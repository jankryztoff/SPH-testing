trigger MigrationCaseSubTrigger on Case_Subscription__c (after delete, after insert, after update, before delete, before insert, before update) {
 if(MigrationCaseSubTriggerHandler.preventExecution == FALSE){
      TriggerFactory.createHandler(MigrationCaseSubTriggerHandler.class);
 }
}