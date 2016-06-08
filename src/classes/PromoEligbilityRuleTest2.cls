@isTest (SeeAllData=FALSE)
private class PromoEligbilityRuleTest2 {

    
    static void setCustomSettings() {
    
        //Cir_Planner_Schedule__c
        List<Cir_Planner_Schedule__c> cpsList = new List<Cir_Planner_Schedule__c>{
            new Cir_Planner_Schedule__c(Name='CIR Plan Schedule', Mon_Fri_End_Time__c=Date.today(),
                Mon_Fri_Start_Time__c=Date.today(),Sat_PH_End_Time__c=Date.today(),Sat_PH_Start_Time__c=Date.today(),
                Sun_End_Time__c=Date.today(),Sun_Start_Time__c=Date.today())
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
        /*
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
        */
        //Batch_Configuration_Settings__c.getInstance('SP_VendorNotificationsBatch');
        List<Batch_Configuration_Settings__c> bcsList = new List<Batch_Configuration_Settings__c>{
            new Batch_Configuration_Settings__c(Name='SP_VendorNotificationsBatch', Batch_Size__c=10, 
                Max_Retries__c=10, Notification_Recipients__c='', Number_Of_Days_To_Retrieve__c=30)
        };
        Database.insert(bcsList);
        
        //Other__c
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'),
            
            new Other__c(Name='Zero Charge Amount',     Value__c='Zero'),
            new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB'),
            new Other__c(Name='APT DELIVERY CHARGE',    Value__c='APT'),
            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='LANDED')
        };        
        Database.insert(otherList);
        
        //Delivery_Charge_Type__c
        List<Delivery_Charge_Type__c> delCharTypeList = new List<Delivery_Charge_Type__c>{
            new Delivery_Charge_Type__c(Name='H', Default_Delivery_Charge_Type__c='H'),
            new Delivery_Charge_Type__c(Name='L', Default_Delivery_Charge_Type__c='L'),
            new Delivery_Charge_Type__c(Name='C', Default_Delivery_Charge_Type__c='C')
        };
        Database.insert(delCharTypeList);
    }
    
    
    static testMethod void testGetEligibility_VendorCustomer01() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
        
            setCustomSettings();
            
            //Singpost_Address__c
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            Database.insert(postal);
    
            //Create Parent Account
            Account accParent = TestDataFactory.createAccount(1, 'Vendor')[0];
            Database.insert(accParent);
            
            //Create account
            List<Account> accList = TestDataFactory.createAccount(4, 'Vendor');
            accList[0]          = TestDataFactory.createAccount(1, 'Vendor')[0];
            accList[0].Name     = 'TEST1';
            accList[0].NRIC__c  = 'T1234567R';
            accList[0].ParentId = accParent.Id;
            
            accList[1]          = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[1].Name     = 'TEST2';
            accList[1].NRIC__c  = 'T1234567S';
            accList[1].ParentId = accParent.Id;
            
            accList[2]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[2].Name    = 'TEST3';
            accList[2].NRIC__c = 'T1234567T';
            accList[2].ParentId = accParent.Id;
            
            accList[3]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[3].Name    = 'TEST4';
            accList[3].NRIC__c = 'T1234567U';
            accList[3].ParentId = accParent.Id;
            
            Database.insert(accList);
            
           
            
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c             = addressRec.Id;
            con.AccountId              = accList[0].Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            //Create promo
            List<Promotion__c> promoList = TestDataFactory.createPromoList(3);
            for(Promotion__c promo : promoList) {
                promo.Effective_Start_Date__c    = Date.today();
                promo.Effective_End_Date__c      = Date.today().addDays(30);
                promo.Contract__c                = 'Yes';
                promo.Contract_Period__c         = '2';
                promo.Penalty_Charge__c          = '100';
                promo.Penalty_Charge_Override__c = 500.00;  
            }   
            promoList[0].Promotion_Code__c = 'yasyd97';
            promoList[1].Promotion_Code__c = 'yasyd97';
            promoList[2].Promotion_Code__c = 'yasyd99';
            Database.insert(promoList);
            
            //Create package
            List<Package__c> packList = TestDataFactory.createPackage(1);
            for(Package__c pack : packList) {
                pack.Package_Type__c                   = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
                pack.Billing_Type__c                   = 'Full Prepaid';
                pack.Package_Code__c                   = 'tempCode0';      
                pack.Product_Family_Current_Package__c = 'tmp0'; 
                pack.Effective_End_Date__c             = date.today().addDays(31);
                pack.Effective_Start_Date__c           = date.today();
                pack.Subscription_Period__c            = '1';
            }
            Database.insert(packList);
            
            //Create promotion package
            List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(4);
            promotionPackageList[0].Promotion__c    = promoList[0].Id;
            promotionPackageList[0].Package_Name__c = packList[0].Id;
            promotionPackageList[1].Promotion__c    = promoList[1].Id;
            promotionPackageList[1].Package_Name__c = packList[0].Id;
            promotionPackageList[2].Promotion__c    = promoList[2].Id;
            promotionPackageList[2].Package_Name__c = packList[0].Id;
            promotionPackageList[3].Promotion__c    = promoList[0].Id;
            promotionPackageList[3].Package_Name__c = packList[0].Id;
            Database.insert(promotionPackageList);
            
            //create product family      
            List<Product_Family__c> pfList = TestDataFactory.createProductFamily(1);
            Database.insert(pfList);
            
            //create eligibility rule
            List<Eligibility_Rule__c> erList = TestDataFactory.createEligibilityRule(5);
            for(Eligibility_Rule__c er : erList) {
                er.Product_Family__c       = pfList[0].Id;
                er.Effective_Start_Date__c = Date.today();
                er.Effective_End_Date__c   = Date.today().addDays(30);
            }    
            erList[0].Customer_Status__c   = 'Vendor Customer';
            //erList[0].Contract_Status__c   = 'With Contract';
            erList[0].Action__c            = 'Add';
            
            erList[1].Customer_Status__c   = 'Vendor Customer';
            //erList[1].Contract_Status__c   = 'With Contract';
            erList[1].Action__c            = 'Add';
                
            erList[2].Customer_Status__c   = 'Vendor Customer';
            //erList[2].Contract_Status__c   = 'With Contract';
            erList[2].Action__c            = 'Add';
            
            erList[3].Customer_Status__c   = 'Vendor Customer';
            //erList[3].Contract_Status__c   = 'With Contract';
            erList[3].Action__c            = 'Add';  
            
            erList[4].Customer_Status__c   = 'Vendor Customer';
            //erList[4].Contract_Status__c   = 'With Contract';
            erList[4].Action__c            = 'Add'; 
            Database.insert(erList);
            
            
            //create promotion eligibility rule
            List<Promotion_Eligibility_Rule__c> perList = TestDataFactory.createPromEligibilityRule(6);
            for(Promotion_Eligibility_Rule__c per : perList) {
                per.Product_Family__c = 'TM';
                per.Package_List__c   = 'tempCode0';
                per.Prod_Family__c    = pfList[0].Id; 
                per.Date__c           = Date.today();
            }
            perList[0].Promotion__c        = promoList[0].Id;
            perList[0].Eligibility_Rule__c = erList[0].Id;
            perList[1].Promotion__c        = promoList[1].Id;
            perList[1].Eligibility_Rule__c = erList[1].Id;
            perList[2].Promotion__c        = promoList[0].Id;
            perList[2].Eligibility_Rule__c = erList[2].Id;
            perList[3].Promotion__c        = promoList[1].Id;
            perList[3].Eligibility_Rule__c = erList[3].Id;
            perList[4].Promotion__c        = promoList[0].Id;
            perList[4].Eligibility_Rule__c = erList[4].Id;
            perList[5].Promotion__c        = promoList[1].Id;
            perList[5].Eligibility_Rule__c = erList[1].Id;
            Database.insert(perList);
        
        
            //create promo eligibility rule product family
            List<Promo_Eligibility_Rule_Product_Family__c> perpfList = TestDataFactory.createPromoEligRuleProdFamily(1);
            perpfList[0].Product_Family__c             = pfList[0].Id;
            perpfList[0].Promotion_Eligibility_Rule__c = perList[0].Id;
            Database.insert(perpfList);
           
           
        //Billing Account
            //Create zoura customer account
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc[0].Zuora__Account__c              = accList[0].Id;
            billAcc[0].Billing_Type__c                = 'Full Prepaid';
            billAcc[0].Zuora__Credit_Balance__c       = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            Database.insert(billAcc);
            
        
            //Create order
            List<Order__c> odr = TestDataFactory.createOrder(1);
            odr[0].Account__c         = accList[0].Id;
    //      odr[0].Billing_Account__c = billAcc[0].Id;
            odr[0].Billing_Type__c    = 'Full Prepaid';
            Database.insert(odr);
        
        
            //Create zuora subscription 
            List<Zuora__Subscription__c> zSubList = TestDataFactory.createSubscription(6);
            for(Zuora__Subscription__c zSub: zSubList){
                zSub.Zuora__Account__c               = accList[0].id;
                zSub.Promotion_1__c                  = promoList[0].id;
                zSub.Zuora__CustomerAccount__c       = billAcc[0].Id;
                zSub.Order_Number__c                 = odr[0].id;
                zSub.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
                zSub.Zuora__SubscriptionEndDate__c   = Date.today().addDays(90);
                //zSub.Contract_End_Date_1__c        = Date.today().addDays(90);
                zSub.Contract_End_Date__c            = ''+Date.today().addDays(90);
                zSub.Zuora__Status__c                = 'Active';
                zSub.Main_Package__c                 = packList[0].id;
            }
            
            zSubList[1].Promotion_1__c  = promoList[1].id;
            zSubList[1].Main_Package__c = packList[0].id;
            
            zSubList[2].Promotion_1__c  = promoList[2].id;
            zSubList[2].Main_Package__c = packList[0].id;
            
            zSubList[3].Promotion_1__c  = promoList[0].id;
                        
            zSubList[4].Promotion_1__c  = promoList[1].id;
            zSubList[4].Main_Package__c = packList[0].id;
                        
            zSubList[5].Promotion_1__c  = promoList[2].id;
                
            Database.insert(zSubList);
            
               
               
            //Create zuora subscription product charge
            List<Zuora__SubscriptionProductCharge__c> zSubProChargeList = TestDataFactory.createSubscriptionProductCharge(1);
            for(Zuora__SubscriptionProductCharge__c zSubProCharge : zSubProChargeList) {
                zSubProCharge.Zuora__Account__c       = accList[0].id;
                zSubProCharge.Zuora__Subscription__c  = zSubList[0].Id;
                zSubProCharge.Zuora__ProductSKU__c    = 'temp';
                zSubProCharge.Zuora__RatePlanName__c  = 'temp';
                zSubProCharge.Zuora__ProductName__c   = 'temp';
                zSubProCharge.Zuora__Quantity__c      = 15.3;
                zSubProCharge.Product_Code__c         = 'churva';
                zSubProCharge.Zuora__Price__c         = 100.00;
                zSubProCharge.Zuora__BillingPeriod__c = 'First';
            }
            Database.insert(zSubProChargeList); 
            
        
            //Create zuora zProduct
            List<zqu__ZProduct__c> zProductList = TestDataFactory.createZProduct(1);
            for(zqu__ZProduct__c zProduct : zProductList) {
                zProduct.ProductCode__c = 'churva';
                zProduct.zqu__SKU__c    = zSubProChargeList[0].Zuora__ProductSKU__c;
            }
            Database.insert(zProductList);
        
        
            //Create product rate plan
            List<zqu__ProductRatePlan__c> productRatePlanList = TestDataFactory.createProductRatePlan(1);
            for(zqu__ProductRatePlan__c productRatePlan : productRatePlanList) {
                productRatePlan.Name             = zSubProChargeList[0].Zuora__RatePlanName__c;
                productRatePlan.zqu__ZProduct__c = zProductList[0].Id;
            }
            Database.insert(productRatePlanList);
            
            //Publication
            List<Publication__c> publicationList = TestDataFactory.createPublication(1);
            publicationList[0].Product_Family_Lookup__c = pfList[0].Id;
            Database.insert(publicationList);
            
        
            //FROM Subscription_Vendor__c WHERE Account__c =: acct.Parent.Id AND Status__c = 'Active'
            //Subscription_Vendor__c 
            List<Subscription_Vendor__c> subsVendorList = TestDataFactory.createSubscriptionVendor(1);
            for(Subscription_Vendor__c subsVendor : subsVendorList) {
                subsVendor.Account__c = accParent.id;
                subsVendor.Status__c = 'Active';
            }
            Database.insert(subsVendorList);
        
            //Subscription_Vendor_Publications__c
            List<Subscription_Vendor_Publication__c> subsVendorPubList = new List<Subscription_Vendor_Publication__c>();
            subsVendorPubList.add(new Subscription_Vendor_Publication__c());
            for(Subscription_Vendor_Publication__c subsVendorPub : subsVendorPubList) {
                subsVendorPub.Publication__c         = publicationList[0].id;
                subsVendorPub.Subscription_Vendor__c = subsVendorList[0].id;
            }
            Database.insert(subsVendorPubList);
            
            
            
            //Promo_Eligibility_Rule_Product_Family__c
            List<Promo_Eligibility_Rule_Product_Family__c> promoEligRuleProdFamList = new List<Promo_Eligibility_Rule_Product_Family__c>();
            Promo_Eligibility_Rule_Product_Family__c promoEligRuleProdFam1 = new Promo_Eligibility_Rule_Product_Family__c();
            promoEligRuleProdFam1.Product_Family__c             = pfList[0].id;
            promoEligRuleProdFam1.Promotion_Eligibility_Rule__c = perList[0].id;
            promoEligRuleProdFamList.add(promoEligRuleProdFam1);
            Database.insert(promoEligRuleProdFamList);
            
            //FROM Zuora__Subscriptions__r
            //FROM Account
            //FROM Subscription_Vendor__c
            //FROM Promotion__c
            //FROM Zuora__Subscription__c
            //FROM Zuora__SubscriptionProductCharge__c
            //FROM zqu__ProductRatePlan__c
            //FROM Promotion_Package__c
            //from Promo_Eligibility_Rule_Product_Families__r
            //FROM Promotion_Eligibility_Rule__c 
            
        
            //Setup Parameters
            Id accId = accList[0].id;
            String action = 'Add';
            Map<String , Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
            Set<String> contractPeriod1 = new Set<String>();
            contractPeriod1.add(promoList[0].Contract_Period__c);
            contractPeriod1.add(promoList[1].Contract_Period__c);   
            contractPeriod1.add(promoList[2].Contract_Period__c);          
            promoCodeContractSet.put(promoList[0].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[1].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[2].Promotion_Code__c, contractPeriod1);
            
            String pkgCode = '';
            Id subsId = zSubList[0].id;
            Boolean booleanVar = True;
            
            Test.startTest();
            PromoEligibilityRule testObj = new PromoEligibilityRule();
            //public Map<String, Set<String>> result
            testObj.getEligibility(accId, action, promoCodeContractSet, pkgCode, subsId, booleanVar);  
            Test.stopTest();
        }
    
    }
    
    
    static testMethod void testGetEligibility_NewCustomer01() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
        
            setCustomSettings();
            
            //Singpost_Address__c
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            Database.insert(postal);
    
            //Create Parent Account
            Account accParent = TestDataFactory.createAccount(1, 'Vendor')[0];
            Database.insert(accParent);
            
            //Create account
            List<Account> accList = TestDataFactory.createAccount(4, 'Vendor');
            accList[0]          = TestDataFactory.createAccount(1, 'Vendor')[0];
            accList[0].Name     = 'TEST1';
            accList[0].NRIC__c  = 'T1234567R';
            accList[0].ParentId = accParent.Id;
            
            accList[1]          = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[1].Name     = 'TEST2';
            accList[1].NRIC__c  = 'T1234567S';
            accList[1].ParentId = accParent.Id;
            
            accList[2]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[2].Name    = 'TEST3';
            accList[2].NRIC__c = 'T1234567T';
            accList[2].ParentId = accParent.Id;
            
            accList[3]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[3].Name    = 'TEST4';
            accList[3].NRIC__c = 'T1234567U';
            accList[3].ParentId = accParent.Id;
            
            Database.insert(accList);
            
           
            
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c             = addressRec.Id;
            con.AccountId              = accList[0].Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            //Create promo
            List<Promotion__c> promoList = TestDataFactory.createPromoList(3);
            for(Promotion__c promo : promoList) {
                promo.Effective_Start_Date__c    = Date.today();
                promo.Effective_End_Date__c      = Date.today().addDays(30);
                promo.Contract__c                = 'Yes';
                promo.Contract_Period__c         = '2';
                promo.Penalty_Charge__c          = '100';
                promo.Penalty_Charge_Override__c = 500.00;  
            }   
            promoList[0].Promotion_Code__c = 'yasyd97';
            promoList[1].Promotion_Code__c = 'yasyd97';
            promoList[2].Promotion_Code__c = 'yasyd99';
            Database.insert(promoList);
            
            //Create package
            List<Package__c> packList = TestDataFactory.createPackage(1);
            for(Package__c pack : packList) {
                pack.Package_Type__c                   = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
                pack.Billing_Type__c                   = 'Full Prepaid';
                pack.Package_Code__c                   = 'tempCode0';      
                pack.Product_Family_Current_Package__c = 'tmp0'; 
                pack.Effective_End_Date__c             = date.today().addDays(31);
                pack.Effective_Start_Date__c           = date.today();
                pack.Subscription_Period__c            = '1';
            }
            Database.insert(packList);
            
            //Create promotion package
            List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(4);
            promotionPackageList[0].Promotion__c    = promoList[0].Id;
            promotionPackageList[0].Package_Name__c = packList[0].Id;
            promotionPackageList[1].Promotion__c    = promoList[1].Id;
            promotionPackageList[1].Package_Name__c = packList[0].Id;
            promotionPackageList[2].Promotion__c    = promoList[2].Id;
            promotionPackageList[2].Package_Name__c = packList[0].Id;
            promotionPackageList[3].Promotion__c    = promoList[0].Id;
            promotionPackageList[3].Package_Name__c = packList[0].Id;
            Database.insert(promotionPackageList);
            
            //create product family      
            List<Product_Family__c> pfList = TestDataFactory.createProductFamily(1);
            Database.insert(pfList);
            
            //create eligibility rule
            List<Eligibility_Rule__c> erList = TestDataFactory.createEligibilityRule(5);
            for(Eligibility_Rule__c er : erList) {
                er.Product_Family__c       = pfList[0].Id;
                er.Effective_Start_Date__c = Date.today();
                er.Effective_End_Date__c   = Date.today().addDays(30);
            }    
            erList[0].Customer_Status__c   = 'New Customer';
            //erList[0].Contract_Status__c   = 'With Contract';
            erList[0].Action__c            = 'Add';
            
            erList[1].Customer_Status__c   = 'New Customer';
            //erList[1].Contract_Status__c   = 'With Contract';
            erList[1].Action__c            = 'Add';
                
            erList[2].Customer_Status__c   = 'New Customer';
            //erList[2].Contract_Status__c   = 'With Contract';
            erList[2].Action__c            = 'Add';
            
            erList[3].Customer_Status__c   = 'New Customer';
            //erList[3].Contract_Status__c   = 'With Contract';
            erList[3].Action__c            = 'Add';  
            
            erList[4].Customer_Status__c   = 'New customer';
            //erList[4].Contract_Status__c   = 'With Contract';
            erList[4].Action__c            = 'Add'; 
            Database.insert(erList);
            
            
            //create promotion eligibility rule
            List<Promotion_Eligibility_Rule__c> perList = TestDataFactory.createPromEligibilityRule(6);
            for(Promotion_Eligibility_Rule__c per : perList) {
                per.Product_Family__c = 'TM';
                per.Package_List__c   = 'tempCode0';
                per.Prod_Family__c    = pfList[0].Id; 
                per.Date__c           = Date.today();
            }
            perList[0].Promotion__c        = promoList[0].Id;
            perList[0].Eligibility_Rule__c = erList[0].Id;
            perList[1].Promotion__c        = promoList[1].Id;
            perList[1].Eligibility_Rule__c = erList[1].Id;
            perList[2].Promotion__c        = promoList[0].Id;
            perList[2].Eligibility_Rule__c = erList[2].Id;
            perList[3].Promotion__c        = promoList[1].Id;
            perList[3].Eligibility_Rule__c = erList[3].Id;
            perList[4].Promotion__c        = promoList[0].Id;
            perList[4].Eligibility_Rule__c = erList[4].Id;
            perList[5].Promotion__c        = promoList[1].Id;
            perList[5].Eligibility_Rule__c = erList[1].Id;
            Database.insert(perList);
        
        
            //create promo eligibility rule product family
            List<Promo_Eligibility_Rule_Product_Family__c> perpfList = TestDataFactory.createPromoEligRuleProdFamily(1);
            perpfList[0].Product_Family__c             = pfList[0].Id;
            perpfList[0].Promotion_Eligibility_Rule__c = perList[0].Id;
            Database.insert(perpfList);
           
           
        //Billing Account
            //Create zoura customer account
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc[0].Zuora__Account__c              = accList[0].Id;
            billAcc[0].Billing_Type__c                = 'Full Prepaid';
            billAcc[0].Zuora__Credit_Balance__c       = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            Database.insert(billAcc);
            
        
            //Create order
            List<Order__c> odr = TestDataFactory.createOrder(1);
            odr[0].Account__c         = accList[0].Id;
    //      odr[0].Billing_Account__c = billAcc[0].Id;
            odr[0].Billing_Type__c    = 'Full Prepaid';
            Database.insert(odr);
        
        
            //Create zuora subscription 
            List<Zuora__Subscription__c> zSubList = TestDataFactory.createSubscription(6);
            for(Zuora__Subscription__c zSub: zSubList){
                //zSub.Zuora__Account__c               = accList[0].id;
                zSub.Zuora__Account__c               = accParent.id;
                zSub.Promotion_1__c                  = promoList[0].id;
                zSub.Zuora__CustomerAccount__c       = billAcc[0].Id;
                zSub.Order_Number__c                 = odr[0].id;
                zSub.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
                zSub.Zuora__SubscriptionEndDate__c   = Date.today().addDays(90);
                //zSub.Contract_End_Date_1__c        = Date.today().addDays(90);
                zSub.Contract_End_Date__c            = ''+Date.today().addDays(90);
                zSub.Zuora__Status__c                = 'Active';
                zSub.Main_Package__c                 = packList[0].id;
            }
            
            zSubList[1].Promotion_1__c  = promoList[1].id;
            zSubList[1].Main_Package__c = packList[0].id;
            
            zSubList[2].Promotion_1__c  = promoList[2].id;
            zSubList[2].Main_Package__c = packList[0].id;
            
            zSubList[3].Promotion_1__c  = promoList[0].id;
                        
            zSubList[4].Promotion_1__c  = promoList[1].id;
            zSubList[4].Main_Package__c = packList[0].id;
                        
            zSubList[5].Promotion_1__c  = promoList[2].id;
                
            Database.insert(zSubList);
            
               
               
            //Create zuora subscription product charge
            List<Zuora__SubscriptionProductCharge__c> zSubProChargeList = TestDataFactory.createSubscriptionProductCharge(1);
            for(Zuora__SubscriptionProductCharge__c zSubProCharge : zSubProChargeList) {
                zSubProCharge.Zuora__Account__c       = accList[0].id;
                zSubProCharge.Zuora__Subscription__c  = zSubList[0].Id;
                zSubProCharge.Zuora__ProductSKU__c    = 'temp';
                zSubProCharge.Zuora__RatePlanName__c  = 'temp';
                zSubProCharge.Zuora__ProductName__c   = 'temp';
                zSubProCharge.Zuora__Quantity__c      = 15.3;
                zSubProCharge.Product_Code__c         = 'churva';
                zSubProCharge.Zuora__Price__c         = 100.00;
                zSubProCharge.Zuora__BillingPeriod__c = 'First';
            }
            Database.insert(zSubProChargeList); 
            
        
            //Create zuora zProduct
            List<zqu__ZProduct__c> zProductList = TestDataFactory.createZProduct(1);
            for(zqu__ZProduct__c zProduct : zProductList) {
                zProduct.ProductCode__c = 'churva';
                zProduct.zqu__SKU__c    = zSubProChargeList[0].Zuora__ProductSKU__c;
            }
            Database.insert(zProductList);
        
        
            //Create product rate plan
            List<zqu__ProductRatePlan__c> productRatePlanList = TestDataFactory.createProductRatePlan(1);
            for(zqu__ProductRatePlan__c productRatePlan : productRatePlanList) {
                productRatePlan.Name             = zSubProChargeList[0].Zuora__RatePlanName__c;
                productRatePlan.zqu__ZProduct__c = zProductList[0].Id;
            }
            Database.insert(productRatePlanList);
            
            //Publication
            List<Publication__c> publicationList = TestDataFactory.createPublication(1);
            publicationList[0].Product_Family_Lookup__c = pfList[0].Id;
            Database.insert(publicationList);
            
        
            //FROM Subscription_Vendor__c WHERE Account__c =: acct.Parent.Id AND Status__c = 'Active'
            //Subscription_Vendor__c 
            List<Subscription_Vendor__c> subsVendorList = TestDataFactory.createSubscriptionVendor(1);
            for(Subscription_Vendor__c subsVendor : subsVendorList) {
                subsVendor.Account__c = accParent.id;
                subsVendor.Status__c = 'Active';
            }
            Database.insert(subsVendorList);
        
            //Subscription_Vendor_Publications__c
            List<Subscription_Vendor_Publication__c> subsVendorPubList = new List<Subscription_Vendor_Publication__c>();
            subsVendorPubList.add(new Subscription_Vendor_Publication__c());
            for(Subscription_Vendor_Publication__c subsVendorPub : subsVendorPubList) {
                subsVendorPub.Publication__c         = publicationList[0].id;
                subsVendorPub.Subscription_Vendor__c = subsVendorList[0].id;
            }
            Database.insert(subsVendorPubList);
            
            
            
            //Promo_Eligibility_Rule_Product_Family__c
            List<Promo_Eligibility_Rule_Product_Family__c> promoEligRuleProdFamList = new List<Promo_Eligibility_Rule_Product_Family__c>();
            Promo_Eligibility_Rule_Product_Family__c promoEligRuleProdFam1 = new Promo_Eligibility_Rule_Product_Family__c();
            promoEligRuleProdFam1.Product_Family__c             = pfList[0].id;
            promoEligRuleProdFam1.Promotion_Eligibility_Rule__c = perList[0].id;
            promoEligRuleProdFamList.add(promoEligRuleProdFam1);
            Database.insert(promoEligRuleProdFamList);
            
            //FROM Zuora__Subscriptions__r
            //FROM Account
            //FROM Subscription_Vendor__c
            //FROM Promotion__c
            //FROM Zuora__Subscription__c
            //FROM Zuora__SubscriptionProductCharge__c
            //FROM zqu__ProductRatePlan__c
            //FROM Promotion_Package__c
            //from Promo_Eligibility_Rule_Product_Families__r
            //FROM Promotion_Eligibility_Rule__c 
            
        
            //Setup Parameters
            Id accId = accList[1].id;
            String action = 'Add';
            Map<String , Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
            Set<String> contractPeriod1 = new Set<String>();
            contractPeriod1.add(promoList[0].Contract_Period__c);
            contractPeriod1.add(promoList[1].Contract_Period__c);   
            contractPeriod1.add(promoList[2].Contract_Period__c);          
            promoCodeContractSet.put(promoList[0].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[1].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[2].Promotion_Code__c, contractPeriod1);
            
            String pkgCode = '';
            Id subsId = zSubList[0].id;
            Boolean booleanVar = False;
            
            Test.startTest();
            PromoEligibilityRule testObj = new PromoEligibilityRule();
            //public Map<String, Set<String>> result
            testObj.getEligibility(accId, action, promoCodeContractSet, pkgCode, subsId, booleanVar);  
            Test.stopTest();
        }
    
    }
    
    
    static testMethod void testGetEligibility_ExistingCustomer_NewSubscriber01() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
        
            setCustomSettings();
            
            //Singpost_Address__c
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            Database.insert(postal);
    
            //Create Parent Account
            Account accParent = TestDataFactory.createAccount(1, 'Vendor')[0];
            Database.insert(accParent);
            
            //Create account
            List<Account> accList = TestDataFactory.createAccount(4, 'Vendor');
            accList[0]          = TestDataFactory.createAccount(1, 'Vendor')[0];
            accList[0].Name     = 'TEST1';
            accList[0].NRIC__c  = 'T1234567R';
            accList[0].ParentId = accParent.Id;
            
            accList[1]          = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[1].Name     = 'TEST2';
            accList[1].NRIC__c  = 'T1234567S';
            accList[1].ParentId = accParent.Id;
            
            accList[2]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[2].Name    = 'TEST3';
            accList[2].NRIC__c = 'T1234567T';
            accList[2].ParentId = accParent.Id;
            
            accList[3]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[3].Name    = 'TEST4';
            accList[3].NRIC__c = 'T1234567U';
            accList[3].ParentId = accParent.Id;
            
            Database.insert(accList);
            
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c             = addressRec.Id;
            con.AccountId              = accList[1].Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            //Create promo
            List<Promotion__c> promoList = TestDataFactory.createPromoList(3);
            for(Promotion__c promo : promoList) {
                promo.Effective_Start_Date__c    = Date.today();
                promo.Effective_End_Date__c      = Date.today().addDays(30);
                promo.Contract__c                = 'Yes';
                promo.Contract_Period__c         = '2';
                promo.Penalty_Charge__c          = '100';
                promo.Penalty_Charge_Override__c = 500.00;  
            }   
            promoList[0].Promotion_Code__c = 'yasyd97';
            promoList[1].Promotion_Code__c = 'yasyd97';
            promoList[2].Promotion_Code__c = 'yasyd99';
            Database.insert(promoList);
            
            //Create package
            List<Package__c> packList = TestDataFactory.createPackage(2);
            for(Package__c pack : packList) {
                pack.Package_Type__c                   = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
                pack.Billing_Type__c                   = 'Full Prepaid';
                pack.Package_Code__c                   = 'tempCode0';      
                pack.Product_Family_Current_Package__c = 'tmp0'; 
                pack.Effective_End_Date__c             = date.today().addDays(31);
                pack.Effective_Start_Date__c           = date.today();
                pack.Subscription_Period__c            = '1';
            }
            packList[1].Package_Code__c                   = 'tempCode1';  
            packList[1].Product_Family_Current_Package__c = 'tmp1';
            Database.insert(packList);
            
            List<Package__c> packList2 = TestDataFactory.createPackage(1);
            for(Package__c pack : packList2) {
                pack.Package_Type__c                   = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
                pack.Billing_Type__c                   = 'Full Prepaid';
                pack.Package_Code__c                   = 'tempCode2';      
                pack.Product_Family_Current_Package__c = 'tmp2'; 
                pack.Effective_End_Date__c             = date.today().addDays(31);
                pack.Effective_Start_Date__c           = date.today();
                pack.Subscription_Period__c            = '1';
            }
            Database.insert(packList2);
            
            //Create promotion package
            List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(4);
            promotionPackageList[0].Promotion__c    = promoList[0].Id;
            promotionPackageList[0].Package_Name__c = packList[0].Id;
            promotionPackageList[1].Promotion__c    = promoList[1].Id;
            promotionPackageList[1].Package_Name__c = packList[1].Id;
            promotionPackageList[2].Promotion__c    = promoList[2].Id;
            promotionPackageList[2].Package_Name__c = packList2[0].Id;
            promotionPackageList[3].Promotion__c    = promoList[0].Id;
            promotionPackageList[3].Package_Name__c = packList[0].Id;
            Database.insert(promotionPackageList);
            
            //create product family      
            List<Product_Family__c> pfList = TestDataFactory.createProductFamily(2);
            //pfList[0].Product_Family__c = 
            Database.insert(pfList);
            
            //create eligibility rule
            List<Eligibility_Rule__c> erList = TestDataFactory.createEligibilityRule(5);
            for(Eligibility_Rule__c er : erList) {
                er.Product_Family__c       = pfList[0].Id;
                er.Effective_Start_Date__c = Date.today();
                er.Effective_End_Date__c   = Date.today().addDays(30);
                er.Subsciber_Status__c     = 'New Subscriber';
            }    
            erList[0].Customer_Status__c   = 'Existing Customer';
            //erList[0].Contract_Status__c   = 'With Contract';
            erList[0].Action__c            = 'Add';
            
            erList[1].Customer_Status__c   = 'Existing Customer';
            //erList[1].Contract_Status__c   = 'With Contract';
            erList[1].Action__c            = 'Add';
            erList[1].Product_Family__c    = pfList[0].Id;
                
            erList[2].Customer_Status__c   = 'Existing Customer';
            //erList[2].Contract_Status__c   = 'With Contract';
            erList[2].Action__c            = 'Add';
            erList[2].Product_Family__c    = pfList[0].Id;
            
            erList[3].Customer_Status__c   = 'Existing Customer';
            //erList[3].Contract_Status__c   = 'With Contract';
            erList[3].Action__c            = 'Add';  
            
            erList[4].Customer_Status__c   = 'Existing customer';
            //erList[4].Contract_Status__c   = 'With Contract';
            erList[4].Action__c            = 'Add'; 
            Database.insert(erList);
            
            
            //create promotion eligibility rule
            List<Promotion_Eligibility_Rule__c> perList = TestDataFactory.createPromEligibilityRule(6);
            for(Promotion_Eligibility_Rule__c per : perList) {
                per.Product_Family__c = 'TM';
                per.Package_List__c   = 'tempCode0;tempCode1';
                per.Prod_Family__c    = pfList[0].Id; 
                per.Date__c           = Date.today();
            }
            perList[0].Promotion__c        = promoList[0].Id;
            perList[0].Eligibility_Rule__c = erList[0].Id;
            perList[1].Promotion__c        = promoList[1].Id;
            perList[1].Eligibility_Rule__c = erList[1].Id;
            perList[2].Promotion__c        = promoList[0].Id;
            perList[2].Eligibility_Rule__c = erList[2].Id;
            perList[3].Promotion__c        = promoList[1].Id;
            perList[3].Eligibility_Rule__c = erList[3].Id;
            perList[4].Promotion__c        = promoList[0].Id;
            perList[4].Eligibility_Rule__c = erList[4].Id;
            perList[5].Promotion__c        = promoList[1].Id;
            perList[5].Eligibility_Rule__c = erList[1].Id;
            Database.insert(perList);
        
        
            //create promo eligibility rule product family
            List<Promo_Eligibility_Rule_Product_Family__c> perpfList = TestDataFactory.createPromoEligRuleProdFamily(2);
            perpfList[0].Product_Family__c             = pfList[0].Id;
            perpfList[0].Promotion_Eligibility_Rule__c = perList[0].Id;
            perpfList[1].Product_Family__c             = pfList[1].Id;
            perpfList[1].Promotion_Eligibility_Rule__c = perList[1].Id;
            Database.insert(perpfList);
           
           
            //Billing Account
            //Create zoura customer account
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc[0].Zuora__Account__c              = accList[1].Id;
            billAcc[0].Billing_Type__c                = 'Full Prepaid';
            billAcc[0].Zuora__Credit_Balance__c       = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            Database.insert(billAcc);
            
        
            //Create order
            List<Order__c> odr = TestDataFactory.createOrder(1);
            odr[0].Account__c         = accList[1].Id;
    //      odr[0].Billing_Account__c = billAcc[0].Id;
            odr[0].Billing_Type__c    = 'Full Prepaid';
            Database.insert(odr);
        
        
            //Create zuora subscription 
            List<Zuora__Subscription__c> zSubList = TestDataFactory.createSubscription(6);
            for(Zuora__Subscription__c zSub: zSubList){
                zSub.Zuora__Account__c               = accList[1].id;
                zSub.Promotion_1__c                  = promoList[0].id;
                zSub.Zuora__CustomerAccount__c       = billAcc[0].Id;
                zSub.Order_Number__c                 = odr[0].id;
                zSub.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
                zSub.Zuora__SubscriptionEndDate__c   = Date.today().addDays(90);
                //zSub.Contract_End_Date_1__c        = Date.today().addDays(90);
                zSub.Contract_End_Date__c            = ''+Date.today().addDays(90);
                zSub.Zuora__Status__c                = 'Active';
                zSub.Main_Package__c                 = packList[0].id;
            }
            
            zSubList[1].Promotion_1__c  = promoList[1].id;
            zSubList[1].Main_Package__c = packList[0].id;
            
            zSubList[2].Promotion_1__c  = promoList[2].id;
            zSubList[2].Main_Package__c = packList[0].id;
            
            zSubList[3].Promotion_1__c  = promoList[0].id;
                        
            zSubList[4].Promotion_1__c  = promoList[1].id;
            zSubList[4].Main_Package__c = packList[0].id;
                        
            zSubList[5].Promotion_1__c  = promoList[2].id;
            zSubList[5].Main_Package__c = packList[0].id;
                
            Database.insert(zSubList);
            
               
               
            //Create zuora subscription product charge
            List<Zuora__SubscriptionProductCharge__c> zSubProChargeList = TestDataFactory.createSubscriptionProductCharge(2);
            for(Zuora__SubscriptionProductCharge__c zSubProCharge : zSubProChargeList) {
                zSubProCharge.Zuora__Account__c       = accList[1].id;
                zSubProCharge.Zuora__ProductSKU__c    = 'temp';
                zSubProCharge.Zuora__RatePlanName__c  = 'temp';
                zSubProCharge.Zuora__ProductName__c   = 'temp';
                zSubProCharge.Zuora__Quantity__c      = 15.3;
                zSubProCharge.Product_Code__c         = 'churva';
                zSubProCharge.Zuora__Price__c         = 100.00;
                zSubProCharge.Zuora__BillingPeriod__c = 'First';
            }
            zSubProChargeList[0].Zuora__Subscription__c = zSubList[0].Id;
            zSubProChargeList[1].Zuora__Subscription__c = zSubList[1].Id;
            Database.insert(zSubProChargeList); 
            
        
            //Create zuora zProduct
            List<zqu__ZProduct__c> zProductList = TestDataFactory.createZProduct(1);
            for(zqu__ZProduct__c zProduct : zProductList) {
                zProduct.ProductCode__c = 'churva';
                zProduct.zqu__SKU__c    = zSubProChargeList[0].Zuora__ProductSKU__c;
            }
            Database.insert(zProductList);
        
        
            //Create product rate plan
            List<zqu__ProductRatePlan__c> productRatePlanList = TestDataFactory.createProductRatePlan(2);
            for(zqu__ProductRatePlan__c productRatePlan : productRatePlanList) {
                productRatePlan.zqu__ZProduct__c = zProductList[0].Id;
            }
            productRatePlanList[0].Name = zSubProChargeList[0].Zuora__RatePlanName__c;
            productRatePlanList[1].Name = zSubProChargeList[1].Zuora__RatePlanName__c;
            Database.insert(productRatePlanList);
            
            //Publication
            List<Publication__c> publicationList = TestDataFactory.createPublication(2);
            publicationList[0].Product_Family_Lookup__c = pfList[0].Id;
            publicationList[1].Product_Family_Lookup__c = pfList[1].Id;
            Database.insert(publicationList);
            
        
            //FROM Subscription_Vendor__c WHERE Account__c =: acct.Parent.Id AND Status__c = 'Active'
            //Subscription_Vendor__c 
            List<Subscription_Vendor__c> subsVendorList = TestDataFactory.createSubscriptionVendor(1);
            for(Subscription_Vendor__c subsVendor : subsVendorList) {
                subsVendor.Account__c = accParent.id;
                subsVendor.Status__c = 'Active';
            }
            Database.insert(subsVendorList);
        
            //Subscription_Vendor_Publications__c
            List<Subscription_Vendor_Publication__c> subsVendorPubList = new List<Subscription_Vendor_Publication__c>();
            subsVendorPubList.add(new Subscription_Vendor_Publication__c());
            for(Subscription_Vendor_Publication__c subsVendorPub : subsVendorPubList) {
                subsVendorPub.Publication__c         = publicationList[0].id;
                subsVendorPub.Subscription_Vendor__c = subsVendorList[0].id;
            }
            Database.insert(subsVendorPubList);
            
            
            
            //Promo_Eligibility_Rule_Product_Family__c
            List<Promo_Eligibility_Rule_Product_Family__c> promoEligRuleProdFamList = new List<Promo_Eligibility_Rule_Product_Family__c>();
            Promo_Eligibility_Rule_Product_Family__c promoEligRuleProdFam1 = new Promo_Eligibility_Rule_Product_Family__c();
            promoEligRuleProdFam1.Product_Family__c             = pfList[0].id;
            promoEligRuleProdFam1.Promotion_Eligibility_Rule__c = perList[0].id;
            promoEligRuleProdFamList.add(promoEligRuleProdFam1);
            Promo_Eligibility_Rule_Product_Family__c promoEligRuleProdFam2 = new Promo_Eligibility_Rule_Product_Family__c();
            promoEligRuleProdFam2.Product_Family__c             = pfList[1].id;
            promoEligRuleProdFam2.Promotion_Eligibility_Rule__c = perList[1].id;
            promoEligRuleProdFamList.add(promoEligRuleProdFam2);
            Database.insert(promoEligRuleProdFamList);
            
            //FROM Zuora__Subscriptions__r
            //FROM Account
            //FROM Subscription_Vendor__c
            //FROM Promotion__c
            //FROM Zuora__Subscription__c
            //FROM Zuora__SubscriptionProductCharge__c
            //FROM zqu__ProductRatePlan__c
            //FROM Promotion_Package__c
            //from Promo_Eligibility_Rule_Product_Families__r
            //FROM Promotion_Eligibility_Rule__c 
            
        
            //Setup Parameters
            Id accId = accList[1].id;
            String action = 'Add';
            Map<String , Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
            Set<String> contractPeriod1 = new Set<String>();
            contractPeriod1.add(promoList[0].Contract_Period__c);
            contractPeriod1.add(promoList[1].Contract_Period__c);   
            contractPeriod1.add(promoList[2].Contract_Period__c);          
            promoCodeContractSet.put(promoList[0].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[1].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[2].Promotion_Code__c, contractPeriod1);
            
            String pkgCode = '';
            Id subsId = zSubList[0].id;
            Boolean booleanVar = False;
            
            Test.startTest();
            PromoEligibilityRule testObj = new PromoEligibilityRule();
            //public Map<String, Set<String>> result
            testObj.getEligibility(accId, action, promoCodeContractSet, pkgCode, subsId, booleanVar);  
            Test.stopTest();
        }
    
    }
    
    
    static testMethod void testGetEligibility_ExistingCustomer_Change_WithContract_Date01() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
        
            setCustomSettings();
            
            //Singpost_Address__c
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            Database.insert(postal);
    
            //Create Parent Account
            Account accParent = TestDataFactory.createAccount(1, 'Vendor')[0];
            Database.insert(accParent);
            
            //Create account
            List<Account> accList = TestDataFactory.createAccount(4, 'Vendor');
            accList[0]          = TestDataFactory.createAccount(1, 'Vendor')[0];
            accList[0].Name     = 'TEST1';
            accList[0].NRIC__c  = 'T1234567R';
            accList[0].ParentId = accParent.Id;
            
            accList[1]          = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[1].Name     = 'TEST2';
            accList[1].NRIC__c  = 'T1234567S';
            accList[1].ParentId = accParent.Id;
            
            accList[2]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[2].Name    = 'TEST3';
            accList[2].NRIC__c = 'T1234567T';
            accList[2].ParentId = accParent.Id;
            
            accList[3]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[3].Name    = 'TEST4';
            accList[3].NRIC__c = 'T1234567U';
            accList[3].ParentId = accParent.Id;
            
            Database.insert(accList);
            
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c             = addressRec.Id;
            con.AccountId              = accList[1].Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            //Create promo
            List<Promotion__c> promoList = TestDataFactory.createPromoList(3);
            for(Promotion__c promo : promoList) {
                promo.Effective_Start_Date__c    = Date.today();
                promo.Effective_End_Date__c      = Date.today().addDays(30);
                promo.Contract__c                = 'Yes';
                promo.Contract_Period__c         = '2';
                promo.Penalty_Charge__c          = '100';
                promo.Penalty_Charge_Override__c = 500.00;  
            }   
            promoList[0].Promotion_Code__c = 'yasyd97';
            promoList[1].Promotion_Code__c = 'yasyd97';
            promoList[2].Promotion_Code__c = 'yasyd99';
            Database.insert(promoList);
            
            //Create package
            List<Package__c> packList = TestDataFactory.createPackage(1);
            for(Package__c pack : packList) {
                pack.Package_Type__c                   = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
                pack.Billing_Type__c                   = 'Full Prepaid';
                pack.Package_Code__c                   = 'tempCode0';      
                pack.Product_Family_Current_Package__c = 'tmp0'; 
                pack.Effective_End_Date__c             = date.today().addDays(31);
                pack.Effective_Start_Date__c           = date.today();
                pack.Subscription_Period__c            = '1';
            }
            Database.insert(packList);
            
            //Create promotion package
            List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(4);
            promotionPackageList[0].Promotion__c    = promoList[0].Id;
            promotionPackageList[0].Package_Name__c = packList[0].Id;
            promotionPackageList[1].Promotion__c    = promoList[1].Id;
            promotionPackageList[1].Package_Name__c = packList[0].Id;
            promotionPackageList[2].Promotion__c    = promoList[2].Id;
            promotionPackageList[2].Package_Name__c = packList[0].Id;
            promotionPackageList[3].Promotion__c    = promoList[0].Id;
            promotionPackageList[3].Package_Name__c = packList[0].Id;
            Database.insert(promotionPackageList);
            
            //create product family      
            List<Product_Family__c> pfList = TestDataFactory.createProductFamily(1);
            Database.insert(pfList);
            
            //create eligibility rule
            List<Eligibility_Rule__c> erList = TestDataFactory.createEligibilityRule(5);
            for(Eligibility_Rule__c er : erList) {
                er.Product_Family__c             = pfList[0].Id;
                er.Effective_Start_Date__c       = Date.today();
                er.Effective_End_Date__c         = Date.today().addDays(30);
                er.Contract_Subscription_Rule__c = 'Contract End Date';
                er.Condition__c                  = '>';
            }    
            erList[0].Customer_Status__c   = 'Existing Customer';
            erList[0].Contract_Status__c   = 'With Contract';
            erList[0].Action__c            = 'Change';
            
            erList[1].Customer_Status__c   = 'Existing Customer';
            erList[1].Contract_Status__c   = 'With Contract';
            erList[1].Action__c            = 'Change';
                
            erList[2].Customer_Status__c   = 'Existing Customer';
            erList[2].Contract_Status__c   = 'With Contract';
            erList[2].Action__c            = 'Change';
            
            erList[3].Customer_Status__c   = 'Existing Customer';
            erList[3].Contract_Status__c   = 'With Contract';
            erList[3].Action__c            = 'Change';  
            
            erList[4].Customer_Status__c   = 'Existing customer';
            erList[4].Contract_Status__c   = 'With Contract';
            erList[4].Action__c            = 'Change'; 
            Database.insert(erList);
            
            
            //create promotion eligibility rule
            List<Promotion_Eligibility_Rule__c> perList = TestDataFactory.createPromEligibilityRule(6);
            for(Promotion_Eligibility_Rule__c per : perList) {
                per.Product_Family__c   = 'tmp0';
                per.Package_List__c     = 'tempCode0';
                per.Prod_Family__c      = pfList[0].Id; 
                per.Current_Platform__c = 'Online';
                per.Date__c             = Date.today();
            }
            perList[0].Promotion__c        = promoList[0].Id;
            perList[0].Eligibility_Rule__c = erList[0].Id;
            perList[1].Promotion__c        = promoList[1].Id;
            perList[1].Eligibility_Rule__c = erList[1].Id;
            perList[2].Promotion__c        = promoList[0].Id;
            perList[2].Eligibility_Rule__c = erList[2].Id;
            perList[3].Promotion__c        = promoList[1].Id;
            perList[3].Eligibility_Rule__c = erList[3].Id;
            perList[4].Promotion__c        = promoList[0].Id;
            perList[4].Eligibility_Rule__c = erList[4].Id;
            perList[5].Promotion__c        = promoList[1].Id;
            perList[5].Eligibility_Rule__c = erList[1].Id;
            Database.insert(perList);
        
        
            //create promo eligibility rule product family
            List<Promo_Eligibility_Rule_Product_Family__c> perpfList = TestDataFactory.createPromoEligRuleProdFamily(1);
            perpfList[0].Product_Family__c             = pfList[0].Id;
            perpfList[0].Promotion_Eligibility_Rule__c = perList[0].Id;
            Database.insert(perpfList);
           
           
            //Billing Account
            //Create zoura customer account
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc[0].Zuora__Account__c              = accList[1].Id;
            billAcc[0].Billing_Type__c                = 'Full Prepaid';
            billAcc[0].Zuora__Credit_Balance__c       = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            Database.insert(billAcc);
            
        
            //Create order
            List<Order__c> odr = TestDataFactory.createOrder(1);
            odr[0].Account__c         = accList[1].Id;
    //      odr[0].Billing_Account__c = billAcc[0].Id;
            odr[0].Billing_Type__c    = 'Full Prepaid';
            Database.insert(odr);
        
        
            //Create zuora subscription 
            List<Zuora__Subscription__c> zSubList = TestDataFactory.createSubscription(6);
            for(Zuora__Subscription__c zSub: zSubList){
                zSub.Zuora__Account__c               = accList[1].id;
                zSub.Promotion_1__c                  = promoList[0].id;
                zSub.Zuora__CustomerAccount__c       = billAcc[0].Id;
                zSub.Order_Number__c                 = odr[0].id;
                zSub.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
                // NG - zSub.Zuora__SubscriptionEndDate__c   = Date.today().addDays(90);
                zSub.Term_Length__c                  = 3;     
                //zSub.Contract_End_Date_1__c        = Date.today().addDays(90);
                zSub.Contract_End_Date__c            = ''+Date.today().addDays(90);
                zSub.Zuora__Status__c                = 'Active';
                zSub.Main_Package__c                 = packList[0].id;
            }
            
            zSubList[1].Promotion_1__c  = promoList[1].id;
            zSubList[1].Main_Package__c = packList[0].id;
            
            zSubList[2].Promotion_1__c  = promoList[2].id;
            zSubList[2].Main_Package__c = packList[0].id;
            
            zSubList[3].Promotion_1__c  = promoList[0].id;
                        
            zSubList[4].Promotion_1__c  = promoList[1].id;
            zSubList[4].Main_Package__c = packList[0].id;
                        
            zSubList[5].Promotion_1__c  = promoList[2].id;
                
            Database.insert(zSubList);
               
               
            //Create zuora subscription product charge
            List<Zuora__SubscriptionProductCharge__c> zSubProChargeList = TestDataFactory.createSubscriptionProductCharge(2);
            for(Zuora__SubscriptionProductCharge__c zSubProCharge : zSubProChargeList) {
                zSubProCharge.Zuora__Account__c       = accList[1].id;
                zSubProCharge.Zuora__Subscription__c  = zSubList[0].Id;
                zSubProCharge.Zuora__ProductSKU__c    = 'temp';
                zSubProCharge.Zuora__RatePlanName__c  = 'temp';
                zSubProCharge.Zuora__ProductName__c   = 'temp';
                zSubProCharge.Zuora__Quantity__c      = 15.3;
                zSubProCharge.Product_Code__c         = 'churva';
                zSubProCharge.Zuora__Price__c         = 100.00;
                zSubProCharge.Zuora__BillingPeriod__c = 'First';
            }
            Database.insert(zSubProChargeList); 
            
        
            //Create zuora zProduct
            List<zqu__ZProduct__c> zProductList = TestDataFactory.createZProduct(1);
            for(zqu__ZProduct__c zProduct : zProductList) {
                zProduct.ProductCode__c     = 'churva';
                zProduct.zqu__SKU__c        = zSubProChargeList[0].Zuora__ProductSKU__c;
                zProduct.ProductPlatform__c = 'Online';
            }
            Database.insert(zProductList);
        
        
            //Create product rate plan
            List<zqu__ProductRatePlan__c> productRatePlanList = TestDataFactory.createProductRatePlan(1);
            for(zqu__ProductRatePlan__c productRatePlan : productRatePlanList) {
                productRatePlan.Name             = zSubProChargeList[0].Zuora__RatePlanName__c;
                productRatePlan.zqu__ZProduct__c = zProductList[0].Id;
            }
            Database.insert(productRatePlanList);
            
            //Publication
            List<Publication__c> publicationList = TestDataFactory.createPublication(1);
            publicationList[0].Product_Family_Lookup__c = pfList[0].Id;
            Database.insert(publicationList);
            
        
            //FROM Subscription_Vendor__c WHERE Account__c =: acct.Parent.Id AND Status__c = 'Active'
            //Subscription_Vendor__c 
            List<Subscription_Vendor__c> subsVendorList = TestDataFactory.createSubscriptionVendor(1);
            for(Subscription_Vendor__c subsVendor : subsVendorList) {
                subsVendor.Account__c = accParent.id;
                subsVendor.Status__c = 'Active';
            }
            Database.insert(subsVendorList);
        
            //Subscription_Vendor_Publications__c
            List<Subscription_Vendor_Publication__c> subsVendorPubList = new List<Subscription_Vendor_Publication__c>();
            subsVendorPubList.add(new Subscription_Vendor_Publication__c());
            for(Subscription_Vendor_Publication__c subsVendorPub : subsVendorPubList) {
                subsVendorPub.Publication__c         = publicationList[0].id;
                subsVendorPub.Subscription_Vendor__c = subsVendorList[0].id;
            }
            Database.insert(subsVendorPubList);
            
            
            
            //Promo_Eligibility_Rule_Product_Family__c
            List<Promo_Eligibility_Rule_Product_Family__c> promoEligRuleProdFamList = new List<Promo_Eligibility_Rule_Product_Family__c>();
            Promo_Eligibility_Rule_Product_Family__c promoEligRuleProdFam1 = new Promo_Eligibility_Rule_Product_Family__c();
            promoEligRuleProdFam1.Product_Family__c             = pfList[0].id;
            promoEligRuleProdFam1.Promotion_Eligibility_Rule__c = perList[0].id;
            promoEligRuleProdFamList.add(promoEligRuleProdFam1);
            Database.insert(promoEligRuleProdFamList);
            
            //FROM Zuora__Subscriptions__r
            //FROM Account
            //FROM Subscription_Vendor__c
            //FROM Promotion__c
            //FROM Zuora__Subscription__c
            //FROM Zuora__SubscriptionProductCharge__c
            //FROM zqu__ProductRatePlan__c
            //FROM Promotion_Package__c
            //from Promo_Eligibility_Rule_Product_Families__r
            //FROM Promotion_Eligibility_Rule__c 
            
        
            //Setup Parameters
            Id accId = accList[1].id;
            String action = 'Change';
            Map<String , Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
            Set<String> contractPeriod1 = new Set<String>();
            contractPeriod1.add(promoList[0].Contract_Period__c);
            contractPeriod1.add(promoList[1].Contract_Period__c);   
            contractPeriod1.add(promoList[2].Contract_Period__c);          
            promoCodeContractSet.put(promoList[0].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[1].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[2].Promotion_Code__c, contractPeriod1);
            
            String pkgCode = '';
            Id subsId = zSubList[0].id;
            Boolean booleanVar = False;
            
            Test.startTest();
            PromoEligibilityRule testObj = new PromoEligibilityRule();
            //public Map<String, Set<String>> result
            testObj.getEligibility(accId, action, promoCodeContractSet, pkgCode, subsId, booleanVar);  
            Test.stopTest();
        }
    
    }
    
    
    static testMethod void testGetEligibility_ExistingCustomer_Change_WithContract_Days01() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
        
            setCustomSettings();
            
            //Singpost_Address__c
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            Database.insert(postal);
    
            //Create Parent Account
            Account accParent = TestDataFactory.createAccount(1, 'Vendor')[0];
            Database.insert(accParent);
            
            //Create account
            List<Account> accList = TestDataFactory.createAccount(4, 'Vendor');
            accList[0]          = TestDataFactory.createAccount(1, 'Vendor')[0];
            accList[0].Name     = 'TEST1';
            accList[0].NRIC__c  = 'T1234567R';
            accList[0].ParentId = accParent.Id;
            
            accList[1]          = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[1].Name     = 'TEST2';
            accList[1].NRIC__c  = 'T1234567S';
            accList[1].ParentId = accParent.Id;
            
            accList[2]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[2].Name    = 'TEST3';
            accList[2].NRIC__c = 'T1234567T';
            accList[2].ParentId = accParent.Id;
            
            accList[3]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[3].Name    = 'TEST4';
            accList[3].NRIC__c = 'T1234567U';
            accList[3].ParentId = accParent.Id;
            
            Database.insert(accList);
            
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c             = addressRec.Id;
            con.AccountId              = accList[1].Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            //Create promo
            List<Promotion__c> promoList = TestDataFactory.createPromoList(3);
            for(Promotion__c promo : promoList) {
                promo.Effective_Start_Date__c    = Date.today();
                promo.Effective_End_Date__c      = Date.today().addDays(30);
                promo.Contract__c                = 'Yes';
                promo.Contract_Period__c         = '2';
                promo.Penalty_Charge__c          = '100';
                promo.Penalty_Charge_Override__c = 500.00;  
            }   
            promoList[0].Promotion_Code__c = 'yasyd97';
            promoList[1].Promotion_Code__c = 'yasyd97';
            promoList[2].Promotion_Code__c = 'yasyd99';
            Database.insert(promoList);
            
            //Create package
            List<Package__c> packList = TestDataFactory.createPackage(1);
            for(Package__c pack : packList) {
                pack.Package_Type__c                   = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
                pack.Billing_Type__c                   = 'Full Prepaid';
                pack.Package_Code__c                   = 'tempCode0';      
                pack.Product_Family_Current_Package__c = 'tmp0'; 
                pack.Effective_End_Date__c             = date.today().addDays(31);
                pack.Effective_Start_Date__c           = date.today();
                pack.Subscription_Period__c            = '1';
            }
            Database.insert(packList);
            
            //Create promotion package
            List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(4);
            promotionPackageList[0].Promotion__c    = promoList[0].Id;
            promotionPackageList[0].Package_Name__c = packList[0].Id;
            promotionPackageList[1].Promotion__c    = promoList[1].Id;
            promotionPackageList[1].Package_Name__c = packList[0].Id;
            promotionPackageList[2].Promotion__c    = promoList[2].Id;
            promotionPackageList[2].Package_Name__c = packList[0].Id;
            promotionPackageList[3].Promotion__c    = promoList[0].Id;
            promotionPackageList[3].Package_Name__c = packList[0].Id;
            Database.insert(promotionPackageList);
            
            //create product family      
            List<Product_Family__c> pfList = TestDataFactory.createProductFamily(1);
            Database.insert(pfList);
            
            //create eligibility rule
            List<Eligibility_Rule__c> erList = TestDataFactory.createEligibilityRule(5);
            for(Eligibility_Rule__c er : erList) {
                er.Product_Family__c             = pfList[0].Id;
                er.Effective_Start_Date__c       = Date.today();
                er.Effective_End_Date__c         = Date.today().addDays(30);
                er.Contract_Subscription_Rule__c = 'Contract End Date';
                er.Condition__c                  = '<';
            }    
            erList[0].Customer_Status__c   = 'Existing Customer';
            erList[0].Contract_Status__c   = 'With Contract';
            erList[0].Action__c            = 'Change';
            
            erList[1].Customer_Status__c   = 'Existing Customer';
            erList[1].Contract_Status__c   = 'With Contract';
            erList[1].Action__c            = 'Change';
                
            erList[2].Customer_Status__c   = 'Existing Customer';
            erList[2].Contract_Status__c   = 'With Contract';
            erList[2].Action__c            = 'Change';
            
            erList[3].Customer_Status__c   = 'Existing Customer';
            erList[3].Contract_Status__c   = 'With Contract';
            erList[3].Action__c            = 'Change';  
            
            erList[4].Customer_Status__c   = 'Existing customer';
            erList[4].Contract_Status__c   = 'With Contract';
            erList[4].Action__c            = 'Change'; 
            Database.insert(erList);
            
            
            //create promotion eligibility rule
            List<Promotion_Eligibility_Rule__c> perList = TestDataFactory.createPromEligibilityRule(6);
            for(Promotion_Eligibility_Rule__c per : perList) {
                per.Product_Family__c   = 'tmp0';
                per.Package_List__c     = 'tempCode0';
                per.Prod_Family__c      = pfList[0].Id; 
                per.Current_Platform__c = 'Online';
                per.Days__c             = '90';
            }
            perList[0].Promotion__c        = promoList[0].Id;
            perList[0].Eligibility_Rule__c = erList[0].Id;
            perList[1].Promotion__c        = promoList[1].Id;
            perList[1].Eligibility_Rule__c = erList[1].Id;
            perList[2].Promotion__c        = promoList[0].Id;
            perList[2].Eligibility_Rule__c = erList[2].Id;
            perList[3].Promotion__c        = promoList[1].Id;
            perList[3].Eligibility_Rule__c = erList[3].Id;
            perList[4].Promotion__c        = promoList[0].Id;
            perList[4].Eligibility_Rule__c = erList[4].Id;
            perList[5].Promotion__c        = promoList[1].Id;
            perList[5].Eligibility_Rule__c = erList[1].Id;
            Database.insert(perList);
        
        
            //create promo eligibility rule product family
            List<Promo_Eligibility_Rule_Product_Family__c> perpfList = TestDataFactory.createPromoEligRuleProdFamily(1);
            perpfList[0].Product_Family__c             = pfList[0].Id;
            perpfList[0].Promotion_Eligibility_Rule__c = perList[0].Id;
            Database.insert(perpfList);
           
           
            //Billing Account
            //Create zoura customer account
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc[0].Zuora__Account__c              = accList[1].Id;
            billAcc[0].Billing_Type__c                = 'Full Prepaid';
            billAcc[0].Zuora__Credit_Balance__c       = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            Database.insert(billAcc);
            
        
            //Create order
            List<Order__c> odr = TestDataFactory.createOrder(1);
            odr[0].Account__c         = accList[1].Id;
    //      odr[0].Billing_Account__c = billAcc[0].Id;
            odr[0].Billing_Type__c    = 'Full Prepaid';
            Database.insert(odr);
        
        
            //Create zuora subscription 
            List<Zuora__Subscription__c> zSubList = TestDataFactory.createSubscription(6);
            for(Zuora__Subscription__c zSub: zSubList){
                zSub.Zuora__Account__c               = accList[1].id;
                zSub.Promotion_1__c                  = promoList[0].id;
                zSub.Zuora__CustomerAccount__c       = billAcc[0].Id;
                zSub.Order_Number__c                 = odr[0].id;
                zSub.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
                // NG - zSub.Zuora__SubscriptionEndDate__c   = Date.today().addDays(90);
                zSub.Term_Length__c                  = 3;     
                //zSub.Contract_End_Date_1__c        = Date.today().addDays(90);
                zSub.Contract_End_Date__c            = ''+Date.today().addDays(90);
                zSub.Zuora__Status__c                = 'Active';
                zSub.Main_Package__c                 = packList[0].id;
            }
            
            zSubList[1].Promotion_1__c  = promoList[1].id;
            zSubList[1].Main_Package__c = packList[0].id;
            
            zSubList[2].Promotion_1__c  = promoList[2].id;
            zSubList[2].Main_Package__c = packList[0].id;
            
            zSubList[3].Promotion_1__c  = promoList[0].id;
                        
            zSubList[4].Promotion_1__c  = promoList[1].id;
            zSubList[4].Main_Package__c = packList[0].id;
                        
            zSubList[5].Promotion_1__c  = promoList[2].id;
                
            Database.insert(zSubList);
               
               
            //Create zuora subscription product charge
            List<Zuora__SubscriptionProductCharge__c> zSubProChargeList = TestDataFactory.createSubscriptionProductCharge(2);
            for(Zuora__SubscriptionProductCharge__c zSubProCharge : zSubProChargeList) {
                zSubProCharge.Zuora__Account__c       = accList[1].id;
                zSubProCharge.Zuora__Subscription__c  = zSubList[0].Id;
                zSubProCharge.Zuora__ProductSKU__c    = 'temp';
                zSubProCharge.Zuora__RatePlanName__c  = 'temp';
                zSubProCharge.Zuora__ProductName__c   = 'temp';
                zSubProCharge.Zuora__Quantity__c      = 15.3;
                zSubProCharge.Product_Code__c         = 'churva';
                zSubProCharge.Zuora__Price__c         = 100.00;
                zSubProCharge.Zuora__BillingPeriod__c = 'First';
            }
            Database.insert(zSubProChargeList); 
            
        
            //Create zuora zProduct
            List<zqu__ZProduct__c> zProductList = TestDataFactory.createZProduct(1);
            for(zqu__ZProduct__c zProduct : zProductList) {
                zProduct.ProductCode__c     = 'churva';
                zProduct.zqu__SKU__c        = zSubProChargeList[0].Zuora__ProductSKU__c;
                zProduct.ProductPlatform__c = 'Online';
            }
            Database.insert(zProductList);
        
        
            //Create product rate plan
            List<zqu__ProductRatePlan__c> productRatePlanList = TestDataFactory.createProductRatePlan(1);
            for(zqu__ProductRatePlan__c productRatePlan : productRatePlanList) {
                productRatePlan.Name             = zSubProChargeList[0].Zuora__RatePlanName__c;
                productRatePlan.zqu__ZProduct__c = zProductList[0].Id;
            }
            Database.insert(productRatePlanList);
            
            //Publication
            List<Publication__c> publicationList = TestDataFactory.createPublication(1);
            publicationList[0].Product_Family_Lookup__c = pfList[0].Id;
            Database.insert(publicationList);
            
        
            //FROM Subscription_Vendor__c WHERE Account__c =: acct.Parent.Id AND Status__c = 'Active'
            //Subscription_Vendor__c 
            List<Subscription_Vendor__c> subsVendorList = TestDataFactory.createSubscriptionVendor(1);
            for(Subscription_Vendor__c subsVendor : subsVendorList) {
                subsVendor.Account__c = accParent.id;
                subsVendor.Status__c = 'Active';
            }
            Database.insert(subsVendorList);
        
            //Subscription_Vendor_Publications__c
            List<Subscription_Vendor_Publication__c> subsVendorPubList = new List<Subscription_Vendor_Publication__c>();
            subsVendorPubList.add(new Subscription_Vendor_Publication__c());
            for(Subscription_Vendor_Publication__c subsVendorPub : subsVendorPubList) {
                subsVendorPub.Publication__c         = publicationList[0].id;
                subsVendorPub.Subscription_Vendor__c = subsVendorList[0].id;
            }
            Database.insert(subsVendorPubList);
            
            
            
            //Promo_Eligibility_Rule_Product_Family__c
            List<Promo_Eligibility_Rule_Product_Family__c> promoEligRuleProdFamList = new List<Promo_Eligibility_Rule_Product_Family__c>();
            Promo_Eligibility_Rule_Product_Family__c promoEligRuleProdFam1 = new Promo_Eligibility_Rule_Product_Family__c();
            promoEligRuleProdFam1.Product_Family__c             = pfList[0].id;
            promoEligRuleProdFam1.Promotion_Eligibility_Rule__c = perList[0].id;
            promoEligRuleProdFamList.add(promoEligRuleProdFam1);
            Database.insert(promoEligRuleProdFamList);
            
            //FROM Zuora__Subscriptions__r
            //FROM Account
            //FROM Subscription_Vendor__c
            //FROM Promotion__c
            //FROM Zuora__Subscription__c
            //FROM Zuora__SubscriptionProductCharge__c
            //FROM zqu__ProductRatePlan__c
            //FROM Promotion_Package__c
            //from Promo_Eligibility_Rule_Product_Families__r
            //FROM Promotion_Eligibility_Rule__c 
            
        
            //Setup Parameters
            Id accId = accList[1].id;
            String action = 'Change';
            Map<String , Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
            Set<String> contractPeriod1 = new Set<String>();
            contractPeriod1.add(promoList[0].Contract_Period__c);
            contractPeriod1.add(promoList[1].Contract_Period__c);   
            contractPeriod1.add(promoList[2].Contract_Period__c);          
            promoCodeContractSet.put(promoList[0].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[1].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[2].Promotion_Code__c, contractPeriod1);
            
            String pkgCode = '';
            Id subsId = zSubList[0].id;
            Boolean booleanVar = False;
            
            Test.startTest();
            PromoEligibilityRule testObj = new PromoEligibilityRule();
            //public Map<String, Set<String>> result
            testObj.getEligibility(accId, action, promoCodeContractSet, pkgCode, subsId, booleanVar);  
            Test.stopTest();
        }
    
    }
    
    
    
    static testMethod void testGetEligibility_ExistingCustomer_Change_WithoutContract_Date01() {
    
        System.RunAs(TestDataFactory.prepareTestusers('Standard User')) {
        
            setCustomSettings();
            
            //Singpost_Address__c
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            Database.insert(postal);
    
            //Create Parent Account
            Account accParent = TestDataFactory.createAccount(1, 'Vendor')[0];
            Database.insert(accParent);
            
            //Create account
            List<Account> accList = TestDataFactory.createAccount(4, 'Vendor');
            accList[0]          = TestDataFactory.createAccount(1, 'Vendor')[0];
            accList[0].Name     = 'TEST1';
            accList[0].NRIC__c  = 'T1234567R';
            accList[0].ParentId = accParent.Id;
            
            accList[1]          = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[1].Name     = 'TEST2';
            accList[1].NRIC__c  = 'T1234567S';
            accList[1].ParentId = accParent.Id;
            
            accList[2]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[2].Name    = 'TEST3';
            accList[2].NRIC__c = 'T1234567T';
            accList[2].ParentId = accParent.Id;
            
            accList[3]         = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            accList[3].Name    = 'TEST4';
            accList[3].NRIC__c = 'T1234567U';
            accList[3].ParentId = accParent.Id;
            
            Database.insert(accList);
            
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            Database.insert(addressRec);
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.Address__c             = addressRec.Id;
            con.AccountId              = accList[1].Id;
            con.Recipient_Indicator__c = true;
            Database.insert(con);   
            
            //Create promo
            List<Promotion__c> promoList = TestDataFactory.createPromoList(3);
            for(Promotion__c promo : promoList) {
                promo.Effective_Start_Date__c    = Date.today();
                promo.Effective_End_Date__c      = Date.today().addDays(30);
                promo.Contract__c                = 'Yes';
                promo.Contract_Period__c         = '2';
                promo.Penalty_Charge__c          = '100';
                promo.Penalty_Charge_Override__c = 500.00;  
            }   
            promoList[0].Promotion_Code__c = 'yasyd97';
            promoList[1].Promotion_Code__c = 'yasyd97';
            promoList[2].Promotion_Code__c = 'yasyd99';
            Database.insert(promoList);
            
            //Create package
            List<Package__c> packList = TestDataFactory.createPackage(1);
            for(Package__c pack : packList) {
                pack.Package_Type__c                   = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
                pack.Billing_Type__c                   = 'Full Prepaid';
                pack.Package_Code__c                   = 'tempCode0';      
                pack.Product_Family_Current_Package__c = 'tmp0'; 
                pack.Effective_End_Date__c             = date.today().addDays(31);
                pack.Effective_Start_Date__c           = date.today();
                pack.Subscription_Period__c            = '1';
            }
            Database.insert(packList);
            
            //Create promotion package
            List<Promotion_Package__c> promotionPackageList = TestDataFactory.createPromotionPackage(4);
            promotionPackageList[0].Promotion__c    = promoList[0].Id;
            promotionPackageList[0].Package_Name__c = packList[0].Id;
            promotionPackageList[1].Promotion__c    = promoList[1].Id;
            promotionPackageList[1].Package_Name__c = packList[0].Id;
            promotionPackageList[2].Promotion__c    = promoList[2].Id;
            promotionPackageList[2].Package_Name__c = packList[0].Id;
            promotionPackageList[3].Promotion__c    = promoList[0].Id;
            promotionPackageList[3].Package_Name__c = packList[0].Id;
            Database.insert(promotionPackageList);
            
            //create product family      
            List<Product_Family__c> pfList = TestDataFactory.createProductFamily(1);
            Database.insert(pfList);
            
            //create eligibility rule
            List<Eligibility_Rule__c> erList = TestDataFactory.createEligibilityRule(5);
            for(Eligibility_Rule__c er : erList) {
                er.Product_Family__c             = pfList[0].Id;
                er.Effective_Start_Date__c       = Date.today();
                er.Effective_End_Date__c         = Date.today().addDays(30);
                er.Contract_Subscription_Rule__c = 'Contract End Date';
                er.Condition__c                  = '>';
            }    
            erList[0].Customer_Status__c   = 'Existing Customer';
            erList[0].Contract_Status__c   = 'Without Contract';
            erList[0].Action__c            = 'Change';
            
            erList[1].Customer_Status__c   = 'Existing Customer';
            erList[1].Contract_Status__c   = 'Without Contract';
            erList[1].Action__c            = 'Change';
                
            erList[2].Customer_Status__c   = 'Existing Customer';
            erList[2].Contract_Status__c   = 'Without Contract';
            erList[2].Action__c            = 'Change';
            
            erList[3].Customer_Status__c   = 'Existing Customer';
            erList[3].Contract_Status__c   = 'Without Contract';
            erList[3].Action__c            = 'Change';  
            
            erList[4].Customer_Status__c   = 'Existing customer';
            erList[4].Contract_Status__c   = 'Without Contract';
            erList[4].Action__c            = 'Change'; 
            Database.insert(erList);
            
            
            //create promotion eligibility rule
            List<Promotion_Eligibility_Rule__c> perList = TestDataFactory.createPromEligibilityRule(6);
            for(Promotion_Eligibility_Rule__c per : perList) {
                per.Product_Family__c   = 'tmp0';
                per.Package_List__c     = 'tempCode0';
                per.Prod_Family__c      = pfList[0].Id; 
                per.Current_Platform__c = 'Online';
                per.Date__c             = Date.today();
            }
            perList[0].Promotion__c        = promoList[0].Id;
            perList[0].Eligibility_Rule__c = erList[0].Id;
            perList[1].Promotion__c        = promoList[1].Id;
            perList[1].Eligibility_Rule__c = erList[1].Id;
            perList[2].Promotion__c        = promoList[0].Id;
            perList[2].Eligibility_Rule__c = erList[2].Id;
            perList[3].Promotion__c        = promoList[1].Id;
            perList[3].Eligibility_Rule__c = erList[3].Id;
            perList[4].Promotion__c        = promoList[0].Id;
            perList[4].Eligibility_Rule__c = erList[4].Id;
            perList[5].Promotion__c        = promoList[1].Id;
            perList[5].Eligibility_Rule__c = erList[1].Id;
            Database.insert(perList);
        
        
            //create promo eligibility rule product family
            List<Promo_Eligibility_Rule_Product_Family__c> perpfList = TestDataFactory.createPromoEligRuleProdFamily(1);
            perpfList[0].Product_Family__c             = pfList[0].Id;
            perpfList[0].Promotion_Eligibility_Rule__c = perList[0].Id;
            Database.insert(perpfList);
           
           
            //Billing Account
            //Create zoura customer account
            List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc[0].Zuora__Account__c              = accList[1].Id;
            billAcc[0].Billing_Type__c                = 'Full Prepaid';
            billAcc[0].Zuora__Credit_Balance__c       = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            Database.insert(billAcc);
            
        
            //Create order
            List<Order__c> odr = TestDataFactory.createOrder(1);
            odr[0].Account__c         = accList[1].Id;
    //      odr[0].Billing_Account__c = billAcc[0].Id;
            odr[0].Billing_Type__c    = 'Full Prepaid';
            Database.insert(odr);
        
        
            //Create zuora subscription 
            List<Zuora__Subscription__c> zSubList = TestDataFactory.createSubscription(6);
            for(Zuora__Subscription__c zSub: zSubList){
                zSub.Zuora__Account__c               = accList[1].id;
                zSub.Promotion_1__c                  = promoList[0].id;
                zSub.Zuora__CustomerAccount__c       = billAcc[0].Id;
                zSub.Order_Number__c                 = odr[0].id;
                zSub.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
                // NG - zSub.Zuora__SubscriptionEndDate__c   = Date.today().addDays(90);
                zSub.Term_Length__c                  = 3;     
                //zSub.Contract_End_Date_1__c        = Date.today().addDays(90);
                zSub.Contract_End_Date__c            = ''+Date.today().addDays(-90);
                zSub.Zuora__Status__c                = 'Active';
                zSub.Main_Package__c                 = packList[0].id;
            }
            
            zSubList[1].Promotion_1__c  = promoList[1].id;
            zSubList[1].Main_Package__c = packList[0].id;
            
            zSubList[2].Promotion_1__c  = promoList[2].id;
            zSubList[2].Main_Package__c = packList[0].id;
            
            zSubList[3].Promotion_1__c  = promoList[0].id;
                        
            zSubList[4].Promotion_1__c  = promoList[1].id;
            zSubList[4].Main_Package__c = packList[0].id;
                        
            zSubList[5].Promotion_1__c  = promoList[2].id;
                
            Database.insert(zSubList);
               
               
            //Create zuora subscription product charge
            List<Zuora__SubscriptionProductCharge__c> zSubProChargeList = TestDataFactory.createSubscriptionProductCharge(2);
            for(Zuora__SubscriptionProductCharge__c zSubProCharge : zSubProChargeList) {
                zSubProCharge.Zuora__Account__c       = accList[1].id;
                zSubProCharge.Zuora__Subscription__c  = zSubList[0].Id;
                zSubProCharge.Zuora__ProductSKU__c    = 'temp';
                zSubProCharge.Zuora__RatePlanName__c  = 'temp';
                zSubProCharge.Zuora__ProductName__c   = 'temp';
                zSubProCharge.Zuora__Quantity__c      = 15.3;
                zSubProCharge.Product_Code__c         = 'churva';
                zSubProCharge.Zuora__Price__c         = 100.00;
                zSubProCharge.Zuora__BillingPeriod__c = 'First';
            }
            Database.insert(zSubProChargeList); 
            
        
            //Create zuora zProduct
            List<zqu__ZProduct__c> zProductList = TestDataFactory.createZProduct(1);
            for(zqu__ZProduct__c zProduct : zProductList) {
                zProduct.ProductCode__c     = 'churva';
                zProduct.zqu__SKU__c        = zSubProChargeList[0].Zuora__ProductSKU__c;
                zProduct.ProductPlatform__c = 'Online';
            }
            Database.insert(zProductList);
        
        
            //Create product rate plan
            List<zqu__ProductRatePlan__c> productRatePlanList = TestDataFactory.createProductRatePlan(1);
            for(zqu__ProductRatePlan__c productRatePlan : productRatePlanList) {
                productRatePlan.Name             = zSubProChargeList[0].Zuora__RatePlanName__c;
                productRatePlan.zqu__ZProduct__c = zProductList[0].Id;
            }
            Database.insert(productRatePlanList);
            
            //Publication
            List<Publication__c> publicationList = TestDataFactory.createPublication(1);
            publicationList[0].Product_Family_Lookup__c = pfList[0].Id;
            Database.insert(publicationList);
            
        
            //FROM Subscription_Vendor__c WHERE Account__c =: acct.Parent.Id AND Status__c = 'Active'
            //Subscription_Vendor__c 
            List<Subscription_Vendor__c> subsVendorList = TestDataFactory.createSubscriptionVendor(1);
            for(Subscription_Vendor__c subsVendor : subsVendorList) {
                subsVendor.Account__c = accParent.id;
                subsVendor.Status__c = 'Active';
            }
            Database.insert(subsVendorList);
        
            //Subscription_Vendor_Publications__c
            List<Subscription_Vendor_Publication__c> subsVendorPubList = new List<Subscription_Vendor_Publication__c>();
            subsVendorPubList.add(new Subscription_Vendor_Publication__c());
            for(Subscription_Vendor_Publication__c subsVendorPub : subsVendorPubList) {
                subsVendorPub.Publication__c         = publicationList[0].id;
                subsVendorPub.Subscription_Vendor__c = subsVendorList[0].id;
            }
            Database.insert(subsVendorPubList);
            
            
            
            //Promo_Eligibility_Rule_Product_Family__c
            List<Promo_Eligibility_Rule_Product_Family__c> promoEligRuleProdFamList = new List<Promo_Eligibility_Rule_Product_Family__c>();
            Promo_Eligibility_Rule_Product_Family__c promoEligRuleProdFam1 = new Promo_Eligibility_Rule_Product_Family__c();
            promoEligRuleProdFam1.Product_Family__c             = pfList[0].id;
            promoEligRuleProdFam1.Promotion_Eligibility_Rule__c = perList[0].id;
            promoEligRuleProdFamList.add(promoEligRuleProdFam1);
            Database.insert(promoEligRuleProdFamList);
            
            //FROM Zuora__Subscriptions__r
            //FROM Account
            //FROM Subscription_Vendor__c
            //FROM Promotion__c
            //FROM Zuora__Subscription__c
            //FROM Zuora__SubscriptionProductCharge__c
            //FROM zqu__ProductRatePlan__c
            //FROM Promotion_Package__c
            //from Promo_Eligibility_Rule_Product_Families__r
            //FROM Promotion_Eligibility_Rule__c 
            
        
            //Setup Parameters
            Id accId = accList[1].id;
            String action = 'Change';
            Map<String , Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
            Set<String> contractPeriod1 = new Set<String>();
            contractPeriod1.add(promoList[0].Contract_Period__c);
            contractPeriod1.add(promoList[1].Contract_Period__c);   
            contractPeriod1.add(promoList[2].Contract_Period__c);          
            promoCodeContractSet.put(promoList[0].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[1].Promotion_Code__c, contractPeriod1);
            promoCodeContractSet.put(promoList[2].Promotion_Code__c, contractPeriod1);
            
            String pkgCode = '';
            Id subsId = zSubList[0].id;
            Boolean booleanVar = False;
            
            Test.startTest();
            PromoEligibilityRule testObj = new PromoEligibilityRule();
            //public Map<String, Set<String>> result
            testObj.getEligibility(accId, action, promoCodeContractSet, pkgCode, subsId, booleanVar);  
            Test.stopTest();
        }
    
    }

}