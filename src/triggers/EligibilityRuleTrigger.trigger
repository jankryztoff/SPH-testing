trigger EligibilityRuleTrigger on Eligibility_Rule__c (after delete, after insert, after update, before delete, before insert, before update)
{
  TriggerFactory.createHandler(EligibilityRuleTriggerHandler.class);
}