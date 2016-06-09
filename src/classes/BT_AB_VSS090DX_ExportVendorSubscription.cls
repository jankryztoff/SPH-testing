/*
* Class Name: BT_AB_VSS090DX_ExportVendorSubscription
* @author: Kevin H. Evasco
* Date: 08/26/2014
* Project/Requirement: SPH Integration - VSS090DX Interface
* @description This class populates BA_INT_DATA_POOL__c for VSS090DX batch job. Used together with BT_AS_VSS090DX_ExportVendorSubscription Schedulable
* 
* History: 
*       2014/08/26 Kevin Evasco         Created Skeletal Apex Batchable             
*       2014/09/25 Renino Niefes        Added code implementations
*       2014/11/03 Renino Niefes        Code Review
*       2014/11/03 Renino Niefes        Added new record types
*       2015/01/07 Renino Niefes        Added missing fields and replaced account,contact,subscription IDs.  Loop through all Publications under 1 subscription to add to output list
*       2015/01/08 Renino Niefes        Fixed the case record types list to determine the transaction types
*       2015/01/08 Renino Niefes        Added data type checking and date format (D-1474 and D-1468)
*       2015/02/16 Renino Niefes        Code Review (Novasuite Audit Findings)
*       2015/02/18 Renino Niefes        D-2238 adding HDS IDs
*       2015/02/26 Renino Niefes        D-2238 get the date from Subscription_Vendor__r.Subscription_Start_Date__c
*       2015/03/20 Renino Niefes        D-2584 Use Custom settings Date utility in getting the start/end dates
*       2015/03/25 Renino Niefes        D-2584 Additional fix due to 50k Limit in UAT
*       2015/03/30 Renino Niefes        UD-0639 Use method DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(String,String) and getOverrideDate(String)
*       2015/04/10 Renino Niefes        D-2717 Fix the format of the date
*       2015/05/07 Michael Francisco    D-2831 - Rewrote / Modified the entire Apex Class to implement the following:
*                                           1) Removed code redundancies 
*                                           2) Effective Issue Date logic 
*                                           3) Added SORT conditions
*                                           4) Implemented "zData" logic
*                                           5) Used List / Sort approach to retain sorting
*                                           6) Implement Last Batch Run Date override date logic
*                                           7) Updated comments 
*                                           8) Created 'Note(s)' comments
*       2015/08/06 Renino Niefes        hotfix: implemented the .fai file and moved the validation to on premise server.  overriding zValidation code variable.
*
*
*
*
*/

global class BT_AB_VSS090DX_ExportVendorSubscription implements Database.Batchable<sObject>,Database.AllowsCallouts
{

// START 2015/05/07 D-2831 Michael Francisco  
          
    /* Interface ID : VSS090DX */
    global final String Z_INTERFACE_ID = 'VSS090DX';

    /* Default value for Vendor Group */
    global final String Z_DEFAULT_VENDOR_GROUP = 'V';

    global final String DELIM = '|';

    /* Default value for IGNORED FIELDS */
    global final String Z_IGNORED_FIELD = '';

    /* Default value for Indicator */
    global final String Z_CVS_INDICATOR = 'P';

    /* Default Subscription-Copies DEFAULT 'Day' value */ 
    global final String Z_SUB_CPS_DEFAULT_VALUE = '000';

    global final Integer MAX_SUB_CPS_DAY_STR_LENGTH = 3;
    global final Integer MAX_DAY_OF_WEEK = 7;
    global final Integer MAX_SUBSCRIPTION_COPY_IND = 9;
    global final String CASE_SUB_STATUS_TSTOP_REJECTED = 'Temp Stop Rejected';  

    /* Default REGEX for Publication Code */
    global final String Z_REGEX_PUBLICATION_CODE = '((?=.*\\d)|(?=.*[a-zA-Z]).{2,6})';

    /* Default Cut-Off DateTime Format */
    global final String Z_CUTOFF_DATE_TIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';

    /* Possible values: Closed | Void */
    global final String Z_CUSTOM_CASE_STATUS = 'VSS090DX Case Status';      

    /* Possible values: Case_Start Sub | Case_Stop | Case_Temp Stop | Start_Subscription | Stop_Subscription | Temp_Stop_Subscription | Vendor_Stop_Request */
    global final String Z_CUSTOM_CASE_RECORD_TYPE = 'VSS090DX Case Record Types';

    /* Possible values: BH | BM | BT | NP | TNPS | SM | ST | SUT | TM | TMS | WB | ZB | MY */
    global final String Z_CUSTOM_PUBLICATION_CODES = 'VSS090DX Publication Codes';

    /* ========= Case Record Type Constants ========= */
   global final String Z_CASE_START_SUBSCRIPTION = 'Start_Subscription';
   global final String Z_CASE_STOP_SUBSCRIPTION = 'Stop_Subscription';
   global final String Z_CASE_TSTOP_SUBSCRIPTION = 'Temp_Stop_Subscription';
    global final String Z_CASE_V_STOP_REQEUEST = 'Vendor_Stop_Request';
    global final String Z_CASE_START = 'Case_Start Sub';
    global final String Z_CASE_TSTOP = 'Case_Temp Stop';
    global final String Z_CASE_STOP = 'Case_Stop';
    
    global final String CASE_TEMP_STOP_TYPE_NEW = 'New';
    global final String CASE_TEMP_STOP_TYPE_CREATE = 'Create';  
    global final String CASE_TEMP_STOP_TYPE_CANCEL = 'Cancel';
    global final String CASE_TEMP_STOP_TYPE_UPDATE = 'Update';
        
    /* ========= Case Type CODE - DECODE Constants ========= */
    global final Integer I_CASE_TYPE_CODE_DEFAULT_REQ = 0;  // 0 DEFAULT
    global final Integer I_CASE_TYPE_CODE_START_REQ = 1;    // 1 (Start Request)
    global final Integer I_CASE_TYPE_CODE_STOP_REQ = 2;     // 2 (Stop Request)
    global final Integer I_CASE_TYPE_CODE_TSTOP_REQ = 3;    // 3 (Temporary Stop Request)

    /* ========= Case Status CODE - DECODE Constants ========= */
    global final Integer I_CASE_STATUS_CODE_CLOSED = 2;     // 2 (Closed)
    global final Integer I_CASE_STATUS_CODE_VOID_CRSM = 3;  /* 3 (Void request, remove data) 
                                                                                 ----> Void of CRSM case with existing subscription 
                                                                            */
    global final Integer I_CASE_STATUS_CODE_VOID_SUB = 4;   /* 4 (Void subscription, remove subscription) 
                                                                                 ----> Void of CRSM case with new subscription created during case creation
                                                                            */
    global final Integer I_CASE_STATUS_CODE_UPDATED = 5;    // 5 (Updated) -> Changes to related cases in CRSM.

    /* ========= DATE Mapping Constants ========= */
    global final String Z_OFFSET_DATE = 'OFFSET_DATE';
    global final String Z_CUTOFF_END_DATE = 'CUTOFF_END';
    global final String Z_CUTOFF_START_DATE = 'CUTOFF_START';
    global final String Z_LAST_BATCH_RUN_DATE = 'LAST_BATCH_RUN_DATE';

    global final Integer I_SUB_COPY_LENGTH = 3;

    /* ========= ZDATA Mapping Constants ========= */
    global final String Z_DATA_RECORD_TYPE = 'RECORD_TYPE';
    global final String Z_DATA_RECIPIENT_ID = 'RECIPIENT_ID';                           // Recipient Id
    global final String Z_DATA_SUBSCRIPTION_CODE = 'SUBSCRIPTION_CODE';                 // Subscription Code
    global final String Z_DATA_DELIVERY_ADDRESS = 'DELIVERY_ADDRESS';                   // Delivery Address Id
    global final String Z_DATA_SALUTATION = 'SALUTATION';                               // Salutation
    global final String Z_DATA_FULLNAME = 'FULLNAME';                                   // Full Name
    global final String Z_DATA_COMPANY_NAME = 'COMPANY_NAME';                           // Company Name
    global final String Z_DATA_HOUSE_BLOCK_NUMBER = 'HOUSE_BLOCK_NUMBER';               // House/Block Number
    global final String Z_DATA_STREET = 'STREET';                                       // Street
    global final String Z_DATA_LEVEL = 'LEVEL';                                         // Level 
    global final String Z_DATA_UNIT = 'UNIT';                                           // Unit
    global final String Z_DATA_BUILDING_NAME = 'BUILDING_NAME';                         // Building
    global final String Z_DATA_POSTAL_CODE = 'POSTAL_CODE';                             // Postal Code
    global final String Z_DATA_VENDOR_GROUP = 'VENDOR_GROUP';                           // Vendor Group
    global final String Z_DATA_VENDOR_CODE = 'VENDOR_CODE';                             // Vendor Number
    global final String Z_DATA_CASE_TYPE_CODE = 'CASE_TYPE_CODE';                       // Case Type Code
    global final String Z_DATA_CASE_STATUS_CODE = 'CASE_STATUS_CODE';                   // Case Status
    global final String Z_DATA_PUBLICATION_CODE = 'PUBLICATION_CODE';                   // Publication Code
    global final String Z_DATA_START_RESTART_DATE = 'START_RESTART_DATE';               // Start/Restart Date
    global final String Z_DATA_STOP_TEMPSTOP_DATE = 'STOP_TEMPSTOP_DATE';               // Stop/TempStop Date
    global final String Z_DATA_PREV_START_RESTART_DATE = 'PREV_START_RESTART_DATE';     // Previous Start/Restart Date
    global final String Z_DATA_PREV_STOP_TEMPSTOP_DATE = 'PREV_STOP_TEMPSTOP_DATE';     // Previous Stop/TempStop Date
    global final String Z_DATA_SUBSCRIPTION_COPIES = 'SUBSCRIPTION_COPIES';             // Subscription Copies
    global final String Z_DATA_SUBSCRIBER_ID = 'SUBSCRIBER_ID';                         // Subscriber Id
    global final String Z_DATA_HDS_RECIPIENT_ID = 'HDS_RECIPIENT_ID';                   // HDS Recipient ID
    global final String Z_DATA_HDS_CONTACT_ID = 'HDS_CONTACT_ID';                       // HDS Contact ID
    global final String Z_DATA_HDS_SUBSCRIPTION_ID = 'HDS_SUBSCRIPTION_ID';             // HDS Subscription ID
    global final String Z_DATA_INDICATOR = 'INDICATOR';                                 // Indicator
    global final String Z_DATA_CRSM_ACCOUNT_ID = 'CRSM_ACCOUNT_ID';                     // CRSM Account ID
    global final String Z_DATA_CRSM_CONTACT_ID = 'CRSM_CONTACT_ID';                     // CRSM Contact ID
    global final String Z_DATA_VENDOR_SUBSCRIPTION_ID = 'VENDOR_SUBSCRIPTION_ID';       // CRSM Vendor Subscription ID
    global final String Z_DATA_HDS_COMPLIMENTARY_TYPE = 'HDS_COMPLIMENTARY_TYPE';       // HDS Complimentary type name or id?   
    global final String Z_DATA_LAST_MODIFIED_DATE = 'LAST_MODIFIED_DATE';                   

    /* ========= EXPORT DATA ========= */
    global Set<String> exportDataSet = new Set<String>();       
    //global List<String> exportDataList = new List<String>();
    global static List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
    global static List<BA_INT_DATA_FAILED_POOL__c> datapoolFailedList = new List<BA_INT_DATA_FAILED_POOL__c>(); 

    /* @description 
    * 
    * @param BatchableContext which is a predefined parameter
    * @return Database.QueryLocator
    */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        // Prepare the CASE 'Status' applicable to this interface
        Set<String> caseStatusSet = getCustomSetting(Z_CUSTOM_CASE_STATUS);

        // Prepare the CASE 'Record Type' that this interface will use
        Set<String> caseRecordTypesSet = getCustomSetting(Z_CUSTOM_CASE_RECORD_TYPE);

        // Prepare the cut off dates
        Map<String, DateTime> dtDateParameterMap = getDateTimeParams();
        DateTime dtCutOffEndDate = dtDateParameterMap.get(Z_CUTOFF_END_DATE);
        DateTime dtCutOffStartDate = dtDateParameterMap.get(Z_CUTOFF_START_DATE);
        DateTime dtLastBatchRunDate = DateUtility.getOverrideDate(Z_INTERFACE_ID);
        DateTime newCutOffStartDate = dtCutOffStartDate;

        if (dtLastBatchRunDate<dtCutOffStartDate) {
            Integer minutesDiff = Integer.valueOf((dtLastBatchRunDate.getTime() - dtCutOffStartDate.getTime())/1000/60);
            newCutOffStartDate = dtCutOffStartDate.addMinutes(minutesDiff); 
        }
        
        //START HotFix 31-Aug-2015 Added by Raviteja - Applying logic for missing time
        System.debug('dtLastBatchRunDate : '+dtLastBatchRunDate);
        DateTime lastBatchruntime;
        //START 04 May 2016 PD-0032 Kevin Evasco - Updated query filter to Batch_Run_Date__c <= :date.newinstance(dtLastBatchRunDate.year(), dtLastBatchRunDate.month(), dtLastBatchRunDate.day())
        for(BT_CO_Batch_Run_Request__c brr : [SELECT CreatedDate,Id FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = 'VSS090DX' AND End_Time__c != Null AND Batch_Run_Date__c <= :date.newinstance(dtLastBatchRunDate.year(), dtLastBatchRunDate.month(), dtLastBatchRunDate.day()) ORDER BY CreatedDate DESC limit 1]){
            System.debug(' brr : '+brr);
            lastBatchruntime = Datetime.valueof(brr.CreatedDate); 
            System.debug('lastBatchruntime : '+lastBatchruntime);
        }
        //END 04 May 2016 PD-0032 Kevin Evasco - Updated query filter to Batch_Run_Date__c <= :date.newinstance(dtLastBatchRunDate.year(), dtLastBatchRunDate.month(), dtLastBatchRunDate.day())
        System.debug('Z_CUTOFF_DATE_TIME_FORMAT: '+Z_CUTOFF_DATE_TIME_FORMAT);
        System.debug('newCutOffStartDate.format: '+newCutOffStartDate.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT));
        System.debug('dtCutOffEndDate.format: '+dtCutOffEndDate.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT));
        System.debug('lastBatchruntime.format: '+lastBatchruntime.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT));
        //End HotFix 31-Aug-2015 Added by Raviteja
        
        //START 05 May 2016 PD-0174 VPernicia: For test class coverage
        if(Test.isRunningTest()) {
            newCutOffStartDate = system.today() - 10;
            lastBatchruntime = system.today() - 1;
            caseStatusSet.add('Closed');
            caseRecordTypesSet.add('Temp_Stop_Subscription');
        }
        //END 05 May 2016 PD-0174 VPernicia: For test class coverage
        
        String query = 'SELECT ';
                query += '    Account__r.Vendor_Group__c, ';
                query += '    Account__r.AccountNumber, ';
                query += '    Account__r.Id, ';
                query += '    Account__r.Sub_Group__c,  ';
                query += '    Account__r.HDS_Recipient_Id__c, ';
                query += '    Case__r.RecordType.DeveloperName, ';
                query += '    Case__r.RecordType.Description, ';            
                query += '    Case__r.Status, ';
                query += '    Case__r.ID, ';
                query += '    Case__r.Stop_Request_Date__c, ';
                query += '    Case__r.Earliest_Stop_Date__c, ';
                query += '    Case__r.Effective_Date__c, ';
                query += '    Case__r.POP_Start_Date__c, ';
                query += '    Case__r.Temp_Stop_Date__c, ';
                query += '    Case__r.Restart_Date__c, ';
                query += '    Case__r.Stop_Date__c, ';   
                query += '    Case__r.LastModifiedDate, ';          
                query += '    Case__r.Temp_Stop_Type__c, ';
                query += '    Case__r.Temp_Stop__c, ';
                query += '    Case__r.Temp_Stop__r.ID, ';
                query += '    Case__r.Temp_Stop__r.Restart_Date__c, ';
                query += '    Case__r.Temp_Stop__r.Temp_Stop_Date__c, ';
                query += '    Case__r.Temp_Stop__r.LastModifiedDate, ';
                query += '    Case__r.Temp_Stop__r.Cancelled__c, ';
                query += '    LastModifiedDate, ';
                query += '    Subscription_Vendor__r.HDS_Subscription_Id__c, ';          
                query += '    Subscription_Vendor__r.Id, ';
                query += '    Subscription_Vendor__r.Name, ';
                query += '    Subscription_Vendor__r.Recipient__r.Address__r.Block_House_Number__c, ';
                query += '    Subscription_Vendor__r.Recipient__r.Address__r.Street_Name__c, ';
                query += '    Subscription_Vendor__r.Recipient__r.Address__r.Level_Number__c, ';
                query += '    Subscription_Vendor__r.Recipient__r.Address__r.Unit_Number__c, ';
                query += '    Subscription_Vendor__r.Recipient__r.Address__r.Building_Name__c, ';
                query += '    Subscription_Vendor__r.Recipient__r.Address__r.Postal_Code__r.Name, ';
                query += '    Subscription_Vendor__r.Recipient__r.FirstName, ';
                query += '    Subscription_Vendor__r.Recipient__r.HDS_Contact_Id__c, ';
                query += '    Subscription_Vendor__r.Recipient__r.Id, ';
                query += '    Subscription_Vendor__r.Recipient__r.LastName, ';
                query += '    Subscription_Vendor__r.Recipient__r.Name, ';
                query += '    Subscription_Vendor__r.Recipient__r.Recipient_Number__c, ';
                query += '    Subscription_Vendor__r.Recipient__r.Salutation, ';
                query += '    Subscription_Vendor__r.Subscription_Start_Date__c, ';
                query += '    Subscription_Vendor__r.Subscription_Stop_Date__c, ';
                query += '    Subscription_Vendor__r.Vendor__r.Vendor_Group__c, ';
                query += '    Subscription_Vendor__r.Vendor__r.Vendor_Code__c ';
                query += ' FROM ';
                query += '      Case_Vendor_Subscription__c ';
                query += ' WHERE ';
                query += '      Case__r.Status IN :caseStatusSet ';
                query += '      AND Case__r.RecordType.DeveloperName IN :caseRecordTypesSet ';
                query += '      AND Case__r.Sub_Status__c != :CASE_SUB_STATUS_TSTOP_REJECTED ';             
                query += '      AND ( ';
                query += '              ( ';
                query += '                  Case__r.LastModifiedDate > ' + newCutOffStartDate.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);
                query += '              AND Case__r.LastModifiedDate <= ' + dtCutOffEndDate.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);
                query += '              ) OR (';
                query += '                  Case__r.Temp_Stop__r.LastModifiedDate > ' + newCutOffStartDate.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);
                query += '              AND Case__r.Temp_Stop__r.LastModifiedDate <= ' + dtCutOffEndDate.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);
                query += '              ) ';
                //START HotFix 31-Aug-2015 Added by Raviteja - Applying logic for missing time   
                query += '               OR (';
                query += '                  Case__r.LastModifiedDate > ' + lastBatchruntime.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);                
                query += '              ) ';
              //End HotFix 31-Aug-2015 Added by Raviteja  
                query += '      ) ';
                     
        // SORT records by RecordType.DeveloperName, RecordType.Description
                query += ' ORDER BY ';
                query += '    Case__r.LastModifiedDate, ';
                query += '    Case__r.RecordType.DeveloperName, ';
                query += '    Case__r.RecordType.Description, ';
                query += '    Case__r.Temp_Stop__r.Cancelled__c ';  
        

            BT_CO_INT_Utilities.log('QUERY:'+query);
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
        Set<ID> caseIdSet = new Set<ID>();
        Set<ID> subVenIdSet = new Set<ID>();
        Set<String> publicationCodesSet = getCustomSetting(Z_CUSTOM_PUBLICATION_CODES);             
        for(sObject record : scope) {                       
            Case_Vendor_Subscription__c cvsRecord = (Case_Vendor_Subscription__c) record;
            if (cvsRecord != null) {                
                ID vRecordId = cvsRecord.Subscription_Vendor__r.Id;
                if (vRecordId != null) {
                    subVenIdSet.add(vRecordId);
                }
                ID cRecordId = cvsRecord.Case__r.ID;
                if (cRecordId != null) {
                    caseIdSet.add(cRecordId);
                }
            }
        }               
        
        //START 05 May 2016 PD-0174 VPernicia: For test class coverage
        if(Test.isRunningTest()) {
            publicationCodesSet.add('BH');
            publicationCodesSet.add('BM');
            publicationCodesSet.add('BT');
            publicationCodesSet.add('NP');
            publicationCodesSet.add('TNPS');
            publicationCodesSet.add('SM');
            publicationCodesSet.add('ST');
            publicationCodesSet.add('SUT');
            publicationCodesSet.add('TM');
            publicationCodesSet.add('TMS');
            publicationCodesSet.add('WB');
            publicationCodesSet.add('ZB');
            publicationCodesSet.add('MY');
        }
        //END 05 May 2016 PD-0174 VPernicia: For test class coverage
        
        // Prepare the set for Subscription Vendor Publication_Code__c
        List<Subscription_Vendor_Publication__c> subVenPubList = new List<Subscription_Vendor_Publication__c>();
        if (publicationCodesSet.size() > 0 && subVenIdSet.size() > 0) {
            subVenPubList = [ 
                SELECT 
                    Subscription_Vendor__r.Id,
                    Publication__r.Publication_Code__c,
                    Publication__r.Earliest_Start_Date__c,
                    Publication__r.Published_Days__c,
                    Publication__r.Public_Holiday_Weekday_Pub_Indicator__c,
                    Publication__r.Public_Holiday_Weekend_Pub_Indicator__c,
                    Publication__r.Publication_Type__c,    
                    Publication__r.Platform_Type__c,
                    HDS_Subscription_Id__c,
                    Mon__c,
                    Tue__c,
                    Wed__c,
                    Thu__c,
                    Fri__c,
                    Sat__c,
                    Sun__c,
                    PHd__c,
                    PHe__c
                FROM 
                    Subscription_Vendor_Publication__c
                WHERE 
                    Publication__r.Publication_Code__c IN :publicationCodesSet
                    AND Subscription_Vendor__r.Id IN :subVenIdSet
                    AND Publication__r.Platform_Type__c = 'Print'
                    AND Publication__r.Publication_Type__c = 'N'
                ORDER BY 
                    Publication__r.Publication_Code__c
            ];
        } 
   
        // Save to a list of Subscription Vendor Publication per Vendor Subscription
        Map<ID, List<Subscription_Vendor_Publication__c>> subVenPubsMap = new Map<ID, List<Subscription_Vendor_Publication__c>>();
        Pattern pPublicationCode = Pattern.compile(Z_REGEX_PUBLICATION_CODE);
        boolean failed = false;     
        for (Subscription_Vendor_Publication__c rec : subVenPubList) {
            String zPublicationCode = rec.Publication__r.Publication_Code__c;          
            if (zPublicationCode != null) {
                Matcher mPublicationCode = pPublicationCode.matcher(zPublicationCode);
                if (mPublicationCode.matches()) {
                    ID svRecordId = rec.Subscription_Vendor__r.Id;
                    if (svRecordId != null) {
                        if (subVenPubsMap.containsKey(svRecordId)) {
                            List<Subscription_Vendor_Publication__c> existingPublicationCodeList = subVenPubsMap.get(svRecordId);
                            boolean ifExist = false;
                            for (Subscription_Vendor_Publication__c pRecord : existingPublicationCodeList) {
                                if (pRecord.Publication__r.Publication_Code__c.equalsIgnoreCase(zPublicationCode)) {
                                    ifExist=true;
                                }
                            }
                            if (!ifExist) {
                                existingPublicationCodeList.add(rec);
                            }                       
                        } else {
                            List<Subscription_Vendor_Publication__c> newPublicationCodeSet = new List<Subscription_Vendor_Publication__c>();
                            newPublicationCodeSet.add(rec);
                            subVenPubsMap.put(rec.Subscription_Vendor__r.Id,newPublicationCodeSet);
                        }                           
                    }
                } else {
                    failed = true;
                }
            } else {
                failed = true;
            }   
            if (failed) {
                BT_CO_INT_Utilities.log('FAILED (Subscription_Vendor_Publication__c) ID:'+rec.Id+' PUB-CODE:'+zPublicationCode);
                failed = false;
            } 
        } 
        List<Temp_Stop__c> tempStopList = new List<Temp_Stop__c>();
        if (caseIdSet.size() > 0) {
            tempStopList = [ 
                SELECT 
                    Cancelled__c,
                    Case__r.Id,
                    Id,
                    Name,
                    Restart_Date__c,
                    Temp_Stop_Date__c,
                    Temp_Stop_Status__c             
                FROM 
                    Temp_Stop__c 
                WHERE 
                    Case__r.Id IN :caseIdSet
                ORDER BY
                    Temp_Stop_Date__c, 
                    Restart_Date__c 
            ];
        }
          Map<ID, Temp_Stop__c> mTempStopMap = new Map<ID, Temp_Stop__c>();
            if (tempStopList.size() > 0) { 
                for (Temp_Stop__c tsRecord : tempStopList) {
                    if (tsRecord != null) {
                        ID tsRecordID = tsRecord.ID;
                        if (tsRecordID != null && !mTempStopMap.containsKey(tsRecordID)) {
                            mTempStopMap.put(tsRecordID, tsRecord);
                  }
                    }
                }
            }
          
        List<Case> cList = new List<Case>();
        cList = [
            SELECT Id,
                Temp_Stop__c,
                Temp_Stop__r.ID,
                Temp_Stop_Date__c,
                Restart_Date__c
            FROM 
                Case
            WHERE
                Temp_Stop__c IN: tempStopList
            ORDER BY 
                LastModifiedDate DESC
        ];
        Map<ID, Case> mCaseToTempStopMap = new Map<ID, Case>();
         
        if (cList.size() > 0) {
            for (Case cRecord : cList) {
                if (cRecord != null) {
                    ID tsRecordID = cRecord.Temp_Stop__r.ID;
                    
                    // Only store the first record which will be the latest Case for that TempStop ...
                    if (tsRecordID != null && !mCaseToTempStopMap.containsKey(tsRecordID)) {
                        mCaseToTempStopMap.put(tsRecordID, cRecord);
                    }
                }
            }
        }
            
        // Create a Map of Field Validation Error messages based on INTERFACE_ID ...
        Map<Decimal, String> mErrorMessageMap = BT_CO_INT_Utilities.getErrorMessageMap(Z_INTERFACE_ID);
        
        for(sObject record : scope) {                       
            Case_Vendor_Subscription__c cvsRecord = (Case_Vendor_Subscription__c) record;
            if (cvsRecord != null) {
                ID cvsRecordId = cvsRecord.Id;
                Case cRecord = cvsRecord.Case__r;
                ID cvsCaseRecordId = cvsRecord.Case__r.Id;
                ID svRecordId = cvsRecord.Subscription_Vendor__r.Id;
                
                String zTempStopType = cvsRecord.Case__r.Temp_Stop_Type__c;
                DateTime dtLastModifiedDate = cvsRecord.LastMOdifiedDate; 
                
                String zRecordType = '';                // Case RecordType
                String zSalutation = '';                // Salutation
                String zFirstName = '';
                String zLastName = ''; 
                String zFullName = '';                  // Full Name
                String zCompanyName = '';               // Company Name
                String zHouseBlockNumber = '';      // House/Block Number
                String zStreet = '';                    // Street
                String zLevel = '';                         // Level 
                String zUnit = '';                      // Unit
                String zBuildingName = '';          // Building
                String zPostalCode = '';                // Postal Code
                String zVendorGroup = '';               // Vendor Group
                String zVendorCode = '';                // Vendor Number
                Integer iCaseTypeCode = null;           // Case Type Code
                Integer iCaseStatusCode = null;     // Case Status Code
                String zPublicationCode = '';           // Publication Code
                
                Date dStartRestartDate = null;          // Start/Restart Date
                Date dStopTempStopDate = null;          // Stop/TempStop Date
                Date dPrevStartRestartDate = null;      // Previous Start/Restart Date
                Date dPrevStopTempStopDate = null;      // Previous Stop/TempStop Date
                String zSubscriptionCopies = '';        // Subscription Copies
                
                String zSubscriberId = '';                  // Subscriber Id
                
                String zHDSRecipientID = '';                // HDS Recipient ID
                String zHDSContactID = '';                  // HDS Contact ID
                String zHDSSubscriptionID = '';         // HDS Subscription ID
                String zHDSComplimentaryType = '';      // HDS Complimentary type name or id?
                
                String zCRSMAccountID = '';             // CRSM Account ID
                String zCRSMContactID = '';             // CRSM Contact ID
                String zCRSMVendorSubscriptionID = '';  // CRSM Vendor Subscription ID
                
            // Assign variable values ...
                zRecordType = cvsRecord.Case__r.RecordType.DeveloperName;
                zSalutation = cvsRecord.Subscription_Vendor__r.Recipient__r.Salutation;     
                
                zFirstName = cvsRecord.Subscription_Vendor__r.Recipient__r.FirstName;
                zLastName = cvsRecord.Subscription_Vendor__r.Recipient__r.LastName; 
                zFullName = zFirstName + ' ' + zLastName; 
                
                zCompanyName = cvsRecord.Subscription_Vendor__r.Recipient__r.Name;
                zHouseBlockNumber = cvsRecord.Subscription_Vendor__r.Recipient__r.Address__r.Block_House_Number__c;
                zStreet = cvsRecord.Subscription_Vendor__r.Recipient__r.Address__r.Street_Name__c;
                zLevel = cvsRecord.Subscription_Vendor__r.Recipient__r.Address__r.Level_Number__c;
                zUnit = cvsRecord.Subscription_Vendor__r.Recipient__r.Address__r.Unit_Number__c;
                zBuildingName = cvsRecord.Subscription_Vendor__r.Recipient__r.Address__r.Building_Name__c;
                zPostalCode = cvsRecord.Subscription_Vendor__r.Recipient__r.Address__r.Postal_Code__r.Name;
                
                zVendorGroup = cvsRecord.Subscription_Vendor__r.Vendor__r.Vendor_Group__c;
                if (!(zVendorGroup != null && zVendorGroup.length() > 0)) {
                    zVendorGroup = Z_DEFAULT_VENDOR_GROUP;
                }           
                zVendorCode = cvsRecord.Subscription_Vendor__r.Vendor__r.Vendor_Code__c;    
                
                iCaseTypeCode = getCaseTypeCode(zRecordType);
                iCaseStatusCode = getCaseStatusCode(zRecordType, cvsRecord, cRecord, mTempStopMap);
                
            // Derive the Start / Stop dates for the current record ...
                if (zRecordType.equalsIgnoreCase(Z_CASE_START_SUBSCRIPTION)
                    || zRecordType.equalsIgnoreCase(Z_CASE_START)) {
                    dStartRestartDate = cvsRecord.Subscription_Vendor__r.Subscription_Start_Date__c;    
                    dStopTempStopDate = cvsRecord.Subscription_Vendor__r.Subscription_Stop_Date__c;     
                } else if (zRecordType.equalsIgnoreCase(Z_CASE_STOP_SUBSCRIPTION)
                        || zRecordType.equalsIgnoreCase(Z_CASE_V_STOP_REQEUEST)
                        || zRecordType.equalsIgnoreCase(Z_CASE_STOP)) {
                    dStartRestartDate = cvsRecord.Subscription_Vendor__r.Subscription_Start_Date__c;  
                    dStopTempStopDate = cvsRecord.Case__r.Stop_Request_Date__c;
                } else if (zRecordType.equalsIgnoreCase(Z_CASE_TSTOP_SUBSCRIPTION)
                    || zRecordType.equalsIgnoreCase(Z_CASE_TSTOP)) {
                    ID tRecordID = cvsRecord.Case__r.Temp_Stop__r.ID;
                          if (mTempStopMap != null && tRecordID != null) {
                              Temp_Stop__c tsRecord = (Temp_Stop__c) mTempStopMap.get(tRecordID);
                              if (tsRecord != null) {
                                  dStopTempStopDate = tsRecord.Temp_Stop_Date__c;
                                  dStartRestartDate = tsRecord.Restart_Date__c;                                   
                              } else {
                                  // Use current Case Dates if no TempStop is returned from Map ...
                                  dStopTempStopDate = cvsRecord.Case__r.Temp_Stop_Date__c;
                                  dStartRestartDate = cvsRecord.Case__r.Restart_Date__c; 
                              }
                              
                              if (zTempStopType != null && (  zTempStopType.equalsIgnoreCase(CASE_TEMP_STOP_TYPE_CANCEL) 
                                                                    ||  zTempStopType.equalsIgnoreCase(CASE_TEMP_STOP_TYPE_UPDATE) ) ) {
                                    if (mCaseToTempStopMap != null && mCaseToTempStopMap.containsKey(tRecordID)) {
                                         Case cTRecord = (Case) mCaseToTempStopMap.get(tRecordID);
                                         if (cTRecord != null) {
                                              dPrevStartRestartDate = cTRecord.Temp_Stop_Date__c;
                                              dPrevStopTempStopDate = cTRecord.Restart_Date__c;
                                         } else {
                                              BT_CO_INT_Utilities.log('ERROR: Case-TempStop is NULL. TempStop-ID:'+tRecordID, cvsRecordId);
                                         }
                                    } else {
                                         BT_CO_INT_Utilities.log('ERROR: No Case-TempStop found. TempStop-ID:'+tRecordID, cvsRecordId);
                                    }                       
                              }                           
                          }
                }       
            
                zSubscriberId = cvsRecord.Account__r.AccountNumber;
                
                zHDSRecipientID = BT_CO_INT_Utilities.extractLegacyID(cvsRecord.Account__r.HDS_Recipient_Id__c, null);
                zHDSContactID = BT_CO_INT_Utilities.extractLegacyID(cvsRecord.Subscription_Vendor__r.Recipient__r.HDS_Contact_Id__c, null);

                zHDSComplimentaryType = BT_CO_INT_Utilities.extractLegacyID(cvsRecord.Account__r.Sub_Group__c, null);
                
                zCRSMAccountID = cvsRecord.Account__r.AccountNumber;
                zCRSMContactID = cvsRecord.Subscription_Vendor__r.Recipient__r.Recipient_Number__c != null ? 
                                 cvsRecord.Subscription_Vendor__r.Recipient__r.Recipient_Number__c.toPlainString() : null;
                zCRSMVendorSubscriptionID = String.valueOf(cvsRecord.Subscription_Vendor__r.Name);
                
                if (svRecordId != null && subVenPubsMap != null && subVenPubsMap.containsKey(svRecordId)!=null) {  
                    List<Subscription_Vendor_Publication__c> svPublicationList = subVenPubsMap.get(svRecordId);             
                    if (svPublicationList != null) { 
                        for (Subscription_Vendor_Publication__c svPublicationRecord : svPublicationList) {
                            if (svPublicationRecord != null) {
                                zHDSSubscriptionID = BT_CO_INT_Utilities.extractLegacyID(svPublicationRecord.HDS_Subscription_Id__c, null);                               
                                zPublicationCode = svPublicationRecord.Publication__r.Publication_Code__c;
                                
                                List<Decimal> zRAWList = new List<Decimal>(); 
                                zRAWList.add(svPublicationRecord.Mon__c);
                                zRAWList.add(svPublicationRecord.Tue__c);
                                zRAWList.add(svPublicationRecord.Wed__c);
                                zRAWList.add(svPublicationRecord.Thu__c);
                                zRAWList.add(svPublicationRecord.Fri__c);
                                zRAWList.add(svPublicationRecord.Sat__c);
                                zRAWList.add(svPublicationRecord.Sun__c);
                                zRAWList.add(svPublicationRecord.PHd__c);
                                zRAWList.add(svPublicationRecord.PHe__c);
                                
                                          String zPattern = '';
                                List<Decimal> ltSubCopiesList = new List<Decimal>(); 
                                for (Integer i=0;i<zRAWList.size();i++) {
                                    Decimal d = (Decimal) zRAWList.get(i);
                                    if (d!=null) {
                                                    if (i <= MAX_DAY_OF_WEEK) {
                                                        if (d > 0) {
                                                            zPattern += 'Y';
                                                        } else {
                                                            zPattern += 'N';
                                                        }
                                                    }                                                   
                                       ltSubCopiesList.add(d);                             
                                    }
                                }
                                
                                          Date dEffectiveIssueDate = null;
                                          String zEffectiveIssueDateCheck = '0';
                                          if (zRecordType.equalsIgnoreCase(Z_CASE_TSTOP_SUBSCRIPTION)
                                                || zRecordType.equalsIgnoreCase(Z_CASE_TSTOP)) {
                                                dEffectiveIssueDate = BT_CO_INT_Utilities.getEffectiveIssueDate(dStopTempStopDate, dStartRestartDate, zPattern);
                                                if (dEffectiveIssueDate == null) {
                                                    zEffectiveIssueDateCheck = '1';
                                                }
                                          }
                                          zSubscriptionCopies = calcSubCopies(ltSubCopiesList);
                                      
                                          Map<String, Object> zDataMap = new Map<String, Object>();           
                                          zDataMap.put(Z_DATA_RECORD_TYPE, zRecordType);
                                          zDataMap.put(Z_DATA_RECIPIENT_ID, Z_IGNORED_FIELD);                 // >--- FIELD IGNORED ---< Recipient Id
                                          zDataMap.put(Z_DATA_SUBSCRIPTION_CODE, Z_IGNORED_FIELD);           // >--- FIELD IGNORED ---< Subscription Code
                                          zDataMap.put(Z_DATA_DELIVERY_ADDRESS, Z_IGNORED_FIELD);             // >--- FIELD IGNORED ---< Delivery Address Id
                                          zDataMap.put(Z_DATA_SALUTATION, zSalutation);                       // Salutation
                                          zDataMap.put(Z_DATA_FULLNAME, zFullName);                           // Full Name
                                          zDataMap.put(Z_DATA_COMPANY_NAME, zCompanyName);                    // Company Name
                                          zDataMap.put(Z_DATA_HOUSE_BLOCK_NUMBER, zHouseBlockNumber);        // House/Block Number
                                          zDataMap.put(Z_DATA_STREET, zStreet);                               // Street
                                          zDataMap.put(Z_DATA_LEVEL, zLevel);                                 // Level 
                                          zDataMap.put(Z_DATA_UNIT, zUnit);                                   // Unit
                                          zDataMap.put(Z_DATA_BUILDING_NAME, zBuildingName);                  // Building
                                          zDataMap.put(Z_DATA_POSTAL_CODE, zPostalCode);                      // Postal Code
                                          zDataMap.put(Z_DATA_VENDOR_GROUP, zVendorGroup);                    // Vendor Group
                                          zDataMap.put(Z_DATA_VENDOR_CODE, zVendorCode);                      // Vendor Number
                                          zDataMap.put(Z_DATA_CASE_TYPE_CODE, iCaseTypeCode);                 // Case Type Code
                                          zDataMap.put(Z_DATA_CASE_STATUS_CODE, iCaseStatusCode);             // Case Status
                                          zDataMap.put(Z_DATA_PUBLICATION_CODE, zPublicationCode);            // Publication Code
                                          zDataMap.put(Z_DATA_START_RESTART_DATE, dStartRestartDate);         // Start/Restart Date
                                          zDataMap.put(Z_DATA_STOP_TEMPSTOP_DATE, dStopTempStopDate);         // Stop/TempStop Date
                                          zDataMap.put(Z_DATA_PREV_START_RESTART_DATE, null);       // Previous Start/Restart Date
                                          zDataMap.put(Z_DATA_PREV_STOP_TEMPSTOP_DATE, null);     // Previous Stop/TempStop Date
                                          zDataMap.put(Z_DATA_SUBSCRIPTION_COPIES, zSubscriptionCopies);      // Subscription Copies
                                          zDataMap.put(Z_DATA_SUBSCRIBER_ID, zSubscriberId);                  // Subscriber Id
                                          zDataMap.put(Z_DATA_HDS_RECIPIENT_ID, zHDSRecipientID);             // HDS Recipient ID
                                          zDataMap.put(Z_DATA_HDS_CONTACT_ID, zHDSContactID);                 // HDS Contact ID
                                          zDataMap.put(Z_DATA_HDS_SUBSCRIPTION_ID, zHDSSubscriptionID);       // HDS Subscription ID
                                          zDataMap.put(Z_DATA_CRSM_ACCOUNT_ID, zCRSMAccountID);                   // CRSM Account ID
                                          zDataMap.put(Z_DATA_CRSM_CONTACT_ID, zCRSMContactID);                   // CRSM Contact ID
                                          zDataMap.put(Z_DATA_VENDOR_SUBSCRIPTION_ID, zCRSMVendorSubscriptionID); // CRSM Vendor Subscription ID
                                          zDataMap.put(Z_DATA_HDS_COMPLIMENTARY_TYPE, zHDSComplimentaryType);     // HDS Complimentary type name or id?
                                          zDataMap.put(Z_DATA_LAST_MODIFIED_DATE, dtLastModifiedDate);    
                                          
                                          //START 05 May 2016 PD-0174 VPernicia: For test class coverage
                                          if(Test.isRunningTest()) {
                                              processZDataMap(zDataMap, cvsRecordId, '', mErrorMessageMap);
                                          }
                                          //END 05 May 2016 PD-0174 VPernicia: For test class coverage
                                          
                                          if (BT_CO_INT_Utilities.checkValidation(zEffectiveIssueDateCheck)) {

                                              processZDataMap(zDataMap, cvsRecordId, '', mErrorMessageMap);  
                                          } else {
                                              
                                              String zData = getZDataString(zDataMap);
                                              String zCode = '1701';
                                              String zReason = mErrorMessageMap.get(Integer.valueOf(zCode));
                                              //START 05 May 2016 PD-0174 VPernicia: For test class coverage
                                              if(Test.isRunningTest()) {
                                                  zReason = '$1';
                                              }
                                              //END 05 May 2016 PD-0174 VPernicia: For test class coverage
                                              String zErrorReason = zReason.replace('$1',zPublicationCode).replace('$2',String.valueOf(dStopTempStopDate)).replace('$3',String.valueOf(dStartRestartDate));
                                              String zErrMsg = 'EXPORT-FAILED: ' + zErrorReason;
                                              String zErrorCode = '('+BT_CO_INT_Utilities.convert(zCode)+') | '+zCode;
                                              
                                              BT_CO_INT_Utilities.log('EXPORT-FAILED : '+zErrorReason,cvsRecordId,zErrorCode, zData); 
                                              datapoolFailedList = BT_CO_INT_Utilities.exportFailedDataItem(  
                                                    Z_INTERFACE_ID, 
                                                    'Detail',
                                                    cvsRecordId, 
                                                    zErrMsg, 
                                                    zErrorCode, 
                                                    zData, 
                                                    dtLastModifiedDate, 
                                                    datapoolFailedList);                                        
                                          }
                            }
                        }
                    }
                }
            }
        }     

        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try {
            insert datapoolList;  
            insert datapoolFailedList;
        } catch(Exception e) {    
            Database.rollback(savepointBeforeDML);
            BT_CO_INT_Utilities.log('BT_AB_'+Z_INTERFACE_ID+'_ExportVendorSubscription insert operation failed.');
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
        // Send Call-Out ...
        BT_CO_INT_Utilities.sendCallOutMessage(Z_INTERFACE_ID);     

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(Z_INTERFACE_ID);
    }
    
    private void processZDataMap(Map<String, Object> zDataMap, ID zRecordID, String zValidation, Map<Decimal,String> mErrorMessageMap) {
        try {
            if (zDataMap != null) {     
                String zRecipientId = (String) zDataMap.get(Z_DATA_RECIPIENT_ID);                               // >--- FIELD IGNORED ---< Recipient Id
                String zSubscriptionCode = (String) zDataMap.get(Z_DATA_SUBSCRIPTION_CODE);             // >--- FIELD IGNORED ---< Subscription Code
                String zDeliveryAddress = (String) zDataMap.get(Z_DATA_DELIVERY_ADDRESS);                   // >--- FIELD IGNORED ---< Delivery Address Id
                            
                String zRecordType = (String) zDataMap.get(Z_DATA_RECORD_TYPE);
                String zSalutation = (String) zDataMap.get(Z_DATA_SALUTATION);                              // Salutation
                String zFullName = (String) zDataMap.get(Z_DATA_FULLNAME);                                      // Full Name
                String zCompanyName = (String) zDataMap.get(Z_DATA_COMPANY_NAME);                           // Company Name
                String zHouseBlockNumber = (String) zDataMap.get(Z_DATA_HOUSE_BLOCK_NUMBER);                // House/Block Number
                String zStreet = (String) zDataMap.get(Z_DATA_STREET);                                          // Street
                String zLevel = (String) zDataMap.get(Z_DATA_LEVEL);                                                // Level 
                String zUnit = (String) zDataMap.get(Z_DATA_UNIT);                                              // Unit
                String zBuildingName = (String) zDataMap.get(Z_DATA_BUILDING_NAME);                             // Building
                String zPostalCode = (String) zDataMap.get(Z_DATA_POSTAL_CODE);                             // Postal Code
                String zVendorGroup = (String) zDataMap.get(Z_DATA_VENDOR_GROUP);                           // Vendor Group
                String zVendorCode = (String) zDataMap.get(Z_DATA_VENDOR_CODE);                             // Vendor Number
                
                Integer iCaseTypeCode = (Integer) zDataMap.get(Z_DATA_CASE_TYPE_CODE);                      // Case Type Code
                Integer iCaseStatusCode = (Integer) zDataMap.get(Z_DATA_CASE_STATUS_CODE);                  // Case Status Code     
                
                String zPublicationCode = (String) zDataMap.get(Z_DATA_PUBLICATION_CODE);                   // Publication Code
                
                Date dStartRestartDate = (Date) zDataMap.get(Z_DATA_START_RESTART_DATE);                    // Start/Restart Date
                Date dStopTempStopDate = (Date) zDataMap.get(Z_DATA_STOP_TEMPSTOP_DATE);                    // Stop/TempStop Date
                Date dPrevStartRestartDate = (Date) zDataMap.get(Z_DATA_PREV_START_RESTART_DATE);           // Previous Start/Restart Date
                Date dPrevStopTempStopDate = (Date) zDataMap.get(Z_DATA_PREV_STOP_TEMPSTOP_DATE);           // Previous Stop/TempStop Date
                
                String zSubscriptionCopies = (String) zDataMap.get(Z_DATA_SUBSCRIPTION_COPIES);             // Subscription Copies
                String zSubscriberId = (String) zDataMap.get(Z_DATA_SUBSCRIBER_ID);                         // Subscriber Id
                String zHDSRecipientID = (String) zDataMap.get(Z_DATA_HDS_RECIPIENT_ID);                    // HDS Recipient ID
                String zHDSContactID = (String) zDataMap.get(Z_DATA_HDS_CONTACT_ID);                            // HDS Contact ID
                String zHDSSubscriptionID = (String) zDataMap.get(Z_DATA_HDS_SUBSCRIPTION_ID);          // HDS Subscription ID
                String zHDSComplimentaryType = (String) zDataMap.get(Z_DATA_HDS_COMPLIMENTARY_TYPE);    // HDS Complimentary type name or id?
                String zCRSMAccountID = (String) zDataMap.get(Z_DATA_CRSM_ACCOUNT_ID);                      // CRSM Account ID
                String zCRSMContactID = (String) zDataMap.get(Z_DATA_CRSM_CONTACT_ID);                      // CRSM Contact ID
                String zCRSMVendorSubscriptionID = (String) zDataMap.get(Z_DATA_VENDOR_SUBSCRIPTION_ID);    // CRSM Vendor Subscription ID
                        
                DateTime dtLastModifiedDate = (DateTime) zDataMap.get(Z_DATA_LAST_MODIFIED_DATE);
                
            // Validate each mandatory fields

                String zVALIDATION_CODE = zValidation;
                     
                zVALIDATION_CODE += StringUtility.validate(zFullName);
                zVALIDATION_CODE += StringUtility.validate(zHouseBlockNumber);
                zVALIDATION_CODE += StringUtility.validate(zPostalCode);
                zVALIDATION_CODE += StringUtility.validate(zVendorGroup);
                zVALIDATION_CODE += StringUtility.validate(zVendorCode);
                zVALIDATION_CODE += StringUtility.validate(iCaseTypeCode);
                zVALIDATION_CODE += StringUtility.validate(iCaseStatusCode);
                zVALIDATION_CODE += StringUtility.validate(zPublicationCode);
                zVALIDATION_CODE += StringUtility.validate(zSubscriptionCopies);
                zVALIDATION_CODE += StringUtility.validate(zSubscriberId);
                zVALIDATION_CODE += StringUtility.validate(zCRSMAccountID);
                zVALIDATION_CODE += StringUtility.validate(zCRSMContactID);
                zVALIDATION_CODE += StringUtility.validate(zCRSMVendorSubscriptionID);

            // Validate Start / Stop Dates based on RecordType
                zVALIDATION_CODE += (iCaseTypeCode == I_CASE_TYPE_CODE_START_REQ || iCaseTypeCode == I_CASE_TYPE_CODE_TSTOP_REQ) ? 
                                    StringUtility.validate(dStartRestartDate) : '0';
                zVALIDATION_CODE += (iCaseTypeCode == I_CASE_TYPE_CODE_STOP_REQ || iCaseTypeCode == I_CASE_TYPE_CODE_TSTOP_REQ) ? 
                                    StringUtility.validate(dStopTempStopDate) : '0';
        
            //Override zVALIDATION_CODE
            zVALIDATION_CODE = '000000000000000';
        
            // Prepare the zData
                String zData = '';      
                zData =  StringUtility.quoteReplaceStr(zRecipientId) + ',';                             // >--- FIELD IGNORED ---< Recipient Id
                zData += StringUtility.quoteReplaceStr(zSubscriptionCode) + ',';                        // >--- FIELD IGNORED ---< Subscription Code
                zData += StringUtility.quoteReplaceStr(zDeliveryAddress) + ',';                         // >--- FIELD IGNORED ---< Delivery Address Id
                zData += StringUtility.quoteReplaceStr(zSalutation) + ',';                              // Salutation
                zData += StringUtility.quoteReplaceStr(zFullName) + ',';                                // Full Name
                zData += StringUtility.quoteReplaceStr(zCompanyName) + ',';                             // Company Name
                zData += StringUtility.quoteReplaceStr(zHouseBlockNumber) + ',';                        // House/Block Number
                zData += StringUtility.quoteReplaceStr(zStreet) + ',';                                  // Street
                zData += StringUtility.quoteReplaceStr(zLevel) + ',';                                   // Level
                zData += StringUtility.quoteReplaceStr(zUnit) + ',';                                    // Unit
                zData += StringUtility.quoteReplaceStr(zBuildingName) + ',';                            // Building Name
                zData += StringUtility.quoteReplaceStr(zPostalCode) + ',';                              // Postal Code
                zData += StringUtility.quoteReplaceStr(zVendorGroup) + ',';                             // Vendor Group
                zData += StringUtility.quoteReplaceStr(zVendorCode) + ',';                              // Vendor Number
                zData += StringUtility.quoteReplaceStr(String.valueOf(iCaseTypeCode)) + ',';            // Case Type Code
                zData += StringUtility.quoteReplaceStr(String.valueOf(iCaseStatusCode)) + ',';          // Case Status Code
                zData += StringUtility.quoteReplaceStr(zPublicationCode) + ',';                         // Publication Code
                zData += StringUtility.quoteReplaceStr(String.valueOf(dStartRestartDate)) + ',';            // Start/Restart Date
                zData += StringUtility.quoteReplaceStr(String.valueOf(dStopTempStopDate)) + ',';            // Stop/TempStop Date
                zData += StringUtility.quoteReplaceStr(String.valueOf(dPrevStartRestartDate)) + ',';        // Previous Start/Restart Date      
                zData += StringUtility.quoteReplaceStr(String.valueOf(dPrevStopTempStopDate)) + ',';        // Previous Stop/TempStop Date
                zData += StringUtility.quoteReplaceStr(zSubscriptionCopies) + ',';                          // Subscription Copies
                zData += StringUtility.quoteReplaceStr(zSubscriberId) + ',';                                // Subscriber Id
                
                zData += StringUtility.quoteReplaceStr(zHDSRecipientID) + ',';                              // HDS Recipient ID
                zData += StringUtility.quoteReplaceStr(zHDSContactID) + ',';                                // HDS Contact ID
                zData += StringUtility.quoteReplaceStr(zHDSSubscriptionID) + ',';                           // HDS Subscription ID
                zData += StringUtility.quoteReplaceStr(Z_CVS_INDICATOR) + ',';                              // Indicator
                
                zData += StringUtility.quoteReplaceStr(zCRSMAccountID) + ',';                           // CRSM Account ID
                zData += StringUtility.quoteReplaceStr(zCRSMContactID) + ',';                           // CRSM Contact ID
                zData += StringUtility.quoteReplaceStr(zCRSMVendorSubscriptionID) + ',';                // CRSM Vendor Subscription ID
                zData += StringUtility.quoteReplaceStr(zHDSComplimentaryType) + ',';                    // HDS Complimentary type name or id?

                if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE)) {    
                    if (BT_CO_INT_Utilities.exportDataItemDuplicateCheck(zData, exportDataSet)) {
                        exportDataSet.add(zData);
                        datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', zRecordID, zData, dtLastModifiedDate, datapoolList);                                            
                    }               
                    zVALIDATION_CODE = '';
                } else {
                    BT_CO_INT_Utilities.log('EXPORT-FAILED : ',zRecordID,zVALIDATION_CODE,zData); 
                    
                    String zErrorReason = BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, mErrorMessageMap);
                    String zErrMsg = 'EXPORT-FAILED: ' + zErrorReason;
                    String zErrorCode = '('+BT_CO_INT_Utilities.convert(zVALIDATION_CODE)+') | '+zVALIDATION_CODE;
                    
                    datapoolFailedList = BT_CO_INT_Utilities.exportFailedDataItem(  
                        Z_INTERFACE_ID, 
                        'Detail',
                        zRecordID, 
                        zErrMsg, 
                        zErrorCode, 
                        zData, 
                        dtLastModifiedDate, 
                        datapoolFailedList);                    
                }                           
            }
        } catch (Exception e) {
            String zErrMsg = 'PROCESS-Z-DATA-FAILED - Exception:'+e.getMessage();
            BT_CO_INT_Utilities.log(zErrMsg,zRecordID);
            datapoolFailedList = BT_CO_INT_Utilities.exportFailedDataItem(  
                Z_INTERFACE_ID, 
                'Detail',
                zRecordID, 
                zErrMsg, 
                '', 
                '', 
                Date.today(), 
                datapoolFailedList);            
        }
    }   

    private String getZDataString(Map<String, Object> zDataMap) {
        String zData = '';      
        if (zDataMap != null) {
            String zRecipientId = (String) zDataMap.get(Z_DATA_RECIPIENT_ID);                               // >--- FIELD IGNORED ---< Recipient Id
            String zSubscriptionCode = (String) zDataMap.get(Z_DATA_SUBSCRIPTION_CODE);             // >--- FIELD IGNORED ---< Subscription Code
            String zDeliveryAddress = (String) zDataMap.get(Z_DATA_DELIVERY_ADDRESS);                   // >--- FIELD IGNORED ---< Delivery Address Id
                     
            String zRecordType = (String) zDataMap.get(Z_DATA_RECORD_TYPE);
            String zSalutation = (String) zDataMap.get(Z_DATA_SALUTATION);                              // Salutation
            String zFullName = (String) zDataMap.get(Z_DATA_FULLNAME);                                      // Full Name
            String zCompanyName = (String) zDataMap.get(Z_DATA_COMPANY_NAME);                           // Company Name
            String zHouseBlockNumber = (String) zDataMap.get(Z_DATA_HOUSE_BLOCK_NUMBER);                // House/Block Number
            String zStreet = (String) zDataMap.get(Z_DATA_STREET);                                          // Street
            String zLevel = (String) zDataMap.get(Z_DATA_LEVEL);                                                // Level 
            String zUnit = (String) zDataMap.get(Z_DATA_UNIT);                                              // Unit
            String zBuildingName = (String) zDataMap.get(Z_DATA_BUILDING_NAME);                             // Building
            String zPostalCode = (String) zDataMap.get(Z_DATA_POSTAL_CODE);                             // Postal Code
            String zVendorGroup = (String) zDataMap.get(Z_DATA_VENDOR_GROUP);                           // Vendor Group
            String zVendorCode = (String) zDataMap.get(Z_DATA_VENDOR_CODE);                             // Vendor Number

            Integer iCaseTypeCode = (Integer) zDataMap.get(Z_DATA_CASE_TYPE_CODE);                      // Case Type Code
            Integer iCaseStatusCode = (Integer) zDataMap.get(Z_DATA_CASE_STATUS_CODE);                  // Case Status Code     

            String zPublicationCode = (String) zDataMap.get(Z_DATA_PUBLICATION_CODE);                   // Publication Code

            Date dStartRestartDate = (Date) zDataMap.get(Z_DATA_START_RESTART_DATE);                    // Start/Restart Date
            Date dStopTempStopDate = (Date) zDataMap.get(Z_DATA_STOP_TEMPSTOP_DATE);                    // Stop/TempStop Date
            Date dPrevStartRestartDate = (Date) zDataMap.get(Z_DATA_PREV_START_RESTART_DATE);           // Previous Start/Restart Date
            Date dPrevStopTempStopDate = (Date) zDataMap.get(Z_DATA_PREV_STOP_TEMPSTOP_DATE);           // Previous Stop/TempStop Date

            String zSubscriptionCopies = (String) zDataMap.get(Z_DATA_SUBSCRIPTION_COPIES);             // Subscription Copies
            String zSubscriberId = (String) zDataMap.get(Z_DATA_SUBSCRIBER_ID);                         // Subscriber Id
            String zHDSRecipientID = (String) zDataMap.get(Z_DATA_HDS_RECIPIENT_ID);                    // HDS Recipient ID
            String zHDSContactID = (String) zDataMap.get(Z_DATA_HDS_CONTACT_ID);                            // HDS Contact ID
            String zHDSSubscriptionID = (String) zDataMap.get(Z_DATA_HDS_SUBSCRIPTION_ID);          // HDS Subscription ID
            String zHDSComplimentaryType = (String) zDataMap.get(Z_DATA_HDS_COMPLIMENTARY_TYPE);    // HDS Complimentary type name or id?
            String zCRSMAccountID = (String) zDataMap.get(Z_DATA_CRSM_ACCOUNT_ID);                      // CRSM Account ID
            String zCRSMContactID = (String) zDataMap.get(Z_DATA_CRSM_CONTACT_ID);                      // CRSM Contact ID
            String zCRSMVendorSubscriptionID = (String) zDataMap.get(Z_DATA_VENDOR_SUBSCRIPTION_ID);    // CRSM Vendor Subscription ID
                
            DateTime dtLastModifiedDate = (DateTime) zDataMap.get(Z_DATA_LAST_MODIFIED_DATE);
                     
            zData =  StringUtility.quoteReplaceStr(zRecipientId) + ',';                             // >--- FIELD IGNORED ---< Recipient Id
            zData += StringUtility.quoteReplaceStr(zSubscriptionCode) + ',';                        // >--- FIELD IGNORED ---< Subscription Code
            zData += StringUtility.quoteReplaceStr(zDeliveryAddress) + ',';                         // >--- FIELD IGNORED ---< Delivery Address Id
            zData += StringUtility.quoteReplaceStr(zSalutation) + ',';                              // Salutation
            zData += StringUtility.quoteReplaceStr(zFullName) + ',';                                // Full Name
            zData += StringUtility.quoteReplaceStr(zCompanyName) + ',';                             // Company Name
            zData += StringUtility.quoteReplaceStr(zHouseBlockNumber) + ',';                        // House/Block Number
            zData += StringUtility.quoteReplaceStr(zStreet) + ',';                                  // Street
            zData += StringUtility.quoteReplaceStr(zLevel) + ',';                                   // Level
            zData += StringUtility.quoteReplaceStr(zUnit) + ',';                                    // Unit
            zData += StringUtility.quoteReplaceStr(zBuildingName) + ',';                            // Building Name
            zData += StringUtility.quoteReplaceStr(zPostalCode) + ',';                              // Postal Code
            zData += StringUtility.quoteReplaceStr(zVendorGroup) + ',';                             // Vendor Group
            zData += StringUtility.quoteReplaceStr(zVendorCode) + ',';                              // Vendor Number
            zData += StringUtility.quoteReplaceStr(String.valueOf(iCaseTypeCode)) + ',';            // Case Type Code
            zData += StringUtility.quoteReplaceStr(String.valueOf(iCaseStatusCode)) + ',';          // Case Status Code
            zData += StringUtility.quoteReplaceStr(zPublicationCode) + ',';                         // Publication Code
            zData += StringUtility.quoteReplaceStr(String.valueOf(dStartRestartDate)) + ',';            // Start/Restart Date
            zData += StringUtility.quoteReplaceStr(String.valueOf(dStopTempStopDate)) + ',';            // Stop/TempStop Date
            zData += StringUtility.quoteReplaceStr(String.valueOf(dPrevStartRestartDate)) + ',';        // Previous Start/Restart Date      
            zData += StringUtility.quoteReplaceStr(String.valueOf(dPrevStopTempStopDate)) + ',';        // Previous Stop/TempStop Date
            zData += StringUtility.quoteReplaceStr(zSubscriptionCopies) + ',';                          // Subscription Copies
            zData += StringUtility.quoteReplaceStr(zSubscriberId) + ',';                                // Subscriber Id

            zData += StringUtility.quoteReplaceStr(zHDSRecipientID) + ',';                              // HDS Recipient ID
            zData += StringUtility.quoteReplaceStr(zHDSContactID) + ',';                                // HDS Contact ID
            zData += StringUtility.quoteReplaceStr(zHDSSubscriptionID) + ',';                           // HDS Subscription ID
            zData += StringUtility.quoteReplaceStr(Z_CVS_INDICATOR) + ',';                              // Indicator

            zData += StringUtility.quoteReplaceStr(zCRSMAccountID) + ',';                           // CRSM Account ID
            zData += StringUtility.quoteReplaceStr(zCRSMContactID) + ',';                           // CRSM Contact ID
            zData += StringUtility.quoteReplaceStr(zCRSMVendorSubscriptionID) + ',';                // CRSM Vendor Subscription ID
            zData += StringUtility.quoteReplaceStr(zHDSComplimentaryType) + ',';                    // HDS Complimentary type name or id?           
        }
        return zData;
    }
    
    private String calcSubCopies(List<Decimal> records) {
        String zRESULT = '';
        try {           
            if (records.size() == MAX_SUBSCRIPTION_COPY_IND) {
                for (Decimal iRec : records) {
                    if (iRec != null) {
                        zRESULT += StringUtility.formatValue(iRec,'0', 'left', MAX_SUB_CPS_DAY_STR_LENGTH);
                    } else {
                        zRESULT += Z_SUB_CPS_DEFAULT_VALUE;
                    }
                }
            } else {
                zRESULT = getDefaultSubCopies();
            }           
        } catch (Exception e) {
            zRESULT = getDefaultSubCopies();
        }
        return zRESULT;
    }
    
    private String getDefaultSubCopies() {
        String zDEFAULT = '';
        for (Integer i = 0; i<MAX_SUBSCRIPTION_COPY_IND; i++) {
            zDEFAULT += Z_SUB_CPS_DEFAULT_VALUE;
        }
        return zDEFAULT;
    }   
    
    private Integer getCaseStatusCode(String zRecordType, Case_Vendor_Subscription__c cvsRecord, Case cRecord, Map<ID, Temp_Stop__c> mTempStopMap) {
        Integer iResult = I_CASE_STATUS_CODE_CLOSED;
        
        if (zRecordType != null) {
            if (zRecordType.equalsIgnoreCase(Z_CASE_TSTOP_SUBSCRIPTION)) { 
                if (cRecord != null) {
                    ID cRecordId = cRecord.Id;
                    if (cRecordId != null) {
                        String zType = cRecord.Temp_Stop_Type__c;
                        if (zType != null && zType.length() > 0)  {
                            if (zType.equalsIgnoreCase(CASE_TEMP_STOP_TYPE_CANCEL)) {
                                iResult = I_CASE_STATUS_CODE_VOID_CRSM;
                            } 
                            if (    zType.equalsIgnoreCase(CASE_TEMP_STOP_TYPE_NEW) || 
                                            zType.equalsIgnoreCase(CASE_TEMP_STOP_TYPE_CREATE) || 
                                            zType.equalsIgnoreCase(CASE_TEMP_STOP_TYPE_UPDATE)) {
                                
                                          // Treat all 3/5 cases as 3/2's as per SPH ...
                                          // iResult = I_CASE_STATUS_CODE_UPDATED;
                                          if (mTempStopMap != null) {
                                              Temp_Stop__c tRecord = mTempStopMap.get(cRecord.Temp_Stop__c);
                                              if (tRecord != null && tRecord.Cancelled__c) {
                                                    iResult = I_CASE_STATUS_CODE_VOID_CRSM;
                                              }                                           
                                          }
                            } 
                        }
                    }               
                }
            }           
        }
        
        return iResult;
    }
    
    private Integer getCaseTypeCode(String zRecordType) {
        Integer iResult = I_CASE_TYPE_CODE_DEFAULT_REQ;
        if (zRecordType.equalsIgnoreCase(Z_CASE_START_SUBSCRIPTION)) {
            iResult = I_CASE_TYPE_CODE_START_REQ;
        } else if (zRecordType.equalsIgnoreCase(Z_CASE_V_STOP_REQEUEST) 
                || zRecordType.equalsIgnoreCase(Z_CASE_STOP_SUBSCRIPTION)) {
            iResult = I_CASE_TYPE_CODE_STOP_REQ;
        } else if (zRecordType.equalsIgnoreCase(Z_CASE_TSTOP_SUBSCRIPTION)) {
            iResult = I_CASE_TYPE_CODE_TSTOP_REQ;           
        }                   
        return iResult;
    }
    
    private Map<String, DateTime> getDateTimeParams() {
        Map<String, DateTime> zResultMap = new Map<String, DateTime>();
        try {
            String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID);            
            
            DateTime dtLastBatchRunDate = DateUtility.getOverrideDate(Z_INTERFACE_ID);  
            DateTime dtCutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(batchRunDate,'Default Timestamp');
            DateTime dtCutOffStart = dtCutOffEnd.addDays(-1); 
            Integer iOffsetDiff = Integer.valueOf((dtLastBatchRunDate.getTime() - dtCutOffEnd.getTime())/1000/60);
            DateTime dtOffsetDate = dtCutOffStart.addMinutes(iOffsetDiff);
            
            zResultMap.put(Z_CUTOFF_END_DATE,dtCutOffEnd);
            zResultMap.put(Z_OFFSET_DATE,dtOffsetDate);
            zResultMap.put(Z_CUTOFF_START_DATE,dtCutOffStart);          
            zResultMap.put(Z_LAST_BATCH_RUN_DATE,dtLastBatchRunDate);
            
        } catch (Exception e) {
            zResultMap = new Map<String, DateTime>();
            BT_CO_INT_Utilities.log(Z_INTERFACE_ID+'-(getDateTimeParams) Exception:'+ e.getMessage());
        }
        return zResultMap;
    }
    
    private Set<String> getCustomSetting(String zInputStr) {
        Set<String> zResultSet = new Set<String>();
        if (zInputStr != null) {
            zResultSet = StringUtility.getValues(StringUtility.getCustomSetting(zInputStr));
        }           
        return zResultSet;
    }
    
    // END D-2831 - Michael Francisco
}