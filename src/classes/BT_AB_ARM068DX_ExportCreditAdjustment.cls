/*
 * Class Name: BT_AB_ARM068DX_ExportCreditAdjustment
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - ARM068DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for ARM068DX batch job
 * 
 * History: 09 March 2016 - New Class for UD-3247
*/


global class BT_AB_ARM068DX_ExportCreditAdjustment implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    global final String interfaceId = 'ARM068DX';
    
    public class GenericException extends Exception{}
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator
        ([
            SELECT
                Billing_Account__r.Zuora__Account__r.Account_Auto_Number__c,
                Billing_Account__r.ARMS_Account_Number__c,
                Case__r.Actual_Approver_Name__c,
                Credit_Amount__c,
                Document_Date__c, 
                Name
            FROM Credit_Adjustment__c
            
            WHERE To_ARMS_Time__c = null
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Credit_Adjustment__c> scope) //START/END 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
    {       
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        
        for (Credit_Adjustment__c ca : scope) {
            ca.To_ARMS_Time__c = DateTime.now();
            
            //Create Header Record for each credit adjustment
            String exportHeaderData = '';
            exportHeaderData += ca.Name + ','; //Reference Number
            exportHeaderData += ca.Document_Date__c + ','; //Document Date
            exportHeaderData += ca.Document_Date__c + ','; //Posting Date 
            exportHeaderData += ca.Document_Date__c + ','; //Baseline Date 
            exportHeaderData += ca.Credit_Amount__c + ','; //Document Amount         

            // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord2 = new BA_INT_DATA_POOL__c();
            datapoolRecord2.Name = interfaceId;
            datapoolRecord2.job_id__c = '1';
            datapoolRecord2.group_id__c = 'Master';
            datapoolRecord2.run_for_date__c = Date.today();      
            datapoolRecord2.insert_time__c = DateTime.now(); 
            datapoolRecord2.export_data__c = exportHeaderData;              
            datapoolList.add(datapoolRecord2);

            String exportData = '';
            exportData += StringUtility.quoteReplaceStr(ca.Billing_Account__r.ARMS_Account_Number__c) + ',';  //Account Number
            exportData += StringUtility.quoteReplaceStr('S') + ','; //Sales Type 
            exportData += StringUtility.quoteReplaceStr(' ') + ',';
            exportData += StringUtility.quoteReplaceStr('JP') + ',';//Publication 
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Depot Group
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Depot Group Description 
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Outlet Customer Name
            exportData += StringUtility.quoteReplaceStr(ca.Billing_Account__r.Zuora__Account__r.Account_Auto_Number__c) + ',';//Synonym 
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Client No 
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Negative Discount Indicator
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Filler 
            exportData += 0 + ',';//No Of Copies
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Issue No 
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Issue Date
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Start Date
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Stop Date
            exportData += 0 + ',';//Insertion Amount
            exportData += 0 + ',';//Pagination Amount
            exportData += 0 + ',';//NRA Amount 
            exportData += 0 + ',';//Freight Charge
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Freight Type
            exportData += Decimal.valueOf(0).setScale(4) + ',';//GST Rate
            exportData += 0 + ',';//GST Amount
            exportData += ca.Credit_Amount__c + ',';//Gross Amount
            exportData += ca.Credit_Amount__c + ',';//Gross Sales
            exportData += ca.Credit_Amount__c + ','; //Net Amount After GST 
            exportData += 0 + ',';//Adjustment to Commission Amount
            exportData += 0 + ',';//Commission 
            exportData += 0 + ',';//Discount
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Due Date
            exportData += StringUtility.quoteReplaceStr(ca.Billing_Account__r.Zuora__Account__r.Account_Auto_Number__c) + ',';//Remark1
            exportData += StringUtility.quoteReplaceStr(ca.Case__r.Actual_Approver_Name__c) + ',';//Approved By
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Reference Doc No (for CN)
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Sign Indicator
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//GL account 
            exportData += 0 + ',';//Handling Fee
            exportData += 0 + ',';//Delivery Fee
            exportData += 0 + ',';//Miscellaneous Amount
            exportData += StringUtility.quoteReplaceStr(' ') + ',';//Bundle Code

            // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.Name = interfaceId;
            datapoolRecord.job_id__c = '1';
            datapoolRecord.group_id__c = 'Detail';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;

            datapoolList.add(datapoolRecord);
        }   
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            Database.insert(datapoolList,true);
            Database.update(scope, true);
        }
        catch(Exception ex)
        {    
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_ARM068DX_ExportCreditAdjustment insert operation failed.');
            System.debug('Exception Message: ' + ex.getMessage());
            System.debug('Exception Stack Trace: ' + ex.getStackTraceString());
            BT_AU_BATCHRUNREQUEST_UpdateInfo.abortJob(BC.getJobId(), interfaceId, BT_AB_ARM068DX_ExportCreditAdjustment.class.getName(), ex, true);
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        BT_AU_BATCHRUNREQUEST_UpdateInfo.delegateBatchCall(interfaceId,true);
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);
    }
}