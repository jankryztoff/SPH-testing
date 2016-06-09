/**
 * Class Name: CaseEditOverrideControllerTest
 * @author Mark Jhustin Pinoy
 * Date: 2014.09.20
 * Requirement: 
 * @description Test class of CaseEditOverrideController.
 *
 */

@isTest(SeeAllData=true) //this is to access Custom Settings               
public class CaseEditOverrideControllerTest {
            private static User usrTest;
            private static List<Id> caseRecTypeLIST;
            private static String sphSysAd = ConstantsSLB.getKeyId('Profile_System Administrator');
            private static void createTestData() {
                        //test User - change this to appropriate Profile
                        usrTest = new User(
                        alias = 'testuser', 
                        email = 'testUser123@salesforce.com', 
                        emailencodingkey = 'UTF-8', 
                        firstname = 'Insert', 
                        lastname = 'Tester', 
                        languagelocalekey = 'en_US', 
                        localesidkey = 'en_US', 
                        profileid = sphSysAd,
                        //UserRoleId = '',
                        timezonesidkey = 'America/Los_Angeles', 
                        username = 'testUser123@salesforce.com');      
            }
            
            public static testMethod void testCaseEditOverrideCont() {
                        caseRecTypeLIST = new List<Id>{ ConstantsSLB.getKeyId('Case_Complaint Magazine'),
                        ConstantsSLB.getKeyId('Complaint_Newspaper'),
                        ConstantsSLB.getKeyId('Case_Change of Payment Type'),
                        ConstantsSLB.getKeyId('Case_Change of Credit Card'),
                        ConstantsSLB.getKeyId('Case_Bypass Credit Card'),
                        ConstantsSLB.getKeyId('Case_Adjustments'),
                        ConstantsSLB.getKeyId('Case_Change in Address'),
                        ConstantsSLB.getKeyId('Case_Start Sub'),
                        ConstantsSLB.getKeyId('Case_Stop'),
                        ConstantsSLB.getKeyId('Case_Particulars'),
                        ConstantsSLB.getKeyId('Case_Reset Password'),
                        ConstantsSLB.getKeyId('Case_Retention'),
                        ConstantsSLB.getKeyId('Case_Temp Stop'),
                        ConstantsSLB.getKeyId('Case_Refund'),
                        ConstantsSLB.getKeyId('Case_Digital'), 
                        ConstantsSLB.getKeyId('Case_Enquiry')
                        };
                        
                        //insert c;
                        Case c = [SELECT Id, RecordTypeId, RecordType.Name, AccountId FROM Case LIMIT 1];
                        
                        test.startTest();
                        //system.runAs(usrTest) {
                        for (Id recId: caseRecTypeLIST) {
                        PageReference pageRef = Page.CaseEditOverride;
                        pageRef.getParameters().put('RecordType', recId);
                        Test.setCurrentPage(pageRef);
                        ApexPages.StandardController sc = new ApexPages.StandardController(c);
                        CaseEditOverrideController testController = new CaseEditOverrideController(sc);
                        testController.redirect();
                        //check if it redirected correct url
                        //system.assertEquals('/' + c.Id + '/e?nooverride=1&RecordType=' + recId + '&retURL=' + '/' + c.Id, testController.redirect().getUrl());
                        
                        ApexPages.currentPage().getParameters().put('RecordType', ConstantsSLB.getKeyId('Case_Enquiry'));
                        CaseEditOverrideController testController2 = new CaseEditOverrideController(sc);
                        testController2.redirect();
                        testController2.relatedCaseIds();
                        }
                        //}
                        test.stopTest();       
            }
            //jurna
            public static testMethod void testCaseEditOverrideCont2() {
                        caseRecTypeLIST = new List<Id>{ ConstantsSLB.getKeyId('Case_Complaint Magazine'),
                        ConstantsSLB.getKeyId('Complaint_Newspaper'),
                        ConstantsSLB.getKeyId('Case_Change of Payment Type'),
                        ConstantsSLB.getKeyId('Case_Change of Credit Card'),
                        ConstantsSLB.getKeyId('Case_Bypass Credit Card'),
                        ConstantsSLB.getKeyId('Case_Adjustments'),
                        ConstantsSLB.getKeyId('Case_Change in Address'),
                        ConstantsSLB.getKeyId('Case_Start Sub'),
                        ConstantsSLB.getKeyId('Case_Stop'),
                        ConstantsSLB.getKeyId('Case_Particulars'),
                        ConstantsSLB.getKeyId('Case_Reset Password'),
                        ConstantsSLB.getKeyId('Case_Retention'),
                        ConstantsSLB.getKeyId('Case_Temp Stop'),
                        ConstantsSLB.getKeyId('Case_Refund'),
                        ConstantsSLB.getKeyId('Case_Digital'), 
                        ConstantsSLB.getKeyId('Case_Enquiry')
                        };
                        
                        //insert c;
                        Case c = [SELECT Id, RecordTypeId, RecordType.Name, AccountId FROM Case LIMIT 1];
                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        database.insert(acc);
                        
                         Case cas = TestDataFactory.createCase(1, 'Complaint - Digital')[0];
                        cas.AccountId = acc.id;
                        cas.Status = 'New';
                        database.insert(cas);
                        
                        Case cas2 = TestDataFactory.createCase(1, 'Change of Particulars')[0];
                        cas2.AccountId = acc.id;
                        cas2.Status = 'New';
                        database.insert(cas2);
                         
                        
                        test.startTest();
                        //system.runAs(usrTest) {
                        //for (Id recId: caseRecTypeLIST) {
                        PageReference pageRef = Page.CaseEditOverride;
                        //pageRef.getParameters().put('RecordType', cas.RecordTypeId);
                        //pageRef.getParameters().put('RecordType', cas2.RecordTypeId);
                        Test.setCurrentPage(pageRef);
                        ApexPages.StandardController sc = new ApexPages.StandardController(c);
                        CaseEditOverrideController testController = new CaseEditOverrideController(sc);
                        testController.redirect();
                        //check if it redirected correct url
                        //system.assertEquals('/' + c.Id + '/e?nooverride=1&RecordType=' + recId + '&retURL=' + '/' + c.Id, testController.redirect().getUrl());
                        
                        ApexPages.currentPage().getParameters().put('RecordType', cas2.RecordTypeId);
                        CaseEditOverrideController testController2 = new CaseEditOverrideController(sc);
                        testController2.redirect();
                        testController2.relatedCaseIds();
                        //}
                        //}
                        test.stopTest();       
            }
 
         public static testMethod void testCaseEditOverrideCont3() {

                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        database.insert(acc);
                        
                         Case cas = TestDataFactory.createCase(1, 'Complaint - Digital')[0];
                        cas.AccountId = acc.id;
                        cas.Status = 'New';
                        database.insert(cas);
                        
                        Case cas2 = TestDataFactory.createCase(1, 'Enquiry')[0];
                        cas2.AccountId = acc.id;
                        cas2.Status = 'New';
                        database.insert(cas2);
                         
                        
                        test.startTest();
                        //system.runAs(usrTest) {
                        //for (Id recId: caseRecTypeLIST) {
                        PageReference pageRef = Page.CaseEditOverride;
                        //pageRef.getParameters().put('RecordType', cas.RecordTypeId);
                        //pageRef.getParameters().put('RecordType', cas2.RecordTypeId);
                        Test.setCurrentPage(pageRef);
                        ApexPages.StandardController sc = new ApexPages.StandardController(cas2);
                        ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
                        CaseEditOverrideController testController = new CaseEditOverrideController(sc);
                        testController.redirect();
                        //check if it redirected correct url
                        //system.assertEquals('/' + c.Id + '/e?nooverride=1&RecordType=' + recId + '&retURL=' + '/' + c.Id, testController.redirect().getUrl());
                        
                        /*ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
                        CaseEditOverrideController testController2 = new CaseEditOverrideController(sc);
                        testController2.redirect();
                        testController2.relatedCaseIds();*/
                        //}
                        //}
                        test.stopTest();       
            }
                       
           public static testMethod void testCaseEditOverrideCont4() {
                        
                        caseRecTypeLIST = new List<Id>{ ConstantsSLB.getKeyId('Case_Complaint Magazine'),
                        ConstantsSLB.getKeyId('Complaint_Newspaper'),
                        ConstantsSLB.getKeyId('Case_Change of Payment Type'),
                        ConstantsSLB.getKeyId('Case_Change of Credit Card'),
                        ConstantsSLB.getKeyId('Case_Bypass Credit Card'),
                        ConstantsSLB.getKeyId('Case_Adjustments'),
                        ConstantsSLB.getKeyId('Case_Change in Address'),
                        ConstantsSLB.getKeyId('Case_Start Sub'),
                        ConstantsSLB.getKeyId('Case_Stop'),
                        ConstantsSLB.getKeyId('Case_Particulars'),
                        ConstantsSLB.getKeyId('Case_Reset Password'),
                        ConstantsSLB.getKeyId('Case_Retention'),
                        ConstantsSLB.getKeyId('Case_Temp Stop'),
                        ConstantsSLB.getKeyId('Case_Refund'),
                        ConstantsSLB.getKeyId('Case_Digital'),
                        ConstantsSLB.getKeyId('Case Renewal of Subscription'),
                        ConstantsSLB.getKeyId('Case_Change of Subscription')
                        };
                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        database.insert(acc);
                        
                         Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
                        cas.AccountId = acc.id;
                        cas.Status = 'New';
                        database.insert(cas);
                        
                        Case cas2 = TestDataFactory.createCase(1, 'Enquiry')[0];
                        cas2.AccountId = acc.id;
                        cas2.Status = 'New';
                        database.insert(cas2);
                         
                        
                        test.startTest();
                        /*PageReference pageRef = Page.CaseEditOverride;
                        Test.setCurrentPage(pageRef);
                        ApexPages.StandardController sc = new ApexPages.StandardController(cas2);
                        ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
                        CaseEditOverrideController testController = new CaseEditOverrideController(sc);
                        testController.redirect();*/
                       
                       for(Id recId: caseRecTypeLIST)
                       {
                           PageReference pageRef = Page.CaseEditOverride;
                            Test.setCurrentPage(pageRef);
                            ApexPages.StandardController sc = new ApexPages.StandardController(cas2);
                            pageRef.getParameters().put('RecordType', recId);
                            CaseEditOverrideController testController = new CaseEditOverrideController(sc);
                            testController.redirect();
                       }
                        test.stopTest();       
            }            
                       
}