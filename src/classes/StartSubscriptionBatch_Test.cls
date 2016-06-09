/*
* Class Name: <StartSubscriptionBatch_Test>
* @author: Reszel Garrie Pineda
* Date: 2/16/2015
* Requirement/Project Name: <SPH>
* @description: Test class for StartSubscriptionBatch
*/
@isTest (seeAllData= True)
private class StartSubscriptionBatch_Test {
    
    public static Key_Id__c acctRecType = [Select Id, Name, Id__c, Type__c FROM Key_Id__c WHERE NAME = 'Account_Direct Individual' LIMIT 1];
    public static Key_Id__c contactRecType = [Select Id, Name, Id__c, Type__c FROM Key_Id__c WHERE NAME = 'Contact_Customer Contact' LIMIT 1];
    
    /* @description: This method checks StartSubscriptionBatch methods*/ 
    static testmethod void testStartSubscriptionBatch(){
        
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
        
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Gift__c> oliIdToOliGiftList = new List<Order_Line_Item_Gift__c>();
        List<Package_Item__c> packageList = new List<Package_Item__c>();
        //Select record type of Account
        Date dateToday = System.today().addDays(1);
        
        //test data creation
        Account account1 = new Account(Name = 'SPHAccountTest', RecordTypeId = acctRecType.Id__c, Status__c = 'Active', Active__c = true, Email__c = 'test@sample.com', Mobile__c = '1234567');
        insert account1;
        Id account1Id = account1.Id;
        Contact contact1 = new Contact(FirstName = 'SPHFirst', LastName = 'SPHLast', AccountId = account1Id, 
        RecordTypeId = contactRecType.Id__c, HomePhone__c = '321324321434');
        insert contact1;
        Zuora__Subscription__c subscription1 = new Zuora__Subscription__c(Name = 'BA-S00000001', Zuora__SubscriptionEndDate__c = dateToday, 
        Zuora__Account__c = account1Id);
        
        try
        {
            insert subscription1;
        } catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
    
        Id subscription1Id = subscription1.Id;
        
        Order__c order1 = new Order__c(Account__c = account1Id, Subscription_Start_Date__c = System.today() + 180 ,
        Subscription_End_Date__c = System.today() + 360, New_Quantity__c = 1, Effective_Date__c = System.today() + 180,
        Delivery_Charge_Type__c = 'L', Vendor_Credit__c = 4.00, Order_Type__c = 'Temp Stop', Credit_Balance__c = 0.00,
        Delivery_Charge__c = 0.00, Base_Subscription__c = subscription1Id);
        insert order1;        
        Id order1Id = order1.Id;
        
        Package__c package1 = TestDataFactory.createPackage(1)[0];      
        package1.Package_Type__c = 'Discount';
        package1.Package_Sub_Type__c = 'Single';
        insert package1;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c = 'Bill Plan';
        insert prdRatePlan;
                        
        zqu__ProductRatePlanCharge__c prdRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];        
        prdRatePlanCharge.zqu__ProductRatePlan__c = prdRatePlan.Id;     
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
        Order_Line_Item__c orderLineItem1 = new Order_Line_Item__c(Main_Package_ID__c = packageItem1.Package__c, Main_Package_Billing_Type__c = 'Full Prepaid', Delivered_By__c = 'None', Main_Package_Type__c = 'Base', Promotion_ID__c = promotion1Id, Qty__c = 1, Start_Date__c = dateToday, End_Date__c = dateToday + 3000, Order__c = order1Id);
        insert orderLineItem1;
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];        
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
        //packageItemMap.put(packageItem1.Id, packageList);
        prodRatePlanIdRatePlanMap.put(prdRatePlan.Id, prdRatePlan);
        //oliIdToOliGiftListMap.put(OrderLineItemGifts.id, oliIdToOliGiftList);        
        
        Test.StartTest();
        
        Renewal_Quote_Handler_Bulk renewalQuote = new Renewal_Quote_Handler_Bulk();
        
        renewalQuote.bulkQuoteCreation(orderIds, 'Renewal');
        renewalQuote.getOrder(orderIds);
        
        orderIdOrderLineItemMap = renewalQuote.getOrderLineItem(orderIds);
        
       // melchris 04-13-15 compile error fix
       // renewalQuote.preparePostageCharge();
        try
        {
           renewalQuote.zPopulateQuoteChargePostage(quote.Id, orderLineItem1);
        }
        catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
        oliIdToOliGiftListMap = renewalQuote.getOrderLineItemGifts(orderLineItemGiftSet);
        packageItemMap = renewalQuote.getPackage(packageIdSet, orderIdOrderLineItemMap);
        prodRatePlanIdRatePlanMap = renewalQuote.getProductRatePlan(packageItemMap);
        prodRatePlanChargemap = renewalQuote.getProdRatePlanCharge(prodRatePlanIdRatePlanMap);
        prcIdToPrpctMap = renewalQuote.getProdRatePlanChargeTier(prodRatePlanChargemap);
        oliNameToQuoteId = renewalQuote.createQuote(orderIdOrderLineItemMap, packageItemMap, oliIdToOliGiftListMap, orderIdToOrderMap, orderIdToSubZuoraIdMap);
        renewalQuote.zBuildQoutesPackage(orderLineItem1,orderIdToOrderMap, 10, TRUE, 'Subtype', TRUE, TRUE, TRUE, TRUE, 'Renewal', orderIdToSubZuoraIdMap);
        renewalQuote.zBuildPostageQuote(order1, orderLineItem1, 'Subtype', 'Renewal');      
//      renewalQuote.addQuoteChargeToQuote(oliList, packageItemMap, oliNameToQuoteId, prodRatePlanChargemap, prcIdToPrpctMap, prodRatePlanIdRatePlanMap);                       
        
         Set<String> newOrderIdSet_str = new Set<String>();
         Set<Id> newOrderIdSet_id = new Set<Id>();
         Set<String> allQuoteIds = new Set<String>();
       
        newOrderIdSet_id.add(order1.id);
        System.assertEquals(true, newOrderIdSet_id<>null);
        newOrderIdSet_str.add(String.valueOf(order1.id));
        
        StartSubscriptionBatch batch = new StartSubscriptionBatch(newOrderIdSet_str);
        Database.executeBatch(batch, 200);
        
        Test.stopTest();
    }//end of testStartSubscriptionBatch
}//end of StartSubscriptionBatch_Test