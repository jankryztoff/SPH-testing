/**
@Author Christopher Manawatao
@name NewSubscriptionService_Test
@CreateDate 2/10/2015
@Description Test Class For NewSubscriptionService
@Version 1.0
@reference TestDataFactory
**/
@isTest(SeeAllData = true)
private class StartSubscriptionService_Test {
    
    /**
@Author <Rom Edison Reyes>
@name <StartSubscriptionServiceRequest>
@CreateDate <02/11/2015>
@Description <recreates StartSusbcriptionServiceRequest of base class>
@Version <1.0>
@reference <none>
*/
    public class StartSubscriptionServiceRequest {
        AccountWrapper subscriberAccount; 
        List<ContactWrapper> contacts;
        OrderWrapper order;       
    }
    
    /**
@Author <Rom Edison Reyes>
@name <AccountWrapper>
@CreateDate <02/11/2015>
@Description <recreates AccountWrapper of base class>
@Version <1.0>
@reference <none>
*/
    public class AccountWrapper {
        String accountName;
        String accountNumber; 
        String recordType;
        String phone;
        String email;
        String dateBirth;
        String gender;
        String race;
        String language;
        String contactPerson;
        String uniqueEntityNumber;
        String businessNature;
        String staffId;
        String subGroup;
    }
    
    /**
@Author <Rom Edison Reyes>
@name <ContactWrapper>
@CreateDate <02/11/2015>
@Description <recreates ContactWrapper of base class>
@Version <1.0>
@reference <none>
*/    
    public class ContactWrapper {
        String salutation;
        String firstName;
        String lastName;
        String nric;
        String passport;
        String billingIndicator;
        String recipientIndicator;
        String homeNumber;
        String mobileNumber1;
        String emailAddress1;
        AddressWrapper address;
    }
    
    /**
@Author <Rom Edison Reyes>
@name <OrderWrapper>
@CreateDate <02/11/2015>
@Description <recreates OrderWrapper of base class>
@Version <1.0>
@reference <none>
*/
    public class OrderWrapper {
        String billingAccountNumber;
        String paymentMode;
        String paymentMethodId;
        String deliveryChargeType;
        String ReferenceId;
        List<OrderLineItemWrapper> orderLineItems;
    }
    
    /**
@Author <Rom Edison Reyes>
@name <OrderLineItemWrapper>
@CreateDate <02/11/2015>
@Description <recreates OrderLineItemWrapper of base class>
@Version <1.0>
@reference <none>
*/
    public class OrderLineItemWrapper {
        public String Id;        
        public String promotioncode;
        public String packagecode;
        public String addonpackagecode;
        public String ldapId;
        public Integer quantity;
        public String startDate;
        public List<String> giftCode;
        public String contractenddate;
        public List<Asia1__c> asia1Items;             
    }
    
    /**
@Author <Rom Edison Reyes>
@name <AddressWrapper>
@CreateDate <02/11/2015>
@Description <recreates AddressWrapper of base class>
@Version <1.0>
@reference <none>
*/
    public class AddressWrapper {
        String houseBlockNumber;
        String levelNumber;
        String unitNumber;
        String postalCode;
        String streetName;
        String buildingName;
        String country;
        String singpostAddressType;   
        String Address1;
        String Address2;
        String Address3;
        String Address4;
    }
    
    /**
*  Initial testmethod
* @name <testInitial>
* @param <none>
* @return <none>
* @throws exception-<none>
* @see 
*/
    static testMethod void testInitial(){
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        insert postal;
        
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Name = 'Test Account';
        acc.Phone = '123-456';
        acc.Email__c = 'test@test.com';
        acc.Date_of_Birth__c = date.today();
        acc.Gender__c = 'Male';
        acc.Race__c = 'Chinese';
        acc.Language__c = 'Others';
        acc.Contact_Person__c = 'Contact Person';
        acc.Sub_Group__c = 'Freelist(MY)';
        insert acc;
        
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
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
        insert billAcc;
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        insert addressRec; 
        
        //Contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        //con.NRIC__c = '123456';
        con.Passport__c = 'PassTest';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        //order.Billing_Account__c = billAcc.id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        order.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
        order.Delivery_Charge_Type__c = 'C';
        //order.Postage_Charge__c = 200.00;
        insert order;
        
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        //Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(2);
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
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        Test.startTest();
        //AddressWrapper
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = addressRec.Postal_Code__c;
        addWrap.streetName = addressRec.Street_Name__c;
        addWrap.buildingName = addressRec.Building_Name__c;
        addWrap.country = addressRec.Country_Name__c;
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = addressRec.Address_1__c;
        addWrap.Address2 = addressRec.Address_2__c;
        addWrap.Address3 = addressRec.Address_3__c;
        addWrap.Address4 = addressRec.Address_4__c;
        
        //List<ContactWrapper>
        ContactWrapper conWrap = new ContactWrapper();
        conWrap.billingIndicator = 'Y'; 
        conWrap.recipientIndicator = 'N';
        conWrap.salutation = '';
        conWrap.firstName = con.FirstName;
        conWrap.lastName = con.LastName;
        conWrap.nric = con.NRIC__c;
        conWrap.passport = con.Passport__c;
        conWrap.homeNumber = con.Home_Phone_display__c;
        conWrap.mobileNumber1 = con.Mobile_Number__c;
        conWrap.emailAddress1 = con.Email;
        conWrap.address = addWrap; //AddressWrapper address;
        
        List<ContactWrapper> conWrap2 = new List<ContactWrapper>();
        conWrap2.add(conWrap);
        
        //OrderLineItemWrapper
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
        oliWrap.Id = orderline.Id;   
        List<OrderLineItemWrapper> oliWraps = new List<OrderLineItemWrapper>();
        oliWraps.add(oliWrap);
        //OrderWrapper
        OrderWrapper ordWrap = new OrderWrapper();//ordWrap.billingAccountNumber = order.bi;
        ordWrap.paymentMode = order.Payment_Mode__c;
        ordWrap.paymentMethodId = order.Payment_Method_ID__c;
        ordWrap.deliveryChargeType = order.Delivery_Charge_Type__c;//ordWrap.ReferenceId;
        ordWrap.orderLineItems = oliWraps;//List<OrderLineItemWrapper> orderLineItems;
        
        //AccountWrapper
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = acc.Account_Auto_Number__c; 
        accWrap.recordType = acc.RecordTypeId;
        accWrap.phone = acc.Phone;
        accWrap.email = acc.Email__c;
        //accWrap.dateBirth = acc.Date_of_Birth__c.format();
        accWrap.gender = acc.Gender__c;
        accWrap.race = acc.Race__c;
        accWrap.language = acc.Language__c;
        accWrap.contactPerson = acc.Contact_Person__c;
        accWrap.subGroup = acc.Sub_Group__c;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/StartSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        StartSubscriptionServiceRequest startReq = new  StartSubscriptionServiceRequest();
        startReq.contacts = conWrap2;
        startReq.subscriberAccount = accWrap;
        startReq.order = ordWrap;
        StartSubscriptionService.StartSubscriptionServiceRequest start = new StartSubscriptionService.StartSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(startReq);
        start = (StartSubscriptionService.StartSubscriptionServiceRequest)JSON.deserialize(jsonStr, StartSubscriptionService.StartSubscriptionServiceRequest.class);
        StartSubscriptionService.StartSubscriptionServiceResponse startRes = StartSubscriptionService.processRequest(start);      
        Test.stopTest();    
        System.assert(startRes != null);
    }
    
    /**
*  Testmethod for catch statement
* @name <testCatch>
* @param <none>
* @return <none>
* @throws exception-<none>
* @see 
*/
    static testMethod void testCatch()
    {     
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/StartSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        StartSubscriptionServiceRequest startReq = new  StartSubscriptionServiceRequest();
        StartSubscriptionService.StartSubscriptionServiceRequest start = new StartSubscriptionService.StartSubscriptionServiceRequest();
        
        String jsonStr = JSON.serialize(startReq);
        start = (StartSubscriptionService.StartSubscriptionServiceRequest)JSON.deserialize(jsonStr, StartSubscriptionService.StartSubscriptionServiceRequest.class);
        StartSubscriptionService.StartSubscriptionServiceResponse startRes = StartSubscriptionService.processRequest(start);
        Test.stopTest(); 
        System.assert(startRes != null);
    }
    
    /**
*  Testmethod wherein there is no address
* @name <noAddress>
* @param <none>
* @return <none>
* @throws exception-<none>
* @see 
*/
    static testMethod void noAddress(){
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'SIN';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        
        insert postal;
        
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Name = 'Test Account';
        acc.Phone = '123-456';
        acc.Email__c = 'test@test.com';
        acc.Date_of_Birth__c = date.today();
        acc.Gender__c = 'Male';
        acc.Race__c = 'Chinese';
        acc.Language__c = 'Others';
        acc.Contact_Person__c = 'Contact Person';
        acc.Sub_Group__c = 'Freelist(MY)';
        insert acc;
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
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
        insert billAcc;
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        insert addressRec; 
        
        //Contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Passport__c = 'PassTest';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        //con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        //order.Billing_Account__c = billAcc.Id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        order.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
        order.Delivery_Charge_Type__c = 'C';
        insert order;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        //Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(2);
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
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        Test.startTest();
        //AddressWrapper
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = addressRec.Postal_Code__c;
        addWrap.streetName = addressRec.Street_Name__c;
        addWrap.buildingName = addressRec.Building_Name__c;
        //addWrap.country = addressRec.Country_Name__c;
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = addressRec.Address_1__c;
        addWrap.Address2 = addressRec.Address_2__c;
        addWrap.Address3 = addressRec.Address_3__c;
        addWrap.Address4 = addressRec.Address_4__c;
        
        List<ContactWrapper> conWraps = new List<ContactWrapper>();
        conWraps.add(new ContactWrapper());
        conWraps.add(new ContactWrapper());
        
        for(ContactWrapper conWrap: conWraps)
        {
            conWrap.billingIndicator = 'Y'; 
            conWrap.recipientIndicator = 'Y';
            conWrap.salutation = '';
            conWrap.firstName = con.FirstName;
            conWrap.lastName = con.LastName;
            conWrap.nric = con.NRIC__c;
            conWrap.passport = con.Passport__c;
            conWrap.homeNumber = con.Home_Phone_display__c;
            conWrap.mobileNumber1 = con.Mobile_Number__c;
            conWrap.emailAddress1 = con.Email; 
            conWrap.address = addWrap;
        }
        
        //OrderLineItemWrapper
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
        oliWrap.Id = orderline.Id;   
        List<OrderLineItemWrapper> oliWraps = new List<OrderLineItemWrapper>();
        oliWraps.add(oliWrap);
        
        //OrderWrapper
        OrderWrapper ordWrap = new OrderWrapper();//ordWrap.billingAccountNumber = order.bi;
        ordWrap.paymentMode = order.Payment_Mode__c;
        ordWrap.paymentMethodId = order.Payment_Method_ID__c;
        ordWrap.deliveryChargeType = order.Delivery_Charge_Type__c;//ordWrap.ReferenceId;
        ordWrap.orderLineItems = oliWraps;//List<OrderLineItemWrapper> orderLineItems;
        
        //AccountWrapper
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = acc.Account_Auto_Number__c; 
        accWrap.recordType = acc.RecordTypeId;
        accWrap.phone = acc.Phone;
        accWrap.email = acc.Email__c;
        accWrap.gender = acc.Gender__c;
        accWrap.race = acc.Race__c;
        accWrap.language = acc.Language__c;
        accWrap.contactPerson = acc.Contact_Person__c;
        accWrap.subGroup = acc.Sub_Group__c;
        
        List<Address__c> address = [SELECT Id, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Code__c = :addWrap.country AND Address_1__c = :addWrap.Address1 AND Address_2__c = :addWrap.Address2 AND Address_3__c = :addWrap.Address3 AND Address_4__c = :addWrap.Address4];
        System.debug('>>>Address List'+ address);  
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/StartSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        StartSubscriptionServiceRequest startReq = new  StartSubscriptionServiceRequest();
        startReq.contacts = conWraps;
        startReq.subscriberAccount = accWrap;
        startReq.order = ordWrap;
        StartSubscriptionService.StartSubscriptionServiceRequest start = new StartSubscriptionService.StartSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(startReq);
        start = (StartSubscriptionService.StartSubscriptionServiceRequest)JSON.deserialize(jsonStr, StartSubscriptionService.StartSubscriptionServiceRequest.class);
        StartSubscriptionService.StartSubscriptionServiceResponse startRes = StartSubscriptionService.processRequest(start);
        system.debug('RESPONSE:' + startRes );
        
        StartSubscriptionService.getSingpostAddress('SPosta');
        StartSubscriptionService.getCountry('SPosta');
        Test.stopTest();
        System.assert(startRes != null);
    }
    
     /**
*  My test method
* @name <noAddress>
* @param <none>
* @return <none>
* @throws exception-<none>
* @see 
*/
    static testMethod void myTestMethod(){
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'SIN';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        
        insert postal;
        
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Name = 'Test Account';
        acc.Phone = '123-456';
        acc.Email__c = 'test@test.com';
        acc.Date_of_Birth__c = date.today();
        acc.Gender__c = 'Male';
        acc.Race__c = 'Chinese';
        acc.Language__c = 'Others';
        acc.Contact_Person__c = 'Contact Person';
        acc.Sub_Group__c = 'Freelist(MY)';
        insert acc;
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
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
        prdRatePlan.BillingType__c = 'Full Prepaid';
        prdRatePlan.BillingPeriod__c = '18';
        prdRatePlan.SubscriptionFrequency__c = '1';
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
        
        Publication__c publ = TestDataFactory.createPublication(1)[0];
        publ.Direct_Sub_Delivery_Method__c = 'Vendor';
        insert publ;  
        
        Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
        prodPub.Publication_Code__c = publ.id;
        prodPub.ZProduct__c = zProduct.Id;
        insert prodPub;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Set<Id> billAccIdSet = new Set<Id>();
        billAccIdSet.add(billAcc.id);
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        insert addressRec; 
        
        //Contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Passport__c = 'PassTest';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        //con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        //order.Billing_Account__c = billAcc.Id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        order.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
        order.Delivery_Charge_Type__c = 'C';
        insert order;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        //Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(2);
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
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        Test.startTest();
        //AddressWrapper
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = addressRec.Postal_Code__c;
        addWrap.streetName = addressRec.Street_Name__c;
        addWrap.buildingName = addressRec.Building_Name__c;
        //addWrap.country = 'SIN';
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = addressRec.Address_1__c;
        addWrap.Address2 = addressRec.Address_2__c;
        addWrap.Address3 = addressRec.Address_3__c;
        addWrap.Address4 = addressRec.Address_4__c;
        
        List<ContactWrapper> conWraps = new List<ContactWrapper>();
        conWraps.add(new ContactWrapper());
        conWraps.add(new ContactWrapper());
        
        for(ContactWrapper conWrap: conWraps)
        {
            conWrap.billingIndicator = 'Y'; 
            conWrap.recipientIndicator = 'Y';
            conWrap.salutation = '';
            conWrap.firstName = con.FirstName;
            conWrap.lastName = con.LastName;
            conWrap.nric = con.NRIC__c;
            conWrap.passport = con.Passport__c;
            conWrap.homeNumber = con.Home_Phone_display__c;
            conWrap.mobileNumber1 = con.Mobile_Number__c;
            conWrap.emailAddress1 = con.Email; 
            conWrap.address = addWrap;
        }
        
        //OrderLineItemWrapper
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
        oliWrap.Id = orderline.Id;  
        List<OrderLineItemWrapper> oliWraps = new List<OrderLineItemWrapper>();
        oliWraps.add(oliWrap);
        
        //OrderWrapper
        OrderWrapper ordWrap = new OrderWrapper();//ordWrap.billingAccountNumber = order.bi;
        ordWrap.paymentMode = order.Payment_Mode__c;
        ordWrap.paymentMethodId = order.Payment_Method_ID__c;
        ordWrap.deliveryChargeType = order.Delivery_Charge_Type__c;//ordWrap.ReferenceId;
        ordWrap.orderLineItems = oliWraps;//List<OrderLineItemWrapper> orderLineItems;
        
        //AccountWrapper
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = acc.Account_Auto_Number__c; 
        accWrap.recordType = 'Direct Corporate';
        accWrap.phone = acc.Phone;
        accWrap.email = acc.Email__c;
        accWrap.gender = acc.Gender__c;
        accWrap.race = acc.Race__c;
        accWrap.language = acc.Language__c;
        accWrap.contactPerson = acc.Contact_Person__c;
        accWrap.subGroup = acc.Sub_Group__c;
        accWrap.staffId = 'SampleID';
        
        List<Address__c> address = [SELECT Id, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Code__c = :addWrap.country AND Address_1__c = :addWrap.Address1 AND Address_2__c = :addWrap.Address2 AND Address_3__c = :addWrap.Address3 AND Address_4__c = :addWrap.Address4];
        System.debug('>>>Address List'+ address);  
        
        List<Asia1__c> asia1List = TestDataFactory.createAsiaOne(1);
        asia1List[0].Display_Name__c = '003yngwie@test';
        asia1List[0].User_ID_LDAP_ID__c = '003yngwie@test';
        asia1List[0].Password__c = 'samplepass';
        asia1List[0].Status__c = 'Pending Creation';
        insert asia1List;
        
        Gift__c gft = TestDataFactory.createGift(1)[0];
        gft.Gift_Code__c = 'gftCode';
        insert gft;
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Promotion_Code__c = 'promoCode';
        prom.Contract_Period__c = '1';
        insert prom;
        
        Promotion_Gift__c promGft = TestDataFactory.createPromotionGift(1)[0];
        promGft.Promotion__c = prom.id;
        promGft.Gift__c = gft.id;
        insert promGft;
        
        List<String> gftCodes = new List<String>();
        gftCodes.add('gftCode');
        
        Package_Access_Flag__c paf = TestDataFactory.createPackageAccessFlag(1)[0];
        paf.Package__c = pack.id;
        insert paf;
        
        Asia1_Subscription__c asiaSub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asiaSub.Order_Line_Item__c = orderline.id;
        asiaSub.Asia1__c = asia1List[0].id;
        insert asiaSub;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/StartSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        StartSubscriptionServiceRequest startReq = new  StartSubscriptionServiceRequest();
        startReq.contacts = conWraps;
        startReq.subscriberAccount = accWrap;
        startReq.order = ordWrap;
        StartSubscriptionService.StartSubscriptionServiceRequest start = new StartSubscriptionService.StartSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(startReq);
        start = (StartSubscriptionService.StartSubscriptionServiceRequest)JSON.deserialize(jsonStr, StartSubscriptionService.StartSubscriptionServiceRequest.class);
        StartSubscriptionService.StartSubscriptionServiceResponse startRes = StartSubscriptionService.processRequest(start);
        system.debug('RESPONSE:' + startRes );
        
        StartSubscriptionService.AddressWrapper adWrap = new StartSubscriptionService.AddressWrapper();
        StartSubscriptionService.createAddress(adWrap);
        StartSubscriptionService.getSingpostAddress('SPostal');
        
        Date tod = Date.today().addDays(1);
        
        List<StartSubscriptionService.OrderLineItemWrapper> ordWrpList = new List<StartSubscriptionService.OrderLineItemWrapper>();
        StartSubscriptionService.OrderLineItemWrapper ordWrp = new StartSubscriptionService.OrderLineItemWrapper();
        //WAK
        //ordWrp.startDate = '12/21/2015';
        ordWrp.startDate = Date.today().addDays(1).format();
        ordWrp.contractenddate = '12/22/2015';
        ordWrp.packagecode = 'afds132';
        ordWrp.quantity = 5;
        ordWrp.asia1Items = asia1List;
        ordWrp.giftCode = gftCodes;
        ordWrp.promotioncode = 'promoCode';
        ordWrpList.add(ordWrp);
        StartSubscriptionService.createOrderLineItems(ordWrpList, order);
        
        StartSubscriptionService.registerAsia1Accounts(order.id);
        StartSubscriptionService.onDemandSyncFromZoura(billAccIdSet);
        StartSubscriptionService.Billing_Contact = con;
        StartSubscriptionService.Recipient_Contact = con;
        StartSubscriptionService.BilConId = con.id;
        StartSubscriptionService.RecConId = con.id;
        Test.stopTest();
        System.assert(startRes != null);
    }
    static testMethod void newTEST(){
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'SIN';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        
        insert postal;
        
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Name = 'Test Account';
        acc.Phone = '123-456';
        acc.Email__c = 'test@test.com';
        acc.Date_of_Birth__c = date.today();
        acc.Gender__c = 'Male';
        acc.Race__c = 'Chinese';
        acc.Language__c = 'Others';
        acc.Contact_Person__c = 'Contact Person';
        acc.Sub_Group__c = 'Freelist(MY)';
        insert acc;
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
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
        prdRatePlan.BillingType__c = 'Full Prepaid';
        prdRatePlan.BillingPeriod__c = '18';
        prdRatePlan.SubscriptionFrequency__c = '1';
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
        
        Publication__c publ = TestDataFactory.createPublication(1)[0];
        publ.Direct_Sub_Delivery_Method__c = 'Vendor';
        insert publ;  
        
        Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
        prodPub.Publication_Code__c = publ.id;
        prodPub.ZProduct__c = zProduct.Id;
        insert prodPub;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Set<Id> billAccIdSet = new Set<Id>();
        billAccIdSet.add(billAcc.id);
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        insert addressRec; 
        
        //Contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Passport__c = 'PassTest';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        //con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        //order.Billing_Account__c = billAcc.Id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        order.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
        order.Delivery_Charge_Type__c = 'C';
        insert order;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        //Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = date.today().addDays(1);
        orderline.End_Date__c = date.today().addDays(2);
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
        //orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        Test.startTest();
        //AddressWrapper
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = addressRec.Postal_Code__c;
        addWrap.streetName = addressRec.Street_Name__c;
        addWrap.buildingName = addressRec.Building_Name__c;
        addWrap.country = 'SIN';
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = addressRec.Address_1__c;
        addWrap.Address2 = addressRec.Address_2__c;
        addWrap.Address3 = addressRec.Address_3__c;
        addWrap.Address4 = addressRec.Address_4__c;
        
        List<ContactWrapper> conWraps = new List<ContactWrapper>();
        conWraps.add(new ContactWrapper());
        conWraps.add(new ContactWrapper());
        
        for(ContactWrapper conWrap: conWraps)
        {
            conWrap.billingIndicator = 'Y'; 
            conWrap.recipientIndicator = 'Y';
            conWrap.salutation = '';
            conWrap.firstName = con.FirstName;
            conWrap.lastName = con.LastName;
            conWrap.nric = con.NRIC__c;
            conWrap.passport = con.Passport__c;
            conWrap.homeNumber = con.Home_Phone_display__c;
            conWrap.mobileNumber1 = con.Mobile_Number__c;
            conWrap.emailAddress1 = con.Email; 
            conWrap.address = addWrap;
        }
        
        //OrderLineItemWrapper
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
        oliWrap.Id = orderline.Id;  
        List<OrderLineItemWrapper> oliWraps = new List<OrderLineItemWrapper>();
        oliWraps.add(oliWrap);
        
        //OrderWrapper
        OrderWrapper ordWrap = new OrderWrapper();//ordWrap.billingAccountNumber = order.bi;
        ordWrap.paymentMode = order.Payment_Mode__c;
        ordWrap.paymentMethodId = order.Payment_Method_ID__c;
        ordWrap.deliveryChargeType = order.Delivery_Charge_Type__c;//ordWrap.ReferenceId;
        ordWrap.orderLineItems = oliWraps;//List<OrderLineItemWrapper> orderLineItems;
        
        //AccountWrapper
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = acc.Account_Auto_Number__c; 
        accWrap.recordType = 'Direct Corporate';
        accWrap.phone = acc.Phone;
        accWrap.email = acc.Email__c;
        accWrap.gender = acc.Gender__c;
        accWrap.race = acc.Race__c;
        accWrap.language = acc.Language__c;
        accWrap.contactPerson = acc.Contact_Person__c;
        accWrap.subGroup = acc.Sub_Group__c;
        accWrap.staffId = 'SampleID';
        
        List<Address__c> address = [SELECT Id, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Code__c = :addWrap.country AND Address_1__c = :addWrap.Address1 AND Address_2__c = :addWrap.Address2 AND Address_3__c = :addWrap.Address3 AND Address_4__c = :addWrap.Address4];
        System.debug('>>>Address List'+ address);  
        
        List<Asia1__c> asia1List = TestDataFactory.createAsiaOne(1);
        asia1List[0].Display_Name__c = '003yngwie@test';
        asia1List[0].User_ID_LDAP_ID__c = '003yngwie@test';
        asia1List[0].Password__c = 'samplepass';
        asia1List[0].Status__c = 'Pending Creation';
        insert asia1List;
        
        Gift__c gft = TestDataFactory.createGift(1)[0];
        gft.Gift_Code__c = 'gftCode';
        insert gft;
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Promotion_Code__c = 'promoCode';
        prom.Contract_Period__c = '1';
        insert prom;
        
        Promotion_Gift__c promGft = TestDataFactory.createPromotionGift(1)[0];
        promGft.Promotion__c = prom.id;
        promGft.Gift__c = gft.id;
        insert promGft;
        
        List<String> gftCodes = new List<String>();
        gftCodes.add('gftCode');
        
        Package_Access_Flag__c paf = TestDataFactory.createPackageAccessFlag(1)[0];
        paf.Package__c = pack.id;
        insert paf;
        
        Asia1_Subscription__c asiaSub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asiaSub.Order_Line_Item__c = orderline.id;
        asiaSub.Asia1__c = asia1List[0].id;
        insert asiaSub;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/StartSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        StartSubscriptionServiceRequest startReq = new  StartSubscriptionServiceRequest();
        startReq.contacts = conWraps;
        startReq.subscriberAccount = accWrap;
        startReq.order = ordWrap;
        StartSubscriptionService.StartSubscriptionServiceRequest start = new StartSubscriptionService.StartSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(startReq);
        start = (StartSubscriptionService.StartSubscriptionServiceRequest)JSON.deserialize(jsonStr, StartSubscriptionService.StartSubscriptionServiceRequest.class);
        StartSubscriptionService.StartSubscriptionServiceResponse startRes = StartSubscriptionService.processRequest(start);
        system.debug('RESPONSE:' + startRes );
        
        StartSubscriptionService.AddressWrapper adWrap = new StartSubscriptionService.AddressWrapper();
        StartSubscriptionService.createAddress(adWrap);
        StartSubscriptionService.getSingpostAddress('SPostal');
        
        Date tod = Date.today().addDays(1);
        
        List<StartSubscriptionService.OrderLineItemWrapper> ordWrpList = new List<StartSubscriptionService.OrderLineItemWrapper>();
        StartSubscriptionService.OrderLineItemWrapper ordWrp = new StartSubscriptionService.OrderLineItemWrapper();
        //WAK
        //ordWrp.startDate = '12/21/2015';
        ordWrp.startDate = Date.today().addDays(1).format();
        ordWrp.contractenddate = '12/22/2015';
        ordWrp.packagecode = 'afds132';
        ordWrp.quantity = 5;
        ordWrp.asia1Items = asia1List;
        ordWrp.giftCode = gftCodes;
        ordWrp.promotioncode = 'promoCode';
        ordWrpList.add(ordWrp);
        StartSubscriptionService.createOrderLineItems(ordWrpList, order);
        
        StartSubscriptionService.registerAsia1Accounts(order.id);
        StartSubscriptionService.onDemandSyncFromZoura(billAccIdSet);
        StartSubscriptionService.Billing_Contact = con;
        StartSubscriptionService.Recipient_Contact = con;
        StartSubscriptionService.BilConId = con.id;
        StartSubscriptionService.RecConId = con.id;
        Test.stopTest();
        System.assert(startRes != null);
    }
}