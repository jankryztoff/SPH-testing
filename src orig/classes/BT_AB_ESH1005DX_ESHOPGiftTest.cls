@isTest 
public class BT_AB_ESH1005DX_ESHOPGiftTest {

        static testMethod void unitTest1() {
            
            Key_Id__c keyId = new Key_Id__c();
            keyId.Name = 'UpdateARMSInfoResultId';
            keyId.Id__c = '123vd';
            //Type__c = 'ID';
            insert keyId;
            
            BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
            bs.Name = 'Endpoint Delegator';
            bs.Value__c = 'http://tstcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
            insert bs;
            
            Other__c testOther = new Other__c();
            testOther.Name = 'LOG_DEBUG_ON';
            testOther.Value__c = 'TRUE';
        	insert testOther;  
        
            bt_int_param_config__c paramConfig = new bt_int_param_config__c();
            paramConfig.field_name__c = 'Publication_Code__c';
            paramConfig.from_object__c = 'Product_Publication__c';
            paramConfig.interface_name__c = 'ESH1005DX';
            paramConfig.field_sequence__c = 10;
            paramConfig.postOpFieldName__c = 'Field Name';
            database.insert(paramConfig);
        
            BA_INT_DATA_POOL__c datapoolHRecord = new BA_INT_DATA_POOL__c(); 
            datapoolHRecord.name = 'DatabaseBatchable'; 
            datapoolHRecord.job_id__c = 'DatabaseBatchable'; 
            datapoolHRecord.group_id__c = 'Master'; 
            datapoolHRecord.run_for_date__c = Date.today(); 
            datapoolHRecord.insert_time__c = DateTime.now(); 
            datapoolHRecord.export_data__c = 'H'; 
            
            insert datapoolHRecord; 
            
            Test.StartTest(); 
            BT_AB_ESH1005DX_ESHOPGift batch = new BT_AB_ESH1005DX_ESHOPGift('ESH1005DX');
            ID batchprocessid = Database.executeBatch(batch, 200);
            Test.StopTest();
        }
}