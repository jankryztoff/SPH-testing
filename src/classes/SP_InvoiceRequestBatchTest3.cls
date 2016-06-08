@isTest
public class SP_InvoiceRequestBatchTest3{
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createBatchInterface();        
    }  
    
       static testmethod void unitTest(){
    
            try{
                BATCH_JOB_SCHEDULER__c batchJob = new BATCH_JOB_SCHEDULER__c();
                batchJob.Batch_Code__c = 'SP020';
                batchJob.Status__c = 'SUCCESS';
                batchJob.Batch_Run_Date__c = date.Today() -60;
                insert batchJob;
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                insert acc;
                
                Set<Id> accountNumberset= new Set<Id>();
                accountNumberset.add(acc.id);
                
                Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c();
                invoice.Zuora__Zuora_Id__c = 'ABS123456';
                insert invoice;
                
                Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
                invoiceLineItem.Invoice_ID__c = 'ABS123456';
                insert invoiceLineItem; 
                
                
                
                Test.StartTest();
                SP_InvoiceRequestBatch batch = new SP_InvoiceRequestBatch('A', 4, 'sessionID', accountNumberset);
                ID batchprocessid = Database.executeBatch(batch,200);
               
               //Database.BatchableContext BC;
               // Database.QueryLocator ql = batch.start(BC);
                //batch.execute(BC, billAcc);
                //batch.finish(BC);
                Test.stopTest();
            }catch(Exception e){}
    }
    
    static testmethod void unitTest1(){
    
            try{
                BATCH_JOB_SCHEDULER__c batchJob = new BATCH_JOB_SCHEDULER__c();
                batchJob.Batch_Code__c = 'SP020';
                batchJob.Status__c = 'SUCCESS';
                batchJob.Batch_Run_Date__c = date.Today() -60;
                insert batchJob;
                
                Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                insert acc;
                
                Set<Id> accountNumberset= new Set<Id>();
                accountNumberset.add(acc.id);
                
                Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c();
                invoice.Zuora__Zuora_Id__c = 'ABS123456';
                insert invoice;
                
                Set<Id> inv = new Set<Id>();
                inv.add(invoice.Id);
                
                Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
                invoiceLineItem.Invoice_ID__c = 'ABS123456';
                insert invoiceLineItem; 
                
                
                
                Test.StartTest();
                SP_InvoiceRequestBatch batch = new SP_InvoiceRequestBatch('A', 4, 'sessionID', accountNumberset);
                ID batchprocessid = Database.executeBatch(batch,200);
               
               //Database.BatchableContext BC;
               // Database.QueryLocator ql = batch.start(BC);
                //batch.execute(BC, billAcc);
                //batch.finish(BC);
                Test.stopTest();
            }catch(Exception e){}
    }

}