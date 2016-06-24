/**
 * Description: Trigger for Contact. Will invoke Trigger Handler to process each Trigger Event. 
                No logic shall be in this class
**/
trigger MigrationContactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete)
{
    MigrationContactTriggerHandler handler = new MigrationContactTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert)
        handler.doBeforeInsert(Trigger.new);
    else if(Trigger.isBefore && Trigger.isUpdate) 
        handler.doBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
   
    
}