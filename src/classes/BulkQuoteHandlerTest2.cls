@isTest(SeeAllData=true)
private class BulkQuoteHandlerTest2{
    
  /*  static testMethod void testBulkQuoteHandler(){
        //start test data
        //List<zqu__Quote__c> quote = TestDataFactory.createQuote(1);
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Address_Type__c = 'A';
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = 'POSCHG';
        database.insert(zp);
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.RatePlanCode__c = 'CHGPOS';
        prp.zqu__Deleted__c = false;
        prp.zqu__ZProduct__c = zp.Id;
        prp.RatePlanType__c= 'Bill Plan';
        //prp.RatePlanType__c= 'Proration';
        database.insert(prp);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '0.0';
        database.insert(subRecs);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = subRecs.Id;
        order.Recipient_Contact__c = con.Id;
        database.insert(order);
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = billAcc.Id;
        subs.Zuora__SubscriptionStartDate__c = date.today();
        subs.Term_Length1__c = '0.0';
        subs.Order_Number_1__c = order.Id;
        database.insert(subs);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Add On';
        pack.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        pack.Billing_Type__c = 'Full Prepaid';
        database.insert(pack);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Product_Rate_Plan__c = prp.Id;
        pItem.Package__c = pack.Id;
        database.insert(pItem);
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli:orderline){
            oli.order__c = order.ID;
            oli.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+1;
            oli.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+2;
            oli.Main_Package_ID__c = pack.Id;
            oli.Addon_Package__c = pack.Id;
            oli.Main_Package_Product_Family__c = 'Default';
            oli.Main_Package_Billing_Type__c = 'Full Prepaid';
            //START UD-3660 AddedBy FrancisBenzon 18Mar16  
            oli.Delivered_By__c = 'Mailing Agent';
            oli.Main_Package_Product_Platform__c = 'Print';
           //END UD-3660 AddedBy FrancisBenzon 18Mar16  
        }
        database.insert(orderline);
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Premium';
        gift.One_Time_Charge__c = 100;
        database.insert(gift);
        
        Promotion_Gift__c promGift = TestDataFactory.createPromotionGift(1)[0];
        promGift.Gift__c = gift.Id;
        database.insert(promGift);
        
        List<Order_Line_Item_Gift__c> olif = TestDataFactory.createItemGift(2);
        for(Order_Line_Item_Gift__c oli:olif){
            oli.Order_Line_Item__c = orderline[0].Id;
            oli.Promotion_Gift__c = promGift.Id;
        }
        database.insert(olif);
        
        List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
        for(zqu__ProductRatePlanCharge__c pr: prpc){
            pr.zqu__ProductRatePlan__c = prp.Id;
            pr.zqu__Deleted__c = false;
        }
        database.insert(prpc);
        
        Integer counter=0;
        List<zqu__ProductRatePlanChargeTier__c> prpct = TestDataFactory.createProductRatePlanChargeTier(2);
        for(zqu__ProductRatePlanChargeTier__c pr:prpct){
            pr.zqu__ProductRatePlanCharge__c = prpc[counter].Id;
            pr.zqu__PriceFormat__c = 'Per Unit';
            pr.zqu__Currency__c = 'SGD';
            counter++;
        }
        database.insert(prpct);
        
        set<id> orderIdSet = new set<id>();
        orderIdSet.add(order.Id);
        //end test data
    
        test.startTest();
        try{
            BulkQuoteHandler handler = new BulkQuoteHandler();
            handler.bulkQuoteCreation(orderIdSet, '');
            }
            catch(zqu.ZQException e){}
        test.stopTest();
    }
    */
    
    static testMethod void testBulkQuoteHandler2(){
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        //Address__c add = TestDataFactory.createAddress(1)[0];
        //add.Address_Type__c = 'P';
        //database.insert(add);
        Address__c address = [select Id, Country__r.Zone__c from Address__c where RecordType.DeveloperName = 'Local' and Country__r.Name = 'SG' limit 1];
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = address.Id;
        con.AccountId = acc.Id;
        con.Billing_Indicator__c = true;
        con.Recipient_Indicator__c = true;
        database.insert(con);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = 'POSCHG';
        database.insert(zp);
        
        Zone_Product__c zoneProduct = new Zone_Product__c();
        zoneProduct.Effective_Start_Date__c = date.today();
        zoneProduct.Zone__c = address.Country__r.Zone__c;
        zoneProduct.Product__c = zp.Id;
        zoneProduct.Postage_Charge__c = 0.0;
        database.insert(zoneProduct);
        
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c p:prp){
            p.RatePlanCode__c = 'CHGPOS';
            p.zqu__Deleted__c = false;
            p.zqu__ZProduct__c = zp.Id;
            p.RatePlanType__c= 'Proration';
            p.RatePlanSubType__c = 'Standard';
            p.SubscriptionFrequency__c = '1';
        }
        database.insert(prp);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '0.0';
        database.insert(subRecs);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Base_Subscription__c = subRecs.Id;
        order.Recipient_Contact__c = con.Id;
        database.insert(order);
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = billAcc.Id;
        subs.Zuora__SubscriptionStartDate__c = date.today();
        subs.Term_Length1__c = '0.0';
        subs.Order_Number_1__c = order.Id;
        subs.Zuora__Zuora_Id__c = 'id1234';
        database.insert(subs);
                                
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Grace Period';
        pack.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        /*Package__c pack2 = TestDataFactory.createPackage(1)[0];
        pack2.Package_Type__c = 'Grace Period';
        pack2.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
        pack2.Billing_Type__c = 'Full Prepaid';
        pack2.Subscription_Period__c = '1';
        database.insert(pack2);*/
        
        Product_Family__c pf = TestDataFactory.createProductFamily(1)[0];
        database.insert(pf);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Product_Rate_Plan__c = prp[0].Id;
        pItem.Package__c = pack.Id;
        pItem.Product_Family__c = pf.Id;
        database.insert(pItem);
     
                   
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(2);
        for(Order_Line_Item__c oli:orderline){
            oli.order__c = order.ID;
            oli.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+1;
            oli.End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+2;
            oli.Main_Package_ID__c = pack.Id;
            oli.Main_Package_Product_Family__c = 'Default';
            oli.Main_Package_Billing_Type__c = 'Full Prepaid';
           // oli.Addon_Package__c = pack.id;
            //START UD-3660 AddedBy FrancisBenzon 18Mar16  
            oli.Contract_End_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+10;
            //END UD-3660 AddedBy FrancisBenzon 18Mar16  
        }
        //START UD-3660 AddedBy FrancisBenzon 18Mar16  
        orderline[1].Delivered_By__c = 'Mailing Agent';
        orderline[1].Main_Package_Product_Platform__c = 'Print';        
        //END UD-3660 AddedBy FrancisBenzon 18Mar16  
        database.insert(orderline);
        
        Gift__c gift = TestDataFactory.createGift(1)[0];
        gift.Gift_Type__c = 'Premium';
        gift.One_Time_Charge__c = 100;
        database.insert(gift);
        
        Promotion_Gift__c promGift = TestDataFactory.createPromotionGift(1)[0];
        promGift.Gift__c = gift.Id;
        database.insert(promGift);
        
        List<Order_Line_Item_Gift__c> olif = TestDataFactory.createItemGift(2);
        for(Order_Line_Item_Gift__c oli:olif){
            oli.Order_Line_Item__c = orderline[0].Id;
            oli.Promotion_Gift__c = promGift.Id;
        }
        database.insert(olif);
        
        List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(2);
        for(zqu__ProductRatePlanCharge__c pr: prpc){
            pr.zqu__ProductRatePlan__c = prp[0].Id;
            pr.zqu__Deleted__c = false;
        }
        database.insert(prpc);
        
        Integer counter=0;
        List<zqu__ProductRatePlanChargeTier__c> prpct = TestDataFactory.createProductRatePlanChargeTier(2);
        for(zqu__ProductRatePlanChargeTier__c pr:prpct){
            pr.zqu__ProductRatePlanCharge__c = prpc[counter].Id;
            pr.zqu__PriceFormat__c = 'Per Unit';
            pr.zqu__Currency__c = 'SGD';
            counter++;
        }
        database.insert(prpct);
        
        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Frequency__c = 'Default';
        quote.Subscription_Type__c  = 'Postage';
        quote.Order_Line_Item_Number__c = orderline[0].Id; 
        database.insert(quote);
        
        zqu__QuoteCharge__c qc = TestDataFactory.createQuoteCharge(1)[0];
        qc.zqu__Quote__c = quote.Id;
        qc.zqu__ProductRatePlanCharge__c = prpc[0].Id;
        database.insert(qc);
        
        set<id> orderIdSet = new set<id>();
        orderIdSet.add(order.Id);
        //end test data
        
        
         
        test.startTest();
            try{
            BulkQuoteHandler handler = new BulkQuoteHandler();
            handler.bulkQuoteCreation(orderIdSet, '');
            }
            catch(zqu.ZQException e){}
        test.stopTest();
    }
}