@isTest
private class usageCreationForStopSubscriptionTest{
    static testMethod void testusageCreationForStopSubscription(){
        Map<String, Date> mapSub = new Map<String, Date>();
        Integer counter;
        
        //start custom settings
        List<Other__c> other = new List<Other__c>{new Other__c(Name = 'DTL', Value__c = '23:59'),
            new Other__c(Name = 'Order_Type Renewa',Value__c = 'Renewal')};
        database.insert(other);
        //end custom settings
        
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Package__c pack2 = new Package__c();
        pack2.Effective_End_Date__c = date.today()+3;
        pack2.Effective_Start_Date__c = date.today();
        pack2.Package_Code__c = 'code123';
        database.insert(pack2);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Magazine';
        database.insert(zProduct);
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.2';
        database.insert(sub);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = sub.Id;
        database.insert(order);
        
        Zuora__Subscription__c subQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Id=:sub.Id];
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = subQ.Zuora__SubscriptionEndDate__c.addDays(1);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Main_Package_Billing_Type__c = 'Recurring Prepaid';  
        database.insert(orderline);
        
        counter=0;
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c subs:subRecs){
            subs.Zuora__CustomerAccount__c = billAcc.Id;
            subs.Zuora__Zuora_Id__c = 'zID001';   
            subs.Subscription_Type__c = 'Delivery';
            subs.Order_Line_Item_Number__c = orderline.Id;
            subs.Billing_Type__c = 'Recurring Prepaid';
            subs.Main_Package__c = pack.Id;
            subs.Zuora__SubscriptionStartDate__c = date.today();
            subs.Term_Length1__c = '3.3';
            subs.Zuora__TermSettingType__c = 'Termed'; 
            subs.Qty1__c = '3';
            if(counter==1){
                subs.Billing_Type__c = 'Full Prepaid';  
                subs.Main_Package__c = pack2.Id;
            }
            counter++;
        }
        database.insert(subRecs);
        
        Zuora__Subscription__c subRecsQ = [SELECT Number_of_Copies__c, Zuora__Zuora_Id__c, Zuora__SubscriptionStartDate__c, Billing_Type__c FROM Zuora__Subscription__c WHERE Id=:subRecs[1].Id];
        system.assertNotEquals(subRecsQ.Zuora__Zuora_Id__c, null);
        system.assertNotEquals(subRecsQ.Zuora__SubscriptionStartDate__c, null);
        system.assertEquals(subRecsQ.Number_of_Copies__c, 3);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp:spc){
            sp.Zuora__Subscription__c = subRecs[0].Id;
            sp.Zuora__UOM__c = 'Credit';
            sp.Zuora__Type__c = 'Usage';
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        mapSub.put(subRecs[0].Zuora__Zuora_Id__c, subRecs[0].Zuora__SubscriptionStartDate__c+65);
        //end test data
    
        test.startTest();
            usageCreationForStopSubscription  ucss = new usageCreationForStopSubscription();
            ucss.createUsage(mapSub);
        test.stopTest();
    }
    
    static testMethod void testusageCreationForStopSubscription2(){
        Map<String, Date> mapSub = new Map<String, Date>();
        Integer counter;
        
        //start custom settings
        List<Other__c> other = new List<Other__c>{new Other__c(Name = 'DTL', Value__c = '23:59'),
            new Other__c(Name = 'Order_Type Renewa',Value__c = 'Renewal')};
        database.insert(other);
        //end custom settings
        
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Package__c pack2 = new Package__c();
        pack2.Effective_End_Date__c = date.today()+3;
        pack2.Effective_Start_Date__c = date.today();
        pack2.Package_Code__c = 'code123';
        database.insert(pack2);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Newspaper';
        database.insert(zProduct);
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.2';
        database.insert(sub);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = sub.Id;
        database.insert(order);
        
        Zuora__Subscription__c subQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Id=:sub.Id];
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = subQ.Zuora__SubscriptionEndDate__c.addDays(1);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Main_Package_Billing_Type__c = 'Recurring Prepaid';  
        database.insert(orderline);
        
        counter=0;
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c subs:subRecs){
            subs.Zuora__CustomerAccount__c = billAcc.Id;
            subs.Zuora__Zuora_Id__c = 'zID001';   
            subs.Subscription_Type__c = 'Delivery';
            subs.Order_Line_Item_Number__c = orderline.Id;
            subs.Billing_Type__c = 'Recurring Prepaid';
            subs.Main_Package__c = pack.Id;
            subs.Zuora__SubscriptionStartDate__c = date.today();
            subs.Term_Length1__c = '3.3';
            subs.Zuora__TermSettingType__c = 'Termed'; 
            subs.Qty1__c = '3';
            if(counter==1){
                subs.Billing_Type__c = 'Full Prepaid';  
                subs.Main_Package__c = pack2.Id;
            }
            counter++;
        }
        database.insert(subRecs);
        
        Zuora__Subscription__c subRecsQ = [SELECT Number_of_Copies__c, Zuora__Zuora_Id__c, Zuora__SubscriptionStartDate__c, Billing_Type__c FROM Zuora__Subscription__c WHERE Id=:subRecs[1].Id];
        system.assertNotEquals(subRecsQ.Zuora__Zuora_Id__c, null);
        system.assertNotEquals(subRecsQ.Zuora__SubscriptionStartDate__c, null);
        system.assertEquals(subRecsQ.Number_of_Copies__c, 3);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp:spc){
            sp.Zuora__Subscription__c = subRecs[0].Id;
            sp.Zuora__UOM__c = 'Credit';
            sp.Zuora__Type__c = 'Usage';
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        mapSub.put(subRecs[0].Zuora__Zuora_Id__c, (subRecs[0].Zuora__SubscriptionStartDate__c+65).toStartOfMonth());
        //end test data
    
        test.startTest();
            usageCreationForStopSubscription  ucss = new usageCreationForStopSubscription();
            ucss.createUsage(mapSub);
        test.stopTest();
    }
    
    static testMethod void testusageCreationForStopSubscription3(){
        Map<String, Date> mapSub = new Map<String, Date>();
        Integer counter;
        
        //start custom settings
        List<Other__c> other = new List<Other__c>{new Other__c(Name = 'DTL', Value__c = '23:59'),
            new Other__c(Name = 'Order_Type Renewa',Value__c = 'Renewal')};
        database.insert(other);
        //end custom settings
        
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Package__c pack2 = new Package__c();
        pack2.Effective_End_Date__c = date.today()+3;
        pack2.Effective_Start_Date__c = date.today();
        pack2.Package_Code__c = 'code123';
        database.insert(pack2);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Newspaper';
        database.insert(zProduct);
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        database.insert(pItem);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.2';
        database.insert(sub);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = sub.Id;
        database.insert(order);
        
        Zuora__Subscription__c subQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Id=:sub.Id];
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = subQ.Zuora__SubscriptionEndDate__c.addDays(1);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Main_Package_Billing_Type__c = 'Recurring Prepaid';  
        database.insert(orderline);
        
        counter=0;
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c subs:subRecs){
            subs.Zuora__CustomerAccount__c = billAcc.Id;
            subs.Zuora__Zuora_Id__c = 'zID001';   
            subs.Subscription_Type__c = 'Delivery';
            subs.Order_Line_Item_Number__c = orderline.Id;
            subs.Billing_Type__c = 'Recurring Prepaid';
            subs.Main_Package__c = pack.Id;
            subs.Zuora__SubscriptionStartDate__c = usageCreationForStopSubscription.getLastDayOfTheMonth(date.today());
            subs.Term_Length1__c = '3.3';
            subs.Zuora__TermSettingType__c = 'Termed'; 
            subs.Qty1__c = '3';
            if(counter==1){
                subs.Billing_Type__c = 'Full Prepaid';  
                subs.Main_Package__c = pack2.Id;
            }
            counter++;
        }
        database.insert(subRecs);
        
        Zuora__Subscription__c subRecsQ = [SELECT Number_of_Copies__c, Zuora__Zuora_Id__c, Zuora__SubscriptionStartDate__c, Billing_Type__c FROM Zuora__Subscription__c WHERE Id=:subRecs[1].Id];
        system.assertNotEquals(subRecsQ.Zuora__Zuora_Id__c, null);
        system.assertNotEquals(subRecsQ.Zuora__SubscriptionStartDate__c, null);
        system.assertEquals(subRecsQ.Number_of_Copies__c, 3);
        
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c sp:spc){
            sp.Zuora__Subscription__c = subRecs[0].Id;
            sp.Zuora__UOM__c = 'Credit';
            sp.Zuora__Type__c = 'Usage';
            sp.PublicationCode__c = '01';
        }
        database.insert(spc);
        
        mapSub.put(subRecs[0].Zuora__Zuora_Id__c, usageCreationForStopSubscription.getLastDayOfTheMonth(subRecs[0].Zuora__SubscriptionStartDate__c+31));
        //end test data
    
        test.startTest();
            usageCreationForStopSubscription  ucss = new usageCreationForStopSubscription();
            ucss.createUsage(mapSub);
        test.stopTest();
    } 
    
}