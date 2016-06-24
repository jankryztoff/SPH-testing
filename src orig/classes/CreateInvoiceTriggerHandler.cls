public class CreateInvoiceTriggerHandler implements TriggerHandlerInterface {
    /**
     * Class Name: <CreateInvoiceTriggerHandler>
     * @authors: Estoya
     * Date: <3/17/2015>
     * Requirement/Project Name: [MD-12] D-2588
     * @description <create a Credit Balance Adjustment record>
     */
    
    //recursion flags
//D-3146 Start
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    //D-3146 End
    //START UD-3002 12/11/2015 Added by J.Sarion - Record Type Id for Direct Corporate
    public Id ACCOUNT_DIRECTCORPORATE = ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRCORP);
    //END UD-3002 12/11/2015 Added by J.Sarion - Record Type Id for Direct Corporate
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled;
        CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled;
        CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled;
        CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled;
        CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled;
        CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled;
        CreateInvoiceTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }      

   
    
    public void afterInsert(SObject so) {
        // Start HotFix 15Jun15 JohnD - commented out 
        /*
        //create credit adjustment
        
        startDate = zuora.zUtil.getZuoraDate(date.today());
        List<Map<String, Object>> listMap = new List<Map<String, Object>>();
            
        ZuoraCallOut creditAdjustmentCallOut = new ZuoraCallOut();
            
                                                                        
        List<Zuora__ZInvoice__c> InvoiceList = [SELECT Zuora__BillingAccount__c, Zuora__BillingAccount__r.Other_PaymentMethod__c ,
                                                    Zuora__BillingAccount__r.Zuora__BillCycleDay__c, Zuora__Account__c, Zuora__Balance2__c, Zuora__BillingAccount__r.Zuora__Credit_Balance__c 
                                                    FROM Zuora__ZInvoice__c 
                                                    WHERE Zuora__BillingAccount__r.Other_PaymentMethod__c != 'Paypal' 
                                                        AND Zuora__BillingAccount__r.Other_PaymentMethod__c !='CreditCard'
                                                        AND Zuora__BillingAccount__r.Zuora__Credit_Balance__c > 0];
                                    
            
            
            for (Zuora__ZInvoice__c cBalance : InvoiceList){
                if (cBalance.Zuora__BillingAccount__r.Zuora__Credit_Balance__c > cBalance.Zuora__Balance2__c){
                    Map<String,Object> creditAdjustment = new Map<String, Object>();
                    creditAdjustment.put('AdjustmentDate', startDate );
                    creditAdjustment.put('Amount', cBalance.Zuora__Balance2__c);
                    creditAdjustment.put('Type', 'Decrease' );          
                }
                else{
                    Map<String,Object> creditAdjustment = new Map<String, Object>();
                    creditAdjustment.put('AdjustmentDate', startDate );
                    creditAdjustment.put('Amount',cBalance.Zuora__Balance2__c );
                    creditAdjustment.put('Type', 'Increase' );
                }
                
                try{
                List<Map<String,String>> resultMap = creditAdjustmentCallOut.loadZObjects(listMap, 'CreditBalanceAdjustment');
                //Map<String,String> creditAdjustment = creditAdjustmentCallOut.createZObject(creditAdjustment, 'CreditBalanceAdjustment');
                
                    for(Map<String, String> rMap: resultMap) {
                        if(rMap.get('Status') == 'Success'){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ConstantsSLB.geterrorMessage('Credit Balance Adjustment Success')));
                        }
                        else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('Failed Credit Adjustment Refund')));
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Message: ' + rMap.get('Message')));
                        }
                    }
                } catch (exception ze) {
                        ApexPages.addMessages(ze);
                    }
                
            }
                
        */
        // End HotFix 15Jun15 JohnD - commented out 
        
    }
    public void bulkAfter() {
        
        // Start HotFix 15Jun15 JohnD - added logic for credit balance adjustment
        if (trigger.isInsert) {
            set<id> invoiceIdSet = new set<id>();
            //START UD-3002 12/10/2015 Added by J.Sarion - Set of Ids for Direct Corporate
            Set<String> directCorpInvoiceIdSet = new Set<String>();
            Set<Id> billAccIdSet = new Set<Id>();
            Map<Id, Zuora__CustomerAccount__c> billAccIdToBillAccMap = new Map<Id, Zuora__CustomerAccount__c>();
            List<Zuora__CustomerAccount__c> billAccList = new List<Zuora__CustomerAccount__c>();
            //END UD-3002 12/10/2015 Added by J.Sarion - Set of Ids for Direct Corporate
            
            //START UD-3002 12/11/2015 Added by J.Sarion - Check Billing Account and Account
            for(Zuora__ZInvoice__c invoice : (list<Zuora__ZInvoice__c>)trigger.new){
                billAccIdSet.add(invoice.Zuora__BillingAccount__c);
            }
            system.debug('>>>>>billAccIdSet ' + billAccIdSet);
            if(!billAccIdSet.isEmpty()) {
                billAccList = [SELECT Id, Billing_Type__c, Zuora__Account__r.RecordTypeId FROM Zuora__CustomerAccount__c WHERE Id IN: billAccIdSet];
            }
            system.debug('>>>>>billAccList ' + billAccList);
            for(Zuora__CustomerAccount__c billAcc :billAccList) {
                billAccIdToBillAccMap.put(billAcc.Id, billAcc);
            }
            
            //END UD-3002 12/11/2015 Added by J.Sarion - Check Billing Account and Account
            
            for (Zuora__ZInvoice__c invoice : (list<Zuora__ZInvoice__c>)trigger.new) {
                //START UD-3002 12/11/2015 Added by J.Sarion - Check Account if Direct Corporate
                system.debug('>>>>> ' + invoice.Zuora__Account__r.RecordTypeId);
                Zuora__CustomerAccount__c billAcc;
                
                if(billAccIdToBillAccMap.containsKey(invoice.Zuora__BillingAccount__c)) {
                    billAcc = billAccIdToBillAccMap.get(invoice.Zuora__BillingAccount__c);
                }
                system.debug('>>>>>billAcc ' + billAcc);
                //START UD-3676 RReyes - 01/20/16 - only check if direct corporate regardless of billing type.
                if(billAcc != null) {
                    if(billAcc.Zuora__Account__r.RecordTypeId == ACCOUNT_DIRECTCORPORATE ) {
                        directCorpInvoiceIdSet.add(invoice.Zuora__Zuora_Id__c);
                    }
                    /*
                    else {
                        invoiceIdSet.add(invoice.Id);
                    }*/
                }
                //END UD-3676 RReyes - 01/20/16 - only check if direct corporate regardless of billing type.
                //END UD-3002 12/11/2015 Added by J.Sarion - Check Account if Direct Corporate
            }
            //START UD-3002 12/15/2015 Added by J.Sarion - check if null
            //START UD-3676 CommentedOut by RReyes - 01/20/16 - no need to call this method
            //if(!invoiceIdSet.isEmpty()){
           //     CreditBalanceAdjustmentCallout.send(invoiceIdSet);
            //}
            //END UD-3676 CommentedOut by RReyes - 01/20/16 - no need to call this method
            //END UD-3002 12/15/2015 Added by J.Sarion - check if null
            
            //START UD-3002 12/11/2015 Added by J.Sarion - enqueue job for invoicePostProcessingForDirectCorp
            //START UD-3491 9Jan16 FrancisBenzon : synced class in dv1 as new logic for payment creation added.
            if(!directCorpInvoiceIdSet.isEmpty()){
                //invoicePostProcessingForDirectCorp inv = new invoicePostProcessingForDirectCorp();
                //invoicePostProcessingForDirectCorp.processDirectCorp(directCorpInvoiceIdSet);
                //START UD-3676 RReyes - change method call
                //Id jobID = System.enqueueJob(new invoicePostProcessingForDirectCorp(directCorpInvoiceIdSet));
                //Start PD-0040/UD-3207 27-Apr-2016 Added by S.Puli
                if(!Test.isRunningTest()){
                    invoicePostProcessingForDirectCorp inv = new invoicePostProcessingForDirectCorp(directCorpInvoiceIdSet); 
                }
                //End PD-0040/UD-3207 27-Apr-2016 Added by S.Puli
                //system.debug(':::jobID' + ' ' + jobID);
                //END UD-3676 RReyes - change method call
            }
            //END UD-3491 9Jan16 FrancisBenzon : synced class in dv1 as new logic for payment creation added.
            //END UD-3002 12/11/2015 Added by J.Sarion - enqueue job for invoicePostProcessingForDirectCorp
        }
        // End HotFix 15Jun15 JohnD - added logic for credit balance adjustment
    }
    public void bulkBefore() {

    }
    
    public void beforeInsert(SObject so) {
      
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
       
    }
    
    public void beforeDelete(SObject so) {
        
    }
    
    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {
        
    }
    
}