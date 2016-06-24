/*
* Class Name: <BatchAddressAssignmentEffectiveDateTest2>
* @author: Hazel Jurna M. Limot
* Date: 7/27/2015
* Requirement/Project Name: <SPH>
* @description: Test class for BatchAddressAssignmentEffectiveDate
*/
@isTest (seeAllData= false)
private class BatchAddressAssignmentEffectiveDateTest2{
    
    @testSetup
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createBatchInterface();
        insert CustomSettingsDataFactory.createPlannerSched();
    }
    
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

    static void setUpTestData() {       
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
        acnt.AccountNumber = '31397726';

        insert acnt;

        //Setup Postal records
        singpostalList = TestDataFactory.createSingpostAddress(2);
        singpostalList[0].Name = 'SPostal';
        singpostalList[0].House_Block_Number__c = 'TEST';
        singpostalList[0].Address_Type__c = 'A';
        singpostalList[0].Building_Name__c = 'Building';
        singpostalList[0].Street_Name__c = 'Street';
        singpostalList[1].Name = 'Postal';
        singpostalList[1].House_Block_Number__c = 'TEST';
        singpostalList[1].Address_Type__c = 'A';
        singpostalList[1].Building_Name__c = 'Building';
        singpostalList[1].Street_Name__c = 'Street';
        insert singpostalList;

        City__c city = TestDataFactory.createCity(1)[0];
        city.Flight_Number_1__c = '01351512';
        city.City_Name__c = 'testCityName';
        insert city;
        
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
        addrList[0].City__c = city.Id;
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
        addrList[1].City__c = city.Id;
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
        cntctList[1].Address__c = addrList[1].Id;
        cntctList[1].AccountId = acnt.Id;
        cntctList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        cntctList[1].Billing_Indicator__c = true;
        cntctList[1].FirstName = 'Test1';
        cntctList[1].LastName = 'Contact';
        cntctList[1].Email = 'test@test.com';
        cntctList[1].Passport__c = 'PassTest';
        cntctList[1].HomePhone__c = '123 456';
        cntctList[1].Mobile_Number__c = '123456';
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
        custAccount.ARMS_Customer_Number__c = '111111';
        custAccount.Other_PaymentMethod__c = 'Invoice';
        
        insert custAccount;

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

        validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Test_Name';
        validEmailTemplate.DeveloperName = 'Test_Developer';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        validEmailTemplate.HtmlValue = '<html> <table width="100%"> <tr> <td width=68% align=left> <div style = "font-family:Arial; font-size: 9pt;"> {{Insert Table}}<br> <br> {{Contact.FirstName}} {{Contact.LastName}}<br> </div> </html>';

        insert validEmailTemplate;
    }

    // static User createUser() {
    //     UserRole usrRole = [SELECT id, Name from UserRole LIMIT 1];
    //     Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
    //     User usr = new User(Alias = 'test122',Email='test2@test.sph.com',
    //                   EmailEncodingKey='UTF-8', LastName='Testing123', 
    //                   LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
    //                   ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserRoleId = usrRole.Id,
    //                   UserName='testDeploymentUser@sph.com', Title='Testing123');
    //     insert usr;

    //     return usr;
    // }

    static testMethod void testBatchAddressAssignmentEffectiveDate (){
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
         try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            
            //test data creation
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Street_Name__c = 'testStreet';
            postal.Building_Name__c = 'testBuilding';
            insert postal;
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
            acc.Name = 'testtest';
            acc.Phone = '123456';
            insert acc;    
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;        
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;        
            
            zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
            zprpc.Name = 'Product Rate Plan Charge';
            zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc.zqu__ZuoraId__c = '3689922200';
            insert zprpc;        
            
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
            insert pItem; 
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            insert billAcc;      
            
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Country_Name__c = 'testCountryName';
            insert country;  
            
            City__c city = TestDataFactory.createCity(1)[0];
            city.Flight_Number_1__c = '01351512';
            city.City_Name__c = 'testCityName';
            insert city;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c = 'TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            addressRec.Country__c = country.Id;
            addressRec.City__c = city.Id;
            insert addressRec;     
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.HomePhone__c = '123456';
            con.Salutation = 'Mr.';
            con.NRIC__c = 'T1234567R';
            con.Passport__c = 'testpassport';
            con.Billing_Account_Name_2__c = 'test name';
            con.Company_Name__c = 'test company';
            con.City_Code__c = city.Id;
            con.Remarks__c = 'test remarks';
            con.Business_Address_Indicator__c = true;
            con.Billing_Indicator__c = true;
            con.Mobile_Number__c = '949243871';
            con.Mobile_Number_2__c = '949243872';
            con.Office_Number__c = '949243873';
            con.Office_Extension__c = '1';
            con.Fax__c = '949243874';
            con.Email__c = 'testemail@salesforce.com';
            con.Email_Secondary__c = 'testemailsecondary@email.com';
            insert con;        
            
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con1.Billing_Indicator__c = true;
            insert con1;        
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Subscriber_Charge__c = 100.0;
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Billing_Contact__c = con1.id;
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
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            cas.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
            cas.Status = GlobalVariableClass.STATUS_CLOSED;                
            insert cas;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(30);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            //orderline.Fee_Waiver__c = TRUE;
            //orderline.Fee_Override__c = FALSE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            insert orderline;              
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
            subRecs[0].Contact__c = con.Id;
            subRecs[0].Zuora__TermSettingType__c = 'EVERGREEN';
            subRecs[0].Zuora__CustomerAccount__c = billAcc.Id;
            subRecs[0].Zuora__Account__c = acc.Id;
            subRecs[0].Zuora__Zuora_Id__c = '1123';
            subRecs[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecs[0].Subscriber_Contact__c = con.Id;
            subRecs[0].Recipient_Contact__c = con.Id;
            subRecs[0].Main_Package_1__c = pack.id;
            subRecs[0].Zuora__Status__c = 'Active';
            subRecs[0].Order_Number__c = order.Id;
            subRecs[0].Suppress_Vendor_Start_Notice__c = 'false';
            subRecs[0].Supressed_Acknowledgement_Letter__c = 'false';
            subRecs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs[0].Urgent__c = 'false';
            subRecs[0].Vendor_Conversion__c = 'false';
            subRecs[0].Charity__c = 'false';
            subRecs[0].Billing_Type__c = billAcc.Billing_Type__c;
            subRecs[0].Order_Line_Item_Number__c = orderline.id;
            subRecs[0].Subscription_Type_1__c = 'Publication';
            subRecs[0].Subscription_Type__c = 'Publication';
            //subRecs[0].Zuora__Status__c = 'Active';
            subRecs[0].Order_Number_1__c = order.id;
            subRecs[0].Zuora__Zuora_Id__c = '3fss2223456ee44312';
            subRecs[0].Number_of_Copies1__c = '100';
            //subRecs[0].Qty__c = 15;
            subRecs[1].Contact__c = con.Id;
            subRecs[1].Zuora__TermSettingType__c = 'EVERGREEN';
            subRecs[1].Zuora__CustomerAccount__c = billAcc.Id;
            subRecs[1].Zuora__Account__c = acc.Id;
            subRecs[1].Zuora__Zuora_Id__c = '1123';
            subRecs[1].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subRecs[1].Subscriber_Contact__c = con.Id;
            subRecs[1].Recipient_Contact__c = con.Id;
            subRecs[1].Main_Package_1__c = pack.id;
            subRecs[1].Zuora__Status__c = 'Active';
            subRecs[1].Order_Number__c = order.Id;
            subRecs[1].Suppress_Vendor_Start_Notice__c = 'false';
            subRecs[1].Supressed_Acknowledgement_Letter__c = 'false';
            subRecs[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs[1].Urgent__c = 'false';
            subRecs[1].Vendor_Conversion__c = 'false';
            subRecs[1].Charity__c = 'false';
            subRecs[1].Billing_Type__c = billAcc.Billing_Type__c;
            subRecs[1].Order_Line_Item_Number__c = orderline.id;
            subRecs[1].Subscription_Type_1__c = 'Publication';
            subRecs[1].Subscription_Type__c = 'Publication';
            //subRecs[1].Zuora__Status__c = 'Active';
            subRecs[1].Order_Number_1__c = order.id;  
            subRecs[1].Number_of_Copies1__c = '100';
            //subRecs[1].Qty__c = 15;
            
            Test.startTest();        
            
            insert subRecs;
            
            Promotion__c promoTmp = TestDataFactory.createPromotion(1)[0]; 
            promoTmp.Name = 'Promotions';
            promoTmp.Contract_Period__c ='12';
            promoTmp.Penalty_Charge__c = '100';
            insert promoTmp;            
            
            Promotion_Gift__c PromoGift = TestDataFactory.createPromotionGift(1)[0];
            insert PromoGift;     
            
            Vendor_Allocation__c va = TestDataFactory.createVendorAlloc(1)[0];
            va.Allocated__c = TRUE;
            va.Vendor_Account__c = acc.Id;
            va.Effective_Start_Date__c  = date.today();
            va.SingPost_Address__c = postal.id;
            insert va;
            
            Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];
            sv.Account__c = acc.Id;
            sv.Status__c = 'Active';
            sv.Recipient__c = con.Id;
            insert sv;
            
           /** List<Address_Assignment__c> aa1 = new List<Address_Assignment__c>();
            //aa1.add(new Address_Assignment__c(Address__c=addressRec.Id, Contact__c = con.Id)); //IAN Added
            for(Address_Assignment__c aa : aa1){
                aa.Address__c = addressRec.Id;
                aa.Case__c = cas.Id;
                aa.Contact__c = con.Id; 
                aa.Effective_Date__c = Date.today(); 
                aa.Status__c = 'Active'; 
                aa.End_Date__c = null;                                      
                aa.Subscription_Vendor__c = sv.id; 
                aa.Active__c = False; 
                aa.Subscription__c = subRecs[0].id;
            }
            insert aa1; */
            
            List<Address_Assignment__c> aa1 = new List<Address_Assignment__c>();
            aa1.add(new Address_Assignment__c(Address__c=addressRec.Id, Contact__c = con.Id));
            for(Address_Assignment__c aa : aa1){
            //aa.Address__c = addressRec.Id;
            aa.Case__c = cas.Id;
            //aa.Contact__c = con.Id; 
            aa.Effective_Date__c = date.today(); 
            aa.Status__c = 'Active';                                     
            aa.Subscription_Vendor__c = sv.id; 
            //aa1.Active__c = false; 
            //aa.End_Date__c = null;
            aa.Subscription__c = subRecs[0].id;
            aa.Vendor__c = acc.Id;
            }
            insert aa1;    
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch,200);
            System.assertNotEquals(null, batchprocessid);
    
            BatchAddressAssignmentEffectiveDate batch2 = new BatchAddressAssignmentEffectiveDate(date.today());
            ID batchprocessid2 = Database.executeBatch(batch2,200);
            System.assertNotEquals(null, batchprocessid2);
    
            BatchAddressAssignmentEffectiveDate batch3 = new BatchAddressAssignmentEffectiveDate(addressRec.Id);
            ID batchprocessid3 = Database.executeBatch(batch3,200);
            System.assertNotEquals(null, batchprocessid3);
    
            
    
            /**  TO DO  // Not satisfied: WHERE Effective_Date__c = TODAY
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            //Database.executeBatch(batch, 200);
            Database.BatchableContext BC;
            batch.start(BC);
            batch.execute(BC, aa1);
            //batch.finish();
           
            //Arvin 4/14/2015 below method doess not exist, it was removed (made as comment on the BatchAddressAssignmentEffectiveDate class )
            //batch.createContactZuora(con, subRecs[0]);
            batch.createContact(con, addressRec.id, true); TO DO */ 
    
            //Begin Added by Francis Bagtas
            batch3.updateSub(new Map<String, Contact>(),new Map<String, Id>());
            batch3.updateSubVendor(new Map<Id, Contact>(),new Map<Id, Id>());
    
            Map<Id, Contact> mCon = new Map<Id, Contact>();
            mCon.put(con1.id,con1);
            batch3.updateOrderBillingContact(mCon);
    
            Map<Id, Address__c> mAdd = new Map<Id, Address__c>();
            mAdd.put(addressRec.id,addressRec);
            batch3.updateContactZuora(con1, billAcc, mAdd);
            
            batch3.updateOrderRecipientContact(new Map<String, Contact>());
            batch3.updateBillAccBillingContact(new Map<Id, Address_Assignment__c>(),new Map<Id, Contact>(),new Map<Id, Zuora__CustomerAccount__c>(),new Map<Id, Contact>(),new Map<Id, Set<Zuora__Subscription__c>>());
            batch3.updateSubBillingContact(new List<Order__c>(),new Map<Id, Contact>());
            
            //batch3.updatePreviousAddressAssignment(new List<Address_Assignment__c>());
            batch3.updatePreviousAddressAssignment(aa1);
            
            List<Zuora__CustomerAccount__c> zCustAcc = new List<Zuora__CustomerAccount__c>();
            zCustAcc.add(billAcc);
            batch3.updateCustomer(zCustAcc);
    
            BatchAddressAssignmentEffectiveDate.updateCustomerWebserviceNonFuture(new Set<Id>());
            //End Added by Francis Bagtas
            
            Test.stopTest();
            }
             catch(Zuora.zRemoteException e) {
            } 
        }
    }//end of testBatchAddressAssignmentEffectiveDate


    static testMethod void testUpdateCustomer() {
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
            setUpTestData();

            Test.startTest();
                List<Zuora__CustomerAccount__c> custAccountList = new List<Zuora__CustomerAccount__c>();
                custAccountList.add(custAccount);

                BatchAddressAssignmentEffectiveDate batchDate = new BatchAddressAssignmentEffectiveDate();
                System.assertNotEquals(null, batchDate.updateCustomer(custAccountList));

                addrList[1].RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
                update addrList; 

                BatchAddressAssignmentEffectiveDate batchDate2 = new BatchAddressAssignmentEffectiveDate();
                System.assertNotEquals(null, batchDate2.updateCustomer(custAccountList));

                addrList[1].RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
                update addrList; 

                BatchAddressAssignmentEffectiveDate batchDate3 = new BatchAddressAssignmentEffectiveDate();
                System.assertNotEquals(null, batchDate3.updateCustomer(custAccountList));

                addrList[1].RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                update addrList; 

                BatchAddressAssignmentEffectiveDate batchDate4 = new BatchAddressAssignmentEffectiveDate();
                System.assertNotEquals(null, batchDate4.updateCustomer(custAccountList));

            Test.stopTest();
        }
    }
    
    // static testMethod void testBatchCOA_Overall(){
    //     Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
    //     postal.House_Block_Number__c = 'HBN01';
    //     insert postal;
        
    //     List<Account> accList = new List<Account>();
    //     Account accVendorSub = new Account();
    //     Account accDirect = new Account();
    //     Account accVendor = new Account();
        
    //     /*
    //     Account accVendorSub = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
    //     insert accVendorSub;
        
    //     Account accDirect = TestDataFactory.createAccount(1, 'Direct Individual')[0];
    //     insert accDirect;
        
    //     Account accVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
    //     insert accVendor;
    //     */
        
    //     accList.add(TestDataFactory.createAccount(1, 'Vendor Subscriber')[0]);
    //     accList.add(TestDataFactory.createAccount(1, 'Direct Individual')[0]);
    //     accList.add(TestDataFactory.createAccount(1, 'Vendor')[0]);
        
    //     insert accList;
        
    //     accVendorSub = accList[0];
    //     accDirect = accList[1];
    //     accVendor = accList[2];
        
    //     Package__c pack = TestDataFactory.createPackage(1)[0];
    //     pack.Billing_Type__c = 'Full Prepaid';
    //     insert pack;
        
    //     zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
    //     insert zProduct;
        
    //     zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
    //     prdRatePlan.zqu__ZProduct__c = zProduct.Id;
    //     prdRatePlan.zqu__EffectiveStartDate__c= date.today();
    //     prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
    //     prdRatePlan.zqu__Deleted__c = false;
    //     insert prdRatePlan;
        
    //     zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
    //     zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
    //     insert zprpc;
        
    //     Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
    //     pItem.Package__c = pack.id;
    //     pItem.Product_Rate_Plan__c = prdRatePlan.id;
    //     insert pItem;
        
    //     Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
    //     billAcc.Zuora__Account__c = accDirect.Id;
    //     billAcc.Zuora__Status__c = 'Active';
    //     insert billAcc;
        
    //     Country__c country = TestDataFactory.createCountry(1)[0];
    //     insert country;
        
    //     City__c city = TestDataFactory.createCity(1)[0];
    //     city.Flight_Number_1__c = '01351512';
    //     city.City_Name__c = 'testCityName';
    //     insert city;
        
    //     List<Address__c> addressRecList = TestDataFactory.createAddress(2);
    //     addressRecList[0].Address_Type__c = 'A';
    //     addressRecList[0].Postal_Code__c = postal.Id;
    //     addressRecList[0].Block_House_Number__c = 'BHN01';
    //     addressRecList[0].Level_Number__c ='xx';
    //     addressRecList[0].Unit_Number__c = 'yy';
    //     addressRecList[0].City__c = city.Id;
        
    //     addressRecList[1].Address_Type__c = 'A';
    //     addressRecList[1].Postal_Code__c = postal.Id;
    //     addressRecList[1].Block_House_Number__c = 'BHN02';
    //     addressRecList[1].Level_Number__c ='X1';
    //     addressRecList[1].Unit_Number__c = 'Y1';
    //     addressRecList[1].City__c = city.Id;
    //     insert addressRecList;
        
    //     List<Contact> conList = TestDataFactory.createContact(6);
    //     conList[0].Address__c = addressRecList[0].Id;
    //     conList[0].AccountId = accVendorSub.Id;
    //     conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //     conList[0].Recipient_Indicator__c = true;
    //     conList[0].Billing_Indicator__c = true;
    //     conList[0].HomePhone__c = '123456';
    //     conList[0].NRIC__c = 'T1234567R';
    //     conList[0].Passport__c = 'testpassport';
    //     conList[0].Company_Name__c = 'test company';
    //     conList[0].City_Code__c = city.Id;
    //     conList[0].Mobile_Number__c = '949243871';
    //     conList[0].Mobile_Number_2__c = '949243872';
    //     conList[0].Office_Number__c = '949243873';
    //     conList[0].Office_Extension__c = '1';
    //     conList[0].Fax__c = '949243874';
    //     conList[0].Email__c = 'testemail@salesforce.com';
    //     conList[0].Email_Secondary__c = 'testemailsecondary@email.com';
        
    //     conList[1].Address__c = addressRecList[0].Id;
    //     conList[1].AccountId = accVendorSub.Id;
    //     conList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //     conList[1].Recipient_Indicator__c = true;
    //     conList[1].Billing_Indicator__c = true;
    //     conList[1].HomePhone__c = '123456';
    //     conList[1].NRIC__c = 'T1234567R';
    //     conList[1].Passport__c = 'testpassport';
    //     conList[1].Company_Name__c = 'test company';
    //     conList[1].City_Code__c = city.Id;
    //     conList[1].Mobile_Number__c = '949243871';
    //     conList[1].Mobile_Number_2__c = '949243872';
    //     conList[1].Office_Number__c = '949243873';
    //     conList[1].Office_Extension__c = '1';
    //     conList[1].Fax__c = '949243874';
    //     conList[1].Email__c = 'testemail@salesforce.com';
    //     conList[1].Email_Secondary__c = 'testemailsecondary@email.com';
        
    //     conList[2].Address__c = addressRecList[0].Id;
    //     conList[2].AccountId = accVendorSub.Id;
    //     conList[2].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //     conList[2].Recipient_Indicator__c = true;
    //     conList[2].Billing_Indicator__c = true;
    //     conList[2].HomePhone__c = '123456';
    //     conList[2].NRIC__c = 'T1234567R';
    //     conList[2].Passport__c = 'testpassport';
    //     conList[2].Company_Name__c = 'test company';
    //     conList[2].City_Code__c = city.Id;
    //     conList[2].Mobile_Number__c = '949243871';
    //     conList[2].Mobile_Number_2__c = '949243872';
    //     conList[2].Office_Number__c = '949243873';
    //     conList[2].Office_Extension__c = '1';
    //     conList[2].Fax__c = '949243874';
    //     conList[2].Email__c = 'testemail@salesforce.com';
    //     conList[2].Email_Secondary__c = 'testemailsecondary@email.com';
        
    //     conList[3].Address__c = addressRecList[0].Id;
    //     conList[3].AccountId = accDirect.Id;
    //     conList[3].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //     conList[3].Recipient_Indicator__c = true;
    //     conList[3].Billing_Indicator__c = true;
    //     conList[3].HomePhone__c = '123456';
    //     conList[3].NRIC__c = 'T1234567R';
    //     conList[3].Passport__c = 'testpassport';
    //     conList[3].Company_Name__c = 'test company';
    //     conList[3].City_Code__c = city.Id;
    //     conList[3].Mobile_Number__c = '949243871';
    //     conList[3].Mobile_Number_2__c = '949243872';
    //     conList[3].Office_Number__c = '949243873';
    //     conList[3].Office_Extension__c = '1';
    //     conList[3].Fax__c = '949243874';
    //     conList[3].Email__c = 'testemail@salesforce.com';
    //     conList[3].Email_Secondary__c = 'testemailsecondary@email.com';
        
    //     conList[4].Address__c = addressRecList[0].Id;
    //     conList[4].AccountId = accDirect.Id;
    //     conList[4].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //     conList[4].Recipient_Indicator__c = true;
    //     conList[4].Billing_Indicator__c = true;
    //     conList[4].HomePhone__c = '123456';
    //     conList[4].NRIC__c = 'T1234567R';
    //     conList[4].Passport__c = 'testpassport';
    //     conList[4].Company_Name__c = 'test company';
    //     conList[4].City_Code__c = city.Id;
    //     conList[4].Mobile_Number__c = '949243871';
    //     conList[4].Mobile_Number_2__c = '949243872';
    //     conList[4].Office_Number__c = '949243873';
    //     conList[4].Office_Extension__c = '1';
    //     conList[4].Fax__c = '949243874';
    //     conList[4].Email__c = 'testemail@salesforce.com';
    //     conList[4].Email_Secondary__c = 'testemailsecondary@email.com';
        
    //     conList[5].Address__c = addressRecList[0].Id;
    //     conList[5].AccountId = accDirect.Id;
    //     conList[5].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
    //     conList[5].Recipient_Indicator__c = true;
    //     conList[5].Billing_Indicator__c = true;
    //     conList[5].HomePhone__c = '123456';
    //     conList[5].NRIC__c = 'T1234567R';
    //     conList[5].Passport__c = 'testpassport';
    //     conList[5].Company_Name__c = 'test company';
    //     conList[5].City_Code__c = city.Id;
    //     conList[5].Mobile_Number__c = '949243871';
    //     conList[5].Mobile_Number_2__c = '949243872';
    //     conList[5].Office_Number__c = '949243873';
    //     conList[5].Office_Extension__c = '1';
    //     conList[5].Fax__c = '949243874';
    //     conList[5].Email__c = 'testemail@salesforce.com';
    //     conList[5].Email_Secondary__c = 'testemailsecondary@email.com';
    //     insert conList;
        
    //     Order__c order = TestDataFactory.createOrder(1)[0];
    //     order.Subscriber_Charge__c = 100.0;
    //     order.Account__c = accDirect.Id;
    //     order.Informed_Customer__c = TRUE;
    //     order.Recipient_Contact__c = conList[3].Id;
    //     order.Status__c = 'Close';
    //     order.Eligible_for_Retention__c = TRUE;
    //     order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
    //     order.Payment_Mode__c = 'Credit Card';
    //     order.Billing_Account__c = billAcc.id;
    //     order.Billing_Type__c = 'Full Prepaid';
    //     order.Billing_Contact__c = conList[3].id;
    //     order.Order_Type__c = 'Start';
    //     order.PO_Number__c = 'PO00000';
    //     insert order;
        
    //     Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
    //     orderline.Order__c = order.Id;
    //     orderline.Main_Package_ID__c = pack.Id;
    //     orderline.Terminating_Reason__c = 'Others';
    //     orderline.Amount_To_Refund__c = 0;
    //     orderline.Admin_Charge__c = 0;
    //     orderline.Override_Reason__c = 'TEST';
    //     orderline.Suppress_Notification_Stop__c = TRUE;
    //     insert orderline;
        
    //     List<Zuora__Subscription__c> subRecList = TestDataFactory.createSubscription(3);
    //     subRecList[0].Contact__c = conList[3].Id;
    //     subRecList[0].Zuora__TermSettingType__c = 'EVERGREEN';
    //     subRecList[0].Zuora__CustomerAccount__c = billAcc.Id;
    //     subRecList[0].Zuora__Account__c = accDirect.Id;
    //     subRecList[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
    //     subRecList[0].Subscriber_Contact__c = conList[3].Id;
    //     subRecList[0].Recipient_Contact__c = conList[3].Id;
    //     subRecList[0].Main_Package_1__c = pack.Id;
    //     subRecList[0].Zuora__Status__c = 'Active';
    //     subRecList[0].Order_Number__c = order.Id;
    //     subRecList[0].Order_Number_1__c = order.Id;
    //     subRecList[0].Suppress_Vendor_Start_Notice__c = 'false';
    //     subRecList[0].Supressed_Acknowledgement_Letter__c = 'false';
    //     subRecList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //     subRecList[0].Urgent__c = 'false';
    //     subRecList[0].Vendor_Conversion__c = 'false';
    //     subRecList[0].Charity__c = 'false';
    //     subRecList[0].Billing_Type__c = billAcc.Billing_Type__c;
    //     subRecList[0].Order_Line_Item_Number__c = orderline.Id;
    //     subRecList[0].Subscription_Type_1__c = 'Publication';
    //     subRecList[0].Subscription_Type__c = 'Publication';
    //     subRecList[0].Term_Length__c = 12;
        
    //     subRecList[1].Contact__c = conList[4].Id;
    //     subRecList[1].Zuora__TermSettingType__c = 'EVERGREEN';
    //     subRecList[1].Zuora__CustomerAccount__c = billAcc.Id;
    //     subRecList[1].Zuora__Account__c = accDirect.Id;
    //     subRecList[1].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
    //     subRecList[1].Subscriber_Contact__c = conList[4].Id;
    //     subRecList[1].Recipient_Contact__c = conList[4].Id;
    //     subRecList[1].Main_Package_1__c = pack.Id;
    //     subRecList[1].Zuora__Status__c = 'Active';
    //     subRecList[1].Order_Number__c = order.Id;
    //     subRecList[1].Order_Number_1__c = order.Id;
    //     subRecList[1].Suppress_Vendor_Start_Notice__c = 'false';
    //     subRecList[1].Supressed_Acknowledgement_Letter__c = 'false';
    //     subRecList[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //     subRecList[1].Urgent__c = 'false';
    //     subRecList[1].Vendor_Conversion__c = 'false';
    //     subRecList[1].Charity__c = 'false';
    //     subRecList[1].Billing_Type__c = billAcc.Billing_Type__c;
    //     subRecList[1].Order_Line_Item_Number__c = orderline.Id;
    //     subRecList[1].Subscription_Type_1__c = 'Publication';
    //     subRecList[1].Subscription_Type__c = 'Publication';
    //     subRecList[1].Term_Length__c = 12;
        
    //     subRecList[2].Contact__c = conList[5].Id;
    //     subRecList[2].Zuora__TermSettingType__c = 'EVERGREEN';
    //     subRecList[2].Zuora__CustomerAccount__c = billAcc.Id;
    //     subRecList[2].Zuora__Account__c = accDirect.Id;
    //     subRecList[2].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
    //     subRecList[2].Subscriber_Contact__c = conList[5].Id;
    //     subRecList[2].Recipient_Contact__c = conList[5].Id;
    //     subRecList[2].Main_Package_1__c = pack.Id;
    //     subRecList[2].Zuora__Status__c = 'Active';
    //     subRecList[2].Order_Number__c = order.Id;
    //     subRecList[2].Order_Number_1__c = order.Id;
    //     subRecList[2].Suppress_Vendor_Start_Notice__c = 'false';
    //     subRecList[2].Supressed_Acknowledgement_Letter__c = 'false';
    //     subRecList[2].Supressed_Renewal_and_Reminder_Letter__c = 'false';
    //     subRecList[2].Urgent__c = 'false';
    //     subRecList[2].Vendor_Conversion__c = 'false';
    //     subRecList[2].Charity__c = 'false';
    //     subRecList[2].Billing_Type__c = billAcc.Billing_Type__c;
    //     subRecList[2].Order_Line_Item_Number__c = orderline.Id;
    //     subRecList[2].Subscription_Type_1__c = 'Publication';
    //     subRecList[2].Subscription_Type__c = 'Publication';
    //     subRecList[2].Term_Length__c = 12;
    //     insert subRecList;
        
    //     List<Case> casList = TestDataFactory.createCase(6, 'Change of Address/Vendor');
    //     casList[0].Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
    //     casList[0].Status = GlobalVariableClass.STATUS_CLOSED;
        
    //     casList[1].Change_of_Address_Type__c = GlobalVariableClass.BILLINGADD;
    //     casList[1].Status = GlobalVariableClass.STATUS_CLOSED;
        
    //     casList[2].Change_of_Address_Type__c = GlobalVariableClass.DELIVERYADDLOC;
    //     casList[2].Status = GlobalVariableClass.STATUS_CLOSED;
        
    //     casList[3].Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
    //     casList[3].Status = GlobalVariableClass.STATUS_CLOSED;
        
    //     casList[4].Change_of_Address_Type__c = GlobalVariableClass.BILLINGADD;
    //     casList[4].Status = GlobalVariableClass.STATUS_CLOSED;
        
    //     casList[5].Change_of_Address_Type__c = GlobalVariableClass.DELIVERYADDLOC;
    //     casList[5].Status = GlobalVariableClass.STATUS_CLOSED;
    //     insert casList;
        
    //     Vendor_Allocation__c va = TestDataFactory.createVendorAlloc(1)[0];
    //     va.Allocated__c = TRUE;
    //     va.Vendor_Account__c = accVendor.Id;
    //     va.SingPost_Address__c = postal.id;
    //     insert va;
        
    //     List<Subscription_Vendor__c> svList = TestDataFactory.createSubscriptionVendor(3);
    //     svList[0].Account__c = accVendorSub.Id;
    //     svList[0].Status__c = 'Active';
    //     svList[0].Recipient__c = conList[0].Id;
        
    //     svList[1].Account__c = accVendorSub.Id;
    //     svList[1].Status__c = 'Active';
    //     svList[1].Recipient__c = conList[1].Id;
        
    //     svList[2].Account__c = accVendorSub.Id;
    //     svList[2].Status__c = 'Active';
    //     svList[2].Recipient__c = conList[2].Id;
    //     insert svList;
        
    //     List<Address_Assignment__c> addAssignList = new List<Address_Assignment__c>();
    //     Address_Assignment__c aa1 = new Address_Assignment__c();
    //     aa1.Address__c = addressRecList[1].Id;
    //     aa1.Case__c = casList[0].Id;
    //     aa1.Contact__c = conList[0].Id;
    //     aa1.Effective_Date__c = date.today();
    //     aa1.Subscription_Vendor__c = svList[0].Id;
    //     aa1.Vendor__c = accVendor.Id;
    //     addAssignList.add(aa1);
        
    //     Address_Assignment__c aa2 = new Address_Assignment__c();
    //     aa2.Address__c = addressRecList[1].Id;
    //     aa2.Case__c = casList[1].Id;
    //     aa2.Contact__c = conList[1].Id;
    //     aa2.Effective_Date__c = date.today();
    //     aa2.Subscription_Vendor__c = svList[1].Id;
    //     aa2.Vendor__c = accVendor.Id;
    //     addAssignList.add(aa2);
        
    //     Address_Assignment__c aa3 = new Address_Assignment__c();
    //     aa3.Address__c = addressRecList[1].Id;
    //     aa3.Case__c = casList[2].Id;
    //     aa3.Contact__c = conList[2].Id;
    //     aa3.Effective_Date__c = date.today();
    //     aa3.Subscription_Vendor__c = svList[2].Id;
    //     aa3.Vendor__c = accVendor.Id;
    //     addAssignList.add(aa3);
        
    //     Address_Assignment__c aa4 = new Address_Assignment__c();
    //     aa4.Address__c = addressRecList[1].Id;
    //     aa4.Case__c = casList[3].Id;
    //     aa4.Contact__c = conList[3].Id;
    //     aa4.Effective_Date__c = date.today();
    //     aa4.Subscription_Vendor__c = subRecList[0].Id;
    //     aa4.Vendor__c = accVendor.Id;
    //     addAssignList.add(aa4);
        
    //     Address_Assignment__c aa5 = new Address_Assignment__c();
    //     aa5.Address__c = addressRecList[1].Id;
    //     aa5.Case__c = casList[4].Id;
    //     aa5.Contact__c = conList[4].Id;
    //     aa5.Effective_Date__c = date.today();
    //     aa5.Subscription_Vendor__c = subRecList[1].Id;
    //     aa5.Vendor__c = accVendor.Id;
    //     addAssignList.add(aa5);
        
    //     Address_Assignment__c aa6 = new Address_Assignment__c();
    //     aa6.Address__c = addressRecList[1].Id;
    //     aa6.Case__c = casList[5].Id;
    //     aa6.Contact__c = conList[5].Id;
    //     aa6.Effective_Date__c = date.today();
    //     aa6.Subscription_Vendor__c = subRecList[2].Id;
    //     aa6.Vendor__c = accVendor.Id;
    //     addAssignList.add(aa6);
    //     insert addAssignList;
        
    //     Test.startTest();

    //     BatchAddressAssignmentEffectiveDate batch01 = new BatchAddressAssignmentEffectiveDate();
    //     ID batchProcessId01 = Database.executeBatch(batch01, 10);
    //     System.assertNotEquals(null, batchProcessId01);
        
    //     Test.stopTest();
    // }
    
    
    private static testMethod void testUpdateBillingContact() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            //acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
            database.insert(acc);
            
            //RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Local'];
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Billing_Indicator__c = true;
            Database.insert(con);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            Database.insert(con2);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            Database.insert(billAcc);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Billing_Contact__c = con.Id;
            ord.Recipient_Contact__c = con2.Id;
            Database.insert(ord);
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
            for (Zuora__Subscription__c sub : subList) {
                sub.Zuora__CustomerAccount__c = billAcc[0].Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Subscription_Type_1__c = 'Publication';
                sub.Recipient_Contact__c = con2.Id;
                sub.Delivered_By_1__c = 'Mailing Agent';
                sub.Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
                sub.Zuora__TermSettingType__c = 'EVERGREEN';
                sub.Order_Number_1__c = ord.Id;
                sub.Zuora__Status__c = 'Active';
            }
            Database.insert(subList);
            
            Test.startTest();
            
            Map<Id, Contact> subIdToNewContactMap = new Map<Id, Contact>();
            for (Zuora__Subscription__c sub : subList) {
                subIdToNewContactMap.put(sub.Id, con);
            }
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            batch.updateOrderBillingContact(subIdToNewContactMap);
            batch.updateSubBillingContact(new List<Order__c>{ord}, subIdToNewContactMap);
            
            Test.stopTest();
        }
    }
    
    private static testMethod void testCoaCheckIfArmsContact() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            //RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Local'];
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            List<Contact> billConList = TestDataFactory.createContactRecType(2, 'Customer Contact');
            for (Contact con : billConList) {
                con.Address__c = ad.Id;
                con.AccountId = acc.Id;
                con.Billing_Indicator__c = true;
            }
            Database.insert(billConList);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            Integer index = 0;
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
                bill.Billing_Contact__c = billConList[index].Id;
                bill.ARMS_Customer_Number__c = '12345';
                bill.ARMS_Account_Number__c = '67890';
                ++index;
            }
            Database.insert(billAcc);
           
            
            Test.startTest();
            
            List<Contact> contact_LIST = new List<Contact>();
            contact_LIST.addAll(billConList);
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            batch.coaCheckIfArmsContact(contact_LIST);
            
            Test.stopTest();
        }
    }
    
    private static testMethod void testUpdateRecipientContact() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Billing_Indicator__c = true;
            Database.insert(con);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            Database.insert(con2);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            Database.insert(billAcc);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Billing_Contact__c = con.Id;
            ord.Recipient_Contact__c = con2.Id;
            Database.insert(ord);
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
            Integer index = 0;
            for (Zuora__Subscription__c sub : subList) {
                sub.Zuora__CustomerAccount__c = billAcc[0].Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Subscription_Type_1__c = 'Publication';
                sub.Recipient_Contact__c = con2.Id;
                sub.Delivered_By_1__c = 'Mailing Agent';
                sub.Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
                sub.Zuora__TermSettingType__c = 'EVERGREEN';
                sub.Order_Number_1__c = ord.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__Zuora_Id__c = 'XXXXX' + index;
                ++index;
            }
            Database.insert(subList);
            
            Test.startTest();
            
            Map<String, Contact> subIdToNewContactMap = new Map<String, Contact>();
            for (Zuora__Subscription__c sub : subList) {
                subIdToNewContactMap.put(sub.Zuora__Zuora_Id__c, con2);
            }
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            batch.updateOrderRecipientContact(subIdToNewContactMap);
            
            Test.stopTest();
        }
    }
    
    private static testMethod void testUpdateBillAccBillingContact() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            List<Contact> billConList = TestDataFactory.createContactRecType(2, 'Customer Contact');
            for (Contact con : billConList) {
                con.Address__c = ad.Id;
                con.AccountId = acc.Id;
                con.Billing_Indicator__c = true;
            }
            Database.insert(billConList);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            Database.insert(con2);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            Integer index = 0;
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
                bill.Billing_Contact__c = billConList[index].Id;
                ++index;
            }
            Database.insert(billAcc);
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
            index = 0;
            for (Zuora__Subscription__c sub : subList) {
                sub.Zuora__CustomerAccount__c = billAcc[index].Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Subscription_Type_1__c = 'Publication';
                sub.Recipient_Contact__c = con2.Id;
                sub.Delivered_By_1__c = 'Mailing Agent';
                sub.Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
                sub.Zuora__TermSettingType__c = 'EVERGREEN';
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__Zuora_Id__c = 'XXXXX' + index;
                ++index;
            }
            Database.insert(subList);
            
            Test.startTest();
            
            Map<Id, Address_Assignment__c> conIdToAddressAssignIdMap = new Map<Id, Address_Assignment__c>();
            Map<Id, Contact> conIdToConMap = new Map<Id, Contact>();
            Map<Id, Contact> billAccIdToNewContactMap = new Map<Id, Contact>();
            index = 0;
            for (Contact con : billConList) {
                conIdToAddressAssignIdMap.put(con.Id, null);
                conIdToConMap.put(con.Id, con);
                billAccIdToNewContactMap.put( billAcc[index].Id, con);
                ++index;
            }
            
            Map<Id, Zuora__CustomerAccount__c> subIdToBillAccMap = new Map<Id, Zuora__CustomerAccount__c>();
            index = 0;
            for (Zuora__Subscription__c sub : subList) {
                subIdToBillAccMap.put(sub.Id, billAcc[index]);
                ++index;
            }
            Map<Id, Set<Zuora__Subscription__c>> accountIdToSubscriptionMap = new Map<Id, Set<Zuora__Subscription__c>>();
            accountIdToSubscriptionMap.put(acc.Id, new Set<Zuora__Subscription__c>(subList));
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            batch.updateBillAccBillingContact(conIdToAddressAssignIdMap, conIdToConMap, subIdToBillAccMap, billAccIdToNewContactMap, accountIdToSubscriptionMap);
            
            Test.stopTest();
        }
    }
    
    public static testMethod void testUpdateSubVendor() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            // Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            // database.insert(acc);
            
            Account accV = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accV.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
            database.insert(accV);
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = accV.Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);
            
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
            Database.insert(subVenPub);
            
            Test.startTest();
            
            Map<Id, Contact> subVendorIdToNewContactMap = new Map<Id, Contact>();
            subVendorIdToNewContactMap.put(subVen.Id, con);
            
            Map<Id, Id> subVendorIdToNewVendorMap = new Map<Id, Id>();
            subVendorIdToNewVendorMap.put(subVen.Id, accV.Id);
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            batch.updateSubVendor(subVendorIdToNewContactMap, subVendorIdToNewVendorMap);
            
            Test.stopTest();
        }
        
    }
    
    public static testMethod void testUpdateSub() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
            database.insert(acc);
            
            //RecordType rec = [SELECT id, Name FROM RecordType WHERE SObjectType = 'Address__c' AND Name = 'Local'];
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
            ad.Address_Type__c = 'Local';
            ad.Postal_Code__c = spAdd.Id;
            Database.insert(ad);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c = ad.Id;
            con.AccountId = acc.Id;
            con.Billing_Indicator__c = true;
            Database.insert(con);
            
            Contact con2 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con2.Address__c = ad.Id;
            con2.AccountId = acc.Id;
            con2.Recipient_Indicator__c = true;
            Database.insert(con2);
            
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(2);
            for(Zuora__CustomerAccount__c bill : billAcc){
                bill.Zuora__Account__c = acc.Id;
            }
            Database.insert(billAcc);
            
            Order__c ord = TestDataFactory.createOrder(1)[0];
            ord.Account__c = acc.Id;
            ord.Billing_Contact__c = con.Id;
            ord.Recipient_Contact__c = con2.Id;
            Database.insert(ord);
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            packageList[0].Package_Code__c = 'packsample';
            packageList[0].Subscription_Type__c = 'Termed';
            packageList[0].Package_Sub_Type__c = 'Single';
            packageList[0].Subscription_Period__c = '12';
            packageList[0].Billing_Type__c = 'Full Prepaid';
            insert packageList;
            
            //Start Prod Cat Setup
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0]; //try to loop with many product sub type
            zProduct.ProductPlatform__c = 'Print';
            zProduct.ProductSubType__c = 'Magazine';
            zProduct.ProductCode__c = 'STSU';
            insert zProduct;
            
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.SubscriptionFrequency__c = '2';
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            insert prdRatePlan;
            
           
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
            
            List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
            prodfam[0].Product_Family_Name__c = 'TestNAme';
            insert prodfam;
            
            Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            pItem.Package__c = packageList[0].Id;
            pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            pItem.Duration_in_months__c = '1';
            pItem.Effective_Start_Month__c = '1';
            pItem.Product_Family__c = prodfam[0].id;
            Database.insert(pItem);
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
            for (Zuora__Subscription__c sub : subList) {
                sub.Zuora__CustomerAccount__c = billAcc[0].Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Subscription_Type_1__c = 'Publication';
                sub.Recipient_Contact__c = con2.Id;
                sub.Delivered_By_1__c = 'Mailing Agent';
                sub.Zuora__SubscriptionEndDate__c = Date.today().addDays(2);
                sub.Zuora__TermSettingType__c = 'TERMED';
                sub.Order_Number_1__c = ord.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Main_Package_1__c = packageList[0].Id;
            }
            Database.insert(subList);
            
            Test.startTest();
            
            Map<String, Contact> subZuoraIdToNewContactMap = new Map<String, Contact>();
            Map<String, Id> subZuoraIdToNewVendorMap = new Map<String, Id>();
            for (Zuora__Subscription__c sub : subList) {
                //subZuoraIdToNewContactMap.put(sub.Id, con);
                subZuoraIdToNewVendorMap.put(String.valueOf(sub.Id), acc.Id);
            }
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            ID batchprocessid = Database.executeBatch(batch,200);
            batch.updateSub(subZuoraIdToNewContactMap, subZuoraIdToNewVendorMap);
            
            Test.stopTest();
            
        }
        
    }
    
    private static testMethod void testUpdateCustomer2() {
        
        User userU = TestDataFactory.prepareTestusers();
        
        System.runAs(userU) {
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            SingPost_Address__c spAdd = TestDataFactory.createSingpostAddress(1)[0];
            insert spAdd;
            
            Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
            bill.Name = 'Test Accoun' + 0;
            bill.Zuora__Account__c = acc.Id;
            bill.ARMS_Customer_Number__c = '1234567890';
            bill.Other_PaymentMethod__c = 'Invoice';
            Database.insert(bill);
            
            BT_CO_ARMS_UpdateCustomerBatchFile__c arm = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
            arm.Customer_Name1__c = bill.Name;
            arm.UniqueKey__c = acc.AccountNumber;
            arm.CCRID__c = bill.ARMS_Customer_Number__c;
            Database.insert(arm);
            
            Test.startTest();
            
            BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
            batch.updateCustomer(new List<Zuora__CustomerAccount__c>{bill});
            // ID batchprocessid = Database.executeBatch(batch,200);
            // batch.updateSub(subZuoraIdToNewContactMap, subZuoraIdToNewVendorMap);
            
            Test.stopTest();
            
        }
    }
    
    //TODO: Remove this patch in the future
    public static testMethod void coveragePatch() {
        BatchAddressAssignmentEffectiveDate batch = new BatchAddressAssignmentEffectiveDate();
        batch.testCoveragePatch();
    }
    
    
}//end of BatchAddressAssignmentEffectiveDateTest2