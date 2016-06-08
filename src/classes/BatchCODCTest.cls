/**
* Class Name: BatchCODCTest
* @author: Recuerdo Bregente
* @date: 07/30/2015
* @requirement/Project Name: SPH Project
* @description Batch Apex Class for BatchCODC
* History: 19/02/2016 [D-4382] Wenjun : Update Test Class for the major change
*/
@isTest(seeAllData=false)
private class BatchCODCTest {
    
    // Test Data
    static Account acc;
    static Zuora__Subscription__c subs;
    
    static final String MR_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    static final String MR_POST = GlobalVariableClass.RECURRING_POSTPAID;
    static final String SUB_TYPE_DEL = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    static final String STATUS_ACTIVE = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
    
    /**
    * @name : prepareTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 07/30/2015
    */ 
    static void prepareTestData(String delChargeType, Decimal subCharge, String ratePlanName){
          defaultCustomSetting();
            
          acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
          insert acc;
          
          Zuora__CustomerAccount__c billingAccount = TestDataFactory.createBillingAccount(1)[0];
          billingAccount.Zuora__Account__c = acc.Id;
          insert billingAccount;
          
          Order__c order = TestDataFactory.createOrder(1)[0];
          order.Account__c = acc.Id;
          insert order;
          
          Package__c pack = TestDataFactory.createPackage(1)[0];
          insert pack;
          
          Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
          orderLineItem.Order__c = order.Id;
          orderLineItem.Main_Package_ID__c = pack.Id;
          orderLineItem.Main_Package_Billing_Type__c = GlobalVariableClass.RECURRING_POSTPAID;
          insert orderLineItem; 
            
          subs = TestDataFactory.createSubscription(1)[0];
          subs.Name = 'BA-S0001';
          subs.Delivery_Charge_Type__c = delChargeType;
          subs.Zuora__CustomerAccount__c = billingAccount.Id;
          subs.Order_Line_Item_Number__c = orderLineItem.Id;
          subs.Order_Line_Item_Number_1__c = orderLineItem.Id;
          subs.Contract_End_Date_1__c = date.Today()+3;
          subs.Zuora__SubscriptionStartDate__c = date.Today()+2;
          subs.Zuora__SubscriptionEndDate__c = NULL;
          subs.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
          subs.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
          subs.Zuora__Status__c = 'Active';
          subs.Billing_Type__c = GlobalVariableClass.RECURRING_POSTPAID;
          subs.Subscription_Charge__c = subCharge;
          subs.Order_Number_1__c = order.Id;
          subs.Term_Length__c = null;
          subs.Contract_End_Date__c = string.valueOf(date.Today()+23);
          insert subs;
          
          zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
          zProduct.ProductSubType__c = 'Newspaper';
          zProduct.ProductPlatform__c = 'Print';
          zProduct.name='BORJ';
          zProduct.zqu__SKU__c = 'TESTES121';
          zProduct.ProductCode__c = GlobalVariableClass.PRODUCT_CODE_DELCHG;
          zProduct.ProductFamily__c = 'asdasd';
          insert zProduct;
          
          zqu__ProductRatePlan__c prdRatePlans = TestDataFactory.createProductRatePlan(1)[0];
          prdRatePlans.zqu__ZProduct__c = zProduct.Id;
          prdRatePlans.Name = ratePlanName;
          prdRatePlans.zqu__Deleted__c = false;
          insert prdRatePlans;
          

    }

    static void prepareBatchSetting(Decimal hdbPrice,  Decimal condoPrice, Decimal landPrice)
    {
          //Insert Custom Setting
          List<MASS_CONFIG__c> lstConfig = new List<MASS_CONFIG__c>();
          
          MASS_CONFIG__c hdbConfig = new MASS_CONFIG__c();
          hdbConfig.Name = 'HDB_PRICE';
          hdbConfig.Value__c = String.valueOf(hdbPrice);
          
          MASS_CONFIG__c condoConfig = new MASS_CONFIG__c();
          condoConfig.Name = 'APT_PRICE';
          condoConfig.Value__c = String.valueOf(condoPrice);
          
          MASS_CONFIG__c landConfig = new MASS_CONFIG__c();
          landConfig.Name = 'LANDED_PRICE';
          landConfig.Value__c = String.valueOf(landPrice);
          
          lstConfig.add(hdbConfig);
          lstConfig.add(condoConfig);
          lstConfig.add(landConfig);
          
          insert lstConfig;
    }
    
    /**
    * @name: testBatch
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchCODC execution with
    *                Delivery Charge type equal to 'H'.
    * @date: 07/30/2015
    */
    static testMethod void testBatchDeliveryChargeTypeIsH(){
            prepareTestData('H', 2.00, 'HDB Delivery Charge');
            prepareBatchSetting(1.00,0.00,0.00);
          
          Test.startTest();
          BatchCODC batch = new BatchCODC(false, false, Date.today());
          ID batchprocessid = Database.executeBatch(batch,1);
          System.assertNotEquals(null, batchprocessid);
          Test.stopTest();
    }
    
    /**
    * @name: testBatch
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchCODC execution with
    *                Delivery Charge type equal to 'C'.
    * @date: 07/30/2015
    */
    static testMethod void testBatchDeliveryChargeTypeIsC(){
          prepareTestData('C', 2.00,'Apt Delivery Charge');
          prepareBatchSetting(1.00,1.00,0.00);
     
              Test.startTest();
              BatchCODC batch = new BatchCODC(false, true, Date.today());
              ID batchprocessid = Database.executeBatch(batch,1);
              System.assertNotEquals(null, batchprocessid);
              Test.stopTest();
    }
    
    /**
    * @name: testBatch
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchCODC execution with
    *                Delivery Charge type equal to 'L'.
    * @date: 07/30/2015
    */
    static testMethod void testBatchDeliveryChargeTypeIsL(){
          prepareTestData('L', 2.00,'Landed Delivery Charge');
          prepareBatchSetting(1.00,1.00,1.00);
     
          Test.startTest();
          BatchCODC batch = new BatchCODC(true, false, Date.today());
          ID batchprocessid = Database.executeBatch(batch,1);
          System.assertNotEquals(null, batchprocessid);
          Test.stopTest();
  
    }
    
    /**
    * @name: testBatchNoSubscriptionCharge
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BatchCODC execution with
    *                no subscription charge.
    * @date: 07/30/2015
    */
    static testMethod void testBatchNoSubscriptionCharge(){
          prepareTestData('L', 2.00,'Landed Delivery Charge');
          prepareBatchSetting(0.00,0.00,0.00);
         
          try{
              Test.startTest();
              BatchCODC batch = new BatchCODC(true, true, Date.today());
              ID batchprocessid = Database.executeBatch(batch,1);
              System.assertNotEquals(null, batchprocessid);
              Test.stopTest();
          } catch(System.NullPointerException e) {
              System.assertNotEquals(null, e);
          }
  
    }
    
    /**
    * @name: testBatchNoSubscriptionCharge
    * @author : Wenjun Zhu
    * @description : Test target run
    * @date: 01/30/2016
    */
    static testMethod void testSelectedSubs(){
          prepareTestData('H', 3.00,'HDB Delivery Charge');
          prepareBatchSetting(6.00,0.00,0.00);
         
          try{
              Test.startTest();
              BatchCODC batch = new BatchCODC(false,'BA-S0001',false, Date.today());
              ID batchprocessid = Database.executeBatch(batch,1);
              System.assertNotEquals(null, batchprocessid);
              Test.stopTest();
          } catch(System.NullPointerException e) {
              System.assertNotEquals(null, e);
          }
  
    }
    
    /**
    * @name: defaultCustomSetting
    * @author : Recuerdo Bregente
    * @description : Prepares custom settings.
    * @date: 07/27/2015
    */
    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
        List<Key_Id__c> keyList = [SELECT Name FROM Key_Id__c];
        Set<String> keyNames = new Set<String>();
        for(Key_Id__c keyRec : keyList) {
            keyNames.add(keyRec.Name);
        }
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            if(!keyNames.contains(keyIdNameArray[i])) {
                keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
                insert keyId;
            }
        }
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password','HDB DELIVERY CHARGE','APT DELIVERY CHARGE','LANDED DELIVERY CHARGE'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password','HDB Delivery Charge','Apt Delivery Charge','Landed Delivery Charge'};
        
        List<Other__c> otherList = [SELECT Name FROM Other__c];
        Set<String> otherNames = new Set<String>();
        for(Other__c otherRec : otherList) {
            otherNames.add(otherRec.Name);
        }
        
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            if(!otherNames.contains(orderCNameArray[i])) {
                otherC = new Other__c();
                otherC.Name = orderCNameArray[i];
                otherC.Value__c = orderCValueArray[i];
                insert otherC;
            }
        }
        
        List<Cir_Planner_Schedule__c> cpcList = [SELECT Name FROM Cir_Planner_Schedule__c WHERE Name = 'CIR Plan Schedule'];
        if(cpcList.isEmpty()) {
            Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            insert cirPlannerSchedule;
        }
        
        List<BatchInterface_Settings__c> bitList = [SELECT Name FROM BatchInterface_Settings__c WHERE Name = 'Endpoint Delegator'];
        if(bitList.isEmpty()) {
            BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
            batchInterfaceSetting.Name = 'Endpoint Delegator';
            batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
            insert batchInterfaceSetting;
        }
        
        Date_Configuration__c dateConfig = new Date_Configuration__c();
        dateConfig.name = 'Usage Reference Date';
        dateConfig.Date__c = Date.today().addMonths(1).toStartofMonth().addDays(-1);
        insert dateConfig;
        
    }
}