@isTest(SeeAllData = True)
private class StartStopTest{
    static testmethod void startStopMethod1(){
        Map<String, SObject> sObjMap = new Map<String,SObject>();
        sObjMap = TestDataFactory.createSubscriptionPackage();
        Zuora__Subscription__c zSub = (Zuora__Subscription__c) sObjMap.get('Zuora__Subscription__c');
        Test.startTest();
        insert zSub;
        
        Order__c orderRec = (Order__c) sObjMap.get('Order__c');
        orderRec.Base_Subscription__c = zSub.id;
        orderRec.Order_Type__c = 'Start';
        orderRec.Delivery_Charge_Type__c = 'S';
        orderRec.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        orderRec.Vendor_Credit__c = 10000;
        update orderRec;
        zqu__ProductRatePlanCharge__c zprp = new zqu__ProductRatePlanCharge__c();
        zprp.zqu__ProductRatePlan__c = sObjMap.get('zqu__ProductRatePlan__c').id;
        zprp.zqu__Type__c = 'Recurring';
        zprp.zqu__Discount_Level__c = 'RatePlan';
        zprp.zqu__Model__c = 'Discount-Percentage';
        zprp.zqu__ZuoraId__c = '1234567';
        //insert zprp;
        Promotion__c promo = new Promotion__c();
        promo.RecordTypeId = [Select Id From RecordType Where SObjectType = 'Promotion__c' And Name = 'Gift Promotion' LIMIT 1].id;
        promo.Name = 'Promo Name';
        promo.Promotion_Code__c = 'ABCDE';
        promo.Effective_Start_Date__c = date.today();
        promo.Contract__c = 'No';
        promo.Effective_End_Date__c = date.today().addDays(30);
        promo.Promotion_Type__c = 'Gift Promotion';
        //insert promo;
        insert new List<SObject>{zprp, promo};
        
        Promotion_Package__c proPack = new Promotion_Package__c();
        proPack.Promotion__c = promo.Id;
        proPack.Package_Name__c= sObjMap.get('Package__c').id;
        insert proPack;
        PageReference pRef = Page.startstop;
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getParameters().put('id', orderRec.id);
        ApexPages.CurrentPage().getParameters().put('accountId', orderRec.Account__c);
        startstop sStop = new startstop();
        sStop.initialize();
        sStop.selectedOrderLineItem = sObjMap.get('Order_Line_Item__c').id;
        sStop.retrieveOrderLineItem();
        sStop.addOrderLineItem();
        sStop.searchFrom = 'Package';
        sStop.searchText = 'Pack name';
        sStop.searchBillingType = 'Full Prepaid';
        sStop.executeSearch();
        sStop.searchFrom = 'Promotion';
        sStop.searchText = 'Promo Name';
        sStop.searchBillingType = 'Full Prepaid';
        sStop.executeSearch();
        sStop.getAcquisitionTypes();
        sStop.getDeliveryChargeTypes();
        sStop.getBillingAccountOptions();
        sStop.getSource();
        sStop.clearPaymentMethod();
        sStop.clearOtherPaymentMethod();
        sStop.getselectedchangeOfSubscriptionOptions();
        sStop.setchangeOfSubscriptionOptions('quantity');
        sStop.ChangeOrderAction();
        sStop.setchangeOfSubscriptionOptions('package');
        sStop.ChangeOrderAction();
        sStop.getListchangeOfSubscriptionOptions();
        sStop.populateSubscriptionDetail();
        sStop.populateAddOn();
        sStop.save();
        sStop.cancel();
        sStop.populatePromotionGifts();
        
        Test.stopTest();
    }
    static testmethod void startStopMethod2(){
        Map<String, SObject> sObjMap = new Map<String,SObject>();
        sObjMap = TestDataFactory.createSubscriptionPackage();
        Zuora__Subscription__c zSub = (Zuora__Subscription__c) sObjMap.get('Zuora__Subscription__c');
        Test.startTest();
        insert zSub;
        
        Order__c orderRec = (Order__c) sObjMap.get('Order__c');
        orderRec.Base_Subscription__c = zSub.id;
        orderRec.Order_Type__c = 'Start';
        orderRec.Delivery_Charge_Type__c = 'S';
        orderRec.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
        orderRec.Vendor_Credit__c = 10000;
        update orderRec;
        zqu__ProductRatePlanCharge__c zprp = new zqu__ProductRatePlanCharge__c();
        zprp.zqu__ProductRatePlan__c = sObjMap.get('zqu__ProductRatePlan__c').id;
        zprp.zqu__Type__c = 'Recurring';
        zprp.zqu__Discount_Level__c = 'RatePlan';
        zprp.zqu__Model__c = 'Discount-Percentage';
        zprp.zqu__ZuoraId__c = '1234567';
        //insert zprp;
        Promotion__c promo = new Promotion__c();
        promo.RecordTypeId = [Select Id From RecordType Where SObjectType = 'Promotion__c' And Name = 'Gift Promotion' LIMIT 1].id;
        promo.Name = 'Promo Name';
        promo.Promotion_Code__c = 'ABCDE';
        promo.Effective_Start_Date__c = date.today();
        promo.Contract__c = 'No';
        promo.Effective_End_Date__c = date.today().addDays(30);
        promo.Promotion_Type__c = 'Gift Promotion';
        //insert promo;
        insert new List<SObject>{zprp, promo};
        
        Promotion_Package__c proPack = new Promotion_Package__c();
        proPack.Promotion__c = promo.Id;
        proPack.Package_Name__c= sObjMap.get('Package__c').id;
        insert proPack;
        PageReference pRef = Page.startstop;
        Test.setCurrentPage(pRef);
        //ApexPages.CurrentPage().getParameters().put('id', orderRec.id);
        ApexPages.CurrentPage().getParameters().put('accountId', orderRec.Account__c);
        startstop sStop = new startstop();
        sStop.earliestStart(sObjMap.get('Package__c').id);
        Test.stopTest();
    }
}