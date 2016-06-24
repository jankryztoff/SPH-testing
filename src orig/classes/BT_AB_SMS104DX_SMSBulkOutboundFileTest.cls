/**
* Class Name: BT_AB_SMS104DX_SMSBulkOutboundFileTest
* Date: 2015/03/11
* @author: Michael Francisco
* @description: This class is the test class for BT_AB_SMS104DX_SMSBulkOutboundFile
* @history:     2015/03/11 - Michael Francisco - Created Apex Test Class    
**/
@isTest (Seealldata = false)
private class BT_AB_SMS104DX_SMSBulkOutboundFileTest {
    
    @testSetup static void prepareTestData(){
    	Key_Id__c keyID = new Key_Id__c();
        keyID.Name = 'SMS104DX Invalid characters';
        keyID.Id__c = '123462697';
        keyID.Type__c = 'Number';
        insert keyID;    
    }
    
    
    private static void createBISEntry() {
        BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.Name = 'Endpoint Delegator';
        bis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert bis;     
    }
    
    private static boolean executeTestBlock() {
        boolean result = false;
        try {
            BT_AB_SMS104DX_SMSBulkOutboundFile sms = new BT_AB_SMS104DX_SMSBulkOutboundFile();
            database.executeBatch(sms,200);
            result = true;
        } catch (Exception e) {
            result = false;         
        }
        return result;
    }
    
    static testmethod void processCurrentSMSRecordsTest() {
        createBISEntry();   
        test.starttest();   
        boolean result = executeTestBlock();
        System.assertEquals(result,true);
        test.stoptest();
    }
    
    static testmethod void processBadSMSRecordTest() {
        createBISEntry();   
        List<SMS_Outbound__c> bad_records = new List<SMS_Outbound__c>();

        //Create a record w/ null Mobile Number 
        SMS_Outbound__c bad_sms_record_1 = new SMS_Outbound__c();
        bad_sms_record_1.Mobile__c = null;
        bad_sms_record_1.SMS_message__c = null;
        bad_sms_record_1.SMS_status__c = 'New';

        //Create a record w/ empty Mobile Number
        SMS_Outbound__c bad_sms_record_2 = new SMS_Outbound__c();
        bad_sms_record_2.Mobile__c = '';
        bad_sms_record_2.SMS_message__c = null;
        bad_sms_record_2.SMS_status__c = 'New';

        //Create a record w/ valid Mobile Number
        SMS_Outbound__c bad_sms_record_3 = new SMS_Outbound__c();
        bad_sms_record_3.Mobile__c = '639209499687';
        bad_sms_record_3.SMS_message__c = null;
        bad_sms_record_3.SMS_status__c = 'New';
        
        //Create a record w/ Empty SMS Message w/ null Mobile Number 
        SMS_Outbound__c bad_sms_record_4 = new SMS_Outbound__c();
        bad_sms_record_4.Mobile__c = null;
        bad_sms_record_4.SMS_message__c = '';
        bad_sms_record_4.SMS_status__c = 'New';

        //Create a record w/ Empty SMS Message w/ empty Mobile Number
        SMS_Outbound__c bad_sms_record_5 = new SMS_Outbound__c();
        bad_sms_record_5.Mobile__c = '';
        bad_sms_record_5.SMS_message__c = '';
        bad_sms_record_5.SMS_status__c = 'New';

        //Create a record w/ Empty SMS Message w/ valid Mobile Number
        SMS_Outbound__c bad_sms_record_6 = new SMS_Outbound__c();
        bad_sms_record_6.Mobile__c = '639209499687';
        bad_sms_record_6.SMS_message__c = '';
        bad_sms_record_6.SMS_status__c = 'New';
        
        //Create a record w/ valid SMS Message w/ null Mobile Number 
        SMS_Outbound__c bad_sms_record_7 = new SMS_Outbound__c();
        bad_sms_record_7.Mobile__c = null;
        bad_sms_record_7.SMS_message__c = '12/03/2015 -Start - New BHS1/BHS (Default>1.00) BHO1 (Default>1) BHT1 (Default>1) and BH/BM (Default>1.00) @224 Chua chu kang Central Building #086-629 direct sub';
        bad_sms_record_7.SMS_status__c = 'New';

        //Create a record w/ valid SMS Message w/ empty Mobile Number
        SMS_Outbound__c bad_sms_record_8 = new SMS_Outbound__c();
        bad_sms_record_8.Mobile__c = '';
        bad_sms_record_8.SMS_message__c = '12/03/2015 -Start - New BHS1/BHS (Default>1.00) BHO1 (Default>1) BHT1 (Default>1) and BH/BM (Default>1.00) @224 Chua chu kang Central Building #086-629 direct sub';
        bad_sms_record_8.SMS_status__c = 'New';
        
        //Add bad records to bad record list ...
        bad_records.add(bad_sms_record_1);
        bad_records.add(bad_sms_record_2);
        bad_records.add(bad_sms_record_3);
        bad_records.add(bad_sms_record_4);
        bad_records.add(bad_sms_record_5);
        bad_records.add(bad_sms_record_6);
        bad_records.add(bad_sms_record_7);
        bad_records.add(bad_sms_record_8);
        
        // insert bad data to SMS_Outbound__c ...
        insert bad_records; 
        
        // run apex class ...
        test.starttest();               
        boolean result = executeTestBlock();
        System.assertEquals(result,true);
        test.stoptest();
    }
    
    static testmethod void processValidSMSRecordTest() {
        createBISEntry();   
        //Create a record w/ valid data
        SMS_Outbound__c good_sms_record = new SMS_Outbound__c();
        good_sms_record.Mobile__c = '639209499687';
        good_sms_record.SMS_message__c = '12/03/2015 -Start - New BHS1/BHS (Default>1.00) BHO1 (Default>1) BHT1 (Default>1) and BH/BM (Default>1.00) @224 Chua chu kang Central Building #086-629 direct sub';
        good_sms_record.SMS_status__c = 'New';
        insert good_sms_record;     
        
        test.starttest();   
        boolean result = executeTestBlock();
        System.assertEquals(result,true);
        test.stoptest();    
    }
}