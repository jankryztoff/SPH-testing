/**
 * Trigger Name: BT_AT_CMI077DX_ImportPublicationIssue
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - CMI077DX Interface
 * Description: This trigger contains the business logic for CMI077DX interface.
 * History: 
            2014/08/21 Kevin Evasco         Created Skeletal Apex Trigger
            2014/09/22 Kevin Evasco         Updated to implement business logic
            2015/01/06 Michael Francisco    Updated to address D-1493 
            2015/01/10 Michael Francisco    Updated to address D-1493 - Retest Failed Issues 
 * History: 2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings)
 * History: 2015/04/24 Renino Niefes UD-0999 CHeck only for mandatory validation for Order Closed Date if Order Closed Date Indicator is set to Yes.  Otherwise, it's optional
 * History: 2015/05/05 Renino Niefes D-XXXX Fix the Line 186 null pointer exception
 */

trigger BT_AT_CMI077DX_ImportPublicationIssue on BT_CO_CMIS_POP_ImportPublicationIssue__c (before insert, before update) 
{
    
    List<BT_CO_CMIS_POP_ImportPublicationIssue__c> recordsList = trigger.new;
            
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';    
    
    List<Publication_Daily_Issue_Data__c> publicationDailyIssueDataForUpdate = new List<Publication_Daily_Issue_Data__c>();
    List<Publication_Daily_Issue_Data__c> publicationDailyIssueDataForInsert = new List<Publication_Daily_Issue_Data__c>();
     
    Set<String> inputPublicationCodeSet = new Set<String>();
    Set<String> existingPublicationCodeSet = new Set<String>();
    
    //START D-1493 - Michael Francisco - 01.10.2015 - Added Set / Map variables to store the issue date data along with the publication code ...
    // Variable Declarations ...
    Set<String> inputPublicationCodeDateSet = new Set<String>();
    Set<String> validPublicationCodeDateSet = new Set<String>();
    Set<String> insertPublicationCodeDateSet = new Set<String>();

    Map<String, BT_CO_CMIS_POP_ImportPublicationIssue__c> publicationData_map = new Map<String,BT_CO_CMIS_POP_ImportPublicationIssue__c>();
    Map<String, Id> publicationCode_publicationId_map = new Map<String, Id>();
    //END D-1493 - Michael Francisco - 01.10.2015
    
    for(BT_CO_CMIS_POP_ImportPublicationIssue__c so : recordsList)
    {   //START 02/18/2015 JTeves - Code Optimization - Removal of NULL value in Query Filter Sets
        if(so.publicationCode__c != null) {
            inputPublicationCodeSet.add(so.publicationCode__c);
        }
        //END 02/18/2015 JTeves - Code Optimization
        
        
        //START D-1493 - Michael Francisco - 01.10.2015 
        //D-1493 - Michael Francisco - 01.10.2015 - Store the Publication Code and the Issue Date value in a SET ...
        //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        if (so.publicationIssueDate__c!=null||so.publicationCode__c!=null) {
            List<String> ltTmpDate = String.valueOf(DateUtility.convertDate(so.publicationIssueDate__c, '\\.', 'DMY')).split(' ');
            String code_date = (so.publicationCode__c+''+ltTmpDate.get(0)).trim();

            inputPublicationCodeDateSet.add(code_date);
            publicationData_map.put(code_date,so);
        }
        //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        //END D-1493 - Michael Francisco - 01.10.2015
    }
    
    //START D-1493 - Michael Francisco - 01.10.2015 - Check if the Publication code exists in the Publication__c Salesforce Object ...
    for(Publication__c publication : [SELECT Id, Publication_Code__c FROM Publication__c WHERE Publication_Code__c IN :inputPublicationCodeSet])
    {
        //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        if (publication.Publication_Code__c!=null) {
            //D-1493 - Michael Francisco - 01.10.2015 - Save SO Publication Code ...
            existingPublicationCodeSet.add(publication.Publication_Code__c);
        
            //D-1493 - Michael Francisco - 01.10.2015 - Save SO Map of Publication Code - Id ...
            publicationCode_publicationId_map.put(publication.Publication_Code__c,publication.Id);
        }
        //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
    }
    //END D-1493 - Michael Francisco - 01.10.2015

    //START D-1493 - Michael Francisco - 01.10.2015 - Validate data in the file...
    for(BT_CO_CMIS_POP_ImportPublicationIssue__c so : recordsList)
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
        
        if(so.consolidationDate__c == null || so.consolidationDate__c == '')
        {
            validationDetails += 'Consolidation Date is a mandatory parameter. ';
            isValid = false;
        }        
        else if(DateUtility.isDateDD_MM_YYYY(so.consolidationDate__c,'\\.') == false)
        {
            validationDetails += 'Consolidation Date format should be DD.MM.YYYY. ';
            isValid = false;
        }
        
        if(so.orderClosedIndicator__c != 'Y' && so.orderClosedIndicator__c != 'N')
        {
            validationDetails += 'Order Closed Indicator must be Y/N. ';
            isValid = false;
        }
        
        if(so.orderCloseDate__c == null || so.orderCloseDate__c == '')
        {
            //START 2015/04/24 Renino Niefes UD-0999 CHeck only for mandatory validation for Order Closed Date if Order Closed Date Indicator is set to Yes.  Otherwise, it's optional
            if (so.orderClosedIndicator__c!=null&&so.orderClosedIndicator__c=='Y') {
                validationDetails += 'Order Closed Date is a mandatory parameter since the order closed indicator is set to yes. ';
                isValid = false;
            }
            //END 2015/04/24 Renino Niefes UD-0999
        }        
        else if(DateUtility.isDateDD_MM_YYYY(so.orderCloseDate__c,'\\.') == false)
        {
            validationDetails += 'Order Closed Date format should be DD.MM.YYYY. ';
            isValid = false;
        }
        
        try
        {
            Integer.valueOf(so.pagination__c);
        }
        catch(Exception e)
        {            
            validationDetails += 'Pagination must be a whole number. ';
            isValid = false;
        }
        
        if(isValid)
        {             
            so.Validation_Status__c = 'Passed';
                   
            //START D-1493 - Michael Francisco - 01.10.2015 - Added logic to split issue date field to only get DATE and not TIME components ...            
            //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
            if (so.publicationIssueDate__c!=null||so.publicationCode__c!=null) {
                List<String> ltTmpDate = String.valueOf(DateUtility.convertDate(so.publicationIssueDate__c, '\\.', 'DMY')).split(' ');
                String tmpID = (so.publicationCode__c+''+ltTmpDate.get(0)).trim();          
                validPublicationCodeDateSet.add(tmpID);
                insertPublicationCodeDateSet.add(tmpID);
            }
            //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
             //END D-1493 - Michael Francisco - 01.10.2015
        }
        else
        {        
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = validationDetails;
            invalidRecordCount++; 
        }
    }
    //END D-1493 - Michael Francisco - 01.10.2015
    
    //START D-1493 - Michael Francisco - 01.10.2015 - Process Data for UPDATE ...
    for(Publication_Daily_Issue_Data__c publicationIssueData : [SELECT Id, Publication__r.Publication_Code__c,  Publication_Issue_Date__c FROM Publication_Daily_Issue_Data__c WHERE Publication__r.Publication_Code__c IN :inputPublicationCodeSet])
    {
        List<String> ltTmpDate = String.valueOf(publicationIssueData.Publication_Issue_Date__c).split(' ');     
        String tmpID = String.valueOf(publicationIssueData.Publication__r.Publication_Code__c+''+ltTmpDate.get(0)).trim();
                
        if (insertPublicationCodeDateSet.contains(tmpID) && validPublicationCodeDateSet.contains(tmpID)) {   
            
            //D-1493 - Michael Francisco - 01.10.2015 - Remove entry if it exists in SOQL ...
            insertPublicationCodeDateSet.remove(tmpID);
            
            BT_CO_CMIS_POP_ImportPublicationIssue__c so = publicationData_map.get(tmpID);     
            if (so != null && publicationIssueData != null) {
                publicationIssueData.Publication_Issue_Date__c = DateUtility.convertDate(so.publicationIssueDate__c, '\\.', 'DMY');
                publicationIssueData.Publication_Issue_Number__c = so.publicationIssueNumber__c;
                publicationIssueData.Pagination__c = Integer.valueOf(so.pagination__c);
                publicationIssueData.Consolidation_Date__c = DateUtility.convertDate(so.consolidationDate__c, '\\.', 'DMY');
                publicationIssueData.Order_Closed_Indicator__c = so.orderClosedIndicator__c;
                
                //START 2015/05/05 Renz D-XXXX Check if orderClosedDate is null before converting
                if (so.orderCloseDate__c!=null) {
                    publicationIssueData.Order_Closed_Date__c = DateUtility.convertDate(so.orderCloseDate__c, '\\.', 'DMY');
                }
                //END 2015/05/05 Renz D-XXXX Check if orderClosedDate is null before converting
                
                if (publicationIssueData != null) {
                    publicationDailyIssueDataForUpdate.add(publicationIssueData);   
                }
            }
        } 
    }
    //END D-1493 - Michael Francisco - 01.10.2015
    
    //START D-1493 - Michael Francisco - 01.10.2015 - Process Data for INSERT ...
    for(String newID : insertPublicationCodeDateSet)
    {
        if (validPublicationCodeDateSet.contains(newID)) {   
            BT_CO_CMIS_POP_ImportPublicationIssue__c so = publicationData_map.get(newID);  
            if (so != null) {
                Publication_Daily_Issue_Data__c publicationIssueData = new Publication_Daily_Issue_Data__c();
                
                publicationIssueData.Publication__c = publicationCode_publicationId_map.get(so.publicationCode__c);
                publicationIssueData.Publication_Code__c = so.publicationCode__c;
                publicationIssueData.Publication_Issue_Date__c = DateUtility.convertDate(so.publicationIssueDate__c, '\\.', 'DMY');
                publicationIssueData.Publication_Issue_Number__c = so.publicationIssueNumber__c;
                publicationIssueData.Pagination__c = Integer.valueOf(so.pagination__c);
                publicationIssueData.Consolidation_Date__c = DateUtility.convertDate(so.consolidationDate__c, '\\.', 'DMY');
                publicationIssueData.Order_Closed_Indicator__c = so.orderClosedIndicator__c;
                //START 2015-04-24 Renz UD-0999 Only assign if orderClosedDate is not null
                if (so.orderCloseDate__c!=null) {
                    publicationIssueData.Order_Closed_Date__c = DateUtility.convertDate(so.orderCloseDate__c, '\\.', 'DMY');
                }
                //START 2015-04-24 Renz UD-0999 Only assign if orderClosedDate is not null
                
                if (publicationIssueData != null) {
                    publicationDailyIssueDataForInsert.add(publicationIssueData);   
                }
            }
        }   
    }
    //END D-1493 - Michael Francisco - 01.10.2015
    
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        insert publicationDailyIssueDataForInsert;
        update publicationDailyIssueDataForUpdate;
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }        
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'CMI077DX';
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