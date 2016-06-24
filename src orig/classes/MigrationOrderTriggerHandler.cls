/**
* Class Name: <MigrationOrderTriggerHandler>
* @authors: <Christopher Camilon>
* Date: <6/25/2015>
* Requirement/Project Name: <SPH>
* @description <Validate>
*/
global class MigrationOrderTriggerHandler{

    public void doBeforeInsert(List<Order__c> lstNewOrder)
    {
    
        List<Order__c> updatenewOrderList = new List<Order__c>();       
        for(Order__c newOrder : lstNewOrder)
        {
        
            if(newOrder.Order_Legacy_Id__c != null || newOrder.Order_Legacy_Id__c != ''){
                
                //START : D-3260 7/23/2015 K. Tan Update Order Legacy checkbox to true once record is created
                newOrder.isOrderLegacy__c = True;
                //END : D-3260 7/23/2015 K. Tan Update Order Legacy checkbox to true once record is created
            
                updatenewOrderList.add(newOrder);
            
            }
        
        }
        
        newOrderLstUpdate(updatenewOrderList);
        
    }
    
    public void doBeforeUpdate(List<Order__c> lstNewOrders, Map<Id, Order__c> mapNewOrders, List<Order__c> lstOldOrders, Map<Id, Order__c> mapOldOrders)
    {
        List<Order__c> updateOrderList = new List<Order__c>();
        for(Order__c newOrder : lstNewOrders)
        {
        
            if(mapOldOrders.get(newOrder.Id) != null )
            {
            
                 if(newOrder.Order_Legacy_Id__c != null || newOrder.Order_Legacy_Id__c != '')
                 {
                    //START : D-3260 7/23/2015 K. Tan Update Order Legacy checkbox to true once record is created
                    newOrder.isOrderLegacy__c = True;
                    //END : D-3260 7/23/2015 K. Tan Update Order Legacy checkbox to true once record is created           
                     updateOrderList.add(newOrder);
                     
                 }    
            
            }            
         
        }
        
        if(!updateOrderList.isEmpty())
            updOrderListupdate(updateOrderList);
            updateOrderBaList(updateOrderList);
            System.Debug('MANOLOMANOLO76 updateOrderList: ' + updateOrderList);
    }
    
    private void newOrderLstUpdate(List<Order__c> newOrderListUpdate)
    {
    
        for(Order__c newOrder : newOrderListUpdate)
        {
            newOrder.Billing_Account_Creation_Mode__c = 'Use created Billing Account';
            newOrder.isChangeOfSubEntry__c = False;
            newOrder.isWaive__c = False;
            newOrder.Subscriber_Charge__c = newOrder.Delivery_Charge__c;
            newOrder.Monthly_Delivery_Charge_for_Full_Payment__c = newOrder.Delivery_Charge__c;            
        }    
    
    }
    
    private void updOrderListupdate(List<Order__c> oldOrderListUpdate)
    {
    
        Set<Id> accountIds = new Set<Id>();
        
        
        for (Order__c updOrder : oldOrderListUpdate)
        {
            
            accountIds.add(updOrder.Account__c);
            
        }
        
        Map<Id, Account> accountMap = new Map<Id,Account>([Select Id, Name, AccountNumber FROM Account where Id IN : accountIds]);
                    
        
        for (Order__c updOrd : oldOrderListUpdate)
        {
            
            
            
            if(updOrd.Account__c != null && accountMap.containsKey(updOrd.Account__c))
            {
                Account ordAccount = accountMap.get(updOrd.Account__c);
                updOrd.Account_Name__c = ordAccount.Name;
                updOrd.Account_Number__c =  ordAccount.AccountNumber;
                
                
            }
            
                                           
        }   
        
        
                
    } 
    
    private void updateOrderBaList(List<Order__c> oldOrderListUpdate)
    {
    
        Set<Id> billingAccountIds = new Set<Id>();
        
        for (Order__c updOrder : oldOrderListUpdate)
        {                      
            billingAccountIds.add(updOrder.Billing_Account__c);
        }
        
        //START D-3275 07242015 Get Zuora Id of Default Payment Method
        //Map<Id, Zuora__CustomerAccount__c> billingAccountMap = new Map<Id, Zuora__CustomerAccount__c>([Select Id, Zuora__Default_Payment_Method__c FROM Zuora__CustomerAccount__c where Id IN: billingAccountIds]);  
        Map<Id, Zuora__CustomerAccount__c> billingAccountMap = new Map<Id, Zuora__CustomerAccount__c>([Select Id, Zuora__Default_Payment_Method__r.Zuora__External_Id__c FROM Zuora__CustomerAccount__c where Id IN: billingAccountIds]);
        //END D-3275 07242015 Get Zuora Id of Default Payment Method
         
        for (Order__c updOrd : oldOrderListUpdate)
        {
            if(updOrd.Billing_Account__c != null && billingAccountMap.containsKey(updOrd.Billing_Account__c))
            {                
                    Zuora__CustomerAccount__c ordBillingAccount = billingAccountMap.get(updOrd.Billing_Account__c);
                    updOrd.Billing_Account_ID__c = String.valueof(updOrd.Billing_Account__c);
                    //START D-3275 07242015 Get Zuora Id of Default Payment Method
                    //updOrd.Payment_Method_ID__c = ordBillingAccount.Zuora__Default_Payment_Method__c;                
                    updOrd.Payment_Method_ID__c = ordBillingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c;
                    //END D-3275 07242015 Get Zuora Id of Default Payment Method
            }
        } 
    }
    


}