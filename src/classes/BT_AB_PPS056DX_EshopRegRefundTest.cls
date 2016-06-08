/**
Class Name: BT_AB_PPS056DX_EshopRegRefundTest
@author: Accenture IDC (Sudha Kumari)
Date: 02/11/2015
Project/Requirement: SPH Integration - ARM063DX Interface 
@description This class is test class for BT_AB_PPS056DX_EshopRegistrationRefund
**/
@isTest (Seealldata = false)
private class BT_AB_PPS056DX_EshopRegRefundTest {
    static testmethod void eshopRefundTest(){
         BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;
        
        account acc = new account();
        acc.Name='test1';
        insert acc;    
        Zuora__CustomerAccount__c cusAcc = new Zuora__CustomerAccount__c();        
        cusAcc.Zuora__Account__c=acc.id;
        cusAcc.name = 'testcustacc';
        insert cusAcc;       
        Zuora__Refund__c refund = new Zuora__Refund__c();
        refund.Name = 'abc';
        refund.Zuora__Amount__c = 200;
        refund.Zuora__BillingAccount__c = cusAcc.id;
        refund.Status__c = 'new';
        refund.Zuora__RefundMethodType__c = 'Other';

        system.debug('rrrrrrrrr'+acc.Name);
        system.debug('rrrrrrrrrrrrr'+acc);
        system.debug('vvvvvvvvvvvvvvvvv'+cusAcc.Zuora__Account__c);
        system.debug('vvvvvvvvvvvvvvvvv'+cusAcc.name);
        system.debug('vvvvvvvvvvvvvvvvv'+cusAcc);
        system.debug('tttttttttttttttt'+refund);
        system.debug('tttttttttttttttt'+refund.name);
        system.debug('tttttttttttttttt'+refund.zuora__amount__c);
        system.debug('tttttttttttttttt'+refund.Zuora__BillingAccount__c);
        system.debug('tttttttttttttttt'+refund.Zuora__BillingAccount__c);
        insert refund;
        test.startTest();
        BT_AB_PPS056DX_EshopRegistrationRefund erref = new BT_AB_PPS056DX_EshopRegistrationRefund();
        database.executeBatch(erref,200);
        test.stopTest();             
    }
    
    static testmethod void eshopRefundTest2(){
        BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;
            
        account acc = new account();
        acc.Name='test1';
        insert acc;
            
        Zuora__CustomerAccount__c cusAcc = new Zuora__CustomerAccount__c();        
        cusAcc.Zuora__Account__c=acc.id;
        cusAcc.name = 'testcustacc';
        insert cusAcc;
               
        Zuora__Refund__c refund = new Zuora__Refund__c();
        refund.Name = 'abc';
        refund.Zuora__Amount__c = 200;
        refund.Zuora__BillingAccount__c = cusAcc.id;
        refund.Status__c = 'new';
        refund.Zuora__RefundMethodType__c = 'other';
        insert refund;
        
        test.startTest();
        BT_AB_PPS056DX_EshopRegistrationRefund erref = new BT_AB_PPS056DX_EshopRegistrationRefund();
        database.executeBatch(erref,200);
        test.stopTest();             
    }
}