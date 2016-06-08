/**
 * Class Name: RenewSubscriptionServiceTest2
 * @author: Recuerdo Bregente  
 * Date: 10 Aug 2015    
 * Requirement/Project Name: SPH Project    
 * @description Test Class for RenewSubscriptionService
 */
@isTest(seeAllData=false)
public class RenewSubscriptionServiceTest2{

    // Test Data
    static RenewSubscriptionService.RenewSubscriptionServiceResponse response;
    static RenewSubscriptionService.RenewSubscriptionServiceRequest request;
    static RenewSubscriptionServiceRequest requestTemp;
    
    static Account acc;
    static Singpost_Address__c postal;
    static Address__c address;
    static List<Contact> con;
    static List<Package__c> pkg;
    static List<Zuora__CustomerAccount__c> zcaList;
    static List<Zuora__PaymentMethod__c> zpmList;
    static List<Zuora__Subscription__c> zSubs;
    static Order_Line_Item__c orderline;
    static Order__c orderRec;
    
     public class RenewSubscriptionServiceRequest {
        String subscriptionId;
        String subscriberId;
        String packageCode;
        String billingAccountNumber;
        String paymentMethodId;
        String subscriptionEndDate;
        String subscriptionStartDate;   
        String contractEndDate;  
        List<String> giftCode;
        String paypalBAID;
        String paypalEmail;
     
    }
    
    
    /**
    * @name : prepareTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 08/10/2015
    */ 
    static void prepareTestData(String methodType, String externalId, String termLength){
        defaultCustomSetting();
        
        acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId =  [SELECT id FROM RecordType WHERE SObjectType='Account' AND Name='Direct Corporate'].Id; 
        acc.Email__c = 'recuerdo.bregente@gmail.com';
        acc.Mobile__c = '09324861074';
        insert acc;
            
        postal = new Singpost_Address__c();
        postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Country__c countr = TestDataFactory.createCountry(1)[0];
        countr.Country_Name__c = 'Test Country';
        countr.Zonal_Code__c = 'ZC1';
        insert countr;
            
        address = new Address__c();
        address = TestDataFactory.createAddress(1)[0];
        address.Postal_Code__c = postal.Id;
        address.Country__c = countr.Id;
        insert address;
        
        Zone__c zoneRec = new Zone__c();
        zoneRec.Name = 'ZC1';
        zoneRec.Zone_Name_External_Id__c = '123';
        insert zoneRec;
        
        con = TestDataFactory.createContact(1);
        con[0].Phone = '1234567';
        con[0].AccountId = acc.Id;
        con[0].Recipient_Indicator__c = true;
        con[0].Address__c = address.Id;
        insert con;
                   
        pkg = TestDataFactory.createPackage(1);
        pkg[0].Subscription_Period__c = '15';
        pkg[0].Effective_End_Date__c = Date.today();
        pkg[0].Effective_Start_Date__c = Date.today();
        pkg[0].Package_Code__c = 'PKGCD001';
        pkg[0].Billing_Type__c = 'Recurring Prepaid';
        insert pkg;
           
        zcaList = TestDataFactory.createBillingAccount(1);
        zcaList[0].Name = 'Zuora Customer Account';
        zcaList[0].Zuora__Account__c = acc.Id;
        zcaList[0].Zuora__Credit_Balance__c = 1;
        zcaList[0].Refund_Amount__c = 100;
        zcaList[0].Zuora__AutoPay__c =false;
        zcaList[0].Zuora__Balance__c = 1;
        zcaList[0].Payment_Mode__c = methodType;
        zcaList[0].Other_PaymentMethod__c= methodType;
        zcaList[0].Zuora__PaymentMethodType__c = methodType; 
        zcalist[0].Zuora__External_Id__c = '22544AA';  
        zcalist[0].Zuora__Zuora_Id__c = '0124';  
        zcalist[0].Zuora__Batch__c = 'Batch'+ConstantsSLB.getBillingBatch('Default');  
        zcalist[0].Zuora__DefaultPaymentMethod__c = methodType;
        zcalist[0].Billing_Type__c = 'Recurring Prepaid';
        insert zcaList;
            
        //START : D-1929 3/2/2015 added to create Default Payment Method
        zpmList = TestDataFactory.createPaymentMethod(1);
        zpmList[0].Name = 'Zuora Customer Account';
        zpmList[0].Zuora__Type__c = methodType;
        zpmList[0].Zuora__BillingAccount__c = zcaList[0].id;
        if(externalId != null){
            zpmList[0].Zuora__External_Id__c = externalId;
        }
        
        insert zpmList;  
        //End: D-1929 3/2/2015 added to create Default Payment Method
            
        zcalist[0].Zuora__Default_Payment_Method__c = zpmList[0].id;         
        update zcaList;
            
        orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = con[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        orderRec.Billing_Type__c = 'Recurring Prepaid';
        insert orderRec;
                
        orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = orderRec.Id;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pkg[0].id;
        orderline.Main_Package_Billing_Type__c = 'Full Prepaid';
        orderline.Qty__c = 1;
        try
        {
            //insert orderline;
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
            
        //create billing account      
        zSubs =  TestDataFactory.createSubscription(1);
        zSubs[0].Order_Line_Item_Number__c = orderline.Id;
        zSubs[0].Subscriber_Contact__c = con[0].id;
        zSubs[0].Main_Package__c = pkg[0].id;
        zSubs[0].Zuora__Account__c = acc.id;
        zSubs[0].Order_Number__c = orderRec.Id;
        zSubs[0].Zuora__CustomerAccount__c = zcaList[0].Id;
        zSubs[0].Recipient_Contact__c = con[0].id;
        zSubs[0].Billing_Type_isNull__c = 'FALSE';
        zSubs[0].Billing_Type__c = 'Full Prepaid';
        zSubs[0].Zuora__SubscriptionStartDate__c = Date.today();
        zSubs[0].Zuora__Zuora_Id__c = 'ZZID001';
        if(termLength != null){
            zSubs[0].Term_Length1__c = termLength;
        }
        try
        {
            //insert zSubs;
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
       
        
        List<Gift__c> gifts = TestDataFactory.createGift(2);
        for(Gift__c  gift:gifts){
            gift.Gift_Type__c = 'Premium';
            gift.Gift_Code__c  = '1233333';
            gift.One_Time_Charge__c = 100;
        }
        gifts[0].Gift_Code__c  = 'GC001';
        gifts[1].Gift_Code__c  = 'GC002';
        insert gifts;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Magazine';
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        prdRatePlan.BillingType__c = 'Recurring Prepaid';
        insert prdRatePlan;        
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;        
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pkg[0].id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Zone__c = zoneRec.id;
        zoneProd.Product__c = zProduct.id;
        zoneProd.Postage_Charge__c = 10.00;
        zoneProd.Effective_Start_Date__c = Date.today();
        insert zoneProd;
        
    }
    
    /**
    * @name: testProcessRequest
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRequest method.
    * @date: 08/10/2015
    */
    static testMethod void testProcessRequest(){
        try{
            prepareTestData('Invoice', 'ZEID0000001', '1');
            
            zSubs[0].Term_Length__c = 1;
            zSubs[0].Zuora__SubscriptionEndDate__c = Date.today().addMonths(1);
            try
            {
                //update zSubs;
            }catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
           
        
            List<Account> accountList = [SELECT Id, Account_Auto_Number__c FROM Account
                                        WHERE Id = :acc.id];
            
            Test.StartTest();
            
            requestTemp = new RenewSubscriptionServiceRequest();
            requestTemp.subscriptionId = 'ZZID001';
            requestTemp.subscriberId = accountList[0].Account_Auto_Number__c;
            requestTemp.giftCode = new List<String>{'GC001','GC002'};
            requestTemp.packageCode = 'PKGCD001';
            
            
            request = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
            String jsonStr = JSON.serialize(requestTemp);
            request = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
            response = RenewSubscriptionService.processRequest(request);
            System.assertNotEquals(null, response);
                                                            
            Test.StopTest();
            
            
        } catch (Zuora.zAPIException e){
            System.assertNotEquals(null, e);
        }
        
            try
            {
                Zuora__Subscription__c subscription = RenewSubscriptionService.getSubscription('ZZID001');
                
                Package__c renewalPackageRecord;
                String renewalPackageCode = subscription.Main_Package_1__r.Package_Code__c;
                    
                renewalPackageRecord = RenewSubscriptionService.getPackage(renewalPackageCode);
                Account accountRecord = RenewSubscriptionService.getAccount(requestTemp.subscriberId);
                
                Order__c oldOrder = RenewSubscriptionService.getOrder(subscription.Order_Number__c);
                Order__c newOrder = (Order__c)SObjectAllFieldCloner.cloneObject(oldOrder,oldOrder.getsObjectType());
                newOrder.Order_Legacy_Id__c  = null;
                Date subscriptionStartDate = subscription.Zuora__SubscriptionEndDate__c.addDays(1);
                newOrder.Subscription_Start_Date__c = subscription.Zuora__SubscriptionEndDate__c.addDays(1);
                newOrder.Subscription_End_Date__c = subscriptionStartDate.addMonths(Integer.valueOf(renewalPackageRecord.Subscription_Period__c));
                newOrder.Account__c = accountRecord.Id;
                newOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
                newOrder.Billing_Account__c = subscription.Zuora__CustomerAccount__r.Id;
                newOrder.OwnerId = UserInfo.getUserId();
                insert newOrder;
                
                Order_Line_Item__c oldOrderLineItem = RenewSubscriptionService.getOrderLineItem(subscription.Order_Line_Item_Number__c);
                
                NewSubscriptionService.OrderLineItemWrapper orderLineItem = new NewSubscriptionService.OrderLineItemWrapper();
                orderLineItem.packagecode = renewalPackageCode;
                orderLineItem.quantity = Integer.valueOf(oldOrderLineItem.Qty__c);          
                
                // TO-DO:
                orderLineItem.startDate = String.valueOf(subscriptionStartDate.month()) + '/' + String.valueOf(subscriptionStartDate.day()) + '/' + String.valueOf(subscriptionStartDate.year());
                orderLineItem.giftCode = requestTemp.giftCode;
                //orderLineItem.contractEndDate = request.contractEndDate;
                
                List<NewSubscriptionService.OrderLineItemWrapper> orderLineItemList = new List<NewSubscriptionService.OrderLineItemWrapper>();
                orderLineItemList.add(orderLineItem);
                
                //START D-0821 1/14/2015 Added By C. Lin - Add missing parameter
                //START D-1846 20/01/2015 Wenjun : Set New Postage Charge
                Contact recipientContact = RenewSubscriptionService.getRecipientContact(newOrder.Recipient_Contact__c);
                NewSubscriptionService.createOrderLineItems(orderLineItemList,newOrder,null,recipientContact, null);
            }catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
    }
    
    /**
    * @name: testProcessRequestWithParentSubscription
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRequest method.
    * @date: 08/10/2015
    */
    static testMethod void testProcessRequestWithParentSubscription(){
        try{
            prepareTestData('Invoice', 'ZEID0000001', '1');
            
            Test.StartTest();
            
            Zuora__Subscription__c subParent = TestDataFactory.createSubscription(1)[0];
            subParent.Order_Line_Item_Number__c = orderline.Id;
            subParent.Subscriber_Contact__c = con[0].id;
            subParent.Main_Package__c = pkg[0].id;
            subParent.Zuora__Account__c = acc.id;
            subParent.Order_Number__c = orderRec.Id;
            subParent.Zuora__CustomerAccount__c = zcaList[0].Id;
            subParent.Recipient_Contact__c = con[0].id;
            subParent.Billing_Type_isNull__c = 'FALSE';
            subParent.Billing_Type__c = 'Full Prepaid';
            try
            {
                //insert subParent;
            }catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
            
            
            zSubs[0].Term_Length__c = 1;
            zSubs[0].Zuora__SubscriptionEndDate__c = Date.today().addMonths(1);
            zSubs[0].Grace_Period_Subscription__c = subParent.Id;
            try
            {
                //update zSubs;
            }catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
            
        
            List<Account> accountList = [SELECT Id, Account_Auto_Number__c FROM Account
                                        WHERE Id = :acc.id];  
            
            requestTemp = new RenewSubscriptionServiceRequest();
            requestTemp.subscriptionId = 'ZZID001';
            requestTemp.subscriberId = accountList[0].Account_Auto_Number__c;
            requestTemp.giftCode = new List<String>{'GC001','GC002'};
            requestTemp.packageCode = 'PKGCD001';
            
            
            request = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
            String jsonStr = JSON.serialize(requestTemp);
            request = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
            response = RenewSubscriptionService.processRequest(request);
            System.assertNotEquals(null, response);
                                                            
            Test.StopTest();
            
            
        } catch (Zuora.zAPIException e){
            System.assertNotEquals(null, e);
        }
    }
    
    /**
    * @name: testProcessRequestWithValidPaypalBAID
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRequest method PaypalBAID in request object is valid.
    * @date: 08/10/2015
    */
    static testMethod void testProcessRequestWithValidPaypalBAID(){
        try{
            prepareTestData('Invoice', 'ZEID0000001', '1');
            
            zSubs[0].Term_Length__c = 1;
            zSubs[0].Zuora__SubscriptionEndDate__c = Date.today().addMonths(1);
            try
            {
                //update zSubs;
            }catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
        
            List<Account> accountList = [SELECT Id, Account_Auto_Number__c FROM Account
                                        WHERE Id = :acc.id];  
            
            requestTemp = new RenewSubscriptionServiceRequest();
            requestTemp.subscriptionId = 'ZZID001';
            requestTemp.subscriberId = accountList[0].Account_Auto_Number__c;
            requestTemp.giftCode = new List<String>{'GC001','GC002'};
            requestTemp.packageCode = 'PKGCD001';
            requestTemp.paypalBAID = zcalist[0].Id;
            requestTemp.paypalEmail = 'ana.dumanagas@email.com';
            
            
            request = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
            String jsonStr = JSON.serialize(requestTemp);
            request = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
            
            Test.StartTest();
            response = RenewSubscriptionService.processRequest(request);
            System.assertNotEquals(null, response);
                                                            
            Test.StopTest();
        } catch (Zuora.zAPIException e){
            System.assertNotEquals(null, e);
        }
    }
    
    /**
    * @name: testProcessRequestWithBillingTypeIsFullPrepaid
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRequest method with billing type of billing account is Full Prepaid.
    * @date: 08/10/2015
    */
    static testMethod void testProcessRequestWithBillingTypeIsFullPrepaid(){
        try{
            prepareTestData('Invoice', 'ZEID0000001', '1');
            
            zcalist[0].Billing_Type__c = 'Full Prepaid';
            update zcaList;
            
            zSubs[0].Term_Length__c = 1;
            zSubs[0].Zuora__SubscriptionEndDate__c = Date.today().addMonths(1);
            try
            {
                //update zSubs;
            }catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
        
            List<Account> accountList = [SELECT Id, Account_Auto_Number__c FROM Account
                                        WHERE Id = :acc.id];  
            
            requestTemp = new RenewSubscriptionServiceRequest();
            requestTemp.subscriptionId = 'ZZID001';
            requestTemp.subscriberId = accountList[0].Account_Auto_Number__c;
            requestTemp.giftCode = new List<String>{'GC001','GC002'};
            requestTemp.packageCode = 'PKGCD001';
            
            
            request = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
            String jsonStr = JSON.serialize(requestTemp);
            request = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
            
            Test.StartTest();
            response = RenewSubscriptionService.processRequest(request);
            System.assertNotEquals(null, response);
                                                            
            Test.StopTest();
        } catch (Zuora.zAPIException e){
            System.assertNotEquals(null, e);
        }
    }
    
    /**
    * @name: testProcessRequestWithNoSubscriptionEndDate
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRequest method with no SubscriptionEndDate.
    * @date: 08/10/2015
    */
    static testMethod void testProcessRequestWithNoSubscriptionEndDate(){
        try{
            prepareTestData('Invoice', 'ZEID0000001', null);
        
            List<Account> accountList = [SELECT Id, Account_Auto_Number__c FROM Account
                                        WHERE Id = :acc.id];  
            
            requestTemp = new RenewSubscriptionServiceRequest();
            requestTemp.subscriptionId = 'ZZID001';
            requestTemp.subscriberId = accountList[0].Account_Auto_Number__c;
            requestTemp.giftCode = new List<String>{'GC001','GC002'};
            requestTemp.packageCode = 'PKGCD001';
            
            
            request = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
            String jsonStr = JSON.serialize(requestTemp);
            request = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
            
            Test.StartTest();
            response = RenewSubscriptionService.processRequest(request);
            System.assertNotEquals(null, response);
                                                            
            Test.StopTest();
        } catch (Zuora.zAPIException e){
            System.assertNotEquals(null, e);
        }
    }
    
    /**
    * @name: testProcessRequestWithNoGiftCodeFound
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRequest method with gift code not found.
    * @date: 08/10/2015
    */
    static testMethod void testProcessRequestWithNoGiftCodeFound(){
        try{
            prepareTestData('Invoice', 'ZEID0000001', '1');
        
            List<Account> accountList = [SELECT Id, Account_Auto_Number__c FROM Account
                                        WHERE Id = :acc.id];  
            
            requestTemp = new RenewSubscriptionServiceRequest();
            requestTemp.subscriptionId = 'ZZID001';
            requestTemp.subscriberId = accountList[0].Account_Auto_Number__c;
            requestTemp.billingAccountNumber = '0124';
            requestTemp.giftCode = new List<String>{'GC003','GC004'};
            requestTemp.packageCode = 'PKGCD001';
            
            
            request = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
            String jsonStr = JSON.serialize(requestTemp);
            request = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
            
            Test.StartTest();
            try{
                response = RenewSubscriptionService.processRequest(request);
                System.assertNotEquals(null, response);
            } catch (System.NullPointerException e) {
                System.assertNotEquals(null, e);
            } 
                                                            
            Test.StopTest();
        } catch (Zuora.zAPIException e){
            System.assertNotEquals(null, e);
        }
        
    }
    
    /**
    * @name: testProcessRequestWithBillingAccountNotFound
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRequest method with billing Account not found.
    * @date: 08/10/2015
    */
    static testMethod void testProcessRequestWithBillingAccountNotFound(){
        try{
            prepareTestData('Invoice', 'ZEID0000001', '1');
        
            List<Account> accountList = [SELECT Id, Account_Auto_Number__c FROM Account
                                        WHERE Id = :acc.id];  
            
            requestTemp = new RenewSubscriptionServiceRequest();
            requestTemp.subscriptionId = 'ZZID001';
            requestTemp.subscriberId = accountList[0].Account_Auto_Number__c;
            requestTemp.billingAccountNumber = '0123';
            
            request = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
            String jsonStr = JSON.serialize(requestTemp);
            request = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
            
            Test.StartTest();
            
            try{
                response = RenewSubscriptionService.processRequest(request);
                System.assertNotEquals(null, response);
            } catch (System.NullPointerException e) {
                System.assertNotEquals(null, e);
            }       
                                                     
            Test.StopTest();
        } catch (Zuora.zAPIException e){
            System.assertNotEquals(null, e);
        }
        
    }
    
    /**
    * @name: testProcessRequestWithNoPaymentMethodExternalId
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRequest method with no Payment Method External Id.
    * @date: 08/10/2015
    */
    static testMethod void testProcessRequestWithNoPaymentMethodExternalId(){
        prepareTestData('Invoice', null, '1');
        
        List<Account> accountList = [SELECT Id, Account_Auto_Number__c FROM Account
                                    WHERE Id = :acc.id];  
        
        requestTemp = new RenewSubscriptionServiceRequest();
        requestTemp.subscriptionId = 'ZZID001';
        requestTemp.subscriberId = accountList[0].Account_Auto_Number__c;
        
        request = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(requestTemp);
        request = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
        
        Test.StartTest();
        response = RenewSubscriptionService.processRequest(request);
        System.assertNotEquals(null, response);
                                                        
        Test.StopTest();
    }
    
    /**
    * @name: testProcessRequestWithAccountNotMatched
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRequest method with account not matched.
    * @date: 08/10/2015
    */
    static testMethod void testProcessRequestWithAccountNotMatched(){
        prepareTestData('Invoice', null, '1');
        
        Account newAcc = new Account();
        newAcc.Name = 'Test Account';
        //newAcc.RecordTypeId =  '012N00000008ic6'; 
        newAcc.RecordTypeId = [SELECT id FROM RecordType WHERE SObjectType='Account' AND Name='Direct Corporate'].Id; 
        newAcc.Email__c = 'recuerdo.bregente@gmail.com';
        newAcc.Mobile__c = '09324861074';
        insert newAcc;
        
        List<Account> accountList = [SELECT Id, Account_Auto_Number__c FROM Account
                                    WHERE Id = :newAcc.id];  
        
        requestTemp = new RenewSubscriptionServiceRequest();
        requestTemp.subscriptionId = 'ZZID001';
        requestTemp.subscriberId = accountList[0].Account_Auto_Number__c;
        
        request = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(requestTemp);
        request = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
        
        Test.StartTest();
        response = RenewSubscriptionService.processRequest(request);
        System.assertNotEquals(null, response);
                                                        
        Test.StopTest();
    }
    
     /**
    * @name: testProcessRequestWithNoSubscription 
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRequest method with no Subscription.
    * @date: 08/10/2015
    */
    static testMethod void testProcessRequestWithNoSubscription(){
        prepareTestData('Invoice', null, '1');
        
        List<Account> accountList = [SELECT Id, Account_Auto_Number__c FROM Account
                                    WHERE Id = :acc.id];  
        
        requestTemp = new RenewSubscriptionServiceRequest();
        requestTemp.subscriptionId = zSubs[0].Id;
        requestTemp.subscriberId = accountList[0].Account_Auto_Number__c;
        
        request = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(requestTemp);
        request = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
        
        Test.StartTest();
        response = RenewSubscriptionService.processRequest(request);
        System.assertNotEquals(null, response);
        Test.StopTest();
    }
    
    /**
    * @name: testProcessRequestWithNoAccount
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRequest method with no Account Record.
    * @date: 08/10/2015
    */
    static testMethod void testProcessRequestWithNoAccount(){
        prepareTestData('Invoice', null, '1');
        
        requestTemp = new RenewSubscriptionServiceRequest();
        requestTemp.subscriptionId = zSubs[0].Id;
        requestTemp.subscriberId = con[0].Id;
        
        request = new RenewSubscriptionService.RenewSubscriptionServiceRequest();
        String jsonStr = JSON.serialize(requestTemp);
        request = (RenewSubscriptionService.RenewSubscriptionServiceRequest)JSON.deserialize(jsonStr, RenewSubscriptionService.RenewSubscriptionServiceRequest.class);
        
        Test.StartTest();
        response = RenewSubscriptionService.processRequest(request);
        System.assertNotEquals(null, response);
        Test.StopTest();
    }
    
    /**
    * @name: defaultCustomSetting
    * @author : Recuerdo Bregente
    * @description : Prepares custom settings.
    * @date: 08/10/2015
    */
    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        /*
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        */
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;
        
        Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            insert cirPlannerSchedule;
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c();
        delType.Name = 'A';
        delType.Default_Delivery_Charge_Type__c = 'C';
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c();
        delCharge.Name ='AC';
        delCharge.Vendor_Credit__c = 9.00;
        delCharge.Subscriber_Charge__c = 9.00;
        insert delCharge;
    }
}