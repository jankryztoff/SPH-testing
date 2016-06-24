/**
 * Trigger Name: BT_AT_CMI079DX_ImportNextIssueDateInfo
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - CMI079DX Interface
 * Description: This trigger contains the business logic for CMI079DX interface.
 * History: 2014/08/21 Kevin Evasco Created Skeletal Apex Trigger
            2014/09/20 Kevin Evasco Updated to implement business logic
 * History: 2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings)	
 * hISTORY: 2015/02/17 Renino Niefes D-2268 
 */

trigger BT_AT_CMI079DX_ImportNextIssueDateInfo on BT_CO_CMIS_POP_ImportNextIssueDateInfo__c (before insert, before update) 
{
    
    List<BT_CO_CMIS_POP_ImportNextIssueDateInfo__c> recordsList = trigger.new;
        
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';    
    
    List<Publication__c> publicationsForUpdate = new List<Publication__c>();
    List<Publication__c> existingPublications = new List<Publication__c>();
    
    Set<String> inputPublicationCode = new Set<String>();
    Set<String> existingPublicationCode = new Set<String>();
    Set<String> validPublicationCode = new Set<String>();
    
    Map<String,BT_CO_CMIS_POP_ImportNextIssueDateInfo__c> publicationCode_SO_map = new Map<String,BT_CO_CMIS_POP_ImportNextIssueDateInfo__c>();
    
    for(BT_CO_CMIS_POP_ImportNextIssueDateInfo__c so : recordsList)
    {
		//[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
		if (so.publicationCode__c!=null) {
			inputPublicationCode.add(so.publicationCode__c);
			publicationCode_SO_map.put(so.publicationCode__c,so);
		}
		//[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
    }
    
    existingPublications = [SELECT Id, Publication_Code__c FROM Publication__c WHERE Publication_Code__c IN :inputPublicationCode];
    
    for(Publication__c publication : existingPublications)
    {    
		//[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        if(publication.Publication_Code__c!=null) existingPublicationCode.add(publication.Publication_Code__c);    
		//[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
    }
    
    for(BT_CO_CMIS_POP_ImportNextIssueDateInfo__c so : recordsList)
    {
        Boolean isValid = true;
        String validationDetails = '';
        
        if(existingPublicationCode.contains(so.publicationCode__c) == false)
        {
            validationDetails += 'Publication Code does not exist in Salesforce Publication records. ';
            isValid = false;
        }   
		//[START 2015-02-17 D-2268 Renz] Wrong if condition.  It should be || instead of &&]
        if(so.publicationNextStartDate__c==null || so.publicationNextStartDate__c == '' || DateUtility.isDateDD_MM_YYYY(so.publicationNextStartDate__c,'\\.') == false)
        {
            validationDetails += 'Publication Next Start Date is mandatory and must be DD.MM.YYYY format. ';
            isValid = false;
        } 
        //[END 2015-02-17 D-2268 Renz] Wrong if condition.  It should be || instead of &&]
		
        if(isValid)
        {     
			//[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
            if (so.publicationCode__c!=null) validPublicationCode.add(so.publicationCode__c);			
			so.Validation_Status__c = 'Passed';
			so.Name = 'FOR UPDATE';
			//[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        }
        else
        {        
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = validationDetails;
            invalidRecordCount++; 
        }
    }
    
    publicationsForUpdate = [SELECT Id, Publication_Code__c FROM Publication__c WHERE Publication_Code__c IN :validPublicationCode];
    
    for(Publication__c publication : publicationsForUpdate)
    {
        if (publicationCode_SO_map.containsKey(publication.Publication_Code__c)) {
            BT_CO_CMIS_POP_ImportNextIssueDateInfo__c so = publicationCode_SO_map.get(publication.Publication_Code__c);

			//[START 02/16/2015 Renino Niefes D-2268] Added debug logs for testing
			System.debug('RENZ20150218_1:' + DateUtility.isDateDD_MM_YYYY(so.publicationNextStartDate__c,'\\.'));			
            if(so.publicationNextStartDate__c!=null && so.publicationNextStartDate__c != '' && DateUtility.isDateDD_MM_YYYY(so.publicationNextStartDate__c,'\\.') == true) {        
                publication.Publication_Next_Start_Date__c = DateUtility.convertDate(so.publicationNextStartDate__c,'\\.','DMY');
                
                //D-2260 : start : nitin khanna : Start Subscription - Earliest Start Date not getting populated at the Publication level
		//updating the earliest start sate withthe value of the next start date field
		//both fields are duplicates and used in separate modules
		//earliest start date used by POP is not updated when the information comes in from CMIS-POP
		//through CMI077DX	Inbound	IMPORT PUBLICATION ISSUE INFORMATION
		publication.Earliest_Start_Date__c = DateUtility.convertDate(so.publicationNextStartDate__c,'\\.','DMY');
		//D-2260 : end : nitin khanna : Start Subscription - Earliest Start Date not getting populated at the Publication level
		
            }
			//[END 02/16/2015 Renino Niefes D-2268] Added debug logs for testing
        }
    }    
    
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        update publicationsForUpdate;
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_CMI079DX_ImportNextIssueDateInfo Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }    
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'CMI079DX';
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