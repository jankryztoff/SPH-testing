trigger ZoneProductTrigger on Zone_Product__c (after delete, after insert, after update, before delete, before insert, before update)
{
  TriggerFactory.createHandler(ZoneProductTriggerHandler.class);
}