public class OrderTriggerHandler {
    
    public void doBeforeInsert(list<Order__c> newOrderListParam) {
    	setPaymentMethodId(newOrderListParam, null);
    }
    
    
    public void doBeforeUpdate(list<Order__c> newOrderListParam, map<id, Order__c> newOrderId_newOrderParam, 
    		list<Order__c> oldOrderListParam,  map<id, Order__c> oldOrderId_oldOrderParam) {
    			
    	setPaymentMethodId(newOrderListParam, oldOrderId_oldOrderParam);
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
    
    private void setPaymentMethodId(list<Order__c> orderListParam, map<id, Order__c> orderId_oldOrderParam) {
    	
    	final string APPLICABLE_BA_CREATION_MODE = 'Use existing Billing Account';
    	final string APPLICABLE_PAYMENT_MODE = 'Credit Card';
    	set<id> billingAccountIdSet = new set<id>();
    	map<id, string> billingAccountId_defaultPaymentMethodId = new map<id, string>();
    	
    	for (Order__c orderx : orderListParam) {
    		
    		if (orderx.Billing_Account_Creation_Mode__c == APPLICABLE_BA_CREATION_MODE 
    				&& orderx.Payment_Mode__c == APPLICABLE_PAYMENT_MODE 
    				&& orderx.Billing_Account__c != null) {
    		
	    		billingAccountIdSet.add(orderx.Billing_Account__c);
    		}
    	}
    	
    	if (!billingAccountIdSet.isEmpty()) {
    		
    		billingAccountId_defaultPaymentMethodId = getDefaultPaymentMethodId(billingAccountIdSet);
			
			for (Order__c orderx : orderListParam) {
				if (billingAccountId_defaultPaymentMethodId.get(orderx.Billing_Account__c) != null) {
					orderx.Payment_Method_ID__c = billingAccountId_defaultPaymentMethodId.get(orderx.Billing_Account__c);
				}
			}		
    	}
    }
    

    private map<id, string> getDefaultPaymentMethodId(set<id> billingAccountIdSetParam) {
    	
    	map<id, string> billingAccountId_defaultPaymentMethodId = new map<id, string>();
    	final string ELIGIBLE_STATUS = 'Active';
    	
    	for (Zuora__PaymentMethod__c paymentMethod : [select Zuora__BillingAccount__c, Zuora__External_Id__c 
    			from Zuora__PaymentMethod__c where Zuora__BillingAccount__c in :billingAccountIdSetParam 
    			and Zuora__PaymentMethodStatus__c = :ELIGIBLE_STATUS]) {
    				
    		billingAccountId_defaultPaymentMethodId.put(paymentMethod.Zuora__BillingAccount__c, 
    				paymentMethod.Zuora__External_Id__c);
    	}
    	
    	return billingAccountId_defaultPaymentMethodId;
    }
    
}