/**
* Class Name: BT_AB_DIR094DX_VendorPerformanceIndTest
* @author: Recuerdo Bregente
* @date: 08/10/2015
* @requirement/Project Name: SPH Project
* @description Test Class for BT_AB_DIR094DX_VendorPerformanceIndirect.
*/
@isTest (seeAllData=false)
public class BT_AB_DIR094DX_VendorPerformanceIndTest {

    // Test Data
    static Case_Vendor_Subscription__c csVenSub2;

    /**
    * @name : prepareTestData
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 08/10/2015
    */ 
    static void prepareTestData(){
       defaultCustomSetting();
            
        //Singpost Address
        Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
        insert singAdd;
        
        //Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = singAdd.id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        acc.Vendor_Code__c = 'VC001';
        insert acc;
        
        //Address__c
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = singAdd.Id;
        insert addressRec;
      
        //Contact
        List<Contact> conList = new List<Contact>();
        conList.add(new Contact());
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Recipient_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Billing_Indicator__c = TRUE; 
        conList[0].Mobile_Number__c = '09155568874'; 
        conList[0].Mobile_Number_2__c = '09112234567';
        conList[0].Active__c = true;
        conList[0].Email = 'test@sample.com';
        insert conList;
        
        //Order__c
        Order__c orderRec = TestDataFactory.createOrder(1)[0];
        orderRec.Account__c = acc.Id;
        orderRec.Informed_Customer__c = TRUE;
        orderRec.Recipient_Contact__c = conList[0].Id;
        orderRec.Billing_Contact__c = conList[0].Id;
        orderRec.Subscriber_Charge__c = 15;
        insert orderRec;
        
        //Temp Stop
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Temp_Stop_Date__c = Date.today() + 1;
        tempStop.Restart_Date__c = Date.today() + 2;
        tempStop.Remarks__c = 'Sample Remarks';
        insert tempStop;
        List<RecordType> rt = [SELECT id, Name, DeveloperName FROM RecordType WHERE SobjectType='Case' and Name =: 'Complaint - Newspaper'];

        //Case
        Case cs = new Case();
        cs.AccountId = acc.id;
        cs.Effective_Date__c = Date.today()+1;
        cs.COA__c = true;
        cs.Temp_Stop__c = tempStop.id;
        cs.Status = 'Closed';
        cs.Order__c = orderRec.id;
        cs.Vendor__c = acc.id;
        cs.Change_of_Address_Type__c = 'Change of Vendor';
        cs.Contact_To_Update__c = conList[0].id;
        cs.Remarks__c = 'Sample Remarks';
        cs.Sub_Category__c = 'Miscellaneous';
        cs.RecordTypeId = rt[0].Id;
        cs.Vendor_Chargeable_Courier__c = true; //EGC 4/9/2016 added
        insert cs;
        
        //START EGC 4/9/2016
        Vendor_Performance__c vendorPerf = new Vendor_Performance__c();
        vendorPerf.From_Date__c = System.today().addDays(-30);
        vendorPerf.To_Date__c = System.today().addDays(30);
        insert vendorPerf;
        //END EGC 4/9/2016
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.id;
        subVen.Vendor__c = acc.id;
        insert subVen;
        
        Publication__c testPublication = TestDataFactory.createPublication(1)[0];
        testPublication.Publication_Code__c = 'BH';
        testPublication.Published_Days__c = 'YYYYYYY';
        testPublication.Publication_Type__c = 'N';
        testPublication.Platform_Type__c = 'Print';        
        insert testPublication;
            
        Subscription_Vendor_Publication__c testSubscriptionVendorPublication = TestDataFactory.createVendorPublication(1)[0];
        testSubscriptionVendorPublication.Subscription_Vendor__c = subVen.Id;
        testSubscriptionVendorPublication.Account__c = acc.id;
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
        
        //Subject here
        csVenSub2 = TestDataFactory.createCaseVendorSub(1)[0];
        csVenSub2.Case__c = cs.id;
        csVenSub2.Subscription_Vendor__c = subVen.id;
        csVenSub2.Account__c = acc.id;
        insert csVenSub2;
        
        BT_CO_DIR_VendorPerformanceMaster__c master = new BT_CO_DIR_VendorPerformanceMaster__c();
        master.AccountId__c = acc.id;
        master.Vendor_Code__c  = 'VC001';
        
        insert master;
        
        cs.Status = 'Closed';
        cs.Sub_Status__c = 'Complaint Resolved';
        update cs;
        
    }
    
    /**
    * @name: testBatch
    * @author : Recuerdo Bregente
    * @description : Handles the testing for processRecords method.
    * @date: 08/10/2015
    */
    static testMethod void testBatch(){
        prepareTestData();
        
        BT_AB_DIR094DX_VendorPerformanceIndirect batch = new BT_AB_DIR094DX_VendorPerformanceIndirect();
        ID batchprocessid = Database.executeBatch(batch, 200);
        
        System.assertNotEquals(null, batchprocessid);
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
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Case_Complaint Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
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
        
        BT_CO_Batch_Run_Request__c brr = new BT_CO_Batch_Run_Request__c();
        brr.interface_id__c='DIR094DX';
        brr.batch_run_date__c = Date.today();
        insert brr;
    }
}