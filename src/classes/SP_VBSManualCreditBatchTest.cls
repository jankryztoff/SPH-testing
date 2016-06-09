@isTest (seeAllData= false)
public class SP_VBSManualCreditBatchTest {

    private static Account accountDummy;
    //private static BT_CO_VSS_CreditDebit__c vssCreditDebit;
    
    private static void setAccount() {
        defaultCustomSetting();
        RecordType rtype = [Select Name, Id 
                                   from RecordType 
                                   where sObjectType='Account' 
                                    and Name='Vendor' 
                                    and isActive=true
                                    limit 1];
        
        accountDummy = new Account(Name = 'Test', recordTypeId = rtype.Id);
        accountDummy.Vendor_Code__c = '12345';
        accountDummy.Active__c = true;
        
        insert accountDummy;
        
    }
    
    private static void setVSSCreditDebit(boolean isCredit) {
        
        defaultCustomSetting();
        BT_CO_VSS_CreditDebit__c vssCreditDebit = new BT_CO_VSS_CreditDebit__c();        
        vssCreditDebit.Vendor_Group__c = 'a';
        vssCreditDebit.Publication_Code__c = '1122';
        vssCreditDebit.Posting_Date__c = (System.now()).date();  
        vssCreditDebit.Vendor_Number__c = '12345';
                                         
        vssCreditDebit.Manual_Amt__c = 100;        
        if(isCredit) {
            vssCreditDebit.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;            
        } else {
            vssCreditDebit.Credit_Debit__c = GlobalVariableClass.DEBIT_IND;           
        }
        
        System.debug('vssCreditDebit.Vendor_Group__c: ' + vssCreditDebit.Vendor_Group__c);
        System.debug('vssCreditDebit.Publication_Code__c: ' + vssCreditDebit.Publication_Code__c);
        System.debug('vssCreditDebit.Posting_Date__c: ' + vssCreditDebit.Posting_Date__c);
        System.debug('vssCreditDebit.Manual_Amt__c: ' + vssCreditDebit.Manual_Amt__c);
        System.debug('vssCreditDebit.Vendor_Number__c: ' + vssCreditDebit.Vendor_Number__c);
        System.debug('vssCreditDebit.Credit_Debit__c: ' + vssCreditDebit.Credit_Debit__c);
        
        insert vssCreditDebit;
    }
    
    
    static testMethod void executeTest() {
        
        defaultCustomSetting();
        System.debug('executeTest start');
        
        setAccount();
        setVSSCreditDebit(true);
        setVSSCreditDebit(false);
        boolean errorExist = false;
        try {        
            Test.startTest();
                SP_VBSManualCreditBatch batch = new SP_VBSManualCreditBatch(accountDummy.Id);
                ID batchProcessId = Database.executeBatch(batch, 200);
                System.debug('executeTest mid');
            Test.stopTest();            
        } catch(Zuora.zRemoteException e) {
            System.debug('zRemoteException: ' + e);
            errorExist = true;
        }
        System.assertEquals(false, errorExist, 'Batch execution successful. No error has occurred');
        System.debug('executeTest end');
    }
    
     static testMethod void executeTest2() {
        
        defaultCustomSetting();
        System.debug('executeTest start');
        
        setAccount();
        setVSSCreditDebit(true);
        setVSSCreditDebit(false);
        boolean errorExist = false;
        try {        
            Test.startTest();
                SP_VBSManualCreditBatch batch = new SP_VBSManualCreditBatch(accountDummy.Id, date.Today(), date.Today());
                ID batchProcessId = Database.executeBatch(batch, 200);
                System.debug('executeTest mid');
            Test.stopTest();            
        } catch(Zuora.zRemoteException e) {
            System.debug('zRemoteException: ' + e);
            errorExist = true;
        }
        System.assertEquals(false, errorExist, 'Batch execution successful. No error has occurred');
        System.debug('executeTest end');
    }
    
    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        
        String[] orderCNameArray = new String[]{'GST'/*'Order_Type COS_Package'*/,'Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;
        
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
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c();
        delType.Name = 'A';
        delType.Default_Delivery_Charge_Type__c = 'C';
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c();
        delCharge.Name ='AC';
        delCharge.Vendor_Credit__c = 9.00;
        delCharge.Subscriber_Charge__c = 9.00;
        insert delCharge;
    }
}