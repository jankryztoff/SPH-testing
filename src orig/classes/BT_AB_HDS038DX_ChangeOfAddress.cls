/*
 * Class Name: BT_AB_HDS038DX_ChangeOfAddress
 * @author: Renino Niefes
 * Date: 2015/05/20
 * Project/Requirement: SPH Integration - HDS038DX Interface
 * @description For Change Of Address and Change of Subscription Transactions only
 * 
 * History:
 *     2015/05/20 Renino Niefes Created Skeletal Apex Batchable
 *     2015/07/31 Renino Niefes             - Hot Fix: Override zValidation Code to Pass.  Moving validation checks to on-premise server and save to FAI file
 *     2015/08/14 Renino Niefes                 UD-2132 Add another condition when creating export data.  Use Product family to match the current record.  If it matches, then create a new record
 *     2015/08/24 Kevin Evasco              - UD-2048 Hot Fix: Include cases closed after effective date to the output file
 *     2015/09/22 Renino Niefes             - UD-2895 Hot Fix (uat2) Add the product code of the old subs as well. add nullity check too.
 *     2015/09/23 Raviteja Kumar            - UD-2691 Added Database.Stateful
 *     2015/09/25 Renino Niefes             - UD-2536 Hot fix (uat2) Change the logic for getting the old Address 
 *     2015/10/01 Renino Niefes             - UD-2980 add Subscription ID 
 *     2015/10/08 Renino Niefes             - UD-2599 Hot Fixed. For change of subscription cases, check if the Old Subscription's start date is greater than end date.  If it is, reject that record
 *     2015/10/12 Renino Niefes             - UD-3077 Hot fixed in UAT2.  Subscription ID should use old and new.  Current only uses new Subscription IDs.
 *     2015/10/12 Renino Niefes             - UD-3080 Hotfix in UAT2, exclude cases with sub_status__c like '%rejected%'
 *     2015/11/11 Renino Niefes             - D-3914 Company_Name__c is the new field for "Attention To" parameter
 *     2016/01/07 Renino Niefes             - UD-3634 Use Case's effective date as effective issue date for all publications if case is COA
 *     2016/01/18 Renino Niefes             - UD-3634 for COA and COV determine the effective issue date for all publications but this time add 7 days after subscription end date
 *     2016/01/28 Renino Niefes             - UD-3848 Add only vendor delivered subscriptions for direct subscribers
 */

//START UD-2691 23-Sep-2015 Added by Raviteja  - Added Database.Stateful
//global class BT_AB_HDS038DX_ChangeOfAddress implements Database.Batchable<sObject>,Database.AllowsCallouts
global class BT_AB_HDS038DX_ChangeOfAddress implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful
//End UD-2691 23-Sep-2015 Added by Raviteja
{
    global final String Z_INTERFACE_ID = 'HDS038DX';
    global final String CHANGE_OF_ADDRESS = 'Change_of_Address';
   global final String CHANGE_OF_VENDOR = 'Change_of_Vendor';
    global final String CHANGE_OF_SUBSCRIPTION = 'Change_of_Subscription';
    global final String RENEWAL_OF_SUBSCRIPTION = 'Renewal_of_Subscription';
    
    global final String CHANGE_OF_VENDOR_TYPE = 'Change of Vendor'; 
    global final String CHANGE_OF_ADDRESS_TYPE = 'Change of%Delivery%';
    
    global final String CASE_STATUS_CLOSED = 'Closed';
    global final String DEFAULT_END_DATE = '20991231';
    global final String INDICATOR_YES = 'Y';
    global final String INDICATOR_NO = 'N';
    
    global final String TRANSACTION_TYPE_START = 'Start';
    global final String TRANSACTION_TYPE_STOP = 'Stop';
    
    global final String TRANSACTION_DESC_COA = 'Change of Address';
    global final String TRANSACTION_DESC_ROS = 'Renewal of Subscription';
    global final String TRANSACTION_DESC_COS = 'Change of Subscription';
    global Map<String, Set<String>> mapProdPub = new Map<String, Set<String>>(); //START/End UD-2691 23-Sep-2015 Added by Raviteja
    /* ========== ZDATA - SUBSCRIPTION MAP KEYS ========== */
    global final String ZDATA_SUBSCRIPTION_VENDOR_GROUP = 'SCRPT_VENDOR_GROUP';
    global final String ZDATA_SUBSCRIPTION_VENDOR_CODE = 'SCRPT_VENDOR_CODE';
    global final String ZDATA_SUBSCRIPTION_BLK_H_NUMBER = 'SCRPT_BLK_H_NUMBER';
    global final String ZDATA_SUBSCRIPTION_LEVEL_NUMBER = 'SCRPT_LEVEL_NUMBER';
    global final String ZDATA_SUBSCRIPTION_UNIT_NUMBER = 'SCRPT_UNIT_NUMBER';
    global final String ZDATA_SUBSCRIPTION_POSTAL_CODE = 'SCRPT_POSTAL_CODE';
    global final String ZDATA_SUBSCRIPTION_STREET_NAME = 'SCRPT_STREET_NAME';
    global final String ZDATA_SUBSCRIPTION_BLDG_NAME = 'SCRPT_BLDG_NAME';
    global final String ZDATA_SUBSCRIPTION_CRSM_CONTACT_NUMBER = 'SCRPT_CRSM_CONTACT_NUMBER';
    global final String ZDATA_SUBSCRIPTION_RECIPIENT_CONTACT_LEGACY_ID = 'SCRPT_RECIPIENT_CONTACT_LEGACY_ID';
    global final String ZDATA_SUBSCRIPTION_RECIPIENT_CONTACT_NAME = 'SCRPT_RECIPIENT_CONTACT_NAME';
    global final String ZDATA_SUBSCRIPTION_NAME = 'SCRPT_NAME';
    global final String ZDATA_SUBSCRIPTION_QTY = 'SCRPT_QTY';
    global final String ZDATA_SUBSCRIPTION_PUBTAG = 'SCRPT_PUBTAG';
    global final String ZDATA_SUBSCRIPTION_FREQUENCY = 'SCRPT_FREQUENCY';
    global final String ZDATA_SUBSCRIPTION_PRODUCT_CODE = 'SCRPT_PRODUCT_CODE';
    global final String ZDATA_SUBSCRIPTION_START_DATE = 'SCRPT_START_DATE';
    global final String ZDATA_SUBSCRIPTION_END_DATE = 'SCRPT_END_DATE';
    global final String ZDATA_SUBSCRIPTION_LAST_MODIFIED_DATE = 'SCRPT_LAST_MODIFIED_DATE';
    global final String ZDATA_SUBSCRIPTION_Z_STATUS = 'SCRPT_Z_STATUS';
    global final String ZDATA_SUBSCRIPTION_MAIN_PACKAGE_ID = 'SCRPT_MAIN_PACKAGE_ID';   
    
    global static final Integer ZDATA_NEW_DATA = 0;
    global static final Integer ZDATA_OLD_DATA = 1; 
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //prepare the status set applicable to this interface
        Set<String> caseStatusSet = new Set<String>();
        caseStatusSet.add(CASE_STATUS_CLOSED);

        //prepare the status set applicable to this interface
        Set<String> caseRecordTypeSet = new Set<String>();
        caseRecordTypeSet.add(CHANGE_OF_ADDRESS);
        caseRecordTypeSet.add(CHANGE_OF_SUBSCRIPTION);
        
        //Prepare the cutoff dates
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID);     
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(brd,'Default Timestamp');     
        DateTime cutOffStart = cutOffEnd.addDays(-1); 
        Date dtEffStart = Date.valueOf(brd);        
        Date dtEffEnd = dtEffStart.addDays(1);              
        

        //START 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
        DateTime dStartDate = DateTime.newInstance(dtEffStart.year(),dtEffStart.month(),dtEffStart.day());
        DateTime dEndDate = dStartDate.addDays(1);      
        

        mapProdPub = BT_CO_INT_Utilities.prodPubMapping();   //START/End UD-2691 23-Sep-2015 Added by Raviteja 
        
        String query = '';
        query += ' SELECT ';
        query += '      Case__r.Id, ';
        query += '      Case__r.Restart_Date__c, ';
        query += '      Case__r.Effective_Date__c, ';
        query += '      Case__r.Change_of_Address_Type__c, ';   
        query += '      Case__r.LastModifiedDate, ';
        query += '      Case__r.POP_Start_Date__c, ';
        query += '      Case__r.Earliest_Stop_Date__c, ';
        query += '      Case__r.Stop_Request_Date__c, ';
        query += '      Case__r.Stop_Date__c, ';
        query += '      Case__r.Temp_Stop_Date__c, ';
        query += '      Case__r.RecordType.DeveloperName, ';  
        query += '      Case__r.Status, ';      
        query += '     Case__r.Order__c, ';
        query += '     Case__r.Order__r.ID, ';
        query += '     Case__r.Order__r.Subscription__r.ID, ';
        query += '     Case__r.CreatedDate, ';  
        query += '      Case__r.Vendor__r.Vendor_Group__c, ';   
        query += '      Case__r.Vendor__r.Vendor_Code__c, ';    
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Block_House_Number__c,  ';
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Level_Number__c,  ';
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Unit_Number__c,  ';
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name, '; 
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Street_Name__c,  ';
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Building_Name__c,  ';
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Contact_Legacy_Id__c,  ';
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Id,  ';
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Name,  ';
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Recipient_Number__c,  ';
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Salutation,       ';
        query += '      Case__r.Subscription_Name__r.Recipient_Contact__r.Company_Name__c,  ';  //START/END D-3914 2015-11-11 Renz Company_Name__c is the new attention to name
        query += '      Case__r.Subscription_Name__r.Id,  ';
        query += '      Case__r.Subscription_Name__r.Name,  ';
        query += '      Case__r.Subscription_Name__r.Qty__c,  ';
        query += '      Case__r.Subscription_Name__r.Pub_Tag__c, ';               
        query += '      Case__r.Subscription_Name__r.Frequency__c,  ';
        query += '      Case__r.Subscription_Name__r.Product_Code__c,  ';
        query += '      Case__r.Subscription_Name__r.Zuora__SubscriptionStartDate__c,  ';
        query += '      Case__r.Subscription_Name__r.Zuora__SubscriptionEndDate__c,  ';
        query += '      Case__r.Subscription_Name__r.Effective_Start_Date__c,   ';    
        query += '      Case__r.Subscription_Name__r.Effective_End_Date__c,       ';          
        query += '      Case__r.Subscription_Name__r.Vendor_1__r.Id,  ';
        query += '      Case__r.Subscription_Name__r.Vendor_1__r.Vendor_Group__c, '; 
        query += '      Case__r.Subscription_Name__r.Vendor_1__r.Vendor_Code__c,  ';
        query += '      Case__r.Subscription_Name__r.Main_Package_1__c,  ';
        query += '      Case__r.Subscription_Name__r.LastModifiedDate,  ';
        query += '      Case__r.Subscription_Name__r.Zuora__Status__c,   ';
        
        //START UD-2536 Renino Niefes 2015-09-25 Add the old address fields in the main query
        query += '      Address__r.Id,  ';
        query += '      Address__r.Block_House_Number__c,  ';
        query += '      Address__r.Level_Number__c,  ';
        query += '      Address__r.Unit_Number__c,  ';
        query += '      Address__r.Postal_Code__r.Name, '; 
        query += '      Address__r.Street_Name__c,  ';
        query += '      Address__r.Building_Name__c,  ';
        //END UD-2536 Renino Niefes 2015-09-25
        
        query += '      Subscription__r.Vendor_1__r.Id, ';
        query += '      Subscription__r.Vendor_1__r.Vendor_Group__c, ';
        query += '      Subscription__r.Vendor_1__r.Vendor_Code__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name, ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Contact_Legacy_Id__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Id, ';
        query += '      Subscription__r.Recipient_Contact__r.Name, ';
        query += '      Subscription__r.Recipient_Contact__r.Recipient_Number__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Company_Name__c, ';    //START/END D-3914 2015-11-11 Renz Company_Name__c is the new attention to name
        query += '      Subscription__r.Id, ';
        query += '      Subscription__r.Name, ';      
        query += '      Subscription__r.Qty__c, ';      
        query += '      Subscription__r.Pub_Tag__c, ';                
        query += '      Subscription__r.Frequency__c, ';
        query += '      Subscription__r.Product_Code__c, ';       
        query += '      Subscription__r.Zuora__SubscriptionStartDate__c, ';
        query += '      Subscription__r.Zuora__SubscriptionEndDate__c, ';
        query += '      Subscription__r.LastModifiedDate, ';
        query += '      Subscription__r.Zuora__Status__c, ';    
        query += '      Subscription__r.Main_Package_1__c, ';       
        query += '      Account__r.Attention_To_Care_Of__c, ';
        query += '      Account__r.Account_Legacy_Id__c, ';
        query += '      Account__r.Account_Auto_Number__c, ';
        query += '      Account__r.CreatedDate, ';
        query += '      Account__r.Id, ';
        query += '      Account__r.Name, ';
        query += '      LastModifiedDate ';
        query += ' FROM ';
        query += '      Case_Subscription__c ';
        query += ' WHERE ';
        query += '      Case__r.Status IN :caseStatusSet ';
        query += '      AND Subscription__r.Delivered_By_1__c = \'Vendor\' ';     //START/END 2016/01/28 Renino Niefes        UD-3848       
        query += '      AND ( ';
        query += '              (   Case__r.RecordType.DeveloperName = :CHANGE_OF_ADDRESS ';
        query += '                  AND (   Case__r.Change_of_Address_Type__c LIKE :CHANGE_OF_ADDRESS_TYPE';
        query += '                          OR Case__r.Change_of_Address_Type__c = :CHANGE_OF_VENDOR_TYPE';                 
        query += '                  ) ';
        query += '                 AND ';
        query += '                     ( Case__r.Effective_Date__c = :dtEffEnd ';
        query += '                     OR ( Case__r.Effective_Date__c <= :dtEffStart ';
        query += '                         AND Case__r.ClosedDate >= :dStartDate ';
        query += '                         AND Case__r.ClosedDate < :dEndDate )';
        query += '                     ) ';
        query += '          ) OR ( ';
        query += '                  ( Subscription__r.Zuora__SubscriptionStartDate__c = :dtEffEnd ';        
        query += '                     OR ( Subscription__r.Zuora__SubscriptionStartDate__c <= :dtEffStart ';
        query += '                         AND Case__r.ClosedDate >= :dStartDate ';
        query += '                         AND Case__r.ClosedDate < :dEndDate ) ';      
        query += '                  ) AND ( '; 
        query += '                      Case__r.RecordType.DeveloperName = :CHANGE_OF_SUBSCRIPTION ';
        query += '                      OR Case__r.RecordType.DeveloperName = :RENEWAL_OF_SUBSCRIPTION ';
        query += '                  ) ';
        query += '          ) '; 
        query += '      ) ';
        query += '      AND (NOT Case__r.Sub_Status__c LIKE \'%Rejected%\' ) ';  //START/END UD-3080 Renino Niefes 2015-10-12 Exclude rejected cases in the main query
        query += ' ORDER BY ';
        query += '      Case__r.RecordType.DeveloperName, ';
        query += '      LastModifiedDate, ';
        query += '      Subscription__r.Zuora__Account__r.Account_Auto_Number__c, '; 
        query += '      Subscription__r.Recipient_Contact__r.Recipient_Number__c, '; 
        query += '      Subscription__r.Name, ';                                    
        query += '      Subscription__r.Product_Code__c ASC';                           
        //END 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
        
        return Database.getQueryLocator(query);     
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
        
        //START 26May2016 JC Aduan - call this method for test coverage purposes
        if(Test.isRunningTest()){
            mapProdPub = BT_CO_INT_Utilities.prodPubMapping();
        }
        //END

        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID); 
        
        List<BA_INT_DATA_FAILED_POOL__c> datapoolListFailed = new List<BA_INT_DATA_FAILED_POOL__c>();
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        Map<Decimal,String> errorMessageMap = BT_CO_INT_Utilities.getErrorMessageMap(Z_INTERFACE_ID);
        
        List<Id> caseIdList = new List<Id>();
        List<ID> lPackageIDs = new List<ID>();
    
        // START UD-2132 2015-08-14 Renino Niefes
        Map<String, String> mapProdCode2ProdFamily = new Map<String, String>();
        List<String> lstProdCodes = new List<String>();
        
        //prepare the mainPackageList and caseIdList
        for(sObject record : scope)
        {                       
            Case_Subscription__c csRecord = (Case_Subscription__c) record;
            String zRecordType = csRecord.Case__r.RecordType.DeveloperName;
            
        // Populate the 'Main Package' ID list ...
            ID mainPackageId = csRecord.Subscription__r.Main_Package_1__c;
            if (mainPackageId!=null) {
                lPackageIDs.add(mainPackageId);
            }
            if (isChangeOfSubscription(zRecordType)) {
                ID iOS_MainPackageID = csRecord.Case__r.Subscription_Name__r.Main_Package_1__c;
                if (iOS_MainPackageID != null) {
                    lPackageIDs.add(iOS_MainPackageID);
                }               
            }
            
            ID caseId = csRecord.Case__r.Id;
            if (caseId!=null) {
                caseIdList.add(caseId);
            }

            //START UD-2895 Renz 2015-09-22 Add the product code of the old subs as well. add nullity check too.
            if(csRecord.Subscription__r.Product_Code__c != null){
                String newSubsProdCode = csRecord.Subscription__r.Product_Code__c;
                if (newSubsProdCode!=null) {
                    lstProdCodes.add(newSubsProdCode);
                }
            }

            if (isChangeOfSubscription(zRecordType)) {
                String oldSubsProdCode = csRecord.Case__r.Subscription_Name__r.Product_Code__c;
                if (oldSubsProdCode != null) {
                    lstProdCodes.add(oldSubsProdCode);
                }               
            }
            //END UD-2895 Renz 2015-09-22 Add the product code of the old subs as well
        }

    // Create a map of product family
        List<zqu__ZProduct__c> zPrd = [select id, ProductCode__c, ProductFamily__c from   zqu__ZProduct__c where ProductCode__c in :lstProdCodes];
        for(zqu__ZProduct__c temp : zPrd){
            if(temp != null && temp.ProductFamily__c != null){
                mapProdCode2ProdFamily.put(temp.ProductCode__c, temp.ProductFamily__c);
            }
        }
    // END UD-2132 2015-08-14 Renino Niefes
        
      // Create a Map of Address Assignment Object
        Map<ID, Address_Assignment__c> caseAddressAssignmentMap = BT_CO_INT_Utilities.getAddressAssignmentMap(caseIdList);

        // Create a Map of Package IDs to a SET of Publications ...     
        Map<ID, Set<Publication__c>> mPackagePublications = new Map<ID, Set<Publication__c>>();
        if (lPackageIDs.size() > 0) {
            mPackagePublications = BT_CO_INT_Utilities.packageToPublication(lPackageIDs);           
        }
        
        // Iterate through and create the export data
        Set<String> exportDataSet = new Set<String>(); 
        for (sObject record : scope)
        {
            Case_Subscription__c csRecord = (Case_Subscription__c) record;
            
            ID zRecordId = csRecord.Id;
            ID zCaseId = csRecord.Case__r.ID;
            String zVALIDATION_CODE = '';  

            String zRecordType = csRecord.Case__r.RecordType.DeveloperName;
            String zSubRecordType = csRecord.Case__r.Change_of_Address_Type__c;
            if (zSubRecordType != null && zSubRecordType.equalsIgnoreCase(CHANGE_OF_VENDOR_TYPE)) {
                zRecordType = CHANGE_OF_VENDOR;
            }
            
            String zChgVendorGroup = csRecord.Case__r.Vendor__r.Vendor_Group__c;
            String zChgVendorCode = csRecord.Case__r.Vendor__r.Vendor_Code__c;
            
            boolean isChangeOfSubscription = isChangeOfSubscription(zRecordType);
            boolean isChangeOfVendor = isChangeOfVendor(zRecordType);
            boolean isChangeOfAddress = isChangeOfAddress(zRecordType);
            boolean isRenewalOfSubscription = isRenewalOfSubscription(zRecordType);
            
            Map<String, Object> mSubscriptionDataMap = getSubscriptionDataMap(csRecord, ZDATA_NEW_DATA);        
            
            ID zPackageID = (ID) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_MAIN_PACKAGE_ID);
            Date dtSubscriptionStartDate = (Date) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_START_DATE);
            Date dtSubscriptionEndDate = (Date) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_END_DATE);
            DateTime dtmSubscriptionLastModifiedDate = (DateTime) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_LAST_MODIFIED_DATE);
            String zCRSMContactNumber = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_CRSM_CONTACT_NUMBER);          
            Decimal dSubscriptionQty = (Decimal) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_QTY); 
            String zVendorGroup = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_VENDOR_GROUP);
            String zVendorCode = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_VENDOR_CODE);          
            String zHouseBlockNumber = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_BLK_H_NUMBER);    
            String zLevelNumber = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_LEVEL_NUMBER);  
            String zUnitNumber = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_UNIT_NUMBER); 
            String zPostalCode = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_POSTAL_CODE);   
            String zStreetName = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_STREET_NAME); 
            String zBuildingName = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_BLDG_NAME);   
            String zRecipientLegacyId = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_RECIPIENT_CONTACT_LEGACY_ID); 
            String zRecipientName = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_RECIPIENT_CONTACT_NAME); 
            String zProductCode = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_PRODUCT_CODE);                             
            String zSubscriptionStatus = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_Z_STATUS);             
            String zSubscriptionFrequency = (String) mSubscriptionDataMap.get(ZDATA_SUBSCRIPTION_FREQUENCY); 
            
            if (zChgVendorGroup == null) zChgVendorGroup = 'V';

            //START D-3914 Renino Niefes 2015-11-11 Get the attention to field from Contact object.  Note that Company_Name__c is the field for attention To
            //String zAttnToCareOf = csRecord.Account__r.Attention_To_Care_Of__c; 
            String zAttnToCareOf = csRecord.Case__r.Subscription_Name__r.Recipient_Contact__r.Company_Name__c;
            if (zAttnToCareOf == null) zAttnToCareOf = csRecord.Subscription__r.Recipient_Contact__r.Company_Name__c;
            //END D-3914 Renino Niefes 2015-11-11 Get the attention to field from Contact object
            
            String zCRSMAccountNumber = csRecord.Account__r.Account_Auto_Number__c;
            String zAccountLegacyId = csRecord.Account__r.Account_Legacy_Id__c;
            String zRestartDate = String.valueOf(csRecord.Case__r.Restart_Date__c);
            Date dtStopRequestDate = csRecord.Case__r.Stop_Request_Date__c;          
            Date dtEffectiveDate = csRecord.Case__r.Effective_Date__c;
            DateTime dtLastModifiedDate = csRecord.LastModifiedDate;            
            String zCrsmSubscriptionId = csRecord.Subscription__r.Name; //START/END  UD-2980 2015-10-01 Renino Niefes add Subscription ID

            String zTransactionDesc = null;
            String zTransactionType = null;
            Date zEffectiveDate = null;
            Date zEffectiveIssueDate = null;            
            
            //Set default values if null
            if (dSubscriptionQty == null) dSubscriptionQty = 0.0;
                                
            // Store Publication_Code__c, Published_Days__c, Public_Holiday_Weekday_Pub_Indicator and Public_Holiday_Weekend_Pub_Indicator__c values...
            String zPublishedDays = '';
            String zPublicationCode = '';
            String zPHeIndicator = INDICATOR_NO;
            String zPHdIndicator = INDICATOR_NO;
            String zSponsoredIndicator = null; 
            String zDeliveryFrequency = null;
            String zPattern = null;
            String zMon = '0';
            String zTue = '0';
            String zWed = '0';
            String zThu = '0';
            String zFri = '0';
            String zSat = '0';
            String zSun = '0';
            String zPHd = '0';
            String zPHe = '0';
            boolean zPublicHolidayWeekdayInd = false;
            boolean zPublicHolidayWeekendInd = false;
        
            // Get Change Of Address Assignment
            String zNewVendorCode = null;
            String zNewVendorGroup = null;
            String zNewHouseBlockNumber = null;
            String zNewLevel = null;
            String zNewUnitNumber = null;
            String zNewStreetName = null;
            String zNewBuildingName = null;
            String zNewPostalCode = null;
            Date dtNewEffectiveDate = null;
            
            Address_Assignment__c aRecord = null;

            if (!(isChangeOfSubscription || isRenewalOfSubscription)) {
                aRecord = (Address_Assignment__c) caseAddressAssignmentMap.get(zCaseId);
                if (aRecord != null) {
                    zNewHouseBlockNumber = aRecord.Address__r.Block_House_Number__c;
                    zNewLevel = aRecord.Address__r.Level_Number__c;
                    zNewUnitNumber = aRecord.Address__r.Unit_Number__c;
                    zNewStreetName = aRecord.Address__r.Street_Name__c;
                    zNewBuildingName = aRecord.Address__r.Building_Name__c;
                    zNewPostalCode = aRecord.Address__r.Postal_Code__r.Name;    
                    dtNewEffectiveDate = aRecord.Effective_Date__c;
                    zNewVendorCode = aRecord.Vendor__r.Vendor_Code__c;
                    zNewVendorGroup = aRecord.Vendor__r.Vendor_Group__c;
                    if (zNewVendorGroup == null) zNewVendorGroup = 'V';
                }               
            }
            
            if (mPackagePublications.containsKey(zPackageID)) {
                
                Set<Publication__c> publicationListData = new Set<Publication__c>();                
                if (mPackagePublications.get(zPackageID) != null) {
                    publicationListData = mPackagePublications.get(zPackageID);
                }                
                String prodCode = csRecord.Subscription__r.product_code__c; //START/End UD-2691 23-Sep-2015 Added by Raviteja
                System.debug('$%$ publicationListData1: ' + publicationListData);
                System.debug('$%$ prodCode: ' + prodCode);
                System.debug('$%$ mapProdPub: ' + mapProdPub);    
                publicationListData = BT_CO_INT_Utilities.prodPubMapping(publicationListData, prodCode, mapProdPub);//START/End UD-2691 23-Sep-2015 Added by Raviteja
                System.debug('$%$ publicationListData2: ' + publicationListData);
                for (Publication__c rec : publicationListData) { 
                    if (rec != null && rec.Product_Family__c == mapProdCode2ProdFamily.get(zProductCode)) {  //UD-2132 start/end  added conditions to filter out listdata
                        String zDayOfWeekPattern = null;
                        zSponsoredIndicator = rec.Free_Publication__c ? INDICATOR_YES:INDICATOR_NO;
                        zPublishedDays = StringUtility.getPublishedDays(zSubscriptionFrequency, rec.Published_Days__c); 
                        zPublicationCode = rec.Publication_Code__c;
                        zPublicHolidayWeekdayInd = rec.Public_Holiday_Weekday_Pub_Indicator__c;
                        zPublicHolidayWeekendInd = rec.Public_Holiday_Weekend_Pub_Indicator__c;
                        zPHdIndicator = (zPublicHolidayWeekdayInd) ? INDICATOR_YES : INDICATOR_NO;
                        zPHeIndicator = (zPublicHolidayWeekendInd) ? INDICATOR_YES : INDICATOR_NO;

                        if (String.isNotBlank(zPublishedDays)) {
                             Integer iQty = 0;
                             try {
                                  iQty = Integer.valueOf(String.valueOf(dSubscriptionQty));
                                  zDayOfWeekPattern = zPublishedDays + zPHdIndicator;     
                                  zPattern = zDayOfWeekPattern + zPHeIndicator;   
                             } catch (Exception e) {
                                  iQty = 0;
                                  zPattern = 'NNNNNNNNN';
                             }
                             zDeliveryFrequency = StringUtility.getCopies('DEFAULT', iQty, zPattern);
                             zMon = StringUtility.getCopies('DAY1', iQty, zPattern);
                             zTue = StringUtility.getCopies('DAY2', iQty, zPattern);
                             zWed = StringUtility.getCopies('DAY3', iQty, zPattern);
                             zThu = StringUtility.getCopies('DAY4', iQty, zPattern);
                             zFri = StringUtility.getCopies('DAY5', iQty, zPattern);
                             zSat = StringUtility.getCopies('DAY6', iQty, zPattern);
                             zSun = StringUtility.getCopies('DAY7', iQty, zPattern);
                             zPHd = StringUtility.getCopies('PHD', iQty, zPattern);
                             zPHe = StringUtility.getCopies('PHE', iQty, zPattern);
                        }
                                            
                        zEffectiveDate = (isChangeOfSubscription || isRenewalOfSubscription) ? dtSubscriptionStartDate : dtEffectiveDate;
                        Date dateFrom = zEffectiveDate;
                        Date dateTo = dtSubscriptionEndDate;
                        if (dateFrom==null) dateFrom = Date.Today();
                        if (dateTo==null) dateTo = DateUtility.convertDateFromYYYYMMDD(DEFAULT_END_DATE);
                        
                        //START UD-3634 2016-01-18 Renz Niefes  adding 7 days to subscription end date both applies to COA and COV
                        if (isChangeOfAddress||isChangeOfVendor) {
                            //add 7 days to dateTo
                            dateTo=dateTo.addDays(7); 
                            zEffectiveIssueDate = DateUtility.getFirstPublicationDate(dateFrom,dateTo,zPublishedDays);                
                        } else {
                            zEffectiveIssueDate = DateUtility.getFirstPublicationDate(dateFrom,dateTo,zPublishedDays);                
                        }
                        //END UD-3634 2016-01-18 Renz Niefes
                        
                        //Setting transaction type and description for first record
                        zTransactionType = (isChangeOfSubscription || isRenewalOfSubscription) ? TRANSACTION_TYPE_START : TRANSACTION_TYPE_STOP ;
                        zTransactionDesc = getTransactionDesc(zRecordType); 
                        
                        // Validate Data ...                        
                        zVALIDATION_CODE = StringUtility.validate(zVendorCode);                 // Check 'Vendor Code' Data
                        zVALIDATION_CODE += StringUtility.validate(zHouseBlockNumber);      // Check 'House/Block Number' Data ... 
                        zVALIDATION_CODE += StringUtility.validate(zPostalCode);                    // Check 'Postal Code' Data ...
                        zVALIDATION_CODE += StringUtility.validate(zDayOfWeekPattern);          // CHeck 'Day of Week Pattern' Data ...                     
                        zVALIDATION_CODE += StringUtility.validate(zRecipientName);             // Check 'Recipient Name' Data ...                      
                        zVALIDATION_CODE += StringUtility.validate(zCRSMAccountNumber);     // Check 'Account Number' Data ...
                        zVALIDATION_CODE += StringUtility.validate(zCRSMContactNumber);     // Check 'Recipient Number' Data ...                    
                        zVALIDATION_CODE += StringUtility.validate(zPublicationCode);       // Check 'Publication Code' Data ...                        
                        zVALIDATION_CODE += StringUtility.validate(zEffectiveDate);             // Check 'Effective Date' Data ...                                              
                        zVALIDATION_CODE += '0';//StringUtility.validate(zLevelNumber);             // Check 'Level Number' Data ...                        
                        zVALIDATION_CODE += '0';//StringUtility.validate(zUnitNumber);                  // Check 'Unit Number' Data ...                     
                        zVALIDATION_CODE += StringUtility.validate(zStreetName);                // Check 'Street Name' Data ...  
                        zVALIDATION_CODE += StringUtility.validate(zTransactionType);           // Check 'Transaction Type'
                        zVALIDATION_CODE += StringUtility.validate(zTransactionDesc);           // Check 'Transaction Desc' Data ... 
                        zVALIDATION_CODE += StringUtility.validate(zEffectiveIssueDate);        // Check The Indicator...                       
                        zVALIDATION_CODE += isChangeOfAddress ? StringUtility.validate(zNewHouseBlockNumber) : '0';     // Check NEW 'House/Block Number' Data ...
                        zVALIDATION_CODE += isChangeOfAddress ? StringUtility.validate(zNewLevel) : '0';                // Check NEW 'Level Number' Data ...
                        zVALIDATION_CODE += isChangeOfAddress ? StringUtility.validate(zNewUnitNumber) : '0';           // Check NEW 'Unit Number' Data ... 
                        zVALIDATION_CODE += isChangeOfAddress ? StringUtility.validate(zNewPostalCode) : '0';           // Check NEW 'Postal Code' Data ...
                        zVALIDATION_CODE += isChangeOfAddress ? StringUtility.validate(zNewStreetName) : '0';           // Check NEW 'Street Name' Data ...  
                        zVALIDATION_CODE += isChangeOfAddress ? StringUtility.validate(zNewVendorCode) : '0';           // Check NEW 'Vendor Code' Data ...  
                        zVALIDATION_CODE += isChangeOfVendor ? StringUtility.validate(zChgVendorCode) : '0';            // Check CHANGE Vendor Code ... 
                        
                        //Override zValidation Code to Pass.  Moving validation checks to on-premise server and save to FAI file
                        zVALIDATION_CODE = '000000000000000';
                        
                        // Create zData string ...
                        String zData = '';
                        zData += StringUtility.quoteReplaceStr(zVendorGroup) +',';                              // Customer Group (Vendor Group)
                        zData += StringUtility.quoteReplaceStr(zVendorCode) +',';                                   // Vendor Number 
                        zData += StringUtility.quoteReplaceStr(zTransactionType) +',';                              // Transaction Type 
                        zData += StringUtility.quoteReplaceStr(zTransactionDesc) +',';                              // Transaction Description 
                        zData += StringUtility.quoteReplaceStr(zHouseBlockNumber) +',';                             // Block Number
                        zData += StringUtility.quoteReplaceStr(zLevelNumber) +',';                                  // Level Number 
                        zData += StringUtility.quoteReplaceStr(zUnitNumber) +',';                                   // Unit Number 
                        zData += StringUtility.quoteReplaceStr(zPostalCode) +',';                                   // Postal Code 
                        zData += StringUtility.quoteReplaceStr(zStreetName) +',';                                   // Street Name 
                        zData += StringUtility.quoteReplaceStr(zBuildingName) +',';                                 // Building Name 
                        zData += StringUtility.quoteReplaceStr(zPublicationCode) +',';                              // Publication Code 
                        zData += StringUtility.quoteReplaceStr(String.valueOf(dSubscriptionQty)) +',';          // Subscription Copies
                        zData += StringUtility.quoteReplaceStr(String.valueOf(zEffectiveDate)) +',';                // Effective Date                         
                        zData += StringUtility.quoteReplaceStr(String.valueOf(zEffectiveIssueDate)) +',';       // Effective Issue                      
                        zData += StringUtility.quoteReplaceStr(zRestartDate) +',';                                  // Restart Date 
                        zData += StringUtility.quoteReplaceStr(zDeliveryFrequency) +',';                            // Delivery Frequency 
                        zData += StringUtility.quoteReplaceStr(zAccountLegacyId) +',';                              // Subscriber Account 
                        zData += StringUtility.quoteReplaceStr(zRecipientLegacyId) +',';                            // Recipient Account 
                        zData += StringUtility.quoteReplaceStr(zRecipientName) +',';                                // Recipient Name 
                        zData += StringUtility.quoteReplaceStr(zAttnToCareOf) +',';                                 // Recipient Attention To 
                        zData += 'null,';                                                               // Route Sys    ---> IGNORED FIELD
                        zData += 'null,';                                                               // Route Number ---> IGNORED FIELD
                        zData += 'null,';                                                               // Drop Point   ---> IGNORED FIELD
                        zData += 'null,';                                                               // User ID      ---> IGNORED FIELD
                        zData += StringUtility.quoteReplaceStr(zSponsoredIndicator) +',';                           // Sponsored Indicator
                        zData += StringUtility.quoteReplaceStr(zMon) +',';                                          // Day 1 Copy 
                        zData += StringUtility.quoteReplaceStr(zTue) +',';                                          // Day 2 Copy 
                        zData += StringUtility.quoteReplaceStr(zWed) +',';                                          // Day 3 Copy 
                        zData += StringUtility.quoteReplaceStr(zThu) +',';                                          // Day 4 Copy 
                        zData += StringUtility.quoteReplaceStr(zFri) +',';                                          // Day 5 Copy 
                        zData += StringUtility.quoteReplaceStr(zSat) +',';                                          // Day 6 Copy 
                        zData += StringUtility.quoteReplaceStr(zSun) +',';                                          // Day 7 Copy 
                        zData += StringUtility.quoteReplaceStr(zPHd) +',';                                          // PH Weekday Copy 
                        zData += StringUtility.quoteReplaceStr(zPHe) +',';                                          // PH Weekend Copy 
                        zData += StringUtility.quoteReplaceStr(zDayOfWeekPattern) +',';                             // Day of Week Pattern 
                        zData += StringUtility.quoteReplaceStr(zProductCode) +',';                                  // Product Code 
                        zData += StringUtility.quoteReplaceStr(zCRSMAccountNumber) +',';                            // CRSM Account ID
                        zData += StringUtility.quoteReplaceStr(zCRSMContactNumber) +',';                            // CRSM Contact ID
                        zData += StringUtility.quoteReplaceStr(zPHeIndicator) +',';                                 // Day of week pattern (PHe)
                        zData += StringUtility.quoteReplaceStr(zCrsmSubscriptionId) + ',';                          // START/END  UD-2980 2015-10-01 Renino Niefes add Subscription ID
                    
                        
                        //Duplicate Record for tempstops (one for stop (above) and another one for restart (below))
                        String zData2 = '';
                        if (!(isChangeOfSubscription || isRenewalOfSubscription)) {
                            String zParseVendorGroup = isChangeOfVendor ? zChgVendorGroup : (isChangeOfAddress ? zNewVendorGroup : zVendorGroup);
                            String zParseVendorCode = isChangeOfVendor ? zChgVendorCode : (isChangeOfAddress ? zNewVendorCode : zVendorCode);
                            
                            zData2 += StringUtility.quoteReplaceStr(zParseVendorGroup) +',';                                                                // Customer Group (Vendor Group)
                            zData2 += StringUtility.quoteReplaceStr(zParseVendorCode) +',';                                                                 // Vendor Number 
                            zData2 += StringUtility.quoteReplaceStr(TRANSACTION_TYPE_START) +',';                                                   // Transaction Type 
                            zData2 += StringUtility.quoteReplaceStr(zTransactionDesc) +',';                                                         // Transaction Description 
                            zData2 += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewHouseBlockNumber : zHouseBlockNumber) +',';     // Block Number
                            zData2 += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewLevel : zLevelNumber) +',';                    // Level Number 
                            zData2 += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewUnitNumber : zUnitNumber) +',';                // Unit Number 
                            zData2 += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewPostalCode : zPostalCode) +',';                // Postal Code 
                            zData2 += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewStreetName : zStreetName) +',';                // Street Name 
                            zData2 += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewBuildingName : zBuildingName) +',';            // Building Name 
                            zData2 += StringUtility.quoteReplaceStr(zPublicationCode) +',';                                                         // Publication Code 
                            zData2 += StringUtility.quoteReplaceStr(String.valueOf(dSubscriptionQty)) +',';                                         // Subscription Copies
                            zData2 += StringUtility.quoteReplaceStr(String.valueOf(isChangeOfVendor ? zEffectiveDate : dtNewEffectiveDate)) +',';                                       // Effective Date                         
                            zData2 += StringUtility.quoteReplaceStr(String.valueOf(zEffectiveIssueDate)) +',';                                      // Effective Issue                      
                            zData2 += StringUtility.quoteReplaceStr(zRestartDate) +',';                                                             // Restart Date 
                            zData2 += StringUtility.quoteReplaceStr(zDeliveryFrequency) +',';                                                       // Delivery Frequency 
                            zData2 += StringUtility.quoteReplaceStr(zAccountLegacyId) +',';                                                         // Subscriber Account 
                            zData2 += StringUtility.quoteReplaceStr(zRecipientLegacyId) +',';                                                       // Recipient Account 
                            zData2 += StringUtility.quoteReplaceStr(zRecipientName) +',';                                                           // Recipient Name 
                            zData2 += StringUtility.quoteReplaceStr(zAttnToCareOf) +',';                                                            // Recipient Attention To 
                            zData2 += 'null,';                                          // Route Sys    ---> IGNORED FIELD
                            zData2 += 'null,';                                          // Route Number ---> IGNORED FIELD
                            zData2 += 'null,';                                          // Drop Point   ---> IGNORED FIELD
                            zData2 += 'null,';                                          // User ID      ---> IGNORED FIELD
                            zData2 += StringUtility.quoteReplaceStr(zSponsoredIndicator) +',';                                                      // Sponsored Indicator
                            zData2 += StringUtility.quoteReplaceStr(zMon) +',';                                                                     // Day 1 Copy 
                            zData2 += StringUtility.quoteReplaceStr(zTue) +',';                                                                     // Day 2 Copy 
                            zData2 += StringUtility.quoteReplaceStr(zWed) +',';                                                                     // Day 3 Copy 
                            zData2 += StringUtility.quoteReplaceStr(zThu) +',';                                                                     // Day 4 Copy 
                            zData2 += StringUtility.quoteReplaceStr(zFri) +',';                                                                     // Day 5 Copy 
                            zData2 += StringUtility.quoteReplaceStr(zSat) +',';                                                                     // Day 6 Copy 
                            zData2 += StringUtility.quoteReplaceStr(zSun) +',';                                                                     // Day 7 Copy 
                            zData2 += StringUtility.quoteReplaceStr(zPHd) +',';                                                                     // PH Weekday Copy 
                            zData2 += StringUtility.quoteReplaceStr(zPHe) +',';                                                                     // PH Weekend Copy 
                            zData2 += StringUtility.quoteReplaceStr(zDayOfWeekPattern) +',';                                                        // Day of Week Pattern 
                            zData2 += StringUtility.quoteReplaceStr(zProductCode) +',';                                                             // Product Code 
                            zData2 += StringUtility.quoteReplaceStr(zCRSMAccountNumber) +',';                                                       // CRSM Account ID
                            zData2 += StringUtility.quoteReplaceStr(zCRSMContactNumber) +',';                                                       // CRSM Contact ID
                            zData2 += StringUtility.quoteReplaceStr(zPHeIndicator) +',';                                                            // Day of week pattern (PHe)                            
                            zData2 += StringUtility.quoteReplaceStr(zCrsmSubscriptionId) + ',';                                                     // START/END  UD-2980 2015-10-01 Renino Niefes add Subscription ID
                        }
                    
                        if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE) ) {
                            if (!exportDataSet.contains(zData) && String.isNotBlank(zData)) {
                                datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', zRecordId, zData, dtLastModifiedDate, datapoolList);
                                if (!(isChangeOfSubscription || isRenewalOfSubscription)) {
                                    datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', zRecordId, zData2, dtLastModifiedDate, datapoolList);                                   
                                }
                                exportDataSet.add(zData);                               
                            }
                        } else {
                            //Create a debug log / Interpret Validation String / Insert to Failed Pool
                            BT_CO_INT_Utilities.log(zData,zRecordId);
                            String zErrorMsg = '('+zRecordType+')'+BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, errorMessageMap);
                            datapoolListFailed = BT_CO_INT_Utilities.exportFailedDataItem(Z_INTERFACE_ID, 'Detail', zRecordId, 
                            zErrorMsg, zVALIDATION_CODE, zData, DateTime.now(), datapoolListFailed);
                        }                       
                        zVALIDATION_CODE = '';
                    }
                }               
            }
            
            if (isChangeOfSubscription) {
                Map<String, Object> mOldSubscriptionData = getSubscriptionDataMap(csRecord, ZDATA_OLD_DATA);
                ID zOldPackageID = (ID) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_MAIN_PACKAGE_ID);
                Date dtOldSubscriptionStartDate = (Date) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_START_DATE);
                Date dtOldSubscriptionEndDate = (Date) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_END_DATE);
                DateTime dtmOldSubscriptionLastModifiedDate = (DateTime) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_LAST_MODIFIED_DATE);
                String zOldCRSMContactNumber = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_CRSM_CONTACT_NUMBER);           
                Decimal dOldSubscriptionQty = (Decimal) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_QTY); 
                String zOldVendorGroup = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_VENDOR_GROUP);
                String zOldVendorCode = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_VENDOR_CODE);          
                String zOldHouseBlockNumber = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_BLK_H_NUMBER);    
                String zOldLevelNumber = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_LEVEL_NUMBER);  
                String zOldUnitNumber = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_UNIT_NUMBER); 
                String zOldPostalCode = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_POSTAL_CODE);   
                String zOldStreetName = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_STREET_NAME); 
                String zOldBuildingName = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_BLDG_NAME);   
                String zOldRecipientLegacyId = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_RECIPIENT_CONTACT_LEGACY_ID); 
                String zOldRecipientName = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_RECIPIENT_CONTACT_NAME); 
                String zOldProductCode = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_PRODUCT_CODE);                             
                String zOldSubscriptionStatus = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_Z_STATUS);             
                String zOldSubscriptionFrequency = (String) mOldSubscriptionData.get(ZDATA_SUBSCRIPTION_FREQUENCY); 
                String zOldCrsmSubscriptionId = csRecord.Case__r.Subscription_Name__r.Name;  //START/END UD-3077 Renino Niefes 2015-10-12 Use the old subscription Ids for COS scenario
                
                if (mPackagePublications.containsKey(zOldPackageID)) {
                    Set<Publication__c> oldPublicationDataSet = new Set<Publication__c>();
                    if (mPackagePublications.get(zOldPackageID) != null) {
                        oldPublicationDataSet = mPackagePublications.get(zOldPackageID);
                    } 
                    zVALIDATION_CODE = '';
                    for (Publication__c pCaseRecord : oldPublicationDataSet) { 
                        if (pCaseRecord != null && pCaseRecord.Product_Family__c == mapProdCode2ProdFamily.get(zOldProductCode)) {  //UD-2132 start/end  added conditions to filter out listdata
                            String zDayOfWeekPattern = null;
                            zSponsoredIndicator = pCaseRecord.Free_Publication__c ? INDICATOR_YES:INDICATOR_NO;
                            zPublishedDays = StringUtility.getPublishedDays(zOldSubscriptionFrequency, pCaseRecord.Published_Days__c); 
                            zPublicationCode = pCaseRecord.Publication_Code__c;
                            zPublicHolidayWeekdayInd = pCaseRecord.Public_Holiday_Weekday_Pub_Indicator__c;
                            zPublicHolidayWeekendInd = pCaseRecord.Public_Holiday_Weekend_Pub_Indicator__c;
                            zPHdIndicator = (zPublicHolidayWeekdayInd) ? INDICATOR_YES : INDICATOR_NO;
                            zPHeIndicator = (zPublicHolidayWeekendInd) ? INDICATOR_YES : INDICATOR_NO;

                            
                            if (String.isNotBlank(zPublishedDays)) {
                                 Integer iQty = 0;
                                 try {
                                      iQty = Integer.valueOf(String.valueOf(dOldSubscriptionQty));
                                      zDayOfWeekPattern = zPublishedDays + zPHdIndicator;     
                                      zPattern = zDayOfWeekPattern + zPHeIndicator;   
                                 } catch (Exception e) {
                                      iQty = 0;
                                      zPattern = 'NNNNNNNNN';
                                 }
                                 zDeliveryFrequency = StringUtility.getCopies('DEFAULT', iQty, zPattern);
                                 zMon = StringUtility.getCopies('DAY1', iQty, zPattern);
                                 zTue = StringUtility.getCopies('DAY2', iQty, zPattern);
                                 zWed = StringUtility.getCopies('DAY3', iQty, zPattern);
                                 zThu = StringUtility.getCopies('DAY4', iQty, zPattern);
                                 zFri = StringUtility.getCopies('DAY5', iQty, zPattern);
                                 zSat = StringUtility.getCopies('DAY6', iQty, zPattern);
                                 zSun = StringUtility.getCopies('DAY7', iQty, zPattern);
                                 zPHd = StringUtility.getCopies('PHD', iQty, zPattern);
                                 zPHe = StringUtility.getCopies('PHE', iQty, zPattern);
                            }
                            
                            zEffectiveDate = (dtEffectiveDate != null) ? dtEffectiveDate : (dtOldSubscriptionEndDate != null) ? dtOldSubscriptionEndDate : Date.valueOf(brd).addDays(1);
                            Date dateFrom = zEffectiveDate;
                            Date dateTo = DateUtility.convertDateFromYYYYMMDD(DEFAULT_END_DATE);
                            dateFrom = (dateFrom != null) ? dateFrom : Date.Today();                                
                            dateTo = (dateTo != null) ? dateTo : DateUtility.convertDateFromYYYYMMDD(DEFAULT_END_DATE);
                            zEffectiveIssueDate = DateUtility.getFirstPublicationDate(dateFrom,dateTo,zPattern);                
                        
                            // Validate Data ...             
                            zVALIDATION_CODE = StringUtility.validate(zOldVendorCode);                  // Check 'Vendor Code' Data
                            zVALIDATION_CODE += StringUtility.validate(zOldHouseBlockNumber);       // Check 'House/Block Number' Data ... 
                            zVALIDATION_CODE += StringUtility.validate(zOldPostalCode);                 // Check 'Postal Code' Data ...
                            zVALIDATION_CODE += StringUtility.validate(zDayOfWeekPattern);          // CHeck 'Day of Week Pattern' Data ...                     
                            zVALIDATION_CODE += StringUtility.validate(zRecipientName);             // Check 'Recipient Name' Data ...                      
                            zVALIDATION_CODE += StringUtility.validate(zCRSMAccountNumber);     // Check 'Account Number' Data ...
                            zVALIDATION_CODE += StringUtility.validate(zOldCRSMContactNumber);      // Check 'Recipient Number' Data ...                    
                            zVALIDATION_CODE += StringUtility.validate(zPublicationCode);       // Check 'Publication Code' Data ...                        
                            zVALIDATION_CODE += StringUtility.validate(zEffectiveDate);             // Check 'Effective Date' Data ...                                              
                            zVALIDATION_CODE += '0';//StringUtility.validate(zLevelNumber);             // Check 'Level Number' Data ...                        
                            zVALIDATION_CODE += '0';//StringUtility.validate(zUnitNumber);                  // Check 'Unit Number' Data ...                     
                            zVALIDATION_CODE += StringUtility.validate(zOldStreetName);             // Check 'Street Name' Data ...  
                            zVALIDATION_CODE += StringUtility.validate(zTransactionType);           // Check 'Transaction Type'
                            zVALIDATION_CODE += StringUtility.validate(zTransactionDesc);           // Check 'Transaction Desc' Data ... 
                            zVALIDATION_CODE += StringUtility.validate(zEffectiveIssueDate);        // Check The Indicator...                       
                            zVALIDATION_CODE += '0';    // Check NEW 'House/Block Number' Data ...
                            zVALIDATION_CODE += '0';    // Check NEW 'Level Number' Data ...
                            zVALIDATION_CODE += '0';    // Check NEW 'Unit Number' Data ... 
                            zVALIDATION_CODE += '0';    // Check NEW 'Postal Code' Data ...
                            zVALIDATION_CODE += '0';    // Check NEW 'Street Name' Data ...  
                            zVALIDATION_CODE += '0';    // Check NEW 'Vendor Code' Data ...  
                            zVALIDATION_CODE += '0';    // Check CHANGE Vendor Code ...                 

                            //Override zValidation Code to Pass.  Moving validation checks to on-premise server and save to FAI file
                            zVALIDATION_CODE = '0000000000000000000000';
                        
                            // Create zData string ...
                            String zData = '';
                            zData += StringUtility.quoteReplaceStr(zOldVendorGroup) +',';                       // Customer Group (Vendor Group)
                            zData += StringUtility.quoteReplaceStr(zOldVendorCode) +',';                        // Vendor Number 
                            zData += StringUtility.quoteReplaceStr(TRANSACTION_TYPE_STOP) +',';                 // Transaction Type 
                            zData += StringUtility.quoteReplaceStr(zTransactionDesc) +',';                          // Transaction Description 
                            zData += StringUtility.quoteReplaceStr(zOldHouseBlockNumber) +',';                  // Block Number
                            zData += StringUtility.quoteReplaceStr(zOldLevelNumber) +',';                       // Level Number 
                            zData += StringUtility.quoteReplaceStr(zOldUnitNumber) +',';                        // Unit Number 
                            zData += StringUtility.quoteReplaceStr(zOldPostalCode) +',';                        // Postal Code 
                            zData += StringUtility.quoteReplaceStr(zOldStreetName) +',';                        // Street Name 
                            zData += StringUtility.quoteReplaceStr(zOldBuildingName) +',';                      // Building Name 
                            zData += StringUtility.quoteReplaceStr(zPublicationCode) +',';                          // Publication Code 
                            zData += StringUtility.quoteReplaceStr(String.valueOf(dOldSubscriptionQty)) +',';   // Subscription Copies
                            zData += StringUtility.quoteReplaceStr(String.valueOf(zEffectiveDate)) +',';        // Effective Date                         
                            zData += StringUtility.quoteReplaceStr(String.valueOf(zEffectiveIssueDate)) +',';   // Effective Issue                      
                            zData += StringUtility.quoteReplaceStr(null) +',';                                      // Restart Date 
                            zData += StringUtility.quoteReplaceStr(zDeliveryFrequency) +',';                        // Delivery Frequency 
                            zData += StringUtility.quoteReplaceStr(zAccountLegacyId) +',';                          // Subscriber Account 
                            zData += StringUtility.quoteReplaceStr(zOldRecipientLegacyId) +',';                 // Recipient Account 
                            zData += StringUtility.quoteReplaceStr(zOldRecipientName) +',';                     // Recipient Name 
                            zData += StringUtility.quoteReplaceStr(zAttnToCareOf) +',';                             // Recipient Attention To 
                            zData += 'null,';   // Route Sys    ---> IGNORED FIELD
                            zData += 'null,';   // Route Number ---> IGNORED FIELD
                            zData += 'null,';   // Drop Point   ---> IGNORED FIELD
                            zData += 'null,';   // User ID      ---> IGNORED FIELD
                            zData += StringUtility.quoteReplaceStr(zSponsoredIndicator) +',';                   // Sponsored Indicator
                            zData += StringUtility.quoteReplaceStr(zMon) +',';                                  // Day 1 Copy 
                            zData += StringUtility.quoteReplaceStr(zTue) +',';                                  // Day 2 Copy 
                            zData += StringUtility.quoteReplaceStr(zWed) +',';                                  // Day 3 Copy 
                            zData += StringUtility.quoteReplaceStr(zThu) +',';                                  // Day 4 Copy 
                            zData += StringUtility.quoteReplaceStr(zFri) +',';                                  // Day 5 Copy 
                            zData += StringUtility.quoteReplaceStr(zSat) +',';                                  // Day 6 Copy 
                            zData += StringUtility.quoteReplaceStr(zSun) +',';                                  // Day 7 Copy 
                            zData += StringUtility.quoteReplaceStr(zPHd) +',';                                  // PH Weekday Copy 
                            zData += StringUtility.quoteReplaceStr(zPHe) +',';                                  // PH Weekend Copy 
                            zData += StringUtility.quoteReplaceStr(zDayOfWeekPattern) +',';                     // Day of Week Pattern 
                            zData += StringUtility.quoteReplaceStr(zOldProductCode) +',';                   // Product Code 
                            zData += StringUtility.quoteReplaceStr(zCRSMAccountNumber) +',';                    // CRSM Account ID
                            zData += StringUtility.quoteReplaceStr(zOldCRSMContactNumber) +',';             // CRSM Contact ID
                            zData += StringUtility.quoteReplaceStr(zPHeIndicator) +',';                         // Day of week pattern (PHe)
                            //START UD-3077 Renino Niefes 2015-10-12 Use the old subscription Ids for COS scenario.  If blank use null.
                            if (zOldCrsmSubscriptionId!=null) {
                                zData += StringUtility.quoteReplaceStr(zOldCrsmSubscriptionId) + ',';                   // START/END  UD-2980 2015-10-01 Renino Niefes add Subscription ID
                            } else {
                                zData += null + ',';
                            }
                            //END UD-3077 Renino Niefes 2015-10-12 
                        
                            if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE)) {
                                if (!exportDataSet.contains(zData) && String.isNotBlank(zData)) {
                                    //START UD-2599 2015-10-08 Renino Niefes  Check if the Old Subscription's start date is greater than or equal to end date.  If it is, reject that record
                                    //Note that the code is adding 1 day for End date that's why the criteria is greater than or equal to.
                                    if (dtOldSubscriptionEndDate==null||dtOldSubscriptionEndDate>dtOldSubscriptionStartDate) {
                                        datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', zRecordId, zData, dtLastModifiedDate, datapoolList);
                                        exportDataSet.add(zData);
                                    } else {
                                        BT_CO_INT_Utilities.log(zData,zRecordId);
                                        String zErrorMsg = '('+zRecordType+') Subscription start date is greater than end date';
                                        datapoolListFailed = BT_CO_INT_Utilities.exportFailedDataItem(Z_INTERFACE_ID, 'Detail', zRecordId, 
                                        zErrorMsg, '1', zData, DateTime.now(), datapoolListFailed); 
                                    }
                                    //START UD-2599 2015-10-08 Renino Niefes
                                }
                            } else {
                                //Create a debug log / Interpret Validation String / Insert to Failed Pool
                                BT_CO_INT_Utilities.log(zData,zRecordId);
                                String zErrorMsg = '('+zRecordType+')'+BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, errorMessageMap);
                                datapoolListFailed = BT_CO_INT_Utilities.exportFailedDataItem(Z_INTERFACE_ID, 'Detail', zRecordId, 
                                zErrorMsg, zVALIDATION_CODE, zData, DateTime.now(), datapoolListFailed);
                            }                       
                            zVALIDATION_CODE = '';
                        }
                    }
                }                   
            }
        }
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
            insert datapoolListFailed;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            BT_CO_INT_Utilities.log('BT_AB_HDS038DX_DailyStartStopActionFile insert operation failed.' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //Send callout
        BT_CO_INT_Utilities.sendCallOutMessage(Z_INTERFACE_ID);

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(Z_INTERFACE_ID);
        
    }
    
    private Map<String, Object> getSubscriptionDataMap (Case_Subscription__c csRecord, Integer iMode) {
        Map<String, Object> mZSubscriptionDataMap = new Map<String, Object>();
        
        if (csRecord != null) {
            String zRecordType = csRecord.Case__r.RecordType.DeveloperName;
            boolean isChangeOfSubscription = isChangeOfSubscription(zRecordType);
            
            ID zCasePackageID = null;   
            Date dtCaseSubscriptionStartDate = null;
            Date dtCaseSubscriptionEndDate = null;
            DateTime dtmCaseSubscriptionLastModifiedDate = null;
            Decimal dCaseCRSMContactNumber = null;
            Decimal dCaseSubscriptionQty = null;        
            String zCaseVendorGroup = null;
            String zCaseVendorCode = null;            
            String zCaseHouseBlockNumber = null;
            String zCaseLevelNumber = null;   
            String zCaseUnitNumber = null;   
            String zCasePostalCode = null;   
            String zCaseStreetName = null;
            String zCaseBuildingName = null;   
            String zCaseRecipientLegacyId = null;
            String zCaseRecipientName = null;
            String zCaseProductCode = null;                            
            String zCaseSubscriptionStatus = null;            
            String zCaseSubscriptionFrequency = null;
            String zCaseCRSMContactNumber = null;           

            zCasePackageID = csRecord.Subscription__r.Main_Package_1__c;
            dtCaseSubscriptionStartDate = csRecord.Subscription__r.Zuora__SubscriptionStartDate__c;
            dtCaseSubscriptionEndDate = csRecord.Subscription__r.Zuora__SubscriptionEndDate__c;
            dtmCaseSubscriptionLastModifiedDate = csRecord.Subscription__r.LastModifiedDate;
            dCaseCRSMContactNumber = csRecord.Subscription__r.Recipient_Contact__r.Recipient_Number__c;
            dCaseSubscriptionQty = csRecord.Subscription__r.Qty__c;     
            zCaseVendorGroup = csRecord.Subscription__r.Vendor_1__r.Vendor_Group__c;
            zCaseVendorCode = csRecord.Subscription__r.Vendor_1__r.Vendor_Code__c;    

            //START UD-2536 Renino Niefes 2015-09-25 Get the old address from Case__r.Address__c.  If it doesn't exist, use the old code
            if (csRecord.Address__r.Id!=null) {
                zCaseHouseBlockNumber = csRecord.Address__r.Block_House_Number__c;
                zCaseLevelNumber = csRecord.Address__r.Level_Number__c;   
                zCaseUnitNumber = csRecord.Address__r.Unit_Number__c;   
                zCasePostalCode = csRecord.Address__r.Postal_Code__r.Name;   
                zCaseStreetName = csRecord.Address__r.Street_Name__c;
                zCaseBuildingName = csRecord.Address__r.Building_Name__c;           
            } else {
                zCaseHouseBlockNumber = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c;
                zCaseLevelNumber = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c;   
                zCaseUnitNumber = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c;   
                zCasePostalCode = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name;   
                zCaseStreetName = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c;
                zCaseBuildingName = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c;   
            }
            //END UD-2536 Renino Niefes 2015-09-25
            
            zCaseRecipientLegacyId = csRecord.Subscription__r.Recipient_Contact__r.Contact_Legacy_Id__c;
            zCaseRecipientName = csRecord.Subscription__r.Recipient_Contact__r.Name;
            zCaseProductCode = csRecord.Subscription__r.Product_Code__c;                            
            zCaseSubscriptionStatus = csRecord.Subscription__r.Zuora__Status__c;            
            zCaseSubscriptionFrequency = csRecord.Subscription__r.Frequency__c;                                 
            
            if (isChangeOfSubscription && iMode == ZDATA_OLD_DATA) {
                zCasePackageID = csRecord.Case__r.Subscription_Name__r.Main_Package_1__c;   
                dtCaseSubscriptionStartDate = csRecord.Case__r.Subscription_Name__r.Zuora__SubscriptionStartDate__c;
                dtCaseSubscriptionEndDate = csRecord.Case__r.Subscription_Name__r.Zuora__SubscriptionEndDate__c;
                dtmCaseSubscriptionLastModifiedDate = csRecord.Case__r.Subscription_Name__r.LastModifiedDate;
                dCaseCRSMContactNumber = csRecord.Case__r.Subscription_Name__r.Recipient_Contact__r.Recipient_Number__c;
                dCaseSubscriptionQty = csRecord.Case__r.Subscription_Name__r.Qty__c;            
                zCaseVendorGroup = csRecord.Case__r.Subscription_Name__r.Vendor_1__r.Vendor_Group__c;
                zCaseVendorCode = csRecord.Case__r.Subscription_Name__r.Vendor_1__r.Vendor_Code__c;            
                zCaseHouseBlockNumber = csRecord.Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Block_House_Number__c;
                zCaseLevelNumber = csRecord.Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Level_Number__c;   
                zCaseUnitNumber = csRecord.Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Unit_Number__c;   
                zCasePostalCode = csRecord.Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name;   
                zCaseStreetName = csRecord.Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Street_Name__c;
                zCaseBuildingName = csRecord.Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Building_Name__c;   
                zCaseRecipientLegacyId = csRecord.Case__r.Subscription_Name__r.Recipient_Contact__r.Contact_Legacy_Id__c;
                zCaseRecipientName = csRecord.Case__r.Subscription_Name__r.Recipient_Contact__r.Name;
                zCaseProductCode = csRecord.Case__r.Subscription_Name__r.Product_Code__c;                            
                zCaseSubscriptionStatus = csRecord.Case__r.Subscription_Name__r.Zuora__Status__c;            
                zCaseSubscriptionFrequency = csRecord.Case__r.Subscription_Name__r.Frequency__c;                    
            }
            
            dtCaseSubscriptionEndDate = dtCaseSubscriptionEndDate != null ? dtCaseSubscriptionEndDate.addDays(1) : dtCaseSubscriptionEndDate;
            
            dCaseSubscriptionQty = (dCaseSubscriptionQty == null) ? 0.0 : dCaseSubscriptionQty;
            zCaseCRSMContactNumber = String.valueOf((dCaseCRSMContactNumber != null) ? dCaseCRSMContactNumber.toPlainString() : 'null');                                    
            zCaseVendorGroup = (String.isNotBlank(zCaseVendorGroup)) ? zCaseVendorGroup : 'V';
            
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_MAIN_PACKAGE_ID, zCasePackageID);  
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_START_DATE, dtCaseSubscriptionStartDate);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_END_DATE, dtCaseSubscriptionEndDate);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_LAST_MODIFIED_DATE, dtmCaseSubscriptionLastModifiedDate);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_LAST_MODIFIED_DATE, dtmCaseSubscriptionLastModifiedDate);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_CRSM_CONTACT_NUMBER, zCaseCRSMContactNumber);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_QTY, dCaseSubscriptionQty);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_VENDOR_GROUP, zCaseVendorGroup);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_VENDOR_CODE, zCaseVendorCode);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_BLK_H_NUMBER, zCaseHouseBlockNumber);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_LEVEL_NUMBER, zCaseLevelNumber);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_UNIT_NUMBER, zCaseUnitNumber);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_POSTAL_CODE, zCasePostalCode);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_STREET_NAME, zCaseStreetName);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_BLDG_NAME, zCaseBuildingName);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_RECIPIENT_CONTACT_LEGACY_ID, zCaseRecipientLegacyId);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_RECIPIENT_CONTACT_NAME, zCaseRecipientName);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_PRODUCT_CODE, zCaseProductCode);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_Z_STATUS, zCaseSubscriptionStatus);
            mZSubscriptionDataMap.put(ZDATA_SUBSCRIPTION_FREQUENCY, zCaseSubscriptionFrequency);
        }
        return mZSubscriptionDataMap;
    }
     
    private boolean isChangeOfSubscription(String zRecordType) {
        return (zRecordType != null && zRecordType.trim().equalsIgnoreCase(CHANGE_OF_SUBSCRIPTION));
    }

    private boolean isRenewalOfSubscription(String zRecordType) {
        return (zRecordType != null && zRecordType.trim().equalsIgnoreCase(RENEWAL_OF_SUBSCRIPTION));       
    }
    
    private boolean isChangeOfAddress(String zRecordType) {
        return (zRecordType != null && zRecordType.trim().equalsIgnoreCase(CHANGE_OF_ADDRESS));
    }   
    
    private boolean isChangeOfVendor(String zRecordType) {
        return (zRecordType != null && zRecordType.trim().equalsIgnoreCase(CHANGE_OF_VENDOR));
    }   

    private String getTransactionDesc(String zRecordType) {
        String zResult = TRANSACTION_DESC_COA;
        if (zRecordType != null) {
            if (zRecordType.trim().equalsIgnoreCase(CHANGE_OF_VENDOR)) {
                zResult = CHANGE_OF_VENDOR_TYPE;             
            } else if (zRecordType.trim().equalsIgnoreCase(CHANGE_OF_SUBSCRIPTION)) { 
                zResult = TRANSACTION_DESC_COS;
            } else if (zRecordType.trim().equalsIgnoreCase(RENEWAL_OF_SUBSCRIPTION)) {
                zResult = TRANSACTION_DESC_ROS;             
            }
        } 
        return zResult;
    }
}