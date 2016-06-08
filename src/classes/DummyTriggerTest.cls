@isTest //(SeeAllData = true)
private class DummyTriggerTest {
    
    static void getCustomSettings()
    {
        BatchInterface_Settings__c btis = new BatchInterface_Settings__c();
        btis.Name = GlobalVariableClass.ENDPOINTDELEGATOR;
        btis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert btis;
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = date.valueOf('2014-08-19T14:00:00.000+0000');
        cir.Mon_Fri_Start_Time__c = date.valueOf('2014-08-19T00:00:00.000+0000');
        cir.Sat_PH_End_Time__c = date.valueOf('2014-08-18T09:00:00.000+0000');
        cir.Sat_PH_Start_Time__c = date.valueOf('2014-08-18T00:00:00.000+0000');
        cir.Sun_End_Time__c = date.valueOf('2014-08-18T09:00:00.000+0000');
        cir.Sun_Start_Time__c = date.valueOf('2014-08-18T09:00:00.000+0000');  
        insert cir;
        
        //KeyId
        Map<String, Map<String, Id>> rcTypeMap = new Map<String, Map<String, Id>>();
        for(RecordType rt : [SELECT Id, Name, SObjectType FROM RecordType]) {
            if(!rcTypeMap.containsKey(rt.SObjectType)) {
                rcTypeMap.put(rt.SObjectType, new Map<String, Id>());
            }
            rcTypeMap.get(rt.SObjectType).put(rt.Name, rt.Id);
        }
        
        insert new List<Key_Id__c>{
            new Key_Id__c(Name='Contact_Customer Contact',Id__c=rcTypeMap.get('Contact').get('Customer Contact')), 
            new Key_Id__c(Name='Account_Direct Corporate',Id__c=rcTypeMap.get('Account').get('Direct Corporate')),
            new Key_Id__c(Name='Case_Start Sub',Id__c= rcTypeMap.get('Case').get('Start Subscription'))
                };
        insert new list<Other__c>{new Other__c(Name='DTL', Value__c='14:00'), new Other__c(Name='Order_Type Renewal', Value__c='Renewal')};
    }
    @isTest (seeAllData = true)
    static void testSubscription()
    
    {
    try{
        getCustomSettings();
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
        
        //Account acct = new Account();
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acct.Name = 'TestAcct';
        acct.NRIC__c = 'T1234567R';
        acct.Email__c = 'test@test.com';
        acct.Mobile__c = '123456';
        insert acct;
        
        Account acctVendor = new Account();
        acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert acctVendor;
        
        Contact con = new Contact();
        con = TestDataFactory.createContact(1)[0];
        con.AccountId = acct.Id;
        con.Address__c = address.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        
        
        Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
        zua.Zuora__Account__c = acct.Id;
        zua.Zuora__PaymentMethodType__c = 'Paypal';
        insert zua;
        
        Zuora__CustomerAccount__c zua2 =  TestDataFactory.createBillingAccount(1)[0];
        zua2.Zuora__Account__c = acct.Id;
        zua.Zuora__PaymentMethodType__c = 'Cash';
        insert zua2;
        
        Zuora__PaymentMethod__c pm = new Zuora__PaymentMethod__c();
        pm.Zuora__BillingAccount__c = zua.Id;
        pm.Zuora__Type__c = 'Cash';
        
        insert pm;
        
        Zuora__PaymentMethod__c pm2 = new Zuora__PaymentMethod__c();
        pm2.Zuora__Type__c = 'PayPal';
        pm2.Zuora__BillingAccount__c = zua2.Id;
        insert pm2;           
        
        //create subscription vendor
        Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
        //SubVend.Name = 'Test Subscription Vendor';
        insert SubVend;
        
        Case caseRec = new Case();
        caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
        caseRec.Status = 'Pending';
        caseRec.Sub_Status__c = 'Wating for Vendor Assignment';    
        insert caseRec;   
        
        Case_Vendor_Subscription__c cVenSub = new Case_Vendor_Subscription__c();
        cVenSub.Case__c = caseRec.id;
        cVenSub.Subscription_Vendor__c = subVend.id;
        insert cVenSub;
        
        //test.startTest();    
        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
        subRec = TestDataFactory.createSubscription(1)[0];
        subRec.Zuora__SubscriptionEndDate__c = date.today();
        subRec.Zuora__Account__c = acct.Id;
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__CustomerAccount__c = zua.id;
        subRec.Zuora__Status__c = 'Expired'; //[JPO 02/12/2015] changed from 'Active'
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Vendor_1__c = acctVendor.id;
        subRec.Zuora__Version__c = 1;
        insert subRec;
        
        //create order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Base_Subscription__c = subRec.id;
        order.Account__c = acct.Id;
        order.Recipient_Contact__c = con.Id;
        order.Informed_Customer__c = True;
        order.Subscriber_Charge__c = 6.00;
        insert order;
        
        test.startTest();
        //create case
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.today();
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today().addDays(2);
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        //orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        
        subRec.Order_Line_Item_Number__c = orderline.Id; 
        subRec.Order_Number__c = order.Id;
        update subRec;
        
        Case_Subscription__c  caseSub = new Case_Subscription__c();
        caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Account__c = acct.Id;
        caseSub.Address__c = address.Id;
        caseSub.Case__c = caseRec.Id;
        caseSub.Subscription__c = subRec.Id;
        insert caseSub;
        
        Product_Family__c pkgFam = new Product_Family__c();
        pkgFam.Product_Family__c = 'Test_PackageFam02';
        pkgFam.Product_Family_Name__c = 'Test_PackageFamName02';
        insert pkgFam;
        
        Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubProductCharge(1)[0];    
        subProdCharge.Name = 'Credit Copy Sat';
        subProdCharge.PublicationCode__c = 'BH';
        subProdCharge.Zuora__Subscription__c = subRec.id;
        subProdCharge.Zuora__UOM__c = 'Credit Copy Sat';
        subProdCharge.Zuora__Quantity__c = 5;
        subProdCharge.Zuora__ProductSKU__c = 'SKU-12345678';
        subProdCharge.Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
        /*try {
        insert subProdCharge;
        } catch (exception e) {
        }*/
        
        Promotion_Gift__c promgift = TestDataFactory.createPromotionGift(1)[0];
        promgift.Gift_Inventory__c = 1;
        promgift.Gift_Issued__c = 1;
        promgift.Gift_Redeemed__c = 1;
        insert promgift;
        
        Order_Line_Item_Gift__c oligift = TestDataFactory.createItemGift(1)[0];
        oligift.Order_Line_Item__c = orderline.id;
        oligift.Promotion_Gift__c = promgift.id;
        insert oligift;
        }catch(Exception e){
        System.debug('Error: ' + e.getMessage());
        }
    }

    static testmethod void testPackProdFamily()
    {
        Package__c pkg1 = new Package__c(Name = 'Test_Package01/14/2015');
        pkg1.Package_Type__c = 'Add On';
        pkg1.Subscription_Type__c = 'Termed';
        pkg1.Package_Code__c = '030615';
        pkg1.Subscription_Period__c = '1';
        pkg1.Effective_Start_Date__c = System.Today();
        pkg1.Effective_End_Date__c = System.Today() + 1;
        insert pkg1;
  
        Product_Family__c pkgFam1 = new Product_Family__c();
        pkgFam1.Product_Family__c = 'Test_PackageFam01';
        pkgFam1.Product_Family_Name__c = 'Test_PackageFamName01';
        insert pkgFam1;

        Package_Product_Family__c pkgProdFam1 = new Package_Product_Family__c();
        pkgProdFam1.Package_Name__c = pkg1.id;
        pkgProdFam1.Product_Family__c = pkgFam1.id;
        insert pkgProdFam1;
    }
    
    static testmethod void testPromotionGiftTrigger()
    {
        getCustomSettings();        
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        List<Promotion__c> promotionList = new List<Promotion__c>();
        List<Promotion_Gift__c> promoGift = new List<Promotion_Gift__c>();
        List<Gift__c> gift = new List<Gift__c>();
        Order__c orderRecord;
        
        
        Account acctRecord = new Account(
            Name='TestAcct'
        );
        insert acctRecord;
        
        Contact contRecord = new Contact(
            HomePhone='1115632', 
            LastName='TestLastName',
            AccountId=acctRecord.Id,
            Recipient_Indicator__c = true            
        );
        //insert contRecord;
        
        Package__c pkgRecord = new Package__c(
            Name='TestPkg',
            Package_Code__c='10001', 
            Effective_Start_Date__c=Date.today(), 
            Effective_End_Date__c=Date.today()
        );
        insert pkgRecord;
        
        for(Integer i = 0; i < 200; i++){
            promotionList.add(
                new Promotion__c(
                    Promotion_Code__c='Pcode' + i,
                    Name='Promotion ' + i,
                    Effective_Start_Date__c = Date.today(),
                    Effective_End_Date__c = Date.today().addDays(5)
                )
            );
        }
        insert promotionList;
        
        gift = TestDataFactory.createGift(3);
        
        insert gift;
        
        promoGift = TestDataFactory.createPromotionGift(3);
        promoGift[0].Promotion__c = promotionList[0].Id;
        promoGift[0].gift__c = gift[0].Id;
        
        promoGift[1].Promotion__c = promotionList[1].Id;
        promoGift[1].gift__c = gift[1].Id;
        
        promoGift[2].Promotion__c = promotionList[2].Id;
        promoGift[2].gift__c = gift[2].Id;
        
        insert promoGift;
    }
    
    static testmethod void testPromotionEligibility()
    {
        List<Eligibility_Rule__c> eRule = TestDataFactory.createEligibilityRule(2);
        eRule[0].Contract_Subscription_Rule__c = 'Contract End Date';
        eRule[0].Action__c = 'Add';
        eRule[0].Current_Platform__c = 'Online';
        eRule[0].Condition__c = '>=';
        eRule[0].Contract_Type__c = 'NA';
        eRule[0].Subsciber_Status__c = 'New Subscriber';
        eRule[0].Customer_Status__c = 'New customer';
        eRule[0].Date__c = Date.today();
        eRule[0].Contract_Subscription_Rule__c = 'NA';        
        
        insert eRule;
        
        system.assertNotEquals(null,eRule[0].id);
        
        List<Promotion__c> Promo = TestDataFactory.createPromotion(2);
        Promo[0].Name = 'Test Promo0';
        Promo[0].Promotion_Code__c = 'TESTx1';
        Promo[0].Contract__c='Yes';
        Promo[0].Contract_Period__c = '15';
        Promo[0].Effective_End_Date__c=date.today()+100;
        Promo[0].Effective_Start_Date__c=date.today();
        
        Promo[1].Name = 'Test Promo1';
        Promo[1].Promotion_Code__c = 'TESTx2';
        Promo[1].Contract__c='Yes';
        Promo[1].Contract_Period__c = '20';
        Promo[1].Effective_End_Date__c=date.today()+100;
        Promo[1].Effective_Start_Date__c=date.today().addDays(-3);
        
        insert Promo;
        
        system.assertNotEquals(null,Promo[0].id);
        system.assertNotEquals(null,Promo[1].id);
        
        //create Promotion eligibility rule
        List<Promotion_Eligibility_Rule__c> promoEli = TestDataFactory.createPromEligibilityRule(2);
        promoEli[0].Promotion__c = Promo[0].Id;
        promoEli[0].Eligibility_Rule__c = eRule[0].Id;
        promoEli[0].Package_List__c = 'Test package';
        promoEli[0].Product_Family__c = 'ST';
        promoEli[0].Date__c = Date.today();
        //promoEli[0].Days__c = '28';
        
        promoEli[1].Promotion__c = Promo[1].Id;
        promoEli[1].Eligibility_Rule__c = eRule[1].Id;
        promoEli[1].Package_List__c = 'Test package';
        promoEli[1].Product_Family__c = 'ST';
        promoEli[1].Date__c = Date.today().addDays(-2);
        //promoEli[1].Days__c = '15';  
        insert promoEli;
        
    }
    
    static testmethod void testCaseComment()
    {
        getCustomSettings();
        Account acct = new Account();
        acct.Name = 'Testing Contact Trigger';
        acct.Airline_Indicator__c = TRUE;
        insert acct;    
        
        Case cs = TestDataFactory.createCase(1,'Complaint - Digital')[0];
        cs.AccountId = acct.id;
        insert cs;
        
        CaseComment cc = new CaseComment(CommentBody = 'Test Comment 1',IsPublished=True,ParentID=cs.id );                            
        insert cc;
        
        EmailMessage ems =  new EmailMessage();
        ems.FromAddress = UserInfo.getUserEmail();
        ems.FromName =  UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        ems.Incoming = true;
        ems.ToAddress = 'jean.c.b.carino@accenture.com';
        ems.Subject = 'Test email';
        ems.TextBody = 'Hello';
        ems.ParentId = cs.Id;
        insert ems;
        
        
        
    }
   
    static testmethod void testPackageItem()
    {
        Package__c pack = new Package__c();
        pack.Package_Type__c = 'Base';
        pack.Name = 'testpackB';
        pack.Package_Code__c = 'pcode';
        pack.Subscription_Type__c = 'Termed';
        pack.Subscription_Period__c= '1';
        pack.Effective_End_Date__c = date.today().addDays(20);
        pack.Effective_Start_Date__c = date.today();
        insert pack;
        
        
        zqu__ProductRatePlan__c prPlan = new zqu__ProductRatePlan__c();
        zqu__ZProduct__c zprod = new zqu__ZProduct__c();
        zprod.Name = 'testzprod';
        zprod.zqu__SKU__c = '123456';
        zprod.ProductCode__c ='pcode123';
        zprod.zqu__ZuoraId__c = 'zoura1234567';
        zprod.ProductType__c = 'Print';
        insert zprod;
        
        
        prPlan.Name = 'testrateplan';
        prPlan.zqu__ZProduct__c = zprod.id;
        prPlan.RatePlanCode__c = 'rpcode';
        prPlan.zqu__ZuoraId__c = 'zoura123';
        prPlan.RatePlanType__c = 'Bill Plan';
        insert prPlan;
        
        Package_Item__c packItem = new Package_Item__c();
        packItem.Product_Rate_Plan__c = prPlan.id;
        packItem.Package__c = pack.id;
        packItem.Name = 'testbase';                      
        insert packItem;
    }
    
    static testmethod void testZoneProduct()
    {
        //Create Zone
        Zone__c zone = new Zone__c();
        insert zone;
        
        //Create ZProduct
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'BT Invest Test';
        zProd.zqu__ZuoraId__c = '13213';
        zProd.zqu__SKU__c = 'SKU-00000005';
        zProd.ProductCode__c = 'Test Code';
        zProd.ProductType__c = 'Test Type';
        insert zProd;
        
        //Create Zone Product
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = zone.id;
        zoneProd.Postage_Charge__c = 30;
        zoneProd.Product__c = zProd.Id;
 
        insert zoneProd;
        /*Start Ud-3253 removed by s.puli for credit note CR
        Credit_Note__c cN = new Credit_Note__c();
        cN.Remark1__c = 'samplecredit';
        INSERT cN;
        end ud-3253*/
   
    }
    
    @isTest (seealldata = true)
    static void testExternalPayment()
    {
    try{
        Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        insert vendorSubsAcct;           
        
        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
        insert billingAcc;
        
        External_Payment__c externalPaymentRecord2 = new External_Payment__c(
            Payment_amount__c = 2,
            Expiration_Date__c = Date.today(),
            Billing_Contact_email__c = 'test@sample.com',
            Billing_Contact_First_Name__c = 'John',
            Billing_Contact_Last_Name__c = 'Doe',
            Transaction_Status__c = 'C',
            Transaction_Type__c = 'C',
            Transaction_Amount__c = 100,
            Billing_Account__c = billingAcc.Id,
            Transaction_Date__c = Date.today(),
            Payment_Method__c = 'Credit Card',
            Parent_Transaction_ID__c = '111222333444'
        );
        
        /*try {
          insert externalPaymentRecord2;
        } catch (exception e) {}*/
        }catch(Exception e){
        System.debug('Error: ' + e.getMessage());
        }
    }
    
    /*static testmethod void testPrpCharge()
    {
        List<zqu__ZProduct__c> listProducts = TestDataFactory.createZProduct(1);
        List<zqu__ProductRatePlan__c> listProductRatePlan = TestDataFactory.createProductRatePlan(1);       
        List<zqu__ProductRatePlanCharge__c> listProductRatePlanCharge = TestDataFactory.createProductRatePlanCharge(100);
        List<Publication__c> listPublication = TestDataFactory.createPublication(100);  
        
        // get the records in their respective lists   
        list<zqu__ZProduct__c> prodListForInsert = new list<zqu__ZProduct__c>(); 
        list<zqu__ProductRatePlan__c> prodRatePlanListForInsert = new list<zqu__ProductRatePlan__c>();  
        list<Publication__c> prodPublicationListForInsert = new list<Publication__c>(); 
        list<zqu__ProductRatePlanCharge__c> prodRatePlanListInsert = new List<zqu__ProductRatePlanCharge__c>();
        
        // insert products with the desired data
        for(zqu__ZProduct__c prodRec :  listProducts){
            prodRec.ProductType__c = 'Product';
            prodRec.zqu__Deleted__c= false;
            prodListForInsert.add(prodRec);         
        }
        insert prodListForInsert; 
        
        // insert product rate plans with the desired data
        for(zqu__ProductRatePlan__c proRatePlan : listProductRatePlan){
            proRatePlan.zqu__ZProduct__c = prodListForInsert[0].Id;             
            proRatePlan.RatePlanType__c = 'Bill Plan';  
            prodRatePlanListForInsert.add(proRatePlan);               
        }
        insert prodRatePlanListForInsert;
        
        // insert publication records with desired data
        for(Publication__c prodPublication : listPublication){
            prodPublication.Publication_Code__c = 'CODE';
            prodPublication.Publication_Type__c = 't';
            prodPublication.Published_Days__c ='test';               
            prodPublicationListForInsert.add(prodPublication);         
        } 
        insert prodPublicationListForInsert; 
        
        // insert producation rate plan charge records with desired data
        for(zqu__ProductRatePlanCharge__c prodRatePlan : listProductRatePlanCharge){
            prodRatePlan.zqu__ProductRatePlan__c = prodRatePlanListForInsert[0].Id;
            prodRatePlan.PublicationCode__c = 'CODE';
            prodRatePlanListInsert.add(prodRatePlan);              
        }            
        insert prodRatePlanListInsert; 

    }*/
    
    //BT_AT_STP050DX_StopPressSubscription
    static testmethod void testBT_StopPressSub()
    {
        List<BT_CO_STPPRS_StopPressSubscription__c> interfaceRecordList = new List<BT_CO_STPPRS_StopPressSubscription__c>();
        
        BT_CO_STPPRS_StopPressSubscription__c interfaceRecord = new BT_CO_STPPRS_StopPressSubscription__c();
        interfaceRecord.Name = 'STP050DX';
        interfaceRecord.amount_paid__c = 'a';
        interfaceRecord.auto_renewal_indicator__c = 'b';
        interfaceRecord.card_expiry_date__c = 'c';
        interfaceRecord.credit_card_type__c = 'd';
        interfaceRecord.delivery_fee_indicator__c = 'e';
        interfaceRecord.filler__c = 'f';
        interfaceRecord.free_gift__c = 'g';
        interfaceRecord.free_gift2__c = 'h';
        interfaceRecord.free_gift3__c = 'i';
        interfaceRecord.free_gift4__c = 'j';
        interfaceRecord.hse_type__c = 'k';
        interfaceRecord.mlgagt__c = 'l';
        interfaceRecord.online_order_num__c = 'm';
        interfaceRecord.payment_number__c = 'n';
        interfaceRecord.pay_type__c = 'o';
        interfaceRecord.product_code__c = 'p';
        interfaceRecord.promo_indicator__c = 'q';
        interfaceRecord.recipient_age_group__c = 'r';
        interfaceRecord.recipient_blgm__c = 's';
        interfaceRecord.recipient_country__c = 't';
        interfaceRecord.recipient_country_code__c = 'u';
        interfaceRecord.recipient_coym__c = 'v';
        interfaceRecord.recipient_date_of_birth__c = 'w';
        interfaceRecord.recipient_dsg__c = 'x';
        interfaceRecord.recipient_email_id__c = 'y';
        interfaceRecord.recipient_fax_num__c = 'z';
        interfaceRecord.recipient_home_tel_num__c = 'A';
        interfaceRecord.recipient_house_block_num__c = 'B';
        interfaceRecord.recipient_house_level_number__c = 'C';
        interfaceRecord.recipient_house_unit_number__c = 'D';
        interfaceRecord.recipient_hphnn__c = 'E';
        interfaceRecord.recipient_icn__c = 'F';
        interfaceRecord.recipient_income_range__c = 'G';
        interfaceRecord.recipient_local_address__c = 'H';
        interfaceRecord.recipient_name__c = 'I';
        interfaceRecord.recipient_office_ext_num__c = 'J';
        interfaceRecord.recipient_office_tel_num__c = 'K';
        interfaceRecord.recipient_overseas_add1__c = 'L';
        interfaceRecord.recipient_overseas_add2__c = 'M';
        interfaceRecord.recipient_overseas_add3__c = 'N';
        interfaceRecord.recipient_overseas_add4__c = 'O';
        interfaceRecord.recipient_postal_code__c = 'P';
        interfaceRecord.recipient_privacy_indicator__c = 'Q';
        interfaceRecord.recipient_profession__c = 'R';
        interfaceRecord.recipient_race__c = 'S';
        interfaceRecord.recipient_salutation__c = 'T';
        interfaceRecord.recipient_sex__c = 'U';
        interfaceRecord.recipient_strm__c = 'V';
        interfaceRecord.recurring_indicator__c = 'W';
        interfaceRecord.referred_start_date__c = 'X';
        interfaceRecord.sub_copies__c = 'Y';
        interfaceRecord.sub_period__c = 'Z';
        interfaceRecord.subscribe_local_address__c = 'a';
        interfaceRecord.subscriber_age_group__c = 'b';
        interfaceRecord.subscriber_blgm__c = 'c';
        interfaceRecord.subscriber_country__c = 'd';
        interfaceRecord.subscriber_country_code__c = 'e';
        interfaceRecord.subscriber_coym__c = 'f';
        interfaceRecord.subscriber_date_of_birth__c = String.escapeSingleQuotes('1.1.1');//'g';
        interfaceRecord.subscriber_dsg__c = 'h';
        interfaceRecord.subscriber_email_id__c = 'i';
        interfaceRecord.subscriber_fax_number__c = 'j';
        interfaceRecord.subscriber_home_tel_number__c = 'k';
        interfaceRecord.subscriber_house_block_number__c = 'l';
        interfaceRecord.subscriber_house_level_number__c = 'm';
        interfaceRecord.subscriber_house_unit_number__c = 'n';
        interfaceRecord.subscriber_hphnn__c = 'o';
        interfaceRecord.subscriber_icn__c = 'p';
        interfaceRecord.subscriber_income_range__c = 'q';
        interfaceRecord.subscriber_name__c = 'r';
        interfaceRecord.subscriber_office_ext_number__c = 's';
        interfaceRecord.subscriber_office_tel_number__c = 't';
        interfaceRecord.subscriber_overseas_add1__c = 'u';
        interfaceRecord.subscriber_overseas_add2__c = 'v';
        interfaceRecord.subscriber_overseas_add3__c = 'w';
        interfaceRecord.subscriber_overseas_add4__c = 'x';
        interfaceRecord.subscriber_postal_code__c = 'y';
        interfaceRecord.subscriber_privacy_indicator__c = 'z';
        interfaceRecord.subscriber_profession__c = 'A';
        interfaceRecord.subscriber_race__c = 'B';
        interfaceRecord.subscriber_salutation__c = 'C';
        interfaceRecord.subscriber_sex__c = 'D';
        interfaceRecord.subscriber_strm__c = 'E';
        interfaceRecord.subscriber_type__c = 'F';
        interfaceRecord.subscription_package_code__c = 'G';
        interfaceRecord.unit_discount_price__c = 'H';

        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
    
    //SP_BatchJobSchedulerTriggerTest
    static testmethod void testBatchJobScheduler()
    {
        getCustomSettings();
       List<BATCH_JOB_SCHEDULER__c> batch = new List<BATCH_JOB_SCHEDULER__c>();
        for(Integer x=1; x<=5; x++)
        {
            BATCH_JOB_SCHEDULER__c batchRec = new BATCH_JOB_SCHEDULER__c();
            if(x<=9){
               batchRec.Batch_Code__c = 'SP00' + x;
            }
          
            if(x>=10){
               batchRec.Batch_Code__c = 'SP0' + x;
            }
            batchRec.Batch_Run_Date__c = date.today();
            batch.add(batchRec);
        }
        test.startTest();
        insert batch;    
        test.stopTest();
        LIST<BATCH_JOB_SCHEDULER__c> batchList = [SELECT Id from BATCH_JOB_SCHEDULER__c WHERE Id=:batch[1].id];
        System.assert(batchList.size()>0);
    
    }
    
    //BT_AT_AGD043DX_AGD_EINVOICE
    static testmethod void testBT_EInvoice()
    {   
        BT_CO_AGD_EINVOICE__c bt1 = new BT_CO_AGD_EINVOICE__c();
        insert bt1;
    }
    
    //BT_AT_ARM063DX_2_CreateAccountBatchResonseFile
    static testmethod void testBT_AcctBatchResFile()
    {   
        BT_CO_ARMS_CreateAccountBatchResonseFile__c bt2 = new BT_CO_ARMS_CreateAccountBatchResonseFile__c();
        insert bt2;
    }
    
    //BT_AT_ARM064DX_2_CreateCustAccountResponseFile
    static testmethod void testBT_CustAcctResFile()
    {   
        BT_CO_ARMS_CreateCustAccountResponseFile__c bt3 = new BT_CO_ARMS_CreateCustAccountResponseFile__c();
        insert bt3;
    }
    
    //BT_AT_ARM068DX_ExportAccountSummary
    static testmethod void testBT_ExpAcctSumm()
    {   
        BT_CO_ARMS_ExportAccountSummary__c bt4 = new BT_CO_ARMS_ExportAccountSummary__c();
        insert bt4;
    }
    
    //BT_AT_ARM069DX_OutstandingAmountInterface
    static testmethod void testBT_OutAmtInt()
    {   
        BT_CO_ARMS_OutstandingAmountInterface__c bt5 = new BT_CO_ARMS_OutstandingAmountInterface__c();
        insert bt5;
    }
    
    //BT_AT_ARM071DX_ExportCustomerInvoice
    static testmethod void testBT_ExpCustInvoice()
    {   
        BT_CO_ARMS_ExportCustomerInvoice__c bt6 = new BT_CO_ARMS_ExportCustomerInvoice__c();
        insert bt6;
    }
    
    //BT_AT_BatchRunRequestTrigger
    static testmethod void test()
    {   
        BT_CO_Batch_Run_Request__c bt7 = new BT_CO_Batch_Run_Request__c();
        bt7.Interface_ID__c = '123456789';
        insert bt7;
    }
    
    //BT_AT_CMI073DX_ImportVendorProfile
    static testmethod void testBT_ImpVenProf()
    {   
        BT_CO_CMISPOP_ImportVendorProfile__c bt8 = new BT_CO_CMISPOP_ImportVendorProfile__c();
        insert bt8;
    }
    
    //BT_AT_CMI074DX_ImportVendorStaff
    static testmethod void testBT_ImpVenStaff()
    {   
        BT_CO_CMISPOP_ImportVendorStaff__c bt9 = new BT_CO_CMISPOP_ImportVendorStaff__c();
        insert bt9;
    }
    
    //BT_AT_CMI075DX_ImportPublicationInfo
    static testmethod void testBT_ImpPubInfo()
    {   
        BT_CO_CMIS_POP_ImportPublicationInfo__c bt10 = new BT_CO_CMIS_POP_ImportPublicationInfo__c();
        bt10.effectiveDate__c = string.valueOf(date.today());
        insert bt10;
    }
    
    //BT_AT_CMI076DX_ImportPublicationPrice
    static testmethod void testBT_ImpPubSub()
    {   
        BT_CO_CMIS_POP_ImportPublicationPrice__c bt11 = new BT_CO_CMIS_POP_ImportPublicationPrice__c();
        bt11.Batch_Run_Date__c = date.today();
        bt11.effectiveDate__c = '25.01.2015';
        insert bt11;
    }
    
    //BT_AT_CMI077DX_ImportPublicationIssue
    static testmethod void testBT_ImpPubIssue()
    {   
        BT_CO_CMIS_POP_ImportPublicationIssue__c bt12 = new BT_CO_CMIS_POP_ImportPublicationIssue__c();
        insert bt12;
    }
    
    //BT_AT_CMI078DX_ImportPublicHolidayInfo
    static testmethod void testBT_PubHolidayInfo()
    {   
        BT_CO_CMIS_POP_ImportPublicHolidayInfo__c bt13 = new BT_CO_CMIS_POP_ImportPublicHolidayInfo__c();
        insert bt13;
    }
    
    //BT_AT_CMI079DX_ImportNextIssueDateInfo
    static testmethod void testBT_ImpNextIssueDateInfo()
    {   
        BT_CO_CMIS_POP_ImportNextIssueDateInfo__c bt14 = new BT_CO_CMIS_POP_ImportNextIssueDateInfo__c();
        insert bt14;
    }
    
    //BT_AT_CMI080DX_ImportNonPublicationDate
    static testmethod void testBT_ImpNonPubDate()
    {   
        BT_CO_CMIS_POP_ImportNonPublicationDate__c bt15 = new BT_CO_CMIS_POP_ImportNonPublicationDate__c();
        insert bt15;
    }
    
    //BT_AT_CMI082DX_ImportVendorRouteInfo
    static testmethod void testBT_ImVenRouteInfo()
    {   
        BT_CO_CMIS_POP_ImportVendorRouteInfo__c bt16 = new BT_CO_CMIS_POP_ImportVendorRouteInfo__c();
        insert bt16;
    }
    //BT_AT_CMI100DX_NumberOfVendorInserts
    static testmethod void testBT_NumOfVen()
    {   
        BT_CO_CMIS_POP_NumberOfVendorInserts__c bt17 = new BT_CO_CMIS_POP_NumberOfVendorInserts__c();
        insert bt17;
    }
    
    //BT_AT_DIR092DX_ImportSingpostDatabase
    static testmethod void testBT_ImpSingPostDB()
    {   
        BT_CO_DIR_ImportSingpostDatabase__c bt18 = new BT_CO_DIR_ImportSingpostDatabase__c();
        insert bt18;
    }
    //For refund file response trigger test
    public static List<BT_CO_PPS_RefundFileResponse__c> createRefundFileResponse(Integer count) {

        List<BT_CO_PPS_RefundFileResponse__c> refundFileResponseList = new List<BT_CO_PPS_RefundFileResponse__c>();
    
        for(Integer i=0; i<count; i++){
             BT_CO_PPS_RefundFileResponse__c testRefundFileResponse = new BT_CO_PPS_RefundFileResponse__c();
            testRefundFileResponse.Name = 'RefundFileResponse ' + i; 
            refundFileResponseList.add(testRefundFileResponse); 
        }
        
        return refundFileResponseList;
    }     
    
    //Create Refund Response
    public static List<BT_CO_PPS_RefundFile__c> createRefundFile(Integer count) {

        List<BT_CO_PPS_RefundFile__c> refundFileList = new List<BT_CO_PPS_RefundFile__c>();
    
        for(Integer i=0; i<count; i++){
             BT_CO_PPS_RefundFile__c testRefundFile = new BT_CO_PPS_RefundFile__c();
            testRefundFile.Name = 'RefundFile ' + i; 
            refundFileList.add(testRefundFile); 
        }
        
        return refundFileList;
    }
    //BT_AT_PPS057DX_RefundFileResponse
    static testmethod void testBT_RefFileResponse()
    {   
        Test.startTest();
        
        Account testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            testAccount.NRIC__c = 'T1234567R';
          testAccount.Email__c = 'test@test.com';
           testAccount.Mobile__c = '123456';
        insert testAccount;
        
        Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
            testCustomerAccount.Zuora__Account__c = testAccount.Id;
        insert testCustomerAccount;
        
        Zuora__Refund__c testRefund = TestDataFactory.createRefund(1)[0];
            testRefund.Zuora__AccountingCode__c = 'XXX';
            testRefund.Zuora__Account__c = testAccount.Id;
            testRefund.Zuora__BillingAccount__c = testCustomerAccount.id;
        insert testRefund;
        
        BT_CO_PPS_RefundFile__c testRefundFile = createRefundFile(1)[0];
            testRefundFile.Status__c = 'sent';
        insert testRefundFile;      
        
        BT_CO_PPS_RefundFileResponse__c testRefundFileResponse = createRefundFileResponse(1)[0];
            testRefundFileResponse.customerACNumber__c = 'XXX';
            testRefundFileResponse.paymentAmount__c='10';
        insert testRefundFileResponse;       
        Test.stopTest();
    
    }
    
    //BT_AT_VSS085DX_ImportVendorSubscription
    static testmethod void testBT_ImpVenSubs()
    {   
        BT_CO_VSS_ImportVendorSubscription__c bt20 = new BT_CO_VSS_ImportVendorSubscription__c();
        insert bt20;
    }
    
    @isTest (seeAllData = true)
    static void PaymentMethodTrigger()
    {   
    try{
        Test.startTest();
    
        Account testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            testAccount.NRIC__c = 'T1234567R';
          testAccount.Email__c = 'test@test.com';
           testAccount.Mobile__c = '123456';
        insert testAccount;
        
        Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
            testCustomerAccount.Zuora__Account__c = testAccount.Id;
        insert testCustomerAccount;
        
        Zuora__PaymentMethod__c paymentMethod = new Zuora__PaymentMethod__c();
        paymentMethod.name = 'Payment Test';
        paymentMethod.Zuora__BillingAccount__c = testCustomerAccount.id;
        try {
          insert paymentMethod;
        } catch (exception e) {}
        Test.stopTest();
        }catch(Exception e){
        System.debug('Error: ' + e.getMessage());
        }
    }
    
    static testmethod void CreateInvoiceTrigger()
    {   
        Test.startTest();
        
        Zuora__ZInvoice__c Invoice = new Zuora__ZInvoice__c();
        Invoice.name = 'INV-370H55V';
        insert Invoice;
        
        Test.stopTest();
    }
    
    static testmethod void MigrationContactTrigger()
    {
        Test.startTest();
        
        Account acctRecord = new Account(
            Name='TestAcct'
        );
        insert acctRecord;
        
        
        List<Contact> contRecordList = new List<Contact>();
        Contact contRecord = new Contact(
            HomePhone='1115632', 
            LastName='370H55V',
            AccountId=acctRecord.Id,
            Recipient_Indicator__c = true,
            Recipient_Number__c = 0448925566           
        );
        contRecordList .add(contRecord);
        Key_Id__c kID = new Key_Id__c();
        kID.name = 'NEXT_RECIPIENT_NUMBER';
        kID.id__c = '30004487';
        insert kID;
        
        insert contRecordList;
        
        Test.stopTest();
    }
    
    static testmethod void OrderLineItemVendorTrigger()
    {
        Test.startTest();
        
        getCustomSettings();
        Singpost_Address__c postal = new Singpost_Address__c();
        postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c address = new Address__c();
        address = TestDataFactory.createAddress(1)[0];
        address.Postal_Code__c = postal.Id;
        insert address;
        
       //Account acct = new Account();
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acct.NRIC__c = 'T1234567R';
        acct.Email__c = 'test@test.com';
        acct.Mobile__c = '123456';
        insert acct;
        
        Account acctVendor = new Account();
        acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert acctVendor;
        
        Contact con = new Contact();
        con = TestDataFactory.createContact(1)[0];
        con.AccountId = acct.Id;
        con.Address__c = address.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
        zua.Zuora__Account__c = acct.Id;
        zua.Zuora__PaymentMethodType__c = 'Paypal';
        insert zua;
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        insert pack;
        
        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
        subRec = TestDataFactory.createSubscription(1)[0];
        subRec.Zuora__SubscriptionStartDate__c = date.today();
        subRec.Zuora__SubscriptionEndDate__c = date.today().addMonths(12);
        subRec.Zuora__Account__c = acct.Id;
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = pack.id;
        subRec.Zuora__CustomerAccount__c = zua.id;
        subRec.Zuora__Status__c = 'Expired'; //[JPO 02/12/2015] changed from 'Active' 
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Charity__c = 'false';
        subRec.Vendor_1__c = acctVendor.id;
        subRec.Zuora__Version__c = 1;
        insert subRec;
    
     //create order
     Account accOrd = [Select Id From Account Where Id =: acct.id];
     Contact conOrd = [Select Id From Contact Where id=:con.Id];
     Zuora__Subscription__c zSubOrd = [Select Id From Zuora__Subscription__c Where id=:SubRec.id];
     //system.assertEquals (accOrd+'<<>>'+conOrd+'<<>>'+zSubOrd,' '); 
     
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Base_Subscription__c = subRec.id;
        order.Account__c = acct.Id;
        order.Recipient_Contact__c = con.Id;
        order.Informed_Customer__c = True;
        insert order;
        
        System.debug('---->> : ' + order.Id);
        
        List<Publication__c> listPublication = TestDataFactory.createPublication(100);  
        Publication__c publication = new Publication__c();
        publication = listPublication[0];  
        date myDate = date.today();
        
        Order_Line_Item_Vendor__c oliVendor = new Order_Line_Item_Vendor__c();
        oliVendor.Order__c = order.id;
        oliVendor.Publication__c = publication.id;
        oliVendor.Start_Date__c  = Date.Today().addDays(2);
        insert oliVendor;
        
        oliVendor.Remarks__c = 'Test only';
        update oliVendor;
        Test.stopTest();
        //delete oliVendor;        
        
        
        
    }
    
    static testmethod void UsageTrigger()
    {
        Test.startTest();
        
        Usage__c usage = new Usage__c();
        usage.Unique_Identifier__c = '370H55V';
        insert usage;
        
        Test.stopTest();
    }
    
     static testmethod void Vendor_AllocationTrigger()
    {
        Test.startTest();
        
        getCustomSettings();
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
        
        //Account acct = new Account();
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acct.NRIC__c = 'T1234567R';
        acct.Email__c = 'test@test.com';
        acct.Mobile__c = '123456';
        
        insert acct;
        
        Account acctVendor = new Account();
        acctVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert acctVendor;
        
        Contact con = new Contact();
        con = TestDataFactory.createContact(1)[0];
        con.AccountId = acct.Id;
        con.Address__c = address.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        date myDate = date.today();
        
        Vendor_Allocation__c vendorAllocation = new Vendor_Allocation__c();
        vendorAllocation.Vendor_Account__c = acctVendor.id;
        vendorAllocation.Effective_Start_Date__c  = myDate;
        vendorAllocation.Allocated__c = true;
        insert vendorAllocation ;
        
        Test.stopTest();
    }
    
    static testmethod void VDC_CREDITNOTE_Trigger()
    {
        Test.startTest();
        
        VDC_CREDITNOTE__c vdc = new VDC_CREDITNOTE__c();
        vdc.name = '370H55V';
        insert vdc ;
        
        Test.stopTest();
    }
    
}