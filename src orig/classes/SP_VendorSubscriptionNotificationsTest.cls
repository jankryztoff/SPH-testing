@isTest (seeAllData = false)
public class SP_VendorSubscriptionNotificationsTest{
    
    static void setCustomSettings() {
    
        //Cir_Planner_Schedule__c
        List<Cir_Planner_Schedule__c> cpsList = new List<Cir_Planner_Schedule__c>{
            new Cir_Planner_Schedule__c(Name='CIR Plan Schedule', Mon_Fri_End_Time__c=Date.today(),
                Mon_Fri_Start_Time__c=Date.today(),Sat_PH_End_Time__c=Date.today(),Sat_PH_Start_Time__c=Date.today(),
                Sun_End_Time__c=Date.today(),Sun_Start_Time__c=Date.today())
        };
        Database.insert(cpsList);
        
        //
        RecordType Case_ChangeinAddress = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Change of Address/Vendor' LIMIT 1];
        RecordType Case_TempStop = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Temp Stop Subscription' LIMIT 1];
        RecordType Contact_VendorStaff = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Vendor Staff' LIMIT 1];
        RecordType Case_Stop = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Stop Subscription' LIMIT 1];
        RecordType Case_StartSub = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Start Subscription' LIMIT 1];
        
        //Key_Id__c
        //.getInstance('Vendor Rep Role')
        List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role', Id__c='123456789', Type__c='Number'),
            /*new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c='123456789', Type__c='Number'),*/
            new Key_Id__c(Name='Case_Change in Address', Id__c=Case_ChangeinAddress.id ,Type__c='Id'),
            new Key_Id__c(Name='Case_Temp Stop', Id__c=Case_TempStop.id ,Type__c='Id'),
            new Key_Id__c(Name='Contact_Vendor Staff', Id__c=Contact_VendorStaff.id ,Type__c='Id'),
            new Key_Id__c(Name='Case_Stop', Id__c=Case_Stop.id ,Type__c='Id'),
            new Key_Id__c(Name='Case_Start Sub', Id__c=Case_StartSub.id ,Type__c='Id')
        };
        Database.insert(kisList);
        
        //Batch_Configuration_Settings__c.getInstance('SP_VendorNotificationsBatch');
        List<Batch_Configuration_Settings__c> bcsList = new List<Batch_Configuration_Settings__c>{
            new Batch_Configuration_Settings__c(Name='SP_VendorNotificationsBatch', Batch_Size__c=10, 
                Max_Retries__c=10, Notification_Recipients__c='', Number_Of_Days_To_Retrieve__c=30)
        };
        Database.insert(bcsList);
        
    }
    
    static testmethod void test_SP_VendorSubscriptionNotifications01(){
        
        setCustomSettings();
        
  
        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        singAdd.Name = 'Test';
        insert singAdd;
    
  
  
    /*2: Select Id, Name, Email__c, (Select Id, Name, Email, RecordType.Name, Address__r.Id, HomePhone__c, Vendor_Communication_Preference__c, Active__c
                                    From Contacts where 
                                    RecordType.Name = :GlobalVariableClass.VENDOR_STAFF)
       From Account Where RecordType.Name = 'Vendor' AND Active__c = true*/
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        insert acc;
        
        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = singAdd.Id;
            RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype='address__c' AND Name='Overseas'];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;
   
    /*2: Vendor Staff*/     
        //Contact
        List<Contact> conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
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
        
       // UserLicense license = [SELECT Id, Name From UserLicense Where Name = 'Partner Community' LIMIT 1];
        
        
       // Profile prof = [SELECT Id, UserLicenseId FROM Profile ];
    
        String profName = 'Partner Community User';
       //User UserNew = new  TestDataFactory.prepareTestusers(profName);
        Profile prof = [Select Id From Profile Where Name =: profName Limit 1];
        User UserNew = 
        new User(
             ContactId = conList[0].id,
        //UserNew.ProfileId = prof.id;
        Alias = 'standard',
        Email='standarduser@gmail.com',
        EmailEncodingKey='UTF-8',
        LastName='Testing',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        ProfileId = prof.id, //ConstantsSLB.getKeyId('Profile_Partner Community User'),
        TimeZoneSidKey='America/Los_Angeles',
        UserName='userstand3541987*@testorg.com'
        );
       // insert UserNew;
      
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
        cs.Effective_Date__c = Date.today()+1;
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
        List<Publication__c> sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);
        
        /*Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = sundayPublicationList[0].id;
        insert subVenPub; */
        
        //Publication__c
        List<Publication__c> publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication : publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);
        
        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = publicationList[0] .id;
        insert subVenPub;
    
        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch('sampleSession');
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        
      /*  User u = new User(
                    Alias = 'stndrd',
                    isActive = true,
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ContactId = conList[0].id,
                    ProfileId = [SELECT id from Profile Where Name ='Vendor rep'].id,
                    UserRoleId = [SELECT Id from UserRole LIMIT 1].id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
        database.update(u);
       */ 
        Postal_Zone__c postalZone = new Postal_Zone__c();
        postalZone.Name = 'Test';
        database.insert(postalZone);

        Post_Sector_Ops_Rep_Mapping__c postSector  = new Post_Sector_Ops_Rep_Mapping__c();
        postSector.Zone__C = postalZone.id;
        postSector.Vendor_Ops__c =  [SELECT Id from User where IsActive = true LIMIT 1].id;
        database.insert(postSector);
        
        
        SP_VendorSubscriptionNotificationsBatch batch2 = new SP_VendorSubscriptionNotificationsBatch(new set<id>{cs.Id});
        ID batchprocessid2 = Database.executeBatch(batch2, 200);
        Test.stopTest();
        
    }
    
    static testmethod void test_SP_VondorSubscriptionNotificationsSelective() {

        setCustomSettings();
        
  
        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;
    
  
  
    /*2: Select Id, Name, Email__c, (Select Id, Name, Email, RecordType.Name, Address__r.Id, HomePhone__c, Vendor_Communication_Preference__c, Active__c
                                    From Contacts where 
                                    RecordType.Name = :GlobalVariableClass.VENDOR_STAFF)
       From Account Where RecordType.Name = 'Vendor' AND Active__c = true*/
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '923429';
        insert acc;
        
        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = singAdd.Id;
            RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype='address__c' AND Name='Overseas'];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;
   
    /*2: Vendor Staff*/     
        //Contact
        List<Contact> conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
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
        
       // UserLicense license = [SELECT Id, Name From UserLicense Where Name = 'Partner Community' LIMIT 1];
        
        
       // Profile prof = [SELECT Id, UserLicenseId FROM Profile ];
    
        String profName = 'Partner Community User';
       //User UserNew = new  TestDataFactory.prepareTestusers(profName);
        Profile prof = [Select Id From Profile Where Name =: profName Limit 1];
        User UserNew = 
        new User(
             ContactId = conList[0].id,
        //UserNew.ProfileId = prof.id;
        Alias = 'standard',
        Email='standarduser@gmail.com',
        EmailEncodingKey='UTF-8',
        LastName='Testing',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        ProfileId = prof.id, //ConstantsSLB.getKeyId('Profile_Partner Community User'),
        TimeZoneSidKey='America/Los_Angeles',
        UserName='userstand3541987*@testorg.com'
        );
       // insert UserNew;
      
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
        cs.Effective_Date__c = Date.today()+1;
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
        List<Publication__c> sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);
        
        /*Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = sundayPublicationList[0].id;
        insert subVenPub; */
        
        //Publication__c
        List<Publication__c> publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication : publicationList) {
            publication.Publication_Code__c = 'PUB1';
            publication.Sunday_Publication__c = sundayPublicationList[0].id;
        }
        Database.insert(publicationList);
        
        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = publicationList[0] .id;
        insert subVenPub;
    
        
        Test.startTest();
        SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch();
        SP_VendorSubscriptionNotificationsBatch batch2 = new SP_VendorSubscriptionNotificationsBatch(new set<id>{cs.Id});
        ID batchprocessid2 = Database.executeBatch(batch2, 200);
        Test.stopTest();
                
    }
    
    static testmethod void test_SP_VendorSubscriptionNotifications02(){
        
        setCustomSettings();
        
        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;
    
    /*2: Select Id, Name, Email__c, (Select Id, Name, Email, RecordType.Name, Address__r.Id, HomePhone__c, Vendor_Communication_Preference__c, Active__c
                                    From Contacts where 
                                    RecordType.Name = :GlobalVariableClass.VENDOR_STAFF)
       From Account Where RecordType.Name = 'Vendor' AND Active__c = true*/
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '09155568874';
        insert acc;
        
        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = singAdd.Id;
            RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype='address__c' AND Name='Overseas'];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;
   
    /*2: Vendor Staff*/     
        //Contact
        List<Contact> conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
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
        cs.Effective_Date__c = Date.today()+1;
        cs.COA__c = true;
        cs.Temp_Stop__c = tempStop.id;
        cs.Status = 'Closed';
        cs.Order__c = orderRec.id;
        //cs.Vendor__c = acc.id; //xxx
        cs.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        cs.Contact_To_Update__c = conList[0].id;
        cs.New_Address__c = addressRec.id;
        cs.Temp_Stop_Date__c = Date.today();
        cs.restart_date__c = date.today()+1;
        insert cs;
        
        //Case2
        Case cs2 = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
        cs2.AccountId = acc.id;
        cs2.Effective_Date__c = Date.today()+1;
        cs2.COA__c = true;
        cs2.Temp_Stop__c = tempStop.id;
        cs2.Status = 'Closed';
        cs2.Order__c = orderRec.id;
        //cs.Vendor__c = acc.id;
        cs2.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        cs2.Contact_To_Update__c = conList[0].id;
        cs2.New_Address__c = addressRec.id;
        cs2.Temp_Stop_Date__c = Date.today().addDays(1);
        cs2.restart_date__c = date.today()+2;
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
        List<Publication__c> sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);
        
        //Publication__c
        List<Publication__c> publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication : publicationList) {
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
    
    static testmethod void test_SP_VendorSubscriptionNotifications03(){
        
        setCustomSettings();
        
        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;
    
    /*2: Select Id, Name, Email__c, (Select Id, Name, Email, RecordType.Name, Address__r.Id, HomePhone__c, Vendor_Communication_Preference__c, Active__c
                                    From Contacts where 
                                    RecordType.Name = :GlobalVariableClass.VENDOR_STAFF)
       From Account Where RecordType.Name = 'Vendor' AND Active__c = true*/
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '09155568874';
        insert acc;
        
        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = singAdd.Id;
            RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype='address__c' AND Name='Overseas'];
        addressRec.RecordTypeId = addressRT.id;
        addressRec.Block_House_Number__c = '213';
        insert addressRec;
   
    /*2: Vendor Staff*/     
        //Contact
        List<Contact> conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
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
        cs2.Effective_Date__c = Date.today()+1;
        cs2.COA__c = true;
        cs2.Temp_Stop__c = tempStop.id;
        cs2.Status = 'Closed';
        cs2.Order__c = orderRec.id;
        //cs2.Vendor__c = acc.id;   //xxxx
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
        List<Publication__c> sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);
        
        //Publication__c
        List<Publication__c> publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication : publicationList) {
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
    
    static testmethod void test_SP_VendorSubscriptionNotifications04(){
        
        setCustomSettings();
        
        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;
    
    /*2: Select Id, Name, Email__c, (Select Id, Name, Email, RecordType.Name, Address__r.Id, HomePhone__c, Vendor_Communication_Preference__c, Active__c
                                    From Contacts where 
                                    RecordType.Name = :GlobalVariableClass.VENDOR_STAFF)
       From Account Where RecordType.Name = 'Vendor' AND Active__c = true*/
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '09155568874';
        insert acc;
        
        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = singAdd.Id;
            RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype='address__c' AND Name='Overseas'];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;
   
    /*2: Vendor Staff*/     
        //Contact
        List<Contact> conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
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
        cs2.Effective_Date__c = Date.today()+1;
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
        List<Publication__c> sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);
        
        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = sundayPublicationList[0].id;
        insert subVenPub;
        
        //Publication__c
        List<Publication__c> publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication : publicationList) {
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
    
    static testmethod void test_SP_VendorSubscriptionNotifications05(){
        
        setCustomSettings();
        
        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;
    
    /*2: Select Id, Name, Email__c, (Select Id, Name, Email, RecordType.Name, Address__r.Id, HomePhone__c, Vendor_Communication_Preference__c, Active__c
                                    From Contacts where 
                                    RecordType.Name = :GlobalVariableClass.VENDOR_STAFF)
       From Account Where RecordType.Name = 'Vendor' AND Active__c = true*/
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '09155568874';
        insert acc;
        
        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = singAdd.Id;
            RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype='address__c' AND Name='Overseas'];
        addressRec.RecordTypeId = addressRT.id;
        insert addressRec;
   
    /*2: Vendor Staff*/     
        //Contact
        List<Contact> conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
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
        cs2.Effective_Date__c = Date.today()+1;
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
        List<Publication__c> sundayPublicationList = TestDataFactory.createPublication(1);
        sundayPublicationList[0].Publication_Code__c = 'SPB1';
        Database.insert(sundayPublicationList);
        
        Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
        subVenPub.Subscription_Vendor__c = subVen.id;
        subVenPub.Publication__c = sundayPublicationList[0].id;
        insert subVenPub;
        
        //Publication__c
        List<Publication__c> publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication : publicationList) {
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
    
    static testmethod void test_SP_VendorSubscriptionNotifications06(){
        
        setCustomSettings();
        
        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;
    
    /*2: Select Id, Name, Email__c, (Select Id, Name, Email, RecordType.Name, Address__r.Id, HomePhone__c, Vendor_Communication_Preference__c, Active__c
                                    From Contacts where 
                                    RecordType.Name = :GlobalVariableClass.VENDOR_STAFF)
       From Account Where RecordType.Name = 'Vendor' AND Active__c = true*/
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Handphone_Number__c = '09155568874';
        insert acc;
        
        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = singAdd.Id;
            RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype='address__c' AND Name='Overseas'];
        addressRec.RecordTypeId = addressRT.id;
        addressRec.Block_House_Number__c = '213';
        insert addressRec;
   
    /*2: Vendor Staff*/     
        //Contact
        List<Contact> conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
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
        cs2.Effective_Date__c = Date.today()+1;
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
        subVen.Subscription_Start_Date__c = Date.today()+1;
        insert subVen;
        
        Case_Vendor_Subscription__c csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs2.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;
        
        //Sunday_Publication__r
        List<Publication__c> sundayPublicationList = TestDataFactory.createPublication(1);
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
        List<Publication__c> publicationList = TestDataFactory.createPublication(1);
        for (Publication__c publication : publicationList) {
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
}