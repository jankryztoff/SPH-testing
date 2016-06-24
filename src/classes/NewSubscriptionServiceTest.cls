/*
 * Class Name: NewSubscriptionServiceTest
 * @author: Flores, Emmanuel D.
 * Date: 08/04/2015
 * Project/Requirement: 
 * @description : Test Class for NewSubscriptionService class
 * History:
 * 04/08/2016 RReyes - reconstructured Test Class
 */
@isTest (seeAllData= True)
global class NewSubscriptionServiceTest{

    global class NewSubscriptionServiceResponse {
        String svc_status;
        String error_code;
        String error_message = '';
        String subscriberId;
        String subscriptionId;
        String orderid;
        String debug = '';
    }
    
    global class NewSubscriptionServiceRequest {
        AccountWrapper subscriberAccount; 
        List<ContactWrapper> contacts;
        OrderWrapper order;       
    }
    
    public class AccountWrapper {
        String accountName;
        String accountNumber; 
        String recordType;
    }
        
    public class ContactWrapper {
        String contactId;
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
    
    public class OrderWrapper {
        String billingAccountNumber;
        String paymentMode;
        String paymentMethodId;
        String ReferenceId;
        String ldapId;
        String paypalbaID;
        String paypalemail;
        List<OrderLineItemWrapper> orderLineItems;
        String vendorConversion = 'N';
    }
    
    public class OrderLineItemWrapper {        
        public String promotioncode;
        public String packagecode;
        public String addonpackagecode; 
        public Integer quantity;
        public String startDate;
        public List<String> giftCode;
        public String contractenddate;
        
    }
    
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
    
    
    static testMethod void testForNull(){
        //request.subscriberAccount
        AccountWrapper acctWrap = new AccountWrapper();
        acctWrap.accountName = '';
        acctWrap.accountNumber = '';
        acctWrap.recordType = '';
        
        //request.contacts
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = '';
        addWrap.levelNumber = '';
        addWrap.unitNumber = '';
        addWrap.postalCode = '';
        addWrap.streetName = '';
        addWrap.buildingName = '';
        addWrap.country = '';
        addWrap.singpostAddressType = '';
        addWrap.Address1 = '';
        addWrap.Address2 = '';
        addWrap.Address3 = '';
        addWrap.Address4 = '';
        
        ContactWrapper contWrap = new ContactWrapper();
        contWrap.contactId = '';
        contWrap.salutation = '';
        contWrap.firstName = '';
        contWrap.lastName = '';
        contWrap.nric = '';
        contWrap.passport = '';
        contWrap.billingIndicator = '';
        contWrap.recipientIndicator = '';
        contWrap.homeNumber = '';
        contWrap.mobileNumber1 = '';
        contWrap.emailAddress1 = '';
        contWrap.address = addWrap;
        
        List<ContactWrapper> lstContWrap = new List<ContactWrapper>();
        lstContWrap.add(contWrap);
        
        //request.order
        List<String> lstGiftCode = new List<String>();
        lstGiftCode.add('');
        
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();        
        oliWrap.promotioncode = '';
        oliWrap.packagecode = '';
        oliWrap.addonpackagecode = ''; 
        oliWrap.quantity = null; //Integer
        oliWrap.startDate = '';
        oliWrap.giftCode = lstGiftCode; //List<String>
        oliWrap.contractenddate = '';
        
        List<OrderLineItemWrapper> lstOliWrap = new List<OrderLineItemWrapper>();
        lstOliWrap.add(oliWrap);
        
        OrderWrapper ordWrap = new OrderWrapper();
        ordWrap.billingAccountNumber = '';
        ordWrap.paymentMode = '';
        ordWrap.paymentMethodId = '';
        ordWrap.ReferenceId = '';
        ordWrap.ldapId = '';
        ordWrap.paypalbaID = '';
        ordWrap.paypalemail = '';
        ordWrap.orderLineItems = lstOliWrap; //List<OrderLineItemWrapper> 
        ordWrap.vendorConversion = '';
        
        
        NewSubscriptionServiceRequest request = new NewSubscriptionServiceRequest();
        request.subscriberAccount = acctWrap; //AccountWrapper
        request.contacts = lstContWrap; //List<ContactWrapper>
        request.order = ordWrap;//OrderWrapper
        
        String jsonStr = JSON.serialize(request);
        NewSubscriptionService.NewSubscriptionServiceRequest paramRequest = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        
        Test.StartTest();
        NewSubscriptionService.processRequest(paramRequest);
        Test.StopTest();        
    }
    
    static testMethod void testForIsValidTrue(){
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'PACKCODE';
        pack.Product_Family_Current_Package__c = 'test';
        insert pack;
        
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
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        ctry.Code__c = 'Singapore';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        postal.House_Block_Number__c = 'HB';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='01';
        addressRec.Level_Number__c ='23';
        addressRec.Unit_Number__c = '45';
        addressRec.Country__c = ctry.id;
        //addressRec.Building_Name__c = 'SG Building';
        insert addressRec; 
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'FName';
        con.LastName = 'LName';
        //con.NRIC__c = '123456';
        con.Passport__c = 'Passport Test';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__AccountNumber__c = 'BA999999';
        insert billAcc;

        //request.subscriberAccount
        AccountWrapper acctWrap = new AccountWrapper();
        acctWrap.accountName = '';
        acctWrap.accountNumber = '';
        acctWrap.recordType = '';
        
        //request.contacts
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = '';
        addWrap.levelNumber = '';
        addWrap.unitNumber = '';
        addWrap.postalCode = '';
        addWrap.streetName = '';
        addWrap.buildingName = '';
        addWrap.country = '';
        addWrap.singpostAddressType = '';
        addWrap.Address1 = '';
        addWrap.Address2 = '';
        addWrap.Address3 = '';
        addWrap.Address4 = '';
        
        ContactWrapper contWrap = new ContactWrapper();
        contWrap.contactId = con.Id;
        contWrap.salutation = '';
        contWrap.firstName = '';
        contWrap.lastName = '';
        contWrap.nric = '';
        contWrap.passport = '';
        contWrap.billingIndicator = 'Y';
        contWrap.recipientIndicator = 'Y';
        contWrap.homeNumber = '';
        contWrap.mobileNumber1 = '';
        contWrap.emailAddress1 = '';
        contWrap.address = addWrap;
        
        List<ContactWrapper> lstContWrap = new List<ContactWrapper>();
        lstContWrap.add(contWrap);
        
        //request.order
        List<String> lstGiftCode = new List<String>();
        lstGiftCode.add('');
        
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();        
        oliWrap.promotioncode = '';
        oliWrap.packagecode = 'PACKCODE';
        oliWrap.addonpackagecode = ''; 
        oliWrap.quantity = null; //Integer
        oliWrap.startDate = String.valueOf(Date.Today().addDays(1));
        oliWrap.giftCode = lstGiftCode; //List<String>
        oliWrap.contractenddate = '04/10/2016';
        
        List<OrderLineItemWrapper> lstOliWrap = new List<OrderLineItemWrapper>();
        lstOliWrap.add(oliWrap);
        
        
        
        OrderWrapper ordWrap = new OrderWrapper();
        ordWrap.billingAccountNumber = billAcc.Zuora__AccountNumber__c;
        ordWrap.paymentMode = 'Paypal';
        ordWrap.paymentMethodId = '';
        ordWrap.ReferenceId = '';
        ordWrap.ldapId = '2222222217';
        ordWrap.paypalbaID = '';
        ordWrap.paypalemail = '';
        ordWrap.orderLineItems = lstOliWrap; //List<OrderLineItemWrapper> 
        ordWrap.vendorConversion = 'Y';
        
        
        NewSubscriptionServiceRequest request = new NewSubscriptionServiceRequest();
        request.subscriberAccount = acctWrap; //AccountWrapper
        request.contacts = lstContWrap; //List<ContactWrapper>
        request.order = ordWrap;//OrderWrapper
        
        String jsonStr = JSON.serialize(request);
        NewSubscriptionService.NewSubscriptionServiceRequest paramRequest = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        
        Test.StartTest();
        NewSubscriptionService.processRequest(paramRequest);
        Test.StopTest();        
    }
    
    static testMethod void testForInvalidMandatoryFields(){
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'PACKCODE';
        pack.Product_Family_Current_Package__c = 'test';
        insert pack;
        
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
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        ctry.Code__c = 'Singapore';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        postal.House_Block_Number__c = 'HB';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='01';
        addressRec.Level_Number__c ='23';
        addressRec.Unit_Number__c = '45';
        addressRec.Country__c = ctry.id;
        //addressRec.Building_Name__c = 'SG Building';
        insert addressRec; 
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'FName';
        con.LastName = 'LName';
        //con.NRIC__c = '123456';
        con.Passport__c = 'Passport Test';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        insert billAcc;
        
        //request.subscriberAccount
        AccountWrapper acctWrap = new AccountWrapper();
        acctWrap.accountName = '';
        acctWrap.accountNumber = '';
        acctWrap.recordType = '';
        
        //request.contacts
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = '';
        addWrap.levelNumber = '';
        addWrap.unitNumber = '';
        addWrap.postalCode = '';
        addWrap.streetName = '';
        addWrap.buildingName = '';
        addWrap.country = 'SG';
        addWrap.singpostAddressType = '';
        addWrap.Address1 = '';
        addWrap.Address2 = '';
        addWrap.Address3 = '';
        addWrap.Address4 = '';
        
        ContactWrapper contWrap = new ContactWrapper();
        contWrap.contactId = '';
        contWrap.salutation = '';
        contWrap.firstName = '';
        contWrap.lastName = '';
        contWrap.nric = '';
        contWrap.passport = '';
        contWrap.billingIndicator = 'Y';
        contWrap.recipientIndicator = 'Y';
        contWrap.homeNumber = '';
        contWrap.mobileNumber1 = '';
        contWrap.emailAddress1 = '';
        contWrap.address = addWrap;
        
        List<ContactWrapper> lstContWrap = new List<ContactWrapper>();
        lstContWrap.add(contWrap);
        
        //request.order
        List<String> lstGiftCode = new List<String>();
        lstGiftCode.add('');
        
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();        
        oliWrap.promotioncode = 'PromoCode';
        oliWrap.packagecode = 'PACKCODE';
        oliWrap.addonpackagecode = ''; 
        oliWrap.quantity = null; //Integer
        oliWrap.startDate = '';
        oliWrap.giftCode = lstGiftCode; //List<String>
        oliWrap.contractenddate = '';
        
        List<OrderLineItemWrapper> lstOliWrap = new List<OrderLineItemWrapper>();
        lstOliWrap.add(oliWrap);
        
        OrderWrapper ordWrap = new OrderWrapper();
        ordWrap.billingAccountNumber = billAcc.Zuora__AccountNumber__c;
        ordWrap.paymentMode = 'Paypal';
        ordWrap.paymentMethodId = '';
        ordWrap.ReferenceId = '';
        ordWrap.ldapId = '';
        ordWrap.paypalbaID = '';
        ordWrap.paypalemail = '';
        ordWrap.orderLineItems = lstOliWrap; //List<OrderLineItemWrapper> 
        ordWrap.vendorConversion = 'Y';
        
        
        NewSubscriptionServiceRequest request = new NewSubscriptionServiceRequest();
        request.subscriberAccount = acctWrap; //AccountWrapper
        request.contacts = lstContWrap; //List<ContactWrapper>
        request.order = ordWrap;//OrderWrapper
        
        String jsonStr = JSON.serialize(request);
        NewSubscriptionService.NewSubscriptionServiceRequest paramRequest = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);
        
        Test.StartTest();
        //NewSubscriptionService.processRequest(paramRequest);
        Test.StopTest();        
    }

    static testMethod void testCreateOliPositive(){
        
        List<Package__c> lstPkg = new List<Package__c>();
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '12';
        pack.Package_Code__c = 'PkgCode';
        pack.Product_Family_Current_Package__c = 'MY';
        pack.Package_Sub_Type__c = '';
        pack.Subscription_Type__c = 'Termed';
        lstPkg.add(pack);
        
        Package__c addOnpack = TestDataFactory.createPackage(1)[0];
        addOnpack.Billing_Type__c = 'Full Prepaid';
        addOnpack.Package_Type__c = 'Add On';
        addOnpack.Subscription_Period__c = '12';
        addOnpack.Package_Code__c = 'AddOnPkgCode';
        addOnpack.Product_Family_Current_Package__c = 'addOn';
        addOnpack.Package_Sub_Type__c = '';
        addOnpack.Subscription_Type__c = 'Termed';
        lstPkg.add(addOnpack);
        
        insert lstPkg;
        
        //ZProduct
        List<zqu__ZProduct__c> lstZProd = new List<zqu__ZProduct__c>();
        zqu__ZProduct__c zProductNP = TestDataFactory.createZProduct(1)[0];
        zProductNP.ProductSubType__c = 'Newspaper';
        zProductNP.ProductPlatform__c = 'Print';
        zProductNP.zqu__ZuoraId__c = 'newspaperzProduct';
        lstZProd.add(zProductNP);
        
        zqu__ZProduct__c zProductMag = TestDataFactory.createZProduct(1)[0];
        zProductMag.ProductSubType__c = 'Magazine';
        zProductMag.ProductPlatform__c = 'Print';
        zProductMag.zqu__ZuoraId__c = 'MagazinezProduct';
        lstZProd.add(zProductMag);
        
        insert lstZProd;
        
        //Product Rate Plan
        List<zqu__ProductRatePlan__c> lstPRP = new List<zqu__ProductRatePlan__c>();
        zqu__ProductRatePlan__c prpNP = TestDataFactory.createProductRatePlan(1)[0];
        prpNP.zqu__ZProduct__c = zProductNP.Id;
        prpNP.RatePlanType__c= 'Bill Plan';
        prpNP.zqu__EffectiveStartDate__c= date.today();
        prpNP.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpNP.zqu__Deleted__c = false;
        prpNP.SubscriptionFrequency__c = '0';
        prpNP.zqu__ZuoraId__c = 'prpNewspaper';
        prpNP.BillingType__c = 'Full Prepaid';
        prpNP.BillingPeriod__c = '12';
        lstPRP.add(prpNP);
        
        zqu__ProductRatePlan__c prpMag = TestDataFactory.createProductRatePlan(1)[0];
        prpMag.zqu__ZProduct__c = zProductMag.Id;
        prpMag.RatePlanType__c= 'Bill Plan';
        prpMag.zqu__EffectiveStartDate__c= date.today();
        prpMag.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpMag.zqu__Deleted__c = false;
        prpMag.SubscriptionFrequency__c = '1';
        prpMag.zqu__ZuoraId__c = 'prpMagazine';
        prpMag.BillingType__c = 'Full Prepaid';
        prpMag.BillingPeriod__c = '12';
        lstPRP.add(prpMag);
        
        insert lstPRP;
        
        //Product Rate Plan Charge
        List<zqu__ProductRatePlanCharge__c> lstPRPCharge = new List<zqu__ProductRatePlanCharge__c>();
        zqu__ProductRatePlanCharge__c prpChargeNP =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeNP.Name = 'Product Rate Plan Charge';
        prpChargeNP.zqu__ProductRatePlan__c = prpNP.id;
        prpChargeNP.zqu__ZuoraId__c = 'prpChargeNewspaper';
        lstPRPCharge.add(prpChargeNP);
        zqu__ProductRatePlanCharge__c prpChargeMag =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeMag.Name = 'Product Rate Plan Charge';
        prpChargeMag.zqu__ProductRatePlan__c = prpMag.id;
        prpChargeMag.zqu__ZuoraId__c = 'prpChargeMagazine';
        lstPRPCharge.add(prpChargeMag);
        insert lstPRPCharge;
        
        List<Publication__c> lstpub = new List<Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
        pub.Earliest_Start_Date__c = Date.Today().addDays(-5);
        lstpub.add(pub);
        Publication__c pub2 = TestDataFactory.createPublication(1)[0];
        pub2.Direct_Sub_Delivery_Method__c = 'Vendor';
        pub2.Earliest_Start_Date__c = Date.Today().addDays(-7);
        lstpub.add(pub2);
        //insert lstPub;
        
        List<Product_Publication__c> lstProdPub = new List<Product_Publication__c>();
        Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
        prodPub.Publication_Code__c = pub.id;
        prodPub.ZProduct__c = zProductNP.Id;
        lstProdPub.add(prodPub);
        Product_Publication__c prodPubMag = TestDataFactory.createProductPublication(1)[0];
        prodPubMag.Publication_Code__c = pub2.id;
        prodPubMag.ZProduct__c = zProductMag.Id;
        lstProdPub.add(prodPubMag);
        insert lstProdPub;
        
        List<Product_Publication__c> lstProdPub2 = new List<Product_Publication__c>();
        lstProdPub[0] = prodPub;
        lstProdPub[1] = prodPubMag;
        
        //Package Item
        List<Package_Item__c> lstPkgItem = new List<Package_Item__c>();
        Package_Item__c pItemNP = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemNP.Package__c = pack.id;
        pItemNP.Product_Rate_Plan__c = prpNP.id;
        pItemNP.Name = 'Test Pack Item Newspaper';
        lstPkgItem.add(pItemNP);
        Package_Item__c pItemMag = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemMag.Package__c = pack.id;
        pItemMag.Product_Rate_Plan__c = prpMag.id;
        pItemMag.Name = 'Test Pack Item Magazine';
        lstPkgItem.add(pItemMag);
        insert lstPkgItem; 
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract_Period__c = '24';
        promo.Penalty_Charge__c = '200';
        promo.Promotion_Code__c = 'PromoCode';
        insert promo;
        
        Gift__c gift = new Gift__c();
        gift.Gift_Code__c = 'GiftCode';
        insert gift;
        
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
        promoGift.Promotion__c = promo.id;
        promoGift.Gift__c = gift.id;
        insert promoGift;
        
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
        
        Account acctVen = TestDataFactory.createAccount(1, 'Vendor')[0];
        acctVen.NRIC__c = 'T1234567R';
        acctVen.Name = 'Vendor Account';
        acctVen.Phone = '123-456';
        acctVen.Email__c = 'test@test.com';
        acctVen.Date_of_Birth__c = date.today();
        acctVen.Gender__c = 'Male';
        acctVen.Race__c = 'Chinese';
        acctVen.Language__c = 'Others';
        acctVen.Contact_Person__c = 'Contact Person';
        acctVen.Sub_Group__c = 'Freelist(MY)';
        insert acctVen;
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        ctry.Code__c = 'Singapore';
        ctry.Zonal_Code__c = 'A';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        postal.House_Block_Number__c = 'HB';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='01';
        addressRec.Level_Number__c ='23';
        addressRec.Unit_Number__c = '45';
        addressRec.Country__c = ctry.id;
        addressRec.RecordTypeId = ConstantsSLB.getkeyid('Address_Local');
        insert addressRec; 
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'FName';
        con.LastName = 'LName';
        //con.NRIC__c = '123456';
        con.Passport__c = 'Passport Test';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        Zone__c zone = new Zone__c();
        zone.Zone_Name_External_Id__c = 'A';
        zone.Name = 'A';
        insert zone;
        
        List<Zone_Product__c> lstzoneProd = new List<Zone_Product__c>();
        
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Product__c = zProductNP.Id;
        zoneProd.Postage_Charge__c = 100;
        zoneProd.Effective_Start_Date__c = Date.Today();
        zoneProd.Zone__c = zone.id;
        lstzoneProd.add(zoneProd);
        Zone_Product__c zoneProdMag = new Zone_Product__c();
        zoneProdMag.Product__c = zProductMag.Id;
        zoneProdMag.Postage_Charge__c = 100;
        zoneProdMag.Effective_Start_Date__c = Date.Today();
        zoneProdMag.Zone__c = zone.id;
        lstzoneProd.add(zoneProdMag);
        insert lstzoneProd;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__AccountNumber__c = 'BA999999';
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Start';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Paypal';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Billing_Contact__c = con.id;
        order.Case_Record_Type__c = 'Start Subscription';
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
        
        Vendor_Allocation__c venAcc = new Vendor_Allocation__c();
        venAcc.Vendor_Account__c = acctVen.id;
        venAcc.SingPost_Address__c = postal.Id;
        venAcc.Allocated__c = true;
        venAcc.Effective_Start_Date__c = Date.Today().addDays(-5);
        venAcc.Effective_End_Date__c = Date.Today().addDays(30);
        insert venAcc;
        
        
        //request.subscriberAccount
        AccountWrapper acctWrap = new AccountWrapper();
        acctWrap.accountName = '';
        acctWrap.accountNumber = '';
        acctWrap.recordType = '';
        
        //request.contacts
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = '';
        addWrap.levelNumber = '';
        addWrap.unitNumber = '';
        addWrap.postalCode = '';
        addWrap.streetName = '';
        addWrap.buildingName = '';
        addWrap.country = '';
        addWrap.singpostAddressType = '';
        addWrap.Address1 = '';
        addWrap.Address2 = '';
        addWrap.Address3 = '';
        addWrap.Address4 = '';
        
        ContactWrapper contWrap = new ContactWrapper();
        contWrap.contactId = con.Id;
        contWrap.salutation = '';
        contWrap.firstName = '';
        contWrap.lastName = '';
        contWrap.nric = '';
        contWrap.passport = '';
        contWrap.billingIndicator = 'Y';
        contWrap.recipientIndicator = 'Y';
        contWrap.homeNumber = '';
        contWrap.mobileNumber1 = '';
        contWrap.emailAddress1 = '';
        contWrap.address = addWrap;
        
        List<ContactWrapper> lstContWrap = new List<ContactWrapper>();
        lstContWrap.add(contWrap);
        
        //request.order
        List<String> lstGiftCode = new List<String>();
        lstGiftCode.add('GiftCode');
        
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();        
        oliWrap.promotioncode = 'PromoCode';
        oliWrap.packagecode = 'PkgCode';
        oliWrap.addonpackagecode = 'AddOnPkgCode'; 
        oliWrap.quantity = 1; //Integer
        oliWrap.startDate = '04/10/2016';
        oliWrap.giftCode = lstGiftCode; //List<String>
        oliWrap.contractenddate = '04/10/2017';
        
        List<OrderLineItemWrapper> lstOliWrap = new List<OrderLineItemWrapper>();
        lstOliWrap.add(oliWrap);
        
        
        
        OrderWrapper ordWrap = new OrderWrapper();
        ordWrap.billingAccountNumber = billAcc.Zuora__AccountNumber__c;
        ordWrap.paymentMode = 'Paypal';
        ordWrap.paymentMethodId = '';
        ordWrap.ReferenceId = '';
        ordWrap.ldapId = '2222222217';
        ordWrap.paypalbaID = '';
        ordWrap.paypalemail = '';
        ordWrap.orderLineItems = lstOliWrap; //List<OrderLineItemWrapper> 
        ordWrap.vendorConversion = 'Y';
        
        
        NewSubscriptionServiceRequest request = new NewSubscriptionServiceRequest();
        request.subscriberAccount = acctWrap; //AccountWrapper
        request.contacts = lstContWrap; //List<ContactWrapper>
        request.order = ordWrap;//OrderWrapper
        
        String jsonStr = JSON.serialize(request);
        NewSubscriptionService.NewSubscriptionServiceRequest paramRequest = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);

        String oliJsonStr = JSON.serialize(oliWrap);
        NewSubscriptionService.OrderLineItemWrapper oliWrapper = (NewSubscriptionService.OrderLineItemWrapper)JSON.deserialize(oliJsonStr, NewSubscriptionService.OrderLineItemWrapper.class);
        
        List<NewSubscriptionService.OrderLineItemWrapper> lstOliWrap2 = new List<NewSubscriptionService.OrderLineItemWrapper>();
        lstOliWrap2.add(oliWrapper);
        
        Set<String> prodFam = new Set<String>();
        prodFam.add('test');
        
        
        Test.StartTest();
        NewSubscriptionService.processRequest(paramRequest);
        //NewSubscriptionService.createOrderLineItems(lstOliWrap2,order,ordWrap.ldapId,con, null);
        Boolean testBool = NewSubscriptionService.isUniqueProductFamily(prodFam, 'accountNumber');
        Date earliest = NewSubscriptionService.getEarliestStartDate(lstProdPub);
        Boolean isBillValid = NewSubscriptionService.isBillingTypevalid('BA999999',lstOliWrap2);
        Test.StopTest();        
    }
    
    static testmethod void testCheckInvalidChars(){
        
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = 'houseBlockNumber';
        addWrap.levelNumber = 'lbl';
        addWrap.unitNumber = 'unit';
        addWrap.postalCode = '123456';
        addWrap.streetName = 'street';
        addWrap.buildingName = 'bldg';
        addWrap.country = 'country';
        addWrap.singpostAddressType = 'addresstype';
        addWrap.Address1 = 'Address1';
        addWrap.Address2 = 'Address2';
        addWrap.Address3 = 'Address3';
        addWrap.Address4 = 'Address4';
        
        AddressWrapper addWrap2 = new AddressWrapper();
        addWrap2.houseBlockNumber = 'houseBlockNumber!';
        addWrap2.levelNumber = 'lbl';
        addWrap2.unitNumber = 'unit';
        addWrap2.postalCode = '123456';
        addWrap2.streetName = 'street';
        addWrap2.buildingName = 'bldg';
        addWrap2.country = 'country';
        addWrap2.singpostAddressType = 'addresstype';
        addWrap2.Address1 = 'Address1';
        addWrap2.Address2 = 'Address2';
        addWrap2.Address3 = 'Address3';
        addWrap2.Address4 = 'Address4';
        
        ContactWrapper contWrap1a = new ContactWrapper();
        contWrap1a.address = addWrap;
        
        ContactWrapper contWrap2a = new ContactWrapper();
        contWrap2a.address = addWrap;
        
        ContactWrapper contWrap1b = new ContactWrapper();
        contWrap1b.address = addWrap2;
        
        ContactWrapper contWrap2b = new ContactWrapper();
        contWrap2b.address = addWrap2;
        
        
        String cont1aJsonStr = JSON.serialize(contWrap1a);
        NewSubscriptionService.ContactWrapper contWrapper1a = (NewSubscriptionService.ContactWrapper)JSON.deserialize(cont1aJsonStr, NewSubscriptionService.ContactWrapper.class);
        
        String cont2aJsonStr = JSON.serialize(contWrap2a);
        NewSubscriptionService.ContactWrapper contWrapper2a = (NewSubscriptionService.ContactWrapper)JSON.deserialize(cont2aJsonStr, NewSubscriptionService.ContactWrapper.class);
        
        List<NewSubscriptionService.ContactWrapper> lstContWrap1 = new List<NewSubscriptionService.ContactWrapper>();
        lstContWrap1.add(contWrapper1a);
        lstContWrap1.add(contWrapper2a);
        
        String cont1bJsonStr = JSON.serialize(contWrap1b);
        NewSubscriptionService.ContactWrapper contWrapper1b = (NewSubscriptionService.ContactWrapper)JSON.deserialize(cont1bJsonStr, NewSubscriptionService.ContactWrapper.class);
        
        String cont2bJsonStr = JSON.serialize(contWrap2b);
        NewSubscriptionService.ContactWrapper contWrapper2b = (NewSubscriptionService.ContactWrapper)JSON.deserialize(cont2bJsonStr, NewSubscriptionService.ContactWrapper.class);
        
        List<NewSubscriptionService.ContactWrapper> lstContWrap2 = new List<NewSubscriptionService.ContactWrapper>();
        lstContWrap2.add(contWrapper1b);
        lstContWrap2.add(contWrapper2b);
        
        Test.StartTest();
        NewSubscriptionService.checkInvalidCharacters(lstContWrap1);
        NewSubscriptionService.checkInvalidCharacters(lstContWrap2);
        Test.StopTest();    
    }
    
    static testMethod void testSearchCreateAddress(){        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        ctry.Code__c = 'Singapore';
        ctry.Zonal_Code__c = 'A';
        ctry.Name = 'SG';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123456';
        postal.House_Block_Number__c = 'HB';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='01';
        addressRec.Level_Number__c ='23';
        addressRec.Unit_Number__c = '45';
        addressRec.Country__c = ctry.id;
        addressRec.RecordTypeId = ConstantsSLB.getkeyid('Address_Local');
        addressRec.Address_1__c = 'Address1';
        addressRec.Address_2__c = 'Address2';
        addressRec.Address_3__c = 'Address3';
        addressRec.Address_4__c = 'Address4';
        insert addressRec; 
        
        //request.contacts
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = '';
        addWrap.levelNumber = '';
        addWrap.unitNumber = '';
        addWrap.postalCode = '';
        addWrap.streetName = '';
        addWrap.buildingName = '';
        addWrap.country = 'Singapore';
        addWrap.singpostAddressType = '';
        addWrap.Address1 = '';
        addWrap.Address2 = '';
        addWrap.Address3 = '';
        addWrap.Address4 = '';
        
        AddressWrapper addWrap2 = new AddressWrapper();
        addWrap2.houseBlockNumber = '';
        addWrap2.levelNumber = '';
        addWrap2.unitNumber = '';
        addWrap2.postalCode = '';
        addWrap2.streetName = '';
        addWrap2.buildingName = '';
        addWrap2.country = 'Singapore';
        addWrap2.singpostAddressType = '';
        addWrap2.Address1 = 'Address1';
        addWrap2.Address2 = 'Address2';
        addWrap2.Address3 = 'Address3';
        addWrap2.Address4 = 'Address4';
        
        String add1JsonStr = JSON.serialize(addWrap);
        NewSubscriptionService.AddressWrapper add1Wrapper = (NewSubscriptionService.AddressWrapper)JSON.deserialize(add1JsonStr, NewSubscriptionService.AddressWrapper.class);
        
        String add2JsonStr = JSON.serialize(addWrap2);
        NewSubscriptionService.AddressWrapper add2Wrapper = (NewSubscriptionService.AddressWrapper)JSON.deserialize(add2JsonStr, NewSubscriptionService.AddressWrapper.class);
        
        Test.StartTest();
        Address__c add1 = NewSubscriptionService.searchAddress(add1Wrapper);
        Address__c add2 = NewSubscriptionService.searchAddress(add2Wrapper);
        
        Address__c add1b = NewSubscriptionService.createAddress(add1Wrapper);
        Address__c add2b = NewSubscriptionService.createAddress(add2Wrapper);
        
        Country__c ctry2 =  NewSubscriptionService.getCountry('myCountryCode');
        
        Singpost_Address__c postal1 = NewSubscriptionService.getSingpostAddress('123456','Building','HB');
        Singpost_Address__c postal2 = NewSubscriptionService.getSingpostAddress('123456','BuildingFalse','HB');
        Test.StopTest();        
    }

    static testMethod void testValidateSimilarSub(){        
        
        Test.StartTest();
        Set<String> productFamiliesParam = new Set<String>();
        Boolean isValid = NewSubscriptionService.validateSimilarSubscriptions('subscriptionIdParam', 'accountNumberParam',productFamiliesParam ,'countryCodeParam','postalCodeParam', 'levelNumberParam', 'unitNumberParam');
        Test.StopTest();        
    }
    static testMethod void testCreateOliPositive2(){
        
        List<Package__c> lstPkg = new List<Package__c>();
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '12';
        pack.Package_Code__c = 'PkgCode';
        pack.Product_Family_Current_Package__c = 'MY';
        pack.Package_Sub_Type__c = '';
        pack.Subscription_Type__c = 'Termed';
        lstPkg.add(pack);
        
        Package__c addOnpack = TestDataFactory.createPackage(1)[0];
        addOnpack.Billing_Type__c = 'Full Prepaid';
        addOnpack.Package_Type__c = 'Add On';
        addOnpack.Subscription_Period__c = '12';
        addOnpack.Package_Code__c = 'AddOnPkgCode';
        addOnpack.Product_Family_Current_Package__c = 'addOn';
        addOnpack.Package_Sub_Type__c = '';
        addOnpack.Subscription_Type__c = 'Termed';
        lstPkg.add(addOnpack);
        
        insert lstPkg;
        
        //ZProduct
        List<zqu__ZProduct__c> lstZProd = new List<zqu__ZProduct__c>();
        zqu__ZProduct__c zProductNP = TestDataFactory.createZProduct(1)[0];
        zProductNP.ProductSubType__c = 'Newspaper';
        zProductNP.ProductPlatform__c = 'Print';
        zProductNP.zqu__ZuoraId__c = 'newspaperzProduct';
        lstZProd.add(zProductNP);
        
        zqu__ZProduct__c zProductMag = TestDataFactory.createZProduct(1)[0];
        zProductMag.ProductSubType__c = 'Magazine';
        zProductMag.ProductPlatform__c = 'Print';
        zProductMag.zqu__ZuoraId__c = 'MagazinezProduct';
        lstZProd.add(zProductMag);
        
        insert lstZProd;
        
        //Product Rate Plan
        List<zqu__ProductRatePlan__c> lstPRP = new List<zqu__ProductRatePlan__c>();
        zqu__ProductRatePlan__c prpNP = TestDataFactory.createProductRatePlan(1)[0];
        prpNP.zqu__ZProduct__c = zProductNP.Id;
        prpNP.RatePlanType__c= 'Bill Plan';
        prpNP.zqu__EffectiveStartDate__c= date.today();
        prpNP.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpNP.zqu__Deleted__c = false;
        prpNP.SubscriptionFrequency__c = '0';
        prpNP.zqu__ZuoraId__c = 'prpNewspaper';
        prpNP.BillingType__c = 'Full Prepaid';
        prpNP.BillingPeriod__c = '12';
        lstPRP.add(prpNP);
        
        zqu__ProductRatePlan__c prpMag = TestDataFactory.createProductRatePlan(1)[0];
        prpMag.zqu__ZProduct__c = zProductMag.Id;
        prpMag.RatePlanType__c= 'Bill Plan';
        prpMag.zqu__EffectiveStartDate__c= date.today();
        prpMag.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpMag.zqu__Deleted__c = false;
        prpMag.SubscriptionFrequency__c = '1';
        prpMag.zqu__ZuoraId__c = 'prpMagazine';
        prpMag.BillingType__c = 'Full Prepaid';
        prpMag.BillingPeriod__c = '12';
        lstPRP.add(prpMag);
        
        insert lstPRP;
        
        //Product Rate Plan Charge
        List<zqu__ProductRatePlanCharge__c> lstPRPCharge = new List<zqu__ProductRatePlanCharge__c>();
        zqu__ProductRatePlanCharge__c prpChargeNP =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeNP.Name = 'Product Rate Plan Charge';
        prpChargeNP.zqu__ProductRatePlan__c = prpNP.id;
        prpChargeNP.zqu__ZuoraId__c = 'prpChargeNewspaper';
        lstPRPCharge.add(prpChargeNP);
        zqu__ProductRatePlanCharge__c prpChargeMag =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeMag.Name = 'Product Rate Plan Charge';
        prpChargeMag.zqu__ProductRatePlan__c = prpMag.id;
        prpChargeMag.zqu__ZuoraId__c = 'prpChargeMagazine';
        lstPRPCharge.add(prpChargeMag);
        insert lstPRPCharge;
        
        List<Publication__c> lstpub = new List<Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
        pub.Earliest_Start_Date__c = Date.Today().addDays(-5);
        lstpub.add(pub);
        Publication__c pub2 = TestDataFactory.createPublication(1)[0];
        pub2.Direct_Sub_Delivery_Method__c = 'Vendor';
        pub2.Earliest_Start_Date__c = Date.Today().addDays(-7);
        lstpub.add(pub2);
        //insert lstPub;
        
        List<Product_Publication__c> lstProdPub = new List<Product_Publication__c>();
        Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
        prodPub.Publication_Code__c = pub.id;
        prodPub.ZProduct__c = zProductNP.Id;
        lstProdPub.add(prodPub);
        Product_Publication__c prodPubMag = TestDataFactory.createProductPublication(1)[0];
        prodPubMag.Publication_Code__c = pub2.id;
        prodPubMag.ZProduct__c = zProductMag.Id;
        lstProdPub.add(prodPubMag);
        insert lstProdPub;
        
        List<Product_Publication__c> lstProdPub2 = new List<Product_Publication__c>();
        lstProdPub[0] = prodPub;
        lstProdPub[1] = prodPubMag;
        
        //Package Item
        List<Package_Item__c> lstPkgItem = new List<Package_Item__c>();
        Package_Item__c pItemNP = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemNP.Package__c = pack.id;
        pItemNP.Product_Rate_Plan__c = prpNP.id;
        pItemNP.Name = 'Test Pack Item Newspaper';
        lstPkgItem.add(pItemNP);
        Package_Item__c pItemMag = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemMag.Package__c = pack.id;
        pItemMag.Product_Rate_Plan__c = prpMag.id;
        pItemMag.Name = 'Test Pack Item Magazine';
        lstPkgItem.add(pItemMag);
        insert lstPkgItem; 
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract_Period__c = '24';
        promo.Penalty_Charge__c = '200';
        promo.Promotion_Code__c = 'PromoCode';
        insert promo;
        
        Gift__c gift = new Gift__c();
        gift.Gift_Code__c = 'GiftCode';
        insert gift;
        
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
        promoGift.Promotion__c = promo.id;
        promoGift.Gift__c = gift.id;
        insert promoGift;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Name = 'Test Account';
        acc.Phone = '123-456';
        acc.AccountNumber = '3999999999';
        acc.Email__c = 'test@test.com';
        acc.Date_of_Birth__c = date.today();
        acc.Gender__c = 'Male';
        acc.Race__c = 'Chinese';
        acc.Language__c = 'Others';
        acc.Contact_Person__c = 'Contact Person';
        acc.Sub_Group__c = 'Freelist(MY)';
        insert acc;
        
        Account acctVen = TestDataFactory.createAccount(1, 'Vendor')[0];
        acctVen.NRIC__c = 'T1234567R';
        acctVen.Name = 'Vendor Account';
        acctVen.Phone = '123-456';
        acctVen.Email__c = 'test@test.com';
        acctVen.Date_of_Birth__c = date.today();
        acctVen.Gender__c = 'Male';
        acctVen.Race__c = 'Chinese';
        acctVen.Language__c = 'Others';
        acctVen.Contact_Person__c = 'Contact Person';
        acctVen.Sub_Group__c = 'Freelist(MY)';
        insert acctVen;
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        ctry.Code__c = 'Singapore';
        ctry.Zonal_Code__c = 'A';
        ctry.Name = 'SG';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123456';
        postal.House_Block_Number__c = 'HB';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='01';
        addressRec.Level_Number__c ='23';
        addressRec.Unit_Number__c = '45';
        addressRec.Country__c = ctry.id;
        addressRec.RecordTypeId = ConstantsSLB.getkeyid('Address_Local');
        insert addressRec; 
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'FName';
        con.LastName = 'LName';
        //con.NRIC__c = '123456';
        con.Passport__c = 'Passport Test';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        Zone__c zone = new Zone__c();
        zone.Zone_Name_External_Id__c = 'A';
        zone.Name = 'A';
        insert zone;
        
        List<Zone_Product__c> lstzoneProd = new List<Zone_Product__c>();
        
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Product__c = zProductNP.Id;
        zoneProd.Postage_Charge__c = 100;
        zoneProd.Effective_Start_Date__c = Date.Today();
        zoneProd.Zone__c = zone.id;
        lstzoneProd.add(zoneProd);
        Zone_Product__c zoneProdMag = new Zone_Product__c();
        zoneProdMag.Product__c = zProductMag.Id;
        zoneProdMag.Postage_Charge__c = 100;
        zoneProdMag.Effective_Start_Date__c = Date.Today();
        zoneProdMag.Zone__c = zone.id;
        lstzoneProd.add(zoneProdMag);
        insert lstzoneProd;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__AccountNumber__c = 'BA999999';
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Start';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Paypal';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Billing_Contact__c = con.id;
        order.Case_Record_Type__c = 'Start Subscription';
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
        
        Vendor_Allocation__c venAcc = new Vendor_Allocation__c();
        venAcc.Vendor_Account__c = acctVen.id;
        venAcc.SingPost_Address__c = postal.Id;
        venAcc.Allocated__c = true;
        venAcc.Effective_Start_Date__c = Date.Today().addDays(-5);
        venAcc.Effective_End_Date__c = Date.Today().addDays(30);
        insert venAcc;
        
        
        //request.subscriberAccount
        AccountWrapper acctWrap = new AccountWrapper();
        acctWrap.accountName = '';
        acctWrap.accountNumber = '';
        acctWrap.recordType = 'Direct Individual';
        
        //request.contacts
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = 'HB';
        addWrap.levelNumber = '50';
        addWrap.unitNumber = '1234';
        addWrap.postalCode = '123456';
        addWrap.streetName = 'Test Street';
        addWrap.buildingName = '';
        addWrap.country = 'Singapore';
        addWrap.singpostAddressType = 'H';  
        addWrap.Address1 = 'ADDRESS 1';
        addWrap.Address2 = 'ADDRESS 2';
        addWrap.Address3 = 'ADDRESS 3';
        addWrap.Address4 = 'ADDRESS 4';
        
        ContactWrapper contWrap = new ContactWrapper();
        contWrap.contactId = '';
        contWrap.salutation = 'Mr.';
        contWrap.firstName = 'test';
        contWrap.lastName = 'class';
        contWrap.nric = 'G1314243K';
        contWrap.passport = 'K456978';
        contWrap.billingIndicator = 'Y';
        contWrap.recipientIndicator = 'Y';
        contWrap.homeNumber = '67586979';
        contWrap.mobileNumber1 = '96320193';
        contWrap.emailAddress1 = 'test@test.com';       
        contWrap.address = addWrap;
        
        List<ContactWrapper> lstContWrap = new List<ContactWrapper>();
        lstContWrap.add(contWrap);
        
        //request.order
        List<String> lstGiftCode = new List<String>();
        lstGiftCode.add('GiftCode');
        
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();        
        oliWrap.promotioncode = 'PromoCode';
        oliWrap.packagecode = 'PkgCode';
        oliWrap.addonpackagecode = 'AddOnPkgCode'; 
        oliWrap.quantity = 1; //Integer
        oliWrap.startDate = String.valueOf(Date.Today().addDays(2)).Mid(5,2)+'/'+ String.valueOf(Date.Today().addDays(2)).Mid(8,2)+ '/'+String.valueOf(Date.Today().addDays(2)).Mid(0,4);
        oliWrap.giftCode = lstGiftCode; //List<String>
        oliWrap.contractenddate = String.valueOf(Date.Today().addDays(366)).Mid(5,2)+'/'+ String.valueOf(Date.Today().addDays(366)).Mid(8,2)+ '/'+String.valueOf(Date.Today().addDays(366)).Mid(0,4);

        
        List<OrderLineItemWrapper> lstOliWrap = new List<OrderLineItemWrapper>();
        lstOliWrap.add(oliWrap);
        
        
        
        OrderWrapper ordWrap = new OrderWrapper();
        ordWrap.billingAccountNumber = '';
        ordWrap.paymentMode = 'Cash';
        ordWrap.paymentMethodId = '';
        ordWrap.ReferenceId = '';
        ordWrap.ldapId = '2222222217';
        ordWrap.paypalbaID = '';
        ordWrap.paypalemail = '';
        ordWrap.orderLineItems = lstOliWrap; //List<OrderLineItemWrapper> 
        ordWrap.vendorConversion = 'Y';
        
        
        NewSubscriptionServiceRequest request = new NewSubscriptionServiceRequest();
        request.subscriberAccount = acctWrap; //AccountWrapper
        request.contacts = lstContWrap; //List<ContactWrapper>
        request.order = ordWrap;//OrderWrapper
        
        String jsonStr = JSON.serialize(request);
        NewSubscriptionService.NewSubscriptionServiceRequest paramRequest = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);

        String oliJsonStr = JSON.serialize(oliWrap);
        NewSubscriptionService.OrderLineItemWrapper oliWrapper = (NewSubscriptionService.OrderLineItemWrapper)JSON.deserialize(oliJsonStr, NewSubscriptionService.OrderLineItemWrapper.class);
        
        List<NewSubscriptionService.OrderLineItemWrapper> lstOliWrap2 = new List<NewSubscriptionService.OrderLineItemWrapper>();
        lstOliWrap2.add(oliWrapper);
        
        Set<String> prodFam = new Set<String>();
        prodFam.add('test');
        
        
        Test.StartTest();
        NewSubscriptionService.processRequest(paramRequest);
        //NewSubscriptionService.createOrderLineItems(lstOliWrap2,order,ordWrap.ldapId,con, null);
        Boolean testBool = NewSubscriptionService.isUniqueProductFamily(prodFam, 'accountNumber');
        Date earliest = NewSubscriptionService.getEarliestStartDate(lstProdPub);
        Boolean isBillValid = NewSubscriptionService.isBillingTypevalid('BA999999',lstOliWrap2);
        Test.StopTest();        
    }
    static testMethod void testCreateOliPositive3(){
        
        List<Package__c> lstPkg = new List<Package__c>();
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '12';
        pack.Package_Code__c = 'PkgCode';
        pack.Product_Family_Current_Package__c = 'MY';
        pack.Package_Sub_Type__c = '';
        pack.Subscription_Type__c = 'Termed';
        lstPkg.add(pack);
        
        Package__c addOnpack = TestDataFactory.createPackage(1)[0];
        addOnpack.Billing_Type__c = 'Full Prepaid';
        addOnpack.Package_Type__c = 'Add On';
        addOnpack.Subscription_Period__c = '12';
        addOnpack.Package_Code__c = 'AddOnPkgCode';
        addOnpack.Product_Family_Current_Package__c = 'addOn';
        addOnpack.Package_Sub_Type__c = '';
        addOnpack.Subscription_Type__c = 'Termed';
        lstPkg.add(addOnpack);
        
        insert lstPkg;
        
        //ZProduct
        List<zqu__ZProduct__c> lstZProd = new List<zqu__ZProduct__c>();
        zqu__ZProduct__c zProductNP = TestDataFactory.createZProduct(1)[0];
        zProductNP.ProductSubType__c = 'Newspaper';
        zProductNP.ProductPlatform__c = 'Print';
        zProductNP.zqu__ZuoraId__c = 'newspaperzProduct';
        lstZProd.add(zProductNP);
        
        zqu__ZProduct__c zProductMag = TestDataFactory.createZProduct(1)[0];
        zProductMag.ProductSubType__c = 'Magazine';
        zProductMag.ProductPlatform__c = 'Print';
        zProductMag.zqu__ZuoraId__c = 'MagazinezProduct';
        lstZProd.add(zProductMag);
        
        insert lstZProd;
        
        //Product Rate Plan
        List<zqu__ProductRatePlan__c> lstPRP = new List<zqu__ProductRatePlan__c>();
        zqu__ProductRatePlan__c prpNP = TestDataFactory.createProductRatePlan(1)[0];
        prpNP.zqu__ZProduct__c = zProductNP.Id;
        prpNP.RatePlanType__c= 'Bill Plan';
        prpNP.zqu__EffectiveStartDate__c= date.today();
        prpNP.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpNP.zqu__Deleted__c = false;
        prpNP.SubscriptionFrequency__c = '0';
        prpNP.zqu__ZuoraId__c = 'prpNewspaper';
        prpNP.BillingType__c = 'Full Prepaid';
        prpNP.BillingPeriod__c = '12';
        lstPRP.add(prpNP);
        
        zqu__ProductRatePlan__c prpMag = TestDataFactory.createProductRatePlan(1)[0];
        prpMag.zqu__ZProduct__c = zProductMag.Id;
        prpMag.RatePlanType__c= 'Bill Plan';
        prpMag.zqu__EffectiveStartDate__c= date.today();
        prpMag.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpMag.zqu__Deleted__c = false;
        prpMag.SubscriptionFrequency__c = '1';
        prpMag.zqu__ZuoraId__c = 'prpMagazine';
        prpMag.BillingType__c = 'Full Prepaid';
        prpMag.BillingPeriod__c = '12';
        lstPRP.add(prpMag);
        
        insert lstPRP;
        
        //Product Rate Plan Charge
        List<zqu__ProductRatePlanCharge__c> lstPRPCharge = new List<zqu__ProductRatePlanCharge__c>();
        zqu__ProductRatePlanCharge__c prpChargeNP =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeNP.Name = 'Product Rate Plan Charge';
        prpChargeNP.zqu__ProductRatePlan__c = prpNP.id;
        prpChargeNP.zqu__ZuoraId__c = 'prpChargeNewspaper';
        lstPRPCharge.add(prpChargeNP);
        zqu__ProductRatePlanCharge__c prpChargeMag =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeMag.Name = 'Product Rate Plan Charge';
        prpChargeMag.zqu__ProductRatePlan__c = prpMag.id;
        prpChargeMag.zqu__ZuoraId__c = 'prpChargeMagazine';
        lstPRPCharge.add(prpChargeMag);
        insert lstPRPCharge;
        
        List<Publication__c> lstpub = new List<Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
        pub.Earliest_Start_Date__c = Date.Today().addDays(-5);
        lstpub.add(pub);
        Publication__c pub2 = TestDataFactory.createPublication(1)[0];
        pub2.Direct_Sub_Delivery_Method__c = 'Vendor';
        pub2.Earliest_Start_Date__c = Date.Today().addDays(-7);
        lstpub.add(pub2);
        //insert lstPub;
        
        List<Product_Publication__c> lstProdPub = new List<Product_Publication__c>();
        Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
        prodPub.Publication_Code__c = pub.id;
        prodPub.ZProduct__c = zProductNP.Id;
        lstProdPub.add(prodPub);
        Product_Publication__c prodPubMag = TestDataFactory.createProductPublication(1)[0];
        prodPubMag.Publication_Code__c = pub2.id;
        prodPubMag.ZProduct__c = zProductMag.Id;
        lstProdPub.add(prodPubMag);
        insert lstProdPub;
        
        List<Product_Publication__c> lstProdPub2 = new List<Product_Publication__c>();
        lstProdPub[0] = prodPub;
        lstProdPub[1] = prodPubMag;
        
        //Package Item
        List<Package_Item__c> lstPkgItem = new List<Package_Item__c>();
        Package_Item__c pItemNP = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemNP.Package__c = pack.id;
        pItemNP.Product_Rate_Plan__c = prpNP.id;
        pItemNP.Name = 'Test Pack Item Newspaper';
        lstPkgItem.add(pItemNP);
        Package_Item__c pItemMag = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemMag.Package__c = pack.id;
        pItemMag.Product_Rate_Plan__c = prpMag.id;
        pItemMag.Name = 'Test Pack Item Magazine';
        lstPkgItem.add(pItemMag);
        insert lstPkgItem; 
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract_Period__c = '24';
        promo.Penalty_Charge__c = '200';
        promo.Promotion_Code__c = 'PromoCode';
        insert promo;
        
        Gift__c gift = new Gift__c();
        gift.Gift_Code__c = 'GiftCode';
        insert gift;
        
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
        promoGift.Promotion__c = promo.id;
        promoGift.Gift__c = gift.id;
        insert promoGift;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Name = 'Test Account';
        acc.Phone = '123-456';
        acc.Email__c = 'test@test.com';
        acc.Date_of_Birth__c = date.today();
        acc.Gender__c = 'Male';
        acc.AccountNumber = '3999999999';
        acc.Race__c = 'Chinese';
        acc.Language__c = 'Others';
        acc.Contact_Person__c = 'Contact Person';
        acc.Sub_Group__c = 'Freelist(MY)';
        insert acc;
        
        Account acctVen = TestDataFactory.createAccount(1, 'Vendor')[0];
        acctVen.NRIC__c = 'T1234567R';
        acctVen.Name = 'Vendor Account';
        acctVen.Phone = '123-456';
        acctVen.Email__c = 'test@test.com';
        acctVen.Date_of_Birth__c = date.today();
        acctVen.Gender__c = 'Male';
        acctVen.Race__c = 'Chinese';
        acctVen.Language__c = 'Others';
        acctVen.Contact_Person__c = 'Contact Person';
        acctVen.Sub_Group__c = 'Freelist(MY)';
        insert acctVen;
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        ctry.Code__c = 'Singapore';
        ctry.Zonal_Code__c = 'A';
        ctry.Name = 'SG';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123456';
        postal.House_Block_Number__c = 'HB';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='01';
        addressRec.Level_Number__c ='23';
        addressRec.Unit_Number__c = '45';
        addressRec.Country__c = ctry.id;
        addressRec.RecordTypeId = ConstantsSLB.getkeyid('Address_Local');
        insert addressRec; 
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'FName';
        con.LastName = 'LName';
        //con.NRIC__c = '123456';
        con.Passport__c = 'Passport Test';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        Zone__c zone = new Zone__c();
        zone.Zone_Name_External_Id__c = 'A';
        zone.Name = 'A';
        insert zone;
        
        List<Zone_Product__c> lstzoneProd = new List<Zone_Product__c>();
        
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Product__c = zProductNP.Id;
        zoneProd.Postage_Charge__c = 100;
        zoneProd.Effective_Start_Date__c = Date.Today();
        zoneProd.Zone__c = zone.id;
        lstzoneProd.add(zoneProd);
        Zone_Product__c zoneProdMag = new Zone_Product__c();
        zoneProdMag.Product__c = zProductMag.Id;
        zoneProdMag.Postage_Charge__c = 100;
        zoneProdMag.Effective_Start_Date__c = Date.Today();
        zoneProdMag.Zone__c = zone.id;
        lstzoneProd.add(zoneProdMag);
        insert lstzoneProd;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__AccountNumber__c = 'BA999999';
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Start';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Paypal';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Billing_Contact__c = con.id;
        order.Case_Record_Type__c = 'Start Subscription';
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
        
        Vendor_Allocation__c venAcc = new Vendor_Allocation__c();
        venAcc.Vendor_Account__c = acctVen.id;
        venAcc.SingPost_Address__c = postal.Id;
        venAcc.Allocated__c = true;
        venAcc.Effective_Start_Date__c = Date.Today().addDays(-5);
        venAcc.Effective_End_Date__c = Date.Today().addDays(30);
        insert venAcc;
        
        
        //request.subscriberAccount
        AccountWrapper acctWrap = new AccountWrapper();
        acctWrap.accountName = 'Test Account';
        acctWrap.accountNumber = '3999999999';
        acctWrap.recordType = 'Direct Corporate';
        
        //request.contacts
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = 'HB';
        addWrap.levelNumber = '50';
        addWrap.unitNumber = '1234';
        addWrap.postalCode = '123456';
        addWrap.streetName = 'Test Street';
        addWrap.buildingName = '';
        addWrap.country = 'SG';
        addWrap.singpostAddressType = 'H';  
        addWrap.Address1 = 'ADDRESS 1';
        addWrap.Address2 = 'ADDRESS 2';
        addWrap.Address3 = 'ADDRESS 3';
        addWrap.Address4 = 'ADDRESS 4';
        
        ContactWrapper contWrap = new ContactWrapper();
        contWrap.contactId = con.id;
        contWrap.salutation = 'Mr.';
        contWrap.firstName = 'test';
        contWrap.lastName = 'class';
        contWrap.nric = 'G1314243K';
        contWrap.passport = 'K456978';
        contWrap.billingIndicator = 'Y';
        contWrap.recipientIndicator = 'Y';
        contWrap.homeNumber = '67586979';
        contWrap.mobileNumber1 = '96320193';
        contWrap.emailAddress1 = 'test@test.com';       
        contWrap.address = addWrap;
        
        List<ContactWrapper> lstContWrap = new List<ContactWrapper>();
        lstContWrap.add(contWrap);
        
        //request.order
        List<String> lstGiftCode = new List<String>();
        lstGiftCode.add('GiftCode');
        
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();        
        oliWrap.promotioncode = 'PromoCode';
        oliWrap.packagecode = 'PkgCode';
        oliWrap.addonpackagecode = 'AddOnPkgCode'; 
        oliWrap.quantity = 1; //Integer
        oliWrap.startDate = String.valueOf(Date.Today().addDays(2)).Mid(5,2)+'/'+ String.valueOf(Date.Today().addDays(2)).Mid(8,2)+ '/'+String.valueOf(Date.Today().addDays(2)).Mid(0,4);
        oliWrap.giftCode = lstGiftCode; //List<String>
        oliWrap.contractenddate = String.valueOf(Date.Today().addDays(366)).Mid(5,2)+'/'+ String.valueOf(Date.Today().addDays(366)).Mid(8,2)+ '/'+String.valueOf(Date.Today().addDays(366)).Mid(0,4);
        
        List<OrderLineItemWrapper> lstOliWrap = new List<OrderLineItemWrapper>();
        lstOliWrap.add(oliWrap);
        
        
        
        OrderWrapper ordWrap = new OrderWrapper();
        ordWrap.billingAccountNumber = '';
        ordWrap.paymentMode = 'Cash';
        ordWrap.paymentMethodId = '';
        ordWrap.ReferenceId = '';
        ordWrap.ldapId = 'qqqqqq';
        ordWrap.paypalbaID = '';
        ordWrap.paypalemail = '';
        ordWrap.orderLineItems = lstOliWrap; //List<OrderLineItemWrapper> 
        ordWrap.vendorConversion = 'Y';
        
        
        NewSubscriptionServiceRequest request = new NewSubscriptionServiceRequest();
        request.subscriberAccount = acctWrap; //AccountWrapper
        request.contacts = lstContWrap; //List<ContactWrapper>
        request.order = ordWrap;//OrderWrapper
        
        String jsonStr = JSON.serialize(request);
        NewSubscriptionService.NewSubscriptionServiceRequest paramRequest = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);

        String oliJsonStr = JSON.serialize(oliWrap);
        NewSubscriptionService.OrderLineItemWrapper oliWrapper = (NewSubscriptionService.OrderLineItemWrapper)JSON.deserialize(oliJsonStr, NewSubscriptionService.OrderLineItemWrapper.class);
        
        List<NewSubscriptionService.OrderLineItemWrapper> lstOliWrap2 = new List<NewSubscriptionService.OrderLineItemWrapper>();
        lstOliWrap2.add(oliWrapper);
        
        Set<String> prodFam = new Set<String>();
        prodFam.add('test');
        
        
        Test.StartTest();
        NewSubscriptionService.processRequest(paramRequest);
        //NewSubscriptionService.createOrderLineItems(lstOliWrap2,order,ordWrap.ldapId,con, null);
        Boolean testBool = NewSubscriptionService.isUniqueProductFamily(prodFam, 'accountNumber');
        Date earliest = NewSubscriptionService.getEarliestStartDate(lstProdPub);
        Boolean isBillValid = NewSubscriptionService.isBillingTypevalid('BA999999',lstOliWrap2);
        Test.StopTest();        
    }
    static testMethod void testCreateOliPositive4(){
        
        List<Package__c> lstPkg = new List<Package__c>();
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '12';
        pack.Package_Code__c = 'PkgCode';
        pack.Product_Family_Current_Package__c = 'MY';
        pack.Package_Sub_Type__c = '';
        pack.Subscription_Type__c = 'Termed';
        lstPkg.add(pack);
        
        Package__c addOnpack = TestDataFactory.createPackage(1)[0];
        addOnpack.Billing_Type__c = 'Full Prepaid';
        addOnpack.Package_Type__c = 'Add On';
        addOnpack.Subscription_Period__c = '12';
        addOnpack.Package_Code__c = 'AddOnPkgCode';
        addOnpack.Product_Family_Current_Package__c = 'addOn';
        addOnpack.Package_Sub_Type__c = '';
        addOnpack.Subscription_Type__c = 'Termed';
        lstPkg.add(addOnpack);
        
        insert lstPkg;
        
        //ZProduct
        List<zqu__ZProduct__c> lstZProd = new List<zqu__ZProduct__c>();
        zqu__ZProduct__c zProductNP = TestDataFactory.createZProduct(1)[0];
        zProductNP.ProductSubType__c = 'Newspaper';
        zProductNP.ProductPlatform__c = 'Print';
        zProductNP.zqu__ZuoraId__c = 'newspaperzProduct';
        lstZProd.add(zProductNP);
        
        zqu__ZProduct__c zProductMag = TestDataFactory.createZProduct(1)[0];
        zProductMag.ProductSubType__c = 'Magazine';
        zProductMag.ProductPlatform__c = 'Print';
        zProductMag.zqu__ZuoraId__c = 'MagazinezProduct';
        lstZProd.add(zProductMag);
        
        insert lstZProd;
        
        //Product Rate Plan
        List<zqu__ProductRatePlan__c> lstPRP = new List<zqu__ProductRatePlan__c>();
        zqu__ProductRatePlan__c prpNP = TestDataFactory.createProductRatePlan(1)[0];
        prpNP.zqu__ZProduct__c = zProductNP.Id;
        prpNP.RatePlanType__c= 'Bill Plan';
        prpNP.zqu__EffectiveStartDate__c= date.today();
        prpNP.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpNP.zqu__Deleted__c = false;
        prpNP.SubscriptionFrequency__c = '0';
        prpNP.zqu__ZuoraId__c = 'prpNewspaper';
        prpNP.BillingType__c = 'Full Prepaid';
        prpNP.BillingPeriod__c = '12';
        lstPRP.add(prpNP);
        
        zqu__ProductRatePlan__c prpMag = TestDataFactory.createProductRatePlan(1)[0];
        prpMag.zqu__ZProduct__c = zProductMag.Id;
        prpMag.RatePlanType__c= 'Bill Plan';
        prpMag.zqu__EffectiveStartDate__c= date.today();
        prpMag.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpMag.zqu__Deleted__c = false;
        prpMag.SubscriptionFrequency__c = '1';
        prpMag.zqu__ZuoraId__c = 'prpMagazine';
        prpMag.BillingType__c = 'Full Prepaid';
        prpMag.BillingPeriod__c = '12';
        lstPRP.add(prpMag);
        
        insert lstPRP;
        
        //Product Rate Plan Charge
        List<zqu__ProductRatePlanCharge__c> lstPRPCharge = new List<zqu__ProductRatePlanCharge__c>();
        zqu__ProductRatePlanCharge__c prpChargeNP =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeNP.Name = 'Product Rate Plan Charge';
        prpChargeNP.zqu__ProductRatePlan__c = prpNP.id;
        prpChargeNP.zqu__ZuoraId__c = 'prpChargeNewspaper';
        lstPRPCharge.add(prpChargeNP);
        zqu__ProductRatePlanCharge__c prpChargeMag =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeMag.Name = 'Product Rate Plan Charge';
        prpChargeMag.zqu__ProductRatePlan__c = prpMag.id;
        prpChargeMag.zqu__ZuoraId__c = 'prpChargeMagazine';
        lstPRPCharge.add(prpChargeMag);
        insert lstPRPCharge;
        
        List<Publication__c> lstpub = new List<Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
        pub.Earliest_Start_Date__c = Date.Today().addDays(-5);
        lstpub.add(pub);
        Publication__c pub2 = TestDataFactory.createPublication(1)[0];
        pub2.Direct_Sub_Delivery_Method__c = 'Vendor';
        pub2.Earliest_Start_Date__c = Date.Today().addDays(-7);
        lstpub.add(pub2);
        //insert lstPub;
        
        List<Product_Publication__c> lstProdPub = new List<Product_Publication__c>();
        Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
        prodPub.Publication_Code__c = pub.id;
        prodPub.ZProduct__c = zProductNP.Id;
        lstProdPub.add(prodPub);
        Product_Publication__c prodPubMag = TestDataFactory.createProductPublication(1)[0];
        prodPubMag.Publication_Code__c = pub2.id;
        prodPubMag.ZProduct__c = zProductMag.Id;
        lstProdPub.add(prodPubMag);
        insert lstProdPub;
        
        List<Product_Publication__c> lstProdPub2 = new List<Product_Publication__c>();
        lstProdPub[0] = prodPub;
        lstProdPub[1] = prodPubMag;
        
        //Package Item
        List<Package_Item__c> lstPkgItem = new List<Package_Item__c>();
        Package_Item__c pItemNP = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemNP.Package__c = pack.id;
        pItemNP.Product_Rate_Plan__c = prpNP.id;
        pItemNP.Name = 'Test Pack Item Newspaper';
        lstPkgItem.add(pItemNP);
        Package_Item__c pItemMag = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemMag.Package__c = pack.id;
        pItemMag.Product_Rate_Plan__c = prpMag.id;
        pItemMag.Name = 'Test Pack Item Magazine';
        lstPkgItem.add(pItemMag);
        insert lstPkgItem; 
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract_Period__c = '24';
        promo.Penalty_Charge__c = '200';
        promo.Promotion_Code__c = 'PromoCode';
        insert promo;
        
        Gift__c gift = new Gift__c();
        gift.Gift_Code__c = 'GiftCode';
        insert gift;
        
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
        promoGift.Promotion__c = promo.id;
        promoGift.Gift__c = gift.id;
        insert promoGift;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Name = 'Test Account';
        acc.Phone = '123-456';
        acc.Email__c = 'test@test.com';
        acc.Date_of_Birth__c = date.today();
        acc.Gender__c = 'Male';
        acc.AccountNumber = '3999999999';
        acc.Race__c = 'Chinese';
        acc.Language__c = 'Others';
        acc.Contact_Person__c = 'Contact Person';
        acc.Sub_Group__c = 'Freelist(MY)';
        insert acc;
        
        Account acctVen = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acctVen.NRIC__c = 'T1234567R';
        acctVen.Name = 'Direct Corporate';
        acctVen.Phone = '123-456';
        acctVen.Email__c = 'test@test.com';
        acctVen.Date_of_Birth__c = date.today();
        acctVen.Gender__c = 'Male';
        acctVen.Race__c = 'Chinese';
        acctVen.Language__c = 'Others';
        acctVen.Contact_Person__c = 'Contact Person';
        acctVen.Sub_Group__c = 'Freelist(MY)';
        insert acctVen;
        String autoNum = acctVen.Account_Auto_Number__c;
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        ctry.Code__c = 'Singapore';
        ctry.Zonal_Code__c = 'A';
        ctry.Name = 'SG';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123456';
        postal.House_Block_Number__c = 'HB';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='01';
        addressRec.Level_Number__c ='23';
        addressRec.Unit_Number__c = '45';
        addressRec.Country__c = ctry.id;
        addressRec.RecordTypeId = ConstantsSLB.getkeyid('Address_Local');
        insert addressRec; 
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'FName';
        con.LastName = 'LName';
        //con.NRIC__c = '123456';
        con.Passport__c = 'Passport Test';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        Zone__c zone = new Zone__c();
        zone.Zone_Name_External_Id__c = 'A';
        zone.Name = 'A';
        insert zone;
        
        List<Zone_Product__c> lstzoneProd = new List<Zone_Product__c>();
        
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Product__c = zProductNP.Id;
        zoneProd.Postage_Charge__c = 100;
        zoneProd.Effective_Start_Date__c = Date.Today();
        zoneProd.Zone__c = zone.id;
        lstzoneProd.add(zoneProd);
        Zone_Product__c zoneProdMag = new Zone_Product__c();
        zoneProdMag.Product__c = zProductMag.Id;
        zoneProdMag.Postage_Charge__c = 100;
        zoneProdMag.Effective_Start_Date__c = Date.Today();
        zoneProdMag.Zone__c = zone.id;
        lstzoneProd.add(zoneProdMag);
        insert lstzoneProd;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__AccountNumber__c = 'BA999999';
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Start';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Paypal';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Billing_Contact__c = con.id;
        order.Case_Record_Type__c = 'Start Subscription';
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
        /*
        Vendor_Allocation__c venAcc = new Vendor_Allocation__c();
        venAcc.Vendor_Account__c = acctVen.id;
        venAcc.SingPost_Address__c = postal.Id;
        venAcc.Allocated__c = true;
        venAcc.Effective_Start_Date__c = Date.Today().addDays(-5);
        venAcc.Effective_End_Date__c = Date.Today().addDays(30);
        insert venAcc;
        
        */
        //request.subscriberAccount
        AccountWrapper acctWrap = new AccountWrapper();
        acctWrap.accountName = 'Test Account';
        acctWrap.accountNumber = 'autoNum';
        acctWrap.recordType = 'Direct Corporate';
        
        //request.contacts
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = 'HB';
        addWrap.levelNumber = '50';
        addWrap.unitNumber = '1234';
        addWrap.postalCode = '123456';
        addWrap.streetName = 'Test Street';
        addWrap.buildingName = '';
        addWrap.country = 'SG';
        addWrap.singpostAddressType = 'H';  
        addWrap.Address1 = 'ADDRESS 1';
        addWrap.Address2 = 'ADDRESS 2';
        addWrap.Address3 = 'ADDRESS 3';
        addWrap.Address4 = 'ADDRESS 4';
        
        ContactWrapper contWrap = new ContactWrapper();
        contWrap.contactId = con.id;
        contWrap.salutation = 'Mr.';
        contWrap.firstName = 'test';
        contWrap.lastName = 'class';
        contWrap.nric = 'G1314243K';
        contWrap.passport = 'K456978';
        contWrap.billingIndicator = 'Y';
        contWrap.recipientIndicator = 'Y';
        contWrap.homeNumber = '67586979';
        contWrap.mobileNumber1 = '96320193';
        contWrap.emailAddress1 = 'test@test.com';       
        contWrap.address = addWrap;
        
        List<ContactWrapper> lstContWrap = new List<ContactWrapper>();
        lstContWrap.add(contWrap);
        
        //request.order
        List<String> lstGiftCode = new List<String>();
        lstGiftCode.add('GiftCode');
        
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();        
        oliWrap.promotioncode = 'PromoCode';
        oliWrap.packagecode = 'PkgCode';
        oliWrap.addonpackagecode = 'AddOnPkgCode'; 
        oliWrap.quantity = 1; //Integer
        oliWrap.startDate = String.valueOf(Date.Today().addDays(2)).Mid(5,2)+'/'+ String.valueOf(Date.Today().addDays(2)).Mid(8,2)+ '/'+String.valueOf(Date.Today().addDays(2)).Mid(0,4);
        oliWrap.giftCode = lstGiftCode; //List<String>
        oliWrap.contractenddate = String.valueOf(Date.Today().addDays(366)).Mid(5,2)+'/'+ String.valueOf(Date.Today().addDays(366)).Mid(8,2)+ '/'+String.valueOf(Date.Today().addDays(366)).Mid(0,4);
        
        List<OrderLineItemWrapper> lstOliWrap = new List<OrderLineItemWrapper>();
        lstOliWrap.add(oliWrap);
        
        
        
        OrderWrapper ordWrap = new OrderWrapper();
        ordWrap.billingAccountNumber = 'BA999999';
        ordWrap.paymentMode = 'Cash';
        ordWrap.paymentMethodId = '';
        ordWrap.ReferenceId = '';
        ordWrap.ldapId = 'qqqqqq';
        ordWrap.paypalbaID = '';
        ordWrap.paypalemail = '';
        ordWrap.orderLineItems = lstOliWrap; //List<OrderLineItemWrapper> 
        ordWrap.vendorConversion = 'N';
        
        
        NewSubscriptionServiceRequest request = new NewSubscriptionServiceRequest();
        request.subscriberAccount = acctWrap; //AccountWrapper
        request.contacts = lstContWrap; //List<ContactWrapper>
        request.order = ordWrap;//OrderWrapper
        
        String jsonStr = JSON.serialize(request);
        NewSubscriptionService.NewSubscriptionServiceRequest paramRequest = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);

        String oliJsonStr = JSON.serialize(oliWrap);
        NewSubscriptionService.OrderLineItemWrapper oliWrapper = (NewSubscriptionService.OrderLineItemWrapper)JSON.deserialize(oliJsonStr, NewSubscriptionService.OrderLineItemWrapper.class);
        
        List<NewSubscriptionService.OrderLineItemWrapper> lstOliWrap2 = new List<NewSubscriptionService.OrderLineItemWrapper>();
        lstOliWrap2.add(oliWrapper);
        
        Set<String> prodFam = new Set<String>();
        prodFam.add('test');
        
        
        Test.StartTest();
        NewSubscriptionService.processRequest(paramRequest);
        //NewSubscriptionService.createOrderLineItems(lstOliWrap2,order,ordWrap.ldapId,con, null);
        Boolean testBool = NewSubscriptionService.isUniqueProductFamily(prodFam, 'accountNumber');
        Date earliest = NewSubscriptionService.getEarliestStartDate(lstProdPub);
        Boolean isBillValid = NewSubscriptionService.isBillingTypevalid('BA999999',lstOliWrap2);
        Test.StopTest();        
    }
    
    static testMethod void testCreateOliPositive5(){
        
        List<Package__c> lstPkg = new List<Package__c>();
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '12';
        pack.Package_Code__c = 'PkgCode';
        pack.Product_Family_Current_Package__c = 'MY';
        pack.Package_Sub_Type__c = '';
        pack.Subscription_Type__c = 'Termed';
        lstPkg.add(pack);
        
        Package__c addOnpack = TestDataFactory.createPackage(1)[0];
        addOnpack.Billing_Type__c = 'Full Prepaid';
        addOnpack.Package_Type__c = 'Add On';
        addOnpack.Subscription_Period__c = '12';
        addOnpack.Package_Code__c = 'AddOnPkgCode';
        addOnpack.Product_Family_Current_Package__c = 'addOn';
        addOnpack.Package_Sub_Type__c = '';
        addOnpack.Subscription_Type__c = 'Termed';
        lstPkg.add(addOnpack);
        
        insert lstPkg;
        
        //ZProduct
        List<zqu__ZProduct__c> lstZProd = new List<zqu__ZProduct__c>();
        zqu__ZProduct__c zProductNP = TestDataFactory.createZProduct(1)[0];
        zProductNP.ProductSubType__c = 'Newspaper';
        zProductNP.ProductPlatform__c = 'Print';
        zProductNP.zqu__ZuoraId__c = 'newspaperzProduct';
        lstZProd.add(zProductNP);
        
        zqu__ZProduct__c zProductMag = TestDataFactory.createZProduct(1)[0];
        zProductMag.ProductSubType__c = 'Magazine';
        zProductMag.ProductPlatform__c = 'Print';
        zProductMag.zqu__ZuoraId__c = 'MagazinezProduct';
        lstZProd.add(zProductMag);
        
        insert lstZProd;
        
        //Product Rate Plan
        List<zqu__ProductRatePlan__c> lstPRP = new List<zqu__ProductRatePlan__c>();
        zqu__ProductRatePlan__c prpNP = TestDataFactory.createProductRatePlan(1)[0];
        prpNP.zqu__ZProduct__c = zProductNP.Id;
        prpNP.RatePlanType__c= 'Bill Plan';
        prpNP.zqu__EffectiveStartDate__c= date.today();
        prpNP.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpNP.zqu__Deleted__c = false;
        prpNP.SubscriptionFrequency__c = '0';
        prpNP.zqu__ZuoraId__c = 'prpNewspaper';
        prpNP.BillingType__c = 'Full Prepaid';
        prpNP.BillingPeriod__c = '12';
        lstPRP.add(prpNP);
        
        zqu__ProductRatePlan__c prpMag = TestDataFactory.createProductRatePlan(1)[0];
        prpMag.zqu__ZProduct__c = zProductMag.Id;
        prpMag.RatePlanType__c= 'Bill Plan';
        prpMag.zqu__EffectiveStartDate__c= date.today();
        prpMag.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpMag.zqu__Deleted__c = false;
        prpMag.SubscriptionFrequency__c = '1';
        prpMag.zqu__ZuoraId__c = 'prpMagazine';
        prpMag.BillingType__c = 'Full Prepaid';
        prpMag.BillingPeriod__c = '12';
        lstPRP.add(prpMag);
        
        insert lstPRP;
        
        //Product Rate Plan Charge
        List<zqu__ProductRatePlanCharge__c> lstPRPCharge = new List<zqu__ProductRatePlanCharge__c>();
        zqu__ProductRatePlanCharge__c prpChargeNP =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeNP.Name = 'Product Rate Plan Charge';
        prpChargeNP.zqu__ProductRatePlan__c = prpNP.id;
        prpChargeNP.zqu__ZuoraId__c = 'prpChargeNewspaper';
        lstPRPCharge.add(prpChargeNP);
        zqu__ProductRatePlanCharge__c prpChargeMag =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeMag.Name = 'Product Rate Plan Charge';
        prpChargeMag.zqu__ProductRatePlan__c = prpMag.id;
        prpChargeMag.zqu__ZuoraId__c = 'prpChargeMagazine';
        lstPRPCharge.add(prpChargeMag);
        insert lstPRPCharge;
        
        List<Publication__c> lstpub = new List<Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
        pub.Earliest_Start_Date__c = Date.Today().addDays(-5);
        lstpub.add(pub);
        Publication__c pub2 = TestDataFactory.createPublication(1)[0];
        pub2.Direct_Sub_Delivery_Method__c = 'Vendor';
        pub2.Earliest_Start_Date__c = Date.Today().addDays(-7);
        lstpub.add(pub2);
        //insert lstPub;
        
        List<Product_Publication__c> lstProdPub = new List<Product_Publication__c>();
        Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
        prodPub.Publication_Code__c = pub.id;
        prodPub.ZProduct__c = zProductNP.Id;
        lstProdPub.add(prodPub);
        Product_Publication__c prodPubMag = TestDataFactory.createProductPublication(1)[0];
        prodPubMag.Publication_Code__c = pub2.id;
        prodPubMag.ZProduct__c = zProductMag.Id;
        lstProdPub.add(prodPubMag);
        insert lstProdPub;
        
        List<Product_Publication__c> lstProdPub2 = new List<Product_Publication__c>();
        lstProdPub[0] = prodPub;
        lstProdPub[1] = prodPubMag;
        
        //Package Item
        List<Package_Item__c> lstPkgItem = new List<Package_Item__c>();
        Package_Item__c pItemNP = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemNP.Package__c = pack.id;
        pItemNP.Product_Rate_Plan__c = prpNP.id;
        pItemNP.Name = 'Test Pack Item Newspaper';
        lstPkgItem.add(pItemNP);
        Package_Item__c pItemMag = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemMag.Package__c = pack.id;
        pItemMag.Product_Rate_Plan__c = prpMag.id;
        pItemMag.Name = 'Test Pack Item Magazine';
        lstPkgItem.add(pItemMag);
        insert lstPkgItem; 
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract_Period__c = '24';
        promo.Penalty_Charge__c = '200';
        promo.Promotion_Code__c = 'PromoCode';
        insert promo;
        
        Gift__c gift = new Gift__c();
        gift.Gift_Code__c = 'GiftCode';
        insert gift;
        
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
        promoGift.Promotion__c = promo.id;
        promoGift.Gift__c = gift.id;
        insert promoGift;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Name = 'Test Account';
        acc.Phone = '123-456';
        acc.AccountNumber = '3999999999';
        acc.Email__c = 'test@test.com';
        acc.Date_of_Birth__c = date.today();
        acc.Gender__c = 'Male';
        acc.Race__c = 'Chinese';
        acc.Language__c = 'Others';
        acc.Contact_Person__c = 'Contact Person';
        acc.Sub_Group__c = 'Freelist(MY)';
        insert acc;
        
        Account acctVen = TestDataFactory.createAccount(1, 'Vendor')[0];
        acctVen.NRIC__c = 'T1234567R';
        acctVen.Name = 'Vendor Account';
        acctVen.Phone = '123-456';
        acctVen.Email__c = 'test@test.com';
        acctVen.Date_of_Birth__c = date.today();
        acctVen.Gender__c = 'Male';
        acctVen.Race__c = 'Chinese';
        acctVen.Language__c = 'Others';
        acctVen.Contact_Person__c = 'Contact Person';
        acctVen.Sub_Group__c = 'Freelist(MY)';
        insert acctVen;
        
        Country__c ctry = TestDataFactory.createCountry(1)[0];
        ctry.Country_Name__c = 'Singapore';
        ctry.Code__c = 'Singapore';
        ctry.Zonal_Code__c = 'A';
        ctry.Name = 'SG';
        insert ctry;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123456';
        postal.House_Block_Number__c = 'HB';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='01';
        addressRec.Level_Number__c ='23';
        addressRec.Unit_Number__c = '45';
        addressRec.Country__c = ctry.id;
        addressRec.RecordTypeId = ConstantsSLB.getkeyid('Address_Local');
        insert addressRec; 
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'FName';
        con.LastName = 'LName';
        //con.NRIC__c = '123456';
        con.Passport__c = 'Passport Test';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        Zone__c zone = new Zone__c();
        zone.Zone_Name_External_Id__c = 'A';
        zone.Name = 'A';
        insert zone;
        
        List<Zone_Product__c> lstzoneProd = new List<Zone_Product__c>();
        
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Product__c = zProductNP.Id;
        zoneProd.Postage_Charge__c = 100;
        zoneProd.Effective_Start_Date__c = Date.Today();
        zoneProd.Zone__c = zone.id;
        lstzoneProd.add(zoneProd);
        Zone_Product__c zoneProdMag = new Zone_Product__c();
        zoneProdMag.Product__c = zProductMag.Id;
        zoneProdMag.Postage_Charge__c = 100;
        zoneProdMag.Effective_Start_Date__c = Date.Today();
        zoneProdMag.Zone__c = zone.id;
        lstzoneProd.add(zoneProdMag);
        insert lstzoneProd;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__AccountNumber__c = 'BA999999';
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Start';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Paypal';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Billing_Contact__c = con.id;
        order.Case_Record_Type__c = 'Start Subscription';
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
        
        Vendor_Allocation__c venAcc = new Vendor_Allocation__c();
        venAcc.Vendor_Account__c = acctVen.id;
        venAcc.SingPost_Address__c = postal.Id;
        venAcc.Allocated__c = true;
        venAcc.Effective_Start_Date__c = Date.Today().addDays(-5);
        venAcc.Effective_End_Date__c = Date.Today().addDays(30);
        insert venAcc;
        
        
        //request.subscriberAccount
        AccountWrapper acctWrap = new AccountWrapper();
        acctWrap.accountName = '';
        acctWrap.accountNumber = '';
        acctWrap.recordType = 'Direct Individual';
        
        //request.contacts
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = 'HB';
        addWrap.levelNumber = '50';
        addWrap.unitNumber = '1234';
        addWrap.postalCode = '123456';
        addWrap.streetName = 'Test Street';
        addWrap.buildingName = '';
        addWrap.country = 'Singapore';
        addWrap.singpostAddressType = 'H';  
        addWrap.Address1 = 'ADDRESS 1';
        addWrap.Address2 = 'ADDRESS 2';
        addWrap.Address3 = 'ADDRESS 3';
        addWrap.Address4 = 'ADDRESS 4';
        
        ContactWrapper contWrap = new ContactWrapper();
        contWrap.contactId = '';
        contWrap.salutation = 'Mr.';
        contWrap.firstName = 'test';
        contWrap.lastName = 'class';
        contWrap.nric = 'G1314243K';
        contWrap.passport = 'K456978';
        contWrap.billingIndicator = 'Y';
        contWrap.recipientIndicator = 'Y';
        contWrap.homeNumber = '67586979';
        contWrap.mobileNumber1 = '96320193';
        contWrap.emailAddress1 = 'test@test.com';       
        contWrap.address = addWrap;
        
        List<ContactWrapper> lstContWrap = new List<ContactWrapper>();
        lstContWrap.add(contWrap);
        
        //request.order
        List<String> lstGiftCode = new List<String>();
        lstGiftCode.add('GiftCode');
        
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();        
        oliWrap.promotioncode = 'PromoCode';
        oliWrap.packagecode = 'PkgCode';
        oliWrap.addonpackagecode = 'AddOnPkgCode'; 
        oliWrap.quantity = 1; //Integer
        oliWrap.startDate = String.valueOf(Date.Today().addDays(2)).Mid(5,2)+'/'+ String.valueOf(Date.Today().addDays(2)).Mid(8,2)+ '/'+String.valueOf(Date.Today().addDays(2)).Mid(0,4);
        oliWrap.giftCode = lstGiftCode; //List<String>
        oliWrap.contractenddate = String.valueOf(Date.Today().addDays(366)).Mid(5,2)+'/'+ String.valueOf(Date.Today().addDays(366)).Mid(8,2)+ '/'+String.valueOf(Date.Today().addDays(366)).Mid(0,4);

        
        List<OrderLineItemWrapper> lstOliWrap = new List<OrderLineItemWrapper>();
        lstOliWrap.add(oliWrap);
        
        
        
        OrderWrapper ordWrap = new OrderWrapper();
        ordWrap.billingAccountNumber = 'BA999999';
        ordWrap.paymentMode = 'Cash';
        ordWrap.paymentMethodId = '';
        ordWrap.ReferenceId = '';
        ordWrap.ldapId = '2222222217';
        ordWrap.paypalbaID = '';
        ordWrap.paypalemail = '';
        ordWrap.orderLineItems = lstOliWrap; //List<OrderLineItemWrapper> 
        ordWrap.vendorConversion = 'N';
        
        
        NewSubscriptionServiceRequest request = new NewSubscriptionServiceRequest();
        request.subscriberAccount = acctWrap; //AccountWrapper
        request.contacts = lstContWrap; //List<ContactWrapper>
        request.order = ordWrap;//OrderWrapper
        
        String jsonStr = JSON.serialize(request);
        NewSubscriptionService.NewSubscriptionServiceRequest paramRequest = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);

        String oliJsonStr = JSON.serialize(oliWrap);
        NewSubscriptionService.OrderLineItemWrapper oliWrapper = (NewSubscriptionService.OrderLineItemWrapper)JSON.deserialize(oliJsonStr, NewSubscriptionService.OrderLineItemWrapper.class);
        
        List<NewSubscriptionService.OrderLineItemWrapper> lstOliWrap2 = new List<NewSubscriptionService.OrderLineItemWrapper>();
        lstOliWrap2.add(oliWrapper);
        
        Set<String> prodFam = new Set<String>();
        prodFam.add('test');
        
        
        Test.StartTest();
        NewSubscriptionService.processRequest(paramRequest);
        //NewSubscriptionService.createOrderLineItems(lstOliWrap2,order,ordWrap.ldapId,con, null);
        Boolean testBool = NewSubscriptionService.isUniqueProductFamily(prodFam, 'accountNumber');
        Date earliest = NewSubscriptionService.getEarliestStartDate(lstProdPub);
        Boolean isBillValid = NewSubscriptionService.isBillingTypevalid('BA999999',lstOliWrap2);
        Test.StopTest();        
    }
    static testMethod void testCreateOliPositive6(){
        
        List<Package__c> lstPkg = new List<Package__c>();
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '12';
        pack.Package_Code__c = 'PkgCode';
        pack.Product_Family_Current_Package__c = 'MY';
        pack.Package_Sub_Type__c = '';
        pack.Subscription_Type__c = 'Termed';
        lstPkg.add(pack);
        
        Package__c addOnpack = TestDataFactory.createPackage(1)[0];
        addOnpack.Billing_Type__c = 'Full Prepaid';
        addOnpack.Package_Type__c = 'Add On';
        addOnpack.Subscription_Period__c = '12';
        addOnpack.Package_Code__c = 'AddOnPkgCode';
        addOnpack.Product_Family_Current_Package__c = 'addOn';
        addOnpack.Package_Sub_Type__c = '';
        addOnpack.Subscription_Type__c = 'Termed';
        lstPkg.add(addOnpack);
        
        insert lstPkg;
        
        //ZProduct
        List<zqu__ZProduct__c> lstZProd = new List<zqu__ZProduct__c>();
        zqu__ZProduct__c zProductNP = TestDataFactory.createZProduct(1)[0];
        zProductNP.ProductSubType__c = 'Newspaper';
        zProductNP.ProductPlatform__c = 'Print';
        zProductNP.zqu__ZuoraId__c = 'newspaperzProduct';
        lstZProd.add(zProductNP);
        
        zqu__ZProduct__c zProductMag = TestDataFactory.createZProduct(1)[0];
        zProductMag.ProductSubType__c = 'Magazine';
        zProductMag.ProductPlatform__c = 'Print';
        zProductMag.zqu__ZuoraId__c = 'MagazinezProduct';
        lstZProd.add(zProductMag);
        
        insert lstZProd;
        
        //Product Rate Plan
        List<zqu__ProductRatePlan__c> lstPRP = new List<zqu__ProductRatePlan__c>();
        zqu__ProductRatePlan__c prpNP = TestDataFactory.createProductRatePlan(1)[0];
        prpNP.zqu__ZProduct__c = zProductNP.Id;
        prpNP.RatePlanType__c= 'Bill Plan';
        prpNP.zqu__EffectiveStartDate__c= date.today();
        prpNP.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpNP.zqu__Deleted__c = false;
        prpNP.SubscriptionFrequency__c = '0';
        prpNP.zqu__ZuoraId__c = 'prpNewspaper';
        prpNP.BillingType__c = 'Full Prepaid';
        prpNP.BillingPeriod__c = '12';
        lstPRP.add(prpNP);
        
        zqu__ProductRatePlan__c prpMag = TestDataFactory.createProductRatePlan(1)[0];
        prpMag.zqu__ZProduct__c = zProductMag.Id;
        prpMag.RatePlanType__c= 'Bill Plan';
        prpMag.zqu__EffectiveStartDate__c= date.today();
        prpMag.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prpMag.zqu__Deleted__c = false;
        prpMag.SubscriptionFrequency__c = '1';
        prpMag.zqu__ZuoraId__c = 'prpMagazine';
        prpMag.BillingType__c = 'Full Prepaid';
        prpMag.BillingPeriod__c = '12';
        lstPRP.add(prpMag);
        
        insert lstPRP;
        
        //Product Rate Plan Charge
        List<zqu__ProductRatePlanCharge__c> lstPRPCharge = new List<zqu__ProductRatePlanCharge__c>();
        zqu__ProductRatePlanCharge__c prpChargeNP =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeNP.Name = 'Product Rate Plan Charge';
        prpChargeNP.zqu__ProductRatePlan__c = prpNP.id;
        prpChargeNP.zqu__ZuoraId__c = 'prpChargeNewspaper';
        lstPRPCharge.add(prpChargeNP);
        zqu__ProductRatePlanCharge__c prpChargeMag =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpChargeMag.Name = 'Product Rate Plan Charge';
        prpChargeMag.zqu__ProductRatePlan__c = prpMag.id;
        prpChargeMag.zqu__ZuoraId__c = 'prpChargeMagazine';
        lstPRPCharge.add(prpChargeMag);
        insert lstPRPCharge;
        
        List<Publication__c> lstpub = new List<Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
        pub.Earliest_Start_Date__c = Date.Today().addDays(-5);
        lstpub.add(pub);
        Publication__c pub2 = TestDataFactory.createPublication(1)[0];
        pub2.Direct_Sub_Delivery_Method__c = 'Vendor';
        pub2.Earliest_Start_Date__c = Date.Today().addDays(-7);
        lstpub.add(pub2);
        //insert lstPub;
        
        List<Product_Publication__c> lstProdPub = new List<Product_Publication__c>();
        Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
        prodPub.Publication_Code__c = pub.id;
        prodPub.ZProduct__c = zProductNP.Id;
        lstProdPub.add(prodPub);
        Product_Publication__c prodPubMag = TestDataFactory.createProductPublication(1)[0];
        prodPubMag.Publication_Code__c = pub2.id;
        prodPubMag.ZProduct__c = zProductMag.Id;
        lstProdPub.add(prodPubMag);
        insert lstProdPub;
        
        List<Product_Publication__c> lstProdPub2 = new List<Product_Publication__c>();
        lstProdPub[0] = prodPub;
        lstProdPub[1] = prodPubMag;
        
        //Package Item
        List<Package_Item__c> lstPkgItem = new List<Package_Item__c>();
        Package_Item__c pItemNP = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemNP.Package__c = pack.id;
        pItemNP.Product_Rate_Plan__c = prpNP.id;
        pItemNP.Name = 'Test Pack Item Newspaper';
        lstPkgItem.add(pItemNP);
        Package_Item__c pItemMag = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItemMag.Package__c = pack.id;
        pItemMag.Product_Rate_Plan__c = prpMag.id;
        pItemMag.Name = 'Test Pack Item Magazine';
        lstPkgItem.add(pItemMag);
        insert lstPkgItem; 
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0];
        promo.Contract_Period__c = '24';
        promo.Penalty_Charge__c = '200';
        promo.Promotion_Code__c = 'PromoCode';
        insert promo;
        
        Gift__c gift = new Gift__c();
        gift.Gift_Code__c = 'GiftCode';
        insert gift;
        
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
        promoGift.Promotion__c = promo.id;
        promoGift.Gift__c = gift.id;
        insert promoGift;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Name = 'Test Account';
        acc.Phone = '123-456';
        acc.AccountNumber = '3999999999';
        acc.Email__c = 'test@test.com';
        acc.Date_of_Birth__c = date.today();
        acc.Gender__c = 'Male';
        acc.Race__c = 'Chinese';
        acc.Language__c = 'Others';
        acc.Contact_Person__c = 'Contact Person';
        acc.Sub_Group__c = 'Freelist(MY)';
        insert acc;
        
        Account acctVen = TestDataFactory.createAccount(1, 'Vendor')[0];
        acctVen.NRIC__c = 'T1234567R';
        acctVen.Name = 'Vendor Account';
        acctVen.Phone = '123-456';
        acctVen.Email__c = 'test@test.com';
        acctVen.Date_of_Birth__c = date.today();
        acctVen.Gender__c = 'Male';
        acctVen.Race__c = 'Chinese';
        acctVen.Language__c = 'Others';
        acctVen.Contact_Person__c = 'Contact Person';
        acctVen.Sub_Group__c = 'Freelist(MY)';
        insert acctVen;
        Country__c ctry; 
        List<Country__c> CountryList = [Select ID,Code__c from Country__c where Code__c = 'SG'];
        if(CountryList.size() > 0){
            ctry = CountryList[0];
        }else{
            ctry = TestDataFactory.createCountry(1)[0];
            ctry.Country_Name__c = 'Singapore';
            ctry.Code__c = 'SG';
            ctry.Zonal_Code__c = 'A';
            ctry.Name = 'SG';
            insert ctry;
        }
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123456';
        postal.House_Block_Number__c = 'HB';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Building';
        postal.Street_Name__c = 'Street';
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='01';
        addressRec.Level_Number__c ='23';
        addressRec.Unit_Number__c = '45';
        addressRec.Country__c = ctry.id;
        addressRec.RecordTypeId = ConstantsSLB.getkeyid('Address_Local');
        insert addressRec; 
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.FirstName = 'FName';
        con.LastName = 'LName';
        //con.NRIC__c = '123456';
        con.Passport__c = 'Passport Test';
        con.HomePhone__c = '123 456';
        con.Mobile_Number__c = '123456';
        con.Email = 'test@test.com';
        insert con;
        
        Zone__c zone = new Zone__c();
        zone.Zone_Name_External_Id__c = 'A';
        zone.Name = 'A';
        insert zone;
        
        List<Zone_Product__c> lstzoneProd = new List<Zone_Product__c>();
        
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Product__c = zProductNP.Id;
        zoneProd.Postage_Charge__c = 100;
        zoneProd.Effective_Start_Date__c = Date.Today();
        zoneProd.Zone__c = zone.id;
        lstzoneProd.add(zoneProd);
        Zone_Product__c zoneProdMag = new Zone_Product__c();
        zoneProdMag.Product__c = zProductMag.Id;
        zoneProdMag.Postage_Charge__c = 100;
        zoneProdMag.Effective_Start_Date__c = Date.Today();
        zoneProdMag.Zone__c = zone.id;
        lstzoneProd.add(zoneProdMag);
        insert lstzoneProd;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Contact__c = con.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__AccountNumber__c = 'BA999999';
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Start';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Paypal';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Billing_Contact__c = con.id;
        order.Case_Record_Type__c = 'Start Subscription';
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
        
        Vendor_Allocation__c venAcc = new Vendor_Allocation__c();
        venAcc.Vendor_Account__c = acctVen.id;
        venAcc.SingPost_Address__c = postal.Id;
        venAcc.Allocated__c = true;
        venAcc.Effective_Start_Date__c = Date.Today().addDays(-5);
        venAcc.Effective_End_Date__c = Date.Today().addDays(30);
        insert venAcc;
        
        
        //request.subscriberAccount
        AccountWrapper acctWrap = new AccountWrapper();
        acctWrap.accountName = '';
        acctWrap.accountNumber = '';
        acctWrap.recordType = 'Direct Individual';
        
        //request.contacts
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = 'HB';
        addWrap.levelNumber = '50';
        addWrap.unitNumber = '1234';
        addWrap.postalCode = '123456';
        addWrap.streetName = 'Test Street';
        addWrap.buildingName = '';
        addWrap.country = 'SG';
        addWrap.singpostAddressType = 'H';  
        addWrap.Address1 = 'ADDRESS 1';
        addWrap.Address2 = 'ADDRESS 2';
        addWrap.Address3 = 'ADDRESS 3';
        addWrap.Address4 = 'ADDRESS 4';
        
        ContactWrapper contWrap = new ContactWrapper();
        contWrap.contactId = '';
        contWrap.salutation = 'Mr.';
        contWrap.firstName = 'test';
        contWrap.lastName = 'class';
        contWrap.nric = 'G1314243K';
        contWrap.passport = 'K456978';
        contWrap.billingIndicator = 'Y';
        contWrap.recipientIndicator = 'Y';
        contWrap.homeNumber = '67586979';
        contWrap.mobileNumber1 = '96320193';
        contWrap.emailAddress1 = 'test@test.com';       
        contWrap.address = addWrap;
        
        List<ContactWrapper> lstContWrap = new List<ContactWrapper>();
        lstContWrap.add(contWrap);
        
        //request.order
        List<String> lstGiftCode = new List<String>();
        lstGiftCode.add('GiftCode');
        
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();        
        oliWrap.promotioncode = 'PromoCode';
        oliWrap.packagecode = 'PkgCode';
        oliWrap.addonpackagecode = 'AddOnPkgCode'; 
        oliWrap.quantity = 1; //Integer
        oliWrap.startDate = String.valueOf(Date.Today().addDays(2)).Mid(5,2)+'/'+ String.valueOf(Date.Today().addDays(2)).Mid(8,2)+ '/'+String.valueOf(Date.Today().addDays(2)).Mid(0,4);
        oliWrap.giftCode = lstGiftCode; //List<String>
        oliWrap.contractenddate = String.valueOf(Date.Today().addDays(366)).Mid(5,2)+'/'+ String.valueOf(Date.Today().addDays(366)).Mid(8,2)+ '/'+String.valueOf(Date.Today().addDays(366)).Mid(0,4);

        
        List<OrderLineItemWrapper> lstOliWrap = new List<OrderLineItemWrapper>();
        lstOliWrap.add(oliWrap);
        
        
        
        OrderWrapper ordWrap = new OrderWrapper();
        ordWrap.billingAccountNumber = '';
        ordWrap.paymentMode = 'Cash';
        ordWrap.paymentMethodId = '';
        ordWrap.ReferenceId = '';
        ordWrap.ldapId = '2222222217';
        ordWrap.paypalbaID = '';
        ordWrap.paypalemail = '';
        ordWrap.orderLineItems = lstOliWrap; //List<OrderLineItemWrapper> 
        ordWrap.vendorConversion = 'Y';
        
        
        NewSubscriptionServiceRequest request = new NewSubscriptionServiceRequest();
        request.subscriberAccount = acctWrap; //AccountWrapper
        request.contacts = lstContWrap; //List<ContactWrapper>
        request.order = ordWrap;//OrderWrapper
        
        String jsonStr = JSON.serialize(request);
        NewSubscriptionService.NewSubscriptionServiceRequest paramRequest = (NewSubscriptionService.NewSubscriptionServiceRequest)JSON.deserialize(jsonStr, NewSubscriptionService.NewSubscriptionServiceRequest.class);

        String oliJsonStr = JSON.serialize(oliWrap);
        NewSubscriptionService.OrderLineItemWrapper oliWrapper = (NewSubscriptionService.OrderLineItemWrapper)JSON.deserialize(oliJsonStr, NewSubscriptionService.OrderLineItemWrapper.class);
        
        List<NewSubscriptionService.OrderLineItemWrapper> lstOliWrap2 = new List<NewSubscriptionService.OrderLineItemWrapper>();
        lstOliWrap2.add(oliWrapper);
        
        Set<String> prodFam = new Set<String>();
        prodFam.add('test');
        
        
        Test.StartTest();
        NewSubscriptionService.processRequest(paramRequest);
        //NewSubscriptionService.createOrderLineItems(lstOliWrap2,order,ordWrap.ldapId,con, null);
        Boolean testBool = NewSubscriptionService.isUniqueProductFamily(prodFam, 'accountNumber');
        Date earliest = NewSubscriptionService.getEarliestStartDate(lstProdPub);
        Boolean isBillValid = NewSubscriptionService.isBillingTypevalid('BA999999',lstOliWrap2);
        Test.StopTest();        
    }
    

}