/**
Class Name: BT_AB_ARM063DX_CreateAccountBatchTest
@author: Accenture IDC (Sudha Kumari)
Date: 02/10/2015
Project/Requirement: SPH Integration - ARM063DX Interface 
@description This class is test class for BT_AB_ARM063DX_CreateAccountBatch
*/
@isTest(seeAllData=false)
private class BT_AB_ARM063DX_CreateAccountBatchTest {
    static testmethod void testAccounts(){
        BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;
        BT_CO_ARMS_CreateAccountBatchFile__c newRecord =  new BT_CO_ARMS_CreateAccountBatchFile__c();
        newrecord.Status__c = 'New';
        newRecord.Name = 'testName';                                                                                
        insert newRecord;
        Test.StartTest();
        BT_AB_ARM063DX_CreateAccountBatch batch  = new BT_AB_ARM063DX_CreateAccountBatch();
        Database.executeBatch(batch, 200)     ;
        Test.StopTest();
    }
    static testmethod void testAccounts1(){
        BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;
        BT_CO_ARMS_CreateAccountBatchFile__c newRecord =  new BT_CO_ARMS_CreateAccountBatchFile__c();
        newrecord.Status__c = 'New';
        newRecord.Name = 'testName';                                                                                
        insert newRecord;
        Test.StartTest();
        BT_AB_ARM063DX_CreateAccountBatch batch  = new BT_AB_ARM063DX_CreateAccountBatch();
        Database.executeBatch(batch, 200)     ;
        Test.StopTest();
    }
}