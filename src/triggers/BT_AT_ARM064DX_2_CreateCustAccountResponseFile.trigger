/**
 * Trigger Name: BT_AT_ARM064DX_2_CreateCustAccountResponseFile
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - ARM064DX_2 Interface
 * Description: This trigger contains the business logic for ARM064DX_2 interface.
 * History: 2014/08/21 Kevin Evasco Created Skeletal Apex Trigger
 *          2014/09/24 Kevin Evasco Updated to implement business logic
 * History: 2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings) 
            2015/02/27 D-1858 Renino Niefes (Remove the all-or-nothing validation due to salesforce bulk api limitation)
 */

trigger BT_AT_ARM064DX_2_CreateCustAccountResponseFile on BT_CO_ARMS_CreateCustAccountResponseFile__c (before insert, before update) 
{    
    List<BT_CO_ARMS_CreateCustAccountResponseFile__c> recordsList = trigger.new;    
    
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';    
    
    //START 2015/02/27 D-1858 Renino Niefes (Remove the all-or-nothing validation due to salesforce bulk api limitation)
        List<Zuora__CustomerAccount__c> billingAccountsForUpdate = new List<Zuora__CustomerAccount__c>();
        
        Set<String> inputIdSet = new Set<String>();
        Set<String> existingIdSet = new Set<String>();
        Set<String> validIdSet = new Set<String>();
        
        Map<String,BT_CO_ARMS_CreateCustAccountResponseFile__c> id_SO_map = new Map<String,BT_CO_ARMS_CreateCustAccountResponseFile__c>();
        
        for(BT_CO_ARMS_CreateCustAccountResponseFile__c so : recordsList)
        {
            //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
            if (so.uniqueKey__c!=null) inputIdSet.add(so.uniqueKey__c);
            //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        }                
        
        for(Zuora__CustomerAccount__c zBillingAccount : [SELECT Id, Zuora__Account__r.AccountNumber FROM Zuora__CustomerAccount__c WHERE Zuora__Account__r.AccountNumber IN :inputIdSet]) //START/END 2015-02-27 D-1858 Renz It should be mapped to Account's Account Number
        {
            //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
            if (zBillingAccount.Zuora__Account__r.AccountNumber!=null) existingIdSet.add(zBillingAccount.Zuora__Account__r.AccountNumber); //START/END 2015-02-27 D-1858 Renz It should be mapped to Account's Account Number
            //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        }
        
        for(BT_CO_ARMS_CreateCustAccountResponseFile__c so : recordsList)
        {
            Boolean isValid = true;
            String validationDetails = '';
            
            try
            {
                if(Integer.valueOf(so.returnStatus__c) > 0)
                {
                    validationDetails += 'Unable to process unsuccessful records. ';
                    isValid = false;
                }
                
                //Nitin Khanna : 19-may-2016 : PD-0265 : capture details sent by arms in case the account already exists in ARMS : START
                /*if(Integer.valueOf(so.returnStatus__c) == 2)
                {
                    validationDetails += 'ARMS details updated using existing details from ARMS';
                    isValid = true;
                }
                */
                if(Integer.valueOf(so.returnStatus__c) == 4)
                {

                    isValid = true;
                    validationDetails = '';
                }
                //Nitin Khanna : 19-may-2016 : PD-0265 : capture details sent by arms in case the account already exists in ARMS : END 
            }
            catch(Exception e)
            {   
                validationDetails += 'Invalid Return Status. ';
                isValid = false;
            }
            
            if(existingIdSet.contains(so.uniqueKey__c) == false)
            {
                validationDetails += 'Unique Key does not exist in Salesforce Billing Account records. ';
                isValid = false;
            }            
            
            if(DateUtility.isDateYYYYMMDD(so.customerCreateDate__c) == false)
            {
                validationDetails += 'Customer Create Date format must be YYYYMMDD. ';
                isValid = false;
            }
            
            if(DateUtility.isDateYYYYMMDD(so.accountCreationDate__c) == false)
            {
                validationDetails += 'Account Creation Date format must be YYYYMMDD. ';
                isValid = false;
            }
            
            if(isValid)
            {             
                so.Validation_Status__c = 'Passed';
                //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
                if (so.uniqueKey__c!=null) {
                    validIdSet.add(so.uniqueKey__c);
                    id_SO_map.put(so.uniqueKey__c,so);
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
    //START D-3619 01-Oct-2015 Added By S.Puli - filter invoice billing accounts only
        billingAccountsForUpdate = [SELECT Id, ARMS_Customer_Number__c, ARMS_Account_Number__c, Zuora__Account__r.AccountNumber, Other_PaymentMethod__c, ARMS_ID__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__r.AccountNumber IN :validIdSet AND Other_PaymentMethod__c = 'Invoice']; //START/END 2015-02-27 D-1858 Renz It should be mapped to Account's Account Number
        //END D-3619 01-Oct-2015 Added By S.Puli
        for(Zuora__CustomerAccount__c billingAccount : billingAccountsForUpdate)
        {
            BT_CO_ARMS_CreateCustAccountResponseFile__c so = id_SO_map.get(billingAccount.Zuora__Account__r.AccountNumber);
            
            //START 2015-02-27 D-1858 Renz Niefes Only update this record if it has value in the SPH feed file. Only assign the value to the field if it's empty or null
            if (so.accountNumber__c!=null&&so.accountNumber__c!='') {
                if (billingAccount.ARMS_Account_Number__c==null||billingAccount.ARMS_Account_Number__c=='')
                    billingAccount.ARMS_Account_Number__c = so.accountNumber__c; 
            }
            
            if (so.ccrId__c!=null&&so.ccrId__c!='') {
                if (billingAccount.ARMS_Customer_Number__c==null||billingAccount.ARMS_Customer_Number__c=='')
                    billingAccount.ARMS_Customer_Number__c = so.ccrId__c;
                    //START D-3619 01-Oct-2015 Added By S.Puli
                    billingAccount.ARMS_ID__c = so.ccrId__c;
                    //END D-3619 01-Oct-2015 Added By S.Puli
            }
            //END 2015-02-27 D-1858 Renz Niefes
        }        
        
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            ARMS_triggerHandler.isskipupdate=true;
            update billingAccountsForUpdate;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            dmlStatus = 'Failed';
            errorMessage  = e.getMessage();
            stackTrace = e.getStackTraceString();
        }                    
    
    //END 2015/02/27 D-1858 Renino Niefes (Remove the all-or-nothing validation due to salesforce bulk api limitation)
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'ARM064DX_2';
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