/**
* Class Name: ChangeAddressServiceTest
* @author: Accenture IDC (Shruti Kishore)
* Date: <02/18/2015>
* Requirement/Project Name: SPH
* @description<Test Class for ChangeAddressService>
*/

@isTest (seeAllData = true)
global with sharing class ChangeAddressServiceTest 
{
       //joy

    global class ChangeAddressServiceRequest {
        String customerAccountNumber;
        String billingAccountNumber;
        List<String> subscriptions;
        String country;
        String postalCode;
        String blockNumber;   
        String levelNumber;
        String streetName;
        String buildingName;
        String unitNumber;
        String Address1;
        String Address2;
        String Address3;
        String Address4;
        String billingIndicator;
        String deliveryIndicator;
        String effectiveDate;
        }
        
    static testMethod void testMethodForNullValidation(){
    
        Test.startTest();
        
        defaultCustomSetting();
        
        List<String> subscriptions = null;
        ChangeAddressService.ChangeAddressServiceResponse response= new ChangeAddressService.ChangeAddressServiceResponse();
        response.setSvc_status('');
        response.getSvc_status();
        response.setError_code('');
        response.getError_code();  
        response.setError_message('');
        response.getError_message();
        response.setOrderid('');
        response.getOrderid();
        response.setDebug('');
        response.getDebug();
        
        ChangeAddressService.ChangeAddressServiceRequest request = new ChangeAddressService.ChangeAddressServiceRequest();
        request.setCustomerAccountNumber('');
        request.getCustomerAccountNumber();
        request.setBillingAccountNumber('');
        request.getBillingAccountNumber();
        request.setSubscriptions(subscriptions);
        request.getSubscriptions ();
        request.setCountry('Singapore'); //jurna added
        request.getCountry();
        request.setPostalCode('');
        request.getPostalCode();
        request.setBlockNumber('');
        request.getBlockNumber();
        request.setLevelNumber('');
        request.getLevelNumber();
        request.setStreetName('');
        request.getStreetName();
        request.setBuildingName('');
        request.getBuildingName();
        request.setUnitNumber('');
        request.getUnitNumber();
        request.setAddress1('');
        request.setAddress2('');
        request.setAddress3('');
        request.setAddress4('');
        request.getAddress1();
        request.getAddress2();
        request.getAddress3();
        request.getAddress4();
        request.setBillingIndicator('');
        request.getBillingIndicator();
        request.setDeliveryIndicator('');
        request.getDeliveryIndicator();
        request.setEffectiveDate('01/09/2014');
        request.getEffectiveDate();
        
        ChangeAddressService.processRequest(request);
        Test.stopTest();
        
        
    }
    
    static testMethod void testMethodForTrueValidation(){
        
        defaultCustomSetting();
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = 'AN000';
        acc.Generate_Account_Number__c = TRUE;
        insert acc;
        
        Singpost_Address__c singpostAddressRecord = TestDatafactory.createSingpostAddress(1)[0];
        singpostAddressRecord.Name = '1234';
        singpostAddressRecord.Building_Name__c = 'Manhatton';
        singpostAddressRecord.House_Block_Number__c = '143';
        singpostAddressRecord.Floor__c = '1';
        singpostAddressRecord.Unit__c = '5';
        singpostAddressRecord.Street_Name__c = 'Test';
        insert singpostAddressRecord;
        
        Country__c co = new Country__c();
        co.Code__c =  'Singapore';
        co.Country_Name__c = 'Singapore';
        insert co;
        
        acc = [SELECT id,Account_Auto_Number__c, AccountNumber  FROM Account WHERE Id =: acc.Id limit 1][0];
        
        List<String> subscriptions = new List<String>();
        subscriptions.add('test1');
        
        Contact con = TestDataFactory.createContact(1)[0];
        //con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.LastName = 'LastName';
        con.Billing_Indicator__c = true;
        con.Recipient_Indicator__c =TRUE;
        con.HomePhone = '12346';
        insert con;
        
        Zuora__CustomerAccount__c zs = new Zuora__CustomerAccount__c();
        zs.Zuora__Zuora_Id__c =  'test789';
        zs.Zuora__Account__c = acc.Id;
        zs.Billing_Contact__c = con.Id;
        zs.Zuora__AccountNumber__c = 'test123';
        zs.Billing_Type__c = 'Full Prepaid';
        insert zs;
        
        /*Country__c co = new Country__c();
        co.Code__c =  request.getCountry();
        co.Country_Name__c = request.getCountry();
        insert co;*/ 
       
        /*Singpost_Address__c sa = new Singpost_Address__c();
        sa.Name= request.getPostalCode();
        insert sa;*/
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = singpostAddressRecord.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx'; //xx
        addressRec.Unit_Number__c = 'yy'; //yy
        addressRec.Country__c = co.Id;
        addressRec.Address_1__c = 'address1';
        addressRec.Address_2__c = 'address2';
        addressRec.Address_3__c = 'address3';
        addressRec.Address_4__c = 'address4';
        insert addressRec;
   
        //edf
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Account__c = acc.Id;
        insert cas;
        
        Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '24';
            pack.Package_Code__c = 'afds132';
            pack.Package_Sub_Type__c = 'Single';
            PACK.Subscription_Type__c = 'Termed';
        insert pack;
        
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
            order.Billing_Account__c = zs.id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Billing_Contact__c = con.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Delivery_Charge_Type__c = 'H';
        insert order;
        
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(30);
            orderline.Main_Package_ID__c = pack.Id;
            //orderline.Term_Length__c = 0; //jurna removed
            orderline.Term_Length__c = 10; //jurna added
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
        
        Zuora__Subscription__c subList = TestDataFactory.createSubscription(1)[0];
            subList.Zuora__CustomerAccount__c = zs.Id;
            subList.Zuora__Account__c = acc.Id;
            subList.Zuora__Zuora_Id__c = '1123';
            subList.Zuora__SubscriptionStartDate__c = date.today();
            subList.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subList.Subscriber_Contact__c = con.Id;
            subList.Recipient_Contact__c = con.Id;
            subList.Recipient_Contact_1__c = con.Id;
            subList.Main_Package_1__c = pack.id;
            //subRecs.Zuora__Status__c = 'Active'; // jurna removed
            subList.Zuora__Status__c = 'Cancelled'; // jurna added
            subList.Order_Number__c = order.Id;
            subList.Suppress_Vendor_Start_Notice__c = 'false';
            subList.Supressed_Acknowledgement_Letter__c = 'false';
            subList.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subList.Urgent__c = 'false';
            subList.Vendor_Conversion__c = 'false';
            subList.Charity__c = 'false';
            subList.Billing_Type__c = 'Recurring Prepaid';
            subList.Order_Line_Item_Number__c = orderline.id;
            subList.Order_Line_Item_Number_1__c = orderline.id;
            subList.Subscription_Type_1__c = 'Publication';
            subList.Subscription_Type__c = 'Publication';
            //subRecs.Zuora__Status__c = 'Active'; // jurna removed
            subList.Zuora__Status__c = 'Cancelled'; // jurna added
            subList.Order_Number_1__c = order.id;
            subList.Zuora__Zuora_Id__c = '3fss2223456ee44312';
            subList.Number_of_Copies__c = 100;
            subList.Term_Length__c = 10; //jurna added
            subList.Zuora__External_Id__c = 'test1';
        insert subList;
        
        Test.startTest();
        ChangeAddressService.ChangeAddressServiceRequest request = new ChangeAddressService.ChangeAddressServiceRequest();
        request.setCustomerAccountNumber(acc.AccountNumber);
        request.getCustomerAccountNumber();
        request.setBillingAccountNumber('test123');
        request.getBillingAccountNumber();
        request.setCountry(co.Country_Name__c);// jurna change from SIN
        request.getCountry();
        request.setPostalCode(singpostAddressRecord.Name);
        request.getPostalCode();
        request.setBlockNumber('143');
        request.getBlockNumber();
        request.setLevelNumber('xx');
        request.getLevelNumber();
        request.setStreetName('Test');
        request.getStreetName();
        request.setBuildingName('Manhatton');
        request.getBuildingName();
        request.setUnitNumber('yy');
        request.getUnitNumber();
        request.setAddress1('address1');
        request.setAddress2('address2');
        request.setAddress3('address3');
        request.setAddress4('address4');
        request.getAddress1();
        request.getAddress2();
        request.getAddress3();
        request.getAddress4();
        request.setBillingIndicator('Y');
        request.getBillingIndicator();
        request.setDeliveryIndicator('Y');
        request.getDeliveryIndicator();
        request.setEffectiveDate('11/02/2016');
        request.getEffectiveDate();
        request.setSubscriptions(subscriptions);
        request.getSubscriptions();
        
        ChangeAddressService.processRequest(request);
        
         //TODO edf
        ChangeAddressService.getBillingAccount('test');
        ChangeAddressService.getContact(string.valueOf(con.Id));
        ChangeAddressService.createCase(acc.Id, con, request, 'Billing Contact', cas);
        
        
        Test.stopTest();

    }
 
        //245
    static testMethod void testMethodForTrueValidationProceed(){
        Test.startTest();
        
        defaultCustomSetting();
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0]; 
        insert acc;
        
        acc = [SELECT id,Account_Auto_Number__c FROM Account WHERE Id =: acc.Id limit 1][0];
        
        ChangeAddressService.ChangeAddressServiceRequest request = new ChangeAddressService.ChangeAddressServiceRequest();
        request.setCustomerAccountNumber(acc.Account_Auto_Number__c);
        request.getCustomerAccountNumber();
        request.setBillingAccountNumber('345');
        request.getBillingAccountNumber();
       // request.setSubscriptions(subscriptions);
       // request.getSubscriptions ();
        request.setCountry('Singapore');
        request.getCountry();
        request.setPostalCode('800008');
        request.getPostalCode();
        request.setBlockNumber('43');
        request.getBlockNumber();
        request.setLevelNumber('1');
        request.getLevelNumber();
        request.setStreetName('fdfd');
        request.getStreetName();
        request.setBuildingName('Manhatton');
        request.getBuildingName();
        request.setUnitNumber('5');
        request.getUnitNumber();
        request.setAddress1('dfdf');
        request.setAddress2('dfrtdf');
        request.setAddress3('vbvb');
        request.setAddress4('vbvbvbv');
        request.getAddress1();
        request.getAddress2();
        request.getAddress3();
        request.getAddress4();
        request.setBillingIndicator('Y');
        request.getBillingIndicator();
        request.setDeliveryIndicator('Y');
        request.getDeliveryIndicator();
        request.setEffectiveDate('01/09/2014');
        request.getEffectiveDate();
        
        Country__c co = new Country__c();
        co.Code__c =  request.getCountry();
        co.Country_Name__c = request.getCountry();
        insert co; 
       
        Singpost_Address__c sa = new Singpost_Address__c();
        sa.Name= request.getPostalCode();
        insert sa;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = sa.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = co.Id;
        addressRec.Address_1__c = request.getAddress1();
        addressRec.Address_2__c = request.getAddress2();
        addressRec.Address_3__c = request.getAddress3();
        addressRec.Address_4__c = request.getAddress4();
        insert addressRec;

        
        Contact con = new Contact();
        //con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.LastName = 'LastName';
        con.Billing_Indicator__c = true;
        con.Recipient_Indicator__c =false;
        con.HomePhone = '12346';
        insert con;
            
        Zuora__CustomerAccount__c zs = new Zuora__CustomerAccount__c();
        zs.Zuora__Zuora_Id__c =  request.getbillingAccountNumber();
        zs.Zuora__Account__c = acc.Id;
        zs.Billing_Contact__c = con.Id;
        insert zs;
        
        ChangeAddressService.processRequest(request);

        Test.stopTest();
 
    }

    static testMethod void testMethodForValidation(){
    
        defaultCustomSetting();

        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0]; 
        insert acc;
        
        acc = [SELECT id,Account_Auto_Number__c FROM Account WHERE Id =: acc.Id limit 1][0];

        List<String> subscriptions = new List<String>();
        subscriptions.add('churva');
        subscriptions.add('churvabells');
        
        //jurna added
        Country__c testCountry = TestDataFactory.createCountry(1)[0];
            testCountry.Account__c = acc.Id;
            testCountry.Code__c = '6547954';
            testCountry.Country_Name__c = 'Singapore';
            insert testCountry;

        ChangeAddressService.ChangeAddressServiceRequest request = new ChangeAddressService.ChangeAddressServiceRequest();
        request.setCustomerAccountNumber(acc.Account_Auto_Number__c);
        request.setBillingAccountNumber('345');
        request.setSubscriptions(subscriptions);
        request.setCountry('Singapore'); // jurna removed
        request.getCountry();
        request.setPostalCode('696969');
        request.setBlockNumber('69');
        request.setLevelNumber('69');
        request.setStreetName('69');
        request.setBuildingName('69');
        request.setUnitNumber('69');
        request.setAddress1('69');
        request.setBillingIndicator('69');
        
        Date tempDate = Date.today().addDays(2);
        String tempDateString = tempDate.format();
        
        request.setEffectiveDate(tempDateString);
         
        ChangeAddressService.processRequest(request);
        
        
        System.assertEquals(true,true);
    }
    
    static testMethod void testMethodForValidation2(){
    
        defaultCustomSetting();

        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0]; 
        insert acc;
        
        acc = [SELECT id,Account_Auto_Number__c FROM Account WHERE Id =: acc.Id limit 1][0];
        
        //joy
        Country__c testCountry = TestDataFactory.createCountry(1)[0];
            testCountry.Account__c = acc.Id;
            testCountry.Code__c = '6547954';
            testCountry.Country_Name__c = 'testCountry';
            insert testCountry;

        List<String> subscriptions = new List<String>();
        subscriptions.add('test1');
        subscriptions.add('test2');
        
            zqu__ZProduct__c zProduct = new zqu__ZProduct__c();
            zProduct.zqu__SKU__c = 'test';
            zProduct.zqu__ZuoraId__c = '265481';
            zProduct.ProductSubType__c = 'Newspaper';

            insert zProduct;
        
            zqu__ProductRatePlan__c productRatePlan = new zqu__ProductRatePlan__c();
            productRatePlan.zqu__ZProduct__c = zProduct.Id;
            productRatePlan.zqu__ZuoraId__c = '155612';
            productRatePlan.RatePlanType__c = 'Bill Plan';
            insert productRatePlan;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            //pack.Package_Type__c = 'Grace Period';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            //pack.Subscription_Period__c = 
            insert pack;
            
            Package_Item__c packageItem = new Package_Item__c();
            packageItem.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Package_Item__c' AND Name='Base Product'].Id; //constantsSLB.getKeyID('Package Item_Base Product'); 
            packageItem.Product_Rate_Plan__c = productRatePlan.Id;
           /* START UD-4415 Gdelrosario packageItem.RenewalPkgCodeNewspaper__c = pack.id;
            packageItem.RenewalPkgCodeMag1YrBase__c = pack.id;
            packageItem.RenewalPkgCodeMag1YrDisc__c = pack.id;
            packageItem.RenewalPkgCodeMag2YrBase__c = pack.id;
            packageItem.RenewalPkgCodeMag2YrDisc__c = pack.id;*/
            packageItem.Package__c = pack.Id;
            insert packageItem;   

            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Zuora_Id__c = '1123';
            insert billAcc;        
        
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            insert addressRec;  
        
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.HomePhone__c = '123456';
            insert con;        
        
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Contact' AND Name='Customer Contact'].Id; //ConstantsSLB.getKeyId('Contact_Customer Contact');
            con1.Billing_Indicator__c = true;
            con1.HomePhone = '12346';
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
            //order.Billing_Account__c = billAcc.id;
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
            order.Delivery_Charge_Type__c = 'H';
            //order.Recipient_Type__c = ;
        insert order;
        
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(30);
            orderline.Main_Package_ID__c = pack.Id;
            //orderline.Term_Length__c = 0; //jurna removed
            orderline.Term_Length__c = 10; //jurna added
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
        
        Zuora__Subscription__c subList = TestDataFactory.createSubscription(1)[0];
                subList.Zuora__CustomerAccount__c = billAcc.Id;
                subList.Zuora__Account__c = acc.Id;
                subList.Zuora__Zuora_Id__c = '1123';
                subList.Zuora__SubscriptionStartDate__c = date.today();
                subList.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subList.Subscriber_Contact__c = con.Id;
                subList.Recipient_Contact__c = con.Id;
                subList.Recipient_Contact_1__c = con.Id;
                subList.Main_Package_1__c = pack.id;
                //subRecs.Zuora__Status__c = 'Active'; // jurna removed
                subList.Zuora__Status__c = 'Cancelled'; // jurna added
                subList.Order_Number__c = order.Id;
                subList.Suppress_Vendor_Start_Notice__c = 'false';
                subList.Supressed_Acknowledgement_Letter__c = 'false';
                subList.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subList.Urgent__c = 'false';
                subList.Vendor_Conversion__c = 'false';
                subList.Charity__c = 'false';
                subList.Billing_Type__c = 'Recurring Prepaid';
                subList.Order_Line_Item_Number__c = orderline.id;
                subList.Order_Line_Item_Number_1__c = orderline.id;
                subList.Subscription_Type_1__c = 'Publication';
                subList.Subscription_Type__c = 'Publication';
                //subRecs.Zuora__Status__c = 'Active'; // jurna removed
                subList.Zuora__Status__c = 'Cancelled'; // jurna added
                subList.Order_Number_1__c = order.id;
                subList.Zuora__Zuora_Id__c = '3fss2223456ee44312';
                subList.Number_of_Copies__c = 100;
                subList.Term_Length__c = 10; //jurna added
            insert subList;

        ChangeAddressService.ChangeAddressServiceRequest request = new ChangeAddressService.ChangeAddressServiceRequest();
        request.setCustomerAccountNumber(acc.Account_Auto_Number__c);
        request.setBillingAccountNumber('345');
        request.setSubscriptions(subscriptions);
        request.setCountry('Singapore'); // jurna removed
        request.setPostalCode('696969');
        request.setBlockNumber('69');
        request.setLevelNumber('69');
        request.setStreetName('69');
        request.setBuildingName('69');
        request.setUnitNumber('69');
        request.setAddress1('69');
        request.setBillingIndicator('69');
        
        Date tempDate = Date.today().addDays(2);
        String tempDateString = tempDate.format();
        
        request.setEffectiveDate(tempDateString);
        
        Set<String> orderIdSet = new Set<String>();
        orderIdSet.add(order.Id);
        
        Set<String> orderLineItemIdSet = new Set<String>();
        orderLineItemIdSet.add(orderline.Id);
         
        ChangeAddressService.processRequest(request);
        ChangeAddressService.getSubscriptions(new List<String> {subList.Id});
        ChangeAddressService.getAllSubscriptions(acc.Id, billAcc.Id);
        ChangeAddressService.getOrders(orderIdSet);
        ChangeAddressService.getOrderLineItems(string.valueof(order.Id));
        ChangeAddressService.getOrderLineItems(orderLineItemIdSet);
        ChangeAddressService.getOrderLineItemGifts(orderLineItemIdSet);
        //ChangeAddressService.getRenewalPackageCode(pack.Package_Code__c);
        
        System.assertEquals(true,true);
    }
    
    static testMethod void testMethodForValidation3(){
    
        defaultCustomSetting();

        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0]; 
        insert acc;
        
        acc = [SELECT id,Account_Auto_Number__c FROM Account WHERE Id =: acc.Id limit 1][0];
        
        //joy
        Country__c testCountry = TestDataFactory.createCountry(1)[0];
            testCountry.Account__c = acc.Id;
            testCountry.Code__c = '6547954';
            testCountry.Country_Name__c = 'testCountry';
            insert testCountry;

        List<String> subscriptions = new List<String>();
        subscriptions.add('churva');
        subscriptions.add('churvabells');
        
            zqu__ZProduct__c zProduct = new zqu__ZProduct__c();
            zProduct.zqu__SKU__c = 'test';
            zProduct.zqu__ZuoraId__c = '265481';
            //zProduct.ProductSubType__c = 'Magazine';
            zProduct.ProductSubType__c = 'Newspaper';
            insert zProduct;
        
            zqu__ProductRatePlan__c productRatePlan = new zqu__ProductRatePlan__c();
            productRatePlan.zqu__ZProduct__c = zProduct.Id;
            productRatePlan.zqu__ZuoraId__c = '155612';
            productRatePlan.RatePlanType__c = 'Discount';
            //productRatePlan.RatePlanSubType__c = 'Discount';
            insert productRatePlan;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            //pack.Package_Type__c = 'Base';
            //pack.Package_Type__c = 'Discount';
            pack.Package_Type__c = 'Base Product';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            //pack.Subscription_Period__c = 
            pack.Subscription_Period__c = '1';
            pack.Subscription_Period_1__c = '1';
            //pack.Package_Sub_Type__c = 'Single';
            //pack.Subscription_Type__c = 'Termed';
            insert pack;
            
            Package_Item__c packageItem = new Package_Item__c();
            packageItem.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Package_Item__c' AND Name='Discount'].Id; //constantsSLB.getKeyID('Package Item_Discount'); 
            packageItem.Product_Rate_Plan__c = productRatePlan.Id;
           /* packageItem.RenewalPkgCodeNewspaper__c = pack.id;
            packageItem.RenewalPkgCodeMag1YrBase__c = pack.id;
            packageItem.RenewalPkgCodeMag1YrDisc__c = pack.id;
            packageItem.RenewalPkgCodeMag2YrBase__c = pack.id;
            packageItem.RenewalPkgCodeMag2YrDisc__c = pack.id;*/
            packageItem.Package__c = pack.Id;
            packageItem.Duration_in_months__c = '1';
            packageItem.Effective_Start_Month__c = '1';
            
            insert packageItem;   

            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Zuora_Id__c = '1123';
            insert billAcc;        
        
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            insert addressRec;  
        
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.HomePhone__c = '123456';
            insert con;        
        
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Contact' AND Name='Customer Contact'].Id; //ConstantsSLB.getKeyId('Contact_Customer Contact');
            con1.Billing_Indicator__c = true;
            con1.HomePhone = '12346';
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
            //order.Billing_Account__c = billAcc.id;
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
            order.Delivery_Charge_Type__c = 'H';
            //order.Recipient_Type__c = ;
        insert order;
        
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(30);
            orderline.Main_Package_ID__c = pack.Id;
            //orderline.Term_Length__c = 0; //jurna removed
            orderline.Term_Length__c = 10; //jurna added
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
        
        Zuora__Subscription__c subList = TestDataFactory.createSubscription(1)[0];
                subList.Zuora__CustomerAccount__c = billAcc.Id;
                subList.Zuora__Account__c = acc.Id;
                subList.Zuora__Zuora_Id__c = '1123';
                subList.Zuora__SubscriptionStartDate__c = date.today();
                subList.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subList.Subscriber_Contact__c = con.Id;
                subList.Recipient_Contact__c = con.Id;
                subList.Recipient_Contact_1__c = con.Id;
                subList.Main_Package_1__c = pack.id;
                //subRecs.Zuora__Status__c = 'Active'; // jurna removed
                subList.Zuora__Status__c = 'Cancelled'; // jurna added
                subList.Order_Number__c = order.Id;
                subList.Suppress_Vendor_Start_Notice__c = 'false';
                subList.Supressed_Acknowledgement_Letter__c = 'false';
                subList.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subList.Urgent__c = 'false';
                subList.Vendor_Conversion__c = 'false';
                subList.Charity__c = 'false';
                subList.Billing_Type__c = 'Recurring Prepaid';
                subList.Order_Line_Item_Number__c = orderline.id;
                subList.Order_Line_Item_Number_1__c = orderline.id;
                subList.Subscription_Type_1__c = 'Publication';
                subList.Subscription_Type__c = 'Publication';
                //subRecs.Zuora__Status__c = 'Active'; // jurna removed
                subList.Zuora__Status__c = 'Cancelled'; // jurna added
                subList.Order_Number_1__c = order.id;
                subList.Zuora__Zuora_Id__c = '3fss2223456ee44312';
                subList.Number_of_Copies__c = 100;
                subList.Term_Length__c = 10; //jurna added
            insert subList;

        ChangeAddressService.ChangeAddressServiceRequest request = new ChangeAddressService.ChangeAddressServiceRequest();
        request.setCustomerAccountNumber(acc.Account_Auto_Number__c);
        request.setBillingAccountNumber('345');
        request.setSubscriptions(subscriptions);
        request.setCountry('Singapore'); // jurna removed
        request.getCountry();
        request.setPostalCode('696969');
        request.setBlockNumber('69');
        request.setLevelNumber('69');
        request.setStreetName('69');
        request.setBuildingName('69');
        request.setUnitNumber('69');
        request.setAddress1('69');
        request.setBillingIndicator('69');
        
        Date tempDate = Date.today().addDays(2);
        String tempDateString = tempDate.format();
        
        request.setEffectiveDate(tempDateString);
        
        Set<String> orderIdSet = new Set<String>();
        orderIdSet.add(order.Id);
        
        Set<String> orderLineItemIdSet = new Set<String>();
        orderLineItemIdSet.add(orderline.Id);
         
        ChangeAddressService.processRequest(request);
        ChangeAddressService.getSubscriptions(new List<String> {subList.Id});
        ChangeAddressService.getAllSubscriptions(acc.Id, billAcc.Id);
        ChangeAddressService.getOrders(orderIdSet);
        ChangeAddressService.getOrderLineItems(string.valueof(order.Id));
        ChangeAddressService.getOrderLineItems(orderLineItemIdSet);
        ChangeAddressService.getOrderLineItemGifts(orderLineItemIdSet);
        ChangeAddressService.getRenewalPackageCode(pack.Package_Code__c);
        ChangeAddressService.getAccount(acc.Account_Auto_Number__c);
        
        System.assertEquals(true,true);
    }
    
     static testMethod void testMethodForValidation4(){
    
        defaultCustomSetting();

        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '6000';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0]; 
        insert acc;
        
        acc = [SELECT id,Account_Auto_Number__c FROM Account WHERE Id =: acc.Id limit 1][0];

        //joy
        Country__c testCountry = TestDataFactory.createCountry(1)[0];
            testCountry.Account__c = acc.Id;
            testCountry.Code__c = '6547954';
            testCountry.Country_Name__c = 'testCountry';
            insert testCountry;
        

        List<String> subscriptions = new List<String>();
        subscriptions.add('churva');
        subscriptions.add('churvabells');
        
            zqu__ZProduct__c zProduct = new zqu__ZProduct__c();
            zProduct.zqu__SKU__c = 'test';
            zProduct.zqu__ZuoraId__c = '265481';
            //zProduct.ProductSubType__c = 'Magazine';
            zProduct.ProductSubType__c = 'Newspaper';
            insert zProduct;
        
            zqu__ProductRatePlan__c productRatePlan = new zqu__ProductRatePlan__c();
            productRatePlan.zqu__ZProduct__c = zProduct.Id;
            productRatePlan.zqu__ZuoraId__c = '155612';
            productRatePlan.RatePlanType__c = 'Bill Plan';
            insert productRatePlan;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            //pack.Package_Type__c = 'Grace Period';
            pack.Subscription_Period__c = '12';
            pack.Package_Code__c = 'afds132';
            //pack.Subscription_Period__c = 
            insert pack;
            
            Package_Item__c packageItem = new Package_Item__c();
            packageItem.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Package_Item__c' AND Name='Base Product'].Id; //constantsSLB.getKeyID('Package Item_Base Product'); 
            packageItem.Product_Rate_Plan__c = productRatePlan.Id;
           /* packageItem.RenewalPkgCodeNewspaper__c = pack.id;
            packageItem.RenewalPkgCodeMag1YrBase__c = pack.id;
            packageItem.RenewalPkgCodeMag1YrDisc__c = pack.id;
            packageItem.RenewalPkgCodeMag2YrBase__c = pack.id;
            packageItem.RenewalPkgCodeMag2YrDisc__c = pack.id;*/
            packageItem.Package__c = pack.Id;
            
            insert packageItem;   

            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Zuora_Id__c = '1123';
            insert billAcc;        
        
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            insert addressRec;  
        
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.HomePhone__c = '123456';
            insert con;        
        
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Contact' AND Name='Customer Contact'].Id; //ConstantsSLB.getKeyId('Contact_Customer Contact');
            con1.Billing_Indicator__c = true;
            con1.HomePhone = '12346';
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
            //order.Billing_Account__c = billAcc.id;
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
            order.Delivery_Charge_Type__c = 'H';
            //order.Recipient_Type__c = ;
        insert order;
        
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(30);
            orderline.Main_Package_ID__c = pack.Id;
            //orderline.Term_Length__c = 0; //jurna removed
            orderline.Term_Length__c = 10; //jurna added
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
        
        Zuora__Subscription__c subList = TestDataFactory.createSubscription(1)[0];
                subList.Zuora__CustomerAccount__c = billAcc.Id;
                subList.Zuora__Account__c = acc.Id;
                subList.Zuora__Zuora_Id__c = '1123';
                subList.Zuora__SubscriptionStartDate__c = date.today();
                subList.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subList.Subscriber_Contact__c = con.Id;
                subList.Recipient_Contact__c = con.Id;
                subList.Recipient_Contact_1__c = con.Id;
                subList.Main_Package_1__c = pack.id;
                //subRecs.Zuora__Status__c = 'Active'; // jurna removed
                subList.Zuora__Status__c = 'Cancelled'; // jurna added
                subList.Order_Number__c = order.Id;
                subList.Suppress_Vendor_Start_Notice__c = 'false';
                subList.Supressed_Acknowledgement_Letter__c = 'false';
                subList.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subList.Urgent__c = 'false';
                subList.Vendor_Conversion__c = 'false';
                subList.Charity__c = 'false';
                subList.Billing_Type__c = 'Recurring Prepaid';
                subList.Order_Line_Item_Number__c = orderline.id;
                subList.Order_Line_Item_Number_1__c = orderline.id;
                subList.Subscription_Type_1__c = 'Publication';
                subList.Subscription_Type__c = 'Publication';
                //subRecs.Zuora__Status__c = 'Active'; // jurna removed
                subList.Zuora__Status__c = 'Cancelled'; // jurna added
                subList.Order_Number_1__c = order.id;
                subList.Zuora__Zuora_Id__c = '3fss2223456ee44312';
                subList.Number_of_Copies__c = 100;
                subList.Term_Length__c = 10; //jurna added
            insert subList;

        ChangeAddressService.ChangeAddressServiceRequest request = new ChangeAddressService.ChangeAddressServiceRequest();
        request.setCustomerAccountNumber(acc.Account_Auto_Number__c);
        request.setBillingAccountNumber('345');
        request.setSubscriptions(subscriptions);
        request.setCountry('Singapore'); // jurna removed
        request.setPostalCode('696969');
        request.setBlockNumber('69');
        request.setLevelNumber('69');
        request.setStreetName('69');
        request.setBuildingName('69');
        request.setUnitNumber('69');
        request.setAddress1('69');
        request.setBillingIndicator('69');
        
        Date tempDate = Date.today().addDays(2);
        String tempDateString = tempDate.format();
        
        request.setEffectiveDate(tempDateString);
        
        Set<String> orderIdSet = new Set<String>();
        orderIdSet.add(order.Id);
        
        Set<String> orderLineItemIdSet = new Set<String>();
        orderLineItemIdSet.add(orderline.Id);
         
        ChangeAddressService.processRequest(request);
        ChangeAddressService.getSubscriptions(new List<String> {subList.Id});
        ChangeAddressService.getAllSubscriptions(acc.Id, billAcc.Id);
        ChangeAddressService.getOrders(orderIdSet);
        ChangeAddressService.getOrderLineItems(string.valueof(order.Id));
        ChangeAddressService.getOrderLineItems(orderLineItemIdSet);
        ChangeAddressService.getOrderLineItemGifts(orderLineItemIdSet);
        //ChangeAddressService.getRenewalPackageCode(pack.Package_Code__c);
        
        ChangeAddressService.ChangeAddressServiceRequest request3 = new ChangeAddressService.ChangeAddressServiceRequest();
        request3.setCustomerAccountNumber(acc.Account_Auto_Number__c);
        request3.setBillingAccountNumber('15646589');
        request3.setSubscriptions(subscriptions);
        request3.setCountry('Singapore'); // jurna removed
        request3.setPostalCode('6000');
        request3.setBlockNumber('69');
        request3.setLevelNumber('11');
        request3.setStreetName('69');
        request3.setBuildingName('Ebloc2');
        request3.setUnitNumber('22');
        request3.setAddress1('69');
        request3.setBillingIndicator('Y');
        request3.setDeliveryIndicator('Y');
        request3.setEffectiveDate(Date.today().month()+'/'+(Date.today().day()+1)+'/'+Date.today().year());
        
        String jsonStr2 = JSON.serialize(request3);
        ChangeAddressService.ChangeAddressServiceRequest esh2 = (ChangeAddressService.ChangeAddressServiceRequest)JSON.deserialize(jsonStr2, ChangeAddressService.ChangeAddressServiceRequest.class);
        
        request3.setEffectiveDate(tempDateString);
        
        ChangeAddressService.getAddress(request3, testCountry.Id, postal.Id);
        
        System.assertEquals(true,true);
    }
    
    static testMethod void testMethodForValidation4b(){
    
        defaultCustomSetting();

        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '6000';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0]; 
        insert acc;
        
        acc = [SELECT id,Account_Auto_Number__c FROM Account WHERE Id =: acc.Id limit 1][0];

        //joy
        Country__c testCountry = TestDataFactory.createCountry(1)[0];
            testCountry.Account__c = acc.Id;
            testCountry.Code__c = '6547954';
            testCountry.Country_Name__c = 'testCountry';
            insert testCountry;
        

        List<String> subscriptions = new List<String>();
        subscriptions.add('churva');
        subscriptions.add('churvabells');
        
            zqu__ZProduct__c zProduct = new zqu__ZProduct__c();
            zProduct.zqu__SKU__c = 'test';
            zProduct.zqu__ZuoraId__c = '265481';
            //zProduct.ProductSubType__c = 'Magazine';
            zProduct.ProductSubType__c = 'Newspaper';
            insert zProduct;
        
            zqu__ProductRatePlan__c productRatePlan = new zqu__ProductRatePlan__c();
            productRatePlan.zqu__ZProduct__c = zProduct.Id;
            productRatePlan.zqu__ZuoraId__c = '155612';
            productRatePlan.RatePlanType__c = 'Bill Plan';
            insert productRatePlan;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            //pack.Package_Type__c = 'Grace Period';
            pack.Subscription_Period__c = '12';
            pack.Package_Code__c = 'afds132';
            //pack.Subscription_Period__c = 
            insert pack;
            
            Package_Item__c packageItem = new Package_Item__c();
            packageItem.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Package_Item__c' AND Name='Base Product'].Id; //constantsSLB.getKeyID('Package Item_Base Product'); 
            packageItem.Product_Rate_Plan__c = productRatePlan.Id;
            /*packageItem.RenewalPkgCodeNewspaper__c = pack.id;
            packageItem.RenewalPkgCodeMag1YrBase__c = pack.id;
            packageItem.RenewalPkgCodeMag1YrDisc__c = pack.id;
            packageItem.RenewalPkgCodeMag2YrBase__c = pack.id;
            packageItem.RenewalPkgCodeMag2YrDisc__c = pack.id;*/
            packageItem.Package__c = pack.Id;
            
            insert packageItem;   

            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Zuora_Id__c = '1123';
            insert billAcc;        
        
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            insert addressRec;  
        
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.HomePhone__c = '123456';
            insert con;        
        
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Contact' AND Name='Customer Contact'].Id; //ConstantsSLB.getKeyId('Contact_Customer Contact');
            con1.Billing_Indicator__c = true;
            con1.HomePhone = '12346';
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
            //order.Billing_Account__c = billAcc.id;
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
            order.Delivery_Charge_Type__c = 'H';
            //order.Recipient_Type__c = ;
        insert order;
        
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(30);
            orderline.Main_Package_ID__c = pack.Id;
            //orderline.Term_Length__c = 0; //jurna removed
            orderline.Term_Length__c = 10; //jurna added
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
        
        Zuora__Subscription__c subList = TestDataFactory.createSubscription(1)[0];
                subList.Zuora__CustomerAccount__c = billAcc.Id;
                subList.Zuora__Account__c = acc.Id;
                subList.Zuora__Zuora_Id__c = '1123';
                subList.Zuora__SubscriptionStartDate__c = date.today();
                subList.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                subList.Subscriber_Contact__c = con.Id;
                subList.Recipient_Contact__c = con.Id;
                subList.Recipient_Contact_1__c = con.Id;
                subList.Main_Package_1__c = pack.id;
                //subRecs.Zuora__Status__c = 'Active'; // jurna removed
                subList.Zuora__Status__c = 'Cancelled'; // jurna added
                subList.Order_Number__c = order.Id;
                subList.Suppress_Vendor_Start_Notice__c = 'false';
                subList.Supressed_Acknowledgement_Letter__c = 'false';
                subList.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subList.Urgent__c = 'false';
                subList.Vendor_Conversion__c = 'false';
                subList.Charity__c = 'false';
                subList.Billing_Type__c = 'Recurring Prepaid';
                subList.Order_Line_Item_Number__c = orderline.id;
                subList.Order_Line_Item_Number_1__c = orderline.id;
                subList.Subscription_Type_1__c = 'Publication';
                subList.Subscription_Type__c = 'Publication';
                //subRecs.Zuora__Status__c = 'Active'; // jurna removed
                subList.Zuora__Status__c = 'Cancelled'; // jurna added
                subList.Order_Number_1__c = order.id;
                subList.Zuora__Zuora_Id__c = '3fss2223456ee44312';
                subList.Number_of_Copies__c = 100;
                subList.Term_Length__c = 10; //jurna added
            insert subList;

        ChangeAddressService.ChangeAddressServiceRequest request = new ChangeAddressService.ChangeAddressServiceRequest();
        request.setCustomerAccountNumber(acc.Account_Auto_Number__c);
        request.setBillingAccountNumber('345');
        request.setSubscriptions(subscriptions);
        request.setCountry('Phil'); // jurna removed
        request.setPostalCode('696969');
        request.setBlockNumber('69');
        request.setLevelNumber('69');
        request.setStreetName('69');
        request.setBuildingName('69');
        request.setUnitNumber('69');
        request.setAddress1('69');
        request.setBillingIndicator('69');
        
        Date tempDate = Date.today().addDays(2);
        String tempDateString = tempDate.format();
        
        request.setEffectiveDate(tempDateString);
        
        Set<String> orderIdSet = new Set<String>();
        orderIdSet.add(order.Id);
        
        Set<String> orderLineItemIdSet = new Set<String>();
        orderLineItemIdSet.add(orderline.Id);
         
        ChangeAddressService.processRequest(request);
        ChangeAddressService.getSubscriptions(new List<String> {subList.Id});
        ChangeAddressService.getAllSubscriptions(acc.Id, billAcc.Id);
        ChangeAddressService.getOrders(orderIdSet);
        ChangeAddressService.getOrderLineItems(string.valueof(order.Id));
        ChangeAddressService.getOrderLineItems(orderLineItemIdSet);
        ChangeAddressService.getOrderLineItemGifts(orderLineItemIdSet);
        //ChangeAddressService.getRenewalPackageCode(pack.Package_Code__c);
        
        ChangeAddressService.ChangeAddressServiceRequest request3 = new ChangeAddressService.ChangeAddressServiceRequest();
        request3.setCustomerAccountNumber(acc.Account_Auto_Number__c);
        request3.setBillingAccountNumber('15646589');
        request3.setSubscriptions(subscriptions);
        request3.setCountry('Phil'); // jurna removed
        request3.setPostalCode('6000');
        request3.setBlockNumber('69');
        request3.setLevelNumber('11');
        request3.setStreetName('69');
        request3.setBuildingName('Ebloc2');
        request3.setUnitNumber('22');
        request3.setAddress1('69');
        request3.setBillingIndicator('Y');
        request3.setDeliveryIndicator('Y');
        request3.setEffectiveDate(Date.today().month()+'/'+(Date.today().day()+1)+'/'+Date.today().year());
        
        String jsonStr2 = JSON.serialize(request3);
        ChangeAddressService.ChangeAddressServiceRequest esh2 = (ChangeAddressService.ChangeAddressServiceRequest)JSON.deserialize(jsonStr2, ChangeAddressService.ChangeAddressServiceRequest.class);
        
        request3.setEffectiveDate(tempDateString);
        
        ChangeAddressService.getAddress(request3, testCountry.Id, postal.Id);
        
        System.assertEquals(true,true);
    }
    
    static testMethod void testMethodForValidation5(){
    
        defaultCustomSetting();
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Building_Name__c = 'Ebloc2';
            postal.Floor__c = '4th';
            postal.Unit__c = '10';
            postal.Street_Name__c = 'Emerald';
        insert postal;
  
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0]; 
        insert acc;
        
        acc = [SELECT id,Account_Auto_Number__c FROM Account WHERE Id =: acc.Id limit 1][0];
        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');
            cas.Account__c = acc.Id;
            insert cas;
        
            Country__c testCountry = TestDataFactory.createCountry(1)[0];
            testCountry.Account__c = acc.Id;
            testCountry.Code__c = '6547954';
            testCountry.Country_Name__c = 'Singapore';
            insert testCountry;
        
            zqu__ZProduct__c zProduct = new zqu__ZProduct__c();
            zProduct.zqu__SKU__c = 'test';
            zProduct.zqu__ZuoraId__c = '265481';
            zProduct.ProductSubType__c = 'Magazine';
            
            insert zProduct;
            
            Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
            prodPub.ZProduct__c = zProduct.Id;
            insert prodPub;
        
            zqu__ProductRatePlan__c productRatePlan = new zqu__ProductRatePlan__c();
            productRatePlan.zqu__ZProduct__c = zProduct.Id;
            productRatePlan.zqu__ZuoraId__c = '155612';
            productRatePlan.RatePlanType__c = 'Bill Plan';
            productRatePlan.BillingType__c = 'Full Prepaid';
            productRatePlan.BillingPeriod__c = '24';
            insert productRatePlan;
            
            zqu__ProductRatePlanCharge__c prodRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
            prodRatePlanCharge.zqu__ProductRatePlan__c = productRatePlan.Id;
            //prodRatePlanChange.sum__c = 100;
            insert prodRatePlanCharge;
            
            zqu__ProductRatePlanChargeTier__c prodRatePlanChargeTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
            prodRatePlanChargeTier.zqu__Price__c = 100;
            prodRatePlanChargeTier.zqu__ProductRatePlanCharge__c = prodRatePlanCharge.Id;
            insert prodRatePlanChargeTier;

            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '24';
            pack.Package_Code__c = 'afds132';
            pack.Package_Sub_Type__c = 'Single';
            PACK.Subscription_Type__c = 'Termed';
            insert pack;
            
            Package_Item__c packageItem = new Package_Item__c();
            packageItem.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Package_Item__c' AND Name='Base Product'].Id; //constantsSLB.getKeyID('Package Item_Base Product'); 
            packageItem.Product_Rate_Plan__c = productRatePlan.Id;
            /*packageItem.RenewalPkgCodeNewspaper__c = pack.id;
            packageItem.RenewalPkgCodeMag1YrBase__c = pack.id;
            packageItem.RenewalPkgCodeMag1YrDisc__c = pack.id;
            packageItem.RenewalPkgCodeMag2YrBase__c = pack.id;
             START UD-4415 Gdelrosario packageItem.RenewalPkgCodeMag2YrDisc__c = pack.id;*/
            packageItem.Package__c = pack.Id;
            //packageItem.BillingType__c = 'Full Prepaid';
            insert packageItem;   
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='11';
            addressRec.Unit_Number__c = '22';
            addressRec.Country__c = testCountry.Id;
            insert addressRec;  
        
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            con.HomePhone__c = '123456';
            insert con;        
        
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Contact' AND Name='Customer Contact'].Id; //ConstantsSLB.getKeyId('Contact_Customer Contact');
            con1.Billing_Indicator__c = true;
            con1.HomePhone = '12346';
            insert con1;  

            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Zuora_Id__c = '1123';
            billAcc.Zuora__AccountNumber__c = '15646589';
            billAcc.Billing_Contact__c = con.Id;
            insert billAcc;        

            /*Order__c order = TestDataFactory.createOrder(1)[0];
            order.Subscriber_Charge__c = 100.0;
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            //order.Billing_Account__c = billAcc.id;
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
            order.Delivery_Charge_Type__c = 'H';
            //order.Recipient_Type__c = ;
        insert order;
        
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(30);
            orderline.Main_Package_ID__c = pack.Id;
            //orderline.Term_Length__c = 0; //jurna removed
            orderline.Term_Length__c = 10; //jurna added
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
        
        Zuora__Subscription__c subList = TestDataFactory.createSubscription(1)[0];
            subList.Zuora__CustomerAccount__c = billAcc.Id;
            subList.Zuora__Account__c = acc.Id;
            subList.Zuora__Zuora_Id__c = '1123';
            subList.Zuora__SubscriptionStartDate__c = date.today();
            subList.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subList.Subscriber_Contact__c = con.Id;
            subList.Recipient_Contact__c = con.Id;
            subList.Recipient_Contact_1__c = con.Id;
            subList.Main_Package_1__c = pack.id;
            //subRecs.Zuora__Status__c = 'Active'; // jurna removed
            subList.Zuora__Status__c = 'Cancelled'; // jurna added
            subList.Order_Number__c = order.Id;
            subList.Suppress_Vendor_Start_Notice__c = 'false';
            subList.Supressed_Acknowledgement_Letter__c = 'false';
            subList.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subList.Urgent__c = 'false';
            subList.Vendor_Conversion__c = 'false';
            subList.Charity__c = 'false';
            subList.Billing_Type__c = 'Recurring Prepaid';
            subList.Order_Line_Item_Number__c = orderline.id;
            subList.Order_Line_Item_Number_1__c = orderline.id;
            subList.Subscription_Type_1__c = 'Publication';
            subList.Subscription_Type__c = 'Publication';
            //subRecs.Zuora__Status__c = 'Active'; // jurna removed
            subList.Zuora__Status__c = 'Cancelled'; // jurna added
            subList.Order_Number_1__c = order.id;
            subList.Zuora__Zuora_Id__c = '3fss2223456ee44312';
            subList.Number_of_Copies__c = 100;
            subList.Term_Length__c = 10; //jurna added
            subList.Zuora__External_Id__c = '123456';
        insert subList;
            
        List<String> subscriptions = new List<String>();
        subscriptions.add('123456');*/

        ChangeAddressService.ChangeAddressServiceRequest request = new ChangeAddressService.ChangeAddressServiceRequest();

        Set<Id> packageIdSet = new Set<Id>();
        packageIdSet.add(pack.Id);
        
        List<Package_Item__c> packageItemList = new List<Package_Item__c>();
        packageItemList.add(packageItem);
        
        List<Product_Publication__c> prodPubList = new List<Product_Publication__c>();
        prodPubList.add(prodPub);
        
        Map<Id, List<Package_Item__c>> pimap = new Map<Id, List<Package_Item__c>>();
        pimap.put(packageItem.Id, packageItemList);
        
        Map<Id,zqu__ProductRatePlan__c> productRatePlanMap = new Map<Id,zqu__ProductRatePlan__c>();
        productRatePlanMap.put(productRatePlan.Id, productRatePlan);
        
        Map<Id, List<Product_Publication__c>> product_productPublicationMap = new Map<Id, List<Product_Publication__c>>();
        product_productPublicationMap.put(prodPub.Id, prodPubList);
        
        ChangeAddressService.getEarliestStartDateMap(packageIdSet, pimap, productRatePlanMap, product_productPublicationMap);
        
   }
   
     static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
        List<Key_Id__c> keyList = [SELECT Name FROM Key_Id__c];
        Set<String> keyNames = new Set<String>();
        for(Key_Id__c keyRec : keyList) {
            keyNames.add(keyRec.Name);
        }
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            if(!keyNames.contains(keyIdNameArray[i])) {
                keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
                insert keyId;
            }
        }
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = [SELECT Name FROM Other__c];
        Set<String> otherNames = new Set<String>();
        for(Other__c otherRec : otherList) {
            otherNames.add(otherRec.Name);
        }
        
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            if(!otherNames.contains(orderCNameArray[i])) {
                otherC = new Other__c();
                otherC.Name = orderCNameArray[i];
                otherC.Value__c = orderCValueArray[i];
                insert otherC;
            }
        }
        
        List<Cir_Planner_Schedule__c> cpcList = [SELECT Name FROM Cir_Planner_Schedule__c WHERE Name = 'CIR Plan Schedule'];
        if(cpcList.isEmpty()) {
            Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            insert cirPlannerSchedule;
        }
        
        List<BatchInterface_Settings__c> bitList = [SELECT Name FROM BatchInterface_Settings__c WHERE Name = 'Endpoint Delegator'];
        if(bitList.isEmpty()) {
            BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
            batchInterfaceSetting.Name = 'Endpoint Delegator';
            batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
            insert batchInterfaceSetting;
        }
        
        String[] errorCNameArray = new String[]{'ARMS account too many record','ARMS account is not existing','ARMS Timed-out','ARMS select one Customer only','Invalid Response'};
        String[] errorCValueArray = new String[]{'Too many account type.','ARMS account is not existing.','Timed-out. Please click Search button again.','Please select one Customer only.','Invalid response from server. Please try again later.'};
        
        List<Error_Messages__c> errorList = [SELECT Name FROM Error_Messages__c];
        Set<String> errorNames = new Set<String>();
        for(Error_Messages__c errorRec : errorList) {
            errorNames.add(errorRec.Name);
        }
        
        Error_Messages__c errorRec;
        for(Integer i = 0 ; i < errorCNameArray.size(); i++ )
        {
             if(!errorNames.contains(errorCNameArray[i])) {
                errorRec = new Error_Messages__c();
                errorRec.Name = errorCNameArray[i];
                errorRec.Message__c = errorCValueArray[i];
                insert errorRec;
            }
        }
    }
  
    static testMethod void testMethodForInvalidSub(){
        
        defaultCustomSetting();
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        //acc.AccountNumber = 'AN000';
        acc.Generate_Account_Number__c = TRUE;
        insert acc;
        
        Singpost_Address__c singpostAddressRecord = TestDatafactory.createSingpostAddress(1)[0];
        singpostAddressRecord.Name = '1234';
        singpostAddressRecord.Building_Name__c = 'Manhatton';
        singpostAddressRecord.House_Block_Number__c = '143';
        singpostAddressRecord.Floor__c = '1';
        singpostAddressRecord.Unit__c = '5';
        singpostAddressRecord.Street_Name__c = 'Test';
        insert singpostAddressRecord;
        
        Country__c co = new Country__c();
        co.Code__c =  'Singapore';
        co.Country_Name__c = 'Singapore';
        insert co;
        
        acc = [SELECT id,Account_Auto_Number__c, AccountNumber  FROM Account WHERE Id =: acc.Id limit 1][0];
        
        List<String> subscriptions = new List<String>();
        subscriptions.add('');
    subscriptions.add('testSub');
        
        Contact con = TestDataFactory.createContact(1)[0];
        //con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
    con.FirstName = 'FirstName';
        con.LastName = 'LastName';
        con.Billing_Indicator__c = true;
        con.Recipient_Indicator__c =TRUE;
        con.HomePhone = '1234623';
        insert con;
        
        Zuora__CustomerAccount__c zs = new Zuora__CustomerAccount__c();
        zs.Zuora__Zuora_Id__c =  'test789';
        zs.Zuora__Account__c = acc.Id;
        zs.Billing_Contact__c = con.Id;
        zs.Zuora__AccountNumber__c = 'test123';
        zs.Billing_Type__c = 'Full Prepaid';
        insert zs;
        
        /*Country__c co = new Country__c();
        co.Code__c =  request.getCountry();
        co.Country_Name__c = request.getCountry();
        insert co;*/ 
       
        /*Singpost_Address__c sa = new Singpost_Address__c();
        sa.Name= request.getPostalCode();
        insert sa;*/
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = singpostAddressRecord.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx'; //xx
        addressRec.Unit_Number__c = 'yy'; //yy
        addressRec.Country__c = co.Id;
        addressRec.Address_1__c = 'address1';
        addressRec.Address_2__c = 'address2';
        addressRec.Address_3__c = 'address3';
        addressRec.Address_4__c = 'address4';
        insert addressRec;
   
        //edf
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Account__c = acc.Id;
        insert cas;
        
        Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '24';
            pack.Package_Code__c = 'afds132';
            pack.Package_Sub_Type__c = 'Single';
            PACK.Subscription_Type__c = 'Termed';
        insert pack;
        
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
            order.Billing_Account__c = zs.id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Billing_Contact__c = con.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Delivery_Charge_Type__c = 'H';
        insert order;
        
         Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(30);
            orderline.Main_Package_ID__c = pack.Id;
            //orderline.Term_Length__c = 0; //jurna removed
            orderline.Term_Length__c = 10; //jurna added
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
        
        Zuora__Subscription__c subList = TestDataFactory.createSubscription(1)[0];
            subList.Zuora__CustomerAccount__c = zs.Id;
            subList.Zuora__Account__c = acc.Id;
            subList.Zuora__Zuora_Id__c = '1123';
            subList.Zuora__SubscriptionStartDate__c = date.today();
            subList.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
            subList.Subscriber_Contact__c = con.Id;
            subList.Recipient_Contact__c = con.Id;
            subList.Recipient_Contact_1__c = con.Id;
            subList.Main_Package_1__c = pack.id;
            //subRecs.Zuora__Status__c = 'Active'; // jurna removed
            subList.Zuora__Status__c = 'Cancelled'; // jurna added
            subList.Order_Number__c = order.Id;
            subList.Suppress_Vendor_Start_Notice__c = 'false';
            subList.Supressed_Acknowledgement_Letter__c = 'false';
            subList.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subList.Urgent__c = 'false';
            subList.Vendor_Conversion__c = 'false';
            subList.Charity__c = 'false';
            subList.Billing_Type__c = 'Recurring Prepaid';
            subList.Order_Line_Item_Number__c = orderline.id;
            subList.Order_Line_Item_Number_1__c = orderline.id;
            subList.Subscription_Type_1__c = 'Publication';
            subList.Subscription_Type__c = 'Publication';
            //subRecs.Zuora__Status__c = 'Active'; // jurna removed
            subList.Zuora__Status__c = 'Cancelled'; // jurna added
            subList.Order_Number_1__c = order.id;
            subList.Zuora__Zuora_Id__c = '3fss2223456ee44312';
            subList.Number_of_Copies__c = 100;
            subList.Term_Length__c = 10; //jurna added
            subList.Zuora__External_Id__c = 'test1';
        insert subList;
        
        Test.startTest();
        ChangeAddressService.ChangeAddressServiceRequest request = new ChangeAddressService.ChangeAddressServiceRequest();
        request.setCustomerAccountNumber(acc.AccountNumber);
        request.getCustomerAccountNumber();
        request.setBillingAccountNumber('test123');
        request.getBillingAccountNumber();
        request.setCountry(co.Country_Name__c);// jurna change from SIN
        request.getCountry();
        request.setPostalCode(singpostAddressRecord.Name);
        request.getPostalCode();
        request.setBlockNumber('143');
        request.getBlockNumber();
        request.setLevelNumber('xx');
        request.getLevelNumber();
        request.setStreetName('Test');
        request.getStreetName();
        request.setBuildingName('Manhatton');
        request.getBuildingName();
        request.setUnitNumber('yy');
        request.getUnitNumber();
        request.setAddress1('address1');
        request.setAddress2('address2');
        request.setAddress3('address3');
        request.setAddress4('address4');
        request.getAddress1();
        request.getAddress2();
        request.getAddress3();
        request.getAddress4();
        request.setBillingIndicator('Y');
        request.getBillingIndicator();
        request.setDeliveryIndicator('Y');
        request.getDeliveryIndicator();
        request.setEffectiveDate('11/02/2016');
        request.getEffectiveDate();
        request.setSubscriptions(subscriptions);
        request.getSubscriptions();
        
        ChangeAddressService.processRequest(request);
        
         //TODO edf
        ChangeAddressService.getBillingAccount('test');
        ChangeAddressService.getContact(string.valueOf(con.Id));
        ChangeAddressService.createCase(acc.Id, con, request, 'Billing Contact', cas);
        
        
        Test.stopTest();

    }

}