/*
 * Class Name: BT_AB_CMI101DX_DirectSubNewspaper
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - CMI101DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for CMI101DX batch job. Used together with BT_AS_CMI101DX_DirectSubNewspaper Schedulable
 * 
 * History: 2014/08/26 Kevin Evasco Created Skeletal Apex Batchable
 * History: 2014/09/30 Renino Niefes Added code implementation
 * History: 2015/01/21 Angel Villamor Modified date format
 * History: 2015/03/03 Renino Niefes D-2421 (UAT Defect) Change the criteria in getting the records from vendor pop batch.  COmment out the delete statements in start block
 */


global class BT_AB_CMI101DX_DirectSubNewspaper implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    //global final String query = 'SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = \'CMI101DX Sample Source\'';    
    global final String interfaceId = 'CMI101DX';
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);
        String startDate = batchRunDate + 'T00:00:00Z';
        String endDate = batchRunDate + 'T23:59:59Z';
        
        //[START D-2421 2015-03-03 Renz] Change the query.  Get all records where subscription id is null, comment out the batch run date it's no longer needed
        String query = '';      
        query += ' SELECT Publication_Code__c,   ';
        query += '  Publication_Issue_Date__c, ';
        query += '  Vendor_Group__c, ';
        query += '  Vendor_Number__c,    ';
        query += '  Total_Direct_Subscriptions__c, ';
        query += '  Total_Sponsored_Copies__c,   ';
        query += '  Total_Local_Freelist_Copies__c,  ';
        query += '  Total_Local_Subscription_Copies__c,  ';
        query += '  Total_Overseas_Freelist_Copies__c, ';
        query += '  Total_Overseas_Subscription_Copies__c ';
        query += ' FROM Vendor_POP_Batch__c ';
        query += ' WHERE Subscription_Name__c = null AND CreatedDate >= '+startDate+' AND CreatedDate <= '+ endDate;
        //[END D-2421 2015-03-03 Renz]
        
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
        
            for(sObject record : scope)
        {  
            Vendor_POP_Batch__c popRecord = (Vendor_POP_Batch__c)record;
            
            String exportData = '';                     
                
            exportData += popRecord.Publication_Code__c + ',';
            //[START D-2421 2015-03-03 Renz]  Don't do formatting here.  Formatting will be handled in the java side
            exportData += popRecord.Publication_Issue_Date__c + ',';
            //[END D-2421 2015-03-03 Renz]  Don't do formatting here.  Formatting will be handled in the java side

            exportData += popRecord.Vendor_Group__c + ',';
            exportData += popRecord.Vendor_Number__c + ',';
            exportData += popRecord.Total_Direct_Subscriptions__c + ',';
            exportData += popRecord.Total_Sponsored_Copies__c + ',';
            exportData += popRecord.Total_Local_Freelist_Copies__c + ',';
            exportData += popRecord.Total_Local_Subscription_Copies__c + ',';
            exportData += popRecord.Total_Overseas_Freelist_Copies__c + ',';
            exportData += popRecord.Total_Overseas_Subscription_Copies__c;
            
            
            // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.Name = interfaceId;
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
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_CMI101DX_DirectSubNewspaper insert operation failed.');
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
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        //System.debug('*********************** inside final'+ this.query);
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