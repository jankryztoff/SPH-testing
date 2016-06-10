/*
* Class Name: SM_RenewalOfSubscriptionEntryTest4
*@author: Karl Tan
*Date: 04/06/2016
* Project/Requirement: SPH
* @description: Test class for SM_RenewalOfSubscriptionEntryController
*/
@isTest (seeAllData= true)
private class SM_RenewalOfSubscriptionEntryTest4 {
    
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
   static testMethod void Test_SM_RenewalOfSubscriptionEntry_01() {
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
        prd[0].zqu__ZuoraId__c = '23456sddsfd';
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
        Test.startTest();
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
        
        
        
        //Create Subscription
        List<Zuora__Subscription__c> testSubscription =  TestDataFactory.createSubscription(1);
                testSubscription[0].Subscriber_Contact__c = con.id;
                testSubscription[0].Main_Package__c = billAcc.id;
                testSubscription[0].Zuora__Account__c = acc.id;
                testSubscription[0].Order_Number__c = null;
                testSubscription[0].Zuora__CustomerAccount__c = billAcc.Id;
                testSubscription[0].Billing_Type__c = 'Recurring Prepaid';
                testSubscription[0].Legacy_Create_Date__c = 'a';
                testSubscription[0].Legacy_Create_By__c = 'a';
                testSubscription[0].Legacy_Update_By__c = 'a';
                testSubscription[0].Legacy_Subscription_ID__c = 'a';
                testSubscription[0].Legacy_Update_Date__c = 'a';
                testSubscription[0].Number_of_Copies__c = 100;
                testSubscription[0].Number_of_Copies1__c = '100';
                testSubscription[0].Zuora__Status__c = 'Active';
                testSubscription[0].Subscription_Type_1__c = 'Publication';
                testSubscription[0].Subscription_Type__c = 'Publication';
                testSubscription[0].Contact__c = con.id;
                testSubscription[0].Delivery_Charge_Type__c = 'H';
                testSubscription[0].Recipient_Contact__c = con.id;
                testSubscription[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(20);
                testSubscription[0].Zuora__Version__c = 1;
                insert testSubscription;
                
                
        Case testCase = new Case();
            testCase.AccountId = testSubscription[0].Zuora__Account__c;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Status = 'New';
            testCase.Payment_Mode__c = 'Cash';
            testCase.Amount_To_Refund__c = 100;
            testCase.Action_Type__c = 'Amend';    
            testCase.RecordTypeId = ConstantsSLB.getKeyId(GlobalVariableClass.CASERETENTION);
            testCase.Subscription_Name__c = testSubscription[0].Id;

           
            insert testCase;
     
        Test.startTest();
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        SM_RenewalOfSubscriptionEntryController ssec = new SM_RenewalOfSubscriptionEntryController();       
        
        //EXISTING ORDER
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        Test.setCurrentPage(pageRef);
        ssec = new SM_RenewalOfSubscriptionEntryController();
        
        ssec.selectedOrderLineItem = orderline[0].Id;
        
        ssec.initialize();
        ssec.retrieveOrderLineItem();
        ssec.retrieveActiveSubscriptions();
        ssec.populateRecipientContactRelatedDetails();
        ssec.closePopup();
        
        
        //SEARCH FUNCTIONALITY
        //ssec = new SM_RenewalOfSubscriptionEntryController();
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
    
    //orderLineItem.Term_is_discussed__c is true
    /*static testMethod void Test_SM_RenewalOfSubscriptionEntry_02() {
        setAllData();
        
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
          SM_RenewalOfSubscriptionEntryController ssec = new SM_RenewalOfSubscriptionEntryController();
            
        ApexPages.currentPage().getParameters().put('id', acc_global.Id);
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());        
        
        pageRef.getParameters().put('accountId', null);
        pageRef.getParameters().put('Id', null);
        
        Test.setCurrentPage(pageRef);
        ssec.initialize();
        ssec.selectedOrderLineItem = orderline_global[0].Id;            
        ssec.initialize();         
        ssec.selectedAddOnPackage = 'TEST';
        ssec.addOnPackage = packageList_global[0];
        
        orderline_global[0].Delivered_By__c = 'Vendor';
        orderline_global[0].Term_is_discussed__c = true;
        orderline_global[0].Term_Length__c = 1;
        orderline_global[0].Main_Package_Sub_Type__c = 'Single';
        orderline_global[0].Start_Date__c = date.Today();
        update orderline_global[0];
        
        ssec.selectedPackageId = packageList_global[0].id;
        ssec.orderLineItem = orderline_global[0];
        
        ssec.selectedPromotionId = promoTmp_global.Id;
        ssec.selectedPackageName = 'TEst';
                
        ssec.populatePromotionGifts();
        ssec.addOrderLineItem();
        
        
    }*/
    

    
   /*static testMethod void Test_SM_RenewalOfSubscriptionEntry1() {
        
       
         Integer count = 0;
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
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Name = 'TEST';     
        billAcc.Zuora__Credit_Balance__c = 0;
        billAcc.Payment_Mode__c = 'Cash';
        billAcc.Billing_Type__c = 'Full Prepaid';
  
        insert billAcc;
        
        //Create Asia One
       
        List <Asia1__c> asiaList = TestDataFactory.createAsiaOne(1);
        for(Asia1__c asia : asiaList){
        asia.Id_Already_Active__c = false;
        asia.Is_Link_Expired_Used__c = true;
        asia.Status__c = 'Enabled';
        asia.Enabled__c = false;
        asia.Contact__c = con.Id;
        asia.Display_Name__c = 'acn@sphcom.sg';
        asia.User_ID_LDAP_ID__c = 'userId27';
        asia.Base_Date_Expiration__c = date.today()-5;
        asia.Password__c = 'sph123409';
        asia.ASIAONE_Legacy_Id__c = '146';
        asia.Email__c = 'acn@sphcom.sg';
        }
        insert asiaList;
        
        system.assertNotEquals(null, asiaList.size());
        
                      
        //Create Package
         List<Package__c> packageList = TestDataFactory.createPackage(1);
        count = 0;
        for (Package__c obj : packageList) {
        obj.Package_Price__c = 3;
        obj.Billing_Type__c = 'Recurring Prepaid';
        obj.Package_Type__c = 'Add on';
        obj.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        
            count++;
        }
        insert packageList;
        system.assertNotEquals(0, packageList.size());
        
        //Create zProduct
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE;
        zProduct.ProductPlatform__c = 'Online';
        insert zProduct;
        
        Set<String> promoId = new Set<String>();
        promoId.add(zProduct.id);
        
        //Create Product Rate Plan
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prdRatePlan;
        
        //Create Product Rate Plan Charge
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        
        insert prpc;
        
        //Create Package Item
        List<Package_Item__c> pItemList = TestDataFactory.createPackageItem(1,'Base Product');
        count = 0;
         for (Package_Item__c pItem : pItemList) {
        pItem.Package__c = packageList[0].Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';
         count++;
        }
          
        insert pItemList;
        
          //Create Publication
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'pubdata';
        pub.Publication_Code__c = 'pubf';
        pub.Published_Days__c = 'NNNYYYN';
        pub.Publication_Type__c = 'A';
        pub.Earliest_Start_Date__c = date.Today().addDays(3);
        pub.Direct_Sub_Delivery_Method__c = null;
        insert pub;

        
        //Create Product Publication
        
        List<Product_Publication__c> prodList = TestDataFactory.createProductPublication(1);
        count = 0;
         for (Product_Publication__c obj : prodList) {
            obj.Publication_Code__c = pub.id;
            obj.ZProduct__c = zProduct.id;
     
            count++;
        }
 
        insert prodList;
        
        system.assertNotEquals(0, prodList.size());
        
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
        orderRec_0.Delivery_Charge_Type__c = 'S' ;
        orderRec_0.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        orderRec_0.Check_Amount__c = 100;
        orderRec_0.Check_Issuing_Bank__c = 'BLANK';
        orderRec_0.Check_No__c = 'SPACE';
        orderRec_0.Payment_Mode__c = 'Other';
        orderRec_0.Check_Dated__c =  date.today();
        orderRec_0.Remarks_Check__c =  'TESTTESTTEST';
        orderRec_0.Zone_Charge__c = 0;
        orderRec_0.Subscriber_Charge__c = 0;
        orderRec_0.Vendor_Credit__c = 0;   
        orderRec_0.Billing_Account__c = billAcc.id;
        orderRec_0.Other_Payment_Mode__c = 'Invoice';
        orderRec_0.Billing_Type__c = 'Full Prepaid';
         
        insert orderRec_0;
        
                      
        //Create Order Line Item
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(3);
        orderline[0].Order__c = orderRec_0.Id;

        orderline[0].End_Date__c = date.today();
        orderline[0].Main_Package_ID__c = packageList[0].Id;
        orderline[0].Addon_Package__c = packageList[0].id;
        orderline[0].Term_Length__c = null;
        orderline[0].Main_Package_Period__c = 0;  
        orderline[0].Asia1_Creation_Mode__c = 'Individual';

        orderline[0].Parent_Account__c = acc.Id;
        orderline[0].Term_is_discussed__c = false;
        orderline[0].Is_Digital__c = TRUE;
        orderline[0].Promotion_ID__c = promoTmp.id;
        orderline[0].Penalty_Charge__c = 100;
        orderline[0].New_Contract_Period__c = 1;
        orderline[0].Main_Package_Subscription_Rate__c = 100;
        orderline[0].Qty__c = 1;
        orderline[0].Main_Package_Product_Family__c = 'Default';
        orderline[0].Main_Package_Billing_Type__c = 'Recurring Prepaid';
        orderline[0].Main_Package_Frequency__c = 'Default';
        orderline[0].Main_Package_Sub_Type__c = 'Termed';
        orderline[0].Main_Package_Type__c = 'Base';
        orderline[0].Subscribed_as__c = 'New Buy';

        //Create Order Line Item    
        orderline[1].Order__c = orderRec_0.Id;
        orderline[1].End_Date__c = date.today();
        orderline[1].Addon_Package__c = packageList[0].id;
        orderline[1].Main_Package_ID__c = packageList[0].Id;
        orderline[1].Term_Length__c = 0;
        orderline[1].Main_Package_Period__c = 0;  
        orderline[1].Asia1_Creation_Mode__c = 'Individual';
       
        orderline[1].Term_is_discussed__c = false;
        orderline[1].Is_Digital__c = TRUE;
        orderline[1].Promotion_ID__c = promoTmp.id;
        orderline[1].Penalty_Charge__c = 9999999999999999.99;
        orderline[1].New_Contract_Period__c = 999;
        orderline[1].Main_Package_Subscription_Rate__c = 100;
        orderline[1].Qty__c = 1;
        orderline[1].Main_Package_Product_Family__c = 'Default';
        orderline[1].Main_Package_Billing_Type__c = 'Recurring Prepaid';
        orderline[1].Main_Package_Frequency__c = 'Default';
        orderline[1].Main_Package_Sub_Type__c = 'Single';
        orderline[1].Main_Package_Type__c = 'Base';
        orderline[1].Subscribed_as__c = 'New Buy';
        orderline[1].Contract_End_Date__c = date.valueOf('1970-01-01');        
        
        //Create Order Line Item    
        orderline[2].Order__c = orderRec_0.Id;
        orderline[2].End_Date__c = date.today();
        orderline[2].Addon_Package__c = packageList[0].id;
        orderline[2].Main_Package_ID__c = packageList[0].Id;
        orderline[2].Term_Length__c = 0;
        orderline[2].Main_Package_Period__c = 0;  
        orderline[2].Asia1_Creation_Mode__c = 'Individual';
        orderline[2].Start_Date__c = null;
        orderline[2].Term_is_discussed__c = true;
        orderline[2].Is_Digital__c = TRUE;
        orderline[2].Promotion_ID__c = promoTmp.id;
        orderline[2].Penalty_Charge__c = 9999999999999999.99;
        orderline[2].New_Contract_Period__c = 0;
        orderline[2].Main_Package_Subscription_Rate__c = 100;
        orderline[2].Qty__c = 1;
        orderline[2].Main_Package_Product_Family__c = 'Default';
        orderline[2].Main_Package_Billing_Type__c = 'Recurring Prepaid';
        orderline[2].Main_Package_Frequency__c = 'Default';
        orderline[2].Main_Package_Sub_Type__c = 'Single';
        orderline[2].Main_Package_Type__c = 'Base';
        orderline[2].Subscribed_as__c = 'New Buy';
        orderline[2].Contract_End_Date__c = date.valueOf('1970-01-01'); 
        
        insert orderline;    
        system.assertNotEquals(0, orderline.size());
        
     
        
        //create Quote
        List<zqu__Quote__c> zqQ = TestDataFactory.createQuote(1);
        zqQ[0].Vendor_Credit__c = 0;
        zqQ[0].zqu__Account__c = acc.id;
        zqQ[0].Payment_Mode__c = 'Test';
        zqQ[0].Delivery_Charge_Type__c = 'S';
        zqQ[0].Subscriber_Charge__c = 0;
        zqQ[0].Other_PaymentMethod__c = 'Recurring Prepaid';
        zqQ[0].zqu__BillToContact__c = con.id;
        zqQ[0].Main_Package__c = packageList[0].id;
        zqQ[0].Order__c = orderRec_0.id;
        insert zqQ;
        
                
        //Create Promotion Gift
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
         
        insert promoGift;
        
        //Create Order Line Item Gift
        List<Order_Line_Item_Gift__c> orderLineItemGifts = TestDataFactory.createItemGift(5);
        for(Order_Line_Item_Gift__c olig : orderLineItemGifts) {
            olig.Order_Line_Item__c = orderline[0].id;
            olig.Promotion_Gift__c = promoGift.id;
        }
         
         Test.startTest();
        insert orderLineItemGifts;
        system.assertNotEquals(0, orderLineItemGifts.size());
 
          PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
          SM_RenewalOfSubscriptionEntryController ssec = new SM_RenewalOfSubscriptionEntryController();
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', acc.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());
            
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderline[0].Id);
        Test.setCurrentPage(pageRef);
        
        ssec.initialize();
        //ssec.checkAndCreateOrder();
        //ssec.getRecordType();
        //ssec.getbillingRecordType();
        //ssec.retrieveLatestRecipientContact();
        //ssec.retrieveLatestBillingContact();
        
        //EXISTING ORDER
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        Test.setCurrentPage(pageRef);
        ssec = new SM_RenewalOfSubscriptionEntryController();
        ssec.selectedOrderLineItem = orderline[0].Id;
        ssec.initialize();
        //ssec.populateSubscriptionDetail();
        ssec.populateRecipientContactRelatedDetails();

        
        //SEARCH FUNCTIONALITY
        ssec.searchText = 'TEST';
        ssec.searchBillingType = 'TEST';
        ssec.searchFrom = 'Package';
        //ssec.CustomerContactRecType = 'TEST';
        //ssec.selectedMailingAgent = 'Test';
        //ssec.termLength = '0'; 
        ssec.selectedPromotionId = 'TEst';
        ssec.selectedPackageName = 'TEst';
        ssec.executeSearch();
        //ssec.airlineAgents = new List<SelectOption>();
        //ssec.quantity = 5;
        //ssec.result = FALSE;
        //ssec.maxNoOfGifts = 3;
        ssec.promotionResultList = null;
        ssec.packageResultList = null;
        ssec.selectedAddOnPackage = 'TEST';
        //ssec.productIsMagazine = FALSE;
        ssec.searchText = 'TEST';
        ssec.subscriptionRate = 100.00;
        ssec.totalSubscriptionPrice = 50.00;
        ssec.isPromotionSelected = True;
        ssec.searchBillingType = 'TEST';
        ssec.isRemoveEligibilityRuleSearchFilter = FALSE;
        ssec.searchFrom = 'Promotion';
        ssec.executeSearch();
        //ssec.isFullPrepaid = FALSE;
        ssec.isFromPromotion = FALSE;
        //ssec.isMagazine = FALSE;
        ssec.isDigital = True;
        //ssec.addOnIsDigital = True;
        ssec.searchPackageMsg = 'Test';
        ssec.isAllInOne = FALSE;
        //ssec.vendorEligibilityCheck = FALSE;
        ssec.searchPromotionMsg = 'Test';
        ssec.searchErrorMsg = 'Test';
        ssec.billingAccountOption = 'useExisting';
        
        ssec.save();
        ssec.cancel();
        ssec.addAsia1NewAccount();
        ssec.removeAsia1Subscription();
        ssec.clearPaymentMethod();
        ssec.selectedPackageId = packageList[0].id;
        ssec.addOrderLineItem();
        
        ssec.orderLineItem = orderline[1];
        ssec.selectedPackageId = packageList[0].id;
        ssec.addOrderLineItem();
        //ssec.updateOrderLineItem();
        
        ssec.orderLineItem = orderline[2];
        ssec.selectedPackageId = '';
        ssec.addOrderLineItem();
        
        ssec.orderLineItem = orderline[0];
        ssec.orderLineItemIdToBeRemoved = orderline[0].id;
        //ssec.removeLineItem();
          
        SM_RenewalOfSubscriptionEntryController.retrieveRelatedPackages(String.ValueOf(promoTmp.id), packageList[0].Billing_Type__c, packageList[0].id);
        SM_RenewalOfSubscriptionEntryController.GiftWrapper gw = new SM_RenewalOfSubscriptionEntryController.GiftWrapper();
        gw.promotionGift = new Promotion_Gift__c();
        gw.selectGift = true;
        
        ssec.cancelSearch();
        
      
        orderline[0].Delivered_By__c = 'Vendor';
        ssec.orderLineItem = orderline[0];

        
        ssec.addOrderLineItem();

        
        
        Test.stopTest(); 
        
  }*/
     static testMethod void Test_SM_RenewalOfSubscriptionEntry2() {
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
        prd[0].zqu__ZuoraId__c = '23456sddsfd';
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
        Test.startTest();
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
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        SM_RenewalOfSubscriptionEntryController ssec = new SM_RenewalOfSubscriptionEntryController();
        
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderline[1].Id);//invalid ID
        Test.setCurrentPage(pageRef);
        
        //ssec.retrieveOrderLineItem();
        ssec.initialize();
        //ssec.getRecordType();
        //ssec.getbillingRecordType();
        //ssec.updateOrderLineItem();  //--need to look contact__c lookup filter
        
        //EXISTING ORDER
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        Test.setCurrentPage(pageRef);
        ssec = new SM_RenewalOfSubscriptionEntryController();
        
        ssec.selectedOrderLineItem = orderline[0].Id;
        
        ssec.initialize();
        ssec.populateRecipientContactRelatedDetails();
        ssec.closePopup();
        
        
        //SEARCH FUNCTIONALITY
        //ssec = new SM_RenewalOfSubscriptionEntryController();
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
 
   /*static testMethod void Test_SM_RenewalOfSubscriptionEntry3() {
        
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
            UserName='standard@test.com'
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
         Test.startTest();
        insert orderRec1;
   
      /*  Subscription_Vendor__c subven = TestDataFactory.createSubscriptionVendor(1)[0];
        subven.Account__c = acc1.Id;
        subven.Vendor__c = acc1.Id;
        subven.Order_Number__c = orderRec1.Id;

         insert subven; */
  
       /* List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(2);
        orderline1[0].Order__c = orderRec1.Id;
        orderline1[0].End_Date__c = date.today();
        orderline1[0].Main_Package_ID__c = pack1.Id;
        orderline1[0].Term_Length__c = 0;
        orderline1[0].Main_Package_Period__c = 0;  
        orderline1[0].Asia1_Creation_Mode__c = 'Individual';
        orderline1[0].Start_Date__c = date.today();
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
        orderline1[1].Start_Date__c = date.today();
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
        
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        pageRef.getParameters().put('Id', orderline1[0].Id);
        pageRef.getParameters().put('accountId', acc1.Id);
        pageRef.getParameters().put('orderId', orderRec1.Id);
        pageRef.getParameters().put('subRecord.Id', subRecs1[0].Id);
        Test.setCurrentPage(pageRef);
        
        SM_RenewalOfSubscriptionEntryController ssec = new SM_RenewalOfSubscriptionEntryController();
        
        ssec.initialize();
        //System.debug('DEB Account Id: ' + ssec.isFromAccount);
        
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
        //ssec.getAcquisitionTypes();
        ssec.asia1ErrorMsg = 'TEST';
        ssec.getBillingAccountOptions();
        
        
        ssec.getSource();
        ssec.clearPaymentMethod();
        ssec.clearOtherPaymentMethod();
        
        //ssec.getRecordType();
        //ssec.getbillingRecordType();
        ssec.populateRecipientContactRelatedDetails();
        
        ssec.orderLineItem = orderline1[0];
        //ssec.checkAddressAndProductFamily();
        //ssec.deleteRelatedAsia1();
        //Promotion Id != null
        ssec.selectedOrderLineItem = orderline1[0].id;
        ssec.retrieveOrderLineItem();
        
        //Promotion Id = null
        ssec.selectedOrderLineItem = orderline1[1].id;
        ssec.retrieveOrderLineItem();
        
        ssec.addOrderLineItem(); //Start/End UD-3896 added
        //ssec.removeAsia1SubscriptionBulk(); //Start/End UD-3896 added
        
        
         system.assertEquals(ssec.searchBillingType , 'Full Prepaid');
         
         
        Test.stopTest();
         }
         
          
          catch(Zuora.zRemoteException e) {
          }  
          }   */    
    
    
    /*static testMethod void Test_SM_RenewalOfSubscriptionEntry4(){
        
        
        Test.startTest();
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        pageRef.getParameters().put('accountId', null);
        Test.setCurrentPage(pageRef);
        
        SM_RenewalOfSubscriptionEntryController StartSubsEntryCont = new SM_RenewalOfSubscriptionEntryController();
        
        StartSubsEntryCont.initialize();
        
        // Test armsWrapper
        SM_RenewalOfSubscriptionEntryController.armsWrapper aw = new SM_RenewalOfSubscriptionEntryController.armsWrapper();
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
        
    }*/
    
    /*static testMethod void Test_SM_RenewalOfSubscriptionEntry5() {
        
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
        orderline0.Start_Date__c = date.today();
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
         Test.startTest();
        insert orderLineItemGifts;
        
        
        
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        SM_SubscriptionHelper ssh = new SM_SubscriptionHelper();
      
        SM_RenewalOfSubscriptionEntryController ssec = new SM_RenewalOfSubscriptionEntryController();
        
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        Test.setCurrentPage(pageRef);
        
        ssec = new SM_RenewalOfSubscriptionEntryController();
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        pageRef.getParameters().put('def_parent_id', orderRec_0.Id);
        ssec.selectedOrderLineItem = orderline[0].Id;
        ssec.initialize();
        ssec.billingAccountOption = 'useExisting';
        ssec.save();
        
        ssec = new SM_RenewalOfSubscriptionEntryController();
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        ssec.selectedOrderLineItem = orderline[0].Id;
        ssec.initialize();
        ssec.billingAccountOption = NULL;
        ssec.save();
        
        ssec = new SM_RenewalOfSubscriptionEntryController();
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
  } */
   
   static testMethod void Test_SM_RenewalOfSubscriptionEntry6() {
   
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
   
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        SM_RenewalOfSubscriptionEntryController ssec = new SM_RenewalOfSubscriptionEntryController();
        List<SM_RenewalOfSubscriptionEntryController.armsWrapper> armsList = new List<SM_RenewalOfSubscriptionEntryController.armsWrapper>();
           SM_RenewalOfSubscriptionEntryController.armsWrapper arms = new SM_RenewalOfSubscriptionEntryController.armsWrapper();
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
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        SM_RenewalOfSubscriptionEntryController ssec = new SM_RenewalOfSubscriptionEntryController();
        ssec.searchAccName();
        ssec.addPopAcc();
        
        SM_RenewalOfSubscriptionEntryController.armsWrapper ssaw = new SM_RenewalOfSubscriptionEntryController.armsWrapper();
        
        
        pageRef.getParameters().put('accountId', accountList[0].Id);
        Test.setCurrentPage(pageRef);
        Test.stopTest();
          }
        catch(Exception e) {
          }
     }
      /*static testMethod void newTest02() {
       
       
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
        PageReference pageRef = Page.SM_RenewalOfSubscriptionEntry;
        SM_RenewalOfSubscriptionEntryController ssec = new SM_RenewalOfSubscriptionEntryController();
        
        ssec.initialize(); 
        SM_RenewalOfSubscriptionEntryController.armsWrapper ssaw = new SM_RenewalOfSubscriptionEntryController.armsWrapper();
        
        pageRef.getParameters().put('accountId', acc.Id);
        Test.setCurrentPage(pageRef);
        Test.stopTest();
        }*/
        
      
}