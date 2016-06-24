/*
 * Class Name: BT_AB_SMS104DX_SMSBulkOutboundFile
 * @author: Nitin Khanna
 * Date: 2016/02/25
 * Project/Requirement: SPH Integration - DIR105DX Interface
 * CR # NCR-016
 */

global class BT_AB_DIR105DX_BuildingCodeValidation implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // TO-DO: Create a custom setting to store all Integration Batch InterfaceID values ...
    global final String interfaceId = 'DIR105DX';
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList;  

        Set<String> SMS_Status_Set = new Set<String>();
        SMS_Status_Set.add('New');
        
        String query = '';
        query += ' SELECT ';
        query += '    house_type__c, building_type_code__c ';
        query += ' FROM BuildingCodeToHouseTypeMapping__c ';    
        
        return Database.getQueryLocator(query);
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {       
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        for (sObject record : scope)
        {
            BuildingCodeToHouseTypeMapping__c rec = (BuildingCodeToHouseTypeMapping__c) record;
            if (rec != null) {
                String exportData = '';
                exportData += rec.House_Type__c + ',';
                exportData += rec.Building_Type_Code__c + ',';
                BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
                datapoolRecord.Name = interfaceId;
                datapoolRecord.job_id__c = '1';
                datapoolRecord.group_id__c = 'Detail';
                datapoolRecord.run_for_date__c = Date.today();      
                datapoolRecord.insert_time__c = DateTime.now(); 
                datapoolRecord.export_data__c = exportData;
                datapoolList.add(datapoolRecord);           
            } 
        }
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_DIR105DX_BuildingCodeValidationInterface DATAPOOL insert operation failed.');
        }
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
        //Get the batch run date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID(interfaceId);
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');        

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);
    }
}