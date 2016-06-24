/**
* Class Name: InvLineItem_TriggerHandler
* @author: Accenture PDC - Sherwin Puli
* Date: 25.April.2015
* Requirement/Project Name: SF SPH
* @description: Class that manages Invoice Line Items 
*/

public class InvLineItem_TriggerHandler implements TriggerHandlerInterface{
    
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    Map<String, Set<Decimal>> subNameToCharges_MAP = new Map<String, Set<Decimal>>();
    Map<String, Id> subNameToId_MAP = new Map<String, Id>();
    List<Zuora__Subscription__c> subsToUpdate = new List<Zuora__Subscription__c>();
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !InvLineItem_TriggerHandler.isBeforeInsertTriggerCalled;
        InvLineItem_TriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !InvLineItem_TriggerHandler.isBeforeUpdateTriggerCalled;
        InvLineItem_TriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !InvLineItem_TriggerHandler.isBeforeDeleteTriggerCalled;
        InvLineItem_TriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !InvLineItem_TriggerHandler.isAfterInsertTriggerCalled;
        InvLineItem_TriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !InvLineItem_TriggerHandler.isAfterUpdateTriggerCalled;
        InvLineItem_TriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !InvLineItem_TriggerHandler.isAfterDeleteTriggerCalled;
        InvLineItem_TriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
        
    public void bulkBefore() {
        
        if(!trigger.isDelete){
            for(SObject iNew : trigger.new){
                
                Invoice_Line_Item__c invRec = (Invoice_Line_Item__c)iNew;
                if(trigger.isUpdate){
                    SObject oldSO = Trigger.oldMap.get(invRec.Id);
                    Invoice_Line_Item__c oldInv = (Invoice_Line_Item__c)oldSO;
                }
                if(invRec.Subscription__c == null){
                    if(subNameToCharges_MAP.containskey(invRec.Subscription_Number__c)){    
                        subNameToCharges_MAP.get(invRec.Subscription_Number__c).add(invRec.Charge_Amount__c);
                    } else{
                        subNameToCharges_MAP.put(invRec.Subscription_Number__c, new Set<Decimal>{invRec.Charge_Amount__c});
                    }
                }
                
            }
        }
        if(subNameToCharges_MAP.size()>0){
            getSubId(subNameToCharges_MAP);
        }
    } 
        
    public void bulkAfter() {
        
    }
    
    public void beforeInsert(SObject so) {
        Invoice_Line_Item__c invRec = (Invoice_Line_Item__c)so;
        if(subNameToId_MAP.containskey(invRec.Subscription_Number__c)){
            invRec.Subscription__c = subNameToId_MAP.get(invRec.Subscription_Number__c);
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
    
        Invoice_Line_Item__c invUpdRec = (Invoice_Line_Item__c)so;

        if(subNameToId_MAP.containskey(invUpdRec.Subscription_Number__c)){
            invUpdRec.Subscription__c = subNameToId_MAP.get(invUpdRec.Subscription_Number__c);
        }
    }
    
    public void beforeDelete(SObject so) {
      
    }
    
    public void afterInsert(SObject so) {
        
    }


    public void afterUpdate(SObject oldSo, SObject so) {   

    }

    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {
        
        if(subsToUpdate.size()>0){
            //START UD-0533 addedBy S. Puli to avoid SOQL 101 
            SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = true;
            SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled  = true;
            SubscriptionTriggerHandler.isBeforeInsertTriggerCalled  = true;
            SubscriptionTriggerHandler.isAfterUpdateTriggerCalled  = true;
            SubscriptionTriggerHandler.isAfterDeleteTriggerCalled  = true;
            SubscriptionTriggerHandler.isAfterInsertTriggerCalled  = true;
            
            SubscriptionTriggerHandler.isBulkBeforeToRun = FALSE;
            SubscriptionTriggerHandler.isBulkAfterToRun = FALSE;
            SubscriptionTriggerHandler.preventExecution = true; // Start/End D-3518 09Sep15 JohnD
            //END UD-0533 addedBy S. Puli to avoid SOQL 101 
            Database.update(subsToUpdate, false);
        }
        
    }
    
    public void getSubId(Map<String, Set<Decimal>> subsName_MAP){
        if(subsName_MAP.size()>0){
            List<Zuora__Subscription__c> subsLIST = [Select Id, Name, Invoice_Line_Item_Charge__c From Zuora__Subscription__c Where Name In :subsName_MAP.keyset()];
            Decimal charge = 0;
            if(subsLIST.size()>0){
                for(Zuora__Subscription__c sub : subsLIST){
                    subNameToId_MAP.put(sub.Name, sub.Id);

                    if(subsName_MAP.containskey(sub.Name)){
                        for(Decimal d : subsName_MAP.get(sub.Name)){
                            charge += d;
                        }
                    }
                    if(charge > 0){
                        if(sub.Invoice_Line_Item_Charge__c <> null){
                            Decimal oldcharge = sub.Invoice_Line_Item_Charge__c;
                            sub.Invoice_Line_Item_Charge__c = charge + oldcharge;
                        } else{
                            sub.Invoice_Line_Item_Charge__c = charge;
                        }
                        subsToUpdate.add(sub);
                    }
                }
            }
        }
    }
}