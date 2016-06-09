/*
* Class Name: <SubscriptionVendorTriggerHandler>
* @authors: <CharlesLin>
* Date: <2/24/2015>
* Requirement/Project Name: <SPH>
*/
public class SubscriptionVendorTriggerHandler implements TriggerHandlerInterface {

    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    static Set<Id> accountIdSet = new Set<Id>();
    static List<Account> accountsList = new List<Account>();
    static List<exception> exceptionList = new List<exception>();
    static List<Subscription_Vendor__c> subVendorList = new List<Subscription_Vendor__c>();
    static Map<Id, List<Subscription_Vendor__c>> accountIdToSubscriptionVendorMap = new Map<Id, List<Subscription_Vendor__c>>();
    static Set<Id> accIdSet = new Set<Id>();
    static Set<Id> accntIdSet = new Set<Id>();
    static List<Account> inactiveAccountsList = new List<Account>();
    //Start UD-1643 06/17/2015 James
    static Map<Id,Date> StopOLIMap = new Map<Id,Date>();
    static List<Id> StopSubVenIdList = new List<Id>();
    static List<Id> StopCaseIdList = new List<Id>();
    static List<Order_Line_Item_Vendor__c> StopOLIList = new List<Order_Line_Item_Vendor__c>();
    //End UD-1643 06/17/2015 James
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isBeforeInsertTriggerCalled;
        SubscriptionTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;
    }
   
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled;
        SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;
    }
   
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled;
        SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;
    }
   
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isAfterInsertTriggerCalled;
        SubscriptionTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;
    }
   
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isAfterUpdateTriggerCalled;
        SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;
    }
   
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !SubscriptionTriggerHandler.isAfterDeleteTriggerCalled;
        SubscriptionTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;
    }
    
    public void bulkBefore() {
        //Start UD-1643 06/17/2015 James
        if (Trigger.isInsert || Trigger.isUpdate){
            for (Subscription_Vendor__c subVendor : (List<Subscription_Vendor__c>)trigger.new) {
                if(subVendor.Status__c == GlobalVariableClass.STATUS_CANCELLED){
                    StopSubVenIdList.add(subVendor.Id);
                }
            }
            if(StopSubVenIdList.size() > 0){
                StopOLIList = [SELECT Id, Stop_Request_Date__c, Subscription_Vendor__c FROM Order_Line_Item_Vendor__c WHERE Subscription_Vendor__c IN :StopSubVenIdList AND Stop_Request_Date__c != null];
            }
            if(StopOLIList.size() > 0){
                for(Order_Line_Item_Vendor__c StopOLIVen : StopOLIList){
                    StopOLIMap.put(StopOLIVen.Subscription_Vendor__c, StopOLIVen.Stop_Request_Date__c);
                }
            }
        }
        //End UD-1643 06/17/2015 James
    }
    
    public void bulkAfter() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (Subscription_Vendor__c subVendor : (List<Subscription_Vendor__c>)trigger.new) {
                if(subVendor.Status__c == GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE){
                    accountIdSet.add(subVendor.Account__c);
                }
                
                if(subVendor.Status__c != GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE){
                    accIdSet.add(subVendor.Account__c);
                }
            }
                       
            accountsList = [SELECT Id, Status__c FROM Account WHERE Id IN :accountIdSet];
            
            subVendorList = [SELECT Id, Status__c, Account__c FROM Subscription_Vendor__c WHERE Account__c IN :accIdSet AND Status__c = :GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE];
            
            for(Subscription_Vendor__c sv : subVendorList){
                if(accountIdToSubscriptionVendorMap.containsKey(sv.Account__c)){
                    accountIdToSubscriptionVendorMap.get(sv.Account__c).add(sv);
                }else{
                    accountIdToSubscriptionVendorMap.put(sv.Account__c, new List<Subscription_Vendor__c> {sv});
                }
            }
            
            for(Id accId : accIdSet){
                if(!accountIdToSubscriptionVendorMap.containsKey(accId)){
                    accntIdSet.add(accId);
                }
            }
            
            inactiveAccountsList = [SELECT Id, Status__c FROM Account WHERE Id IN :accntIdSet];
        }
    }
    
    public void beforeInsert(SObject so) {
        
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        //Start UD-1643 06/17/2015 James
        Subscription_Vendor__c SubscriptionVendor = (Subscription_Vendor__c)so;
        
        if(StopOLIMap.size() > 0){
            if(StopOLIMap.containsKey(SubscriptionVendor.Id)){
                SubscriptionVendor.Subscription_Stop_Date__c = StopOLIMap.get(SubscriptionVendor.Id);
            }
        }
        //End UD-1643 06/17/2015 James
    }
    
    public void beforeDelete(SObject so) {

    }
    
    public void afterInsert(SObject so) {
        for(Account a : accountsList){
            a.Status__c = GlobalVariableClass.ACCOUNT_STATUS_ACTIVE;
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so) {
        for(Account a : accountsList){
            a.Status__c = GlobalVariableClass.ACCOUNT_STATUS_ACTIVE;
        }
        
        for(Account acc: inactiveAccountsList){
            acc.Status__c = GlobalVariableClass.ACCOUNT_STATUS_INACTIVE;
        }
    }
    
    public void afterDelete(SObject so) {
       
    }
    
    public void andFinally() {
        if (trigger.isAfter) {
            if (!accountsList.isEmpty()) {
                try {
                    update accountsList;
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }
                        
            if (!inactiveAccountsList.isEmpty()) {
                try {
                    update inactiveAccountsList;
                } catch (exception e) {
                    exceptionList.add(e);
                }
            }
            
            ExceptionLogger.log(exceptionList);
        }
    }
    
}