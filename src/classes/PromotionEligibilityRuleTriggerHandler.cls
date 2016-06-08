public class PromotionEligibilityRuleTriggerHandler implements TriggerHandlerInterface{
    
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
	//START 18/02/15 Wenjun : Fix Code Bug - Incorrect referring to PackageItemTriggerHandler
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !PromotionEligibilityRuleTriggerHandler.isBeforeInsertTriggerCalled;
        PromotionEligibilityRuleTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !PromotionEligibilityRuleTriggerHandler.isBeforeUpdateTriggerCalled;
        PromotionEligibilityRuleTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !PromotionEligibilityRuleTriggerHandler.isBeforeDeleteTriggerCalled;
        PromotionEligibilityRuleTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !PromotionEligibilityRuleTriggerHandler.isAfterInsertTriggerCalled;
        PromotionEligibilityRuleTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !PromotionEligibilityRuleTriggerHandler.isAfterUpdateTriggerCalled;
        PromotionEligibilityRuleTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !PromotionEligibilityRuleTriggerHandler.isAfterDeleteTriggerCalled;
        PromotionEligibilityRuleTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    //END 18/02/15 Wenjun
	
    public void bulkBefore() {
        if(trigger.isDelete){
            List<Promotion_Eligibility_Rule__c> promotionEligibilityRuleList = trigger.old;
            DeleteProductFamiliesClass dpf = new DeleteProductFamiliesClass();
            dpf.DeleteProductFamilies(promotionEligibilityRuleList);
        }
    }
  
    public void bulkAfter() {
        //start here
    }
    
    public void beforeInsert(SObject so) {
       
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }
    
    public void beforeDelete(SObject so) {
      
    }
    
    public void afterInsert(SObject so) {
        
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {
        
    }
}