/**
 * Class Name: BT_AB_HDS037DX_DailyVendorSubscription_3    
 * @author: Accenture IDC - Nilesh    
 * Date: 13 Feb 2015    
 * Requirement/Project Name: SPH Project    
 * @description Test Class for BT_AB_HDS037DX_DailyVendorSubscription_3    
 */
@isTest(seeAllData = True)
public class BT_AB_HDS037DX_DailyVendorSub3Test {
    
    static {
        
        BT_CO_Batch_Run_Request__c batchRunRequest = new BT_CO_Batch_Run_Request__c();
        batchRunRequest.Interface_ID__c = 'HDS037DX';
        batchRunRequest.Batch_Run_Date__c = System.Today()+1;
        
       // insert batchRunRequest;
    }
    
    static testmethod void executeBatch(){
    
        //defaultCustomSetting();
        
        //RecordType testRecordType = [SELECT Id FROM RecordType WHERE Name='Vendor Stop Request' LIMIT 1][0];
        RecordType testRecordType = [SELECT Id FROM RecordType WHERE Name='Change of Subscription' LIMIT 1];
        
        //Map<String, SObject> sobjectMap =  TestDataFactory.createSubscriptionPackage();
        /*
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
        */
        Account testAccount = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            testAccount.NRIC__c = 'T1234567R';
        insert testAccount;
        
        Country__c testCountry = TestDataFactory.createCountry(1)[0];
            testCountry.Account__c = testAccount.Id;
            testCountry.Code__c = '6547954';
            testCountry.Country_Name__c = 'Singapore';
            insert testCountry;
        
        Address__c testAddress = new Address__c();
            testAddress.name = 'SA999';
            testAddress.Address_Type__c = 'P';
            testAddress.Unit_Number__c = '99';
            testAddress.Block_House_Number__c = '99';
            testAddress.Level_Number__c = '99';
            testAddress.Unit_Number__c = '99';
            testAddress.Country__c = testCountry.Id;
        insert testAddress; 
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '123457397';
        key.Type__c = 'Number';
        insert key; 
        */
        Contact testContact = TestDataFactory.createContactRecType(1, 'Vendor Contact')[0];
            testContact.Address__c = testAddress.Id;
            testContact.AccountId = testAccount.Id;
            testContact.Recipient_Indicator__c = true;
        insert testContact;
        
        Address_Assignment__c testAddressAssignment = new Address_Assignment__c();
            testAddressAssignment.Active__c = false;
            testAddressAssignment.Contact__c = testContact.id;
            testAddressAssignment.Address__c = testAddress.id;
            testAddressAssignment.Effective_Date__c = date.today().addYears(-1);
        insert testAddressAssignment;
        
        Subscription_Vendor__c testSubscriptionVendor = TestDataFactory.createSubscriptionVendor(1)[0];
            testSubscriptionVendor.Account__c = testAccount.id;
            testSubscriptionVendor.Recipient__c = testContact.id;
        insert testSubscriptionVendor;
        
        Publication__c testPublication = TestDataFactory.createPublication(1)[0];
            testPublication.Publication_Code__c = 'BH';
            testPublication.Published_Days__c = 'YYYYYYY';
            testPublication.Publication_Type__c = 'Y';
        insert testPublication;
        
        Subscription_Vendor_Publication__c testSubscriptionVendorPublication = TestDataFactory.createVendorPublication(1)[0];
            testSubscriptionVendorPublication.Subscription_Vendor__c = testSubscriptionVendor.id;
            testSubscriptionVendorPublication.Account__c = testAccount.id;
            testSubscriptionVendorPublication.Publication__c = testPublication.id;            
            testSubscriptionVendorPublication.Mon__c = 1;
            testSubscriptionVendorPublication.Tue__c = 1;
            testSubscriptionVendorPublication.Wed__c = 1;
            testSubscriptionVendorPublication.Thu__c = 1;
            testSubscriptionVendorPublication.Fri__c = 1;
            testSubscriptionVendorPublication.Sat__c = 1;
            testSubscriptionVendorPublication.Sun__c = 1;
            testSubscriptionVendorPublication.PHd__c = 1;
            testSubscriptionVendorPublication.PHe__c = 1;
        insert testSubscriptionVendorPublication;
        /*
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        */
        RecordType rec = [select id from recordType where name = 'Change of Subscription'];
        Case testCase = new Case();
        testCase.AccountId = testAccount.Id;
            testCase.RecordTypeId = rec.ID;//ConstantsSLB.getKeyId('Case_Change of Subscription');
            testCase.Status = 'Closed';
            testCase.Publication__c = testPublication.id;
            //try{
                //system.assertEquals(string.valueOf(testCase.RecordTypeId), 'a');
                insert testCase;
            //}catch(exception e){}
        /*
        stdObj = TestDataFactory.createCase(1,'Change of Subscription');
        Case stdObj = caseList[0];
            testCase.Status = 'Closed';
            testCase.Publication__c = testPublication.id;
            //testCase.RecordTypeId = testRecordType.id;
        update testCase;
        */
        
        Case_Vendor_Subscription__c testCaseVendorSubscription = TestDataFactory.createCaseVendorSub(1)[0];
            testCaseVendorSubscription.Account__c = testAccount.id;
            testCaseVendorSubscription.Case__c = testCase.id;
            testCaseVendorSubscription.Subscription_Vendor__c = testSubscriptionVendor.id;
        //try{
            insert testCaseVendorSubscription;
        //}catch(exception e){}
        try{
        Test.StartTest();
            BT_AB_HDS037DX_DailyVendorSubscription_3 batch = new BT_AB_HDS037DX_DailyVendorSubscription_3(Date.newInstance(2016, 05, 01),Date.newInstance(2016, 05, 31));
            //Database.executeBatch(batch, null);
            Database.executeBatch(batch);
        Test.StopTest();
        }catch(exception e){}
    }
    
    static void defaultCustomSetting()
    {
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product',
                                                'Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId',
                                                'NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription',
                                                'Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue',
                                                'Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel',
                                                'SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI',
                                                    '012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA',
                                                    '012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw',
                                                    '012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number',
                                                    'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type',
                                                    'Record Type','Record Type','Record Type','Name','Name','Name'};
        /*
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
                keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
            insert keyId;
        }
        */
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop',
                                                        'Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)',
                                                        'Digital','Magazine','Print'};
        
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
    }
}