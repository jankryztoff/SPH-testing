/*
Author:
Class Name: BatchCalloutUtilityTest
TODO

*/

@isTest (SeeAllData = true)

public class BatchCalloutUtilityTest{
    static testMethod void batchCalloutUtilityTest(){
      /*  
        List<BATCH_JOB_SCHEDULER__c> batchId = [SELECT SFDC_Job_id__c,Id FROM BATCH_JOB_SCHEDULER__c LIMIT 200];
        
        BatchCalloutUtility.updateBatchSchedulerRecord(batchId[1].SFDC_Job_id__c);  
        
        List<Id> listId = new List<Id>(); 
        Id Ids;
        
        for(BATCH_JOB_SCHEDULER__c batch:batchId){
            Ids = batch.Id;
            listId.add(Ids);
        }
        system.assert(!listId.isEmpty());
        
        BatchCalloutUtility.invokeCalloutUtility(listId);   */
        
        BATCH_JOB_SCHEDULER__c batch = [SELECT SFDC_Job_id__c, Id FROM BATCH_JOB_SCHEDULER__c ORDER BY CreatedDate DESC LIMIT 1];
        
        system.assert(batch.Id!=null);
        
        BatchCalloutUtility.updateBatchSchedulerRecord(batch.SFDC_Job_id__c);  
        
        List<Id> listId = new List<Id>(); 
        listId.add(batch.Id);
        BatchCalloutUtility.invokeCalloutUtility(listId);
        
    }
    
    static testMethod void batchCalloutUtilityTest2(){
      /*  
        List<BATCH_JOB_SCHEDULER__c> batchId = [SELECT SFDC_Job_id__c,Id FROM BATCH_JOB_SCHEDULER__c LIMIT 200];
        
        BatchCalloutUtility.updateBatchSchedulerRecord(batchId[1].SFDC_Job_id__c);  
        
        List<Id> listId = new List<Id>(); 
        Id Ids;
        
        for(BATCH_JOB_SCHEDULER__c batch:batchId){
            Ids = batch.Id;
            listId.add(Ids);
        }
        system.assert(!listId.isEmpty());
        
        BatchCalloutUtility.invokeCalloutUtility(listId);   */
        
        BATCH_JOB_SCHEDULER__c batch = [SELECT SFDC_Job_id__c,Id,Status__c FROM BATCH_JOB_SCHEDULER__c WHERE Status__c =: 'Failed' ORDER BY CreatedDate DESC LIMIT 1];
        
        system.assert(batch.Id!=null);
        STP050DXSendQuotesToZuoraBatch batch3 = new STP050DXSendQuotesToZuoraBatch();
        BatchCalloutUtility.updateBatchSchedulerRecord(batch.SFDC_Job_id__c);  
        
        List<Id> listId = new List<Id>(); 
        listId.add(batch.Id);
        BatchCalloutUtility.invokeCalloutUtility(listId);
        
    }
    
/*   static testMethod void batchCalloutUtilityTest2(){
        
        List<BATCH_JOB_SCHEDULER__c> batchId = [SELECT SFDC_Job_id__c,Id FROM BATCH_JOB_SCHEDULER__c LIMIT 1];
        
        BatchCalloutUtility.updateBatchSchedulerRecord(batchId[0].SFDC_Job_id__c);  
        
        List<Id> listId = new List<Id>(); 
        Id Ids;
        
        for(BATCH_JOB_SCHEDULER__c batch:batchId){
            Ids = batch.Id;
            listId.add(Ids);
        }
        
        system.assert(!listId.isEmpty());
        
        BatchCalloutUtility.invokeCalloutUtility(listId);  
        
        }  */
}