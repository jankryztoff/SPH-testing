trigger MigrationNewSubscriptionTrigger on Zuora__Subscription__c (after delete, after insert, after update, before delete, before insert, before update){
    if(MigrationNewSubscriptionTriggerHandler.preventExecution == FALSE){
      TriggerFactory.createHandler(MigrationNewSubscriptionTriggerHandler.class);
    }
}