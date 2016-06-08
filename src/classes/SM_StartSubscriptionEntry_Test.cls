/*
* Class Name: SM_StartSubscriptionEntry_Test
*@author: Patrick Pancho
*Date: 02/02/2015
* @author: Val Lu/MGaelo
* Date: 02/10/2015
* Project/Requirement: SPH
* @description: Test class for SM_StartSubscriptionEntryController
*/
@isTest (seeAllData= true)
private class SM_StartSubscriptionEntry_Test {
    
    private static Account acc_global;
    private static Singpost_Address__c postal_global;
    private static Address__c addressRec_global;
    private static Contact con_global;
    private static Zuora__CustomerAccount__c billAcc_global;
    private static List <Asia1__c> asiaList_global;
    private static List<Package__c> packageList_global;
    private static zqu__ZProduct__c zProduct_global;
    private static zqu__ProductRatePlan__c prdRatePlan_global;
    private static zqu__ProductRatePlanCharge__c prpc_global;
    private static List<Package_Item__c> pItemList_global;
    private static Publication__c pub_global;
    private static List<Product_Publication__c> prodList_global;
    private static Promotion__c promoTmp_global;
    private static Order__c orderRec_0_global; 
    private static List<Order_Line_Item__c> orderline_global;
    private static List<zqu__Quote__c> zqQ_global;
    private static Promotion_Gift__c promoGift_global;
    private static List<Order_Line_Item_Gift__c> orderLineItemGifts_global;
    //Create Account
    private static void setAccount() {
        //Create Account
        acc_global = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc_global.Name = 'TEST';
        acc_global.AccountNumber = '123456789';
        acc_global.NRIC__c = 'T1234567R';
        insert acc_global; 
    }
    //Create Singpost Address
    private static void setSingpostAddress() {
        postal_global = TestDataFactory.createSingpostAddress(1)[0];
        insert postal_global;
    }
    //Create Address
    private static void setAddress() {
        addressRec_global = TestDataFactory.createAddress(1)[0];
        addressRec_global.Address_Type__c='P';
        addressRec_global.Postal_Code__c = postal_global.Id;
        insert addressRec_global;
    }
    //Create Contact
    private static void setContact() {
        con_global = TestDataFactory.createContact(1)[0];
        con_global.Address__c = addressRec_global.Id;
        con_global.AccountId = acc_global.Id;
        con_global.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con_global.Recipient_Indicator__c = true;  
        insert con_global;
    }
    //Create Billing Account
    private static void setBillingAccount() {
        billAcc_global = TestDataFactory.createBillingAccount(1)[0];
        billAcc_global.Zuora__Account__c = acc_global.Id;
        billAcc_global.Name = 'TEST';     
        billAcc_global.Zuora__Credit_Balance__c = 0;
        billAcc_global.Payment_Mode__c = 'Cash';
        billAcc_global.Billing_Type__c = 'Full Prepaid';
  
        insert billAcc_global;
    }
    //Create Asia One
    private static void setAsiaOne() {
        asiaList_global = TestDataFactory.createAsiaOne(1);
        for(Asia1__c asia : asiaList_global){
        asia.Id_Already_Active__c = false;
        asia.Is_Link_Expired_Used__c = true;
        asia.Status__c = 'Enabled';
        asia.Enabled__c = false;
        asia.Contact__c = con_global.Id;
        asia.Display_Name__c = 'acn@sphcom.sg';
        asia.User_ID_LDAP_ID__c = 'userId27';
        asia.Base_Date_Expiration__c = date.today()-5;
        asia.Password__c = 'sph123409';
        asia.ASIAONE_Legacy_Id__c = '146';
        asia.Email__c = 'acn@sphcom.sg';
        }
        insert asiaList_global;
        
        system.assertNotEquals(null, asiaList_global.size());
    }
    //Create Package
    private static void setPackage() {
        //Create Package
        packageList_global = TestDataFactory.createPackage(1);
        Integer count = 0;
        for (Package__c obj : packageList_global) {
        obj.Package_Price__c = 3;
        obj.Billing_Type__c = 'Recurring Prepaid';
        obj.Package_Type__c = 'Add on';
        obj.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        
            count++;
        }
        insert packageList_global;
        system.assertNotEquals(0, packageList_global.size());
        
    }
    //Create zProduct_global
    private static void setzProduct_global() {
        //Create zProduct_global
        zProduct_global = TestDataFactory.createZProduct(1)[0];
        zProduct_global.ProductSubType__c = GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE;
        zProduct_global.ProductPlatform__c = 'Online';
        insert zProduct_global;
        
        Set<String> promoId = new Set<String>();
        promoId.add(zProduct_global.id);
        
    }
    //Create Product Rate Plan
    private static void setProductRatePlan() {
        //Create Product Rate Plan
        prdRatePlan_global = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan_global.zqu__ZProduct__c = zProduct_global.Id;
        insert prdRatePlan_global;
    }
    //Create Product Rate Plan Charge
    private static void setProductRatePlanCharge() {
        //Create Product Rate Plan Charge
        prpc_global = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc_global.zqu__ProductRatePlan__c = prdRatePlan_global.Id;
        
        insert prpc_global;
    }
    //Create Package Item
    private static void setPackageItem() {
        //Create Package Item
        pItemList_global = TestDataFactory.createPackageItem(1,'Base Product');
        Integer count = 0;
         for (Package_Item__c pItem : pItemList_global) {
        pItem.Package__c = packageList_global[0].Id;
        pItem.Product_Rate_Plan__c = prdRatePlan_global.Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';
         count++;
        }
          
        insert pItemList_global;
    }
    //Create Publication
    private static void setPublication() {
        //Create Publication
        pub_global = TestDataFactory.createPublication(1)[0];
        pub_global.Name = 'pub_globaldata';
        //pub_global.Publication_Code__c = 'pub_globalf';
        pub_global.Publication_Code__c = 'pubg';
        pub_global.Published_Days__c = 'NNNYYYN';
        pub_global.Publication_Type__c = 'A';
        pub_global.Earliest_Start_Date__c = date.Today().addDays(3);
        pub_global.Direct_Sub_Delivery_Method__c = null;
        insert pub_global;
    }
    //Create Product Publication
    private static void setProductPublication() {
        //Create Product Publication
        
        prodList_global = TestDataFactory.createProductPublication(1);
        Integer count = 0;
         for (Product_Publication__c obj : prodList_global) {
            obj.Publication_Code__c = pub_global.id;
            obj.ZProduct__c = zProduct_global.id;
     
            count++;
        }
 
        insert prodList_global;
        
        system.assertNotEquals(0, prodList_global.size());
    }
    //insert Promo
    private static void setPromo() {
        //insert Promo
        promoTmp_global = TestDataFactory.createPromotion(1)[0]; 
        promoTmp_global.Name = 'Promotions';
        promoTmp_global.Contract_Period__c ='12';
        promoTmp_global.Penalty_Charge__c = '100'; 
        promoTmp_global.Maximum_No_of_gifts_allowed__c = '5';
        
        insert promoTmp_global;
    }
    //Create Order
    private static void setOrder() {
        //Create Order
        orderRec_0_global = TestDataFactory.createOrder(1)[0];
       
        orderRec_0_global.Account__c = acc_global.Id;
        orderRec_0_global.Informed_Customer__c = TRUE;
        orderRec_0_global.Sub_Category__c ='Stop Subscription';
        orderRec_0_global.Recipient_Contact__c = con_global.Id;
        orderRec_0_global.Order_Type__c = 'Start';
        orderRec_0_global.Status__c = 'New';
        orderRec_0_global.Credit_Balance__c = 0;
        orderRec_0_global.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        orderRec_0_global.Delivery_Charge__c = 0;
        orderRec_0_global.Billing_Contact__c = null; 
        orderRec_0_global.Delivery_Charge_Type__c = 'S' ;
        orderRec_0_global.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        orderRec_0_global.Check_Amount__c = 100;
        orderRec_0_global.Check_Issuing_Bank__c = 'BLANK';
        orderRec_0_global.Check_No__c = 'SPACE';
        orderRec_0_global.Payment_Mode__c = 'Other';
        orderRec_0_global.Check_Dated__c =  date.today();
        orderRec_0_global.Remarks_Check__c =  'TESTTESTTEST';
        orderRec_0_global.Zone_Charge__c = 0;
        orderRec_0_global.Subscriber_Charge__c = 0;
        orderRec_0_global.Vendor_Credit__c = 0;   
        orderRec_0_global.Billing_Account__c = billAcc_global.id;
        orderRec_0_global.Other_Payment_Mode__c = 'Invoice';
        orderRec_0_global.Billing_Type__c = 'Full Prepaid';
         
        insert orderRec_0_global;
    }
    //Create Order Line Item
    //Create Order Line Item 
    //Create Order Line Item
    private static void setOrderLineItem() {
        //Create Order Line Item
        orderline_global = TestDataFactory.createOrderLineItem(3);
        orderline_global[0].Order__c = orderRec_0_global.Id;

        orderline_global[0].End_Date__c = date.today();
        orderline_global[0].Main_Package_ID__c = packageList_global[0].Id;
        orderline_global[0].Addon_Package__c = packageList_global[0].id;
        orderline_global[0].Term_Length__c = null;
        orderline_global[0].Main_Package_Period__c = 0;  
        orderline_global[0].Asia1_Creation_Mode__c = 'Individual';
        orderline_global[0].Start_Date__c = null;
        orderline_global[0].Parent_Account__c = acc_global.Id;
        orderline_global[0].Term_is_discussed__c = false;
        orderline_global[0].Is_Digital__c = TRUE;
        orderline_global[0].Promotion_ID__c = promoTmp_global.id;
        orderline_global[0].Penalty_Charge__c = 100;
        orderline_global[0].New_Contract_Period__c = 1;
        orderline_global[0].Main_Package_Subscription_Rate__c = 100;
        orderline_global[0].Qty__c = 1;
        orderline_global[0].Main_Package_Product_Family__c = 'Default';
        orderline_global[0].Main_Package_Billing_Type__c = 'Recurring Prepaid';
        orderline_global[0].Main_Package_Frequency__c = 'Default';
        orderline_global[0].Main_Package_Sub_Type__c = 'Termed';
        orderline_global[0].Main_Package_Type__c = 'Base';
        orderline_global[0].Subscribed_as__c = 'New Buy';

        //Create Order Line Item    
        orderline_global[1].Order__c = orderRec_0_global.Id;
        orderline_global[1].End_Date__c = date.today();
        orderline_global[1].Addon_Package__c = packageList_global[0].id;
        orderline_global[1].Main_Package_ID__c = packageList_global[0].Id;
        orderline_global[1].Term_Length__c = 0;
        orderline_global[1].Main_Package_Period__c = 0;  
        orderline_global[1].Asia1_Creation_Mode__c = 'Individual';
        orderline_global[1].Start_Date__c = null;      
        orderline_global[1].Term_is_discussed__c = false;
        orderline_global[1].Is_Digital__c = TRUE;
        orderline_global[1].Promotion_ID__c = promoTmp_global.id;
        orderline_global[1].Penalty_Charge__c = 9999999999999999.99;
        orderline_global[1].New_Contract_Period__c = 999;
        orderline_global[1].Main_Package_Subscription_Rate__c = 100;
        orderline_global[1].Qty__c = 1;
        orderline_global[1].Main_Package_Product_Family__c = 'Default';
        orderline_global[1].Main_Package_Billing_Type__c = 'Recurring Prepaid';
        orderline_global[1].Main_Package_Frequency__c = 'Default';
        orderline_global[1].Main_Package_Sub_Type__c = 'Single';
        orderline_global[1].Main_Package_Type__c = 'Base';
        orderline_global[1].Subscribed_as__c = 'New Buy';
        orderline_global[1].Contract_End_Date__c = date.valueOf('1970-01-01');        
        
        //Create Order Line Item    
        orderline_global[2].Order__c = orderRec_0_global.Id;
        orderline_global[2].End_Date__c = date.today();
        orderline_global[2].Addon_Package__c = packageList_global[0].id;
        orderline_global[2].Main_Package_ID__c = packageList_global[0].Id;
        orderline_global[2].Term_Length__c = 0;
        orderline_global[2].Main_Package_Period__c = 0;  
        orderline_global[2].Asia1_Creation_Mode__c = 'Individual';
        orderline_global[2].Start_Date__c = null;
        orderline_global[2].Term_is_discussed__c = true;
        orderline_global[2].Is_Digital__c = TRUE;
        orderline_global[2].Promotion_ID__c = promoTmp_global.id;
        orderline_global[2].Penalty_Charge__c = 9999999999999999.99;
        orderline_global[2].New_Contract_Period__c = 0;
        orderline_global[2].Main_Package_Subscription_Rate__c = 100;
        orderline_global[2].Qty__c = 1;
        orderline_global[2].Main_Package_Product_Family__c = 'Default';
        orderline_global[2].Main_Package_Billing_Type__c = 'Recurring Prepaid';
        orderline_global[2].Main_Package_Frequency__c = 'Default';
        orderline_global[2].Main_Package_Sub_Type__c = 'Single';
        orderline_global[2].Main_Package_Type__c = 'Base';
        orderline_global[2].Subscribed_as__c = 'New Buy';
        orderline_global[2].Contract_End_Date__c = date.valueOf('1970-01-01'); 
        
        insert orderline_global;    
        system.assertNotEquals(0, orderline_global.size());
    }
    //create Quote
    private static void setQuote() {
        //create Quote
        zqQ_global = TestDataFactory.createQuote(1);
        zqQ_global[0].Vendor_Credit__c = 0;
        zqQ_global[0].zqu__Account__c = acc_global.id;
        zqQ_global[0].Payment_Mode__c = 'Test';
        zqQ_global[0].Delivery_Charge_Type__c = 'S';
        zqQ_global[0].Subscriber_Charge__c = 0;
        zqQ_global[0].Other_PaymentMethod__c = 'Recurring Prepaid';
        zqQ_global[0].zqu__BillToContact__c = con_global.id;
        zqQ_global[0].Main_Package__c = packageList_global[0].id;
        zqQ_global[0].Order__c = orderRec_0_global.id;
        insert zqQ_global;
    }
    //Create Promotion Gift
    private static void setPromotionGift() {
        //Create Promotion Gift
        promoGift_global = TestDataFactory.createPromotionGift(1)[0];
        promoGift_global.Promotion__c = promoTmp_global.Id;
         
        insert promoGift_global;
    }
    //Create Order Line Item Gift
    private static void setOrderLineItemGift() {
        //Create Order Line Item Gift
        orderLineItemGifts_global = TestDataFactory.createItemGift(5);
        for(Order_Line_Item_Gift__c olig : orderLineItemGifts_global) {
            olig.Order_Line_Item__c = orderline_global[0].id;
            olig.Promotion_Gift__c = promoGift_global.id;
        }
        //???
        insert orderLineItemGifts_global;
    }
    
    private static void setAllData() {
        setAccount();
        setSingpostAddress();
        setAddress();
        setContact();
        setBillingAccount();
        setAsiaOne();
        setPackage();
        setzProduct_global();
        setProductRatePlan();
        setProductRatePlanCharge();
        setPackageItem();
        setPublication();   
        setProductPublication();
        setPromo();
        setOrder();
        setOrderLineItem();
        setQuote();
        setPromotionGift();
        setOrderLineItemGift();
    }
    
    //account is null
    static testMethod void Test_SM_StartSubscriptionEntry_01() {
        setAllData();
        Test.startTest(); //josell 05132016
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
            SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
            
            ApexPages.currentPage().getParameters().put('id', acc_global.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());        
        
            //account id is null
            //pageRef.getParameters().put('accountId', acc_global.Id);
            pageRef.getParameters().put('accountId', null);
            //orderline id is null
            //pageRef.getParameters().put('Id', orderline_global[0].Id);
            pageRef.getParameters().put('Id', null);
            
            Test.setCurrentPage(pageRef);
            ssec.initialize();
            ssec.getRecordType();
            ssec.getbillingRecordType();
            ssec.retrieveLatestRecipientContact();   
            ssec.retrieveLatestBillingContact();
        
            //pageRef.getParameters().put('Id', orderRec_0_global.Id);
            //Test.setCurrentPage(pageRef);
                    
            ssec.selectedOrderLineItem = orderline_global[0].Id;            
            ssec.initialize();
        Test.StopTest(); //josell 05132016
    }
    
    //orderLineItem.Term_is_discussed__c is true
    static testMethod void Test_SM_StartSubscriptionEntry_02() {
        setAllData();
        Test.startTest(); //josell 05132016
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
          SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
            
        ApexPages.currentPage().getParameters().put('id', acc_global.Id);
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());        
        
        //account id is null
        //pageRef.getParameters().put('accountId', acc_global.Id);
        pageRef.getParameters().put('accountId', null);
        //orderline id is null
        //pageRef.getParameters().put('Id', orderline_global[0].Id);
        pageRef.getParameters().put('Id', null);
        
        Test.setCurrentPage(pageRef);
        ssec.initialize();
        ssec.getRecordType();
        ssec.getbillingRecordType();
        ssec.retrieveLatestRecipientContact();   
        ssec.retrieveLatestBillingContact();
        
        //pageRef.getParameters().put('Id', orderRec_0_global.Id);
        //Test.setCurrentPage(pageRef);
        
       
        ssec.selectedOrderLineItem = orderline_global[0].Id;            
        ssec.initialize();
        /*
        ssec.populateRecipientContactRelatedDetails();
        
            //SEARCH FUNCTIONALITY
        ssec.searchText = 'TEST';
        ssec.searchBillingType = 'TEST';
        ssec.searchFrom = 'Package';
        ssec.CustomerContactRecType = 'TEST';
        ssec.selectedMailingAgent = 'Test';
        ssec.termLength = '0'; 
        ssec.selectedPromotionId = 'TEst';
        ssec.selectedPackageName = 'TEst';
        ssec.executeSearch();
        ssec.airlineAgents = new List<SelectOption>();
        ssec.quantity = 5;
        ssec.result = FALSE;
        ssec.maxNoOfGifts = 3;
        ssec.promotionResultList = null;
        ssec.packageResultList = null;
        ssec.selectedAddOnPackage = 'TEST';
        ssec.productIsMagazine = FALSE;
        ssec.searchText = 'TEST';
        ssec.subscriptionRate = 100.00;
        ssec.totalSubscriptionPrice = 50.00;
        ssec.isPromotionSelected = True;
        ssec.searchBillingType = 'TEST';
        ssec.isRemoveEligibilityRuleSearchFilter = FALSE;
        ssec.searchFrom = 'Promotion';
        ssec.executeSearch();
        ssec.isFullPrepaid = FALSE;
        ssec.isFromPromotion = FALSE;
        ssec.isMagazine = FALSE;
        ssec.isDigital = True;
        ssec.addOnIsDigital = True;
        ssec.searchPackageMsg = 'Test';
        ssec.isAllInOne = FALSE;
        ssec.vendorEligibilityCheck = FALSE;
        ssec.searchPromotionMsg = 'Test';
        ssec.searchErrorMsg = 'Test';
        ssec.billingAccountOption = 'useExisting';
        
        ssec.save();
        ssec.cancel();
        ssec.addAsia1NewAccount();
        ssec.removeAsia1Subscription();
        ssec.clearPaymentMethod();
        ssec.selectedPackageId = packageList_global[0].id;
        
        ssec.addOrderLineItem();
        
        ssec.orderLineItem = orderline_global[1];
        ssec.selectedPackageId = packageList_global[0].id;
        ssec.addOrderLineItem();
        ssec.updateOrderLineItem();
        
        ssec.orderLineItem = orderline_global[2];
        ssec.selectedPackageId = '';
        ssec.addOrderLineItem();
        
        ssec.orderLineItem = orderline_global[0];
        ssec.orderLineItemIdToBeRemoved = orderline_global[0].id;
        ssec.removeLineItem();
          
        SM_StartSubscriptionEntryController.retrieveRelatedPackages(String.ValueOf(promoTmp_global.id), packageList_global[0].Billing_Type__c, String.ValueOf(acc_global.id), '1', 'true');
        SM_StartSubscriptionEntryController.GiftWrapper gw = new SM_StartSubscriptionEntryController.GiftWrapper();
        gw.promotionGift = new Promotion_Gift__c();
        gw.selectGift = true;
        
        ssec.cancelSearch();
        */
        
        
                
        ssec.selectedAddOnPackage = 'TEST';
        ssec.addOnPackage = packageList_global[0];
        
        orderline_global[0].Delivered_By__c = 'Vendor';
        orderline_global[0].Term_is_discussed__c = true;
        orderline_global[0].Term_Length__c = 1;
        orderline_global[0].Main_Package_Sub_Type__c = 'Single';
        orderline_global[0].Start_Date__c = null;
        update orderline_global[0];
        
        ssec.selectedPackageId = packageList_global[0].id;
        ssec.orderLineItem = orderline_global[0];
        
        ssec.selectedPromotionId = promoTmp_global.Id;
        ssec.selectedPackageName = 'TEst';
                
        ssec.populatePromotionGifts();
        //ssec.retrieveOrderLineItem();
        ssec.addOrderLineItem();
        Test.stopTest(); //josell 05132016
        
    }
    
     static testMethod void Test_SM_StartSubscriptionEntry2() {
        try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.NRIC__c = 'T1234567R';
       
        insert acc;
        
        //Create Singpost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
       
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
       
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        //Create Contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.Billing_Indicator__c = true;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//PPancho 01/26/2015
        con.Recipient_Indicator__c = true;
        con.Email = 'test@sph.com';
        insert con;
        
        //Create Billing Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Name = 'TEST';     
        billAcc.Zuora__Credit_Balance__c = 0;
        billAcc.Payment_Mode__c = 'Cash';
        billAcc.Billing_Type__c = 'Full Prepaid'; //Start/End UD-3896 change value to Full Prepaid
        insert billAcc;
        
     
        
       
        //Create Package
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Code__c = 'packsample';
        pack.Subscription_Type__c = 'Termed';
        pack.Package_Sub_Type__c = 'Single';
        pack.Subscription_Period__c = '2';
        pack.Billing_Type__c = 'Recurring Postpaid';
        pack.Package_Type__c = 'Add on';
        pack.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        insert pack;
        
        //Create ZProduct
        List<zqu__ZProduct__c> prd = TestDataFactory.createZProduct(2);
        prd[0].Name = 'the Strait Times Print';
        prd[0].zqu__SKU__c = 'SKU-000012';
        prd[0].ProductCode__c = 'STSU';
        prd[0].zqu__ZuoraId__c = '23456sddsfdtndhf';
        prd[0].ProductType__c = 'product';
        prd[0].ProductSubType__c = 'Newspaper';
        prd[0].ProductPlatform__c = 'All-In-One';
        
        prd[1].Name = 'the Strait Times Print';
        prd[1].zqu__SKU__c = 'SKU-000012';
        prd[1].ProductCode__c = 'STSU';
        prd[1].zqu__ZuoraId__c = '23regregerg';
        prd[1].ProductType__c = 'product';
        prd[1].ProductSubType__c = 'Magazine';
        prd[1].ProductPlatform__c = 'All-In-One';
        insert prd;
        
        //Create Product Rate Plan
        List<zqu__ProductRatePlan__c> prdRatePlan = TestDataFactory.createProductRatePlan(1);
        prdRatePlan[0].zqu__ZProduct__c = prd[0].Id;
        insert prdRatePlan;
        
        //Create Product Rate Plan Charge
        zqu__ProductRatePlanCharge__c  prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan[0].Id;
        insert prpc;
        
        //insert Promo
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';     
        insert promo;
        
        //Create Package Item
        List<Package_Item__c>  packItem = TestDataFactory.createPackageItem(1, 'Base Product');
        packItem[0].Name = 'testthispack';
        packItem[0].Package__c = pack.id;
        packItem[0].Product_Rate_Plan__c = prdRatePlan[0].id;
        //Test.startTest();
        insert packItem;
        
        //insert Promo
        Promotion__c promoTmp = TestDataFactory.createPromotion(1)[0]; 
        promoTmp.Name = 'Promotions';
        promoTmp.Contract_Period__c ='12';
        promoTmp.Penalty_Charge__c = '100';     
        insert promoTmp;
        
        //Create Order
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Informed_Customer__c = TRUE;
        orderRec_0.Sub_Category__c ='Stop Subscription';
        //orderRec_0.Recipient_Contact__c = null;
        orderRec_0.Order_Type__c = 'Start';
        orderRec_0.Status__c = 'Draft';
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        orderRec_0.Delivery_Charge__c = 0;
        orderRec_0.Billing_Contact__c = con.id;
        orderRec_0.Delivery_Charge_Type__c = null ;
        orderRec_0.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        orderRec_0.Check_Amount__c = null;
        orderRec_0.Check_Issuing_Bank__c = null;
        orderRec_0.Check_No__c = null;
        orderRec_0.Check_Dated__c =  null;
        orderRec_0.Remarks_Check__c =  null;
        orderRec_0.Zone_Charge__c = 0;
        orderRec_0.Subscriber_Charge__c = 0;
        orderRec_0.Vendor_Credit__c = 0;
        orderRec_0.Billing_Account__c = billAcc.id;
        orderRec_0.Other_Payment_Mode__c = 'Freelist';
        orderRec_0.Billing_Type__c = 'Full Prepaid'; //Start/End UD-3896 change value to Full Prepaid
        insert orderRec_0;
        
        //Create Order Line Item
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(3);
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Addon_Package__c = pack.id;
        orderline[0].End_Date__c = date.today();
        orderline[0].Main_Package_ID__c = pack.Id;
        orderline[0].Term_Length__c = 0;
        orderline[0].Main_Package_Period__c = 0;  
        orderline[0].Asia1_Creation_Mode__c = 'Individual';
        orderline[0].Start_Date__c = date.today();
        orderline[0].Term_is_discussed__c = false;
        orderline[0].Is_Digital__c = TRUE;
        orderline[0].Promotion_ID__c = promoTmp.id;
        orderline[0].Penalty_Charge__c = 100;
        orderline[0].New_Contract_Period__c = 1;
        orderline[0].Main_Package_Subscription_Rate__c = 100;
        orderline[0].Qty__c = 1;
        orderline[0].Main_Package_Product_Family__c = 'Default';
        orderline[0].Main_Package_Billing_Type__c = 'Recurring Postpaid';
        orderline[0].Main_Package_Frequency__c = 'Default';
        orderline[0].Main_Package_Sub_Type__c = 'Single';
        orderline[0].Main_Package_Type__c = 'Base';
        orderline[0].Subscribed_as__c = 'New Buy';
        
        //Create Order Line Item    
        orderline[1].Order__c = orderRec_0.Id;
        orderline[1].End_Date__c = date.today();
        orderline[1].Addon_Package__c = pack.id;
        orderline[1].Main_Package_ID__c = pack.Id;
        orderline[1].Term_Length__c = 0;
        orderline[1].Main_Package_Period__c = 0;  
        orderline[1].Asia1_Creation_Mode__c = 'Individual';
        orderline[1].Start_Date__c = date.today();
        orderline[1].Term_is_discussed__c = false;
        orderline[1].Is_Digital__c = TRUE;
        orderline[1].Promotion_ID__c = promoTmp.id;
        orderline[1].Penalty_Charge__c = 9999999999999999.99;
        orderline[1].New_Contract_Period__c = 999;
        orderline[1].Main_Package_Subscription_Rate__c = 100;
        orderline[1].Qty__c = 1;
        orderline[1].Main_Package_Product_Family__c = 'Default';
        orderline[1].Main_Package_Billing_Type__c = 'Recurring Postpaid';
        orderline[1].Main_Package_Frequency__c = 'Default';
        orderline[1].Main_Package_Sub_Type__c = 'Single';
        orderline[1].Main_Package_Type__c = 'Base';
        orderline[1].Subscribed_as__c = 'New Buy';
        orderline[1].Contract_End_Date__c = date.valueOf('1970-01-01');        
        
        
        //Create Order Line Item    
        orderline[2].Order__c = orderRec_0.Id;
        orderline[2].End_Date__c = date.today();
        orderline[2].Addon_Package__c = pack.id;
        orderline[2].Main_Package_ID__c = pack.Id;
        orderline[2].Term_Length__c = 0;
        orderline[2].Main_Package_Period__c = 0;  
        orderline[2].Asia1_Creation_Mode__c = 'Individual';
        orderline[2].Start_Date__c = date.today();
        orderline[2].Term_is_discussed__c = true;
        orderline[2].Is_Digital__c = TRUE;
        orderline[2].Promotion_ID__c = promoTmp.id;
        orderline[2].Penalty_Charge__c = 9999999999999999.99;
        orderline[2].New_Contract_Period__c = 0;
        orderline[2].Main_Package_Subscription_Rate__c = 100;
        orderline[2].Qty__c = 1;
        orderline[2].Main_Package_Product_Family__c = 'Default';
        orderline[2].Main_Package_Billing_Type__c = 'Recurring Postpaid';
        orderline[2].Main_Package_Frequency__c = 'Default';
        orderline[2].Main_Package_Sub_Type__c = 'Single';
        orderline[2].Main_Package_Type__c = 'Base';
        orderline[2].Subscribed_as__c = 'New Buy';
        orderline[2].Contract_End_Date__c = date.valueOf('1970-01-01'); 
           
        insert orderline;
           
               
        //Create Publication
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'pubdata';
        pub.Publication_Code__c = 'pubf';
        pub.Published_Days__c = 'NNNYYYN';
        pub.Publication_Type__c = 'A';
        insert pub;
        
        //Create Product Publication
        Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
        prodPub.Publication_Code__c = pub.id;
        prodPub.ZProduct__c = prd[0].id;
        insert prodPub;
     
        
        //NEW ORDER
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderline[1].Id);//invalid ID
        Test.setCurrentPage(pageRef);
        
        Test.startTest(); //josell 05132016
        
        //ssec.retrieveOrderLineItem();
        ssec.initialize();
        ssec.getRecordType();
        ssec.getbillingRecordType();
        //ssec.updateOrderLineItem();  //--need to look contact__c lookup filter
        
        //EXISTING ORDER
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        Test.setCurrentPage(pageRef);
        ssec = new SM_StartSubscriptionEntryController();
        
        ssec.selectedOrderLineItem = orderline[0].Id;
        
        ssec.initialize();
        ssec.populateRecipientContactRelatedDetails();
        ssec.closePopup();
        
        
        //SEARCH FUNCTIONALITY
        //ssec = new SM_StartSubscriptionEntryController();
        ssec.searchText = 'TEST';
        ssec.aCust = 'test'; //Start/End VPernicia UD-3896
        ssec.searchBillingType = 'Full Prepaid'; //Start/End VPernicia UD-3896 
        ssec.aCust = 'Test';
        ssec.searchFrom = 'Package';
        ssec.getBillAccName();
        ssec.searchCusName();
        ssec.searchAccName();
        ssec.executeSearch();
        ssec.addPopAcc(); //Start/End VPernicia UD-3896 added
        
        orderline[0].Delivered_By__c = 'Mailing Agent';
        ssec.orderLineItem = orderline[0];

        
        ssec.addOrderLineItem();
        
        //Start Vpernicia UD-3896
        ssec.CreditCardType = 'American Express';
        ssec.retrieveSource();
        
        ssec.CreditCardType = 'Visa';
        ssec.retrieveSource();
        //End Vpernicia UD-3896

        
        
        system.assertEquals(ssec.searchBillingType, 'Full Prepaid');
        Test.stopTest();
        }
        catch(Exception e) {
          }
     
    }
    
   static testMethod void Test_SM_StartSubscriptionEntry3() {
        
         try {
        
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardOP001@test.com'
        );
        
        Account acc1 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc1.Name = 'TEST';
        acc1.AccountNumber = '123456789';
        acc1.NRIC__c = 'T1234567R';
       
        insert acc1;
        
        Package__c pack1 =  TestDataFactory.createPackage(1)[0];
        pack1.Package_Code__c = 'SAMPLE1';
        pack1.Subscription_Type__c = 'Termed';
        pack1.Package_Sub_Type__c = 'Single';
        pack1.Subscription_Period__c = '2';
        pack1.Billing_Type__c = 'Full Prepaid';
        pack1.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON; 
        //insert pack1;
        
        List<Package__c> packList = new List<Package__c>();
        packList.add(pack1);
        insert packList;
        
        Publication__c newPublication = TestDataFactory.createPublication(1)[0];
        newPublication.Earliest_Start_Date__c = Date.Today().addDays(4);
        newPublication.Publication_Code__c = 'PUB1';
        newPublication.Published_Days__c = 'NNNYYYN';
        newPublication.Publication_Type__c = 'N';
        newPublication.Direct_Sub_Delivery_Method__c = 'Vendor';
        newPublication.Vendor_Sub_Delivery_Method__c = 'Vendor';
        insert newPublication;
        
        Product_Publication__c newProductPub = TestDataFactory.createProductPublication(1)[0];
        insert newProductPub; 
        
        List<zqu__ZProduct__c> zprodList = TestDataFactory.createZProduct(1);
        for(zqu__ZProduct__c zProduct : zprodList){
        zProduct.ProductFamily__c = 'BH';
        }
        insert zprodList;
     
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zprodList[0].Id;
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        insert prpc;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack1.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';

        insert pItem;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc1.Id;
        billAcc.Name = 'TEST';     
        billAcc.Zuora__Credit_Balance__c = 0;
        billAcc.Payment_Mode__c = 'Cash';
        billAcc.Billing_Type__c = 'Full Prepaid'; //Start/End UD-3896 change value to Full Prepaid
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        insert billAcc;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc1.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        Promotion__c promoTmp = TestDataFactory.createPromotion(1)[0]; 
        promoTmp.Name = 'Promotions';
        promoTmp.Contract_Period__c ='12';
        promoTmp.Penalty_Charge__c = '100';   
        promoTmp.Active__c = true;
        promoTmp.Effective_Start_Date__c = date.today();
        // Start VPernicia 4/2/16: UD-3896 add + 1 to handle FIELD_CUSTOM_VALIDATION_EXCEPTION, Effective End Date is not after the Effective Start Date
        promoTmp.Effective_End_Date__c = date.today() + 1;
        // End VPernicia 4/2/16: UD-3896 add + 1 to handle FIELD_CUSTOM_VALIDATION_EXCEPTION, Effective End Date is not after the Effective Start Date
        insert promoTmp;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packList[0].id;
        PromPak.Promotion__c = promoTmp.id;
        insert PromPak;
        // End VPernicia 4/2/16: UD-3896
        
        Order__c orderRec1 = TestDataFactory.createOrder(1)[0];
        orderRec1.Account__c = acc1.Id;
        orderRec1.Informed_Customer__c = TRUE;
        orderRec1.Sub_Category__c ='Stop Subscription';
        orderRec1.Recipient_Contact__c = con.Id;
        orderRec1.Order_Type__c = 'Start';
        orderRec1.Status__c = 'Draft';
        orderRec1.Credit_Balance__c = 0;
        orderRec1.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        orderRec1.Delivery_Charge__c = 0;
        orderRec1.Billing_Contact__c = null;
        orderRec1.Delivery_Charge_Type__c = null;
        orderRec1.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        orderRec1.Check_Amount__c = 100;
        orderRec1.Check_Issuing_Bank__c = 'BLANK';
        orderRec1.Check_No__c = 'SPACE';
        orderRec1.Check_Dated__c =  date.today();
        orderRec1.Remarks_Check__c =  'TESTTESTTEST';
        orderRec1.Zone_Charge__c = 0;
        orderRec1.Subscriber_Charge__c = 10;
        orderRec1.Vendor_Credit__c = 0;
        orderRec1.Billing_Account__c = billAcc.id;
        orderRec1.Other_Payment_Mode__c = 'Freelist';
        orderRec1.Billing_Type__c = 'Full Prepaid'; //Start/End UD-3896 change value to Full Prepaid
         //Test.startTest();
        insert orderRec1;
   
      /*  Subscription_Vendor__c subven = TestDataFactory.createSubscriptionVendor(1)[0];
        subven.Account__c = acc1.Id;
        subven.Vendor__c = acc1.Id;
        subven.Order_Number__c = orderRec1.Id;

         insert subven; */
  
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(2);
        orderline1[0].Order__c = orderRec1.Id;
        orderline1[0].End_Date__c = date.today();
        orderline1[0].Main_Package_ID__c = pack1.Id;
        orderline1[0].Term_Length__c = 0;
        orderline1[0].Main_Package_Period__c = 0;  
        orderline1[0].Asia1_Creation_Mode__c = 'Individual';
        orderline1[0].Start_Date__c = null;
        orderline1[0].Term_is_discussed__c = false;
        orderline1[0].Is_Digital__c = TRUE;
        orderline1[0].Promotion_ID__c = promoTmp.id;
        orderline1[0].Penalty_Charge__c = 100;
        orderline1[0].New_Contract_Period__c = 1;
        orderline1[0].Main_Package_Subscription_Rate__c = 100;
        orderline1[0].Qty__c = 1;
        //orderline1[0].Vendor_Subscription_ID__c = subven.id;
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Main_Package_Frequency__c = 'Default';
        orderline1[0].Main_Package_Sub_Type__c = 'Single'; 
        orderline1[0].Main_Package_Type__c = 'Base';
        orderline1[0].Subscribed_as__c = 'New Buy';
        orderline1[0].Is_All_In_One__c = false;
        
        orderline1[1].Order__c = orderRec1.Id;
        orderline1[1].End_Date__c = date.today();
        orderline1[1].Main_Package_ID__c = pack1.Id;
        orderline1[1].Term_Length__c = 0;
        orderline1[1].Main_Package_Period__c = 0;  
        orderline1[1].Asia1_Creation_Mode__c = 'Individual';
        orderline1[1].Start_Date__c = null;
        orderline1[1].Term_is_discussed__c = false;
        orderline1[1].Is_Digital__c = TRUE;
        orderline1[1].Promotion_ID__c = null;
        orderline1[1].Penalty_Charge__c = 100;
        orderline1[1].New_Contract_Period__c = 1;
        orderline1[1].Main_Package_Subscription_Rate__c = 100;
        orderline1[1].Qty__c = 1;
        orderline1[1].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[1].Main_Package_Frequency__c = 'Default';
        orderline1[1].Main_Package_Sub_Type__c = 'Single';
        orderline1[1].Main_Package_Type__c = 'Base';
        orderline1[1].Subscribed_as__c = 'New Buy';
        orderline1[1].Is_All_In_One__c = false;
        
     
        insert orderline1;
        
                     
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        
        //create Order Line Item Gift
        Order_Line_Item_Gift__c newOLIg = TestDataFactory.createItemGift(1)[0];
        newOLIG.Order_Line_Item__c = orderline1[1].Id;
        newOLIG.Promotion_Gift__c = newPG.Id;
        newOLIG.Order_Quantity__c = 1;
        newOLIG.Redemption_Quantity__c = 1;
        newOLIG.Redemption_Date__c = date.today();
          
        insert newOLIG;
        
              
        
        Case cas_0 = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas_0.Order__c = orderRec1.Id;
        //insert cas_0;
        
        
        List<Zuora__Subscription__c> subRecs1 = TestDataFactory.createSubscription(4);
        for (Zuora__Subscription__c subRec : subRecs1) {
            subRec.Zuora__CustomerAccount__c = billAcc.id;
            subRec.Zuora__Account__c = acc1.Id;
            //subRec.Zuora__SubscriptionEndDate__c = null;
            subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2).addDays(30);
            subRec.Subscriber_Contact__c = con.Id;
            subRec.Recipient_Contact__c = con.Id;
            subRec.Main_Package_1__c = pack1.id;
            subRec.Zuora__Status__c = 'Active';
            subRec.Order_Number__c = orderRec1.Id;
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Product_Code__c = 'TestProd';
            subRec.Charity__c = 'false';
            subRec.Legacy_Create_Date__c = 'date';
            subRec.Legacy_Create_By__c = 'a'; 
            subRec.Legacy_Update_By__c = 'a';
            subRec.Legacy_Subscription_ID__c = 'a';
            subRec.Legacy_Update_Date__c = 'a';
            subRec.Legacy_Update_By__c = 'a';
            subRec.Legacy_Subscription_ID__c = 'a';
            
            subrec.Order_Line_Item_Number__c = orderline1[0].id;
        }
        subRecs1[0].Billing_Type__c = 'Full Prepaid';
        subRecs1[1].Billing_Type__c = 'Recurring Prepaid';
        subRecs1[2].Billing_Type__c = 'Full Prepaid';
        subRecs1[3].Billing_Type__c = 'Recurring Prepaid';
         
         
        insert subRecs1; 
        //insert new List<sObject>{cas, subRecs1[0]};
            
        Promotion_Gift__c PromoGift = TestDataFactory.createPromotionGift(1)[0];
        insert PromoGift;
        
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        insert SAF;
        
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack1.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        insert PAF;
        
        //create Asia1__c
        Asia1__c tmpAsia1 = new Asia1__c();
        tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        tmpAsia1.Display_Name__c = 'Test';
        tmpAsia1.Email__c = 'test@email.com' ;
        tmpAsia1.Password__c = 'aBcD3Fg';
        tmpAsia1.Contact__c = con.Id;
        tmpAsia1.Status__c = 'Pending Creation';
        tmpAsia1.Order_Number__c = 'Test';
        insert tmpAsia1;
        
        List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
        asiaSubList[0].Asia1__c = tmpAsia1.Id;
        asiaSubList[0].Concurrent__c = 2;
        asiaSubList[0].Subscription__c = subRecs1[0].Id;
        asiaSubList[0].Status__c = 'Enabled';
        asiaSubList[0].Order_Line_Item__c = orderline1[0].Id;
        asiaSubList[0].Service_Access_Flag__c = SAF.Id;
        insert asiaSubList;
        
        list<Order_Line_Item_Gift__c> orderLineItemGifts = new list<Order_Line_Item_Gift__c>();
        //Test.startTest();
        insert orderLineItemGifts;
        
        Zuora__Product__c prod = TestDataFactory.createProduct(1)[0];
        insert prod;
        
        List<Product_Publication__c> prodPubList = TestDataFactory.createProductPublication(1);
        for(Product_Publication__c prodPub : prodPubList ){
            prodPub.Product_Code__c = prod.Id;
            prodPub.Publication_Code__c = newPublication.Id;
            prodPub.ZProduct__c = zprodList[0].Id;
        }
        insert prodPubList;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('Id', orderline1[0].Id);
        pageRef.getParameters().put('accountId', acc1.Id);
        pageRef.getParameters().put('orderId', orderRec1.Id);
        pageRef.getParameters().put('subRecord.Id', subRecs1[0].Id);
        Test.setCurrentPage(pageRef);
        
        
        Test.startTest(); //josell 05132016
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        
        ssec.initialize();
        System.debug('DEB Account Id: ' + ssec.isFromAccount);
        
        ssec.addAsia1NewAccount();
        ssec.searchText = 'test search';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchFrom = 'Package';
        ssec.executeSearch();
        
        ssec.searchText = 'test search';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchFrom = 'Promotions';
        ssec.executeSearch();
        
        ssec.initialize();
        ssec.selectedAddOnPackage = pack1.id;
        ssec.populateAddOn();
        ssec.searchPackage();
        
        ssec.searchText = 'Promotions';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchPromotion();
        ssec.validateNewAsia1Account();
        
        
        ssec.getAsia1ExistingAccounts();
        ssec.addAsia1NewAccount();
        ssec.validateNewAsia1Account();
        ssec.removeAsia1Subscription();
        
        
        ssec.getDeliveryChargeTypes();
        ssec.billingAccountOption = 'CreateNew';
        ssec.getAcquisitionTypes();
        ssec.asia1ErrorMsg = 'TEST';
        ssec.getBillingAccountOptions();
        
        
        ssec.getSource();
        ssec.clearPaymentMethod();
        ssec.clearOtherPaymentMethod();
        
        ssec.getRecordType();
        ssec.getbillingRecordType();
        ssec.populateRecipientContactRelatedDetails();
        
        ssec.orderLineItem = orderline1[0];
        ssec.checkAddressAndProductFamily();
        ssec.deleteRelatedAsia1();
        //Promotion Id != null
        ssec.selectedOrderLineItem = orderline1[0].id;
        ssec.retrieveOrderLineItem();
        
        //Promotion Id = null
        ssec.selectedOrderLineItem = orderline1[1].id;
        ssec.retrieveOrderLineItem();
        
        ssec.addOrderLineItem(); //Start/End UD-3896 added
        ssec.removeAsia1SubscriptionBulk(); //Start/End UD-3896 added
        
        
         system.assertEquals(ssec.searchBillingType , 'Full Prepaid');
         
         
        Test.stopTest();
         }
         
          
          catch(Zuora.zRemoteException e) {
          }  
          }        
    
    
    static testMethod void Test_SM_StartSubscriptionEntry4(){
        
        
        Test.startTest();
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', null);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController StartSubsEntryCont = new SM_StartSubscriptionEntryController();
        
        StartSubsEntryCont.initialize();
        
        // Test armsWrapper
        SM_StartSubscriptionEntryController.armsWrapper aw = new SM_StartSubscriptionEntryController.armsWrapper();
        aw.arNum = 'Test';
        aw.arName = 'Test';
        aw.arPOC = 'Test';
        aw.arAddress = 'Test';
        aw.arPostcode = 'Test';
        aw.arStatus = 'Test';
        aw.arBusProf = 'Test';
        aw.arDate = 'Test';
        aw.isTick = True;
        aw.arAccNum = 'Test';
        aw.arType = 'Test';
        aw.arCredTerm = 'Test';
        aw.arCredTermRef = 'Test';
        aw.arDebtMgmt = 'Test';
        aw.arCompCode = 'Test';
        aw.arCreateDate = 'Test';
        aw.arBLInd = 'Test';
        aw.BLClrCd = 'Test';
        aw.BLRsn = 'Test';
        aw.IdTyp = 'Test';
        aw.IdN = 'Test';
        aw.PpCntryC = 'Test';
        aw.CrRskRtg = 'Test';
        aw.CrLmtInt = 'Test';
        aw.CrLmtExt = 'Test';
        aw.CityM = 'Test';
        aw.Cntry = 'Test';
        aw.PoBoxN = 'Test';
        aw.AttnI = 'Test';
        aw.StfI = 'Test';
        aw.GstOOSI = 'Test';
        aw.UpdId = 'Test';
        aw.UpdDte = 'Test';
        aw.UpdTme = 'Test';
        aw.arAddress1 = 'Test';
        aw.arAddress2 = 'Test';
        aw.arAddress3 = 'Test';
        aw.arAddress4 = 'Test';
        
        Test.stopTest();
        
    }
    
    static testMethod void Test_SM_StartSubscriptionEntry5() {
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //Create Singpost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Create Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        //Create Contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        
        //Create Billing Account
        //Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__DefaultPaymentMethod__c = 'ACH';
          billAcc.Name = 'TEST';     
        //billAcc.Zuora__Credit_Balance__c = 0;
        //billAcc.Payment_Mode__c = 'Cash';
        //billAcc.Billing_Type__c = 'Full';
        insert billAcc;
        
        //Create Asia One
        Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
        asia.Contact__c = con.Id;
        asia.Display_Name__c = '2asiatest';
        asia.User_ID_LDAP_ID__c = 'setasia1test';
        asia.Password__c = 'sph123409';
        asia.ASIAONE_Legacy_Id__c = '146';
        asia.Email__c = 'acn@sphcom.sg';
        insert asia;
        
               
        //Create Package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'TestName';
        pack.Package_Code__c = 'SAMPLE1';
        pack.Package_Price__c = 2;
        pack.Subscription_Type__c = 'Termed';
        pack.Product_Family_Current_Package__c = null;
        pack.Package_Sub_Type__c = 'Single';
        pack.Subscription_Period__c = '1';
        pack.Billing_Type__c =  GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        pack.Package_Type__c = 'Grace Period';
        insert pack;
        
        
        //Create zProduct
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductPlatform__c = 'Print';
        zProduct.ProductSubType__c = 'Magazine';
        insert zProduct;
        
        //Create Product Rate Plan
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.SubscriptionFrequency__c = '2';
        prdRatePlan.RatePlanType__c = 'Proration';
        insert prdRatePlan;
        
        //Create Product Rate Plan Charge
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        insert prpc;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'TestNAme';
        insert prodfam;
        //Create Package Item
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        //insert Promo
        Promotion__c promoTmp = TestDataFactory.createPromotion(1)[0]; 
        promoTmp.Name = 'Promotions';
        promoTmp.Contract_Period__c ='12';
        promoTmp.Penalty_Charge__c = '100';     
        insert promoTmp;
        
        //Create Order
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Informed_Customer__c = TRUE;
        orderRec_0.Sub_Category__c ='Stop Subscription';
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Order_Type__c = 'Start';
        orderRec_0.Status__c = 'New';
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        orderRec_0.Delivery_Charge__c = 0;
        orderRec_0.Billing_Contact__c = null;
        orderRec_0.Delivery_Charge_Type__c = '9' ;
        orderRec_0.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        orderRec_0.Check_Amount__c = 100;
        orderRec_0.Check_Issuing_Bank__c = 'BLANK';
        orderRec_0.Check_No__c = 'SPACE';
        orderRec_0.Check_Dated__c =  date.today();
        orderRec_0.Remarks_Check__c =  'TESTTESTTEST';
        orderRec_0.Zone_Charge__c = 0;
        orderRec_0.Subscriber_Charge__c = 0;
        orderRec_0.Vendor_Credit__c = 0;
        orderRec_0.Billing_Account__c = null;
        orderRec_0.Payment_Mode__c = 'Freelist';  
        orderRec_0.Billing_Type__c = 'Full Prepaid';
        orderRec_0.Parent_Case__c = 'def_parent_id';
        insert orderRec_0;
        
        //Create Order Line Item
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c orderline0 : orderline){
        orderline0.Order__c = orderRec_0.Id;
        orderline0.End_Date__c = date.today();
        orderline0.Main_Package_ID__c = pack.Id;
        orderline0.Term_Length__c = 0;
        orderline0.Main_Package_Period__c = 0;  
        orderline0.Asia1_Creation_Mode__c = 'Individual';
        orderline0.Start_Date__c = null;
        orderline0.Term_is_discussed__c = false;
        orderline0.Is_Digital__c = TRUE;
        orderline0.Promotion_ID__c = promoTmp.id;
        orderline0.Penalty_Charge__c = 100;
        orderline0.New_Contract_Period__c = 1;
        orderline0.Main_Package_Subscription_Rate__c = 100;
        orderline0.Qty__c = 1;
        orderline0.Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline0.Main_Package_Frequency__c = 'Default';
        orderline0.Main_Package_Sub_Type__c = 'Single';
        orderline0.Main_Package_Type__c = 'Base';
        orderline0.Is_Digital__c = true;
        orderline0.Subscribed_as__c = 'New Buy';
        }
        
        insert orderline;
        
        
        //Create Promotion Gift
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
        
        insert promoGift;
        
        //Create Order Line Item Gift
        List<Order_Line_Item_Gift__c> orderLineItemGifts = TestDataFactory.createItemGift(5);
        for(Order_Line_Item_Gift__c olig : orderLineItemGifts) {
            olig.Order_Line_Item__c = orderline[0].id;
            olig.Promotion_Gift__c = promoGift.id;
        }
         //Test.startTest();
        insert orderLineItemGifts;
        
        
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        SM_SubscriptionHelper ssh = new SM_SubscriptionHelper();
      Test.startTest(); //josell 05132016
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        Test.setCurrentPage(pageRef);
        
        ssec = new SM_StartSubscriptionEntryController();
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        pageRef.getParameters().put('def_parent_id', orderRec_0.Id);
        ssec.selectedOrderLineItem = orderline[0].Id;
        ssec.initialize();
        ssec.billingAccountOption = 'useExisting';
        ssec.save();
        
        ssec = new SM_StartSubscriptionEntryController();
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        ssec.selectedOrderLineItem = orderline[0].Id;
        ssec.initialize();
        ssec.billingAccountOption = NULL;
        ssec.save();
        
        ssec = new SM_StartSubscriptionEntryController();
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        ssec.selectedOrderLineItem = orderline[0].Id;
        ssec.initialize();
        ssec.errorMsg = 'TestError';
        ssec.billingAccountOption = 'createNew';
        ssec.acquisitionType = 'Test';
        ssec.deliveryChargeType = 'TEst';
        ssec.glCode = 'TEST';
        ssec.dtlDate = Date.Today().addDays(25);
        ssec.isSponsored = true;
        ssec.fetchBillingAccount();
        ssec.fullPaymentMonthlyDeliveryCharge = 100.00;
        ssec.amountPaid = 20.00;
        ssec.save();
        ssec.thisOrder = orderRec_0;
        ssec.cancel();
        
        // Test for addAsia1ExistingAccount and addAsia1NewAccount
        ssec.selectedPackageId = pack.id;
        ssec.asia1SelectedExistingId=asia.id;
        ssec.addAsia1ExistingAccount();    
        ssec.addAsia1NewAccount();
        ssec.populateSubscriptionDetail();
        //ssec.addPopAcc();
        ssec.cancel();
        
        system.assertEquals(ssec.billingAccountOption, 'createNew');
        
        Test.stopTest();
  } 
   
   static testMethod void Test_SM_StartSubscriptionEntry6() {
   
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
        //Create Contact
        Contact con = TestDataFactory.createContact(1)[0];
        //con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        insert orderRec_0;
   Test.startTest();
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
           SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
              arms.arName = 'Sample arName';
              arms.isTick = true;
              armsList.add(arms);
              ssec.armsCusWrapList = armsList;
              
             //ssec.addPopAcc();
              ssec.closePopup();
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        pageRef.getParameters().put('contactId', con.id);
        Test.setCurrentPage(pageRef);
    test.stoptest();
   }
   
     static testMethod void newTest01() {
     
        // TestData Initialization
       try {
        Integer count = 0;
        Integer records = 1;
    
        //Address
        List<Address__c> addressList = TestDataFactory.createAddress(records);
        count = 0;
        for (Address__c obj : addressList) {
             }
        insert addressList;
        
        system.assertNotEquals(null, addressList.size());
        
              
        //Singpost Address
        List<Singpost_Address__c> singpostAddressList = TestDataFactory.createSingpostAddress(records);
        insert singpostAddressList;

        //Account
        List<Account> accountList = TestDataFactory.createAccount(records, 'Direct Corporate');
        count = 0;
        for (Account obj : accountList) {
       
        obj.Singpost_Address__c = singpostAddressList[count].id;

        count++;
        }
        insert accountList;
    

        //Package
        List<Package__c> packageList = TestDataFactory.createPackage(records);
        count = 0;
        for (Package__c pkg : packageList) {
        pkg.Name = 'TESTname';
        pkg.Subscription_Period__c = '15'; 
        count++;
        }
        insert packageList;
        system.assertNotEquals(null, packageList.size());
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Newspaper';
        zProduct.ProductPlatform__c = 'Print';
        insert zProduct;
            
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prdRatePlan;
            
        List<zqu__ProductRatePlanCharge__c> prpcList = TestDataFactory.createProductRatePlanCharge(1);
        for (zqu__ProductRatePlanCharge__c prpc : prpcList) {
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.PublicationCode__c = '1234';
        count++;
        }   
        insert prpcList;
        
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
        for (Package_Item__c pItem : pItems) {
            pItem.Package__c = packageList[0].Id;
            pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            count++;
            }
            
        insert pItems;
        
        //Billing Contact
        List<Contact> contactList = TestDataFactory.createContact(records);
        count = 0;
        for (Contact obj : contactList) {
            obj.Account = accountList[count];
      
            count++;
        }   
        insert contactList; 

        //Billing Account
        List<Zuora__CustomerAccount__c> zuoraCustomerAccountList = TestDataFactory.createBillingAccount(records);
        count = 0;
        for (Zuora__CustomerAccount__c obj : zuoraCustomerAccountList) {
            obj.Billing_Contact__c = contactList[count].id;
            obj.Zuora__Account__c = accountList[count].id;

            count++;
        }
        insert zuoraCustomerAccountList;
        
        //Payment Method
        List<Zuora__PaymentMethod__c> zuoraPaymentMethodList = TestDataFactory.createPaymentMethod(records);
        count = 0;
        for(Zuora__PaymentMethod__c obj : zuoraPaymentMethodList) {
        obj.Zuora__BillingAccount__c = zuoraCustomerAccountList[0].id;
        }
        
        
        insert zuoraPaymentMethodList;
        
        
        //Order
        List<Order__c> orderList = TestDataFactory.createOrder(records);
        count = 0;
        for (Order__c obj : orderList) {
            obj.Account__c = accountList[count].id;
            //obj.Recipient_Contact__c = contactList[0].id;
            
            count++;
        }
        insert orderList;
        
        List<Publication__c> publicationList = TestDataFactory.createPublication(1);
        count = 0;
        for (Publication__c publication : publicationList ) {
        publication.Product_Family__c = 'PrFam';
        publication.Published_Days__c = 'YYYYYYY';
        publication.Publication_Type__c = 'N';
        publication.Publication_Code__c = '1234';
        count++;
        }
        insert publicationList;
        
        //Order Line Item
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(records);
        count = 0;
        for (Order_Line_Item__c obj : orderLineItemList) {
            obj.Order__c = orderList[count].id;
            obj.Main_Package_ID__c = packageList[count].id;
            obj.Delivered_By__c = 'Mailing Agent';
            
            count++;
        }
        insert orderLineItemList;
       
        Zuora__Product__c prod = TestDataFactory.createProduct(1)[0];
        insert prod;
        
        List<Product_Publication__c> prodPubList = TestDataFactory.createProductPublication(1);
        count = 0;
        for(Product_Publication__c prodPub : prodPubList ){
            prodPub.Product_Code__c = prod.Id;
            prodPub.Publication_Code__c = publicationList[0].Id;
            prodPub.ZProduct__c = zProduct.Id;
            count++;
        }
        insert prodPubList;
       
        Test.startTest();
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        ssec.searchAccName();
        ssec.addPopAcc();
        
        SM_StartSubscriptionEntryController.armsWrapper ssaw = new SM_StartSubscriptionEntryController.armsWrapper();
        
        
        pageRef.getParameters().put('accountId', accountList[0].Id);
        Test.setCurrentPage(pageRef);
        Test.stopTest();
          }
        catch(Exception e) {
          }
     }
      static testMethod void newTest02() {
       
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.NRIC__c = 'T1234567R';
        insert acc;
        
      
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
     
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
     
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
       
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        insert billAccountList;

       
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'TestName';
        pack.Package_Code__c = 'SAMPLE1';
        pack.Package_Price__c = 2;
        pack.Subscription_Type__c = 'Termed';
        pack.Product_Family_Current_Package__c = null;
        pack.Package_Sub_Type__c = 'Single';
        pack.Subscription_Period__c = '1';
        pack.Billing_Type__c = 'Recurring Postpaid';
        pack.Package_Type__c = 'Grace Period';
        insert pack;
        
                
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductPlatform__c = 'Print';
        zProduct.ProductSubType__c = 'Magazine';
        insert zProduct;
        
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.SubscriptionFrequency__c = '2';
        prdRatePlan.RatePlanType__c = 'Proration';
        insert prdRatePlan;
        
       
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        insert prpc;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'TestNAme';
        insert prodfam;
       
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
      
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = null;
        insert orderRec_0;
       
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = pack.Id;
        orderline[0].Is_Digital__c = TRUE;
        orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
        orderline[0].Asia1_Creation_Mode__c = 'Individual';    
        insert orderline;
        
              
        Test.startTest();
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        
        ssec.initialize(); 
        SM_StartSubscriptionEntryController.armsWrapper ssaw = new SM_StartSubscriptionEntryController.armsWrapper();
        
        pageRef.getParameters().put('accountId', acc.Id);
        Test.setCurrentPage(pageRef);
        Test.stopTest();
        }
    static testMethod void newTest03() {
        
        setAllData();
        Test.startTest(); //josell 05132016
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
          SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
            
            ApexPages.currentPage().getParameters().put('id', acc_global.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());        
        
            pageRef.getParameters().put('accountId', null);

            pageRef.getParameters().put('Id', null);
            
            Test.setCurrentPage(pageRef);
            ssec.initialize();
            ssec.reInitializeItem();
            ssec.searchText = 'TEST';
            ssec.searchBillingType = 'TEST';
            ssec.searchFrom = 'Package';
            ssec.CustomerContactRecType = 'TEST';
            ssec.selectedMailingAgent = 'Test';
            ssec.termLength = '0'; 
            ssec.selectedPromotionId = 'TEst';
            ssec.selectedPackageName = 'TEst';
            ssec.executeSearch();
            ssec.airlineAgents = new List<SelectOption>();
            ssec.quantity = 5;
            ssec.result = FALSE;
            ssec.maxNoOfGifts = 3;
            ssec.promotionResultList = null;
            ssec.packageResultList = null;
            ssec.selectedAddOnPackage = 'TEST';
            ssec.productIsMagazine = FALSE;
            ssec.searchText = 'TEST';
            ssec.subscriptionRate = 100.00;
            ssec.totalSubscriptionPrice = 50.00;
            ssec.isPromotionSelected = True;
            ssec.searchBillingType = 'TEST';
            ssec.isRemoveEligibilityRuleSearchFilter = FALSE;
            ssec.searchFrom = 'Promotion';
            ssec.executeSearch();
            ssec.isFullPrepaid = FALSE;
            ssec.isFromPromotion = FALSE;
            ssec.isMagazine = FALSE;
            ssec.isDigital = True;
            ssec.addOnIsDigital = True;
            ssec.searchPackageMsg = 'Test';
            ssec.isAllInOne = FALSE;
            ssec.vendorEligibilityCheck = FALSE;
            ssec.searchPromotionMsg = 'Test';
            ssec.searchErrorMsg = 'Test';
            ssec.billingAccountOption = 'useExisting';
            ssec.cancelSearch();
        Test.stopTest();

    }
      static testMethod void newTest04() {
       
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.NRIC__c = 'T1234567R';
        acc.Airline_Indicator__c = TRUE;
        insert acc;
        
      
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
     
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
        insert addressRec;
     
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
       
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        
        insert billAccountList;

       
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'TestName';
        pack.Package_Code__c = 'SAMPLE1';
        pack.Package_Price__c = 2;
        pack.Subscription_Type__c = 'Termed';
        pack.Product_Family_Current_Package__c = null;
        pack.Package_Sub_Type__c = 'Single';
        pack.Subscription_Period__c = '1';
        pack.Billing_Type__c = 'Recurring Postpaid';
        pack.Package_Type__c = 'Grace Period';
        insert pack;
        
                
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductPlatform__c = 'Print';
        zProduct.ProductSubType__c = 'Magazine';
        insert zProduct;
        
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.SubscriptionFrequency__c = '2';
        prdRatePlan.RatePlanType__c = 'Proration';
        insert prdRatePlan;
        
       
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        insert prpc;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'TestNAme';
        insert prodfam;
       
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = pack.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
      
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = null;
        insert orderRec_0;
       
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = pack.Id;
        orderline[0].Is_Digital__c = TRUE;
        orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
        orderline[0].Asia1_Creation_Mode__c = 'Individual'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';        
        insert orderline;
        
              
        Test.startTest();
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        
        ssec.initialize(); 
        SM_StartSubscriptionEntryController.armsWrapper ssaw = new SM_StartSubscriptionEntryController.armsWrapper();
        
        pageRef.getParameters().put('accountId', acc.Id);
        Test.setCurrentPage(pageRef);
        Test.stopTest();
        } 
    
    static testMethod void unitTest05(){
        system.debug('\n\n ***unitTest05 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        //[SELECT Id, Name FROM RecordType WHERE SobjectType = 'Address__c' AND Name = 'Local' LIMIT 1];  
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        //acc.NRIC__c = 'T1234567R';
        //acc.Airline_Indicator__c = TRUE;
        insert acc;
        
      
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
     
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
       
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        
        insert billAccountList;

        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        //zProductMain.Subscription_Period_1__c = '12';
        insert zProductMain;
        
        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = zProductMain.Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Full Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        //packMain.Subscription_Type__c = 'Termed';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Package_Sub_Type__c = 'Single';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Full Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        //pItemMain.Duration_in_months__c = '1';
        //pItemMain.Effective_Start_Month__c = '1';
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        
        //Add On Package
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        //zProductAddOn.Subscription_Period_1__c = '12';
        insert zProductAddOn;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProductAddOn.Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        prdRatePlan.BillingType__c  = 'Full Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Termed';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Single';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Add On';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        //pItem.Duration_in_months__c = '1';
        //pItem.Effective_Start_Month__c = '1';
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        insert asia1;
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.
        insert orderRec_0;
       
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
        orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Individual'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 100;       
        insert orderline;
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        insert asia1Sub;
        
        Asia1_Subscription__c asia1Sub2 = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub2.Asia1__c = asia1.Id;
        asia1Sub2.Order_Line_Item__c = orderline[0].Id;
        asia1Sub2.Service_Access_Flag__c = safRecMain.Id;
        insert asia1Sub2;
        
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('Id', orderline[0].Id);
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('orderId', orderRec_0.Id);
        //pageRef.getParameters().put('subRecord.Id', subRecs1[0].Id);
        pageRef.getParameters().put('contactId', con.Id);
        Test.setCurrentPage(pageRef);
        
        
        system.debug('\n\n ***unitTest05 method DEBUG LIMIT 2***** ' +  Limits.getQueries() + '\n\n' );
        
        Test.startTest();
        
        system.debug('\n\n ***unitTest05 method DEBUG LIMIT 3 ***** ' +  Limits.getQueries() + '\n\n' );
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        
        ssec.initialize();
        System.debug('DEB Account Id: ' + ssec.isFromAccount);
        //ssec.checkAndCreateOrder();
        
        ssec.addAsia1NewAccount();
        ssec.searchText = 'TestNameMain';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchFrom = 'Package';
        ssec.executeSearch();
        
        ssec.searchText = 'TestName';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchFrom = 'Package';
        ssec.executeSearch();
        
        ssec.initialize();
        ssec.selectedAddOnPackage = packAddOn.id;
        ssec.populateAddOn();
        ssec.searchPackage();
        
        ssec.searchText = 'Promotions';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchPromotion();
        ssec.validateNewAsia1Account();
        
        
        ssec.getAsia1ExistingAccounts();
        ssec.addAsia1NewAccount();
        ssec.validateNewAsia1Account();
        ssec.removeAsia1Subscription();
        
        
        ssec.getDeliveryChargeTypes();
        ssec.billingAccountOption = 'CreateNew';
        ssec.getAcquisitionTypes();
        ssec.asia1ErrorMsg = 'TEST';
        ssec.getBillingAccountOptions();
        
        
        ssec.getSource();
        ssec.clearPaymentMethod();
        ssec.clearOtherPaymentMethod();
        
        ssec.getRecordType();
        ssec.getbillingRecordType();
        ssec.populateRecipientContactRelatedDetails();
        
        ssec.orderLineItem = orderline[0];
        ssec.checkAddressAndProductFamily();
        ssec.deleteRelatedAsia1();
        //Promotion Id != null
        ssec.selectedOrderLineItem = orderline[0].id;
        ssec.retrieveOrderLineItem();
        
        //Promotion Id = null
        ssec.selectedOrderLineItem = orderline[0].id;
        ssec.retrieveOrderLineItem();
        
        ssec.addOrderLineItem(); //Start/End UD-3896 added
        ssec.removeAsia1SubscriptionBulk(); //Start/End UD-3896 added
        
        
        Test.stopTest(); 
    }
    
    static testMethod void unitTestMethod06(){
        system.debug('\n\n ***unitTestMethod06 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        //List<RecordType> rtAdd = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Address__c' AND Name = 'Local' LIMIT 1];  
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        //acc.NRIC__c = 'T1234567R';
        //acc.Airline_Indicator__c = TRUE;
        insert acc;
        
      
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
     
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        
        insert billAccountList;

        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        //zProductMain.Subscription_Period_1__c = '12';
        insert zProductMain;
        
        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = zProductMain.Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Full Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        //packMain.Subscription_Type__c = 'Termed';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Package_Sub_Type__c = 'Single';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Full Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        //pItemMain.Duration_in_months__c = '1';
        //pItemMain.Effective_Start_Month__c = '1';
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        
        //Add On Package
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        //zProductAddOn.Subscription_Period_1__c = '12';
        insert zProductAddOn;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProductAddOn.Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        prdRatePlan.BillingType__c  = 'Full Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Termed';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Single';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Add On';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        //pItem.Duration_in_months__c = '1';
        //pItem.Effective_Start_Month__c = '1';
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        insert asia1;
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.
        insert orderRec_0;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';     
        insert promo;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  zProductMain.id;
        insert prodPubRec;
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
        orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Individual'; 
        orderline[0].Delivered_By__c  = 'Vendor';    
        orderline[0].Main_Package_Subscription_Rate__c = null;  
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 0;
        orderline[0].Main_Package_Sub_Type__c = 'Termed';
        orderline[0].Start_Date__c = null;
        orderline[0].Term_Length__c = 0;
        orderline[0].New_Contract_Period__c = null;
        orderline[0].Promotion_ID__c = promo.id;
        insert orderline;
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        insert asia1Sub;
        
        Asia1_Subscription__c asia1Sub2 = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub2.Asia1__c = asia1.Id;
        asia1Sub2.Order_Line_Item__c = orderline[0].Id;
        asia1Sub2.Service_Access_Flag__c = safRecMain.Id;
        insert asia1Sub2;
        
        
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('Id', orderline[0].Id);
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('orderId', orderRec_0.Id);
        //pageRef.getParameters().put('subRecord.Id', subRecs1[0].Id);
        pageRef.getParameters().put('contactId', con.Id);
        Test.setCurrentPage(pageRef);
        
        
        system.debug('\n\n ***unitTestMethod06 method DEBUG LIMIT 2***** ' +  Limits.getQueries() + '\n\n' );
        
        Test.startTest();
        
        system.debug('\n\n ***unitTestMethod06 method DEBUG LIMIT 3 ***** ' +  Limits.getQueries() + '\n\n' );
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        ssec.subscriptionRate = orderline[0].Add_On_Package_Subscription_Rate__c;
        ssec.selectedPackageId = orderline[0].Main_Package_ID__c;
        ssec.initialize();
        System.debug('DEB Account Id: ' + ssec.isFromAccount);
        //ssec.checkAndCreateOrder();
        //ssec.recipientAddressRecordTypeName = 'Overseas';
        ssec.addAsia1NewAccount();
        ssec.searchText = 'TestNameMain';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchFrom = 'Package';
        ssec.executeSearch();
        
        ssec.searchText = 'TestName';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchFrom = 'Package';
        ssec.executeSearch();
        
        ssec.initialize();
        ssec.selectedAddOnPackage = packAddOn.id;
        ssec.populateAddOn();
        ssec.searchPackage();
        
        ssec.searchText = 'Promotions';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchPromotion();
        ssec.validateNewAsia1Account();
        
        
        ssec.getAsia1ExistingAccounts();
        ssec.addAsia1NewAccount();
        ssec.validateNewAsia1Account();
        ssec.removeAsia1Subscription();
        
        
        ssec.getDeliveryChargeTypes();
        ssec.billingAccountOption = 'CreateNew';
        ssec.getAcquisitionTypes();
        ssec.asia1ErrorMsg = 'TEST';
        ssec.getBillingAccountOptions();
        
        
        ssec.getSource();
        ssec.clearPaymentMethod();
        ssec.clearOtherPaymentMethod();
        
        ssec.getRecordType();
        ssec.getbillingRecordType();
        ssec.populateRecipientContactRelatedDetails();
        
        ssec.orderLineItem = orderline[0];
        ssec.orderLineItemList.add(ssec.orderLineItem);
        system.assert(ssec.orderLineItem.Id != null );
        system.assert(ssec.orderLineItemList.size()>0 );
        ssec.checkAddressAndProductFamily();
        ssec.deleteRelatedAsia1();
        //Promotion Id != null
        ssec.selectedOrderLineItem = orderline[0].id;
        
        
        try{
            
        ssec.retrieveOrderLineItem();   
        }catcH(exception e){}
        
        //Promotion Id = null
        //ssec.selectedOrderLineItem = orderline[0].id;
        //ssec.retrieveOrderLineItem();
        system.assert(ssec.orderLineItem.Id != null );
        
        system.debug('\n\n ***DEBUG ssec.selectedOrderLineItem   *** ' + ssec.selectedOrderLineItem + '\n\n');
        ssec.addOrderLineItem(); //Start/End UD-3896 added
        ssec.removeAsia1SubscriptionBulk(); //Start/End UD-3896 added
        
        
        Test.stopTest(); 
    }
    
    
    static testMethod void unitTestMethod07(){
        
        
        system.debug('\n\n ***unitTestMethod06 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        //List<RecordType> rtAdd = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Address__c' AND Name = 'Local' LIMIT 1];  
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        //acc.NRIC__c = 'T1234567R';
        //acc.Airline_Indicator__c = TRUE;
        insert acc;
        
      
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        //zProductAddOn.Subscription_Period_1__c = '12';
        //insert zProductAddOn;
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        //zProductMain.Subscription_Period_1__c = '12';
        //insert zProductMain;
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
            list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
            Zone_Product__c zoneProd = new Zone_Product__c();
            zoneProd.Effective_Start_Date__c = date.today();
            zoneProd.Zone__c = testZone.id;
            zoneProd.Postage_Charge__c = 648;
            zoneProd.Product__c = listZproducts[1].Id;
            zoneProductLst.add(zoneProd);
            
            Zone_Product__c zoneProd2 = new Zone_Product__c();
            zoneProd2.Effective_Start_Date__c = date.today();
            zoneProd2.Zone__c = testZone.id;
            zoneProd2.Postage_Charge__c = 648;
            zoneProd2.Product__c = listZproducts[0].Id;
            zoneProductLst.add(zoneProd2);
            insert zoneProductLst;
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
            //insert keyId;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        
        insert billAccountList;

        
        
        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
       // packMain.Package_Sub_Type__c = 'Extension';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        //pItemMain.Duration_in_months__c = '1';
        //pItemMain.Effective_Start_Month__c = '1';
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        
        
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        //pItemMain.Duration_in_months__c = '1';
        //pItemMain.Effective_Start_Month__c = '1';
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        //pItem.Duration_in_months__c = '1';
        //pItem.Effective_Start_Month__c = '1';
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        orderRec_0.Billing_Type__c = 'Full Prepaid';
        
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        insert asia1;
        
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';     
        insert promo;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
       //original 
      // Test.startTest();
        
        
        insert orderline[0];
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        insert asia1Sub;
        
        
        system.debug('\n\n ****limit queries 3***** ' +  Limits.getQueries() + '\n\n' );
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('Id', orderline[0].Id);
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('orderId', orderRec_0.Id);
        //pageRef.getParameters().put('subRecord.Id', subRecs1[0].Id);
        pageRef.getParameters().put('contactId', con.Id);
        Test.setCurrentPage(pageRef);
        
        
        system.debug('\n\n ***unitTestMethod06 method DEBUG LIMIT 2***** ' +  Limits.getQueries() + '\n\n' );
        
        //Test.startTest();
        
        system.debug('\n\n ***unitTestMethod06 method DEBUG LIMIT 3 ***** ' +  Limits.getQueries() + '\n\n' );
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        system.debug('\n\n ****limit queries 4***** ' +  Limits.getQueries() + '\n\n' );
        //SM_SubscriptionHelper ssh = new SM_SubscriptionHelper();
        
        //added josell 10:54 am 
        
        SM_StartSubscriptionEntryController.GiftWrapper tstGiftWrap = new SM_StartSubscriptionEntryController.GiftWrapper();
        tstGiftWrap.selectGift = false; 
        tstGiftWrap.promotionGift = newPG;
        
        List<SM_StartSubscriptionEntryController.GiftWrapper> tstGiftWrap_gwList = new List<SM_StartSubscriptionEntryController.GiftWrapper>();
        tstGiftWrap_gwList.add(tstGiftWrap);
        ssec.promotionGifts = tstGiftWrap_gwList;
        system.debug('\n\n ****ssec.promotionGifts 1 ***** ' +  ssec.promotionGifts + '\n\n' );
        system.debug('\n\n ****limit queries 5***** ' +  Limits.getQueries() + '\n\n' );
        ssec.orderLineItemList = SM_SubscriptionHelper.getOrderLineItems(orderRec_0.id);
        ssec.subscriptionRate = orderline[0].Main_Package_Subscription_Rate__c;
        ssec.selectedPackageId = orderline[0].Main_Package_ID__c;
        ssec.initialize();
        
        system.debug('\n\n ****limit queries 6***** ' +  Limits.getQueries() + '\n\n' );
        
        System.debug('DEB Account Id: ' + ssec.isFromAccount);
        //ssec.checkAndCreateOrder();
        //ssec.recipientAddressRecordTypeName = 'Overseas';
        ssec.addAsia1NewAccount();
        ssec.searchText = 'TestNameMain';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchFrom = 'Package';
        ssec.executeSearch();
        
        system.debug('\n\n ****limit queries 7***** ' +  Limits.getQueries() + '\n\n' );
        
        ssec.searchText = 'TestName';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchFrom = 'Package';
        ssec.executeSearch();
        //test
        //Test.startTest();
        
        ssec.initialize();
        ssec.selectedAddOnPackage = packAddOn.id;
        ssec.populateAddOn();
        ssec.searchPackage();
        
        system.debug('\n\n ****limit queries  8***** ' +  Limits.getQueries() + '\n\n' );
    //test 2
        Test.startTest();    
        ssec.searchText = 'Promotions';
        ssec.searchBillingType = 'Full Prepaid';
        ssec.searchPromotion();
        ssec.validateNewAsia1Account();
        
        
        ssec.getAsia1ExistingAccounts();
        ssec.addAsia1NewAccount();
        ssec.validateNewAsia1Account();
        ssec.removeAsia1Subscription();
        
        
        ssec.getDeliveryChargeTypes();
        ssec.billingAccountOption = 'CreateNew';
        ssec.getAcquisitionTypes();
        ssec.asia1ErrorMsg = 'TEST';
        ssec.getBillingAccountOptions();
        
        
        ssec.getSource();
        ssec.clearPaymentMethod();
        ssec.clearOtherPaymentMethod();
        
        ssec.getRecordType();
        ssec.getbillingRecordType();
        ssec.populateRecipientContactRelatedDetails();
        
        ssec.orderLineItem = orderline[0];
        ssec.orderLineItemList.add(ssec.orderLineItem);
        ssec.updateOrderLineItem(); //added josell now 
        
        system.debug('\n\n ****limit queries 9***** ' +  Limits.getQueries() + '\n\n' );
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        
        
        
        
        
        /*Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        orderRec_0.Billing_Type__c = 'Full Prepaid';
        //orderRec_0.
        insert orderRec_0;*/
        
        system.debug('\n\n ****limit queries 10***** ' +  Limits.getQueries() + '\n\n' );
        
        Map<String, Schema.SObjectField> orderMap = Order__c.sObjectType.getDescribe().fields.getMap();
        system.debug('\n\n ***DEBUG orderMap **** ' + orderMap + '\n\n');
        ssec.thisOrder = [SELECT id,
                                    Account__c,
                                    Recipient_Contact__c,
                                    Billing_Contact__c, 
                                    Delivery_Charge_Type__c, 
                                    Billing_Type__c,
                                    Name
                        FROM Order__c WHERE id=:orderRec_0.id];
        asia1.Order_Number__c = ssec.thisOrder.Name;
        update asia1; 
        Asia1_Subscription__c asia1Sub2 = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub2.Asia1__c = asia1.Id;
        asia1Sub2.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub2.Service_Access_Flag__c = safRecMain.Id;
        insert asia1Sub2;
    system.debug('\n\n ***DEBUG thisOrder ****** '  + ssec.thisOrder.Name + '\n\n');
        //added 7:34:00 AM 
        ssec.orderLineItem = orderline1[0];
        ssec.reParentAsia1SubToNewOLI();
        
        //create Promotion gift
        Promotion_Gift__c newPG2 = TestDataFactory.createPromotionGift(1)[0];
        newPG2.Gift_Inventory__c = 1000;
        newPG2.Gift_Issued__c = 100;
        newPG2.Gift_Redeemed__c = 100;
        insert newPG2;
        
        system.debug('\n\n ****limit queries 11***** ' +  Limits.getQueries() + '\n\n' );
        system.debug('\n\n ***DEBUG BILLING TYPE **** ' + orderline1[0].Order__c + '\n\n');
        system.debug('\n\n ***DEBUG BILLING TYPE **** ' + ssec.thisOrder.Billing_Type__c + '\n\n');
        system.debug('\n\n ***DEBUG BILLING TYPE  2 **** ' + orderline1[0].Main_Package_Billing_Type__c + '\n\n');
        system.assert(ssec.thisOrder.Billing_Type__c ==  orderline1[0].Main_Package_Billing_Type__c );
      
        ssec.selectedOrderLineItem = orderline1[0].id;
        ssec.addOnPackage = packAddOn;
        ssec.orderLineItem = orderline1[0];
        ssec.orderLineItemList.add(ssec.orderLineItem);
        ssec.orderLineItemList = SM_SubscriptionHelper.getOrderLineItems(orderRec_0.id);
        ssec.orderLineItem = SM_SubscriptionHelper.getOrderLineItem(orderline1[0].id);
        //system.debug('\n\n ***DeBUG ssec.orderLineItemList    **** ' + ssec.orderLineItemList  + '\n\n' );
        ssec.retrieveOrderLineItem(); //added again 
        //system.debug('\n\n ***DeBUG ssec.orderLineItemList 2    **** ' + ssec.orderLineItemList  + '\n\n' );
        system.assertequals(ssec.orderLineItem != null, true);
        system.assertequals(ssec.orderLineItemList.size()>0, true );
        system.assertequals(ssec.addOnPackage != null, true);
        
        SM_StartSubscriptionEntryController.GiftWrapper tstGiftWrap2 = new SM_StartSubscriptionEntryController.GiftWrapper();
        tstGiftWrap2.selectGift = true; 
        tstGiftWrap2.promotionGift = newPG2;
        
        
        system.debug('\n\n ****limit queries 12***** ' +  Limits.getQueries() + '\n\n' );
        
        List<SM_StartSubscriptionEntryController.GiftWrapper> tstGiftWrap_gwList2 = new List<SM_StartSubscriptionEntryController.GiftWrapper>();
        tstGiftWrap_gwList2.add(tstGiftWrap2);
        ssec.promotionGifts = tstGiftWrap_gwList2;
        
        system.debug('\n\n ****limit queries 13***** ' +  Limits.getQueries() + '\n\n' ); 
       // system.debug('\n\n ***DeBUG ssec.promotionGifts     **** ' + ssec.promotionGifts  + '\n\n' );
        
        system.assertEquals(ssec.promotionGifts.size() >0, true);
        ssec.addOrderLineItem(); //added again
        
        system.assertequals(ssec.orderLineItemList.size()>0, true );
        
        system.debug('\n\n ****limit queries 14***** ' +  Limits.getQueries() + '\n\n' ); 
        
        //ssec.checkAddressAndProductFamily();
        //ssec.deleteRelatedAsia1();
        //Promotion Id != null
        //ssec.orderLineItemIdToBeRemoved = string.valueof(orderline1[0].id);
       // ssec.removelineitem();
        
        
        
        //Promotion Id = null
        //ssec.selectedOrderLineItem = orderline[0].id;
        //ssec.retrieveOrderLineItem();
       // system.assert(ssec.orderLineItem.Id != null );
        //syst
       // system.debug('\n\n ***DEBUG ssec.selectedOrderLineItem   *** ' + SM_SubscriptionHelper.getOrderLineItems(orderRec_0.id) + '\n\n');
        
        ssec.removeAsia1SubscriptionBulk(); //Start/End UD-3896 added
        
        
        Test.stopTest(); 
    }
    
    static testMethod void unitTestMethod08(){
        system.debug('\n\n ***unitTestMethod08 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        insert billAccountList;

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        insert asia1;
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        orderRec_0.Billing_Type__c = 'Full Prepaid';
        
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';     
        insert promo;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
         ssec.thisOrder = orderRec_0;
        ssec.selectedOrderLineItem = orderline1[0].id;
        ssec.addOnPackage = packAddOn;
        ssec.orderLineItem = orderline1[0];
        system.assert(orderline1[0].id != null);
        ssec.orderLineItem = SM_SubscriptionHelper.getOrderLineItem(orderline1[0].id);
        system.assert(ssec.orderLineItem != null);
        //ssec.orderLineItemList.add(ssec.orderLineItem);
        //ssec.orderLineItemList.add(orderline[0]);
        ssec.orderLineItemList = SM_SubscriptionHelper.getOrderLineItems(orderRec_0.id);
        
        
        ssec.orderLineItemIdToBeRemoved = string.valueof(orderline[0].id);
        system.assert(orderRec_0.id != null);
        ssec.removelineitem();
        ssec.eraseCheckDetails();
        test.stopTest();
    }
    static testMethod void unitTestMethod09(){
        system.debug('\n\n ***unitTestMethod08 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Mailing_Agent')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.Type='Airline';
        acc.Active__c = true;
        insert acc;
        Zuora_HPM_Settings__c hpm2 = Zuora_HPM_Settings__c.getInstance('Default');
        test.startTest();
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        
        ssec.creditCardType = 'American Test';
        ssec.retrieveSource();
        ssec.getAirlineMailingAgents();
        
        test.stopTest();
    }
    
    static testMethod void unitTestMethod10(){
        system.debug('\n\n ***unitTestMethod08 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Full Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'IPP';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        orderRec_0.Billing_Type__c = 'Full Prepaid';
        orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        //added 7:34:00 AM 
        system.assert(ssec.orderLineItem.id != null);
        ssec.addPopAcc();
        
        Eligibility_Rule__c eligRule = new Eligibility_Rule__c();
        eligRule.Name = 'test Eligibility';
        eligRule.Action__c = 'Add';
        eligRule.Condition__c = '<';
        eligRule.Contract_Subscription_Rule__c = 'Subscription End Date';
        //eligRule.Contract_Status__c = 'Without Contract';
        eligRule.Contract_Type__c = 'NA';
        eligRule.Customer_Status__c = 'New Customer';
        eligRule.Date__c = date.today();
        eligRule.Days__c = '3';
        eligRule.Effective_Start_Date__c = date.today().addDays(-10);
        eligRule.Effective_End_Date__c = date.today().addYears(2);
        insert eligRule;
        
        
        Promotion_Eligibility_Rule__c PromoRule = new Promotion_Eligibility_Rule__c();
        PromoRule.Current_Platform__c = 'Print';
        PromoRule.Date__c = date.today();
        //PromoRule.Days__c = '3';
        PromoRule.Promotion__c = promo.id;
        PromoRule.Eligibility_Rule__c = eligRule.id;
        PromoRule.Package_List__c = 'test';
        insert PromoRule;
        
        Zuora__Subscription__c subRec = new Zuora__Subscription__c();
        subRec.Zuora__CustomerAccount__c = billAccountList[0].id;
        subRec.Zuora__Account__c = acc.Id;
        //subRec.Zuora__SubscriptionEndDate__c = null;
        subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2).addDays(30);
        subRec.Subscriber_Contact__c = con.Id;
        subRec.Recipient_Contact__c = con.Id;
        subRec.Main_Package_1__c = packAddOn.id;
        subRec.Zuora__Status__c = 'Active';
        subRec.Order_Number__c = orderRec_0.Id;
        subRec.Suppress_Vendor_Start_Notice__c = 'false';
        subRec.Supressed_Acknowledgement_Letter__c = 'false';
        subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRec.Urgent__c = 'false';
        subRec.Vendor_Conversion__c = 'false';
        subRec.Product_Code__c = 'TestProd';
        subRec.Charity__c = 'false';
        subRec.Legacy_Create_Date__c = 'date';
        subRec.Legacy_Create_By__c = 'a'; 
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subRec.Legacy_Update_Date__c = 'a';
        subRec.Legacy_Update_By__c = 'a';
        subRec.Legacy_Subscription_ID__c = 'a';
        subrec.Order_Line_Item_Number__c = orderline1[0].id;
        subrec.Billing_Type__c = 'Recurring Prepaid'; 
        subrec.Subscription_Type_1__c = 'Publication';
        insert subrec;
        
        /*Zuora__SubscriptionProductCharge__c zspc = [SELECT id, Name, Zuora__ProductSKU__c ,Zuora__Zuora_Id__c, Zuora__Subscription__c, Zuora__Account__c, Zuora__Model__c 
                                                    FROM Zuora__SubscriptionProductCharge__c WHERE id != null limit 1];
        system.debug('\n\n ******zspc ***** ' + zspc + '\n\n' );    */                                      
        //new Zuora__SubscriptionProductCharge__c();
        /*zspc.name = 'REW031DX';
        zspc.Zuora__ProductSKU__c = 'SKU01';
        zspc.Zuora__Zuora_Id__c = 'dfgdfg';
        zspc.Zuora__Subscription__c = subrec.Id;
        zspc.Zuora__Account__c = acc.Id;
        zspc.Zuora__Model__c = 'Test';*/
        //insert zspc;
        
        SM_StartSubscriptionEntryController.retrieveRelatedPackages(string.valueof(promo.id), 'Recurring Postpaid', string.valueof(acc.id), 'Add', 'true');
        ssec.vendorEligibilityCheck = true;
        try{
        SM_StartSubscriptionEntryController.retrieveRelatedPackages(string.valueof(promo.id), 'Recurring Postpaid', string.valueof(acc.id), 'Add', 'false');    
        }catch(Exception e){}
        
        //added 05182016
        /*ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'BankTransfer';
        update billAccountList;
        
        ssec.fetchBillingAccount();
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'Cash';
        update billAccountList;
        
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'CreditCard';
        update billAccountList;
        
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'CreditCardReferenceTransaction';
        update billAccountList;
        
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'DebitCard';
        update billAccountList;
        
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'Other';
        update billAccountList;
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'PayPal';
        update billAccountList;
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'WireTransfer';
        update billAccountList;
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'Check';
        update billAccountList;
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'Other';
        billAccountList[0].Other_PaymentMethod__c = '';
        update billAccountList;
        ssec.fetchBillingAccount();*/
        
        
        
        //added 11:05 
        SM_StartSubscriptionEntryController.armsWrapper arms2 = new SM_StartSubscriptionEntryController.armsWrapper();
        arms2.arName = 'Sample arName';
        arms2.isTick = true;
        armsList.add(arms2);
        ssec.armsCusWrapList = armsList;
        ssec.addPopAcc();
        ssec.validateNewAsia1Account();
        ssec.asia1SingleAccount = asia1;
        ssec.validateNewAsia1Account();
        ssec.reParentAsia1SubToNewOLI();
        ssec.selectedPackageId = orderline1[0].Main_Package_ID__c;
        ssec.selectedAddOnPackage = packAddOn.id;
        if(!ssec.isAsia1Validated) ssec.isAsia1Validated = true;
system.assert(ssec.isAsia1Validated == true);       
system.assert(ssec.asia1SingleAccount.Password__c == asia1.Password__c);
        ssec.addAsia1NewAccount();
        
        
        ssec.retrieveSelectedRecipientContact();
        ssec.retrieveLatestBillingContact();
        ssec.retrieveLatestRecipientContact();
        
        ssec.addOnPackage = packAddOn;
        ssec.retrieveNewlyAddedAddOn();
        ssec.creditCardType = 'American Express';
        ssec.retrieveSource();
        ssec.removeAsia1Subscription();
        ssec.deleteRelatedAsia1();
        system.debug('\n\n **** debug limit query ***** ' + limits.getqueries() + '\n\n');
        test.stopTest();
    }
    
  static testMethod void unitTestMethod11(){
        system.debug('\n\n ***unitTestMethod08 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Full Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'IPP';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        orderRec_0.Billing_Type__c = 'Full Prepaid';
        orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        //added 7:34:00 AM 
        system.assert(ssec.orderLineItem.id != null);
        ssec.addPopAcc();
        
        
        /*SM_StartSubscriptionEntryController.retrieveRelatedPackages(string.valueof(promo.id), 'Recurring Postpaid', string.valueof(acc.id), 'Add', 'true');
        ssec.vendorEligibilityCheck = true;
        try{
        SM_StartSubscriptionEntryController.retrieveRelatedPackages(string.valueof(promo.id), 'Recurring Postpaid', string.valueof(acc.id), 'Add', 'false');    
        }catch(Exception e){}*/
        
        //added 05182016
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'BankTransfer';
        update billAccountList;
        
        ssec.fetchBillingAccount();
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'Cash';
        update billAccountList;
        
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'CreditCard';
        update billAccountList;
        
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'CreditCardReferenceTransaction';
        update billAccountList;
        
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'DebitCard';
        update billAccountList;
        
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'Other';
        update billAccountList;
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'PayPal';
        update billAccountList;
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'WireTransfer';
        update billAccountList;
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'Check';
        update billAccountList;
        ssec.fetchBillingAccount();
        
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'Other';
        billAccountList[0].Other_PaymentMethod__c = '';
        update billAccountList;
        ssec.fetchBillingAccount();
        
        
        test.stopTest();
    }
    static testMethod void unitTestMethod12(){
        system.debug('\n\n ***unitTestMethod12 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Other_Payment_Mode__c  = 'Invoice';
        orderRec_0.Create_ARMS_Customer_Account__c =false;
        orderRec_0.Business_Profile__c = 'NONE';
        orderRec_0.Debt_Management_Treatment__c = 'NONE';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        //added 7:34:00 AM 
        system.assert(ssec.orderLineItem.id != null);
        ssec.addPopAcc();
        
        
        /*SM_StartSubscriptionEntryController.retrieveRelatedPackages(string.valueof(promo.id), 'Recurring Postpaid', string.valueof(acc.id), 'Add', 'true');
        ssec.vendorEligibilityCheck = true;
        try{
        SM_StartSubscriptionEntryController.retrieveRelatedPackages(string.valueof(promo.id), 'Recurring Postpaid', string.valueof(acc.id), 'Add', 'false');    
        }catch(Exception e){}*/
        
        //added 05182016
        ssec.billingAccountOption = 'createNew';
        
        ssec.cancelSearch();
        
        ssec.save();
        
        orderRec_0.Create_ARMS_Customer_Account__c =false;
        orderRec_0.Business_Profile__c = 'NONE';
        orderRec_0.Debt_Management_Treatment__c = 'NONE';
        orderRec_0.Debt_Management_Treatment__c = 'NORM';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        update orderRec_0;
        
        ssec.thisOrder = orderRec_0;
        ssec.searchCustTick = false;
        
        ssec.accNum  = '';
        ssec.accTextName  = '';
        ssec.searchAcctTick = false;
        
        ssec.save();
        test.stopTest();
    }
    
    static testMethod void unitTestMethod13(){
        system.debug('\n\n ***unitTestMethod12 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Other_Payment_Mode__c  = 'Invoice';
        orderRec_0.Create_ARMS_Customer_Account__c =false;
        orderRec_0.Business_Profile__c = 'NONE';
        orderRec_0.Debt_Management_Treatment__c = 'NONE';
        orderRec_0.Customer_Name__c = 'test';
        orderRec_0.Customer_No__c = 'jx8l22';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        
        ssec.billingAccountOption = 'createNew';
        ssec.accNum  = '';
        ssec.accTextName  = '';
        ssec.searchAcctTick = false;
        ssec.save();
        
        orderRec_0.Create_ARMS_Customer_Account__c =true;
        orderRec_0.Customer_No__c = 'jx8l22';
        orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Business_Profile__c = 'NONE';
      //  orderRec_0.Debt_Management_Treatment__c = 'NONE';
        system.debug('\n\n ****limit queries 20**** ' +  Limits.getQueries() + '\n\n' );
        update orderRec_0;
        ssec.save();
        test.stopTest();
    }
    
    static testMethod void unitTestMethod14(){
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Other_Payment_Mode__c  = 'Invoice';
        //orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //orderRec_0.Debt_Management_Treatment__c = 'NONE';
        orderRec_0.Customer_Name__c = 'test';
        orderRec_0.Customer_No__c = 'jx8l22';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        
        ssec.billingAccountOption = 'createNew';
       // ssec.accNum  = '';
       // ssec.accTextName  = '';
       // ssec.searchAcctTick = false;
        ssec.save();
        
        ///orderRec_0.Create_ARMS_Customer_Account__c =true;
        ////orderRec_0.Customer_No__c = 'jx8l22';
        ////orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Business_Profile__c = 'NONE';
      //  orderRec_0.Debt_Management_Treatment__c = 'NONE';
        ////system.debug('\n\n ****limit queries 20**** ' +  Limits.getQueries() + '\n\n' );
        ////update orderRec_0;
       /// ssec.save();
        test.stopTest();
    }
    static testMethod void unitTestMethod15(){
        system.debug('\n\n ***unitTestMethod15 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Other_Payment_Mode__c  = 'Invoice';
        //orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //orderRec_0.Debt_Management_Treatment__c = 'NONE';
        orderRec_0.Customer_Name__c = 'test';
        orderRec_0.Customer_No__c = 'jx8l22';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        
        ssec.billingAccountOption = 'createNew';
       // ssec.accNum  = '';
       // ssec.accTextName  = '';
       // ssec.searchAcctTick = false;
        ssec.save();
        
        ///orderRec_0.Create_ARMS_Customer_Account__c =true;
        ////orderRec_0.Customer_No__c = 'jx8l22';
        ////orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Business_Profile__c = 'NONE';
      //  orderRec_0.Debt_Management_Treatment__c = 'NONE';
        ////system.debug('\n\n ****limit queries 20**** ' +  Limits.getQueries() + '\n\n' );
        ////update orderRec_0;
       /// ssec.save();
        test.stopTest();
    }
    static testMethod void unitTestMethod16(){
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc2.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Other_Payment_Mode__c  = 'Invoice';
        //orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //orderRec_0.Debt_Management_Treatment__c = 'NONE';
        orderRec_0.Customer_Name__c = 'test';
        orderRec_0.Customer_No__c = 'jx8l22';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        
        ssec.billingAccountOption = 'createNew';
       // ssec.accNum  = '';
       // ssec.accTextName  = '';
       // ssec.searchAcctTick = false;
       ssec.searchCustTick = true;
        orderRec_0.Customer_Name__c = 'test';
        orderRec_0.Customer_No__c = 'jx8l22';
        system.assert( ssec.thisOrder.Customer_Name__c  != null);
        system.assert(ssec.thisOrder.Customer_No__c != null);
        system.assert(ssec.searchCustTick == true);
        ssec.save();
        test.stopTest();
    }
    
    static testMethod void unitTestMethod17(){
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc2.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Other_Payment_Mode__c  = 'Invoice';
        //orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //orderRec_0.Debt_Management_Treatment__c = 'NONE';
        //orderRec_0.Customer_Name__c = 'test';
        orderRec_0.Customer_No__c = 'jx8l22';
        orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        
        ssec.billingAccountOption = 'createNew';
       // ssec.accNum  = '';
       // ssec.accTextName  = '';
       // ssec.searchAcctTick = false;
       ssec.searchCustTick = true;
        //orderRec_0.Customer_Name__c = 'test';
        orderRec_0.Customer_No__c = 'jx8l22';
       // system.assert( ssec.thisOrder.Customer_Name__c  != null);
        system.assert(ssec.thisOrder.Customer_No__c != null);
        system.assert(ssec.searchCustTick == true);
        ssec.save();
        test.stopTest();
    }
    static testMethod void unitTestMethod18(){
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc2.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Other_Payment_Mode__c  = 'Invoice';
        //orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //orderRec_0.Debt_Management_Treatment__c = 'NONE';
        //orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Customer_No__c = 'jx8l22';
        orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        orderRec_0.Debt_Management_Treatment__c =  'NORM';
        orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        
        ssec.billingAccountOption = 'createNew';
       // ssec.accNum  = '';
       // ssec.accTextName  = '';
       // ssec.searchAcctTick = false;
       ssec.searchCustTick = true;
        //orderRec_0.Customer_Name__c = 'test';
        //orderRec_0.Customer_No__c = 'jx8l22';
       // system.assert( ssec.thisOrder.Customer_Name__c  != null);
        //system.assert(ssec.thisOrder.Customer_No__c != null);
        system.assert(ssec.searchCustTick == true);
        ssec.save();
        test.stopTest();
    }
    static testMethod void unitTestMethod19(){
        
        
        
        
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Other_Payment_Mode__c  = 'Invoice';
       // orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //orderRec_0.Debt_Management_Treatment__c = 'NONE';
        //orderRec_0.Customer_Name__c = 'test';
        orderRec_0.Customer_No__c = 'jx8l22';
        orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        //orderRec_0.Debt_Management_Treatment__c =  'NORM';
        //orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        
        ssec.billingAccountOption = 'createNew';
       // ssec.accNum  = '';
       // ssec.accTextName  = '';
       // ssec.searchAcctTick = false;
       ssec.searchCustTick = true;
        //orderRec_0.Customer_Name__c = 'test';
        //orderRec_0.Customer_No__c = 'jx8l22';
       // system.assert( ssec.thisOrder.Customer_Name__c  != null);
        //system.assert(ssec.thisOrder.Customer_No__c != null);
        system.assert(ssec.searchCustTick == true);
        try{ssec.save();}catch(exception e){}
        test.stopTest();
    }
    
    static testMethod void unitTestMethod20(){
        /*User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardOP001@test.com'
        );
        */
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Other_Payment_Mode__c  = 'Invoice';
       // orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //orderRec_0.Debt_Management_Treatment__c = 'NONE';
        //orderRec_0.Customer_Name__c = 'test';
        orderRec_0.Customer_No__c = 'jx8l22';
        orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        //orderRec_0.Debt_Management_Treatment__c =  'NORM';
        //orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        system.assert(orderline1[0].id != null );
        system.assert(orderline[0].id != null );
        ssec.orderLineItemList = new list<Order_Line_Item__c>();
        ssec.orderLineItemList.add(orderline[0]);
        ssec.orderLineItemList.add(orderline1[0]);
        
        
       /* SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        
        
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;*/
        
        // System.runAs(u) {
             
             Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('1'));   
             ssec.aCust = 'second test'; 
         //}
        
        
        
         ssec.searchAccName();
        /*ssec.initialize();
       
        
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        
        
        ssec.billingAccountOption = 'createNew';
       // ssec.accNum  = '';
       // ssec.accTextName  = '';
       // ssec.searchAcctTick = false;
       ssec.searchCustTick = true;
        //orderRec_0.Customer_Name__c = 'test';
        //orderRec_0.Customer_No__c = 'jx8l22';
       // system.assert( ssec.thisOrder.Customer_Name__c  != null);
        //system.assert(ssec.thisOrder.Customer_No__c != null);
        system.assert(ssec.searchCustTick == true);
        try{ssec.save();}catch(exception e){}*/
        
        test.stopTest();
    }
    
    static testMethod void unitTestMethod21(){
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
        orderRec_0.Credit_Balance__c = 0;
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Other_Payment_Mode__c  = 'Invoice';
       // orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //orderRec_0.Debt_Management_Treatment__c = 'NONE';
        //orderRec_0.Customer_Name__c = 'test';
        orderRec_0.Customer_No__c = 'jx8l22';
        orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        //orderRec_0.Debt_Management_Treatment__c =  'NORM';
        //orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        system.assert(orderline1[0].id != null );
        system.assert(orderline[0].id != null );
        ssec.orderLineItemList = new list<Order_Line_Item__c>();
        ssec.orderLineItemList.add(orderline[0]);
        ssec.orderLineItemList.add(orderline1[0]);
        
        
       /* SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        
        
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;*/
        
        // System.runAs(u) {
             
             Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchCust(true));   
             ssec.aCust = 'second test'; 
         //}
        
        
        
         ssec.searchCusName();
        /*ssec.initialize();
       
        
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        
        
        ssec.billingAccountOption = 'createNew';
       // ssec.accNum  = '';
       // ssec.accTextName  = '';
       // ssec.searchAcctTick = false;
       ssec.searchCustTick = true;
        //orderRec_0.Customer_Name__c = 'test';
        //orderRec_0.Customer_No__c = 'jx8l22';
       // system.assert( ssec.thisOrder.Customer_Name__c  != null);
        //system.assert(ssec.thisOrder.Customer_No__c != null);
        system.assert(ssec.searchCustTick == true);
        try{ssec.save();}catch(exception e){}*/
        
        test.stopTest();
    }
    
    
    static testMethod void unitTestMethod23(){
        
        
        
        
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
         orderRec_0.Credit_Balance__c = 0;
         orderRec_0.Payment_Mode__c = 'Other';
       // orderRec_0.Other_Payment_Mode__c  = 'Invoice';
       // orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //orderRec_0.Debt_Management_Treatment__c = 'NONE';
        //orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Customer_No__c = 'jx8l22';
        //orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        //orderRec_0.Debt_Management_Treatment__c =  'NORM';
        //orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;  
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        
        ssec.billingAccountOption = 'createNew';
       // ssec.accNum  = '';
       // ssec.accTextName  = '';
       // ssec.searchAcctTick = false;
       ssec.searchCustTick = true;
        //orderRec_0.Customer_Name__c = 'test';
        //orderRec_0.Customer_No__c = 'jx8l22';
       // system.assert( ssec.thisOrder.Customer_Name__c  != null);
        //system.assert(ssec.thisOrder.Customer_No__c != null);
        system.assert(ssec.searchCustTick == true);
        ssec.save();
        orderRec_0.Payment_Mode__c = null;
        update orderRec_0;
        
        ssec.thisOrder = orderRec_0;
        ssec.chooseAgent = true;
        ssec.selectedMailingAgent = null;
        ssec.save();
        
        orderRec_0.Business_Profile__c = 'NONE';
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Other_Payment_Mode__c = 'Invoice';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.chooseAgent = false;
        ssec.selectedMailingAgent = null;
            ssec.save();
            
        ssec.billingAccountOption = 'createNew';
        orderRec_0.Payment_Mode__c = 'Credit Card';
        orderRec_0.Payment_Method_ID__c = null;
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();
        test.stopTest();
    }
    
    static testMethod void unitTestMethod24(){
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
         orderRec_0.Credit_Balance__c = 0;
         orderRec_0.Payment_Mode__c = null;
       // orderRec_0.Other_Payment_Mode__c  = 'Invoice';
       // orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //orderRec_0.Debt_Management_Treatment__c = 'NONE';
        //orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Customer_No__c = 'jx8l22';
        //orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        //orderRec_0.Debt_Management_Treatment__c =  'NORM';
        //orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;  
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        
        //ssec.billingAccountOption = 'createNew';
       // ssec.accNum  = '';
       // ssec.accTextName  = '';
       // ssec.searchAcctTick = false;
       ssec.searchCustTick = true;
       ssec.thisBillingAccount = [SELECT id, Zuora__PaymentMethod_Type__c FROM Zuora__CustomerAccount__c  WHERE id =:billAccountList[0].id];
        //orderRec_0.Customer_Name__c = 'test';
        //orderRec_0.Customer_No__c = 'jx8l22';
       // system.assert( ssec.thisOrder.Customer_Name__c  != null);
        //system.assert(ssec.thisOrder.Customer_No__c != null);
        system.assert(ssec.searchCustTick == true);
        ssec.save();
        
        ssec.billingAccountOption = 'useExisting';
        orderRec_0.Billing_Account__c = null;
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();
        test.stopTest();
    }
    static testMethod void unitTestMethod25(){
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        //orderRec_0.Billing_Type__c = 'Recurring Prepaid';
        //orderRec_0.Billing_Account__c = billAccountList[0].id;
         orderRec_0.Credit_Balance__c = 0;
         orderRec_0.Payment_Mode__c = 'Cash';
         orderRec_0.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
       // orderRec_0.Other_Payment_Mode__c  = 'Invoice';
       // orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //orderRec_0.Debt_Management_Treatment__c = 'NONE';
        //orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Customer_No__c = 'jx8l22';
        //orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        //orderRec_0.Debt_Management_Treatment__c =  'NORM';
        //orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;  
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Mailing Agent';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        insert orderline1[0];
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
          Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = orderRec_0;
        ssec.orderLineItem = orderline1[0];
        
        //ssec.billingAccountOption = 'createNew';
       // ssec.accNum  = '';
       // ssec.accTextName  = '';
       // ssec.searchAcctTick = false;
       ssec.searchCustTick = true;
       ssec.billingAccountOption = 'createNew';
        //orderRec_0.Customer_Name__c = 'test';
        //orderRec_0.Customer_No__c = 'jx8l22';
       // system.assert( ssec.thisOrder.Customer_Name__c  != null);
        //system.assert(ssec.thisOrder.Customer_No__c != null);
        system.assert(ssec.thisOrder.Billing_Account_Creation_Mode__c  == 'Create New Billing Account');
        system.assert(ssec.thisOrder.Payment_Mode__c  != null);
        system.assert(ssec.thisOrder.Billing_Account_Creation_Mode__c  != 'Use existing Billing Account');
        ssec.save();
        
        ssec.billingAccountOption = null; // 'useExisting';
        ssec.save();
    try{
        ssec.billingAccountOption = 'createNew'; // 'useExisting';
        orderRec_0.Payment_Mode__c = 'Check';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();
        
        ssec.billingAccountOption = 'createNew'; // 'useExisting';
        orderRec_0.Payment_Mode__c = 'Cash';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();
        
        ssec.billingAccountOption = 'createNew'; // 'useExisting';
        orderRec_0.Payment_Mode__c = 'Credit Card';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();
        
        ssec.billingAccountOption = 'createNew'; // 'useExisting';
        orderRec_0.Payment_Mode__c = 'Other';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();
    }catch(exception e){}
        
        
        
        test.stopTest();
    }
    
    static testMethod void unitTestMethod26(){
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        id rtacct =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct SPH Inter-Division').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.RecordTypeId = rtacct;
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        Key_Id__c key = Key_Id__c.getInstance('Account_Direct SPH Inter-Division');
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        orderRec_0.Billing_Type__c = 'Recurring Prepaid';
          orderRec_0.Billing_Account__c = billAccountList[0].id;
         orderRec_0.Credit_Balance__c = 0;
         orderRec_0.Payment_Mode__c = 'Other';
         orderRec_0.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        orderRec_0.Other_Payment_Mode__c  = 'Freelist';
        orderRec_0.Debt_Management_Treatment__c = 'SUBL';
       // orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //
        //orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Customer_No__c = 'jx8l22';
        //orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        //orderRec_0.Debt_Management_Treatment__c =  'NORM';
        //orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;  
        
        
        
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Vendor';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Recurring';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        
        
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        //orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Recurring';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        orderline1[0].Delivered_By__c = 'Vendor';
        insert orderline1[0];
        
        Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = [SELECT id, Name,Business_Profile__c,Debt_Management_Treatment__c,Account__c,Recipient_Contact__c,Billing_Contact__c,Billing_Type__c,Billing_Account__c,Payment_Mode__c,Billing_Account_Creation_Mode__c,Other_Payment_Mode__c FROM Order__c WHERE id=:orderRec_0.id]; //orderRec_0;
        ssec.orderLineItem = orderline1[0];
        asia1.Order_Number__c =  ssec.thisOrder.Name;
         
        update asia1;
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
        ssec.searchCustTick = true;
        ssec.billingAccountOption = 'useExisting';
        ssec.save();
        
        /*orderRec_0.Debt_Management_Treatment__c = 'SUBH';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();
        
        orderRec_0.Debt_Management_Treatment__c = 'GOVT';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();*/
        test.stopTest();
    }
    
    static testMethod void unitTestMethod27(){
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        id rtacct =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct SPH Inter-Division').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.RecordTypeId = rtacct;
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        Key_Id__c key = Key_Id__c.getInstance('Account_Direct SPH Inter-Division');
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        orderRec_0.Billing_Type__c = 'Recurring Prepaid';
          orderRec_0.Billing_Account__c = billAccountList[0].id;
         orderRec_0.Credit_Balance__c = 0;
         orderRec_0.Payment_Mode__c = 'Other';
         orderRec_0.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        orderRec_0.Other_Payment_Mode__c  = 'Freelist';
        orderRec_0.Debt_Management_Treatment__c = 'SUBH';
       // orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //
        //orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Customer_No__c = 'jx8l22';
        //orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        //orderRec_0.Debt_Management_Treatment__c =  'NORM';
        //orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;  
        
        
        
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Vendor';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Recurring';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        
        
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        //orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Recurring';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        orderline1[0].Delivered_By__c = 'Vendor';
        insert orderline1[0];
        
        Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = [SELECT id, Name,Business_Profile__c,Debt_Management_Treatment__c,Account__c,Recipient_Contact__c,Billing_Contact__c,Billing_Type__c,Billing_Account__c,Payment_Mode__c,Billing_Account_Creation_Mode__c,Other_Payment_Mode__c FROM Order__c WHERE id=:orderRec_0.id]; //orderRec_0;
        ssec.orderLineItem = orderline1[0];
        asia1.Order_Number__c =  ssec.thisOrder.Name;
         
        update asia1;
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
        ssec.searchCustTick = true;
        ssec.billingAccountOption = 'useExisting';
        ssec.save();
        
        /*orderRec_0.Debt_Management_Treatment__c = 'GOVT';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();
        
        orderRec_0.Debt_Management_Treatment__c = 'GOVT';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();*/
        test.stopTest();
    }
    
    static testMethod void unitTestMethod28(){
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        id rtacct =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct SPH Inter-Division').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.RecordTypeId = rtacct;
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        Key_Id__c key = Key_Id__c.getInstance('Account_Direct SPH Inter-Division');
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        orderRec_0.Billing_Type__c = 'Recurring Prepaid';
          orderRec_0.Billing_Account__c = billAccountList[0].id;
         orderRec_0.Credit_Balance__c = 0;
         orderRec_0.Payment_Mode__c = 'Other';
         orderRec_0.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        orderRec_0.Other_Payment_Mode__c  = 'Freelist';
        orderRec_0.Debt_Management_Treatment__c = 'GOVT';
       // orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //
        //orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Customer_No__c = 'jx8l22';
        //orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        //orderRec_0.Debt_Management_Treatment__c =  'NORM';
        //orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;  
        
        
        
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Vendor';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Recurring';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        
        
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        //orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Recurring';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        orderline1[0].Delivered_By__c = 'Vendor';
        insert orderline1[0];
        
        Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        ssec.thisOrder = [SELECT id, Name,Business_Profile__c,Debt_Management_Treatment__c,Account__c,Recipient_Contact__c,Billing_Contact__c,Billing_Type__c,Billing_Account__c,Payment_Mode__c,Billing_Account_Creation_Mode__c,Other_Payment_Mode__c FROM Order__c WHERE id=:orderRec_0.id]; //orderRec_0;
        ssec.orderLineItem = orderline1[0];
        asia1.Order_Number__c =  ssec.thisOrder.Name;
         
        update asia1;
        system.debug('\n\n asia1.Order_Number__c ' + asia1.Order_Number__c + '\n\n');
        ssec.searchCustTick = true;
        ssec.billingAccountOption = 'useExisting';
        ssec.save();
        
        /*orderRec_0.Debt_Management_Treatment__c = 'GOVT';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();
        
        orderRec_0.Debt_Management_Treatment__c = 'GOVT';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();*/
        test.stopTest();
    }
    
    static testMethod void unitTestMethod29(){
        system.debug('\n\n ***unitTestMethod14 method DEBUG LIMIT***** ' +  Limits.getQueries() + '\n\n' );
        //Rec Type 
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        id rtacct =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct SPH Inter-Division').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.RecordTypeId = rtacct;
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Full Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
        Key_Id__c key = Key_Id__c.getInstance('Account_Direct SPH Inter-Division');
        
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'S';
        orderRec_0.Billing_Type__c = 'Full Prepaid'; //'Recurring Prepaid';
          orderRec_0.Billing_Account__c = billAccountList[0].id;
         orderRec_0.Credit_Balance__c = 0;
         orderRec_0.Payment_Mode__c = 'Other';
         orderRec_0.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        orderRec_0.Other_Payment_Mode__c  = 'Test';
        orderRec_0.Debt_Management_Treatment__c = 'GOVT';
        orderRec_0.Order_Type__c = 'Start';
        orderRec_0.Status__c = 'New';
       // orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //
        //orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Customer_No__c = 'jx8l22';
        //orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        //orderRec_0.Debt_Management_Treatment__c =  'NORM';
        //orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;  
        
        
        
        
        Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Vendor';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Recurring';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        
        
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        //orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Recurring';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        orderline1[0].Delivered_By__c = 'Vendor';
        insert orderline1[0];
        
        Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        
        
        
        
        PageReference pageRef = Page.SM_StartSubscriptionEntry;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('id', orderRec_0.id);
        Test.setCurrentPage(pageRef);
        
        SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
        SM_SubscriptionHelper.Asia1SubscriptionWrapper asiaSubWrap = new SM_SubscriptionHelper.Asia1SubscriptionWrapper();
        asiaSubWrap.serviceFlagName = safRec.Name;
        asiaSubWrap.serviceFlagId = string.valueof(safRec.id);
        asiaSubWrap.status = asia1Sub.Status__c;
        asiaSubWrap.concurrent = integer.valueof(pckAF.No_of_Concurrent_Users__c);
        list<SM_SubscriptionHelper.Asia1SubscriptionWrapper> asiaSubWrapList = new list<SM_SubscriptionHelper.Asia1SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        SM_SubscriptionHelper.Asia1Wrapper asiaWrap  = new SM_SubscriptionHelper.Asia1Wrapper();
        asiaWrap.asia1Id = asia1.id;
        asiaWrap.asia1Subscriptions = asiaSubWrapList;
        list<SM_SubscriptionHelper.Asia1Wrapper> asiaWrapList = new list<SM_SubscriptionHelper.Asia1Wrapper>();
        
        asiaWrapList.add(asiaWrap);
        
        List<SM_StartSubscriptionEntryController.armsWrapper> armsList = new List<SM_StartSubscriptionEntryController.armsWrapper>();
        SM_StartSubscriptionEntryController.armsWrapper arms = new SM_StartSubscriptionEntryController.armsWrapper();
        arms.arName = 'Sample arName';
        arms.isTick = true;
        armsList.add(arms);
        ssec.armsCusWrapList = armsList;
        
        
        ssec.initialize();
    
        ssec.asia1Subscriptions = asiaWrapList;
        ssec.asia1IdToBeRemoved = string.valueof(asia1.id);
        asia1.Order_Number__c =  ssec.thisOrder.Name;
        update asia1;
        ssec.thisOrder = [SELECT id, Delivery_Charge_Type__c, Name,Business_Profile__c,Debt_Management_Treatment__c,Account__c,Recipient_Contact__c,Billing_Contact__c,Billing_Type__c,Billing_Account__c,Payment_Mode__c,Billing_Account_Creation_Mode__c,Other_Payment_Mode__c FROM Order__c WHERE id=:orderRec_0.id]; //orderRec_0;
        ssec.thisOrder.Delivery_Charge_Type__c = 'S';
        update ssec.thisOrder;
        
        ssec.orderLineItem = orderline1[0];
        
        
        zqu__Quote__c testQuote = new zqu__Quote__c();
        testQuote.Vendor_Credit__c = 0;
        testQuote.zqu__Account__c = acc.id;
        testQuote.Payment_Mode__c = 'Test';
        testQuote.Delivery_Charge_Type__c = ssec.thisOrder.Delivery_Charge_Type__c;
        testQuote.Subscriber_Charge__c = 0;
        testQuote.Other_PaymentMethod__c = 'Recurring Prepaid';
        testQuote.zqu__BillToContact__c = con.id;
        testQuote.Main_Package__c = packAddOn.id;
        testQuote.Order__c = orderRec_0.id;
        testQuote.Order_Line_Item_Number_1__c = orderline1[0].id;
        testQuote.Subscription_Type__c = 'Delivery';
        insert testQuote;
        
        system.debug('\n\n asia1.Order_Number__c ' + testQuote  + '\n\n');
        ssec.searchCustTick = true;
        ssec.billingAccountOption = 'useExisting';
        
        system.assert(testQuote.Subscription_Type__c == 'Delivery');
        system.assert(ssec.thisOrder.Delivery_Charge_Type__c == testQuote.Delivery_Charge_Type__c);
        ssec.save();
        
        /*orderRec_0.Debt_Management_Treatment__c = 'GOVT';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();
        
        orderRec_0.Debt_Management_Treatment__c = 'GOVT';
        update orderRec_0;
        ssec.thisOrder = orderRec_0;
        ssec.save();*/
        test.stopTest();
    }
}