/*
* Class Name: BulkStopOrderCreationQueueable
* @Author: John Dacutan
* Date: 6 April 2015
* Requirement/Project Name: CRSM Project
* @Description: UD-2549 Retry Mechanism for BulkStopOrderCreationHandler
*/
public with sharing class BulkStopOrderCreationQueueable implements Queueable {
    
    set<id> subscriptionIdSet = new set<id>();
    map<id, id> subscriptionId_caseId = new map<id, id>();
    
    public BulkStopOrderCreationQueueable(set<id> subscriptionIdSetParam) {
        this.subscriptionIdSet = subscriptionIdSetParam;
    }
    
    public void execute(QueueableContext qc) {

        //START UD-2549 4/10/2016 Added by J.Sarion - update query
        list<Zuora__Subscription__c> subscriptionList = [SELECT Id, Name, Zuora__Account__c, Product_Code__c, Main_Package_1__c, Zuora__Zuora_Id__c, Billing_Type__c, Delivered_By__c, 
                                Zuora__SubscriptionEndDate__c, Main_Package_1__r.Package_Type__c, Subscriber_Contact__c, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__DefaultPaymentMethod__c, Subscription_Type_1__c, Order_Line_Item_Number_1__c, Zuora__SubscriptionStartDate__c FROM Zuora__Subscription__c WHERE Id IN :subscriptionIdSet];
        //END UD-2549 4/10/2016 Added by J.Sarion - update query

        if (!subscriptionList.isEmpty()) {
                
            BulkStopOrderCreationHandler bulkStop = new BulkStopOrderCreationHandler();
            subscriptionId_caseId = bulkStop.createRelatedRecords(subscriptionList);
        }
    }
}
//START UD-2549 4/6/2016 Added by J.Dacutan