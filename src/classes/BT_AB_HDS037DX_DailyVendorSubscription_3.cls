/*
 * Class Name: BT_AB_HDS037DX_DailyVendorSubscription_3
 * @author: Raviteja Kumar
 * Date: 17-May-2016
 * Project/Requirement: SPH Integration - HDS037DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for HDS037DX batch job. Used together with BT_AS_HDS037DX_DailyVendorSubscription Schedulable
 * Created class to executed back dated records
 * 
 */

global class BT_AB_HDS037DX_DailyVendorSubscription_3 implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful

{
    global final String Z_INTERFACE_ID = 'HDS037DX';

    // START UD-1198 - Michael Francisco 2015/05/12 

    /* Possible values: Closed */
    global final String Z_CUSTOM_CASE_STATUS = 'HDS037DX Case Status';      

    /* Default Stop Date */
    global final String Z_CUSTOM_DEFAULT_STOP_DATE = 'HDS037DX Default Stop Date';

    /* Possible values: Change_of_Address | Change_of_Vendor | Start_Subscription | Stop_Subscription | Change_of_Subscription | Renewal_of_Subscription */
    global final String Z_CUSTOM_CASE_RECORD_TYPE = 'HDS037DX Case Record Types';   

    global final String START_SUBSCRIPTION = 'Start_Subscription';
    global final String STOP_SUBSCRIPTION = 'Stop_Subscription';
    global final String CHANGE_OF_VENDOR = 'Change_of_Vendor';
    global final String CHANGE_OF_ADDRESS = 'Change_of_Address';
    global final String CHANGE_OF_SUBSCRIPTION = 'Change_of_Subscription';
    global final String RENEWAL_OF_SUBSCRIPTION = 'Renewal_of_Subscription';

    global final String CHANGE_OF_VENDOR_TYPE = 'Change of Vendor';
    global final String Z_CUSTOM_DEFAULT_END_DATE = '20991231';  

    /* ========= INDICATOR Constants ========= */
    global final String Z_IND_ADD = 'A';            // Add
    global final String Z_IND_UPDATE = 'U';         // Update
    global final String Z_IND_CHANGE = 'C';         // Change

    /* ========= Transaction DATE Mapping Constants ========= */
    global final String Z_TRANS_START_DATE = 'START_DATE';
    global final String Z_TRANS_END_DATE = 'END_DATE';
    global final String Z_TRANS_EFFECTIVE_DATE = 'EFFECTIVE_DATE';

    /* ========= ZUORA Subscription Status ========= */
    global final String Z_ZUORA_SUBSCRIPTION_CANCELLED = 'Cancelled';

    /* Default Cut-Off DateTime Format */
    global final String Z_DATETIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\''; 
    global final String Z_DATE_FORMAT = 'yyyy-MM-dd';   

    global final String INDICATOR_YES = 'Y';
    global final String INDICATOR_NO = 'N';

    global final String TRANSACTION_TYPE_START = 'Start';
    global final String TRANSACTION_TYPE_STOP = 'Stop';

    global static final String ERROR_CODE_ZDATA_FAILURE = '1921';
    global static final String ERROR_CODE_EXCEPTION = '1311';
    global static final String ERROR_CODE_NONPUB = '1701';
    
    global static String DEFATUL_STOP_DATE = '20991231';
    global static String batchRunDateX = null;
    global Map<String, Set<String>> mapProdPub = new Map<String, Set<String>>(); //START/End UD-2691 23-Sep-2015 Added by Raviteja     
    
    global DateTime dStartDatetime; 
    global DateTime dEndDatetime; 
    global Set<Id> casesubsIds = New Set<Id>();
    
    global BT_AB_HDS037DX_DailyVendorSubscription_3(Set<Id> casesubIds,DateTime StartDatetime,DateTime EndDatetime)
    {
        if(casesubIds.size() > 0){
            casesubsIds.addAll(casesubIds);
        }
        dStartDatetime = StartDatetime;
        dEndDatetime = EndDatetime;
    }
    
    global BT_AB_HDS037DX_DailyVendorSubscription_3(DateTime StartDatetime,DateTime EndDatetime)
    {        
        dStartDatetime = StartDatetime;
        dEndDatetime = EndDatetime;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
      {       
        
        // Prepare the cut off dates
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID);  
        Date dBatchRunDate = convertBRD_To_Date(batchRunDate);

        DateTime dStartDate = DateTime.newInstance(dBatchRunDate.year(),dBatchRunDate.month(),dBatchRunDate.day()); 
        //DateTime dEndDate = dStartDate.addDays(1);
        //DateTime dEndDate = Date.Today().addDays(1);
        DateTime dEndDate = dEndDatetime;
        
        //DateTime dTomorrow = System.Today().addDays(1);
        
        //START UD-2697 2015-10-02 Renino Niefes Fixed the cut off logic to only fetch based from previous exeuction date time
        //START 2015/09/16 Renino Niefes            - UD-2774 Hot Fix: Use the previous batch run date instead of previous day 12 midnight to current day 12 midnight
        DateTime dtPrevBatchRunDate = DateUtility.getOverrideDate(Z_INTERFACE_ID);
        Date dPrevBatchRunDate = dtPrevBatchRunDate.date();
        DateTime dStartDate2 = null;
        if (dPrevBatchRunDate<=dBatchRunDate&&dtPrevBatchRunDate<dStartDate) {
            dStartDate2 = dtPrevBatchRunDate;
        } else {
            dStartDate2 = dStartDate;
        }                
        //END 2015/09/16 Renino Niefes            - UD-2774
        //END UD-2697 2015-10-02 Renino Niefes
     
        DateTime dtLastBatchRunDate = DateUtility.getOverrideDate(Z_INTERFACE_ID);         
        DateTime newCutOffStart = dStartDate;

        if (dtLastBatchRunDate<dStartDate) {
            Integer minutesDiff = Integer.valueOf((dtLastBatchRunDate.getTime() - dStartDate.getTime())/1000/60);
            newCutOffStart = dStartDate.addMinutes(minutesDiff); 
        }
        //dStartDate = DateTime.newInstance(dBatchRunDate.year(),dBatchRunDate.month(),dBatchRunDate.day());
        dStartDate = dStartDatetime;
        // Prepare the CASE 'Status' applicable to this interface
        Set<String> caseStatusSet = getCustomSetting(Z_CUSTOM_CASE_STATUS);
        
        mapProdPub = BT_CO_INT_Utilities.prodPubMapping();   //START/End UD-2691 23-Sep-2015 Added by Raviteja       

        // Prepare the CASE 'Record Type' that this interface will use
        Set<String> caseRecordTypesSet = new Set<String>();
        caseRecordTypesSet.add(CHANGE_OF_VENDOR);
        caseRecordTypesSet.add(CHANGE_OF_ADDRESS);

        //getCustomSetting(Z_CUSTOM_CASE_RECORD_TYPE);

        //START 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
        String query = ' SELECT ';
        query += '      Id, ';
        query += '      Account__r.Account_Legacy_Id__c, ';
        query += '      Account__r.Account_Auto_Number__c, ';
        query += '      Account__r.Id, ';
        query += '      Account__r.Name, ';
        query += '      Account__r.Company_Name__c, ';
        query += '      Account__r.Sub_Group__c, ';
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
        query += '      Subscription__r.Recipient_Contact__r.Salutation, ';     
        query += '      Subscription__r.Id, ';
        query += '      Subscription__r.Name, ';
        query += '      Subscription__r.Qty__c, ';
        query += '      Subscription__r.Pub_Tag__c, ';              
        query += '      Subscription__r.Frequency__c, ';
        query += '      Subscription__r.Product_Code__c, ';
        query += '      Subscription__r.Zuora__SubscriptionStartDate__c, ';
        query += '      Subscription__r.Zuora__SubscriptionEndDate__c, ';
        query += '      Subscription__r.Effective_Start_Date__c, ';     
        query += '      Subscription__r.Effective_End_Date__c, ';               
        query += '      Subscription__r.Vendor_1__r.Id, ';
        query += '      Subscription__r.Vendor_1__r.Vendor_Group__c, ';
        query += '      Subscription__r.Vendor_1__r.Vendor_Code__c, ';
        query += '      Subscription__r.Main_Package_1__c, ';
        query += '      Subscription__r.LastModifiedDate, ';
        query += '      Subscription__r.Zuora__Status__c, ';    

        //START UD-2536 Renino Niefes 2015-09-25 Add new fields for old address
        query += '      Address__r.Id, ';
        query += '      Address__r.Block_House_Number__c, ';
        query += '      Address__r.Level_Number__c, ';
        query += '      Address__r.Unit_Number__c, ';
        query += '      Address__r.Postal_Code__r.Name, ';
        query += '      Address__r.Street_Name__c, ';
        query += '      Address__r.Building_Name__c, ';
        //END UD-2536 Renino Niefes 2015-09-25 Add new fields for old address
        
        query += '      Case__r.ClosedDate, ';
        query += '      Case__r.Order__c, ';
        query += '      Case__r.Order__r.ID, ';
        query += '      Case__r.Order__r.Subscription__r.ID, ';
        query += '      Case__r.CreatedDate, ';
        query += '      Case__r.LastModifiedDate, ';
        query += '      Case__r.RecordType.DeveloperName, ';                
        query += '      Case__r.Stop_Date__c, ';  
        query += '      Case__r.Stop_Request_Date__c, ';
        query += '      Case__r.Effective_Date__c, ';
        query += '      Case__r.Change_of_Address_Type__c , ';
        query += '      Case__r.Id, ';
        query += '       Case__r.Vendor__r.Vendor_Group__c, ';  
        query += '       Case__r.Vendor__r.Vendor_Code__c, ';                   
        query += '      LastModifiedDate ';
        query += ' FROM ';
        query += '      Case_Subscription__c ';
        query += ' WHERE ';
        query += '      Case__r.Status IN :caseStatusSet ';
        query += '      AND Subscription__r.Delivered_By_1__c = \'Vendor\' ';   
        if(!casesubsIds.isEmpty()){
            query += '      AND ID IN :casesubsIds '; // added for testing purpose
        }
        query += '      AND Case__r.RecordType.DeveloperName = :STOP_SUBSCRIPTION  ';
        query += '      AND  Subscription__r.Qty__c >= 0 AND  ';
        query += '      Subscription__r.Zuora__SubscriptionStartDate__c <= ' +dStartDate.format(Z_DATE_FORMAT) ;
        
        query += '      AND (NOT Case__r.Sub_Status__c LIKE \'%Rejected%\' ) ';   
        query += ' ORDER BY ';
        query += '      Account__r.Account_Auto_Number__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Name, ';
        query += '      Subscription__r.Name, ';       
        query += '      Case__r.LastModifiedDate, '; 
        query += '      Case__r.RecordType.DeveloperName ';     
        
        if(Test.isRunningTest()){
           query += '      Limit 200 ';  
        }
     
      //START UD-2774 Renz Hotfix: for debugging purposes only
      System.debug(Logginglevel.INFO,'[EXPORT-BASE-SOQL]:'+query);
      System.debug(Logginglevel.INFO,'[EXPORT-BASE-SOQL]:'+dStartDate );
      System.debug(Logginglevel.INFO,'[EXPORT-BASE-SOQL]:'+dEndDate );
      //END UD-2774 Renz Hotfix: for debugging purposes only
              
         system.debug('query : '+query);     
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {   
        System.debug(Logginglevel.INFO,'HDS037DX: Execute Start Block...');    
        DEFATUL_STOP_DATE = StringUtility.getCustomSetting(Z_CUSTOM_DEFAULT_STOP_DATE); 
        DEFATUL_STOP_DATE = DEFATUL_STOP_DATE != null ? DEFATUL_STOP_DATE : Z_CUSTOM_DEFAULT_END_DATE;
        
        Set<String> exportDataSet = new Set<String>(); 
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        List<BA_INT_DATA_FAILED_POOL__c> datapoolListFailed = new List<BA_INT_DATA_FAILED_POOL__c>();
        Map<Decimal,String> errorMessageMap = BT_CO_INT_Utilities.getErrorMessageMap(Z_INTERFACE_ID);
        Map<String, String> mapProdCode2ProdFamily = new Map<String, String>();
        Map<Id, Case_Subscription__c> orderId_caseSubscription_map = new Map<Id, Case_Subscription__c>(); //START/END 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
        List<String> lstProdCodes = new List<String>();

        List<ID> lPackageIDs = new List<ID>();
        List<ID> caseIdList = new List<Id>();
        List<ID> lChangeOfSubscriptionOrderIDs = new List<ID>();
        List<ID> lSubscriptionIDs = new List<ID>();
        List<ID> lOrderIDs = new List<ID>();
          
        //prepare the mainPackageList and caseIdList
        
        for (sObject record : scope) {
            System.debug(Logginglevel.INFO, 'HDS037DX: preparing the mainPackageList and caseIdList...');
            Case_Subscription__c csRecord = (Case_Subscription__c) record;
            String zRecordType = csRecord.Case__r.RecordType.DeveloperName;
            ID orderID = csRecord.case__r.Order__c;
            ID subscriptionID = csRecord.Subscription__r.Id;
            
            ID csMainPackageId = csRecord.Subscription__r.Main_Package_1__c;
            if (csMainPackageId!=null) {
                lPackageIDs.add(csMainPackageId);
            }
            
        // Store the 'Order IDs' for 'Change of Subscription'
            if (isChangeOfSubscription(zRecordType)) {
                ID caseOrderID = csRecord.Case__r.Order__r.ID;
                if (caseOrderID != null) {
                    lChangeOfSubscriptionOrderIDs.add(caseOrderID);
                }               
            }
         
            if (orderID != null) {
                lOrderIDs.add(orderID);
                System.debug(Logginglevel.INFO, 'HDS037DX: Order IDs ' + orderID);
            }
         
            if (subscriptionID != null) {
                lSubscriptionIDs.add(subscriptionID);
                System.debug(Logginglevel.INFO, 'HDS037DX: Subscription IDs ' + subscriptionID);
            }
            
            ID caseId = csRecord.Case__r.Id;
            if (caseId!=null) {
                caseIdList.add(caseId);
            }
            
            if(csRecord.Subscription__r.Product_Code__c != null){
                lstProdCodes.add(csRecord.Subscription__r.Product_Code__c);
            }
            
            orderId_caseSubscription_map.put(csRecord.Case__r.Order__c, csRecord); //START/END 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
        }   
        
        List<zqu__ZProduct__c> zPrd = [select id, ProductCode__c, ProductFamily__c from   zqu__ZProduct__c where ProductCode__c in :lstProdCodes];
        for(zqu__ZProduct__c temp : zPrd){
            if(temp != null && temp.ProductFamily__c != null){
                mapProdCode2ProdFamily.put(temp.ProductCode__c, temp.ProductFamily__c);
            }
        }

    // Create 'Change of Subscription' Subscription Map
        Map<ID, Zuora__Subscription__c> mCaseSubscriptionMap = BT_CO_INT_Utilities.getSubscriptionMap(lSubscriptionIDs);
        Map<ID, Zuora__Subscription__c> mOrderSubscriptionMap = BT_CO_INT_Utilities.orderToSubscription(lChangeOfSubscriptionOrderIDs);
        Set<ID> zChangeOfSubscriptionIDs = new Set<ID>();
        if (mOrderSubscriptionMap != null && mOrderSubscriptionMap.size() > 0) {
            zChangeOfSubscriptionIDs = mOrderSubscriptionMap.keySet();            
        }
        
        // Get the 'Main Package IDs' for the 'Change of Subscription IDs' ... 
        for (ID zRecordID : zChangeOfSubscriptionIDs) {
            Zuora__Subscription__c zRecord = (Zuora__Subscription__c) mOrderSubscriptionMap.get(zRecordID);
            ID zMainPackageID = zRecord.Main_Package_1__c; 
            if (zMainPackageID != null) {
                lPackageIDs.add(zMainPackageID);                                
            }
        }
        
        // Create a Map of Address Assignment Object
        Map<ID, Address_Assignment__c> caseAddressAssignmentMap = BT_CO_INT_Utilities.getAddressAssignmentMap(caseIdList);

        // Create a Map of Package IDs to a SET of Publications ...     
        Map<ID, Set<Publication__c>> mPackagePublications = new Map<ID, Set<Publication__c>>();
        if (lPackageIDs.size() > 0) {
            mPackagePublications = BT_CO_INT_Utilities.packageToPublication(lPackageIDs);           
        }
        
        // UD-1606 Hot Fix - Create a map of Order Line Items using Order ID and Subscription IDs
        Map<String, Order_Line_Item__c> mOrderLineItemMap = new Map<String, Order_Line_Item__c>();

        DateTime dStartDate ;
        DateTime dEndDate ;
        
        DateTime dStartDate2 = null;

        dStartDate = dStartDatetime;
        dEndDate = dEndDatetime;
        dStartDate2 = dStartDatetime;
        
        System.debug(Logginglevel.INFO, 'HDS037DX: dStartDate2 ' + dStartDate2);
        
        List<Order_Line_Item__c> orderItemsList = [ SELECT Order__c,Stop_Request_Date__c,Subscription__c 
                                        FROM Order_Line_Item__c 
                                        WHERE Order__c IN :lOrderIDs
                                            AND Subscription__c IN :lSubscriptionIDs
                                        ORDER BY Order__c, Subscription__c ];

        for (Order_Line_Item__c orderItem : orderItemsList) {
            Case_Subscription__c caseSubscriptionRecord = orderId_caseSubscription_map.get(orderItem.Order__c);
            DateTime caseClosedDate = caseSubscriptionRecord.Case__r.ClosedDate;
            System.debug(Logginglevel.INFO, 'HDS037DX: caseClosedDate ' + caseClosedDate);
            System.debug(Logginglevel.INFO, 'HDS037DX: orderItem.Order__c ' + orderItem.Order__c);
            System.debug(Logginglevel.INFO, 'HDS037DX: orderItem.Subscription__c ' + orderItem.Subscription__c);
            if(orderItem.Stop_Request_Date__c == Date.valueOf(dStartDate) ||
                (orderItem.Stop_Request_Date__c <= caseClosedDate && caseClosedDate >= dStartDate2 && caseClosedDate < dEndDate)) {
                String orderItemKey = '';
                orderItemKey += orderItem.Order__c + '-' + orderItem.Subscription__c;
                mOrderLineItemMap.put(orderItemKey, orderItem);
                System.debug(Logginglevel.INFO, 'HDS037DX: OrderlineItemMap ' + orderItemKey);
            }
        }
        //END 2015-10-02 UD-2697 Renino Niefes
        //END 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
        
        for(sObject record : scope) {                       
            Case_Subscription__c csRecord = (Case_Subscription__c) record;
            
            String zVALIDATION_CODE = '';
            ID zRecordId = csRecord.Id;
            ID zCaseId = csRecord.Case__r.ID;
            
            ID orderID = csRecord.case__r.Order__c;
            ID subscriptionID = csRecord.Subscription__r.Id;
            String strOrderSubsKey = orderID+ '-' + subscriptionID;
            System.debug(Logginglevel.INFO, 'HDS037DX: orderItemKey ' + strOrderSubsKey);
            
        // TBD: Update this to the correct field for the 4-digit Singpost Address Id.
            String zSingpostAddressId = '0000';     
            
            String zSubGroup = csRecord.Account__r.Sub_Group__c;
            String zCRSMAccountNumber = csRecord.Account__r.Account_Auto_Number__c;
            String zAccountLegacyId = csRecord.Account__r.Account_Legacy_Id__c;
            String zRecordType = csRecord.Case__r.RecordType.DeveloperName;
            String zSubRecordType =  csRecord.Case__r.Change_of_Address_Type__c;
            if (zSubRecordType != null && zSubRecordType.equalsIgnoreCase(CHANGE_OF_VENDOR_TYPE)) {
                zRecordType = CHANGE_OF_VENDOR;
            }
            
            String zChgVendorGroup = csRecord.Case__r.Vendor__r.Vendor_Group__c;
            String zChgVendorCode = csRecord.Case__r.Vendor__r.Vendor_Code__c;
            
            String zCompanyName = csRecord.Account__r.Company_Name__c;
            String zIndicator = getIndicator(zRecordType);

            boolean isChangeOfAddress = isChangeOfAddress(zRecordType, zSubRecordType);
            boolean isChangeOfSubscription = isChangeOfSubscription(zRecordType);
            boolean isChangeOfVendor = isChangeOfVendor(zRecordType);           
            boolean isRenewalOfSubscription = isRenewalOfSubscription(zRecordType);         
                        
            Zuora__Subscription__c zSubscriptionRecord = mCaseSubscriptionMap.get(csRecord.Subscription__c);
            
            String zPublicationTag = zSubscriptionRecord.Pub_Tag__c;
            String zRecipientLegacyId = zSubscriptionRecord.Recipient_Contact__r.Contact_Legacy_Id__c;
            String zProductCode = zSubscriptionRecord.Product_Code__c;
            
            String zVendorCode = zSubscriptionRecord.Vendor_1__r.Vendor_Code__c;
            String zVendorGroup = zSubscriptionRecord.Vendor_1__r.Vendor_Group__c;
              
            String zDirectSubscriptionNumber = zSubscriptionRecord.Name;        
            String zSubscriptionFrequency = zSubscriptionRecord.Frequency__c;
            Decimal zSubscriptionQty = zSubscriptionRecord.Qty__c;

            Decimal dRecipientNumber = zSubscriptionRecord.Recipient_Contact__r.Recipient_Number__c;
            
            String zRecipientName = zSubscriptionRecord.Recipient_Contact__r.Name;
            String zSalutation = zSubscriptionRecord.Recipient_Contact__r.Salutation;
            
            String zPostalCode = zSubscriptionRecord.Recipient_Contact__r.Address__r.Postal_Code__r.Name;   
            String zHouseBlockNumber = zSubscriptionRecord.Recipient_Contact__r.Address__r.Block_House_Number__c;
            String zStreetName = zSubscriptionRecord.Recipient_Contact__r.Address__r.Street_Name__c;
            String zBuildingName = zSubscriptionRecord.Recipient_Contact__r.Address__r.Building_Name__c;   
            String zLevelNumber = zSubscriptionRecord.Recipient_Contact__r.Address__r.Level_Number__c;   
            String zUnitNumber = zSubscriptionRecord.Recipient_Contact__r.Address__r.Unit_Number__c;
            
            String zSubscriptionStatus = zSubscriptionRecord.Zuora__Status__c;

            ID zSubscriptionRecipientId = zSubscriptionRecord.Recipient_Contact__r.Id;          
            ID zPackageID = zSubscriptionRecord.Main_Package_1__c;              
            
            Map<String, Date> mDateRecords = getTransactionDates(csRecord, zSubscriptionRecord, zRecordType,mOrderLineItemMap);
            String zCRSMContactNumber = (dRecipientNumber != null) ? dRecipientNumber.toPlainString() : null;
            DateTime dtLastModifiedDate = csRecord.LastModifiedDate;
            
            Date dSubscriptionStartDate = mDateRecords.get(Z_TRANS_START_DATE);             
            Date dSubscriptionEndDate = mDateRecords.get(Z_TRANS_END_DATE);             
            Date dEffectiveDate = mDateRecords.get(Z_TRANS_EFFECTIVE_DATE);                 
            
            Date dSubscriptionEndDate2 = zSubscriptionRecord.Zuora__SubscriptionEndDate__c;
            dSubscriptionEndDate2 = (dSubscriptionEndDate2 != null) ? dSubscriptionEndDate2.addDays(1) : DateUtility.convertDateFromYYYYMMDD(Z_CUSTOM_DEFAULT_END_DATE);
            
            boolean zPublicHolidayWeekdayInd = false;
            boolean zPublicHolidayWeekendInd = false;
            
            Decimal zTotalQuantity = 0;
            String zPublicationPattern = null;
            
        // Get Change Of Address Assignment
            String zNewVendorCode = null;
            String zNewVendorGroup = null;
            String zNewBlockHouseNumber = null;
            String zNewLevel = null;
            String zNewUnitNumber = null;
            String zNewStreetName = null;
            String zNewBuildingName = null;
            String zNewPostalCode = null;
            Date dtNewEffectiveDate = null;

            String zParseVendorGroup = isChangeOfVendor ? zChgVendorGroup : (isChangeOfAddress ? zNewVendorGroup : zVendorGroup);
            String zParseVendorCode = isChangeOfVendor ? zChgVendorCode : (isChangeOfAddress ? zNewVendorCode : zVendorCode);   
            
            String zVendorNumber = StringUtility.getVendor(zParseVendorGroup,zParseVendorCode);
            // START UD-2771 16-Sep-2015 Added by Raviteja - Applying Logic for Vendor Conversion
            String zVendorConversion = '';
            if(zSubscriptionRecord.Vendor_Conversion_1__c == True){
                zVendorConversion = 'Y';
            }
            // End UD-2771 16-Sep-2015 Added by Raviteja
            // Store Publication_Code__c, Published_Days__c, Public_Holiday_Weekday_Pub_Indicator and Public_Holiday_Weekend_Pub_Indicator__c values...
            String zPublishedDays = '';
            String zPublicationCode = '';
            String zPHeIndicator = INDICATOR_NO;
            String zPHdIndicator = INDICATOR_NO;
      
            if (mPackagePublications.containsKey(zPackageID)) {
                Set<Publication__c> publicationListData = new Set<Publication__c>();
                if (mPackagePublications.get(zPackageID) != null) {
                    publicationListData = mPackagePublications.get(zPackageID);
                }
                publicationListData = BT_CO_INT_Utilities.prodPubMapping(publicationListData, zProductCode, mapProdPub);//START/End UD-2691 23-Sep-2015 Added by Raviteja               
                for (Publication__c pRecord : publicationListData) {
                    if (pRecord != null && pRecord.Product_Family__c == mapProdCode2ProdFamily.get(zProductCode)) {
                        zPublicationCode = pRecord.Publication_Code__c;
                        zPublishedDays = StringUtility.getPublishedDays(zSubscriptionFrequency, pRecord.Published_Days__c); 
                        zPublicHolidayWeekdayInd = pRecord.Public_Holiday_Weekday_Pub_Indicator__c;
                        zPublicHolidayWeekendInd = pRecord.Public_Holiday_Weekend_Pub_Indicator__c;
                        zPHdIndicator = zPublicHolidayWeekdayInd ? INDICATOR_YES : INDICATOR_NO;
                        zPHeIndicator = zPublicHolidayWeekendInd ? INDICATOR_YES : INDICATOR_NO;

                        if (String.isNotBlank(zPublishedDays)) {
                            zPublicationPattern = zPublishedDays + zPHdIndicator;                                       
                            zTotalQuantity = Decimal.valueOf(zPublishedDays.replaceAll('[N]','').length()) * zSubscriptionQty;
                        }
 
                    // Validate the fields
                        zVALIDATION_CODE = StringUtility.validate(isChangeOfAddress ? zNewVendorCode : zVendorCode);                                                                            // Derive then validate VendorNumber ...
                        zVALIDATION_CODE += StringUtility.validate(isChangeOfAddress ? zNewBlockHouseNumber : zHouseBlockNumber);       // Validate House Block Number ...
                        zVALIDATION_CODE += StringUtility.validate(isChangeOfAddress ? zNewPostalCode : zPostalCode);                       // Validate Postal Code ...
                        zVALIDATION_CODE += StringUtility.validate(zPublicationPattern);                                                            // Validate zPublicationPattern ...
                        zVALIDATION_CODE += StringUtility.validate(zRecipientName);                                                                 // Validate Recipient Name ...
                        zVALIDATION_CODE += StringUtility.validate(zCRSMAccountNumber);                                                             // Validate CRSM Account Number ...
                        zVALIDATION_CODE += StringUtility.validate(zCRSMContactNumber);                                                             // Validate CRSM Contact Number ...
                        zVALIDATION_CODE += StringUtility.validate(zDirectSubscriptionNumber);                                                      // Validate CRSM Direct Subscription ID ...
                        zVALIDATION_CODE += StringUtility.validate(zIndicator);                                                                             // Validate The Indicator...
                        
                        //Override zValidation Code to Pass.  Moving validation checks to on-premise server and save to FAI file
                        zVALIDATION_CODE = '000000000';
                        
                        if (zRecordType.equalsIgnoreCase(STOP_SUBSCRIPTION)) {
                            zVALIDATION_CODE += StringUtility.validate(dEffectiveDate); 
                        } else {
                            zVALIDATION_CODE += '0';
                        }
                  
                    // Create Export-Data String ...
                        String zData = '';
                        zData += StringUtility.quoteReplaceStr(zAccountLegacyId) +',';                                                              // Subscriber Account 
                        zData += StringUtility.quoteReplaceStr(zRecipientLegacyId) +',';                                                            // Recipient Account 
                        zData += StringUtility.quoteReplaceStr(zPublicationCode) +',';                                                              // Publication Code 
                        zData += StringUtility.quoteReplaceStr(zPublicationTag) +',';                                                               // Publication Tag                          
                        zData += zSubscriptionQty +',';                                                                                         // Subscription Copies      
                        zData += dSubscriptionStartDate +',';                                                                                   // Subscription Start Date 
                        if (zRecordType.equalsIgnoreCase(STOP_SUBSCRIPTION)) {// Subscription Stop Date 
                            zData += dSubscriptionEndDate2 + ',';                                                                                // Use Zuora Subscription EndDate + 1 day
                        } else {
                            zData += dSubscriptionEndDate + ',';                                                                                    // Subscription Stop Date 
                        }
                        zData += StringUtility.quoteReplaceStr(zVendorNumber) +',';                                                                 // Vendor Number 
                        zData += StringUtility.quoteReplaceStr(zSingpostAddressId) +',';                                                            // Address ID
                        
                        zData += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewBlockHouseNumber : zHouseBlockNumber) +',';      // House-Block Number
                        zData += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewLevel : zLevelNumber) +',';                      // Level Number
                        zData += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewUnitNumber : zUnitNumber) +',';                  // Unit Number 
                        zData += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewPostalCode : zPostalCode) +',';                  // Postal Code 
                        zData += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewStreetName : zStreetName) +',';                  // Street Name 
                        zData += StringUtility.quoteReplaceStr(isChangeOfAddress ? zNewBuildingName : zBuildingName) +',';              // Building Name 
             
                        zData += StringUtility.quoteReplaceStr(zIndicator) +',';                            // Indicator 
                        zData += StringUtility.quoteReplaceStr(zPublicationPattern) +',';                   // Day of Week Pattern 
                        zData += StringUtility.quoteReplaceStr(zRecipientName) +',';                        // Recipient Name
                        zData += StringUtility.quoteReplaceStr(zCompanyName) +',';                          // Company Name 
                        zData += StringUtility.quoteReplaceStr(zSalutation) +',';                           // Salutation 
                        zData += StringUtility.quoteReplaceStr(zCRSMAccountNumber) +',';                    // CRSM Account ID;
                        zData += StringUtility.quoteReplaceStr(zCRSMContactNumber) +',';                    // CRSM Contact ID
                        zData += StringUtility.quoteReplaceStr(zDirectSubscriptionNumber) +',';             // CRSM Direct Subscription ID
                        zData += StringUtility.quoteReplaceStr(zSubGroup) +',';                             // CRSM Account Sub Group
                        zData += StringUtility.quoteReplaceStr(zPHeIndicator) +',';                         // Day of week pattern (PHe)

                        zData += StringUtility.quoteReplaceStr(isChangeOfAddress ? zHouseBlockNumber : null) +',';                          // Previous House/Block Number
                        zData += StringUtility.quoteReplaceStr(isChangeOfAddress ? zLevelNumber : null) +',';                               // Previous Level Number 
                        zData += StringUtility.quoteReplaceStr(isChangeOfAddress ? zUnitNumber : null) +',';                                // Previous Unit Number 
                        zData += StringUtility.quoteReplaceStr(isChangeOfAddress ? zPostalCode : null) +',';                                // Previous Postal Code
                        
                        // START UD-2771 16-Sep-2015 Added by Raviteja - Applying Logic for Vendor Conversion                                                         
                        //zData += ',';                     // >----- BLANK -----< Vendor Conversion 
                        zData += zVendorConversion +',';      //Vendor Conversion                                                                
                        // End  UD-2771 16-Sep-2015 Added by Raviteja
                        zData += dEffectiveDate +',';                                                           // Effective Date

                        if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE)) {
                             if (!exportDataSet.contains(zData)) {
                                  exportDataSet.add(zData);                           
                                  datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', '('+zRecordType+') '+zRecordId, zData, dtLastModifiedDate, datapoolList);
                             }
                        } else {
                             //Create a debug log / Interpret Validation String / Insert to Failed Pool
                             System.debug('zData : '+zData);
                             System.debug('zRecordId: '+zRecordId);
                             BT_CO_INT_Utilities.log(zData,zRecordId);
                             System.debug('zVALIDATION_CODE : '+zVALIDATION_CODE);
                             System.debug('errorMessageMap : '+errorMessageMap);
                             String zErrorMsg = '('+zRecordType+')'+BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, errorMessageMap);
                             System.debug('zErrorMsg : '+zErrorMsg);
                             if (zRecordType.equalsIgnoreCase('Stop_Subscription')&&zErrorMsg.indexOf('Effective Date')>0) {
                                //ignore the record...
                                System.debug(Logginglevel.INFO, 'HDS037DX: Ignored Stop Subscription Record ID ' + zRecordId);
                             } else {
                                datapoolListFailed = BT_CO_INT_Utilities.exportFailedDataItem(Z_INTERFACE_ID, 'Detail',  '('+zRecordType+') '+zRecordId, 
                                                             zErrorMsg, zVALIDATION_CODE, zData, DateTime.now(), datapoolListFailed);
                             }
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
            insert datapoolListFailed;
        } catch(Exception e) {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_' + Z_INTERFACE_ID + '_DailyVendorSubscription insert operation failed.');
        }
    }
  
    global void finish(Database.BatchableContext BC) {
       System.debug('Finish Method Start');
        //Send callout
        if(!Test.isRunningTest()){
            BT_CO_INT_Utilities.sendCallOutMessage(Z_INTERFACE_ID);
        System.debug('sendCallOutMessage');
        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(Z_INTERFACE_ID);
        System.debug('BT_AU_BATCHRUNREQUEST_UpdateInfo');
        }
        System.debug('Finish Method Completed');
    }
     
    private boolean isChangeOfSubscription(String zRecordType) {
        return (zRecordType != null && zRecordType.trim().equalsIgnoreCase(CHANGE_OF_SUBSCRIPTION));
    }
    
    private boolean isChangeOfAddress(String zRecordType, String zSubRecordType) {
        return (zRecordType != null && zRecordType.trim().equalsIgnoreCase(CHANGE_OF_ADDRESS) && zSubRecordType != null && !zSubRecordType.trim().equalsIgnoreCase(CHANGE_OF_VENDOR_TYPE));
    }
    
    private boolean isChangeOfVendor(String zRecordType) {
        return (zRecordType != null && zRecordType.trim().equalsIgnoreCase(CHANGE_OF_VENDOR));
    }       

    private boolean isRenewalOfSubscription(String zRecordType) {
        return (zRecordType != null && zRecordType.trim().equalsIgnoreCase(RENEWAL_OF_SUBSCRIPTION));       
    }
    
    private String getIndicator(String zRecordType) {
        String zIndicator = null;

        if (zRecordType != null) {
            if (zRecordType.equalsIgnoreCase(CHANGE_OF_ADDRESS)
            || zRecordType.equalsIgnoreCase(CHANGE_OF_VENDOR)) {    
                zIndicator = Z_IND_CHANGE;
            } else if (zRecordType.equalsIgnoreCase(STOP_SUBSCRIPTION)) {
                zIndicator = Z_IND_UPDATE;
            } else if (zRecordType.equalsIgnoreCase(START_SUBSCRIPTION)) {
                zIndicator = Z_IND_ADD;
            } else if (zRecordType.equalsIgnoreCase(CHANGE_OF_SUBSCRIPTION)) {
                zIndicator = Z_IND_ADD;
            } else if (zRecordType.equalsIgnoreCase(RENEWAL_OF_SUBSCRIPTION)) {
                zIndicator = Z_IND_ADD;
            }           
        }         
        return zIndicator;
    }
    
    private Map<String, Date> getTransactionDates(Case_Subscription__c csRecord, Zuora__Subscription__c zSubscription, String zRecordType,Map<String, Order_Line_Item__c> mOrderLineItemMap) {
        Map<String, Date> zResultDateMap = new Map<String, Date>();
        if (csRecord != null) {
            Date dSubscriptionStartDate = processDate(zSubscription.Zuora__SubscriptionStartDate__c, null, 1);                          
            Date dSubscriptionEndDate = processDate(zSubscription.Zuora__SubscriptionEndDate__c, getDefaultEndDate(), 1);                   
            Date dEffectiveDate = processDate(csRecord.Case__r.Effective_Date__c, null, 1);
            ID orderID = csRecord.Case__r.Order__r.ID;
            ID subscriptionID = zSubscription.ID;
            String strOrderSubsKey = orderID + '-' + subscriptionID;
            System.debug('HDS037DX: orderItemKey2 ' + strOrderSubsKey);

            if (dSubscriptionEndDate == null) {
                dSubscriptionEndDate = getDefaultEndDate();
            } else {
                dSubscriptionEndDate = dSubscriptionEndDate.addDays(1);
            }
            if (zRecordType != null) {
                // Store the 'Subscription Start Date' in the Map ...
                zResultDateMap.put(Z_TRANS_START_DATE, dSubscriptionStartDate);     
                zResultDateMap.put(Z_TRANS_EFFECTIVE_DATE, dEffectiveDate); 

                // Store the 'Effective Date' in the Map ....
                if (zRecordType.equalsIgnoreCase(START_SUBSCRIPTION)) {
                    zResultDateMap.put(Z_TRANS_EFFECTIVE_DATE, dSubscriptionStartDate); 
                } 

                // Store the 'Subscription End Date' in the Map ...
                if (zRecordType.equalsIgnoreCase(STOP_SUBSCRIPTION)) {

                    // Store the possible 'End Dates' in a List ...
                    // List<Date> dateList = new List<Date>();
                    // dateList.add(dSubscriptionEndDate);
                    // dateList.add((Date) csRecord.Case__r.Stop_Request_Date__c);

                    Date dEffectiveStopDate = null;
                    Date dStopDate = null;
                    if (mOrderLineItemMap.containsKey(strOrderSubsKey)) {
                        Order_Line_Item__c orderItem = mOrderLineItemMap.get(strOrderSubsKey);
                        dEffectiveStopDate = orderItem.Stop_Request_Date__c;
                        dStopDate = dEffectiveStopDate != null ? dEffectiveStopDate.addDays(-1) : Date.Today(); 
                        System.debug('HDS037DX: orderLineItemMap exist ' + strOrderSubsKey);
                        System.debug('HDS037DX: dEffectiveStopDate ' + dEffectiveStopDate);
                        System.debug('HDS037DX: dStopDate ' + dStopDate);
                    } 
                    
                    //dEffectiveStopDate = (Date) csRecord.Case__r.Stop_Request_Date__c;
                    //Date dStopDate = dEffectiveStopDate != null ? dEffectiveStopDate.addDays(1) : Date.Today().addDays(1); 

                    // Process the 'List' to get the 'Earliest Date' (i.e. EARLIEST_DATE >= SYSDATE) ...                   

                    zResultDateMap.put(Z_TRANS_END_DATE, dStopDate);
                    zResultDateMap.put(Z_TRANS_EFFECTIVE_DATE, dEffectiveStopDate); 
                } else {
                    zResultDateMap.put(Z_TRANS_END_DATE, dSubscriptionEndDate); 
                } 
            }
        }
        return zResultDateMap;
    }    
    
    private Date processDate(Date d, Date dtOverrideDate, Integer iOffsetDays) {
        Date dResult = null;
        if (d != null) {
            dResult = d;
        } else {
            if (dtOverrideDate != null) {
                dResult = dtOverrideDate;
            } else {
                dResult = getDateToday(iOffsetDays);
            }
        }
        return dResult;
    }
    
    private Date getDateToday(Integer iOffsetDays) {
        Date d = Date.today();
        if (iOffsetDays != null) {
            try {
                if (batchRunDateX==null) batchRunDateX = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID);  
                Date dBatchRunDate = convertBRD_To_Date(batchRunDateX);      
                d = dBatchRunDate.addDays(iOffsetDays);     
            } catch (Exception e) {
                Date dNew = Date.today();
                d = dNew.addDays(iOffsetDays);  
            }
        }
        return d;       
    }   

    
    private Integer getDiff(Date d) {
        Integer iResult = -1;
        if (d != null) {
            iResult = Date.today().daysBetween(d);
        }
        return iResult;
    }
    
    private Date getDefaultEndDate() {
        Date dResult = null;
        try {
            dResult = Date.valueOf(DEFATUL_STOP_DATE);
        } catch (Exception e) {
            dResult = getDateToday(1);
        }
        return dResult;
    }
    
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
    
    private Set<String> getCustomSetting(String zInputStr) {
        Set<String> zResultSet = new Set<String>();
        try {
            if (zInputStr != null) {
                zResultSet = StringUtility.getValues(StringUtility.getCustomSetting(zInputStr));
            }                       
        } catch (Exception e) {
            zResultSet = new Set<String>();
        }
        return zResultSet;
    }
    // END UD-1198 - Michael Francisco 2015/05/12 
}