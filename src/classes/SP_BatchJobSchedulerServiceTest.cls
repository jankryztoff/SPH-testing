/*
Class Name: SP_BatchJobSchedulerServiceTest


*/

@isTest (SeeAllData=True)
public class SP_BatchJobSchedulerServiceTest{
     static testmethod void testSP_BatchJobSchedulerService(){
        String letterType = 'Acknowledgment Letter';
        Integer batchCount = 5;
        String sessionId = 'testsession';
        
        List<Letter_Print_Request__c> lprList = new List<Letter_Print_Request__c>();
        
        Letter_Print_Request__c lpr = new Letter_Print_Request__c();
        lpr.Batch_Run_Sequence__c = 0;
        lpr.Status__c = 'Processing';
        lprList.add(lpr);
        
        insert lprList;   
        
        test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/SP_BatchJobSchedulerService';  
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        SP_BatchJobSchedulerService.processRequest('string','string1',1,'string3');
        SP_BatchJobSchedulerService.initializeBatches('SP041','Start',1,'string3',batchCount);
        SP_BatchJobSchedulerService.initializeBatches('ST000','Start',1,'string3',batchCount);
        SP_BatchJobSchedulerService.initializeBatches('SP041','Abort',1,'string3',batchCount);
        
        
        //BATCH_JOB_SCHEDULER__c batch = SP_BatchJobSchedulerService.instantiateBatchJobScheduler('string',1,'string1',true,1,batchCount);
        
        test.stopTest();
     }
}