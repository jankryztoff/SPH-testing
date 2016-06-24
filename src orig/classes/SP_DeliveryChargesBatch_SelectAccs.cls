/**
 * Class Name: SP_DeliveryChargesBatch
 * @author: Manolo Valena/Jayson Sarion
 * Date: 
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Process to handle delivery charges for Temp Stop Subscription
 * History: UD-2176 Added by M.Valena && J.Sarion 08/05/2015 - Recode class based on the correct implementation of Del Charge usage creation
 */

global class SP_DeliveryChargesBatch_SelectAccs implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String mainQuery;
    public Integer durationInDays;
    public String UOM;
    public Date startDate;
    public Date endDate;
    public ID thisAccId;
    
    Set<Id> subRecipientAddressIdSet = new Set<Id>();
    Set<String> billingAccountIdSet = new Set<String>();
    Set<Id> allPublicationSubscriptionIdSet = new Set<Id>();
    List<Zuora__Subscription__c> allPublicationSubscriptionList = new List<Zuora__Subscription__c>();
    Set<String> sameRecipientAddressSet = new Set<String>();
    Map<Id, Date> startDateMap = new Map<Id, Date>();
    Map<Id, Date> endDateMap = new Map<Id, Date>();
    List<Id> failedRecords = new List<Id>();
    
    Map<Id, List<Subscription_Temp_Stop__c>> recipientContactToSubscriptionsMap = new Map<Id, List<Subscription_Temp_Stop__c>>();
    Map<Id, List<Subscription_Temp_Stop__c>> recipientContactToSubscriptionsMap2 = new Map<Id, List<Subscription_Temp_Stop__c>>();
    Set<Id> recipientContactSet = new Set<Id>();
    Set<Id> stcIdSet = new Set<Id>();
    
    Map<Id, Zuora__SubscriptionProductCharge__c> recipientContactToSPCMap = new Map<Id, Zuora__SubscriptionProductCharge__c>();
    Map<Id, Set<Id>> recipientToTotalSubs = new Map<Id, Set<Id>>();
    Map<Id, List<Zuora__Subscription__c>> recipientToDeliverySubs = new Map<Id, List<Zuora__Subscription__c>>();
    Map<Id, Zuora__Subscription__c> contactToHighestDelSubMap = new Map<Id, Zuora__Subscription__c>();
    Map<Id, Set<Id>> recipientToTotalSubsFromTStop = new Map<Id, Set<Id>>();
    Map<Id, Zuora__SubscriptionProductCharge__c> subIdToSpcMap = new Map<Id, Zuora__SubscriptionProductCharge__c>();
    Map<Id, Date> subscriptionIdToEndDate = new Map<Id, Date>();
  
    private final static Date referenceDate = UsageHelper.getUsageReferenceDate(); 
    
    Boolean selectAccountsFlag = false; 
    Set<String> accountNumberSet;
    
    global SP_DeliveryChargesBatch_SelectAccs(Set<String> accountNumberSet){
        this.selectAccountsFlag = true;
        this.accountNumberSet = accountNumberSet;
    }       
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String onGoing = 'On-going';
        String activeStat = 'Active';
        String subTypePub = 'Publication';
        String cancelled = 'Cancelled';
        
        String query = 'SELECT Id, Subscription__c, Subscription__r.Recipient_Contact__r.Address__c, '+
                        'Subscription__r.Zuora__CustomerAccount__c, Temp_Stop__c,  '+
                        'Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Temp_Stop_Status__c '+ 
                        'FROM Subscription_Temp_Stop__c '+
                        'WHERE Temp_Stop__r.Temp_Stop_Status__c !=: cancelled '+ 
                        'AND Subscription__r.Subscription_Type_1__c =: subTypePub '+ 
                        'AND Subscription__r.Zuora__Status__c =: activeStat ';

        if(referenceDate != null) {
            Date startDate = referenceDate.toStartOfMonth();
            Date endDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
            query += 'AND Temp_Stop__r.Restart_Date__c >=: startDate AND Temp_Stop__r.Restart_Date__c <=: endDate';
        } else {        
            query += 'AND Temp_Stop__r.Restart_Date__c >= THIS_MONTH AND Temp_Stop__r.Restart_Date__c <= THIS_MONTH';
        }
        
        if(selectAccountsFlag) {
            query += ' AND Subscription__r.Zuora__Account__r.AccountNumber IN :accountNumberSet';
        }
        
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List<Subscription_Temp_Stop__c> scope) {
        
        list<Usage__c> usageList = new list<Usage__c>();
        List<Zuora__SubscriptionProductCharge__c> delSubSPCList = new List<Zuora__SubscriptionProductCharge__c>();
        Usage__c usage;
        set<Id> usageIdSet = new set<Id>();
        Set<Id> delSubIdSet = new Set<Id>();
        
        for(Subscription_Temp_Stop__c subTempStop : scope)
        {
            stcIdSet.add(subTempStop.Id);
            if(subTempStop.Subscription__r.Recipient_Contact__c != null) {
                recipientContactSet.add(subTempStop.Subscription__r.Recipient_Contact__c);
            }
        }
        
        if(recipientContactSet.size() > 0) {
            for(Subscription_Temp_Stop__c sTempStopRec : [SELECT Id, Subscription__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c,
                                                          Subscription__r.Recipient_Contact__c, Subscription__r.Zuora__SubscriptionEndDate__c
                                                          FROM Subscription_Temp_Stop__c
                                                          WHERE Subscription__r.Recipient_Contact__c IN : recipientContactSet
                                                          AND Temp_Stop__r.Temp_Stop_Status__c !=: GlobalVariableClass.STATUS_CANCELLED]) {
                if(sTempStopRec.Temp_Stop__r.Restart_Date__c >= referenceDate.toStartOfMonth()) {
                    if(recipientContactToSubscriptionsMap.containsKey(sTempStopRec.Subscription__r.Recipient_Contact__c)) {
                        recipientContactToSubscriptionsMap.get(sTempStopRec.Subscription__r.Recipient_Contact__c).add(sTempStopRec);
                    }
                    else {
                        recipientContactToSubscriptionsMap.put(sTempStopRec.Subscription__r.Recipient_Contact__c, new List<Subscription_Temp_Stop__c>{sTempStopRec});
                    }
                    
                    if(recipientToTotalSubsFromTStop.containsKey(sTempStopRec.Subscription__r.Recipient_Contact__c)) {
                        recipientToTotalSubsFromTStop.get(sTempStopRec.Subscription__r.Recipient_Contact__c).add(sTempStopRec.Subscription__c);
                    }
                    else {
                        recipientToTotalSubsFromTStop.put(sTempStopRec.Subscription__r.Recipient_Contact__c, new Set<Id>{sTempStopRec.Subscription__c});
                    }
                }
                else {
                    if(recipientContactToSubscriptionsMap2.containsKey(sTempStopRec.Subscription__r.Recipient_Contact__c)) {
                        recipientContactToSubscriptionsMap2.get(sTempStopRec.Subscription__r.Recipient_Contact__c).add(sTempStopRec);
                    }
                    else {
                        recipientContactToSubscriptionsMap2.put(sTempStopRec.Subscription__r.Recipient_Contact__c, new List<Subscription_Temp_Stop__c>{sTempStopRec});
                    }
                    subscriptionIdToEndDate.put(sTempStopRec.Subscription__c, sTempStopRec.Subscription__r.Zuora__SubscriptionEndDate__c);
                }
            }
            
            for(Zuora__Subscription__c zsRec : [SELECT Id, Name, Recipient_Contact__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Subscription_Type_1__c, Billing_Type__c, Zuora__SubscriptionStartDate__c,
                                                       Contract_End_Date_1__c, Zuora__SubscriptionEndDate__c
                                                FROM Zuora__Subscription__c 
                                                WHERE Recipient_Contact__c IN : recipientContactSet 
                                                AND Zuora__Status__c =: GlobalVariableClass.ZUORA_STATUS_ACTIVE 
                                                AND (Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION OR Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY)]) {
                if(zsRec.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION) {
                    if(recipientToTotalSubs.containsKey(zsRec.Recipient_Contact__c)) {
                        recipientToTotalSubs.get(zsRec.Recipient_Contact__c).add(zsRec.Id);
                    }
                    else {
                        recipientToTotalSubs.put(zsRec.Recipient_Contact__c, new Set<Id>{zsRec.Id});
                    }
                }
                else {
                    delSubIdSet.add(zsRec.Id);
                    if(recipientToDeliverySubs.containsKey(zsRec.Recipient_Contact__c)) {
                        recipientToDeliverySubs.get(zsRec.Recipient_Contact__c).add(zsRec);
                    }
                    else {
                        recipientToDeliverySubs.put(zsRec.Recipient_Contact__c, new List<Zuora__Subscription__c>{zsRec});
                    }
                }
            }
        }
        
        if(!delSubIdSet.isEmpty()){
            delSubSPCList = [SELECT Id, Zuora__ChargeNumber__c, Zuora__ProductSKU__c, Zuora__UOM__c, Zuora__Subscription__c, PublicationCode__c 
                             FROM Zuora__SubscriptionProductCharge__c 
                             WHERE Zuora__Subscription__c IN : delSubIdSet 
                             AND Zuora__UOM__c LIKE '%Credit%'];
            
            for(Zuora__SubscriptionProductCharge__c spc : delSubSPCList){
                subIdToSpcMap.put(spc.Zuora__Subscription__c, spc);
            }
        }
        
        for(Id recCon : recipientContactToSubscriptionsMap.keySet()) {
            if(recipientContactToSubscriptionsMap.get(recCon).size() > 0) {
                if(recipientToTotalSubs.get(recCon).size() == recipientToTotalSubsFromTStop.get(recCon).size()) {
                    Map<Date, Integer> stcToMonthsMap = new Map<Date, Integer>();
                    for(Subscription_Temp_Stop__c stc : recipientContactToSubscriptionsMap.get(recCon)) {
                        Integer numbOfMonths = 0;
                        if(stc.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(stc.Temp_Stop__r.Restart_Date__c) > 1) {    
                            numbOfMonths = stc.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(stc.Temp_Stop__r.Restart_Date__c) - 1;
                            
                            Integer count = numbOfMonths;
                            while(count > 0) {
                                if(stcToMonthsMap.containsKey(stc.Temp_Stop__r.Temp_Stop_Date__c.addMonths(count).toStartOfMonth())) {
                                    stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c.addMonths(count).toStartOfMonth(), stcToMonthsMap.get(stc.Temp_Stop__r.Temp_Stop_Date__c.addMonths(count).toStartOfMonth()) + 1);
                                }
                                else {
                                    stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c.addMonths(count).toStartOfMonth(), 1);
                                }
                                count--;
                            }
                            
                            if(stc.Temp_Stop__r.Temp_Stop_Date__c == stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth()) {
                                if(stcToMonthsMap.containsKey(stc.Temp_Stop__r.Temp_Stop_Date__c)) {
                                    stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c, stcToMonthsMap.get(stc.Temp_Stop__r.Temp_Stop_Date__c) + 1);
                                }
                                else {
                                    stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c, 1);
                                }
                            }
                        }
                        else if(stc.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(stc.Temp_Stop__r.Restart_Date__c) == 1) {
                            if(stc.Temp_Stop__r.Temp_Stop_Date__c == stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth()) {
                                if(stcToMonthsMap.containsKey(stc.Temp_Stop__r.Temp_Stop_Date__c)) {
                                    stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c, stcToMonthsMap.get(stc.Temp_Stop__r.Temp_Stop_Date__c) + 1);
                                }
                                else {
                                    stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c, 1);
                                }
                            }
                        }               
                    }
                    
                    Integer usageCount = 0;
                    for(Date uniqueDate : stcToMonthsMap.keySet()) {
                        if(stcToMonthsMap.get(uniqueDate) > 0) {
                            if(recipientContactToSubscriptionsMap2.containsKey(recCon)) {
                                Integer s = recipientContactToSubscriptionsMap2.get(recCon).size();
                                for(Subscription_Temp_Stop__c xx : recipientContactToSubscriptionsMap2.get(recCon)) {
                                    if(uniqueDate > subscriptionIdToEndDate.get(xx.Subscription__c).toStartofMonth()) {
                                        s--;
                                    }
                                }
                                if(s == 0) {
                                    usageCount++;
                                }
                            }
                            else{
                                if(stcToMonthsMap.get(uniqueDate) == recipientContactToSubscriptionsMap.get(recCon).size()){
                                    usageCount++;
                                }
                            }
                        }
                    }
                    
                    if(recipientToDeliverySubs.containsKey(recCon)) {
                        for(Zuora__Subscription__c dcSub : recipientToDeliverySubs.get(recCon)) {
                            //map contact to the highest sub in hierarchy
                            if(!contactToHighestDelSubMap.containsKey(recCon)) {
                                contactToHighestDelSubMap.put(recCon, dcSub);
                            }
                            else if(DeliveryChargeHelper.isHigherInHierarchy(dcSub, contactToHighestDelSubMap.get(recCon))) {
                                contactToHighestDelSubMap.put(recCon, dcSub);
                            }
                        }
                    }
                    
                    if(usageCount > 0 && contactToHighestDelSubMap.containsKey(recCon)) {
                        usageList.add(createUsage(usageCount, contactToHighestDelSubMap.get(recCon)));
                    }
                }
            }
        }
        UsageHelper.loadUniqueUsages(usageList, false);
    }
        

    global void finish(Database.BatchableContext BC) {
        BatchJobHelper.updateJobStatus(BC.getJobId());
    }
    
    public Usage__c createUsage(Integer qty, Zuora__Subscription__c sub) {
        Usage__c usage = new Usage__c();
        usage.Status__c = GlobalVariableClass.STATUS_NEW;
        usage.Quantity__c = qty;
        usage.Account_Id__c = sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
        usage.Subscription_Id__c = sub.Name;
        usage.UOM__c = (subIdToSpcMap.containsKey(sub.Id) ? subIdToSpcMap.get(sub.Id).Zuora__UOM__c : GlobalVariableClass.EMPTYSTR);
        usage.Rate_Plan_Charge_Id__c = (subIdToSpcMap.containsKey(sub.Id) ? subIdToSpcMap.get(sub.Id).Zuora__ChargeNumber__c : GlobalVariableClass.EMPTYSTR); 
        usage.Publication_Code__c = (subIdToSpcMap.containsKey(sub.Id) ? subIdToSpcMap.get(sub.Id).PublicationCode__c : GlobalVariableClass.EMPTYSTR); 
        usage.Start_Date__c = referenceDate.toStartOfMonth();
        usage.Usage_Type__c = UsageHelper.USAGE_TYPE_DELIVERY_CHARGE;

        return usage;
    }
}