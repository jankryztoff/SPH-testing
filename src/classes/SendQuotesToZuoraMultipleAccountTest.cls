/*
 * Class Name: SendQuotesToZuoraMultipleAccountTest
 * @author: JMGonzales 
 * Date: 4/10/16
 * Project/Requirement: SPH Integration
 * @description
 */ 
 
 @isTest (seeAllData= true)
private class SendQuotesToZuoraMultipleAccountTest{
    static testMethod void SendQuotesToZuoraMultipleAccountTest() {
    
        map<id, map<string, string>> orderId_creditCard = new map<id, map<string, string>>();
        map<string, string> orderIdCreditCard = new map<string, string>();
        set<id> orderIdSet = new set<id>(); 
        set<id> urgentOrderIdSet = new set<id>();
        set<String> quoteNameSet = new set<String>();
        Map<Id, Set<Id>> orderIdToQuoteIdSetMap = new Map<Id, Set<Id>>();
        /*
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        */

        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        Database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        con.Address__c = address.Id;
        database.insert(con); 
            
        Order__c ord1 = TestDataFactory.createOrder(1)[0];
        ord1.Account__c = acc.id;
        Database.insert(ord1);

        Order__c ord3 = TestDataFactory.createOrder(1)[0];
        ord3.Account__c = acc.id;
        Database.insert(ord3);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Zuora_Id__c = '12345';
        billAcc.Zuora__External_Id__c = '12345';
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today().addDays(1);
        sub.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        sub.Zuora__Zuora_Id__c = '12345';
        sub.Zuora__External_Id__c = '12345';
        sub.Payment_Mode_1__c = 'Credit Card';
        sub.Acquisition_Type_1__c = 'ROAD SHOW';
        sub.Billing_Type__c = 'Full Prepaid';
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub.id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        List<Order__c> orders2 = TestDataFactory.createOrder(1);
        for(Order__c ord2 : orders2){
        ord2.Account__c = acc.id;
        ord2.Order_Type__c = 'Renewal'; 
        ord2.Base_Subscription__c = sub.id;
        ord2.Billing_Contact__c = con.id;
        ord2.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders2);
        orderIdToQuoteIdSetMap.put(orders[0].Id,new Set<Id>{orders[0].Id});
        
        orderIdSet.add(orders[0].Id);
        urgentOrderIdSet.add(orders2[0].Id);
        orderIdCreditCard.put(''+orders[0],''+orders2[0]);
        orderId_creditCard.put(orders[0].Id, orderIdCreditCard);
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
            oli.Order__c = orders[0].id; 
            oli.Main_Package_ID__c = pack.id; 
            oli.Subscription__c = sub.id;  
            oli.Start_Date__c = Date.Today().addDays(32);          
        }

        database.insert(olis);
        
        system.debug('sub end date ' + orders[0].Base_Subscription__c);
        system.debug('oli start date ' + olis[0].Order__r.Base_Subscription__c);
        system.debug('order id ' + orders[0].id);
        system.debug('oli id ' + olis[0].id);
        system.debug('oli order ' + olis[0].Order__c);
        
         
        List<zqu__Quote__c> quoteList = TestDataFactory.createQuote(1);
        for(zqu__Quote__c zq: quoteList ){
        zq.zqu__Account__c = acc.id;
        zq.Order_Line_Item_Number_1__c = olis[0].id;
        zq.Order_Line_Item_Number__c = olis[0].id;
        zq.Order_Number__c = orders[0].Id;
        orderIdToQuoteIdSetMap.put(zq.Order_Number__c, new Set<Id>{zq.Id});
        }
        
        Database.insert(quoteList);
        quoteNameSet.add(quoteList[0].Name);    
        
        List<zqu__QuoteCharge__c> zqCharge = TestDataFactory.createQuoteCharge(1);
        for(zqu__QuoteCharge__c zqc: zqCharge){
        zqc.zqu__Quote__c = quoteList[0].Id;
        }
        Database.insert(zqCharge);
        
        Set<Id> olitemsId = new Set<Id>();
        for(Order_Line_Item__c oli : olis ){
        olitemsId.add(oli.Id);
        }
        
        List<Order_Line_Item__c> orderLineItemList = [SELECT Id, Order__r.Billing_Account_Creation_Mode__c FROM Order_Line_Item__c WHERE id IN: olitemsId];
       
        List<Id> QuoteIds = new List<Id>();
        QuoteIds.add(quoteList[0].id); 
        string PaymentMode1 = 'Credit Card'; 
        string PaymentModeOther1 = ''; 
        string sDeliveryChargeType1 = ''; 
        boolean bCreateNewBillingAccount1 = true; 
        boolean bCreateDeliverySubscription1 = true; 
        boolean bPayDeliveryChargeNow1 = true; 
        ID ExistingDeliverySubscriptionId1 = sub.id; 
        ID SFBillingAccount1 = billAcc.Id; 
        string zBillingAccount1 = ''; 
        decimal SubscriberCharge1 = 1.0; 
        ID AccountId1 = acc.id; 
        ID OrderId1 = orders[0].id; 
        decimal DeliveryFPSubscriptionUsage1 = 1.0; 
        string CCPaymentMethodID1 = '';
       
         test.startTest();
            SendQuotesToZuoraMultipleAccount batch = new SendQuotesToZuoraMultipleAccount(orderIdSet,quoteNameSet,'csvupload',orderId_creditCard);
            database.executeBatch(batch, 200);
               
            Database.BatchableContext BC;
            batch.execute(BC, orders);
        test.stopTest();    
        }
        
        static testMethod void SendQuotesToZuoraMultipleAccountTest2() {
    
        map<id, map<string, string>> orderId_creditCard = new map<id, map<string, string>>();
        map<string, string> orderIdCreditCard = new map<string, string>();
        set<id> orderIdSet = new set<id>(); 
        set<id> urgentOrderIdSet = new set<id>();
        set<String> quoteNameSet = new set<String>();
        Map<Id, Set<Id>> orderIdToQuoteIdSetMap = new Map<Id, Set<Id>>();
        /*
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        */

        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        Database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        con.Address__c = address.Id;
        database.insert(con); 
            
        Order__c ord1 = TestDataFactory.createOrder(1)[0];
        ord1.Account__c = acc.id;
        Database.insert(ord1);

        Order__c ord3 = TestDataFactory.createOrder(1)[0];
        ord3.Account__c = acc.id;
        Database.insert(ord3);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Zuora_Id__c = '12345';
        billAcc.Zuora__External_Id__c = '12345';
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today().addDays(1);
        sub.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        sub.Zuora__Zuora_Id__c = '12345';
        sub.Zuora__External_Id__c = '12345';
        sub.Payment_Mode_1__c = 'Credit Card';
        sub.Acquisition_Type_1__c = 'ROAD SHOW';
        sub.Billing_Type__c = 'Full Prepaid';
        database.insert(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub.id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        List<Order__c> orders2 = TestDataFactory.createOrder(1);
        for(Order__c ord2 : orders2){
        ord2.Account__c = acc.id;
        ord2.Order_Type__c = 'Renewal'; 
        ord2.Base_Subscription__c = sub.id;
        ord2.Billing_Contact__c = con.id;
        ord2.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders2);
        orderIdToQuoteIdSetMap.put(orders[0].Id,new Set<Id>{orders[0].Id});
        
        orderIdSet.add(orders[0].Id);
        urgentOrderIdSet.add(orders2[0].Id);
        orderIdCreditCard.put(''+orders[0],''+orders2[0]);
        orderId_creditCard.put(orders[0].Id, orderIdCreditCard);
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
            oli.Order__c = orders[0].id; 
            oli.Main_Package_ID__c = pack.id; 
            oli.Subscription__c = sub.id;  
            oli.Start_Date__c = Date.Today().addDays(32);          
        }

        database.insert(olis);
        
        system.debug('sub end date ' + orders[0].Base_Subscription__c);
        system.debug('oli start date ' + olis[0].Order__r.Base_Subscription__c);
        system.debug('order id ' + orders[0].id);
        system.debug('oli id ' + olis[0].id);
        system.debug('oli order ' + olis[0].Order__c);
        
         
        List<zqu__Quote__c> quoteList = TestDataFactory.createQuote(1);
        for(zqu__Quote__c zq: quoteList ){
        zq.zqu__Account__c = acc.id;
        zq.Order_Line_Item_Number_1__c = olis[0].id;
        zq.Order_Line_Item_Number__c = olis[0].id;
        zq.Order_Number__c = orders[0].Id;
        orderIdToQuoteIdSetMap.put(zq.Order_Number__c, new Set<Id>{zq.Id});
        }
        
        Database.insert(quoteList);
        quoteNameSet.add(quoteList[0].Name);    
        
        List<zqu__QuoteCharge__c> zqCharge = TestDataFactory.createQuoteCharge(1);
        for(zqu__QuoteCharge__c zqc: zqCharge){
        zqc.zqu__Quote__c = quoteList[0].Id;
        }
        Database.insert(zqCharge);
        
        Set<Id> olitemsId = new Set<Id>();
        for(Order_Line_Item__c oli : olis ){
        olitemsId.add(oli.Id);
        }
        
        List<Order_Line_Item__c> orderLineItemList = [SELECT Id, Order__r.Billing_Account_Creation_Mode__c FROM Order_Line_Item__c WHERE id IN: olitemsId];
       
        List<Id> QuoteIds = new List<Id>();
        QuoteIds.add(quoteList[0].id); 
        string PaymentMode1 = 'Credit Card'; 
        string PaymentModeOther1 = ''; 
        string sDeliveryChargeType1 = ''; 
        boolean bCreateNewBillingAccount1 = true; 
        boolean bCreateDeliverySubscription1 = true; 
        boolean bPayDeliveryChargeNow1 = true; 
        ID ExistingDeliverySubscriptionId1 = sub.id; 
        ID SFBillingAccount1 = billAcc.Id; 
        string zBillingAccount1 = ''; 
        decimal SubscriberCharge1 = 1.0; 
        ID AccountId1 = acc.id; 
        ID OrderId1 = orders[0].id; 
        decimal DeliveryFPSubscriptionUsage1 = 1.0; 
        string CCPaymentMethodID1 = '';
       
         test.startTest();
            SendQuotesToZuoraMultipleAccount batch = new SendQuotesToZuoraMultipleAccount(orderIdSet,quoteNameSet,'csvupload');
            database.executeBatch(batch, 200);
               
            Database.BatchableContext BC;
            batch.execute(BC, orders);
        test.stopTest();    
        }
        
}