public class PromotionTriggerHandler implements TriggerHandlerInterface{

 //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    Set<Id> promotionIds;
    Set<Id> promotionIdsWithActivesubscriptions; //will be validated against records to be deleted.
    Set<String> activeSubscriptionStatuses = new Set<String>{'Active'};//other statuses

    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !PromotionTriggerHandler.isBeforeInsertTriggerCalled;
        PromotionTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !PromotionTriggerHandler.isBeforeUpdateTriggerCalled;
        PromotionTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !PromotionTriggerHandler.isBeforeDeleteTriggerCalled;
        PromotionTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !PromotionTriggerHandler.isAfterInsertTriggerCalled;
        PromotionTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !PromotionTriggerHandler.isAfterUpdateTriggerCalled;
        PromotionTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !PromotionTriggerHandler.isAfterDeleteTriggerCalled;
        PromotionTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
        
    public void bulkBefore() {
    
        //START: D-1758 , 01/15/2015 Modified By: Marvin Gatchalian - in include block of code into Isdelete condition
        if(Trigger.IsDelete) {
            promotionIdsWithActivesubscriptions = new Set<Id>();
            Set<String> orderNumbers = new Set<String>();
            promotionIds = new Set<Id>();
            
                for(sObject s : Trigger.old) {
                    promotionIds.add((Id) s.get('Id'));
                }
			//START: Code Review Implementation 2/17/2015 JAlejandro
			if(!promotionIds.isEmpty())
			{ //END: Code Review Implementation 2/17/2015 JAlejandro
				List<Order_Line_Item__c> orderLineItems = [SELECT Order__r.Name, Promotion_ID__c FROM Order_Line_Item__c WHERE Promotion_ID__c IN :promotionIds];
			   
				Map<String, Set<Id>> orderNumberPromotionIdMap = new Map<String, Set<Id>>();
				for(Order_Line_Item__c lineItem : orderLineItems) {
		
					if (orderNumberPromotionIdMap.containsKey(lineItem.Order__r.Name)) {
						orderNumberPromotionIdMap.get(lineItem.Order__r.Name).add(lineItem.Promotion_ID__c);
					}
					else {
						orderNumberPromotionIdMap.put(lineItem.Order__r.Name, new Set<id>{lineItem.Promotion_ID__c});
					}
					orderNumbers.add(lineItem.Order__r.Name);            
				}  
				//system.assertEquals('', String.valueOf(orderNumberPromotionIdMap));
				// START: Code Review Implementation 2/17/2015 JAlejandro
				if (!activeSubscriptionStatuses.isEmpty())
				{// END: Code Review Implementation 2/17/2015 JAlejandro
                    List<Zuora__Subscription__c> subscriptions = [SELECT Id, Order_Number__c FROM Zuora__Subscription__c WHERE Order_Number_1__c IN :orderNumbers AND Zuora__Status__c IN :activeSubscriptionStatuses]; //START/END D-2302 02/24/15 Kevin Evasco: Replaced Order_Number__c  with Order_Number_1__c
					for(Zuora__Subscription__c subscription : subscriptions) {
						if(orderNumberPromotionIdMap.containsKey(subscription.Order_Number__c)) {
							promotionIdsWithActivesubscriptions.addAll(orderNumberPromotionIdMap.get(subscription.Order_Number__c));
						}
					}
				}// Code Review Implementation 2/17/2015 JAlejandro
			}// Code Review Implementation 2/17/2015 JAlejandro
        }        
        //END: D-1758 , 01/15/2015 Modified By: Marvin Gatchalian - in include block of code into Isdelete condition
    }
        
    public void bulkAfter() {
        
    }
    
    public void beforeInsert(SObject so) {
       
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }
    
    public void beforeDelete(SObject so) {
        if(promotionIdsWithActivesubscriptions.contains((id) so.get('Id'))){  
            so.addError('You cannot delete Promotion(s) with active Subscriptions.');
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