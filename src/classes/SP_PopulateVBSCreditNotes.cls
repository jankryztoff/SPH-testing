/*
 * Class Name: SP_PopulateVBSCreditNotes
 * @author: Kevin H. Evasco
 * Date: 03/19/2015
 * Project/Requirement: SPH Integration
 * 
 * History: 03/19/2015 Kevin Evasco Created Apex Batchable
 * UD-3618 07-Jan-2016 Added by Raviteja - Restructure the class
 */


global class SP_PopulateVBSCreditNotes implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    global final String batchCode;
    global final Id jobId;  
    global Date startDate;
    global Date endDate;       
    
    Boolean isApexJobSuccessful = true; 
    
    public SP_PopulateVBSCreditNotes(String batchCodeParam, Id jobIdParam)
    {
        batchCode = batchCodeParam;
        jobId = jobIdParam;        
       
        if(batchCode != 'SP002'){
            startDate = Date.today().toStartOfMonth();
            endDate = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
        } else {            
            startDate = Date.today()-1;
            endDate = Date.today();
        }        
    }    
   
    public SP_PopulateVBSCreditNotes(String batchCodeParam, Id jobIdParam, Date manualstartDate, Date manualendDate)
    {
        batchCode = batchCodeParam;
        jobId = jobIdParam;         
        startDate = manualstartDate;
        endDate = manualendDate;               
    } 
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {       
        return Database.getQueryLocator([SELECT Id, Job_Id__c, Vendor_Number__c, Note_Number__c, Reason_Code__c, Credit_Debit__c , Amt_Before_GST__c 
                                                        FROM BT_CO_VBS_CreditDebit__c 
                                                            WHERE Job_Id__c = :batchCode AND Note_Number__c = NULL 
                                                                    AND Posting_Date__c >= :startDate AND Posting_Date__c <= :endDate]);
    }
    
    /* @description Instantiates VDC_CREDITNOTE__c records
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<BT_CO_VBS_CreditDebit__c> scope)
    {                              
        Logger logger = new Logger(SP_VBSManualCreditBatch.class.getName(), 'SP002', BC.getJobID()); 
        Savepoint sp = Database.setSavepoint();
        
        try {
            Set<String> vendorNumberSet = new Set<String>();
            Set<String> reasonCategorySet = new Set<String>();
            Set<String> creditDebitIndicatorSet = new Set<String>();                 
            Map<String, VDC_CREDITNOTE__c> creditNotesMap = new Map<String, VDC_CREDITNOTE__c>();
            
            
            for(BT_CO_VBS_CreditDebit__c batchRecord : scope)
            {
                vendorNumberSet.add(batchRecord.Vendor_Number__c);
                reasonCategorySet.add(SP_PopulateVDCCreditNotes.getReasonCodeCategory(batchRecord.Reason_Code__c));
                creditDebitIndicatorSet.add(batchRecord.Credit_Debit__c);
            }
            creditNotesMap = SP_PopulateVDCCreditNotes.getCreditNotesMap(vendorNumberSet,reasonCategorySet, creditDebitIndicatorSet);
        
        
            for(BT_CO_VBS_CreditDebit__c batchRecord : scope)
            {
                VDC_CREDITNOTE__c creditNoteRecord = creditNotesMap.get(SP_PopulateVDCCreditNotes.constructCreditNoteKey(batchRecord));                
                if(creditNoteRecord != null && batchRecord.Amt_Before_GST__c != 0)             
                {
                    batchRecord.Note_Number__c = creditNoteRecord.Credit_Note_Number__c;
                }
            }
            
            update scope;
        } catch (Exception e){
            Database.rollback(sp);
            logger.logBatchFailure(e, scope);
            logger.save();
            
            isApexJobSuccessful = false;
        }       
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
        system.debug('============>'+jobId);
        BatchJobHelper.updateJobStatus(jobId);//KRITHIKA DHARMARAJAN HOTFIX
    }
}