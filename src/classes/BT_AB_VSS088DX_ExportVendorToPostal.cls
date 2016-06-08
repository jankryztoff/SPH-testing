/*
 * Class Name: BT_AB_VSS088DX_ExportVendorToPostal
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - VSS088DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for VSS088DX batch job. Used together with BT_AS_VSS088DX_ExportVendorToPostal Schedulable
 * 
 * History: 2014/08/26 Kevin Evasco Created Skeletal Apex Batchable
 * 			2014/09/18 Renino Niefes copy paste codes from CMI087DX 
 * 			2014/11/03 Renino Niefes updated the SOQL
 *			2015/03/11 Michael Francisco - updated to address D-2491
 */

global class BT_AB_VSS088DX_ExportVendorToPostal implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    //global final String query = 'SELECT Id, Vendor_Account__r.Vendor_Group__c, Vendor_Account__r.Vendor_Code__c, SingPost_Address__r.Name FROM Vendor_Allocation__c WHERE Status__c = \'Active\' AND Effective_Start_Date__c <= TODAY AND Effective_End_Date__c >= TODAY';
    global final String interfaceId = 'VSS088DX';
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
		// START D-2491 2015/03/11 Michael Francisco modified query to ensure full data dump         
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList;        
        String query = 'SELECT Id, Vendor_Account__r.Vendor_Group__c, Vendor_Account__r.Vendor_Code__c, SingPost_Address__r.Name FROM Vendor_Allocation__c ';
        query += ' WHERE Status__c = \'Active\' ';
		// END D-2491 2015/03/11 Michael Francisco 		
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
            Vendor_Allocation__c vendorAllocation = (Vendor_Allocation__c) record;
			// START D-2491 2015/03/11 Michael Francisco			
            String zValidationCode = '0';
			
			String zVendorGroup = vendorAllocation.Vendor_Account__r.Vendor_Group__c;
			String zVendorCode = vendorAllocation.Vendor_Account__r.Vendor_Code__c;
			String zPostalCode = vendorAllocation.SingPost_Address__r.Name;
			
			if (zVendorGroup == null || zVendorGroup.length() == 0) {
				zVendorGroup = 'V';
			} 

			if (zVendorCode != null && zVendorCode.length() > 0) {
				zValidationCode += '0';
			} else {
				zValidationCode += '1';
			}
			
			if (zPostalCode != null && zPostalCode.length() > 0) {
				zValidationCode += '0';
			} else {
				zValidationCode += '1';
			}
			
            String exportData = '';     
            exportData += zVendorGroup + ',';
            exportData += zVendorCode + ',';
            exportData += zPostalCode;
			if (Decimal.valueOf(zValidationCode) == 0) {
				// Prepare Data Pool information here
				BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
				datapoolRecord.Name = interfaceId;
				datapoolRecord.job_id__c = '1';
				datapoolRecord.group_id__c = 'Detail';
				datapoolRecord.run_for_date__c = Date.today();      
				datapoolRecord.insert_time__c = DateTime.now(); 
				datapoolRecord.export_data__c = exportData;
				
				datapoolList.add(datapoolRecord);
			} else {
				System.debug('ERROR:('+zValidationCode+') ID:['+record.Id+'] DATA:['+exportData+']');
			}
			// END D-2491 2015/03/11 Michael Francisco 			
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