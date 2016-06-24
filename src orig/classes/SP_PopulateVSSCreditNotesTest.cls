/**
 * Class Name: SP_PopulateVSSCreditNotesTest
 * @author: Kirk Yngwie Enriquez
 * Date: 2015/07/02
 * Requirement/Project Name: N/A
 * @description This class will test SP_PopulateVSSCreditNotes.
 *
 */
 @isTest(seeAllData = true)
 private class SP_PopulateVSSCreditNotesTest{
     
     static testmethod void test_SP_PopulateVSSCreditNotesDateToday(){
     
         try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            
             Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
             insert acc;
             
             Order__c ord = TestDataFactory.createOrder(1)[0];
             ord.Account__c = acc.id;
             insert ord;
         
             Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
             billAcc.Zuora__Account__c = acc.id;
             insert billAcc;
             
             Package__c pack = TestDataFactory.createPackage(1)[0];
             insert pack;
             
             Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
             ordLineItem.Order__c = ord.id;
             ordLineItem.Main_Package_ID__c = pack.id;
             insert ordLineItem;
         
             List<Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
             subscription[0].Subscription_Type__c = 'Publication';
             subscription[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
             subscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
             subscription[0].Zuora__CustomerAccount__c = billAcc.id;
             subscription[0].Number_of_Copies__c = 1;
             subscription[0].Number_of_Copies1__c = '1';
             subscription[0].Order_Line_Item_Number_1__c = ordLineItem.id;
             subscription[0].Order_Line_Item_Number__c = ordLineItem.id;
             insert subscription;
             
             System.assertNotEquals(null, subscription[0].id);
            
             BT_CO_VSS_CreditDebit__c creditDebit = new BT_CO_VSS_CreditDebit__c();
             creditDebit.Job_Id__c = 'SP002';
             creditDebit.Vendor_Number__c = '12345';
             creditDebit.Note_Number__c = null;
             creditDebit.Credit_Debit__c = 'D';
             creditDebit.Commission__c = 20.90;
             creditDebit.Pagination__c = 20.90;
             creditDebit.Insertion__c = 20.90;
             creditDebit.Delivery__c = 20.90;
             creditDebit.Manual_Amt__c = 20.90;
             creditDebit.Subscription__c = subscription[0].id;
             creditDebit.Posting_Date__c = Date.today();
             creditDebit.Vendor_Group__c = 'X';
             insert creditDebit;
             
             System.assertNotEquals(null, creditDebit.id);
             
             Test.startTest();
             SP_PopulateVSSCreditNotes batch = new SP_PopulateVSSCreditNotes('SP002', creditDebit.id);
             ID batchprocessid = Database.executeBatch(batch,1);
             System.assertNotEquals(null, batchprocessid);
             Test.stopTest();
             
         }catch(Zuora.zRemoteException e) {}  
     }
     
     static testmethod void test_SP_PopulateVSSCreditNotesDateStartOfMonth(){
     
         try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            
             Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
             insert acc;
             
             Order__c ord = TestDataFactory.createOrder(1)[0];
             ord.Account__c = acc.id;
             insert ord;
         
             Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
             billAcc.Zuora__Account__c = acc.id;
             insert billAcc;
             
             Package__c pack = TestDataFactory.createPackage(1)[0];
             insert pack;
             
             Order_Line_Item__c ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
             ordLineItem.Order__c = ord.id;
             ordLineItem.Main_Package_ID__c = pack.id;
             insert ordLineItem;
         
             List<Zuora__Subscription__c> subscription = TestDataFactory.createSubscription(1);
             subscription[0].Subscription_Type__c = 'Publication';
             subscription[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
             subscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
             subscription[0].Zuora__CustomerAccount__c = billAcc.id;
             subscription[0].Number_of_Copies__c = 1;
             subscription[0].Number_of_Copies1__c = '1';
             subscription[0].Order_Line_Item_Number_1__c = ordLineItem.id;
             subscription[0].Order_Line_Item_Number__c = ordLineItem.id;
             insert subscription;
             
             System.assertNotEquals(null, subscription[0].id);
             
             BT_CO_VSS_CreditDebit__c creditDebit = new BT_CO_VSS_CreditDebit__c();
             creditDebit.Job_Id__c = 'SP002';
             creditDebit.Vendor_Number__c = '12345';
             creditDebit.Note_Number__c = null;
             creditDebit.Credit_Debit__c = 'D';
             creditDebit.Commission__c = 20.90;
             creditDebit.Pagination__c = 20.90;
             creditDebit.Insertion__c = 20.90;
             creditDebit.Delivery__c = 20.90;
             creditDebit.Manual_Amt__c = 20.90;
             creditDebit.Subscription__c = subscription[0].id;
             creditDebit.Posting_Date__c = Date.today();
             creditDebit.Vendor_Group__c = 'X';
             insert creditDebit;
             
             System.assertNotEquals(null, creditDebit.id);
             
             Test.startTest();
             SP_PopulateVSSCreditNotes batch = new SP_PopulateVSSCreditNotes('SP001', creditDebit.id);
             ID batchprocessid = Database.executeBatch(batch,1);
             System.assertNotEquals(null, batchprocessid);
             Test.stopTest();
             
         }catch(Zuora.zRemoteException e) {}  
     }
 }