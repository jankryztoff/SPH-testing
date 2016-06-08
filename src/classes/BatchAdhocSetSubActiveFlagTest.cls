@isTest (SeeAllData = false)
private class BatchAdhocSetSubActiveFlagTest {

    static Account acct;
    static Zuora__CustomerAccount__c billingAccount;
    //static Zuora__Subscription__c subList;
    static List <Zuora__Subscription__c> SubsList;
    static Order_Line_Item__c orderLine; 
    static Order__c order;
    
    private static void prepareTestData() {
       
       defaultCustomSetting();
       
       acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
       //acct.NRIC__c = 'T1234567R';
       insert acct;
       
       Contact cont = TestDataFactory.createContact(1)[0];
       cont.Recipient_Indicator__c = true;
       insert cont;
       
       billingAccount = TestDataFactory.createBillingAccount(1)[0];
       billingAccount.Zuora__Account__c = acct.Id;
       billingAccount.Payment_Mode__c = 'Other';
       billingAccount.Zuora__DefaultPaymentMethod__c = 'Other';
       insert billingAccount;
       
       SubsList = new List <Zuora__Subscription__c>();
          Zuora__Subscription__c Subs = new Zuora__Subscription__c();
            Subs.Zuora__Account__c = acct.id;
            Subs.Name= 'CS0000000110';
            Subs.Number_of_Copies__c= 10;
            Subs.Zuora__CustomerAccount__c = billingAccount.id;
            Subs.Next_Earliest_Start_Date__c= date.today();
            Subs.Unique_Address_Id__c= 'asdasdasd';
            Subs.Year_to_Date_Temp_Stop_Days__c= 2;
            Subs.Previous_Year_Temp_Stop_Days__c= 2;
            Subs.Legacy_Create_Date__c='2014-08-07';
            Subs.Legacy_Create_By__c='test';
            Subs.Legacy_Update_Date__c='test';
            Subs.Legacy_Update_By__c='test';
            Subs.Legacy_Subscription_ID__c='test';
            Subs.Cheque_details__c='test';
            Subs.DTL__c='test';
            Subs.Paypal_Payment_Profile_Id__c='test';
            Subs.Pub_Tag__c='test';
            Subs.Subscribe_As__c='test';
            Subs.Zuora__SubscriptionEndDate__c= date.today().addDays(5);
            Subs.Subscription_Grace_Period_End_Date__c= 'test';
            Subs.Gift_ID__c= 'test';
            Subs.Redeem_Date__c= 'test';
            Subs.Gift_ID_2__c= 'test';
            Subs.Redeem_Date_2__c= 'test';
            Subs.Subscriber_Contact__c= cont.Id;
            Subs.Recipient_Contact__c= cont.Id;
            Subs.Subscription_Charge__c= 223.0;
            Subs.Term_Length__c= 2;
            Subs.Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
            
            SubsList.add(Subs);
            insert SubsList;
       
       //Key_Id__c keyId = new Key_Id__c();
      // keyId.Name = 'NEXT_RECIPIENT_NUMBER';
       //insert keyId;
       
       //Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
       //insert dtl;
      
      /** subList = TestDataFactory.createSubscription(1)[0];
       subList.Zuora__Account__c = acct.Id;
       subList.Is_Active__c = false;
       subList.Zuora__CustomerAccount__c = billingAccount.Id;
       subList.Zuora__SubscriptionEndDate__c = date.Today()+3;
       subList.Term_Length__c = 200.00;
       subList.Zuora__SubscriptionStartDate__c = date.Today();
       subList.Name= 'CS0000000110';
       subList.Number_of_Copies__c= 10;
       subList.Next_Earliest_Start_Date__c= date.today();
       subList.Unique_Address_Id__c= 'asdasdasd';
       subList.Year_to_Date_Temp_Stop_Days__c= 2;
       subList.Previous_Year_Temp_Stop_Days__c= 2;
       subList.Legacy_Create_Date__c='2014-08-07';
       subList.Legacy_Create_By__c='test';
       subList.Legacy_Update_Date__c='test';
       subList.Legacy_Update_By__c='test';
       subList.Legacy_Subscription_ID__c='test';
       subList.Cheque_details__c='test';
       subList.DTL__c='test';
       subList.Paypal_Payment_Profile_Id__c='test';
       subList.Pub_Tag__c='test';
       subList.Subscribe_As__c='test';
       subList.Zuora__SubscriptionEndDate__c= date.today().addDays(5);
       subList.Subscription_Grace_Period_End_Date__c= 'test';
       subList.Gift_ID__c= 'test';
       subList.Redeem_Date__c= 'test';
       subList.Gift_ID_2__c= 'test';
       subList.Redeem_Date_2__c= 'test';
       subList.Subscriber_Contact__c= cont.Id;
       subList.Recipient_Contact__c= cont.Id;
       subList.Subscription_Charge__c= 223.0;
       subList.Term_Length__c= 2;
       subList.Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
       //subList.Order_Line_Item_Number__c = '0123456089';
       //subList.Sponsor_1__c = false;
       //subList.Recipient_Contact__c = cont.Id;
       //subList.Subscription_Charge__c = 100.00;
       //subList.Number_of_Copies__c = 10;    
       insert subList; */
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
                //insert keyId;
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
    
    static testmethod void test() {
    
       prepareTestData();
    
       Test.startTest();  
       BatchAdhocSetSubActiveFlag c = new BatchAdhocSetSubActiveFlag();
       ID batchprocessid = Database.executeBatch(c,200);
       Test.stopTest();
       
       System.assertNotEquals(null, batchprocessid);
       
    }
}