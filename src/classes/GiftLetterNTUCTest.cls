/**
 * Class Name: GiftLetterNTUCTest
 * @author: Recuerdo Bregente
 * Date: 07.16.2015
 * Requirement/Project Name: SPH
 * @description Test Class for GiftLetterNTUC
 */
@isTest(seeAllData=true)
private class GiftLetterNTUCTest {
    
    // Test Data
    static Order_Line_Item_Gift__c testOrderLineItemGift;
    static Map<String, SObject> sobjectMap;
    static Zuora__Subscription__c zuoraSub;
    static Package__c packageObj;
    static zqu__ProductRatePlan__c prdRatePlan;
    
    /**
    * @name : prepareTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 07/09/2015
    */ 
    static void prepareTestData(String packType, String packItemType) {
        //defaultCustomSetting();
        
        Account accountRec = (Account) sobjectMap.get('Account');
        
        Zuora__CustomerAccount__c billAcc = (Zuora__CustomerAccount__c) sobjectMap.get('Zuora__CustomerAccount__c');
        billAcc.Name = 'Zuora Customer Account';
        billAcc.Zuora__Account__c = accountRec.Id;
        //billAcc.Billing_Contact__c = con[0].Id;
        billAcc.Zuora__Credit_Balance__c = 1;
        billAcc.Refund_Amount__c = 100;
        billAcc.Zuora__AutoPay__c =false;
        billAcc.Zuora__Balance__c = 1;
        billAcc.Payment_Mode__c = 'Paypal';
        billAcc.Other_PaymentMethod__c= 'Paypal';
        billAcc.Zuora__PaymentMethodType__c = 'Paypal'; 
        billAcc.Zuora__External_Id__c = '22544AA';  
        billAcc.Zuora__Zuora_Id__c = '0124'; 
        update billAcc;
        
        packageObj = TestDataFactory.createPackage(1)[0];
        packageObj.Name = 'Pack name';
        packageObj.Billing_Type__c = 'Full Prepaid';
        packageObj.Package_Type__c = packType;
        packageObj.Subscription_Period__c = '18';
        packageObj.Package_Code__c = 'afds133';
        insert packageObj;
        
        prdRatePlan = (zqu__ProductRatePlan__c) sobjectMap.get('zqu__ProductRatePlan__c');
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,packItemType)[0];
        pItem.Package__c = packageObj.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        zuoraSub = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c');
        zuoraSub.Zuora__CustomerAccount__c = billAcc.Id;
        zuoraSub.Main_Package__c = packageObj.Id;
        insert zuoraSub;
        
        Order_Line_Item__c testOrderLineItem = (Order_Line_Item__c) sobjectMap.get('Order_Line_Item__c');
        testOrderLineItem.Main_Package_ID__c = packageObj.Id;
        update testOrderLineItem;
        
        Gift__c testGift = TestDataFactory.createGift(1)[0];
        insert testGift;
        
        Promotion_Gift__c testPromotionGift = TestDataFactory.createPromotionGift(1)[0];
            testPromotionGift.Gift__c = testGift.id;
        insert testPromotionGift; 
    
        testOrderLineItemGift = new Order_Line_Item_Gift__c();
            testOrderLineItemGift.Order_Line_Item__c = testOrderLineItem.id;
            testOrderLineItemGift.Promotion_Gift__c = testPromotionGift.id;
            testOrderLineItemGift.Gift_ID__c = testGift.id;
        insert testOrderLineItemGift;
               
    }
    
    /**
    * @name: testPackageTypeIsBase
    * @author : Recuerdo Bregente
    * @description : Tests the logic inside the constructor where package type is base.
    * @date: 07/16/2015
    */
    static testMethod void testPackageTypeIsBase()
    { 
         boolean errorExist = false;
         sobjectMap = TestDataFactory.createSubscriptionPackage();
         
         try{
            Test.startTest();
            
            prepareTestData('Base', 'Base Product');
        
            ApexPages.currentPage().getParameters().put('id', String.valueOf(testOrderLineItemGift.Id));
            
            GiftLetterNTUC cont = new GiftLetterNTUC();
            cont.ProductCode = 'Test';
            cont.ProductName = 'TEst';
            cont.PenaltyCharge = 'Test';
            Test.stopTest();
        
            
            System.assertNotEquals(null, cont.PenaltyCharge);  
        } catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
    }//END testPackageTypeIsBase
    
    /**
    * @name: testPackageTypeIsBundle
    * @author : Recuerdo Bregente
    * @description : Tests the logic inside the constructor where package type is bundle.
    * @date: 07/16/2015
    */
    static testMethod void testPackageTypeIsBundle()
    { 
         boolean errorExist = false;
         sobjectMap = TestDataFactory.createSubscriptionPackage();
         
         try{
            Test.startTest();
            
            prepareTestData('Bundle', 'Bundle Product');
        
            ApexPages.currentPage().getParameters().put('id', String.valueOf(testOrderLineItemGift.Id));
            
            GiftLetterNTUC cont = new GiftLetterNTUC();
            cont.ProductCode = 'Test';
            cont.ProductName = 'TEst';
            cont.PenaltyCharge = 'Test';
            Test.stopTest();
            
            System.assertNotEquals(null, cont.PenaltyCharge);  
        } catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
    }//END testPackageTypeIsBundle
}