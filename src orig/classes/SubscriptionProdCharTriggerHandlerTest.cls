/**
* Class Name: <SubsProductChargeTriggerHandlerTest>
* @author: 
* Date: 
* Requirement/Project Name: <SPH>
* @description<Test Class for SubscriptionProductChargeTriggerHandlerTest>
*/

@isTest
private class SubscriptionProdCharTriggerHandlerTest{
    @testSetup 
    static void setupData() {
        //insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
    }  
    
    
    /*
    //@Description: tests if updating the zuora subscription will trigger methods
    //              before and after trigger update is set to FALSE.
    //@Parameters: none
    //@Return type: none
    static testMethod void testSingleInsertUpdate(){
    
         test.startTest(); 
    
        Zuora__Subscription__c sobj = new Zuora__Subscription__c();
        Zuora__Subscription__c sobj2 = new Zuora__Subscription__c();        
        
        //SubscriptionProductChargeTriggerHandler subhandler = new SubscriptionProductChargeTriggerHandler();
        //subhandler.beforeDelete(sobj);
        //SubscriptionProductChargeTriggerHandler subhandler2 = new SubscriptionProductChargeTriggerHandler();
        //subhandler.afterDelete(sobj2);
        //SubscriptionProductChargeTriggerHandler.isBeforeDeleteTriggerCalled = FALSE;
        //SubscriptionProductChargeTriggerHandler.isAfterDeleteTriggerCalled = FALSE;

        //The test will run as the user created.
        Id profileID = (Id) ConstantsSLB.getKeyId('Profile_Standard User');
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='subtrig1@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(u) {
            
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
            
            Account acct = new Account();
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.NRIC__c = 'T1234567R';
            insert acct;
            
            Account acctVendor = new Account();
            acctVendor = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            insert acctVendor;
            
            Account acct2 = new Account();
            acct2 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct2.NRIC__c = 'T1234567R';
            insert acct2;
            
            Contact con = new Contact();
            con = TestDataFactory.createContact(1)[0];
            con.AccountId = acct.Id;
            con.Address__c = address.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acct.Id;
            order.Recipient_Contact__c = con.Id;
            order.Informed_Customer__c = True;
            order.Subscriber_Charge__c = 100;
            insert order;
            
            //create case
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            insert cas;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.today() + 1;
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
            orderline.Fee_Override__c = FALSE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Main_Package_Billing_Type__c = 'Full Prepaid';
            orderline.Delivered_By__c = 'Vendor';
            insert orderline;

             //create subscription vendor
            Subscription_Vendor__c SubVend = TestDataFactory.createSubscriptionVendor(1)[0];
            insert SubVend;
                       
            Case caseRec = new Case();
            caseRec.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            caseRec.Status = 'Pending';
            caseRec.Sub_Status__c = 'Wating for Vendor Assignment';               
            insert caseRec;  
            
           Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
           zua.Zuora__Account__c = acct.Id;
           zua.Zuora__PaymentMethodType__c = 'Paypal';
           zua.Zuora__DefaultPaymentMethod__c = 'Other'; 
           insert zua;
            
            Zuora__Subscription__c subRec = new Zuora__Subscription__c();
            subRec = TestDataFactory.createSubscription(1)[0];
            subRec.Zuora__Account__c = acct.Id;
            subRec.Order_Number__c = order.Id;
            subRec.Subscriber_Contact__c = con.Id;
            subRec.Recipient_Contact__c = con.Id;
            subRec.Main_Package_1__c = pack.id;
            subRec.Zuora__CustomerAccount__c = zua.id;
            subRec.Zuora__Status__c = 'Active';
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Charity__c = 'false';
            subRec.Order_Line_Item_Number__c = orderline.Id;
            subrec.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
            subRec.Vendor_1__c = acctVendor.id; 
            subRec.Delivery_Charge__c = 100;
            subRec.Term_Length__c = 30;     
              
            insert subRec; 
            
            Case_Subscription__c  caseSub = new Case_Subscription__c();
            caseSub.Account__c = acct.Id;
            caseSub.Address__c = address.Id;
            caseSub.Case__c = caseRec.Id;
            caseSub.Subscription__c = subRec.Id;
            insert caseSub;   
            
            subRec.Zuora__Status__c = 'Active'; 
            
            //update            
            SubscriptionProductChargeTriggerHandler.isBeforeUpdateTriggerCalled = false;
            SubscriptionProductChargeTriggerHandler.isAfterUpdateTriggerCalled = false;   
            subRec.Vendor__c = acctVendor.Id+'';
            update subRec;   
            
            //create subscription product charge
            Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
            database.insert(spc);
        
            SubscriptionProductChargeTriggerHandler spcth = new SubscriptionProductChargeTriggerHandler();
            spcth.runBeforeInsertTrigger();
            spcth.runBeforeUpdateTrigger();
            spcth.updateProdutCode(spc);
            
            test.stoptest();
        }
    }

    //@Description: tests if deleting the zuora subscription will trigger methods
    //              before and after trigger update is set to FALSE.
    //@Parameters: none
    //@Return type: none
    static testMethod void testSingleDelete(){ 
        //The test will run as the user created.
        Id profileID = (Id) ConstantsSLB.getKeyId('Profile_Standard User');
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='subtrig2@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(u) {
            
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
            
            Account acct = new Account();
            acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.NRIC__c = 'T1234567R';
            insert acct;
            
            Contact con = new Contact();
            con = TestDataFactory.createContact(1)[0];
            con.AccountId = acct.Id;
            con.Address__c = address.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acct.Id;
            order.Recipient_Contact__c = con.Id;
            order.Informed_Customer__c = True;
            order.Subscriber_Charge__c = 100;
            insert order;
            
            //create case
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            cas.AccountId =  acct.Id;
            cas.Sub_Category__c = 'Stop Subscription';
            insert cas;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.today() + 1;
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
            orderline.Fee_Override__c = FALSE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Subscription_Name__c = 'TestSubName';
            orderline.Case__c = cas.Id;
            orderline.Main_Package_Billing_Type__c = 'Full Prepaid';
            orderline.Delivered_By__c = 'Vendor';
            insert orderline;
            
            System.assertEquals(order.Id, orderline.Order__c);        
        
           Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
           zua.Zuora__Account__c = acct.Id;
           zua.Zuora__PaymentMethodType__c = 'Paypal';
           zua.Zuora__DefaultPaymentMethod__c = 'Other'; 
           insert zua;
            
            Zuora__Subscription__c subRec = new Zuora__Subscription__c();
            subRec = TestDataFactory.createSubscription(1)[0];
            subRec.Zuora__Account__c = acct.Id;
            subRec.Zuora__CustomerAccount__c = zua.id;
            subRec.Order_Number__c = order.Id;
            subRec.Subscriber_Contact__c = con.Id;
            subRec.Recipient_Contact__c = con.Id;
            subRec.Main_Package_1__c = pack.id;
            subRec.Zuora__Status__c = 'Active';
            subRec.Suppress_Vendor_Start_Notice__c = 'false';
            subRec.Supressed_Acknowledgement_Letter__c = 'false';
            subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRec.Urgent__c = 'false';
            subRec.Vendor_Conversion__c = 'false';
            subRec.Charity__c = 'false';
            subRec.Order_Line_Item_Number__c = orderline.Id;
            subRec.Zuora__Status__c = 'Cancelled';
            subRec.Name = 'TestSubName';
            subRec.Delivery_Charge__c = 100;
            subRec.Term_Length__c = 30; 
            
            SubscriptionProductChargeTriggerHandler.isBeforeInsertTriggerCalled = false;
            SubscriptionProductChargeTriggerHandler.isAfterInsertTriggerCalled = false;
     
            
             
            test.startTest();  
            
            insert subRec;
            
            //delete
            SubscriptionProductChargeTriggerHandler.isBeforeDeleteTriggerCalled = false;
            SubscriptionProductChargeTriggerHandler.isAfterDeleteTriggerCalled = false;
            //delete subRec;                
        test.stoptest();    
        }
        //SubscriptionProductChargeTriggerHandler spcth = new SubscriptionProductChargeTriggerHandler();
        //spcth.runBeforeDeleteTrigger();
        //spcth.runAfterInsertTrigger();
        //spcth.runAfterUpdateTrigger();
        //spcth.runAfterDeleteTrigger();
        //spcth.runBeforeInsertTrigger();
        //spcth.runBeforeUpdateTrigger();
    }
    */
    
    static testMethod void testSubscriptionProductChargeTriggerHandler02_insert() {
    // Account 
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
    // Customer Account
        List<Zuora__CustomerAccount__c> zcas = TestDataFactory.createBillingAccount(1);
        zcas[0].Zuora__Account__c = acc.id;
        insert zcas;
      
    // Subscription  
        List<Zuora__Subscription__c> zss = TestDataFactory.createSubscription(1);
        zss[0].Zuora__CustomerAccount__c = zcas[0].id;
        insert zss;
        
    // Add SKU Product       
        //zqu__ZProduct__c
        List<zqu__ZProduct__c> zqu_zps = TestDataFactory.createZProduct(1);
        zqu_zps[0].zqu__ZuoraId__c = 'ZuoraId1';
        insert zqu_zps;
        
    // zqu__ProductRatePlan__c
        List<zqu__ProductRatePlan__c> sprps = TestDataFactory.createProductRatePlan(1);
        sprps[0].zqu__ZProduct__c = zqu_zps[0].id;
        insert sprps;
        
        
    // zqu__ProductRatePlanCharge__c
        List<zqu__ProductRatePlanCharge__c> zqu_prpcs = TestDataFactory.createProductRatePlanCharge(1);
        zqu_prpcs[0].zqu__ProductRatePlan__c = sprps[0].id;
        insert zqu_prpcs;
    
    // Test Class     
        List<Zuora__SubscriptionProductCharge__c> zspcs = TestDataFactory.createSubProductCharge(200);        
        Integer count=0;
        for(Zuora__SubscriptionProductCharge__c zspc : zspcs) {
            zspc.Zuora__ProductSKU__c = zqu_zps[0].zqu__SKU__c;
            zspc.Zuora__Subscription__c = zss[0].id;
            zspc.Zuora__RatePlanName__c = sprps[0].name;
        }
        
        Test.startTest();
        insert zspcs;
        Test.stopTest();
        
        System.assertEquals(zspcs[0].Zuora__ProductSKU__c, zqu_zps[0].zqu__SKU__c);
        System.assertEquals(zspcs[0].Zuora__RatePlanName__c, sprps[0].name);
    }
    
    static testMethod void testSubscriptionProductChargeTriggerHandler03_update() {
    // Account 
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
    // Customer Account
        List<Zuora__CustomerAccount__c> zcas = TestDataFactory.createBillingAccount(1);
        zcas[0].Zuora__Account__c = acc.id;
        insert zcas;
      
    // Subscription  
        List<Zuora__Subscription__c> zss = TestDataFactory.createSubscription(1);
        zss[0].Zuora__CustomerAccount__c = zcas[0].id;
        //zss[0]. = 'Subscription';
        insert zss;
        
    // Add SKU Product       
        //zqu__ZProduct__c
        List<zqu__ZProduct__c> zqu_zps = TestDataFactory.createZProduct(1);
        zqu_zps[0].zqu__ZuoraId__c = 'ZuoraId1';
        insert zqu_zps;
        
    // zqu__ProductRatePlan__c
        List<zqu__ProductRatePlan__c> sprps = TestDataFactory.createProductRatePlan(1);
        sprps[0].zqu__ZProduct__c = zqu_zps[0].id;
        insert sprps;
        
        
    // zqu__ProductRatePlanCharge__c
        List<zqu__ProductRatePlanCharge__c> zqu_prpcs = TestDataFactory.createProductRatePlanCharge(1);
        zqu_prpcs[0].zqu__ProductRatePlan__c = sprps[0].id;
        zqu_prpcs[0].PublicationCode__c = 'ST';
        insert zqu_prpcs;
    
    // Test Class     
        List<Zuora__SubscriptionProductCharge__c> zspcs = TestDataFactory.createSubProductCharge(200);
        Integer count=0;
        for(Zuora__SubscriptionProductCharge__c zspc : zspcs) {
            zspc.Name = zqu_prpcs[0].name;
            zspc.Zuora__ProductSKU__c = zqu_zps[0].zqu__SKU__c;
            zspc.Zuora__Subscription__c = zss[0].id;
            zspc.Zuora__RatePlanName__c = sprps[0].name;
        }
        
        Test.startTest();
        insert zspcs;
        zspcs[0].Zuora__RatePlanName__c = 'NewRatePlanName';
        update zspcs;
        Test.stopTest();
        
        Zuora__SubscriptionProductCharge__c actual = [SELECT id,Zuora__RatePlanName__c FROM Zuora__SubscriptionProductCharge__c WHERE id =:zspcs[0].id];
        System.assertEquals('NewRatePlanName', actual.Zuora__RatePlanName__c);
    }
    
    static testMethod void testSubscriptionProductChargeTriggerHandler04_update() {
    // Account 
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
    // Customer Account
        List<Zuora__CustomerAccount__c> zcas = TestDataFactory.createBillingAccount(1);
        zcas[0].Zuora__Account__c = acc.id;
        insert zcas;
      
    // Subscription  
        List<Zuora__Subscription__c> zss = TestDataFactory.createSubscription(1);
        zss[0].Zuora__CustomerAccount__c = zcas[0].id;
        insert zss;
        
    // Add SKU Product       
        List<zqu__ZProduct__c> zqu_zps = TestDataFactory.createZProduct(1);
        zqu_zps[0].zqu__ZuoraId__c = 'ZuoraId1';
        insert zqu_zps;
        
    // zqu__ProductRatePlan__c
        List<zqu__ProductRatePlan__c> sprps = TestDataFactory.createProductRatePlan(1);
        sprps[0].zqu__ZProduct__c = zqu_zps[0].id;
        insert sprps;
        
        
    // zqu__ProductRatePlanCharge__c
        List<zqu__ProductRatePlanCharge__c> zqu_prpcs = TestDataFactory.createProductRatePlanCharge(1);
        zqu_prpcs[0].zqu__ProductRatePlan__c = sprps[0].id;
        zqu_prpcs[0].PublicationCode__c = 'ST';
        insert zqu_prpcs;
    
    // Test Class     
        List<Zuora__SubscriptionProductCharge__c> zspcs = TestDataFactory.createSubProductCharge(1);
        Integer count=0;
        for(Zuora__SubscriptionProductCharge__c zspc : zspcs) {
            zspc.Name = zqu_prpcs[0].name;
            zspc.Zuora__ProductSKU__c = zqu_zps[0].zqu__SKU__c;
            zspc.Zuora__Subscription__c = zss[0].id;
            zspc.Zuora__RatePlanName__c = sprps[0].name;
            zspc.Zuora__Model__c = GlobalVariableClass.SPC_MODEL_DISCOUNT;
        }
        
        Test.startTest();
        insert zspcs;
        update zspcs;
        Test.stopTest();
    }
    
    static testMethod void testSubscriptionProductChargeTriggerHandler05_update() {
    // Account 
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
    // Customer Account
        List<Zuora__CustomerAccount__c> zcas = TestDataFactory.createBillingAccount(1);
        zcas[0].Zuora__Account__c = acc.id;
        insert zcas;
      
    // Subscription  
        List<Zuora__Subscription__c> zss = TestDataFactory.createSubscription(1);
        zss[0].Zuora__CustomerAccount__c = zcas[0].id;
        insert zss;
        
    // Add SKU Product       
        //zqu__ZProduct__c
        List<zqu__ZProduct__c> zqu_zps = TestDataFactory.createZProduct(1);
        zqu_zps[0].zqu__ZuoraId__c = 'ZuoraId1';
        zqu_zps[0].ProductCode__c = GlobalVariableClass.PRODUCT_CODE_PRMGFT;
        insert zqu_zps;
        
    // zqu__ProductRatePlan__c
        List<zqu__ProductRatePlan__c> sprps = TestDataFactory.createProductRatePlan(1);
        sprps[0].zqu__ZProduct__c = zqu_zps[0].id;
        insert sprps;
        
    // zqu__ProductRatePlanCharge__c
        List<zqu__ProductRatePlanCharge__c> zqu_prpcs = TestDataFactory.createProductRatePlanCharge(1);
        zqu_prpcs[0].zqu__ProductRatePlan__c = sprps[0].id;
        zqu_prpcs[0].PublicationCode__c = 'ST';
        insert zqu_prpcs;
    
    // Test Class     
        List<Zuora__SubscriptionProductCharge__c> zspcs = TestDataFactory.createSubProductCharge(1);
        Integer count=0;
        for(Zuora__SubscriptionProductCharge__c zspc : zspcs) {
            zspc.Name = zqu_prpcs[0].name;
            zspc.Zuora__ProductSKU__c = zqu_zps[0].zqu__SKU__c;
            zspc.Zuora__Subscription__c = zss[0].id;
            zspc.Zuora__RatePlanName__c = sprps[0].name;
            zspc.Product_Code__c = GlobalVariableClass.PRODUCT_CODE_PRMGFT;
            zspc.Zuora__Price__c = 10;
            zspc.Zuora__Quantity__c = 10;
        }
        
        Test.startTest();
        insert zspcs;
        update zspcs;
        Test.stopTest();
    }
    
    static testMethod void testSubscriptionProductChargeTriggerHandler06_update() {
    // Account 
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
    // Customer Account
        List<Zuora__CustomerAccount__c> zcas = TestDataFactory.createBillingAccount(1);
        zcas[0].Zuora__Account__c = acc.id;
        insert zcas;
      
    // Subscription  
        List<Zuora__Subscription__c> zss = TestDataFactory.createSubscription(1);
        zss[0].Zuora__CustomerAccount__c = zcas[0].id;
        zss[0].Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
        insert zss;
        
    // Add SKU Product       
        List<zqu__ZProduct__c> zqu_zps = TestDataFactory.createZProduct(1);
        zqu_zps[0].zqu__ZuoraId__c = 'ZuoraId1';
        zqu_zps[0].ProductCode__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
        insert zqu_zps;
        
    // zqu__ProductRatePlan__c
        List<zqu__ProductRatePlan__c> sprps = TestDataFactory.createProductRatePlan(1);
        sprps[0].zqu__ZProduct__c = zqu_zps[0].id;
        insert sprps;
        
    // zqu__ProductRatePlanCharge__c
        List<zqu__ProductRatePlanCharge__c> zqu_prpcs = TestDataFactory.createProductRatePlanCharge(1);
        zqu_prpcs[0].zqu__ProductRatePlan__c = sprps[0].id;
        zqu_prpcs[0].PublicationCode__c = 'ST';
        insert zqu_prpcs;
    
    // Test Class     
        List<Zuora__SubscriptionProductCharge__c> zspcs = TestDataFactory.createSubProductCharge(1);
        Integer count=0;
        for(Zuora__SubscriptionProductCharge__c zspc : zspcs) {
            zspc.Name = zqu_prpcs[0].name;
            zspc.Zuora__ProductSKU__c = zqu_zps[0].zqu__SKU__c;
            zspc.Zuora__Subscription__c = zss[0].id;
            zspc.Zuora__RatePlanName__c = sprps[0].name;
            zspc.Product_Code__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
            zspc.Zuora__Price__c = 10;
        }
        
        Test.startTest();
        insert zspcs;
        update zspcs;
        Test.stopTest();
    }
    
    static testMethod void testSubscriptionProductChargeTriggerHandler07_delete() {
    // Account 
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
    // Customer Account
        List<Zuora__CustomerAccount__c> zcas = TestDataFactory.createBillingAccount(1);
        zcas[0].Zuora__Account__c = acc.id;
        insert zcas;
      
    // Subscription  
        List<Zuora__Subscription__c> zss = TestDataFactory.createSubscription(1);
        zss[0].Zuora__CustomerAccount__c = zcas[0].id;
        insert zss;
        
    // Add SKU Product       
        //zqu__ZProduct__c
        List<zqu__ZProduct__c> zqu_zps = TestDataFactory.createZProduct(1);
        zqu_zps[0].zqu__ZuoraId__c = 'ZuoraId1';
        insert zqu_zps;
        
    // zqu__ProductRatePlan__c
        List<zqu__ProductRatePlan__c> sprps = TestDataFactory.createProductRatePlan(1);
        sprps[0].zqu__ZProduct__c = zqu_zps[0].id;
        insert sprps;
        
        
    // zqu__ProductRatePlanCharge__c
        List<zqu__ProductRatePlanCharge__c> zqu_prpcs = TestDataFactory.createProductRatePlanCharge(1);
        zqu_prpcs[0].zqu__ProductRatePlan__c = sprps[0].id;
        zqu_prpcs[0].PublicationCode__c = 'ST';
        insert zqu_prpcs;
    
    // Test Class     
        List<Zuora__SubscriptionProductCharge__c> zspcs = TestDataFactory.createSubProductCharge(1);
        Integer count=0;
        for(Zuora__SubscriptionProductCharge__c zspc : zspcs) {
            zspc.Name = zqu_prpcs[0].name;
            zspc.Zuora__ProductSKU__c = zqu_zps[0].zqu__SKU__c;
            zspc.Zuora__Subscription__c = zss[0].id;
            zspc.Zuora__RatePlanName__c = sprps[0].name;
            zspc.Product_Code__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
            zspc.Zuora__Price__c = 10;
        }
        
        Test.startTest();
        insert zspcs;
        Id toDeleteId = zspcs[0].id;
        delete zspcs;
        Test.stopTest();
        
        //Map<ID,Zuora__SubscriptionProductCharge__c> actual = new Map<ID,Zuora__SubscriptionProductCharge__c>([SELECT id,Name FROM Zuora__SubscriptionProductCharge__c WHERE Id != :toDeleteId]); //CHA 22April2016
        //System.assertEquals(FALSE, actual.containsKey(toDeleteId));
        
    }
    
    static testMethod void testSubscriptionProductChargeTriggerHandler08_run() {
        SubscriptionProductChargeTriggerHandler testObj = new SubscriptionProductChargeTriggerHandler();
        
        System.assert(testObj.runBeforeInsertTrigger(), 'ERROR');
        System.assert(testObj.runBeforeUpdateTrigger(), 'ERROR');
        System.assert(testObj.runBeforeDeleteTrigger(), 'ERROR');
        System.assert(testObj.runAfterInsertTrigger(), 'ERROR');
        System.assert(testObj.runAfterUpdateTrigger(), 'ERROR');
        System.assert(testObj.runAfterDeleteTrigger(), 'ERROR');
    }
        
}