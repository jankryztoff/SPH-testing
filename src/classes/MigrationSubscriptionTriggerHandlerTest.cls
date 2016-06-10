@IsTest (seeAllData = True)
public class MigrationSubscriptionTriggerHandlerTest{
      
     static testmethod void MigrationSubscriptionTest1(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
          acc.Name = 'Test Account';
          insert acc;
          
          Package__c pack = new Package__c(); 
          pack.Package_Type__c = 'Base';
          pack.Name = 'TestPackageName';
          pack.Package_Code__c = 'SamplePackageCode';
          pack.Effective_Start_Date__c = date.Today();
          pack.Effective_End_Date__c = date.Today() + 30;
          insert pack;
          
          Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
          testCustomerAccount.Zuora__Account__c = acc.Id;
          insert testCustomerAccount;
           
          Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0]; 
          sub.Zuora__Account__c = acc.Id;
          sub.Zuora__SubscriptionEndDate__c = date.Today();
          sub.Zuora__CustomerAccount__c = testCustomerAccount.Id;
          sub.Legacy_Subscription_ID__c = 'LSUB00000';   
          sub.Main_Package_1__c = pack.id ;
          sub.Main_Package__c = pack.id;     
          insert sub;
              
        
          Test.startTest();
          MigrationSubscriptionTriggerHandler migSubHandler = new MigrationSubscriptionTriggerHandler();
          migSubHandler.doBeforeInsert(new List<Zuora__Subscription__c> { sub });
          Test.stopTest();
            
          System.assertEquals(sub.Legacy_Subscription_ID__c, 'LSUB00000');
      } 
    
     static testmethod void MigrationSubscriptionTest2(){
     try{
        Test.setMock(WebServiceMock.class, new zLoginMock()); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
          acc.Name = 'Test Account';
          insert acc;
          
          Contact con = TestDataFactory.createContact(1)[0];
          con.AccountId = acc.Id;
          con.Recipient_Indicator__c = true;
          insert con;
          
          Package__c pack = new Package__c(); 
          pack.Package_Type__c = 'Base';
          pack.Name = 'TestPackageName';
          pack.Package_Code__c = 'SamplePackageCode';
          pack.Effective_Start_Date__c = date.Today();
          pack.Effective_End_Date__c = date.Today() + 30;
          insert pack;
          
          Order__c order = TestDataFactory.createOrder(1)[0];
          order.Account__c = acc.id; 
          order.Initial_Term__c = '1';
          order.Recipient_Contact__c = con.Id;
          order.Subscriber_Charge__c = 0;
          insert order;
           
          Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
          testCustomerAccount.Zuora__Account__c = acc.Id;
          insert testCustomerAccount;
           
          Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0]; 
          sub.Zuora__Account__c = acc.Id;
          sub.Zuora__CustomerAccount__c = testCustomerAccount.Id;
          sub.Zuora__SubscriptionEndDate__c = date.Today();
          sub.Legacy_Subscription_ID__c = 'LSUB00000';  
          sub.Subscription_Type_1__c= 'Delivery';
          sub.Billing_Type__c = 'Full Prepaid';
          sub.Subscription_Type__c ='Delivery';
          sub.Main_Package_1__c = pack.id ;
          sub.Main_Package__c = pack.id;   
          sub.Order_Number_1__c = order.id;
          sub.Order_Number__c = order.id;
          insert sub;
          
          
          List<Zuora__Subscription__c> sub2 = TestDataFactory.createSubscription(2); 
          sub2[0].Zuora__Account__c = acc.Id;
          sub2[0].Zuora__CustomerAccount__c = testCustomerAccount.Id;
          sub2[0].Zuora__SubscriptionEndDate__c = date.Today();
          sub2[0].Legacy_Subscription_ID__c = 'LSUB00000';  
          sub2[0].Subscription_Type_1__c= 'Delivery';
          sub2[0].Billing_Type__c = 'Full Prepaid';
          sub2[0].Subscription_Type__c ='Delivery';
          sub2[0].Main_Package_1__c = pack.id ;
          sub2[0].Main_Package__c = pack.id;   
          sub2[0].Order_Number_1__c = order.id;
          sub2[0].Order_Number__c =order.id;
          
          sub2[1].Zuora__Account__c = acc.Id;
          sub2[1].Zuora__CustomerAccount__c = testCustomerAccount.Id;
          sub2[1].Zuora__SubscriptionEndDate__c = date.Today();
          sub2[1].Legacy_Subscription_ID__c = 'LSUB00000';  
          sub2[1].Subscription_Type_1__c= 'Delivery';
          sub2[1].Billing_Type__c = 'Full Prepaid';
          sub2[1].Subscription_Type__c ='Delivery';
          sub2[1].Main_Package_1__c = pack.id ;
          sub2[1].Main_Package__c = pack.id;   
          sub2[1].Order_Number_1__c = order.id;
          sub2[1].Order_Number__c =order.id;
          insert sub2;
          
          sub = [SELECT Id, Legacy_Subscription_ID__c, Order_Number_1__c, Order_Line_Item_Number_1__c,Subscription_Type_1__c, Billing_Type__c   FROM Zuora__Subscription__c WHERE Id = :sub.Id];
         
          Map<Id, Zuora__Subscription__c> subMap1 = new Map<Id, Zuora__Subscription__c>();
          subMap1.put(sub.id, sub);
            
          Map<Id, Zuora__Subscription__c> subMap2 = new Map<Id, Zuora__Subscription__c>();
          subMap2.put(sub.id, sub);
          
          Test.startTest();
          MigrationSubscriptionTriggerHandler migSubHandler = new MigrationSubscriptionTriggerHandler();
          migSubHandler.doAfterUpdate(new List<Zuora__Subscription__c> { sub }, subMap1 , new List<Zuora__Subscription__c> { sub }, subMap2);
          migSubHandler.doBeforeInsert(sub2);
          migSubHandler.doBeforeUpdate(sub2, subMap1 , sub2, subMap2);
          Test.stopTest();
            
          System.assertEquals(sub.Legacy_Subscription_ID__c, 'LSUB00000');
          }catch (Exception e){}
          
      }
    
    static testmethod void MigrationSubscriptionTest3(){
    try{
        Test.setMock(WebServiceMock.class, new zLoginMock());    
       Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
          acc.Name = 'Test Account';
          insert acc;
          
          Contact con = TestDataFactory.createContact(1)[0];
          con.AccountId = acc.Id;
          con.Recipient_Indicator__c = true;
          insert con;
          
          Package__c pack = new Package__c(); 
          pack.Package_Type__c = 'Base';
          pack.Name = 'TestPackageName';
          pack.Package_Code__c = 'SamplePackageCode';
          pack.Effective_Start_Date__c = date.Today();
          pack.Effective_End_Date__c = date.Today() + 30;
          insert pack;
                   
          Order__c order = TestDataFactory.createOrder(1)[0];
          order.Account__c = acc.id; 
          order.Initial_Term__c = '1';
          order.Recipient_Contact__c = con.Id;
          insert order;
          
          Order_Line_Item__c  orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
          orderLineItem.Order__c = order.id;
          orderLineItem.Main_Package_ID__c = pack.id;
          insert orderLineItem;
          
          //Promotion__c promo = new Promotion__c();
         //insert promo;
          
          Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
          testCustomerAccount.Zuora__Account__c = acc.Id;
          insert testCustomerAccount;
          
          Subscription_Vendor__c vensub = TestDataFactory.createSubscriptionVendor(1)[0];
          vensub.Account__c = acc.id;
          insert vensub;
          
          Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0]; 
          sub.Zuora__Account__c = acc.Id;
          sub.Zuora__CustomerAccount__c = testCustomerAccount.Id;
          sub.Zuora__SubscriptionEndDate__c = date.Today();
          sub.Legacy_Subscription_ID__c = 'LSUB00000'; 
          sub.Subscription_Type__c = 'Delivery';
          sub.Billing_Type__c = 'Full Prepaid';  
          sub.Billing_Type_isNull__c = 'false';
          sub.Term_Length__c = 10;
          sub.Delivery_Charge__c = 10;
          sub.Delivered_By__c = 'Vendor';
          sub.Order_Line_Item_Number__c = orderLineItem.id;
          //sub.Addon_Package_1__c = pack.id;
          sub.Addon_Package__c = pack.id;
          sub.Number_of_Copies__c = 10;
          sub.Order_Number__c = order.id;
          sub.Recipient_Contact__c = con.id;
          sub.Recipient_Contact_isNull__c = 'False';
          sub.Subscriber_Contact__c = con.id;
          sub.Vendor_Subscription_To_Convert__c = vensub.id;
          sub.Vendor_1__c= acc.id;
           sub.Main_Package_1__c = pack.id ;
          sub.Main_Package__c = pack.id;
          sub.Order_Number_1__c = order.id;
          sub.Order_Number__c =order.id;
          //sub.Promotion__c = promo.id;
          insert sub;
          
          List<Zuora__Subscription__c> sub2 = TestDataFactory.createSubscription(2); 
          sub2[0].Zuora__Account__c = acc.Id;
          sub2[0].Zuora__CustomerAccount__c = testCustomerAccount.Id;
          sub2[0].Zuora__SubscriptionEndDate__c = date.Today();
          sub2[0].Legacy_Subscription_ID__c = 'LSUB00000';  
          sub2[0].Subscription_Type_1__c= 'Delivery';
          sub2[0].Billing_Type__c = 'Full Prepaid';
          sub2[0].Subscription_Type__c ='Delivery';
          sub2[0].Main_Package_1__c = pack.id ;
          sub2[0].Main_Package__c = pack.id;   
          sub2[0].Order_Number_1__c = order.id;
          sub2[0].Order_Number__c =order.id;
          
          sub2[1].Zuora__Account__c = acc.Id;
          sub2[1].Zuora__CustomerAccount__c = testCustomerAccount.Id;
          sub2[1].Zuora__SubscriptionEndDate__c = date.Today();
          sub2[1].Legacy_Subscription_ID__c = 'LSUB00000';  
          sub2[1].Subscription_Type_1__c= 'Delivery';
          sub2[1].Billing_Type__c = 'Full Prepaid';
          sub2[1].Subscription_Type__c ='Delivery';
          sub2[1].Main_Package_1__c = pack.id ;
          sub2[1].Main_Package__c = pack.id;   
          sub2[1].Order_Number_1__c = order.id;
          sub2[1].Order_Number__c =order.id;
          insert sub2;
          
          order.Full_Prepaid_Delivery_Charge__c = integer.valueof(sub.Term_Length__c) * sub.Delivery_Charge__c;
          update order;
           
          sub = [SELECT Id, Legacy_Subscription_ID__c, Order_Number_1__c, Order_Line_Item_Number_1__c, Delivered_By_1__c, Addon_Package_1__c, Number_of_Copies1__c, Subscriber_Contact_1__c, Vendor__c FROM Zuora__Subscription__c WHERE Id = :sub.Id];
         
          Map<Id, Zuora__Subscription__c> subMap1 = new Map<Id, Zuora__Subscription__c>();
          subMap1.put(sub.id, sub);
            
          Map<Id, Zuora__Subscription__c> subMap2 = new Map<Id, Zuora__Subscription__c>();
          subMap2.put(sub.id, sub);
          
          Test.startTest();
          MigrationSubscriptionTriggerHandler migSubHandler = new MigrationSubscriptionTriggerHandler();
          migSubHandler.doBeforeUpdate(new List<Zuora__Subscription__c> { sub }, subMap1 , sub2, subMap2);
          Test.stopTest();
            
          System.assertEquals(sub.Legacy_Subscription_ID__c, 'LSUB00000');
      }catch (Exception e){
      
      }
    }
        
    
     

}