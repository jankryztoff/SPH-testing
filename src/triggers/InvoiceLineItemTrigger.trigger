trigger InvoiceLineItemTrigger on Invoice_Line_Item__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(InvLineItem_TriggerHandler.class);
}