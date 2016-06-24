/*
 * Class Name: SP_CreditCardFailureRequestBatch
 * @author: Kevin H. Evasco
 * Date: 11/09/2014
 * Project/Requirement: Letter Printing - Credit Card Failure Notification
 * @description This class generates Credit Card Failure Notification Letter Print Requests
 * 
 * History: 11/09/2014 Kevin Evasco Created Apex Batch
 * History: 12/05/2014 D-0797, D-0849 Kevin Evasco Added new constructor to enable storage of Session ID.
 * History: 10/15/2015 Added by Kristine Balaoing - batch recovery
 */

global class SP_CreditCardFailureRequestBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    String letterType;
    Integer batchCount;
    String sessionId;
    List<Letter_Print_Request__c> letterPrintRequests = new List<Letter_Print_Request__c>();

    //START: D-3663 10/08/2015 Added by Kristine Balaoing - batch recovery
    //START: D-3754 10/15/2015 Added by Kristine Balaoing - batch recovery
    List<Id> extPaymentIdList = new List<Id>();
    Boolean isAdhocDate = false;
    Boolean isAdhocId = false;
    Date refDate;
    Boolean isApexJobSuccessful = true;
    //END: D-3754 10/15/2015 Added by Kristine Balaoing - batch recovery
    //END: D-3663 10/08/2015 Added by Kristine Balaoing - batch recovery

    public static final String creditCard = 'Credit Card';
    
    // START: 12/05/2014 D-0797, D-0849 Kevin Evasco Added new constructor to enable storage of Session ID.
    //START: D-3663 10/08/2015 Added by Kristine Balaoing - batch recovery
    global SP_CreditCardFailureRequestBatch(String letterType, Integer batchCount, String sessionId, Set<Id> extPaymentIds, Date createDate)
    {
        this.letterType = letterType;
        this.batchCount = batchCount;
        this.sessionId = sessionId;
                
        if(extPaymentIds <> null){
            extPaymentIdList.addAll(extPaymentIds);
            isAdhocId = true;
        }
        if(createDate <> null){
            isAdhocDate = true;
            refDate  = createDate;
        }
    }
    //END: D-3663 10/08/2015 Added by Kristine Balaoing - batch recovery
    // END: 12/05/2014 D-0797, D-0849 Kevin Evasco Added new constructor to enable storage of Session ID.
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //START 02 May 2016 UD-3872 Kevin Evasco - Added Is PDF Generated = false
        //START: D-3663 10/08/2015 Added by Kristine Balaoing - batch recovery
        String query = '';
        if(isAdhocDate){
            query += 'SELECT Id, CreatedDate FROM External_Payment__c ';
            query += 'WHERE Payment_Type__c = :creditCard AND CreatedDate = :refDate';
        }else if(isAdhocId){
            query += 'SELECT Id, CreatedDate FROM External_Payment__c ';
            query += 'WHERE Payment_Type__c = :creditCard AND ID IN :extPaymentIdList AND Is_PDF_Generated__c = false';
        }
        else {
            //START UD-2556 08/31/2015 added by Jason A./Alyana N.
            Date dateYesterday = Date.Today() -1; 
            query += 'SELECT Id, CreatedDate FROM External_Payment__c ';
            query += 'WHERE Payment_Type__c = :creditCard AND CreatedDate = YESTERDAY AND Is_PDF_Generated__c = false'; //START UD-3316 Gdelrosario: changed to yesterday
        }
        //END 02 May 2016 UD-3872 Kevin Evasco - Added Is PDF Generated = false
        return Database.getQueryLocator(query);
        //END: D-3663 10/08/2015 Added by Kristine Balaoing - batch recovery
        //END UD-2556 08/31/2015 added by Jason A./Alyana N.
    }
     
    /* @description Generates Acknowledgment Letter for Newly Created Subscriptions.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<External_Payment__c> scope)
    {
        //START: D-3663 10/08/2015 Added by Kristine Balaoing - batch recovery
        //START: D-3754 10/08/2015 Added by Kristine Balaoing - batch recovery
        //Logger logger = new Logger(SP_CreditCardFailureRequestBatch.class.getName(), 'SP019', BC.getJobID());
        //START D-3920 5-Nov-2015 Joyrem Zarmaine Ayuman- edited logger start
        Logger logger;
        
        if(!Test.isRunningTest()) {
            logger = new Logger (SP_CreditCardFailureRequestBatch.class.getName(), 'SP019', BC.getJobID());
            
            }//START D-3920 5-Nov-2015 Joyrem Zarmaine Ayuman- edited logger end
        
        
        Savepoint sp = Database.setSavepoint();
        try{
            letterPrintRequests = new List<Letter_Print_Request__c>(); //START/END 04/15/2015 D-2740 Kevin Evasco - Needs to initiliaze list to avoid inserting records with IDs already
            
            //START 02 May 2016 UD-3872 Kevin Evasco - Generate CCF PDFs only once by marking IS PDF Generated = true
            for(External_Payment__c batchObject : scope)
            {
                Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                letterPrintRequest.Letter_Type__c = letterType;
                letterPrintRequest.Record_ID__c = batchObject.Id;
                letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;

                letterPrintRequests.add(letterPrintRequest);
                batchObject.Is_PDF_Generated__c = true;
            }

            if(letterPrintRequests.size() > 0)
            {
                insert letterPrintRequests;
                update scope;
            }           
            //END 02 May 2016 UD-3872 Kevin Evasco - Generate CCF PDFs only once by marking IS PDF Generated = true
        }catch(Exception e){
            Database.rollback(sp);
            logger.logBatchFailure(e, scope);
            logger.save();
            
            isApexJobSuccessful = false;
        }
        //END: D-3754 10/08/2015 Added by Kristine Balaoing - batch recovery
        //END: D-3663 10/08/2015 Added by Kristine Balaoing - batch recovery
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
       //START: D-3663 10/08/2015 Added by Kristine Balaoing - interchanged logic to catch error 'You have uncommitted work pending.Please commit or rollback before calling out
        //START 04/14/2015 D-2740 Kevin Evasco - Utilized the Batch Job Helper
        //START: D-3754 10/08/2015 Added by Kristine Balaoing - batch recovery
        //START: D-4264 1-12-2016 Added by Kristine Balaoing - added logging mechanism
        List<Exception> exceptionList = new List<Exception>();
        try{
            //Start D-4482 - Raviteja Kumar - calling updateBatchJobScheduler method 
            /*if(!isApexJobSuccessful){
                BatchJobHelper.updateJobStatus(BC.getJobId(), false);
            }else{
                BatchJobHelper.updateJobStatus(BC.getJobId(), true);
            }
            */
            BatchJobHelper.updateBatchJobScheduler(BC.getJobId(), isApexJobSuccessful);
            //End D-4482 - Raviteja Kumar - calling updateBatchJobScheduler method
            //END: D-3754 10/08/2015 Added by Kristine Balaoing - batch recovery
            // START: 12/05/2014 D-0797, D-0849 Kevin Evasco Added the Session ID Parameter
            //Start D-4742 Raviteja 26Apr2016 - Capturing batch job schdduler record id            
            SP_BatchJobSchedulerService.setParentBatchJobSchedulerId(BC.getJobId());  
            //End D-4742 Raviteja 26Apr2016 - Capturing batch job schdduler record id
            SP_BatchJobSchedulerService.processRequest('SP027','Start', null, sessionId);
            //END: D-3663 10/08/2015 Added by Kristine Balaoing
            // END: 12/05/2014 D-0797, D-0849 Kevin Evasco Added the Session ID Parameter
            /* REMOVED FOR D-2740
            String shortID = String.valueOf(BC.getJobId()).subString(0,15);
            List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :BC.getJobId()];

            if(batchJobSchedulerList.size() > 0)
            {
                BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
                batchJobScheduler.Status__c = 'SUCCESS';
                batchJobScheduler.End_Time__c = DateTime.now();
                update batchJobScheduler;           
                
                //System.debug('*********************** inside final'+ this.query);
                BatchServiceFacade a1F = new BatchServiceFacade();
                BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
                serviceRequestVO.setJobStatus(0);
                serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
                serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
                System.debug('################ before');
                a1F.delegateBatchCall(serviceRequestVO);
                System.debug('################ after');             
            }
            REMOVED FOR D-2740 */       
            //END 04/14/2015 D-2740 Kevin Evasco - Utilized the Batch Job Helper
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        
        //END: D-4264 1-12-2016 Added by Kristine Balaoing
    }
    
}