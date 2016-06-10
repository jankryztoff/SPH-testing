/**
 * Class Name: SP_BatchJobSchedulerService
 * @author: Jb Domingo
 * Date: 11/09/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Inserts record to Batch Job Scheduler object
 * History: 11/23/2014 Kevin Evasco Updated to include gift letter printing
 * History: 12/05/2014 D-0797, D-0849 Kevin Evasco Added new parameter to enable storage of Session ID.
 * History: 22/06/2015 Krithika Hotfix UAT 
 */

@RestResource(urlMapping='/SP_BatchJobSchedulerService/*')
global class SP_BatchJobSchedulerService
{
    public static Set<String> parallelBatches = new Set<String>();
    //START: UD-2328 8/18 added by Alyana N/ Jason A
    public static Map<String, String> batchCodeLetterTypeMap = new Map<String, String>();
    //END: UD-2328 8/18 added by Alyana N/ Jason A
    //Start D-4742 Raviteja 26Apr2016 - Capturing parent batch job schdduler record id
    public static Id parentBatchJobSchedulerId;
    public static void setParentBatchJobSchedulerId(Id parentId)
    {
        parentBatchJobSchedulerId = parentId;
    }        
    
    //End D-4742 Raviteja 26Apr2016 - Capturing parent batch job schdduler record id      
    static 
    {       
        parallelBatches.add('SP018');
        parallelBatches.add('SP026');
        parallelBatches.add('SP027');
        parallelBatches.add('SP028');
        parallelBatches.add('SP029');
        parallelBatches.add('SP030');
        parallelBatches.add('SP031');
        parallelBatches.add('SP032');
        parallelBatches.add('SP033');
        parallelBatches.add('SP034');
        //parallelBatches.add('SP035'); //START 20 January 2016 D-4281 Kevin Evasco - SP035 is no longer running parallel.
        parallelBatches.add('SP036');
        parallelBatches.add('SP037');
        parallelBatches.add('SP038');
        //START : 20/03/2015 Added by Jean Cari?o for MD42
        parallelBatches.add('SP040');
        parallelBatches.add('SP041');
        parallelBatches.add('SP063');//Start/End UD-3207 01-Apr-2016 Added By S.Puli
        //END
    parallelBatches.add('SP047'); // START-END : UD-2634 9/10/2015 Alyana Navarro
    }
    //START 04/15/2015 D-2740 Kevin Evasco - Dynamic Number of Parallel Jobs for Infoprint
    @HttpPost
    global static void processRequest(String batchCode, String action, Integer daysBeforeExpiration, String sessionId)
    {
        //START: UD-2328 8/18 added by Alyana N/ Jason A
        //START D-3535 09-Sept-2015 Added By S.Puli - transfer to initializeBatches method
        /*batchCodeLetterTypeMap.put('SP018', SP_GenerateLetterPrintBatch.acknowledgmentLetter);          
        batchCodeLetterTypeMap.put('SP026', SP_GenerateLetterPrintBatch.creditNotes);
        batchCodeLetterTypeMap.put('SP027', SP_GenerateLetterPrintBatch.creditCardFailureNotification);     
        batchCodeLetterTypeMap.put('SP028', SP_GenerateLetterPrintBatch.invoiceLetter);     
        batchCodeLetterTypeMap.put('SP029', SP_GenerateLetterPrintBatch.packingLabelLetter);    
        batchCodeLetterTypeMap.put('SP030', SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine);       
        batchCodeLetterTypeMap.put('SP031', SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine);  
        batchCodeLetterTypeMap.put('SP032', SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper);  
        batchCodeLetterTypeMap.put('SP033', SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper);                 
        batchCodeLetterTypeMap.put('SP034', SP_GenerateLetterPrintBatch.giftLetter);
        batchCodeLetterTypeMap.put('SP036', SP_GenerateLetterPrintBatch.subscriptionLetter);
        batchCodeLetterTypeMap.put('SP037', SP_GenerateLetterPrintBatch.giftRenewalLetter);
        batchCodeLetterTypeMap.put('SP038', SP_GenerateLetterPrintBatch.giftRedemptionLetter);
        batchCodeLetterTypeMap.put('SP040', SP_GenerateLetterPrintBatch.giftPremiumChina);
        batchCodeLetterTypeMap.put('SP041', SP_GenerateLetterPrintBatch.giftPremiumEnglish);
        */
        //END D-3535 09-Sept-2015 Added By S.Puli
        //END: UD-2328 8/18 added by Alyana N/ Jason A
       initializeBatches(batchCode,action,daysBeforeExpiration,sessionId,null);
    }
    
    global static void initializeBatches(String batchCode, String action, Integer daysBeforeExpiration, String sessionId, Integer letterPrintRequestCount)
    {   
        //KRITHIKA DHARMARAJAN HOTFIX UAT START 22/06/2015
        //Integer numberOfParallelJobs = BatchJobHelper.getNumberOfParallelJobs(batchCode);
       //START D-3535 09-Sept-2015 Added By S.Puli - transfer to initializeBatches method
        batchCodeLetterTypeMap.put('SP018', SP_GenerateLetterPrintBatch.acknowledgmentLetter);          
        batchCodeLetterTypeMap.put('SP026', SP_GenerateLetterPrintBatch.creditNotes);
        batchCodeLetterTypeMap.put('SP027', SP_GenerateLetterPrintBatch.creditCardFailureNotification);     
        batchCodeLetterTypeMap.put('SP028', SP_GenerateLetterPrintBatch.invoiceLetter);     
        batchCodeLetterTypeMap.put('SP029', SP_GenerateLetterPrintBatch.packingLabelLetter);    
        batchCodeLetterTypeMap.put('SP030', SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine);       
        batchCodeLetterTypeMap.put('SP031', SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine);  
        batchCodeLetterTypeMap.put('SP032', SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper);  
        batchCodeLetterTypeMap.put('SP033', SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper);                 
        batchCodeLetterTypeMap.put('SP034', SP_GenerateLetterPrintBatch.giftLetter);
        batchCodeLetterTypeMap.put('SP036', SP_GenerateLetterPrintBatch.subscriptionLetter);
        batchCodeLetterTypeMap.put('SP037', SP_GenerateLetterPrintBatch.giftRenewalLetter);
        batchCodeLetterTypeMap.put('SP038', SP_GenerateLetterPrintBatch.giftRedemptionLetter);
        batchCodeLetterTypeMap.put('SP040', SP_GenerateLetterPrintBatch.giftPremiumChina);
        batchCodeLetterTypeMap.put('SP041', SP_GenerateLetterPrintBatch.giftPremiumEnglish);
        batchCodeLetterTypeMap.put('SP063', SP_GenerateLetterPrintBatch.dailyInvLetter);//Start/End UD-3207 01-Apr-2016 Added By S.Puli
        //END D-3535 09-Sept-2015 Added By S.Puli
        
       Integer numberOfParallelJobs = 5;
        //KRITHIKA DHARMARAJAN HOTFIX END 22/06/2015
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = new List<BATCH_JOB_SCHEDULER__c>();
        //START: UD-2328 8/18 added by Alyana N/ Jason A
        List<Letter_Print_Batch__c> letterPrintList = new List<Letter_Print_Batch__c>();
        if(batchCodeLetterTypeMap.containskey(batchcode)){
            letterPrintList = [SELECT Id, Name, Letter_Type__c, Initialization_Status__c From Letter_Print_Batch__c WHERE Initialization_Status__c = 'Active' AND Letter_Type__c =: batchCodeLetterTypeMap.get(batchcode)];
            if(letterPrintList != null && letterPrintList.size()>0){
                for(integer counter = 0; counter < letterPrintList.size(); counter++ ){
                    letterPrintList[counter].Initialization_Status__c = 'Incomplete';
                }
            }
            update letterPrintList;
        }
        //END: UD-2328 8/18 added by Alyana N/ Jason A
        if(action == 'Start')
        {                           
            if(parallelBatches.contains(batchCode))
            {
                //KRITHIKA DHARMARAJAN HOTFIX UAT START 22/06/2015
              if(letterPrintRequestCount != null){
                numberOfParallelJobs = letterPrintRequestCount/9000 + 1;
              if(numberOfParallelJobs < 5)  {
                numberOfParallelJobs = 5;
                 }
                 }
                 List<Batch_Control_Settings__c> batchJobsControlSettingsList = new List<Batch_Control_Settings__c>();
                 batchJobsControlSettingsList = [SELECT id,Number_of_Parallel_Jobs__c FROM Batch_Control_Settings__c where Name ='Number of Parallel Jobs'];
                 for(Batch_Control_Settings__c temp:batchJobsControlSettingsList)
                 {
                 system.debug('==============>updating customesetting');
                     //START 20 January 2016 D-4281 Kevin Evasco - Single callout to on-premise system for letter printing parallel jobs
                     temp.Number_of_Parallel_Jobs__c = 1;
                     //END 20 January 2016 D-4281 Kevin Evasco - Single callout to on-premise system for letter printing parallel jobs
                 }
                 update batchJobsControlSettingsList;
                 
               //KRITHIKA DHARMARAJAN HOTFIX END 22/06/2015 
                if(letterPrintRequestCount >= 45000) {
                    numberOfParallelJobs = letterPrintRequestCount/9000 + 1;
                }
                for(Integer counter = 0; counter < numberOfParallelJobs; counter++)
                {
                    batchJobSchedulerList.add(instantiateBatchJobScheduler(batchCode,daysBeforeExpiration,sessionId,true,letterPrintRequestCount, numberOfParallelJobs));
                }
            }
            else
            {            
                batchJobSchedulerList.add(instantiateBatchJobScheduler(batchCode,daysBeforeExpiration,sessionId,false,null,null));
            }
            
            if(batchJobSchedulerList.size() > 0)
            {
                Database.insert(batchJobSchedulerList);
            }
        }
        else if(action == 'Abort')
        {
            batchJobSchedulerList = [SELECT Id, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c batchJobScheduler WHERE Batch_Code__c = :batchCode AND Status__c = 'STARTED' LIMIT 1];

            if(batchJobSchedulerList.size() > 0)
            {
                BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
                System.abortJob((ID)batchJobScheduler.SFDC_Job_id__c);
                batchJobScheduler.Status__c = 'ABORTED';
                
                update batchJobScheduler;
            }
        }
    }
    
    private static BATCH_JOB_SCHEDULER__c instantiateBatchJobScheduler(String batchCode, Integer daysBeforeExpiration, String sessionId, Boolean allowParallelJobs, Integer letterPrintRequestCount, Integer numberOfParallelJobs) {
        BATCH_JOB_SCHEDULER__c batchJobScheduler = new BATCH_JOB_SCHEDULER__c();
        batchJobScheduler.Batch_Code__c = batchCode;
        batchJobScheduler.Batch_Run_Date__c = Date.today();
        batchJobScheduler.LP_Days_Before_Expiration__c = daysBeforeExpiration;
        batchJobScheduler.Start_Time__c = DateTime.now();
        batchJobScheduler.Status__c = 'STARTED';         
        batchJobScheduler.Session_ID__c = sessionId;         
        batchJobScheduler.Allow_Parallel_Jobs__c = allowParallelJobs;
        batchJobScheduler.Letter_Print_Request_Count__c = letterPrintRequestCount;      
        batchJobScheduler.Number_of_Parallel_Jobs__c = numberOfParallelJobs;    
        //Start D-4742 Raviteja 26Apr2016 - Capturing parent batch job schdduler record id
        if(parentBatchJobSchedulerId != Null){
            string shortID = string.valueOf(parentBatchJobSchedulerId).subString(0,15);
            for(BATCH_JOB_SCHEDULER__c  bjs : [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, 
                SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :parentBatchJobSchedulerId]){
                batchJobScheduler.Parent_Job__c = bjs.Id; 
            }
        }
        //End D-4742 Raviteja 26Apr2016 - Capturing parent batch job schdduler record id
        return batchJobScheduler;
    }
    //END 04/15/2015 D-2740 Kevin Evasco - Dynamic Number of Parallel Jobs for Infoprint
}