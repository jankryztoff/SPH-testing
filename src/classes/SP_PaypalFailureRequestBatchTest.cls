/* April Veloso
   10/16/2015
   Test class for SP_PaypalFailureRequestBatch
*/


@isTest(seeAllData = false)
public class SP_PaypalFailureRequestBatchTest{
        static testmethod void testSP_PaypalFailureRequestBatchtest(){

                    /*Key_Id__c key = new Key_Id__c();
                    key.Name = 'NEXT_RECIPIENT_NUMBER';
                    key.Id__c = '30012551';
                    database.insert(key);*/
                    
                    Other__c other = new Other__c();
                    other.Name = 'SP18_InitializedBatch';
                    other.Value__c = '0';
                    database.insert(other);
                    
                    
                    //String letterType = 'April';
                    Integer batchCount = 200;
                    String sessionId = 'SE123';
                    String strBatch = ConstantsSLB.getOther('SP18_InitializedBatch');
                    
                    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                    insert acc;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
                    Country__c country = TestDataFactory.createCountry(1)[0]; 
                    country.Country_Name__c = 'SINGAPORE'; 
                    insert country;
                    
                    Address__c address = TestDataFactory.createAddress(1)[0];
                    address.Block_House_Number__c =  'TEST';
                    address.Postal_Code__c = postal.id;
                    address.Level_Number__c = '17';
                    address.Unit_Number__c = 'Unit 5';
                    address.Country__c = country.id;
                    insert address;
                    
                    Contact con = TestDataFactory.createContact(1)[0];
                    con.AccountId = acc.Id;
                    con.Address__c = address.id;
                    con.Recipient_Indicator__c = true;
                    insert con;
                    
                    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                    billAcc.Zuora__Account__c = acc.Id;
                    insert billAcc;
                    
                    Zuora__PaymentMethod__c paymentMethod = TestdataFactory.createPaymentMethod(1)[0];
                    paymentMethod.Zuora__Type__c = 'Paypal';
                    paymentMethod.Zuora__BillingAccount__c = billAcc.Id;
                    database.insert(paymentMethod);
                    
                    
                    List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                    billAccountList[0].name = 'April Summer';
                    //billAccountList [0].id = zInv.id;
                    billAccountList[0].Zuora__Account__c = acc.id; 
                    billAccountList[0].Billing_Contact__c = con.id;
                    billAccountList[0].Zuora__Default_Payment_Method__c = paymentMethod.id;
                    insert billAccountList;
                    
                    Zuora__Payment__c paymentRecord = new Zuora__Payment__c();
                    paymentRecord.Zuora__BillingAccount__c = billAccountList[0].id;
                    paymentRecord.Name='TestPayment';
                    paymentRecord.Zuora__Amount__c=100.00;
                    paymentRecord.Zuora__PaymentMethod__c='Payment Method';
                    paymentRecord.Zuora__EffectiveDate__c=date.today();
                    paymentRecord.Zuora__Type__c = 'Electronic';
                    paymentRecord.Zuora__Status__c = 'Error';
                    paymentRecord.Is_PDF_Generated__c = false;
                    database.insert(paymentRecord);
                    
                    External_Payment__c externalPayment = TestDataFactory.createExternalPayment(1)[0];
                    externalPayment.Name = 'External';
                    externalPayment.Transaction_Amount__c = 15.00;
                    externalPayment.Transaction_Date__c = date.today();
                    externalPayment.Account_Name__c = acc.id;
                    externalPayment.Transaction_Type__c = 'F';
                    externalPayment.Billing_Account__c = billAccountList[0].id ;
                    externalPayment.Payment_Type__c = 'Paypal';
                    database.insert(externalPayment);    
                    
                    //List<Zuora__Payment__c> scope = [SELECT Zuora__BillingAccount__c,Zuora__Type__c,Zuora__Status__c,Is_PDF_Generated__c FROM Zuora__Payment__c];
                    BatchInterface_Settings__c batchSettings = new BatchInterface_Settings__c();
                    batchSettings.Name = 'Endpoint Delegator';
                    batchSettings.value__c = 'Endpoint Delegator';
                    database.insert(batchSettings);
                    
                    BATCH_JOB_SCHEDULER__c batchJob = new BATCH_JOB_SCHEDULER__c();
                    batchJob.Batch_Code__c = 'SP045';
                    batchJob.Status__c = 'SUCCESS';
                    batchJob.Batch_Run_Date__c = date.today();
                    database.insert(batchJob);
                    Test.setCreatedDate(batchJob.Id, date.today() - 1);
                    
                    Letter_Print_Request__c letterPrint = new Letter_Print_Request__c ();
                    letterPrint.Letter_Type__c = SP_GenerateLetterPrintBatch.FAILED_PAYPAL_NOTIFICATION;
                    letterPrint.Status__c = SP_GenerateLetterPrintBatch.newValue;
                    letterPrint.Batch_Run_Sequence__c = 3;
                    database.insert(letterPrint);
                    
                    List<External_Payment__c> scope = [SELECT Id, Name, Transaction_Amount__c,Transaction_Date__c,Account_Name__c,
                    Transaction_Type__c,Billing_Account__c, Payment_Type__c from External_Payment__c where id =: externalPayment.id];
                    
                    Set<Id> paymentIds = new Set<Id>();
                    paymentIds.add(paymentRecord.Id);
                    
                    Test.startTest();
                    Database.BatchableContext BC;
                    
                    SP_PaypalFailureRequestBatch batch = new SP_PaypalFailureRequestBatch('letter_type',batchCount,sessionId);
                    ID batchprocessid = Database.executeBatch(batch,200);
                    System.assertNotEquals(null, batchprocessid);
                    batch.execute(BC,scope);
                    SP_PaypalFailureRequestBatch batch2 = new SP_PaypalFailureRequestBatch('letter_type',batchCount,sessionId, paymentIds);
                    ID batchprocessid2 = Database.executeBatch(batch2,200);
                    System.assertNotEquals(null, batchprocessid2);
                    batch2.execute(BC,scope);
                    Test.stopTest();
                    
        }
        static testmethod void testbatchJobSchedulerListsizeisZero(){

                    /*Key_Id__c key = new Key_Id__c();
                    key.Name = 'NEXT_RECIPIENT_NUMBER';
                    key.Id__c = '30012551';
                    database.insert(key);*/
                    
                    Other__c other = new Other__c();
                    other.Name = 'SP18_InitializedBatch';
                    other.Value__c = '0';
                    database.insert(other);
                    
                    Integer batchCount = 200;
                    String sessionId = 'SE123';
                    String strBatch = ConstantsSLB.getOther('SP18_InitializedBatch');
                    
                    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                    insert acc;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
                    Country__c country = TestDataFactory.createCountry(1)[0]; 
                    country.Country_Name__c = 'SINGAPORE'; 
                    insert country;
                    
                    Address__c address = TestDataFactory.createAddress(1)[0];
                    address.Block_House_Number__c =  'TEST';
                    address.Postal_Code__c = postal.id;
                    address.Level_Number__c = '17';
                    address.Unit_Number__c = 'Unit 5';
                    address.Country__c = country.id;
                    insert address;
                    
                    Contact con = TestDataFactory.createContact(1)[0];
                    con.AccountId = acc.Id;
                    con.Address__c = address.id;
                    con.Recipient_Indicator__c = true;
                    insert con;
                    
                    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                    billAcc.Zuora__Account__c = acc.Id;
                    insert billAcc;
                    
                    Zuora__PaymentMethod__c paymentMethod = TestdataFactory.createPaymentMethod(1)[0];
                    paymentMethod.Zuora__Type__c = 'Paypal';
                    paymentMethod.Zuora__BillingAccount__c = billAcc.Id;
                    database.insert(paymentMethod);
                    
                    
                    List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                    billAccountList[0].name = 'April Summer';
                    billAccountList[0].Zuora__Account__c = acc.id; 
                    billAccountList[0].Billing_Contact__c = con.id;
                    billAccountList[0].Zuora__Default_Payment_Method__c = paymentMethod.id;
                    insert billAccountList;
                    
                    Zuora__Payment__c paymentRecord = new Zuora__Payment__c();
                    paymentRecord.Zuora__BillingAccount__c = billAccountList[0].id;
                    paymentRecord.Name='TestPayment';
                    paymentRecord.Zuora__Amount__c=100.00;
                    paymentRecord.Zuora__PaymentMethod__c='Payment Method';
                    paymentRecord.Zuora__EffectiveDate__c=date.today();
                    paymentRecord.Zuora__Type__c = 'Electronic';
                    paymentRecord.Zuora__Status__c = 'Error';
                    paymentRecord.Is_PDF_Generated__c = false;
                    database.insert(paymentRecord);
                    
                    External_Payment__c externalPayment = TestDataFactory.createExternalPayment(1)[0];
                    externalPayment.Name = 'External';
                    externalPayment.Transaction_Amount__c = 15.00;
                    externalPayment.Transaction_Date__c = date.today();
                    externalPayment.Account_Name__c = acc.id;
                    externalPayment.Transaction_Type__c = 'F';
                    externalPayment.Billing_Account__c = billAccountList[0].id ;
                    externalPayment.Payment_Type__c = 'Paypal';
                    database.insert(externalPayment);    
                    
                    //List<Zuora__Payment__c> scope = [SELECT Zuora__BillingAccount__c,Zuora__Type__c,Zuora__Status__c,Is_PDF_Generated__c FROM Zuora__Payment__c];
                    BatchInterface_Settings__c batchSettings = new BatchInterface_Settings__c();
                    batchSettings.Name = 'Endpoint Delegator';
                    batchSettings.value__c = 'Endpoint Delegator';
                    database.insert(batchSettings);
                                        
                    Letter_Print_Request__c letterPrint = new Letter_Print_Request__c ();
                    letterPrint.Letter_Type__c = SP_GenerateLetterPrintBatch.FAILED_PAYPAL_NOTIFICATION;
                    letterPrint.Status__c = SP_GenerateLetterPrintBatch.newValue;
                    letterPrint.Batch_Run_Sequence__c = 3;
                    database.insert(letterPrint);
                    
                    List<External_Payment__c> scope = [SELECT Id, Name, Transaction_Amount__c,Transaction_Date__c,Account_Name__c,
                    Transaction_Type__c,Billing_Account__c, Payment_Type__c from External_Payment__c where id =: externalPayment.id];
                    
                    Set<Id> paymentIds = new Set<Id>();
                    paymentIds.add(paymentRecord.Id);
                    
                    Test.startTest();
                    Database.BatchableContext BC;
                    SP_PaypalFailureRequestBatch batch = new SP_PaypalFailureRequestBatch('letter_type',batchCount,sessionId);
                    ID batchprocessid = Database.executeBatch(batch,200);
                    System.assertNotEquals(null, batchprocessid);
                    batch.execute(BC,scope);
                    SP_PaypalFailureRequestBatch batch2 = new SP_PaypalFailureRequestBatch('letter_type',batchCount,sessionId, paymentIds);
                    ID batchprocessid2 = Database.executeBatch(batch2,200);
                    System.assertNotEquals(null, batchprocessid2);
                    batch2.execute(BC,scope);
                    Test.stopTest();
         }
                   
}