/**
 * Class Name: usageCreationforCCFailure  
 * @author: Marvin Gatchalian/John Dacutan
 * Date: 07/04/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description: This class will create usages/charges to the customer for credit credit card 
 * History Major modification for D-3236
 */

Public class usageCreationforCCFailure {
    public Batch_Configuration_Settings__c batchSettings;
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
    
    private final static Date referenceDate = UsageHelper.getUsageReferenceDate(); 
    private final static Date firstDayOfMonth = referenceDate.toStartOfMonth();
    private final static Date lastDayOfMonth = referenceDate.addMonths(1).toStartofMonth().addDays(-1);   
    private final static Date firstDayOfNextMonth = referenceDate.addMonths(1).toStartofMonth();    
    private final static Date lastDayOfNextMonth = referenceDate.addMonths(2).toStartofMonth().addDays(-1);  
    private static string destinationAccountNumber;
    private static string StopType = 'Pstop';

    
    public void createUsageForCreditCardFailure(Set<Id> subIdSet, String newAccountNumber) {

        List<Usage__c> usageList = new List<Usage__c>();       
        
        Set<String> copyUOMs = new Set<String>();
        Set<String> issueUOMs = new Set<String>();
        Set<String> creditCopyUOMS = new Set<String>();
        Set<String> noCreditUOMs = new Set<String>();
        Set<Id> scopeIdSet = new Set<Id>();
        
        destinationAccountNumber = newAccountNumber;
        
        
        
        
        List <Zuora__Subscription__c> subList = [SELECT Id, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
                                        Frequency_1__c, Grace_End_Date__c, Zuora__Status__c, Zuora__Zuora_Id__c,
                                       Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, 
                                       Number_of_Copies__c, Billing_Type__c, Grace_Period_Subscription__c, 
                                       Grace_Days__c, Order_Line_Item_Number_1__r.Main_Package_Frequency__c, 
                                       Order_Line_Item_Number_1__r.Ph_e__c, Order_Line_Item_Number_1__r.Ph_d__c, 
                                       Zuora__TermSettingType__c FROM Zuora__Subscription__c where id in :subIdSet];
                                       
        
        
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
 
        UsageHelper.initialize();
        
        for(Unit_of_Measure__c uom : Unit_of_Measure__c.getall().values()) {
            if(uom.Used_for__c == GlobalVariableClass.PRORATION_CHARGE_USAGE) {
                copyUOMs.add(uom.Name);
            }
            else if(uom.Used_for__c == GlobalVariableClass.POSTPAID_USAGE) {
                issueUOMs.add(uom.Name);
            }
            else if(uom.Used_for__c == GlobalVariableClass.PRORATION_CREDIT_USAGE) {
                creditCopyUOMS.add(uom.Name);
            }
            else if(uom.Used_for__c == GlobalVariableClass.PRORATION_CREDIT_USAGE) {
                noCreditUOMs.add(uom.Name);
            }
        }

        for(Zuora__Subscription__c sub : subList) {
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
                    
                    spcIdentifierToSpcMap.put(spc.Zuora__Subscription__c + ' ' + spc.Zuora__UOM__c + ' ' + spc.PublicationCode__c, spc);
                }
            }
            year = referenceDate.year(); 
            month = referenceDate.month(); 
            Date usageStartDate;
            Date usageEndDate;
            Date usageDate;
            String usageType;
            
            if(sub.Billing_Type__c == 'Recurring Prepaid' && sub.Zuora__SubscriptionStartDate__c <= lastDayOfMonth ){

                usageEndDate  = date.today();
                usageStartDate = firstDayOfMonth;
                
                usageType = UsageHelper.USAGE_TYPE_RECURRING_PREPAID_START; 
                usageDate = firstDayOfMonth;
                subIdToUomTypeMap.put(sub.Id, 'Copy');
            }
            
            createUsageFirstForCC(sub, usageStartDate, usageEndDate, usageDate, usageType);
            
        }
        
        for (Usage__c usage :usageSet) {
            usageList.add(usage);
        }

        system.debug('>>>>usage List ' + usageList);
        //UsageHelper.insertUniqueUsages(usageList);
        UsageHelper.loadUniqueUsages(usageList,false);

    }
    
     private void createUsageFirstForCC (Zuora__Subscription__c sub, Date startDate, Date endDate, Date usageDate, String usageType) { 
        PublicationIssueWrapper pubIssueWrapperObject;
        if (subIdToPubCodeSetMap.containsKey(sub.Id)) {
            for (String pubCode :subIdToPubCodeSetMap.get(sub.Id)) {
                pubIssueWrapperObject = UsageHelper.IssueCalculation(pubCode, startDate, endDate, sub, Integer.valueOf(sub.Number_of_Copies__c));
                createUsagePrepForCC (sub, pubIssueWrapperObject.weekday_no_of_copies, 'Weekday', usageDate, usageType, pubCode);
                createUsagePrepForCC (sub, pubIssueWrapperObject.sat_no_of_copies, 'Sat', usageDate, usageType, pubCode);
                createUsagePrepForCC (sub, pubIssueWrapperObject.sun_no_of_copies, 'Sun', usageDate, usageType, pubCode);
                createUsagePrepForCC (sub, pubIssueWrapperObject.odd_freq_copies, 'Online', usageDate, usageType, pubCode);
                createUsagePrepForCC (sub, pubIssueWrapperObject.odd_freq_copies, 'Smartphone', usageDate, usageType, pubCode);
                createUsagePrepForCC (sub, pubIssueWrapperObject.odd_freq_copies, 'Tablet', usageDate, usageType, pubCode);
                createUsagePrepForCC (sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Online', usageDate, usageType, pubCode);
                createUsagePrepForCC (sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Smartphone', usageDate, usageType, pubCode);
                createUsagePrepForCC (sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Tablet', usageDate, usageType, pubCode);
            }
            
        } 
    }

    private void createUsagePrepForCC (Zuora__Subscription__c sub, Integer quantity, String uom, Date usageDate, String usageType, String pubCode) {             
        usage = new Usage__c();
        
        usage = createUsageForCC(sub, quantity, uom, usageDate, usageType, pubCode);
        
        
        if (usage.Quantity__c != 0 && usage != null)
            usageSet.add(usage);
    }  

    
    private Usage__c createUsageForCC (Zuora__Subscription__c sub, Integer quantity, String uom, Date usageDate, String usageType, String pubCode) { 

        spcIdentifier = generateSpcIndentifierKey(sub.Id, subIdToUomTypeMap.get(sub.Id) + ' ' + uom , pubCode);
        year = referenceDate.year(); 
        month = referenceDate.month(); 
        Date endDate;
        
        usage = new Usage__c();
        
        if (spcIdentifierToSpcMap.containsKey(spcIdentifier)) {
            spc = spcIdentifierToSpcMap.get(spcIdentifier);
            
            if (sub.Zuora__TermSettingType__c != 'EVERGREEN') {
                if (sub.Zuora__SubscriptionEndDate__c.monthsBetween(referenceDate) == 0 || sub.Grace_Period_Subscription__c != null) { 
                    endDate = sub.Zuora__SubscriptionEndDate__c;
                } else {
                    endDate = date.newInstance(year, month, date.daysInMonth(year, month));
                }
            }
            else
                endDate = date.newInstance(year, month, date.daysInMonth(year, month));
            
            usage.Account_Id__c = destinationAccountNumber;
            usage.Subscription_Id__c = sub.Name;
            usage.End_Date__c = endDate;
            usage.Status__c = USAGE_STATUS;
            usage.UOM__c = spc.Zuora__UOM__c;
            usage.Rate_Plan_Charge_Id__c = spc.Zuora__ChargeNumber__c;                 
            usage.Publication_Code__c = spc.PublicationCode__c;
            usage.Quantity__c = quantity;
            usage.StopType__c = StopType;
            usage.Usage_Type__c = usageType;            
            usage.Start_Date__c = usageDate;
            usage.Case__c = null;	// Start/End D-4470 05Apr16 JohnD
           
        }
        return usage;
    }
    
    private static string generateSpcIndentifierKey(string subscriptionId, string uom, String pubCode) {
        return subscriptionId + ' ' + uom + ' ' + pubCode;
    }
}