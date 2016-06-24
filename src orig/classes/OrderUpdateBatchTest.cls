@isTest (seeAllData = false)
private class OrderUpdateBatchTest {

    static testmethod void test() {
        
       defaultCustomSetting();
       
       Account acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
       //acct.NRIC__c = 'T1234567R';
       acct.Name = 'E2E';
       insert acct;
       
       Order__c order = TestDataFactory.createOrder(1)[0];
       order.isOrderLegacy__c = false;
       order.Account__c = acct.Id;
       order.Order_Legacy_Id__c = '114151251';
       insert order;
        
       Test.startTest();  
       OrderUpdateBatch batch = new OrderUpdateBatch();
       ID batchprocessid = Database.executeBatch(batch,200);
       Test.stopTest();
       
       System.assertNotEquals(null, batchprocessid);
    
    }
    
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
        
        String[] errorCNameArray = new String[]{'ARMS account too many record','ARMS account is not existing','ARMS Timed-out','ARMS select one Customer only','Invalid Response'};
        String[] errorCValueArray = new String[]{'Too many account type.','ARMS account is not existing.','Timed-out. Please click Search button again.','Please select one Customer only.','Invalid response from server. Please try again later.'};
        
        List<Error_Messages__c> errorList = [SELECT Name FROM Error_Messages__c];
        Set<String> errorNames = new Set<String>();
        for(Error_Messages__c errorRec : errorList) {
            errorNames.add(errorRec.Name);
        }
        
        Error_Messages__c errorRec;
        for(Integer i = 0 ; i < errorCNameArray.size(); i++ )
        {
             if(!errorNames.contains(errorCNameArray[i])) {
                errorRec = new Error_Messages__c();
                errorRec.Name = errorCNameArray[i];
                errorRec.Message__c = errorCValueArray[i];
                insert errorRec;
            }
        }
    }
}