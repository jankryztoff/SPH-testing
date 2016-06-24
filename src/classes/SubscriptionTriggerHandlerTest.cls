/**
* Class Name: <SubscriptionTriggerHandlerTest>
* @author: <JerellaMayelLedesma>
* Date: <8/7/2014>
* Requirement/Project Name: <SPH>
* @description<Test Class for SubscriptionTriggerHandlerTest, handles bulk insert and update>
* Last Modified by: Jp Ocariz
* Last Modified on: 02/13/2015
*/

@isTest
private class SubscriptionTriggerHandlerTest {
    
    //List of variables
    static List<Country__c> cntryList;
    static Account acnt;
    static List<Singpost_Address__c> singpostalList;
    static List<Address__c> addrList;
    static List<Contact> cntctList;
    static Zuora__CustomerAccount__c custAccount;
    static Package__c packge;
    static zqu__ZProduct__c zProducts;
    static zqu__ProductRatePlan__c prodRatePlan;
    static Product_Family__c prodFamily;
    static Package_Item__c packageItem;
    static Order__c orders;
    static List<Order_Line_Item__c> orderItemList;
    static Order_Line_Item__c ordLineItem;
    static Zuora__Subscription__c zuoraSubscription;
    static Promotion__c prom;
    static EmailTemplate validEmailTemplate;
    @testSetup 
    static void setupData() {
        
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createBatchInterface();  
        insert CustomSettingsDataFactory.createPlannerSched();
    }
    
    static void setUpTestData() {
        
        
        /*
Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
cir.Name = 'CIR Plan Schedule';
cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
database.insert(cir);

//CustomSettings
RecordType Case_ChangeinAddress = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Change of Address/Vendor' LIMIT 1];
RecordType Contact_CustomerContact = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Customer Contact' LIMIT 1];
RecordType Address_Local = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Local' LIMIT 1];
RecordType addressOverseas = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Overseas' LIMIT 1];
RecordType directCorporate = [SELECT id, Name FROM RecordType WHERE SobjectType='Account' AND Name='Direct Corporate' LIMIT 1];
RecordType addressAirline = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Airline' LIMIT 1];
RecordType addressInternal = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Internal' LIMIT 1];
RecordType caseStartSub = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Start Subscription' LIMIT 1];

//Key_Id__c
List<Key_Id__c> kisList = new List<Key_Id__c>{
new Key_Id__c(Name='Vendor Rep Role', Id__c='123456789', Type__c='Number'),
new Key_Id__c(Name='Case_Change in Address', Id__c=Case_ChangeinAddress.id ,Type__c='RecordType'),
new Key_Id__c(Name='Contact_Customer Contact', Id__c=Contact_CustomerContact.id ,Type__c='RecordType'),
new Key_Id__c(Name='Address_Local', Id__c=Address_Local.id ,Type__c='RecordType'),
new Key_Id__c(Name='Address_Overseas', Id__c=addressOverseas.id ,Type__c='RecordType'),
new Key_Id__c(Name='Address_Internal', Id__c=addressInternal.id ,Type__c='RecordType'),
new Key_Id__c(Name='Address_Airline', Id__c=addressAirline.id ,Type__c='RecordType'),
new Key_Id__c(Name='Case_Start Sub', Id__c=caseStartSub.id ,Type__c='RecordType'),
new Key_Id__c(Name='Account_Direct Corporate', Id__c=directCorporate.id ,Type__c='RecordType')
};
Database.insert(kisList);

//Other__c
List<Other__c> otherList = new List<Other__c>{
new Other__c(Name='DTL', Value__c='23:59')
};
Database.insert(otherList);
*/
        //Setup Country__c records
        cntryList = TestDataFactory.createCountry(2);
        cntryList[0].Country_Name__c = 'Quezon';
        cntryList[0].Code__c = 'QC';
        cntryList[1].Country_Name__c = 'Manila';
        cntryList[1].Code__c = 'XZ';
        insert cntryList;
        
        //Setup Account records
        acnt = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acnt.NRIC__c = 'T1234567R';
        acnt.Name = 'Test Account';
        acnt.Phone = '123-456';
        acnt.Email__c = 'test@test.com';
        acnt.Date_of_Birth__c = date.today();
        acnt.Gender__c = 'Male';
        acnt.Race__c = 'Chinese';
        acnt.Language__c = 'Others';
        acnt.Contact_Person__c = 'Contact Person';
        acnt.Sub_Group__c = 'Freelist(MY)';
        acnt.Generate_Account_Number__c = true;
        acnt.Renewal_Letter__c = 'Email';
        
        insert acnt;
        
        //Setup Postal records
        singpostalList = TestDataFactory.createSingpostAddress(2);
        singpostalList[0].Name = 'SPostal';
        singpostalList[0].House_Block_Number__c = 'TEST';
        singpostalList[0].Address_Type__c = 'A';
        singpostalList[0].Building_Name__c = 'Building';
        singpostalList[0].Street_Name__c = 'Street';
        singpostalList[1].Name = 'PPostal';
        singpostalList[1].House_Block_Number__c = 'TEST';
        singpostalList[1].Address_Type__c = 'A';
        singpostalList[1].Building_Name__c = 'Building';
        singpostalList[1].Street_Name__c = 'Street';
        insert singpostalList;
        
        //Address
        addrList = TestDataFactory.createAddress(2);
        addrList[0].Address_Type__c = 'A';
        addrList[0].Postal_Code__c = singpostalList[0].Id;
        addrList[0].Block_House_Number__c ='TEST';
        addrList[0].Level_Number__c ='xx';
        addrList[0].Unit_Number__c = 'yy';
        addrList[0].Country__c = cntryList[0].id;
        addrList[0].Address_1__c = 'Address 1';
        addrList[0].Address_2__c = 'Address 2';
        addrList[0].Address_3__c = 'Address 3';
        addrList[0].Address_4__c = 'Address 4';
        addrList[0].RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        addrList[1].Address_Type__c = 'A';
        addrList[1].Postal_Code__c = singpostalList[1].Id;
        addrList[1].Block_House_Number__c ='TEST';
        addrList[1].Level_Number__c ='xx';
        addrList[1].Unit_Number__c = 'yy';
        addrList[1].Country__c = cntryList[1].id;
        addrList[1].Address_1__c = 'Address 1';
        addrList[1].Address_2__c = 'Address 2';
        addrList[1].Address_3__c = 'Address 3';
        addrList[1].Address_4__c = 'Address 4';
        addrList[1].RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        insert addrList; 
        
        //Setup Contact records
        cntctList = TestDataFactory.createContact(2);
        cntctList[0].Address__c = addrList[0].Id;
        cntctList[0].AccountId = acnt.Id;
        cntctList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        cntctList[0].Billing_Indicator__c = true;
        cntctList[0].FirstName = 'Test';
        cntctList[0].LastName = 'Contact';
        cntctList[0].Passport__c = 'PassTest';
        cntctList[0].HomePhone__c = '123 456';
        cntctList[0].Mobile_Number__c = '123456';
        cntctList[0].Email = 'test@test.com';
        cntctList[0].Recipient_Indicator__c = true;
        cntctList[1].Address__c = addrList[1].Id;
        cntctList[1].AccountId = acnt.Id;
        cntctList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        cntctList[1].Billing_Indicator__c = true;
        cntctList[1].FirstName = 'Test1';
        cntctList[1].LastName = 'Contact';
        cntctList[1].Email = 'test@test.com';
        cntctList[1].Recipient_Indicator__c = true;
        insert cntctList;
        
        String ZuoraExternalId = 'try1234';
        String ZuoraZuoraIdc = 'Test1';
        String PackageCodec   = 'afds132';
        String PromotionCodec = 'yasyd97';
        
        //Setup Zuora__CustomerAccount__c
        
       
    
          
        custAccount = TestDataFactory.createBillingAccount(1)[0];
        custAccount.Zuora__Account__c = acnt.Id;
        custAccount.Billing_Contact__c = cntctList[1].Id;
        custAccount.Zuora__Zuora_Id__c = ZuoraZuoraIdc;
        custAccount.Billing_Type__c = 'Full Prepaid';
        custAccount.Zuora__DefaultPaymentMethod__c = 'Other';
        custAccount.Zuora__AccountNumber__c = 'Test1';
        //custAccount.Zuora__PaymentMethod_Type__c = 'Credit Card';
        //Zuora__Default_Payment_Method__c = pm.id;
        
        insert custAccount;
        Zuora__PaymentMethod__c pm = new Zuora__PaymentMethod__c();
        pm.Zuora__BillingAccount__c = custAccount.Id;
        pm.Zuora__Type__c = 'Cash';
        insert pm;
        custAccount.Zuora__Default_Payment_Method__c = pm.id;
        update custAccount;
        
       // update custAccount;
        //Setup Package records
        packge = TestDataFactory.createPackage(1)[0];
        packge.Billing_Type__c = 'Full Prepaid';
        packge.Package_Type__c = 'Grace Period';
        packge.Subscription_Period__c = '1';
        packge.Package_Code__c = PackageCodec;
        packge.Product_Family_Current_Package__c = 'test';
        insert packge;
        
        //Setup zqu__ZProduct__c records
        zProducts = TestDataFactory.createZProduct(1)[0];
        zProducts.ProductSubType__c = 'Magazine';
        zProducts.zqu__ZuoraId__c = 'Test';
        insert zProducts ;
        
        //Setup zqu__ProductRatePlan__c records
        prodRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
        prodRatePlan.zqu__ZProduct__c = zProducts.Id;
        prodRatePlan.RatePlanType__c= 'Proration';
        prodRatePlan.zqu__EffectiveStartDate__c= date.today();
        prodRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prodRatePlan.zqu__Deleted__c = false;
        prodRatePlan.zqu__ZuoraId__c = 'Test';
        insert prodRatePlan;
        
        //Setup Product_Family__c records
        prodFamily = new Product_Family__c();
        prodFamily.Product_Family__c = 'Trythis';
        prodFamily.Product_Family_Name__c = 'testtest';
        insert prodFamily;
        
        //Setup Package Item records
        packageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packageItem.Package__c = packge.id;
        packageItem.Product_Rate_Plan__c = prodRatePlan.id;
        packageItem.Name = 'Test Pack Item';
        packageItem.Product_Family__c = prodFamily.Id;
        insert packageItem;
        
        //Setup Order records
        orders = TestDataFactory.createOrder(1)[0];
        orders.Account__c = acnt.Id;
        orders.Informed_Customer__c = TRUE;
        orders.Order_Type__c = 'Renewal';
        orders.Status__c = 'Draft';
        orders.Eligible_for_Retention__c = TRUE;
        orders.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        orders.Payment_Mode__c = 'Credit Card';
        orders.Billing_Account__c = custAccount.id;
        orders.Billing_Type__c = 'Full Prepaid';
        orders.Billing_Contact__c = cntctList[1].id;
        orders.Recipient_Contact__c = cntctList[1].id;
        orders.Case_Record_Type__c = 'Complaint - Magazine';
        orders.Category__c = 'Subscription Request';
        orders.Sub_Category__c ='Stop Subscription';
        orders.Credit_Balance__c = 0;
        orders.Delivery_Charge__c = 0;
        orders.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        orders.Order_Type__c = 'Change of Subscription Package';
        orders.PO_Number__c = 'PO00000';
        orders.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
        orders.Delivery_Charge_Type__c = 'C';
        orders.Subscriber_Charge__c = 10.00;
        insert orders;
        
        //Order Line Item
        orderItemList = new List<Order_Line_Item__c>(1);
        ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
        ordLineItem.Order__c = orders.Id;
        ordLineItem.Start_Date__c = date.today().addDays(1);
        ordLineItem.End_Date__c = date.Today().addDays(4);
        ordLineItem.Main_Package_ID__c = packge.Id;
        ordLineItem.Term_Length__c = 0;
        ordLineItem.Main_Package_Period__c = 0;
        ordLineItem.Earliest_Start_Date__c = date.today();
        ordLineItem.Earliest_Stop_Date__c = Date.Today().addDays(2);
        ordLineItem.Stop_Request_Date__c =  date.Today().addDays(4);
        ordLineItem.Terminating_Reason__c = 'Others';
        ordLineItem.Amount_To_Refund__c = 0;
        ordLineItem.Admin_Charge__c = 0;
        ordLineItem.Fee_Waiver__c = TRUE;
        ordLineItem.Fee_Override__c = FALSE;
        ordLineItem.Override_Reason__c = 'TEST';
        ordLineItem.Suppress_Notification_Stop__c = TRUE;
        ordLineItem.Main_Package_Type__c = 'Base';
        insert ordLineItem;
        orderItemList.add(ordLineItem);
        
        Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = cntctList[0].id);        
        insert asiaOneRecord;
        System.debug('***wendy : inserted asiaOneRecord');
        
        Service_Access_Flag__c saf = new Service_Access_Flag__c();
        saf.Name = 'test name';
        insert saf;
        System.debug('***wendy : inserted saf');
        
        Package_Access_Flag__c paf = new Package_Access_Flag__c();
        paf.Package_Service_Access_Flag__c = saf.id;
        paf.Package__c = packge.id;
        paf.No_of_Concurrent_Users__c = 1;
        insert paf;
        System.debug('***wendy : inserted paf' + paf.Package__c);
        
        
        
        //create subscription vendor
        //Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
        ////SubVend.Name = 'Test Subscription Vendor';
        //insert SubVend;
        //System.debug('***wendy : inserted tmp');
        /*           
Case caseRec = new Case();
caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
caseRec.Status = 'Pending';
caseRec.Sub_Status__c = 'Wating for Vendor Assignment';               
insert caseRec;   
System.debug('***wendy : caseRec');  
*/
        
        /*
//Setup Zoura Records
zuoraSubscription = TestDataFactory.createSubscription(1)[0];
zuoraSubscription.Zuora__Account__c = acnt.Id;
zuoraSubscription.Order_Line_Item_Number__c = ordLineItem.Id;
zuoraSubscription.Subscriber_Contact__c = cntctList[0].Id;
zuoraSubscription.Recipient_Contact__c = cntctList[0].Id;
zuoraSubscription.Main_Package_1__c = packge.Id;
zuoraSubscription.Main_Package__c = packge.Id;
zuoraSubscription.Zuora__Status__c = 'Active';
zuoraSubscription.Order_Number__c = orders.Id;
zuoraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
zuoraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
zuoraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
zuoraSubscription.Urgent__c = 'false';
zuoraSubscription.Vendor_Conversion__c = 'false';
zuoraSubscription.Charity__c = 'false';
zuoraSubscription.Subscription_Type__c = 'Publication';
zuoraSubscription.Subscription_Type_1__c = 'Publication';
zuoraSubscription.Zuora__SubscriptionEndDate__c= date.today();
zuoraSubscription.Zuora__SubscriptionStartDate__c = date.today();
zuoraSubscription.Zuora__CustomerAccount__c = custAccount.Id;
zuoraSubscription.Contact__c = cntctList[0].id;
zuoraSubscription.Zuora__External_Id__c = ZuoraExternalId;
zuoraSubscription.Zuora__Zuora_Id__c = ZuoraExternalId;
zuoraSubscription.Order_Line_Item_Number_1__c = ordLineItem.Id;
zuoraSubscription.Delivered_By__c = 'Vendor';
insert zuoraSubscription; 
*/
        
    }
    static void setUpSubscription() {
        String ZuoraExternalId = 'try1234';
        zuoraSubscription = TestDataFactory.createSubscription(1)[0];
        zuoraSubscription.Zuora__Account__c = acnt.Id;
        zuoraSubscription.Order_Line_Item_Number__c = ordLineItem.Id;
        zuoraSubscription.Subscriber_Contact__c = cntctList[0].Id;
        zuoraSubscription.Recipient_Contact__c = cntctList[0].Id;
        zuoraSubscription.Main_Package_1__c = packge.Id;
        zuoraSubscription.Main_Package__c = packge.Id;
        zuoraSubscription.Zuora__Status__c = 'Active';
        zuoraSubscription.Order_Number__c = orders.Id;
        zuoraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
        zuoraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
        zuoraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zuoraSubscription.Urgent__c = 'false';
        zuoraSubscription.Vendor_Conversion__c = 'false';
        zuoraSubscription.Charity__c = 'false';
        zuoraSubscription.Subscription_Type__c = 'Publication';
        zuoraSubscription.Subscription_Type_1__c = 'Publication';
        zuoraSubscription.Zuora__SubscriptionEndDate__c= date.today();
        zuoraSubscription.Zuora__SubscriptionStartDate__c = date.today();
        zuoraSubscription.Zuora__CustomerAccount__c = custAccount.Id;
        zuoraSubscription.Contact__c = cntctList[0].id;
        zuoraSubscription.Zuora__External_Id__c = ZuoraExternalId;
        zuoraSubscription.Zuora__Zuora_Id__c = ZuoraExternalId;
        zuoraSubscription.Order_Line_Item_Number_1__c = ordLineItem.Id;
        zuoraSubscription.Delivered_By__c = 'Vendor';
        insert zuoraSubscription;     
    }
    static User createUser() {
        UserRole usrRole = [SELECT id, Name from UserRole LIMIT 1];
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User usr = new User(Alias = 'test122',Email='test2@test.sph.com',
                            EmailEncodingKey='UTF-8', LastName='Testing123', 
                            LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                            ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserRoleId = usrRole.Id,
                            UserName='testDeploymentUserJS00@sph.com', Title='Testing123');
        insert usr;
        
        return usr;
    }
    
    //@Description: tests if updating the zuora subscription will trigger methods
    //              before and after trigger update is set to FALSE.
    //@Parameters: none
    //@Return type: none
    static testMethod void testSingleInsertUpdate(){        
        User usr = createUser();
        
        //The test will run as the user created.
        System.runAs(usr) {
            setUpTestData();
                        List<Billing_Batch__c> billBatches = new List<Billing_Batch__c>();
            billBatches = CustomSettingsDataFactory.createBillingBatch();
            insert billBatches;
            Zuora__Subscription__c sobj = new Zuora__Subscription__c();
            Zuora__Subscription__c sobj2 = new Zuora__Subscription__c();        
            
            SubscriptionTriggerHandler subhandler = new SubscriptionTriggerHandler();
            subhandler.beforeDelete(sobj);
            SubscriptionTriggerHandler subhandler2 = new SubscriptionTriggerHandler();
            subhandler.afterDelete(sobj2);
            
            subhandler.testCoveragePatch();
            
            SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = FALSE;
            SubscriptionTriggerHandler.isAfterDeleteTriggerCalled = FALSE;
            
            //Singpost_Address__c postal = new Singpost_Address__c();
            //postal = TestDataFactory.createSingpostAddress(1)[0];
            //insert postal;
            
            //Address__c address = new Address__c();
            //address = TestDataFactory.createAddress(1)[0];
            //address.Postal_Code__c = postal.Id;
            //insert address;
            
            //Package__c pack = new Package__c();
            //pack = TestDataFactory.createPackage(1)[0];
            //insert pack;
            
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
            //acctVendor.Ven
            insert acctVendor;
            
            //Contact con = new Contact();
            //con = TestDataFactory.createContact(1)[0];
            //con.AccountId = acct.Id;
            //con.Address__c = address.Id;
            //// START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
            ////con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            //con.Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            //insert con;
            
            /*[JPO 02/13] create con2
Contact con2 = new Contact();
con2 =  TestDataFactory.createContact(1)[0];
con2.AccountId = acct2.Id;
con2.Address__c = address.Id;            
con2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
con2.Recipient_Indicator__c = true;
insert con2; */
            
            
            
            //create order
            /*   Order__c order = TestDataFactory.createOrder(1)[0];
order.Account__c = acnt.Id;
order.Recipient_Contact__c = cntctList[1].Id;
order.Informed_Customer__c = True;*/
            //order.Base_Subscription__c = zuoraSubscription.Id;
            
            //WAK 04/15/16 added
            //order.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            //insert order;
            
            /*[JPO 02/13] create order2 for subrRec's orderline item 1
Order__c order2 = TestDataFactory.createOrder(1)[0];
order2.Account__c = acct2.Id;
order2.Recipient_Contact__c = con2.Id;
order2.Informed_Customer__c = True;
insert order2; //error? FIELD_FILTER_VALIDATION_EXCEPTION, Value does not exist or does not match filter criteria.: [Recipient_Contact__c]
*/
            //create case
            //Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            //cas.Order__c = order.Id;
            //insert cas;
            /*
Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
orderline.Order__c = order.Id;
orderline.End_Date__c = date.newInstance(2014, 12, 2);
orderline.End_Date__c = date.today()+30;
orderline.Main_Package_ID__c = packge.Id;
orderline.Term_Length__c = 1;
orderline.Main_Package_Period__c = 0;
orderline.Earliest_Start_Date__c = date.today();
orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
orderline.Stop_Request_Date__c =  date.Today().addDays(4);
orderline.Terminating_Reason__c = 'Others';
orderline.Amount_To_Refund__c = 0;
orderline.Admin_Charge__c = 0;
orderline.Fee_Waiver__c = TRUE;
orderline.Fee_Override__c = TRUE;
orderline.Override_Reason__c = 'TEST';
orderline.Suppress_Notification_Stop__c = TRUE;
orderline.Main_Package_Type__c = 'Base';
orderline.Start_Date__c = date.today()+5;
*/
            
            //WAK 04/15/2016
            Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = cntctList[0].id);        
            insert asiaOneRecord;
            System.debug('***wendy : inserted asiaOneRecord');
            
            Service_Access_Flag__c saf = new Service_Access_Flag__c();
            saf.Name = 'test name';
            insert saf;
            System.debug('***wendy : inserted saf');
            
            Package_Access_Flag__c paf = new Package_Access_Flag__c();
            paf.Package_Service_Access_Flag__c = saf.id;
            paf.Package__c = packge.id;
            paf.No_of_Concurrent_Users__c = 1;
            insert paf;
            System.debug('***wendy : inserted paf' + paf.Package__c);
            
            List<Asia1_Subscription__c> tmpList = new List<Asia1_Subscription__c>();
            Asia1_Subscription__c tmp = new Asia1_Subscription__c();
            tmp.Asia1__c = asiaOneRecord.id;
            tmp.Order_Line_Item__c = ordLineItem.id;
            tmp.Service_Access_Flag__c = saf.id;
            tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
            tmpList.add(tmp);
            Asia1_Subscription__c tmp1 = new Asia1_Subscription__c();
            tmp1.Asia1__c = asiaOneRecord.id;
            tmp1.Order_Line_Item__c = ordLineItem.id;
            tmp1.Service_Access_Flag__c = saf.id;
            tmp1.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED;
            tmpList.add(tmp1);
            insert tmpList; 
            System.debug('***wendy : inserted tmp');
            
            //create subscription vendor
            //Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            ////SubVend.Name = 'Test Subscription Vendor';
            //insert SubVend;
            //System.debug('***wendy : inserted tmp');
            
            Case caseRec = new Case();
            caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            caseRec.Status = 'Pending';
            caseRec.Sub_Status__c = 'Wating for Vendor Assignment';               
            insert caseRec;   
            System.debug('***wendy : caseRec'); 
            
            Subscription_Vendor__c venSub = new Subscription_Vendor__c();
            venSub = TestDataFactory.createSubscriptionVendor(1)[0];
            insert venSub;
            
            Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
            zua.Zuora__Account__c = acnt.Id;
            zua.Zuora__DefaultPaymentMethod__c = 'Other';
            //zua.Zuora__PaymentMethodType__c = 'Paypal';
            insert zua; 
            System.debug('***wendy : inserted zua');
            String ZuoraExternalId = 'try1234';
            Zuora__Subscription__c subRec = TestDataFactory.createSubscription(1)[0];
            subRec.Zuora__Account__c = acnt.Id;
            subRec.Order_Line_Item_Number__c = ordLineItem.Id;
            subRec.Subscriber_Contact__c = cntctList[0].Id;
            subRec.Recipient_Contact__c = cntctList[0].Id;
            subRec.Main_Package_1__c = packge.Id;
            subRec.Main_Package__c = packge.Id;
            subRec.Zuora__Status__c = 'Active';
            subRec.Order_Number__c = orders.Id;
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Charity__c = 'false';
            subRec.Subscription_Type__c = 'Publication';
            subRec.Subscription_Type_1__c = 'Publication';
            subRec.Zuora__SubscriptionEndDate__c= date.today().addDays(30);        
            subRec.Zuora__TermSettingType__c = 'TERMED';
            subRec.Term_Length__c = 1;
            subRec.Zuora__SubscriptionStartDate__c = date.today();
            subRec.Zuora__CustomerAccount__c = custAccount.Id;
            subRec.Contact__c = cntctList[0].id;
            subRec.Zuora__External_Id__c = ZuoraExternalId;
            subRec.Zuora__Zuora_Id__c = ZuoraExternalId;
            subRec.Order_Line_Item_Number_1__c = ordLineItem.Id;
            subRec.Delivered_By__c = 'Vendor';
            subRec.Vendor_Subscription_To_Convert_1__c = venSub.id;
            subRec.Term_Length__c = 12;
            subRec.Zuora__TermSettingType__c = 'EVERGREEN';
            
            
            // insert zuoraSubscription;
            /*
Zuora__Subscription__c subRec = new Zuora__Subscription__c();
subRec = TestDataFactory.createSubscription(1)[0];
subRec.Zuora__Account__c = acnt.Id;
subRec.Order_Number__c = order.Id;
subRec.Subscriber_Contact__c = cntctList[0].Id;
//subRec.Recipient_Contact__c = con.Id;
subRec.Main_Package_1__c = packge.id;
subRec.Zuora__Status__c = 'Active';
//subRec.Zuora__Status__c = 'Cancelled'; [JPO 02/13] commented out
subRec.Suppress_Vendor_Start_Notice__c = 'false';
subRec.Supressed_Acknowledgement_Letter__c = 'false';
subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
subRec.Urgent__c = 'false';
subRec.Vendor_Conversion__c = 'false';
subRec.Charity__c = 'false';
subRec.Order_Line_Item_Number__c = ordLineItem.Id;
subrec.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
subRec.Vendor_1__c = acctVendor.id;
subRec.Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
//subRec.Order_Number_1__c = order2.id; //[JPO 02/13] added 
*/       
            
            test.startTest(); //[JPO 02/12/2015] Moved startTest before inserting subRec 
            insert subRec; 
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acnt.Id;
            order.Recipient_Contact__c = cntctList[1].Id;
            order.Informed_Customer__c = True;
            insert order;
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = packge.Id;
            orderline.Term_Length__c = 1;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+5;
            orderline.Subscription_Name__c = subRec.name;
            orderline.Main_Package_Subscription_Rate__c  = 10;
            orderline.Qty__c = 1;
            insert orderline;
            subRec.Zuora__Status__c = 'Cancelled';
            subRec.Recipient_Contact__c = null;
            subRec.Subscription_Charge__c = null;
            update subRec;
            
            System.debug('***wendy : inserted subRec');
            
           
            
            Zuora__Subscription__c subRec2 = new Zuora__Subscription__c();
            subRec2 = TestDataFactory.createSubscription(1)[0];
            subRec2.Zuora__Version__c = 2; 
            subRec2.Zuora__CustomerAccount__c = custAccount.Id;       
            insert subRec2;
                        
            
            //[JPO 02/12/2015] Adding List
            //List<Zuora__Subscription__c> testsubscriptionList = TestDataFactory.createSubscription(1);
            //testsubscriptionList.add(subrec);
            
            //insert testsubscriptionList;
            
            /* removing this causing SOQL limit
Zuora__Subscription__c subRec2 = new Zuora__Subscription__c();
subRec2 = TestDataFactory.createSubscription(1)[0];
subRec2.Zuora__Account__c = acct.Id;
subRec2.Order_Number__c = order.Id;
subRec2.Subscriber_Contact__c = con.Id;
subRec2.Recipient_Contact__c = con.Id;
subRec2.Main_Package_1__c = pack.id;
subRec2.Suppress_Vendor_Start_Notice__c = 'false';
subRec2.Supressed_Acknowledgement_Letter__c = 'false';
subRec2.Supressed_Renewal_and_Reminder_Letter__c = 'false';
subRec2.Urgent__c = 'false';
subRec2.Vendor_Conversion__c = 'false';
subRec2.Charity__c = 'false';
//subRec2.Zuora__Status__c = NULL;
subRec2.Order_Line_Item_Number__c = orderline.Id;
insert subRec2;

Zuora__Subscription__c subRec3 = new Zuora__Subscription__c();
subRec3 = TestDataFactory.createSubscription(1)[0];
subRec3.Zuora__Account__c = acct.Id;
subRec3.Order_Number__c = order.Id;
subRec3.Subscriber_Contact__c = con.Id;
subRec3.Recipient_Contact__c = con.Id;
subRec3.Main_Package_1__c = pack.id;
subRec3.Suppress_Vendor_Start_Notice__c = 'false';
subRec3.Supressed_Acknowledgement_Letter__c = 'false';
subRec3.Supressed_Renewal_and_Reminder_Letter__c = 'false';
subRec3.Urgent__c = 'false';
subRec3.Vendor_Conversion__c = 'false';
subRec3.Charity__c = 'false';
subRec3.Order_Line_Item_Number__c = orderline.Id;
insert subRec3;
*/                      
            /*
            Case_Subscription__c  caseSub = new Case_Subscription__c();
            caseSub.Account__c = acnt.Id;
            caseSub.Address__c = addrList[0].Id;
            caseSub.Case__c = caseRec.Id;
            caseSub.Subscription__c = subRec.Id;
            insert caseSub;    
            
            System.assertEquals(acnt.Id, caseSub.Account__c);
            */
            
            /*
try{    
subRec.Vendor_1__c = NULL;
update subRec;
//subRec2.Vendor_1__c = NULL;
//update subRec2;   
}   
catch (Exception e){
Boolean expectedExceptionThrown =  e.getMessage().contains('Vendor cannot be empty.') ? true : false;
//System.AssertEquals(expectedExceptionThrown, true);
}
*/
            
            subRec.Zuora__Status__c = 'Cancelled'; // [JPO 2/13] Made 'Active' From ''
            subRec.Zuora__SubscriptionStartDate__c = Date.today().addMonths(-Integer.valueOf(subRec.Term_Length__c));
            subRec.Zuora__SubscriptionEndDate__c = Date.today();
            //update subRec;
            //subRec2.Zuora__Status__c = 'Active';
            //update subRec2;
            //subRec3.Zuora__Status__c = 'Active';
            //update subRec3;
            
            //update            
            SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = false;
            SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = false;   
            //subRec.Vendor_1__c = acctVendor.Id; 
            //subRec.Vendor__c = acctVendor.Id;
            // System.assertEquals(null, acctVendor.Id);    
            subRec.Vendor__c = acctVendor.Id+'';
           // update subRec; // venor cdannot be empty error
            
            SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
            handler.runBeforeUpdateTrigger();
            handler.runAfterUpdateTrigger();
            //TEST: if 
            
            handler.runBeforeInsertTrigger();
            handler.runBeforeDeleteTrigger();
            handler.runAfterInsertTrigger();
            handler.runAfterDeleteTrigger();
            
            
            
            test.stoptest();    
        }
    }
    
    /*
    //@Description: tests if deleting the zuora subscription will trigger methods
    //              before and after trigger update is set to FALSE.
    //@Parameters: none
    //@Return type: none
    static testMethod void testSingleDelete(){        
        User usr = createUser();
        
        //The test will run as the user created.
        System.runAs(usr) {
            setUpTestData();
            setUpSubscription();
            
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
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.NRIC__c = 'T1234567R';
            insert acct;
            
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
            /*
//create case
Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
cas.Order__c = orders.Id;
cas.AccountId =  acnt.Id;//for InsertCaseSubforStop
cas.Sub_Category__c = 'Stop Subscription';
insert cas;
*//*
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            
            //orderLine.Case__c = cas.Id;
            orderline.Start_Date__c = date.today()+5;
            //WAk
            orderline.Subscription_Name__c = 'TestSubName';
            insert orderline;
            
            ordLineItem.Subscription_Name__c = 'TestSubName';
            ordLineItem.Fee_Override__c = TRUE;
            //ordLineItem.Case__c = cas.Id;
            update ordLineItem;
            
            zuoraSubscription.Zuora__Status__c = 'Cancelled';
            update zuoraSubscription;
            
            System.assertEquals(order.Id, orderline.Order__c);  
            
            Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
            zua.Zuora__Account__c = acct.Id;
            zua.Zuora__DefaultPaymentMethod__c = 'Other';
            zua.Zuora__PaymentMethodType__c = 'Paypal';
            insert zua;      
            
            Zuora__Subscription__c subRec = new Zuora__Subscription__c();
            subRec = TestDataFactory.createSubscription(1)[0];
            subRec.Zuora__Account__c = acct.Id;
            subRec.Order_Number__c = order.Id;
            subRec.Subscriber_Contact__c = con.Id;
            subRec.Recipient_Contact__c = con.Id;
            subRec.Main_Package_1__c = pack.id;
            subRec.Zuora__Status__c = 'Active';
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Charity__c = 'false';
            subRec.Order_Line_Item_Number__c = orderline.Id;
            subRec.Zuora__Status__c = 'Cancelled';
            subRec.Name = 'TestSubName';
            subRec.Zuora__CustomerAccount__c = zua.id;
            insert subRec; 
            
            SubscriptionTriggerHandler.isBeforeInsertTriggerCalled = false;
            SubscriptionTriggerHandler.isAfterInsertTriggerCalled = false;
            
            test.startTest(); //  [JPO 02/12/2015] Moved startTest 
            
            //WAK: 4/12/2016
            Zuora__SubscriptionProductCharge__c subProdCharge = new Zuora__SubscriptionProductCharge__c();    
            subProdCharge.Zuora__Subscription__c = zuoraSubscription.Id;
            subProdCharge.Name = 'Goodwill Charge';
            subProdCharge.Zuora__Zuora_Id__c = '12345';
            insert subProdCharge;
            
            // delete
            SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = false;
            SubscriptionTriggerHandler.isAfterDeleteTriggerCalled = false;
            
            test.stoptest();    
        }
    }
   */    //@Description: tests if updating the zuora subscription with payment type = PAYPAL will trigger methods
    //              before and after trigger update is set to FALSE.
    //@Parameters: none
    //@Return type: none
  /*  static testMethod void testTransferDeliveryChargeToPayPal(){
    
        User usr = createUser();
    
    //    //The test will run as the user created.
        System.runAs(usr) {
           setUpTestData();
           setUpSubscription();
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
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.NRIC__c = 'T1234567R';
            insert acct;
    
    
    
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
            insert acctVendor;
    
            Contact con = new Contact();
            con = TestDataFactory.createContact(1)[0];
            con.AccountId = acnt.Id;
            con.Address__c = address.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
    
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acnt.Id;
            order.Recipient_Contact__c = cntctList[0].Id;
            order.Informed_Customer__c = True;
            insert order;
            /*
            //create case
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            insert cas;
    *//*
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+5;
            insert orderline;
           /*
    
           Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
           zua.Zuora__Account__c = acnt.Id;
           zua.Zuora__DefaultPaymentMethod__c = 'Other';
           zua.Zuora__PaymentMethodType__c = 'Paypal';
           insert zua;
            
            /
           Zuora__CustomerAccount__c zua2 =  TestDataFactory.createBillingAccount(1)[0];
           zua2.Zuora__Account__c = acnt.Id;
           zua.Zuora__PaymentMethodType__c = 'Cash';
           insert zua2;
            
           Zuora__PaymentMethod__c pm = new Zuora__PaymentMethod__c();
           pm.Zuora__BillingAccount__c = zua.Id;
           pm.Zuora__Type__c = 'Cash';
            
           insert pm;
            */
            /*
           Zuora__PaymentMethod__c pm2 = new Zuora__PaymentMethod__c();
           pm2.Zuora__Type__c = 'PayPal';
           pm2.Zuora__BillingAccount__c = custAccount.id;
           insert pm2;           
           
            //create subscription vendor
            Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            //SubVend.Name = 'Test Subscription Vendor';
            insert SubVend;
            /*
            Case caseRec = new Case();
            caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            caseRec.Status = 'Pending';
            caseRec.Sub_Status__c = 'Wating for Vendor Assignment';    
            insert caseRec;    
            */
             //test.startTest(); 
             
           
       
             
               /* 
            Zuora__Subscription__c subRec = new Zuora__Subscription__c();
            subRec = TestDataFactory.createSubscription(1)[0];
            subRec.Zuora__Account__c = acnt.Id;
            subRec.Order_Number__c = order.Id;
            subRec.Subscriber_Contact__c = cntctList[0].Id;
            subRec.Recipient_Contact__c = cntctList[0].Id;
            subRec.Main_Package_1__c = packge.id;
            subRec.Zuora__CustomerAccount__c = custAccount.id;
            subRec.Zuora__Status__c = 'Expired'; //[JPO 02/12/2015] changed from 'Active'
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Charity__c = 'false';
            subRec.Order_Line_Item_Number__c = ordLineItem.Id; 
            subRec.Vendor_1__c = acnt.id;
            subRec.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
            subRec.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    
            test.startTest();
            
           // insert zuoraSubscription; 
            insert subRec;
            
            custAccount.Zuora__Default_Payment_Method__c = pm2.id;
            update custAccount;
            /*
            Case_Subscription__c  caseSub = new Case_Subscription__c();
            caseSub = TestDataFactory.createCaseSubscription(1)[0];
            caseSub.Account__c = acnt.Id;
            caseSub.Address__c = addrList[0].Id;
            caseSub.Case__c = caseRec.Id;
            caseSub.Subscription__c = subRec.Id;
            insert caseSub;
            */
            /*
            try{    
                subRec.Vendor_1__c = NULL;
                update subRec; 
            }   
            catch (Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Vendor cannot be empty.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
           
            subRec.Zuora__Status__c = '';
     */
        /*     //  update         
            SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = true;
            SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = true;   
            subRec.Vendor__c = acnt.Id+'';
            subRec.Zuora__Status__c = 'Expired';
            update subRec; //vendor cannot be empty error
    
    
           SubscriptionTriggerHandler sth= new SubscriptionTriggerHandler();
            sth.runBeforeInsertTrigger();
            sth.runBeforeUpdateTrigger();
            sth.runBeforeDeleteTrigger();
            sth.runAfterInsertTrigger();
            sth.runAfterUpdateTrigger();
            sth.runAfterDeleteTrigger();
    
    
        test.stoptest();    
        }
    }
    */
    ////@Description: tests if updating the zuora subscription will trigger methods
    ////              before and after trigger update is set to FALSE.
    ////@Parameters: none
    ////@Return type: none
    //static testMethod void testUpdateRelatedSubscription(){
    //    User usr = createUser();
    
    //    //The test will run as the user created.
    //    System.runAs(usr) {
    //        setUpTestData();
    
    //        Zuora__Subscription__c sobj = new Zuora__Subscription__c();
    //        Zuora__Subscription__c sobj2 = new Zuora__Subscription__c();        
    
    //        SubscriptionTriggerHandler subhandler = new SubscriptionTriggerHandler();
    //        subhandler.beforeDelete(sobj);
    //        SubscriptionTriggerHandler subhandler2 = new SubscriptionTriggerHandler();
    //        subhandler.afterDelete(sobj2);
    //        SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = FALSE;
    //        SubscriptionTriggerHandler.isAfterDeleteTriggerCalled = FALSE;
    
    //        Singpost_Address__c postal = new Singpost_Address__c();
    //        postal = TestDataFactory.createSingpostAddress(1)[0];
    //        insert postal;
    
    //        Address__c address = new Address__c();
    //        address = TestDataFactory.createAddress(1)[0];
    //        address.Postal_Code__c = postal.Id;
    //        insert address;
    
    //        Package__c pack = new Package__c();
    //        pack = TestDataFactory.createPackage(1)[0];
    //        insert pack;
    
    //        Account acct = new Account();
    //        acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //        acct.NRIC__c = 'T1234567R';
    //        insert acct;
    
    //        Account acctVendor = new Account();
    //        acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
    //        //acctVendor.Ven
    //        insert acctVendor;
    
    //        Account acct2 = new Account();
    //        acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //        acct2.NRIC__c = 'T1234567R';
    //        insert acct2;
    
    //        Contact con = new Contact();
    //        con = TestDataFactory.createContact(1)[0];
    //        con.AccountId = acct.Id;
    //        con.Address__c = address.Id;
    //        // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
    //        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
    //        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //        con.Recipient_Indicator__c = true;
    //        // END : CCB 002 12/2/2014
    //        insert con;
    
    //        /*[JPO 02/13] create con2
    //        Contact con2 = new Contact();
    //        con2 =  TestDataFactory.createContact(1)[0];
    //        con2.AccountId = acct2.Id;
    //        con2.Address__c = address.Id;            
    //        con2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //        con2.Recipient_Indicator__c = true;
    //        insert con2; */
    
    //        //create order
    //        Order__c order = TestDataFactory.createOrder(1)[0];
    //        order.Account__c = acct.Id;
    //        order.Recipient_Contact__c = con.Id;
    //        order.Informed_Customer__c = True;
    //        //order.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
    //        insert order;
    
    //        /*[JPO 02/13] create order2 for subrRec's orderline item 1
    //        Order__c order2 = TestDataFactory.createOrder(1)[0];
    //        order2.Account__c = acct2.Id;
    //        order2.Recipient_Contact__c = con2.Id;
    //        order2.Informed_Customer__c = True;
    //        insert order2; //error? FIELD_FILTER_VALIDATION_EXCEPTION, Value does not exist or does not match filter criteria.: [Recipient_Contact__c]
    //        */
    //        //create case
    //        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
    //        cas.Order__c = order.Id;
    //        insert cas;
    
    //        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
    //        orderline.Order__c = order.Id;
    //        //orderline.End_Date__c = date.newInstance(2014, 12, 2);
    //        orderline.End_Date__c = date.today()+30;
    //        orderline.Main_Package_ID__c = pack.Id;
    //        orderline.Term_Length__c = 0;
    //        orderline.Main_Package_Period__c = 0;
    //        orderline.Earliest_Start_Date__c = date.today();
    //        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
    //        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
    //        orderline.Terminating_Reason__c = 'Others';
    //        orderline.Amount_To_Refund__c = 0;
    //        orderline.Admin_Charge__c = 0;
    //        orderline.Fee_Waiver__c = TRUE;
    //        orderline.Fee_Override__c = TRUE;
    //        orderline.Override_Reason__c = 'TEST';
    //        orderline.Suppress_Notification_Stop__c = TRUE;
    //        orderline.Main_Package_Type__c = 'Base';
    //        orderline.Start_Date__c = date.today()+5;
    //        insert orderline;
    
    //         //create subscription vendor
    //        Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
    //        //SubVend.Name = 'Test Subscription Vendor';
    //        insert SubVend;
    
    //        Case caseRec = new Case();
    //        caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
    //        caseRec.Status = 'Pending';
    //        caseRec.Sub_Status__c = 'Wating for Vendor Assignment';               
    //        insert caseRec;     
    
    //         Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
    //       zua.Zuora__Account__c = acct.Id;
    //       zua.Zuora__DefaultPaymentMethod__c = 'Other';
    //       //zua.Zuora__PaymentMethodType__c = 'Paypal';
    //       insert zua; 
    
    //        Zuora__Subscription__c relSub = new Zuora__Subscription__c();
    //        relSub = TestDataFactory.createSubscription(1)[0];
    //        relSub.Zuora__Account__c = acct.Id;
    //        relSub.Order_Number__c = order.Id;
    //        relSub.Subscriber_Contact__c = con.Id;
    //        relSub.Recipient_Contact__c = con.Id;
    //        relSub.Main_Package_1__c = pack.id;
    //        relSub.Zuora__Status__c = 'Active';
    //        //subRec.Zuora__Status__c = 'Cancelled'; [JPO 02/13] commented out
    //        relSub.Suppress_Vendor_Start_Notice__c = 'false';
    //        relSub.Supressed_Acknowledgement_Letter__c = 'false';
    //        relSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        relSub.Urgent__c = 'false';
    //        relSub.Vendor_Conversion__c = 'false';
    //        relSub.Charity__c = 'false';
    //        relSub.Order_Line_Item_Number__c = orderline.Id;
    //        relSub.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
    //        relSub.Vendor_1__c = acctVendor.id;
    //        relSub.Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
    //        //subRec.Order_Number_1__c = order2.id; //[JPO 02/13] added 
    //        relSub.Zuora__Zuora_Id__c = '111111';
    //        //insert relSub;
    
    //        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
    //        subRec = TestDataFactory.createSubscription(1)[0];
    //        subRec.Zuora__Account__c = acct.Id;
    //        subRec.Order_Number__c = order.Id;
    //        subRec.Subscriber_Contact__c = con.Id;
    //        subRec.Recipient_Contact__c = con.Id;
    //        subRec.Main_Package_1__c = pack.id;
    //        subRec.Zuora__Status__c = 'Active';
    //        //subRec.Zuora__Status__c = 'Cancelled'; [JPO 02/13] commented out
    //        subRec.Suppress_Vendor_Start_Notice__c = 'false';
    //        subRec.Supressed_Acknowledgement_Letter__c = 'false';
    //        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        subRec.Urgent__c = 'false';
    //        subRec.Vendor_Conversion__c = 'false';
    //        subRec.Charity__c = 'false';
    //        subRec.Order_Line_Item_Number__c = orderline.Id;
    //        subrec.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
    //        subRec.Vendor_1__c = acctVendor.id;
    //        subRec.Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
    //        //subRec.Order_Number_1__c = order2.id; //[JPO 02/13] added 
    //        subRec.Zuora__AutoRenew__c = true;  // WAK 04/13/16 added
    //        subRec.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; // WAK 04/13/16 added
    //        //subRec.Related_Subscription__c = relSub.Zuora__Zuora_Id__c; // WAK 04/13/16 added
    
    //        test.startTest(); //[JPO 02/12/2015] Moved startTest before inserting subRec  
    
    
    //        //insert subRec;      
    
    //        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
    //        subList.add(relSub);
    //        subList.add(subRec);
    //        insert subList;
    //        //[JPO 02/12/2015] Adding List
    //        //List<Zuora__Subscription__c> testsubscriptionList = TestDataFactory.createSubscription(1);
    //        //testsubscriptionList.add(subrec);
    
    //        //insert testsubscriptionList;
    
    //        /* removing this causing SOQL limit
    //        Zuora__Subscription__c subRec2 = new Zuora__Subscription__c();
    //        subRec2 = TestDataFactory.createSubscription(1)[0];
    //        subRec2.Zuora__Account__c = acct.Id;
    //        subRec2.Order_Number__c = order.Id;
    //        subRec2.Subscriber_Contact__c = con.Id;
    //        subRec2.Recipient_Contact__c = con.Id;
    //        subRec2.Main_Package_1__c = pack.id;
    //        subRec2.Suppress_Vendor_Start_Notice__c = 'false';
    //        subRec2.Supressed_Acknowledgement_Letter__c = 'false';
    //        subRec2.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        subRec2.Urgent__c = 'false';
    //        subRec2.Vendor_Conversion__c = 'false';
    //        subRec2.Charity__c = 'false';
    //        //subRec2.Zuora__Status__c = NULL;
    //        subRec2.Order_Line_Item_Number__c = orderline.Id;
    //        insert subRec2;
    
    //        Zuora__Subscription__c subRec3 = new Zuora__Subscription__c();
    //        subRec3 = TestDataFactory.createSubscription(1)[0];
    //        subRec3.Zuora__Account__c = acct.Id;
    //        subRec3.Order_Number__c = order.Id;
    //        subRec3.Subscriber_Contact__c = con.Id;
    //        subRec3.Recipient_Contact__c = con.Id;
    //        subRec3.Main_Package_1__c = pack.id;
    //        subRec3.Suppress_Vendor_Start_Notice__c = 'false';
    //        subRec3.Supressed_Acknowledgement_Letter__c = 'false';
    //        subRec3.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        subRec3.Urgent__c = 'false';
    //        subRec3.Vendor_Conversion__c = 'false';
    //        subRec3.Charity__c = 'false';
    //        subRec3.Order_Line_Item_Number__c = orderline.Id;
    //        insert subRec3;
    //        */                      
    
    //        Case_Subscription__c  caseSub = new Case_Subscription__c();
    //        caseSub.Account__c = acct.Id;
    //        caseSub.Address__c = address.Id;
    //        caseSub.Case__c = caseRec.Id;
    //        caseSub.Subscription__c = subRec.Id;
    //        insert caseSub;    
    
    //        System.assertEquals(acct.Id, caseSub.Account__c);
    
    
    //        /*
    //        try{    
    //            subRec.Vendor_1__c = NULL;
    //            update subRec;
    //            //subRec2.Vendor_1__c = NULL;
    //            //update subRec2;   
    //        }   
    //        catch (Exception e){
    //            Boolean expectedExceptionThrown =  e.getMessage().contains('Vendor cannot be empty.') ? true : false;
    //            //System.AssertEquals(expectedExceptionThrown, true);
    //        }
    //        */
    
    //        subRec.Zuora__Status__c = 'Active'; // [JPO 2/13] Made 'Active' From ''
    //        subRec.Related_Subscription__c = relSub.Zuora__Zuora_Id__c; // WAK 04/13/16 added
    //        //update subRec;
    //        //subRec2.Zuora__Status__c = 'Active';
    //        //update subRec2;
    //        //subRec3.Zuora__Status__c = 'Active';
    //        //update subRec3;
    
    //        //update            
    
    //        //Test.setMock(WebServiceMock.class, new zLoginMock());
    //        //Zuora.zApi zApiInstance = new Zuora.zApi();
    //        //zApiInstance.zlogin();
    
    //        SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = false;
    //        SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = false;   
    //        //subRec.Vendor_1__c = acctVendor.Id; 
    //        //subRec.Vendor__c = acctVendor.Id;
    //        // System.assertEquals(null, acctVendor.Id);    
    //        subRec.Vendor__c = acctVendor.Id+'';
    //        update subRec; // venor cdannot be empty error
    
    
    //        SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
    //        handler.runBeforeUpdateTrigger();
    //        handler.runAfterUpdateTrigger();
    //        //TEST: if 
    
    
    
    //    test.stoptest();    
    //    }
    //}
    
    //static testMethod void testSingleInsertUpdate2(){        
    //    User usr = createUser();
    
    //    //The test will run as the user created.
    //    System.runAs(usr) {
    //        setUpTestData();
    
    //        Zuora__Subscription__c sobj = new Zuora__Subscription__c();
    //        Zuora__Subscription__c sobj2 = new Zuora__Subscription__c();        
    
    //        SubscriptionTriggerHandler subhandler = new SubscriptionTriggerHandler();
    //        subhandler.beforeDelete(sobj);
    //        SubscriptionTriggerHandler subhandler2 = new SubscriptionTriggerHandler();
    //        subhandler.afterDelete(sobj2);
    //        SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = FALSE;
    //        SubscriptionTriggerHandler.isAfterDeleteTriggerCalled = FALSE;
    
    //        Singpost_Address__c postal = new Singpost_Address__c();
    //        postal = TestDataFactory.createSingpostAddress(1)[0];
    //        insert postal;
    
    //        Address__c address = new Address__c();
    //        address = TestDataFactory.createAddress(1)[0];
    //        address.Postal_Code__c = postal.Id;
    //        insert address;
    
    //        Package__c pack = new Package__c();
    //        pack = TestDataFactory.createPackage(1)[0];
    //        insert pack;
    
    //        Account acct = new Account();
    //        acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //        acct.NRIC__c = 'T1234567R';
    //        insert acct;
    
    //        Account acctVendor = new Account();
    //        acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
    //        //acctVendor.Ven
    //        insert acctVendor;
    
    //        Account acct2 = new Account();
    //        acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //        acct2.NRIC__c = 'T1234567R';
    //        insert acct2;
    
    //        Contact con = new Contact();
    //        con = TestDataFactory.createContact(1)[0];
    //        con.AccountId = acct.Id;
    //        con.Address__c = address.Id;
    //        // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
    //        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
    //        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //        con.Recipient_Indicator__c = true;
    //        // END : CCB 002 12/2/2014
    //        insert con;
    
    //        /*[JPO 02/13] create con2
    //        Contact con2 = new Contact();
    //        con2 =  TestDataFactory.createContact(1)[0];
    //        con2.AccountId = acct2.Id;
    //        con2.Address__c = address.Id;            
    //        con2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //        con2.Recipient_Indicator__c = true;
    //        insert con2; */
    
    //        //create order
    //        Order__c order = TestDataFactory.createOrder(1)[0];
    //        order.Account__c = acct.Id;
    //        order.Recipient_Contact__c = con.Id;
    //        order.Informed_Customer__c = True;
    //        //order.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
    //        insert order;
    
    //        /*[JPO 02/13] create order2 for subrRec's orderline item 1
    //        Order__c order2 = TestDataFactory.createOrder(1)[0];
    //        order2.Account__c = acct2.Id;
    //        order2.Recipient_Contact__c = con2.Id;
    //        order2.Informed_Customer__c = True;
    //        insert order2; //error? FIELD_FILTER_VALIDATION_EXCEPTION, Value does not exist or does not match filter criteria.: [Recipient_Contact__c]
    //        */
    //        //create case
    //        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
    //        cas.Order__c = order.Id;
    //        insert cas;
    
    //        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
    //        orderline.Order__c = order.Id;
    //        //orderline.End_Date__c = date.newInstance(2014, 12, 2);
    //        orderline.End_Date__c = date.today()+30;
    //        orderline.Main_Package_ID__c = pack.Id;
    //        orderline.Term_Length__c = 1;
    //        orderline.Main_Package_Period__c = 0;
    //        orderline.Earliest_Start_Date__c = date.today();
    //        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
    //        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
    //        orderline.Terminating_Reason__c = 'Others';
    //        orderline.Amount_To_Refund__c = 0;
    //        orderline.Admin_Charge__c = 0;
    //        orderline.Fee_Waiver__c = TRUE;
    //        orderline.Fee_Override__c = TRUE;
    //        orderline.Override_Reason__c = 'TEST';
    //        orderline.Suppress_Notification_Stop__c = TRUE;
    //        orderline.Main_Package_Type__c = 'Base';
    //        orderline.Start_Date__c = date.today()+5;
    //        insert orderline;
    
    
    
    //         //create subscription vendor
    //        Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
    //        //SubVend.Name = 'Test Subscription Vendor';
    //        insert SubVend;
    //        System.debug('***wendy : inserted tmp');
    
    //        Case caseRec = new Case();
    //        caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
    //        caseRec.Status = 'Pending';
    //        caseRec.Sub_Status__c = 'Wating for Vendor Assignment';               
    //        insert caseRec;   
    //        System.debug('***wendy : caseRec');  
    
    //        Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
    //       zua.Zuora__Account__c = acct.Id;
    //       zua.Zuora__DefaultPaymentMethod__c = 'Other';
    //       //zua.Zuora__PaymentMethodType__c = 'Paypal';
    //       insert zua; 
    //       System.debug('***wendy : inserted zua');
    
    
    //        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
    //        subRec = TestDataFactory.createSubscription(1)[0];
    //        subRec.Zuora__Account__c = acct.Id;
    //        //subRec.Zuora__Account__c = zua.id;
    //        subRec.Order_Number__c = order.Id;
    //        subRec.Subscriber_Contact__c = con.Id;
    //        //subRec.Recipient_Contact__c = con.Id;
    //        subRec.Main_Package_1__c = pack.id;
    //        subRec.Zuora__Status__c = GlobalVariableClass.STATUS_ACTIVE;
    //        //subRec.Zuora__Status__c = 'Cancelled'; [JPO 02/13] commented out
    //        subRec.Suppress_Vendor_Start_Notice__c = 'false';
    //        subRec.Supressed_Acknowledgement_Letter__c = 'false';
    //        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        subRec.Urgent__c = 'false';
    //        subRec.Vendor_Conversion__c = 'false';
    //        subRec.Charity__c = 'false';
    //        subRec.Order_Line_Item_Number__c = orderline.Id;
    //        subrec.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
    //        subRec.Vendor_1__c = acctVendor.id;
    //        subRec.Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
    //        subRec.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; // WAK 04/13/16 added
    //        //sub.Zuora__Status__c == GlobalVariableClass.STATUS_ACTIVE
    //        //subRec.Order_Number_1__c = order2.id; //[JPO 02/13] added 
    
    //        test.startTest(); //[JPO 02/12/2015] Moved startTest before inserting subRec  
    //        insert subRec;      
    
    //        //WAK 04/15/2016
    //        Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = con.id);        
    //        insert asiaOneRecord;
    //        System.debug('***wendy : inserted asiaOneRecord');
    
    //        Service_Access_Flag__c saf = new Service_Access_Flag__c();
    //        saf.Name = 'test name';
    //        insert saf;
    //        System.debug('***wendy : inserted saf');
    
    //        Asia1_Subscription__c tmp = new Asia1_Subscription__c();
    //        tmp.Asia1__c = asiaOneRecord.id;
    //        tmp.Order_Line_Item__c = orderline.id;
    //        tmp.Service_Access_Flag__c = saf.id;
    //        tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED;
    //        tmp.Subscription__c = subRec.Id;
    //        insert tmp; 
    //        System.debug('***wendy : inserted tmp');
    //        System.debug('***wendy : inserted subRec');
    //        //[JPO 02/12/2015] Adding List
    //        //List<Zuora__Subscription__c> testsubscriptionList = TestDataFactory.createSubscription(1);
    //        //testsubscriptionList.add(subrec);
    
    //        //insert testsubscriptionList;
    
    //         removing this causing SOQL limit
    //        Zuora__Subscription__c subRec2 = new Zuora__Subscription__c();
    //        subRec2 = TestDataFactory.createSubscription(1)[0];
    //        subRec2.Zuora__Account__c = acct.Id;
    //        subRec2.Order_Number__c = order.Id;
    //        subRec2.Subscriber_Contact__c = con.Id;
    //        subRec2.Recipient_Contact__c = con.Id;
    //        subRec2.Main_Package_1__c = pack.id;
    //        subRec2.Suppress_Vendor_Start_Notice__c = 'false';
    //        subRec2.Supressed_Acknowledgement_Letter__c = 'false';
    //        subRec2.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        subRec2.Urgent__c = 'false';
    //        subRec2.Vendor_Conversion__c = 'false';
    //        subRec2.Charity__c = 'false';
    //        //subRec2.Zuora__Status__c = NULL;
    //        subRec2.Order_Line_Item_Number__c = orderline.Id;
    //        insert subRec2;
    
    //        Zuora__Subscription__c subRec3 = new Zuora__Subscription__c();
    //        subRec3 = TestDataFactory.createSubscription(1)[0];
    //        subRec3.Zuora__Account__c = acct.Id;
    //        subRec3.Order_Number__c = order.Id;
    //        subRec3.Subscriber_Contact__c = con.Id;
    //        subRec3.Recipient_Contact__c = con.Id;
    //        subRec3.Main_Package_1__c = pack.id;
    //        subRec3.Suppress_Vendor_Start_Notice__c = 'false';
    //        subRec3.Supressed_Acknowledgement_Letter__c = 'false';
    //        subRec3.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        subRec3.Urgent__c = 'false';
    //        subRec3.Vendor_Conversion__c = 'false';
    //        subRec3.Charity__c = 'false';
    //        subRec3.Order_Line_Item_Number__c = orderline.Id;
    //        insert subRec3;
    
    
    //        Case_Subscription__c  caseSub = new Case_Subscription__c();
    //        caseSub.Account__c = acct.Id;
    //        caseSub.Address__c = address.Id;
    //        caseSub.Case__c = caseRec.Id;
    //        caseSub.Subscription__c = subRec.Id;
    //        insert caseSub;    
    
    //        System.assertEquals(acct.Id, caseSub.Account__c);
    
    
    //        /*
    //        try{    
    //            subRec.Vendor_1__c = NULL;
    //            update subRec;
    //            //subRec2.Vendor_1__c = NULL;
    //            //update subRec2;   
    //        }   
    //        catch (Exception e){
    //            Boolean expectedExceptionThrown =  e.getMessage().contains('Vendor cannot be empty.') ? true : false;
    //            //System.AssertEquals(expectedExceptionThrown, true);
    //        }
    //        */
    
    //        subRec.Zuora__Status__c = 'Cancelled'; // [JPO 2/13] Made 'Active' From ''
    //        subRec.Zuora__SubscriptionStartDate__c = Date.today().addMonths(-Integer.valueOf(subRec.Term_Length__c));
    //        subRec.Zuora__SubscriptionEndDate__c = Date.today();
    //        //update subRec;
    //        //subRec2.Zuora__Status__c = 'Active';
    //        //update subRec2;
    //        //subRec3.Zuora__Status__c = 'Active';
    //        //update subRec3;
    
    //        //update            
    //        SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = false;
    //        SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = false;   
    //        //subRec.Vendor_1__c = acctVendor.Id; 
    //        //subRec.Vendor__c = acctVendor.Id;
    //        // System.assertEquals(null, acctVendor.Id);    
    //        subRec.Vendor__c = acctVendor.Id+'';
    //        update subRec; // venor cdannot be empty error
    
    
    //        SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
    //        handler.runBeforeUpdateTrigger();
    //        handler.runAfterUpdateTrigger();
    //        //TEST: if 
    
    //        //handler.afterInsert(subRec);
    
    //    test.stoptest();    
    //    }
    //}
    
    //static testMethod void testSingleInsertUpdate3(){        
    //    User u = createUser();
    
    //    //The test will run as the user created.
    //    System.runAs(u) {
    //        setUpTestData();
    
    //        Zuora__Subscription__c sobj = new Zuora__Subscription__c();
    //        Zuora__Subscription__c sobj2 = new Zuora__Subscription__c();        
    
    //        SubscriptionTriggerHandler subhandler = new SubscriptionTriggerHandler();
    //        subhandler.beforeDelete(sobj);
    
    //        SubscriptionTriggerHandler subhandler2 = new SubscriptionTriggerHandler();
    //        subhandler.afterDelete(sobj2);
    //        SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = FALSE;
    //        SubscriptionTriggerHandler.isAfterDeleteTriggerCalled = FALSE;
    
    //        Singpost_Address__c postal = new Singpost_Address__c();
    //        postal = TestDataFactory.createSingpostAddress(1)[0];
    //        insert postal;
    
    //        Address__c address = new Address__c();
    //        address = TestDataFactory.createAddress(1)[0];
    //        address.Postal_Code__c = postal.Id;
    //        insert address;
    
    //        Package__c pack = new Package__c();
    //        pack = TestDataFactory.createPackage(1)[0];
    //        insert pack;
    
    //        Account acct = new Account();
    //        acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //        acct.NRIC__c = 'T1234567R';
    //        insert acct;
    
    //        Account acctVendor = new Account();
    //        acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
    //        //acctVendor.Ven
    //        insert acctVendor;
    
    //        Account acct2 = new Account();
    //        acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //        acct2.NRIC__c = 'T1234567R';
    //        insert acct2;
    
    //        Contact con = new Contact();
    //        con = TestDataFactory.createContact(1)[0];
    //        con.AccountId = acct.Id;
    //        con.Address__c = address.Id;
    //        // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
    //        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
    //        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //        con.Recipient_Indicator__c = true;
    //        // END : CCB 002 12/2/2014
    //        insert con;
    
    //        /*[JPO 02/13] create con2
    //        Contact con2 = new Contact();
    //        con2 =  TestDataFactory.createContact(1)[0];
    //        con2.AccountId = acct2.Id;
    //        con2.Address__c = address.Id;            
    //        con2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //        con2.Recipient_Indicator__c = true;
    //        insert con2; */
    
    //        //create order
    //        Order__c order = TestDataFactory.createOrder(1)[0];
    //        order.Account__c = acct.Id;
    //        order.Recipient_Contact__c = con.Id;
    //        order.Informed_Customer__c = True;
    //        insert order;
    
    
    //        //create case
    //        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
    //        //cas.Order__c = order.Id;
    //        cas.Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
    //        insert cas;
    
    //        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
    //        orderline.Order__c = order.Id;
    //        //orderline.End_Date__c = date.newInstance(2014, 12, 2);
    //        orderline.End_Date__c = date.today()+30;
    //        orderline.Main_Package_ID__c = pack.Id;
    //        orderline.Term_Length__c = 1;
    //        orderline.Main_Package_Period__c = 0;
    //        orderline.Earliest_Start_Date__c = date.today();
    //        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
    //        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
    //        orderline.Terminating_Reason__c = 'Others';
    //        orderline.Amount_To_Refund__c = 0;
    //        orderline.Admin_Charge__c = 0;
    //        orderline.Fee_Waiver__c = TRUE;
    //        orderline.Fee_Override__c = TRUE;
    //        orderline.Override_Reason__c = 'TEST';
    //        orderline.Suppress_Notification_Stop__c = TRUE;
    //        orderline.Main_Package_Type__c = 'Base';
    //        orderline.Start_Date__c = date.today()+5;
    //        orderline.Delivered_By__c = GlobalVariableClass.VENDOR;
    //        orderline.Vendor_Mailing_Agent__c = null;
    //        insert orderline;
    
    //        //WAK 04/15/2016
    //        Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = con.id);        
    //        insert asiaOneRecord;
    //        System.debug('***wendy : inserted asiaOneRecord');
    
    //        Service_Access_Flag__c saf = new Service_Access_Flag__c();
    //        saf.Name = 'test name';
    //        insert saf;
    //        System.debug('***wendy : inserted saf');
    
    //        Asia1_Subscription__c tmp = new Asia1_Subscription__c();
    //        tmp.Asia1__c = asiaOneRecord.id;
    //        tmp.Order_Line_Item__c = orderline.id;
    //        tmp.Service_Access_Flag__c = saf.id;
    //        tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
    //        insert tmp; 
    //        System.debug('***wendy : inserted tmp');
    
    //         //create subscription vendor
    //        Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
    //        //SubVend.Name = 'Test Subscription Vendor';
    //        insert SubVend;
    //        System.debug('***wendy : inserted tmp');
    
    //        Case caseRec = new Case();
    //        caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
    //        caseRec.Status = 'Pending';
    //        caseRec.Sub_Status__c = 'Wating for Vendor Assignment';   
    //        //caseRec.Order__c = order.Id;  
    //        caseRec.Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;           
    //        insert caseRec;   
    //        System.debug('***wendy : caseRec');  
    
    //        Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
    //        zua.Zuora__Account__c = acct.Id;
    //        zua.Zuora__DefaultPaymentMethod__c = 'Other';
    //        //zua.Zuora__PaymentMethodType__c = 'Paypal';
    //        insert zua; 
    //        System.debug('***wendy : inserted zua');
    
    //        Zuora__Subscription__c relSub = new Zuora__Subscription__c();
    //        relSub = TestDataFactory.createSubscription(1)[0];
    //        relSub.Zuora__Account__c = acct.Id;
    //        relSub.Order_Number__c = order.Id;
    //        relSub.Subscriber_Contact__c = con.Id;
    //        relSub.Recipient_Contact__c = con.Id;
    //        relSub.Main_Package_1__c = pack.id;
    //        relSub.Zuora__Status__c = 'Active';
    //        //subRec.Zuora__Status__c = 'Cancelled'; [JPO 02/13] commented out
    //        relSub.Suppress_Vendor_Start_Notice__c = 'false';
    //        relSub.Supressed_Acknowledgement_Letter__c = 'false';
    //        relSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        relSub.Urgent__c = 'false';
    //        relSub.Vendor_Conversion__c = 'false';
    //        relSub.Charity__c = 'false';
    //        relSub.Order_Line_Item_Number__c = orderline.Id;
    //        relSub.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
    //        relSub.Vendor_1__c = acctVendor.id;
    //        relSub.Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
    //        //subRec.Order_Number_1__c = order2.id; //[JPO 02/13] added 
    //        relSub.Zuora__Zuora_Id__c = '111111';
    //        insert relSub;
    
    //        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
    //        subRec = TestDataFactory.createSubscription(1)[0];
    //        subRec.Zuora__Zuora_Id__c = '111111';
    //        subRec.Zuora__Account__c = acct.Id;
    //        subRec.Order_Number__c = order.Id;
    //        subRec.Subscriber_Contact__c = con.Id;
    //        subRec.Recipient_Contact__c = con.Id;
    //        subRec.Main_Package_1__c = pack.id;
    //        subRec.Zuora__Status__c = GlobalVariableClass.STATUS_ACTIVE;
    //        //subRec.Zuora__Status__c = 'Cancelled'; [JPO 02/13] commented out
    //        subRec.Suppress_Vendor_Start_Notice__c = 'false';
    //        subRec.Supressed_Acknowledgement_Letter__c = 'false';
    //        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        subRec.Urgent__c = 'false';
    //        subRec.Vendor_Conversion__c = 'false';
    //        subRec.Charity__c = 'false';
    //        subRec.Order_Line_Item_Number__c = orderline.Id;
    //        subrec.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
    //        subRec.Vendor_1__c = acctVendor.id;
    //        subRec.Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
    //        //subRec.Order_Number_1__c = order2.id; //[JPO 02/13] added 
    //        subRec.Vendor__c = acctVendor.Id+'';
    //        subRec.Zuora__AutoRenew__c = true;
    //        subRec.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    //        subRec.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
    //        subRec.Related_Subscription__c = relSub.Id;
    
    //        test.startTest(); //[JPO 02/12/2015] Moved startTest before inserting subRec  
    
    //        insert subRec;      
    //        System.debug('***wendy : inserted subRec');
    //        //[JPO 02/12/2015] Adding List
    //        //List<Zuora__Subscription__c> testsubscriptionList = TestDataFactory.createSubscription(1);
    //        //testsubscriptionList.add(subrec);
    
    //        //insert testsubscriptionList;
    
    
    //        Case_Subscription__c  caseSub = new Case_Subscription__c();
    //        caseSub.Account__c = acct.Id;
    //        caseSub.Address__c = address.Id;
    //        caseSub.Case__c = caseRec.Id;
    //        caseSub.Subscription__c = subRec.Id;
    //        //cas.Order__c = order.Id;
    //        cas.Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
    //        insert caseSub;    
    
    //        System.assertEquals(acct.Id, caseSub.Account__c);
    
    //        subRec.Zuora__Status__c = 'Cancelled'; // [JPO 2/13] Made 'Active' From ''
    //        subRec.Zuora__SubscriptionStartDate__c = Date.today().addMonths(-Integer.valueOf(subRec.Term_Length__c));
    //        subRec.Zuora__SubscriptionEndDate__c = Date.today();
    
    //        SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = false;
    //        SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = false;   
    //        //subRec.Vendor_1__c = acctVendor.Id; 
    //        //subRec.Vendor__c = acctVendor.Id;
    //        // System.assertEquals(null, acctVendor.Id);    
    //        subRec.Vendor__c = acctVendor.Id+'';
    //        update subRec; // venor cdannot be empty error
    
    
    //        SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
    //        handler.runBeforeUpdateTrigger();
    //        handler.runAfterUpdateTrigger();
    //        //handler.setVendorSUbscriptionEndDate(subRec);
    //        //handler.updateDelSubsActiveFlag();
    //        //TEST: if 
    
    //    test.stoptest();    
    //    }
    //}
    //static testMethod void testSingleInsertUpdate4(){        
    //    User usr = createUser();
    //    //The test will run as the user created.
    //    System.runAs(usr) {
    //        setUpTestData();
    
    //        Zuora__Subscription__c sobj = new Zuora__Subscription__c();
    //        Zuora__Subscription__c sobj2 = new Zuora__Subscription__c();        
    
    //        SubscriptionTriggerHandler subhandler = new SubscriptionTriggerHandler();
    //        subhandler.beforeDelete(sobj);
    
    //        SubscriptionTriggerHandler subhandler2 = new SubscriptionTriggerHandler();
    //        subhandler.afterDelete(sobj2);
    //        SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = FALSE;
    //        SubscriptionTriggerHandler.isAfterDeleteTriggerCalled = FALSE;
    
    //        Singpost_Address__c postal = new Singpost_Address__c();
    //        postal = TestDataFactory.createSingpostAddress(1)[0];
    //        insert postal;
    
    //        Address__c address = new Address__c();
    //        address = TestDataFactory.createAddress(1)[0];
    //        address.Postal_Code__c = postal.Id;
    //        insert address;
    
    //        Package__c pack = new Package__c();
    //        pack = TestDataFactory.createPackage(1)[0];
    //        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BUNDLE;
    //        insert pack;
    
    //        Account acct = new Account();
    //        acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //        acct.NRIC__c = 'T1234567R';
    //        insert acct;
    
    //        Account acctVendor = new Account();
    //        acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
    //        //acctVendor.Ven
    //        insert acctVendor;
    
    //        Account acct2 = new Account();
    //        acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //        acct2.NRIC__c = 'T1234567R';
    //        insert acct2;
    
    //        Contact con = new Contact();
    //        con = TestDataFactory.createContact(1)[0];
    //        con.AccountId = acct.Id;
    //        con.Address__c = address.Id;
    //        // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
    //        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
    //        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //        con.Recipient_Indicator__c = true;
    //        // END : CCB 002 12/2/2014
    //        insert con;
    
    //        /*[JPO 02/13] create con2
    //        Contact con2 = new Contact();
    //        con2 =  TestDataFactory.createContact(1)[0];
    //        con2.AccountId = acct2.Id;
    //        con2.Address__c = address.Id;            
    //        con2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //        con2.Recipient_Indicator__c = true;
    //        insert con2; */
    
    //        //create order
    //        Order__c order = TestDataFactory.createOrder(1)[0];
    //        order.Account__c = acct.Id;
    //        order.Recipient_Contact__c = con.Id;
    //        order.Informed_Customer__c = True;
    //        insert order;
    
    
    //        //create case
    //        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
    //        //cas.Order__c = order.Id;
    //        cas.Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
    //        insert cas;
    
    //        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
    //        orderline.Order__c = order.Id;
    //        //orderline.End_Date__c = date.newInstance(2014, 12, 2);
    //        orderline.End_Date__c = date.today()+30;
    //        orderline.Main_Package_ID__c = pack.Id;
    //        orderline.Term_Length__c = 1;
    //        orderline.Main_Package_Period__c = 0;
    //        orderline.Earliest_Start_Date__c = date.today();
    //        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
    //        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
    //        orderline.Terminating_Reason__c = 'Others';
    //        orderline.Amount_To_Refund__c = 0;
    //        orderline.Admin_Charge__c = 0;
    //        orderline.Fee_Waiver__c = TRUE;
    //        orderline.Fee_Override__c = TRUE;
    //        orderline.Override_Reason__c = 'TEST';
    //        orderline.Suppress_Notification_Stop__c = TRUE;
    //        orderline.Main_Package_Type__c = 'Base';
    //        orderline.Start_Date__c = date.today()+5;
    //        orderline.Delivered_By__c = GlobalVariableClass.VENDOR;
    //        orderline.Vendor_Mailing_Agent__c = null;
    //        insert orderline;
    
    //        //WAK 04/15/2016
    //        Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = con.id);        
    //        insert asiaOneRecord;
    //        System.debug('***wendy : inserted asiaOneRecord');
    
    //        Service_Access_Flag__c saf = new Service_Access_Flag__c();
    //        saf.Name = 'test name';
    //        insert saf;
    //        System.debug('***wendy : inserted saf');
    
    //        Asia1_Subscription__c tmp = new Asia1_Subscription__c();
    //        tmp.Asia1__c = asiaOneRecord.id;
    //        tmp.Order_Line_Item__c = orderline.id;
    //        tmp.Service_Access_Flag__c = saf.id;
    //        tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
    //        insert tmp; 
    //        System.debug('***wendy : inserted tmp');
    
    //         //create subscription vendor
    //        Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
    //        //SubVend.Name = 'Test Subscription Vendor';
    //        insert SubVend;
    //        System.debug('***wendy : inserted tmp');
    
    //        Case caseRec = new Case();
    //        caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
    //        caseRec.Status = 'Pending';
    //        caseRec.Sub_Status__c = 'Wating for Vendor Assignment';   
    //        //caseRec.Order__c = order.Id;  
    //        caseRec.Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;           
    //        insert caseRec;   
    //        System.debug('***wendy : caseRec');  
    
    //        Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
    //        zua.Zuora__Account__c = acct.Id;
    //        zua.Zuora__DefaultPaymentMethod__c = 'Other';
    //        //zua.Zuora__PaymentMethodType__c = 'Paypal';
    //        insert zua; 
    //        System.debug('***wendy : inserted zua');
    
    //        Zuora__Subscription__c relSub = new Zuora__Subscription__c();
    //        relSub = TestDataFactory.createSubscription(1)[0];
    //        relSub.Zuora__AutoRenew__c = true;
    //        relSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
    //        relSub.Zuora__Account__c = acct.Id;
    //        relSub.Order_Number__c = order.Id;
    //        relSub.Subscriber_Contact__c = con.Id;
    //        relSub.Recipient_Contact__c = con.Id;
    //        relSub.Main_Package_1__c = pack.id;
    //        relSub.Zuora__Status__c = 'Active';
    //        relSub.Suppress_Vendor_Start_Notice__c = 'false';
    //        relSub.Supressed_Acknowledgement_Letter__c = 'false';
    //        relSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        relSub.Urgent__c = 'false';
    //        relSub.Vendor_Conversion__c = 'false';
    //        relSub.Charity__c = 'false';
    //        relSub.Order_Line_Item_Number__c = orderline.Id;
    //        relSub.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
    //        relSub.Vendor_1__c = acctVendor.id;
    //        relSub.Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
    //        relSub.Zuora__Zuora_Id__c = '111111';
    //        insert relSub;
    //        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
    //        subRec = TestDataFactory.createSubscription(1)[0];
    //        subRec.Zuora__Zuora_Id__c = relSub.Id;
    //        subRec.Zuora__Account__c = acct.Id;        
    //        subRec.Order_Number__c = order.Id;
    //        subRec.Subscriber_Contact__c = con.Id;
    //        //trial subRec.Recipient_Contact__c = con.Id;
    //        subRec.Subscription_Charge__c = null;
    //        subRec.Main_Package_1__c = pack.id;
    //        subRec.Zuora__Status__c = GlobalVariableClass.STATUS_ACTIVE;
    //        subRec.Suppress_Vendor_Start_Notice__c = 'false';
    //        subRec.Supressed_Acknowledgement_Letter__c = 'false';
    //        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        subRec.Urgent__c = 'false';
    //        subRec.Vendor_Conversion__c = 'false';
    //        subRec.Charity__c = 'false';
    //        subRec.Order_Line_Item_Number__c = orderline.Id;
    //        subrec.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
    //        subRec.Vendor_1__c = acctVendor.id;
    //        subRec.Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
    //        //subRec.Order_Number_1__c = order2.id; //[JPO 02/13] added 
    //        subRec.Vendor__c = acctVendor.Id+'';
    //        subRec.Zuora__AutoRenew__c = true;
    //        subRec.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
    //        subRec.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
    //        subRec.Related_Subscription__c = relSub.Id;
    //        subRec.Payment_Mode__c = 'Other';
    //        subRec.Other_PaymentMethod__c = 'Freelist';
    //        test.startTest(); //[JPO 02/12/2015] Moved startTest before inserting subRec  
    
    //        insert subRec;      
    //        System.debug('***wendy : inserted subRec');
    //        //[JPO 02/12/2015] Adding List
    //        //List<Zuora__Subscription__c> testsubscriptionList = TestDataFactory.createSubscription(1);
    //        //testsubscriptionList.add(subrec);
    
    //        //insert testsubscriptionList;
    
    
    //        Case_Subscription__c  caseSub = new Case_Subscription__c();
    //        caseSub.Account__c = acct.Id;
    //        caseSub.Address__c = address.Id;
    //        caseSub.Case__c = caseRec.Id;
    //        caseSub.Subscription__c = subRec.Id;
    //        //cas.Order__c = order.Id;
    //        cas.Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
    //        insert caseSub;    
    
    //        System.assertEquals(acct.Id, caseSub.Account__c);
    
    //        subRec.Zuora__Status__c = 'Cancelled'; // [JPO 2/13] Made 'Active' From ''
    //        subRec.Zuora__SubscriptionStartDate__c = Date.today().addMonths(-Integer.valueOf(subRec.Term_Length__c));
    //        subRec.Zuora__SubscriptionEndDate__c = Date.today();
    
    //        SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = false;
    //        SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = false;   
    //        //subRec.Vendor_1__c = acctVendor.Id; 
    //        //subRec.Vendor__c = acctVendor.Id;
    //        // System.assertEquals(null, acctVendor.Id);    
    //        subRec.Vendor__c = acctVendor.Id+'';
    //        update subRec; // venor cdannot be empty error
    
    
    //        SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
    //        handler.runBeforeUpdateTrigger();
    //        handler.runAfterUpdateTrigger();
    //        //handler.setVendorSUbscriptionEndDate(subRec);
    //        //handler.updateDelSubsActiveFlag();
    //        //TEST: if 
    
    //    test.stoptest();    
    //    }
    //}
    //static testMethod void testSingleInsertUpdate5(){
    
    //    User usr = createUser();
    
    //    //The test will run as the user created.
    //    System.runAs(usr) {
    //        setUpTestData();
    
    //        Singpost_Address__c postal = new Singpost_Address__c();
    //        postal = TestDataFactory.createSingpostAddress(1)[0];
    //        insert postal;
    
    //        Address__c address = new Address__c();
    //        address = TestDataFactory.createAddress(1)[0];
    //        address.Postal_Code__c = postal.Id;
    //        insert address;
    
    
    //        Package__c pack = new Package__c();
    //        pack = TestDataFactory.createPackage(1)[0];
    //        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BUNDLE;
    //        insert pack;
    
    //        Account acct = new Account();
    //        acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //        acct.NRIC__c = 'T1234567R';
    //        insert acct;
    
    //        Account acctVendor = new Account();
    //        acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
    //        insert acctVendor;
    
    //        Account acct2 = new Account();
    //        acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //        acct2.NRIC__c = 'T1234567R';
    //        insert acct2;
    
    //        Contact con = new Contact();
    //        con = TestDataFactory.createContact(1)[0];
    //        con.AccountId = acct.Id;
    //        con.Address__c = address.Id;
    //        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //        con.Recipient_Indicator__c = true;
    //        insert con;
    
    //        //create order
    //        Order__c order = TestDataFactory.createOrder(1)[0];
    //        order.Account__c = acct.Id;
    //        order.Recipient_Contact__c = con.Id;
    //        order.Informed_Customer__c = True;
    //        insert order;
    
    //        //create case
    //        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
    //        cas.Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
    
    //        insert cas;
    
    //        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
    //        orderline.Order__c = order.Id;
    //        orderline.End_Date__c = date.today()+30;
    //        orderline.Main_Package_ID__c = pack.Id;
    //        orderline.Term_Length__c = 1;
    //        orderline.Main_Package_Period__c = 0;
    //        orderline.Earliest_Start_Date__c = date.today();
    //        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
    //        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
    //        orderline.Terminating_Reason__c = 'Others';
    //        orderline.Amount_To_Refund__c = 0;
    //        orderline.Admin_Charge__c = 0;
    //        orderline.Fee_Waiver__c = TRUE;
    //        orderline.Fee_Override__c = TRUE;
    //        orderline.Override_Reason__c = 'TEST';
    //        orderline.Suppress_Notification_Stop__c = TRUE;
    //        orderline.Main_Package_Type__c = 'Base';
    //        orderline.Start_Date__c = date.today()+5;
    //        orderline.Delivered_By__c = GlobalVariableClass.VENDOR;
    //        orderline.Vendor_Mailing_Agent__c = null;
    //        orderline.Subscription_Name__c ='test name';
    
    //        insert orderline;
    
    //        //WAK 04/15/2016
    //        Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = con.id);        
    //        insert asiaOneRecord;
    //        System.debug('***wendy : inserted asiaOneRecord');
    
    //        Service_Access_Flag__c saf = new Service_Access_Flag__c();
    //        saf.Name = 'test name';
    //        insert saf;
    //        System.debug('***wendy : inserted saf');
    
    //        Asia1_Subscription__c tmp = new Asia1_Subscription__c();
    //        tmp.Asia1__c = asiaOneRecord.id;
    //        tmp.Order_Line_Item__c = orderline.id;
    //        tmp.Service_Access_Flag__c = saf.id;
    //        tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
    //        insert tmp; 
    //        System.debug('***wendy : inserted tmp');
    
    //        //create subscription vendor
    //        Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
    //        insert SubVend;
    //        System.debug('***wendy : inserted tmp');
    
    
    
    //        Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
    //        zua.Zuora__Account__c = acct.Id;
    //        zua.Zuora__DefaultPaymentMethod__c = 'Other';
    //        insert zua; 
    //        System.debug('***wendy : inserted zua');
    
    
    //        Zuora__CustomerAccount__c zua2 =  TestDataFactory.createBillingAccount(1)[0];
    //        zua2.Zuora__Account__c = acct.Id;
    //        zua2.Zuora__DefaultPaymentMethod__c = 'Other';
    //        insert zua2; 
    //        System.debug('***wendy : inserted zua2');
    
    //        Zuora__Subscription__c relSub = new Zuora__Subscription__c();
    //        relSub = TestDataFactory.createSubscription(1)[0];
    //        relSub.Zuora__AutoRenew__c = true;
    //        relSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
    //        relSub.Zuora__Account__c = acct.Id;
    //        relSub.Order_Number__c = order.Id;
    //        relSub.Subscriber_Contact__c = con.Id;
    //        relSub.Recipient_Contact__c = con.Id;
    //        relSub.Main_Package_1__c = pack.id;
    //        relSub.Zuora__Status__c = 'Active';
    //        relSub.Suppress_Vendor_Start_Notice__c = 'false';
    //        relSub.Supressed_Acknowledgement_Letter__c = 'false';
    //        relSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        relSub.Urgent__c = 'false';
    //        relSub.Vendor_Conversion__c = 'false';
    //        relSub.Charity__c = 'false';
    //        relSub.Order_Line_Item_Number__c = orderline.Id;
    //        relSub.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
    //        relSub.Vendor_1__c = acctVendor.id;
    //        relSub.Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
    //        relSub.Zuora__Zuora_Id__c = '111111';
    //        insert relSub;
    
    //        test.startTest(); 
    //        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
    //        subRec = TestDataFactory.createSubscription(1)[0];
    //        subRec.Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    //        subRec.Subscription_Type__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    //        subRec.Zuora__Zuora_Id__c = relSub.Id;
    //        subRec.Recipient_Contact__c = null;
    //        subRec.Name = 'test name';
    //        subRec.Zuora__Account__c = acct.Id;        
    //        subRec.Order_Number__c = order.Id;
    //        subRec.Subscriber_Contact__c = con.Id;
    //        subRec.Vendor_Subscription_To_Convert_1__c = SubVend.Id;
    //        subRec.Subscription_Charge__c = null;
    //        subRec.Main_Package_1__c = pack.id;
    //        subRec.Zuora__Status__c = GlobalVariableClass.STATUS_ACTIVE;
    //        subRec.Suppress_Vendor_Start_Notice__c = 'false';
    //        subRec.Supressed_Acknowledgement_Letter__c = 'false';
    //        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //        subRec.Urgent__c = 'false';
    //        subRec.Vendor_Conversion__c = 'false';
    //        subRec.Charity__c = 'false';
    //        subRec.Order_Line_Item_Number__c = orderline.Id;
    //        subrec.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
    //        subRec.Vendor_1__c = acctVendor.id;
    //        subRec.Zuora__CustomerAccount__c = zua.id;
    //        //subRec.Order_Number_1__c = order2.id;
    //        subRec.Vendor__c = acctVendor.Id+'';
    //        subRec.Zuora__AutoRenew__c = true;
    //        subRec.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
    //        subRec.Related_Subscription__c = relSub.Id;
    //        subRec.Payment_Mode__c = 'Other';
    //        subRec.Other_PaymentMethod__c = 'Freelist';
    //        subRec.Order_Line_Item_Number_1__c = orderline.Id;
    //        subRec.Zuora__Version__c = 1;
    
    //        insert subRec;      
    //        System.debug('***wendy : inserted subRec');
    //        System.debug('***subRec.Subscription_Type_1__c-----------------' + subRec.Subscription_Type_1__c);
    //        System.debug('***subRec.Subscription_Type__c -----------------' + subRec.Subscription_Type__c );
    //        System.debug('***subRec.Zuora__Status__c -----------------' + subRec.Zuora__Status__c );
    
    //        Id caseRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Stop Subscription').getRecordTypeId();
    //        Case caseRec = new Case();
    //        caseRec.RecordTypeId = caseRT; //ConstantsSLB.getKeyId('Case_Start Sub');
    //        caseRec.Status = 'Pending';
    //        caseRec.Sub_Status__c = 'Wating for Vendor Assignment';   
    //        caseRec.Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;   
    //        //caseRec.RecordType.DeveloperName = caseRTName;
    //        caseRec.Subscription_Name__c = subRec.Id;
    //        caseRec.Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
    //        caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
    //        caseRec.AccountId = acct.Id;
    //        insert caseRec;   
    //        System.debug('***wendy : caseRec');  
    
    //        Case_Subscription__c  caseSub = new Case_Subscription__c();
    //        caseSub.Account__c = acct.Id;
    //        caseSub.Address__c = address.Id;
    //        caseSub.Case__c = caseRec.Id;
    //        caseSub.Subscription__c = subRec.Id;
    //        insert caseSub;    
    //        System.assertEquals(acct.Id, caseSub.Account__c);
    
    //        subRec.Zuora__Status__c = 'Cancelled'; // [JPO 2/13] Made 'Active' From ''
    //        subRec.Zuora__TermSettingType__c = 'TERMED';
    //        subRec.Zuora__SubscriptionEndDate__c = Date.today();
    //        subRec.Zuora__SubscriptionStartDate__c = Date.today();
    //        subRec.Term_Length__c = 2;
    //        //subRec.Zuora__CustomerAccount__c = zua2.Id;
    //        update subRec;
    
    //        subRec.Zuora__Status__c = 'Cancelled'; // [JPO 2/13] Made 'Active' From ''
    //        subRec.Zuora__TermSettingType__c = 'EVERGREEN';
    //        subRec.Zuora__SubscriptionEndDate__c = Date.today()+1;
    //        subRec.Zuora__SubscriptionStartDate__c = Date.today();
    //        subRec.Term_Length__c = 2;
    //        subRec.Zuora__Version__c = 2;
    //        subRec.Order_Line_Item_Number_1__c = orderline.Id;
    //        subRec.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
    //        update subRec;
    //        test.stoptest(); 
    
    //    }
    //}
    
    static testMethod void testMethod3() {
        User usr = createUser();
    
        //The test will run as the user created.
        System.runAs(usr) {
            //setUpTestData();
            List<Billing_Batch__c> billBatches = new List<Billing_Batch__c>();
            billBatches = CustomSettingsDataFactory.createBillingBatch();
            insert billBatches;
            Singpost_Address__c postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
    
            Address__c address = new Address__c();
            address = TestDataFactory.createAddress(1)[0];
            address.Postal_Code__c = postal.Id;
            insert address;
    
    
            packge = TestDataFactory.createPackage(1)[0];
            packge.Billing_Type__c = 'Full Prepaid';
            packge.Package_Type__c = 'Grace Period';
            packge.Subscription_Period__c = '1';
            packge.Package_Code__c = 'STSU';
            packge.Product_Family_Current_Package__c = 'test';
            insert packge;
            
            //Setup zqu__ZProduct__c records
            zProducts = TestDataFactory.createZProduct(1)[0];
            zProducts.ProductSubType__c = 'Magazine';
            zProducts.zqu__ZuoraId__c = 'Test';
            insert zProducts ;
            
            //Setup zqu__ProductRatePlan__c records
            prodRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
            prodRatePlan.zqu__ZProduct__c = zProducts.Id;
            prodRatePlan.RatePlanType__c= 'Proration';
            prodRatePlan.zqu__EffectiveStartDate__c= date.today();
            prodRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prodRatePlan.zqu__Deleted__c = false;
            prodRatePlan.zqu__ZuoraId__c = 'Test';
            insert prodRatePlan;
            
            //Setup Product_Family__c records
            prodFamily = new Product_Family__c();
            prodFamily.Product_Family__c = 'Trythis';
            prodFamily.Product_Family_Name__c = 'testtest';
            insert prodFamily;
            
            //Setup Package Item records
            packageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            packageItem.Package__c = packge.id;
            packageItem.Product_Rate_Plan__c = prodRatePlan.id;
            packageItem.Name = 'Test Pack Item';
            packageItem.Product_Family__c = prodFamily.Id;
            insert packageItem;
    
            Account acct = new Account();
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.NRIC__c = 'T1234567R';
            insert acct;
    
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
            insert acctVendor;
    
            Account acct2 = new Account();
            acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct2.NRIC__c = 'T1234567R';
            insert acct2;
    
            Contact con = new Contact();
            con = TestDataFactory.createContact(1)[0];
            con.AccountId = acct.Id;
            con.Address__c = address.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
    
            //create order
            List<Order__c> order = TestDataFactory.createOrder(2);
            order[0].Account__c = acct.Id;
            order[0].Recipient_Contact__c = con.Id;
            order[0].Informed_Customer__c = True;
            order[0].Acquisition_Type__c = 'Call';
            order[1].Account__c = acct.Id;
            order[1].Recipient_Contact__c = con.Id;
            order[1].Informed_Customer__c = True;
            order[1].Acquisition_Type__c = 'Call';
            insert order;
    
            //create case
            List<Case> cas = TestDataFactory.createCase(5, 'Complaint - Magazine');
            cas[0].Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
            cas[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            cas[0].Order__c = order[0].Id;
            cas[1].Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            cas[1].RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas[1].Order__c = order[0].Id;
            cas[2].Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            cas[2].RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas[2].Order__c = order[1].Id;
            cas[2].Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas[2].Status = 'Pending';
            cas[3].Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
            cas[3].RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            cas[4].Sub_Category__c = GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION;
            cas[4].RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Subscription');
            cas[4].Order__c = order[1].Id;
            cas[4].Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas[4].Status = 'Pending';
    
            insert cas;
    
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order[0].Id;
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = packge.Id;
            orderline.Term_Length__c = 1;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+5;
            orderline.Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline.Vendor_Mailing_Agent__c = null;
            orderline.Subscription_Name__c ='test name';
            orderline.Is_Digital__c = false;
    
            insert orderline;
    
            //WAK 04/15/2016
            Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = con.id);        
            insert asiaOneRecord;
            System.debug('***wendy : inserted asiaOneRecord');
    
            Service_Access_Flag__c saf = new Service_Access_Flag__c();
            saf.Name = 'test name';
            insert saf;
            System.debug('***wendy : inserted saf');
    
            Asia1_Subscription__c tmp = new Asia1_Subscription__c();
            tmp.Asia1__c = asiaOneRecord.id;
            tmp.Order_Line_Item__c = orderline.id;
            tmp.Service_Access_Flag__c = saf.id;
            tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
            insert tmp; 
            System.debug('***wendy : inserted tmp');
    
            //create subscription vendor
            Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            insert SubVend;
            System.debug('***wendy : inserted tmp');
    
            Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
            zua.Zuora__Account__c = acct.Id;
            zua.Zuora__DefaultPaymentMethod__c = 'Other';
            insert zua; 
            System.debug('***wendy : inserted zua');
    
    
            Zuora__CustomerAccount__c zua2 =  TestDataFactory.createBillingAccount(1)[0];
            zua2.Zuora__Account__c = acct.Id;
            zua2.Zuora__DefaultPaymentMethod__c = 'Other';
            insert zua2; 
            
            Letter_Print_Request__c lpr = new Letter_Print_Request__c();
            lpr.Letter_Type__c = GlobalVariableClass.LETTER_TYPE_ACK;
            lpr.Record_ID__c = zua.Id;
            insert lpr;
            
            List<Zuora__PaymentMethod__c> paymentMethodList = TestDataFactory.createPaymentMethod(2);
            paymentMethodList[0].Zuora__Type__c = 'CreditCard';
            paymentMethodList[0].Zuora__BillingAccount__c = zua.Id;
            paymentMethodList[1].Zuora__Type__c = 'CreditCard';
            paymentMethodList[1].Zuora__BillingAccount__c = zua2.Id;
            insert paymentMethodList;
            
            zua.Zuora__Default_Payment_Method__c = paymentMethodList[0].Id;
            update zua;
            system.debug('>>>>>zua ' + zua.Zuora__Default_Payment_Method__c);
            system.debug('>>>>>zua ' + zua.Zuora__Default_Payment_Method__r.Zuora__Type__c);
            system.debug('>>>>>zua ' + zua.Zuora__PaymentMethod_Type__c);
            zua2.Zuora__Default_Payment_Method__c = paymentMethodList[0].Id;
            update zua2;
            System.debug('***wendy : inserted zua2');

            test.startTest();
            List<Zuora__Subscription__c> relSub = new List<Zuora__Subscription__c>();
            relSub = TestDataFactory.createSubscription(3);
            relSub[0].Zuora__AutoRenew__c = true;
            relSub[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[0].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[0].Zuora__Account__c = acct.Id;
            relSub[0].Order_Number__c = order[0].Id;
            relSub[0].Subscriber_Contact__c = con.Id;
            relSub[0].Recipient_Contact__c = con.Id;
            relSub[0].Recipient_Contact_1__c = con.Id;
            relSub[0].Main_Package_1__c = packge.id;
            relSub[0].Zuora__Status__c = 'Active';
            relSub[0].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[0].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[0].Urgent__c = 'false';
            relSub[0].Vendor_Conversion__c = 'false';
            relSub[0].Charity__c = 'false';
            relSub[0].Order_Line_Item_Number__c = orderline.Id;
            //relSub[0].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[0].Vendor_1__c = acctVendor.id;
            relSub[0].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[0].Zuora__Zuora_Id__c = '111111';
            relSub[0].Term_Length__c = 12;
            relSub[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub[0].Zuora__SubscriptionEndDate__c = relSub[0].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[0].Term_Length__c)).addDays(-1);
            relSub[0].Zuora__Version__c = 1;
            relSub[0].Zuora__TermSettingType__c = 'TERMED';
            relSub[1].Zuora__AutoRenew__c = true;
            relSub[1].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[1].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[1].Zuora__Account__c = acct.Id;
            relSub[1].Order_Number__c = order[0].Id;
            relSub[1].Subscriber_Contact__c = con.Id;
            relSub[1].Recipient_Contact__c = con.Id;
            relSub[1].Recipient_Contact_1__c = con.Id;
            relSub[1].Main_Package_1__c = packge.id;
            relSub[1].Zuora__Status__c = 'Cancelled';
            relSub[1].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[1].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[1].Urgent__c = 'false';
            relSub[1].Vendor_Conversion__c = 'false';
            relSub[1].Charity__c = 'false';
            relSub[1].Order_Line_Item_Number__c = orderline.Id;
            //relSub[1].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[1].Vendor_1__c = acctVendor.id;
            relSub[1].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[1].Zuora__Zuora_Id__c = '111111';
            relSub[1].Term_Length__c = 12;
            relSub[1].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub[1].Zuora__SubscriptionEndDate__c = relSub[1].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[1].Term_Length__c));
            relSub[1].Zuora__Version__c = 2;
            relSub[2].Zuora__AutoRenew__c = true;
            relSub[2].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
            relSub[2].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
            relSub[2].Zuora__Account__c = acct.Id;
            relSub[2].Order_Number__c = order[0].Id;
            relSub[2].Subscriber_Contact__c = con.Id;
            relSub[2].Recipient_Contact__c = con.Id;
            relSub[2].Recipient_Contact_1__c = con.Id;
            relSub[2].Main_Package_1__c = packge.id;
            relSub[2].Zuora__Status__c = 'Cancelled';
            relSub[2].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[2].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[2].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[2].Urgent__c = 'false';
            relSub[2].Vendor_Conversion__c = 'false';
            relSub[2].Charity__c = 'false';
            relSub[2].Order_Line_Item_Number__c = orderline.Id;
            //relSub[2].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[2].Vendor_1__c = acctVendor.id;
            relSub[2].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[2].Zuora__Zuora_Id__c = '111111';
            relSub[2].Term_Length__c = 12;
            relSub[2].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub[2].Zuora__SubscriptionEndDate__c = relSub[2].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[2].Term_Length__c));
            relSub[2].Zuora__Version__c = 2;
            relSub[2].Legacy_Subscription_ID__c = '12345';
            insert relSub;
            
            order[0].Base_Subscription__c = relSub[0].Id;
            update order[0];
            
            orderline.Subscription_Name__c = relSub[0].Name;
            orderline.Case__c = cas[0].Id;
            update orderline;
            
            List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(3);
            orderline1[0].Order__c = order[0].Id;
            orderline1[0].End_Date__c = date.today()+30;
            orderline1[0].Main_Package_ID__c = packge.Id;
            orderline1[0].Term_Length__c = 1;
            orderline1[0].Main_Package_Period__c = 0;
            orderline1[0].Earliest_Start_Date__c = date.today();
            orderline1[0].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[0].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[0].Terminating_Reason__c = 'Others';
            orderline1[0].Amount_To_Refund__c = 0;
            orderline1[0].Admin_Charge__c = 0;
            orderline1[0].Fee_Waiver__c = TRUE;
            orderline1[0].Fee_Override__c = TRUE;
            orderline1[0].Override_Reason__c = 'TEST';
            orderline1[0].Suppress_Notification_Stop__c = TRUE;
            orderline1[0].Main_Package_Type__c = 'Base';
            orderline1[0].Start_Date__c = date.today()+5;
            orderline1[0].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[0].Vendor_Mailing_Agent__c = null;
            orderline1[0].Subscription_Name__c = relSub[1].Name;
            orderline1[0].Is_Digital__c = false;
            orderline1[1].Order__c = order[0].Id;
            orderline1[1].End_Date__c = date.today()+30;
            orderline1[1].Main_Package_ID__c = packge.Id;
            orderline1[1].Term_Length__c = 1;
            orderline1[1].Main_Package_Period__c = 0;
            orderline1[1].Earliest_Start_Date__c = date.today();
            orderline1[1].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[1].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[1].Terminating_Reason__c = 'Others';
            orderline1[1].Amount_To_Refund__c = 0;
            orderline1[1].Admin_Charge__c = 0;
            orderline1[1].Fee_Waiver__c = TRUE;
            orderline1[1].Fee_Override__c = TRUE;
            orderline1[1].Override_Reason__c = 'TEST';
            orderline1[1].Suppress_Notification_Stop__c = TRUE;
            orderline1[1].Main_Package_Type__c = 'Base';
            orderline1[1].Start_Date__c = date.today()+5;
            orderline1[1].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[1].Vendor_Mailing_Agent__c = null;
            orderline1[1].Subscription_Name__c = relSub[1].Name;
            orderline1[1].Is_Digital__c = false;
            orderline1[1].Case__c = cas[2].Id;
            orderline1[1].Subscription__c = relSub[0].Id;
            orderline1[2].Order__c = order[0].Id;
            orderline1[2].End_Date__c = date.today()+30;
            orderline1[2].Main_Package_ID__c = packge.Id;
            orderline1[2].Term_Length__c = 1;
            orderline1[2].Main_Package_Period__c = 0;
            orderline1[2].Earliest_Start_Date__c = date.today();
            orderline1[2].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[2].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[2].Terminating_Reason__c = 'Others';
            orderline1[2].Amount_To_Refund__c = 0;
            orderline1[2].Admin_Charge__c = 0;
            orderline1[2].Fee_Waiver__c = TRUE;
            orderline1[2].Fee_Override__c = TRUE;
            orderline1[2].Override_Reason__c = 'TEST';
            orderline1[2].Suppress_Notification_Stop__c = TRUE;
            orderline1[2].Main_Package_Type__c = 'Base';
            orderline1[2].Start_Date__c = date.today()+5;
            orderline1[2].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[2].Vendor_Mailing_Agent__c = null;
            orderline1[2].Subscription_Name__c = relSub[2].Name;
            orderline1[2].Is_Digital__c = false;
            orderline1[2].Case__c = cas[4].Id;
            orderline1[2].Subscription__c = relSub[0].Id;
    
            insert orderline1;
            
            relSub[0].Zuora__CustomerAccount__c = zua2.id;
            update relSub[0];
            
            test.stopTest(); 
            /*
            List<Zuora__Subscription__c> relSub1 = TestDataFactory.createSubscription(1);
            relSub1[0].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub1[0].Subscription_Type__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub1[0].Zuora__Zuora_Id__c = '222222';
            relSub1[0].Recipient_Contact__c = null;
            relSub1[0].Name = 'test name';
            relSub1[0].Zuora__Account__c = acct.Id;        
            relSub1[0].Order_Number__c = order.Id;
            relSub1[0].Subscriber_Contact__c = con.Id;
            relSub1[0].Vendor_Subscription_To_Convert_1__c = SubVend.Id;
            relSub1[0].Subscription_Charge__c = null;
            relSub1[0].Main_Package_1__c = packge.id;
            relSub1[0].Zuora__Status__c = GlobalVariableClass.STATUS_ACTIVE;
            relSub1[0].Suppress_Vendor_Start_Notice__c = 'false';
            relSub1[0].Supressed_Acknowledgement_Letter__c = 'false';
            relSub1[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub1[0].Urgent__c = 'false';
            relSub1[0].Vendor_Conversion__c = 'false';
            relSub1[0].Charity__c = 'false';
            relSub1[0].Order_Line_Item_Number__c = orderline.Id;
            //relSub1[0].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub1[0].Vendor_1__c = acctVendor.id;
            relSub1[0].Zuora__CustomerAccount__c = zua.id;
            //relSub1[1].Order_Number_1__c = order2.id;
            relSub1[0].Vendor__c = acctVendor.Id+'';
            relSub1[0].Zuora__AutoRenew__c = true;
            relSub1[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
            relSub1[0].Payment_Mode__c = 'Other';
            relSub1[0].Other_PaymentMethod__c = 'Freelist';
            relSub1[0].Order_Line_Item_Number_1__c = orderline.Id;
            relSub1[0].Zuora__Version__c = 1;
            relSub1[0].Term_Length__c = 12;
            relSub1[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub1[0].Zuora__SubscriptionEndDate__c = relSub1[0].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub1[0].Term_Length__c)).addDays(-1);
            relSub1[0].Related_Subscription__c = '222222';
            insert relSub1[0];
            
            Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
            temp.Temp_Stop_Date__c = relSub1[0].Zuora__SubscriptionStartDate__c.addMonths(1).toStartOfMonth();
            temp.Restart_Date__c = temp.Temp_Stop_Date__c.addDays(10);
            temp.Qty__c = 1;
            //temp.Cancelled__c  = true;
            database.insert(temp);
            
            Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
            subTemp.Temp_Stop__c = temp.Id;
            subTemp.Subscription__c = relSub1[0].Id; 
            database.insert(subTemp);
            
            Address_Assignment__c addAss = new Address_Assignment__c();
            addAss.Active__c = false;
            addAss.Effective_Date__c = date.today().addMonths(2).toStartOfMonth();
            addAss.Subscription__c = relSub1[0].Id;
            addAss.Address__c = address.Id;
            addAss.Contact__c = con.Id;
            insert addAss;
            */
        }
    }
    
    static testMethod void testMethod4() {
        User usr = createUser();
    
        //The test will run as the user created.
        System.runAs(usr) {
            //setUpTestData();
            List<RecordType> rectype = new List<RecordType>();
            rectype = [Select Id From RecordType Where Name = 'Extension Product'  AND SObjectType = 'Package_Item__c'];
            Id packitemid = rectype[0].id;
            Key_Id__c keypackage = new Key_Id__c();
            keypackage.Id__c = rectype[0].id;
            keypackage.Name = 'Package Item_Extension Product';
            keypackage.Type__c = 'RecordType';
            insert keypackage;
            
            List<Billing_Batch__c> billBatches = new List<Billing_Batch__c>();
            billBatches = CustomSettingsDataFactory.createBillingBatch();
            insert billBatches;
            
            Singpost_Address__c postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
    
            Address__c address = new Address__c();
            address = TestDataFactory.createAddress(1)[0];
            address.Postal_Code__c = postal.Id;
            insert address;
    
    
            packge = TestDataFactory.createPackage(1)[0];
            packge.Billing_Type__c = 'Full Prepaid';
            packge.Package_Type__c = 'Grace Period';
            packge.Subscription_Period__c = '1';
            packge.Package_Code__c = 'STSU';
            packge.Product_Family_Current_Package__c = 'test';
            insert packge;
            
            //Setup zqu__ZProduct__c records
            zProducts = TestDataFactory.createZProduct(1)[0];
            zProducts.ProductSubType__c = 'Magazine';
            zProducts.zqu__ZuoraId__c = 'Test';
            insert zProducts ;
            
            //Setup zqu__ProductRatePlan__c records
            prodRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
            prodRatePlan.zqu__ZProduct__c = zProducts.Id;
            prodRatePlan.RatePlanType__c= 'Proration';
            prodRatePlan.zqu__EffectiveStartDate__c= date.today();
            prodRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prodRatePlan.zqu__Deleted__c = false;
            prodRatePlan.zqu__ZuoraId__c = 'Test';
            insert prodRatePlan;
            
            //Setup Product_Family__c records
            prodFamily = new Product_Family__c();
            prodFamily.Product_Family__c = 'Trythis';
            prodFamily.Product_Family_Name__c = 'testtest';
            insert prodFamily;
            
            //Setup Package Item records
            packageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            packageItem.Package__c = packge.id;
            packageItem.Product_Rate_Plan__c = prodRatePlan.id;
            packageItem.Name = 'Test Pack Item';
            packageItem.Product_Family__c = prodFamily.Id;
            insert packageItem;
    
            Account acct = new Account();
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.NRIC__c = 'T1234567R';
            acct.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual');
            insert acct;
            system.debug('>>>>>acct.RecordTypeId ' +  acct.RecordTypeId);
    
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
            insert acctVendor;
    
            Account acct2 = new Account();
            acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct2.NRIC__c = 'T1234567R';
            insert acct2;
    
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
            order.Acquisition_Type__c = 'Call';
            insert order;
    
            //create case
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
            cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
    
            insert cas;
    
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = packge.Id;
            orderline.Term_Length__c = 1;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+5;
            orderline.Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline.Vendor_Mailing_Agent__c = null;
            orderline.Subscription_Name__c ='test name';
            orderline.Is_Digital__c = false;
    
            insert orderline;
    
            //WAK 04/15/2016
            Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = con.id);        
            insert asiaOneRecord;
            System.debug('***wendy : inserted asiaOneRecord');
    
            Service_Access_Flag__c saf = new Service_Access_Flag__c();
            saf.Name = 'test name';
            insert saf;
            System.debug('***wendy : inserted saf');
    
            Asia1_Subscription__c tmp = new Asia1_Subscription__c();
            tmp.Asia1__c = asiaOneRecord.id;
            tmp.Order_Line_Item__c = orderline.id;
            tmp.Service_Access_Flag__c = saf.id;
            tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
            insert tmp; 
            System.debug('***wendy : inserted tmp');
    
            //create subscription vendor
            Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            insert SubVend;
            System.debug('***wendy : inserted tmp');
    
            Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
            zua.Zuora__Account__c = acct.Id;
            zua.Zuora__DefaultPaymentMethod__c = 'CreditCard';
            insert zua; 
            System.debug('***wendy : inserted zua');
    
    
            Zuora__CustomerAccount__c zua2 =  TestDataFactory.createBillingAccount(1)[0];
            zua2.Zuora__Account__c = acct.Id;
            zua2.Zuora__DefaultPaymentMethod__c = 'Other';
            insert zua2; 
            
            List<Zuora__PaymentMethod__c> paymentMethodList = TestDataFactory.createPaymentMethod(2);
            paymentMethodList[0].Zuora__Type__c = 'CreditCard';
            paymentMethodList[0].Zuora__BillingAccount__c = zua.Id;
            paymentMethodList[1].Zuora__Type__c = 'CreditCard';
            paymentMethodList[1].Zuora__BillingAccount__c = zua2.Id;
            insert paymentMethodList;
            
            zua.Zuora__Default_Payment_Method__c = paymentMethodList[0].Id;
            update zua;
            zua2.Zuora__Default_Payment_Method__c = paymentMethodList[0].Id;
            update zua2;
            System.debug('***wendy : inserted zua2');
            /*
            List<Zuora__Subscription__c> relSub = new List<Zuora__Subscription__c>();
            relSub = TestDataFactory.createSubscription(2);
            relSub[0].Zuora__AutoRenew__c = true;
            relSub[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[0].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[0].Zuora__Account__c = acct.Id;
            relSub[0].Order_Number__c = order.Id;
            relSub[0].Subscriber_Contact__c = con.Id;
            relSub[0].Recipient_Contact__c = con.Id;
            relSub[0].Recipient_Contact_1__c = con.Id;
            relSub[0].Main_Package_1__c = packge.id;
            relSub[0].Zuora__Status__c = 'Active';
            relSub[0].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[0].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[0].Urgent__c = 'false';
            relSub[0].Vendor_Conversion__c = 'false';
            relSub[0].Charity__c = 'false';
            relSub[0].Order_Line_Item_Number__c = orderline.Id;
            //relSub[0].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[0].Vendor_1__c = acctVendor.id;
            relSub[0].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[0].Zuora__Zuora_Id__c = '111111';
            relSub[0].Term_Length__c = 12;
            relSub[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub[0].Zuora__SubscriptionEndDate__c = relSub[0].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[0].Term_Length__c)).addDays(-1);
            relSub[0].Zuora__Version__c = 1;
            relSub[1].Zuora__AutoRenew__c = true;
            relSub[1].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[1].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[1].Zuora__Account__c = acct.Id;
            relSub[1].Order_Number__c = order.Id;
            relSub[1].Subscriber_Contact__c = con.Id;
            relSub[1].Recipient_Contact__c = con.Id;
            relSub[1].Recipient_Contact_1__c = con.Id;
            relSub[1].Main_Package_1__c = packge.id;
            relSub[1].Zuora__Status__c = 'Cancelled';
            relSub[1].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[1].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[1].Urgent__c = 'false';
            relSub[1].Vendor_Conversion__c = 'false';
            relSub[1].Charity__c = 'false';
            relSub[1].Order_Line_Item_Number__c = orderline.Id;
            //relSub[1].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[1].Vendor_1__c = acctVendor.id;
            relSub[1].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[1].Zuora__Zuora_Id__c = '111111';
            relSub[1].Term_Length__c = 12;
            relSub[1].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub[0].Zuora__Version__c = 2;
            insert relSub;
            
            Order_Line_Item__c orderline1 = TestDataFactory.createOrderLineItem(1)[0];
            orderline1.Order__c = order.Id;
            orderline1.End_Date__c = date.today()+30;
            orderline1.Main_Package_ID__c = packge.Id;
            orderline1.Term_Length__c = 1;
            orderline1.Main_Package_Period__c = 0;
            orderline1.Earliest_Start_Date__c = date.today();
            orderline1.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1.Terminating_Reason__c = 'Others';
            orderline1.Amount_To_Refund__c = 0;
            orderline1.Admin_Charge__c = 0;
            orderline1.Fee_Waiver__c = TRUE;
            orderline1.Fee_Override__c = TRUE;
            orderline1.Override_Reason__c = 'TEST';
            orderline1.Suppress_Notification_Stop__c = TRUE;
            orderline1.Main_Package_Type__c = 'Base';
            orderline1.Start_Date__c = date.today()+5;
            orderline1.Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1.Vendor_Mailing_Agent__c = null;
            orderline1.Subscription_Name__c = relSub[1].Name;
            orderline1.Is_Digital__c = false;
    
            insert orderline1;
            */
            
            test.startTest();
            List<Zuora__Subscription__c> relSub1 = TestDataFactory.createSubscription(1);
            relSub1[0].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub1[0].Subscription_Type__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub1[0].Zuora__Zuora_Id__c = '222222';
            relSub1[0].Recipient_Contact__c = null;
            relSub1[0].Name = 'test name';
            relSub1[0].Zuora__Account__c = acct.Id;        
            relSub1[0].Order_Number__c = order.Id;
            relSub1[0].Subscriber_Contact__c = con.Id;
            relSub1[0].Vendor_Subscription_To_Convert_1__c = SubVend.Id;
            relSub1[0].Subscription_Charge__c = null;
            relSub1[0].Main_Package_1__c = packge.id;
            relSub1[0].Zuora__Status__c = GlobalVariableClass.STATUS_ACTIVE;
            relSub1[0].Suppress_Vendor_Start_Notice__c = 'false';
            relSub1[0].Supressed_Acknowledgement_Letter__c = 'false';
            relSub1[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub1[0].Urgent__c = 'false';
            relSub1[0].Vendor_Conversion__c = 'false';
            relSub1[0].Charity__c = 'false';
            relSub1[0].Order_Line_Item_Number__c = orderline.Id;
            //relSub1[0].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub1[0].Vendor_1__c = acctVendor.id;
            relSub1[0].Zuora__CustomerAccount__c = zua.id;
            //relSub1[1].Order_Number_1__c = order2.id;
            relSub1[0].Vendor__c = acctVendor.Id+'';
            relSub1[0].Zuora__AutoRenew__c = true;
            relSub1[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
            relSub1[0].Payment_Mode__c = 'Other';
            relSub1[0].Other_PaymentMethod__c = 'Freelist';
            relSub1[0].Order_Line_Item_Number_1__c = orderline.Id;
            relSub1[0].Zuora__Version__c = 1;
            relSub1[0].Term_Length__c = 12;
            relSub1[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub1[0].Zuora__SubscriptionEndDate__c = relSub1[0].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub1[0].Term_Length__c)).addDays(-1);
            relSub1[0].Related_Subscription__c = '222222';
            relSub1[0].Zuora__TermSettingType__c = 'TERMED';
            relSub1[0].Sponsor_1__c = false;
            insert relSub1;
            
            order.Base_Subscription__c = relSub1[0].Id;
            update order;
            
            system.debug('>>>>>relSub1[0] ' + relSub1[0].Zuora__Account__c);
            relSub1[0].Zuora__SubscriptionEndDate__c = relSub1[0].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub1[0].Term_Length__c)).addDays(-3);
            update relSub1;
            
            Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
            temp.Temp_Stop_Date__c = relSub1[0].Zuora__SubscriptionStartDate__c.addMonths(1).toStartOfMonth();
            temp.Restart_Date__c = temp.Temp_Stop_Date__c.addDays(10);
            temp.Qty__c = 1;
            temp.Cancelled__c  = true;
            insert temp;
            system.debug('>>>>>temp ' + temp.Cancelled__c);
            system.debug('>>>>>temp ' + temp.Temp_Stop_Status__c);
            system.debug('>>>>>temp ' + temp.Id);
            system.debug('>>>>>temp ' + temp.Temp_Stop_Date__c);
            Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
            subTemp.Temp_Stop__c = temp.Id;
            subTemp.Subscription__c = relSub1[0].Id; 
            database.insert(subTemp);
            system.debug('>>>>>subTemp ' + subTemp.Temp_Stop__c);
            system.debug('>>>>>subTemp ' + subTemp.Subscription__c);
            
            Address_Assignment__c addAss = new Address_Assignment__c();
            addAss.Active__c = false;
            addAss.Effective_Date__c = date.today().addMonths(2).toStartOfMonth();
            addAss.Subscription__c = relSub1[0].Id;
            addAss.Address__c = address.Id;
            addAss.Contact__c = con.Id;
            insert addAss;
            
            test.stopTest(); 
        }
    }
    
    static testMethod void testSingleInsertUpdate2(){        
        User usr = createUser();
        
        //The test will run as the user created.
        System.runAs(usr) {
            setUpTestData();
                        List<Billing_Batch__c> billBatches = new List<Billing_Batch__c>();
            billBatches = CustomSettingsDataFactory.createBillingBatch();
            insert billBatches;
            Zuora__Subscription__c sobj = new Zuora__Subscription__c();
            Zuora__Subscription__c sobj2 = new Zuora__Subscription__c();        
            
            SubscriptionTriggerHandler subhandler = new SubscriptionTriggerHandler();
            subhandler.beforeDelete(sobj);
            SubscriptionTriggerHandler subhandler2 = new SubscriptionTriggerHandler();
            subhandler.afterDelete(sobj2);
            
            //subhandler.testCoveragePatch();
            
            SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = FALSE;
            SubscriptionTriggerHandler.isAfterDeleteTriggerCalled = FALSE;
            
            //Singpost_Address__c postal = new Singpost_Address__c();
            //postal = TestDataFactory.createSingpostAddress(1)[0];
            //insert postal;
            
            //Address__c address = new Address__c();
            //address = TestDataFactory.createAddress(1)[0];
            //address.Postal_Code__c = postal.Id;
            //insert address;
            
            //Package__c pack = new Package__c();
            //pack = TestDataFactory.createPackage(1)[0];
            //insert pack;
            
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
            //acctVendor.Ven
            insert acctVendor;
            
            //Contact con = new Contact();
            //con = TestDataFactory.createContact(1)[0];
            //con.AccountId = acct.Id;
            //con.Address__c = address.Id;
            //// START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
            ////con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            //con.Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            //insert con;
            
            /*[JPO 02/13] create con2
Contact con2 = new Contact();
con2 =  TestDataFactory.createContact(1)[0];
con2.AccountId = acct2.Id;
con2.Address__c = address.Id;            
con2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
con2.Recipient_Indicator__c = true;
insert con2; */
            
            
            
            //create order
            /*   Order__c order = TestDataFactory.createOrder(1)[0];
order.Account__c = acnt.Id;
order.Recipient_Contact__c = cntctList[1].Id;
order.Informed_Customer__c = True;*/
            //order.Base_Subscription__c = zuoraSubscription.Id;
            
            //WAK 04/15/16 added
            //order.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            //insert order;
            
            /*[JPO 02/13] create order2 for subrRec's orderline item 1
Order__c order2 = TestDataFactory.createOrder(1)[0];
order2.Account__c = acct2.Id;
order2.Recipient_Contact__c = con2.Id;
order2.Informed_Customer__c = True;
insert order2; //error? FIELD_FILTER_VALIDATION_EXCEPTION, Value does not exist or does not match filter criteria.: [Recipient_Contact__c]
*/
            //create case
            //Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            //cas.Order__c = order.Id;
            //insert cas;
            /*
Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
orderline.Order__c = order.Id;
orderline.End_Date__c = date.newInstance(2014, 12, 2);
orderline.End_Date__c = date.today()+30;
orderline.Main_Package_ID__c = packge.Id;
orderline.Term_Length__c = 1;
orderline.Main_Package_Period__c = 0;
orderline.Earliest_Start_Date__c = date.today();
orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
orderline.Stop_Request_Date__c =  date.Today().addDays(4);
orderline.Terminating_Reason__c = 'Others';
orderline.Amount_To_Refund__c = 0;
orderline.Admin_Charge__c = 0;
orderline.Fee_Waiver__c = TRUE;
orderline.Fee_Override__c = TRUE;
orderline.Override_Reason__c = 'TEST';
orderline.Suppress_Notification_Stop__c = TRUE;
orderline.Main_Package_Type__c = 'Base';
orderline.Start_Date__c = date.today()+5;
*/
            
            //WAK 04/15/2016
            Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = cntctList[0].id);        
            insert asiaOneRecord;
            System.debug('***wendy : inserted asiaOneRecord');
            
            Service_Access_Flag__c saf = new Service_Access_Flag__c();
            saf.Name = 'test name';
            insert saf;
            System.debug('***wendy : inserted saf');
            
            Package_Access_Flag__c paf = new Package_Access_Flag__c();
            paf.Package_Service_Access_Flag__c = saf.id;
            paf.Package__c = packge.id;
            paf.No_of_Concurrent_Users__c = 1;
            insert paf;
            System.debug('***wendy : inserted paf' + paf.Package__c);
            
            List<Asia1_Subscription__c> tmpList = new List<Asia1_Subscription__c>();
            Asia1_Subscription__c tmp = new Asia1_Subscription__c();
            tmp.Asia1__c = asiaOneRecord.id;
            tmp.Order_Line_Item__c = ordLineItem.id;
            tmp.Service_Access_Flag__c = saf.id;
            tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
            tmpList.add(tmp);
            Asia1_Subscription__c tmp1 = new Asia1_Subscription__c();
            tmp1.Asia1__c = asiaOneRecord.id;
            tmp1.Order_Line_Item__c = ordLineItem.id;
            tmp1.Service_Access_Flag__c = saf.id;
            tmp1.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED;
            tmpList.add(tmp1);
            insert tmpList; 
            System.debug('***wendy : inserted tmp');
            
            //create subscription vendor
            //Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            ////SubVend.Name = 'Test Subscription Vendor';
            //insert SubVend;
            //System.debug('***wendy : inserted tmp');
            
            Case caseRec = new Case();
            caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            caseRec.Status = 'Pending';
            caseRec.Sub_Status__c = 'Wating for Vendor Assignment';               
            insert caseRec;   
            System.debug('***wendy : caseRec'); 
            
            Subscription_Vendor__c venSub = new Subscription_Vendor__c();
            venSub = TestDataFactory.createSubscriptionVendor(1)[0];
            insert venSub;
            
            Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
            zua.Zuora__Account__c = acnt.Id;
            zua.Zuora__DefaultPaymentMethod__c = 'Other';
            //zua.Zuora__PaymentMethodType__c = 'Paypal';
            insert zua; 
            System.debug('***wendy : inserted zua');
            String ZuoraExternalId = 'try1234';
            Zuora__Subscription__c subRec = TestDataFactory.createSubscription(1)[0];
            subRec.Zuora__Account__c = acnt.Id;
            subRec.Order_Line_Item_Number__c = ordLineItem.Id;
            //subRec.Subscriber_Contact__c = cntctList[0].Id;
            //subRec.Recipient_Contact__c = cntctList[0].Id;
            subRec.Main_Package_1__c = packge.Id;
            subRec.Main_Package__c = packge.Id;
            subRec.Zuora__Status__c = 'Active';
            subRec.Order_Number__c = orders.Id;
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Charity__c = 'false';
            subRec.Subscription_Type__c = 'Publication';
            subRec.Subscription_Type_1__c = 'Publication';
            subRec.Zuora__SubscriptionEndDate__c= date.today().addDays(30);        
            subRec.Zuora__TermSettingType__c = 'TERMED';
            subRec.Term_Length__c = 1;
            subRec.Zuora__SubscriptionStartDate__c = date.today();
            subRec.Zuora__CustomerAccount__c = custAccount.Id;
            subRec.Contact__c = cntctList[0].id;
            subRec.Zuora__External_Id__c = ZuoraExternalId;
            subRec.Zuora__Zuora_Id__c = ZuoraExternalId;
            subRec.Order_Line_Item_Number_1__c = ordLineItem.Id;
            subRec.Delivered_By__c = 'Vendor';
            subRec.Vendor_Subscription_To_Convert_1__c = venSub.id;
            subRec.Term_Length__c = 12;
            subRec.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_MR_POST;
            subRec.Vendor_Credit_1__c = 1;
            subRec.Delivery_Charge_Type_1__c = 'H';
            subRec.Zuora__TermSettingType__c = 'EVERGREEN';
            
            
            // insert zuoraSubscription;
            /*
Zuora__Subscription__c subRec = new Zuora__Subscription__c();
subRec = TestDataFactory.createSubscription(1)[0];
subRec.Zuora__Account__c = acnt.Id;
subRec.Order_Number__c = order.Id;
subRec.Subscriber_Contact__c = cntctList[0].Id;
//subRec.Recipient_Contact__c = con.Id;
subRec.Main_Package_1__c = packge.id;
subRec.Zuora__Status__c = 'Active';
//subRec.Zuora__Status__c = 'Cancelled'; [JPO 02/13] commented out
subRec.Suppress_Vendor_Start_Notice__c = 'false';
subRec.Supressed_Acknowledgement_Letter__c = 'false';
subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
subRec.Urgent__c = 'false';
subRec.Vendor_Conversion__c = 'false';
subRec.Charity__c = 'false';
subRec.Order_Line_Item_Number__c = ordLineItem.Id;
subrec.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
subRec.Vendor_1__c = acctVendor.id;
subRec.Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
//subRec.Order_Number_1__c = order2.id; //[JPO 02/13] added 
*/       
            
            test.startTest(); //[JPO 02/12/2015] Moved startTest before inserting subRec 
            insert subRec; 
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acnt.Id;
            order.Recipient_Contact__c = cntctList[1].Id;
            order.Informed_Customer__c = True;
            insert order;
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = packge.Id;
            orderline.Term_Length__c = 1;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+5;
            orderline.Subscription_Name__c = subRec.name;
            orderline.Main_Package_Subscription_Rate__c  = 10;
            orderline.Qty__c = 1;
           
            insert orderline;
            subRec.Zuora__Status__c = 'Cancelled';
           //subRec.Recipient_Contact__c = null;
            subRec.Subscription_Charge__c = null;
            update subRec;
            
            System.debug('***wendy : inserted subRec');
            
           
            
            Zuora__Subscription__c subRec2 = new Zuora__Subscription__c();
            subRec2 = TestDataFactory.createSubscription(1)[0];
            subRec2.Zuora__Version__c = 2; 
            subRec2.Zuora__CustomerAccount__c = custAccount.Id;       
            insert subRec2;
                        
            
            //[JPO 02/12/2015] Adding List
            //List<Zuora__Subscription__c> testsubscriptionList = TestDataFactory.createSubscription(1);
            //testsubscriptionList.add(subrec);
            
            //insert testsubscriptionList;
            
            /* removing this causing SOQL limit
Zuora__Subscription__c subRec2 = new Zuora__Subscription__c();
subRec2 = TestDataFactory.createSubscription(1)[0];
subRec2.Zuora__Account__c = acct.Id;
subRec2.Order_Number__c = order.Id;
subRec2.Subscriber_Contact__c = con.Id;
subRec2.Recipient_Contact__c = con.Id;
subRec2.Main_Package_1__c = pack.id;
subRec2.Suppress_Vendor_Start_Notice__c = 'false';
subRec2.Supressed_Acknowledgement_Letter__c = 'false';
subRec2.Supressed_Renewal_and_Reminder_Letter__c = 'false';
subRec2.Urgent__c = 'false';
subRec2.Vendor_Conversion__c = 'false';
subRec2.Charity__c = 'false';
//subRec2.Zuora__Status__c = NULL;
subRec2.Order_Line_Item_Number__c = orderline.Id;
insert subRec2;

Zuora__Subscription__c subRec3 = new Zuora__Subscription__c();
subRec3 = TestDataFactory.createSubscription(1)[0];
subRec3.Zuora__Account__c = acct.Id;
subRec3.Order_Number__c = order.Id;
subRec3.Subscriber_Contact__c = con.Id;
subRec3.Recipient_Contact__c = con.Id;
subRec3.Main_Package_1__c = pack.id;
subRec3.Suppress_Vendor_Start_Notice__c = 'false';
subRec3.Supressed_Acknowledgement_Letter__c = 'false';
subRec3.Supressed_Renewal_and_Reminder_Letter__c = 'false';
subRec3.Urgent__c = 'false';
subRec3.Vendor_Conversion__c = 'false';
subRec3.Charity__c = 'false';
subRec3.Order_Line_Item_Number__c = orderline.Id;
insert subRec3;
*/                      
            /*
            Case_Subscription__c  caseSub = new Case_Subscription__c();
            caseSub.Account__c = acnt.Id;
            caseSub.Address__c = addrList[0].Id;
            caseSub.Case__c = caseRec.Id;
            caseSub.Subscription__c = subRec.Id;
            insert caseSub;    
            
            System.assertEquals(acnt.Id, caseSub.Account__c);
            */
            
            /*
try{    
subRec.Vendor_1__c = NULL;
update subRec;
//subRec2.Vendor_1__c = NULL;
//update subRec2;   
}   
catch (Exception e){
Boolean expectedExceptionThrown =  e.getMessage().contains('Vendor cannot be empty.') ? true : false;
//System.AssertEquals(expectedExceptionThrown, true);
}
*/
            
            subRec.Zuora__Status__c = 'Cancelled'; // [JPO 2/13] Made 'Active' From ''
            subRec.Zuora__SubscriptionStartDate__c = Date.today().addMonths(-Integer.valueOf(subRec.Term_Length__c));
            subRec.Zuora__SubscriptionEndDate__c = Date.today();
            //update subRec;
            //subRec2.Zuora__Status__c = 'Active';
            //update subRec2;
            //subRec3.Zuora__Status__c = 'Active';
            //update subRec3;
            
            //update            
            SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = false;
            SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = false;   
            //subRec.Vendor_1__c = acctVendor.Id; 
            //subRec.Vendor__c = acctVendor.Id;
            // System.assertEquals(null, acctVendor.Id);    
            subRec.Vendor__c = acctVendor.Id+'';
           // update subRec; // venor cdannot be empty error
            
            SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
            handler.runBeforeUpdateTrigger();
            handler.runAfterUpdateTrigger();
            //TEST: if 
            
            handler.runBeforeInsertTrigger();
            handler.runBeforeDeleteTrigger();
            handler.runAfterInsertTrigger();
            handler.runAfterDeleteTrigger();
            
            
            
            test.stoptest();    
        }
    }
    
    static testMethod void testMethod5() {
        User usr = createUser();
    
        //The test will run as the user created.
        System.runAs(usr) {
            //setUpTestData();
            List<RecordType> recList = new List<RecordType>();
            recList = [Select id, name from Recordtype Where SobjectType = 'Package_Item__c' AND Name = 'Bundle Product'];
            
            Key_Id__c keyID = new Key_Id__c();
            keyID.Id__c = recList[0].id;
            keyID.Name = 'Package Item_Bundle Product';
            keyID.Type__c = 'RecordType';
            insert keyID;
            
            System.debug('@@@' + keyID.Id__c);
            System.debug('@@@' + recList[0].name);
            
            
            List<Billing_Batch__c> billBatches = new List<Billing_Batch__c>();
            billBatches = CustomSettingsDataFactory.createBillingBatch();
            insert billBatches;
            Singpost_Address__c postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
    
            Address__c address = new Address__c();
            address = TestDataFactory.createAddress(1)[0];
            address.Postal_Code__c = postal.Id;
            insert address;
    
    
            packge = TestDataFactory.createPackage(1)[0];
            packge.Billing_Type__c = 'Full Prepaid';
            packge.Package_Type__c = 'Bundle';
            packge.Subscription_Period__c = '1';
            packge.Package_Code__c = 'STSU';
            packge.Product_Family_Current_Package__c = 'test';
            insert packge;
            
            //Setup zqu__ZProduct__c records
            zProducts = TestDataFactory.createZProduct(1)[0];
            zProducts.ProductSubType__c = 'Magazine';
            zProducts.zqu__ZuoraId__c = 'Test';
            insert zProducts ;
            
            //Setup zqu__ProductRatePlan__c records
            prodRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
            prodRatePlan.zqu__ZProduct__c = zProducts.Id;
            prodRatePlan.RatePlanType__c= 'Bill Plan';
            prodRatePlan.zqu__EffectiveStartDate__c= date.today();
            prodRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prodRatePlan.zqu__Deleted__c = false;
            prodRatePlan.zqu__ZuoraId__c = 'Test';
            insert prodRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prodRatePlan.id;
            insert prpc;
            
            zqu__ProductRatePlanChargeTier__c prpcTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
            prpcTier.zqu__ProductRatePlanCharge__c = prpc.id;
            prpcTier.zqu__Price__c = 1;
            insert prpcTier;
            
            //Setup Product_Family__c records
            prodFamily = new Product_Family__c();
            prodFamily.Product_Family__c = 'Trythis';
            prodFamily.Product_Family_Name__c = 'testtest';
            insert prodFamily;
            
            //Setup Package Item records
            packageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            packageItem.Package__c = packge.id;
            packageItem.Product_Rate_Plan__c = prodRatePlan.id;
            packageItem.Name = 'Test Pack Item';
            packageItem.Product_Family__c = prodFamily.Id;
            packageItem.RecordTypeId = keyID.Id__c;
            insert packageItem;
            System.debug('@@@' + packageItem.RecordType.Name);
    
            Account acct = new Account();
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.NRIC__c = 'T1234567R';
            insert acct;
    
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
            insert acctVendor;
    
            Account acct2 = new Account();
            acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct2.NRIC__c = 'T1234567R';
            insert acct2;
    
            Contact con = new Contact();
            con = TestDataFactory.createContact(1)[0];
            con.AccountId = acct.Id;
            con.Address__c = address.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
    
            //create order
            List<Order__c> order = TestDataFactory.createOrder(2);
            order[0].Account__c = acct.Id;
            order[0].Recipient_Contact__c = con.Id;
            order[0].Informed_Customer__c = True;
            order[0].Acquisition_Type__c = 'Call';
            order[1].Account__c = acct.Id;
            order[1].Recipient_Contact__c = con.Id;
            order[1].Informed_Customer__c = True;
            order[1].Acquisition_Type__c = 'Call';
            insert order;
    
            //create case
            List<Case> cas = TestDataFactory.createCase(5, 'Complaint - Magazine');
            cas[0].Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
            cas[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            cas[0].Order__c = order[0].Id;
            cas[1].Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            cas[1].RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas[1].Order__c = order[0].Id;
            cas[2].Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            cas[2].RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas[2].Order__c = order[1].Id;
            cas[2].Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas[2].Status = 'Pending';
            cas[3].Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
            cas[3].RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            cas[4].Sub_Category__c = GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION;
            cas[4].RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Subscription');
            cas[4].Order__c = order[1].Id;
            cas[4].Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas[4].Status = 'Pending';
    
            insert cas;
    
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order[0].Id;
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = packge.Id;
            orderline.Term_Length__c = 1;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+5;
            orderline.Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline.Vendor_Mailing_Agent__c = null;
            orderline.Subscription_Name__c ='test name';
            orderline.Is_Digital__c = false;
    
            insert orderline;
    
            //WAK 04/15/2016
            Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = con.id);        
            insert asiaOneRecord;
            System.debug('***wendy : inserted asiaOneRecord');
    
            Service_Access_Flag__c saf = new Service_Access_Flag__c();
            saf.Name = 'test name';
            insert saf;
            System.debug('***wendy : inserted saf');
    
            Asia1_Subscription__c tmp = new Asia1_Subscription__c();
            tmp.Asia1__c = asiaOneRecord.id;
            tmp.Order_Line_Item__c = orderline.id;
            tmp.Service_Access_Flag__c = saf.id;
            tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
            insert tmp; 
            System.debug('***wendy : inserted tmp');
    
            //create subscription vendor
            Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            insert SubVend;
            System.debug('***wendy : inserted tmp');
    
            Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
            zua.Zuora__Account__c = acct.Id;
            zua.Zuora__DefaultPaymentMethod__c = 'Other';
            insert zua; 
            System.debug('***wendy : inserted zua');
    
    
            Zuora__CustomerAccount__c zua2 =  TestDataFactory.createBillingAccount(1)[0];
            zua2.Zuora__Account__c = acct.Id;
            zua2.Zuora__DefaultPaymentMethod__c = 'Other';
            insert zua2; 
            
            Letter_Print_Request__c lpr = new Letter_Print_Request__c();
            lpr.Letter_Type__c = GlobalVariableClass.LETTER_TYPE_ACK;
            lpr.Record_ID__c = zua.Id;
            insert lpr;
            
            List<Zuora__PaymentMethod__c> paymentMethodList = TestDataFactory.createPaymentMethod(2);
            paymentMethodList[0].Zuora__Type__c = 'CreditCard';
            paymentMethodList[0].Zuora__BillingAccount__c = zua.Id;
            paymentMethodList[1].Zuora__Type__c = 'CreditCard';
            paymentMethodList[1].Zuora__BillingAccount__c = zua2.Id;
            insert paymentMethodList;
            
            zua.Zuora__Default_Payment_Method__c = paymentMethodList[0].Id;
            update zua;
            system.debug('>>>>>zua ' + zua.Zuora__Default_Payment_Method__c);
            system.debug('>>>>>zua ' + zua.Zuora__Default_Payment_Method__r.Zuora__Type__c);
            system.debug('>>>>>zua ' + zua.Zuora__PaymentMethod_Type__c);
            zua2.Zuora__Default_Payment_Method__c = paymentMethodList[0].Id;
            update zua2;
            System.debug('***wendy : inserted zua2');

            test.startTest();
            List<Zuora__Subscription__c> relSub = new List<Zuora__Subscription__c>();
            relSub = TestDataFactory.createSubscription(3);
            relSub[0].Zuora__AutoRenew__c = true;
            relSub[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[0].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[0].Zuora__Account__c = acct.Id;
            relSub[0].Order_Number__c = order[0].Id;
            relSub[0].Subscriber_Contact__c = con.Id;
            relSub[0].Recipient_Contact__c = con.Id;
            relSub[0].Recipient_Contact_1__c = con.Id;
            relSub[0].Main_Package_1__c = packge.id;
            relSub[0].Zuora__Status__c = 'Active';
            relSub[0].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[0].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[0].Urgent__c = 'false';
            relSub[0].Vendor_Conversion__c = 'false';
            relSub[0].Charity__c = 'false';
            relSub[0].Order_Line_Item_Number__c = orderline.Id;
            //relSub[0].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[0].Vendor_1__c = acctVendor.id;
            relSub[0].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[0].Zuora__Zuora_Id__c = '111111';
            relSub[0].Term_Length__c = 12;
            relSub[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub[0].Zuora__SubscriptionEndDate__c = relSub[0].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[0].Term_Length__c)).addDays(-1);
            relSub[0].Zuora__Version__c = 1;
            relSub[0].Zuora__TermSettingType__c = 'TERMED';
            relSub[1].Zuora__AutoRenew__c = true;
            relSub[1].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[1].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[1].Zuora__Account__c = acct.Id;
            relSub[1].Order_Number__c = order[0].Id;
            relSub[1].Subscriber_Contact__c = con.Id;
            relSub[1].Recipient_Contact__c = con.Id;
            relSub[1].Recipient_Contact_1__c = con.Id;
            relSub[1].Main_Package_1__c = packge.id;
            relSub[1].Zuora__Status__c = 'Cancelled';
            relSub[1].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[1].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[1].Urgent__c = 'false';
            relSub[1].Vendor_Conversion__c = 'false';
            relSub[1].Charity__c = 'false';
            relSub[1].Order_Line_Item_Number__c = orderline.Id;
            //relSub[1].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[1].Vendor_1__c = acctVendor.id;
            relSub[1].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[1].Zuora__Zuora_Id__c = '111111';
            relSub[1].Term_Length__c = 12;
            relSub[1].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub[1].Zuora__SubscriptionEndDate__c = relSub[1].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[1].Term_Length__c));
            relSub[1].Zuora__Version__c = 2;
            relSub[2].Zuora__AutoRenew__c = true;
            relSub[2].Subscription_Type__c = 'Postage';
            relSub[2].Subscription_Type_1__c =  'Postage';
            relSub[2].Zuora__Account__c = acct.Id;
            relSub[2].Order_Number__c = order[0].Id;
            relSub[2].Subscriber_Contact__c = con.Id;
            relSub[2].Recipient_Contact__c = con.Id;
            relSub[2].Recipient_Contact_1__c = con.Id;
            relSub[2].Main_Package_1__c = packge.id;
            relSub[2].Zuora__Status__c = 'Cancelled';
            relSub[2].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[2].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[2].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[2].Urgent__c = 'false';
            relSub[2].Vendor_Conversion__c = 'false';
            relSub[2].Charity__c = 'false';
            relSub[2].Order_Line_Item_Number__c = orderline.Id;
            //relSub[2].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[2].Vendor_1__c = acctVendor.id;
            relSub[2].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[2].Zuora__Zuora_Id__c = '111111';
            relSub[2].Term_Length__c = 12;
            relSub[2].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub[2].Zuora__SubscriptionEndDate__c = relSub[2].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[2].Term_Length__c));
            relSub[2].Zuora__Version__c = 2;
            relSub[2].Legacy_Subscription_ID__c = '12345';
            insert relSub;
            
            order[0].Base_Subscription__c = relSub[0].Id;
            update order[0];
            
            orderline.Subscription_Name__c = relSub[0].Name;
            orderline.Case__c = cas[0].Id;
            update orderline;
            
            List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(3);
            orderline1[0].Order__c = order[0].Id;
            orderline1[0].End_Date__c = date.today()+30;
            orderline1[0].Main_Package_ID__c = packge.Id;
            orderline1[0].Term_Length__c = 1;
            orderline1[0].Main_Package_Period__c = 0;
            orderline1[0].Earliest_Start_Date__c = date.today();
            orderline1[0].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[0].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[0].Terminating_Reason__c = 'Others';
            orderline1[0].Amount_To_Refund__c = 0;
            orderline1[0].Admin_Charge__c = 0;
            orderline1[0].Fee_Waiver__c = TRUE;
            orderline1[0].Fee_Override__c = TRUE;
            orderline1[0].Override_Reason__c = 'TEST';
            orderline1[0].Suppress_Notification_Stop__c = TRUE;
            orderline1[0].Main_Package_Type__c = 'Base';
            orderline1[0].Start_Date__c = date.today()+5;
            orderline1[0].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[0].Vendor_Mailing_Agent__c = null;
            orderline1[0].Subscription_Name__c = relSub[1].Name;
            orderline1[0].Is_Digital__c = false;
            orderline1[1].Order__c = order[0].Id;
            orderline1[1].End_Date__c = date.today()+30;
            orderline1[1].Main_Package_ID__c = packge.Id;
            orderline1[1].Term_Length__c = 1;
            orderline1[1].Main_Package_Period__c = 0;
            orderline1[1].Earliest_Start_Date__c = date.today();
            orderline1[1].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[1].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[1].Terminating_Reason__c = 'Others';
            orderline1[1].Amount_To_Refund__c = 0;
            orderline1[1].Admin_Charge__c = 0;
            orderline1[1].Fee_Waiver__c = TRUE;
            orderline1[1].Fee_Override__c = TRUE;
            orderline1[1].Override_Reason__c = 'TEST';
            orderline1[1].Suppress_Notification_Stop__c = TRUE;
            orderline1[1].Main_Package_Type__c = 'Base';
            orderline1[1].Start_Date__c = date.today()+5;
            orderline1[1].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[1].Vendor_Mailing_Agent__c = null;
            orderline1[1].Subscription_Name__c = relSub[1].Name;
            orderline1[1].Is_Digital__c = false;
            orderline1[1].Case__c = cas[2].Id;
            orderline1[1].Subscription__c = relSub[0].Id;
            orderline1[2].Order__c = order[0].Id;
            orderline1[2].End_Date__c = date.today()+30;
            orderline1[2].Main_Package_ID__c = packge.Id;
            orderline1[2].Term_Length__c = 1;
            orderline1[2].Main_Package_Period__c = 0;
            orderline1[2].Earliest_Start_Date__c = date.today();
            orderline1[2].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[2].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[2].Terminating_Reason__c = 'Others';
            orderline1[2].Amount_To_Refund__c = 0;
            orderline1[2].Admin_Charge__c = 0;
            orderline1[2].Fee_Waiver__c = TRUE;
            orderline1[2].Fee_Override__c = TRUE;
            orderline1[2].Override_Reason__c = 'TEST';
            orderline1[2].Suppress_Notification_Stop__c = TRUE;
            orderline1[2].Main_Package_Type__c = 'Base';
            orderline1[2].Start_Date__c = date.today()+5;
            orderline1[2].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[2].Vendor_Mailing_Agent__c = null;
            orderline1[2].Subscription_Name__c = relSub[2].Name;
            orderline1[2].Is_Digital__c = false;
            orderline1[2].Case__c = cas[4].Id;
            orderline1[2].Subscription__c = relSub[0].Id;
    
            insert orderline1;
            
            relSub[0].Zuora__CustomerAccount__c = zua2.id;
            update relSub[0];
            
            test.stopTest(); 
            /*
            List<Zuora__Subscription__c> relSub1 = TestDataFactory.createSubscription(1);
            relSub1[0].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub1[0].Subscription_Type__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub1[0].Zuora__Zuora_Id__c = '222222';
            relSub1[0].Recipient_Contact__c = null;
            relSub1[0].Name = 'test name';
            relSub1[0].Zuora__Account__c = acct.Id;        
            relSub1[0].Order_Number__c = order.Id;
            relSub1[0].Subscriber_Contact__c = con.Id;
            relSub1[0].Vendor_Subscription_To_Convert_1__c = SubVend.Id;
            relSub1[0].Subscription_Charge__c = null;
            relSub1[0].Main_Package_1__c = packge.id;
            relSub1[0].Zuora__Status__c = GlobalVariableClass.STATUS_ACTIVE;
            relSub1[0].Suppress_Vendor_Start_Notice__c = 'false';
            relSub1[0].Supressed_Acknowledgement_Letter__c = 'false';
            relSub1[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub1[0].Urgent__c = 'false';
            relSub1[0].Vendor_Conversion__c = 'false';
            relSub1[0].Charity__c = 'false';
            relSub1[0].Order_Line_Item_Number__c = orderline.Id;
            //relSub1[0].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub1[0].Vendor_1__c = acctVendor.id;
            relSub1[0].Zuora__CustomerAccount__c = zua.id;
            //relSub1[1].Order_Number_1__c = order2.id;
            relSub1[0].Vendor__c = acctVendor.Id+'';
            relSub1[0].Zuora__AutoRenew__c = true;
            relSub1[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
            relSub1[0].Payment_Mode__c = 'Other';
            relSub1[0].Other_PaymentMethod__c = 'Freelist';
            relSub1[0].Order_Line_Item_Number_1__c = orderline.Id;
            relSub1[0].Zuora__Version__c = 1;
            relSub1[0].Term_Length__c = 12;
            relSub1[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub1[0].Zuora__SubscriptionEndDate__c = relSub1[0].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub1[0].Term_Length__c)).addDays(-1);
            relSub1[0].Related_Subscription__c = '222222';
            insert relSub1[0];
            
            Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
            temp.Temp_Stop_Date__c = relSub1[0].Zuora__SubscriptionStartDate__c.addMonths(1).toStartOfMonth();
            temp.Restart_Date__c = temp.Temp_Stop_Date__c.addDays(10);
            temp.Qty__c = 1;
            //temp.Cancelled__c  = true;
            database.insert(temp);
            
            Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
            subTemp.Temp_Stop__c = temp.Id;
            subTemp.Subscription__c = relSub1[0].Id; 
            database.insert(subTemp);
            
            Address_Assignment__c addAss = new Address_Assignment__c();
            addAss.Active__c = false;
            addAss.Effective_Date__c = date.today().addMonths(2).toStartOfMonth();
            addAss.Subscription__c = relSub1[0].Id;
            addAss.Address__c = address.Id;
            addAss.Contact__c = con.Id;
            insert addAss;
            */
        }
    }
    
   static testMethod void testMethod6() {
        User usr = createUser();
    
        //The test will run as the user created.
        System.runAs(usr) {
            //setUpTestData();
            List<RecordType> recList = new List<RecordType>();
            recList = [Select id, name from Recordtype Where SobjectType = 'Package_Item__c' AND Name = 'Bundle Product'];
            
            Key_Id__c keyID = new Key_Id__c();
            keyID.Id__c = recList[0].id;
            keyID.Name = 'Package Item_Bundle Product';
            keyID.Type__c = 'RecordType';
            insert keyID;
            
            System.debug('@@@' + keyID.Id__c);
            System.debug('@@@' + recList[0].name);
            
            
            List<Billing_Batch__c> billBatches = new List<Billing_Batch__c>();
            billBatches = CustomSettingsDataFactory.createBillingBatch();
            insert billBatches;
            Singpost_Address__c postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
    
            Address__c address = new Address__c();
            address = TestDataFactory.createAddress(1)[0];
            address.Postal_Code__c = postal.Id;
            insert address;
    
    
            packge = TestDataFactory.createPackage(1)[0];
            packge.Billing_Type__c = 'Full Prepaid';
            packge.Package_Type__c = 'Bundle';
            packge.Subscription_Period__c = '1';
            packge.Package_Code__c = 'STSU';
            packge.Product_Family_Current_Package__c = 'test';
            insert packge;
            
            //Setup zqu__ZProduct__c records
            zProducts = TestDataFactory.createZProduct(1)[0];
            zProducts.ProductSubType__c = 'Magazine';
            zProducts.zqu__ZuoraId__c = 'Test';
            insert zProducts ;
            
            //Setup zqu__ProductRatePlan__c records
            prodRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
            prodRatePlan.zqu__ZProduct__c = zProducts.Id;
            prodRatePlan.RatePlanType__c= 'Bill Plan';
            prodRatePlan.zqu__EffectiveStartDate__c= date.today();
            prodRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prodRatePlan.zqu__Deleted__c = false;
            prodRatePlan.zqu__ZuoraId__c = 'Test';
            insert prodRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prodRatePlan.id;
            insert prpc;
            
            zqu__ProductRatePlanChargeTier__c prpcTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
            prpcTier.zqu__ProductRatePlanCharge__c = prpc.id;
            prpcTier.zqu__Price__c = 1;
            insert prpcTier;
            
            //Setup Product_Family__c records
            prodFamily = new Product_Family__c();
            prodFamily.Product_Family__c = 'Trythis';
            prodFamily.Product_Family_Name__c = 'testtest';
            insert prodFamily;
            
            //Setup Package Item records
            packageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            packageItem.Package__c = packge.id;
            packageItem.Product_Rate_Plan__c = prodRatePlan.id;
            packageItem.Name = 'Test Pack Item';
            packageItem.Product_Family__c = prodFamily.Id;
            packageItem.RecordTypeId = keyID.Id__c;
            insert packageItem;
            System.debug('@@@' + packageItem.RecordType.Name);
    
            Account acct = new Account();
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.NRIC__c = 'T1234567R';
            insert acct;
    
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
            insert acctVendor;
    
            Account acct2 = new Account();
            acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct2.NRIC__c = 'T1234567R';
            insert acct2;
    
            Contact con = new Contact();
            con = TestDataFactory.createContact(1)[0];
            con.AccountId = acct.Id;
            con.Address__c = address.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
    
            //create order
            List<Order__c> order = TestDataFactory.createOrder(2);
            order[0].Account__c = acct.Id;
            order[0].Recipient_Contact__c = con.Id;
            order[0].Informed_Customer__c = True;
            order[0].Acquisition_Type__c = 'Call';
            order[1].Account__c = acct.Id;
            order[1].Recipient_Contact__c = con.Id;
            order[1].Informed_Customer__c = True;
            order[1].Acquisition_Type__c = 'Call';
            insert order;
    
            //create case
            List<Case> cas = TestDataFactory.createCase(5, 'Complaint - Magazine');
            cas[0].Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
            cas[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            cas[0].Order__c = order[0].Id;
            cas[1].Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            cas[1].RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas[1].Order__c = order[0].Id;
            cas[2].Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            cas[2].RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas[2].Order__c = order[1].Id;
            cas[2].Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas[2].Status = 'Pending';
            cas[3].Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
            cas[3].RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            cas[4].Sub_Category__c = GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION;
            cas[4].RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Subscription');
            cas[4].Order__c = order[1].Id;
            cas[4].Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas[4].Status = 'Pending';
    
            insert cas;
    
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order[0].Id;
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = packge.Id;
            orderline.Term_Length__c = 1;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+5;
            orderline.Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline.Vendor_Mailing_Agent__c = null;
            orderline.Subscription_Name__c ='test name';
            orderline.Is_Digital__c = false;
    
            insert orderline;
    
            //WAK 04/15/2016
            Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = con.id);        
            insert asiaOneRecord;
            System.debug('***wendy : inserted asiaOneRecord');
    
            Service_Access_Flag__c saf = new Service_Access_Flag__c();
            saf.Name = 'test name';
            insert saf;
            System.debug('***wendy : inserted saf');
    
            Asia1_Subscription__c tmp = new Asia1_Subscription__c();
            tmp.Asia1__c = asiaOneRecord.id;
            tmp.Order_Line_Item__c = orderline.id;
            tmp.Service_Access_Flag__c = saf.id;
            tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
            insert tmp; 
            System.debug('***wendy : inserted tmp');
    
            //create subscription vendor
            Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            insert SubVend;
            System.debug('***wendy : inserted tmp');
    
            Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
            zua.Zuora__Account__c = acct.Id;
            zua.Zuora__DefaultPaymentMethod__c = 'Other';
            insert zua; 
            System.debug('***wendy : inserted zua');
    
    
            Zuora__CustomerAccount__c zua2 =  TestDataFactory.createBillingAccount(1)[0];
            zua2.Zuora__Account__c = acct.Id;
            zua2.Zuora__DefaultPaymentMethod__c = 'Other';
            insert zua2; 
            
            Letter_Print_Request__c lpr = new Letter_Print_Request__c();
            lpr.Letter_Type__c = GlobalVariableClass.LETTER_TYPE_ACK;
            lpr.Record_ID__c = zua.Id;
            insert lpr;
            
            List<Zuora__PaymentMethod__c> paymentMethodList = TestDataFactory.createPaymentMethod(2);
            paymentMethodList[0].Zuora__Type__c = 'CreditCard';
            paymentMethodList[0].Zuora__BillingAccount__c = zua.Id;
            paymentMethodList[1].Zuora__Type__c = 'CreditCard';
            paymentMethodList[1].Zuora__BillingAccount__c = zua2.Id;
            insert paymentMethodList;
            
            zua.Zuora__Default_Payment_Method__c = paymentMethodList[0].Id;
            update zua;
            system.debug('>>>>>zua ' + zua.Zuora__Default_Payment_Method__c);
            system.debug('>>>>>zua ' + zua.Zuora__Default_Payment_Method__r.Zuora__Type__c);
            system.debug('>>>>>zua ' + zua.Zuora__PaymentMethod_Type__c);
            zua2.Zuora__Default_Payment_Method__c = paymentMethodList[0].Id;
            update zua2;
            System.debug('***wendy : inserted zua2');

            test.startTest();
            List<Zuora__Subscription__c> relSub = new List<Zuora__Subscription__c>();
            relSub = TestDataFactory.createSubscription(3);
            relSub[0].Zuora__AutoRenew__c = true;
            relSub[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[0].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[0].Zuora__Account__c = acct.Id;
            relSub[0].Order_Number__c = order[0].Id;
            relSub[0].Subscriber_Contact__c = con.Id;
            relSub[0].Recipient_Contact__c = con.Id;
            relSub[0].Recipient_Contact_1__c = con.Id;
            relSub[0].Main_Package_1__c = packge.id;
            relSub[0].Zuora__Status__c = 'Active';
            relSub[0].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[0].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[0].Urgent__c = 'false';
            relSub[0].Vendor_Conversion__c = 'false';
            relSub[0].Charity__c = 'false';
            relSub[0].Order_Line_Item_Number__c = orderline.Id;
            //relSub[0].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[0].Vendor_1__c = acctVendor.id;
            relSub[0].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[0].Zuora__Zuora_Id__c = '111111';
            relSub[0].Term_Length__c = 12;
            relSub[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub[0].Zuora__SubscriptionEndDate__c = relSub[0].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[0].Term_Length__c)).addDays(-1);
            relSub[0].Zuora__Version__c = 1;
            relSub[0].Zuora__TermSettingType__c = 'TERMED';
            relSub[1].Zuora__AutoRenew__c = true;
            relSub[1].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[1].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[1].Zuora__Account__c = acct.Id;
            relSub[1].Order_Number__c = order[0].Id;
            relSub[1].Subscriber_Contact__c = con.Id;
            relSub[1].Recipient_Contact__c = con.Id;
            relSub[1].Recipient_Contact_1__c = con.Id;
            relSub[1].Main_Package_1__c = packge.id;
            relSub[1].Zuora__Status__c = 'Cancelled';
            relSub[1].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[1].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[1].Urgent__c = 'false';
            relSub[1].Vendor_Conversion__c = 'false';
            relSub[1].Charity__c = 'false';
            relSub[1].Order_Line_Item_Number__c = orderline.Id;
            //relSub[1].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[1].Vendor_1__c = acctVendor.id;
            relSub[1].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[1].Zuora__Zuora_Id__c = '111111';
            relSub[1].Term_Length__c = 12;
            relSub[1].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub[1].Zuora__SubscriptionEndDate__c = relSub[1].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[1].Term_Length__c));
            relSub[1].Zuora__TermSettingType__c = 'TERMED';
            relSub[1].Zuora__Version__c = 2;
            relSub[2].Zuora__AutoRenew__c = true;
            relSub[2].Subscription_Type__c = 'Delivery';
            relSub[2].Subscription_Type_1__c =  'Delivery';
            relSub[2].Zuora__Account__c = acct.Id;
            relSub[2].Order_Number__c = order[0].Id;
            relSub[2].Subscriber_Contact__c = con.Id;
            relSub[2].Recipient_Contact__c = con.Id;
            relSub[2].Recipient_Contact_1__c = con.Id;
            relSub[2].Main_Package_1__c = packge.id;
            relSub[2].Zuora__Status__c = 'Cancelled';
            relSub[2].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[2].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[2].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[2].Urgent__c = 'false';
            relSub[2].Vendor_Conversion__c = 'false';
            relSub[2].Charity__c = 'false';
            relSub[2].Order_Line_Item_Number__c = orderline.Id;
            relSub[2].Zuora__TermSettingType__c = 'TERMED';
            //relSub[2].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[2].Vendor_1__c = acctVendor.id;
            relSub[2].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[2].Zuora__Zuora_Id__c = '111111';
            relSub[2].Term_Length__c = 12;
            relSub[2].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub[2].Zuora__SubscriptionEndDate__c = relSub[2].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[2].Term_Length__c));
            relSub[2].Zuora__Version__c = 2;
            relSub[2].Legacy_Subscription_ID__c = '12345';
            insert relSub;
            
            order[0].Base_Subscription__c = relSub[0].Id;
            update order[0];
            
            orderline.Subscription_Name__c = relSub[0].Name;
            orderline.Case__c = cas[0].Id;
            update orderline;
            
            List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(3);
            orderline1[0].Order__c = order[0].Id;
            orderline1[0].End_Date__c = date.today()+30;
            orderline1[0].Main_Package_ID__c = packge.Id;
            orderline1[0].Term_Length__c = 1;
            orderline1[0].Main_Package_Period__c = 0;
            orderline1[0].Earliest_Start_Date__c = date.today();
            orderline1[0].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[0].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[0].Terminating_Reason__c = 'Others';
            orderline1[0].Amount_To_Refund__c = 0;
            orderline1[0].Admin_Charge__c = 0;
            orderline1[0].Fee_Waiver__c = TRUE;
            orderline1[0].Fee_Override__c = TRUE;
            orderline1[0].Override_Reason__c = 'TEST';
            orderline1[0].Suppress_Notification_Stop__c = TRUE;
            orderline1[0].Main_Package_Type__c = 'Base';
            orderline1[0].Start_Date__c = date.today()+5;
            orderline1[0].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[0].Vendor_Mailing_Agent__c = null;
            orderline1[0].Subscription_Name__c = relSub[1].Name;
            orderline1[0].Is_Digital__c = false;
            orderline1[1].Order__c = order[0].Id;
            orderline1[1].End_Date__c = date.today()+30;
            orderline1[1].Main_Package_ID__c = packge.Id;
            orderline1[1].Term_Length__c = 1;
            orderline1[1].Main_Package_Period__c = 0;
            orderline1[1].Earliest_Start_Date__c = date.today();
            orderline1[1].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[1].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[1].Terminating_Reason__c = 'Others';
            orderline1[1].Amount_To_Refund__c = 0;
            orderline1[1].Admin_Charge__c = 0;
            orderline1[1].Fee_Waiver__c = TRUE;
            orderline1[1].Fee_Override__c = TRUE;
            orderline1[1].Override_Reason__c = 'TEST';
            orderline1[1].Suppress_Notification_Stop__c = TRUE;
            orderline1[1].Main_Package_Type__c = 'Base';
            orderline1[1].Start_Date__c = date.today()+5;
            orderline1[1].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[1].Vendor_Mailing_Agent__c = null;
            orderline1[1].Subscription_Name__c = relSub[1].Name;
            orderline1[1].Is_Digital__c = false;
            orderline1[1].Case__c = cas[2].Id;
            orderline1[1].Subscription__c = relSub[0].Id;
            orderline1[2].Order__c = order[0].Id;
            orderline1[2].End_Date__c = date.today()+30;
            orderline1[2].Main_Package_ID__c = packge.Id;
            orderline1[2].Term_Length__c = 1;
            orderline1[2].Main_Package_Period__c = 0;
            orderline1[2].Earliest_Start_Date__c = date.today();
            orderline1[2].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[2].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[2].Terminating_Reason__c = 'Others';
            orderline1[2].Amount_To_Refund__c = 0;
            orderline1[2].Admin_Charge__c = 0;
            orderline1[2].Fee_Waiver__c = TRUE;
            orderline1[2].Fee_Override__c = TRUE;
            orderline1[2].Override_Reason__c = 'TEST';
            orderline1[2].Suppress_Notification_Stop__c = TRUE;
            orderline1[2].Main_Package_Type__c = 'Base';
            orderline1[2].Start_Date__c = date.today()+5;
            orderline1[2].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[2].Vendor_Mailing_Agent__c = null;
            orderline1[2].Subscription_Name__c = relSub[2].Name;
            orderline1[2].Is_Digital__c = false;
            orderline1[2].Case__c = cas[4].Id;
            orderline1[2].Subscription__c = relSub[0].Id;
    
            insert orderline1;
            
            relSub[0].Zuora__CustomerAccount__c = zua2.id;
            update relSub[0];
            
            test.stopTest(); 
            /*
            List<Zuora__Subscription__c> relSub1 = TestDataFactory.createSubscription(1);
            relSub1[0].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub1[0].Subscription_Type__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub1[0].Zuora__Zuora_Id__c = '222222';
            relSub1[0].Recipient_Contact__c = null;
            relSub1[0].Name = 'test name';
            relSub1[0].Zuora__Account__c = acct.Id;        
            relSub1[0].Order_Number__c = order.Id;
            relSub1[0].Subscriber_Contact__c = con.Id;
            relSub1[0].Vendor_Subscription_To_Convert_1__c = SubVend.Id;
            relSub1[0].Subscription_Charge__c = null;
            relSub1[0].Main_Package_1__c = packge.id;
            relSub1[0].Zuora__Status__c = GlobalVariableClass.STATUS_ACTIVE;
            relSub1[0].Suppress_Vendor_Start_Notice__c = 'false';
            relSub1[0].Supressed_Acknowledgement_Letter__c = 'false';
            relSub1[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub1[0].Urgent__c = 'false';
            relSub1[0].Vendor_Conversion__c = 'false';
            relSub1[0].Charity__c = 'false';
            relSub1[0].Order_Line_Item_Number__c = orderline.Id;
            //relSub1[0].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub1[0].Vendor_1__c = acctVendor.id;
            relSub1[0].Zuora__CustomerAccount__c = zua.id;
            //relSub1[1].Order_Number_1__c = order2.id;
            relSub1[0].Vendor__c = acctVendor.Id+'';
            relSub1[0].Zuora__AutoRenew__c = true;
            relSub1[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
            relSub1[0].Payment_Mode__c = 'Other';
            relSub1[0].Other_PaymentMethod__c = 'Freelist';
            relSub1[0].Order_Line_Item_Number_1__c = orderline.Id;
            relSub1[0].Zuora__Version__c = 1;
            relSub1[0].Term_Length__c = 12;
            relSub1[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub1[0].Zuora__SubscriptionEndDate__c = relSub1[0].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub1[0].Term_Length__c)).addDays(-1);
            relSub1[0].Related_Subscription__c = '222222';
            insert relSub1[0];
            
            Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
            temp.Temp_Stop_Date__c = relSub1[0].Zuora__SubscriptionStartDate__c.addMonths(1).toStartOfMonth();
            temp.Restart_Date__c = temp.Temp_Stop_Date__c.addDays(10);
            temp.Qty__c = 1;
            //temp.Cancelled__c  = true;
            database.insert(temp);
            
            Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
            subTemp.Temp_Stop__c = temp.Id;
            subTemp.Subscription__c = relSub1[0].Id; 
            database.insert(subTemp);
            
            Address_Assignment__c addAss = new Address_Assignment__c();
            addAss.Active__c = false;
            addAss.Effective_Date__c = date.today().addMonths(2).toStartOfMonth();
            addAss.Subscription__c = relSub1[0].Id;
            addAss.Address__c = address.Id;
            addAss.Contact__c = con.Id;
            insert addAss;
            */
        }
    }

   static testMethod void testMethod7() {
        User usr = createUser();
    
        //The test will run as the user created.
        System.runAs(usr) {
            //setUpTestData();
            List<RecordType> recList = new List<RecordType>();
            recList = [Select id, name from Recordtype Where SobjectType = 'Package_Item__c' AND Name = 'Bundle Product'];
            
            Key_Id__c keyID = new Key_Id__c();
            keyID.Id__c = recList[0].id;
            keyID.Name = 'Package Item_Bundle Product';
            keyID.Type__c = 'RecordType';
            insert keyID;
            
            System.debug('@@@' + keyID.Id__c);
            System.debug('@@@' + recList[0].name);
            
            
            List<Billing_Batch__c> billBatches = new List<Billing_Batch__c>();
            billBatches = CustomSettingsDataFactory.createBillingBatch();
            insert billBatches;
            Singpost_Address__c postal = new Singpost_Address__c();
            postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
    
            Address__c address = new Address__c();
            address = TestDataFactory.createAddress(1)[0];
            address.Postal_Code__c = postal.Id;
            insert address;
    
    
            packge = TestDataFactory.createPackage(1)[0];
            packge.Billing_Type__c = 'Full Prepaid';
            packge.Package_Type__c = 'Bundle';
            packge.Subscription_Period__c = '1';
            packge.Package_Code__c = 'STSU';
            packge.Product_Family_Current_Package__c = 'test';
            insert packge;
            
            //Setup zqu__ZProduct__c records
            zProducts = TestDataFactory.createZProduct(1)[0];
            zProducts.ProductSubType__c = 'Magazine';
            zProducts.zqu__ZuoraId__c = 'Test';
            insert zProducts ;
            
            //Setup zqu__ProductRatePlan__c records
            prodRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
            prodRatePlan.zqu__ZProduct__c = zProducts.Id;
            prodRatePlan.RatePlanType__c= 'Bill Plan';
            prodRatePlan.zqu__EffectiveStartDate__c= date.today();
            prodRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prodRatePlan.zqu__Deleted__c = false;
            prodRatePlan.zqu__ZuoraId__c = 'Test';
            insert prodRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prodRatePlan.id;
            insert prpc;
            
            zqu__ProductRatePlanChargeTier__c prpcTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
            prpcTier.zqu__ProductRatePlanCharge__c = prpc.id;
            prpcTier.zqu__Price__c = 1;
            insert prpcTier;
            
            //Setup Product_Family__c records
            prodFamily = new Product_Family__c();
            prodFamily.Product_Family__c = 'Trythis';
            prodFamily.Product_Family_Name__c = 'testtest';
            insert prodFamily;
            
            //Setup Package Item records
            packageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            packageItem.Package__c = packge.id;
            packageItem.Product_Rate_Plan__c = prodRatePlan.id;
            packageItem.Name = 'Test Pack Item';
            packageItem.Product_Family__c = prodFamily.Id;
            packageItem.RecordTypeId = keyID.Id__c;
            insert packageItem;
            System.debug('@@@' + packageItem.RecordType.Name);
    
            Account acct = new Account();
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.NRIC__c = 'T1234567R';
            insert acct;
    
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
            insert acctVendor;
    
            Account acct2 = new Account();
            acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct2.NRIC__c = 'T1234567R';
            insert acct2;
    
            Contact con = new Contact();
            con = TestDataFactory.createContact(1)[0];
            con.AccountId = acct.Id;
            con.Address__c = address.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
    
            //create order
            List<Order__c> order = TestDataFactory.createOrder(2);
            order[0].Account__c = acct.Id;
            order[0].Recipient_Contact__c = con.Id;
            order[0].Informed_Customer__c = True;
            order[0].Acquisition_Type__c = 'Call';
            order[1].Account__c = acct.Id;
            order[1].Recipient_Contact__c = con.Id;
            order[1].Informed_Customer__c = True;
            order[1].Acquisition_Type__c = 'Call';
            insert order;
    
            //create case
            List<Case> cas = TestDataFactory.createCase(5, 'Complaint - Magazine');
            cas[0].Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
            cas[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            cas[0].Order__c = order[0].Id;
            cas[1].Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            cas[1].RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas[1].Order__c = order[0].Id;
            cas[2].Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            cas[2].RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            cas[2].Order__c = order[1].Id;
            cas[2].Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas[2].Status = 'Pending';
            cas[3].Sub_Category__c = GlobalVariableClass.RECTYPE_START_SUBSCRIPTION;
            cas[3].RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            cas[4].Sub_Category__c = GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION;
            cas[4].RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Subscription');
            cas[4].Order__c = order[1].Id;
            cas[4].Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            cas[4].Status = 'Pending';
    
            insert cas;
    
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order[0].Id;
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = packge.Id;
            orderline.Term_Length__c = 1;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+5;
            orderline.Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline.Vendor_Mailing_Agent__c = null;
            orderline.Subscription_Name__c ='test name';
            orderline.Is_Digital__c = false;
    
            insert orderline;
    
            //WAK 04/15/2016
            Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = con.id);        
            insert asiaOneRecord;
            System.debug('***wendy : inserted asiaOneRecord');
    
            Service_Access_Flag__c saf = new Service_Access_Flag__c();
            saf.Name = 'test name';
            insert saf;
            System.debug('***wendy : inserted saf');
    
            Asia1_Subscription__c tmp = new Asia1_Subscription__c();
            tmp.Asia1__c = asiaOneRecord.id;
            tmp.Order_Line_Item__c = orderline.id;
            tmp.Service_Access_Flag__c = saf.id;
            tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
            insert tmp; 
            System.debug('***wendy : inserted tmp');
    
            //create subscription vendor
            Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            insert SubVend;
            System.debug('***wendy : inserted tmp');
    
            Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
            zua.Zuora__Account__c = acct.Id;
            zua.Zuora__DefaultPaymentMethod__c = 'Other';
            insert zua; 
            System.debug('***wendy : inserted zua');
    
    
            Zuora__CustomerAccount__c zua2 =  TestDataFactory.createBillingAccount(1)[0];
            zua2.Zuora__Account__c = acct.Id;
            zua2.Zuora__DefaultPaymentMethod__c = 'Other';
            insert zua2; 
            
            Letter_Print_Request__c lpr = new Letter_Print_Request__c();
            lpr.Letter_Type__c = GlobalVariableClass.LETTER_TYPE_ACK;
            lpr.Record_ID__c = zua.Id;
            insert lpr;
            
            List<Zuora__PaymentMethod__c> paymentMethodList = TestDataFactory.createPaymentMethod(2);
            paymentMethodList[0].Zuora__Type__c = 'CreditCard';
            paymentMethodList[0].Zuora__BillingAccount__c = zua.Id;
            paymentMethodList[1].Zuora__Type__c = 'CreditCard';
            paymentMethodList[1].Zuora__BillingAccount__c = zua2.Id;
            insert paymentMethodList;
            
            zua.Zuora__Default_Payment_Method__c = paymentMethodList[0].Id;
            update zua;
            system.debug('>>>>>zua ' + zua.Zuora__Default_Payment_Method__c);
            system.debug('>>>>>zua ' + zua.Zuora__Default_Payment_Method__r.Zuora__Type__c);
            system.debug('>>>>>zua ' + zua.Zuora__PaymentMethod_Type__c);
            zua2.Zuora__Default_Payment_Method__c = paymentMethodList[0].Id;
            update zua2;
            System.debug('***wendy : inserted zua2');

            test.startTest();
            List<Zuora__Subscription__c> relSub = new List<Zuora__Subscription__c>();
            relSub = TestDataFactory.createSubscription(3);
            relSub[0].Zuora__AutoRenew__c = true;
            relSub[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[0].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[0].Zuora__Account__c = acct.Id;
            relSub[0].Order_Number__c = order[0].Id;
            relSub[0].Subscriber_Contact__c = con.Id;
            relSub[0].Recipient_Contact__c = con.Id;
            relSub[0].Recipient_Contact_1__c = con.Id;
            relSub[0].Main_Package_1__c = packge.id;
            relSub[0].Zuora__Status__c = 'Active';
            relSub[0].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[0].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[0].Urgent__c = 'false';
            relSub[0].Vendor_Conversion__c = 'false';
            relSub[0].Charity__c = 'false';
            relSub[0].Order_Line_Item_Number__c = orderline.Id;
            //relSub[0].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[0].Vendor_1__c = acctVendor.id;
            relSub[0].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[0].Zuora__Zuora_Id__c = '111111';
            //relSub[0].Term_Length__c = 12;
            relSub[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            //relSub[0].Zuora__SubscriptionEndDate__c = relSub[0].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[0].Term_Length__c)).addDays(-1);
            relSub[0].Zuora__Version__c = 1;
            relSub[0].Zuora__TermSettingType__c = 'EVERGREEN';
            relSub[1].Zuora__AutoRenew__c = true;
            relSub[1].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[1].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub[1].Zuora__Account__c = acct.Id;
            relSub[1].Order_Number__c = order[0].Id;
            relSub[1].Subscriber_Contact__c = con.Id;
            relSub[1].Recipient_Contact__c = con.Id;
            relSub[1].Recipient_Contact_1__c = con.Id;
            relSub[1].Main_Package_1__c = packge.id;
            relSub[1].Zuora__Status__c = 'Cancelled';
            relSub[1].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[1].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[1].Urgent__c = 'false';
            relSub[1].Vendor_Conversion__c = 'false';
            relSub[1].Charity__c = 'false';
            relSub[1].Order_Line_Item_Number__c = orderline.Id;
            //relSub[1].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[1].Vendor_1__c = acctVendor.id;
            relSub[1].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[1].Zuora__Zuora_Id__c = '111111';
            //relSub[1].Term_Length__c = 12;
            relSub[1].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            //relSub[1].Zuora__SubscriptionEndDate__c = relSub[1].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[1].Term_Length__c));
            relSub[1].Zuora__TermSettingType__c = 'EVERGREEN';
            relSub[1].Zuora__Version__c = 2;
            relSub[2].Zuora__AutoRenew__c = true;
            relSub[2].Subscription_Type__c = 'Delivery';
            relSub[2].Subscription_Type_1__c =  'Delivery';
            relSub[2].Zuora__Account__c = acct.Id;
            relSub[2].Order_Number__c = order[0].Id;
            relSub[2].Subscriber_Contact__c = con.Id;
            relSub[2].Recipient_Contact__c = con.Id;
            relSub[2].Recipient_Contact_1__c = con.Id;
            relSub[2].Main_Package_1__c = packge.id;
            relSub[2].Zuora__Status__c = 'Cancelled';
            relSub[2].Suppress_Vendor_Start_Notice__c = 'false';
            relSub[2].Supressed_Acknowledgement_Letter__c = 'false';
            relSub[2].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub[2].Urgent__c = 'false';
            relSub[2].Vendor_Conversion__c = 'false';
            relSub[2].Charity__c = 'false';
            relSub[2].Order_Line_Item_Number__c = orderline.Id;
            relSub[2].Zuora__TermSettingType__c = 'EVERGREEN';
            //relSub[2].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub[2].Vendor_1__c = acctVendor.id;
            relSub[2].Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
            relSub[2].Zuora__Zuora_Id__c = '111111';
            //relSub[2].Term_Length__c = 12;
            relSub[2].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            //relSub[2].Zuora__SubscriptionEndDate__c = relSub[2].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub[2].Term_Length__c));
            relSub[2].Zuora__Version__c = 2;
            relSub[2].Legacy_Subscription_ID__c = '12345';
            insert relSub;
            
            order[0].Base_Subscription__c = relSub[0].Id;
            update order[0];
            
            orderline.Subscription_Name__c = relSub[0].Name;
            orderline.Case__c = cas[0].Id;
            update orderline;
            
            List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(3);
            orderline1[0].Order__c = order[0].Id;
            orderline1[0].End_Date__c = date.today()+30;
            orderline1[0].Main_Package_ID__c = packge.Id;
            orderline1[0].Term_Length__c = 1;
            orderline1[0].Main_Package_Period__c = 0;
            orderline1[0].Earliest_Start_Date__c = date.today();
            orderline1[0].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[0].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[0].Terminating_Reason__c = 'Others';
            orderline1[0].Amount_To_Refund__c = 0;
            orderline1[0].Admin_Charge__c = 0;
            orderline1[0].Fee_Waiver__c = TRUE;
            orderline1[0].Fee_Override__c = TRUE;
            orderline1[0].Override_Reason__c = 'TEST';
            orderline1[0].Suppress_Notification_Stop__c = TRUE;
            orderline1[0].Main_Package_Type__c = 'Base';
            orderline1[0].Start_Date__c = date.today()+5;
            orderline1[0].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[0].Vendor_Mailing_Agent__c = null;
            orderline1[0].Subscription_Name__c = relSub[1].Name;
            orderline1[0].Is_Digital__c = false;
            orderline1[1].Order__c = order[0].Id;
            orderline1[1].End_Date__c = date.today()+30;
            orderline1[1].Main_Package_ID__c = packge.Id;
            orderline1[1].Term_Length__c = 1;
            orderline1[1].Main_Package_Period__c = 0;
            orderline1[1].Earliest_Start_Date__c = date.today();
            orderline1[1].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[1].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[1].Terminating_Reason__c = 'Others';
            orderline1[1].Amount_To_Refund__c = 0;
            orderline1[1].Admin_Charge__c = 0;
            orderline1[1].Fee_Waiver__c = TRUE;
            orderline1[1].Fee_Override__c = TRUE;
            orderline1[1].Override_Reason__c = 'TEST';
            orderline1[1].Suppress_Notification_Stop__c = TRUE;
            orderline1[1].Main_Package_Type__c = 'Base';
            orderline1[1].Start_Date__c = date.today()+5;
            orderline1[1].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[1].Vendor_Mailing_Agent__c = null;
            orderline1[1].Subscription_Name__c = relSub[1].Name;
            orderline1[1].Is_Digital__c = false;
            orderline1[1].Case__c = cas[2].Id;
            orderline1[1].Subscription__c = relSub[0].Id;
            orderline1[2].Order__c = order[0].Id;
            orderline1[2].End_Date__c = date.today()+30;
            orderline1[2].Main_Package_ID__c = packge.Id;
            orderline1[2].Term_Length__c = 1;
            orderline1[2].Main_Package_Period__c = 0;
            orderline1[2].Earliest_Start_Date__c = date.today();
            orderline1[2].Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline1[2].Stop_Request_Date__c =  date.Today().addDays(4);
            orderline1[2].Terminating_Reason__c = 'Others';
            orderline1[2].Amount_To_Refund__c = 0;
            orderline1[2].Admin_Charge__c = 0;
            orderline1[2].Fee_Waiver__c = TRUE;
            orderline1[2].Fee_Override__c = TRUE;
            orderline1[2].Override_Reason__c = 'TEST';
            orderline1[2].Suppress_Notification_Stop__c = TRUE;
            orderline1[2].Main_Package_Type__c = 'Base';
            orderline1[2].Start_Date__c = date.today()+5;
            orderline1[2].Delivered_By__c = GlobalVariableClass.VENDOR;
            orderline1[2].Vendor_Mailing_Agent__c = null;
            orderline1[2].Subscription_Name__c = relSub[2].Name;
            orderline1[2].Is_Digital__c = false;
            orderline1[2].Case__c = cas[4].Id;
            orderline1[2].Subscription__c = relSub[0].Id;
    
            insert orderline1;
            
            relSub[0].Zuora__CustomerAccount__c = zua2.id;
            update relSub[0];
            
            test.stopTest(); 
            /*
            List<Zuora__Subscription__c> relSub1 = TestDataFactory.createSubscription(1);
            relSub1[0].Subscription_Type_1__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub1[0].Subscription_Type__c =  GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            relSub1[0].Zuora__Zuora_Id__c = '222222';
            relSub1[0].Recipient_Contact__c = null;
            relSub1[0].Name = 'test name';
            relSub1[0].Zuora__Account__c = acct.Id;        
            relSub1[0].Order_Number__c = order.Id;
            relSub1[0].Subscriber_Contact__c = con.Id;
            relSub1[0].Vendor_Subscription_To_Convert_1__c = SubVend.Id;
            relSub1[0].Subscription_Charge__c = null;
            relSub1[0].Main_Package_1__c = packge.id;
            relSub1[0].Zuora__Status__c = GlobalVariableClass.STATUS_ACTIVE;
            relSub1[0].Suppress_Vendor_Start_Notice__c = 'false';
            relSub1[0].Supressed_Acknowledgement_Letter__c = 'false';
            relSub1[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            relSub1[0].Urgent__c = 'false';
            relSub1[0].Vendor_Conversion__c = 'false';
            relSub1[0].Charity__c = 'false';
            relSub1[0].Order_Line_Item_Number__c = orderline.Id;
            //relSub1[0].Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            relSub1[0].Vendor_1__c = acctVendor.id;
            relSub1[0].Zuora__CustomerAccount__c = zua.id;
            //relSub1[1].Order_Number_1__c = order2.id;
            relSub1[0].Vendor__c = acctVendor.Id+'';
            relSub1[0].Zuora__AutoRenew__c = true;
            relSub1[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
            relSub1[0].Payment_Mode__c = 'Other';
            relSub1[0].Other_PaymentMethod__c = 'Freelist';
            relSub1[0].Order_Line_Item_Number_1__c = orderline.Id;
            relSub1[0].Zuora__Version__c = 1;
            relSub1[0].Term_Length__c = 12;
            relSub1[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            relSub1[0].Zuora__SubscriptionEndDate__c = relSub1[0].Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(relSub1[0].Term_Length__c)).addDays(-1);
            relSub1[0].Related_Subscription__c = '222222';
            insert relSub1[0];
            
            Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
            temp.Temp_Stop_Date__c = relSub1[0].Zuora__SubscriptionStartDate__c.addMonths(1).toStartOfMonth();
            temp.Restart_Date__c = temp.Temp_Stop_Date__c.addDays(10);
            temp.Qty__c = 1;
            //temp.Cancelled__c  = true;
            database.insert(temp);
            
            Subscription_Temp_Stop__c subTemp = new Subscription_Temp_Stop__c();
            subTemp.Temp_Stop__c = temp.Id;
            subTemp.Subscription__c = relSub1[0].Id; 
            database.insert(subTemp);
            
            Address_Assignment__c addAss = new Address_Assignment__c();
            addAss.Active__c = false;
            addAss.Effective_Date__c = date.today().addMonths(2).toStartOfMonth();
            addAss.Subscription__c = relSub1[0].Id;
            addAss.Address__c = address.Id;
            addAss.Contact__c = con.Id;
            insert addAss;
            */
        }
    }
    
        static testMethod void testSingleInsertUpdate3(){        
        User usr = createUser();
        
        //The test will run as the user created.
        System.runAs(usr) {
            setUpTestData();
                        List<Billing_Batch__c> billBatches = new List<Billing_Batch__c>();
            billBatches = CustomSettingsDataFactory.createBillingBatch();
            insert billBatches;
            Zuora__Subscription__c sobj = new Zuora__Subscription__c();
            Zuora__Subscription__c sobj2 = new Zuora__Subscription__c();        
            
            SubscriptionTriggerHandler subhandler = new SubscriptionTriggerHandler();
            subhandler.beforeDelete(sobj);
            SubscriptionTriggerHandler subhandler2 = new SubscriptionTriggerHandler();
            subhandler.afterDelete(sobj2);
            
            //subhandler.testCoveragePatch();
            
            SubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = FALSE;
            SubscriptionTriggerHandler.isAfterDeleteTriggerCalled = FALSE;
            
            //Singpost_Address__c postal = new Singpost_Address__c();
            //postal = TestDataFactory.createSingpostAddress(1)[0];
            //insert postal;
            
            //Address__c address = new Address__c();
            //address = TestDataFactory.createAddress(1)[0];
            //address.Postal_Code__c = postal.Id;
            //insert address;
            
            //Package__c pack = new Package__c();
            //pack = TestDataFactory.createPackage(1)[0];
            //insert pack;
            
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
            //acctVendor.Ven
            insert acctVendor;
            
            //Contact con = new Contact();
            //con = TestDataFactory.createContact(1)[0];
            //con.AccountId = acct.Id;
            //con.Address__c = address.Id;
            //// START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
            ////con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            //con.Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            //insert con;
            
            /*[JPO 02/13] create con2
Contact con2 = new Contact();
con2 =  TestDataFactory.createContact(1)[0];
con2.AccountId = acct2.Id;
con2.Address__c = address.Id;            
con2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
con2.Recipient_Indicator__c = true;
insert con2; */
            
            
            
            //create order
            /*   Order__c order = TestDataFactory.createOrder(1)[0];
order.Account__c = acnt.Id;
order.Recipient_Contact__c = cntctList[1].Id;
order.Informed_Customer__c = True;*/
            //order.Base_Subscription__c = zuoraSubscription.Id;
            
            //WAK 04/15/16 added
            //order.RecordTypeId = ConstantsSLB.getKeyId('Case_Stop');
            //insert order;
            
            /*[JPO 02/13] create order2 for subrRec's orderline item 1
Order__c order2 = TestDataFactory.createOrder(1)[0];
order2.Account__c = acct2.Id;
order2.Recipient_Contact__c = con2.Id;
order2.Informed_Customer__c = True;
insert order2; //error? FIELD_FILTER_VALIDATION_EXCEPTION, Value does not exist or does not match filter criteria.: [Recipient_Contact__c]
*/
            //create case
            //Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            //cas.Order__c = order.Id;
            //insert cas;
            /*
Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
orderline.Order__c = order.Id;
orderline.End_Date__c = date.newInstance(2014, 12, 2);
orderline.End_Date__c = date.today()+30;
orderline.Main_Package_ID__c = packge.Id;
orderline.Term_Length__c = 1;
orderline.Main_Package_Period__c = 0;
orderline.Earliest_Start_Date__c = date.today();
orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
orderline.Stop_Request_Date__c =  date.Today().addDays(4);
orderline.Terminating_Reason__c = 'Others';
orderline.Amount_To_Refund__c = 0;
orderline.Admin_Charge__c = 0;
orderline.Fee_Waiver__c = TRUE;
orderline.Fee_Override__c = TRUE;
orderline.Override_Reason__c = 'TEST';
orderline.Suppress_Notification_Stop__c = TRUE;
orderline.Main_Package_Type__c = 'Base';
orderline.Start_Date__c = date.today()+5;
*/
            
            //WAK 04/15/2016
            Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = cntctList[0].id);        
            insert asiaOneRecord;
            System.debug('***wendy : inserted asiaOneRecord');
            
            Service_Access_Flag__c saf = new Service_Access_Flag__c();
            saf.Name = 'test name';
            insert saf;
            System.debug('***wendy : inserted saf');
            
            Package_Access_Flag__c paf = new Package_Access_Flag__c();
            paf.Package_Service_Access_Flag__c = saf.id;
            paf.Package__c = packge.id;
            paf.No_of_Concurrent_Users__c = 1;
            insert paf;
            System.debug('***wendy : inserted paf' + paf.Package__c);
            
            List<Asia1_Subscription__c> tmpList = new List<Asia1_Subscription__c>();
            Asia1_Subscription__c tmp = new Asia1_Subscription__c();
            tmp.Asia1__c = asiaOneRecord.id;
            tmp.Order_Line_Item__c = ordLineItem.id;
            tmp.Service_Access_Flag__c = saf.id;
            tmp.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
            tmpList.add(tmp);
            Asia1_Subscription__c tmp1 = new Asia1_Subscription__c();
            tmp1.Asia1__c = asiaOneRecord.id;
            tmp1.Order_Line_Item__c = ordLineItem.id;
            tmp1.Service_Access_Flag__c = saf.id;
            tmp1.Status__c  = GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED;
            tmpList.add(tmp1);
            insert tmpList; 
            System.debug('***wendy : inserted tmp');
            
            //create subscription vendor
            //Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            ////SubVend.Name = 'Test Subscription Vendor';
            //insert SubVend;
            //System.debug('***wendy : inserted tmp');
            
            Case caseRec = new Case();
            caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            caseRec.Status = 'Pending';
            caseRec.Sub_Status__c = 'Wating for Vendor Assignment';               
            insert caseRec;   
            System.debug('***wendy : caseRec'); 
            
            Subscription_Vendor__c venSub = new Subscription_Vendor__c();
            venSub = TestDataFactory.createSubscriptionVendor(1)[0];
            insert venSub;
            
            Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
            zua.Zuora__Account__c = acnt.Id;
            zua.Zuora__DefaultPaymentMethod__c = 'Other';
            //zua.Zuora__PaymentMethodType__c = 'Paypal';
            insert zua; 
            System.debug('***wendy : inserted zua');
            String ZuoraExternalId = 'try1234';
            Zuora__Subscription__c subRec = TestDataFactory.createSubscription(1)[0];
            subRec.Zuora__Account__c = acnt.Id;
            subRec.Order_Line_Item_Number__c = ordLineItem.Id;
            subRec.Subscriber_Contact__c = cntctList[0].Id;
            //subRec.Recipient_Contact__c = cntctList[0].Id;
            subRec.Main_Package_1__c = packge.Id;
            subRec.Main_Package__c = packge.Id;
            subRec.Zuora__Status__c = 'Active';
            subRec.Order_Number__c = orders.Id;
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Charity__c = 'false';
            subRec.Subscription_Type__c = 'Publication';
            subRec.Subscription_Type_1__c = 'Publication';
            subRec.Zuora__SubscriptionEndDate__c= date.today().addDays(30);        
            subRec.Zuora__TermSettingType__c = 'TERMED';
            subRec.Term_Length__c = 1;
            subRec.Zuora__SubscriptionStartDate__c = date.today();
            subRec.Zuora__CustomerAccount__c = custAccount.Id;
            subRec.Contact__c = cntctList[0].id;
            subRec.Zuora__External_Id__c = ZuoraExternalId;
            subRec.Zuora__Zuora_Id__c = ZuoraExternalId;
            subRec.Order_Line_Item_Number_1__c = ordLineItem.Id;
            subRec.Delivered_By__c = 'Vendor';
            subRec.Vendor_Subscription_To_Convert_1__c = venSub.id;
            subRec.Term_Length__c = 12;
            subRec.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_MR_POST;
            subRec.Vendor_Credit_1__c = 1;
            subRec.Delivery_Charge_Type_1__c = 'H';
            subRec.Zuora__TermSettingType__c = 'EVERGREEN';
            
            
            // insert zuoraSubscription;
            /*
Zuora__Subscription__c subRec = new Zuora__Subscription__c();
subRec = TestDataFactory.createSubscription(1)[0];
subRec.Zuora__Account__c = acnt.Id;
subRec.Order_Number__c = order.Id;
subRec.Subscriber_Contact__c = cntctList[0].Id;
//subRec.Recipient_Contact__c = con.Id;
subRec.Main_Package_1__c = packge.id;
subRec.Zuora__Status__c = 'Active';
//subRec.Zuora__Status__c = 'Cancelled'; [JPO 02/13] commented out
subRec.Suppress_Vendor_Start_Notice__c = 'false';
subRec.Supressed_Acknowledgement_Letter__c = 'false';
subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
subRec.Urgent__c = 'false';
subRec.Vendor_Conversion__c = 'false';
subRec.Charity__c = 'false';
subRec.Order_Line_Item_Number__c = ordLineItem.Id;
subrec.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
subRec.Vendor_1__c = acctVendor.id;
subRec.Zuora__CustomerAccount__c = zua.id; //[JPO 02/12] added
//subRec.Order_Number_1__c = order2.id; //[JPO 02/13] added 
*/       
            
            test.startTest(); //[JPO 02/12/2015] Moved startTest before inserting subRec 
            insert subRec; 
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acnt.Id;
            order.Recipient_Contact__c = cntctList[1].Id;
            order.Informed_Customer__c = True;
            insert order;
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.End_Date__c = date.today()+30;
            orderline.Main_Package_ID__c = packge.Id;
            orderline.Term_Length__c = 1;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+5;
            orderline.Subscription_Name__c = subRec.name;
            orderline.Main_Package_Subscription_Rate__c  = 10;
            orderline.Qty__c = 1;
           
            insert orderline;
            subRec.Zuora__Status__c = 'Cancelled';
           //subRec.Recipient_Contact__c = null;
            subRec.Subscription_Charge__c = null;
            update subRec;
            
            System.debug('***wendy : inserted subRec');
            
           
            
            Zuora__Subscription__c subRec2 = new Zuora__Subscription__c();
            subRec2 = TestDataFactory.createSubscription(1)[0];
            subRec2.Zuora__Version__c = 2; 
            subRec2.Zuora__CustomerAccount__c = custAccount.Id; 
            subRec2.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_MR_POST;
            subRec2.Vendor_Credit_1__c = 1;
            subRec2.Delivery_Charge_Type_1__c = 'H';
            subRec2.Subscription_Type__c = 'Delivery';
            subRec2.Subscription_Type_1__c = 'Delivery';
            insert subRec2;
                        
            
            //[JPO 02/12/2015] Adding List
            //List<Zuora__Subscription__c> testsubscriptionList = TestDataFactory.createSubscription(1);
            //testsubscriptionList.add(subrec);
            
            //insert testsubscriptionList;
            
            /* removing this causing SOQL limit
Zuora__Subscription__c subRec2 = new Zuora__Subscription__c();
subRec2 = TestDataFactory.createSubscription(1)[0];
subRec2.Zuora__Account__c = acct.Id;
subRec2.Order_Number__c = order.Id;
subRec2.Subscriber_Contact__c = con.Id;
subRec2.Recipient_Contact__c = con.Id;
subRec2.Main_Package_1__c = pack.id;
subRec2.Suppress_Vendor_Start_Notice__c = 'false';
subRec2.Supressed_Acknowledgement_Letter__c = 'false';
subRec2.Supressed_Renewal_and_Reminder_Letter__c = 'false';
subRec2.Urgent__c = 'false';
subRec2.Vendor_Conversion__c = 'false';
subRec2.Charity__c = 'false';
//subRec2.Zuora__Status__c = NULL;
subRec2.Order_Line_Item_Number__c = orderline.Id;
insert subRec2;

Zuora__Subscription__c subRec3 = new Zuora__Subscription__c();
subRec3 = TestDataFactory.createSubscription(1)[0];
subRec3.Zuora__Account__c = acct.Id;
subRec3.Order_Number__c = order.Id;
subRec3.Subscriber_Contact__c = con.Id;
subRec3.Recipient_Contact__c = con.Id;
subRec3.Main_Package_1__c = pack.id;
subRec3.Suppress_Vendor_Start_Notice__c = 'false';
subRec3.Supressed_Acknowledgement_Letter__c = 'false';
subRec3.Supressed_Renewal_and_Reminder_Letter__c = 'false';
subRec3.Urgent__c = 'false';
subRec3.Vendor_Conversion__c = 'false';
subRec3.Charity__c = 'false';
subRec3.Order_Line_Item_Number__c = orderline.Id;
insert subRec3;
*/                      
            /*
            Case_Subscription__c  caseSub = new Case_Subscription__c();
            caseSub.Account__c = acnt.Id;
            caseSub.Address__c = addrList[0].Id;
            caseSub.Case__c = caseRec.Id;
            caseSub.Subscription__c = subRec.Id;
            insert caseSub;    
            
            System.assertEquals(acnt.Id, caseSub.Account__c);
            */
            
            /*
try{    
subRec.Vendor_1__c = NULL;
update subRec;
//subRec2.Vendor_1__c = NULL;
//update subRec2;   
}   
catch (Exception e){
Boolean expectedExceptionThrown =  e.getMessage().contains('Vendor cannot be empty.') ? true : false;
//System.AssertEquals(expectedExceptionThrown, true);
}
*/
            
            subRec.Zuora__Status__c = 'Cancelled'; // [JPO 2/13] Made 'Active' From ''
            subRec.Zuora__SubscriptionStartDate__c = Date.today().addMonths(-Integer.valueOf(subRec.Term_Length__c));
            subRec.Zuora__SubscriptionEndDate__c = Date.today();
            //update subRec;
            //subRec2.Zuora__Status__c = 'Active';
            //update subRec2;
            //subRec3.Zuora__Status__c = 'Active';
            //update subRec3;
            
            //update            
            SubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = false;
            SubscriptionTriggerHandler.isAfterUpdateTriggerCalled = false;   
            //subRec.Vendor_1__c = acctVendor.Id; 
            //subRec.Vendor__c = acctVendor.Id;
            // System.assertEquals(null, acctVendor.Id);    
            subRec.Vendor__c = acctVendor.Id+'';
           // update subRec; // venor cdannot be empty error
            
            SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler();
            handler.runBeforeUpdateTrigger();
            handler.runAfterUpdateTrigger();
            //TEST: if 
            
            handler.runBeforeInsertTrigger();
            handler.runBeforeDeleteTrigger();
            handler.runAfterInsertTrigger();
            handler.runAfterDeleteTrigger();
            
            
            
            test.stoptest();    
        }
    }

         static testmethod void magazineRenewalSubTest() {
    
        /****************************** Test Data Creation ******************************/
        /*   Insert code statements that inserts Data                                   */
        /*   needed by Base Class.                                                      */
        /*   e.g. Base Class Queries Account with                                       */
        /*        Record Type = Direct.                                                 */
        /*                                                                              */
        /*        List<Account> accList = TestDataFactory.createAccount('Direct',5);    */
        /*         Insert accList;                                                      */
        /********************************************************************************/
        
        Manual_Batch_Run_Dates__c mbrDate = new Manual_Batch_Run_Dates__c();
        mbrDate.Name = 'ManualBatchRun';
        mbrDate.Batch_Run_Date__c = Date.Today();
        database.insert(mbrDate);
        
        Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
        Package__c pack = TestDataFactory.createPackage(1)[0];
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        insert new List<sObject>{venAccount, pack, subsVen};           
    List<RecordType> casrt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Renewal of Subscription'];            
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
            postal.Name = 'Test Postal';
            postal.Building_Name__c = 'Test Building';
            postal.Street_Name__c = 'Test Street';
            insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
            
        Country__c countr = TestDataFactory.createCountry(1)[0];
            countr.Country_Name__c = 'Test Country';
            insert countr;
                
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
            //addressRec.RecordTypeId = '012N00000008idiIAA';
            addressRec.Block_House_Number__c = 'Sample';
            addressRec.Address_Type__c= 'P';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Level_Number__c = 'Ab';
            addressRec.Unit_Number__c = 'ab';
            addressRec.Country__c = countr.Id;
            insert addressRec;        
            
        Contact conList = TestDataFactory.createContact(1)[0];
            conList.LastName = 'Gonzales';
            conList.Address__c = addressRec.Id;
            conList.AccountId = acc.Id;
            conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            conList.Recipient_Indicator__c = true;
            insert conList;
        
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = conList.Id;
            insert orderRec;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
      cas.recordtypeid = casrt[0].Id;
            insert cas;
            
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.Today() +60;
            orderline.start_date__c = date.Today();
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Case__c = cas.id;
            orderline.Vendor_Mailing_Agent__c = venAccount.Id;
            orderline.Vendor_Subscription_ID__c = subsVen.Id;
            orderline.Start_Date__c = date.today()+1;
            insert orderline;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = '100 YEARS OF ADVENTURE';
            pub.Published_Days__c = 'YYYYYYY';
            pub.Publication_Code__c ='TSSA';
            pub.Publication_Type__c ='M';
            insert pub;

        //START KINGSLEY
        Billing_Batch__c billingBatch = new Billing_Batch__c();
            billingBatch.Next_Batch_Number__c   = 14;
            billingBatch.Batch__c               = '13,14,15';
            billingBatch.Name                   = 'Full Prepaid';
        insert billingBatch;

        //END KINGSLEY
        
        //jurna added    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Billing_Contact__c = conList.Id;
        insert billAcc;
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Order_Line_Item_Number__c = orderline.Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Order_Number__c = orderRec.Id;
            sub.Contact__c = conList.Id;
            sub.Subscriber_Contact__c = conList.Id;
            sub.Recipient_Contact__c = conList.Id;
            sub.Main_Package_1__c = pack.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Order_Line_Item_Number_1__c = orderline.id;
            sub.Subscription_Type__c = 'Delivery';
            sub.Zuora__SubscriptionEndDate__c = date.today();          
            sub.Frequency_1__c = 'Mon - Fri';
            sub.Number_of_Copies__c = 3;  
            sub.Zuora__CustomerAccount__c = billAcc.id; //jurna added   
            //insert sub; 
            
        Test.startTest();            
        
        /*************************** Creation of Test User ******************************/
        //User testUser = TestDataFactory.prepareTestusers();
        
        //System.runAs(testUser){
             //This creates a new Heap block Dedicated to your test Run of actual lines in Base Class.
            insert sub;
            
            Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
         letterPrintRequest.Billing_Account__c = billAcc.Id;
         letterPrintRequest.Type__c = 'Master';
         letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest.Status_Email__c = 'Tagged';
         //letterPrintRequest.Record_Id__c = 'Email';
         letterPrintRequest.Record_Id__c = String.ValueOf(sub.Id);
         letterPrintRequest.Language_Medium__c = 'C';
         insert letterPrintRequest;
         
         Letter_Print_Request__c letterPrintRequest2 = new Letter_Print_Request__c();
         letterPrintRequest2.Billing_Account__c = billAcc.Id;
         letterPrintRequest2.Type__c = 'Master';
         letterPrintRequest2.Letter_Type__c = SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine;
         letterPrintRequest2.Status_Email__c = 'Tagged';
         letterPrintRequest2.Status__c = 'Tagged';
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest2.Record_Id__c = 'Email';
         letterPrintRequest2.Record_Id__c = String.ValueOf(sub.Id);
         insert letterPrintRequest2;
         
         letterPrintRequest2.Parent_Letter_Print_Request__c = letterPrintRequest.Id;
         letterPrintRequest.Parent_Letter_Print_Request__c = letterPrintRequest2.Id;
         update letterPrintRequest2;
         //update letterPrintRequest;
          
         /*   PageReference pageRef = Page.LP_MagazineRenewal;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',letterPrintRequest.id); //add this statement if Base Class contains  "ApexPages.currentPage().getParameters().put"
            RenewalController controller = new RenewalController();
           try{controller.setFields();
            }catch(Exception e){}
            controller.initializeMZ();
            controller.initializeNP();*/
            /*try
            {
                controller.initializeCHNP();
                controller.initializeCHMZ();
            }catch(exception e) {
                system.debug(':::ERROR ' + e);
            }*/
 
            //karen 04.13.15 compile error fixed
//            controller.initialize();
            
            //System.assertEquals(sub.Contact__r.Address__r.Block_House_Number__c, '');
            //System.assertEquals(sub.Contact__r.Address__r.Block_House_Number__c, 'Sample');
            
            //<Name of Base Class> controller = new <Name of Base Class>(); //FOR CUSTOM CONTROLLERS ONLY
            //<Name of Base Class> controller = new <Name of Base Class>(new ApexPages.StandardController(co));//FOR EXTENSION CONTROLLERS ; co is the SOBJECT Record.
            
            /***************************************** Execution of Methods *****************************************/
            /*  Execute Methods inside Base Class. E.g. Base class has a method,                                    */
            /*  public void Initialize(){                                                                           */
            /*      <<Code Block>>                                                                                  */
            /*  }                                                                                                   */
            /*                                                                                                      */
            /*  In test Method, insert a statement:                                                                 */
            /*  controller.Initialize(); //controller is the alias of the Base Class as instantiated in Line 26/27  */
            /*                                                                                                      */
            /*  Make sure to cover all PUBLIC methods.                                                              */
            /*  Note: Private methods does not need to be called as it is already called in another method.         */
            /********************************************************************************************************/
                 
            Test.stopTest(); //Indicates End of Coverage of Test Method
        //}
    }
    
     static testMethod void testAssignCaseSubscription(){

 
      //Id profileID = (Id) ConstantsSLB.getKeyId('Standard_User User');
     // System.debug('>>>>>>>>>>>>>>' + profileID);
       
      Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profile.Id,            
            //ProfileId = (Id) ConstantsSLB.getKeyId('Standard_User User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard_assignCS@test.com'
        );
        //System.runAs(u) {
              
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '6922';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;

            Package__c pack = TestDataFactory.createPackage(1)[0];
            Account acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acct.Contact_Person__c = 'asaasayt';
            acct.Singpost_Address__c = postal.Id;
            acct.PostalCode__c = '1145';
            acct.Telephone_Number_1__c = '0122112';
            acct.Telephone_Number_2__c = '0211544';
            acct.Unit_Number__c = '021';
            insert new List<sObject>{pack, acct};
           
            Account acct2 = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acct2.Contact_Person__c = 'rsasayt';
            acct2.Singpost_Address__c = postal.Id;
            acct2.PostalCode__c = '1155';
            acct2.Telephone_Number_1__c = '0122112';
            acct2.Telephone_Number_2__c = '0211544';
            acct2.Unit_Number__c = '021';
            //insert acct2;
            
            Zone__c zone = new Zone__c();
            insert zone;
            
            List<City__c> cityList = TestDataFactory.createCity(1);
            cityList[0].City_Name__c = 'cityName_test';
            cityList[0].Flight_Number_1__c = 'cityFlightNumber1_test';
            cityList[0].Flight_Number_2__c = 'cityFlightNumber2_test';
            //insert cityList;
     
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SIN';
            //country.Zone__c = zone.Id;
            insert country;
            
             //GAAC: Get RecordType Id
            Map<String, Id> mappedRecordType = new Map<String, Id>();
            for(RecordType crt : [SELECT Name, id FROM RecordType WHERE SObjectType = 'Address__c' LIMIT 2]) {
                MappedRecordType.put(crt.Name, crt.id);
              //  System.debug ('listing all address name: ' + crt.Name + ' Id: ' + crt.id); 
            }
             
            List<Address__c> addressRec = TestDataFactory.createAddress(1); 
            addressRec[0].Country__c = country.Id;
            addressRec[0].Postal_Code__c = postal.Id;
        
            addressRec[0].Address_Unique_Id__c = 'addrUniqueId_test';
            addressRec[0].RecordTypeId = ConstantsSLB.getKeyId('Address_Local'); //NOTE 
            addressRec[0].Name = 'Overseas'; 
            addressRec[0].Address_1__c = 'add1';
            addressRec[0].Address_2__c = 'add2';
            addressRec[0].Address_3__c = 'add3';
            addressRec[0].Address_4__c = 'add4';
            addressRec[0].Address_1__c = 'address1_test2';
            addressRec[0].Address_2__c = 'address2_test2';
            insert addressRec;
            
            List<Contact> con = TestDataFactory.createContactRecType(1, 'Vendor-MA');
            con[0].AccountId = acct.Id;
            con[0].Address__c = addressRec[0].Id;
            con[0].Recipient_Indicator__c = true;
            //con[0].City_Code__c = cityList[0].Id;         
            con[0].Billing_Indicator__c = true;
            con[0].Email__c = 'email@email.com';
            con[0].Email_Secondary__c = 'email2@email.com';
            con[0].Office_Number__c = '111-111-111';
            con[0].Mobile_Number__c = '111-111-111';
            con[0].HomePhone__c = '111-111-111';
            con[0].Fax__c = '111-111-111';
            con[0].zqu__County__c = 'zouraCountry_test';
            con[0].Description = 'contactDesc_test';  
            con[0].Firstname = 'Alfred';
            con[0].Lastname = 'Abrina';
           // con[0].Contact_Address_Detail__c = 'The address is here';
            insert con;
            
            //create postal Sector
            Postal_Zone__c pzc = new Postal_Zone__c();
            pzc.Name = 'myPostal';
            pzc.Postal_Zone__c = '00154as';
            pzc.Postal_Zone_Name__c = 'myPostal';
            pzc.Legacy_Created_Date__c   = '02/27/2015';
            pzc.Legacy_Created_By__c = 'Alfred';
            pzc.Legacy_Updated_Date__c  = '02/27/2015';
            pzc.Legacy_Updated_By__c = 'mytess';
            insert pzc;
            
            Integer postal_code_u;
            
            List<Contact> contacts = [Select Id, Address__r.Postal_Code__r.Name from Contact where Id =: con[0].Id LIMIT 2];
            for(Contact recipient : contacts){
                if (recipient.Address__r.Postal_Code__r.Name != null) {      
                    String subStrPostal = recipient.Address__r.Postal_Code__r.Name.substring(0,2);              
                    postal_code_u = integer.valueOf(subStrPostal);
                }
            }

//            System.assertNotEquals (2, postal_code_u);
            
            Post_Sector_Ops_Rep_Mapping__c pso = new Post_Sector_Ops_Rep_Mapping__c();
            pso.Postal_Sector_Code__c = postal_code_u;
            //pso.Vendor_Ops__c = u.Id;
            pso.Zone__c = pzc.Id;
            pso.Legacy_Created_Date__c   = '02/27/2015';
            pso.Legacy_Created_By__c = 'Alfred';
            pso.Legacy_Updated_Date__c  = '02/27/2015';
            pso.Legacy_Updated_By__c = 'mytess';
            insert pso;
              
            //System.debug ('vendorOps: ' +[Select Postal_Sector_Code__c, Vendor_Ops__c from Post_Sector_Ops_Rep_Mapping__c where Postal_Sector_Code__c =:pso.Postal_Sector_Code__c LIMIT 2]);
            System.assertEquals (con[0].address__c, [Select Address__c from Contact where Id =: con[0].Id LIMIT 2].Address__c);
            //System.debug ('Selecting Address_c alfred [Id, Address__c]: '+ [Select Id, Address__c from Contact where Id =: con[0].Id LIMIT 2]);
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acct.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con[0].Id;
            orderRec.Delivery_Charge__c = 4;
            orderRec.Order_Legacy_Id__c = '3421';
            orderRec.Legacy_Create_By__c = '1';
            orderRec.Legacy_Create_Date__c = '1';
            orderRec.Legacy_Update_By__c = '1';
            orderRec.Legacy_Update_Date__c = '1';
            orderRec.Monthly_Delivery_Charge_for_Full_Payment__c = 4;
            orderRec.Credit_Balance__c =1;
            insert orderRec;
            
            //System.debug ('Selecting from order: Alfred [Id, Recipient_Type__c, Account__c]' + [Select Id, Recipient_Type__c, Account__c from Order__c where Id =: orderRec.Id]);
           //System.assertEquals ('Overseas', orderRec.Recipient_Type__c);
            
           // System.debug ('Listing receipient contact from order level: ' + [Select Recipient_Contact__c from Order__c where Id =: orderRec.Id LIMIT 2]);
            
            //System.assertEquals(orderRec.Id, [Select Id from Order__c where Id =: orderRec.Id LIMIT 2].Id);
           
            //create publication
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Test';
            pub.Publication_Code__c = 'PUB1';
            pub.Published_Days__c = 'NNNNNNN';
            pub.Publication_Type__c = 'N';
            insert pub;
         
            Order_Line_Item__c orderline2 = TestDataFactory.createOrderLineItem(1)[0];
            orderline2.Order__c = orderRec.Id;
            orderline2.End_Date__c = date.newInstance(2014, 12, 2);
            orderline2.Main_Package_ID__c = pack.Id;
            orderline2.Term_Length__c = 0;
            orderline2.Main_Package_Period__c = 0;
            orderline2.Earliest_Start_Date__c = date.today();
            orderline2.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline2.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline2.Terminating_Reason__c = 'Others';
            orderline2.Amount_To_Refund__c = 0;
            orderline2.Admin_Charge__c = 0;
            orderline2.Fee_Waiver__c = TRUE;
            //orderline2.Fee_Override__c = TRUE;
            orderline2.Fee_Override__c = FALSE;
            orderline2.Override_Reason__c = 'TEST';
            orderline2.Suppress_Notification_Stop__c = TRUE;
            orderline2.Main_Package_Type__c = 'Base';
            orderline2.Start_Date__c = date.today().addDays(2);
            orderline2.End_Date__c = Date.Today().addDays(10);
            orderline2.Main_Package_Billing_Type__c = 'Recurring Prepaid';
            insert orderline2;
                      
            Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
            defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
            defaultPayment.Zuora__Account__c = acct.Id; 
            insert defaultPayment;
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Main_Package_1__c = pack.Id;
            sub.Zuora__Zuora_Id__c = 'sampleId';
            sub.Zuora__Account__c = acct.Id;
            sub.Subscriber_Contact__c = con[0].Id;
            sub.Recipient_Contact__c  = con[0].Id;
            sub.Order_Number__c = orderRec.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Zuora__SubscriptionStartDate__c = date.Today();
            //sub.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            sub.Zuora__SubscriptionEndDate__c = date.Today()+365;           
            sub.Billing_Type__c = 'Full Prepaid';
            sub.Charity__c = 'TRUE';
            sub.Contract_End_Date__c = String.valueof(date.Today());
            sub.New_Contract_Period__c = '1';
            sub.Penalty_Charge__c = '1000';
            sub.Promotion_Contract_Period__c = '2';
            sub.Suppress_Vendor_Start_Notice__c = 'TRUE';
            sub.Supressed_Acknowledgement_Letter__c = 'TRUE';
            sub.Supressed_Renewal_and_Reminder_Letter__c = 'TRUE';
            sub.Urgent__c= 'TRUE';
            sub.Vendor__c = acct.Id ;
            sub.Vendor_Conversion__c = 'TRUE';
            sub.Order_Line_Item_Number__c = orderline2.Id;        
            sub.Zuora__CustomerAccount__c = defaultPayment.Id; 
            sub.Delivery_Charge__c = 100;
            sub.Term_Length__c = 30;
            
            
            /*Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];          
            insert SubVend; */
            Test.startTest();
            //System.runAs(u){
            
            insert sub;
            
            Temp_Stop__c tsc = new Temp_Stop__c();
            tsc.Legacy_Create_Date__c = '02/10/2015';
            tsc.Legacy_Create_By__C = 'Alfred A';
            tsc.Legacy_Update_Date__c = '02/15/2015';
            tsc.Legacy_Update_By__c = 'GGASS';
            tsc.Cancelled__c = true;
            tsc.Order__c = orderRec.Id;
            insert tsc;
            
            List<Case> caseSub = TestDataFactory.createCase(2, 'Complaint - Newspaper');
            for (Case caseData: caseSub){
                caseData.AccountId = acct.Id;
                caseData.ContactId = con[0].Id;
                caseData.Order__c = orderRec.Id;
                caseData.Origin = 'Email';
                caseData.Outcome__c = 'Retained';
                caseData.Urgent_Request__c = true; 
                caseData.Requires_Urgent_Approval__c = true;                      
                caseData.Rejected_Renewal__c = true;   
                caseData.Category__c = 'Subscription Request';
                caseData.Sub_Category__c = 'Start Subscription';  
                caseData.Recipient_Address__c = addressRec[0].Id;
                caseData.Recipient__c = con[0].Id; 
                caseData.New_Order_Details__c = orderRec.Id;    
                caseData.Order_Number__c = orderRec.Id; 
            }
            
            caseSub[0].Earliest_Stop_Date__c = date.today();
            caseSub[0].Stop_Request_Date__c = date.today();           
            caseSub[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Temp Stop');
            caseSub[0].Status = GlobalVariableClass.STATUS_CLOSED;
            caseSub[0].Sub_Status__c = 'Urgent Start Approved';             
            caseSub[0].Requires_Urgent_Approval__c = true;
            caseSub[0].Temp_Stop_Updated__c = tsc.Id;
            caseSub[0].Temp_Stop_Sub__c = sub.Id;
            
            caseSub[1].Sub_Status__c = 'Urgent Start Approved';            
            caseSub[1].RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            
            insert caseSub;
            
            caseSub[0].Sub_Status__c = GlobalVariableClass.TEMP_STOP_APPROVED;
            caseSub[1].Sub_Status__c = 'Goodwill Approved';
            
            //update caseSub;  
            
            Subscription_Vendor__c svc = new Subscription_Vendor__c();
            svc.Legacy_Create_Date__c = '02/10/2015';
            svc.Legacy_Create_By__C = 'Alfred A';
            svc.Legacy_Update_Date__c = '02/15/2015';
            svc.Legacy_Update_By__c = 'GGASS';
            insert svc;
            
            Case_Vendor_Subscription__c  csc = new Case_Vendor_Subscription__c();
            csc.Subscription_Vendor__c = svc.Id;
            csc.Case__c = caseSub[0].Id; 
            insert csc; 
            
          //}
               
            Test.stopTest();

    } 
}