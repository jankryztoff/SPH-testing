/**
 * Class Name: DataPurgeBatch
 * @author: Zhu, Wenjun
 * Date: 24 Feb 2015
 * @description: For purging data   
 */
 
global class DataPurgeBatch implements Database.Batchable<sObject>,Database.AllowsCallouts  {    
    global final String query;  
    
    global DataPurgeBatch (String strInput)
    {
        this.query = strInput;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {     
        return Database.getQueryLocator(query);
    }
    
    //Delete records in batch - to manage the 10K DML Limit
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords) {
        DELETE lstRecords;
        Database.emptyRecycleBin(lstRecords);
    }        
    
    global void finish(Database.BatchableContext BC) {
        BatchJobHelper.updateJobStatus(BC.getJobId()); //START-END KRITHIKA DHARMARAJAN HOTFIX      
    }
}