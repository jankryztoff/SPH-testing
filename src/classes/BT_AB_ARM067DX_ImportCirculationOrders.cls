/*
 * Class Name: BT_AB_ARM067DX_ImportCirculationOrders
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - ARM067DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for ARM067DX batch job
 * 
 * History: 09 March 2016 - Total Class Revamp for UD-3247
*/


global class BT_AB_ARM067DX_ImportCirculationOrders implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    global final String interfaceId = 'ARM067DX';
    
    public class GenericException extends Exception{}
    ZuoraCallOut RefundCallOut = new ZuoraCallOut();
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //START UD-3912 5 April 2016 Kevin Evasco - Added new filter: ARMS Account Number != null
        //START D-4588 04 April 2016 Kevin Evasco - Changed immediate CB data type and value
        return Database.getQueryLocator
        ([
            SELECT
                Account_Number__c,
                ARMS_Number__c,
                Billing_Account__r.Zuora__External_Id__c,
                Credit_Note_Number__c,
                Document_Date__c,
                Id,
                Tax_Rate__c,
                Total_Amt_After_Tax__c
            FROM Credit_Note__c
            
            WHERE To_ARMS_Time__c = null AND Source_Invoice__r.Immediate_CB__c != 'Y' AND Billing_Account__r.Other_PaymentMethod__c = 'Invoice' AND Billing_Account__r.ARMS_Account_Number__c != null
        ]);
        //END D-4588 04 April 2016 Kevin Evasco - Changed immediate CB data type and value
        //END UD-3912 5 April 2016 Kevin Evasco - Added new filter: ARMS Account Number != null
    }
    
    global void execute(Database.BatchableContext BC, List<Credit_Note__c> scope) //START/END 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
    {       
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        List<Map<String, Object>> refundListMap = new List<Map<String, Object>>();
        Map<Id,List<Credit_Note_Item__c>> creditNoteItemMap = new Map<Id,List<Credit_Note_Item__c>>();
        
        Other__c minCreditNoteNumber = Other__c.getInstance('CN_NUMBER_MIN');
        Other__c maxCreditNoteNumber = Other__c.getInstance('CN_NUMBER_MAX');
        
        //START UD-3912 5 April 2016 Kevin Evasco - Credit Note Number check
        Integer minCreditNoteNumberInt = Integer.valueOf(minCreditNoteNumber.Value__c);
        Integer maxCreditNoteNumberInt = Integer.valueOf(maxCreditNoteNumber.Value__c);
        //END UD-3912 5 April 2016 Kevin Evasco - Credit Note Number check
        
        //START D-4724 22 April 2016 Kevin Evasco - Made Credit Note Item query selective.
        Set<Id> creditNoteItemIdSet = new Set<Id>();
        
        for (Credit_Note__c cn : scope) {
            creditNoteItemIdSet.add(cn.Id);
        }
        
        List<Credit_Note_Item__c> creditNoteItemList =
            [SELECT
                Amt_After_Tax__c,
                Amt_Before_Tax__c,  
                Credit_Note__c,         
                Id,
                Invoice__r.Name,
                Invoice__r.ARMS_Invoice_ID__c,
                Tax_Amt__c,
                Tax_Rate__c
            FROM Credit_Note_Item__c WHERE Credit_Note__c IN :creditNoteItemIdSet];
        //END D-4724 22 April 2016 Kevin Evasco - Made Credit Note Item query selective.
        
        for(Credit_Note_Item__c creditNoteItem : creditNoteItemList) {
            if(creditNoteItemMap.get(creditNoteItem.Credit_Note__c) == null)
                creditNoteItemMap.put(creditNoteItem.Credit_Note__c, new List<Credit_Note_Item__c>());
            creditNoteItemMap.get(creditNoteItem.Credit_Note__c).add(creditNoteItem);
        }
    
        //START UD-3912 5 April 2016 Kevin Evasco - Credit Note Number check
        for (Credit_Note__c cn : scope) {
        
            Boolean isValid = true;
            Integer cnNumber;
            
            try{
                cnNumber = Integer.valueOf(cn.Credit_Note_Number__c);
                if(cnNumber < minCreditNoteNumberInt || cnNumber > maxCreditNoteNumberInt)
                    isValid = false;
                
            } catch(Exception e) {
                isValid = false;
            }
            if(isValid) {
                cn.To_ARMS_Time__c = DateTime.now();
                List<Credit_Note_Item__c> cniList = creditNoteItemMap.get(cn.Id);
                
                if(cniList != null) {
                
                    Map<String,Object> refundMap = new Map<String, Object>();
                    refundMap.put('AccountId', cn.Billing_Account__r.Zuora__External_Id__c);                                 
                    refundMap.put('Amount', cn.Total_Amt_After_Tax__c);                                   
                    refundMap.put('SourceType', 'CreditBalance');                    
                    refundMap.put('Type', 'External');             
                    refundMap.put('MethodType', 'Other');          
                    refundMap.put('OtherPaymentMethod__c', 'Invoice');
                    refundListMap.add(refundMap);
                                
                    //Create Header Record for each credit notes
                    String exportHeaderData = '';
                    exportHeaderData += cn.Credit_Note_Number__c + ','; //Reference Number
                    exportHeaderData += cn.Document_Date__c + ','; //Document Date
                    exportHeaderData += cn.Document_Date__c + ','; //Posting Date 
                    exportHeaderData += cn.Document_Date__c + ','; //Baseline Date 
                    exportHeaderData += cn.Total_Amt_After_Tax__c + ','; //Document Amount         

                    // Prepare Data Pool information here
                    BA_INT_DATA_POOL__c datapoolRecord2 = new BA_INT_DATA_POOL__c();
                    datapoolRecord2.Name = interfaceId;
                    datapoolRecord2.job_id__c = '1';
                    datapoolRecord2.group_id__c = 'Master';
                    datapoolRecord2.run_for_date__c = Date.today();      
                    datapoolRecord2.insert_time__c = DateTime.now(); 
                    datapoolRecord2.export_data__c = exportHeaderData;              
                    datapoolList.add(datapoolRecord2);

                    for(Credit_Note_Item__c cniRecord : cniList){
                        String exportData = '';
                        exportData += StringUtility.quoteReplaceStr(cn.ARMS_Number__c) + ',';  //Account Number
                        exportData += StringUtility.quoteReplaceStr('S') + ','; //Sales Type 
                        exportData += StringUtility.quoteReplaceStr(' ') + ',';
                        exportData += StringUtility.quoteReplaceStr('JP') + ',';//Publication 
                        exportData += StringUtility.quoteReplaceStr(' ') + ',';//Depot Group
                        exportData += StringUtility.quoteReplaceStr(' ') + ',';//Depot Group Description 
                        exportData += StringUtility.quoteReplaceStr(' ') + ',';//Outlet Customer Name
                        exportData += StringUtility.quoteReplaceStr(cn.Account_Number__c) + ',';//Synonym 
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
                        
                        Decimal taxRate = 0;
                        if(cniRecord.Tax_Rate__c != null){
                            taxRate = cniRecord.Tax_Rate__c / 100;
                        } 
                        exportData += taxRate.setScale(4) + ',';//GST Rate
                        
                        exportData += cniRecord.Tax_Amt__c + ',';//GST Amount
                        exportData += cniRecord.Amt_Before_Tax__c + ',';//Gross Amount
                        exportData += cniRecord.Amt_Before_Tax__c + ',';//Gross Sales
                        exportData += cniRecord.Amt_After_Tax__c + ','; //Net Amount After GST 
                        exportData += 0 + ',';//Adjustment to Commission Amount
                        exportData += 0 + ',';//Commission 
                        exportData += 0 + ',';//Discount
                        exportData += StringUtility.quoteReplaceStr(' ') + ',';//Due Date
                        exportData += StringUtility.quoteReplaceStr(cn.Account_Number__c) + ',';//Remark1
                        exportData += StringUtility.quoteReplaceStr(' ') + ',';//Approved By
                        exportData += StringUtility.quoteReplaceStr(cniRecord.Invoice__r.ARMS_Invoice_ID__c) + ',';//Reference Doc No (for CN)
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
                }
            }
        }  
        //END UD-3912 5 April 2016 Kevin Evasco - Credit Note Number check      
        
        try {   
            Map<String,String> resultMap = RefundCallOut.createMultipleZObjectForRefund(refundListMap, 'Refund'); 
            if(resultMap.get('Status') == 'Success') {
                System.debug('Successful Refund Creation in Zuora');
            }
            else {
                String errorMessage = 'Job Aborted. Unsuccessful Refund Creation in Zuora';
                throw new GenericException(errorMessage);
            }
        } catch(Exception ex) {
            if(!Test.isRunningTest()){
                BT_AU_BATCHRUNREQUEST_UpdateInfo.abortJob(BC.getJobId(), interfaceId, BT_AB_ARM067DX_ImportCirculationOrders.class.getName(), ex, false);
            }
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
            System.debug('BT_AB_ARM067DX_ImportCirculationOrders insert operation failed.');
            System.debug('Exception Message: ' + ex.getMessage());
            System.debug('Exception Stack Trace: ' + ex.getStackTraceString());
            BT_AU_BATCHRUNREQUEST_UpdateInfo.abortJob(BC.getJobId(), interfaceId, BT_AB_ARM067DX_ImportCirculationOrders.class.getName(), ex, true);
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        BT_AU_BATCHRUNREQUEST_UpdateInfo.delegateBatchCall(interfaceId,true);
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);
    }
}