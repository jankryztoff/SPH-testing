/*
 * Class Name: SP_LetterPrintRequestUpdater 
 * @author: Sherwin Puli
 * Date: 09/09/2015
 * Project/Requirement: D-3535
 * @description This class patches old Letter Print Request that are still "New". 
 */ 
global class SP_LetterPrintRequestUpdater implements Database.Batchable<sObject>, Database.Stateful {
    
    public List<Letter_Print_Request__c> invoiceList = new List<Letter_Print_Request__c>();
    public String sessionId;
    public Integer requestCount;
    public String letterType;
    public String batchCode;
    public String parentjobid; //Start-End PD-0027 09-May-2016 Added By Raviteja Kumar - add variable for source batch code 
    //START UD-2847 22-Sept-2015 Added By S.Puli - add variable for source batch code
    public String sourceCode;
    //END UD-2847 22-Sept-2015 Added By S.Puli
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = new List<BATCH_JOB_SCHEDULER__c>(); 
        //START UD-2847 22-Sept-2015 Added By S.Puli - add variable for source batch code
        //STAR D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter
        if(sourceCode == null || sourceCode == ''){
            batchJobSchedulerList = [SELECT id, name, CreatedDate, Start_Time__c
                            FROM BATCH_JOB_SCHEDULER__c 
                            WHERE Batch_Code__c = 'SP020' AND Status__c = 'SUCCESS'
                            ORDER BY CreatedDate DESC LIMIT 1];
        }else if(sourceCode== 'SP045'){
            batchJobSchedulerList = [SELECT id, name, CreatedDate, Start_Time__c
                            FROM BATCH_JOB_SCHEDULER__c 
                            WHERE Batch_Code__c = :sourceCode AND Status__c = 'SUCCESS'
                            AND CreatedDate = YESTERDAY LIMIT 1];
        }else{
            batchJobSchedulerList = [SELECT id, name, CreatedDate, Start_Time__c
                            FROM BATCH_JOB_SCHEDULER__c 
                            WHERE Batch_Code__c = :sourceCode AND Status__c = 'SUCCESS'
                            ORDER BY CreatedDate DESC LIMIT 1];
        }
        //END D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter  
        //END UD-2847 22-Sept-2015 Added By S.Puli - add variable for source batch code  
        //Start D-4449 11-MAr-2016 Added by S.Puli - update to avoid first run issue
		if(batchJobSchedulerList.size() == 1){
            DateTime lastExecution = batchJobSchedulerList[0].Start_Time__c;            
            
            return Database.getQueryLocator([SELECT Id, Letter_Type__c,Status__c FROM Letter_Print_Request__c WHERE CreatedDate <: lastExecution AND Status__c = :SP_GenerateLetterPrintBatch.newValue AND Letter_Type__c = :letterType]);
        } else {
            return Database.getQueryLocator([SELECT Id, Letter_Type__c,Status__c FROM Letter_Print_Request__c WHERE Status__c = :GlobalVariableClass.STATUS_PENDING AND Letter_Type__c = :letterType]);
        }
        //End D-4449 11-MAr-2016 Added by S.Puli
    }

    global void execute(Database.BatchableContext BC, List<Letter_Print_Request__c> scope){
    
        for(Letter_Print_Request__c lpr : scope) {
            lpr.Status__c = SP_GenerateLetterPrintBatch.failedValue;
        }
        
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
        //Start PD-0027 Raviteja 09May2016 - Capturing batch job schdduler record id            
        SP_BatchJobSchedulerService.setParentBatchJobSchedulerId(parentjobid);  
        //End PD-0027 Raviteja 09May2016 - Capturing batch job schdduler record id
        SP_BatchJobSchedulerService.initializeBatches(batchCode,'Start', null, sessionId,requestCount);
    }
}