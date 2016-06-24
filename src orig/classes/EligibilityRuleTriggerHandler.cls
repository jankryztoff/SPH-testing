public class EligibilityRuleTriggerHandler implements TriggerHandlerInterface{
    
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    Set<Id> eligibilityRuleIds;
    Set<Id> eligibilityRulesWithActiveSubs; //will be validated against records to be deleted.
    Set<String> activeSubscriptionStatuses = new Set<String>{'Active'};//other statuses
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !EligibilityRuleTriggerHandler.isBeforeInsertTriggerCalled;
        EligibilityRuleTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !EligibilityRuleTriggerHandler.isBeforeUpdateTriggerCalled;
        EligibilityRuleTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !EligibilityRuleTriggerHandler.isBeforeDeleteTriggerCalled;
        EligibilityRuleTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !EligibilityRuleTriggerHandler.isAfterInsertTriggerCalled;
        EligibilityRuleTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !EligibilityRuleTriggerHandler.isAfterUpdateTriggerCalled;
        EligibilityRuleTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !EligibilityRuleTriggerHandler.isAfterDeleteTriggerCalled;
        EligibilityRuleTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
        
    public void bulkBefore() {
        
        Set<Id> promotionIdsWithActivesubscriptions = new Set<Id>();
        Set<Id> promotionIds = new Set<Id>();
        eligibilityRulesWithActiveSubs = new Set<Id>();
        Set<String> orderNumbers = new Set<String>();
        eligibilityRuleIds = new Set<Id>();
        if(!Trigger.IsDelete) {
            for(sObject s : Trigger.new) {
                eligibilityRuleIds .add((Id) s.get('Id'));
            }
        }
        else {
            for(sObject s : Trigger.old) {
                eligibilityRuleIds.add((Id) s.get('Id'));
            }
        }
        List<Promotion_Eligibility_Rule__c> pers = [SELECT Eligibility_Rule__c, Promotion__c FROM Promotion_Eligibility_Rule__c WHERE Eligibility_Rule__c IN :eligibilityRuleIds];
        for(Promotion_Eligibility_Rule__c per : pers) {
            promotionIds.add(per.Promotion__c);
        }
        Map<String, Set<Id>> orderNumberPromotionIdMap = new Map<String, Set<Id>>();
        
        List<Order_Line_Item__c> orderLineItems = [SELECT Order__r.Name, Promotion_Id__c FROM Order_Line_Item__c WHERE Promotion_Id__c IN :promotionIds];
        
        for(Order_Line_Item__c lineItem : orderLineItems) {

            if (orderNumberPromotionIdMap.containsKey(lineItem.Order__r.Name)) {
                orderNumberPromotionIdMap.get(lineItem.Order__r.Name).add(lineItem.Promotion_ID__c);
            }
            else {
                orderNumberPromotionIdMap.put(lineItem.Order__r.Name, new Set<id>{lineItem.Promotion_ID__c});
            }
            orderNumbers.add(lineItem.Order__r.Name);            
        }

        
        // Removed by MBG changed logic on getting active subscription
        List<Zuora__Subscription__c> subscriptions = [SELECT Id, Order_Number__c FROM Zuora__Subscription__c WHERE Order_Number_1__c IN :orderNumbers AND Zuora__Status__c IN :activeSubscriptionStatuses]; //START/END D-2302 02/24/15 Kevin Evasco: Replaced Order_Number__c  with Order_Number_1__c
        
        for(Zuora__Subscription__c subscription : subscriptions) {
            if(orderNumberPromotionIdMap.containsKey(subscription.Order_Number__c)) {
                promotionIdsWithActivesubscriptions.addAll(orderNumberPromotionIdMap.get(subscription.Order_Number__c));
            }
        }
        
        List<Zuora__Subscription__c> subscriptions1 = [SELECT Id, Order_Number__c, Promotion_1__c FROM Zuora__Subscription__c WHERE Promotion_1__c IN :promotionIds AND Zuora__Status__c IN :activeSubscriptionStatuses];
        
        
        /*for(Promotion_Eligibility_Rule__c per : pers) {
            if(promotionIdsWithActivesubscriptions.contains(per.Promotion__c)) {
                eligibilityRulesWithActiveSubs.add(per.Eligibility_Rule__c);
            }
        }*/
        
        // added by MBG chaging logic of getting active subs with eligibility rules
        // Nov 23, 2014
        for (Zuora__Subscription__c sub : subscriptions1) {
            for (Promotion_Eligibility_Rule__c per : pers) {
                eligibilityRulesWithActiveSubs.add(per.Eligibility_Rule__c);
            }
        }
    }
        
    public void bulkAfter() {
        
    }
    
    public void beforeInsert(SObject so) {
       
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }
    
    public void beforeDelete(SObject so) {
        if(eligibilityRulesWithActiveSubs.contains((id) so.get('Id'))){  
            so.addError('An active subscription exists for a promotion to which the eligibility rule has been attached');
        }
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