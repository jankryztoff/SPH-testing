/**
 * Trigger Name: BT_AT_ARM069DX_OutstandingAmountInterface
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - ARM069DX Interface
 * Description: This trigger contains the business logic for ARM069DX interface.
 * History: 2014/08/21 Kevin Evasco Created Skeletal Apex Trigger
 * History: 2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings)
 * History: 2015/06/03 Renino Niefes UAT and GIThub sync up.  Found out that nullity checks for novasuite audit findings were missing.
 * History: 2015-06-26 D-2989 Renz Niefes removed the nullity check
 * History: 2015/07/28 UD-1986 Renz Niefes added two more validation rules due to FIELD_CUSTOM_VALIDATION_RULE created in salesforce
 * History: 2015/07/31 UD-1986 Renz Niefes removed two more validation rules due to FIELD_CUSTOM_VALIDATION_RULE created in salesforce
 */

trigger BT_AT_ARM069DX_OutstandingAmountInterface on BT_CO_ARMS_OutstandingAmountInterface__c (before insert, before update) 
{
    
    List<BT_CO_ARMS_OutstandingAmountInterface__c> recordsList = trigger.new;
 
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';  
    
    List<Zuora__CustomerAccount__c> billingAccountsForUpdate = new List<Zuora__CustomerAccount__c>();
        
    Set<String> inputARMSAccountNumberSet = new Set<String>();
    Set<String> existingARMSAccountNumberSet = new Set<String>();
    Set<String> validARMSAccountNumberSet = new Set<String>();    
      
    Set<String> inputSynonymSet = new Set<String>();
    Set<String> existingSynonymSet = new Set<String>();
    Set<String> validSynonymSet = new Set<String>();    
    
    Map<String,BT_CO_ARMS_OutstandingAmountInterface__c> accountNumber_SO_map = new Map<String,BT_CO_ARMS_OutstandingAmountInterface__c>();
    Map<String,BT_CO_ARMS_OutstandingAmountInterface__c> synonym_SO_map = new Map<String,BT_CO_ARMS_OutstandingAmountInterface__c>();
    
    for(BT_CO_ARMS_OutstandingAmountInterface__c so : recordsList)
    {
        //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
        if (so.accountNumber__c!=null) inputARMSAccountNumberSet.add(so.accountNumber__c);
        if (so.synonym__c!=null) inputSynonymSet.add(so.synonym__c);
        //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
    }                
    
    //START D-3799 - HotFix 21-Oct-2015 Added by Raviteja  - Updated the SOQL logic from 'OR' operator to 'AND' operator
    /*for(Zuora__CustomerAccount__c zBillingAccount : [SELECT Id, ARMS_Account_Number__c, Zuora__Account__r.Account_Auto_Number__c FROM Zuora__CustomerAccount__c 
                                    WHERE ARMS_Account_Number__c IN :inputARMSAccountNumberSet OR Zuora__Account__r.Account_Auto_Number__c IN :inputSynonymSet])*/
    for(Zuora__CustomerAccount__c zBillingAccount : [SELECT Id, ARMS_Account_Number__c, Zuora__Account__r.Account_Auto_Number__c
                                                                 FROM Zuora__CustomerAccount__c 
                                                                      WHERE ARMS_Account_Number__c IN :inputARMSAccountNumberSet 
                                                                              AND Zuora__Account__r.Account_Auto_Number__c IN :inputSynonymSet])
    {
    //End  D-3799 - HotFix 21-Oct-2015 Added by Raviteja 
        if(zBillingAccount.ARMS_Account_Number__c != null && zBillingAccount.ARMS_Account_Number__c != '')
        {
           existingARMSAccountNumberSet.add(zBillingAccount.ARMS_Account_Number__c);
            System.debug('SZ1 ------> ' + zBillingAccount.ARMS_Account_Number__c);
        }
        if(zBillingAccount.Zuora__Account__r.Account_Auto_Number__c != null && zBillingAccount.Zuora__Account__r.Account_Auto_Number__c != '')
        {        
            //[START 2015-06-26 D-2989 Renz Niefes] removed the nullity check
            existingSynonymSet.add(zBillingAccount.Zuora__Account__r.Account_Auto_Number__c);
            //[END 2015-06-26 D-2989 Renz Niefes]            
            System.debug('SZ2 ------> ' + zBillingAccount.Zuora__Account__r.Account_Auto_Number__c);
        }
    }
    System.debug('SZ3 ------> ' + existingARMSAccountNumberSet.size());
    System.debug('SZ4 ------> ' + existingSynonymSet.size());
    
    for(BT_CO_ARMS_OutstandingAmountInterface__c so : recordsList)
    {
        Boolean isValid = true;
        String validationDetails = '';        
        
        if(existingARMSAccountNumberSet.contains(so.accountNumber__c) == false && existingSynonymSet.contains(so.synonym__c) == false)
        {
            System.debug('SZ5 ------> false and false');
            if(existingARMSAccountNumberSet.contains(so.accountNumber__c) == false)
            {
                validationDetails += 'ARMS Account Number does not exist in Salesforce Billing Account records. ';
                System.debug('SZ6 ------> ARMS Account Number does not exist');
            }
            if(existingSynonymSet.contains(so.synonym__c) == false)
            {
                validationDetails += 'CMIS Account Number does not exist in Salesforce Billing Account records. ';
                System.debug('SZ7 ------> CMIS Account Number does not exist');
            }
            isValid = false;
        }
        
        if(isValid)
        {             
            so.Validation_Status__c = 'Passed';
            System.debug('SZ8 ------> Passed');
            if(existingARMSAccountNumberSet.contains(so.accountNumber__c))
            {
                validARMSAccountNumberSet.add(so.accountNumber__c);
                accountNumber_SO_map.put(so.accountNumber__c,so);
                System.debug('SZ9 ------> ARMS A/c Exits');
            }
            if(existingSynonymSet.contains(so.synonym__c))
            {
                validSynonymSet.add(so.synonym__c);
                synonym_SO_map.put(so.synonym__c,so);
                System.debug('SZ10 ------> CRSM A/c Exits');
            }
        }
        else
        {        
            System.debug('SZ11 ------> Failed');
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = validationDetails;
            //invalidRecordCount++; 
        }
    }

    billingAccountsForUpdate = [SELECT Id, ARMS_Account_Number__c, Zuora__Account__r.Account_Auto_Number__c,
                                    Payment_Mode__c,Other_PaymentMethod__c,
                                    ARMS_Debt_Management__c,ARMS_Business_Profile__c FROM Zuora__CustomerAccount__c 
                                    //START D-3799 -  HotFix 21-Oct-2015 Added by Raviteja  - Updated the SOQL logic from 'OR' operator to 'AND' operator
                                    //WHERE ARMS_Account_Number__c IN :validARMSAccountNumberSet OR Zuora__Account__r.Account_Auto_Number__c IN :validSynonymSet];
                                     WHERE ARMS_Account_Number__c IN :validARMSAccountNumberSet AND Zuora__Account__r.Account_Auto_Number__c IN :validSynonymSet];
                                    //End D-3799 -  HotFix 21-Oct-2015 Added by Raviteja
    
    for(Zuora__CustomerAccount__c billingAccount : billingAccountsForUpdate)
    {
        BT_CO_ARMS_OutstandingAmountInterface__c so;

        so = accountNumber_SO_map.get(billingAccount.ARMS_Account_Number__c);
        if(so == null)
        {
            so = synonym_SO_map.get(billingAccount.Zuora__Account__r.Account_Auto_Number__c);
        }
        
        //UD-1986 Additional validation rule
        //if (
        //  billingAccount.Payment_Mode__c.equalsIgnoreCase('Other')
        //  && billingAccount.Other_PaymentMethod__c.equalsIgnoreCase('Invoice') 
        //  && (StringUtility.validate(billingAccount.ARMS_Business_Profile__c).equalsIgnoreCase('1') 
        //      || StringUtility.validate(billingAccount.ARMS_Debt_Management__c).equalsIgnoreCase('1')
        //     )
        //  ) {
        //  
        //  System.debug('SZ12 ------> Additional Validation');
        //   so.Validation_Status__c = 'Failed';
        //    so.Validation_Details__c = 'ARMS Business Profile and/or ARMS Debt Managment is/are missing.';
        //    //invalidRecordCount++; 
        //} else {      
            System.debug('SZ13 ------> Before Update');
            //START PD-0211 - I-0123 30-May-2016 Added By Raviteja Kumar - Applying Logic for Negative amount 
            //billingAccount.ARMS_Total_Outstanding_Amount__c = Decimal.valueOf(so.totalOutstandingAmount__c)/100;     
            billingAccount.ARMS_Total_Outstanding_Amount__c = (so.negativeAmountIndicator1__c == '-' ? (-1*Decimal.valueOf(so.totalOutstandingAmount__c)/100) : Decimal.valueOf(so.totalOutstandingAmount__c)/100);     
            //END PD-0211 - I-0123 30-May-2016 Added By Raviteja Kumar
            //START D-4584 24-Mar-2016 Added by Raviteja  - Assigning value to ARMS_Credit_Balance__c 
            //billingAccount.Zuora__Credit_Balance__c = Decimal.valueOf(so.creditBalance__c)/100;   
            billingAccount.ARMS_Credit_Balance__c = Decimal.valueOf(so.creditBalance__c)/100;   
            //End D-4584 24-Mar-2016 Added by Raviteja
            billingAccount.GIRO_A_C__c = so.giroAccountNumber__c;
            billingAccount.GIRO_Bank_Code__c = so.bankCode__c;
        //START UD-2966 01-Oct-2015 Added By S.Puli - do not blank billing account field
        if(so.debitManagementStatus__c <> null && so.debitManagementStatus__c <> ''){
            //START PD-0211 - I-0123 18-May-2016 Added By Raviteja Kumar - updated ARMS_Activity_Status_Type__c assignment 
            //billingAccount.ARMS_Debt_Management__c = so.debitManagementStatus__c;
            billingAccount.ARMS_Activity_Status_Type__c = so.debitManagementStatus__c;
            //END PD-0211 - I-0123 18-May-2016 Added By Raviteja Kumar
        }
        //END UD-2966 01-Oct-2015 Added By S.Puli
            System.debug('SZ13 ------> After Update ----> is billingAccount == null ----> ' + (billingAccount == null));
        //}
    }

    //Count again the number of failed records
    invalidRecordCount=0;
    for(BT_CO_ARMS_OutstandingAmountInterface__c so : recordsList)
    {
        if (so.Validation_Status__c.equalsIgnoreCase('Failed')) {
            invalidRecordCount++; 
        }
    }
    
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        if(billingAccountsForUpdate.size()>0)
        {
            update billingAccountsForUpdate;
        }
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_ARM069DX_OutstandingAmountInterface DML operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }  


    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'ARM069DX';
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