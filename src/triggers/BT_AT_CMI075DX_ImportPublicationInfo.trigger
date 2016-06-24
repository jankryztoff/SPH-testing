/**
 * Trigger Name: BT_AT_CMI075DX_ImportPublicationInfo
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - CMI075DX Interface
 * Description: This trigger contains the business logic for CMI075DX interface.
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger
 *          09/20/2014 Kevin Evasco Updated to implement business logic
 *          2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings)			
 *          2015/06/23 Renz Niefes - synced back this code to Github as part of D-2989 defect.  currently modified by Nitin Khanna last week.            
 */

trigger BT_AT_CMI075DX_ImportPublicationInfo on BT_CO_CMIS_POP_ImportPublicationInfo__c (before insert, before update) 
{
    
    List<BT_CO_CMIS_POP_ImportPublicationInfo__c> recordsList = trigger.new;
    
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';
    
    List<Publication__c> publicationsForUpdate = new List<Publication__c>();
    List<Publication__c> publicationsForInsert = new List<Publication__c>();
    
    Set<String> inputPublicationCodeSet = new Set<String>();
    Set<String> validPublicationCodeSet = new Set<String>();
    Set<String> newPublicationCodeSet = new Set<String>();
    
    Map<String,BT_CO_CMIS_POP_ImportPublicationInfo__c> publicationCode_SO_map = new Map<String,BT_CO_CMIS_POP_ImportPublicationInfo__c>();
    
    for(BT_CO_CMIS_POP_ImportPublicationInfo__c so : recordsList)
    {
		//[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        if (so.publicationCode__c!=null) inputPublicationCodeSet.add(so.publicationCode__c);
		//[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
    }
    
    for(BT_CO_CMIS_POP_ImportPublicationInfo__c so : recordsList)
    {
        Boolean isValid = true;
        String validationDetails = '';
        
        if(so.publicationType__c != 'N' && so.publicationType__c != 'M')
        {
            validationDetails += 'Publication Type must be N or M. ';
            isValid = false;
        }
        
        if(so.frequencyCode__c != 'D' && so.frequencyCode__c != 'W' && so.frequencyCode__c != 'F' && so.frequencyCode__c != 'M' && so.frequencyCode__c != 'B' && so.frequencyCode__c != 'Q' && so.frequencyCode__c != 'H' && so.frequencyCode__c != 'Y' && so.frequencyCode__c != 'O')
        {
            validationDetails += 'Frequency Code must be D, W , F, M, B, Q, H, Y, or O. ';
            isValid = false;
        }
        
        //TO-DO insert validation here for Published Days
        
        if(so.publicHolidayWeekdayIndicator__c != 'Y' && so.publicHolidayWeekdayIndicator__c != 'N')
        {
            validationDetails += 'Public Holiday Weekday Indicator must be Y/N. ';
            isValid = false;
        }
        
        if(so.publicHolidayWeekendIndicator__c != 'Y' && so.publicHolidayWeekendIndicator__c != 'N')
        {
            validationDetails += 'Public Holiday Weekend Indicator must be Y/N. ';
            isValid = false;
        }
        
        if(DateUtility.isDateDD_MM_YYYY(so.effectiveDate__c,'\\.') == false)
        {
            validationDetails += 'Start Date format must be DD.MM.YYYY. ';
            isValid = false;
        }
        
        if(so.expiryDate__c != null && so.expiryDate__c != '' && DateUtility.isDateDD_MM_YYYY(so.expiryDate__c,'\\.') == false )
        {
            validationDetails += 'Start Date format must be DD.MM.YYYY. ';
            isValid = false;
        }
        
        if(so.sphPublicationIndicator__c != 'Y' && so.sphPublicationIndicator__c != 'N')
        {
            validationDetails += 'SPH Publication Indicator must be Y/N. ';
            isValid = false;
        }        
        
        if(so.onlinePublicationIndicator__c != 'Y' && so.onlinePublicationIndicator__c != 'N')
        {
            validationDetails += 'Online Publication Indicator must be Y/N. ';
            isValid = false;
        }
        
        if(so.freePublicationIndicator__c != 'Y' && so.freePublicationIndicator__c != 'N')
        {
            validationDetails += 'Free Publication Indicator must be Y/N. ';
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
    
    newPublicationCodeSet.addAll(validPublicationCodeSet);
    
    publicationsForUpdate = [SELECT Id, Publication_Code__c FROM Publication__c WHERE Publication_Code__c IN :validPublicationCodeSet];
    
    for(Publication__c publication : publicationsForUpdate)
    {
        newPublicationCodeSet.remove(publication.Publication_Code__c);
        
        
        if (publicationCode_SO_map.containsKey(publication.Publication_Code__c)) {
        BT_CO_CMIS_POP_ImportPublicationInfo__c so = publicationCode_SO_map.get(publication.Publication_Code__c);
        
        
        publication.Name = so.publicationName__c;       
        publication.Publication_Type__c = so.publicationType__c;
        publication.Frequency_Code__c = so.frequencyCode__c;
        publication.Published_Days__c = so.publishedDays__c;
        publication.Language_Medium__c = so.languageCode__c; //Start-End(D-2989)
        
        if(so.publicHolidayWeekdayIndicator__c == 'Y')
        {
            publication.Public_Holiday_Weekday_Pub_Indicator__c = true;
        }
        else
        {
            publication.Public_Holiday_Weekday_Pub_Indicator__c = false;
        }       
        
        if(so.publicHolidayWeekendIndicator__c == 'Y')
        {
            publication.Public_Holiday_Weekend_Pub_Indicator__c = true;
        }
        else
        {
            publication.Public_Holiday_Weekend_Pub_Indicator__c = false;
        }
        
        publication.Active_Date__c = DateUtility.convertDate(so.effectiveDate__c, '\\.', 'DMY');
        if(so.expiryDate__c != null && so.expiryDate__c != '' && DateUtility.isDateDD_MM_YYYY(so.expiryDate__c,'\\.') == false )
        {       
            publication.Expiry_Date__c = DateUtility.convertDate(so.expiryDate__c, '\\.', 'DMY');
        }
        
        if(so.sphPublicationIndicator__c == 'Y')
        {
            publication.Sph_Publication_Indicator__c = true;
        }
        else
        {
            publication.Sph_Publication_Indicator__c = false;
        }
        
        publication.Publisher_Code__c = so.publisherCode__c;
        
        if(so.onlinePublicationIndicator__c == 'Y')
        {
            publication.Online_Publication__c = true;
        }
        else
        {
            publication.Online_Publication__c = false;
        }
        
        if(so.freePublicationIndicator__c == 'Y')
        {
            publication.Free_Publication__c = true;
        }
        else
        {
            publication.Free_Publication__c = false;
        }
        }
    }
    
    for(String newPublicationCode : newPublicationCodeSet)
    {
        BT_CO_CMIS_POP_ImportPublicationInfo__c so = publicationCode_SO_map.get(newPublicationCode);
        
        Publication__c publication = new Publication__c();
        publication.Publication_Code__c = so.publicationCode__c;
        publication.Name = so.publicationName__c;
        publication.Publication_Type__c = so.publicationType__c; //Start-End(D-2989)
        publication.Frequency_Code__c = so.frequencyCode__c;
        publication.Published_Days__c = so.publishedDays__c;
        publication.Language_Medium__c = so.languageCode__c;
        
        if(so.publicHolidayWeekdayIndicator__c == 'Y')
        {
            publication.Public_Holiday_Weekday_Pub_Indicator__c = true;
        }
        else
        {
            publication.Public_Holiday_Weekday_Pub_Indicator__c = false;
        }       
        
        if(so.publicHolidayWeekendIndicator__c == 'Y')
        {
            publication.Public_Holiday_Weekend_Pub_Indicator__c = true;
        }
        else
        {
            publication.Public_Holiday_Weekend_Pub_Indicator__c = false;
        }
        
        publication.Active_Date__c = DateUtility.convertDate(so.effectiveDate__c, '\\.', 'DMY');
        if(so.expiryDate__c != null && so.expiryDate__c != '' && DateUtility.isDateDD_MM_YYYY(so.expiryDate__c,'\\.') == false ) {
            publication.Expiry_Date__c = DateUtility.convertDate(so.expiryDate__c, '\\.', 'DMY');
        }
        
        if(so.sphPublicationIndicator__c == 'Y')
        {
            publication.Sph_Publication_Indicator__c = true;
        }
        else
        {
            publication.Sph_Publication_Indicator__c = false;
        }
        
        publication.Publisher_Code__c = so.publisherCode__c;
        
        if(so.onlinePublicationIndicator__c == 'Y')
        {
            publication.Online_Publication__c = true;
        }
        else
        {
            publication.Online_Publication__c = false;
        }
        
        if(so.freePublicationIndicator__c == 'Y')
        {
            publication.Free_Publication__c = true;
        }
        else
        {
            publication.Free_Publication__c = false;
        }
        
        publicationsForInsert.add(publication);
    }
    
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        update publicationsForUpdate;
        insert publicationsForInsert;
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_CMI075DX_ImportPublicationInfo Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }        
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'CMI075DX';
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