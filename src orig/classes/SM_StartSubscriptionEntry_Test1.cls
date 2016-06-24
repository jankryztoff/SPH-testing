@isTest (seeAllData= true)
private class SM_StartSubscriptionEntry_Test1 {
    
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
        promoTmp_global.Effective_Start_Date__c = date.Today();
        promoTmp_global.Effective_End_Date__c = date.Today()+1;
        promoTmp_global.Active__c = true;
        
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
 /*APRIL   
    //account is null
    static testMethod void Test_SM_StartSubscriptionEntry_01() {
        setAllData();
        
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
    }
    APRIL*/
    //orderLineItem.Term_is_discussed__c is true
 /*   static testMethod void Test_SM_StartSubscriptionEntry_02() {
        setAllData();
        
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
        */
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
        
  /*      
                
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
        //ssec.retrieveOrderLineItem();
        ssec.addOrderLineItem();
        
        
    }
    
*/
   
   static testMethod void Test_SM_StartSubscriptionEntryAPRIL() {
        
       
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
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack .Package_Price__c = 3;
        pack .Billing_Type__c = 'Recurring Prepaid';
        pack .Package_Type__c = 'Add on';
        pack .Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        insert pack ;
        //system.assertNotEquals(0, packageList.size());
        
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
        pItem.Package__c = pack.Id;
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
        promoTmp.Active__c = true;
        promoTmp.Effective_Start_Date__c = date.Today();
        promoTmp.Effective_End_Date__c = date.Today() + 1;
        insert promoTmp;
       
        Promotion_Package__c promotionPackage = TestDataFactory.createPromotionPackage(1)[0];
        promotionPackage.Promotion__c = promoTmp.id;
        promotionPackage.Package_Name__c = pack.id;
        insert promotionPackage;
         
       
        
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

        orderline[0].End_Date__c = date.today()+30;
        orderline[0].Main_Package_ID__c = pack.Id;
        orderline[0].Addon_Package__c = pack.id;
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
        orderline[1].End_Date__c = date.today()+30;
        orderline[1].Addon_Package__c = pack.id;
        orderline[1].Main_Package_ID__c = pack.Id;
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
        orderline[2].End_Date__c = date.today()+40;
        orderline[2].Addon_Package__c = pack.id;
        orderline[2].Main_Package_ID__c = pack.Id;
        orderline[2].Term_Length__c = 0;
        orderline[2].Main_Package_Period__c = 0;  
        orderline[2].Asia1_Creation_Mode__c = 'Individual';
        orderline[2].Start_Date__c = date.today() + 1;
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
        zqQ[0].Main_Package__c = pack.id;
        zqQ[0].Order__c = orderRec_0.id;
        insert zqQ;
       /* 
        Package__c pack = TestDataFactory.createPackage(1);
        pack .Package_Price__c = 3;
        pack .Billing_Type__c = 'Recurring Prepaid';
        pack .Package_Type__c = 'Add on';
        pack .Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        insert pack;
       */         
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
        
        transient string sText = 'Promotions';
        string sBillType = 'Recurring Prepaid';
 
          PageReference pageRef = Page.SM_StartSubscriptionEntry;
          SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', acc.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());
            
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderline[0].Id);
        Test.setCurrentPage(pageRef);
        ssec.searchText = sText;
        ssec.initialize();
        ssec.searchBillingType = sBillType;
        ssec.getRecordType();
        ssec.getbillingRecordType();
        ssec.retrieveLatestRecipientContact();
        ssec.retrieveLatestBillingContact();
        
        //EXISTING ORDER
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('Id', orderRec_0.Id);
        Test.setCurrentPage(pageRef);
        ssec = new SM_StartSubscriptionEntryController();
        ssec.selectedOrderLineItem = orderline[0].Id;
        ssec.initialize();
        //ssec.populateSubscriptionDetail();
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
        ssec.selectedPackageId = pack.id;
        ssec.addOrderLineItem();
        
        ssec.orderLineItem = orderline[1];
        ssec.selectedPackageId = pack.id;
        ssec.addOrderLineItem();
        ssec.updateOrderLineItem();
        
        ssec.orderLineItem = orderline[2];
        ssec.selectedPackageId = '';
        ssec.addOrderLineItem();
        
        ssec.orderLineItem = orderline[0];
        ssec.orderLineItemIdToBeRemoved = orderline[0].id;
        //ssec.removeLineItem(); //CHA
        
        SM_StartSubscriptionEntryController.retrieveRelatedPackages(String.ValueOf(promoTmp.id), pack.Billing_Type__c, String.ValueOf(acc.id), '1', 'true');
        SM_StartSubscriptionEntryController.GiftWrapper gw = new SM_StartSubscriptionEntryController.GiftWrapper();
        gw.promotionGift = new Promotion_Gift__c();
        gw.selectGift = true;
        
        ssec.cancelSearch();
        
      
        orderline[0].Delivered_By__c = 'Vendor';
        ssec.orderLineItem = orderline[0];

        
        //ssec.addOrderLineItem(); //CHA
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        //database.insert(cas); //CHA
        
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCtrlr2 = new ApexPages.StandardController(new Order__c());
        
        ApexPages.currentPage().getParameters().put('id', null);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('def_parent_id', cas.Id);
        ApexPages.currentPage().getParameters().put('contactId', con.Id);
        
        SM_StartSubscriptionEntryController ssec2 = new SM_StartSubscriptionEntryController();

        //ssec2.initialize(); //CHA
        //SM_StartSubscriptionEntryController.retrieveRelatedPackages('','','','','false'); //CHA
        SM_StartSubscriptionEntryController.retrieveRelatedPackages('','','','','true');
        
        Test.stopTest(); 
    }
}