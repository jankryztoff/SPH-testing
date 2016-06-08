/*
 * Class Name: SP_PopulateVDCCreditNotes
 * @author: Kevin H. Evasco
 * Date: 03/19/2015
 * Project/Requirement: SPH Integration
 * 
 * History: 03/19/2015 Kevin Evasco Created Apex Batchable
 * UD-3618 07-Jan-2016 Added by Raviteja - Restructure the class
 */


global class SP_PopulateVDCCreditNotes implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    global final String batchCode;
    global final Id jobId;
    global final Map<String, VDC_CREDITNOTE__c> creditNote_map = new Map<String, VDC_CREDITNOTE__c>();
    
    global static final String CREDIT_NUMBER_SETTING_NAME = 'Latest Credit Number';
    global static final String DEBIT_NUMBER_SETTING_NAME = 'Latest Debit Number';
    global static final String REASON_CATEGORY_CPI = 'CPI';
    global static final String REASON_CATEGORY_C5 = 'C5';
    global static final String REASON_CATEGORY_24 = '24';
    global static final String REASON_CATEGORY_D3 = 'D3';
    global static final String REASON_CATEGORY_M = 'M';
     //Start D-4742 Raviteja 26Apr2016 - removing hardocde values and applying custom settings
    /*global static final Integer CREDIT_INITIAL_NUMBER = 19999999;
    global static final Integer CREDIT_MIN_NUMBER = 20000000;
    global static final Integer CREDIT_MAX_NUMBER = 20099999;
    global static final Integer DEBIT_INITIAL_NUMBER = 12999999;
    global static final Integer DEBIT_MIN_NUMBER = 13000000;
    global static final Integer DEBIT_MAX_NUMBER = 13099999;    
    */
    global static final Integer CREDIT_INITIAL_NUMBER =  getCreditDebitNumberSetting('CREDIT_INITIAL_NUMBER');
    global static final Integer CREDIT_MIN_NUMBER = getCreditDebitNumberSetting('CREDIT_MIN_NUMBER');
    global static final Integer CREDIT_MAX_NUMBER = getCreditDebitNumberSetting('CREDIT_MAX_NUMBER');
    global static final Integer DEBIT_INITIAL_NUMBER = getCreditDebitNumberSetting('DEBIT_INITIAL_NUMBER');
    global static final Integer DEBIT_MIN_NUMBER = getCreditDebitNumberSetting('DEBIT_MIN_NUMBER');
    global static final Integer DEBIT_MAX_NUMBER = getCreditDebitNumberSetting('DEBIT_MAX_NUMBER');
    //End D-4742 Raviteja 26Apr2016 - removing hardocde values and applying custom settings
    global Date startDate;
    global Date endDate;
    global Boolean ismanualrun = False;
    Boolean isApexJobSuccessful = true; 
    
    public SP_PopulateVDCCreditNotes(String batchCodeParam, Id jobIdParam)
    {
        batchCode = batchCodeParam;
        jobId = jobIdParam;
        
        if(batchCode != 'SP002'){
            startDate = Date.today().toStartOfMonth();
            endDate = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
        } else {            
            startDate = Date.today()-1;
            endDate = Date.today();
        }       
    }    
   
    public SP_PopulateVDCCreditNotes(String batchCodeParam, Id jobIdParam, Date manualstartDate, Date manualendDate)
    {
        batchCode = batchCodeParam;
        jobId = jobIdParam;         
        startDate = manualstartDate;
        endDate = manualendDate;
        ismanualrun = True;        
    }
   
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
       
        return Database.getQueryLocator([SELECT Id, Job_Id__c, Vendor_Number__c, Reason_Code__c, Credit_Debit__c,Amt_Before_GST__c
                                                 FROM BT_CO_VBS_CreditDebit__c 
                                                     WHERE Job_Id__c = :batchCode 
                                                             AND Note_Number__c = NULL 
                                                             AND Posting_Date__c >= :startDate 
                                                             AND Posting_Date__c <= :endDate]);
    }
    
    /* @description Instantiates VDC_CREDITNOTE__c records
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<BT_CO_VBS_CreditDebit__c> scope)
    {                              
        Logger logger;
        if(!Test.isRunningTest()) {
        //logger = new Logger(SP_PopulateVDCCreditNotes.class.getName(), 'SP002', BC.getJobID());  
          logger = new Logger(SP_PopulateVDCCreditNotes.class.getName(), batchCode, BC.getJobID());
        }  
        Savepoint sp = Database.setSavepoint();
        try {
        for(BT_CO_VBS_CreditDebit__c batchRecord : scope)
        {
            String creditNoteKey = constructCreditNoteKey(batchRecord);           
            if(batchRecord.Amt_Before_GST__c > 0 && creditNote_map.get(creditNoteKey) == null)            
            {
                VDC_CREDITNOTE__c creditNoteRecord = new VDC_CREDITNOTE__c();
                creditNoteRecord.Vendor_Number__c = batchRecord.Vendor_Number__c;
                creditNoteRecord.Reason_Code_Category__c = getReasonCodeCategory(batchRecord.Reason_Code__c);
                creditNoteRecord.Credit_Debit_Indicator__c = batchRecord.Credit_Debit__c;
                creditNoteRecord.Job_Id__c = batchCode;
                creditNote_map.put(creditNoteKey,creditNoteRecord);
            }
        }
        } catch(Exception e) {
            Database.rollback(sp);
            logger.logBatchFailure(e, scope);
            logger.save();
            
            isApexJobSuccessful = false;
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
        Map<String, VDC_CREDITNOTE__c> creditNoteRecords_resultMap = new Map<String, VDC_CREDITNOTE__c>();
        
        if(creditNote_map.size()>0)
        {
            List<VDC_CREDITNOTE__c> creditNoteList = creditNote_map.values();
            populateCreditNoteNumbers(creditNoteList);
            List<Database.SaveResult> saveResults = Database.insert(creditNoteList);             
        }       

        if(batchCode != 'SP002')
        {    
            SP_PopulateVSSCreditNotes batchInstance;
            if(ismanualrun){
                batchInstance = new SP_PopulateVSSCreditNotes(batchCode, jobId, startDate,endDate);
                Database.executeBatch(batchInstance); 
            }
            else{
                batchInstance = new SP_PopulateVSSCreditNotes(batchCode, jobId);
                Database.executeBatch(batchInstance); 
            }         
        }
        else
        {              
            SP_PopulateManualCreditNotes batchInstance;
            if(ismanualrun){
                batchInstance = new SP_PopulateManualCreditNotes(batchCode, jobId, startDate,endDate);
                Database.executeBatch(batchInstance); 
            }
            else{
                batchInstance = new SP_PopulateManualCreditNotes(batchCode, jobId);
                Database.executeBatch(batchInstance); 
            }        
        }
    }
    
    public static Map<String, VDC_CREDITNOTE__c> getCreditNotesMap(Set<String> vendorNumberSetParam, Set<String> reasonCategorySetParam, Set<String> creditDebitIndicatorSetParam) {
        Map<String, VDC_CREDITNOTE__c> creditNotesMapResult = new Map<String, VDC_CREDITNOTE__c>();
        
        List<VDC_CREDITNOTE__c> creditNotesList = [SELECT Id, Vendor_Number__c, Reason_Code_Category__c, Credit_Debit_Indicator__c, Credit_Note_Number__c 
                                                                FROM VDC_CREDITNOTE__c WHERE 
                                                                    CreatedDate = THIS_MONTH 
                                                                        AND Vendor_Number__c IN :vendorNumberSetParam 
                                                                        AND Reason_Code_Category__c IN :reasonCategorySetParam 
                                                                        AND Credit_Debit_Indicator__c IN :creditDebitIndicatorSetParam 
                                                                        order by createdDate ASC];
        
        for(VDC_CREDITNOTE__c creditNoteElement : creditNotesList) {
            String primaryKey = constructCreditNoteKey(creditNoteElement);
            creditNotesMapResult.put(primaryKey, creditNoteElement);
        }
        
        return creditNotesMapResult;
    }
    
    public static String constructCreditNoteKey(BT_CO_VBS_CreditDebit__c creditDebitVBSParam) {
        String key = '';
        
        key += creditDebitVBSParam.Vendor_Number__c;
        key += getReasonCodeCategory(creditDebitVBSParam.Reason_Code__c);
        key += creditDebitVBSParam.Credit_Debit__c;
        
        return key;
    }
    
    public static String constructCreditNoteKey(BT_CO_VSS_CreditDebit__c creditDebitVSSParam) {
        String key = '';
        
        key += creditDebitVSSParam.Vendor_Number__c;
        key += getReasonCodeCategory(creditDebitVSSParam);
        key += creditDebitVSSParam.Credit_Debit__c;
        
        return key;
    }
    
    public static String constructCreditNoteKey(VDC_CREDITNOTE__c vdcCreditNoteParam) {
        String key = '';
        
        key += vdcCreditNoteParam.Vendor_Number__c;
        key += vdcCreditNoteParam.Reason_Code_Category__c;
        key += vdcCreditNoteParam.Credit_Debit_Indicator__c;
        
        return key;
    }
    
    public static String constructCreditNoteKey(Manual_Vendor_Credits_Debits__c manualCreditDebitParam) {
        String key = '';        
        key += manualCreditDebitParam.Vendor__r.Vendor_Code__c;        
        key += manualCreditDebitParam.Credit_Debit_Vendor_Reason__c;        
        key += manualCreditDebitParam.Credit_Debit_Indicator__c;
        
        return key;
    }   
    
    public static String getReasonCodeCategory(String reasonCodeParam){
        if(reasonCodeParam == 'C' || reasonCodeParam == 'P' || reasonCodeParam == 'I')
            return REASON_CATEGORY_CPI;
        else
            return reasonCodeParam;
    }
    
    public static String getReasonCodeCategory(BT_CO_VSS_CreditDebit__c creditDebitVSSParam){
        if((creditDebitVSSParam.Commission__c != 0 && creditDebitVSSParam.Commission__c != null) ||
            (creditDebitVSSParam.Pagination__c != 0 && creditDebitVSSParam.Pagination__c != null) ||
            (creditDebitVSSParam.Insertion__c != 0 && creditDebitVSSParam.Insertion__c != null))
            return REASON_CATEGORY_CPI;
        else if(creditDebitVSSParam.Delivery__c != 0 && creditDebitVSSParam.Delivery__c != null)
            return REASON_CATEGORY_C5;
        else if(creditDebitVSSParam.Manual_Amt__c == 0 && creditDebitVSSParam.Subscription__c == null)
            return REASON_CATEGORY_24;
        else if(creditDebitVSSParam.Manual_Amt__c == 0 && creditDebitVSSParam.Subscription__c != null)
            return REASON_CATEGORY_D3;      
        else if((creditDebitVSSParam.Manual_VDC_reason_code__c == '01' || creditDebitVSSParam.Manual_VDC_reason_code__c == '02' || 
                     creditDebitVSSParam.Manual_VDC_reason_code__c == '03' || creditDebitVSSParam.Manual_VDC_reason_code__c == '04' ) && 
                 (creditDebitVSSParam.Manual_Amt__c > 0 && creditDebitVSSParam.Subscription__c != null)){
             return creditDebitVSSParam.Manual_VDC_reason_code__c;
         }
         else return Null;    
          
    }
    
    public static void populateCreditNoteNumbers(List<VDC_CREDITNOTE__c> creditNoteListParam){
        Other__c latestCreditNumberSetting = getLatestCreditDebitNumberSetting(CREDIT_NUMBER_SETTING_NAME);
        Other__c latestDebitNumberSetting = getLatestCreditDebitNumberSetting(DEBIT_NUMBER_SETTING_NAME);
        Integer latestCreditNumber = Integer.valueOf(latestCreditNumberSetting.Value__c);
        Integer latestDebitNumber = Integer.valueOf(latestDebitNumberSetting.Value__c);
        
        for(VDC_CREDITNOTE__c creditNoteElement : creditNoteListParam) {
            if(creditNoteElement.Credit_Debit_Indicator__c == 'C'){             
                latestCreditNumber++;
                if(latestCreditNumber > CREDIT_MAX_NUMBER)
                    latestCreditNumber = CREDIT_MIN_NUMBER;
                creditNoteElement.Credit_Note_Number__c = latestCreditNumber;
            } else {
                latestDebitNumber++;                
                if(latestDebitNumber > DEBIT_MAX_NUMBER)
                    latestDebitNumber = DEBIT_MIN_NUMBER;
                creditNoteElement.Credit_Note_Number__c = latestDebitNumber;
            }
        }
        
        latestCreditNumberSetting.Value__c = String.valueOf(latestCreditNumber);
        latestDebitNumberSetting.Value__c = String.valueOf(latestDebitNumber);
        
        update latestCreditNumberSetting;
        update latestDebitNumberSetting;
    }   
    
    public static Other__c getLatestCreditDebitNumberSetting(String recordNameParam) {      
        Other__c creditNumberSetting;
        List<Other__c> creditNumberSettings = [SELECT Id, Value__c FROM Other__c WHERE Name = :recordNameParam LIMIT 1];
        if(creditNumberSettings.size() > 0) {
            creditNumberSetting = creditNumberSettings.get(0);
        } else {
            creditNumberSetting = new Other__c();
            creditNumberSetting.Name = recordNameParam;
            if(recordNameParam == CREDIT_NUMBER_SETTING_NAME)
                creditNumberSetting.Value__c = String.valueOf(CREDIT_INITIAL_NUMBER);
            else
                creditNumberSetting.Value__c = String.valueOf(DEBIT_INITIAL_NUMBER);
            insert creditNumberSetting;
        }
        
        return creditNumberSetting;
    }
    //Start D-4742 Raviteja 26Apr2016 - Created method to get the values from custom settings
    public static Integer getCreditDebitNumberSetting(String recordNameParam) {      
        Integer creditNumberSetting;
        List<Other__c> creditNumberSettings = [SELECT Id, Value__c FROM Other__c WHERE Name = :recordNameParam LIMIT 1];
        if(creditNumberSettings.size() > 0) {
            creditNumberSetting = Integer.Valueof(creditNumberSettings.get(0).Value__c);
        } 
        return creditNumberSetting;
    }
    //End D-4742 Raviteja 26Apr2016 - Created method to get the values from custom settings
}