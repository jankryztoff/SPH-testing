/**
* Class Name: SP_BatchCreateCreditBalance 
* @author: George Del Rosario
* Date: 3.17.2015
* Requirement/Project Name: SPH
* @description Batch Apex Class to create Payment and  
* @history : Added filter query and zuora callout
*/

global class SP_BatchCreateCreditBalanceDummy 
{   
    
       
    public void execute(List<Zuora__Subscription__c> subList){
         ZuoraCallOut zCallout = new ZuoraCallOut();
         List<String> billingAccountID = new List<String>();
         Map<String, Object> creditBalance = new Map<String, Object>();
         List<Map<String, Object>> creditBalanceList = new List<Map<String, Object>>();
         Map<String, Object> paymentZ = new Map<String, Object>();
         List<Map<String, Object>> paymentZList = new List<Map<String, Object>>();

         //-----------
         System.debug('---------------- Subcription List size : ' + subList.size() );
         //-----------        
         //
         //-----------
         System.debug('---------------- Subcription List size : ' + subList );
         //----------- 
        
        for (Zuora__Subscription__c subcription  :subList) {
            billingAccountID.add(subcription.Zuora__CustomerAccount__c);
        }

       List<Zuora__ZInvoice__c> InvoiceList = [SELECT Id,Zuora__Zuora_Id__c,Zuora__Balance__c,Name,Zuora__BillingAccount__r.Zuora__External_Id__c,Zuora__InvoiceDate__c,Zuora__BillingAccount__r.Zuora__Credit_Balance__c,Zuora__Balance2__c, Zuora__TotalAmount__c ,Zuora__BillingAccount__c, Zuora__BillingAccount__r.Other_PaymentMethod__c , Zuora__Account__c, Zuora__GeneratedDate__c
                                               ,Zuora__BillingAccount__r.Zuora__Balance__c 
                                               FROM Zuora__ZInvoice__c 
                                                    WHERE Zuora__BillingAccount__r.Other_PaymentMethod__c = 'Invoice'
                                                        AND Zuora__BillingAccount__c IN : billingAccountID
                                                           AND Zuora__Balance2__c > 0];
          
        //-----------
         System.debug('---------------- Invoice List size : ' + InvoiceList.size());
         //-----------

        for (Zuora__ZInvoice__c invoice : InvoiceList) {   
           
            
            String startDate;
            String cashId;
            cashId = ConstantsSLB.getKeyId('PaymentMethodId_Cash');
            startDate = zuora.zUtil.getZuoraDate(date.today());
            
          
            paymentZ = new Map<String, Object>();
            creditBalance = new Map<String, Object>();
            if (invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c > 0){
                system.debug('------------SourceTransactionNumber' + invoice.Name+ '--' +invoice.Zuora__Balance2__c+ '--' + invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c); 
                  //START MD-52 03/22/2015 George Del Rosario - change the field realted to the condition
                if(invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c == invoice.Zuora__Balance2__c){
                  //END  MD-52 03/22/2015 George Del Rosario - re-change the field realted to the condition
                    creditBalance.put('SourceTransactionNumber', invoice.Name);                    
                    creditBalance.put('Amount',  invoice.Zuora__Balance2__c);                                   
                    creditBalance.put('Type', 'Decrease');                    
                    creditBalanceList.add(creditBalance); 
                  //START MD-52 03/22/2015 George Del Rosario - re-change the field realted to the condition
                }else if (invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c > invoice.Zuora__Balance2__c){
                   //END  MD-52 03/22/2015 George Del Rosario - change the field realted to the condition
                    creditBalance.put('SourceTransactionNumber', invoice.Name);                    
                    creditBalance.put('Amount',  invoice.Zuora__Balance2__c);                                   
                    creditBalance.put('Type', 'Decrease');                    
                    creditBalanceList.add(creditBalance);
                    
                    //START MD-52 03/22/2015 George Del Rosario - change the field realted to the condition 
                }else if (invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c < invoice.Zuora__BillingAccount__r.Zuora__Balance__c){
                    //END MD-52 03/22/2015 George Del Rosario - change the field realted to the condition
                    creditBalance.put('SourceTransactionNumber', invoice.Name);                    
                    creditBalance.put('Amount',  invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c);                                   
                    creditBalance.put('Type', 'Decrease');                    
                    creditBalanceList.add(creditBalance);

                    system.debug('INV >>>> CB < IB ' + invoice.Name);
                    
                    paymentZ.put('AccountId', invoice.Zuora__BillingAccount__r.Zuora__External_Id__c );
                    paymentZ.put('Amount', invoice.Zuora__Balance2__c-invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c);
                    paymentZ.put('Type', 'External');
                    paymentZ.put('EffectiveDate', startDate);
                    paymentZ.put('PaymentMethodId', cashId  );
                    paymentZ.put('InvoiceNumber' , invoice.Name);  
                    paymentZ.put('Status', 'Processed');
                    paymentZ.put('AppliedCreditBalanceAmount', 0);
                    paymentZ.put('AppliedInvoiceAmount', invoice.Zuora__TotalAmount__c - invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c);
                    paymentZList.add(paymentZ);
                    //START MD-52 03/22/2015 George Del Rosario - change the field realted to the condition
                }else {
                  system.debug ('------- : catch');
                }
                     //END MD-52 03/22/2015 George Del Rosario - change the field realted to the condition
                   
             }else if(invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c == 0 && invoice.Zuora__BillingAccount__r.Zuora__Balance__c >0) {
                    system.debug('INV CB = 0 and IB > 0 >>>> ' + invoice.Name);

                    paymentZ.put('AccountId', invoice.Zuora__BillingAccount__r.Zuora__External_Id__c );
                    paymentZ.put('Amount', invoice.Zuora__TotalAmount__c );
                    paymentZ.put('Type', 'External');
                    paymentZ.put('EffectiveDate', startDate);
                    paymentZ.put('PaymentMethodId', cashId );
                    paymentZ.put('InvoiceNumber' , invoice.Name);  
                    paymentZ.put('Status', 'Processed');
                    paymentZ.put('AppliedInvoiceAmount', invoice.Zuora__Balance2__c);
                    paymentZList.add(paymentZ);
                
                }else {
                  system.debug ('------ : Do nothing');
                }
                    
             
        }             
            
            Integer myCounter1;
            myCounter1 = 0;
            for (Map<String, Object> eachPaymentZ :paymentZList) {
                myCounter1 = myCounter1 +1;
                system.debug ('Invoice Name >>>> ' + myCounter1 + '--' + eachPaymentZ.get('InvoiceNumber'));
                system.debug ('Invoice Name >>>> ' + myCounter1 + '--' + eachPaymentZ.get('AccountId'));
                system.debug ('>>>> ' + paymentZList);
            }

   
             try {   
                                                                      
                     List<Map<String,String>> resultMap = zCallout.loadZObjects(creditBalanceList, 'CreditBalanceAdjustment');
                     for(Map<String,String> result :resultMap){
                              if(result.get('Status') == 'Success') {                      
                                    system.debug('~~~~~~ : SUCCESS CREDIT BALANCE'); 
                                }
                                else {
                                    system.debug('~~~~~~ : Failed CREDIT BALANCE');                       
                                    system.debug('Message : ' + result.get('Message'));                                                                  
                                } 
                           }                          
                } catch (exception ze) {
                    ApexPages.addMessages(ze);
                }
        
            
        
            try {   
                    List<Map<String,String>> resultMap = zCallout.loadZObjects(paymentZList, 'Payment');
                    system.debug('>>>> MBG' + resultMap);      
                            
        
                    Integer myCounter;
                    myCounter= 0;
                     for(Map<String,String> result :resultMap){
                             myCounter=myCounter+1;
                              if(result.get('Status') == 'Success') {    
                                    system.debug('~~~~~~ : SUCCESS PAYMENT' + myCounter+ ' -- ' ); 
                                }
                                else {
                                    system.debug('~~~~~~ : Failed PAYMENT');                       
                                    system.debug('Message : ' + myCounter+ ' -- ' +  result.get('Message'));                                                                  
                                } 
                           }
                            
                } catch (exception ze) {
                    ApexPages.addMessages(ze);
                }




    }
    
    
    
}