/**
 * Trigger Name: BT_AT_ARM071DX_ExportCustomerInvoice
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - ARM071DX Interface
 * Description: This trigger contains the business logic for ARM071DX interface.
 * History: 2014/08/21 Kevin Evasco Created Skeletal Apex Trigger
 *          2014/09/24 Kevin Evasco Updated to implement business logic
 *          2014/10/01 Kevin Evasco Updated to implement business logic
 * History: 2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings) 
 * History: 2015/03/31 Renino Niefes  D-2676 Added empty string checks
 * History: 2015/05/08 Renino Niefes Code Review - Cleaned up comments starting line 14 up to end of file.  Too many comments already.
 * History: 2015/06/03 Renino Niefes Sync UAT code to Github
 * History: 2015/10/20 Renino Niefes D-3772 Hotfixed in UAT2: Use 2nd condition in SOQL to further limit the number of records retrieved. use so.Synonym__c field.  Revised the Logging Level of Debug.
 */

 
trigger BT_AT_ARM071DX_ExportCustomerInvoice on BT_CO_ARMS_ExportCustomerInvoice__c (before insert, before update) 
{
	//START D-3772 Use 2nd condition in SOQL to further limit the number of records retrieved. use so.Synonym__c field.
    List<BT_CO_ARMS_ExportCustomerInvoice__c> recordsList = trigger.new;
    integer invalidRecordCount = 0;
    String errorMessage = '';
    String stackTrace = '';
    String dmlStatus = 'Success';    
    
    List<Zuora__ZInvoice__c> invoicesForUpdate = new List<Zuora__ZInvoice__c>();
    List<Zuora__ZInvoice__c> invoicesForInsert = new List<Zuora__ZInvoice__c>();
    
    Set<String> inputARMSAccountNumberSet = new Set<String>();
    Set<String> existingARMSAccountNumberSet = new Set<String>();
    Set<String> validARMSAccountNumberSet = new Set<String>();       
    Set<String> newARMSAccountNumberSet = new Set<String>();    
    
    Set<String> inputSynonymSet = new Set<String>();
    Set<String> existingSynonymSet = new Set<String>();
    Set<Id> existingSynonymIdSet = new Set<Id>();
    Set<String> validSynonymSet = new Set<String>();
    Set<String> newSynonymSet = new Set<String>();
    
    Set<String> inputInvoiceNumberSet = new Set<String>();
    Set<String> existingInvoiceNumberSet = new Set<String>();
    Set<String> validInvoiceNumberSet = new Set<String>();
    Set<String> newInvoiceNumberSet = new Set<String>();
    
    Map<String,BT_CO_ARMS_ExportCustomerInvoice__c> invoiceNumber_SO_map = new Map<String,BT_CO_ARMS_ExportCustomerInvoice__c>();
    System.debug(loggingLevel.INFO,'RENZ --> trigger size ' + recordsList.size());
	
    for(BT_CO_ARMS_ExportCustomerInvoice__c so : recordsList){
        if (so.accountNumber__c!=null&&so.accountNumber__c.trim()!='') {
			inputARMSAccountNumberSet.add(so.accountNumber__c.trim());
			System.debug(loggingLevel.INFO,'RENZ --> inputARMSAccountNumberSet ADD  ' + so.accountNumber__c);
		}
        System.debug(loggingLevel.INFO,'SZ1 --> inputARMSAccountNumberSet size ' + inputARMSAccountNumberSet.size());
        
        if (so.synonym__c!=null&&so.synonym__c.trim()!='') {			
			inputSynonymSet.add(so.synonym__c.trim());
			System.debug(loggingLevel.INFO,'RENZ --> inputSynonymSet ADD  ' + so.synonym__c);
		}
        System.debug(loggingLevel.INFO,'SZ2 --> inputSynonymSet size ' + inputSynonymSet.size());
        
        if (so.invoiceNumber__c!=null&&so.invoiceNumber__c.trim()!=''){
            inputInvoiceNumberSet.add(so.invoiceNumber__c);
            System.debug(loggingLevel.INFO,'SZ3 --> inputInvoiceNumberSet size ' + inputInvoiceNumberSet.size());

            invoiceNumber_SO_map.put(so.invoiceNumber__c,so);
            System.debug(loggingLevel.INFO,'SZ4 --> invoiceNumber_SO_map size ' + invoiceNumber_SO_map.size());
            
            validInvoiceNumberSet.add(so.invoiceNumber__c);
            System.debug(loggingLevel.INFO,'SZ5 --> validInvoiceNumberSet size ' + validInvoiceNumberSet.size());
            
            so.Validation_Status__c = 'Passed';  
        }
    }
    validInvoiceNumberSet.remove(null);  //START/END UD-3207 and D-4584 22-Mar-2016 Added by Raviteja - Removing null values from set
    
    //for(Zuora__CustomerAccount__c zBillingAccount : [SELECT Id FROM Zuora__CustomerAccount__c WHERE Zuora__Account__r.Id IN :inputSynonymSet]) {
    
    System.debug(loggingLevel.INFO,'SZ6 --> inputARMSAccountNumberSet size '+ inputARMSAccountNumberSet.size());
	List<Zuora__CustomerAccount__c> zBillingAccountList = [SELECT Id,arms_account_number__c FROM Zuora__CustomerAccount__c WHERE arms_account_number__c IN :inputARMSAccountNumberSet AND Zuora__Account__r.AccountNumber IN :inputSynonymSet ];
    for(Zuora__CustomerAccount__c zBillingAccount : zBillingAccountList) {
        System.debug(loggingLevel.INFO,'SZ7 --> Arms account number -->'+zBillingAccount.arms_account_number__c);
        existingSynonymIdSet.add(zBillingAccount.Id);
    }   
    
    //invoicesForUpdate = [SELECT Id, ARMS_Invoice_ID__c, Name, Zuora__BillingAccount__r.ARMS_Account_Number__c, Zuora__BillingAccount__r.ARMS_Customer_Number__c FROM Zuora__ZInvoice__c WHERE  Zuora__BillingAccount__r.Id  IN :existingSynonymIdSet AND ARMS_Invoice_ID__c IN :validInvoiceNumberSet];
 
    //Start/End UD-3207 and D-4584 22-Mar-2016 Added by Raviteja - Added Zuora__TotalAmount__c in SOQL and sorted by Desc
    
    invoicesForUpdate = [SELECT Id, ARMS_Invoice_ID__c, Name, Zuora__BillingAccount__r.ARMS_Account_Number__c, Zuora__BillingAccount__r.ARMS_Customer_Number__c, Zuora__TotalAmount__c FROM Zuora__ZInvoice__c WHERE  Zuora__BillingAccount__r.Id  IN :existingSynonymIdSet AND ARMS_Invoice_ID__c IN :validInvoiceNumberSet  order by Zuora__TotalAmount__c Desc];
    
    Map<String, BT_CO_ARMS_ExportCustomerInvoice__c> updateList = new Map<String, BT_CO_ARMS_ExportCustomerInvoice__c>();
    for(BT_CO_ARMS_ExportCustomerInvoice__c temp : recordsList){
        updateList.put(temp.invoiceNumber__c,temp);
    }
    
    System.debug(loggingLevel.INFO,'SZX -----> ' + updateList.size());
    for(Zuora__ZInvoice__c invoice : invoicesForUpdate)
    {
        BT_CO_ARMS_ExportCustomerInvoice__c so = invoiceNumber_SO_map.get(invoice.ARMS_Invoice_ID__c);
        //START UD-3207  and D-4584 22-Mar-2016 Added by Raviteja - updating ARMS outstanding amount into new filed instead of Balance
        //invoice.Zuora__Balance2__c = Decimal.valueOf(so.invoiceOutstandingAmount__c);   
        Decimal invoiceOutstandingAmount = Decimal.valueOf(so.invoiceOutstandingAmount__c); 
               
        if(invoice.Zuora__TotalAmount__c <= invoiceOutstandingAmount){
            invoice.ARMS_Outstanding_Amount__c = invoice.Zuora__TotalAmount__c;
            invoiceOutstandingAmount -= invoice.Zuora__TotalAmount__c;
        }else{
            invoice.ARMS_Outstanding_Amount__c = invoiceOutstandingAmount;
            invoiceOutstandingAmount = 0;
         }
        
        //END UD-3207 and D-4584 22-Mar-2016 Added by Raviteja 
        if(updateList.containsKey(invoice.ARMS_Invoice_ID__c)){
            updateList.remove(invoice.ARMS_Invoice_ID__c);
        }
    }
    System.debug(loggingLevel.INFO,'SZX -----> ' + updateList.size());
    
    for(String recKey : updateList.keySet()){
        BT_CO_ARMS_ExportCustomerInvoice__c so  = updateList.get(recKey);
        so.Validation_Status__c = 'Failed';
        so.Validation_Details__c = 'Arms Invoice id / synonym combination not found';
        invalidRecordCount++;
    }
    
    
    
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        update invoicesForUpdate;
        //[START 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)] Removed
        //removed //insert invoicesForInsert; 
        //[END 02/16/2015 Renino Niefes Code Review (Novasuite Audit Findings)]
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug(loggingLevel.INFO,'BT_AT_ARM071DX_ExportCustomerInvoice Upsert operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }    
    
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = 'ARM071DX';
    leg2sfLog.Batch_Run_Date__c = recordsList[0].Batch_Run_Date__c;
    leg2sfLog.Total_Record_Count__c = recordsList.size();
    leg2sfLog.Valid_Record_Count__c = recordsList.size() - invalidRecordCount;
    leg2sfLog.Invalid_Record_Count__c = invalidRecordCount;
    leg2sfLog.DML_Status__c = dmlStatus;
    leg2sfLog.Error_Message__c = errorMessage;
    leg2sfLog.Stack_Trace__c = stackTrace;
    leg2sfLog.Batch_Job_Id__c = recordsList[0].Batch_Job_Id__c;
   
    insert leg2sfLog;    
	//END D-3772 Use 2nd condition in SOQL to further limit the number of records retrieved. use so.Synonym__c field.   
}