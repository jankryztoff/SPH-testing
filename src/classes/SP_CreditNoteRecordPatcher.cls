/*
 * Class Name: SP_CreditNoteRecordPatcher 
 * @author: Sherwin Puli
 * Date: 09/01/2015
 * Project/Requirement: UD-2361
 * @description This class patches old credit note record that has PDF already generated on it. 
 SP_CreditNoteRecordPatcher sp = new SP_CreditNoteRecordPatcher();
 Database.executeBatch(sp, 100);
 * @History: UD-3252 08-Mar-2016 Added By S.Puli - Updated for Credit Note Change Request
 */ 
global class SP_CreditNoteRecordPatcher implements Database.Batchable<sObject>, Database.Stateful {
    
    public List<Credit_Note__c> invoiceList = new List<Credit_Note__c>();
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = new List<BATCH_JOB_SCHEDULER__c>(); 
        
        //START 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
        batchJobSchedulerList = [SELECT id, name, CreatedDate, Start_Time__c
                            FROM BATCH_JOB_SCHEDULER__c 
                            WHERE Batch_Code__c = 'SP043' AND Status__c = 'SUCCESS'
                            ORDER BY CreatedDate DESC LIMIT 1];
							
		//START D-4588 04 April 2016 Kevin Evasco - Changed immediate CB data type and value
        //Start UD-3253 29-Feb-2016 Added By S.Puli                   
        if(batchJobSchedulerList.size() == 1){
            DateTime lastExecution = batchJobSchedulerList[0].Start_Time__c;            
            
            return Database.getQueryLocator([SELECT Id, Is_PDF_Generated__c, To_ARMS_Time__c, CreatedDate FROM Credit_Note__c WHERE CreatedDate <=: lastExecution AND (Is_PDF_Generated__c = false OR To_ARMS_Time__c = null)]);
        } else {
            return Database.getQueryLocator([SELECT Id, Is_PDF_Generated__c, To_ARMS_Time__c, CreatedDate, Source_Invoice__r.Immediate_CB__c FROM Credit_Note__c WHERE Is_PDF_Generated__c = false OR (To_ARMS_Time__c = null AND Source_Invoice__r.Immediate_CB__c != 'Y')]);
        }
        //END 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
        //End UD-3253 29-Feb-2016 Added By S.Puli		
		//END D-4588 04 April 2016 Kevin Evasco - Changed immediate CB data type and value
    }

    global void execute(Database.BatchableContext BC, List<Credit_Note__c> scope){
        
        //Start UD-3253 29-Feb-2016 Added By S.Puli
        for(Credit_Note__c creditNoteElement : scope) {
            creditNoteElement.Is_PDF_Generated__c = true;
            //START 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
            if(creditNoteElement.To_ARMS_Time__c == null)
                creditNoteElement.To_ARMS_Time__c = creditNoteElement.CreatedDate;
            //END 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
        }
        //End UD-3253 29-Feb-2016 Added By S.Puli
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }

}