/*
 * Class Name: BT_AT_ARM064DX_2_CreateCustAccount_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - ARM064DX_2 Interface
 * @description A test class for BT_AT_ARM064DX_2_CreateCustAccountResponseFile 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest
private class BT_AT_ARM064DX_2_CreateCustAccount_Test
{   
            /* @description This method executes during class instantiation.  
            * @param SC a ScheduleContext which is a predefined parameter
            * @return void
            */
            static testMethod void testInterfaceApexTriggerForTrueValidation()
            {
            
                        BT_CO_ARMS_CreateCustAccountFile__c custBatchRecord = new BT_CO_ARMS_CreateCustAccountFile__c();
                        custBatchRecord.Status__c = 'sent';
                        custBatchRecord.Name = 'Test 1';
                        custBatchRecord.Unique_Key__c = '11212';
                        insert custBatchRecord;
                        
                        
                        
                        List<BT_CO_ARMS_CreateCustAccountResponseFile__c> interfaceRecordList = new List<BT_CO_ARMS_CreateCustAccountResponseFile__c>();
                        
                        BT_CO_ARMS_CreateCustAccountResponseFile__c interfaceRecord = new BT_CO_ARMS_CreateCustAccountResponseFile__c();
                        interfaceRecord.Name = 'ARM064DX_2';
                        interfaceRecord.accountCreationDate__c = '08122014';
                        interfaceRecord.accountNumber__c = '2';
                        interfaceRecord.blacklistColourCode__c = '3';
                        interfaceRecord.blacklistIndicator__c = '4';
                        interfaceRecord.blacklistReason__c = '5';
                        interfaceRecord.ccrId__c = '6';
                        interfaceRecord.creditRiskRating__c = '7';
                        interfaceRecord.customerCreateDate__c = '20141128';
                        interfaceRecord.returnMessage__c = '9';
                        interfaceRecord.returnStatus__c = '1';
                        interfaceRecord.synonym__c = '11';
                        interfaceRecord.uniqueKey__c = 'efdfdfdfd';
                        interfaceRecordList.add(interfaceRecord); 
                        
                        Test.startTest();
                        insert interfaceRecordList;
                        Test.stopTest();
            }
            
      /*      static testMethod void testInterfaceApexTrigger()
            {
            
                        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
                        acct.AccountNUmber = 'BA-00000150';
                        insert acct;
                        
                        Zuora__CustomerAccount__c bAccount = TestDataFactory.createBillingAccount(1)[0];
                        bAccount.Zuora__Account__c = acct.id;
                        bAccount.Zuora__AccountNumber__c = 'BA-00000150'; 
                        insert bAccount;
                       
                        BT_CO_ARMS_CreateCustAccountFile__c custBatchRecord = new BT_CO_ARMS_CreateCustAccountFile__c();
                        custBatchRecord.Status__c = 'sent';
                        custBatchRecord.Name = 'Test 1';
                        custBatchRecord.Unique_Key__c = '11212';
                        insert custBatchRecord;
                        
                        List<BT_CO_ARMS_CreateCustAccountResponseFile__c> interfaceRecordList = new List<BT_CO_ARMS_CreateCustAccountResponseFile__c>();
                        
                        BT_CO_ARMS_CreateCustAccountResponseFile__c interfaceRecord = new BT_CO_ARMS_CreateCustAccountResponseFile__c();
                        interfaceRecord.Name = 'ARM064DX_2';
                        interfaceRecord.accountCreationDate__c = '08122014';
                        interfaceRecord.accountNumber__c = '2';
                        interfaceRecord.blacklistColourCode__c = '3';
                        interfaceRecord.blacklistIndicator__c = '4';
                        interfaceRecord.blacklistReason__c = '5';
                        interfaceRecord.ccrId__c = '6';
                        interfaceRecord.creditRiskRating__c = '7';
                        interfaceRecord.customerCreateDate__c = '20141128';
                        interfaceRecord.returnMessage__c = '9';
                        interfaceRecord.returnStatus__c = '0';
                        interfaceRecord.synonym__c = '11';
                        interfaceRecord.uniqueKey__c = 'BA-00000150';
                        
                        interfaceRecordList.add(interfaceRecord);
                        
                        Test.startTest();
                        insert interfaceRecordList;
                        Test.stopTest();
            }
            */
            static testMethod void testInterfaceApexTriggerForFailedValidation()
            {
            
                        Test.startTest();
                        
                        BT_CO_ARMS_CreateCustAccountFile__c custBatchRecord = new BT_CO_ARMS_CreateCustAccountFile__c();
                        custBatchRecord.Status__c = 'Failed';
                        custBatchRecord.Name = 'Test 1';
                        custBatchRecord.Unique_Key__c = '11212';
                        insert custBatchRecord;
                        
                        
                        List<BT_CO_ARMS_CreateCustAccountResponseFile__c> interfaceRecordList = new List<BT_CO_ARMS_CreateCustAccountResponseFile__c>();
                        
                        BT_CO_ARMS_CreateCustAccountResponseFile__c interfaceRecord = new BT_CO_ARMS_CreateCustAccountResponseFile__c();
                        interfaceRecord.Name = 'fdfdfdf';
                        interfaceRecord.accountCreationDate__c = '08122014';
                        interfaceRecord.accountNumber__c = '5678';
                        interfaceRecord.blacklistColourCode__c = '45';
                        interfaceRecord.blacklistIndicator__c = '6';
                        interfaceRecord.blacklistReason__c = 'efd';
                        interfaceRecord.ccrId__c = 'fdfd';
                        interfaceRecord.creditRiskRating__c = 'cvcv';
                        interfaceRecord.customerCreateDate__c = '09872013';
                        interfaceRecord.returnMessage__c = 'vcvcx';
                        interfaceRecord.returnStatus__c = '2';
                        interfaceRecord.synonym__c = 'cvxvxv';
                        interfaceRecord.uniqueKey__c = '1234';
                        
                        interfaceRecordList.add(interfaceRecord);
                        try{     
                        
                        insert interfaceRecordList;
                        
                        }
                        catch(DmlException de)
                        {
                        Boolean isValid= false;
                        
                        }
                        
                        Test.stopTest();
            }
            static testMethod void testInterfaceApexTriggerApril()
            {
                       
                        BT_CO_ARMS_CreateCustAccountFile__c custBatchRecord = new BT_CO_ARMS_CreateCustAccountFile__c();
                        custBatchRecord.Status__c = 'sent';
                        custBatchRecord.Name = 'Test 1';
                        custBatchRecord.Unique_Key__c = '11212';
                        insert custBatchRecord;
                        
                       // List<BT_CO_ARMS_CreateCustAccountResponseFile__c> interfaceRecordList = new List<BT_CO_ARMS_CreateCustAccountResponseFile__c>();
                        
                        BT_CO_ARMS_CreateCustAccountResponseFile__c interfaceRecord = new BT_CO_ARMS_CreateCustAccountResponseFile__c();
                        interfaceRecord.Name = 'ARM064DX_2';
                      /*  interfaceRecord.accountCreationDate__c = '08122014';
                        interfaceRecord.accountNumber__c = '2';
                        interfaceRecord.blacklistColourCode__c = '3';
                        interfaceRecord.blacklistIndicator__c = '4';
                        interfaceRecord.blacklistReason__c = '5';
                        interfaceRecord.creditRiskRating__c = '7';
                        interfaceRecord.customerCreateDate__c = '20141128';
                        interfaceRecord.returnMessage__c = '9';
                        interfaceRecord.returnStatus__c = '1';
                        interfaceRecord.synonym__c = '11';*/
                        interfaceRecord.ccrId__c = '6';
                        interfaceRecord.uniqueKey__c = 'BA-00000150';
                       
                        Test.startTest();
                        database.insert(interfaceRecord);
                        //interfaceRecordList.add(interfaceRecord); 
                        
                        List<Account> acct = TestDataFactory.createAccount(2,'Direct Corporate');
                        acct[0].AccountNUmber = 'BA-00000150';
                        acct[1].AccountNUmber = 'BA-00000150';
                        //acct[0].Generate_Account_Number__c = true;
                        //acct[1].Generate_Account_Number__c = true;
                        insert acct;
                        System.assertNotEquals(null, acct[0].AccountNUmber);
                            
                              
                        List<Zuora__CustomerAccount__c> bAccount = TestDataFactory.createBillingAccount(2);
                        bAccount[0].Zuora__Account__c = acct[0].id;
                        bAccount[0].Other_PaymentMethod__c = 'Invoice';
                        //bAccount[0].Zuora__AccountNumber__c = 'BA-00000150'; 
                        bAccount[1].Zuora__Account__c = acct[1].id;
                        bAccount[0].Other_PaymentMethod__c = 'Invoice';
                       // bAccount[1].Zuora__AccountNumber__c = 'BA-00000150'; 
                        insert bAccount;
                       
                       Test.stopTest(); 
             
            }
            static testMethod void testInterfaceApexTriggerApril2()
            {
                       
                        BT_CO_ARMS_CreateCustAccountFile__c custBatchRecord = new BT_CO_ARMS_CreateCustAccountFile__c();
                        custBatchRecord.Status__c = 'sent';
                        custBatchRecord.Name = 'Test 1';
                        custBatchRecord.Unique_Key__c = '11212';
                        insert custBatchRecord;
                        
                        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
                        //acct[0].AccountNUmber = 'BA-00000159';
                       // acct[1].AccountNUmber = 'BA-00000159';
                        acct.Generate_Account_Number__c = true;
                        //acct[1].Generate_Account_Number__c = true;
                        insert acct;
                        System.assertNotEquals(null, acct.AccountNUmber);
                        
                        
                      /*  interfaceRecord.uniqueKey__c = ''+acct[0].AccountNUmber;
                        update  interfaceRecord;  */        
                        
                        Account var1 = [SELECT AccountNUmber from Account Where ID =: acct.id];     
                              
                        Zuora__CustomerAccount__c bAccount = TestDataFactory.createBillingAccount(1)[0];
                        bAccount.Zuora__Account__c = var1.id;
                        bAccount.Other_PaymentMethod__c = 'Invoice';
                        /*bAccount[0].Zuora__AccountNumber__c = 'BA-00000150'; 
                        bAccount[1].Zuora__Account__c = acct[1].id;
                        bAccount[0].Other_PaymentMethod__c = 'Invoice';
                       // bAccount[1].Zuora__AccountNumber__c = 'BA-00000150'; */
                        insert bAccount;
                       // List<BT_CO_ARMS_CreateCustAccountResponseFile__c> interfaceRecordList = new List<BT_CO_ARMS_CreateCustAccountResponseFile__c>();
                        
                        
                        
                        BT_CO_ARMS_CreateCustAccountResponseFile__c interfaceRecord = new BT_CO_ARMS_CreateCustAccountResponseFile__c();
                        interfaceRecord.Name = 'ARM064DX_2';
                      /*  interfaceRecord.accountCreationDate__c = '08122014';
                        interfaceRecord.accountNumber__c = 'BA-00000159';
                        interfaceRecord.blacklistColourCode__c = '3';
                        interfaceRecord.blacklistIndicator__c = '4';
                        interfaceRecord.blacklistReason__c = '5';
                        interfaceRecord.creditRiskRating__c = '7';
                        interfaceRecord.customerCreateDate__c = '20141128';
                        interfaceRecord.returnMessage__c = '9';
                        interfaceRecord.synonym__c = '11';*/
                        interfaceRecord.ccrId__c = '6';
                        interfaceRecord.returnStatus__c = '1';
                        interfaceRecord.uniqueKey__c = ''+ var1.AccountNUmber; //'BA-00000159';
                       
                        Test.startTest();
                        database.insert(interfaceRecord);
                        //interfaceRecordList.add(interfaceRecord); 
                        
                        
                       
                       Test.stopTest(); 
         
            }
           static testMethod void testInterfaceApexTriggerApril3()
            {
                       
                        BT_CO_ARMS_CreateCustAccountFile__c custBatchRecord = new BT_CO_ARMS_CreateCustAccountFile__c();
                        custBatchRecord.Status__c = 'sent';
                        custBatchRecord.Name = 'Test 1';
                        custBatchRecord.Unique_Key__c = '11212';
                        insert custBatchRecord;
                        
                        Account acct = TestDataFactory.createAccount(1,'Direct Corporate')[0];
                        //acct[0].AccountNUmber = 'BA-00000159';
                       // acct[1].AccountNUmber = 'BA-00000159';
                        acct.Generate_Account_Number__c = true;
                        //acct[1].Generate_Account_Number__c = true;
                        insert acct;
                        System.assertNotEquals(null, acct.AccountNUmber);
                        
                        
                      /*  interfaceRecord.uniqueKey__c = ''+acct[0].AccountNUmber;
                        update  interfaceRecord;  */        
                        
                        Account var1 = [SELECT AccountNUmber from Account Where ID =: acct.id];     
                              
                        Zuora__CustomerAccount__c bAccount = TestDataFactory.createBillingAccount(1)[0];
                        bAccount.Zuora__Account__c = var1.id;
                        bAccount.Other_PaymentMethod__c = 'Invoice';
                        /*bAccount[0].Zuora__AccountNumber__c = 'BA-00000150'; 
                        bAccount[1].Zuora__Account__c = acct[1].id;
                        bAccount[0].Other_PaymentMethod__c = 'Invoice';
                       // bAccount[1].Zuora__AccountNumber__c = 'BA-00000150'; */
                        insert bAccount;
                       // List<BT_CO_ARMS_CreateCustAccountResponseFile__c> interfaceRecordList = new List<BT_CO_ARMS_CreateCustAccountResponseFile__c>();
                        
                        
                        
                        BT_CO_ARMS_CreateCustAccountResponseFile__c interfaceRecord = new BT_CO_ARMS_CreateCustAccountResponseFile__c();
                        interfaceRecord.Name = 'ARM064DX_2';
                        interfaceRecord.accountCreationDate__c = '08122014';
                        interfaceRecord.accountNumber__c = '000159';
                        interfaceRecord.blacklistColourCode__c = '3';
                        interfaceRecord.blacklistIndicator__c = '4';
                        interfaceRecord.blacklistReason__c = '5';
                        interfaceRecord.creditRiskRating__c = '7';
                        interfaceRecord.customerCreateDate__c = '20141128';
                        interfaceRecord.returnMessage__c = '9';
                        interfaceRecord.synonym__c = '11';
                        interfaceRecord.ccrId__c = '6';
                        interfaceRecord.returnStatus__c = '0';
                        interfaceRecord.uniqueKey__c = ''+ var1.AccountNUmber; //'BA-00000159';
                       
                        Test.startTest();
                        database.insert(interfaceRecord);
                        //interfaceRecordList.add(interfaceRecord); 
                        
                        
                       
                       Test.stopTest(); 
         
            }
 }