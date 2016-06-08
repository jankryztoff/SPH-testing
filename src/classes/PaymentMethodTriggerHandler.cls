public class PaymentMethodTriggerHandler implements TriggerHandlerInterface{ 
    
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
	//START UD-3863 3/1/2016 Added by J.Sarion
    //Sets
    set<id> billingAccountIdSet = new set<id>(); // Start/End D-2756 22Apr15 JohnD
    Set<Id> billAccIdSet = new Set<Id>();
    
    //Maps
    Map<Id, Zuora__CustomerAccount__c> billAccIdToBillAccMap = new Map<Id, Zuora__CustomerAccount__c>();
    
    static Boolean isDataPrepCalled = false;
    //END UD-3863 3/1/2016 Added by J.Sarion
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !PaymentMethodTriggerHandler.isBeforeInsertTriggerCalled;
        PaymentMethodTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !PaymentMethodTriggerHandler.isBeforeUpdateTriggerCalled;
        PaymentMethodTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !PaymentMethodTriggerHandler.isBeforeDeleteTriggerCalled;
        PaymentMethodTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !PaymentMethodTriggerHandler.isAfterInsertTriggerCalled;
        PaymentMethodTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !PaymentMethodTriggerHandler.isAfterUpdateTriggerCalled;
        PaymentMethodTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !PaymentMethodTriggerHandler.isAfterDeleteTriggerCalled;
        PaymentMethodTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    //START: 04/20/2015 Jean Cari?o : Added for fix of D-2757    
    public void bulkBefore() {
        //START UD-3863 3/1/2016 Added by J.Sarion - Credit Card Failure
        for (Zuora__PaymentMethod__c paymentMethod : (list<Zuora__PaymentMethod__c>)trigger.new) {
            if (Trigger.isInsert) {
                //START 05/04/2015 CR-005 Kevin Evasco - PayPal CR
                if(paymentMethod.Zuora__Type__c == 'CreditCard'){
                    paymentMethod.Name = 'Credit Card ' + paymentMethod.Zuora__CreditCardType__c + paymentMethod.Zuora__CreditCardMaskNumber__c;
                } else if(paymentMethod.Zuora__Type__c == 'PayPal') {
                    paymentMethod.Name = 'PayPal ' + paymentMethod.Zuora__PaypalBaid__c;
                }
                //END 05/04/2015 CR-005 Kevin Evasco - PayPal CR
            }
        }
        //END UD-3863 3/1/2016 Added by J.Sarion - Credit Card Failure
    }
    //END: 04/20/2015 Jean Cari?o : Added For fix D-2757 
        
        
        
    public void bulkAfter() {
        
        Set<Id> paymentMethodID = new Set<Id>();
        Set<Id> BASetID = new Set<Id>();
        
        if(Trigger.IsInsert) {
            for(sObject s : Trigger.new) {
                paymentMethodID.add((Id) s.get('Id'));
                BASetID.add((Id) s.get('Zuora__BillingAccount__c'));
            }
        
        
       
            map <id, Zuora__PaymentMethod__c> BAtoPaymentMethodMap = new map <id, Zuora__PaymentMethod__c>();
            List<Zuora__PaymentMethod__c> paymentMethodList = [SELECT id, Zuora__BillingAccount__c, Zuora__Type__c FROM Zuora__PaymentMethod__c WHERE Zuora__BillingAccount__c IN :BASetID]; //START/END 05/04/2015 CR-005 Kevin Evasco - PayPal CR        
			for(Zuora__PaymentMethod__c eachPayment: paymentMethodList ) {
                BAtoPaymentMethodMap.put(eachPayment.Zuora__BillingAccount__c, eachPayment);
            }
            
            List<Zuora__CustomerAccount__c> BAList = [SELECT id FROM Zuora__CustomerAccount__c WHERE id IN :BASetID];
            List<Zuora__CustomerAccount__c> BAListToUpdate = new List<Zuora__CustomerAccount__c> ();
            for(Zuora__CustomerAccount__c eachBA: BAList) {
                if (BAtoPaymentMethodMap.containskey(eachBA.id)) {
                    Zuora__PaymentMethod__c curPaymentMethod = new Zuora__PaymentMethod__c();
                    curPaymentMethod = BAtoPaymentMethodMap.get(eachBA.id);
                    //eachBA.Zuora__Default_Payment_Method__c = curPaymentMethod.id; START/END D-3279 07/27/15 CommentedOut by RReyes
          //START UD-1397 19-06-2015 Marvin Gatchalian
                    //START D-3279 RReyes - 07/27/15
                    if (curPaymentMethod.id != null){
                         if(String.valueOf(curPaymentMethod.id) != '')
                            eachBA.Zuora__Default_Payment_Method__c = curPaymentMethod.id;
                    }
                    /*CommentedOut by RReyes to use logic above
                    if (curPaymentMethod.id != null || curPaymentMethod.id != '') {
                        eachBA.Zuora__Default_Payment_Method__c = curPaymentMethod.id;
                    }
                    CommentedOut by RReyes to use logic above */
                    //END D-3279 RReyes - 07/27/15
                    //END UD-1397 19-06-2015 Marvin Gatchalian
					
					//START 05/04/2015 CR-005 Kevin Evasco - PayPal CR
					if(curPaymentMethod.Zuora__Type__c == 'PayPal') {
					eachBA.Zuora__DefaultPaymentMethod__c = 'PayPal';
					eachBA.Payment_Mode__c = 'PayPal';
					}
					//END 05/04/2015 CR-005 Kevin Evasco - PayPal CR
                    BAListToUpdate.add(eachBA);
                }
                 
            }
            update BAListToUpdate;
            
            BillingAccountHelper.updateDefaultPaymentMethod(BASetID); // Start/End D-2756 22Apr15 JohnD
        }
        
        //START UD-2549 3/24/2016 Added by J.Sarion - Transferred code to bulkAfter
        if(Trigger.isUpdate) {
            for (Zuora__PaymentMethod__c paymentMethod : (list<Zuora__PaymentMethod__c>)trigger.new) {
                system.debug('>>>>>oldMap ' + ((Zuora__PaymentMethod__c) trigger.oldMap.get(paymentMethod.Id)).Zuora__NumConsecutiveFailures__c);
                system.debug('>>>>>newMap ' + paymentMethod.Zuora__NumConsecutiveFailures__c);
                
                if((paymentMethod.Zuora__NumConsecutiveFailures__c == 3 && ((Zuora__PaymentMethod__c) trigger.oldMap.get(paymentMethod.Id)).Zuora__NumConsecutiveFailures__c != 3) && (paymentMethod.Name.contains('Credit Card') || paymentMethod.Name.contains('PayPal'))) {
                    billAccIdSet.add(paymentMethod.Zuora__BillingAccount__c);
                }
            }
        }
        //END UD-2549 3/24/2016 Added by J.Sarion - Transferred code to bulkAfter
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
		//START UD-2549 3/24/2016 Added by J.Sarion - removed isDataPrepCalled. billAccIdSet will be check only on update
        //START UD-3863 3/1/2016 Added by J.Sarion - Credit Card Failure
        if(!billAccIdSet.isEmpty()) {
			//START UD-2549 3/22/2016 Added by J.Sarion - call queueable class
            Id jobID = System.enqueueJob(new CreditCardFailureQueueableClass(billAccIdSet));
            system.debug(':::jobID' + ' ' + jobID);    
			//END UD-2549 3/22/2016 Added by J.Sarion - call queueable class
        }
        //END UD-3863 3/1/2016 Added by J.Sarion - Credit Card Failure
		//END UD-2549 3/24/2016 Added by J.Sarion - removed isDataPrepCalled. billAccIdSet will be check only on update
    }
}