//START UD-2549 3/23/2016 Added by J.Sarion
trigger InvoicePaymentTrigger on Zuora__PaymentInvoice__c (after insert) {
    TriggerFactory.createHandler(InvoicePaymentTriggerHandler.class);
}
//END UD-2549 3/23/2016 Added by J.Sarion