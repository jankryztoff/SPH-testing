/**
* Class Name: InvoicePaymentTriggerHandler
* @author: Accenture PDC - Kevin Evasco
* Date: September 21 2015
* Requirement/Project Name: SF SPH - UD-2504 and UD-2826
* @description: Invoice Payment Trigger Handler
*/

public class InvoicePaymentTriggerHandler implements TriggerHandlerInterface{
    
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    public Set<Id> invIdSet = new Set<Id>(); //START-END UD-2549 3/22/2016 Added by J.Sarion
    public Set<String> invoiceZuoraIdSet = new Set<String>(); //START-END UD-2549 3/24/2016 Added by J.Sarion - remode static
	Set<Id> paymentIdSet = new Set<Id>();
	Set<Id> invoiceIdSet = new Set<Id>();
	
    List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>(); //START-END UD-2549 3/22/2016 Added by J.Sarion
		
	Map<Id,Id> paymentId_invoiceId = new Map<Id,Id>();
	Map<Id, Zuora__ZInvoice__c> invoiceMap = new Map<Id, Zuora__ZInvoice__c>();
	
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !InvoicePaymentTriggerHandler.isBeforeInsertTriggerCalled;
        InvoicePaymentTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !InvoicePaymentTriggerHandler.isBeforeUpdateTriggerCalled;
        InvoicePaymentTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;   
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !InvoicePaymentTriggerHandler.isBeforeDeleteTriggerCalled;
        InvoicePaymentTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !InvoicePaymentTriggerHandler.isAfterInsertTriggerCalled;
        InvoicePaymentTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !InvoicePaymentTriggerHandler.isAfterUpdateTriggerCalled;
        InvoicePaymentTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !InvoicePaymentTriggerHandler.isAfterDeleteTriggerCalled;
        InvoicePaymentTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    //START: D-995 12/05/14 Added by S.Puli
    
    public void bulkBefore() {    		
		//Start UD-3890 11-Apr-2016 Added By S.Puli - Remove logic of previous balance
        if(trigger.isInsert) {
			/***
            for(SObject record : trigger.new) {
                Zuora__PaymentInvoice__c invoiceElem = (Zuora__PaymentInvoice__c) record;
                paymentIdSet.add(invoiceElem.Zuora__Payment__c);
                invoiceIdSet.add(invoiceElem.Zuora__Invoice__c);
                paymentId_invoiceId.put(invoiceElem.Zuora__Payment__c, invoiceElem.Zuora__Invoice__c);
            }
            
            invoiceMap = new Map<Id, Zuora__ZInvoice__c>([SELECT Id, Previous_Balance__c FROM Zuora__ZInvoice__c WHERE Id IN : invoiceIdSet]);
            
            List<Zuora__Payment__c> paymentList = [SELECT Id, Zuora__Amount__c FROM Zuora__Payment__c WHERE Id IN : paymentId_invoiceId.keySet() AND Zuora__Status__c = 'Processed'];
            for(Zuora__Payment__c paymentElem : paymentList) {
                Id invoiceId = paymentId_invoiceId.get(paymentElem.Id);
                if(invoiceMap.get(invoiceId) != null) {
                    invoiceMap.get(invoiceId).Previous_Balance__c += paymentElem.Zuora__Amount__c;
                }
            }
			***/
        }
		//End UD-3890 11-Apr-2016 Added By S.Puli
    } 
        
    public void bulkAfter() {
		//START UD-2549 3/22/2016 Added by J.Sarion - check payment failure
        if(trigger.isInsert) {
            system.debug('>>>>>trigger ' + trigger.newMap.values());
            for(SObject sobj :trigger.newMap.values()) {
                Zuora__PaymentInvoice__c pmInv = (Zuora__PaymentInvoice__c) sobj;
                system.debug('>>>>>pmInv ' + pmInv);
                system.debug('>>>>>pmInv.Zuora__Invoice__c ' + pmInv.Zuora__Invoice__c);
                invIdSet.add(pmInv.Zuora__Invoice__c);
            }
        }
        system.debug('>>>>>invIdSet ' + invIdSet);
        if(!invIdSet.isEmpty()) {
            invoiceList = [SELECT Id, Zuora__Zuora_Id__c, (SELECT Id FROM Zuora__PaymentInvoices__r WHERE Zuora__Payment__r.Zuora__Status__c = 'Error')
                           FROM Zuora__ZInvoice__c 
                           WHERE Id IN :invIdSet AND Zuora__BillingAccount__r.Billing_Type__c = 'Full Prepaid'];
            system.debug('>>>>>invoiceList ' + invoiceList);
            for(Zuora__ZInvoice__c inv :invoiceList) {
                system.debug('>>>>>payment ' + inv.Zuora__PaymentInvoices__r.size());
                if(inv.Zuora__PaymentInvoices__r.size() == 1) {
                    invoiceZuoraIdSet.add(inv.Zuora__Zuora_Id__c);
                }
            }
        }
        system.debug('>>>>>invoiceZuoraIdSet ' + invoiceZuoraIdSet);
		//END UD-2549 3/22/2016 Added by J.Sarion - check payment failure
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
		//START UD-2549 3/22/2016 Added by J.Sarion - create tasks
        if(!invoiceZuoraIdSet.isEmpty())
            createTasks(invoiceZuoraIdSet);
		//END UD-2549 3/22/2016 Added by J.Sarion - create tasks
	
		if(trigger.isInsert){
			update invoiceMap.values();
		}
    }    
    //START UD-2549 UD-2549 3/22/2016 Added by J.Sarion - create tasks
    @future(callout=true)
    public static void createTasks(Set<String> invZuoraIdSet) {
        //Lists
        List<Zuora.zObject> invoiceLineItemList = new List<Zuora.zObject>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        List<Task> taskList = new List<Task>();
        //START UD-2549 4/5/2016 Added by J.Sarion
        List<Map<String, Object>> updateInvoiceMapList = new List<Map<String, Object>>();
        List<Map<String, String>> resultMapList = new List<Map<String, String>>(); 
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
        //END UD-2549 4/5/2016 Added by J.Sarion
        
        //Sets
        Set<String> subZuoraIdSet = new Set<String>();
        
        //Maps
        Map<String, Object> objMap = new Map<String, Object>(); //START-END UD-2549 4/5/2016 Added by J.Sarion
        
        //Variables
        String queryStr = '';
        
        Logger logger = new Logger(InvoicePaymentTriggerHandler.class.getName()); //START-END UD-2549 4/5/2016 Added by J.Sarion
        
        ZuoraCallout zCallout = new ZuoraCallout();
        system.debug('>>>>>invZuoraIdSet ' + invZuoraIdSet);
        
        //START UD-2549 4/5/2016 Added by J.Sarion - update invoice 
        invoiceList = [SELECT Id, Is_CN_Processed__c FROM Zuora__ZInvoice__c WHERE Zuora__Zuora_Id__c IN :invZuoraIdSet];
        system.debug('>>>>>invoiceList ' + invoiceList);
        for(Zuora__ZInvoice__c inv :invoiceList) {
            inv.Is_CN_Processed__c = false;
        }
        //END UD-2549 4/5/2016 Added by J.Sarion - update invoice 
        for(String invId :invZuoraIdSet) {
            queryStr += ' OR InvoiceId=\'' + invId + '\'';
            
            //START UD-2549 4/5/2016 Added by J.Sarion - update InvoicePaymentFailure__c to Y
            objMap = new Map<String, Object>();
            objMap.put('Id', invId);
            objMap.put('InvoicePaymentFailure__c', 'Y');
            updateInvoiceMapList.add(objMap);
            //END UD-2549 4/5/2016 Added by J.Sarion - update InvoicePaymentFailure__c to Y
        }
        
        //START UD-2549 4/5/2016 Added by J.Sarion - update invoice
        if(!updateInvoiceMapList.isEmpty()) {
            resultMapList = new List<Map<String, String>>();
            resultMapList = zCallOut.updateZObjects(updateInvoiceMapList, 'Invoice');
            system.debug('>>>>>resultMapList ' + resultMapList);
            for(Map<String, String> resultMap :resultMapList) {
                if(resultMap.get('Status') != 'Success') {
                    logger.log(false, resultMap.get('Message'));
                }
            }
        }
        //END UD-2549 4/5/2016 Added by J.Sarion - update invoice
        
        if(queryStr != '') {
            queryStr = queryStr.substring(4);
            queryStr += ' AND ChargeAmount > 0';
            String zoqlString = 'SELECT Id, SubscriptionId, InvoiceId FROM InvoiceItem Where ' + queryStr;
            
            invoiceLineItemList = zCallout.bulkQueryZObjects(zoqlString); //START-END UD-2549 3/15/2016 Added by J.Sarion - added params
        }
        
        system.debug('>>>>>invoiceLineItemList ' + invoiceLineItemList);
        if(!invoiceLineItemList.isEmpty()) {
            for(Zuora.zObject zobj :invoiceLineItemList) {
                subZuoraIdSet.add((String) zobj.getValue('SubscriptionId'));
            }
        }
        system.debug('>>>>>subZuoraIdSet ' + subZuoraIdSet);
        if(!subZuoraIdSet.isEmpty()) {
            subList = [SELECT Id, (SELECT Id, Case__r.CreatedById, Case__r.Account__c, Case__r.AccountId FROM Case_Subscriptions__r 
                        WHERE Case__r.RecordTypeId = :ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION) 
                        //START PD-0116 Gdelrosario/JDacutan : added condition for RENEWAL and COS
                        or Case__r.RecordTypeId = :ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION) 
                        or Case__r.RecordTypeId = :ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_RENEWAL_OF_SUBSCRIPTION)) 
                        //END PD-0116 Gdelrosario/JDacutan : added condition for RENEWAL and COS
                        FROM Zuora__Subscription__c 
                        WHERE Zuora__Zuora_Id__c IN :subZuoraIdSet AND Subscription_Type_1__c = 'Publication'];
        }
        
        for(Zuora__Subscription__c sub :subList) {
            system.debug('>>>>>Case_Subscriptions__r ' + sub.Case_Subscriptions__r.size());
            Task t = new Task();
            t.Subject = 'Payment failure - Credit card / Paypal';
            t.OwnerId = sub.Case_Subscriptions__r[0].Case__r.CreatedById;
            t.Status = 'Open';
            t.Priority = 'High';
            t.ActivityDate = date.Today();
            t.WhatId = sub.Case_Subscriptions__r[0].Case__r.Account__c;
            t.WhatId = sub.Case_Subscriptions__r[0].Case__r.AccountId;
            taskList.add(t);
            system.debug('>>>>>task ' + t);
        }
        
        if(!taskList.isEmpty()) {
            try {
                insert taskList;
            }
            catch(Exception e) {
                system.debug('>>>>>Error ' + e);
                logger.log(e); //START-END UD-2549 4/5/2016 Added by J.Sarion - error handling
            }
        }
        
        //START UD-2549 4/5/2016 Added by J.Sarion
        if(!invoiceList.isEmpty()) {
            try {
                update invoiceList;
            }
            catch(Exception e) {
                system.debug('>>>>>Error ' + e);
                logger.log(e); //START-END D- 4/5/2016 Added by J.Sarion - error handling
            }
        }
        
        logger.save();
        //END UD-2549 4/5/2016 Added by J.Sarion - insert logs
    }
	//END UD-2549 3/22/2016 Added by J.Sarion - create tasks
}