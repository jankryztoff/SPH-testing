/**
Class Name: BT_AB_REW040DX_SubscriberRewardsIntTest
@author: Accenture IDC (Sudha Kumari)
Date: 02/11/2015
Project/Requirement: SPH Integration - ARM063DX Interface 
@description This class is test class for BT_AB_REW040DX_SubscriberRewardsIntFile
**/
@isTest (Seealldata = false)
private class BT_AB_REW040DX_SubscriberRewardsIntTest{
   
    static testMethod void unitTest1(){
        defaultcustomsetting();
        String recordTypeID = ConstantsSLB.getKeyId('Account_Direct Individual');
        Set<String> productCodeSet = new Set<String>();
         
       /* BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator1';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;   */
        
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        accounts[0].AccountNumber = 'TestAcctNum';
        accounts[0].Date_Of_Birth__c = date.Today().addDays(20);
        accounts[0].Name = 'TestName';
        accounts[0].NRIC__c = 'T1234567R';
        accounts[0].Phone = '444123123';
        accounts[0].Email__c = 'xxxx@xxxx.com';
        insert accounts;
        
        List<Contact> contactList = TestDataFactory.createContact(1);
           for(Contact obj : contactList ) {
            obj.Account = accounts[0];
            
        }
        insert contactList;  
        
     
         Zuora__CustomerAccount__c ba = TestDataFactory.createBillingAccount(1)[0];
         ba.Name = 'Test';
         ba.Zuora__Account__c = accounts[0].Id;
         ba.Zuora__AccountNumber__c = 'TestAcctNum';
         ba.Billing_Type__c = 'Full Prepaid'; 
         insert ba;
        
        zqu__ZProduct__c zp = new zqu__ZProduct__c();
        zp.name = 'asdd';
        zp.zqu__ZuoraId__c = 'fgfdg';
        zp.zqu__Deleted__c = false;
        zp.zqu__SKU__c = 'dgsd';
        zp.ProductType__c = 'dsfdsf';
        zp.ProductCode__c = 'sdgfsd';
        zp.ProductSubType__c = 'Newspaper';
        
        insert zp; 
          
                
        test.StartTest();
        BT_AB_REW040DX_SubscriberRewardsIntFile batch = new BT_AB_REW040DX_SubscriberRewardsIntFile();
        ID batchprocessid = Database.executeBatch(batch,200);
        test.StopTest();
    }//end of unitTest1
    
    
    static testMethod void unitTest2(){
      defaultcustomsetting();
      
        Integer count = 0;
        String exportData = 'Test';
        
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
        
                
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        for(BA_INT_DATA_POOL__c datapoolRecord : datapoolList){
            datapoolRecord.Name = 'REW040DX';
            datapoolRecord.job_id__c = '1';
            datapoolRecord.group_id__c = 'Detail';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;                            
        }
         
        insert datapoolList;
        system.assertNotEquals(null, datapoolList.size());
        
        List<Account> accountList = TestDataFactory.createAccount(1, 'Direct Corporate');
        count = 0;
        for(Account obj : accountList ) {
        obj.AccountNumber = 'TestAcctNum';
        obj.Date_Of_Birth__c = date.Today().addDays(20);
        obj.Name = 'TestName';
        obj.NRIC__c = 'T1234567R';
        obj.Phone = '444123123';
        obj.Email__c = 'xxxx@xxxx.com';
        count++;
        }
        insert accountList;
        
        //Singpost Address
        List<Singpost_Address__c> singpostAddressList = TestDataFactory.createSingpostAddress(1);
        singpostAddressList[0].Name = 'TestName';
        singpostAddressList[0].Building_Name__c = 'New Liberty';
        insert singpostAddressList;
        
        //Address
        List<Address__c> addressList = TestDataFactory.createAddress(1);
        addressList[0].Postal_Code__c = singpostAddressList[0].id;
        addressList[0].Address_Unique_ID__c = 'TestName';
        insert addressList;
        
        List<Contact> contactList = TestDataFactory.createContact(1);
        contactList[0].Account = accountList[0]; 
        insert contactList;  
        
        system.assertNotEquals(0,contactList.size());
        
         Zuora__CustomerAccount__c ba = TestDataFactory.createBillingAccount(1)[0];
         ba.Name = 'Test';
         ba.Zuora__Account__c = accountList[0].Id;
         ba.Zuora__AccountNumber__c = 'TestAcctNum';
         ba.Billing_Type__c = 'Full Prepaid'; 
         insert ba;
         
           List<Zuora__Subscription__c> zuoraSubscriptionList = TestDataFactory.createSubscription(1);
            zuoraSubscriptionList[0].Zuora__Account__c = accountList[0].id;
            zuoraSubscriptionList[0].Name= 'CS0000000110';
            zuoraSubscriptionList[0].Number_of_Copies__c= 10;
            zuoraSubscriptionList[0].Zuora__CustomerAccount__c = ba.id;
            zuoraSubscriptionList[0].Next_Earliest_Start_Date__c= date.today();
            zuoraSubscriptionList[0].Unique_Address_Id__c= 'asdasdasd';
            zuoraSubscriptionList[0].Year_to_Date_Temp_Stop_Days__c= 2;
            zuoraSubscriptionList[0].Previous_Year_Temp_Stop_Days__c= 2;
            zuoraSubscriptionList[0].Legacy_Create_Date__c='2014-08-07';
            zuoraSubscriptionList[0].Legacy_Create_By__c='test';
            zuoraSubscriptionList[0].Legacy_Update_Date__c='test';
            zuoraSubscriptionList[0].Legacy_Update_By__c='test';
            zuoraSubscriptionList[0].Legacy_Subscription_ID__c='test';
            zuoraSubscriptionList[0].Cheque_details__c='test';
            zuoraSubscriptionList[0].DTL__c='test';
            zuoraSubscriptionList[0].Paypal_Payment_Profile_Id__c='test';
            zuoraSubscriptionList[0].Pub_Tag__c='test';
            zuoraSubscriptionList[0].Subscribe_As__c='test';
            zuoraSubscriptionList[0].Zuora__SubscriptionEndDate__c= date.today().addDays(5);
            zuoraSubscriptionList[0].Subscription_Grace_Period_End_Date__c= 'test';
            zuoraSubscriptionList[0].Gift_ID__c= 'test';
            zuoraSubscriptionList[0].Redeem_Date__c= 'test';
            zuoraSubscriptionList[0].Gift_ID_2__c= 'test';
            zuoraSubscriptionList[0].Redeem_Date_2__c= 'test';
            zuoraSubscriptionList[0].Subscriber_Contact__c= contactList[0].Id;
            zuoraSubscriptionList[0].Recipient_Contact__c= contactList[0].Id;
            zuoraSubscriptionList[0].Subscription_Charge__c= 223.0;
            zuoraSubscriptionList[0].Term_Length__c= 2;
            zuoraSubscriptionList[0].Product_Code__c = 'Test';
            zuoraSubscriptionList[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
            insert zuoraSubscriptionList;
           
            //List<Zuora__Subscription__c> se = [SELECT Subscriber_Contact__r.ID from Zuora__Subscription__c where ID =: zuoraSubscriptionList[0].Id];
            List<Zuora__Subscription__c> se = [SELECT Zuora__Account__c, Subscriber_Contact__c, Zuora__SubscriptionEndDate__c, ID,  Product_Code__c FROM  Zuora__Subscription__c 
               WHERE id =: zuoraSubscriptionList[0].id];
           // system.AssertEquals('', se[0].Subscriber_Contact__r.ID + '');
            List<Asia1__c> zAsia1List = new List<Asia1__c>();
            Asia1__c a1 = new  Asia1__c();
            a1.Contact__c = contactList[0].id;
            a1.Display_Name__c = 'TestName';
            a1.Password__c = 'Password123';
            a1.User_ID_LDAP_ID__c = 'xxxx@xxxx.com';
        
            zAsia1List.add(a1);
            insert zAsia1List;
            
            String zCustomerName = zuoraSubscriptionList[0].Zuora__Account__r.Name;
            String zNRICPassport = zuoraSubscriptionList[0].Zuora__Account__r.NRIC__c;
            String zBirthDate = String.valueOf(zuoraSubscriptionList[0].Zuora__Account__r.Date_Of_Birth__c);
            String zTelephoneNumber = zuoraSubscriptionList[0].Zuora__Account__r.Phone;
            String zEmailID = zuoraSubscriptionList[0].Zuora__Account__r.Email__c;
            String zExpiryDate = String.valueOf(zuoraSubscriptionList[0].Zuora__SubscriptionEndDate__c);
            String zSubscriberID = zuoraSubscriptionList[0].Zuora__Account__r.AccountNumber;
            String zPostalCode = zuoraSubscriptionList[0].Subscriber_Contact__r.Address__r.Postal_Code__r.Name;    
            String zCRSMAccountNumber = zuoraSubscriptionList[0].Zuora__Account__r.Account_Auto_Number__c; 
            
            
            List<String> exportDataList = new List<String>();
            exportDataList.add(zuoraSubscriptionList[0].Zuora__Account__r.Name);
            exportDataList.add(zuoraSubscriptionList[0].Zuora__Account__r.NRIC__c);
            exportDataList.add(String.valueOf(zuoraSubscriptionList[0].Zuora__Account__r.Date_Of_Birth__c));
            exportDataList.add(zuoraSubscriptionList[0].Zuora__Account__r.Phone);
            exportDataList.add(zuoraSubscriptionList[0].Zuora__Account__r.Email__c);
            exportDataList.add(String.valueOf(zuoraSubscriptionList[0].Zuora__SubscriptionEndDate__c));
            exportDataList.add(zuoraSubscriptionList[0].Zuora__Account__r.AccountNumber);
            exportDataList.add(zuoraSubscriptionList[0].Subscriber_Contact__r.Address__r.Postal_Code__r.Name);
            exportDataList.add(zuoraSubscriptionList[0].Zuora__Account__r.Account_Auto_Number__c);
            
            Map<ID, Zuora__Subscription__c> mContactSubscription = new Map<ID, Zuora__Subscription__c>();
            mContactSubscription.put(contactList[0].Id, zuoraSubscriptionList[0]);
            
            Set<ID> zContactSet = new Set<ID>();
            zContactSet = mContactSubscription.keySet();
            system.assertNotEquals(null, zContactSet.size());

        Database.BatchableContext BC;
        test.StartTest();
        BT_AB_REW040DX_SubscriberRewardsIntFile batch = new BT_AB_REW040DX_SubscriberRewardsIntFile();
        ID batchprocessid = Database.executeBatch(batch,200);
        batch.execute(BC, zuoraSubscriptionList);
        batch.finish(BC);
        test.StopTest();
    }//end of unitTest2
    
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