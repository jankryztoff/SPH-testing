@isTest(seeAllData=true)
private class PromoEligibilityRuleTest{
    static testMethod void testPromoEligibilityRuleVendor(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = billAcc.id;
        subs.Zuora__SubscriptionStartDate__c = date.today();
        subs.Term_Length1__c = '0.0';
        insert subs;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = subs.Id;
        insert order;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Code__c = '01';
        insert pack;
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs.Id].Zuora__SubscriptionEndDate__c)+2;
        orderline.Main_Package_ID__c = pack.Id;
        insert orderline;
        
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub:subRecs){
            sub.Zuora__CustomerAccount__c = billAcc.id;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Order_Line_Item_Number__c = orderline.Id;
        }
        insert subRecs;
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subRecs[0].Id;
            sp.Zuora__ProductSKU__c = 'SKU01';
            sp.Zuora__RatePlanName__c = 'Name';
        }
        insert spc;
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU01';
        zp.ProductPlatform__c = 'Print';
        insert zp;
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.Name = 'Name';
        prp.zqu__ZProduct__c = zp.Id;
        prp.RatePlanType__c = 'Bill Plan';
        prp.zqu__Deleted__c = false;
        insert prp;
        
        List<Promotion__c> prom = TestDataFactory.createPromotion(2);
        for(Promotion__c p: prom){
            p.Promotion_Code__c = '01';
            p.Contract_Period__c = '01';
        }
        insert prom;
        
        List<Promotion_Package__c> promPack = TestDataFactory.createPromotionPackage(2);
        for(Promotion_Package__c pp:promPack){
            pp.Promotion__c = prom[0].Id;
            pp.Package_Name__c = pack.Id;
        }
        insert promPack;
        
        Eligibility_Rule__c eligRule = TestDataFactory.createEligibilityRule(1)[0];
        eligRule.Action__c = 'Add';
        eligRule.Customer_Status__c = 'Vendor Customer';
        insert eligRule;
        
        List<Promotion_Eligibility_Rule__c> peRule = TestDataFactory.createPromEligibilityRule(2);
        for(Promotion_Eligibility_Rule__c p: peRule){
            p.Promotion__c = prom[0].Id;
            p.Package_List__c = '01';
            p.Eligibility_Rule__c = eligRule.Id;
        }
        insert peRule;
        
        Set<String> code = new Set<String>();
        code.add('01');
        Map<String , Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
        promoCodeContractSet.put('01', code);
        //end test data
    
        test.startTest();
            PromoEligibilityRule perVendor = new PromoEligibilityRule();
            perVendor.getEligibility(acc.Id, 'Add', promoCodeContractSet, '', subRecs[0].Id, true);
        test.stopTest();
    }
    
    static testMethod void testPromoEligibilityRuleNew(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = billAcc.id;
        subs.Zuora__SubscriptionStartDate__c = date.today();
        subs.Term_Length1__c = '0.0';
        insert subs;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = subs.Id;
        insert order;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Code__c = '01';
        insert pack;
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs.Id].Zuora__SubscriptionEndDate__c)+2;
        orderline.Main_Package_ID__c = pack.Id;
        insert orderline;
        
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub:subRecs){
            sub.Zuora__CustomerAccount__c = billAcc.id;
            //sub.Zuora__Account__c = acc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Order_Line_Item_Number__c = orderline.Id;
        }
        insert subRecs;
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subRecs[0].Id;
            sp.Zuora__ProductSKU__c = 'SKU01';
            sp.Zuora__RatePlanName__c = 'Name';
        }
        insert spc;
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU01';
        insert zp;
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.Name = 'Name';
        prp.zqu__ZProduct__c = zp.Id;
        prp.RatePlanType__c = 'Bill Plan';
        prp.zqu__Deleted__c = false;
        insert prp;
        
        List<Promotion__c> prom = TestDataFactory.createPromotion(2);
        for(Promotion__c p: prom){
            p.Promotion_Code__c = '01';
            p.Contract_Period__c = '01';
        }
        insert prom;
        
        List<Promotion_Package__c> promPack = TestDataFactory.createPromotionPackage(2);
        for(Promotion_Package__c pp:promPack){
            pp.Promotion__c = prom[0].Id;
            pp.Package_Name__c = pack.Id;
        }
        insert promPack;
        
        Eligibility_Rule__c eligRule = TestDataFactory.createEligibilityRule(1)[0];
        eligRule.Action__c = 'Add';
        eligRule.Customer_Status__c = 'New Customer';
        insert eligRule;
        
        List<Promotion_Eligibility_Rule__c> peRule = TestDataFactory.createPromEligibilityRule(2);
        for(Promotion_Eligibility_Rule__c p: peRule){
            p.Promotion__c = prom[0].Id;
            p.Package_List__c = '01';
            p.Eligibility_Rule__c = eligRule.Id;
        }
        insert peRule;
        
        Set<String> code = new Set<String>();
        code.add('01');
        Map<String , Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
        promoCodeContractSet.put('01', code);
        //end test data
    
        test.startTest();
            PromoEligibilityRule per = new PromoEligibilityRule();
            per.getEligibility(acc.Id, 'Add', promoCodeContractSet, '', subRecs[0].Id, false);
        test.stopTest();
    }
    
    static testMethod void testPromoEligibilityRuleExisting(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = billAcc.id;
        subs.Zuora__SubscriptionStartDate__c = date.today();
        subs.Term_Length1__c = '0.0';
        insert subs;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = subs.Id;
        insert order;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Code__c = 'TABL';
        pack.Product_Family_Current_Package__c = 'TABL';
        insert pack;
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs.Id].Zuora__SubscriptionEndDate__c)+2;
        orderline.Main_Package_ID__c = pack.Id;
        insert orderline;
        
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub:subRecs){
            sub.Zuora__CustomerAccount__c = billAcc.id;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Order_Line_Item_Number__c = orderline.Id;
            sub.Main_Package__c = pack.Id;
        }
        insert subRecs;
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subRecs[0].Id;
            sp.Zuora__ProductSKU__c = 'SKU01';
            sp.Zuora__RatePlanName__c = 'Name';
        }
        insert spc;
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU01';
        zp.ProductPlatform__c = 'Print';
        insert zp;
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.Name = 'Name';
        prp.zqu__ZProduct__c = zp.Id;
        prp.RatePlanType__c = 'Bill Plan';
        prp.zqu__Deleted__c = false;
        insert prp;
        
        List<Promotion__c> prom = TestDataFactory.createPromotion(2);
        for(Promotion__c p: prom){
            p.Promotion_Code__c = 'TABL';
            p.Contract_Period__c = 'TABL';
        }
        insert prom;
        
        List<Promotion_Package__c> promPack = TestDataFactory.createPromotionPackage(2);
        for(Promotion_Package__c pp:promPack){
            pp.Promotion__c = prom[0].Id;
            pp.Package_Name__c = pack.Id;
        }
        insert promPack;
        
        Eligibility_Rule__c eligRule = TestDataFactory.createEligibilityRule(1)[0];
        eligRule.Action__c = 'Add';
        eligRule.Customer_Status__c = 'Existing Customer';
        eligRule.Subsciber_Status__c = 'New Subscriber';
        eligRule.Contract_Subscription_Rule__c = 'Subscription End Date';
        eligRule.Condition__c = '>';
        //eligRule.Contract_Status__c = 'With Contract';
        insert eligRule;
        
        List<Promotion_Eligibility_Rule__c> peRule = TestDataFactory.createPromEligibilityRule(2);
        for(Promotion_Eligibility_Rule__c p: peRule){
            p.Promotion__c = prom[0].Id;
            p.Package_List__c = 'TABL';
            p.Eligibility_Rule__c = eligRule.Id;
            p.Product_Family__c = 'TABL';
            p.Date__c = date.today();
            //p.Days__c = '30';
            p.Current_Platform__c = 'Print';
        }
        insert peRule;
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        insert pf;
        
        Promo_Eligibility_Rule_Product_Family__c perpf = TestDataFactory.createPromoEligRuleProdFamily(1)[0];
        perpf.Promotion_Eligibility_Rule__c = peRule[0].Id;
        perpf.Product_Family__c = pf.Id;
        insert perpf;
        
        Promotion_Eligibility_Rule__c peQ = [SELECT Product_Family__c FROM Promotion_Eligibility_Rule__c WHERE Id=:peRule[0].Id];
        Zuora__Subscription__c subQ = [SELECT Main_Package_1__r.Product_Family_Current_Package__c, Main_Package_1__c FROM Zuora__Subscription__c  WHERE id=:subrecs[0].Id];
        
        Package__c packQ = [SELECT Product_Family_Current_Package__c FROM Package__c WHERE id=:pack.Id];
        system.assertEquals(packQ.Product_Family_Current_Package__c, 'TABL');
        
        system.assertNotEquals(null, subQ.Main_Package_1__c);
        
        system.assertEquals(peQ.Product_Family__c, subQ.Main_Package_1__r.Product_Family_Current_Package__c);
        
        Set<String> code = new Set<String>();
        code.add('TABL');
        Map<String , Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
        promoCodeContractSet.put('TABL', code);
        //end test data
    
        test.startTest();
            PromoEligibilityRule per = new PromoEligibilityRule();
            per.getEligibility(acc.Id, 'Add', promoCodeContractSet, '', subRecs[0].Id, false);
            
            pack.Product_Family_Current_Package__c = null;
            update pack;
            PromoEligibilityRule per2 = new PromoEligibilityRule();
            per2.getEligibility(acc.Id, 'Add', promoCodeContractSet, '', subRecs[0].Id, false);
            
            eligRule.Condition__c = '<';
            update eligRule;
            peRule[0].Date__c = null;
            peRule[0].Days__c = '30';
            peRule[1].Date__c = null;
            peRule[1].Days__c = '30';
            update peRule;
            PromoEligibilityRule per3 = new PromoEligibilityRule();
            per3.getEligibility(acc.Id, 'Add', promoCodeContractSet, '', subRecs[0].Id, false);
            
            subRecs[0].Main_Package__c = null;
            subRecs[1].Main_Package__c = null;
            update subRecs;
            pack.Product_Family_Current_Package__c = '01';
            update pack;
            PromoEligibilityRule per4 = new PromoEligibilityRule();
            per4.getEligibility(acc.Id, 'Add', promoCodeContractSet, '', subRecs[0].Id, false);
            
            pack.Package_Type__c = 'Bundle';
            update pack;
            subRecs[0].Main_Package__c = pack.Id;
            subRecs[1].Main_Package__c = pack.Id;    
            update subRecs;
            eligRule.Action__c = 'Change';
            eligRule.Contract_Status__c = 'With Contract';
            update eligRule;
            PromoEligibilityRule per5 = new PromoEligibilityRule();
            per5.getEligibility(acc.Id, 'Change', promoCodeContractSet, '', subRecs[0].Id, false);
        test.stopTest();
    }
    
    static testMethod void testPromoEligibilityRuleExisting2(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = billAcc.id;
        subs.Zuora__SubscriptionStartDate__c = date.today();
        subs.Term_Length1__c = '0.0';
        insert subs;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = subs.Id;
        insert order;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Code__c = 'TABL';
        pack.Product_Family_Current_Package__c = '01';
        pack.Package_Type__c = 'Bundle';
        insert pack;
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subs.Id].Zuora__SubscriptionEndDate__c)+2;
        orderline.Main_Package_ID__c = pack.Id;
        insert orderline;
        
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub:subRecs){
            sub.Zuora__CustomerAccount__c = billAcc.id;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscription_Type__c = 'Publication';
            sub.Order_Line_Item_Number__c = orderline.Id;
            sub.Main_Package__c = pack.Id;
            sub.Contract_End_Date__c = string.valueOf(date.today()+10);
        }
        insert subRecs;
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp: spc){
            sp.Zuora__Subscription__c = subRecs[0].Id;
            sp.Zuora__ProductSKU__c = 'SKU01';
            sp.Zuora__RatePlanName__c = 'Name';
        }
        insert spc;
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU01';
        zp.ProductPlatform__c = 'Print';
        insert zp;
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.Name = 'Name';
        prp.zqu__ZProduct__c = zp.Id;
        prp.RatePlanType__c = 'Bill Plan';
        prp.zqu__Deleted__c = false;
        insert prp;
        
        List<Promotion__c> prom = TestDataFactory.createPromotion(2);
        for(Promotion__c p: prom){
            p.Promotion_Code__c = 'TABL';
            p.Contract_Period__c = 'TABL';
        }
        insert prom;
        
        List<Promotion_Package__c> promPack = TestDataFactory.createPromotionPackage(2);
        for(Promotion_Package__c pp:promPack){
            pp.Promotion__c = prom[0].Id;
            pp.Package_Name__c = pack.Id;
        }
        insert promPack;
        
        Eligibility_Rule__c eligRule = TestDataFactory.createEligibilityRule(1)[0];
        eligRule.Action__c = 'Change';
        eligRule.Customer_Status__c = 'Existing Customer';
        //eligRule.Subsciber_Status__c = 'New Subscriber';
        eligRule.Contract_Subscription_Rule__c = 'Subscription End Date';
        eligRule.Condition__c = '<';
        eligRule.Contract_Status__c = 'With Contract';
        insert eligRule;
        
        List<Promotion_Eligibility_Rule__c> peRule = TestDataFactory.createPromEligibilityRule(2);
        for(Promotion_Eligibility_Rule__c p: peRule){
            p.Promotion__c = prom[0].Id;
            p.Package_List__c = 'TABL';
            p.Eligibility_Rule__c = eligRule.Id;
            p.Product_Family__c = 'TABL';
            //p.Date__c = date.today();
            p.Days__c = '30';
            p.Current_Platform__c = 'Print';
        }
        insert peRule;
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        insert pf;
        
        Promo_Eligibility_Rule_Product_Family__c perpf = TestDataFactory.createPromoEligRuleProdFamily(1)[0];
        perpf.Promotion_Eligibility_Rule__c = peRule[0].Id;
        perpf.Product_Family__c = pf.Id;
        insert perpf;
        
       /* Promotion_Eligibility_Rule__c peQ = [SELECT Product_Family__c FROM Promotion_Eligibility_Rule__c WHERE Id=:peRule[0].Id];
        Zuora__Subscription__c subQ = [SELECT Main_Package_1__r.Product_Family_Current_Package__c, Main_Package_1__c FROM Zuora__Subscription__c  WHERE id=:subrecs[0].Id];
        
        Package__c packQ = [SELECT Product_Family_Current_Package__c FROM Package__c WHERE id=:pack.Id];
        system.assertEquals(packQ.Product_Family_Current_Package__c, 'TABL');
        
        system.assertNotEquals(null, subQ.Main_Package_1__c);
        
        system.assertEquals(peQ.Product_Family__c, subQ.Main_Package_1__r.Product_Family_Current_Package__c); */
        
        Set<String> code = new Set<String>();
        code.add('TABL');
        Map<String , Set<String>> promoCodeContractSet = new Map<String , Set<String>>();
        promoCodeContractSet.put('TABL', code);
        //end test data
    
        test.startTest();
            PromoEligibilityRule per = new PromoEligibilityRule();
            per.getEligibility(acc.Id, 'Change', promoCodeContractSet, '', subRecs[0].Id, false);
            
            peRule[0].Date__c = date.today();
            peRule[0].Days__c = null;
            peRule[1].Date__c = date.today();
            peRule[1].Days__c = null;
            update peRule;
            
            PromoEligibilityRule per2 = new PromoEligibilityRule();
            per2.getEligibility(acc.Id, 'Change', promoCodeContractSet, '', subRecs[0].Id, false);
            
            subRecs[0].Contract_End_Date__c = null;
            subRecs[1].Contract_End_Date__c = null;
            update subRecs;
            
            eligRule.Contract_Status__c = 'Without Contract';
            update eligRule;
            
            PromoEligibilityRule per3 = new PromoEligibilityRule();
            per3.getEligibility(acc.Id, 'Change', promoCodeContractSet, '', subRecs[0].Id, false);
        test.stopTest();
    }
}