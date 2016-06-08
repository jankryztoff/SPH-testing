/*
* Class Name: <NewSubscriptionServiceTest>
* @author: Flores, Emmanuel
* Requirement/Project Name: <SPH>
* @description: Test class for NewSubscriptionService
*/
@isTest (seeAllData= True)

private class NewSubscriptionService_Test{

    public class NewSubscriptionServiceResponse{
        String svc_status;
        String error_code;
        String error_message = '';
        String subscriberId;
        String subscriptionId;
        String orderid;
    }
    
    public class NewSubscriptionServiceRequest{
        AccountWrapper subscriberAccount; 
        List<ContactWrapper> contacts;
        OrderWrapper order; 
    }
    
    
    public class AccountWrapper{
        String accountName;
        String accountNumber; 
        String recordType;
        String billingType;
    }
    
    
    public class ContactWrapper{
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
    
    public class OrderWrapper{
        String billingAccountNumber;
        String billingType2;
        String paymentMode;
        String paymentMethodId;
        String deliveryChargeType;
        String ReferenceId;
        String ldapId;
        List<OrderLineItemWrapper> orderLineItems;
        // START : D-2093 2/4/2015 Alyana Navarro
        String vendorConversion = 'N';
    }    
    
    public class OrderLineItemWrapper{
        public String promotioncode;
        public String packagecode;
        public String addonpackagecode; 
        public Integer quantity;
        public String startDate;
        public List<String> giftCode;
        public String contractenddate;
    }
    
    public class AddressWrapper{
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
    
    static testMethod void tesNewSubSvcMethod1(){
    
        try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        //ctry.Code__c = 'SG';
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
        
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        //addressRec.Street_Name__c = 'Street';
        //addressRec.Building_Name__c = 'SG Building';
        //address.Address_1__c = 'Address 1';
        //addressRec.Address_2__c = 'Address 2';
        //addressRec.Address_3__c = 'Address 3';
        //addressRec.Address_4__c = 'Address 4';
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
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Paypal';
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
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
     
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
        
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
        ContactWrapper conWrap = new ContactWrapper();
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
        conWrap.address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap);
        
        String accNumber = [Select Account_Auto_Number__c from Account Where Id =: acc.Id].Account_Auto_Number__c;
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = accNumber;
        accWrap.recordType = 'Direct Corporate';
        
        NewSubscriptionService.vendorConversionFlag = TRUE;
        
        Test.startTest();
        NewSubscriptionService.AccountWrapper aWrap = new NewSubscriptionService.AccountWrapper();
        NewSubscriptionService.ContactWrapper cWrap = new NewSubscriptionService.ContactWrapper();
        NewSubscriptionService.OrderWrapper oWrap = new NewSubscriptionService.OrderWrapper();
        NewSubscriptionService.OrderLineItemWrapper olWrap = new NewSubscriptionService.OrderLineItemWrapper();
        NewSubscriptionService.AddressWrapper adWrap = new NewSubscriptionService.AddressWrapper();
        
       
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/NewSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
         
        NewSubscriptionServiceRequest nwSubServ = new NewSubscriptionServiceRequest();
        nwSubServ.subscriberAccount = accWrap;
        nwSubServ.contacts = conWrapList;
        nwSubserv.order = new OrderWrapper();
        nwSubserv.order.paymentMode = 'Credit Card';
        nwSubserv.order.orderLineItems = new List<OrderLineItemWrapper>();
                         
        String jsonStr = JSON.serialize(nwSubServ);
        NewSubscriptionService.NewSubscriptionServiceRequest esh = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        NewSubscriptionService.processRequest(esh);         
        Test.stopTest();
          }catch(Exception e) {
          }  
                  
    
  }
    static testMethod void tesNewSubSvcMethod1B(){
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
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
        //billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        //addressRec.Street_Name__c = 'Street';
        //addressRec.Building_Name__c = 'SG Building';
        //address.Address_1__c = 'Address 1';
        //addressRec.Address_2__c = 'Address 2';
        //addressRec.Address_3__c = 'Address 3';
        //addressRec.Address_4__c = 'Address 4';
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
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
    
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = addressRec.Postal_Code__c;
        addWrap.streetName = 'Strawberry St';
        addWrap.buildingName = addressRec.Building_Name__c;
        addWrap.country = 'SG';
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = 'BLK6 LOT5 Paz Village <>';
        addWrap.Address2 = addressRec.Address_2__c;
        addWrap.Address3 = addressRec.Address_3__c;
        addWrap.Address4 = addressRec.Address_4__c;
        
        system.debug('addWrap: '+ addWrap );
        
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
        ContactWrapper conWrap = new ContactWrapper();
        conWrap.billingIndicator = 'Y'; 
        conWrap.recipientIndicator = 'Y';
        conWrap.salutation = '';
        conWrap.firstName = con.FirstName;
        conWrap.lastName = con.LastName;
        conWrap.nric = con.NRIC__c;
        conWrap.passport = con.Passport__c;
        conWrap.homeNumber = '09107620428';
        conWrap.mobileNumber1 = con.Mobile_Number__c;
        conWrap.emailAddress1 = con.Email;
        conWrap.address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap);
        
        ContactWrapper conWrap2 = new ContactWrapper();
        conWrap2 .billingIndicator = 'Y'; 
        conWrap2 .recipientIndicator = 'Y';
        conWrap2 .salutation = '';
        conWrap2 .firstName = con1.FirstName;
        conWrap2 .lastName = con1.LastName;
        conWrap2 .nric = con1.NRIC__c;
        conWrap2 .passport = con1.Passport__c;
        conWrap2 .homeNumber = '09107620428';
        conWrap2 .mobileNumber1 = con1.Mobile_Number__c;
        conWrap2 .emailAddress1 = con1.Email;
        conWrap2 .address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap2 );        
        
        String accNumber = [Select Account_Auto_Number__c from Account Where Id =: acc.Id].Account_Auto_Number__c;
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = accNumber;
        accWrap.recordType = 'Direct Corporate';            
        accWrap.billingType = billAcc.Billing_Type__c;
        
        Test.startTest();        
        
        NewSubscriptionService.AccountWrapper aWrap = new NewSubscriptionService.AccountWrapper();
        NewSubscriptionService.ContactWrapper cWrap = new NewSubscriptionService.ContactWrapper();
        NewSubscriptionService.OrderWrapper oWrap = new NewSubscriptionService.OrderWrapper();
        NewSubscriptionService.OrderLineItemWrapper olWrap = new NewSubscriptionService.OrderLineItemWrapper();
        NewSubscriptionService.AddressWrapper adWrap = new NewSubscriptionService.AddressWrapper();
        
        olWrap.promotioncode='Test';
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/NewSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        NewSubscriptionServiceRequest nwSubServ = new NewSubscriptionServiceRequest();
        nwSubServ.subscriberAccount = accWrap;
        nwSubServ.contacts = conWrapList;
        nwSubserv.order = new OrderWrapper();
        nwSubserv.order.paymentMode = 'Check';
        nwSubserv.order.paymentMethodId = '';
        nwSubserv.order.billingType2 = order.Billing_Type__c;
        nwSubserv.order.orderLineItems = new List<OrderLineItemWrapper>();    
        
        system.debug('TEST Orderline Items' + nwSubserv.order.orderLineItems);
        //system.assert(NewSubscriptionService.validateMandatoryFields(nwSubserv));
        
        String jsonStr = JSON.serialize(nwSubServ);
        NewSubscriptionService.NewSubscriptionServiceRequest esh = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        NewSubscriptionService.processRequest(esh);         
        Test.stopTest();
        }catch(Exception e) {
          }  
                  
    
  }
    static testMethod void tesNewSubSvcMethod1C(){
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        //ctry.Code__c = 'SG';
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
        //billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        //addressRec.Street_Name__c = 'Street';
        //addressRec.Building_Name__c = 'SG Building';
        //address.Address_1__c = 'Address 1';
        //addressRec.Address_2__c = 'Address 2';
        //addressRec.Address_3__c = 'Address 3';
        //addressRec.Address_4__c = 'Address 4';
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
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = addressRec.Postal_Code__c;
        addWrap.streetName = 'Strawberry St';
        addWrap.buildingName = addressRec.Building_Name__c;
        addWrap.country = 'SG';
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = 'BLK6 LOT5 Paz Village <>';
        addWrap.Address2 = addressRec.Address_2__c;
        addWrap.Address3 = addressRec.Address_3__c;
        addWrap.Address4 = addressRec.Address_4__c;
        
        system.debug('addWrap: '+ addWrap );
        
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
        ContactWrapper conWrap = new ContactWrapper();
        conWrap.billingIndicator = 'Y'; 
        conWrap.recipientIndicator = 'Y';
        conWrap.salutation = '';
        conWrap.firstName = con.FirstName;
        conWrap.lastName = con.LastName;
        conWrap.nric = con.NRIC__c;
        conWrap.passport = con.Passport__c;
        conWrap.homeNumber = '09107620428';
        conWrap.mobileNumber1 = con.Mobile_Number__c;
        conWrap.emailAddress1 = con.Email;
        conWrap.address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap);
        
        ContactWrapper conWrap2 = new ContactWrapper();
        conWrap2.billingIndicator = 'Y'; 
        conWrap2.recipientIndicator = 'Y';
        conWrap2.salutation = '';
        conWrap2.firstName = con1.FirstName;
        conWrap2.lastName = con1.LastName;
        conWrap2.nric = con1.NRIC__c;
        conWrap2.passport = con1.Passport__c;
        conWrap2.homeNumber = '09107620428';
        conWrap2.mobileNumber1 = con1.Mobile_Number__c;
        conWrap2.emailAddress1 = con1.Email;
        conWrap2.address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap2 );        
        
        String accNumber = [Select Account_Auto_Number__c from Account Where Id =: acc.Id].Account_Auto_Number__c;
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = accNumber;
        accWrap.recordType = 'Direct Corporate';
        accWrap.billingType = billAcc.Billing_Type__c;            
        
        Test.startTest();
                
        NewSubscriptionService.AccountWrapper aWrap = new NewSubscriptionService.AccountWrapper();
        NewSubscriptionService.ContactWrapper cWrap = new NewSubscriptionService.ContactWrapper();
        NewSubscriptionService.OrderWrapper oWrap = new NewSubscriptionService.OrderWrapper();
        NewSubscriptionService.OrderLineItemWrapper olWrap = new NewSubscriptionService.OrderLineItemWrapper();
        NewSubscriptionService.AddressWrapper adWrap = new NewSubscriptionService.AddressWrapper();
        
        olWrap.promotioncode='Test';
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/NewSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        NewSubscriptionServiceRequest nwSubServ = new NewSubscriptionServiceRequest();
        nwSubServ.subscriberAccount = accWrap;
        nwSubServ.contacts = conWrapList;
        nwSubserv.order = new OrderWrapper();
        nwSubserv.order.paymentMode = 'TestPaymentMode';
        nwSubserv.order.paymentMethodId = '';
        nwSubserv.order.billingType2 = order.Billing_Type__c;
        nwSubserv.order.orderLineItems = new List<OrderLineItemWrapper>();    
        
        system.debug('TEST Orderline Items' + nwSubserv.order.orderLineItems);
        //system.assert(NewSubscriptionService.validateMandatoryFields(nwSubserv));
        
        String jsonStr = JSON.serialize(nwSubServ);
        NewSubscriptionService.NewSubscriptionServiceRequest esh = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        NewSubscriptionService.processRequest(esh);         
        Test.stopTest();
        }catch(Exception e) {
          }  
                  
    
  }
    static testMethod void tesNewSubSvcMethod2(){
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        //ctry.Code__c = 'SG';
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
        //billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        //addressRec.Street_Name__c = 'Street';
        //addressRec.Building_Name__c = 'SG Building';
        //address.Address_1__c = 'Address 1';
        //addressRec.Address_2__c = 'Address 2';
        //addressRec.Address_3__c = 'Address 3';
        //addressRec.Address_4__c = 'Address 4';
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
        //order.Payment_Mode__c = 'Credit Card';
        order.Payment_Mode__c = 'Paypal';
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
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = addressRec.Postal_Code__c;
        addWrap.streetName = 'Strawberry St';
        addWrap.buildingName = addressRec.Building_Name__c;
        addWrap.country = 'Singapore';
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = 'BLK6 LOT5 Paz Village';
        addWrap.Address2 = '471 Lerma St.';
        addWrap.Address3 = '#9 Masikap';
        addWrap.Address4 = 'Banga Caves';
        
        
        //OrderLineItemWrapper
        OrderLineItemWrapper OrdrLnItemWrap = new OrderLineItemWrapper();
        OrdrLnItemWrap.promotioncode = 'TESTCODE';
        OrdrLnItemWrap.packagecode = 'TEST PACKAGE CODE';
        OrdrLnItemWrap.addonpackagecode = 'ADD ON Package code';
        OrdrLnItemWrap.quantity = 1;
        OrdrLnItemWrap.startDate = '02/19/2015';
        //public List<String> giftCode;
        OrdrLnItemWrap.contractenddate = '02/21/2015';
        
        
        system.debug('addWrap: '+ addWrap );
        
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
        ContactWrapper conWrap = new ContactWrapper();
        conWrap.billingIndicator = 'Y'; 
        conWrap.recipientIndicator = 'Y';
        conWrap.salutation = '';
        conWrap.firstName = con.FirstName;
        conWrap.lastName = con.LastName;
        conWrap.nric = con.NRIC__c;
        conWrap.passport = con.Passport__c;
        conWrap.homeNumber = '09107620428';
        conWrap.mobileNumber1 = con.Mobile_Number__c;
        conWrap.emailAddress1 = con.Email;
        conWrap.address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap);
        
        ContactWrapper conWrap2 = new ContactWrapper();
        conWrap2 .billingIndicator = 'Y'; 
        conWrap2 .recipientIndicator = 'Y';
        conWrap2 .salutation = '';
        conWrap2 .firstName = con1.FirstName;
        conWrap2 .lastName = con1.LastName;
        conWrap2 .nric = con1.NRIC__c;
        conWrap2 .passport = con1.Passport__c;
        conWrap2 .homeNumber = '09107620428';
        conWrap2 .mobileNumber1 = con1.Mobile_Number__c;
        conWrap2 .emailAddress1 = con1.Email;
        conWrap2 .address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap2 );        
        
        String accNumber = [Select Account_Auto_Number__c from Account Where Id =: acc.Id].Account_Auto_Number__c;
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = accNumber;
        accWrap.recordType = 'Direct Corporate';
        accWrap.billingType = billAcc.Billing_Type__c;            
        
        Test.startTest();        
        
        NewSubscriptionService.AccountWrapper aWrap = new NewSubscriptionService.AccountWrapper();
        NewSubscriptionService.ContactWrapper cWrap = new NewSubscriptionService.ContactWrapper();
        NewSubscriptionService.OrderWrapper oWrap = new NewSubscriptionService.OrderWrapper();
        NewSubscriptionService.OrderLineItemWrapper olWrap = new NewSubscriptionService.OrderLineItemWrapper();
        NewSubscriptionService.AddressWrapper adWrap = new NewSubscriptionService.AddressWrapper();
        //NewSubscriptionService.Billing_Contact = con1;
        
        olWrap.promotioncode = 'TESTCODE';
        olWrap.packagecode = 'TEST PACKAGE CODE';
        olWrap.addonpackagecode = 'ADD ON Package code';
        olWrap.quantity = 1;
        olWrap.startDate = '02/19/2015';
        //public List<String> giftCode;
        olWrap.contractenddate = '02/21/2015';        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/NewSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        NewSubscriptionServiceRequest nwSubServ = new NewSubscriptionServiceRequest();
        nwSubServ.subscriberAccount = accWrap;
        nwSubServ.contacts = conWrapList;
        nwSubserv.order = new OrderWrapper();
        nwSubserv.order.paymentMode = 'Cash';
        nwSubserv.order.paymentMethodId = '';
        nwSubserv.order.billingAccountNumber = null;
        nwSubserv.order.billingType2 = order.Billing_Type__c;
        nwSubserv.order.orderLineItems = new List<OrderLineItemWrapper>();    
        
        system.debug('TEST Orderline Items' + nwSubserv.order.orderLineItems);
        //system.assert(NewSubscriptionService.validateMandatoryFields(nwSubserv));
        
        String jsonStr = JSON.serialize(nwSubServ);
        NewSubscriptionService.NewSubscriptionServiceRequest esh = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        NewSubscriptionService.processRequest(esh);         
        Test.stopTest();
        }catch(Exception e) {
          }  
                  
    
  }
    static testMethod void tesNewSubSvcMethod3(){
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        //ctry.Code__c = 'SG';
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
        //billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        //addressRec.Street_Name__c = 'Street';
        //addressRec.Building_Name__c = 'SG Building';
        //address.Address_1__c = 'Address 1';
        //addressRec.Address_2__c = 'Address 2';
        //addressRec.Address_3__c = 'Address 3';
        //addressRec.Address_4__c = 'Address 4';
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
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = addressRec.Postal_Code__c;
        addWrap.streetName = 'Strawberry St';
        addWrap.buildingName = addressRec.Building_Name__c;
        addWrap.country = 'Singapore';
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = 'BLK6 LOT5 Paz Village';
        addWrap.Address2 = addressRec.Address_2__c;
        addWrap.Address3 = addressRec.Address_3__c;
        addWrap.Address4 = addressRec.Address_4__c;
        
        system.debug('addWrap: '+ addWrap );
        
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
        ContactWrapper conWrap = new ContactWrapper();
        conWrap.billingIndicator = 'Y'; 
        conWrap.recipientIndicator = 'Y';
        conWrap.salutation = '';
        conWrap.firstName = con.FirstName;
        conWrap.lastName = con.LastName;
        conWrap.nric = con.NRIC__c;
        conWrap.passport = con.Passport__c;
        conWrap.homeNumber = '09107620428';
        conWrap.mobileNumber1 = con.Mobile_Number__c;
        conWrap.emailAddress1 = con.Email;
        conWrap.address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap);
        
        ContactWrapper conWrap2 = new ContactWrapper();
        conWrap2 .billingIndicator = 'Y'; 
        conWrap2 .recipientIndicator = 'Y';
        conWrap2 .salutation = '';
        conWrap2 .firstName = con1.FirstName;
        conWrap2 .lastName = con1.LastName;
        conWrap2 .nric = con1.NRIC__c;
        conWrap2 .passport = con1.Passport__c;
        conWrap2 .homeNumber = '09107620428';
        conWrap2 .mobileNumber1 = con1.Mobile_Number__c;
        conWrap2 .emailAddress1 = con1.Email;
        conWrap2 .address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap2 );        
        
        String accNumber = [Select Account_Auto_Number__c from Account Where Id =: acc.Id].Account_Auto_Number__c;
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = accNumber;
        accWrap.recordType = 'Direct Corporate';
        accWrap.billingType = billAcc.Billing_Type__c;            
        
        Test.startTest();        
        
        NewSubscriptionService.AccountWrapper aWrap = new NewSubscriptionService.AccountWrapper();
        NewSubscriptionService.ContactWrapper cWrap = new NewSubscriptionService.ContactWrapper();
        NewSubscriptionService.OrderWrapper oWrap = new NewSubscriptionService.OrderWrapper();
        NewSubscriptionService.OrderLineItemWrapper olWrap = new NewSubscriptionService.OrderLineItemWrapper();
        NewSubscriptionService.AddressWrapper adWrap = new NewSubscriptionService.AddressWrapper();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/NewSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        NewSubscriptionServiceRequest nwSubServ = new NewSubscriptionServiceRequest();
        nwSubServ.subscriberAccount = accWrap;
        nwSubServ.contacts = conWrapList;
        nwSubserv.order = new OrderWrapper();
        nwSubserv.order.paymentMode = 'Cash';
        nwSubserv.order.paymentMethodId = '';
        nwSubserv.order.billingType2 = order.Billing_Type__c;
        //nwSubserv.order.billingAccountNumber = '1345656';
        
        nwSubserv.order.orderLineItems = new List<OrderLineItemWrapper>();  
        OrderLineItemWrapper OrderLItems = new OrderLineItemWrapper();  
        OrderLItems.promotioncode = 'test';
        OrderLItems.packagecode = 'test';
        OrderLItems.addonpackagecode  = 'test';
        OrderLItems.quantity = 3;
        OrderLItems.startDate = '02/17/2015';
        //List<String> giftCode
        OrderLItems.contractenddate = '02/18/2015'; 
        nwSubserv.order.orderLineItems.add(OrderLItems);
        
        //system.assert(NewSubscriptionService.validateMandatoryFields(nwSubserv));
        
        String jsonStr = JSON.serialize(nwSubServ);
        NewSubscriptionService.NewSubscriptionServiceRequest esh = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        NewSubscriptionService.processRequest(esh);         
        Test.stopTest();
        }catch(Exception e) {
          }  
                  
    
  }
    static testMethod void tesNewSubSvcMethod4A(){
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        //ctry.Code__c = 'SG';
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
        //billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        //addressRec.Street_Name__c = 'Street';
        //addressRec.Building_Name__c = 'SG Building';
        //address.Address_1__c = 'Address 1';
        //addressRec.Address_2__c = 'Address 2';
        //addressRec.Address_3__c = 'Address 3';
        //addressRec.Address_4__c = 'Address 4';
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
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = addressRec.Postal_Code__c;
        addWrap.streetName = 'Strawberry St';
        addWrap.buildingName = addressRec.Building_Name__c;
        addWrap.country = 'Singapore';
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = 'BLK6 LOT5 Paz Village';
        addWrap.Address2 = addressRec.Address_2__c;
        addWrap.Address3 = addressRec.Address_3__c;
        addWrap.Address4 = addressRec.Address_4__c;
        
        system.debug('addWrap: '+ addWrap );
        
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
        /*ContactWrapper conWrap3 = new ContactWrapper();
        conWrap3.billingIndicator = 'Y'; 
        conWrap3.recipientIndicator = 'Y';
        conWrap3.salutation = '';
        conWrap3.firstName = con.FirstName;
        conWrap3.lastName = con.LastName;
        conWrap3.nric = con.NRIC__c;
        conWrap3.passport = con.Passport__c;
        conWrap3.homeNumber = '09107620428';
        conWrap3.mobileNumber1 = con.Mobile_Number__c;
        conWrap3.emailAddress1 = con.Email;
        conWrap3.address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap3);     */   
        
        ContactWrapper conWrap = new ContactWrapper();
        conWrap.billingIndicator = 'Y'; 
        conWrap.recipientIndicator = 'N';
        conWrap.salutation = '';
        conWrap.firstName = con.FirstName;
        conWrap.lastName = con.LastName;
        conWrap.nric = con.NRIC__c;
        conWrap.passport = con.Passport__c;
        conWrap.homeNumber = '09107620428';
        conWrap.mobileNumber1 = con.Mobile_Number__c;
        conWrap.emailAddress1 = con.Email;
        conWrap.address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap);
        
        ContactWrapper conWrap2 = new ContactWrapper();
        conWrap2 .billingIndicator = 'Y'; 
        conWrap2 .recipientIndicator = 'N';
        conWrap2 .salutation = '';
        conWrap2 .firstName = con1.FirstName;
        conWrap2 .lastName = con1.LastName;
        conWrap2 .nric = con1.NRIC__c;
        conWrap2 .passport = con1.Passport__c;
        conWrap2 .homeNumber = '09107620428';
        conWrap2 .mobileNumber1 = con1.Mobile_Number__c;
        conWrap2 .emailAddress1 = con1.Email;
        conWrap2 .address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap2 );     
        
          
        
        String accNumber = [Select Account_Auto_Number__c from Account Where Id =: acc.Id].Account_Auto_Number__c;
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = accNumber;
        accWrap.recordType = 'Direct Corporate';
        accWrap.billingType = billAcc.Billing_Type__c;            
        
        Test.startTest();        
       
        NewSubscriptionService.AccountWrapper aWrap = new NewSubscriptionService.AccountWrapper();
        NewSubscriptionService.ContactWrapper cWrap = new NewSubscriptionService.ContactWrapper();
        NewSubscriptionService.OrderWrapper oWrap = new NewSubscriptionService.OrderWrapper();
        NewSubscriptionService.OrderLineItemWrapper olWrap = new NewSubscriptionService.OrderLineItemWrapper();
        NewSubscriptionService.AddressWrapper adWrap = new NewSubscriptionService.AddressWrapper();
        
        olWrap.promotioncode='Test';        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/NewSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        NewSubscriptionServiceRequest nwSubServ = new NewSubscriptionServiceRequest();
        nwSubServ.subscriberAccount = accWrap;
        nwSubServ.contacts = conWrapList;
        nwSubserv.order = new OrderWrapper();
        nwSubserv.order.paymentMode = 'Cash';
        nwSubserv.order.paymentMethodId = '';
        nwSubserv.order.billingAccountNumber = null; //'BA00002408';
        nwSubserv.order.billingType2 = order.Billing_Type__c;
        nwSubserv.order.orderLineItems = new List<OrderLineItemWrapper>();    
        
        system.debug('TEST Orderline Items' + nwSubserv.order.orderLineItems);
        //system.assert(NewSubscriptionService.validateMandatoryFields(nwSubserv));
        
        String jsonStr = JSON.serialize(nwSubServ);
        NewSubscriptionService.NewSubscriptionServiceRequest esh = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        NewSubscriptionService.processRequest(esh);         
        Test.stopTest();
        }catch(Exception e) {
          }  
                  
    
  }
    static testMethod void tesNewSubSvcMethod4B(){
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        //ctry.Code__c = 'SG';
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
        //billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        //addressRec.Street_Name__c = 'Street';
        //addressRec.Building_Name__c = 'SG Building';
        //address.Address_1__c = 'Address 1';
        //addressRec.Address_2__c = 'Address 2';
        //addressRec.Address_3__c = 'Address 3';
        //addressRec.Address_4__c = 'Address 4';
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
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;

        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = addressRec.Postal_Code__c;
        addWrap.streetName = 'Strawberry St';
        addWrap.buildingName = addressRec.Building_Name__c;
        addWrap.country = 'Singapore';
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = 'BLK6 LOT5 Paz Village';
        addWrap.Address2 = addressRec.Address_2__c;
        addWrap.Address3 = addressRec.Address_3__c;
        addWrap.Address4 = addressRec.Address_4__c;
        
        system.debug('addWrap: '+ addWrap );
        
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
        ContactWrapper conWrap = new ContactWrapper();
        conWrap.billingIndicator = 'Y'; 
        conWrap.recipientIndicator = 'N';
        conWrap.salutation = '';
        conWrap.firstName = con.FirstName;
        conWrap.lastName = con.LastName;
        conWrap.nric = con.NRIC__c;
        conWrap.passport = con.Passport__c;
        conWrap.homeNumber = '09107620428';
        conWrap.mobileNumber1 = con.Mobile_Number__c;
        conWrap.emailAddress1 = con.Email;
        conWrap.address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap);
        
        ContactWrapper conWrap2 = new ContactWrapper();
        conWrap2 .billingIndicator = 'Y'; 
        conWrap2 .recipientIndicator = 'N';
        conWrap2 .salutation = '';
        conWrap2 .firstName = con1.FirstName;
        conWrap2 .lastName = con1.LastName;
        conWrap2 .nric = con1.NRIC__c;
        conWrap2 .passport = con1.Passport__c;
        conWrap2 .homeNumber = '09107620428';
        conWrap2 .mobileNumber1 = con1.Mobile_Number__c;
        conWrap2 .emailAddress1 = con1.Email;
        conWrap2 .address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap2 );        
        
        String accNumber = [Select Account_Auto_Number__c from Account Where Id =: acc.Id].Account_Auto_Number__c;
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = accNumber;
        accWrap.recordType = 'Direct Corporate';
        accWrap.billingType = billAcc.Billing_Type__c;            
        
        Test.startTest();        
       
        NewSubscriptionService.AccountWrapper aWrap = new NewSubscriptionService.AccountWrapper();
        NewSubscriptionService.ContactWrapper cWrap = new NewSubscriptionService.ContactWrapper();
        NewSubscriptionService.OrderWrapper oWrap = new NewSubscriptionService.OrderWrapper();
        NewSubscriptionService.OrderLineItemWrapper olWrap = new NewSubscriptionService.OrderLineItemWrapper();
        NewSubscriptionService.AddressWrapper adWrap = new NewSubscriptionService.AddressWrapper();
        
        List<NewSubscriptionService.OrderLineItemWrapper> olWrapList = new List<NewSubscriptionService.OrderLineItemWrapper>();
        olWrap.promotioncode = 'TESTCODE';
        olWrap.packagecode = 'TEST PACKAGE CODE';
        olWrap.addonpackagecode = 'ADD ON Package code';
        olWrap.quantity = 1;
        olWrap.startDate = '02/19/2015';
        //public List<String> giftCode;
        olWrap.contractenddate = '02/21/2015';    
        
        olWrapList.add(olWrap); 
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/NewSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        NewSubscriptionServiceRequest nwSubServ = new NewSubscriptionServiceRequest();
        nwSubServ.subscriberAccount = accWrap;
        nwSubServ.contacts = conWrapList;
        nwSubserv.order = new OrderWrapper();
        nwSubServ.order.orderLineItems =new List<OrderLineItemWrapper>();   
        nwSubserv.order.paymentMode = 'Cash';
        nwSubserv.order.paymentMethodId = '';
        nwSubserv.order.billingType2 = order.Billing_Type__c;
        
        //system.debug('billAcc: ' + billAcc.id);
        
        //nwSubserv.order.billingAccountNumber = [Select Account_Auto_Number__c From Account Where Id =: billAcc.id].Account_Auto_Number__c; 

        //nwSubserv.order.orderLineItems = new List<OrderLineItemWrapper>();
       
      
        String jsonStr = JSON.serialize(nwSubServ);
        NewSubscriptionService.NewSubscriptionServiceRequest esh = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        NewSubscriptionService.processRequest(esh);
        Test.stopTest();
        }catch(Exception e) {
          }  
                  
    
  }
    /**
    *  @Description: tests deeper conditions, private classes. 
    *  @name tesNewSubSvcMethod5
    *  @param none
    *  @return none
    *  @throws na
    */        
    static testMethod void tesNewSubSvcMethod5(){
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        //ctry.Code__c = 'SG';
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
        
        Publication__c publ = TestDataFactory.createPublication(1)[0];
        publ.Direct_Sub_Delivery_Method__c = 'Vendor';
        insert publ;  
        
        List <Product_Publication__c> prodPub = TestDataFactory.createProductPublication(1);
        prodPub[0].Publication_Code__c = publ.id;
        prodPub[0].ZProduct__c = zProduct.Id;
        insert prodPub;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        //billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        //addressRec.Street_Name__c = 'Street';
        //addressRec.Building_Name__c = 'SG Building';
        //address.Address_1__c = 'Address 1';
        //addressRec.Address_2__c = 'Address 2';
        //addressRec.Address_3__c = 'Address 3';
        //addressRec.Address_4__c = 'Address 4';
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
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = '123456';
        addWrap.streetName = 'Strawberry St';
        addWrap.buildingName = addressRec.Building_Name__c;
        addWrap.country = 'SG';
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = 'BLK6 LOT5 Paz Village';
        addWrap.Address2 = addressRec.Address_2__c;
        addWrap.Address3 = addressRec.Address_3__c;
        addWrap.Address4 = addressRec.Address_4__c;
        
        
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
        ContactWrapper conWrap = new ContactWrapper();
        conWrap.billingIndicator = 'Y'; 
        conWrap.recipientIndicator = 'Y';
        conWrap.salutation = '';
        conWrap.firstName = con.FirstName;
        conWrap.lastName = con.LastName;
        conWrap.nric = con.NRIC__c;
        conWrap.passport = con.Passport__c;
        conWrap.homeNumber = '09107620428';
        conWrap.mobileNumber1 = con.Mobile_Number__c;
        conWrap.emailAddress1 = con.Email;
        conWrap.address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap);
        
        ContactWrapper conWrap2 = new ContactWrapper();
        conWrap2 .billingIndicator = 'Y'; 
        conWrap2 .recipientIndicator = 'Y';
        conWrap2 .salutation = '';
        conWrap2 .firstName = con1.FirstName;
        conWrap2 .lastName = con1.LastName;
        conWrap2 .nric = con1.NRIC__c;
        conWrap2 .passport = con1.Passport__c;
        conWrap2 .homeNumber = '09107620428';
        conWrap2 .mobileNumber1 = con1.Mobile_Number__c;
        conWrap2 .emailAddress1 = con1.Email;
        conWrap2 .address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap2 ); 
        
        String accNumber = [Select Account_Auto_Number__c from Account Where Id =: acc.Id].Account_Auto_Number__c;
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = null;
        accWrap.recordType = 'Direct Corporate';
        accWrap.billingType = billAcc.Billing_Type__c;            
        
        Test.startTest();
        
        NewSubscriptionService.AccountWrapper aWrap = new NewSubscriptionService.AccountWrapper();
        NewSubscriptionService.ContactWrapper cWrap = new NewSubscriptionService.ContactWrapper();
        NewSubscriptionService.OrderWrapper oWrap = new NewSubscriptionService.OrderWrapper();
        //List<NewSubscriptionService.OrderLineItemWrapper> olWrapList = new List<NewSubscriptionService.OrderLineItemWrapper>();        
        NewSubscriptionService.OrderLineItemWrapper olWrap = new NewSubscriptionService.OrderLineItemWrapper();
        NewSubscriptionService.AddressWrapper adWrap = new NewSubscriptionService.AddressWrapper();
        //NewSubscriptionService.createCase(order);
        //NewSubscriptionService.getEarliestStartDate(prodPub);
        
        olWrap.promotioncode = 'TESTCODE';
        olWrap.packagecode = 'TEST PACKAGE CODE';
        olWrap.addonpackagecode = 'ADD ON Package code';
        olWrap.quantity = 1;
        olWrap.startDate = '02/19/2015';
        //public List<String> giftCode;
        olWrap.contractenddate = '02/21/2015'; 
        //olWrapList.add(olWrap);        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/NewSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        NewSubscriptionServiceRequest nwSubServ = new NewSubscriptionServiceRequest();
        nwSubServ.subscriberAccount = accWrap;
        nwSubServ.contacts = conWrapList;
        nwSubserv.order = new OrderWrapper();
        nwSubserv.order.paymentMode = 'Cash';
        nwSubserv.order.paymentMethodId = '';
        nwSubserv.order.billingAccountNumber = null;
        nwSubserv.order.billingType2 = order.Billing_Type__c;
        nwSubserv.order.orderLineItems = new List<OrderLineItemWrapper>();

        String jsonStr = JSON.serialize(nwSubServ);
        NewSubscriptionService.NewSubscriptionServiceRequest esh = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        NewSubscriptionService.processRequest(esh);
 
        Test.stopTest();
        }catch(Exception e) {
          }  
  }
    static testMethod void tesNewSubSvcMethod5B(){
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        //ctry.Code__c = 'SG';
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
        
        Publication__c publ = TestDataFactory.createPublication(1)[0];
        publ.Direct_Sub_Delivery_Method__c = 'Vendor';
        insert publ;  
        
        List <Product_Publication__c> prodPub = TestDataFactory.createProductPublication(1);
        prodPub[0].Publication_Code__c = publ.id;
        prodPub[0].ZProduct__c = zProduct.Id;
        insert prodPub;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        //billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        //Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = ctry.id;
        //addressRec.Street_Name__c = 'Street';
        //addressRec.Building_Name__c = 'SG Building';
        //address.Address_1__c = 'Address 1';
        //addressRec.Address_2__c = 'Address 2';
        //addressRec.Address_3__c = 'Address 3';
        //addressRec.Address_4__c = 'Address 4';
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
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = addressRec.Block_House_Number__c;
        addWrap.levelNumber = addressRec.Level_Number__c;
        addWrap.unitNumber = addressRec.Unit_Number__c;
        addWrap.postalCode = '123456';
        addWrap.streetName = 'Strawberry St';
        addWrap.buildingName = addressRec.Building_Name__c;
        addWrap.country = 'SG';
        addWrap.singpostAddressType = addressRec.Address_Type__c;   
        addWrap.Address1 = 'BLK6 LOT5 Paz Village';
        addWrap.Address2 = addressRec.Address_2__c;
        addWrap.Address3 = addressRec.Address_3__c;
        addWrap.Address4 = addressRec.Address_4__c;
        
        
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
        ContactWrapper conWrap = new ContactWrapper();
        conWrap.billingIndicator = 'Y'; 
        conWrap.recipientIndicator = 'Y';
        conWrap.salutation = '';
        conWrap.firstName = con.FirstName;
        conWrap.lastName = con.LastName;
        conWrap.nric = con.NRIC__c;
        conWrap.passport = con.Passport__c;
        conWrap.homeNumber = '09107620428';
        conWrap.mobileNumber1 = con.Mobile_Number__c;
        conWrap.emailAddress1 = con.Email;
        conWrap.address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap);
        
        ContactWrapper conWrap2 = new ContactWrapper();
        conWrap2 .billingIndicator = 'Y'; 
        conWrap2 .recipientIndicator = 'Y';
        conWrap2 .salutation = '';
        conWrap2 .firstName = con1.FirstName;
        conWrap2 .lastName = con1.LastName;
        conWrap2 .nric = con1.NRIC__c;
        conWrap2 .passport = con1.Passport__c;
        conWrap2 .homeNumber = '09107620428';
        conWrap2 .mobileNumber1 = con1.Mobile_Number__c;
        conWrap2 .emailAddress1 = con1.Email;
        conWrap2 .address = addWrap; //AddressWrapper address;
        conWrapList.add(conWrap2 ); 
        
        String accNumber = [Select Account_Auto_Number__c from Account Where Id =: acc.Id].Account_Auto_Number__c;
        AccountWrapper accWrap = new AccountWrapper();
        accWrap.accountName = acc.Name;
        accWrap.accountNumber = null;
        accWrap.recordType = 'Direct Corporate';
        accWrap.billingType = billAcc.Billing_Type__c;            
        
        Test.startTest();
        
        NewSubscriptionService.AccountWrapper aWrap = new NewSubscriptionService.AccountWrapper();
        NewSubscriptionService.ContactWrapper cWrap = new NewSubscriptionService.ContactWrapper();
        NewSubscriptionService.OrderWrapper oWrap = new NewSubscriptionService.OrderWrapper();
        //List<NewSubscriptionService.OrderLineItemWrapper> olWrapList = new List<NewSubscriptionService.OrderLineItemWrapper>();        
        NewSubscriptionService.OrderLineItemWrapper olWrap = new NewSubscriptionService.OrderLineItemWrapper();
        NewSubscriptionService.AddressWrapper adWrap = new NewSubscriptionService.AddressWrapper();
        NewSubscriptionService.createCase(order, TRUE);
        NewSubscriptionService.getEarliestStartDate(prodPub);
        //NewSubscriptionService.checkInvalidCharacters(cWrap);
        
        olWrap.promotioncode = 'TESTCODE';
        olWrap.packagecode = 'TEST PACKAGE CODE';
        olWrap.addonpackagecode = 'ADD ON Package code';
        olWrap.quantity = 1;
        olWrap.startDate = '02/19/2015';
        //public List<String> giftCode;
        olWrap.contractenddate = '02/21/2015'; 
        //olWrapList.add(olWrap);        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/NewSubscriptionService/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        NewSubscriptionServiceRequest nwSubServ = new NewSubscriptionServiceRequest();
        nwSubServ.subscriberAccount = accWrap;
        nwSubServ.contacts = conWrapList;
        nwSubserv.order = new OrderWrapper();
        nwSubserv.order.paymentMode = 'Cash';
        nwSubserv.order.paymentMethodId = '';
        nwSubserv.order.billingAccountNumber = null;
        nwSubserv.order.billingType2 = order.Billing_Type__c;
        nwSubserv.order.orderLineItems = new List<OrderLineItemWrapper>();

        String jsonStr = JSON.serialize(nwSubServ);
        NewSubscriptionService.NewSubscriptionServiceRequest esh = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        NewSubscriptionService.processRequest(esh);
        NewSubscriptionService.validateValues(esh);

        Test.stopTest();
        }catch(Exception e) {
          }  
  }       
}