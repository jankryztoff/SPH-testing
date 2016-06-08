/**
  * Class Name: OrderLineItemVendorTriggerHandlerTest
  * @author: Recuerdo Bregente
  * Date: 08/06/2015
  * Requirement/Project Name: SPH Project
  * @description Test Class for OrderLineItemVendorTriggerHandler
  */
@isTest(seeAllData=false)
private class OrderLineItemVendorTriggerHandlerTest{

    // Test Data
    static Account acc;
    static Account accVendor;
    static Order__c order;
    static Publication__c pub;
    static Order_Line_Item_Vendor__c orderLineItem;
    static List<Subscription_Vendor__c> svs;
    
    
     /**
    * @name : prepareTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 08/06/2015
    */ 
    static void prepareTestData(String pubDays){
        defaultCustomSetting();
        
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        System.assertNotEquals(null, acc);
        
        accVendor = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert accVendor;
        System.assertNotEquals(null, accVendor);
        
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        insert order;
        System.assertNotEquals(null, order);
        
        pub = TestDataFactory.createPublication(1)[0];
        pub.Published_Days__c = pubDays;
        pub.Vendor_Sub_Delivery_Method__c = 'Mailing Agent';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';
        insert pub;
        System.assertNotEquals(null, pub);
        
        orderLineItem = TestDataFactory.createOrderLineItemVendor(1)[0];
        orderLineItem.Order__c = order.id;
        orderLineItem.Publication__c = pub.id;
        orderLineItem.Earliest_Start_Date__c = Date.today().addDays(1);
        orderLineItem.Start_Date__c = Date.today().addDays(3); //EGC 4/9/2016 Added
        orderLineItem.Vendor__c = acc.id;
        orderLineItem.Sun__c = 1;
        insert orderLineItem;
        
        svs = TestDataFactory.createSubscriptionVendor(1);
        for(Subscription_Vendor__c sv:svs) {
            sv.Account__c = acc.Id;
            sv.Status__c = 'Active';
            sv.Order_Number__c = order.id;
        }
        
        insert svs;
        
        Case cas = new Case();
        cas.Order__c = order.Id;
        insert cas;
    }
    
    /**
    * @name: testUpdatePassed
    * @author : Recuerdo Bregente
    * @description : Handles the testing for the update logic with error.
    * @date: 08/06/2015
    */
    static testmethod void testUpdatePassed(){
        prepareTestData('YYYYYYY');
        Test.startTest();
        System.assertNotEquals(null, orderLineItem);
        Boolean errorExist = false;
        try{
            orderLineItem.Vendor__c = accVendor.Id;
            update orderLineItem;
        } catch(System.DmlException e) {
            errorExist = true;
        }
        System.assertEquals(false, errorExist);
        Test.stopTest();
    }
    
    /**
    * @name: testUpdatePassedWithAnotherOLIVendor
    * @author : Recuerdo Bregente
    * @description : Handles the testing for the update logic with error.
    * @date: 08/06/2015
    */
    static testmethod void testUpdatePassedWithAnotherOLIVendor(){
        prepareTestData('YYYYYYY');
        Test.startTest();
        System.assertNotEquals(null, orderLineItem);
        Boolean errorExist = false;
        
        Order_Line_Item_Vendor__c newOrderLineItem = TestDataFactory.createOrderLineItemVendor(1)[0];
        newOrderLineItem.Order__c = order.id;
        newOrderLineItem.Publication__c = pub.id;
        newOrderLineItem.Earliest_Start_Date__c = Date.today().addDays(1);
        newOrderLineItem.Start_Date__c = Date.today().addDays(3); //EGC 4/9/2016 Added
        newOrderLineItem.Vendor__c = acc.id;
        newOrderLineItem.Sun__c = 1;
        insert newOrderLineItem;
        
        try{
            orderLineItem.Vendor__c = accVendor.Id;
            update orderLineItem;
        } catch(System.DmlException e) {
            errorExist = true;
        }
        System.assertEquals(false, errorExist);
        Test.stopTest();
    }
    
    /**
    * @name: testUpdatePassedWithNoVendor
    * @author : Recuerdo Bregente
    * @description : Handles the testing for the update logic with error.
    * @date: 08/06/2015
    */
    static testmethod void testUpdatePassedWithNoVendor(){
        prepareTestData('YYYYYYY');
        Test.startTest();
        System.assertNotEquals(null, orderLineItem);
        Boolean errorExist = false;
        try{
            orderLineItem.Vendor__c = null;
            update orderLineItem;
        } catch(System.DmlException e) {
            errorExist = true;
        }
        System.assertEquals(false, errorExist);
        Test.stopTest();
    }
    
    /**
    * @name: testUpdateFailed
    * @author : Recuerdo Bregente
    * @description : Handles the testing for the update logic with error.
    * @date: 08/06/2015
    */
    static testmethod void testUpdateFailed(){
        prepareTestData('NNNNNNY');
        Test.startTest();
        System.assertNotEquals(null, orderLineItem);
        Boolean errorExist = false;
        try{
            orderLineItem.Vendor__c = accVendor.Id;
            update orderLineItem;
        } catch(System.DmlException e) {
            errorExist = true;
        }
        System.assertEquals(true, errorExist);
        Test.stopTest();
    }
    
    /**
    * @name: testUpdateFailedWithTwoEditable
    * @author : Recuerdo Bregente
    * @description : Handles the testing for the update logic with error.
    * @date: 08/06/2015
    */
    static testmethod void testUpdateFailedWithTwoEditable(){
        prepareTestData('NNNNYYN');
        Test.startTest();
        System.assertNotEquals(null, orderLineItem);
        Boolean errorExist = false;
        Order_Line_Item_Vendor__c oliv = [SELECT Sun__c FROM Order_Line_Item_Vendor__c WHERE Id =: orderLineItem.Id];
        try{
            orderLineItem.Vendor__c = accVendor.Id;
            if(oliv.Sun__c == 1){
                orderLineItem.Sun__c = 0;
            } else {
                orderLineItem.Sun__c = 1;
            }
            update orderLineItem;
        } catch(System.DmlException e) {
            errorExist = true;
        }
        System.assertEquals(true, errorExist);
        Test.stopTest();
    }
    
    static testmethod void testDelete(){
        prepareTestData('NNNNNNY');
        Test.startTest();
        System.assertNotEquals(null, orderLineItem);
        
        delete orderLineItem;
        
        Test.stopTest();
    }
    
    /**
    * @name: defaultCustomSetting
    * @author : Recuerdo Bregente
    * @description : Prepares custom settings.
    * @date: 08/06/2015
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
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
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
        
        Delivery_Charge_Type__c testDeliveryChargeType = new Delivery_Charge_Type__c();
            testDeliveryChargeType.Name = 'T';
            testDeliveryChargeType.Default_Delivery_Charge_Type__c = 'T';
        insert testDeliveryChargeType; 
        
        Postage_Charge__c testPostageCharge = new Postage_Charge__c();
            testPostageCharge.Name = 'null';
            testPostageCharge.Amount__c = 10;
        insert testPostageCharge;
       
    }

}