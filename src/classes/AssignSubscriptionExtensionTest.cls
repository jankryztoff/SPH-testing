@isTest(SeeAllData=True)
public class AssignSubscriptionExtensionTest {
    
    //static Zuora__Account__c ZA;
    //static Zuora__Subscription__c ZS;
    
    static testMethod void test_ASE(){
    
        Singpost_Address__c newPostal = TestDataFactory.createSingpostAddress(1)[0];
            
        Account newAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        newAccount.NRIC__c = 'T1234567R';
        insert newAccount;

/*           
        Package__c newPackage = new Package__c();
        newPackage = TestDataFactory.createPackage(1)[0];
        insert new List<sObject>{newPostal,newAccount,newPackage};
        
        
         //create Account
        Account newAccount = TestDataFactory.createAccount(1,'Direct Corporate')[0];
        newAccount.Name='TestAccount';
        newAccount.Phone='00000';
        insert newAccount;
        
        //create Singpost
        Singpost_Address__c newSA = TestDataFactory.createSingpostAddress(1)[0];
        insert newSA;
*/     

        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = newAccount.id;
        billingAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        database.insert(billingAcc);
        
        //create Package
        Package__c newPackage = TestDataFactory.createPackage(1)[0];
        newPackage.Name = 'Test Package';
        newPackage.Package_Type__c='Base';
        newPackage.Subscription_Type__c='Termed';
        newPackage.Effective_Start_Date__c=date.today();
        newPackage.Effective_End_Date__c=date.today()+100;
        newPackage.Subscription_Period__c='18';      
        insert newPackage;
        
//        newPackage.Package_Code__c='PackageCode';
//        update newPackage;
        
        //create Order
        Order__c newOrder = TestDataFactory.createOrder(1)[0];
        newOrder.Order_Type__c = 'Start';
        newOrder.Status__c = 'Draft';
        newOrder.Account__c = newAccount.Id;
        newOrder.Informed_Customer__c = TRUE;
        newOrder.Sub_Category__c = 'Stop Subscription';
        insert newOrder;
        
        //create Case
        Case newCase = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        newCase.Order__c = newOrder.Id;
        insert newCase;
        
        //create Order Line Item
        Order_Line_Item__c newOLI = TestDataFactory.createOrderLineItem(1)[0];
        newOLI.Order__c = newOrder.Id;
        newOLI.Main_Package_ID__c = newPackage.Id;
        newOLI.Is_Digital__c = true;
        newOLi.Start_Date__c = Date.today()+1;
        insert newOLI;
        
        //create Address
        Address__c newAddress = TestDataFactory.createAddress(1)[0];
        newAddress.Address_Type__c='P';
        newAddress.Postal_Code__c = newPostal.Id;
        insert newAddress;
        
        //create Contact
        Contact newContact = TestDataFactory.createContact(1)[0];
        newContact.Address__c = newAddress.Id;
        newContact.AccountId = newAccount.Id;
        newContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
        newContact.Address_Unique_Id__c = 'TestAddress';
//        insert newContact;               
        
        //create Zsub
         Zuora__Subscription__c newZ = TestDataFactory.createSubscription(1)[0];
                newZ.Zuora__Account__c = newAccount.Id;
                newZ.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                newZ.Subscriber_Contact__c = newContact.Id;
                newZ.Recipient_Contact__c = newContact.Id;
                newZ.Zuora__CustomerAccount__c = billingAcc.Id;
                //newZ.Recipient_Address_ID__c = newContact.Address_Unique_Id__c;
                //newZ.Main_Package_1__c = newPackage;
                newZ.Zuora__Status__c = 'Active';
                newZ.Order_Number__c = newOrder.Id;
                newZ.Suppress_Vendor_Start_Notice__c = 'false';
                newZ.Supressed_Acknowledgement_Letter__c = 'false';
                newZ.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                newZ.Urgent__c = 'false';
                newZ.Vendor_Conversion__c = 'false';
                newZ.Charity__c = 'false';
        insert newZ;
            
        
        //create Case_Subscription__c
        Case_Subscription__c newCS = TestDataFactory.createCaseSubscription(1)[0];
        newCS.Case__c = newCase.Id;
        newCS.Account__c = newAccount.Id;
        newCS.Subscription__c = newZ.Id;
        insert newCS;

        Test.startTest();
        
        // instantiate AssignSubscription vf page
        PageReference pageRef = Page.CaseAssignSelectedSubscription;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController testclassrun = new ApexPages.StandardController(newCase);        
        ApexPages.currentPage().getParameters().put('Id', newZ.Id);
        ApexPages.currentPage().getParameters().put('RecordType', newCase.RecordTypeID);
        
        // instantiate AssignSubscriptionExtension apex class
        AssignSubscriptionExtension extension = new AssignSubscriptionExtension(testclassrun);
        extension.submit();
        extension.cancel();
        extension.retrieveAddress();
        
        AssignSubscriptionExtension extension2 = new AssignSubscriptionExtension(testclassrun);
        List<AssignSubscriptionExtension.SubscriptionObj> SubsList = new List<AssignSubscriptionExtension.SubscriptionObj>();
        //AssignSubscriptionExtension.SubscriptionObj Subs = new AssignSubscriptionExtension.SubscriptionObj(newZ);
        //SubsList.add(Subs);
        extension2.SubscriptionList = SubsList;
        extension2.submit();
        
        Test.stopTest();
        
    }
    
    static testMethod void test_ASE2(){
        
        Singpost_Address__c newPostal = TestDataFactory.createSingpostAddress(1)[0];
            
        Account newAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        newAccount.NRIC__c = 'T1234567R';
        insert newAccount;

        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = newAccount.id;
        billingAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        database.insert(billingAcc);
        
        //create Package
        Package__c newPackage = TestDataFactory.createPackage(1)[0];
        newPackage.Name = 'Test Package';
        newPackage.Package_Type__c='Base';
        newPackage.Subscription_Type__c='Termed';
        newPackage.Effective_Start_Date__c=date.today();
        newPackage.Effective_End_Date__c=date.today()+100;
        newPackage.Subscription_Period__c='18';      
        insert newPackage;
        
//        newPackage.Package_Code__c='PackageCode';
//        update newPackage;
        
        //create Order
        Order__c newOrder = TestDataFactory.createOrder(1)[0];
        newOrder.Order_Type__c = 'Start';
        newOrder.Status__c = 'Draft';
        newOrder.Account__c = newAccount.Id;
        newOrder.Informed_Customer__c = TRUE;
        newOrder.Sub_Category__c = 'Stop Subscription';
        insert newOrder;
        
        //create Case
        Case newCase = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        newCase.Order__c = newOrder.Id;
        
            insert newCase;
        
        //create Order Line Item
        Order_Line_Item__c newOLI = TestDataFactory.createOrderLineItem(1)[0];
        newOLI.Order__c = newOrder.Id;
        newOLI.Main_Package_ID__c = newPackage.Id;
        newOLI.Is_Digital__c = true;
        newOLi.Start_Date__c = Date.today()+1;
        insert newOLI;
        
        //create Address
        Address__c newAddress = TestDataFactory.createAddress(1)[0];
        newAddress.Address_Type__c='P';
        newAddress.Postal_Code__c = newPostal.Id;
        insert newAddress;
        
        //create Contact
        Contact newContact = TestDataFactory.createContact(1)[0];
        newContact.Address__c = newAddress.Id;
        newContact.AccountId = newAccount.Id;
        newContact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
        newContact.Address_Unique_Id__c = 'TestAddress';
//        insert newContact;               
        
        //create Zsub
         Zuora__Subscription__c newZ = TestDataFactory.createSubscription(1)[0];
                newZ.Zuora__Account__c = newAccount.Id;
                newZ.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                newZ.Subscriber_Contact__c = newContact.Id;
                newZ.Recipient_Contact__c = newContact.Id;
                newZ.Zuora__CustomerAccount__c = billingAcc.Id;
                //newZ.Recipient_Address_ID__c = newContact.Address_Unique_Id__c;
                //newZ.Main_Package_1__c = newPackage;
                newZ.Zuora__Status__c = 'Active';
                newZ.Order_Number__c = newOrder.Id;
                newZ.Suppress_Vendor_Start_Notice__c = 'false';
                newZ.Supressed_Acknowledgement_Letter__c = 'false';
                newZ.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                newZ.Urgent__c = 'false';
                newZ.Vendor_Conversion__c = 'false';
                newZ.Charity__c = 'false';
       
            insert newZ;
        
        
        //create Case_Subscription__c
        Case_Subscription__c newCS = TestDataFactory.createCaseSubscription(1)[0];
        newCS.Case__c = newCase.Id;
        newCS.Account__c = newAccount.Id;
        newCS.Subscription__c = newZ.Id;
        
            insert newCS;
        try{
        Test.startTest();
        
        // instantiate AssignSubscription vf page
        PageReference pageRef = Page.CaseAssignSelectedSubscription;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController testclassrun = new ApexPages.StandardController(new Case());        
        ApexPages.currentPage().getParameters().put('id', newZ.Id);
        //ApexPages.currentPage().getParameters().put('RecordType', newCase.RecordTypeID);
        //try {
        AssignSubscriptionExtension extension2 = new AssignSubscriptionExtension(testclassrun);
        List<AssignSubscriptionExtension.SubscriptionObj> SubsList = new List<AssignSubscriptionExtension.SubscriptionObj>();
        //AssignSubscriptionExtension.SubscriptionObj Subs = new AssignSubscriptionExtension.SubscriptionObj(newZ);
        //SubsList.add(Subs);
        
        extension2.SubscriptionList = SubsList;
        extension2.submit();
        

        Test.stopTest();
        } catch (exception e){}
    }
    
}