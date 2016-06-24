/**
* Class Name: <SM_ChangeOfSubStartStopProcess>
* @authors: <JTeves>
* Date: <18-June-2015>
* Requirement/Project Name: <SPH>
* @description: 
* Allow Old SUbscriptions to be cancelled/invoice first before creating the new Subscription
* This class is called from InvoiceProcessForStopSubscription
* UD-3676 01/21/16 RReyes - bulkify class
*/

public class SM_ChangeOfSubStartStopProcess implements Queueable, Database.AllowsCallouts {
    //START UD-3676 01/21/16 RReyes - bulkify
    private Id orderId;
    private Set<Id> orderIdSet;
    final String COS = GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION;
    /*public SM_ChangeOfSubStartStopProcess(Id orderId) {
        this.orderId = orderId;
    }*/
     public SM_ChangeOfSubStartStopProcess(Set<Id> orderIdSet) {
        this.orderIdSet = orderIdSet;
    }
    //END UD-3676 01/21/16 RReyes - bulkify
    public void execute(QueueableContext context) {
        Decimal creditBalance = 0;
        Id billingAcctIdNewSub;
        
        //query Order of the new Subscription produced via COS
        //START UD-3676 RReyes 01/21/16 - bulkify
        string queryStr = SM_SubscriptionHelper.generateOrderSoqlStr();
        //queryStr += ' where Id = \'' + orderId + '\'';
        String orderParams = '';
        for(String ordId : orderIdSet)
            orderParams += ' OR ID=\'' + ordId + '\'';
        orderParams = orderParams.substring(4);
        queryStr += ' WHERE ' + orderParams;
        /*Order__c orderRec = (Order__c) database.query(queryStr);
        String billingAcctIdOldSub = orderRec.Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c;
        */
        List<Order__c> orderList = (List<Order__c>) database.query(queryStr);
        Map<Id, String> mapOrderToBA = new Map<Id, String>();
        for(Order__c orderRec : orderList){
            //send quotes to Z-billing for the new sub
            system.debug(':::COS' + ' ' + COS);
            Subscription_Handler subHandler = new Subscription_Handler();
            subHandler.origin = 'Change of Subscription';
            subHandler.CreateQuotes(orderRec,COS);
            if(orderRec.Billing_Type__c != GlobalVariableClass.BILLING_TYPE_FULL_PRE){
                if(orderRec.Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c != null){
                    if(!mapOrderToBA.containsKey(orderRec.Id)){
                        mapOrderToBA.put(orderRec.Id,orderRec.Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c);
                    }
                }
            }
        
        }
        //END UD-3676 RReyes 01/21/16 - bulkify
        //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates - comment-out code
        //TO-DO: transfer billing account balance from OLD to NEW Billing Account if there is a change of Billing ACC        
        /*if(orderRec.Billing_Type__c != null)
        {
            Account accToUpd = new Account(Id = orderRec.Account__c);
            accToUpd.Billing_Type__c = SM_SubscriptionHelper.getBillingTypeForBA(orderRec.Billing_Type__c);
            UPDATE accToUpd;
        } */
        //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
    //----Create refund to zero-out credit balance of OLD Billing Acc
    //----Create Payment to move the amount from OLD to NEW Billing Account
    //Id jobId = System.enqueueJob(new SM_COSCreditBalanceTransfer(orderId, billingAcctIdOldSub));
        //START UD-2249 9/28/15 AddedBy FrancisBenzon : removed creation of payment and refund. already catered by UD-2501 in InvoicePaymentQueueableClass
    //START D-3758 10/16/15 AddedBy FrancisBenzon : only cater changes from fpp to recurring. 
        //START UD-3676 01/21/16 RReyes - bulkify       
        //if(orderRec.Billing_Type__c != GlobalVariableClass.BILLING_TYPE_FULL_PRE)
        //{
        if(mapOrderToBA.size() > 0){
            SM_COSCreditBalanceTransfer.processBalanceTransfer(mapOrderToBA);
        }
        //}
        //END UD-3676 01/21/16 RReyes - bulkify     
    //END D-3758 10/16/15 AddedBy FrancisBenzon : only cater changes from fpp to recurring.     
        //END UD-2249 9/28/15 AddedBy FrancisBenzon : removed creation of payment and refund. already catered by UD-2501 in InvoicePaymentQueueableClass
            
    }
}