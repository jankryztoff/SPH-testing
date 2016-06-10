public with sharing class CreditBalanceAdjustmentCallout {

    @future(callout=true)
    public static void send(set<id> invoiceIdSetParam) {
        
        final integer MAX_RECORD = 50; // Start/End HotFix 15Jun15 JohnD
        list<exception> exceptionList = new list<exception>();  // Start/End HotFix 15Jun15 JohnD
        string startDate = zuora.zUtil.getZuoraDate(date.today());
        list<map<string, object>> listMap = new list<map<string, object>>();
        integer counter = 0;
        string invoiceType;
        
        //START 11May16 VinceCanlas - Adjusted condition to only cover the lines that will throw an exception.
        if (!Test.isRunningTest()) {
            
            Zuora.zApi zApiInstance = new Zuora.zApi();
            zApiInstance.zlogin();
            
        }
        //END 11May16 VinceCanlas - Adjusted condition to only cover the lines that will throw an exception.
        
            for (Zuora__ZInvoice__c invoice : [select Id, Name, Zuora__BillingAccount__r.Zuora__Credit_Balance__c, 
                    Zuora__Balance2__c from Zuora__ZInvoice__c where Id in :invoiceIdSetParam 
                    and Zuora__BillingAccount__r.Other_PaymentMethod__c != :GlobalVariableClass.PAYPAL
                    and Zuora__BillingAccount__r.Other_PaymentMethod__c != :GlobalVariableClass.PAYMENT_MODE_CREDITCARD 
                    and Zuora__BillingAccount__r.Zuora__Credit_Balance__c > 0]) {
                
                counter++;
                
                if (invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c > invoice.Zuora__Balance2__c) {
                    invoiceType = 'Decrease';
                } else {
                    invoiceType = 'Increase';
                }
                
                Map<String,Object> creditAdjustment = new Map<String, Object>(); 
                creditAdjustment.put('SourceTransactionNumber', invoice.Name);
                creditAdjustment.put('Amount', invoice.Zuora__Balance2__c );
                creditAdjustment.put('Type', invoiceType);
                
                listMap.add(creditAdjustment);
                
                if (counter == MAX_RECORD) {
                    
                    ZuoraCallOut creditAdjustmentCallOut = new ZuoraCallOut();
                    
                    try {
                        List<Map<String,String>> resultMap = creditAdjustmentCallOut.loadZObjects(listMap, 'CreditBalanceAdjustment');
                        system.debug('JohnD :: ' + resultMap);
                    } catch (exception e) {
                        system.debug('JohnD :: ' + e);
                        exceptionList.add(e);
                    }
                    
                    listMap.clear();
                    counter = 0;
                }
            }
            
            if (counter > 0) {
                ZuoraCallOut creditAdjustmentCallOut = new ZuoraCallOut();
                
                try {
                    List<Map<String,String>> resultMap = creditAdjustmentCallOut.loadZObjects(listMap, 'CreditBalanceAdjustment');
                    system.debug('JohnD :: ' + resultMap);
                } catch (exception e) {
                    system.debug('JohnD :: ' + e);
                    exceptionList.add(e);
                }           
            }
            
            if (!exceptionList.isEmpty()) {
                ExceptionLogger.log(exceptionList);
            }
        
    }
}