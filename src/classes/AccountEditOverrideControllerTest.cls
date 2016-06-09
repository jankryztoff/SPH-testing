@isTest(seeAllData = TRUE)
public class AccountEditOverrideControllerTest {
<<<<<<< HEAD
    /** testing jkrc
=======
    /** for testing jcalma
>>>>>>> 91e97148123644126c96615fc64596acce6ae86e
     * Class Name: ContactNewOverrideControllerTest
     * @author: Jeffrey B. Teves
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Test Class for ContactNewOverrideController
     * 
     */
    
    static Account acc;
    static User cso;
    
    static testMethod void testRedirectVendorAccount() {
        prepareTestUsersAccount();
        System.runAs(cso) {
            acc = new Account(
                Name = 'Test Account',
                RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor'),
                Email__c = 'sample@email.com',
                Mobile__c = '1234567'
            );
            insert acc;
            
            Test.startTest();
            PageReference pRef = Page.AccountEditOverride;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('id', acc.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());
            AccountEditOverrideController controller = new AccountEditOverrideController(stdCtrlr);
            PageReference nextPage = controller.redirect();
            System.assert(nextPage.getUrl().contains('/' + acc.Id + '/e'));
            Test.stopTest();
        }
    }
    
    static testMethod void testRedirectNonVendorAccount() {
        prepareTestUsersAccount();
        System.runAs(cso) {
            acc = new Account(
                Name = 'Test Account',
                RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
                Email__c = 'sample@email.com',
                Mobile__c = '1234567'
            );
            insert acc;
            
            Test.startTest();
            PageReference pRef = Page.AccountEditOverride;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('id', acc.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());
            AccountEditOverrideController controller = new AccountEditOverrideController(stdCtrlr);
            PageReference nextPage = controller.redirect();
            System.assert(nextPage.getUrl().contains('/apex/AccountEditPage'));
            Test.stopTest();
        }
    }
    
    static testMethod void testInvalidAccountId() {
        prepareTestUsersAccount();
        System.runAs(cso) {
            acc = new Account(
                Name = 'Test Account',
                RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual'),
                Email__c = 'sample@email.com',
                Mobile__c = '1234567'
            );
            insert acc;
            delete acc;
            
            Test.startTest();
            PageReference pRef = Page.AccountEditOverride;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('id', acc.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());
            AccountEditOverrideController controller = new AccountEditOverrideController(stdCtrlr);
            PageReference nextPage = controller.redirect();
            System.assertEquals(null, nextpage);
            Test.stopTest();
        }
    }
    
    static void prepareTestUsersAccount() {
        cso = TestDataFactory.prepareTestusers();
    }
}