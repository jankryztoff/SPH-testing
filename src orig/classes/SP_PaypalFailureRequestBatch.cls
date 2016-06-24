/*
 * Class Name: SP_PaypalFailureRequestBatch
 * @author: Alyana Navarro/Jason Abolac/George Del Rosario
 * Date: 9/10/2015  
 * Project/Requirement: Letter Printing - PayPal Failure Notification
 * @description This class generates PayPal Notification Letter Print Requests for UD-2634
 */
//START: D3729 10/15/2015 Added by Kristine Balaoing - added for Batch Recovery using selective Ids
global class SP_PaypalFailureRequestBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    String letterType;
    Integer batchCount;
    String sessionId;
    List<Letter_Print_Request__c> letterPrintRequests = new List<Letter_Print_Request__c>();
    Boolean isApexJobSuccessful = true;
    //START D-4080 Gdelrosario : added instantiation for code review
    Set<Id> failedRecIds = new Set<Id>();
    //END D-4080 Gdelrosario : added instantiation for code review
    Boolean isAdhoc = false;
    //START D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter
    Date refDate;
    //END D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter


    global SP_PaypalFailureRequestBatch(String letterType, Integer batchCount, String sessionId)
    {
        this.letterType = letterType;
        this.batchCount = batchCount;
        this.sessionId = sessionId;
       
    }


    //START D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter
    //START D-3952 Gdelrosario 19/11/15 : change variable to paymentids
    global SP_PaypalFailureRequestBatch(String letterType, Integer batchCount, String sessionId, Set<Id> exPaymentIds){
            this.letterType = letterType;
            this.batchCount = batchCount;
            this.sessionId = sessionId;
            this.failedRecIds = exPaymentIds;
            this.isAdhoc = true;
            
    }
    //END: D3729 10/15/2015 Added by Kristine Balaoing
    //END D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter

    //START: D3729 10/15/2015 Added by Kristine Balaoing - added for Batch Recovery using selective Ids
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        if(isAdhoc){
            //START D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter
            //START D-3952 Gdelrosario 19/11/15 : change the query to external payment
            query += 'SELECT id, name, CreatedDate ';
            query += 'FROM External_Payment__c ';
            query += 'WHERE Id IN :failedRecIds AND Payment_Type__c = \'PayPal\' ';
            query += 'AND Billing_Account__r.Zuora__PaymentMethod_Type__c = \'PayPal\' ';
            //query += 'AND      = false AND Billing_Account__r.Zuora__PaymentMethod_Type__c = \'PayPal\' ';
            //END D-3952 Gdelrosario 19/11/15 : change the query to external payment
            //END D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter
        }else{
            //START D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter
            //START D-3952 Gdelrosario 19/11/15 : change the query to external payment
            query += 'SELECT id, name, CreatedDate ';
            query += 'FROM External_Payment__c ';
            query += 'WHERE Payment_Type__c = \'PayPal\' ';
            //query += 'AND CreatedDate  = YESTERDAY AND Billing_Account__r.Zuora__PaymentMethod_Type__c = \'PayPal\' ';
            query += 'AND CreatedDate  = Today AND Billing_Account__r.Zuora__PaymentMethod_Type__c = \'PayPal\' ';
            //query += 'AND Is_PDF_Generated__c = false AND Billing_Account__r.Zuora__PaymentMethod_Type__c = \'PayPal\' ';
            //END D-3952 Gdelrosario 19/11/15 : change the query to external payment
            //END D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter
        }
        return Database.getQueryLocator(query);
    }
    //END: D3729 10/15/2015 Added by Kristine Balaoing
    //START: D3729 10/15/2015 Added by Kristine Balaoing - added to add exception logger
    //START D-3952 Gdelrosario 19/11/15 : change the query to external payment
    global void execute(Database.BatchableContext BC, List<External_Payment__c> scope) {
    //END D-3952 Gdelrosario 19/11/15 : change the query to external payment
             //START D-3920-Nov-2015 April Grace Veloso- edited logger start
            Logger logger; 
            if(!Test.isRunningTest())//Added by April Grace Veloso to skip logger error - nov 9, 2015
            { 
                logger = new Logger(SP_PaypalFailureRequestBatch.class.getName(), 'SP045', BC.getJobID());
            } //START D-3920-Nov-2015 April Grace Veloso- edited logger end
        
        try{
            letterPrintRequests = new List<Letter_Print_Request__c>();
            //START D-3952 Gdelrosario 19/11/15 : change the query to external payment
            for(External_Payment__c batchObject : scope) {
            //END D-3952 Gdelrosario 19/11/15 : change the query to external payment
                Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                letterPrintRequest.Letter_Type__c = letterType;
                letterPrintRequest.Record_ID__c = batchObject.Id;
                letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;

                letterPrintRequests.add(letterPrintRequest);
            }
            
            if(letterPrintRequests.size() > 0) {
                insert letterPrintRequests;
            }
        }catch(Exception e){
            logger.logBatchFailure(e, scope);
            logger.save();
            
            isApexJobSuccessful = false;
       }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        //START: D- 4265 1-13-2016 Added by Kristine Balaoing - added logging mechanism
        Logger loggerFinish;
        
        if(!Test.isRunningTest()){
            loggerFinish = new Logger('SP_PaypalFailureRequestBatch', 'SP045');
        }
        
        try{
            if(!isApexJobSuccessful){
                BatchJobHelper.updateJobStatus(BC.getJobId(), false);
            }else{
                BatchJobHelper.updateJobStatus(BC.getJobId(), true);
            }
            //START D-3783 20-Oct-2015 Added By S.Puli - insert logic of letter print request updater
            Integer requestCount = null;
            letterType = SP_GenerateLetterPrintBatch.FAILED_PAYPAL_NOTIFICATION ;
            
            List<Letter_Print_Request__c> letterRequests_LIST = new List<Letter_Print_Request__c>();
        //STAR D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter
            List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT id, name, CreatedDate, Start_Time__c
                                FROM BATCH_JOB_SCHEDULER__c 
                                WHERE Batch_Code__c = 'SP045' AND Status__c = 'SUCCESS'
                                AND CreatedDate = YESTERDAY];
        //END D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter
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
        //START D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter
            if(letterRequests_LIST.size()>0 && !isAdhoc){
        //end D-3930 Gdelrosario 23/11/2015 : added to cater a new parameter
                SP_LetterPrintRequestUpdater sp = new SP_LetterPrintRequestUpdater();
                sp.sessionId =  sessionId;
                sp.requestCount = requestCount;
                sp.letterType = letterType;
                sp.batchCode = 'SP047';
                sp.sourceCode = 'SP045';
                Database.executeBatch(sp, 100);
            } else {
                SP_BatchJobSchedulerService.initializeBatches('SP047','Start', null, sessionId,requestCount);
            }
            //END D-3783 20-Oct-2015 Added By S.Puli
        }catch(Exception e){
            loggerFinish.log(e);
            loggerFinish.save();
        }
        //END: D- 4265 1-13-2016 Added by Kristine Balaoing
    }
    //END: D3729 10/15/2015 Added by Kristine Balaoing
}