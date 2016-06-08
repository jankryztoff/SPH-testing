/**
 * Class Name:  SP_VSSManualCreditBatch
 * @author: Zhu, Wenjun
 * Date: 11 March 2015
 * Requirement/Project Name: CRSM Project
 * @description: This is the entry point for VDC - Manual Vendor Credit / Debit.
                 This job will process 'Approved" Manual Vendor Credit/Debit Records and save into VSS Table
 * UD-3618 07-Jan-2016 Added by Raviteja - Restructure the class                 
 */
 
global class  SP_VSSManualCreditBatch implements Database.Batchable<sObject> {    
    
   
    global Date startDate;
    global Date endDate; 
    global Boolean ismanualRun = False;  
    Boolean isApexJobSuccessful = true;
    
    global SP_VSSManualCreditBatch(){       
        //startDate = Date.today();
        startDate = Date.today()-1;
        endDate = Date.today();
    }
    
    global SP_VSSManualCreditBatch(Date startDateX, Date endDateX){
        startDate = startDateX;
        endDate = endDateX;
        ismanualRun = True;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {     
        //Fetch all the "Approved" but not "Processed" records        
        String query = 'SELECT Credit_Debit_Vendor_Reason__c, Id, Vendor__r.Vendor_Group__c, Vendor__r.Vendor_Code__c, Publication__r.Publication_Code__c, Case__c, Subscription__c,  ';
        query += 'Case__r.RecordType.DeveloperName, Case__r.Contact_To_Update__c, Credit_Debit_Indicator__c, Amt_After_GST__c, Approval_Date__c,From_Date__c,To_Date__c ';         
        query += 'FROM Manual_Vendor_Credits_Debits__c WHERE Status__c = \'Approved\' AND Approval_Date__c >= :startDate  AND Approval_Date__c <= :endDate AND Credit_Debit_Note_Number__c = Null ';        
        query += ' AND Vendor__r.Vendor_Group__c != null AND Vendor__r.Vendor_Code__c != null';
        return Database.getQueryLocator(query);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Manual_Vendor_Credits_Debits__c> lstRecords) {       
        Logger logger = new Logger(SP_VSSManualCreditBatch.class.getName(), 'SP002', BC.getJobID()); 
        Savepoint sp = Database.setSavepoint();
        
        try {
            List<BT_CO_VSS_CreditDebit__c> lstNew = new List<BT_CO_VSS_CreditDebit__c> ();
            String RT_START = GlobalVariableClass.RT_CASE_START;
            String RT_COA = GlobalVariableClass.RT_CASE_COA;
            Set<Id> setCaseIds = new Set<Id>();          
            
            for(Manual_Vendor_Credits_Debits__c mdcRec : lstRecords)
            {              
                    setCaseIds.add(mdcRec.Case__c);
            }           
            
            for(Manual_Vendor_Credits_Debits__c mdcRec : lstRecords)
            {
                BT_CO_VSS_CreditDebit__c tempRec = new BT_CO_VSS_CreditDebit__c();
                
                    tempRec.Posting_Date__c = mdcRec.Approval_Date__c; 
                    tempRec.Credit_Debit__c = mdcRec.Credit_Debit_Indicator__c;
                    tempRec.Vendor_Number__c = mdcRec.Vendor__r.Vendor_Code__c;
                    tempRec.Vendor_Group__c = mdcRec.Vendor__r.Vendor_Group__c;
                    tempRec.Publication_Code__c = mdcRec.Publication__r.Publication_Code__c;
                    tempRec.Manual_Amt__c = mdcRec.Amt_After_GST__c;
                    tempRec.Total_Amount__c = mdcRec.Amt_After_GST__c;                
                    tempRec.From__c = mdcRec.From_Date__c;
                    tempRec.To__c = mdcRec.To_Date__c;                   
                    tempRec.Subscription__c = mdcRec.Subscription__c;                    
                    tempRec.Manual_VDC_reason_code__c = mdcRec.Credit_Debit_Vendor_Reason__c;              
                    tempRec.Job_Id__c = 'SP002'; 
                    lstNew.add(tempRec);
            }
            
            if(!lstNew.isEmpty())
                INSERT lstNew;
        } catch(Exception e) {
            Database.rollback(sp);
            logger.logBatchFailure(e, lstRecords);
            logger.save();
            
            isApexJobSuccessful = false;
        }
        
    }        
               
    global void finish(Database.BatchableContext BC) {   
    
        Id jobID = BC.getJobId();     
        SP_VBSManualCreditBatch batchJob;
        
        if(ismanualRun){
            batchJob = new SP_VBSManualCreditBatch(jobID,startDate,endDate);
        }else{
            batchJob = new SP_VBSManualCreditBatch(jobID);
        }
        
        Database.executeBatch(batchJob, 2);
    }
}