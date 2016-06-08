/**
 * Base Class Name: PromoEligbilityRule
 * @author: Accenture IDC (sudha Kumari)
 * Date Created: <10/24/2015>
 * Modified by: Joyrem Zarmaine D. Ayuman
 * Date Modified: June 19, 2015
 * Modification: Added "String.valueOf(subRecord.id)" in lines 375, 745, 1484 
 * Requirement/Project Name: <SPH>
 * @description: Test Class for PromoEligbilityRule
 */

@isTest(seeAllData=true)
private class PromoEligbilityRuleTest { 
/* TODO questionable Test class since not base class is tested.
    
    static testmethod void promoEligibilityRuleTest1(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);
        
        Promotion__c promo = new Promotion__c();
        promo.Name = 'Promotion';
        promo.Promotion_Code__c = 'yasyd97';
        promo.Effective_Start_Date__c = date.today();
        promo.Effective_End_Date__c = date.today().addDays(1);
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge__c = '100';
        promo.Penalty_Charge_Override__c = 500.00;
        database.insert(promo);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Package';
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
        promopack.Promotion__c = promo.id;
        promopack.Package_Name__c = pack.id;
        database.insert(promopack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        database.insert(zProduct);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Cash';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        database.insert(billAcc);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con);
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);            
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = billAcc.Billing_Type__c;
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        database.insert(order);
     
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;
        //subRecord.Order__c = order.id;
        subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;        
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Promotion_1__c = promo.id;
        database.insert(subRecord);
        
        Product_Family__c prodFamily = new Product_Family__c();
        prodFamily.Product_Family__c = 'CODEFAMILY2424';
        prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
        database.insert(prodFamily);
        
        //Package_Product_Family__c family = new Package_Product_Family__c();
        //family.Package_Name__c = pack.id;
        //family.Product_Family__c = prodFamily.id;
        //insert family;
        
        List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
            spc.Name = 'Sub Product Charge Test';
            spc.Zuora__Subscription__c = subRecord.id;
            spc.Zuora__RatePlanName__c = 'Sample Rate'; 
            spc.Zuora__ProductSKU__c = 'Product SKU'; 
        }
        database.insert(subProductCharge);
        
        List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c prp:productRatePlan) {
            prp.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prp.zqu__ZProduct__c = zProduct.id;
            prp.RatePlanCode__c = 'Super Plan';
            prp.SubscriptionFrequency__c = '0';
            prp.zqu__ZuoraId__c = subRecord.id;
            prp.RatePlanType__c = 'Bill Plan';  
            prp.RatePlanSubType__c = 'Standard';
        }
        database.insert(productRatePlan);
        
        List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1);
        for(zqu__ProductRatePlanCharge__c prpc:productRatePlanCharge) {
            prpc.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prpc.zqu__ProductRatePlan__c = productRatePlan[0].id;
            prpc.PublicationCode__c = 'PUB1';
            prpc.zqu__ZuoraId__c = subRecord.id;
        }
        database.insert(productRatePlanCharge);
        
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
        for (Package_Item__c pItem : pItems) {
            pItem.Package__c = pack.Id;
            pItem.Duration_in_months__c = '3';
            pItem.Effective_Start_Month__c = '3';
            pItem.Product_Rate_Plan__c = productRatePlan[0].id;
            pItem.Product_Family__c = prodFamily.id;
        }
        
               
        database.insert(pItems);
        
        order.Subscription__c = subRecord.id;
        order.Base_Subscription__c= subRecord.id;
        database.update(order);
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c =  date.today();
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        oli.Term_Length__c = 1;
        oli.Start_Date__c = date.today().addDays(1); //added by jjzs
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        //oli.Promotion_ID__c = promo.id;//
        oli.Addon_Package__c = pack.id;
        oli.Term_is_discussed__c = TRUE;
        oli.Is_Digital__c = TRUE;
        Test.startTest(); //<-------HERE  
        database.insert(oli);
        
        Promotion_Gift__c promgift = TestDataFactory.createPromotionGift(1)[0];
        promgift.Promotion__c = promo.id;
        promgift.Gift_Inventory__c = 1;
        promgift.Gift_Issued__c = 1;
        promgift.Gift_Redeemed__c = 1;
        
        database.insert(promgift);
        
        Order_Line_Item_Gift__c oligift = TestDataFactory.createItemGift(1)[0];
        oligift.Order_Line_Item__c = oli.id;
        oligift.Promotion_Gift__c = promgift.id;
        oligift.Redemption_Date__c = date.today().addDays(2);
        oligift.Redemption_Quantity__c = 2;
        oligift.Order_Quantity__c = 3;
              
        database.insert(oligift);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        database.insert(cas);
        
        subRecord.Order_Line_Item_Number__c = oli.id;        
        database.update(subRecord);        
        
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
           
        database.insert(pubList);          
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        database.insert(SAF);
        
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        database.insert(PAF);
        
        //create Asia1__c
        Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
        tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        tmpAsia1.Display_Name__c = 'Test';
        tmpAsia1.Email__c = 'test@email.com' ;
        tmpAsia1.Password__c = 'aBcD3Fg';
        tmpAsia1.Contact__c = con.Id;
             
        database.insert(tmpAsia1);
        
        List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
        
        asiaSubList[0].Asia1__c = tmpAsia1.Id;
        asiaSubList[0].Subscription__c = subRecord.Id;
        asiaSubList[0].Status__c = 'Enabled';
        asiaSubList[0].Order_Line_Item__c = oli.Id;
        asiaSubList[0].Service_Access_Flag__c = SAF.Id;

        database.insert(asiaSublist);
        
        //create publications
        List<Publication__c> publicationList = TestDataFactory.createPublication(2);
        publicationList[0].Product_Family__c = 'Stray';
        publicationList[0].Published_Days__c = 'YYYYYYY';
        publicationList[0].Publication_Type__c = 'A';
        publicationList[1].Product_Family__c = 'Time';
        publicationList[1].Published_Days__c = 'YYYYYYY';
        publicationList[1].Publication_Type__c = 'A';
        
        database.insert(publicationList);

        List<Product_Publication__c> prodPub = TestDataFactory.createProductPublication(2);        
        prodPub[0].Publication_Code__c = publicationList[0].id;
        prodPub[0].ZProduct__c = zProduct.id;
        prodPub[1].Publication_Code__c = publicationList[1].id;
        prodPub[1].ZProduct__c = zProduct.id;
        database.insert(prodPub);
        
        //create oliv
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        for(Order_Line_Item_Vendor__c oliv:orderLineItemList){
            oliv.Order__c = order.id;
        }
        database.insert(orderLineItemList);
     
        ApexPages.currentPage().getParameters().put('Id', order.id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('subscriptionId', subRecord.id);

     List<Order__c> myId = [SELECT Id, Status__c, Order_Type__c, Subscription__c, Account__c
                   FROM Order__c 
                   WHERE Account__c =: order.Account__c
                   AND Order_Type__c =: order.Order_Type__c
                   //AND Status__c = 'Draft'];
                   AND Subscription__c =: order.Subscription__c];        
  //asserts if expected value is equal to actual value
  
        //System.assertEquals(1, myId.size());
        
        
        Order__c ord; 
        for(Order__c o: myId){
            if(o.id == order.id){
                ord = o;
            }
        }    
        System.assertNotEquals(null, ord);    
        System.assertEquals(order.id, ord.id);
       
        
        Zuora__Subscription__c mySub = [SELECT Id, Order_Number_1__c
                                       FROM Zuora__Subscription__c
                                       WHERE Id =: subRecord.id 
                                        and Order_Number_1__c =: subRecord.Order_Number_1__c];
                                        
        //asserts if expected value is equal to actual value
        System.assertEquals(mySub.id, subRecord.id);
        System.assertEquals(mySub.Order_Number_1__c, subRecord.Order_Number_1__c);
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
        
        controller.getCOS_PACKAGE();
        controller.getCOS_QUANTITY();
        controller.getEarliestStart(pack.id);
        controller.activateMaps(pack.id);
        controller.retrieveActiveSubscriptions();
                
        //@description: When Order Type is Check //        
        controller.save();
        
        controller.asia1SelectedExistingId = String.valueOf(tmpAsia1.id);
        controller.addAsia1NewAccount();
        controller.addAsia1ExistingAccount();
        
        controller.asia1SingleAccount = tmpAsia1;
        controller.validateNewAsia1Account();
        controller.getAsia1ExistingAccounts();
        controller.removeAsia1Subscription();
        
        controller.getDeliveryChargeTypes();
        controller.getBillingAccountOptions();
        controller.fetchBillingAccount();
        controller.getSource();        
        
        controller.clearPaymentMethod();
        controller.clearOtherPaymentMethod();
        
        controller.retrieveAdminFee();
        // @description: I dont know the reason of the error. I just checked that zs.Contract End Date 
        // has data. 
        //controller.retrieveAdminCharge();
        
        controller.searchText = 'Package';
        controller.searchBillingType = 'Prepaid';
        controller.searchFrom = 'Package';
        controller.executeSearch();
        
        controller.searchText = 'Promotion';
        controller.searchBillingType = 'Full Prepaid';
        controller.searchFrom = 'Promotion';        
        controller.executeSearch();
        
        controller.selectedAddOnPackage = String.valueOf(pack.id);
        controller.populateAddOn();
        
        SM_ChangeOfSubscriptionEntryController.retrieveRelatedPackages(String.valueOf(promo.id), pack.Billing_Type__c, String.valueOf(acc.id), 'Add', 'on', String.valueOf(subRecord.id));
            
        controller.cancel();
        Test.stopTest();
    }
    
    static testmethod void promoEligibilityRuleTest2(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.Name = 'TEST1';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);
        
        Promotion__c promo = new Promotion__c();
        promo.Name = 'Promotion';
        promo.Promotion_Code__c = 'yasyd97';
        promo.Effective_Start_Date__c = date.today();
        promo.Effective_End_Date__c = date.today().addDays(1);
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge__c = '100';
        promo.Penalty_Charge_Override__c = 500.00;
        database.insert(promo);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Package';
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
        promopack.Promotion__c = promo.id;
        promopack.Package_Name__c = pack.id;
        database.insert(promopack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        database.insert(zProduct);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'cash';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        database.insert(billAcc);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con);
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);            
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;     
        order.Billing_Type__c = billAcc.Billing_Type__c;
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;
        //subRecord.Order__c = order.id;
        //subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;        
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Promotion_1__c = promo.id;
        database.insert(subRecord);
        
        Product_Family__c prodFamily = new Product_Family__c();
        prodFamily.Product_Family__c = 'CODEFAMILY2424';
        prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
        database.insert(prodFamily);
        
        //Package_Product_Family__c family = new Package_Product_Family__c();
        //family.Package_Name__c = pack.id;
        //family.Product_Family__c = prodFamily.id;
        //insert family;
        
        List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
            spc.Name = 'Sub Product Charge Test';
            spc.Zuora__Subscription__c = subRecord.id;
            spc.Zuora__RatePlanName__c = 'Sample Rate'; 
            spc.Zuora__ProductSKU__c = 'Product SKU'; 
        }
        database.insert(subProductCharge);
        
        List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c prp:productRatePlan) {
            prp.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prp.zqu__ZProduct__c = zProduct.id;
            prp.RatePlanCode__c = 'Super Plan';
            prp.SubscriptionFrequency__c = '0';
            prp.zqu__ZuoraId__c = subRecord.id;
            prp.RatePlanType__c = 'Bill Plan';  
            prp.RatePlanSubType__c = 'Standard';
        }
        database.insert(productRatePlan);
        
        List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1);
        for(zqu__ProductRatePlanCharge__c prpc:productRatePlanCharge) {
            prpc.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prpc.zqu__ProductRatePlan__c = productRatePlan[0].id;
            prpc.PublicationCode__c = 'PUB1';
            prpc.zqu__ZuoraId__c = subRecord.id;
        }
        database.insert(productRatePlanCharge);
        
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
        for (Package_Item__c pItem : pItems) {
            pItem.Package__c = pack.Id;
            pItem.Duration_in_months__c = '3';
            pItem.Effective_Start_Month__c = '3';
            pItem.Product_Rate_Plan__c = productRatePlan[0].id;
            pItem.Product_Family__c = prodFamily.id;
        }
        database.insert(pItems);
        
        order.Subscription__c = subRecord.id;
        order.Base_Subscription__c= subRecord.id;
        database.update(order);
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c =  date.today();
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Start_Date__c = date.today().addDays(1); //added by jjzs
        oli.Qty__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        //oli.Promotion_ID__c = promo.id;
        oli.Addon_Package__c = pack.id;
        oli.Term_is_discussed__c = TRUE;
        oli.Is_Digital__c = TRUE;
        database.insert(oli);
        
        Promotion_Gift__c promgift = TestDataFactory.createPromotionGift(1)[0];
        promgift.Promotion__c = promo.id;
        promgift.Gift_Inventory__c = 1;
        promgift.Gift_Issued__c = 1;
        promgift.Gift_Redeemed__c = 1;
        database.insert(promgift);
        
        Order_Line_Item_Gift__c oligift = TestDataFactory.createItemGift(1)[0];
        oligift.Order_Line_Item__c = oli.id;
        oligift.Promotion_Gift__c = promgift.id;
        oligift.Redemption_Date__c = date.today().addDays(2);
        oligift.Redemption_Quantity__c = 2;
        oligift.Order_Quantity__c = 3;
        database.insert(oligift);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        database.insert(cas);
        
        subRecord.Order_Line_Item_Number__c = oli.id;        
        database.update(subRecord);        
        
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
        database.insert(pubList);          
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        database.insert(SAF);
        
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        database.insert(PAF);
        
        //create Asia1__c
        Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
        tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        tmpAsia1.Display_Name__c = 'Test';
        tmpAsia1.Email__c = 'test@email.com' ;
        tmpAsia1.Password__c = 'aBcD3Fg';
        tmpAsia1.Contact__c = con.Id;
        database.insert(tmpAsia1);
        
        List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
        
        asiaSubList[0].Asia1__c = tmpAsia1.Id;
        asiaSubList[0].Subscription__c = subRecord.Id;
        asiaSubList[0].Status__c = 'Enabled';
        asiaSubList[0].Order_Line_Item__c = oli.Id;
        asiaSubList[0].Service_Access_Flag__c = SAF.Id;
        database.insert(asiaSublist)   ;
        
        //create publications
        List<Publication__c> publicationList = TestDataFactory.createPublication(2);
        publicationList[0].Product_Family__c = 'Stray';
        publicationList[0].Published_Days__c = '7';
        publicationList[0].Publication_Type__c = 'A';
        publicationList[1].Product_Family__c = 'Time';
        publicationList[1].Published_Days__c = '7';
        publicationList[1].Publication_Type__c = 'A';
        database.insert(publicationList);

        List<Product_Publication__c> prodPub = TestDataFactory.createProductPublication(2);        
        prodPub[0].Publication_Code__c = publicationList[0].id;
        prodPub[0].ZProduct__c = zProduct.id;
        prodPub[1].Publication_Code__c = publicationList[1].id;
        prodPub[1].ZProduct__c = zProduct.id;
        database.insert(prodPub);
        
        //create oliv
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        for(Order_Line_Item_Vendor__c oliv:orderLineItemList){
            oliv.Order__c = order.id;
        }
        database.insert(orderLineItemList);
        
        ApexPages.currentPage().getParameters().put('Id', order.id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('subscriptionId', subRecord.id);
        
        Order__c myId = [SELECT Id, Status__c
                   FROM Order__c 
                   WHERE Order_Type__c =: order.Order_Type__c 
                   AND Account__c =: order.Account__c 
                   AND Status__c = 'Draft'
                   AND Subscription__c =: order.Subscription__c limit 1];
        
        //asserts if expected value is equal to actual value
        system.assertEquals(order.id, myId.id);
        
        Test.startTest();   
        
        Zuora__Subscription__c mySub = [SELECT Id, Order_Number_1__c
                                       FROM Zuora__Subscription__c
                                       WHERE Id =: subRecord.id 
                                        and Order_Number_1__c =: subRecord.Order_Number_1__c];
        
        //asserts if expected value is equal to actual value
        System.assertEquals(mySub.id, subRecord.id);
        System.assertEquals(mySub.Order_Number_1__c, subRecord.Order_Number_1__c);
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
        
        controller.getCOS_PACKAGE();
        controller.getCOS_QUANTITY();
        controller.getEarliestStart(pack.id);
        controller.activateMaps(pack.id);
        controller.retrieveActiveSubscriptions();
                
        //@description: When Order Type is Check        
        controller.save();
        
        controller.asia1SelectedExistingId = String.valueOf(tmpAsia1.id);
        controller.addAsia1NewAccount();
        controller.addAsia1ExistingAccount();
        
        controller.asia1SingleAccount = tmpAsia1;
        controller.validateNewAsia1Account();
        controller.getAsia1ExistingAccounts();
        controller.removeAsia1Subscription();
        
        controller.getDeliveryChargeTypes();
        controller.getBillingAccountOptions();
        controller.fetchBillingAccount();
        controller.getSource();        
        
        controller.clearPaymentMethod();
        controller.clearOtherPaymentMethod();
        
        controller.retrieveAdminFee();
        // @description: I dont know the reason of the error. I just checked that zs.Contract End Date 
        // has data. 
        //controller.retrieveAdminCharge();
        
        controller.searchText = 'Package';
        controller.searchBillingType = 'Prepaid';
        controller.searchFrom = 'Package';
        controller.executeSearch();
        
        controller.searchText = 'Promotion';
        controller.searchBillingType = 'Full Prepaid';
        controller.searchFrom = 'Promotion';        
        controller.executeSearch();
        
        controller.selectedAddOnPackage = String.valueOf(pack.id);
        controller.populateAddOn();
        
        SM_ChangeOfSubscriptionEntryController.retrieveRelatedPackages(String.valueOf(promo.id), pack.Billing_Type__c, String.valueOf(acc.id), 'Add', 'on',String.valueOf(subRecord.id));
            
        controller.cancel();
    }
    static testmethod void promoEligibilityRuleTest3(){
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
       // acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);
        
        Promotion__c promo = new Promotion__c();
        promo.Name = 'Promotion';
        promo.Promotion_Code__c = 'yasyd97';
        promo.Effective_Start_Date__c = date.today();
        promo.Effective_End_Date__c = date.today().addDays(1);
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge__c = '100';
        promo.Penalty_Charge_Override__c = 500.00;
        database.insert(promo);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Package';
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
        promopack.Promotion__c = promo.id;
        promopack.Package_Name__c = pack.id;
        database.insert(promopack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        database.insert(zProduct);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_type__c = 'cash';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        database.insert(billAcc);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con);
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);            
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;   
        order.Billing_type__c  = billAcc.Billing_type__c;
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;
        //subRecord.Order__c = order.id;
        //subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;        
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Promotion_1__c = promo.id;
        database.insert(subRecord);
        
        Product_Family__c prodFamily = new Product_Family__c();
        prodFamily.Product_Family__c = 'CODEFAMILY2424';
        prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
        database.insert(prodFamily);
        
        //Package_Product_Family__c family = new Package_Product_Family__c();
        //family.Package_Name__c = pack.id;
        //family.Product_Family__c = prodFamily.id;
        //insert family;
        
        List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
            spc.Name = 'Sub Product Charge Test';
            spc.Zuora__Subscription__c = subRecord.id;
            spc.Zuora__RatePlanName__c = 'Sample Rate'; 
            spc.Zuora__ProductSKU__c = 'Product SKU'; 
        }
        database.insert(subProductCharge);
        
        List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c prp:productRatePlan) {
            prp.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prp.zqu__ZProduct__c = zProduct.id;
            prp.RatePlanCode__c = 'Super Plan';
            prp.SubscriptionFrequency__c = '0';
            prp.zqu__ZuoraId__c = subRecord.id;
            prp.RatePlanType__c = 'Bill Plan';  
            prp.RatePlanSubType__c = 'Standard';
        }
        database.insert(productRatePlan);
        
        List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1);
        for(zqu__ProductRatePlanCharge__c prpc:productRatePlanCharge) {
            prpc.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prpc.zqu__ProductRatePlan__c = productRatePlan[0].id;
            prpc.PublicationCode__c = 'PUB1';
            prpc.zqu__ZuoraId__c = subRecord.id;
        }
        database.insert(productRatePlanCharge);
        
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
        for (Package_Item__c pItem : pItems) {
            pItem.Package__c = pack.Id;
            pItem.Duration_in_months__c = '3';
            pItem.Effective_Start_Month__c = '3';
            pItem.Product_Rate_Plan__c = productRatePlan[0].id;
            pItem.Product_Family__c = prodFamily.id;
        }
        database.insert(pItems);
        
        order.Subscription__c = subRecord.id;
        order.Base_Subscription__c= subRecord.id;
        database.update(order);
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c =  date.today();
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Start_Date__c = date.today().addDays(1); //added by jjzs 
        oli.Qty__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        //oli.Promotion_ID__c = promo.id;
        oli.Addon_Package__c = pack.id;
        oli.Term_is_discussed__c = TRUE;
        oli.Is_Digital__c = TRUE;
        database.insert(oli);
        
        Promotion_Gift__c promgift = TestDataFactory.createPromotionGift(1)[0];
        promgift.Promotion__c = promo.id;
        promgift.Gift_Inventory__c = 1;
        promgift.Gift_Issued__c = 1;
        promgift.Gift_Redeemed__c = 1;
        database.insert(promgift);
        
        Order_Line_Item_Gift__c oligift = TestDataFactory.createItemGift(1)[0];
        oligift.Order_Line_Item__c = oli.id;
        oligift.Promotion_Gift__c = promgift.id;
        oligift.Redemption_Date__c = date.today().addDays(2);
        oligift.Redemption_Quantity__c = 2;
        oligift.Order_Quantity__c = 3;
        database.insert(oligift);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        database.insert(cas);
        
        subRecord.Order_Line_Item_Number__c = oli.id;        
        database.update(subRecord);        
        
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
        database.insert(pubList);          
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        database.insert(SAF);
        
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        database.insert(PAF);
        
        //create Asia1__c
        Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
        tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        tmpAsia1.Display_Name__c = 'Test';
        tmpAsia1.Email__c = 'test@email.com' ;
        tmpAsia1.Password__c = 'aBcD3Fg';
        tmpAsia1.Contact__c = con.Id;
        database.insert(tmpAsia1);
        
        List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
        
        asiaSubList[0].Asia1__c = tmpAsia1.Id;
        asiaSubList[0].Subscription__c = subRecord.Id;
        asiaSubList[0].Status__c = 'Enabled';
        asiaSubList[0].Order_Line_Item__c = oli.Id;
        asiaSubList[0].Service_Access_Flag__c = SAF.Id;
        database.insert(asiaSublist)   ;
        
        //create publications
        List<Publication__c> publicationList = TestDataFactory.createPublication(2);
        publicationList[0].Product_Family__c = 'Stray';
        publicationList[0].Published_Days__c = '7';
        publicationList[0].Publication_Type__c = 'A';
        publicationList[1].Product_Family__c = 'Time';
        publicationList[1].Published_Days__c = '7';
        publicationList[1].Publication_Type__c = 'A';
        database.insert(publicationList);

        List<Product_Publication__c> prodPub = TestDataFactory.createProductPublication(2);        
        prodPub[0].Publication_Code__c = publicationList[0].id;
        prodPub[0].ZProduct__c = zProduct.id;
        prodPub[1].Publication_Code__c = publicationList[1].id;
        prodPub[1].ZProduct__c = zProduct.id;
        database.insert(prodPub);
        
        //create oliv
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        for(Order_Line_Item_Vendor__c oliv:orderLineItemList){
            oliv.Order__c = order.id;
        }
        database.insert(orderLineItemList);
        
        ApexPages.currentPage().getParameters().put('Id', order.id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('subscriptionId', subRecord.id);
        
        Order__c myId = [SELECT Id, Status__c
                   FROM Order__c 
                   WHERE Order_Type__c =: order.Order_Type__c 
                   AND Account__c =: order.Account__c 
                   AND Status__c = 'Draft'
                   AND Subscription__c =: order.Subscription__c limit 1];
        
        system.assertEquals(order.id, myId.id);
        
        Test.startTest();   
        
        Zuora__Subscription__c mySub = [SELECT Id, Order_Number_1__c
                                       FROM Zuora__Subscription__c
                                       WHERE Id =: subRecord.id 
                                        and Order_Number_1__c =: subRecord.Order_Number_1__c];
        
        //asserts if expected value is equal to actual value
        System.assertEquals(mySub.id, subRecord.id);
        System.assertEquals(mySub.Order_Number_1__c, subRecord.Order_Number_1__c);
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
        
        controller.getCOS_PACKAGE();
        controller.getCOS_QUANTITY();
        controller.getEarliestStart(pack.id);
        controller.activateMaps(pack.id);
        controller.retrieveActiveSubscriptions();
                
        //@description: When Order Type is Check         
        controller.save();
        
        controller.asia1SelectedExistingId = String.valueOf(tmpAsia1.id);
        controller.addAsia1NewAccount();
        controller.addAsia1ExistingAccount();
        
        controller.asia1SingleAccount = tmpAsia1;
        controller.validateNewAsia1Account();
        controller.getAsia1ExistingAccounts();
        controller.removeAsia1Subscription();
        
        controller.getDeliveryChargeTypes();
        controller.getBillingAccountOptions();
        controller.fetchBillingAccount();
        controller.getSource();        
        
        controller.clearPaymentMethod();
        controller.clearOtherPaymentMethod();
        
        controller.retrieveAdminFee();
        // @description: I dont know the reason of the error. I just checked that zs.Contract End Date 
        // has data. 
        //controller.retrieveAdminCharge();
        
        controller.searchText = 'Package';
        controller.searchBillingType = 'Prepaid';
        controller.searchFrom = 'Package';
        controller.executeSearch();
        
        controller.searchText = 'Promotion';
        controller.searchBillingType = 'Full Prepaid';
        controller.searchFrom = 'Promotion';        
        controller.executeSearch();
        
        controller.selectedAddOnPackage = String.valueOf(pack.id);
        controller.populateAddOn();
        
        SM_ChangeOfSubscriptionEntryController.retrieveRelatedPackages(String.valueOf(promo.id), pack.Billing_Type__c, String.valueOf(acc.id), 'Add', 'on', String.valueOf(subRecord.id));
            
        controller.cancel();
        
    }
    static testmethod void promoEligibilityRuleTest4(){
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        
        database.insert(acc);
        
        
        Promotion__c promo = new Promotion__c();
        promo.Name = 'Promotion';
        promo.Promotion_Code__c = 'yasyd97';
        promo.Effective_Start_Date__c = date.today();
        promo.Effective_End_Date__c = date.today().addDays(1);
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        promo.Penalty_Charge__c = '100';
        promo.Penalty_Charge_Override__c = 500.00;
        database.insert(promo);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Package';
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
        promopack.Promotion__c = promo.id;
        promopack.Package_Name__c = pack.id;
        database.insert(promopack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        database.insert(zProduct);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_type__c = 'cash';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        database.insert(billAcc);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con);
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);            
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;
        order.Billing_type__c  = billAcc.Billing_type__c;
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;
        //subRecord.Order__c = order.id;
        //subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;        
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Promotion_1__c = promo.id;
        database.insert(subRecord);
        
        Product_Family__c prodFamily = new Product_Family__c();
        prodFamily.Product_Family__c = 'CODEFAMILY2424';
        prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
        database.insert(prodFamily);
        
        //Package_Product_Family__c family = new Package_Product_Family__c();
        //family.Package_Name__c = pack.id;
        //family.Product_Family__c = prodFamily.id;
        //insert family;
        
        List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
            spc.Name = 'Sub Product Charge Test';
            spc.Zuora__Subscription__c = subRecord.id;
            spc.Zuora__RatePlanName__c = 'Sample Rate'; 
            spc.Zuora__ProductSKU__c = 'Product SKU'; 
        }
        database.insert(subProductCharge);
        
        List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c prp:productRatePlan) {
            prp.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prp.zqu__ZProduct__c = zProduct.id;
            prp.RatePlanCode__c = 'Super Plan';
            prp.SubscriptionFrequency__c = '0';
            prp.zqu__ZuoraId__c = subRecord.id;
            prp.RatePlanType__c = 'Bill Plan';  
            prp.RatePlanSubType__c = 'Standard';
        }
        database.insert(productRatePlan);
        
        List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1);
        for(zqu__ProductRatePlanCharge__c prpc:productRatePlanCharge) {
            prpc.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prpc.zqu__ProductRatePlan__c = productRatePlan[0].id;
            prpc.PublicationCode__c = 'PUB1';
            prpc.zqu__ZuoraId__c = subRecord.id;
        }
        database.insert(productRatePlanCharge);
        
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
        for (Package_Item__c pItem : pItems) {
            pItem.Package__c = pack.Id;
            pItem.Duration_in_months__c = '3';
            pItem.Effective_Start_Month__c = '3';
            pItem.Product_Rate_Plan__c = productRatePlan[0].id;
            pItem.Product_Family__c = prodFamily.id;
        }
        database.insert(pItems);
        
        order.Subscription__c = subRecord.id;
        order.Base_Subscription__c= subRecord.id;
        database.update(order);
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c =  date.today();
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Start_Date__c = date.today().addDays(1); //added by jjzs
        oli.Qty__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        //oli.Promotion_ID__c = promo.id;
        oli.Addon_Package__c = pack.id;
        oli.Term_is_discussed__c = TRUE;
        oli.Is_Digital__c = TRUE;
        database.insert(oli);
        
        Promotion_Gift__c promgift = TestDataFactory.createPromotionGift(1)[0];
        promgift.Promotion__c = promo.id;
        promgift.Gift_Inventory__c = 1;
        promgift.Gift_Issued__c = 1;
        promgift.Gift_Redeemed__c = 1;
        database.insert(promgift);
        
        Order_Line_Item_Gift__c oligift = TestDataFactory.createItemGift(1)[0];
        oligift.Order_Line_Item__c = oli.id;
        oligift.Promotion_Gift__c = promgift.id;
        oligift.Redemption_Date__c = date.today().addDays(2);
        oligift.Redemption_Quantity__c = 2;
        oligift.Order_Quantity__c = 3;
        database.insert(oligift);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        database.insert(cas);
        
        subRecord.Order_Line_Item_Number__c = oli.id;        
        database.update(subRecord);        
        
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
        database.insert(pubList);          
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);       
        
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        database.insert(SAF);
        
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        database.insert(PAF);
        
        //create Asia1__c
        Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
        tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        tmpAsia1.Display_Name__c = 'Test';
        tmpAsia1.Email__c = 'test@email.com' ;
        tmpAsia1.Password__c = 'aBcD3Fg';
        tmpAsia1.Contact__c = con.Id;
        database.insert(tmpAsia1);
        
        List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
        
        asiaSubList[0].Asia1__c = tmpAsia1.Id;
        asiaSubList[0].Subscription__c = subRecord.Id;
        asiaSubList[0].Status__c = 'Enabled';
        asiaSubList[0].Order_Line_Item__c = oli.Id;
        asiaSubList[0].Service_Access_Flag__c = SAF.Id;
        database.insert(asiaSublist)   ;
        
        //create publications
        List<Publication__c> publicationList = TestDataFactory.createPublication(2);
        publicationList[0].Product_Family__c = 'Stray';
        publicationList[0].Published_Days__c = '7';
        publicationList[0].Publication_Type__c = 'A';
        publicationList[1].Product_Family__c = 'Time';
        publicationList[1].Published_Days__c = '7';
        publicationList[1].Publication_Type__c = 'A';
        database.insert(publicationList);

        List<Product_Publication__c> prodPub = TestDataFactory.createProductPublication(2);        
        prodPub[0].Publication_Code__c = publicationList[0].id;
        prodPub[0].ZProduct__c = zProduct.id;
        prodPub[1].Publication_Code__c = publicationList[1].id;
        prodPub[1].ZProduct__c = zProduct.id;
        database.insert(prodPub);
        
        //create oliv
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        for(Order_Line_Item_Vendor__c oliv:orderLineItemList){
            oliv.Order__c = order.id;
        }
        database.insert(orderLineItemList);
        
        ApexPages.currentPage().getParameters().put('Id', order.id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('subscriptionId', subRecord.id);
        
        Order__c myId = [SELECT Id, Status__c
                   FROM Order__c 
                   WHERE Order_Type__c =: order.Order_Type__c 
                   AND Account__c =: order.Account__c 
                   AND Status__c = 'Draft'
                   AND Subscription__c =: order.Subscription__c limit 1];
        
        //asserts if expected value is equal to actual value
        system.assertEquals(order.id, myId.id);
        
        Test.startTest();   
        
        Zuora__Subscription__c mySub = [SELECT Id, Order_Number_1__c
                                       FROM Zuora__Subscription__c
                                       WHERE Id =: subRecord.id 
                                        and Order_Number_1__c =: subRecord.Order_Number_1__c];
        
        //asserts if expected value is equal to actual value
        System.assertEquals(mySub.id, subRecord.id);
        System.assertEquals(mySub.Order_Number_1__c, subRecord.Order_Number_1__c);
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
        
        controller.getCOS_PACKAGE();
        controller.getCOS_QUANTITY();
        controller.getEarliestStart(pack.id);
        controller.activateMaps(pack.id);
        controller.retrieveActiveSubscriptions();
                
        //@description: When Order Type is Check       
        controller.save();
        
        controller.asia1SelectedExistingId = String.valueOf(tmpAsia1.id);
        controller.addAsia1NewAccount();
        controller.addAsia1ExistingAccount();
        
        controller.asia1SingleAccount = tmpAsia1;
        controller.validateNewAsia1Account();
        controller.getAsia1ExistingAccounts();
        controller.removeAsia1Subscription();
        
        controller.getDeliveryChargeTypes();
        controller.getBillingAccountOptions();
        controller.fetchBillingAccount();
        controller.getSource();        
        
        controller.clearPaymentMethod();
        controller.clearOtherPaymentMethod();
        
        controller.retrieveAdminFee();
        // @description: I dont know the reason of the error. I just checked that zs.Contract End Date 
        // has data. 
        //controller.retrieveAdminCharge();
        
        controller.searchText = 'Package';
        controller.searchBillingType = 'Prepaid';
        controller.searchFrom = 'Package';
        controller.executeSearch();
        
        controller.searchText = 'Promotion';
        controller.searchBillingType = 'Full Prepaid';
        controller.searchFrom = 'Promotion';        
        controller.executeSearch();
        
        controller.selectedAddOnPackage = String.valueOf(pack.id);
        controller.populateAddOn();
        
        SM_ChangeOfSubscriptionEntryController.retrieveRelatedPackages(String.valueOf(promo.id), pack.Billing_Type__c, String.valueOf(acc.id), 'Add', 'on',String.valueOf(subRecord.id));
            
        controller.cancel();
        
    }
TODO */   
}