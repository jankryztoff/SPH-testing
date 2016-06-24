/*
 * Class Name: BT_AB_HDS038DX_DailyStartStopActionFile
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - HDS038DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for HDS038DX batch job. Used together with BT_AS_HDS038DX_DailyStartStopActionFile Schedulable
 * 
 * History:
 *     2014/08/26 Kevin Evasco                  Created Skeletal Apex Batchable
 *     2014/09/20 Renino Niefes                     Added code implementation
 *     2014/11/03 Renino Niefes                     Uncommented date range clause in soql
 *     2014/11/18 Renino Niefes                     Added new set of record types
 *     2014/12/16 Wenjun                        D-1167
 *     2015/01/13 Renino Niefes                 D-1480 D-1478  Missing fields and patterns 
 *     2015/01/22 Renino Niefes                 D-1480 D-1478 Created StringUtility class to shorten the code
 *     2015/02/09 Michael Francisco             D-2018 Updated code to contain logic for 'Delivery Frequency' field     
 *     2015/02/16 Michael Francisco             Modified to address NovaSuite Code Review Findings - 100k limit / NULL values in WHERE clause 
 *     2015/02/19 Kevin Evasco                  D-2238 Used Vendor__c lookup to locate Vendor instead of Account__c
 *     2015/02/20 Renino Niefes                 D-2238 Used Vendor__c lookup to locate Vendor Group instead of Account__c.Vendor_Group__c
 *     2015/03/20 Michael Francisco             UD-0504 - Removed 'T11:00:00Z' timestamp and modified code to use convertDateFromYYYY_MM_DD_CustomSettings() method
 *     2015/03/25 Michael Francisco             D-2557 - Rewrote Apex Class to use 'Case_Subscription__c' 
 *     2015/03/30 Michael Francisco             UD-0624 - Added logic to handle the following:
 *                                              1) Multiple publications for one subscription
 *                                              2) Use of subscription effective date logic
 *                                              3) Removed 'utility' functions and placed these inside StringUtility.cls
 *     2015/04/06 Renino Niefes              Removed Pattern Validation for Product and Recipient IDs
 *     2015/04/09 Renino Niefes                 D-2715  fixes for SPH feedback in SIT
 *     2015/04/14 Renino Niefes                 UD-0550     Subscription Copies are calculated incorrectly.  
 *                                                                      Currently, it's the sum of all copies per day + phd and phe.  
 *                                                                      It should be "per day" copies only. Get it from Subscription's qty__c.
 *     2015/05/04 Michael Francisco             UD-1061 - Revised to address 'comma' values in 'Building Name' and added sorting  
 *     2015/05/19 Renino Niefes                 Hot Fix - Revise the code to use Nitin's Utility class.  Removed unnecessary comments
 *     2015/05/20 Renino Niefes                 Hot Fix - Commented out the COA part in start query.  corrected the values for temp stop types
 *                                                   Split the code into multiple apex classes
 *     2015/05/21 Renino Niefes                 Hot Fix - Additional refactoring removing unused codes.  Calling Temp Stop class instead of normal expiry.
 *     2015/06/29 Renino Niefes                 Hot Fix for UD-1606 - Get the stop request date from Order Line Item rather than from the case
 *     2015/07/31 Renino Niefes                 Hot Fix: Override zValidation Code to Pass.  Moving validation checks to on-premise server and save to FAI file 
 *     2015/08/14 Renino Niefes                 UD-2132 Add another condition when creating export data.  Use Product family to match the current record.  If it matches, then create a new record
 *     2015/08/24 Kevin Evasco                  UD-2048 Hot Fix: Include cases closed after effective date to the output file
 *     2015/09/16 Renino Niefes                 UD-2773 Hot Fix: Remove duplicate records check.  Apparently, there are subscriptions from a single account that has the same package.
 *     2015/09/23 Renino Niefes                 UD-2885 - Hotfix in UAT2, add another condition.  for both start and stop cases
 *     2015/09/23 Raviteja Kumar                UD-2691 Added Database.Stateful
 *     2015/10/01 Renino Niefes                 UD-2980 add Subscription ID 
 *     2015/10/12 Renino Niefes                 UD-3080 Hotfix in UAT2, exclude cases with sub_status__c like '%rejected%'
 *     2015/11/11 Renino Niefes                 D-3914 Company_Name__c is the new field for "Attention To" parameter
 *     2016/01/04 Renino Niefes                 UD-3467 Add another validation check for Stop Subscriptions.  If the Subscription's End Date is less than Subscription's Start Date, then it is invalid.
 *     2016/01/14 Renino Niefes                 UD-3774 Do not send out invalid STOP Subscription if the stop request date is not for tomorrow
 *     2016/01/28 Renino Niefes                 UD-3848 Add only vendor delivered subscriptions for direct subscribers 
 */

//START UD-2691 23-Sep-2015 Added by Raviteja  - Added Database.Stateful
//global class BT_AB_HDS038DX_DailyStartStopActionFile implements Database.Batchable<sObject>,Database.AllowsCallouts {
global class BT_AB_HDS038DX_DailyStartStopActionFile implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
//End UD-2691 23-Sep-2015 Added by Raviteja
    // SOQL Query in getting the interface primary object
    global final String interfaceId = 'HDS038DX';

    global final String START_SUBSCRIPTION = 'Start_Subscription';
    global final String STOP_SUBSCRIPTION = 'Stop_Subscription';  
    global final String CASE_STATUS_CLOSED = 'Closed';
    global final String DEFAULT_END_DATE = '20991231';
    global final String INDICATOR_YES = 'Y';
    global final String INDICATOR_NO = 'N';

    global final String TRANSACTION_TYPE_START = 'Start';
    global final String TRANSACTION_TYPE_STOP = 'Stop';

    global final String TRANSACTION_DESC_NEW = 'New';
    global final String TRANSACTION_DESC_PREMATURE_STOP = 'Premature Stop';
    global Map<String, Set<String>> mapProdPub = new Map<String, Set<String>>(); //START/End UD-2691 23-Sep-2015 Added by Raviteja  
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //prepare the case transaction types (only start and stop)
        Set<String> caseRecordTypesSet = new Set<String>();
        caseRecordTypesSet.add(START_SUBSCRIPTION);
        caseRecordTypesSet.add(STOP_SUBSCRIPTION);

        //prepare the status set applicable to this interface
        Set<String> caseStatusSet = new Set<String>();
        caseStatusSet.add(CASE_STATUS_CLOSED);

        //Prepare the cutoff dates
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);     
        DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_CustomSettings(brd,'Default Timestamp');     
        DateTime cutOffStart = cutOffEnd.addDays(-1); 
        Date dtEffStart = Date.valueOf(brd);
        Date dtEffEnd = dtEffStart.addDays(1);    
        
        //START 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
        DateTime dStartDate = DateTime.newInstance(dtEffStart.year(),dtEffStart.month(),dtEffStart.day());
        DateTime dEndDate = dStartDate.addDays(1);      
        
        mapProdPub = BT_CO_INT_Utilities.prodPubMapping();   //START/End UD-2691 23-Sep-2015 Added by Raviteja 
        
        String query = ' SELECT ';
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
        query += '    Case__r.ClosedDate, ';
        query += '    Case__r.Temp_Stop__r.Temp_Stop_Date__c, ';    
        query += '    Case__r.Temp_Stop__r.Restart_Date__c, ';
        query += '    Case__r.Order__c ';                               //UD-1606
        query += ' FROM Case_Subscription__c ';
        query += ' WHERE Case__r.Status in :caseStatusSet '; 
        query += '      AND Subscription__r.Delivered_By_1__c = \'Vendor\' ';     //START/END 2016/01/28 Renino Niefes        UD-3848               
        query += '      AND ( (     Case__r.RecordType.DeveloperName = :START_SUBSCRIPTION '; 
        query += '                  AND Subscription__r.Zuora__SubscriptionStartDate__c = :dtEffEnd ';
        query += '                  AND (Subscription__r.Zuora__SubscriptionEndDate__c= null OR Subscription__r.Zuora__SubscriptionEndDate__c >= :dtEffEnd ) ';  //START/END UD-2885 Renino Niefes 2015-09-23
        query += '              ) OR ( ';
        query += '                  Case__r.RecordType.DeveloperName = :STOP_SUBSCRIPTION';
        query += '                  AND Subscription__r.Zuora__SubscriptionStartDate__c <= :dtEffEnd ';    //START/END UD-2885 Renino Niefes 2015-09-23
        //query += '                    AND Case__r.Stop_Request_Date__c = :dtEffStart ';  //UD-1606 (Use Order Line Item instead)
        query += '              ) OR ( ';
        query += '                Subscription__r.Zuora__SubscriptionStartDate__c <= :dtEffStart ';
        query += '                AND (Subscription__r.Zuora__SubscriptionEndDate__c= null OR Subscription__r.Zuora__SubscriptionEndDate__c >= :dtEffStart ) ';  //START/END UD-2885 Renino Niefes 2015-09-23       
        query += '                AND Case__r.RecordType.DeveloperName = :START_SUBSCRIPTION ';
        query += '                AND Case__r.ClosedDate >= :dStartDate ';
        query += '                AND Case__r.ClosedDate < :dEndDate ';
        query += '           ) ';
        query += '      ) ';
        query += '      AND (NOT Case__r.Sub_Status__c LIKE \'%Rejected%\' ) ';  //START/END UD-3080 Renino Niefes 2015-10-12 Exclude rejected cases in the main query
        query += ' ORDER BY ';
        query += '      Subscription__r.Zuora__Account__r.Account_Auto_Number__c, ';    
        query += '      Subscription__r.Recipient_Contact__r.Recipient_Number__c, ';    
        query += '      Subscription__r.Name, ';                                        
        query += '      Subscription__r.Product_Code__c ASC';                                        
        //END 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
        
        return Database.getQueryLocator(query);
    }
    

    global void execute(Database.BatchableContext BC, List<sObject> scope) {       
        List<BA_INT_DATA_FAILED_POOL__c> datapoolListFailed = new List<BA_INT_DATA_FAILED_POOL__c>();
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        Map<Decimal,String> errorMessageMap = BT_CO_INT_Utilities.getErrorMessageMap(interfaceId);
        List<ID> lPackageIDs = new List<ID>();
        List<ID> lOrderIDs = new List<ID>();
        List<ID> lSubscriptionIDs = new List<ID>();
        
    // START UD-2132 2015-08-14 Renino Niefes
        Map<String, String> mapProdCode2ProdFamily = new Map<String, String>();
        List<String> lstProdCodes = new List<String>();     
        
        Map<Id, Case_Subscription__c> orderId_caseSubscription_map = new Map<Id, Case_Subscription__c>(); //START/END 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
        
    //prepare the mainPackageList
        for(sObject record : scope) {                       
            Case_Subscription__c subRecord = (Case_Subscription__c) record;
            ID mainPackageId = subRecord.Subscription__r.Main_Package_1__c;
            ID orderID = subRecord.case__r.Order__c;
            ID subscriptionID = subRecord.Subscription__r.Id;
            if (mainPackageId!=null) {
                lPackageIDs.add(mainPackageId);
            }
            if (orderID!=null) {
                lOrderIDs.add(orderID);
            }
            if (subscriptionID!=null) {
                lSubscriptionIDs.add(subscriptionID);
            }  
                        
            if(subRecord.Subscription__r.Product_Code__c != null){
                lstProdCodes.add(subRecord.Subscription__r.Product_Code__c);
            }                       
            
            orderId_caseSubscription_map.put(subRecord.Case__r.Order__c, subRecord); //START/END 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
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
        
    // UD-1606 Hot Fix - Create a map of Order Line Items using Order ID and Subscription IDs
        Map<String, Order_Line_Item__c> mOrderLineItemMap = new Map<String, Order_Line_Item__c>();
        String brd = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);     
        Date dtEffStart = Date.valueOf(brd);
        Date dtEffEnd = dtEffStart.addDays(1);          
        
        //START 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
        DateTime dStartDate = DateTime.newInstance(dtEffStart.year(),dtEffStart.month(),dtEffStart.day());
        DateTime dEndDate = dStartDate.addDays(1);
        
        List<Order_Line_Item__c> orderItemsList = [ SELECT Order__c,Stop_Request_Date__c,Subscription__c 
                                        FROM Order_Line_Item__c 
                                        WHERE Order__c IN :lOrderIDs
                                            AND Subscription__c IN :lSubscriptionIDs
                                        ORDER BY Order__c, Subscription__c ];

        for (Order_Line_Item__c orderItem : orderItemsList) {
            Case_Subscription__c caseSubscriptionRecord = orderId_caseSubscription_map.get(orderItem.Order__c);
            DateTime caseClosedDate = caseSubscriptionRecord.Case__r.ClosedDate;
            if(orderItem.Stop_Request_Date__c == dtEffEnd ||
                (orderItem.Stop_Request_Date__c <= caseClosedDate && caseClosedDate >= dStartDate && caseClosedDate < dEndDate)) {
                String orderItemKey = '';
                orderItemKey += orderItem.Order__c + '-' + orderItem.Subscription__c;
                mOrderLineItemMap.put(orderItemKey, orderItem);
            }
        }
        //END 24 August 2015 UD-2048 Kevin Evasco - Include cases closed after effective date to the output file
                                        
    // Iterate through and create the export data
        Set<String> exportDataSet = new Set<String>(); 
        for (sObject record : scope) {
            Case_Subscription__c subRecord = (Case_Subscription__c) record;
            
            ID zRecordId = subRecord.Id;
            ID orderID = subRecord.case__r.Order__c;
            ID subscriptionID = subRecord.Subscription__r.Id;
            String zRecordType = subRecord.Case__r.RecordType.DeveloperName;
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
            //DateTime dtmSubscriptionLastModifiedDate = subRecord.Subscription__r.LastModifiedDate;
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

            String zTransactionDesc = null;
            String zTransactionType = null;
            Date zEffectiveDate = null;
            Date zEffectiveIssueDate = null;        
            String strOrderSubsKey = orderID+ '-' + subscriptionID;
            
            String zCrsmSubscriptionId = subRecord.Subscription__r.Name; //START/END  UD-2980 2015-10-01 Renino Niefes add Subscription ID
            
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
                for (Publication__c pRecord : publicationListData) { 
                    if (pRecord != null && pRecord.Product_Family__c == mapProdCode2ProdFamily.get(zProductCode)) {  //UD-2132 start/end  added conditions to filter out listdata
                        String zDayOfWeekPattern = null;
                        zSponsoredIndicator = pRecord.Free_Publication__c ? INDICATOR_YES:INDICATOR_NO;
                        zPublishedDays = StringUtility.getPublishedDays(zSubscriptionFrequency, pRecord.Published_Days__c); 
                        zPublicationCode = pRecord.Publication_Code__c;
                        zPublicHolidayWeekdayInd = pRecord.Public_Holiday_Weekday_Pub_Indicator__c;
                        zPublicHolidayWeekendInd = pRecord.Public_Holiday_Weekend_Pub_Indicator__c;
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
                          
                        //Values for Transaction type: Start, Stop                              
                        if (zCaseRecordType.trim().equalsIgnoreCase(START_SUBSCRIPTION)) {
                            zTransactionType = TRANSACTION_TYPE_START;
                            zTransactionDesc = TRANSACTION_DESC_NEW;
                            zEffectiveDate = dtSubscriptionStartDate;                           
                        } else if (zCaseRecordType.trim().equalsIgnoreCase(STOP_SUBSCRIPTION)) {
                            zTransactionType = TRANSACTION_TYPE_STOP;
                            zTransactionDesc = TRANSACTION_DESC_PREMATURE_STOP;
                            //zEffectiveDate = dtStopRequestDate != null ? dtStopRequestDate.addDays(1) : dtStopRequestDate;                            
                            if (mOrderLineItemMap.containsKey(strOrderSubsKey)) {
                                Order_Line_Item__c orderItem = mOrderLineItemMap.get(strOrderSubsKey);
                                zEffectiveDate = orderItem.Stop_Request_Date__c;
                            } else {
                                zEffectiveDate = null;
                            }
                        }
                        Date dateFrom = zEffectiveDate;
                        Date dateTo = dtSubscriptionEndDate;
                        if (dateFrom==null) dateFrom = Date.Today();
                        if (dateTo==null || (dateTo != null && dateFrom.daysBetween(dateTo) < 0)) dateTo = DateUtility.convertDateFromYYYYMMDD(DEFAULT_END_DATE);
                        zEffectiveIssueDate = DateUtility.getFirstPublicationDate(dateFrom,dateTo,zPattern);                        

                    //START 2016/01/14 Renino Niefes UD-3774 Do not send out invalid STOP Subscription if the stop request date is not for tomorrow. Comment out old validations                        
                    // Validate Data ...                        
                        //zVALIDATION_CODE = StringUtility.validate(zVendorCode);                 // Check 'Vendor Number' Data
                        //zVALIDATION_CODE += StringUtility.validate(zHouseBlockNumber);      // Check 'House/Block Number' Data ... 
                        //zVALIDATION_CODE += StringUtility.validate(zPostalCode);                    // Check 'Postal Code' Data ...
                        //zVALIDATION_CODE += StringUtility.validate(zDayOfWeekPattern);          // CHeck 'Day of Week Pattern' Data ...                     
                        //zVALIDATION_CODE += StringUtility.validate(zRecipientName);             // Check 'Recipient Name' Data ...                      
                        //zVALIDATION_CODE += StringUtility.validate(zCRSMAccountNumber);     // Check 'Account Number' Data ...
                        //zVALIDATION_CODE += StringUtility.validate(zCRSMContactNumber);     // Check 'Recipient Number' Data ...                    
                        //zVALIDATION_CODE += StringUtility.validate(zPublicationCode);       // Check 'Publication Code' Data ...                        
                        //zVALIDATION_CODE += StringUtility.validate(zEffectiveDate);             // Check 'Effective Date' Data ...                                              
                        //zVALIDATION_CODE += '0';//StringUtility.validate(zLevelNumber);             // Check 'Level Number' Data ...                        
                        //zVALIDATION_CODE += '0';//StringUtility.validate(zUnitNumber);                  // Check 'Unit Number' Data ...                     
                        //zVALIDATION_CODE += StringUtility.validate(zStreetName);                // Check 'Street Name' Data ...  
                        //zVALIDATION_CODE += StringUtility.validate(zTransactionType);           // Check 'Transaction Type'
                        //zVALIDATION_CODE += StringUtility.validate(zTransactionDesc);           // Check 'Transaction Desc' Data ... 
                        //zVALIDATION_CODE += StringUtility.validate(zEffectiveIssueDate);        // Check The Indicator...                       
                        
                                                
                        //Override zValidation Code to Pass.  Moving validation checks to on-premise server and save to FAI file
                        zVALIDATION_CODE = '000000000000000';                        
                        
                        //START 2016/01/04 Renino Niefes UD-3467 Add another validation check for Stop Subscriptions
                        if (zCaseRecordType.trim().equalsIgnoreCase(STOP_SUBSCRIPTION)) {
                            if ( dtSubscriptionEndDate!=null && dtSubscriptionEndDate<dtSubscriptionStartDate ) {
                                zVALIDATION_CODE += '1';
                            } else {
                                zVALIDATION_CODE += '0';
                            }
                            
                            zVALIDATION_CODE += StringUtility.validate(zEffectiveDate); //Note: this validation is only required for Stop Subscriptions... for UD-3774
                        } else {
                            zVALIDATION_CODE += '0';
                        }
                        //END 2016/01/04 Renino Niefes UD-3467
                        //END 2016/01/14 Renino Niefes UD-3774
                        
                    // Create zData string ...
                        String zData = '';
                        zData += StringUtility.quoteReplaceStr(zCustomerGroup) +',';                                // Customer Group (Vendor Group)
                        zData += StringUtility.quoteReplaceStr(zVendorCode) +',';                                   // Vendor Number 
                        zData += StringUtility.quoteReplaceStr(zTransactionType) +',';                              // Transaction Type 
                        zData += StringUtility.quoteReplaceStr(zTransactionDesc) +',';                          // Transaction Description 
                        zData += StringUtility.quoteReplaceStr(zHouseBlockNumber) +',';                             // Block Number
                        zData += StringUtility.quoteReplaceStr(zLevelNumber) +',';                                  // Level Number 
                        zData += StringUtility.quoteReplaceStr(zUnitNumber) +',';                                   // Unit Number 
                        zData += StringUtility.quoteReplaceStr(zPostalCode) +',';                                   // Postal Code 
                        zData += StringUtility.quoteReplaceStr(zStreetName) +',';                                   // Street Name 
                        zData += StringUtility.quoteReplaceStr(zBuildingName) +',';                                 // Building Name 
                        zData += StringUtility.quoteReplaceStr(zPublicationCode) +',';                          // Publication Code 
                        zData += StringUtility.quoteReplaceStr(String.valueOf(dSubscriptionQty)) +',';      // Subscription Copies
                        zData += StringUtility.quoteReplaceStr(String.valueOf(zEffectiveDate)) +',';            // Effective Date                         
                        zData += StringUtility.quoteReplaceStr(String.valueOf(zEffectiveIssueDate)) +',';   // Effective Issue                      
                        zData += 'null,';       // Restart Date (not applicable to start and stop)
                        zData += StringUtility.quoteReplaceStr(zDeliveryFrequency) +',';                        // Delivery Frequency 
                        zData += StringUtility.quoteReplaceStr(zAccountLegacyId) +',';                          // Subscriber Account 
                        zData += StringUtility.quoteReplaceStr(zRecipientLegacyId) +',';                        // Recipient Account 
                        zData += StringUtility.quoteReplaceStr(zRecipientName) +',';                            // Recipient Name 
                        zData += StringUtility.quoteReplaceStr(zAttnToCareOf) +',';                             // Recipient Attention To 
                        zData += 'null,';       // Route Sys    ---> IGNORED FIELD
                        zData += 'null,';       // Route Number ---> IGNORED FIELD
                        zData += 'null,';       // Drop Point   ---> IGNORED FIELD
                        zData += 'null,';       // User ID      ---> IGNORED FIELD
                        zData += StringUtility.quoteReplaceStr(zSponsoredIndicator) +',';                       // Sponsored Indicator
                        zData += StringUtility.quoteReplaceStr(zMon) +',';                                          // Day 1 Copy 
                        zData += StringUtility.quoteReplaceStr(zTue) +',';                                          // Day 2 Copy 
                        zData += StringUtility.quoteReplaceStr(zWed) +',';                                          // Day 3 Copy 
                        zData += StringUtility.quoteReplaceStr(zThu) +',';                                              // Day 4 Copy 
                        zData += StringUtility.quoteReplaceStr(zFri) +',';                                              // Day 5 Copy 
                        zData += StringUtility.quoteReplaceStr(zSat) +',';                                              // Day 6 Copy 
                        zData += StringUtility.quoteReplaceStr(zSun) +',';                                              // Day 7 Copy 
                        zData += StringUtility.quoteReplaceStr(zPHd) +',';                                              // PH Weekday Copy 
                        zData += StringUtility.quoteReplaceStr(zPHe) +',';                                              // PH Weekend Copy 
                        zData += StringUtility.quoteReplaceStr(zDayOfWeekPattern) +',';                         // Day of Week Pattern 
                        zData += StringUtility.quoteReplaceStr(zProductCode) +',';                                  // Product Code 
                        zData += StringUtility.quoteReplaceStr(zCRSMAccountNumber) +',';                            // CRSM Account ID
                        zData += StringUtility.quoteReplaceStr(zCRSMContactNumber) +',';                            // CRSM Contact ID
                        zData += StringUtility.quoteReplaceStr(zPHeIndicator) +',';                                 // Day of week pattern (PHe)
                        zData += StringUtility.quoteReplaceStr(zCrsmSubscriptionId) +',';                           //START/END  UD-2980 2015-10-01 Renino Niefes add Subscription ID
                        
                        if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE)) {
                            //START 2015/09/16 Renino Niefes                 UD-2773 Hot Fix: Remove duplicate records check
                            //if (!exportDataSet.contains(zData)) {
                            datapoolList = BT_CO_INT_Utilities.exportDataItem(interfaceId, 'Detail', zRecordId, zData, dtLastModifiedDate, datapoolList);
                            //}
                            //exportDataSet.add(zData);              
                            //END 2015/09/16 Renino Niefes                 UD-2773 Hot Fix: Remove duplicate records check                            
                        } else {
                        //Create a debug log / Interpret Validation String / Insert to Failed Pool
                            BT_CO_INT_Utilities.log(zData,zRecordId);
                            String zErrorMsg = '('+zRecordType+')'+BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, errorMessageMap);                          
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
                        zVALIDATION_CODE = '';
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
        BT_AB_HDS038DX_TempStop callOutJob = new BT_AB_HDS038DX_TempStop();
        Database.executeBatch(callOutJob);
    }   


}