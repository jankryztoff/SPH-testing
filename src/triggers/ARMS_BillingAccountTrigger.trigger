trigger ARMS_BillingAccountTrigger on Zuora__CustomerAccount__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(ARMS_TriggerHandler.class);
}