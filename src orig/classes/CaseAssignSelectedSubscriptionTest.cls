/** * Class Name: <CaseAssignSelectedSubscription> 
* @author: <KarlTan> * Date: <8/16/2014> 
* Requirement/Project Name: <SPH> 
* @description<Test Class for ComplaintMagazineExtensionEdit> */

@isTest (seeAllData= True)
public class CaseAssignSelectedSubscriptionTest {       
    static testMethod void testSingleVendorSub(){
        
        //Create a new user with Standard User Profile

        User testUserCASST = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='caseAssign1@test.com'
            );
        
      //  System.assertEquals('', String.valueOf(u));

        //The test will run as the user created.
        System.runAs(testUserCASST) {
            
            Test.startTest();
        
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            Account acc = TestDataFactory.createAccount(1,'Vendor Subscriber')[0];
            insert acc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            Package__c pack = new Package__c();
            pack.Package_Type__c = 'Base';
            pack.Name = 'Test Package';
            pack.Package_Code__c = 'PackCodeTestUnique';
            pack.Effective_Start_Date__c = date.today().addDays(2);
            pack.Effective_End_Date__c = date.today().addDays(2);
            insert pack;
            
            //create Contact Record
            List<Contact> conList = TestDataFactory.createContact(1);
            conList[0].Address__c = addressRec.Id;
            conList[0].AccountId = acc.Id;
            //START CCB.002 Modified by: Francis Benzon
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            conList[0].Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            insert conList;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = conList[0].Id;
            insert orderRec;
       
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
			orderline.Start_Date__c = date.today().addDays(2);
            orderline.End_Date__c = date.today().addDays(4);
            orderline.Main_Package_ID__c = pack.Id;
            insert orderline;
            
            
            //create Case Record 
            Case cas = new Case();
            cas.AccountId = acc.id;
            cas.Order__c = orderRec.Id;
            cas.Origin = 'Phone';
            cas.Priority = 'Medium';
            cas.Date_Replaced__c = system.today();
            cas.Status = 'New';
            insert cas;
            
            Zuora__CustomerAccount__c billacct = new Zuora__CustomerAccount__c();
            billacct.Zuora__Account__c= acc.id;
            insert billacct;
            
            //create Subscription
            List<Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
            zuoSubList[0].Order_Number__c = orderRec.Id;
            zuoSubList[0].Zuora__CustomerAccount__c = billacct.id; 
            zuoSubList[0].Zuora__Status__c = 'Active';
            zuoSubList[0].Zuora__Account__c = acc.Id;
            zuoSubList[0].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            zuoSubList[0].Subscriber_Contact__c = conList[0].Id;
            zuoSubList[0].Recipient_Contact__c = conList[0].Id;
            zuoSubList[0].Main_Package_1__c = pack.id;
            zuoSubList[0].Billing_Type__c = 'Full Prepaid';
            zuoSubList[0].Charity__c = 'TRUE';
            zuoSubList[0].Contract_End_Date__c = String.valueof(date.Today());
            zuoSubList[0].New_Contract_Period__c = '1';
            zuoSublist[0].Penalty_Charge__c = '1000';
            zuoSublist[0].Promotion_Contract_Period__c = '2';
            zuoSubList[0].Suppress_Vendor_Start_Notice__c = 'TRUE';
            zuoSubList[0].Supressed_Acknowledgement_Letter__c = 'TRUE';
            zuoSubList[0].Supressed_Renewal_and_Reminder_Letter__c = 'TRUE';
            zuoSubList[0].Urgent__c= 'TRUE';
            zuoSubList[0].Vendor__c = acc.Id ;
            zuoSubList[0].Vendor_Conversion__c = 'TRUE';
            zuoSubList[0].Number_of_Copies1__c = '1';			
            upsert zuoSubList;
     
          //initialize page and controllers            
            PageReference pgRef = Page.CaseAssignSelectedSubscription;            
            Test.setCurrentPage(pgRef);           
            ApexPages.currentPage().getParameters().put('id', cas.Id);           
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            
            Test.stopTest();
       }    
    }
 
 
}