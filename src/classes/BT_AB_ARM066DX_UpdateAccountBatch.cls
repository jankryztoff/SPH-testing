/*
 * Class Name: BT_AB_ARM066DX_UpdateAccountBatch
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - ARM066DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for ARM066DX batch job. Used together with BT_AS_ARM066DX_UpdateAccountBatch Schedulable
 * 
 * History: 08/26/2014 Kevin Evasco Created Skeletal Apex Batchable
 * History: 09/24/2014 Renino Niefes added codes that retrieves data into the Datapool
 */


global class BT_AB_ARM066DX_UpdateAccountBatch implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    global final String query = 'SELECT ' +
                                '       CCRID__c, ' +
                                '       Account_Number__c, ' +
                                '       Account_Type__c, ' +
                                '       Credit_Term__c, ' +
                                '       Credit_Term_Reference__c, ' +
                                '       Credit_Limit_Internal__c, ' +
                                '       Credit_Limit_External__c, ' +   
                                '       Approved_Debt_Exposure_Amount__c, ' +
                                '       Debt__c, ' +
                                '       Update_ID__c, ' +
                                '       Update_Date__c, ' +
                                '       Update_Time__c, ' +
                                '       Business_Sector__c, ' +
                                '       SoaGroup__c, ' +
                                '       Company_Code__c, ' +
                                '       SOA_Suppression_Indicator__c, ' +
                                '       Transient_Indicator__c ' +
                                'FROM BT_CO_ARMS_UpdateAccountBatchFile__c ' +
                                'WHERE Status__c = \'new\' ';
                                
                                
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = 'ARM066DX'];
        delete resultList;
        
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
        List<BT_CO_ARMS_UpdateAccountBatchFile__c> armsList = new List<BT_CO_ARMS_UpdateAccountBatchFile__c>();

        for(sObject record : scope)
        {                       
            BT_CO_ARMS_UpdateAccountBatchFile__c armsRecord = (BT_CO_ARMS_UpdateAccountBatchFile__c) record;            
            armsRecord.Status__c = 'sent';
            armsList.add(armsRecord);
            
            String exportData = '';     
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            
            // Prepare Export Data
            exportData += armsRecord.CCRID__c + ',';
            exportData += armsRecord.Account_Number__c + ',';
            exportData += armsRecord.Account_Type__c + ',';
            exportData += armsRecord.Credit_Term__c + ',';
            exportData += armsRecord.Credit_Term_Reference__c + ',';
            exportData += armsRecord.Credit_Limit_Internal__c + ',';
            exportData += armsRecord.Credit_Limit_External__c + ',';
            exportData += armsRecord.Approved_Debt_Exposure_Amount__c + ',';
            exportData += armsRecord.Debt__c + ',';
            exportData += armsRecord.Update_ID__c + ',';
            exportData += armsRecord.Update_Date__c + ',';
            exportData += armsRecord.Update_Time__c + ',';
            exportData += armsRecord.Business_Sector__c + ',';
            exportData += armsRecord.SoaGroup__c + ',';
            exportData += armsRecord.Company_Code__c + ',';
            exportData += armsRecord.SOA_Suppression_Indicator__c + ',';
            exportData += armsRecord.Transient_Indicator__c;
            
            // Prepare Data Pool information here
            datapoolRecord.Name = 'ARM066DX';
            datapoolRecord.job_id__c = '1';
            datapoolRecord.group_id__c = 'Detail';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;             
            
            datapoolList.add(datapoolRecord);
        }   
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
            update armsList;  //comment it for now
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_ARM066DX_UpdateAccountBatch insert operation failed.');
        }
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
        //Get the batch run date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('ARM066DX');            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        //System.debug('*********************** inside final'+ this.query);
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID('ARM066DX');
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');        

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('ARM066DX');
    }
}