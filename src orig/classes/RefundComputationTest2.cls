@isTest
private class RefundComputationTest2{
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther();
    }

    static testmethod void unitTest(){
    
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardOP43@test.com'
        );
        
        System.runAs(u){    
            //Create Account
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'Test Account';
            insert acc;
            
            //Create Contact   
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = acc.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Grace Period';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '1';
            pack.Effective_Start_Date__c = Date.today();
            pack.Effective_End_Date__c = Date.today().addDays(5);
            insert pack;
            
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            zProd.ProductPlatform__c = 'All-In-One';
            zProd.zqu__SKU__c = 'PRODUCT RATE PLAN';
            insert zProd;
            
            List<zqu__ProductRatePlan__c> prps = TestDataFactory.createProductRatePlan(2);
            for(zqu__ProductRatePlan__c prp: prps)
            {     
                prp.Name = 'PRODUCT RATE PLAN';   
                prp.zqu__ZProduct__c = zProd.Id;
                prp.SubscriptionFrequency__c = '1';
                prp.RatePlanType__c = 'Proration';
                prp.RatePlanSubType__c = 'Standard';
                prp.zqu__Deleted__c = false;
            }
            insert prps;        
            
            Product_Family__c prodFam = new Product_Family__c();
            prodFam.Product_Family__c = 'Sample Family';
            insert prodFam;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.Id;
            packItem.Product_Rate_Plan__c = prps[0].Id;
            packItem.Product_Family__c = prodFam.id;
            insert packItem;   
            
            Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
            bill.Zuora__Account__c = acc.Id;
            insert bill; 
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.id;
            order.Delivery_Charge__c = 20; 
            order.Recipient_Contact__c = con.id;
            order.Subscriber_Charge__c = 15;
            insert order;
            
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Earliest_Start_Date__c = Date.today();
            oli.Start_Date__c = Date.today()+7;
            oli.Order__c = Order.id;
            oli.Main_Package_Period__c = 2;
            oli.Qty__c = 3;
            oli.Term_Length__c = 5;
            oli.Main_Package_ID__c = Pack.id;  
            oli.Main_Package_Frequency__c = 'Default';
            insert oli;
            
            List <Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(1);
            //Zuora__Subscription__c Subs = new Zuora__Subscription__c();
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Name= 'CS0000000110';
            zSubs[0].Number_of_Copies__c= 10;
            zSubs[0].Zuora__CustomerAccount__c = bill.id;
            zSubs[0].Next_Earliest_Start_Date__c= date.today();
            zSubs[0].Unique_Address_Id__c= 'asdasdasd';
            zSubs[0].Year_to_Date_Temp_Stop_Days__c= 2;
            zSubs[0].Previous_Year_Temp_Stop_Days__c= 2;
            zSubs[0].Legacy_Create_Date__c='2014-08-07';
            zSubs[0].Legacy_Create_By__c='test';
            zSubs[0].Legacy_Update_Date__c='test';
            zSubs[0].Legacy_Update_By__c='test';
            zSubs[0].Legacy_Subscription_ID__c='test';
            zSubs[0].Cheque_details__c='test';
            zSubs[0].DTL__c='test';
            zSubs[0].Paypal_Payment_Profile_Id__c='test';
            zSubs[0].Pub_Tag__c='test';
            zSubs[0].Subscribe_As__c='test';
            zSubs[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            zSubs[0].Zuora__SubscriptionEndDate__c = date.today().addDays(2);
            zSubs[0].Subscription_Grace_Period_End_Date__c= 'test';
            zSubs[0].Gift_ID__c= 'test';
            zSubs[0].Redeem_Date__c= 'test';
            zSubs[0].Gift_ID_2__c= 'test';
            zSubs[0].Redeem_Date_2__c= 'test';
            zSubs[0].Subscriber_Contact__c= con.Id;
            zSubs[0].Recipient_Contact__c= con.Id;
            zSubs[0].Subscription_Charge__c= 223.0;
            zSubs[0].Term_Length__c= 2;
            zSubs[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
            zSubs[0].Main_Package__c = pack.id;
            zSubs[0].Main_Package_1__c = pack.id;
            zSubs[0].Billing_Type__c = 'Recurring Prepaid';
            zSubs[0].Delivered_By_1__c = 'Mailing Agent';
            zSubs[0].Order_Line_Item_Number__c =  oli.id; 
            zSubs[0].Order_Line_Item_Number_1__c =  oli.id;
            //zSubs.add(Subs);
            insert zSubs; 
            
            Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubProductCharge(1)[0];    
            subProdCharge.Name = 'Credit Copy Sat';
            subProdCharge.PublicationCode__c = 'BH';
            subProdCharge.Zuora__Subscription__c = zSubs[0].id;
            subProdCharge.Zuora__UOM__c = 'Credit Copy Sat';
            subProdCharge.Zuora__Quantity__c = 5;
            subProdCharge.Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge.Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            subProdCharge.Zuora__Model__c = GlobalVariableClass.SPC_MODEL_DISCOUNT;
            subProdCharge.Zuora__ProductName__c = 'discount';
            subProdCharge.Zuora__EffectiveStartDate__c = Date.today().addDays(2);
            insert subProdCharge;
            
            zqu__ProductRatePlanCharge__c zProdRate = TestDataFactory.createProductRatePlanCharge(1)[0];
            zProdRate.PublicationCode__c = 'BH';
            zProdRate.zqu__ProductRatePlan__c = prps[0].id;
            insert zProdRate;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'BH';
            pub.Platform_Type__c = 'Print';
            pub.Publication_Type__c = 'M';
            insert pub;
            
            Non_Publication_Day__c nonPub = TestDataFactory.createNonPublicationDay(1)[0];
            nonPub.Publication_Code__c = 'BH';
            nonPub.Publication__c = pub.id;
            insert nonPub;
            
            Test.startTest();
            RefundComputation.ProductSKU = 'PRODUCT RATE PLAN';
            Decimal refund = RefundComputation.computeRefund(zSubs[0].id, Date.today());
            Boolean retVal = RefundComputation.checkTempStop(Date.today());
            //Date dt = RefundComputation.getLastDayOfTheMonth(Date.today());
            Test.stopTest();
        }
    }
    
    static testmethod void unitTest2(){
    
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardJK72@test.com'
        );
        
        System.runAs(u){    
            //Create Account
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'Test Account';
            insert acc;
            
            //Create Contact   
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = acc.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Grace Period';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '1';
            pack.Effective_Start_Date__c = Date.today();
            pack.Effective_End_Date__c = Date.today().addDays(5);
            insert pack;
            
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            zProd.ProductPlatform__c = 'All-In-One';
            zProd.zqu__SKU__c = 'PRODUCT RATE PLAN';
            insert zProd;
            
            List<zqu__ProductRatePlan__c> prps = TestDataFactory.createProductRatePlan(2);
            for(zqu__ProductRatePlan__c prp: prps)
            {     
                prp.Name = 'PRODUCT RATE PLAN';   
                prp.zqu__ZProduct__c = zProd.Id;
                prp.SubscriptionFrequency__c = '1';
                prp.RatePlanType__c = 'Proration';
                prp.RatePlanSubType__c = 'Standard';
                prp.zqu__Deleted__c = false;
            }
            insert prps;        
            
            Product_Family__c prodFam = new Product_Family__c();
            prodFam.Product_Family__c = 'Sample Family';
            insert prodFam;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.Id;
            packItem.Product_Rate_Plan__c = prps[0].Id;
            packItem.Product_Family__c = prodFam.id;
            insert packItem;   
            
            Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
            bill.Zuora__Account__c = acc.Id;
            insert bill; 
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.id;
            order.Delivery_Charge__c = 20; 
            order.Recipient_Contact__c = con.id;
            order.Subscriber_Charge__c = 15;
            insert order;
            
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Earliest_Start_Date__c = Date.today();
            oli.Start_Date__c = Date.today()+7;
            oli.Order__c = Order.id;
            oli.Main_Package_Period__c = 2;
            oli.Qty__c = 3;
            oli.Term_Length__c = 5;
            oli.Main_Package_ID__c = Pack.id;  
            oli.Main_Package_Frequency__c = 'Default';
            insert oli;
            
            List <Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(1);
            //Zuora__Subscription__c Subs = new Zuora__Subscription__c();
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Name= 'CS0000000110';
            zSubs[0].Number_of_Copies__c= 10;
            zSubs[0].Zuora__CustomerAccount__c = bill.id;
            zSubs[0].Next_Earliest_Start_Date__c= date.today();
            zSubs[0].Unique_Address_Id__c= 'asdasdasd';
            zSubs[0].Year_to_Date_Temp_Stop_Days__c= 2;
            zSubs[0].Previous_Year_Temp_Stop_Days__c= 2;
            zSubs[0].Legacy_Create_Date__c='2014-08-07';
            zSubs[0].Legacy_Create_By__c='test';
            zSubs[0].Legacy_Update_Date__c='test';
            zSubs[0].Legacy_Update_By__c='test';
            zSubs[0].Legacy_Subscription_ID__c='test';
            zSubs[0].Cheque_details__c='test';
            zSubs[0].DTL__c='test';
            zSubs[0].Paypal_Payment_Profile_Id__c='test';
            zSubs[0].Pub_Tag__c='test';
            zSubs[0].Subscribe_As__c='test';
            zSubs[0].Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
            zSubs[0].Zuora__SubscriptionEndDate__c = Date.today()+1;
            zSubs[0].Subscription_Grace_Period_End_Date__c= 'test';
            zSubs[0].Gift_ID__c= 'test';
            zSubs[0].Redeem_Date__c= 'test';
            zSubs[0].Gift_ID_2__c= 'test';
            zSubs[0].Redeem_Date_2__c= 'test';
            zSubs[0].Subscriber_Contact__c= con.Id;
            zSubs[0].Recipient_Contact__c= con.Id;
            zSubs[0].Subscription_Charge__c= 223.0;
            zSubs[0].Term_Length__c = 2.0;
            zSubs[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
            zSubs[0].Main_Package__c = pack.id;
            zSubs[0].Main_Package_1__c = pack.id;
            zSubs[0].Billing_Type__c = 'Full Prepaid';
            zSubs[0].Delivered_By_1__c = 'Mailing Agent';
            zSubs[0].Zuora__TermSettingType__c = GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED;
            zSubs[0].Order_Line_Item_Number__c =  oli.id; 
            zSubs[0].Order_Line_Item_Number_1__c =  oli.id;
            //zSubs.add(Subs);
            insert zSubs;

            
            Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubProductCharge(1)[0];    
            subProdCharge.Name = 'Credit Copy Sat';
            subProdCharge.PublicationCode__c = 'BH';
            subProdCharge.Zuora__Subscription__c = zSubs[0].id;
            subProdCharge.Zuora__UOM__c = 'Credit Copy Sat';
            subProdCharge.Zuora__Quantity__c = 5;
            subProdCharge.Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge.Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            subProdCharge.Zuora__Model__c = GlobalVariableClass.SPC_MODEL_DISCOUNT;
            subProdCharge.Zuora__ProductName__c = 'discount';
            subProdCharge.Zuora__EffectiveStartDate__c = Date.today().addDays(2);
            insert subProdCharge;
            
            zqu__ProductRatePlanCharge__c zProdRate = TestDataFactory.createProductRatePlanCharge(1)[0];
            zProdRate.PublicationCode__c = 'BH';
            zProdRate.zqu__ProductRatePlan__c = prps[0].id;
            insert zProdRate;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'BH';
            pub.Platform_Type__c = 'Online';
            pub.Publication_Type__c = 'M';
            insert pub;
            
            List<Publication__c> pubList = new List<Publication__c>();
            pubList.add(pub);
            
            Non_Publication_Day__c nonPub = TestDataFactory.createNonPublicationDay(1)[0];
            nonPub.Publication_Code__c = 'BH';
            nonPub.Publication__c = pub.id;
            insert nonPub;
            
            Test.startTest();
            RefundComputation.ProductSKU = 'PRODUCT RATE PLAN';
            try
            {
                Decimal refund = RefundComputation.computeRefund(zSubs[0].id, zSubs[0].Zuora__SubscriptionStartDate__c+1);
                refund = RefundComputation.computeDiscount(pubList, Date.today().addDays(1), Date.today().addDays(9));
                Boolean retVal = RefundComputation.checkTempStop(Date.today());
            }catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
            
            //Date dt = RefundComputation.getLastDayOfTheMonth(Date.today());
            Test.stopTest();
        }
    }
    
    static testmethod void unitTest3(){
    
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardYU12@test.com'
        );
        
        System.runAs(u){    
            //Create Account
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'Test Account';
            insert acc;
            
            //Create Contact   
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = acc.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Grace Period';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '1';
            pack.Effective_Start_Date__c = Date.today();
            pack.Effective_End_Date__c = Date.today().addDays(5);
            insert pack;
            
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            zProd.ProductPlatform__c = 'All-In-One';
            zProd.zqu__SKU__c = 'PRODUCT RATE PLAN';
            insert zProd;
            
            List<zqu__ProductRatePlan__c> prps = TestDataFactory.createProductRatePlan(2);
            for(zqu__ProductRatePlan__c prp: prps)
            {     
                prp.Name = 'PRODUCT RATE PLAN';   
                prp.zqu__ZProduct__c = zProd.Id;
                prp.SubscriptionFrequency__c = '1';
                prp.RatePlanType__c = 'Proration';
                prp.RatePlanSubType__c = 'Standard';
                prp.zqu__Deleted__c = false;
            }
            insert prps;        
            
            Product_Family__c prodFam = new Product_Family__c();
            prodFam.Product_Family__c = 'Sample Family';
            insert prodFam;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.Id;
            packItem.Product_Rate_Plan__c = prps[0].Id;
            packItem.Product_Family__c = prodFam.id;
            insert packItem;   
            
            Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
            bill.Zuora__Account__c = acc.Id;
            insert bill; 
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.id;
            order.Delivery_Charge__c = 20; 
            order.Recipient_Contact__c = con.id;
            order.Subscriber_Charge__c = 15;
            insert order;
            
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Earliest_Start_Date__c = Date.today();
            oli.Start_Date__c = Date.today()+7;
            oli.Order__c = Order.id;
            oli.Main_Package_Period__c = 2;
            oli.Qty__c = 3;
            oli.Term_Length__c = 5;
            oli.Main_Package_ID__c = Pack.id;  
            oli.Main_Package_Frequency__c = 'Default';
            insert oli;
            
            List <Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(1);
            //Zuora__Subscription__c Subs = new Zuora__Subscription__c();
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Name= 'CS0000000110';
            zSubs[0].Number_of_Copies__c= 10;
            zSubs[0].Zuora__CustomerAccount__c = bill.id;
            zSubs[0].Next_Earliest_Start_Date__c= date.today();
            zSubs[0].Unique_Address_Id__c= 'asdasdasd';
            zSubs[0].Year_to_Date_Temp_Stop_Days__c= 2;
            zSubs[0].Previous_Year_Temp_Stop_Days__c= 2;
            zSubs[0].Legacy_Create_Date__c='2014-08-07';
            zSubs[0].Legacy_Create_By__c='test';
            zSubs[0].Legacy_Update_Date__c='test';
            zSubs[0].Legacy_Update_By__c='test';
            zSubs[0].Legacy_Subscription_ID__c='test';
            zSubs[0].Cheque_details__c='test';
            zSubs[0].DTL__c='test';
            zSubs[0].Paypal_Payment_Profile_Id__c='test';
            zSubs[0].Pub_Tag__c='test';
            zSubs[0].Subscribe_As__c='test';
            zSubs[0].Zuora__SubscriptionStartDate__c = date.today().addDays(1);
            zSubs[0].Zuora__SubscriptionEndDate__c = date.today().addDays(2);
            zSubs[0].Subscription_Grace_Period_End_Date__c= 'test';
            zSubs[0].Gift_ID__c= 'test';
            zSubs[0].Redeem_Date__c= 'test';
            zSubs[0].Gift_ID_2__c= 'test';
            zSubs[0].Redeem_Date_2__c= 'test';
            zSubs[0].Subscriber_Contact__c= con.Id;
            zSubs[0].Recipient_Contact__c= con.Id;
            zSubs[0].Subscription_Charge__c= 223.0;
            zSubs[0].Term_Length__c= 2;
            zSubs[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
            zSubs[0].Main_Package__c = pack.id;
            zSubs[0].Main_Package_1__c = pack.id;
            zSubs[0].Billing_Type__c = 'Recurring Prepaid';
            zSubs[0].Delivered_By_1__c = 'Mailing Agent';
            zSubs[0].Order_Line_Item_Number__c =  oli.id; 
            zSubs[0].Order_Line_Item_Number_1__c =  oli.id;
            //zSubs.add(Subs);
            insert zSubs;

            
            Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubProductCharge(1)[0];    
            subProdCharge.Name = 'Credit Copy Sat';
            subProdCharge.PublicationCode__c = 'BH';
            subProdCharge.Zuora__Subscription__c = zSubs[0].id;
            subProdCharge.Zuora__UOM__c = 'Credit Copy Sat';
            subProdCharge.Zuora__Quantity__c = 5;
            subProdCharge.Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge.Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            subProdCharge.Zuora__Model__c = GlobalVariableClass.SPC_MODEL_DISCOUNT;
            subProdCharge.Zuora__ProductName__c = 'discount';
            subProdCharge.Zuora__EffectiveStartDate__c = Date.today().addDays(2);
            insert subProdCharge;
            
            zqu__ProductRatePlanCharge__c zProdRate = TestDataFactory.createProductRatePlanCharge(1)[0];
            zProdRate.PublicationCode__c = 'BH';
            zProdRate.zqu__ProductRatePlan__c = prps[0].id;
            insert zProdRate;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Publication_Code__c = 'BH';
            pub.Platform_Type__c = 'All in One (AIO)';
            pub.Publication_Type__c = 'M';
            insert pub;
                        
            Non_Publication_Day__c nonPub = TestDataFactory.createNonPublicationDay(1)[0];
            nonPub.Publication_Code__c = 'BH';
            nonPub.Publication__c = pub.id;
            insert nonPub;
            
            Test.startTest();
            RefundComputation.ProductSKU = 'PRODUCT RATE PLAN';
            Decimal refund = RefundComputation.computeRefund(zSubs[0].id, Date.today());
            Boolean retVal = RefundComputation.checkTempStop(Date.today());
            //Date dt = RefundComputation.getLastDayOfTheMonth(Date.today());
            Test.stopTest();
        }
    }
    
    static testMethod void testFullPrepaid(){
      
           //Create SingPost Address
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            zone.name = '10';
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            //country.Name = 'SINGAPORE';
            //country.Country_Name__c = 'SINGAPORE';
            //country.Code__c = 'SG';
            country.Zone__c = zone.Id;
            insert country;
            
            //Create Address
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '30';
            add.Unit_Number__c = '13';
            add.Country__c = country.Id;
            insert add;
            
            //Create Account
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'Test Account';
            acc.AccountNumber = '';
            insert acc;
            
            //Create Contact   
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = acc.id;
            con.Address__c = add.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.id;
            order.Delivery_Charge__c = 20; 
            order.Recipient_Contact__c = con.id;
            order.Subscriber_Charge__c = 15;
            insert order;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Base';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '12';
            pack.Effective_Start_Date__c = date.today();
            pack.Effective_End_Date__c = date.today() + 5;
            insert pack;
            
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Earliest_Start_Date__c = date.today();
            oli.Start_Date__c = date.today()+7;
            oli.Order__c = order.id;
            oli.Main_Package_Period__c = 2;
            oli.Qty__c = 3;
            oli.Term_Length__c = 5;
            oli.Main_Package_ID__c = pack.id;  
            insert oli;
            
            Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
            bill.Zuora__Account__c = acc.Id;
            insert bill;    
            
            //Create Zuora Subscription    
            List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(2);
            
            for(Zuora__Subscription__c zSub: zSubs)
            {
                zSub.Subscriber_Contact__c = con.Id;
                zSub.Recipient_Contact__c = con.Id;
                zSub.Recipient_Contact_1__c = con.Id;    
                zSub.Contact__c = con.Id;
                zSub.Zuora__Account__c = acc.id;
                zSub.Order_Number_1__c = order.Id;
                zSub.Order_Line_Item_Number__c =  oli.id; 
                zSub.Order_Line_Item_Number_1__c =  oli.id;
                zSub.Frequency__c = 'Default';    
                zSub.Frequency_1__c = 'Default';
                zSub.Number_of_Copies__c = 1;
                zSub.Number_of_Copies1__c = '1';
                zSub.Zuora__SubscriptionStartDate__c = date.today().addDays(1);
                zSub.Subscription_End_Date__c = String.valueOf(date.today()+5);
                zSub.Main_Package__c = pack.id;
                zSub.Main_Package_1__c = pack.id;
                zSub.Zuora__SubscriptionEndDate__c = date.today() +5;
                zSub.Zuora__CustomerAccount__c = bill.Id;
                zSub.Subscription_Charge__c = 30;
                zSub.Billing_Type__c = 'Full Prepaid';
                zSub.Delivered_By__c = 'Mailing Agent'; 
                zSub.Delivered_By_1__c = 'Mailing Agent';
                zSub.Postage_Charge__c = 20;
                zSub.Qty__c = 1;
                zSub.Qty1__c = '1';
                zSub.Zuora__CustomerAccount__c = bill.id;
            }
            zSubs[0].Name = 'BA-S00002264';
            zSubs[1].Name = 'BA-S12342264'; 
            zSubs[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
            zSubs[1].Subscription_Type__c = 'Delivery';
            insert zSubs;    
            
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            zProd.Name = 'THE STRAITS TIMES PRINT TEST';
            zProd.zqu__SKU__c = 'SKU-12345678';
            zProd.ProductCode__c = 'TEST';
            zProd.ProductType__c = 'Product';
            zProd.ProductPlatform__c = 'Print';
            zProd.ProductFamily__c = 'ST';
            zProd.ProductSubType__c = 'Newspaper';
            insert zProd;
            
            List<zqu__ProductRatePlan__c> prps = TestDataFactory.createProductRatePlan(2);
            for(zqu__ProductRatePlan__c prp: prps)
            { 
                prp.zqu__ZProduct__c = zProd.Id;
                prp.SubscriptionFrequency__c = '1';
            }
            prps[0].RatePlanCode__c = 'STEST13TS';
            prps[0].Name = 'PRODUCT RATE PLAN TEST';
            prps[0].RatePlanType__c = 'Bill Plan';
            
            prps[1].RatePlanCode__c = 'STEST15TS';
            prps[1].Name = 'PRODUCT RATE PLAN';
            prps[1].RatePlanType__c = 'Proration';
            prps[1].RatePlanSubType__c = 'Standard';
            insert prps;        
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.Id;
            packItem.Product_Rate_Plan__c = prps[0].Id;
            insert packItem;   
            
            Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubProductCharge(1)[0];    
            subProdCharge.Name = 'Credit Copy Sat';
            subProdCharge.PublicationCode__c = 'BH';
            subProdCharge.Zuora__Subscription__c = zSubs[1].id;
            subProdCharge.Zuora__UOM__c = 'Credit Copy Sat';
            subProdCharge.Zuora__Quantity__c = 5;
            subProdCharge.Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge.Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            insert subProdCharge;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Beat Harry';    
            pub.Publication_Code__c = 'BHAO';
            pub.Published_Days__c = 'YYYYYYN';
            pub.Publication_Type__c = 'N';
            pub.Frequency_Code__c = 'D';
            insert pub;
                    
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prps[1].id;
            prpc.PublicationCode__c = 'BHAO';
            prpc.zqu__UOM__c = 'Credit Copy Sat';
            insert prpc;    
            
            Non_Publication_Day__c npub = new Non_Publication_Day__c();
            npub.Publication__c = pub.id;
            npub.Publication_Code__c = 'BHAO';
            npub.Non_Publication_Date__c = date.today();
            insert npub;
            
            Test.startTest();
            Decimal refund = RefundComputation.computeRefund(zSubs[0].Id, system.today());
            RefundComputation.getLastDayOfTheMonth(date.today());
            System.debug('>>Refund Full Prepaid: ' + refund);
            Test.stopTest();
            System.assert(refund != null);
        }
        
        static testMethod void testRecurringPrepaid(){
      
            //Create SingPost Address
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            zone.name = '10';
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            //country.Name = 'SINGAPORE';
            //country.Country_Name__c = 'SINGAPORE';
            //country.Code__c = 'AU';
            country.Zone__c = zone.Id;
            insert country;
            
            //Create Address
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '30';
            add.Unit_Number__c = '13';
            add.Country__c = country.Id;
            insert add;
            
            //Create Account
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'Test Account';
            acc.AccountNumber = '';
            insert acc;
            
            //Create Contact   
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = acc.id;
            con.Address__c = add.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.id;
            order.Delivery_Charge__c = 20; 
            order.Recipient_Contact__c = con.id;
            order.Subscriber_Charge__c = 15;
            insert order;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Base';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '12';
            pack.Effective_Start_Date__c = date.today();
            pack.Effective_End_Date__c = date.today() + 5;
            insert pack;
            
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Earliest_Start_Date__c = date.today();
            oli.Start_Date__c = date.today()+7;
            oli.Order__c = order.id;
            oli.Main_Package_Period__c = 2;
            oli.Qty__c = 3;
            oli.Term_Length__c = 5;
            oli.Main_Package_ID__c = pack.id;  
            insert oli;
            
            Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
            bill.Zuora__Account__c = acc.Id;
            insert bill;    
            
            //Create Zuora Subscription    
            List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(2);
            
            for(Zuora__Subscription__c zSub: zSubs)
            {
                zSub.Subscriber_Contact__c = con.Id;
                zSub.Recipient_Contact__c = con.Id;
                zSub.Recipient_Contact_1__c = con.Id;    
                zSub.Contact__c = con.Id;
                zSub.Zuora__Account__c = acc.id;
                zSub.Order_Number_1__c = order.Id;
                zSub.Order_Line_Item_Number__c =  oli.id; 
                zSub.Order_Line_Item_Number_1__c =  oli.id;
                zSub.Frequency__c = 'Default';    
                zSub.Frequency_1__c = 'Default';
                zSub.Number_of_Copies__c = 1;
                zSub.Number_of_Copies1__c = '1';
                zSub.Zuora__SubscriptionStartDate__c = date.today().addDays(1);
                zSub.Subscription_End_Date__c = String.valueOf(date.today()+5);
                zSub.Main_Package__c = pack.id;
                zSub.Main_Package_1__c = pack.id;
                zSub.Zuora__SubscriptionEndDate__c = date.today() +5;
                zSub.Zuora__CustomerAccount__c = bill.Id;
                zSub.Subscription_Charge__c = 30;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                zSub.Delivered_By__c = 'Mailing Agent'; 
                zSub.Delivered_By_1__c = 'Mailing Agent';
                zSub.Postage_Charge__c = 20;
                zSub.Zuora__CustomerAccount__c = bill.id;
            }
            zSubs[0].Name = 'BA-S00002264';
            zSubs[1].Name = 'BA-S12342264'; 
            zSubs[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
            zSubs[1].Subscription_Type__c = 'Delivery';
            zSubs[0].Delivery_Charge__c = 20;
            zSubs[1].Delivery_Charge__c = 20;
            insert zSubs;    
            
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            zProd.Name = 'THE STRAITS TIMES PRINT TEST';
            zProd.zqu__SKU__c = 'SKU-12345678';
            zProd.ProductCode__c = 'TEST';
            zProd.ProductType__c = 'Product';
            zProd.ProductPlatform__c = 'Print';
            zProd.ProductFamily__c = 'ST';
            zProd.ProductSubType__c = 'Newspaper';
            insert zProd;
            
            List<zqu__ProductRatePlan__c> prps = TestDataFactory.createProductRatePlan(2);
            for(zqu__ProductRatePlan__c prp: prps)
            { 
                prp.zqu__ZProduct__c = zProd.Id;
                prp.SubscriptionFrequency__c = '0';
            }
            prps[0].RatePlanCode__c = 'STEST13TS';
            prps[0].Name = 'PRODUCT RATE PLAN TEST';
            prps[0].RatePlanType__c = 'Bill Plan';
            
            prps[1].RatePlanCode__c = 'STEST15TS';
            prps[1].Name = 'PRODUCT RATE PLAN';
            prps[1].RatePlanType__c = 'Proration';
            prps[1].RatePlanSubType__c = 'Standard';
            insert prps;        
    
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.Id;
            packItem.Product_Rate_Plan__c = prps[0].Id;
            insert packItem;   
            
            Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubProductCharge(1)[0];    
            subProdCharge.Name = 'Credit Copy Sat';
            subProdCharge.PublicationCode__c = 'BH';
            subProdCharge.Zuora__Subscription__c = zSubs[1].id;
            subProdCharge.Zuora__UOM__c = 'Credit Copy Sat';
            subProdCharge.Zuora__Quantity__c = 5;
            subProdCharge.Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge.Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            insert subProdCharge;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Beat Harry';    
            pub.Publication_Code__c = 'BHAO';
            pub.Published_Days__c = 'YYYYYYN';
            pub.Publication_Type__c = 'N';
            pub.Frequency_Code__c = 'D';
            insert pub;
                    
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prps[1].id;
            prpc.PublicationCode__c = 'BHAO';
            prpc.zqu__UOM__c = 'Credit Copy Sat';
            insert prpc;    
            
            Non_Publication_Day__c npub = new Non_Publication_Day__c();
            npub.Publication__c = pub.id;
            npub.Publication_Code__c = 'BHAO';
            npub.Non_Publication_Date__c = date.today();
            insert npub;
            
            Test.startTest();
            
            Decimal refund = RefundComputation.computeRefund(zSubs[0].Id, system.today());
            RefundComputation.getLastDayOfTheMonth(date.today());
            System.debug('>>Refund Recurring: ' + refund);
            Test.stopTest();
            System.assert(refund != null);
        } 
}