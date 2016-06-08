@isTest(seeAllData = True)
public class Renewal_Quote_Handler_BulkTest
{
    public static Key_Id__c acctRecType = [Select Id, Name, Id__c, Type__c FROM Key_Id__c WHERE NAME = 'Account_Direct Individual' LIMIT 1];
    public static Key_Id__c contactRecType = [Select Id, Name, Id__c, Type__c FROM Key_Id__c WHERE NAME = 'Contact_Customer Contact' LIMIT 1];
    
    static testMethod void testOnOrdersPerMethod()
    {
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderLineItemGiftSet = new Set<Id>();
        Set<id> packageIdSet = new Set<Id>();
        Map<id, List<Order_Line_Item__c>> orderIdOrderLineItemMap = new Map<id, List<Order_Line_Item__c>>();
        Map<id, List<Package_Item__c>> packageItemMap = new Map<id, List<Package_Item__c>>();
        Map<id, zqu__ProductRatePlan__c> prodRatePlanIdRatePlanMap = new Map<id, zqu__ProductRatePlan__c>();
        Map<id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanChargemap = new Map<id, List<zqu__ProductRatePlanCharge__c>>();
        Map<Id, List<Order_Line_Item_Gift__c>> oliIdToOliGiftListMap = new Map<Id, List<Order_Line_Item_Gift__c>>();
        Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c> ();
        Map<Id, String> orderIdToSubZuoraIdMap = new Map<Id, String>();
        Map<String, Set<id>> oliNameToQuoteId = new Map<String, Set<id>>();     
        Map<id, zqu__ProductRatePlanChargeTier__c> prcIdToPrpctMap = new Map<id, zqu__ProductRatePlanChargeTier__c>();
        
        Account account1 = new Account(Name = 'SPHAccountTest', RecordTypeId = acctRecType.Id__c, Status__c = 'Active', Active__c = true, Email__c = 'test@sample.com', SMS_Renewal_Notification__c = true, Mobile__c = '09321234567');
        insert account1;
       
        /*Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;*/
            
        /*  Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
                RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Airline' LIMIT 1][0];
                addressRec.RecordTypeId = rt.id;
                //addressRec.Country__c = countr.Id;
                insert addressRec;    */
                
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Gift__c> oliIdToOliGiftList = new List<Order_Line_Item_Gift__c>();
        List<Package_Item__c> packageList = new List<Package_Item__c>();
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = account1.Id;
        defaultPayment.Billing_Type__c = 'Full Prepaid';
 
        insert defaultPayment;
        
        //Select record type of Account
        Date dateToday = System.today();

       
        Id account1Id = account1.Id;
        Contact contact1 = new Contact(FirstName = 'SPHFirst', LastName = 'SPHLast', AccountId = account1Id, 
        RecordTypeId = contactRecType.Id__c, HomePhone__c = '321324321434',Recipient_Indicator__c = true);//, Address__c =addressRec.Id);
        insert contact1;
        
        Zuora__Subscription__c subscription1 = new Zuora__Subscription__c(Name = 'BA-S00000001', Zuora__SubscriptionEndDate__c = dateToday, 
        Zuora__Account__c = account1Id, Zuora__CustomerAccount__c = defaultPayment.id);        
        insert subscription1;
        
        Id subscription1Id = subscription1.Id;
        
        system.assert(account1Id != null);
        system.assert(subscription1Id != null);
        
        /*Order__c order1 = new Order__c(Account__c = account1Id, Subscription_Start_Date__c = System.today() + 180 ,
        Subscription_End_Date__c = System.today() + 360, New_Quantity__c = 1, Effective_Date__c = System.today() + 180,
        Delivery_Charge_Type__c = 'L', Vendor_Credit__c = 4.00, Order_Type__c = 'Temp Stop', Credit_Balance__c = 0.00,
        Delivery_Charge__c = 0.00, Base_Subscription__c = subscription1Id, Subscriber_Charge__c = 15);*/
        Order__c order1 = TestDataFactory.createOrder(1)[0];
        order1.Account__c = account1Id;
        order1.Recipient_Contact__c = contact1.Id;
        //order1.Recipient_Contact__c= '1';
        order1.Billing_Account__c = defaultPayment.Id;
            //order.Informed_Customer__c = True;
        order1.Billing_Type__c = 'Full Prepaid';
        order1.Subscriber_Charge__c = 15;
        order1.Payment_Mode__c ='Check';
        order1.Other_Payment_Mode__c = 'Invoice';
           
        insert order1;
        
        Id order1Id = order1.Id;
        
        /*Package__c package1 = new Package__c(Name = 'SPHPackage', Package_Code__c = 'SPHFP1', Effective_Start_Date__c = dateToday - 1000,
        Effective_End_Date__c = dateToday + 2000);
        insert package1;        
        Id package1Id = package1.Id;
        */
        Package__c package1 = TestDataFactory.createPackage(1)[0];      
        package1.Package_Type__c = 'Discount';
        package1.Package_Sub_Type__c = 'Single';
        package1.Subscription_Type__c = 'Termed';
        insert package1;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();//
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);//
        //prdRatePlan.RatePlanCode__c = 'CHGPOS';
        //prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
                        
        zqu__ProductRatePlanCharge__c prdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prdRatePlanCharge.Name = 'Product Rate Plan Charge';  //      
        prdRatePlanCharge.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prdRatePlanCharge.zqu__ZuoraId__c = '3689922200';//     
        insert prdRatePlanCharge;
        //system.assertequals(null,prdRatePlanCharge);
        
        zqu__ProductRatePlanChargeTier__c prdRatePlanChrgTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        prdRatePlanChrgTier.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        insert prdRatePlanChrgTier;
        
//        Package_Item__c packageItem1 = new Package_Item__c(Package__c = package1Id, Name = 'SPHPackageItem');     
        
        Package_Item__c packageItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItem1.Package__c = package1.Id;
        packageItem1.Product_Rate_Plan__c = prdRatePlanCharge.zqu__ProductRatePlan__c;
        packageItem1.Duration_in_months__c = '3';
        packageItem1.Effective_Start_Month__c = '3'; 
        insert packageItem1;
        
        Promotion__c promotion1 = new Promotion__c(Name = 'SPHPromotion', Promotion_Code__c = 'SPPROMO12', Effective_Start_Date__c = dateToday - 1000,
        Effective_End_Date__c = dateToday + 2000, Contract__c = 'No');
        insert promotion1;
        Id promotion1Id = promotion1.Id;
        
        Order_Line_Item__c orderLineItem1 = new Order_Line_Item__c(Main_Package_ID__c = packageItem1.Package__c, Main_Package_Billing_Type__c = 'Full Prepaid', Delivered_By__c = 'None', Main_Package_Type__c = 'Base', Promotion_ID__c = promotion1Id, Qty__c = 1, Start_Date__c = dateToday, End_Date__c = dateToday + 3000, Order__c = order1Id, Term_Length__c=1.5, Contract_End_Date__c = date.today()+30);
        orderLineItem1.Start_Date__c = date.today()+1;
        insert orderLineItem1;
        //system.assertequals(null,orderLineItem1);
        
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        quote.zqu__SubscriptionType__c = 'New Subscription';                    
        quote.zqu__ValidUntil__c = Date.Today().addMonths(1);
        quote.Qty1__c = 12;
        quote.Term_Length1__c = 12;
        quote.zqu__Subscription_Term_Type__c = 'Evergreen';
        quote.zqu__Currency__c = 'USD';
        quote.zqu__InvoiceProcessingOption__c ='Subscription';
        quote.zqu__PaymentTerm__c  = 'Due Upon Receipt';
        quote.zqu__StartDate__c  = date.today();
        quote.zqu__Service_Activation_Date__c  = date.today();
        quote.Acquisition_Type__c= 'CALL';      
        quote.zqu__Account__c  = account1.Id;        
        
        quote.Payment_Mode__c = 'Check'; 
        quote.zqu__PaymentMethod__c= 'Check' ; 
        quote.Other_PaymentMethod__c  = 'Invoice';
        quote.zqu__SoldToContact__c = contact1.Id;
        quote.Subscription_Type__c = 'Postage';        
        insert quote;
        //system.assertEquals(null,quote);
        
        Promotion_Gift__c promotionGift = TestDataFactory.createPromotionGift(1)[0];
        insert promotionGift;
        
        Order_Line_Item_Gift__c OrderLineItemGifts = TestDataFactory.createItemGift(1)[0];
        OrderLineItemGifts.Order_Line_Item__c = orderLineItem1.Id;
        OrderLineItemGifts.Promotion_Gift__c = promotionGift.Id;
        insert OrderLineItemGifts;  

        orderLineItemGiftSet.add(OrderLineItemGifts.id);
        packageIdSet.add(package1.id);
        orderIds.add(order1Id);
        packageList.add(packageItem1);
        oliIdToOliGiftList.add(OrderLineItemGifts);
        oliList.add(orderLineItem1);
        
        orderIdToOrderMap.put(order1.Id, order1);
        orderIdToSubZuoraIdMap.put(order1.Id, 'Test');
        //packageItemMap.put(packageItem1.Id, packageList);
        prodRatePlanIdRatePlanMap.put(prdRatePlan.Id, prdRatePlan);
        //oliIdToOliGiftListMap.put(OrderLineItemGifts.id, oliIdToOliGiftList);
        
        zqu__QuoteCharge__c zqc= TestDataFactory.createQuoteCharge(1)[0];
        zqc.Name = 'Product Rate Plan Charge';
        zqc.zqu__Quote__c=quote.Id;
        zqc.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        zqc.zqu__Quantity__c = 1;
        insert zqc;
         
         
         //new
         List<zqu__ProductRatePlanCharge__c> zprpc = new List<zqu__ProductRatePlanCharge__c>();
         zprpc.add(prdRatePlanCharge);
        
         
        //zqu__ProductRatePlan__c postagePrp 
         Map<Id, List<zqu__ProductRatePlanCharge__c>> postagePrpIdToPrpcListMap = new Map<Id, List<zqu__ProductRatePlanCharge__c>>();
         postagePrpIdToPrpcListMap.put(prdRatePlan.Id,zprpc);
        
        //end
        
        
        Test.StartTest();
        Renewal_Quote_Handler_Bulk renewalQuote = new Renewal_Quote_Handler_Bulk();
        renewalQuote.bulkQuoteCreation(orderIds, 'Renewal');
        renewalQuote.zBuildPostageQuote(order1, orderLineItem1, 'subtype', 'origin');
        renewalQuote.createQuoteDelivery(order1, orderLineItem1, 'subtype', 'origin');
        renewalQuote.getOrder(orderIds);
        orderIdOrderLineItemMap = renewalQuote.getOrderLineItem(orderIds);
        //karenmae 04.13.15
        //renewalQuote.preparePostageCharge();
        //renewalQuote.zPopulateQuoteChargePostage(quote.Id, orderLineItem1);
        oliIdToOliGiftListMap = renewalQuote.getOrderLineItemGifts(orderLineItemGiftSet);
        packageItemMap = renewalQuote.getPackage(packageIdSet, orderIdOrderLineItemMap);
        prodRatePlanIdRatePlanMap = renewalQuote.getProductRatePlan(packageItemMap);
        prodRatePlanChargemap = renewalQuote.getProdRatePlanCharge(prodRatePlanIdRatePlanMap);
        prcIdToPrpctMap = renewalQuote.getProdRatePlanChargeTier(prodRatePlanChargemap);
        oliNameToQuoteId = renewalQuote.createQuote(orderIdOrderLineItemMap, packageItemMap, oliIdToOliGiftListMap, orderIdToOrderMap, orderIdToSubZuoraIdMap);
        renewalQuote.zBuildQoutesPackage(orderLineItem1,orderIdToOrderMap, 10, TRUE, 'Subtype', TRUE, TRUE, TRUE, TRUE, 'Renewal', orderIdToSubZuoraIdMap);
        renewalQuote.zBuildPostageQuote(order1, orderLineItem1, 'Subtype', 'Renewal');      
//      renewalQuote.addQuoteChargeToQuote(oliList, packageItemMap, oliNameToQuoteId, prodRatePlanChargemap, prcIdToPrpctMap, prodRatePlanIdRatePlanMap);                       
        Test.StopTest();
        
        try{
        
        renewalQuote.zPopulateQuoteChargePostage(quote.Id, orderLineItem1);
        
        }catch(Exception e) {}
        
        
   
   
    }
    
    
    
    static testMethod void testOnOrdersPerMethod2()
    {
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderLineItemGiftSet = new Set<Id>();
        Set<id> packageIdSet = new Set<Id>();
        Map<id, List<Order_Line_Item__c>> orderIdOrderLineItemMap = new Map<id, List<Order_Line_Item__c>>();
        Map<id, List<Package_Item__c>> packageItemMap = new Map<id, List<Package_Item__c>>();
        Map<id, zqu__ProductRatePlan__c> prodRatePlanIdRatePlanMap = new Map<id, zqu__ProductRatePlan__c>();
        Map<id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanChargemap = new Map<id, List<zqu__ProductRatePlanCharge__c>>();
        Map<Id, List<Order_Line_Item_Gift__c>> oliIdToOliGiftListMap = new Map<Id, List<Order_Line_Item_Gift__c>>();
        Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c> ();
        Map<Id, String> orderIdToSubZuoraIdMap = new Map<Id, String>();
        Map<String, Set<id>> oliNameToQuoteId = new Map<String, Set<id>>();     
        Map<id, zqu__ProductRatePlanChargeTier__c> prcIdToPrpctMap = new Map<id, zqu__ProductRatePlanChargeTier__c>();
        
        Account account1 = new Account(Name = 'SPHAccountTest', RecordTypeId = acctRecType.Id__c, Status__c = 'Active', Active__c = true, Email__c = 'test@sample.com', SMS_Renewal_Notification__c = true, Mobile__c = '09321234567');
        insert account1;
       
        /*Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;*/
            
        /*  Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
                RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Airline' LIMIT 1][0];
                addressRec.RecordTypeId = rt.id;
                //addressRec.Country__c = countr.Id;
                insert addressRec;    */
                
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Gift__c> oliIdToOliGiftList = new List<Order_Line_Item_Gift__c>();
        List<Package_Item__c> packageList = new List<Package_Item__c>();
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = account1.Id;
        defaultPayment.Billing_Type__c = 'Full Prepaid';
        defaultPayment.Zuora__External_Id__c = 'test';
        defaultPayment.Legacy_Billing_Account_Id__c = 'test';
 
        insert defaultPayment;
        
        //Select record type of Account
        Date dateToday = System.today();

       
        Id account1Id = account1.Id;
        Contact contact1 = new Contact(FirstName = 'SPHFirst', LastName = 'SPHLast', AccountId = account1Id, 
        RecordTypeId = contactRecType.Id__c, HomePhone__c = '321324321434',Recipient_Indicator__c = true);//, Address__c =addressRec.Id);
        insert contact1;
        
        Zuora__Subscription__c subscription1 = new Zuora__Subscription__c(Name = 'BA-S00000001', Zuora__SubscriptionEndDate__c = dateToday, 
        Zuora__Account__c = account1Id, Zuora__CustomerAccount__c = defaultPayment.id);        
        insert subscription1;
        
        Id subscription1Id = subscription1.Id;
        
        system.assert(account1Id != null);
        system.assert(subscription1Id != null);
        
        /*Order__c order1 = new Order__c(Account__c = account1Id, Subscription_Start_Date__c = System.today() + 180 ,
        Subscription_End_Date__c = System.today() + 360, New_Quantity__c = 1, Effective_Date__c = System.today() + 180,
        Delivery_Charge_Type__c = 'L', Vendor_Credit__c = 4.00, Order_Type__c = 'Temp Stop', Credit_Balance__c = 0.00,
        Delivery_Charge__c = 0.00, Base_Subscription__c = subscription1Id, Subscriber_Charge__c = 15);*/
        Order__c order1 = TestDataFactory.createOrder(1)[0];
        order1.Account__c = account1Id;
        order1.Recipient_Contact__c = contact1.Id;
        //order1.Recipient_Contact__c= '1';
        //order1.Billing_Account__c = defaultPayment.Id;
            //order.Informed_Customer__c = True;
        order1.Billing_Type__c = 'Full Prepaid';
        order1.Subscriber_Charge__c = 15;
        //order1.Debt_Management_Treatment__c = 'SUBL';
        //order1.Billing_Account_External_ID__c =defaultPayment.Id;
           
        insert order1;
        
        Id order1Id = order1.Id;
        
       
        
        /*Package__c package1 = new Package__c(Name = 'SPHPackage', Package_Code__c = 'SPHFP1', Effective_Start_Date__c = dateToday - 1000,
        Effective_End_Date__c = dateToday + 2000);
        insert package1;        
        Id package1Id = package1.Id;
        */
        Package__c package1 = TestDataFactory.createPackage(1)[0];      
        package1.Package_Type__c = 'Discount';
        package1.Package_Sub_Type__c = 'Single';
        insert package1;
        
        Promotion_Package__c proPack = new Promotion_Package__c();
        proPack.Package_Name__c= package1.Id;
        insert proPack; //
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();//
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);//
        //prdRatePlan.RatePlanCode__c = 'CHGPOS';
        //prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
                        
        zqu__ProductRatePlanCharge__c prdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prdRatePlanCharge.Name = 'Product Rate Plan Charge';  //      
        prdRatePlanCharge.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prdRatePlanCharge.zqu__ZuoraId__c = '3689922200';//     
        insert prdRatePlanCharge;
        //system.assertequals(null,prdRatePlanCharge);
        
        zqu__ProductRatePlanChargeTier__c prdRatePlanChrgTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        prdRatePlanChrgTier.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        insert prdRatePlanChrgTier;
        
//        Package_Item__c packageItem1 = new Package_Item__c(Package__c = package1Id, Name = 'SPHPackageItem');     
        
        Package_Item__c packageItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItem1.Package__c = package1.Id;
        packageItem1.Product_Rate_Plan__c = prdRatePlanCharge.zqu__ProductRatePlan__c;
        packageItem1.Duration_in_months__c = '3';
        packageItem1.Effective_Start_Month__c = '3'; 
        insert packageItem1;
        
        Promotion__c promotion1 = new Promotion__c(Name = 'SPHPromotion', Promotion_Code__c = 'SPPROMO12', Effective_Start_Date__c = dateToday - 1000,
        Effective_End_Date__c = dateToday + 2000, Contract__c = 'No');
        insert promotion1;
        Id promotion1Id = promotion1.Id;
        
        Order_Line_Item__c orderLineItem1 = new Order_Line_Item__c(Main_Package_ID__c = packageItem1.Package__c, Main_Package_Billing_Type__c = 'Full Prepaid', Delivered_By__c = 'None', Main_Package_Type__c = 'Base', Promotion_ID__c = promotion1Id, Qty__c = 1, Start_Date__c = dateToday, End_Date__c = dateToday + 3000, Order__c = order1Id, Term_Length__c=1.5, Contract_End_Date__c = date.today()+30);
        orderLineItem1.Start_Date__c = date.today()+1;
        insert orderLineItem1;
        //system.assertequals(null,orderLineItem1);
        
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        quote.zqu__SubscriptionType__c = 'New Subscription';                    
        quote.zqu__ValidUntil__c = Date.Today().addMonths(1);
        quote.Qty1__c = 12;
        quote.Term_Length1__c = 12;
        quote.zqu__Subscription_Term_Type__c = 'Evergreen';
        quote.zqu__Currency__c = 'USD';
        quote.zqu__InvoiceProcessingOption__c ='Subscription';
        quote.zqu__PaymentTerm__c  = 'Due Upon Receipt';
        quote.zqu__StartDate__c  = date.today();
        quote.zqu__Service_Activation_Date__c  = date.today();
        quote.Acquisition_Type__c= 'CALL';      
        quote.zqu__Account__c  = account1.Id;  
        //quote.Subscription_Type__c = 'Postage';  //
        //quote.Payment_Mode__c = ; 
        //quote.zqu__PaymentMethod__c= ; 
       // quote.Other_PaymentMethod__c  = orderObj.Other_Payment_Mode__c;
        //quote.zqu__SoldToContact__c = orderObj.Recipient_Contact__c;        
        insert quote;
        //system.assertequals(null,quote);
        
        Promotion_Gift__c promotionGift = TestDataFactory.createPromotionGift(1)[0];
        insert promotionGift;
        
        Order_Line_Item_Gift__c OrderLineItemGifts = TestDataFactory.createItemGift(1)[0];
        OrderLineItemGifts.Order_Line_Item__c = orderLineItem1.Id;
        OrderLineItemGifts.Promotion_Gift__c = promotionGift.Id;
        insert OrderLineItemGifts;  

        orderLineItemGiftSet.add(OrderLineItemGifts.id);
        packageIdSet.add(package1.id);
        orderIds.add(order1Id);
        packageList.add(packageItem1);
        oliIdToOliGiftList.add(OrderLineItemGifts);
        oliList.add(orderLineItem1);
        
        orderIdToOrderMap.put(order1.Id, order1);
        orderIdToSubZuoraIdMap.put(order1.Id, 'Test');
        //packageItemMap.put(packageItem1.Id, packageList);
        prodRatePlanIdRatePlanMap.put(prdRatePlan.Id, prdRatePlan);
        //oliIdToOliGiftListMap.put(OrderLineItemGifts.id, oliIdToOliGiftList);
        
        Test.StartTest();
        Renewal_Quote_Handler_Bulk renewalQuote = new Renewal_Quote_Handler_Bulk();
        renewalQuote.bulkQuoteCreation(orderIds, 'Renewal');
        renewalQuote.zBuildPostageQuote(order1, orderLineItem1, 'subtype', 'origin');
        renewalQuote.createQuoteDelivery(order1, orderLineItem1, 'subtype', 'origin');
        renewalQuote.getOrder(orderIds);
        orderIdOrderLineItemMap = renewalQuote.getOrderLineItem(orderIds);
        //karenmae 04.13.15
        //renewalQuote.preparePostageCharge();
        //renewalQuote.zPopulateQuoteChargePostage(quote.Id, orderLineItem1);
        oliIdToOliGiftListMap = renewalQuote.getOrderLineItemGifts(orderLineItemGiftSet);
        packageItemMap = renewalQuote.getPackage(packageIdSet, orderIdOrderLineItemMap);
        prodRatePlanIdRatePlanMap = renewalQuote.getProductRatePlan(packageItemMap);
        prodRatePlanChargemap = renewalQuote.getProdRatePlanCharge(prodRatePlanIdRatePlanMap);
        prcIdToPrpctMap = renewalQuote.getProdRatePlanChargeTier(prodRatePlanChargemap);
        oliNameToQuoteId = renewalQuote.createQuote(orderIdOrderLineItemMap, packageItemMap, oliIdToOliGiftListMap, orderIdToOrderMap, orderIdToSubZuoraIdMap);
        renewalQuote.zBuildQoutesPackage(orderLineItem1,orderIdToOrderMap, 10, TRUE, 'Subtype', TRUE, TRUE, TRUE, TRUE, 'Renewal', orderIdToSubZuoraIdMap);
        renewalQuote.zBuildPostageQuote(order1, orderLineItem1, 'Subtype', 'Renewal');      
//      renewalQuote.addQuoteChargeToQuote(oliList, packageItemMap, oliNameToQuoteId, prodRatePlanChargemap, prcIdToPrpctMap, prodRatePlanIdRatePlanMap);                       
        Test.StopTest();
        
        
         try{
        
        renewalQuote.zPopulateQuoteChargePostage(quote.Id, orderLineItem1);
        
        }catch(Exception e) {}
        
}

   static testMethod void testOnOrdersPerMethod3()
    {
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderLineItemGiftSet = new Set<Id>();
        Set<id> packageIdSet = new Set<Id>();
        Map<id, List<Order_Line_Item__c>> orderIdOrderLineItemMap = new Map<id, List<Order_Line_Item__c>>();
        Map<id, List<Package_Item__c>> packageItemMap = new Map<id, List<Package_Item__c>>();
        Map<id, zqu__ProductRatePlan__c> prodRatePlanIdRatePlanMap = new Map<id, zqu__ProductRatePlan__c>();
        Map<id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanChargemap = new Map<id, List<zqu__ProductRatePlanCharge__c>>();
        Map<Id, List<Order_Line_Item_Gift__c>> oliIdToOliGiftListMap = new Map<Id, List<Order_Line_Item_Gift__c>>();
        Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c> ();
        Map<Id, String> orderIdToSubZuoraIdMap = new Map<Id, String>();
        Map<String, Set<id>> oliNameToQuoteId = new Map<String, Set<id>>();     
        Map<id, zqu__ProductRatePlanChargeTier__c> prcIdToPrpctMap = new Map<id, zqu__ProductRatePlanChargeTier__c>();
        
        Account account1 = new Account(Name = 'SPHAccountTest', RecordTypeId = acctRecType.Id__c, Status__c = 'Active', Active__c = true, Email__c = 'test@sample.com', SMS_Renewal_Notification__c = true, Mobile__c = '09321234567');
        insert account1;
       
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
     
     
     RecordType recordType3 = [SELECT ID, Name FROM RecordType WHERE DeveloperName ='Airline' LIMIT 1];
            
     Address__c addressRec = TestDataFactory.createAddress(1)[0];
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
                //RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Airline' LIMIT 1][0];
                //addressRec.RecordTypeId = recordType3.id;
                 addressRec.RecordType = recordType3;
                //addressRec.Country__c = countr.Id;
                insert addressRec;
                
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Gift__c> oliIdToOliGiftList = new List<Order_Line_Item_Gift__c>();
        List<Package_Item__c> packageList = new List<Package_Item__c>();
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = account1.Id;
        defaultPayment.Billing_Type__c = 'Full Prepaid';
        defaultPayment.Zuora__External_Id__c = 'test';
        defaultPayment.Legacy_Billing_Account_Id__c = 'test';
 
        insert defaultPayment;
        
        //Select record type of Account
        Date dateToday = System.today();

       
        Id account1Id = account1.Id;
        
      
        
        Contact contact1 = TestDataFactory.createContact(1)[0];
        contact1.FirstName = 'SPHFirst';
        contact1.LastName = 'SPHLast';
        contact1.AccountId = account1Id;
        //contact1.RecordTypeId = contactRecType.Id__c;
        contact1.HomePhone__c = '321324321434';
        contact1.Recipient_Indicator__c = true;
        contact1.Address__c =addressRec.Id;
        insert contact1; 
        
        
        Zuora__Subscription__c subscription1 = new Zuora__Subscription__c(Name = 'BA-S00000001', Zuora__SubscriptionEndDate__c = dateToday, 
        Zuora__Account__c = account1Id, Zuora__CustomerAccount__c = defaultPayment.id);        
        insert subscription1;
        
        Id subscription1Id = subscription1.Id;
        
        system.assert(account1Id != null);
        system.assert(subscription1Id != null);
        
        
        Order__c order1 = TestDataFactory.createOrder(1)[0];
        order1.Account__c = account1Id;
        order1.Recipient_Contact__c = contact1.Id;
        //order1.Recipient_Contact__c= '1';
        //order1.Billing_Account__c = defaultPayment.Id;
            //order.Informed_Customer__c = True;
        order1.Billing_Type__c = 'Full Prepaid';
        order1.Subscriber_Charge__c = 15;
        order1.Debt_Management_Treatment__c = GlobalVariableClass.SUBL;
        order1.Payment_Mode__c ='Check';
        order1.Other_Payment_Mode__c = 'Invoice';
        //order1.Debt_Management_Treatment__c = 'SUBL';
        //order1.Billing_Account_External_ID__c =defaultPayment.Id;
           
        insert order1;
        
        Id order1Id = order1.Id;
        
       
        
        
        Package__c package1 = TestDataFactory.createPackage(1)[0];      
        package1.Package_Type__c = 'Discount';
        package1.Package_Sub_Type__c = 'Single';
        package1.Package_Type__c = 'Add On';
        package1.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        package1.Billing_Type__c = 'Full Prepaid';
        package1.Subscription_Type__c = 'Evergreen';
        
        insert package1;
        
        Promotion_Package__c proPack = new Promotion_Package__c();
        proPack.Package_Name__c= package1.Id;
        insert proPack; //
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();//
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);//
        //prdRatePlan.RatePlanCode__c = 'CHGPOS';
        //prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
                        
        zqu__ProductRatePlanCharge__c prdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prdRatePlanCharge.Name = 'Product Rate Plan Charge';  //      
        prdRatePlanCharge.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prdRatePlanCharge.zqu__ZuoraId__c = '3689922200';//     
        insert prdRatePlanCharge;
        //system.assertequals(null,prdRatePlanCharge);
        
        zqu__ProductRatePlanChargeTier__c prdRatePlanChrgTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        prdRatePlanChrgTier.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        insert prdRatePlanChrgTier;
        
//        Package_Item__c packageItem1 = new Package_Item__c(Package__c = package1Id, Name = 'SPHPackageItem');     
        
        Package_Item__c packageItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItem1.Package__c = package1.Id;
        packageItem1.Product_Rate_Plan__c = prdRatePlanCharge.zqu__ProductRatePlan__c;
        packageItem1.Duration_in_months__c = '3';
        packageItem1.Effective_Start_Month__c = '3'; 
        insert packageItem1;
        
        Promotion__c promotion1 = new Promotion__c(Name = 'SPHPromotion', Promotion_Code__c = 'SPPROMO12', Effective_Start_Date__c = dateToday - 1000,
        Effective_End_Date__c = dateToday + 2000, Contract__c = 'No');
        insert promotion1;
        Id promotion1Id = promotion1.Id;
        
        //Order_Line_Item__c orderLineItem1 = new Order_Line_Item__c(Main_Package_ID__c = package1.Id, /*packageItem1.Package__c*/ Main_Package_Billing_Type__c = 'Full Prepaid', Delivered_By__c = 'Vendor', Main_Package_Type__c = 'Base', Promotion_ID__c = promotion1Id, Qty__c = 1, Start_Date__c = dateToday, End_Date__c = dateToday + 3000, Order__c = order1Id, Term_Length__c=1.5, Contract_End_Date__c = date.today()+30,Main_Package_Product_Family__c = 'Default',Addon_Package__c=package1.Id);
        Order_Line_Item__c orderLineItem1 = TestDataFactory.createOrderLineItem(1)[0];
        orderLineItem1.Main_Package_ID__c = package1.Id;
        orderLineItem1.Main_Package_Billing_Type__c = 'Full Prepaid';
        orderLineItem1.Delivered_By__c = 'Mailing Agent';
        orderLineItem1.Main_Package_Type__c = 'Base';
        orderLineItem1.Promotion_ID__c = promotion1Id;
        orderLineItem1.Qty__c = 1;
        orderLineItem1.Start_Date__c = date.today()+1;
        orderLineItem1.End_Date__c = dateToday + 3000;
        orderLineItem1.Order__c = order1Id;
        orderLineItem1.Term_Length__c=null;
        orderLineItem1.Contract_End_Date__c = date.today()+30;
        orderLineItem1.Main_Package_Product_Family__c = 'Default';
        orderLineItem1.Addon_Package__c=package1.Id;
        //orderlineItem1.Vendor_Conversion__c = true;
        //orderlineItem1.Parent_Account__c = account1.Id;
        //orderlineItem1.Vendor_Subscription_ID__c = account1.Id;
        
        //system.assertEquals(null,package1.Id);
                  
        insert orderLineItem1;
        //system.assertequals(null,orderLineItem1);
        
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        //quote.zqu__SubscriptionType__c = 'New Subscription';  
        quote.zqu__SubscriptionType__c = 'Postage';                  
        quote.zqu__ValidUntil__c = Date.Today().addMonths(1);
        quote.Qty1__c = 12;
        quote.Term_Length1__c = 12;
        quote.zqu__Subscription_Term_Type__c = 'Evergreen';
        quote.zqu__Currency__c = 'USD';
        quote.zqu__InvoiceProcessingOption__c ='Subscription';
        quote.zqu__PaymentTerm__c  = 'Due Upon Receipt';
        quote.zqu__StartDate__c  = date.today();
        quote.zqu__Service_Activation_Date__c  = date.today();
        quote.Acquisition_Type__c= 'CALL';      
        quote.zqu__Account__c  = account1.Id;
        quote.zqu__Subscription_Term_Type__c = 'Evergreen'; 
        
        //quote.Subscription_Type__c = 'Postage';  //
        //quote.Payment_Mode__c = ; 
        //quote.zqu__PaymentMethod__c= ; 
       // quote.Other_PaymentMethod__c  = orderObj.Other_Payment_Mode__c;
        //quote.zqu__SoldToContact__c = orderObj.Recipient_Contact__c;        
        insert quote;
        //system.assertequals(null,quote);
        
        
        
        zqu__QuoteCharge__c zqc= TestDataFactory.createQuoteCharge(1)[0];
        zqc.zqu__Quote__c=quote.Id;
        zqc.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        insert zqc;
         
        
        Promotion_Gift__c promotionGift = TestDataFactory.createPromotionGift(1)[0];
        insert promotionGift;
        
        Order_Line_Item_Gift__c OrderLineItemGifts = TestDataFactory.createItemGift(1)[0];
        OrderLineItemGifts.Order_Line_Item__c = orderLineItem1.Id;
        OrderLineItemGifts.Promotion_Gift__c = promotionGift.Id;
        insert OrderLineItemGifts;  

        orderLineItemGiftSet.add(OrderLineItemGifts.id);
        packageIdSet.add(package1.id);
        orderIds.add(order1Id);
        packageList.add(packageItem1);
        oliIdToOliGiftList.add(OrderLineItemGifts);
        oliList.add(orderLineItem1);
        
        orderIdToOrderMap.put(order1.Id, order1);
        orderIdToSubZuoraIdMap.put(order1.Id, 'Test');
        //packageItemMap.put(packageItem1.Id, packageList);
        prodRatePlanIdRatePlanMap.put(prdRatePlan.Id, prdRatePlan);
        //oliIdToOliGiftListMap.put(OrderLineItemGifts.id, oliIdToOliGiftList);
        
        Renewal_Quote_Handler_Bulk renewalQuote = new Renewal_Quote_Handler_Bulk();
        renewalQuote.createQuoteDelivery(order1,orderLineItem1, 'test','test string');
        
        
}
     static testMethod void testOnOrdersPerMethod4()
    {
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderLineItemGiftSet = new Set<Id>();
        Set<id> packageIdSet = new Set<Id>();
        Map<id, List<Order_Line_Item__c>> orderIdOrderLineItemMap = new Map<id, List<Order_Line_Item__c>>();
        Map<id, List<Package_Item__c>> packageItemMap = new Map<id, List<Package_Item__c>>();
        Map<id, zqu__ProductRatePlan__c> prodRatePlanIdRatePlanMap = new Map<id, zqu__ProductRatePlan__c>();
        Map<id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanChargemap = new Map<id, List<zqu__ProductRatePlanCharge__c>>();
        Map<Id, List<Order_Line_Item_Gift__c>> oliIdToOliGiftListMap = new Map<Id, List<Order_Line_Item_Gift__c>>();
        Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c> ();
        Map<Id, String> orderIdToSubZuoraIdMap = new Map<Id, String>();
        Map<String, Set<id>> oliNameToQuoteId = new Map<String, Set<id>>();     
        Map<id, zqu__ProductRatePlanChargeTier__c> prcIdToPrpctMap = new Map<id, zqu__ProductRatePlanChargeTier__c>();
        
        Account account1 = new Account(Name = 'SPHAccountTest', RecordTypeId = acctRecType.Id__c, Status__c = 'Active', Active__c = true, Email__c = 'test@sample.com', SMS_Renewal_Notification__c = true, Mobile__c = '09321234567');
        insert account1;
       
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
     
     
     RecordType recordType3 = [SELECT ID, Name FROM RecordType WHERE DeveloperName ='Airline' LIMIT 1];
            
     Address__c addressRec = TestDataFactory.createAddress(1)[0];
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
                //RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Airline' LIMIT 1][0];
                //addressRec.RecordTypeId = recordType3.id;
                 addressRec.RecordType = recordType3;
                //addressRec.Country__c = countr.Id;
                insert addressRec;
                
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Gift__c> oliIdToOliGiftList = new List<Order_Line_Item_Gift__c>();
        List<Package_Item__c> packageList = new List<Package_Item__c>();
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = account1.Id;
        defaultPayment.Billing_Type__c = 'Full Prepaid';
        defaultPayment.Zuora__External_Id__c = 'test';
        defaultPayment.Legacy_Billing_Account_Id__c = 'test';
 
        insert defaultPayment;
        
        //Select record type of Account
        Date dateToday = System.today();

       
        Id account1Id = account1.Id;
        
      
        
        Contact contact1 = TestDataFactory.createContact(1)[0];
        contact1.FirstName = 'SPHFirst';
        contact1.LastName = 'SPHLast';
        contact1.AccountId = account1Id;
        //contact1.RecordTypeId = contactRecType.Id__c;
        contact1.HomePhone__c = '321324321434';
        contact1.Recipient_Indicator__c = true;
        contact1.Address__c =addressRec.Id;
        insert contact1; 
        
        
        Zuora__Subscription__c subscription1 = new Zuora__Subscription__c(Name = 'BA-S00000001', Zuora__SubscriptionEndDate__c = dateToday, 
        Zuora__Account__c = account1Id, Zuora__CustomerAccount__c = defaultPayment.id);        
        insert subscription1;
        
        Id subscription1Id = subscription1.Id;
        
        system.assert(account1Id != null);
        system.assert(subscription1Id != null);
        
        
        Order__c order1 = TestDataFactory.createOrder(1)[0];
        order1.Account__c = account1Id;
        order1.Recipient_Contact__c = contact1.Id;
        //order1.Recipient_Contact__c= '1';
        //order1.Billing_Account__c = defaultPayment.Id;
            //order.Informed_Customer__c = True;
        order1.Billing_Type__c = 'Full Prepaid';
        order1.Subscriber_Charge__c = 15;
        order1.Debt_Management_Treatment__c = GlobalVariableClass.SUBH;
        order1.Payment_Mode__c ='Check';
        order1.Other_Payment_Mode__c = 'Invoice';
        //order1.Debt_Management_Treatment__c = 'SUBL';
        //order1.Billing_Account_External_ID__c =defaultPayment.Id;
           
        insert order1;
        
        Id order1Id = order1.Id;
        
       
        
        
        Package__c package1 = TestDataFactory.createPackage(1)[0];      
        package1.Package_Type__c = 'Discount';
        package1.Package_Sub_Type__c = 'Single';
        package1.Package_Type__c = 'Add On';
        package1.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        package1.Billing_Type__c = 'Full Prepaid';
        package1.Subscription_Type__c = 'Evergreen';
        
        insert package1;
        
        Promotion_Package__c proPack = new Promotion_Package__c();
        proPack.Package_Name__c= package1.Id;
        insert proPack; //
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();//
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);//
        //prdRatePlan.RatePlanCode__c = 'CHGPOS';
        //prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
                        
        zqu__ProductRatePlanCharge__c prdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prdRatePlanCharge.Name = 'Product Rate Plan Charge';  //      
        prdRatePlanCharge.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prdRatePlanCharge.zqu__ZuoraId__c = '3689922200';//     
        insert prdRatePlanCharge;
        //system.assertequals(null,prdRatePlanCharge);
        
        zqu__ProductRatePlanChargeTier__c prdRatePlanChrgTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        prdRatePlanChrgTier.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        insert prdRatePlanChrgTier;
        
//        Package_Item__c packageItem1 = new Package_Item__c(Package__c = package1Id, Name = 'SPHPackageItem');     
        
        Package_Item__c packageItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItem1.Package__c = package1.Id;
        packageItem1.Product_Rate_Plan__c = prdRatePlanCharge.zqu__ProductRatePlan__c;
        packageItem1.Duration_in_months__c = '3';
        packageItem1.Effective_Start_Month__c = '3'; 
        insert packageItem1;
        
        Promotion__c promotion1 = new Promotion__c(Name = 'SPHPromotion', Promotion_Code__c = 'SPPROMO12', Effective_Start_Date__c = dateToday - 1000,
        Effective_End_Date__c = dateToday + 2000, Contract__c = 'No');
        insert promotion1;
        Id promotion1Id = promotion1.Id;
        
        //Order_Line_Item__c orderLineItem1 = new Order_Line_Item__c(Main_Package_ID__c = package1.Id, /*packageItem1.Package__c*/ Main_Package_Billing_Type__c = 'Full Prepaid', Delivered_By__c = 'Vendor', Main_Package_Type__c = 'Base', Promotion_ID__c = promotion1Id, Qty__c = 1, Start_Date__c = dateToday, End_Date__c = dateToday + 3000, Order__c = order1Id, Term_Length__c=1.5, Contract_End_Date__c = date.today()+30,Main_Package_Product_Family__c = 'Default',Addon_Package__c=package1.Id);
        Order_Line_Item__c orderLineItem1 = TestDataFactory.createOrderLineItem(1)[0];
        orderLineItem1.Main_Package_ID__c = package1.Id;
        orderLineItem1.Main_Package_Billing_Type__c = 'Full Prepaid';
        orderLineItem1.Delivered_By__c = 'Mailing Agent';
        orderLineItem1.Main_Package_Type__c = 'Base';
        orderLineItem1.Promotion_ID__c = promotion1Id;
        orderLineItem1.Qty__c = 1;
        orderLineItem1.Start_Date__c = date.today()+1;
        orderLineItem1.End_Date__c = dateToday + 3000;
        orderLineItem1.Order__c = order1Id;
        orderLineItem1.Term_Length__c=null;
        orderLineItem1.Contract_End_Date__c = date.today()+30;
        orderLineItem1.Main_Package_Product_Family__c = 'Default';
        orderLineItem1.Addon_Package__c=package1.Id;
        //orderlineItem1.Vendor_Conversion__c = true;
        //orderlineItem1.Parent_Account__c = account1.Id;
        //orderlineItem1.Vendor_Subscription_ID__c = account1.Id;
        
        //system.assertEquals(null,package1.Id);
                  
        insert orderLineItem1;
        //system.assertequals(null,orderLineItem1);
        
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        //quote.zqu__SubscriptionType__c = 'New Subscription';  
        quote.zqu__SubscriptionType__c = 'Postage';                  
        quote.zqu__ValidUntil__c = Date.Today().addMonths(1);
        quote.Qty1__c = 12;
        quote.Term_Length1__c = 12;
        quote.zqu__Subscription_Term_Type__c = 'Evergreen';
        quote.zqu__Currency__c = 'USD';
        quote.zqu__InvoiceProcessingOption__c ='Subscription';
        quote.zqu__PaymentTerm__c  = 'Due Upon Receipt';
        quote.zqu__StartDate__c  = date.today();
        quote.zqu__Service_Activation_Date__c  = date.today();
        quote.Acquisition_Type__c= 'CALL';      
        quote.zqu__Account__c  = account1.Id;
        quote.zqu__Subscription_Term_Type__c = 'Evergreen'; 
        
        //quote.Subscription_Type__c = 'Postage';  //
        //quote.Payment_Mode__c = ; 
        //quote.zqu__PaymentMethod__c= ; 
       // quote.Other_PaymentMethod__c  = orderObj.Other_Payment_Mode__c;
        //quote.zqu__SoldToContact__c = orderObj.Recipient_Contact__c;        
        insert quote;
        //system.assertequals(null,quote);
        
        
        
        zqu__QuoteCharge__c zqc= TestDataFactory.createQuoteCharge(1)[0];
        zqc.zqu__Quote__c=quote.Id;
        zqc.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        insert zqc;
         
        
        Promotion_Gift__c promotionGift = TestDataFactory.createPromotionGift(1)[0];
        insert promotionGift;
        
        Order_Line_Item_Gift__c OrderLineItemGifts = TestDataFactory.createItemGift(1)[0];
        OrderLineItemGifts.Order_Line_Item__c = orderLineItem1.Id;
        OrderLineItemGifts.Promotion_Gift__c = promotionGift.Id;
        insert OrderLineItemGifts;  

        orderLineItemGiftSet.add(OrderLineItemGifts.id);
        packageIdSet.add(package1.id);
        orderIds.add(order1Id);
        packageList.add(packageItem1);
        oliIdToOliGiftList.add(OrderLineItemGifts);
        oliList.add(orderLineItem1);
        
        orderIdToOrderMap.put(order1.Id, order1);
        orderIdToSubZuoraIdMap.put(order1.Id, 'Test');
        //packageItemMap.put(packageItem1.Id, packageList);
        prodRatePlanIdRatePlanMap.put(prdRatePlan.Id, prdRatePlan);
        //oliIdToOliGiftListMap.put(OrderLineItemGifts.id, oliIdToOliGiftList);
        
        Renewal_Quote_Handler_Bulk renewalQuote = new Renewal_Quote_Handler_Bulk();
        renewalQuote.createQuoteDelivery(order1,orderLineItem1, 'test','test string');
        
        
}
     static testMethod void testOnOrdersPerMethod5()
    {
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderLineItemGiftSet = new Set<Id>();
        Set<id> packageIdSet = new Set<Id>();
        Map<id, List<Order_Line_Item__c>> orderIdOrderLineItemMap = new Map<id, List<Order_Line_Item__c>>();
        Map<id, List<Package_Item__c>> packageItemMap = new Map<id, List<Package_Item__c>>();
        Map<id, zqu__ProductRatePlan__c> prodRatePlanIdRatePlanMap = new Map<id, zqu__ProductRatePlan__c>();
        Map<id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanChargemap = new Map<id, List<zqu__ProductRatePlanCharge__c>>();
        Map<Id, List<Order_Line_Item_Gift__c>> oliIdToOliGiftListMap = new Map<Id, List<Order_Line_Item_Gift__c>>();
        Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c> ();
        Map<Id, String> orderIdToSubZuoraIdMap = new Map<Id, String>();
        Map<String, Set<id>> oliNameToQuoteId = new Map<String, Set<id>>();     
        Map<id, zqu__ProductRatePlanChargeTier__c> prcIdToPrpctMap = new Map<id, zqu__ProductRatePlanChargeTier__c>();
        
        Account account1 = new Account(Name = 'SPHAccountTest', RecordTypeId = acctRecType.Id__c, Status__c = 'Active', Active__c = true, Email__c = 'test@sample.com', SMS_Renewal_Notification__c = true, Mobile__c = '09321234567');
        insert account1;
       
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
     
     
     //RecordType recordType3 = [SELECT Id, Name FROM RecordType WHERE DeveloperName ='Airline' LIMIT 1];
     //RecordType recordType3 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Address' AND Name ='Airline' LIMIT 1][0];
    /* List<RecordType> recordType3 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Address' AND DeveloperName ='Airline' LIMIT 1];
     // RecordType recordType3 = [SELECT id, name FROM RecordType WHERE name = 'Airline' LIMIT 1][0];
      
          
     Address__c addressRec = TestDataFactory.createAddress(1)[0];
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
              
                
                 addressRec.RecordType = recordType3[0];
                //addressRec.Country__c = countr.Id;
                insert addressRec;*/
                
                
      RecordType recordType3 = [SELECT ID, Name FROM RecordType WHERE DeveloperName ='Airline' LIMIT 1];
            
       Address__c addressRec = TestDataFactory.createAddress(1)[0];
                //addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Level_Number__c = 'AB';
                addressRec.Unit_Number__c = 'abcdef';
                //RecordType rt = [SELECT id, name FROM RecordType WHERE name = 'Airline' LIMIT 1][0];
                //addressRec.RecordTypeId = recordType3.id;
                 addressRec.RecordType = recordType3;
                //addressRec.Country__c = countr.Id;
                insert addressRec;
                
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Gift__c> oliIdToOliGiftList = new List<Order_Line_Item_Gift__c>();
        List<Package_Item__c> packageList = new List<Package_Item__c>();
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = account1.Id;
        defaultPayment.Billing_Type__c = 'Full Prepaid';
        defaultPayment.Zuora__External_Id__c = 'test';
        defaultPayment.Legacy_Billing_Account_Id__c = 'test';
 
        insert defaultPayment;
        
        //Select record type of Account
        Date dateToday = System.today();

       
        Id account1Id = account1.Id;
        
      
        
        Contact contact1 = TestDataFactory.createContact(1)[0];
        contact1.FirstName = 'SPHFirst';
        contact1.LastName = 'SPHLast';
        contact1.AccountId = account1Id;
        //contact1.RecordTypeId = contactRecType.Id__c;
        contact1.HomePhone__c = '321324321434';
        contact1.Recipient_Indicator__c = true;
        contact1.Address__c =addressRec.Id;
        insert contact1; 
        
        
        Zuora__Subscription__c subscription1 = new Zuora__Subscription__c(Name = 'BA-S00000001', Zuora__SubscriptionEndDate__c = dateToday, 
        Zuora__Account__c = account1Id, Zuora__CustomerAccount__c = defaultPayment.id);        
        insert subscription1;
        
        Id subscription1Id = subscription1.Id;
        
        system.assert(account1Id != null);
        system.assert(subscription1Id != null);
        
        
        Order__c order1 = TestDataFactory.createOrder(1)[0];
        order1.Account__c = account1Id;
        order1.Recipient_Contact__c = contact1.Id;
        //order1.Recipient_Contact__c= '1';
        //order1.Billing_Account__c = defaultPayment.Id;
            //order.Informed_Customer__c = True;
        order1.Billing_Type__c = 'Full Prepaid';
        order1.Subscriber_Charge__c = 15;
        order1.Debt_Management_Treatment__c = GlobalVariableClass.GOVT;
        order1.Payment_Mode__c ='Check';
        order1.Other_Payment_Mode__c = 'Invoice';
        //order1.Recipient_Type__c = contact1.Id;
        //order1.Debt_Management_Treatment__c = 'SUBL';
        //order1.Billing_Account_External_ID__c =defaultPayment.Id;
           
        //insert order1;
        
        Id order1Id = order1.Id;
        
       List<Order__c> ordList = new List<Order__c> ();
       ordList.add(order1);
       insert ordList;
        
       
        
        
        Package__c package1 = TestDataFactory.createPackage(1)[0];      
        package1.Package_Type__c = 'Discount';
        package1.Package_Sub_Type__c = 'Single';
        package1.Package_Type__c = 'Add On';
        package1.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        package1.Billing_Type__c = 'Full Prepaid';
        package1.Subscription_Type__c = 'Termed';
        package1.Subscription_Period__c = '1';
        
        
        insert package1;
        
        /*Promotion_Package__c proPack = new Promotion_Package__c();
        proPack.Package_Name__c= package1.Id;
        insert proPack;*/
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductCode__c = 'TestCode';
        zProduct.ProductType__c = 'TestProductType';
        zProduct.ProductSubType__c ='Newspaper';
        insert zProduct;
        
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.Name = 'Test Name';
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30); prdRatePlan.RatePlanCode__c = 'CHGPOS'; prdRatePlan.zqu__Deleted__c = false;
        //prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
                        
        zqu__ProductRatePlanCharge__c prdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prdRatePlanCharge.Name = 'Product Rate Plan Charge';  //      
        prdRatePlanCharge.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prdRatePlanCharge.zqu__ZuoraId__c = '3689922200';//     
        insert prdRatePlanCharge;
        //system.assertequals(null,prdRatePlanCharge);
        
        zqu__ProductRatePlanChargeTier__c prdRatePlanChrgTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        prdRatePlanChrgTier.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        insert prdRatePlanChrgTier;
        
//        Package_Item__c packageItem1 = new Package_Item__c(Package__c = package1Id, Name = 'SPHPackageItem');     
        
        Package_Item__c packageItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItem1.Package__c = package1.Id;
        packageItem1.Product_Rate_Plan__c = prdRatePlanCharge.zqu__ProductRatePlan__c;
        packageItem1.Duration_in_months__c = '3';
        packageItem1.Effective_Start_Month__c = '3'; 
        insert packageItem1;
        
        Promotion__c promotion1 = new Promotion__c(Name = 'SPHPromotion', Promotion_Code__c = 'SPPROMO12', Effective_Start_Date__c = dateToday - 1000,
        Effective_End_Date__c = dateToday + 2000, Contract__c = 'No');
        insert promotion1;
        Id promotion1Id = promotion1.Id;
        
        //Order_Line_Item__c orderLineItem1 = new Order_Line_Item__c(Main_Package_ID__c = package1.Id, /*packageItem1.Package__c*/ Main_Package_Billing_Type__c = 'Full Prepaid', Delivered_By__c = 'Vendor', Main_Package_Type__c = 'Base', Promotion_ID__c = promotion1Id, Qty__c = 1, Start_Date__c = dateToday, End_Date__c = dateToday + 3000, Order__c = order1Id, Term_Length__c=1.5, Contract_End_Date__c = date.today()+30,Main_Package_Product_Family__c = 'Default',Addon_Package__c=package1.Id);
        Order_Line_Item__c orderLineItem1 = TestDataFactory.createOrderLineItem(1)[0];
        orderLineItem1.Main_Package_ID__c = package1.Id;
        orderLineItem1.Main_Package_Billing_Type__c = 'Full Prepaid';
        orderLineItem1.Delivered_By__c = GlobalVariableClass.OLIDELIVEREDBY_VENDOR;
        orderLineItem1.Main_Package_Type__c = 'Base';
        orderLineItem1.Promotion_ID__c = promotion1Id;
        orderLineItem1.Qty__c = 1;
        orderLineItem1.Start_Date__c = date.today()+1;
        orderLineItem1.End_Date__c = dateToday + 3000;
        //orderLineItem1.Order__c = order1Id;
        orderLineItem1.Order__c = ordList[0].Id;
        orderLineItem1.Term_Length__c=null;
        orderLineItem1.Contract_End_Date__c = date.today()+30;
        orderLineItem1.Main_Package_Product_Family__c = 'Default';
        orderLineItem1.Addon_Package__c=package1.Id;
        //orderlineItem1.Vendor_Conversion__c = true;
        //orderlineItem1.Parent_Account__c = account1.Id;
        //orderlineItem1.Vendor_Subscription_ID__c = account1.Id;
        
        //system.assertEquals(null,package1.Id);
                  
        insert orderLineItem1;
        //system.assertequals(null,orderLineItem1);
        
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        //quote.zqu__SubscriptionType__c = 'New Subscription';  
        quote.zqu__SubscriptionType__c = 'Postage';                  
        quote.zqu__ValidUntil__c = Date.Today().addMonths(1);
        quote.Qty1__c = 12;
        quote.Term_Length1__c = 12;
        quote.zqu__Subscription_Term_Type__c = 'Evergreen';
        quote.zqu__Currency__c = 'USD';
        quote.zqu__InvoiceProcessingOption__c ='Subscription';
        quote.zqu__PaymentTerm__c  = 'Due Upon Receipt';
        quote.zqu__StartDate__c  = date.today();
        quote.zqu__Service_Activation_Date__c  = date.today();
        quote.Acquisition_Type__c= 'CALL';      
        quote.zqu__Account__c  = account1.Id;
        
        
        //quote.Subscription_Type__c = 'Postage';  //
        //quote.Payment_Mode__c = ; 
        //quote.zqu__PaymentMethod__c= ; 
       // quote.Other_PaymentMethod__c  = orderObj.Other_Payment_Mode__c;
        //quote.zqu__SoldToContact__c = orderObj.Recipient_Contact__c;        
        insert quote;
        //system.assertequals(null,quote);
        
        
        
        zqu__QuoteCharge__c zqc= TestDataFactory.createQuoteCharge(1)[0];
        zqc.zqu__Quote__c=quote.Id;
        zqc.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        insert zqc;
         
        
        Promotion_Gift__c promotionGift = TestDataFactory.createPromotionGift(1)[0];
        insert promotionGift;
        
        Order_Line_Item_Gift__c OrderLineItemGifts = TestDataFactory.createItemGift(1)[0];
        OrderLineItemGifts.Order_Line_Item__c = orderLineItem1.Id;
        OrderLineItemGifts.Promotion_Gift__c = promotionGift.Id;
        insert OrderLineItemGifts;  

        orderLineItemGiftSet.add(OrderLineItemGifts.id);
        packageIdSet.add(package1.id);
        //orderIds.add(order1Id);
        orderIds.add(ordList[0].Id);
        packageList.add(packageItem1);
        oliIdToOliGiftList.add(OrderLineItemGifts);
        oliList.add(orderLineItem1);
        
        //orderIdToOrderMap.put(order1.Id, order1);
        //orderIdToSubZuoraIdMap.put(order1.Id, 'Test');
        orderIdToOrderMap.put(ordList[0].Id, order1);
        orderIdToSubZuoraIdMap.put(ordList[0].Id, 'Test');
        //packageItemMap.put(packageItem1.Id, packageList);
        prodRatePlanIdRatePlanMap.put(prdRatePlan.Id, prdRatePlan);
        //oliIdToOliGiftListMap.put(OrderLineItemGifts.id, oliIdToOliGiftList);
        
        
        Map<Id, zqu__ProductRatePlan__c> postagePrpIdToPrpMap = new Map<Id, zqu__ProductRatePlan__c>();
        postagePrpIdToPrpMap.put(account1Id,prdRatePlan);   
        
        Renewal_Quote_Handler_Bulk renewalQuote = new Renewal_Quote_Handler_Bulk();
        renewalQuote.createQuoteDelivery(order1,orderLineItem1, 'test','test string');
        renewalQuote.zBuildPostageQuote(order1,orderLineItem1,'test','test');
        renewalQuote.getDeliveryCharge(ordList);
        
        
        
        Map<String, Date> subIdToStopDateMap = new Map<String, Date>();
        subIdToStopDateMap.put('Test', date.today());
        
        
        usageCreationForStopSubscription ucfss = new usageCreationForStopSubscription ();
        ucfss.createUsage(subIdToStopDateMap);                 
        
}
    static testMethod void newTest001()
    {
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderLineItemGiftSet = new Set<Id>();
        Set<id> packageIdSet = new Set<Id>();
        Map<id, List<Order_Line_Item__c>> orderIdOrderLineItemMap = new Map<id, List<Order_Line_Item__c>>();
        Map<id, List<Package_Item__c>> packageItemMap = new Map<id, List<Package_Item__c>>();
        Map<id, zqu__ProductRatePlan__c> prodRatePlanIdRatePlanMap = new Map<id, zqu__ProductRatePlan__c>();
        Map<id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanChargemap = new Map<id, List<zqu__ProductRatePlanCharge__c>>();
        Map<Id, List<Order_Line_Item_Gift__c>> oliIdToOliGiftListMap = new Map<Id, List<Order_Line_Item_Gift__c>>();
        Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c> ();
        Map<Id, String> orderIdToSubZuoraIdMap = new Map<Id, String>();
        Map<String, Set<id>> oliNameToQuoteId = new Map<String, Set<id>>();     
        Map<id, zqu__ProductRatePlanChargeTier__c> prcIdToPrpctMap = new Map<id, zqu__ProductRatePlanChargeTier__c>();
        
        Account account1 = new Account(Name = 'SPHAccountTest', RecordTypeId = acctRecType.Id__c, Status__c = 'Active', Active__c = true, Email__c = 'test@sample.com', SMS_Renewal_Notification__c = true, Mobile__c = '09321234567');
        insert account1;
       
       
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Gift__c> oliIdToOliGiftList = new List<Order_Line_Item_Gift__c>();
        List<Package_Item__c> packageList = new List<Package_Item__c>();
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = account1.Id;
        defaultPayment.Zuora__External_Id__c = 'Test';
        defaultPayment.Billing_Type__c = 'Full Prepaid';
 
        insert defaultPayment;
        
        //Select record type of Account
        Date dateToday = System.today();

       
        Id account1Id = account1.Id;
        Contact contact1 = new Contact(FirstName = 'SPHFirst', LastName = 'SPHLast', AccountId = account1Id, 
        RecordTypeId = contactRecType.Id__c, HomePhone__c = '321324321434',Recipient_Indicator__c = true);//, Address__c =addressRec.Id);
        insert contact1;
        
        Zuora__Subscription__c subscription1 = new Zuora__Subscription__c(Name = 'BA-S00000001', Zuora__SubscriptionEndDate__c = dateToday, 
        Zuora__Account__c = account1Id, Zuora__CustomerAccount__c = defaultPayment.id);        
        insert subscription1;
        
        Id subscription1Id = subscription1.Id;
        
        system.assert(account1Id != null);
        system.assert(subscription1Id != null);
        
       
        Order__c order1 = TestDataFactory.createOrder(1)[0];
        order1.Account__c = account1Id;
        order1.Recipient_Contact__c = contact1.Id;
        //order1.Recipient_Contact__c= '1';
        order1.Billing_Account__c = defaultPayment.Id;
            //order.Informed_Customer__c = True;
        order1.Billing_Type__c = 'Full Prepaid';
        order1.Subscriber_Charge__c = 15;
        order1.Payment_Mode__c ='Check';
        order1.Other_Payment_Mode__c = 'Invoice';
           
        insert order1;
        
        Id order1Id = order1.Id;
        
        
        Package__c package1 = TestDataFactory.createPackage(1)[0];      
        package1.Package_Type__c = 'Discount';
        package1.Package_Sub_Type__c = 'Single';
        package1.Subscription_Type__c = 'Termed';
        insert package1;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        prdRatePlan.RatePlanCode__c = 'CHGPOS';
        prdRatePlan.zqu__Deleted__c = false;
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();//
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);//
      
        insert prdRatePlan;
                        
        zqu__ProductRatePlanCharge__c prdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prdRatePlanCharge.Name = 'Product Rate Plan Charge';  //      
        prdRatePlanCharge.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prdRatePlanCharge.zqu__ZuoraId__c = '3689922200';//     
        insert prdRatePlanCharge;
        //system.assertequals(null,prdRatePlanCharge);
        
        zqu__ProductRatePlanChargeTier__c prdRatePlanChrgTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        prdRatePlanChrgTier.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        insert prdRatePlanChrgTier;
        
//        Package_Item__c packageItem1 = new Package_Item__c(Package__c = package1Id, Name = 'SPHPackageItem');     
        
        Package_Item__c packageItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItem1.Package__c = package1.Id;
        packageItem1.Product_Rate_Plan__c = prdRatePlanCharge.zqu__ProductRatePlan__c;
        packageItem1.Duration_in_months__c = '3';
        packageItem1.Effective_Start_Month__c = '3'; 
        insert packageItem1;
        
        Promotion__c promotion1 = new Promotion__c(Name = 'SPHPromotion', Promotion_Code__c = 'SPPROMO12', Effective_Start_Date__c = dateToday - 1000,
        Effective_End_Date__c = dateToday + 2000, Contract__c = 'No');
        insert promotion1;
        Id promotion1Id = promotion1.Id;
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        insert subsVen;
        
        Order_Line_Item__c orderLineItem1 = new Order_Line_Item__c(Main_Package_ID__c = packageItem1.Package__c, Main_Package_Billing_Type__c = 'Full Prepaid', Delivered_By__c = 'None', Main_Package_Type__c = 'Base', Promotion_ID__c = promotion1Id, Qty__c = 1, Start_Date__c = dateToday, End_Date__c = dateToday + 3000, Order__c = order1Id, Term_Length__c=1.5, Contract_End_Date__c = date.today()+30);
        orderLineItem1.Start_Date__c = date.today()+1;
        orderLineItem1.Vendor_Conversion__c = true;
        orderLineItem1.Vendor_Subscription_ID__c = subsVen.id;
        insert orderLineItem1;
        //system.assertequals(null,orderLineItem1);
        
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        quote.zqu__SubscriptionType__c = 'New Subscription';                    
        quote.zqu__ValidUntil__c = Date.Today().addMonths(1);
        quote.Qty1__c = 12;
        quote.Term_Length1__c = 12;
        quote.zqu__Subscription_Term_Type__c = 'Evergreen';
        quote.zqu__Currency__c = 'USD';
        quote.zqu__InvoiceProcessingOption__c ='Subscription';
        quote.zqu__PaymentTerm__c  = 'Due Upon Receipt';
        quote.zqu__StartDate__c  = date.today();
        quote.zqu__Service_Activation_Date__c  = date.today();
        quote.Acquisition_Type__c= 'CALL';      
        quote.zqu__Account__c  = account1.Id;        
        
        quote.Payment_Mode__c = 'Check'; 
        quote.zqu__PaymentMethod__c= 'Check' ; 
        quote.Other_PaymentMethod__c  = 'Invoice';
        quote.zqu__SoldToContact__c = contact1.Id;
        quote.Subscription_Type__c = 'Postage';        
        insert quote;
        //system.assertEquals(null,quote);
        
        Promotion_Gift__c promotionGift = TestDataFactory.createPromotionGift(1)[0];
        insert promotionGift;
        
        Order_Line_Item_Gift__c OrderLineItemGifts = TestDataFactory.createItemGift(1)[0];
        OrderLineItemGifts.Order_Line_Item__c = orderLineItem1.Id;
        OrderLineItemGifts.Promotion_Gift__c = promotionGift.Id;
        insert OrderLineItemGifts;  

        orderLineItemGiftSet.add(OrderLineItemGifts.id);
        packageIdSet.add(package1.id);
        orderIds.add(order1Id);
        packageList.add(packageItem1);
        oliIdToOliGiftList.add(OrderLineItemGifts);
        oliList.add(orderLineItem1);
        
        orderIdToOrderMap.put(order1.Id, order1);
        orderIdToSubZuoraIdMap.put(order1.Id, 'Test');
        //packageItemMap.put(packageItem1.Id, packageList);
        prodRatePlanIdRatePlanMap.put(prdRatePlan.Id, prdRatePlan);
        //oliIdToOliGiftListMap.put(OrderLineItemGifts.id, oliIdToOliGiftList);
        
        zqu__QuoteCharge__c zqc= TestDataFactory.createQuoteCharge(1)[0];
        zqc.Name = 'Product Rate Plan Charge';
        zqc.zqu__Quote__c=quote.Id;
        zqc.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        zqc.zqu__Quantity__c = 1;
        insert zqc;
         
         
         //new
         List<zqu__ProductRatePlanCharge__c> zprpc = new List<zqu__ProductRatePlanCharge__c>();
         zprpc.add(prdRatePlanCharge);
        
         
        //zqu__ProductRatePlan__c postagePrp 
         Map<Id, List<zqu__ProductRatePlanCharge__c>> postagePrpIdToPrpcListMap = new Map<Id, List<zqu__ProductRatePlanCharge__c>>();
         postagePrpIdToPrpcListMap.put(prdRatePlan.Id,zprpc);
        
        //end
        
        
        Test.StartTest();
        try
        {
            Renewal_Quote_Handler_Bulk renewalQuote = new Renewal_Quote_Handler_Bulk(); 
            renewalQuote.zBuildQoutesPackage(orderLineItem1,orderIdToOrderMap, 10, TRUE, 'Subtype', TRUE, TRUE, TRUE, TRUE, 'Renewal', orderIdToSubZuoraIdMap);   
            renewalQuote.zBuildPostageQuote(order1, orderLineItem1, 'Subtype', 'Renewal'); 
            renewalQuote.zPopulateQuoteChargePostage(quote.Id, orderLineItem1);     
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }     
        Test.StopTest();
    }
    
      static testMethod void newTest()
    {
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderLineItemGiftSet = new Set<Id>();
        Set<id> packageIdSet = new Set<Id>();
        Map<id, List<Order_Line_Item__c>> orderIdOrderLineItemMap = new Map<id, List<Order_Line_Item__c>>();
        Map<id, List<Package_Item__c>> packageItemMap = new Map<id, List<Package_Item__c>>();
        Map<id, zqu__ProductRatePlan__c> prodRatePlanIdRatePlanMap = new Map<id, zqu__ProductRatePlan__c>();
        Map<id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanChargemap = new Map<id, List<zqu__ProductRatePlanCharge__c>>();
        Map<Id, List<Order_Line_Item_Gift__c>> oliIdToOliGiftListMap = new Map<Id, List<Order_Line_Item_Gift__c>>();
        Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c> ();
        Map<Id, String> orderIdToSubZuoraIdMap = new Map<Id, String>();
        Map<String, Set<id>> oliNameToQuoteId = new Map<String, Set<id>>();     
        Map<id, zqu__ProductRatePlanChargeTier__c> prcIdToPrpctMap = new Map<id, zqu__ProductRatePlanChargeTier__c>();
        
        
        Account account1 = new Account(Name = 'SPHAccountTest', RecordTypeId = acctRecType.Id__c, Status__c = 'Active', Active__c = true, Email__c = 'test@sample.com', SMS_Renewal_Notification__c = true, Mobile__c = '09321234567');
        insert account1;
       
        
                
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Gift__c> oliIdToOliGiftList = new List<Order_Line_Item_Gift__c>();
        List<Package_Item__c> packageList = new List<Package_Item__c>();
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = account1.Id;
        defaultPayment.Billing_Type__c = 'Full Prepaid';
 
        insert defaultPayment;
        
        
        Date dateToday = System.today();

       
        Id account1Id = account1.Id;
        Contact contact1 = new Contact(FirstName = 'SPHFirst', LastName = 'SPHLast', AccountId = account1Id, 
        RecordTypeId = contactRecType.Id__c, HomePhone__c = '321324321434',Recipient_Indicator__c = true);//, Address__c =addressRec.Id);
        insert contact1;
        
        Zuora__Subscription__c subscription1 = new Zuora__Subscription__c(Name = 'BA-S00000001', Zuora__SubscriptionEndDate__c = dateToday, 
        Zuora__Account__c = account1Id, Zuora__CustomerAccount__c = defaultPayment.id);        
        insert subscription1;
        
        Id subscription1Id = subscription1.Id;
        
        system.assert(account1Id != null);
        system.assert(subscription1Id != null);
        
       
        Order__c order1 = TestDataFactory.createOrder(1)[0];
        order1.Account__c = account1Id;
        order1.Recipient_Contact__c = contact1.Id;
        order1.Billing_Account__c = defaultPayment.Id;
        order1.Billing_Type__c = 'Full Prepaid';
        order1.Subscriber_Charge__c = 15;
        order1.Payment_Mode__c ='Check';
        order1.Other_Payment_Mode__c = 'Invoice';
           
        insert order1;
        
        Id order1Id = order1.Id;

        Package__c package1 = TestDataFactory.createPackage(1)[0];      
        package1.Package_Type__c = 'Add On';
        package1.Billing_Type__c = 'Full Prepaid';
        package1.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        package1.Package_Sub_Type__c = 'Single';
        package1.Subscription_Type__c = 'Termed';
        insert package1;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();//
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);//
        insert prdRatePlan;
                        
        zqu__ProductRatePlanCharge__c prdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        prdRatePlanCharge.Name = 'Product Rate Plan Charge';  //      
        prdRatePlanCharge.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prdRatePlanCharge.zqu__ZuoraId__c = '3689922200';//     
        insert prdRatePlanCharge;
       
        
        zqu__ProductRatePlanChargeTier__c prdRatePlanChrgTier = TestDataFactory.createProductRatePlanChargeTier(1)[0];
        prdRatePlanChrgTier.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        insert prdRatePlanChrgTier;
        
   
        
        Package_Item__c packageItem1 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItem1.Package__c = package1.Id;
        packageItem1.Product_Rate_Plan__c = prdRatePlanCharge.zqu__ProductRatePlan__c;
        packageItem1.Duration_in_months__c = '3';
        packageItem1.Effective_Start_Month__c = '3'; 
        insert packageItem1;
        
        Promotion__c promotion1 = new Promotion__c(Name = 'SPHPromotion', Promotion_Code__c = 'SPPROMO12', Effective_Start_Date__c = dateToday - 1000,
        Effective_End_Date__c = dateToday + 2000, Contract__c = 'No');
        insert promotion1;
        Id promotion1Id = promotion1.Id;
        
        Order_Line_Item__c orderLineItem1 = new Order_Line_Item__c(Main_Package_ID__c = packageItem1.Package__c, Main_Package_Billing_Type__c = 'Full Prepaid', Delivered_By__c = 'None', Main_Package_Type__c = 'Base', Promotion_ID__c = promotion1Id, Qty__c = 1, Start_Date__c = dateToday, End_Date__c = dateToday + 3000, Order__c = order1Id, Term_Length__c=1.5, Contract_End_Date__c = date.today()+30);
        orderLineItem1.Start_Date__c = date.today()+1;
        orderLineItem1.Delivered_By__c = GlobalVariableClass.OLIDELIVEREDBY_VENDOR;
        orderLineItem1.Addon_Package__c = package1.id;
        orderLineItem1.Main_Package_Product_Family__c = 'Default';
        orderLineItem1.Main_Package_Billing_Type__c = 'Full Prepaid';
        insert orderLineItem1;
        
        
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Name = 'Quote Name';
        quote.zqu__SubscriptionType__c = 'New Subscription';                    
        quote.zqu__ValidUntil__c = Date.Today().addMonths(1);
        quote.Qty1__c = 12;
        quote.Term_Length1__c = 12;
        quote.zqu__Subscription_Term_Type__c = 'Evergreen';
        quote.zqu__Currency__c = 'USD';
        quote.zqu__InvoiceProcessingOption__c ='Subscription';
        quote.zqu__PaymentTerm__c  = 'Due Upon Receipt';
        quote.zqu__StartDate__c  = date.today();
        quote.zqu__Service_Activation_Date__c  = date.today();
        quote.Acquisition_Type__c= 'CALL';      
        quote.zqu__Account__c  = account1.Id;        
        
        quote.Payment_Mode__c = 'Check'; 
        quote.zqu__PaymentMethod__c= 'Check' ; 
        quote.Other_PaymentMethod__c  = 'Invoice';
        quote.zqu__SoldToContact__c = contact1.Id;
        quote.Subscription_Type__c = 'Postage';        
        insert quote;
        
        
        Promotion_Gift__c promotionGift = TestDataFactory.createPromotionGift(1)[0];
        insert promotionGift;
        
        Order_Line_Item_Gift__c OrderLineItemGifts = TestDataFactory.createItemGift(1)[0];
        OrderLineItemGifts.Order_Line_Item__c = orderLineItem1.Id;
        OrderLineItemGifts.Promotion_Gift__c = promotionGift.Id;
        insert OrderLineItemGifts;  

        orderLineItemGiftSet.add(OrderLineItemGifts.id);
        packageIdSet.add(package1.id);
        orderIds.add(order1Id);
        packageList.add(packageItem1);
        oliIdToOliGiftList.add(OrderLineItemGifts);
        oliList.add(orderLineItem1);
        
        orderIdToOrderMap.put(order1.Id, order1);
        orderIdToSubZuoraIdMap.put(order1.Id, 'Test');
        
        prodRatePlanIdRatePlanMap.put(prdRatePlan.Id, prdRatePlan);
        
        
        zqu__QuoteCharge__c zqc= TestDataFactory.createQuoteCharge(1)[0];
        zqc.Name = 'Product Rate Plan Charge';
        zqc.zqu__Quote__c=quote.Id;
        zqc.zqu__ProductRatePlanCharge__c = prdRatePlanCharge.Id;
        zqc.zqu__Quantity__c = 1;
        insert zqc;
         
         
         //new
         List<zqu__ProductRatePlanCharge__c> zprpc = new List<zqu__ProductRatePlanCharge__c>();
         zprpc.add(prdRatePlanCharge);
        
         
        //zqu__ProductRatePlan__c postagePrp 
         Map<Id, List<zqu__ProductRatePlanCharge__c>> postagePrpIdToPrpcListMap = new Map<Id, List<zqu__ProductRatePlanCharge__c>>();
         postagePrpIdToPrpcListMap.put(prdRatePlan.Id,zprpc);
        
        //end
        
        
        Test.StartTest();
        try
        {
            Renewal_Quote_Handler_Bulk renewalQuote = new Renewal_Quote_Handler_Bulk();
            renewalQuote.bulkQuoteCreation(orderIds, 'Renewal');
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        Test.StopTest();
        
        
   
   
    }
}