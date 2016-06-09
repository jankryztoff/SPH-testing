/**
 * Class Name: IntegrationDataPurgeBatch
 * @author: Evasco, Kevin   
 * Date: December 1, 2015
 * @description: For purging integration data 
 * @History: 01 December 2015 D-4003 - Created class for chained data purge batches    
 */
 
global class IntegrationDataPurgeBatch implements Database.Batchable<sObject>,Database.AllowsCallouts  {    
    global final String batchCode;
    global final String query;      
    
    global final Static String DIR094DX_DETAIL_DATAPURGE = 'DIR094DX_DETAIL_DATAPURGE';
    global final Static String DIR094DX_MASTER_DATAPURGE = 'DIR094DX_MASTER_DATAPURGE';
    global final Static String DIR094DX_DETAIL_DATAPURGE_SQL = 'SELECT Id FROM BT_CO_DIR_VendorPerformance__c';
    global final Static String DIR094DX_MASTER_DATAPURGE_SQL = 'SELECT Id FROM BT_CO_DIR_VendorPerformanceMaster__c';
    
    global IntegrationDataPurgeBatch (String batchCodeParam, String queryParam) {
        this.batchCode = batchCodeParam;
        this.query = queryParam;
    }   
    
    global Database.QueryLocator start(Database.BatchableContext BC) {     
        return Database.getQueryLocator(query);
    }
    
    //Delete records in batch - to manage the 10K DML Limit
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords) {
        try {
            delete lstRecords;
            Database.emptyRecycleBin(lstRecords);
        } catch(Exception e) {          
            if(!Test.isRunningTest()) {  
                Logger logger = new Logger (IntegrationDataPurgeBatch.class.getName(), batchCode, BC.getJobID());
                logger.logBatchFailure(e, lstRecords);
                logger.save();
                BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(batchCode.subString(0,batchCode.indexOf('_')));
                System.abortJob(BC.getJobID());
            } 
        }
    }        
    
    global void finish(Database.BatchableContext BC) {  
        if(batchCode == DIR094DX_DETAIL_DATAPURGE){
            IntegrationDataPurgeBatch detailDataPurge = new IntegrationDataPurgeBatch(DIR094DX_MASTER_DATAPURGE, DIR094DX_MASTER_DATAPURGE_SQL);
            Database.executeBatch(detailDataPurge,1000);
        } else if(batchCode == DIR094DX_MASTER_DATAPURGE){          
            BT_AB_DIR094DX_VendorPerformanceDirect batchJob = new BT_AB_DIR094DX_VendorPerformanceDirect();
            Database.executeBatch(batchJob);
        }           
    }
}