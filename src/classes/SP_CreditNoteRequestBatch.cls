/*
 * Class Name: SP_CreditNoteRequestBatch 
 * @author: Sherwin Puli
 * Date: 08/31/2015
 * Project/Requirement: UD-2361
 * @description This class creates letter print request for credit notes, batch code: SP043
 * @History: UD-2847 22-Sept-2015 S.Puli Added logic for letter print request updater to avoid duplicate letter print requests
 * @History: UD-3253 08-Mar-2016 Added By S.Puli - Updated for Credit Note Change Request
 */ 
global class SP_CreditNoteRequestBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    public List<Letter_Print_Request__c> letterPrint_List = new List<Letter_Print_Request__c>();
    
    //START UD-3656 Gdelrosario : removed as per defect solution presented in the attach email of defect. Updatng of the custom setting is moved to SP043    
    //public Other__c creditNoteNumber = new Other__c();
    //List<Credit_Note__c> creditList = new List<Credit_Note__c>();
    //Integer latestCreditNote = 0;
    //END UD-3656 Gdelrosario : removed as per defect solution presented in the attach email of defect. Updatng of the custom setting is moved to SP043 

    //START UD-2847 22-Sept-2015 Added By S.Puli - insert logic of letter print request updater
    //START: D-3668 10/20/2015 Added by Kristine Balaoing - added for selective batch run
    String letterType = '';
    String sessionId = UserInfo.getSessionId();
    Integer requestCount = 0;
    Boolean isAdhoc = false;
    Set<Id> failedRecs = new Set<Id>();
    Boolean isApexJobSuccessful = true;
    
    //END UD-2847 22-Sept-2015 Added By S.Puli
    global SP_CreditNoteRequestBatch(){
        
    }
    
    global SP_CreditNoteRequestBatch(Set<Id> creditNoteIds){
        this.failedRecs = creditNoteIds;
        this.isAdhoc = true;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        String query = '';
        if(isAdhoc){
            //Start D-4614 02-Apr-2016 Added By S.Puli - to prevent download of LPR
            //START UD-3656 Gdelrosario : removed as per defect solution presented in the attach email of defect. Updatng of the custom setting is moved to SP043
            //START PD-0036 05042016 Gdelrosario : added query on the creation of letterPrintRequest becuase we need to check GST Invoice on account level
            //START PD-0442 Fritz : prnt for Account GST Invoice indicator
            query += 'SELECT Id, Is_PDF_Generated__c,Source_Invoice__r.Immediate_CB__c, Billing_Account__r.Zuora__Account__r.GST_Invoice__c,';
            query += ' Billing_Account__r.Other_PaymentMethod__c ';
            query += 'FROM Credit_Note__c ';
            query += 'WHERE ID IN :failedRecs';
        }else{
            query = 'SELECT Id, Is_PDF_Generated__c,Source_Invoice__r.Immediate_CB__c, Billing_Account__r.Zuora__Account__r.GST_Invoice__c, ';
            query += ' Billing_Account__r.Other_PaymentMethod__c ';
            query += 'FROM Credit_Note__c ';
            query += 'WHERE Is_PDF_Generated__c = false';
            //END PD-0442 Fritz : prnt for Account GST Invoice indicator
            //END PD-0036 05042016 Gdelrosario : added query on the creation of letterPrintRequest becuase we need to check GST Invoice on account level
            //END UD-3656 Gdelrosario : removed as per defect solution presented in the attach email of defect. Updatng of the custom setting is moved to SP043
            //End D-4614 02-Apr-2016 Added By S.Puli - to prevent download of LPR
        }
        //Start PD-0137 10-Apr-2016 Added by S.Puli 
        if(Test.isRunningTest()){
                query += ' Limit 1';
        }
        //End PD-0137 10-Apr-2016 Added by S.Puli 
        system.debug('query: '+ query);
        return Database.getQueryLocator(query);
        
    }

    global void execute(Database.BatchableContext BC, List<Credit_Note__c> scope){

        Logger logger = new Logger(SP_CreditNoteRequestBatch.class.getName(), 'SP043', BC.getJobID());
        
        try{
            for(Credit_Note__c cnRec : scope) {
            
                Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.creditNotes;
                letterPrintRequest.Record_ID__c = cnRec.Id;
                letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;
                //Start D-4614 02-Apr-2016 Added By S.Puli - to prevent download of LPR
                //Start PD-0137 10-Apr-2016 Added by S.Puli - to merge logic of immediate CB and GST Invoice
                //START D-4588 04 April 2016 Kevin Evasco - Changed immediate CB data type and value
                              
                //END D-4588 04 April 2016 Kevin Evasco - Changed immediate CB data type and value
                //End D-4614 02-Apr-2016 Added By S.Puli
                //START PD-0036 05042016 Gdelrosario : added filter on the creation of letterPrintRequest becuase we need to check GST Invoice on account level
                //START PD-0442 Fritz : prnt for Account GST Invoice indicator
                if(cnRec.Billing_Account__r.Zuora__Account__r.GST_Invoice__c == GlobalVariableClass.TS_YES 
                || cnRec.Billing_Account__r.Other_PaymentMethod__c == GlobalVariableClass.INVOICE){  //used only available yes from GlobalVariableClass regardless of module
                //END PD-0442 Fritz : prnt for Account GST Invoice indicator
                    letterPrintRequest.Printable__c = true;
                    if(cnRec.Source_Invoice__r.Immediate_CB__c == 'Y'){
                        letterPrintRequest.Downloaded__c = false;
                        letterPrintRequest.Printable__c  = false;
                    } 
                }
                //END PD-0036 05042016 Gdelrosario : added filter on the creation of letterPrintRequest becuase we need to check GST Invoice on account level
                //End PD-0137 10-Apr-2016 Added by S.Puli - to merge logic of immediate CB and GST Invoice
                letterPrint_List.add(letterPrintRequest); 

            }
            
            if(!letterPrint_List.isEmpty()){  

                Database.insert(letterPrint_List, false);  
                //START UD-2847 22-Sept-2015 Added By S.Puli
                requestCount += letterPrint_List.size();
                //END UD-2847 22-Sept-2015 Added By S.Puli
            }
        }catch(Exception e){
            logger.logBatchFailure(e, scope);
            logger.save();
                    
            isApexJobSuccessful = false;

        }
    }
    
    global void finish(Database.BatchableContext BC){
        //START HotFix 09-Sep-2015 Added by Raviteja - applying New Logic for job exist automatically in Ctrl+M
        /*
        String shortID = String.valueOf(BC.getJobId()).subString(0,15);
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :BC.getJobId()];

        if(batchJobSchedulerList.size() > 0)
        {                   
            BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
            batchJobScheduler.Status__c = 'SUCCESS';
            batchJobScheduler.End_Time__c = DateTime.now();
        
            update batchJobScheduler;         
        }
        */
        //START: D-4263 1-11-2016 Added by Kristine Balaoing - added logging mechanism
        Logger logger = new Logger(SP_CreditNoteRequestBatch.class.getName(), 'SP043', BC.getJobID());
        
        //START D-4482 14-Mar-2016 Added by Raviteja - Fetching Job status for letter Print Request job
        Boolean isSucess;   
        isSucess = BatchJobHelper.getJobStatus(letterType,'SP043',SP_GenerateLetterPrintBatch.newValue);        
        
        try{
            // if(!isApexJobSuccessful){
            if(!isApexJobSuccessful || !isSucess){        
                BatchJobHelper.updateJobStatus(BC.getJobId(), false);
                //BatchJobHelper.updateBatchJobScheduler(BC.getJobId(), false); 
            }else{
                BatchJobHelper.updateJobStatus(BC.getJobId(), true);
                //BatchJobHelper.updateBatchJobScheduler(BC.getJobId(), true);
                //End D-4482 14-Mar-2016 Added by Raviteja 
            }
            
           //End HotFix 09-Sep-2015 Added by Raviteja 
            //START UD-2847 22-Sept-2015 Added By S.Puli - insert logic of letter print request updater
            letterType = SP_GenerateLetterPrintBatch.creditNotes;
            
            List<Letter_Print_Request__c> letterRequests_LIST = new List<Letter_Print_Request__c>();
            
            List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT id, name, CreatedDate, Start_Time__c
                                FROM BATCH_JOB_SCHEDULER__c 
                                WHERE Batch_Code__c = 'SP043' AND Status__c = 'SUCCESS'
                                ORDER BY CreatedDate DESC LIMIT 1];
            if(batchJobSchedulerList.size() > 0){
                DateTime lastExecution = batchJobSchedulerList[0].Start_Time__c;
                letterRequests_LIST = [SELECT Id,Letter_Type__c,Status__c, CreatedDate FROM Letter_Print_Request__c 
                                                                WHERE CreatedDate <: lastExecution AND Letter_Type__c = :letterType AND Status__c = :SP_GenerateLetterPrintBatch.newValue LIMIT 1];
            }
            else{
                //START D-4449 14April2016 Added By C. Lin - Change SP_GenerateLetterPrintBatch.newValue to GlobalVariableClass.STATUS_PENDING
                letterRequests_LIST = [SELECT Id,Letter_Type__c,Status__c FROM Letter_Print_Request__c 
                                                                WHERE Letter_Type__c = :letterType AND Status__c = :GlobalVariableClass.STATUS_PENDING LIMIT 1];
                //END D-4449 14April2016 Added By C. Lin
            }
            
            if(letterRequests_LIST.size()>0){
                SP_LetterPrintRequestUpdater sp = new SP_LetterPrintRequestUpdater();
                sp.sessionId =  sessionId;
                sp.requestCount = requestCount;
                sp.letterType = letterType;
                sp.batchCode = 'SP026';
                sp.sourceCode = 'SP043';
                //Start PD-0137 10-Apr-2016 Added by S.Puli 
                if(!Test.isRunningTest()){
                    Database.executeBatch(sp, 100);
                }
                //End PD-0137 10-Apr-2016 Added by S.Puli
            } else {
                //Start PD-0137 10-Apr-2016 Added by S.Puli 
                if(!Test.isRunningTest()){
                    SP_BatchJobSchedulerService.initializeBatches('SP026','Start', null, sessionId,requestCount);
                }
                //End PD-0137 10-Apr-2016 Added by S.Puli
            }
            //END UD-2847 22-Sept-2015 Added By S.Puli
            //END: D-3668 10/20/2015 Added by Kristine Balaoing
        }catch (Exception e){
            logger.log(e);
            logger.save();
        }
        
        //END: D-4263 1-11-2016 Added by Kristine Balaoing
    }
}