/**
     * Class Name: BT_AB_ESH1004DX_ESHOPPromotionTest
     * @author: Accenture IDC - Nilesh
     * Date: 12 Feb 2015
     * Requirement/Project Name: SPH Project
     * @description Test Class for BT_AB_ESH1004DX_ESHOPPromotion
     * 
     */
@isTest
public class BT_AB_ESH1004DX_ESHOPPromotionTest {  

    static testMethod void executeBatchTest() { 
        
        String interfaceName = 'XXX0000XX';
        List<BT_INT_PARAM_CONFIG__c> paramConfigList = new List<BT_INT_PARAM_CONFIG__c>();
        
        defaultCustomSetting();
        
        List<String> fieldName = new List<String> { 'Promotion__r.Sequence__c',
                                                    'Promotion__r.Promotion_Code__c',
                                                    'Package_Name__r.Package_Code__c',
                                                    'Promotion__r.name',
                                                    'Promotion__r.Effective_Start_Date__c',
                                                    'Promotion__r.Effective_End_Date__c',
                                                    'lastmodifieddate',
                                                    'createddate',
                                                    'lastmodifiedby.name',
                                                    'createdby.name',
                                                    'Promotion__r.Channel_E_shop_public__c',
                                                    'Promotion__r.Channel_E_shop_overseas__c',
                                                    'Promotion__r.Channel_E_shop_private__c',
                                                    'Promotion__r.Channel_Direct__c',
                                                    'Promotion__r.Contract_Period__c' };
        
        for (Integer i=0; i<fieldName.size(); i++) {
        
            BT_INT_PARAM_CONFIG__c paramConfig = new BT_INT_PARAM_CONFIG__c();
            paramConfig.From_Object__c = 'Promotion_Package__c';
            paramConfig.field_sequence__c = i+1;
            paramConfig.interface_Name__c = interfaceName;
            paramConfig.postopfieldname__c = 'Name '+i;
            paramConfig.name = 'ESHOP000'+i;
            paramConfig.field_name__c = fieldName[i];
            
            paramConfigList.add(paramConfig);
        }
        
        insert paramConfigList;
        
        Promotion__c testPromotion = TestDataFactory.createPromotion(1)[0];
            testPromotion.Promotion_Code__c = 'Test';
            testPromotion.name = 'Test';
            testPromotion.Effective_Start_Date__c = date.today();
            testPromotion.Effective_End_Date__c = date.today().addDays(3);
            testPromotion.Channel_E_shop_public__c = false;
            testPromotion.Channel_E_shop_overseas__c = false;
            testPromotion.Channel_E_shop_private__c = false;
            testPromotion.Channel_Direct__c = false;
            testPromotion.Contract_Period__c = '24';
        insert testPromotion;
        
        Package__c testPackage = TestDataFactory.createPackage(1)[0];
            testPackage.Name = 'Pack Name';
            testPackage.Billing_Type__c = 'Full Prepaid';
            testPackage.Package_Type__c = 'Base';
            testPackage.Subscription_Period__c = '18';
            testPackage.Package_Code__c = 'Test 111';
        insert testPackage;
        
        Promotion_Package__c testPromotionPackage = TestDataFactory.createPromotionPackage(1)[0];
            testPromotionPackage.Promotion__c = testPromotion.id;
            testPromotionPackage.Package_Name__c = testPackage.id;
        insert testPromotionPackage;
        
        Test.StartTest();
        
            BT_AB_ESH1004DX_ESHOPPromotion batch = new BT_AB_ESH1004DX_ESHOPPromotion (interfaceName);        
            Database.executeBatch(batch, 200);
        
        Test.StopTest();
    }
    
    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
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
    }
}