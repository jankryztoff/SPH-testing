trigger ProductRatePlanChargeTrigger on zqu__ProductRatePlanCharge__c (before insert,after insert,before update,after update,before delete, after delete) {
    TriggerFactory.createHandler(ProductRatePlanChargeTriggerHandler.class);    
}