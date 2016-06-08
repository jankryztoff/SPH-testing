@isTest (SeeAllData=FALSE)
private class SM_SubscriptionHelperTest2 {
     
    static void setCustomSettings() {
    
        //Cir_Planner_Schedule__c
        List<Cir_Planner_Schedule__c> cpsList = new List<Cir_Planner_Schedule__c>{
                new Cir_Planner_Schedule__c(Name='CIR Plan Schedule',
                                            Mon_Fri_End_Time__c=Date.today(),
                                            Mon_Fri_Start_Time__c=Date.today(),
                                            Sat_PH_End_Time__c=Date.today(),
                                            Sat_PH_Start_Time__c=Date.today(),
                                            Sun_End_Time__c=Date.today(),
                                            Sun_Start_Time__c=Date.today())
        };
        Database.insert(cpsList);
        
        //
        RecordType Case_ChangeinAddress = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Change of Address/Vendor' LIMIT 1];
        RecordType Case_TempStop        = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Temp Stop Subscription' LIMIT 1];
        RecordType Contact_VendorStaff     = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Vendor Staff' LIMIT 1];
        RecordType Contact_CustomerContact = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Customer Contact' LIMIT 1];
        RecordType Case_Stop = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Stop Subscription' LIMIT 1];
        
        //Key_Id__c
        //.getInstance('Vendor Rep Role')
        //ConstantsSLB.getKeyId('Contact_Customer Contact');
        /*
        final string AIRLINE = ConstantsSLB.getKeyId('AddAirline');
        final string OVERSEAS = ConstantsSLB.getKeyId('AddOverseas');
        final string LOCAL = ConstantsSLB.getKeyId('AddLocal');
        final string INTERNAL = ConstantsSLB.getKeyId('AddInternal');
        */
        List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role',       Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c='123456789', Type__c='Number'),
            
            new Key_Id__c(Name='Case_Change in Address', Id__c=Case_ChangeinAddress.id, Type__c='RecordType'),
            new Key_Id__c(Name='Case_Temp Stop',         Id__c=Case_TempStop.id,        Type__c='RecordType'),
            
            new Key_Id__c(Name='Contact_Vendor Staff',     Id__c=Contact_VendorStaff.id,     Type__c='RecordType'),
            new Key_Id__c(Name='Contact_Customer Contact', Id__c=Contact_CustomerContact.id, Type__c='RecordType'),
            
            new Key_Id__c(Name='Case_Stop', Id__c=Case_Stop.id ,Type__c='RecordType'),
            
            new Key_Id__c(Name='AddInternal', Id__c='Internal', Type__c='Name'),
            new Key_Id__c(Name='AddLocal',    Id__c='Local',     Type__c='Name')
        };
        Database.insert(kisList);
        
        //Batch_Configuration_Settings__c.getInstance('SP_VendorNotificationsBatch');
        List<Batch_Configuration_Settings__c> bcsList = new List<Batch_Configuration_Settings__c>{
            new Batch_Configuration_Settings__c(Name='SP_VendorNotificationsBatch', Batch_Size__c=10, 
                Max_Retries__c=10, Notification_Recipients__c='', Number_Of_Days_To_Retrieve__c=30)
        };
        Database.insert(bcsList);
        
        //Other__c
        // List<Other__c> otherList = new List<Other__c>{
        //     //new Other__c(Name='DTL', Value__c='2:00'),
            
        //     new Other__c(Name='Zero Charge Amount',     Value__c='Zero Charge Amount'),
        //     new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB Delivery Charge'),
        //     new Other__c(Name='APT DELIVERY CHARGE',    Value__c='Apt Delivery Charge'),
        //     new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge')
        // };        
        // Database.insert(otherList);
        
        //Delivery_Charge_Type__c
        List<Delivery_Charge_Type__c> delCharTypeList = new List<Delivery_Charge_Type__c>{
            new Delivery_Charge_Type__c(Name='H', Default_Delivery_Charge_Type__c='H'),
            new Delivery_Charge_Type__c(Name='L', Default_Delivery_Charge_Type__c='L'),
            new Delivery_Charge_Type__c(Name='C', Default_Delivery_Charge_Type__c='C')
        };
        Database.insert(delCharTypeList);
    }


    static void testGetDtlDate01() {
    
        setCustomSettings();
    
        //Public_Holiday__c
        Public_Holiday__c publicHoliday = new Public_Holiday__c(
            Holiday_Date__c=Date.today(), Holiday_Description__c='National Day'
        );
        Database.insert(publicHoliday);
        
        SM_SubscriptionHelper.getDtlDate();
    }
    
    static void testGetCharges00() {
        
        setCustomSettings();
        
        //Test data creation
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        Database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        Database.insert(acc); 
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        Database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        Database.insert(zProduct);
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        Database.insert(prdRatePlan);
        
        
        /*from zqu__ProductRatePlanCharge__c
            where zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCode__c = :GlobalVariableClass.PRODUCT_CODE_DELCHG 
            and (not Name like 'Credit%') and (not Name like 'Dummy%') and zqu__Deleted__c = false]*/
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        Database.insert(zprpc);
                
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        Database.insert(pItem);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        Database.insert(billAcc);  
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        Database.insert(addressRec);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        Database.insert(con);   
        
        Contact con1 = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.Billing_Indicator__c = true;
        Database.insert(con1);
        
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
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        //order.Postage_Charge__c = 200.00;
        Database.insert(order);   
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        Database.insert(cas); 
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.Earliest_Start_Date__c = Date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE; //changed by JJZS
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        Database.insert(orderline);

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.id;
        subRecs.Zuora__Account__c = acc.Id;
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
        subRecs.Order_Line_Item_Number_1__c = orderline.Id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Generate_Invoice1__c = 'false';
        subRecs.Sponsor_1__c = false;
        Database.insert(subRecs);
    
        
        order.Subscription__c = subRecs.id;
        update order;
        
        Promotion__c promoTmp = TestDataFactory.createPromotion(1)[0]; 
        promoTmp.Name = 'Promotions';
        promoTmp.Contract_Period__c ='12';
        promoTmp.Penalty_Charge__c = '100';
        Database.insert(promoTmp);           
        
        List<Order_Line_Item__c> oliList= TestDataFactory.createOrderLineItem(1);
        oliList[0].Order__c = order.id;
        oliList[0].Main_Package_ID__c = pack.Id;
        oliList[0].Is_Digital__c = true;
        oliList[0].Start_Date__c = Date.today().addDays(1);
        Database.insert(oliList);
        
        Promotion_Gift__c PromoGift = TestDataFactory.createPromotionGift(1)[0];
        Database.insert(PromoGift);        
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'M';
        pub.Publish_Pattern__c = 'Weekdays';
        pubList.add(pub);
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'M';
        npub.Publish_Pattern__c = 'Weekdays';
        pubList.add(npub);
        Database.insert(pubList);            
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        Database.insert(nonPubList);
        
        
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        Database.insert(SAF);
        
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        Database.insert(PAF);
        
        Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
        tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        tmpAsia1.Display_Name__c = 'Test';
        tmpAsia1.Email__c = 'test@email.com' ;
        tmpAsia1.Password__c = 'aBcD3Fg';
        tmpAsia1.Contact__c = con.Id;
        tmpAsia1.Status__c = 'Pending Creation';
        Database.insert(tmpAsia1);
        
        List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
        asiaSubList[0].Asia1__c = tmpAsia1.Id;
        asiaSubList[0].Subscription__c = subRecs.Id;
        asiaSubList[0].Status__c = 'Pending Creation';
        asiaSubList[0].Order_Line_Item__c = orderline.Id;
        asiaSubList[0].Service_Access_Flag__c = SAF.Id;
        Database.insert(asiaSubList); 
        //end of test data creation
        
        set<id> pacids = new set<id>();
        pacids.add(pack.id);
        
           
        SM_SubscriptionHelper.getCharges(con.id, 'deliveryChargeType', 10, 10);
        SM_SubscriptionHelper.deleteRelatedOrderLineItemRelatedObjects(orderline.id);
      
    }
    
    static testMethod void testGetCharges01() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            //Test data creation
            setCustomSettings();
            
        List<Other__c> otherList = new List<Other__c>{
        //new Other__c(Name='DTL', Value__c='2:00'),
        
        new Other__c(Name='Zero Charge Amount',     Value__c='Zero Charge Amount'),
        new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB Delivery Charge'),
        new Other__c(Name='APT DELIVERY CHARGE',    Value__c='Apt Delivery Charge'),
        new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge')
        };        

        Database.insert(otherList);

            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            Database.insert(postal);
            
            RecordType Address_Internal = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Internal' LIMIT 1];
            RecordType Address_Local    = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Local' LIMIT 1];
            
            List<Address__c> addressRecList = TestDataFactory.createAddress(4);
            for(Address__c addressRec : addressRecList) {
                addressRec.RecordTypeId = Address_Local.Id;
                addressRec.Address_Type__c = 'H';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
            }
            //Internal
            addressRecList[0].RecordTypeId = Address_Internal.Id;
            //Local
            addressRecList[1].Address_Type__c = 'H';
            addressRecList[2].Address_Type__c = 'L';
            addressRecList[3].Address_Type__c = 'C';
            Database.insert(addressRecList);
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            Database.insert(acc);    
            
            List<Contact> conList = TestDataFactory.createContactRecType(4, 'Customer Contact');
            for(Contact con : conList) {
                con.AccountId = acc.Id;
                con.Recipient_Indicator__c = true;
            }
            conList[0].Address__c = addressRecList[0].Id;
            conList[1].Address__c = addressRecList[1].Id;
            conList[2].Address__c = addressRecList[2].Id;
            conList[3].Address__c = addressRecList[3].Id;
            //Database.insert(conList); D-xxx
    
            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            Database.insert(pack);
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.ProductCode__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
            Database.insert(zProduct);
            
            List<zqu__ProductRatePlan__c> prdRatePlanList = TestDataFactory.createProductRatePlan(4);
            for(zqu__ProductRatePlan__c prdRatePlan : prdRatePlanList) {
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today();
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
            }
            prdRatePlanList[0].Name = 'Zero Name';
            prdRatePlanList[1].Name = 'HDB Name';
            prdRatePlanList[2].Name = 'APT Name';
            prdRatePlanList[3].Name = 'LANDED Name';
            Database.insert(prdRatePlanList);
            
            /*from zqu__ProductRatePlanCharge__c
                where zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCode__c = :GlobalVariableClass.PRODUCT_CODE_DELCHG 
                and (not Name like 'Credit%') and (not Name like 'Dummy%') and zqu__Deleted__c = false]*/
            List<zqu__ProductRatePlanCharge__c> zprpcList =  TestDataFactory.createProductRatePlanCharge(4);
            zprpcList[0].zqu__ProductRatePlan__c = prdRatePlanList[0].id;
            zprpcList[0].zqu__ZuoraId__c = '3689922200';
            zprpcList[1].zqu__ProductRatePlan__c = prdRatePlanList[1].id;
            zprpcList[1].zqu__ZuoraId__c = '3689922201';
            zprpcList[2].zqu__ProductRatePlan__c = prdRatePlanList[2].id;
            zprpcList[2].zqu__ZuoraId__c = '3689922202';
            zprpcList[3].zqu__ProductRatePlan__c = prdRatePlanList[3].id;
            zprpcList[3].zqu__ZuoraId__c = '3689922203';
            Database.insert(zprpcList);
            
            //zqu__ProductRatePlanChargeTier__c
            List<zqu__ProductRatePlanChargeTier__c> productRatePlanList = TestDataFactory.createProductRatePlanChargeTier(4);
            productRatePlanList[0].zqu__Price__c = 10;
            productRatePlanList[0].zqu__ProductRatePlanCharge__c = zprpcList[0].id;
            productRatePlanList[1].zqu__Price__c = 20;
            productRatePlanList[1].zqu__ProductRatePlanCharge__c = zprpcList[1].id;
            productRatePlanList[2].zqu__Price__c = 30;
            productRatePlanList[2].zqu__ProductRatePlanCharge__c = zprpcList[2].id;
            productRatePlanList[3].zqu__Price__c = 40;
            productRatePlanList[3].zqu__ProductRatePlanCharge__c = zprpcList[3].id;
            Database.insert(productRatePlanList);
            
        
            Test.startTest();
            map<string, decimal> exp1;
            
            exp1 = SM_SubscriptionHelper.getCharges(conList[0].id,  'deliveryChargeType', 10, 10);
            //System.assertEquals(exp1.get('SubscriberCharge'), 10);
            System.assertEquals(exp1.get('VendorCredit'),     null);
            
            exp1 = SM_SubscriptionHelper.getCharges(conList[1].id, 'N', 10, 10);
            //System.assertEquals(exp1.get('SubscriberCharge'), 0.0);
            //System.assertEquals(exp1.get('VendorCredit'),     20);
            
            exp1 = SM_SubscriptionHelper.getCharges(conList[2].id, 'N', 10, 10);
            //System.assertEquals(exp1.get('SubscriberCharge'), 0.0);
            //System.assertEquals(exp1.get('VendorCredit'),     40);
            
            exp1 = SM_SubscriptionHelper.getCharges(conList[3].id, 'N', 10, 10);
            //System.assertEquals(exp1.get('SubscriberCharge'), 0.0);
            //System.assertEquals(exp1.get('VendorCredit'),     30);
            
            exp1 = SM_SubscriptionHelper.getCharges(conList[3].id, 'Z', 10, 10);
            //System.assertEquals(exp1.get('SubscriberCharge'), 0.0);
            //System.assertEquals(exp1.get('VendorCredit'),     0.0);
            
            exp1 = SM_SubscriptionHelper.getCharges(conList[3].id, 'S', 10, 10);
            //System.assertEquals(exp1.get('SubscriberCharge'), 10);
            //System.assertEquals(exp1.get('VendorCredit'),     10);
            
            exp1 = SM_SubscriptionHelper.getCharges(conList[1].id, 'H', 10, 10);
            //System.assertEquals(exp1.get('SubscriberCharge'), 20);
            //System.assertEquals(exp1.get('VendorCredit'),     20);
            
            exp1 = SM_SubscriptionHelper.getCharges(conList[2].id, 'L', 10, 10);
            //System.assertEquals(exp1.get('SubscriberCharge'), 40);
            //System.assertEquals(exp1.get('VendorCredit'),     40);
            
            exp1 = SM_SubscriptionHelper.getCharges(conList[3].id, 'C', 10, 10);
            //System.assertEquals(exp1.get('SubscriberCharge'), 30);
            //System.assertEquals(exp1.get('VendorCredit'),     30);
            Test.stopTest();
        }
    
    }
    
    static testMethod void testGetPackageSubscriptionRate01() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            //Test data creation
            setCustomSettings();
            
            // List<Other__c> otherList = new List<Other__c>{
            // //new Other__c(Name='DTL', Value__c='2:00'),
            
            // new Other__c(Name='Zero Charge Amount',     Value__c='Zero Charge Amount'),
            // new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB Delivery Charge'),
            // new Other__c(Name='APT DELIVERY CHARGE',    Value__c='Apt Delivery Charge'),
            // new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge')
            // };        
            // Database.insert(otherList);

            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            Database.insert(postal);
            
            RecordType Address_Internal = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Internal' LIMIT 1];
            RecordType Address_Local    = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Local' LIMIT 1];
            
              
            List<Address__c> addressRecList = TestDataFactory.createAddress(4);
            for(Address__c addressRec : addressRecList) {
                addressRec.RecordTypeId = Address_Local.Id;
                addressRec.Address_Type__c = 'H';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Block_House_Number__c ='TEST';
                addressRec.Level_Number__c ='xx';
                addressRec.Unit_Number__c = 'yy';
            }
            //Internal
            addressRecList[0].RecordTypeId = Address_Internal.Id;
            //Local
            addressRecList[1].Address_Type__c = 'H';
            addressRecList[2].Address_Type__c = 'L';
            addressRecList[3].Address_Type__c = 'C';
            Database.insert(addressRecList);
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            Database.insert(acc);    
            
            List<Contact> conList = TestDataFactory.createContactRecType(4, 'Customer Contact');
            for(Contact con : conList) {
                con.AccountId = acc.Id;
                con.Recipient_Indicator__c = true;
            }
            conList[0].Address__c = addressRecList[0].Id;
            conList[1].Address__c = addressRecList[1].Id;
            conList[2].Address__c = addressRecList[2].Id;
            conList[3].Address__c = addressRecList[3].Id;
            //Database.insert(conList);
    
            List<Package__c> packList = TestDataFactory.createPackage(4);
            for(Package__c pack : packList) {
                pack.Billing_Type__c = 'Bill Plan';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
            }
            packList[0].Package_Code__c = 'afds130';
            packList[1].Package_Code__c = 'afds131';
            packList[2].Package_Code__c = 'afds132';
            packList[3].Package_Code__c = 'afds133';
            Database.insert(packList);
                        
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.ProductCode__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
            Database.insert(zProduct);
            
            List<zqu__ProductRatePlan__c> prdRatePlanList = TestDataFactory.createProductRatePlan(4);
            for(zqu__ProductRatePlan__c prdRatePlan : prdRatePlanList) {
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c = 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today();
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                prdRatePlan.BillingType__c = 'Bill Plan';
            }
            prdRatePlanList[0].Name = 'Zero Name';
            prdRatePlanList[1].Name = 'HDB Name';
            prdRatePlanList[2].Name = 'APT Name';
            prdRatePlanList[3].Name = 'LANDED Name';
            Database.insert(prdRatePlanList);
            
            /*from zqu__ProductRatePlanCharge__c 
                where zqu__ProductRatePlan__c in :productRatePlanIds and zqu__ProductRatePlan__r.BillingType__c = :billingType*/
            List<zqu__ProductRatePlanCharge__c> zprpcList =  TestDataFactory.createProductRatePlanCharge(4);
            zprpcList[0].zqu__ProductRatePlan__c = prdRatePlanList[0].id;
            zprpcList[0].zqu__ZuoraId__c = '3689922200';
            zprpcList[1].zqu__ProductRatePlan__c = prdRatePlanList[1].id;
            zprpcList[1].zqu__ZuoraId__c = '3689922201';
            zprpcList[2].zqu__ProductRatePlan__c = prdRatePlanList[2].id;
            zprpcList[2].zqu__ZuoraId__c = '3689922202';
            zprpcList[3].zqu__ProductRatePlan__c = prdRatePlanList[3].id;
            zprpcList[3].zqu__ZuoraId__c = '3689922203';
            Database.insert(zprpcList);
            
            List<zqu__ProductRatePlanCharge__c> zprpcList2 =  TestDataFactory.createProductRatePlanCharge(1);
            zprpcList2[0].zqu__ProductRatePlan__c = prdRatePlanList[0].id;
            zprpcList2[0].zqu__ZuoraId__c = '3689922204';
            Database.insert(zprpcList2);
                      
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = packList[0].id;
            pItem.Product_Rate_Plan__c = prdRatePlanList[0].id;
            pItem.Name = 'Test Pack Item';
            Database.insert(pItem);
            
            
            set<id> pacids = new set<id>();
            pacids.add(packList[0].id);
            
            // string billType = 'Full Prepaid';
            
            
            Test.startTest();
            SM_SubscriptionHelper.getPackageSubscriptionRate(pacids, 'Bill Plan');
            //boolean var = SM_SubscriptionHelper.checkExistingInvoice(acc.id,billType);
            Test.stopTest();
        }
    
    }
    
    static testMethod void testgetRelatedPackages01() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            //Test data creation
            setCustomSettings();
            
            List<Other__c> otherList = new List<Other__c>{
            //new Other__c(Name='DTL', Value__c='2:00'),
            
            new Other__c(Name='Zero Charge Amount',     Value__c='Zero Charge Amount'),
            new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB Delivery Charge'),
            new Other__c(Name='APT DELIVERY CHARGE',    Value__c='Apt Delivery Charge'),
            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge')
            };        
            Database.insert(otherList);

            //Package__c
            List<Package__c> packList = TestDataFactory.createPackage(4);
            for(Package__c pack : packList) {
                pack.Billing_Type__c = 'Bill Plan';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
            }
            packList[0].Package_Code__c = 'afds130';
            packList[0].Product_Family_Current_Package__c = 'afds130';
            packList[1].Package_Code__c = 'afds131';
            packList[1].Product_Family_Current_Package__c = 'afds130';
            packList[2].Package_Code__c = 'afds132';
            packList[2].Product_Family_Current_Package__c = 'afds130';
            packList[3].Package_Code__c = 'afds133';
            packList[3].Product_Family_Current_Package__c = 'afds130';
            Database.insert(packList);
                       
            //Promotion__c 
            Promotion__c promoTmp = TestDataFactory.createPromotion(1)[0]; 
            promoTmp.Name = 'Promotions';
            promoTmp.Contract_Period__c ='12';
            promoTmp.Penalty_Charge__c = '100';
            Database.insert(promoTmp);    
        
            //Promotion_Package__c
            List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(4);
            promotionPackageList[0].Package_Name__c = packList[0].id;
            promotionPackageList[0].Promotion__c = promoTmp.id;
            promotionPackageList[1].Package_Name__c = packList[1].id;
            promotionPackageList[1].Promotion__c = promoTmp.id;
            promotionPackageList[2].Package_Name__c = packList[2].id;
            promotionPackageList[2].Promotion__c = promoTmp.id;
            promotionPackageList[3].Package_Name__c = packList[3].id;
            promotionPackageList[3].Promotion__c = promoTmp.id;
            Database.insert(promotionPackageList);
         
            String promotionId = ''+promoTmp.id; 
            String billingType = 'Bill Plan'; 
            //String sId =  ''+packList[0].id;
           
            Test.startTest();
            String serializedResult = SM_SubscriptionHelper.getRelatedPackages(promotionId, billingType);
            //SM_SubscriptionHelper.getRelatedPackagesOnProdFam(promotionId, billingType ,sId);
            List<RelatedPackageWrapper> rpwList = (List<RelatedPackageWrapper>)System.JSON.deserialize(serializedResult, List<RelatedPackageWrapper>.class);
            System.assertEquals(4, rpwList.size());
            Test.stopTest();
        }
    }
    
    private class RelatedPackageWrapper {
        
        string packageId;
        string packageName;
        string packageType;
        string packageSubscriptionType;
        string packageSubscriptionPeriod;
        decimal packageSubscriptionRate;        
    }
    
    static void testGetRelatedPackages02() {
        
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            //Test data creation
            setCustomSettings();
            
            //Package__c
            List<Package__c> packList = TestDataFactory.createPackage(4);
            for(Package__c pack : packList) {
                pack.Billing_Type__c = 'Bill Plan';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
            }
            packList[0].Package_Code__c = 'afds130';
            packList[1].Package_Code__c = 'afds131';
            packList[2].Package_Code__c = 'afds132';
            packList[3].Package_Code__c = 'afds133';
            Database.insert(packList);
            
            //Promotion__c 
            Promotion__c promoTmp = TestDataFactory.createPromotion(1)[0]; 
            promoTmp.Name = 'Promotions';
            promoTmp.Contract_Period__c ='12';
            promoTmp.Penalty_Charge__c = '100';
            Database.insert(promoTmp);    
        
            //Promotion_Package__c
            List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(4);
            promotionPackageList[0].Package_Name__c = packList[0].id;
            promotionPackageList[0].Promotion__c = promoTmp.id;
            promotionPackageList[1].Package_Name__c = packList[1].id;
            promotionPackageList[1].Promotion__c = promoTmp.id;
            promotionPackageList[2].Package_Name__c = packList[2].id;
            promotionPackageList[2].Promotion__c = promoTmp.id;
            promotionPackageList[3].Package_Name__c = packList[3].id;
            promotionPackageList[3].Promotion__c = promoTmp.id;
            Database.insert(promotionPackageList);
         
            String promotionId = promoTmp.id; 
            String billingType = 'Bill Plan'; 
            /*
            String accountId, 
            String action, 
            boolean isVendor, 
            Id subscriptionId
            */
            
            /*
            Test.startTest();
            String serializedResult = SM_SubscriptionHelper.getRelatedPackages(String promotionId, String billingType, String accountId, String action, boolean isVendor, Id subscriptionId);
            List<RelatedPackageWrapper> rpwList = (List<RelatedPackageWrapper>)System.JSON.deserialize(serializedResult, List<RelatedPackageWrapper>.class);
            System.assertEquals(4, rpwList.size());
            Test.stopTest();
            */
        }
    }
        static testMethod void testgetRelatedPackagesApril() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            //Test data creation
            setCustomSettings();
            List<Other__c> otherList = new List<Other__c>{
            //new Other__c(Name='DTL', Value__c='2:00'),
            
            new Other__c(Name='Zero Charge Amount',     Value__c='Zero Charge Amount'),
            new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB Delivery Charge'),
            new Other__c(Name='APT DELIVERY CHARGE',    Value__c='Apt Delivery Charge'),
            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge')
            };        
            Database.insert(otherList);
        
            //Package__c
            List<Package__c> packList = TestDataFactory.createPackage(4);
            for(Package__c pack : packList) {
                pack.Billing_Type__c = 'Bill Plan';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
            }
            packList[0].Package_Code__c = 'afds130';
            packList[1].Package_Code__c = 'afds131';
            packList[2].Package_Code__c = 'afds132';
            packList[3].Package_Code__c = 'afds133';
            Database.insert(packList);
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            Database.insert(zProduct);
        
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            Database.insert(prdRatePlan);
            
            Product_Family__c prodFamily = TestDataFactory.createProductFamily(1)[0];
            prodFamily.Product_Family__c = 'xy12nh76';
            database.insert(prodFamily);
            
            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(2,'Base Product');
            pItem[0].Package__c = packList[0].id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[0].Name = 'Test Pack Item';
            pItem[0].Product_Family__c = prodFamily.id;
            
            pItem[1].Package__c = packList[0].id;
            pItem[1].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[1].Name = 'Test Pack Item';
            pItem[1].Product_Family__c = prodFamily.id;
            
           
            Database.insert(pItem);
            
            //Promotion__c 
            Promotion__c promoTmp = TestDataFactory.createPromotion(1)[0]; 
            promoTmp.Name = 'Promotions';
            promoTmp.Contract_Period__c ='12';
            promoTmp.Penalty_Charge__c = '100';
            Database.insert(promoTmp);    
        
            //Promotion_Package__c
            List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(4);
            promotionPackageList[0].Package_Name__c = packList[0].id;
            promotionPackageList[0].Promotion__c = promoTmp.id;
            promotionPackageList[1].Package_Name__c = packList[1].id;
            promotionPackageList[1].Promotion__c = promoTmp.id;
            promotionPackageList[2].Package_Name__c = packList[2].id;
            promotionPackageList[2].Promotion__c = promoTmp.id;
            promotionPackageList[3].Package_Name__c = packList[3].id;
            promotionPackageList[3].Promotion__c = promoTmp.id;
            Database.insert(promotionPackageList);
         
            String promotionId = ''+promoTmp.id; 
            String billingType = 'Bill Plan'; 
            String sId =  ''+packList[0].id;
           
            Test.startTest();
            String serializedResult = SM_SubscriptionHelper.getRelatedPackages(promotionId, billingType);
            SM_SubscriptionHelper.getRelatedPackagesOnProdFam(promotionId, billingType ,sId);
            List<RelatedPackageWrapper> rpwList = (List<RelatedPackageWrapper>)System.JSON.deserialize(serializedResult, List<RelatedPackageWrapper>.class);
            SM_SubscriptionHelper.getBillingTypeForBA('Full Prepaid');
            SM_SubscriptionHelper.getBillingTypeForBA('Recurring Prepaid');
            SM_SubscriptionHelper.getBillingTypeForBA('Recurring Postpaid');
            SM_SubscriptionHelper.getBillingTypeForBA(null);
            System.assertEquals(4, rpwList.size());
            Test.stopTest();
        }
    }
    static testMethod void testgetRelatedPackagesApril2() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
            //Test data creation
            setCustomSettings();
            List<Other__c> otherList = new List<Other__c>{
            //new Other__c(Name='DTL', Value__c='2:00'),
            new Other__c(Name='DTL',     Value__c=''+datetime.now().hour()), 
            new Other__c(Name='Zero Charge Amount',     Value__c='Zero Charge Amount'),
            new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB Delivery Charge'),
            new Other__c(Name='APT DELIVERY CHARGE',    Value__c='Apt Delivery Charge'),
            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge')
            };        
            Database.insert(otherList);

           // Other__c other = new Other__c();
           // other.Name = 'DTL';
           // other.Value__c = ''+datetime.now().hour(); //'02:00';
           // database.insert(other);
           
            //Package__c
            List<Package__c> packList = TestDataFactory.createPackage(4);
            for(Package__c pack : packList) {
                pack.Billing_Type__c = 'Bill Plan';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
            }
            packList[0].Package_Code__c = 'afds130';
            packList[1].Package_Code__c = 'afds131';
            packList[2].Package_Code__c = 'afds132';
            packList[3].Package_Code__c = 'afds133';
            Database.insert(packList);
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            Database.insert(zProduct);
        
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            Database.insert(prdRatePlan);
            
            Product_Family__c prodFamily = TestDataFactory.createProductFamily(1)[0];
            prodFamily.Product_Family__c = 'xy12nh76';
            database.insert(prodFamily);
            
            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(2,'Base Product');          
            pItem[0].Package__c = packList[0].id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[0].Name = 'Test Pack Item';
            //pItem[0].Product_Family__c = prodFamily.id;
            
            pItem[1].Package__c = packList[0].id;
            pItem[1].Product_Rate_Plan__c = prdRatePlan.id;
            pItem[1].Name = 'Test Pack Item';
            //pItem[0].Product_Family__c = prodFamily.id;
            Database.insert(pItem);
            
            //Promotion__c 
            Promotion__c promoTmp = TestDataFactory.createPromotion(1)[0]; 
            promoTmp.Name = 'Promotions';
            promoTmp.Contract_Period__c ='12';
            promoTmp.Penalty_Charge__c = '100';
            Database.insert(promoTmp);    
        
            //Promotion_Package__c
            List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(4);
            promotionPackageList[0].Package_Name__c = packList[0].id;
            promotionPackageList[0].Promotion__c = promoTmp.id;
            promotionPackageList[1].Package_Name__c = packList[1].id;
            promotionPackageList[1].Promotion__c = promoTmp.id;
            promotionPackageList[2].Package_Name__c = packList[2].id;
            promotionPackageList[2].Promotion__c = promoTmp.id;
            promotionPackageList[3].Package_Name__c = packList[3].id;
            promotionPackageList[3].Promotion__c = promoTmp.id;
            Database.insert(promotionPackageList);
         
            String promotionId = ''+promoTmp.id; 
            String billingType = 'Bill Plan'; 
            String sId =  ''+packList[0].id;
           
            Test.startTest();
            SM_SubscriptionHelper.generateOrderSoqlStr();
            String serializedResult = SM_SubscriptionHelper.getRelatedPackages(promotionId, billingType);
            SM_SubscriptionHelper.getRelatedPackagesOnProdFam(promotionId, billingType ,sId);
            List<RelatedPackageWrapper> rpwList = (List<RelatedPackageWrapper>)System.JSON.deserialize(serializedResult, List<RelatedPackageWrapper>.class);
            System.assertEquals(4, rpwList.size());
            Test.stopTest();
        }
    }

    static testMethod void testgetRelatedPackagesApril3() {
    
                        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
                        //Test data creation
                        //setCustomSettings();
                        List<Key_Id__c> key = new List<Key_Id__c>{
                            new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER', Id__c = '30012551'),
                            new Key_Id__c(Name = 'AddAirline', Id__c = 'Airline'),
                            new Key_Id__c(Name = 'AddInternal', Id__c = 'Internal'),
                            new Key_Id__c(Name = 'AddOverseas', Id__c = 'Overseas'),
                            new Key_Id__c(Name = 'AddLocal', Id__c = 'Local')
                        };
                        // key.Name = 'NEXT_RECIPIENT_NUMBER';
                        // key.Id__c = '30012551';
                        database.insert(key);

                        List<Delivery_Charge_Type__c> delCharTypeList = new List<Delivery_Charge_Type__c>{
                            new Delivery_Charge_Type__c(Name='A', Default_Delivery_Charge_Type__c='C'),
                            new Delivery_Charge_Type__c(Name='B', Default_Delivery_Charge_Type__c='C'),
                            new Delivery_Charge_Type__c(Name='C', Default_Delivery_Charge_Type__c='C'),
                            new Delivery_Charge_Type__c(Name='G', Default_Delivery_Charge_Type__c='C'),
                            new Delivery_Charge_Type__c(Name='H', Default_Delivery_Charge_Type__c='H'),
                            new Delivery_Charge_Type__c(Name='K', Default_Delivery_Charge_Type__c='C'),
                            new Delivery_Charge_Type__c(Name='P', Default_Delivery_Charge_Type__c='C'),
                            new Delivery_Charge_Type__c(Name='S', Default_Delivery_Charge_Type__c='L'),
                            new Delivery_Charge_Type__c(Name='U', Default_Delivery_Charge_Type__c='C'),
                            new Delivery_Charge_Type__c(Name='W', Default_Delivery_Charge_Type__c='C')
                        };
                        
                        Database.insert(delCharTypeList);
                        
                        List<Other__c> otherList2 = new List<Other__c> {
                            
                            new Other__c(Name='DTL', Value__c='23:59'),
                            new Other__c(Name='Friday', Value__c='Fri'),
                            new Other__c(Name='Saturday', Value__c='Sat'),
                            new Other__c(Name='Sunday', Value__c='Sun'),
                            new Other__c(Name='Zero Charge Amount',     Value__c='Zero Charge Amount'),
                            new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB Delivery Charge'),
                            new Other__c(Name='APT DELIVERY CHARGE',    Value__c='Apt Delivery Charge'),
                            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge')
                        };        
                        // other.Name = 'DTL';
                        // other.Value__c = '23:59';
                        database.insert(otherList2);

                      
                        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
                        cir.Name = 'CIR Plan Schedule';
                        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
                        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
                        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
                        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
                        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
                        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
                        database.insert(cir); 
        
                        Integration_Settings__c integ = new Integration_Settings__c();
                        integ.Name = 'Endpoint Delegator';
                        integ.Value__c = 'http://devcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator';
                        database.insert(integ);
                               
                        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                        postal.Name = 'SPostal';
                        postal.House_Block_Number__c = 'TEST';
                        postal.Address_Type__c = 'A';
                        Database.insert(postal);
                        
                        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                        acc.NRIC__c = 'T1234567R';
                        Database.insert(acc); 
                        
                        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
                        List<Address__c> addressRec = TestDataFactory.createAddress(5);
                        addressRec[0].Address_Type__c = 'A';
                        addressRec[0].Postal_Code__c = postal.Id;
                        addressRec[0].Block_House_Number__c ='TEST';
                        addressRec[0].Level_Number__c ='xx';
                        addressRec[0].Unit_Number__c = 'yy';
                        addressRec[0].RecordTypeId = rtAdd;

                        addressRec[1].Address_Type__c = 'H';
                        addressRec[1].Postal_Code__c = postal.Id;
                        addressRec[1].Block_House_Number__c ='TEST';
                        addressRec[1].Level_Number__c ='xx';
                        addressRec[1].Unit_Number__c = 'yy';
                        addressRec[1].RecordTypeId = rtAdd;

                        addressRec[2].Address_Type__c = 'K';
                        addressRec[2].Postal_Code__c = postal.Id;
                        addressRec[2].Block_House_Number__c ='TEST';
                        addressRec[2].Level_Number__c ='xx';
                        addressRec[2].Unit_Number__c = 'yy';
                        addressRec[2].RecordTypeId = rtAdd;

                        addressRec[3].Address_Type__c = 'S';
                        addressRec[3].Postal_Code__c = postal.Id;
                        addressRec[3].Block_House_Number__c ='TEST';
                        addressRec[3].Level_Number__c ='xx';
                        addressRec[3].Unit_Number__c = 'yy';
                        addressRec[3].RecordTypeId = rtAdd;

                        addressRec[4].Address_Type__c = 'C';
                        addressRec[4].Postal_Code__c = postal.Id;
                        addressRec[4].Block_House_Number__c ='TEST';
                        addressRec[4].Level_Number__c ='xx';
                        addressRec[4].Unit_Number__c = 'yy';
                        addressRec[4].RecordTypeId = rtAdd;
                        
                        Database.insert(addressRec);
                        
                        Set<Id> subRecsSet = new Set<Id>();

                        List<Contact> conList = TestDataFactory.createContactRecType(5, 'Customer Contact');
                        
                        conList[0].AccountId = acc.id;
                        conList[0].Address__c = addressRec[0].Id;
                        conList[0].AccountId = acc.Id;
                        conList[0].Recipient_Indicator__c = true;
                        conList[0].Billing_Indicator__c = true;
                        conList[0].Phone = '123456789';
                        conList[0].HomePhone = '123456789';
                        conList[0].Mobile_Number__c = '123456789';
                        conList[0].HomePhone__c = '123456789';
                        conList[0].Office_Number__c = '123456789';

                        conList[1].AccountId = acc.id;
                        conList[1].Address__c = addressRec[1].Id;
                        conList[1].AccountId = acc.Id;
                        conList[1].Recipient_Indicator__c = true;
                        conList[1].Billing_Indicator__c = true;
                        conList[1].Phone = '123456789';
                        conList[1].HomePhone = '123456789';
                        conList[1].Mobile_Number__c = '123456789';
                        conList[1].HomePhone__c = '123456789';
                        conList[1].Office_Number__c = '123456789';

                        conList[2].AccountId = acc.id;
                        conList[2].Address__c = addressRec[2].Id;
                        conList[2].AccountId = acc.Id;
                        conList[2].Recipient_Indicator__c = true;
                        conList[2].Billing_Indicator__c = true;
                        conList[2].Phone = '123456789';
                        conList[2].HomePhone = '123456789';
                        conList[2].Mobile_Number__c = '123456789';
                        conList[2].HomePhone__c = '123456789';
                        conList[2].Office_Number__c = '123456789';

                        conList[3].AccountId = acc.id;
                        conList[3].Address__c = addressRec[3].Id;
                        conList[3].AccountId = acc.Id;
                        conList[3].Recipient_Indicator__c = true;
                        conList[3].Billing_Indicator__c = true;
                        conList[3].Phone = '123456789';
                        conList[3].HomePhone = '123456789';
                        conList[3].Mobile_Number__c = '123456789';
                        conList[3].HomePhone__c = '123456789';
                        conList[3].Office_Number__c = '123456789';

                        conList[4].AccountId = acc.id;
                        conList[4].Address__c = addressRec[4].Id;
                        conList[4].AccountId = acc.Id;
                        conList[4].Recipient_Indicator__c = true;
                        conList[4].Billing_Indicator__c = true;
                        conList[4].Phone = '123456789';
                        conList[4].HomePhone = '123456789';
                        conList[4].Mobile_Number__c = '123456789';
                        conList[4].HomePhone__c = '123456789';
                        conList[4].Office_Number__c = '123456789';

                        Database.insert(conList);  
                        
                        
                        

                        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                        billAcc.Zuora__Account__c = acc.Id;
                        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
                        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
                        Database.insert(billAcc);  
                                                
                        //Package__c
                        List<Package__c> packList = TestDataFactory.createPackage(4);
                            for(Package__c pack : packList) {
                                pack.Billing_Type__c = 'Bill Plan';
                                pack.Package_Type__c = 'Base';
                                pack.Subscription_Period__c = '18';
                            }
                        packList[0].Package_Code__c = 'afds130';
                        packList[1].Package_Code__c = 'afds131';
                        packList[2].Package_Code__c = 'afds132';
                        packList[3].Package_Code__c = 'afds133';
                        Database.insert(packList);
                        
                        Order__c order = TestDataFactory.createOrder(1)[0];
                        order.Account__c = acc.Id;
                        order.Informed_Customer__c = TRUE;
                        order.Recipient_Contact__c = conList[0].Id;
                        order.Order_Type__c = 'Renewal';
                        order.Status__c = 'Draft';
                        order.Eligible_for_Retention__c = TRUE;
                        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                        order.Payment_Mode__c = 'Credit Card';
                        order.Billing_Account__c = billAcc.id;
                        order.Billing_Contact__c = conList[0].id;
                        order.Case_Record_Type__c = 'Complaint - Magazine';
                        order.Category__c = 'Subscription Request';
                        order.Sub_Category__c ='Stop Subscription';
                        order.Credit_Balance__c = 0;
                        order.Delivery_Charge__c = 0;
                        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                        order.Order_Type__c = 'Change of Subscription Package';
                        order.PO_Number__c = 'PO00000';
                        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
                        //order.Postage_Charge__c = 200.00;
                        Database.insert(order);   
                                    
                        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                        cas.Order__c = order.Id;
                        Database.insert(cas); 
                        
                        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
                        orderline[0].Order__c = order.Id;
                        orderline[0].End_Date__c = Date.Today().addDays(100);
                        orderline[0].Main_Package_ID__c = packList[0].Id;
                        orderline[0].Term_Length__c = 0;
                        orderline[0].Main_Package_Period__c = 0;
                        orderline[0].Start_Date__c = Date.Today().addDays(1);
                        orderline[0].Earliest_Start_Date__c = Date.today();
                        orderline[0].Earliest_Stop_Date__c = Date.Today().addDays(2);
                        orderline[0].Stop_Request_Date__c =  Date.Today().addDays(4);
                        orderline[0].Terminating_Reason__c = 'Others';
                        orderline[0].Amount_To_Refund__c = 0;
                        orderline[0].Admin_Charge__c = 0;
                        orderline[0].Fee_Waiver__c = TRUE;
                        orderline[0].Fee_Override__c = FALSE; //changed by JJZS
                        orderline[0].Override_Reason__c = 'TEST';
                        orderline[0].Suppress_Notification_Stop__c = TRUE;
                        orderline[0].Main_Package_Type__c = 'Base';
                        Database.insert(orderline);

                        // List<Order_Line_Item__c> oliList= TestDataFactory.createOrderLineItem(1);
                        // oliList[0].Order__c = order.id;
                        // oliList[0].Main_Package_ID__c = packList[1].Id;
                        // oliList[0].Is_Digital__c = true;
                        // oliList[0].Start_Date__c = Date.today().addDays(1);
                        // Database.insert(oliList);
                        Map<Id, Set<String>> contStringMap = new Map<Id, Set<String>>();
                        Map<Id, Contact> recipientContactMap = new Map<Id, Contact>();

                        List<Zuora__Subscription__c> subRecs = TestdataFactory.createSubscription(1);
                        subRecs[0].Zuora__CustomerAccount__c = billAcc.id;
                        subRecs[0].Zuora__Account__c = acc.Id;
                        subRecs[0].Zuora__Status__c = 'Active';
                        subRecs[0].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                        subRecs[0].Subscriber_Contact__c = conList[0].Id;
                        subRecs[0].Recipient_Contact__c = conList[0].Id;
                        subRecs[0].Billing_Type__c = 'Full Prepaid';
                        subRecs[0].Subscription_Type_1__c = 'Publication';
                        subRecs[0].Subscription_Type__c = 'Publication';
                        subRecs[0].Delivery_Charge_Type__c = 'H';
                        /*
                        subRecs[1].Zuora__CustomerAccount__c = billAcc.id;
                        subRecs[1].Zuora__Account__c = acc.Id;
                        subRecs[1].Zuora__Status__c = 'Active';
                        subRecs[1].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                        subRecs[1].Subscriber_Contact__c = conList[1].Id;
                        subRecs[1].Recipient_Contact__c = conList[1].Id;
                        subRecs[1].Billing_Type__c = 'Full Prepaid';
                        subRecs[1].Subscription_Type_1__c = 'Publication';
                        subRecs[1].Subscription_Type__c = 'Publication';
                        subRecs[1].Delivery_Charge_Type__c = 'S';

                        subRecs[2].Zuora__CustomerAccount__c = billAcc.id;
                        subRecs[2].Zuora__Account__c = acc.Id;
                        subRecs[2].Zuora__Status__c = 'Active';
                        subRecs[2].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                        subRecs[2].Subscriber_Contact__c = conList[2].Id;
                        subRecs[2].Recipient_Contact__c = conList[2].Id;
                        subRecs[2].Billing_Type__c = 'Full Prepaid';
                        subRecs[2].Subscription_Type_1__c = 'Publication';
                        subRecs[2].Subscription_Type__c = 'Publication';
                        subRecs[2].Delivery_Charge_Type__c = 'Z';

                        subRecs[3].Zuora__CustomerAccount__c = billAcc.id;
                        subRecs[3].Zuora__Account__c = acc.Id;
                        subRecs[3].Zuora__Status__c = 'Active';
                        subRecs[3].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                        subRecs[3].Subscriber_Contact__c = conList[3].Id;
                        subRecs[3].Recipient_Contact__c = conList[3].Id;
                        subRecs[3].Billing_Type__c = 'Full Prepaid';
                        subRecs[3].Subscription_Type_1__c = 'Publication';
                        subRecs[3].Subscription_Type__c = 'Publication';
                        subRecs[3].Delivery_Charge_Type__c = 'L';

                        subRecs[4].Zuora__CustomerAccount__c = billAcc.id;
                        subRecs[4].Zuora__Account__c = acc.Id;
                        subRecs[4].Zuora__Status__c = 'Active';
                        subRecs[4].Zuora__SubscriptionEndDate__c = date.today().addDays(30);
                        subRecs[4].Subscriber_Contact__c = conList[4].Id;
                        subRecs[4].Recipient_Contact__c = conList[4].Id;
                        subRecs[4].Billing_Type__c = 'Full Prepaid';
                        subRecs[4].Subscription_Type_1__c = 'Publication';
                        subRecs[4].Subscription_Type__c = 'Publication';
                        subRecs[4].Delivery_Charge_Type__c = 'C';
                        */
                        //subRecs.Main_Package_1__c = pack.id;*/
                        //subRecs.Zuora__Zuora_Id__c = '1123';
                        //subRecs.Order_Number__c = order.Id;
                        //subRecs.Suppress_Vendor_Start_Notice__c = 'false';
                        //subRecs.Supressed_Acknowledgement_Letter__c = 'false';
                        //subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                        //subRecs.Urgent__c = 'false';
                        //subRecs.Vendor_Conversion__c = 'false';
                        //Charity__c = 'false';
                        //subRecs.Order_Line_Item_Number__c = orderline.id;
                        //subRecs.Order_Number_1__c = order.id;
                        //subRecs.Order_Line_Item_Number_1__c = orderline.Id;
                        //subRecs.Generate_Invoice1__c = 'false';
                        //subRecs.Sponsor_1__c = false;
                        database.insert(subRecs);

                        for(Integer cc = 0; cc < subRecs.size(); cc++){
                            subRecsSet.add(subRecs[cc].Recipient_Contact__c);
                        }
                        
                        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                        zProduct.ProductCode__c = 'DELCHG';
                        zProduct.zqu__SKU__c = 'Product SKU';
                        Database.insert(zProduct);
                        
                        List<zqu__ProductRatePlan__c> prdRatePlanList = TestDataFactory.createProductRatePlan(4);
                        prdRatePlanList[0].Name = 'Zero Charge Amount';
                        prdRatePlanList[0].zqu__ZProduct__c = zProduct.Id;
                        prdRatePlanList[0].RatePlanType__c= 'Bill Plan';
                        prdRatePlanList[0].zqu__EffectiveStartDate__c= date.today();
                        prdRatePlanList[0].zqu__EffectiveEndDate__c= date.today().addDays(30);
                        prdRatePlanList[0].zqu__Deleted__c = false;

                        prdRatePlanList[1].Name = 'HDB Delivery Charge';
                        prdRatePlanList[1].zqu__ZProduct__c = zProduct.Id;
                        prdRatePlanList[1].RatePlanType__c= 'Bill Plan';
                        prdRatePlanList[1].zqu__EffectiveStartDate__c= date.today();
                        prdRatePlanList[1].zqu__EffectiveEndDate__c= date.today().addDays(30);
                        prdRatePlanList[1].zqu__Deleted__c = false;

                        prdRatePlanList[2].Name = 'APT Delivery Charge';
                        prdRatePlanList[2].zqu__ZProduct__c = zProduct.Id;
                        prdRatePlanList[2].RatePlanType__c= 'Bill Plan';
                        prdRatePlanList[2].zqu__EffectiveStartDate__c= date.today();
                        prdRatePlanList[2].zqu__EffectiveEndDate__c= date.today().addDays(30);
                        prdRatePlanList[2].zqu__Deleted__c = false;

                        prdRatePlanList[3].Name = 'Landed Delivery Charge';
                        prdRatePlanList[3].zqu__ZProduct__c = zProduct.Id;
                        prdRatePlanList[3].RatePlanType__c= 'Bill Plan';
                        prdRatePlanList[3].zqu__EffectiveStartDate__c= date.today();
                        prdRatePlanList[3].zqu__EffectiveEndDate__c= date.today().addDays(30);
                        prdRatePlanList[3].zqu__Deleted__c = false;

                        insert prdRatePlanList;

                        Set<Id> prpcSet = new Set<Id>();

                        List<zqu__ProductRatePlanCharge__c> prpcList = TestDataFactory.createProductRatePlanCharge(4);
                        prpcList[0].Name = 'test';
                        prpcList[0].zqu__ZuoraId__c = '123123';
                        prpcList[0].zqu__UOM__c = 'UOM';
                        prpcList[0].zqu__Type__c = 'One-Time';
                        //prpc.sum__c = 1010;
                        prpcList[0].zqu__ProductRatePlan__c = prdRatePlanList[0].Id;
                        prpcList[0].zqu__Deleted__c = false;

                        prpcList[1].Name = 'test1';
                        prpcList[1].zqu__ZuoraId__c = '123124';
                        prpcList[1].zqu__UOM__c = 'UOM';
                        prpcList[1].zqu__Type__c = 'One-Time';
                        //prpc.sum__c = 1010;
                        prpcList[1].zqu__ProductRatePlan__c = prdRatePlanList[1].Id;
                        prpcList[1].zqu__Deleted__c = false;

                        prpcList[2].Name = 'test2';
                        prpcList[2].zqu__ZuoraId__c = '123125';
                        prpcList[2].zqu__UOM__c = 'UOM';
                        prpcList[2].zqu__Type__c = 'One-Time';
                        //prpc.sum__c = 1010;
                        prpcList[2].zqu__ProductRatePlan__c = prdRatePlanList[2].Id;
                        prpcList[2].zqu__Deleted__c = false;

                        prpcList[3].Name = 'test3';
                        prpcList[3].zqu__ZuoraId__c = '123126';
                        prpcList[3].zqu__UOM__c = 'UOM';
                        prpcList[3].zqu__Type__c = 'One-Time';
                        //prpc.sum__c = 1010;
                        prpcList[3].zqu__ProductRatePlan__c = prdRatePlanList[3].Id;
                        prpcList[3].zqu__Deleted__c = false;

                        insert prpcList;

                        for(Integer i = 0; i < prpcList.size(); i++){
                            prpcSet.add(prpcList[i].Id);
                        }
                        

                        List<zqu__ProductRatePlanChargeTier__c> productRatePlanList = TestDataFactory.createProductRatePlanChargeTier(4);
                        productRatePlanList[0].zqu__Price__c = 10;
                        productRatePlanList[0].zqu__ProductRatePlanCharge__c = prpcList[0].id;
                        productRatePlanList[1].zqu__Price__c = 20;
                        productRatePlanList[1].zqu__ProductRatePlanCharge__c = prpcList[1].id;
                        productRatePlanList[2].zqu__Price__c = 30;
                        productRatePlanList[2].zqu__ProductRatePlanCharge__c = prpcList[2].id;
                        productRatePlanList[3].zqu__Price__c = 40;
                        productRatePlanList[3].zqu__ProductRatePlanCharge__c = prpcList[3].id;
                        
                        insert productRatePlanList;

                        List<zqu__ProductRatePlanCharge__c> prpcResult = [Select sum__c from zqu__ProductRatePlanCharge__c where Id IN : prpcSet];
                        System.assertEquals(10 ,prpcResult[0].sum__c);
                        System.assertEquals(20 ,prpcResult[1].sum__c);
                        System.assertEquals(30 ,prpcResult[2].sum__c);
                        System.assertEquals(40 ,prpcResult[3].sum__c);
                        /**
                        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                        prdRatePlan.Name = 'Zero Charge';
                        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                        prdRatePlan.RatePlanType__c= 'Bill Plan';
                        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
                        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                        prdRatePlan.zqu__Deleted__c = false;
                        insert prdRatePlan;

                        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                        prpc.Name = 'test';
                        prpc.zqu__ZuoraId__c = '123123';
                        prpc.zqu__UOM__c = 'UOM';
                        prpc.zqu__Type__c = 'One-Time';
                        //prpc.sum__c = 1010;
                        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                        prpc.zqu__Deleted__c = false;
                        insert prpc;
                        */
                        Product_Family__c prodFamily = TestDataFactory.createProductFamily(1)[0];
                        prodFamily.Product_Family__c = 'xy12nh76';
                        database.insert(prodFamily);
                        
                        List<Package_Item__c> pItem = TestDataFactory.createPackageItem(2,'Base Product');          
                        pItem[0].Package__c = packList[0].id;
                        pItem[0].Product_Rate_Plan__c = prdRatePlanList[0].id;
                        pItem[0].Name = 'Test Pack Item';
                        //pItem[0].Product_Family__c = prodFamily.id;
                        
                        pItem[1].Package__c = packList[0].id;
                        pItem[1].Product_Rate_Plan__c = prdRatePlanList[0].id;
                        pItem[1].Name = 'Test Pack Item';
                        //pItem[0].Product_Family__c = prodFamily.id;
                        Database.insert(pItem);
                        
                        //Promotion__c 
                        List<Promotion__c> promoTmp = TestDataFactory.createPromotion(4); 
                        promoTmp[0].Name = 'Promotions';
                        promoTmp[0].Contract_Period__c ='12';
                        promoTmp[0].Penalty_Charge__c = '100';
                        promoTmp[0].Promotion_Code__c = 'Code1';
                        
                        promoTmp[1].Name = 'Promotions1';
                        promoTmp[1].Contract_Period__c ='12';
                        promoTmp[1].Penalty_Charge__c = '100';
                        promoTmp[1].Promotion_Code__c = 'Code1';
                        
                        promoTmp[2].Name = 'Promotions2';
                        promoTmp[2].Contract_Period__c ='12';
                        promoTmp[2].Penalty_Charge__c = '100';
                        promoTmp[2].Promotion_Code__c = 'Code1';
                        
                        promoTmp[3].Name = 'Promotions3';
                        promoTmp[3].Contract_Period__c ='12';
                        promoTmp[3].Penalty_Charge__c = '100';
                        promoTmp[3].Promotion_Code__c = 'Code1';
                        Database.insert(promoTmp);    
                        
                        //Promotion_Package__c
                        List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(4);
                        promotionPackageList[0].Package_Name__c = packList[0].id;
                        promotionPackageList[0].Promotion__c = promoTmp[0].id;
                        
                        promotionPackageList[1].Package_Name__c = packList[1].id;
                        promotionPackageList[1].Promotion__c = promoTmp[1].id;
                        promotionPackageList[2].Package_Name__c = packList[2].id;
                        promotionPackageList[2].Promotion__c = promoTmp[2].id;
                        promotionPackageList[3].Package_Name__c = packList[3].id;
                        promotionPackageList[3].Promotion__c = promoTmp[3].id;
                        Database.insert(promotionPackageList);
                        
                        Eligibility_Rule__c eligibilityRule = new Eligibility_Rule__c();
                        eligibilityRule.Name = 'Test';
                        eligibilityRule.Action__c = 'Add';
                        eligibilityRule.Customer_Status__c = 'Existing Customer'; //'New customer';
                        eligibilityRule.Effective_End_Date__c = date.today().addDays(3);
                        eligibilityRule.Effective_Start_Date__c = date.today() ;
                        eligibilityRule.Contract_Subscription_Rule__c = 'Subscription End Date';
                        eligibilityRule.Condition__c = '>';
                        database.insert(eligibilityRule);
                        
                        Promotion_Eligibility_Rule__c promoEligibilityRule = new Promotion_Eligibility_Rule__c();
                        promoEligibilityRule.Eligibility_Rule__c= eligibilityRule.id;
                        promoEligibilityRule.Package_List__c = 'afds130';
                        promoEligibilityRule.Promotion__c = promoTmp[0].id;
                        promoEligibilityRule.Date__c = date.today().addDays(15);
                       // promoEligibilityRule.Days__c = '60';
                        database.insert(promoEligibilityRule);
                        
                        Zuora__SubscriptionProductCharge__c SubscriptionProductCharge= TestDatafactory.createSubscriptionProductCharge(1)[0];
                        SubscriptionProductCharge.Zuora__Subscription__c = subrecs[0].id;
                        SubscriptionProductCharge.Zuora__RatePlanName__c = 'Rate Plan';
                        SubscriptionProductCharge.Zuora__ProductSKU__c = 'Product SKU';
                        SubscriptionProductCharge.Zuora__Price__c = 1200;
                        database.insert(SubscriptionProductCharge);
                        
                        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
                        //SAF.Flag_Code__c = 'TEST';
                        SAF.Flag_Description__c = 'TESTx';
                        Database.insert(SAF);
                        
                        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
                        PAF.Package__c = packList[0].Id;
                        PAF.No_of_Concurrent_Users__c = 2;
                        PAF.Package_Service_Access_Flag__c = SAF.Id;
                        Database.insert(PAF);
                        
                        List<Asia1__c> tmpAsia1List = TestDataFactory.createAsiaOne(5);
                        List<Asia1__c> asiaListResult = new List<Asia1__c>();
                        Integer cnt = 0;
                        for(Asia1__c asiarec : tmpAsia1List){
                            asiarec.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
                            asiarec.Display_Name__c = 'Test';
                            asiarec.Email__c = 'test@email.com' ;
                            asiarec.Password__c = 'aBcD3Fg';
                            asiarec.Contact__c = conList[cnt].Id;
                            asiarec.Status__c = 'Pending Creation';
                            asiaListResult.add(asiarec);
                            cnt++;
                        }
                        
                        Database.insert(asiaListResult);


                        
                        List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
                        asiaSubList[0].Asia1__c = asiaListResult[0].Id;
                        asiaSubList[0].Subscription__c = subRecs[0].Id;
                        asiaSubList[0].Status__c = 'Pending Creation';
                        asiaSubList[0].Order_Line_Item__c = orderline[0].Id;
                        asiaSubList[0].Service_Access_Flag__c = SAF.Id;
                        Database.insert(asiaSubList); 
        
                        String promotionId = ''+promoTmp[0].id; 
                        String billingType = 'Bill Plan'; 
                        String accountId = ''+acc.id;
                        String action = 'Add';
                        Boolean isVendor = False;
                        Id subscriptionId = subRecs[0].id;
                        string ldapId = 'xxxxx@xxxx.xxxx';
                        string displayName = 'Test';
                        set<id> subscriptionIdSet = new set<id>();
                        subscriptionIdSet.add(subRecs[0].id);
                        id orderId = order.id;
                        boolean isAll = true;
                        id accountId2 = acc.id;
                        string billType = 'Full Prepaid';
                        String sId =  ''+packList[0].id;

                        for(Zuora__Subscription__c dctype : subRecs){
                            if(contStringMap.containsKey(dctype.Recipient_Contact__c)){
                                contStringMap.get(dctype.Recipient_Contact__c).add(dctype.Delivery_Charge_Type__c);
                            }else{
                                contStringMap.put(dctype.Recipient_Contact__c, new Set<String>{dctype.Delivery_Charge_Type__c});
                            }
                        }

                        for(Contact conAddType : [Select Id,
                                                    Address__r.Address_Type__c,
                                                    Address__c,
                                                    Recipient_Indicator__c,
                                                    Billing_Indicator__c,
                                                    Phone,
                                                    HomePhone,
                                                    Mobile_Number__c,
                                                    HomePhone__c,
                                                    Office_Number__c,
                                                    Address__r.RecordTypeId,
                                                    Address__r.RecordType.Name,
                                                    AccountId from Contact where Id IN: subRecsSet]){

                            recipientContactMap.put(conAddType.Id, conAddType);
                        }
                        

                        //System.assertEquals('A', checkCon.Address__r.Address_Type__c);
                        System.debug('&&&& conmap: ' + contStringMap);
                        System.debug('&&&& reconMap: ' + recipientContactMap);

                        Test.startTest();
                        SM_SubscriptionHelper.getOrderLineItem(orderline[0].Id);// orderline.Id;
                        SM_SubscriptionHelper.getOrderLineItems(orderline[0].Id);
                        SM_SubscriptionHelper.getCharges(conList[0].Id, 'N', 10, 10);
                        String serializedResult = SM_SubscriptionHelper.getRelatedPackages(promotionId, billingType, accountId, action, isVendor, subscriptionId);
                        SM_SubscriptionHelper.getRelatedPackagesOnProdFam(promotionId, billingType ,sId);
                        SM_SubscriptionHelper.registerAsia1Accounts(order.Id);
                        SM_SubscriptionHelper.validateAsia1Account(ldapId,displayName);
                        SM_SubscriptionHelper.mapSubscriptionToAsia1Subscription(subscriptionIdSet);
                        SM_SubscriptionHelper.getChargesForRenewalLetter(contStringMap, recipientContactMap);
                        SM_SubscriptionHelper.deleteRelatedOrderLineItemRelatedObjects(orderline[0].Id);       
                        SM_SubscriptionHelper.getDtlDate();
                        SM_SubscriptionHelper.getEarliestStartDate(packList[0].Id);
                        //SM_SubscriptionHelper.deleteRelatedOrderLineItemRelatedObjects(orderId,isAll,lstAsia1Wrapper);
                        SM_SubscriptionHelper.checkExistingInvoice(accountId2,billType);
                        List<RelatedPackageWrapper> rpwList = (List<RelatedPackageWrapper>)System.JSON.deserialize(serializedResult, List<RelatedPackageWrapper>.class);      
                        SM_SubscriptionHelper.getAsia1s(asiaSubList);
                        SM_SubscriptionHelper.createAsia1Subscription(SM_SubscriptionHelper.getAsia1s(asiaSubList), orderline[0].Id);
                        SM_SubscriptionHelper.createAsia1SubscriptionFromAccessFlag('test1@sample.com', asiaListResult[0].Id, packList[0].Id);
                        //System.assertEquals(4, rpwList.size());
                        Test.stopTest();
                 }
            }

   
}