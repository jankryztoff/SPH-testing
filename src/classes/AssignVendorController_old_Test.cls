@isTest(SeeAllData=True)
public class AssignVendorController_old_Test
{    
    static List<Contact> conList;
    static List<Case> cas;
    static List<Order_Line_Item__c> orderline;
    static List<Order__c> orderRec;
    static List<Zuora__Subscription__c> zSub;
    static Account venAccount;
    static string selectedRadioButton;
    static Singpost_Address__c postal;
    
    public static void setupRecords()
    {   
        Project__c pro = TestDataFactory.createProject(1)[0];
        pro.Project_Description__c = 'This is a new confidential project.';

        Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        Account agentAccount = TestDataFactory.createAccount(1, 'Mailing Agent')[0];

        postal = TestDataFactory.createSingpostAddress(1)[0];

        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];

        Package__c pack = TestDataFactory.createPackage(1)[0];

        venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
            insert new List<sObject>{pro, postal, venAccount, vendorSubsAcct, agentAccount, pack, subsVen};
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
        
        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
            billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
            insert billingAcc;
        
        conList = TestDataFactory.createContact(2);
            conList[0].Address__c = addressRec.Id;
            conList[0].AccountId = vendorSubsAcct.Id;
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            conList[0].Recipient_Indicator__c = true;
            conList[1].Address__c = addressRec.Id;
            conList[1].AccountId = agentAccount.Id;
            conList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            conList[1].Recipient_Indicator__c = true;
            insert conList;
        
        orderRec = TestDataFactory.createOrder(2);
            orderRec[0].Account__c = vendorSubsAcct.Id;
            orderRec[0].Informed_Customer__c = TRUE;
            orderRec[0].Recipient_Contact__c = conList[0].Id;
            orderRec[1].Account__c = agentAccount.Id;
            orderRec[1].Informed_Customer__c = TRUE;
            orderRec[1].Recipient_Contact__c = conList[1].Id;
            insert orderRec;       

        cas = TestDataFactory.createCase(2, 'Complaint - Magazine');
            cas[0].Order__c = orderRec[0].Id;
            cas[1].Order__c = orderRec[1].Id;
            insert cas;
        
        orderline = TestDataFactory.createOrderLineItem(2);
            orderline[0].Order__c = orderRec[0].Id;
            orderline[0].End_Date__c = date.newInstance(2015, 1, 13);
            orderline[0].Main_Package_ID__c = pack.Id;
            orderline[0].Case__c = cas[0].id;
            orderline[0].Vendor_Mailing_Agent__c = venAccount.Id;
            orderline[0].Vendor_Subscription_ID__c = subsVen.Id;
            /*orderline[1].Order__c = orderRec[1].Id;*/
            orderline[1].End_Date__c = date.newInstance(2015, 1, 13);
            orderline[1].Main_Package_ID__c = pack.Id;
            orderline[1].Case__c = cas[1].id;
            orderline[1].Vendor_Mailing_Agent__c = venAccount.Id;
            orderline[1].Vendor_Subscription_ID__c = subsVen.Id;
            /*insert orderline;*/
        
        zSub = TestDataFactory.createSubscription(2);
            zSub[0].Zuora__Account__c = vendorSubsAcct.Id;
            zSub[0].Order_Line_Item_Number__c = orderline[0].Id;
            zSub[0].Order_Number__c = orderRec[0].Id;
            zSub[0].Suppress_Vendor_Start_Notice__c = 'false';
            zSub[0].Supressed_Acknowledgement_Letter__c = 'false';
            zSub[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub[0].Urgent__c = 'false';
            zSub[0].Vendor_Conversion__c = 'false';
            zSub[0].Charity__c = 'false';
            zSub[1].Zuora__Account__c = vendorSubsAcct.Id;
            zSub[1].Order_Line_Item_Number__c = orderline[1].Id;
            zSub[1].Order_Number__c = orderRec[1].Id;
            insert zSub;
        
        Parcel__c par = TestDataFactory.createParcel(1)[0];
            par.Project_Name__c = pro.Id;
            par.Allocation_Type__c = 'SDA';
            par.Description__c = 'Description';
            insert par;
        
        Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
            venAlloc.SingPost_Address__c = postal.Id;
            venAlloc.Vendor_Account__c = venAccount.Id;
            venAlloc.Parcel_Name__c = par.Id;
            insert venAlloc;
    }   
    
    public static testMethod void AssignVendorControllerTest()
    {
        /*setupRecords();*/
    
        PageReference pageRef = Page.AssignVendor;
        /*pageRef.getParameters().put('id',orderline[0].Id);  */ 
        Test.setCurrentPage(pageRef);       
        //AssignVendorController controller = new AssignVendorController(new ApexPages.StandardController(orderline[0])); 
    }    
    
    public static testMethod void AssignVendorControllerTest2()
    {
        /*setupRecords();*/
    
        PageReference pRef = Page.AssignVendor;
        Test.setCurrentPage(pRef);
        /*ApexPages.currentPage().getParameters().put('id', orderline[0].Id);*/  
        AssignVendorController controller = new AssignVendorController();
 
        /*controller.save();*/
        System.assertEquals(null, controller.cancel());     

        /*Vendor_Allocation__c val = new Vendor_Allocation__c(SingPost_Address__c = postal.Id, Vendor_Account__c = venAccount.Id);
        AssignVendorController.vaWrapper wrap = new AssignVendorController.vaWrapper(val); */
    } 
}