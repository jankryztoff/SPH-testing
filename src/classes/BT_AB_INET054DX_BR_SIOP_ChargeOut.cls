/*
 * Class Name: BT_AB_INET054DX_BR_SIOP_ChargeOut
 *
 * @Author: Michael Francisco
 * @CreatedDate: 2015-06-09
 * @Project/Requirement: SPH Integration - INET054DX Interface
 *
 * @Description 
 *      This class populates BA_INT_DATA_POOL__c for INET054DX batch job and was created to replace 
 *      the existing BT_AB_INET054DX_ShareInvestorChargeOut apex class. Will reference the BillingReports__c 
 *      Salesforce custom object to obtain the pertinent data and as such can only be run AFTER the monthly 
 *      BILL-RUN batch process. Similar to the other integration batch jobs (i.e SAP072DX, PPS056DX, etc.)
 * 
 * @History: 
 *      2015-06-09 Michael Francisco - Created Apex Class
 *
 */

global class BT_AB_INET054DX_BR_SIOP_ChargeOut implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful
{
    global final String Z_INTERFACE_ID = 'INET054DX';      
    global final String Z_SIOP_CODE = 'SIOP';
    global Boolean isHeaderUpdated = false;
      
    global Database.QueryLocator start(Database.BatchableContext BC)
    {

        String zBatchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID);  
        String zAccountingPeriod = StringUtility.getAccountingPeriod(zBatchRunDate);
                 
        String query = '';
        query += 'SELECT ';
        query += '  Id, ';
        query += '  Accounting_Period__c, ';
        query += '  Transaction_Type__c, ';
        query += '  Subscription_ID__c, ';
        query += '  Publication__c, ';
        query += '  Copies__c, ';
        query += '  GST_Amount__c, ';
        query += '  Zero_Rated_GST__c, '; 
        query += '  Standard_Rated_GST__c, ';
        query += '  Subscription_AMT_Before_GST__c, ';
        query += '  Subscription_AMT_After_GST__c, ';
        query += '  Subscriber_Account__c, ';
        query += '  Recipient_Contact_ID__c, ';
        query += '  Publication_Type__c, ';
        query += '  Billing_Account__c, ';
        query += '  IsDeleted, ';
        query += '  LastModifiedDate ';
        query += 'FROM '; 
        query += '  Billing_Report__c ';
        query += 'WHERE ';
        query += '  IsDeleted = FALSE ';
        query += '  AND Publication__c = :Z_SIOP_CODE ';
        query += '  AND Accounting_Period__c = :zAccountingPeriod ';
        query += '  AND Transaction_Type__c like \'%Charge-Out%\' ';
        query += 'ORDER BY Subscription_ID__c ';

        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {   
        Set<String> zSubscriptionNameSet = new Set<String>();
        for (Object record : scope) {
            Billing_Report__c brRecord = (Billing_Report__c) record;
            if (brRecord != null) {
                String zSubscriptionName = brRecord.Subscription_ID__c;
                if (String.isNotBlank(zSubscriptionName)) {
                    zSubscriptionNameSet.add(zSubscriptionName);
                }
            }
        }
        List<Zuora__Subscription__c> zSubscriptionList = new List<Zuora__Subscription__c>();
        if (zSubscriptionNameSet.size() > 0) {
        
            //START 14 January 2016 D-4314  Kevin Evasco - Added Recipient_Contact__r.SS_Subscriber_Account_Number__c
            //START 08 December 2015 D-4023 Kevin Evasco - New query fields: SS_Subscriber_Account_Number__c, SS_Recipient_Account_Number__c
            zSubscriptionList = [
                 SELECT 
                      Name,
                      Zuora__Account__r.Account_Auto_Number__c,
                      Recipient_Contact__r.Name, 
                      Recipient_Contact__r.Recipient_Number__c, 
                      Recipient_Contact__r.SS_Recipient_Account_Number__c,
                      Recipient_Contact__r.SS_Subscriber_Account_Number__c,
                      Contact__r.SS_Subscriber_Account_Number__c,
                      Zuora__Status__c
                 FROM 
                      Zuora__Subscription__c 
                 WHERE 
                      Name IN :zSubscriptionNameSet
            ];          
            //END 08 December 2015 D-4023 Kevin Evasco - New query fields: SS_Subscriber_Account_Number__c, SS_Recipient_Account_Number__c
            //END 14 January 2016 D-4314  Kevin Evasco - Added Recipient_Contact__r.SS_Subscriber_Account_Number__c
        }
        Map<String, Zuora__Subscription__c> zSubscriptionMap = new Map<String, Zuora__Subscription__c>();
        if (zSubscriptionList.size() > 0) {
            for (Zuora__Subscription__c zRecord : zSubscriptionList) {
                String zSubscriptionName = zRecord.Name;
                if (zSubscriptionName != null) {
                    zSubscriptionMap.put(zSubscriptionName, zRecord);
                }
            }
        }
        
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();    
        Set<String> exportDataSet = new Set<String>();
        String tmpData = 'TXN_TYPE,CUSTOMER_NAME,SUBS_NO,REC_NO,PUB,PUB_TAG,COPIES,GST_AMT,SUB_AMT,DEL_CHRG,TOTAL_AMT,CRSM_ACC_ID,CRSM_CONT_ID,CRSM_SUBN_ID';
        if(!isHeaderUpdated){
            datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', 'XXXXYYYYZZZZ', tmpData, DateTime.now(), datapoolList);
            exportDataSet.add(tmpData);
            isHeaderUpdated = true;
        }
        
        for (Object record : scope) {
            Billing_Report__c brRecord = (Billing_Report__c) record;
            if (brRecord != null) {
                ID zRecordID = brRecord.ID;
                String zSubscriptionName = brRecord.Subscription_ID__c;
                DateTime dLastModifiedDate = brRecord.LastModifiedDate;
                
                if (String.isNotBlank(zSubscriptionName) && zSubscriptionMap.containsKey(zSubscriptionName)) {
                    Zuora__Subscription__c zSubscriptionRecord = (Zuora__Subscription__c) zSubscriptionMap.get(zSubscriptionName);
                    
                    if (zSubscriptionRecord != null) {
                        String zCustomerName = zSubscriptionRecord.Recipient_Contact__r.Name;
                        String zSubscriberACNumber = zSubscriptionRecord.Contact__r.SS_Subscriber_Account_Number__c; //START/END 08 December 2015 D-4023 Kevin Evasco - Assign Contact SS_Subscriber_Number__c for the Subscriber A/C Number
                        Decimal iCRSMRecipientNumber = zSubscriptionRecord.Recipient_Contact__r.Recipient_Number__c;
                        String zCRSMRecipientNumber = (iCRSMRecipientNumber != null) ? iCRSMRecipientNumber.toPlainString() : String.valueOf(iCRSMRecipientNumber);

                        String zPubTag = '';
                        String zTransactionType = brRecord.Transaction_Type__c;
                        
                        //START 14 January 2016 D-4314  Kevin Evasco - Use the SS_Subscriber_Account_Number__c if SS_Recipient_Account_Number__c is null.
                        String zRecipientACNumber;                      
                        
                        if(zSubscriptionRecord.Recipient_Contact__r.SS_Recipient_Account_Number__c != null)
                            zRecipientACNumber = zSubscriptionRecord.Recipient_Contact__r.SS_Recipient_Account_Number__c; //START/END 08 December 2015 D-4023 Kevin Evasco - Assign Contact SS_Recipient_Account_Number__c for the Recipient A/C Number
                        else    
                            zRecipientACNumber = zSubscriptionRecord.Recipient_Contact__r.SS_Subscriber_Account_Number__c; 
                        //END 14 January 2016 D-4314  Kevin Evasco - Use the SS_Subscriber_Account_Number__c if SS_Recipient_Account_Number__c is null.
                            
                        String zPublicationCode = brRecord.Publication__c;
                        String zCRSMAccountNumber = brRecord.Subscriber_Account__c;
                                        
                        Decimal dCopies = brRecord.Copies__c;
                        Decimal dGSTAmount = brRecord.GST_Amount__c;
                        Decimal dSubscriptionAmount = brRecord.Subscription_AMT_After_GST__c;
                        Decimal dTotalAmount = brRecord.Subscription_AMT_After_GST__c;

                        String zData = '';
                        zData = StringUtility.quoteReplaceStr(zTransactionType) +',';                       // Transaction Type 
                        zData += (zCustomerName != null ? StringUtility.quoteReplaceStr(zCustomerName.remove(',')) : zCustomerName)  + ',';           // Customer Name 
                        zData += StringUtility.quoteReplaceStr(zSubscriberACNumber)  + ',';                 // Subscriber A/C Number 
                        zData += StringUtility.quoteReplaceStr(zRecipientACNumber)  + ',';                  // Recipient A/C Number 
                        zData += StringUtility.quoteReplaceStr(zPublicationCode)  + ',';                    // Publication Code (Use SKU to link)
                        zData += StringUtility.quoteReplaceStr(zPubTag) + ',';                              // PubTag 
                        zData += -1*dCopies + ',';                                                          // Copy (Quantity)
                        zData += -1*dGSTAmount + ',';                                                       // GST Amount (Tax Amount)
                        zData += -1*dSubscriptionAmount + ',';                                              // Subscription Amount (Unit Price)
                        zData += '0,';                                                                   // ----> HARD CODED <---- Postage / Delivery Amount (0)
                        zData += -1*dTotalAmount  + ',';                                                    // Total Amount (Charge Amount)
                        zData += StringUtility.quoteReplaceStr(zCRSMAccountNumber) + ',';                   // CRSM Account Auto Number
                        zData += zCRSMRecipientNumber  + ',';                                            // CRSM Contact Recipient Number
                        zData += StringUtility.quoteReplaceStr(zSubscriptionName) + ',';                    // CRSM Subscription Name

                        if (String.isNotBlank(zData) && !exportDataSet.contains(zData)) {
                            datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', zRecordID, zData, dLastModifiedDate, datapoolList);              
                            exportDataSet.add(zData);
                        }                                               
                    }
                }
            }
        }
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try {
            insert datapoolList;
        } catch(Exception e) {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_'+Z_INTERFACE_ID+'_ShareInvestorChargeOut insert operation failed.');
        }
    }
   
    global void finish(Database.BatchableContext BC) {
        //Send callout
        BT_CO_INT_Utilities.sendCallOutMessage(Z_INTERFACE_ID);

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(Z_INTERFACE_ID);
    }
}