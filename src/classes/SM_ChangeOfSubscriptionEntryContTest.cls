/**
 * Base Class Name: SM_ChangeOfSubscriptionEntryContTest
 * @author: <Thayne Recato Dy>
 * Date: <2/23/2015>
 * Changes: by: Jensar Joey Z. Sayson - Added "String.valueOf(subRecord.id)" to satisfy the last parameter of "SM_ChangeOfSubscriptionEntryController.retrieveRelatedPackages" methodat line 375 column 9
 * Requirement/Project Name: <SPH>
 * @description: Test Class for SM_ChangeOfSubscriptionEntryController
 */ 
@isTest (Seealldata = TRUE)
private class SM_ChangeOfSubscriptionEntryContTest{
/* TODO
    //@description: This test method execute all methods in the base class //
    static testmethod void testStartOfFlow() {
    
    
         //User testUser = new User(
         //   Alias = 'stndrd',
         //   Email='standarduser@test.com', 
         //   EmailEncodingKey='UTF-8',
         //   LastName='Test',
         //   LanguageLocaleKey='en_US', 
         //   LocaleSidKey='en_US',
         //   ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
         //   TimeZoneSidKey='America/Los_Angeles',
         //   UserName='standard@test.com'
         // );
        
        User cso = TestDataFactory.prepareTestUsers();
        
        System.runAs(cso) {
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
        
        Test.startTest(); 
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
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
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Legacy_Id__c='Sample Legacy Id';
        order.Legacy_Create_Date__c= 'June 29, 2015';
        order.Legacy_Create_By__c= 'Hello Kiko';
        order.Legacy_Update_Date__c= 'June 29, 2015';
        order.Legacy_Update_By__c= 'Mang Kiko Odias';
        order.Billing_Type__c= 'Full Prepaid';
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
        subRecord.Zuora__SubscriptionStartDate__c = date.today().addDays(2);
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;        
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Promotion_1__c = promo.id;
        subRecord.Number_of_Copies__c=100;
        subRecord.Number_of_Copies1__c =  '100';
        subRecord.Qty__c = 20;
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
        oli.Start_Date__c =  date.today().addDays(2);
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        //oli.Add_On_Package_Subscription_Rate__c = 1;
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
        
        //Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        //cas.Order__c = order.Id;
        //database.insert(cas);
        
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
        //publicationList[0].Published_Days__c = '7';
        publicationList[0].Published_Days__c = 'NYNYNYY';
        publicationList[0].Publication_Type__c = 'A';
        publicationList[1].Product_Family__c = 'Time';
        //publicationList[1].Published_Days__c = '7';
        publicationList[0].Published_Days__c = 'NYNYNYY';
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
        
          
        
        Zuora__Subscription__c mySub = [SELECT Id, Order_Number_1__c
                                       FROM Zuora__Subscription__c
                                       WHERE Id =: subRecord.id 
                                        and Order_Number_1__c =: subRecord.Order_Number_1__c];
        
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
        }
    }
TODO */

    static List<Account> accountList = null;
    static List<Order__c> orderList = null;
    static List<Zuora__Subscription__c> zuoraSubscriptionList = null;
//    static List<Order_Line_Item__c> orderLineItemList = null;

    static void testData01() {
    
        Integer records = 1;
        Integer count = 0;
    
        //Address
        List<Address__c> addressList = TestDataFactory.createAddress(records);
        insert addressList;
        
        //Zone
        List<Zone__c> zoneList = TestDataFactory.createZone(records);
        count = 0;
        for (Zone__c obj : zoneList) {
            obj.Name = ''+count;
            count++;
        }
        insert zoneList;
        
        //Country
        List<Country__c> countryList = TestDataFactory.createCountry(records);
        count = 0;
        for (Country__c obj : countryList) {
            obj.Zone__c = zoneList[count].id;
            count++;
        }
        insert countryList;
        
        //City
        List<City__c> cityList = TestDataFactory.createCity(records);
        count = 0;
        for (City__c obj : cityList) {
            //Country - Country
            obj.Country__c = countryList[count].id;
            obj.Flight_Number_1__c = 'Flight Number 1 '+ count;
            count++;
        }
        insert cityList;
        
        //Singpost Address
        List<Singpost_Address__c> singpostAddressList = TestDataFactory.createSingpostAddress(records);
        insert singpostAddressList;

        //Account
        accountList = TestDataFactory.createAccount(records, 'Direct Corporate');
        count = 0;
        for (Account obj : accountList) {
            //Singpost Address - Postal Code
            obj.Singpost_Address__c = singpostAddressList[count].id;
            count++;
        }
        insert accountList;
    
    //Billing Account
//    Zuora__Account__c

        //Package
        List<Package__c> packageList = TestDataFactory.createPackage(records);
        insert packageList;

        //Billing Contact
        List<Contact> contactList = TestDataFactory.createContact(records);
        count = 0;
        for (Contact obj : contactList) {
            //Account - Account
            obj.Account = accountList[count];
            
            //City    - City Code
            obj.City_Code__c = cityList[count].id;
            
            //Contact - Reports To
            // Supervisor
            
            obj.Recipient_Indicator__c = true;
            
            count++;
        }   
        insert contactList; 

        //Paypdament Method
        List<Zuora__PaymentMethod__c> zuoraPaymentMethodList = TestDataFactory.createPaymentMethod(records);
        count = 0;
        for(Zuora__PaymentMethod__c obj : zuoraPaymentMethodList) {
            //Billing Account - Billing Account
        }

        //Billing Account
        List<Zuora__CustomerAccount__c> zuoraCustomerAccountList = TestDataFactory.createBillingAccount(records);
        count = 0;
        for (Zuora__CustomerAccount__c obj : zuoraCustomerAccountList) {
            //Contact - Billing Contact
            obj.Billing_Contact__c = contactList[count].id;
            //Account - Billing Account
            obj.Zuora__Account__c = accountList[count].id;
            //Payment Method - Default Payment Method
//            zuoraPaymentMethodList[count].id;
            
            //Billing Account - Parent
            //Payment Term - Payment Term(invalid)
            
            obj.Zuora__Credit_Balance__c = 0;
            
            obj.Billing_Type__c = 'Full Prepaid';
            
            count++;
        }
        insert zuoraCustomerAccountList;
        
        //Order
        orderList = TestDataFactory.createOrder(records);
        count = 0;
        for (Order__c obj : orderList) {
            //Account__c // Mandatory
            obj.Account__c = accountList[0].id;
            
            obj.Billing_Account__c = zuoraCustomerAccountList[0].id;
            
//            obj.Recipient_Contact__c = contactList[0].id;
            
//TODO            obj.Subscription__c = 
            obj.isChangeOfSubEntry__c = false;
            
            obj.Order_Type__c = 'Change of Subscription';
            obj.Billing_Type__c = 'Full Prepaid';
            
            obj.Status__c = 'Draft';
            
            count++;
        }
        insert orderList;
        
        //Order Line Item
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(records);
        count = 0;
        for (Order_Line_Item__c obj : orderLineItemList) {
            //Order__c, // Mandatory
            obj.Order__c = orderList[count].id;
            //Main_Package_ID__c // Mandatory
            obj.Main_Package_ID__c = packageList[count].id;
            
            obj.Start_Date__c = Date.today().addDays(10);
            
            obj.Qty__c = 10;
            obj.Add_On_Package_Subscription_Rate__c = 10;
            
            count++;
        }
        insert orderLineItemList;

        //Subscription
        zuoraSubscriptionList = TestDataFactory.createSubscription(records);
        count = 0;
        for (Zuora__Subscription__c obj : zuoraSubscriptionList) {
            //Account         - Account
            obj.Zuora__Account__c = accountList[0].id;
            //Package         - Addon Package
            obj.Addon_Package_1__c = packageList[0].id;
            //Billing Account - Billing Account
            obj.Zuora__CustomerAccount__c = zuoraCustomerAccountList[0].id;
            //Contact         - Billing Contact
            //Subscription    - Grace Period Subscription
            //Billing Account - Invoice Owner
            //Package         - Main Package
            obj.Main_Package_1__c = packageList[0].id;
            //Order Line Item - Order Line Item Number
        //obj.Order_Line_Item_Number__c = orderLineItemList[0].id; // This should be ID of Order Line Item
            //Order           - Order Number
            //Promotion       - Promotion
            //Contact         - Recipient Contact
            //Contact         - Subscriber Contact
            //Account         - Vendor
            //Vendor          - Vendor Subscription To Convert
            //Text            - Number of Copies 
            
            obj.Number_of_Copies1__c = '1';
            obj.Zuora__Status__c = Globalvariableclass.SUBSCRIPTION_STATUS_ACTIVE;
            obj.Zuora__SubscriptionStartDate__c = Date.today();
            obj.Zuora__SubscriptionEndDate__c = null;
            obj.Subscription_Type__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
            obj.Subscription_Type_1__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
            obj.Zuora__TermSettingType__c = 'EVERGREEN';
            obj.Term_Length__c = 1;
            
            
            count++;
        }
        insert zuoraSubscriptionList;
        
        //count = 0;
        for (Order__c obj : orderList) {
            //Account__c // Mandatory
            //obj.Account__c = accountList[count].id;
            
            obj.Subscription__c = zuoraSubscriptionList[0].id;
            //obj.isChangeOfSubEntry__c = false;
            
            //count++;
        }
        update orderList;
    }
    
    static testMethod void testMethod01() {
    
        testData01();
    
        Test.startTest();
        
        // Initialization of VisualForce Page
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
//        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());
        
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();

/*
        controller.selectedSubscription = new SM_ChangeOfSubscriptionEntryController.SubscriptionWrapper();
//        controller.orderLineItem        = orderLineItemList[0];
        controller.thisOrder            = orderList[0];
        controller.zs                   = zuoraSubscriptionList[0];
        controller.subscriptionRate = 10;
*/
        Try {
            controller.retrieveActiveSubscriptions();
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }

        
        System.debug('>>>>>>>>>>');
        System.debug([select Id, Name, Promotion_ID__r.Name, Order__c, Asia1_Creation_Mode__c, Auto_Renew__c, Charity__c, Contract_End_Date__c, 
                    Delivered_By__c, Earliest_Start_Date__c, End_Date__c, Generate_Invoice__c, Is_Digital__c, 
                    Main_Package_ID__c, New_Contract_Period__c, Main_Package_ID__r.Name, Main_Package_Sub_Type__c, 
                    Penalty_Charge__c, PO_Number__c, Qty__c, Start_Date__c, Total_Subscription_Rate__c, Admin_Charge__c, 
                    Add_On_Package_Subscription_Rate__c, Term_is_discussed__c, Main_Package_Billing_Type__c, 
                    Main_Package_Type__c, Main_Package_Subscription_Rate__c, Main_Package_Frequency__c, Main_Package_Period__c,
                    Supressed_Acknowledgement_Letter__c, Suppress_Renewal_and_Reminder_Letter__c, Main_Package_Product_Sub_Type__c, 
                    Supressed_Vendor_Notification_New_Sub__c, Term_Length__c, Vendor_Conversion__c, Effective_Date__c, 
                    Vendor_Subscription_ID__c, Addon_Package__c, Addon_Package__r.Name, Promotion_ID__c, Subscribed_as__c, Suppress_Vendor_Start_notice__c, 
                    Direct_Sub_Delivery_Method__c, (select Promotion_Gift__c, Gift_Name__c, Type__c, Price__c from Order_Line_Item_Gifts__r), 
                    (select Asia1__c, Asia1__r.User_ID_LDAP_ID__c, Service_Access_Flag__c, 
                    Service_Access_Flag__r.Name, Status__c, Concurrent__c from Asia1_Subscriptions__r), Vendor_Mailing_Agent__c 
                    from Order_Line_Item__c where Order__r.Subscription__c = :orderList[0].Subscription__c and 
                    Order__r.Status__c = 'Draft' and Order__c = :orderList[0].id limit 1]);
        
        System.debug('<<<<<<<<<<');
        System.debug('>>>>>>>>>>');
        System.debug([select Id, Zuora__CustomerAccount__r.Zuora__Credit_Balance__c, Contract_End_Date_1__c, Promotion_1__c, 
                        Promotion_1__r.Penalty_Charge__c, Promotion_1__r.Penalty_Charge_Override__c, Order_Line_Item_Number_1__r.Admin_Charge__c, Order_Line_Item_Number_1__c, Recipient_Contact__c, Cost_Center__c, Number_of_Copies__c, Order_Line_Item_Number_1__r.Main_Package_Subscription_Rate__c, Zuora__CustomerAccount__c,
                        Main_Package_1__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, 
                        Order_Line_Item_Number_1__r.Total_Subscription_Rate__c,
                        Order_Number_1__c, Delivery_Charge_Type_1__c, Zuora__CustomerAccount__r.Name, 
                        Zuora__CustomerAccount__r.Payment_Mode__c, Vendor_Conversion_1__c, Charity_1__c, Delivered_By_1__c, Term_Length__c,
                        PO_Number__c, Supressed_Renewal_and_Reminder_Letter_1__c, New_Contract_Period_1__c, Supressed_Acknowledgement_Letter_1__c,
                        Suppress_Vendor_Start_Notice_1__c, Penalty_Charge_1__c, Generate_Invoice__c, Qty__c, Zuora__AutoRenew__c, Subscribe_As__c,
                        Vendor__c, Vendor_1__c, Billing_Type__c, Main_Package_1__r.Name, Zuora__Status__c
                        from Zuora__Subscription__c where Id = :orderList[0].Subscription__c]);
        System.debug('<<<<<<<<<<');
        

// Many TODO

        //controller.retrieveAdminCharge();
//        controller.retrieveRelatedSubscriptions();
/*
        try{
            controller.retrieveOrderLineItem();
        }catch(Exception e){System.debug(e);}
            
        try{
            controller.retrieveRelatedSubscriptions();
        }catch(Exception e){System.debug(e);}
                      
//        try{
//            controller.retrieveActiveSubscriptions();
//        }catch(Exception e){System.debug(e);}
        
        try{
            controller.save();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.cancel();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.refreshSubscriberCharge();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.addOrderLineItem();
        }catch(Exception e){System.debug(e);}
      
        try{
            controller.checkExistingCOA();
        }catch(Exception e){System.debug(e);}
      
        try{
            controller.retrieveOrderLineItem();
        }catch(Exception e){System.debug(e);}
      
        try{
            controller.executeSearch();
        }catch(Exception e){System.debug(e);}
    
        try{
            controller.searchPackage();
        }catch(Exception e){System.debug(e);}
      
        try{
            controller.searchPromotion();
        }catch(Exception e){System.debug(e);}

        try{
            controller.populateAddOn();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.populatePromotionGifts();
        }catch(Exception e){System.debug(e);}
     
        try{
            controller.addAsia1ExistingAccount();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.addAsia1NewAccount();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.validateNewAsia1Account();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.removeAsia1Subscription();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.getAsia1ExistingAccounts();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.getDeliveryChargeTypes();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.getBillingAccountOptions();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.fetchBillingAccount();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.getSource();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.clearPaymentMethod();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.clearOtherPaymentMethod();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.checkInvoiceForBillingAccount();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.searchCusName();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.searchAccName();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.addPopAcc();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.closePopup();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.cancelSearch();
        }catch(Exception e){System.debug(e);}
        
        try{
            controller.retrieveAdminFeeAdminCharge();
        }catch(Exception e){System.debug(e);}
       
        try{
            controller.continueSave();
        }catch(Exception e){System.debug(e);}
*/       
        Test.stopTest();
    
                
    }
    
/* TODO
   
    //@description: This test method check when the Billing Account Creation Mode is 
    //Use existing Billing Account//
    static testmethod void testBillingCreationModeUsed() {
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
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
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
        order.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        order.Payment_Mode__c = 'Cash';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Delivery_Charge__c= 1000;
        order.Order_Legacy_Id__c='Sample Legacy Id';
        order.Legacy_Create_Date__c= 'June 29, 2015';
        order.Legacy_Create_By__c= 'Hello Kiko';
        order.Legacy_Update_Date__c= 'June 29, 2015';
        order.Legacy_Update_By__c= 'Mang Kiko Odias';
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c= 'Full Prepaid';
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;
        //subRecord.Order__c = order.id;
        //subRecord.Order_Number__c = order.Id;
        //subRecord.Order_Number_1__c = order.id;
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
        subRecord.Zuora__SubscriptionStartDate__c = date.today().addDays(2);
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;        
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Promotion_1__c = promo.id;
        subRecord.Number_of_Copies__c=100;
        subRecord.Number_of_Copies1__c =  '100';
        subRecord.Qty__c = 20;
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
        oli.Start_Date__c =  date.today().addDays(2);
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        //oli.Add_On_Package_Subscription_Rate__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        oli.Promotion_ID__c = promo.id;
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
        
        //Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        //cas.Order__c = order.Id;
        //database.insert(cas);
        
        subRecord.Order_Line_Item_Number__c = oli.id;        
        database.update(subRecord);  
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', order.id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('subscriptionId', subRecord.id);
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
        
        Order__c myOrder = [SELECT Billing_Account_Creation_Mode__c
                            FROM Order__c
                            WHERE Id =: order.id];
        
        System.assertEquals('Use existing Billing Account', myOrder.Billing_Account_Creation_Mode__c);
        
        controller.retrieveActiveSubscriptions();
        controller.save();
        //controller.retrieveRelatedSubscriptions();
    }
   
    //@description: This test method check when the Order payment mode is Cash //
    static testmethod void testPaymentModeCash() {
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
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
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
        order.Payment_Mode__c = 'Cash';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Delivery_Charge__c= 1000;
        order.Order_Legacy_Id__c='Sample Legacy Id';
        order.Legacy_Create_Date__c= 'June 29, 2015';
        order.Legacy_Create_By__c= 'Hello Kiko';
        order.Legacy_Update_Date__c= 'June 29, 2015';
        order.Legacy_Update_By__c= 'Mang Kiko Odias';
        order.Order_Type__c = 'Change of Subscription';        
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;
        //subRecord.Order__c = order.id;
        //subRecord.Order_Number__c = order.Id;
        //subRecord.Order_Number_1__c = order.id;
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
        subRecord.Zuora__SubscriptionStartDate__c = date.today().addDays(2);
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;        
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Promotion_1__c = promo.id;
        subRecord.Number_of_Copies__c=100;
        subRecord.Number_of_Copies1__c =  '100';
        subRecord.Qty__c = 20;
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
        oli.Start_Date__c =  date.today().addDays(2);
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        //oli.Add_On_Package_Subscription_Rate__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        oli.Promotion_ID__c = promo.id;
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
        
        //Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        //cas.Order__c = order.Id;
        //database.insert(cas);
        
        subRecord.Order_Line_Item_Number__c = oli.id;        
        database.update(subRecord);  
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', order.id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('subscriptionId', subRecord.id);
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
        
        Order__c myOrder = [SELECT Payment_Mode__c
                            FROM Order__c
                            WHERE Id =: order.id];
        
        System.assertEquals('Cash', myOrder.Payment_Mode__c);
        
        controller.retrieveActiveSubscriptions();
        controller.save();
    }
    
    //@description: This test method check when the Order payment mode is Credit Card //
    static testmethod void testPaymentModeCreditCard() {
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
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
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
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Legacy_Id__c='Sample Legacy Id';
        order.Legacy_Create_Date__c= 'June 29, 2015';
        order.Legacy_Create_By__c= 'Hello Kiko';
        order.Legacy_Update_Date__c= 'June 29, 2015';
        order.Legacy_Update_By__c= 'Mang Kiko Odias';
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;
        //subRecord.Order__c = order.id;
        //subRecord.Order_Number__c = order.Id;
        //subRecord.Order_Number_1__c = order.id;
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
        subRecord.Zuora__SubscriptionStartDate__c = date.today().addDays(2);
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;        
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Promotion_1__c = promo.id;
        subRecord.Number_of_Copies__c=100;
        subRecord.Number_of_Copies1__c =  '100';
        subRecord.Qty__c = 20;
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
        oli.Start_Date__c =  date.today().addDays(2);
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        //oli.Add_On_Package_Subscription_Rate__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        oli.Promotion_ID__c = promo.id;
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
        
        //Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        //cas.Order__c = order.Id;
        //database.insert(cas);
        
        subRecord.Order_Line_Item_Number__c = oli.id;        
        database.update(subRecord);  
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', order.id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('subscriptionId', subRecord.id);
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
        
        Order__c myOrder = [SELECT Payment_Mode__c
                            FROM Order__c
                            WHERE Id =: order.id];
        
        System.assertEquals('Credit Card', myOrder.Payment_Mode__c);
        
        controller.retrieveActiveSubscriptions();
        controller.save();
    }
    
    //@description: This test method check when the Order payment mode is Other //
    static testmethod void testPaymentModeOther() {
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
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
        billAcc.Other_PaymentMethod__c = 'Invoice';
        //billAcc.Other_Payment_Mode__c = '';
       // billAcc.Payment_Mode__c 
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
        //order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        //order.Payment_Mode__c = 'Other';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Delivery_Charge__c= 1000;
        order.Order_Legacy_Id__c='Sample Legacy Id';
        order.Legacy_Create_Date__c= 'June 29, 2015';
        order.Legacy_Create_By__c= 'Hello Kiko';
        order.Legacy_Update_Date__c= 'June 29, 2015';
        order.Legacy_Update_By__c= 'Mang Kiko Odias';
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
        //order.Other_PaymentMethod__c = 'Invoice';
        order.Other_Payment_Mode__c = 'Invoice';
        //order.Other_Payment_Mode__c = '';
        order.Payment_Mode__c = 'Other';
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;
        //subRecord.Order__c = order.id;
        //subRecord.Order_Number__c = order.Id;
        //subRecord.Order_Number_1__c = order.id;
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
        subRecord.Zuora__SubscriptionStartDate__c = date.today().addDays(2);
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;        
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Promotion_1__c = promo.id;
        subRecord.Number_of_Copies__c=100;
        subRecord.Number_of_Copies1__c =  '100';
        subRecord.Qty__c = 20;
        //subRecord.Zuora__CustomerAccount__c = 
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
        oli.Start_Date__c =  date.today().addDays(2);
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        //oli.Add_On_Package_Subscription_Rate__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        oli.Promotion_ID__c = promo.id;
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
        
        //Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        //cas.Order__c = order.Id;
        //database.insert(cas);
        
        subRecord.Order_Line_Item_Number__c = oli.id;        
        database.update(subRecord);  
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', order.id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('subscriptionId', subRecord.id);
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
        
        Order__c myOrder = [SELECT Payment_Mode__c, Delivery_Charge_Type__c
                            FROM Order__c
                            WHERE Id =: order.id];
        
        System.assertEquals('Other', myOrder.Payment_Mode__c);
        
        controller.retrieveActiveSubscriptions();
        controller.save();
    }
    
    //@description: This test method check when the Order status is Close //
    static testmethod void testWhenOrderStatusIsClose() {
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
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        //billAcc.Zuora__Credit_Balance__c = 50000.00;
        billAcc.Billing_Type__c= 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 0;
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
        order.Status__c = GlobalVariableClass.STATUS_NEW;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Legacy_Id__c='Sample Legacy Id';
        order.Legacy_Create_Date__c= 'June 29, 2015';
        order.Legacy_Create_By__c= 'Hello Kiko';
        order.Legacy_Update_Date__c= 'June 29, 2015';
        order.Legacy_Update_By__c= 'Mang Kiko Odias';
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;
        //subRecord.Order_Number__c = order.id;//
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
        subRecord.Zuora__SubscriptionStartDate__c = date.today().addDays(2);
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;        
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Promotion_1__c = promo.id;
        subRecord.Number_of_Copies__c=100;
        subRecord.Number_of_Copies1__c =  '100';
        subRecord.Qty__c = 20;
        database.insert(subRecord);
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', order.id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('subscriptionId', subRecord.id);
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
        
        Order__c myOrder = [SELECT Status__c
                            FROM Order__c
                            WHERE Id =: order.id];
        
        System.assertEquals('New', myOrder.Status__c);
        
        controller.retrieveActiveSubscriptions();
        controller.save();
        controller.cancel();
        Test.stopTest();
    }
    
    //@description: This test method check when the Order Line Item is not digital //
    static testmethod void testOLIIsNotDigital() {
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
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Zuora__Credit_Balance__c = NULL;
        billAcc.Billing_Type__c= 'Full Prepaid';
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
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Delivery_Charge__c= 1000;
        order.Order_Legacy_Id__c='Sample Legacy Id';
        order.Legacy_Create_Date__c= 'June 29, 2015';
        order.Legacy_Create_By__c= 'Hello Kiko';
        order.Legacy_Update_Date__c= 'June 29, 2015';
        order.Legacy_Update_By__c= 'Mang Kiko Odias';
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
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
        subRecord.Zuora__SubscriptionStartDate__c = date.today().addDays(2);
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;        
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
        subRecord.Promotion_1__c = promo.id;
        subRecord.Number_of_Copies__c=100;
        subRecord.Number_of_Copies1__c =  '100';
        subRecord.Qty__c = 20;
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
        
        order.Subscription__c = subRecord.id;
        order.Base_Subscription__c= subRecord.id;
        database.update(order);
        
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
        for (Package_Item__c pItem : pItems) {
            pItem.Package__c = pack.Id;
            pItem.Duration_in_months__c = '3';
            pItem.Effective_Start_Month__c = '3';
            pItem.Product_Rate_Plan__c = productRatePlan[0].id;
            pItem.Product_Family__c = prodFamily.id;
        }
        database.insert(pItems);
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c =  date.today().addDays(2);
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        //oli.Add_On_Package_Subscription_Rate__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        oli.Promotion_ID__c = promo.id;
        oli.Addon_Package__c = pack.id;
        oli.Term_is_discussed__c = FALSE;
        oli.Main_Package_Subscription_Rate__c = NULL;
        oli.Add_On_Package_Subscription_Rate__c = NULL;
        oli.Admin_Charge__c = NULL;
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
        
        //Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        //cas.Order__c = order.Id;
        //database.insert(cas);
        
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
        SAF.Flag_Code__c = 'TEST';
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
        //publicationList[0].Published_Days__c = '7';
        publicationList[0].Published_Days__c = 'NYNYNYY';
        publicationList[0].Publication_Type__c = 'A';
        publicationList[0].Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
        publicationList[1].Product_Family__c = 'Time';
        //publicationList[1].Published_Days__c = '7';
        publicationList[0].Published_Days__c = 'NYNYNYY';
        publicationList[1].Publication_Type__c = 'A';
        publicationList[1].Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
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
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', order.id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('subscriptionId', subRecord.id);        
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
        
        Order_Line_Item__c myOli = [SELECT Is_Digital__c 
                                   FROM Order_Line_Item__c
                                   WHERE Id =: oli.id];
        
        System.assertEquals(FALSE, myOli.Is_Digital__c);
        
        controller.retrieveActiveSubscriptions();
        
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
        
        controller.selectedAddOnPackage = String.valueOf(pack.id);
        controller.populateAddOn();
        
        controller.cancel();
        
        controller.hidSubCharge = 1.5;
        controller.hidCreditCharge = 2.0;
        controller.isDelivery= true;
        controller.selectedOrderLineItem = 'sdfdfg';
        controller.selectedPromotionId = 'sdfd';
        //controller.selectedchangeOfSubscriptionOption = 'sdafds';
        controller.selectedPackageId='fgdfg';
        controller.selectedchangeOfSubscriptionOptions = 'dsfsdf';
        controller.dueToSph = 1.5;
        controller.totalSubRate = 2.3;
        controller.dueToCustomer = 1.6;
        controller.searchBillingType = 'sdfsd';
        controller.selectedPackageName='dfsdf';
        controller.isAllInOne =true;
        controller.isReInitializedItem = false;
        controller.selectedAddOnPackage= 'sdfd';
        controller.isExecuteSearch= true;
        controller.isPackageSelected= false;
        controller.isPromotionSelected= true;
        controller.isDigital= true;
        controller.isFromPromotion = false;
        
         
        
        Test.stopTest();
    }
TODO */
}