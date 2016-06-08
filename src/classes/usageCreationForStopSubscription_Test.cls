/**
 * Class Name: <usageCreationForStopSubscription_Test>
 * @author: <Joyrem Zarmaine D. Ayuman>
 * Date: <7/15/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for usageCreationForStopSubscription>
 */
 
 
@isTest(SeeAllData=false)
public class usageCreationForStopSubscription_Test
{

     // Test Data
     static Account acc;
     static Singpost_Address__c postal;
     static Address__c address;
     static List<Contact> con;
     static List<Package__c> pkg;
     static List<Zuora__CustomerAccount__c> zcaList;
     static List<Zuora__Subscription__c> zSubs;
     static List<Zuora__PaymentMethod__c> zpmList;
     static Order_Line_Item__c orderline;
     static Order__c orderRec;
     static Zuora__SubscriptionProductCharge__c zuoProdChargeDel;
     
     static Date dateToday;

     /**
    * @name : prepareTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 08/05/2015
    */ 
    static void prepareTestData(String productType, String billingType, String termLength){
            defaultCustomSetting();
            dateToday = Date.today();
            
            acc = new Account();
            acc.Name = 'Test Account';
            acc.RecordTypeId =  '012N00000008ic6'; 
            acc.Email__c = 'recuerdo.bregente@gmail.com';
            acc.Mobile__c = '09324861074';
            insert acc;
            
            postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = GlobalVariableClass.SINGAPORE_CODE;
            insert postal;
            
            Country__c countr = TestDataFactory.createCountry(1)[0];
            countr.Country_Name__c = 'Test Country';
            countr.Code__c = GlobalVariableClass.SINGAPORE_CODE;
            insert countr;
            
            address = new Address__c();
            address = TestDataFactory.createAddress(1)[0];
            address.Postal_Code__c = postal.Id;
            address.Country__c = countr.Id;
            address.Unit_Number__c = '11';
            address.Level_Number__c = '11';
            insert address;
            
            con = TestDataFactory.createContact(1);
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;
            con[0].Recipient_Indicator__c = true;
            con[0].Billing_Indicator__c = true;
            con[0].Address__c = address.Id;
            con[0].LastName = 'Veloso';
            con[0].FirstName = 'Ana';
            insert con;
                   
            pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15'; 
            pkg[0].Package_Code__c = 'PKGCD001';
            pkg[0].Billing_Type__c = 'Full Prepaid';
            insert pkg;
           
            
            zcaList = TestDataFactory.createBillingAccount(1);
            zcaList[0].Name = 'Billing test';
            zcaList[0].Zuora__Account__c = acc.Id;
            zcaList[0].Zuora__Credit_Balance__c = 1;
            zcaList[0].Refund_Amount__c = 100;
            zcaList[0].Zuora__AutoPay__c =false;
            zcaList[0].Zuora__Balance__c = 1;
            zcaList[0].Payment_Mode__c = 'Invoice';
            zcaList[0].Other_PaymentMethod__c= 'Invoice';
            //zcaList[0].Zuora__Default_Payment_Method__c = zpmList[0].id;
            zcaList[0].Zuora__PaymentMethodType__c = 'Invoice'; 
            zcalist[0].Zuora__External_Id__c = '22544AA';  
            zcalist[0].Zuora__Zuora_Id__c = 'ZZID001';    
            zcalist[0].Billing_Type__c = 'Full Prepaid';
            zcalist[0].Billing_Contact__c = con[0].Id; 
            insert zcaList;
            
            //START : D-1929 3/2/2015 added to create Default Payment Method
            zpmList = TestDataFactory.createPaymentMethod(1);
            zpmList[0].Name = 'Zuora Customer Account';
            zpmList[0].Zuora__Type__c = 'Invoice';
            zpmList[0].Zuora__BillingAccount__c = zcaList[0].id;
            insert zpmList;  
            //End: D-1929 3/2/2015 added to create Default Payment Method
            
            zcalist[0].Zuora__Default_Payment_Method__c = zpmList[0].id;         
            update zcaList;
            
            orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con[0].Id;
            orderRec.Subscriber_Charge__c = 15;
            insert orderRec;
                
            orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.Start_Date__c = Date.Today().addDays(1);
            orderline.End_Date__c = Date.Today().addDays(100);
            orderline.Main_Package_ID__c = pkg[0].id;
            orderline.Online_Order_Number__c = '100001-100001';
            orderline.Main_Package_Billing_Type__c = billingType;
            insert orderline;
            
            //create billing account      
            zSubs =  TestDataFactory.createSubscription(1);
            zSubs[0].Order_Line_Item_Number__c = orderline.Id;
            zSubs[0].Subscriber_Contact__c = con[0].id;
            zSubs[0].Main_Package__c = pkg[0].id;
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Zuora__CustomerAccount__c = zcaList[0].Id;
            zSubs[0].Recipient_Contact__c = con[0].id;
            zSubs[0].Zuora__Zuora_Id__c = 'ZZID001';
            zSubs[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
            zSubs[0].Zuora__SubscriptionStartDate__c = dateToday;
            zSubs[0].Term_Length1__c = termLength;
            zSubs[0].Qty1__c = '1';
            zSubs[0].Zuora__TermSettingType__c = GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED;
            zSubs[0].Order_Number__c = orderRec.Id;
            insert zSubs;
            
            Usage__c usage = new Usage__c();
            usage.UOM__c = 'day';
            usage.Account_Id__c = zcaList[0].Id;
            usage.Subscription_Id__c = zcaList[0].Id;
            usage.Start_Date__c =date.today();
            usage.Quantity__c = 12;
            usage.Status__c = 'New';
            usage.Rate_Plan_Charge_Id__c = '00001';
            usage.Publication_Code__c = 'BH';
            usage.StopType__c = 'Pstop';
            insert usage;
            
            
            zuoProdChargeDel = new Zuora__SubscriptionProductCharge__c();
            zuoProdChargeDel.Zuora__Price__c = 15;
            zuoProdChargeDel.Zuora__UOM__c='CREDIT';
            zuoProdChargeDel.Zuora__Subscription__c=zSubs[0].Id;
            zuoProdChargeDel.Zuora__ChargeNumber__c='Test';
            zuoProdChargeDel.PublicationCode__c='Test';
            zuoProdChargeDel.Zuora__ProductSKU__c = 'PUB123';
            zuoProdChargeDel.Zuora__RatePlanName__c = 'Test Rate Plan Name';
            zuoProdChargeDel.Zuora__Type__c = 'Usage';
            insert zuoProdChargeDel;
            
            Zuora__SubscriptionProductCharge__c spc = new Zuora__SubscriptionProductCharge__c();
            spc.Zuora__Price__c = 15;
            spc.Zuora__UOM__c='CREDIT';
            spc.Zuora__Subscription__c=zSubs[0].Id;
            spc.Zuora__ChargeNumber__c='Test';
            spc.PublicationCode__c='Test';
            spc.Zuora__ProductSKU__c = 'PUB123';
            spc.Zuora__RatePlanName__c = 'Test Rate Plan Name';
            spc.Zuora__Type__c = 'Usage';
            insert spc;
            
            zqu__ZProduct__c Zprod = TestDataFactory.createZProduct(1)[0];
            Zprod.zqu__SKU__c = zuoProdChargeDel.Zuora__ProductSKU__c;
            Zprod.ProductSubType__c = productType;
            Zprod.ProductPlatform__c = 'All-In-One';
            Zprod.ProductCode__c = 'NitinPrd';
            Zprod.zqu__ZuoraId__c='1234';
            insert Zprod;
            
            
            zqu__ProductRatePlan__c PRP = TestDataFactory.createProductRatePlan(1)[0];
            PRP.zqu__ZProduct__c = Zprod.Id;
            PRP.RatePlanType__c = 'Bill Plan';
            PRP.Name = zuoProdChargeDel.Zuora__RatePlanName__c;
            PRP.SubscriptionFrequency__c = '1';
            insert PRP;
            
            Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            pItem.Package__c = pkg[0].Id;
            pItem.Product_Rate_Plan__c = PRP.Id;
            pItem.Duration_in_months__c = '3';
            pItem.Effective_Start_Month__c = '3';
            insert pItem;
    }
    
     /**
    * @name: testCreateUsage
    * @author : Recuerdo Bregente
    * @description : Handles the testing for createUsage method.
    * @date: 08/05/2015
    */
    static testMethod void testCreateUsage(){
        prepareTestData('Magazine', GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID, '1');
        
        Test.startTest();
        zSubs[0].Zuora__SubscriptionEndDate__c = dateToday.addMonths(1);
        update zSubs;                            
        
        Map<String, Date> zzIdMap = new Map<String, Date>();
        zzIdMap.put(zSubs[0].Zuora__Zuora_Id__c, dateToday.addDays(-10));
        usageCreationForStopSubscription ucForStopSub = new usageCreationForStopSubscription();
        ucForStopSub.createUsage(zzIdMap);
        
        System.assertNotEquals(null, ucForStopSub);
        
        
        Test.stopTest();
    }
    
    /**
    * @name: testCreateUsageWithBillingTypeIsRecurringPrepaid
    * @author : Recuerdo Bregente
    * @description : Handles the testing for createUsage method.
    * @date: 08/05/2015
    */
    static testMethod void testCreateUsageWithBillingTypeIsFullPrepaid(){
        prepareTestData('Newspaper', GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID, '1');
        
        Test.startTest();  
        
        Map<String, Date> zzIdMap = new Map<String, Date>();
        zzIdMap.put(zSubs[0].Zuora__Zuora_Id__c, dateToday.toStartOfMonth());
        usageCreationForStopSubscription ucForStopSub = new usageCreationForStopSubscription();
        ucForStopSub.createUsage(zzIdMap);
        
        System.assertNotEquals(null, ucForStopSub);
        
        
        Test.stopTest();
    }
    
    /**
    * @name: testCreateUsageWithBillingTypeIsFullPrepaidAndDateIsEndOfMonth
    * @author : Recuerdo Bregente
    * @description : Handles the testing for createUsage method.
    * @date: 08/05/2015
    */
    static testMethod void testCreateUsageWithBillingTypeIsFullPrepaidAndDateIsEndOfMonth(){
        prepareTestData('Newspaper', GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID, '1');
        
        Test.startTest();
        zSubs[0].Zuora__SubscriptionStartDate__c = dateToday.addMonths(2).toStartOfMonth();
        
        update zSubs;
        
        Date stopDate = dateToday.addMonths(1).toStartOfMonth().addDays(-1);
        stopDate = usageCreationForStopSubscription.getLastDayOfTheMonth(stopDate);
        Map<String, Date> zzIdMap = new Map<String, Date>();
        zzIdMap.put(zSubs[0].Zuora__Zuora_Id__c, stopDate);
        usageCreationForStopSubscription ucForStopSub = new usageCreationForStopSubscription();
        ucForStopSub.createUsage(zzIdMap);
        
        System.assertNotEquals(null, ucForStopSub);
        
        Test.stopTest();
    }
    
    /**
    * @name: testCreateUsageWithBillingTypeIsFullPrepaidAndDateIsNotStartOfMonth
    * @author : Recuerdo Bregente
    * @description : Handles the testing for createUsage method.
    * @date: 08/05/2015
    */
    static testMethod void testCreateUsageWithBillingTypeIsFullPrepaidAndDateIsNotStartOfMonth(){
        prepareTestData('Newspaper', GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID, '1');
        
        Test.startTest();
        zSubs[0].Zuora__SubscriptionStartDate__c = dateToday.addMonths(1).toStartOfMonth().addDays(1);
        
        update zSubs;
        
        Date stopDate = dateToday.addMonths(1).toStartOfMonth().addDays(-1);
        stopDate = usageCreationForStopSubscription.getLastDayOfTheMonth(stopDate);
        Map<String, Date> zzIdMap = new Map<String, Date>();
        zzIdMap.put(zSubs[0].Zuora__Zuora_Id__c, stopDate);
        usageCreationForStopSubscription ucForStopSub = new usageCreationForStopSubscription();
        ucForStopSub.createUsage(zzIdMap);
        
        System.assertNotEquals(null, ucForStopSub);
        
        Test.stopTest();
    }
    
    /**
    * @name: testCreateUsageWithBillingTypeIsFullPrepaidAndDateIsEndOfMonthWithMagazine
    * @author : Recuerdo Bregente
    * @description : Handles the testing for createUsage method.
    * @date: 08/05/2015
    */
    static testMethod void testCreateUsageWithBillingTypeIsFullPrepaidWithMagazine(){
        prepareTestData('Magazine', GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID, '1');
        
        Test.startTest();
        zSubs[0].Zuora__SubscriptionStartDate__c = dateToday.addMonths(2).toStartOfMonth();
        
        update zSubs;
        
        Date stopDate = dateToday.addMonths(1).toStartOfMonth().addDays(-1);
        stopDate = usageCreationForStopSubscription.getLastDayOfTheMonth(stopDate);
        Map<String, Date> zzIdMap = new Map<String, Date>();
        zzIdMap.put(zSubs[0].Zuora__Zuora_Id__c, stopDate);
        usageCreationForStopSubscription ucForStopSub = new usageCreationForStopSubscription();
        ucForStopSub.createUsage(zzIdMap);
        
        System.assertNotEquals(null, ucForStopSub);
        
        Test.stopTest();
    }
    
    /**
    * @name: testCreateUsageWithBillingTypeIsFullPrepaidAndDateIsEndOfMonthWithNewspaper
    * @author : Recuerdo Bregente
    * @description : Handles the testing for createUsage method.
    * @date: 08/05/2015
    */
    static testMethod void testCreateUsageWithBillingTypeIsFullPrepaidAndDateIsEndOfMonthWithNewspaper(){
        prepareTestData('Newspaper', GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID, '0');
        
        Test.startTest();
        Date endDate = dateToday.addMonths(2).toStartOfMonth().addDays(-1);
        zSubs[0].Zuora__SubscriptionStartDate__c = dateToday.toStartOfMonth();
        
        update zSubs;
        
        Date stopDate = dateToday.addMonths(1).toStartOfMonth().addDays(-1);
        stopDate = usageCreationForStopSubscription.getLastDayOfTheMonth(stopDate);
        Map<String, Date> zzIdMap = new Map<String, Date>();
        zzIdMap.put(zSubs[0].Zuora__Zuora_Id__c, stopDate);
        usageCreationForStopSubscription ucForStopSub = new usageCreationForStopSubscription();
        ucForStopSub.createUsage(zzIdMap);
        
        System.assertNotEquals(null, ucForStopSub);
        
        Test.stopTest();
    }
    
    /**
    * @name: testCreateUsageWithBillingTypeIsFullPrepaidAndDateIsEndOfMonthWithMagazine
    * @author : Recuerdo Bregente
    * @description : Handles the testing for createUsage method.
    * @date: 08/05/2015
    */
    static testMethod void testCreateUsageWithBillingTypeIsFullPrepaidAndDateIsEndOfMonthWithMagazine(){
        prepareTestData('Magazine', GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID, '0');
        
        Test.startTest(); 
        Date endDate = dateToday.addMonths(2).toStartOfMonth().addDays(-1);
        zSubs[0].Zuora__SubscriptionStartDate__c = dateToday.toStartOfMonth();
        update zSubs;
        
        Date stopDate = dateToday.addMonths(1).toStartOfMonth().addDays(-1);
        stopDate = usageCreationForStopSubscription.getLastDayOfTheMonth(stopDate);
        Map<String, Date> zzIdMap = new Map<String, Date>();
        zzIdMap.put(zSubs[0].Zuora__Zuora_Id__c, stopDate);
        usageCreationForStopSubscription ucForStopSub = new usageCreationForStopSubscription();
        ucForStopSub.createUsage(zzIdMap);
        
        System.assertNotEquals(null, ucForStopSub);
        
        Test.stopTest();
    }
    
    /**
    * @name: testCreateUsageWithBillingTypeIsFullPrepaidAndStopDateIsNextMonth
    * @author : Recuerdo Bregente
    * @description : Handles the testing for createUsage method.
    * @date: 08/05/2015
    */
    static testMethod void testCreateUsageWithBillingTypeIsFullPrepaidAndStopDateIsNextMonth(){
        prepareTestData('Newspaper', GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID, '1');
        
        Test.startTest();  
        
        Map<String, Date> zzIdMap = new Map<String, Date>();
        zzIdMap.put(zSubs[0].Zuora__Zuora_Id__c, dateToday.addMonths(1).toStartOfMonth().addDays(-1));
        usageCreationForStopSubscription ucForStopSub = new usageCreationForStopSubscription();
        ucForStopSub.createUsage(zzIdMap);
        
        System.assertNotEquals(null, ucForStopSub);
        
        Test.stopTest();
    }
    
    /**
    * @name: testCreateUsageWithBillingTypeIsRecurringPrepaid
    * @author : Recuerdo Bregente
    * @description : Handles the testing for createUsage method.
    * @date: 08/06/2015
    */
    static testMethod void testCreateUsageWithBillingTypeIsRecurringPrepaid(){
        prepareTestData('Newspaper', 'Recurring Prepaid', '1');
        
        Test.startTest();  
        
        Map<String, Date> zzIdMap = new Map<String, Date>();
        zzIdMap.put(zSubs[0].Zuora__Zuora_Id__c, dateToday);
        usageCreationForStopSubscription ucForStopSub = new usageCreationForStopSubscription();
        ucForStopSub.createUsage(zzIdMap);
        
        System.assertNotEquals(null, ucForStopSub);
        
        Test.stopTest();
    }
    
    /**
    * @name: testCreateUsageWithBillingTypeIsRecurringPrepaidAndProductTypeIsNewsPaper
    * @author : Recuerdo Bregente
    * @description : Handles the testing for createUsage method and product type is 'Newspaper'.
    * @date: 08/06/2015
    */
    static testMethod void testCreateUsageWithBillingTypeIsRecurringPrepaidAndProductTypeIsNewsPaper(){
        prepareTestData('Newspaper', 'Recurring Prepaid', '1');
        
        Test.startTest();  
        
        Map<String, Date> zzIdMap = new Map<String, Date>();
        zzIdMap.put(zSubs[0].Zuora__Zuora_Id__c, dateToday.toStartOfMonth());
        usageCreationForStopSubscription ucForStopSub = new usageCreationForStopSubscription();
        ucForStopSub.createUsage(zzIdMap);
        
        System.assertNotEquals(null, ucForStopSub);
        
        Test.stopTest();
    }
    
    /**
    * @name: testCreateUsageWithBillingTypeIsRecurringPrepaidAndProductTypeIsMagazine
    * @author : Recuerdo Bregente
    * @description : Handles the testing for createUsage method and product type is 'Magazine'.
    * @date: 08/06/2015
    */
    static testMethod void testCreateUsageWithBillingTypeIsRecurringPrepaidAndProductTypeIsMagazine(){
        prepareTestData('Magazine', 'Recurring Prepaid', '1');
        
        Test.startTest();  
        
        Map<String, Date> zzIdMap = new Map<String, Date>();
        zzIdMap.put(zSubs[0].Zuora__Zuora_Id__c, dateToday.toStartOfMonth());
        usageCreationForStopSubscription ucForStopSub = new usageCreationForStopSubscription();
        ucForStopSub.createUsage(zzIdMap);
        
        System.assertNotEquals(null, ucForStopSub);
        
        Test.stopTest();
    }
             
    static testmethod void testmethod3(){ 
         
         usageCreationForStopSubscription.getLastDayOfTheMonth(date.today()+30);
         usageCreationForStopSubscription.usageQtyWrapper uqw = new usageCreationForStopSubscription.usageQtyWrapper(); 
         
    }
         
    /**
    * @name: defaultCustomSetting
    * @author : Recuerdo Bregente
    * @description : Prepares custom settings.
    * @date: 08/04/2015
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