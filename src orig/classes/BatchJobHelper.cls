public class BatchJobHelper {

    //START 20 January 2016 D-4281 Kevin Evasco - Update Batch Job Scheduler without callout
    public static void updateBatchJobScheduler(id jobId) {
        
        string shortID = string.valueOf(jobId).subString(0,15);
        list<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, 
                SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :jobId];

        if(batchJobSchedulerList.size() > 0)
        {
            AsyncApexJob apexJobInstance = [SELECT Id, NumberOfErrors FROM AsyncApexJob WHERE Id = :jobId];
        
            BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
            if(apexJobInstance.NumberOfErrors == 0)         
                batchJobScheduler.Status__c = 'SUCCESS';
            else
                batchJobScheduler.Status__c = 'FAILED';
                
            batchJobScheduler.End_Time__c = DateTime.now();            
            update batchJobScheduler;            
        }       
        
    } 
    //END 20 January 2016 D-4281 Kevin Evasco - Update Batch Job Scheduler without callout
    
    //START D-4482 14-Mar-2016 Added by Raviteja - Update Batch Job Scheduler without callout for Letter Printrequest jobs
    
    //Start D-4742 Raviteja 26Apr2016 - updating the parent BatchJobScheduler id logic in  updateBatchJobScheduler method   
        public static void updateBatchJobScheduler(id jobId, Boolean isSuccess) {
        
        string shortID = string.valueOf(jobId).subString(0,15);
        list<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c, Parent_Job__c
                                                                                ,Details_of_Parallel_jobs__c, Number_of_Parallel_Jobs__c   
                                                                            FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :jobId];

        if(batchJobSchedulerList.size() > 0)
        {
            AsyncApexJob apexJobInstance = [SELECT Id, NumberOfErrors FROM AsyncApexJob WHERE Id = :jobId];
            
            List<BATCH_JOB_SCHEDULER__c> lstBatchJobScheduler = New List<BATCH_JOB_SCHEDULER__c>();
            
            BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
            if(apexJobInstance.NumberOfErrors == 0 && isSuccess)         
                batchJobScheduler.Status__c = 'SUCCESS';
            else
                batchJobScheduler.Status__c = 'FAILED';
                
            batchJobScheduler.End_Time__c = DateTime.now();            
            
            lstBatchJobScheduler.add(batchJobScheduler);
            
            if(batchJobScheduler.Parent_Job__c != Null){
                string parentshortID = string.valueOf(batchJobScheduler.Parent_Job__c).subString(0,15);
                for(BATCH_JOB_SCHEDULER__c parentbatchJobScheduler : [SELECT Id, SFDC_Job_id__c, Details_of_Parallel_jobs__c, Number_of_Parallel_Jobs_Executed__c, 
                                                                                Status_of_Parallel_jobs__c,Number_of_Parallel_Jobs__c, Parent_Job__c    
                                                                                    FROM BATCH_JOB_SCHEDULER__c 
                                                                                        WHERE ( Id = :parentshortID ) OR 
                                                                                              (Id = :batchJobScheduler.Parent_Job__c) limit 1 FOR UPDATE]){                   
                    
                    System.debug('parentbatchJobScheduler.Number_of_Parallel_Jobs_Executed__c : '+parentbatchJobScheduler.Number_of_Parallel_Jobs_Executed__c);
                    System.debug('parentbatchJobScheduler.Status_of_Parallel_jobs__c : '+parentbatchJobScheduler.Status_of_Parallel_jobs__c);
                    System.debug('parentbatchJobScheduler.Parent_Job__c : '+parentbatchJobScheduler.Parent_Job__c);
                    System.debug('parentbatchJobScheduler.Number_of_Parallel_Jobs__c : '+parentbatchJobScheduler.Number_of_Parallel_Jobs__c);
                    
                    if(parentbatchJobScheduler.Number_of_Parallel_Jobs__c == Null){
                        parentbatchJobScheduler.Number_of_Parallel_Jobs__c = batchJobScheduler.Number_of_Parallel_Jobs__c ;
                    }
                    
                    if(parentbatchJobScheduler.Number_of_Parallel_Jobs_Executed__c > 0){
                            parentbatchJobScheduler.Number_of_Parallel_Jobs_Executed__c = parentbatchJobScheduler.Number_of_Parallel_Jobs_Executed__c + 1;
                    }
                    else{
                            parentbatchJobScheduler.Number_of_Parallel_Jobs_Executed__c = 1;
                    }
                    
                    String jobdetails = '{' + batchJobScheduler.Id + ' : ';
                    
                    String Status;
                    if(batchJobScheduler.Status__c == 'FAILED'){                        
                        jobdetails = jobdetails + '1' ;
                        Status = '1';
                    }else{                      
                        jobdetails = jobdetails + '0' ;
                        Status = '0';
                    }
                    
                    if(parentbatchJobScheduler.Status_of_Parallel_jobs__c != Null){
                        parentbatchJobScheduler.Status_of_Parallel_jobs__c = parentbatchJobScheduler.Status_of_Parallel_jobs__c + Status ;                      
                    }else{
                        parentbatchJobScheduler.Status_of_Parallel_jobs__c = Status;
                    }
                    
                    jobdetails = jobdetails + '}' ;

                    if(parentbatchJobScheduler.Details_of_Parallel_jobs__c != Null){
                        parentbatchJobScheduler.Details_of_Parallel_jobs__c = parentbatchJobScheduler.Details_of_Parallel_jobs__c + ',' + jobdetails;
                    }
                    else{
                        parentbatchJobScheduler.Details_of_Parallel_jobs__c = jobdetails;
                    }
                    
                    lstBatchJobScheduler.add(parentbatchJobScheduler);
                }
                
            }
            
            update lstBatchJobScheduler;  

            
        }       
        
    }
    //End D-4742 Raviteja 26Apr2016 - updating the parent BatchJobScheduler id logic in  updateBatchJobScheduler method
    
   //END D-4482 14-Mar-2016 Added by Raviteja 
    
    public static void updateJobStatus(id jobId) {
        
        string shortID = string.valueOf(jobId).subString(0,15);
        list<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, 
                SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :jobId];

        if(batchJobSchedulerList.size() > 0)
        {
            BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
            batchJobScheduler.Status__c = 'SUCCESS';
            batchJobScheduler.End_Time__c = DateTime.now();
            
            BatchServiceFacade a1F = new BatchServiceFacade();
            BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
            serviceRequestVO.setJobStatus(0);
            serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
            serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
            a1F.delegateBatchCall(serviceRequestVO);
            
            update batchJobScheduler;
            
        }       
    }
    
    //START UD-1917 Wenjun 15/07/15 : New utility method to accept job status as parameter
    public static void updateJobStatus(Id jobId, Boolean isSuccess) {
        String shortID = string.valueOf(jobId).subString(0,15);
        list<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, 
                SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :jobId];
                
        if(batchJobSchedulerList.size() > 0)
        {
            BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
            batchJobScheduler.Status__c = isSuccess ? 'SUCCESS' : 'FAILED';
            batchJobScheduler.End_Time__c = DateTime.now();
            
            BatchServiceFacade a1F = new BatchServiceFacade();
            BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
            serviceRequestVO.setJobStatus(isSuccess ? 0 : 1);
            serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
            serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
            a1F.delegateBatchCall(serviceRequestVO);
            
            UPDATE batchJobScheduler;
        }       
    }
    //END UD-1917 Wenjun 15/07/15
    
    //START 04/14/2015 D-2740 Kevin Evasco - Dynamic Number of Parallel Jobs for Infoprint
    public static Integer getNumberOfParallelJobs(String batchCode) {
        Integer numberofParallelJobs = 5;
        try{
            Batch_Control_Settings__c batchControlSettings = Batch_Control_Settings__c.getInstance(batchCode);
            if(batchControlSettings.Number_of_Parallel_Jobs__c != null && batchControlSettings.Number_of_Parallel_Jobs__c > 0) {                
                numberofParallelJobs = Integer.valueOf(batchControlSettings.Number_of_Parallel_Jobs__c);
            }
        } catch (Exception e) {
        }
        return numberofParallelJobs;
    }
    //END 04/14/2015 D-2740 Kevin Evasco - Dynamic Number of Parallel Jobs for Infoprint
    //START 04/17/2015 D-2771 Kevin Evasco - Configurable Batch Size
    public static Map<String, Batch_Control_Settings__c> getBatchControlSettingsMap(Set<String> batchCodeSetParam){
        Map<String, Batch_Control_Settings__c> batchControlSettingsMap = new Map<String, Batch_Control_Settings__c>();
        List<Batch_Control_Settings__c> batchControlSettingsList = new List<Batch_Control_Settings__c>();
        
        batchControlSettingsList = [SELECT Name, Batch_Size__c FROM Batch_Control_Settings__c WHERE Name IN :batchCodeSetParam];
        
        for(Batch_Control_Settings__c batchControlSettingsElement : batchControlSettingsList){
            batchControlSettingsMap.put(batchControlSettingsElement.Name, batchControlSettingsElement);
        }       
        return batchControlSettingsMap;
    }
    
    public static Integer getBatchSize(Map<String, Batch_Control_Settings__c> batchControlSettingsMap, String batchCode){
        Integer batchSize = 200;
        
        if(batchControlSettingsMap.get(batchCode) != null){
            Decimal customSettingsBatchSize = batchControlSettingsMap.get(batchCode).Batch_Size__c;
            if(customSettingsBatchSize != null) {
                batchSize = Integer.valueOf(customSettingsBatchSize);
            }
        }
        
        return batchSize;
    }
    //END 04/17/2015 D-2771 Kevin Evasco - Configurable Batch Size
    
    //START UD-3043 07-Oct-2015 Added by Raviteja - Creating isJobSuccessmethod
    public static Boolean isJobSucesss(id jobId) {
        Boolean isSucess = True;
        List<AsyncApexJob> lstapexjobs = New List<AsyncApexJob>();
        lstapexjobs = [SELECT Id,NumberOfErrors,Status,ExtendedStatus FROM AsyncApexJob WHERE Id = :jobId limit 1];
        if(!lstapexjobs.isEmpty() && (( lstapexjobs[0].ExtendedStatus != Null &&  lstapexjobs[0].ExtendedStatus.contains('aborted')) || (lstapexjobs[0].NumberOfErrors > 0 || lstapexjobs[0].Status != 'Completed'))){
            isSucess = False;
        }    
     return isSucess;
    }
    //End UD-3043 07-Oct-2015 Added by Raviteja
    
    //START D-4482 14-Mar-2016 Added by Raviteja - Fetching Job status for letter Print Request jobs (logic from SP_LetterPrintRequestUpdater class)
    public static Boolean getJobStatus(String letterType, String sourceCode, String status) {
        Boolean isSucess = True;        
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = new List<BATCH_JOB_SCHEDULER__c>(); 
        List<Letter_Print_Request__c> letterPrintRequestList = new List<Letter_Print_Request__c>(); 
       
        batchJobSchedulerList = [SELECT id, name, CreatedDate, Start_Time__c
                                    FROM BATCH_JOB_SCHEDULER__c 
                                    WHERE Batch_Code__c = :sourceCode AND Status__c = 'SUCCESS'
                                    ORDER BY CreatedDate DESC LIMIT 1];
                
        if(batchJobSchedulerList.size() == 1){
            DateTime lastExecution = batchJobSchedulerList[0].Start_Time__c;            
            letterPrintRequestList = [SELECT Id, Letter_Type__c,Status__c FROM Letter_Print_Request__c 
                                                                            WHERE CreatedDate < :lastExecution 
                                                                                    AND Status__c = :SP_GenerateLetterPrintBatch.failedValue 
                                                                                    AND Letter_Type__c = :letterType];
        } else {
            letterPrintRequestList = [SELECT Id, Letter_Type__c,Status__c FROM Letter_Print_Request__c 
                                                                            WHERE Status__c = :status 
                                                                                    AND Letter_Type__c = :letterType];
        }   
        
        if(letterPrintRequestList.size() > 0){
            isSucess = False;
        }
     return isSucess;
    }
    //End D-4482 14-Mar-2016 Added by Raviteja
    
    //START UD-3043 07-Oct-2015 Added by Raviteja - Creating handleException Method
    public static void handleException(List<sObject> lstRecords, Exception e, String className, String batchCode, ID jobID, ID currentjobID, Boolean performAbort)
    {       
        System.debug(' className : '+className);
        System.debug(' batchCode : '+batchCode);
        System.debug(' jobID : '+jobID);
        System.debug(' currentjobID : '+currentjobID);
        System.debug(' performAbort : '+performAbort);
        String shortID = string.valueOf(jobId).subString(0,15);
        list<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, 
                SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :jobId];
                
        if(!batchJobSchedulerList.isEmpty())
        {

            BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
            batchJobScheduler.Status__c = 'FAILED';
            batchJobScheduler.End_Time__c = DateTime.now();
                
            if(performAbort)
            {
                BatchServiceFacade a1F = new BatchServiceFacade();
                BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
                serviceRequestVO.setJobStatus(1);
                serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
                serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
                a1F.delegateBatchCall(serviceRequestVO);
            }
            
            Logger logger = new Logger(className,batchCode,jobID);
            String exceptionMessage = '';
            exceptionMessage= 'Stack trace: '+ e.getStackTraceString();    
            exceptionMessage = exceptionMessage + '; Message: ' + e.getMessage();  
            logger.logBatchFailure(exceptionMessage, lstRecords); 
            logger.save(); 
            
            if(performAbort)
            {
                UPDATE batchJobScheduler;
                if(currentjobID != Null){
                    System.debug(' currentjobID abotred ');
                    System.abortJob(currentjobID); 
                }
                else{
                System.debug(' jobID abotred ');
                System.abortJob(jobID); 
                }
            }
        }else{
            //START D-3667 LISEN 10/6/2015 - Enable on demand batch call for recovery
            Logger logger = new Logger(className,batchCode,jobID);
            String exceptionMessage = '';
            exceptionMessage= 'Stack trace: '+ e.getStackTraceString();    
            exceptionMessage = exceptionMessage + '; Message: ' + e.getMessage();  
            logger.logBatchFailure(exceptionMessage, lstRecords); 
            logger.save();
            //END D-3667 LISEN 10/6/2015 - Enable on demand batch call for recovery
        }                                                      

    }
   //End UD-3043 07-Oct-2015 Added by Raviteja
   
   //START 09 October 2015 D-3629 Kevin Evasco - Seperate methods for callout and DML
    public static BATCH_JOB_SCHEDULER__c delegateBatchCall(Id jobId, Boolean isSuccess) {
        BATCH_JOB_SCHEDULER__c batchJobScheduler;
        String shortID = string.valueOf(jobId).subString(0,15);
        list<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, 
                SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :jobId];
                
        if(batchJobSchedulerList.size() > 0)
        {
            batchJobScheduler = batchJobSchedulerList.get(0);
            batchJobScheduler.Status__c = isSuccess ? 'SUCCESS' : 'FAILED';
            batchJobScheduler.End_Time__c = DateTime.now();
            
            BatchServiceFacade a1F = new BatchServiceFacade();
            BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
            serviceRequestVO.setJobStatus(isSuccess ? 0 : 1);
            serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
            serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
            a1F.delegateBatchCall(serviceRequestVO);            
        }

        return batchJobScheduler;
    }
    //END 09 October 2015 D-3629 Kevin Evasco - Seperate methods for callout and DML
    
    //START 11 November 2015 D-3897 Kevin Evasco - BJS-BRR Clean up Methods
    public static boolean runJobCleaners(BATCH_JOB_SCHEDULER__c batchJobSchedulerParam){    
        Boolean isSuccess = true;
        try {
            cleanBatchJobScheduler();
            cleanBatchRunRequest();
        } catch (Exception e) {
            Logger logger = new Logger(BatchJobHelper.class.getName(),'HK017');
            logger.log(false,'Failed to clean up Batch Job Schedulers and Batch Run Requests');
            logger.save();
            isSuccess = false;
        }
        
        try {
            delegateBatchFutureCall(batchJobSchedulerParam.Batch_Code__c, batchJobSchedulerParam.Batch_Run_Date__c, isSuccess);
        } catch (Exception e) {
            Logger logger = new Logger(BatchJobHelper.class.getName(),'HK017');
            logger.log(false,'Failed to send completion callout to Integration Server');
            logger.save();
            isSuccess = false;
        }
        
        return isSuccess;
    }
    
    public static void cleanBatchJobScheduler() {
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, End_Time__c, Status__c FROM BATCH_JOB_SCHEDULER__c WHERE End_Time__c = null];
        for(BATCH_JOB_SCHEDULER__c batchJobSchedulerElem : batchJobSchedulerList) {
            batchJobSchedulerElem.End_Time__c = DateTime.newInstance(4000,12,30);           
            batchJobSchedulerElem.Status__c = 'FAILED';
        }       
        update batchJobSchedulerList;
    }
    
    public static void cleanBatchRunRequest() {
        List<BT_CO_Batch_Run_Request__c> batchRunRequestList = [SELECT Id, End_Time__c FROM BT_CO_Batch_Run_Request__c WHERE End_Time__c = null];
        for(BT_CO_Batch_Run_Request__c batchRunRequestElem : batchRunRequestList) {
            batchRunRequestElem.End_Time__c = DateTime.newInstance(4000,12,30);         
        }       
        update batchRunRequestList;
    }
    
    @future(callout=true)
    public static void delegateBatchFutureCall(String batchCode, Date batchRunDate, Boolean isSuccess) {
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(isSuccess ? 0 : 1);
        serviceRequestVO.setJobID(batchCode);
        serviceRequestVO.setJobDate(batchRunDate);
        a1F.delegateBatchCall(serviceRequestVO);        
    }   
    //END 11 November 2015 D-3897 Kevin Evasco - BJS-BRR Clean up Methods
}