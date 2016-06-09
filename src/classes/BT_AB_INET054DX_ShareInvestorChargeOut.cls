/*
 * Class Name: BT_AB_INET054DX_ShareInvestorChargeOut
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - INET054DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for INET054DX batch job. Used together with BT_AS_INET054DX_ShareInvestorChargeOut Schedulable
 * 
 * History: 2014/08/26 Kevin Evasco Created Skeletal Apex Batchable
 *          2014/10/07 Updated code implementation
 *          2014/12/16 Wenjun D-1169
 *          2014/12/18 Michael Francisco D-1324 Added logic to retrieve Product Code from ZProduct object using Product ID  
 *          2015/01/20 Michael Francisco D-1169 Added logic to retrieve Transaction Type, Subscription A/C Number, Recipient A/C Number and PubTag values from Salesforce
 *          2015/01/21 Michael Francisco D-1169 Removed commented debugger code and revised comment layout
 *          2015/02/16 Michael Francisco Modified to address NovaSuite Code Review Findings - 100k limit / NULL values in WHERE clause
 *          2015/02/18 Michael Francisco D-2241 Modified to address defect items 
 *          2015/04/29 Renino Niefes D-2840 Handle quotes and sort records by Account Number
 *          2015/05/26 Renino Niefes Code Review: Remove the pub tag, removed the comma in Name field, modified the query (c/o Mike F.)
 */

global class BT_AB_INET054DX_ShareInvestorChargeOut implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    global final String interfaceId = 'INET054DX';      
    global final String siopCode = 'SIOP';
        
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList;  
        
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_ToMonthEnd(batchRunDate);
        DateTime cutOffStart = DateUtility.convertDateFromYYYY_MM_DD_ToMonthStart(batchRunDate);
        
    
        String  query =  'SELECT Zuora__Account__r.Name , ';                //Customer name 
                query += '   Zuora__Zuora_Id__c, ';                         //Zuora Invoice ID
                query += '   Zuora__Account__r.Account_Auto_Number__c, ';   //CRSM Account Auto Number
                query += '   Zuora__Account__r.Id, ';                       //CRSM Account ID
                query += '   Zuora__BillingAccount__r.Id, ';                 //Zuora Billing Account 
                query += '   Zuora__BillingAccount__r.Legacy_Billing_Account_Id__c, ';  // Legacy_Billing_Account_Id__c
                query += '   Zuora__Account__r.Account_Legacy_Id__c ';                  // Account_Legacy_Id__c
                query += ' FROM Zuora__ZInvoice__c ';
                query += ' WHERE CreatedDate >= :cutOffStart AND CreatedDate <= :cutOffEnd  ';
                query += ' ORDER BY Zuora__Account__r.Account_Auto_Number__c,Zuora__Zuora_Id__c '; 
        
        return Database.getQueryLocator(query);
    }
    

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {   
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        Set<ID>accountIDSet = new Set<ID>();
        for (sObject so : scope) {
            Zuora__ZInvoice__c record = (Zuora__ZInvoice__c)so;
            if (record.Zuora__Account__r.Id!=null) {
                accountIDSet.add(record.Zuora__Account__r.Id);
            }
        }
        
        List<zqu__ProductRatePlanCharge__c> productRPCList = [
            SELECT Product_Code__c FROM zqu__ProductRatePlanCharge__c WHERE PublicationCode__c = :siopCode AND Product_Code__c <> ''
        ];
        

        Set<String> productCodeSet = new Set<String>();
        for (zqu__ProductRatePlanCharge__c record : productRPCList) {
            String zProductCode = record.Product_Code__c;
            if (StringUtility.validate(zProductCode)=='0') { 
                productCodeSet.add(zProductCode);
            }

        }  

        
        List<Zuora__SubscriptionProductCharge__c> chargeNumberList = [
                SELECT ID, Zuora__ChargeNumber__c 
                FROM Zuora__SubscriptionProductCharge__c                
                WHERE Zuora__Account__c IN :accountIDSet AND PublicationCode__c = :siopCode
            ];
            
        Set<String> chargeNumberSet = new Set<String>();
        for (Zuora__SubscriptionProductCharge__c record : chargeNumberList) {
            if (StringUtility.validate(record.Zuora__ChargeNumber__c)=='0') {
                chargeNumberSet.add(record.Zuora__ChargeNumber__c);
            }
        }
        

        Set<ID> ZuoraBillingAcctIDSet = new Set<ID>();
        Set<String> invNoSet = new Set<String>();
        Map<String,Zuora__ZInvoice__c> invoiceMap = new Map<String, Zuora__ZInvoice__c>();
        Set<ID> accountIDList = new Set<ID>();
        for (sObject record : scope)
        {
            Zuora__ZInvoice__c invRecord = (Zuora__ZInvoice__c)record;
            
            if (invRecord.Zuora__Zuora_Id__c != null) { 
                invNoSet.add(invRecord.Zuora__Zuora_Id__c);
                invoiceMap.put(invRecord.Zuora__Zuora_Id__c, invRecord);
            }
            
            if (invRecord.Zuora__Account__r.Id != null) { 
                accountIDList.add(invRecord.Zuora__Account__r.Id);
            }

            if (invRecord.Zuora__BillingAccount__r.Id != null) { 
                ZuoraBillingAcctIDSet.add(invRecord.Zuora__BillingAccount__r.Id);
            }
            
        }



        List<Contact> billingContactList = new List<Contact>([
            SELECT ID, Billing_Account_Name_2__c, Company_Name__c,Recipient_Number__c FROM Contact WHERE Billing_Indicator__c = true
            AND AccountId IN :accountIDList
        ]);



        Map<ID, Contact> billingContactMap = new Map<ID, Contact>();
        for (ID record: accountIDList)
        {
            for (Contact record2 : billingContactList)
            {
                billingContactMap.put(record, record2);
            }
        }
        
        List<Zuora__CustomerAccount__c> zuoraBillingList = [
            SELECT Goodwill_Amount__c,
                IsDeleted,
                Other_PaymentMethod__c,
                Payment_Mode__c,
                Status__c,
                Zuora__DefaultPaymentMethod__c,
                Zuora__Parent__c,
                Zuora__Status__c 
            FROM Zuora__CustomerAccount__c 
            WHERE IsDeleted = false 
            AND Zuora__Status__c = 'Active'
            AND Id IN :ZuoraBillingAcctIDSet
        ];
        
        Map<ID, Zuora__CustomerAccount__c> zuoraBillingMap = new Map<ID, Zuora__CustomerAccount__c>();
        for (Zuora__CustomerAccount__c zbill_acct: zuoraBillingList)
        {
            zuoraBillingMap.put(zbill_acct.Id, zbill_acct);
        }       



        List<Zuora__Subscription__c> subscriptionList = ([
        SELECT ID,Name,Zuora__Account__r.Id, Pub_Tag__c FROM Zuora__Subscription__c
        WHERE Product_Code__c IN :productCodeSet
        AND Zuora__Account__c IN :accountIDList
        ]);

        
        Map<ID, Zuora__Subscription__c> acctSubsMap = new Map<ID, Zuora__Subscription__c>();
        for (Zuora__Subscription__c recordx : subscriptionList)
        {
            acctSubsMap.put(recordx.Zuora__Account__r.Id, recordx); 
        }
        

        List<Invoice_Line_Item__c> invLinesList = [
                SELECT Invoice_ID__c, 
                    Quantity__c, 
                    Tax_Amount__c, 
                    Unit_Price__c,
                    Charge_Amount__c,
                    Product_ID__c
                FROM Invoice_Line_Item__c
                WHERE Invoice_ID__c IN :invNoSet                
                AND Charge_Number__c IN :chargeNumberSet
        ];
        
        Map<ID, String> zTransactionTypeMap = new Map<ID, String>();
        for (Invoice_Line_Item__c record : invLinesList)
        {
            if (invoiceMap.get(record.Invoice_ID__c)!=null) {           
                Zuora__ZInvoice__c invRecord = invoiceMap.get(record.Invoice_ID__c);
                ID zbill_ID = invRecord.Zuora__BillingAccount__r.ID;
                if (zuoraBillingMap.get(zbill_ID)!=null)  {
                    Zuora__CustomerAccount__c zbill_acct = zuoraBillingMap.get(zbill_ID);             
                    String default_mode = zbill_acct.Zuora__DefaultPaymentMethod__c;
                    String payment_mode = zbill_acct.Payment_Mode__c;
                    String payment_other = zbill_acct.Other_PaymentMethod__c;
                    String goodwill = zbill_acct.Goodwill_Amount__c;
                    
                    String pmt_mode_final = '';
                    String zTransType = '';
                    
                    // RULE: Zuora__DefaultPaymentMethod__c > Payment_Mode__c > Other_PaymentMethod__c                    
                    // NULL checks for payment mode  
                    if (default_mode != null && default_mode.length() > 0) {
                        pmt_mode_final = default_mode;                          
                    } else {
                        if (payment_mode != null && payment_mode.length() > 0) {
                            pmt_mode_final = payment_mode;
                        } else {
                            if (payment_other != null && payment_other.length() > 0) {
                                pmt_mode_final = payment_other;                         
                            } else {
                                pmt_mode_final = 'Other';
                            }
                        }
                    }
                    
                    // Derive Transaction Type 
                    if (pmt_mode_final != null && pmt_mode_final.length() > 0) {
                        
                        if (goodwill != null) {
                            // Goodwill Transaction Type ...
                            zTransType = 'GOODWILL';
                        } else {
                            if (payment_other != null) {
                                if (payment_other.equalsIgnoreCase('Invoice')) {
                                    zTransType = 'RCRINV';              
                                } else {
                                    zTransType = 'RCRPPL';
                                }
                            } else {
                                if (pmt_mode_final.equalsIgnoreCase('CreditCard')) {
                                    zTransType = 'RCRCRD';
                                } else {
                                    zTransType = 'RCRINV';
                                }                                                       
                            }
                        }
                    }
                    
                    if (zTransType == null) {
                        zTransType = 'NONE';
                    } else {
                        if (zTransType.length() == 0) {
                            zTransType = 'NONE';
                        }
                    }
                    
                    zTransactionTypeMap.put(zbill_ID, zTransType);
                }
            }
        }

        
        for (Invoice_Line_Item__c record : invLinesList)
        {
            //Prepare the master data pool
            String exportData = '';
            if (invoiceMap.get(record.Invoice_ID__c)!=null) {
                Zuora__ZInvoice__c invRecord = invoiceMap.get(record.Invoice_ID__c);
                ID zAcctID = invRecord.Zuora__Account__r.ID;
                ID zBillAcctID = invRecord.Zuora__BillingAccount__r.ID;
                if (billingContactMap.get(zAcctID) !=null && acctSubsMap.get(zAcctID)!=null && zuoraBillingMap.get(zBillAcctID)!=null) {
                    Contact contact = billingContactMap.get(zAcctID);
                    Zuora__Subscription__c subscription = acctSubsMap.get(zAcctID);
                    
                                          
                    String transaction_type = zTransactionTypeMap.get(zBillAcctID);                    
                    Decimal recipient_num = contact.Recipient_Number__c;
                    String subscrpt_pub_tag = '';  
                    String subscrpt_name = subscription.Name;
                    String subscrpt_acct = invRecord.Zuora__Account__r.Account_Auto_Number__c;                    
                    String zLegacyRecipientNumber = invRecord.Zuora__BillingAccount__r.Legacy_Billing_Account_Id__c;            // Legacy_Billing_Account_Id__c
                    String zLegacySubscriberNumber = invRecord.Zuora__Account__r.Account_Legacy_Id__c;                          // Legacy_Account_Id__c
                    String zAccountName = invRecord.Zuora__Account__r.Name;
                    String zRecordId = record.Invoice_ID__c;


                    exportData = StringUtility.quoteReplaceStr(transaction_type) +',';                                          //Transaction type 
                    exportData += StringUtility.quoteReplaceStr(zAccountName.remove(','))  + ',';                               //Customer Name 
                    exportData += StringUtility.quoteReplaceStr(zLegacySubscriberNumber)  + ',';                                //Subscriber A/C Number 
                    exportData += StringUtility.quoteReplaceStr(zLegacyRecipientNumber)  + ',';                                 //Recipient A/C Number 
                    exportData += StringUtility.quoteReplaceStr(siopCode)  + ',';                                               //Publication Code (Use SKU to link)
                    exportData += StringUtility.quoteReplaceStr(subscrpt_pub_tag)  + ',';                                       //PubTag 
                    exportData += record.Quantity__c  + ',';                                                                    //Copy (Quantity)
                    exportData += record.Tax_Amount__c  + ',';                                                                  //GST Amount (Tax Amount)
                    exportData += record.Unit_Price__c  + ',';                                                                  //Subscription Amount  (Unit Price)
                    exportData += '0,';                                                                                         //Postage / Delivery Amount (0)  hard coded
                    exportData += record.Charge_Amount__c  + ',';                                                               //Total Amount (Charge Amount)
                    
                    exportData += StringUtility.quoteReplaceStr(subscrpt_acct)   + ',';                                         //CRSM Account Auto Number
                    exportData += recipient_num  + ',';                                                                         //CRSM Contact Recipient Number
                    exportData += StringUtility.quoteReplaceStr(subscrpt_name)  + ',';                                          //CRSM Subscription Name

                    
                    datapoolList = BT_CO_INT_Utilities.exportDataItem(interfaceId, 'Detail', zRecordId, exportData, DateTime.now(), datapoolList);
                
                } 
            }
        
        }

        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_INET054DX_ShareInvestorChargeOut insert operation failed.');
        }
    }
    

    global void finish(Database.BatchableContext BC) {
        //Send callout
        BT_CO_INT_Utilities.sendCallOutMessage(interfaceId);

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);
    }
}