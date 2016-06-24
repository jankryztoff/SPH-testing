@isTest
private class BatchJobHelperTest2{
    static testMethod void testBatchJobHelper(){
        Set<Id> extPaymentIds = new Set<Id>();
        List<sObject> lstRecords = new List<sObject>();
        Exception error;
        
        //start custom settings
        BatchInterface_Settings__c integ = new BatchInterface_Settings__c();
        integ.Name = 'Endpoint Delegator';
        integ.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(integ);
        
        Other__c other = new Other__c();
        other.Name = 'SP18_InitializedBatch';
        other.Value__c = '0';
        database.insert(other);
        
        Batch_Control_Settings__c batchControlSettings = new Batch_Control_Settings__c();
        batchControlSettings.Name = 'SP028';
        batchControlSettings.Batch_Size__c = 100;
        batchControlSettings.Number_of_Parallel_Jobs__c = 5;
        insert batchControlSettings;
        
        BT_CO_Batch_Run_Request__c brr = new BT_CO_Batch_Run_Request__c();
        brr.Interface_ID__c = 'IntID123';
        brr.End_Time__c = null;
        database.insert(brr);
        //end custom settings
    
        test.startTest();
            SP_CreditCardFailureRequestBatch batch = new SP_CreditCardFailureRequestBatch('Email', 1, 'SESSIONID', extPaymentIds, date.today());
            ID batchProcessID = Database.executeBatch(batch, 200);
            system.assertNotEquals(batchProcessID, null);
            
            String shortID = string.valueOf(batchProcessID).subString(0,15);
            
            BATCH_JOB_SCHEDULER__c batchJobScheduler = new BATCH_JOB_SCHEDULER__c();
            batchJobScheduler.Batch_Run_Date__c = System.today();
            batchJobScheduler.SFDC_Job_id__c = shortID;
            batchJobScheduler.Batch_Code__c = 'SP028';
            batchJobScheduler.End_Time__c = null;
            insert batchJobScheduler; 
            
            BATCH_JOB_SCHEDULER__c bq = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, 
                SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE id=:batchJobScheduler.Id];
               // system.assertEquals(bq.SFDC_Job_id__c, shortID);
            
            BatchJobHelper.updateJobStatus(batchProcessID);
            BatchJobHelper.updateJobStatus(bq.SFDC_Job_id__c, true);
            BatchJobHelper.getNumberOfParallelJobs('SP028');
            BatchJobHelper.isJobSucesss(batchProcessID);
            BatchJobHelper.delegateBatchCall(bq.SFDC_Job_id__c, true);
            BatchJobHelper.runJobCleaners(batchJobScheduler);
            
            try{
                insert batchJobScheduler;
            }
            catch(Exception e){
                error=e;
            }
            BatchJobHelper.handleException(lstRecords, error, '', '', bq.SFDC_Job_id__c, batchProcessID,true);
            BatchJobHelper.handleException(lstRecords, error, '', '', batchProcessID, batchProcessID,false);
        test.stopTest();
    }
}