/*
 * Class Name: BatchServiceRequestVOTest
 * @author: Francisco Lino U. Ano
 * Date: 02/17/2015
 * Project/Requirement: 
 * @description: to test BatchServiceRequestVO class
 */

@isTest(SeeAllData = True)
private class BatchServiceRequestVOTest{

    /**
    *  To test BatchServiceRequestVO
    *  @name BatchServiceRequestVOunit
    *  @param none
    *  @return none
    *  @throws na
    */    
    static testmethod void BatchServiceRequestVOunit(){
        Test.startTest();
        
        integer jobstat;
        string jobid;
        Date jobDate;
        
        BatchServiceRequestVO bsrv = new BatchServiceRequestVO();        
             
        bsrv.setJobStatus(2);
        jobstat=bsrv.getJobStatus();
        
        bsrv.setJobID('TXS001');
        jobid = bsrv.getJobID();
        
        bsrv.setJobDate(date.today());
        jobDate = bsrv.getJobDate();
        
        system.assertNotEquals(null, jobid);
        
        Test.stopTest();
    }    
}//END EOF