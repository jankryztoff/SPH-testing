trigger PackageTrigger on Package__c (after delete, after insert, after update, before delete, before insert, before update)
{
	TriggerFactory.createHandler(PackageTriggerHandler.class);
}