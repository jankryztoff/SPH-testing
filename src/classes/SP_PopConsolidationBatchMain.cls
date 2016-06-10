/**
 * Class Name: SP_PopConsolidationBatchMain
 * @author: Crisanto de Llamas
 * Date: 
 * Requirement/Project Name: CRSM Project
 * @description Batch Apex Class to Create Daily Vendor POP Batch Records which will be fetched by Integration to be sent to the POP System.
 * assumptions: This batch Class runs on a daily basis and aggregates publication data for the next day. Publication Copies is computed per vendor if:
 *              1. The next day is a Publish Day AND
 *              2. The next day is not a public holiday AND
 *              3. The subscription is not under a Temp Stop for the next day.
 *              4. Totals does not include copies for Vendor Subscriptions
 * @Modifications : By Nitin to add MIRO specific computation logic
 * @History: D-1182 Wenjun 11 Feb 15 : Rewrite this class for the following changes:
 *      - Fix 1: Support Date Range - this batch will generate data for the defined date range instead of "Next Day" only
 *      - Fix 2: Calculate Total Count in finsih method - Be Thread Safe!
 *      - Fix 3: make sure no data will be generated if the date is already generated in previous runs
 *      - Fix 4: Fix the approach to handle Different Publication Frequency 
 * @History: D-2317 Wenjun 23 Feb 15 - Rename to SP_PopConsolidationBatchMain. This is the 2nd step of POP Process.
 *           D-2622 Nitin 27-3-2015 made changes to grace period comparisons and added a few debug statements for future reference.  
 * @History: D-2984 UAT Hotfix Wenjun 12 May 15 - Start Query / Delivery By / COA / COV 
 * UD-3349 - UD-3359 - UD-3354 - 28-Dec-2015 Added by Raviteja - Restructured the class as part of the defect fix. 
 * UD-3349 - 06-Jan-2016 Added by Raviteja - Restructured the class as part of the defect fix. 
 * D-4383 - 29-Jan-2016 Added by Raviteja - Applying the logic of pub issue date by using POP History records
 */
//START/End UD-3043 07-Oct-2015 Added by Raviteja - Adding Database.AllowsCallouts 
//START/End D-4383 29-Jan-2016 Added by Raviteja - Adding Database.stateful
//global class SP_PopConsolidationBatchMain implements Database.Batchable<sObject>, Database.AllowsCallouts {    
global class SP_PopConsolidationBatchMain implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {    

    global final Id JOB_ID;
    
    //START UD-0430 24/04/2015 Nitin Khanna : adding Date reconfigurability
    global Boolean overrideFlg = false;
    global Date ovdFromDate = Date.today();
    global Date ovdToDate;   //START / End HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of Todate 
    global Boolean isMiroManualRun = False;  //START / End HotFix 03-Aug-2015 Added by Raviteja - applying New Logic of MIRO ManualRun     
    //START/End D-4383 29-Jan-2016 Added by Raviteja - created mapPubIssueDate to store  Pub and Pub issue dates
    global Map<Id,Set<Date>> mapPubIssueDate = New Map<Id,Set<Date>>();            

    global SP_PopConsolidationBatchMain(Id jobID, Date fromDate){
        JOB_ID = jobID;
        overrideFlg = true;
        ovdFromDate = fromDate;
    }
    //END UD-0430 24/04/2015 Nitin Khanna
    
    //START HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of Todate 
    //START HotFix 03-Aug-2015 Added by Raviteja - applying New Logic of MIRO ManualRun 
    //global SP_PopConsolidationBatchMain(Id jobID, Date fromDate, Boolean Miromanualrun){
    global SP_PopConsolidationBatchMain(Id jobID, Date fromDate, Date toDate, Boolean Miromanualrun){
        // Importnat Note: Fromdate should be expected date + 1 day . Eg: if you want run from 12-Aug-2105 to 13-Aug-2105 , Request  should be as fromDate = 11-Aug-2105 and toDate = 13-Aug-2105
        JOB_ID = jobID;
        overrideFlg = true;
        ovdFromDate = fromDate;
        isMiroManualRun = True;
        ovdToDate = toDate; //START / End HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of Todate 
    }
    // End HotFix 03-Aug-2015 Added by Raviteja
    // End HotFix 17-Aug-2015 Added by Raviteja
    global SP_PopConsolidationBatchMain(Id jobID){
      JOB_ID = jobID;
    }
   
    global Database.QueryLocator start(Database.BatchableContext BC) {     
        
        //START/End UD-3349 15-Dec-2015 Added by Nitin Khanna- added Zuora__Account__r.Id in SOQL
        //Modifications for MIRO to include address specific details
        String query = 'SELECT Id, Name, qty__c, Product_Code__c, Vendor_1__c, Vendor_1__r.Vendor_Code__c, Vendor_1__r.Vendor_Group__c, '; //START/END 02/20/15 D-2297 KEVASCO Replaced AccountNumber with Vendor_Code__c
        query       += ' Recipient_Contact__r.Address__r.RecordType.DeveloperName, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, ';
        query       += ' Main_Package_1__r.Package_Type__c, Main_Package_1__r.Package_Price__c, Main_Package_1__r.Frequency_Identifier__c, ';
        query       += ' Recipient_Contact__r.Address__r.Postal_Code__r.Address_Type__c, Zuora__CustomerAccount__r.Attention_To_Care_Of_Indicator__c, ';
        query       += ' Recipient_Contact__r.Address__r.Postal_Code__r.Name, Vendor_1__r.Mailing_Agent_Code__c, ';
        //START D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration. 
         //START / End HotFix 18-Aug-2015 Added by Raviteja - Added Frequency_1__c in SOQL
        //query       += ' Delivered_By_1__c, Sponsor_1__c, Other_PaymentMethod_1__c, Ph_d__c, Ph_e__c, Frequency_1__c,Zuora__Account__r.Id '; 
        query       += ' Delivered_By_1__c, Sponsor_1__c, Other_PaymentMethod_1__c, Ph_d__c, Ph_e__c, Frequency_1__c,Zuora__Account__C '; 
        //END D-1960 and D-1686 12/02/15 Kevin Evasco
        
        //START D-2622 UD-0430 24/04/2015 Nitin Khanna : adding the delivered by criteria
        //START UD-0431 05/05/2015 Wenjun : checking Sub End Date instead of Status
        query       += ' FROM Zuora__Subscription__c WHERE Subscription_Type__c  = \'Publication\' and Delivered_By_1__c IN (\'Vendor\',\'Mailing Agent\') '; 
        //query       += ' AND  Vendor_1__r.Vendor_Code__c = \'0001C\''  ;//START / End HotFix 01-Feb-2015 Added by Raviteja - applying vendor_number__c filter for Testing purpose
        query       += ' AND (Zuora__SubscriptionEndDate__c > :ovdFromDate OR Zuora__SubscriptionEndDate__c = NULL) ';        
       
        //END UD-0431 05/05/2015 Wenjun 
        //END D-2622 UD-0430 24/04/2015 Nitin Khanna
        
        query       += ' AND Vendor_1__c != NULL';         
        //query       += ' Limit 10 '  ;//START / End HotFix 01-Feb-2015 Added by Raviteja - applying Limit for Testing purpose
        
        System.debug('query : '+query);
        
        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> lstSubs) {
        /************************** Variable Definitions ***********************************************/
        Map<Id, Zuora__Subscription__c> mapSubIdToObj = new Map<Id, Zuora__Subscription__c>();
        Set<String> setProductCodes = new Set<String>();
        Map<String, Set<Id>> mapProdCodeToPubIds = new Map<String, Set<Id>>();
        Map<Id, Set<Id>> mapSubIdToPubIds = new Map<Id, Set<Id>>();
        Set<Id> setPublicationIds = new Set<Id>();
        Map<Id, Publication__c> mapPubIdToObj = new Map<Id, Publication__c>();
        Map<Id, List<Date>> mapPubIdToPOPDates = new Map<Id, List<Date>>();
        Map<Id, Set<Date>> mapPubIdToNonPubDates = new Map<Id, Set<Date>>();
        Map<String, Set<Date>> mapPubCodeToPreRunDates = new Map<String, Set<Date>>();
        Map<Id, PubIssueHelper.PublicationPattern> mapPubIdToPubPattern = new Map<Id, PubIssueHelper.PublicationPattern>();
        Set<Date> setHolidays = new Set<Date>();
        Map<Id, List<Subscription_Temp_Stop__c>> mapSubIdToTStops = new Map<Id, List<Subscription_Temp_Stop__c>>();
        List<Vendor_POP_Batch__c> lstPOPData = new List<Vendor_POP_Batch__c>();
        List<BT_CO_MIRO_SubscriptionIssueFile__c> lstMIROData = new List<BT_CO_MIRO_SubscriptionIssueFile__c>();
        Map<String, BT_CO_MIRO_SubscriptionIssueFile__c> mapMiroDets = new Map<String, BT_CO_MIRO_SubscriptionIssueFile__c>();
        Map<Id,COAWrapper> mapSubToCOA = new  Map<Id,COAWrapper>();
        Date maxDateToCheck = ovdFromDate.addDays(90); //START END D-3631 29/09/15 Wenjun Hotfix to support full back dated run
        /************************** Get Publications based on Subscriptions ****************************/    
     //START UD-3043 07-Oct-2015 Added by Raviteja - Applying Try catch block in order to handle the Exception , failed records and Abort the job if exception occured 
    try{             
        for(Zuora__Subscription__c zSub : lstSubs) {
            mapSubIdToObj.put(zSub.Id, zSub);
            if(zSub.Product_Code__c != null)
                setProductCodes.add(zSub.Product_Code__c);
        }
        
        //Retrieve Product Code to Publication Mapping
        //Filter by Product Category. For All-in-one, the Print Publication is still "Print"
        //Nitin Khanna : 13-3-2015 : UD-0341 : using platform type instead of product category as the latter field is now obselete
        //for(Product_Publication__c prodPub : [SELECT ZProduct__r.ProductCode__c, Publication_Code__c, Publication_Code__r.Publication_Code__c 
        //         FROM Product_Publication__c WHERE ZProduct__r.ProductCode__c in :setProductCodes AND Publication_Code__r.Product_Category__c = 'Print'])
        for(Product_Publication__c prodPub : [SELECT ZProduct__r.ProductCode__c, Publication_Code__c, Publication_Code__r.Publication_Code__c 
                //Nitin Khanna : 31-3-2015 : Start : UD-0341 : Removing the platform type of the publication to capture all publications
                //FROM Product_Publication__c WHERE ZProduct__r.ProductCode__c in :setProductCodes AND Publication_Code__r.Platform_Type__c = 'Print'])
                FROM Product_Publication__c WHERE ZProduct__r.ProductCode__c in :setProductCodes])
        {
            //Nitin Khanna : 31-3-2015 : End : UD-0341 : Removing the platform type of the publication to capture all publications
            String productCode = prodPub.ZProduct__r.ProductCode__c;
            Id pubId = prodPub.Publication_Code__c;
            setPublicationIds.add(pubId);
            if(!mapProdCodeToPubIds.containsKey(productCode))
                mapProdCodeToPubIds.put(productCode, new Set<Id> {pubId});
            else
                mapProdCodeToPubIds.get(productCode).add(pubId);
        }
        //Nitin Khanna : 13-3-2015 : UD-0341 : End
        
        System.debug('=====> mapProdCodeToPubIds: ' + mapProdCodeToPubIds);
        //START / End UD-3098 - HotFix 14-Oct-2015 Added by Raviteja - Adding  Platform_Type__c field in SOQL
        mapPubIdToObj = new Map<Id, Publication__c>([SELECT Id, Name, Publication_Code__c, Published_Days__c, Publication_Next_Start_Date__c, Platform_Type__c,  
                                                    Frequency_Code__c, Public_Holiday_Weekend_Pub_Indicator__c, Public_Holiday_Weekday_Pub_Indicator__c 
                                                    FROM Publication__c WHERE ID in :setPublicationIds AND Publication_Next_Start_Date__c != null]);
        
        //Generate Sub ID to Publication Codes mapping
        for(Zuora__Subscription__c zSub : lstSubs) {
            if(mapProdCodeToPubIds.containsKey(zSub.Product_Code__c))
                mapSubIdToPubIds.put(zSub.Id, mapProdCodeToPubIds.get(zSub.Product_Code__c));
        }
        
        /*************************** Generate Date Range for each Publication ************************/
        //Only retrieve Non Pub Dates in the next 90 days
        //START D-3631 29/09/15 Wenjun Hotfix to support full back dated run - use maxDateToCheck instead of NEXT_90_DAYS
        for(Non_Publication_Day__c pubDay : [SELECT Id, Publication__c, Publication_Code__c, Non_Publication_Date__c 
              FROM Non_Publication_Day__c WHERE Publication__c IN : setPublicationIds 
              AND Non_Publication_Date__c > :ovdFromDate AND Non_Publication_Date__c <= :maxDateToCheck])
        //END D-3631 29/09/15 Wenjun Hotfix to support full back dated run
        {
            if(!mapPubIdToNonPubDates.containsKey(pubDay.Publication__c))
                mapPubIdToNonPubDates.put(pubDay.Publication__c, new Set<Date> {pubDay.Non_Publication_Date__c});
            else
                mapPubIdToNonPubDates.get(pubDay.Publication__c).add(pubDay.Non_Publication_Date__c);
        }
        System.debug('=====> mapPubIdToNonPubDates: ' + mapPubIdToNonPubDates);
        System.debug('=====>  Size : ' + mapPubIdToNonPubDates.size());
        
        //Only retrieve Public Holidays in the next 90 days
        //START D-3631 29/09/15 Wenjun Hotfix to support full back dated run - use maxDateToCheck instead of NEXT_90_DAYS
        for (Public_Holiday__c tmp : [SELECT Holiday_Date__c FROM Public_Holiday__c 
                                      WHERE Holiday_Date__c > :ovdFromDate AND Holiday_Date__c <= :maxDateToCheck]) 
        //END D-3631 29/09/15 Wenjun Hotfix to support full back dated run
        { 
            setHolidays.add(tmp.Holiday_Date__c);
        }
        
        System.debug('=====> setHolidays: ' + setHolidays);
        System.debug('=====>  Size : ' +setHolidays.size());
        
        //Check Preivous Runs for the next 90 days
        // START  D-4383 29-Jan-2016 Added by Raviteja - Applying the logic of pub issue date by using POP History records
        /*
        //START / End HotFix 26-Aug-2015 Added by Raviteja - added Subscription_Name__c = null in SOQL 
        //START D-3631 29/09/15 Wenjun Hotfix to support full back dated run - use maxDateToCheck instead of NEXT_90_DAYS
        for (AggregateResult ar :[SELECT Publication_Code__c, Publication_Issue_Date__c, COUNT(ID) FROM Vendor_POP_Batch__c 
                                 WHERE Subscription_Name__c = null AND CreatedDate < TODAY 
                                 AND Publication_Issue_Date__c > :ovdFromDate AND Publication_Issue_Date__c <= :maxDateToCheck
                                 GROUP BY Publication_Code__c, Publication_Issue_Date__c])
        //END D-3631 29/09/15 Wenjun Hotfix to support full back dated run
        */
        for (POP_History__c ph : [SELECT Publication_Code__c, Publication_Issue_Date__c  FROM POP_History__c 
                                                // WHERE Publication_Code__c != null AND CreatedDate < TODAY
                                                 WHERE CreatedDate < TODAY
                                                 AND Publication_Issue_Date__c > :ovdFromDate AND Publication_Issue_Date__c <= :maxDateToCheck])

        {   
            String pubCode =  ph.Publication_Code__c;
            Date issueDate =  ph.Publication_Issue_Date__c;
            if(!mapPubCodeToPreRunDates.containsKey(pubCode))
                mapPubCodeToPreRunDates.put(pubCode, new Set<Date> {issueDate});
            else
                mapPubCodeToPreRunDates.get(pubCode).add(issueDate);
        }
                // End  D-4383 29-Jan-2016 Added by Raviteja
        System.debug('=====> mapPubCodeToPreRunDates: ' + mapPubCodeToPreRunDates);
        System.debug('=====>  Size : ' + mapPubCodeToPreRunDates.size());
        
        //Generate Publication Pattern for Daily Publications
        for(Publication__c pubObj : mapPubIdToObj.values())
        {
            if(pubObj.Frequency_Code__c == 'D') //Daily Publication
                mapPubIdToPubPattern.put(pubObj.Id, PubIssueHelper.generatePubPattern(pubObj));
        }
        
        System.debug('=====> mapPubIdToPubPattern: ' + mapPubIdToPubPattern);
        System.debug('=====>  Size : ' + mapPubIdToPubPattern.size());
        
        Date todayDT = Date.today();
    
        //Nitin Khanna : UD-430 : Start : 24-4-2015 :  adding Date reconfigurability
        if(overrideFlg){
            todayDT = ovdFromDate;
            System.debug('=====> Overriding From Date');
        }
        //Nitin Khanna : UD-430 : End : 24-4-2015 :  adding Date reconfigurability
                
        //START D-2914 Wenjun 03/06/15: Check relevant Vendor Assignments COA & COV - the latest record will take precedence 
        //Fetch all the COA Cases
        Set<Id> setCaseIDs = new Set<Id>();
        Map<Id, Address_Assignment__c> mapCaseToAddrAssign = new Map<Id, Address_Assignment__c>();
        List<Case_Subscription__c> lstCaseSubs = [SELECT ID, Name, Case__c, Subscription__c, Case__r.Effective_Date__c, CreatedDate
                       FROM Case_Subscription__c WHERE Subscription__c in :lstSubs AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED 
                       AND Case__r.Effective_Date__c > :todayDT 
                       AND (Case__r.Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD 
                            OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC)];
        
        for(Case_Subscription__c caseSub : lstCaseSubs)
            setCaseIDs.add(caseSub.Case__c);
        
        //Fetch Address Assignment to get Vendor
        //START-End UD-2775 - HotFix 17-Aug-2015 Added by Raviteja - Added Address__r.Postal_Code__r.Name, Address__r.Postal_Code__r.Address_Type__c in SOQL
        for(Address_Assignment__c addrAssign : [SELECT ID, Case__c, Vendor__r.Vendor_Code__c, Vendor__r.Vendor_Group__c , Address__r.Postal_Code__r.Name, Address__r.Postal_Code__r.Address_Type__c   
                    From Address_Assignment__c WHERE Case__c in :setCaseIDs AND Vendor__c != NULL])
         {
              mapCaseToAddrAssign.put(addrAssign.Case__c, addrAssign);  
         }
        
        for(Case_Subscription__c caseSub : lstCaseSubs)
        {
            if(mapCaseToAddrAssign.containsKey(caseSub.Case__c))
            {
                Address_Assignment__c addrAssign = mapCaseToAddrAssign.get(caseSub.Case__c);
                COAWrapper newCOA = new COAWrapper(caseSub.Case__r.Effective_Date__c, caseSub.CreatedDate, 
                                                   addrAssign.Vendor__r.Vendor_Group__c, addrAssign.Vendor__r.Vendor_Code__c);
                //START UD-2775 - HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of House Type and Postal Sector
                newCOA.setHouseType(addrAssign.Address__r.Postal_Code__r.Address_Type__c);
                newCOA.setPostalSector(addrAssign.Address__r.Postal_Code__r.Name);
                //End UD-2775 - HotFix 17-Aug-2015 Added by Raviteja    
                if(mapSubToCOA.containsKey(caseSub.Subscription__c))
                {
                    COAWrapper preCOA = mapSubToCOA.get(caseSub.Subscription__c);
                    if(newCOA.createDT > preCOA.createDT)
                        mapSubToCOA.put(caseSub.Subscription__c, newCOA);
                }
                else
                    mapSubToCOA.put(caseSub.Subscription__c, newCOA);
            }
        }
        
        //Fetch COV Cases
        for(Case_Subscription__c caseSub : [SELECT ID, Name, Case__c, Subscription__c, Case__r.Effective_Date__c, CreatedDate,
                                            Case__r.Vendor__r.Vendor_Code__c, Case__r.Vendor__r.Vendor_Group__c 
                       FROM Case_Subscription__c WHERE Subscription__c in :lstSubs AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED 
                       AND Case__r.Effective_Date__c > :todayDT 
                       AND Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR])
        {
            COAWrapper newCOA = new COAWrapper(caseSub.Case__r.Effective_Date__c, caseSub.CreatedDate, 
                      caseSub.Case__r.Vendor__r.Vendor_Group__c, caseSub.Case__r.Vendor__r.Vendor_Code__c);
            if(mapSubToCOA.containsKey(caseSub.Subscription__c))
            {
                COAWrapper preCOA = mapSubToCOA.get(caseSub.Subscription__c);
                if(newCOA.createDT > preCOA.createDT)
                    mapSubToCOA.put(caseSub.Subscription__c, newCOA);
            }
            else
                mapSubToCOA.put(caseSub.Subscription__c, newCOA);
        }
        //END D-2914 Wenjun 03/06/15
        
        //Finally generate the Publication to POP Consolidation Dates mapping
        for(Publication__c pubObj : mapPubIdToObj.values())
        {
            Date nextIssueDate = pubObj.Publication_Next_Start_Date__c;
            System.debug('=====> Pub next Start Date: ' + pubObj.Publication_Next_Start_Date__c);
            System.debug('=====> Pub Frequency Code: ' + pubObj.Frequency_Code__c);
            System.debug('=====> Pub Code: ' + pubObj.publication_code__c);
            
            List<Date> lstDates = new List<Date>();
            
            //Date Range: start_date = Today + 1, end_date = next_issue_date - 1
            if(pubObj.Frequency_Code__c == 'D') //Daily
            {
                for(Date tmpDate = todayDT.addDays(1); tmpDate < nextIssueDate; tmpDate = tmpDate.addDays(1))
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'W') //Weekly
            {
                for(Date tmpDate = nextIssueDate.addDays(-7); tmpDate > todayDT; tmpDate = tmpDate.addDays(-7))
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'F') //Fortnightly
            {
                for(Date tmpDate = nextIssueDate.addDays(-14); tmpDate > todayDT; tmpDate = tmpDate.addDays(-14))
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'M') //Monthly
            {
                for(Date tmpDate = nextIssueDate.addMonths(-1); tmpDate > todayDT; tmpDate = tmpDate.addMonths(-1))
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'B') //Bi-Monthly
            {
                for(Date tmpDate = nextIssueDate.addMonths(-2); tmpDate > todayDT; tmpDate = tmpDate.addMonths(-2))
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'Q') //Quarterly
            {
                for(Date tmpDate = nextIssueDate.addMonths(-3); tmpDate > todayDT; tmpDate = tmpDate.addMonths(-3))
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'H') //Half-Yearly
            {
                for(Date tmpDate = nextIssueDate.addMonths(-6); tmpDate > todayDT; tmpDate = tmpDate.addMonths(-6))
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'Y') //Yearly
            {
                for(Date tmpDate = nextIssueDate.addYears(-1); tmpDate > todayDT; tmpDate = tmpDate.addYears(-1))
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern))
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                }
            }
            
            if(!lstDates.isEmpty())
                mapPubIdToPOPDates.put(pubObj.Id, lstDates);
                            
            System.debug('===========> mapPubIdToPOPDates: ' + mapPubIdToPOPDates);
            System.debug('===========> Size: ' + mapPubIdToPOPDates.size());
        }
        
        /*************************** Retrieve Temp Stops ************************/
        //START D-3631 29/09/15 Wenjun Hotfix to support full back dated run - use maxDateToCheck instead of NEXT_90_DAYS
        for( Subscription_Temp_Stop__c tempStopObj : [SELECT Subscription__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Qty__c,
                                                      Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Qty__c 
                                                      FROM Subscription_Temp_Stop__c 
                                                      WHERE Subscription__c IN :lstSubs AND Temp_Stop__r.Cancelled__c = false 
                                                      //START D-3946 18-Nov-2015 Added by Raviteja  - removing the logic of Max date check
                                                      //AND Temp_Stop__r.Restart_Date__c >:todayDT AND Temp_Stop__r.Restart_Date__c <= :maxDateToCheck])
                                                      AND Temp_Stop__r.Restart_Date__c >:todayDT])
                                                      //End D-3946 18-Nov-2015 Added by Raviteja
        //END D-3631 29/09/15 Wenjun Hotfix to support full back dated run
        {
            if(!mapSubIdToTStops.containsKey(tempStopObj.Subscription__c))
                mapSubIdToTStops.put(tempStopObj.Subscription__c, new List<Subscription_Temp_Stop__c> {tempStopObj});
            else
                mapSubIdToTStops.get(tempStopObj.Subscription__c).add(tempStopObj);
        }
        
        System.debug('===========> mapSubIdToTStops: '+ mapSubIdToTStops);
        System.debug('===========> Size: ' + mapSubIdToTStops.size());
        
        System.debug('=============>mapPubIdToPOPDates: ' + mapPubIdToPOPDates);
        /*************************** Processing for each Subscription ************************/
        for(Zuora__Subscription__c sub : lstSubs) 
        {
            Set<Id> setPubIds = mapSubIdToPubIds.get(sub.Id);
            if(setPubIds != null && !setPubIds.isEmpty())
            {
                Boolean hasTempStop = mapSubIdToTStops.containsKey(sub.Id);
                System.debug(setPubIds + ':' + setPubIds.size());
                //Retrieve the eligible dates for each pub
                for(Id pubId : setPubIds)
                {
                    List<Date> lstPOPDates = mapPubIdToPOPDates.get(pubId);
                    if(lstPOPDates != null && !lstPOPDates.isEmpty())
                    {
                        //Get User Subscription Frequency 
                        PubIssueHelper.PublicationPattern userPattern = PubIssueHelper.generateSubPattern(mapPubIdToObj.get(pubId), sub);
                        
                        System.debug(userPattern);
                        
                        for(Date popDate : lstPOPDates)
                        {
                            //Verify Subscription Start Date / End Date
                            System.debug('=====> Subscrn Start Date : '+sub.Zuora__SubscriptionStartDate__c);
                            System.debug('=====> Subscrn Stop  Date : '+sub.Zuora__SubscriptionEndDate__c);
                            System.debug('=====> Subscrn POPDate    : '+popDate);
                            System.debug('=====> Is pop date a holiday : ' + setHolidays.contains(popDate));
                            System.debug('=====> Is phd : ' + PubIssueHelper.isHolidayPublishDate(userPattern, popDate));
                            System.debug('=====> Is publn printed on the date : ' + PubIssueHelper.isPublishDate(userPattern, popDate));
                            
                            //START HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of Todate
                            /*if(popDate < sub.Zuora__SubscriptionStartDate__c || (sub.Zuora__SubscriptionEndDate__c != null && popDate > sub.Zuora__SubscriptionEndDate__c))
                                continue;
                                */                             
                             System.debug('ovdToDate ::: '+ovdToDate);
                             System.debug('isMiroManualRun ::: '+isMiroManualRun);
                              
                             if(!isMiroManualRun){
                                 if(popDate < sub.Zuora__SubscriptionStartDate__c || (sub.Zuora__SubscriptionEndDate__c != null && popDate > sub.Zuora__SubscriptionEndDate__c))
                                continue;
                             }
                             else{                                
                                 if((popDate < sub.Zuora__SubscriptionStartDate__c || (sub.Zuora__SubscriptionEndDate__c != null && popDate > sub.Zuora__SubscriptionEndDate__c)) || ovdToDate < popDate)
                                    continue;                               
                             }   
                             System.debug('continue after if ::: ');     
                            //End HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of Todate
                            
                            //Verify Holiday
                            if(setHolidays.contains(popDate) && !PubIssueHelper.isHolidayPublishDate(userPattern, popDate))
                                continue;
                            
                            //Check User Subscription Frequency 
                            if(!PubIssueHelper.isPublishDate(userPattern, popDate))
                                continue;
                            
                            //START D-2269 18/02/15 Wenjun : Fix Temp Stop Qty Issue
                            Integer tempStopQty = 0;
                            //START UD-3098 - HotFix 14-Oct-2015 Added by Raviteja - Non print publciations tempStopQty will be 0
                            //if(hasTempStop) //Having Temp Stops
                            if(hasTempStop && mapPubIdToObj.get(pubId) != Null && mapPubIdToObj.get(pubId).Platform_Type__c == 'Print') //Having Temp Stops
                                tempStopQty = getTempStopQty(popDate, mapSubIdToTStops.get(sub.Id));
                            //End UD-3098 - HotFix 14-Oct-2015 Added by Raviteja 
                            //Creating POP Record
                            System.debug('====>Astalavsita : '+mapPubIdToObj.get(pubId)+':'+popDate+':'+tempStopQty);   
                            //START HotFix 03-Aug-2015 Added by Raviteja - applying New Logic of MIRO ManualRun 
                            //lstPOPData.add(createPOPRecord(sub, mapPubIdToObj.get(pubId), popDate, tempStopQty, mapSubToCOA.get(sub.Id))); 
                            if(!isMiroManualRun){                               
                                //START D-4383 29-Jan-2016 Added by Raviteja - Caputring Pub Issue Date
                                if(pubId != Null && mapPubIdToObj.get(pubId).Publication_Code__c != Null){
                                    if(!mapPubIssueDate.containsKey(pubId))
                                        mapPubIssueDate.put(pubId, new Set<Date> {popDate});
                                    else
                                        mapPubIssueDate.get(pubId).add(popDate);
                                }
                                //End D-4383 29-Jan-2016 Added by Raviteja
                                lstPOPData.add(createPOPRecord(sub, mapPubIdToObj.get(pubId), popDate, tempStopQty, mapSubToCOA.get(sub.Id))); 
                            }
                            //End HotFix 03-Aug-2015 Added by Raviteja
                            //Creating MIRO Record
                            
                            //Nitin Khanna : UD-3349 : populating pre grouped miro data , grouping to be based on subscribers : Start
                            BT_CO_MIRO_SubscriptionIssueFile__c miroRec = createMIRORecord(sub, mapPubIdToObj.get(pubId), popDate, tempStopQty, mapSubToCOA.get(sub.Id));
                            String miroKey = miroRec.Publication_Code__c + ',' +  String.valueOf(miroRec.Publication_Issue_Date__c) + ',' + miroRec.postal_sector__c;
                            miroKey += ',' + miroRec.vendor_number__c + ',' + miroRec.office_house_mail_indicator__c;
                            miroKey += ',' + miroRec.house_type__c + ',' + miroRec.sub_channel_code__c + ',' + miroRec.subscriberId__c;                            
                            
                            
                            BT_CO_MIRO_SubscriptionIssueFile__c miroRecTemp = mapMiroDets.get(miroKey);                            
                           
                            
                            if(miroRecTemp == null){
                                    mapMiroDets.put(miroKey, miroRec);
                                }
                            else {                               
                                //miroRecTemp.subscriber_count__c += miroRec.subscriber_count__c;
                                miroRecTemp.subscription_copies__c += miroRec.subscription_copies__c;
                            }
                            //lstMIROData.add(createMIRORecord(sub, mapPubIdToObj.get(pubId), popDate, tempStopQty, mapSubToCOA.get(sub.Id))); 
                            //Nitin Khanna : UD-3349 : populating pre grouped miro data , grouping to be based on subscribers : End
                            //END D-2269 18/02/15 Wenjun
                        }
                    }
                }
            }
        }
        
        /*************************** Insert Data into DB ************************/
        if(!lstPOPData.isEmpty()) 
        {
            List<Database.SaveResult > saveResults = Database.insert(lstPOPData, false); 
            for(Database.SaveResult result : saveResults) {
                if(!result.isSuccess()) 
                    System.debug(Logginglevel.WARN, 'Insert POP Failed: ' + result);
            } 
        }
        
        //Nitin Khanna : UD-3349 : populating pre grouped miro data , grouping to be based on subscribers : Start
        lstMIROData = mapMiroDets.values();
        //Nitin Khanna : UD-3349 : populating pre grouped miro data , grouping to be based on subscribers : End
        
        if(!lstMIROData.isEmpty())
        {
            List<Database.SaveResult > saveResults = Database.insert(lstMIROData, false); 
            for(Database.SaveResult result : saveResults) {
                if(!result.isSuccess()) 
                    System.debug(Logginglevel.WARN, 'Insert MIRO Failed: ' + result);
            } 
        }
      } 
      catch (Exception e) {                
            BatchJobHelper.handleException(lstSubs,e,SP_PopConsolidationBatchMain.class.getName(),'SP012',JOB_ID,BC.getJobId(),True);
        } 
     //End UD-3043 07-Oct-2015 Added by Raviteja    
    }        
               
    global void finish(Database.BatchableContext BC) {   
        //Start the Main Process for POP - Default Size 2
        //START HotFix 03-Aug-2015 Added by Raviteja - applying New Logic of MIRO ManualRun 
        /*
        SP_PopConsolidationBatchFinal batchJob = new SP_PopConsolidationBatchFinal(JOB_ID);
        Database.executeBatch(batchJob, 2);
        */
         
        //START D-4383 - 29-Jan-2016 Added by Raviteja - Inserting POP History records 
        List<POP_History__c> lstPOPHistory = New List<POP_History__c>();
        for(Id pubid : mapPubIssueDate.keySet()){
            for(Date pubDate: mapPubIssueDate.get(pubid)){
                POP_History__c ph = New POP_History__c();
                ph.Publication__c = pubid;
                ph.Publication_Issue_Date__c = pubDate;
                if(ph != Null)
                    lstPOPHistory.add(ph);              
            }           
        }
        if(!lstPOPHistory.isEmpty())
            insert lstPOPHistory;
        //End D-4383 - 29-Jan-2016 Added by Raviteja - Inserting POP History records
        
         //START UD-3043 07-Oct-2015 Added by Raviteja - Stop the chain batch job proccess if current batch job status not equals to Completed or NumberOfErrors > 0
         Id jobID = BC.getJobId();
         Boolean isJobSucess = BatchJobHelper.isJobSucesss(jobID);
         if(isJobSucess){
             if(!isMiroManualRun){           
                 SP_PopConsolidationBatchFinal batchJob = new SP_PopConsolidationBatchFinal(JOB_ID);
                 Database.executeBatch(batchJob, 2);
                
             }
         }
        //End UD-3043 07-Oct-2015 Added by Raviteja 
        //End HotFix 03-Aug-2015 Added by Raviteja
         
    }
    
    private Boolean isPOPDate(Publication__c publication, Date inputDate, Map<Id, Set<Date>> mapPubIdToNonPubDates, 
            Map<String, Set<Date>> mapPubCodeToPreRunDates, Set<Date> setHolidays, Map<Id, PubIssueHelper.PublicationPattern> mapPubIdToPubPattern)
    {
        //Verify Non-Publication Date
        System.debug('Checking for Non-Pub Days');
        if(mapPubIdToNonPubDates.containsKey(publication.Id) && mapPubIdToNonPubDates.get(publication.Id).contains(inputDate))
            return false;
        
        //Verify Previous Run Date
        System.debug('Checking for previous runs');
        if(mapPubCodeToPreRunDates.containsKey(publication.Publication_Code__c) 
            && mapPubCodeToPreRunDates.get(publication.Publication_Code__c).contains(inputDate))
            return false;
            
        //Verify Holiday
        System.debug('Checking for Holidays');
        if(setHolidays.contains(inputDate) && !PubIssueHelper.isHolidayPublishDate(publication, inputDate))
            return false;
        
        //Verify Publish Days for Publications : cater for various frequency
        System.debug('Checking for Frequency');
        if(publication.Frequency_Code__c == 'D') //Daily Publication
        {
            PubIssueHelper.PublicationPattern pattern = mapPubIdToPubPattern.get(publication.Id);
            System.debug('is publish date :' + PubIssueHelper.isPublishDate(pattern, inputDate)); 
            return PubIssueHelper.isPublishDate(pattern, inputDate);
        }
        else 
            return true; //Frequency already catered in the for loop for Non-daily Publications
        
        System.debug('ALL PASS!!!');
        return true;
    }
    
    //START D-2269 18/02/15 Wenjun : Fix Temp Stop Qty Issue
    public Integer getTempStopQty(Date inputDate, List<Subscription_Temp_Stop__c> lstTempStops)
    {
        for(Subscription_Temp_Stop__c tempStop : lstTempStops)
        {
            //Temp Stop Date Range: Temp_Stop_Date__c to Restart_Date__c minus 1 day
            if(tempStop.Temp_Stop__r.Temp_Stop_Date__c <= inputDate && tempStop.Temp_Stop__r.Restart_Date__c > inputDate)
                return tempStop.Temp_Stop__r.Qty__c == null ? 0 : Integer.valueOf(tempStop.Temp_Stop__r.Qty__c);
        }
        
        return 0;
    }
    
    private Vendor_POP_Batch__c createPOPRecord(Zuora__Subscription__c sub, Publication__c pub, Date popDate, 
                                                Integer tempStopQty, COAWrapper coaRec)   
    {                                               
        //Nitin Khanna : 9-Sept : UD-2264 : Hotfix : Start : including internals/Airlines as local subscriptions
        //Boolean isLocal = (sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Local');
          Boolean isLocal = (sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Local' || sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Airline' || sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Internal');
        //Nitin Khanna : 9-Sept : UD-2264 : Hotfix : End : including internals/Airlines as local subscriptions
        
        Boolean isOverseas = (sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Overseas');
        
        //Grace Period Subscription / Free List Payment Type / Zero Charge Subscription
        //Grace Period Subscription / Free List Payment Type / Zero Charge Subscription
        //START / End UD-1920 HotFix 26-Aug-2015 Added by Raviteja -Updated Other_PaymentMethod_1__c from 'Free List' to 'FreeList'
        //Boolean isFreeList = sub.Other_PaymentMethod_1__c == 'Free List' || sub.Main_Package_1__r.Package_Price__c == 0.0 ||
        //START UD-3043 07-Oct-2015 Added by Raviteja - Updating the logic for freelist 
        Boolean isFreeList = sub.Other_PaymentMethod_1__c == 'FreeList'? True : False;
        //End UD-3043 07-Oct-2015 Added by Raviteja
        Vendor_POP_Batch__c popRec = new Vendor_POP_Batch__c();
        
        //START UD-0430 24/04/15 Nitin Khanna : adding Mailing_Agent delivered as the criteria
        System.debug('===========> Vendor Code + Group : ' + sub.Vendor_1__r.Vendor_Code__c +' : '+sub.Vendor_1__r.Vendor_Group__c);
        if(sub.Delivered_By_1__c == 'Vendor')
        {
            //Check COA / COV
            if(coaRec != null && coaRec.effectiveDT != null && coaRec.effectiveDT <= popDate)
            {
                popRec.Vendor_Number__c = coaRec.vendorCode;
                popRec.Vendor_Group__c = coaRec.vendorGroup;
            }
            else
            {
                popRec.Vendor_Number__c = sub.Vendor_1__r.Vendor_Code__c; //START/END 02/20/15 D-2297 KEvasco Replaced AccountNumber with Vendor_Code__c
                popRec.Vendor_Group__c = (sub.Vendor_1__r.Vendor_Group__c == null) ? 'V' : sub.Vendor_1__r.Vendor_Group__c; 
            }           
        }
        else 
        {//Mailing Agent
            String mCode = 'MLAGN';
            /*if(sub.Vendor_1__r.Mailing_Agent_Code__c != null)
            {
                if(sub.Vendor_1__r.Mailing_Agent_Code__c.length() > 5)
                    mCode = sub.Vendor_1__r.Mailing_Agent_Code__c.substring(0,5);
                else
                    mCode = sub.Vendor_1__r.Mailing_Agent_Code__c;
            }*/
            popRec.Vendor_Number__c = mCode;
            popRec.Vendor_Group__c = 'M'; 
        }
        System.debug('===========> Vendor Code + Group :' + popRec.Vendor_Number__c +' : '+popRec.Vendor_Group__c);
        //END UD-0430 24/04/15 Nitin Khanna
        
        popRec.Publication_Code__c = pub.Publication_Code__c;
        //popRec.Vendor_Group__c = (sub.Vendor_1__r.Vendor_Group__c == null) ? 'V' : sub.Vendor_1__r.Vendor_Group__c; //START END UD-430 24/04/15 Nitin:  adding Mailing_Agent delivered as the criteria
        popRec.Publication_Issue_Date__c = popDate;
        popRec.Subscription_Name__c = sub.Name;
        popRec.Subscription__c = sub.Id; //START/End D-3969 23-Nov-2015 Added by Raviteja  - Inserting Logic for Subscription__c
        popRec.External_Id__c = sub.Vendor_1__r.Vendor_Code__c + pub.Publication_Code__c + sub.Name; //START/END 02/20/15 D-2297 KEvasco Replaced AccountNumber with Vendor_Code__c
        
        Integer qtyToPrint = (sub.qty__c == null) ? 0 : Integer.valueOf(sub.qty__c);
        qtyToPrint = qtyToPrint - tempStopQty; //Minus Temp Stop Quantity
        
        popRec.Total_Direct_Subscriptions__c = qtyToPrint;
        popRec.Total_Sponsored_Copies__c = sub.Sponsor_1__c ? qtyToPrint : 0;
        if(isLocal) {
            //Nitin Khanna : 9-Sept : UD-2268 : Hotfix : Start : not adding freelist copies to the total
            //popRec.Total_Local_Subscription_Copies__c = qtyToPrint;
            popRec.Total_Local_Subscription_Copies__c = isFreeList ? 0 : qtyToPrint;
            //Nitin Khanna : 9-Sept : UD-2268 : Hotfix : End : not adding freelist copies to the total            
            popRec.Total_Local_Freelist_Copies__c = isFreeList ? qtyToPrint : 0;
            popRec.Total_Overseas_Subscription_Copies__c = 0;
            popRec.Total_Overseas_Freelist_Copies__c = 0;
        }
        else if(isOverseas) {
            popRec.Total_Local_Subscription_Copies__c = 0;
            popRec.Total_Local_Freelist_Copies__c = 0;
            //Nitin Khanna : 9-Sept : UD-2268 : Hotfix : Start : not adding freelist copies to the total
            //popRec.Total_Overseas_Subscription_Copies__c = qtyToPrint;
              popRec.Total_Overseas_Subscription_Copies__c = isFreeList ? 0 : qtyToPrint;
            //Nitin Khanna : 9-Sept : UD-2268 : Hotfix : Start : not adding freelist copies to the total            
            popRec.Total_Overseas_Freelist_Copies__c = isFreeList ? qtyToPrint : 0;
        }
        else{
            popRec.Total_Local_Subscription_Copies__c = 0;
            popRec.Total_Local_Freelist_Copies__c = 0;
            popRec.Total_Overseas_Subscription_Copies__c = 0;
            popRec.Total_Overseas_Freelist_Copies__c = 0;
        }
        return popRec;
    }
    
    private BT_CO_MIRO_SubscriptionIssueFile__c createMIRORecord(Zuora__Subscription__c sub, Publication__c pub, 
                                                                Date popDate, Integer tempStopQty, COAWrapper coaRec)    
    {
        //Nitin Khanna : UD-3359 : Airlines to be treated as local for MIRO : Start
        Boolean isLocal = (sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Local' || sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Airline');
        Boolean isInternal = (sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Internal');
        Boolean isOverseas = (sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Overseas');
        //Nitin Khanna : UD-3359 : Airlines to be treated as local for MIRO : End
        String deliveredBy = sub.Delivered_By_1__c;
        
        //START UD-2775 - HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of House Type and Postal Sector
        String houseType;
        String postalSector;    
        houseType = ConstantsSLB.getDefaultDeliveryChargeType(sub.Recipient_Contact__r.Address__r.Postal_Code__r.Address_Type__c);
        if(sub.Recipient_Contact__r.Address__r.Postal_Code__r.Name != null)
            postalSector = sub.Recipient_Contact__r.Address__r.Postal_Code__r.Name.substring(0,2);
        //End UD-2775 - HotFix 17-Aug-2015 Added by Raviteja 
        //Grace Period Subscription / Free List Payment Type / Zero Charge Subscription
        //START / End UD-1920 HotFix 26-Aug-2015 Added by Raviteja -Updated Other_PaymentMethod_1__c from 'Free List' to 'FreeList'
        //Boolean isFreeList = sub.Other_PaymentMethod_1__c == 'Free List' || sub.Main_Package_1__r.Package_Price__c == 0.0 ||
        Boolean isFreeList = sub.Other_PaymentMethod_1__c == 'FreeList' || sub.Main_Package_1__r.Package_Price__c == 0.0 ||
                             sub.Main_Package_1__r.Package_Type__c == 'Grace Period';
    
        String subChannelCode = '';
        BT_CO_MIRO_SubscriptionIssueFile__c miroDets = new BT_CO_MIRO_SubscriptionIssueFile__c();
                
        if(deliveredBy == GlobalVariableClass.OLIDELIVEREDBY_VENDOR)
        {
            if(isLocal || isInternal)
                subChannelCode = 'LDS';
            if(isOverseas)
                subChannelCode = 'ODS';
            if(sub.Sponsor_1__c)
                subChannelCode = 'SDS';
            //START UD-2775 - HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of House Type and Postal Sector
            //Check COA / COV
            /*
            if(coaRec != null && coaRec.effectiveDT != null && coaRec.effectiveDT <= popDate)
                miroDets.Vendor_Number__c = coaRec.vendorCode;
            else
                miroDets.Vendor_Number__c = sub.Vendor_1__r.Vendor_Code__c; 
            */
            if(coaRec != null && coaRec.effectiveDT != null && coaRec.effectiveDT <= popDate){
                //START UD-3300 and D-3989  24-Nov-2015 Added by Raviteja  - Updating the logic for Online Publications 
                //miroDets.Vendor_Number__c = coaRec.vendorCode;
                if(pub.Platform_Type__c != 'Print'){
                    miroDets.Vendor_Number__c = 'MLAGN';
                }
                else 
                    miroDets.Vendor_Number__c = coaRec.vendorCode;    
                //End  UD-3300 and D-3989 24-Nov-2015 Added by Raviteja 
                //START D-3631 29/09/15 Wenjun Hotfix : Fix Null Point Exception
                if(coaRec.houseType != null)
                    houseType = ConstantsSLB.getDefaultDeliveryChargeType(coaRec.houseType);
                if(coaRec.postalSector != null)
                    postalSector = coaRec.postalSector.substring(0,2);
                //END D-3631 29/09/15 Wenjun Hotfix 
                }
            //START UD-3300 and D-3989 24-Nov-2015 Added by Raviteja  - Updating the logic for Online Publications    
            /*else
                miroDets.Vendor_Number__c = sub.Vendor_1__r.Vendor_Code__c; 
            */    
            else if(pub.Platform_Type__c != 'Print'){
                    miroDets.Vendor_Number__c = 'MLAGN';
                }
                else 
                    miroDets.Vendor_Number__c = sub.Vendor_1__r.Vendor_Code__c;    
            //End  UD-3300 and D-3989 24-Nov-2015 Added by Raviteja    
            
            //End UD-2775 - HotFix 17-Aug-2015 Added by Raviteja     
        }
        else if(deliveredBy == GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT)
        {
            //START UD-2586 HotFix 03-Sep-2015 Added by Raviteja - F02 should be overseas freelist and F01 is local freelist 
            /*
            if(isLocal || isInternal)
                subChannelCode = isFreeList? 'F02' : 'LDS';
            if(isOverseas)
                subChannelCode = isFreeList? 'F01' : 'ODS';
            */
            if(isLocal || isInternal)
                subChannelCode = isFreeList? 'F01' : 'LDS';
            if(isOverseas)
                subChannelCode = isFreeList? 'F02' : 'ODS';           
            //End UD-2586 HotFix 03-Sep-2015 Added by Raviteja  
                
            if(sub.Sponsor_1__c)
                subChannelCode = 'SDS';
            
            String mCode = 'MLAGN';
            /*if(sub.Vendor_1__r.Mailing_Agent_Code__c != null)
            {
                if(sub.Vendor_1__r.Mailing_Agent_Code__c.length() > 5)
                    mCode = sub.Vendor_1__r.Mailing_Agent_Code__c.substring(0,5);
                else
                    mCode = sub.Vendor_1__r.Mailing_Agent_Code__c;
            }*/
            miroDets.Vendor_Number__c = mCode;
        }
        
        if(isLocal){
            //START UD-2775 - HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of House Type and Postal Sector
            //miroDets.house_type__c = ConstantsSLB.getDefaultDeliveryChargeType(sub.Recipient_Contact__r.Address__r.Postal_Code__r.Address_Type__c);
            miroDets.house_type__c = houseType;
            //End UD-2775 - HotFix 17-Aug-2015 Added by Raviteja
        }
        if(isOverseas){
            miroDets.house_type__c = ' ';
        }
        if(isInternal){
            miroDets.house_type__c = 'I';
        }
        
        miroDets.office_house_mail_indicator__c = (((sub.Zuora__CustomerAccount__r.Attention_To_Care_Of_Indicator__c == null) 
                                || (sub.Zuora__CustomerAccount__r.Attention_To_Care_Of_Indicator__c == ''))? 'H' : 'O');
        //START UD-2775 - HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of House Type and Postal Sector                     
        /*
        if(sub.Recipient_Contact__r.Address__r.Postal_Code__r.Name != null)
            miroDets.postal_sector__c = sub.Recipient_Contact__r.Address__r.Postal_Code__r.Name.substring(0,2);
        */
        miroDets.postal_sector__c = postalSector;
        //End UD-2775 - HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of House Type and Postal Sector   
        
        miroDets.Publication_Code__c = pub.Publication_Code__c;
        miroDets.Publication_Issue_Date__c = popDate;
        miroDets.sub_channel_code__c = subChannelCode;
        //Nitin Khanna : UD-3349 : populating pre grouped miro data , grouping to be based on subscribers : Start
        miroDets.subscriber_count__c = 1;
        miroDets.subscription_copies__c = (sub.qty__c == null)? 0 : (sub.qty__c - tempStopQty); //Minus Temp Stop Quantity
        //START HotFix 16-Dec-2015 Added by Raviteja - applying subscription name for Testing purpose
        //miroDets.subscriberId__c = sub.Zuora__Account__r.Id;       
        miroDets.subscriberId__c = sub.Zuora__Account__C;       
        //End HotFix 16-Dec-2015 Added by Raviteja
        //Nitin Khanna : UD-3349 : populating pre grouped miro data , grouping to be based on subscribers : End
        return miroDets;
    }
    //END D-2269 18/02/15 Wenjun
    
    Class COAWrapper
    {
        Date effectiveDT {get;set;}
        Datetime createDT {get;set;}
        String vendorGroup {get;set;}
        String vendorCode {get;set;}
        //START UD-2775 - HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of House Type and Postal Sector
        String houseType;
        String postalSector;
        //End UD-2775 - HotFix 17-Aug-2015 Added by Raviteja 
        
        COAWrapper(Date startDate, Datetime createdDate, String strGroup, String strCode)
        {
            effectiveDT = startDate;
            createDT = createdDate;
            vendorGroup = strGroup;
            vendorCode = strCode;
        }
        //START UD-2775 - HotFix 17-Aug-2015 Added by Raviteja - applying New Logic of House Type and Postal Sector
        public String getHouseType() {
         return houseType;
        }        
        public void setHouseType(String houseType) {
         this.houseType = houseType;
        }
        
        public String getPostalSector() {
         return postalSector;
        }        
        public void setPostalSector(String postalSector) {
         this.postalSector = postalSector;
        }
        //End UD-2775 - HotFix 17-Aug-2015 Added by Raviteja 
    }
}