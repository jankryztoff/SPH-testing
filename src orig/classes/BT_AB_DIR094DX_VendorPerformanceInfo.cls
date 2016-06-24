/*
 * Class Name: BT_AB_DIR094DX_VendorPerformanceInfo
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - DIR094DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for DIR094DX batch job. Used together with BT_AS_DIR094DX_VendorPerformanceInfo Schedulable
 * 
 * History: 2014/08/26 Kevin Evasco Created Skeletal Apex Batchable
 * History: 2014/09/27 Renino Niefes Added code implementation
 * History: 2014/11/03 Renino Niefes removed other case status from list (removed temporary status)
 * History: 2014/11/03 Renino Niefes updated the list of sub categories
 * History: 2014/11/03 Renino Niefes moved the call out to future date
 * History: 2015/02/19 Renino Niefes D-2238 Fix the Vendor Code Issue and default value for vendor group
 * History: 2015/03/24 Renino Niefes D-2627 Revise the apex class to get cases from both Vendor and Direct Individual (Vendor Subscriber)
 * History: 2015/04/07 Renino Niefes D-2627 Remove Account Record Type from the where clause.
 */


global class BT_AB_DIR094DX_VendorPerformanceInfo implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    // global final String query = 'SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = \'DIR094DX Sample Source\'';    
    global final String interfaceId = 'DIR094DX';
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList;

        List<BT_CO_DIR_VendorPerformance__c> stagingList = [SELECT Id FROM BT_CO_DIR_VendorPerformance__c];
        delete stagingList;

        List<BT_CO_DIR_VendorPerformanceMaster__c> stagingMasterList = [SELECT Id FROM BT_CO_DIR_VendorPerformanceMaster__c];
        delete stagingMasterList;
        
    

        //prepare the status set applicable to this interface
        List<String> caseStatusList = new List<String>();
        caseStatusList.add('Closed');
        //caseStatusList.add('Void'); //for testing only.  remove afterwards
        //caseStatusList.add('Pending'); //for testing only.  remove afterwards
        //caseStatusList.add('New'); //for testing only.  remove afterwards
        
        //prepare the list of cases that this interface will use
        List<String> caseRecordTypesList = new List<String>();
        caseRecordTypesList.add('Complaint_Newspaper');
        caseRecordTypesList.add('Complaint_Magazine');

        //START 2015/04/07 Renino Niefes D-2627 Remove Account Record Type from the where clause. added Non-Delivery sub category

        //prepare the list of case Sub Category
        List<String> caseSubCategList = new List<String>();

        //Updated the list of sub categories based on SIT environment by Renz 11/18/2014
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
        
        //[START 2015-01-20 Renz D-1720] Additional Sub Categ List 
        caseSubCategList.add('Non-Delivery');
        //[END 2015-01-20 Renz D-1720]
        
        //start 2015/03/24 Renino Niefes D-2627 Additional Complaints
        caseSubCategList.add('Non-Start');
        caseSubCategList.add('Non-Start (Temp-Stop)');
        caseSubCategList.add('Non-Stop');
        caseSubCategList.add('Non-Stop (Temp Stop)');
        //end 2015/03/24 Renino Niefes D-2627 Additional Complaints
        
        //Prepare the cut off dates.  Use Batch Run Date as current date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_ToMonthEnd(batchRunDate);
        DateTime cutOffStart = DateUtility.convertDateFromYYYY_MM_DD_ToMonthStart(batchRunDate);

        
        //TO-DO:  determine what's chargeable and non chargeable.
        
        //start 2015/03/24 Renino Niefes D-2627 Use Case object instead of Case Vendor Subscription
        String query = 'SELECT Id, ';
        query += ' AccountId,  ';
        query += ' CaseNumber, ';
        query += ' Status,  ';
        query += ' RecordType.DeveloperName,  ';
        query += ' Account_Record_Type__c,  ';
        query += ' Sub_Category__c  ';
        query += ' FROM Case ';
        query += ' WHERE Status IN :caseStatusList ';
        query += ' AND RecordType.DeveloperName in :caseRecordTypesList ';        
        query += ' AND Sub_Category__c IN :caseSubCategList ';
        //[START 2015-01-20 Renz D-1720] Uncomment the date range below
        query += ' AND LastModifiedDate >= ' + cutOffStart.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        query += ' AND LastMOdifiedDate <= ' + cutOffEnd.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        //[END 2015-01-20 Renz D-1720] Uncomment the date range below
        //end 2015/03/24 Renino Niefes D-2627 Use Case object instead of Case Vendor Subscription

        //EMD 2015/04/07 Renino Niefes D-2627 Remove Account Record Type from the where clause.
        /*
        BT_DEV_Debugger debugger = new BT_DEV_Debugger();
        debugger.clearDebugLogs(interfaceId);
        debugger.addDebugLogs(interfaceId,'query=' + query);
        debugger.saveDebugLogs();
        */
        
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
        //start 2015/03/24 Renino Niefes D-2627
        //Create a set of Vendor Codes and a list of Details
        Set<String> vendorMasterSet = new Set<String>();
        Map<String, BT_CO_DIR_VendorPerformanceMaster__c> vendorMasterMap = new Map<String, BT_CO_DIR_VendorPerformanceMaster__c>();
        List<BT_CO_DIR_VendorPerformance__c> vendorDetailList = new List<BT_CO_DIR_VendorPerformance__c>();
        
        List<ID> caseIDList = new List<ID>();  //To be used for retrieving Case_Subscription and Case_Vendor_Subscription
        Map<ID,Case> caseMap = new Map<ID,Case>(); //To be used as map when creating the details
        
        for (sObject record : scope)
        {
            Case record2 = (Case) record;
            caseIDList.add(record2.Id);
            caseMap.put(record2.Id, record2);
        }
        
        
        //('ST', 'SUT', 'ZB', 'BH', 'BM', 'BT', 'TM')  Only thes publication codes are required in this interface
        //Prepare the product publication Map to be used for Vendor Subscribers
        LIST<Product_Publication__c> prodPubCodeList = [SELECT Product_Code_Mapping__c,
                    Publication_Code_Mapping__c 
            FROM Product_Publication__c WHERE Publication_Code_Mapping__c IN ('ST', 'SUT', 'ZB', 'BH', 'BM', 'BT', 'TM')];
            
        Map<String,Set<String>> prodPubCodeMap = new Map<String,Set<String>>();
        
        for (Product_Publication__c pprec : prodPubCodeList)
        {
            if (pprec.Product_Code_Mapping__c!=null&&pprec.Product_Code_Mapping__c!='') {
                if (prodPubCodeMap.containsKey(pprec.Product_Code_Mapping__c)) {
                    Set<String> set1  = prodPubCodeMap.get(pprec.Product_Code_Mapping__c);
                    set1.add(pprec.Publication_Code_Mapping__c);
                } else{
                    Set<String> set1 = new Set<String>();
                    set1.add(pprec.Publication_Code_Mapping__c);
                    prodPubCodeMap.put(pprec.Product_Code_Mapping__c,set1);
                }
            }
        }
        
        
        
        
        //Get Records from Case Subscription
        LIST<Case_Subscription__c> caseSubsList = [SELECT Case__r.ID, Product_Code__c, 
            Subscription__r.Vendor_1__r.Vendor_Code__c, Subscription__r.ID
            FROM Case_Subscription__c WHERE Case__r.ID IN :caseIDList];
        
        for (Case_Subscription__c csrec : caseSubsList) {
            if (csrec.Product_Code__c!=null&&csrec.Subscription__r.Vendor_1__r.Vendor_Code__c!=null&&prodPubCodeMap.containsKey(csrec.Product_Code__c)) {
            
                //Create a new master record if it doesn't exist and put that to Map.  Use Vendor Code as the key
                vendorMasterSet.add(csrec.Subscription__r.Vendor_1__r.Vendor_Code__c);                          
                if (!vendorMasterMap.containsKey(csrec.Subscription__r.Vendor_1__r.Vendor_Code__c)) {
                    BT_CO_DIR_VendorPerformanceMaster__c masterRec = new BT_CO_DIR_VendorPerformanceMaster__c();                    
                    masterRec.Vendor_Group__c = 'V';
                    masterRec.Vendor_Code__c = csrec.Subscription__r.Vendor_1__r.Vendor_Code__c;                    
                    vendorMasterMap.put(csrec.Subscription__r.Vendor_1__r.Vendor_Code__c, masterRec);
                }
                
                //Get the case from caseMap
                Case caseRec = null;
                if (caseMap.containsKey(csrec.Case__r.ID)) {
                    caseRec = caseMap.get(csrec.Case__r.ID);
                }
                
                Set<String> set1 = prodPubCodeMap.get(csrec.Product_Code__c);               
                for (String str1 : set1) {
                    
                    BT_CO_DIR_VendorPerformance__c rec1 = new BT_CO_DIR_VendorPerformance__c();

                    rec1.VendorAccountId__c = caseRec.AccountId;
                    rec1.Account_Record_Type__c =  caseRec.Account_Record_Type__c;
                    rec1.Vendor_Code__c = csrec.Subscription__r.Vendor_1__r.Vendor_Code__c;
                    rec1.Vendor_Group__c = 'V';
                    rec1.Case_Number__c = caseRec.CaseNumber;
                    rec1.Case_Category__c =  caseRec.RecordType.DeveloperName;
                    rec1.Case_Status__c = caseRec.Status;
                    rec1.Case_SubCategory__c = caseRec.Sub_Category__c;
                    rec1.CaseVenSubId__c = csrec.Subscription__r.ID;
                    rec1.Publication_Code__c = str1;
                    
                    vendorDetailList.add(rec1);
                }               
                
            }
        }

    
        //Get records from Case Vendor Subscription
        LIST<Case_Vendor_Subscription__c> caseVenSubsList = [SELECT Case__r.ID,
            Subscription_Vendor__r.Vendor__r.Vendor_Code__c, Subscription_Vendor__r.ID
            FROM Case_Vendor_Subscription__c WHERE Case__r.ID IN :caseIDList];

        Set<ID> subVenIDSet = new Set<ID>();
        for (Case_Vendor_Subscription__c cvsrec : caseVenSubsList) {      //Get all the Subscription vendor IDs and get the Subscription Vendor Publication
            subVenIDSet.add(cvsrec.Subscription_Vendor__r.ID);
            
        }

        //Get all the publication codes assigned to each subscription vendor.  create a map
        LIST<Subscription_Vendor_Publication__c> svpList = [
            SELECT Publication__r.Publication_Code__c,Subscription_Vendor__r.ID FROM Subscription_Vendor_Publication__c
            WHERE Subscription_Vendor__r.ID IN :subVenIDSet
            AND Publication__r.Publication_Code__c IN ('ST', 'SUT', 'ZB', 'BH', 'BM', 'BT', 'TM')
        ];
        
        Map<String,Set<String>> svpMap = new Map<String,Set<String>>();
        for (Subscription_Vendor_Publication__c svprec : svpList)
        {
            if (svprec.Publication__r.Publication_Code__c!=null&&svprec.Publication__r.Publication_Code__c!='') {
                if (svpMap.containsKey(svprec.Publication__r.Publication_Code__c)) {
                    Set<String> set1  = svpMap.get(svprec.Publication__r.Publication_Code__c);
                    set1.add(svprec.Publication__r.Publication_Code__c);
                } else{
                    Set<String> set1 = new Set<String>();
                    set1.add(svprec.Publication__r.Publication_Code__c);
                    svpMap.put(svprec.Subscription_Vendor__r.ID,set1);
                }
            }
        }
        
        
        for (Case_Vendor_Subscription__c cvsrec : caseVenSubsList) {      //Loop through again to generate the details
            if (cvsrec.Subscription_Vendor__r.Vendor__r.Vendor_Code__c!=null&&svpMap.containsKey(cvsrec.Subscription_Vendor__r.ID)) {
            
                //Get the case from caseMap
                Case caseRec = null;
                if (caseMap.containsKey(cvsrec.Case__r.ID)) {
                    caseRec = caseMap.get(cvsrec.Case__r.ID);
                }
            
                //Create a new master record if it doesn't exist and put that to Map.  Use Vendor Code as the key
                vendorMasterSet.add(cvsrec.Subscription_Vendor__r.Vendor__r.Vendor_Code__c);                            
                if (!vendorMasterMap.containsKey(cvsrec.Subscription_Vendor__r.Vendor__r.Vendor_Code__c)) {
                    BT_CO_DIR_VendorPerformanceMaster__c masterRec = new BT_CO_DIR_VendorPerformanceMaster__c();                    
                    masterRec.Vendor_Group__c = 'V';
                    masterRec.Vendor_Code__c = cvsrec.Subscription_Vendor__r.Vendor__r.Vendor_Code__c;                  
                    vendorMasterMap.put(cvsrec.Subscription_Vendor__r.Vendor__r.Vendor_Code__c, masterRec);
                }
            
                Set<String> set1 = svpMap.get(cvsrec.Subscription_Vendor__r.ID);                
                for (String str1 : set1) {
                    
                    BT_CO_DIR_VendorPerformance__c rec1 = new BT_CO_DIR_VendorPerformance__c();

                    rec1.VendorAccountId__c = caseRec.AccountId;
                    rec1.Account_Record_Type__c =  caseRec.Account_Record_Type__c;
                    rec1.Vendor_Code__c = cvsrec.Subscription_Vendor__r.Vendor__r.Vendor_Code__c;
                    rec1.Vendor_Group__c = 'V';
                    rec1.Case_Number__c = caseRec.CaseNumber;
                    rec1.Case_Category__c =  caseRec.RecordType.DeveloperName;
                    rec1.Case_Status__c = caseRec.Status;
                    rec1.Case_SubCategory__c = caseRec.Sub_Category__c;
                    rec1.CaseVenSubId__c = cvsrec.Subscription_Vendor__r.ID;
                    rec1.Publication_Code__c = str1;
                    
                    vendorDetailList.add(rec1);
                }   
            
            }
        }
        
        
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML2 = Database.setSavepoint();
        try
        {
            insert vendorMasterMap.values();
            for (BT_CO_DIR_VendorPerformance__c  detail1 : vendorDetailList) {
                if (vendorMasterMap.containsKey(detail1.Vendor_Code__c)) {
                    BT_CO_DIR_VendorPerformanceMaster__c masterRec = vendorMasterMap.get(detail1.Vendor_Code__c);
                    detail1.BT_CO_DIR_VendorPerformanceMaster__c = masterRec.ID;
                }
            }
            
            insert vendorDetailList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML2);
            System.debug('BT_AB_DIR094DX_VendorPerformanceInfo insert operation failed.');
        }       
        
        //end 2015/03/24 Renino Niefes D-2627
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        
        //After all records were processed and consolidated in Staging Objects (master-detail), get the master's data for summarized view
        List<BT_CO_DIR_VendorPerformanceMaster__c> masterList = [SELECT AccountId__c,
            Vendor_Code__c,
            Vendor_Group__c,
            Complaint_Count_NonDelivery__c,
            Complain_Count_Delivery__c
            FROM BT_CO_DIR_VendorPerformanceMaster__c
        ];

        for(BT_CO_DIR_VendorPerformanceMaster__c record : masterList)
        {  
            String exportData = '';     
            exportData += record.Vendor_Group__c + ',';
            exportData += record.Vendor_Code__c + ',';
            exportData += record.Complain_Count_Delivery__c + ',';
            exportData += record.Complaint_Count_NonDelivery__c + '';
            
            // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.Name = interfaceId;
            datapoolRecord.job_id__c = '1';
            datapoolRecord.group_id__c = 'Detail';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;
            
            datapoolList.add(datapoolRecord);           
        }
                   
    
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_' + interfaceId + '_DailyVendorSubscription insert operation failed.');
        }   
             
     
        //Call out to Nitin's web serviceRequestVO
        BT_AB_DIR094DX_CallOutOnly callOutJob = new BT_AB_DIR094DX_CallOutOnly();
        Database.executeBatch(callOutJob);
        
    }
    
}