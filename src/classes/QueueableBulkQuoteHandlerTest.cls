/*
 * Class Name: BulkAsiaOneSignUpLevel1QueueableTest
 * @author: Jensar Joey Z. Sayson
 * Date: 4/8/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for BulkAsiaOneSignUpLevel1Queueable
 */

@isTest(seeAllData = true)
public class QueueableBulkQuoteHandlerTest {
   
    //initializing queueable class
   /* 
    static testMethod void test02(){ 
        system.debug('ENTER test02');
        map<id, map<string, string>> orderId_creditCard = new map<id, map<string, string>>();
        map<string, string> orderIdCreditCard = new map<string, string>();
        set<id> orderIdSet = new set<id>(); 
        set<id> urgentOrderIdSet = new set<id>();    

        Test.startTest();
            System.enqueueJob(new QueueableBulkQuoteHandler(orderIdSet,urgentOrderIdSet,orderId_creditCard,'test','test',1));
            System.assertNotEquals(null,1);
        Test.stopTest();  
        system.debug('END test02');  
    }
    **/
    static testMethod void test03(){ 
        
        map<id, map<string, string>> orderId_creditCard = new map<id, map<string, string>>();
        map<string, string> orderIdCreditCard = new map<string, string>();
        set<id> orderIdSet = new set<id>(); 
        set<id> urgentOrderIdSet = new set<id>();    

        Delivery_Charge_Type__c charge = Delivery_Charge_Type__c.getInstance('Internal');
        Other__c odd1 = Other__c.getInstance('DTL');
        Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');
        //start test data
        //start test data
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
        
        List<zqu__ProductRatePlan__c> prp = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c p:prp){
            p.RatePlanCode__c = 'CHGPOS';
            p.zqu__Deleted__c = false;
            p.zqu__ZProduct__c = zp.Id;
            p.RatePlanType__c= 'Proration';
            p.RatePlanSubType__c = 'Standard';
            p.SubscriptionFrequency__c = '1';
        }
        database.insert(prp);
        
        Billing_Batch__c bbatch = Billing_Batch__c.getInstance('Full Prepaid');

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '0.0';
        database.insert(subRecs);
        //Zuora__DefaultPaymentMethod__c
        
        List<Order__c> order = new List<Order__c>(); //TestDataFactory.createOrder(1)[0];
        for(Integer x = 0; x < 3; x++){
            Order__c ord = new Order__c();
            ord.Account__c = acc.Id;
            ord.Base_Subscription__c = subRecs.Id;
            ord.Recipient_Contact__c = con.Id;
            ord.Credit_Balance__c=20000.00;
            ord.Delivery_Charge__c=100.00;
            order.add(ord);
        }
        
        database.insert(order);

        Other__c cSets = Other__c.getInstance('OrderUpload|2016-03-07 16:11:03');

        Case caserec = TestDataFactory.createCase(1,'Complaint - Magazine')[0];
        caserec.Order__c = order[0].Id;
        caserec.Sub_Status__c = 'Provisioning';

        insert caserec;


        // Order__c ord2 = new Order__c(); //TestDataFactory.createOrder(1)[0];
        // //ord2.Name = 'test2';
        // ord2.Credit_Balance__c=20000.00;
        // ord2.Delivery_Charge__c=100.00;
        // ord2.Account__c = acc.id;
        // Database.insert(ord2);


        // Order__c ord3 = new Order__c(); //TestDataFactory.createOrder(1)[0];
        // //ord3.Name = 'test3';
        // ord3.Credit_Balance__c=20000.00;
        // ord3.Delivery_Charge__c=100.00;
        // ord3.Account__c = acc.id;
        // Database.insert(ord3);

        
        //orderIdSet.add(ord2.Id);
        urgentOrderIdSet.add(order[1].Id);
        orderIdCreditCard.put(''+order[1],''+order[2]);
        orderId_creditCard.put(order[0].Id, orderIdCreditCard);
        /*
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = billAcc.Id;
        subs.Zuora__SubscriptionStartDate__c = date.today();
        subs.Term_Length1__c = '0.0';
        subs.Order_Number_1__c = order.Id;
        subs.Zuora__Zuora_Id__c = 'id1234';
        database.insert(subs);
        **/                      
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
            oli.order__c = order[0].Id;
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
        
        List<Order_Line_Item_Gift__c> olif = TestDataFactory.createItemGift(1);
        for(Order_Line_Item_Gift__c oli:olif){
            oli.Order_Line_Item__c = orderline[0].Id;
            oli.Promotion_Gift__c = promGift.Id;
        }
        database.insert(olif);
        
        List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(1);
        for(zqu__ProductRatePlanCharge__c pr: prpc){
            pr.zqu__ProductRatePlan__c = prp[0].Id;
            pr.zqu__Deleted__c = false;
        }
        database.insert(prpc);

        Set<Id> prpcSet = new Set<Id>();
        prpcSet.add(prpc[0].Id);
        //prpcSet.add(prpc[1].Id);
        
        Integer counter=0;
        List<zqu__ProductRatePlanChargeTier__c> prpct = TestDataFactory.createProductRatePlanChargeTier(1);
        for(zqu__ProductRatePlanChargeTier__c pr:prpct){
            pr.zqu__ProductRatePlanCharge__c = prpc[counter].Id;
            pr.zqu__PriceFormat__c = 'Per Unit';
            pr.zqu__Currency__c = 'SGD';
            pr.zqu__Price__c = 10;
            counter++;
        }
        database.insert(prpct);
        
        List<zqu__ProductRatePlanCharge__c> prpcResult = [Select sum__c from zqu__ProductRatePlanCharge__c where Id IN : prpcSet];

        zqu__Quote__c quote = TestDataFactory.createQuote(1)[0];
        quote.Frequency__c = 'Default';
        quote.Subscription_Type__c  = 'Postage';
        quote.Order_Line_Item_Number__c = orderline[0].Id; 
        database.insert(quote);
        
        zqu__QuoteCharge__c qc = TestDataFactory.createQuoteCharge(1)[0];
        qc.zqu__Quote__c = quote.Id;
        qc.zqu__ProductRatePlanCharge__c = prpc[0].Id;
        database.insert(qc);
        
        //set<id> orderIdSet = new set<id>();
        orderIdSet.add(order[0].Id);
        

        Test.startTest();
            System.debug('#$# size: ' + prpcResult.size());
            System.debug('#$# Check Sum: ' + prpcResult);
            System.assertEquals(10 ,prpcResult[0].sum__c);
            // System.assertEquals(10 ,prpcResult[1].sum__c);
            System.enqueueJob(new QueueableBulkQuoteHandler(orderIdSet,urgentOrderIdSet,orderId_creditCard,'test','OrderUpload|2016-03-07 16:11:03',1));
            System.assertNotEquals(null,1);
        Test.stopTest();   
    }
}