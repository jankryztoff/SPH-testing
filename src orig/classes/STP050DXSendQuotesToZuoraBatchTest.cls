/** 
* class Name: STP050DXSendQuotesToZuoraBatchTest
* @author: Christian Coquilla
* Date: 10/21/15
* @description: Test Class for STP050DXSendQuotesToZuoraBatch
*/

@isTest//(seealldata = false)
public class STP050DXSendQuotesToZuoraBatchTest {
    
    static testMethod void test1(){        
        
        Set<String> selectiveIdSet = new Set<String>();
        
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId =  [Select Id From Profile Where Name = 'CSO Admin' LIMIT 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardKC09254785@test.com'
        );   
        
        
        //Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        //insert dtl;
        System.runAs(testUser){
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'PKGCD001';
            insert pack;
            
            Key_Id__c keyId = new Key_Id__c();
            keyId.Name = 'NEXT_RECIPIENT_NUMBER';
            KeyId.Id__c = '30465198';
            insert keyId;
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            insert con; 
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
            billAcc.Billing_Contact__c = con.id;
            billAcc.Billing_Type__c = 'Recurring Prepaid';
            insert billAcc;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Billing_Account__c = billAcc.Id;
            order.Billing_Contact__c = con.Id;
            order.Billing_Type__c = 'Recurring Prepaid'; //START END 12April2016 Added By C. Lin
            order.Order_Type__c = 'Start';
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            insert order;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2017, 12, 2);
            orderline.Start_Date__c = date.today()+1;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            insert orderline;
            
            zqu__Quote__c quote1 = TestDataFactory.createQuote(1)[0];
            quote1.Order_Line_Item_Number_1__c = orderline.Id;
            quote1.zqu__Status__c = 'New';
            insert quote1;
            
            zqu__QuoteCharge__c quoteCharge = TestDataFactory.createQuoteCharge(1)[0];
            quoteCharge.zqu__Quote__c = quote1.Id;
            insert quoteCharge;
            
            selectiveIdSet.add(order.Id);
            System.debug('>>>>>>test selectiveIdSet: ' + selectiveIdSet);
            
            BT_CO_STPPRS_StopPressSubscription__c stopPressSubs = new BT_CO_STPPRS_StopPressSubscription__c();
            stopPressSubs.Order__c = order.Id;
            stopPressSubs.Quotes_Created__c = FALSE;
            stopPressSubs.Validation_Status__c = 'Passed';
            stopPressSubs.subscription_package_code__c='PKGCD001';
            //Database.SaveResult myResult = Database.insert(stopPressSubs);                      
            //system.debug('>>>>>CHA myResult: ' + myResult);
            insert stopPressSubs;
            system.debug('>>>>>CHA stopPressSubs: ' + stopPressSubs);    
            List<Order__c> orderList = new List<Order__c>();
            orderList.add(order);
            test.startTest();        
            
            STP050DXSendQuotesToZuoraBatch batch = new STP050DXSendQuotesToZuoraBatch(selectiveIdSet);
            Database.executeBatch(batch,200);
            
            Database.BatchableContext BC;
            batch.execute(BC, orderList);
            
            test.stopTest();
            
        }
    }
    
        static testMethod void test2(){        
        
        Set<String> selectiveIdSet = new Set<String>();
        
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId =  [Select Id From Profile Where Name = 'CSO Admin' LIMIT 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standardKC09254785@test.com'
        );   
        
        
        //Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        //insert dtl;
        System.runAs(testUser){
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'PKGCD001';
            insert pack;
            
            Key_Id__c keyId = new Key_Id__c();
            keyId.Name = 'NEXT_RECIPIENT_NUMBER';
            KeyId.Id__c = '30465198';
            insert keyId;
            
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            insert con; 
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
            billAcc.Billing_Contact__c = con.id;
            billAcc.Billing_Type__c = 'Recurring Prepaid';
            insert billAcc;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Billing_Account__c = billAcc.Id;
            order.Billing_Contact__c = con.Id;
            order.Billing_Type__c = 'Recurring Prepaid'; //START END 12April2016 Added By C. Lin
            order.Order_Type__c = 'Start';
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account1';
            insert order;
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2017, 12, 2);
            orderline.Start_Date__c = date.today()+1;
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            insert orderline;
            
            zqu__Quote__c quote1 = TestDataFactory.createQuote(1)[0];
            quote1.Order_Line_Item_Number_1__c = orderline.Id;
            quote1.zqu__Status__c = 'New';
            insert quote1;
            
            zqu__QuoteCharge__c quoteCharge = TestDataFactory.createQuoteCharge(1)[0];
            quoteCharge.zqu__Quote__c = quote1.Id;
            insert quoteCharge;
            
            selectiveIdSet.add(order.Id);
            System.debug('>>>>>>test selectiveIdSet: ' + selectiveIdSet);
            
            BT_CO_STPPRS_StopPressSubscription__c stopPressSubs = new BT_CO_STPPRS_StopPressSubscription__c();
            stopPressSubs.Order__c = order.Id;
            stopPressSubs.Quotes_Created__c = FALSE;
            stopPressSubs.Validation_Status__c = 'Passed';
            stopPressSubs.subscription_package_code__c='PKGCD001';
            //Database.SaveResult myResult = Database.insert(stopPressSubs);                      
            //system.debug('>>>>>CHA myResult: ' + myResult);
            insert stopPressSubs;
            system.debug('>>>>>CHA stopPressSubs: ' + stopPressSubs);    
            List<Order__c> orderList = new List<Order__c>();
            orderList.add(order);
            test.startTest();        
            
            STP050DXSendQuotesToZuoraBatch batch = new STP050DXSendQuotesToZuoraBatch();
            Database.executeBatch(batch,200);
            
            Database.BatchableContext BC;
            batch.execute(BC, orderList);
            
            test.stopTest();
            
        }
    }
    
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
        Set<String> selectiveIdSet = new Set<String>();
        selectiveIdSet.add(orders[0].Id);
        //  test.startTest();

             
        //     SendQuotesToZuoraBatch batch = new SendQuotesToZuoraBatch(QuoteIds, PaymentMode1, PaymentModeOther1, sDeliveryChargeType1,bCreateNewBillingAccount1, bCreateDeliverySubscription1, bPayDeliveryChargeNow1,
        //                                  ExistingDeliverySubscriptionId1, SFBillingAccount1, zBillingAccount1, SubscriberCharge1,
        //                                 AccountId1, OrderId1, DeliveryFPSubscriptionUsage1, CCPaymentMethodID1);
        //     database.executeBatch(batch, 200);
               
        //     Database.BatchableContext BC;
        //     batch.execute(BC, orderLineItemList);
        // test.stopTest();    
        
        test.startTest();        
            
            STP050DXSendQuotesToZuoraBatch batch = new STP050DXSendQuotesToZuoraBatch(selectiveIdSet);
            Database.executeBatch(batch,200);
            
            Database.BatchableContext BC;
            batch.execute(BC, orders);
            
        test.stopTest();
        }
    
}