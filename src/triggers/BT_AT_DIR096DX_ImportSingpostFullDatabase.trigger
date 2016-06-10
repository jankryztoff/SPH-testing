/**
 * Trigger Name: BT_AT_DIR096DX_ImportSingpostFullDatabase
 * Author: Kevin Evasco
 * Date: 01 March 2016
 * Project/Requirement: SPH Integration - DIR096DX Interface - D-4602
 * Description: This trigger contains the business logic for DIR096DX interface.
 */

trigger BT_AT_DIR096DX_ImportSingpostFullDatabase on BT_CO_DIR_ImportSingpostFullDatabase__c (before insert, before update) 
{    
    List<BT_CO_DIR_ImportSingpostFullDatabase__c> recordsList = trigger.new;
        
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
    String strBatchID = '';
    
    Map<String,BT_CO_DIR_ImportSingpostFullDatabase__c> uniqueKey_SO_Map = new Map<String,BT_CO_DIR_ImportSingpostFullDatabase__c>();
    
    for(BT_CO_DIR_ImportSingpostFullDatabase__c so : recordsList)
    {
        String uniqueKey = so.SingpostKey__c;
        inputSingpostUniqueKeySet.add(uniqueKey);
        uniqueKey_SO_Map.put(uniqueKey,so);
        
        //Get the batch ID, this will be used to delete old data
        if (strBatchID==null || strBatchID == '') {
            strBatchID = so.Batch_Job_Id__c;
        }       
    }
    
    newSingpostUniqueKeySet.addAll(inputSingpostUniqueKeySet);
    
    existingSingpostAddressList = [SELECT Id, SingPost_Key__c, Address_Type_Overridden__c, Building__c, Street_Name_Overriden__c FROM Singpost_Address__c WHERE SingPost_Key__c IN :inputSingpostUniqueKeySet];
    

    for(Singpost_Address__c singpostAddress : existingSingpostAddressList)
    {
        BT_CO_DIR_ImportSingpostFullDatabase__c so = uniqueKey_SO_Map.get(singpostAddress.SingPost_Key__c);
        newSingpostUniqueKeySet.remove(singpostAddress.SingPost_Key__c);
          
        singpostAddress.House_Block_Number__c = so.buildingNo__c;
        if (singpostAddress.Street_Name_Overriden__c == false) singpostAddress.Street_Name__c = so.streetName__c;            
        if (singpostAddress.Building__c == false) singpostAddress.Building_Name__c = so.buildingName__c;
        singpostAddress.SingPost_Building_Code__c = so.buildingCode__c;
        singpostAddress.Building_Type_Description__c = so.buildingDescription__c;

        if(singpostAddress.Address_Type_Overridden__c == false) singpostAddress.Address_Type__c = so.houseType__c;

        so.Name = 'FOR UPDATE';            
        singpostAddressForUpdate.add(singpostAddress);
    }
    
    
    //For Insert
    for(String uniqueKey : newSingpostUniqueKeySet)
    {  
        BT_CO_DIR_ImportSingpostFullDatabase__c so = uniqueKey_SO_Map.get(uniqueKey);
        Singpost_Address__c newSingpostAddress = new Singpost_Address__c();     
        
        newSingpostAddress.SingPost_Key__c = so.SingpostKey__c;
        newSingpostAddress.Name = so.postalCode__c;            
        newSingpostAddress.House_Block_Number__c = so.buildingNo__c;
        newSingpostAddress.Street_Name__c = so.streetName__c;
        newSingpostAddress.Building_Name__c = so.buildingName__c;
        newSingpostAddress.SingPost_Building_Code__c = so.buildingCode__c;
        newSingpostAddress.Building_Type_Description__c = so.buildingDescription__c;
        newSingpostAddress.Address_Type__c = so.houseType__c;
        
        newSingpostAddress.Address_Type_Overridden__c = false;
        newSingpostAddress.Building__c = false;
        newSingpostAddress.Street_Name_Overriden__c = false;
        
        so.Name = 'FOR INSERT';
        
        singpostAddressForInsert.add(newSingpostAddress);   
    }
    
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
        System.debug('BT_AT_DIR096DX_ImportSingpostFullDatabase Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    } 

    try
    {       
        singpostAddressForInsert = [SELECT Id, SingPost_Key__c FROM Singpost_Address__c WHERE SingPost_Key__c IN :inputSingpostUniqueKeySet];
        
        
        for(Singpost_Address__c newSingpostAddress : singpostAddressForInsert)
        {           
            BT_CO_DIR_ImportSingpostFullDatabase__c so = uniqueKey_SO_Map.get(newSingpostAddress.SingPost_Key__c);

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
        System.debug('BT_AT_DIR096DX_ImportSingpostFullDatabase Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
        System.debug('DIR096DX: ZQ ' + errorMessage);
    }   
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'DIR096DX';
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