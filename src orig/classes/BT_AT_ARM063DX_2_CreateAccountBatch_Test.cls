/*
 * Class Name: BT_AT_ARM063DX_2_CreateAccountBatch_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - ARM063DX_2 Interface
 * @description A test class for BT_AT_ARM063DX_2_CreateAccountBatchResonseFile 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest
private class BT_AT_ARM063DX_2_CreateAccountBatch_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {
        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        insert acct;
        
        Zuora__CustomerAccount__c bAccount = TestDataFactory.createBillingAccount(1)[0];
        bAccount.Zuora__Account__c = acct.id;
        insert bAccount;
        String ccrID;
        for(Zuora__CustomerAccount__c zBillingAccount : [SELECT Id, Billing_Account_Auto_Number__c FROM Zuora__CustomerAccount__c WHERE Id =: bAccount.Id Limit 1]){
            ccrID = zBillingAccount.Billing_Account_Auto_Number__c;    
        }
        

        BT_CO_ARMS_CreateAccountBatchFile__c accBatchRecord = new BT_CO_ARMS_CreateAccountBatchFile__c();
        accBatchRecord.Status__c = 'sent';
        accBatchRecord.Name = 'Test 1';
        accBatchRecord.CCRID__c = ccrID;
        insert accBatchRecord;
        
        List<BT_CO_ARMS_CreateAccountBatchResonseFile__c> interfaceRecordList = new List<BT_CO_ARMS_CreateAccountBatchResonseFile__c>();
       
        BT_CO_ARMS_CreateAccountBatchResonseFile__c interfaceRecord2 = new BT_CO_ARMS_CreateAccountBatchResonseFile__c();
        interfaceRecord2.Name = 'AMS063DX_3';
        interfaceRecord2.accountCreationDate__c = '20141131';
        interfaceRecord2.accountNumber__c = '4';
        interfaceRecord2.ccrId__c = ccrID;
        interfaceRecord2.returnMessage__c = '4';
        interfaceRecord2.returnStatus__c = '0';
        interfaceRecord2.creditLimitInternal__c = '0.2';
        interfaceRecord2.creditLimitExternal__c = '0.3';
        interfaceRecord2.approvedDebtExposureAmount__c = '3.2';
        interfaceRecordList.add(interfaceRecord2);
        BT_CO_ARMS_CreateAccountBatchResonseFile__c interfaceRecord = new BT_CO_ARMS_CreateAccountBatchResonseFile__c();
        Test.startTest();
        insert interfaceRecordList;
        System.AssertEquals(ccrID, interfaceRecord2.ccrId__c);

        Test.stopTest();
    }
    static testMethod void testInterfaceApexTrigger2()
    {
        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        insert acct;
        
        Zuora__CustomerAccount__c bAccount = TestDataFactory.createBillingAccount(1)[0];
        bAccount.Zuora__Account__c = acct.id;
        insert bAccount;
        String ccrID;
        for(Zuora__CustomerAccount__c zBillingAccount : [SELECT Id, Billing_Account_Auto_Number__c FROM Zuora__CustomerAccount__c WHERE Id =: bAccount.Id Limit 1]){
            ccrID = zBillingAccount.Billing_Account_Auto_Number__c;    
        }
        

        BT_CO_ARMS_CreateAccountBatchFile__c accBatchRecord = new BT_CO_ARMS_CreateAccountBatchFile__c();
        accBatchRecord.Status__c = 'sent';
        accBatchRecord.Name = 'Test 1';
        accBatchRecord.CCRID__c = ccrID;
        insert accBatchRecord;
        
        List<BT_CO_ARMS_CreateAccountBatchResonseFile__c> interfaceRecordList = new List<BT_CO_ARMS_CreateAccountBatchResonseFile__c>();
       
        BT_CO_ARMS_CreateAccountBatchResonseFile__c interfaceRecord2 = new BT_CO_ARMS_CreateAccountBatchResonseFile__c();
        interfaceRecord2.Name = 'AMS063DX_3';
        interfaceRecord2.accountCreationDate__c = '20141131';
        interfaceRecord2.accountNumber__c = '4';
        interfaceRecord2.ccrId__c = ccrID;
        interfaceRecord2.returnMessage__c = '4';
        interfaceRecord2.returnStatus__c = '0';
        interfaceRecord2.creditLimitInternal__c = ' ';
        interfaceRecord2.creditLimitExternal__c = '0.3';
        interfaceRecord2.approvedDebtExposureAmount__c = '3.2';
        interfaceRecordList.add(interfaceRecord2);
        BT_CO_ARMS_CreateAccountBatchResonseFile__c interfaceRecord = new BT_CO_ARMS_CreateAccountBatchResonseFile__c();
        Test.startTest();
        insert interfaceRecordList;
        System.AssertEquals(ccrID, interfaceRecord2.ccrId__c);

        Test.stopTest();
    }
    
    
    /* @description This method is test for class BT_AT_ARM063DX_2_CreateAccountBatchResonseFile   
     * @author Kalidass Gujar  Date: 20-2-2015
     */ 
    static testMethod void createAccountBatchResonseFileTest(){
        
        
        List <Account> testAccount = TestDataFactory.createAccount(1, 'Mailing_Agent');
        insert testAccount;
        
        
        Zuora__CustomerAccount__c a = new Zuora__CustomerAccount__c();
        a.Name = 'Test Billing Account';
        a.Zuora__Account__c = testAccount[0].id;
        a.ARMS_Account_Number__c = '1234';
        a.ARMS_Customer_Number__c = '5678';
        
        insert a;
        system.debug('------------------------>>>>>>>>>>>>'+a.Billing_Account_Auto_Number__c);
         
        a = [select Billing_Account_Auto_Number__c from Zuora__CustomerAccount__c where id= :a.id limit 1];
        String ccrid = a.Billing_Account_Auto_Number__c ;
        
        BT_CO_ARMS_CreateAccountBatchFile__c newRecord =  new BT_CO_ARMS_CreateAccountBatchFile__c();
        newrecord.Status__c = 'Sent';
        newRecord.Name = 'testName';
        newRecord.CCRID__c = ccrid;                                                                                 
        insert newRecord;
               
        BT_CO_ARMS_CreateAccountBatchResonseFile__c cabr = new BT_CO_ARMS_CreateAccountBatchResonseFile__c();
        cabr.Name = 'Test';
        cabr.ccrId__c = ccrid;
        cabr.returnStatus__c = '2';
        cabr.accountCreationDate__c = '20150202';
        cabr.creditLimitInternal__c = '45638.5';
        cabr.creditLimitExternal__c = '823763.67';
        cabr.approvedDebtExposureAmount__c = '8972164';
        insert cabr;
        
        BT_CO_ARMS_CreateAccountBatchFile__c cabf1 =  new BT_CO_ARMS_CreateAccountBatchFile__c();
            cabf1.Status__c = 'Sent';
            cabf1.Name = 'testName1';                                                                                
            insert cabf1;
            
            Account acc = new Account();
            acc.Name = 'Test Account';
           // acc.RecordTypeID = '012N00000008ic6';
            
            insert acc;
            
            
            Zuora__CustomerAccount__c a1 = new Zuora__CustomerAccount__c();
            a1.Name = 'Test Billing Account';
            a1.Zuora__Account__c = acc.id;
            a1.ARMS_Account_Number__c = '1234';
            a1.ARMS_Customer_Number__c = '5678';
            
            insert a1;
        
            BT_CO_ARMS_CreateAccountBatchResonseFile__c cabr1 = new BT_CO_ARMS_CreateAccountBatchResonseFile__c();
            cabr1.Name = 'Test1';
            cabr1.ccrId__c = a1.Billing_Account_Auto_Number__c;
            cabr1.returnStatus__c = '';
            cabr1.accountCreationDate__c = '000124';
            cabr1.creditLimitInternal__c = 'abc';
            cabr1.creditLimitExternal__c = 'abc';
            cabr1.approvedDebtExposureAmount__c = 'abc';
            insert cabr1;
        
}

}