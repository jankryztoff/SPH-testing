/**
 * Class Name: BatchPostageMonthlyUsage
 * @author: Joban Bir Singh
 * Date: 12/1/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch class that passes usage information for monthly postage charge
 *
 * @History: 01/15/2015 Krithika D: Change in finish method Control-M 
 */
global class BatchPostageMonthlyUsage_Clone implements Database.Batchable<sObject>,Database.AllowsCallouts
{
   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bcTemp - predefined parameter 
    * @return list of objects from Order Object
    */
    //START 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches  
    private final static Date referenceDate = UsageHelper.getUsagereferenceDate();
    private final static String postageUOM = ConstantsSLB.getUOM('PostageCharge');
    //START 04/20/2015 D-2764 & D-2765 Added by J.Sarion - Postage Batch Implementation
    global final static String SUBTYPE_POSTAGE = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
    global final static String STATUS_ACTIVE = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
    global final static String STATUS_CANCELLED = GlobalVariableClass.STATUS_CANCELLED;
    global final static String FULL_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
    global final static String MR_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    global final static String MR_POST = GlobalVariableClass.RECURRING_POSTPAID;
    //END 04/20/2015 D-2764 & D-2765 Added by J.Sarion - Postage Batch Implementation
    //END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches    
    public database.QueryLocator start(database.BatchableContext bcTemp)
    {
        //START 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches              
        Date startDate = referenceDate.toStartOfMonth();
        Date endDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
        //START 04/20/2015 D-2764 & D-2765 Added by J.Sarion - Postage Batch Implementation
        String query = 'SELECT ID FROM Contact WHERE Recipient_Indicator__c = true';
        return database.getQueryLocator(query);
        //END 04/20/2015 D-2764 & D-2765 Added by J.Sarion - Postage Batch Implementation
        //END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches
    }
    /* @description Executes the business logic and creates Address Assignment objects
     * 
     * @param bcTemp - predefined parameter 
     * @param allScopes - a list of sObjects from the initial database query
     * @return void
     */ 
    //START 04/20/2015 D-2764 & D-2765 Added by J.Sarion - Postage Batch Implementation
    public void execute(database.batchableContext bcTemp, list<Contact> allScopes){
    //END 04/20/2015 D-2764 & D-2765 Added by J.Sarion - Postage Batch Implementation
        //REMOVED FOR D-2698 zCallOut = new ZuoraCallOut(); // START 04/07/2015 D-2698 Kevin Evasco - BatchPostageMonthlyUsage fix
       // initialize variables 
       ID ratePlanIDToUse = NULL;
       zqu__ProductRatePlanCharge__c prpc;
       string dFormat;
       Date startDate;
       List<Map<String, Object>> usageMapList = new List<Map<String, Object>>();
       
        //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
        List<Usage__c> usageList = new list<Usage__c>();
       //loop through the records returned in the querylocator
        
        //START 04/20/2015 D-2764 & D-2765 Added by J.Sarion - Postage Batch Implementation
        Set<Id> conIdSet = new Set<Id>();
        List<Zuora__Subscription__c> subPrepaidList = new List<Zuora__Subscription__c>();
        List<Zuora__Subscription__c> subPostpaidList = new List<Zuora__Subscription__c>();
        Date firstDayOfMonth;
        Date lastDayOfMonth;
        Date firstDayOfNextMonth;
        Date lastDayOfNextMonth; 
        
        if(referenceDate != null) {
            firstDayOfMonth = referenceDate.toStartOfMonth();
            lastDayOfMonth = referenceDate.addMonths(1).toStartOfMonth().addDays(-1);
            firstDayOfNextMonth = referenceDate.addMonths(1).toStartOfMonth();
            lastDayOfNextMonth = referenceDate.addMonths(2).toStartOfMonth().addDays(-1);
        } else {
            firstDayOfMonth = System.today().toStartOfMonth();
            lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
            firstDayOfNextMonth = firstDayOfMonth.addMonths(1).toStartOfMonth();
            lastDayOfNextMonth = firstDayOfNextMonth.addDays(Date.daysInMonth(firstDayOfNextMonth.year(), firstDayOfNextMonth.month()) - 1); 
        }
        
        for (Contact con :allScopes) {
            conIdSet.add(con.Id);
        }
        
        if (!conIdSET.isEmpty()) {
            //fetch DC Subs for CURRENT MONTH
            subPostpaidList = [SELECT Id, Name, Zuora__Account__c, Recipient_Address_ID__c, Subscription_Type_1__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, 
                        Billing_Type__c, Zuora__SubscriptionStartDate__c, New_Contract_Period_1__c, Contract_End_Date_1__c,Recipient_Contact__c
                        FROM Zuora__Subscription__c
                        WHERE
                            Recipient_Contact__c IN :conIdSET AND
                            Subscription_Type_1__c = :SUBTYPE_POSTAGE AND 
                            (
                                (   //1
                                    Zuora__Status__c = :STATUS_ACTIVE AND
                                    Billing_Type__c = :MR_POST AND
                                    Zuora__SubscriptionStartDate__c <= :lastDayOfMonth AND 
                                    (Zuora__SubscriptionEndDate__c >= :firstDayOfMonth OR Zuora__SubscriptionEndDate__c = null)AND 
                                    Order_Number_1__r.CreatedDate < :firstDayOfMonth
                                )
                                OR
                                (
                                    //2
                                    Zuora__Status__c = :STATUS_ACTIVE AND
                                    Billing_Type__c = :MR_PRE AND
                                    Zuora__SubscriptionStartDate__c <= :firstDayOfMonth AND 
                                    (Zuora__SubscriptionEndDate__c >= :firstDayOfMonth OR Zuora__SubscriptionEndDate__c = null) AND
                                    Order_Number_1__r.CreatedDate < :firstDayOfMonth
                                )
                                OR
                                (   //3
                                    Zuora__Status__c = :STATUS_CANCELLED AND 
                                   (Zuora__SubscriptionEndDate__c > :firstDayOfMonth OR Zuora__SubscriptionEndDate__c = null) AND
                                    Order_Number_1__r.CreatedDate < :firstDayOfMonth
                                )
                            )
                        ORDER BY Zuora__Account__c, Billing_Type__c, Recipient_Address_ID__c, Billing_Type__c, New_Contract_Period_1__c];

            //fetch DC Subs for NEXT MONTH
            subPrepaidList = [SELECT Id, Name, Zuora__Account__c, Recipient_Address_ID__c, Subscription_Type_1__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, 
                        Billing_Type__c, Zuora__SubscriptionStartDate__c, New_Contract_Period_1__c, Contract_End_Date_1__c,Recipient_Contact__c
                        FROM Zuora__Subscription__c
                        WHERE
                            Recipient_Contact__c IN :conIdSET AND
                            Subscription_Type_1__c = :SUBTYPE_POSTAGE AND 
                            (
                                (   //1,2
                                    Zuora__Status__c = :STATUS_ACTIVE AND 
                                    Billing_Type__c = :MR_PRE AND
                                    Zuora__SubscriptionStartDate__c <= :firstDayOfNextMonth AND 
                                  ( Zuora__SubscriptionEndDate__c >= :firstDayOfNextMonth OR Zuora__SubscriptionEndDate__c = null)
                                )
                                OR
                                (   //3
                                    Zuora__Status__c = :STATUS_ACTIVE AND
                                    Billing_Type__c = :MR_POST AND
                                    Zuora__SubscriptionStartDate__c <= :lastDayOfMonth AND 
                                   ( Zuora__SubscriptionEndDate__c >= :firstDayOfMonth OR Zuora__SubscriptionEndDate__c = null)
                                )
                                OR
                                (   //4,5,6
                                    Zuora__Status__c = :STATUS_CANCELLED AND
                                  ( Zuora__SubscriptionEndDate__c > :firstDayOfNextMonth OR Zuora__SubscriptionEndDate__c = null)
                                )
                            )
                        ORDER BY Zuora__Account__c, Billing_Type__c, Recipient_Address_ID__c, Billing_Type__c, New_Contract_Period_1__c];
        }
        
        for (Zuora__Subscription__c sub :subPrepaidList) {
            startDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
            //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            
            Usage__c usage = new Usage__c();
            usage.UOM__c = postageUOM;
            usage.Account_Id__c = sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
            usage.Subscription_Id__c = sub.Name;
            usage.Start_Date__c = startDate;
            usage.Quantity__c = 1; // HOW TO GET QUANTITY
            usage.Status__c = UsageHelper.USAGE_STATUS;
            usage.Usage_Type__c = UsageHelper.USAGE_TYPE_POSTAGE_CHARGE;    
            usageList.add(usage);
        }
        
        for (Zuora__Subscription__c sub :subPostpaidList) {
            //START-END 04/20/2015 D-2764 & D-2765 Removed by J.Sarion - Removed commented lines
            startDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
            
            Usage__c usage = new Usage__c();
            usage.UOM__c = postageUOM;
            usage.Account_Id__c = sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
            usage.Subscription_Id__c = sub.Name;
            usage.Start_Date__c = startDate;
            usage.Quantity__c = 1; // HOW TO GET QUANTITY
            usage.Status__c = UsageHelper.USAGE_STATUS;
            usage.Usage_Type__c = UsageHelper.USAGE_TYPE_POSTAGE_CHARGE;    
            usageList.add(usage);
        }
        //END 04/20/2015 D-2764 & D-2765 Added by J.Sarion - Postage Batch Implementation   
        System.debug('Before loadUniqueUsages');
        UsageHelper.loadUniqueUsages(usageList,true);
        System.debug('After loadUniqueUsages');
        
        //START-END 04/20/2015 D-2764 & D-2765 Removed by J.Sarion - Removed commented lines        
    }
    /* @description 
     * Finish method will call the batch service facade as part of Control-M
     * @param bcTemp - predefined parameter
     * @return void
     */ 
    public void finish(database.batchableContext bcTemp){   
        // START 04/07/2015 D-2698 Kevin Evasco - BatchPostageMonthlyUsage fix
        BatchJobHelper.updateJobStatus(bcTemp.getJobId());
        // END 04/07/2015 D-2698 Kevin Evasco - BatchPostageMonthlyUsage fix
    }
}