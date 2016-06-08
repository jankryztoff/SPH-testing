@IsTest 
private class MigrationSubscriptionTriggerHandlerTest2{
    static testMethod void testMigrationSubscriptionTriggerHandler(){
        Integer counter;
    
        //custom settings for DTL
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        //create account data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        database.insert(con);
    
        //create billing account data
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.RatePlanType__c = 'Bill Plan';
        prp.zqu__ZProduct__c = zProduct.Id;
        database.insert(prp);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Product_Rate_Plan__c = prp.Id;
        pItem.Package__c = pack.Id;
        database.insert(pItem);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.ID;
        order.Total_Full_Prepaid__c = 100;
        database.insert(order);
        
        Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
        ordLine.Order__c = order.Id;
        ordLine.Main_Package_ID__c = pack.ID;
        database.insert(ordLine);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '30';
        database.insert(prom);
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        database.insert(subven);
        
        counter=0;
        //create list of subscription data
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Legacy_Subscription_ID__c = '123';
            sub.Main_Package__c = pack.Id;
            sub.Addon_Package_1__c = pack.Id;
            sub.Delivered_By_1__c = 'Vendor';
            sub.Order_Line_Item_Number_1__c = ordLine.Id;
            //sub.Order_Number__c = order.Id;
            sub.Order_Number_1__c = order.Id;
            sub.Promotion_1__c = prom.Id;
            sub.Number_of_Copies1__c = '3';
            sub.Recipient_Contact__c = con.Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscriber_Contact__c = con.Id;
            sub.Vendor_1__c = acc.Id;
            sub.Vendor_Subscription_To_Convert_1__c = subVen.Id;
            sub.Subscription_Type__c = 'Delivery';
            sub.Billing_Type__c = 'Full Prepaid';
            sub.Main_Package_1__c = pack.Id;
            //sub.Delivery_Charge__c = 100;
            if(counter==1){
                sub.Zuora__Status__c = 'Cancelled';
                sub.Zuora__SubscriptionEndDate__c = date.today()-1;
                sub.Zuora__SubscriptionStartDate__c = date.today().addMonths(-2).addDays(1);
                sub.Term_Length1__c = '2';
                sub.Delivery_Charge__c = 100;
            }    
            else if(counter==2){
                sub.Recipient_Contact__c = null;
                sub.Delivery_Charge__c = 100;
            }
            else if(counter==3){
                sub.Billing_Type__c = null;
                sub.Main_Package_1__c = null;
            }
            counter++;
        }
        database.insert(subs);
        
        Map<Id, Zuora__Subscription__c> mapNewSubscriptions = new Map<Id, Zuora__Subscription__c>();
        
        for(Zuora__Subscription__c sub: subs){
            mapNewSubscriptions.put(sub.Id, sub);
        }
        
        List<Zuora__Subscription__c> subQ = [SELECT Main_Package_1__c FROM Zuora__Subscription__c WHERE Id IN : mapNewSubscriptions.keySet()];
        for(Zuora__Subscription__c sub: subQ){
            system.assertNotEquals(sub.Main_Package_1__c, null);
        }
        
        test.startTest();
            MigrationSubscriptionTriggerHandler handler = new MigrationSubscriptionTriggerHandler();
            handler.doBeforeInsert(subs);
            handler.doBeforeUpdate(subs, mapNewSubscriptions, subs, mapNewSubscriptions);
            handler.doAfterUpdate(subs, mapNewSubscriptions, subs, mapNewSubscriptions);
        test.stopTest();
    }
    
    static testMethod void testMigrationSubscriptionTriggerHandler2(){
        Integer counter;
    
        //custom settings for DTL
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
    
        //create account data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        database.insert(con);
    
        //create billing account data
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.RatePlanType__c = 'Bill Plan';
        prp.zqu__ZProduct__c = zProduct.Id;
        database.insert(prp);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Product_Rate_Plan__c = prp.Id;
        pItem.Package__c = pack.Id;
        database.insert(pItem);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.ID;
        order.Total_Full_Prepaid__c = 100;
        database.insert(order);
        
        Order__c order2 = TestDataFactory.createOrder(1)[0];
        order2.Account__c = acc.ID;
        order2.Total_Full_Prepaid__c = 100;
        database.insert(order2);
        
        Order_Line_Item__c ordLine = TestDataFactory.createOrderLineItem(1)[0];
        ordLine.Order__c = order.Id;
        ordLine.Main_Package_ID__c = pack.ID;
        database.insert(ordLine);
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Contract_Period__c = '30';
        database.insert(prom);
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        database.insert(subven);
        
        counter=0;
        //create list of subscription data
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(5);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Legacy_Subscription_ID__c = '123';
            sub.Main_Package__c = pack.Id;
            sub.Addon_Package_1__c = pack.Id;
            sub.Delivered_By_1__c = 'Vendor';
            sub.Order_Line_Item_Number_1__c = ordLine.Id;
            //sub.Order_Number__c = order.Id;
            sub.Order_Number_1__c = order.Id;
            sub.Promotion_1__c = prom.Id;
            sub.Number_of_Copies1__c = '3';
            sub.Recipient_Contact__c = con.Id;
            sub.Zuora__Account__c = acc.Id;
            sub.Subscriber_Contact__c = con.Id;
            sub.Vendor_1__c = acc.Id;
            sub.Vendor_Subscription_To_Convert_1__c = subVen.Id;
            sub.Subscription_Type__c = 'Delivery';
            sub.Billing_Type__c = 'Recurring Prepaid';
            sub.Main_Package_1__c = pack.Id;
            sub.Delivery_Charge__c = null;
            if(counter==1){
                sub.Order_Number_1__c = order2.Id;
                sub.Subscription_Type__c = 'Publication';
                sub.Billing_Type__c = 'Full Prepaid';
                sub.Subscription_Charge__c = 100;
            }    
           /* else if(counter==2){
                sub.Recipient_Contact__c = null;
                sub.Delivery_Charge__c = 100;
            }
            else if(counter==3){
                sub.Billing_Type__c = null;
                sub.Main_Package_1__c = null;
            }*/
            counter++;
        }
        database.insert(subs);
        
        Map<Id, Zuora__Subscription__c> mapNewSubscriptions = new Map<Id, Zuora__Subscription__c>();
        
        for(Zuora__Subscription__c sub: subs){
            mapNewSubscriptions.put(sub.Id, sub);
        }
        
        List<Zuora__Subscription__c> subQ = [SELECT Main_Package_1__c FROM Zuora__Subscription__c WHERE Id IN : mapNewSubscriptions.keySet()];
        for(Zuora__Subscription__c sub: subQ){
            system.assertNotEquals(sub.Main_Package_1__c, null);
        }
        
        test.startTest();
            MigrationSubscriptionTriggerHandler handler = new MigrationSubscriptionTriggerHandler();
            handler.doBeforeInsert(subs);
            handler.doBeforeUpdate(subs, mapNewSubscriptions, subs, mapNewSubscriptions);
            handler.doAfterUpdate(subs, mapNewSubscriptions, subs, mapNewSubscriptions);
        test.stopTest();
    }
}