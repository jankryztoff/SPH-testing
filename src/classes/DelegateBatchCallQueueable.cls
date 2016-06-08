/**
 * Class Name: DelegateBatchCallQueueable 
 * @author: Kevin Evasco
 * Date: 20 January 2016
 * Requirement/Project Name: Singapore Press Holdings
 * @description Queueable class for delegateBatchCall
 * History: 20 January 2016 D-4281 Kevin Evasco - Created queueable class.
 */


public class DelegateBatchCallQueueable implements Queueable, Database.allowsCallouts {
    
    String batchCode;
    Date batchRunDate;
    Boolean isSuccess;
    
    public DelegateBatchCallQueueable(String batchCode, Date batchRunDate, Boolean isSuccess) {
        this.batchCode = batchCode;
        this.batchRunDate = batchRunDate;
        this.isSuccess = isSuccess;
    }       
    
    public void execute(QueueableContext context) {
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(isSuccess ? 0 : 1);
        serviceRequestVO.setJobID(batchCode);
        serviceRequestVO.setJobDate(batchRunDate);
        System.debug('delegateBatchCall response: ' + a1F.delegateBatchCall(serviceRequestVO));   
    }
}