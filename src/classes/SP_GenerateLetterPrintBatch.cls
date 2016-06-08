/*
 * Class Name: SP_GenerateLetterPrintBatch
 * @author: Kevin H. Evasco
 * Date: 11/04/2014
 * Project/Requirement: Letter Printing
 * @description This class generates Letter Prints for Subscribers.
 * 
 * History: 11/04/2014 Kevin Evasco Created Apex Batch
 * History: 11/27/2014 D-0894 Kevin Evasco Updated to to implement webservice approach for PDF Generator
 * History: 12/02/2014 D-0906, D-0907, D-0908, D-0909, D-0849, D-0900, D-0901, D-0902, D-0903, D-0904, D-0910 Kevin Evasco Updated to include Session ID
 * History: 11/14/2014 D-1716 Updated to include date of generation and invoice/credit note # in the filename.
 * History: 11/22/2014 D-1716 Updated to replace spaces with underscores for letter template names.
 * History: 02/02/2015 D-1990 and D-1991 Kevin Evasco - Added error handling for issues related to JSON Parses and Read Timed Out
 * History: 02/10/2015 D-2101 Kevin Evasco - Updated to enable letter printing for CSO.
 * History: 08-Mar-2016 UD-3253 Added By S.Puli - changes for Credit Note CR
 */

global class SP_GenerateLetterPrintBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    String letterType;
    Integer batchCount;
    Integer batchSize;
    String sessionId;
    Integer letterPrintRequestCount; //START/END 04/15/2015 D-2740 Kevin Evasco - Dynamic Number of Parallel Jobs for Infoprint
    Boolean islprequestfailed = True; //START/END D-4482 14-Mar-2016 Added by Raviteja - Capturing if any letter print request failed
      
    public static final String newValue = 'New';
    public static final String processingValue = 'Processing';
    public static final String successValue = 'Successful';
    public static final String failedValue = 'Failed';
  
  //START 11/22/2014 D-1716 Updated to replace spaces with underscores for letter template names.
    public static final String packingLabelLetter = 'Packing_Label_Letter';
    public static final String acknowledgmentLetter = 'Acknowledgment_Letter';
    public static final String invoiceLetter = 'Invoice_Letter';
    //Start UD-3207 26-Mar-2016 Added by S.Puli
    public static final String dailyInvLetter = 'Daily_Inv_Letter';
    //End UD-3207 26-Mar-2016 Added by S.Puli
  
    //START:D-2218 2/13/15 Added by Manolo Vale?a - Updated existing variables with new and correct values and added Premium China and Premium English which will be new templates to be added.
    //START UD-3181 2/11/2015 Gdelrosario : removed the special characters like slash and parenthesis because integ server cannot pickup filename
    public static final String giftLetter = 'Gift_SPHM_Eng';
    public static final String subscriptionLetter = 'Gift_SPH_Mag_without_Date_Eng';
    public static final String giftRenewalLetter = 'Gift_Retention_Eng';
    public static final String giftRedemptionLetter = 'Gift_IPP_Eng';
    public static final String giftPremiumChina = 'Gift_Premium_Chi';
    public static final String giftPremiumEnglish = 'Gift_Premium_Eng';
    //END UD-3181 2/11/2015 Gdelrosario : removed the special characters like slash and parenthesis because integ server cannot pickup filename
    //END:D-2218 2/13/15 Added by Manolo Vale?a
  
    public static final String creditCardFailureNotification = 'Credit_Card_Failure_Notification';
    public static final String firstRenewalReminderForMagazine = 'First_Renewal_Reminder_for_Magazine';
    public static final String secondRenewalReminderForMagazine = 'Second_Renewal_Reminder_for_Magazine';
    public static final String firstRenewalReminderForNewspaper = 'First_Renewal_Reminder_for_Newspaper';
    public static final String secondRenewalReminderForNewspaper = 'Second_Renewal_Reminder_for_Newspaper';
    public static final String creditNotes = 'Credit_Notes';    
    public static final String overseasNewspaperReportHardCopy = 'Overseas_Newspaper_Report_Hard_Copy';   
    public static final String overseasNewspaperWrapper = 'Overseas_Newspaper_Wrapper';   
    public static final String magazineInternalWrapper = 'Magazine_Internal_Wrapper';
    public static final String airlineSubscriptionReportHardCopy = 'Airline_Subscription_Report_Hard_Copy';
    public static final String airlineSubscriptionWrapper = 'Airline_Subscription_Wrapper';
  //END 11/22/2014 D-1716 Updated to replace spaces with underscores for letter template names.
    
    public static final String FAILED_PAYPAL_NOTIFICATION = 'PayPal_Failure_Notification'; // START-END : UD-2634 9/10/2015 Alyana Navarro
    
    //START 18 February 2016 NCR015-6 Kevin Evasco - Letter Code Map
    public static Map<String,String> letterCodeMap = new Map<String,String>();
    static 
    {       
        letterCodeMap.put(acknowledgmentLetter, 'ACK');
        letterCodeMap.put(invoiceLetter, 'INV');
        letterCodeMap.put(creditNotes, 'CRN');
        letterCodeMap.put(creditCardFailureNotification, 'CCF');
        letterCodeMap.put(firstRenewalReminderForNewspaper, 'RNWNP');
        letterCodeMap.put(secondRenewalReminderForNewspaper, 'REN2NRMDNP');
        letterCodeMap.put(firstRenewalReminderForMagazine, 'REN1MRNWMAG');
        letterCodeMap.put(secondRenewalReminderForMagazine, 'REN2MRMDMAG');
        letterCodeMap.put(giftLetter, 'GFTME');
        letterCodeMap.put(subscriptionLetter, 'GFTMWDE');
        letterCodeMap.put(giftRenewalLetter, 'GFTRE');
        letterCodeMap.put(giftRedemptionLetter, 'GFTIPPE');
        letterCodeMap.put(giftPremiumChina, 'GFTPC');
        letterCodeMap.put(giftPremiumEnglish, 'GFTPE');
        //Start UD-3207 01-Apr-2016 Added By S.Puli
        letterCodeMap.put(dailyInvLetter, 'INV');
        //End UD-3207 01-Apr-2016 Added By S.Puli
    }
    //END 18 February 2016 NCR015-6 Kevin Evasco - Letter Code Map
    
    public static final String activeValue = 'Active';
    public static final String completedValue = 'Completed';
    
    //START UD-2328 08/26/2015 RReyes
    public DateTime dateFrom;
    public DateTime dateTo;
    String strBatch = '';
    Integer intBatch = 0;
    Boolean hasError;
    //END UD-2328 08/26/2015 RReyes
    //START D-3599 10/06/2015 added by Jason A. 
    public Set<Id> lprIdSet = new Set<Id>();
    Boolean isRecovery = false;
    //END D-3599 10/06/2015 added by Jason A.
    public List<Zuora__ZInvoice__c> invoiceFinalList = new List<Zuora__ZInvoice__c>(); // START-END : UD-2371 8/20/2015 Alyana Navarro
    public List<Daily_Invoice__c> dailyInvList = new List<Daily_Invoice__c>();//Start/End UD-3207 01-Apr-2016 Added By S.Puli
    /*
    global SP_GenerateLetterPrintBatch(String letterType, Integer batchCount)
    {
        this.letterType = letterType;
        this.batchCount = batchCount;
    }*/
    
    global SP_GenerateLetterPrintBatch(String letterType, Integer batchCount, String sessionId)
    {
        this.letterType = letterType;
        this.batchCount = batchCount;
        this.sessionId = sessionId;
    }
    //START 04/15/2015 D-2740 Kevin Evasco - Dynamic Number of Parallel Jobs for Infoprint
    global SP_GenerateLetterPrintBatch(String letterType, Integer batchCount, String sessionId, Integer letterPrintRequestCount)
    {
        this.letterType = letterType;
        this.batchCount = batchCount;
        this.sessionId = sessionId;
        this.letterPrintRequestCount = letterPrintRequestCount;
    }
    //END 04/15/2015 D-2740 Kevin Evasco - Dynamic Number of Parallel Jobs for Infoprint
    //START D-3599 10/06/2015 added by Jason A.
    global SP_GenerateLetterPrintBatch (Set<Id> lprID, String letterType, Integer batchCount, String sessionId ){
        this.isRecovery = true;
        this.lprIdSet = lprID;
        this.letterType = letterType;
        this.batchCount = batchCount;
        this.sessionId = sessionId; 
    //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery 
        if(letterType == 'Packing_Label_Letter'){
            this.isRecovery = false;    
        }
    //END: D-3672 11/13/2015 Added by Kristine Balaoing
    }
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext bc)
    {   
        if(isRecovery == false){
            //START UD-2328 08/26/15 RReyes
            strBatch = ConstantsSLB.getOther('SP18_InitializedBatch');
            hasError = false;
            if(strBatch <> null || strBatch <> ''){
                intBatch = Integer.valueOf(strBatch);
            }
            if(intBatch > 1){
                dateFrom = ConstantsSLB.getOtherDate('SP18_SDT1');
                dateTo = ConstantsSLB.getOtherDate('SP18_SDT2');
            }else{
                dateFrom = ConstantsSLB.getOtherDate('SP18_SDT2');
                dateTo = DateTime.Now();
            }
            //END UD-2328 08/26/15 RReyes
            
            // START Code Review 2/18/2015 Jean Cari�o
            List<Letter_Print_Batch__c> letterPrintBatchList;
            if(letterType != null){
                letterPrintBatchList = [SELECT Id, Letter_Type__c, Initialization_Status__c, Initialized_Batches__c, Total_Record_Count__c, Total_Batch_Count__c, Subset_Batch_Size__c FROM Letter_Print_Batch__c WHERE Initialization_Status__c = :activeValue AND Letter_Type__c = :letterType];
            }
            // END Code Review 2/18/2015 Jean Cari�o 
            
            Letter_Print_Batch__c letterPrintBatch;
            
            if(letterPrintBatchList.size() == 0)
            {   
                // START Code Review 2/18/2015 Jean Cari�o
                Integer printableLetterTotalCount;
                if(letterType != null){
                    // START D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                    String datString = String.valueOf(Date.today());     
                    //START 04/15/2015 D-2740 Kevin Evasco - Dynamic Number of Parallel Jobs for Infoprint
                    if(letterPrintRequestCount != null) {
                        printableLetterTotalCount = letterPrintRequestCount;
                    }
                    else {
                        if(letterType == 'Acknowledgment_Letter'){ // START-END : UD-0682 4/8/2015 Jean Cari�o
                            printableLetterTotalCount = [SELECT COUNT() FROM Letter_Print_Request__c WHERE Status__c = :newValue AND Letter_Type__c = :letterType AND (Sub_Created_Date__c >: dateFrom AND Sub_Created_Date__c <=:dateTo)]; //START/END UD-2328 08/26/15 RReyes - replaced DTL_Date__c condition with Sub_Created_Date__c 
                        } else {
                        // END D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                            printableLetterTotalCount = [SELECT COUNT() FROM Letter_Print_Request__c WHERE Status__c = :newValue AND Letter_Type__c = :letterType];
                        }// START/END D-2116 03/12/2015 Added by S.Puli - passing of dtl date
                    }
                    //END 04/15/2015 D-2740 Kevin Evasco - Dynamic Number of Parallel Jobs for Infoprint
                }
                // END Code Review 2/18/2015 Jean Cari�o
                
                letterPrintBatch = new Letter_Print_Batch__c();
                letterPrintBatch.Letter_Type__c = letterType;
                letterPrintBatch.Initialization_Status__c = activeValue;
                letterPrintBatch.Initialized_Batches__c = 1;            
                letterPrintBatch.Total_Record_Count__c = printableLetterTotalCount;
                letterPrintBatch.Total_Batch_Count__c = batchCount;
                Decimal roundedDecimal = (1.0 * printableLetterTotalCount/ batchCount).round(System.RoundingMode.CEILING);
                batchSize = Integer.valueOf(roundedDecimal);
                insert letterPrintBatch;
                
                letterPrintBatchList = [SELECT Id, Letter_Type__c, Initialization_Status__c, Initialized_Batches__c, Total_Record_Count__c, Total_Batch_Count__c, Subset_Batch_Size__c FROM Letter_Print_Batch__c WHERE Id = :letterPrintBatch.Id];
            }
            else
            {
                letterPrintBatch = letterPrintBatchList.get(0);
                letterPrintBatch.Initialized_Batches__c = letterPrintBatch.Initialized_Batches__c + 1;
                
                //START UD-2328 18-Aug-2015 Added By S.Puli - if an acknowledgement letter is on the last batch run, it will get all new LPR to avoid expiration of DTL date
                Integer remainingAckLPR;
                if(letterType == 'Acknowledgment_Letter'){
                    if(letterPrintBatch.Initialized_Batches__c == 5){
                        remainingAckLPR = [SELECT COUNT() FROM Letter_Print_Request__c WHERE Status__c = :newValue AND Letter_Type__c = :letterType AND (Sub_Created_Date__c >: dateFrom AND Sub_Created_Date__c <=:dateTo )];//START/END UD-2328 08/26/15 RReyes - replaced DTL_Date__c condition with Sub_Created_Date__c 
                    }
                    
                    if(letterPrintBatch.Initialized_Batches__c == letterPrintBatch.Total_Batch_Count__c)
                    {
                        letterPrintBatch.Initialization_Status__c = completedValue;
                    }
                    
                } else{
                
                    if(letterPrintBatch.Initialized_Batches__c == letterPrintBatch.Total_Batch_Count__c)
                    {
                        letterPrintBatch.Initialization_Status__c = completedValue;
                    }
                }
                //END UD-2328 18-Aug-2015 Added By S.Puli 
                
                Decimal roundedDecimal = (1.0 * letterPrintBatch.Total_Record_Count__c/ batchCount).round(System.RoundingMode.CEILING);        
                //START UD-2328 18-Aug-2015 Added By S.Puli 
                if(letterType == 'Acknowledgment_Letter' && letterPrintBatch.Initialized_Batches__c == 5){
                    batchSize = remainingAckLPR;
                }else{
                    batchSize = Integer.valueOf(roundedDecimal);
                }
                //END UD-2328 18-Aug-2015 Added By S.Puli 
                update letterPrintBatch;
            }
            
            // START Code Review 2/18/2015 Jean Cari�o
            List<Letter_Print_Request__c> letterPrintRequestList;
            List<Letter_Print_Request__c> latestLetterPrintRequest;
            if(letterType != null){
                // START : UD-0682 4/9/2015 Jean Cari�o
                //START UD-2014 Added By S.Puli - filter acknowledgement letter not inlcuding EMAIL reference
                if(letterType == 'Acknowledgment_Letter'){
                    //START UD-2328 08/26/15 RReyes - replaced DTL_Date__c condition with Sub_Created_Date__c 
                    letterPrintRequestList = [SELECT Id, Status__c, Record_ID__c, Letter_Type__c, DTL_Date__c,Acknowledgment_Type__c,Generation_From__c, Generation_To__c, Sub_Created_Date__c
                                              FROM Letter_Print_Request__c 
                                              WHERE (Sub_Created_Date__c >: dateFrom AND Sub_Created_Date__c <=:dateTo) 
                                              AND Status__c = :newValue AND Letter_Type__c = :letterType LIMIT :batchSize];
                    //END UD-2328 08/26/15 RReyes - replaced DTL_Date__c condition with Sub_Created_Date__c 
                } else {
                    letterPrintRequestList = [SELECT Id, Status__c, Record_ID__c, Letter_Type__c, DTL_Date__c,Acknowledgment_Type__c, Generation_From__c, Generation_To__c
                                              FROM Letter_Print_Request__c 
                                              WHERE Status__c = :newValue AND Letter_Type__c = :letterType LIMIT :batchSize];
                }           
                //END UD-2014 Added By S.Puli - filter acknowledgement letter not inlcuding EMAIL reference
                // END : UD-0682 4/9/2015 Jean Cari�o
                
                latestLetterPrintRequest = [SELECT Id, Batch_Run_Sequence__c FROM Letter_Print_Request__c WHERE (Status__c = :processingValue OR Status__c = :successValue OR Status__c = :failedValue) AND Letter_Type__c = :letterType ORDER BY Batch_Run_Sequence__c DESC NULLS LAST LIMIT 1];
            }
            // END Code Review 2/18/2015 Jean Cari�o
            
            
            Integer latestBatchRunSequence = 0;     
            if(latestLetterPrintRequest.size() > 0)
        {
                //Start D-3902 Vpernicia 11/27/15
                if (Integer.valueOf(latestLetterPrintRequest.get(0).Batch_Run_Sequence__c) != null) {
                    latestBatchRunSequence = Integer.valueOf(latestLetterPrintRequest.get(0).Batch_Run_Sequence__c);
                }
                //End D-3902 Vpernicia 11/27/15
                latestBatchRunSequence++;
            }
            //START UD-2328
            if(letterType == 'Acknowledgment_Letter'){
                if(letterPrintBatch <> null){
                    if(letterPrintBatch.Initialized_Batches__c <> null){
                        Other__c otherBatch = Other__c.getInstance('SP18_InitializedBatch');
                        if(letterPrintBatch.Initialized_Batches__c < 5){
                            otherBatch.Value__c = String.valueOf(letterPrintBatch.Initialized_Batches__c);
                        }else{
                            otherBatch.Value__c = '0';
                        }
                        update otherBatch;
                    }
                }
            }
            //END UD-2328
            for(Letter_Print_Request__c letterPrint : letterPrintRequestList)
            {
                // START : UD-682 4/8/2015 Jean Cari�o
                if(letterPrint.Letter_Type__c == 'Acknowledgment_Letter'){
                //START UD-2014 Added By S.Puli - filter acknowledgement letter not inlcuding EMAIL reference
                    if((letterPrint.Sub_Created_Date__c > dateFrom && letterPrint.Sub_Created_Date__c <= dateTo) 
                        && (letterPrint.Acknowledgment_Type__c == 'Both' || letterPrint.Acknowledgment_Type__c == 'Hard Copy')){ // START-END : D-3806 10/28/2015 Alyana Navarro //START UD-2328 08/26/15 RReyes - replaced DTL_Date__c condition with Sub_Created_Date__c
                        letterPrint.Status__c = processingValue;
                        letterPrint.Batch_Run_Sequence__c = latestBatchRunSequence;
                    } else if( letterPrint.Acknowledgment_Type__c == 'Email'){
                        letterPrint.Status__c = failedValue; //fail if reference is Email
                    }
                    letterPrint.Generation_From__c = dateFrom;
                    letterPrint.Generation_To__c = dateTo;
                //END UD-2014 Added By S.Puli - filter acknowledgement letter not inlcuding EMAIL reference
                } else {
                    letterPrint.Status__c = processingValue;
                    letterPrint.Batch_Run_Sequence__c = latestBatchRunSequence;
                }
                // END : UD-682 4/8/2015 Jean Cari�o
            }
            
            //START UD-2328 08/26/15 RReyes
           
           if(letterType == 'Acknowledgment_Letter'){
               try{
                    if(letterPrintBatch.Initialized_Batches__c == 1){
                        Other__c other1 = Other__c.getInstance('SP18_SDT1');
                        other1.DateTime__c = dateFrom;
                        
                        update other1;
                        
                        Other__c other2 = Other__c.getInstance('SP18_SDT2');
                        other2.DateTime__c = dateTo;
                        
                        update other2;
                    }
                  }catch(exception e){
                        hasError = true;
                  }
                
                  
            }
            
             update letterPrintRequestList;
            //END UD-2328 08/26/15 RReyes
            return Database.getQueryLocator([SELECT Id, Status__c, Record_ID__c, Letter_Type__c, Generation_From__c, Generation_To__c, Letter_Sub_Type__c FROM Letter_Print_Request__c WHERE Status__c = :processingValue AND Letter_Type__c = :letterType AND Batch_Run_Sequence__c = :latestBatchRunSequence LIMIT :batchSize]); 
        }
        else{
        
            return Database.getQueryLocator([SELECT id, name, Record_ID__c, Letter_Type__c, Letter_Sub_Type__c, Status__c, Generation_From__c, Generation_To__c FROM Letter_Print_Request__c WHERE ID in: lprIdSet]);
        }
    //END D-3599 10/06/2015 added by Jason A.
    }
     
    /* @description Generates Acknowledgment Letter for Newly Created Subscriptions.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<Letter_Print_Request__c> scope){
        // START : D-4175 12/23/2015 Alyana Navarro
        //Start UD-3207 26-Mar-2016 Added by S.Puli
        String batchCode = '';
        Boolean isFailed = false;
        if(letterType == acknowledgmentLetter){
            batchCode = 'SP018';
        } else if(letterType == packingLabelLetter){
            batchCode = 'SP029';
        } else if(letterType == invoiceLetter){
            batchCode = 'SP028';
        } else if(letterType == creditCardFailureNotification){
            batchCode = 'SP027';
        } else if(letterType == firstRenewalReminderForMagazine){
            batchCode = 'SP030';
        } else if(letterType == secondRenewalReminderForMagazine){
            batchCode = 'SP031';
        } else if(letterType == firstRenewalReminderForNewspaper){
            batchCode = 'SP032';
        } else if(letterType == secondRenewalReminderForNewspaper){
            batchCode = 'SP033';
        } else if(letterType == creditNotes){
            batchCode = 'SP026';
        } else if(letterType == dailyInvLetter){
            batchCode = 'SP063';
        }
        //End UD-3207 26-Mar-2016 Added by S.Puli
        Logger logger = new Logger(SP_GenerateLetterPrintBatch.class.getName(), batchCode, BC.getJobID());
        // END : D-4175 12/23/2015 Alyana Navarro
        invoiceFinalList = new List<Zuora__ZInvoice__c>(); // START-END : UD-2371 8/20/2015 Alyana Navarro
        dailyInvList = new List<Daily_Invoice__c>();//Start/End UD-3207 01-Apr-2016 Added By S.Puli
        system.debug('sessionId: '+sessionId);
        // START : D-2013 3/17/2015 Alyana Navarro
        Set<String> mailingAccountNumberSet = new Set<String>();
        List<Account> mailingAccountList = new List<Account>();
        Map<String, Id> mailingNumberMailingIdMap = new Map<String, Id>();
        // END : D-2013 3/17/2015 Alyana Navarro
    
        //String sessionId = login();
        Set<String> allFailedRecords = new Set<String>();
        Set<String> idBatchSet = new Set<String>(); //START/END 02/02/15 D-1990 and D-1991 Kevin Evasco - Added error handling for issues related to JSON Parses and Read Timed Out
        List<String> parentIdList = new List<String>();        
        Map<String,List<String>> letterSubTypeMap = new Map<String,List<String>>(); // START-END : D-2873 5/18/2015 Alyana Navarro
    //START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
    Map<Id,String> recordID_attachmentID_map = new Map<Id,String>();
    Map<Id,Date> recordID_dateOfGeneration_map = new Map<Id,Date>();
    Map<Id,String> recordID_filename_map = new Map<Id,String>();
    //END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.>();
        Map<String,String> packLabelRecId_AttachmentID_Map = new Map<String,String>();  // START-END : D-2873 5/18/2015 Alyana Navarro
        
        // START : UD-2371 8/20/2015 Alyana Navarro
        Set<Id> invoiceIdSet = new Set<Id>();               
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
        // END : UD-2371 8/20/2015 Alyana Navarro
        
        //Start UD-3207 26-Mar-2016 Added by S.Puli
        Set<Id> dailyInvId_Set = new Set<Id>();               
        List<Daily_Invoice__c> invoiceDailyList = new List<Daily_Invoice__c>();
        //End UD-3207 26-Mar-2016 Added by S.Puli
        //START : UD-2361 31-Aug-2015 Added by S.Puli 
        Set<Id> creditNoteId_Set = new Set<Id>(); 
        List<Credit_Note__c> creditNote_List = new List<Credit_Note__c>();
        //END : UD-2361 31-Aug-2015 Added by S.Puli 

        System.debug('SESSION ID:' + UserInfo.getSessionId());
        
        // START : UD-2634 9/10/2015 Alyana Navarro
        //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
        Set<Id> paymentIdSet = new Set<Id>();

        List<External_Payment__c> paymentList = new List<External_Payment__c>();
        //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
        // END : UD-2634 9/10/2015 Alyana Navarro
        //START 25 November 2015 UD-2535 Kevin Evasco - Update Sub Is PDF Generated fields
        Set<Id> masterLPRIdSet = new Set<Id>();     
        List<Letter_Print_Request__c> detailLPRList = new List<Letter_Print_Request__c>();
        List<Zuora__Subscription__c> renewalSubscriptionList = new List<Zuora__Subscription__c>();
        //START 25 November 2015 UD-2535 Kevin Evasco - Update Sub Is PDF Generated fields
        
        integer index = 0;
        //START 04/09/2015 D-2586/D-2587 Kevin Evasco - Use Custom Settings for the PDF Generator batch size
        Integer pdfGeneratorBatchSize = 5;
        try {
            Batch_Configuration_Settings__c pdfGeneratorBatchConfiguration = Batch_Configuration_Settings__c.getInstance('SP_PDFGenerator');
            pdfGeneratorBatchSize = Integer.valueOf(pdfGeneratorBatchConfiguration.Batch_Size__c);
        } catch(Exception e) {
            System.debug('There is no custom settings for SP_PDFGenerator. Please check Batch_Configuration_Settings__c records. ');
            // START : D-4175 12/23/2015 Alyana Navarro
            logger.log(e);
            isFailed = true;
            // END : D-4175 12/23/2015 Alyana Navarro
        }
        //END 04/09/2015 D-2586/D-2587 Kevin Evasco - Use Custom Settings for the PDF Generator batch size
        
        for(Letter_Print_Request__c batchObject : scope)
        {
            // START : D-2013 3/17/2015 Alyana Navarro
            if(batchObject.Letter_Sub_Type__c == 'Overseas_Newspaper_Report_Hard_Copy'){
                mailingAccountNumberSet.add(batchObject.Record_ID__c);
            }
            // END : D-2013 3/17/2015 Alyana Navarro
            parentIdList.add(batchObject.Record_ID__c);
            idBatchSet.add(batchObject.Record_ID__c); //START/END 02/02/15 D-1990 and D-1991 Kevin Evasco - Added error handling for issues related to JSON Parses and Read Timed Out
        // START : D-2873 5/19/2015 Alyana Navarro
            // START : D-3016 5/29/2015 SPuli - Hotfix
            if(batchObject.Record_ID__c != null){
                if(letterSubTypeMap.containsKey(batchObject.Record_ID__c)){         
                    letterSubTypeMap.get(batchObject.Record_ID__c).add(batchObject.Letter_Sub_Type__c);
                } else {
                    letterSubTypeMap.put(batchObject.Record_ID__c, new List<String>{batchObject.Letter_Sub_Type__c});
                }
            }
            // END : D-3016 5/20/2015 SPuli - Hotfix
            // END : D-2873 5/19/2015 Alyana Navarro
            if(parentIdList.size() == pdfGeneratorBatchSize || index == scope.size()-1) //START/END 04/09/2015 D-2586/D-2587 Kevin Evasco - Use Custom Settings for the PDF Generator batch size
            {            
                HttpRequest req = new HttpRequest();
                req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SP_PDFGenerator');
                req.setMethod('POST');
                //START: D-4409 02-10-2016 Added by Kristine Balaoing - extended callout timeout
				//START: PD-0374 06012016 Gdelrosario : extended callout timeout to 1minute
                req.setTimeout(60000);
				//END: PD-0374 06012016 Gdelrosario : extended callout timeout to 1minute
                //END: D-4409 02-10-2016 Added by Kristine Balaoing
                // START 12/2/14 Kevin Evasco D-0906, D-0907, D-0908, D-0909, D-0849, D-0900, D-0901, D-0902, D-0903, D-0904, D-0910
                //req.setHeader('Authorization', 'OAuth ' + sessionId);
                req.setHeader('Authorization', 'Bearer ' + sessionId); //START/END 02/10/2015 D-2101 Kevin Evasco - Updated to enable letter printing for CSO.
                // END 12/2/14 Kevin Evasco D-0906, D-0907, D-0908, D-0909, D-0849, D-0900, D-0901, D-0902, D-0903, D-0904, D-0910
                
                req.setHeader('Content-Type','application/json');        

    //START D-3599 10/06/2015 added by Jason A.
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeObjectField('parentIdList', parentIdList);
                gen.writeObjectField('templateName', letterType);
                gen.writeObjectField('letterSubTypeMap', letterSubTypeMap);
                gen.writeObjectField('isRecovery', isRecovery);
                if(isRecovery && letterType == acknowledgmentLetter){
                    gen.writeObjectField('generationFrom', batchObject.Generation_From__c);
                    gen.writeObjectField('generationTo', batchObject.Generation_To__c);
                //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
        } else if(letterType == packingLabelLetter){
                    gen.writeObjectField('generationFrom', batchObject.Generation_From__c);    //tine's change
                }
        //END: D-3672 11/13/2015 Added by Kristine Balaoing
                else {
                    gen.writeObjectField('generationFrom', Date.Today());
                    gen.writeObjectField('generationTo', Date.Today());
                }                         
                gen.writeEndObject();
                String reqBody = gen.getAsString();
    //END D-3599 10/06/2015 added by Jason A.        
                req.setBody(reqBody);
                Http http = new Http();
                //START 02/02/15 D-1990 and D-1991 Kevin Evasco - Added error handling for issues related to JSON Parses and Read Timed Out
                try
                {
                  HttpResponse response = http.send(req);            
                  
                  if(response.getStatusCode() >= 200 && response.getStatusCode() <= 204)
                  {
                        //END 02/02/15 D-1990 and D-1991 Kevin Evasco - Added error handling for issues related to JSON Parses and Read Timed Out
                //START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
                        SP_PDFGenerator.SP_PDFGeneratorResponse deserializedResponse = (SP_PDFGenerator.SP_PDFGeneratorResponse)JSON.deserialize(response.getBody(),SP_PDFGenerator.SP_PDFGeneratorResponse.class);
                
                        Set<String> deserializedFailedRecordsSet = (Set<String>)JSON.deserialize(deserializedResponse.failedRecordsSet,Set<String>.class);
                        Map<Id,String> deserialized_recordID_attachmentID_map = (Map<Id,String>)JSON.deserialize(deserializedResponse.recordID_attachmentID_map,Map<Id,String>.class);
                        Map<Id,Date> deserialized_recordID_dateOfGeneration_map = (Map<Id,Date>)JSON.deserialize(deserializedResponse.recordID_dateOfGeneration_map,Map<Id,Date>.class);
                        Map<Id,String> deserialized_recordID_filename_map = (Map<Id,String>)JSON.deserialize(deserializedResponse.recordID_filename_map,Map<Id,String>.class);
                        Map<String, String> deserialized_packLabelRecId_AttachmentID_Map = (Map<String, String>) JSON.deserialize(deserializedResponse.packLabelRecId_AttachmentID_Map, Map<String, String>.class); // START-END : D-2873 5/18/2015 Alyana Navarro
                                
                        allFailedRecords.addAll(deserializedFailedRecordsSet);
                        
                        // START : D-4175 12/23/2015 Alyana Navarro
                        if(deserializedFailedRecordsSet.size() > 0){                            
                            logger.log(true, 'PDFGenerator failed record response: ' + String.valueOf(deserializedFailedRecordsSet));
                            isFailed = true;
                        }
                        // END : D-4175 12/23/2015 Alyana Navarro
                        
                        recordID_attachmentID_map.putAll(deserialized_recordID_attachmentID_map);  
                        recordID_dateOfGeneration_map.putAll(deserialized_recordID_dateOfGeneration_map);
                        recordID_filename_map.putAll(deserialized_recordID_filename_map);
                        packLabelRecId_AttachmentID_Map.putAll(deserialized_packLabelRecId_AttachmentID_Map); // START-END : D-2873 5/18/2015 Alyana Navarro
                        //END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
                                
                        parentIdList = new List<String>();
                        letterSubTypeMap = new Map<String, List<String>>(); // START-END : D-2873 5/19/2015 Alyana Navarro
                            //START 02/02/15 D-1990 and D-1991 Kevin Evasco - Added error handling for issues related to JSON Parses and Read Timed Out                 
                        idBatchSet = new Set<String>();
                        // START : UD-2371 8/20/2015 Alyana Navarro
                        if(letterType == invoiceLetter){
                            invoiceIdSet.addAll(recordID_filename_map.keySet());
                        }                       
                        // END : UD-2371 8/20/2015 Alyana Navarro
                        //Start UD-3207 01-Apr-2016 Added By S.Puli
                        if(letterType == dailyInvLetter){
                            dailyInvId_Set.addAll(recordID_filename_map.keySet());
                        }
                        //End UD-3207 01-Apr-2016 Added By S.Puli
                        // START : UD-2634 9/10/2015 Alyana Navarro
                        if(letterType == FAILED_PAYPAL_NOTIFICATION){
                            paymentIdSet.addAll(recordID_filename_map.keySet());
                        }
                        // END : UD-2634 9/10/2015 Alyana Navarro
                        
                        //START : UD-2361 31-Aug-2015 Added by S.Puli 
                        if(letterType == creditNotes){
                            creditNoteId_Set.addAll(recordID_filename_map.keySet());
                        }
                        //END : UD-2361 31-Aug-2015 Added by S.Puli 
                        
                        //START 25 November 2015 UD-2535 Kevin Evasco - Update Sub Is PDF Generated fields
                        if(letterType == firstRenewalReminderForMagazine || 
                            letterType == secondRenewalReminderForMagazine || 
                            letterType == firstRenewalReminderForNewspaper || 
                            letterType == secondRenewalReminderForNewspaper) {
                            masterLPRIdSet.addAll(recordID_filename_map.keySet());
                        }                       
                        //END 25 November 2015 UD-2535 Kevin Evasco - Update Sub Is PDF Generated fields
                    }
                    else
                    {
                        // START : D-4175 12/23/2015 Alyana Navarro
                        logger.log(true, 'Response Error. Response Status Code: ' + String.valueOf(response.getStatusCode()));
                        isFailed = true;
                        // END : D-4175 12/23/2015 Alyana Navarro
                        allFailedRecords.addAll(idBatchSet);
                        idBatchSet = new Set<String>(); 
                    }
                }
                catch(Exception e)
                {
                    // START : D-4175 12/23/2015 Alyana Navarro
                    logger.log(e);
                    isFailed = true;
                    // END : D-4175 12/23/2015 Alyana Navarro
                    allFailedRecords.addAll(idBatchSet);
                    idBatchSet = new Set<String>(); 
                }
                //END 02/02/15 D-1990 and D-1991 Kevin Evasco - Added error handling for issues related to JSON Parses and Read Timed Out
            }
            index++;
        }
        // START : UD-2371 8/20/2015 Alyana Navarro
        if(letterType == invoiceLetter){
            invoiceList = [SELECT id, name, Is_PDF_Generated__c FROM Zuora__ZInvoice__c WHERE Id IN: invoiceIdSet];
            
            for(Integer counter = 0; counter < invoiceList.size(); counter++){
                invoiceList[counter].Is_PDF_Generated__c = true;
            }
            
            invoiceFinalList.addAll(invoiceList);           
        }
        // END : UD-2371 8/20/2015 Alyana Navarro
        
        //Start UD-3207 01-Apr-2016 Added By S.Puli
        if(letterType == dailyInvLetter){
            invoiceDailyList = [SELECT id, name, Is_PDF_Generated__c FROM Daily_Invoice__c WHERE Id IN: dailyInvId_Set];
            
            for(Integer counter = 0; counter < invoiceDailyList.size(); counter++){
                invoiceDailyList[counter].Is_PDF_Generated__c = true;
            }
            
            dailyInvList.addAll(invoiceDailyList);           
        }
        //End UD-3207 01-Apr-2016 Added By S.Puli
        //START 25 November 2015 UD-2535 Kevin Evasco - Update Sub Is PDF Generated fields
        if(letterType == firstRenewalReminderForMagazine || 
            letterType == secondRenewalReminderForMagazine || 
            letterType == firstRenewalReminderForNewspaper || 
            letterType == secondRenewalReminderForNewspaper){
            detailLPRList = [SELECT Id, Record_ID__c FROM Letter_Print_Request__c WHERE Parent_Letter_Print_Request__c IN :masterLPRIdSet AND Status__c = :SP_RenewalReminderConsolidator.LPR_STATUS_TAGGED];
            
            Set<Id> subscriptionIdSet = new Set<Id>();
            for(Letter_Print_Request__c lprElem : detailLPRList){
                subscriptionIdSet.add(lprElem.Record_ID__c);
            }
            
            renewalSubscriptionList = [SELECT Id, is1stPDFGenerated__c, is2ndPDFGenerated__c FROM Zuora__Subscription__c WHERE Id IN :subscriptionIdSet];
            
            for(Zuora__Subscription__c subscriptionElem : renewalSubscriptionList){
                if(letterType == firstRenewalReminderForMagazine || letterType == firstRenewalReminderForNewspaper)
                    subscriptionElem.is1stPDFGenerated__c = true;
                if(letterType == secondRenewalReminderForMagazine || letterType == secondRenewalReminderForNewspaper)
                    subscriptionElem.is2ndPDFGenerated__c = true;
            }
            
            SubscriptionTriggerHandler.preventExecution = true;
            Database.update(renewalSubscriptionList,false);
            
            for(Integer counter = 0; counter < invoiceList.size(); counter++){
                invoiceList[counter].Is_PDF_Generated__c = true;
            }
            
            invoiceFinalList.addAll(invoiceList);           
        }        
        //END 25 November 2015 UD-2535 Kevin Evasco - Update Sub Is PDF Generated fields
        // START : UD-2634 9/10/2015 Alyana Navarro
        //START D-3952 Gdelrosario 19/11/15 : change the variables to external payment
        if(letterType == FAILED_PAYPAL_NOTIFICATION){
            if(paymentIdSet.size() > 0){
                paymentList = [SELECT id, name FROM External_Payment__c WHERE id IN: paymentIdSet];
            }
            /*
            for(Integer counter = 0; counter < paymentList.size(); counter++){
                paymentList[counter].Is_PDF_Generated__c = true;
            }*/
        }
        //END D-3952 Gdelrosario 19/11/15 : change the variables to external payment
        // END : UD-2634 9/10/2015 Alyana Navarro
        //START : UD-2361 31-Aug-2015 Added by S.Puli 
        //START D-3575 16-09-2015 Added By S.Puli - correcting the letter type
        if(letterType == creditNotes){
        //END D-3575 16-09-2015 Added By S.Puli - correcting the letter type
            creditNote_List = [SELECT id, Is_PDF_Generated__c FROM Credit_Note__c WHERE Id IN: creditNoteId_Set];
            
            for(Integer counter = 0; counter < creditNote_List.size(); counter++){
                creditNote_List[counter].Is_PDF_Generated__c = true;
            }
                     
        }           
        //END : UD-2361 31-Aug-2015 Added by S.Puli 
        
        // START : D-2013 3/17/2015 Alyana Navarro
        mailingAccountList = [SELECT id, name, AccountNumber FROM Account WHERE AccountNumber IN: mailingAccountNumberSet];
        for(Account mailingAccount : mailingAccountList){
            mailingNumberMailingIdMap.put(mailingAccount.AccountNumber, mailingAccount.id);
        }
        
        //START:D-2180 2/13/15 Added by Manolo Vale�a - Added new variable.
        Set<Id> oligIdSet = new Set<Id>();
        //END:D-2180 2/13/15 Added by Manolo Vale�a
        
    //START D-3599 10/06/2015 added by Jason A.
    //START UD-3141 10/22/2015 Jason A. - Added for Supressed Acknowledgement
        Map<Id, Boolean> billingAccountIdIsSuccessMap = new Map<Id, Boolean>(); 
        Set<Id> validBillAccSet = new Set<Id>(); //START END PD-0186 24May2016 Added By C. Lin
		if(letterType == acknowledgmentLetter){                
			//START PD-0186 24May2016 Added By C. Lin - Add Zuora__SubscriptionEndDate__c, Zuora__SubscriptionStartDate__c, Zuora__TermSettingType__c
            List<Zuora__Subscription__c> subscriptionList = [SELECT id, name, Acknowledgement_Letter__c, Zuora__CustomerAccount__c, Supressed_Acknowledgement_Letter_1__c, Zuora__SubscriptionEndDate__c, Zuora__SubscriptionStartDate__c, Zuora__TermSettingType__c 
                                                             FROM Zuora__Subscription__c 
                                                             WHERE Zuora__CustomerAccount__c IN: recordID_filename_map.keySet() 
                                                             AND (CreatedDate >=: dateFrom AND CreatedDate <=: dateTo) AND Supressed_Acknowledgement_Letter_1__c = false ];
            //END PD-0186 24May2016 Added By C. Lin
            for(Zuora__Subscription__c subscription : subscriptionList){
				//START PD-0186 24May2016 Added By C. Lin - Update condition to exclude subscriptions with deleted status
				if(subscription.Zuora__SubscriptionEndDate__c > subscription.Zuora__SubscriptionStartDate__c || (subscription.Zuora__TermSettingType__c == 'EVERGREEN' && subscription.Zuora__SubscriptionEndDate__c == null)){
                    if(subscription.Acknowledgement_Letter__c == null || subscription.Acknowledgement_Letter__c == ''){
                        billingAccountIdIsSuccessMap.put(subscription.Zuora__CustomerAccount__c, false);
                    }
                    
                    if(!validBillAccSet.contains(subscription.Zuora__CustomerAccount__c)){
                        validBillAccSet.add(subscription.Zuora__CustomerAccount__c);
                    }
                }
				//END PD-0186 24May2016 Added By C. Lin
            }
			
			//START PD-0186 24May2016 Added By C. Lin - Update condition to exclude subscriptions with deleted status
            for(Zuora__Subscription__c subscription : subscriptionList){
                if(!validBillAccSet.contains(subscription.Zuora__CustomerAccount__c)){
                    allFailedRecords.add(subscription.Zuora__CustomerAccount__c);
                }
            }
            //END PD-0186 24May2016 Added By C. Lin
        }
    //END UD-3141 10/22/2015 Jason A. - Added for Supressed Acknowledgement
    //END D-3599 10/06/2015 added by Jason A.
        
        for(Letter_Print_Request__c batchObject : scope)
        {           
            if(allFailedRecords.contains(batchObject.Record_ID__c))
            {                       
                batchObject.Status__c = failedValue;
                islprequestfailed = False; //START/END D-4482 14-Mar-2016 Added by Raviteja - Capturing letter print request failuer
            }
            else
            {
    //START D-3599 10/06/2015 added by Jason A.
                batchObject.Status__c = successValue;
                
                if(letterType == acknowledgmentLetter){
                    if(billingAccountIdIsSuccessMap.containsKey(batchObject.Record_ID__c)){                      
                        batchObject.Status__c = 'Incomplete';                       
                    }
                }
    //END D-3599 10/06/2015 added by Jason A.
                
                //START:D-2180 2/13/15 Added by Manolo Vale�a - Insert values in set.
            
                // START Code Review 2/18/2015 Jean Cari�o
                if(batchObject.Record_ID__c != null){
                    if(mailingNumberMailingIdMap.containsKey(batchObject.Record_ID__c)){
                        oligIdSet.add(mailingNumberMailingIdMap.get(batchObject.Record_ID__c));
                    } else {
                        oligIdSet.add((ID)batchObject.Record_ID__c);
                    }
                }
                // END Code Review 2/18/2015 Jean Cari�o
                
                //END:D-2180 2/13/15 Added by Manolo Vale�a             
                //START: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
                if(mailingNumberMailingIdMap.containsKey(batchObject.Record_ID__c)){
                    batchObject.Attachment_ID__c = recordID_attachmentID_map.get(mailingNumberMailingIdMap.get(batchObject.Record_ID__c));
                    batchObject.Date_of_Generation__c = recordID_dateOfGeneration_map.get(mailingNumberMailingIdMap.get(batchObject.Record_ID__c));
                    batchObject.Filename__c = recordID_filename_map.get(mailingNumberMailingIdMap.get(batchObject.Record_ID__c));
                } 
        // START : D-2873 5/19/2015 Alyana Navarro
        else if(packLabelRecId_AttachmentID_Map.containsKey(batchObject.Record_ID__c + '-' + batchObject.Letter_Sub_Type__c)){
                    batchObject.Attachment_ID__c = packLabelRecId_AttachmentID_Map.get(batchObject.Record_ID__c + '-' + batchObject.Letter_Sub_Type__c);
                    batchObject.Date_of_Generation__c = recordID_dateOfGeneration_map.get((ID)batchObject.Record_ID__c);
                    batchObject.Filename__c = recordID_filename_map.get((ID)batchObject.Record_ID__c);      
        } 
        // END : D-2873 5/19/2015 Alyana Navarro
        else {
                    batchObject.Attachment_ID__c = recordID_attachmentID_map.get((ID)batchObject.Record_ID__c);
                    batchObject.Date_of_Generation__c = recordID_dateOfGeneration_map.get((ID)batchObject.Record_ID__c);
                    batchObject.Filename__c = recordID_filename_map.get((ID)batchObject.Record_ID__c);
                }
                //END: 01/14/15 D-1716 Kevin Evasco - Updated to include date of generation and invoice/credit note # in the filename.
            }
        }
        // END : D-2013 3/17/2015 Alyana Navarro
    //START:D-2180 2/13/15 Added by Manolo Vale?a - If the pdf generation is successful, the has letter attached field of an OLIG will be checked.
        if(this.letterType == giftLetter || this.letterType == subscriptionLetter || this.letterType == giftRenewalLetter || this.letterType == giftRedemptionLetter || this.letterType == giftPremiumChina || this.letterType == giftPremiumEnglish)
        {   
            // START Code Review 2/18/2015 Jean Cari�o
            //START 02/21/2015 JTeves - fix null pointer exception - UAT Issue
            List<Order_Line_Item_Gift__c> oligList = new List<Order_Line_Item_Gift__c>();
            //END 02/21/2015 JTeves
            if(oligIdSet.size() > 0){
                oligList = [SELECT Id, Has_Letter_Attached__c FROM Order_Line_Item_Gift__c WHERE Id IN : oligIdSet];
            }
            // END Code Review 2/18/2015 Jean Cari�o
            
            for(Order_Line_Item_Gift__c olig : oligList)
            {
                olig.Has_Letter_Attached__c = true;                  
            }
            if(oligList.size() > 0)
            {
                Database.Update(oligList);
            }
        }
        //END:D-2180 2/13/15 Added by Manolo Vale?a    
        
        // START : UD-2371 8/20/2015 Alyana Navarro
        if(letterType == invoiceLetter){        
            Database.update(invoiceFinalList,false);
        }       
        // END : UD-2371 8/20/2015 Alyana Navarro
        
        //Start UD-3207 01-Apr-2016 Added By S.Puli
        if(letterType == dailyInvLetter){        
            Database.update(dailyInvList,false);
        }
        //End UD-3207 01-Apr-2016 Added By S.Puli
         // START : UD-2634 9/10/2015 Alyana Navarro
        if(letterType == FAILED_PAYPAL_NOTIFICATION){        
            Database.update(paymentList,false);
        }       
        // END : UD-2634 9/10/2015 Alyana Navarro
        //START : UD-2361 31-Aug-2015 Added by S.Puli 
        if(creditNote_List.size()>0){
            Database.update(creditNote_List, false);
        }
        //END : UD-2361 31-Aug-2015 Added by S.Puli 
        
        if(scope.size() > 0) {
            List<Database.Upsertresult> saveResults = Database.upsert(scope, false); 
            // START : D-4175 12/23/2015 Alyana Navarro
            String errorMessage;
            for(Database.Upsertresult sr : saveResults) {               
                if(!sr.isSuccess()) {                   
                    System.debug('UpserResult: ' + sr);
                    errorMessage = '';
                    for(Database.Error pdfError : sr.getErrors()){
                        errorMessage += '* ' + pdfError.getMessage() + '\n';
                    }                   
                    logger.log(true, 'Error Message: \n ' + errorMessage);
                    isFailed = true;
                }
            }
            // END : D-4175 12/23/2015 Alyana Navarro
        }
        // START : D-4175 12/23/2015 Alyana Navarro
        if(isFailed){
            logger.save();            
        }
        // END : D-4175 12/23/2015 Alyana Navarro
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
     
    global void finish(Database.BatchableContext BC)
    {       
    //START D-3599 10/06/2015 added by Jason A.    
        //START 20 January 2016 D-4281 Kevin Evasco - Single callout to on-premise system for letter printing parallel jobs
        //START D-4482 14-Mar-2016 Added by Raviteja - Sending the signals to Control-M 
        //BatchJobHelper.updateBatchJobScheduler(BC.getJobId());
         BatchJobHelper.updateBatchJobScheduler(BC.getJobId(),islprequestfailed);
        //END D-4482 14-Mar-2016 Added by Raviteja
        //END 20 January 2016 D-4281 Kevin Evasco - Single callout to on-premise system for letter printing parallel jobs

            
        
    //END D-3599 10/06/2015 added by Jason A.
    }
}