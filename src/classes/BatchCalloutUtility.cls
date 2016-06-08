global class BatchCalloutUtility { 
     Public static void updateBatchSchedulerRecord(String batchID ){
            List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :batchID];
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                                        TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchID];
            system.debug('a--------'+a);                            
            system.debug('batchJobSchedulerList----------------'+batchJobSchedulerList);
                if(batchJobSchedulerList.size() > 0)
                {
                    BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
                    if(a.Status == 'Completed'){
                        batchJobScheduler.Status__c = 'SUCCESS';
                    }else if(a.Status =='Failed'){
                        batchJobScheduler.Status__c = 'Failed';
                    }
                    batchJobScheduler.End_Time__c = DateTime.now();
                    update batchJobScheduler;    
                    system.debug('batchJobScheduler-------------'+batchJobScheduler);
    }
        
     }
     @future (callout=true) 
     Public static void invokeCalloutUtility(List<Id> batchJobSchedulerRecList)
     {
        system.debug('batchJobSchedulerRecList---------------'+batchJobSchedulerRecList);
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = new List<BATCH_JOB_SCHEDULER__c>([Select Status__c,Batch_Code__c,Batch_Run_Date__c,Id
                                                                                                from BATCH_JOB_SCHEDULER__c where Id in :batchJobSchedulerRecList]);
        BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0); 
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        if(batchJobScheduler.Status__c == 'SUCCESS'){
            serviceRequestVO.setJobStatus(0);
        }else if( batchJobScheduler.Status__c == 'Failed'){
            serviceRequestVO.setJobStatus(1);
        }
        serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
        serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after'); 
     }
}