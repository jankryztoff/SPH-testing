/*
 * Class Name: CancelSubscriptionBatch
 * @author: Kevin H. Evasco
 * Date: 10/16/2014
 * Project/Requirement: SPH Integration
 * @description This class performs cancellation of subscriptions to zuora.
 * 
 * History: 09/12/2014 Kevin Evasco Created Apex Batchable
 * History: 01/29/2015 D-1776 and D-1777 Kevin Evasco Reconstructed class to perform both case creation and bulkified stop subscription.
 * History: 01/29/2015 D-2534 Kevin Evasco Create Order for Stop Subscription, utilize Subscription Cancellation Helper
 */


global class CancelSubscriptionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    //START D-4076 12-10-2015 added by Jason A. for code review
    List<Order__c> ordersForStopSubscription = new List<Order__c>(); 
    Set<String> orderIdForStopSubscription = new Set<String>(); 
    Set<String> subscriptionIdSetForCancellation = new Set<String>();
    Date stopDate;
    ID accountId;
    Set<String> zAccountId = new Set<String>(); 
    //END D-4076 12-10-2015 added by Jason A. for code review
    public CancelSubscriptionBatch (Set<String> orderIdForStopSubscription, Set<String> subscriptionIdSetForCancellation, Date stopDate, Set<String> zAccountId, Id accountId)
    {
        this.orderIdForStopSubscription = orderIdForStopSubscription;
        this.subscriptionIdSetForCancellation = subscriptionIdSetForCancellation;
        this.stopDate = stopDate; 
        this.zAccountId = zAccountId;
        this.accountId = accountId;
    }
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {           
        //START 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - No stop case creation for ESHOP
        //ordersForStopSubscription = createOrdersForStopSubscription(subscriptionIdSetForCancellation, stopDate); // START/END 03/24/2015 MD-59 Kevin Evasco - Added stopDate parameter
        // START/END 01/29/2015 D-2534 Kevin Evasco Create Order for Stop Subscription, utilize Subscription Cancellation Helper
        
        //createCase caseCreator = new createCase();
        //caseCreator.createCaseForStopSubscription(ordersForStopSubscription,true);
        //END 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - No stop case creation for ESHOP
        
        String query = 'SELECT Id, Name, Zuora__Zuora_Id__c, Order_Number__c, Order_Line_Item_Number__c, Zuora__CustomerAccount__r.Id, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Zuora__Account__r.Id, Contact__r.Id, Recipient_Contact__r.Id, Recipient_Contact__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :subscriptionIdSetForCancellation';
     
        return Database.getQueryLocator(query);
    }
    
    /* @description Cancels the subscription via Zuora Callout
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope)
    {   
        // START 01/29/2015 D-2534 Kevin Evasco Create Order for Stop Subscription, utilize Subscription Cancellation Helper
        Map<Id, Date> subscriptionId_effectiveDate = new Map<Id, Date>();
        for(Zuora__Subscription__c batchRecord : scope)
        {           
            subscriptionId_effectiveDate.put(batchRecord.Id,stopDate);
        }
        SM_SubscriptionCancellationHelper.cancelSubscriptions(subscriptionId_effectiveDate,'ESHOP Change of Subscription');  //START/END 05/15/2015 Kevin Evasco - ESHOP Hotfix   
        // END 01/29/2015 D-2534 Kevin Evasco Create Order for Stop Subscription, utilize Subscription Cancellation Helper
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    { 
        ZuoraOnDemandSyncBatch zuoraOnDemanSyncBatch = new ZuoraOnDemandSyncBatch(zAccountId, accountId);
        Database.executeBatch(zuoraOnDemanSyncBatch);
    }
    
    // START 01/29/2015 D-2534 Kevin Evasco Create Order for Stop Subscription, utilize Subscription Cancellation Helper
    /*
     * @description Creates new order for stop subscription
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
     
     // Start 10/11/2015  by Ana Fe Dumangas to comment out unused method

 /*   private static List<Order__c> createOrdersForStopSubscription(Set<String> subscriptionIdSetForCancellation, Date stopDate) // START/END 03/24/2015 MD-59 Kevin Evasco - Added stopDate parameter
    {   
        List<Zuora__Subscription__c> subscriptionList = [SELECT Id, Main_Package_1__r.Billing_Type__c, Main_Package_1__r.Package_Type__c, Zuora__Account__c, Order_Line_Item_Number__c, Order_Number__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :subscriptionIdSetForCancellation];   
        
        Set<Id> orderLineItemIdSet = new Set<Id>();
        Map<Id,Id> orderLineItemId_subscriptionId_map = new Map<Id,Id>();
        List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
        List<Order_Line_Item__c> newOrderLineItemList = new List<Order_Line_Item__c>();
        List<Order__c> orderList = new List<Order__c>();
        
        Order__c order = new Order__c();
        order.account__c = subscriptionList[0].Zuora__Account__c;
        order.status__c = GlobalVariableClass.STATUS_NEW;
        order.case_record_type__c = 'Stop Subscription';
        order.category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
        order.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;
        order.credit_balance__c = 0;
        order.delivery_charge__c = 0;
        order.monthly_delivery_charge_for_full_payment__c = 0;
        order.Order_Type__c = 'Stop';
        orderList.add(order);
        insert orderList;       
        
        for(Zuora__Subscription__c subscription : subscriptionList)
        {
            if(subscription.Order_Line_Item_Number__c != null){
                Id orderLineItemId = (Id)subscription.Order_Line_Item_Number__c;
                orderLineItemIdSet.add(orderLineItemId);
                orderLineItemId_subscriptionId_map.put(orderLineItemId,subscription.Id);
            }
        }
        
        orderLineItemList = [SELECT Id FROM Order_Line_Item__c WHERE Id IN :orderLineItemIdSet];
        
        for(Order_Line_Item__c orderLineItem : orderLineItemList)
        {
            Order_Line_Item__c newOrderLineItem = (Order_Line_Item__c) SObjectAllFieldCloner.cloneObject(orderLineItem, orderLineItem.getsObjectType());
            newOrderLineItem.Order__c = order.Id;
            newOrderLineItem.Subscription__c = orderLineItemId_subscriptionId_map.get(orderLineItem.Id);
            newOrderLineItem.Start_Date__c = stopDate; // START/END 03/24/2015 MD-59 Kevin Evasco - Used stopDate parameter
            
            
            newOrderLineItem.Main_Package_Billing_Type__c = subscriptionList[0].Main_Package_1__r.Billing_Type__c;
            if(newOrderLineItem.Main_Package_Billing_Type__c == null)
                newOrderLineItem.Main_Package_Billing_Type__c = 'null';
                
            newOrderLineItem.Main_Package_Type__c= subscriptionList[0].Main_Package_1__r.Package_Type__c;
            if(newOrderLineItem.Main_Package_Type__c== null)
                newOrderLineItem.Main_Package_Type__c= 'null';
            
            newOrderLineItemList.add(newOrderLineItem);
        }   
        
        Database.insert(newOrderLineItemList);
        
        return orderList;
    }*/
    // END 01/29/2015 D-2534 Kevin Evasco Create Order for Stop Subscription, utilize Subscription Cancellation Helper
    
    // End 10/11/2015  by Ana Fe Dumangas to comment out unused method

}