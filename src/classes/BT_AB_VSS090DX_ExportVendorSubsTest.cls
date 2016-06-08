/**
 * Class Name: BT_AB_VSS090DX_ExportVendorSubsTest     
 * @author: Accenture IDC - Nilesh    
 * Date: 13 Feb 2015    
 * Requirement/Project Name: SPH Project    
 * @description Test Class for BT_AB_VSS090DX_ExportVendorSubscription    
 */
@isTest 
public class BT_AB_VSS090DX_ExportVendorSubsTest {
  
  
        @testSetup 
        static void setupData() {
            insert CustomSettingsDataFactory.createKey_Id();
            insert CustomSettingsDataFactory.createOther(); 
            insert CustomSettingsDataFactory.createIntegration_Settings();
            insert CustomSettingsDataFactory.createBatchInterface(); 
            insert CustomSettingsDataFactory.createPlannerSched();
            //Cir_Planner_Schedule__c cirPlannerSchdule = Cir_Planner_Schedule__c.getInstance('CIR Plan Schedule'); 
            //system.assertequals(cirPlannerSchdule, null);
        } 
  
      /*static testmethod void unitTest1() {                 
                BT_AB_VSS090DX_ExportVendorSubscription batch = new BT_AB_VSS090DX_ExportVendorSubscription();
                ID batchprocessid = Database.executeBatch(batch,200);
                System.assertNotEquals(null, batchprocessid);
      } */ 
      
       public static void TestexecutesveRecordIsNull(){
              /*  String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
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
                insert batchInterfaceSetting;*/
       
        try {
                Test.setMock(WebServiceMock.class, new zLoginMock());
        
                Account testAccount = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                testAccount.NRIC__c = 'T1234567R';
                insert testAccount;
                
                Contact testContact = TestDataFactory.createContactRecType(1, 'Vendor Contact')[0];
                insert testContact;
                
                Subscription_Vendor__c testSubscriptionVendor = TestDataFactory.createSubscriptionVendor(1)[0];
                testSubscriptionVendor.Account__c = testAccount.id;
                testSubscriptionVendor.Recipient__c = testContact.id;
                insert testSubscriptionVendor;
                
                Publication__c testPublication = TestDataFactory.createPublication(1)[0];
                testPublication.Publication_Code__c = 'BH';
                testPublication.Published_Days__c = 'YYYYYYY';
                testPublication.Publication_Type__c = 'N';
                testPublication.Platform_Type__c = 'Print';        
                insert testPublication;
                
                Subscription_Vendor_Publication__c testSubscriptionVendorPublication = TestDataFactory.createVendorPublication(1)[0];
                testSubscriptionVendorPublication.Subscription_Vendor__c = null;
                testSubscriptionVendorPublication.Account__c = testAccount.id;
                testSubscriptionVendorPublication.Publication__c = testPublication.id;
       /*         testSubscriptionVendorPublication.Mon__c = 1;
                testSubscriptionVendorPublication.Tue__c = 1;
                testSubscriptionVendorPublication.Wed__c = 1;
                testSubscriptionVendorPublication.Thu__c = 1;
                testSubscriptionVendorPublication.Fri__c = 1;
                testSubscriptionVendorPublication.Sat__c = 1;
                testSubscriptionVendorPublication.Sun__c = 1;
                testSubscriptionVendorPublication.PHd__c = 1;
                testSubscriptionVendorPublication.PHe__c = 1; */
                insert testSubscriptionVendorPublication;
                
                Map<String, SObject> sobjectMap =  TestDataFactory.createSubscriptionPackage();
            
                RecordType testRecordType = [SELECT id FROM RecordType WHERE Name='Temp_Stop_Subscription' LIMIT 1];
                //testRecordType.DeveloperName = 'Start_Subscription';
                
                List<Temp_Stop__c> tempStopList = TestDataFactory.createTempStop(1);
                tempStopList[0].Temp_Stop_Date__c = date.Today() +10;
                tempStopList[0].Restart_Date__c = date.Today() +30;
                insert tempStopList;
                
                Case testCase = (Case) sobjectMap.get('Case');
                testCase.Status = 'Closed';
                testCase.Temp_Stop_Date__c = date.Today() +10;
                testCase.Restart_Date__c = date.Today() +30;
                testCase.Temp_Stop_Type__c = 'Cancel';
                testCase.Temp_Stop__c = tempStopList[0].id;
                testCase.Publication__c = testPublication.id;
                testCase.RecordTypeId = testRecordType.id;
                insert testCase;
    
                
                Case_Vendor_Subscription__c testCaseVendorSubscription = TestDataFactory.createCaseVendorSub(1)[0];
                testCaseVendorSubscription.Account__c = testAccount.id;
                testCaseVendorSubscription.Case__c = testCase.id;
                testCaseVendorSubscription.Subscription_Vendor__c = testSubscriptionVendor.id;
                insert testCaseVendorSubscription;
                
                Test.StartTest();
                BT_AB_VSS090DX_ExportVendorSubscription batch = new BT_AB_VSS090DX_ExportVendorSubscription();
                Database.executeBatch(batch, 100);
                Test.StopTest(); 
                
       } catch(Zuora.zRemoteException e){ }          
    }
    static testmethod void testzEffectiveIssueDateCheckisFalse(){
      /*  BT_AB_VSS090DX_ExportVendorSubscription batch = new BT_AB_VSS090DX_ExportVendorSubscription();
        ID batchprocessid = Database.executeBatch(batch,200);
        System.assertNotEquals(null, batchprocessid);*/
        
       /* String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
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
        }*/
        
        /*Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
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
        insert batchInterfaceSetting;*/
        
       try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
    
            Account testAccount = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            testAccount.NRIC__c = 'T1234567R';
            insert testAccount;
            
            Contact testContact = TestDataFactory.createContactRecType(1, 'Vendor Contact')[0];
            insert testContact;
            
            Subscription_Vendor__c testSubscriptionVendor = TestDataFactory.createSubscriptionVendor(1)[0];
            testSubscriptionVendor.Account__c = testAccount.id;
            testSubscriptionVendor.Recipient__c = testContact.id;
            testSubscriptionVendor.Subscription_Stop_Date__c = date.today()+1;
            testSubscriptionVendor.Subscription_Start_Date__c = date.Today();
            insert testSubscriptionVendor;
            
            List<Temp_Stop__c> tempStopList = TestDataFactory.createTempStop(1);
            tempStopList[0].Temp_Stop_Date__c = date.today();
            tempStopList[0].Restart_Date__c = date.today()+1;
            insert tempStopList;
            
          /*  Recordtype rectype = [SELECT Id, DeveloperName from Recordtype WHERE sObjectType = 'Case' AND DeveloperName = 'Temp_Stop_Subscription'];
            Case caseNew = new Case(); 
            caseNew.Temp_Stop__c = null; //tempStopList[0].id;
            caseNew.Recordtypeid = rectype.id;        
            caseNew.Stop_Request_Date__c = null;
            insert caseNew;*/
            
            Publication__c testPublication = TestDataFactory.createPublication(1)[0];
            testPublication.Publication_Code__c = 'BH';
            testPublication.Published_Days__c = 'YYYYYYY';
            testPublication.Publication_Type__c = 'N';
            testPublication.Platform_Type__c = 'Print';        
            insert testPublication;
             
            Subscription_Vendor_Publication__c testSubscriptionVendorPublication = new Subscription_Vendor_Publication__c();//  TestDataFactory.createVendorPublication(1)[0];
            testSubscriptionVendorPublication.Subscription_Vendor__c = testSubscriptionVendor.id;
            testSubscriptionVendorPublication.Account__c = testAccount.id;
            testSubscriptionVendorPublication.Publication__c = testPublication.id;
            testSubscriptionVendorPublication.Mon__c = null;
            testSubscriptionVendorPublication.Tue__c = null;
            testSubscriptionVendorPublication.Wed__c = null;
            testSubscriptionVendorPublication.Thu__c = null;
            testSubscriptionVendorPublication.Fri__c = null;
            testSubscriptionVendorPublication.Sat__c = null;
            testSubscriptionVendorPublication.Sun__c = null;
            testSubscriptionVendorPublication.PHd__c = null;
            testSubscriptionVendorPublication.PHe__c = null;
            insert testSubscriptionVendorPublication;
            
           // Map<String, SObject> sobjectMap =  TestDataFactory.createSubscriptionPackage();
        
            //RecordType testRecordType = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName = 'Stop_Subscription' LIMIT 1];
            //testRecordType.DeveloperName = 'Start_Subscription';
            
           
          
           /* Case testCase = (Case) sobjectMap.get('Case');
            testCase.Status = 'Closed';
            testCase.Temp_Stop_Date__c = date.Today() +30;
            testCase.Restart_Date__c = date.Today() +10;
            testCase.Temp_Stop_Type__c = 'Cancel';
            testCase.Temp_Stop__c = tempStopList[0].id;
            testCase.Publication__c = testPublication.id;
            testCase.RecordTypeId = testRecordType.id;
            insert testCase;
            
            Recordtype rectype = [SELECT Id, DeveloperName from Recordtype WHERE sObjectType = 'Case' AND DeveloperName = 'Temp_Stop_Subscription'];
            Case caseNew = new Case(); 
            caseNew.Recordtypeid = rectype.id;        
            insert caseNew;

            */
            RecordType testRecordType = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName='Temp_Stop_Subscription' LIMIT 1];
            Case testCase = new Case();
            testCase.Status = 'Closed';
            testCase.Sub_Status__c = 'Temp Stop Approved';
            testCase.Temp_Stop_Date__c = date.today();
            testCase.Restart_Date__c = date.today()+1;
            testCase.Temp_Stop_Type__c = 'Cancel';
            testCase.Temp_Stop__c = tempStopList[0].id;
            testCase.Publication__c = testPublication.id;
            testCase.RecordTypeId = testRecordType.id;
            testCase.Stop_Request_Date__c = date.Today()+1;
            insert testCase;
             
            Case_Vendor_Subscription__c testCaseVendorSubscription = TestDataFactory.createCaseVendorSub(1)[0];
            testCaseVendorSubscription.Account__c = testAccount.id;
            testCaseVendorSubscription.Case__c = testCase.id;
            testCaseVendorSubscription.Subscription_Vendor__c = testSubscriptionVendor.id;
            insert testCaseVendorSubscription;
            
            BT_CO_Batch_Run_Request__c batchRequestRun = new BT_CO_Batch_Run_Request__c();
            batchRequestRun.Interface_ID__c = 'VSS090DX';
            batchRequestRun.End_Time__c = date.today();
            batchRequestRun.Batch_Run_Date__c = date.today();
            insert batchRequestRun;
            
            BT_CS_Interface_Field_Validation__c interfaceValidation = new BT_CS_Interface_Field_Validation__c();
            interfaceValidation.Error_Message__c = 'sample error';
            interfaceValidation.Name = 'VSS090DX';
            interfaceValidation.Field_ID__c = 1234;
            interfaceValidation.Field_Name__c = 'Field_Name__c';
            insert interfaceValidation;
            
            Test.StartTest();
            BT_AB_VSS090DX_ExportVendorSubscription batch = new BT_AB_VSS090DX_ExportVendorSubscription();
            Database.executeBatch(batch, 100);
            Test.StopTest(); 
        
       } catch(Zuora.zRemoteException e){ }     
    }
     
    

}