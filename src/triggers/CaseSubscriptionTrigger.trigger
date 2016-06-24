/**
 * Description: Trigger for Case_Subscription__c. Will invoke Trigger Handler to process each Trigger Event. 
                No logic shall be in this class
 * History: D-2323 24/02/15 Wenjun - Fix SQL 101 Issue and use new Trigger Framework
**/
trigger CaseSubscriptionTrigger on Case_Subscription__c (before insert, after insert, before update, after update, before delete, after delete)
{
    CaseSubscriptionTriggerHandler handler = new CaseSubscriptionTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert)
        handler.doBeforeInsert(Trigger.new);
    else if(Trigger.isBefore && Trigger.isUpdate) 
        handler.doBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    else if(Trigger.isBefore && Trigger.isDelete) 
        handler.doBeforeDelete(Trigger.old, Trigger.oldMap);
    else if(Trigger.isAfter && Trigger.isInsert)
        handler.doAfterInsert(Trigger.new, Trigger.newMap);
    else if(Trigger.isAfter && Trigger.isUpdate) 
        handler.doAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    else if(Trigger.isAfter && Trigger.isDelete) 
        handler.doAfterDelete(Trigger.old, Trigger.oldMap);
}