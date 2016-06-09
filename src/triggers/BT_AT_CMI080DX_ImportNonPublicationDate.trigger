/**
 * Trigger Name: BT_AT_CMI080DX_ImportNonPublicationDate
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - CMI080DX Interface
 * Description: This trigger contains the business logic for CMI080DX interface.
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger
            09/20/2014 Kevin Evasco Updated to implement business logic
            01/29/2015 Renino Niefes D-1964 Change the business logic to do upsert instead of delete insert
 * History: 2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings)
 * History: 2015/04/28 Renino Niefes D-2834 Code Review Only.  Make sure no null values added into the SOQL statements.
 * History: 2015/09/10 Renino Niefes UD-2704 Do Delete-Insert instead of upsert.  Change the business logic below (Removed old comments)
 */

trigger BT_AT_CMI080DX_ImportNonPublicationDate on BT_CO_CMIS_POP_ImportNonPublicationDate__c (before insert, before update) 
{            
    List<BT_CO_CMIS_POP_ImportNonPublicationDate__c> recordsList = trigger.new;
    
	//START UD-2704 2015-09-10 Renino Niefes Delete the records first (note 10k limit is to prevent exceptions.  expected record is only 3500+)
	String batchJobId = '';
	for (BT_CO_CMIS_POP_ImportNonPublicationDate__c so : recordsList)
    {        
		batchJobId = so.Batch_Job_Id__c;
		if (batchJobId!='') {
			break;
		}
	}
	
    List<Non_Publication_Day__c> nonPublicationDaysForDelete = [SELECT Id FROM Non_Publication_Day__c WHERE Name != :batchJobId LIMIT 10000]; 
    delete nonPublicationDaysForDelete;
	
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';    
    
    List<Non_Publication_Day__c> nonPublicationDaysForInsert = new List<Non_Publication_Day__c>();    
	List<Publication__c> existingNonPublicationsList = new List<Publication__c>();
	Map<String, Id> publicationCode_publicationId_map = new Map<String, Id>();
    Set<String> inputPublicationCodeSet = new Set<String>();
    Set<String> existingPublicationCodeSet = new Set<String>();    

    String strTemp = '';
    String strBatchID = '';
    
    for(BT_CO_CMIS_POP_ImportNonPublicationDate__c so : recordsList)
    {
        inputPublicationCodeSet.add(so.publicationCode__c);
    }    
    
    existingNonPublicationsList = [SELECT Id, Publication_Code__c FROM Publication__c WHERE Publication_Code__c IN :inputPublicationCodeSet];
    
    for(Publication__c publication : existingNonPublicationsList)
    {
        if (publication.Publication_Code__c!=null) {
            existingPublicationCodeSet.add(publication.Publication_Code__c);
            publicationCode_publicationId_map.put(publication.Publication_Code__c,publication.Id);
        }
    }
    
    for(BT_CO_CMIS_POP_ImportNonPublicationDate__c so : recordsList)
    {
        Boolean isValid = true;
        String validationDetails = '';
        
        if(existingPublicationCodeSet.contains(so.publicationCode__c) == false)
        {
            validationDetails += 'Publication Code does not exist in Salesforce Publication records. ';
            isValid = false;
        }  
        
        if(so.nonPublicationDate__c == null || so.nonPublicationDate__c == '')
        {
            validationDetails += 'Non Publication Date is a mandatory parameter. ';
            isValid = false;
        }        
        else if(DateUtility.isDateDD_MM_YYYY(so.nonPublicationDate__c,'\\.') == false)
        {
            validationDetails += 'Non Publication Date is not in valid format. Non Publication Date should be DD.MM.YYYY. ';
            isValid = false;
        }        
        
        if(isValid)
        {             
            so.Validation_Status__c = 'Passed';
            
            Non_Publication_Day__c newNonPublicationDay = new Non_Publication_Day__c();
            newNonPublicationDay.Non_Publication_Date__c =  DateUtility.convertDate(so.nonPublicationDate__c,'\\.','DMY');
            newNonPublicationDay.Publication__c = publicationCode_publicationId_map.get(so.publicationCode__c);
            newNonPublicationDay.Publication_Code__c = so.publicationCode__c;
			newNonPublicationDay.Name = batchJobId;
            nonPublicationDaysForInsert.add(newNonPublicationDay);            
        }
        else
        {   
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = validationDetails;
            invalidRecordCount++; 
        }    
    }    
	//END UD-2704 2015-09-10 Renino Niefes

   
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        insert nonPublicationDaysForInsert;
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_CMI080DX_ImportNonPublicationDate Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }    
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'CMI080DX';
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