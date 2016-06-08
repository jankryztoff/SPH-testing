/**
 * Class Name: usageCreationForStopSubscription
 * @author: Jayson Sarion
 * Date: 03/19/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description: Create Usage for Stop Subscription - D-2425 MD - 55: Issue Calculation
 */
 
public with sharing class usageCreationForStopSubscription {
    final string CREDIT_USAGE = 'Credit Copy';
    final string USAGE_STATUS = 'New';
    //START D-3179 07/04/2015 Added by J.Sarion - Commented out logic for creation of usages for Postpaid
    /*
    //START UD-1676 6/23/2015 Added By C. Lin - Usage for Recurring Post Paid
    final string ISSUE_USAGE = 'Issue';
    final string COPY_USAGE = 'Copy';
    //END UD-1676 6/23/2015 Added By C. Lin
    */
    //END D-3179 07/04/2015 Added by J.Sarion - Commented out logic for creation of usages for Postpaid
    Map<String, Zuora__SubscriptionProductCharge__c> spcIdentifierToSpcMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
    Map<Id, String> subIdToUomTypeMap = new Map<Id, String>();
    Map<Id, Set<String>> subIdToPubCodeSetMap = new Map<Id, Set<String>>();
    // START : D-2429 / K. Tan / Set to Stop Date minus one as per the clarification provided   
    Map<String, Date> subscriptionToStopDateMap = new Map<String, Date>();
    // END: D-2429 / K. Tan / Set to Stop Date minus one as per the clarification provided   
    
    //START 03/31/2015 D-2610 Kevin Evasco - REMOVED CODE
    //START D-2429 03/22/2015 Added by K. Tan - Set endDate to Subscription End Date
    //Map<Integer, Map<String, Object>> identifierToUsageMap = new Map<Integer, Map<String, Object>>();
    //END D-2429 03/22/2015 Added by K. Tan - Set endDate to Subscription End Date
    //END 03/31/2015 D-2610 Kevin Evasco - REMOVED CODE
    
    List<Map<String, Object>> usageMapList = new List<Map<String, Object>>();
    Set<Map<String, Object>> usageMapSet = new Set<Map<String, Object>>();
    Set<Usage__c> usageSet = new Set<Usage__c>();
    List<Usage__c> usageList = new List<Usage__c>();

    String spcIdentifier;
    Date endDate;
    Date startDate;
    Date subEndDate;
    //Start D-2815 James
    Date earliestStopDate;
    Date subEndDateEndMth;
    //End D-2815 James
    Integer year;
    Integer month;
    //START D-2429 03/22/2015 Added by K. Tan - Set endDate to Subscription End Date
    Integer count = 0;
    //END D-2429 03/22/2015 Added by K. Tan - Set endDate to Subscription End Date
    Usage__c usage;
    Zuora__SubscriptionProductCharge__c spc;
    
    //START D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
    Map<Id, usageQtyWrapper> subIdToQtyWrapperMap = new Map<Id, usageQtyWrapper>();
    Map<Id, Zuora__Subscription__c> subIdToSubMap = new Map<Id, Zuora__Subscription__c>();
    usageQtyWrapper qtyWrapper;
    Zuora__Subscription__c lsub;
    //END D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
    //Start: D-2815 05/27/2015 James    
    public static List<Zuora__Subscription__c> zuoSubDel = new List<Zuora__Subscription__c>();
    public static List<Zuora__SubscriptionProductCharge__c> zuoProdChargeDel = new List<Zuora__SubscriptionProductCharge__c>();
    public static Integer DelSubQty;
    public static Integer numberOfDays;
    public static Date lastDayOfMonth;
    //End: D-2815 05/27/2015 James
    /* @description Executes the business logic and creates Usage record
     * 
     * @param - Set of Subscription Id; Map of Subscription Id to Stop Date 
     * @return void
     */     
        
    public void createUsage (Map<String, Date> subIdToStopDateMap) {
        UsageHelper.initialize();
        // START : D-2429 / K. Tan / Set to Stop Date minus one as per the clarification provided   
        subscriptionToStopDateMap = subIdToStopDateMap;
        // END: D-2429 / K. Tan / Set to Stop Date minus one as per the clarification provided   
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        Set<Id> packageIdSet = new Set<Id>();
        List<Package_Item__c> packageItemList = new List<Package_Item__c>();
        Set<Id> packageMagSet = new Set<Id>();
        Set<Id> packageNewspaperSet = new Set<Id>();
    //START UD-1676 6/23/2015 Added By C. Lin - Kevin
        List<Exception> exceptionList = new List<Exception>();
        
        //START UD-2549 3/18/2016 Added by J.Sarion
        List<Order_Line_Item__c> ccFailureOliList = new List<Order_Line_Item__c>();
        Set<String> ccFailureOliSet = new Set<String>();
        //END UD-2549 3/18/2016 Added by J.Sarion
        
        
        //END UD-1676 6/23/2015 Added By C. Lin
        //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only      
        //START D-2429 03/24/2015 Added by K. Tan - Incorrect Quantity
        //Start: D-2815 05/27/2015 James -- added Order_Line_Item_Number_1__c and Subscription_Type_1__c
        //START UD-1676 Wenjun 22/06/15 : Add Term_Length__c Field
        // Start D-3185 hotfix 27Jun15 JohnD - added filter criteria on recurring postaid
        //START D-4273 1/18/2016 Added by J.Sarion - Added Susbcription Subscription Type
        subList = [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Grace_End_Date__c, 
                    Zuora__Status__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Number_of_Copies__c, 
                    Billing_Type__c, Grace_Period_Subscription__c, Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Order_Line_Item_Number_1__r.Ph_e__c, 
                    Order_Line_Item_Number_1__r.Ph_d__c, Zuora__TermSettingType__c, Main_Package_1__c, Frequency_1__c, Term_Length__c,
                    Order_Line_Item_Number_1__c, Subscription_Type_1__c, Order_Line_Item_Number_1__r.Earliest_Start_Date__c, 
                    (SELECT Zuora__Quantity__c, Zuora__RatePlanName__c, Name, Id, Zuora__ProductSKU__c, Zuora__ChargeNumber__c, 
                    Zuora__UOM__c, Zuora__Type__c, Zuora__Subscription__c, PublicationCode__c, Zuora__Subscription__r.Subscription_Type_1__c FROM Zuora__Subscription_Product_Charges__r 
                    WHERE Zuora__Type__c = 'Usage') FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :subIdToStopDateMap.keySet()                     
                    and Billing_Type__c != :GlobalVariableClass.RECURRING_POSTPAID];
        //END D-4273 1/18/2016 Added by J.Sarion - Added Susbcription Subscription Type
        // End  D-3185 hotfix 27Jun15 JohnD - added filter criteria on recurring postaid
        //END UD-1676 Wenjun 22/06/15
        //End: D-2815 05/27/2015 James
        //END D-2429 03/24/2015 Added by K. Tan - Incorrect Quantity        
        //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only        
        
        //START UD-2549 3/18/2016 Added by J.Sarion - check full prepaid for cc failure
        ccFailureOliList = [SELECT Id, Subscription__r.Order_Line_Item_Number_1__c FROM Order_Line_Item__c WHERE (Terminating_Reason__c = 'Payment failure - Credit card' OR Terminating_Reason__c = 'Payment failure - PayPal') AND Subscription__r.Zuora__Zuora_Id__c IN :subIdToStopDateMap.keySet() AND Case__r.Status != 'Void'];
        
        for(Order_Line_Item__c oli :ccFailureOliList) {
            ccFailureOliSet.add(oli.Subscription__r.Order_Line_Item_Number_1__c);
        }
        //END UD-2549 3/18/2016 Added by J.Sarion - check full prepaid for cc failure
        
        //Start: D-2815 05/27/2015 James -- get Delivery Subscription
        Map<id,Zuora__SubscriptionProductCharge__c> zuoSubDelMap = new Map<id,Zuora__SubscriptionProductCharge__c>();
        if(subList.size() > 0){
            List<String> orderlineitem = new List<String>();
            for(Zuora__Subscription__c sub2 : subList){
                //START UD-2549 3/18/2016 Added by J.Sarion - check if failed cc
                if(ccFailureOliSet.contains(sub2.Order_Line_Item_Number_1__c))
                    continue;
                //END UD-2549 3/18/2016 Added by J.Sarion - check if failed cc
                
                orderlineitem.add(sub2.Order_Line_Item_Number_1__c);
            }
            //START:D-3102 6/17/15 Added by Manolo Valena - Added missing fields for new logic.
            //START UD-1676 Wenjun 22/06/15 : Add Term_Length__c Field
            // Start  D-3185 hotfix 27Jun15 JohnD - added filter criteria on recurring postaid
            zuoSubDel = [SELECT Id, Name, Subscription_Type_1__c, Zuora__CustomerAccount__c, Recipient_Contact__r.Address__r.Name, Zuora__Zuora_ID__c, Term_Length__c, 
                        Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Billing_Type__c, Zuora__SubscriptionEndDate__c, Zuora__SubscriptionStartDate__c, 
                        Zuora__TermSettingType__c FROM Zuora__Subscription__c WHERE (Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY 
                        OR Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE) AND Order_Line_Item_Number_1__c IN :orderlineitem 
                        and Billing_Type__c != :GlobalVariableClass.RECURRING_POSTPAID];
            // End  D-3185 hotfix 27Jun15 JohnD - added filter criteria on recurring postaid
            //END UD-1676 Wenjun 22/06/15
            //END:D-3102 6/17/15 Added by Manolo Valena
      
            //START UD-1676 Wenjun 22/06/15 : Reset Sub End Date
            resetEndDate(subList);
            resetEndDate(zuoSubDel);
            //END UD-1676 Wenjun 22/06/15
        }
        if(zuoSubDel.size() > 0){
            //START D-4273 1//18/2016 Added by J.Sarion - Added Subscription Subscription Type
            zuoProdChargeDel = [SELECT Id, Zuora__Price__c, Zuora__UOM__c, Zuora__Subscription__c, Zuora__Subscription__r.Subscription_Type_1__c, Zuora__ChargeNumber__c, PublicationCode__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN :zuoSubDel AND Zuora__UOM__c LIKE 'CREDIT%']; 
            //END D-4273 1//18/2016 Added by J.Sarion - Added Subscription Subscription Type
            
            for(Zuora__SubscriptionProductCharge__c subDeliveryCharge : zuoProdChargeDel){
                zuoSubDelMap.put(subDeliveryCharge.Zuora__Subscription__c, subDeliveryCharge );
                spcIdentifierToSpcMap.put(subDeliveryCharge.Zuora__Subscription__c + ' ' + subDeliveryCharge.Zuora__UOM__c, subDeliveryCharge);
            }
        }
        if(zuoSubDel.size() > 0){
            for(Zuora__Subscription__c SubDel: zuoSubDel) {
                Date StopDateDelPost = subIdToStopDateMap.get(SubDel.Zuora__Zuora_Id__c);
                
                
                if(SubDel.Billing_Type__c == 'Full Prepaid'){
                    if(StopDateDelPost != null && SubDel.Zuora__SubscriptionEndDate__c != null){
                        if(StopDateDelPost == StopDateDelPost.toStartOfMonth()){
                            DelSubQty = StopDateDelPost.monthsBetween(Subdel.Zuora__SubscriptionEndDate__c) + 1;
                        }else{
                            DelSubQty = StopDateDelPost.monthsBetween(Subdel.Zuora__SubscriptionEndDate__c);
                        }
                    }else{
                        DelSubQty = 1;
                    }
                }else{
                    if(StopDateDelPost != null && StopDateDelPost == StopDateDelPost.toStartOfMonth()){
                        DelSubQty = 1;
                    }else{
                        DelSubQty = 0;
                    }
                }
                
                // Start UD-1622 13Jun15 JohnD
                //START UD-1595 6/22/15 AddedBy FrancisBenzon/JeffreyTeves : for the batch process.
                try {
                //Start D-4121 12-17-2015 added by Jason A.
                    if(zuoSubDelMap.containskey(SubDel.id)){
                        if(zuoSubDelMap != null && SubDel != null && zuoSubDelMap.get(SubDel.id).Zuora__UOM__c != null && DelSubQty != null)
                        {
                            createUsagePrep(SubDel, DelSubQty, zuoSubDelMap.get(SubDel.id).Zuora__UOM__c);
                        }
                    }
                //End D-4121 12-17-2015 added by Jason A.
                } catch (Exception e){
                    exceptionList.add(E);
                }
                //END UD-1595 6/22/15 AddedBy FrancisBenzon/JeffreyTeves : for the batch process.
                // End UD-1622 13Jun15 JohnD
                
            }
        }
        //End: D-2815 05/27/2015 James
        for(Zuora__Subscription__c zSub :subList) {
            for (Zuora__SubscriptionProductCharge__c spc :zSub.Zuora__Subscription_Product_Charges__r) {
                if (subIdToPubCodeSetMap.containsKey(spc.Zuora__Subscription__c)) {
                    if (spc.PublicationCode__c != null)
                        subIdToPubCodeSetMap.get(spc.Zuora__Subscription__c).add(spc.PublicationCode__c);
                }
                else {
                    if (spc.PublicationCode__c != null)
                        subIdToPubCodeSetMap.put(spc.Zuora__Subscription__c, new Set<String> {spc.PublicationCode__c});
                }
                spcIdentifierToSpcMap.put(spc.Zuora__Subscription__c + ' ' + spc.Zuora__UOM__c, spc);
            }   
            //START D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
            subIdToSubMap.put(zSub.Id, zSub);
            //END D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
            subIdToUomTypeMap.put(zSub.Id, CREDIT_USAGE);
            packageIdSet.add(zSub.Main_Package_1__c);
        }
        
        if (!packageIdSet.isEmpty()) {
            packageItemList = [SELECT Id, Name, Package__c, Is_Magazine__c, Is_Newspaper__c FROM Package_Item__c WHERE Package__c IN :packageIdSet];
        }
        
        for (Package_Item__c packItem :packageItemList) {
            if (!packageMagSet.contains(packItem.Package__c) && packItem.Is_Magazine__c)
                packageMagSet.add(packItem.Package__c);
            if (!packageNewspaperSet.contains(packItem.Package__c) && packItem.Is_Newspaper__c)
                packageNewspaperSet.add(packItem.Package__c);
        }
        
        for (Zuora__Subscription__c sub : subList) {
            //START UD-2549 3/18/2016 Added by J.Sarion - check if failed cc
            if(ccFailureOliSet.contains(sub.Order_Line_Item_Number_1__c))
                continue;
            //END UD-2549 3/18/2016 Added by J.Sarion - check if failed cc
            
            //START UD-2681 09/09/2015 Added by J.Sarion - Cater No of Copies for usage quantity
            Integer copies = (Integer.valueOf(sub.Number_of_Copies__c) != null ? Integer.valueOf(sub.Number_of_Copies__c) : 0);
            //END UD-2681 09/09/2015 Added by J.Sarion - Cater No of Copies for usage quantity
            if (subIdToStopDateMap.containsKey(sub.Zuora__Zuora_Id__c)) {
                //START D-3179 07/04/2015 Added by J.Sarion - Commented out logic for creation of usages for Postpaid
                /*
                //START UD-1676 6/23/2015 Added By C. Lin - Usage for Recurring Post Paid
                if(sub.Billing_Type__c == 'Recurring Postpaid')
                {
                    if (packageNewspaperSet.contains(sub.Main_Package_1__c)){
                        subIdToUomTypeMap.put(sub.Id, ISSUE_USAGE);
                    }
                    if (packageMagSet.contains(sub.Main_Package_1__c)){
                        subIdToUomTypeMap.put(sub.Id, COPY_USAGE);
                    }
                }
                //END UD-1676 6/23/2015 Added By C. Lin
                */
                //END D-3179 07/04/2015 Added by J.Sarion - Commented out logic for creation of usages for Postpaid
                //Start D-2815 James
                Date StopDate = subIdToStopDateMap.get(sub.Zuora__Zuora_Id__c);
                
                //START UD-2657/D-3414/D-3711 Wenjun 19 Oct 15: No Credit if Stop before Start
                if(StopDate <= sub.Zuora__SubscriptionStartDate__c || 
                        (sub.Zuora__SubscriptionStartDate__c.monthsBetween(stopDate) == 0 
                        && sub.Zuora__SubscriptionStartDate__c != sub.Zuora__SubscriptionStartDate__c.toStartOfMonth() 
                        && sub.Billing_Type__c == 'Recurring Prepaid')) continue;   // Start/End D-3741 23Oct15 JohnD - added sub.Zuora__SubscriptionStartDate__c.monthsBetween(stopDate) == 0
                //END UD-2657/D-3414/D-3711 Wenjun 19 Oct 15
                
                Date StopDateEndMth = getLastDayOfTheMonth(StopDate);
                subEndDate = sub.Zuora__SubscriptionEndDate__c;
                //year = StopDate.year();
                //month = StopDate.month();
                //End D-2815 James
                
                //START D-2429 03/24/2015 Added by K. Tan - Incorrect Quantity
                //START UD-0912 04/24/2015 Added by J. Sarion - Usage for EVERGREEN
                //START D-3179 07/04/2015 Added by J.Sarion - Commented out logic for creation of usages for Postpaid
                if (sub.Billing_Type__c == 'Recurring Prepaid') {
                //END D-3179 07/04/2015 Added by J.Sarion - Commented out logic for creation of usages for Postpaid
                    //Start D-2815 James 05/27/2015
                    /*if (sub.Zuora__TermSettingType__c != 'EVERGREEN') {
                        if (StopDate != StopDateEndMth) {
                            if (StopDate.month() == subEndDate.month() && StopDate.year() == subEndDate.year()) {
                                startDate = StopDate; //.addDays(1); //Start/End: D-2815 James 05/27/2015
                                endDate = subEndDate;
                                createUsageFirst(sub, startDate, endDate);
                            }
                            else {
                                startDate = StopDate; //.addDays(1); //Start/End: D-2815 James 05/27/2015
                                endDate = StopDateEndMth;
                                createUsageFirst(sub, startDate, endDate);
                            }
                        }
                    }
                    else {
                        startDate = StopDate; //.addDays(1); //Start/End: D-2815 James 05/27/2015
                        if (startDate != StopDateEndMth) {
                            endDate = StopDateEndMth;
                            createUsageFirst(sub, startDate, endDate);
                        }
                    }*/
                    if(StopDate != StopDate.toStartOfMonth()){
                        //START UD-1676 6/23/2015 Added By C. Lin - Usage for Recurring Post Paid
                        if(sub.Billing_Type__c == 'Recurring Prepaid'){
                            startDate = StopDate;
                            endDate = getLastDayOfTheMonth(StopDate);
                        }
                        //START D-3179 07/04/2015 Added by J.Sarion - Commented out logic for creation of usages for Postpaid
                        /*
                        else if(sub.Billing_Type__c == 'Recurring Postpaid'){
                            startDate = StopDate.toStartOfMonth();
                            endDate = StopDate.addDays(-1);
                        }
                        //END UD-1676 6/23/2015 Added By C. Lin
                        */
                        //END D-3179 07/04/2015 Added by J.Sarion - Commented out logic for creation of usages for Postpaid
                        createUsageFirst(sub, startDate, endDate);
                        //START UD-2681 09/09/2015 Added by J.Sarion - Cater No of Copies for usage quantity
                    }else{
                        if (subIdToPubCodeSetMap.containsKey(sub.Id)) {
                            for (String pubCode :subIdToPubCodeSetMap.get(sub.Id)) {
                                Usage__c usage = new Usage__c();
                                //START D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                                /*
                                if (packageMagSet.contains(sub.Main_Package_1__c)){
                                    createUsagePrep(sub, copies, 'Issue ' + pubCode);
                                }
                                */
                                startDate = StopDate;
                                endDate = getLastDayOfTheMonth(StopDate);
                                createUsageFirst(sub, startDate, endDate);
                                //END D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                                
                                if (packageNewspaperSet.contains(sub.Main_Package_1__c)){
                                    createUsagePrep(sub, copies, 'Month ' + pubCode);
                                }
                            }
                        }
                    }
                    //End D-2815 James 05/27/2015
                }
                //END D-2429 03/24/2015 Added by K. Tan - Incorrect Quantity
                
                if (sub.Billing_Type__c == 'Full Prepaid') {
                    //Start: D-2815 James 05/27/2015
                    //StopDate.addDays(Date.daysInMonth(StopDate.year(), StopDate.month()) - 1);                    
                    earliestStopDate = sub.Order_Line_Item_Number_1__r.Earliest_Start_Date__c;
                    subEndDateEndMth = getLastDayOfTheMonth(subEndDate);
                    
                    //START D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                    if(packageMagSet.contains(sub.Main_Package_1__c)) {
                        startDate = StopDate;
                        endDate = subEndDate;
                        createUsageFirst(sub, startDate, endDate);
                    }
                    else if (StopDate.monthsBetween(subEndDate) != 0){ //Months between Stop Request Date and Subscription End Date is greater than 0
                    //END D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                        if(StopDate == StopDateEndMth || (StopDate != StopDate.toStartOfMonth() && subEndDate != StopDateEndMth)){
                            if(!packageMagSet.contains(sub.Main_Package_1__c)){
                                if (StopDate != StopDateEndMth) {
                                    startDate = StopDate;
                                    endDate = StopDateEndMth;
                                    createUsageFirst(sub, startDate, endDate);
                                }
                                
                                if (subEndDate != subEndDateEndMth) {
                                    startDate = date.newInstance(subEndDate.year(), subEndDate.month(), 1);
                                    endDate = subEndDate;
                                    createUsageFirst(sub, startDate, endDate);
                                }
                                if(StopDate == StopDateEndMth && StopDate != subEndDate){
                                    startDate = StopDate;
                                    endDate = StopDateEndMth;
                                    createUsageFirst(sub, startDate, endDate);
                                }
                            }
                        }
                        else if(subEndDate == subEndDate.toStartOfMonth() || (subEndDate != subEndDate.toStartOfMonth() && subEndDate != subEndDateEndMth)){
                            startDate = subEndDate.toStartOfMonth();
                            endDate = subEndDate;
                            createUsageFirst(sub, startDate, endDate);
                        }
                        if (StopDate.monthsBetween(subEndDate) == 1 && StopDate == StopDateEndMth && subEndDate == subEndDateEndMth) {
                            if (subIdToPubCodeSetMap.containsKey(sub.Id)) {
                                for (String pubCode :subIdToPubCodeSetMap.get(sub.Id)) {
                                    Usage__c usage = new Usage__c();
                                    //START D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                                    /*
                                    if (packageMagSet.contains(sub.Main_Package_1__c)){
                                        if(StopDate.day() >= earliestStopDate.day() && subEndDate.day() < earliestStopDate.day()){
                                            createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)-1), 'Issue ' + pubCode);
                                        }else if(StopDate.day() < earliestStopDate.day() && subEndDate.day() >= earliestStopDate.day()){
                                            createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)+1), 'Issue ' + pubCode);
                                        }else{
                                            createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)), 'Issue ' + pubCode);
                                        }
                                    }
                                    */
                                    //END D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                                    
                                    if (packageNewspaperSet.contains(sub.Main_Package_1__c)){
                                        if(StopDate != StopDate.toStartOfMonth() && subEndDate != subEndDateEndMth){
                                            createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)-1), 'Month ' + pubCode);
                                        }else{
                                            if(StopDate == StopDate.toStartOfMonth() && subEndDate == subEndDateEndMth){
                                                createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)+1), 'Month ' + pubCode);
                                            }else{
                                                createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)), 'Month ' + pubCode);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            if (subIdToPubCodeSetMap.containsKey(sub.Id)) {
                                if (subEndDate == subEndDateEndMth) {
                                    for (String pubCode :subIdToPubCodeSetMap.get(sub.Id)) {
                                        Usage__c usage = new Usage__c();
                                        //START D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                                        /*
                                        if (packageMagSet.contains(sub.Main_Package_1__c)){
                                            system.debug('j>>>>');
                                            if(StopDate.day() >= earliestStopDate.day() && subEndDate.day() < earliestStopDate.day()){
                                                createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)-1), 'Issue ' + pubCode);
                                            }else if(StopDate.day() < earliestStopDate.day() && subEndDate.day() >= earliestStopDate.day()){
                                                createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)+1), 'Issue ' + pubCode);
                                            }else{
                                                createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)), 'Issue ' + pubCode);
                                            }
                                        }
                                        */
                                        //END D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                                        
                                        if (packageNewspaperSet.contains(sub.Main_Package_1__c)){
                                            if(StopDate != StopDate.toStartOfMonth() && subEndDate != subEndDateEndMth){
                                                createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)-1), 'Month ' + pubCode);
                                            }else{
                                                if(StopDate == StopDate.toStartOfMonth() && subEndDate == subEndDateEndMth){
                                                    createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)+1), 'Month ' + pubCode);
                                                }else{
                                                    createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)), 'Month ' + pubCode);
                                                }
                                            }
                                        }
                                    }
                                }
                                else {
                                    for (String pubCode :subIdToPubCodeSetMap.get(sub.Id)) {
                                        Usage__c usage = new Usage__c();
                                        //START D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                                        /*
                                        if (packageMagSet.contains(sub.Main_Package_1__c)){
                                            if(StopDate.day() >= earliestStopDate.day() && subEndDate.day() < earliestStopDate.day()){
                                                createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)-1), 'Issue ' + pubCode);
                                            }else if(StopDate.day() < earliestStopDate.day() && subEndDate.day() >= earliestStopDate.day()){
                                                createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)+1), 'Issue ' + pubCode);
                                            }else{
                                                createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)), 'Issue ' + pubCode);
                                            }
                                        }
                                        */
                                        //END D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                                    
                                        if (packageNewspaperSet.contains(sub.Main_Package_1__c)){
                                            if(StopDate != StopDate.toStartOfMonth() && subEndDate != subEndDateEndMth){
                                                createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)-1), 'Month ' + pubCode);
                                            }else{
                                                if(StopDate == StopDate.toStartOfMonth() && subEndDate == subEndDateEndMth){
                                                    createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)+1), 'Month ' + pubCode);
                                                }else{
                                                    createUsagePrep(sub, copies*(StopDate.monthsBetween(subEndDate)), 'Month ' + pubCode);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else if(StopDate == StopDate.toStartOfMonth() && subEndDate == StopDateEndMth){
                        if (subIdToPubCodeSetMap.containsKey(sub.Id)) {
                            for (String pubCode :subIdToPubCodeSetMap.get(sub.Id)) {
                                Usage__c usage = new Usage__c();
                                //START D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                                /*
                                if (packageMagSet.contains(sub.Main_Package_1__c)){
                                    if(StopDate.day() < earliestStopDate.day() && subEndDate.day() >= earliestStopDate.day()){
                                        createUsagePrep(sub, copies, 'Issue ' + pubCode);
                                    }else{
                                        createUsagePrep(sub, 0, 'Issue ' + pubCode);
                                    }
                                }
                                */
                                //END D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                            
                                if (packageNewspaperSet.contains(sub.Main_Package_1__c)){
                                    createUsagePrep(sub, copies, 'Month ' + pubCode);
                                }
                            }
                        }               
                    }
                    else {
                        if (StopDate != subEndDateEndMth) {
                            if(!packageMagSet.contains(sub.Main_Package_1__c)){
                                startDate = StopDate; //.addDays(1); //Start/End: D-2815 James 05/27/2015
                                //START D-2429 03/22/2015 Added by K. Tan - Set endDate to Subscription End Date
                                //endDate = subEndDateEndMth;
                                //START UD-2341 08/17/2015 Added by J.Sarion - Set end date to subEndDate as this scenario is for stop date month equal to subscription end date month. Usage will only be from stop date to Subscription End Date
                                createUsageFirst(sub, startDate, subEndDate); //Kevin Evasco Hotfix 6/13/15: Change end date from subEndDate to subEndDateEndMth. The quantity will always be equal to 0 if the stop date and sub end date is always equal.
                                //END UD-2341 08/17/2015 Added by J.Sarion - Set end date to subEndDate as this scenario is for stop date month equal to subscription end date month. Usage will only be from stop date to Subscription End Date
                                //END D-2429 03/22/2015 Added by K. Tan - Set endDate to Subscription End Date
                            }
                            //START D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                            /*
                            else if(packageMagSet.contains(sub.Main_Package_1__c)){
                                for (String pubCode :subIdToPubCodeSetMap.get(sub.Id)) {
                                    Usage__c usage = new Usage__c();
                                    if(StopDate.day() < earliestStopDate.day() && subEndDate.day() >= earliestStopDate.day()){
                                        createUsagePrep(sub, copies, 'Issue ' + pubCode);
                                    }else{
                                        createUsagePrep(sub, 0, 'Issue ' + pubCode);
                                    }
                                }
                            }
                            */
                            //END D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                            
                        }//END UD-2681 09/09/2015 Added by J.Sarion - Cater No of Copies for usage quantity
                        else if(StopDate == getLastDayOfTheMonth(StopDate) && StopDate == subEndDate){
                            startDate = StopDate;
                            endDate = subEndDate;
                            createUsageFirst(sub, startDate, endDate);
                        }
                        else{
                            startDate = StopDate;
                            endDate = subEndDate;
                            createUsageFirst(sub, startDate, endDate);
                        }
                    }
                }
            }
        }
        //End: D-2815 James 05/27/2015
        //START D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
        for (Id subId :subIdToQtyWrapperMap.keySet()) {
            lsub = new Zuora__Subscription__c();
            qtyWrapper = subIdToQtyWrapperMap.get(subId);
            
            if (subIdToSubMap.containsKey(subId))
                lsub = subIdToSubMap.get(subId);
            
            if (lsub != null) {
                //if (pubIssueWrapperObject.weekday_no_of_copies != 0)
                    createUsagePrep(lsub, qtyWrapper.weekday, 'Weekday');
                //if (pubIssueWrapperObject.sat_no_of_copies != 0)
                    createUsagePrep(lsub, qtyWrapper.sat, 'Sat');
                //if (pubIssueWrapperObject.sun_no_of_copies != 0)
                    createUsagePrep(lsub, qtyWrapper.sun, 'Sun');
                //if (pubIssueWrapperObject.odd_freq_copies != 0) {
                    createUsagePrep(lsub, qtyWrapper.oddFreq, 'Online');
                    createUsagePrep(lsub, qtyWrapper.oddFreq, 'Smartphone');
                    createUsagePrep(lsub, qtyWrapper.oddFreq, 'Tablet');
                    createUsagePrep(lsub, qtyWrapper.oddFreq, 'AIO Online');
                    createUsagePrep(lsub, qtyWrapper.oddFreq, 'AIO Smartphone');
                    createUsagePrep(lsub, qtyWrapper.oddFreq, 'AIO Tablet');
                    //START D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies
                    for (String pubCode :subIdToPubCodeSetMap.get(lsub.Id)) {
                        createUsagePrep(lsub, qtyWrapper.oddFreq, 'Issue ' + pubCode);
                    }
                    //END D-3974 11/24/2015 Added by J.Sarion - Check Frequency Code for the computation of credit copies                   
            }
        }
        //END D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
        //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
        UsageHelper.loadUniqueUsages(usageList,false);
        /* REMOVED FOR D-2610
        //START D-2429 03/22/2015 Added by K. Tan - Set endDate to Subscription End Date
        if (!identifierToUsageMap.isEmpty()) {
            ZuoraCallOut zCall = new ZuoraCallOut();
            List<Map<String, String>> resultMapList = zCall.loadZObjects(identifierToUsageMap.values(), 'Usage');
            
            for (Map<String, String> result :resultMapList) {
                if (result.get('Status') == 'Success')
                    system.debug('>>>>>Success');
                else {
                    system.debug('>>>>>Fail ' + result.get('Code'));
                    system.debug('>>>>>Fail ' + result.get('Message'));
                }
            }
        }
        REMOVED FOR D-2610 */       
        //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only       
        //END D-2429 03/22/2015 Added by K. Tan - Set endDate to Subscription End Date
        //START UD-1676 6/23/2015 Added By C. Lin - Kevin
        ExceptionLogger.log(exceptionList);
        //END UD-1676 6/23/2015 Added By C. Lin
    }

    /* @description Executes the business logic and creates Usage record
     * 
     * @param - Subscription; Start Date; End Date to be passed to the calculation of published days
     * @return void
     */         
    
    public void createUsageFirst (Zuora__Subscription__c sub, Date startDate, Date endDate) {
        PublicationIssueWrapper pubIssueWrapperObject;
        //START D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
        Boolean onlineFirstRun = false;
        //END D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
        system.debug('>>>>>subIdToPubCodeSetMap' + subIdToPubCodeSetMap);
        if (subIdToPubCodeSetMap.containsKey(sub.Id)) {
            for (String pubCode :subIdToPubCodeSetMap.get(sub.Id)) {
                pubIssueWrapperObject = UsageHelper.IssueCalculation(pubCode, startDate, endDate, sub, Integer.valueOf(sub.Number_of_Copies__c));
                //START D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
                if (subIdToQtyWrapperMap.containsKey(sub.Id)) {
                    qtyWrapper = subIdToQtyWrapperMap.get(sub.Id);
                    
                    qtyWrapper.weekday = qtyWrapper.weekday + pubIssueWrapperObject.weekday_no_of_copies;
                    qtyWrapper.sat = qtyWrapper.sat + pubIssueWrapperObject.sat_no_of_copies;
                    qtyWrapper.sun = qtyWrapper.sun + pubIssueWrapperObject.sun_no_of_copies;
                    //Start D-3173 06/27/2015  Von/James
                    //if (qtyWrapper.oddFreq == 0 || onlineFirstRun == false) { 
                    if (pubIssueWrapperObject.odd_freq_copies != 0 && (qtyWrapper.oddFreq == 0 || onlineFirstRun == false)) {
                    //End D-3173 06/27/2015 Von/James
                        qtyWrapper.oddFreq = qtyWrapper.oddFreq + pubIssueWrapperObject.odd_freq_copies;
                        onlineFirstRun = true;
                    }
                    subIdToQtyWrapperMap.put(sub.Id, qtyWrapper);
                }
                else {
                    qtyWrapper = new usageQtyWrapper();
                    
                    qtyWrapper.weekday = pubIssueWrapperObject.weekday_no_of_copies;
                    qtyWrapper.sat = pubIssueWrapperObject.sat_no_of_copies;
                    qtyWrapper.sun = pubIssueWrapperObject.sun_no_of_copies;
                    qtyWrapper.oddFreq = pubIssueWrapperObject.odd_freq_copies;
                    
                    subIdToQtyWrapperMap.put(sub.Id, qtyWrapper);
                    
                    if (qtyWrapper.oddFreq != 0)
                        onlineFirstRun = true;
                }
                //END D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
                //START D-2597 03/22/2015 Commented by J.Sarion - Added QtyWrapper for usage quantity consolidation
                /*
                system.debug('>>>>>pubIssueWrapperObject ' + pubIssueWrapperObject);
                //if (pubIssueWrapperObject.weekday_no_of_copies != 0)
                    createUsagePrep(sub, pubIssueWrapperObject.weekday_no_of_copies, 'Weekday');
                //if (pubIssueWrapperObject.sat_no_of_copies != 0)
                    createUsagePrep(sub, pubIssueWrapperObject.sat_no_of_copies, 'Sat');
                //if (pubIssueWrapperObject.sun_no_of_copies != 0)
                    createUsagePrep(sub, pubIssueWrapperObject.sun_no_of_copies, 'Sun');
                //if (pubIssueWrapperObject.odd_freq_copies != 0) {
                    createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Online');
                    createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Smartphone');
                    createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'Tablet');
                    createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Online');
                    createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Smartphone');
                    createUsagePrep(sub, pubIssueWrapperObject.odd_freq_copies, 'AIO Tablet');
                */
                //END D-2597 03/22/2015 Commented by J.Sarion - Added QtyWrapper for usage quantity consolidation
            }
        }
    }

    /* @description Executes the business logic and creates Usage record
     * 
     * @param - Subscription; Quantity; UOM to be used for usage
     * @return void
     */     
    
    //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only. Reconstructed method.
    public void createUsagePrep (Zuora__Subscription__c sub, Integer quantity, String uom) {   
        
        Usage__c usageRecord = createUsageRecord(sub, quantity, uom);

        if (usageRecord != null) {
            if (usageRecord.Quantity__c > 0) {
                usageList.add(usageRecord);
            }
        }       
    }
    //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only. Reconstructed method.
    
    /* @description Executes the business logic and creates Usage record
     * 
     * @param - Subscription; Quantity; UOM; Create Usage record
     * @return Usage__c
     */      
    //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only. Reconstructed method.
    public Usage__c createUsageRecord (Zuora__Subscription__c sub, Integer quantity, String uom) {
        //Start: D-2815 05/27/2015 James
        
        //START: D-4029 K. Tan 12/10/2015
        Date startDate;
        Date origStopDate;
        //END: D-4029 K. Tan 12/10/2015
        if(sub.Subscription_Type_1__c == 'Delivery' || sub.Subscription_Type_1__c == 'Postage'){
            spcIdentifier = generateSpcIndentifierKey(sub.Id, uom);
        }else{
            spcIdentifier = generateSpcIndentifierKey(sub.Id, subIdToUomTypeMap.get(sub.Id) + ' ' + uom);
        }
        //End: D-2815 05/27/2015 James
        //START: D-4029 K. Tan 12/10/2015
        if(subscriptionToStopDateMap.containsKey(sub.Zuora__Zuora_Id__c)){
            startDate = subscriptionToStopDateMap.get(sub.Zuora__Zuora_Id__c).addDays(-1);
        //START:D-3102 6/17/15 Added by Manolo Valena - Added new variable.
            origStopDate = subscriptionToStopDateMap.get(sub.Zuora__Zuora_Id__c);
        }
        //END: D-4029 K. Tan 12/10/2015
        //END:D-3102 6/17/15 Added by Manolo Valena
        
        //START:D-3102 6/17/15 Added by Manolo Valena - Change startDate value for the usages if stop request date is earlier than the start date of the subscription. This will allow Zuora to process the credit balance.
        //START UD-2657/D-3414/D-3711 Wenjun 19 Oct 15 : fix the checking condition
        if(origStopDate <= sub.Zuora__SubscriptionStartDate__c && sub.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID) {
            startDate = sub.Zuora__SubscriptionStartDate__c;
        }
        //END UD-2657/D-3414/D-3711 Wenjun 19 Oct 15
        //END:D-3102 6/17/15 Added by Manolo Valena
         
        Usage__c usageRecord;
        //START: D-4257 1/15/16 Added by Manolo Valena
        if (spcIdentifierToSpcMap.containsKey(spcIdentifier) && startDate != null) {
        //END: D-4257 1/15/16 Added by Manolo Valena
            //START D-3290/D-3291 7/29/2015 Added by Manolo Valena - Added if-else condition.
            //START UD-2528 8/27/2015 Added by Manolo Valena - Put additional condition for recurring prepaid with stop date of 1st day of month.
            if((origStopDate <= sub.Zuora__SubscriptionStartDate__c && sub.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID) ||
               (origStopDate == origStopDate.toStartOfMonth() &&
                //Start UD-2685 VPernicia 09/15/15
                //origStopDate.month() > sub.Zuora__SubscriptionStartDate__c.month() &&
                //origStopDate.year() >= sub.Zuora__SubscriptionStartDate__c.year() &&
                origStopDate >= sub.Zuora__SubscriptionStartDate__c &&
                //End UD-2685 VPernicia 09/15/15
                sub.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID)) {
                usageRecord = new Usage__c();           
            }
            //END UD-2528 8/27/2015 Added by Manolo Valena
            else {
                usageRecord = new Usage__c();           
                spc = spcIdentifierToSpcMap.get(spcIdentifier);
                
                usageRecord.UOM__c = spc.Zuora__UOM__c;
                usageRecord.Account_Id__c = sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
                usageRecord.Subscription_Id__c = sub.Name;
                usageRecord.Start_Date__c = startDate;
                usageRecord.Quantity__c = quantity;
                usageRecord.Status__c = UsageHelper.USAGE_STATUS;   
                usageRecord.Rate_Plan_Charge_Id__c = spc.Zuora__ChargeNumber__c;
                //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier            
                //START D-4273 1/18/2016 Added by J.Sarion - Check if Subscription Type is Publication
                if(spc.Zuora__Subscription__r.Subscription_Type_1__c == 'Publication') {
                    usageRecord.Publication_Code__c = spc.PublicationCode__c;
                }
                //END D-4273 1/18/2016 Added by J.Sarion - Check if Subscription Type is Publication
                usageRecord.StopType__c = 'Pstop';  // Start/End D-2826 08May15 Von/JohnD
                //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier            
                if(sub.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID){
                    usageRecord.Usage_Type__c = UsageHelper.USAGE_TYPE_FULL_PREPAID_STOP;
                } else if (sub.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID) {
                    usageRecord.Usage_Type__c = UsageHelper.USAGE_TYPE_RECURRING_PREPAID_STOP;
                }
            }
            //END D-3290/D-3291 7/29/2015 Added by Manolo Valena
        }
        return usageRecord;
    }
    //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only. Reconstructed method.

    /* @description Executes the business logic and creates Usage record
     * 
     * @param - Subscription Id; UOM; Identifier for the corresponding Subscription Product and Charge
     * @return String
     */     
    
    public static string generateSpcIndentifierKey(string subscriptionId, string uom) {
        return subscriptionId + ' ' + uom;
    }
    //START D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
    public class usageQtyWrapper {
        public Integer weekday = 0;
        public Integer sun = 0;
        public Integer sat = 0;
        public Integer oddFreq = 0;
    }
    //END D-2597 03/22/2015 Added by J.Sarion - Added QtyWrapper for usage quantity consolidation
    //Start: D-2815 James 05/27/2015
    public Static Date getLastDayOfTheMonth(Date dateField){   
        numberOfDays = Date.daysInMonth(dateField.year(), dateField.month());
        lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
        
        return lastDayOfMonth;
    }
    //End: D-2815 James 05/27/2015  
    
    //START UD-1676 Wenjun 22/06/15 : Method for Reset Sub End Date back to original End Date
    private void resetEndDate(List<Zuora__Subscription__c> lstSubs)
    {
        for(Zuora__Subscription__c sub : lstSubs)
        {
            if(sub.Zuora__TermSettingType__c == GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED)
            {
                sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(sub.Term_Length__c)).addDays(-1);
            }
            else
                sub.Zuora__SubscriptionEndDate__c = null; //For Evergreen
            
        }
    }
    //END UD-1676 Wenjun 22/06/15
}