/*
 * Class Name: BT_AB_ARM063DX_CreateAccountBatch
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - ARM063DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for ARM063DX batch job. Used together with BT_AS_ARM063DX_CreateAccountBatch Schedulable
 * 
 * History: 08/26/2014 Kevin Evasco Created Skeletal Apex Batchable
 * History: 09/22/2014 Renino Niefes added codes. created custom object for source data.  Online Integration to put data into it.
 * History: 11/04/2014 Renino Niefes added callout codes
 */


global class BT_AB_ARM063DX_CreateAccountBatch implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    global final String query = 'SELECT CCRID__c, '+
                                '       Company_Code__c, '+
                                '       Account_Type__c, '+
                                '       Credit_Term__c, '+
                                '       Credit_Term_Refererence__c, '+
                                '       Credit_Limit_Internal__c, '+
                                '       Credit_Limit_External__c, '+
                                '       Approved_Debt_Exposure_Amount__c, '+
                                '       Debt_Management_Treatment__c, '+
                                '       Creator_ID__c, '+
                                '       Business_Sector__c, '+
                                '       SOA_Group__c, '+
                                '       SOA_Suppression_Indicator__c, '+
                                '       Transient_Indicator__c, '+
                                '       Retrieve_Account_Indicator__c '+
                                'FROM BT_CO_ARMS_CreateAccountBatchFile__c  '+
                                'WHERE Status__c = \'new\'';
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = 'ARM063DX'];
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
        List<BT_CO_ARMS_CreateAccountBatchFile__c> armsList = new List<BT_CO_ARMS_CreateAccountBatchFile__c>();
                
        for(sObject record : scope)
        {                       
            BT_CO_ARMS_CreateAccountBatchFile__c armsRecord = (BT_CO_ARMS_CreateAccountBatchFile__c) record;            
            armsRecord.Status__c = 'sent';
            armsList.add(armsRecord);
            
            String exportData = '';     
            exportData += armsRecord.CCRID__c + ',';
            exportData += armsRecord.Company_Code__c + ',';
            exportData += armsRecord.Account_Type__c + ',';
            exportData += armsRecord.Credit_Term__c + ',';
            exportData += armsRecord.Credit_Term_Refererence__c + ',';
            exportData += armsRecord.Credit_Limit_Internal__c + ',';
            exportData += armsRecord.Credit_Limit_External__c + ',';
            exportData += armsRecord.Approved_Debt_Exposure_Amount__c + ',';
            exportData += armsRecord.Debt_Management_Treatment__c + ',';
            exportData += armsRecord.Creator_ID__c + ',';
            exportData += armsRecord.Business_Sector__c + ',';
            exportData += armsRecord.SOA_Group__c + ',';
            exportData += armsRecord.SOA_Suppression_Indicator__c + ',';
            exportData += armsRecord.Transient_Indicator__c + ',';
            exportData += armsRecord.Retrieve_Account_Indicator__c;
            
            // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.Name = 'ARM063DX';
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
            update armsList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_ARM063DX_CreateAccountBatch insert operation failed.');
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
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('ARM063DX');            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        //System.debug('*********************** inside final'+ this.query);
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID('ARM063DX');
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');        

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('ARM063DX');
    }
}