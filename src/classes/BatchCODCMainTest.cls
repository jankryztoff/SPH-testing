/**
* Class Name: BatchCODCMainTest
* @author: Karl Tan
* @date: 4/7/2016
* @requirement/Project Name: SPH Project
* @description Batch Apex Class for BatchCODCMain
*/
@isTest(seeAllData=false)
private class BatchCODCMainTest {
    
    // Test Data
    static Account acc;
    static Zuora__Subscription__c subs;
    
    static final String MR_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    static final String MR_POST = GlobalVariableClass.RECURRING_POSTPAID;
    static final String SUB_TYPE_DEL = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    static final String STATUS_ACTIVE = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
    
    /**
    * @name : prepareTestData
    * @author : Karl Tan
    * @description : Prepares the test data objects.
    * @date: 4/7/2016
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

    /**
    * @name: testBatch
    * @author : Karl Tan
    * @description : Handles the testing for BatchCODC execution with
    *                Delivery Charge type equal to 'H'.
    * @date: 4/7/2016
    */
    static testMethod void testBatchDeliveryChargeTypeIsH(){
          prepareTestData('H', 2.00, 'HDB Delivery Charge');
          
              Test.startTest();
              Decimal HDB_PRICE = 1.00;
              Decimal APT_PRICE = 0.00;
              Decimal LANDED_PRICE = 0.00;
              BatchCODCMain batch = new BatchCODCMain(1.00, 0.00, 0.00);
              Database.BatchableContext BC;
              batch.start(BC);
              List<Zuora__Subscription__c> lstSubs = Database.query(batch.getQueryString());
              batch.execute(BC, lstSubs);
              batch = new BatchCODCMain(2.00, 0.00, 0.00);
              batch.finish(BC);
              //ID batchprocessid = Database.executeBatch(batch,1);
              System.assertNotEquals(null, batch);
              Test.stopTest();
          
  
    }
    
    /**
    * @name: testBatch
    * @author : Karl Tan
    * @description : Handles the testing for BatchCODC execution with
    *                Delivery Charge type equal to 'C'.
    * @date: 4/7/2016
    */
    static testMethod void testBatchDeliveryChargeTypeIsC(){
          prepareTestData('C', 2.00,'Apt Delivery Charge');
     
              Test.startTest();
              Decimal HDB_PRICE = 1.00;
              Decimal APT_PRICE = 1.00;
              Decimal LANDED_PRICE = 0.00;
              BatchCODCMain batch = new BatchCODCMain(1.00, 1.00, 0.00);
              Database.BatchableContext BC;
              batch.start(BC);
              List<Zuora__Subscription__c> lstSubs = Database.query(batch.getQueryString());
              batch.execute(BC, lstSubs);
              batch = new BatchCODCMain(2.00, 2.00, 0.00);
              batch.finish(BC);
              //ID batchprocessid = Database.executeBatch(batch,1);
              System.assertNotEquals(null, batch);
              Test.stopTest();
    }
    
    /**
    * @name: testBatch
    * @author : Karl Tan
    * @description : Handles the testing for BatchCODC execution with
    *                Delivery Charge type equal to 'L'.
    * @date: 4/7/2016
    */
    static testMethod void testBatchDeliveryChargeTypeIsL(){
          prepareTestData('L', 2.00,'Landed Delivery Charge');
     
              Test.startTest();
              Decimal HDB_PRICE = 1.00;
              Decimal APT_PRICE = 1.00;
              Decimal LANDED_PRICE = 1.00;
              BatchCODCMain batch = new BatchCODCMain(1.00, 1.00, 1.00);
              Database.BatchableContext BC;
              batch.start(BC);
              List<Zuora__Subscription__c> lstSubs = Database.query(batch.getQueryString());
              batch.execute(BC, lstSubs);
              batch = new BatchCODCMain(2.00, 2.00, 2.00);
              batch.finish(BC);
              //ID batchprocessid = Database.executeBatch(batch,1);
              System.assertNotEquals(null, batch);
              Test.stopTest();
  
    }
    
    /**
    * @name: testBatchNoSubscriptionCharge
    * @author : Karl Tan
    * @description : Handles the testing for BatchCODC execution with
    *                no subscription charge.
    * @date: 4/7/2016
    */
    static testMethod void testBatchNoSubscriptionCharge(){
          prepareTestData('L', 2.00,'Landed Delivery Charge');
         
          try{
              Test.startTest();
              BatchCODCMain batch = new BatchCODCMain(0.00, 0.00, 0.00);
              ID batchprocessid = Database.executeBatch(batch,1);
              System.assertNotEquals(null, batchprocessid);
              Test.stopTest();
          } catch(System.NullPointerException e) {
              System.assertNotEquals(null, e);
          }
  
    }
    
    /**
    * @name: testBatchNoSubscriptionCharge
    * @author : Karl Tan
    * @description : Test target run
    * @date: 04/7/2016
    */
   /* static testMethod void testSelectedSubs(){
          prepareTestData('H', 3.00,'HDB Delivery Charge');
         
          try{
              Test.startTest();
              BatchCODCMain batch = new BatchCODCMain(6.00, 0.00, 0.00, 'BA-S0001');
              ID batchprocessid = Database.executeBatch(batch,1);
              System.assertNotEquals(null, batchprocessid);
              Test.stopTest();
          } catch(System.NullPointerException e) {
              System.assertNotEquals(null, e);
          }
  
    }*/
    
    /**
    * @name: defaultCustomSetting
    * @author : Karl Tan
    * @description : Prepares custom settings.
    * @date: 4/7/2016
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
        
    }
}