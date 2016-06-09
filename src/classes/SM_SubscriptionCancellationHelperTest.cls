/**
 * Class Name: SM_SubscriptionCancellationHelperTest 
 * @author: George Santos
 * Date: 2/11/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description: Test Class for SM_SubscriptionCancellationHelper
 */
 
 @isTest(seeAllData = true)
public with sharing class SM_SubscriptionCancellationHelperTest {
  
  static Order__c order = null;
/*  static Map<id, date> createTestMapDatas(){
    User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(u){
        
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert acc;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';  
            billAcc.Zuora__DefaultPaymentMethod__c = 'Others';  
            database.insert(billAcc);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            insert zProd;
            
            zqu__ProductRatePlan__c zProdRate = TestDataFactory.createProductRatePlan(1)[0];
            zProdRate.zqu__ZProduct__c = zProd.id;
            insert zProdRate;
            
            Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
            prodPub.ZProduct__c = zProd.id;
            insert prodPub;
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.id;
            packItem.Product_Rate_Plan__c = zProdRate.id;
            insert packItem;
            
            order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Billing_Account__c = billAcc.id;
            order.Billing_Type__c = 'Full Prepaid';  
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 1.00;
            insert order;
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            insert orderLineItem;
            
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Line_Item_Number__c = orderLineItem.id;
            zSub.Recipient_Contact__c = con.id;
            zSub.Name = 'S0000000';
            zSub.Order_Number__c = order.id;
            zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
            zSub.Zuora__AutoRenew__c = False;
            zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
            zSub.Zuora__CustomerAccount__c = billAcc.Id; 
            insert zSub;   
            
            Map<id, date> retMap = new Map<id, date>();
          retMap.put(zSub.id, System.Today());
          return retMap;       
        }
        return null;  
  }
  
  
  static testmethod void test01_cancellSubscription(){
    
    try{
        Map<Id, Date> subMap = new Map<Id, Date>();
        subMap = createTestMapDatas();
    
        test.setMock(WebServiceMock.class, new zApiTest());
        test.startTest();
            SM_SubscriptionCancellationHelper.cancel(subMap, 'Stop Subscription');
        test.stopTest();
     }
     catch(Exception e){
     }
  } 
  
  static testmethod void test02_cosCancellSubscription(){
      try{
          Map<Id, Date> subMap = new Map<Id, Date>();
          subMap = createTestMapDatas();
          
        test.setMock(WebServiceMock.class, new zApiTest());
        test.startTest();
            SM_SubscriptionCancellationHelper.cosCancel(subMap, 'Stop Subscription',order.Id);
        test.stopTest();
      }
      catch(Exception e){
      }
  }*/
  
  //static testmethod void test03_cosCancellSubscription(){
  //    //start test data
  //    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
  //    insert acc;
      
  //    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
  //    billAcc.Zuora__Account__c = acc.Id;
  //    insert billAcc;
      
  //    Package__c pack = TestDataFactory.createPackage(1)[0];
  //    insert pack;
      
  //    order = TestDataFactory.createOrder(1)[0];
  //    order.Account__c = acc.Id;
  //    insert order;
      
  //    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
  //    orderline.Order__c = order.Id;
  //    orderline.Main_Package_ID__c = pack.Id;
  //    orderline.Admin_Charge__c = 50;
  //    insert orderline;
      
  //    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
  //    promo.Contract_Period__c = '30';
  //    insert promo;
      
  //    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
  //    for(Zuora__Subscription__c sub:subRecs){
  //        sub.Zuora__CustomerAccount__c = billAcc.Id;
  //        sub.Order_Line_Item_Number__c = orderline.Id;
  //        sub.Zuora__Status__c = 'Active';
  //        sub.Billing_Type__c = 'Full Prepaid';
  //        sub.Zuora__SubscriptionStartDate__c = date.today();
  //        sub.Subscription_Type__c = 'Publication';
  //        sub.Zuora__Account__c = acc.Id;
  //        sub.Promotion__c = promo.Id;
  //    }
  //    insert subRecs;
      
  //    orderline.Subscription__c = subRecs[0].Id;
  //    update orderline;
      
  //    order.Subscription__c = subRecs[0].Id;
  //    update order;
      
  //    //Zuora__Subscription__c subQ = [SELECT Order_Line_Item_Number__c, Order_Line_Item_Number_1__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id]
  //    //system.assertEquals(subQ.Order_Line_Item_Number__c, subQ.Order_Line_Item_Number_1__c);
      
  //    map<id, date> subscriptionId_effectiveDate = new map<id, date>();
  //    subscriptionId_effectiveDate.put(subRecs[0].Id, date.today());
  //    //end test data
      
  //    try{
  //        test.setMock(WebServiceMock.class, new zApiTest());
  //        test.startTest();
  //            SM_SubscriptionCancellationHelper.cancel(subscriptionId_effectiveDate, '');
  //        test.stopTest();
  //    }
  //    catch(Exception e){
  //    }
  //}
  
  //static testmethod void test04_cosCancellSubscription(){
  //    //start test data
  //    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
  //    insert acc;
      
  //    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
  //    billAcc.Zuora__Account__c = acc.Id;
  //    insert billAcc;
      
  //    Package__c pack = TestDataFactory.createPackage(1)[0];
  //    insert pack;
      
  //    order = TestDataFactory.createOrder(1)[0];
  //    order.Account__c = acc.Id;
  //    insert order;
      
  //    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
  //    orderline.Order__c = order.Id;
  //    orderline.Main_Package_ID__c = pack.Id;
  //    orderline.Fee_Override__c = true;
  //    orderline.Fee_Override_Amount__c = 50;
  //    insert orderline;
      
  //    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
  //    promo.Contract_Period__c = '30';
  //    insert promo;
      
  //    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
  //    for(Zuora__Subscription__c sub:subRecs){
  //        sub.Zuora__CustomerAccount__c = billAcc.Id;
  //        sub.Order_Line_Item_Number__c = orderline.Id;
  //        sub.Zuora__Status__c = 'Active';
  //        sub.Billing_Type__c = 'Full Prepaid';
  //        sub.Zuora__SubscriptionStartDate__c = date.today();
  //        sub.Subscription_Type__c = 'Publication';
  //        sub.Zuora__Account__c = acc.Id;
  //        sub.Promotion__c = promo.Id;
  //    }
  //    insert subRecs;
      
  //    //orderline.Subscription__c = subRecs[0].Id;
  //    //update orderline;
      
  //    order.Subscription__c = subRecs[0].Id;
  //    update order;
      
  //    //Zuora__Subscription__c subQ = [SELECT Order_Line_Item_Number__c, Order_Line_Item_Number_1__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id]
  //    //system.assertEquals(subQ.Order_Line_Item_Number__c, subQ.Order_Line_Item_Number_1__c);
      
  //    map<id, date> subscriptionId_effectiveDate = new map<id, date>();
  //    subscriptionId_effectiveDate.put(subRecs[0].Id, date.today());
  //    //end test data
      
  //    try{
  //        test.setMock(WebServiceMock.class, new zApiTest());
  //        test.startTest();
  //            SM_SubscriptionCancellationHelper.cosCancel(subscriptionId_effectiveDate, '', order.Id);
  //        test.stopTest();
  //    }
  //    catch(Exception e){
  //    }
  //}
  
  //static testmethod void test05_cosCancellSubscription(){
  //    //start test data
  //    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
  //    insert acc;
      
  //    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
  //    billAcc.Zuora__Account__c = acc.Id;
  //    insert billAcc;
      
  //    Package__c pack = TestDataFactory.createPackage(1)[0];
  //    insert pack;
      
  //    order = TestDataFactory.createOrder(1)[0];
  //    order.Account__c = acc.Id;
  //    insert order;
      
  //    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
  //    orderline.Order__c = order.Id;
  //    orderline.Main_Package_ID__c = pack.Id;
  //    orderline.Fee_Override__c = true;
  //    orderline.Fee_Override_Amount__c = 50;
  //    insert orderline;
      
  //    Promotion__c promo = TestDataFactory.createPromotion(1)[0];
  //    promo.Contract_Period__c = '30';
  //    insert promo;
      
  //    List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
  //    for(Zuora__Subscription__c sub:subRecs){
  //        sub.Zuora__CustomerAccount__c = billAcc.Id;
  //        sub.Order_Line_Item_Number__c = orderline.Id;
  //        sub.Zuora__Status__c = 'Active';
  //        sub.Billing_Type__c = 'Full Prepaid';
  //        sub.Zuora__SubscriptionStartDate__c = date.today();
  //        sub.Subscription_Type__c = 'Publication';
  //        sub.Zuora__Account__c = acc.Id;
  //        sub.Promotion__c = promo.Id;
  //    }
  //    insert subRecs;
      
  //    orderline.Subscription__c = subRecs[0].Id;
  //    update orderline;
      
  //    order.Subscription__c = subRecs[0].Id;
  //    update order;
      
  //    //Zuora__Subscription__c subQ = [SELECT Order_Line_Item_Number__c, Order_Line_Item_Number_1__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id]
  //    //system.assertEquals(subQ.Order_Line_Item_Number__c, subQ.Order_Line_Item_Number_1__c);
      
  //    map<string, date> subscriptionId_effectiveDate = new map<string, date>();
  //    subscriptionId_effectiveDate.put(subRecs[0].Id, date.today());
  //    //end test data
      
  //    try{
  //        test.setMock(WebServiceMock.class, new zApiTest());
  //        test.startTest();
  //            SM_SubscriptionCancellationHelper.processCancellation(subscriptionId_effectiveDate, new map<String, String>());
  //        test.stopTest();
  //    }
  //    catch(Exception e){
  //    }
  //}
  
  static testmethod void test06_cosCancellSubscription(){
      //start test data
      Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
      insert acc;
      
      Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
      billAcc.Zuora__Account__c = acc.Id;
      insert billAcc;
      
      Package__c pack = TestDataFactory.createPackage(1)[0];
      insert pack;
      
      order = TestDataFactory.createOrder(1)[0];
      order.Account__c = acc.Id;
      insert order;
      
      Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
      orderline.Order__c = order.Id;
      orderline.Main_Package_ID__c = pack.Id;
      orderline.Fee_Override__c = true;
      orderline.Fee_Override_Amount__c = 50;
      insert orderline;
      
      Promotion__c promo = TestDataFactory.createPromotion(1)[0];
      promo.Contract_Period__c = '30';
      insert promo;
      
      List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(2);
      for(Zuora__Subscription__c sub:subRecs){
          sub.Zuora__CustomerAccount__c = billAcc.Id;
          sub.Order_Line_Item_Number__c = orderline.Id;
          sub.Zuora__Status__c = 'Active';
          sub.Billing_Type__c = 'Full Prepaid';
          sub.Zuora__SubscriptionStartDate__c = date.today();
          sub.Subscription_Type__c = 'Publication';
          sub.Zuora__Account__c = acc.Id;
          sub.Promotion__c = promo.Id;
      }
      insert subRecs;
      
      //orderline.Subscription__c = subRecs[0].Id;
      //update orderline;
      
      order.Subscription__c = subRecs[0].Id;
      update order;
      
      //Zuora__Subscription__c subQ = [SELECT Order_Line_Item_Number__c, Order_Line_Item_Number_1__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id]
      //system.assertEquals(subQ.Order_Line_Item_Number__c, subQ.Order_Line_Item_Number_1__c);
      
      map<id, date> subscriptionId_effectiveDate = new map<id, date>();
      subscriptionId_effectiveDate.put(subRecs[0].Id, date.today());
      //end test data
      
      try{
          test.setMock(WebServiceMock.class, new zLoginMock());
          test.startTest();
              SM_SubscriptionCancellationHelper.cosCancel(new map<id, date>(), '', order.Id);
          test.stopTest();
      }
      catch(Exception e){
      }
  }

  static testmethod void test01_CancelSubscription(){
      //start test data
      Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
      insert acc;
      
      Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
      billAcc.Zuora__Account__c = acc.Id;
      insert billAcc;
      
      Package__c pack = TestDataFactory.createPackage(1)[0];
      insert pack;
      
      order = TestDataFactory.createOrder(1)[0];
      order.Account__c = acc.Id;
      insert order;

      Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
      orderline.Order__c = order.Id;
      orderline.Main_Package_ID__c = pack.Id;
      orderline.Fee_Override__c = false;
      orderline.Fee_Override_Amount__c = 50;
      orderline.Subscription_Name__c = 'Test Subscription1';
      orderline.Fee_Waiver__c = false;
      insert orderline;

      Promotion__c promo = TestDataFactory.createPromotion(1)[0];
      promo.Contract_Period__c = '30';
      insert promo;
      
      Integer x = 2;
      List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(x);
      List<Zuora__Subscription__c> subRecs2 = new List<Zuora__Subscription__c>();
      for(Zuora__Subscription__c sub:subRecs){
          sub.Zuora__CustomerAccount__c = billAcc.Id;
          sub.Order_Line_Item_Number__c = orderline.Id;
          sub.Order_Line_Item_Number_1__c = orderline.Id;
          sub.Zuora__Status__c = 'Active';
          sub.Billing_Type__c = 'Full Prepaid';
          sub.Subscription_Type__c = 'Publication';
          sub.Zuora__Account__c = acc.Id;
          sub.Promotion__c = promo.Id;
          sub.Order_Number_1__c = order.Id;
          sub.Term_Length1__c = '1024';
          sub.Term_Length__c = 2;
          sub.Promotion_1__c = promo.id;
          if (subRecs.size() == x) {
            sub.Zuora__SubscriptionStartDate__c = date.today();
          } else {
            sub.Zuora__SubscriptionStartDate__c = Date.newInstance(2016, 2, 6);
          }
          subRecs2.add(sub);
      }

      insert subRecs2;

      orderline.Subscription__c = subRecs[1].Id;
      update orderline;
      
      map<Id, date> subscriptionId_effectiveDate = new map<Id, date>();
      subscriptionId_effectiveDate.put(subRecs[1].Id, date.today());
      //end test data
      
      try{
          test.setMock(WebServiceMock.class, new zLoginMock());
          test.startTest();
              SM_SubscriptionCancellationHelper.cancel(subscriptionId_effectiveDate, '');
          test.stopTest();
      }
      catch(Exception e){
      }
  }

  static testmethod void test02_CancelSubscription(){
      //start test data
      Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
      insert acc;
      
      Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
      billAcc.Zuora__Account__c = acc.Id;
      insert billAcc;
      
      Package__c pack = TestDataFactory.createPackage(1)[0];
      insert pack;
      
      order = TestDataFactory.createOrder(1)[0];
      order.Account__c = acc.Id;
      insert order;
      
      Promotion__c promo = TestDataFactory.createPromotion(1)[0];
      promo.Contract_Period__c = '30';
      insert promo;

      Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
      orderline.Order__c = order.Id;
      orderline.Main_Package_ID__c = pack.Id;
      orderline.Fee_Override__c = true;
      orderline.Fee_Override_Amount__c = 50;
      orderline.Subscription_Name__c = 'Test Subscription1';
      orderline.Fee_Waiver__c = false;
      orderline.Promotion_ID__c = promo.id;
      insert orderline;
      
      Integer x = 2;
      List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(x);
      List<Zuora__Subscription__c> subRecs2 = new List<Zuora__Subscription__c>();
      for(Zuora__Subscription__c sub:subRecs){
          sub.Zuora__CustomerAccount__c = billAcc.Id;
          sub.Order_Line_Item_Number__c = orderline.Id;
          sub.Order_Line_Item_Number_1__c = orderline.Id;
          sub.Zuora__Status__c = 'Active';
          sub.Billing_Type__c = 'Full Prepaid';
          sub.Subscription_Type__c = 'Publication';
          sub.Zuora__Account__c = acc.Id;
          sub.Promotion__c = promo.Id;
          sub.Order_Number_1__c = order.Id;
          sub.Term_Length1__c = '1024';
          sub.Term_Length__c = 2;
          sub.Promotion_1__c = promo.id;
          if (subRecs.size() == x) {
            sub.Zuora__SubscriptionStartDate__c = date.today();
          } else {
            sub.Zuora__SubscriptionStartDate__c = Date.newInstance(2016, 2, 6);
          }
          subRecs2.add(sub);
      }

      insert subRecs2;

      orderline.Subscription__c = subRecs[0].Id;
      update orderline;
      
      map<Id, date> subscriptionId_effectiveDate = new map<Id, date>();
      subscriptionId_effectiveDate.put(subRecs[0].Id, date.today());
      //end test data
      
      try{
          test.setMock(WebServiceMock.class, new zLoginMock());
          test.startTest();
              SM_SubscriptionCancellationHelper.cancel(subscriptionId_effectiveDate, '');
          test.stopTest();
      }
      catch(Exception e){
      }
  }

  static testmethod void test03_CancelSubscription(){
      //start test data
      Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
      insert acc;
      
      Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
      billAcc.Zuora__Account__c = acc.Id;
      insert billAcc;
      
      Package__c pack = TestDataFactory.createPackage(1)[0];
      insert pack;
      
      order = TestDataFactory.createOrder(1)[0];
      order.Account__c = acc.Id;
      insert order;
      
      Promotion__c promo = TestDataFactory.createPromotion(1)[0];
      promo.Contract_Period__c = '30';
      insert promo;

      Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
      orderline.Order__c = order.Id;
      orderline.Main_Package_ID__c = pack.Id;
      orderline.Fee_Override__c = false;
      orderline.Fee_Override_Amount__c = 50;
      orderline.Subscription_Name__c = 'Test Subscription1';
      orderline.Fee_Waiver__c = false;
      orderline.Promotion_ID__c = promo.id;
      insert orderline;
      
      Integer x = 2;
      List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(x);
      List<Zuora__Subscription__c> subRecs2 = new List<Zuora__Subscription__c>();
      for(Zuora__Subscription__c sub:subRecs){
          sub.Zuora__CustomerAccount__c = billAcc.Id;
          sub.Order_Line_Item_Number__c = orderline.Id;
          sub.Order_Line_Item_Number_1__c = orderline.Id;
          sub.Zuora__Status__c = 'Active';
          sub.Billing_Type__c = 'Full Prepaid';
          sub.Subscription_Type__c = 'Publication';
          sub.Zuora__Account__c = acc.Id;
          sub.Promotion__c = promo.Id;
          sub.Order_Number_1__c = order.Id;
          sub.Term_Length1__c = '1024';
          sub.Term_Length__c = 2;
          sub.Promotion_1__c = promo.id;
          if (subRecs.size() == x) {
            sub.Zuora__SubscriptionStartDate__c = date.today();
          } else {
            sub.Zuora__SubscriptionStartDate__c = Date.newInstance(2016, 2, 6);
          }
          subRecs2.add(sub);
      }

      insert subRecs2;

      orderline.Subscription__c = subRecs[0].Id;
      update orderline;
      
      map<Id, date> subscriptionId_effectiveDate = new map<Id, date>();
      subscriptionId_effectiveDate.put(subRecs[0].Id, date.today());
      //end test data
      
      try{
          test.setMock(WebServiceMock.class, new zLoginMock());
          test.startTest();
              SM_SubscriptionCancellationHelper.cancel(subscriptionId_effectiveDate, '');
          test.stopTest();
      }
      catch(Exception e){
      }
  }
}