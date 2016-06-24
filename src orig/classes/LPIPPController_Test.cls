/**
 * Class Name: <LPIPPController_Test>
 * @author: <CV Manawatao>
 * Date: <28/01/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for LPIPPController>
*/

@isTest (Seealldata = TRUE)
private class LPIPPController_Test {
    
    static Account vendorAcct;
    static Singpost_Address__c singPostAddr;
    static Address__c address;
    static Contact contact;
    
    static zqu__ZProduct__c zProduct;
    static zqu__ProductRatePlan__c prodRatePlan;
    static zqu__ProductRatePlanCharge__c prodRatePlanCharge;
    
    static Package__c aPackage;
    static Package_Item__c packageItem;
    static Order__c order;
    static Order_Line_Item__c orderLineItem;
    static Vendor_Allocation__c vendorAlloc; 
    static Zuora__Subscription__c zouraSubscription;
    static Case aCase;
    static Zuora__CustomerAccount__c billingaccount;
    static List<Id> oliId;
    static Promotion__c promo;
    static Gift__c giftRec;
    static Promotion_Gift__c promogift;
    static Order_Line_Item_Gift__c oligift;
    static Gift_Letter_Batch__c glb;
    static Country__c country;
    
    
    static void prepareTestData(){
        setUpFirstDataFactory();
        Test.startTest();
        setUpSecondDataFactory();
    }
    
    static void prepareTestDataVersion2(){
        setUpThirdDataFactory();
        Test.startTest();
        setUpFourthDataFactory();
    } 
    
     /**
        @name setUpFirstDataFactory
        @param none
        @return void
        @description sets up data required for the test
    */
    private static void setUpFirstDataFactory() {
    
        vendorAcct = TestDataFactory.createAccount(1, 'Vendor')[0]; 
        insert vendorAcct;
        
        singPostAddr = TestDataFactory.createSingpostAddress(1)[0];
        singPostAddr.Name = 'SPostal';
        singPostAddr.House_Block_Number__c = 'TEST';
        //singPostAddr.orderRecord_Type__c = 'A';
        insert singPostAddr;  
        
        country = TestDataFactory.createCountry(1)[0];
        country.Country_Name__c = 'SINGAPORE';
        insert country;      
        
        address = TestDataFactory.createAddress(1)[0];
        address.Address_Type__c = 'P';
        address.Postal_Code__c = singPostAddr.Id;
        address.Block_House_Number__c ='TEST';
        address.Level_Number__c ='xx';
        address.Unit_Number__c = 'yy';
        address.Country__c = country.Id;
        insert address;        
        
        billingaccount = TestDataFactory.createBillingAccount(1)[0];
        billingaccount.Zuora__Account__c = vendorAcct.Id;
        insert billingaccount;
        
        contact = TestDataFactory.createContact(1)[0];
        contact.Address__c = address.Id;
        contact.AccountId = vendorAcct.Id;
        contact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contact.Recipient_Indicator__c = true;
        insert contact;        
        
        zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        prodRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prodRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prodRatePlan;
        
        prodRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prodRatePlanCharge.zqu__ProductRatePlan__c = prodRatePlan.Id;
        insert prodRatePlanCharge;        
                       
        aPackage = TestDataFactory.createPackage(1)[0]; 
        aPackage.Name = 'Pack name';
        aPackage.Billing_Type__c = 'Full Prepaid';
        aPackage.Package_Type__c = 'Base';
        aPackage.Subscription_Period__c = '18';
        aPackage.Package_Code__c = 'afds132';
        insert aPackage;        
        
        packageItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItem.Package__c = aPackage.Id;
        packageItem.Product_Rate_Plan__c = prodRatePlan.Id;
        insert packageItem;
        
    }
    
    
    /**
        @name setUpSecondDataFactory
        @param none
        @return void
        @description sets up data required for the test
    */
    private static void setUpSecondDataFactory() { 
        
        aCase = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        insert aCase;
           
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = vendorAcct.Id;
        order.Informed_Customer__c = true;
        order.Recipient_Contact__c = contact.Id;
        //order.Order_Type__c = 'Renewal';
        //order.Status__c = 'Draft';
        order.Status__c = 'Closed';
        order.Eligible_for_Retention__c = true;
        //order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        //order.Billing_Account__c = billAcc.id;
        //order.Billing_Contact__c = contact.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        //order.Order_Type__c = 'Change of Subscription Package';
        order.Order_Type__c = 'Change of Subscription Quantity';
        order.PO_Number__c = 'PO00000';
        //order.Postage_Charge__c = 0;
        order.Subscriber_Charge__c = 100.00;
        insert order;
        
        System.debug('ASM order.Id = ' + order.Id);
        
            orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.Id;
            orderLineItem.Case__c = aCase.Id;        
            orderLineItem.Main_Package_ID__c = aPackage.Id;
            orderLineItem.Main_Package_Type__c = 'Base';
            orderLineItem.Main_Package_Billing_Type__c = 'Full Prepaid'; //NOTE
            orderLineItem.Main_Package_Period__c = 0;
            orderLineItem.Start_Date__c = Date.today().addDays(1); //LIMOT
            orderLineItem.End_Date__c = Date.Today().addDays(2);
            orderLineItem.Term_Length__c = 0;        
            orderLineItem.Earliest_Start_Date__c = Date.today();
            orderLineItem.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderLineItem.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderLineItem.Terminating_Reason__c = 'Others';
            orderLineItem.Amount_To_Refund__c = 0;
            orderLineItem.Admin_Charge__c = 0;
            orderLineItem.Fee_Waiver__c = false; //LIMOT
            orderLineItem.Fee_Override__c = true; 
            orderLineItem.Override_Reason__c = 'TEST';
            orderLineItem.Suppress_Notification_Stop__c = true;        
            orderLineItem.Vendor_Mailing_Agent__c = vendorAcct.Id;
            orderLineItem.Postage_Charge__c = 0;
            orderLineItem.Main_Package_Product_Sub_Type__c = 'Newspaper';
            orderLineItem.Term_Length__c = 10;
            insert orderLineItem;       
            
            zouraSubscription = TestDataFactory.createSubscription(1)[0];
        
        zouraSubscription.Zuora__Zuora_Id__c = 'zouraId';
        zouraSubscription.Zuora__CustomerAccount__c = billingaccount.Id;
        zouraSubscription.Zuora__Status__c = 'Active';
        zouraSubscription.Zuora__Account__c = vendorAcct.Id;
        zouraSubscription.Zuora__SubscriptionEndDate__c = Date.today().addDays(30);        
        
        zouraSubscription.Subscriber_Contact__c = contact.Id;
        //zouraSubscription.Recipient_Contact__c = contact.Id;       
        
        zouraSubscription.Main_Package_1__c = aPackage.Id;
        zouraSubscription.Order_Number__c = order.Id;
        zouraSubscription.Order_Number_1__c = order.Id;
        zouraSubscription.Order_Line_Item_Number__c = orderLineItem.Id;
        zouraSubscription.Order_Line_Item_Number_1__c = orderLineItem.Id;
        
        zouraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
        zouraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
        zouraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zouraSubscription.Urgent__c = 'false';
        
        zouraSubscription.Vendor_Conversion__c = 'false';
        zouraSubscription.Vendor__c = vendorAcct.Id;
        zouraSubscription.Vendor_1__c = vendorAcct.Id;         
        zouraSubscription.Charity__c = 'false';
        
        zouraSubscription.Billing_Type__c = 'Full Pre'; //NOTE       
        
        zouraSubscription.Subscription_Type__c = 'Delivery';
        zouraSubscription.Subscription_Type_1__c = 'Delivery';
        zouraSubscription.Unique_Delivery_Identifier__c = 'xx-yy;SPostal';
        
        zouraSubscription.Number_of_Copies1__c =  '100';
        zouraSubscription.Number_of_Copies__c = 100;
        zouraSubscription.Qty__c = 20;
        zouraSubscription.Delivery_Charge__c = 100.00; 
        zouraSubscription.Id = order.Subscription__r.Id; 
        insert zouraSubscription; 
        
        promo = TestDataFactory.createPromotion(1)[0];
            promo.RecordTypeId = [Select Id From RecordType Where Name = 'Gift Promotion' LIMIT 1].id;
            promo.Promotion_Name__c = 'Test Promotion';
            promo.Promotion_Code__c = '0123456789';
            promo.Effective_Start_Date__c = date.today();
            promo.Effective_End_Date__c = date.today().addDays(30);
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            insert promo;
 
            giftRec = TestDataFactory.createGift(1)[0];
            giftRec.Gift_Code__c = 'GiftCode1234567890';
            insert giftRec;

            promogift = TestDataFactory.createPromotionGift(1)[0];
            promogift.Promotion__c = promo.id;
            insert promogift;

            oligift = new Order_Line_Item_Gift__c();
            oligift.Order_Line_Item__c = orderLineItem.id;
            oligift.Promotion_Gift__c = promogift.id;
            oligift.Redemption_Date__c = date.today();
            oligift.Redemption_Quantity__c = 1;
            oligift.Gift_ID__c = giftRec.id;
            insert oligift;
            
            glb = new Gift_Letter_Batch__c();
            glb.Promotion__c = promo.id;
            glb.Gift__c = giftRec.id;
            glb.Redemption_Start_Date__c = date.today();
            glb.Start_Date__c = date.today().addDays(1);
            glb.End_Date__c = date.today().addDays(2);
            glb.Redemption_End_Date__c = date.today().addDays(1);
            insert glb;
        
        vendorAlloc = TestDataFactory.createVendorAlloc(1)[0];   
        vendorAlloc.Vendor_Account__c = vendorAcct.Id;
        vendorAlloc.SingPost_Address__c = singPostAddr.Id;
        vendorAlloc.Effective_Start_Date__c = Date.today();
        vendorAlloc.Allocated__c = true;
        insert vendorAlloc; 

      }
      
      private static void setUpThirdDataFactory() { 
        
        vendorAcct = TestDataFactory.createAccount(1, 'Vendor')[0]; 
        insert vendorAcct;
        
        singPostAddr = TestDataFactory.createSingpostAddress(1)[0];
        singPostAddr.Name = 'SPostal';
        singPostAddr.House_Block_Number__c = 'TEST';
        //singPostAddr.orderRecord_Type__c = 'A';
        insert singPostAddr;   

        //START UD-3336 Gdelrosario 4.3.2016
        //create country
        Country__c count = TestDataFactory.createCountry(1)[0];
         count.Code__c = 'Zz';
         insert count;
        //END UD-3336 Gdelrosario 4.3.2016     
        
        address = TestDataFactory.createAddress(1)[0];
        //START UD-3336 Gdelrosario 4.3.2016
         address.Country__c = count.Id;
        //END UD-3336 Gdelrosario 4.3.2016
        address.Address_Type__c = 'P';
        address.Postal_Code__c = singPostAddr.Id;
        address.Block_House_Number__c ='TEST';
        address.Level_Number__c ='xx';
        address.Unit_Number__c = 'yy';
        insert address;        
        
        billingaccount = TestDataFactory.createBillingAccount(1)[0];
        billingaccount.Zuora__Account__c = vendorAcct.Id;
        insert billingaccount;
        
        contact = TestDataFactory.createContact(1)[0];
        contact.Address__c = address.Id;
        contact.AccountId = vendorAcct.Id;
        contact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contact.Recipient_Indicator__c = true;
        insert contact;        
        
        zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        prodRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prodRatePlan.zqu__ZProduct__c = zProduct.Id;
        insert prodRatePlan;
        
        prodRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prodRatePlanCharge.zqu__ProductRatePlan__c = prodRatePlan.Id;
        insert prodRatePlanCharge;        
                       
        aPackage = TestDataFactory.createPackage(1)[0]; 
        aPackage.Name = 'Pack name';
        aPackage.Billing_Type__c = 'Full Prepaid';
        aPackage.Package_Type__c = 'Bundle';
        aPackage.Subscription_Period__c = '18';
        aPackage.Package_Code__c = 'afds132';
        insert aPackage;        
        
        packageItem = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
        packageItem.Package__c = aPackage.Id;
        packageItem.Product_Rate_Plan__c = prodRatePlan.Id;
        insert packageItem;
      } 
      
   private static void setUpFourthDataFactory() { 
        
        aCase = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        insert aCase;
           
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = vendorAcct.Id;
        order.Informed_Customer__c = true;
        order.Recipient_Contact__c = contact.Id;
        //order.Order_Type__c = 'Renewal';
        //order.Status__c = 'Draft';
        order.Status__c = 'Closed';
        order.Eligible_for_Retention__c = true;
        //order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        //order.Billing_Account__c = billAcc.id;
        //order.Billing_Contact__c = contact.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        //order.Order_Type__c = 'Change of Subscription Package';
        order.Order_Type__c = 'Change of Subscription Quantity';
        order.PO_Number__c = 'PO00000';
        //order.Postage_Charge__c = 10.00;
        order.Subscriber_Charge__c = 100.00;
        insert order;
        
        System.debug('ASM order.Id = ' + order.Id);
        
            orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.Id;
            orderLineItem.Case__c = aCase.Id;        
            orderLineItem.Main_Package_ID__c = aPackage.Id;
            orderLineItem.Main_Package_Type__c = 'Base';
            orderLineItem.Main_Package_Billing_Type__c = 'Full Prepaid'; //NOTE
            orderLineItem.Main_Package_Period__c = 0;
            orderLineItem.Start_Date__c = Date.today().addDays(1); //LIMOT
            orderLineItem.End_Date__c = Date.Today().addDays(2);
            orderLineItem.Term_Length__c = 0;        
            orderLineItem.Earliest_Start_Date__c = Date.today();
            orderLineItem.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderLineItem.Stop_Request_Date__c =  Date.Today().addDays(4);
            orderLineItem.Terminating_Reason__c = 'Others';
            orderLineItem.Amount_To_Refund__c = 0;
            orderLineItem.Admin_Charge__c = 0;
            orderLineItem.Fee_Waiver__c = false; //LIMOT
            orderLineItem.Fee_Override__c = true; 
            orderLineItem.Override_Reason__c = 'TEST';
            orderLineItem.Suppress_Notification_Stop__c = true;        
            orderLineItem.Vendor_Mailing_Agent__c = vendorAcct.Id;
            orderLineItem.Main_Package_Product_Sub_Type__c = 'Newspaper';
            orderLineItem.Term_Length__c = 10;
            orderlineItem.Postage_Charge__c = 10.00;
            insert orderLineItem;       
            
            zouraSubscription = TestDataFactory.createSubscription(1)[0];
        
        zouraSubscription.Zuora__Zuora_Id__c = 'zouraId';
        zouraSubscription.Zuora__CustomerAccount__c = billingaccount.Id;
        zouraSubscription.Zuora__Status__c = 'Active';
        zouraSubscription.Zuora__Account__c = vendorAcct.Id;
        zouraSubscription.Zuora__SubscriptionEndDate__c = Date.today().addDays(30);        
        
        zouraSubscription.Subscriber_Contact__c = contact.Id;
        //zouraSubscription.Recipient_Contact__c = contact.Id;       
        
        zouraSubscription.Main_Package_1__c = aPackage.Id;
        zouraSubscription.Order_Number__c = order.Id;
        zouraSubscription.Order_Number_1__c = order.Id;
        zouraSubscription.Order_Line_Item_Number__c = orderLineItem.Id;
        zouraSubscription.Order_Line_Item_Number_1__c = orderLineItem.Id;
        
        zouraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
        zouraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
        zouraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zouraSubscription.Urgent__c = 'false';
        
        zouraSubscription.Vendor_Conversion__c = 'false';
        zouraSubscription.Vendor__c = vendorAcct.Id;
        zouraSubscription.Vendor_1__c = vendorAcct.Id;         
        zouraSubscription.Charity__c = 'false';
        
        zouraSubscription.Billing_Type__c = 'Full Pre'; //NOTE       
        
        zouraSubscription.Subscription_Type__c = 'Postage';
        zouraSubscription.Subscription_Type_1__c = 'Postage';
        zouraSubscription.Unique_Delivery_Identifier__c = 'xx-yy;SPostal';
        
        zouraSubscription.Number_of_Copies1__c =  '100';
        zouraSubscription.Number_of_Copies__c = 100;
        zouraSubscription.Qty__c = 20;
        zouraSubscription.Delivery_Charge__c = 100.00; 
        //zouraSubscription.Id = order.Subscription__r.Id;
        insert zouraSubscription; 
        //zouraSubscription.Subscription_Charge__c = 10.00;
        
        
        promo = TestDataFactory.createPromotion(1)[0];
            promo.RecordTypeId = [Select Id From RecordType Where Name = 'Gift Promotion' LIMIT 1].id;
            promo.Promotion_Name__c = 'Test Promotion';
            promo.Promotion_Code__c = '0123456789';
            promo.Effective_Start_Date__c = date.today();
            promo.Effective_End_Date__c = date.today().addDays(30);
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            insert promo;
 
            giftRec = TestDataFactory.createGift(1)[0];
            giftRec.Gift_Code__c = 'GiftCode1234567890';
            insert giftRec;

            promogift = TestDataFactory.createPromotionGift(1)[0];
            promogift.Promotion__c = promo.id;
            insert promogift;

            oligift = new Order_Line_Item_Gift__c();
            oligift.Order_Line_Item__c = orderLineItem.id;
            oligift.Promotion_Gift__c = promogift.id;
            oligift.Redemption_Date__c = date.today();
            oligift.Redemption_Quantity__c = 1;
            oligift.Gift_ID__c = giftRec.id;
            insert oligift;
            
            glb = new Gift_Letter_Batch__c();
            glb.Promotion__c = promo.id;
            glb.Gift__c = giftRec.id;
            glb.Redemption_Start_Date__c = date.today();
            glb.Start_Date__c = date.today().addDays(1);
            glb.End_Date__c = date.today().addDays(2);
            glb.Redemption_End_Date__c = date.today().addDays(1);
            insert glb;
        
        vendorAlloc = TestDataFactory.createVendorAlloc(1)[0];   
        vendorAlloc.Vendor_Account__c = vendorAcct.Id;
        vendorAlloc.SingPost_Address__c = singPostAddr.Id;
        vendorAlloc.Effective_Start_Date__c = Date.today();
        vendorAlloc.Allocated__c = true;
        insert vendorAlloc; 

      } 
      
      
            static testmethod void testPopulateLPPTemplate(){
      
            prepareTestData();
            LPIPPController lpipps = new LPIPPController();
            lpipps.recipientContact = contact;

            ApexPages.CurrentPage().getParameters().put('giftLetterBatchId', glb.id);
            ApexPages.CurrentPage().getParameters().put('Id', oligift.id);
            LPIPPController lpipp = new LPIPPController();
            lpipp.populateLPPTemplate();
            lpipp.zuoSub = zouraSubscription;
            lpipp.delSubscription = zouraSubscription;
            lpipp.zuoSubDel = zouraSubscription;
            lpipp.blockHouseNum = address.Block_House_Number__c;
            lpipp.levelNum = address.Level_Number__c;
            lpipp.unitNum = address.Unit_Number__c;
            lpipp.buildingName = 'test';
            lpipp.stName = 'test';
            lpipp.postalCode = address.Postal_Code__c;
            lpipp.countryName = address.Country__c;
            lpipp.contractPeriod = 10;
        
            Test.stopTest();
            /*System.assertEquals('XX', lpipp.levelNum);
            System.assertEquals('YY', lpipp.unitNum);
            System.assertEquals('TESTBLDGNAME0', lpipp.buildingName);
            System.assertEquals(null, lpipp.countryName);
            System.assertEquals('SPOSTAL', lpipp.postalCode);
            System.assertEquals(null, lpipp.contractPeriod);
            System.assertEquals('TEST', lpipp.blockHouseNum);*/
            
      }
      
      static testmethod void testZouraSubGreaterThanZero(){
      
            prepareTestData();
            LPIPPController lpipps = new LPIPPController();
            lpipps.recipientContact = contact;

            ApexPages.CurrentPage().getParameters().put('giftLetterBatchId', glb.id);
            ApexPages.CurrentPage().getParameters().put('Id', oligift.id);
            LPIPPController lpipp = new LPIPPController();
            lpipp.populateLPPTemplate();
            
            Test.stopTest();
      } 
      
      static testmethod void testPackageItemIsBundle(){
      
            prepareTestDataVersion2();
            LPIPPController lpipps = new LPIPPController();
            lpipps.recipientContact = contact;

            ApexPages.CurrentPage().getParameters().put('giftLetterBatchId', glb.id);
            ApexPages.CurrentPage().getParameters().put('Id', oligift.id);
            LPIPPController lpipp = new LPIPPController();
            lpipp.populateLPPTemplate();
            
            Test.stopTest();
      } 
      
      static testmethod void testGiftLetterBatchIdIsNull(){
      
            prepareTestDataVersion2();
            LPIPPController lpipps = new LPIPPController();
            lpipps.recipientContact = contact;

            //ApexPages.CurrentPage().getParameters().put('giftLetterBatchId', glb.id);
            ApexPages.CurrentPage().getParameters().put('Id', oligift.id);
            LPIPPController lpipp = new LPIPPController();
            lpipp.populateLPPTemplate();
            
            Test.stopTest();
      } 
      
      static testmethod void unitTest1(){

        User user1 = new User(
        Alias = 'Standard',
        Email = 'standarduser@gmail.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'),
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'userstand3541987*@testorg.com'
        );
            
            System.RunAs(user1){
            
            Account acc = TestDataFactory.createAccount(1, 'Direct SPH Inter-Division')[0];
            insert acc;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
            
            SPH_Department__c dept = new SPH_Department__c();
            dept.Department_Name__c = 'Test';
            insert dept;
            
            SPH_Division__c div = new SPH_Division__c();
            div.Name = 'Test';
            insert div;
            
            SPH_Section__c sec = new SPH_Section__c();
            sec.Section_Name__c = 'Test';
            insert sec;
            
            SPH_Location__c loc = new SPH_Location__c();
            loc.Location_Name__c = 'Test';
            insert loc;
            
            SPH_Company__c comp = new SPH_Company__c();
            comp.Company_Name__c = 'test';
            insert comp;
            
            City__c cit = TestDataFactory.createCity(1)[0];
            cit.Flight_Number_1__c = 'flight1';
            cit.Flight_Number_2__c = 'flight2';
            insert cit;
 
            Country__c ctry = TestDataFactory.createCountry(1)[0]; 
            ctry.Country_Name__c = 'SINGAPORE'; 
            insert ctry;
            
            address = TestDataFactory.createAddress(1)[0];
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
            address.Block_House_Number__c =  'Block 10';
            address.Postal_Code__c = postal.id;
            address.Level_Number__c = '17';
            address.Unit_Number__c = 'Unit 5';
            address.Country__c = ctry.id;
            address.Address_1__c = 'test';
            address.Address_2__c = 'test';
            address.Address_3__c = 'test';
            address.Address_4__c = 'test';
            address.Company_Code__c = comp.Id;
            address.Department__c = dept.Id;
            address.Division_Code__c = div.Id;
            address.Section_Code__c = sec.Id;
            address.Location_Code__c = loc.Id;
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            con.HomePhone__c = '1234567890';
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id; 
            insert orderRec;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Base';
            pack.Name = 'Test Package';
            pack.Subscription_Period__c = '1';
            insert pack;
           
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.today().addDays(10);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = FALSE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today().addDays(2);
            insert orderline;
                
            Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();        
            billAcc.Zuora__Account__c = acc.id;
            billAcc.Billing_Contact__c = con.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            insert billAcc;
            
            promo = TestDataFactory.createPromotion(1)[0];
            promo.RecordTypeId = [Select Id From RecordType Where Name = 'Gift Promotion' LIMIT 1].id;
            promo.Promotion_Name__c = 'Test Promotion';
            promo.Promotion_Code__c = '0123456789';
            promo.Effective_Start_Date__c = date.today();
            promo.Effective_End_Date__c = date.today().addDays(10);
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            insert promo;
            
            promogift = TestDataFactory.createPromotionGift(1)[0];
            promogift.Promotion__c = promo.id;
            insert promogift;
 
            giftRec = TestDataFactory.createGift(1)[0];
            giftRec.Gift_Code__c = 'GiftCode1234567890';
            insert giftRec;
            
            oligift = new Order_Line_Item_Gift__c();
            oligift.Order_Line_Item__c = orderline.id;
            oligift.Promotion_Gift__c = promogift.id;
            oligift.Redemption_Date__c = date.today();
            oligift.Redemption_Quantity__c = 1;
            oligift.Gift_ID__c = giftRec.id;
            insert oligift;
            
            glb = new Gift_Letter_Batch__c();
            glb.Promotion__c = promo.id;
            glb.Gift__c = giftRec.id;
            glb.Redemption_Start_Date__c = date.today();
            glb.Start_Date__c = date.today().addDays(1);
            glb.End_Date__c = date.today().addDays(2);
            glb.Redemption_End_Date__c = date.today().addDays(1);
            insert glb;
            
            LPIPPController lpipps = new LPIPPController();
            lpipps.recipientContact = con;
            //lpipps.zuoSub = subs;
            //lpipps.zuoSubDel = subs;
            //lpipps.delSubscription = subs;
            lpipps.countryName = 'testcountryname';
            lpipps.contractPeriod = 12345;
  
            Test.startTest();
            ApexPages.CurrentPage().getParameters().put('giftLetterBatchId', glb.id);
            ApexPages.CurrentPage().getParameters().put('Id', oligift.id);
            LPIPPController lpipp = new LPIPPController();
            lpipp.populateLPPTemplate();
            Test.stopTest();
          }  
    }//end of unitTest1
    
    static testmethod void unitTest2(){

        User user1 = new User(
        Alias = 'Standard',
        Email = 'standarduser@gmail.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'),
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'userstand3541987*@testorg.com'
        );
            
            System.RunAs(user1){
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert acc;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
            
            Country__c ctry = TestDataFactory.createCountry(1)[0]; 
            ctry.Country_Name__c = 'SINGAPORE'; 
            insert ctry;
            
            address = TestDataFactory.createAddress(1)[0];
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
            address.Block_House_Number__c =  'Block 10';
            address.Postal_Code__c = postal.id;
            address.Level_Number__c = '17';
            address.Unit_Number__c = 'Unit 5';
            address.Country__c = ctry.id;
            address.Address_1__c = 'test';
            address.Address_2__c = 'test';
            address.Address_3__c = 'test';
            address.Address_4__c = 'test';
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            con.HomePhone__c = '1234567890';
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id; 
            insert orderRec;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Base';
            pack.Name = 'Test Package';
            pack.Subscription_Period__c = '1';
            insert pack;
           
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.today().addDays(10);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = FALSE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today().addDays(2);
            insert orderline;
                
            Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();        
            billAcc.Zuora__Account__c = acc.id;
            billAcc.Billing_Contact__c = con.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            insert billAcc;
            
            zouraSubscription = TestDataFactory.createSubscription(1)[0];
            zouraSubscription.Zuora__Zuora_Id__c = 'zouraId';
            zouraSubscription.Zuora__CustomerAccount__c = billAcc.Id;
            zouraSubscription.Zuora__Status__c = 'Active';
            zouraSubscription.Zuora__Account__c = acc.Id;
            zouraSubscription.Zuora__SubscriptionEndDate__c = Date.today().addDays(30);        
            zouraSubscription.Subscriber_Contact__c = con.Id;
            //zouraSubscription.Recipient_Contact__c = contact.Id;       
            zouraSubscription.Main_Package_1__c = pack.Id;
            zouraSubscription.Order_Number__c = orderRec.Id;
            zouraSubscription.Order_Number_1__c = orderRec.Id;
            zouraSubscription.Order_Line_Item_Number__c = orderline.Id;
            zouraSubscription.Order_Line_Item_Number_1__c = orderline.Id; 
            zouraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
            zouraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
            zouraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zouraSubscription.Urgent__c = 'false';
            zouraSubscription.Vendor_Conversion__c = 'false';
            zouraSubscription.Charity__c = 'false';
            zouraSubscription.Billing_Type__c = 'Full Prepaid'; //NOTE       
            zouraSubscription.Subscription_Type__c = 'Publication';
            zouraSubscription.Subscription_Type_1__c = 'Publication';
            zouraSubscription.Unique_Delivery_Identifier__c = 'xx-yy;SPostal';
            zouraSubscription.Number_of_Copies1__c =  '100';
            zouraSubscription.Number_of_Copies__c = 100;
            zouraSubscription.Qty__c = 20;
            zouraSubscription.Delivery_Charge__c = 100.00; 
            insert zouraSubscription;
            
            promo = TestDataFactory.createPromotion(1)[0];
            promo.RecordTypeId = [Select Id From RecordType Where Name = 'Gift Promotion' LIMIT 1].id;
            promo.Promotion_Name__c = 'Test Promotion';
            promo.Promotion_Code__c = '0123456789';
            promo.Effective_Start_Date__c = date.today();
            promo.Effective_End_Date__c = date.today().addDays(10);
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            insert promo;
            
            promogift = TestDataFactory.createPromotionGift(1)[0];
            promogift.Promotion__c = promo.id;
            insert promogift;
            //START UD-3336 Gdelrosario 4.3.2016
            Gift__c forGiftCode = [SELECT Gift_Code__c FROM Gift__c WHERE Gift_Code__c = 'XM2' LIMIT 1];
            //END UD-3336 Gdelrosario 4.3.2016
            giftRec = TestDataFactory.createGift(1)[0];
            giftRec.Gift_Code__c = forGiftCode.Gift_Code__c;  //'GiftCode1234567890';
            insert giftRec;
            
            oligift = new Order_Line_Item_Gift__c();
            oligift.Order_Line_Item__c = orderline.id;
            oligift.Promotion_Gift__c = promogift.id;
            oligift.Redemption_Date__c = date.today();
            oligift.Redemption_Quantity__c = 1;
            oligift.Gift_ID__c = giftRec.id;
            insert oligift;
            
            glb = new Gift_Letter_Batch__c();
            glb.Promotion__c = promo.id;
            glb.Gift__c = giftRec.id;
            glb.Redemption_Start_Date__c = date.today();
            glb.Start_Date__c = date.today().addDays(1);
            glb.End_Date__c = date.today().addDays(2);
            glb.Redemption_End_Date__c = date.today().addDays(1);
            insert glb;
            
            LPIPPController lpipps = new LPIPPController();
            lpipps.recipientContact = con;
            //lpipps.zuoSub = subs;
            //lpipps.zuoSubDel = subs;
            //lpipps.delSubscription = subs;
            lpipps.countryName = 'testcountryname';
            lpipps.contractPeriod = 12345;
  
            Test.startTest();
            ApexPages.CurrentPage().getParameters().put('giftLetterBatchId', glb.id);
            ApexPages.CurrentPage().getParameters().put('Id', oligift.id);
            LPIPPController lpipp = new LPIPPController();
            lpipp.populateLPPTemplate();
            Test.stopTest();
          }
    } 
    
    static testmethod void unitTest3(){

            User user1 = new User(
        Alias = 'Standard',
        Email = 'standarduser@gmail.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'),
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'userstand3541987*@testorg.com'
        );
            
            System.RunAs(user1){
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.Airline_Indicator__c = TRUE;
            insert acc;
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
            
            Country__c ctry = TestDataFactory.createCountry(1)[0]; 
            ctry.Country_Name__c = 'SINGAPORE'; 
            insert ctry;
            
            SPH_Department__c dept = new SPH_Department__c();
            dept.Name = 'Test';
            insert dept;
            
            SPH_Division__c div = new SPH_Division__c();
            div.Name = 'Test';
            insert div;
            
            SPH_Section__c sec = new SPH_Section__c();
            sec.Name = 'Test';
            insert sec;
            
            SPH_Location__c loc = new SPH_Location__c();
            loc.Name = 'Test';
            insert loc;
            
            SPH_Company__c comp = new SPH_Company__c();
            comp.Company_Name__c = 'test';
            insert comp;
            
            City__c cit = TestDataFactory.createCity(1)[0];
            cit.Flight_Number_1__c = 'flight1';
            cit.Flight_Number_2__c = 'flight2';
            cit.City_Name__c = 'test';
            cit.Country__c = ctry.id;
            insert cit;
            
            address = TestDataFactory.createAddress(1)[0];
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
            address.Block_House_Number__c =  'Block 10';
            address.Postal_Code__c = postal.id;
            address.Level_Number__c = '17';
            address.Unit_Number__c = 'Unit 5';
            address.Country__c = ctry.id;
            address.Address_1__c = 'test';
            address.Address_2__c = 'test';
            address.Address_3__c = 'test';
            address.Address_4__c = 'test';
            address.Company_Code__c = comp.Id;
            address.Department__c = dept.Id;
            address.Division_Code__c = div.Id;
            address.Section_Code__c = sec.Id;
            address.Location_Code__c = loc.Id;
            address.City__c = cit.id;
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = address.id;
            con.Recipient_Indicator__c = true;
            con.HomePhone__c = '1234567890';
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id; 
            insert orderRec;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Base';
            pack.Name = 'Test Package';
            pack.Subscription_Period__c = '1';
            insert pack;
           
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.today().addDays(10);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = FALSE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today().addDays(2);
            insert orderline;
                
            Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();        
            billAcc.Zuora__Account__c = acc.id;
            billAcc.Billing_Contact__c = con.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            insert billAcc;
            
            promo = TestDataFactory.createPromotion(1)[0];
            promo.RecordTypeId = [Select Id From RecordType Where Name = 'Gift Promotion' LIMIT 1].id;
            promo.Promotion_Name__c = 'Test Promotion';
            promo.Promotion_Code__c = '0123456789';
            promo.Effective_Start_Date__c = date.today();
            promo.Effective_End_Date__c = date.today().addDays(10);
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            insert promo;
            
            promogift = TestDataFactory.createPromotionGift(1)[0];
            promogift.Promotion__c = promo.id;
            insert promogift;
 
            giftRec = TestDataFactory.createGift(1)[0];
            giftRec.Gift_Code__c = 'GiftCode1234567890';
            insert giftRec;
            
            oligift = new Order_Line_Item_Gift__c();
            oligift.Order_Line_Item__c = orderline.id;
            oligift.Promotion_Gift__c = promogift.id;
            oligift.Redemption_Date__c = date.today();
            oligift.Redemption_Quantity__c = 1;
            oligift.Gift_ID__c = giftRec.id;
            insert oligift;
            
            glb = new Gift_Letter_Batch__c();
            glb.Promotion__c = promo.id;
            glb.Gift__c = giftRec.id;
            glb.Redemption_Start_Date__c = date.today();
            glb.Start_Date__c = date.today().addDays(1);
            glb.End_Date__c = date.today().addDays(2);
            glb.Redemption_End_Date__c = date.today().addDays(1);
            insert glb;
            
            LPIPPController lpipps = new LPIPPController();
            lpipps.recipientContact = con;
            //lpipps.zuoSub = subs;
            //lpipps.zuoSubDel = subs;
            //lpipps.delSubscription = subs;
            lpipps.countryName = 'testcountryname';
            lpipps.contractPeriod = 12345;
  
            Test.startTest();
            ApexPages.CurrentPage().getParameters().put('giftLetterBatchId', glb.id);
            ApexPages.CurrentPage().getParameters().put('Id', oligift.id);
            LPIPPController lpipp = new LPIPPController();
            lpipp.populateLPPTemplate();
            lpipp.barcode = 'test';
            lpipp.address1 = 'Address1';
            lpipp.address2 = 'Address2';
            lpipp.address3 = 'Address3';
            lpipp.address4 = 'Address4';
            lpipp.address5 = 'Address5';
            Test.stopTest();
          }
    } 
    
}