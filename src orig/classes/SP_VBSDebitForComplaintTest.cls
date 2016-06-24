/*
* Class Name: SP_VBSDebitForComplaintTest
* @author: 
* Date: 
* Requirement/Project Name: <SPH>
* @description: 
*/
@isTest(seeAllData = true)
private class SP_VBSDebitForComplaintTest{
    /*
    static testmethod void testCancelSubForNormalExpiration(){
        Integer count = 0;
        List<Account> accounts = TestDataFactory.createAccount(200, 'Corporate Subscriber');
        RecordType recType = [SELECT Id, Name FROM RecordType WHERE Name='Vendor'LIMIT 1];
        for(Account acnt:accounts){
            acnt.Vendor_Code__c = 'VC'+count;
            acnt.RecordType = recType;
            acnt.Active__c = true;
            count++;
        }
        database.insert(accounts);
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = accounts[0].Id;
        insert defaultPayment;
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = defaultPayment.Id;
        subs.Zuora__Account__c = accounts[0].Id;
        subs.Subscription_Type_1__c = 'Publication';
        subs.Subscription_Type__c = 'Publication';
        database.insert(subs);
        
        System.assertEquals(subs.Subscription_Type_1__c, 'Publication');
        
        count = 0;
        List<BT_CO_VBS_CreditDebit__c> bt_co= TestDataFactory.createBT_CO_VBS_CreditDebit(200);
        for(BT_CO_VBS_CreditDebit__c CD: bt_co){
            CD.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;
            CD.Posting_Date__c = date.today();
            CD.Reason_Code__c = 'D3';
            CD.Vendor_Group__c = 'A';
            CD.Vendor_Number__c = 'VC'+count;
            CD.Job_Id__c = 'ST001';
            CD.Publication_Code__c = 'pubC';
            count++;
        }
        database.insert(bt_co);
        System.assert(!bt_co.isEmpty());
        
        count = 0;
        List<BT_CO_VSS_CreditDebit__c> bt_coVSS = TestDataFactory.createBT_CO_VSS_CreditDebit(200);
        for(BT_CO_VSS_CreditDebit__c bt : bt_coVSS){
            bt.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;
            bt.Posting_Date__c = date.today();
            bt.Vendor_Group__c = 'A';
            bt.Vendor_Number__c = 'VC'+count;
            bt.Job_Id__c = 'ST001';
            bt.Publication_Code__c = 'pubC';
            bt.Manual_Amt__c = 0;
            bt.Subscription__c = subs.Id;
            count++;
        }
        
        database.insert(bt_coVSS);
       
       // System.assertEquals(bt_coVSS.Subscription__r.Subscription_Type_1__c, 'Publication');
    
        BATCH_JOB_SCHEDULER__c job = [SELECT Id, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c LIMIT 1];
        String jobId = job.SFDC_Job_id__c;
        
        Test.StartTest();
        
        SP_VBSDebitForComplaint batch = new SP_VBSDebitForComplaint(jobId);
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
        
        database.batchableContext bc;
        batch.start(bc);
        batch.execute(bc, accounts);
        //finish()
        
        Test.StopTest();
    }
    
    static testmethod void testCancelSubForNormalExpiration2(){
        Integer count = 0;
        List<Account> accounts = TestDataFactory.createAccount(200, 'Corporate Subscriber');
        RecordType recType = [SELECT Id, Name FROM RecordType WHERE Name='Vendor'LIMIT 1];
        for(Account acnt:accounts){
            acnt.Vendor_Code__c = 'VC'+count;
            acnt.RecordType = recType;
            acnt.Active__c = true;
            count++;
        }
        database.insert(accounts);
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = accounts[0].Id;
        insert defaultPayment;
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = defaultPayment.Id;
        subs.Zuora__Account__c = accounts[0].Id;
        subs.Subscription_Type_1__c = 'Publication';
        subs.Subscription_Type__c = 'Publication';
        database.insert(subs);
        
        System.assertEquals(subs.Subscription_Type_1__c, 'Publication');
        
        count = 0;
        List<BT_CO_VBS_CreditDebit__c> bt_co= TestDataFactory.createBT_CO_VBS_CreditDebit(200);
        for(BT_CO_VBS_CreditDebit__c CD: bt_co){
            CD.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;
            CD.Posting_Date__c = date.today();
            CD.Reason_Code__c = '24';
            CD.Vendor_Group__c = 'A';
            CD.Vendor_Number__c = 'VC'+count;
            CD.Job_Id__c = 'ST001';
            CD.Publication_Code__c = 'pubC';
            count++;
        }
        database.insert(bt_co);
        System.assert(!bt_co.isEmpty());
        
        count = 0;
        List<BT_CO_VSS_CreditDebit__c> bt_coVSS = TestDataFactory.createBT_CO_VSS_CreditDebit(200);
        for(BT_CO_VSS_CreditDebit__c bt : bt_coVSS){
            bt.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;
            bt.Posting_Date__c = date.today();
            bt.Vendor_Group__c = 'A';
            bt.Vendor_Number__c = 'VC'+count;
            bt.Job_Id__c = 'ST001';
            bt.Publication_Code__c = 'pubC';
            bt.Manual_Amt__c = 0;
            //bt.Subscription__c = subs.Id;
            count++;
        }
        
        database.insert(bt_coVSS);
       
       // System.assertEquals(bt_coVSS.Subscription__r.Subscription_Type_1__c, 'Publication');
    
        BATCH_JOB_SCHEDULER__c job = [SELECT Id, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c LIMIT 1];
        String jobId = job.SFDC_Job_id__c;
        
        Test.StartTest();
        
        SP_VBSDebitForComplaint batch = new SP_VBSDebitForComplaint(jobId);
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
        
        database.batchableContext bc;
        batch.start(bc);
        batch.execute(bc, accounts);
        //finish()
        
        Test.StopTest();
    }
    
    static testmethod void testCancelSubForNormalExpiration3(){
        Integer count = 0;
        List<Account> accounts = TestDataFactory.createAccount(200, 'Corporate Subscriber');
        RecordType recType = [SELECT Id, Name FROM RecordType WHERE Name='Vendor'LIMIT 1];
        for(Account acnt:accounts){
            acnt.Vendor_Code__c = 'VC'+count;
            acnt.RecordType = recType;
            acnt.Active__c = true;
            count++;
        }
        database.insert(accounts);
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = accounts[0].Id;
        insert defaultPayment;
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = defaultPayment.Id;
        subs.Zuora__Account__c = accounts[0].Id;
        subs.Subscription_Type_1__c = 'Publication';
        subs.Subscription_Type__c = 'Publication';
        database.insert(subs);
        
        System.assertEquals(subs.Subscription_Type_1__c, 'Publication');
        
        count = 0;
        List<BT_CO_VBS_CreditDebit__c> bt_co= TestDataFactory.createBT_CO_VBS_CreditDebit(200);
        for(BT_CO_VBS_CreditDebit__c CD: bt_co){
            CD.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;
            CD.Posting_Date__c = date.today();
            CD.Reason_Code__c = 'D3';
            CD.Vendor_Group__c = 'A';
            CD.Vendor_Number__c = 'VC'+count;
            CD.Job_Id__c = 'ST001';
            CD.Publication_Code__c = 'pubC';
            count++;
        }
        database.insert(bt_co);
        System.assert(!bt_co.isEmpty());
        
        count = 0;
        List<BT_CO_VSS_CreditDebit__c> bt_coVSS = TestDataFactory.createBT_CO_VSS_CreditDebit(200);
        for(BT_CO_VSS_CreditDebit__c bt : bt_coVSS){
            bt.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;
            bt.Posting_Date__c = date.today();
            bt.Vendor_Group__c = 'A';
            bt.Vendor_Number__c = 'VC'+count;
            bt.Job_Id__c = 'ST001';
            bt.Publication_Code__c = 'pubC';
            bt.Manual_Amt__c = 0;
            //bt.Subscription__c = subs.Id;
            count++;
        }
        
        database.insert(bt_coVSS);
       
       // System.assertEquals(bt_coVSS.Subscription__r.Subscription_Type_1__c, 'Publication');
    
        BATCH_JOB_SCHEDULER__c job = [SELECT Id, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c LIMIT 1];
        String jobId = job.SFDC_Job_id__c;
        
        Test.StartTest();
        
        SP_VBSDebitForComplaint batch = new SP_VBSDebitForComplaint(jobId);
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
        
        database.batchableContext bc;
        batch.start(bc);
        batch.execute(bc, accounts);
        //finish()
        
        Test.StopTest();
    }
    
    static testmethod void testCancelSubForNormalExpiration4(){
        Integer count = 0;
        List<Account> accounts = TestDataFactory.createAccount(200, 'Corporate Subscriber');
        RecordType recType = [SELECT Id, Name FROM RecordType WHERE Name='Vendor'LIMIT 1];
        for(Account acnt:accounts){
            acnt.Vendor_Code__c = 'VC'+count;
            acnt.RecordType = recType;
            acnt.Active__c = true;
            count++;
        }
        database.insert(accounts);
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = accounts[0].Id;
        insert defaultPayment;
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = defaultPayment.Id;
        subs.Zuora__Account__c = accounts[0].Id;
        subs.Subscription_Type_1__c = 'Publication';
        subs.Subscription_Type__c = 'Publication';
        database.insert(subs);
        
        System.assertEquals(subs.Subscription_Type_1__c, 'Publication');
        
        count = 0;
        List<BT_CO_VBS_CreditDebit__c> bt_co= TestDataFactory.createBT_CO_VBS_CreditDebit(200);
        for(BT_CO_VBS_CreditDebit__c CD: bt_co){
            CD.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;
            CD.Posting_Date__c = date.today();
            CD.Reason_Code__c = '24';
            CD.Vendor_Group__c = 'A';
            CD.Vendor_Number__c = 'VC'+count;
            CD.Job_Id__c = 'ST001';
            CD.Publication_Code__c = 'pubC';
            count++;
        }
        database.insert(bt_co);
        System.assert(!bt_co.isEmpty());
        
        count = 0;
        List<BT_CO_VSS_CreditDebit__c> bt_coVSS = TestDataFactory.createBT_CO_VSS_CreditDebit(200);
        for(BT_CO_VSS_CreditDebit__c bt : bt_coVSS){
            bt.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;
            bt.Posting_Date__c = date.today();
            bt.Vendor_Group__c = 'A';
            bt.Vendor_Number__c = 'VC'+count;
            bt.Job_Id__c = 'ST001';
            bt.Publication_Code__c = 'pubC';
            bt.Manual_Amt__c = 0;
            bt.Subscription__c = subs.Id;
            count++;
        }
        
        database.insert(bt_coVSS);
       
       // System.assertEquals(bt_coVSS.Subscription__r.Subscription_Type_1__c, 'Publication');
    
        BATCH_JOB_SCHEDULER__c job = [SELECT Id, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c LIMIT 1];
        String jobId = job.SFDC_Job_id__c;
        
        Test.StartTest();
        
        SP_VBSDebitForComplaint batch = new SP_VBSDebitForComplaint(jobId);
        ID batchprocessid = Database.executeBatch(batch);
        System.assertNotEquals(null, batchprocessid);
        
        database.batchableContext bc;
        batch.start(bc);
        batch.execute(bc, accounts);
        //finish()
        
        Test.StopTest();
    }
    */
}