/*
 * Class Name: BT_AB_DIR094DX_VendorPerformanceDirect
 * @author: Renino Niefes
 * Date: 05/26/2015
 * Project/Requirement: SPH Integration - DIR094DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for DIR094DX batch job. Used together with BT_AS_DIR094DX_VendorPerformanceInfo Schedulable
 * 
 * History: 2015/05/26 Renino Niefes rewritten the code
 * History: 2015/12/03 Renino Niefes D-4012 Add 2 more criteria in the main query.  Only vendor chargeable cases should be in the file
 */

//START UD-2691 23-Sep-2015 Added by Raviteja  - Added Database.Stateful
//global class BT_AB_DIR094DX_VendorPerformanceDirect implements Database.Batchable<sObject>,Database.AllowsCallouts
global class BT_AB_DIR094DX_VendorPerformanceDirect implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful
//End UD-2691 23-Sep-2015 Added by Raviteja
{
    global final String interfaceId = 'DIR094DX';
    global final String Z_CUSTOM_CASE_STATUS = 'Closed';
    global final String Z_CUSTOM_CASE_SUB_STATUS = 'Rejected';
    global final String Z_CUTOFF_DATE_TIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    global Map<String, Set<String>> mapProdPub = new Map<String, Set<String>>(); //START/End UD-2691 23-Sep-2015 Added by Raviteja
     
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //START 1 December 2015 D-4003 Kevin Evasco - Transferred data purge to a dedicated batch
        /*
        List<BT_CO_DIR_VendorPerformance__c> stagingList = [SELECT Id FROM BT_CO_DIR_VendorPerformance__c];
        delete stagingList;

        List<BT_CO_DIR_VendorPerformanceMaster__c> stagingMasterList = [SELECT Id FROM BT_CO_DIR_VendorPerformanceMaster__c];
        delete stagingMasterList;
        */
        //END 1 December 2015 D-4003 Kevin Evasco - Transferred data purge to a dedicated batch
        
        mapProdPub = BT_CO_INT_Utilities.prodPubMapping(); //START/End UD-2691 23-Sep-2015 Added by Raviteja       
        List<String> caseRecordTypesList = new List<String>();
        caseRecordTypesList.add('Complaint_Newspaper');
        caseRecordTypesList.add('Complaint_Magazine');
        //caseRecordTypesList.add('Start_Subscription'); //Temporary for testing purposes only
        
        List<String> caseSubCategList = new List<String>();
        caseSubCategList.add('Miscellaneous');      
        caseSubCategList.add('Late Delivery');
        caseSubCategList.add('Magazine Late Delivery');
        caseSubCategList.add('Magazine Non Delivery');
        caseSubCategList.add('Missing Inserts');
        caseSubCategList.add('Non Delivery');
        caseSubCategList.add('Non-Delivery');
        caseSubCategList.add('Short Delivery');
        caseSubCategList.add('Torn / Wet Papers');
        caseSubCategList.add('Wrong Delivery Location');
        caseSubCategList.add('Wrong Papers Delivered');
        caseSubCategList.add('Non-Delivery, notified date > 3 days from pub date');
        //caseSubCategList.add('Non-Delivery');
        caseSubCategList.add('Non-Start');
        caseSubCategList.add('Non-Start (Temp-Stop)');
        caseSubCategList.add('Non-Stop');
        caseSubCategList.add('Non-Stop (Temp Stop)');
        //caseSubCategList.add('Start Subscription'); //Temporary for testing purposes only
        //START 15 December 2015 D-4103 Kevin Evasco - added new sub categories     
        caseSubCategList.add('Non Start');
        caseSubCategList.add('Non Start Temp-Stop');
        //END 15 December 2015 D-4103 Kevin Evasco - added new sub categories
        

        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId); 
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_ToMonthEnd(batchRunDate);
        DateTime cutOffStart = DateUtility.convertDateFromYYYY_MM_DD_ToMonthStart(batchRunDate);           
        //START 1 December 2015 D-4003 Kevin Evasco - User Input Date Range
        for(Vendor_Performance__c vendorPerfRecord : [select From_Date__c,To_Date__c from Vendor_Performance__c order by LastModifiedDate desc limit 1]){
            cutOffStart = vendorPerfRecord.From_Date__c;
            cutOffEnd =  vendorPerfRecord.To_Date__c;
        }
        //END 1 December 2015 D-4003 Kevin Evasco - User Input Date Range

        String query = ' SELECT ID, Case__r.ID, ';
        query += '          Case__r.AccountId, ';
        query += '          Case__r.CaseNumber, ';
        query += '          Case__r.Status, ';
        query += '          Case__r.RecordType.DeveloperName, ';
        query += '          Case__r.Account_Record_Type__c, ';
        query += '          Case__r.Sub_Category__c, ';
        query += '          Subscription__r.Main_Package_1__c, ';
        query += '          Subscription__r.product_code__c, '; //START/End UD-2691 23-Sep-2015 Added by Raviteja
        query += '          Subscription__r.Vendor_1__r.Vendor_Group__c, ';
        query += '          Subscription__r.Vendor_1__r.Vendor_Code__c, ';
        query += '          Subscription__r.Frequency__c, Complaint_From__c, Complaint_To__c, '; //START/END D-4012 2015-12-09 Renz  Added 2 criterias
        query += '          Subscription__r.ID ';
        query += '          FROM Case_Subscription__c ';
        query += '          WHERE Case__r.Status  = :Z_CUSTOM_CASE_STATUS ';
        query += '          AND Case__r.Sub_Status__c <> :Z_CUSTOM_CASE_SUB_STATUS ';
        query += '          AND Case__r.RecordType.DeveloperName IN :caseRecordTypesList ';
        query += '          AND Case__r.Sub_Category__c IN :caseSubCategList ';
        query += '          AND Case__r.CreatedDate >=  ' + cutOffStart.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);
        query += '          AND Case__r.CreatedDate <=  ' + cutOffEnd.formatGmt(Z_CUTOFF_DATE_TIME_FORMAT);
        query += '          AND (Case__r.Vendor_Chargeable_Courier__c = TRUE OR Case__r.Vendor_Chargeable_Paper__c = TRUE) ';  //START/END D-4012 2015-12-03 Renz  Added 2 criterias
        return Database.getQueryLocator(query);
    }
    

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {           
        List<BT_CO_DIR_VendorPerformanceMaster__c> masterList = new List<BT_CO_DIR_VendorPerformanceMaster__c>();
        List<BT_CO_DIR_VendorPerformance__c> detailList = new List<BT_CO_DIR_VendorPerformance__c>();
        List<BA_INT_DATA_FAILED_POOL__c> datapoolListFailed = new List<BA_INT_DATA_FAILED_POOL__c>();
        List<ID> lPackageIDs = new List<ID>();

        Set<String> vendorCodeSet = new Set<String>();
        Set<String> allVendorCodeSet = new Set<String>(); //START/END 1 December 2015 D-4003 Kevin Evasco - 1 master record per vendor
        
        Map<Decimal,String> errorMessageMap = BT_CO_INT_Utilities.getErrorMessageMap(interfaceId);
        Map<String, ID> masterMap = new Map<String, ID>();
        
        Set<String> validPubCodeSet = new Set<String>();
        validPubCodeSet.add('ST');
        validPubCodeSet.add('SUT');
        validPubCodeSet.add('ZB');
        validPubCodeSet.add('BH');
        validPubCodeSet.add('BM');
        validPubCodeSet.add('BT');
        validPubCodeSet.add('TM');
        validPubCodeSet.add('TMS');
        
        //START 1 December 2015 D-4003 Kevin Evasco - 1 master record per vendor
        for(sObject record : scope) { 
            Case_Subscription__c subRecord = (Case_Subscription__c) record;
            String zVendorCode = subRecord.Subscription__r.Vendor_1__r.Vendor_Code__c;
            allVendorCodeSet.add(zVendorCode);
        }
        
        List<BT_CO_DIR_VendorPerformanceMaster__c> existingMasterRecList = [SELECT Id, Vendor_Code__c FROM BT_CO_DIR_VendorPerformanceMaster__c WHERE Vendor_Code__c = :allVendorCodeSet];
        
        for(BT_CO_DIR_VendorPerformanceMaster__c existingMasterRecElem : existingMasterRecList) {
            masterMap.put(existingMasterRecElem.Vendor_Code__c, existingMasterRecElem.ID);
        }
        //END 1 December 2015 D-4003 Kevin Evasco - 1 master record per vendor
        
        //prepare the mainPackageList and master list
        for(sObject record : scope) {                       
            Case_Subscription__c subRecord = (Case_Subscription__c) record;
            ID mainPackageId = subRecord.Subscription__r.Main_Package_1__c;
            String zVendorGroup = subRecord.Subscription__r.Vendor_1__r.Vendor_Group__c;
            String zVendorCode = subRecord.Subscription__r.Vendor_1__r.Vendor_Code__c;
            
            if (StringUtility.validate(zVendorGroup)=='1') {
                zVendorGroup = 'V';
            }
            if (mainPackageId!=null) {
                lPackageIDs.add(mainPackageId);
            }
            if (StringUtility.validate(zVendorCode)=='0') {
                //START 1 December 2015 D-4003 Kevin Evasco - 1 master record per vendor
                if (!vendorCodeSet.contains(zVendorCode) && !masterMap.containsKey(zVendorCode)) {
                    BT_CO_DIR_VendorPerformanceMaster__c masterRec = new BT_CO_DIR_VendorPerformanceMaster__c();
                    masterRec.Vendor_Group__c = zVendorGroup.trim();
                    masterRec.Vendor_Code__c =zVendorCode.trim();
                    masterList.add(masterRec);                  
                    vendorCodeSet.add(zVendorCode);
                }
                //END 1 December 2015 D-4003 Kevin Evasco - 1 master record per vendor
            }
        }
        
        //Save the master list first and create a map
        try {
            insert masterList;
        } catch(Exception e) {    
            BT_CO_INT_Utilities.log('DIR094DX Master list for Direct Subs failed...' + e.getMessage());
        }
        
        for (BT_CO_DIR_VendorPerformanceMaster__c masterRec : masterList) {
            masterMap.put(masterRec.Vendor_Code__c, masterRec.ID);
        }
        
        
        // Create a Map of Package IDs to a SET of Publications ...     
        Map<ID, Set<Publication__c>> mPackagePublications = new Map<ID, Set<Publication__c>>();
        if (lPackageIDs.size() > 0) {
            mPackagePublications = BT_CO_INT_Utilities.packageToPublication(lPackageIDs);           
        }
        
        
        //Iterate through each record again to populate the detail object
        for (sObject record : scope) {
            Case_Subscription__c subRecord = (Case_Subscription__c) record;
            String zVALIDATION_CODE = '0';              
            ID zRecordId = subRecord.ID;
            ID zCaseID = subRecord.Case__r.ID;
            ID zAccountID = subRecord.Case__r.AccountId;
            String zCaseNumber = subRecord.Case__r.CaseNumber;
            String zCaseStatus = subRecord.Case__r.Status;
            String zCaseRecordType = subRecord.Case__r.RecordType.DeveloperName;
            String zAccountRecordType = subRecord.Case__r.Account_Record_Type__c;
            String prodCode = subRecord.Subscription__r.product_code__c; //START/End UD-2691 23-Sep-2015 Added by Raviteja
            String zCaseCategory = subRecord.Case__r.Sub_Category__c;
            ID zPackageID = subRecord.Subscription__r.Main_Package_1__c;        
            String zVendorGroup = subRecord.Subscription__r.Vendor_1__r.Vendor_Group__c;
            String zVendorCode = subRecord.Subscription__r.Vendor_1__r.Vendor_Code__c;
            ID zSubscriptionID = subRecord.Subscription__r.ID;

            //START UD-4012 Renz 2015-12-09 Add complaint dates
            String zFrequency = subRecord.Subscription__r.Frequency__c;
            Date dtComplaintFromDate = subRecord.Complaint_From__c;
            Date dtComplaintToDate = subRecord.Complaint_To__c;
            //END UD-4012 Renz 2015-12-09 Add complaint dates

            if (StringUtility.validate(zVendorGroup)=='1') {
                zVendorGroup = 'V';
            }
            
            if (mPackagePublications.containsKey(zPackageID)) {
                Set<Publication__c> publicationListData = new Set<Publication__c>();

                if (mPackagePublications.get(zPackageID) != null) {
                    publicationListData = mPackagePublications.get(zPackageID);
                }
                
                publicationListData = BT_CO_INT_Utilities.prodPubMapping(publicationListData, prodCode, mapProdPub);//START/End UD-2691 23-Sep-2015 Added by Raviteja
                
               
                for (Publication__c pRecord : publicationListData) { 
                    if (pRecord != null) {
                        String zPublicationCode = pRecord.Publication_Code__c;
                        
                        zVALIDATION_CODE = StringUtility.validate(zVendorCode);
                        zVALIDATION_CODE += StringUtility.validate(zPublicationCode);
                        if (zPublicationCode!=null&&!validPubCodeSet.contains(zPublicationCode)) {
                            zVALIDATION_CODE += '1';
                        } else {
                            zVALIDATION_CODE += '0';
                        }
                        
                        //START UD-4012 Renz 2015-12-09 Check if the publication is within the complaint date range
                        String zPublishedDays = '';
                        zPublishedDays = StringUtility.getPublishedDays(zFrequency, pRecord.Published_Days__c);
                        Date zEffectiveIssueDate = DateUtility.getFirstPublicationDate(dtComplaintFromDate,dtComplaintToDate,zPublishedDays);                       
                         zVALIDATION_CODE += StringUtility.validate(zEffectiveIssueDate);                       
                        //END UD-4012 Renz 2015-12-09 Check if the publication is within the complaint date range
                        
                        
                        String zData = zRecordId + ',';
                        zData += zAccountRecordType  + ',';
                        zData += zVendorCode  + ',';
                        zData += zVendorGroup  + ',';
                        zData += zCaseNumber  + ',';
                        zData += zCaseRecordType  + ',';
                        zData += zCaseStatus  + ',';
                        zData += zCaseCategory + ',';
                        zData += zSubscriptionID  + ',';
                        zData += pRecord.Publication_Code__c  + ',';
                        zData += 'Direct,';
        
                        if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE)) {
                            BT_CO_DIR_VendorPerformance__c rec1 = new BT_CO_DIR_VendorPerformance__c();

                            rec1.VendorAccountId__c = zRecordId;
                            rec1.Account_Record_Type__c =  zAccountRecordType;
                            rec1.Vendor_Code__c = zVendorCode;
                            rec1.Vendor_Group__c = zVendorGroup;
                            rec1.Case_Number__c = zCaseNumber;
                            rec1.Case_Category__c =  zCaseRecordType;
                            rec1.Case_Status__c = zCaseStatus;
                            rec1.Case_SubCategory__c = zCaseCategory;
                            rec1.CaseVenSubId__c = zSubscriptionID;
                            rec1.Publication_Code__c = pRecord.Publication_Code__c;
                            rec1.BT_CO_DIR_VendorPerformanceMaster__c = masterMap.get(zVendorCode);
                            rec1.Name = 'Direct';
                            
                            detailList.add(rec1);
                        } else {
                            BT_CO_INT_Utilities.log(zData,zRecordId);
                            String zErrorMsg = BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, errorMessageMap);                          
                            datapoolListFailed = BT_CO_INT_Utilities.exportFailedDataItem(
                                interfaceId, 
                                'Detail', 
                                zRecordId, 
                                zErrorMsg, 
                                zVALIDATION_CODE, 
                                zData, 
                                DateTime.now(), 
                                datapoolListFailed);
                        }
                    }
                }
            }
        }
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert detailList;
            insert datapoolListFailed;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            BT_CO_INT_Utilities.log('DIR094DX Detail insert operation failed (Direct).' + e.getMessage());
        }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        BT_AB_DIR094DX_VendorPerformanceIndirect batchJob = new BT_AB_DIR094DX_VendorPerformanceIndirect();
        Database.executeBatch(batchJob);        
    } 


}