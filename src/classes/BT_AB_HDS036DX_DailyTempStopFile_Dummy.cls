/*
 * Class Name: BT_AB_HDS036DX_DailyTempStopFile_Dummy
 * Dummy Class
 */

global class BT_AB_HDS036DX_DailyTempStopFile_Dummy implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful

{
   
    global final String Z_INTERFACE_ID = 'HDS036DX';
    
  
    global final String Z_CUTOFF_DATE_TIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';    

    global final String CASE_TEMP_STOP_TYPE_NEW = 'New';
    global final String CASE_TEMP_STOP_TYPE_CREATE = 'Create';  
    global final String CASE_TEMP_STOP_TYPE_CANCEL = 'Cancel';
    global final String CASE_TEMP_STOP_TYPE_UPDATE = 'Update';

    global static final String ERROR_CODE_EXCEPTION = '1311';
    global static final String ERROR_CODE_NONPUB = '1701';
    global final String CASE_STATUS_CLOSED = 'Closed';
    global final String CHANGE_OF_ADDRESS = 'Change_of_Address';
    
    global Set<String> exportDataSet = new Set<String>();       
    
    global Map<String, Set<String>> mapProdPub = new Map<String, Set<String>>(); 
    global static String batchRunDateX = null;
    global Set<Id> lastmodifiedbyIds = New Set<Id>();
    Date StartDate;
    Date Enddate;
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    
    global BT_AB_HDS036DX_DailyTempStopFile_Dummy(){
    }
    
    global BT_AB_HDS036DX_DailyTempStopFile_Dummy(Set<Id> lastmodifiedIds, Date Start_Date, Date End_date){
        lastmodifiedbyIds.addAll(lastmodifiedIds);  
        StartDate = Start_Date;
        Enddate = End_date;
        System.debug(' Start_Date : '+Start_Date);
        System.debug(' End_date : '+End_date);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
       
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID);            
       
        //DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(batchRunDate,'Default Timestamp');         
        System.debug('Enddate : '+Enddate);
        System.debug('String Enddate : '+String.ValueOf(Enddate));
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(String.ValueOf(Enddate),'Default Timestamp');         
       
        DateTime cutOffStart = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(String.ValueOf(StartDate),'Default Timestamp');    
        DateTime dtLastBatchRunDate = DateUtility.getOverrideDate(Z_INTERFACE_ID); 
        DateTime newCutOffStart = null;
       
        //Date dtEffStart = Date.valueOf(batchRunDate);
        //Date dtEffEnd = dtEffStart.addDays(1);    

        Date dtEffStart = Date.valueOf(StartDate);
        Date dtEffEnd = Date.valueOf(Enddate);  
 
        if (dtLastBatchRunDate>cutOffStart) {
            newCutOffStart = cutOffStart;
        } else {
            Integer minutesDiff = Integer.valueOf((dtLastBatchRunDate.getTime() - cutOffStart.getTime())/1000/60);
            newCutOffStart = cutOffStart.addMinutes(minutesDiff);           
        }
         mapProdPub = BT_CO_INT_Utilities.prodPubMapping();   //START/End UD-2691 23-Sep-2015 Added by Raviteja       
        // Prepare the list of cases that this interface will use
        String customRecordTypes = StringUtility.getCustomSetting('HDS036DX Case Record Types');
        Set<String> caseRecordTypesSet = new Set<String>();
        
        //Temp_Stop_Subscription|Case_Temp Stop|Temp Stop
        caseRecordTypesSet = StringUtility.getValues(customRecordTypes);
    
        List<String> caseStatusList = new List<String>();
        caseStatusList.add('Closed');
        
        //START UD-2145 HotFix 02-Sep-2015 Added by Raviteja - Applying logic for missing time
        System.debug('dtLastBatchRunDate : '+dtLastBatchRunDate);
        DateTime lastBatchruntime;
        for(BT_CO_Batch_Run_Request__c brr : [SELECT CreatedDate,Id FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = 'HDS036DX' AND End_Time__c != Null 
                                                                                                            AND Batch_Run_Date__c < :date.newinstance(dtLastBatchRunDate.year(), dtLastBatchRunDate.month(), dtLastBatchRunDate.day()) ORDER BY CreatedDate DESC limit 1]){
            System.debug(' brr : '+brr);
            lastBatchruntime = Datetime.valueof(brr.CreatedDate); 
            System.debug('lastBatchruntime : '+lastBatchruntime);
        }
        
        //End UD-2145 HotFix 02-Sep-2015 Added by Raviteja
        
        //START UD-2768 Renz 2015-09-29 New logic to get the new cut off date for previous run
        
        /*
        Date dBatchRunDate = convertBRD_To_Date(batchRunDate);
        DateTime dtPrevBatchRunDate = DateUtility.getOverrideDate(Z_INTERFACE_ID,dBatchRunDate);
        Date dPrevBatchRunDate = dtPrevBatchRunDate.date();
        */
        DateTime dStartDate2 = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(String.ValueOf(StartDate),'Default Timestamp');
        /*
        DateTime dStartDate2 = null;
        if (dPrevBatchRunDate<=dBatchRunDate&&dtPrevBatchRunDate<newCutOffStart) {
            dStartDate2 = dtPrevBatchRunDate;
        } else {
            dStartDate2 = newCutOffStart;
        } 
        */
        //END UD-2768 Renz 2015-09-29 New logic to get the new cut off date for previous run
        
        //Get all Case Vendor Subscriptions that are temp stops for the day
        String query = '';
        query += ' SELECT  ';
        query += '      ID, ';
        query += '      Subscription__r.Zuora__Account__r.Account_Legacy_Id__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Contact_Legacy_Id__c, ';
        query += '      Subscription__r.Product_Code__c,  ';
        query += '      Subscription__r.Pub_Tag__c,  ';
        query += '      Subscription__r.Qty__c,  ';
        query += '      Subscription__r.Zuora__SubscriptionStartDate__c,  ';
        query += '      Subscription__r.Zuora__SubscriptionEndDate__c,  ';
        query += '      Subscription__r.Vendor_1__r.Vendor_Code__c,  ';
        query += '      Subscription__r.Vendor_1__r.Vendor_Group__c,  ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name, ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c, ';                
        query += '      Subscription__r.Recipient_Contact__r.FirstName, ';
        query += '      Subscription__r.Recipient_Contact__r.LastName, ';
        query += '      Subscription__r.Zuora__Account__r.Company_Name__c, ';
        query += '      Subscription__r.Recipient_Contact__r.Salutation, ';
        query += '      Subscription__r.Main_Package_1__c, ';
        query += '      Subscription__r.ID, ';
        query += '      Case__r.ID, ';
        query += '      Case__r.LastModifiedDate, ';          
        query += '      Case__r.Temp_Stop_Type__c, ';
        query += '      Case__r.Temp_Stop__c, ';
        query += '      Case__r.Temp_Stop__r.ID, ';
        query += '      Case__r.Temp_Stop__r.Restart_Date__c, ';
        query += '      Case__r.Temp_Stop__r.Temp_Stop_Date__c, ';
        query += '      Case__r.Temp_Stop__r.LastModifiedDate, ';
        query += '      Case__r.Temp_Stop__r.Cancelled__c, ';
        query += '      Case__r.Temp_Stop_Date__c, ';
        query += '      Case__r.Restart_Date__c, ';
        query += '      Subscription__r.Zuora__Account__r.Account_Auto_Number__c, ';        
        query += '      Subscription__r.Recipient_Contact__r.Recipient_Number__c, ';        
        query += '      Subscription__r.Name, ';                                            
        query += '      Subscription__r.Frequency__c ';
        query += ' FROM ';
        query += '      Case_Subscription__c     ';     
        query += ' WHERE ';
        query += '      Case__r.RecordType.DeveloperName IN :caseRecordTypesSet ';
        query += '      AND LastModifiedById  NOT IN :lastmodifiedbyIds ';
        query += '      AND Subscription__r.Delivered_By_1__c = \'Vendor\' ';     
        query += '     AND Case__r.Status IN :caseStatusList ';
        query += '      AND ( ';
        query += '              ( ';
        
       
        query += '                  Case__r.LastModifiedDate > ' + dStartDate2.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);
        query += '              AND Case__r.LastModifiedDate <= ' + cutOffEnd.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);
        query += '              AND Subscription__r.Zuora__SubscriptionStartDate__c <= :dtEffStart ';
        query += '              ) OR (';
        query += '                  Case__r.Temp_Stop__r.LastModifiedDate > ' + dStartDate2.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);
        query += '              AND Case__r.Temp_Stop__r.LastModifiedDate <= ' + cutOffEnd.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);
        query += '              AND Subscription__r.Zuora__SubscriptionStartDate__c <= :dtEffStart ';
       
        query += '              ) OR (';
        query += '                Subscription__r.Zuora__SubscriptionStartDate__c = :dtEffEnd ';
        query += '              )';
       
        query += '      ) ';
        query += ' ORDER BY ';
        query += '    Subscription__r.Zuora__Account__r.Account_Auto_Number__c, ';      // CRSM Account ID
        query += '    Subscription__r.Recipient_Contact__r.Recipient_Number__c, ';      // CRSM Contact Number
        query += '    Subscription__r.Name, ';                                                      // Subscription Name
        query += '    Subscription__r.Product_Code__c, ';                                       // Use Product Code in place of Publication Code
        query += '    Case__r.LastModifiedDate, ';
        query += '    Case__r.Temp_Stop__r.Cancelled__c '; 
                
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
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();        //START/END 2015-10-12 Renino Niefes UD-2599 datapoolList shouldn't be a global variable
        List<BA_INT_DATA_FAILED_POOL__c> datapoolFailedList = new List<BA_INT_DATA_FAILED_POOL__c>();   //START/END 2015-12-18 Renino Niefes (D-4133) Hot Fix: reset the datapoolFailedList for each execute
        List<Case_Subscription__c> caseDirectSubsList = new List<Case_Subscription__c>();
        List<ID> lSubscriptionIDs = new List<ID>();
        
        for(SObject record : scope) {
            Case_Subscription__c csRecord = (Case_Subscription__c) record;
            if (csRecord != null) {
                caseDirectSubsList.add(csRecord);
            }
            
            ID subscriptionId = csRecord.Subscription__r.Id;
            if (subscriptionId!=null) {
                lSubscriptionIDs.add(subscriptionId);
                System.debug(Logginglevel.INFO,'[Adding to lSubscriptionIDs]:'+subscriptionId);
            }
            
        }           
        
        //Convert that into a Map so that you could search the value using Case__r.Id
        List<ID> lPackageIDs = new List<ID>();
        for(Case_Subscription__c csRecord : caseDirectSubsList) {
            if (csRecord != null) {     
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

        // Create a Map of Field Validation Error messages based on INTERFACE_ID ...
        Map<Decimal, String> mErrorMessageMap = BT_CO_INT_Utilities.getErrorMessageMap(Z_INTERFACE_ID);
        
        
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(Z_INTERFACE_ID);     
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
        
        for (Case_Subscription__c csRecord : caseDirectSubsList) {
            if (csRecord != null) { 
                ID zRecordId = csRecord.Id;
                String zVALIDATION_CODE = '0';
                String zExceptionTracer = '';
                try {
                    ID subscriptionId = csRecord.Subscription__r.Id;
                    String zAccountId = String.valueOf(csRecord.Subscription__r.Zuora__Account__r.Account_Legacy_Id__c);
                    // 6/1/2016 KRITHIKA DHARMARAJAN START UD-3465 CHANGES HAVE BEEN REVERTED AND CONFIGURED IN DATABASE
                    String zRecipientId = String.valueOf(csRecord.Subscription__r.Recipient_Contact__r.Contact_Legacy_Id__c); 
                    // 6/1/2016 KRITHIKA DHARMARAJAN END UD-3465 CHANGES HAVE BEEN REVERTED AND CONFIGURED IN DATABASE
                    String zPublicationTag = String.valueOf(csRecord.Subscription__r.Pub_Tag__c);
                    String zFrequency = csRecord.Subscription__r.Frequency__c;
                    
                    String zVendorGroup = csRecord.Subscription__r.Vendor_1__r.Vendor_Group__c;
                    String zVendorCode = csRecord.Subscription__r.Vendor_1__r.Vendor_Code__c;   
                    String zVendor = StringUtility.getVendor(zVendorGroup, zVendorCode);

                    Date dtSubscriptionStartDate = csRecord.Subscription__r.Zuora__SubscriptionStartDate__c;
                    Date dtSubscriptionEndDate = csRecord.Subscription__r.Zuora__SubscriptionEndDate__c;
                    
                    String zLevelNumber = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c;
                    String zUnitNumber = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c;
                    String zHouseBlockNumber = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c;
                    String zBuildingName = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c; 
                    String zStreetName = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c;
                    String zPostalCode = csRecord.Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name;
                    
                    String zRecipientFirstName = csRecord.Subscription__r.Recipient_Contact__r.FirstName;
                    String zRecipientLastName = csRecord.Subscription__r.Recipient_Contact__r.LastName;
                    String zRecipientName = null;

                    String zTempStopType = csRecord.Case__r.Temp_Stop_Type__c;
                    boolean bTempStopIsCancelled = csRecord.Case__r.Temp_Stop__r.Cancelled__c;
                    String zIndicatorField = getIndicatorField(zTempStopType,bTempStopIsCancelled);
                    
                    Date dtCaseTempStopDate = csRecord.Case__r.Temp_Stop__r.Temp_Stop_Date__c;
                    if (dtCaseTempStopDate == null) {
                        dtCaseTempStopDate = csRecord.Case__r.Temp_Stop_Date__c;
                    }
                    
                    Date dtCaseRestartDate = csRecord.Case__r.Temp_Stop__r.Restart_Date__c;
                    if (dtCaseRestartDate == null) {
                        dtCaseRestartDate = csRecord.Case__r.Restart_Date__c;
                    }
                    
                    DateTime dtLastModifiedDate = csRecord.Case__r.LastModifiedDate;
                    
                    String zCRSMAccountNumber = csRecord.Subscription__r.Zuora__Account__r.Account_Auto_Number__c;
                    String zCRSMContactNumber = csRecord.Subscription__r.Recipient_Contact__r.Recipient_Number__c != null ? 
                                                    csRecord.Subscription__r.Recipient_Contact__r.Recipient_Number__c.toPlainString() : null;
                    String zSubscriptionName = csRecord.Subscription__r.Name;
                    String zPHeIndicator = ''; 
                    
                    String zCompanyName = csRecord.Subscription__r.Zuora__Account__r.Company_Name__c;
                    String zSalutation = csRecord.Subscription__r.Recipient_Contact__r.Salutation;
                    String prodCode = csRecord.Subscription__r.product_code__c; //START/End UD-2691 23-Sep-2015 Added by Raviteja     
                    
                    
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
                                zVendorGroup = aRecord.Vendor__r.Vendor_Group__c;
                                zVendor = StringUtility.getVendor(zVendorGroup, zVendorCode);   //START/END UD-2599 2015-10-15 Renz  Hotfix
                                if (zVendorGroup == null) zVendorGroup = 'V';
                            } else {
                                System.debug(Logginglevel.INFO,'[overriding Address fields ]: Address Assignment record is null. ');
                            }
                        } else {
                            System.debug(Logginglevel.INFO,'[overriding Address fields ]: Case ID does not have Address Assignment ' + coaCaseID);
                        }
                    } else {
                        System.debug(Logginglevel.INFO,'[overriding Address fields ]: Subscription ID does not have COA ' + subscriptionId);
                    }
                    
                    
                    zExceptionTracer += '--- Check 1 ';
                    // Perform preliminary processing ...
                    zBuildingName = (zBuildingName != null) ? zBuildingName.trim() : zBuildingName;
                    if (zBuildingName != null && zBuildingName.length() == 1) {
                        zBuildingName = zBuildingName.replaceAll('[-]','');
                    }
                    if (dtSubscriptionEndDate == null) {
                        dtSubscriptionEndDate = DateUtility.getDefaultEndDate();
                    } 
                    if (String.isNotBlank(zRecipientFirstName) || String.isNotBlank(zRecipientLastName))  {
                        zRecipientName = zRecipientFirstName + ' ' + zRecipientLastName;
                    }
                                
                    zExceptionTracer += '--- Check 2 ';
                    ID pkgRecordID = csRecord.Subscription__r.Main_Package_1__c;
                    if (pkgRecordID != null && mPackagePublications != null && mPackagePublications.containsKey(pkgRecordID)) {
                        
                        //Get The publication set from productPublicationMap
                        Set<Publication__c> publicationListData = new Set<Publication__c>();
                        if (pkgRecordID != null && mPackagePublications.get(pkgRecordID) != null) {
                            publicationListData = mPackagePublications.get(pkgRecordID);
                        } 
                        publicationListData = BT_CO_INT_Utilities.prodPubMapping(publicationListData, prodCode, mapProdPub);//START/End UD-2691 23-Sep-2015 Added by Raviteja     
                        zExceptionTracer += '--- Check 3 ';
                        if (publicationListData != null && publicationListData.size() > 0) {
                            for (Publication__c pRecord : publicationListData) {  
                                if (pRecord != null) {
                                    zExceptionTracer += '--- Check 3.1 ';
                                
                                // Prepare the data ...
                                    String zPublicationCode = String.valueOf(pRecord.Publication_Code__c);
                                    String zDayOfWeekPattern = '';
                                    
                                //Subscription Copies 
                                    Integer iDirectQty=0;
                                    Integer iDirectSubCopies=0;
                                    Integer directMon=0;
                                    Integer directTue=0;
                                    Integer directWed=0;
                                    Integer directThu=0;
                                    Integer directFri=0;
                                    Integer directSat=0;
                                    Integer directSun=0;
                                    Integer directPHd=0;
                                    Integer directPHe=0;
                                    
                                    if (csRecord.Subscription__r.Qty__c != null) {
                                        iDirectQty= Integer.valueOf(csRecord.Subscription__r.Qty__c);                           
                                    }
                                    
                                //Default or null, use Publication's frequency pattern
                                    if ( zFrequency == null || zFrequency.equalsIgnoreCase('default')) {
                                        String strFreq = pRecord.Published_Days__c;
                                        Integer x = 0;
                                        if (strFreq!=null) {
                                            while (x<strFreq.length()) {
                                                if (strFreq.substring(x,x+1).equalsIgnoreCase('y')) {
                                                    iDirectSubCopies += iDirectQty;
                                                    if (x==0) directMon = iDirectQty;
                                                    if (x==1) directTue = iDirectQty;
                                                    if (x==2) directWed = iDirectQty;
                                                    if (x==3) directThu = iDirectQty;
                                                    if (x==4) directFri = iDirectQty;
                                                    if (x==5) directSat = iDirectQty;
                                                    if (x==6) directSun = iDirectQty;
                                                }
                                                x++;
                                            }
                                        }
                                        if (pRecord.Public_Holiday_Weekday_Pub_Indicator__c==true) {
                                            directPHd = iDirectQty;
                                        }
                                        if (pRecord.Public_Holiday_Weekend_Pub_Indicator__c==true) {
                                            directPHe = iDirectQty;
                                        }                                           
                                    }
                                        
                                    if ( zFrequency != null && zFrequency.equalsIgnoreCase('Mon - Fri') ) { //Use the subscription's frequency  
                                        iDirectSubCopies = iDirectQty * 5;
                                        directMon = iDirectQty;
                                        directTue = iDirectQty;
                                        directWed = iDirectQty;
                                        directThu = iDirectQty;
                                        directFri = iDirectQty;
                                        directSat = 0;
                                        directSun = 0;
                                        directPHd = 0;
                                        directPHe = 0;
                                    }

                                    if ( zFrequency != null && zFrequency.equalsIgnoreCase('Mon - Sat') ) { //Use the subscription's frequency
                                        iDirectSubCopies = iDirectQty * 6;
                                        directMon = iDirectQty;
                                        directTue = iDirectQty;
                                        directWed = iDirectQty;
                                        directThu = iDirectQty;
                                        directFri = iDirectQty;
                                        directSat = iDirectQty;
                                        directSun = 0;
                                        directPHd = 0;
                                        directPHe = 0;                  
                                    }
                                    if ( zFrequency != null && zFrequency.equalsIgnoreCase('Sat - Sun') ) { //Use the subscription's frequency
                                        iDirectSubCopies = iDirectQty * 2;
                                        directMon = 0;
                                        directTue = 0;
                                        directWed = 0;
                                        directThu = 0;
                                        directFri = 0;
                                        directSat = iDirectQty;
                                        directSun = iDirectQty;
                                        directPHd = 0;
                                        directPHe = 0;                  
                                    }
                                    
                                //Day of week pattern
                                    if (directMon>0) zDayOfWeekPattern += 'Y'; else zDayOfWeekPattern += 'N';
                                    if (directTue>0) zDayOfWeekPattern += 'Y'; else zDayOfWeekPattern += 'N';
                                    if (directWed>0) zDayOfWeekPattern += 'Y'; else zDayOfWeekPattern += 'N';
                                    if (directThu>0) zDayOfWeekPattern += 'Y'; else zDayOfWeekPattern += 'N';
                                    if (directFri>0) zDayOfWeekPattern += 'Y'; else zDayOfWeekPattern += 'N';
                                    if (directSat>0) zDayOfWeekPattern += 'Y'; else zDayOfWeekPattern += 'N';
                                    if (directSun>0) zDayOfWeekPattern += 'Y'; else zDayOfWeekPattern += 'N';
                                    if (directPHd>0) zDayOfWeekPattern += 'Y'; else zDayOfWeekPattern += 'N';           
                                    
                                //Day of week pattern (PHe)
                                    zPHeIndicator = directPHe > 0 ? 'Y' : 'N';                                      
                                    
                                    zExceptionTracer += '--- Check 3.2 ';
                                    Date dEffectiveIssueDate = BT_CO_INT_Utilities.getEffectiveIssueDate(dtCaseTempStopDate, dtCaseRestartDate, zDayOfWeekPattern);
                                    String zEffectiveIssueDateCheck = (dEffectiveIssueDate == null) ? '1' : '0';
                                    
                                // Validation Rules ...
                                    zVALIDATION_CODE += StringUtility.validate(zVendorCode);                            // Validate Vendor Code ...
                                    zVALIDATION_CODE += StringUtility.validate(zHouseBlockNumber);                  // Validate House Block Number ...
                                    zVALIDATION_CODE += StringUtility.validate(zPostalCode);                            // Validate Postal Code ...
                                    zVALIDATION_CODE += StringUtility.validate(zRecipientName);                     // Validate Recipient Name ...
                                    zVALIDATION_CODE += StringUtility.validate(iDirectSubCopies);                   // Validate Subscription Copies ...
                                    zVALIDATION_CODE += StringUtility.validate(dtSubscriptionStartDate);            // Validate Subscription Start Date ... 
                                    zVALIDATION_CODE += StringUtility.validate(dtCaseTempStopDate);             // Validate Temp Stop Date ...
                                    zVALIDATION_CODE += StringUtility.validate(dtCaseRestartDate);                  // Validate TempStop Restart Date ...
                                    zVALIDATION_CODE += StringUtility.validate(zCRSMAccountNumber);             // Validate CRSM Account Number ...
                                    zVALIDATION_CODE += StringUtility.validate(zCRSMContactNumber);             // Validate CRSM Contact Number ...
                                    zVALIDATION_CODE += StringUtility.validate(zSubscriptionName);                  // Validate Subscription Name ...
                                
                                //Override zValidation Code to Pass.  Moving validation checks to on-premise server and save to FAI file
                                    zVALIDATION_CODE = '000000000000';
                        
                        
                                // Prepare Export-Data String ...
                                    String zData = '';
                                    zData += StringUtility.quoteReplaceStr(zAccountId) + ',';                                           // Subscriber Account 
                                    zData += StringUtility.quoteReplaceStr(zRecipientId) + ',';                                         // Recipient Account 
                                    zData += StringUtility.quoteReplaceStr(zPublicationCode) + ',';                                     // Publication Code 
                                    zData += StringUtility.quoteReplaceStr(zPublicationTag) + ',';                                  // Publication Tag 
                                    zData += StringUtility.quoteReplaceStr(String.valueOf(iDirectQty)) + ',';                       // Subscription Copies 
                                    zData += StringUtility.quoteReplaceStr(String.valueOf(dtSubscriptionStartDate)) + ',';  // Subscription Start Date 
                                    zData += StringUtility.quoteReplaceStr(String.valueOf(dtSubscriptionEndDate)) + ',';        // Subscription Stop Date 
                                    zData += StringUtility.quoteReplaceStr(zVendor) + ',';                                              // Vendor Number 
                                    zData += '0000,';                                                                                               // Address ID 
                                    zData += StringUtility.quoteReplaceStr(zHouseBlockNumber) + ',';                                    // House/Block Number 
                                    zData += StringUtility.quoteReplaceStr(zLevelNumber) + ',';                                         // Level Number 
                                    zData += StringUtility.quoteReplaceStr(zUnitNumber) + ',';                                          // Unit Number 
                                    zData += StringUtility.quoteReplaceStr(zPostalCode) + ',';                                          // Postal Code 
                                    zData += StringUtility.quoteReplaceStr(zStreetName) + ',';                                          // Street Name 
                                    zData += StringUtility.quoteReplaceStr(zBuildingName) +',';                                         // Building Name 
                                    zData += StringUtility.quoteReplaceStr(zDayOfWeekPattern) + ',';                                    // Day of week pattern 
                                    zData += StringUtility.quoteReplaceStr(zRecipientName) + ',';                                       // Recipient Name 
                                    zData += StringUtility.quoteReplaceStr(zCompanyName) + ',';                                         // Company Name 
                                    zData += StringUtility.quoteReplaceStr(zSalutation) + ',';                                          // Salutation 
                                    zData += StringUtility.quoteReplaceStr(String.valueOf(dtCaseTempStopDate)) + ',';           // TempStop Stop Date 
                                    zData += StringUtility.quoteReplaceStr(String.valueOf(dtCaseRestartDate)) + ',';            // TempStop Restart Date 
                                    zData += StringUtility.quoteReplaceStr(zCRSMAccountNumber) + ',';                               // CRSM Account ID
                                    zData += StringUtility.quoteReplaceStr(zCRSMContactNumber) + ',';                               // CRSM Contact ID
                                    zData += StringUtility.quoteReplaceStr(zSubscriptionName) + ',';                                    // CRSM Subscription ID
                                    zData += StringUtility.quoteReplaceStr(zPHeIndicator) + ',';                                        // Day of week pattern (PHe)
                                    zData += StringUtility.quoteReplaceStr(zIndicatorField) + ',';                                  // Indicator Field  
                                    
                                    zExceptionTracer += '--- Check 3.3 ';
                                    if (BT_CO_INT_Utilities.checkValidation(zEffectiveIssueDateCheck)) {
                                        if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE)) {    
                                            if (BT_CO_INT_Utilities.exportDataItemDuplicateCheck(zData, exportDataSet)) {
                                                exportDataSet.add(zData);
                                                datapoolList = BT_CO_INT_Utilities.exportDataItem(Z_INTERFACE_ID, 'Detail', zRecordID, zData, dtLastModifiedDate, datapoolList);                                            
                                            }               
                                        } else {
                                            BT_CO_INT_Utilities.log('EXPORT-FAILED : ',zRecordID, zVALIDATION_CODE, zData); 

                                            String zErrorReason = BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, mErrorMessageMap);
                                            String zErrMsg = 'EXPORT-FAILED: ' + zErrorReason;
                                            String zErrorCode = '('+BT_CO_INT_Utilities.convert(zVALIDATION_CODE)+') | '+zVALIDATION_CODE;

                                            logFailedRecord(zRecordID, zErrMsg, zErrorCode, zData, dtLastModifiedDate,datapoolFailedList);  //START/END 2015-12-18 D-4133 Renino Niefes Hot fix: add datapoolFailedList as parameter instead of global variable                
                                        }                                       
                                    } else {
                                        String zReason = mErrorMessageMap.get(Integer.valueOf(ERROR_CODE_NONPUB));
                                        String zErrorReason = zReason.replace('$1',zPublicationCode)
                                                        .replace('$2',String.valueOf(dtCaseTempStopDate))
                                                        .replace('$3',String.valueOf(dtCaseRestartDate));
                                        
                                        String zErrMsg = 'EXPORT-FAILED: ' + zErrorReason;
                                        String zErrCode = '('+BT_CO_INT_Utilities.convert(ERROR_CODE_NONPUB)+') | '+ERROR_CODE_NONPUB;
                                        
                                        logFailedRecord(zRecordID, zErrMsg, zErrCode, zData, dtLastModifiedDate,datapoolFailedList);      //START/END 2015-12-18 D-4133 Renino Niefes Hot fix: add datapoolFailedList as parameter instead of global variable                                                         
                                    }
                                    zVALIDATION_CODE = '';
                                    zExceptionTracer += '--- Check 3.4 ';                                   
                                } 
                            }
                        } 
                    }
                } catch (Exception e) {
                    String zErrMsg = 'CASE-EXCEPTION: '+e.getMessage()+' Trace: '+zExceptionTracer;
                    BT_CO_INT_Utilities.log(zErrMsg, zRecordID);
                    logFailedRecord(zRecordID, zErrMsg, ERROR_CODE_EXCEPTION, '', Date.today(),datapoolFailedList);  //START/END 2015-12-18 Renino Niefes D-4133 Hot fix: add datapoolFailedList as parameter instead of global variable                  
                }
            }
        }
    
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try {
            insert datapoolList;
            upsert datapoolFailedList;      //START/STOP UD-2599 2015-10-12 Renino Niefes    
        } catch(Exception e) {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_'+Z_INTERFACE_ID+'_DailyTempStopFile insert operation failed.');
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
      
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(Z_INTERFACE_ID);
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
    
    private String getIndicatorField(String zTempStopType, boolean isCancelled) {
        String zResult = 'A';
        if (String.isNotBlank(zTempStopType)) {
            if (zTempStopType.equalsIgnoreCase(CASE_TEMP_STOP_TYPE_CANCEL) || isCancelled) {
                zResult = 'D';
            } 
        }
        return zResult;
    }    
   
    private void logFailedRecord(String zRecordID, String zErrMsg, String zErrCode, String zData, DateTime dtLastModifiedDate,List<BA_INT_DATA_FAILED_POOL__c> datapoolFailedList) {
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
   
}