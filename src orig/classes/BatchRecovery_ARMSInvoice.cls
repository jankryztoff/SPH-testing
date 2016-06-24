global class BatchRecovery_ARMSInvoice implements Database.Batchable<sObject>,Database.AllowsCallouts  {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {   
        BT_CO_Batch_Run_Request__c batchRunRequest = [SELECT Id, Start_Time__c, End_Time__c FROM BT_CO_Batch_Run_Request__c WHERE Id = 'a16O0000004DOICIA4' LIMIT 1];
        return Database.getQueryLocator([SELECT Id, ARMS_Interface_Timestamp__c FROM Zuora__ZInvoice__c WHERE  
        ARMS_Interface_Timestamp__c = TODAY]);
    }
    
    //Delete records in batch - to manage the 10K DML Limit
    global void execute(Database.BatchableContext BC, List<Zuora__ZInvoice__c> lstRecords) {
        for(Zuora__ZInvoice__c invoiceElem : lstRecords){
            invoiceElem.ARMS_Interface_Timestamp__c =  null;
        }
        
        update lstRecords;
    }        
               
    global void finish(Database.BatchableContext BC) {
    }
}