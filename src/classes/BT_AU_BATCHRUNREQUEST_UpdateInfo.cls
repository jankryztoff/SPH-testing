/*
 * Class Name: BT_AB_BATCHRUNREQUEST_UpdateInfo
 * @author: Renno Niefes
 * Date: 09/24/2014
 * Project/Requirement: SPH Integration - Interface Tools
 * @description This class sets the end time of Batch Run Request Object
 * 
 * History: 09/24/2014 Renino Niefes  written the this class
 */

public class BT_AU_BATCHRUNREQUEST_UpdateInfo 
{
    public static void updateEndTime(String interfaceId)
    {
        List<BT_CO_Batch_Run_Request__c> brrList = [SELECT End_Time__c,Id,Interface_ID__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = :interfaceId AND End_Time__c = null ORDER BY CreatedDate DESC];
        List<BT_CO_Batch_Run_Request__c> brrListForUpdate = new List<BT_CO_Batch_Run_Request__c>();

        if(brrList.size() == 0)
        {
            System.debug('No active batch has been found for this interface.');
        }
        else if(brrList.size() > 1)
        {
            System.debug('More than 1 active batches have been detected. Please investigate.');
        }
        else
        {
            for (BT_CO_Batch_Run_Request__c brrRecord: brrList)
            {
                brrRecord.End_Time__c = DateTime.now();
                brrListForUpdate.add(brrRecord);
            }

            // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback. 
            Savepoint savepointBeforeDML = Database.setSavepoint();
            try
            {
                update brrListForUpdate;
            }
            catch(Exception e)
            { 
                // Execute Database Rollback 
                Database.rollback(savepointBeforeDML);
                System.debug(interfaceId + ' - Batch Run Request update operation failed.');
            } 
        }
    }
    
    //Gets the previous batch's start time
    public static String getStartTime(String interfaceId)
    {
        List<BT_CO_Batch_Run_Request__c> brrList = [SELECT Id, Start_Time__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = :interfaceId AND End_Time__c != null ORDER BY CreatedDate DESC];
        DateTime prevCutOffDate;
        
        for (BT_CO_Batch_Run_Request__c brrRecord: brrList)
        {
            prevCutOffDate = brrRecord.Start_Time__c;
            break;
        }
        
        //if this is the first run, use current date.
        if (prevCutOffDate==null)       
        {
            prevCutOffDate = DateTime.now();
        }

        return  prevCutOffDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');  
    }
    
    //Gets the current batch run date
    public static String getBatchRunDate(String interfaceId)
    {
        List<BT_CO_Batch_Run_Request__c> brrList = [SELECT Id, Batch_Run_Date__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = :interfaceId AND End_Time__c = null ORDER BY CreatedDate DESC];
        DateTime batchRunDate;
        
        for (BT_CO_Batch_Run_Request__c brrRecord: brrList)
        {
            batchRunDate = brrRecord.Batch_Run_Date__c;
            break;
        }
        
        //if this is the first run, use current date.
        if (batchRunDate==null)     
        {
            batchRunDate = DateTime.now();
        }

        return  batchRunDate.format('yyyy-MM-dd');
    }   
    
    //START 10 March 2016 UD-3247 Kevin Evasco - Added abortJob and delegateBatchCall utility methods
    public static void abortJob(String jobId, String className, String batchCode, Exception exceptionParam, Boolean isFuture)
    {
        if(isFuture)
            delegateBatchFutureCall(batchCode,true);
        else
            delegateBatchCall(batchCode, false);        
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(batchCode);
        Logger logger = new Logger(className, batchCode);
        logger.log(exceptionParam);
        logger.save();
        System.abortJob(jobId);
    }
    
    public static void delegateBatchCall(String batchCode, Boolean isSuccess){
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(batchCode);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
        
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(isSuccess ? 0 : 1);
        serviceRequestVO.setJobID(batchCode);
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');             
    }
    
    @future(callout=true)
    public static void delegateBatchFutureCall(String batchCode, Boolean isSuccess){
        delegateBatchCall(batchCode, isSuccess);            
    }
    //END 10 March 2016 UD-3247 Kevin Evasco - Added abortJob and delegateBatchCall utility methods
}