/*
 * Class Name: BT_DEV_Debugger
 * @author: Renno Niefes
 * Date: 09/24/2014
 * Project/Requirement: SPH Integration - Interface Tools
 * @description This class sets the end time of Batch Run Request Object
 * 
 * History: 09/24/2014 Renino Niefes  written the this class
 */

public class BT_DEV_Debugger 
{
    List<BA_INT_DATA_POOL__c> debugList = new List<BA_INT_DATA_POOL__c>();
    
   public void addDebugLogs(String interfaceId, String messageLog)
    {
        BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
        datapoolRecord.Name = interfaceId+'_DEBUG';
        datapoolRecord.job_id__c = '1';
        datapoolRecord.group_id__c = 'Debug';
        datapoolRecord.run_for_date__c = Date.today();      
        datapoolRecord.insert_time__c = DateTime.now(); 
        datapoolRecord.export_data__c = messageLog;
                
        debugList.add(datapoolRecord);  
        
    }
    
    public void saveDebugLogs()
    {
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            //insert datapoolList;
            insert debugList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('Debugger failed to save the list');
        }
    }
    
    public void clearDebugLogs(String interfaceId)
    {
        interfaceId += '_DEBUG';
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList;                  

    }
    
}