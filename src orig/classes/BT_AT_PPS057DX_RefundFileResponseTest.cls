/**
  * Class Name: BT_AT_PPS057DX_RefundFileResponseTest
  * @author: Accenture IDC - Nilesh
  * Date: 12 Feb 2015
  * Requirement/Project Name: SPH Project
  * @description Test Class for BT_AT_PPS057DX_RefundFileResponse
  * 
  */
@isTest (SeeAllData = false)
public class BT_AT_PPS057DX_RefundFileResponseTest {  
    
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName){
       //Generate a map of tokens for all the Record Types for the desired object
       Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

       //Retrieve the record type id by name
       return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }

    static testMethod void insertRecords(){
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        List<Other__c> otherList = new List<Other__c>();

        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual',
                                               'Account_Vendor Subscriber',
                                               'Address_Local',
                                               'Contact_Customer Contact',
                                               'Package Item_Base Product',
                                               'Package Item_Bundle Product',
                                               'Package Item_Discount',
                                               'Package Item_Extension Discount',
                                               'UpdateARMSInfoResultId',
                                               'Account_Direct Corporate',
                                               'Account_Direct SPH Inter-Division',
                                               'Case_Change of Subscription',
                                               'Case_Start Sub','Case_Stop',
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
                                               'SubTypePub',
                                               'Address_Airline',
                                               'Address_Internal',
                                               'Address_Overseas'};
        String[] keyIdIdArray = new String[]{'012N00000008ic1IAA',
                                             '012N00000008ibwIAA',
                                             '012N00000008idiIAA',
                                             '012N00000008r43IAA',
                                             '012N00000008jCOIAY',
                                             '012N00000008jCdIAI',
                                             '012N00000008jCTIAY',
                                             '012N00000008jCsIAI',
                                             '123vd',
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
                                             'Delivery',
                                             'Postage',
                                             'Publication',
                                             '012N00000008idx',
                                             '012N00000008idnIAA'};
        String[] keyIdTypeArray = new String[]{'RecordType',
                                               'Name',
                                               'Field',
                                               'Case Team Role',
                                               'Number',
                                               'Id',
                                               'Boolean',
                                               'Number of Months',
                                               'BillingAccountFieldID',
                                               'Vendor Credit',
                                               'Queue',
                                               'Zuora Id',
                                               'ZuoraPaymentMethodId',
                                               'ID',
                                               'Integer',
                                               'Record',
                                               'Delivery Charge Type',
                                               'Delivery Charge',
                                               'Profile',
                                               'Vendor or Mailing Agent',
                                               'Vendor or Mailing Agent',
                                               'Vendor or Mailing Agent',
                                               'Vendor or Mailing Agent',
                                               'Vendor or Mailing Agent',
                                               'Vendor or Mailing Agent',
                                               'Vendor or Mailing Agent',
                                               'Vendor or Mailing Agent',
                                               'PaymentMethodId'};

        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ ){
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        
        String[] orderNameArray = new String[]{'Order_Type COS_Package',
                                               'Order_Type COS_Quantity',
                                               'Order_Type Renewal',
                                               'Order_Type Start',
                                               'Order_Type Stop',
                                               'Product_Category AIO',
                                               'Product_Category Digital',
                                               'Product_Category Magazine',
                                               'Product_Category Print',
                                               'DTL',
                                               'ARMS_AccTyp',
                                               'ARMS_SysId',
                                               'ARMS_userID',
                                               'ARMS_password'};
        String[] orderValueArray = new String[]{'TRUE',
                                                'Change of Subscription Package',
                                                'Change of Subscription Quantity',
                                                'Renewal',
                                                'Start',
                                                'Stop',
                                                'All in One (AIO)',
                                                'Digital',
                                                'Magazine',
                                                'Print', 
                                                '23:59',
                                                'SS',
                                                'Username',
                                                'Password'};
       
        for(Integer i = 0 ; i < orderNameArray.size(); i++ ){
            otherC = new Other__c();
            otherC.Name = orderNameArray[i];
            otherC.Value__c = orderValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;

        List<BT_CO_PPS_RefundFileResponse__c> refFileList = new List<BT_CO_PPS_RefundFileResponse__c>();
        BT_CO_PPS_RefundFileResponse__c testRefundFileResponse1 = new BT_CO_PPS_RefundFileResponse__c(Name = 'Test data 1',
                                                                                                      CustomerACNumber__c = '31397728',
                                                                                                      PaymentAmount__c = '11',
                                                                                                      CustomerAccount__c = 'PPS057DX');
        
        BT_CO_PPS_RefundFileResponse__c testRefundFileResponse2 = new BT_CO_PPS_RefundFileResponse__c(Name = 'Test data 1',
                                                                                                      CustomerACNumber__c = '31397721',
                                                                                                      PaymentAmount__c = '10',
                                                                                                      CustomerAccount__c = 'PPS057DX');
        
        BT_CO_PPS_RefundFileResponse__c testRefundFileResponse3 = new BT_CO_PPS_RefundFileResponse__c(Name = 'Test data 1',
                                                                                                      CustomerACNumber__c = '31397725',
                                                                                                      PaymentAmount__c = '20',
                                                                                                      CustomerAccount__c = 'PPS057DX');
        refFileList.add(testRefundFileResponse1);
        refFileList.add(testRefundFileResponse2); 
        refFileList.add(testRefundFileResponse3); 
        insert refFileList;
        System.debug('\n\n\n TEST CLASS refFileList '+refFileList+'\n\n');

        Account acc = new Account(Name = 'Test Account',
                                  RecordTypeId = getObjectRecordTypeId(Account.SObjectType,'Direct Corporate'),
                                  Email__c = 'sample@email.com',
                                  Mobile__c = '1234567',
                                  AccountNumber = '31397728');
        insert acc;
        System.debug('\n\n\n TEST CLASS acc '+acc+'\n\n');

        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c(Name = 'Test Billing Account',
                                                                          Zuora__Account__c = acc.id,
                                                                          Zuora__Status__c = 'Active');
        insert billAcc;
        System.debug('\n\n\n TEST CLASS billAcc '+billAcc+'\n\n');

        Zuora__Refund__c refundRecord = new Zuora__Refund__c(Name = 'Test Refund', 
                                                             Zuora__Amount__c = 100.00,
                                                             Zuora__Account__c = acc.Id,
                                                             Zuora__BillingAccount__c = billAcc.Id,
                                                             Status__c = 'Status',
                                                             Cheque_Cut_Date__c = '10/10/1990',
                                                             Approval_Date__c = '10/11/1990',
                                                             Handled_by_Who__c = 'Robby',
                                                             Clearance_Date__c = '10/13/1990',
                                                             Cheque_Number__c = '123124',
                                                             Payee__c = 'Von',
                                                             Payment_Amount__c = 1234);
        insert refundRecord;
        System.debug('\n\n\n TEST CLASS refundRecord '+refundRecord+'\n\n');
    }
}