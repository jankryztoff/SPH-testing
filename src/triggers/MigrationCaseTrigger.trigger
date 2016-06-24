trigger MigrationCaseTrigger on Case (after delete, after update, after insert, before delete, before insert, before update) {
 if(MigrationCaseTriggerHandler.preventExecution == FALSE){
      TriggerFactory.createHandler(MigrationCaseTriggerHandler.class);
 }
}