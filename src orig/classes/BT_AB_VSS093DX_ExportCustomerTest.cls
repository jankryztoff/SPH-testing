/**
 * Class Name: BT_AB_VSS093DX_ExportCustomerTest     
 * @author: Accenture IDC - Nilesh    
 * Date: 13 Feb 2015    
 * Requirement/Project Name: SPH Project    
 * @description Test Class for BT_AB_VSS093DX_ExportCustomerStartStop    
 */
@isTest(SeeAllData = false)
public class BT_AB_VSS093DX_ExportCustomerTest {
    /*
    static testmethod void executeBatchBaseCaseSubscription(){

        defaultCustomSetting();
        
        
        
            Map<String, SObject> sobjectMap = defaultValues(false, 1);
            Zuora__Subscription__c testSubscription = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c');
                testSubscription.Frequency__c = 'default';      
                testSubscription.Billing_Type__c = 'Postpaid';
            update testSubscription;
            

            
        /// Start Test Class
        
        
        
            BT_AB_VSS093DX_ExportCustomerStartStop batch = new BT_AB_VSS093DX_ExportCustomerStartStop(); 
            ID batchprocessid = Database.executeBatch(batch, 200);
            
                    
            BA_INT_DATA_POOL__c bidp = new BA_INT_DATA_POOL__c();
            bidp.group_id__c = 'test98234';
            bidp.insert_time__c = dateTime.now();
            bidp.job_id__c = batchprocessid;
            bidp.run_for_date__c = date.Today()+2;
            bidp.Name = 'VSS093DX';
            insert bidp; 
        
        Test.StopTest();
    }
 
    static testmethod void executeBatchBaseCaseSubscription1(){

        defaultCustomSetting();
        Map<String, SObject> sobjectMap = defaultValues(false, 2);
//        Test.StartTest();
        Zuora__Subscription__c testSubscription = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c');
            testSubscription.Frequency__c = 'Mon - Sat';
        update testSubscription;
        
        /// Start Test Class
        
        
        
            BT_AB_VSS093DX_ExportCustomerStartStop batch = new BT_AB_VSS093DX_ExportCustomerStartStop();        
            Database.executeBatch(batch, 200);

        Test.StopTest();
    }
    
    static testmethod void executeBatchBaseCaseSubscription2(){

        defaultCustomSetting();
        Map<String, SObject> sobjectMap = defaultValues(false, 3);
//        Test.StartTest();
        Zuora__Subscription__c testSubscription = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c');
            testSubscription.Frequency__c = 'Sat - Sun';
        update testSubscription;
        
        /// Start Test Class
        
//        Test.StartTest();
        
            BT_AB_VSS093DX_ExportCustomerStartStop batch = new BT_AB_VSS093DX_ExportCustomerStartStop();        
            Database.executeBatch(batch, 200);

        Test.StopTest();
    }
    */
  /* APRIL  
    static testmethod void executeBatchBaseCaseVendorSubscription(){

        defaultCustomSetting();
        Map<String, SObject> sobjectMap = defaultValues(false, 1);
//        Test.StartTest();
     //   Case testCase = (Case) sobjectMap.get('Case');
     //   Case testCloneCase = testCase.clone(false, false, false, false);
     //       testCase.Effective_Date__c = date.today();
      //  insert testCloneCase;
        
        Case_Vendor_Subscription__c testCaseVendorSubscription = (Case_Vendor_Subscription__c) sobjectMap.get('testCaseVendorSubscription');
        Case_Vendor_Subscription__c testCloneCaseVendorSubscription = testCaseVendorSubscription.clone(false, false, false, false);
            testCloneCaseVendorSubscription.Case__c = testCloneCase.id;
        insert testCloneCaseVendorSubscription;
                
        /// Start Test Class
        
        Test.StartTest();
        
            BT_AB_VSS093DX_ExportCustomerStartStop batch = new BT_AB_VSS093DX_ExportCustomerStartStop();        
            Database.executeBatch(batch, 200);

        Test.StopTest();
    }*/
    
    private static Map<String, SObject> defaultValues(boolean insertFlag, integer dateCount)
    {
        Date today = date.today();
        DateTime todayDateTime = DateTime.newInstance(today.year(), today.month(), today.day());
        String productCode = 'XXXX';
        Map<String, SObject> sobjectMap = TestDataFactory.createSubscriptionPackage();

        Publication__c testPublication = TestDataFactory.createPublication(1)[0];
            testPublication.Publication_Code__c = 'XXXX';
            testPublication.Published_Days__c = 'YYYYYYY';
            testPublication.Public_Holiday_Weekday_Pub_Indicator__c = true;
            testPublication.Public_Holiday_Weekend_Pub_Indicator__c = true;
            testPublication.Publication_Type__c = 'N';
        insert testPublication;
        
        Account testAccount = (Account) sobjectMap.get('Account');
            testAccount.RecordTypeId = getRecordType('Vendor Subscriber','Account').id;
            testAccount.Vendor_Code__c = '0000X';
            testAccount.Vendor_Group__c = 'X';
        update testAccount;
        
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;       
        
        Order__c order = (Order__c) sobjectMap.get('Order__c');
        order.Subscriber_Charge__c = 200;
        update order;
        
        zqu__ZProduct__c testProduct =  (zqu__ZProduct__c) sobjectMap.get('zqu__ZProduct__c');
            testProduct.ProductCode__c = productCode;
        update testProduct;     
        
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Cancelled__c = False; //Checkbox
        tempStop.Restart_Date__c = date.Today ()+90;
        tempStop.Temp_Stop_Date__c = date.Today ()+30;
        insert tempStop;
        sobjectMap.put('Temp_Stop__c',tempStop);
        // First Case - All Default Values
      
        Recordtype recType = [SELECT Id, DeveloperName, Description FROM Recordtype WHERE SobjectType = 'Case' AND DeveloperName = 'Temp_Stop_Subscription'];
        
        Case testCase = (Case) sobjectMap.get('Case');
            testCase.Account__c = testAccount.id;
            testCase.Publication__c = testPublication.id;
            //testCase.RecordTypeId = getRecordType('Start Subscription','Case').id;
            testCase.RecordTypeId = recType.id;
            testCase.Date_Replaced__c = date.Today()+3;
            testCase.Description = 'Description';
            testCase.Effective_Date__c = date.Today() +1;
            testCase.Earliest_Stop_Date__c = date.Today() +60;
            testCase.POP_Start_Date__c = date.Today()+1;
            testCase.Remarks__c = 'Remarks';
            testCase.Restart_Date__c = date.Today() +90;
            testCase.Sub_Category__c = 'Change of Credit Card'; //Picklist
            testCase.Stop_Request_Date__c =  date.Today()+60;
            testCase.Stop_Date__c = date.Today()+15;
            testCase.Temp_Stop_Date__c = date.Today() +30;
            testCase.Temp_Stop__c = tempStop.id;
            testCase.Temp_Stop_Type__c = 'New'; //Picklist
            testCase.Change_of_Address_Type__c = 'Change of Billing address'; //Picklist
            testCase.Sub_Status__c = 'Assess for Goodwill'; //Picklist
            testCase.Status = 'Closed';
          
            if(dateCount == 1)
                testCase.Temp_Stop_Date__c = today;
            else if(dateCount == 2)
                testCase.Restart_Date__c = today;
            else if(dateCount == 3)
                testCase.Earliest_Stop_Date__c = today;
                
        //insert testCase;
        
        sobjectMap.put('Case',testCase);
        try{
        Test.StartTest();
        //Test.StartTest();//TODO
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0];
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other';
        defaultPayment.Zuora__Account__c = testAccount.id;
        insert defaultPayment;
        
        Contact testContact = TestDataFactory.createContactRecType(1, 'Vendor Contact')[0];
        insert testContact;
        
        Zuora__Subscription__c testSubscription = (Zuora__Subscription__c) sobjectMap.get('Zuora__Subscription__c');
            testSubscription.Product_Code__c = productCode;
            testSubscription.Frequency__c = 'Mon - Fri';
            testSubscription.Qty__c = 10;
            testSubscription.Billing_Type__c = 'Full Prepaid';
            testSubscription.Vendor_1__c = testAccount.id;
            testSubscription.Zuora__CustomerAccount__c = defaultPayment.id; 
            testSubscription.Recipient_Contact__c = testContact.id;
        insert testSubscription;
        
        Case_Subscription__c testCaseSubscription = TestDataFactory.createCaseSubscription(1)[0];
            testCaseSubscription.Case__c = testCase.id;
            testCaseSubscription.Subscription__c = testSubscription.id;
            testCaseSubscription.Account__c = testAccount.id;
        
        
            insert testCaseSubscription;
        
        
        sobjectMap.put('testCaseSubscription', testCaseSubscription);  
        
        Product_Publication__c testProductPublication = TestDataFactory.createProductPublication(1)[0];
            testProductPublication.ZProduct__c = testProduct.id;
            testProductPublication.Publication_Code__c = testPublication.id;
        insert testProductPublication;
        
        
        
        Subscription_Vendor__c testSubscriptionVendor = TestDataFactory.createSubscriptionVendor(1)[0];
            testSubscriptionVendor.Account__c = testAccount.id;
            testSubscriptionVendor.Recipient__c = testContact.id;
        insert testSubscriptionVendor;
        
        Case_Vendor_Subscription__c testCaseVendorSubscription = TestDataFactory.createCaseVendorSub(1)[0];
            testCaseVendorSubscription.Account__c = testAccount.id;
            testCaseVendorSubscription.Case__c = testCase.id;
            testCaseVendorSubscription.Subscription_Vendor__c = testSubscriptionVendor.id;
        insert testCaseVendorSubscription;
        
        sobjectMap.put('testCaseVendorSubscription', testCaseVendorSubscription); 
        
        Subscription_Vendor_Publication__c testSubscriptionVendorPublication = TestDataFactory.createVendorPublication(1)[0];
            testSubscriptionVendorPublication.Subscription_Vendor__c = testSubscriptionVendor.id;
            testSubscriptionVendorPublication.Account__c = testAccount.id;
            testSubscriptionVendorPublication.Publication__c = testPublication.id;
            if(insertFlag)
            {
                testSubscriptionVendorPublication.Mon__c = 1;
                testSubscriptionVendorPublication.Tue__c = 1;
                testSubscriptionVendorPublication.Wed__c = 1;
                testSubscriptionVendorPublication.Thu__c = 1;
                testSubscriptionVendorPublication.Fri__c = 1;
                testSubscriptionVendorPublication.Sat__c = 1;
                testSubscriptionVendorPublication.Sun__c = 1;
                testSubscriptionVendorPublication.PHd__c = 1;
                testSubscriptionVendorPublication.PHe__c = 1;
            }
        insert testSubscriptionVendorPublication;
        
        sobjectMap.put('testSubscriptionVendorPublication', testSubscriptionVendorPublication);  
        Test.StopTest();        
        }catch(Exception e){}
        return sobjectMap;
    }
    
    private static RecordType getRecordType(String recordTypeValue,String objectType)
    {
        RecordType testRecordType = null;
        
        if(recordTypeValue != null)
        {
            testRecordType = [SELECT id FROM RecordType WHERE SobjectType = :objectType AND Name=: recordTypeValue LIMIT 1][0];
        }
        
        return testRecordType;
    }
   
    static void defaultCustomSetting() //TODO
    {
        List<Key_Id__c> keyIds = new List<Key_Id__c>();
        List<Other__c> others = new List<Other__c>();
        
        String[] keyIdNameArray = new String[]
        {'Account_Direct Individual',
        'Account_Vendor Subscriber',
        'Address_Local',
        'Contact_Customer Contact',
        'Package Item_Base Product',
        'Package Item_Bundle Product',
        'Package Item_Discount',
        'Package Item_Extension Discount',
        'UpdateARMSInfoResultId',
        'NEXT_RECIPIENT_NUMBER',
        'Account_Direct Corporate',
        'Account_Direct SPH Inter-Division',
        'Case_Change of Subscription',
        'Case_Start Sub',
        'Case_Stop',
        'Case_Temp Stop',
        'CSO Asst. Manager/ Manager Queue',
        'CSO TL Queue',
        'Head of Customer Service Queue',
        'Case Renewal of Subscription',
        'Case_Change in Address',
        'Complaint_Newspaper',
        'Case_Complaint Magazine',
        'SubTypeDel',
        'SubTypePostage',
        'SubTypePub'};

        String[] keyIdIdcArray = new String[]
        {'012N00000008ic1IAA',
        '012N00000008ibwIAA',
        '012N00000008idiIAA',
        '012N00000008r43IAA',
        '012N00000008jCOIAY',
        '012N00000008jCdIAI',
        '012N00000008jCTIAY',
        '012N00000008jCsIAI',
        '123vd',
        '123457177',
        '012N00000008ic6IAA',
        '012N00000008icBIAQ',
        '012N00000008lpwIAA',
        '012N00000008jvYIAQ',
        '012N00000008k09IAA',
        '012N00000008k0EIAQ',
        '00GN0000000mMcJ',
        '00GN0000000lUNp',
        '00GN0000000mUXw',
        '012N00000008lqG',
        '012N00000008lAoIAI',
        '012N00000008kI8IAI',
        '012N00000008kIDIAY',
        'Delivery',
        'Postage',
        'Publication'};
        
        String[] keyIdTypeArray = new String[]
        {'Record Type',
        'Record Type',
        'Record Type',
        'Record Type',
        'Record Type',
        'Record Type',
        'Record Type',
        'Record Type',
        'Id',
        'Number',
        'Record Type',
        'Record Type',
        'Record Type',
        'Record Type',
        'Record Type',
        'Record Type',
        'Id',
        'Id',
        'Id',
        'Record Type',
        'Record Type',
        'Record Type',
        'Record Type',
        'Name',
        'Name',
        'Name'};

        
//        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
//        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
//        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
                Key_Id__c keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
                keyIds.add(keyId);
        }
        insert keyIds;

        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print'};
        
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
                Other__c otherC = new Other__c();
                otherC.Name = orderCNameArray[i];
                otherC.Value__c = orderCValueArray[i];
                others.add(otherC);
        }
        insert others;
        //joy
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