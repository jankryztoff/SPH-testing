/**
* Class Name: <CCFailureQueueableClass_RecoveryProcess>
* @authors: <JaysonSarion>
* Date: <3/21/16>
* Requirement/Project Name: <SPH>
* @description: Credit Card Failure Recovery Process. Cancellation, Usage creation, and Related Objects creation
* START-END UD-2549 3/22/2016 Createdby J.Sarion
*/

public class CCFailureQueueableClass_RecoveryProcess implements queueable, Database.AllowsCallouts {
    
    //Lists
    List<Usage__c> usageList = new List<Usage__c>();
    
    //Maps
    Map<String, String> subZuoraIdToUomTypeMap = new Map<String, String>();
    Map<String, Zuora__SubscriptionProductCharge__c> spcIdentifierToSpcMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
    Map<String, Set<String>> subZuoraIdToPubCodeSetMap = new Map<String, Set<String>>();
    
    //Sets
    public Set<Id> billAccIdSet {get;set;}
    
    public Boolean isBillRun = boolean.valueOf(ConstantsSLB.getKeyId('BILL_RUN_TESTING').toLowerCase());
    Date_Configuration__c dateConfig = Date_Configuration__c.getInstance('PAYMENT_FAILURE_TEST_PSTOP_DATE');
    public Date testingPSTOPDate = dateConfig.Date__c;
    
    public CCFailureQueueableClass_RecoveryProcess(Set<Id> billAccIds) {
        this.billAccIdSet = billAccIds;
    }
      
    public void execute(QueueableContext context){
        //Maps
        Map<String, Publication__c> pubCodeToPubMap = new Map<String, Publication__c>();
        Map<String, Date> subZuoraIdToEarliestDateMap = new Map<String, Date>();
        Map<String, Date> subZuoraIdToEarliestDateMap2 = new Map<String, Date>();
        Map<String, Object> objMap = new Map<String, Object>();
        Map<Id, String> oliIdToPubIdMap = new Map<Id, String>();
        
        //Sets
        Set<String> allPubCodeSet = new Set<String>();
        
        //Lists
        List<Map<String, String>> resultMapList = new List<Map<String, String>>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        List<Publication__c> pubList = new List<Publication__c>();
        List<Map<String, Object>> amendmentCancelMapList = new List<Map<String, Object>>();


        List<Zuora__Subscription__c> subDelList = new List<Zuora__Subscription__c>();
        List<Zuora__Subscription__c> subForCaseCreationList = new List<Zuora__Subscription__c>();
        
        Logger logger = new Logger(CCFailureQueueableClass_RecoveryProcess.class.getName());
        UsageHelper.initialize();
        
        try {
            ZuoraCallOut zCallout = new ZuoraCallOut();
            
            system.debug('>>>>>billAccIdSet ' + billAccIdSet);
            if(!billAccIdSet.isEmpty()) {
                subList = [SELECT Id, Name, Zuora__Account__c, Product_Code__c, Main_Package_1__c, Zuora__Zuora_Id__c, Billing_Type__c, Delivered_By__c, 
                                Zuora__SubscriptionEndDate__c, Main_Package_1__r.Package_Type__c, Subscriber_Contact__c, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__DefaultPaymentMethod__c, Subscription_Type_1__c, Order_Line_Item_Number_1__c, Zuora__SubscriptionStartDate__c, (SELECT Id, PublicationCode__c FROM Zuora__Subscription_Product_Charges__r WHERE Zuora__Subscription__r.Subscription_Type_1__c = 'Publication') 
                           FROM Zuora__Subscription__c 
                           WHERE Zuora__CustomerAccount__c IN :billAccIdSet AND Billing_Type__c != 'Full Prepaid'];
                           
                for(Zuora__Subscription__c sub :subList) {
                    Set<String> pubCodeSet = new Set<String>();
                    
                    if(sub.Subscription_Type_1__c == 'Publication') {
                        subForCaseCreationList.add(sub); //START-END UD-2549 3/29/2016 Added by J.Sarion
                        oliIdToPubIdMap.put(sub.Order_Line_Item_Number_1__c, sub.Zuora__Zuora_Id__c);
                    }
                    
                    for(Zuora__SubscriptionProductCharge__c spc :sub.Zuora__Subscription_Product_Charges__r) {
                        if(spc.PublicationCode__c != null) {
                            pubCodeSet.add(spc.PublicationCode__c);
                            allPubCodeSet.add(spc.PublicationCode__c);
                        }
                    }
                    
                    pubCodeSet.remove(null);
                    subZuoraIdToPubCodeSetMap.put(sub.Zuora__Zuora_Id__c, new Set<String>(pubCodeSet));
                }
            }
            system.debug('>>>>>subZuoraIdToPubCodeSetMap ' + subZuoraIdToPubCodeSetMap);
            system.debug('>>>>>allPubCodeSet ' + allPubCodeSet);
            if(!allPubCodeSet.isEmpty()) {
                pubList = [SELECT Id, Earliest_Start_Date__c, Publication_Code__c 
                           FROM Publication__c 
                           WHERE Publication_Code__c IN :allPubCodeSet];
                           
                for(Publication__c pub :pubList) {
                    pubCodeToPubMap.put(pub.Publication_Code__c, pub);
                }
            }
            system.debug('>>>>>pubCodeToPubMap ' + pubCodeToPubMap);
            //START UD-2549 4/3/2016 Added by J.Sarion - Set cancellation date. Check if for bill run testing
            system.debug('>>>>>isBillRun ' + isBillRun);
            if(!subZuoraIdToPubCodeSetMap.isEmpty()) {
                for(String subZuoraId :subZuoraIdToPubCodeSetMap.keySet()) {
                    List<Date> earliestDateList = new List<Date>();
                    
                    for(String pubCode :subZuoraIdToPubCodeSetMap.get(subZuoraId)) {
                        if(pubCodeToPubMap.containsKey(pubCode)) {
                            system.debug('>>>>>Earliest_Start_Date__c ' + pubCodeToPubMap.get(pubCode).Earliest_Start_Date__c);
                            if(pubCodeToPubMap.get(pubCode).Earliest_Start_Date__c != null) {
                                earliestDateList.add(pubCodeToPubMap.get(pubCode).Earliest_Start_Date__c);
                            }
                        }
                    }
                    system.debug('>>>>>earliestDateList ' + earliestDateList);
                    if(!earliestDateList.isEmpty()) {
                        earliestDateList.sort();
                        subZuoraIdToEarliestDateMap.put(subZuoraId, earliestDateList[0]);
                        subZuoraIdToEarliestDateMap2.put(subZuoraId, earliestDateList[0]);
                        
                        if(isBillRun) {
                            subZuoraIdToEarliestDateMap.put(subZuoraId, testingPSTOPDate);
                            subZuoraIdToEarliestDateMap2.put(subZuoraId, testingPSTOPDate);
                        }
                    }
                }
            }
            system.debug('>>>>>subZuoraIdToEarliestDateMap ' + subZuoraIdToEarliestDateMap);
            if(!oliIdToPubIdMap.isEmpty()) {
                subDelList = [SELECT Id, Name, Zuora__Zuora_Id__c, Order_Line_Item_Number_1__c 
                              FROM Zuora__Subscription__c 
                              WHERE Order_Line_Item_Number_1__c IN :oliIdToPubIdMap.keySet() AND Subscription_Type_1__c != 'Publication'];
                              
                for(Zuora__Subscription__c sub :subDelList) {
                    if(subZuoraIdToEarliestDateMap.containsKey(oliIdToPubIdMap.get(sub.Order_Line_Item_Number_1__c))) {
                        subZuoraIdToEarliestDateMap.put(sub.Zuora__Zuora_Id__c, subZuoraIdToEarliestDateMap.get(oliIdToPubIdMap.get(sub.Order_Line_Item_Number_1__c)));
                    }
                }
            }
            
            if(!subZuoraIdToEarliestDateMap.isEmpty()) {
                for(String subZuoraId :subZuoraIdToEarliestDateMap.keySet()) {
                    amendmentCancelMapList.add(createCancelAmendment(subZuoraId, subZuoraIdToEarliestDateMap.get(subZuoraId)));
                }
                
                usageDataPrep(subZuoraIdToEarliestDateMap2);
            }
            
            if(!amendmentCancelMapList.isEmpty()) {
                resultMapList = new List<Map<String, String>>();
                
                resultMapList = zCallout.amendZObjects(amendmentCancelMapList);
                system.debug('>>>>>resultMapList ' + resultMapList);
                for(Map<String, String> resultMap :resultMapList) {
                    if(resultMap.get('Status') != 'Success') {
                        logger.log(false, resultMap.get('Message'));
                    }
                }
            }
            
            if(!subForCaseCreationList.isEmpty()) {
                system.debug('>>>>>subForCaseCreationList ' + subForCaseCreationList);
                BulkStopOrderCreationHandler bulkStop = new BulkStopOrderCreationHandler();
                map<id, id> subscriptionId_caseId = new map<id, id>();
                subscriptionId_caseId = bulkStop.createRelatedRecords(subForCaseCreationList);
            }
            
            system.debug('>>>>>usageList ' + usageList);
            if(!usageList.isEmpty()) {
                insert usageList;
            }
        }
        catch(Exception e) {
            logger.log(e);
        }
        logger.save();
    }
    
    public static Map<String, Object> createCancelAmendment(String subZuoraId, Date stopDate) {
        Map<String,Object> amendmentMap = new Map<String, Object>();
        String stopZuoraDate = '';
        if(stopDate != null) {
            stopZuoraDate = zuora.zUtil.getZuoraDate(stopDate);
        }
        
        system.debug('=====Inside Loop SelectedSubscription====>>');
        amendmentMap = new Map<String, Object>();
        amendmentMap.put(globalvariableclass.CONTRACT_EFFECTIVEDATE, stopZuoraDate);
        amendmentMap.put(globalvariableclass.DESCRIPTION, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
        amendmentMap.put(globalvariableclass.EFFECTIVE_DATE, stopZuoraDate);
        amendmentMap.put(globalvariableclass.NAME, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
        amendmentMap.put(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
        amendmentMap.put(globalvariableclass.SUBSCRIPTION_ID, subZuoraId);
        amendmentMap.put(globalvariableclass.TYPE, globalvariableclass.CANCELATION);
        system.debug('>>>>>createCancelAmendment ' + amendmentMap);
        
        return amendmentMap;
    }
    
    public void usageDataPrep(Map<String, Date> subZuoraIdToStopDate) {
        //Variables
        final String COPY_USAGE = 'Copy';
        final String ISSUE_USAGE = 'Issue';
        Date usageStartDate;
        Date usageEndDate;
        String usageType;
        system.debug('>>>>>subZuoraIdToStopDate ' + subZuoraIdToStopDate);
        //Lists
        List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        //Sets
        Set<Usage__c> usageSet = new Set<Usage__c>();
        
        
        subList = [SELECT Id, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c,Frequency_1__c, Grace_End_Date__c, Zuora__Status__c, Zuora__SubscriptionStartDate__c, 
                        Zuora__SubscriptionEndDate__c, Number_of_Copies__c, Billing_Type__c, Grace_Period_Subscription__c, Grace_Days__c, 
                        Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Order_Line_Item_Number_1__r.Ph_e__c, Order_Line_Item_Number_1__r.Ph_d__c, 
                        Zuora__TermSettingType__c, Term_Length__c, Zuora__Zuora_Id__c 
                   FROM Zuora__Subscription__c 
                   WHERE Zuora__Zuora_Id__c IN :subZuoraIdToStopDate.keySet() AND Subscription_Type_1__c = 'Publication'];
        
        spcList = [SELECT Zuora__Quantity__c, Zuora__RatePlanName__c, Name,Id, Zuora__ProductSKU__c, Zuora__ChargeNumber__c, Zuora__UOM__c, Zuora__Type__c, 
                        Zuora__Subscription__c, PublicationCode__c, Zuora__Subscription__r.Zuora__Zuora_Id__c, Zuora__Subscription__r.Billing_Type__c
                   FROM Zuora__SubscriptionProductCharge__c 
                   WHERE Zuora__Type__c = 'Usage' AND Zuora__Subscription__r.Zuora__Zuora_Id__c IN :subZuoraIdToStopDate.keySet() AND Zuora__Subscription__r.Subscription_Type_1__c = 'Publication'];
        system.debug('>>>>>test2');
        system.debug('>>>>>subList ' + subList);
        system.debug('>>>>>spcList ' + spcList);
        for(Zuora__SubscriptionProductCharge__c spc :spcList) {         
            if(spc.PublicationCode__c != null) {
                if(subZuoraIdToPubCodeSetMap.get(spc.Zuora__Subscription__r.Zuora__Zuora_Id__c) == null) { //START-END UD-2549 4/8/2016 Added by J.Sarion - Set Zuora Id
                    subZuoraIdToPubCodeSetMap.put(spc.Zuora__Subscription__r.Zuora__Zuora_Id__c, new Set<String>());
                }
                subZuoraIdToPubCodeSetMap.get(spc.Zuora__Subscription__r.Zuora__Zuora_Id__c).add(spc.PublicationCode__c);
                
                if(spc.Zuora__Subscription__r.Billing_Type__c == 'Recurring Prepaid') {
                    spcIdentifierToSpcMap.put(generateSpcIndentifierKey(spc.Zuora__Subscription__r.Zuora__Zuora_Id__c, spc.Zuora__UOM__c, spc.PublicationCode__c), spc);
                }
                else if(spc.Zuora__Subscription__r.Billing_Type__c == 'Recurring Postpaid') {
                    spcIdentifierToSpcMap.put(generateSpcIndentifierKey(spc.Zuora__Subscription__r.Zuora__Zuora_Id__c, spc.Zuora__UOM__c, spc.PublicationCode__c), spc);
                }
            }
        }
        //system.assertEquals(subList, null);
        system.debug('>>>>>spcList ' + spcList);
        system.debug('>>>>>spcIdentifierToSpcMap ' + spcIdentifierToSpcMap);
        system.debug('>>>>>test1');
        for(Zuora__Subscription__c sub :subList) {
            //START UD-2549 3/29/2016 Added by J.Sarion - Set usageStartDate to Sub Start Date if it's first payment failure
            if(sub.Zuora__SubscriptionStartDate__c.monthsBetween(subZuoraIdToStopDate.get(sub.Zuora__Zuora_Id__c)) == 1) {
                usageStartDate = sub.Zuora__SubscriptionStartDate__c;
            }
            else {
                //START UD-2549 4/8/2016 Added by J.Sarion - set usage Start Date
                usageStartDate = subZuoraIdToStopDate.get(sub.Zuora__Zuora_Id__c).toStartOfMonth(); //for Recurring Prepaid
                if(sub.Billing_Type__c == 'Recurring Postpaid') {
                    usageStartDate = subZuoraIdToStopDate.get(sub.Zuora__Zuora_Id__c).addMonths(-1).toStartOfMonth();
                }
                //END UD-2549 4/8/2016 Added by J.Sarion - set usage Start Date
            }
            usageEndDate = subZuoraIdToStopDate.get(sub.Zuora__Zuora_Id__c).addDays(-1);
            //END UD-2549 3/29/2016 Added by J.Sarion - Set usageStartDate to Sub Start Date if it's first payment failure
            
            if(sub.Billing_Type__c == 'Recurring Prepaid') {
                subZuoraIdToUomTypeMap.put(sub.Zuora__Zuora_Id__c, COPY_USAGE);
            }
            else if(sub.Billing_Type__c == 'Recurring Postpaid') {
                subZuoraIdToUomTypeMap.put(sub.Zuora__Zuora_Id__c, ISSUE_USAGE);
            }
            system.debug('>>>>>usageStartDate ' + usageStartDate);
            system.debug('>>>>>usageEndDate ' + usageEndDate);
            createUsageFirst(sub, usageStartDate, usageEndDate);
        }
        system.debug('>>>>>test');
    }
    
    public void createUsageFirst (Zuora__Subscription__c sub, Date startDate, Date endDate) { 
        PublicationIssueWrapper pubIssueWrapperObject;
        if (subZuoraIdToPubCodeSetMap.containsKey(sub.Zuora__Zuora_Id__c)) {
            for (String pubCode :subZuoraIdToPubCodeSetMap.get(sub.Zuora__Zuora_Id__c)) {
                pubIssueWrapperObject = UsageHelper.IssueCalculation(pubCode, startDate, endDate, sub, Integer.valueOf(sub.Number_of_Copies__c));
                system.debug('>>>>>pubIssueWrapperObject ' + pubIssueWrapperObject);
                createUsagePrep(sub, pubIssueWrapperObject.weekday_no_of_copies, 'Weekday', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.sat_no_of_copies, 'Sat', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.sun_no_of_copies, 'Sun', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Online', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Smartphone', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Tablet', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Online', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Smartphone', endDate, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Tablet', endDate, pubCode);
            }
        }
    }
    
    public void createUsagePrep (Zuora__Subscription__c sub, Integer quantity, String uom, Date usageDate, String pubCode) {             
        Usage__c usage = new Usage__c();
        usage = createUsage(sub, quantity, uom, usageDate, pubCode);
        
        if (usage.Quantity__c != 0 && usage != null && usage.Quantity__c > 0)
            usageList.add(usage);
    }
    
    private Usage__c createUsage (Zuora__Subscription__c sub, Integer quantity, String uom, Date usageDate, String pubCode) {
        String spcIdentifier = generateSpcIndentifierKey(sub.Zuora__Zuora_Id__c, subZuoraIdToUomTypeMap.get(sub.Zuora__Zuora_Id__c) + ' ' + uom, pubCode);
        system.debug('>>>>>spcIdentifier ' + spcIdentifier);
        Usage__c usage = new Usage__c();
        system.debug('>>>>>spcIdentifier ' + spcIdentifierToSpcMap.containsKey(spcIdentifier));
        if (spcIdentifierToSpcMap.containsKey(spcIdentifier)) {
            Zuora__SubscriptionProductCharge__c spc = spcIdentifierToSpcMap.get(spcIdentifier);

            usage.Account_Id__c = sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
            usage.Subscription_Id__c = sub.Name;
            usage.End_Date__c = usageDate;
            usage.Status__c = UsageHelper.USAGE_STATUS;
            usage.UOM__c = spc.Zuora__UOM__c;
            usage.Rate_Plan_Charge_Id__c = spc.Zuora__ChargeNumber__c;                 
            usage.Publication_Code__c = spc.PublicationCode__c;
            usage.Quantity__c = quantity;
            
            if(sub.Billing_Type__c == 'Recurring Prepaid') {
                usage.Usage_Type__c = UsageHelper.USAGE_TYPE_RECURRING_PREPAID_STOP;
            }
            else if(sub.Billing_Type__c == 'Recurring Postpaid') {
                usage.Usage_Type__c = 'RecurringPostpaid_Stop';
            }
            
            usage.Start_Date__c = usageDate.toStartOfMonth();
            
            usage.StopType__c = 'PStop';
        }
        return usage;
    }
    
    public static string generateSpcIndentifierKey(string subscriptionId, string uom, String pubCode) {
        return subscriptionId + ' ' + uom + ' ' + pubCode;
    }
}