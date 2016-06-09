/*
 * Class Name: BT_AB_ARM064DX_CreateCustomerAccount
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - ARM064DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for ARM064DX batch job. Used together with BT_AS_ARM064DX_CreateCustomerAccount Schedulable
 * 
 * History: 2014/08/26 Kevin Evasco Created Skeletal Apex Batchable
 *          2014/09/22 Renino Niefes  added codes and created staging object
 *          2015/03/06 Michael Francisco: D-2446 - Modified to replace ',' character if any exist 
 *          2015-05-06 Renino Niefes - Changed the sorting logic
 */


global class BT_AB_ARM064DX_CreateCustomerAccount implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    global final String query = 'SELECT Record_Type__c, ' +
                                '       Customer_Name1__c, ' +
                                '       Customer_Name2__c, ' +
                                '       Customer_Status__c, ' +
                                '       ID_Type__c, ' +
                                '       ID_No__c, ' +
                                '       Passport_Country_Code__c, ' +
                                '       Block_House_Number__c, ' +
                                '       Floor_Number__c, ' +
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
                                '       co_Attention_To_Party__c, ' +
                                '       Co_Attention_To_Indicator__c, ' +
                                '       Reference_Key__c, ' +
                                '       Unique_Key__c, ' +
                                '       Business_Profile__c, ' +
                                '       SPH_Staff_Indicator__c, ' +
                                '       Account_Type__c, ' +
                                '       Credit_Term__c, ' +
                                '       Credit_Term_Reference__c, ' +
                                '       Credit_Limit_Internal__c, ' +
                                '       Credit_Limit_External__c, ' +
                                '       Approved_Debt_Exposure_Amount__c, ' +
                                '       Debt_Mgt_Treatment__c, ' +
                                '       Create_Id__c, ' +
                                '       Company_Code__c, ' +
                                '       Business_Sector__c, ' +
                                '       SOA_Group__c, ' +
                                '       SOA_Supression_Indicator__c, ' +
                                '       Transient_Indicator__c, ' +
                                '       Retrieve_Account_Indicator__c, ' +
                                '       GST_OutOfScope_Indicator__c, ' +
                                '       Sub_Contact_Name__c, ' +
                                '       Sub_Contact_Designation__c, ' +
                                '       Sub_Contact_Type__c, ' +
                                '       Sub_ContactNo_Email__c, ' +
                                '       Sub_Contact_Ext__c ' +
                                'FROM BT_CO_ARMS_CreateCustAccountFile__c  ' +
                                'WHERE Status__c = \'new\'' +
                                'ORDER BY Reference_Key__c ASC, Record_Type__c DESC';  //START/END 2015-05-06 Renino Niefes - Changed the sorting logic
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = 'ARM064DX'];
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
        List<BT_CO_ARMS_CreateCustAccountFile__c> armsList = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
        
        for(sObject record : scope)
        {                       
            BT_CO_ARMS_CreateCustAccountFile__c armsRecord = (BT_CO_ARMS_CreateCustAccountFile__c) record;          
            //START D-3775 10/29/15 RReyes
            String tempCont = '';
            if(armsRecord.Sub_ContactNo_Email__c != null){
                tempCont = armsRecord.Sub_ContactNo_Email__c;
                if(tempCont.length() > 40){
                    armsRecord.Sub_ContactNo_Email__c = tempCont.subString(0,40);
                }
            }
            //END D-3775 10/29/15 RReyes            
            armsRecord.Status__c = 'sent';
            armsList.add(armsRecord);
            
            String exportData = '';     
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            
            if (armsRecord.Record_Type__c == 'Master')
            {
                //START D-2446 2015/03/06 Michael Francisco - Modified to replace ',' character if any exist
                // Prepare Export Data
                exportData += StringUtility.quoteReplaceStr(armsRecord.Customer_Name1__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Customer_Name2__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Customer_Status__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.ID_Type__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.ID_No__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Passport_Country_Code__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Block_House_Number__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Floor_Number__c) + ',';
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
                exportData += StringUtility.quoteReplaceStr(armsRecord.co_Attention_To_Party__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Co_Attention_To_Indicator__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Reference_Key__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Unique_Key__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Business_Profile__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.SPH_Staff_Indicator__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Account_Type__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Credit_Term__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Credit_Term_Reference__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Credit_Limit_Internal__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Credit_Limit_External__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Approved_Debt_Exposure_Amount__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Debt_Mgt_Treatment__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Create_Id__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Company_Code__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Business_Sector__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.SOA_Group__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.SOA_Supression_Indicator__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Transient_Indicator__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Retrieve_Account_Indicator__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.GST_OutOfScope_Indicator__c);
            
                // Prepare Data Pool information here
                datapoolRecord.Name = 'ARM064DX';
                datapoolRecord.job_id__c = '1';
                datapoolRecord.group_id__c = 'Master';
                datapoolRecord.run_for_date__c = Date.today();      
                datapoolRecord.insert_time__c = DateTime.now(); 
                datapoolRecord.export_data__c = exportData;             
            }
            else 
            {
                // Prepare Export Data
                exportData += StringUtility.quoteReplaceStr(armsRecord.Sub_Contact_Name__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Sub_Contact_Designation__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Sub_Contact_Type__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Sub_ContactNo_Email__c) + ',';
                exportData += StringUtility.quoteReplaceStr(armsRecord.Sub_Contact_Ext__c);
                //END D-2446 2015/03/06 Michael Francisco 
            
                // Prepare Data Pool information here
                datapoolRecord.Name = 'ARM064DX';
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
            System.debug('BT_AB_ARM064DX_CreateCustomerAccount insert operation failed.');
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
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('ARM064DX');            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        //System.debug('*********************** inside final'+ this.query);
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID('ARM064DX');
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');        

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('ARM064DX');
    }
}