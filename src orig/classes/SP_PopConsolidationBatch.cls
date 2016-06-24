/**
 * Class Name: SP_PopConsolidationBatch
 * @author: Zhu, Wenjun
 * Date: 23 Feb 2015
 * Requirement/Project Name: CRSM Project
 * @description: This is the entry point of POP Process. It is to purge all the existing MIRO records. 
                 After this, it will start the SP_PopConsolidationBatchMain    
 * Raviteja - 17-Aug-2105 - No need of Retrofix. Removed the Publication SOQL and added Limit 0. As per Nitin as of now we are not using this class.
 */
//START/End UD-3043 07-Oct-2015 Added by Raviteja - Adding Database.AllowsCallouts
global class SP_PopConsolidationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts  {    

    global Boolean overrideFlg = false;
    global Date ovdFromDate = Date.today();

    global SP_PopConsolidationBatch(){}
    
    global SP_PopConsolidationBatch(Date fromDate){
        overrideFlg = true;
        ovdFromDate = fromDate;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {             
        //Fetch all the existing MIRO Records        
        String query = 'Select Id from BT_CO_MIRO_SubscriptionIssueFile__c ';   
        //String query = 'Select Id from BT_CO_MIRO_SubscriptionIssueFile__c limit 500';   
             
        return Database.getQueryLocator(query);
    }
    
    //Delete MIRO records in batch - to manage the 10K DML Limit
    global void execute(Database.BatchableContext BC, List<BT_CO_MIRO_SubscriptionIssueFile__c> lstRecords) {        
    //START UD-3043 07-Oct-2015 Added by Raviteja - Applying Try catch block in order to handle the Exception , failed records and Abort the job if exception occured 
    try{
        //System.debug('Error: '+2/0);                      
        DELETE lstRecords;
       } 
      catch (Exception e) {  
            Id JOB_ID = BC.getJobId();       
            BatchJobHelper.handleException(lstRecords,e,SP_PopConsolidationBatch.class.getName(),'SP012',JOB_ID,Null,True);
        }  
      //End UD-3043 07-Oct-2015 Added by Raviteja      
        //START/End HotFix 17-Sep-2015 Added by Raviteja
        //Database.emptyRecycleBin(lstRecords);
    }        
               
    global void finish(Database.BatchableContext BC) {   
        Id jobID = BC.getJobId();
        //START UD-3043 07-Oct-2015 Added by Raviteja - Stop the chain batch job proccess if current batch job status not equals to Completed or NumberOfErrors > 0
        Boolean isJobSucess = BatchJobHelper.isJobSucesss(jobID);
        if(isJobSucess){
            SP_PopConsolidationBatchMain batchJob;
            
            //Start the Main Process for POP - Default Size 200
            if(overrideFlg)
                batchJob = new SP_PopConsolidationBatchMain(jobID, ovdFromDate);
            else
                batchJob = new SP_PopConsolidationBatchMain(jobID);
            
            Database.executeBatch(batchJob);
        }
        //End UD-3043 07-Oct-2015 Added by Raviteja
    }
}