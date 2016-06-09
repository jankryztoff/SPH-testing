/*
 * Class Name: SP_PopulateManualCreditNotes
 * @author: Kevin H. Evasco
 * Date: 03/19/2015
 * Project/Requirement: SPH Integration
 * 
 * History: 03/19/2015 Kevin Evasco Created Apex Batchable
 * UD-3618 07-Jan-2016 Added by Raviteja - Restructure the class
 */


global class SP_PopulateManualCreditNotes implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    global final String batchCode;
    global final Id jobId;   
    global Boolean isManualrun = False;
    global Date startDate;
    global Date endDate;  
    
    Boolean isApexJobSuccessful = true; 
    
    public SP_PopulateManualCreditNotes(String batchCodeParam, Id jobIdParam)
    {
        batchCode = batchCodeParam;
        jobId = jobIdParam;
        startDate = Date.today();
        if(batchCodeParam == 'SP002')
            startDate = Date.today()-1;
        endDate = Date.today();    
    }   
  
    public SP_PopulateManualCreditNotes(String batchCodeParam, Id jobIdParam,Date manualstartdate,Date manualenddate)
    {
        batchCode = batchCodeParam;
        jobId = jobIdParam;
        startDate = manualstartdate;
        endDate = manualenddate;
        isManualrun = True;
    }  
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {                  
            return Database.getQueryLocator([SELECT Id, Vendor__r.Vendor_Group__c, Vendor__r.Vendor_Code__c, Publication__r.Publication_Code__c, Case__c, 
                                                            Case__r.RecordType.DeveloperName, Case__r.Contact_To_Update__c, Credit_Debit_Indicator__c, Amt_After_GST__c,
                                                            Approval_Date__c, Credit_Debit_Vendor_Reason__c 
                                                            FROM Manual_Vendor_Credits_Debits__c 
                                                            WHERE Status__c = 'Approved' AND  Approval_Date__c >= :startDate  AND Approval_Date__c <= :endDate 
                                                                    AND Vendor__r.Vendor_Group__c != null AND Vendor__r.Vendor_Code__c != null 
                                                                    AND Credit_Debit_Note_Number__c = NULL AND Status__c = 'Approved']);      
    }
    
    /* @description Instantiates VDC_CREDITNOTE__c records
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<Manual_Vendor_Credits_Debits__c> scope)
    {                              
        Logger logger = new Logger(SP_PopulateManualCreditNotes.class.getName(), 'SP002', BC.getJobID()); 
        Savepoint sp = Database.setSavepoint();
        
        try {
            Set<String> vendorNumberSet = new Set<String>();           
            Set<String> reasonCategorySet = new Set<String>{'01','02','03','04'};            
            Set<String> creditDebitIndicatorSet = new Set<String>();        
            Map<String, VDC_CREDITNOTE__c> creditNotesMap = new Map<String,VDC_CREDITNOTE__c >();            
            
            for(Manual_Vendor_Credits_Debits__c batchRecord : scope)
            {
                vendorNumberSet.add(batchRecord.Vendor__r.Vendor_Code__c);
                creditDebitIndicatorSet.add(batchRecord.Credit_Debit_Indicator__c);
            }
            creditNotesMap = SP_PopulateVDCCreditNotes.getCreditNotesMap(vendorNumberSet,reasonCategorySet, creditDebitIndicatorSet);
        
        
            for(Manual_Vendor_Credits_Debits__c batchRecord : scope)
            {
                VDC_CREDITNOTE__c creditNoteRecord = creditNotesMap.get(SP_PopulateVDCCreditNotes.constructCreditNoteKey(batchRecord));               
                if(creditNoteRecord != null && batchRecord.Amt_After_GST__c > 0)               
                {
                    batchRecord.Credit_Debit_Note_Number__c = creditNoteRecord.Credit_Note_Number__c;
                    batchRecord.Job_Id__c = 'SP002';
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
        SP_PopulateVSSCreditNotes batchInstance;
        if(isManualrun){
            batchInstance = new SP_PopulateVSSCreditNotes(batchCode, jobId, startDate, endDate);
            Database.executeBatch(batchInstance);
        }else{
            batchInstance = new SP_PopulateVSSCreditNotes(batchCode, jobId);
            Database.executeBatch(batchInstance); 
        }                      
    }
}