/**
  * Class Name: BT_TH_STP050DX_StopPressSubscriptionTest
  * @author: Accenture IDC - Nilesh
  * Date: 10 Feb 2015
  * Requirement/Project Name: SPH Project
  * @description Test Class for BT_TH_STP050DX_StopPressSubscription
  * 
  */
@isTest
public class BT_TH_STP050DX_StopPressSubscriptionTest {
    
    static testMethod void testexecutePositive() {
        
            try {
                defaultCustomSetting();
                List<BT_CO_STPPRS_StopPressSubscription__c> recordsList = createStopPressSubscription(1);
                
                Test.startTest();
                
                BT_TH_STP050DX_StopPressSubscription testInstance = new BT_TH_STP050DX_StopPressSubscription();
                
                testInstance.execute(recordsList);
                
                Test.stopTest();
                    
            }catch(Exception exp)
            {
                System.debug('Exception - ' + exp.getMessage());
            }
        }
       /* 
      static testMethod void testexecuteNegative() {
        
            defaultCustomSetting();
            List<BT_CO_STPPRS_StopPressSubscription__c> recordsList = createStopPressSubscription(2);
            
            Test.startTest();
            
            BT_TH_STP050DX_StopPressSubscription testInstance = new BT_TH_STP050DX_StopPressSubscription();
            
            testInstance.execute(recordsList);
            
            Test.stopTest();
        }
        
    static testMethod void testexecuteNegative1() {
        
            defaultCustomSetting();
            List<BT_CO_STPPRS_StopPressSubscription__c> recordsList = createStopPressSubscription(1);
            
            for(Integer i =0; i < recordsList.size();i++)
            {
                BT_CO_STPPRS_StopPressSubscription__c record = recordsList[i];
                
                record.subscriber_home_tel_number__c = 'x';
                record.subscriber_office_tel_number__c = 'x';
                record.subscriber_office_ext_number__c = 'x';
                record.subscriber_fax_number__c = 'x';
                record.subscriber_email_id__c = 'x';
                
 //               update record;
            }
        
            Test.startTest();
            
            BT_TH_STP050DX_StopPressSubscription testInstance = new BT_TH_STP050DX_StopPressSubscription();
            
            testInstance.execute(recordsList);
            
            Test.stopTest();
        }
        */
        
      /**
     * @description 
     *      This method creates one or more BT_CO_STPPRS_StopPressSubscription__c test data.   
     * 
     * @param numAccts - number of BT_CO_STPPRS_StopPressSubscription__c to be created
     * @return accountList - list of created BT_CO_STPPRS_StopPressSubscription__cs
     * @throws exception - none
     */     
    public static List<BT_CO_STPPRS_StopPressSubscription__c> createStopPressSubscription(Integer numSub) {
        List<BT_CO_STPPRS_StopPressSubscription__c> subscriptionList = new List<BT_CO_STPPRS_StopPressSubscription__c>();
       
        //create Package
        //Map<String, SObject> mapSObject = TestDataFactory.createSubscriptionPackage();
         
         Country__c country = new Country__c();
             country.Name = 'SIN';
             country.Code__c = 'SIN';
             country.Country_Name__c = 'SINGAPORE';
         insert country;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'Name';
        postal.Building_Name__c = 'Ebloc2';
        insert postal;
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        address.Block_House_Number__c =  'TEST';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        
        //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
        
        insert address;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Grace Period';
        pack.Package_Code__c ='PC01';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Sub_Type__c = 'Single';
        pack.Subscription_Period__c = '1';
        pack.Subscription_Type__c = 'Termed';
        pack.Product_Family_Current_Package__c = '1';
        pack.Package_Price__c = 10.50;
        insert pack;
        
        /*
        Singpost_Address__c testSingPostAddress = (Singpost_Address__c) mapSObject.get('Singpost_Address__c');
            testSingPostAddress.Name = '11111';
        update testSingPostAddress;
        
         Address__c addressRec = (Address__c) mapSObject.get('Address__c');
            addressRec.Country__c = country.Id;
         update addressRec;
        
         Package__c pack = (Package__c) mapSObject.get('Package__c');
                 
         zqu__ZProduct__c prod = (zqu__ZProduct__c) mapSObject.get('zqu__ZProduct__c');
         prod.ProductSubType__c='Newspaper';
         update prod;
        
         Product_Publication__c publication = TestDataFactory.createProductPublication(1)[0];
         publication.ZProduct__c=prod.Id;
         insert publication;
        */
         
         upsert new Delivery_Charge__c (Name='nullT',SetupOwnerId=UserInfo.getOrganizationId(), Subscriber_Charge__c=10.0);
        
        //for(Integer i=0;i<numSub;i++){
            BT_CO_STPPRS_StopPressSubscription__c record = new BT_CO_STPPRS_StopPressSubscription__c(
                                                subscriber_name__c='TestSubName',
                                                subscriber_profession__c='Professional',
                                                subscriber_home_tel_number__c='1234567',
                                                subscriber_office_tel_number__c='1234567',
                                                subscriber_office_ext_number__c='123',
                                                subscriber_fax_number__c='1234567',
                                                subscriber_email_id__c='test' + '@test.com',
                                                subscriber_date_of_birth__c='10.02.2015',
                                                subscription_package_code__c= pack.Package_Code__c,
                                                subscriber_type__c='IS',
                                                subscriber_postal_code__c='11111',
                                                subscriber_country_code__c='SIN',
                                                referred_start_date__c='10.02.2015',
                                                sub_period__c='24',
                                                sub_copies__c='1',
                                                recipient_name__c='TestRecName',
                                                recipient_profession__c='Professional',
                                                recipient_home_tel_num__c='1234567',
                                                recipient_office_tel_num__c='1234567',
                                                recipient_office_ext_num__c='123',
                                                recipient_fax_num__c='1234567',
                                                recipient_email_id__c='test' + '@test.com',
                                                recipient_date_of_birth__c='10.02.2015',
                                                recipient_postal_code__c='11111',
                                                recipient_country_code__c='SIN');
                                                
            //Add the record object to list 
            subscriptionList.add(record);
        //}
        
        insert subscriptionList;
        
        return subscriptionList;
    }
    
    static void defaultCustomSetting()
    {
        Key_Id__c keyId;
        Other__c otherC;        
        
        String[] keyIdNameArray = new String[]{'Default Mailing Agent','Publication Delivered By','Start Subscription','AddAirline','AddInternal','AddLocal','AddOverseas','Package Item_Extension Product','SubTermTypeEvergreen','SubTypeGift','Package Item_Bundle Discount','SubTermTypeTermed','QuoteInvoiceProcessingSubscription','CurrencySGD','Profile_System Administrator','Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'001N000000ICcIv','Vendor or Mailing Agent','012N00000008jvY','Airline','Internal','Local','Overseas','012N00000008jCnIAI','Evergreen','Gift','012N00000008jCiIAI','Termed','Subscription','SGD','00e90000001VZOq','012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'','String','RecordType','Name','Name','Name','Name','RecordType','Name','Name','RecordType','Name','Name','Name','Profile','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
            //insert keyId;
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
        
        Cir_Planner_Schedule__c testCirPlannerSchedule = new Cir_Planner_Schedule__c();
            testCirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            testCirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            testCirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            testCirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            testCirPlannerSchedule.Sun_Start_Time__c = System.Now();
            testCirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            testCirPlannerSchedule.Name = 'CIR Plan Schedule';
        insert testCirPlannerSchedule;
        
        BatchInterface_Settings__c testBatchInterfaceSetting = new BatchInterface_Settings__c();
            testBatchInterfaceSetting.Name = 'Endpoint Delegator';
            testBatchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert testBatchInterfaceSetting;
        
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