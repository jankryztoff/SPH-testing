/*
 * Trigger Name: CreditNoteTrigger 
 * @author: Sherwin Puli
 * Date: 29-Feb-2016
 * Project/Requirement: UD-3253 CR for credit note
 * Description: Trigger for Credit Note. Will invoke Trigger Handler to process each Trigger Event. 
                No logic shall be in this class
**/
trigger CreditNoteTrigger on Credit_Note__c (before insert, after insert, before update, after update, before delete, after delete)
{
    CreditNoteTriggerHandler handler = new CreditNoteTriggerHandler();
    
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