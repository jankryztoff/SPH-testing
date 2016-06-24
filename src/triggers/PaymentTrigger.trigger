trigger PaymentTrigger on Zuora__Payment__c (after insert, after update){
    
TriggerFactory.createHandler(PaymentTriggerHandler.class);

}