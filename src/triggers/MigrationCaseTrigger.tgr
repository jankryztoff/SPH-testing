trigger MigrationCaseTrigger on Case (after delete, after insert, after update, before delete, before insert, before update) {
 if(MigrationCaseTriggerHandler.preventExecution == FALSE){
      TriggerFactory.createHandler(MigrationCaseTriggerHandler.class);
 }
}