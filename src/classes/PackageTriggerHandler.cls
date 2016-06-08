public class PackageTriggerHandler implements TriggerHandlerInterface{
    
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    Set<Id> packageIds;
    Set<Id> packageIdsWithActivesubscriptions; //will be validated against records to be deleted.
    Set<String> activeSubscriptionStatuses = new Set<String>{'Active'};//other statuses
    //START 2/19/2015 MGAELO Code Review declare subscriptions as a list 
    List<Zuora__Subscription__c> subscriptions = new List<Zuora__Subscription__c>();
    //END 2/19/2015 Added by MGAELO 
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !PackageTriggerHandler.isBeforeInsertTriggerCalled;
        PackageTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !PackageTriggerHandler.isBeforeUpdateTriggerCalled;
        PackageTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !PackageTriggerHandler.isBeforeDeleteTriggerCalled;
        PackageTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !PackageTriggerHandler.isAfterInsertTriggerCalled;
        PackageTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !PackageTriggerHandler.isAfterUpdateTriggerCalled;
        PackageTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !PackageTriggerHandler.isAfterDeleteTriggerCalled;
        PackageTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
        
    public void bulkBefore() {
        
        //START: 01/14/2015 Modified By: Marvin Gatchalian - in include block of code into Isdelete condition
        if(Trigger.IsDelete) {
            packageIdsWithActivesubscriptions = new Set<Id>();
            Set<String> orderNumbers = new Set<String>();
            packageids = new Set<Id>();
            
                for(sObject s : Trigger.old) {
                    packageIds.add((Id) s.get('Id'));
                }
            
            
            List<Order_Line_Item__c> orderLineItems = [SELECT Order__r.Name, Promotion_ID__c, Main_Package_ID__c FROM Order_Line_Item__c WHERE Promotion_ID__c IN :packageIds];
           
            Map<String, Set<Id>> orderNumberpackageIdMap = new Map<String, Set<Id>>();
            for(Order_Line_Item__c lineItem : orderLineItems) {
                
                if(orderNumberpackageIdMap.containsKey(lineItem.Order__r.Name)) {
                    orderNumberpackageIdMap.get(lineItem.Order__r.Name).add(lineItem.Promotion_ID__c);
                }
                else {
                    orderNumberpackageIdMap.put(lineItem.Order__r.Name, new Set<id>{lineItem.Main_Package_ID__c});
                }
                orderNumbers.add(lineItem.Order__r.Name);            
            }    
            //START 2/18/15 MGaelo Code Review: check if orderNumbers and activeSubscriptionStatuses is null and moved declaration of list of subscriptions
            if (orderNumbers.size()>0 && activeSubscriptionStatuses.size()>0){
                subscriptions = [SELECT Id, Order_Number__c FROM Zuora__Subscription__c WHERE Order_Number__c IN :orderNumbers AND Zuora__Status__c IN :activeSubscriptionStatuses];
            }
            //END 2/18/15 Added by MGaelo
            for(Zuora__Subscription__c subscription : subscriptions) {
                if(orderNumberpackageIdMap.containsKey(subscription.Order_Number__c)) {
                    packageIdsWithActivesubscriptions.addAll(orderNumberpackageIdMap.get(subscription.Order_Number__c));
                }
            }
        
        }
        //END: 01/14/2015 Modified By: Marvin Gatchalian - in include block of code into Isdelete condition
		
		//START:UD-1033 5/5/15 Added by Manolo Valena - Added before update and invoke the new method.
        if(Trigger.isUpdate) {
            List<Package__c> packageList = Trigger.new;
            List<Package__c> packageListOld = Trigger.old;
            fullPrepaidSubscriptionBillingPeriod(packageList, packageListOld);
        }
        //END:UD-1033 5/5/15 Added by Manolo Valena
    }
        
    public void bulkAfter() {
        
    }
    
    public void beforeInsert(SObject so) {
       
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }
    
    public void beforeDelete(SObject so) {
        if(packageIdsWithActivesubscriptions.contains((id) so.get('Id'))){  
            so.addError('You cannot delete Packages(s) with active Subscriptions.');
        }
    }
    
    public void afterInsert(SObject so) {
        
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {
        
    }
	
	//START:UD-1033 5/5/15 Added by Manolo Valena - New method to add error when Subscription Period is being updated while there are package items having different Billing Period.
    public void fullPrepaidSubscriptionBillingPeriod (List<Package__c> packageList, List<Package__c> packageListOld) {
        Set<Id> packageIds = new Set<Id>();
        Map<Id, String> mapPackageToPackageItemBillingPeriod = new Map<Id, String>();
        List<Package_Item__c> packageItemList = new List<Package_Item__c>();
        
        for(Package__c packageRecord : packageList) {
            for(Package__c packageRecordOld : packageListOld) {
                if(packageRecordOld.Id == packageRecord.Id) {   
                    if(packageRecord.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED) {
                        if(packageRecordOld.Subscription_Period__c != packageRecord.Subscription_Period__c) {
                            packageIds.add(packageRecord.Id);
                        }
                    }
                }
            }
        }
        
        if(packageIds.size() > 0) {
            packageItemList = [SELECT Package__c, Product_Rate_Plan__r.BillingPeriod__c, 
                               Package__r.Subscription_Type__c, Product_Rate_Plan__r.BillingType__c
                               FROM Package_Item__c 
                               WHERE Package__c IN : packageIds 
                               AND Product_Rate_Plan__r.BillingType__c =: GlobalVariableClass.BILLING_TYPE_FULL_PRE];
            
            if(packageItemList.size() > 0) {
                for(Package_Item__c packageItemRecord : packageItemList) {
                    if(!mapPackageToPackageItemBillingPeriod.containsKey(packageItemRecord.Package__c)) {
                        mapPackageToPackageItemBillingPeriod.put(packageItemRecord.Package__c, packageItemRecord.Product_Rate_Plan__r.BillingPeriod__c);
                    }
                }
            }
            String sBreak = '</br>';
            for(Package__c pack : packageList) {
                if(mapPackageToPackageItemBillingPeriod.containsKey(pack.Id)) {
                    if(pack.Subscription_Period__c != mapPackageToPackageItemBillingPeriod.get(pack.Id)) {
                        pack.addError('<span>There are already product rate plans connected to this package having the Billing Period: ' + mapPackageToPackageItemBillingPeriod.get(pack.Id) + 
                        sBreak + 'Please delete the package item/s connected to this package to be able to update the value of the Subscription Period field.</span>', false);
                    }
                }
            }
        }
    }
    //END:UD-1033 5/5/15 Added by Manolo Valena
}