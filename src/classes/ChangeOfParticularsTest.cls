/**
 * Class Name: ChangeOfParticularsTest
 * @author: Leuwend Job Hapa
 * Date: 01/22/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description Test class for ChangeOfParticulars
 *
 */

@isTest ( seeAllData = true )
public class ChangeOfParticularsTest {

    static testMethod void myUnitTest() {
        
        Contact contact = [
            Select 
            Recipient_Indicator__c, Billing_Indicator__c, MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
            AccountId, Id, Salutation, FirstName, Address__c, Address__r.RecordTypeId, Address__r.RecordType.Name,
            Address__r.Location_Code__c, Address__r.Company_Code__c, Address__r.Division_Code__c, Address__r.Section_Code__c,
            Address__r.Additional_Info__c, Address__r.City__c, Address__r.Packing_Code__c, LastName, HomePhone__c, Mobile_Number__c,
            Mobile_Number_2__c, Email__c, Email_Secondary__c, NRIC__c, Office_Number__c, RecordTypeId, Fax,
            Passport__c, Account.Language__c, Account.Gender__c, Account.Race__c, Account.Designation__c, Recipient_Number__c,
            Account.Education__c, Account.Income_Range__c, Account.Date_of_Birth__c, Office_Extension__c
            
            From Contact 
            
            limit 1
        ];
                            
        PageReference currentPage = Page.UpdateContact_COP;
        currentPage.getParameters().put( 'ContactId', contact.id );
        
        system.Test.setCurrentPage( currentPage );
        ApexPages.StandardController sc = new ApexPages.StandardController( contact );
        
        ChangeOfParticulars controller = new ChangeOfParticulars( sc );
        controller.saveContact();
        controller.AddressType = 'Internal';
        controller.saveContact();
        controller.AddressType = 'Airline';
        controller.saveContact();
    }
    
    static testMethod void test_RecordTypeIsInternalOrAirline() {
        
        Contact contact = [
            Select 
            Recipient_Indicator__c, Billing_Indicator__c, MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
            AccountId, Id, Salutation, FirstName, Address__c, Address__r.RecordTypeId, Address__r.RecordType.Name,
            Address__r.Location_Code__c, Address__r.Company_Code__c, Address__r.Division_Code__c, Address__r.Section_Code__c,
            Address__r.Additional_Info__c, Address__r.City__c, Address__r.Packing_Code__c, LastName, HomePhone__c, Mobile_Number__c,
            Mobile_Number_2__c, Email__c, Email_Secondary__c, NRIC__c, Office_Number__c, RecordTypeId, Fax,
            Passport__c, Account.Language__c, Account.Gender__c, Account.Race__c, Account.Designation__c, Recipient_Number__c,
            Account.Education__c, Account.Income_Range__c, Account.Date_of_Birth__c, Office_Extension__c
            
            From Contact Where (Address__r.RecordType.Name = 'Internal' OR Address__r.RecordType.Name = 'Airline')
            
            limit 1
        ];
                            
        PageReference currentPage = Page.UpdateContact_COP;
        currentPage.getParameters().put( 'ContactId', contact.id );
        
        system.Test.setCurrentPage( currentPage );
        ApexPages.StandardController sc = new ApexPages.StandardController( contact );
        
        ChangeOfParticulars controller = new ChangeOfParticulars( sc );
    }
    
    static testMethod void test_ContactIsNull() {
        
        ChangeOfParticulars controller = new ChangeOfParticulars( null );
        controller.saveContact();
    }    
}