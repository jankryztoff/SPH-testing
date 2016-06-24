/*
*
 * Description: Trigger for Order Line Item. Will invoke Trigger Handler to process each Trigger Event. 
                No logic shall be in this class
*/
trigger MigrationOLITrigger on Order_Line_Item__c (before insert, after insert, before update, after update, before delete, after delete)
{
    MigrationOLITriggerHandler handler = new MigrationOLITriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert) 
        handler.doBeforeInsert(Trigger.new);
    else if(Trigger.isBefore && Trigger.isUpdate) 
        handler.doBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
}