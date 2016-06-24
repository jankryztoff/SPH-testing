/**
 * Trigger Name: BT_AT_ARM063DX_2_CreateAccountBatchResonseFile
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - ARM063DX_2 Interface
 * Description: This trigger contains the business logic for ARM063DX_2 interface.
 * History: 2014/08/21 Kevin Evasco Created Skeletal Apex Trigger
 *          2014/09/22 Kevin Evasco Updated to implement business logic
 * History: 2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings) 
 *          2015/02/27 D-1857 Renino Niefes (Remove the all-or-nothing validation due to salesforce bulk api limitation)
 */

trigger BT_AT_ARM063DX_2_CreateAccountBatchResonseFile on BT_CO_ARMS_CreateAccountBatchResonseFile__c (before insert, before update) 
{    
    List<BT_CO_ARMS_CreateAccountBatchResonseFile__c> recordsList = trigger.new;
 
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';    
    
    //START 2015/02/27 D-1857 Renino Niefes (Remove the all-or-nothing validation due to salesforce bulk api limitation)
        List<Zuora__CustomerAccount__c> billingAccountsForUpdate = new List<Zuora__CustomerAccount__c>();
        
        Set<String> inputCcrIdSet = new Set<String>();
        Set<String> existingCcrIdSet = new Set<String>();
        Set<String> validCcrIdSet = new Set<String>();
        
        Map<String,BT_CO_ARMS_CreateAccountBatchResonseFile__c> ccrId_SO_map = new Map<String,BT_CO_ARMS_CreateAccountBatchResonseFile__c>();
        
        for(BT_CO_ARMS_CreateAccountBatchResonseFile__c so : recordsList)
        {
            //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
            if (so.ccrId__c!=null) inputCcrIdSet.add(so.ccrId__c);
            //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        }                
        
        for(Zuora__CustomerAccount__c zBillingAccount : [SELECT Id, ARMS_Customer_Number__c FROM Zuora__CustomerAccount__c WHERE ARMS_Customer_Number__c IN :inputCcrIdSet])  //START/END 2015-02-27 D-1857 Renz It should be mapped to ARMS_Customer_Number__c
        {
            //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
            if (zBillingAccount.ARMS_Customer_Number__c!=null) existingCcrIdSet.add(zBillingAccount.ARMS_Customer_Number__c);
            //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        }
        
        for(BT_CO_ARMS_CreateAccountBatchResonseFile__c so : recordsList)
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
                if(Integer.valueOf(so.returnStatus__c) == 2)
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
            
            if(existingCcrIdSet.contains(so.ccrId__c) == false)
            {
                validationDetails += 'CCR Id (ARMS Customer Number) does not exist in Salesforce Billing Account records. ';
                isValid = false;
            }
            
            if(DateUtility.isDateYYYYMMDD(so.accountCreationDate__c) == false)
            {
                validationDetails += 'Account Creation Date format must be YYYYMMDD. ';
                isValid = false;
            }
            
            if(so.creditLimitInternal__c != '' && so.creditLimitInternal__c != null)
            {
                try
                {
                    Decimal.valueOf(so.creditLimitInternal__c);
                }
                catch(Exception e)
                {
                    validationDetails += 'Credit Limit Internal must be a decimal number. ';
                    isValid = false;
                }
            }
            
            if(so.creditLimitExternal__c != '' && so.creditLimitExternal__c != null)
            {
                try
                {
                    Decimal.valueOf(so.creditLimitExternal__c);
                }
                catch(Exception e)
                {
                    validationDetails += 'Credit Limit External must be a decimal number. ';
                    isValid = false;
                }
            }
            
            if(so.approvedDebtExposureAmount__c != '' && so.approvedDebtExposureAmount__c != null)
            {
                try
                {
                    Decimal.valueOf(so.approvedDebtExposureAmount__c);
                }
                catch(Exception e)
                {
                    validationDetails += 'Approved Debt Exposure Amount must be a decimal number. ';
                    isValid = false;
                }
            }
            
            if(isValid)
            {             
                so.Validation_Status__c = 'Passed';             
                //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
                if (so.ccrId__c!=null) {
                    validCcrIdSet.add(so.ccrId__c);
                    ccrId_SO_map.put(so.ccrId__c,so);
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

        billingAccountsForUpdate = [SELECT Id, ARMS_Customer_Number__c FROM Zuora__CustomerAccount__c WHERE ARMS_Customer_Number__c IN :validCcrIdSet]; //START/END 2015-02-27 D-1857 Renz It should be mapped to ARMS_Customer_Number__c
        
        for(Zuora__CustomerAccount__c billingAccount : billingAccountsForUpdate)
        {
            BT_CO_ARMS_CreateAccountBatchResonseFile__c so = ccrId_SO_map.get(billingAccount.ARMS_Customer_Number__c); //START/END 2015-02-27 D-1857 Renz It should be mapped to ARMS_Customer_Number__c
            
            billingAccount.ARMS_Account_Number__c = so.accountNumber__c;
            billingAccount.Credit_Reference__c = so.creditTermReference__c;
            //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
            billingAccount.Credit_Limit_Internal__c = Decimal.valueOf(so.creditLimitInternal__c)/100;
            billingAccount.Credit_Limit_External__c = Decimal.valueOf(so.creditLimitExternal__c)/100;
            billingAccount.Approved_Debt_Exposure_Amount__c = Decimal.valueOf(so.approvedDebtExposureAmount__c)/100;
            //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
            billingAccount.ARMS_Debt_Management__c = so.debtManagementTreatment__c;
            billingAccount.Business_Sector__c = so.businessSector__c;
        }        
        
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            update billingAccountsForUpdate;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AT_ARM063DX_2_CreateAccountBatchResonseFile DML operation failed.');
            dmlStatus = 'Failed';
            errorMessage  = e.getMessage();
            stackTrace = e.getStackTraceString();
        }                    
    //END 2015/02/27 D-1857 Renino Niefes (Remove the all-or-nothing validation due to salesforce bulk api limitation)
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'ARM063DX_2';
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