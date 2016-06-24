/*  
    Version     : 1.0
    Company     : Accenture Cloud First
    Date        : June.15.2016
    Author      : Enen Fernandez
    Description : Merge class of SP_VendorSubscriptionNotificationsTest and SP_VendorSubscriptionNotificationsTest2
    History     : June.15.2016: Removed deprecated statements
                  June.15.2016: Changed method names
                  June.15.2016: Added additional test methods
                  June.15.2016: Changed (seeAllData) to FALSE
*/
@isTest(seeAllData = false)
public class SP_VendorSubscriptionNotificationsTest3 {

    @testSetup
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createBatchConfig();
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createCharge();
        insert CustomSettingsDataFactory.createChargeType();
        insert CustomSettingsDataFactory.createZuora_HPM_Settings();
        insert CustomSettingsDataFactory.createError_Messages();
        insert CustomSettingsDataFactory.createARMSInterface();
        insert CustomSettingsDataFactory.createUom();
        insert CustomSettingsDataFactory.createUnit_of_Measure();
    }

    static testmethod void test_SP_VendorSubscriptionNotifications01() {

        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        singAdd.Name = '013';
        insert singAdd;


        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '923429';
        acc.Email__c = 'test@test.com';
        acc.Vendor_Code__c = 'Code1';
        acc.Vendor_Group__c = '1';
        database.insert(acc);


        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;


        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].Email = 'test@sample.com';
        conList[0].Vendor_Communication_Preference__c = 'Both';
        conList[0].HomePhone__c = '09155568874';
        conList[0].Email = 'test@test.com';
        insert conList;



        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;



        //Temp Stop
        List < Temp_Stop__c > tempStop = TestDataFactory.createTempStop(4);
        tempStop[0].Temp_Stop_Date__c = Date.today();
        tempStop[0].Restart_Date__c = Date.today() + 1;
        tempStop[0].Remarks__c = 'Sample Remarks';
        tempStop[0].Cancelled__c = false;

        tempStop[1].Temp_Stop_Date__c = Date.today();
        tempStop[1].Restart_Date__c = Date.today() + 1;
        tempStop[1].Remarks__c = 'Sample Remarks';
        tempStop[1].Cancelled__c = false;

        tempStop[2].Temp_Stop_Date__c = Date.today() + 1;
        tempStop[2].Restart_Date__c = Date.today() + 2;
        tempStop[2].Remarks__c = 'Sample Remarks';
        tempStop[2].Cancelled__c = false;

        tempStop[3].Temp_Stop_Date__c = Date.today();
        tempStop[3].Restart_Date__c = Date.today() + 1;
        tempStop[3].Remarks__c = 'Sample Remarks';
        tempStop[3].Cancelled__c = false;
        insert tempStop;


        //Case
        List < Case > cs = TestDataFactory.createCase(4, 'Change of Address/Vendor');
        cs[0].AccountId = acc.id;
        cs[0].Effective_Date__c = Date.today() + 1;
        cs[0].COA__c = true;
        cs[0].Temp_Stop__c = tempStop[0].id;
        cs[0].Status = 'Closed';
        cs[0].Order__c = orderRec.id;
        cs[0].Vendor__c = acc.id;
        cs[0].Change_of_Address_Type__c = 'Change of Vendor';
        cs[0].Contact_To_Update__c = conList[0].id;
        cs[0].New_Address__c = addressRec.id;
        cs[0].Temp_Stop_Date__c = Date.today();
        cs[0].restart_date__c = date.today() + 1;
        cs[0].Vendor_Chargeable_Courier__c = true;
        cs[0].Vendor_Chargeable_Paper__c = false;
        cs[0].Vendor_Email__c = 'test@test.com';
        cs[0].Vendor_No__c = '1234567';
        cs[0].Vendor_Subscription_Created__c = true;

        cs[1].AccountId = acc.id;
        cs[1].Effective_Date__c = Date.today() + 1;
        cs[1].COA__c = true;
        cs[1].Temp_Stop__c = tempStop[1].id;
        cs[1].Status = 'Closed';
        cs[1].Order__c = orderRec.id;
        //cs[1].Vendor__c = acc.id;
        cs[1].Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        //cs[1].Change_of_Address_Type__c = 'Change of Vendor';
        cs[1].Contact_To_Update__c = conList[0].id;
        cs[1].New_Address__c = addressRec.id;
        cs[1].Temp_Stop_Date__c = Date.today();
        cs[1].restart_date__c = date.today() + 2;
        cs[1].Vendor_Chargeable_Courier__c = true;
        cs[1].Vendor_Chargeable_Paper__c = false;
        cs[1].Vendor_Email__c = 'test@test.com';
        cs[1].Vendor_No__c = '1234567';
        cs[1].Vendor_Subscription_Created__c = true;


        cs[2].RecordtypeId = ConstantsSLB.getKeyId('Case_Stop');
        cs[2].AccountId = acc.id;
        cs[2].Effective_Date__c = Date.today() + 1;
        cs[2].COA__c = true;
        cs[2].Temp_Stop__c = tempStop[2].id;
        cs[2].Status = 'Closed';
        cs[2].Order__c = orderRec.id;
        cs[2].Vendor__c = acc.id;
        cs[2].Change_of_Address_Type__c = 'Change of Vendor';
        cs[2].Contact_To_Update__c = conList[0].id;
        cs[2].New_Address__c = addressRec.id;
        //cs[1].Temp_Stop_Date__c = Date.today();
        cs[2].Temp_Stop_Date__c = Date.today().addDays(1);
        cs[2].restart_date__c = date.today() + 2;
        cs[2].Vendor_Chargeable_Courier__c = true;
        cs[2].Vendor_Chargeable_Paper__c = false;
        cs[2].Vendor_Email__c = 'test@test.com';
        cs[2].Vendor_No__c = '1234567';
        cs[2].Vendor_Subscription_Created__c = true;

        cs[3].RecordtypeId = ConstantsSLB.getKeyId('Case_Temp Stop');
        cs[3].AccountId = acc.id;
        cs[3].Effective_Date__c = Date.today() + 1;
        cs[3].COA__c = true;
        cs[3].Temp_Stop__c = tempStop[3].id;
        cs[3].Status = 'Closed';
        cs[3].Order__c = orderRec.id;
        cs[3].Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        //cs[3].Change_of_Address_Type__c = 'Change of Vendor';
        cs[3].Contact_To_Update__c = conList[0].id;
        cs[3].New_Address__c = addressRec.id;
        //cs[1].Temp_Stop_Date__c = Date.today();
        cs[3].Temp_Stop_Date__c = Date.today();
        cs[3].Restart_date__c = date.today() + 1;
        //cs[3].Vendor__c = acc.id;
        cs[3].Vendor_Chargeable_Courier__c = true;
        cs[3].Vendor_Chargeable_Paper__c = false;
        cs[3].Vendor_Email__c = 'test@test.com';
        cs[3].Vendor_No__c = '1234567';
        cs[3].Vendor_Subscription_Created__c = true;
    
        insert cs;



        List < Subscription_Vendor__c > subVen = TestDataFactory.createSubscriptionVendor(4);
        subVen[0].Account__c = acc.id;
        subVen[0].Vendor__c = acc.id;
        subVen[0].Recipient__c = conList[0].id;
        subVen[0].Subscription_Stop_Date__c = date.today() + 1;

        subVen[1].Account__c = acc.id;
        subVen[1].Vendor__c = acc.id;
        subVen[1].Recipient__c = conList[0].id;
        subVen[1].Subscription_Stop_Date__c = date.today() + 1;

        subVen[2].Account__c = acc.id;
        subVen[2].Vendor__c = acc.id;
        subVen[2].Recipient__c = conList[0].id;
        subVen[2].Subscription_Stop_Date__c = date.today() + 1;

        subVen[3].Account__c = acc.id;
        subVen[3].Vendor__c = acc.id;
        subVen[3].Recipient__c = conList[0].id;
        subVen[3].Subscription_Stop_Date__c = date.today() + 1;
        insert subVen;


        List < Case_Vendor_Subscription__c > csVenSub = TestDataFactory.createCaseVendorSub(4);
        csVenSub[0].Case__c = cs[0].id;
        csVenSub[0].Subscription_Vendor__c = subVen[0].id;
        csVenSub[0].Account__c = acc.id;
        csVenSub[0].Address__c = addressRec.id;

        csVenSub[1].Case__c = cs[1].id;
        csVenSub[1].Subscription_Vendor__c = subVen[1].id;
        csVenSub[1].Account__c = acc.id;
        csVenSub[1].Address__c = addressRec.id;

        csVenSub[2].Case__c = cs[2].id;
        csVenSub[2].Subscription_Vendor__c = subVen[2].id;
        csVenSub[2].Account__c = acc.id;
        csVenSub[2].Address__c = addressRec.id;

        csVenSub[3].Case__c = cs[3].id;
        csVenSub[3].Subscription_Vendor__c = subVen[3].id;
        csVenSub[3].Account__c = acc.id;
        csVenSub[3].Address__c = addressRec.id;

        insert csVenSub;


        List < Order_Line_Item_Vendor__c > orderlineVendor = TestdataFactory.createOrderLineItemVendor(4);
        orderlineVendor[0].Start_Date__c = date.today().addDays(1);
        orderlineVendor[0].Order__c = orderRec.id;
        orderlineVendor[0].Case__c = cs[0].id;
        orderlineVendor[0].Subscription_Vendor__c = subVen[0].id;

        orderlineVendor[1].Start_Date__c = date.today().addDays(1);
        orderlineVendor[1].Order__c = orderRec.id;
        orderlineVendor[1].Case__c = cs[1].id;
        orderlineVendor[1].Subscription_Vendor__c = subVen[1].id;

        orderlineVendor[2].Start_Date__c = date.today().addDays(1);
        orderlineVendor[2].Order__c = orderRec.id;
        orderlineVendor[2].Case__c = cs[2].id;
        orderlineVendor[2].Subscription_Vendor__c = subVen[2].id;

        orderlineVendor[3].Start_Date__c = date.today().addDays(1);
        orderlineVendor[3].Order__c = orderRec.id;
        orderlineVendor[3].Case__c = cs[3].id;
        orderlineVendor[3].Subscription_Vendor__c = subVen[3].id;
        database.insert(orderlineVendor);


        //Sunday_Publication__r
        List < Publication__c > sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);


        //Publication__c
        List < Publication__c > publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication: publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);


        Address_Assignment__c addAss1 = new Address_Assignment__c();
        addAss1.Case__c = cs[0].id;
        addAss1.Address__c = addressRec.id;
        addAss1.Contact__c = conList[0].id;
        addAss1.Effective_Date__c = Date.today().addDays(2);
        addAss1.Vendor__c = acc.id;
        insert addAss1;

        Address_Assignment__c addAss2 = new Address_Assignment__c();
        addAss2.Case__c = cs[1].id;
        addAss2.Address__c = addressRec.id;
        addAss2.Contact__c = conList[0].id;
        addAss2.Effective_Date__c = Date.today().addDays(2);
        addAss2.Vendor__c = acc.id;
        insert addAss2;

        Address_Assignment__c addAss3 = new Address_Assignment__c();
        addAss3.Case__c = cs[2].id;
        addAss3.Address__c = addressRec.id;
        addAss3.Contact__c = conList[0].id;
        addAss3.Effective_Date__c = Date.today().addDays(2);
        addAss3.Vendor__c = acc.id;
        insert addAss3;

        Address_Assignment__c addAss4 = new Address_Assignment__c();
        addAss4.Case__c = cs[3].id;
        addAss4.Address__c = addressRec.id;
        addAss4.Contact__c = conList[0].id;
        addAss4.Effective_Date__c = Date.today().addDays(2);
        addAss4.Vendor__c = acc.id;
        insert addAss4;


        Postal_Zone__c postalZone = new Postal_Zone__c();
        postalZone.Name = '01';
        database.insert(postalZone);

        User myUser = [SELECT Id, IsActive from User where IsActive = true LIMIT 1];
        Post_Sector_Ops_Rep_Mapping__c postSector = new Post_Sector_Ops_Rep_Mapping__c();
        postSector.Zone__c = postalZone.id;
        postSector.Vendor_Ops__c = myUser.Id;
        //[SELECT Id, IsActive from User where IsActive = true and Id != null LIMIT 1].id;
        //postSector.Vendor_Ops__c = u.id;
        database.insert(postSector);


        List < Subscription_Vendor_Publication__c > subVenPub = TestDataFactory.createVendorPublication(4);
        subVenPub[0].Subscription_Vendor__c = subVen[0].id;
        subVenPub[0].Publication__c = publicationList[0].id;
        subVenPub[0].Mon__c = 1;
        subVenPub[0].Tue__c = 2;
        subVenPub[0].Wed__c = 3;
        subVenPub[0].Thu__c = 4;
        subVenPub[0].Fri__c = 5;
        subVenPub[0].Sat__c = 6;
        subVenPub[0].Sun__c = 7;

        subVenPub[1].Subscription_Vendor__c = subVen[1].id;
        subVenPub[1].Publication__c = publicationList[0].id;
        subVenPub[1].Mon__c = 1;
        subVenPub[1].Tue__c = 2;
        subVenPub[1].Wed__c = 3;
        subVenPub[1].Thu__c = 4;
        subVenPub[1].Fri__c = 5;
        subVenPub[1].Sat__c = 6;
        subVenPub[1].Sun__c = 7;


        subVenPub[2].Subscription_Vendor__c = subVen[2].id;
        subVenPub[2].Publication__c = publicationList[0].id;
        subVenPub[2].Mon__c = 1;
        subVenPub[2].Tue__c = 2;
        subVenPub[2].Wed__c = 3;
        subVenPub[2].Thu__c = 4;
        subVenPub[2].Fri__c = 5;
        subVenPub[2].Sat__c = 6;
        subVenPub[2].Sun__c = 7;

        subVenPub[3].Subscription_Vendor__c = subVen[3].id;
        subVenPub[3].Publication__c = publicationList[0].id;
        subVenPub[3].Mon__c = 1;
        subVenPub[3].Tue__c = 2;
        subVenPub[3].Wed__c = 3;
        subVenPub[3].Thu__c = 4;
        subVenPub[3].Fri__c = 5;
        subVenPub[3].Sat__c = 6;
        subVenPub[3].Sun__c = 7;
        insert subVenPub;

        Set <Case_Vendor_Subscription__c>  caseVendorIdSet = new Set <Case_Vendor_Subscription__c>();
        caseVendorIdSet.add(csVenSub[0]);
        
        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch();
        SP_VendorSubscriptionNotificationsBatch batch2 = new SP_VendorSubscriptionNotificationsBatch(new set < id > {
            cs[0].Id,
            cs[1].Id,
            cs[2].Id,
            cs[3].id
        });
        ID batchprocessid2 = Database.executeBatch(batch2, 200);
        Test.stopTest();

    }

    static testmethod void test_SP_VendorSubscriptionNotifications02() {


        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;

        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '923429';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].Email = 'test@sample.com';
        conList[0].Vendor_Communication_Preference__c = 'Both';
        conList[0].HomePhone__c = '09155568874';
        insert conList;
        system.debug('CON**: ' + conList[0].Id);
        String profName = 'Partner Community User';
        Profile prof = [Select Id From Profile Where Name =: profName AND UserLicense.Name =: GlobalVariableClass.USER_LICENSE Limit 1];
        User UserNew =
            new User(
                ContactId = conList[0].id,
                //UserNew.ProfileId = prof.id;
                Alias = 'standard',
                Email = 'standarduser@gmail.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = prof.id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userstand3541987*@testorg.com'
            );


        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today() + 1;
        tempStop.Restart_Date__c = Date.today() + 2;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;

        //Case
        Case cs = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cs.AccountId = acc.id;
        cs.Effective_Date__c = Date.today() + 1;
        cs.COA__c = true;
        cs.Temp_Stop__c = tempStop.id;
        cs.Status = 'Closed';
        cs.Order__c = orderRec.id;
        cs.Vendor__c = acc.id;
        cs.Change_of_Address_Type__c = 'Change of Vendor';
        cs.Contact_To_Update__c = conList[0].id;
        cs.Remarks__c = 'Sample Remarks';
        insert cs;

        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.id;
        subVen.Vendor__c = acc.id;
        insert subVen;

        Case_Vendor_Subscription__c csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;

        //Sunday_Publication__r
        List < Publication__c > sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);


        //Publication__c
        List < Publication__c > publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication: publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);

        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = publicationList[0].id;
        insert subVenPub;


        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch();
        SP_VendorSubscriptionNotificationsBatch batch2 = new SP_VendorSubscriptionNotificationsBatch(new set < id > {
            cs.Id
        });
        ID batchprocessid2 = Database.executeBatch(batch2, 200);
        Test.stopTest();

    }

    static testmethod void test_SP_VendorSubscriptionNotifications03() {


        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        singAdd.Name = 'Test';
        insert singAdd;


        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].Email = 'test@sample.com';
        conList[0].Vendor_Communication_Preference__c = 'Both';
        conList[0].HomePhone__c = '09155568874';
        insert conList;


        String profName = 'Partner Community User';
        Profile prof = [Select Id From Profile Where Name =: profName AND UserLicense.Name =: GlobalVariableClass.USER_LICENSE Limit 1];
        User UserNew =
            new User(
                ContactId = conList[0].id,
                Alias = 'standard',
                Email = 'standarduser@gmail.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = prof.id, //ConstantsSLB.getKeyId('Profile_Partner Community User'),
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userstand3541987*@testorg.com'
            );

        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today() + 1;
        tempStop.Restart_Date__c = Date.today() + 2;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;

        //Case
        Case cs = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cs.AccountId = acc.id;
        cs.Effective_Date__c = Date.today() + 1;
        cs.COA__c = true;
        cs.Temp_Stop__c = tempStop.id;
        cs.Status = 'Closed';
        cs.Order__c = orderRec.id;
        cs.Vendor__c = acc.id;
        cs.Change_of_Address_Type__c = 'Change of Vendor';
        cs.Contact_To_Update__c = conList[0].id;
        cs.Remarks__c = 'Sample Remarks';
        insert cs;

        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.id;
        subVen.Vendor__c = acc.id;
        insert subVen;

        Case_Vendor_Subscription__c csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;

        //Sunday_Publication__r
        List < Publication__c > sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);

        //Publication__c
        List < Publication__c > publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication: publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);

        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = publicationList[0].id;
        insert subVenPub;

        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);


        Postal_Zone__c postalZone = new Postal_Zone__c();
        postalZone.Name = 'Test';
        database.insert(postalZone);

        User myUser2 = [SELECT Id, IsActive from User where IsActive = true LIMIT 1];
        Post_Sector_Ops_Rep_Mapping__c postSector = new Post_Sector_Ops_Rep_Mapping__c();
        postSector.Zone__c = postalZone.id;
        postSector.Vendor_Ops__c = myUser2.Id; //[SELECT Id from User where IsActive = true LIMIT 1].id;
        database.insert(postSector);


        SP_VendorSubscriptionNotificationsBatch batch2 = new SP_VendorSubscriptionNotificationsBatch(new set < id > {
            cs.Id
        });
        ID batchprocessid2 = Database.executeBatch(batch2, 200);
        Test.stopTest();

    }


    static testmethod void test_SP_VendorSubscriptionNotifications04() {

        //setCustomSettings();

        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;

        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '09155568874';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].HomePhone__c = '09155568874';
        insert conList;

        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today() + 1;
        tempStop.Restart_Date__c = Date.today() + 2;
        tempStop.cancelled__c = false;
        insert tempStop;

        //Case
        Case cs = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cs.AccountId = acc.id;
        cs.Effective_Date__c = Date.today() + 1;
        cs.COA__c = true;
        cs.Temp_Stop__c = tempStop.id;
        cs.Status = 'Closed';
        cs.Order__c = orderRec.id;
        //cs.Vendor__c = acc.id; //xxx
        cs.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        cs.Contact_To_Update__c = conList[0].id;
        cs.New_Address__c = addressRec.id;
        cs.Temp_Stop_Date__c = Date.today();
        cs.restart_date__c = date.today() + 1;
        insert cs;

        //Case2
        Case cs2 = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cs2.AccountId = acc.id;
        cs2.Effective_Date__c = Date.today() + 1;
        cs2.COA__c = true;
        cs2.Temp_Stop__c = tempStop.id;
        cs2.Status = 'Closed';
        cs2.Order__c = orderRec.id;
        //cs.Vendor__c = acc.id;
        cs2.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        cs2.Contact_To_Update__c = conList[0].id;
        cs2.New_Address__c = addressRec.id;
        cs2.Temp_Stop_Date__c = Date.today().addDays(1);
        cs2.restart_date__c = date.today() + 2;
        insert cs2;

        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.id;
        subVen.Vendor__c = acc.id;
        insert subVen;

        Case_Vendor_Subscription__c csVenSub = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub.Case__c = cs.id;
        csVenSub.Subscription_Vendor__c = subVen.id;
        csVenSub.Account__c = acc.id;
        insert csVenSub;

        Case_Vendor_Subscription__c csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs2.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;

        //Sunday_Publication__r
        List < Publication__c > sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);

        //Publication__c
        List < Publication__c > publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication: publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);

        Address_Assignment__c addAss = new Address_Assignment__c();
        addAss.Case__c = cs.id;
        addAss.Address__c = addressRec.id;
        addAss.Contact__c = conList[0].id;
        addAss.Effective_Date__c = Date.today().addDays(2);
        addAss.Vendor__c = acc.id;
        insert addAss;

        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    }

    static testmethod void test_SP_VendorSubscriptionNotifications05() {

        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;

        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '09155568874';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        addressRec.Block_House_Number__c = '213';
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].HomePhone__c = '09155568874';
        insert conList;

        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today() + 1;
        tempStop.Restart_Date__c = Date.today() + 2;
        insert tempStop;

        //Case2
        Case cs2 = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cs2.AccountId = acc.id;
        cs2.Effective_Date__c = Date.today() + 1;
        cs2.COA__c = true;
        cs2.Temp_Stop__c = tempStop.id;
        cs2.Status = 'Closed';
        cs2.Order__c = orderRec.id;
        cs2.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        cs2.Contact_To_Update__c = conList[0].id;
        cs2.New_Address__c = addressRec.id;
        cs2.Temp_Stop_Date__c = Date.today().addDays(1);
        insert cs2;

        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.id;
        subVen.Vendor__c = acc.id;
        insert subVen;

        Case_Vendor_Subscription__c csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs2.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;

        //Sunday_Publication__r
        List < Publication__c > sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);

        //Publication__c
        List < Publication__c > publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication: publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);

        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = sundayPublicationList[0].id;
        insert subVenPub;

        Address_Assignment__c addAss = new Address_Assignment__c();
        addAss.Case__c = cs2.id;
        addAss.Address__c = addressRec.id;
        addAss.Contact__c = conList[0].id;
        addAss.Effective_Date__c = Date.today().addDays(2);
        addAss.Vendor__c = acc.id;
        insert addAss;

        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    }

    static testmethod void test_SP_VendorSubscriptionNotifications06() {

        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        singAdd.House_Block_Number__c = '01';
        insert singAdd;

        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '09155568874';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Local'
        ];
        addressRec.RecordTypeId = addressRT.id;
        addressRec.Block_House_Number__c = '01';
        addressRec.Level_Number__c = '01';
        addressRec.Unit_Number__c = '01';
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].HomePhone__c = '09155568874';
        insert conList;

        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today();
        tempStop.Restart_Date__c = Date.today() + 1;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;

        //Case2
        Case cs2 = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cs2.AccountId = acc.id;
        cs2.Effective_Date__c = Date.today() + 1;
        cs2.COA__c = true;
        cs2.Temp_Stop__c = tempStop.id;
        cs2.Status = 'Closed';
        cs2.Order__c = orderRec.id;
        cs2.Vendor__c = acc.id;
        cs2.Change_of_Address_Type__c = 'Change of Vendor';
        cs2.Contact_To_Update__c = conList[0].id;
        cs2.New_Address__c = addressRec.id;
        cs2.Temp_Stop_Date__c = Date.today().addDays(1);
        cs2.Remarks__c = 'Sample Remarks';
        insert cs2;

        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.id;
        subVen.Vendor__c = acc.id;
        insert subVen;

        Case_Vendor_Subscription__c csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs2.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;

        //Sunday_Publication__r
        List < Publication__c > sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);

        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = sundayPublicationList[0].id;
        subVenPub.Mon__c = 1;
        subVenPub.Tue__c = 1;
        subVenPub.Wed__c = 1;
        subVenPub.Thu__c = 1;
        subVenPub.Fri__c = 1;
        subVenPub.Sat__c = 1;
        subVenPub.Sun__c = 1;
        subVenPub.PHd__c = 1;
        subVenPub.PHe__c = 1;
        insert subVenPub;
        
        SP_VendorSubscriptionNotificationsBatch.subIdToCaseIdToTempStopQty_MAP.put(subVen.Id, new Map < Id, Decimal > {cs2.Id => 1});
        
        //Publication__c
        List < Publication__c > publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication: publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);

        Address_Assignment__c addAss = new Address_Assignment__c();
        addAss.Case__c = cs2.id;
        addAss.Address__c = addressRec.id;
        addAss.Contact__c = conList[0].id;
        addAss.Effective_Date__c = Date.today().addDays(2);
        addAss.Vendor__c = acc.id;
        insert addAss;

        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    }

    static testmethod void test_SP_VendorSubscriptionNotifications07() {

        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;

        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '09155568874';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].HomePhone__c = '09155568874';
        insert conList;

        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today();
        tempStop.Restart_Date__c = Date.today() + 1;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;

        //Case2
        Case cs2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cs2.AccountId = acc.id;
        cs2.Effective_Date__c = Date.today() + 1;
        cs2.COA__c = true;
        cs2.Temp_Stop__c = tempStop.id;
        cs2.Status = 'Closed';
        cs2.Order__c = orderRec.id;
        cs2.Vendor__c = acc.id;
        cs2.Change_of_Address_Type__c = 'Change of Vendor';
        cs2.Contact_To_Update__c = conList[0].id;
        cs2.New_Address__c = addressRec.id;
        cs2.Temp_Stop_Date__c = Date.today().addDays(1);
        cs2.Remarks__c = 'Sample Remarks';
        insert cs2;

        Package__c pack = TestDataFactory.createPackage(1)[0];
        insert pack;

        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.id;
        insert ord;

        Order_Line_Item_Vendor__c ordLineItem = TestDataFactory.createOrderLineItemVendor(1)[0];
        ordLineItem.Case__c = cs2.id;
        ordLineItem.Order__c = ord.id;
        //ordLineItem.Main_Package_ID__c = pack.id;
        ordLineItem.Start_Date__c = date.today().addDays(5);
        insert ordLineItem;

        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.id;
        subVen.Vendor__c = acc.id;
        insert subVen;

        Case_Vendor_Subscription__c csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs2.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;

        //Sunday_Publication__r
        List < Publication__c > sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);

        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = sundayPublicationList[0].id;
        insert subVenPub;

        //Publication__c
        List < Publication__c > publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication: publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);

        Address_Assignment__c addAss = new Address_Assignment__c();
        addAss.Case__c = cs2.id;
        addAss.Address__c = addressRec.id;
        addAss.Contact__c = conList[0].id;
        addAss.Effective_Date__c = Date.today().addDays(2);
        addAss.Vendor__c = acc.id;
        insert addAss;

        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    }

    static testmethod void test_SP_VendorSubscriptionNotifications08() {

        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;

        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '09155568874';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        addressRec.Block_House_Number__c = '213';
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].HomePhone__c = '09155568874';
        insert conList;

        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today();
        tempStop.Restart_Date__c = Date.today() + 1;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;

        //Case2
        Case cs2 = TestDataFactory.createCase(1, 'Start Subscription')[0];
        cs2.AccountId = acc.id;
        cs2.Effective_Date__c = Date.today() + 1;
        cs2.COA__c = true;
        cs2.Temp_Stop__c = tempStop.id;
        cs2.Status = 'Closed';
        cs2.Order__c = orderRec.id;
        cs2.Vendor__c = acc.id;
        cs2.Change_of_Address_Type__c = 'Change of Vendor';
        cs2.Contact_To_Update__c = conList[0].id;
        cs2.New_Address__c = addressRec.id;
        cs2.Temp_Stop_Date__c = Date.today().addDays(1);
        cs2.Remarks__c = 'Sample Remarks';
        insert cs2;

        Package__c pack = TestDataFactory.createPackage(1)[0];
        insert pack;

        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.id;
        insert ord;

        Order_Line_Item_Vendor__c ordLineItem = TestDataFactory.createOrderLineItemVendor(1)[0];
        ordLineItem.Case__c = cs2.id;
        ordLineItem.Order__c = ord.id;
        //ordLineItem.Main_Package_ID__c = pack.id;
        ordLineItem.Start_Date__c = date.today().addDays(5);
        insert ordLineItem;

        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.id;
        subVen.Vendor__c = acc.id;
        subVen.Subscription_Start_Date__c = Date.today() + 1;
        insert subVen;

        Case_Vendor_Subscription__c csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs2.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;

        //Sunday_Publication__r
        List < Publication__c > sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);

        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = sundayPublicationList[0].id;
        subVenPub.Mon__c = 1;
        subVenPub.Tue__c = 1;
        subVenPub.Wed__c = 1;
        subVenPub.Thu__c = 1;
        subVenPub.Fri__c = 1;
        subVenPub.Sat__c = 1;
        subVenPub.Sun__c = 1;
        subVenPub.PHd__c = 1;
        subVenPub.PHe__c = 1;
        insert subVenPub;

        //Publication__c
        List < Publication__c > publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication: publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);

        Address_Assignment__c addAss = new Address_Assignment__c();
        addAss.Case__c = cs2.id;
        addAss.Address__c = addressRec.id;
        addAss.Contact__c = conList[0].id;
        addAss.Effective_Date__c = Date.today().addDays(2);
        addAss.Vendor__c = acc.id;
        insert addAss;

        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    }

    static testmethod void test_SP_VendorSubscriptionNotifications09() {

        //insert singpost address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;

        //insert account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '09155568874';
        acc.Email__c = 'test@test.com';
        insert acc;

        //insert address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;

        //insert contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].HomePhone__c = '09155568874';
        insert conList;

        //insert order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //insert temp stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today();
        tempStop.Restart_Date__c = Date.today() + 1;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;

        //insert case
        Case cs2 = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cs2.AccountId = acc.id;
        cs2.Effective_Date__c = Date.today() + 1;
        cs2.COA__c = true;
        cs2.Temp_Stop__c = tempStop.id;
        cs2.Status = 'Closed';
        cs2.Order__c = orderRec.id;
        cs2.Vendor__c = acc.id;
        cs2.Change_of_Address_Type__c = 'Change of Vendor';
        cs2.Contact_To_Update__c = conList[0].id;
        cs2.New_Address__c = addressRec.id;
        cs2.Temp_Stop_Date__c = Date.today().addDays(1);
        cs2.Remarks__c = 'Sample Remarks';
        insert cs2;

        List < Case > caseIdList = new List < Case > ();
        caseIdList.add(cs2);

        Map < Id, Map < Id, boolean >> insertNestedMap = new Map < Id, Map < Id, boolean >> ();
        Map < Id, boolean > insertMapValue = new Map < Id, boolean > ();


        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();

    }
    
    static testmethod void test_SP_VendorSubscriptionNotifications10() {


        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;

        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '923429';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].Email = 'test@sample.com';
        conList[0].Vendor_Communication_Preference__c = 'Both';
        conList[0].HomePhone__c = '09155568874';
        insert conList;
        system.debug('CON**: ' + conList[0].Id);
        String profName = 'Partner Community User';
        //String licenseName = 'Partner Community';
        Profile prof = [Select Id From Profile Where Name =: profName AND UserLicense.Name =: GlobalVariableClass.USER_LICENSE Limit 1];
        
        User UserNew =
            new User(
                ContactId = conList[0].id,
                //UserNew.ProfileId = prof.id;
                Alias = 'standard',
                Email = 'standarduser@gmail.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = prof.id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userstand3541987*@testorg.com'
            );


        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today() + 1;
        tempStop.Restart_Date__c = Date.today() + 2;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;

        //Case
        Case cs = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cs.AccountId = acc.id;
        cs.Effective_Date__c = Date.today() + 1;
        cs.COA__c = true;
        cs.Temp_Stop__c = tempStop.id;
        cs.Status = 'Closed';
        cs.Order__c = orderRec.id;
        cs.Vendor__c = acc.id;
        cs.Change_of_Address_Type__c = 'Change of Vendor';
        cs.Contact_To_Update__c = conList[0].id;
        cs.Remarks__c = 'Sample Remarks';
        cs.Requires_Urgent_Approval__c = false;
        insert cs;



        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch();
        ID batchprocessid2 = Database.executeBatch(batch, 200);
        Test.stopTest();

    }
    
        static testmethod void test_SP_VendorSubscriptionNotifications11() {


        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;

        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '923429';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].Email = 'test@sample.com';
        conList[0].Vendor_Communication_Preference__c = 'Both';
        conList[0].HomePhone__c = '09155568874';
        insert conList;
        system.debug('CON**: ' + conList[0].Id);
        String profName = 'Partner Community User';
        //String licenseName = 'Partner Community';
        Profile prof = [Select Id From Profile Where Name =: profName AND UserLicense.Name =: GlobalVariableClass.USER_LICENSE Limit 1];
        
        User UserNew =
            new User(
                ContactId = conList[0].id,
                //UserNew.ProfileId = prof.id;
                Alias = 'standard',
                Email = 'standarduser@gmail.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = prof.id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userstand3541987*@testorg.com'
            );


        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today() + 1;
        tempStop.Restart_Date__c = Date.today() + 2;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;

        //Case
        Case cs = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cs.AccountId = acc.id;
        cs.Effective_Date__c = Date.today() + 1;
        cs.COA__c = true;
        cs.Temp_Stop__c = tempStop.id;
        cs.Status = 'Closed';
        cs.Order__c = orderRec.id;
        cs.Vendor__c = acc.id;
        cs.Change_of_Address_Type__c = 'Change of Vendor';
        cs.Contact_To_Update__c = conList[0].id;
        cs.Remarks__c = 'Sample Remarks';
        cs.Requires_Urgent_Approval__c = true;
        insert cs;



        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch();
        ID batchprocessid2 = Database.executeBatch(batch, 200);
        Test.stopTest();

    }
    
    static testmethod void test_SP_VendorSubscriptionNotifications12() {


        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        singAdd.Name = 'Test';
        insert singAdd;


        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].Email = 'test@sample.com';
        conList[0].Vendor_Communication_Preference__c = 'Both';
        conList[0].HomePhone__c = '09155568874';
        insert conList;


        String profName = 'Partner Community User';
        Profile prof = [Select Id From Profile Where Name =: profName AND UserLicense.Name =: GlobalVariableClass.USER_LICENSE Limit 1];
        User UserNew =
            new User(
                ContactId = conList[0].id,
                Alias = 'standard',
                Email = 'standarduser@gmail.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = prof.id, //ConstantsSLB.getKeyId('Profile_Partner Community User'),
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userstand3541987*@testorg.com'
            );

        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today() + 1;
        tempStop.Restart_Date__c = Date.today() + 2;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;

        //Case
        Case cs = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cs.AccountId = acc.id;
        cs.Effective_Date__c = Date.today() + 1;
        cs.COA__c = true;
        cs.Temp_Stop__c = tempStop.id;
        cs.Status = 'Closed';
        cs.Order__c = orderRec.id;
        //cs.Vendor__c = acc.id;
        cs.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        cs.Contact_To_Update__c = conList[0].id;
        cs.Remarks__c = 'Sample Remarks';
        insert cs;
        
        Case csTemp = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        csTemp.AccountId = acc.id;
        csTemp.Effective_Date__c = Date.today() + 1;
        csTemp.COA__c = true;
        csTemp.Temp_Stop__c = tempStop.id;
        csTemp.Temp_Stop_Date__c = Date.today() + 1;
        csTemp.Restart_Date__c = Date.today() + 2;
        csTemp.Status = 'Closed';
        csTemp.Order__c = orderRec.id;
        //csTemp.Vendor__c = acc.id;
        //csTemp.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        csTemp.Contact_To_Update__c = conList[0].id;
        csTemp.Remarks__c = 'Sample Remarks';
        insert csTemp;
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.id;
        subVen.Vendor__c = acc.id;
        insert subVen;

        Case_Vendor_Subscription__c csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;
        
        Case_Vendor_Subscription__c csVenSub3 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub3.Case__c = csTemp.id;
        csVenSub3.Subscription_Vendor__c = subVen.id;
        csVenSub3.Account__c = acc.id;
        insert csVenSub3;

        //Sunday_Publication__r
        List < Publication__c > sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);

        //Publication__c
        List < Publication__c > publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication: publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);

        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = publicationList[0].id;
        insert subVenPub;

        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);


        Postal_Zone__c postalZone = new Postal_Zone__c();
        postalZone.Name = 'Test';
        database.insert(postalZone);

        User myUser2 = [SELECT Id, IsActive from User where IsActive = true LIMIT 1];
        Post_Sector_Ops_Rep_Mapping__c postSector = new Post_Sector_Ops_Rep_Mapping__c();
        postSector.Zone__c = postalZone.id;
        postSector.Vendor_Ops__c = myUser2.Id; //[SELECT Id from User where IsActive = true LIMIT 1].id;
        database.insert(postSector);


        SP_VendorSubscriptionNotificationsBatch batch2 = new SP_VendorSubscriptionNotificationsBatch(new set < id > {
            cs.Id
        });
        ID batchprocessid2 = Database.executeBatch(batch2, 200);
        Test.stopTest();

    }
    
    static testmethod void test_SP_VendorSubscriptionNotifications13() {


        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        singAdd.Name = 'Test';
        insert singAdd;


        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].Email = 'test@sample.com';
        conList[0].Vendor_Communication_Preference__c = 'Both';
        conList[0].HomePhone__c = '09155568874';
        insert conList;


        String profName = 'Partner Community User';
        Profile prof = [Select Id From Profile Where Name =: profName AND UserLicense.Name =: GlobalVariableClass.USER_LICENSE Limit 1];
        User UserNew =
            new User(
                ContactId = conList[0].id,
                Alias = 'standard',
                Email = 'standarduser@gmail.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = prof.id, //ConstantsSLB.getKeyId('Profile_Partner Community User'),
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userstand3541987*@testorg.com'
            );

        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today() -3;
        tempStop.Restart_Date__c = Date.today() + 1;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;

        //Case
        Case cs = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cs.AccountId = acc.id;
        cs.Effective_Date__c = Date.today() + 1;
        cs.COA__c = true;
        cs.Temp_Stop__c = tempStop.id;
        cs.Status = 'Closed';
        cs.Order__c = orderRec.id;
        //cs.Vendor__c = acc.id;
        cs.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        cs.Contact_To_Update__c = conList[0].id;
        cs.Remarks__c = 'Sample Remarks';
        insert cs;
        
        Case csTemp = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        csTemp.AccountId = acc.id;
        csTemp.Effective_Date__c = Date.today() + 1;
        csTemp.COA__c = true;
        csTemp.Temp_Stop__c = tempStop.id;
        csTemp.Temp_Stop_Date__c = Date.today() -3;
        csTemp.Restart_Date__c = Date.today() + 1;
        csTemp.Status = 'Closed';
        csTemp.Order__c = orderRec.id;
        //csTemp.Vendor__c = acc.id;
        //csTemp.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        csTemp.Contact_To_Update__c = conList[0].id;
        csTemp.Remarks__c = 'Sample Remarks';
        insert csTemp;
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.id;
        subVen.Vendor__c = acc.id;
        insert subVen;

        Case_Vendor_Subscription__c csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;
        
        Case_Vendor_Subscription__c csVenSub3 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub3.Case__c = csTemp.id;
        csVenSub3.Subscription_Vendor__c = subVen.id;
        csVenSub3.Account__c = acc.id;
        insert csVenSub3;

        //Sunday_Publication__r
        List < Publication__c > sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);

        //Publication__c
        List < Publication__c > publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication: publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);

        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = publicationList[0].id;
        insert subVenPub;

        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);


        Postal_Zone__c postalZone = new Postal_Zone__c();
        postalZone.Name = 'Test';
        database.insert(postalZone);

        User myUser2 = [SELECT Id, IsActive from User where IsActive = true LIMIT 1];
        Post_Sector_Ops_Rep_Mapping__c postSector = new Post_Sector_Ops_Rep_Mapping__c();
        postSector.Zone__c = postalZone.id;
        postSector.Vendor_Ops__c = myUser2.Id; //[SELECT Id from User where IsActive = true LIMIT 1].id;
        database.insert(postSector);


        SP_VendorSubscriptionNotificationsBatch batch2 = new SP_VendorSubscriptionNotificationsBatch(new set < id > {
            cs.Id
        });
        ID batchprocessid2 = Database.executeBatch(batch2, 200);
        Test.stopTest();

    }
    
    static testmethod void test_SP_VendorSubscriptionNotifications14() {


        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        singAdd.Name = 'Test';
        insert singAdd;


        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Email__c = 'test@test.com';
        insert acc;

        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'P';
        addressRec.Postal_Code__c = singAdd.Id;
        RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype = 'address__c'
            AND Name = 'Overseas'
        ];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;

        /*2: Vendor Staff*/
        //Contact
        List < Contact > conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE;
        conList[0].Mobile_Number__c = '09155568874';
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].Email = 'test@sample.com';
        conList[0].Vendor_Communication_Preference__c = 'Both';
        conList[0].HomePhone__c = '09155568874';
        insert conList;


        String profName = 'Partner Community User';
        Profile prof = [Select Id From Profile Where Name =: profName AND UserLicense.Name =: GlobalVariableClass.USER_LICENSE Limit 1];
        User UserNew =
            new User(
                ContactId = conList[0].id,
                Alias = 'standard',
                Email = 'standarduser@gmail.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = prof.id, //ConstantsSLB.getKeyId('Profile_Partner Community User'),
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userstand3541987*@testorg.com'
            );

        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;

        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today() -3;
        tempStop.Restart_Date__c = Date.today() + 2;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;

        //Case
        Case cs = TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        cs.AccountId = acc.id;
        cs.Effective_Date__c = Date.today() + 1;
        cs.COA__c = true;
        cs.Temp_Stop__c = tempStop.id;
        cs.Status = 'Closed';
        cs.Order__c = orderRec.id;
        //cs.Vendor__c = acc.id;
        cs.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        cs.Contact_To_Update__c = conList[0].id;
        cs.Remarks__c = 'Sample Remarks';
        insert cs;
        
        Case csTemp = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        csTemp.AccountId = acc.id;
        csTemp.Effective_Date__c = Date.today() + 1;
        csTemp.COA__c = true;
        csTemp.Temp_Stop__c = tempStop.id;
        csTemp.Temp_Stop_Date__c = Date.today() -3;
        csTemp.Restart_Date__c = Date.today() + 2;
        csTemp.Status = 'Closed';
        csTemp.Order__c = orderRec.id;
        //csTemp.Vendor__c = acc.id;
        //csTemp.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        csTemp.Contact_To_Update__c = conList[0].id;
        csTemp.Remarks__c = 'Sample Remarks';
        insert csTemp;
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.id;
        subVen.Vendor__c = acc.id;
        insert subVen;

        Case_Vendor_Subscription__c csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;
        
        Case_Vendor_Subscription__c csVenSub3 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub3.Case__c = csTemp.id;
        csVenSub3.Subscription_Vendor__c = subVen.id;
        csVenSub3.Account__c = acc.id;
        insert csVenSub3;

        //Sunday_Publication__r
        List < Publication__c > sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);

        //Publication__c
        List < Publication__c > publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication: publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);

        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = publicationList[0].id;
        insert subVenPub;

        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);


        Postal_Zone__c postalZone = new Postal_Zone__c();
        postalZone.Name = 'Test';
        database.insert(postalZone);

        User myUser2 = [SELECT Id, IsActive from User where IsActive = true LIMIT 1];
        Post_Sector_Ops_Rep_Mapping__c postSector = new Post_Sector_Ops_Rep_Mapping__c();
        postSector.Zone__c = postalZone.id;
        postSector.Vendor_Ops__c = myUser2.Id; //[SELECT Id from User where IsActive = true LIMIT 1].id;
        database.insert(postSector);


        SP_VendorSubscriptionNotificationsBatch batch2 = new SP_VendorSubscriptionNotificationsBatch(new set < id > {
            cs.Id
        });
        ID batchprocessid2 = Database.executeBatch(batch2, 200);
        Test.stopTest();

    }
    /************************************************************************************
    public static testMethod void testRollUpDays() {

        User userU = TestDataFactory.prepareTestusers();

        System.runAs(userU) {


            Account accV = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accV.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
            database.insert(accV);

            Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
            subVen.Status__c = 'Active';
            subVen.Account__c = accV.Id;
            Database.insert(subVen);

            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Product_Category__c = 'Magazine';
            Database.insert(pub);

            Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createSubVendorPublication(1)[0];
            subVenPub.Subscription_Vendor__c = subVen.Id;
            subVenPub.Publication__c = pub.Id;
            subVenPub.Mon__c = 1;
            subVenPub.Tue__c = 1;
            subVenPub.Wed__c = 1;
            subVenPub.Thu__c = 1;
            subVenPub.Fri__c = 1;
            subVenPub.Sat__c = 1;
            subVenPub.Sun__c = 1;
            subVenPub.PHd__c = 1;
            subVenPub.PHe__c = 1;
            Database.insert(subVenPub);

            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            insert cas;

            Test.startTest();
            SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
            ID batchprocessid = Database.executeBatch(batch, 200);
            System.assertNotEquals(null, batchprocessid);
            SP_VendorSubscriptionNotificationsBatch.subIdToCaseIdToTempStopQty_MAP.put(subVenPub.Id, new Map < Id, Decimal > {
                cas.Id => 1
            });
            SP_VendorSubscriptionNotificationsBatch.rollUpDays(subVenPub);

            Test.stopTest();
        }

    }
    ******************************************************************************************************/
}