trigger CaseVendorSubscriptionTrigger on Case_Vendor_Subscription__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(CaseVendorSubscriptionTriggerHandler.class);
 
    CaseVendorSubscriptionTriggerHandler cTrig = new CaseVendorSubscriptionTriggerHandler();
    
    if (Trigger.isBefore){
        if(Trigger.isInsert){
            cTrig.runBeforeInsertTrigger();
        }
        if(Trigger.isUpdate){
            cTrig.runBeforeUpdateTrigger();
        }
        if(Trigger.isDelete){
            cTrig.runBeforeDeleteTrigger();
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            cTrig.runAfterInsertTrigger();
        }
        if(Trigger.isUpdate){
            cTrig.runAfterUpdateTrigger();
        }
        if(Trigger.isDelete){
            cTrig.runAfterDeleteTrigger();
        }
    }
 
}