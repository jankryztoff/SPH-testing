@isTest(seeAllData = TRUE)
public class ContactNewOverrideControllerTest {
    /**
     * Class Name: ContactNewOverrideControllerTest
     * @author: Jeffrey B. Teves
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Test Class for ContactNewOverrideController
     * 
     */
    
    static Account acc;
    static User cso;
    
    static testMethod void testRedirectBillingContact() {
        prepareTestUsers();
        System.runAs(cso) {
            prepareTestData();
            
            Test.startTest();
            PageReference pRef = Page.ContactNewOverride;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('accid', acc.Id);
            ApexPages.currentPage().getParameters().put('RecordType', ConstantsSLB.getKeyId('Contact_Customer Contact'));//START/END CCB.002 Modified by: Francis Benzon
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new contact());
            ContactNewOverrideController controller = new ContactNewOverrideController(stdCtrlr);
            PageReference nextPage = controller.redirect();
            //System.assertEquals('/apex/CreateModifyContactAddress?accountId=' + acc.Id, nextPage.getUrl());
            Test.stopTest();
        }
    }
    
    static testMethod void testRedirectRecipientContact() {
        prepareTestUsers();
        System.runAs(cso) {
            prepareTestData();
            
            Test.startTest();
            PageReference pRef = Page.ContactNewOverride;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('accid', acc.Id);
            ApexPages.currentPage().getParameters().put('RecordType', ConstantsSLB.getKeyId('Contact_Customer Contact'));//START/END CCB.002 Modified by: Francis Benzon
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new contact());
            ContactNewOverrideController controller = new ContactNewOverrideController(stdCtrlr);
            PageReference nextPage = controller.redirect();
            //System.assertEquals('/apex/CreateModifyContactAddress?accountId=' + acc.Id, nextPage.getUrl());
            Test.stopTest();
        }
    }
    
    static testMethod void testRedirectVendorContact() {
        prepareTestUsers();
        System.runAs(cso) {
            prepareTestData();
            
            Test.startTest();
            PageReference pRef = Page.ContactNewOverride;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('accid', acc.Id);
            ApexPages.currentPage().getParameters().put('RecordType', ConstantsSLB.getKeyId('Contact_Vendor Contact'));
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new contact());
            ContactNewOverrideController controller = new ContactNewOverrideController(stdCtrlr);
            PageReference nextPage = controller.redirect();
            System.assert(nextPage.getUrl().contains('/003/e'));
            Test.stopTest();
        }
    }
    
    static void prepareTestUsers() {
        cso = new User(
            Alias = 'standt',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
    }
    
    static void prepareTestdata() {
        
        acc = new Account(
            Name = 'Test Account',
            RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
            SMS_Renewal_Notification__c = true,
            Mobile__c = '09321234567',
            Email__c = 'test@sample.com' );
        insert acc;
        
    }
    
}