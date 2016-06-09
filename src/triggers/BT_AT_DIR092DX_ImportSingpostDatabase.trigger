/**
 * Trigger Name: BT_AT_DIR092DX_ImportVendorStaff
 * Author: Kevin Evasco
 * Date: 10/13/2014
 * Project/Requirement: SPH Integration - DIR092DX Interface
 * Description: This trigger contains the business logic for DIR092DX interface.
 * History: 2014/10/13 Kevin Evasco Created Apex Trigger
 * History: 2014/11/07 Renino Niefes reworked for singpost db old format (6 files)
 * History: 2015/01/21 Renino Niefes D-1656 CHanged the field to be used (buildingnumber into House_Block_Number__c) 
 * History: 2015/01/30 Renino Niefes D-1756 
 * History: 2015-06-17 Renino Niefes D-3115 Hot Fix - Add all records including for updates and re-create the postal image
 * History: 2015-08-27 Renino Niefes UD-2253 Hot fix - instead of filtering out the whole record if it's overriden, filter only the 3 fields
 */

trigger BT_AT_DIR092DX_ImportSingpostDatabase on BT_CO_DIR_ImportSingpostDatabase__c (before insert, before update) 
{    
    List<BT_CO_DIR_ImportSingpostDatabase__c> recordsList = trigger.new;
        
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';    
    
    List<Singpost_Address__c> singpostAddressForInsert = new List<Singpost_Address__c>();      
    List<Singpost_Address__c> existingSingpostAddressList = new List<Singpost_Address__c>();
    List<Singpost_Address__c> singpostAddressForUpdate = new List<Singpost_Address__c>();
    
    List<Attachment> allAttachments = new List<Attachment>();
    List<Attachment> attachmentsForDeletion = new List<Attachment>();
    
    Set<String> inputSingpostUniqueKeySet = new Set<String>();
    Set<String> newSingpostUniqueKeySet = new Set<String>();
    
    Set<Id> parentIDs = new Set<Id>();
    Set<String> filenameSet = new Set<String>();
    //[START 01/30/2015 D-1756 Renz Niefes]  Add new  variables
    String strBatchID = '';
    //[END 01/30/2015 D-1756 Renz Niefes]
    
    Map<String,BT_CO_DIR_ImportSingpostDatabase__c> uniqueKey_SO_Map = new Map<String,BT_CO_DIR_ImportSingpostDatabase__c>();
    
    for(BT_CO_DIR_ImportSingpostDatabase__c so : recordsList)
    {
        Boolean isValid = true;
        String validationDetails = '';
        
        //[START 01/30/2015 D-1756 Renz Niefes] Add the missing validations and remove BuildingName validation as it is not mandatory based on FDS

        if(so.postalCode__c == null || so.postalCode__c == '')
        {
            validationDetails += 'Postal Code cannot be null. ';
            isValid = false;        
        }
        if(so.AddressType__c == null || so.AddressType__c == '')
        {
            validationDetails += 'Address Type cannot be null. ';
            isValid = false;        
        }
        //if(so.buildingNo__c == null || so.buildingNo__c == '')
        //{
        //    validationDetails += 'House Block Number cannot be null. ';
        //    isValid = false;        
        //}
        //if(so.StreetKey__c == null || so.StreetKey__c == '')
        //{
        //    validationDetails += 'Street Key cannot be null. ';
        //    isValid = false;        
        //}
        //if(so.streetName__c == null || so.streetName__c == '')
        //{
        //    validationDetails += 'Street Name cannot be null. ';
        //    isValid = false;        
        //}
        
        if(isValid)
        {             
            //String uniqueKey = AddressUtility.constructSingpostUniqueKey(so.postalCode__c,so.floor__c,so.unit__c);
            String uniqueKey = so.SingpostKey__c;
            inputSingpostUniqueKeySet.add(uniqueKey);
            uniqueKey_SO_Map.put(uniqueKey,so);
            so.Validation_Status__c = 'Passed';
        }
        else
        {        
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = validationDetails;
            invalidRecordCount++; 
        }
        
        //Get the batch ID, this will be used to delete old data
        if (strBatchID==null || strBatchID == '') {
            strBatchID = so.Batch_Job_Id__c;
        }       
        //[END 01/30/2015 D-1756 Renz Niefes]       
    }
    
    //[START 01/30/2015 D-1756 Renz Niefes] Changed the algorithm in determining for update and for insert
    newSingpostUniqueKeySet.addAll(inputSingpostUniqueKeySet);
    
    existingSingpostAddressList = [SELECT Id, SingPost_Key__c, Address_Type_Overridden__c, Building__c, Street_Name_Overriden__c FROM Singpost_Address__c WHERE SingPost_Key__c IN :inputSingpostUniqueKeySet];
    

    //START UD-2253 Renino Niefes 2015-08-27 instead of skipping overriden records, just skip updating the 3 fields`
    //Update existing Singpost Address
    for(Singpost_Address__c singpostAddress : existingSingpostAddressList)
    {
        BT_CO_DIR_ImportSingpostDatabase__c so = uniqueKey_SO_Map.get(singpostAddress.SingPost_Key__c);
        newSingpostUniqueKeySet.remove(singpostAddress.SingPost_Key__c);
        
        //[START D-1656 01/21/2015 Renz] Change this into House_Block_Number__c        
        singpostAddress.House_Block_Number__c = so.buildingNo__c;
        //[END D-1656 01/21/2015 Renz]
        if (singpostAddress.Street_Name_Overriden__c == false) singpostAddress.Street_Name__c = so.streetName__c;            
        if (singpostAddress.Building__c == false) singpostAddress.Building_Name__c = so.buildingName__c;
        singpostAddress.SingPost_Building_Code__c = so.buildingCode__c;
        singpostAddress.Building_Type_Description__c = so.buildingDescription__c;

        //additional fields: Renz 2014-11-07
        if(singpostAddress.Address_Type_Overridden__c == false) singpostAddress.Address_Type__c = so.AddressType__c;
        singpostAddress.Number_of_Units__c = so.NumberOfUnits__c;
        singpostAddress.Street_Code__c = so.StreetKey__c;
        singpostAddress.Service_Number__c = so.ServiceNumber__c;
        singpostAddress.Walkup_Indicator__c = so.WalkupIndicator__c;
        //singpostAddress. = so.BuildingKey__c;
        //singpostAddress.SingPost_Key__c = so.SingpostKey__c;

        so.Name = 'FOR UPDATE';            
        singpostAddressForUpdate.add(singpostAddress);
    }
    
    
    //For Insert
    for(String uniqueKey : newSingpostUniqueKeySet)
    {  
        BT_CO_DIR_ImportSingpostDatabase__c so = uniqueKey_SO_Map.get(uniqueKey);
        Singpost_Address__c newSingpostAddress = new Singpost_Address__c();     
        
        newSingpostAddress.Name = so.postalCode__c;
        //[START D-1656 01/21/2015 Renz] Change this into House_Block_Number__c                
        newSingpostAddress.House_Block_Number__c = so.buildingNo__c;
        //[END D-1656 01/21/2015 Renz]
        newSingpostAddress.Street_Name__c = so.streetName__c;
        newSingpostAddress.Building_Name__c = so.buildingName__c;
        newSingpostAddress.Floor__c = so.floor__c;
        newSingpostAddress.Unit__c = so.unit__c;
        //newSingpostAddress.Number_of_Units__c = 0;
        newSingpostAddress.SingPost_Building_Code__c = so.buildingCode__c;
        newSingpostAddress.Building_Type_Description__c = so.buildingDescription__c;
        
        //additional fields: Renz 2014-11-07
        newSingpostAddress.Address_Type__c = so.AddressType__c;
        newSingpostAddress.Number_of_Units__c = so.NumberOfUnits__c;
        newSingpostAddress.Street_Code__c = so.StreetKey__c;
        newSingpostAddress.Service_Number__c = so.ServiceNumber__c;
        newSingpostAddress.Walkup_Indicator__c = so.WalkupIndicator__c;
        newSingpostAddress.SingPost_Key__c = so.SingpostKey__c;
        //singpostAddress. = so.BuildingKey__c;
        
        //Set the overriden flags to false
        newSingpostAddress.Address_Type_Overridden__c = false;
        newSingpostAddress.Building__c = false;
        newSingpostAddress.Street_Name_Overriden__c = false;
        
        so.Name = 'FOR INSERT';
        
        singpostAddressForInsert.add(newSingpostAddress);   
    }
    //END UD-2253 Renino Niefes 2015-08-27 instead of skipping overriden records, just skip updating the 3 fields`
    //[END 01/30/2015 D-1756 Renz Niefes]
    
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        update singpostAddressForUpdate;
        insert singpostAddressForInsert;
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_DIR092DX_ImportSingpostDatabase Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    } 

    //[START 01/30/2015 D-1756 Renz Niefes] Separate block for attachments (FOR INSERT only)
    try
    {       
        singpostAddressForInsert = [SELECT Id, SingPost_Key__c FROM Singpost_Address__c WHERE SingPost_Key__c IN :inputSingpostUniqueKeySet];
        
        
        for(Singpost_Address__c newSingpostAddress : singpostAddressForInsert)
        {           
            BT_CO_DIR_ImportSingpostDatabase__c so = uniqueKey_SO_Map.get(newSingpostAddress.SingPost_Key__c);

            Attachment attach = new Attachment();
            attach.contentType = 'image/png';
            attach.name = 'Bar Code ' + so.postalCode__c;
            attach.parentId = newSingpostAddress.Id;
            attach.body = EncodingUtil.base64Decode(so.postalCodeImageBase64__c);
            allAttachments.add(attach);
            parentIDs.add(newSingpostAddress.Id);
            filenameSet.add('Bar Code ' + so.postalCode__c);
        }       
        
        attachmentsForDeletion = [SELECT Id, parentId FROM Attachment WHERE parentId IN :parentIDs AND name IN :filenameSet];
        
        delete attachmentsForDeletion;      
        insert allAttachments;    
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_DIR092DX_ImportSingpostDatabase Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
        System.debug('DIR092DX: ZQ ' + errorMessage);
    } 
    //[END 01/30/2015 D-1756 Renz Niefes]    
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'DIR092DX';
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