/**
@Author Kirk Yngwie Enriquez
@name OverseasNewspaperSubBatchableTest
@CreateDate <07/08/2015>
@Description <Test Class for OverseasNewspaperSubscriptionBatchable>
@Version <1.0>
@reference <none>
*/

@isTest
public class OverseasNewspaperSubBatchableTest{
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther();
    }

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
        
        //Key_Id__c
        //.getInstance('Vendor Rep Role')
        List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role', Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='Case_Change in Address', Id__c=Case_ChangeinAddress.id ,Type__c='Id'),
            new Key_Id__c(Name='Case_Temp Stop', Id__c=Case_TempStop.id ,Type__c='Id'),
            new Key_Id__c(Name='Contact_Vendor Staff', Id__c=Contact_VendorStaff.id ,Type__c='Id'),
            new Key_Id__c(Name='Case_Stop', Id__c=Case_Stop.id ,Type__c='Id')
        };
        Database.insert(kisList);
        
        //Batch_Configuration_Settings__c.getInstance('SP_VendorNotificationsBatch');
        List<Batch_Configuration_Settings__c> bcsList = new List<Batch_Configuration_Settings__c>{
            new Batch_Configuration_Settings__c(Name='SP_VendorNotificationsBatch', Batch_Size__c=10, 
                Max_Retries__c=10, Notification_Recipients__c='', Number_Of_Days_To_Retrieve__c=30)
        };
        Database.insert(bcsList);
        
        //ConstantsSLB.getOther('DTL').split(':')
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        Database.insert(otherList);
        
        //SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType='Contact'
        //List<RecordType> objRecordType = new List<RecordType>{
        //    new RecordType(Name='Internal', SObjectType='Contact')
        //};
        //Database.insert(objRecordType);
        
    }

    static testmethod void unitTest(){
        
        //setCustomSettings();
        
         try {
            //Test.setMock(WebServiceMock.class, new zLoginMock());
            /*
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
            */
            
            User u = TestDataFactory.prepareTestusers('Standard User');
            u.UserName = 'standardSPX12@test.com';
            System.runAs(u){
                //Create Account
                //List<Account> acc = TestDataFactory.createAccount(1, 'Direct Corporate');
                 System.runAs(u){
                //Create Account
                //List<Account> acc = TestDataFactory.createAccount(1, 'Direct Corporate');
                List<Account> acc = TestDataFactory.createAccount(1, 'Direct Individual'); // joy
                acc[0].Name = 'Test Account';
                acc[0].AccountNumber = '30017'; //joy
                acc[0].Mailing_Agent_Code__c = 'test';//joy
                insert acc;
                
                
                //Create SingPost Address
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = '1234';
                postal.Street_Name__c = 'Test Street';
                postal.Building_Name__c = 'Test Building';
                postal.House_Block_Number__c = '13';
                insert postal;
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
                
                //Create Country   
                List<Country__c> country = TestDataFactory.createCountry(1);
                country[0].Name = 'SINGAPORE';
                country[0].Country_Name__c = 'SINGAPORE';
                //country[0].Zone__c = zone.Id;
                insert country;
                
                //Create Address
                List<Address__c> add = TestDataFactory.createAddress(1);
                //add[0].RecordTypeId = ConstantsSLB.getKeyId('Address_Internal'); // joy
                add[0].Name = 'Test Address';
                add[0].Postal_Code__c = postal.id;
                add[0].Legacy_Created_By__c = 'Creator';
                add[0].Legacy_Created_Date__c = String.valueOf(date.today().addDays(-3));
                add[0].Legacy_Updated_By__c = 'Modifier';
                add[0].Legacy_Updated_Date__c = String.valueOf(date.today()); 
                add[0].Block_House_Number__c = '22';
                add[0].Level_Number__c = '30';
                add[0].Unit_Number__c = '13';
                add[0].Country__c = country[0].id;
                add[0].Address_1__c = 'TestAdd';
                add[0].Address_2__c = 'O';
                add[0].Address_3__c = 'Y';
                add[0].Address_4__c = 'Z';
                insert add;
                
                //Create 'Internal' Record Type
                RecordType recType = new RecordType ();
                recType.Name = 'Internal';
                recType.sObjectType = 'Contact';
                //insert recType;
                
                //Create Contact   
                /*List<Contact> con = TestDataFactory.createContactRecType(1, 'Internal');
                con[0].FirstName = 'Test';
                con[0].LastName = 'Contact';
                con[0].AccountId = acc[0].id;
                con[0].Address__c = add[0].id;
                con[0].MailingCountry = 'Singapore';
                con[0].MailingCity = 'Singapore';
                con[0].MailingStreet = '123 Test Street';
                con[0].MailingPostalCode = '1000';
                con[0].Recipient_Indicator__c = true;
                //con[0].RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Billing Contact' AND sObjectType = 'Contact'].Id;
                insert con;*/ //joy
                
                List<Contact> con = TestDataFactory.createContactRecType(1, 'Customer Contact');
                con[0].FirstName = 'Test';
                con[0].LastName = 'Contact';
                con[0].AccountId = acc[0].id;
                con[0].Address__c = add[0].id;
                con[0].MailingCountry = 'Singapore';
                con[0].MailingCity = 'Singapore';
                con[0].MailingStreet = '123 Test Street';
                con[0].MailingPostalCode = '1000';
                con[0].Recipient_Indicator__c = true;
                //con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con[0].Phone = '1212';
                con[0].Salutation ='MR.';
                insert con; // joy
                
                
                System.debug('Con is ' + con[0].RecordType.Name);
                
                List<Order__c> order = TestDataFactory.createOrder(1);
                order[0].Delivery_Charge__c = 20; 
                order[0].Recipient_Contact__c = con[0].id;
                order[0].Subscriber_Charge__c = 10;
                order[0].Account__c = acc[0].id;
                insert order;
                
                List<Package__c> pack = TestDataFactory.createPackage(1);    
                pack[0].Package_Type__c = 'Base';
                pack[0].Name = 'ST Print Test';
                pack[0].Subscription_Type__c = 'Termed';
                pack[0].Package_Code__c = 'STEST12';
                pack[0].Subscription_Period__c = '12';
                pack[0].Effective_Start_Date__c = date.today();
                pack[0].Effective_End_Date__c = date.today().addDays(5);
                insert pack;
                
                //Create Order Line Item
                List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
                oli[0].Earliest_Start_Date__c = date.today();
                oli[0].Start_Date__c = date.today().addDays(1);
                oli[0].Order__c = order[0].id;
                oli[0].Main_Package_Period__c = 2;
                oli[0].Qty__c = 3;
                oli[0].Term_Length__c = 5;
                oli[0].Main_Package_ID__c = pack[0].id;  
                insert oli;
                
                List<Zuora__CustomerAccount__c> bill = TestDataFactory.createBillingAccount(1);
                bill[0].Zuora__Account__c = acc[0].Id;
                insert bill;
                
                //Create Zuora Subscription    
                List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(1);
                zSubs[0].Delivered_By__c = 'Mailing Agent';
                zSubs[0].Recipient_Contact__c = con[0].Id;
                zSubs[0].Recipient_Contact_1__c = con[0].Id;   
                zSubs[0].Order_Line_Item_Number__c =  oli[0].id; 
                zSubs[0].Order_Line_Item_Number_1__c =  oli[0].id;
                zSubs[0].Frequency__c = 'Default';    
                zSubs[0].Frequency_1__c = 'Default';
                zSubs[0].Number_of_Copies__c = 1;
                zSubs[0].Number_of_Copies1__c = '1';
                zSubs[0].Subscription_End_Date__c = String.valueOf(Date.today().addDays(5));
                zSubs[0].Main_Package__c = pack[0].id;
                zSubs[0].Main_Package_1__c = pack[0].id;
                zSubs[0].Zuora__SubscriptionEndDate__c = date.today() +5;
                zSubs[0].Zuora__CustomerAccount__c = bill[0].Id;
                zSubs[0].Subscription_Charge__c = 30;
                zSubs[0].Delivered_By__c = 'Mailing Agent';
                zSubs[0].Delivered_By_1__c = 'Mailing Agent';
                zSubs[0].Zuora__Account__c = acc[0].Id; // joy
                insert zSubs;
                
                Test.startTest();
                OverseasNewspaperSubscriptionBatchable batch = new OverseasNewspaperSubscriptionBatchable();
                Id batchprocessid = Database.executeBatch(batch, 200);
                Test.stopTest();
            }
            }
         }catch(Exception e){}
    }
    
    
    
    static testmethod void unitTest2(){
        
        //setCustomSettings();
        
         try {
            //Test.setMock(WebServiceMock.class, new zLoginMock());
            /*
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
            */
            User u = TestDataFactory.prepareTestusers('Standard User');
            u.UserName = 'standardSPX13@test.com';
            System.runAs(u){
                //Create Account
                //List<Account> acc = TestDataFactory.createAccount(1, 'Direct Corporate');
                Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
                acc.RecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account'AND DeveloperName='Vendor'];
                acc.RecordType.DeveloperName = 'Vendor';
                insert acc;
                
                /*List<Account> acc = TestDataFactory.createAccount(1, 'Direct Individual'); // joy
                acc[0].Name = 'Test Account';
                acc[0].AccountNumber = '30017'; //joy
                acc[0].Mailing_Agent_Code__c = 'test';//joy
                insert acc;
                */
                //Create SingPost Address
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                postal.Name = '1234';
                postal.Street_Name__c = 'Test Street';
                postal.Building_Name__c = 'Test Building';
                postal.House_Block_Number__c = '13';
                insert postal;
                
                //Create Zone
                Zone__c zone = new Zone__c();
                insert zone;
                
                //Create Country   
                List<Country__c> country = TestDataFactory.createCountry(1);
                country[0].Name = 'SINGAPORE';
                country[0].Country_Name__c = 'SINGAPORE';
                //country[0].Zone__c = zone.Id;
                insert country;
                
                //Create Address
                List<Address__c> add = TestDataFactory.createAddress(1);
                //add[0].RecordTypeId = ConstantsSLB.getKeyId('Address_Internal'); // joy
                add[0].Name = 'Test Address';
                add[0].Postal_Code__c = postal.id;
                add[0].Legacy_Created_By__c = 'Creator';
                add[0].Legacy_Created_Date__c = String.valueOf(date.today().addDays(-3));
                add[0].Legacy_Updated_By__c = 'Modifier';
                add[0].Legacy_Updated_Date__c = String.valueOf(date.today()); 
                add[0].Block_House_Number__c = '22';
                add[0].Level_Number__c = '30';
                add[0].Unit_Number__c = '13';
                add[0].Country__c = country[0].id;
                add[0].Address_1__c = 'TestAdd';
                add[0].Address_2__c = 'O';
                add[0].Address_3__c = 'Y';
                add[0].Address_4__c = 'Z';
                add[0].RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Address__c' AND Name = 'Internal'].Id; // joy
                insert add;
                
                //Create 'Internal' Record Type
                RecordType recType = new RecordType ();
                recType.Name = 'Internal';
                recType.sObjectType = 'Contact';
                //insert recType;
                
                //Create Contact   
                /*List<Contact> con = TestDataFactory.createContactRecType(1, 'Internal');
                con[0].FirstName = 'Test';
                con[0].LastName = 'Contact';
                con[0].AccountId = acc[0].id;
                con[0].Address__c = add[0].id;
                con[0].MailingCountry = 'Singapore';
                con[0].MailingCity = 'Singapore';
                con[0].MailingStreet = '123 Test Street';
                con[0].MailingPostalCode = '1000';
                con[0].Recipient_Indicator__c = true;
                //con[0].RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Billing Contact' AND sObjectType = 'Contact'].Id;
                insert con;*/ //joy
                
                List<Contact> con = TestDataFactory.createContact(1);
                con[0].FirstName = 'Test';
                con[0].LastName = 'Contact';
                con[0].AccountId = acc.id;
                con[0].Address__c = add[0].id;
                con[0].MailingCountry = 'Singapore';
                con[0].MailingCity = 'Singapore';
                con[0].MailingStreet = '123 Test Street';
                con[0].MailingPostalCode = '1000';
                con[0].Recipient_Indicator__c = true;
                //con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con[0].Phone = '1212';
                con[0].Salutation ='MR.';
                con[0].RecordType.Name = 'Internal';
                insert con; // joy
                
                
                System.debug('Con is ' + con[0].RecordType.Name);
                
                List<Order__c> order = TestDataFactory.createOrder(1);
                order[0].Delivery_Charge__c = 20; 
                order[0].Recipient_Contact__c = con[0].id;
                order[0].Subscriber_Charge__c = 10;
                order[0].Account__c = acc.id;
                insert order;
                
                List<Package__c> pack = TestDataFactory.createPackage(1);    
                pack[0].Package_Type__c = 'Base';
                pack[0].Name = 'ST Print Test';
                pack[0].Subscription_Type__c = 'Termed'; //from Termed
                pack[0].Package_Code__c = 'STEST12';
                pack[0].Subscription_Period__c = '12';
                pack[0].Effective_Start_Date__c = date.today();
                pack[0].Effective_End_Date__c = date.today().addDays(5);
                //pack[0].Package_Type__c = 'Grace Period';
                insert pack;
                
                //Create Order Line Item
                List<Order_Line_Item__c> oli = TestDataFactory.createOrderLineItem(1);
                oli[0].Earliest_Start_Date__c = date.today();
                oli[0].Start_Date__c = date.today().addDays(1);
                oli[0].Order__c = order[0].id;
                oli[0].Main_Package_Period__c = 2;
                oli[0].Qty__c = 3;
                oli[0].Term_Length__c = 5;
                oli[0].Main_Package_ID__c = pack[0].id; 
                oli[0].Subscription_Name__c = 'test123'; 
                insert oli;
                
                List<Zuora__CustomerAccount__c> bill = TestDataFactory.createBillingAccount(1);
                bill[0].Zuora__Account__c = acc.Id;
                insert bill;
                
                //Create Zuora Subscription    
                List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(1);
                zSubs[0].Delivered_By__c = 'Mailing Agent';
                zSubs[0].Recipient_Contact_1__c = con[0].Id;  
                zSubs[0].Recipient_Contact__c = con[0].Id; 
                zSubs[0].Order_Line_Item_Number_1__c =  oli[0].id;
                zSubs[0].Order_Line_Item_Number__c =  oli[0].id;
                zSubs[0].Frequency_1__c = 'Default';
                zSubs[0].Frequency__c = 'Default';    
                zSubs[0].Number_of_Copies1__c = '1';
                zSubs[0].Number_of_Copies__c = 1;
                zSubs[0].Subscription_End_Date__c = String.valueOf(Date.today().addDays(5));
                zSubs[0].Main_Package_1__c = pack[0].id;
                zSubs[0].Main_Package__c = pack[0].id;
                zSubs[0].Zuora__SubscriptionEndDate__c = date.today() +5;
                zSubs[0].Zuora__CustomerAccount__c = bill[0].Id;
                zSubs[0].Subscription_Charge__c = 30;
                zSubs[0].Delivered_By_1__c = 'Mailing Agent';
                zSubs[0].Delivered_By__c = 'Mailing Agent';
                zSubs[0].Zuora__Account__c = acc.Id; // joy
                zSubs[0].Zuora__Status__c = GlobalVariableClass.STATUS_CANCELLED;
                insert zSubs;
                
                Zuora__SubscriptionProductCharge__c tmp = new Zuora__SubscriptionProductCharge__c();
                tmp.Zuora__Subscription__c = zSubs[0].Id;
                tmp.PublicationCode__c = 'Pub8';
                tmp.Zuora__Price__c = 2 ;
                insert tmp;
                
                
                //Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c
                
                
                List<zqu__ZProduct__c> zProductList = TestDataFactory.createZProduct(1);
                zProductList[0].ProductSubType__c = 'Newspaper';
                Database.insert(zProductList);
        
                
                //RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'zqu__ProductRatePlan__c' AND Name = 'Base Product'];
                zqu__ProductRatePlan__c prc =TestDataFactory.createProductRatePlan(1)[0];
                prc.RatePlanType__c = 'Bill Plan';
                prc.zqu__ZProduct__c = zProductList[0].id;
                //prc.RecordTypeId = rt.Id;
                insert prc;
                
                List<Package_Item__c> packageItemList = TestDataFactory.createPackageItem(1, 'Base Product');
                packageItemList[0].Package__c = pack[0].Id;
                packageItemList[0].Product_Rate_Plan__c = prc.id;
                Database.insert(packageItemList);
                
                
                Test.startTest();
                OverseasNewspaperSubscriptionBatchable batch = new OverseasNewspaperSubscriptionBatchable();
                //Id batchprocessid = Database.executeBatch(batch, 200);
                Database.BatchableContext bc;
                batch.execute(bc,zSubs);
                Test.stopTest();
            }
         }catch(Exception e){}
    }
    
   
}