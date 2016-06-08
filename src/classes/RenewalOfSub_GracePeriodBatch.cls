global class RenewalOfSub_GracePeriodBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
    Date twoDaysBefore = Date.Today().addDays(2);
  
        String query = 'SELECT Id, Name, Zuora__SubscriptionEndDate__c, Zuora__SubscriptionStartDate__c, Grace_Period__c '+
                       'FROM  Zuora__Subscription__c WHERE Zuora__SubscriptionEndDate__c = :twoDaysBefore AND Grace_Period__c != 0';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope){    
    List<Zuora__Subscription__c> gracePeriodSubs = new List<Zuora__Subscription__c>();
    String graceSubStatus = 'Not Renewed Yet';
    
    for(Zuora__Subscription__c zGraceSub : scope) {
        Integer gracePeriod = integer.valueOf(zGraceSub.Grace_Period__c);        
        Zuora__Subscription__c zCreateGraceSub = zGraceSub.clone(false, true, true, false);
        zCreateGraceSub.Zuora__Status__c = graceSubStatus;
        zCreateGraceSub.Grace_Period_Subscription__c = zGraceSub.Id;
        zCreateGraceSub.Zuora__SubscriptionStartDate__c = zGraceSub.Zuora__SubscriptionEndDate__c.addDays(1);
        zCreateGraceSub.Zuora__SubscriptionEndDate__c = zGraceSub.Zuora__SubscriptionEndDate__c.addDays(gracePeriod);
        gracePeriodSubs.add(zCreateGraceSub);
    }
    insert gracePeriodSubs;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}