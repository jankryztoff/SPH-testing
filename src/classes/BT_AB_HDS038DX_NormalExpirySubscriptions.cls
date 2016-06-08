/*
 * Class Name: BT_AB_HDS038DX_NormalExpirySubscriptions
 * @author: Renino Q. Niefes
 * Date: 05/13/2015
 * Project/Requirement: SPH Integration - HDS038DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for HDS038DX batch job. 
 * 
 *          2015/05/13 Renino Niefes                - Adding normal expiry subscriptions into HDS038DX
 *          2015/05/18 Renino Niefes                - added failed data pool and used reusable codes from BT_CO_INT_Utilities class
 *          2015/05/19 Renino Niefes                - additional updates (code review)
 *          2015/07/28 Renino Niefes                - UD-2141 Added another critera in main query.  Only Subscription Type = PUBLICATION must be in the file
 *          2015/07/31 Renino Niefes                - Hot Fix: Override zValidation Code to Pass.  Moving validation checks to on-premise server and save to FAI file
 *          2015/08/14 Renino Niefes                - UD-2132 Add another condition when creating export data.  Use Product family to match the current record.  If it matches, then create a new record
 *          2015/09/10 Renino Niefes                - Hot Fix: UD-2661 (SIR provided for retrofitting) Remove the Zuora_Status__c != Cancelled criteria in the main query to pick up all expiring subs due for tomorrow
 *          2015/09/14 Renino Niefes                - Hot Fix: UD-2661 (SIR provided for retrofitting) Override zCheck variable as well.  Record gets filtered out by this validation check
 *          2015/09/22 Raviteja Kumar               - UD-2884 - HotFix 17-Aug-2015 Added by Raviteja - Removing Stop subscription from scope
 *          2015/09/22 Renino Niefes                - UD-2895 - Hotfix Removing COS subs from scope as well
 *          2015/09/23 Renino Niefes                - UD-2885 - Hotfix in UAT2, add another condition.  Zuora Start date must be less than or equal to dtEffStart
 *          2015/09/23 Raviteja Kumar               - UD-2691 Added Database.Stateful
 *          2015/10/01 Renino Niefes                - UD-2980 add Subscription ID  
 *          2015/11/11 Renino Niefes                - D-3914 Company_Name__c is the new field for "Attention To" parameter
 *          2016/01/28 Renino Niefes                - UD-3848 Add only vendor delivered subscriptions for direct subscribers 
 */

//START UD-2691 23-Sep-2015 Added by Raviteja  - Added Database.Stateful
//global class BT_AB_HDS038DX_NormalExpirySubscriptions implements Database.Batchable<sObject>,Database.AllowsCallouts
global class BT_AB_HDS038DX_NormalExpirySubscriptions implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful
//End UD-2691 23-Sep-2015 Added by Raviteja
{
    global final String Z_INTERFACE_ID = 'HDS038DX';
    
    /* ========= ZUORA Subscription Status ========= */
    global final String Z_ZUORA_SUBSCRIPTION_CANCELLED = 'Cancelled';
    global static final String ERROR_CODE_ZDATA_FAILURE = '1921';
    global static final String ERROR_CODE_EXCEPTION = '1311';
    global static final String ERROR_CODE_NONPUB = '1701';
    global final String DEFAULT_END_DATE = '20991231';
    global final String Z_SUBSCRIPTION_TYPE_PUB = 'PUBLICATION';    //UD-2141
    global Map<String, Set<String>> mapProdPub = new Map<String, Set<String>>(); //START/End UD-2691 23-Sep-2015 Added by Raviteja  
    /* @description 
    * 
    * @param BatchableContext which is a predefined parameter
    * @return Database.QueryLocator
    */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID); 
        Date dtEffStart = Date.valueOf(brd);
        //dtEffStart = Date.NewInstance(2015,09,16);//Raviteja -18Sep2015 added name filter for testing.
        Date dtEffEnd = dtEffStart.addDays(1);
        mapProdPub = BT_CO_INT_Utilities.prodPubMapping();   //START/End UD-2691 23-Sep-2015 Added by Raviteja
        String  query = ' SELECT ';
                query += '  ID, ';
                query += '  Zuora__Account__r.Account_Legacy_Id__c, ';
                query += '  Zuora__Account__r.Account_Auto_Number__c, ';
                query += '  Zuora__Account__r.Id, ';
                query += '  Zuora__Account__r.Name, ';
                query += '  Zuora__Account__r.Company_Name__c, ';
                query += '  Zuora__Account__r.Sub_Group__c, ';
                query += '  Recipient_Contact__r.Address__r.Block_House_Number__c, ';
                query += '  Recipient_Contact__r.Address__r.Level_Number__c, ';
                query += '  Recipient_Contact__r.Address__r.Unit_Number__c, ';
                query += '  Recipient_Contact__r.Address__r.Postal_Code__r.Name, ';
                query += '  Recipient_Contact__r.Address__r.Street_Name__c, ';
                query += '  Recipient_Contact__r.Address__r.Building_Name__c, ';
                query += '  Recipient_Contact__r.Contact_Legacy_Id__c, ';
                query += '  Recipient_Contact__r.Id, ';
                query += '  Recipient_Contact__r.Name, ';
                query += '  Recipient_Contact__r.Recipient_Number__c, ';
                query += '  Recipient_Contact__r.Salutation, ';
                query += '  Recipient_Contact__r.Company_Name__c, ';    //START/END D-3914 2015-11-11 Renz Company_Name__c is the new attention to name
                query += '  Name, ';
                query += '  Qty__c, ';
                query += '  Pub_Tag__c, ';
                query += '  Frequency__c, ';
                query += '  Product_Code__c, ';
                query += '  Zuora__SubscriptionStartDate__c, ';
                query += '  Zuora__SubscriptionEndDate__c, ';
                query += '  Effective_Start_Date__c, ';
                query += '  Effective_End_Date__c, ';
                query += '  Vendor_1__r.Id, ';
                query += '  Vendor_1__r.Vendor_Group__c, ';
                query += '  Vendor_1__r.Vendor_Code__c, ';
                query += '  LastModifiedDate, ';
                query += '  Zuora__Status__c, ';
                query += '  Sponsored_Indicator__c, ';
                query += '  Main_Package_1__c ';
                query += ' FROM Zuora__Subscription__c ';
                query += ' WHERE ';
                query += '      Zuora__SubscriptionEndDate__c = :dtEffStart ';
                query += '      AND Delivered_By_1__c = \'Vendor\' ';     //START/END 2016/01/28 Renino Niefes        UD-3848   
                //START 2015/09/10 Renino Niefes                - UD-2661 Remove the Zuora_Status__c != Cancelled criteria in the main query to pick up all expiring subs due for tomorrow
                //query += '      AND Name = \'BA-S01710546\' '; //Raviteja -18Sep2015 added name filter for testing.                
                //query += '      AND Zuora__Status__c != :Z_ZUORA_SUBSCRIPTION_CANCELLED ';
                //END 2015/09/10 Renino Niefes                - UD-2661
                query += '      AND Subscription_Type__c = :Z_SUBSCRIPTION_TYPE_PUB ';          //UD-2141
                query += '      AND Zuora__SubscriptionStartDate__c <= :dtEffStart ';       //START/END UD-2885 Renino Niefes - this ensures that only valid subscriptions get interfaced
                query += ' ORDER BY Zuora__Account__r.Account_Auto_Number__c ASC, Product_Code__c ASC ';

        return Database.getQueryLocator(query); 
    }
    
    global List<BA_INT_DATA_FAILED_POOL__c> datapoolListFailed = new List<BA_INT_DATA_FAILED_POOL__c>();

  /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
    * 
    * @param BC a BatchableContext which is a predefined parameter
    * @param scope a list of sObjects from the initial database query
    * @return void
    */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    { 
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        
        Map<Decimal,String> mErrorMessageMap = BT_CO_INT_Utilities.getErrorMessageMap(Z_INTERFACE_ID);
        
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID); 
        Date dtEffStart = Date.valueOf(brd);
        //dtEffStart = Date.NewInstance(2015,09,16);//Raviteja -18Sep2015 added name filter for testing.
        Date dtEffEnd = dtEffStart.addDays(1);
   
        // START UD-2132 2015-08-14 Renino Niefes
        Map<String, String> mapProdCode2ProdFamily = new Map<String, String>();
        List<String> lstProdCodes = new List<String>();
        List<ID> lPackageIDs = new List<ID>();
        //START UD-2884 - HotFix 17-Aug-2015 Added by Raviteja - Removing Stop subscription from scope    
        Set<ID> lsSubIds = new Set<ID>();
        Set<ID> lsStopSubIds = new Set<ID>();
        Set<ID> lsStopCaseIds = new Set<ID>();
        //End UD-2884 - HotFix 17-Aug-2015 Added by Raviteja - Removing Stop subscription from scope 
        
        //START UD-2895 Renino Niefes 2015-09-22 Removing COS subscription from scope
        Set<ID> lsCOSSubIds = new Set<ID>();                
        //END UD-2895 Renino Niefes 2015-09-22 Removing COS subscription from scope
        for(sObject record : scope)
        {
            Zuora__Subscription__c subRecord = (Zuora__Subscription__c) record;
            ID mainPackageId = subRecord.Main_Package_1__c;
            if (mainPackageId!=null) {
                lPackageIDs.add(mainPackageId);
            }
            
            if(subRecord.Product_Code__c != null){
                lstProdCodes.add(subRecord.Product_Code__c);
            }   
            lsSubIds.add(subRecord.id);  //START-End UD-2884 - HotFix 17-Aug-2015 Added by Raviteja - Removing Stop subscription from scope      
        }
        
        //START UD-2884 - HotFix 17-Aug-2015 Added by Raviteja - Removing Stop subscription from scope
        //List<Case_Subscription__c> lstCaseSubs = new List<Case_Subscription__c>(); 
        //lstCaseSubs = [Select Id, Name, Subscription__c from Case_Subscription__c where Subscription__c in :lsSubIds AND Case__r.RecordType.DeveloperName = 'Stop_Subscription' AND Case__r.Stop_Request_Date__c = :dtEffEnd];
        System.debug('lsSubIds : '+lsSubIds);
        for(Order_Line_Item__c oli : [Select Id, Name,Stop_Request_Date__c,Case__c from Order_Line_Item__c where Case__r.RecordType.DeveloperName = 'Stop_Subscription' AND Stop_Request_Date__c = :dtEffEnd]){
            lsStopCaseIds.add(oli.Case__c);
        }     
        for(Case_Subscription__c cs : [Select Id, Name, Subscription__c from Case_Subscription__c where Subscription__c in :lsSubIds AND Case__c in :lsStopCaseIds]){
            lsStopSubIds.add(cs.Subscription__c);
        }
        System.debug('lsStopSubIds : '+lsStopSubIds);        
        //End UD-2884 - HotFix 17-Aug-2015 Added by Raviteja - Removing Stop subscription from scope
        
        //START UD-2895 Renino Niefes 2015-09-22 Removing COS subscription from scope
        for(Case cs : [SELECT Subscription_Name__r.ID FROM Case WHERE RecordType.DeveloperName = 'Change_Of_Subscription' and (Subscription_Name__r.Zuora__SubscriptionEndDate__c = :dtEffStart OR Subscription_Name__r.Zuora__SubscriptionEndDate__c = :dtEffEnd) ]){
            lsCOSSubIds.add(cs.Subscription_Name__r.ID);
        }
        System.debug(LoggingLevel.INFO,lsCOSSubIds);        
        //END UD-2895 Renino Niefes 2015-09-22 Removing COS subscription from scope
        
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
    
        Set<String> exportDataSet = new Set<String>();      
        List<String> exportDataList = new List<String>();

        for(sObject record : scope)
        {
            Zuora__Subscription__c subRecord = (Zuora__Subscription__c) record;
            ID zRecordId = subRecord.Id;
            System.debug('zRecordId 1 : '+zRecordId);
            //START UD-2884 - HotFix 17-Aug-2015 Added by Raviteja - Removing Stop subscription from scope
            if(lsStopSubIds.contains(zRecordId))
                continue;
                
            System.debug('zRecordId 2 : '+zRecordId);    
            //End UD-2884 - HotFix 17-Aug-2015 Added by Raviteja
            
            //START UD-2895 - Hotfix 2015-09-22 Renino Niefes - Removing COS Subscription from scope
            if(lsCOSSubIds.contains(zRecordId))
                continue;
            System.debug(LoggingLevel.INFO, 'zRecordId COS : '+zRecordId);    
            //END UD-2895 - Hotfix 2015-09-22 Renino Niefes - Removing COS Subscription from scope
            String zSingpostAddressId = '0000';
            
            String zAccountLegacyId = subRecord.Zuora__Account__r.Account_Legacy_Id__c;
            String zAccountNumber = subRecord.Zuora__Account__r.Account_Auto_Number__c;
            String zAccountID = subRecord.Zuora__Account__r.Id;
            String zAccountName = subRecord.Zuora__Account__r.Name;
            String zAccountCompany = subRecord.Zuora__Account__r.Company_Name__c;
            String zAccountSubGroup = subRecord.Zuora__Account__r.Sub_Group__c;
            String zAccountBlockHouseNo = subRecord.Recipient_Contact__r.Address__r.Block_House_Number__c;
            String zAccountLevelNo= subRecord.Recipient_Contact__r.Address__r.Level_Number__c;
            String zAccountUnitNo = subRecord.Recipient_Contact__r.Address__r.Unit_Number__c;
            String zAccountPostalCode = subRecord.Recipient_Contact__r.Address__r.Postal_Code__r.Name;
            String zAccountStreetName = subRecord.Recipient_Contact__r.Address__r.Street_Name__c;
            String zAccountBuildingName = subRecord.Recipient_Contact__r.Address__r.Building_Name__c;
            String zContactLegacyId = subRecord.Recipient_Contact__r.Contact_Legacy_Id__c;
            String zContactId = subRecord.Recipient_Contact__r.Id;
            String zContactName = subRecord.Recipient_Contact__r.Name;
            //START D-2854 2015-05-04 Renz use ToPlainString to prevent scientific notation
            String zContactNumber = null;
            if (subRecord.Recipient_Contact__r.Recipient_Number__c!=null) {
                zContactNumber = String.valueOf(subRecord.Recipient_Contact__r.Recipient_Number__c.toPlainString());  
            }
            //END D-2854 2015-05-04 Renz use ToPlainString to prevent scientific notation
                        
            //START D-3914 2015-11-11 Renz Company_Name__c is the new attention to name
            //String zContactSalutation = subRecord.Recipient_Contact__r.Salutation;
            String zContactSalutation = subRecord.Recipient_Contact__r.Company_Name__c;    
            //END D-3914 2015-11-11 Renz Company_Name__c is the new attention to name
            
            String zSubsName = subRecord.Name;
            Decimal zSubsQty = subRecord.Qty__c;
            String zSubsPubTag = subRecord.Pub_Tag__c;
            String zSubsFrequency = subRecord.Frequency__c;
            String zSubsProductCode = subRecord.Product_Code__c;
            Date zSubsStartDate = subRecord.Zuora__SubscriptionStartDate__c;
            Date zSubsEndDate = subRecord.Zuora__SubscriptionEndDate__c;
            Date zSubsEffectiveStartDate = subRecord.Effective_Start_Date__c;
            Date zSubsEffectiveEndDate = subRecord.Effective_End_Date__c;
            String zVendorId = subRecord.Vendor_1__r.Id;
            String zVendorGroup = subRecord.Vendor_1__r.Vendor_Group__c;
            String zVendorCode = subRecord.Vendor_1__r.Vendor_Code__c;
            DateTime zLastModifiedDate = subRecord.LastModifiedDate;
            String zStatus = subRecord.Zuora__Status__c;
            String zTransactionType = 'Stop';  //Default value for normal expiry
            String zTransactionDesc = 'Expired';  //Default value for normal expiry
            String zSponsoredIndicator = subRecord.Sponsored_Indicator__c;
            ID pkgRecordID = subRecord.Main_Package_1__c;
            String zCrsmSubscriptionId = subRecord.Name; //START/END  UD-2980 2015-10-01 Renino Niefes add Subscription ID
            
            if (zVendorGroup==null||zVendorGroup.trim().equalsIgnoreCase('')) {
                zVendorGroup = 'V';
            }
            
            if (zSponsoredIndicator==null||zSponsoredIndicator.trim().equalsIgnoreCase('')) {
                zSponsoredIndicator = 'N';
            }
            
            if (pkgRecordID != null && mPackagePublications.containsKey(pkgRecordID)) {
                Set<Publication__c> publicationListData = new Set<Publication__c>();
                if (pkgRecordID != null && mPackagePublications.get(pkgRecordID) != null) {
                        publicationListData = mPackagePublications.get(pkgRecordID);
                } 
                publicationListData = BT_CO_INT_Utilities.prodPubMapping(publicationListData, zSubsProductCode, mapProdPub);//START/End UD-2691 23-Sep-2015 Added by Raviteja 
                String zVALIDATION_CODE = '';
                Decimal zSubscriptionQty = subRecord.Qty__c;
                String zDeliveryFrequency = '';
                String zDayOfWeekPattern = '';
                String zPublishedDays = '';
                String zPublicationCode = '';
                String zPHeIndicator = 'N';
                String zPHdIndicator = 'N';
                boolean zPublicHolidayWeekdayInd = false;
                boolean zPublicHolidayWeekendInd = false;
                    
                String zPattern = null;
                String zMon = StringUtility.formatValue(0,'0', 'left', 4);
                String zTue = StringUtility.formatValue(0,'0', 'left', 4);
                String zWed = StringUtility.formatValue(0,'0', 'left', 4);
                String zThu = StringUtility.formatValue(0,'0', 'left', 4);
                String zFri = StringUtility.formatValue(0,'0', 'left', 4);
                String zSat = StringUtility.formatValue(0,'0', 'left', 4);
                String zSun = StringUtility.formatValue(0,'0', 'left', 4);
                String zPHd = StringUtility.formatValue(0,'0', 'left', 4);
                String zPHe = StringUtility.formatValue(0,'0', 'left', 4);
                        
                for (Publication__c rec : publicationListData) {
                    if (rec != null && rec.Product_Family__c == mapProdCode2ProdFamily.get(zSubsProductCode)) {  //UD-2132 start/end  added conditions to filter out listdata
                        zPublishedDays = StringUtility.getPublishedDays(zSubsFrequency, rec.Published_Days__c); 
                        zPublicationCode = rec.Publication_Code__c;
                        zPublicHolidayWeekdayInd = rec.Public_Holiday_Weekday_Pub_Indicator__c;
                        zPublicHolidayWeekendInd = rec.Public_Holiday_Weekend_Pub_Indicator__c;
                        if (zPublicHolidayWeekdayInd) {
                            zPHdIndicator = 'Y';
                        } else {
                            zPHdIndicator = 'N';
                        }
                        if (zPublicHolidayWeekendInd) {
                            zPHeIndicator = 'Y';
                        } else {
                            zPHeIndicator = 'N';
                        }
                        if (zPublishedDays != null && zPublishedDays.length() > 0) {
                            Integer iQty = 0;
                            try {
                                iQty = Integer.valueOf(String.valueOf(zSubsQty));
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

                        Date dTomorrow = Date.Today().addDays(1);
                        
                        Date dStart = zSubsEndDate != null ? zSubsEndDate.addDays(1) : (dtEffStart != null ? dtEffStart.addDays(1) : dTomorrow);    
                        Date dEnd = DateUtility.convertDateFromYYYYMMDD(DEFAULT_END_DATE);
                        Date zEffectiveIssueDate = DateUtility.getFirstPublicationDate(dStart,dEnd,zPattern);     
                        
                        String zCheck = (zEffectiveIssueDate != null && dTomorrow.daysBetween(zEffectiveIssueDate) >= 0) ? '0' : '1';
                    
                        //Validation
                        zVALIDATION_CODE = StringUtility.validate(zVendorCode);                 // Check 'Vendor Number' Data
                        zVALIDATION_CODE += StringUtility.validate(zAccountBlockHouseNo);   // Check 'House/Block Number' Data ... 
                        zVALIDATION_CODE += StringUtility.validate(zAccountPostalCode);     // Check 'Postal Code' Data ...
                        zVALIDATION_CODE += StringUtility.validate(zDayOfWeekPattern);          // CHeck 'Day of Week Pattern' Data ...                     
                        zVALIDATION_CODE += StringUtility.validate(zContactName);               // Check 'Recipient Name' Data ...                      
                        zVALIDATION_CODE += StringUtility.validate(zAccountNumber);             // Check 'Account Number' Data ...
                        zVALIDATION_CODE += StringUtility.validate(zContactNumber);             // Check 'Recipient Number' Data ...                    
                        zVALIDATION_CODE += StringUtility.validate(zPublicationCode);       // Check 'Publication Code' Data ...                        
                        zVALIDATION_CODE += StringUtility.validate(zSubsEndDate);               // Check 'Effective Issue Date' Data ...                                                
                        zVALIDATION_CODE += '0';//StringUtility.validate(zAccountLevelNo);  // Check 'Level Number' Data ...                        
                        zVALIDATION_CODE += '0';//StringUtility.validate(zAccountUnitNo);       // Check 'Unit Number' Data ...                     
                        zVALIDATION_CODE += StringUtility.validate(zAccountStreetName);         // Check 'Street Name' Data ...  
                        zVALIDATION_CODE += StringUtility.validate(zTransactionType);           // Check 'Transaction Type'
                        zVALIDATION_CODE += StringUtility.validate(zTransactionDesc);           // Check 'Transaction Desc' Data ... 
                        zVALIDATION_CODE += '0';                                                            // Check The Indicator...   (Doesnt apply here)                                         
                        
                        //Override zValidation Code to Pass.  Moving validation checks to on-premise server and save to FAI file
                        zVALIDATION_CODE = '000000000000000';
                        zCheck = '0'; //START/END 2015/09/14 Renz - Hot Fix: UD-2661 Override zCheck variable as well.  Record gets filtered out by this validation check
                        
                        // Create zData string ... (HDS038DX)
                        String zData = '';
                        zData += StringUtility.quoteReplaceStr(zVendorGroup) +',';                      // Customer Group (Vendor Group)                        
                        zData += StringUtility.quoteReplaceStr(zVendorCode) +',';                       // Vendor Number                        
                        zData += StringUtility.quoteReplaceStr(zTransactionType) +',';                  // Transaction Type                         
                        zData += StringUtility.quoteReplaceStr(zTransactionDesc) +',';                  // Transaction Description                      
                        zData += StringUtility.quoteReplaceStr(zAccountBlockHouseNo) +',';              // Block Number                     
                        zData += StringUtility.quoteReplaceStr(zAccountLevelNo) +',';                   // Level Number                         
                        zData += StringUtility.quoteReplaceStr(zAccountUnitNo) +',';                    // Unit Number
                        zData += StringUtility.quoteReplaceStr(zAccountPostalCode) +',';                // Postal Code                                              
                        zData += StringUtility.quoteReplaceStr(zAccountStreetName) +',';                // Street Name 
                        zData += StringUtility.quoteReplaceStr(zAccountBuildingName) +',';              // Building Name 
                        zData += StringUtility.quoteReplaceStr(zPublicationCode) +',';                  // Publication Code                         
                        zData += StringUtility.quoteReplaceStr(String.valueOf(zSubsQty)) +',';          // Subscription Copies                      
                        zData += StringUtility.quoteReplaceStr(String.valueOf(dStart)) +',';        // Effective Date 
                        zData += StringUtility.quoteReplaceStr(String.valueOf(zEffectiveIssueDate)) +',';       // Effective Issue 
                        zData += 'null,';                                                               // Restart Date 
                        
                        zData += StringUtility.quoteReplaceStr(zDeliveryFrequency) +',';                // Delivery Frequency                       
                        zData += StringUtility.quoteReplaceStr(zAccountLegacyId) +',';                  // Subscriber Account 
                        zData += StringUtility.quoteReplaceStr(zContactLegacyId) +',';                  // Recipient Account 
                        zData += StringUtility.quoteReplaceStr(zContactName) +',';                      // Recipient Name 
                        zData += StringUtility.quoteReplaceStr(zContactSalutation) +',';                // Recipient Attention To 
                        
                        zData += 'null,';   // Route Sys    ---> IGNORED FIELD
                        zData += ',';       // Route Number ---> IGNORED FIELD
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
                        zData += StringUtility.quoteReplaceStr(zSubsProductCode) +',';                      // Product Code 
                        zData += StringUtility.quoteReplaceStr(zAccountNumber) +',';                // CRSM Account ID
                        zData += StringUtility.quoteReplaceStr(zContactNumber) +',';                // CRSM Contact ID
                        zData += StringUtility.quoteReplaceStr(zPHeIndicator) +',';                     // Day of week pattern (PHe)
                        zData += StringUtility.quoteReplaceStr(zCrsmSubscriptionId) +',';               //START/END  UD-2980 2015-10-01 Renino Niefes add Subscription ID

                        if (BT_CO_INT_Utilities.checkValidation(zCheck)) {                      
                            if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE)) {
                                if (!exportDataSet.contains(zData)) {
                                    datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', zRecordId, zData, DateTime.now(), datapoolList);
                                }
                                exportDataSet.add(zData);
                            } else {
                                //Create a debug log
                                BT_CO_INT_Utilities.log(zData,zRecordId);
                                
                                //Interpret the validation string
                                String zErrorMsg = '(Normal Expiry)'+BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, mErrorMessageMap);                           
                                
                                addFailedRecord(zRecordId,zErrorMsg,zVALIDATION_CODE,zData, zLastModifiedDate);

                            }
                        } else {
                            String zReason = mErrorMessageMap.get(Integer.valueOf(ERROR_CODE_NONPUB));
                            String zErrorReason = zReason.replace('$1',zPublicationCode)
                                            .replace('$2',String.valueOf(dStart))
                                            .replace('$3',String.valueOf(dEnd));
                            String zErrMsg = '(Normal Expiry) EXPORT-FAILED: ' + zErrorReason;
                            String zErrCode = '('+BT_CO_INT_Utilities.convert(ERROR_CODE_NONPUB)+') | '+ERROR_CODE_NONPUB;
                            
                            addFailedRecord(zRecordID, zErrMsg, zErrCode, zData, zLastModifiedDate);
                        }   
                        
                        
                        zVALIDATION_CODE = '';
                    } 
                }
            }
        }
        

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
            BT_CO_INT_Utilities.log('BT_AB_' + Z_INTERFACE_ID + '_DailyVendorSubscription insert operation failed.' + e.getMessage());
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
        BT_AB_HDS038DX_ChangeOfAddress callOutJob = new BT_AB_HDS038DX_ChangeOfAddress();
        Database.executeBatch(callOutJob);  
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
    //END 2015/03/30 UD-0624 Michael Francisco
}