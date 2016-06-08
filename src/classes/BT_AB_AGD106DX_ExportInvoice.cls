/*
 * Class Name: BT_AB_AGD106DX_ExportInvoice
 * @author: Kevin H. Evasco
 * Date: 30 March 2016
 * Project/Requirement: SPH Integration - AGD106DX
 */


global class BT_AB_AGD106DX_ExportInvoice implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful
{ 
    global final String interfaceId = 'AGD106DX';  
    
    Decimal GSTRate = 1000.0;       
    
    global class AGD106DX_LineItemAmountWrapper
    {
        Decimal unitPrice = 0;
        Decimal taxAmount = 0;
        Decimal merchandiseAmount = 0;
        Integer quantity = 1;
        String lineDescription;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId); 
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
        
        Date lastBatchRunDate;
        List<BT_CO_Batch_Run_Request__c> brrList = [SELECT Id, Batch_Run_Date__c, CreatedDate, End_Time__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = :interfaceId AND End_Time__c != NULL ORDER BY CreatedDate DESC LIMIT 1];
        if(brrList.size() > 0) {
            lastBatchRunDate = brrList[0].Batch_Run_Date__c;
        } else {
            lastBatchRunDate = myDate;
        }
        
        if(lastBatchRunDate.daysBetween(myDate) > 1) {
            lastBatchRunDate = lastBatchRunDate.addDays(1);
        } else {
            lastBatchRunDate = myDate;
        }
                 
        List<Other__c> gstSettingList = [SELECT Id, Value__c FROM Other__c WHERE Name = 'GST'];
        if(gstSettingList.size() > 0) {
            Other__c gstSetting = gstSettingList.get(0);
            try{ GSTRate = Decimal.valueOf(gstSetting.Value__c); } catch(Exception e) {}
        }       
        
        return Database.getQueryLocator(
            [SELECT 
            ARMS_Invoice_ID__c,
            ID,
            Name,
            Zuora__Account__r.Vendor_Code__c,
            Zuora__BillingAccount__r.AGD_Unit__c,
            Zuora__BillingAccount__r.Billing_Contact__r.Company_Name__c,
            Zuora__BillingAccount__r.Credit_Term__c,
            Zuora__Description__c,
            Zuora__External_Id__c,
            Zuora__InvoiceDate__c,
            Zuora__TaxAmount__c,
            Zuora__TotalAmount__c,Zuora__AmountWithoutTax__c

            FROM Zuora__ZInvoice__c       

            WHERE

            ARMS_Interface_Timestamp__c = null AND 
            ARMS_invoice_id__c != null AND 
            Zuora__TotalAmount__c > 0 AND
            Zuora__BillingAccount__r.AGD_Unit__c != null AND
            (Zuora__BillingAccount__r.Zuora__Account__r.RecordTypeId != :ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRCORP) OR
            Zuora__BillingAccount__r.Billing_Type__c != :GlobalVariableClass.BILLING_TYPE_FULL_PRE)

            ORDER BY ARMS_Invoice_ID__c ASC
            ]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {     
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
           
        List<Id> invoiceIdList = new List<Id>();
        List<String> invoiceNoList = new List<String>();
        for(sObject record : scope)
        {   
            Zuora__ZInvoice__c invRecord = (Zuora__ZInvoice__c)record;
            //added by JC Aduan for debugging purposes 
            System.debug('@#$ Zuora__External_Id__c: ' + invRecord.Zuora__External_Id__c);
            if (invRecord.Id != null) {
                invoiceIdList.add(invRecord.Id);
            }
            if (invRecord.Zuora__External_Id__c != null) {
                invoiceNoList.add(invRecord.Zuora__External_Id__c);
            }
        }
        
        List<Invoice_Line_Item__c> invLinesList = [
            SELECT  ID,
                Invoice_ID__c,
                Unit_Price__c,  
                Quantity__c,
                Tax_Amount__c,
                Charge_Amount__c,
                Charge_Description__c,
                Charge_Name__c,
                Product_Name__c,
                Subscription__c,
                Subscription__r.Zuora__SubscriptionStartDate__c,
                Subscription__r.Zuora__SubscriptionEndDate__c,
                Subscription__r.Recipient_Contact__r.Salutation,
                Subscription__r.Recipient_Contact__r.Name,
                Subscription__r.Recipient_Contact__r.Recipient_Number__c,
                Subscription__r.Number_of_Copies__c
            FROM Invoice_Line_Item__c
            WHERE Invoice_ID__c IN :invoiceNoList
            AND Charge_Amount__c != 0
        ];

        //added by JC Aduan for debugging purposes 
        System.debug('@#$ invLinesList: ' + invLinesList);              
        
        Map<String, Set<Id>> invoice_subscriptionIdSet_map = new Map<String, Set<Id>>();
        Map<String, AGD106DX_LineItemAmountWrapper> invoiceSubscriptionId_LineItemWrapper_map = new Map<String, AGD106DX_LineItemAmountWrapper>();
        
        for (Invoice_Line_Item__c record : invLinesList)
        {           
            if(invoice_subscriptionIdSet_map.get(record.Invoice_ID__c)==null)
                invoice_subscriptionIdSet_map.put(record.Invoice_ID__c,new Set<Id>());
            invoice_subscriptionIdSet_map.get(record.Invoice_ID__c).add(record.Subscription__c);
            
            String invoiceSubscriptionKey = constructInvoiceSubscriptionKey(record.Invoice_ID__c, record.Subscription__c);
            
            if(invoiceSubscriptionId_LineItemWrapper_map.get(invoiceSubscriptionKey)==null) {
                AGD106DX_LineItemAmountWrapper lineItemWrapperRecord = new AGD106DX_LineItemAmountWrapper();
                
                String lineDescription = '';
                if(record.Product_Name__c == 'Delivery Charge') {                   
                    lineDescription += 'SUBSCRIPTION DELIVERY FEE';         
                    lineItemWrapperRecord.quantity = 1; 
                } else if(record.Product_Name__c == 'Postage Charge') {                 
                    lineDescription += 'SUBSCRIPTION POSTAGE FEE';          
                    lineItemWrapperRecord.quantity = 1;
                } else {                
                    if(record.Subscription__r.Number_of_Copies__c != null)
                        lineItemWrapperRecord.quantity = Integer.valueOf(record.Subscription__r.Number_of_Copies__c); 
                    lineDescription += record.Product_Name__c;
                    
                    if(record.Subscription__r.Zuora__SubscriptionStartDate__c != null)
                        lineDescription += ' SUBSCRIPTION FROM ' + DateUtility.convertDateToString(record.Subscription__r.Zuora__SubscriptionStartDate__c);
                    else
                        lineDescription += ' SUBSCRIPTION FROM - ';
                    
                    if(record.Subscription__r.Zuora__SubscriptionEndDate__c != null)
                        lineDescription += ' TO ' + DateUtility.convertDateToString(record.Subscription__r.Zuora__SubscriptionEndDate__c);
                    else
                        lineDescription += ' TO - ';
                } 
                lineDescription += ' FOR';
                if(record.Subscription__r.Recipient_Contact__r.Salutation != null)
                    lineDescription += ' ' +record.Subscription__r.Recipient_Contact__r.Salutation;
                lineDescription += ' ' + record.Subscription__r.Recipient_Contact__r.Name;
                lineDescription += ' ' + record.Subscription__r.Recipient_Contact__r.Recipient_Number__c;
                
                lineItemWrapperRecord.lineDescription = lineDescription;
                
                invoiceSubscriptionId_LineItemWrapper_map.put(invoiceSubscriptionKey, lineItemWrapperRecord);                            
            }
            
            
            AGD106DX_LineItemAmountWrapper lineItemWrapperRecord = invoiceSubscriptionId_LineItemWrapper_map.get(invoiceSubscriptionKey);
            
            if(record.Product_Name__c == 'Delivery Charge' || record.Product_Name__c == 'Postage Charge') {                 
                lineItemWrapperRecord.unitPrice += record.Charge_Amount__c;
                lineItemWrapperRecord.taxAmount += record.Tax_Amount__c;                
            
            } else {    
                lineItemWrapperRecord.taxAmount += record.Tax_Amount__c;                
            }
            
            lineItemWrapperRecord.merchandiseAmount += record.Tax_Amount__c  + record.Charge_Amount__c;       
            lineItemWrapperRecord.unitPrice = (lineItemWrapperRecord.merchandiseAmount - lineItemWrapperRecord.taxAmount)  / lineItemWrapperRecord.quantity; //START/END 06 October 2015 Kevin Evasco UD-1371 - Unit Price = Subscription Total Amount / Quantity                           
            invoiceSubscriptionId_LineItemWrapper_map.put(invoiceSubscriptionKey, lineItemWrapperRecord);   
        }
        
        //Get the default values from Custom Settings
        String vVendorID = null;
        String vCurrencyCode = null;
        String vFreightAmount = null;
        String vDescription = null;
        
        vVendorID = StringUtility.getCustomSetting('AGD106DX Vendor Id');
        vCurrencyCode = StringUtility.getCustomSetting('AGD106DX Currency Code');
        vFreightAmount = StringUtility.getCustomSetting('AGD106DX Freight Amount');
        vDescription = StringUtility.getCustomSetting('AGD106DX Description');
        
        //loop through Invoices and prepare the datapool
        for(sObject record : scope)
        {   
            Zuora__ZInvoice__c invRecord = (Zuora__ZInvoice__c)record;
            
            if(GSTRate == 1000.0){
                Decimal total_amount = invRecord.Zuora__AmountWithoutTax__c;
                Decimal gst_amount = invRecord.Zuora__TaxAmount__c;         
                if (total_amount > 0 && total_amount >= gst_amount) {
                    Decimal tmp_rate = 100 * (gst_amount / total_amount);
                    GSTRate = tmp_rate.setScale(2, RoundingMode.CEILING);
                } 
            }
            
            //Prepare the master data pool
            String exportData = '';
            exportData += invRecord.Zuora__BillingAccount__r.AGD_Unit__c + ',';//Business Unit 
            
            if(invRecord.ARMS_Invoice_ID__c != null) {              
                exportData += invRecord.ARMS_Invoice_ID__c  + ',';//Invoice Number 
            } else {
                exportData += invRecord.Name  + ',';//Invoice Number 
            }
            exportData += invRecord.Zuora__InvoiceDate__c + ',';//Invoice Date 
            exportData += ','; //PO Number 
            exportData += ','; //PO Date 
            exportData += ','; //Delivery Order Number 
            exportData += ','; //Relative Invoice Number 
            exportData += StringUtility.quoteReplaceStr(vVendorID) + ',';//Vendor ID 
            exportData += StringUtility.quoteReplaceStr(vCurrencyCode) + ','; //Currency Code 
            
            exportData += vFreightAmount + ','; //Freight Amount TBD
            
            exportData += invRecord.Zuora__TaxAmount__c.setScale(2) + ',';//GST Amount 
            exportData += invRecord.Zuora__TotalAmount__c.setScale(2)+ ',';            
            exportData += StringUtility.quoteReplaceStr(invRecord.Zuora__BillingAccount__r.Billing_Contact__r.Company_Name__c) + ',';
            
            exportData += StringUtility.quoteReplaceStr(vDescription) + ',';//Description
            if (invRecord.Zuora__BillingAccount__r.Credit_Term__c!=null) {
                Integer vTerm = Integer.valueOf(invRecord.Zuora__BillingAccount__r.Credit_Term__c);
                if(vTerm == 0)
                    exportData += '00,'; //Credit Term (expected value is 30D for GOVT)
                else
                    exportData += vTerm + 'D,'; //Credit Term (expected value is 30D for GOVT)
            }else{
                exportData += '00,';
            }
            
            exportData += GSTRate + ',';//GST Rate 
            
            if (invoice_subscriptionIdSet_map.get(invRecord.Zuora__External_Id__c)!=null){              
                exportData += invoice_subscriptionIdSet_map.get(invRecord.Zuora__External_Id__c).size();//GST Rate 
            } else {
                exportData += '0';//GST Rate 
            }
            
            // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.Name = interfaceId;
            datapoolRecord.job_id__c = '1';
            datapoolRecord.group_id__c = 'Master';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;
            datapoolList.add(datapoolRecord);

            //Prepare the Details data pool
            if (invoice_subscriptionIdSet_map.get(invRecord.Zuora__External_Id__c)!=null) 
            {
                Integer lineCtr = 0;
                for (Id subscriptionIdElem : invoice_subscriptionIdSet_map.get(invRecord.Zuora__External_Id__c))
                {                   
                    String invoiceSubscriptionKey = constructInvoiceSubscriptionKey(invRecord.Zuora__External_Id__c, subscriptionIdElem);                   
                    AGD106DX_LineItemAmountWrapper lineItemWrapperRecord = invoiceSubscriptionId_LineItemWrapper_map.get(invoiceSubscriptionKey);
                    lineCtr++;
                    String exportData2 = '';
                    exportData2 += lineCtr + ','; //Invoice Line Number                 
                    exportData2 += lineItemWrapperRecord.unitPrice.setScale(5)  + ','; //Unit Price 
                    exportData2 += lineItemWrapperRecord.quantity + ','; //Quantity 
                    exportData2 += lineItemWrapperRecord.taxAmount.setScale(2) + ','; //GST Amount 
                    exportData2 += lineItemWrapperRecord.merchandiseAmount.setScale(2) + ','; //Merchandise Amount 
                    exportData2 += StringUtility.quoteReplaceStr(lineItemWrapperRecord.lineDescription); //Line Description 
                    
                    BA_INT_DATA_POOL__c datapoolRecord2 = new BA_INT_DATA_POOL__c();
                    datapoolRecord2.Name = interfaceId;
                    datapoolRecord2.job_id__c = '1';
                    datapoolRecord2.group_id__c = 'Detail';
                    datapoolRecord2.run_for_date__c = Date.today();      
                    datapoolRecord2.insert_time__c = DateTime.now(); 
                    datapoolRecord2.export_data__c = exportData2;           
                    datapoolList.add(datapoolRecord2);
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
            System.debug('BT_AB_AGD106DX_AGDEInvoince insert operation failed.');
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        BT_AB_AGD106DX_ExportDailyInvoice batchInstance = new BT_AB_AGD106DX_ExportDailyInvoice();
        Database.executeBatch(batchInstance);
    }
    
    global static String constructInvoiceSubscriptionKey(String invoiceId, String subscriptionId) {
        return invoiceId + '_' + subscriptionId;
    }
}