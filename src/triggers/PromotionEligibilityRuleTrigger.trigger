trigger PromotionEligibilityRuleTrigger on Promotion_Eligibility_Rule__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(PromotionEligibilityRuleTriggerHandler.class);
}