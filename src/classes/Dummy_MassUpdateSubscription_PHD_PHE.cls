global class Dummy_MassUpdateSubscription_PHD_PHE implements Database.Batchable<sObject> {    
   
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Ph_d__c, Ph_e__c FROM Zuora__Subscription__c WHERE Ph_d__c = false OR Ph_e__c = false]);         
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope) { 
        for(Zuora__Subscription__c subscriptionElement : scope) {
            subscriptionElement.Ph_d__c = true;
            subscriptionElement.Ph_e__c = true;
        }
        
        Database.update(scope, false);
    } 
 
    global void finish(Database.BatchableContext BC) {
    }
}