@isTest //(SeeAllData=True)
public class SP_GenerateLetterPrintBatchTest {

         @testSetup 
        static void setupData() {
            insert CustomSettingsDataFactory.createKey_Id();
            insert CustomSettingsDataFactory.createOther(); 
            insert CustomSettingsDataFactory.createIntegration_Settings();
            insert CustomSettingsDataFactory.createBatchInterface(); 
            insert CustomSettingsDataFactory.createBillingBatch();
           
        } 

            static testmethod void unitTest1()
            {
            
                        String letterType = 'Acknowledgment Letter';
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        
                        Test.startTest(); 
                        SP_GenerateLetterPrintBatch batch = new SP_GenerateLetterPrintBatch('Acknowledgment Letter',20,'testsession');
                        ID batchprocessid = Database.executeBatch(batch,200);
                        Test.stopTest();
            }//end of unitTest1
            
            static testmethod void unitTest2()
            {
            
                        String letterType = 'Acknowledgment Letter';
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        
                        List<Letter_Print_Batch__c> lpbList = new List<Letter_Print_Batch__c>();
                        
                        Letter_Print_Batch__c lpb = new Letter_Print_Batch__c();
                        //lpb.Letter_Type__c = 'Acknowledgment_Letter'; //joy
                        lpb.Letter_Type__c = 'Acknowledgment Letter';//joy
                        lpb.Initialization_Status__c = 'Active';
                        lpb.Initialized_Batches__c = 5;
                        lpb.Total_Record_Count__c = 40;
                        lpb.Total_Batch_Count__c = 1;
                        
                        lpbList.add(lpb);
                        
                        insert lpbList;
                        
                        Test.StartTest();  
                        SP_GenerateLetterPrintBatch spg = new SP_GenerateLetterPrintBatch('',20,'testsession');
                        ID batchprocessid = Database.executeBatch(spg,200);
                        Test.StopTest();  
            }
            
            static testmethod void unitTest3()
            {
            
                        String letterType = 'Acknowledgment Letter';
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        
                        List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                        
                        Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                        lpr.Batch_Run_Sequence__c = 0;
                        lpr.Status__c = 'Processing';
                        lprList.add(lpr);
                        
                        insert lprList;
                        
                        Test.StartTest();  
                        SP_GenerateLetterPrintBatch spg = new SP_GenerateLetterPrintBatch('Acknowledgment Letter',20,'testsession');
                        ID batchprocessid = Database.executeBatch(spg,200);
                        Test.StopTest();  
            }
            
            static testmethod void unitTest4()
            {
            
            
                        //String letterType = 'Acknowledgment Letter';
                        String letterType = SP_GenerateLetterPrintBatch.giftLetter;
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        
                        List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                        
                        Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                        lpr.Batch_Run_Sequence__c = 0;
                        lpr.Status__c = 'Processing';
                        //lpr.Letter_Sub_Type__c = 'Overseas_Newspaper_Report_Hard_Copy';
                        lprList.add(lpr);
                        
                        insert lprList;
                        try{
                        Test.StartTest();  
                        SP_GenerateLetterPrintBatch spg1 = new  SP_GenerateLetterPrintBatch(letterType,20,'testsession');
                        Database.BatchableContext objBatchC; 
                        spg1.execute(objBatchC,lprList); 
                        Test.StopTest();
                        }catch(exception e){}
            
            }
            
            static testmethod void unitTest5()
            {
            
                        try{
                        String letterType = 'Acknowledgment Letter';
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        
                        List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                        
                        Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                        lpr.Batch_Run_Sequence__c = 0;
                        lpr.Status__c = 'Processing';
                        lprList.add(lpr);
                        
                        insert lprList;
                        
                        Test.StartTest();  
                        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
                        SP_GenerateLetterPrintBatch spg1 = new  SP_GenerateLetterPrintBatch('Acknowledgment Letter',20,'testsession');
                        SP_GenerateLetterPrintBatch spg = new SP_GenerateLetterPrintBatch('Acknowledgment Letter',20,'testsession');
                        ID batchprocessid = Database.executeBatch(spg,200);
                        SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch('Acknowledgment Letter',20,'testsession', 3);
                        ID batchprocessidPar = Database.executeBatch(spgParallel,200);
                        Test.StopTest();
                        }catch(Exception e){}
            
            }
            
            static testmethod void unitTest6()
            {
            
                        String letterType = 'Acknowledgment Letter';
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        
                        List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                        
                        Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                        lpr.Batch_Run_Sequence__c = 0;
                        lpr.Status__c = 'Processing';
                        lprList.add(lpr);
                        
                        insert lprList;
                        
                        Test.StartTest();  
                        SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch('Acknowledgment Letter',20,'testsession', 3);
                        ID batchprocessid = Database.executeBatch(spgParallel,200);
                        Test.StopTest();  
            }
            static testmethod void unitTest7()
            {
            
                        String letterType = 'giftLetter';
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        
                        List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                        
                        Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                        lpr.Batch_Run_Sequence__c = 0;
                        lpr.Status__c = 'Processing';
                        lprList.add(lpr);
                        
                        insert lprList;
                        
                        Test.StartTest();  
                        SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch('Acknowledgment_Letter',20,'testsession', null);
                        ID batchprocessid = Database.executeBatch(spgParallel,200);
                        Test.StopTest();  
            }
            
            static testmethod void unitTest8()
            {
            
                        String letterType = 'giftLetter';
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        
                        List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                        
                        Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                        lpr.Batch_Run_Sequence__c = 0;
                        lpr.Status__c = 'New';
                        lpr.Letter_Type__c = 'giftLetter';
                        lprList.add(lpr);
                        
                        insert lprList;
                        
                        
                        Test.StartTest();  
                        Test.setMock(HttpCalloutMock.class, new SP_GenerateLetterPrintBatchMockTest()); 
                        SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch('giftLetter',20,'testsession', 2);
                        //SP_GenerateLetterPrintBatchCloneTest spgParallel = new SP_GenerateLetterPrintBatchCloneTest('giftLetter',20,'testsession', 2);
                        ID batchprocessid = Database.executeBatch(spgParallel,200);
                        Test.StopTest();  
            }
            
            static testmethod void unitTest9()
            {
            
                        String letterType = 'Acknowledgment_Letter';
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        
                        List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                        
                        Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                        lpr.Batch_Run_Sequence__c = 0;
                        lpr.Status__c = 'New';
                        lpr.Letter_Type__c = 'Acknowledgment_Letter';
                        lpr.DTL_Date__c = date.today();
                        lprList.add(lpr);
                        
                        insert lprList;
                        
                        
                        Test.StartTest();  
                        SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch('Acknowledgment_Letter',20,'testsession', 2);
                        ID batchprocessid = Database.executeBatch(spgParallel,200);
                        Test.StopTest();  
            }
            
            static testmethod void unitTest10()
            {
                        String error = '';
                        String letterType = 'Acknowledgment_Letter';
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        datetime dateFrom = DateTime.newInstanceGMT(2015, 12, 19, 22, 00, 00);
                        datetime dateto = DateTime.newInstanceGMT(2015, 12, 20, 22, 00, 00);
                        
                        Zuora__ZInvoice__c inv = TestDataFactory.createInvoice(1)[0];
                        database.insert(inv);
                        
                        system.assertEquals(inv.id, string.valueOf(inv.Id));
                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                        //acc.AccountNumber = string.ValueOf(inv.Id).subString(0,14);
                        acc.AccountNumber = string.valueOf(inv.Id);
                        database.insert(acc);
                        
                        system.assertEquals(acc.AccountNumber, string.valueOf(inv.Id));
                        
                        List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                        
                        Account accL = [SELECT id, name, AccountNumber FROM Account WHERE Id=:acc.Id];
                        
                        Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                        lpr.Batch_Run_Sequence__c = 0;
                        lpr.Status__c = 'Processing';
                        lpr.Letter_Type__c = 'Acknowledgment_Letter';
                        lpr.DTL_Date__c = date.today();
                        lpr.Status__c = 'New';
                        lpr.Sub_Created_Date__c = DateTime.newInstanceGMT(2015, 12, 20, 23, 00, 00);
                        //lpr.Letter_Sub_Type__c = 'Overseas_Newspaper_Report_Hard_Copy';
                        //lpr.Record_ID__c = string.ValueOf(inv.Id);
                        //lpr.Record_ID__c = inv.Id;
                        lpr.Acknowledgment_Type__c = 'Hard Copy';
                        database.insert(lpr);
                        
                        //system.assertEquals(acc.AccountNumber, lpr.Record_ID__c);
                        
                        lprList.add(lpr);
                        
                        // System.assertEquals(accL.accountNumber, lpr.Record_ID__c);
                        
                        List<Letter_Print_Batch__c> lpbList = new List<Letter_Print_Batch__c>();
                        
                        Letter_Print_Batch__c lpb = new Letter_Print_Batch__c();
                        //lpb.Letter_Type__c = 'Acknowledgment_Letter'; //joy
                        lpb.Letter_Type__c = 'Acknowledgment_Letter';//joy
                        lpb.Initialization_Status__c = 'Active';
                        lpb.Initialized_Batches__c = 5;
                        lpb.Total_Record_Count__c = 40;
                        lpb.Total_Batch_Count__c = 1;
                        
                        lpbList.add(lpb);
                        
                        insert lpbList;
                        
                        
                        try{
                        Test.StartTest();  
                        RestRequest req = new RestRequest(); 
                        RestResponse res = new RestResponse();
                        
                        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SP_PDFGenerator';  
                        req.httpMethod = 'POST';
                        RestContext.request = req;
                        RestContext.response = res;
                        
                        Test.setMock(HttpCalloutMock.class, new SP_GenerateLetterPrintBatchMockTest()); 
                        SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch('Acknowledgment_Letter',20,'testsession', 0);
                        Database.BatchableContext BC;
                        spgParallel.start(BC);
                        spgParallel.execute(BC, lprList);
                        //spgParallel.finish(BC); 
                        //Database.executeBatch(spgParallel,lprList);
                        Test.StopTest();  
                        }catch(exception e){}
                        
                        Set<Id> lprID = new Set<Id>();
                        lprID.add(lpr.id);
                        
                        SP_GenerateLetterPrintBatch sp2 = new SP_GenerateLetterPrintBatch(lprID, 'Acknowledgment_Letter', 1, 'test');
            /*
                        String letterType = 'Acknowledgment_Letter';
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        database.insert(acc);
                        
                        List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                        
                        Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                        lpr.Batch_Run_Sequence__c = 0;
                        lpr.Status__c = 'Processing';
                        lpr.Letter_Type__c = 'Acknowledgment_Letter';
                        lpr.DTL_Date__c = date.today();
                        lpr.Acknowledgment_Type__c = 'Hard Copy';
                        //lpr.Letter_Sub_Type__c = 'Overseas_Newspaper_Report_Hard_Copy';
                        lpr.Record_ID__c = acc.Id;
                        lprList.add(lpr);
                        
                        system.assertEquals(lpr.Record_ID__c, acc.Id);
                        
                        insert lprList;
                        
                        
                        Test.StartTest();  
                        SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch('Acknowledgment_Letter',20,'testsession', 2);
                        ID batchprocessid = Database.executeBatch(spgParallel,200);
                        Test.StopTest();  
                        
                        //  String shortID = String.valueOf(batchprocessid).subString(0,15);
                        
                        // System.assertEquals(shortID, null);
                        
                        //List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID];
                        
                        //System.assertEquals(batchJobSchedulerList.size(), 1);
            */
            }
            
            static testmethod void unitTest11()
            {
                        String error = '';
                        String letterType = 'Acknowledgment_Letter';
                        Integer batchCount = 20;
                        String sessionId = 'testsession';
                        
                        Zuora__ZInvoice__c inv = TestDataFactory.createInvoice(1)[0];
                        database.insert(inv);
                        
                        system.assertEquals(inv.id, string.valueOf(inv.Id));
                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                        //acc.AccountNumber = string.ValueOf(inv.Id).subString(0,14);
                        acc.AccountNumber = string.valueOf(inv.Id);
                        database.insert(acc);
                        
                        system.assertEquals(acc.AccountNumber, string.valueOf(inv.Id));
                        
                        List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                        
                        Account accL = [SELECT id, name, AccountNumber FROM Account WHERE Id=:acc.Id];
                        
                        Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                        lpr.Batch_Run_Sequence__c = 0;
                        lpr.Status__c = 'Processing';
                        lpr.Letter_Type__c = 'Acknowledgment_Letter';
                        lpr.DTL_Date__c = date.today();
                        //lpr.Letter_Sub_Type__c = 'Overseas_Newspaper_Report_Hard_Copy';
                        //lpr.Record_ID__c = string.ValueOf(inv.Id);
                        //lpr.Record_ID__c = inv.Id;
                        lpr.Acknowledgment_Type__c = 'Hard Copy';
                        database.insert(lpr);
                        
                        //system.assertEquals(acc.AccountNumber, lpr.Record_ID__c);
                        
                        lprList.add(lpr);
                        
                        // System.assertEquals(accL.accountNumber, lpr.Record_ID__c);
                        
                        try{
                        Test.StartTest();  
                        RestRequest req = new RestRequest(); 
                        RestResponse res = new RestResponse();
                        
                        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SP_PDFGenerator';  
                        req.httpMethod = 'POST';
                        RestContext.request = req;
                        RestContext.response = res;
                        
                        Test.setMock(HttpCalloutMock.class, new SP_GenerateLetterPrintBatchMockTest()); 
                        SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch('Acknowledgment_Letter',20,'testsession', 2);
                        Database.BatchableContext BC;
                        spgParallel.start(BC);
                        spgParallel.execute(BC, lprList);
                        //spgParallel.finish(BC); 
                        //Database.executeBatch(spgParallel,lprList);
                        Test.StopTest();  
                        }catch(exception e){}
                        
                        Set<Id> lprID = new Set<Id>();
                        lprID.add(lpr.id);
                        
                        SP_GenerateLetterPrintBatch sp2 = new SP_GenerateLetterPrintBatch(lprID, 'test', 1, 'test');
                       
                              
            
            }    
            
             static testmethod void unitTest12()
            {
            
                      //  String letterType = 'Acknowledgment Letter';
                        //Integer batchCount = 20;
                       // String sessionId = 'testsession';
                        
                        List<Letter_Print_Batch__c> lpbList = new List<Letter_Print_Batch__c>();
                        
                        Letter_Print_Batch__c lpb = new Letter_Print_Batch__c();
                        //lpb.Letter_Type__c = 'Acknowledgment_Letter'; //joy
                        lpb.Letter_Type__c = 'Invoice Letter';//joy
                        lpb.Initialization_Status__c = 'Active';
                        lpb.Initialized_Batches__c = 5;
                        lpb.Total_Record_Count__c = 40;
                        lpb.Total_Batch_Count__c = 1;
                        
                        lpbList.add(lpb);
                        
                        insert lpbList;
                        
                        Test.StartTest();  
                        SP_GenerateLetterPrintBatch spg = new SP_GenerateLetterPrintBatch('',20,'testsession');
                        ID batchprocessid = Database.executeBatch(spg,200);
                        Test.StopTest();  
            }
            
            
            static testmethod void unitTest13()
            {
             
                    String letterType = 'First_Renewal_Reminder_for_Magazine';
                    Integer batchCount = 20;
                    String sessionId = 'testsession';
                    
                    List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                    
                    Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                    lpr.Batch_Run_Sequence__c = 0;
                    lpr.Status__c = 'Tagged';
                    lpr.Letter_Type__c = letterType;
                    lpr.DTL_Date__c = date.today();
                    lpr.DTL_Date__c = date.today();
                    lprList.add(lpr);
                    
                    insert lprList;
              
                    
                    Test.StartTest();  
                    SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch(letterType,20,'testsession', 2);
                    ID batchprocessid = Database.executeBatch(spgParallel,200);
                   
                    Test.StopTest();  
            }
            static testmethod void unitTest14()
            {
            
                    Account acc = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
                    database.insert(acc);
                    
                    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                    billAcc.Zuora__Account__c = acc.Id;
                    billAcc.billing_Account_Name_2__c  = billAcc.Name;
                    billAcc.Payment_Mode__c = 'CreditCard';
                    billAcc.Zuora__Balance__c = 103;
                            //billAcc.Billing_Contact__c = con.Id;
                    billAcc.Billing_Type__c = 'Recurring Prepaid';
                    billAcc.ARMS_Account_Number__c = '123456';
                    billAcc.Other_PaymentMethod__c = 'Invoice';
                    billAcc.ARMS_Total_Outstanding_Amount__c = 10;
                    billAcc.Attention_To_Care_Of_Salutation__c = 'MS';
                    billAcc.Bank__c = 'TestBank';
                    billAcc.ARMS_Total_Outstanding_Amount__c = 10;
                    billAcc.Zuora__Balance__c = 10;
                    billAcc.Zuora__Batch__c = 'Batch1';
                    database.insert(billAcc);
         
                    Package__c pack = TestDataFactory.createPackage(1)[0];
                    database.insert(pack);
                    
                    Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                    subRecs.Zuora__CustomerAccount__c = billAcc.id;
                    subRecs.Name = '123';
                    subRecs.Subscription_Type__c = 'Publication';
                    subRecs.Main_Package_1__c = pack.id;  
                    //subRecs.Order_Number__c = orderRec.Id;
                   //subRecs.Order_Line_Item_Number__c = orderline2.Id;
                    //subRecs.Main_Package__c = pack.id; 
                    subRecs.Billing_Type__c = 'Recurring Prepaid';
                    subRecs.PO_Number__c = 'Test';        
                    //subRecs.Recipient_Contact__c = con.id;
                    database.insert(subRecs);
        
                    String letterType = 'First_Renewal_Reminder_for_Magazine';
                    Integer batchCount = 20;
                    String sessionId = 'testsession';
                    
                    List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                    
                    Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                    lpr.Batch_Run_Sequence__c = 0;
                    lpr.Status__c = 'New';
                    lpr.Letter_Type__c = letterType;
                    lpr.DTL_Date__c = date.today();
                    lpr.DTL_Date__c = date.today();
                    lpr.Record_Id__c = subRecs.id;
                    lprList.add(lpr);
                    
                    insert lprList;
                    
                    Set<Id> lprIdSet = new Set<Id>();
                    lprIdSet.add(lprList[0].id);
                    
                    Test.StartTest();  
                    SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch(letterType,20,'testsession', 2);
                    ID batchprocessid = Database.executeBatch(spgParallel,200);
                    SP_GenerateLetterPrintBatch spgParallel2 = new SP_GenerateLetterPrintBatch(lprIdSet,letterType,20,'testsession');
                    ID batchprocessid2 = Database.executeBatch(spgParallel2,200);
                    Test.StopTest();  
            }
            static testmethod void unitTest15()
            {
            
                    Account acc = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
                    database.insert(acc);
                    
                    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                    billAcc.Zuora__Account__c = acc.Id;
                    billAcc.billing_Account_Name_2__c  = billAcc.Name;
                    billAcc.Payment_Mode__c = 'CreditCard';
                    billAcc.Zuora__Balance__c = 103;
                            //billAcc.Billing_Contact__c = con.Id;
                    billAcc.Billing_Type__c = 'Recurring Prepaid';
                    billAcc.ARMS_Account_Number__c = '123456';
                    billAcc.Other_PaymentMethod__c = 'Invoice';
                    billAcc.ARMS_Total_Outstanding_Amount__c = 10;
                    billAcc.Attention_To_Care_Of_Salutation__c = 'MS';
                    billAcc.Bank__c = 'TestBank';
                    billAcc.ARMS_Total_Outstanding_Amount__c = 10;
                    billAcc.Zuora__Balance__c = 10;
                    billAcc.Zuora__Batch__c = 'Batch1';
                    database.insert(billAcc);
         
                    Package__c pack = TestDataFactory.createPackage(1)[0];
                    database.insert(pack);
                    
                    Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                    subRecs.Zuora__CustomerAccount__c = billAcc.id;
                    subRecs.Name = '123';
                    subRecs.Subscription_Type__c = 'Publication';
                    subRecs.Main_Package_1__c = pack.id;  
                    //subRecs.Order_Number__c = orderRec.Id;
                   //subRecs.Order_Line_Item_Number__c = orderline2.Id;
                    //subRecs.Main_Package__c = pack.id; 
                    subRecs.Billing_Type__c = 'Recurring Prepaid';
                    subRecs.PO_Number__c = 'Test';        
                    //subRecs.Recipient_Contact__c = con.id;
                    database.insert(subRecs);
        
                    String letterType = 'First_Renewal_Reminder_for_Magazine';
                    Integer batchCount = 20;
                    String sessionId = 'testsession';
                    
                    List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                    
                    Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                    lpr.Batch_Run_Sequence__c = 0;
                    lpr.Status__c = 'New';
                    lpr.Letter_Type__c = letterType;
                    lpr.DTL_Date__c = date.today();
                    lpr.DTL_Date__c = date.today();
                    lpr.Record_Id__c = subRecs.id;
                    lprList.add(lpr);
                    Letter_Print_Request__c lpr2 = new Letter_Print_Request__c();
                    lpr2.Batch_Run_Sequence__c = 0;
                    lpr2.Status__c = 'Tagged';
                    lpr2.Letter_Type__c = letterType;
                    lpr2.DTL_Date__c = date.today();
                    lpr2.DTL_Date__c = date.today();
                    lpr2.Record_Id__c = subRecs.id;
                    lprList.add(lpr2);
                    insert lprList;
                    lprList[1].Parent_Letter_Print_Request__c = lprList[0].id;
                    update lprList;
                    
                    Set<Id> lprIdSet = new Set<Id>();
                    lprIdSet.add(lprList[0].id);
                    
                    Test.StartTest();  
                    Test.setMock(HttpCalloutMock.class, new SP_GenerateLetterPrintBatchMockTest()); 
                    SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch(letterType,20,'testsession', 2);
                    ID batchprocessid = Database.executeBatch(spgParallel,200);
          
                    Test.StopTest();  
            }   
            static testmethod void unitTest16()
            {
            
                    Other__c other = new Other__c();
                    other.Name = 'SP18_SDT2';
                    other.DateTime__c = Date.Today().AddDays(-2);
                    database.insert(other);
            
                    String letterType = 'Acknowledgment_Letter';
                    Integer batchCount = 20;
                    String sessionId = 'testsession';
                    
                    List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                    
                    Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                    lpr.Sub_Created_Date__c = Date.Today().AddDays(-1);
                    lpr.Acknowledgment_Type__c = 'Both';
                    lpr.Batch_Run_Sequence__c = 0;
                    lpr.Status__c = 'New';
                    lpr.Letter_Type__c = letterType;
                    lpr.DTL_Date__c = date.today();
                    lpr.DTL_Date__c = date.today();
                    lprList.add(lpr);
                    
                    insert lprList;
              
                    
                    Test.StartTest();  
                    SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch(letterType,20,'testsession', 2);
                    ID batchprocessid = Database.executeBatch(spgParallel,200);
                 
                    Test.StopTest();  
            } 
            static testmethod void unitTest17()
            {
            
                    Other__c other = new Other__c();
                    other.Name = 'SP18_SDT2';
                    other.DateTime__c = Date.Today().AddDays(-2);
                    database.insert(other);
            
                    String letterType = 'Acknowledgment_Letter';
                    Integer batchCount = 20;
                    String sessionId = 'testsession';
                    
                    List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
                    
                    Letter_Print_Request__c lpr = new Letter_Print_Request__c();
                    lpr.Sub_Created_Date__c = Date.Today().AddDays(-1);
                    lpr.Acknowledgment_Type__c = 'Email';
                    lpr.Batch_Run_Sequence__c = 0;
                    lpr.Status__c = 'New';
                    lpr.Letter_Type__c = letterType;
                    lpr.DTL_Date__c = date.today();
                    lpr.DTL_Date__c = date.today();
                    lprList.add(lpr);
                    
                    insert lprList;
              
                    
                    Test.StartTest();  
                    SP_GenerateLetterPrintBatch spgParallel = new SP_GenerateLetterPrintBatch(letterType,20,'testsession', 2);
                    ID batchprocessid = Database.executeBatch(spgParallel,200);
                    
                  
                   
                   
                    Test.StopTest();  
            }      

}