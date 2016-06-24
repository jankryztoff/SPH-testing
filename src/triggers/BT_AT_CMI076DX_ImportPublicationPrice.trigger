/**
 * Trigger Name: BT_AT_CMI076DX_ImportPublicationPrice
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - CMI076DX Interface
 * Description: This trigger contains the business logic for CMI076DX interface.
 * History: 2014/08/21 Kevin Evasco Created Skeletal Apex Trigger
 * History: 2015/02/12 Renino Niefes Changed the logic for update and insert records
 * History: 2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings)
 */

trigger BT_AT_CMI076DX_ImportPublicationPrice on BT_CO_CMIS_POP_ImportPublicationPrice__c (before insert, before update) 
{
    
    List<BT_CO_CMIS_POP_ImportPublicationPrice__c> recordsList = trigger.new;
            
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';    
    
    List<Publication_Price__c> publicationPricesForUpdate = new List<Publication_Price__c>();
	//[START 2015-02-12 D-2024 Renz] Add new variables
	List<Publication_Price__c> publicationPricesForInsert = new List<Publication_Price__c>();
    List<Publication__c> existingPublications = new List<Publication__c>();
    
    Set<String> inputPublicationCodeSet = new Set<String>();
    Set<String> existingPublicationCodeSet = new Set<String>();
    Set<String> validPublicationCodeSet = new Set<String>();
	Set<String> exitPubPriceIDSet = new Set<String>();	
    
    Map<String,BT_CO_CMIS_POP_ImportPublicationPrice__c> publicationCode_SO_map = new Map<String,BT_CO_CMIS_POP_ImportPublicationPrice__c>();
	Map<String,Publication__c> publicationMap = new Map<String,Publication__c>();
	//[END 2015-02-12 D-2024 Renz] Add new variables
    
	//[START 2015-02-12 D-2024 Renz] Change the logic in getting records for update and for insert
	String strPubPriceID = '';
    for(BT_CO_CMIS_POP_ImportPublicationPrice__c so : recordsList)
    {
        inputPublicationCodeSet.add(so.publicationCode__c);
		if (so.salesType__c==null) so.salesType__c = '';
		if (so.dayOfWeek__c==null) so.dayOfWeek__c = '';
		//[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
		if (so.publicationCode__c!=null||so.effectiveDate__c!=null) {
			strPubPriceID = so.publicationCode__c + DateUtility.convertDate(so.effectiveDate__c,'\\.','DMY') + so.salesType__c + so.dayOfWeek__c ;
			publicationCode_SO_map.put(strPubPriceID,so);
		}
		//[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
    }
    //START SPH Code Review - 18-Feb-2015 Added by Raviteja - included remove(null) in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit
	inputPublicationCodeSet.remove(Null);
	//End SPH Code Review - 18-Feb-2015 Added by Raviteja 
    existingPublications = [SELECT Id, Publication_Code__c FROM Publication__c WHERE Publication_Code__c IN :inputPublicationCodeSet];
    	
    for(Publication__c publication : existingPublications)
    {   
		//[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]	
		if (publication.Publication_Code__c!=null) {
			existingPublicationCodeSet.add(publication.Publication_Code__c);
			publicationMap.put(publication.Publication_Code__c,publication);
		}
		//[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
		
    }
    
    // Validation
    for(BT_CO_CMIS_POP_ImportPublicationPrice__c so : recordsList)
    {
        Boolean isValid = true;
        String validationDetails = '';
		       
		if(so.publicationCode__c == null && so.publicationCode__c == '')
        {
            validationDetails += 'Publication Code is a mandatory parameter. ';
            isValid = false;
        } 
		
        if(existingPublicationCodeSet.contains(so.publicationCode__c) == false)
        {            
            validationDetails += 'Publication Code does not exist in Salesforce Publication records. ';
            isValid = false;
        }
        
        if(so.salesType__c != 'N' && so.salesType__c != 'S' && so.salesType__c != 'P' && so.salesType__c != '' && so.salesType__c != null)
        {            
            validationDetails += 'Invalid Sales Type. Accepted Sales Type values are N,S,P,<blank>. ';
            isValid = false;
        }
        
        if(so.dayOfWeek__c != '1' && so.dayOfWeek__c != '2' && so.dayOfWeek__c != '3' && so.dayOfWeek__c != '4' && so.dayOfWeek__c != '5' && so.dayOfWeek__c != '6' && so.dayOfWeek__c != '7' && so.dayOfWeek__c != '' && so.dayOfWeek__c != null)
        {            
            validationDetails += 'Invalid Day of Week. Accepted Day of Week values are 1,2,3,4,5,6,7,<blank>. ';
            isValid = false;
        }
		
		if(so.coverPrice__c == null && so.coverPrice__c == '')
        {
            validationDetails += 'Cover Price is a mandatory parameter. ';
            isValid = false;
        } 		
        
		if(so.effectiveDate__c == null && so.effectiveDate__c == '')
        {
            validationDetails += 'Effective Date is a mandatory parameter. ';
            isValid = false;
        }        
        else if(DateUtility.isDateDD_MM_YYYY(so.effectiveDate__c,'\\.') == false)
        {
            validationDetails += 'Effective Date is not in valid format. Non Publication Date should be DD.MM.YYYY. ';
            isValid = false;
        } 
		
        if(isValid)
        {             
			so.Name = 'FOR INSERT';
            so.Validation_Status__c = 'Passed';
			//[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]	
            if (so.publicationCode__c!=null) validPublicationCodeSet.add(so.publicationCode__c);
			//[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]	
        }
        else
        {   
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = validationDetails;
            invalidRecordCount++; 
        }
    }
    
	
    publicationPricesForUpdate = [SELECT Id, Publication__r.Publication_Code__c, Publication_Code__c,Cover_Price__c,Effective_Date__c,Sales_Type__c,Day_of_Week__c  FROM Publication_Price__c WHERE Publication__r.Publication_Code__c IN :validPublicationCodeSet];
    
	
    for(Publication_Price__c publicationPrice : publicationPricesForUpdate)
    {   
		if (publicationPrice.Sales_Type__c==null) publicationPrice.Sales_Type__c = '';
		if (publicationPrice.Day_of_Week__c==null) publicationPrice.Day_of_Week__c = '';
		strPubPriceID = publicationPrice.Publication__r.Publication_Code__c 			
			+ publicationPrice.Effective_Date__c 
			+ publicationPrice.Sales_Type__c 
			+ publicationPrice.Day_of_Week__c ;
        if (publicationCode_SO_map.containsKey(strPubPriceID)) {
			BT_CO_CMIS_POP_ImportPublicationPrice__c so = publicationCode_SO_map.get(strPubPriceID);
			try {

        
				publicationPrice.Cover_Price__c = Decimal.valueOf(so.coverPrice__c)/100;
				publicationPrice.Effective_Date__c = DateUtility.convertDate(so.effectiveDate__c,'\\.','DMY');
				publicationPrice.Sales_Type__c = so.salesType__c;
				publicationPrice.Day_of_Week__c = so.dayOfWeek__c;
			
				so.Name = 'FOR UPDATE';
				exitPubPriceIDSet.add(strPubPriceID);
			} catch (Exception e) {
				so.Name = 'FOR INSERT EXCEPTION';
				so.Validation_Status__c = 'Failed';
				so.Validation_Details__c = 'An error occured while assigning the value into Publication Price object.';
			}
        } 	
    }
	
	for(BT_CO_CMIS_POP_ImportPublicationPrice__c so : recordsList)  {
		if (so.Validation_Status__c.equalsIgnoreCase('Passed')&&so.Name.equalsIgnoreCase('FOR INSERT')) {
			if (so.salesType__c==null) so.salesType__c = '';
			if (so.dayOfWeek__c==null) so.dayOfWeek__c = '';			
			strPubPriceID = so.publicationCode__c +  DateUtility.convertDate(so.effectiveDate__c,'\\.','DMY') + so.salesType__c + so.dayOfWeek__c ;
			if (exitPubPriceIDSet.contains(strPubPriceID)) {
				so.Name = 'DUPLICATE';
				so.Validation_Status__c = 'Failed';
				so.Validation_Details__c = 'Duplicate record';
			} else {
				try {
					Publication_Price__c newPubPrice = new Publication_Price__c();
					Publication__c pubRecord = publicationMap.get(so.publicationCode__c);
					newPubPrice.Publication_Code__c	=so.publicationCode__c; 
					newPubPrice.Publication__c = pubRecord.Id;
					newPubPrice.Cover_Price__c = Decimal.valueOf(so.coverPrice__c)/100;
					newPubPrice.Effective_Date__c =  DateUtility.convertDate(so.effectiveDate__c,'\\.','DMY');
					newPubPrice.Sales_Type__c = so.salesType__c;
					newPubPrice.Day_of_Week__c = so.dayOfWeek__c;
					so.Name = 'FOR INSERT';
				
					publicationPricesForInsert.add(newPubPrice);
					exitPubPriceIDSet.add(strPubPriceID);
				} catch (Exception e) {
					so.Name = 'FOR UPDATE EXCEPTION';
					so.Validation_Status__c = 'Failed';
					so.Validation_Details__c = 'An error occured while assigning the value into Publication Price object.';
				}	
			}
		}
	}
	
    //[END 2015-02-12 D-2024 Renz] Change the logic in getting records for update and for insert
        
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        update publicationPricesForUpdate;
		//[START 2015-02-12 D-2024 Renz] Added insert operation for new records
		insert publicationPricesForInsert;
		//[END 2015-02-12 D-2024 Renz] 
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_CMI076DX_ImportPublicationPrice Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }    
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'CMI076DX';
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