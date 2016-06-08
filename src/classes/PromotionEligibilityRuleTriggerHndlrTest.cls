/**
* Class Name: <PromotionEligibilityRuleTriggerHndlrTest>
* @author: CV Manawatao\Val Lu
* Date: <02/26/2015>
* Requirement/Project Name: <SPH>
* @description<Test Class for PromotionEligibilityRuleTriggerHandler>
*/
@isTest(SeeAllData = True)
private class PromotionEligibilityRuleTriggerHndlrTest {
    /**
    *  To test PromotionEligibilityRuleTriggerHndlr class
    *  @name testPromotionEligibilityRuleTriggerHndlr
    *  @param none
    *  @return none
    *  @throws na
    */  
    static testmethod void testPromotionEligibilityRuleTriggerHndlr(){
    
        
         List<Eligibility_Rule__c> eRule = TestDataFactory.createEligibilityRule(2);
         eRule[0].Contract_Subscription_Rule__c = 'Contract End Date';
         eRule[0].Action__c = 'Add';
         eRule[0].Current_Platform__c = 'Online';
         eRule[0].Condition__c = '>=';
         eRule[0].Contract_Type__c = 'NA';
         eRule[0].Subsciber_Status__c = 'New Subscriber';
         eRule[0].Customer_Status__c = 'New customer';
         eRule[0].Date__c = Date.today();
         eRule[0].Contract_Subscription_Rule__c = 'NA';        
        
         insert eRule;
         
         system.assertNotEquals(null,eRule[0].id);
        
         List<Promotion__c> Promo = TestDataFactory.createPromotion(2);
         Promo[0].Name = 'Test Promo0';
         Promo[0].Promotion_Code__c = 'TESTx1';
         Promo[0].Contract__c='Yes';
         Promo[0].Contract_Period__c = '15';
         Promo[0].Effective_End_Date__c=date.today()+100;
         Promo[0].Effective_Start_Date__c=date.today();
            
         Promo[1].Name = 'Test Promo1';
         Promo[1].Promotion_Code__c = 'TESTx2';
         Promo[1].Contract__c='Yes';
         Promo[1].Contract_Period__c = '20';
         Promo[1].Effective_End_Date__c=date.today()+100;
         Promo[1].Effective_Start_Date__c=date.today().addDays(-3);
             
         insert Promo;
        
         system.assertNotEquals(null,Promo[0].id);
         system.assertNotEquals(null,Promo[1].id);
        
         //create Promotion eligibility rule
         List<Promotion_Eligibility_Rule__c> promoEli = TestDataFactory.createPromEligibilityRule(2);
         promoEli[0].Promotion__c = Promo[0].Id;
         promoEli[0].Eligibility_Rule__c = eRule[0].Id;
         promoEli[0].Package_List__c = 'Test package';
         promoEli[0].Product_Family__c = 'ST';
         promoEli[0].Date__c = Date.today();
         //promoEli[0].Days__c = '28';
            
         promoEli[1].Promotion__c = Promo[1].Id;
         promoEli[1].Eligibility_Rule__c = eRule[1].Id;
         promoEli[1].Package_List__c = 'Test package';
         promoEli[1].Product_Family__c = 'ST';
         promoEli[1].Date__c = Date.today().addDays(-2);
         //promoEli[1].Days__c = '15';
             
        
         Test.startTest();
        
         insert promoEli;
         
         system.assertNotEquals(null,promoEli[0].id);
         system.assertNotEquals(null,promoEli[1].id);
        
         eRule[0].Eligibility_Rule__c = promoEli[0].Id;
         update eRule[0];
         
         eRule[1].Eligibility_Rule__c = promoEli[1].Id;
         update eRule[1];
         
         SObject SObj, OldSObj;
        
         PromotionEligibilityRuleTriggerHandler PromoTrgerHndlr = new PromotionEligibilityRuleTriggerHandler();
         system.assertNotEquals(null,PromoTrgerHndlr);
         PromoTrgerHndlr.runBeforeInsertTrigger();
         PromoTrgerHndlr.runBeforeUpdateTrigger();
         PromoTrgerHndlr.runBeforeDeleteTrigger();
         PromoTrgerHndlr.runAfterInsertTrigger();
         PromoTrgerHndlr.runAfterUpdateTrigger();
         PromoTrgerHndlr.runAfterDeleteTrigger();
         PromoTrgerHndlr.bulkAfter();
         PromoTrgerHndlr.andFinally();
         PromoTrgerHndlr.beforeInsert(SObj);
         PromoTrgerHndlr.beforeUpdate(OldSObj , SObj);
         PromoTrgerHndlr.beforeDelete(SObj);
         PromoTrgerHndlr.afterInsert(SObj);
         PromoTrgerHndlr.afterUpdate(OldSObj , SObj);
         PromoTrgerHndlr.afterDelete(SObj); 
         Test.stopTest();
     

    }
}