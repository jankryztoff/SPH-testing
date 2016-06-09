/**
* Class Name: <SubscriptionVendorTriggerHandlerTest>
* @author: <CharlesLin>
* Date: <2/24/2015>
* Requirement/Project Name: <SPH>
* @description<Test Class for SubscriptionVendorTriggerHandlerTest, handles bulk insert and update>
*/
/*Modified by: April Grace Judilla-Veloso
* Date: 07/14/2015
*/

@isTest (Seealldata = TRUE)
public class SubscriptionVendorTriggerHandlerTest {

    static testMethod void testSingleInsertUpdate(){
        Zuora__Subscription__c sobj = new Zuora__Subscription__c();
        Zuora__Subscription__c sobj2 = new Zuora__Subscription__c();        
        
        SubscriptionVendorTriggerHandler subVendorhandler = new SubscriptionVendorTriggerHandler();       

        subVendorhandler.runBeforeInsertTrigger();
        subVendorhandler.runBeforeUpdateTrigger();
        subVendorhandler.runBeforeDeleteTrigger();
        subVendorhandler.runAfterInsertTrigger();
        subVendorhandler.runAfterUpdateTrigger();
        subVendorhandler.runAfterDeleteTrigger();
        
        //The test will run as the user created.
        Id profileID = (Id) ConstantsSLB.getKeyId('Profile_Standard User');
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(u) {
            
            Singpost_Address__c postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            
            Address__c address = new Address__c();
            address = TestDataFactory.createAddress(1)[0];
            address.Postal_Code__c = postal.Id;
            insert address;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            Account acct = new Account();
            acct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acct.NRIC__c = 'T1234567R';
            insert acct;
            
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
            insert acctVendor;
            
            Contact con = new Contact();
            con = TestDataFactory.createContact(1)[0];
            con.AccountId = acct.Id;
            con.Address__c = address.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acct.Id;
            order.Recipient_Contact__c = con.Id;
            order.Informed_Customer__c = True;
            insert order;
            
            Publication__c publication = TestDataFactory.createPublication(1)[0];
            publication.Published_Days__c = 'YYYYYYN';
            publication.Publication_Type__c = 'N';
            publication.Platform_Type__c = 'Print';
            insert publication;
            
            Order_Line_Item_Vendor__c orderlineVendor = TestDataFactory.createOrderLineItemVendor(1)[0];
            orderlineVendor.Order__c = order.Id;
            orderlineVendor.Publication__c = publication.Id;
            orderlineVendor.Start_Date__c = date.today() + 1; //CHA 22April2016
            orderlineVendor.Stop_Date__c = date.today() + 30; //CHA 22April2016
            orderlineVendor.Stop_Request_Date__c = date.today() + 30; //CHA 22April2016
            orderlineVendor.Vendor__c = acctVendor.Id;
            insert orderlineVendor;
            
            Case caseRec = new Case();
            caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            caseRec.Order__c = order.Id;
            caseRec.Status = 'Closed';
            caseRec.Sub_Status__c = 'Subscription Created';
            insert caseRec;
            
            //create subscription vendor
            Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            SubVend.Account__c = acct.Id;
            SubVend.Order_Number__c = order.Id;
            SubVend.Recipient__c = con.Id;
            SubVend.Status__c = 'Cancelled';
            insert SubVend;
            
            orderlineVendor.Case__c = caseRec.Id;
            update orderlineVendor;            
            
           
            test.startTest();
           
            //update
            SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = false;
            SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = false;
            
            /* added by A.Veloso */
            SObject so = new Subscription_Vendor__c();
            SObject so2 = new Subscription_Vendor__c();
            subVendorhandler.beforeInsert(so);
            subVendorhandler.beforeDelete(so);
            
            subVendorhandler.beforeUpdate(so, so2);
            subVendorhandler.afterUpdate(so, so2);
            subVendorhandler.afterDelete(so);
            test.stoptest();
        }

    }
}