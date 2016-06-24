/**
 * Class Name: romotionGiftTrigger
 * @author: Marvin B. Gatchalian
 * Date: 14.JUNE.2014
 * Requirement/Project Name: SPH
 * @description: Handles removal of promotion gift.
 */


trigger PromotionGiftTrigger on Promotion_Gift__c (after delete, after insert, after update, before delete, before insert, before update) {
        
        if((trigger.isBefore) && (trigger.isDelete)){
           GR_PromotionGiftRemovalValidation checkIfThereIsSubs = new GR_PromotionGiftRemovalValidation();
           checkIfThereIsSubs.PromotionGiftRemovalValidation(trigger.new,trigger.old,trigger.newMap,trigger.isDelete);
        }  
  
}