/**
 * Base Class Name: SM_ChangeOfSubscriptionEntryController
 * @author: FrancisBenzon       
 * Date: 4Apr16
 * Requirement/Project Name: <SPH>
 * @description: Test Class for SM_ChangeOfSubscriptionEntryController
 */ 
@isTest 
private class SM_ChangeOfSubscriptionEntryContTest1{

    static List<Account> accountList = null;
    static List<Order__c> orderList = null;
    static List<Zuora__Subscription__c> zuoraSubscriptionList = null;
    static List<Zuora__Subscription__c> zuoraSubscriptionList2 = null;
    static List<Case> parentCase = null;    
    static List<Package__c> packageList = null;
    static List<Address__c> addressList = null;
    static List<zqu__Quote__c> quoteLst = null;
    static List<Zuora__CustomerAccount__c> zuoraCustomerAccountList = null;
    static List<Publication__c> publicationList = null;
    static List<Product_Publication__c> prodPubList = null;
    static List<Order_Line_Item__c> orderLineItemList = null;
    static List<Contact> contactList = null;
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
    }  
    
    
    static void testData01() {
    
        List<Other__c> otherList = CustomSettingsDataFactory.createOther(1);
        insert otherList;

        Cir_Planner_Schedule__c plannerSched = CustomSettingsDataFactory.createPlannerSched();
        insert plannerSched;

        Integer records = 1;
        Integer count = 0;
        
               
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
        
        //Address
        addressList = TestDataFactory.createAddress(records);
        addressList[0].Address_Type__c= 'H';
        addressList[0].Postal_Code__c = singpostAddressList[0].Id;
        addressList[0].Country__c = countryList[0].Id;
        insert addressList;

        //Account
        accountList = TestDataFactory.createAccount(2, 'Direct Individual');
        count = 0;
        for (Account obj : accountList) {
            //Singpost Address - Postal Code
            obj.Singpost_Address__c = singpostAddressList[0].id;
            count++;
        }
        insert accountList;
    
    
        //Package
        packageList = TestDataFactory.createPackage(records);
        packageList[0].Package_Code__c = 'packsample';
        packageList[0].Subscription_Type__c = 'Termed';
        packageList[0].Package_Sub_Type__c = 'Single';
        packageList[0].Subscription_Period__c = '12';
        packageList[0].Billing_Type__c = 'Full Prepaid';
        insert packageList;
        
        //Start Prod Cat Setup
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0]; //try to loop with many product sub type
        zProduct.ProductPlatform__c = 'Print';
        zProduct.ProductSubType__c = 'Newspaper';
        zProduct.ProductCode__c = 'STSU';
        insert zProduct;
        
        Zuora__Product__c prod = TestDataFactory.createProduct(1)[0];
        insert prod;
        
        publicationList = TestDataFactory.createPublication(1);
        count = 0;
        for (Publication__c publication : publicationList ) {
        publication.Product_Family__c = 'PrFam';
        publication.Published_Days__c = 'YYYYYYY';
        publication.Publication_Type__c = 'N';
        publication.Publication_Code__c = '1234';
        publication.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
        //publication.Earliest_Start_Date__c = date.today();
        count++;
        }
        insert publicationList;
        
        prodPubList = TestDataFactory.createProductPublication(1);
        count = 0;
        for(Product_Publication__c prodPub : prodPubList ){
            prodPub.Product_Code__c = prod.Id;
            prodPub.Publication_Code__c = publicationList[0].Id;
            prodPub.ZProduct__c = zProduct.Id;
            count++;
        }
        insert prodPubList;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.SubscriptionFrequency__c = '2';
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        insert prdRatePlan;
        
       
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        insert prpc;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'TestNAme';
        insert prodfam;
       
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = packageList[0].Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        //End Prod Cat Setup
                
        //Billing Contact
        contactList = TestDataFactory.createContact(records);
        count = 0;
        for (Contact obj : contactList) {
            //Account - Account
            obj.AccountId = accountList[count].Id;
            
            //City    - City Code
            obj.City_Code__c = cityList[count].id;
            
            //Contact - Reports To
            // Supervisor
            
            obj.Recipient_Indicator__c = true;
            obj.Billing_Indicator__c = true;
            obj.Address__c = addressList[0].Id;
            
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
        zuoraCustomerAccountList = TestDataFactory.createBillingAccount(records);
        count = 0;
        for (Zuora__CustomerAccount__c obj : zuoraCustomerAccountList) {
            obj.Billing_Contact__c = contactList[count].id;          
            obj.Zuora__Account__c = accountList[count].id;         
            obj.Zuora__Credit_Balance__c = 0;          
            obj.Billing_Type__c = 'Full Prepaid';
            obj.Zuora__DefaultPaymentMethod__c = 'Other';
            
            count++;
        }
        insert zuoraCustomerAccountList;
        
        //Order
        orderList = TestDataFactory.createOrder(2);
        count = 0;
        for (Order__c obj : orderList) {
            obj.Account__c = accountList[0].id;           
            obj.Billing_Account__c = zuoraCustomerAccountList[0].id;           
            obj.isChangeOfSubEntry__c = false;           
            obj.Order_Type__c = 'Change of Subscription';
            obj.Billing_Type__c = 'Full Prepaid';          
            obj.Status__c = 'Draft';
            obj.Recipient_Contact__c = contactList[0].id;
            obj.Payment_Mode__c = 'Credit Card';
            obj.Payment_Method_ID__c = 'zID';
            obj.Subscriber_Charge__c = 100;
            //obj.Create_ARMS_Customer_Account__c = true;
            //obj.Customer_Name__c = 'arms customer';
            //obj.Delivery_Charge_Type__c
            
            count++;
        }
        try{
        insert orderList;
        }catch(exception e){}
        //system.assertEquals('RecCon ' , ' ' + orderList[0].Recipient_Contact__c);
        //Order Line Item
        orderLineItemList = TestDataFactory.createOrderLineItem(records);
        count = 0;
        for (Order_Line_Item__c obj : orderLineItemList) {
            obj.Order__c = orderList[count].id;
            obj.Main_Package_ID__c = packageList[count].id;
            obj.Start_Date__c = Date.today().addDays(10);
            obj.Qty__c = 10;
            obj.Add_On_Package_Subscription_Rate__c = 10;
            obj.Subscribed_as__c = 'New Buy';
            obj.Term_Length__c = 12;            
            
            count++;
        }
        insert orderLineItemList;
        
        quoteLst = TestDataFactory.createQuote(1);
        quoteLst[0].Order_Line_Item_Number_1__c = orderLineItemList[0].Id;
        
        insert quoteLst;

        //Subscription
        zuoraSubscriptionList = TestDataFactory.createSubscription(2);
        count = 0;
        for (Zuora__Subscription__c obj : zuoraSubscriptionList) {
            obj.Zuora__Account__c = accountList[0].id;
            obj.Addon_Package_1__c = packageList[0].id;
            obj.Zuora__CustomerAccount__c = zuoraCustomerAccountList[0].id;
            obj.Main_Package_1__c = packageList[0].id;        
            obj.Number_of_Copies1__c = '1';
            obj.Zuora__Status__c = Globalvariableclass.SUBSCRIPTION_STATUS_ACTIVE;
            obj.Zuora__SubscriptionStartDate__c = Date.today();
            obj.Zuora__SubscriptionEndDate__c = null;
            obj.Subscription_Type__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
            obj.Subscription_Type_1__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
            obj.Zuora__TermSettingType__c = 'EVERGREEN';
            obj.Term_Length__c = 1;
            obj.Recipient_Contact__c = contactList[0].id;
            obj.Delivery_Charge_Type_1__c = 'H';
            obj.Order_Number_1__c = orderList[1].Id;
            obj.Number_of_Copies__c = 1;             
            count++;
        }
        zuoraSubscriptionList[1].Subscription_Type__c = 'Delivery';
        zuoraSubscriptionList[1].Subscription_Type_1__c = 'Delivery';
        zuoraSubscriptionList[1].Main_Package_1__c = packageList[0].Id;
        subscriptiontriggerhandler.preventexecution = true;
        insert zuoraSubscriptionList;
        
        //System.debug('test class >.> ::' + zuoraSubscriptionList[1].Main_Package_1__c + ':::' + zuoraSubscriptionList[0].Main_Package_1__c);
        
        
        parentCase = TestDataFactory.createCase(1, 'Start Subscription');
        parentCase[0].Origin = 'Phone';
        parentCase[0].Status = 'Closed';
        parentCase[0].Sub_Status__c = 'Subscription Created';
        parentCase[0].Category__c = 'Subscription Request';
        parentCase[0].Sub_Category__c = 'Start Subscription';
        insert parentCase[0];
        
        List<Zuora__SubscriptionProductCharge__c> spcLst = TestDataFactory.createSubProductCharge(1);
        spcLst[0].Zuora__Price__c = 10;
        spcLst[0].Zuora__Subscription__c = zuoraSubscriptionList[0].id;
        spcLst[0].Name = GlobalVariableClass.ADMIN_CHARGE;
        insert spcLst;
               
        for (Order__c obj : orderList) {
            obj.Subscription__c = zuoraSubscriptionList[0].id;
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
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
        
        
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();

        
        controller.selectedSubscription = new SM_ChangeOfSubscriptionEntryController.SubscriptionWrapper();
        controller.orderLineItem        = orderLineItemList[0];
        controller.thisOrder            = orderList[0];
        controller.zs                   = zuoraSubscriptionList[0];
        controller.zs                   = zuoraSubscriptionList[0];
        controller.subscriptionRate = 10;
        
        
        Try {
            controller.retrieveActiveSubscriptions();
            controller.getEarliestStart(packageList[0].Id);
            controller.continueSave();
            controller.checkExistingCOA();
            controller.fetchBillingAccount();
            controller.billingAccountOption = 'createNew';      
            controller.save();
            controller.testCoveragePatch();
			controller.testCoveragePatch2();
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
        
        Test.stopTest();               
    }
    
    /*
    static testMethod void testMethod02() {

        testData01();
        publicationList[0].Direct_Sub_Delivery_Method__c = 'Mailing Agent';
        update publicationList;
        
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.getEarliestStart(packageList[0].Id);
            controller.continueSave();
            controller.getBillingAccountOptions();
            controller.billingAccountOption = 'useExisting';        
            //controller.save();
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    /*
    static testMethod void testMethod03() {

        testData01();
        orderlist[0].Payment_Mode__c = 'Check';
        orderlist[0].Delivery_Charge_Type__c = 'S';     
        update orderlist;
        
        addressList[0].Address_Type__c= 'S';
        update addressList;
        
        publicationList[0].Direct_Sub_Delivery_Method__c = 'Vendor';
        update publicationList;
        
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.getEarliestStart(packageList[0].Id);
            controller.continueSave();
            controller.billingAccountOption = 'createNew'; 
            controller.save();
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    static testMethod void testMethod04() {

        testData01();
        orderlist[0].Payment_Mode__c = 'Cash';
        orderlist[0].Amount_Paid__c = 100000;
        update orderlist;
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.getEarliestStart(packageList[0].Id);
            controller.continueSave();
            controller.billingAccountOption = 'createNew';      
            //controller.save();
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    static testMethod void testMethod05() {

        testData01();
        orderlist[0].Payment_Mode__c = 'Other';
        update orderlist;
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.getEarliestStart(packageList[0].Id);
            controller.continueSave();
            controller.billingAccountOption = 'createNew';      
            //controller.save();
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    static testMethod void testMethod06() {

        testData01();
        orderlist[0].Payment_Mode__c = 'Other';
        orderlist[0].Other_Payment_Mode__c = 'eNets';
        update orderlist;
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.getEarliestStart(packageList[0].Id);
            controller.continueSave();
            controller.getDeliveryChargeTypes(); //fritz
            controller.billingAccountOption = 'createNew';      
            controller.save();
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    //cancel method
    static testMethod void testMethod07() {

        testData01();
        orderlist[0].Payment_Mode__c = 'Credit Card'; //fritz1
        orderlist[0].Request_for_Waiving_of_Admin_Charge__c = true;
        update orderlist;
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.getBillAccName();
            orderlist[0].Status__c = 'New';
            update orderlist;
            controller.cancel();
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    //search functionality 1
    static testMethod void testMethod08() {
        testData01();
        
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        //ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.searchText = 'TEST';
            controller.searchBillingType = 'TEST';
            controller.searchFrom = 'Package';
            controller.termLength = '0'; 
            controller.selectedPromotionId = 'TEst';
            controller.selectedPackageName = 'TEst';
            controller.executeSearch(); //fritz
                        
            controller.promotionResultList = null;
            controller.packageResultList = null;
            controller.selectedAddOnPackage = 'TEST';
            controller.productIsMagazine = FALSE;
            controller.searchText = 'TEST';
            controller.subscriptionRate = 100.00;
            controller.isPromotionSelected = True;
            controller.searchBillingType = 'TEST';
            controller.isRemoveEligibilityRuleSearchFilter = FALSE;
            controller.searchFrom = 'Promotion';
            controller.executeSearch();
            
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    //search functionality 2
    static testMethod void testMethod09() {
        testData01();
        
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        //ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.searchText = '2015';
            controller.searchBillingType = 'Full Prepaid';
            controller.searchFrom = 'Package';
            controller.executeSearch(); //fritz
            
            controller.searchText = '2015';
            controller.searchBillingType = 'Full Prepaid';
            controller.searchFrom = 'Promotions';
            controller.executeSearch();                             
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    //addOn
    static testMethod void testMethod10() {
        testData01();
        Package__c pack1 =  TestDataFactory.createPackage(1)[0];
        pack1.Package_Code__c = 'SAMPLE1';
        pack1.Subscription_Type__c = 'Termed';
        pack1.Package_Sub_Type__c = 'Single';
        pack1.Subscription_Period__c = '2';
        pack1.Billing_Type__c = 'Full Prepaid';
        pack1.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON; 
        
        List<Package__c> packList = new List<Package__c>();
        packList.add(pack1);
        insert packList;
        
        Promotion__c promoTmp_global = TestDataFactory.createPromotion(1)[0]; 
        promoTmp_global.Name = 'Promotions';
        promoTmp_global.Contract_Period__c ='12';
        promoTmp_global.Penalty_Charge__c = '100'; 
        promoTmp_global.Maximum_No_of_gifts_allowed__c = '5';
        
        insert promoTmp_global;
        
        List<Gift__c> giftLst = TestDataFactory.createGift(1);
        insert giftLst;
        
        Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
        promoGift.Promotion__c = promoTmp_global.id;
        promoGift.Gift__c = giftLst[0].Id;
        insert promoGift;
        
        List<Order_Line_Item_Gift__c> orderLineItemGifts = TestDataFactory.createItemGift(5);
        for(Order_Line_Item_Gift__c olig : orderLineItemGifts) {
            olig.Order_Line_Item__c = orderLineItemList[0].id;
            olig.Promotion_Gift__c = promoGift.id;
        }
        
        orderLineItemList[0].Promotion_Id__c = promoTmp_global.Id;
        update orderLineItemList;
        
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.selectedAddOnPackage = packList[0].id;
            controller.populateAddOn();
            controller.selectedPromotionId = promoTmp_global.Id;    
            controller.populatePromotionGifts();
            //controller.retrieveRelatedPackages(String.ValueOf(promoTmp_global.id), packList[0].Billing_Type__c, String.ValueOf(accountList[0].id), '1', 'true');
                
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
            
        Test.stopTest();

    }
    
    //Asia1
    static testMethod void testMethod11() {
        testData01();

        Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
        asia.Contact__c = contactList[0].Id;
        asia.Display_Name__c = '2asiatest';
        asia.User_ID_LDAP_ID__c = 'setasia1test';
        asia.Password__c = 'sph123409';
        asia.ASIAONE_Legacy_Id__c = '146';
        asia.Email__c = 'acn@sphcom.sg';
        insert asia;
        
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        //ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.asia1SelectedExistingId = asia.id;
            controller.asia1SingleAccount = asia; //fritz
            controller.addAsia1ExistingAccount();    
            controller.addAsia1NewAccount();
            controller.getAsia1ExistingAccounts();
            controller.asia1IdToBeRemoved = asia.id;
            controller.removeAsia1Subscription();                           
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    //ARMS Wrapper
    static testMethod void testMethod12() {
        testData01();
        
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID    
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            SM_ChangeOfSubscriptionEntryController.armsWrapper aw = new SM_ChangeOfSubscriptionEntryController.armsWrapper();
            
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
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    //ARMS Wrapper
    static testMethod void testMethod13() {
        testData01();
        
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID    
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.aCust = 'Test';
            controller.billAccName = 'Test';
            controller.billAcc = true;
            controller.accNum = 'Test';
            controller.displayAccList = true;
            controller.addAccount = true;
            controller.CBdisable = true;
            controller.searchCusName();
            //controller.searchAccName();
            controller.addPopAcc();

        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    //ARMS Wrapper
    static testMethod void testMethod14() {
        testData01();
        
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID    
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.aCust = 'Test';
            controller.billAccName = 'Test';
            controller.accNum = 'Test';         
            controller.searchAccName();         

        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    //ARMS Wrapper
    static testMethod void testMethod15() {
        testData01();
        
        Test.startTest();
    
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID    
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.closePopup();
            controller.cancelSearch();
            controller.searchErrorMsg = 'Test';
            controller.searchPackageMsg = 'Test';
            controller.searchPromotionMsg = 'Test';
            controller.subscriberChargeHidden = 1;
            controller.vendorCreditHidden = 1;
            controller.asia1ErrorMsg = 'Test';
            controller.acquisitionType = 'Test';
            controller.deliveryChargeType = 'Test';
            controller.glCode = 'Test';
            controller.dtlDate = date.today();
            controller.isSponsored = true;
            controller.fullPaymentMonthlyDeliveryCharge = 1;
            controller.amountPaid = 1000;
            controller.BaseSubRate = 1;
            controller.orderLineItemIdToBeRemoved = 'Test';
            controller.selectedOrderLineItem = 'Test';
            controller.selectedchangeOfSubscriptionOptions = 'Test';
            controller.isReInitializedItem = true;
            controller.getCOS_PACKAGE();
            controller.getCOS_QUANTITY();
            
            SM_ChangeOfSubscriptionEntryController.SubscriptionWrapper sw = new SM_ChangeOfSubscriptionEntryController.SubscriptionWrapper();
            sw.publicationName = 'Test';
            sw.publicationPrintPattern = 'Test';
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
    
    //Recurring
    static testMethod void testData16() {
        List<Other__c> otherList = CustomSettingsDataFactory.createOther(1);
        insert otherList;

        Cir_Planner_Schedule__c plannerSched = CustomSettingsDataFactory.createPlannerSched();
        insert plannerSched;

        Integer records = 1;
        Integer count = 0;
        
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
        
        //Address
        List<Address__c> addressList1 = TestDataFactory.createAddress(records);
        addressList1[0].Address_Type__c= 'H';
        addressList1[0].Postal_Code__c = singpostAddressList[0].Id;
        addressList1[0].Country__c = countryList[0].Id;
        insert addressList1;
        
        List<Account> accountList1 = TestDataFactory.createAccount(1, 'Direct Individual');
        count = 0;
        for (Account obj : accountList1) {
            obj.Singpost_Address__c = singpostAddressList[0].id;
            count++;
        }
        insert accountList1;
        
        List<Contact> contactList1 = TestDataFactory.createContact(records);
        count = 0;
        for (Contact obj : contactList1) {
            obj.AccountId = accountList1[count].Id;
            obj.City_Code__c = cityList[count].id;          
            obj.Recipient_Indicator__c = true;
            obj.Billing_Indicator__c = true;
            obj.Address__c = addressList1[0].Id;
            
            count++;
        }   
        insert contactList1; 
        
        //Product
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0]; //try to loop with many product sub type
        zProduct.ProductPlatform__c = 'Print';
        zProduct.ProductSubType__c = 'Newspaper';
        zProduct.ProductCode__c = 'STSU';
        insert zProduct;
        
        Zuora__Product__c prod = TestDataFactory.createProduct(1)[0];
        insert prod;
        
        //Product Rate Plan
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.SubscriptionFrequency__c = '2';
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        insert prdRatePlan;
        
        //Pubs
        List<Publication__c> publicationList1 = TestDataFactory.createPublication(1);
        count = 0;
        for (Publication__c publication : publicationList1 ) {
        publication.Product_Family__c = 'PrFam';
        publication.Published_Days__c = 'YYYYYYY';
        publication.Publication_Type__c = 'N';
        publication.Publication_Code__c = '1234';
        publication.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
        //publication.Earliest_Start_Date__c = date.today().addDays(1);
        count++;
        }
        insert publicationList1;
        
        //Product Publication
        List<Product_Publication__c> prodPubList1 = TestDataFactory.createProductPublication(1);
        count = 0;
        for(Product_Publication__c prodPub : prodPubList1 ){
            prodPub.Product_Code__c = prod.Id;
            prodPub.Publication_Code__c = publicationList1[0].Id;
            prodPub.ZProduct__c = zProduct.Id;
            count++;
        }
        insert prodPubList1;
        
        //Billing Account
        List<Zuora__CustomerAccount__c> zuoraCustomerAccountList1 = TestDataFactory.createBillingAccount(records);
        count = 0;
        for (Zuora__CustomerAccount__c obj : zuoraCustomerAccountList1) {
            obj.Billing_Contact__c = contactList1[count].id;          
            obj.Zuora__Account__c = accountList1[count].id;         
            obj.Zuora__Credit_Balance__c = 100;          
            obj.Billing_Type__c = 'Recurring Prepaid';
            obj.Zuora__DefaultPaymentMethod__c = 'Other';
            obj.Other_PaymentMethod__c  = 'External Parties';
            
            count++;
        }
        insert zuoraCustomerAccountList1;
        
        //Package
        List<Package__c> packageList1 = TestDataFactory.createPackage(records);
        packageList1[0].Package_Code__c = 'packsample';
        packageList1[0].Subscription_Type__c = 'Evergreen';
        packageList1[0].Package_Sub_Type__c = 'Single';
        packageList1[0].Subscription_Period__c = '12';
        packageList1[0].Billing_Type__c = 'Recurring Prepaid';
        insert packageList1;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'TestNAme';
        insert prodfam;
        
        //Package Items
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItem.Package__c = packageList1[0].Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Duration_in_months__c = '1';
        pItem.Effective_Start_Month__c = '1';
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        //Orders for old sub
        List<Order__c> orderList1 = TestDataFactory.createOrder(1);
        count = 0;
        for (Order__c obj : orderList1) {
            obj.Account__c = accountList1[0].id;           
            obj.Billing_Account__c = zuoraCustomerAccountList1[0].id;           
            obj.isChangeOfSubEntry__c = false;           
            obj.Order_Type__c = 'Start Subscription';
            obj.Billing_Type__c = 'Recurring Prepaid';          
            obj.Status__c = 'Close';
            obj.Recipient_Contact__c = contactList1[0].id;
            obj.Billing_Contact__c = contactList1[0].id;
            obj.Payment_Mode__c = 'Credit Card';
            obj.Payment_Method_ID__c = 'zID';
            obj.Subscriber_Charge__c = 100;
            //obj.Delivery_Charge_Type__c
            
            count++;
        }
        insert orderList1;
        
        //OLI
        List<Order_Line_Item__c> orderLineItemList1 = TestDataFactory.createOrderLineItem(records);
        count = 0;
        for (Order_Line_Item__c obj : orderLineItemList1) {
            obj.Order__c = orderList1[count].id;
            obj.Main_Package_ID__c = packageList1[count].id;
            obj.Start_Date__c = Date.today().addDays(1);
            obj.Qty__c = 1;
            obj.Subscribed_as__c = 'New Buy';
            obj.Term_Length__c = 12; 
            obj.Main_Package_Billing_Type__c = 'Recurring Prepaid';     
            
            count++;
        }
        insert orderLineItemList1;
        
        //Subs
        zuoraSubscriptionList = TestDataFactory.createSubscription(2);
        count = 0;
        for (Zuora__Subscription__c obj : zuoraSubscriptionList) {
            obj.Zuora__Account__c = accountList1[0].id;     
            obj.Zuora__CustomerAccount__c = zuoraCustomerAccountList1[0].id;
            obj.Main_Package_1__c = packageList1[0].id;          
            obj.Number_of_Copies1__c = '1';
            obj.Zuora__Status__c = Globalvariableclass.SUBSCRIPTION_STATUS_ACTIVE;
            obj.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            obj.Zuora__SubscriptionEndDate__c = null;
            obj.Subscription_Type__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
            obj.Subscription_Type_1__c = Globalvariableclass.SUBSCRIPTION_TYPE_PUBLICATION;
            obj.Zuora__TermSettingType__c = 'EVERGREEN';
            obj.Term_Length__c = 1;
            obj.Recipient_Contact__c = contactList1[0].id;
            obj.Contact__c = contactList1[0].id;
            obj.Delivery_Charge_Type_1__c = 'H';
            obj.Order_Number_1__c = orderList1[0].Id;
            obj.Order_Line_Item_Number_1__c = orderLineItemList1[0].Id;
            obj.Number_of_Copies__c = 1;             
            count++;
        }
        zuoraSubscriptionList[1].Subscription_Type__c = 'Delivery';
        zuoraSubscriptionList[1].Subscription_Type_1__c = 'Delivery';
        insert zuoraSubscriptionList;
        
        
        Test.startTest();
            
        // Initialization of VisualForce Page
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        
        ApexPages.currentPage().getParameters().put('accountId', accountList1[0].id); 
        
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
        Try {
            controller.thisOrder = orderList1[0];
            controller.retrieveActiveSubscriptions();
            controller.refreshSubscriberCharge();
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
        
        
        Test.stopTest(); 
            
    }
    static testMethod void testMethod16() {

        testData01();
        orderlist[0].Payment_Mode__c = 'Credit Card';
        orderlist[0].Other_Payment_Mode__c = 'eNets';
        orderlist[0].Payment_Method_ID__c = null;
        orderlist[0].Recipient_Contact__c = null;
        
        update orderlist;
        Test.startTest();        
        
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.getEarliestStart(packageList[0].Id);
            controller.continueSave();
            controller.getDeliveryChargeTypes(); //fritz
            controller.billingAccountOption = 'createNew';      
            controller.save();
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
                
        Test.stopTest();

    }
        static testMethod void testMethod17() {

        testData01();

        List<Zuora_HPM_Settings__c> hpmSettings = CustomSettingsDataFactory.createZuora_HPM_Settings();
        insert hpmSettings;

        orderlist[0].Payment_Mode__c = 'Other';
        orderlist[0].Other_Payment_Mode__c = 'Invoice';
        orderlist[0].Business_Profile__c = '';
        orderlist[0].Debt_Management_Treatment__c = '';
        orderlist[0].Delivery_Charge_Type__c = 'test';
        
        update orderlist;
        
        Test.startTest();     
        
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[0].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.getEarliestStart(packageList[0].Id);
            controller.continueSave();
            controller.getDeliveryChargeTypes(); //fritz
            controller.billingAccountOption = 'createNew';      
            controller.save();
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
        
        controller.paymentGetway = '';
        controller.creditCardType = '';
        controller.retrieveSource();
        controller.clearPaymentMethod();
        controller.clearOtherPaymentMethod();
        controller.errorMsg = '';
        Try{
        controller.addPopAcc();
        }catch(Exception e){}        
        Try{
        controller.retrieveAdminFeeAdminCharge();
        }catch(Exception e){}
                
        Test.stopTest();

    }

    static testMethod void testMethod17b() {

        testData01();

        List<Zuora_HPM_Settings__c> hpmSettings = CustomSettingsDataFactory.createZuora_HPM_Settings();
        insert hpmSettings;

        System.debug('test class testMethod17 >>> ::' + zuoraSubscriptionList[1].Main_Package_1__c);


        Test.startTest();     
        
        PageReference pRef = Page.SM_ChangeOfSubscriptionEntry;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('subscriptionId', zuoraSubscriptionList[1].id); //Subscription ID
        ApexPages.currentPage().getParameters().put('accountId', accountList[0].id); // Account ID
        ApexPages.currentPage().getParameters().put('id', orderList[0].id);          // Order ID
        ApexPages.currentPage().getParameters().put('def_parent_id', parentCase[0].Id);
               
        // BaseClass
        SM_ChangeOfSubscriptionEntryController controller = new SM_ChangeOfSubscriptionEntryController();
    
        Try {
            controller.retrieveActiveSubscriptions();
            controller.getEarliestStart(packageList[0].Id);
            controller.continueSave();
            controller.getDeliveryChargeTypes(); //fritz
            controller.billingAccountOption = 'createNew';      
            controller.save();
        }catch(Exception e){
            System.debug('XXXXXXXXXX');
            System.debug(e);
            System.debug('XXXXXXXXXX');
        }
        
        controller.paymentGetway = '';
        controller.creditCardType = '';
        controller.retrieveSource();
        controller.clearPaymentMethod();
        controller.clearOtherPaymentMethod();
        controller.errorMsg = '';
        Try{
        controller.addPopAcc();
        }catch(Exception e){}        
        Try{
        controller.retrieveAdminFeeAdminCharge();
        }catch(Exception e){}
                
        Test.stopTest();

    }
*/
    
    
}