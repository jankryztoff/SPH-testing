/**
 * Trigger Name: BT_AT_CMI078DX_ImportPublicHolidayInfo
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - CMI078DX Interface
 * Description: This trigger contains the business logic for CMI078DX interface.
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger
            09/19/2014 Kevin Evasco Updated to implement business logic
			09/10/2015 Renino Niefes UD-2701 Do Delete-Insert instead of upsert.  Change the business logic below
 */

trigger BT_AT_CMI078DX_ImportPublicHolidayInfo on BT_CO_CMIS_POP_ImportPublicHolidayInfo__c (before insert, before update) 
{	
    List<BT_CO_CMIS_POP_ImportPublicHolidayInfo__c> recordsList = trigger.new;
 
	//START UD-2701 2015-09-10 Renino Niefes Delete the records first (note 10k limit is to prevent exceptions.  expected record is only 300+)
	String batchJobId = '';
	for (BT_CO_CMIS_POP_ImportPublicHolidayInfo__c so : recordsList)
    {        
		batchJobId = so.Batch_Job_Id__c;
		if (batchJobId!='') {
			break;
		}
	}
	
    List<Public_Holiday__c> holidayList = [SELECT Id FROM Public_Holiday__c WHERE Name != :batchJobId LIMIT 10000]; 
    delete holidayList;
	//END UD-2701 2015-09-10 Renino Niefes
 
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';    
    
    //List<Public_Holiday__c> publicHolidayForUpdate = new List<Public_Holiday__c>();  //START/END UD-2701 2015-09-10 Renino Niefes Remove this
    List<Public_Holiday__c> publicHolidayForInsert = new List<Public_Holiday__c>();
    
    Set<Date> inputHolidayDateSet = new Set<Date>();
    Set<Date> newHolidayDateSet = new Set<Date>();
    
    Map<Date, BT_CO_CMIS_POP_ImportPublicHolidayInfo__c> holidayDate_SO_map = new Map<Date, BT_CO_CMIS_POP_ImportPublicHolidayInfo__c>();
    
    for(BT_CO_CMIS_POP_ImportPublicHolidayInfo__c so : recordsList)
    {        
        Boolean isValid = true;
        String validationDetails = '';
        
        if(so.holidayDate__c == null || so.holidayDate__c == '')
        {
            validationDetails += 'Holiday Date is a mandatory parameter.';
            isValid = false;
        }        
        else if(DateUtility.isDateDD_MM_YYYY(so.holidayDate__c,'\\.') == false)
        {
            validationDetails += 'Holiday Date is not in valid format. Holiday Date should be DD.MM.YYYY. ';
            isValid = false;
        }
        
        if(isValid)
        {             
            so.Validation_Status__c = 'Passed';
            Date convertedHolidayDate = DateUtility.convertDate(so.holidayDate__c,'\\.','DMY');
            inputHolidayDateSet.add(convertedHolidayDate);
            holidayDate_SO_map.put(convertedHolidayDate, so);
        }
        else
        {   
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = validationDetails;
            invalidRecordCount++; 
        }        
    }
    
    newHolidayDateSet.addAll(inputHolidayDateSet);
    
	//START UD-2701 2015-09-10 Renino Niefes Remove this
    //publicHolidayForUpdate = [SELECT Id, Holiday_Date__c, Holiday_Description__c FROM Public_Holiday__c WHERE Holiday_Date__c IN: inputHolidayDateSet];
    //
    //for(Public_Holiday__c nonPublicationDay : publicHolidayForUpdate)
    //{
    //    newHolidayDateSet.remove(nonPublicationDay.Holiday_Date__c);
    //    BT_CO_CMIS_POP_ImportPublicHolidayInfo__c so = holidayDate_SO_map.get(nonPublicationDay.Holiday_Date__c);
    //    nonPublicationDay.Holiday_Description__c = so.holidayDescription__c;
    //}
	//END UD-2701 2015-09-10 Renino Niefes Remove this
	
    
    for(Date newHolidayDate : newHolidayDateSet)
    {
        BT_CO_CMIS_POP_ImportPublicHolidayInfo__c so = holidayDate_SO_map.get(newHolidayDate);
        
        Public_Holiday__c newPublicHolidayDay = new Public_Holiday__c();
        newPublicHolidayDay.Holiday_Date__c =  newHolidayDate; 
        newPublicHolidayDay.Holiday_Description__c = so.holidayDescription__c;
		newPublicHolidayDay.Name = batchJobId;
        publicHolidayForInsert.add(newPublicHolidayDay);
    }
        
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        //update publicHolidayForUpdate; //START/END UD-2701 2015-09-10 Renino Niefes Remove this
        insert publicHolidayForInsert;
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_CMI078DX_ImportPublicHolidayInfo Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }    
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'CMI078DX';
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