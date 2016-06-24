trigger LetterPrintRequestTrigger on Letter_Print_Request__c (before insert) {
LetterPrintRequestTriggerHandler handler = new LetterPrintRequestTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert){ 
        handler.doBeforeInsert(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
}