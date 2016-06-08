/*
     * Class Name: SP_MidMonthTempStopBatch
     * @author: Karl Tan
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Batch Apex Class to Create Usage Records for Mid-Month Temp Stop Subscriptions
     * History: Jerella Ledesma 12/22/2014 Modified batch class to apply the changes for Product Catalogue's new product setup.
     *      02/02/2015 JohnD : totally refactor the entire code because of incorrect logic been built
     * History: D-2169, D-2170, D-1614, D-1616, & D-1617 / Jayson Sarion 03/05/2015 Modified batch class to apply the changes regarding code review that has been implemented
     * History: D-2425 03/20/2015 Added by J. Sarion - MD-55 Issue Calculation: Implement Proration Usage to Zuora based from the excel sent by Ankit
     * History: D-2701 04/7/2015 Added by Joban- D-2701 Added null check before the if conditions
     * History: D-2443 04/9/2015 Added by J.Sarion- Added checking of 30 refundable days per subscription per year
     */
global class SP_MidMonthTempStopBatch_SelectAccs implements Database.Batchable<sObject>, Database.AllowsCallouts { // Start/End D-2590 23Mar15 JohnD removed Database.Stateful
    
    final static string GRACE_NUMBER_OF_DAY_KEY = 'Grace Number of Days for Temp Stop';
    final static integer GRACE_NUMBER_OF_DAY = getGraceNumberOfDay();
    final static string CREDIT_USAGE = 'Credit Copy';
    final static string NO_CREDIT_USAGE = 'No Credit Copy';
    final static string CREDIT_USAGE_QRY_FIELD = CREDIT_USAGE + '%';
    final static string NO_CREDIT_USAGE_QRY_FIELD = NO_CREDIT_USAGE + '%';
    final static string TSTOP_FINAL = 'TStop Final';
    final static string TSTOP_CONVERT = 'TStop Convert';
    final static string TSTOP_TEMP = 'TStop Temp';
    final static string USAGE_STATUS = 'New';
    
    set<Usage__c> usageSet = new set<Usage__c>();
    list<Usage__c> usageList = new list<Usage__c>();
    Boolean isConvert = false;
    Boolean isFinal = false;
    Boolean isCredit = false;
    Boolean isNoCredit = false;
    map<id, integer> subscriptionTempStopId_quantity = new map<id, integer>();
    map<id, integer> subscriptionId_numberOfCopies = new map<id, integer>();
    map<id, string> subscriptionTempStopId_stopType = new map<id, string>();
    map<id, string> subscriptionId_uomType = new map<id, string>();
    Map<Id, Set<String>> subIdToPubCodeSetMap = new Map<Id, Set<String>>();
    Map<String, Zuora__SubscriptionProductCharge__c> spcIdentifierToSpcMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
    Map<Id, Map<String, Integer>> subTempStopIdToUOMToQuantityMap = new Map<Id, Map<String, Integer>>();
    Map<Id, usageQtyWrapper> subIdToQtyWrapperMap = new Map<Id, usageQtyWrapper>();
    Map<Id, usageQtyWrapper> subIdToRefundQtyWrapperMap = new Map<Id, usageQtyWrapper>();
    Map<Id, List<Subscription_Temp_Stop__c>> subIdToBatchSubTempStopListMap = new Map<Id, List<Subscription_Temp_Stop__c>>();
    Map<Id, List<Subscription_Temp_Stop__c>> subIdToPrevSubTempStopListMap = new Map<Id, List<Subscription_Temp_Stop__c>>();
    Map<Id, Integer> subIdToRefundDaysMap = new Map<Id, Integer>();
    
    String spcIdentifier;
    Date startDate;
    Date endDate;
    Integer year;
    Integer month;
    Integer currentYear;
    Integer nextYear;
    Integer refundCounter = 0;
    Integer remainingRefund = 0;
    Integer prevQty = 0;
    Boolean isNextYr = false;
    Boolean isRefundable = false;
    usageQtyWrapper qtyWrapper;
    usageQtyWrapper qtyWrapperPrep;
    Zuora__SubscriptionProductCharge__c spc;
    Usage__c usage; 
    
    Boolean selectAccountsFlag = false; 
    Set<String> accountNumberSet;
    
    global SP_MidMonthTempStopBatch_SelectAccs(Set<String> accountNumberSet){
        this.selectAccountsFlag = true;
        this.accountNumberSet = accountNumberSet;
    }       
    
    //START 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches  
    private final static Date referenceDate = UsageHelper.getUsageReferenceDate(); 
    //END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches    
    
    global Database.queryLocator start(Database.BatchableContext bc) {

        //START 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches        
        Date startDate = referenceDate.toStartOfMonth();
        Date endDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
        
        if(selectAccountsFlag) {
            return Database.getQueryLocator([select Id, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Subscription__c, Subscription__r.Zuora__Account__c, Subscription__r.Name, Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Subscription__r.Frequency_1__c, Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.Qty__c, Subscription__r.Number_of_Copies__c, Subscription__r.Ph_d__c, Subscription__r.Ph_e__c FROM Subscription_Temp_Stop__c WHERE Temp_Stop__r.Temp_Stop_Date__c <= :endDate AND Temp_Stop__r.Restart_Date__c >= :startDate AND Temp_Stop__r.Temp_Stop_Status__c != 'Cancelled' AND Subscription__r.Zuora__Account__r.AccountNumber IN :accountNumberSet]);  
        } else {
            return Database.getQueryLocator([select Id, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Subscription__c, Subscription__r.Zuora__Account__c, Subscription__r.Name, Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Subscription__r.Frequency_1__c, Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.Qty__c, Subscription__r.Number_of_Copies__c, Subscription__r.Ph_d__c, Subscription__r.Ph_e__c FROM Subscription_Temp_Stop__c WHERE Temp_Stop__r.Temp_Stop_Date__c <= :endDate AND Temp_Stop__r.Restart_Date__c >= :startDate AND Temp_Stop__r.Temp_Stop_Status__c != 'Cancelled']);        
        }
        
        //END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches
    }
    
    
    global void execute(Database.BatchableContext bc, list<Subscription_Temp_Stop__c> scope) {
        list<Usage__c> dueUsageList = new list<Usage__c>();
        List<Subscription_Temp_Stop__c> subTempStopList = new List<Subscription_Temp_Stop__c>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        //J.Sarion
        List<Subscription_Temp_Stop__c> prevSubTempStopList = new List<Subscription_Temp_Stop__c>();
        List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();
        //J.Sarion
        set<id> subscriptionTempStopIdSet = new set<id>();
        map<id, integer> dueSubscriptionTempStopId_totalQuantity = new map<id, integer>();
        map<id, set<string>> subscriptionId_subscriptionProductChargeUom = new map<id, set<string>>();
        map<id, UsageHelper.UsageParamWrapper> subscriptionId_UsageParamWrapper = new map<id, UsageHelper.UsageParamWrapper>();
        map<id, UsageHelper.UsageParamWrapper> subscriptionId_UsageParamWrapperRefined = new map<id, UsageHelper.UsageParamWrapper>();
        map<id, id> subscriptionId_subscriptionTempStopId = new map<id, id>();
        map<string, id> subscriptionName_subscriptionId = new map<string, id>();
        Map<Id, Zuora__Subscription__c> subIdToSubMap = new Map<Id, Zuora__Subscription__c>();
        Map<Id, Date> subIdToRefDateMap = new Map<Id, Date>();
        Set<Id> subIdSet = new Set<Id>();
        UsageHelper.UsageParamWrapper usageParamWrapper;
        Usage__c dueUsage = new Usage__c();
        integer year;
        integer month;
        integer subscriptionNumberOfCopies;
        integer tempStopQuantity;
        Date tempDate;
        Date restartDate;
        Date refDate;
        Date startDateRef = referenceDate.toStartOfMonth();
        Date endDateRef = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
        Date lastYearRef = date.newInstance(referenceDate.year()-1, 1, 1);
        Date thisYearRef = date.newInstance(referenceDate.year(), 12, 31);
        Zuora__Subscription__c subRec;

        PublicationIssueWrapper pubIssueWrapperObject;

        //START UD-1575 06/12/2015 Added by J. Sarion - Filter out Subscriptions with All-In-One packages
        Set<Id> scopeSubIdSet = new Set<Id>();
        Set<Id> pkgIdSet = new Set<Id>();
        Set<Id> filteredSubIdSet = new Set<Id>();
        List<Zuora__Subscription__c> scopeSubList = new List<Zuora__Subscription__c>();
        List<Package_Item__c> pkgItemList = new List<Package_Item__c>();
        Map<Id, List<Package_Item__c>> pkgIdToPkgItemsListMap = new Map<Id, List<Package_Item__c>>();
        List<Subscription_Temp_Stop__c> filteredSubTempStopList = new List<Subscription_Temp_Stop__c>();
        
        for (Subscription_Temp_Stop__c subTempStop : scope) {
            if(subTempStop.Subscription__c != null)
                scopeSubIdSet.add(subTempStop.Subscription__c);
        }
        
        if (!scopeSubIdSet.isEmpty()) {
            scopeSubList = [SELECT Id, Main_Package_1__c FROM Zuora__Subscription__c WHERE Id IN :scopeSubIdSet];
        }
        
        for (Zuora__Subscription__c sub :scopeSubList) {
            if (sub.Main_Package_1__c != null)
                pkgIdSet.add(sub.Main_Package_1__c);
        }
        
        if (!pkgIdSet.isEmpty()) {
            pkgItemList = [SELECT Package__c, Product_Rate_Plan__c, Id, Is_Print__c, Is_All_In_One__c, Is_Newspaper__c FROM Package_Item__c WHERE Package__c IN : pkgIdSet AND Is_Newspaper__c = TRUE AND (Is_Print__c=TRUE OR Is_All_In_One__c=TRUE)];
        }
        
        for (Package_Item__c pkgItem :pkgItemList) {
            if (pkgIdToPkgItemsListMap.containsKey(pkgItem.Package__c)) {
                pkgIdToPkgItemsListMap.get(pkgItem.Package__c).add(pkgItem);
            }
            else {
                pkgIdToPkgItemsListMap.put(pkgItem.Package__c, new List<Package_Item__c>());
                pkgIdToPkgItemsListMap.get(pkgItem.Package__c).add(pkgItem);
            }
        }
        
        for(Zuora__Subscription__c sub : scopeSubList){
            Integer counter = 0;
            if (pkgIdToPkgItemsListMap.containsKey(sub.Main_Package_1__c)) {
                for(Package_Item__c pkgItem : pkgIdToPkgItemsListMap.get(sub.Main_Package_1__c)){
                    if(pkgItem.Is_All_In_One__c == TRUE){
                        counter++;
                    }
                }
                if (counter == 0) {
                    filteredSubIdSet.add(sub.Id);
                }
            }
        }
        
        for (Subscription_Temp_Stop__c subTempStop : scope) {
            if (filteredSubIdSet.contains(subTempStop.Subscription__c)) {
                filteredSubTempStopList.add(subTempStop);
            }
        }
        //END UD-1575 06/12/2015 Added by J. Sarion - Filter out Subscriptions with All-In-One packages
        
        //START UD-1575 06/12/2015 Added by J. Sarion - Filter out Subscriptions with All-In-One packages
        for (Subscription_Temp_Stop__c subTempStop : filteredSubTempStopList) {
        //END UD-1575 06/12/2015 Added by J. Sarion - Filter out Subscriptions with All-In-One packages
            subIdSet.add(subTempStop.Subscription__c);
            subscriptionTempStopIdSet.add(subTempStop.Id);
            if (subIdToBatchSubTempStopListMap.containsKey(subTempStop.Subscription__c))
                subIdToBatchSubTempStopListMap.get(subTempStop.Subscription__c).add(subTempStop);
            else
                subIdToBatchSubTempStopListMap.put(subTempStop.Subscription__c, new List<Subscription_Temp_Stop__c>{subTempStop});
        
            if (subTempStop.Subscription__c != null && subTempStop.Subscription__r.Name != null 
                    && subTempStop.Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c != null 
                    && subTempStop.Temp_Stop__r.Temp_Stop_Date__c != null && subTempStop.Temp_Stop__r.Restart_Date__c != null 
                    && subTempStop.Subscription__r.Frequency_1__c != null) {      
                
                // scenario 1 : temp stop period within the same month where period days is < specified value
                if (subTempStop.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(subTempStop.Temp_Stop__r.Restart_Date__c) == 0 
                        && subTempStop.Temp_Stop__r.Temp_Stop_Date__c.daysBetween(subTempStop.Temp_Stop__r.Restart_Date__c) < GRACE_NUMBER_OF_DAY) {
                    // no credit

                    subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                    subscriptionTempStopId_stopType.put(subTempStop.Id, TSTOP_FINAL);
                    
                // scenario 2 : temp stop period within the same month where period days is >= specified value  
                } else if (subTempStop.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(subTempStop.Temp_Stop__r.Restart_Date__c) == 0 
                        && subTempStop.Temp_Stop__r.Temp_Stop_Date__c.daysBetween(subTempStop.Temp_Stop__r.Restart_Date__c) >= GRACE_NUMBER_OF_DAY) {
                    // credit
                    
                    subscriptionId_uomType.put(subTempStop.Subscription__c, CREDIT_USAGE);
                    subscriptionTempStopId_stopType.put(subTempStop.Id, TSTOP_FINAL);
                    
                // scenario 3 : temp stop period across months where period days is < specified value
                } else if (subTempStop.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(subTempStop.Temp_Stop__r.Restart_Date__c) != 0 
                        && subTempStop.Temp_Stop__r.Temp_Stop_Date__c.daysBetween(subTempStop.Temp_Stop__r.Restart_Date__c) < GRACE_NUMBER_OF_DAY) {
                    // no credit            
                
                        subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                        subscriptionTempStopId_stopType.put(subTempStop.Id, TSTOP_TEMP);
                        
                        if (subTempStop.Temp_Stop__r.Restart_Date__c.monthsBetween(referenceDate) == 0) { //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches    
                            //dueSubscriptionTempStopId_totalQuantity.put(subTempStop.Id, 0);
                            subTempStopIdToUOMToQuantityMap.put(subTempStop.Id, new Map<String, Integer>());
                            subscriptionTempStopId_stopType.put(subTempStop.Id, TSTOP_CONVERT);
                        }                       
                    //}
                    
                // scenario 4 : temp stop period across months where period days is >= specified value
                } else if (subTempStop.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(subTempStop.Temp_Stop__r.Restart_Date__c) != 0 
                        && subTempStop.Temp_Stop__r.Temp_Stop_Date__c.daysBetween(subTempStop.Temp_Stop__r.Restart_Date__c) >= GRACE_NUMBER_OF_DAY) {
                    // credit

                        subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                        subscriptionTempStopId_stopType.put(subTempStop.Id, TSTOP_TEMP);
                    //}
                    
                    if (subTempStop.Temp_Stop__r.Restart_Date__c.monthsBetween(referenceDate) == 0) { //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches    
                        subscriptionId_uomType.put(subTempStop.Subscription__c, CREDIT_USAGE);
                        subTempStopIdToUOMToQuantityMap.put(subTempStop.Id, new Map<String, Integer>());
                        subscriptionTempStopId_stopType.put(subTempStop.Id, TSTOP_CONVERT);
                    }
                }
                
            }
        }
        
        if (!subIdSet.isEmpty()) {
            subList = [SELECT Id, Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Order_Line_Item_Number_1__r.Ph_e__c, Order_Line_Item_Number_1__r.Ph_d__c, Frequency_1__c FROM Zuora__Subscription__c WHERE Id IN :subIdSet];
            //J.Sarion
            prevSubTempStopList = [SELECT Id, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Subscription__c, Subscription__r.Zuora__Account__c, Subscription__r.Name, Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Subscription__r.Frequency_1__c, Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.Qty__c, Subscription__r.Number_of_Copies__c, Subscription__r.Ph_d__c, Subscription__r.Ph_e__c FROM Subscription_Temp_Stop__c WHERE Id NOT IN :subscriptionTempStopIdSet AND Subscription__c IN :subIdSet AND Temp_Stop__r.Temp_Stop_Date__c < :startDateRef AND Temp_Stop__r.Temp_Stop_Date__c >= :lastYearRef AND Temp_Stop__r.Restart_Date__c < :startDateRef AND Temp_Stop__r.Restart_Date__c <= :thisYearRef AND Temp_Stop__r.Temp_Stop_Status__c != 'Cancelled' Order By Temp_Stop__r.Temp_Stop_Date__c ASC];
            
            spcList = [SELECT Name, Zuora__Subscription__c, Zuora__UOM__c, PublicationCode__c, Zuora__ChargeNumber__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN :subIdSet];
            //J.Sarion
        }
        
        for (Zuora__Subscription__c sub :subList) {
            subIdToSubMap.put(sub.Id, sub);
        }
        

        for (Zuora__SubscriptionProductCharge__c spc :spcList) {
            if (subIdToPubCodeSetMap.containsKey(spc.Zuora__Subscription__c)) {
                if (spc.PublicationCode__c != null)
                    subIdToPubCodeSetMap.get(spc.Zuora__Subscription__c).add(spc.PublicationCode__c);
            }
            else {
                if (spc.PublicationCode__c != null)
                    subIdToPubCodeSetMap.put(spc.Zuora__Subscription__c, new Set<String> {spc.PublicationCode__c});
            }
            
            spcIdentifierToSpcMap.put(spc.Zuora__Subscription__c + ' ' + spc.Name, spc);
        }
        for (Subscription_Temp_Stop__c subTempStop :prevSubTempStopList) {
            if (subIdToPrevSubTempStopListMap.containsKey(subTempStop.Subscription__c))
                subIdToPrevSubTempStopListMap.get(subTempStop.Subscription__c).add(subTempStop);
            else
                subIdToPrevSubTempStopListMap.put(subTempStop.Subscription__c, new List<Subscription_Temp_Stop__c>{subTempStop});
        }

        for (Id subId :subIdToPrevSubTempStopListMap.keySet()) {
            refundCounter = 0;
            
            if (subIdToSubMap.containsKey(subId)) {
                subRec = subIdToSubMap.get(subId);
            }

            if (subRec != null) {
                for (Subscription_Temp_Stop__c subTempStop :subIdToPrevSubTempStopListMap.get(subId)) {
                    isRefundable = false;
                    if (subTempStop.Temp_Stop__r.Temp_Stop_Date__c.daysBetween(subTempStop.Temp_Stop__r.Restart_Date__c) >= GRACE_NUMBER_OF_DAY) {
                        isRefundable = true;
                    }
                    
                    if (isRefundable) {
                        year = referenceDate.year();
                        
                        if (subTempStop.Temp_Stop__r.Temp_Stop_Date__c.year() == year-1)
                            startDate = date.newInstance(year, 1, 1);
                        else if (subTempStop.Temp_Stop__r.Temp_Stop_Date__c.year() == year)
                            startDate = subTempStop.Temp_Stop__r.Temp_Stop_Date__c;

                        if (subIdToPubCodeSetMap.containsKey(SubId)) {
                            for(String pubCode : subIdToPubCodeSetMap.get(SubId)){
                                UsageHelper.initialize();

                                PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubCode, startDate, subTempStop.Temp_Stop__r.Restart_Date__c.addDays(-1), subRec, 1);
                                currentYear = pubWrapperDiscount.current_year_days;
                                nextYear = pubWrapperDiscount.next_year_days;
                                if(currentYear != 0) {
                                    refundCounter += currentYear;
                                }
                            }
                        }                   
                    }
                }                   
                subIdToRefundDaysMap.put(subRec.Id, refundCounter);
            }
        }

        //START UD-1575 06/12/2015 Added by J. Sarion - Filter out Subscriptions with All-In-One packages
        for (Subscription_Temp_Stop__c subTempStop :filteredSubTempStopList) {
        //END UD-1575 06/12/2015 Added by J. Sarion - Filter out Subscriptions with All-In-One packages
            if (subTempStop.Temp_Stop__r.Restart_Date__c.monthsBetween(referenceDate) == 0) {
                isRefundable = false;
                if (subTempStop.Temp_Stop__r.Temp_Stop_Date__c.daysBetween(subTempStop.Temp_Stop__r.Restart_Date__c) >= GRACE_NUMBER_OF_DAY) {
                    if (subIdToRefundDaysMap.containsKey(subTempStop.Subscription__c)) {
                        if (subIdToRefundDaysMap.get(subTempStop.Subscription__c) < 30) {
                            isRefundable = true;
                            refundCounter = subIdToRefundDaysMap.get(subTempStop.Subscription__c);
                        }
                    }
                    else {
                        isRefundable = true;
                        refundCounter = 0;
                    }
                }

                if (subIdToSubMap.containsKey(subTempStop.Subscription__c)) {
                    subRec = subIdToSubMap.get(subTempStop.Subscription__c);
                }
                if (subRec != null && refundCounter < 30) { 
                    if (isRefundable) {
                        year = referenceDate.year();
                        month = referenceDate.month();
                        refDate = subTempStop.Temp_Stop__r.Restart_Date__c;
                        qtyWrapper = new usageQtyWrapper();

                        for(tempDate = subTempStop.Temp_Stop__r.Temp_Stop_Date__c; tempDate<refDate; tempDate=tempDate.addDays(1)){
                            if (subIdToPubCodeSetMap.containsKey(subTempStop.Subscription__c)) {
                                for(String pubCode : subIdToPubCodeSetMap.get(subTempStop.Subscription__c)){
                                    UsageHelper.initialize();

                                    PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubCode, tempDate, tempDate, subRec, 1);
                                    currentYear = pubWrapperDiscount.current_year_days;
                                    if(currentYear != 0) {
                                        refundCounter++;
                                    }
                                    if (refundCounter == 30)
                                        break;
                                }
                            }
                            if (refundCounter == 30) {
                                refDate = tempDate;
                                break;
                            }
                        }

                        if (refundCounter != 30)
                            refDate = subTempStop.Temp_Stop__r.Restart_Date__c.addDays(-1);
                        if (subIdToPubCodeSetMap.containsKey(subTempStop.Subscription__c)) {
                            for (String pubCode :subIdToPubCodeSetMap.get(subTempStop.Subscription__c)) {
                                UsageHelper.initialize();
                                pubIssueWrapperObject = UsageHelper.IssueCalculation(pubCode, subTempStop.Temp_Stop__r.Temp_Stop_Date__c, refDate, subRec, 1);
                                if (pubIssueWrapperObject.weekday_no_of_copies != 0)
                                    qtyWrapper.weekday = pubIssueWrapperObject.weekday_no_of_copies;
                                if (pubIssueWrapperObject.sat_no_of_copies != 0)
                                    qtyWrapper.sat = pubIssueWrapperObject.sat_no_of_copies;
                                if (pubIssueWrapperObject.sun_no_of_copies != 0) {
                                    qtyWrapper.sun = pubIssueWrapperObject.sun_no_of_copies;
                                }
                                if (pubIssueWrapperObject.odd_freq_copies != 0)
                                    qtyWrapper.oddFreq = pubIssueWrapperObject.odd_freq_copies;
                            }
                            subIdToRefundQtyWrapperMap.put(subTempStop.Subscription__c, qtyWrapper);
                        }
                    }
                }
            }
        }
        
        // end prepare the parameters used to generate the usage thru UsageHelper class
        
        for (Usage__c usage :[SELECT Quantity__c, Subscription_Temp_Stop__c, UOM__c FROM Usage__c WHERE 
                Subscription_Temp_Stop__c in :subTempStopIdToUOMToQuantityMap.keySet()]) {
            
            
            //START 04/07/2015 D-2701 Joban : Added null check for the fields
            if (subTempStopIdToUOMToQuantityMap.containsKey(usage.Subscription_Temp_Stop__c) && usage.UOM__c!=null && usage.Quantity__c!=null) {
            //END 04/07/2015 D-2701 Joban : Added null check for the fields
                if (subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).containsKey('Weekday') && usage.UOM__c.contains('Weekday'))
                    subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Weekday', subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).get('Weekday') + Integer.valueOf(usage.Quantity__c));
                else if (subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).containsKey('Sat') && usage.UOM__c.contains('Sat'))
                    subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Sat', subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).get('Sat') + Integer.valueOf(usage.Quantity__c));
                else if (subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).containsKey('Sun') && usage.UOM__c.contains('Sun'))
                    subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Sun', subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).get('Sun') + Integer.valueOf(usage.Quantity__c));
                else if (subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).containsKey('Online') && usage.UOM__c.contains('Online') && !usage.UOM__c.contains('AIO Online'))
                    subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Online', subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).get('Online') + Integer.valueOf(usage.Quantity__c));
                else if (subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).containsKey('Tablet') && usage.UOM__c.contains('Tablet') && !usage.UOM__c.contains('AIO Tablet'))
                    subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Tablet', subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).get('Tablet') + Integer.valueOf(usage.Quantity__c));
                else if (subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).containsKey('Smartphone') && usage.UOM__c.contains('Smartphone') && !usage.UOM__c.contains('AIO Smartphone'))
                    subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Smartphone', subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).get('Smartphone') + Integer.valueOf(usage.Quantity__c));
                else if (subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).containsKey('AIO Online') && usage.UOM__c.contains('AIO Online'))
                    subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('AIO Online', subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).get('AIO Online') + Integer.valueOf(usage.Quantity__c));
                else if (subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).containsKey('AIO Tablet') && usage.UOM__c.contains('AIO Tablet'))
                    subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('AIO Tablet', subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).get('AIO Tablet') + Integer.valueOf(usage.Quantity__c));
                else if (subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).containsKey('AIO Smartphone') && usage.UOM__c.contains('AIO Smartphone'))
                    subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('AIO Smartphone', subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).get('AIO Smartphone') + Integer.valueOf(usage.Quantity__c));
                else {
                    if (usage.UOM__c.contains('Weekday'))
                        subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Weekday', Integer.valueOf(usage.Quantity__c));
                    else if (usage.UOM__c.contains('Sat'))
                        subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Sat', Integer.valueOf(usage.Quantity__c));
                    else if (usage.UOM__c.contains('Sun'))
                        subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Sun', Integer.valueOf(usage.Quantity__c));
                    else if (usage.UOM__c.contains('Online') && !usage.UOM__c.contains('AIO Online'))
                        subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Online', Integer.valueOf(usage.Quantity__c));
                    else if (usage.UOM__c.contains('Tablet') && !usage.UOM__c.contains('AIO Tablet'))
                        subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Tablet', Integer.valueOf(usage.Quantity__c));
                    else if (usage.UOM__c.contains('Smartphone') && !usage.UOM__c.contains('AIO Smartphone'))
                        subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('Smartphone', Integer.valueOf(usage.Quantity__c));
                    else if (usage.UOM__c.contains('AIO Online'))
                        subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('AIO Online', Integer.valueOf(usage.Quantity__c));
                    else if (usage.UOM__c.contains('AIO Tablet'))
                        subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('AIO Tablet', Integer.valueOf(usage.Quantity__c));
                    else if (usage.UOM__c.contains('AIO Smartphone'))
                        subTempStopIdToUOMToQuantityMap.get(usage.Subscription_Temp_Stop__c).put('AIO Smartphone', Integer.valueOf(usage.Quantity__c));
                }
            }
        
        }
        
        for (Id subTempStopId :subTempStopIdToUOMToQuantityMap.keySet()) {
            for (String uom :subTempStopIdToUOMToQuantityMap.get(subTempStopId).keySet()) {
                if (uom == 'Online' || uom == 'Tablet' || uom == 'Smartphone' || uom == 'AIO Online' || uom == 'AIO Tablet' || uom == 'AIO Smartphone')
                    subTempStopIdToUOMToQuantityMap.get(subTempStopId).put('Digital', subTempStopIdToUOMToQuantityMap.get(subTempStopId).get(uom));
                    
                break;
            }
        }

        //START UD-1575 06/12/2015 Added by J. Sarion - Filter out Subscriptions with All-In-One packages
        for (Subscription_Temp_Stop__c subTempStop :filteredSubTempStopList) {
        //END UD-1575 06/12/2015 Added by J. Sarion - Filter out Subscriptions with All-In-One packages
            year = referenceDate.year(); //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches 
            month = referenceDate.month();  //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches  
            UsageHelper.initialize();
        
            subRec = subIdToSubMap.get(subTempStop.Subscription__c);
            if (subTempStop.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(referenceDate) == 0) { //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches  
                startDate = subTempStop.Temp_Stop__r.Temp_Stop_Date__c;
            } else {
                startDate = date.newInstance(year, month, 1);
            }

            if (subTempStop.Temp_Stop__r.Restart_Date__c.monthsBetween(referenceDate) == 0) { //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches    
                endDate = subTempStop.Temp_Stop__r.Restart_Date__c.addDays(-1);
            } else {
                endDate = date.newInstance(year, month, date.daysInMonth(year, month));
            }
            if (subIdToPubCodeSetMap.containsKey(subTempStop.Subscription__c)) {
                qtyWrapper = new usageQtyWrapper();
                for (String pubCode :subIdToPubCodeSetMap.get(subTempStop.Subscription__c)) {
                    pubIssueWrapperObject = UsageHelper.IssueCalculation(pubCode, startDate, endDate, subRec, Integer.valueOf(subTempStop.Temp_Stop__r.Qty__c));
                    system.debug('>>>>>pubIssueWrapperObject ' + pubIssueWrapperObject);

                    if (pubIssueWrapperObject.weekday_no_of_copies != 0)
                        qtyWrapper.weekday = pubIssueWrapperObject.weekday_no_of_copies;
                    if (pubIssueWrapperObject.sat_no_of_copies != 0)
                        qtyWrapper.sat = pubIssueWrapperObject.sat_no_of_copies;
                    if (pubIssueWrapperObject.sun_no_of_copies != 0)
                        qtyWrapper.sun = pubIssueWrapperObject.sun_no_of_copies;
                    if (pubIssueWrapperObject.odd_freq_copies != 0)
                        qtyWrapper.oddFreq = pubIssueWrapperObject.odd_freq_copies;
                }
                subIdToQtyWrapperMap.put(subTempStop.Subscription__c, qtyWrapper);
            }
        }
        system.debug('>>>>>subIdToQtyWrapperMap ' + subIdToQtyWrapperMap);
        //START UD-1575 06/12/2015 Added by J. Sarion - Filter out Subscriptions with All-In-One packages
        for (Subscription_Temp_Stop__c subTempStop :filteredSubTempStopList) {
        //END UD-1575 06/12/2015 Added by J. Sarion - Filter out Subscriptions with All-In-One packages
            qtyWrapperPrep = new usageQtyWrapper();
            if (subIdToQtyWrapperMap.containsKey(subTempStop.Subscription__c))
                qtyWrapperPrep = subIdToQtyWrapperMap.get(subTempStop.Subscription__c);
            //START D-2443 04/10/2015 Added by J.Sarion - Removed If conditions
            //START 04/10/2015 D-2725 Kevin Evasco - Proceed only if freq is a valid frequency.
            if(pubIssueWrapperObject != null) {
                createUsagePrep(subTempStop, qtyWrapperPrep.weekday, 'Weekday');                

                createUsagePrep(subTempStop, qtyWrapperPrep.sun, 'Sun');
                createUsagePrep(subTempStop, qtyWrapperPrep.sat, 'Sat');
            
                createUsagePrep(subTempStop, pubIssueWrapperObject.odd_freq_copies, 'Smartphone');
                createUsagePrep(subTempStop, pubIssueWrapperObject.odd_freq_copies, 'Tablet');
                createUsagePrep(subTempStop, pubIssueWrapperObject.odd_freq_copies, 'AIO Online');
                createUsagePrep(subTempStop, pubIssueWrapperObject.odd_freq_copies, 'AIO Smartphone');
                createUsagePrep(subTempStop, pubIssueWrapperObject.odd_freq_copies, 'AIO Tablet'); 
            }
            //END 04/10/2015 D-2725 Kevin Evasco - Proceed only if freq is a valid frequency.
            //END D-2443 04/10/2015 Added by J.Sarion - Removed If conditions
        }
        //START D-2590 03/22/2015 Added by J.Sarion - Added Date_Added Field
        for (Usage__c usage :usageList) {
        }
        UsageHelper.insertUniqueUsages(usageList);
        //if (!usageList.isEmpty())
        //    insert usageList;
        //END D-2590 03/22/2015 Added by J.Sarion - Added Date_Added Field
        //REMOVED FOR D-2610 */
        //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
    }

    global void finish(Database.BatchableContext bc) {
        BatchJobHelper.updateJobStatus(BC.getJobId());
    }   

    
    private static integer getGraceNumberOfDay() {
        
        integer numberOfDay;
        
        try {
            Other__c other = Other__c.getInstance(GRACE_NUMBER_OF_DAY_KEY);
            numberOfDay = integer.valueOf(other.Value__c);   
        } catch (exception e) {
            numberOfDay = 8;
        }
        
        return numberOfDay;
    }
    
    private static string generateSpcIndentifierKey(string subscriptionId, string uom) {
        return subscriptionId + ' ' + uom;
    }
    
    private void createUsagePrep (Subscription_Temp_Stop__c subTempStop, Integer quantity, String uom) {        
        prevQty = 0;
        isCredit = false;
        //START 04/16/2015 D-2612 Added by J.Sarion - Set isFinal and isConvert to False
        isFinal = false;
        isConvert = false;
        //END 04/16/2015 D-2612 Added by J.Sarion - Set isFinal and isConvert to False
        if (subscriptionId_uomType.containsKey(subTempStop.Subscription__c)) {
            if (subscriptionId_uomType.get(subTempStop.Subscription__c) == CREDIT_USAGE)
                isCredit = true;
            else
                isCredit = false;
        }
                
        if (subscriptionTempStopId_stopType.get(subTempStop.Id) == TSTOP_CONVERT) {
            isFinal = true;
            isConvert = true;
        }
        
        if (subIdToRefundQtyWrapperMap.containsKey(subTempStop.Subscription__c)) {
            qtyWrapper = subIdToRefundQtyWrapperMap.get(subTempStop.Subscription__c);
        }
        if (subTempStopIdToUOMToQuantityMap.containsKey(subTempStop.Id))
            if (subTempStopIdToUOMToQuantityMap.get(subTempStop.Id).containsKey(uom))
                prevQty = subTempStopIdToUOMToQuantityMap.get(subTempStop.Id).get(uom);
        
        if ((subscriptionTempStopId_stopType.get(subTempStop.Id) == TSTOP_FINAL || subscriptionTempStopId_stopType.get(subTempStop.Id) == TSTOP_CONVERT) && subscriptionId_uomType.get(subTempStop.Subscription__c) == CREDIT_USAGE) {
            system.debug('>>>>>qtyWrapper.sun ' + qtyWrapper.sun);
            if (subIdToRefundDaysMap.containsKey(subTempStop.Subscription__c)) {
                if (subIdToRefundDaysMap.get(subTempStop.Subscription__c) >= 30) {
                    subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                    usage = createUsage(subTempStop, quantity + prevQty, uom);
                    if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                        usageList.add(usage);
                }
                else {
                    if (uom == 'Weekday') {
                        remainingRefund = (qtyWrapper.weekday != null ? qtyWrapper.weekday : 0);
                        if (remainingRefund != 0) {
                            usage = createUsage(subTempStop, remainingRefund, uom);
                            if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                                usageList.add(usage);
                        }
                        
                        if (quantity + prevQty - remainingRefund != 0) {
                            subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                            usage = createUsage(subTempStop, quantity + prevQty - remainingRefund, uom);
                            subscriptionId_uomType.put(subTempStop.Subscription__c, CREDIT_USAGE);
                            if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                                usageList.add(usage);
                        }
                    }
                    else if (uom == 'Sat') {
                        remainingRefund = (qtyWrapper.sat != null ? qtyWrapper.sat : 0);
                        if (remainingRefund != 0) {
                            usage = createUsage(subTempStop, remainingRefund, uom);
                            if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                                usageList.add(usage);
                        }
                        
                        if (quantity + prevQty - remainingRefund != 0) {
                            subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                            usage = createUsage(subTempStop, quantity + prevQty - remainingRefund, uom);
                            subscriptionId_uomType.put(subTempStop.Subscription__c, CREDIT_USAGE);
                            if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                                usageList.add(usage);
                        }
                    }
                    else if (uom == 'Sun') {
                        remainingRefund = (qtyWrapper.sun != null ? qtyWrapper.sun : 0);
                        if (remainingRefund != 0) {
                            usage = createUsage(subTempStop, remainingRefund, uom);
                            if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                                usageList.add(usage);
                        }
                        
                        if (quantity + prevQty - remainingRefund != 0) {
                            subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                            usage = createUsage(subTempStop, quantity + prevQty - remainingRefund, uom);
                            subscriptionId_uomType.put(subTempStop.Subscription__c, CREDIT_USAGE);
                            if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                                usageList.add(usage);
                        }
                    }
                    else if (uom == 'Online' || uom == 'Tablet' || uom == 'Smartphone' || uom == 'AIO Online' || uom == 'AIO Tablet' || uom == 'AIO Smartphone') {
                        remainingRefund = (qtyWrapper.oddFreq != null ? qtyWrapper.oddFreq : 0);
                        if (remainingRefund != 0) {
                            usage = createUsage(subTempStop, remainingRefund, uom);
                            if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                                usageList.add(usage);
                        }
                        
                        if (quantity + prevQty - remainingRefund != 0) {
                            subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                            usage = createUsage(subTempStop, quantity + prevQty - remainingRefund, uom);
                            subscriptionId_uomType.put(subTempStop.Subscription__c, CREDIT_USAGE);
                            if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                                usageList.add(usage);
                        }
                    }
                }
            }
            else {
                if (uom == 'Weekday') {
                    remainingRefund = (qtyWrapper.weekday != null ? qtyWrapper.weekday : 0);
                    if (remainingRefund != 0) {
                        usage = createUsage(subTempStop, remainingRefund, uom);
                        if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                            usageList.add(usage);
                    }
                    
                    if (quantity + prevQty - remainingRefund != 0) {
                        subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                        usage = createUsage(subTempStop, quantity + prevQty - remainingRefund, uom);
                        subscriptionId_uomType.put(subTempStop.Subscription__c, CREDIT_USAGE);
                        if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                            usageList.add(usage);
                    }
                }
                else if (uom == 'Sat') {
                    remainingRefund = (qtyWrapper.sat != null ? qtyWrapper.sat : 0);
                    if (remainingRefund != 0) {
                        usage = createUsage(subTempStop, remainingRefund, uom);
                        if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                            usageList.add(usage);
                    }
                    
                    if (quantity + prevQty - remainingRefund != 0) {
                        subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                        usage = createUsage(subTempStop, quantity + prevQty - remainingRefund, uom);
                        subscriptionId_uomType.put(subTempStop.Subscription__c, CREDIT_USAGE);
                        if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                            usageList.add(usage);
                    }
                }
                else if (uom == 'Sun') {
                    remainingRefund = (qtyWrapper.sun != null ? qtyWrapper.sun : 0);
                    if (remainingRefund != 0) {
                        usage = createUsage(subTempStop, remainingRefund, uom);
                        if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                            usageList.add(usage);
                    }
                    
                    if (quantity + prevQty - remainingRefund != 0) {
                        subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                        usage = createUsage(subTempStop, quantity + prevQty - remainingRefund, uom);
                        subscriptionId_uomType.put(subTempStop.Subscription__c, CREDIT_USAGE);
                        if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                            usageList.add(usage);
                    }
                }
                else if (uom == 'Online' || uom == 'Tablet' || uom == 'Smartphone' || uom == 'AIO Online' || uom == 'AIO Tablet' || uom == 'AIO Smartphone') {
                    remainingRefund = (qtyWrapper.oddFreq != null ? qtyWrapper.oddFreq : 0);
                    if (remainingRefund != 0) {
                        usage = createUsage(subTempStop, remainingRefund, uom);
                        if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                            usageList.add(usage);
                    }
                    
                    if (quantity + prevQty - remainingRefund != 0) {
                        subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                        usage = createUsage(subTempStop, quantity + prevQty - remainingRefund, uom);
                        subscriptionId_uomType.put(subTempStop.Subscription__c, CREDIT_USAGE);
                        if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                            usageList.add(usage);
                    }
                }
            }
            
        }
        //TStop Final and NO_CREDIT_USAGE
        else {
            system.debug('>>>>>Sub ' + subTempStop.Subscription__c + ' Less than Grace Days');
            if (uom == 'Weekday') {
                remainingRefund = (qtyWrapper.weekday != null ? qtyWrapper.weekday : 0);
                usage = createUsage(subTempStop, quantity + prevQty, uom);
            }
            else if (uom == 'Sat') {
                remainingRefund = (qtyWrapper.sat != null ? qtyWrapper.sat : 0);
                usage = createUsage(subTempStop, quantity + prevQty, uom);
            }
            else if (uom == 'Sun') {
                remainingRefund = (qtyWrapper.sun != null ? qtyWrapper.sun : 0);
                usage = createUsage(subTempStop, quantity + prevQty, uom);
            }
            else if (uom == 'Online' || uom == 'Tablet' || uom == 'Smartphone' || uom == 'AIO Online' || uom == 'AIO Tablet' || uom == 'AIO Smartphone') {
                remainingRefund = (qtyWrapper.oddFreq != null ? qtyWrapper.oddFreq : 0);
                usage = createUsage(subTempStop, quantity + prevQty, uom);
            }
            
            if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                usageList.add(usage);
        }
        isFinal = false;
        //START D-2590 03/22/2015 Added by J.Sarion - Added Date_Added Field
        if (subTempStopIdToUOMToQuantityMap.containsKey(subTempStop.Id)) {
            if (subTempStopIdToUOMToQuantityMap.get(subTempStop.Id).containsKey(uom)) {
                subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
                if (uom == 'Online' || uom == 'Tablet' || uom == 'Smartphone' || uom == 'AIO Online' || uom == 'AIO Tablet' || uom == 'AIO Smartphone')
                    usage = createUsage(subTempStop, subTempStopIdToUOMToQuantityMap.get(subTempStop.Id).get('Digital'), uom);
                else
                    usage = createUsage(subTempStop, subTempStopIdToUOMToQuantityMap.get(subTempStop.Id).get(uom), uom);
                
                usage.StopType__c = subscriptionTempStopId_stopType.get(subTempStop.Id);
                system.debug('>>>>>usageFINAL ' + usage);
                if (usage != null && usage.Quantity__c > 0 && usage.Quantity__c != null)
                    usageList.add(usage);
                isConvert = false;
            }
            if (isCredit)
                subscriptionId_uomType.put(subTempStop.Subscription__c, CREDIT_USAGE);
            else
                subscriptionId_uomType.put(subTempStop.Subscription__c, NO_CREDIT_USAGE);
        }
        //END D-2590 03/22/2015 Added by J.Sarion - Added Date_Added Field
    }
    
    private Usage__c createUsage (Subscription_Temp_Stop__c subTempStop, Integer quantity, String uom) {
        spcIdentifier = generateSpcIndentifierKey(subTempStop.Subscription__c, subscriptionId_uomType.get(subTempStop.Subscription__c) + ' ' + uom);
        Integer year = referenceDate.year(); //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches 
        Integer month = referenceDate.month(); //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches        
                        
        usage = new Usage__c();
        
        if (uom == 'Online' || uom == 'Tablet' || uom == 'Smartphone' || uom == 'AIO Online' || uom == 'AIO Tablet' || uom == 'AIO Smartphone')
            uom = 'Digital';
        
        if (spcIdentifierToSpcMap.containsKey(spcIdentifier)) {
            spc = spcIdentifierToSpcMap.get(spcIdentifier);
            
            if (subTempStop.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(referenceDate) == 0) { //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches  
                startDate = subTempStop.Temp_Stop__r.Temp_Stop_Date__c;
            } else {
                startDate = date.newInstance(year, month, 1);
            }

            if (subTempStop.Temp_Stop__r.Restart_Date__c.monthsBetween(referenceDate) == 0) { //START/END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches    
                endDate = subTempStop.Temp_Stop__r.Restart_Date__c.addDays(-1);
            } else {
                endDate = date.newInstance(year, month, date.daysInMonth(year, month));
            }
            
            //START D-2590 03/22/2015 Added by J.Sarion - Added Date_Added Field
            usage.Date_Added__c = DateTime.Now();
            //END D-2590 03/22/2015 Added by J.Sarion - Added Date_Added Field
            usage.Account_Id__c = subTempStop.Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
            usage.Subscription_Id__c = subTempStop.Subscription__r.Name;
            usage.Start_Date__c = startDate;
            usage.End_Date__c = endDate;
            usage.Status__c = USAGE_STATUS;
            usage.UOM__c = spc.Zuora__UOM__c;
            usage.Rate_Plan_Charge_Id__c = spc.Zuora__ChargeNumber__c;   
            usage.Publication_Code__c = spc.PublicationCode__c; //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier       
            usage.Quantity__c = quantity;
            usage.Subscription_Temp_Stop__c = subTempStop.Id;
            usage.StopType__c = subscriptionTempStopId_stopType.get(subTempStop.Id);
            if (isFinal) {
                usage.StopType__c = TSTOP_FINAL;
                system.debug('>>>>>StopType ' + usage.Quantity__c);
                    
            }
            else if (isConvert) {
                usage.StopType__c = TSTOP_CONVERT;
            }
            usage.Usage_Type__c = UsageHelper.USAGE_TYPE_TSTOP;
             
        }
        return usage;
    }
    public class usageQtyWrapper {
        public Integer weekday = 0;
        public Integer sun = 0;
        public Integer sat = 0;
        public Integer oddFreq = 0;
    }
}