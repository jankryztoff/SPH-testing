trigger AddressTrigger on Address__c (after delete, after insert, after update, before delete, before insert, before update)
{
    TriggerFactory.createHandler(AddressTriggerHandler.class);
}