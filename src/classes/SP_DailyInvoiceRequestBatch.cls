/*
 * Class Name: SP_DailyInvoiceRequestBatch 
 * @author: PDC Accenture - Sherwin R. Puli
 * Date: 26-Mar-2016
 * Project/Requirement: UD-3207 Letter Printing - Daily Invoice
 * @description This class generates Daily Invoice Letter print request
 * 
 * History:                       
 */

global class SP_DailyInvoiceRequestBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    public Other__c ARMS_Initial_Invoice = Other__c.getInstance('ARMS Initial Invoice');
    
    global static String SETTING_KEY_ARMS_INVOICE_ID = 'ARMS Latest Invoice ID';
    String SETTING_INITIAL_VALUE_ARMS_INVOICE_ID = String.valueOf(ARMS_Initial_Invoice.value__c);
    global static String SETTING_PREFIX_ARMS_INVOICE_ID = '00';
    global static String SETTING_KEY_GST = 'GST';
    
    String letterType;
    String sessionId;   
    
    Integer latestARMSInvoiceId = 0;    
    Integer requestCount = 0;
    
    Boolean isRegularExecution;
    Boolean gstUpdateFlag = false; 
    Boolean selectAccountsOnly = false;
    
    Date referenceDate = UsageHelper.getUsageReferenceDate(); 
    
    Other__c latestARMSInvoiceIdSetting = getLatestARMSInvoiceIdSettings(); 
    Set<Id> dailyInvIds = new Set<Id>();
    String corporateAcc = ConstantsSLB.getKeyId('Account_Direct Corporate');
    String fullPrep = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
    
    global SP_DailyInvoiceRequestBatch(String letterType, Integer batchCount, String sessionId, Boolean isRegularExecution){
        this.letterType = letterType;
        this.sessionId = sessionId;
        this.isRegularExecution = isRegularExecution;
    }
    
    global SP_DailyInvoiceRequestBatch(String letterType, Integer batchCount, String sessionId, Set<Id> dailyInvIds){
        this.letterType = letterType;
        this.sessionId = sessionId;
        this.dailyInvIds = dailyInvIds;
        this.isRegularExecution = false;
        selectAccountsOnly = true;
    }    

    global Database.QueryLocator start(Database.BatchableContext bc){            
        latestARMSInvoiceId = Integer.valueOf(latestARMSInvoiceIdSetting.Value__c);
        if(selectAccountsOnly == false){
            return Database.getQueryLocator([SELECT Id, Name, To_ARMS_Time__c, ARMS_Invoice_ID__c, Balance__c, Billing_Account__c, Invoice_Date__c, 
                Is_PDF_Generated__c, Payment_Amt__c, Prev_Bal__c, Tax_Amt__c, Tax_Exempt_Amt__c, Total_Amt__c,Billing_Account__r.Zuora__Account__r.RecordTypeId,
                Billing_Account__r.Other_PaymentMethod__c,Billing_Account__r.Zuora__Account__r.GST_Invoice__c 
                FROM Daily_Invoice__c 
                WHERE Billing_Account__r.Zuora__Account__r.RecordTypeId = :corporateAcc 
                AND Billing_Account__r.Billing_Type__c = :fullPrep 
                AND Is_PDF_Generated__c = false 
                ORDER BY Invoice_Date__c ASC]);
        } else {
            return Database.getQueryLocator([SELECT Id, Name, To_ARMS_Time__c, ARMS_Invoice_ID__c, Balance__c, Billing_Account__c, Invoice_Date__c, 
                Is_PDF_Generated__c, Payment_Amt__c, Prev_Bal__c, Tax_Amt__c, Tax_Exempt_Amt__c, Total_Amt__c,Billing_Account__r.Zuora__Account__r.RecordTypeId,
                Billing_Account__r.Other_PaymentMethod__c, Billing_Account__r.Zuora__Account__r.GST_Invoice__c 
                FROM Daily_Invoice__c 
                WHERE Billing_Account__r.Zuora__Account__r.RecordTypeId = :corporateAcc 
                AND Billing_Account__r.Billing_Type__c = :fullPrep 
                AND Id IN :dailyInvIds 
                ORDER BY Invoice_Date__c ASC]);
        }
    }     
    
    global void execute(Database.BatchableContext BC, List<Daily_Invoice__c> scope){
        Logger logger = new Logger(SP_DailyInvoiceRequestBatch.class.getName(), 'SP062', BC.getJobID());
        boolean isError = false;
        Set<Id> billingAccountIdSet = new Set<Id>(); 
        Set<String> invoiceZuoraIdSet = new Set<String>();  
        
        List<Letter_Print_Request__c> letterPrintRequests = new List<Letter_Print_Request__c>();   
        List<Daily_Invoice__c> newARMSInvoices = new List<Daily_Invoice__c>();   
        List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>(); 
        
        Map<String, Decimal> zuoraIdTotalAmount = new Map<String, Decimal>();
        Map<String, Id> invoiceWithVAlue_MAP = new Map<String, Id>();
        
        List<Zuora__ZInvoice__c> invoiceScope = new List<Zuora__ZInvoice__c>();
        Set<Id> initialDailyInvIds = new Set<Id>();
        
        Map<Id, boolean> invDailyToKey_Map = new Map<Id, boolean>();
        
        for(Daily_Invoice__c dInv : scope){
            initialDailyInvIds.add(dInv.Id);
        }
        
        invoiceScope = [SELECT Id, Zuora__Zuora_Id__c, ARMS_Invoice_ID__c, Zuora__BillingAccount__r.Other_PaymentMethod__c, 
                        Zuora__BillingAccount__r.Id, Zuora__Account__r.GST_Invoice__c,Zuora__TotalAmount__c, Is_PDF_Generated__c,
                        Daily_Invoice__c 
                        FROM Zuora__ZInvoice__c 
                        WHERE Daily_Invoice__c IN :initialDailyInvIds];
        
        for(Zuora__ZInvoice__c invoice : invoiceScope){          
            if(invoice.Zuora__Zuora_Id__c != null){
              invoiceZuoraIdSet.add(invoice.Zuora__Zuora_Id__c);
            }
        }
        
        invoiceLineItemList = [SELECT id, name, Invoice_ID__c, Charge_Amount__c, Tax_Amount__c, UOM__c, ID__c, Applied_To_Invoice_Item_ID__c FROM Invoice_Line_Item__c WHERE Invoice_ID__c IN: invoiceZuoraIdSet];

        Decimal tempAmount = 0.00;
        
        for(Invoice_Line_Item__c invoiceLineItem : invoiceLineItemList){

            if(invoiceLineItem.Charge_Amount__c > 0 ){
                if(invoiceLineItem.UOM__c <> null){
                    if(invoiceLineItem.UOM__c.length() > 8){
                        String uomString = '';
                        uomString = invoiceLineItem.UOM__c.substring(0,9).toUpperCase();
                        if(uomString <> GlobalVariableClass.NO_CREDIT){
                            invoiceWithVAlue_MAP.put(invoiceLineItem.Invoice_ID__c, invoiceLineItem.Id);
                        }
                    }
                    else{
                        invoiceWithVAlue_MAP.put(invoiceLineItem.Invoice_ID__c, invoiceLineItem.Id);
                    }
                }
                else{
                    invoiceWithVAlue_MAP.put(invoiceLineItem.Invoice_ID__c, invoiceLineItem.Id);
                }
            }
            else if(invoiceLineItem.Charge_Amount__c <= 0){
                if(invoiceLineItem.UOM__c <> null ){
                    if(invoiceLineItem.UOM__c.length() > 9){
                        if(invoiceLineItem.UOM__c.substring(0,10).toUpperCase() == GlobalVariableClass.ADJUSTMENT){
                            invoiceWithVAlue_MAP.put(invoiceLineItem.Invoice_ID__c, invoiceLineItem.Id);
                        }
                    }
                }
            }   

            if(zuoraIdTotalAmount.containsKey(invoiceLineItem.Invoice_ID__c)){
                tempAmount = zuoraIdTotalAmount.get(invoiceLineItem.Invoice_ID__c);
                tempAmount = tempAmount + invoiceLineItem.Charge_Amount__c + invoiceLineItem.Tax_Amount__c;
                zuoraIdTotalAmount.put(invoiceLineItem.Invoice_ID__c, tempAmount);
            } else {
                tempAmount = invoiceLineItem.Charge_Amount__c + invoiceLineItem.Tax_Amount__c;
                zuoraIdTotalAmount.put(invoiceLineItem.Invoice_ID__c, tempAmount);
            }            
        }
        
        for(Zuora__ZInvoice__c invoiceRec : invoiceScope){    

            try{
                if(invoiceWithVAlue_MAP.containsKey(invoiceRec.Zuora__Zuora_Id__c) && zuoraIdTotalAmount.get(invoiceRec.Zuora__Zuora_Id__c) == invoiceRec.Zuora__TotalAmount__c){
                    if(invoiceRec.Zuora__BillingAccount__r.Other_PaymentMethod__c <> 'Invoice' || invoiceRec.Zuora__TotalAmount__c > 0){
                        if(!invDailyToKey_Map.containsKey(invoiceRec.Daily_Invoice__c)){
                            invDailyToKey_Map.put(invoiceRec.Daily_Invoice__c, true);
                        }
                    }           
              
                    if(gstUpdateFlag == false){
                        gstUpdateFlag = updateGSTRate(invoiceRec.Zuora__Zuora_Id__c);
                    }
                }
            }
            catch(exception e){
                logger.log(true,  'Stack trace: ' + e.getStackTraceString() + '\n Message: ' + e.getMessage(),invoiceRec.id);
                isError = true;
            }
        } 
        for(Daily_Invoice__c dailyInv : scope){
            if(invDailyToKey_Map.containsKey(dailyInv.Id)){
                if(invDailyToKey_Map.get(dailyInv.Id)){
                    Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                        letterPrintRequest.Letter_Type__c = letterType;
                        letterPrintRequest.Record_ID__c = dailyInv.Id;
                        letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;

                        if(dailyInv.Billing_Account__r.Other_PaymentMethod__c == 'Invoice' || dailyInv.Billing_Account__r.Zuora__Account__r.GST_Invoice__c == 'Yes'){
                            letterPrintRequest.Printable__c = true ;
                        }

                        letterPrintRequests.add(letterPrintRequest);
                        
                        if(dailyInv.Billing_Account__r.Other_PaymentMethod__c == 'Invoice' && dailyInv.Total_Amt__c > 0){
                            if(dailyInv.ARMS_Invoice_ID__c == null || dailyInv.ARMS_Invoice_ID__c == ''){
                                dailyInv.ARMS_Invoice_ID__c = SETTING_PREFIX_ARMS_INVOICE_ID + latestARMSInvoiceId;
                                latestARMSInvoiceId++;
                                newARMSInvoices.add(dailyInv);
                            }
                        }
                }
            }
        }
        try{
            if(letterPrintRequests.size() > 0){
            insert letterPrintRequests;
            requestCount += letterPrintRequests.size();
            }
        }
        catch(exception e){
            logger.logBatchFailure(e, letterPrintRequests);
            isError = true;
        }
        if(newARMSInvoices.size()>0){
            List<Database.saveResult> saveResults = Database.update(newARMSInvoices,false);
            system.debug('saveResults>>'+saveResults);
        }
        if(isError){
            logger.save();          
        } 
    }
    
    global void finish(Database.BatchableContext BC){

        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = new List<BATCH_JOB_SCHEDULER__c>();
        batchJobSchedulerList = [SELECT id, name, CreatedDate, Start_Time__c
                                FROM BATCH_JOB_SCHEDULER__c 
                                WHERE Batch_Code__c = 'SP062' AND Status__c = 'SUCCESS'
                                ORDER BY CreatedDate DESC LIMIT 1];
        if(!batchJobSchedulerList.isEmpty()){
            SP_LetterPrintRequestUpdater sp = new SP_LetterPrintRequestUpdater();
            sp.sessionId = sessionId;
            sp.requestCount = requestCount;
            sp.letterType = letterType;
            sp.batchCode = 'SP063';
            Database.executeBatch(sp, 100);
        }else{
            SP_BatchJobSchedulerService.initializeBatches('SP063','Start', null, sessionId,requestCount);
        }
        BatchJobHelper.updateJobStatus(BC.getJobId());
        latestARMSInvoiceIdSetting.Value__c = SETTING_PREFIX_ARMS_INVOICE_ID + latestARMSInvoiceId;
        update latestARMSInvoiceIdSetting;
    }
    
    public Boolean updateGSTRate(String invoiceZuoraId){        
        Boolean updateSuccessful = false;
        Decimal taxRate;
        DateTime latestCreatedDate;
        try{
            Zuora.zApi zuorApi = new Zuora.zApi();
            
            if (!Test.isRunningTest()) {
                zuorApi.zlogin();
            }
           
            String zoql = 'SELECT TaxRate, CreatedDate FROM TaxationItem Where InvoiceId =\'' + invoiceZuoraId + '\'';
            if(!Test.isRunningTest()){
                List<Zuora.zObject> zobjs = zuorApi.zquery(zoql);
            
                for (Zuora.zObject o : zobjs){
                    if(latestCreatedDate == null){                  
                        latestCreatedDate = (DateTime)o.getValue('CreatedDate');
                        taxRate = (Decimal)o.getValue('TaxRate')*100;
                    } else if((DateTime)o.getValue('CreatedDate') > latestCreatedDate){
                        latestCreatedDate = (DateTime)o.getValue('CreatedDate');
                        taxRate = (Decimal)o.getValue('TaxRate')*100;
                    }
                }
            }else{
                taxRate = 5;    
            }
        } catch (Exception e){
        }

        
        if(taxRate != null && taxRate != 0){ 
            List<Other__c> gstSettingList = [SELECT Id, Value__c FROM Other__c WHERE Name = :SETTING_KEY_GST];
            if(gstSettingList.size() > 0){
                Other__c gstSetting = gstSettingList.get(0);
                Decimal previousGstRate;
                if(gstSetting.Value__c != null){
                    try{ previousGstRate = Decimal.valueOf(gstSetting.Value__c); } catch(Exception e){}
                }
                
                if(previousGstRate != taxRate){
                    gstSetting.Value__c = taxRate.stripTrailingZeros().toPlainString();
                }
                update gstSetting;
            } else {
                Other__c gstSetting = new Other__c();
                gstSetting.Name = SETTING_KEY_GST;
                gstSetting.Value__c = taxRate.stripTrailingZeros().toPlainString();

                insert gstSetting;
            }
            updateSuccessful = true;
        }
        
        return updateSuccessful;        
    }       
    
    public Other__c getLatestARMSInvoiceIdSettings(){
        List<Other__c> gstSettingList = [SELECT Id, Value__c FROM Other__c WHERE Name = :SETTING_KEY_ARMS_INVOICE_ID];
        if(gstSettingList.size() > 0){
            Other__c gstSetting = gstSettingList.get(0);
            Integer armsLatestInvoiceId = 0;
            return gstSetting;
            
        } else {
            Other__c gstSetting = new Other__c();
            gstSetting.Name = SETTING_KEY_ARMS_INVOICE_ID;
            gstSetting.Value__c = SETTING_INITIAL_VALUE_ARMS_INVOICE_ID;
            insert gstSetting;
            
            return gstSetting;
        }
    }   
}