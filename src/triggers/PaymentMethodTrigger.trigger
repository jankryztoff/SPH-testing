trigger PaymentMethodTrigger on Zuora__PaymentMethod__c (after delete, after insert, after update, before delete, before insert, before update){//START/ENDJean Cari?o: Added before insert for D-2757 //START-END UD-2549 3/28/2016 Added J.Sarion 
  TriggerFactory.createHandler(PaymentMethodTriggerHandler.class);
}