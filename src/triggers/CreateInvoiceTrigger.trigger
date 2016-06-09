trigger CreateInvoiceTrigger on Zuora__ZInvoice__c (after insert){
    
TriggerFactory.createHandler(CreateInvoiceTriggerHandler.class);

}