/**
Class Name: BT_AB_PPS056DX_EshopRegRefund_Test 
@author: Emmanuel Flores
Date: 10/23/2015
Project/Requirement: SPH Integration - ARM063DX Interface 
@description This class is test class for BT_AB_PPS056DX_EshopRegistrationRefund
**/
@isTest (Seealldata = TRUE)
private class BT_AB_PPS056DX_EshopRegRefund_Test {

    static testmethod void eshopRefundTest(){

        User user1 = new User(
        Alias = 'Standard',
        Email = 'standarduser@gmail.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'),
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'userstand3541987*@testorg.com'
        );
        
        System.RunAs(user1){

        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate');
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        insert postal;
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        insert country;
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
        address.Block_House_Number__c =  'Block 10';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        address.Address_1__c = 'test';
        address.Address_2__c = 'test';
        address.Address_3__c = 'test';
        address.Address_4__c = 'test';
        insert address;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = address.id;
        con.Recipient_Indicator__c = true;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;
            
        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();        
        billAcc.Zuora__Account__c = acc.id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
               
        Zuora__Refund__c refund = new Zuora__Refund__c();
        refund.Name = 'abc';
        refund.Zuora__Amount__c = 200;
        refund.Zuora__BillingAccount__c = billAcc.id;
        refund.Status__c = 'new';
        refund.Zuora__RefundMethodType__c = 'Check';
        
        test.startTest();
        
        BT_AB_PPS056DX_EshopRegistrationRefund erref = new BT_AB_PPS056DX_EshopRegistrationRefund();
        database.executeBatch(erref,200);
        
        test.stopTest();    
        
        }         
    }
    
    static testmethod void eshopRefundTest2(){

        User user1 = new User(
        Alias = 'Standard',
        Email = 'standarduser@gmail.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'),
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'userstand3541987*@testorg.com'
        );
        
        System.RunAs(user1){

        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        
        Account acc = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        insert postal;
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        insert country;
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
        address.Block_House_Number__c =  'Block 10';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        address.Address_1__c = 'test';
        address.Address_2__c = 'test';
        address.Address_3__c = 'test';
        address.Address_4__c = 'test';
        insert address;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = address.id;
        con.Recipient_Indicator__c = true;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;
            
        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();        
        billAcc.Zuora__Account__c = acc.id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
               
        Zuora__Refund__c refund = new Zuora__Refund__c();
        refund.Name = 'abc';
        refund.Zuora__Amount__c = 200;
        refund.Zuora__BillingAccount__c = billAcc.id;
        refund.Status__c = 'new';
        refund.Zuora__RefundMethodType__c = 'Check';
        insert refund;
        
        test.startTest();
        
        BT_AB_PPS056DX_EshopRegistrationRefund erref = new BT_AB_PPS056DX_EshopRegistrationRefund();
        database.executeBatch(erref,200);
        
        test.stopTest();    
        
        }         
    }
    
    static testmethod void eshopRefundTest3(){

        User user1 = new User(
        Alias = 'Standard',
        Email = 'standarduser@gmail.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'),
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'userstand3541987*@testorg.com'
        );
        
        System.RunAs(user1){

        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        
        Account acc = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        insert postal;
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        insert country;
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        address.Block_House_Number__c =  'Block 10';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        address.Address_1__c = 'test';
        address.Address_2__c = 'test';
        address.Address_3__c = 'test';
        address.Address_4__c = 'test';
        insert address;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = address.id;
        con.Recipient_Indicator__c = true;
        con.HomePhone__c = '1234567890';
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;
            
        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();        
        billAcc.Zuora__Account__c = acc.id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
               
        Zuora__Refund__c refund = new Zuora__Refund__c();
        refund.Name = 'abc';
        refund.Zuora__Amount__c = 200;
        refund.Zuora__BillingAccount__c = billAcc.id;
        refund.Status__c = 'new';
        refund.Zuora__RefundMethodType__c = 'Check';
        insert refund;
        
        test.startTest();
        
        BT_AB_PPS056DX_EshopRegistrationRefund erref = new BT_AB_PPS056DX_EshopRegistrationRefund();
        database.executeBatch(erref,200);
        
        test.stopTest();    
        
        }         
    }
    
    static testmethod void eshopRefundTest4(){

        User user1 = new User(
        Alias = 'Standard',
        Email = 'standarduser@gmail.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'),
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'userstand3541987*@testorg.com'
        );
        
        System.RunAs(user1){

        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Airline_Indicator__c = TRUE;
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        insert postal;
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        insert country;
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
        address.Block_House_Number__c =  'Block 10';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        address.Address_1__c = 'test';
        address.Address_2__c = 'test';
        address.Address_3__c = 'test';
        address.Address_4__c = 'test';
        insert address;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = address.id;
        con.Recipient_Indicator__c = true;
        con.Mobile_Number_2__c = '1234567890';
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;
            
        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();        
        billAcc.Zuora__Account__c = acc.id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
               
        Zuora__Refund__c refund = new Zuora__Refund__c();
        refund.Name = 'abc';
        refund.Zuora__Amount__c = 200;
        refund.Zuora__BillingAccount__c = billAcc.id;
        refund.Status__c = 'new';
        refund.Zuora__RefundMethodType__c = 'Check';
        insert refund;
        
        test.startTest();
        
        BT_AB_PPS056DX_EshopRegistrationRefund erref = new BT_AB_PPS056DX_EshopRegistrationRefund();
        database.executeBatch(erref,200);
        
        test.stopTest();    
        
        }         
    }
    
    static testmethod void eshopRefundTest5(){

        User user1 = new User(
        Alias = 'Standard',
        Email = 'standarduser@gmail.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'),
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'userstand3541987*@testorg.com'
        );
        
        System.RunAs(user1){

        /*BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;*/
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        insert postal;
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        insert country;
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
        address.Block_House_Number__c =  'Block 10';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        address.Address_1__c = 'test';
        address.Address_2__c = 'test';
        address.Address_3__c = 'test';
        address.Address_4__c = 'test';
        insert address;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = address.id;
        con.Recipient_Indicator__c = true;
        con.Mobile_Number__c = '1234567890';
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        insert con;
            
        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();        
        billAcc.Zuora__Account__c = acc.id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
               
        Zuora__Refund__c refund = new Zuora__Refund__c();
        refund.Name = 'abc';
        refund.Zuora__Amount__c = 200;
        refund.Zuora__BillingAccount__c = billAcc.id;
        refund.Status__c = 'new';
        refund.Zuora__RefundMethodType__c = 'Check';
        refund.Payment_Amount__c = 10.00;
        insert refund;
        
        test.startTest();
        
        BT_AB_PPS056DX_EshopRegistrationRefund erref = new BT_AB_PPS056DX_EshopRegistrationRefund();
        database.executeBatch(erref,200);
        
        test.stopTest();    
        
        }         
    }
}