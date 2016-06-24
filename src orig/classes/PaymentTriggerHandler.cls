public class PaymentTriggerHandler implements TriggerHandlerInterface{ 
    
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    //Sets
    Set<Id> invoiceIdSet = new Set<Id>();
    Set<Id> paymentIdSet = new Set<Id>();
    public static Set<String> invoiceZuoraIdSet = new Set<String>();
    
    //Lists
    List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
    List<Zuora__PaymentInvoice__c> paymentInvoiceList = new List<Zuora__PaymentInvoice__c>();
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !PaymentTriggerHandler.isBeforeInsertTriggerCalled;
        PaymentTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !PaymentTriggerHandler.isBeforeUpdateTriggerCalled;
        PaymentTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !PaymentTriggerHandler.isBeforeDeleteTriggerCalled;
        PaymentTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !PaymentTriggerHandler.isAfterInsertTriggerCalled;
        PaymentTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !PaymentTriggerHandler.isAfterUpdateTriggerCalled;
        PaymentTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !PaymentTriggerHandler.isAfterDeleteTriggerCalled;
        PaymentTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }

    public void bulkBefore() {      
        
    }
        
    public void bulkAfter() {
        if(trigger.isInsert || trigger.isUpdate) {
            for(SObject sobj :trigger.new) {
                Zuora__Payment__c pm = (Zuora__Payment__c) sobj;
                system.debug('>>>>>pm.Zuora__PaymentMethod__c ' + pm.Zuora__PaymentMethod__c);
                system.debug('>>>>>pm.Zuora__Status__c ' + pm.Zuora__Status__c);
                system.debug('>>>>>pm.Zuora__Invoice__c ' + pm.Zuora__Invoice__c);
                if((pm.Zuora__PaymentMethod__c.contains('PayPal') || pm.Zuora__PaymentMethod__c.contains('Credit Card')) && pm.Zuora__Status__c == 'Error') {
                    paymentIdSet.add(pm.Id);
                }
            }
        }

        if(!paymentIdSet.isEmpty()) {
            paymentInvoiceList = [SELECT Id, Zuora__Invoice__c 
                                  FROM Zuora__PaymentInvoice__c 
                                  WHERE Zuora__Payment__c IN :paymentIdSet];
            
            for(Zuora__PaymentInvoice__c pmInv :paymentInvoiceList) {
                invoiceIdSet.add(pmInv.Zuora__Invoice__c);
            }
        }

        if(!invoiceIdSet.isEmpty()) {
            invoiceList = [SELECT Id, Zuora__Zuora_Id__c, (SELECT Id FROM Zuora__PaymentInvoices__r WHERE Zuora__Payment__r.Zuora__Status__c = 'Error')
                           FROM Zuora__ZInvoice__c 
                           WHERE Id IN :invoiceIdSet AND Zuora__BillingAccount__r.Billing_Type__c = 'Full Prepaid'];
            system.debug('>>>>>invoiceList ' + invoiceList);
            for(Zuora__ZInvoice__c inv :invoiceList) {
                system.debug('>>>>>payment ' + inv.Zuora__PaymentInvoices__r.size());
                if(inv.Zuora__PaymentInvoices__r.size() == 1) {
                    invoiceZuoraIdSet.add(inv.Zuora__Zuora_Id__c);
                }
            }
        }
        system.debug('>>>>>invoiceZuoraIdSet ' + invoiceZuoraIdSet);
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