/**
 * Trigger Name: BT_AT_CMI100DX_NumberOfVendorInserts
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - CMI100DX Interface
 * Description: This trigger contains the business logic for CMI100DX interface.
 *
 * History: 2014/08/21 Kevin Evasco 		- Created Skeletal Apex Trigger
 * 			2014/09/22 Kevin Evasco 		- Updated to implement business logic
 * 			2015/01/29 Renino Niefes 		- Updated the business logic.  
 *											  To get records for update, you must use three fields, 
 *											  publication code, issue date and vendor number
 * 			2015/02/16 Renino Niefes 		- Code Review (Novasuite Audit Findings)         
 *			2015/03/10 Michael Francisco 	- Modified to address D-2458 CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY:
 *											  BT_AT_CMI100DX_NumberOfVendorInserts: execution of BeforeInsert
 */

trigger BT_AT_CMI100DX_NumberOfVendorInserts on BT_CO_CMIS_POP_NumberOfVendorInserts__c (before insert, before update) 
{
    
    List<BT_CO_CMIS_POP_NumberOfVendorInserts__c> recordsList = trigger.new;
            
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';    
    
    //[START D-1966 Renz Niefes 2015-01-29] Add/remove variables
    List<Vendor_Inserts__c> vendorInsertsForInsert = new List<Vendor_Inserts__c>();    
    List<Vendor_Inserts__c> vendorInsertsForUpdate = new List<Vendor_Inserts__c>();    
    //List<ID> vendorInsertsIDsForUpdate = new List<ID>();
    
	/* START 2015/03/10 D-2458 Michael Francisco - Refactor vendorInsertsList to vendorUpdatesList
										Created new Set to store PublicationIssueDate data 
	*/	
	List<Vendor_Inserts__c> vendorUpdatesList = new List<Vendor_Inserts__c>();
    Map<String, ID> vendorUpdatesIDMap = new Map<String, ID>();
    Map<ID,Vendor_Inserts__c> vendorUpdatesMap = new Map<ID,Vendor_Inserts__c>();
    Set<String> vendorUpdatesSet = new Set<String>();
    
	Set<Date> existingPublicationIssueDateSet = new Set<Date>();
	Set<String> existingVendorCodeSet = new Set<String>();
	// END 2015/03/10 D-2458 Michael Francisco 
	
    Set<String> inputPublicationCodeSet = new Set<String>();
    Set<String> existingPublicationCodeSet = new Set<String>();
    Set<String> validPublicationCodeSet = new Set<String>();
    Set<String> newPublicationCodeSet = new Set<String>();
    String strTemp = '';
    //[END D-1966 Renz Niefes 2015-01-29] Add/remove variables
    
    Map<String,BT_CO_CMIS_POP_NumberOfVendorInserts__c> publicationCode_SO_map = new Map<String,BT_CO_CMIS_POP_NumberOfVendorInserts__c>();
    Map<String, Id> publicationCode_publicationId_map = new Map<String, Id>();
    
    for(BT_CO_CMIS_POP_NumberOfVendorInserts__c so : recordsList)
    {
		// START 2015/03/10 D-2458 Michael Francisco - Modified NULL checks ...

		//[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        if (so.publicationCode__c !=null && so.publicationCode__c.length() > 0) {
			inputPublicationCodeSet.add(so.publicationCode__c);
        }
		//[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
		
		if (so.publicationIssueDate__c!=null && so.publicationIssueDate__c.length() > 0) {
			existingPublicationIssueDateSet.add(DateUtility.convertDate(so.publicationIssueDate__c, '\\.', 'DMY'));
		} 
		
		if (so.vendorNumber__c != null && so.vendorNumber__c.length() > 0) {
			existingVendorCodeSet.add(so.vendorNumber__c);
		}
		// END 2015/03/10 D-2458 Michael Francisco 
    }
        
    for(Publication__c publication : [SELECT Id, Publication_Code__c FROM Publication__c WHERE Publication_Code__c IN :inputPublicationCodeSet])
    {
        //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        if (publication.Publication_Code__c!=null) {
            existingPublicationCodeSet.add(publication.Publication_Code__c);
            publicationCode_publicationId_map.put(publication.Publication_Code__c,publication.Id);
        }
        //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
    }
    
    for(BT_CO_CMIS_POP_NumberOfVendorInserts__c so : recordsList)
    {        
        Boolean isValid = true;
        String validationDetails = '';        
        
        if(existingPublicationCodeSet.contains(so.publicationCode__c) == false)
        {
            validationDetails += 'Publication Code does not exist in Salesforce Publication records. ';
            isValid = false;
        }  
        
        if(so.publicationIssueDate__c == null || so.publicationIssueDate__c == '')
        {
            validationDetails += 'Publication Issue Date is a mandatory parameter. ';
            isValid = false;
        }        
        else if(DateUtility.isDateDD_MM_YYYY(so.publicationIssueDate__c,'\\.') == false)
        {
            validationDetails += 'Publication Issue Date format should be DD.MM.YYYY. ';
            isValid = false;
        } 
        //[START D-1966 Renz Niefes 2015-01-29] Adding Vendor number validation
        else if(so.vendorGroup__c == null || so.vendorGroup__c == '')
        {
            validationDetails += 'Vendor Group is a mandatory parameter. ';
            isValid = false;
        } 
        else if(so.vendorNumber__c == null || so.vendorNumber__c == '')
        {
            validationDetails += 'Vendor Number is a mandatory parameter. ';
            isValid = false;
        }       
        //[END D-1966 Renz Niefes 2015-01-29]
        
        try
        {
            Integer.valueOf(so.numberOfInserts__c);
        }
        catch(Exception e)
        {            
            validationDetails += 'Number of Inserts must be a whole number. ';
            isValid = false;
        }

        if(isValid)
        {             
            so.Validation_Status__c = 'Passed';
            //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
            if (so.publicationCode__c!=null) {
                validPublicationCodeSet.add(so.publicationCode__c);
                publicationCode_SO_map.put(so.publicationCode__c,so);
            }
            //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        }
        else
        {        
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = validationDetails;
            invalidRecordCount++; 
        }
    }
    
//[START D-1966 Renz Niefes 2015-01-29] Revised the whole section below.  Checking for records to update is by Publication Code, publication issue date and vendor number
    
	// START 2015/03/10 D-2458 Michael Francisco - List SELECT SOQL to address possible 100k limit ...
    //Get all Vendor Inserts list based on publication code set 
	vendorUpdatesList = [SELECT 
							ID, 
                            Publication_Code__c,
                            Publication_Issue_Date__c,
                            Vendor_Number__c,
                            Number_of_Inserts__c,
                            Publication__c,
                            Vendor_Group__c
                        FROM 
							Vendor_Inserts__c 
                        WHERE 
							Publication__r.Publication_Code__c IN :validPublicationCodeSet
							AND Publication_Issue_Date__c IN :existingPublicationIssueDateSet
							AND Vendor_Number__c IN :existingVendorCodeSet
						];
	
    //Loop through the list above and create the composite key.  Save that to Set and Map
    //The map is used to identify the ID of the vendor inserts while the set is used to check if its for update or for insert
    for(Vendor_Inserts__c vil : vendorUpdatesList) {
        //create a compound key and put to set
        vendorUpdatesSet.add(vil.Publication_Code__c + vil.Vendor_Number__c + vil.Publication_Issue_Date__c);   
        vendorUpdatesIDMap.put(vil.Publication_Code__c + vil.Vendor_Number__c + vil.Publication_Issue_Date__c, vil.ID);
        vendorUpdatesMap.put(vil.ID,vil);
    }
    
    for(BT_CO_CMIS_POP_NumberOfVendorInserts__c so : recordsList)
    {    
        if (so.Validation_Status__c.equalsIgnoreCase('Passed')) {
            strTemp = so.publicationCode__c + so.vendorNumber__c + DateUtility.convertDate(so.publicationIssueDate__c, '\\.', 'DMY');
        
            if (vendorUpdatesSet.contains(strTemp)) {  //For Get all for Update vendor lists, the rest should be insert
                //Get the ID of this map, then use the ID to get the Vendor insert record, then update accordingly.
                //Note that only the Vendor Group and Number of inserts will be updated.  The rest are readonly to avoid duplicates
                Vendor_Inserts__c vUpdateRecord = vendorUpdatesMap.get(vendorUpdatesIDMap.get(strTemp));
            
                if (vUpdateRecord.Vendor_Group__c!=so.vendorGroup__c||vUpdateRecord.Number_of_Inserts__c!=Integer.valueOf(so.numberOfInserts__c)) {
                    vUpdateRecord.Vendor_Group__c = so.vendorGroup__c;
                    vUpdateRecord.Number_of_Inserts__c = Integer.valueOf(so.numberOfInserts__c);                     
                    so.Name = 'FOR UPDATE';
                    vendorInsertsForUpdate.add(vUpdateRecord);
                } else {
                    so.Name = 'NO CHANGE DETECTED';
                }
            } else {
        
                //If no match is found, insert the record
                Vendor_Inserts__c vUpdateRecord = new Vendor_Inserts__c();
                vUpdateRecord.Publication__c = publicationCode_publicationId_map.get(so.publicationCode__c);
                vUpdateRecord.Publication_Code__c = so.publicationCode__c;
                vUpdateRecord.Publication_Issue_Date__c = DateUtility.convertDate(so.publicationIssueDate__c, '\\.', 'DMY');
                vUpdateRecord.Vendor_Group__c = so.vendorGroup__c;
                vUpdateRecord.Vendor_Number__c = so.vendorNumber__c;
                vUpdateRecord.Number_of_Inserts__c = Integer.valueOf(so.numberOfInserts__c);        
        
                so.Name = 'FOR INSERT';
                vendorInsertsForInsert.add(vUpdateRecord);       
            }
        }
    }
    // END 2015/03/10 D-2458 Michael Francisco 
      
	//[END D-1966 Renz Niefes 2015-01-29]  Revised the section above---------------------------------------------------------------------    
    
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        insert vendorInsertsForInsert;
        update vendorInsertsForUpdate;
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_CMI100DX_NumberOfVendorInserts Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }    
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'CMI100DX';
    leg2sfLog.Batch_Run_Date__c = recordsList[0].Batch_Run_Date__c;
    leg2sfLog.Total_Record_Count__c = recordsList.size();
    leg2sfLog.Valid_Record_Count__c = recordsList.size() - invalidRecordCount;
    leg2sfLog.Invalid_Record_Count__c = invalidRecordCount;
    leg2sfLog.DML_Status__c = dmlStatus;
    leg2sfLog.Error_Message__c = errorMessage;
    leg2sfLog.Stack_Trace__c = stackTrace;
    leg2sfLog.Batch_Job_Id__c = recordsList[0].Batch_Job_Id__c;
   
    insert leg2sfLog;
    
}