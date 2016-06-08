@isTest (seeAllData= false)
private class SendQuotesToZuoraBatchTest{
    static testMethod void SendQuotesToZuoraBatch() {
    
  
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
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
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today().addDays(1);
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
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Start_Date__c = Date.Today().addDays(2);          
        }
        database.insert(olis);
         
        List<zqu__Quote__c> quoteList = TestDataFactory.createQuote(1);
        for(zqu__Quote__c zq: quoteList ){
        zq.zqu__Account__c = acc.id;
        zq.Order_Line_Item_Number_1__c = olis[0].id;
        zq.Order_Line_Item_Number__c = olis[0].id;
        }
        
        Database.insert(quoteList);
        
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

             
            SendQuotesToZuoraBatch batch = new SendQuotesToZuoraBatch(QuoteIds, PaymentMode1, PaymentModeOther1, sDeliveryChargeType1,bCreateNewBillingAccount1, bCreateDeliverySubscription1, bPayDeliveryChargeNow1,
                                         ExistingDeliverySubscriptionId1, SFBillingAccount1, zBillingAccount1, SubscriberCharge1,
                                        AccountId1, OrderId1, DeliveryFPSubscriptionUsage1, CCPaymentMethodID1);
            database.executeBatch(batch, 200);
               
            Database.BatchableContext BC;
            batch.execute(BC, orderLineItemList);
        test.stopTest();    
        }
        
}