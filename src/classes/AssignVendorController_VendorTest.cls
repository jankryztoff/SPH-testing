/**
     * Class Name: AssignVendorController_VendorTest
     * @author: Glenn Garcia
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Test Class for AssignVendorController_Vendor
     * 
     */

@isTest(seeAllData = TRUE)
public class AssignVendorController_VendorTest {
 
    static testMethod void testAssignVendorController(){

        //create project
        Project__c pro = TestDataFactory.createProject(1)[0];
        pro.Project_Description__c = 'This is a new confidential project.';
        //create vendor subscriber acct
        Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        //create singpost address
        Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
        //create subscription vendor
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        //create package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        //create vendor Account
        Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount};

        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct SPH-Interdivision');
        insert accounts;
            
        //create address
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singpostAdd.Id;
        insert add;
        
        //create billing acct
        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
        billingAcc.Billing_Type__c = 'Full Prepaid';
        insert billingAcc;
        
        //create contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = vendorSubsAcct.Id;
        con.Address__c = add.Id;
        con.Recipient_Indicator__c = true;
        insert con;
        
        //create order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = vendorSubsAcct.Id;
        order.Recipient_Contact__c = con.Id;
        order.Billing_Account__c = billingAcc.Id;
        order.Informed_Customer__c = True;
        order.Billing_Type__c = 'Full Prepaid';
        insert order;
        
        //create case
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        //create order line item
        Order_Line_Item_Vendor__c oli = TestDataFactory.createOrderLineItemVendor(1)[0];
        oli.Order__c = order.Id;
        oli.Subscription_Vendor__c = subsVen.Id;
        oli.Start_Date__c = date.Today()+1;
        //oli.Main_Package_ID__c = pack.Id;
        //oli.Vendor_Mailing_Agent__c = vendorSubsAcct.Id;
        oli.Vendor__c = accounts[0].id;
        insert oli;
        
        System.assertEquals(oli.Vendor__c,accounts[0].id);
        
        //create Zuora Subscriptions
        Subscription_Vendor__c zSub = TestDataFactory.createSubscriptionVendor(1)[0];
        zSub.Account__c = vendorSubsAcct.Id;
        zSub.Vendor__c = vendorSubsAcct.Id;
        //zSub.Parent_Order_Line_Item__c = oli.Id;
        zSub.Order_Number__c = order.Id;
        //zSub.Suppress_Vendor_Start_Notice__c = 'false';
        //zSub.Supressed_Acknowledgement_Letter__c = 'false';
        //zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        //zSub.Urgent__c = 'false';
        //zSub.Vendor_Conversion__c = 'false';
        //zSub.Charity__c = 'false';
        insert zSub;
        
        //create parcel
        Parcel__c par = TestDataFactory.createParcel(1)[0];
        par.Project_Name__c = pro.Id;
        par.Allocation_Type__c = 'SDA';
        par.Description__c = 'Description';
        insert par;
        
        //create vendor allocation
        Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
        venAlloc.SingPost_Address__c = singpostAdd.Id;
        venAlloc.Vendor_Account__c = venAccount.Id;
        venAlloc.Parcel_Name__c = par.Id;
        venAlloc.Allocated__c = true;
        insert venAlloc;
        
        Test.startTest();
    
        PageReference pRef = Page.AssignVendor_Vendor;
       
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('id', oli.Id);
        AssignVendorController_Vendor controller = new AssignVendorController_Vendor();
        PageReference pRef1 = controller.selectedVendorAllocation();
        System.assertEquals((new PageReference('/' + oli.Id)).getUrl(), controller.save().getUrl());
        System.assertEquals(null, controller.cancel());
        
        Test.stopTest();    
        
    }    
}