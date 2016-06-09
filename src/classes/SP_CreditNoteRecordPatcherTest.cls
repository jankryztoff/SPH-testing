/*
 * Class Name: SP_CreditNoteRecordPatcher
 * @author: April Grace Judilla
 * Date: 09/01/2015
 * Project/Requirement
 * 
 */ 
@isTest(SeeAllData = true)
public with sharing class SP_CreditNoteRecordPatcherTest {

        static testmethod void testSingleBatchJobScheduler(){
                
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Name = 'Test Account';
            acc.Phone = '123-456';
            acc.Email__c = 'test@test.com';
            acc.Date_of_Birth__c = date.today();
            acc.Gender__c = 'Male';
            acc.Race__c = 'Chinese';
            acc.Language__c = 'Others';
            acc.Contact_Person__c = 'Contact Person';
            acc.Sub_Group__c = 'Freelist(MY)';
            insert acc;
            
            Country__c ctry = TestDataFactory.createCountry(1)[0];
            ctry.Country_Name__c = 'Singapore';
            ctry.Code__c = 'Singapore';
            insert ctry;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '123';
            postal.House_Block_Number__c = 'HB';
            postal.Address_Type__c = 'A';
            postal.Building_Name__c = 'Building';
            postal.Street_Name__c = 'Street';
            insert postal;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='01';
            addressRec.Level_Number__c ='23';
            addressRec.Unit_Number__c = '45';
            addressRec.Country__c = ctry.id;
            insert addressRec; 
    
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            con.FirstName = 'FName';
            con.LastName = 'LName';
            con.Passport__c = 'Passport Test';
            con.HomePhone__c = '123 456';
            con.Mobile_Number__c = '123456';
            con.Email = 'test@test.com';
            insert con;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Contact__c = con.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__AccountNumber__c = 'BA999999';
            insert billAcc;

            Credit_Note__c credNote = new Credit_Note__c(); 
            credNote.Is_PDF_Generated__c = true;
            credNote.To_ARMS_Time__c = null;
            credNote.Billing_Account__c = billAcc.Id;
            insert credNote;
            
            BATCH_JOB_SCHEDULER__c batchJob = new BATCH_JOB_SCHEDULER__c();
            batchJob.Batch_Code__c = 'SP043';
            batchJob.Status__c = 'SUCCESS';
            batchJob.Start_Time__c = date.Today();
            batchJob.Batch_Run_Date__c = date.Today();
            insert batchJob;
            
            SP_CreditNoteRecordPatcher patcher = new SP_CreditNoteRecordPatcher();
            //ID batchprocessid = Database.executeBatch(patcher ,200);
            //System.assertNotEquals(null, batchprocessid);
        }
        
        static testmethod void testNoBatchJobScheduler(){
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Name = 'Test Account';
            acc.Phone = '123-456';
            acc.Email__c = 'test@test.com';
            acc.Date_of_Birth__c = date.today();
            acc.Gender__c = 'Male';
            acc.Race__c = 'Chinese';
            acc.Language__c = 'Others';
            acc.Contact_Person__c = 'Contact Person';
            acc.Sub_Group__c = 'Freelist(MY)';
            insert acc;
            
            Country__c ctry = TestDataFactory.createCountry(1)[0];
            ctry.Country_Name__c = 'Singapore';
            ctry.Code__c = 'Singapore';
            insert ctry;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '123';
            postal.House_Block_Number__c = 'HB';
            postal.Address_Type__c = 'A';
            postal.Building_Name__c = 'Building';
            postal.Street_Name__c = 'Street';
            insert postal;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='01';
            addressRec.Level_Number__c ='23';
            addressRec.Unit_Number__c = '45';
            addressRec.Country__c = ctry.id;
            insert addressRec; 
    
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            con.FirstName = 'FName';
            con.LastName = 'LName';
            con.Passport__c = 'Passport Test';
            con.HomePhone__c = '123 456';
            con.Mobile_Number__c = '123456';
            con.Email = 'test@test.com';
            insert con;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Contact__c = con.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__AccountNumber__c = 'BA999999';
            insert billAcc;
            
            Credit_Note__c credNote = new Credit_Note__c(); 
            credNote.Is_PDF_Generated__c = false;
            credNote.To_ARMS_Time__c = null;
            credNote.Billing_Account__c = billAcc.Id;
            insert credNote;
            
            SP_CreditNoteRecordPatcher patcher = new SP_CreditNoteRecordPatcher();
            //ID batchprocessid = Database.executeBatch(patcher ,200);
            //System.assertNotEquals(null, batchprocessid);
        }
}