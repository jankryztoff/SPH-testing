trigger PaymentMethodTrigger on Zuora__PaymentMethod__c (after insert) {
  TriggerFactory.createHandler(PaymentMethodTriggerHandler.class);
}