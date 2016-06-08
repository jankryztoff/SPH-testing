/*
 * Class Name: UpdateBillingContactNameTest
 * @author: Reyes, Rom Edison C.
 * Date: 04/07/2016
 * Project/Requirement: SPH :'(
 * @description : Test Class for UpdateBillingContactName class
 */
@isTest (seeAllData= True)
private class UpdateBillingContactNameTest{

    static testMethod void testUpdateZuoraBillingContact(){

        Id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'TEST';
            acc.AccountNumber = '123456789';
            insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
        
        Zone__c testZone = new Zone__c();
            testZone.Name = '648';
            testZone.Zone_Name_External_Id__c = 'tst135';
            insert testZone;
        
        Country__c testCountry = new Country__c();
            testCountry.Name = 'USA';
            testCountry.Account__c = acc.id;
            testCountry.Code__c = '6A12';
            testCountry.Country_Name__c = 'Canada';
            testCountry.Zone__c = testZone.id;
            testCountry.Zonal_Code__c = '648';
            insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.RecordTypeId = rtAdd;
            addressRec.Country__c = testCountry.id;
            insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');
        
        Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            insert con;
            
        Test.StartTest();
            UpdateBillingContactName updateBCName = new UpdateBillingContactName();

            updateBCName.response = 'response';
            String res = updateBCName.response;
            UpdateBillingContactName.updateZuoraBillingContact('FirstName', 'LastName', string.valueof(con.id));
        Test.StopTest();    
    }

    static testMethod void testUpdateZuoraBillingContactError(){

        Id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'TEST';
            acc.AccountNumber = '123456789';
            insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
        
        Zone__c testZone = new Zone__c();
            testZone.Name = '648';
            testZone.Zone_Name_External_Id__c = 'tst135';
            insert testZone;
        
        Country__c testCountry = new Country__c();
            testCountry.Name = 'USA';
            testCountry.Account__c = acc.id;
            testCountry.Code__c = '6A12';
            testCountry.Country_Name__c = 'Canada';
            testCountry.Zone__c = testZone.id;
            testCountry.Zonal_Code__c = '648';
            insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.RecordTypeId = rtAdd;
            addressRec.Country__c = testCountry.id;
            insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');
        
        Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            insert con;
            
        Test.StartTest();
            UpdateBillingContactName updateBCName = new UpdateBillingContactName();

            updateBCName.response = 'response';
            String res = updateBCName.response;
            UpdateBillingContactName.updateZuoraBillingContact('FirstName', 'LastName', string.valueof(con.id));
            UpdateBillingContactName.isTrue = false;
        Test.StopTest();    
    }

    static testMethod void testUpdateZuoraBillingAccount(){

        Id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'TEST';
            acc.AccountNumber = '123456789';
            insert acc;

        Test.StartTest();
            UpdateBillingContactName updateBCName = new UpdateBillingContactName();

            updateBCName.response = 'response';
            String res = updateBCName.response;
            UpdateBillingContactName.updateZuoraBillingAccount('LastName', string.valueof(acc.id));
        Test.StopTest();    
    }

    static testMethod void testUpdateZuoraBillingAccountError(){

        Id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'TEST';
            acc.AccountNumber = '123456789';
            insert acc;

        Test.StartTest();
            UpdateBillingContactName updateBCName = new UpdateBillingContactName();

            updateBCName.response = 'response';
            String res = updateBCName.response;
            UpdateBillingContactName.updateZuoraBillingAccount('LastName', string.valueof(acc.id));
            UpdateBillingContactName.isTrue = false;
        Test.StopTest();    
    }
}