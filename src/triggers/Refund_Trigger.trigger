/** HISTORY
  * UD-1419 7/20/2015 Alyana Navarro
  **/ 
trigger Refund_Trigger on Zuora__Refund__c (after delete, after insert, after update, before delete, before insert, before update) {
    Refund_TriggerHandler refundTrigger = new Refund_TriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert){
        refundTrigger.doBeforeInsert(Trigger.new);
    } else if(Trigger.isBefore && Trigger.isUpdate){
        refundTrigger.doBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    } else if(Trigger.isBefore && Trigger.isDelete){
        refundTrigger.doBeforeDelete(Trigger.old, Trigger.oldMap);
    } else if(Trigger.isAfter && Trigger.isInsert){
        refundTrigger.doAfterInsert(Trigger.new, Trigger.newMap);
    } else if(Trigger.isAfter && Trigger.isUpdate){
        refundTrigger.doAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    } else if(Trigger.isAfter && Trigger.isDelete){
        refundTrigger.doAfterDelete(Trigger.old, Trigger.oldMap);
    }
}