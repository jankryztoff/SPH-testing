@isTest
private class SP_PopConsolidationBatchFinalTest{
    
    static testmethod void unitTest(){
        try 
        {
        List<Account> accs = TestDataFactory.createAccount(1, 'Mailing Agent');
        accs[0].Vendor_Code__c = 'ABCDE';
        insert accs;
        
        List<Vendor_POP_Batch__c> vendorPops = TestDataFactory.createVendorPopBatch(1);
        vendorPops[0].Subscription_Name__c = 'Sample';
        vendorPops[0].Vendor_Number__c = 'ABCDE';
        insert vendorPops;
        /*
        BATCH_JOB_SCHEDULER__c job = new BATCH_JOB_SCHEDULER__c();
        job.Batch_Run_Date__c = Date.today().addDays(1);
        job.Batch_Code__c = 'SP001';
        job.Status__c = 'STARTED';
        insert job; 
        
        job.SFDC_Job_id__c = job.id;
        update job;
       
        
        SP_PopConsolidationBatchFinal batch = new SP_PopConsolidationBatchFinal(job.id);
        ID batchprocessid = Database.executeBatch(batch, 200); 
        //system.assertEquals('JobId ' , ' ' + batchprocessid);
        System.assertNotEquals(null, batchprocessid);*/ 
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }      
    }
}