@isTest

private class ChangeAddressService_Test{
    public class ChangeAddressServiceRequest {
        String customerAccountNumber = '1234';
        String billingAccountNumber = '567';
        List<String> subscriptions;
        String country ;
        String postalCode;
        String blockNumber = 'B';   
        String levelNumber = '4';
        String streetName = 'nagar';
        String buildingName;
        String unitNumber = '45';
        String Address1 ='dsds';
        String Address2 = 'fssds';
        String Address3 = 'skkdsd';
        String Address4 = 'sdsds';
        String billingIndicator = 'erf';
        String deliveryIndicator = 'dss';
        String effectiveDate ='2015-01-10';
    }
    private static void createCustomSettings(){
       Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
            insert dtl;
            
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        List<RecordType> recordTypeList = [Select Id, Name, SObjectType From RecordType];
        Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
        for(RecordType recordType: recordTypeList){
            recordTypeMap.put(recordType.SObjectType+recordType.Name, recordType);
        }
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Contact_Customer Contact';
        key.Type__c= 'Record Type';
        key.Id__c = recordTypeMap.get('ContactCustomer Contact').id;
        Key_Id__c key2 = new Key_Id__c();
        key2.Name = 'NEXT_RECIPIENT_NUMBER';
        key2.Id__c = '123457461';
        key2.Type__c = 'Number';
        Key_Id__c key3 = new Key_Id__c();
        key3.Name = 'Address_Local';
        key3.Id__c = recordTypeMap.get('Address__cLocal').id;
        key3.Type__c = 'Record Type';
        Key_Id__c key4 = new Key_Id__c();
        key4.Name = 'Account_Vendor Subscriber';
        key4.Id__c =  recordTypeMap.get('AccountVendor Subscriber').id;
        key4.Type__c = 'Record Type';
        Key_Id__c key5 = new Key_Id__c();
        key5.Name = 'Case_Change in Address';
        key5.Id__c =  recordTypeMap.get('CaseChange of Address/Vendor').id;
        key5.Type__c = 'Record Type';
        
        keyList.add(key);
        keyList.add(key2);
        keyList.add(key3);
        keyList.add(key4);
        keyList.add(key5);
        insert keyList;
        
        Cir_Planner_Schedule__c cps = new Cir_Planner_Schedule__c();
        cps.Mon_Fri_End_Time__c = datetime.newInstance(2014, 8, 19, 22, 0, 0);
        cps.Mon_Fri_Start_Time__c = datetime.newInstance(2014, 8, 19, 8, 0, 0);
        cps.Sat_PH_End_Time__c = datetime.newInstance(2014, 8, 18, 17, 0, 0);
        cps.Sat_PH_Start_Time__c = datetime.newInstance(2014, 8, 8, 8, 0, 0);
        cps.Sun_End_Time__c = datetime.newInstance(2014, 8, 18, 17, 0, 0);
        cps.Sun_Start_Time__c = datetime.newInstance(2014, 8, 18, 17, 0, 0);
        cps.Name = 'CIR Plan Schedule';
        insert cps;
    }
    static testmethod void myUnitTest(){
        createCustomSettings();
        
       // Map<String, SObject> sObjMap = TestDataFactory.createSubscriptionPackage20();
        Map<String, SObject> objectMap = new Map<String, SObject>(); 
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '800008';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        postal.Building_Name__c = 'Ebloc2';
        //insert postal;
        
        objectMap.put('Singpost_Address__c', postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        acc.Airline_Indicator__c = true;
        acc.AccountNumber = '01254782632';
        acc.Generate_Account_Number__c = true;
        //acc.Account_Auto_Number__c = '1';       
        objectMap.put('Account', acc);

        
        Country__c country = new Country__c();
        country.Name = 'ZZ';
        country.Code__c = 'ZZ';
        country.Country_Name__c = 'Singapore';
        //insert country;
        objectMap.put('Country__c', country);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        //insert pack;
        
        objectMap.put('Package__c', pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        //insert zProduct;
        
        objectMap.put('zqu__ZProduct__c', zProduct);
        
        insert objectMap.values();
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        objectMap.put('Package_Item__c', pItem);   
           
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = country.Id;
        addressRec.Address_1__c = 'Address 1';
        addressRec.Address_2__c = 'Address 2';
        addressRec.Address_3__c = 'Address 3';
        addressRec.Address_4__c = 'Address 4';
        insert addressRec;
        
        objectMap.put('Address__c', addressRec);   
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        objectMap.put('Recipient Contact', con);   
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        objectMap.put('Billing Contact', con1);   
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Billing_Contact__c = con1.id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        //Zuora__CustomerAccount__c dbacc = [SELECT  Zuora__AccountNumber__c FROM Zuora__CustomerAccount__c WHERE Zuora__AccountNumber__c != null LIMIT 1];
        billAcc.Zuora__AccountNumber__c = 'BA00009999';
        insert billAcc;
        
        objectMap.put('Zuora__CustomerAccount__c', billAcc);
        
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
        
        objectMap.put('Order__c', order);   
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        objectMap.put('Case', cas);   
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.newInstance(2017, 12, 2);
        orderline.Start_Date__c = date.today()+1;
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
        orderline.Fee_Override__c = False;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        objectMap.put('Order_Line_Item__c', orderline);  

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__CustomerAccount__c = billAcc.id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        subRecs.Zuora__External_Id__c = 'ID12345678';
        insert subRecs;
        objectMap.put('Zuora__Subscription__c', subRecs);  
        
       
        List<String> zSub = new List<String>();
        Zuora__Subscription__c zs = (Zuora__Subscription__c) objectMap.get('Zuora__Subscription__c');
        zs.Zuora__Zuora_Id__c = '3d3236481021237219dd9123';
        
        Test.startTest();
        
        insert zs;
        
        Country__c countryRec = (Country__c) objectMap.get('Country__c');
        countryRec.Name = 'Singapore';
        countryRec.Code__c = GlobalVariableClass.SINGAPORE_CODE;
        update countryRec;
        
        zSub.add(zs.Zuora__Zuora_Id__c);
        
        ChangeAddressServiceRequest ccMock = new ChangeAddressServiceRequest();
        ChangeAddressService.ChangeAddressServiceRequest ccAdd = new ChangeAddressService.ChangeAddressServiceRequest();
        
        //String customerAcctNumber = [SELECT AccountNumber FROM Account WHERE AccountNumber != null LIMIT 1].AccountNumber;
        //String customerAcctNumber = [Select Account_Auto_Number__c From Account Where Id =: objectMap.get('Account').id Limit 1].Account_Auto_Number__c;
        ccAdd.setCustomerAccountNumber(acc.Account_Auto_Number__c );
        ccMock.customerAccountNumber = acc.Account_Auto_Number__c;
        
        Zuora__CustomerAccount__c zc = (Zuora__CustomerAccount__c) objectMap.get('Zuora__CustomerAccount__c');
        ccAdd.setBillingAccountNumber(zc.Zuora__Zuora_Id__c);
        ccMock.billingAccountNumber = zc.Zuora__AccountNumber__c;
        
        ccMock.subscriptions[0] = subRecs.Zuora__External_Id__c;
        Country__c co = (Country__c) objectMap.get('Country__c');
        ccAdd.setCountry(co.Code__c);
        ccMock.country = co.Country_Name__c;
        
        Singpost_Address__c sa = (Singpost_Address__c) objectMap.get('Singpost_Address__c');
        ccAdd.setBlockNumber(sa.House_Block_Number__c);
        ccAdd.setPostalCode(sa.Name);
        ccMock.blockNumber = sa.House_Block_Number__c;
        ccMock.postalCode = sa.Name;
        ccMOck.buildingName = sa.Building_Name__c;
        
        Address__c add = (Address__c) objectMap.get('Address__c');
        ccAdd.setLevelNumber(add.Level_Number__c);
        ccAdd.setUnitNumber(add.Unit_Number__c);
        ccAdd.setAddress1(add.Address_1__c);
        ccMock.levelNumber = add.Level_Number__c;
        ccMock.address1 = add.Address_1__c;
        ccMock.address2 = add.Address_2__c;
        ccMock.address3 = add.Address_3__c;
        ccMock.address4 = add.Address_4__c;
        ccAdd.setAddress2(add.Address_2__c);
        ccAdd.setAddress3(add.Address_3__c);
        ccAdd.setAddress4(add.Address_4__c);
        ccMock.billingIndicator = 'Y';
        ccMock.deliveryIndicator = 'N';
        ccMock.subscriptions = zSub;
        ccMock.effectiveDate = '10/02/2015';
        ccAdd.setBillingIndicator('Y');
        ccAdd.setDeliveryIndicator('Y');
        ccAdd.setEffectiveDate('10/02/2015');
        ccAdd.setSubscriptions(zSub);
        ccAdd.getCustomerAccountNumber();
        ccAdd.getBillingAccountNumber();
        ccAdd.getCountry();
        ccAdd.getBlockNumber();
        ccAdd.getPostalCode();
        ccAdd.getLevelNumber();
        ccAdd.getUnitNumber();
        ccAdd.getStreetName();
        ccAdd.getBuildingName();
        ccAdd.getAddress1();
        ccAdd.getAddress2();
        ccAdd.getAddress3();
        ccAdd.getAddress4();
        ccAdd.getBillingIndicator();
        ccAdd.getDeliveryIndicator();
        ccAdd.getEffectiveDate();
        ccAdd.getSubscriptions();
        String jsonStr = JSON.serialize(ccMock);
        ccAdd = (ChangeAddressService.ChangeAddressServiceRequest) JSON.deserialize(jsonStr, ChangeAddressService.ChangeAddressServiceRequest.class);
        ChangeAddressService.ChangeAddressServiceResponse res =  ChangeAddressService.processRequest(ccAdd);
        ChangeAddressService.ChangeAddressServiceResponse response = new ChangeAddressService.ChangeAddressServiceResponse();
        res.getSvc_status();
        res.setSvc_status('Ok');
        res.getError_code();
        res.setError_code('300');
        res.getError_message();
        res.setError_message('message');
        res.getOrderid();
        res.setOrderid('222');
        res.getDebug();
        res.setDebug('Yes');
        
        Test.stopTest();
    }
    static testmethod void myUnitTest2(){
        createCustomSettings();
        //Map<String, SObject> sObjMap = TestDataFactory.createSubscriptionPackage20();
        Map<String, SObject> objectMap = new Map<String, SObject>(); 
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        //insert postal;
        
        objectMap.put('Singpost_Address__c', postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        
        //insert acc;
        
        objectMap.put('Account', acc);
        
        Country__c country = new Country__c();
        country.Name = 'ZZ';
        country.Code__c = 'ZZ';
        country.Country_Name__c = 'Singapore';
        
        objectMap.put('Country__c', country);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        //insert pack;
        
        objectMap.put('Package__c', pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        //insert zProduct;
        
        objectMap.put('zqu__ZProduct__c', zProduct);
        
        insert objectMap.values();
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        objectMap.put('Package_Item__c', pItem);   
           
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = country.Id;
        addressRec.Address_1__c = 'Address 1';
        addressRec.Address_2__c = 'Address 2';
        addressRec.Address_3__c = 'Address 3';
        addressRec.Address_4__c = 'Address 4';
        insert addressRec;
        
        objectMap.put('Address__c', addressRec);   
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        objectMap.put('Recipient Contact', con);   
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        objectMap.put('Billing Contact', con1);   
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Billing_Contact__c = con1.id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        insert billAcc;
        
        objectMap.put('Zuora__CustomerAccount__c', billAcc);
        
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
        
        objectMap.put('Order__c', order);   
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        objectMap.put('Case', cas);   
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.newInstance(2017, 12, 2);
        orderline.Start_Date__c = date.today()+1;
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
        orderline.Fee_Override__c = False;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        objectMap.put('Order_Line_Item__c', orderline);  

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__CustomerAccount__c = billAcc.id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        objectMap.put('Zuora__Subscription__c', subRecs);  
        
        List<String> zSub = new List<String>();
        Zuora__Subscription__c zs = (Zuora__Subscription__c) objectMap.get('Zuora__Subscription__c');
        zs.Zuora__Zuora_Id__c = '3d3236481021237219dd9123';
        Test.startTest();
        
        insert zs;
        
        zSub.add(zs.Zuora__Zuora_Id__c);
        ChangeAddressServiceRequest ccMock = new ChangeAddressServiceRequest();
        ChangeAddressService.ChangeAddressServiceRequest ccAdd = new ChangeAddressService.ChangeAddressServiceRequest();
        String customerAcctNumber = [Select Account_Auto_Number__c From Account Where Id =: objectMap.get('Account').id Limit 1].Account_Auto_Number__c;
        ccAdd.setCustomerAccountNumber(customerAcctNumber);
        ccMock.customerAccountNumber = customerAcctNumber;
        Zuora__CustomerAccount__c zc = (Zuora__CustomerAccount__c) objectMap.get('Zuora__CustomerAccount__c');
        ccAdd.setBillingAccountNumber(zc.Zuora__Zuora_Id__c);
        ccMock.billingAccountNumber = zc.Zuora__Zuora_Id__c;
        Country__c co = (Country__c) objectMap.get('Country__c');
        ccAdd.setCountry(co.Code__c);
        ccMock.country = co.Code__c;
        Singpost_Address__c sa = (Singpost_Address__c) objectMap.get('Singpost_Address__c');
        ccAdd.setBlockNumber(sa.House_Block_Number__c);
        ccAdd.setPostalCode(sa.Name);
        ccMock.blockNumber = sa.House_Block_Number__c;
        ccMock.postalCode = sa.Name;
        Address__c add = (Address__c) objectMap.get('Address__c');
        ccAdd.setLevelNumber(add.Level_Number__c);
        ccAdd.setUnitNumber(add.Unit_Number__c);
        ccAdd.setAddress1(add.Address_1__c);
        ccMock.levelNumber = add.Level_Number__c;
        ccMock.address1 = add.Address_1__c;
        ccMock.address2 = add.Address_2__c;
        ccMock.address3 = add.Address_3__c;
        ccMock.address4 = add.Address_4__c;
        ccAdd.setAddress2(add.Address_2__c);
        ccAdd.setAddress3(add.Address_3__c);
        ccAdd.setAddress4(add.Address_4__c);
        ccMock.billingIndicator = 'Y';
        ccMock.deliveryIndicator = 'Y';
        ccMock.subscriptions = zSub;
        ccMock.effectiveDate = '10/02/2015';
        ccAdd.setBillingIndicator('Y');
        ccAdd.setDeliveryIndicator('Y');
        ccAdd.setEffectiveDate('10/02/2015');
        ccAdd.setSubscriptions(zSub);
        ccAdd.getCustomerAccountNumber();
        ccAdd.getBillingAccountNumber();
        ccAdd.getCountry();
        ccAdd.getBlockNumber();
        ccAdd.getPostalCode();
        ccAdd.getLevelNumber();
        ccAdd.getUnitNumber();
        
        ccAdd.getAddress2();
        ccAdd.getAddress3();
        ccAdd.getAddress4();
        ccAdd.getBillingIndicator();
        ccAdd.getDeliveryIndicator();
        ccAdd.getEffectiveDate();
        ccAdd.getSubscriptions();
        String jsonStr = JSON.serialize(ccMock);
        ccAdd = (ChangeAddressService.ChangeAddressServiceRequest) JSON.deserialize(jsonStr, ChangeAddressService.ChangeAddressServiceRequest.class);
        ChangeAddressService.ChangeAddressServiceResponse res =  ChangeAddressService.processRequest(ccAdd);
        Test.stopTest();
    }
    static testmethod void myUnitTest3(){
        createCustomSettings();
        //Map<String, SObject> sObjMap = TestDataFactory.createSubscriptionPackage20();
        Map<String, SObject> objectMap = new Map<String, SObject>(); 
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        //insert postal;
        
        objectMap.put('Singpost_Address__c', postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        
        //insert acc;
        
        objectMap.put('Account', acc);
        
        Country__c country = new Country__c();
        country.Name = 'ZZ';
        country.Code__c = 'ZZ';
        country.Country_Name__c = 'Singapore';
        
        objectMap.put('Country__c', country);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        //insert pack;
        
        objectMap.put('Package__c', pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        //insert zProduct;
        
        objectMap.put('zqu__ZProduct__c', zProduct);
        
        insert objectMap.values();
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        objectMap.put('Package_Item__c', pItem);   
           
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = country.Id;
        addressRec.Address_1__c = 'Address 1';
        addressRec.Address_2__c = 'Address 2';
        addressRec.Address_3__c = 'Address 3';
        addressRec.Address_4__c = 'Address 4';
        insert addressRec;
        
        objectMap.put('Address__c', addressRec);   
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        objectMap.put('Recipient Contact', con);   
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        objectMap.put('Billing Contact', con1);   
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Billing_Contact__c = con1.id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        insert billAcc;
        
        objectMap.put('Zuora__CustomerAccount__c', billAcc);
        
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
        
        objectMap.put('Order__c', order);   
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        objectMap.put('Case', cas);   
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.newInstance(2017, 12, 2);
        orderline.Start_Date__c = date.today()+1;
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
        orderline.Fee_Override__c = False;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        objectMap.put('Order_Line_Item__c', orderline);  

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__CustomerAccount__c = billAcc.id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        objectMap.put('Zuora__Subscription__c', subRecs);  
        
        List<String> zSub = new List<String>();
        Zuora__Subscription__c zs = (Zuora__Subscription__c) objectMap.get('Zuora__Subscription__c');
        zs.Zuora__Zuora_Id__c = '3d3236481021237219dd9123';
        Test.startTest();
        
        insert zs;
        
        zSub.add(zs.Zuora__Zuora_Id__c);
        ChangeAddressServiceRequest ccMock = new ChangeAddressServiceRequest();
        ChangeAddressService.ChangeAddressServiceRequest ccAdd = new ChangeAddressService.ChangeAddressServiceRequest();
        String customerAcctNumber = [Select Account_Auto_Number__c From Account Where Id =: objectMap.get('Account').id Limit 1].Account_Auto_Number__c;
        ccAdd.setCustomerAccountNumber(customerAcctNumber);
        ccMock.customerAccountNumber = customerAcctNumber;
        Zuora__CustomerAccount__c zc = (Zuora__CustomerAccount__c) objectMap.get('Zuora__CustomerAccount__c');
        ccAdd.setBillingAccountNumber(zc.Zuora__Zuora_Id__c);
        ccMock.billingAccountNumber = zc.Zuora__Zuora_Id__c;
        Country__c co = (Country__c) objectMap.get('Country__c');
        ccAdd.setCountry(co.Code__c);
        ccMock.country = co.Code__c;
        Singpost_Address__c sa = (Singpost_Address__c) objectMap.get('Singpost_Address__c');
        ccAdd.setBlockNumber(sa.House_Block_Number__c);
        ccAdd.setPostalCode(sa.Name);
        ccMock.blockNumber = sa.House_Block_Number__c;
        ccMock.postalCode = sa.Name;
        Address__c add = (Address__c) objectMap.get('Address__c');
        ccAdd.setLevelNumber(add.Level_Number__c);
        ccAdd.setUnitNumber(add.Unit_Number__c);
        ccAdd.setAddress1(add.Address_1__c);
        ccMock.levelNumber = add.Level_Number__c;
        ccMock.address1 = add.Address_1__c;
        ccMock.address2 = add.Address_2__c;
        ccMock.address3 = add.Address_3__c;
        ccMock.address4 = add.Address_4__c;
        ccAdd.setAddress2(add.Address_2__c);
        ccAdd.setAddress3(add.Address_3__c);
        ccAdd.setAddress4(add.Address_4__c);
        ccMock.billingIndicator = 'Y';
        ccMock.deliveryIndicator = 'Y';
        ccMock.subscriptions = new List<String>();
        ccMock.effectiveDate = '10/02/2015';
        ccAdd.setBillingIndicator('Y');
        ccAdd.setDeliveryIndicator('Y');
        ccAdd.setEffectiveDate('10/02/2015');
        ccAdd.setSubscriptions(zSub);
        ccAdd.getCustomerAccountNumber();
        ccAdd.getBillingAccountNumber();
        ccAdd.getCountry();
        ccAdd.getBlockNumber();
        ccAdd.getPostalCode();
        ccAdd.getLevelNumber();
        ccAdd.getUnitNumber();
        
        ccAdd.getAddress2();
        ccAdd.getAddress3();
        ccAdd.getAddress4();
        ccAdd.getBillingIndicator();
        ccAdd.getDeliveryIndicator();
        ccAdd.getEffectiveDate();
        ccAdd.getSubscriptions();
        String jsonStr = JSON.serialize(ccMock);
        ccAdd = (ChangeAddressService.ChangeAddressServiceRequest) JSON.deserialize(jsonStr, ChangeAddressService.ChangeAddressServiceRequest.class);
        ChangeAddressService.ChangeAddressServiceResponse res =  ChangeAddressService.processRequest(ccAdd);
        Test.stopTest();
    }
    

}