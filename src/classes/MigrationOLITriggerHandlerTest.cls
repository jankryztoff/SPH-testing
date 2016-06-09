@IsTest (seeAllData = True)
private class MigrationOLITriggerHandlerTest {

            static Account testAccount;
            static Order__c testOrder;  
            static Order_Line_Item__c testOrderLineItem;
            static Package__c testPackage;
            static Package_Item__c testPackageItem; 
            static zqu__ProductRatePlan__c testProductRatePlan;
            static zqu__ZProduct__c testZProduct;
            static Product_Family__c testProductFamily;
            
    static testmethod void testOrderLineItem()
    {
            testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert testAccount;
            
            testProductFamily = new Product_Family__c();
            testProductFamily.Product_Family__c = 'testproductfamilysample';
            insert testProductFamily;
            
            testZProduct =  TestDataFactory.createZProduct(1)[0];
            testZProduct.ProductPlatform__c = 'Online';
            testZProduct.ProductSubType__c = 'Magazine';
            insert testZProduct;
            
            testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.zqu__ZProduct__c = testZProduct.Id;
            testProductRatePlan.SubscriptionFrequency__c = '1';
            testProductRatePlan.RatePlanType__c = 'Proration';
            insert testProductRatePlan;
            
            testPackage = TestDataFactory.createPackage(1)[0];
            testPackage.Package_Price__c = 10;
            testPackage.Platform__c = 'test';
            testPackage.Subscription_Period__c = '1';
            testPackage.Subscription_Type__c = 'Termed';
            testPackage.Package_Type__c = 'Grace Period';
            insert testPackage;
            
            testPackageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            testPackageItem.Product_Rate_Plan__c = testProductRatePlan.Id;
            testPackageItem.Product_Family__c = testProductFamily.Id;
            testPackageItem.Package__c = testPackage.Id;
            insert testPackageItem;
            
            testOrder = TestDataFactory.createOrder(1)[0];
            testOrder.Account__c = testAccount.Id; 
            testOrder.Credit_Balance__c = 100.00;
            testOrder.Delivery_Charge__c = 100.00;
            insert testOrder;

            testOrderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            testOrderLineItem.Order_Line_Item_Legacy_Id__c = 'IANGAJKERNGIE';
            testOrderLineItem.Asia_1_creation_mode__c = 'Individual';
            testOrderLineItem.Ph_d__c = True;
            testOrderLineItem.Ph_e__c = True;
            testOrderLineItem.Main_Package_ID__c = testPackage.Id;
            testOrderLineItem.Order__c = testOrder.Id;
            insert testOrderLineItem; 
            
            //testPackageItem = [Select Id, Name, Is_Digital__c, Product_Family__r.Name, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.SubscriptionFrequency__c, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c FROM Package_Item__c];
            
           // testPackage = [Select Id, Subscription_Period__c, Package_Price__c, Platform__c, Subscription_Type__c, 
                         // Package_Type__c 
                         // From Package__c ];
            
            Test.startTest();
            MigrationOLITriggerHandler molith = new MigrationOLITriggerHandler();
            molith.doBeforeInsert(new List<Order_Line_Item__c> { testOrderLineItem });
            Test.stopTest();
            
            System.assertEquals(testOrderLineItem.Order_Line_Item_Legacy_Id__c, 'IANGAJKERNGIE');
    }
    
    static testmethod void testOrderLineItem2()
    {
            testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert testAccount;
            
            testProductFamily = new Product_Family__c();
            testProductFamily.Product_Family__c = 'testproductfamilysample';
            insert testProductFamily;
            
            testZProduct =  TestDataFactory.createZProduct(1)[0];
            testZProduct.ProductPlatform__c = 'Online';
            testZProduct.ProductSubType__c = 'Magazine';
            insert testZProduct;
            
            testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.zqu__ZProduct__c = testZProduct.Id;
            testProductRatePlan.SubscriptionFrequency__c = '1';
            testProductRatePlan.RatePlanType__c = 'Proration';
            insert testProductRatePlan;
            
            testPackage = TestDataFactory.createPackage(1)[0];
            testPackage.Package_Price__c = 10;
            testPackage.Platform__c = 'test';
            testPackage.Subscription_Period__c = '1';
            testPackage.Subscription_Type__c = 'Termed';
            testPackage.Package_Type__c = 'Grace Period';
            insert testPackage;
            
            testPackageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            testPackageItem.Product_Rate_Plan__c = testProductRatePlan.Id;
            testPackageItem.Product_Family__c = testProductFamily.Id;
            testPackageItem.Package__c = testPackage.Id;
            insert testPackageItem;
            
            testOrder = TestDataFactory.createOrder(1)[0];
            testOrder.Account__c = testAccount.Id; 
            testOrder.Credit_Balance__c = 100.00;
            testOrder.Delivery_Charge__c = 100.00;
            insert testOrder;

            testOrderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            testOrderLineItem.Order__c = testOrder.Id;
            testOrderLineItem.Order_Line_Item_Legacy_Id__c = 'IANGAJKERNGIE';
            testOrderLineItem.Asia_1_creation_mode__c = 'Individual';
            testOrderLineItem.Ph_d__c = True;
            testOrderLineItem.Ph_e__c = True;
            testOrderLineItem.Main_Package_ID__c = testPackage.Id;
            insert testOrderLineItem; 
            
            
            //testPackageItem = [Select Id, Name, Is_Digital__c, Product_Family__r.Name, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.SubscriptionFrequency__c, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c FROM Package_Item__c];
            
           // testPackage = [Select Id, Subscription_Period__c, Package_Price__c, Platform__c, Subscription_Type__c, 
                         // Package_Type__c 
                         // From Package__c ];
                                      
            //testOrderLineItem = [SELECT Id, Name, Order_Line_Item_Legacy_Id__c FROM Order_Line_Item__c LIMIT 1];

            
            Map<Id, Order_Line_Item__c> orderLineItemMap = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap.put(testOrderLineItem.id, testOrderLineItem);
            
            Map<Id, Order_Line_Item__c> orderLineItemMap2 = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap2.put(testOrderLineItem.id, testOrderLineItem);
            
            Test.startTest();
            MigrationOLITriggerHandler molith = new MigrationOLITriggerHandler();
            molith.doBeforeUpdate(new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap, new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap2);
            Test.stopTest();
            
            System.assertEquals(testOrderLineItem.Asia_1_creation_mode__c, 'Individual');
            
    }
    
    static testmethod void testProductPlatformEqualsAllInOne()
    {
            testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert testAccount;
            
            testProductFamily = new Product_Family__c();
            testProductFamily.Product_Family__c = 'testproductfamilysample';
            insert testProductFamily;
            
            testZProduct =  TestDataFactory.createZProduct(1)[0];
            testZProduct.ProductPlatform__c = 'All-In-One';
            testZProduct.ProductSubType__c = 'Magazine';
            insert testZProduct;
            
            testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.zqu__ZProduct__c = testZProduct.Id;
            testProductRatePlan.SubscriptionFrequency__c = '1';
            testProductRatePlan.RatePlanType__c = 'Proration';
            insert testProductRatePlan;
            
            testPackage = TestDataFactory.createPackage(1)[0];
            testPackage.Package_Price__c = 10;
            testPackage.Platform__c = 'test';
            testPackage.Subscription_Period__c = '1';
            testPackage.Subscription_Type__c = 'Termed';
            testPackage.Package_Type__c = 'Grace Period';
            insert testPackage;
            
            testPackageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            testPackageItem.Product_Rate_Plan__c = testProductRatePlan.Id;
            testPackageItem.Product_Family__c = testProductFamily.Id;
            testPackageItem.Package__c = testPackage.Id;
            insert testPackageItem;
            
            testOrder = TestDataFactory.createOrder(1)[0];
            testOrder.Account__c = testAccount.Id; 
            testOrder.Credit_Balance__c = 100.00;
            testOrder.Delivery_Charge__c = 100.00;
            insert testOrder;

            testOrderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            testOrderLineItem.Order__c = testOrder.Id;
            testOrderLineItem.Order_Line_Item_Legacy_Id__c = 'IANGAJKERNGIE';
            testOrderLineItem.Asia_1_creation_mode__c = 'Individual';
            testOrderLineItem.Ph_d__c = True;
            testOrderLineItem.Ph_e__c = True;
            testOrderLineItem.Main_Package_ID__c = testPackage.Id;
            insert testOrderLineItem; 
            
            
            //testPackageItem = [Select Id, Name, Is_Digital__c, Product_Family__r.Name, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.SubscriptionFrequency__c, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c FROM Package_Item__c];
            
           // testPackage = [Select Id, Subscription_Period__c, Package_Price__c, Platform__c, Subscription_Type__c, 
                         // Package_Type__c 
                         // From Package__c ];
                                      
            //testOrderLineItem = [SELECT Id, Name, Order_Line_Item_Legacy_Id__c FROM Order_Line_Item__c LIMIT 1];

            
            Map<Id, Order_Line_Item__c> orderLineItemMap = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap.put(testOrderLineItem.id, testOrderLineItem);
            
            Map<Id, Order_Line_Item__c> orderLineItemMap2 = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap2.put(testOrderLineItem.id, testOrderLineItem);
            
            Test.startTest();
            MigrationOLITriggerHandler molith = new MigrationOLITriggerHandler();
            molith.doBeforeUpdate(new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap, new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap2);
            Test.stopTest();
            
            System.assertEquals(testZProduct.ProductPlatform__c, 'All-In-One');
            
    }
    
    static testmethod void testSubscriptionFrequencyEqualsZero()
    {
            testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert testAccount;
            
            testProductFamily = new Product_Family__c();
            testProductFamily.Product_Family__c = 'testproductfamilysample';
            insert testProductFamily;
            
            testZProduct =  TestDataFactory.createZProduct(1)[0];
            testZProduct.ProductPlatform__c = 'All-In-One';
            testZProduct.ProductSubType__c = 'Magazine';
            insert testZProduct;
            
            testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.zqu__ZProduct__c = testZProduct.Id;
            testProductRatePlan.SubscriptionFrequency__c = '0';
            testProductRatePlan.RatePlanType__c = 'Proration';
            insert testProductRatePlan;
            
            testPackage = TestDataFactory.createPackage(1)[0];
            testPackage.Package_Price__c = 10;
            testPackage.Platform__c = 'test';
            testPackage.Subscription_Period__c = '1';
            testPackage.Subscription_Type__c = 'Termed';
            testPackage.Package_Type__c = 'Grace Period';
            insert testPackage;
            
            testPackageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            testPackageItem.Product_Rate_Plan__c = testProductRatePlan.Id;
            testPackageItem.Product_Family__c = testProductFamily.Id;
            testPackageItem.Package__c = testPackage.Id;
            insert testPackageItem;
            
            testOrder = TestDataFactory.createOrder(1)[0];
            testOrder.Account__c = testAccount.Id; 
            testOrder.Credit_Balance__c = 100.00;
            testOrder.Delivery_Charge__c = 100.00;
            insert testOrder;

            testOrderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            testOrderLineItem.Order__c = testOrder.Id;
            testOrderLineItem.Start_Date__c=date.today().addDays(1);
            testOrderLineItem.Order_Line_Item_Legacy_Id__c = 'IANGAJKERNGIE';
            testOrderLineItem.Asia_1_creation_mode__c = 'Individual';
            testOrderLineItem.Ph_d__c = True;
            testOrderLineItem.Ph_e__c = True;
            testOrderLineItem.Main_Package_ID__c = testPackage.Id;
            insert testOrderLineItem; 
            
            
            //testPackageItem = [Select Id, Name, Is_Digital__c, Product_Family__r.Name, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.SubscriptionFrequency__c, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c FROM Package_Item__c];
            
           // testPackage = [Select Id, Subscription_Period__c, Package_Price__c, Platform__c, Subscription_Type__c, 
                         // Package_Type__c 
                         // From Package__c ];
                                      
            //testOrderLineItem = [SELECT Id, Name, Order_Line_Item_Legacy_Id__c FROM Order_Line_Item__c LIMIT 1];

            
            Map<Id, Order_Line_Item__c> orderLineItemMap = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap.put(testOrderLineItem.id, testOrderLineItem);
            
            Map<Id, Order_Line_Item__c> orderLineItemMap2 = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap2.put(testOrderLineItem.id, testOrderLineItem);
            
            Test.startTest();
            MigrationOLITriggerHandler molith = new MigrationOLITriggerHandler();
            molith.doBeforeUpdate(new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap, new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap2);
            Test.stopTest();
            
            System.assertEquals(testProductRatePlan.SubscriptionFrequency__c, '0');
       }
       
       static testmethod void testSubscriptionFrequencyEqualsTwo()
        {
            testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert testAccount;
            
            testProductFamily = new Product_Family__c();
            testProductFamily.Product_Family__c = 'testproductfamilysample';
            insert testProductFamily;
            
            testZProduct =  TestDataFactory.createZProduct(1)[0];
            testZProduct.ProductPlatform__c = 'All-In-One';
            testZProduct.ProductSubType__c = 'Magazine';
            insert testZProduct;
            
            testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.zqu__ZProduct__c = testZProduct.Id;
            testProductRatePlan.SubscriptionFrequency__c = '2';
            testProductRatePlan.RatePlanType__c = 'Proration';
            insert testProductRatePlan;
            
            testPackage = TestDataFactory.createPackage(1)[0];
            testPackage.Package_Price__c = 10;
            testPackage.Platform__c = 'test';
            testPackage.Subscription_Period__c = '1';
            testPackage.Subscription_Type__c = 'Termed';
            testPackage.Package_Type__c = 'Grace Period';
            insert testPackage;
            
            testPackageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            testPackageItem.Product_Rate_Plan__c = testProductRatePlan.Id;
            testPackageItem.Product_Family__c = testProductFamily.Id;
            testPackageItem.Package__c = testPackage.Id;
            insert testPackageItem;
            
            testOrder = TestDataFactory.createOrder(1)[0];
            testOrder.Account__c = testAccount.Id; 
            testOrder.Credit_Balance__c = 100.00;
            testOrder.Delivery_Charge__c = 100.00;
            insert testOrder;

            testOrderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            testOrderLineItem.Order__c = testOrder.Id;
            testOrderLineItem.Order_Line_Item_Legacy_Id__c = 'IANGAJKERNGIE';
            testOrderLineItem.Asia_1_creation_mode__c = 'Individual';
            testOrderLineItem.Ph_d__c = True;
            testOrderLineItem.Ph_e__c = True;
            testOrderLineItem.Main_Package_ID__c = testPackage.Id;
            insert testOrderLineItem; 
            
            
            //testPackageItem = [Select Id, Name, Is_Digital__c, Product_Family__r.Name, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.SubscriptionFrequency__c, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c FROM Package_Item__c];
            
           // testPackage = [Select Id, Subscription_Period__c, Package_Price__c, Platform__c, Subscription_Type__c, 
                         // Package_Type__c 
                         // From Package__c ];
                                      
            //testOrderLineItem = [SELECT Id, Name, Order_Line_Item_Legacy_Id__c FROM Order_Line_Item__c LIMIT 1];

            
            Map<Id, Order_Line_Item__c> orderLineItemMap = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap.put(testOrderLineItem.id, testOrderLineItem);
            
            Map<Id, Order_Line_Item__c> orderLineItemMap2 = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap2.put(testOrderLineItem.id, testOrderLineItem);
            
            Test.startTest();
            MigrationOLITriggerHandler molith = new MigrationOLITriggerHandler();
            molith.doBeforeUpdate(new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap, new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap2);
            Test.stopTest();
            
            System.assertEquals(testProductRatePlan.SubscriptionFrequency__c, '2');
       }
       
       static testmethod void testSubscriptionFrequencyEqualsThree()
        {
            testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert testAccount;
            
            testProductFamily = new Product_Family__c();
            testProductFamily.Product_Family__c = 'testproductfamilysample';
            insert testProductFamily;
            
            testZProduct =  TestDataFactory.createZProduct(1)[0];
            testZProduct.ProductPlatform__c = 'All-In-One';
            testZProduct.ProductSubType__c = 'Magazine';
            insert testZProduct;
            
            testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.zqu__ZProduct__c = testZProduct.Id;
            testProductRatePlan.SubscriptionFrequency__c = '3';
            testProductRatePlan.RatePlanType__c = 'Proration';
            insert testProductRatePlan;
            
            testPackage = TestDataFactory.createPackage(1)[0];
            testPackage.Package_Price__c = 10;
            testPackage.Platform__c = 'test';
            testPackage.Subscription_Period__c = '1';
            testPackage.Subscription_Type__c = 'Termed';
            testPackage.Package_Type__c = 'Grace Period';
            insert testPackage;
            
            testPackageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            testPackageItem.Product_Rate_Plan__c = testProductRatePlan.Id;
            testPackageItem.Product_Family__c = testProductFamily.Id;
            testPackageItem.Package__c = testPackage.Id;
            insert testPackageItem;
            
            testOrder = TestDataFactory.createOrder(1)[0];
            testOrder.Account__c = testAccount.Id; 
            testOrder.Credit_Balance__c = 100.00;
            testOrder.Delivery_Charge__c = 100.00;
            insert testOrder;

            testOrderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            testOrderLineItem.Order__c = testOrder.Id;
            testOrderLineItem.Order_Line_Item_Legacy_Id__c = 'IANGAJKERNGIE';
            testOrderLineItem.Asia_1_creation_mode__c = 'Individual';
            testOrderLineItem.Ph_d__c = True;
            testOrderLineItem.Ph_e__c = True;
            testOrderLineItem.Main_Package_ID__c = testPackage.Id;
            insert testOrderLineItem; 
            
            
            //testPackageItem = [Select Id, Name, Is_Digital__c, Product_Family__r.Name, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.SubscriptionFrequency__c, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c FROM Package_Item__c];
            
           // testPackage = [Select Id, Subscription_Period__c, Package_Price__c, Platform__c, Subscription_Type__c, 
                         // Package_Type__c 
                         // From Package__c ];
                                      
            //testOrderLineItem = [SELECT Id, Name, Order_Line_Item_Legacy_Id__c FROM Order_Line_Item__c LIMIT 1];

            
            Map<Id, Order_Line_Item__c> orderLineItemMap = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap.put(testOrderLineItem.id, testOrderLineItem);
            
            Map<Id, Order_Line_Item__c> orderLineItemMap2 = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap2.put(testOrderLineItem.id, testOrderLineItem);
            
            Test.startTest();
            MigrationOLITriggerHandler molith = new MigrationOLITriggerHandler();
            molith.doBeforeUpdate(new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap, new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap2);
            Test.stopTest();
            
            System.assertEquals(testProductRatePlan.SubscriptionFrequency__c, '3');
       }
       
       static testmethod void testSubscriptionFrequencyIsNull()
        {
            testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert testAccount;
            
            testProductFamily = new Product_Family__c();
            testProductFamily.Product_Family__c = 'testproductfamilysample';
            insert testProductFamily;
            
            testZProduct =  TestDataFactory.createZProduct(1)[0];
            testZProduct.ProductPlatform__c = 'All-In-One';
            testZProduct.ProductSubType__c = 'Magazine';
            insert testZProduct;
            
            testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.zqu__ZProduct__c = testZProduct.Id;
            testProductRatePlan.SubscriptionFrequency__c = '';
            testProductRatePlan.RatePlanType__c = 'Proration';
            insert testProductRatePlan;
            
            testPackage = TestDataFactory.createPackage(1)[0];
            testPackage.Package_Price__c = 10;
            testPackage.Platform__c = 'test';
            testPackage.Subscription_Period__c = '1';
            testPackage.Subscription_Type__c = 'Termed';
            testPackage.Package_Type__c = 'Grace Period';
            insert testPackage;
            
            testPackageItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            testPackageItem.Product_Rate_Plan__c = testProductRatePlan.Id;
            testPackageItem.Product_Family__c = testProductFamily.Id;
            testPackageItem.Package__c = testPackage.Id;
            insert testPackageItem;
            
            testOrder = TestDataFactory.createOrder(1)[0];
            testOrder.Account__c = testAccount.Id; 
            testOrder.Credit_Balance__c = 100.00;
            testOrder.Delivery_Charge__c = 100.00;
            insert testOrder;

            testOrderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            testOrderLineItem.Order__c = testOrder.Id;
            testOrderLineItem.Order_Line_Item_Legacy_Id__c = 'IANGAJKERNGIE';
            testOrderLineItem.Asia_1_creation_mode__c = 'Individual';
            testOrderLineItem.Ph_d__c = True;
            testOrderLineItem.Ph_e__c = True;
            testOrderLineItem.Main_Package_ID__c = testPackage.Id;
            insert testOrderLineItem; 
            
            
            //testPackageItem = [Select Id, Name, Is_Digital__c, Product_Family__r.Name, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.SubscriptionFrequency__c, 
                             // Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c FROM Package_Item__c];
            
           // testPackage = [Select Id, Subscription_Period__c, Package_Price__c, Platform__c, Subscription_Type__c, 
                         // Package_Type__c 
                         // From Package__c ];
                                      
            //testOrderLineItem = [SELECT Id, Name, Order_Line_Item_Legacy_Id__c FROM Order_Line_Item__c LIMIT 1];

            
            Map<Id, Order_Line_Item__c> orderLineItemMap = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap.put(testOrderLineItem.id, testOrderLineItem);
            
            Map<Id, Order_Line_Item__c> orderLineItemMap2 = new Map<Id, Order_Line_Item__c>();
            orderLineItemMap2.put(testOrderLineItem.id, testOrderLineItem);
            
            Test.startTest();
            MigrationOLITriggerHandler molith = new MigrationOLITriggerHandler();
            molith.doBeforeUpdate(new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap, new List<Order_Line_Item__c> { testOrderLineItem }, orderLineItemMap2);
            Test.stopTest();
            
            System.assertEquals('', testProductRatePlan.SubscriptionFrequency__c);
       }
}