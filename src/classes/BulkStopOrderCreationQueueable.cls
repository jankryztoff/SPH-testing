/*
* Class Name: BulkStopOrderCreationQueueable
* @Author: John Dacutan
* Date: 6 April 2015
* Requirement/Project Name: CRSM Project
* @Description: UD-2549 Retry Mechanism for BulkStopOrderCreationHandler
*/
public with sharing class BulkStopOrderCreationQueueable implements Queueable {
    
    List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>(); //START-END PD-0506 6/24/2016 Added by J.Sarion
    set<id> subscriptionIdSet = new set<id>();
    map<id, id> subscriptionId_caseId = new map<id, id>();
    
    //START PD-0506 6/24/2016 Added by J.Sarion - Changed param to list of subscription
    public BulkStopOrderCreationQueueable(List<Zuora__Subscription__c> subList) {
        this.subList = subList;
    }
    //END PD-0506 6/24/2016 Added by J.Sarion - Changed param to list of subscription
    
    public void execute(QueueableContext qc) {

        //START UD-2549 4/10/2016 Added by J.Sarion - update query
        // Start D-4825 20Jun16 JohnD - added Zuora__Status__c fiedl
        //START PD-0506 6/24/2016 Added by J.Sarion - commented out
        /*
        list<Zuora__Subscription__c> subscriptionList = [SELECT Id, Name, Zuora__Account__c, Product_Code__c, Main_Package_1__c, Zuora__Zuora_Id__c, Billing_Type__c, Delivered_By__c, Zuora__Status__c, 
                                Zuora__SubscriptionEndDate__c, Main_Package_1__r.Package_Type__c, Subscriber_Contact__c, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__DefaultPaymentMethod__c, Subscription_Type_1__c, Order_Line_Item_Number_1__c, Zuora__SubscriptionStartDate__c FROM Zuora__Subscription__c WHERE Id IN :subscriptionIdSet];
        */
        //END PD-0506 6/24/2016 Added by J.Sarion - commented out
        // End D-4825 20Jun16 JohnD - added Zuora__Status__c fiedl
        //END UD-2549 4/10/2016 Added by J.Sarion - update query

        if (!subList.isEmpty()) {
                
            BulkStopOrderCreationHandler bulkStop = new BulkStopOrderCreationHandler();
            subscriptionId_caseId = bulkStop.createRelatedRecords(subList);
        }
    }
}
//START UD-2549 4/6/2016 Added by J.Dacutan