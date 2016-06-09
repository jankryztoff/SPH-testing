/*
 * Class Name: BT_AB_VSS089DX_ExportZoneToPostal
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - VSS089DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for VSS089DX batch job. Used together with BT_AS_VSS089DX_ExportZoneToPostal Schedulable
 * 
 * History: 08/26/2014 Kevin Evasco Created Skeletal Apex Batchable
 * History: 09/18/2014 Renino Niefes added codes to retrieve data 
 * History: 11/03/2014 Renino Niefes code review
 * History: 17/12/2014 Wenjun D-1170 
 * History: 07-Jan-2015 Renino Niefes D-1170
 */


global class BT_AB_VSS089DX_ExportZoneToPostal implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    //START [D-1170 Wenjun 17/12/2014] : according to CCB036, mapping shall be stored in Postal_Zone__c
    //global final String query = 'SELECT Zone__c, Postal_Sector_Code__c FROM Post_Sector_Ops_Rep_Mapping__c'; 
    //START [D-1170 Renino Niefes 07-Jan-2015] Changed the field from .Name to .Postal_Zone__c as advised by Migration
	//START : Nitin Khanna :15-Sept-2015 : UD-2746 : changing the field mapping to pick the field from Postal_Zone_Name__c instead of Postal_Zone__c
    //global final String query = 'SELECT Postal_Zone__c, Postal_Sector__c FROM Postal_Zone__c';
	global final String query = 'SELECT Postal_Zone_Name__c, Postal_Sector__c FROM Postal_Zone__c';
    //End : Nitin Khanna :15-Sept-2015 : UD-2746 : changing the field mapping to pick the field from Postal_Zone_Name__c instead of Postal_Zone__c    
    //END [D-1170 Renino Niefes 07-Jan-2015]
    //END [D-1170 Wenjun 17/12/2014]
    global final String interfaceId = 'VSS089DX';
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
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
                
        for(sObject record : scope)
        {   
            //START [D-1170 Wenjun 17/12/2014]
            /* Commented Out because need to refer to another object : Postal_Zone__c
            Post_Sector_Ops_Rep_Mapping__c postSector = (Post_Sector_Ops_Rep_Mapping__c) record;
            String exportData = '';     
            exportData += postSector.Zone__c+ ',';
            exportData += postSector.Postal_Sector_Code__c ;
            */
            Postal_Zone__c zoneMapping = (Postal_Zone__c) record;
            String exportData = '';
            //START [D-1170 Renino Niefes 07-Jan-2015] Changed the field from .Name to .Postal_Zone__c as advised by Migration
			//START : Nitin Khanna :15-Sept-2015 : UD-2746 : changing the field mapping to pick the field from Postal_Zone_Name__c instead of Postal_Zone__c
			exportData += zoneMapping.Postal_Zone_Name__c + ',';
            //END : Nitin Khanna :15-Sept-2015 : UD-2746 : changing the field mapping to pick the field from Postal_Zone_Name__c instead of Postal_Zone__c            
            //END  [D-1170 Renino Niefes 07-Jan-2015]
            exportData += zoneMapping.Postal_Sector__c;
            //END [D-1170 Wenjun 17/12/2014]
            
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
            System.debug('BT_AB_' + interfaceId + '_ExportVendorToPostal insert operation failed.');
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