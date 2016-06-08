/**
* Class Name: InvoiceTriggerHandler
* @author: Accenture PDC - Kevin Evasco
* Date: September 21 2015
* Requirement/Project Name: SF SPH - UD-2504 and UD-2826
* @description: Invoice Trigger Handler
*/

public class InvoiceTriggerHandler implements TriggerHandlerInterface{
    
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
	Set<Id> billingAccountIdSet = new Set<Id>();
		
	Map<Id,Decimal> billingAccountID_balance_map = new Map<Id,Decimal>();
	
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !InvoiceTriggerHandler.isBeforeInsertTriggerCalled;
        InvoiceTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !InvoiceTriggerHandler.isBeforeUpdateTriggerCalled;
        InvoiceTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !InvoiceTriggerHandler.isBeforeDeleteTriggerCalled;
        InvoiceTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !InvoiceTriggerHandler.isAfterInsertTriggerCalled;
        InvoiceTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !InvoiceTriggerHandler.isAfterUpdateTriggerCalled;
        InvoiceTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !InvoiceTriggerHandler.isAfterDeleteTriggerCalled;
        InvoiceTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    //START: D-995 12/05/14 Added by S.Puli
    
    public void bulkBefore() {    		
	
		if(trigger.isBefore && trigger.isInsert) {
			for(SObject record : trigger.new) {
				Zuora__ZInvoice__c invoiceElem = (Zuora__ZInvoice__c) record;
				billingAccountIdSet.add(invoiceElem.Zuora__BillingAccount__c);
			}
			
			List<Zuora__CustomerAccount__c> billingAccountList = [SELECT Id, Zuora__Balance__c FROM Zuora__CustomerAccount__c WHERE Id IN : billingAccountIdSet];
			
			for(Zuora__CustomerAccount__c billingAccountElem : billingAccountList) {
				billingAccountID_balance_map.put(billingAccountElem.Id, billingAccountElem.Zuora__Balance__c);
			}
		}
    } 
        
    public void bulkAfter() {
    }
    
    public void beforeInsert(SObject so) {		
		Zuora__ZInvoice__c invoiceElem = (Zuora__ZInvoice__c) so;
		invoiceElem.Previous_Balance__c = billingAccountID_balance_map.get(invoiceElem.Zuora__BillingAccount__c) - invoiceElem.Zuora__TotalAmount__c;
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