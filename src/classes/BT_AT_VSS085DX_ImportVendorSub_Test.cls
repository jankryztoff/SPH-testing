/*
 * Class Name: BT_AT_VSS085DX_ImportVendorSub_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * @description A test class for BT_AT_VSS085DX_ImportVendorSubscription 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest
private class BT_AT_VSS085DX_ImportVendorSub_Test
{   
    /*Declaring variables to be used throughout the Class*/
    private static Key_Id__c keyId;
    private static Account newAccount;
    private static BT_CO_VSS_ImportVendorSubscription__c interfaceRecord;
    
    private static List<Contact> contactList = new List<Contact>();
    private static List<Address__c> addressRecordList = new List<Address__c>();
    private static List<Singpost_Address__c> SingAddList = new List<Singpost_Address__c>();
    private static List<BT_CO_LEG2SF_Log__c> LEG2SFList = new List<BT_CO_LEG2SF_Log__c>();
    private static List<Subscription_Vendor__c> SubVendList = new List<Subscription_Vendor__c>();
    private static List <Subscription_Vendor_Publication__c> subvenPubList = new List<Subscription_Vendor_Publication__c>();
    private static List<BT_CO_VSS_ImportVendorSubscription__c> interfaceRecordList = new List<BT_CO_VSS_ImportVendorSubscription__c>();
    
    public static List<BT_CO_VSS_ImportVendorSubscription__c> getInterfaceRecord(){
        interfaceRecord = new BT_CO_VSS_ImportVendorSubscription__c();
            interfaceRecord.Name = 'VSS085DX';
            interfaceRecord.cssCustomerIdForRecipient__c = 'a';
            interfaceRecord.cssCustomerIdForSubscriber__c = 'b';
            interfaceRecord.cssSubscriptionCode__c = 'c';
            interfaceRecord.effectiveDate__c = 'd';
            interfaceRecord.hdsClassificationId__c = 'e';
            interfaceRecord.hdsContactId__c = 'f';
            interfaceRecord.hdsRecipientId__c = 'g';
            interfaceRecord.hdsSubscriptionId__c = 'h';
            interfaceRecord.paymentCode__c = 'i';
            interfaceRecord.publicationCode__c = 'j';
            interfaceRecord.pubtag__c = 'k';
            interfaceRecord.rcpn__c = 'l';
            interfaceRecord.rcpnSbn__c = 'm';
            interfaceRecord.recipientBuildingCode__c = 'n';
            interfaceRecord.recipientCompanyName__c = 'o';
            interfaceRecord.recipientEmail__c = 'p';
            interfaceRecord.recipientFaxNumber__c = 'q';
            interfaceRecord.recipientHandphoneNumber__c = 'r';
            interfaceRecord.recipientHouseBlockNumber__c = 's';
            interfaceRecord.recipientLevel__c = 't';
            interfaceRecord.recipientName__c = 'u';
            interfaceRecord.recipientNric__c = 'v';
            interfaceRecord.recipientOfficeTelephoneExtension__c = 'w';
            interfaceRecord.recipientOfficeTelephoneNumber__c = 'x';
            interfaceRecord.recipientPostalCode__c = 'y';
            interfaceRecord.recipientResidenceTelephoneNumber__c = 'z';
            interfaceRecord.recipientSalutation__c = 'A';
            interfaceRecord.recipientStreetCode__c = 'B';
            interfaceRecord.recipientUnit__c = 'C';
            interfaceRecord.recipientUpdateIndicator__c = 'D';
            interfaceRecord.startDate__c = 'E';
            interfaceRecord.stopDate__c = 'F';
            interfaceRecord.subscriberBuildingCode__c = 'G';
            interfaceRecord.subscriberCompanyName__c = 'H';
            interfaceRecord.subscriberEmail__c = 'I';
            interfaceRecord.subscriberFaxNumber__c = 'J';
            interfaceRecord.subscriberHandphoneNumber__c = 'K';
            interfaceRecord.subscriberHouseBlockNumber__c = 'L';
            interfaceRecord.subscriberLevel__c = 'M';
            interfaceRecord.subscriberName__c = 'N';
            interfaceRecord.subscriberNric__c = 'O';
            interfaceRecord.subscriberOfficeTelephoneExtension__c = 'P';
            interfaceRecord.subscriberOfficeTelephoneNumber__c = 'Q';
            interfaceRecord.subscriberPostalCode__c = 'R';
            interfaceRecord.subscriberResidentTelephoneNumber__c = 'S';
            interfaceRecord.subscriberSalutation__c = 'T';
            interfaceRecord.subscriberStreetCode__c = 'U';
            interfaceRecord.subscriberUnit__c = 'V';
            interfaceRecord.subscriberUpdateIndicator__c = 'W';
            interfaceRecord.subscriptionCopies__c = 'X';
            interfaceRecord.subscriptionPeriod__c = 'Y';
            interfaceRecord.subscriptionUpdateIndicator__c = 'A';
            interfaceRecord.vendorGroup__c = 'a';
            interfaceRecord.vendorNumber__c = 'b';
            interfaceRecord.crsmAccountId__c = '4';
            interfaceRecord.crsmContactId__c = '5';
            interfaceRecord.crsmVendorSubscriptionId__c = '6';
            interfaceRecord.hdsComplimentaryTypeName__c = '6';
            interfaceRecord.Batch_Run_Date__c = date.today();
            interfaceRecord.hdsComplimentaryTypeName__c = '1';     
        interfaceRecordList.add(interfaceRecord);
        insert interfaceRecordList;
        return interfaceRecordList;
    }
    /*Author : Mayank Singh Rana*/
    /*Dated  : 11 Feb 2015*/
    /*Below class contains sample data created for subsequent usage in following test classes*/
    public static void testData()
    {
        /*
        keyId = new Key_Id__c();
            keyId.name = 'Contact_Customer Contact';
            keyId.Id__c = '012N00000008r43IAA';
            keyId.Type__c = 'Record Type';
        insert keyId;   
        */
        getInterfaceRecord();
        /*interfaceRecord = new BT_CO_VSS_ImportVendorSubscription__c();
            interfaceRecord.Name = 'VSS085DX';
            interfaceRecord.cssCustomerIdForRecipient__c = 'a';
            interfaceRecord.cssCustomerIdForSubscriber__c = 'b';
            interfaceRecord.cssSubscriptionCode__c = 'c';
            interfaceRecord.effectiveDate__c = 'd';
            interfaceRecord.hdsClassificationId__c = 'e';
            interfaceRecord.hdsContactId__c = 'f';
            interfaceRecord.hdsRecipientId__c = 'g';
            interfaceRecord.hdsSubscriptionId__c = 'h';
            interfaceRecord.paymentCode__c = 'i';
            interfaceRecord.publicationCode__c = 'j';
            interfaceRecord.pubtag__c = 'k';
            interfaceRecord.rcpn__c = 'l';
            interfaceRecord.rcpnSbn__c = 'm';
            interfaceRecord.recipientBuildingCode__c = 'n';
            interfaceRecord.recipientCompanyName__c = 'o';
            interfaceRecord.recipientEmail__c = 'p';
            interfaceRecord.recipientFaxNumber__c = 'q';
            interfaceRecord.recipientHandphoneNumber__c = 'r';
            interfaceRecord.recipientHouseBlockNumber__c = 's';
            interfaceRecord.recipientLevel__c = 't';
            interfaceRecord.recipientName__c = 'u';
            interfaceRecord.recipientNric__c = 'v';
            interfaceRecord.recipientOfficeTelephoneExtension__c = 'w';
            interfaceRecord.recipientOfficeTelephoneNumber__c = 'x';
            interfaceRecord.recipientPostalCode__c = 'y';
            interfaceRecord.recipientResidenceTelephoneNumber__c = 'z';
            interfaceRecord.recipientSalutation__c = 'A';
            interfaceRecord.recipientStreetCode__c = 'B';
            interfaceRecord.recipientUnit__c = 'C';
            interfaceRecord.recipientUpdateIndicator__c = 'D';
            interfaceRecord.startDate__c = 'E';
            interfaceRecord.stopDate__c = 'F';
            interfaceRecord.subscriberBuildingCode__c = 'G';
            interfaceRecord.subscriberCompanyName__c = 'H';
            interfaceRecord.subscriberEmail__c = 'I';
            interfaceRecord.subscriberFaxNumber__c = 'J';
            interfaceRecord.subscriberHandphoneNumber__c = 'K';
            interfaceRecord.subscriberHouseBlockNumber__c = 'L';
            interfaceRecord.subscriberLevel__c = 'M';
            interfaceRecord.subscriberName__c = 'N';
            interfaceRecord.subscriberNric__c = 'O';
            interfaceRecord.subscriberOfficeTelephoneExtension__c = 'P';
            interfaceRecord.subscriberOfficeTelephoneNumber__c = 'Q';
            interfaceRecord.subscriberPostalCode__c = 'R';
            interfaceRecord.subscriberResidentTelephoneNumber__c = 'S';
            interfaceRecord.subscriberSalutation__c = 'T';
            interfaceRecord.subscriberStreetCode__c = 'U';
            interfaceRecord.subscriberUnit__c = 'V';
            interfaceRecord.subscriberUpdateIndicator__c = 'W';
            interfaceRecord.subscriptionCopies__c = 'X';
            interfaceRecord.subscriptionPeriod__c = 'Y';
            interfaceRecord.subscriptionUpdateIndicator__c = 'A';
            interfaceRecord.vendorGroup__c = 'a';
            interfaceRecord.vendorNumber__c = 'b';
            interfaceRecord.crsmAccountId__c = '4';
            interfaceRecord.crsmContactId__c = '5';
            interfaceRecord.crsmVendorSubscriptionId__c = '6';
            interfaceRecord.hdsComplimentaryTypeName__c = '6';
            interfaceRecord.Batch_Run_Date__c = date.today();
            interfaceRecord.hdsComplimentaryTypeName__c = '1';     
        interfaceRecordList.add(interfaceRecord);
        insert interfaceRecordList;*/
        
        newAccount = TestDataFactory.createAccount(1,'Direct Corporate')[0];
            newAccount.Name='TestAccount';
            newAccount.Phone='00000';
            newAccount.Vendor_Code__c = '001';
            newAccount.Vendor_Group__c = 'V';
            newAccount.Vendor_Name__c = 'name';
        insert newAccount;
        
        Singpost_Address__c singadd = new Singpost_Address__c();
            singadd.Name = 'Name';
            singadd.Street_Name__c = 'Name';
            singadd.Number_of_Units__c = 3;
            singadd.Building_Name__c = 'Name';
            singadd.House_Block_Number__c = '3';
        SingAddList.add(singadd);
        insert SingAddList;
        
        Address__c addressRecord = TestDataFactory.createAddress(1)[0];
        addressRecord.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
        try{
        insert addressRecord;
        }catch(exception e){}
        /*
        Address__c addressRecord = new Address__c();
            //addressRecord.Street_Name__c = 'name';
            //addressRecord.Building_Name__c = 'name';
            addressRecord.Block_House_Number__c = '3';
            addressRecord.Level_Number__c  = '30';
            addressRecord.Unit_Number__c = '30';
            addressRecord.Postal_Code__c = singadd.Id;
        addressRecordList.add(addressRecord);
        insert addressRecordList;
        */
        
        Contact contact  = new Contact ();
            contact.FirstName = 'testa';
            contact.LastName = 'test';
            contact.Telephone_Residence__c = '123456';
            Contact.Telephone_Office__c = '123456';
            contact.Telephone_Office_Extension__c = '1234';
            contact.Fax__c = '123456';
            contact.Handphone_Number__c = '123456';
            contact.Email__c = 'test@test.com';
            contact.Company_Name__c = 'Name';
            contact.HDS_Contact_Id__c = 'hds';
            contact.Mobile_Number__c = '123456';
            contact.NRIC__c = 'T5275174A';
            contact.Active__c = false;
            contact.Address_Unique_Id__c = '45|1210 ';
            contact.Address__c = addressRecord.Id;
            contact.Billing_Account_Name_2__c = 'name';
            contact.Billing_Indicator__c =  true;
            contact.Company_Name__c = 'Name';
            contact.Contact_Legacy_Id__c = 'a';
            //contact.EditAddressFields__c = false; --field removed | April 11/3
            contact.Fax__c = '123456';
            contact.Handphone_Number__c = '123456';
            contact.HDS_Contact_Id__c = 'Name';
            contact.HomePhone__c = '123456';
            contact.Mobile_Number_2__c = '1234562';
            contact.Office_Extension__c = '123';
            contact.Office_Number__c = '123456';
            contact.Passport__c = 'Name';
            contact.Recipient_Indicator__c = true;
            contact.Recipient_Number__c = 123456;
            contact.Telephone_Office_Extension__c = '123456';
            contact.Telephone_Office__c = '123456';
            contact.Telephone_Residence__c = '123456';
            contact.Vendor_Communication_Preference__c = 'as';
            contact.VSS_Login_ID__c = '123456';
        contactList.add(contact);
        try{
        insert contactList;
        }catch(exception e){}
        Subscription_Vendor__c SubVendor = new Subscription_Vendor__c();
            SubVendor.Recipient__c = SubVendor.Id;
            SubVendor.Account__c =  newAccount.Id;
            SubVendor.Subscription_Start_Date__c = Date.today();
            Subvendor.Subscription_Stop_Date__c = date.today();
        SubVendList.add(SubVendor);
        insert SubVendList;
        
        Subscription_Vendor_Publication__c subvenpub = new Subscription_Vendor_Publication__c();
            subvenpub.Subscription_Vendor__c = SubVendor.Id;
        subvenPubList.add(subvenpub); 
        insert subvenPubList;
        
        BT_CO_LEG2SF_Log__c LEG2SF  = new BT_CO_LEG2SF_Log__c();
            LEG2SF.Invalid_Record_Count__c = 3.0;        
            LEG2SF.Total_Record_Count__c = 3.0;  
            LEG2SF.Valid_Record_Count__c = 3.0;
            LEG2SF.Interface_ID__c = 'DIR092DX';
            LEG2SF.Batch_Run_Date__c = date.today();
            LEG2SF.DML_Status__c = 'Failed';
            LEG2SF.Stack_Trace__c = 'Please see BT_CO_VSS_ImportVendorSubscription__c for validation details.';
        LEG2SFList.add(LEG2SF);
        insert LEG2SFList;
    }
    
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {
        testData();
        
        List<Zuora__SubscriptionProductCharge__c> spcList = TestDataFactory.createSubProductCharge(1);
         //create rates
        Integer count = 0;
        List<zqu__ProductRatePlanCharge__c> rateList = TestDataFactory.createProductRatePlanCharge(1);
        for (zqu__ProductRatePlanCharge__c plan: rateList)
        {  
            plan.Name = spcList[count].Name;
            plan.PublicationCode__c = 'Y';
            count++;
        }
        insert rateList;
        
        //insert publication
        Integer z = 0;
        List<Publication__c> pubList = TestDataFactory.createPublication(1);
        for(Publication__c svp: pubList)
        {
            svp.Publication_Code__c = rateList[z].PublicationCode__c;
            svp.Published_Days__c = 'Y';
            svp.Publication_Type__c = 'Y';
            svp.Published_Days__c = '0';
            z++;
        }
        
        /*Test.startTest();
        insert SingAddList;
        insert contactList;
        insert addressRecordList;
        insert SubVendList;
        insert interfaceRecordList;
        insert subvenPubList;
        insert pubList;
        insert LEG2SFList;
        Test.stopTest();*/   
    }

    static testMethod void testInterfaceApexTrigger2()
    {
        List<BT_CO_VSS_ImportVendorSubscription__c> recordsList = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        BT_CO_VSS_ImportVendorSubscription__c records = new BT_CO_VSS_ImportVendorSubscription__c();
        BT_CO_VSS_ImportVendorSubscription__c records2 = new BT_CO_VSS_ImportVendorSubscription__c();
        recordsList.add(records);
        recordsList.add(records2);
        List<Account> vendorAccountList = new List<Account>();
        List<Publication__c> publicationList = new List<Publication__c>();
        List<Subscription_Vendor__c> subscriptionVendorList = new List<Subscription_Vendor__c>();
        List<Subscription_Vendor_Publication__c> subscriptionVendorPublicationList = new List<Subscription_Vendor_Publication__c>();
        
        Test.startTest();
        try{
            insert recordsList;
        }
        catch(DmlException e){
            System.assert(e.getMessage().contains('Could not perform insert operation because batch size is greater than 1. Maximum batch size for this interface is 1.'));
        }
        Test.stopTest();

    }//end of testInterfaceApexTrigger2
    
    /*Author : Mayank Singh Rana*/
    /*Dated  : 11 Feb 2015*/
    /*Below class contains conditions to increase the coverage*/
    static testMethod void testMethod1()
    {
        List<BT_CO_VSS_ImportVendorSubscription__c> importVendorSubscriptionList = getInterfaceRecord();
        BT_CO_VSS_ImportVendorSubscription__c btObject = importVendorSubscriptionList[0];       
        btObject.subscriptionUpdateIndicator__c = 'U';  
        //btObject.recipientUpdateIndicator__c = 'U';
        update btObject;
    }
    static testMethod void testMethod2()
    {
        List<BT_CO_VSS_ImportVendorSubscription__c> importVendorSubscriptionList = getInterfaceRecord();
        BT_CO_VSS_ImportVendorSubscription__c btObject = importVendorSubscriptionList[0];       
        btObject.subscriptionUpdateIndicator__c = 'P';      
        update btObject;
    }
    static testMethod void testMethod3()
    {
        List<BT_CO_VSS_ImportVendorSubscription__c> importVendorSubscriptionList = getInterfaceRecord();
        BT_CO_VSS_ImportVendorSubscription__c btObject = importVendorSubscriptionList[0];       
        btObject.subscriptionUpdateIndicator__c = 'D';      
        update btObject;
    }
    static testMethod void testMethod4()
    {
        List<BT_CO_VSS_ImportVendorSubscription__c> importVendorSubscriptionList = getInterfaceRecord();
        BT_CO_VSS_ImportVendorSubscription__c btObject = importVendorSubscriptionList[0];       
        btObject.subscriptionUpdateIndicator__c = 'V';      
        update btObject;
    }
    static testMethod void testMethod5()
    {
        List<BT_CO_VSS_ImportVendorSubscription__c> importVendorSubscriptionList = getInterfaceRecord();
        BT_CO_VSS_ImportVendorSubscription__c btObject = importVendorSubscriptionList[0];       
        btObject.subscriptionUpdateIndicator__c = 'R';      
        update btObject;
    }
    static testMethod void testMethod6()
    {
        List<BT_CO_VSS_ImportVendorSubscription__c> importVendorSubscriptionList = getInterfaceRecord();
        BT_CO_VSS_ImportVendorSubscription__c btObject = importVendorSubscriptionList[0];       
        btObject.recipientUpdateIndicator__c = 'U';
        update btObject;
    }
}