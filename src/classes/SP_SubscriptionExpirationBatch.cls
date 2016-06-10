/**
 * Class Name: SP_SubscriptionExpirationBatch
 * @author: James Azana
 * Date: 03/27/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Class that changes the Subscription Status to Expired when the Current Date is equal to the Subscription End Date
 */
 
 global class SP_SubscriptionExpirationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
 
    global Batch_Configuration_Settings__c batchSettings;
    
    
    /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bc- predefined parameter 
    * @return list of objects from Subscription Object
    */     
   
    global Database.QueryLocator start(Database.BatchableContext bc) {
    
        String query = 'SELECT Id, Zuora__Status__c, Zuora__SubscriptionEndDate__c From Zuora__Subscription__c Where Zuora__Status__c = \'Active\' AND Zuora__SubscriptionEndDate__c <= today';
        if (Test.isRunningTest()){
            query += ' Limit 200';
        }
        return Database.getQueryLocator(query);
    }
 
     /* @description Executes the business logic and creates Usage object
     * 
     * @param bc- predefined parameter 
     * @param allScopes - a list of sObjects from the initial database query
     * @return void
     */    
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope) {
        if(scope.size()>0 && scope<>null){
            for(integer x=0; x < scope.size(); x++){
                scope[x].Zuora__Status__c = 'Expired';
            }
            Database.update(scope, false);
            //update scope;
        }
    }
 
    global void finish(Database.BatchableContext BC) {
    
    } 
}