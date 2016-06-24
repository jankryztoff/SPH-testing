/*
 * Class Name: BT_AT_ARM069DX_OutstandingAmountInt_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - ARM069DX Interface
 * @description A test class for BT_AT_ARM069DX_OutstandingAmountInterface 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest
private class BT_AT_ARM069DX_OutstandingAmountInt_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
  /*APRIL  static testMethod void testInterfaceApexTrigger()
    {
        List<BT_CO_ARMS_OutstandingAmountInterface__c> interfaceRecordList = new List<BT_CO_ARMS_OutstandingAmountInterface__c>();
        
        BT_CO_ARMS_OutstandingAmountInterface__c interfaceRecord = new BT_CO_ARMS_OutstandingAmountInterface__c();
        interfaceRecord.Name = 'ARM069DX';
        interfaceRecord.accountNumber__c ='3431123330'; // '1';
        interfaceRecord.synonym__c = '2';
        interfaceRecord.totalBadDebtAmount__c = '3';
        interfaceRecord.totalOutstandingAmount__c = '4';
        //interfaceRecord.totalOverdueAmount__c = '5';
        
        interfaceRecordList.add(interfaceRecord);
        
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    APRIL*/
    static testMethod void testInterfaceApexTrigger2()
    {
    //    List<BT_CO_ARMS_OutstandingAmountInterface__c> interfaceRecordList = new List<BT_CO_ARMS_OutstandingAmountInterface__c>();
        //list<Zuora__CustomerAccount__c> ZuoraAccountList = new list<Zuora__CustomerAccount__c>();
     //   List<Account> accList = new List<Account>();
        Test.startTest();
        BT_CO_ARMS_OutstandingAmountInterface__c interfaceRecord = new BT_CO_ARMS_OutstandingAmountInterface__c();
        interfaceRecord.Name = 'ARM069DX';
        interfaceRecord.accountNumber__c = '3431123330'; // '1';
        interfaceRecord.Validation_Status__c = 'Passed';
        interfaceRecord.totalBadDebtAmount__c = '3';
        interfaceRecord.totalOutstandingAmount__c = '4';
        interfaceRecord.creditBalance__c = '10000';
        //interfaceRecord.totalOverdueAmount__c = '5'
        insert interfaceRecord;
       
        //create Account Records
        
        
        List<Account> accList= TestDataFactory.createAccount(2, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        accList[0].Generate_Account_Number__c = true;
        
        accList[1].NRIC__c = 'T7654321R';
        accList[1].Generate_Account_Number__c = true;
        
      //  accList[2].NRIC__c = 'T1234765R';
        
        insert accList;
        
        Zuora__CustomerAccount__c ZuoraAccountRecord = new Zuora__CustomerAccount__c();
        ZuoraAccountRecord.ARMS_Account_Number__c = '3431123330';
        ZuoraAccountRecord.Zuora__Account__c = accList[0].id;
        ZuoraAccountRecord.Zuora__Credit_Balance__c = 1;
        //ZuoraAccountList.add(ZuoraAccountRecord);        
        insert ZuoraAccountRecord ;   
        
        Account accQ = [SELECT Account_Auto_Number__c FROM Account WHERE id=:accList[0].Id];     
        
        
        interfaceRecord.synonym__c = accQ.Account_Auto_Number__c;
        
        update interfaceRecord; 
        
        //interfaceRecordList.add(interfaceRecord);
            
        
       // insert interfaceRecord;       // insert interfaceRecordList; 
        Test.stopTest();
    }
}