/**
     * Class Name: AccountTriggerHandlerTest
     * @author: Jeffrey Teves
     * Date: 8/4/2014
     * Requirement/Project Name: <SPH>
     * @description Test Class for AccountTriggerHandler
     * 
     */
@isTest(seeAllData = TRUE)
public class AccountTriggerHandlerTest {
   
    static User cso;
    
    static testMethod void testAccountNumberPopulation() {
        cso = TestDataFactory.prepareTestUsers();
        System.runAs(cso) {
            Test.startTest();
            Account acc = new Account(
                Name = 'Test Account',
                RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
                Generate_Account_Number__c = TRUE,
                Email__c = 'test@sample.com',
                SMS_Renewal_Notification__c = true,
                Mobile__c = '09321234567');
            insert acc;
            acc = [SELECT Id, AccountNumber FROM Account WHERE Id = :acc.Id];
            System.assertNotEquals(null, acc.AccountNumber);
            
            acc.AccountNumber = '';
            AccountTriggerHandler.isAfterUpdateTriggerCalled = false;
            update acc;
            acc = [SELECT Id, AccountNumber FROM Account WHERE Id = :acc.Id];
            System.assertNotEquals(null, acc.AccountNumber);
            
            AccountTriggerHandler.isBeforeDeleteTriggerCalled = false;
            delete acc;
            Test.stopTest();
        }
                
    }    
    
    //START [Wenjun 10/12/14] : Vendor Conversion
    //Test method for Account Conversion - auto-create Recipient Contact 
    static testMethod void testCreateRecipientContacts() {
        cso = TestDataFactory.prepareTestUsers();
        
        System.runAs(cso) {
            Test.startTest();
            
            String ACC_RT_VS = (String) ConstantsSLB.getKeyId('Account_Vendor Subscriber');
            String ACC_RT_DI = (String) ConstantsSLB.getKeyId('Account_Direct Individual');
            String CON_RT_CUS = (String) ConstantsSLB.getKeyId('Contact_Customer Contact');

            //Create a Vendor Subscriber Account
            Account accVS = new Account(Name = 'Test VS Account',RecordtypeId = ACC_RT_VS);
            INSERT accVS;
            
            //Manually clear the flag to insert next Account for testing
            AccountTriggerHandler.isAfterInsertTriggerCalled = false;
            
            //Create a Vendor Subscriber Recipient Contact
            Contact contVS = new Contact(AccountId=accVS.ID, FirstName='Firstname', LastName='Lastname', RecordtypeId=CON_RT_CUS, Salutation='MR.', Email='sample@email.com', Phone='61234567');
            contVs.Recipient_Indicator__c = true;
            INSERT contVS;
            
            //Scenerio 1: Create a Direct Subscriber (Individual) Account which has Vendor Subscriber Account as the Parent Account
            Account accDI = new Account(Name = 'Test DI Account',RecordtypeId = ACC_RT_DI, ParentID = accVS.Id,Email__c = 'test2@sample.com', SMS_Renewal_Notification__c = true,
            Mobile__c = '09321234567');
            INSERT accDI;
            
            //Manually clear the flag to insert next Account for testing
            AccountTriggerHandler.isAfterInsertTriggerCalled = false;
            
            //Retrieve the auto-created Recipient Contact 
            List<Contact> lstContact = [SELECT Id,FirstName,LastName,Email,Phone FROM Contact WHERE AccountId = :accDI.Id];
            
            System.assertEquals(1, lstContact.size());
            System.assertEquals('Firstname', lstContact[0].FirstName);
            System.assertEquals('61234567', lstContact[0].Phone);
            
           //Scenerio 2: Create a Direct Subscriber (Individual) Account and then update Vendor Subscriber Account as the Parent Account
            Account accDI2 = new Account(Name = 'Test DI Account 2',RecordtypeId = ACC_RT_DI,Email__c = 'test3@sample.com', SMS_Renewal_Notification__c = true, Mobile__c = '09321234568');
            INSERT accDI2;
            
            //Manually clear the flag to update Account for testing
            AccountTriggerHandler.isAfterUpdateTriggerCalled = false;
            
            //Retrieve the Recipient Contact - it should be none
            lstContact = [SELECT Id,FirstName,LastName,Email,Phone FROM Contact WHERE AccountId = :accDI2.Id];
            System.assertEquals(0, lstContact.size());
            
            accDI2.ParentID = accVS.Id;
            UPDATE accDI2;
            
            //Retrieve the auto-created Recipient Contact 
            lstContact = [SELECT Id,FirstName,LastName,Email,Phone FROM Contact WHERE AccountId = :accDI2.Id];
            
            System.assertEquals(1, lstContact.size());
            System.assertEquals('Firstname', lstContact[0].FirstName);
            System.assertEquals('61234567', lstContact[0].Phone);

            AccountTriggerHandler ath = new AccountTriggerHandler();
            ath.runBeforeInsertTrigger();
            ath.runBeforeUpdateTrigger();
            ath.runBeforeDeleteTrigger();
            ath.runAfterInsertTrigger();
            ath.runAfterUpdateTrigger();
            ath.runAfterDeleteTrigger();

            Test.stopTest();
        }       
    } 
    //END [Wenjun 10/12/14] : Vendor Conversion
}