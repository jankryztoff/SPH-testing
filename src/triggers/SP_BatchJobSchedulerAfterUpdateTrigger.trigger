/*
 * Trigger Name: SP_BatchJobSchedulerAfterUpdateTrigger
 * Author: Raviteja Kumar
 * Date: 05 Oct 2015
 * Project/Requirement: SPH Scheduled Processes - Batch Process Control
 * Description: This trigger executes the batch jobs details into Batch_Monitor__c object after End Time update into record
 * History: 05-Oct-2015 Raviteja Kumar Created Apex Trigger
 *
 */
trigger SP_BatchJobSchedulerAfterUpdateTrigger on BATCH_JOB_SCHEDULER__c (After Update) {
    
    System.debug('Trigger on After Udpate Event');
    List<BATCH_JOB_SCHEDULER__c> lstBatchjobschd = trigger.new;       
    List<Batch_Monitor__c> lstBatchMonitorupsert = New List<Batch_Monitor__c>();
    Map<Id,Log__c> mapLog = New Map<Id,Log__c>();
    Set<Id> lstsfdcJobIds = New Set<Id>();
    Set<Id> lstsfdcJoblongIds = New Set<Id>();
    Set<Id> setTriggerNewIds = New Set<Id>(); //START/END D-4482 14-Mar-2016 Added by Raviteja - Capturing trigger.new ids
    Map<Id,Integer> mapNoofRecords = New Map<Id,Integer>(); //START-End D-3858 11-Nov-2015 Added by Raviteja: Added No.Of records Map
    
    //START 20 January 2016 D-4281 Kevin Evasco - Single callout to on-premise system for letter printing parallel jobs
    Map<String,Date> batchCode_batchRunDate = new Map<String,Date>();
    Set<String> withPendingJobs = new Set<String>();
    Set<String> withFailedJobs = new Set<String>();
    Set<Date> batchRunDateSet = new Set<Date>();
    //Start D-4742 Raviteja 26Apr2016 - Implemtented the Parallel_Job_Settings__c logic
    Map<string,string> mapParalleljobs = New Map<string,string>();
    Set<string> setparalleljobs = new set<string>();
    for(Parallel_Job_Settings__c pjs : Parallel_Job_Settings__c.getAll().values()){             
        mapParalleljobs.put(pjs.Name,pjs.Parallel_Job__c);              
    }
    setparalleljobs.addAll(mapParalleljobs.values());
    System.debug('lstBatchjobschd: ' + lstBatchjobschd);
    for(BATCH_JOB_SCHEDULER__c batchRunRequest: lstBatchjobschd)        
    {
        lstsfdcJobIds.add(batchRunRequest.SFDC_Job_id__c);
        System.debug('batchRunRequest.Number_of_Parallel_Jobs__c : '+batchRunRequest.Number_of_Parallel_Jobs__c);        
        System.debug('mapParalleljobs : '+mapParalleljobs);
        System.debug('batchRunRequest.Batch_Code__c : '+batchRunRequest.Batch_Code__c);
        System.debug('batchRunRequest.Batch_Code__c : '+batchRunRequest.Batch_Code__c);
        System.debug('mapParalleljobs.containsKey : '+mapParalleljobs.containsKey(batchRunRequest.Batch_Code__c));
        System.debug('batchRunRequest.Number_of_Parallel_Jobs__c : '+batchRunRequest.Number_of_Parallel_Jobs__c);
        System.debug('batchRunRequest.Number_of_Parallel_Jobs_Executed__c : '+batchRunRequest.Number_of_Parallel_Jobs_Executed__c);
        
        if(batchRunRequest.Number_of_Parallel_Jobs__c != Null && mapParalleljobs.containsKey(batchRunRequest.Batch_Code__c) && batchRunRequest.Number_of_Parallel_Jobs__c == batchRunRequest.Number_of_Parallel_Jobs_Executed__c){            
                    Date batchRunDate = batchRunRequest.Batch_Run_Date__c;
                    String batchCode = mapParalleljobs.get(batchRunRequest.Batch_Code__c);             
                    Boolean isSuccess = True;
                    if(batchRunRequest.Status_of_Parallel_jobs__c != Null && batchRunRequest.Status_of_Parallel_jobs__c.contains('1')){
                        isSuccess = False;                      
                    }
                    DelegateBatchCallQueueable queueableInstance = new DelegateBatchCallQueueable(batchCode,batchRunDate,isSuccess);
                    System.enqueueJob(queueableInstance);                           
            
        } 
        else if(SP_BatchJobSchedulerService.parallelBatches.contains(batchRunRequest.Batch_Code__c) && batchRunRequest.Batch_Code__c != 'SP035' && !setparalleljobs.contains(batchRunRequest.Batch_Code__c)) {           
            batchCode_batchRunDate.put(batchRunRequest.Batch_Code__c, batchRunRequest.Batch_Run_Date__c);
            batchRunDateSet.add(batchRunRequest.Batch_Run_Date__c);
            //START D-4482 14-Mar-2016 Added by Raviteja - Checking the trigger.New status values
            setTriggerNewIds.add(batchRunRequest.Id);
            
            String batchKey = batchRunRequest.Batch_Code__c + batchRunRequest.Batch_Run_Date__c.format();            
            if(batchRunRequest.Status__c != 'SUCCESS' && batchRunRequest.Status__c != 'FAILED')
                withPendingJobs.add(batchKey);
            
            if(batchRunRequest.Status__c == 'FAILED')
                withFailedJobs.add(batchKey);
            //END D-4482 14-Mar-2016 Added by Raviteja   
        }       
        //End D-4742 Raviteja 26Apr2016 - Implemtented the Parallel_Job_Settings__c logic
    }
    
    System.debug('batchCode_batchRunDate: ' + batchCode_batchRunDate);
    System.debug('batchRunDateSet: ' + batchRunDateSet);
    
    if(batchCode_batchRunDate.isEmpty() == false) {
         //START/END D-4482 14-Mar-2016 Added by Raviteja - added setTriggerNewIds filter in SOQL
        for(BATCH_JOB_SCHEDULER__c batchJobSchedulerElem : [SELECT Id, Batch_Code__c, Batch_Run_Date__c, Status__c FROM BATCH_JOB_SCHEDULER__c 
                                                                                                                      WHERE Batch_Code__c IN :batchCode_batchRunDate.keySet() 
                                                                                                                      AND Batch_Run_Date__c IN :batchRunDateSet
                                                                                                                      AND Id Not IN :setTriggerNewIds ]) {
            String batchKey = batchJobSchedulerElem.Batch_Code__c + batchJobSchedulerElem.Batch_Run_Date__c.format();
            
            if(batchJobSchedulerElem.Status__c != 'SUCCESS' && batchJobSchedulerElem.Status__c != 'FAILED')
                withPendingJobs.add(batchKey);
                
            if(batchJobSchedulerElem.Status__c == 'FAILED')
                withFailedJobs.add(batchKey);
        }
    
        System.debug('withPendingJobs: ' + withPendingJobs);
        for(String batchCodeElem : batchCode_batchRunDate.keySet()) {
            Date batchRunDate = batchCode_batchRunDate.get(batchCodeElem);
            String batchKey = batchCodeElem + batchRunDate.format();
            if(withPendingJobs.contains(batchKey) == false){
                Boolean isSuccess = true;
                if(withFailedJobs.contains(batchKey))
                    isSuccess = false;
                    
                DelegateBatchCallQueueable queueableInstance = new DelegateBatchCallQueueable(batchCodeElem,batchRunDate,isSuccess);
                System.enqueueJob(queueableInstance);
            }
        }
    }
    //END 20 January 2016 D-4281 Kevin Evasco - Single callout to on-premise system for letter printing parallel jobs
    
    System.debug(' lstsfdcJobIds: '+lstsfdcJobIds);
    for(AsyncApexJob ApexJob: [SELECT Id from AsyncApexJob where id in:lstsfdcJobIds])        
    {
     lstsfdcJoblongIds.add(ApexJob.Id);
    }
    System.debug(' lstsfdcJoblongIds: '+lstsfdcJoblongIds);
    for(Log__c log: [SELECT Id,ApexJob_Id__c,isAbortLog__c,Instance__c,Message__c FROM Log__c WHERE isAbortLog__c = True AND ApexJob_Id__c in :lstsfdcJoblongIds])        
    {
     //string shortID = string.valueOf(log.ApexJob_Id__c).subString(0,15);
     //Id jobId = Id.valueOf(shortID);
     mapLog.put(log.ApexJob_Id__c, log);
    }
    System.debug(' mapLog: '+mapLog);
    //START D-3858 11-Nov-2015 Added by Raviteja  - Calculating Logic of No.Of Records Process
    for(AsyncApexJob ApexJob: [SELECT Id,ParentJobId ,LastProcessedOffset from AsyncApexJob where ParentJobId in: lstsfdcJobIds])        
    {
         if(mapNoofRecords.keySet().contains(ApexJob.ParentJobId)){
             if (ApexJob.LastProcessedOffset > mapNoofRecords.get(ApexJob.ParentJobId) ){
                 mapNoofRecords.put(ApexJob.ParentJobId ,ApexJob.LastProcessedOffset);
                 }
             }
         else{
             mapNoofRecords.put(ApexJob.ParentJobId ,ApexJob.LastProcessedOffset);
         }
    }
    //End D-3858 11-Nov-2015 Added by Raviteja
    Map<Id,AsyncApexJob> mapApexJob = New Map<Id,AsyncApexJob>([SELECT ApexClassId,CompletedDate,CreatedById,CreatedDate,ExtendedStatus,Id,JobItemsProcessed,JobType,
                                                                                LastProcessed,LastProcessedOffset,MethodName,NumberOfErrors,ParentJobId,Status,TotalJobItems 
                                                                                FROM AsyncApexJob WHERE Id in :lstsfdcJobIds ]);
    for(BATCH_JOB_SCHEDULER__c batchRunRequest: lstBatchjobschd)        
    {
        Integer exitCode;
        Batch_Monitor__c objBatchMonitor = New Batch_Monitor__c();
        if(batchRunRequest.End_Time__c != Null){
           //Applying BATCH_JOB_SCHEDULER details
           objBatchMonitor.BATCH_JOB_SCHEDULER__c =  batchRunRequest.Id;
           objBatchMonitor.Batch_Code__c =  batchRunRequest.Batch_Code__c;
           objBatchMonitor.Batch_Run_Date__c =  batchRunRequest.Batch_Run_Date__c;
           objBatchMonitor.End_Time__c =  batchRunRequest.End_Time__c;
           objBatchMonitor.Letter_Print_Request_Count__c =  batchRunRequest.Letter_Print_Request_Count__c;           
           objBatchMonitor.SFDC_Job_id__c =  batchRunRequest.SFDC_Job_id__c;
           objBatchMonitor.Start_Time__c =  batchRunRequest.Start_Time__c;
           objBatchMonitor.Batch_Job_Scheduler_Status__c =  batchRunRequest.Status__c;
           objBatchMonitor.RECORDS_RETRIEVED_COUNT__c = mapNoofRecords.get(batchRunRequest.SFDC_Job_id__c); //START - End D-3858 11-Nov-2015 Added by Raviteja           
           
           //Applying Log details
           System.debug(' batchRunRequest.SFDC_Job_id__c :'+batchRunRequest.SFDC_Job_id__c);
           if(mapLog.get(batchRunRequest.SFDC_Job_id__c) != Null){
               objBatchMonitor.Logger__c =  mapLog.get(batchRunRequest.SFDC_Job_id__c).Id;
               objBatchMonitor.Log_Instance__c =  mapLog.get(batchRunRequest.SFDC_Job_id__c).Instance__c;
               objBatchMonitor.Log_Message__c =  mapLog.get(batchRunRequest.SFDC_Job_id__c).Message__c;
               System.debug(' objBatchMonitor.Logger__c :'+objBatchMonitor.Logger__c);
               } 
                            
           
           //Applying AsyncApexJob details
           if(mapApexJob.containsKey(objBatchMonitor.SFDC_Job_id__c)){
               AsyncApexJob objApexJob = mapApexJob.get(objBatchMonitor.SFDC_Job_id__c);
               objBatchMonitor.ExtendedStatus__c = objApexJob.ExtendedStatus;
               objBatchMonitor.JobItemsProcessed__c = objApexJob.JobItemsProcessed;
               objBatchMonitor.NumberofErrors__c = objApexJob.NumberOfErrors;
               objBatchMonitor.ParentJobId__c = objApexJob.ParentJobId;
               objBatchMonitor.TotalJobItems__c = objApexJob.TotalJobItems;
               objBatchMonitor.Apex_Job_Status__c = objApexJob.Status; 
               objBatchMonitor.Status__c = objApexJob.Status;
               if(objApexJob.Status == 'Aborted'){
                   exitCode = 1;
               }else if(objApexJob.NumberOfErrors > 0 && objApexJob.JobItemsProcessed == objApexJob.NumberOfErrors) {
                   exitCode = 23;
               }else if(objApexJob.NumberOfErrors > 0){
                   exitCode = 12;                   
               }else if(batchRunRequest.Status__c == 'SUCCESS' && objApexJob.Status == 'Completed'){
                   exitCode = 0;                   
               }
               
               if(batchRunRequest.Status__c == 'SUCCESS' && objApexJob.Status == 'Completed'){
                   objBatchMonitor.Status__c = 'Completed';
                   exitCode = 0;
               }
               else if(batchRunRequest.Status__c == 'ABORTED' || objApexJob.Status == 'Aborted' || ( objApexJob.ExtendedStatus != Null && objApexJob.ExtendedStatus.contains('Aborted'))){
                   objBatchMonitor.Status__c = 'Aborted';
                   exitCode = 1;
               }else if(objApexJob.NumberOfErrors > 0){
                   objBatchMonitor.Status__c = 'Failed';
                   exitCode = 23;
               }else if(objBatchMonitor.End_Time__c != Null && (objBatchMonitor.Status__c  != 'Completed' || objBatchMonitor.Status__c  != 'Failed' || objApexJob.ExtendedStatus.contains('Aborted') )){
                   objBatchMonitor.Status__c = 'Aborted';
                   exitCode = 1;
               }
           }    
           
           objBatchMonitor.Exit_Code__c =  exitCode;
           lstBatchMonitorupsert.add(objBatchMonitor);        
        }
         
    }
    if(!lstBatchMonitorupsert.isEmpty()){
     Schema.SObjectField schemaField = Batch_Monitor__c.Fields.SFDC_Job_id__c;
     Database.UpsertResult[] upsertResult = Database.upsert(lstBatchMonitorupsert, schemaField, false);
    }
    
}