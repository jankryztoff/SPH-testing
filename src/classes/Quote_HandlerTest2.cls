/**
 * Class Name: Quote_HandlerTest2     
 * @author: Kirk Yngwie Enriquez   
 * Date: 7/9/2015    
 * Requirement/Project Name: SPH Project    
 * @description Test Class for Quote_Handler    
 */
 
@isTest(seeAllData = true)
public class Quote_HandlerTest2{
 
    public static String deliveryChargeType = 'L';
    public static String origin = 'ESHOP Webservice';
    public static Date today = date.today();
    
    static testmethod void test_CreateQuotes(){
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        insert acc;
        System.assertNotEquals(null, acc.id);
        
        Singpost_Address__c singpostAddress = TestDataFactory.createSingpostAddress(1)[0];
        singpostAddress.Name = '99';
        singpostAddress.House_Block_Number__c = 'TEST';
        singpostAddress.Address_Type__c = 'L';
        insert singpostAddress;
        System.assertNotEquals(null, singpostAddress.id);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Postal_Code__c = singpostAddress.Id;
        address.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Internal'].Id;
        address.Address_Type__c = 'L';
        insert address;
        System.assertNotEquals(null, address.id);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.id;
        con.Address__c = address.Id;
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        System.assertNotEquals(null, con.id);
        
        //Create Order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 1;
        order.Payment_Mode__c = 'Cash';
        order.Delivery_Charge_Type__c = 'L';
        order.Recipient_Contact__c = con.id;
        insert order;
        System.assertNotEquals(null, order.id);
        
        //Create Product
        zqu__ZProduct__c testProduct =  TestDataFactory.createZProduct(1)[0];
        testProduct.ProductPlatform__c = 'Print';
        testProduct.ProductType__c = 'Gift';
        testProduct.ProductSubType__c = 'Premium';
        testProduct.ProductCode__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
        insert testProduct;
        System.assertNotEquals(null, testProduct.id);
        
        //Create Product Rate Plan
        List<zqu__ProductRatePlan__c> testProductRatePlan = TestDataFactory.createProductRatePlan(2);
        testProductRatePlan[0].Name = ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount');
        testProductRatePlan[0].zqu__ZProduct__c = testProduct.Id;
        testProductRatePlan[0].RatePlanType__c = 'Proration';
        testProductRatePlan[0].zqu__EffectiveStartDate__c = Date.today();
        testProductRatePlan[0].zqu__EffectiveEndDate__c = Date.today().addDays(30);
        testProductRatePlan[0].zqu__Deleted__c = false;
        testProductRatePlan[0].RatePlanCode__c = 'CHGPOS';
        
        testProductRatePlan[1].Name = ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount');
        testProductRatePlan[1].zqu__ZProduct__c = testProduct.Id;
        testProductRatePlan[1].RatePlanType__c = 'Discount';
        testProductRatePlan[1].zqu__EffectiveStartDate__c = Date.today();
        testProductRatePlan[1].zqu__EffectiveEndDate__c = Date.today().addDays(30);
        testProductRatePlan[1].zqu__Deleted__c = false;
        testProductRatePlan[1].RatePlanCode__c = 'CHGPOS';
        insert testProductRatePlan;
        System.assertNotEquals(null, testProductRatePlan[0].id);
        
        //Create Main Package
        List<Package__c> pack = TestDataFactory.createPackage(2);
        pack[0].Name = 'Test Package Bundled';
        pack[0].Package_Type__c = 'Bundled';
        pack[0].Subscription_Type__c = 'Termed';
        pack[0].Subscription_Period__c = '4';
        pack[0].Package_Code__c = 'Bundled';
        pack[1].Package_Type__c = 'Add On';
        pack[1].Eligible_Product_Family_for_Add_On_Pack__c = 'Bundled';
        pack[1].Billing_Type__c = 'Prepaid';
        pack[1].Subscription_Period__c = '1';
        pack[1].Subscription_Period_1__c = '1';
        insert pack;
        System.assertNotEquals(null, pack[0].id);
        
        //Create Package Bundle Product
        Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
        packItem.Package__c = pack[0].id;
        packitem.Product_Rate_Plan__c = testProductRatePlan[0].Id;
        insert packItem;
        System.assertNotEquals(null, packItem.id);
        
        //Create Promotion
        Promotion__c promotion = TestDataFactory.createPromotion(1)[0];
        promotion.Contract_Period__c = '1';
        insert promotion;
        System.assertNotEquals(null, promotion.id);
        
        //Create Vendor Subscription
        Subscription_Vendor__c subVendor = TestDataFactory.createSubscriptionVendor(1)[0];
        insert subVendor;
        
        //Create Order Line Item
        Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
        orderLineItem.Order__c = order.id;
        orderLineItem.Main_Package_ID__c = pack[0].id;
        orderLineItem.Addon_Package__c = pack[1].id;
        orderLineItem.Main_Package_Product_Family__c = 'Bundled';
        orderLineItem.Main_Package_Billing_Type__c = 'Prepaid';
        orderLineItem.Main_Package_Product_Platform__c = 'Print';
        orderLineItem.Postage_Charge__c = 10;
        orderLineItem.Promotion_ID__c = promotion.id;
        orderLineItem.Vendor_Conversion__c = true;
        orderLineItem.Vendor_Subscription_ID__c = subVendor.id;
        orderLineItem.Start_Date__c=date.today()+1;
        insert orderLineItem;
        System.assertNotEquals(null, orderLineItem.id);
        
        //Create Gift
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Premium';
        gift.One_Time_Charge__c = 100.0;
        insert gift;
        System.assertNotEquals(null, gift.id);
        
        //Create Promotion Gift
        Promotion_Gift__c promotionGift = TestDataFactory.createPromotionGift(1)[0];
        promotionGIft.Gift__c = gift.id;
        insert promotionGift;
        System.assertNotEquals(null, promotionGift.id);
        
        //Create Order Line Item Gift
        Order_Line_Item_Gift__c orderLineItemGift = TestDataFactory.createItemGift(1)[0];
        orderLineItemGift.Order_Line_Item__c = orderLineItem.id;
        orderLineItemGift.Promotion_Gift__c = promotionGift.id;
        insert orderLineItemGift;
        System.assertNotEquals(null, orderLineItemGift.id);
        
        //Start Test
        Test.startTest();
        Quote_Handler testInstance = new Quote_Handler();
        testInstance.Create_Quotes(order, 'Sample Origin', orderLineItem.id);
        Quote_Handler.createQuoteExtension(orderLineItem, order, '2', 'Test', 'Sample Origin');
        Test.stopTest();
    }
    
     static testmethod void test_CreateQuotesB(){
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        insert acc;
        System.assertNotEquals(null, acc.id);
        
        Singpost_Address__c singpostAddress = TestDataFactory.createSingpostAddress(1)[0];
        singpostAddress.Name = '99';
        singpostAddress.House_Block_Number__c = 'TEST';
        singpostAddress.Address_Type__c = 'L';
        insert singpostAddress;
        System.assertNotEquals(null, singpostAddress.id);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Postal_Code__c = singpostAddress.Id;
        address.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Internal'].Id;
        address.Address_Type__c = 'L';
        insert address;
        System.assertNotEquals(null, address.id);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.id;
        con.Address__c = address.Id;
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        System.assertNotEquals(null, con.id);
        
        //Create Order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 1;
        order.Payment_Mode__c = 'Cash';
        order.Delivery_Charge_Type__c = 'L';
        order.Recipient_Contact__c = con.id;
        insert order;
        System.assertNotEquals(null, order.id);
        
        //Create Product
        zqu__ZProduct__c testProduct =  TestDataFactory.createZProduct(1)[0];
        testProduct.ProductPlatform__c = 'Print';
        testProduct.ProductType__c = 'Gift';
        testProduct.ProductSubType__c = 'Premium';
        testProduct.ProductCode__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
        insert testProduct;
        System.assertNotEquals(null, testProduct.id);
        
        //Create Product Rate Plan
        List<zqu__ProductRatePlan__c> testProductRatePlan = TestDataFactory.createProductRatePlan(2);
        testProductRatePlan[0].Name = ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount');
        testProductRatePlan[0].zqu__ZProduct__c = testProduct.Id;
        testProductRatePlan[0].RatePlanType__c = 'Proration';
        testProductRatePlan[0].zqu__EffectiveStartDate__c = Date.today();
        testProductRatePlan[0].zqu__EffectiveEndDate__c = Date.today().addDays(30);
        testProductRatePlan[0].zqu__Deleted__c = false;
        testProductRatePlan[0].RatePlanCode__c = 'CHGPOS';
        
        testProductRatePlan[1].Name = ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount');
        testProductRatePlan[1].zqu__ZProduct__c = testProduct.Id;
        testProductRatePlan[1].RatePlanType__c = 'Discount';
        testProductRatePlan[1].zqu__EffectiveStartDate__c = Date.today();
        testProductRatePlan[1].zqu__EffectiveEndDate__c = Date.today().addDays(30);
        testProductRatePlan[1].zqu__Deleted__c = false;
        testProductRatePlan[1].RatePlanCode__c = 'CHGPOS';
        insert testProductRatePlan;
        System.assertNotEquals(null, testProductRatePlan[0].id);
        
        //Create Main Package
        List<Package__c> pack = TestDataFactory.createPackage(2);
        pack[0].Name = 'Test Package Bundled';
        pack[0].Package_Type__c = 'Bundled';
        pack[0].Subscription_Type__c = 'Termed';
        pack[0].Subscription_Period__c = '4';
        pack[0].Package_Code__c = 'Bundled';
        pack[1].Package_Type__c = 'Add On';
        pack[1].Eligible_Product_Family_for_Add_On_Pack__c = 'Bundled';
        pack[1].Billing_Type__c = 'Prepaid';
        pack[1].Subscription_Period__c = '1';
        pack[1].Subscription_Period_1__c = '1';
        insert pack;
        System.assertNotEquals(null, pack[0].id);
        
        //Create Package Bundle Product
        //Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
        Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Bundle Discount')[0];
        packItem.Package__c = pack[0].id;
        packitem.Product_Rate_Plan__c = testProductRatePlan[0].Id;
        insert packItem;
        System.assertNotEquals(null, packItem.id);
        
        //Create Promotion
        Promotion__c promotion = TestDataFactory.createPromotion(1)[0];
        promotion.Contract_Period__c = '1';
        insert promotion;
        System.assertNotEquals(null, promotion.id);
        
        //Create Vendor Subscription
        Subscription_Vendor__c subVendor = TestDataFactory.createSubscriptionVendor(1)[0];
        insert subVendor;
        
        //Create Order Line Item
        Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
        orderLineItem.Order__c = order.id;
        orderLineItem.Main_Package_ID__c = pack[0].id;
        orderLineItem.Addon_Package__c = pack[1].id;
        orderLineItem.Main_Package_Product_Family__c = 'Bundled';
        orderLineItem.Main_Package_Billing_Type__c = 'Prepaid';
        orderLineItem.Main_Package_Product_Platform__c = 'Print';
        orderLineItem.Postage_Charge__c = 10;
        orderLineItem.Promotion_ID__c = promotion.id;
        orderLineItem.Vendor_Conversion__c = true;
        orderLineItem.Vendor_Subscription_ID__c = subVendor.id;
        orderLineItem.Start_Date__c=date.today()+1;
        insert orderLineItem;
        System.assertNotEquals(null, orderLineItem.id);
        
        //Create Gift
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Premium';
        gift.One_Time_Charge__c = 100.0;
        insert gift;
        System.assertNotEquals(null, gift.id);
        
        //Create Promotion Gift
        Promotion_Gift__c promotionGift = TestDataFactory.createPromotionGift(1)[0];
        promotionGIft.Gift__c = gift.id;
        insert promotionGift;
        System.assertNotEquals(null, promotionGift.id);
        
        //Create Order Line Item Gift
        Order_Line_Item_Gift__c orderLineItemGift = TestDataFactory.createItemGift(1)[0];
        orderLineItemGift.Order_Line_Item__c = orderLineItem.id;
        orderLineItemGift.Promotion_Gift__c = promotionGift.id;
        insert orderLineItemGift;
        System.assertNotEquals(null, orderLineItemGift.id);
        
        //Start Test
        Test.startTest();
        Quote_Handler testInstance = new Quote_Handler();
        testInstance.Create_Quotes(order, 'Sample Origin', orderLineItem.id);
        Quote_Handler.createQuoteExtension(orderLineItem, order, '2', 'Test', 'Sample Origin');
        Test.stopTest();
    }
    
    static testmethod void test_CreateQuote2(){
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        insert acc;
        
        Singpost_Address__c singpostAddress = TestDataFactory.createSingpostAddress(1)[0];
        singpostAddress.Name = '99';
        singpostAddress.House_Block_Number__c = 'TEST';
        singpostAddress.Address_Type__c = 'L';
        insert singpostAddress;
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Postal_Code__c = singpostAddress.Id;
        address.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Local'].Id;
        address.Address_Type__c = 'L';
        insert address;
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.id;
        con.Address__c = address.Id;
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        //Create Order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 1;
        order.Payment_Mode__c = 'Cash';
        order.Delivery_Charge_Type__c = 'L';
        order.Recipient_Contact__c = con.id;
        insert order;
        
        //Create Product
        zqu__ZProduct__c testProduct =  TestDataFactory.createZProduct(1)[0];
        testProduct.ProductPlatform__c = 'Print';
        testProduct.ProductType__c = 'Gift';
        testProduct.ProductSubType__c = 'Premium';
        testProduct.ProductCode__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
        insert testProduct;
        
        //Create Product Rate Plan
        List<zqu__ProductRatePlan__c> testProductRatePlan = TestDataFactory.createProductRatePlan(2);
        testProductRatePlan[0].Name = ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount');
        testProductRatePlan[0].zqu__ZProduct__c = testProduct.Id;
        testProductRatePlan[0].RatePlanType__c = 'Discount';
        testProductRatePlan[0].zqu__EffectiveStartDate__c = Date.today();
        testProductRatePlan[0].zqu__EffectiveEndDate__c = Date.today().addDays(30);
        testProductRatePlan[0].zqu__Deleted__c = false;
        testProductRatePlan[0].RatePlanCode__c = 'CHGPOS';
        
        testProductRatePlan[1].Name = ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount');
        testProductRatePlan[1].zqu__ZProduct__c = testProduct.Id;
        testProductRatePlan[1].RatePlanType__c = 'Bill Plan';
        //testProductRatePlan[1].RatePlanType__c = 'Discount';
        testProductRatePlan[1].zqu__EffectiveStartDate__c = Date.today();
        testProductRatePlan[1].zqu__EffectiveEndDate__c = Date.today().addDays(30);
        testProductRatePlan[1].zqu__Deleted__c = false;
        testProductRatePlan[1].RatePlanCode__c = 'CHGPOS';
        insert testProductRatePlan;
        
        //Create Main Package
        List<Package__c> pack = TestDataFactory.createPackage(2);
        pack[0].Name = 'Test Package Bundled';
        pack[0].Package_Type__c = 'Bundled';
        pack[0].Subscription_Type__c = 'Termed';
        pack[0].Subscription_Period__c = '4';
        pack[0].Package_Code__c = 'Bundled';
        pack[1].Package_Type__c = 'Add On';
        pack[1].Eligible_Product_Family_for_Add_On_Pack__c = 'Bundled';
        pack[1].Billing_Type__c = 'Full Prepaid';
        pack[1].Subscription_Period__c = '1';
        pack[1].Subscription_Period_1__c = '1';
        pack[1].Subscription_Type__c = 'Grace Period';
        insert pack;

        //WAK: Create product rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = testProductRatePlan[1].Id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c packItemBase = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packItemBase.Package__c = pack[1].id;
        packitemBase.Product_Rate_Plan__c = testProductRatePlan[1].Id;
        insert packItemBase; 
        
        //Create Package Bundle Product
        Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        packItem.Package__c = pack[1].id;
        packitem.Product_Rate_Plan__c = testProductRatePlan[0].Id;
        packItem.Base_Package_Item__c = packItemBase.id;
        insert packItem;
        
        //Create Promotion
        Promotion__c promotion = TestDataFactory.createPromotion(1)[0];
        promotion.Contract_Period__c = '1';
        insert promotion;
        
        //Create Order Line Item
        Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
        orderLineItem.Order__c = order.id;
        orderLineItem.Main_Package_ID__c = pack[0].id;
        orderLineItem.Addon_Package__c = pack[1].id;
        orderLineItem.Main_Package_Product_Family__c = 'Bundled';
        orderLineItem.Main_Package_Billing_Type__c = 'Full Prepaid';
        orderLineItem.Main_Package_Product_Platform__c = 'All-In-One';
        orderLineItem.Postage_Charge__c = 10;
        orderLineItem.Promotion_ID__c = promotion.id;
        orderLineItem.Delivered_By__c = 'Mailing Agent';
        orderLineItem.Start_Date__c=date.today()+1;
        insert orderLineItem;
        
        //Create Gift
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Premium';
        gift.One_Time_Charge__c = 100.0;
        insert gift;
        
        //Create Promotion Gift
        Promotion_Gift__c promotionGift = TestDataFactory.createPromotionGift(1)[0];
        promotionGIft.Gift__c = gift.id;
        insert promotionGift;
        
        //Create Order Line Item Gift
        Order_Line_Item_Gift__c orderLineItemGift = TestDataFactory.createItemGift(1)[0];
        orderLineItemGift.Order_Line_Item__c = orderLineItem.id;
        orderLineItemGift.Promotion_Gift__c = promotionGift.id;
        insert orderLineItemGift;
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.zqu__Account__c = acc.id;
        quote.Addon_Package__c = pack[0].id;
        quote.zqu__BillToContact__c = con.id;
        quote.Main_Package__c = pack[1].id;
        quote.Order_Line_Item_Number_1__c = orderLineItem.id;
        quote.Order_Line_Item_Number__c = orderLineItem.id;
        quote.Subscription_Type__c = 'Publication';
        insert quote;
        
        //Start Test
        Test.startTest();
        Quote_Handler testInstance = new Quote_Handler();
        testInstance.Create_Quotes(order, 'Sample Origin', orderLineItem.id);
        //Quote_Handler.createQuoteExtension(testOrderLineItem,testOrder,'2','Test',origin);
        //Quote_Handler.createQuoteDelivery(testOrder, testOrderLineItem,'Test','origin');
        Quote_Handler.createQuotePostage(order, orderLineItem, quote.Subscription_Type__c, 'ESHOP Webservice');
        Test.stopTest();
    }
    
    static testmethod void newTest(){
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Mailing Agent')[0];
        insert acc;
        System.assertNotEquals(null, acc.id);
        
        Singpost_Address__c singpostAddress = TestDataFactory.createSingpostAddress(1)[0];
        singpostAddress.Name = '99';
        singpostAddress.House_Block_Number__c = 'TEST';
        singpostAddress.Address_Type__c = 'L';
        insert singpostAddress;
        System.assertNotEquals(null, singpostAddress.id);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Postal_Code__c = singpostAddress.Id;
        address.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Local'].Id;
        address.Address_Type__c = 'H';
        insert address;
        System.assertNotEquals(null, address.id);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.id;
        con.Address__c = address.Id;
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        System.assertNotEquals(null, con.id);
        
        //Create Order
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 1;
        order.Payment_Mode__c = 'Cash';
        order.Delivery_Charge_Type__c = 'L';
        order.Recipient_Contact__c = con.id;
        insert order;
        System.assertNotEquals(null, order.id);
        
        //Create Product
        zqu__ZProduct__c testProduct =  TestDataFactory.createZProduct(1)[0];
        testProduct.ProductPlatform__c = 'Print';
        testProduct.ProductType__c = 'Gift';
        testProduct.ProductSubType__c = 'Premium';
        testProduct.ProductCode__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
        insert testProduct;
        System.assertNotEquals(null, testProduct.id);
        
        //Create Product Rate Plan
        List<zqu__ProductRatePlan__c> testProductRatePlan = TestDataFactory.createProductRatePlan(2);
        testProductRatePlan[0].Name = ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount');
        testProductRatePlan[0].zqu__ZProduct__c = testProduct.Id;
        testProductRatePlan[0].RatePlanType__c = 'Proration';
        testProductRatePlan[0].zqu__EffectiveStartDate__c = Date.today();
        testProductRatePlan[0].zqu__EffectiveEndDate__c = Date.today().addDays(30);
        testProductRatePlan[0].zqu__Deleted__c = false;
        testProductRatePlan[0].RatePlanCode__c = 'CHGPOS';
        testProductRatePlan[0].SubscriptionFrequency__c = '1';
        
        testProductRatePlan[1].Name = ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount');
        testProductRatePlan[1].zqu__ZProduct__c = testProduct.Id;
        testProductRatePlan[1].RatePlanType__c = 'Discount';
        testProductRatePlan[1].zqu__EffectiveStartDate__c = Date.today();
        testProductRatePlan[1].zqu__EffectiveEndDate__c = Date.today().addDays(30);
        testProductRatePlan[1].zqu__Deleted__c = false;
        testProductRatePlan[1].RatePlanCode__c = 'CHGPOS';
        testProductRatePlan[1].SubscriptionFrequency__c = '1';
        insert testProductRatePlan;
        System.assertNotEquals(null, testProductRatePlan[0].id);
        
        //Create Main Package
        List<Package__c> pack = TestDataFactory.createPackage(2);
        pack[0].Name = 'Test Package Bundled';
        pack[0].Package_Type__c = 'Bundled';
        pack[0].Subscription_Type__c = 'Termed';
        pack[0].Subscription_Period__c = '4';
        pack[0].Package_Code__c = 'Bundled';
        pack[1].Package_Type__c = 'Add On';
        pack[1].Eligible_Product_Family_for_Add_On_Pack__c = 'Bundled';
        pack[1].Billing_Type__c = 'Prepaid';
        pack[1].Subscription_Period__c = '1';
        pack[1].Subscription_Period_1__c = '1';
        insert pack;
        System.assertNotEquals(null, pack[0].id);
        
        
        
        //Create Package Bundle Product
        Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
        packItem.Package__c = pack[0].id;
        packitem.Product_Rate_Plan__c = testProductRatePlan[0].Id;
        insert packItem;
        System.assertNotEquals(null, packItem.id);
        
        //Create Promotion
        Promotion__c promotion = TestDataFactory.createPromotion(1)[0];
        promotion.Contract_Period__c = '1';
        insert promotion;
        System.assertNotEquals(null, promotion.id);
        
        //Create Vendor Subscription
        Subscription_Vendor__c subVendor = TestDataFactory.createSubscriptionVendor(1)[0];
        insert subVendor;
        
        List<Zuora__CustomerAccount__c> billAcc = TestDataFactory.createBillingAccount(1);
            billAcc[0].Zuora__Account__c = acc.Id;
            billAcc[0].Billing_Type__c = 'Full Prepaid';
            billAcc[0].Billing_Contact__c = con.id;
            billAcc[0].Zuora__Credit_Balance__c = 50000.00;
            billAcc[0].Zuora__DefaultPaymentMethod__c = 'Full Prepaid';
            insert billAcc;
            
          
            List<Zuora__Subscription__c> zSub = TestDataFactory.createSubscription(1);
            zSub[0].Name = 'Adjustment';
            zSub[0].Billing_Type__c = 'Full Prepaid';
            zSub[0].Zuora__CustomerAccount__c = billAcc[0].id;
            zSub[0].Subscription_Type_1__c = 'Publication';
            zSub[0].Subscription_Type__c = 'Publication';
            zSub[0].Zuora__Account__c = acc.id;
            zSub[0].Zuora__Status__c = 'Active';
            //zSub.Order_Line_Item_Number__c = orderLineItem.id;
            zSub[0].Recipient_Contact__c = con.id;
            //zSub.Order_Number__c = order.id;
            zSub[0].Zuora__SubscriptionEndDate__c = System.Today() + 1;
            insert zSub; 
            
        
        //Create Order Line Item
        Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
        orderLineItem.Order__c = order.id;
        orderLineItem.Main_Package_ID__c = pack[0].id;
        orderLineItem.Addon_Package__c = pack[1].id;
        orderLineItem.Main_Package_Product_Family__c = 'Bundled';
        orderLineItem.Main_Package_Billing_Type__c = 'Prepaid';
        orderLineItem.Main_Package_Product_Platform__c = 'Print';
        orderLineItem.Postage_Charge__c = 10;
        orderLineItem.Promotion_ID__c = promotion.id;
        orderLineItem.Vendor_Conversion__c = true;
        orderLineItem.Vendor_Subscription_ID__c = subVendor.id;
        orderLineItem.Start_Date__c=date.today()+1;
        insert orderLineItem;
        System.assertNotEquals(null, orderLineItem.id);
        
        //Create Gift
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Premium';
        gift.One_Time_Charge__c = 100.0;
        insert gift;
        System.assertNotEquals(null, gift.id);
        
        //Create Promotion Gift
        Promotion_Gift__c promotionGift = TestDataFactory.createPromotionGift(1)[0];
        promotionGIft.Gift__c = gift.id;
        insert promotionGift;
        System.assertNotEquals(null, promotionGift.id);
        
        //Create Order Line Item Gift
        Order_Line_Item_Gift__c orderLineItemGift = TestDataFactory.createItemGift(1)[0];
        orderLineItemGift.Order_Line_Item__c = orderLineItem.id;
        orderLineItemGift.Promotion_Gift__c = promotionGift.id;
        insert orderLineItemGift;
        System.assertNotEquals(null, orderLineItemGift.id);
        
        //Start Test
        Test.startTest();
        Quote_Handler testInstance = new Quote_Handler();
        testInstance.Create_Quotes(order, 'Sample Origin', orderLineItem.id);
        Quote_Handler.createQuoteExtension(orderLineItem, order, '2', 'Test', 'Sample Origin');
        Quote_Handler.existingDeliverySubscriptionId = zSub[0].id;
        Quote_Handler.recipientAddressType = '';
        Test.stopTest();
    }
    
}