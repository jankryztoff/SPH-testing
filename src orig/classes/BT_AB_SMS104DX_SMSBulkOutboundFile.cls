/*
 * Class Name: BT_AB_SMS104DX_SMSBulkOutboundFile
 * @author: Michael Francisco
 * Date: 2015/03/10
 * Project/Requirement: SPH Integration - SMS104DX Interface
 * @description This class will perform the following
 *              1) Pull data from the SMS_Outbound__c object 
 *              2) Stores valid data into BA_INT_DATA_POOL__c 
 *              3) Update SMS_Outbound__c depending on whether the record was processed successfully or not
 * 
 * History: 2015/03/10 Michael Francisco - Created initial Apex Class
 */


global class BT_AB_SMS104DX_SMSBulkOutboundFile implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // TO-DO: Create a custom setting to store all Integration Batch InterfaceID values ...
    global final String interfaceId = 'SMS104DX';
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList;  

        Set<String> SMS_Status_Set = new Set<String>();
        SMS_Status_Set.add('New');
        
        String query = '';
        query += ' SELECT ';
        query += '    Mobile__c, ';
        query += '    SMS_message__c, ';
        query += '    SMS_status__c, ';
        query += '    Failed_Reason__c, ';
        query += '    IsDeleted ';
        query += ' FROM SMS_Outbound__c ';
        query += ' WHERE ' ;
        query += ' IsDeleted = FALSE ';
        query += ' AND SMS_status__c IN :SMS_Status_Set ';          
        
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
        // Create initial variables
        List<SMS_Outbound__c> smsValidRecords = new List<SMS_Outbound__c>();
        List<SMS_Outbound__c> smsFailedRecords = new List<SMS_Outbound__c>();
        List<SMS_Outbound__c> smsProcessedRecords = new List<SMS_Outbound__c>();
        
        //PD-0123 - 09May2016 - Nitin Khanna : SMS delivery of stale messages : Start
        //String zValidationCode = '0';
        //PD-0123 - 09May2016 - Nitin Khanna : SMS delivery of stale messages : End
        
        //START 02 February 2016 D-4378 Kevin Evasco - Remove invalid characters 
        String invalidCharacterSet = ConstantsSLB.getKeyId('SMS104DX Invalid characters');
        String[] invalidCharacterArray = invalidCharacterSet.split('/\\$/');        
        //END 02 February 2016 D-4378 Kevin Evasco - Remove invalid characters 
                
        // Validate SMS records ...
        for (sObject record : scope)
        {
            //PD-0123 - 09May2016 - Nitin Khanna : SMS delivery of stale messages : Start
            String zValidationCode = '0';
            //PD-0123 - 09May2016 - Nitin Khanna : SMS delivery of stale messages : End
            
            SMS_Outbound__c sms_record = (SMS_Outbound__c) record;
            if (sms_record != null) {
                
                String zMobileNumber = sms_record.Mobile__c;
                // Validate Mobile Number data ...
                if (zMobileNumber != null && zMobileNumber.length() > 0) {
                    sms_record.Mobile__c = zMobileNumber.replaceAll('[^0-9]','');
                    zValidationCode += '0';
                } else {
                    zValidationCode += '1';                 
                }
                
                String zSMSMessage = sms_record.SMS_message__c;
                
                // Validate Message data ...
                if (zSMSMessage != null && zSMSMessage.length() > 0) {
                    //START 02 February 2016 D-4378 Kevin Evasco - Remove invalid characters 
                    zSMSMessage = zSMSMessage.trim();
                    zSMSMessage = zSMSMessage.replaceAll('\r\n', ' ');
                    zSMSMessage = zSMSMessage.replaceAll('\n', ' ');
                    zSMSMessage = zSMSMessage.replaceAll('\r', ' ');
                    for(Integer index = 0; index < invalidCharacterArray.size(); index++) {
                        zSMSMessage = zSMSMessage.replaceAll(invalidCharacterArray[index],'');
                    }
                    //END 02 February 2016 D-4378 Kevin Evasco - Remove invalid characters
                
                    sms_record.SMS_message__c = zSMSMessage.replaceAll('[,]',' ');
                    
                    zValidationCode += '0';
                } else {
                    zValidationCode += '1';     
                }           
            } 
            
            if (Decimal.valueOf(zValidationCode) == 0) {
                // Add record to list of valid records ...
                smsValidRecords.add(sms_record);
            } else {
                // Add SMS record to failed list ...
                sms_record.SMS_status__c = 'Failed';
                sms_record.Failed_Reason__c = 'ERROR-CODE('+zValidationCode+'00). Data Validation Failed.';
                smsFailedRecords.add(sms_record);
            }
        }
        
        // Process Valid SMS records ...
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        for(SMS_Outbound__c validSMSRecord : smsValidRecords)
        {            
            try {
                // Prepare Export-Data
                String exportData = '';     
                exportData += validSMSRecord.Mobile__c + ',';
                exportData += validSMSRecord.SMS_message__c + ',';            
            
                // Add SMS record to processed list ...
                validSMSRecord.SMS_status__c = 'Processed';
                smsProcessedRecords.add(validSMSRecord);

                // Prepare Data Pool information ...
                BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
                datapoolRecord.Name = interfaceId;
                datapoolRecord.job_id__c = '1';
                datapoolRecord.group_id__c = 'Detail';
                datapoolRecord.run_for_date__c = Date.today();      
                datapoolRecord.insert_time__c = DateTime.now(); 
                datapoolRecord.export_data__c = exportData;
                
                // Add Data Pool record to list ...
                datapoolList.add(datapoolRecord);           
            } catch(Exception e) {
                
                // Add SMS record to failed list ...
                validSMSRecord.SMS_status__c = 'Failed';
                validSMSRecord.Failed_Reason__c = 'ERROR-CODE(4200) Error Encountered during DATAPOOL export.';
                smsFailedRecords.add(validSMSRecord);
            }
        }
        
        // Set the database savepoint. In case DML Operation fails, use this save-point for roll-back.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
            update smsProcessedRecords;
            update smsFailedRecords;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_SMS104DX_SMSBulkOutboundFile DATAPOOL insert operation failed.');
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