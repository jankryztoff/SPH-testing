@isTest
private class SP_CreditCardFailureRequestBatchTest2{
    static testMethod void testSP_CreditCardFailureRequestBatch(){
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='SP18_InitializedBatch', Value__c='0')        
            };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
    
        List<External_Payment__c> exPayment = TestDataFactory.createExternalPayment(2);
        for(External_Payment__c ex: exPayment){
            ex.Transaction_Type__c = 'F';
            ex.Billing_Account__c = billAcc.Id;
        }
        database.insert(exPayment);
        
        Set<Id> extPaymentIds = new Set<Id>();
        for(External_Payment__c ex : exPayment){
            extPaymentIds.add(ex.Id);
        }
    
        test.startTest();
            try{
                SP_CreditCardFailureRequestBatch batch = new SP_CreditCardFailureRequestBatch('', 2, '', extPaymentIds, date.today());
                //ID batchID = database.executeBatch(batch, 200);
                Database.BatchableContext bc;
                batch.start(bc);
                batch.execute(bc, exPayment);
                batch.finish(bc);
            
            }
            catch(Exception e){} // no jobID for testing purposes
            
             try{
                            
                SP_CreditCardFailureRequestBatch batch = new SP_CreditCardFailureRequestBatch('', 2, '', extPaymentIds, null);
                //ID batchID = database.executeBatch(batch, 200);
                Database.BatchableContext bc;
                batch.start(bc);
                batch.execute(bc, exPayment);
                batch.finish(bc);
                
            }
            catch(Exception e){} // no jobID for testing purposes
            
             try{
               
                SP_CreditCardFailureRequestBatch batch = new SP_CreditCardFailureRequestBatch('', 2, '', null, null);
                //ID batchID = database.executeBatch(batch, 200);
                Database.BatchableContext bc;
                batch.start(bc);
                batch.execute(bc, exPayment);
                batch.finish(bc);
            }
            catch(Exception e){} // no jobID for testing purposes
        test.stopTest();
    }
}