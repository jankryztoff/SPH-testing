/**
* Class Name: SP_VSSManualCreditBatchTest
* @author: Recuerdo Bregente
* @date: 07/30/2015
* @requirement/Project Name: SPH Project
* @description Batch Apex Class for SP_VSSManualCreditBatch
*/
@isTest(seeAllData=false)
private class SP_PopulateManualCreditNotesTest2{
            
    // Test Data
    static Account acc;
    
    static testMethod void testBatch2Params(){
        prepareTestData();
        Test.StartTest();
        SP_PopulateManualCreditNotes batch = new SP_PopulateManualCreditNotes('SP002',acc.id);
        ID batchprocessid = Database.executeBatch(batch, 200);
        
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
    }
    
    static testMethod void testBatch4Params(){
        prepareTestData();
        Test.StartTest();
        SP_PopulateManualCreditNotes batch = new SP_PopulateManualCreditNotes('SP002',acc.id, Date.today(), Date.Today() + 30);
        ID batchprocessid = Database.executeBatch(batch, 200);
        
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
    }
    
    static void prepareTestData(){
        defaultCustomSetting();
        
        acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Name = 'Test Account';
        acc.Vendor_Group__c = 'A';
        acc.Vendor_Code__c = 'VC001';
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
            
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Postal_Code__c = postal.Id;
        insert address;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = address.Id;
        con.Recipient_Indicator__c = true;
        con.AccountId = acc.Id;
        insert con;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Recipient_Contact__c = con.Id;
        insert order;
        
        RecordType recType = [SELECT Id, Name FROM RecordType WHERE
                            SobjectType = 'Case' AND DeveloperName =:GlobalVariableClass.RT_CASE_START LIMIT 1];
        String recordTypeName = recType.Name;
        List<Case> caseStartAndCOA = TestDataFactory.createCase(1, recordTypeName);
           
        recType = [SELECT Id, Name FROM RecordType WHERE
                            SobjectType = 'Case' AND DeveloperName =:GlobalVariableClass.RT_CASE_COA LIMIT 1];
        recordTypeName = recType.Name;                                   
        
        caseStartAndCOA.add(TestDataFactory.createCase(1, recordTypeName)[0]);
        
        for(Case c : caseStartAndCOA) {
            c.Date_Replaced__c = date.Today()+1;
            c.AccountId = acc.Id;
            c.Order__c = order.Id;
            c.Rejected_Renewal__c = true;   
            c.Category__c = 'Subscription Request';
            c.Sub_Category__c = 'Start Subscription'; 
            c.Vendor_Subscription_Created__c = false; 
            c.Address__c = 'Makati City';   
            c.Contact_To_Update__c = con.Id; 
            c.Within_Circulation_Planning_Schedule__c = true;
        }
        
        insert caseStartAndCOA;
        
        Publication__c testPublication = TestDataFactory.createPublication(1)[0];
        testPublication.Publication_Code__c = 'BH';        
        insert testPublication;
        
        
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       billAcc.Zuora__Account__c = acc.Id;
       billAcc.Zuora__Credit_Balance__c = 50000.00;
       billAcc.Billing_Type__c= 'Full Prepaid';
       database.insert(billAcc);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Generate_Invoice1__c = 'false';
        insert subRecs;
        
        List<Case_Subscription__c>  caseSubs = new List<Case_Subscription__c>();
        caseSubs.add(new Case_Subscription__c());
        caseSubs.add(new Case_Subscription__c());
        
        for(Case_Subscription__c caseSub : caseSubs) {
            caseSub.Account__c = acc.Id;
            caseSub.Address__c = address.Id;
            caseSub.Subscription__c = subRecs.Id;
        }
        caseSubs[0].Case__c = caseStartAndCOA[0].Id;
        caseSubs[1].Case__c = caseStartAndCOA[1].Id;
         
        insert caseSubs;

        
        List<Manual_Vendor_Credits_Debits__c> mvcds = new List<Manual_Vendor_Credits_Debits__c>();
        mvcds.add(new Manual_Vendor_Credits_Debits__c());
        mvcds.add(new Manual_Vendor_Credits_Debits__c());
        
        for(Manual_Vendor_Credits_Debits__c mvcd : mvcds) {
            mvcd.Vendor__c = acc.Id;
            mvcd.Publication__c = testPublication.Id;
            mvcd.Credit_Debit_Vendor_Reason__c = '01'; 
            mvcd.Credit_Debit_Indicator__c = 'C';
            mvcd.Remarks__c = 'Remarks';
            mvcd.Amt_After_GST__c = 100;
            mvcd.Approval_Date__c = date.today();
            mvcd.Status__c = 'Approved';
            mvcd.Subscription__c = subRecs.id;

            
        }
        mvcds[0].Case__c = caseStartAndCOA[0].Id;
        mvcds[1].Case__c = caseStartAndCOA[1].Id; 
        
        insert mvcds;
        
        VDC_CREDITNOTE__c vdc = new VDC_CREDITNOTE__c();
        vdc.Vendor_Number__c =  'VC001';
        vdc.Reason_Code_Category__c = '01';
        vdc.Credit_Debit_Indicator__c = 'C';
        vdc.Credit_Note_Number__c = 123;
        insert vdc;
    }

    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        //Key_Id__c keyId;
        Other__c otherC;
        /*
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
        */
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
        
    }

}