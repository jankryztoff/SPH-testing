/**
Class Name: BT_AB_ARM066DX_UpdateAccountBatchTest
@author: Accenture IDC (Sudha Kumari)
Date: 02/10/2015
Project/Requirement: SPH Integration - ARM063DX Interface 
@description This class is test class for BT_AB_ARM063DX_UpdateAccountBatch
*/
@isTest(seeAllData=false)
private class BT_AB_ARM066DX_UpdateAccountBatchTest {
    static testmethod void testAccounts(){
        BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;
       Test.StartTest();        
       BT_CO_ARMS_UpdateAccountBatchFile__c newRecord =  new BT_CO_ARMS_UpdateAccountBatchFile__c();
       newrecord.Status__c = 'New';
       newRecord.Name  =  'testName';                                                                                
       insert newRecord;
       BT_AB_ARM066DX_UpdateAccountBatch batch  = new BT_AB_ARM066DX_UpdateAccountBatch();
       Database.executeBatch(batch, 201)     ;
       Test.StopTest();
    }
}