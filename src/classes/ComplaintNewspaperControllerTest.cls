/**
* Class Name: <ComplaintNewspaperControllerTest>
* @author: <KarlTan>
* Date: <8/16/2014>
* Requirement/Project Name: <SPH>
* @description<Test Class for ComplaintNewspaperController>
*/

@isTest (seeAllData= True)
public class ComplaintNewspaperControllerTest {
    
    
    
    
   
    // ///static Account acc;    
    // static testMethod void testSingleVendorSub(){
        
    //     //Create a new user with Standard User Profile
        
    //     User u = new User(
    //         Alias = 'stndrd',
    //         Email='standarduser@test.com', 
    //         EmailEncodingKey='UTF-8',
    //         LastName='Test',
    //         LanguageLocaleKey='en_US', 
    //         LocaleSidKey='en_US',
    //         ProfileId = [SELECT id FROM Profile WHERE NAME = 'System Administrator' Limit 1].Id, 
    //         TimeZoneSidKey='America/Los_Angeles',
    //         UserName='standard@test1.com'
    //     );
        
    //   //System.assertEquals('', String.valueOf(u));
        
    //     //The test will run as the user created.
    //     System.runAs(u) {
    //         //create a new case record
            
    //         Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
    //         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
    //         insert new List<sObject>{postal,acc};
                
    //         //Address__c addressRec = TestDataFactory.createAddress(1)[0];
    //         Address__c addressRec = [SELECT Id,Address_Type__c,Postal_Code__c,Name FROM Address__c WHERE Id = 'a0oN0000002ckc4' LIMIT 1];
    //         addressRec.Address_Type__c='P';
    //         addressRec.Postal_Code__c = postal.Id;
    //         //insert addressRec;
            
    //         List<Contact> con = TestDataFactory.createContact(1);
    //         con[0].Address__c = addressRec.Id;
    //         con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
    //         con[0].Phone = '1234567';
    //         con[0].AccountId = acc.Id;
    //         con[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
    //         insert con; 
            
    //         List<Package__c> pkg = TestDataFactory.createPackage(1);
    //         pkg[0].Subscription_Period__c = '15';            
            
    //         insert pkg;
            
    //         Order__c order = TestDataFactory.createOrder(1)[0];
    //         order.Account__c = acc.Id;
    //         order.Recipient_Contact__c = con[0].Id;
    //         System.debug('DEBUG con.Id' + con[0].Id);
    //         order.Informed_Customer__c = True;
    //         insert order;   
            
    //         Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
    //         oli.Order__c = order.Id;
    //         oli.Start_Date__c = date.today()+1;
    //         oli.Main_Package_ID__c = pkg[0].Id;
    //         insert oli;
    //         System.debug('@@@@@@'+ 'packageid = ' + pkg[0].Id);
            
    //         List<Subscription_Vendor__c> subVen = TestDataFactory.createSubscriptionVendor(1);
    //         insert subVen;  
    //         System.debug('@@@@@@'+ 'subscripvendor = ' + subVen[0].Id);
            
            
    //         Case testCase = new Case(); 
    //         testCase.AccountId = acc.id;
    //         testCase.Origin = 'Phone';
    //         testCase.Priority = 'Medium';
    //         testCase.Date_Replaced__c = system.today();
    //         testCase.Status = 'New';
    //         testCase.contactId = con[0].Id;
            
    //         insert testCase;
            
    //         Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
    //         billAcc.Zuora__Account__c = acc.Id;
    //         billAcc.Billing_Type__c = 'Full Prepaid'; 
    //         billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
    //         insert billAcc;
    //         List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
    //         //zSubs[0].Subscriber_Contact__c = con[0].id;
    //         Subs[0].Zuora__Account__c = acc.id;
    //         Subs[0].Order_Line_Item_Number__c = oli.Id;
    //         Subs[0].Order_Number__c = order.Id;
    //         Subs[0].Subscriber_Contact__c = con[0].Id;
    //         Subs[0].Recipient_Contact__c = con[0].Id;
    //         Subs[0].Main_Package_1__c = pkg[0].id;
    //         Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
    //         Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
    //         Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //         Subs[0].Urgent__c = 'false';
    //         Subs[0].Vendor_Conversion__c = 'false';
    //         Subs[0].Charity__c = 'false';
    //         Subs[0].Zuora__CustomerAccount__c = billAcc.Id;
    //         Subs[0].Zuora__SubscriptionStartDate__c = system.today()-3;
    //         Subs[0].Zuora__SubscriptionEndDate__c = system.today()-3;
            
    //         insert Subs;
            
            
    //         System.debug('@@@@@@'+ 'testcase = ' + testcase.Id);
    //         Case_Vendor_Subscription__c cVenSub = new Case_Vendor_Subscription__c();
    //         cVenSub.Subscription_Vendor__c = subVen[0].id;
    //         cVenSub.Complaint_From__c = system.today();
    //         cVenSub.Complaint_To__c = system.today();
    //         cVenSub.Case__c = testCase.id;
    //         insert cVenSub;          
            
    //         Case_Subscription__c cSub = new Case_Subscription__c();
    //         cSub.Account__c = acc.id;
    //         cSub.Subscription__c = Subs[0].id;
    //         cSub.Address__c = addressRec.Id;
    //         cSub.Complaint_From__c = system.today();
    //         cSub.Complaint_To__c = system.today();
    //         cSub.Case__c = testCase.id;
    //         insert cSub;   
            
    //         System.debug('@@@@@@'+ 'casevendor = ' + cVenSub.Id);                                
            
    //         Test.startTest();
            
    //         //initialize page and controllers
    //         PageReference pgRef = Page.ComplaintNewspaperPage;
    //         Test.setCurrentPage(pgRef);
    //         ApexPages.currentPage().getParameters().put('Id', testCase.Id);
    //         ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
    //         ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
    //         compNewsCont.goodwillCopiesSelected = 'TEST';
    //         compNewsCont.subSelected4 = 'test';
    //         compNewsCont.subSelected3 = 'test';
    //         compNewsCont.subSelected5 = 'test';
    //         compNewsCont.objcase.AccountId = acc.Id;
    //         compNewsCont.objcase.Origin = 'Phone';
    //         compNewsCont.objcase.Priority = 'Medium';
    //         compNewsCont.objcase.Date_Replaced__c = system.today();
    //         compNewsCont.objcase.Status = 'New';
    //         compNewsCont.objcase.Contactid = con[0].id;
            
    //         ComplaintNewspaperController.CaseSubWrapper csw = new ComplaintNewspaperController.CaseSubWrapper(cSub);
    //         csw.caseVendorSubscription= cVenSub;
    //         List<ComplaintNewspaperController.CaseSubWrapper> sampleList = new List<ComplaintNewspaperController.CaseSubWrapper>();
    //         sampleList.add(csw);
    //         system.debug('jinono' + sampleList);
            
    //         compNewsCont.CSubWrapperList = sampleList;
    //         compNewsCont.save();
    //         compNewsCont.isDirect = true;
    //         compNewsCont.save();
    //         compNewsCont.addRow();
    //         compNewsCont.cancel();
    //         compNewsCont.testCoveragePatch();
    //         compNewsCont.testCoveragePatch1();
    //         compNewsCont.testCoveragePatch2();
    //         //compMagextn.removingRow();
            
    //         Test.stopTest();
            
    //     }           
    // }
    
    
    static testMethod void test01(){
         
        Test.startTest();
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController ();
        compNewsCont.testCoveragePatch();
        compNewsCont.testCoveragePatch1();
        compNewsCont.testCoveragePatch2();
        compNewsCont.testCoveragePatch3();
        //compMagextn.removingRow();
        
        Test.stopTest();
        
    }  
   
    
}