/*
 * Class Name: BT_AB_HDS038DX_TempStop
 * @author: Renino Niefes
 * Date: 2015/05/20
 * Project/Requirement: SPH Integration - HDS038DX Interface
 * @description For Temp Stop Transactions only
 * 
 * History:
 *     2015/05/20 Renino Niefes Created Skeletal Apex Batchable
 *     2015/07/31 Renino Niefes             - Hot Fix: Override zValidation Code to Pass.  Moving validation checks to on-premise server and save to FAI file 
 *     2015/08/14 Renino Niefes                 UD-2132 Add another condition when creating export data.  Use Product family to match the current record.  If it matches, then create a new record
 *     2015/08/24 Kevin Evasco                  UD-2048 Hot Fix: Include cases closed after effective date to the output file
 *     2015/09/23 Raviteja Kumar                UD-2691 Added Database.Stateful
 *     2015/10/01 Renino Niefes                 UD-2980 add Subscription ID
 *     2015/10/08 Renino Niefes                 UD-2599 Hot Fixed.  If the subscription has COA that's effective tomorrow, use the new address from Address_Assignment__c instead. 
 *     2015/10/12 Renino Niefes                 UD-3080 Hotfix in UAT2, exclude cases with sub_status__c like '%rejected%' 
 *     2015-10-12 Renino Niefes                 UD-3078 Hotfix in UAT2, for start Temp stop, check if the publication is within stop request date and restart date.  If it is not, then exclude in the file.
 *     2015/11/11 Renino Niefes                 D-3914 Company_Name__c is the new field for "Attention To" parameter
 *     2016/01/28 Renino Niefes                 UD-3848 Add only vendor delivered subscriptions for direct subscribers 
 */

//START UD-2691 23-Sep-2015 Added by Raviteja  - Added Database.Stateful
//global class BT_AB_HDS038DX_TempStop implements Database.Batchable<sObject>,Database.AllowsCallouts
global class BT_AB_HDS038DX_TempStop implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful
//End UD-2691 23-Sep-2015 Added by Raviteja
{
    // SOQL Query in getting the interface primary object
    global final String Z_INTERFACE_ID = 'HDS038DX';
    global final String CASE_TEMP_STOP_TYPE_NEW = 'New';
    global final String CASE_TEMP_STOP_TYPE_CREATE = 'Create';
    global final String CASE_TEMP_STOP_TYPE_CANCELLED = 'Cancel';
    global final String CASE_TEMP_STOP_TYPE_UPDATE = 'Update';

    global final String CASE_SUB_STATUS_TSTOP_REJECTED = 'Temp Stop Rejected';
    global final String CHANGE_OF_ADDRESS = 'Change_of_Address';

    global final String TSTOP_SUBSCRIPTION = 'Temp_Stop_Subscription';
    global final String CASE_STATUS_CLOSED = 'Closed';
    global final String DEFAULT_END_DATE = '20991231';
    global final String INDICATOR_YES = 'Y';
    global final String INDICATOR_NO = 'N';

    global final String TRANSACTION_TYPE_START = 'Start';
    global final String TRANSACTION_TYPE_STOP = 'Stop';

    global final String TRANSACTION_DESC_TEMPSTOP = 'Temp Stop';

    global static final String ERROR_CODE_ZDATA_FAILURE = '1921';
    global static final String ERROR_CODE_EXCEPTION = '1311';
    global static final String ERROR_CODE_NONPUB = '1701';
    global Map<String, Set<String>> mapProdPub = new Map<String, Set<String>>(); //START/End UD-2691 23-Sep-2015 Added by Raviteja
    global Database.QueryLocator start(Database.BatchableContext BC)
    {        
        //prepare the status set applicable to this interface
        Set<String> caseStatusSet = new Set<String>();
        caseStatusSet.add(CASE_STATUS_CLOSED);

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
        query += '    Case__r.Id, ';
        query += '    Case__r.Restart_Date__c, ';
        query += '    Case__r.Effective_Date__c, ';
        query += '    Case__r.DuplicateEffectiveDate__c, ';
        query += '    Case__r.LastModifiedDate, ';
        query += '    Case__r.POP_Start_Date__c, ';
        query += '    Case__r.Earliest_Stop_Date__c, ';
        query += '    Case__r.Stop_Request_Date__c, ';
        query += '    Case__r.Stop_Date__c, ';
        query += '    Case__r.Temp_Stop_Date__c, ';
        query += '    Case__r.RecordType.DeveloperName, ';      
        query += '    Subscription__r.Vendor_1__r.Id, ';
        query += '    Subscription__r.Vendor_1__r.Vendor_Group__c, ';
        query += '    Subscription__r.Vendor_1__r.Vendor_Code__c, ';
        query += '    Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c, ';
        query += '    Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c, ';
        query += '    Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c, ';
        query += '    Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name, ';
        query += '    Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c, ';
        query += '    Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c, ';
        query += '    Subscription__r.Recipient_Contact__r.Contact_Legacy_Id__c, ';
        query += '    Subscription__r.Recipient_Contact__r.Id, ';
        query += '    Subscription__r.Recipient_Contact__r.Name, ';
        query += '    Subscription__r.Recipient_Contact__r.Recipient_Number__c, ';
        query += '    Subscription__r.Recipient_Contact__r.Company_Name__c, ';    //START/END D-3914 2015-11-11 Renz Company_Name__c is the new attention to name
        query += '    Subscription__r.Id, ';
        query += '    Subscription__r.Name, ';      
        query += '    Subscription__r.Qty__c, ';      
        query += '    Subscription__r.Pub_Tag__c, ';                
        query += '    Subscription__r.Frequency__c, ';
        query += '    Subscription__r.Product_Code__c, ';       
        query += '    Subscription__r.Zuora__SubscriptionStartDate__c, ';
        query += '    Subscription__r.Zuora__SubscriptionEndDate__c, ';
        query += '    Subscription__r.LastModifiedDate, ';
        query += '    Subscription__r.Zuora__Status__c, ';    
        query += '    Subscription__r.Main_Package_1__c, ';     
        query += '    Account__r.Attention_To_Care_Of__c, ';
        query += '    Account__r.Account_Legacy_Id__c, ';
        query += '    Account__r.Account_Auto_Number__c, ';
        query += '    Account__r.CreatedDate, ';
        query += '    Account__r.Id, ';
        query += '    Account__r.Name, ';
        query += '    LastModifiedDate, ';
        query += '    Case__r.Temp_Stop__r.Temp_Stop_Date__c, ';
        query += '    Case__r.Temp_Stop__r.Restart_Date__c ';
        query += ' FROM Case_Subscription__c ';
        query += ' WHERE ';
        query += '      Case__r.Status IN :caseStatusSet ';
        query += '      AND Subscription__r.Delivered_By_1__c = \'Vendor\' ';     //START/END 2016/01/28 Renino Niefes        UD-3848               
        query += '      AND Case__r.RecordType.DeveloperName = :TSTOP_SUBSCRIPTION ';
        query += '      AND Case__r.Temp_Stop__r.Cancelled__c = FALSE ';
        query += '      AND Case__r.Sub_Status__c != :CASE_SUB_STATUS_TSTOP_REJECTED ';     
        query += '      AND Case__r.Temp_Stop_Type__c != :CASE_TEMP_STOP_TYPE_CANCELLED ';
        query += '      AND (   Case__r.Temp_Stop_Date__c = :dtEffEnd ';
        query += '              OR Case__r.Restart_Date__c = :dtEffEnd ';
        query += '              OR (Case__r.Temp_Stop_Date__c <= :dtEffStart ';
        //START UD-2743 HotFix 02-Sep-2015 Added by Raviteja - No need to notify vendors if case closed after restart date
        query += '                    AND Case__r.Restart_Date__c > :dtEffStart ';
        //End UD-2743 HotFix 02-Sep-2015 Added by Raviteja
        query += '                    AND Case__r.ClosedDate >= :dStartDate ';
        query += '                    AND Case__r.ClosedDate < :dEndDate ';
        query += '              )';
        query += '      )';
        query += '      AND (NOT Case__r.Sub_Status__c LIKE \'%Rejected%\' ) ';  //START/END UD-3080 Renino Niefes 2015-10-12 Exclude rejected cases in the main query
        query += ' ORDER BY ';
        query += ' Subscription__r.Zuora__Account__r.Account_Auto_Number__c, ';     // CRSM Account ID
        query += ' Subscription__r.Recipient_Contact__r.Recipient_Number__c, ';     // CRSM Contact Number
        query += ' Subscription__r.Name, ';                                                     // Subscription Name
        query += ' Subscription__r.Product_Code__c ASC';                                    // Use Product Code in place of Publication Code        
        //END 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
        
        return Database.getQueryLocator(query);
    }
    
    global List<BA_INT_DATA_FAILED_POOL__c> datapoolListFailed = new List<BA_INT_DATA_FAILED_POOL__c>();

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
        //START UD-2599 Renino Niefes 2015-10-08 If the subscription has a COA case effective tomorrow, use the Address_Assignment__c instead of current address
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        Map<Decimal,String> mErrorMessageMap = BT_CO_INT_Utilities.getErrorMessageMap(Z_INTERFACE_ID);
        List<ID> lPackageIDs = new List<ID>();
        List<ID> lSubscriptionIDs = new List<ID>();
        
        // START UD-2132 2015-08-14 Renino Niefes
        Map<String, String> mapProdCode2ProdFamily = new Map<String, String>();
        List<String> lstProdCodes = new List<String>();
        
        //prepare the mainPackageList
        for(sObject record : scope)
        {                       
            Case_Subscription__c subRecord = (Case_Subscription__c) record;
            ID mainPackageId = subRecord.Subscription__r.Main_Package_1__c;
            if (mainPackageId!=null) {
                lPackageIDs.add(mainPackageId);
            }
            
            if(subRecord.Subscription__r.Product_Code__c != null){
                lstProdCodes.add(subRecord.Subscription__r.Product_Code__c);
            }

            ID subscriptionId = subRecord.Subscription__r.Id;
            if (subscriptionId!=null) {
                lSubscriptionIDs.add(subscriptionId);
                System.debug(Logginglevel.INFO,'[Adding to lSubscriptionIDs]:'+lSubscriptionIDs);
            }
        }
        
        // Create a Map of Package IDs to a SET of Publications ...     
        Map<ID, Set<Publication__c>> mPackagePublications = new Map<ID, Set<Publication__c>>();
        if (lPackageIDs.size() > 0) {
            mPackagePublications = BT_CO_INT_Utilities.packageToPublication(lPackageIDs);           
        }
        
        
        // Create a map of product family
        List<zqu__ZProduct__c> zPrd = [select id, ProductCode__c, ProductFamily__c from   zqu__ZProduct__c where ProductCode__c in :lstProdCodes];
        for(zqu__ZProduct__c temp : zPrd){
            if(temp != null && temp.ProductFamily__c != null){
                mapProdCode2ProdFamily.put(temp.ProductCode__c, temp.ProductFamily__c);
            }
        }
        // END UD-2132 2015-08-14 Renino Niefes
    
    
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID);     
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(brd,'Default Timestamp');     
        DateTime cutOffStart = cutOffEnd.addDays(-1); 
        Date dtEffStart = Date.valueOf(brd);
        Date dtEffEnd = dtEffStart.addDays(1); 
    
        //Create a map of COA cases by Subscription ID
        Map<ID, ID> mSubscriptionCOAMap = new Map<ID, ID>();
        List<ID> caseCOAList =  new List<ID>();
        if (lSubscriptionIDs.size() >0) {
            System.debug(Logginglevel.INFO,'[Creating mSubscriptionCOAMap ]:'+lSubscriptionIDs.size());
        
            List<Case_Subscription__c> lCOACaseSubsList = [SELECT Case__r.ID,Subscription__r.ID,Case__r.Effective_Date__c 
                                                            FROM Case_Subscription__c WHERE Case__r.Status = :CASE_STATUS_CLOSED
                                                                AND Case__r.RecordType.DeveloperName = :CHANGE_OF_ADDRESS
                                                                AND Case__r.Effective_Date__c = :dtEffEnd
                                                                AND Subscription__r.ID IN :lSubscriptionIDs
                                                            ORDER BY Subscription__r.ID ASC, Case__r.CreatedDate ASC ];
            for (Case_Subscription__c csRec : lCOACaseSubsList) {               
                if (csRec.Case__r.ID!=null) {
                    mSubscriptionCOAMap.put(csRec.Subscription__r.ID, csRec.Case__r.ID);
                    caseCOAList.add(csRec.Case__r.ID);
                    System.debug(Logginglevel.INFO,'[Adding to mSubscriptionCOAMap ]:'+csRec.Case__r.ID);
                }
            }
        }
    
        //Crate a map of Address Assignment by Case ID      
        Map<ID, Address_Assignment__c> caseAddressAssignmentMap = new Map<ID, Address_Assignment__c>();
        System.debug(Logginglevel.INFO,'[Creating caseAddressAssignmentMap ]:'+caseCOAList.size());
        if (caseCOAList.size()>0) {
            caseAddressAssignmentMap = BT_CO_INT_Utilities.getAddressAssignmentMap(caseCOAList);    
            System.debug(Logginglevel.INFO,'[adding to caseAddressAssignmentMap ]:'+caseAddressAssignmentMap.size());
        }
    
        Date dBatchRunDate = Date.valueOf(brd);
        
        // Iterate through and create the export data
        Set<String> exportDataSet = new Set<String>(); 
        for (sObject record : scope) {
            Case_Subscription__c subRecord = (Case_Subscription__c) record;
                String zRecordType = subRecord.Case__r.RecordType.DeveloperName;
            
                ID zRecordId = subRecord.Id;
            String zVALIDATION_CODE = '0';  
            String zCustomerGroup = subRecord.Subscription__r.Vendor_1__r.Vendor_Group__c;
            String zVendorCode = subRecord.Subscription__r.Vendor_1__r.Vendor_Code__c;
            String zHouseBlockNumber = subRecord.Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c;
            String zLevelNumber = subRecord.Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c;   
            String zUnitNumber = subRecord.Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c;   
            String zPostalCode = subRecord.Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name;   
            String zStreetName = subRecord.Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c;
            String zBuildingName = subRecord.Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c;   
            String zRestartDate = String.valueOf(subRecord.Case__r.Restart_Date__c);
            String zAccountLegacyId = subRecord.Account__r.Account_Legacy_Id__c;
            String zRecipientLegacyId = subRecord.Subscription__r.Recipient_Contact__r.Contact_Legacy_Id__c;
            String zRecipientName = subRecord.Subscription__r.Recipient_Contact__r.Name;
            
            //START D-3914 2015-11-11 Renz Company_Name__c is the new attention to name
            //String zAttnToCareOf = subRecord.Account__r.Attention_To_Care_Of__c;
            String zAttnToCareOf = subRecord.Subscription__r.Recipient_Contact__r.Company_Name__c;    
            //END D-3914 2015-11-11 Renz Company_Name__c is the new attention to name
            
            String zCRSMAccountNumber = subRecord.Account__r.Account_Auto_Number__c;
            Decimal dCRSMContactNumber = subRecord.Subscription__r.Recipient_Contact__r.Recipient_Number__c;
            String zCRSMContactNumber = String.valueOf(dCRSMContactNumber != null ? dCRSMContactNumber.toPlainString() : 'null');
            String zProductCode = subRecord.Subscription__r.Product_Code__c;                            
            Date dtEffectiveDate = subRecord.Case__r.Effective_Date__c;
            Date dtSubscriptionStartDate = subRecord.Subscription__r.Zuora__SubscriptionStartDate__c;
            Date dtSubscriptionEndDate = subRecord.Subscription__r.Zuora__SubscriptionEndDate__c;
            DateTime dtmSubscriptionLastModifiedDate = subRecord.Subscription__r.LastModifiedDate;
            String zSubscriptionStatus = subRecord.Subscription__r.Zuora__Status__c;            
            Date dtEarliestStopDate = subRecord.Case__r.Earliest_Stop_Date__c;
            Date dtStopRequestDate = subRecord.Case__r.Stop_Request_Date__c;
            Date dtTempStopDate = subRecord.Case__r.Temp_Stop__r.Temp_Stop_Date__c;
            Date dtTSRestartDate = subRecord.Case__r.Temp_Stop__r.Restart_Date__c;            
            ID zPackageID = subRecord.Subscription__r.Main_Package_1__c;    
            String zCaseRecordType = subRecord.Case__r.RecordType.DeveloperName;
            DateTime dtLastModifiedDate = subRecord.LastModifiedDate;
            String zSubscriptionFrequency = subRecord.Subscription__r.Frequency__c;
            Decimal dSubscriptionQty = subRecord.Subscription__r.Qty__c;
            String zCrsmSubscriptionId = subRecord.Subscription__r.Name; //START/END  UD-2980 2015-10-01 Renino Niefes add Subscription ID

            String zTransactionDesc = null;
            String zTransactionType = null;
            Date zEffectiveDate = null;
            Date zEffectiveIssueDate = null;            
            Date zEffectiveIssueDate2 = null;

            ID subscriptionId = subRecord.Subscription__r.Id;
            
            //Override the Address fields if there's a COA effective tomorrow for the same subcription          
            System.debug(Logginglevel.INFO,'[overriding Address fields ]: Checking if Subscription ID exist ' + subscriptionId);
            if (subscriptionId!=null&&mSubscriptionCOAMap.containsKey(subscriptionId)) {                
                ID coaCaseID = mSubscriptionCOAMap.get(subscriptionId);
                System.debug(Logginglevel.INFO,'[overriding Address fields ]: Checking if Case ID exist ' + coaCaseID);
                if (coaCaseID!=null&&caseAddressAssignmentMap.containsKey(coaCaseID)) {
                    System.debug(Logginglevel.INFO,'[overriding Address fields ]: fetching address fields from address assignment block ');
                    Address_Assignment__c aRecord = (Address_Assignment__c) caseAddressAssignmentMap.get(coaCaseID);
                    if (aRecord != null) {
                        zHouseBlockNumber = aRecord.Address__r.Block_House_Number__c;
                        zLevelNumber = aRecord.Address__r.Level_Number__c;
                        zUnitNumber = aRecord.Address__r.Unit_Number__c;
                        zStreetName = aRecord.Address__r.Street_Name__c;
                        zBuildingName = aRecord.Address__r.Building_Name__c;
                        zPostalCode = aRecord.Address__r.Postal_Code__r.Name;
                        zVendorCode = aRecord.Vendor__r.Vendor_Code__c;
                        zCustomerGroup = aRecord.Vendor__r.Vendor_Group__c;
                        if (zCustomerGroup == null) zCustomerGroup = 'V';
                    } else {
                        System.debug(Logginglevel.INFO,'[overriding Address fields ]: Address Assignment record is null. ');
                    }
                } else {
                    System.debug(Logginglevel.INFO,'[overriding Address fields ]: Case ID does not have Address Assignment ' + coaCaseID);
                }
            } else {
                System.debug(Logginglevel.INFO,'[overriding Address fields ]: Subscription ID does not have COA ' + subscriptionId);
            }
            
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
        
            if (mPackagePublications.containsKey(zPackageID)) {
                Set<Publication__c> publicationListData = new Set<Publication__c>();

                if (mPackagePublications.get(zPackageID) != null) {
                    publicationListData = mPackagePublications.get(zPackageID);
                } 
                publicationListData = BT_CO_INT_Utilities.prodPubMapping(publicationListData, zProductCode, mapProdPub);//START/End UD-2691 23-Sep-2015 Added by Raviteja 
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


                        //Setting transaction type and description for first record
                        zTransactionType = getTempStopTransactionType(dBatchRunDate, dtTempStopDate,dtTSRestartDate);
                        zTransactionDesc = TRANSACTION_DESC_TEMPSTOP;

                        Date dStart = null;
                        Date dEnd = null;
                        if (zTransactionType.equalsIgnoreCase(TRANSACTION_TYPE_START)) { 
                            zEffectiveDate = dtTSRestartDate;                   
                            dStart = dtTSRestartDate;
                            dEnd = DateUtility.convertDateFromYYYYMMDD(DEFAULT_END_DATE);                       
                            if (dStart==null) dStart = Date.Today();    
                        }
                        if (zTransactionType.equalsIgnoreCase(TRANSACTION_TYPE_STOP)) {
                            zEffectiveDate = dtTempStopDate;
                            dStart = dtTempStopDate;
                            dEnd = dtTSRestartDate;
                            if (dStart==null) dStart = Date.Today();
                            if (dEnd==null) dEnd = DateUtility.convertDateFromYYYYMMDD(DEFAULT_END_DATE);           
                        }
                                            
                        zEffectiveIssueDate = DateUtility.getFirstPublicationDate(dStart,dEnd,zPattern);
                        
                        //START UD-3078 2015-10-12 Renino Niefes Check if temp stop is a start. If it is, check if the publication is within the stop request date and restart date.  
                        //                                        If not, set Effective Issue date to null.  This will trigger the validation check for zCheck variable 
                        //                                        and exclude the record from file.
                        if (zTransactionType.equalsIgnoreCase(TRANSACTION_TYPE_START)) { 
                            Date tempDate = null;
                            tempDate = DateUtility.getFirstPublicationDate(dtTempStopDate,dtTSRestartDate,zPattern);
                            if (tempDate==null) zEffectiveIssueDate = null;
                        }
                        //END UD-3078 2015-10-12 Renino Niefes 
                        
                        String zCheck = (zEffectiveIssueDate != null) ? '0' : '1';
                        String zRestartDateStr = zTransactionType.equalsIgnoreCase(TRANSACTION_TYPE_STOP) ? String.valueOf(dtTSRestartDate) : null; 
                        
                        // Validate Data ...                        
                        zVALIDATION_CODE = StringUtility.validate(zVendorCode);                 // Check 'Vendor Number' Data ...
                        zVALIDATION_CODE += StringUtility.validate(zHouseBlockNumber);              // Check 'House/Block Number' Data ... 
                        zVALIDATION_CODE += StringUtility.validate(zPostalCode);                    // Check 'Postal Code' Data ...
                        zVALIDATION_CODE += StringUtility.validate(zDayOfWeekPattern);          // CHeck 'Day of Week Pattern' Data ...                     
                        zVALIDATION_CODE += StringUtility.validate(zRecipientName);             // Check 'Recipient Name' Data ...                      
                        zVALIDATION_CODE += StringUtility.validate(zCRSMAccountNumber);         // Check 'Account Number' Data ...
                        zVALIDATION_CODE += StringUtility.validate(zCRSMContactNumber);         // Check 'Recipient Number' Data ...                    
                        zVALIDATION_CODE += StringUtility.validate(zPublicationCode);               // Check 'Publication Code' Data ...                        
                        zVALIDATION_CODE += StringUtility.validate(zEffectiveDate);             // Check 'Effective Date' Data ...                                              
                        zVALIDATION_CODE += '0';//StringUtility.validate(zLevelNumber);             // Check 'Level Number' Data ...                        
                        zVALIDATION_CODE += '0';//StringUtility.validate(zUnitNumber);                  // Check 'Unit Number' Data ...                     
                        zVALIDATION_CODE += StringUtility.validate(zStreetName);                        // Check 'Street Name' Data ...  
                        zVALIDATION_CODE += StringUtility.validate(zTransactionType);               // Check 'Transaction Type' ...
                        zVALIDATION_CODE += StringUtility.validate(zTransactionDesc);               // Check 'Transaction Desc' Data ... 
                        zVALIDATION_CODE += StringUtility.validate(zEffectiveIssueDate);            // Check The Indicator ...                      

                        //Override zValidation Code to Pass.  Moving validation checks to on-premise server and save to FAI file
                        zVALIDATION_CODE = '000000000000000';
                        
                        // Create zData string ...
                        String zData = '';
                        zData += StringUtility.quoteReplaceStr(zCustomerGroup) +',';                    // Customer Group (Vendor Group)
                        zData += StringUtility.quoteReplaceStr(zVendorCode) +',';                       // Vendor Number 
                        zData += StringUtility.quoteReplaceStr(zTransactionType) +',';                  // Transaction Type 
                        zData += StringUtility.quoteReplaceStr(zTransactionDesc) +',';                  // Transaction Description 
                        zData += StringUtility.quoteReplaceStr(zHouseBlockNumber) +',';                 // Block Number
                        zData += StringUtility.quoteReplaceStr(zLevelNumber) +',';                      // Level Number 
                        zData += StringUtility.quoteReplaceStr(zUnitNumber) +',';                       // Unit Number 
                        zData += StringUtility.quoteReplaceStr(zPostalCode) +',';                       // Postal Code 
                        zData += StringUtility.quoteReplaceStr(zStreetName) +',';                       // Street Name 
                        zData += StringUtility.quoteReplaceStr(zBuildingName) +',';                     // Building Name 
                        zData += StringUtility.quoteReplaceStr(zPublicationCode) +',';                  // Publication Code 
                        zData += StringUtility.quoteReplaceStr(String.valueOf(dSubscriptionQty)) +',';          // Subscription Copies
                        zData += StringUtility.quoteReplaceStr(String.valueOf(zEffectiveDate)) +',';            // Effective Date                         
                        zData += StringUtility.quoteReplaceStr(String.valueOf(zEffectiveIssueDate)) +',';       // Effective Issue         

                        // Temp Stop Restart Date only for 'STOP' component ...
                        zData += StringUtility.quoteReplaceStr(zRestartDateStr) +',';                           // Restart Date 
                        zData += StringUtility.quoteReplaceStr(zDeliveryFrequency) +',';                    // Delivery Frequency 
                        zData += StringUtility.quoteReplaceStr(zAccountLegacyId) +',';                      // Subscriber Account 
                        zData += StringUtility.quoteReplaceStr(zRecipientLegacyId) +',';                    // Recipient Account 
                        zData += StringUtility.quoteReplaceStr(zRecipientName) +',';                        // Recipient Name 
                        zData += StringUtility.quoteReplaceStr(zAttnToCareOf) +',';                         // Recipient Attention To 
                        zData += 'null,';   // Route Sys    ---> IGNORED FIELD
                        zData += 'null,';   // Route Number ---> IGNORED FIELD
                        zData += 'null,';   // Drop Point   ---> IGNORED FIELD
                        zData += 'null,';   // User ID      ---> IGNORED FIELD
                        zData += StringUtility.quoteReplaceStr(zSponsoredIndicator) +',';               // Sponsored Indicator
                        zData += StringUtility.quoteReplaceStr(zMon) +',';                              // Day 1 Copy 
                        zData += StringUtility.quoteReplaceStr(zTue) +',';                              // Day 2 Copy 
                        zData += StringUtility.quoteReplaceStr(zWed) +',';                              // Day 3 Copy 
                        zData += StringUtility.quoteReplaceStr(zThu) +',';                              // Day 4 Copy 
                        zData += StringUtility.quoteReplaceStr(zFri) +',';                              // Day 5 Copy 
                        zData += StringUtility.quoteReplaceStr(zSat) +',';                              // Day 6 Copy 
                        zData += StringUtility.quoteReplaceStr(zSun) +',';                              // Day 7 Copy 
                        zData += StringUtility.quoteReplaceStr(zPHd) +',';                              // PH Weekday Copy 
                        zData += StringUtility.quoteReplaceStr(zPHe) +',';                              // PH Weekend Copy 
                        zData += StringUtility.quoteReplaceStr(zDayOfWeekPattern) +',';                 // Day of Week Pattern 
                        zData += StringUtility.quoteReplaceStr(zProductCode) +',';                      // Product Code 
                        zData += StringUtility.quoteReplaceStr(zCRSMAccountNumber) +',';                // CRSM Account ID
                        zData += StringUtility.quoteReplaceStr(zCRSMContactNumber) +',';                // CRSM Contact ID
                        zData += StringUtility.quoteReplaceStr(zPHeIndicator) +',';                     // Day of week pattern (PHe)
                        zData += StringUtility.quoteReplaceStr(zCrsmSubscriptionId) +',';               //START/END  UD-2980 2015-10-01 Renino Niefes add Subscription ID
                        
                        if (BT_CO_INT_Utilities.checkValidation(zCheck)) {                      
                            if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE)) {
                                if (!exportDataSet.contains(zData)) {
                                    exportDataSet.add(zData);
                                    datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', zRecordId, zData, dtLastModifiedDate, datapoolList);
                                }
                            } else {
                                //Create a debug log / Interpret Validation String / Insert to Failed Pool
                                BT_CO_INT_Utilities.log(zData,zRecordId);
                                String zErrMsg = '('+zRecordType+')'+BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, mErrorMessageMap);
                                addFailedRecord(zRecordID, zErrMsg, zVALIDATION_CODE, zData, DateTime.now());
                            }   
                        } else {
                            String zReason = mErrorMessageMap.get(Integer.valueOf(ERROR_CODE_NONPUB));
                            String zErrorReason = zReason.replace('$1',zPublicationCode)
                                            .replace('$2',String.valueOf(dStart))
                                            .replace('$3',String.valueOf(dEnd));
                            String zErrMsg = '('+zRecordType+')'+'EXPORT-FAILED: ' + zErrorReason;
                            String zErrCode = '('+BT_CO_INT_Utilities.convert(ERROR_CODE_NONPUB)+') | '+ERROR_CODE_NONPUB;
                            
                            addFailedRecord(zRecordID, zErrMsg, zErrCode, zData, dtLastModifiedDate);
                        }                   
                        zVALIDATION_CODE = '';
                    }
                }
            }
        }
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try {
            insert datapoolList;
            upsert datapoolListFailed;    //START/END UD-3078 2015-10-12 Renino Niefes use Upsert instead of insert
        } catch(Exception e) {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            BT_CO_INT_Utilities.log('BT_AB_HDS038DX_DailyStartStopActionFile insert operation failed.' + e.getMessage());
        }
        //END UD-2599 Renino Niefes 2015-10-08
    }
    
    global void finish(Database.BatchableContext BC) {
        BT_AB_HDS038DX_NormalExpirySubscriptions callOutJob = new BT_AB_HDS038DX_NormalExpirySubscriptions();
        Database.executeBatch(callOutJob);
    } 

    private String getTempStopTransactionType(Date dBatchRunDate, Date dStopDate, Date dRestartDate) {
        //START UD-2743 HotFix 02-Sep-2015 Added by Raviteja - By default transaction type is stop. This would only be start if tomorrow is the restart date
        /*
        String zResult = TRANSACTION_TYPE_START;
        if (dBatchRunDate != null) {
            Date dNextDate = dBatchRunDate.addDays(1);
            if (dStopDate != null && dStopDate.isSameDay(dNextDate) ) {
                zResult = TRANSACTION_TYPE_STOP;
            }
            if (dRestartDate != null && dRestartDate.isSameDay(dNextDate)) {
                zResult = TRANSACTION_TYPE_START;
            }
        }
        */
        String zResult = TRANSACTION_TYPE_STOP;
        if (dBatchRunDate != null) {
            Date dNextDate = dBatchRunDate.addDays(1);            
            if (dRestartDate != null && dRestartDate.isSameDay(dNextDate)) {
                zResult = TRANSACTION_TYPE_START;
            }
        }
        //End UD-2743 HotFix 02-Sep-2015 Added by Raviteja
        return zResult;
    }
    
    private void addFailedRecord(String zRecordID, String zErrMsg, String zErrCode, String zData, DateTime dtLastModifiedDate) {
        datapoolListFailed = BT_CO_INT_Utilities.exportFailedDataItem(  
            Z_INTERFACE_ID, 
            'Detail',
            zRecordID, 
            zErrMsg, 
            zErrCode, 
            zData, 
            dtLastModifiedDate, 
            datapoolListFailed);            
    }   
}