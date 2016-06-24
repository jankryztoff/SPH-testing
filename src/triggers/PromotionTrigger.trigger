/**
 * Class Name: PromotionTrigger
 * @author: Marvin B. Gatchalian
 * Date Modified: 14.JUNE.2014
 * Requirement/Project Name: SPH
 * @description: Handles removal of promotion.
 */

trigger PromotionTrigger on Promotion__c (after delete, after insert, after update, before delete, before insert, before update)
{
  TriggerFactory.createHandler(PromotionTriggerHandler.class);
  
  // Added last Oct 17,2014 to call Apex class Promotion Removal
  if((trigger.isBefore) && (trigger.isDelete)){
           GR_PromotionGiftRemovalValidation checkIfThereIsSubs = new GR_PromotionGiftRemovalValidation();
           checkIfThereIsSubs.PromotionRemovalValidation (trigger.new,trigger.old,trigger.newMap,trigger.isDelete);
  }  
  
}