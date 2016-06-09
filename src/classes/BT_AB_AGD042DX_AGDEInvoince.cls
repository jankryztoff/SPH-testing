/*
 * Class Name: BT_AB_AGD042DX_AGDEInvoince
 * @author: Kevin H. Evasco/*
 * Class Name: BT_AB_AGD042DX_AGDEInvoince
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - AGD042DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for AGD042DX batch job. Used together with BT_AS_AGD042DX_AGDEInvoince Schedulable
 * 
 * History: 2014/08/26 Kevin Evasco Created Skeletal Apex Batchable
 *          2014/10/07 Renino Niefes Added code implementations
 *          2014/11/04 Renino Niefes Added callout codes
 *          2014/12/15 Renino Niefes Changed the lookup field for Invoice Items (for defect #D-1213)
 *          2015/01/23 Michael Francisco Modified to address D-1829
 *          2015/02/16 Michael Francisco Modified to address NovaSuite Code Review Findings - 100k limit / NULL values in WHERE clause
 *          2015/05/05 Renino Niefes D-XXXX Default Values
 *          2015/09/21 Renino Niefes Hotfixed in UAT2: UD-2786 Change the attention-to mapping to Attention_To_Care1__c
 *          2015/11/24 Renino Niefes D-3982 Retrofit and code fix related to D-3914.  ATtention To field must be fetched from Contact, instead of Account.  Baseline came from UAT2 (hotfixed by Kevin last Oct 7, 2015)
 */


global class BT_AB_AGD042DX_AGDEInvoince implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements    
    global final String interfaceId = 'AGD042DX';  
    
    //START 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Group invoices line items per subscription per invoice
    Decimal GSTRate = 1000.0;       
    
    global class AGD042DX_LineItemAmountWrapper
    {
        Decimal unitPrice = 0;
        Decimal taxAmount = 0;
        Decimal merchandiseAmount = 0;
        Integer quantity = 1; //START/END 06 October 2015 Kevin Evasco UD-1371 - Set quantity to 1 for error handling
        String lineDescription;
    }
    //END 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Group invoice line items per subscription per invoice
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList;  

        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId); 
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
        
        //START 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Group invoice line items per subscription per invoice
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
        
        //START D-1829 23/01/2015 Michael Francisco - Added logic to calculate GST Rate and set a value for Freight Amount ...            
        List<Other__c> gstSettingList = [SELECT Id, Value__c FROM Other__c WHERE Name = 'GST'];
        if(gstSettingList.size() > 0) {
            Other__c gstSetting = gstSettingList.get(0);
            try{ GSTRate = Decimal.valueOf(gstSetting.Value__c); } catch(Exception e) {}
        }       
        //END D-1829 23/01/2015 Michael Francisco 
                
        String query = 'SELECT ID,Zuora__BillingAccount__r.AGD_Unit__c, ARMS_Invoice_ID__c, ';
        query += '      Name, '; //Invoice ID
        //Start [15 Dec 2014 Renz Defect #D-1213] Added Zuora__External_Id__c.  This will be used as lookup for Invoice Items
        query += '      Zuora__External_Id__c, ';
        //End [15 Dec 2014 Renz Defect #D-1213]
        query += '      Zuora__InvoiceDate__c, ';
        query += '      Zuora__Account__r.Vendor_Code__c, ';
        query += '      Zuora__TaxAmount__c, ';
        query += '      Zuora__TotalAmount__c,Zuora__AmountWithoutTax__c, ';
        //Start D-3982 2015-11-24 Renz  Company_Name__c is the new attention to name
        //query += '      Zuora__BillingAccount__r.Attention_To_Care1__c, ';  //START/END 2015-09-21 Renz UD-2786  Change the mapping
        query += '      Zuora__BillingAccount__r.Billing_Contact__r.Company_Name__c, ';
        //End D-3982 2015-11-24 Renz
        query += '      Zuora__Description__c, ';
        query += '      Zuora__BillingAccount__r.Credit_Term__c ';
        query += ' FROM Zuora__ZInvoice__c ';       
        //START 06 January 2015 D-4233 Kevin Evasco - use the same filter as ARM067DX_2 but with additional filter of AGD Unit != null
        query += ' WHERE ARMS_Interface_Timestamp__c = null AND ARMS_invoice_id__c != null AND Zuora__TotalAmount__c > 0';
        //query += ' AND Zuora__InvoiceDate__c <= :myDate ';        
        //END 06 January 2015 D-4233 Kevin Evasco - use the same filter as ARM067DX_2 but with additional filter of AGD Unit != null
        query += '      AND Zuora__BillingAccount__r.AGD_Unit__c != null ORDER BY ARMS_Invoice_ID__c ASC';
        
        //END 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Group invoice line items per subscription per invoice
        
        /*  
        BT_DEV_Debugger debugger = new BT_DEV_Debugger();
        debugger.clearDebugLogs(interfaceId);
        debugger.addDebugLogs(interfaceId,'query=' + query);
        debugger.saveDebugLogs();
        */
        
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
        
        //START 2015/05/05 Renino Niefes D-XXXX Default Values
        //Prepare the List of Case IDs for search criteria for Case Vendor Subs and Zuora Subscriptions        
        List<Id> invoiceIdList = new List<Id>(); //For Case/Order objects
        List<String> invoiceNoList = new List<String>(); //For Invoice Line Items object
        for(sObject record : scope)
        {   
            Zuora__ZInvoice__c invRecord = (Zuora__ZInvoice__c)record;
            //START - 16/02/2015 - Michael Francisco - Code Review NovaSuite
            if (invRecord.Id != null) {
                invoiceIdList.add(invRecord.Id);
            }
            if (invRecord.Zuora__External_Id__c != null) {
                //Start [15 Dec 2014 Renz Defect #D-1213] Use Zuora__External_Id__c to fetch invoice line items.
                invoiceNoList.add(invRecord.Zuora__External_Id__c);
                //End [15 Dec 2014 Renz Defect #D-1213]         
            }
            //END - 16/02/2015 - Michael Francisco - Code Review NovaSuite
        }
        
        //START 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Group invoice line items per subscription per invoice
        //Get all Invoice Line Items and save it to a list of Invoice Line Items
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
                Subscription__r.Recipient_Contact__r.Recipient_Number__c, //START/END 06 October 2015 Kevin Evasco UD-1371 - Quantity from Subscription Number of Copies   
                Subscription__r.Number_of_Copies__c //START/END 06 October 2015 Kevin Evasco UD-1371 - Quantity from Subscription Number of Copies                
            FROM Invoice_Line_Item__c
            WHERE Invoice_ID__c IN :invoiceNoList
            AND Charge_Amount__c != 0
        ];              
        
        //Map<String, List<Invoice_Line_Item__c>> invLinesMap = new Map<String, List<Invoice_Line_Item__c>>();
        Map<String, Set<Id>> invoice_subscriptionIdSet_map = new Map<String, Set<Id>>();
        Map<String, AGD042DX_LineItemAmountWrapper> invoiceSubscriptionId_LineItemWrapper_map = new Map<String, AGD042DX_LineItemAmountWrapper>();
        
        for (Invoice_Line_Item__c record : invLinesList)
        {           
            if(invoice_subscriptionIdSet_map.get(record.Invoice_ID__c)==null)
                invoice_subscriptionIdSet_map.put(record.Invoice_ID__c,new Set<Id>());
            invoice_subscriptionIdSet_map.get(record.Invoice_ID__c).add(record.Subscription__c);
            
            String invoiceSubscriptionKey = constructInvoiceSubscriptionKey(record.Invoice_ID__c, record.Subscription__c);
            
            if(invoiceSubscriptionId_LineItemWrapper_map.get(invoiceSubscriptionKey)==null) {
                AGD042DX_LineItemAmountWrapper lineItemWrapperRecord = new AGD042DX_LineItemAmountWrapper();
                //lineItemWrapperRecord.quantity = Integer.valueOf(record.Quantity__c);
                
                String lineDescription = '';
                if(record.Product_Name__c == 'Delivery Charge') {                   
                    lineDescription += 'SUBSCRIPTION DELIVERY FEE';         
                    lineItemWrapperRecord.quantity = 1; 
                } else if(record.Product_Name__c == 'Postage Charge') {                 
                    lineDescription += 'SUBSCRIPTION POSTAGE FEE';          
                    lineItemWrapperRecord.quantity = 1;
                } else {                
                    //START 06 October 2015 Kevin Evasco UD-1371 - Quantity from Subscription Number of Copies
                    if(record.Subscription__r.Number_of_Copies__c != null)
                        lineItemWrapperRecord.quantity = Integer.valueOf(record.Subscription__r.Number_of_Copies__c); 
                    //END 06 October 2015 Kevin Evasco UD-1371 - Quantity from Subscription Number of Copies
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
            
            
            AGD042DX_LineItemAmountWrapper lineItemWrapperRecord = invoiceSubscriptionId_LineItemWrapper_map.get(invoiceSubscriptionKey);
            
            if(record.Product_Name__c == 'Delivery Charge' || record.Product_Name__c == 'Postage Charge') {                 
                lineItemWrapperRecord.unitPrice += record.Charge_Amount__c;
                lineItemWrapperRecord.taxAmount += record.Tax_Amount__c;                
            
            } else {    
                //lineItemWrapperRecord.unitPrice += record.Charge_Amount__c /  record.Quantity__c; //START/END 06 October 2015 Kevin Evasco UD-1371 - Unit Price = Subscription Total Amount / Quantity    
                lineItemWrapperRecord.taxAmount += record.Tax_Amount__c;                
            }
            
            lineItemWrapperRecord.merchandiseAmount += record.Tax_Amount__c  + record.Charge_Amount__c;       
            lineItemWrapperRecord.unitPrice = (lineItemWrapperRecord.merchandiseAmount - lineItemWrapperRecord.taxAmount)  / lineItemWrapperRecord.quantity; //START/END 06 October 2015 Kevin Evasco UD-1371 - Unit Price = Subscription Total Amount / Quantity                           
            invoiceSubscriptionId_LineItemWrapper_map.put(invoiceSubscriptionKey, lineItemWrapperRecord);   
        }
        //END 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Sum up unit price for delivery and postage subscriptions and set quantity to 1 to fix rounding issues
        
        
        //Get the default values from Custom Settings
        String vVendorID = null;
        String vCurrencyCode = null;
        String vFreightAmount = null;
        String vDescription = null;
        
        vVendorID = StringUtility.getCustomSetting('AGD042DX Vendor Id');
        vCurrencyCode = StringUtility.getCustomSetting('AGD042DX Currency Code');
        vFreightAmount = StringUtility.getCustomSetting('AGD042DX Freight Amount');
        vDescription = StringUtility.getCustomSetting('AGD042DX Description');
        
        //loop through Invoices and prepare the datapool
        for(sObject record : scope)
        {   
            Zuora__ZInvoice__c invRecord = (Zuora__ZInvoice__c)record;
            
           
            //START D-1829 23/01/2015 Michael Francisco - Added logic to calculate GST Rate and set a value for Freight Amount ...       
            if(GSTRate == 1000.0){
                Decimal total_amount = invRecord.Zuora__AmountWithoutTax__c;
                Decimal gst_amount = invRecord.Zuora__TaxAmount__c;         
                if (total_amount > 0 && total_amount >= gst_amount) {
                    Decimal tmp_rate = 100 * (gst_amount / total_amount);
                    GSTRate = tmp_rate.setScale(2, RoundingMode.CEILING);
                } 
            }
            //END D-1829 23/01/2015 Michael Francisco 
            
            //Prepare the master data pool
            String exportData = '';
            exportData += invRecord.Zuora__BillingAccount__r.AGD_Unit__c + ',';//Business Unit 
            
            //START 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Group invoice line items per subscription per invoice
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
            
            //START D-1829 23/01/2015 Michael Francisco - Set DEFAULT Freight_Amount ...
            exportData += vFreightAmount + ','; //Freight Amount TBD
            //END D-1829 23/01/2015 Michael Francisco 
            
            exportData += invRecord.Zuora__TaxAmount__c.setScale(2) + ',';//GST Amount 
            //exportData += Decimal.valueOf(invRecord.Zuora__TotalAmount__c).scale(2) - Decimal.valueOf(invRecord.Zuora__TaxAmount__c).scale(2) + ',';//Gross Amount 
            //exportData += invRecord.Zuora__AmountWithoutTax__c+ ',';
            exportData += invRecord.Zuora__TotalAmount__c.setScale(2)+ ',';            
            //Start D-3982 2015-11-24 Renz  Company_Name__c is the new attention to name
            //exportData += StringUtility.quoteReplaceStr(invRecord.Zuora__BillingAccount__r.Attention_To_Care1__c) + ',';//Attention To   //START/END 2015-09-21 Renz UD-2786  Change the mapping
            exportData += StringUtility.quoteReplaceStr(invRecord.Zuora__BillingAccount__r.Billing_Contact__r.Company_Name__c) + ',';
            //End D-3982 2015-11-24 Renz
            
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
            
            //START D-1829 23/01/2015 Michael Francisco - Use GSTRate variable ...
            exportData += GSTRate + ',';//GST Rate 
            //END D-1829 23/01/2015 Michael Francisco 
            
            if (invoice_subscriptionIdSet_map.get(invRecord.Zuora__External_Id__c)!=null){              
                exportData += invoice_subscriptionIdSet_map.get(invRecord.Zuora__External_Id__c).size();//GST Rate 
            } else {
                exportData += '0';//GST Rate 
            }
            //END 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Group invoice line items per subscription per invoice

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
            //START 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Group invoice line items per subscription per invoice
            //Start [15 Dec 2014 Renz D-1213] Changed the invRecord.name into InvRecord.Zuora__External_Id__c (Defect #D-1213)
            if (invoice_subscriptionIdSet_map.get(invRecord.Zuora__External_Id__c)!=null) 
            //End [15 Dec 2014 Renz D-1213]
            {
                //Start [15 Dec 2014 Renz D-1213] Changed the invRecord.name into InvRecord.Zuora__External_Id__c (Defect #D-1213)
                //List<Invoice_Line_Item__c> tmpInvLinesList = invLinesMap.get(invRecord.Zuora__External_Id__c);   
                //End [15 Dec 2014 Renz D-1213]
                Integer lineCtr = 0;
                for (Id subscriptionIdElem : invoice_subscriptionIdSet_map.get(invRecord.Zuora__External_Id__c))
                {                   
                    String invoiceSubscriptionKey = constructInvoiceSubscriptionKey(invRecord.Zuora__External_Id__c, subscriptionIdElem);                   
                    AGD042DX_LineItemAmountWrapper lineItemWrapperRecord = invoiceSubscriptionId_LineItemWrapper_map.get(invoiceSubscriptionKey);
                    lineCtr++;
                    String exportData2 = '';
                    exportData2 += lineCtr + ','; //Invoice Line Number                 
					//START 17 May 2016 PD-0213 Kevin Evasco - Set scale to 5 to fix decimal precision issue
                    exportData2 += lineItemWrapperRecord.unitPrice.setScale(5)  + ','; //Unit Price 
					//END 17 May 2016 PD-0213 Kevin Evasco - Set scale to 5 to fix decimal precision issue
                    exportData2 += lineItemWrapperRecord.quantity + ','; //Quantity 
                    exportData2 += lineItemWrapperRecord.taxAmount.setScale(2) + ','; //GST Amount 
                    exportData2 += lineItemWrapperRecord.merchandiseAmount.setScale(2) + ','; //Merchandise Amount 
                    exportData2 += StringUtility.quoteReplaceStr(lineItemWrapperRecord.lineDescription); //Line Description 
                    
                    //exportData2 += record2.Product_Name__c + ' Subscription From ' +                        
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
            //END 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Group invoice line items per subscription per invoice
        }       
        //END 2015/05/05 Renino Niefes D-XXXX Default Values
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_AGD042DX_AGDEInvoince insert operation failed.');
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
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        //System.debug('*********************** inside final'+ this.query);
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID(interfaceId);
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');        

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);
    }
    
    //START 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Group invoice line items per subscription per invoice
    global static String constructInvoiceSubscriptionKey(String invoiceId, String subscriptionId) {
        return invoiceId + '_' + subscriptionId;
    }
    //END 16 September 2015 UD-1371 and UD-2786 Kevin Evasco - Group invoice line items per subscription per invoice
}