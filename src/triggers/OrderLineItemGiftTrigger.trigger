trigger OrderLineItemGiftTrigger on Order_Line_Item_Gift__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(OrderLineItemGiftTriggerHandler.class);
}