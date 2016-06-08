/*
 * Class Name: SP_InvoiceRecordPatcher
 * @author: Alyana Navarro/Kevin Evasco
 * Date: 08/20/2015
 * Project/Requirement: UD-2371
 * @description This class patches old invoice record that has PDF already generated on it. 
 */ 
global class SP_InvoiceRecordPatcher implements Database.Batchable<sObject>, Database.Stateful {
        
    global Database.QueryLocator start(Database.BatchableContext bc){
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = new List<BATCH_JOB_SCHEDULER__c>(); 
        
        batchJobSchedulerList = [SELECT id, name, CreatedDate, Start_Time__c
                            FROM BATCH_JOB_SCHEDULER__c 
                            WHERE Batch_Code__c = 'SP020' AND Status__c = 'SUCCESS'
                            ORDER BY CreatedDate DESC LIMIT 1];                     
                  
        //Start UD-3253 29-Feb-2016 Added By S.Puli
        //START 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
        if(batchJobSchedulerList.size() == 1){
            DateTime lastExecution = batchJobSchedulerList[0].Start_Time__c;            
            
            return Database.getQueryLocator([SELECT Id, Is_PDF_Generated__c, ARMS_Interface_Timestamp__c, CreatedDate, ARMS_invoice_id__c, Zuora__TotalAmount__c FROM Zuora__ZInvoice__c WHERE CreatedDate <=: lastExecution AND ((Is_PDF_Generated__c = false OR (ARMS_Interface_Timestamp__c = null AND ARMS_invoice_id__c != null AND Zuora__TotalAmount__c > 0)) OR (Zuora__TotalAmount__c < 0 AND Is_CN_Processed__c = false))]); 
        } else {
            return Database.getQueryLocator([SELECT Id, Is_PDF_Generated__c, ARMS_Interface_Timestamp__c, CreatedDate, ARMS_invoice_id__c, Zuora__TotalAmount__c FROM Zuora__ZInvoice__c WHERE ((Is_PDF_Generated__c = false OR (ARMS_Interface_Timestamp__c = null AND ARMS_invoice_id__c != null AND Zuora__TotalAmount__c > 0)) OR (Zuora__TotalAmount__c < 0 AND Is_CN_Processed__c = false))]);
        }        
        //END 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
        //End UD-3253 29-Feb-2016 Added By S.Puli
    }

    global void execute(Database.BatchableContext BC, List<Zuora__ZInvoice__c> scope){    
        for(Zuora__ZInvoice__c invoiceElement : scope) {
            invoiceElement.Is_PDF_Generated__c = true;
            
            //START 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
            if((invoiceElement.ARMS_Interface_Timestamp__c == null && invoiceElement.ARMS_invoice_id__c != null && invoiceElement.Zuora__TotalAmount__c > 0))
                invoiceElement.ARMS_Interface_Timestamp__c = invoiceElement.CreatedDate;                
            //END 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
            //Start UD-3253 29-Feb-2016 Added By S.Puli
            if(invoiceElement.Zuora__TotalAmount__c < 0 && invoiceElement.Is_CN_Processed__c == false){
                invoiceElement.Is_CN_Processed__c = true;
            }
            //End UD-3253 29-Feb-2016 Added By S.Puli
        }
        
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){        
    }
}