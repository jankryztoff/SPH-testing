/**
* Class Name: <MigrationSubscriptionTriggerHandler>
* @authors: <Christopher Camilon>
* Date: <4/8/2015>
* Requirement/Project Name: <SPH>
* @description <Validate>
*/
global class MigrationSubscriptionTriggerHandler{
    //START D-2920 05122015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created
    public void doBeforeInsert(List<Zuora__Subscription__c> lstNewSubs)
    {
        //START D-3171 07082015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created
        List<Zuora__Subscription__c> updateSubEndDateList = new List<Zuora__Subscription__c>();
        for(Zuora__Subscription__c newSubscription : lstNewSubs)
        {
            if(newSubscription.Legacy_Subscription_ID__c != null){
                updateSubEndDateList.add(newSubscription);    
            }
        }
        
        updateSubscriptionEndDate(updateSubEndDateList);
        //END D-3171 07082015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created
    }
    //END D-2920  05122015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created
    public void doBeforeUpdate(List<Zuora__Subscription__c> lstNewSubscriptions, Map<Id, Zuora__Subscription__c> mapNewSubscriptions,
                List<Zuora__Subscription__c> lstOldSubscriptions, Map<Id, Zuora__Subscription__c> mapOldSubscriptions)
    {
    
        List<Zuora__Subscription__c> lstUpdatedSubscriptions = new List<Zuora__Subscription__c>();
        
        for(Zuora__Subscription__c newSubscription : lstNewSubscriptions)
        {
                
            if(mapOldSubscriptions.get(newSubscription.Id) != null ){
            
                if(newSubscription.Legacy_Subscription_ID__c != null){
                
                    lstUpdatedSubscriptions.add(newSubscription);    
                
                }
            
            }
        
        }
        
        if(!lstUpdatedSubscriptions.isEmpty())
            subscriptionUpdate(lstUpdatedSubscriptions);
            
        
    }
    //START D-3171 07082015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created
    public void doAfterUpdate(List<Zuora__Subscription__c> lstNewSubscriptions, Map<Id, Zuora__Subscription__c> mapNewSubscriptions,
                List<Zuora__Subscription__c> lstOldSubscriptions, Map<Id, Zuora__Subscription__c> mapOldSubscriptions)
    {
        List<Zuora__Subscription__c> lstUpdatedSubscriptions = new List<Zuora__Subscription__c>();
        
        for(Zuora__Subscription__c newSubscription : lstNewSubscriptions)
        {
                
            if(mapOldSubscriptions.get(newSubscription.Id) != null ){
            
                if(newSubscription.Legacy_Subscription_ID__c != null){
                
                    lstUpdatedSubscriptions.add(newSubscription);    
                
                }
            
            }
        
        }
        
        if(!lstUpdatedSubscriptions.isEmpty())
            updateOrder(lstUpdatedSubscriptions);        
    
    }
    //END D-3171 07082015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created
    /*
    public void doAfterUpdate(List<Zuora__Subscription__c> lstNewSubscriptions, Map<Id, Zuora__Subscription__c> mapNewSubscriptions,
                List<Zuora__Subscription__c> lstOldSubscriptions, Map<Id, Zuora__Subscription__c> mapOldSubscriptions)
    {
        Set<Id> subscriptionIds = new Set<Id>();
        for(Zuora__Subscription__c newSubscription : lstNewSubscriptions)
        {
        
            if(newSubscription.Legacy_Subscription_ID__c != null){
            
                subscriptionIds.add(newSubscription.Id);
            
            }
        
        }    
        
        if(!subscriptionIds.isEmpty())
            zuoratoUpdate(subscriptionIds);        
    
    }
    */
    //START D-2920 05122015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created   
    private void updateSubscriptionEndDate(List<Zuora__Subscription__c> newSubsList){
    
        for (Zuora__Subscription__c updEndDateSub : newSubsList){
            
            if(updEndDateSub.Zuora__SubscriptionEndDate__c != null){            
                Date newSubscriptionEndDate = updEndDateSub.Zuora__SubscriptionEndDate__c.addDays(-1);
                updEndDateSub.Subscription_End_Date__c = String.valueOf(newSubscriptionEndDate);
                updEndDateSub.Zuora__SubscriptionEndDate__c = newSubscriptionEndDate;               
            }
            
        }
    
    }
    //END D-2920 05122015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created
    private void subscriptionUpdate(List<Zuora__Subscription__c> lstUpdateSubscriptions)
    {
    
        for (Zuora__Subscription__c updSubscription : lstUpdateSubscriptions){
            //START D-2944 05142015 Christopher Camilon - To update fields when subscription is created and enhanced
            updSubscription.Ph_d__c = True;
            updSubscription.Ph_e__c = True;
            //END D-2944 05142015 Christopher Camilon - To update fields when subscription is created and enhanced
        
            if(updSubscription.Addon_Package_1__c != null){
                updSubscription.Addon_Package__c = String.valueOf(updSubscription.Addon_Package_1__c);
            }
            
            if(updSubscription.Billing_Type__c == null){
                updSubscription.Billing_Type_isNull__c = 'True';               
            }else{
                updSubscription.Billing_Type_isNull__c = 'False';
            }
            
            if(updSubscription.Delivered_By_1__c != null){
                updSubscription.Delivered_By__c = String.valueOf(updSubscription.Delivered_By_1__c);
            }
            
            if(updSubscription.Main_Package_1__c != null){
                updSubscription.Main_Package_isNull__c = 'False';
                updSubscription.Main_Package__c = String.valueOf(updSubscription.Main_Package_1__c);
            }else{
                updSubscription.Main_Package_isNull__c = 'True';
                updSubscription.Main_Package__c = '';
            }
            
            if(updSubscription.Order_Line_Item_Number_1__c != null){
                updSubscription.Order_Line_Item_Number__c = String.valueOf(updSubscription.Order_Line_Item_Number_1__c);    
            }
            
            if(updSubscription.Order_Number_1__c != null){
                updSubscription.Order_Number__c = String.valueOf(updSubscription.Order_Number_1__c);    
            }
            
            if(updSubscription.Promotion_1__c != null){
                updSubscription.Promotion__c = String.valueOf(updSubscription.Promotion_1__c);    
            }
            //START D-2944 05142015 Christopher Camilon - To update fields when subscription is created and enhanced
           
            //START D-3264 07202015 Christopher Camilon - To check if Number of Copies is populated.           
            /*
            if(updSubscription.Number_of_Copies1__c != null || String.valueOF(updSubscription.Number_of_Copies1__c) != ''){
                updSubscription.Qty__c = Integer.valueof(updSubscription.Number_of_Copies1__c);
                updSubscription.Number_of_Copies__c = Integer.valueof(updSubscription.Number_of_Copies1__c);
                updSubscription.Qty1__c = updSubscription.Number_of_Copies1__c;
            }
            */
            if(updSubscription.Number_of_Copies1__c != null && String.valueOF(updSubscription.Number_of_Copies1__c) != ''){
                updSubscription.Qty__c = Integer.valueof(updSubscription.Number_of_Copies1__c);
                updSubscription.Number_of_Copies__c = Integer.valueof(updSubscription.Number_of_Copies1__c);
                updSubscription.Qty1__c = updSubscription.Number_of_Copies1__c;
            }
            
            //END D-3264 07202015 Christopher Camilon - To check if Number of Copies is populated.           
            
          
            
            
            if(updSubscription.Subscription_Type__c != null || String.valueOF(updSubscription.Subscription_Type__c) != ''){            
                updSubscription.Subscription_Type_1__c = String.valueof(updSubscription.Subscription_Type__c);            
            }
            
            /*
            if(updSubscription.Qty__c != null){
                updSubscription.Qty1__c = String.valueOf(updSubscription.Qty__c);    
            }
            */
            
            //END D-2944 05142015 Christopher Camilon - To update fields when subscription is created and enhanced
            if(updSubscription.Recipient_Contact__c != null){
                updSubscription.Recipient_Contact_1__c = String.valueOf(updSubscription.Recipient_Contact__c);    
                updSubscription.Recipient_Contact_isNull__c = 'False';
            }else{
                updSubscription.Recipient_Contact_1__c = '';    
                updSubscription.Recipient_Contact_isNull__c = 'True';
            }
            
            if(updSubscription.Subscriber_Contact__c != null){
                updSubscription.Subscriber_Contact_1__c = String.valueOf(updSubscription.Subscriber_Contact__c);    
            }
            
            if(updSubscription.Vendor_1__c != null){
                updSubscription.Vendor__c = String.valueOf(updSubscription.Vendor_1__c);    
            }
            
            if(updSubscription.Vendor_Subscription_To_Convert_1__c != null){
                updSubscription.Vendor_Subscription_To_Convert__c = String.valueOf(updSubscription.Vendor_Subscription_To_Convert_1__c);    
            }
            //START D-2849 04302015 Christopher Camilon - To update the Subscription End Date
            //START D-2920 05122015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created
            /*
            if(updSubscription.Zuora__SubscriptionEndDate__c != null){            
                Date newSubscriptionEndDate = updSubscription.Zuora__SubscriptionEndDate__c.addDays(-1);
                updSubscription.Subscription_End_Date__c = String.valueOf(newSubscriptionEndDate);
                updSubscription.Zuora__SubscriptionEndDate__c = newSubscriptionEndDate;               
            }
            */
            //END D-2920 05122015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created        
            //END D-2849 04302015 Christopher Camilon - To update the Subscription End Date
        }
    
    }
    
    //START D-2849 04302015 Christopher Camilon - To update the Subscription End Date
    /*
    @future(callout=true)
    public static void zuoratoUpdate(Set<Id> lstUpdateSubscriptionsId){
        
        List<Map<String, Object>> updateSubscriptionMapList = new List<Map<String, Object>>();
        ZuoraCallOut SubscriptionCallOut = new ZuoraCallOut();
   
        
        for(Zuora__Subscription__c subscriptiontoUpdate : [Select id, Zuora__Zuora_Id__c, Main_Package__c, Order_Line_Item_Number__c, Order_Number__c, Promotion__c, Qty1__c, Recipient_Contact_1__c, Vendor__c, Vendor_Subscription_To_Convert__c  from Zuora__Subscription__c where id in :lstUpdateSubscriptionsId])
        {
            Map<String, Object> updateSubscriptionMap = new Map<String, Object>();
            updateSubscriptionMap.put('Id', String.valueof(subscriptiontoUpdate.Zuora__Zuora_Id__c));
            updateSubscriptionMap.put('Main_Package__c', String.valueof(subscriptiontoUpdate.Main_Package__c));      
            updateSubscriptionMap.put('Order_Line_Item_Number__c', String.valueof(subscriptiontoUpdate.Order_Line_Item_Number__c));   
            updateSubscriptionMap.put('Order_Number__c', String.valueof(subscriptiontoUpdate.Order_Number__c));
            updateSubscriptionMap.put('Promotion__c', String.valueof(subscriptiontoUpdate.Promotion__c)); 
            updateSubscriptionMap.put('Qty1__c', String.valueof(subscriptiontoUpdate.Qty1__c)); 
            updateSubscriptionMap.put('Recipient_Contact_1__c', String.valueof(subscriptiontoUpdate.Recipient_Contact_1__c));
            updateSubscriptionMap.put('Vendor__c ', String.valueof(subscriptiontoUpdate.Vendor__c));     
            updateSubscriptionMap.put('Vendor_Subscription_To_Convert__c', String.valueof(subscriptiontoUpdate.Vendor_Subscription_To_Convert__c));
            //END D-2849 04302015 Christopher Camilon - To update the Subscription End Date
            updateSubscriptionMapList.add(updateSubscriptionMap);
               
        
        }
        
        if (!updateSubscriptionMapList.isEmpty()) {
            List<Map<String,String>> returnVarUpdateSubscription = SubscriptionCallOut.amendZObjects(updateSubscriptionMapList); 
            
            for(Map<String,String> resultUpdateMapSubscription :returnVarUpdateSubscription){ 
                if (resultUpdateMapSubscription.get('Status') == 'Success') {
                    //TBD
                    system.debug('>>>>>>>>>>>>>>>Success' + resultUpdateMapSubscription);
                }
                else {
                    //TBD
                    system.debug('>>>>>>>>>>>>>>>Failed' + resultUpdateMapSubscription);
                }
            }
        }
    
    }    
    */
    //START D-3171 07082015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created
    private void updateOrder(List<Zuora__Subscription__c> subList){
        
        Set<Id> orderIds = new Set<Id>();     
        Map<String, Zuora__Subscription__c> subMap = new Map<String, Zuora__Subscription__c>();             
        for(Zuora__Subscription__c sub : subList)
        {
            orderIds.add(sub.Order_Number_1__c);
            subMap.put(sub.Order_Number_1__c,sub);
        }
        List<Order__c> orderList = new List<Order__c>([Select Id, Initial_Term__c, Full_Prepaid_Delivery_Charge__c, Delivery_Charge__c, Total_Full_Prepaid__c From Order__c where Id in : orderIds]);
        for(Order__c ord : OrderList){
            Zuora__Subscription__c subCon = subMap.get(ord.Id);
            ord.Initial_Term__c = String.valueof(integer.valueof(subCon.Term_Length__c));
            if(subCon.Subscription_Type_1__c == 'Delivery' && subCon.Billing_Type__c =='Full Prepaid')
            {
                ord.Full_Prepaid_Delivery_Charge__c = integer.valueof(subCon.Term_Length__c) * subCon.Delivery_Charge__c;
            }            
            //Start D-3264 07202015 Christopher Camilon - To check if Subsacription Delivery have Delivery Charge           
            if(subCon.Subscription_Type_1__c == 'Delivery')
            {
                if(subCon.Delivery_Charge__c == null){
                    ord.Subscriber_Charge__c = 0;
                }else{
                    ord.Subscriber_Charge__c = subCon.Delivery_Charge__c;
                }
            }
            //END  D-3264 07202015 Christopher Camilon - To check if Subsacription Delivery have Delivery Charge
            if(subCon.Subscription_Type_1__c == 'Publication' && subCon.Billing_Type__c =='Full Prepaid'){            
                ord.Total_Full_Prepaid__c = ord.Total_Full_Prepaid__c + subCon.Subscription_Charge__c;            
            }
            if(subCon.Subscription_Type_1__c == 'Delivery' && subCon.Billing_Type__c =='Full Prepaid'){            
                ord.Total_Full_Prepaid__c = ord.Total_Full_Prepaid__c + (subCon.Delivery_Charge__c * subCon.Term_Length__c);            
            }   
            System.Debug('@' + ord.Total_Full_Prepaid__c);
            System.Debug('@@' + subCon.Term_Length__c);    
            System.Debug('@@@' + ord.Full_Prepaid_Delivery_Charge__c);         
            
        } 
        update orderList;
    }
    //END D-3171 07082015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created
    
     
   
}