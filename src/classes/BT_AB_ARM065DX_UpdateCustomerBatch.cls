/*
 * Class Name: BT_AB_ARM065DX_UpdateCustomerBatch
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - ARM065DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for ARM065DX batch job. Used together with BT_AS_ARM065DX_UpdateCustomerBatch Schedulable
 * 
 * History: 08/26/2014 Kevin Evasco Created Skeletal Apex Batchable
 * History: 09/23/2014 Renino Niefes added codes to retrieve the data into the datapool
 * History: 2015-04-15 D-2752 Renz: Enclose all fields with quotes
 * History: 2015-04-23 D-2805 REnz: Add Contact_Name__c in start block
 */


global class BT_AB_ARM065DX_UpdateCustomerBatch implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    global final String query = 'SELECT RecordType__c, ' +
                                '       CCRID__c, ' +
                                '       Customer_Name1__c, ' +
                                '       Customer_Name2__c, ' +
                                '       Customer_Status__c, ' +
                                '       BlackList_Indicator__c, ' +
                                '       Blacklist_Colour_Code__c, ' +
                                '       Blacklist_Reason__c, ' +
                                '       ID_Type__c, ' +
                                '       ID_Number__c, ' +
                                '       Passport_CountryCode__c, ' +
                                '       Credit_Risk_Rating__c, ' +
                                '       Block_House_No__c, ' +
                                '       Floor_No__c, ' +
                                '       Unit_No__c, ' +
                                '       Street__c, ' +
                                '       Building_Secondary__c, ' +
                                '       Address1__c, ' +
                                '       Address2__c, ' +
                                '       Address3__c, ' +
                                '       Address4__c, ' +
                                '       Postal_Code__c, ' +
                                '       City_Zip__c, ' +
                                '       Country__c, ' +
                                '       PO_Box_No__c, ' +
                                '       CareOf_ATtentionTo_Party__c, ' +
                                '       CareOf_AttentionTo_Indicator__c, ' +
                                '       ReferenceKey__c, ' +
                                '       UniqueKey__c, ' +
                                '       Business_Profile__c, ' +
                                '       SPH_Staff_Indicator__c, ' +
                                '       Update_ID__c, ' +
                                '       UpdateDate__c, ' +
                                '       UpdateTime__c, ' +
                                '       GST_OutOfScope_Indicator__c, ' +
                                '       Contact_Designation__c, ' +
                '       Contact_Name__c, ' + //START/END 2015-04-23 D-2805 REnz: Add Contact_Name__c in start block
                                '       Contact_Type__c, ' +
                                '       ContactNo_Email__c, ' +
                                '       Contact_Extension__c ' +    
                                'FROM BT_CO_ARMS_UpdateCustomerBatchFile__c ' +
                                'WHERE Status__c = \'new\' ' + 
                                'ORDER BY Sort_Order__c';                               
                                
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = 'ARM065DX'];
        delete resultList;
        
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
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> armsList = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();

        for(sObject record : scope)
        {                       
            BT_CO_ARMS_UpdateCustomerBatchFile__c armsRecord = (BT_CO_ARMS_UpdateCustomerBatchFile__c) record;          
            //START D-3775 10/29/15 RReyes
            String tempCont = '';
            if(armsRecord.ContactNo_Email__c != null){
                tempCont = armsRecord.ContactNo_Email__c;
                if(tempCont.length() > 40){
                    armsRecord.ContactNo_Email__c = tempCont.subString(0,40);
                }
            }
            //END D-3775 10/29/15 RReyes
            armsRecord.Status__c = 'sent';
            armsList.add(armsRecord);
            
            String exportData = '';     
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            
            if (armsRecord.RecordType__c == 'Master')
            {
        //START D-2752 2015-04-15 Renz: Enclose all fields with quotes
                // Prepare Export Data
                exportData += StringUtility.quoteReplaceStr(armsRecord.CCRID__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Customer_Name1__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Customer_Name2__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Customer_Status__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.BlackList_Indicator__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Blacklist_Colour_Code__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Blacklist_Reason__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.ID_Type__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.ID_Number__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Passport_CountryCode__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Credit_Risk_Rating__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Block_House_No__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Floor_No__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Unit_No__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Street__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Building_Secondary__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Address1__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Address2__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Address3__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Address4__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Postal_Code__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.City_Zip__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Country__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.PO_Box_No__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.CareOf_ATtentionTo_Party__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.CareOf_AttentionTo_Indicator__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.ReferenceKey__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.UniqueKey__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Business_Profile__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.SPH_Staff_Indicator__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Update_ID__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.UpdateDate__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.UpdateTime__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.GST_OutOfScope_Indicator__c);
        //END D-2752 2015-04-15 Renz: Enclose all fields with quotes
      
                // Prepare Data Pool information here
                datapoolRecord.Name = 'ARM065DX';
                datapoolRecord.job_id__c = '1';
                datapoolRecord.group_id__c = 'Master';
                datapoolRecord.run_for_date__c = Date.today();      
                datapoolRecord.insert_time__c = DateTime.now(); 
                datapoolRecord.export_data__c = exportData;             
            }
            else 
            {
                // Prepare Export Data
                exportData += armsRecord.Contact_Name__c + ',';
                exportData += armsRecord.Contact_Designation__c + ',';
                exportData += armsRecord.Contact_Type__c + ',';
                exportData += armsRecord.ContactNo_Email__c + ',';
                exportData += armsRecord.Contact_Extension__c;
            
                // Prepare Data Pool information here
                datapoolRecord.Name = 'ARM065DX';
                datapoolRecord.job_id__c = '1';
                datapoolRecord.group_id__c = 'Detail';
                datapoolRecord.run_for_date__c = Date.today();      
                datapoolRecord.insert_time__c = DateTime.now(); 
                datapoolRecord.export_data__c = exportData;         
            }
            
            datapoolList.add(datapoolRecord);
        }       

        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
            update armsList;  //comment it for now
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_ARM065DX_UpdateCustomerBatch insert operation failed.');
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
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('ARM065DX');            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        //System.debug('*********************** inside final'+ this.query);
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID('ARM065DX');
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');        

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('ARM065DX');
        
    }
}