/*
 * Class Name: BT_AB_VSS093DX_ExportCustomerStartStop
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - VSS093DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for VSS093DX batch job. Used together with BT_AS_VSS093DX_ExportCustomerStartStop Schedulable
 * 
 * History: 2014/08/26 Kevin Evasco Created Skeletal Apex Batchable
 *          2014/09/27 Renino Niefes added code implementations (Get data from LOTS OF DIFFERENT OBJECT AND STRUCTURES into the data pool)
 *          2014/11/03 Renino Niefes updates
 *          2014/12/17 Renino Niefes Defect# D-1171 (Find the missing/TBD fields and assign accordingly)
 *          2015/01/26 Renino Niefes Defect# D-1465
 *          2015/01/27 Renino Niefes Defect# D-1465  Additional fix for new bugs introduced by the previous fix
 *          2015/02/03 Angel Villamor Defect# D-1465 Validate Mandatory Fields
 *          2015/02/09 Renino Niefes Defect# D-1465 Append "V" in front of Vendor Code if Vendor Group is not available
 *          2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings)
 *          2015/02/17 Renino Niefes D-2237 This is only applicable to Newspapers
 *          2015/02/18 Renino Niefes D-2237 create mapping for transaction description (Removed unwanted comments) added System.debug for each filter criteria
 *          2015/03/20 Renino Niefes ID-2584 Use Custom settings Date utility in getting the start/end dates
 *          2015/04/10 Renino Niefes D-2717 Fix based on SPH Feedback on SIT Testing.  Revised most of the codes below and removed old comments.
 *          2015/04/14 Renino Niefes UD-0550 Subscription Copies are calculated incorrectly.  Currently, it's the sum of all copies per day + phd and phe.  
 *                                   it should be "per day" copies only. Get it from Subscription's qty__c.
 *          2015/04/29 Michael Francisco D-2831 - Rewrote / Modified the entire Apex Class to implement the following:
 *                                                  1) Removed code redundancies 
 *                                                  2) Effective Issue Date logic 
 *                                                  3) Added SORT conditions
 *                                                  4) Implemented "zData" logic
 *                                                  5) Used List / Sort approach to retain sorting
 *                                                  6) Implement Last Batch Run Date override date logic
 *                                                  7) Updated comments 
 *                                                  8) Created 'Note(s)' comments
 *     
 * Note(s):
 *  1)  Temp Stop data will always by default be 'STOP' transactions. The 'START' transaction for Temp Stop will be generated 
 *      based on the 'Restart Date' in the Temp_Stop__c object. Relationship 
 *      - (START)   - (dtEffectiveDate) - When the subscription will resume. 'Temp_Stop__r.Restart_Date__c'
 *      - (STOP)    - (dtEffectiveDate) - When the subscription will be stopped. 'Temp_Stop__r.Temp_Stop_Date__c'
 *  2)  Change of Address data will always by default be 'STOP' transactions. The 'START' transaction for Change of Address will 
 *      be generated based on the 'Effective_Date__c' in the Address_Assignment__c object. 
 *      - (START)   - (dtEffectiveDate) - When the 'new' Change of Address will take effect. 'Address_Assignment__r.Effective_Date__c'
 *      - (STOP)    - (dtEffectiveDate) - When the 'old' Change of Address will be replaced by the 'new' Address in the 
 *                                        Address_Assignment__c object. 'Case.Effective_Date__c'
 *  3) Temp_Stop__c can be derived from Case
 *  4) SORT BY: Transaction Type, 
 *              Transaction Description, 
 *              Vendor Number, 
 *              Postal Code, 
 *              Level, 
 *              Unit, 
 *              Date, 
 *              Publication Code
 *
 *          2015/08/06 Renino Niefes        hotfix: implemented the .fai file and moved the validation to on premise server.  overriding zValidation code variable.
 *          2015/08/24 Renino Niefes        UD-2438 (hotfix): remove remaining validations in the file.
 *          2015/08/26 Renino Niefes        UD-2437 (hotfix): add "Update" in the main query for Temp Stop Type field`
 *          2015/09/01 Renino Niefes        UD-2161 (hotfix): Moving the fix for UD-2438 to another area so that it won't affect temp stops
 *          2015/09/23 Raviteja Kumar       UD-2691 23-Sep-2015 Added by Raviteja  - Added Database.Stateful
 *          2015/09/29 Renino Niefes        UD-2536 (hotfix uat2) Change of Address fix (get from Case_Vendor_Subscription__r.Address__c for old address)
 *          2015/09/30 Renino Niefes        UD-2708 (hotfix uat2) Change the logic for cut off date range
 *          2015/10/01 Renino Niefes        UD-2980 Add Subscription ID
 *          2016/01/28 Renino Niefes        UD-3848 Add only vendor delivered subscriptions for direct subscribers
 */

//START UD-2691 23-Sep-2015 Added by Raviteja  - Added Database.Stateful
//global class BT_AB_VSS093DX_ExportCustomerStartStop implements Database.Batchable<sObject>,Database.AllowsCallouts
global class BT_AB_VSS093DX_ExportCustomerStartStop implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful
//End UD-2691 23-Sep-2015 Added by Raviteja
{
    // START 2015/04/29 D-2831 Michael Francisco 

    // Define Global variables for VSS093DX ...
    global static final String Z_INTERFACE_ID = 'VSS093DX';
    global final Integer MAX_SUB_COPY_DAY = 4;
    global final Integer MAX_DAY_OF_WEEK = 7;
    global final Integer MAX_SUBSCRIPTION_COPY_IND = 9;

    global final String CASE_TEMP_STOP_TYPE_NEW = 'New';
    global final String CASE_TEMP_STOP_TYPE_CREATE = 'Create';
    global final String CASE_TEMP_STOP_TYPE_CANCELLED = 'Cancel';
    global final String CASE_TEMP_STOP_TYPE_UPDATE = 'Update';

    /* Default Cut-Off DateTime Format */
    global final String Z_CUTOFF_DATE_TIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    
    global final String CASE_SUB_STATUS_TSTOP_REJECTED = 'Temp Stop Rejected';
    global final String CASE_SUB_STATUS_REJECTED = 'Rejected';

    global final String START_SUBSCRIPTION = 'Start_Subscription';
    global final String STOP_SUBSCRIPTION = 'Stop_Subscription';
    global final String TSTOP_SUBSCRIPTION = 'Temp_Stop_Subscription';
    global final String COMPLAINT_NEWSPAPER = 'Complaint_Newspaper';
    global final String CHANGE_OF_ADDRESS = 'Change_of_Address';
    global final String V_STOP_REQEUEST = 'Vendor_Stop_Request';
    global final String CHANGE_OF_ADDRESS_TYPE = 'Change of%Delivery%';

    global final String CASE_STATUS_CLOSED = 'Closed';

    global final String FREQUENCY_DEFAULT = 'default';
    global final String FREQUENCY_WEEKEND = 'Sat - Sun';
    global final String FREQUENCY_WEEKDAY = 'Mon - Fri';
    global final String FREQUENCY_WEEKDAY_EXT = 'Mon - Sat';

    global final String TRANSACTION_TYPE_START = 'Start';
    global final String TRANSACTION_TYPE_STOP = 'Stop';
    global final String TRANSACTION_TYPE_COMPLAINTS = 'Complaints';

    global final String TRANSACTION_DESC_NEW = 'New';
    global final String TRANSACTION_DESC_COA = 'Change of Address';
    global final String TRANSACTION_DESC_TEMP_STOP = 'Temp Stop';
    global final String TRANSACTION_DESC_STOP = 'Stop Subscription';
    global final String TRANSACTION_DESC_PSTOP = 'Premature Stop';

    global final String CASE_RECORD_TYPE_DIRECT = 'DIRECT';
    global final String CASE_RECORD_TYPE_VENDOR = 'VENDOR';
    global final String CASE_RECORD_TYPE_BOTH = 'BOTH';
    global final String CASE_RECORD_TYPE_INVALID = 'INVALID';

    global final String Z_DATA_VENDOR = 'VENDOR';
    global final String Z_DATA_VENDOR_CODE = 'VENDOR_CODE';
    global final String Z_DATA_TRANS_TYPE = 'TRANSACTION_TYPE';
    global final String Z_DATA_TRANS_DESC = 'TRANSACTION_DESC';
    global final String Z_DATA_BLOCK_HOUSE_NUMBER = 'BLOCK_HOUSE_NUMBER';
    global final String Z_DATA_LEVEL = 'LEVEL';
    global final String Z_DATA_UNIT_NUMBER = 'UNIT_NUMBER';
    global final String Z_DATA_POSTAL_CODE = 'POSTAL_CODE';
    global final String Z_DATA_STREET_NAME = 'STREET_NAME';
    global final String Z_DATA_BUILDING_NAME = 'BUILDING_NAME';
    global final String Z_DATA_PUBLICATION_CODE = 'PUBLICATION_CODE';
    global final String Z_DATA_TOTAL_COPIES = 'TOTAL_COPIES';
    global final String Z_DATA_EFFECTIVE_DATE = 'EFFECTIVE_DATE';
    global final String Z_DATA_EFFECTIVE_ISSUE_DATE = 'EFFECTIVE_ISSUE_DATE';
    global final String Z_DATA_RESTART_DATE = 'RESTART_DATE';
    global final String Z_DATA_DESCRIPTION = 'DESCRIPTION';
    global final String Z_DATA_REMARKS = 'REMARKS';
    global final String Z_DATA_SUBSCRIPTION_COPIES = 'SUBSCRIPTION_COPIES';
    global final String Z_DATA_CASE_RECORD_TYPE = 'CASE_RECORD_TYPE';
    global final String Z_DATA_LAST_MODIFIED_DATE = 'LAST_MODIFIED_DATE';
    global final String Z_DATA_PUBLICATION_PATTERN = 'PUBLICATION_PATTERN';
    global final String Z_DATA_DATE_MAPS = 'DATE_MAPS';
    global final String Z_DATA_SUBSCRIPTION_ID = 'Z_DATA_SUBSCRIPTION_ID';   //START/END UD-2980 2015-10-01 Renino Niefes

    global final String Z_COA_DATA_MAP = 'COA_DATA_MAP';

    global final String Z_COA_BLOCK_HOUSE_NUMBER = 'COA_BLOCK_HOUSE_NUMBER';
    global final String Z_COA_LEVEL = 'COA_LEVEL';
    global final String Z_COA_UNIT_NUMBER = 'COA_UNIT_NUMBER';
    global final String Z_COA_STREET_NAME = 'COA_STREET_NAME';
    global final String Z_COA_BUILDING_NAME = 'COA_BUILDING_NAME';
    global final String Z_COA_POSTAL_CODE = 'COA_POSTAL_CODE';
    global final String Z_COA_EFFECTIVE_DATE = 'COA_EFFECTIVE_DATE';
    global final String Z_COA_VENDOR_GROUP = 'COA_VENDOR_GROUP';
    global final String Z_COA_VENDOR_CODE = 'COA_VENDOR_CODE';
    global final String Z_COA_VENDOR = 'COA_VENDOR';

    global final String DT_COMPLAINT_FROM = 'DT_COMPLAINT_FROM';
    global final String DT_COMPLAINT_TO = 'DT_COMPLAINT_TO';
    global final String DT_EFFECTIVE_DATE = 'DT_EFFECTIVE_DATE';
    global final String DT_RESTART_DATE = 'DT_RESTART_DATE';
    global final String DT_Z_SUBSCRIPTION_START_DATE = 'DT_Z_SUBSCRIPTION_START_DATE';
    global final String DT_Z_SUBSCRIPTION_END_DATE = 'DT_Z_SUBSCRIPTION_END_DATE';
    global final String DT_STOP_REQUEST_DATE = 'DT_STOP_REQUEST_DATE';
    global final String DT_EFFECTIVE_ISSUE_DATE = 'DT_EFFECTIVE_ISSUE_DATE';
    global final String DT_START = 'DT_START';
    global final String DT_END = 'DT_END';
    
    global final Integer Z_MODE_TEMP_STOP = 1;
    global final Integer Z_MODE_COA = 2;

    global static final String DELIM = '|';

    global static final String ERROR_CODE_ZDATA_FAILURE = '1921';
    global static final String ERROR_CODE_EXCEPTION = '1311';
    global static final String ERROR_CODE_NONPUB = '1701';
    
    global Set<String> exportDataSet = new Set<String>();       
    global List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
    global List<BA_INT_DATA_FAILED_POOL__c> datapoolFailedList = new List<BA_INT_DATA_FAILED_POOL__c>();
    global Map<String, Set<String>> mapProdPub = new Map<String, Set<String>>(); //START/End UD-2691 23-Sep-2015 Added by Raviteja
    global static String batchRunDateX = null; //START/END UD-2708 Renz 2015-09-30
    /* @description 
    * 
    * @param BatchableContext which is a predefined parameter
    * @return Database.QueryLocator
    */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :Z_INTERFACE_ID];
        delete resultList;  

        // Prepare the list of cases that this interface will use
        List<String> caseRecordTypesList = new List<String>();
        caseRecordTypesList.add(START_SUBSCRIPTION);    //New
        caseRecordTypesList.add(COMPLAINT_NEWSPAPER);   //Complaint Description
        //caseRecordTypesList.add(TSTOP_SUBSCRIPTION);    //Temp Stop
        //caseRecordTypesList.add(CHANGE_OF_ADDRESS);     //Change of Address
        caseRecordTypesList.add(V_STOP_REQEUEST);       //Vendor Stop Request
        caseRecordTypesList.add(STOP_SUBSCRIPTION);     //Premature Stop

        // Prepare the cut off dates. Use Batch Run Date as current date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID);            
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(batchRunDate);
        DateTime cutOffStart = cutOffEnd.addDays(-1);  
        DateTime dtLastBatchRunDate = DateUtility.getOverrideDate(Z_INTERFACE_ID);         
        DateTime newCutOffStart = cutOffStart;
        
        if (dtLastBatchRunDate<cutOffStart) {
            Integer minutesDiff = Integer.valueOf((dtLastBatchRunDate.getTime() - cutOffStart.getTime())/1000/60);
            newCutOffStart = cutOffStart.addMinutes(minutesDiff); 
        }
        
        List<String> caseSubStatusRejectedList = new List<String>();
        caseSubStatusRejectedList.add(CASE_SUB_STATUS_REJECTED);
        caseSubStatusRejectedList.add(CASE_SUB_STATUS_TSTOP_REJECTED);
        
        // Prepare the status set applicable to this interface
        List<String> caseStatusList = new List<String>();
        caseStatusList.add(CASE_STATUS_CLOSED);

        List<String> caseTempStopType = new List<String>();
        caseTempStopType.add(CASE_TEMP_STOP_TYPE_CREATE);
        caseTempStopType.add(CASE_TEMP_STOP_TYPE_NEW);
        caseTempStopType.add(CASE_TEMP_STOP_TYPE_UPDATE); //START/END UD-2437 Renino Niefes 2015-08-26 Add Update in the criteria

        //START UD-2708 Renz 2015-09-30 Change the logic for missing time        
        //START HotFix 31-Aug-2015 Added by Raviteja - Applying logic for missing time        
        //DateTime lastBatchruntime;
        //for(BT_CO_Batch_Run_Request__c brr : [SELECT CreatedDate,Id FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = 'VSS093DX' AND End_Time__c != Null 
                                                                                //AND Batch_Run_Date__c < :date.newinstance(dtLastBatchRunDate.year(), dtLastBatchRunDate.month(), dtLastBatchRunDate.day()) 
                                                                                //ORDER BY CreatedDate DESC limit 1]){           
        //    lastBatchruntime = Datetime.valueof(brr.CreatedDate);             
        //}        
        //End HotFix 31-Aug-2015 Added by Raviteja      
        DateTime curDT = System.now();
        Date dBatchRunDate = convertBRD_To_Date(batchRunDate);
        DateTime dtPrevBatchRunDate = DateUtility.getOverrideDate(Z_INTERFACE_ID);
        Date dPrevBatchRunDate = dtPrevBatchRunDate.date();
        DateTime dStartDate2 = null;
        if (dPrevBatchRunDate<=dBatchRunDate&&dtPrevBatchRunDate<curDT) {
            dStartDate2 = dtPrevBatchRunDate;
        } else {
            dStartDate2 = newCutOffStart;
        }               
        //END UD-2708 Renz 2015-09-30 Change the logic for missing time
        
        mapProdPub = BT_CO_INT_Utilities.prodPubMapping();   //START/End UD-2691 23-Sep-2015 Added by Raviteja 
        // Get all cases 'Closed' for the current offset period ...
        String  query = ' SELECT ';
                query += '    Account.Vendor_Code__c, ';    
                query += '    Account.Vendor_Group__c, ';   
                query += '    Publication__r.Publication_Code__c, ';
                query += '    RecordType.DeveloperName, ';
                query += '    RecordType.Description, ';
                query += '    Date_Replaced__c, ';
                query += '    Date_Closed__c, ';
                query += '    Description, ';
                query += '    Effective_Date__c, ';
                query += '    Earliest_Stop_Date__c, ';
                query += '    POP_Start_Date__c, ';
                query += '    Remarks__c, ';       
                query += '    Restart_Date__c, ';
                query += '    Sub_Category__c, ';
                query += '    Stop_Request_Date__c, ';
                query += '    Stop_Date__c, ';
                query += '    Temp_Stop_Date__c, ';
                query += '    Temp_Stop__c, ';
                query += '    Temp_Stop__r.Cancelled__c, ';
                query += '    Temp_Stop_Type__c, ';
                query += '    LastModifiedDate, ';
                query += '    Change_of_Address_Type__c, ';     
                query += '    ID ';
                query += ' FROM ';
                query += '    Case ';
                query += ' WHERE ';
                query += '      Status IN :caseStatusList ';
                query += '      AND ( RecordType.DeveloperName IN :caseRecordTypesList ';
                query += '          OR (    RecordType.DeveloperName = :TSTOP_SUBSCRIPTION ';
                query += '                  AND Temp_Stop__r.Cancelled__c = FALSE ';
                query += '                  AND Sub_Status__c NOT IN :caseSubStatusRejectedList ';      
                query += '                  AND Temp_Stop_Type__c IN :caseTempStopType ';
                query += '          ) OR (  RecordType.DeveloperName = :CHANGE_OF_ADDRESS ';
                query += '                      AND Change_of_Address_Type__c LIKE :CHANGE_OF_ADDRESS_TYPE ';
                query += '          ) '; 
                query += '      ) ';
                query += '      AND Sub_Status__c != :CASE_SUB_STATUS_REJECTED ';
                
                //START UD-2708 2015-09-30 Renz: change the logic for missing time. Removing unwanted codes
                //START HotFix 31-Aug-2015 Added by Raviteja - Applying logic for missing time   
                query += '      AND LastModifiedDate > ' + dStartDate2.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);
                query += '      AND LastMOdifiedDate <= ' + cutOffEnd.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT); 
                //End HotFix 31-Aug-2015 Added by Raviteja   
                //END UD-2708 2015-09-30 Renz
                
                // Sort records by RecordType.DeveloperName, RecordType.Description
                query += ' ORDER BY ';
                query += '    RecordType.DeveloperName, ';
                query += '    RecordType.Description, ';
                query += '    LastModifiedDate ';
                
                System.debug('query : '+query);
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
        // Prepare the List of Case IDs for search criteria for Case Vendor Subs and Zuora Subscriptions
        List<Id> caseIdList = new List<Id>();
        List<Id> caseIdCOAList = new List<Id>();
        List<Id> caseIdTempStopList = new List<Id>();
        datapoolList = new List<BA_INT_DATA_POOL__c>(); //START /End D-3987 25-Nov-2015 Added by Raviteja - Initializing the datapoolList
        
        for(sObject record : scope) {   
            Case caseRecord = (Case)record;
            ID cRecordId = caseRecord.Id;
            if (cRecordId != null) {
                caseIdList.add(cRecordId);  
                String zRecordType = caseRecord.RecordType.DeveloperName;
                if (zRecordType != null ) { 
                    if (zRecordType.equalsIgnoreCase(CHANGE_OF_ADDRESS)) {
                        caseIdCOAList.add(cRecordId);
                    } else if (zRecordType.equalsIgnoreCase(TSTOP_SUBSCRIPTION)) {
                        caseIdTempStopList.add(cRecordId);
                    } 
                }
            }
        }       
        Map<ID, Address_Assignment__c> caseAddressAssignmentMap = BT_CO_INT_Utilities.getAddressAssignmentMap(caseIdCOAList); 
        
        List<Temp_Stop__c> tempStopIdList = new List<Temp_Stop__c>();
        Map<ID, Temp_Stop__c> caseTempStopMap = new Map<ID, Temp_Stop__c>();
        if (caseIdTempStopList.size() > 0) {
            // Create Case-TempStop Map
            tempStopIdList = [
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
                    Case__c IN :caseIdTempStopList
                ORDER BY
                    Temp_Stop_Date__c, 
                    Restart_Date__c 
            ];
            if (tempStopIdList.size() > 0) {
                for (Temp_Stop__c tRecord : tempStopIdList) {
                    if (tRecord != null) {
                        ID caseId = tRecord.Case__r.Id;
                        if (caseId != null) {
                            caseTempStopMap.put(caseId,tRecord);                                                    
                        }
                    }
                }               
            }
        }
        
        //---------------------------------------------------------------------------------------------------------------------------------
        // Get all Case Subscriptions (Direct) and save it to a list of Case_Subscriptions__c        
        List<Case_Subscription__c> caseDirectSubsList = [
            SELECT 
                Id,
                Case__r.Id,
                Case__r.RecordType.DeveloperName,
                Product_Code__c,
                Subscription__c,
                Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c,
                Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c,
                Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c,
                Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c,
                Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c,
                Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name,
                Subscription__r.Subscriber_Contact__c,
                Subscription__r.Zuora__SubscriptionStartDate__c,
                Subscription__r.Zuora__SubscriptionEndDate__c,
                Subscription__r.Name,                    //START/END 2015-10-01 Renino Niefes: Add Subscription ID
                Complaint_From__c,
                Complaint_To__c,
                Subscription__r.Zuora__Account__c,  
                Complaint_Copies__c,
                Subscription__r.ID, 
                Subscription__r.Product_Code__c,
                Subscription__r.Qty__c,
                Subscription__r.Frequency__c,
                Subscription__r.Vendor_1__r.Vendor_Group__c,
                Subscription__r.Vendor_1__r.Vendor_Code__c,
                Subscription__r.Main_Package_1__c,
                Subscription__r.Main_Package_1__r.Id
            FROM 
                Case_Subscription__c
            WHERE 
                Case__c IN :caseIdList
                AND Case__r.RecordType.DeveloperName = :COMPLAINT_NEWSPAPER
                AND Subscription__r.Delivered_By_1__c = 'Vendor'               //START/END 2016/01/28 Renino Niefes        UD-3848 Add only vendor delivered subscriptions for direct subscribers
            ORDER BY 
                Subscription__r.Vendor_1__r.Vendor_Code__c,
                Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name, 
                Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c, 
                Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c      
        ];
        
        //Convert that into a Map so that you could search the value using Case__r.Id
        Map<ID, List<Case_Subscription__c>> mCaseDirectSubscriptionMap = new Map<ID, List<Case_Subscription__c>>();
        List<ID> lPackageIDs = new List<ID>();
        for(Case_Subscription__c csRecord : caseDirectSubsList) {
            if (csRecord != null) {
                ID caseRecordID = csRecord.Case__r.ID;
                ID subRecordID = csRecord.Subscription__r.ID;
                if (mCaseDirectSubscriptionMap.containsKey(caseRecordID)) {
                    List<Case_Subscription__c> eCaseSubscriptionList = mCaseDirectSubscriptionMap.get(caseRecordID);
                    boolean isExistingRecord = false;
                    for (Case_Subscription__c csExistingRecord : eCaseSubscriptionList) {
                        ID existingSubRecordID = csExistingRecord.Subscription__r.ID;
                        String zExistingSubRecordID = String.valueOf(existingSubRecordID);
                        if (existingSubRecordID != null && zExistingSubRecordID.equalsIgnoreCase(String.valueOf(subRecordID))) {
                            isExistingRecord=true;
                        }
                    }
                    if (!isExistingRecord) {
                        eCaseSubscriptionList.add(csRecord);
                        mCaseDirectSubscriptionMap.put(caseRecordID,eCaseSubscriptionList);
                    }                       
                } else {
                    List<Case_Subscription__c> newCaseSubscriptionList = new List<Case_Subscription__c>();
                    newCaseSubscriptionList.add(csRecord);
                    mCaseDirectSubscriptionMap.put(caseRecordID,newCaseSubscriptionList);
                }               

                ID pkgRecordID = csRecord.Subscription__r.Main_Package_1__c;
                if (pkgRecordID != null) {
                    lPackageIDs.add(pkgRecordID);
                }
            }
        }       
        
        // Create a Map of Package IDs to a SET of Publications ... 
        Map<ID, Set<Publication__c>> mPackagePublications = new Map<ID, Set<Publication__c>>();
        if (lPackageIDs.size() > 0) {
            mPackagePublications = packageToPublication(lPackageIDs);           
        }
        
        //Get all Case Vendor Subs and save it to a List of Subscription_Vendor__c.     
        List<Case_Vendor_Subscription__c> caseVenSubsList = [
            SELECT 
                Id, 
                Case__r.Id,
                Subscription_Vendor__r.Recipient__r.Address__r.Block_House_Number__c,
                Subscription_Vendor__r.Recipient__r.Address__r.Street_Name__c,
                Subscription_Vendor__r.Recipient__r.Address__r.Level_Number__c,
                Subscription_Vendor__r.Recipient__r.Address__r.Unit_Number__c,
                Subscription_Vendor__r.Recipient__r.Address__r.Building_Name__c,
                Subscription_Vendor__r.Subscription_Start_Date__c,
                Subscription_Vendor__r.Subscription_Stop_Date__c,
                Subscription_Vendor__r.Name,                  //START/END 2015-10-01 Renino Niefes: Add Subscription ID
                Complaint_From__c,
                Complaint_To__c,    
                Subscription_Vendor__r.Vendor__r.Vendor_Group__c,
                Subscription_Vendor__r.Vendor_Code__c,
                Subscription_Vendor__r.Id,
                Subscription_Vendor__r.Recipient__r.Address__r.Postal_Code__r.Name,  
                Complaint_Copies__c,
                
                //START UD-2536 Renino Niefes 2015-09-29 Add new fields for old address
                Address__r.Id,
                Address__r.Block_House_Number__c,
                Address__r.Level_Number__c,
                Address__r.Unit_Number__c,
                Address__r.Postal_Code__r.Name,
                Address__r.Street_Name__c,
                Address__r.Building_Name__c
                //END UD-2536 Renino Niefes 2015-09-29 Add new fields for old address
        
            FROM 
                Case_Vendor_Subscription__c
            WHERE 
                Case__r.Id IN :caseIdList
            ORDER BY
                Subscription_Vendor__r.Vendor_Code__c,
                Subscription_Vendor__r.Recipient__r.Address__r.Postal_Code__r.Name, 
                Subscription_Vendor__r.Recipient__r.Address__r.Level_Number__c, 
                Subscription_Vendor__r.Recipient__r.Address__r.Unit_Number__c               
        ];
        
        //Convert that into a Map so that you could search the value using Case__r.Id
        Map<ID, List<Case_Vendor_Subscription__c>> mCaseVendorSubscriptionMap = new Map<ID, List<Case_Vendor_Subscription__c>>();
        List<Id> subsVendorIDs = new List<Id>();
        for(Case_Vendor_Subscription__c cvsRecord : caseVenSubsList) {

            ID cRecordID = cvsRecord.Case__r.ID;
            ID svRecordId = cvsRecord.Subscription_Vendor__r.Id;

            if (mCaseVendorSubscriptionMap.containsKey(cRecordID)) {
                List<Case_Vendor_Subscription__c> eCaseVendorSubscriptionList = mCaseVendorSubscriptionMap.get(cRecordID);
                boolean isExistingRecord = false;
                for (Case_Vendor_Subscription__c cvsExistingRecord : eCaseVendorSubscriptionList) {
                ID cExistingSVRecordID = cvsExistingRecord.Subscription_Vendor__r.ID;
                String zExistingSVRecordID = String.valueOf(cExistingSVRecordID);
                    if (cExistingSVRecordID != null && zExistingSVRecordID.equals(String.valueOf(svRecordId))) {
                        isExistingRecord=true;
                    }
                }
                if (!isExistingRecord) {
                    eCaseVendorSubscriptionList.add(cvsRecord);
                    mCaseVendorSubscriptionMap.put(cRecordID,eCaseVendorSubscriptionList);      
                }   
            } else {
                List<Case_Vendor_Subscription__c> newCaseVendorSubscriptionList = new List<Case_Vendor_Subscription__c>();
                newCaseVendorSubscriptionList.add(cvsRecord);
                mCaseVendorSubscriptionMap.put(cRecordID,newCaseVendorSubscriptionList);
            } 
            if (svRecordId!=null) {
                subsVendorIDs.add(svRecordId);
            }
        }       

        //Get the SubscriptionVendorPublication to get the Subscription Copies
        List<Subscription_Vendor_Publication__c> subVenPubsList = [
            SELECT 
                ID, 
                Subscription_Vendor__r.Id,
                Publication__r.Publication_Code__c,
                Publication__r.Earliest_Start_Date__c,
                Publication__r.Published_Days__c,
                Publication__r.Public_Holiday_Weekday_Pub_Indicator__c,
                Publication__r.Public_Holiday_Weekend_Pub_Indicator__c,
                Publication__r.Publication_Type__c,        
                Publication__r.Platform_Type__c,                
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
                Subscription_Vendor__r.Id IN :subsVendorIDs 
                AND Publication__r.Platform_Type__c = 'Print'
                AND Publication__r.Publication_Type__c = 'N'
            ORDER BY
                Publication__r.Publication_Code__c
        ];
        
        //Create a subVenPubsMap based on subVenPubsList
        Map<ID, List<Subscription_Vendor_Publication__c>> subVenPubsMap = new Map<ID, List<Subscription_Vendor_Publication__c>>();
        boolean failed = false;
        for (Subscription_Vendor_Publication__c rec : subVenPubsList) {
            String zPublicationCode = rec.Publication__r.Publication_Code__c;          
            if (StringUtility.validate(zPublicationCode).equalsIgnoreCase('0')) {
                ID svRecordID = rec.Subscription_Vendor__r.Id;
                if (subVenPubsMap.containsKey(svRecordID)) {
                    List<Subscription_Vendor_Publication__c> existingPublicationCodeList = subVenPubsMap.get(svRecordID);
                    boolean isExistingPublicationRecord = false;
                    for (Subscription_Vendor_Publication__c pRecord : existingPublicationCodeList) {
                        if (pRecord.Publication__r.Publication_Code__c.equalsIgnoreCase(zPublicationCode)) {
                            isExistingPublicationRecord=true;
                        }
                    }
                    if (!isExistingPublicationRecord) {
                        existingPublicationCodeList.add(rec);
                    }                       
                } else {
                    List<Subscription_Vendor_Publication__c> newPublicationCodeSet = new List<Subscription_Vendor_Publication__c>();
                    newPublicationCodeSet.add(rec);
                    subVenPubsMap.put(svRecordID,newPublicationCodeSet);
                }                               
            } else {
                failed = true;
            }   
            if (failed) {
                failed = false;
                String zErrMsg = 'FAILED (Subscription_Vendor_Publication__c) Record. Publication_Code__c:'+zPublicationCode;
                BT_CO_INT_Utilities.log(zErrMsg, rec.Id);
            } 
        }
        
        // Create a Map of Field Validation Error messages based on INTERFACE_ID ...
        Map<Decimal, String> mErrorMessageMap = BT_CO_INT_Utilities.getErrorMessageMap(Z_INTERFACE_ID);
       
        //Loop through the Case Records
        //For each type, gather the appropriate records into the interface parameters
        for(sObject record : scope)
        {
            Case caseRecord = (Case) record;
            ID zRecordID = caseRecord.Id;

            String zRecordType = '';            
            String zVendor = null;
            String zVendorGroup = null;
            String zVendorCode = null;
            String zTransType = null;
            String zTransDesc = null;
            String zBlockHouseNumber = null;
            String zLevel = null;
            String zUnitNumber = null;
            String zPostalCode = null;
            String zStreetName = null;
            String zBuildingName = null;
            String zPublicationCode = null;
            String zDescription = null;
            String zRemarks = null;
            String zSubsriptionCopies = null;
            String zProductCode = null;

            String zCaseRecordType = '';
            String zFrequencyCode = '';
            
            Integer iTotalCopies = null;

            Date dtEffectiveDate = null;
            Date dtRestartDate = null;
            Date dtStopRequestDate = caseRecord.Stop_Request_Date__c;
            DateTime dtLastModifiedDate = caseRecord.LastMOdifiedDate; 
            
            zRemarks = caseRecord.Remarks__c;
            zRecordType = caseRecord.RecordType.DeveloperName;
            dtRestartDate = caseRecord.Restart_Date__c;

            if (zRecordType == null) {
                zRecordType = '';
            }

            zTransType = getTransactionType(zRecordType);
            zTransDesc = getTransactionDesc(zRecordType, caseRecord);

            Map<String, Object> zCoADataMap = new Map<String, Object>();
            if (zRecordType.equalsIgnoreCase(CHANGE_OF_ADDRESS)) {
                dtEffectiveDate = caseRecord.Effective_Date__c;

                String zNewBlockHouseNumber = null;
                String zNewLevel = null;
                String zNewUnitNumber = null;
                String zNewStreetName = null;
                String zNewBuildingName = null;
                String zNewPostalCode = null;       
                String zNewCoAVendorGroup = null;
                String zNewCoAVendorCode = null;
                String zNewCoAVendor = null;

                Date dtNewEffectiveDate = null;
                Address_Assignment__c aRecord = (Address_Assignment__c) caseAddressAssignmentMap.get(zRecordID);

                if (aRecord != null) {
                    zNewBlockHouseNumber = aRecord.Address__r.Block_House_Number__c;
                    zNewLevel = aRecord.Address__r.Level_Number__c;
                    zNewUnitNumber = aRecord.Address__r.Unit_Number__c;
                    zNewStreetName = aRecord.Address__r.Street_Name__c;
                    zNewBuildingName = aRecord.Address__r.Building_Name__c;
                    zNewPostalCode = aRecord.Address__r.Postal_Code__r.Name;    
                    dtNewEffectiveDate = aRecord.Effective_Date__c;
                    zNewCoAVendorGroup = aRecord.Vendor__r.Vendor_Group__c;
                    zNewCoAVendorCode = aRecord.Vendor__r.Vendor_Code__c; 
                    zNewCoAVendor = StringUtility.getVendor(zNewCoAVendorGroup,zNewCoAVendorCode);
                    
                    zCoADataMap.put(Z_COA_BLOCK_HOUSE_NUMBER,zNewBlockHouseNumber);
                    zCoADataMap.put(Z_COA_LEVEL,zNewLevel);
                    zCoADataMap.put(Z_COA_UNIT_NUMBER,zNewUnitNumber);
                    zCoADataMap.put(Z_COA_STREET_NAME,zNewStreetName);
                    zCoADataMap.put(Z_COA_BUILDING_NAME,zNewBuildingName);
                    zCoADataMap.put(Z_COA_POSTAL_CODE,zNewPostalCode);
                    zCoADataMap.put(Z_COA_VENDOR_GROUP,zNewCoAVendorGroup);
                    zCoADataMap.put(Z_COA_VENDOR_CODE,zNewCoAVendorCode);
                    zCoADataMap.put(Z_COA_VENDOR,zNewCoAVendor);
                    
                    zCoADataMap.put(Z_COA_EFFECTIVE_DATE,dtNewEffectiveDate);
                }
            }

            if (zRecordType.equalsIgnoreCase(TSTOP_SUBSCRIPTION) 
                || zRecordType.equalsIgnoreCase(V_STOP_REQEUEST)
                || zRecordType.equalsIgnoreCase(STOP_SUBSCRIPTION)) {
                    
                if (zRecordType.equalsIgnoreCase(TSTOP_SUBSCRIPTION)) {
                    if (caseTempStopMap.containsKey(zRecordID)) {
                        Temp_Stop__c tRecord = (Temp_Stop__c) caseTempStopMap.get(zRecordID);
                        if (tRecord != null) {
                            dtEffectiveDate = tRecord.Temp_Stop_Date__c;
                            dtRestartDate = tRecord.Restart_Date__c;
                        }
                    } else {
                        dtEffectiveDate = caseRecord.Effective_Date__c;
                        dtRestartDate = caseRecord.Restart_Date__c;                     
                    }
                }

                if (zRecordType.equalsIgnoreCase(V_STOP_REQEUEST) || zRecordType.equalsIgnoreCase(STOP_SUBSCRIPTION)) {
                    dtEffectiveDate = caseRecord.Stop_Request_Date__c;
                }
            }

            String zDEBUGGER = 'RecordType:'+zRecordType;                           

            try {
                //For Direct Subscribers
                List<Case_Subscription__c> caseSubscriptionList = mCaseDirectSubscriptionMap.get(zRecordID);
                if (caseSubscriptionList != null) {
                    for (Case_Subscription__c cdsRec : caseSubscriptionList) {
                        if (cdsRec != null) {
                            zDEBUGGER += '('+CASE_RECORD_TYPE_DIRECT+') ';

                            zProductCode = cdsRec.Product_Code__c;
                            zVendorGroup = cdsRec.Subscription__r.Vendor_1__r.Vendor_Group__c;
                            zVendorCode = cdsRec.Subscription__r.Vendor_1__r.Vendor_Code__c;
                            zFrequencyCode = cdsRec.Subscription__r.Frequency__c; 

                            zVendor = StringUtility.getVendor(zVendorGroup,zVendorCode);

                            zBlockHouseNumber = cdsRec.Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c;
                            zLevel = cdsRec.Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c;
                            zUnitNumber = cdsRec.Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c;
                            zStreetName = cdsRec.Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c;
                            zBuildingName = cdsRec.Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c;
                            zPostalCode = cdsRec.Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name;                       

                            iTotalCopies = Integer.valueOf((cdsRec.Subscription__r.Qty__c != null) ? cdsRec.Subscription__r.Qty__c : 0 );
                            Date dtComplaintTo = cdsRec.Complaint_To__c;
                            Date dtComplaintFrom = cdsRec.Complaint_From__c;
                            Date dtZuoraSubscriptionStartDate = cdsRec.Subscription__r.Zuora__SubscriptionStartDate__c;
                            Date dtZuoraSubscriptionEndDate = cdsRec.Subscription__r.Zuora__SubscriptionEndDate__c;
                            
                            String zSubscriptionID = cdsRec.Subscription__r.Name;        //START/END 2015-10-01 Renino Niefes: Add Subscription ID
                            
                            if (zRecordType.equalsIgnoreCase(START_SUBSCRIPTION)) {
                                dtEffectiveDate = cdsRec.Subscription__r.Zuora__SubscriptionStartDate__c;
                            }
                            
                            zDEBUGGER += '(D) --- Check-1';
                            ID pkgRecordID = cdsRec.Subscription__r.Main_Package_1__c;
                            if (pkgRecordID != null && mPackagePublications != null && mPackagePublications.containsKey(pkgRecordID)) {
                                
                                Set<Publication__c> publicationListData = new Set<Publication__c>();
                                if (pkgRecordID != null && mPackagePublications.get(pkgRecordID) != null) {
                                    publicationListData = mPackagePublications.get(pkgRecordID);
                                }
                                String prodCode = cdsRec.Subscription__r.product_code__c; //START/End UD-2691 23-Sep-2015 Added by Raviteja 
                                publicationListData = BT_CO_INT_Utilities.prodPubMapping(publicationListData, prodCode, mapProdPub);//START/End UD-2691 23-Sep-2015 Added by Raviteja                             
                                zDEBUGGER += '(D) --- Check-2';
                                if (publicationListData != null && publicationListData.size() > 0) {
                                    for (Publication__c pRecord : publicationListData) {  
                                        if (pRecord != null) {
                                            zPublicationCode = pRecord.Publication_Code__c;
                                            String zPublishedDays = pRecord.Published_Days__c;
                                                                                
                                            
                                            List<Decimal> ltSubCopiesList = new List<Decimal>();
                                            List<Decimal> ltDayOfWeekList = new List<Decimal>();
                                            
                                            String zPattern = null;
                                            if (zFrequencyCode != null && zPublishedDays != null) {
                                                zPattern = StringUtility.getPublishedDays(zFrequencyCode, zPublishedDays);                                              
                                            }

                                            zDEBUGGER += '(D) --- Check-3.0';
                                            if (zPattern != null) {
                                                if (zPattern.length() == MAX_DAY_OF_WEEK) {
                                                    zPattern += (pRecord.Public_Holiday_Weekday_Pub_Indicator__c) ? 'Y':'N';
                                                    zPattern += (pRecord.Public_Holiday_Weekend_Pub_Indicator__c) ? 'Y':'N';                
                                                }
                              
                                                String wPattern = zPattern.replaceAll('[yY]', iTotalCopies+DELIM).replaceAll('[nN]','0'+DELIM);
                                                List<String> l = wPattern.split('['+DELIM+']');
                                                Integer iCount = 0;
                                                for ( String zRecord : l ) {
                                                    if (zRecord != null) {
                                                        Decimal d = null;
                                                        try {
                                                            d = Decimal.valueOf(zRecord);                                   
                                                        } catch (Exception e) {
                                                            d = 0.0;
                                                        }
                                                        if (iCount <= MAX_DAY_OF_WEEK) {
                                                            ltDayOfWeekList.add(d);                         
                                                        }
                                                        ltSubCopiesList.add(d); 
                                                    }
                                                    iCount++;
                                                }                                   
                                                zSubsriptionCopies = calcSubCopies(ltSubCopiesList, MAX_SUB_COPY_DAY);
                                            }
                                            
                                            zDEBUGGER += '(D) --- Check-3.1';
                                            if (zRecordType.equalsIgnoreCase(COMPLAINT_NEWSPAPER)) {
                                                dtEffectiveDate = dtComplaintFrom;
                                                if (dtComplaintFrom != null && dtComplaintTo != null) {
                                                    zDescription = BT_CO_INT_Utilities.getComplaintDescription(dtComplaintTo,dtComplaintFrom); 
                                                }           
                                            } 
                                            Map<String, Date> mDateRecordMap = new Map<String, Date>();
                                            mDateRecordMap.put(DT_COMPLAINT_FROM, dtComplaintFrom);
                                            mDateRecordMap.put(DT_COMPLAINT_TO, dtComplaintTo);
                                            mDateRecordMap.put(DT_EFFECTIVE_DATE, dtEffectiveDate);
                                            mDateRecordMap.put(DT_RESTART_DATE, dtRestartDate);
                                            mDateRecordMap.put(DT_Z_SUBSCRIPTION_START_DATE, dtZuoraSubscriptionStartDate);
                                            mDateRecordMap.put(DT_Z_SUBSCRIPTION_END_DATE, dtZuoraSubscriptionEndDate);
                                            mDateRecordMap.put(DT_STOP_REQUEST_DATE, dtStopRequestDate);
                                            mDateRecordMap.put(DT_START, null);
                                            mDateRecordMap.put(DT_END, null);
                                            
                                            Map<String, Date> mEffectiveIssueData = getEffectiveIssueData(zRecordType, zPattern, mDateRecordMap);
                                            String zCheck = (mEffectiveIssueData != null && mEffectiveIssueData.get(DT_EFFECTIVE_ISSUE_DATE) != null) ? '0' : '1';
                                            
                                            zDEBUGGER += '(D) --- Check-3.2';
                                            
                                            Map<String, Object> zDataMapDirect = new Map<String, Object>();
                                            zDataMapDirect.put(Z_DATA_VENDOR,zVendor);                          
                                            zDataMapDirect.put(Z_DATA_VENDOR_CODE,zVendorCode);
                                            zDataMapDirect.put(Z_DATA_TRANS_TYPE,zTransType);
                                            zDataMapDirect.put(Z_DATA_TRANS_DESC,zTransDesc);
                                            zDataMapDirect.put(Z_DATA_BLOCK_HOUSE_NUMBER,zBlockHouseNumber);
                                            zDataMapDirect.put(Z_DATA_LEVEL,zLevel);
                                            zDataMapDirect.put(Z_DATA_UNIT_NUMBER,zUnitNumber);
                                            zDataMapDirect.put(Z_DATA_POSTAL_CODE,zPostalCode);
                                            zDataMapDirect.put(Z_DATA_STREET_NAME,zStreetName);
                                            zDataMapDirect.put(Z_DATA_BUILDING_NAME,zBuildingName);
                                            zDataMapDirect.put(Z_DATA_PUBLICATION_CODE,zPublicationCode);
                                            zDataMapDirect.put(Z_DATA_DESCRIPTION,zDescription);
                                            zDataMapDirect.put(Z_DATA_REMARKS,zRemarks);
                                            zDataMapDirect.put(Z_DATA_SUBSCRIPTION_COPIES,zSubsriptionCopies);
                                            zDataMapDirect.put(Z_DATA_CASE_RECORD_TYPE,CASE_RECORD_TYPE_DIRECT);
                                            zDataMapDirect.put(Z_DATA_TOTAL_COPIES,iTotalCopies);
                                            zDataMapDirect.put(Z_DATA_EFFECTIVE_DATE,dtEffectiveDate);
                                            zDataMapDirect.put(Z_DATA_EFFECTIVE_ISSUE_DATE, mEffectiveIssueData.get(DT_EFFECTIVE_ISSUE_DATE));
                                            zDataMapDirect.put(Z_DATA_RESTART_DATE,dtRestartDate);
                                            zDataMapDirect.put(Z_DATA_LAST_MODIFIED_DATE, dtLastModifiedDate);
                                            zDataMapDirect.put(Z_COA_DATA_MAP,zCoADataMap);
                                            zDataMapDirect.put(Z_DATA_PUBLICATION_PATTERN, zPattern);
                                            zDataMapDirect.put(Z_DATA_SUBSCRIPTION_ID, zSubscriptionID);    //START/END UD-2980 2015-10-01 Renino Niefes
                                            
                                            //Start UD-2438 2015-08-24 Renino Niefes
                                            //if (BT_CO_INT_Utilities.checkValidation(zCheck)) {
                                                processZDataMap(zDataMapDirect,zRecordID,'',mErrorMessageMap);      
                                            //} else {
                                            //    String zReason = mErrorMessageMap.get(Integer.valueOf(ERROR_CODE_NONPUB));
                                            //    String zErrorReason = zReason.replace('$1',zPublicationCode)
                                            //                    .replace('$2',String.valueOf(mEffectiveIssueData.get(DT_START)))
                                            //                    .replace('$3',String.valueOf(mEffectiveIssueData.get(DT_END)));
                                            //    
                                            //    String zData = getZDataString(zDataMapDirect);
                                            //    String zErrMsg = 'EXPORT-FAILED: ' + zErrorReason;
                                             //   String zErrCode = '('+BT_CO_INT_Utilities.convert(ERROR_CODE_NONPUB)+') | '+ERROR_CODE_NONPUB;
                                            //    
                                            //    logFailedRecord(zRecordID, zErrMsg, zErrCode, zData, dtLastModifiedDate);                                         
                                            //}
                                            //End UD-2438 2015-08-24 Renino Niefes
                                            zDEBUGGER += '(D) --- Check-3.3';                                       
                                        } 
                                    }                   
                                }
                            }                
                        }
                    }                   
                }

                //For Vendor Subscribers
                List<Case_Vendor_Subscription__c> caseVendorSubscriptionList = mCaseVendorSubscriptionMap.get(zRecordID);
                if (caseVendorSubscriptionList != null) {
                    for (Case_Vendor_Subscription__c cvsRec : caseVendorSubscriptionList) {
                        if (cvsRec != null) {
                            zDEBUGGER += '('+CASE_RECORD_TYPE_VENDOR+') ';
                            ID svRecordID = cvsRec.Subscription_Vendor__r.Id;
                            zVendorGroup = cvsRec.Subscription_Vendor__r.Vendor__r.Vendor_Group__c;
                            zVendorCode = cvsRec.Subscription_Vendor__r.Vendor_Code__c;
                            zVendor = StringUtility.getVendor(zVendorGroup,zVendorCode);

                            //START UD-2536 Renino Niefes 2015-09-29 Add new fields for old address
                            if (zRecordType.equalsIgnoreCase(CHANGE_OF_ADDRESS)&&cvsRec.Address__r.Id!=null) {
                                zBlockHouseNumber = cvsRec.Address__r.Block_House_Number__c;
                                zLevel = cvsRec.Address__r.Level_Number__c;
                                zUnitNumber = cvsRec.Address__r.Unit_Number__c;
                                zPostalCode = cvsRec.Address__r.Postal_Code__r.Name;
                                zStreetName = cvsRec.Address__r.Street_Name__c;
                                zBuildingName = cvsRec.Address__r.Building_Name__c;
                            } else {
                                zBlockHouseNumber = cvsRec.Subscription_Vendor__r.Recipient__r.Address__r.Block_House_Number__c;
                                zLevel = cvsRec.Subscription_Vendor__r.Recipient__r.Address__r.Level_Number__c;
                                zUnitNumber = cvsRec.Subscription_Vendor__r.Recipient__r.Address__r.Unit_Number__c;
                                zPostalCode = cvsRec.Subscription_Vendor__r.Recipient__r.Address__r.Postal_Code__r.Name;
                                zStreetName = cvsRec.Subscription_Vendor__r.Recipient__r.Address__r.Street_Name__c;
                                zBuildingName = cvsRec.Subscription_Vendor__r.Recipient__r.Address__r.Building_Name__c;
                            }
                            //END UD-2536 Renino Niefes 2015-09-29 Add new fields for old address
                            
                            //Loop through the svpMap to calculate these parameters
                            zPublicationCode = null;                
                            iTotalCopies = null;
                            zSubsriptionCopies = null;
                            Date dtComplaintFrom = cvsRec.Complaint_From__c;
                            Date dtComplaintTo = cvsRec.Complaint_To__c;
                            Date dtZuoraSubscriptionStartDate = cvsRec.Subscription_Vendor__r.Subscription_Start_Date__c;
                            Date dtZuoraSubscriptionEndDate = cvsRec.Subscription_Vendor__r.Subscription_Stop_Date__c;
                            
                            String zSubscriptionID = cvsRec.Subscription_Vendor__r.Name;    //START/END UD-2980 2015-10-01 Renino Niefes
                            
                            zDEBUGGER += '(V) --- Check-1';
                            if (zRecordType.equalsIgnoreCase(START_SUBSCRIPTION)) {
                                dtEffectiveDate = cvsRec.Subscription_Vendor__r.Subscription_Start_Date__c;
                            }               
                        
                            zDEBUGGER += '(V) --- Check-2';
                            if (svRecordID != null && subVenPubsMap.containsKey(svRecordID)) {
                                List<Subscription_Vendor_Publication__c> svpListData = new List<Subscription_Vendor_Publication__c>();
                                if (subVenPubsMap.get(svRecordID) != null) {
                                    svpListData = subVenPubsMap.get(svRecordID);

                                    for (Subscription_Vendor_Publication__c svpRecord : svpListData) { 
                                    
                                        zDEBUGGER += '(V) --- Check-3.0';
                                        if (svpRecord != null) { 
                                            List<Decimal> ltSubCopiesList = new List<Decimal>(); 
                                            List<Decimal> ltDayOfWeekList = new List<Decimal>(); 
                                            
                                            List<Decimal> zRAWList = new List<Decimal>(); 
                                            zRAWList.add(svpRecord.Mon__c);
                                            zRAWList.add(svpRecord.Tue__c);
                                            zRAWList.add(svpRecord.Wed__c);
                                            zRAWList.add(svpRecord.Thu__c);
                                            zRAWList.add(svpRecord.Fri__c);
                                            zRAWList.add(svpRecord.Sat__c);
                                            zRAWList.add(svpRecord.Sun__c);
                                            zRAWList.add(svpRecord.PHd__c);
                                            zRAWList.add(svpRecord.PHe__c);
                                            
                                            Integer totalQty=0;
                                            String zPattern = '';
                                            
                                            for (Integer i=0;i<zRAWList.size();i++) {
                                                Decimal d = (Decimal) zRAWList.get(i);
                                                if (d!=null) {
                                                    totalQty += d.intValue();
                                                    if (i <= MAX_DAY_OF_WEEK) {
                                                        ltDayOfWeekList.add(d);
                                                        if (d > 0) {
                                                            zPattern += 'Y';
                                                        } else {
                                                            zPattern += 'N';
                                                        }
                                                    }
                                                    ltSubCopiesList.add(d);                             
                                                }
                                            }
                                            zSubsriptionCopies = calcSubCopies(ltSubCopiesList, MAX_SUB_COPY_DAY);
                                            iTotalCopies = totalQty;
                                            
                                            zPublicationCode = svpRecord.Publication__r.Publication_Code__c;

                                            zDEBUGGER += '(V) --- Check-3.1';
                                            
                                            if (zRecordType.equalsIgnoreCase(COMPLAINT_NEWSPAPER)) {
                                                dtEffectiveDate = dtComplaintFrom;
                                                if (dtComplaintFrom != null && dtComplaintTo != null) {
                                                    zDescription = BT_CO_INT_Utilities.getComplaintDescription(dtComplaintTo,dtComplaintFrom); 
                                                }
                                            } 
                                            
                                            Map<String, Date> mDateRecordMap = new Map<String, Date>();
                                            mDateRecordMap.put(DT_COMPLAINT_FROM, dtComplaintFrom);
                                            mDateRecordMap.put(DT_COMPLAINT_TO, dtComplaintTo);
                                            mDateRecordMap.put(DT_EFFECTIVE_DATE, dtEffectiveDate);
                                            mDateRecordMap.put(DT_RESTART_DATE, dtRestartDate);
                                            mDateRecordMap.put(DT_Z_SUBSCRIPTION_START_DATE, dtZuoraSubscriptionStartDate);
                                            mDateRecordMap.put(DT_Z_SUBSCRIPTION_END_DATE, dtZuoraSubscriptionEndDate);
                                            mDateRecordMap.put(DT_STOP_REQUEST_DATE, dtStopRequestDate);
                                            mDateRecordMap.put(DT_START, null);
                                            mDateRecordMap.put(DT_END, null);

                                            Map<String, Date> mEffectiveIssueData = getEffectiveIssueData(zRecordType, zPattern, mDateRecordMap);
                                            String zCheck = (mEffectiveIssueData != null && mEffectiveIssueData.get(DT_EFFECTIVE_ISSUE_DATE) != null) ? '0' : '1';
                                            
                                            zDEBUGGER += '(V) --- Check-3.2';
                                            
                                            Map<String, Object> zDataMapVendor = new Map<String, Object>();                                 
                                            zDataMapVendor.put(Z_DATA_VENDOR, zVendor);
                                            zDataMapVendor.put(Z_DATA_VENDOR_CODE, zVendorCode);
                                            zDataMapVendor.put(Z_DATA_TRANS_TYPE, zTransType);
                                            zDataMapVendor.put(Z_DATA_TRANS_DESC, zTransDesc);
                                            zDataMapVendor.put(Z_DATA_BLOCK_HOUSE_NUMBER, zBlockHouseNumber);
                                            zDataMapVendor.put(Z_DATA_LEVEL, zLevel);
                                            zDataMapVendor.put(Z_DATA_UNIT_NUMBER, zUnitNumber);
                                            zDataMapVendor.put(Z_DATA_POSTAL_CODE, zPostalCode);
                                            zDataMapVendor.put(Z_DATA_STREET_NAME, zStreetName);
                                            zDataMapVendor.put(Z_DATA_BUILDING_NAME, zBuildingName);
                                            zDataMapVendor.put(Z_DATA_PUBLICATION_CODE, zPublicationCode);
                                            zDataMapVendor.put(Z_DATA_DESCRIPTION, zDescription);
                                            zDataMapVendor.put(Z_DATA_REMARKS, zRemarks);
                                            zDataMapVendor.put(Z_DATA_SUBSCRIPTION_COPIES, zSubsriptionCopies);
                                            zDataMapVendor.put(Z_DATA_CASE_RECORD_TYPE, CASE_RECORD_TYPE_VENDOR);
                                            zDataMapVendor.put(Z_DATA_TOTAL_COPIES, iTotalCopies);
                                            zDataMapVendor.put(Z_DATA_EFFECTIVE_DATE, dtEffectiveDate);
                                            zDataMapVendor.put(Z_DATA_EFFECTIVE_ISSUE_DATE, mEffectiveIssueData.get(DT_EFFECTIVE_ISSUE_DATE));
                                            zDataMapVendor.put(Z_DATA_RESTART_DATE, dtRestartDate); 
                                            zDataMapVendor.put(Z_DATA_LAST_MODIFIED_DATE, dtLastModifiedDate);                          
                                            zDataMapVendor.put(Z_COA_DATA_MAP, zCoADataMap);
                                            zDataMapVendor.put(Z_DATA_PUBLICATION_PATTERN, zPattern);
                                            zDataMapVendor.put(Z_DATA_SUBSCRIPTION_ID, zSubscriptionID);    //START/END UD-2980 Renino Niefes 2015-10-01
                                            
                                            //Start UD-2438 2015-08-24 Renino Niefes
                                            //if (BT_CO_INT_Utilities.checkValidation(zCheck)) {
                                                processZDataMap(zDataMapVendor,zRecordID,'',mErrorMessageMap);      
                                            //} else {
                                            //    String zReason = mErrorMessageMap.get(Integer.valueOf(ERROR_CODE_NONPUB));
                                            //    String zErrorReason = zReason.replace('$1',zPublicationCode)
                                            //                    .replace('$2',String.valueOf(mEffectiveIssueData.get(DT_START)))
                                            //                    .replace('$3',String.valueOf(mEffectiveIssueData.get(DT_END)));
                                            //    
                                            //    String zData = getZDataString(zDataMapVendor);
                                            //    String zErrMsg = 'EXPORT-FAILED: ' + zErrorReason;
                                            //    String zErrCode = '('+BT_CO_INT_Utilities.convert(ERROR_CODE_NONPUB)+') | '+ERROR_CODE_NONPUB;
                                            //    
                                            //    logFailedRecord(zRecordID, zErrMsg, zErrCode, zData, dtLastModifiedDate);
                                            //}
                                            //End UD-2438 2015-08-24 Renino Niefes
                                            zDEBUGGER += '(V) --- Check-3.3';
                                        }
                                    } 
                                }
                            }
                        }
                    }               
                }
            } catch (Exception e) {
                String zErrMsg = 'CASE-EXCEPTION: '+e.getMessage()+' Trace: '+zDEBUGGER;
                BT_CO_INT_Utilities.log(zErrMsg, zRecordID);
                logFailedRecord(zRecordID, zErrMsg, ERROR_CODE_EXCEPTION, '', Date.today());            
            }
        }
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
                insert datapoolFailedList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            BT_CO_INT_Utilities.log('BT_AB_'+Z_INTERFACE_ID+'_ExportCustomerStartStop insert operation failed.', '');
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
        if (zDataMap != null) {     
            try {
                
                    String zVendor = (String) zDataMap.get(Z_DATA_VENDOR);
                    String zVendorCode = (String) zDataMap.get(Z_DATA_VENDOR_CODE);
                    String zTransType = (String) zDataMap.get(Z_DATA_TRANS_TYPE);
                    String zTransDesc = (String) zDataMap.get(Z_DATA_TRANS_DESC);               
                    String zBlockHouseNumber = (String) zDataMap.get(Z_DATA_BLOCK_HOUSE_NUMBER);
                    String zLevel = (String) zDataMap.get(Z_DATA_LEVEL);
                    String zUnitNumber = (String) zDataMap.get(Z_DATA_UNIT_NUMBER);
                    String zPostalCode = (String) zDataMap.get(Z_DATA_POSTAL_CODE);
                    String zStreetName = (String) zDataMap.get(Z_DATA_STREET_NAME);
                    String zBuildingName = (String) zDataMap.get(Z_DATA_BUILDING_NAME);
                    String zPublicationCode = (String) zDataMap.get(Z_DATA_PUBLICATION_CODE);
                    String zDescription = (String) zDataMap.get(Z_DATA_DESCRIPTION);
                    String zRemarks = (String) zDataMap.get(Z_DATA_REMARKS);
                    String zSubsriptionCopies = (String) zDataMap.get(Z_DATA_SUBSCRIPTION_COPIES);
                    String zCaseRecordType = (String) zDataMap.get(Z_DATA_CASE_RECORD_TYPE);
                    Integer iTotalCopies = (Integer) zDataMap.get(Z_DATA_TOTAL_COPIES);
                    
                    Date dtEffectiveDate = (Date) zDataMap.get(Z_DATA_EFFECTIVE_DATE);
                    Date dtEffectiveIssueDate = (Date) zDataMap.get(Z_DATA_EFFECTIVE_ISSUE_DATE);
                    Date dtRestartDate = (Date) zDataMap.get(Z_DATA_RESTART_DATE);
                                
                    DateTime dtLastModifiedDate = (DateTime) zDataMap.get(Z_DATA_LAST_MODIFIED_DATE);
                    
                    String zSubscriptionID = (String)zDataMap.get(Z_DATA_SUBSCRIPTION_ID);   //START/END UD-2980 2015-10-01 Renino Niefes
                    
                // Validate each mandatory fields
                
                    String zVALIDATION_CODE = zValidation;
                    zVALIDATION_CODE += StringUtility.validate(zVendorCode);
                    zVALIDATION_CODE += StringUtility.validate(zBlockHouseNumber);
                    zVALIDATION_CODE += StringUtility.validate(zPostalCode);
                    zVALIDATION_CODE += StringUtility.validate(zStreetName);
                    zVALIDATION_CODE += StringUtility.validate(zPublicationCode);
                    zVALIDATION_CODE += StringUtility.validate(iTotalCopies);
                    zVALIDATION_CODE += StringUtility.validate(dtEffectiveDate);
                    zVALIDATION_CODE += StringUtility.validate(zSubsriptionCopies);
                    zVALIDATION_CODE += StringUtility.validate(dtEffectiveIssueDate);
                    
                    // If Temp Stop missing restart date don't add it to the file ...
                    zVALIDATION_CODE += (zTransDesc.equalsIgnoreCase(TRANSACTION_DESC_TEMP_STOP)) ? StringUtility.validate(dtRestartDate) : '0';                    
                    
                    if (zTransDesc.equalsIgnoreCase(TRANSACTION_DESC_COA)) {
                        Map<String,Object> zCoADataMap = (Map<String,Object>) zDataMap.get(Z_COA_DATA_MAP);
                        if (zCoADataMap != null) {
                            String zNewBlockHouseNumber = (String) zCoADataMap.get(Z_COA_BLOCK_HOUSE_NUMBER);
                            String zNewLevel = (String) zCoADataMap.get(Z_COA_LEVEL);
                            String zNewStreetName = (String) zCoADataMap.get(Z_COA_STREET_NAME);
                            String zNewPostalCode = (String) zCoADataMap.get(Z_COA_POSTAL_CODE);
                            String zNewVendorCode = (String) zCoADataMap.get(Z_COA_VENDOR_CODE);
                            
                            Date dtNewEffectiveDate = (Date) zCoADataMap.get(Z_COA_EFFECTIVE_DATE);     
                            
                            zVALIDATION_CODE += StringUtility.validate(zNewBlockHouseNumber);
                            zVALIDATION_CODE += StringUtility.validate(zNewLevel);
                            zVALIDATION_CODE += StringUtility.validate(zNewStreetName);
                            zVALIDATION_CODE += StringUtility.validate(zNewPostalCode);
                            zVALIDATION_CODE += StringUtility.validate(dtNewEffectiveDate);
                            zVALIDATION_CODE += StringUtility.validate(zNewVendorCode);
                        }                                       
                    }
                    
                // override zVALIDATION_CODE
                zVALIDATION_CODE = '0000000000000000';
                
                // Prepare the zData
                    String zData = '';      
                    zData =  StringUtility.quoteReplaceStr(zVendor) + ',';
                    zData += StringUtility.quoteReplaceStr(zTransType) + ',';
                    zData += StringUtility.quoteReplaceStr(zTransDesc) + ',';
                    zData += StringUtility.quoteReplaceStr(zBlockHouseNumber) + ',';
                    zData += StringUtility.quoteReplaceStr(zLevel) + ',';
                    zData += StringUtility.quoteReplaceStr(zUnitNumber) + ',';
                    zData += StringUtility.quoteReplaceStr(zPostalCode) + ',';
                    zData += StringUtility.quoteReplaceStr(zStreetName) + ',';
                    zData += StringUtility.quoteReplaceStr(zBuildingName) + ',';
                    zData += StringUtility.quoteReplaceStr(zPublicationCode) + ',';
                    zData += StringUtility.quoteReplaceStr(String.valueOf(iTotalCopies)) + ',';
                    zData += StringUtility.quoteReplaceStr(String.valueOf(dtEffectiveDate)) + ',';
                    zData += StringUtility.quoteReplaceStr(String.valueOf(dtEffectiveIssueDate)) + ',';
                    zData += StringUtility.quoteReplaceStr(String.valueOf(dtRestartDate)) + ',';
                    zData += StringUtility.quoteReplaceStr(zDescription) + ',';
                    zData += StringUtility.quoteReplaceStr(zRemarks) + ',';
                    zData += StringUtility.quoteReplaceStr(zSubsriptionCopies) + ',';
                    zData += StringUtility.quoteReplaceStr(zSubscriptionID) + ',';     //START/END UD-2980 2015-10-01 Renino Niefes
                    
                    if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE)) {
                        if (BT_CO_INT_Utilities.exportDataItemDuplicateCheck(zData, exportDataSet)) {
                            exportDataSet.add(zData);
                            datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', zRecordID, zData, dtLastModifiedDate, datapoolList);                                            
                        }
                        
                        String zSupplementalData = null;
                        if (zTransDesc.equalsIgnoreCase(TRANSACTION_DESC_TEMP_STOP)) {
                            // Create 'START' entry for the TempStop record ...
                            zSupplementalData = getSupplementalZData(zRecordID, zDataMap, Z_MODE_TEMP_STOP, mErrorMessageMap);
                        } else if (zTransDesc.equalsIgnoreCase(TRANSACTION_DESC_COA)) {
                            // Create 'START' entry for Change of Address record ...
                            zSupplementalData = getSupplementalZData(zRecordID, zDataMap, Z_MODE_COA, mErrorMessageMap);
                        }
                        if (zSupplementalData != null && zSupplementalData.length() > 0) {
                            datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', zRecordID, zSupplementalData, dtLastModifiedDate, datapoolList);
                        }
                        
                        // Reset Validation Code ...
                        zVALIDATION_CODE = '';
                    } else {
                        BT_CO_INT_Utilities.log('EXPORT-FAILED '+zCaseRecordType+': ',zRecordID, zVALIDATION_CODE, zData); 
                        String zErrorReason = BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, mErrorMessageMap);
                        String zErrMsg = '('+zCaseRecordType+') EXPORT-FAILED: ' + zErrorReason;
                        logFailedRecord(zRecordID, zErrMsg, BT_CO_INT_Utilities.convert(zVALIDATION_CODE), zData, dtLastModifiedDate);      
                    }       
            } catch (Exception e) {
                String zErrMsg = '(EXCEPTION) PROCESS-Z-DATA-FAILED - '+e.getMessage();
                BT_CO_INT_Utilities.log(zErrMsg,zRecordID);
                logFailedRecord(zRecordID, zErrMsg, ERROR_CODE_ZDATA_FAILURE, getZDataString(zDataMap), Date.today());
            }               
        }
    }
    
    private void logFailedRecord(String zRecordID, String zErrMsg, String zErrCode, String zData, DateTime dtLastModifiedDate) {
        datapoolFailedList = BT_CO_INT_Utilities.exportFailedDataItem(  
            Z_INTERFACE_ID, 
            'Detail',
            zRecordID, 
            zErrMsg, 
            zErrCode, 
            zData, 
            dtLastModifiedDate, 
            datapoolFailedList);            
    }
    
    private String getSupplementalZData(ID zRecordID, Map<String, Object> zDataMap, Integer iDataMode, Map<Decimal,String> mErrorMessageMap) {
        String zResult = null;    
        
        String zBlockHouseNumber = null;
        String zLevel = null;
        String zPostalCode = null;
        String zStreetName = null;
        String zUnitNumber = null;
        String zBuildingName = null;
        Date dtEffectiveDate = null;
        Date dtEffectiveIssueDate = null;

        Integer iMode = Integer.valueOf(iDataMode);
        String zPattern = (String) zDataMap.get(Z_DATA_PUBLICATION_PATTERN);
        String zVendor = (String) zDataMap.get(Z_DATA_VENDOR);
        String zVendorCode = (String) zDataMap.get(Z_DATA_VENDOR_CODE);
        String zTransDesc = (String) zDataMap.get(Z_DATA_TRANS_DESC);
        String zPublicationCode = (String) zDataMap.get(Z_DATA_PUBLICATION_CODE);
        String zDescription = (String) zDataMap.get(Z_DATA_DESCRIPTION);
        String zRemarks = (String) zDataMap.get(Z_DATA_REMARKS);
        String zSubsriptionCopies = (String) zDataMap.get(Z_DATA_SUBSCRIPTION_COPIES);
        String zCaseRecordType = (String) zDataMap.get(Z_DATA_CASE_RECORD_TYPE);
        Integer iTotalCopies = (Integer) zDataMap.get(Z_DATA_TOTAL_COPIES);
        Date dtRestartDate = (Date) zDataMap.get(Z_DATA_RESTART_DATE);
        
        String zSubscriptionID = (String) zDataMap.get(Z_DATA_SUBSCRIPTION_ID);      //START/END UD-2980 2015-10-01 Renino Niefes
        
        //START 2015-09-29 Renz UD-2536 Fix for COA case
        dtEffectiveDate = (Date) zDataMap.get(Z_DATA_EFFECTIVE_DATE);        
        // Recalculate the 'NEW' Effective issue date using the restart date as the base ...
        Map<String, Date> mDataRecordMap = new Map<String, Date>();
        if (dtRestartDate!=null) {
            mDataRecordMap.put(DT_START, dtRestartDate);
        } else {
            mDataRecordMap.put(DT_START, dtEffectiveDate);
        }       
        mDataRecordMap.put(DT_END, DateUtility.getDefaultEndDate());
        Map<String, Date> mEffectiveIssueData = getEffectiveIssueData(null, zPattern, mDataRecordMap);
        //END 2015-09-29 Renz UD-2536 Fix for COA case
        
        // Check the calculated effective-issue-date ...
        String zCheck = (mEffectiveIssueData != null && mEffectiveIssueData.get(DT_EFFECTIVE_ISSUE_DATE) != null) ? '0' : '1';
        dtEffectiveIssueDate =  mEffectiveIssueData.get(DT_EFFECTIVE_ISSUE_DATE);                                       
        
        if (iMode == Z_MODE_TEMP_STOP) {
            zBlockHouseNumber = (String) zDataMap.get(Z_DATA_BLOCK_HOUSE_NUMBER);
            zLevel = (String) zDataMap.get(Z_DATA_LEVEL);
            zUnitNumber = (String) zDataMap.get(Z_DATA_UNIT_NUMBER);
            zPostalCode = (String) zDataMap.get(Z_DATA_POSTAL_CODE);
            zStreetName = (String) zDataMap.get(Z_DATA_STREET_NAME);
            zBuildingName = (String) zDataMap.get(Z_DATA_BUILDING_NAME);
            
            // TempStop Restart Date only for 'stop' component as per SPH
            dtRestartDate = null;
            
            dtEffectiveDate = (Date) zDataMap.get(Z_DATA_RESTART_DATE);         
        } else if (iMode == Z_MODE_COA) {
            Map<String,Object> zCoADataMap = (Map<String,Object>) zDataMap.get(Z_COA_DATA_MAP);
            if (zCoADataMap != null) {
                zVendor = (String) zCoADataMap.get(Z_COA_VENDOR);
                zVendorCode = (String) zCoADataMap.get(Z_COA_VENDOR_CODE);
                zBlockHouseNumber = (String) zCoADataMap.get(Z_COA_BLOCK_HOUSE_NUMBER);
                zLevel = (String) zCoADataMap.get(Z_COA_LEVEL);
                zUnitNumber = (String) zCoADataMap.get(Z_COA_UNIT_NUMBER);
                zPostalCode = (String) zCoADataMap.get(Z_COA_POSTAL_CODE);
                zStreetName = (String) zCoADataMap.get(Z_COA_STREET_NAME);
                zBuildingName = (String) zCoADataMap.get(Z_COA_BUILDING_NAME);              
                dtEffectiveDate = (Date) zCoADataMap.get(Z_COA_EFFECTIVE_DATE);                     
            }
        }
                
        
        String zData =  StringUtility.quoteReplaceStr(zVendor) + ',';
        zData += StringUtility.quoteReplaceStr(TRANSACTION_TYPE_START) + ',';
        zData += StringUtility.quoteReplaceStr(zTransDesc) + ',';
        zData += StringUtility.quoteReplaceStr(zBlockHouseNumber) + ',';
        zData += StringUtility.quoteReplaceStr(zLevel) + ',';
        zData += StringUtility.quoteReplaceStr(zUnitNumber) + ',';
        zData += StringUtility.quoteReplaceStr(zPostalCode) + ',';
        zData += StringUtility.quoteReplaceStr(zStreetName) + ',';
        zData += StringUtility.quoteReplaceStr(zBuildingName) + ',';
        zData += StringUtility.quoteReplaceStr(zPublicationCode) + ',';
        zData += StringUtility.quoteReplaceStr(String.valueOf(iTotalCopies)) + ',';
        zData += StringUtility.quoteReplaceStr(String.valueOf(dtEffectiveDate)) + ',';
        zData += StringUtility.quoteReplaceStr(String.valueOf(dtEffectiveIssueDate)) + ',';
        zData += StringUtility.quoteReplaceStr(String.valueOf(dtRestartDate)) + ',';
        zData += StringUtility.quoteReplaceStr(zDescription) + ',';
        zData += StringUtility.quoteReplaceStr(zRemarks) + ',';
        zData += StringUtility.quoteReplaceStr(zSubsriptionCopies) + ',';    
        zData += StringUtility.quoteReplaceStr(zSubscriptionID) + ',';    //START/END UD-2980 2015-10-01 Renino Niefes      
        
        //START UD-2536 Renz 2015-09-29 Remove validation
        //if (BT_CO_INT_Utilities.checkValidation(zCheck)) {
            zResult = zData;
        //} else {
        //    DateTime dtLastModifiedDate = (DateTime) zDataMap.get(Z_DATA_LAST_MODIFIED_DATE);
        //    String zReason = mErrorMessageMap.get(Integer.valueOf(ERROR_CODE_NONPUB));
        //    String zErrorReason = zReason.replace('$1',zPublicationCode)
        //                    .replace('$2',String.valueOf(mEffectiveIssueData.get(DT_START)))
        //                    .replace('$3',String.valueOf(mEffectiveIssueData.get(DT_END)));
        //    String zErrMsg = 'EXPORT-FAILED: ' + zErrorReason;
        //    String zErrCode = '('+BT_CO_INT_Utilities.convert(ERROR_CODE_NONPUB)+') | '+ERROR_CODE_NONPUB;
        //    logFailedRecord(zRecordID, zErrMsg, zErrCode, zData, dtLastModifiedDate);           
        //}
        //END UD-2536 Renz 2015-09-29 Remove validation
        
        return zResult;
    }
    
    private String getZDataString(Map<String, Object> zDataMap) {
        String zData = '';      
        if (zDataMap != null) {
            String zVendor = (String) zDataMap.get(Z_DATA_VENDOR);
            String zTransType = (String) zDataMap.get(Z_DATA_TRANS_TYPE);
            String zTransDesc = (String) zDataMap.get(Z_DATA_TRANS_DESC);
            String zBlockHouseNumber = (String) zDataMap.get(Z_DATA_BLOCK_HOUSE_NUMBER);
            String zLevel = (String) zDataMap.get(Z_DATA_LEVEL);
            String zUnitNumber = (String) zDataMap.get(Z_DATA_UNIT_NUMBER);
            String zPostalCode = (String) zDataMap.get(Z_DATA_POSTAL_CODE);
            String zStreetName = (String) zDataMap.get(Z_DATA_STREET_NAME);
            String zBuildingName = (String) zDataMap.get(Z_DATA_BUILDING_NAME);
            String zPublicationCode = (String) zDataMap.get(Z_DATA_PUBLICATION_CODE);
            String zDescription = (String) zDataMap.get(Z_DATA_DESCRIPTION);
            String zRemarks = (String) zDataMap.get(Z_DATA_REMARKS);
            String zSubsriptionCopies = (String) zDataMap.get(Z_DATA_SUBSCRIPTION_COPIES);
            Integer iTotalCopies = (Integer) zDataMap.get(Z_DATA_TOTAL_COPIES);
            
            Date dtEffectiveDate = (Date) zDataMap.get(Z_DATA_EFFECTIVE_DATE);
            Date dtEffectiveIssueDate = (Date) zDataMap.get(Z_DATA_EFFECTIVE_ISSUE_DATE);
            Date dtRestartDate = (Date) zDataMap.get(Z_DATA_RESTART_DATE);
                     
            zData =  StringUtility.quoteReplaceStr(zVendor) + ',';
            zData += StringUtility.quoteReplaceStr(zTransType) + ',';
            zData += StringUtility.quoteReplaceStr(zTransDesc) + ',';
            zData += StringUtility.quoteReplaceStr(zBlockHouseNumber) + ',';
            zData += StringUtility.quoteReplaceStr(zLevel) + ',';
            zData += StringUtility.quoteReplaceStr(zUnitNumber) + ',';
            zData += StringUtility.quoteReplaceStr(zPostalCode) + ',';
            zData += StringUtility.quoteReplaceStr(zStreetName) + ',';
            zData += StringUtility.quoteReplaceStr(zBuildingName) + ',';
            zData += StringUtility.quoteReplaceStr(zPublicationCode) + ',';
            zData += StringUtility.quoteReplaceStr(String.valueOf(iTotalCopies)) + ',';
            zData += StringUtility.quoteReplaceStr(String.valueOf(dtEffectiveDate)) + ',';
            zData += StringUtility.quoteReplaceStr(String.valueOf(dtEffectiveIssueDate)) + ',';
            zData += StringUtility.quoteReplaceStr(String.valueOf(dtRestartDate)) + ',';
            zData += StringUtility.quoteReplaceStr(zDescription) + ',';
            zData += StringUtility.quoteReplaceStr(zRemarks) + ',';
            zData += StringUtility.quoteReplaceStr(zSubsriptionCopies) + ',';
        }
        return zData;
    }
    
    private Map<String, Date> getEffectiveIssueData(String zRecordType, String zPattern, Map<String, Date> mDateRecordMap) {
        Date dStart = mDateRecordMap.get(DT_START);
        Date dEnd = mDateRecordMap.get(DT_END);
        Map<String, Date> mDateResultMap = new Map<String, Date>();
                
        if (mDateRecordMap != null && zPattern != null) {
            if (zRecordType != null) {
                if (zRecordType.equalsIgnoreCase(COMPLAINT_NEWSPAPER)) {
                    dStart = mDateRecordMap.get(DT_COMPLAINT_FROM);
                    dEnd = mDateRecordMap.get(DT_COMPLAINT_TO);
                } else if (zRecordType.equalsIgnoreCase(TSTOP_SUBSCRIPTION)) {
                    dStart = mDateRecordMap.get(DT_EFFECTIVE_DATE);
                    dEnd = mDateRecordMap.get(DT_RESTART_DATE);
                } else {
                    dStart = mDateRecordMap.get(DT_Z_SUBSCRIPTION_START_DATE);
                    dEnd = mDateRecordMap.get(DT_Z_SUBSCRIPTION_END_DATE);
                    if (zRecordType.equalsIgnoreCase(V_STOP_REQEUEST) 
                        || zRecordType.equalsIgnoreCase(STOP_SUBSCRIPTION)) {       
                        dStart = mDateRecordMap.get(DT_STOP_REQUEST_DATE);                                  
                        dEnd = DateUtility.getDefaultEndDate();
                    }
                    //START UD-2161 Moving the fix for UD-2438 to this area so that it won't affect temp stops.  Check if dStart/dEnd are null
                    if (dStart == null) {
                        dStart = Date.today();
                    }
                    
                    if (dEnd == null) {
                        dEnd = DateUtility.getDefaultEndDate();
                    }
            
                    //START UD-2438 If start Date is same as End date, set a default value 2099-12-31
                    if (dStart.daysBetween(dEnd)<=7) {
                        dEnd = DateUtility.getDefaultEndDate();
                    }
                    //END UD-2438 If start Date is same as End date, set a default value 2099-12-31
                    //END UD-2161 Moving the fix for UD-2438 to this area so that it won't affect temp stops
                }               
            }

            mDateResultMap.put(DT_EFFECTIVE_ISSUE_DATE, BT_CO_INT_Utilities.getEffectiveIssueDate(dStart, dEnd, zPattern));
            mDateResultMap.put(DT_START, dStart);
            mDateResultMap.put(DT_END, dEnd);
        }       
        return mDateResultMap;          
    }
    
    private String calcSubCopies(List<Decimal> records, Integer iLength) {
        String zRESULT = '';
        try {    
            String zDayCopy = '';
            if (iLength != null && iLength > 0) {
                for (Integer i = 0; i<iLength; i++) {
                    zDayCopy += '0';
                }   
            }
            if (records.size() == MAX_SUBSCRIPTION_COPY_IND) {
                for (Decimal iRec : records) {
                    if (iRec != null) {
                        zRESULT += StringUtility.formatValue(iRec, '0', 'left', iLength);
                    } else {
                        zRESULT += zDayCopy;
                    }
                }
            } else {
                zRESULT = getDefaultSubCopies(iLength);
            }           
        } catch (Exception e) {
            zRESULT = getDefaultSubCopies(iLength);
        }
        if (Decimal.valueOf(zRESULT) <= 0) {
            zRESULT = null;
        }
        return zRESULT;
    }
    
    private String getDefaultSubCopies(Integer iLength) {
        String zDayCopy = '';
        if (iLength != null && iLength > 0) {
            for (Integer i = 0; i<iLength; i++) {
                zDayCopy += '0';
            }   
        } 
        String zDEFAULT = '';
        for (Integer i = 0; i<MAX_SUBSCRIPTION_COPY_IND; i++) {
            zDEFAULT += zDayCopy;
        }
        return zDEFAULT;
    }
        
    private String getTransactionType(String zRecordType) {
        String zResult = '';
        if (zRecordType != null) {
            if (zRecordType.equalsIgnoreCase(START_SUBSCRIPTION)) {
                zResult = TRANSACTION_TYPE_START;
            } else if (zRecordType.equalsIgnoreCase(V_STOP_REQEUEST)
                     ||zRecordType.equalsIgnoreCase(CHANGE_OF_ADDRESS)
                     ||zRecordType.equalsIgnoreCase(STOP_SUBSCRIPTION)
                     ||zRecordType.equalsIgnoreCase(TSTOP_SUBSCRIPTION)) {
                zResult = TRANSACTION_TYPE_STOP;
            } else if (zRecordType.equalsIgnoreCase(COMPLAINT_NEWSPAPER)) {
                zResult = TRANSACTION_TYPE_COMPLAINTS;
            }           
        } 
        return zResult;    
    }
    
    private String getTransactionDesc(String zRecordType, Case cRecord) {
        String zResult = '';
        if (zRecordType != null) {
            if (zRecordType.equalsIgnoreCase(START_SUBSCRIPTION)) {
                zResult = TRANSACTION_DESC_NEW;
            } else if (zRecordType.equalsIgnoreCase(CHANGE_OF_ADDRESS)) {
                zResult = TRANSACTION_DESC_COA;
            } else if (zRecordType.equalsIgnoreCase(TSTOP_SUBSCRIPTION)) {
                zResult = TRANSACTION_DESC_TEMP_STOP;
            } else if (zRecordType.equalsIgnoreCase(STOP_SUBSCRIPTION) || zRecordType.equalsIgnoreCase(V_STOP_REQEUEST)) {
                zResult = TRANSACTION_DESC_PSTOP;              
            } else if (zRecordType.equalsIgnoreCase(COMPLAINT_NEWSPAPER)) {
                if (cRecord != null) {
                    zResult = cRecord.Sub_Category__c;
                }
            }                  
        }
        if (zResult == null) {
            zResult = '';
        }
        return zResult;
    }
    
    private Map<ID,Set<Publication__c>> packageToPublication(List<ID> lPackages){
        Map<ID,Set<Publication__c>> mPackageToPublication = new Map<ID,Set<Publication__c>>();
        try {
            mPackageToPublication = BT_CO_INT_Utilities.packageToPublication(lPackages);
        } catch (Exception e) {
            mPackageToPublication = new Map<ID,Set<Publication__c>>();
        }
        return mPackageToPublication;
    }

    // END 2015/04/30 D-2831 Michael Francisco
        
    //START 2015-09-30 Renz UD-2708
    private Date convertBRD_To_Date(String brd) {
        Date dResult = null;
        if (brd != null) {
            try {
                dResult = Date.valueOf(brd);
            } catch (Exception e) {
                dResult = getDateToday(0);
            }
        } else {
            dResult = getDateToday(0);
        }
        return dResult;
    }   

    private Date getDateToday(Integer iOffsetDays) {
        Date d = Date.today();
        if (iOffsetDays != null) {
            try {
                if (batchRunDateX==null) batchRunDateX = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID);  
                Date dBatchRunDate1 = convertBRD_To_Date(batchRunDateX);      
                d = dBatchRunDate1.addDays(iOffsetDays);     
            } catch (Exception e) {
                Date dNew = Date.today();
                d = dNew.addDays(iOffsetDays);  
            }
        }
        return d;       
    }
    //END 2015-09-30 Renz UD-2708   
}