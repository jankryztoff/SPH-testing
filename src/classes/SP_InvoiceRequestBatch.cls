/*
 * Class Name: SP_InvoiceRequestBatch 
 * @author: Kevin H. Evasco
 * Date: 11/09/2014
 * Project/Requirement: Letter Printing - Credit Card Failure Notification
 * @description This class generates Credit Card Failure Notification Letter Print Requests
 * 
 * History: 11/09/2014 Kevin Evasco Created Apex Batch
 * History: 12/05/2014 D-0797, D-0849 Kevin Evasco Added new constructor to enable storage of Session ID.
 * History: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
 * History: 4/27/2015  D-2829 KRITHIKA DHARMARAJAN Added condition to make Letter print request mark printable
 * History: 06/10/2015 UD-1505 / UD-1514 / UD-1577
                Kevin Evasco - Reconstructed class to enable the following features:
                1. Invoice Generation should happen for all bill run invoices except for those with zero or negative balance.
                2. Letter Print Requests will only be marked as subject for printing if any of these is true:
                        - Account - GST Invoice = 'Yes'
                        - Billing Account Payment Mode = 'Invoice'
                        - Billing Account has order line item with Generate Invoice = true
                3. We are now storing the latest ARMS Invoice ID in the custom settings to avoid SOQL issues.
                
                Minor changes:              
                1. Removed unused variables
                2. Repositioned query for latest batch job scheduler record from execute method to start method.                
 * History: 09/15/2015 UD-2694 Kevin Evasco Restructured batch given the following changes:
                1. Changed batch scope from Billing Account to Invoice.
                2. Removed logic for Order Line Item Generate Invoice printable checking.

                        
 */

global class SP_InvoiceRequestBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    global static String SETTING_KEY_ARMS_INVOICE_ID = 'ARMS Latest Invoice ID';
    global static String SETTING_INITIAL_VALUE_ARMS_INVOICE_ID = '0027000000';
    global static String SETTING_PREFIX_ARMS_INVOICE_ID = '00';
    global static String SETTING_KEY_GST = 'GST';
    
    String letterType;
    String sessionId;   
    
    Integer latestARMSInvoiceId = 0;    
    Integer requestCount = 0;
    
    Boolean isRegularExecution;
    Boolean gstUpdateFlag = false; 
    Boolean selectAccountsOnly = false;
    
    //DateTime lastExecution; //START 15 September 2015 UD-2694 Kevin Evasco - Removed unused code.
    Date referenceDate = UsageHelper.getUsageReferenceDate(); 
    
    Other__c latestARMSInvoiceIdSetting = getLatestARMSInvoiceIdSettings(); 
    //Start D-3620 01-Oct-2015 Added By S.Puli
    //START D-4080 Gdelrosario : added instantiation for code review
    Set<Id> invoiceIds = new Set<Id>();
    //END D-4080 Gdelrosario : added instantiation for code review
    //END D-3620 01-Oct-2015 Added By S.Puli
    //List<Letter_Print_Request__c> letterPrintRequests = new List<Letter_Print_Request__c>(); //START 15 September 2015 UD-2694 Kevin Evasco - Move declartion to execute method.
    
    //Start UD-3207 26-Mar-2016 Added by S.Puli
    String corporateAcc = ConstantsSLB.getKeyId('Account_Direct Corporate');
    String fullPrep = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
    //End UD-3207 26-Mar-2016 Added by S.Puli
    global SP_InvoiceRequestBatch(String letterType, Integer batchCount, String sessionId, Boolean isRegularExecution){
        this.letterType = letterType;
        this.sessionId = sessionId;
        this.isRegularExecution = isRegularExecution;
    }
    //Start D-3620 01-Oct-2015 Added By S.Puli
    global SP_InvoiceRequestBatch(String letterType, Integer batchCount, String sessionId, Set<Id> invoiceIds){
        this.letterType = letterType;
        this.sessionId = sessionId;
        this.invoiceIds = invoiceIds;
        this.isRegularExecution = false;
        selectAccountsOnly = true;
    }    
    //END D-3620 01-Oct-2015 Added By S.Puli
    //START 15 September 2015 UD-2694 Kevin Evasco - Restructured start and execute method. Changed batch scope and removed order line item generate invoice printable checking
    global Database.QueryLocator start(Database.BatchableContext bc){               
        latestARMSInvoiceId = Integer.valueOf(latestARMSInvoiceIdSetting.Value__c);
        
		//Start UD-3942 12-Apr-2016 Added By S.Puli 
        //Start UD-3207 01-Apr-2016 Added By S.Puli
        if(selectAccountsOnly == false){
            return Database.getQueryLocator([SELECT Id, Zuora__Zuora_Id__c, ARMS_Invoice_ID__c, Zuora__BillingAccount__r.Other_PaymentMethod__c, 
                Zuora__BillingAccount__r.Id, Zuora__Account__r.GST_Invoice__c,Zuora__TotalAmount__c, Is_PDF_Generated__c, Previous_Balance__c, 
                Zuora__BillingAccount__r.Zuora__Balance__c, Zuora__PaymentAmount__c 
                FROM Zuora__ZInvoice__c 
                WHERE Is_PDF_Generated__c = false AND (Zuora__BillingAccount__r.Other_PaymentMethod__c != 'Invoice' OR (Zuora__TotalAmount__c > 0 AND Zuora__BillingAccount__r.ARMS_Account_Number__c != NULL)) 
                //Start/End PD-0502 06-Jun-2016 Added By S.Puli - remove 3207 temporarily AND ((Zuora__Account__r.RecordTypeId = :corporateAcc AND Zuora__BillingAccount__r.Billing_Type__c <> :fullPrep) OR (Zuora__Account__r.RecordTypeId <> :corporateAcc)) 
                ORDER BY Zuora__InvoiceDate__c ASC]);
        } else {
             //START/END 20 September 2015 Kevin Evasco UD-2834. Do not process ARMS Invoices if the Billing Account does not have ARMS Accoutnt Number
            //Start D-3620 01-Oct-2015 Added By S.Puli - modify to use invocie ID instead of account number to use specific invoice
            return Database.getQueryLocator([SELECT Id, Zuora__Zuora_Id__c, ARMS_Invoice_ID__c, Zuora__BillingAccount__r.Other_PaymentMethod__c, 
                Zuora__BillingAccount__r.Id, Zuora__Account__r.GST_Invoice__c,Zuora__TotalAmount__c, Is_PDF_Generated__c, Previous_Balance__c, 
                Zuora__BillingAccount__r.Zuora__Balance__c, Zuora__PaymentAmount__c 
                FROM Zuora__ZInvoice__c 
                WHERE Is_PDF_Generated__c = false AND (Zuora__BillingAccount__r.Other_PaymentMethod__c != 'Invoice' OR (Zuora__TotalAmount__c > 0 AND Zuora__BillingAccount__r.ARMS_Account_Number__c != NULL)) 
                //Start/End PD-0502 06-Jun-2016 Added By S.Puli - remove 3207 temporarily AND ((Zuora__Account__r.RecordTypeId = :corporateAcc AND Zuora__BillingAccount__r.Billing_Type__c <> :fullPrep) OR (Zuora__Account__r.RecordTypeId <> :corporateAcc)) 
                AND Id IN :invoiceIds ORDER BY Zuora__InvoiceDate__c ASC]);
            //END D-3620 01-Oct-2015 Added By S.Puli
        }
        //End UD-3207 01-Apr-2016 Added By S.Puli
		//End UD-3942 12-Apr-2016 Added By S.Puli
    }     
    
    global void execute(Database.BatchableContext BC, List<Zuora__ZInvoice__c> scope){
        //START: UD-3505 01-08-2015 added by Jason A.
        Logger logger = new Logger(SP_InvoiceRequestBatch.class.getName(), 'SP020', BC.getJobID());
        boolean isError = false;
        //END: UD-3505 01-08-2015 added by Jason A.
        Set<Id> billingAccountIdSet = new Set<Id>(); 
        Set<String> invoiceZuoraIdSet = new Set<String>();  
        
        List<Letter_Print_Request__c> letterPrintRequests = new List<Letter_Print_Request__c>();   
        List<Zuora__ZInvoice__c> newARMSInvoices = new List<Zuora__ZInvoice__c>();   
        List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>(); 
        
        Map<String, Decimal> zuoraIdTotalAmount = new Map<String, Decimal>();
        Map<String, Id> invoiceWithVAlue_MAP = new Map<String, Id>();
                    
        for(Zuora__ZInvoice__c invoice : scope){          
            if(invoice.Zuora__Zuora_Id__c != null){
              invoiceZuoraIdSet.add(invoice.Zuora__Zuora_Id__c);
            }
        }
        
        //START UD-2819 19-Sept-2015 Added By S.Puli - add UOM__c, ID__c, Applied_To_Invoice_Item_ID__c
        invoiceLineItemList = [SELECT id, name, Invoice_ID__c, Charge_Amount__c, Tax_Amount__c, UOM__c, ID__c, Applied_To_Invoice_Item_ID__c FROM Invoice_Line_Item__c WHERE Invoice_ID__c IN: invoiceZuoraIdSet];
        //END UD-2819 19-Sept-2015 Added By S.Puli

        Decimal tempAmount = 0.00;
        
        for(Invoice_Line_Item__c invoiceLineItem : invoiceLineItemList){
            
            // invoiceWithVAlue_MAP: Map would contain the invoice id key if there is at least 1 non-zero invoice line item
            //START UD-2819 19-Sept-2015 Added By S.Puli
            //START D-3603 23-Sept-2015 Added By S.Puli - at least 1 positive invoice line item which the UOM is does not start with ‘No Credit’.
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
            //END D-3603 23-Sept-2015 Added By S.Puli
            //END UD-2819 19-Sept-2015 Added By S.Puli
            
            // Populate zuoraIdTotalAmount map. Key: Invoice Id: Value: Sum of Invoice Line Item Amounts.
            if(zuoraIdTotalAmount.containsKey(invoiceLineItem.Invoice_ID__c)){
                tempAmount = zuoraIdTotalAmount.get(invoiceLineItem.Invoice_ID__c);
                tempAmount = tempAmount + invoiceLineItem.Charge_Amount__c + invoiceLineItem.Tax_Amount__c;
                zuoraIdTotalAmount.put(invoiceLineItem.Invoice_ID__c, tempAmount);
            } else {
                tempAmount = invoiceLineItem.Charge_Amount__c + invoiceLineItem.Tax_Amount__c;
                zuoraIdTotalAmount.put(invoiceLineItem.Invoice_ID__c, tempAmount);
            }            
        }
        
        for(Zuora__ZInvoice__c invoiceRec : scope){    
            //Only create a letter print request if the Invoice has at least 1 non-zero Invoice Line Item && the sum Invoice Line Item Amount is equal to the Invoice Total Amount.
            //START: UD-3505 01-08-2015 added by Jason A.
            try{
                if(invoiceWithVAlue_MAP.containsKey(invoiceRec.Zuora__Zuora_Id__c) && zuoraIdTotalAmount.get(invoiceRec.Zuora__Zuora_Id__c) == invoiceRec.Zuora__TotalAmount__c){
                    //START UD-2819 19-Sept-2015 Added By S.Puli
					//Start UD-3942 12-Apr-2016 Added By S.Puli Previous_Balance__c, Zuora__BillingAccount__r.Zuora__Balance__c, Zuora__TotalAmount__c, Zuora__PaymentAmount__c
					Decimal totalOutstanding = 0;
					Decimal previousBalance = 0;
					if(invoiceRec.Previous_Balance__c != null) {
						previousBalance = Decimal.valueOf(invoiceRec.Previous_Balance__c);
					} else {           
						previousBalance = invoiceRec.Zuora__BillingAccount__r.Zuora__Balance__c - invoiceRec.Zuora__TotalAmount__c + invoiceRec.Zuora__PaymentAmount__c; 
					}
					
					totalOutstanding = previousBalance + invoiceRec.Zuora__TotalAmount__c;
					
                    if(invoiceRec.Zuora__BillingAccount__r.Other_PaymentMethod__c <> 'Invoice' || totalOutstanding > 0){//invoiceRec.Zuora__TotalAmount__c > 0){
                        Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                        letterPrintRequest.Letter_Type__c = letterType;
                        letterPrintRequest.Record_ID__c = invoiceRec.Id;
                        letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;

                        if(invoiceRec.Zuora__BillingAccount__r.Other_PaymentMethod__c == 'Invoice' || invoiceRec.Zuora__Account__r.GST_Invoice__c == 'Yes'){
                            letterPrintRequest.Printable__c = true ;
                        }

                        letterPrintRequests.add(letterPrintRequest);
                    }
					
            //END UD-2819 19-Sept-2015 Added By S.Puli
            // START D-3555/UD-2508 10 September 2015 Kevin Evasco - Only assign arms invoice ID if we have a letter print request.             
                    if(invoiceRec.Zuora__BillingAccount__r.Other_PaymentMethod__c == 'Invoice' && totalOutstanding > 0){
                        if(invoiceRec.ARMS_Invoice_ID__c == null || invoiceRec.ARMS_Invoice_ID__c == ''){
                            invoiceRec.ARMS_Invoice_ID__c = SETTING_PREFIX_ARMS_INVOICE_ID + latestARMSInvoiceId;
                            latestARMSInvoiceId++;
                            newARMSInvoices.add(invoiceRec);
                        }
                    }
					//End UD-3942 12-Apr-2016 Added By S.Puli
            // END D-3555/UD-2508 10 September 2015 Kevin Evasco - Only assign arms invoice ID if we have a letter print request.
              
                    if(gstUpdateFlag == false){
                        gstUpdateFlag = updateGSTRate(invoiceRec.Zuora__Zuora_Id__c);
                    }
                }
            }
            catch(exception e){
                logger.log(true,  'Stack trace: ' + e.getStackTraceString() + '\n Message: ' + e.getMessage(),invoiceRec.id);
                isError = true;
            }
            //END: UD-3505 01-08-2015 added by Jason A.
        }    
        //START: UD-3505 01-08-2015 added by Jason A.
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
        //END: UD-3505 01-08-2015 added by Jason A.
        if(newARMSInvoices.size()>0){
            List<Database.saveResult> saveResults = Database.update(newARMSInvoices,false);
            system.debug('saveResults>>'+saveResults);
        }
        //START: UD-3505 01-08-2015 added by Jason A.
        if(isError){
            logger.save();          
        } 
        //END: UD-3505 01-08-2015 added by Jason A.
    }
    //END 15 September 2015 UD-2694 Kevin Evasco - Restructured start and execute method. Changed batch scope and removed order line item generate invoice printable checking
    
    global void finish(Database.BatchableContext BC){
        //START D-  3535 09-Sept-2015 Added By S.Puli
         //START D-4482 14-Mar-2016 Added by Raviteja - Fetching Job status for letter Print Request job
        //BatchJobHelper.updateJobStatus(BC.getJobId());
        Boolean isSucess;   
        isSucess = BatchJobHelper.getJobStatus(letterType,'SP020',GlobalVariableClass.STATUS_PENDING);
        //BatchJobHelper.updateJobStatus(BC.getJobId(),isSucess);
        BatchJobHelper.updateBatchJobScheduler(BC.getJobId(),isSucess);
        //End D-4482 14-Mar-2016 Added by Raviteja 
        List<Letter_Print_Request__c> letterRequests_LIST = [SELECT Id,Letter_Type__c,Status__c FROM Letter_Print_Request__c 
                                                            WHERE Letter_Type__c = :letterType AND Status__c = :SP_GenerateLetterPrintBatch.newValue LIMIT 1];
        if(letterRequests_LIST.size()>0){
            SP_LetterPrintRequestUpdater sp = new SP_LetterPrintRequestUpdater();
            sp.sessionId = sessionId;
            sp.requestCount = requestCount;
            sp.letterType = letterType;
            sp.batchCode = 'SP028';
            sp.parentjobid = BC.getJobId();//Start PD-0027 Raviteja 09May2016 - Capturing batch job schdduler record id    
            //Start PD-0027 Raviteja 09May2016 - Added isRunningTest if condition
            if(!Test.isRunningTest()){
            	Database.executeBatch(sp, 100);
            }
            //End PD-0027 Raviteja 09May2016
        } else {
            //Start D-4742 Raviteja 26Apr2016 - Capturing batch job schdduler record id            
            SP_BatchJobSchedulerService.setParentBatchJobSchedulerId(BC.getJobId());  
            //End D-4742 Raviteja 26Apr2016 - Capturing batch job schdduler record id	
            //Start PD-0027 Raviteja 09May2016 - Added isRunningTest if condition
            if(!Test.isRunningTest()){
            	SP_BatchJobSchedulerService.initializeBatches('SP028','Start', null, sessionId,requestCount);
            }
           //End PD-0027 Raviteja 09May2016	
        }
        
        //END D-3535 09-Sept-2015 Added By S.Puli
        
        latestARMSInvoiceIdSetting.Value__c = SETTING_PREFIX_ARMS_INVOICE_ID + latestARMSInvoiceId;
        update latestARMSInvoiceIdSetting;
    }
    
    public Boolean updateGSTRate(String invoiceZuoraId){        
        Boolean updateSuccessful = false;
        Decimal taxRate;
        //START UD-1615 14-June-2015 Kevin Evasco: Hotfix. Get the GST Rate from the latest taxation item.
        DateTime latestCreatedDate;
        try{
            Zuora.zApi zuorApi = new Zuora.zApi();
            //START D-3268 Modified By C.I.Salas - Test Coverage
            if (!Test.isRunningTest()) {
                zuorApi.zlogin();
            }
            //END D-3268 Modified By C.I.Salas - Test Coverage
            String zoql = 'SELECT TaxRate, CreatedDate FROM TaxationItem Where InvoiceId =\'' + invoiceZuoraId + '\'';
            //Start PD-0027 Raviteja 18May2016  - Included below D-4686 changes as part of the PD-0027 deployment to avoid code coverage issue 
            //START 15/04/2016 D-4686 - added isRunningTest to skip zCallout (MBG)
            List<Zuora.zObject> zobjs = new List<Zuora.zObject>();
            if (!Test.isRunningTest()) {
                zobjs = zuorApi.zquery(zoql);
            }
            else {
                taxRate =10;
            }
            //END 15/04/2016 D-4686 - added isRunningTest to skip zCallout (MBG)
            //END PD-0027 Raviteja 18May2016
             
            for (Zuora.zObject o : zobjs){
                if(latestCreatedDate == null){                  
                    latestCreatedDate = (DateTime)o.getValue('CreatedDate');
                    taxRate = (Decimal)o.getValue('TaxRate')*100;
                } else if((DateTime)o.getValue('CreatedDate') > latestCreatedDate){
                    latestCreatedDate = (DateTime)o.getValue('CreatedDate');
                    taxRate = (Decimal)o.getValue('TaxRate')*100;
                }
            }
        } catch (Exception e){
        }
        //END UD-1615 14-June-2015 Kevin Evasco: Hotfix. Get the GST Rate from the latest taxation item.
        
        if(taxRate != null && taxRate != 0){ //START/END D-3327 04 August 2015 Kevin Evasco - Update only GST for non-zero tax rates.
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