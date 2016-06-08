/**
 * Class Name: GR_PromotionGiftRemovalValidation
 * @author: Marvin B. Gatchalian
 * Date: 14.JUNE.2014
 * Requirement/Project Name: SPH
 * @description: Handles removal of promotion gift.
 */

public with sharing class GR_PromotionGiftRemovalValidation { 
  
    Set<Id> subscriptionIds = new Set<ID>();
    Set<Id> promotionGiftIds = new Set<ID>();
    Set<Id> promotionIds = new Set<ID>();
    Set<Id> giftIds = new Set<ID>();

    public void PromotionRemovalValidation (List<Promotion__c> newTrigger, List<Promotion__c> oldTrigger, Map<id,Promotion__c> TriggerMap, Boolean isDelete){
                
        if (isDelete) {
            for(Promotion__c promotiongift: oldTrigger){
                promotionIds.add(promotiongift.id);
            }
            //Start Code Review 02/18/2015 James
			List<Zuora__Subscription__c> subscriptionDetails = new List<Zuora__Subscription__c>();
			if (promotionIds.size() > 0){
			subscriptionDetails = [Select id, Zuora__Status__c from Zuora__Subscription__c where 
                                                                                                            Zuora__Status__c = 'Active' and 
                                                                                                            Promotion_1__c IN: promotionIds];
			}
			//End Code Review 02/18/2015 James
                                                                                                     
            if (subscriptionDetails.size() > 0) {
             //START D-1534 03-Feb-2015 Added by Raviteja - commented the standard Salesforce validation error in order to display the customized error
               // oldTrigger[0].addError('An existing subscription for this promotion is active. This promotion/gift cannot be deleted!');            
                  oldTrigger[0].addError('<span color="red"><b>An existing subscription for this promotion is active. This promotion/gift cannot be deleted!</b></span>',false);
            //End D-1534 03-Feb-2015 Added by Raviteja
            }
        }
              
    } 

    public void PromotionGiftRemovalValidation (List<Promotion_Gift__c> newTrigger, List<Promotion_Gift__c> oldTrigger, Map<id,Promotion_Gift__c> TriggerMap, Boolean isDelete){
		
        if (isDelete) {
            for(Promotion_Gift__c promotiongift: oldTrigger){
                promotionGiftIds.add(promotiongift.Promotion__c);
            }
			
			//Start Code Review 02/18/2015 James
			List<Zuora__Subscription__c> subscriptionDetails = new List<Zuora__Subscription__c>();
			if (promotionGiftIds.size() > 0){
           subscriptionDetails = [Select id, Zuora__Status__c from Zuora__Subscription__c where 
                                                                                                            Zuora__Status__c = 'Active' and 
                                                                                                            Promotion_1__c  IN: promotionGiftIds];
			}
			//End Code Review 02/18/2015 James
            if (subscriptionDetails.size() > 0) {
                oldTrigger[0].addError('An existing subscription for this promotion is active. This promotion/gift cannot be deleted!');
            }
        }
              
    } 
    
    public void GiftRemovalValidation (List<Gift__c> newTrigger, List<Gift__c> oldTrigger, Map<id,Gift__c> TriggerMap, Boolean isDelete) {
		if (isDelete) {
            for(Gift__c gift: oldTrigger){
                giftIds.add(gift.id);
            }
            
			//Start Code Review 02/18/2015 James
			List<Promotion_Gift__c> promotionGiftDetails = new List<Promotion_Gift__c>();
			if (giftIds.size() > 0){
            promotionGiftDetails = [Select id, promotion__c, gift__c from Promotion_Gift__c where gift__c IN: giftIds];
            }
			//End Code Review 02/18/2015 James
			
            if (promotionGiftDetails.size() != 0) {
                for (Promotion_Gift__c promotiongift: promotionGiftDetails){
                    promotionGiftIds.add(promotiongift.promotion__c);
                }
				
				//Start Code Review 02/18/2015 James
				List<Zuora__Subscription__c> subscriptionDetails = new List<Zuora__Subscription__c>();
				if (promotionGiftIds.size() > 0){
                subscriptionDetails = [Select id, Zuora__Status__c from Zuora__Subscription__c where 
                                                                                                            Zuora__Status__c = 'Active' and 
                                                                                                            Promotion_1__c IN: promotionGiftIds];
				}
				//End Code Review 02/18/2015 James
				
                if (subscriptionDetails.size() > 0) {
                    oldTrigger[0].addError('An existing subscription for this promotion is active. This promotion/gift cannot be deleted!');
                }
            }
             
        }
    }
    


}