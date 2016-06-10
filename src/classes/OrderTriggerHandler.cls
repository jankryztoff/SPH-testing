public class OrderTriggerHandler {
    
    public void doBeforeInsert(list<Order__c> newOrderListParam) {
    	setPaymentMethodId(newOrderListParam);
    }
    
    
    public void doBeforeUpdate(list<Order__c> newOrderListParam, map<id, Order__c> newOrderId_newOrderParam, 
    		list<Order__c> oldOrderListParam,  map<id, Order__c> oldOrderId_oldOrderParam) {
    	
    	list<Order__c> order2UpdateList = new list<Order__c>();
    	
    	for (Order__c orderx : newOrderListParam) {
    		
    		Order__c newOrder = newOrderId_newOrderParam.get(orderx.Id);
    		Order__c oldOrder = oldOrderId_oldOrderParam.get(orderx.Id);
    		
    		if (newOrder.Billing_Account__c != oldOrder.Billing_Account__c 
    				|| newOrder.Billing_Account_Creation_Mode__c != oldOrder.Billing_Account_Creation_Mode__c) {
    			
    			order2UpdateList.add(orderx);		
    		}
    	}
    	
    	if (!order2UpdateList.isEmpty()) {
    		setPaymentMethodId(order2UpdateList);
    	}
    	
    	system.debug('>>>>>> ' + newOrderListParam);
    }

	/* uncomment item(s) below when needed. make sure to sync the OrderTrigger trigger
	public void doBeforeDelete(list<Order__c> oldOrderListParam,  map<id, Order__c> oldOrderId_oldOrderParam) {
		
	}
	
	public void doAfterInsert(list<Order__c> newOrderListParam, map<id, Order__c> newOrderId_newOrderParam) {
		
	}
    
    public void doAfterUpdate(list<Order__c> newOrderListParam, map<id, Order__c> newOrderId_newOrderParam, 
    		list<Order__c> oldOrderListParam,  map<id, Order__c> oldOrderId_oldOrderParam) {
    	
    }
    
    public void doAfterDelete(list<Order__c> oldOrderListParam,  map<id, Order__c> oldOrderId_oldOrderParam) {
    	
    }
    */
    
    private void setPaymentMethodId(list<Order__c> orderListParam) {
    	
    	final string APPLICABLE_BA_CREATION_MODE = 'Use existing Billing Account';
    	final string APPLICABLE_PAYMENT_MODE = 'Credit Card';
    	set<id> billingAccountIdSet = new set<id>();
    	map<id, string> billingAccountId_defaultPaymentMethodId = new map<id, string>();
    	boolean is4Update;
    	
    	for (Order__c orderx : orderListParam) {
			
    		if (orderx.Billing_Account_Creation_Mode__c == APPLICABLE_BA_CREATION_MODE 
    				&& orderx.Payment_Mode__c == APPLICABLE_PAYMENT_MODE 
    				&& orderx.Billing_Account__c != null) {
    			
	    		billingAccountIdSet.add(orderx.Billing_Account__c);
    		}
    	}
    	
    	if (!billingAccountIdSet.isEmpty()) {

			system.debug('update occur');
			
	    	for (Zuora__CustomerAccount__c billingAccount : [select Id, Zuora__Default_Payment_Method__r.Zuora__External_Id__c 
	    			from Zuora__CustomerAccount__c where Id in :billingAccountIdSet]) {
	    				
	    		billingAccountId_defaultPaymentMethodId.put(billingAccount.Id, 
	    				billingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);
	    	}

			for (Order__c orderx : orderListParam) {
				if (billingAccountId_defaultPaymentMethodId.get(orderx.Billing_Account__c) != null) {
					orderx.Payment_Method_ID__c = billingAccountId_defaultPaymentMethodId.get(orderx.Billing_Account__c);
				}
			}		
    	}
    }
}