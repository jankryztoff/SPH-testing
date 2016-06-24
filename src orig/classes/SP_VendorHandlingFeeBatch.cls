/**
* Class Name: SP_VendorHandlingFeeBatch
* @author: Jayson Sarion
* Date: 
* Requirement/Project Name: CRSM Project
* @description Batch Apex Class to create record in Vendor Monthly Data and calculate the 
* Vendor Handling Fee, summation of Commissions, Insertions, and Pagination.
* History: Joban - Rewritten the logic for the batch for D - 2261
* History: UD-1917 Wenjun 14/07/15: Restructure the class to support POP Order Closure
* History: D-3576 Raviteja 18-Sep-2015: Restructure the class 
* History: UD-3780 Raviteja 15-Jan-2016 - Updated the logic of Vendors when rerun the job
* History: D-4421-UD-3393 and UD-3702 Raviteja 11-Feb-2016 - Restructure the class - Updated the logic of Recipient Contact
*/   
//START: D-43481-21-2016 Added by Kristine Balaoing - added logging mechanism
global class SP_VendorHandlingFeeBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    global final Date monthStart;
    global final Date monthEnd;
    //START-End D-3576 - Hotfix Raviteja - 16Sep2015 - Updating Posting Date as month end for given date
    global final Date monthEndDate; 
    global final Boolean increaseMth;    
    ID jobID; 
    Set<Id> subscriptionIDs = New Set<Id>(); //START I-0405 - PD-0473 - Raviteja - 06Jun2016 - Creating New constructor to calculate specific Subscription Ids
    Boolean isApexJobSuccessful = false;
    //END: D-43481-21-2016 Added by Kristine Balaoing
    //Contructor to be used by Control-M Auto Scheduled Run
    global SP_VendorHandlingFeeBatch()
    {
        Date todayDt = Date.today();
        this.monthStart = Date.newInstance(todayDt.year(),todayDt.month(), 1);
        this.monthEnd = monthStart.addMonths(1).addDays(-1);
        monthEndDate = monthEnd; //START-End D-3576 - Hotfix Raviteja - 16Sep2015 - Updating Posting Date as month end for given date
    }
    
    //Contructor for adhoc Run
    global SP_VendorHandlingFeeBatch(Date dtMthEnd)
    {
        this.monthEnd = dtMthEnd;
        this.monthStart = dtMthEnd.toStartOfMonth();
        //START D-3576 - Hotfix Raviteja - 16Sep2015 - Updating Posting Date as month end for given date        
        Integer numberOfDays = Date.daysInMonth(monthEnd.year(), monthEnd.month());
        monthEndDate  = Date.newInstance(monthEnd.year(), monthEnd.month(), numberOfDays);
        //End D-3576 - Hotfix Raviteja - 16Sep2015 - Updating Posting Date as month end for given date
    }

    //START I-0405 - PD-0473 - Raviteja - 06Jun2016 - Creating New constructor to calculate specific Subscription Ids 
    //Contructor for adhoc Run with Subscription Ids
    global SP_VendorHandlingFeeBatch(Date dtMthEnd, Set<Id> subIDs)
    {
        this.monthEnd = dtMthEnd;
        this.monthStart = dtMthEnd.toStartOfMonth();   
        SubscriptionIDs.addAll(subIDs);
        Integer numberOfDays = Date.daysInMonth(monthEnd.year(), monthEnd.month());
        monthEndDate  = Date.newInstance(monthEnd.year(), monthEnd.month(), numberOfDays);
     
    }    
    //END I-0405 - PD-0473 - Raviteja - 06Jun2016 - Creating New constructor to calculate specific Subscription Ids
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        //Verify Publication Issue Data that all Newspaper Print published in this month have been closed
        Boolean isAllClosed = true;
        String openPubCodes = '';
        this.jobID = BC.getJobId();
        
        //START UAT-Hotfix Wenjun 01/Sep/15 : Filter out non-vendor Deliveryed Newspaper
        for(Publication_Daily_Issue_Data__c pubIssueData : [SELECT Id, Publication_Code__c, Publication_Issue_Date__c FROM Publication_Daily_Issue_Data__c 
                                        WHERE Publication_Issue_Date__c >= :monthStart AND Publication_Issue_Date__c <= :monthEnd AND Order_Closed_Indicator__c = 'N' 
                                        AND Publication__r.Publication_Type__c ='N' AND Publication__r.Platform_Type__c = 'Print' 
                                        AND Publication__r.Direct_Sub_Delivery_Method__c != 'Mailing Agent'])
        //END UAT-Hotfix Wenjun 01/Sep/15
        {
            isAllClosed = false;
            openPubCodes += pubIssueData.Publication_Code__c +'-'+ pubIssueData.Publication_Issue_Date__c.format()+';';
        }

        //Abort the job if not all POP Orders are closed 
        if(!isAllClosed)
            abortJob(System.Label.ERR_POP_ORDER_NOT_CLOSE + ' : ' + openPubCodes);

        //Query all the eligible subscriptions 
        String query = 'SELECT Id, Name, qty__c, Product_Code__c, Vendor_1__c, Vendor_1__r.Vendor_Code__c, Vendor_1__r.Vendor_Group__c, '; 
        query       += ' Recipient_Contact__r.Address__r.RecordType.DeveloperName, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, ';
        query       += ' Main_Package_1__r.Package_Type__c, Main_Package_1__r.Package_Price__c, Main_Package_1__r.Frequency_Identifier__c, ';
        query       += ' Recipient_Contact__r.Address__r.Postal_Code__r.Address_Type__c, Recipient_Contact__r.Address__r.Postal_Code__r.Name, ';
        query       += ' Recipient_Contact__r.Address__c, '; //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Added Address__c field in SOQL  
        query       += ' Delivered_By_1__c, Sponsor_1__c, Other_PaymentMethod_1__c, Ph_d__c, Ph_e__c, Frequency_1__c ';  //START UAT Hotfix Wenjun 18 Aug - Using Subscription Frequency instead
        query       += ' FROM Zuora__Subscription__c WHERE Subscription_Type__c  = \'Publication\' and Delivered_By_1__c =\'Vendor\' '; 
         //START I-0405 - PD-0473 - Raviteja - 06Jun2016 - Executing job with specific Subscription Ids    
        //query       += ' AND id = \'a0C9000000T3ORb\' '; // 04Jan2015 Added by Raviteja for testing purpose
        if(!SubscriptionIDs.isEmpty()){
            query       += ' AND id in :SubscriptionIDs ';
        }
        //End I-0405 - PD-0473 - Raviteja - 06Jun2016 - Executing job with specific Subscription Ids 
        query       += ' AND Vendor_1__c != NULL AND Vendor_1__r.RecordType.DeveloperName = \'Vendor\' AND Zuora__SubscriptionStartDate__c <= :monthEnd ';
        query       += ' AND (Zuora__SubscriptionEndDate__c >= :monthStart OR Zuora__SubscriptionEndDate__c = NULL) ';
        
        //query       += ' limit 1 '; // START/End 04Feb2016 - Added by Raviteja - added limit 1 for testing purpose
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> lstSubs) {
        Set<Date> PublicHolidaysFortheMonth = new Set<Date>();
        Map<Id, Set<Id>> mapSubIdToPubIds = new Map<Id, Set<Id>>();
        Map<Id, List<Date>> mapPubIdToPOPDates = new Map<Id, List<Date>>();
        this.jobID = BC.getJobId();
        
        //START: D-4348 1-21-2016 Added by Kristine Balaoing - added logging mechanism
        Logger logger = new Logger(SP_VendorHandlingFeeBatch.class.getName(), 'SP016', BC.getJobID()); 
        
        try{

            //Get Public Holidays in this month
            Set<Date> setHolidays = getPublicHolidays();
            
            //Get Vendor Number Set
            Set<String> setVendorNumbers = getVendorList(lstSubs);
            
            //Get COA / COV and Other Vendor Number to be included
            Map<Id,List<COAWrapper>> mapSubToCOAList = getRelatedCOAs(lstSubs, setVendorNumbers);
            
            //Get Publication related data
            Map<Id, Publication__c> mapPubIdToObj = getPublicationData(lstSubs, mapSubIdToPubIds, mapPubIdToPOPDates, setHolidays);

            //Get Commission / Pagination / Insertion Rate and Number of Pages
            Map<String,HandlingFeeWrapper> mapPubDateToHandlingFee = getHandlingFeeRates(mapPubIdToPOPDates, setVendorNumbers, setHolidays);
            
            //Get Vendor Inserts
            Map<String, Integer> mapPubVendorToInserts = getVendorInserts(setVendorNumbers, mapPubIdToPOPDates.keySet());
            
            //Get Temp Stops 
            Map<Id, List<Subscription_Temp_Stop__c>> mapSubIdToTStops = getTempStopList(lstSubs);
            
            //Calculation
            calculateHanldingFee(lstSubs, mapSubIdToPubIds, mapSubIdToTStops, mapPubIdToPOPDates, mapSubToCOAList, 
                                mapPubIdToObj, mapPubVendorToInserts, mapPubDateToHandlingFee, setHolidays);
            
        }catch(Exception e){
            logger.logBatchFailure(e, lstSubs);
            logger.save();
            
            isApexJobSuccessful = false;
        }
        //END: D-4348 1-21-2016 Added by Kristine Balaoing
    }
    
    global void finish(Database.BatchableContext BC) {
        this.jobID = BC.getJobId();
        
        //START: D-4348 1-21-2016 Added by Kristine Balaoing - added logging mechanism
        Logger loggerFinish; 
            
        if(!Test.isRunningTest()){
            loggerFinish = new Logger(SP_VendorHandlingFeeBatch.class.getName(), 'SP016');
        }
        
        try{
        
            //Check Job Running Status
            AsyncApexJob apexJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                                    FROM AsyncApexJob WHERE Id = :this.jobID];

            if(apexJob.NumberOfErrors > 0)
            {   
                
                if(!isApexJobSuccessful){
                    BatchJobHelper.updateJobStatus(BC.getJobId(), false); //START-END KRITHIKA DHARMARAJAN 4/17/2015 D-2770
                }else{
                    BatchJobHelper.updateJobStatus(BC.getJobId(), true);
                }
            }
            else
            {
                //Start the VBS Processing Batch - Default Size 2
                //START D-3576 - Hotfix Raviteja - 16Sep2015 - Updating Posting Date as month end for given date.             
                //SP_VendorHandlingFeeVBSBatch batchJob = new SP_VendorHandlingFeeVBSBatch(this.jobID, monthStart, monthEnd);
                 // START/End 04Feb2016 - Added by Raviteja - comneted vbs batch for testing purpose
                 
                 SP_VendorHandlingFeeVBSBatch batchJob = new SP_VendorHandlingFeeVBSBatch(this.jobID, monthStart, monthEndDate);
                //End D-3576 - Hotfix Raviteja - 16Sep2015
                Database.executeBatch(batchJob, 2);
                
                
            }
        }catch(Exception e){
            loggerFinish.log(e);
            loggerFinish.save();
        }
        //END: D-4348 1-21-2016 Added by Kristine Balaoing
    }
    
    public void abortJob(String logMsg)
    {
        Logger logger = new Logger(SP_VendorHandlingFeeBatch.class.getName(),'SP016');
        logger.log(false,logMsg);
        BatchJobHelper.updateJobStatus(this.jobId,false);
        logger.save();
        System.abortJob(this.jobId);
    }
    
    //Get Public Holidays for the month
    public Set<Date> getPublicHolidays()
    {
        Set<Date> setDates = new Set<Date>();

        for (Public_Holiday__c tmp : [SELECT Holiday_Date__c FROM Public_Holiday__c 
                                      WHERE Holiday_Date__c >= :monthStart AND Holiday_Date__c <= :monthEnd]) 
        { 
            setDates.add(tmp.Holiday_Date__c);
        }
        
        return setDates;
    }
    
    public Set<String> getVendorList(List<Zuora__Subscription__c> lstSubs)
    {
        Set<String> setVendorNumbers = new Set<String>();
        
        for(Zuora__Subscription__c sub : lstSubs) 
            setVendorNumbers.add(sub.Vendor_1__r.Vendor_Code__c);
        
        return setVendorNumbers;
    }
    
    public Map<String, Integer> getVendorInserts (Set<String> setVendorNumbers, Set<ID> setPubIDs)
    {
        Map<String, Integer> mapPubVendorToInserts = new Map<String, Integer> ();
        
        /********************* Vendor Inserts *****************************/
        for(Vendor_Inserts__c venInst: [SELECT Id, Publication__c, Publication_Issue_Date__c, Vendor_Number__c, Number_of_Inserts__c
                                            FROM Vendor_Inserts__c WHERE Publication__c IN :setPubIDs AND Vendor_Number__c in:setVendorNumbers
                                            AND Publication_Issue_Date__c >= :monthStart AND Publication_Issue_Date__c <= :monthEnd])
        {
            String strKey = venInst.Publication__c + '|' + venInst.Publication_Issue_Date__c + '|' + venInst.Vendor_Number__c;
            mapPubVendorToInserts.put(strKey, Integer.valueOf(venInst.Number_of_Inserts__c));
        }
        
        return mapPubVendorToInserts;
    }
    
    public Map<Id, Publication__c> getPublicationData(List<Zuora__Subscription__c> lstSubs, Map<Id, Set<Id>> mapSubIdToPubIds, 
                        Map<Id, List<Date>> mapPubIdToPOPDates, Set<Date> setHolidays)
    {
        Set<String> setProductCodes = new Set<String>();
        Map<String, Set<Id>> mapProdCodeToPubIds = new Map<String, Set<Id>>();
        Map<Id, Set<Date>> mapPubIdToNonPubDates = new Map<Id, Set<Date>>();
        Map<Id, PubIssueHelper.PublicationPattern> mapPubIdToPubPattern = new Map<Id, PubIssueHelper.PublicationPattern>();
        Set<Id> setPublicationIds = new Set<Id>();
        Map<Id, Publication__c> mapPubIdToObj = new Map<Id, Publication__c>();
        
        for(Zuora__Subscription__c zSub : lstSubs) {
            if(zSub.Product_Code__c != null)
                setProductCodes.add(zSub.Product_Code__c);
        }
        
        //Retrieve Product Code to Publication Mapping
        //START UAT Hotifix Wenjun 19 Aug 15 : Bypass Digital Pubs
        for(Product_Publication__c prodPub : [SELECT ZProduct__r.ProductCode__c, Publication_Code__c, Publication_Code__r.Publication_Code__c 
                                        FROM Product_Publication__c WHERE ZProduct__r.ProductCode__c in :setProductCodes
                                        AND Publication_Code__r.Publication_Type__c ='N' AND Publication_Code__r.Platform_Type__c = 'Print'])
        //END UAT Hotifix Wenjun 19 Aug 15
        {
            String productCode = prodPub.ZProduct__r.ProductCode__c;
            Id pubId = prodPub.Publication_Code__c;
            setPublicationIds.add(pubId);
            if(!mapProdCodeToPubIds.containsKey(productCode))
                mapProdCodeToPubIds.put(productCode, new Set<Id> {pubId});
            else
                mapProdCodeToPubIds.get(productCode).add(pubId);
        }
        System.debug('=====> mapProdCodeToPubIds: ' + mapProdCodeToPubIds);
        
        mapPubIdToObj = new Map<Id, Publication__c>([SELECT Id, Name, Publication_Code__c, Published_Days__c, Publication_Next_Start_Date__c, 
                                  Frequency_Code__c, Public_Holiday_Weekend_Pub_Indicator__c, Public_Holiday_Weekday_Pub_Indicator__c 
                                  FROM Publication__c WHERE ID in :setPublicationIds AND Publication_Next_Start_Date__c != null]);
        
        //Generate Sub ID to Publication Codes mapping
        for(Zuora__Subscription__c zSub : lstSubs) {
            if(mapProdCodeToPubIds.containsKey(zSub.Product_Code__c))
                mapSubIdToPubIds.put(zSub.Id, mapProdCodeToPubIds.get(zSub.Product_Code__c));
        }
        System.debug('=====> mapSubIdToPubIds: ' + mapSubIdToPubIds);
        
        //Only retrieve Non Pub Dates in this particular month
        for(Non_Publication_Day__c pubDay : [SELECT Id, Publication__c, Publication_Code__c, Non_Publication_Date__c 
              FROM Non_Publication_Day__c WHERE Publication__c IN : setPublicationIds 
              AND Non_Publication_Date__c >= :monthStart AND Non_Publication_Date__c <= :monthEnd])
        {
            if(!mapPubIdToNonPubDates.containsKey(pubDay.Publication__c))
                mapPubIdToNonPubDates.put(pubDay.Publication__c, new Set<Date> {pubDay.Non_Publication_Date__c});
            else
                mapPubIdToNonPubDates.get(pubDay.Publication__c).add(pubDay.Non_Publication_Date__c);
        }
        System.debug('=====> mapPubIdToNonPubDates: ' + mapPubIdToNonPubDates);
        
        //Generate Publication Pattern for Daily Publications
        for(Publication__c pubObj : mapPubIdToObj.values())
        {
            if(pubObj.Frequency_Code__c == 'D') //Daily Publication
                mapPubIdToPubPattern.put(pubObj.Id, PubIssueHelper.generatePubPattern(pubObj));
        }
        
        System.debug('=====> mapPubIdToPubPattern: ' + mapPubIdToPubPattern);
        
        /******************** Get Publish Dates for each Publication ***************************/
        for(Publication__c pubObj : mapPubIdToObj.values())
        {
            Date nextIssueDate = pubObj.Publication_Next_Start_Date__c;
            
            List<Date> lstDates = new List<Date>();
            
            //Date Range: start_date = Month Start, end_date = Month End
            for(Date tmpDate = monthStart; tmpDate <= monthEnd; tmpDate = tmpDate.addDays(1))
            {
                if(pubObj.Frequency_Code__c == 'D') //Daily
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
                else if(pubObj.Frequency_Code__c == 'W') //Weekly
                {
                    if(Math.mod(tmpDate.daysBetween(nextIssueDate),7) == 0)
                    {
                        if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'F') //Fortnightly
                {
                    if(Math.mod(tmpDate.daysBetween(nextIssueDate),14) == 0)
                    {
                        if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'M') //Monthly
                {
                    if(tmpDate.day() == nextIssueDate.day())
                    {
                        if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'B') //Bi-Monthly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 2) == 0)
                    {
                        if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'Q') //Quarterly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 3) == 0)
                    {
                        if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'H') //Half-Yearly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 6) == 0)
                    {
                        if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'Y') //Yearly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 12) == 0)
                    {
                        if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }               
            }
            
            if(!lstDates.isEmpty())
                mapPubIdToPOPDates.put(pubObj.Id, lstDates);
        }
        
        return mapPubIdToObj;
    }
    
    public Map<String,HandlingFeeWrapper> getHandlingFeeRates(Map<Id, List<Date>> mapPubIdToPOPDates, Set<String> setVendorNumbers, Set<Date> setHolidays)
    {
        Map<String, HandlingFeeWrapper> mapPubDateToRates = new Map<String, HandlingFeeWrapper>();
        Map<ID, List<Publication_Commission_Rates__c>> mapPubToComRates = new Map<ID, List<Publication_Commission_Rates__c>>();
        Map<String, Integer> mapPubDateToPages = new Map<String, Integer>();
        Map<ID, List<Pagination_Rate__c>> mapPubToPageRates = new Map<ID, List<Pagination_Rate__c>>();
        
        /********************* Commission Rates and Insertion Rate *******************************/
        for(Publication_Commission_Rates__c pubComRate : [SELECT Commission_Rate_Mon__c, Commission_Rate_Tue__c, Commission_Rate_Wed__c, 
                    Commission_Rate_Thur__c, Commission_Rate_Fri__c, Commission_Rate_Sat__c, Commission_Rate_Sun__c,
                    Commission_Rate_PHE__c, Commission_Rate_PHD__c, Insertion_Rate__c, Publication__c, Effective_Start_Date__c,
                    Commission_Rate_Special_Mon__c,Commission_Rate_Special_Tue__c,Commission_Rate_Special_Wed__c,
                    Commission_Rate_Special_Thur__c,Commission_Rate_Special_Fri__c,Commission_Rate_Special_Sat__c,
                    Commission_Rate_Special_Sun__c,Commission_Rate_Special_PHD__c,Commission_Rate_Special_PHE__c                                            
                    FROM Publication_Commission_Rates__c WHERE Effective_Start_Date__c <= :monthEnd 
                    AND Publication__c IN :mapPubIdToPOPDates.keySet()])
        {
            if(!mapPubToComRates.containsKey(pubComRate.Publication__c))
                mapPubToComRates.put(pubComRate.Publication__c, new List<Publication_Commission_Rates__c> {pubComRate});
            else
                mapPubToComRates.get(pubComRate.Publication__c).add(pubComRate);
        }
        
        /********************* Pagination: Number of Pages *******************************/
        for(Publication_Daily_Issue_Data__c dailyIssueData : [SELECT Id, Publication__c, Publication_Issue_Date__c, Pagination__c 
                                            FROM Publication_Daily_Issue_Data__c WHERE Publication__c IN :mapPubIdToPOPDates.keySet() 
                                            AND Publication_Issue_Date__c >= :monthStart AND Publication_Issue_Date__c <= :monthEnd])
        {
            String strKey = dailyIssueData.Publication__c + '|' + dailyIssueData.Publication_Issue_Date__c;
            mapPubDateToPages.put(strKey, Integer.valueOf(dailyIssueData.Pagination__c));
            
        }
        
        /********************* Pagination: Pagination Rate *******************************/
        for (Pagination_Rate__c pageRate : [SELECT Id,Pagination_Range_LL__c,Pagination_Range_UL__c,Paginaton_Rate__c,Publication__c,Effective_Start_Date__c
                                    FROM Pagination_Rate__c WHERE Effective_Start_Date__c <= :monthEnd 
                                    AND Publication__c IN :mapPubIdToPOPDates.keySet()])
        {
            if(!mapPubToPageRates.containsKey(pageRate.Publication__c))
                mapPubToPageRates.put(pageRate.Publication__c, new List<Pagination_Rate__c> {pageRate});
            else
                mapPubToPageRates.get(pageRate.Publication__c).add(pageRate);
        }
                                    
        /*************** Generating Rates Map for each Publication by Publish Date *************/
        for(ID pubID: mapPubIdToPOPDates.keySet()) //Iterate Publications
        {
            List<Date> lstPublishDates = mapPubIdToPOPDates.get(pubID);
            List<Publication_Commission_Rates__c> lstCommRates;
            List<Pagination_Rate__c> lstPageRates;
            
            if(mapPubToComRates.containsKey(pubID))
                lstCommRates = mapPubToComRates.get(pubID);
            System.debug('=======> Pub ID: ' + pubID +' | lstCommRates: ' + lstCommRates);
           
            if(mapPubToPageRates.containsKey(pubID))
                lstPageRates = mapPubToPageRates.get(pubID);
             System.debug('=======> Pub ID: ' + pubID +' | lstPageRates: ' + lstPageRates);
             
            for(Date theDate : lstPublishDates) //Iterate Publish Dates
            {
                HandlingFeeWrapper feeWrapper = new HandlingFeeWrapper();
                Publication_Commission_Rates__c commRateToUse;
                Pagination_Rate__c pageRateToUse;
                String pubDateKey = pubID + '|' + theDate;
                
                if(lstCommRates == NULL || lstCommRates.isEmpty()) //Default to 0 if no set-up
                {
                    feeWrapper.commissionRate = 0.00;
                    feeWrapper.specialComRate = 0.00;
                    feeWrapper.insertRate = 0.00;
                } else //Having Commission Rates set up
                {
                    //Check Commission Rate Effective Date
                    for(Publication_Commission_Rates__c rate : lstCommRates)
                    {
                        if(rate.Effective_Start_Date__c <= theDate)
                        {
                            if(commRateToUse == NULL) 
                                commRateToUse = rate;
                            else if(rate.Effective_Start_Date__c > commRateToUse.Effective_Start_Date__c)
                                commRateToUse = rate;
                        }
                    }
                    
                    //Validate Commission Rate / Insertion Rate
                    if(!isCommRateValid(commRateToUse))
                    {
                        String errMsg = System.Label.ERR_INVALID_COMM_RATE +' : ' + pubDateKey;
                        throw new CustomException(errMsg);
                    }
                    else
                    {
                        //Check Date of the week and Public Holiday
                        HandlingFeeWrapper rateOfTheDate = getCommRateOfTheDate(theDate, commRateToUse, setHolidays);
                        feeWrapper.commissionRate = rateOfTheDate.commissionRate;
                        feeWrapper.specialComRate = rateOfTheDate.specialComRate;
                        feeWrapper.insertRate = commRateToUse.Insertion_Rate__c;
                    }
                }
                
                //Get Number of Pages
                if(mapPubDateToPages.containsKey(pubDateKey))
                    feeWrapper.numberOfPage = mapPubDateToPages.get(pubDateKey);
                else
                    feeWrapper.numberOfPage = 0; //Default to 0 if no set-up

                //Check Pagination Rate Effective Date
                if(lstPageRates == NULL || lstPageRates.isEmpty()) //Default to 0 if no set-up
                {
                    feeWrapper.paginationRate = 0.00;
                } 
                else //Having Pagination Rates set-up
                {
                    System.debug('lstPageRates size: '+lstPageRates.size());
                    for(Pagination_Rate__c rate : lstPageRates)
                    {
                        /*
                        System.debug('rate '+rate );
                        System.debug('feeWrapper.numberOfPage '+feeWrapper.numberOfPage );
                        System.debug('theDate  '+theDate);
                        System.debug('rate.Pagination_Range_LL__c  '+rate.Pagination_Range_LL__c);
                        System.debug('rate.Pagination_Range_UL__c   '+rate.Pagination_Range_UL__c );
                        System.debug('rate.Effective_Start_Date__c    '+rate.Effective_Start_Date__c  );
                        System.debug('pageRateToUse  '+pageRateToUse);
                        */
                        if(rate.Effective_Start_Date__c <= theDate && rate.Pagination_Range_UL__c >= feeWrapper.numberOfPage
                            && rate.Pagination_Range_LL__c <= feeWrapper.numberOfPage)
                        {
                            system.debug(' in if 1 : ');
                            if(pageRateToUse == NULL) 
                                pageRateToUse = rate;
                            else if(rate.Effective_Start_Date__c > pageRateToUse.Effective_Start_Date__c)
                                pageRateToUse = rate;
                        }
                    }
                    system.debug(' pageRateToUse : '+pageRateToUse);
                    //system.debug(' pageRateToUse.Paginaton_Rate__c : '+pageRateToUse.Paginaton_Rate__c);
                    //Validate Pagination Rate
                    if(pageRateToUse == NULL || pageRateToUse.Paginaton_Rate__c == NULL)
                    {
                        String errMsg = System.Label.ERR_INVALID_PAGE_RATE +' : ' + pubDateKey;
                        throw new CustomException(errMsg);
                    }
                    else
                    {
                        feeWrapper.paginationRate = pageRateToUse.Paginaton_Rate__c;
                    }
                }
                
                mapPubDateToRates.put(pubDateKey,feeWrapper);
            } //End of Publish Dates For Loop
        } //End of Publication For Loop
        
        return mapPubDateToRates;
    }
    
    /*************************** Retrieve Temp Stops ************************/
    public Map<Id, List<Subscription_Temp_Stop__c>> getTempStopList(List<Zuora__Subscription__c> lstSubs)
    {   
        Map<Id, List<Subscription_Temp_Stop__c>> mapSubIdToTStops = new Map<Id, List<Subscription_Temp_Stop__c>>(); 
        for( Subscription_Temp_Stop__c tempStopObj : [SELECT Subscription__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Qty__c,
                                      Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Qty__c FROM Subscription_Temp_Stop__c 
                                      WHERE Subscription__c IN :lstSubs AND Temp_Stop__r.Cancelled__c = false 
                                      AND Temp_Stop__r.Temp_Stop_Date__c <= : monthEnd AND Temp_Stop__r.Restart_Date__c > :monthStart])
        {
            if(!mapSubIdToTStops.containsKey(tempStopObj.Subscription__c))
                mapSubIdToTStops.put(tempStopObj.Subscription__c, new List<Subscription_Temp_Stop__c> {tempStopObj});
            else
                mapSubIdToTStops.get(tempStopObj.Subscription__c).add(tempStopObj);
        }
        return mapSubIdToTStops;
    }
    
    /**************** Check relevant Vendor Assignments COA & COV *******************************/
    public Map<Id,List<COAWrapper>> getRelatedCOAs(List<Zuora__Subscription__c> lstSubs, Set<String> setVendorNumbers)
    {
        Map<Id,List<COAWrapper>> mapSubToCOAList = new Map<Id,List<COAWrapper>>();

        //Fetch all the COA Cases - the latest record will take precedence 
        Set<Id> setCaseIDs = new Set<Id>();
        Map<Id, Address_Assignment__c> mapCaseToAddrAssign = new Map<Id, Address_Assignment__c>();
        //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Added Address__c and Case__r.New_Address__c field in SOQL  
        //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Added Address__c and Case__r.New_Address__c field in SOQL  
        //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Added Old_Recipient_Contact__c, Subscription__r.Recipient_Contact__c field in SOQL  
        List<Case_Subscription__c> lstCaseSubs = [SELECT ID, Name, Case__c, Subscription__c, Case__r.Effective_Date__c, Vendor_Code__c, Address__c, Case__r.New_Address__c, Old_Recipient_Contact__c, Subscription__r.Recipient_Contact__c   
                       FROM Case_Subscription__c WHERE Subscription__c in :lstSubs AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED 
                       //START UD-3780 15-Jan-2016 Added by Raviteja  - Removing end date to get the recent change values and sorting by Lastmodifieddate in SOQL
                       //AND Case__r.Effective_Date__c >= :monthStart AND Case__r.Effective_Date__c <= :monthEnd
                       //AND Case__r.Effective_Date__c >= :monthStart AND Case__r.Effective_Date__c <= :dtToday
                       AND Case__r.Effective_Date__c >= :monthStart 
                       AND (Case__r.Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD 
                            //OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC)];
                            OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC) Order by LastmodifiedDate ASC];
                      //End UD-3780 15-Jan-2016 Added by Raviteja              
        for(Case_Subscription__c caseSub : lstCaseSubs)
            setCaseIDs.add(caseSub.Case__c);
        
        //Fetch Address Assignment to get Vendor
        for(Address_Assignment__c addrAssign : [SELECT ID, Case__c, Vendor__r.Vendor_Code__c, Vendor__r.Vendor_Group__c   
                    From Address_Assignment__c WHERE Case__c in :setCaseIDs AND Vendor__c != NULL])
         {
              mapCaseToAddrAssign.put(addrAssign.Case__c, addrAssign);  
         }
        
        for(Case_Subscription__c caseSub : lstCaseSubs)
        {
            if(mapCaseToAddrAssign.containsKey(caseSub.Case__c))
            {
                Address_Assignment__c addrAssign = mapCaseToAddrAssign.get(caseSub.Case__c);
                COAWrapper newCOA = new COAWrapper();
                newCOA.effectiveDT = caseSub.Case__r.Effective_Date__c;
                newCOA.vendorGroup = addrAssign.Vendor__r.Vendor_Group__c;
                newCOA.vendorCode = addrAssign.Vendor__r.Vendor_Code__c;
                newCOA.oldVendorGroup = 'V';
                newCOA.oldvendorCode = caseSub.Vendor_Code__c;
                newCOA.oldaddressId =  caseSub.Address__c;  //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - assigning Address into COA
                newCOA.newaddressId =  caseSub.Case__r.New_Address__c;  //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - assigning Address into COA
                newCOA.oldcontactId =  caseSub.Old_Recipient_Contact__c;  //START/End UD-3702 - Hotfix Raviteja - UD-3702 - Adding Contactnumber in COAwrapper
                newCOA.newcontactId  =  caseSub.Subscription__r.Recipient_Contact__c;  //START/End UD-3702 - Hotfix Raviteja - UD-3702 - Adding Contactnumber in COAwrapper
                setVendorNumbers.add(caseSub.Vendor_Code__c);
                setVendorNumbers.add(addrAssign.Vendor__r.Vendor_Code__c);
                
                if(!mapSubToCOAList.containsKey(caseSub.Subscription__c))
                    mapSubToCOAList.put(caseSub.Subscription__c, new List<COAWrapper> {newCOA});
                else
                    mapSubToCOAList.get(caseSub.Subscription__c).add(newCOA);
            }
        }
        //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Added Address__c field in SOQL
        //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Added Old_Recipient_Contact__c, Subscription__r.Recipient_Contact__c field in SOQL  
        //Fetch COV Cases
        for(Case_Subscription__c caseSub : [SELECT ID, Name, Case__c, Subscription__c, Case__r.Effective_Date__c, Vendor_Code__c,
                                            Case__r.Vendor__r.Vendor_Code__c, Case__r.Vendor__r.Vendor_Group__c, Address__c ,Old_Recipient_Contact__c, Subscription__r.Recipient_Contact__c  
                       FROM Case_Subscription__c WHERE Subscription__c in :lstSubs AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED 
                       //START UD-3780 15-Jan-2016 Added by Raviteja  - Removing end date to get the recent change values and sorting by Lastmodifieddate in SOQL
                       //AND Case__r.Effective_Date__c >= :monthStart AND Case__r.Effective_Date__c <= :monthEnd
                       //AND Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR])                     
                       AND Case__r.Effective_Date__c >= :monthStart 
                       AND Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR Order by LastmodifiedDate ASC])
                      //End UD-3780 15-Jan-2016 Added by Raviteja  
                       
                       
        {
            COAWrapper newCOA = new COAWrapper();
            newCOA.effectiveDT = caseSub.Case__r.Effective_Date__c;
            newCOA.vendorGroup = caseSub.Case__r.Vendor__r.Vendor_Group__c;
            newCOA.vendorCode = caseSub.Case__r.Vendor__r.Vendor_Code__c;
            newCOA.oldVendorGroup = 'V';
            newCOA.oldvendorCode = caseSub.Vendor_Code__c;
            newCOA.oldaddressId =  caseSub.Address__c;  //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - assigning Address into COV
            newCOA.newaddressId =  caseSub.Address__c;  //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - assigning Address into COV
            newCOA.oldcontactId =  caseSub.Old_Recipient_Contact__c;  //START/End UD-3702 - Hotfix Raviteja - UD-3702 - Adding Contactnumber in COAwrapper
            newCOA.newcontactId  =  caseSub.Subscription__r.Recipient_Contact__c;  //START/End UD-3702 - Hotfix Raviteja - UD-3702 - Adding Contactnumber in COAwrapper 
            
            setVendorNumbers.add(caseSub.Vendor_Code__c);
            setVendorNumbers.add(caseSub.Case__r.Vendor__r.Vendor_Code__c);
                
            if(!mapSubToCOAList.containsKey(caseSub.Subscription__c))
                mapSubToCOAList.put(caseSub.Subscription__c, new List<COAWrapper> {newCOA});
            else
                mapSubToCOAList.get(caseSub.Subscription__c).add(newCOA);
        }
        
        return mapSubToCOAList;
    }
    
    //This class performs the POP logic to calculate the eligible copies for each subscription for each day in the month
    public void calculateHanldingFee(List<Zuora__Subscription__c> lstSubs, Map<Id, Set<Id>> mapSubIdToPubIds,
            Map<Id, List<Subscription_Temp_Stop__c>> mapSubIdToTStops, Map<Id, List<Date>> mapPubIdToPOPDates,
            Map<Id,List<COAWrapper>> mapSubToCOAList, Map<Id, Publication__c> mapPubIdToObj, 
            Map<String, Integer> mapPubVendorToInserts, Map<String,HandlingFeeWrapper> mapPubDateToHandlingFee, Set<Date> setHolidays)
    {
        /************************** Variable Definitions ***********************************************/
        Map<String, BT_CO_VSS_CreditDebit__c> mapVSS = new Map<String, BT_CO_VSS_CreditDebit__c>();
        
        /*************************** Processing for each Subscription ************************/
        for(Zuora__Subscription__c sub : lstSubs) 
        {
            Set<Id> setPubIds = mapSubIdToPubIds.get(sub.Id);
            
            if(setPubIds != null && !setPubIds.isEmpty())
            {
                Boolean hasTempStop = mapSubIdToTStops.containsKey(sub.Id);

                //Retrieve the eligible dates for each pub
                for(Id pubId : setPubIds)
                {
                    List<Date> lstPOPDates = mapPubIdToPOPDates.get(pubId);
                    
                    if(lstPOPDates != null && !lstPOPDates.isEmpty())
                    {
                        //Get User Subscription Frequency 
                        PubIssueHelper.PublicationPattern userPattern = PubIssueHelper.generateSubPattern(mapPubIdToObj.get(pubId), sub);
                        
                        for(Date popDate : lstPOPDates)
                        {
                            //Verify Subscription Start Date / End Date
                            if(popDate < sub.Zuora__SubscriptionStartDate__c || (sub.Zuora__SubscriptionEndDate__c != null && popDate > sub.Zuora__SubscriptionEndDate__c))
                                continue;
                            
                            //Verify Holiday
                            if(setHolidays.contains(popDate) && !PubIssueHelper.isHolidayPublishDate(userPattern, popDate))
                                continue;
                            
                            System.debug(' popDate : '+popDate);
                            System.debug(' userPattern : '+userPattern);
                            
                            //Check User Subscription Frequency 
                            if(!PubIssueHelper.isPublishDate(userPattern, popDate))
                                continue;
                            
                            System.debug(' after PubIssueHelper.isPublishDate ');
                            Integer tempStopQty = 0;
                            if(hasTempStop) //Having Temp Stops
                                tempStopQty = getTempStopQty(popDate, mapSubIdToTStops.get(sub.Id));
                            
                            //Get the Vendor Info
                            VendorInfoWrapper vendorInfo = getVendorInfo(sub, popDate, mapSubToCOAList.get(sub.Id));
                            
                            if(vendorInfo == null || vendorInfo.vendorGroup == null || vendorInfo.vendorCode == null)
                            {
                                String errMsg = System.Label.ERR_NO_VENDOR_DTL +' : ' + sub.Id + '|'+ popDate.format();
                                throw new CustomException(errMsg);
                            }
                           
                            //Calculate Vendor Handling Fee
                            String pubDateKey = pubID + '|' + popDate;
                            String insertKey = pubID + '|' + popDate + '|' + vendorInfo.vendorCode;
                            
                            if(!mapPubVendorToInserts.containsKey(insertKey))
                                mapPubVendorToInserts.put(insertKey, 0); //Default to 0 if no set-up
                            
                            //START D-3621 - Hotfix Raviteja - 29Sep2015 - Passing VendorInfoWrapper instead of vendorGroup and vendorNumber 
                            //calculateFee(mapVSS, sub, mapPubDateToHandlingFee.get(pubDateKey), mapPubIdToObj.get(pubId),popDate,mapPubVendorToInserts.get(insertKey), 
                                    //tempStopQty, vendorInfo.vendorGroup, vendorInfo.vendorCode);
                            calculateFee(mapVSS, sub, mapPubDateToHandlingFee.get(pubDateKey), mapPubIdToObj.get(pubId),popDate, 
                                            mapPubVendorToInserts.get(insertKey), tempStopQty, vendorInfo);
                            //End D-3621 - Hotfix Raviteja - 29Sep2015
                        } //End of for Loop - POP Dates
                    }
                } // END of For Loop - Pub ID Set
            }
        } // END of For Loop : List of Subs
        
        System.debug('mapVSS.values : '+mapVSS.values());
        //Insert VSS Record
        if(!mapVSS.isEmpty())
        {  
            //Set Rounding to Half-Up
            for(BT_CO_VSS_CreditDebit__c vssRec : mapVSS.values())
            {
                vssRec.Commission__c = vssRec.Commission__c.setScale(2,System.RoundingMode.HALF_UP);
                vssRec.Pagination__c = vssRec.Pagination__c.setScale(2,System.RoundingMode.HALF_UP);
                vssRec.Insertion__c = vssRec.Insertion__c.setScale(2,System.RoundingMode.HALF_UP);
                
                vssRec.Total_Amount__c = vssRec.Commission__c + vssRec.Pagination__c + vssRec.Insertion__c;
            }
            
            INSERT mapVSS.values();
        }
    }
    
    public VendorInfoWrapper getVendorInfo(Zuora__Subscription__c sub, Date inputDate, List<COAWrapper> listCOA)
    {
        System.debug('Ravi sub : '+sub);
        System.debug('Ravi inputDate: '+inputDate);
        System.debug('Ravi listCOA: '+listCOA);
        COAWrapper coaActive = null;
        COAWrapper coaFuture = null;
        String vendorGroup;
        String vendorNumber;
        ID addressId;  //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Creating addressId for Case Subscription Address
        ID recipientContactId;  //START/End UD-3702 - Hotfix Raviteja - 11Feb2016 - Creating recipientContactId for Case Subscription Contactnumber
        
        System.debug('====>Sub Vendor:' + sub.Vendor_1__r.Vendor_Code__c);
        System.debug('====>Date:' + inputDate);
        System.debug('====>COA List:' + listCOA);
        
        //Get Vendor Info
         if(listCOA != null && !listCOA.isEmpty())
         {
             for(COAWrapper coa : listCOA)
             {
                 if(coa.effectiveDT <= inputDate)
                 {
                     if(coaActive == null) coaActive = coa;
                     else if (coa.effectiveDT > coaActive.effectiveDT)
                         coaActive = coa;
                 }
                 else{
                     if(coaFuture == null) coaFuture = coa;
                     else if (coa.effectiveDT < coaFuture.effectiveDT)
                         coaFuture = coa;
                 }
             }
         }
         
         System.debug('Ravi coaActive : '+coaActive );
         System.debug('Ravi coaFuture : '+coaFuture );
         
         if(listCOA == null || listCOA.isEmpty() || (coaActive == null && coaFuture == null)) //No COA/COV Event
         {
             vendorGroup = (sub.Vendor_1__r.Vendor_Group__c == null) ? 'V' : sub.Vendor_1__r.Vendor_Group__c;
             vendorNumber = sub.Vendor_1__r.Vendor_Code__c;
            //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - if no COA, assigning addressId from Subscription__r.Recipient_Contact__r.Address__c
             addressId = sub.Recipient_Contact__r.Address__c;  
            //START/End UD-3702 - Hotfix Raviteja - 11Feb2016 - if no COA, assigning recipientContactId from Subscription__r.Recipient_Contact__c 
             recipientContactId = sub.Recipient_Contact__c;
         }
         else
         {
             System.debug('====>coaActive: ' + coaActive);
             System.debug('====>coaFuture: ' + coaFuture);
             if(coaActive != NULL)
             {
                vendorGroup = coaActive.vendorGroup;
                vendorNumber = coaActive.vendorCode;
                addressId = coaActive.newaddressId;  //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - assigning addressId 
                recipientContactId = coaActive.newcontactId;  //START/End UD-3702 - Hotfix Raviteja - 11Feb2016 - assigning ContactId 
             }
             else
             {
                vendorGroup = coaFuture.oldVendorGroup;
                vendorNumber = coaFuture.oldvendorCode;
                addressId = coaFuture.oldaddressId;  //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - assigning addressId
                recipientContactId = coaFuture.oldcontactId;  //START/End UD-3702 - Hotfix Raviteja - 11Feb2016 - assigning ContactId 
             }
         }
         
         VendorInfoWrapper vendorInfo = new VendorInfoWrapper();
         vendorInfo.vendorGroup = vendorGroup;
         vendorInfo.vendorCode = vendorNumber;
         vendorInfo.addressId = addressId;  //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - assigning addressId  
         vendorInfo.recipientContactId = recipientContactId;  //START/End UD-3702 - Hotfix Raviteja - 11Feb2016 - assigning ContactId  
         return vendorInfo;
    }
    
    //START D-3621 - Hotfix Raviteja - 29Sep2015 - Passing VendorInfoWrapper instead of vendorGroup and vendorNumber
   // public void calculateFee(Map<String, BT_CO_VSS_CreditDebit__c> mapVSS, Zuora__Subscription__c sub, HandlingFeeWrapper handlingFee, Publication__c pub, 
           //Date inputDate, Integer numberOfInserts, Integer tempStopQty, String vendorGroup, String vendorNumber)
      public void calculateFee(Map<String, BT_CO_VSS_CreditDebit__c> mapVSS, Zuora__Subscription__c sub, HandlingFeeWrapper handlingFee, 
        Publication__c pub, Date inputDate, Integer numberOfInserts, Integer tempStopQty, VendorInfoWrapper vendorwrap)
    //End D-3621 - Hotfix Raviteja - 29Sep2015      
    {
        Decimal commssionRate = 0.00; 
        Decimal paginationRate = 0.00; 
        Decimal insertionRate = 0.00; 
        //START D-3621 - Hotfix Raviteja - 29Sep2015 -Passing VendorInfoWrapper instead of vendorGroup and vendorNumber
        //String key = vendorGroup + '|' + vendorNumber + '|' + pub.ID + '|' + sub.ID;
        //START UD-3837 - Raviteja - 28Mar2016 - updating key with Address Id to split at the detail level
        //String key = vendorwrap.vendorGroup + '|' + vendorwrap.vendorCode + '|' + pub.ID + '|' + sub.ID;
        String key = vendorwrap.vendorGroup + '|' + vendorwrap.vendorCode + '|' + pub.ID + '|' + sub.ID + '|' +  vendorwrap.addressId ;
        //End UD-3837 - Raviteja - 28Mar2016
        //End D-3621 - Hotfix Raviteja - 29Sep2015
        
        Integer qty = (sub.qty__c == null) ? 0 : Integer.valueOf(sub.qty__c);
        qty = (sub.qty__c > 0) ? qty - tempStopQty : 0; //Minus Temp Stop Quantity
        
        //Check if it is sponsored
        if(sub.Sponsor_1__c)
        {
            commssionRate = handlingFee.specialComRate * qty;
        }
        else
        {
            //Calculate Commission Rate
            commssionRate = handlingFee.commissionRate * qty;
            //Calculate Pagination Rate
            paginationRate = handlingFee.paginationRate * qty;
            //Calculate Insertion Rate
            insertionRate = handlingFee.insertRate * numberOfInserts * qty;
        }
        
        if(mapVSS.containsKey(key)) //Update record
        {
            BT_CO_VSS_CreditDebit__c tempRec = mapVSS.get(key);
            tempRec.Commission__c += commssionRate; 
            tempRec.Pagination__c += paginationRate;
            tempRec.Insertion__c += insertionRate; 
            //START / End UD-2640 05-Nov-2015 Added by Raviteja  - Updated the logic for copies - No. of issues delivered.
            tempRec.Copies__c += qty; 
        }
        else{ //Create new VSS record
            BT_CO_VSS_CreditDebit__c tempRec = new BT_CO_VSS_CreditDebit__c();
            //START D-3621 - Hotfix Raviteja - 29Sep2015 - Getting details from VendorInfoWrapper 
            //tempRec.Vendor_Group__c = vendorGroup;
            //tempRec.Vendor_Number__c = vendorNumber;
            tempRec.Vendor_Group__c = vendorwrap.vendorGroup;
            tempRec.Vendor_Number__c = vendorwrap.vendorCode;
            tempRec.Address__c = vendorwrap.addressId;
            //End D-3621 - Hotfix Raviteja - 29Sep2015
            //START/End UD-3702 - Hotfix Raviteja - 11Feb2016 - Adding Recipient_Contact__c in vss record
            tempRec.Recipient_Contact__c = vendorwrap.recipientContactId;
            tempRec.Subscription__c = sub.ID;
            tempRec.Publication_Code__c = pub.Publication_Code__c;
            //START D-3576 - Hotfix Raviteja - 16Sep2015 - Updating Posting Date as month end for given date. 
            //tempRec.Posting_Date__c = monthEnd;
            tempRec.Posting_Date__c = monthEndDate;
            //End D-3576 - Hotfix Raviteja - 16Sep2015 
            
            tempRec.Credit_Debit__c = GlobalVariableClass.CREDIT_IND; 
            tempRec.Copies__c = qty;
            tempRec.Commission__c = commssionRate; 
            tempRec.Pagination__c = paginationRate;
            tempRec.Insertion__c = insertionRate; 
            tempRec.Job_Id__c = 'SP016'; //For Credit Note Generation
            mapVSS.put(key, tempRec);
        }
    }
    
    public Boolean isPOPDate(Publication__c publication, Date inputDate, Map<Id, Set<Date>> mapPubIdToNonPubDates, 
                    Set<Date> setHolidays, Map<Id, PubIssueHelper.PublicationPattern> mapPubIdToPubPattern)
    {
        //Verify Non-Publication Date
        if(mapPubIdToNonPubDates.containsKey(publication.Id) && mapPubIdToNonPubDates.get(publication.Id).contains(inputDate))
            return false;
            
        //Verify Holiday
        if(setHolidays.contains(inputDate) && !PubIssueHelper.isHolidayPublishDate(publication, inputDate))
            return false;
        
        //Verify Publish Days for Publications : cater for various frequency
        if(publication.Frequency_Code__c == 'D') //Daily Publication
        {
            PubIssueHelper.PublicationPattern pattern = mapPubIdToPubPattern.get(publication.Id);
            return PubIssueHelper.isPublishDate(pattern, inputDate);
        }
        else 
            return true; //Frequency already catered in the for loop for Non-daily Publications
       
        return true;
    }
    
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
    
    public Boolean isCommRateValid(Publication_Commission_Rates__c commRateToUse)
    {
        if(commRateToUse == NULL || commRateToUse.Commission_Rate_Mon__c == NULL
                ||commRateToUse.Commission_Rate_Tue__c == NULL || commRateToUse.Commission_Rate_Wed__c == NULL
                ||commRateToUse.Commission_Rate_Thur__c == NULL || commRateToUse.Commission_Rate_Fri__c == NULL
                ||commRateToUse.Commission_Rate_Sat__c == NULL || commRateToUse.Commission_Rate_Sun__c == NULL
                ||commRateToUse.Commission_Rate_PHE__c == NULL || commRateToUse.Commission_Rate_PHD__c == NULL
                ||commRateToUse.Insertion_Rate__c == NULL || commRateToUse.Commission_Rate_Special_Mon__c == NULL
                ||commRateToUse.Commission_Rate_Special_Tue__c == NULL || commRateToUse.Commission_Rate_Special_Wed__c == NULL
                ||commRateToUse.Commission_Rate_Special_Thur__c == NULL || commRateToUse.Commission_Rate_Special_Fri__c == NULL
                ||commRateToUse.Commission_Rate_Special_Sat__c == NULL || commRateToUse.Commission_Rate_Special_Sun__c == NULL
                ||commRateToUse.Commission_Rate_Special_PHE__c == NULL || commRateToUse.Commission_Rate_Special_PHD__c == NULL)
            return false;
        else return true;
    }
    
    public HandlingFeeWrapper getCommRateOfTheDate(Date inputDate, Publication_Commission_Rates__c commRate, Set<Date> setHolidays)
    {
        HandlingFeeWrapper result = new HandlingFeeWrapper();
        String dayInWeek = DateUtility.dayInWeekEEE(inputDate);
        
        //Is Public Holiday?
        if(setHolidays.contains(inputDate))
        {
            if(dayInWeek == 'Sat' || dayInWeek == 'Sun')
            {
                result.commissionRate = commRate.Commission_Rate_PHE__c;
                result.specialComRate = commRate.Commission_Rate_Special_PHE__c;
            }
            else
            {
                result.commissionRate = commRate.Commission_Rate_PHD__c;
                result.specialComRate = commRate.Commission_Rate_Special_PHD__c;
            }
        }
        else
        {
            if(dayInWeek == 'Mon') 
            {
                result.commissionRate = commRate.Commission_Rate_Mon__c;
                result.specialComRate = commRate.Commission_Rate_Special_Mon__c;
            }
            else if(dayInWeek == 'Tue') 
            {
                result.commissionRate = commRate.Commission_Rate_Tue__c;
                result.specialComRate = commRate.Commission_Rate_Special_Tue__c;
            }
            else if(dayInWeek == 'Wed') 
            {
                result.commissionRate = commRate.Commission_Rate_Wed__c;
                result.specialComRate = commRate.Commission_Rate_Special_Wed__c;
            }
            else if(dayInWeek == 'Thu') 
            {
                result.commissionRate = commRate.Commission_Rate_Thur__c;
                result.specialComRate = commRate.Commission_Rate_Special_Thur__c;
            }
            else if(dayInWeek == 'Fri') 
            {
                result.commissionRate = commRate.Commission_Rate_Fri__c;
                result.specialComRate = commRate.Commission_Rate_Special_Fri__c;
            }
            else if(dayInWeek == 'Sat') 
            {
                result.commissionRate = commRate.Commission_Rate_Sat__c;
                result.specialComRate = commRate.Commission_Rate_Special_Sat__c;
            }
            else if(dayInWeek == 'Sun') 
            {
                result.commissionRate = commRate.Commission_Rate_Sun__c;
                result.specialComRate = commRate.Commission_Rate_Special_Sun__c;
            }
        }
        
        return result;
    }
    
    /* No longer needed
    public void increaseRunMonth()
    {
        Other__c setting;
        
        try{
            setting = [SELECT Name, Value__c FROM Other__c WHERE Name = 'VDC_BILL_MTH' LIMIT 1 FOR UPDATE];
            
            if(setting != null)
            {
                Integer intMth = Integer.valueOf(setting.Value__c);
                intMth ++;
                if(intMth == 13) intMth = 1;
                setting.Value__c = String.valueOf(intMth);
            }
        }
        catch(Exception e){ throw e;}
        finally
        {
            if(setting != null) UPDATE setting; //Release Lock
        }
    }
    */
    
    public class HandlingFeeWrapper{
        public Decimal commissionRate {get;set;}
        public Decimal specialComRate {get;set;}
        public Decimal insertRate {get;set;}
        public Integer numberOfPage {get;set;}
        public Decimal paginationRate {get;set;}
    }
    
    public class VendorInfoWrapper
    {
        public String vendorGroup {get;set;}
        public String vendorCode {get;set;}
        public String addressId {get;set;} //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Adding Addressid in VendorInfoWrapper
        public String recipientContactId {get;set;} //START/End UD-3702 - Hotfix Raviteja - 11Feb2016 - Adding ContactId in VendorInfoWrapper
    }
    
    public class COAWrapper
    {
        public Date effectiveDT {get;set;}
        public String vendorGroup {get;set;}
        public String vendorCode {get;set;}
        public String oldVendorGroup {get;set;}
        public String oldvendorCode {get;set;}
        public String oldaddressId {get;set;} //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Adding Addressid in COAwrapper
        public String newaddressId {get;set;} //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Adding Addressid in COAwrapper
        public String oldcontactId {get;set;} //START/End UD-3702 - Hotfix Raviteja - 11Feb2016 - Adding ContactId in COAwrapper
        public String newcontactId {get;set;} //START/End UD-3702 - Hotfix Raviteja - 11Feb2016 - Adding ContactId in COAwrapper
    }
}