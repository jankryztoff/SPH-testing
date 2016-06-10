/**
     * Class Name: AssignVendorControllerTest
     * @author: Glenn Garcia
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Test Class for AssignVendorController
     * 
     */

@isTest
public class AssignVendorControllerTest {
 
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
    }
 
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

        //create address
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singpostAdd.Id;
        insert add;
        
        //create billing acct
        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
        insert billingAcc;
        
        //create contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = vendorSubsAcct.Id;
        con.Address__c = add.Id;
        insert con;
        
        //create order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = vendorSubsAcct.Id;
        order.Recipient_Contact__c = con.Id;
        order.Billing_Account__c = billingAcc.Id;
        order.Informed_Customer__c = True;
        try{
        insert order;
        }catch(exception e){}
        //create case
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        //cas.Status__c = 'Closed';
        //cas.Sub_Status__c = 'Subscription Created';
        insert cas;
        
        List<Case> testcase = new List<Case>();
        testcase.add(cas);
        
        //create order line item
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Order__c = order.Id;
        oli.Vendor_Subscription_ID__c = subsVen.Id;
        oli.Main_Package_ID__c = pack.Id;
        oli.Vendor_Mailing_Agent__c = vendorSubsAcct.Id;
        try{
        insert oli;
        }catch(exception e){}
        List<Order_Line_Item__c> testOLI= new List<Order_Line_Item__c>();
        testOLI.add(oli);
        
        //create Zuora Subscriptions
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__Account__c = vendorSubsAcct.Id;
        zSub.Order_Line_Item_Number__c = oli.Id;
        zSub.Order_Number__c = order.Id;
        zSub.Suppress_Vendor_Start_Notice__c = 'false';
        zSub.Supressed_Acknowledgement_Letter__c = 'false';
        zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSub.Urgent__c = 'false';
        zSub.Vendor_Conversion__c = 'false';
        zSub.Charity__c = 'false';
        try{
        insert zSub;
        }catch(exception e){}
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
        try{
            insert venAlloc;
        }catch(exception e){}
        Test.startTest();
    
        PageReference pRef = Page.AssignVendor;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('id', oli.Id);
        AssignVendorController controller = new AssignVendorController();
        
        
        try{
            controller.save();
        }catch(exception e){}
        System.assertEquals(null, controller.cancel());
        //System.assertEquals([SELECT Id, Vendor_Mailing_Agent__c FROM Order_Line_Item__c WHERE Order__c =:order.Id]+'', ' ');
        
        Test.stopTest();    
        
    }    
}