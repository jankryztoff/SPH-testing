/**
   @author Glenn Garcia / AMiranda
   @name AssignVendorController_Test
   @createDate 18 Feb 2015
   @description Test for class AssignVendorController
   @version 1.0 
*/
@isTest(seeAllData=true)
private class AssignVendorController_Test {

    /**
        @name testAssignVendorController
        @param none
        @return void
        @description tests the constructor
    */
    //static testMethod void testAssignVendorController(){
    public static void testAssignVendorController(){ 
    
        Test.setMock(WebServiceMock.class, new zApiTest());
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
        billingAcc.Billing_Type__c = 'Full Prepaid';
        billingAcc.Zuora__DefaultPaymentMethod__c = 'Other';
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
        insert order;
        
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
        oli.Vendor_Mailing_Agent__c = venAccount.Id;
        oli.Start_Date__c = date.today().addDays(1);
        oli.End_Date__c = date.today().addDays(30);
        //oli.Vendor_Mailing_Agent__c = vendorSubsAcct.Id;
        insert oli;
        
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
        zsub.Number_of_Copies1__c = '100';
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
        insert venAlloc;
        
        Test.startTest();
    
        PageReference pRef = Page.AssignVendor;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('id', oli.Id);
        AssignVendorController controller = new AssignVendorController();
        
        
        controller.save();
        System.assertEquals(null, controller.cancel());
        //System.assertEquals([SELECT Id, Vendor_Mailing_Agent__c FROM Order_Line_Item__c WHERE Order__c =:order.Id]+'', ' ');
        
        Test.stopTest();       
    } 
    
    
    static Account vendorAcct;
    static Singpost_Address__c singPostAddr;
    static Address__c address;
    static Contact contact;
    static Package__c aPackage;
    static Order__c order;
    static Order_Line_Item__c orderLineItem;
    static Vendor_Allocation__c vendorAlloc; 
    static Zuora__Subscription__c zouraSubscription;
    static Case aCase;   
    
    /**
        @name setUpData
        @param none
        @return void
        @description sets up data required for the test
    */
    private static void setUpData() {
    
        vendorAcct = TestDataFactory.createAccount(1, 'Vendor')[0]; 
        insert vendorAcct;
        
        singPostAddr = TestDataFactory.createSingpostAddress(1)[0];
        singPostAddr.Name = 'SPostal';
        singPostAddr.House_Block_Number__c = 'TEST';
        singPostAddr.Address_Type__c = 'A';
        insert singPostAddr;        
        
        address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c = 'A';
        address.Postal_Code__c = singPostAddr.Id;
        address.Block_House_Number__c ='TEST';
        address.Level_Number__c ='xx';
        address.Unit_Number__c = 'yy';
        insert address;        
        
        contact = TestDataFactory.createContact(1)[0];
        contact.Address__c = address.Id;
        contact.AccountId = vendorAcct.Id;
        contact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contact.Recipient_Indicator__c = true;
        insert contact;        
        
        aPackage = TestDataFactory.createPackage(1)[0]; 
        aPackage.Name = 'Pack name';
        aPackage.Billing_Type__c = 'Full Prepaid';
        aPackage.Package_Type__c = 'Base';
        aPackage.Subscription_Period__c = '18';
        aPackage.Package_Code__c = 'afds132';
        insert aPackage;        
        
        aCase = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        insert aCase;        
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Account__c = vendorAcct.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        insert billAcc; 
        
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = vendorAcct.Id;
        order.Informed_Customer__c = true;
        order.Recipient_Contact__c = contact.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Delivery_Charge__c = 10.00;
        order.Subscriber_Charge__c = 10.00;
        order.Eligible_for_Retention__c = true;
        //order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = 'Full Prepaid';
        //order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        //order.Postage_Charge__c = 200.00;
        insert order;
        
        System.debug('ASM order.Id = ' + order.Id);        
        
        orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
        orderLineItem.Order__c = order.Id;
        orderLineItem.Case__c = aCase.Id;        
        orderLineItem.Main_Package_ID__c = aPackage.Id;
        orderLineItem.End_Date__c = Date.today().addDays(30);
        orderLineItem.Term_Length__c = 0;
        orderLineItem.Main_Package_Period__c = 0;
        orderLineItem.Start_Date__c = Date.today().addDays(1);
        orderLineItem.Earliest_Start_Date__c = Date.today();
        orderLineItem.Earliest_Stop_Date__c = Date.today().addDays(2);
        orderLineItem.Stop_Request_Date__c =  Date.today().addDays(4);
        orderLineItem.Terminating_Reason__c = 'Others';
        orderLineItem.Amount_To_Refund__c = 0;
        orderLineItem.Admin_Charge__c = 0;
        orderLineItem.Fee_Waiver__c = true;
        orderLineItem.Fee_Override__c = false;
        orderLineItem.Override_Reason__c = 'TEST';
        orderLineItem.Suppress_Notification_Stop__c = true;
        orderLineItem.Main_Package_Type__c = 'Base';
        orderLineItem.Vendor_Mailing_Agent__c = vendorAcct.Id;
        insert orderLineItem;        
        
        System.debug('ASM orderLineItem.Vendor_Mailing_Agent__c = ' + orderLineItem.Vendor_Mailing_Agent__c);
                
        
        zouraSubscription = TestDataFactory.createSubscription(1)[0];        
        zouraSubscription.Zuora__Zuora_Id__c = 'zouraId';
        zouraSubscription.Zuora__Status__c = 'Active';
        zouraSubscription.Zuora__Account__c = vendorAcct.Id;
        zouraSubscription.Zuora__CustomerAccount__c = billAcc.id;
        zouraSubscription.Zuora__SubscriptionEndDate__c = Date.today().addDays(30);        
        
        zouraSubscription.Subscriber_Contact__c = contact.Id;
        zouraSubscription.Recipient_Contact__c = contact.Id;       
        
        zouraSubscription.Main_Package_1__c = aPackage.Id;
        zouraSubscription.Order_Number__c = order.Id;
        zouraSubscription.Order_Number_1__c = order.Id;
        zouraSubscription.Order_Line_Item_Number__c = orderLineItem.Id;
        zouraSubscription.Order_Line_Item_Number_1__c = orderLineItem.Id;
        
        zouraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
        zouraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
        zouraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zouraSubscription.Urgent__c = 'false';
        
        zouraSubscription.Vendor_Conversion__c = 'false';
        zouraSubscription.Vendor__c = vendorAcct.Id;
        zouraSubscription.Vendor_1__c = vendorAcct.Id;        
        
        zouraSubscription.Charity__c = 'false';
        zouraSubscription.Billing_Type__c = 'Full Prepaid';        
        
        zouraSubscription.Subscription_Type__c = 'Publication';
        zouraSubscription.Subscription_Type_1__c = 'Publication'; 
        zouraSubscription.Number_of_Copies1__c = '100';      
        insert zouraSubscription;        
        
        vendorAlloc = TestDataFactory.createVendorAlloc(1)[0];   
        vendorAlloc.Vendor_Account__c = vendorAcct.Id;
        vendorAlloc.SingPost_Address__c = singPostAddr.Id;
        vendorAlloc.Allocated__c = TRUE;
        vendorAlloc.Effective_Start_Date__c = Date.today();
        insert vendorAlloc;          
    }
    
    
    /**
        @name assignVendorControllerConstructorTest
        @param none
        @return void
        @description tests the class constructor
    */
    static testMethod void assignVendorControllerConstructorTest() {
        
        setUpData();        
        Test.startTest(); 
        
        System.assertNotEquals(orderLineItem, null);
           
        PageReference pRef = Page.AssignVendor;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('id', orderLineItem.Id);      
         
        new AssignVendorController();        
        //new AssignVendorController(new ApexPages.StandardController(orderLineItem)); 
                
        Test.stopTest();
    }
    
    
    /**
        @name saveTest
        @param none
        @return void
        @description tests the save and cancel methods
    */
    static testMethod void saveTest() {
        
        setUpData();        
        Test.startTest();
        
        System.assertNotEquals(orderLineItem, null);
           
        PageReference pRef = Page.AssignVendor;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('id', orderLineItem.Id);      
         
        AssignVendorController avc = new AssignVendorController(); 
        avc.selectedRadioButton = orderLineItem.Vendor_Mailing_Agent__c; 
        avc.save();
        avc.cancel();
     
        Test.stopTest();        
    }     
}