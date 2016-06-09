/**
* Class Name: SP_BatchCreateCreditBalance 
* @author: George Del Rosario
* Date: 3.17.2015
* Requirement/Project Name: SPH
* @description Batch Apex Class to create Payment and  
* @History: Added filter query and zuora callout
* @History: UD-1530 10/06/15 Wenjun + Code Optimization
*/

global class SP_BatchCreateCreditBalance_SA  implements Database.Batchable<sObject>,Database.AllowsCallouts
{   
    global static final String INV = GlobalVariableClass.INVOICE;
    //START KARL UD-1753 7/4/2015 cater External and Internal Charges 
    global static final String ExParties = GlobalVariableClass.EXTERNAL_PARTIES;
    global static final String InCharge = GlobalVariableClass.INTERNAL_CHARGE;
    //END KARL UD-1753 7/4/2015 cater External and Internal Charges 
    global static final String RPrepaid = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    global static final String RPostpaid = GlobalVariableClass.RECURRING_POSTPAID;
    global static final String FPrepaid = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
    global static final String subcriptionStatus = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
    //START UD-1530 10/06/15 Wenjun - Variable Definition 
    global static final String TYPE_PUB = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
    global static final String PMTHD_INV_ID = ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other');
    //END UD-1530 10/06/15 Wenjun
    
    Boolean selectAccountsFlag = false; 
    Set<String> accountNumberSet;
    
    global SP_BatchCreateCreditBalance_SA(Set<String> accountNumberSet){
        this.selectAccountsFlag = true;
        this.accountNumberSet = accountNumberSet;
    }   
    
    //Start Method : define the scope - Get Process invoices to 
    //START UD-1530 10/06/15 Wenjun: Optimize the Scope - filter by BA and Using Sub End Date instead of Status
    //Full Prepaid Subs are already handled in real time
    global Database.QueryLocator start(Database.BatchableContext BC){  
        Date firstDayOfMonth = System.today().toStartOfMonth();
        
        String query = 'SELECT ID,Name,Zuora__Account__c, Billing_Type__c,Zuora__CustomerAccount__c ';
        query       += ' FROM Zuora__Subscription__c WHERE Subscription_Type__c = :TYPE_PUB ';
        //START KARL UD-1753 7/4/2015 cater External and Internal Charges 
        query       += ' AND (Zuora__CustomerAccount__r.Other_PaymentMethod__c =:INV  OR Zuora__CustomerAccount__r.Other_PaymentMethod__c =:ExParties OR Zuora__CustomerAccount__r.Other_PaymentMethod__c =:InCharge)';
        //END KARL UD-1753 7/4/2015 cater External and Internal Charges 
        query       += ' AND (Billing_Type__c =: RPrepaid OR Billing_Type__c =: RPostpaid) ';
        query       += ' AND (Zuora__SubscriptionEndDate__c >= :firstDayOfMonth OR Zuora__SubscriptionEndDate__c = null)';
        
        if(selectAccountsFlag) {
            query += ' AND Zuora__Account__r.AccountNumber IN :accountNumberSet';
        } 
        
        return Database.getQueryLocator(query);
    }
    //END UD-1530 10/06/15 Wenjun
   
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> subList){
        //START UD-1530 10/06/15 Wenjun: Code Optimization
        ZuoraCallOut zCallout = new ZuoraCallOut();
        List<String> billingAccountID = new List<String>();
        Map<String, Object> creditBalance = new Map<String, Object>();
        List<Map<String, Object>> creditBalanceList = new List<Map<String, Object>>();
        Map<String, Object> paymentZ = new Map<String, Object>();
        List<Map<String, Object>> paymentZList = new List<Map<String, Object>>();
        Logger logger = new Logger(SP_BatchCreateCreditBalance.class.getName(),'SP045'); //START END D-1011 MD-28 Wenjun 18/06/15
        
        for (Zuora__Subscription__c subcription  :subList) {
            billingAccountID.add(subcription.Zuora__CustomerAccount__c);  
        }
        //START KARL UD-1753 7/4/2015 cater External and Internal Charges 

        List<Zuora__ZInvoice__c> InvoiceList = [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__Balance__c,Zuora__Account__c,
                            Zuora__BillingAccount__r.Zuora__External_Id__c, Zuora__InvoiceDate__c, Zuora__Balance2__c,
                            Zuora__BillingAccount__r.Zuora__Credit_Balance__c, Zuora__TotalAmount__c ,Zuora__BillingAccount__c,
                            Zuora__BillingAccount__r.Other_PaymentMethod__c, Zuora__GeneratedDate__c,Zuora__BillingAccount__r.Zuora__Balance__c 
                            FROM Zuora__ZInvoice__c WHERE (Zuora__BillingAccount__r.Other_PaymentMethod__c = :INV OR Zuora__BillingAccount__r.Other_PaymentMethod__c =:ExParties OR Zuora__BillingAccount__r.Other_PaymentMethod__c =:InCharge)
                            AND Zuora__BillingAccount__c IN : billingAccountID AND Zuora__Balance2__c > 0 ];
        //END KARL UD-1753 7/4/2015 cater External and Internal Charges 
        //END UD-1530 10/06/15 Wenjun

        for (Zuora__ZInvoice__c invoice : InvoiceList) {   
            //START UD-1530 10/06/15 Wenjun: Payment Method ID shall be Invoice instead of Cash
            String startDate = zuora.zUtil.getZuoraDate(date.today());
            //END UD-1530 10/06/15 Wenjun
          
            //START D-2570 03-24-2015 Marvin Gatchalian - Re-initialize MAP
            paymentZ = new Map<String, Object>();
            creditBalance = new Map<String, Object>();
            //END D-2570 03-24-2015 Marvin Gatchalian - Re-initialize MAP
             
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
                    //END MD-52 03/22/2015 George Del Rosario - change the field related to the condition
                    creditBalance.put('SourceTransactionNumber', invoice.Name);                    
                    creditBalance.put('Amount',  invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c);                                   
                    creditBalance.put('Type', 'Decrease');                    
                    creditBalanceList.add(creditBalance);

                    paymentZ.put('AccountId', invoice.Zuora__BillingAccount__r.Zuora__External_Id__c );
                    paymentZ.put('Amount', invoice.Zuora__Balance2__c-invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c);
                    paymentZ.put('Type', 'External');
                    paymentZ.put('EffectiveDate', startDate);
                    paymentZ.put('PaymentMethodId', PMTHD_INV_ID); //START END UD-1530 10/06/15 Wenjun
                    paymentZ.put('InvoiceNumber' , invoice.Name);  
                    paymentZ.put('Status', 'Processed');
                    paymentZ.put('AppliedCreditBalanceAmount', 0);
                    paymentZ.put('AppliedInvoiceAmount', invoice.Zuora__TotalAmount__c - invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c);
                    paymentZList.add(paymentZ);
                    //START MD-52 03/22/2015 George Del Rosario - change the field related to the condition
                }else {
                  system.debug ('------- : catch');
                }
                     //END MD-52 03/22/2015 George Del Rosario - change the field related to the condition
                   
             }else if(invoice.Zuora__BillingAccount__r.Zuora__Credit_Balance__c == 0 && invoice.Zuora__BillingAccount__r.Zuora__Balance__c >0) {
                    paymentZ.put('AccountId', invoice.Zuora__BillingAccount__r.Zuora__External_Id__c );
                    paymentZ.put('Amount', invoice.Zuora__TotalAmount__c );
                    paymentZ.put('Type', 'External');
                    paymentZ.put('EffectiveDate', startDate);
                    paymentZ.put('PaymentMethodId', PMTHD_INV_ID); //START END UD-1530 10/06/15 Wenjun
                    paymentZ.put('InvoiceNumber' , invoice.Name);  
                    paymentZ.put('Status', 'Processed');
                    paymentZ.put('AppliedInvoiceAmount', invoice.Zuora__Balance2__c);
                    paymentZList.add(paymentZ);
                
            }else {
              system.debug ('------ : Do nothing');
            }
        }                           
        
        try {                                                 
                 List<Map<String,String>> resultMap = zCallout.loadZObjects(creditBalanceList, 'CreditBalanceAdjustment');
                 for(Map<String,String> result :resultMap){
                      if(result.get('Status') == 'Success') {                      
                            system.debug('~~~~~~ : SUCCESS CREDIT BALANCE'); 
                        }
                        else {
                             //START D-1011 MD-28 Wenjun 18/06/15 - Using Logger
                             //system.debug('~~~~~~ : Failed CREDIT BALANCE');                       
                             logger.log(false,result.get('Message'));
                             //END D-1011 MD-28 Wenjun 18/06/15                                                                  
                        } 
                }                          
            } catch (exception ze) {
                //START MD-28 Wenjun 18/06/15 - Using Logger
                logger.log(ze);
                //END MD-28 Wenjun 18/06/15
            }

            try {   
                    List<Map<String,String>> resultMap = zCallout.loadZObjects(paymentZList, 'Payment');
                     for(Map<String,String> result :resultMap){
                          if(result.get('Status') == 'Success') {                      
                                system.debug('~~~~~~ : SUCCESS PAYMENT'); 
                            }
                            else {
                                //START D-1011 MD-28 Wenjun 18/06/15 - Using Logger
                                logger.log(false,result.get('Message'));
                                //END D-1011 MD-28 Wenjun 18/06/15                                                                  
                            } 
                     }
                } catch (exception ze) {
                      //START D-1011 MD-28 Wenjun 18/06/15 - Using Logger
                      logger.log(ze);
                      //END D-1011 MD-28 Wenjun 18/06/15
                }
    }
    
    global void finish (Database.BatchableContext BC){ 
        //START UD-1530 10/06/15 Wenjun: Code Optimization
        BatchJobHelper.updateJobStatus(BC.getJobId());
        //END UD-1530 10/06/15 Wenjun
    }
}