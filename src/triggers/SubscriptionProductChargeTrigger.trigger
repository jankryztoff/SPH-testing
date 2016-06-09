trigger SubscriptionProductChargeTrigger on Zuora__SubscriptionProductCharge__c (after delete, after insert, after update, before delete, before insert, before update) { 
    TriggerFactory.createHandler(SubscriptionProductChargeTriggerHandler.class);     
}