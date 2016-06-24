/**
 * Class Name: SP_MidMonthStartProrationBatch
 * @author: Karl Tan
 * Date: 
 * Requirement/Project Name: CRSM Project
 * @description Batch Apex Class to Create Usage Records for Mid-Month Start Subscriptions
 * 
 * History: D-1615, D-1618, D-1619 22/01/2015 Jeff Teves
 * -- Restructured entire code for logic updates based on new Product Catalogue design
 * -- Reorganized loops for more efficient processing - iterate on Date per subscription, not per subscription product and charge record.
 * -- D-2425 03/20/2015 Added by J. Sarion - MD-55 Issue Calculation: Implement Proration Usage to Zuora based from the excel sent by Ankit
 * -- D - 2657 03/30/2015 Added by JOban - Added the field in the query
 */
 
global class SP_MidMonthStartProrationSingleMarvin {
    global Batch_Configuration_Settings__c batchSettings; //configuration data for SP_MidMonthStartProrationBatch
    final String RECURRING_PREPAID = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    final String RECURRING_POSTPAID = GlobalVariableClass.RECURRING_POSTPAID;
    final String STATUS_ACTIVE = GlobalVariableClass.STATUS_ACTIVE;
    final String STATUS_EXPIRED = GlobalVariableClass.STATUS_EXPIRED;
    final String POSTPAID_USAGE = GlobalVariableClass.POSTPAID_USAGE;
    final String PRORATION_CHARGE_USAGE = GlobalVariableClass.PRORATION_CHARGE_USAGE;
    final String PRORATION_CREDIT_USAGE = GlobalVariableClass.PRORATION_CREDIT_USAGE;
    final String PRORATION_NO_CREDIT_USAGE = GlobalVariableClass.PRORATION_NO_CREDIT_USAGE;
    final string NO_CREDIT_USAGE = 'No Credit Copy';
    final string CREDIT_USAGE = 'Credit Copy';
    final String COPY_USAGE = 'Copy';
    final String ISSUE_USAGE = 'Issue';
    final string USAGE_STATUS = 'New';
    String spcIdentifier;
    Integer subCounter = 0;
    Integer spcCounter = 0;
    Integer year;
    Integer month;
    Boolean isStart = false;
    Boolean isEnd = false;
    Zuora__SubscriptionProductCharge__c spc;
    Usage__c usage;
    
    Map<Id, String> subIdToUomTypeMap = new Map<Id, String>();
    Map<Id, Set<String>> subIdToPubCodeSetMap = new Map<Id, Set<String>>();
    Map<String, Zuora__SubscriptionProductCharge__c> spcIdentifierToSpcMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
    set<Usage__c> usageSet = new set<Usage__c>();
    
    //START 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches  
    private final static Date referenceDate = UsageHelper.getUsageReferenceDate(); 
    //START 04/28/15 D-2838 Kevin Evasco - Include Expiry Usage 
    private final static Date firstDayOfMonth = referenceDate.toStartOfMonth();
    private final static Date lastDayOfMonth = referenceDate.addMonths(1).toStartofMonth().addDays(-1);   
    private final static Date firstDayOfNextMonth = referenceDate.addMonths(1).toStartofMonth();    
    private final static Date lastDayOfNextMonth = referenceDate.addMonths(2).toStartofMonth().addDays(-1);  
    
    public static integer myCounter;
    //END 04/28/15 D-2838 Kevin Evasco - Include Expiry Usage   
    //END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches    
    
   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bc- predefined parameter 
    * @return list of objects from Subscription Object
    */     
   
    global Database.QueryLocator start(Database.BatchableContext bc) {
        myCounter=0;
        batchSettings = Batch_Configuration_Settings__c.getInstance('SP_MidMonthStartProrationBatch');
        return Database.getQueryLocator([SELECT Id, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c,Frequency_1__c, Grace_End_Date__c, Zuora__Status__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Number_of_Copies__c, Billing_Type__c, Grace_Period_Subscription__c, Grace_Days__c, Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Order_Line_Item_Number_1__r.Ph_e__c, Order_Line_Item_Number_1__r.Ph_d__c, Zuora__TermSettingType__c FROM Zuora__Subscription__c WHERE 
        ((Billing_Type__c = 'Recurring Prepaid' AND Zuora__SubscriptionStartDate__c <= :lastDayOfMonth AND Zuora__SubscriptionStartDate__c > :firstDayOfMonth AND Grace_Period_Subscription__c = null) OR //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier.
        (Billing_Type__c = 'Recurring Prepaid' AND Zuora__SubscriptionEndDate__c < :lastDayOfNextMonth AND Zuora__SubscriptionEndDate__c >= :firstDayOfNextMonth AND Grace_Period_Subscription__c = null) OR //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier.
        (Billing_Type__c = 'Recurring Prepaid' AND Zuora__SubscriptionStartDate__c <= :lastDayOfMonth AND Zuora__SubscriptionStartDate__c > :firstDayOfMonth AND Grace_Period_Subscription__c = null AND Zuora__TermSettingType__c = 'EVERGREEN') OR //START/END 05/09/2015 D-2890 J. Sarion - Create usage for Evergreen
        (Billing_Type__c = 'Recurring PostPaid' AND Zuora__SubscriptionStartDate__c <= :lastDayOfMonth AND Grace_Period_Subscription__c = null AND Zuora__TermSettingType__c = 'EVERGREEN') OR //START/END 05/09/2015 D-2890 J. Sarion - Create usage for Evergreen
        (Billing_Type__c = 'Recurring Postpaid' AND Zuora__SubscriptionStartDate__c <= :lastDayOfMonth AND Zuora__SubscriptionEndDate__c >= :firstDayOfMonth AND Grace_Period_Subscription__c = null) OR
        (Grace_Period_Subscription__c != null AND Zuora__Status__c = 'Active')) AND (Number_of_Copies__c != 0 OR Number_of_Copies__c != null) AND Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION
        AND id in ('a0DO0000006fYN5','a0DO0000006fYN3', 'a0DO0000006fYN1', 'a0DO0000006fYN7')]);   
       
    }
    
    /* @description Executes the business logic and creates Usage object
     * 
     * @param bc- predefined parameter 
     * @param allScopes - a list of sObjects from the initial database query
     * @return void
     */    
    
    //public void execute(List<Zuora__Subscription__c> subList) {
    public void execute(List<Zuora__Subscription__c> subList) {
        //system.debug('>>>>>>>>>>> Marvin ' + myCounter);
        //system.debug('>>>>>>>>>>> size ' + subList.size());
        //myCounter = myCounter + 1;
        //if (myCounter==2){
        //    system.assertequals(subList, null);
        //}
        myCounter =0;

            List<Usage__c> usageList = new List<Usage__c>();       
            Set<String> ratePlanCharges = new Set<String>();
            List<Zuora__SubscriptionProductCharge__c> subProdChaList = new List<Zuora__SubscriptionProductCharge__c> ();        
            Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
            Set<String> pubCodes = new Set<String>();
            Map<Id, zqu__ProductRatePlanCharge__c> mapSubProdChargeIdToProdRatePlanCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
            Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();
            Map<String, Set<Date>> mapPubCodeToNonPubDates = new Map<String, Set<Date>>();
    
            //Map<String, Unit_of_Measure__c> mapUOM = Unit_of_Measure__c.getall();
            Set<String> copyUOMs = new Set<String>();
            Set<String> issueUOMs = new Set<String>();
            Set<String> creditCopyUOMS = new Set<String>();
            //START: D-1968 / 3-9-2015/  / K. Tan/ Modify existing query to capture Grace Period Subscriptions 
            Set<String> noCreditUOMs = new Set<String>();
            //END: D-1968 / 3-9-2015/  / K. Tan/ Modify existing query to capture Grace Period Subscriptions 
    
            // START 04/07/2015 D-2700 Kevin Evasco - Removed Inner Query from Query Locator
            Set<Id> scopeIdSet = new Set<Id>();
            Map<Id,List<Zuora__SubscriptionProductCharge__c>> subscription_subscriptionProductCharges_map = new Map<Id,List<Zuora__SubscriptionProductCharge__c>>(); 
            for(Zuora__Subscription__c subElement : subList) {
                scopeIdSet.add(subElement.Id);
            }
            List<Zuora__SubscriptionProductCharge__c> spcList = [SELECT Zuora__Quantity__c, Zuora__RatePlanName__c, Name,Id, Zuora__ProductSKU__c, Zuora__ChargeNumber__c, Zuora__UOM__c, Zuora__Type__c, Zuora__Subscription__c, PublicationCode__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Type__c = 'Usage' AND Zuora__Subscription__c IN :scopeIdSet];
            
            for(Zuora__SubscriptionProductCharge__c spcElement : spcList) {
                if(subscription_subscriptionProductCharges_map.get(spcElement.Zuora__Subscription__c) == null) {
                    subscription_subscriptionProductCharges_map.put(spcElement.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c>());
                }
                subscription_subscriptionProductCharges_map.get(spcElement.Zuora__Subscription__c).add(spcElement);
            }
            // END 04/07/2015 D-2700 Kevin Evasco - Removed Inner Query from Query Locator      
            UsageHelper.initialize();
            
            //create a set of UOM strings for Prepaid and PostPaid
            for(Unit_of_Measure__c uom : Unit_of_Measure__c.getall().values()) {
                if(uom.Used_for__c == PRORATION_CHARGE_USAGE) {
                    copyUOMs.add(uom.Name);
                }
                else if(uom.Used_for__c == POSTPAID_USAGE) {
                    issueUOMs.add(uom.Name);
                }
                else if(uom.Used_for__c == PRORATION_CREDIT_USAGE) {
                    creditCopyUOMS.add(uom.Name);
                }
            //START: D-1968 / 3-9-2015/ K. Tan/ Modify existing query to capture Grace Period Subscriptions 
                
                else if(uom.Used_for__c == PRORATION_NO_CREDIT_USAGE) {
                    noCreditUOMs.add(uom.Name);
                }
            //END: D-1968 / 3-9-2015/  / K. Tan/ Modify existing query to capture Grace Period Subscriptions 
                
            }
    
            for(Zuora__Subscription__c sub : subList) {
                // START 04/07/2015 D-2700 Kevin Evasco - Perform code only if map value is not null to avoid null pointer exception
                if(subscription_subscriptionProductCharges_map.get(sub.Id) != null) {
                    for (Zuora__SubscriptionProductCharge__c spc :subscription_subscriptionProductCharges_map.get(sub.Id)) {
                        if (subIdToPubCodeSetMap.containsKey(spc.Zuora__Subscription__c)) {
                            if (spc.PublicationCode__c != null)
                                subIdToPubCodeSetMap.get(spc.Zuora__Subscription__c).add(spc.PublicationCode__c);
                        }
                        else {
                            if (spc.PublicationCode__c != null)
                                subIdToPubCodeSetMap.put(spc.Zuora__Subscription__c, new Set<String> {spc.PublicationCode__c});
                        }
                        
                        spcIdentifierToSpcMap.put(spc.Zuora__Subscription__c + ' ' + spc.Zuora__UOM__c + ' ' + spc.PublicationCode__c, spc);//START/END: D-2923 13-May-2015 Added by JTeves - add PubCode in uniqueMap
                    }
                }
                // END 04/07/2015 D-2700 Kevin Evasco - Perform code only if map value is not null to avoid null pointer exception
                
                
                
                year = referenceDate.year(); //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches     
                month = referenceDate.month(); //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches       
                
                //START 04/28/15 D-2838 Kevin Evasco - Include Expiry Usage 
                Date usageStartDate;
                Date usageEndDate;
                Date usageDate;
                String usageType;
                
                if(sub.Billing_Type__c == 'Recurring Prepaid' && sub.Zuora__SubscriptionStartDate__c <= lastDayOfMonth && sub.Zuora__SubscriptionStartDate__c > firstDayOfMonth && sub.Grace_Period_Subscription__c == null){ //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier.
                    usageStartDate = sub.Zuora__SubscriptionStartDate__c;
                    usageEndDate = lastDayOfMonth;
                    usageType = UsageHelper.USAGE_TYPE_RECURRING_PREPAID_START; 
                    usageDate = sub.Zuora__SubscriptionStartDate__c;
                    subIdToUomTypeMap.put(sub.Id, COPY_USAGE);
                }
                
                else if(sub.Billing_Type__c == 'Recurring Prepaid' && sub.Zuora__SubscriptionEndDate__c < lastDayOfNextMonth && sub.Zuora__SubscriptionEndDate__c >= firstDayOfNextMonth && sub.Grace_Period_Subscription__c == null){ //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier.
                    //START D-2974 5/26/2015 Added By C. Lin - Create Copy usage instead of Credit usage.
                    usageStartDate = firstDayOfNextMonth;
                    usageEndDate = sub.Zuora__SubscriptionEndDate__c;
                    usageType = UsageHelper.USAGE_TYPE_RECURRING_PREPAID_EXPIRY; 
                    usageDate = lastDayOfMonth;
                    subIdToUomTypeMap.put(sub.Id, COPY_USAGE);
                    //END D-2974 5/26/2015 Added By C. Lin
                }
                
                //START 05/09/2015 D-2890 J. Sarion - Create usage for Evergreen
                else if(sub.Billing_Type__c == 'Recurring Prepaid' && sub.Zuora__SubscriptionStartDate__c <= lastDayOfMonth && sub.Zuora__SubscriptionStartDate__c > firstDayOfMonth && sub.Grace_Period_Subscription__c == null && sub.Zuora__TermSettingType__c == 'EVERGREEN'){ 
                    usageStartDate = sub.Zuora__SubscriptionStartDate__c;
                    usageEndDate = lastDayOfMonth;
                    usageType = UsageHelper.USAGE_TYPE_RECURRING_PREPAID_START; 
                    usageDate = sub.Zuora__SubscriptionStartDate__c;
                    subIdToUomTypeMap.put(sub.Id, COPY_USAGE);
                }
                
                else if(sub.Billing_Type__c == 'Recurring PostPaid' && sub.Zuora__SubscriptionStartDate__c <= lastDayOfMonth && sub.Grace_Period_Subscription__c == null && sub.Zuora__TermSettingType__c == 'EVERGREEN'){
                    if(sub.Zuora__SubscriptionStartDate__c.monthsBetween(referenceDate) == 0){
                        usageStartDate = sub.Zuora__SubscriptionStartDate__c;
                        usageEndDate = lastDayOfMonth;                
                    } else {
                        usageStartDate = firstDayOfMonth;
                        usageEndDate = lastDayOfMonth;  
                    }
                    usageType = UsageHelper.USAGE_TYPE_RECURRING_POSTPAID_MONTHLY;              
                    usageDate = lastDayOfMonth;
                    subIdToUomTypeMap.put(sub.Id, ISSUE_USAGE);
                } 
                //END 05/09/2015 D-2890 J. Sarion - Create usage for Evergreen
                else if(sub.Billing_Type__c == 'Recurring Postpaid' && sub.Zuora__SubscriptionStartDate__c <= lastDayOfMonth && sub.Zuora__SubscriptionEndDate__c >= firstDayOfMonth && sub.Grace_Period_Subscription__c == null){
                    if(sub.Zuora__SubscriptionStartDate__c.monthsBetween(referenceDate) == 0){
                        usageStartDate = sub.Zuora__SubscriptionStartDate__c;
                        usageEndDate = lastDayOfMonth;
                    } else if(sub.Zuora__SubscriptionEndDate__c.monthsBetween(referenceDate) == 0) {
                        usageStartDate = firstDayOfMonth;
                        usageEndDate = sub.Zuora__SubscriptionEndDate__c;                   
                    } else {
                        usageStartDate = firstDayOfMonth;
                        usageEndDate = lastDayOfMonth;  
                    }
                    usageType = UsageHelper.USAGE_TYPE_RECURRING_POSTPAID_MONTHLY;              
                    usageDate = lastDayOfMonth;
                    subIdToUomTypeMap.put(sub.Id, ISSUE_USAGE);
                }           
                else if (sub.Grace_Period_Subscription__c != null && sub.Zuora__Status__c == 'Active'){
                    if(sub.Zuora__SubscriptionStartDate__c.monthsBetween(referenceDate) == 0){                  
                        usageStartDate = sub.Zuora__SubscriptionStartDate__c;
                        usageEndDate = lastDayOfMonth;
                        usageDate = sub.Zuora__SubscriptionStartDate__c;
                    } else {
                        usageStartDate = firstDayOfMonth;
                        usageEndDate = sub.Zuora__SubscriptionEndDate__c;
                        usageDate = firstDayOfMonth;
                    }
                    usageType = UsageHelper.USAGE_TYPE_GRACE;   
                    subIdToUomTypeMap.put(sub.Id, NO_CREDIT_USAGE);             
                }
                
                createUsageFirst(sub, usageStartDate, usageEndDate, usageDate, usageType);
                
            }
            
            for (Usage__c usage :usageSet) {
                usageList.add(usage);
            }
            
            
            //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            UsageHelper.insertUniqueUsages(usageList);
                        
        //}     // Counter
    } 
 
    global void finish(Database.BatchableContext BC) {
        //SP_ExpiredProrationBatch bP = new SP_ExpiredProrationBatch(); 
        //database.executebatch(bP);
        
        
        String shortID = String.valueOf(BC.getJobId()).subString(0,15);
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :BC.getJobId()];

        if(batchJobSchedulerList.size() > 0)
        {
            BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
            batchJobScheduler.Status__c = 'SUCCESS';
            batchJobScheduler.End_Time__c = DateTime.now();
            update batchJobScheduler;           
            
            BatchServiceFacade a1F = new BatchServiceFacade();
            BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
            serviceRequestVO.setJobStatus(0);
            serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
            serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
            a1F.delegateBatchCall(serviceRequestVO);
        }
    }
    //START 04/28/15 D-2838 Kevin Evasco - Include Expiry Usage 
    
    private void createUsageFirst (Zuora__Subscription__c sub, Date startDate, Date endDate, Date usageDate, String usageType) { 
        
        PublicationIssueWrapper pubIssueWrapperObject;
        if (subIdToPubCodeSetMap.containsKey(sub.Id)) {
            for (String pubCode :subIdToPubCodeSetMap.get(sub.Id)) {
               // pubIssueWrapperObject = UsageHelper.IssueCalculation(pubCode, startDate, endDate, sub, Integer.valueOf(sub.Number_of_Copies__c));
                pubIssueWrapperObject = UsageHelper.IssueCalculation(pubCode, startDate, endDate, sub, Integer.valueOf(sub.Number_of_Copies__c));
                //START: D-2923 13-May-2015 Added by JTeves - add PubCode in uniqueMap
                //if (pubIssueWrapperObject.weekday_no_of_copies != 0)
                createUsagePrep(sub, pubIssueWrapperObject.weekday_no_of_copies, 'Weekday', usageDate, usageType, pubCode);
                //if (pubIssueWrapperObject.sat_no_of_copies != 0)
                createUsagePrep(sub, pubIssueWrapperObject.sat_no_of_copies, 'Sat', usageDate, usageType, pubCode);
                //if (pubIssueWrapperObject.sun_no_of_copies != 0)
                createUsagePrep(sub, pubIssueWrapperObject.sun_no_of_copies, 'Sun', usageDate, usageType, pubCode);
                //if (pubIssueWrapperObject.odd_freq_copies != 0) {
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Online', usageDate, usageType, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Smartphone', usageDate, usageType, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Tablet', usageDate, usageType, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Online', usageDate, usageType, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Smartphone', usageDate, usageType, pubCode);
                createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Tablet', usageDate, usageType, pubCode);
                //END: D-2923 13-May-2015 Added by JTeves - add PubCode in uniqueMap
            }
        }
    }
    //START: D-2923 13-May-2015 Added by JTeves - add PubCode in uniqueMap
    private void createUsagePrep (Zuora__Subscription__c sub, Integer quantity, String uom, Date usageDate, String usageType, String pubCode) {             
        usage = new Usage__c();
        usage = createUsage(sub, quantity, uom, usageDate, usageType, pubCode);

        
        if (usage.Quantity__c != 0 && usage != null)
            usageSet.add(usage);
    }  
    //END: D-2923 13-May-2015 Added by JTeves - add PubCode in uniqueMap    
    //END 04/28/15 D-2838 Kevin Evasco - Include Expiry Usage 
    
    private Usage__c createUsage (Zuora__Subscription__c sub, Integer quantity, String uom, Date usageDate, String usageType, String pubCode) { //START/END: D-2923 13-May-2015 Added by JTeves - add PubCode in uniqueMap
    //START/END 04/28/15 D-2838 Kevin Evasco - Include Expiry Usage 
        spcIdentifier = generateSpcIndentifierKey(sub.Id, subIdToUomTypeMap.get(sub.Id) + ' ' + uom, pubCode);//START/END: D-2923 13-May-2015 Added by JTeves - add PubCode in uniqueMap
        year = referenceDate.year(); //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches     
        month = referenceDate.month(); //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches            
        Date endDate;
        
    //START D-3020 05/25/2015 Added by: J. Sarion - Commented out curly brace. Merged two For Loops referring to same List
        /*
        for (String spc :spcIdentifierToSpcMap.keySet()) {
            system.debug('>>>>>spcString' + spc);
        }
        */
    //END D-3020 05/25/2015 Added by: J. Sarion - Commented out curly brace. Merged two For Loops referring to same List
        usage = new Usage__c();
        if (spcIdentifierToSpcMap.containsKey(spcIdentifier)) {
            spc = spcIdentifierToSpcMap.get(spcIdentifier);
            
            if (sub.Zuora__TermSettingType__c != 'EVERGREEN') {
                if (sub.Zuora__SubscriptionEndDate__c.monthsBetween(referenceDate) == 0 || sub.Grace_Period_Subscription__c != null) { //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches       
                    endDate = sub.Zuora__SubscriptionEndDate__c;
                } else {
                    endDate = date.newInstance(year, month, date.daysInMonth(year, month));
                }
            }
            else
                endDate = date.newInstance(year, month, date.daysInMonth(year, month));
            usage.Account_Id__c = sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
            usage.Subscription_Id__c = sub.Name;
            usage.End_Date__c = endDate;
            usage.Status__c = USAGE_STATUS;
            usage.UOM__c = spc.Zuora__UOM__c;
            usage.Rate_Plan_Charge_Id__c = spc.Zuora__ChargeNumber__c;                 
            usage.Publication_Code__c = spc.PublicationCode__c; //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier  
            usage.Quantity__c = quantity;
            
            
            //START/END 04/28/15 D-2838 Kevin Evasco - Include Expiry Usage 
            /* REMOVED FOR D-2838
            //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            String usageType;
            Date startDate = sub.Zuora__SubscriptionStartDate__c;
            if (sub.Billing_Type__c == 'Recurring Prepaid' && sub.Grace_Period_Subscription__c == null) {
                usageType = UsageHelper.USAGE_TYPE_RECURRING_PREPAID_START;             
            }   
            else if (sub.Billing_Type__c == 'Recurring Postpaid' && sub.Grace_Period_Subscription__c == null) {
                usageType = UsageHelper.USAGE_TYPE_RECURRING_POSTPAID_MONTHLY;              
                startDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);    
            }
            else if (sub.Grace_Period_Subscription__c != null) {
                usageType = UsageHelper.USAGE_TYPE_GRACE;
                
                Date subscriptionStartEOM = firstDayOfMonth.addMonths(1).toStartofMonth().addDays(-1);
                
                if(referenceDate > subscriptionStartEOM){
                    startDate = referenceDate.toStartofMonth();
                }
            }
            REMOVED FOR D-2838 */           
            //END 04/28/15 D-2838 Kevin Evasco - Include Expiry Usage 
            usage.Usage_Type__c = usageType;            
            usage.Start_Date__c = usageDate; //START/END 04/28/15 D-2838 Kevin Evasco - Include Expiry Usage 
            //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            
        }
        return usage;
    }
    
    //START: D-2923 13-May-2015 Added by JTeves - add PubCode in uniqueMap
    private static string generateSpcIndentifierKey(string subscriptionId, string uom, String pubCode) {
        return subscriptionId + ' ' + uom + ' ' + pubCode;
    }
    //END: D-2923 13-May-2015 Added by JTeves - add PubCode in uniqueMap
}