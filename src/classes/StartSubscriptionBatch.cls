/*
 * Class Name: StartSubscriptionBatch
 * @author: Kevin H. Evasco
 * Date: 10/16/2014
 * Project/Requirement: SPH Integration
 * @description This class performs cancellation of subscriptions to zuora.
 * 
 * History: 01/29/2015 Kevin Evasco Created class to perform bulk start subscription
 */


global class StartSubscriptionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    List<Order__c> ordersForStartSubscription = new List<Order__c>();
    Set<String> newOrderIdSet_str = new Set<String>();
    Set<Id> newOrderIdSet_id = new Set<Id>();
    Set<String> allQuoteIds = new Set<String>();
    
    public StartSubscriptionBatch (Set<String> newOrderIdSet_str)
    {
        this.newOrderIdSet_str = newOrderIdSet_str;
        for(String str : newOrderIdSet_str)
        {
            this.newOrderIdSet_id.add((Id) str);
        }
    }
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {           
        ordersForStartSubscription = ChangeAddressService.getOrders(newOrderIdSet_str);
        createCase caseCreator = new createCase();
        caseCreator.createCase2(ordersForStartSubscription,true);
    
        String query = 'SELECT Id, Billing_Contact__c, Billing_Contact__r.Id, Recipient_Contact__r.Id, Billing_Contact__r.Address__r.Country_Name__c, Recipient_Contact__r.Address__r.Country__r.Code__c, Recipient_Contact__r.Address__c, Account__c, Remarks__c, Acquisition_Type__c, Recipient_Contact__c, Base_Subscription__c, Send_to_Retention__c, Eligible_for_Retention__c, Stop_Request_Date__c, Earliest_Stop_Date__c, Parent_Case__c FROM Order__c WHERE Id IN :newOrderIdSet_id';
    
        Renewal_Quote_Handler_Bulk bulkQuoteHandler = new Renewal_Quote_Handler_Bulk();
        allQuoteIds.addAll(bulkQuoteHandler.bulkQuoteCreation(newOrderIdSet_id,GlobalVariableClass.ESHOP_ORIGIN));
            
        
        return Database.getQueryLocator(query);
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<Order__c> scope)
    {        
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {                 
        SendQuotesToZuoraMultipleAccount batchInstance = new SendQuotesToZuoraMultipleAccount(newOrderIdSet_id,allQuoteIds,GlobalVariableClass.ESHOP_ORIGIN);
        Database.executeBatch(batchInstance);
    }
}