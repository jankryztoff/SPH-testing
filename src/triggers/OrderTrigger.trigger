/**
 * Description: Trigger for Order__c. Will invoke Trigger Handler to process each Trigger Event. 
                No logic shall be in this class
**/
trigger OrderTrigger on Order__c (before insert, after insert, before update, after update, before delete, after delete)
{
    OrderTriggerHandler handler = new OrderTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert)
        handler.doBeforeInsert(Trigger.new);
    else if(Trigger.isBefore && Trigger.isUpdate) 
        handler.doBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    /* uncomment item(s) below when needed. make sure to sync the OrderTriggerHandler class
    else if(Trigger.isBefore && Trigger.isDelete) 
        handler.doBeforeDelete(Trigger.old, Trigger.oldMap);
    else if(Trigger.isAfter && Trigger.isInsert)
        handler.doAfterInsert(Trigger.new, Trigger.newMap);
    else if(Trigger.isAfter && Trigger.isUpdate) 
        handler.doAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    else if(Trigger.isAfter && Trigger.isDelete) 
        handler.doAfterDelete(Trigger.old, Trigger.oldMap);
    */
}