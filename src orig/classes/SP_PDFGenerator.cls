/*
 *  Created By: Accenture -  Jeffrey Teves
 *  Created Date: June 25, 2014
 *  Purpose:
 *      - Apex Class exposed as Rest Resource. This will allow getting the content of a PDF page through Batch Apex.
 *  Accepts: Id of the record to fetch the PDF from
 *  Output: Inserts PDF as attachment under the passed record Id.
 *  History: 10/02/14 Kevin Evasco - Updated to accommodate a list of parent IDs instead of a single parent record.
 *  History: 11/27/14 D-0894 Kevin Evasco - Updated to fix webservice issue for generating PDFs
 *  History: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
 *  History: 02/10/15 D-2101 Kevin Evasco - Updated to enable letter printing for CSO.
 */
 
 /* 
  * History: 20-July-2015 D-3258 Added By S.Puli - Retrofit changes from UAT to DV1 and SIT
  * History: 08-Mar-2016 UD-3253 Added By S.Puli - Changes for Credit Note Change Request
  *
  */
  
 
 
//START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
@RestResource(urlMapping='/SP_PDFGenerator/*')
global without sharing class SP_PDFGenerator //START/END 02/10/15 D-2101 Kevin Evasco - Updated to enable letter printing for CSO.
{ 
    list<exception> exceptionList = new list<exception>(); //START-END D-3826 10/28/2015 added by Jason A. for Log exception
    private static SP_PDFGeneratorResponse response;
    
    global class SP_PDFGeneratorResponse
    {
        public String failedRecordsSet;
        public String recordID_attachmentID_map;
        public String recordID_dateOfGeneration_map;
        public String recordID_filename_map;
        public String packLabelRecId_AttachmentID_Map; // START-END : D-2873 5/18/2015 Alyana Navarro
    }

    @HttpPost
    //START D-3599 10/06/2015 added by Jason A.
    global static SP_PDFGeneratorResponse insertAttachment(List<String> parentIdList, String templateName, Map<String,List<String>> letterSubTypeMap, datetime generationFrom, datetime generationTo, boolean isRecovery ) { // START-END : D-2873 5/19/2015 Alyana Navarro
        
        list<exception> exceptionList = new list<exception>();    
    //END D-3599 10/06/2015 added by Jason A.
        response = new SP_PDFGeneratorResponse();       
        Set<String> failedRecordsSet = new Set<String>();       
        Map<Id,String> recordID_attachmentID_map = new Map<Id,String>();
        Map<Id,Date> recordID_dateOfGeneration_map = new Map<Id,Date>();
        Map<Id,String> recordID_filename_map = new Map<Id,String>();
        Map<String, String> packLabelRecId_AttachmentID_Map = new Map<String, String>(); // START-END : D-2873 5/18/2015 Alyana Navarro
        Map<String, Contact> recordId_contact_map = new Map<String, Contact>(); //START/END 18 February 2016 NCR015-6 Kevin Evasco - New Filename Format
        
        String sfidPrefix = 'SFID'; //START/END 18 February 2016 NCR015-6 Kevin Evasco - New Filename Format
        // START : D-2013 3/17/2015 Alyana Navarro
        List<Account> mailingAgentAccountList = new List<Account>();
        Map<String, Id> mailingNumberMailingIdMap = new Map<String, Id>();
        // END : D-2013 3/17/2015 Alyana Navarro
//END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
    
        Map<Id,Zuora__Subscription__c> packingLabelID_subscription_map = new Map<Id,Zuora__Subscription__c>();
        //PageReference ref;
        List<Attachment> attList = new List<Attachment>();
        
        Set<String> IDSet = new Set<String>(); 
        
        //START : D-2930 5/14/2015 Alyana Navarro        
        Set<String> pubCodeSet = new Set<String>();
        List<Publication__c> publicationList = new List<Publication__c>();
        //START 22 November 2015 UD-2535 Kevin Evasco - Retrieve language from LPR 
        //List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();     
        //Map<Id, Boolean> subIdIsEnglishMap = new Map<Id, Boolean>();
        Map<Id, Letter_Print_Request__c> masterLPRMap= new Map<Id, Letter_Print_Request__c>(); 
        //END 22 November 2015 UD-2535 Kevin Evasco - Retrieve language from LPR 
        Map<Id, Set<String>> subIdPubCodeSetMap = new Map<Id, Set<String>>();
        Map<String, Publication__c> publicationMap = new Map<String, Publication__c>();
        // END : D-2930 5/14/2015 Alyana Navarro
        
    //START D-3599 10/06/2015 added by Jason A.        
        Map<String, Integer> parentIdCounterMap = new Map<String, Integer>(); // START : D-2873 5/19/2015 Alyana Navarro
        DateTime dateFrom;
        DateTime dateto;
        //START UD-2328 08/26/15 RReyes
        
        //START: UD-3505 01-11-2015 added by Jason A
        Logger logger = new Logger(SP_PDFGenerator.class.getName()); 
        Boolean isError = false;
        //END: UD-3505 01-11-2015 added by Jason A
        
        if(isRecovery){
            dateFrom = generationFrom;
            dateTo =  generationTo;
        }else{
            dateFrom = ConstantsSLB.getOtherDate('SP18_SDT1');
            dateTo = ConstantsSLB.getOtherDate('SP18_SDT2');
        }   //END UD-2328 08/26/15 RReyes 
    //END D-3599 10/06/2015 added by Jason A.
        for(String parentId : parentIdList)
        {
            IDSet.add(parentId);            
        }
        
        recordId_contact_map = getRecordIdToContactMap(IDSet, templateName); //START/END 18 February 2016 NCR015-6 Kevin Evasco - Record Id to Contact Map
        
        // START : UD-2634 9/10/2015 Alyana Navarro
        //START D-3952 Gdelrosario 19/11/15 : change variable to paymentids
        Map<String, Id> parentIdBillingAccountIdMap = new Map<String, Id>();
        if(templateName == SP_GenerateLetterPrintBatch.FAILED_PAYPAL_NOTIFICATION){
            for(External_Payment__c paymentRec : [SELECT id, name, Billing_Account__c FROM External_Payment__c WHERE Id IN: IDSet]){
                parentIdBillingAccountIdMap.put(paymentRec.id, paymentRec.id);
            }
        }
        //END D-3952 Gdelrosario 19/11/15 : change variable to paymentids
        // END : UD-2634 9/10/2015 Alyana Navarro
        

        // START : UD-1419 7/17/2015 Alyana Navarro
        // START : UD-1421 6/4/2015 Alyana Navarro      
        //List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>(); - Remove
        //Map<Id, Id> invoiceIdBillAccountIdMap = new Map<Id, Id>(); - Remove
        Map<Id, Credit_Note__c> creditNoteMap = new Map<Id, Credit_Note__c>();
        if(templateName == SP_GenerateLetterPrintBatch.creditNotes){            
        //Start UD-3253 Added by S.Puli - Credit Note CR
            //invoiceList = [SELECT id, name, Zuora__BillingAccount__c FROM Zuora__ZInvoice__c WHERE id IN: IDSet];
            
            //for(Zuora__ZInvoice__c invoice : invoiceList){
            //    invoiceIdBillAccountIdMap.put(invoice.id, invoice.Zuora__BillingAccount__c);
            //}
            //START UD-3055 08-Oct-2015 Added by S.Puli
            creditNoteMap = new Map<Id, Credit_Note__c>([SELECT id, name, Billing_Account__c, Document_Date__c FROM Credit_Note__c WHERE id IN: IDSet]);
            //END UD-3055 08-Oct-2015 Added by S.Puli
        //End UD-3253 Added by S.Puli - Credit Note CR
        }
        // END : UD-1421 6/4/2015 Alyana Navarro
        // END : UD-1419 7/17/2015 Alyana Navarro
        
        //START UD-2286 11-Aug-2015 Added By S.Puli
        Map<Id, Id> billAcctoAccId_MAP = new Map<Id, Id>();
        Map<Id, String> fileToAttachId_MAP = new Map<Id, String>();
        List<Zuora__CustomerAccount__c> billAcc_LIST = new List<Zuora__CustomerAccount__c>();
        if(templateName == SP_GenerateLetterPrintBatch.acknowledgmentLetter){
            billAcc_LIST = [Select Id, Name, Zuora__Account__c From Zuora__CustomerAccount__c Where Id In :IDSet];
            
            if(billAcc_LIST.size()>0){
                for(Zuora__CustomerAccount__c ba : billAcc_LIST){
                    billAcctoAccId_MAP.put(ba.Id, ba.Zuora__Account__c);
                }
            }
        }
        //END UD-2286 11-Aug-2015 Added By S.Puli
        
        //START 22 November 2015 UD-2535 Kevin Evasco - Get language from LPR
        
        //START : D-2930 5/14/2015 Alyana Navarro
        if(templateName == SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine 
        || templateName == SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine
        || templateName == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper
        || templateName == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper){
            List<Letter_Print_Request__c> masterLPRList = [SELECT Id, Language_Medium__c, Billing_Account__c FROM Letter_Print_Request__c
                             WHERE Id IN: IDSet];           
            for(Letter_Print_Request__c masterLPRElem : masterLPRList) {
                masterLPRMap.put(masterLPRElem.Id, masterLPRElem);
            }            
        }
        // END : D-2930 5/14/2015 Alyana Navarro        
        //END 22 November 2015 UD-2535 Kevin Evasco - Get language from LPR
        // START : D-2013 3/17/2015 Alyana Navarro
        mailingAgentAccountList = [SELECT id, name, AccountNumber FROM Account WHERE AccountNumber IN: IDSet];

        for(Account mailingAccount : mailingAgentAccountList){
            mailingNumberMailingIdMap.put(mailingAccount.AccountNumber, mailingAccount.id);
        }
        // END : D-2013 3/17/2015 Alyana Navarro
        
        //START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
        Set<Id> validRecordsIDSet = new Set<Id>(); 
        Map<Id,Id> childParentMap = new Map<Id,Id>();
        
        Map<Id,String> invoiceAndCreditNoteNumberMap = new Map<Id,String>();
        //START UD-1421 01-July-2015 Kevin Evasco - PDF Filename should display Credit Note Number for Credit Notes.
        //START UD-1514 10-June-2015 Kevin Evasco - Fixed filename for credit notes and invoice
        Map<Id,String> invoiceDueDateMap = new Map<Id,String>();
        if(templateName == SP_GenerateLetterPrintBatch.invoiceLetter) {
            for(Zuora__ZInvoice__c invoiceRec :[SELECT Id, Name, ARMS_Invoice_ID__c, Zuora__InvoiceDate__c FROM Zuora__ZInvoice__c WHERE Id IN :IDSet])
            {
                if(invoiceRec.ARMS_Invoice_ID__c != null && invoiceRec.ARMS_Invoice_ID__c != '')
                    invoiceAndCreditNoteNumberMap.put(invoiceRec.Id, invoiceRec.ARMS_Invoice_ID__c);
                else
                    invoiceAndCreditNoteNumberMap.put(invoiceRec.Id, invoiceRec.Name);
                
                String invoiceDueDateString = convertDateToString(invoiceRec.Zuora__InvoiceDate__c);
                invoiceDueDateMap.put(invoiceRec.Id,invoiceDueDateString);
            }
        }
        //END UD-1514 10-June-2015 Kevin Evasco - Fixed filename for credit notes and invoice
        //Start UD-3207 01-Apr-2016 Added By S.Puli
        Map<Id,String> dailyInvDateMap = new Map<Id,String>();
        if(templateName == SP_GenerateLetterPrintBatch.dailyInvLetter) {
            for(Daily_Invoice__c dailyInv :[SELECT Id, Name, ARMS_Invoice_ID__c, Invoice_Date__c FROM Daily_Invoice__c WHERE Id IN :IDSet])
            {
                if(dailyInv.ARMS_Invoice_ID__c != null && dailyInv.ARMS_Invoice_ID__c != '')
                    invoiceAndCreditNoteNumberMap.put(dailyInv.Id, dailyInv.ARMS_Invoice_ID__c);
                else
                    invoiceAndCreditNoteNumberMap.put(dailyInv.Id, dailyInv.Name.remove('-'));
                
                String invoiceDueDateString = convertDateToString(dailyInv.Invoice_Date__c);
                dailyInvDateMap.put(dailyInv.Id,invoiceDueDateString);
            }
        }
        //End UD-3207 01-Apr-2016 Added By S.Puli
        if(templateName == SP_GenerateLetterPrintBatch.creditNotes) {
            // START : UD-1419 7/21/2015 Alyana Navarro
        //Start UD-3253 Added by S.Puli - Credit Note CR
            for(Credit_Note__c creditNoteRec :[SELECT Id, Credit_Note_Number__c, ARMS_Number__c FROM Credit_Note__c WHERE Id IN :IDSet]) 
            {
                if(creditNoteRec.ARMS_Number__c <> null){
                    invoiceAndCreditNoteNumberMap.put(creditNoteRec.Id, '00' + String.valueOf(Integer.valueOf(creditNoteRec.Credit_Note_Number__c))); //START END D-4594 31Mar2016 Added By C. Lin - Change 0000 to 00
                }else{
                    invoiceAndCreditNoteNumberMap.put(creditNoteRec.Id, creditNoteRec.Credit_Note_Number__c.remove('-'));
                }
            }
            // END : UD-1419 7/21/2015 Alyana Navarro
        //End UD-3253 Added by S.Puli - Credit Note CR
        }

        //END UD-1421 01-July-2015 Kevin Evasco - PDF Filename should display Credit Note Number for Credit Notes.
        //END UD-1828 16-July-2015 Added by S.Puli- Change Credit_Note_Number__c from Number to Text  
        //START D-4594 01April2016 Added By C. Lin
        /*if(templateName == SP_GenerateLetterPrintBatch.overseasNewspaperWrapper || 
                templateName == SP_GenerateLetterPrintBatch.magazineInternalWrapper || 
                templateName == SP_GenerateLetterPrintBatch.airlineSubscriptionReportHardCopy || 
                templateName == SP_GenerateLetterPrintBatch.airlineSubscriptionWrapper ||
                templateName == SP_GenerateLetterPrintBatch.invoiceLetter)*/
        if(templateName == SP_GenerateLetterPrintBatch.invoiceLetter || templateName == SP_GenerateLetterPrintBatch.dailyInvLetter)//Start/End UD-3207 01-Apr-2016 Added By S.Puli
        //END D-4594 01April2016 Added By C. Lin
        {
            populateChildParentMap(IDSet, templateName, childParentMap);
        }
        //END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
        
        for(String parentId : parentIdList)
        {
            try
            {
                PageReference ref;
                //START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
                // START : D-2013 3/20/2015 Alyana Navarro
                String fileName = '';               
                //START 18 February 2016 NCR015-6 Kevin Evasco - New Filename Format to enable sortin in the on-premise
                String sfidSuffix = '';
                
                if(SP_GenerateLetterPrintBatch.letterCodeMap.containsKey(templateName)) {
                    filename += SP_GenerateLetterPrintBatch.letterCodeMap.get(templateName) + '_';
                } else {
                    filename += templateName + '_';
                }
                
                Contact billingContact = recordId_contact_map.get(parentId);
                
                if(billingContact != null) {
                filename += billingContact.Address__r.Country__r.Code__c + '_';
                
                if(billingContact.Address__r.Country__r.Code__c == 'SG')
                    filename += billingContact.Address__r.Postal_Code_Text__c + '_';
                
                filename += billingContact.Account.Account_Auto_Number__c + '_';
                }
                
                
                if(mailingNumberMailingIdMap.containsKey(parentId)){
                    sfidSuffix += sfidPrefix + mailingNumberMailingIdMap.get(parentId);
                } else {
                    sfidSuffix += sfidPrefix + parentID;
                }
                // END : D-2013 3/20/2015 Alyana Navarro
                //END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.                
                //END 18 February 2016 NCR015-6 Kevin Evasco - New Filename Format to enable sortin in the on-premise
                
                String attachToID = parentId;
                if(templateName == SP_GenerateLetterPrintBatch.acknowledgmentLetter)
                {
                    ref = Page.AcknowledgementLetter;
                }
                else if(templateName == SP_GenerateLetterPrintBatch.invoiceLetter)
                {
                    ref = Page.InvoiceTaxTemplate;
                }
                //Start UD-3207 01-Apr-2016 Added By S.Puli
                else if(templateName == SP_GenerateLetterPrintBatch.dailyInvLetter)
                {
                    ref = Page.InvoiceDailyTaxTemplate;
                }
                //End UD-3207 01-Apr-2016 Added By S.Puli
                else if(templateName == SP_GenerateLetterPrintBatch.giftLetter)
                {
                    ref = Page.LP_GiftLetterMag;
                }
                else if(templateName == SP_GenerateLetterPrintBatch.subscriptionLetter)
                {   
                    ref = Page.LP_May14GiftLetter;
                }
                else if(templateName == SP_GenerateLetterPrintBatch.giftRenewalLetter)
                {
                    ref = Page.LP_GiftLetterNTUC;
                }
                else if(templateName == SP_GenerateLetterPrintBatch.giftRedemptionLetter)
                {
                    ref = Page.LP_IPPLetter;
                }
                //START:D-2218 2/13/15 Added by Manolo Vale�a - Added new conditions that will be used by the new templates that will be created soon.
                //START: 20/03/2015 Added by Jean Cari�o for MD42
                else if(templateName == SP_GenerateLetterPrintBatch.giftPremiumChina)
                {
                    ref = Page.LP_HappyCallLetterChinese;
                }
                else if(templateName == SP_GenerateLetterPrintBatch.giftPremiumEnglish)
                {
                    ref = Page.LP_HappyCallLetter;
                }
                //END
                //END:D-2218 2/13/15 Added by Manolo Vale�a
                else if(templateName == SP_GenerateLetterPrintBatch.creditCardFailureNotification)
                {
                    ref = Page.LP_CreditCardFailure;
                }
                //START 22 November 2015 UD-2535 Kevin Evasco - Get Language from LPR
                //START : D-2930 5/14/2015 Alyana Navarro
                else if(templateName == SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine || templateName == SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine)
                {
                    Letter_Print_Request__c masterLPR = masterLPRMap.get(parentId);
                    if(masterLPR != null) {
                        if(masterLPR.Language_Medium__c == SP_RenewalReminderHelper.LANGUAGE_MEDIUM_ENGLISH){
                            ref = Page.LP_MagazineRenewal;
                        } else {
                            ref = Page.LP_MagazineRenewalChinese;
                        }
                        attachToID = masterLPR.Billing_Account__c;
                    }
                }
                else if(templateName == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper || templateName == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper)
                {
                    Letter_Print_Request__c masterLPR = masterLPRMap.get(parentId);
                    if(masterLPR != null) {
                        if(masterLPR.Language_Medium__c == SP_RenewalReminderHelper.LANGUAGE_MEDIUM_ENGLISH){
                        ref = Page.LP_NewspaperReminder;
                        } else {
                            ref = Page.LP_NewspaperChinese;
                        }
                        attachToID = masterLPR.Billing_Account__c;    
                    }
                }
                // END : D-2930 5/14/2015 Alyana Navarro
                // START 17 February 2016 NCR015-6 Kevin Evasco - Removed packing label code
                /*
                
                //END 22 November 2015 UD-2535 Kevin Evasco - Get Language from LPR
                else if(templateName == SP_GenerateLetterPrintBatch.packingLabelLetter)
                {
                // START : D-2873 5/19/2015 Alyana Navarro
                String letterSubType;
                if(parentIdCounterMap.containsKey(parentId)){
                    Integer counter = parentIdCounterMap.get(parentId);
                    letterSubType = letterSubTypeMap.get(parentId)[counter];
                    parentIdCounterMap.put(parentId, ++counter);
                } else {
                    letterSubType = letterSubTypeMap.get(parentId)[0];
                    parentIdCounterMap.put(parentId, 1);
                }
                // END : D-2873 5/19/2015 Alyana Navarro
                    if(letterSubType == SP_GenerateLetterPrintBatch.overseasNewspaperReportHardCopy)
                    {
                        ref = Page.OverseasNewspaperReportHardCopy;                     
                        attachToID = mailingNumberMailingIdMap.get(parentId); // START-END : D-2013 3/20/2015 Alyana Navarro
                    }
                    else if(letterSubType == SP_GenerateLetterPrintBatch.overseasNewspaperWrapper)
                    {
                        ref = Page.OverseasWrapper;
                    }
                    else if(letterSubType == SP_GenerateLetterPrintBatch.magazineInternalWrapper)
                    {
                        ref = Page.MagazineInternalWrapper;
                    }                   
                    else if(letterSubType == SP_GenerateLetterPrintBatch.airlineSubscriptionReportHardCopy)
                    {
                        ref = Page.ReportHardCopy; // START-END : D-2591 3/24/2015 Alyana Navarro - Change from AirlineSubscriptions to ReportHardCopy
                    }
                    else if(letterSubType == SP_GenerateLetterPrintBatch.airlineSubscriptionWrapper)
                    {
                        ref = Page.AirlineSubscriptions; // START-END : D-2591 3/24/2015 Alyana Navarro - Change from ReportHardCopy to AirlineSubscriptions
                    }
                }
                
                */
                // END 17 February 2016 NCR015-6 Kevin Evasco - Removed packing label code
                
                else if(templateName == SP_GenerateLetterPrintBatch.creditNotes)
                {
                    //START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.    
                    ref = Page.LP_CreditNote; 
                    //END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.  
                }
                // START : UD-2634 9/10/2015 Alyana Navarro
                else if(templateName == SP_GenerateLetterPrintBatch.FAILED_PAYPAL_NOTIFICATION){
                    ref = Page.LP_PaypalFailure;
                }
                // END : UD-2634 9/10/2015 Alyana Navarro
                
                //START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
                //START D-4594 01April2016 Added By C. Lin
                /*if(templateName == SP_GenerateLetterPrintBatch.overseasNewspaperWrapper || 
                templateName == SP_GenerateLetterPrintBatch.magazineInternalWrapper || 
                templateName == SP_GenerateLetterPrintBatch.airlineSubscriptionReportHardCopy || 
                templateName == SP_GenerateLetterPrintBatch.airlineSubscriptionWrapper ||
                templateName == SP_GenerateLetterPrintBatch.invoiceLetter ||
                templateName == SP_GenerateLetterPrintBatch.overseasNewspaperReportHardCopy)*/
                if(templateName == SP_GenerateLetterPrintBatch.invoiceLetter || templateName == SP_GenerateLetterPrintBatch.dailyInvLetter)//Start/End UD-3207 01-Apr-2016 Added By S.Puli
                //END D-4594 01April2016 Added By C. Lin
                {
                    ref.getParameters().put('id', parentId);     
                    // START : D-2013 3/20/2015 Alyana Navarro - Added condition for Overseas Newspaper Report hard Copy
                    //START D-4594 01April2016 Added By C. Lin
                    /*if(templateName == SP_GenerateLetterPrintBatch.overseasNewspaperReportHardCopy){                        
                        attachToID = mailingNumberMailingIdMap.get(parentId);
                    } else {*/
                        attachToID = childParentMap.get(parentId);
                    //}
                    //END D-4594 01April2016 Added By C. Lin
                    // END : D-2013 3/20/2015 Alyana Navarro
                }
                //END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename. 
                // START : UD-1419 7/17/2015 Alyana Navarro
                // START : UD-1421 6/4/2015 Alyana Navarro
                else if(templateName == SP_GenerateLetterPrintBatch.creditNotes){
                    attachToID = creditNoteMap.get(parentId).Billing_Account__c;
                    ref.getParameters().put('id', parentId);
                }
                // END : UD-1421 6/4/2015 Alyana Navarro
                // END : UD-1419 7/17/2015 Alyana Navarro
                //START UD-2286 11-Aug-2015 Added By S.Puli
                else if(templateName == SP_GenerateLetterPrintBatch.acknowledgmentLetter){
                    if(billAcctoAccId_MAP.containsKey(parentId)){
                        attachToID =  billAcctoAccId_MAP.get(parentId);
                    } else{
                        attachToID = parentId;
                    }                   
                    ref.getParameters().put('id', parentId);
    //START D-3599 10/06/2015 added by Jason A.
                    if (isRecovery){
                        ref.getParameters().put('isRecovery', string.valueof(isRecovery));
                        ref.getParameters().put('generationFrom',string.valueof(generationFrom));
                        ref.getParameters().put('generationTo', string.valueof(generationTo));
                    }
    //END D-3599 10/06/2015 added by Jason A.
                }
                //END UD-2286 11-Aug-2015 Added By S.Puli
                // START : UD-2634 9/10/2015 Alyana Navarro
                else if(templateName == SP_GenerateLetterPrintBatch.FAILED_PAYPAL_NOTIFICATION){
                    attachToID = parentIdBillingAccountIdMap.get(parentId);
                    ref.getParameters().put('id', parentId);
                }
                // END : UD-2634 9/10/2015 Alyana Navarro
        //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
                // START 17 February 2016 NCR015-6 Kevin Evasco - Removed packing label code
                /*
                else if(templateName == SP_GenerateLetterPrintBatch.packingLabelLetter)
                {
                    ref.getParameters().put('id', parentId);
                    ref.getParameters().put('issueDate', String.valueOf(generationFrom));    //Tine's change!
                }
                */
                // END 17 February 2016 NCR015-6 Kevin Evasco - Removed packing label code
                else{
                    ref.getParameters().put('id', parentId);
                }
        //END: D-3672 11/13/2015 Added by Kristine Balaoing
                //START D-4594 01April2016 Added By C. Lin
                Blob b;
                if(Test.isRunningTest()){
                    b = Blob.valueOf('Unit Test');
                }else{
                    b = ref.getContent();
                }
                //END D-4594 01April2016 Added By C. Lin
                
                //START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
        //Start UD-3253 Added by S.Puli - Credit Note CR
                if(templateName == SP_GenerateLetterPrintBatch.creditNotes)
                {
                    fileName += sfidSuffix + '_' + invoiceAndCreditNoteNumberMap.get(parentId) + '_';
                }
                else if(templateName == SP_GenerateLetterPrintBatch.invoiceLetter)
                {
                    fileName += invoiceAndCreditNoteNumberMap.get(parentId) + '_';
                }
                 //Start UD-3207 01-Apr-2016 Added By S.Puli
                else if(templateName == SP_GenerateLetterPrintBatch.dailyInvLetter)
                {
                    fileName += invoiceAndCreditNoteNumberMap.get(parentId) + '_';
                }
                //End UD-3207 01-Apr-2016 Added By S.Puli
                //START UD-1514 10-June-2015 Kevin Evasco - Fixed filename for credit notes and invoice
                //START UD-3055 08-Oct-2015 Added by S.Puli
                if(templateName == SP_GenerateLetterPrintBatch.invoiceLetter) {
                    fileName += invoiceDueDateMap.get(parentId) + '_' + sfidSuffix + '.pdf';
                }
                //Start UD-3207 01-Apr-2016 Added By S.Puli
                else if(templateName == SP_GenerateLetterPrintBatch.dailyInvLetter) {
                    fileName += dailyInvDateMap.get(parentId) + '_' + sfidSuffix + '.pdf';
                }
                //End UD-3207 01-Apr-2016 Added By S.Puli
                else if(templateName == SP_GenerateLetterPrintBatch.creditNotes){
                    
                    fileName += convertDateToString(creditNoteMap.get(parentId).Document_Date__c)+ '.pdf';
                }
                
                else {                    
                    fileName += convertDateToString(Date.Today()) + '_' + sfidSuffix + '.pdf';
                }
        //End UD-3253 Added by S.Puli - Credit Note CR
                //END UD-3055 08-Oct-2015 Added by S.Puli
                //END UD-1514 10-June-2015 Kevin Evasco - Fixed filename for credit notes and invoice
                
                Attachment att = new Attachment(
                    parentId = attachToID,
                    Name = fileName);
                    
                //START UD-2286 11-Aug-2015 Added By S.Puli
                //START D-3455 29-Aug-2015 Added By S.Puli
                if(templateName == SP_GenerateLetterPrintBatch.acknowledgmentLetter){
                    fileToAttachId_MAP.put(parentId, att.Name);
                }
                //END D-3455 29-Aug-2015 Added By S.Puli
                //END UD-2286 11-Aug-2015 Added By S.Puli
                
                //END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
                
                att.body = b;
                attList.add(att);
            }
            //START D-3826 10/28/2015 added by Jason A. for Log exception
            catch(Exception e)
            {
                failedRecordsSet.add(parentId);
                System.debug('Error Message Failed Record: ' + e.getMessage());
                exceptionList.add(e);
            }
            ExceptionLogger.log(exceptionList);
            //END D-3826 10/28/2015 added by Jason A. for Log exception
        }
        
        //START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
        //START D-2116 03/19/2015 Added by S.Puli
        Set<Id> accountId = new Set<Id>();
        List<Account> accAckList = new List<Account>();     
        Map<Id, Id> accToAttachment_MAP = new Map<Id, Id>();
        //START UD-2286 11-Aug-2015 Added By S.Puli
        Map<String, Id> attachNameToId_MAP = new Map<String, Id>();
        //END UD-2286 11-Aug-2015 Added By S.Puli
        //END D-2116 03/19/2015 Added by S.Puli
        parentIdCounterMap = new Map<String, Integer>(); // START-END : D-2873 5/19/2015 Alyana Navarro
        String errorMessage = ''; //START-END: UD-3505 01-08-2015 added by Jason A
        if(attList.size() > 0) {
            List<Database.SaveResult> saveResults = Database.insert(attList, false);            
            for(Integer i=0;i<saveResults.size();i++)
            {
                errorMessage = ''; //START-END: UD-3505 01-08-2015 added by Jason A
                Attachment attachmentRecord = attList.get(i);
                //START 19 February 2016 NCR015-6 Kevin Evasco - New Filename Format
                String attachmentName = attachmentRecord.Name;
                Integer startIndex = attachmentName.indexOf(sfidPrefix) + sfidPrefix.length();
                Integer endIndex = startIndex + 15;
                Id recordId = (Id)attachmentName.substring(startIndex, endIndex);
                //END 19 February 2016 NCR015-6 Kevin Evasco - New Filename Format
            // START : D-2873 5/19/2015 Alyana Navarro  
                String letterSubType;
                //START 17 February 2016 NCR015-6 Kevin Evasco - Removed packing label code
                /*
                if(templateName == SP_GenerateLetterPrintBatch.packingLabelLetter){
                    if(letterSubTypeMap.containsKey(attachmentRecord.ParentId)){
                        if(parentIdCounterMap.containsKey(attachmentRecord.ParentId)) {
                            Integer counter = parentIdCounterMap.get(attachmentRecord.ParentId);
                            letterSubType = letterSubTypeMap.get(attachmentRecord.ParentId)[counter];
                            parentIdCounterMap.put(attachmentRecord.ParentId, ++counter);
                        } else {
                            letterSubType = letterSubTypeMap.get(attachmentRecord.ParentId)[0];
                            parentIdCounterMap.put(attachmentRecord.ParentId, 1);
                        }
                    }
                }
                */
                //END 17 February 2016 NCR015-6 Kevin Evasco - Removed packing label code
            // END : D-2873 5/19/2015 Alyana Navarro
                //START: UD-3505 01-08-2015 added by Jason A
                if (!saveResults.get(i).isSuccess())
                {
                    
                    for(Database.Error err : saveResults.get(i).getErrors()) 
                    {
                         errorMessage += '* ' + err.getMessage() + '\n';
                        System.debug('Error Message: ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                    
                    //START D-4594 01April2016 Added By C. Lin
                    /*if(templateName == SP_GenerateLetterPrintBatch.overseasNewspaperWrapper || 
                        templateName == SP_GenerateLetterPrintBatch.magazineInternalWrapper || 
                        templateName == SP_GenerateLetterPrintBatch.airlineSubscriptionReportHardCopy || 
                        templateName == SP_GenerateLetterPrintBatch.airlineSubscriptionWrapper ||
                        templateName == SP_GenerateLetterPrintBatch.invoiceLetter)*/
                    if(templateName == SP_GenerateLetterPrintBatch.invoiceLetter || templateName == SP_GenerateLetterPrintBatch.dailyInvLetter)//Start UD-3207 01-Apr-2016 Added By S.Puli
                    //END D-4594 01April2016 Added By C. Lin
                    {
                        failedRecordsSet.add(recordId);
                        logger.log(true, errorMessage, recordId);
                        isError = true;
                    }
                    else
                    {
                        failedRecordsSet.add(attachmentRecord.ParentId);
                        logger.log(true, errorMessage, attachmentRecord.ParentId);
                        isError = true;
                    }
                    //END: UD-3505 01-08-2015 added by Jason A                    
                }
                else
                {   
                    //START D-2116 03/19/2015 Added by S.Puli
                    if(templateName == SP_GenerateLetterPrintBatch.acknowledgmentLetter){
                        accountId.add(attachmentRecord.ParentId);
                        accToAttachment_MAP.put(attachmentRecord.ParentId, attachmentRecord.Id);
                        //START UD-2286 11-Aug-2015 Added By S.Puli
                        attachNameToId_MAP.put(attachmentRecord.Name, attachmentRecord.Id);
                        //END UD-2286 11-Aug-2015 Added By S.Puli
                    }
                    //END D-2116 03/19/2015 Added by S.Puli
                    // START : D-2873 5/19/2015 Alyana Navarro - Remove commented out code.
                    /*//START D-4594  01April2016 Added By C. Lin
                    if(templateName == SP_GenerateLetterPrintBatch.overseasNewspaperWrapper || 
                        templateName == SP_GenerateLetterPrintBatch.magazineInternalWrapper ||                         
                        /*templateName == SP_GenerateLetterPrintBatch.airlineSubscriptionReportHardCopy || 
                        templateName == SP_GenerateLetterPrintBatch.airlineSubscriptionWrapper ||*/
                    /*    templateName == SP_GenerateLetterPrintBatch.invoiceLetter) {
                        validRecordsIDSet.add(recordId);
                        recordID_attachmentID_map.put(recordId, (String)attachmentRecord.Id);   
                    } else if(letterSubType == SP_GenerateLetterPrintBatch.airlineSubscriptionReportHardCopy || 
                                letterSubType == SP_GenerateLetterPrintBatch.airlineSubscriptionWrapper){
                        validRecordsIDSet.add(recordId);
                        packLabelRecId_AttachmentID_Map.put(attachmentRecord.ParentId + '-' + letterSubType, (String)attachmentRecord.Id); // START-END : D-2873 5/18/2015 Alyana Navarro                                           
                    } else { //END D-4594 01April2016 Added By C. Lin*/
                    // END : D-2873 5/19/2015 Alyana Navarro
                        validRecordsIDSet.add(attachmentRecord.ParentId);
                        recordID_attachmentID_map.put(recordId, (String)attachmentRecord.Id);
                    //} //START END D-4594 01April2016 Added By C. Lin
                    recordID_dateOfGeneration_map.put(recordId, Date.today());
                    recordID_filename_map.put(recordId,attachmentRecord.Name);                  
                }
            }
        }
        
        //START D-2116 03/19/2015 Added by S.Puli
        //START: D-3724 10/16 Added by Jason A.
        List<Zuora__Subscription__c> subsAckList = new List<Zuora__Subscription__c>();
        List<Zuora__Subscription__c> subsAckListUpdated = new List<Zuora__Subscription__c>();
        if(accountId.size()>0 && accountId<>null){
            accAckList = [Select Id, Name From Account Where Id IN :accountId];
            //START UD-2286 11-Aug-2015 Added By S.Puli
            //START UD-2328 08/26/15 RReyes - replaced DTL_Date__c condition with CreatedDate
            //START: D-3807 10/22 added by Jason A.
            subsAckList = [Select Id, Name, Zuora__Account__c, Order_Number_1__r.DTL_Date__c, Acknowledgement_Letter__c, Zuora__CustomerAccount__c, CreatedDate, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Zuora__TermSettingType__c from Zuora__Subscription__c Where Zuora__Account__c IN :accountId AND (CreatedDate >: dateFrom AND CreatedDate <=: dateTo)];
            //END: D-3807 10/22 added by Jason A.
            //END UD-2328 08/26/15 RReyes - replaced DTL_Date__c condition with CreatedDate
            if(subsAckList.size()>0 && accAckList.size()>0 && subsAckList <> null && accAckList.size() <> null){
                for(Zuora__CustomerAccount__c bac : billAcc_LIST){
                    for(Zuora__Subscription__c subRec : subsAckList){
                        if(subRec.Zuora__CustomerAccount__c == bac.Id && (subRec.CreatedDate > dateFrom && subRec.CreatedDate <= dateTo)){//START /END UD-2328 08/26/15 RReyes - replaced DTL_Date__c condition with CreatedDate
                            //START PD-0186 24May2016 Added By C. Lin - Update condition to exclude subscriptions with deleted status
                            if(subRec.Zuora__SubscriptionEndDate__c > subRec.Zuora__SubscriptionStartDate__c || (subRec.Zuora__TermSettingType__c == 'EVERGREEN' && subRec.Zuora__SubscriptionEndDate__c == null)){ //START - END: D-3807 10/22 added by Jason A.
                            //END PD-0186 24May2016 Added By C. Lin
                                subRec.Acknowledgement_Letter__c = URL.getSalesforceBaseUrl().toExternalForm()  + '/servlet/servlet.FileDownload?file=' + attachNameToId_MAP.get(fileToAttachId_MAP.get(bac.Id));
                                subsAckListUpdated.add(subRec);
                            }
            //END UD-2286 11-Aug-2015 Added By S.Puli
                        }
                    }
                }
            }
        
        }
        //END: D-3724 10/16 Added by Jason A.
        //START:UD-2845 9/23/15 Added by Manolo Valena
        SubscriptionTriggerHandler.preventExecution = TRUE;
        //END:UD-2845 9/23/15 Added by Manolo Valena 
    //START D-3599 10/06/2015 added by Jason A.
    
        //START: UD-3505 01-08-2015 added by Jason A
        try{
            update subsAckListUpdated;
        } catch(Exception e){
            logger.logBatchFailure(e, subsAckListUpdated);
            system.debug('StackTrace>>>>> ' + e.getStackTraceString() + 'Message>>>>> ' + e.getMessage() + 'Line Number>>>>> ' + e.getLineNumber());
            exceptionList.add(e);
        }
        ExceptionLogger.log(exceptionList); 
    //END D-3599 10/06/2015 added by Jason A.
        //END D-2116 03/19/2015 Added by S.Puli
        
        if(isError){
            logger.save();
        }
        //END: UD-3505 01-08-2015 added by Jason A
        response.failedRecordsSet = JSON.serialize(failedRecordsSet);
        response.recordID_attachmentID_map = JSON.serialize(recordID_attachmentID_map);     
        response.recordID_dateOfGeneration_map = JSON.serialize(recordID_dateOfGeneration_map);     
        response.recordID_filename_map = JSON.serialize(recordID_filename_map);
        response.packLabelRecId_AttachmentID_Map = JSON.serialize(packLabelRecId_AttachmentID_Map); // START-END : D-2873 5/18/2015 Alyana Navarro
        //END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
        
        return response;
    }
   
    //START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
    public static void populateChildParentMap(Set<String> IDSet, String templateName, Map<Id,Id> childParentMap)
    {
        //START 17 February 2016 NCR015-6 Kevin Evasco - Removed packing label code
        /*//START D-4594 01April2016 Added By C. Lin
        if(templateName == SP_GenerateLetterPrintBatch.overseasNewspaperWrapper || 
                templateName == SP_GenerateLetterPrintBatch.magazineInternalWrapper || 
                templateName == SP_GenerateLetterPrintBatch.airlineSubscriptionReportHardCopy || 
                templateName == SP_GenerateLetterPrintBatch.airlineSubscriptionWrapper )
        {       
        //END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
            //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
            Set<String> accountNumberSet = new Set<String>();
            Map<String,String> accountNumber_packingLabelId_map = new Map<String,String>();
            if (IDSet.size() > 0) { 
                List<Packing_Label_Batch__c> packingLabelList = [SELECT Id, Subscriber_Account_Number__c FROM Packing_Label_Batch__c WHERE ID IN :IDSet];
                for(Packing_Label_Batch__c packingLabel : packingLabelList)
                {
                        accountNumberSet.add(packingLabel.Subscriber_Account_Number__c);
                        accountNumber_packingLabelId_map.put(packingLabel.Subscriber_Account_Number__c, packingLabel.Id);
                }
            } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
            
            //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
            if (accountNumberSet.size() > 0) {
                List<Account> accountList = [SELECT Id, AccountNumber, RecordType.Name, Airline_Indicator__c FROM Account WHERE AccountNumber IN :accountNumberSet];
                
                for(Account accountRec : accountList)
                {
                    childParentMap.put(accountNumber_packingLabelId_map.get(accountRec.AccountNumber), accountRec.Id);
                } 
            } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
        }
        //END 17 February 2016 NCR015-6 Kevin Evasco - Removed packing label code
        //START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
        else //END D-4594 01April2016 Added By C. Lin */
        if(templateName == SP_GenerateLetterPrintBatch.invoiceLetter)
        {
            //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
            if (IDSet.size() > 0) {
                List<Zuora__ZInvoice__c> invoiceList = [SELECT Id, Zuora__BillingAccount__c FROM Zuora__ZInvoice__c WHERE ID IN :IDSet];
                
                for(Zuora__ZInvoice__c invoiceRec : invoiceList)
                {
                    childParentMap.put(invoiceRec.Id, invoiceRec.Zuora__BillingAccount__c);
                }
            } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
        }       
        //END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
        //Start UD-3207 01-Apr-2016 Added By S.Puli
        else if(templateName == SP_GenerateLetterPrintBatch.dailyInvLetter)
        {
            //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
            if (IDSet.size() > 0) {
                List<Daily_Invoice__c> invoiceDailyList = [SELECT Id, Billing_Account__c FROM Daily_Invoice__c WHERE ID IN :IDSet];
                
                for(Daily_Invoice__c invDailyRec : invoiceDailyList)
                {
                    childParentMap.put(invDailyRec.Id, invDailyRec.Billing_Account__c);
                }
            } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
        }
        //End UD-3207 01-Apr-2016 Added By S.Puli
    }
    //START UD-1514 10-June-2015 Kevin Evasco - Fixed filename for credit notes and invoice
    public static String convertDateToString(Date dateValue) {
        Integer day = dateValue.day();
        Integer month = dateValue.month();
        Integer year= dateValue.year();
        
        String dayString;
        String monthString;
        String yearString = String.valueOf(year);
        
        if(day<10)
            dayString = '0' + String.valueOf(day);
        else
            dayString = String.valueOf(day);
        
        if(month<10)
            monthString = '0' + String.valueOf(month);
        else
            monthString = String.valueOf(month);
        
        String dateString = yearString + '' + monthString + '' + dayString;
        
        return dateString;
    }
    //START UD-1514 10-June-2015 Kevin Evasco - Fixed filename for credit notes and invoice
    
    //START 18 February 2016 NCR015-6 Kevin Evasco - Map of LPR Record Id to Billing Contact (Letter Recipient)
    public static Map<String,Contact> getRecordIdToContactMap(Set<String> recordIdSetParam, String templateName) {

        Map<String,Contact> parentIdToContactMap = new Map<String,Contact>();   
        Map<String, Id> recordId_billingContactId = new Map<String, Id>();  
        
        Set<Id> billingContactIdSet = new Set<Id>();
        
        if(templateName == SP_GenerateLetterPrintBatch.acknowledgmentLetter){
            List<Zuora__CustomerAccount__c> baList = [SELECT Id, Billing_Contact__c FROM Zuora__CustomerAccount__c WHERE Id IN :recordIdSetParam];
            for(Zuora__CustomerAccount__c baElem : baList) {
                billingContactIdSet.add(baElem.Billing_Contact__c);
                recordId_billingContactId.put(baElem.Id, baElem.Billing_Contact__c);
            }
            
        } else if(templateName == SP_GenerateLetterPrintBatch.invoiceLetter){
            List<Zuora__ZInvoice__c> invoiceList = [SELECT Id, Zuora__BillingAccount__r.Billing_Contact__c FROM Zuora__ZInvoice__c WHERE Id IN :recordIdSetParam];
            for(Zuora__ZInvoice__c invoiceElem : invoiceList) {
                billingContactIdSet.add(invoiceElem.Zuora__BillingAccount__r.Billing_Contact__c);
                recordId_billingContactId.put(invoiceElem.Id, invoiceElem.Zuora__BillingAccount__r.Billing_Contact__c);
            }   
        //Start UD-3207 01-Apr-2016 Added By S.Puli    
        } else if(templateName == SP_GenerateLetterPrintBatch.dailyInvLetter){
            List<Daily_Invoice__c> dailyInvoiceList = [SELECT Id, Billing_Account__r.Billing_Contact__c FROM Daily_Invoice__c WHERE Id IN :recordIdSetParam];
            for(Daily_Invoice__c dailyInv : dailyInvoiceList) {
                billingContactIdSet.add(dailyInv.Billing_Account__r.Billing_Contact__c);
                recordId_billingContactId.put(dailyInv.Id, dailyInv.Billing_Account__r.Billing_Contact__c);
            }   
            
        } else if(templateName == SP_GenerateLetterPrintBatch.creditNotes){
        //END UD-3207 01-Apr-2016 Added By S.Puli
            List<Credit_Note__c> creditNoteList = [SELECT Id, Billing_Account__r.Billing_Contact__c FROM Credit_Note__c WHERE Id IN :recordIdSetParam];
            for(Credit_Note__c creditNoteElem : creditNoteList) {
                billingContactIdSet.add(creditNoteElem.Billing_Account__r.Billing_Contact__c);
                recordId_billingContactId.put(creditNoteElem.Id, creditNoteElem.Billing_Account__r.Billing_Contact__c);
            }
            
        } else if(templateName == SP_GenerateLetterPrintBatch.creditCardFailureNotification){
            List<External_Payment__c> externalPaymentList = [SELECT Id, Billing_Account__r.Billing_Contact__c FROM External_Payment__c WHERE Id IN :recordIdSetParam];
            for(External_Payment__c externalPaymentElem : externalPaymentList) {
                billingContactIdSet.add(externalPaymentElem.Billing_Account__r.Billing_Contact__c);
                recordId_billingContactId.put(externalPaymentElem.Id, externalPaymentElem.Billing_Account__r.Billing_Contact__c);
            }
            
        } else if(  templateName == SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper ||
                    templateName == SP_GenerateLetterPrintBatch.secondRenewalReminderForNewspaper ||
                    templateName == SP_GenerateLetterPrintBatch.firstRenewalReminderForMagazine ||
                    templateName == SP_GenerateLetterPrintBatch.secondRenewalReminderForMagazine) {
            List<Letter_Print_Request__c> lprList = [SELECT Id, Billing_Account__r.Billing_Contact__c FROM Letter_Print_Request__c WHERE Id IN :recordIdSetParam];
            for(Letter_Print_Request__c lprElem : lprList) {
                billingContactIdSet.add(lprElem.Billing_Account__r.Billing_Contact__c);
                recordId_billingContactId.put(lprElem.Id, lprElem.Billing_Account__r.Billing_Contact__c);
            }
            
        } else if(  templateName == SP_GenerateLetterPrintBatch.giftLetter ||
                    templateName == SP_GenerateLetterPrintBatch.subscriptionLetter ||
                    templateName == SP_GenerateLetterPrintBatch.giftRenewalLetter ||
                    templateName == SP_GenerateLetterPrintBatch.giftRedemptionLetter ||
                    templateName == SP_GenerateLetterPrintBatch.giftPremiumChina ||
                    templateName == SP_GenerateLetterPrintBatch.giftPremiumEnglish ) {
            List<Order_Line_Item_Gift__c> oligList = [SELECT Id, Order_Line_Item__r.Order__r.Billing_Contact__c FROM Order_Line_Item_Gift__c WHERE Id IN :recordIdSetParam];
            for(Order_Line_Item_Gift__c oligElem : oligList) {
                billingContactIdSet.add(oligElem.Order_Line_Item__r.Order__r.Billing_Contact__c);
                recordId_billingContactId.put(oligElem.Id, oligElem.Order_Line_Item__r.Order__r.Billing_Contact__c);
            }
        }
        
        List<Contact> contactList = [SELECT Id, Address__r.Country__r.Code__c, Address__r.Postal_Code_Text__c, Account.Account_Auto_Number__c FROM Contact WHERE Id IN :billingContactIdSet];
        Map<Id,Contact> contactMap = new Map<Id,Contact> (contactList);
        
        for(String recordId : recordIdSetParam) {
            String billingContactId;        
            if(recordId_billingContactId.containsKey(recordId)){
                billingContactId = recordId_billingContactId.get(recordId);         
                if(contactMap.containsKey(billingContactId)){               
                    parentIdToContactMap.put(recordId,contactMap.get(billingContactId));
                }
            }
        }
        
        return parentIdToContactMap;
    }
    //END 18 February 2016 NCR015-6 Kevin Evasco - Map of LPR Record Id to Billing Contact (Letter Recipient)
}