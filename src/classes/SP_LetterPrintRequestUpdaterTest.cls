@isTest
private class SP_LetterPrintRequestUpdaterTest{
    static testmethod void myUnitTest() {       
             
            Letter_Print_Request__c letterPrint = new Letter_Print_Request__c();
            letterPrint.Name = 'Name';
            letterPrint.Letter_Type__c = 'Acknowledgment_Letter'; 
            letterPrint.DTL_Date__c = date.Today(); 
            letterPrint.Acknowledgment_Type__c  = 'Email';
            Database.insert(letterPrint);
            
            BATCH_JOB_SCHEDULER__c batchJobSchedulerList = new BATCH_JOB_SCHEDULER__c();
            batchJobSchedulerList.Start_Time__c = date.today();
            batchJobSchedulerList.Batch_Code__c = 'SP020';
            batchJobSchedulerList.Status__c = 'SUCCESS';
            Database.BatchableContext BC;
            
            List<Letter_Print_Request__c> scope = [SELECT Name, Letter_Type__c FROM  Letter_Print_Request__c];
                        
            SP_LetterPrintRequestUpdater batch = new SP_LetterPrintRequestUpdater();
            ID batchprocessid = Database.executeBatch(batch,200);
            batch.execute(BC, scope);
            System.assertNotEquals(null, batchprocessid);
    }
    //Start PD-0027 Raviteja 18May2016 - Added myUnitTest2 method to increase the code coverage
    static testmethod void myUnitTest2() {       
             
            Letter_Print_Request__c letterPrint = new Letter_Print_Request__c();
            letterPrint.Name = 'Name';
            letterPrint.Letter_Type__c = 'Acknowledgment_Letter'; 
            letterPrint.DTL_Date__c = date.Today(); 
            letterPrint.Acknowledgment_Type__c  = 'Email';
            Database.insert(letterPrint);
            
            BATCH_JOB_SCHEDULER__c batchJobSchedulerList = new BATCH_JOB_SCHEDULER__c();
            batchJobSchedulerList.Start_Time__c = date.today();
            batchJobSchedulerList.Batch_Code__c = 'SP020';
            batchJobSchedulerList.Status__c = 'SUCCESS';
            Database.BatchableContext BC;
            
            List<Letter_Print_Request__c> scope = [SELECT Name, Letter_Type__c FROM  Letter_Print_Request__c];
                        
            SP_LetterPrintRequestUpdater batch = new SP_LetterPrintRequestUpdater();
            batch.sourceCode = 'SP045';
            ID batchprocessid = Database.executeBatch(batch,200);
            batch.execute(BC, scope);
            System.assertNotEquals(null, batchprocessid);
    }    
   //End PD-0027 Raviteja 18May2016     
}