/**
* Class Name: GiftLetterNTUC_Test
* Accenture IDC - Rashmi, Nilesh
* Date: 1/13/2015
* @Description: This class is used to code coverage of the GiftLetterNTUC class.
* History: 
*
*/
@isTest 
public class GiftLetterNTUC_Test
{
  /*  static testMethod void GiftLetterNTUCTest()
    { 
    
        defaultCustomSetting();
        Map<String, SObject> sobjectMap = TestDataFactory.createSubscriptionPackage();
        
        Order_Line_Item__c testOrderLineItem = (Order_Line_Item__c) sobjectMap.get('Order_Line_Item__c');
        
        Gift__c testGift = TestDataFactory.createGift(1)[0];
        insert testGift;
        
        Package__c testPackage = TestDataFactory.createPackage(1)[0];
        insert testPackage;
        
        Promotion_Gift__c testPromotionGift = TestDataFactory.createPromotionGift(1)[0];
            testPromotionGift.Gift__c = testGift.id;
        insert testPromotionGift;
    
     
    
        Order_Line_Item_Gift__c testOrderLineItemGift = new Order_Line_Item_Gift__c();
            testOrderLineItemGift.Order_Line_Item__c = testOrderLineItem.id;
            testOrderLineItemGift.Promotion_Gift__c = testPromotionGift.id;
            testOrderLineItemGift.Gift_ID__c = testGift.id;
        insert testOrderLineItemGift;
        
        Attachment att = new Attachment();
        att.ParentId = postal.Id;
        database.insert(att);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(testOrderLineItemGift.Id));
        
        Test.startTest();
            GiftLetterNTUC cont = new GiftLetterNTUC();
            cont.ProductCode = 'Test';
            cont.ProductName = 'TEst';
            cont.PenaltyCharge = 'Test';
        Test.stopTest();
        
      
    }//END GiftLetterNTUCTest */
    
    static testMethod void GiftLetterNTUCTestOverseas()
    { 
    
        defaultCustomSetting();
        //Map<String, SObject> sobjectMap = TestDataFactory.createSubscriptionPackage();
        
        //Order_Line_Item__c testOrderLineItem = (Order_Line_Item__c) sobjectMap.get('Order_Line_Item__c');
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = postal.Id;
        add.RecordTypeId = [SELECT Id, developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Overseas'].Id;
        insert add;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        con.Recipient_Number__c = 2;
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.2';
        insert subRecs;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Recipient_Contact__c = con.Id;
        insert order;
        
        Package__c testPackage = TestDataFactory.createPackage(1)[0];
        insert testPackage;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = testPackage.id; 
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        insert pItem;
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.Main_Package_ID__c = testPackage.Id;
        insert orderline;
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.2';
        sub.Order_Line_Item_Number__c = orderline.Id;
        sub.Main_Package__c = testPackage.Id;
        sub.Recipient_Contact__c = con.Id;
        insert sub;
        
        Gift__c testGift = TestDataFactory.createGift(1)[0];
        insert testGift;
        
        Promotion_Gift__c testPromotionGift = TestDataFactory.createPromotionGift(1)[0];
            testPromotionGift.Gift__c = testGift.id;
        insert testPromotionGift;
    
        Order_Line_Item_Gift__c testOrderLineItemGift = new Order_Line_Item_Gift__c();
            testOrderLineItemGift.Order_Line_Item__c = orderline.id;
            testOrderLineItemGift.Promotion_Gift__c = testPromotionGift.id;
            testOrderLineItemGift.Gift_ID__c = testGift.id;
        insert testOrderLineItemGift;
        
        Attachment att = new Attachment();
        att.ParentId = postal.Id;
        att.Name = 'Name';
        att.Body = blob.valueOf('body');
        database.insert(att);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(testOrderLineItemGift.Id));
        
        Test.startTest();
            GiftLetterNTUC cont = new GiftLetterNTUC();
            cont.ProductCode = 'Test';
            cont.ProductName = 'TEst';
            cont.PenaltyCharge = 'Test';
        Test.stopTest();
        
      
    }//END GiftLetterNTUCTest
    
    static testMethod void GiftLetterNTUCTestAirline()
    { 
    
        defaultCustomSetting();
        //Map<String, SObject> sobjectMap = TestDataFactory.createSubscriptionPackage();
        
        //Order_Line_Item__c testOrderLineItem = (Order_Line_Item__c) sobjectMap.get('Order_Line_Item__c');
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Airline_Indicator__c = true;
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = postal.Id;
        add.RecordTypeId = [SELECT Id, developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Airline'].Id;
        insert add;
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = add.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        con.Recipient_Number__c = 2;
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.2';
        insert subRecs;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Recipient_Contact__c = con.Id;
        insert order;
        
        Package__c testPackage = TestDataFactory.createPackage(1)[0];
        testPackage.Package_Type__c = 'Bundle';
        insert testPackage;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Bundle Product')[0];
        pItem.Package__c = testPackage.id; 
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        insert pItem;
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Penalty_Charge_Override__c = 33;
        prom.Contract_Period__c = '30';
        insert(prom);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.Main_Package_ID__c = testPackage.Id;
        orderline.Promotion_ID__c = prom.Id;
        insert orderline;
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.2';
        sub.Order_Line_Item_Number__c = orderline.Id;
        sub.Main_Package__c = testPackage.Id;
        sub.Recipient_Contact__c = con.Id;
        insert sub;
        
        Gift__c testGift = TestDataFactory.createGift(1)[0];
        insert testGift;
        
        Promotion_Gift__c testPromotionGift = TestDataFactory.createPromotionGift(1)[0];
            testPromotionGift.Gift__c = testGift.id;
        insert testPromotionGift;
    
        Order_Line_Item_Gift__c testOrderLineItemGift = new Order_Line_Item_Gift__c();
            testOrderLineItemGift.Order_Line_Item__c = orderline.id;
            testOrderLineItemGift.Promotion_Gift__c = testPromotionGift.id;
            testOrderLineItemGift.Gift_ID__c = testGift.id;
        insert testOrderLineItemGift;
        
        Attachment att = new Attachment();
        att.ParentId = postal.Id;
        att.Name = 'Name';
        att.Body = blob.valueOf('body');
        database.insert(att);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(testOrderLineItemGift.Id));
        
        Test.startTest();
            GiftLetterNTUC cont = new GiftLetterNTUC();
            cont.ProductCode = 'Test';
            cont.ProductName = 'TEst';
            cont.PenaltyCharge = 'Test';
        Test.stopTest();
        
      
    }//END GiftLetterNTUCTest
    
    static testMethod void GiftLetterNTUCTestLocal()
    { 
    
        defaultCustomSetting();
        //Map<String, SObject> sobjectMap = TestDataFactory.createSubscriptionPackage();
        
        //Order_Line_Item__c testOrderLineItem = (Order_Line_Item__c) sobjectMap.get('Order_Line_Item__c');
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Airline_Indicator__c = true;
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = postal.Id;
        add.RecordTypeId = [SELECT Id, developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Local'].Id;
        insert add;
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = add.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        con.Recipient_Number__c = 2;
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.2';
        insert subRecs;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Recipient_Contact__c = con.Id;
        insert order;
        
        Package__c testPackage = TestDataFactory.createPackage(1)[0];
        testPackage.Package_Type__c = 'Bundle';
        insert testPackage;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Bundle Product')[0];
        pItem.Package__c = testPackage.id; 
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        insert pItem;
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Penalty_Charge_Override__c = 33;
        prom.Contract_Period__c = '30';
        insert(prom);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.Main_Package_ID__c = testPackage.Id;
        orderline.Promotion_ID__c = prom.Id;
        insert orderline;
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.2';
        sub.Order_Line_Item_Number__c = orderline.Id;
        sub.Main_Package__c = testPackage.Id;
        sub.Recipient_Contact__c = con.Id;
        insert sub;
        
        Gift__c testGift = TestDataFactory.createGift(1)[0];
        insert testGift;
        
        Promotion_Gift__c testPromotionGift = TestDataFactory.createPromotionGift(1)[0];
            testPromotionGift.Gift__c = testGift.id;
        insert testPromotionGift;
    
        Order_Line_Item_Gift__c testOrderLineItemGift = new Order_Line_Item_Gift__c();
            testOrderLineItemGift.Order_Line_Item__c = orderline.id;
            testOrderLineItemGift.Promotion_Gift__c = testPromotionGift.id;
            testOrderLineItemGift.Gift_ID__c = testGift.id;
        insert testOrderLineItemGift;
        
        Attachment att = new Attachment();
        att.ParentId = postal.Id;
        att.Name = 'Name';
        att.Body = blob.valueOf('body');
        database.insert(att);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(testOrderLineItemGift.Id));
        
        Test.startTest();
            GiftLetterNTUC cont = new GiftLetterNTUC();
            cont.ProductCode = 'Test';
            cont.ProductName = 'TEst';
            cont.PenaltyCharge = 'Test';
        Test.stopTest();
        
      
    }//END GiftLetterNTUCTest
    
    static testMethod void GiftLetterNTUCTestInternal()
    { 
    
        defaultCustomSetting();
        //Map<String, SObject> sobjectMap = TestDataFactory.createSubscriptionPackage();
        
        //Order_Line_Item__c testOrderLineItem = (Order_Line_Item__c) sobjectMap.get('Order_Line_Item__c');
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Airline_Indicator__c = true;
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = postal.Id;
        add.RecordTypeId = [SELECT Id, developerName FROM RecordType WHERE SObjectType='Address__c' AND developerName='Internal'].Id;
        insert add;
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = add.Id;
        con.AccountId = acc.Id;
        con.Recipient_Indicator__c = true;
        con.Recipient_Number__c = 2;
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__SubscriptionStartDate__c = date.today();
        subRecs.Term_Length1__c = '1.2';
        insert subRecs;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Recipient_Contact__c = con.Id;
        insert order;
        
        Package__c testPackage = TestDataFactory.createPackage(1)[0];
        testPackage.Package_Type__c = 'Bundle';
        insert testPackage;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
         
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        database.insert(prdRatePlan);
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Bundle Product')[0];
        pItem.Package__c = testPackage.id; 
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        insert pItem;
        
        Promotion__c prom = TestDataFactory.createPromotion(1)[0];
        prom.Penalty_Charge_Override__c = 33;
        prom.Contract_Period__c = '30';
        insert(prom);
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.Start_Date__c = ([SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:subRecs.Id].Zuora__SubscriptionEndDate__c)+1;
        orderline.Main_Package_ID__c = testPackage.Id;
        orderline.Promotion_ID__c = prom.Id;
        insert orderline;
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '1.2';
        sub.Order_Line_Item_Number__c = orderline.Id;
        sub.Main_Package__c = testPackage.Id;
        sub.Recipient_Contact__c = con.Id;
        insert sub;
        
        Gift__c testGift = TestDataFactory.createGift(1)[0];
        insert testGift;
        
        Promotion_Gift__c testPromotionGift = TestDataFactory.createPromotionGift(1)[0];
            testPromotionGift.Gift__c = testGift.id;
        insert testPromotionGift;
    
        Order_Line_Item_Gift__c testOrderLineItemGift = new Order_Line_Item_Gift__c();
            testOrderLineItemGift.Order_Line_Item__c = orderline.id;
            testOrderLineItemGift.Promotion_Gift__c = testPromotionGift.id;
            testOrderLineItemGift.Gift_ID__c = testGift.id;
        insert testOrderLineItemGift;
        
        Attachment att = new Attachment();
        att.ParentId = postal.Id;
        att.Name = 'Name';
        att.Body = blob.valueOf('body');
        database.insert(att);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(testOrderLineItemGift.Id));
        
        Test.startTest();
            GiftLetterNTUC cont = new GiftLetterNTUC();
            cont.ProductCode = 'Test';
            cont.ProductName = 'TEst';
            cont.PenaltyCharge = 'Test';
        Test.stopTest();
        
      
    }//END GiftLetterNTUCTest
    
    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
                keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
            insert keyId;
        }
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print'};
        
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
                otherC = new Other__c();
                otherC.Name = orderCNameArray[i];
                otherC.Value__c = orderCValueArray[i];
            insert otherC;
        }
        
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
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Contact_Customer Contact';
        key.Id__c = '012N00000008rHbIAI';
        key.Type__c = 'RecordType';
        database.insert(key);
        
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
    }
}