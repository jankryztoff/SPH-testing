/**
 * Class Name: BatchPostageMonthlyUsage
 * @author: Joban Bir Singh
 * Date: 12/1/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch class that passes usage information for monthly postage charge
 *
 * @History: 01/15/2015 Krithika D: Change in finish method Control-M 
 */
global class BatchPostageMonthlyUsage implements Database.Batchable<sObject>,Database.AllowsCallouts
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
  
  // START D-3666 LISEN 10/7/2015 - Enable on demand batch call for recovery
    //START D-3666 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
    private Set<String> referenceIdsAsString = new Set<String>(); //START-END D-4076 12-10-2015 added by Jason A. for code review
    private Set<Id> referenceIdsAsId;
    private Integer type;
    Set<Id> contactIdSet = new Set<Id>();
    Boolean isApexJobSuccessful = true;
  
  // Default Constructor
  global BatchPostageMonthlyUsage(){
  }
  
  // Constructor for adhoc batch run using specific accountNumbers
    global BatchPostageMonthlyUsage(Set<String> referenceIds, Integer type){
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        this.referenceIdsAsString = referenceIds;   
        if(type == 1){
            referenceIdsAsId = new Set<Id>();
            for(String refId :referenceIds){
                referenceIdsAsId.add(Id.valueOf(refId));
            }           
            for(Zuora__Subscription__c sub :[SELECT Id, Recipient_Contact__c FROM Zuora__Subscription__c WHERE Id IN :referenceIdsAsId]){
                contactIdSet.add(sub.Recipient_Contact__c);
            }
        }
        else if(type == 2){
            for(Zuora__Subscription__c sub :[SELECT Id, Recipient_Contact__c FROM Zuora__Subscription__c WHERE Zuora__CustomerAccount__r.Zuora__AccountNumber__c IN :referenceIdsAsString]){
                contactIdSet.add(sub.Recipient_Contact__c);
            }
        }
        this.type = type;
    }
    //END D-3666 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
  // END   D-3666 LISEN 10/7/2015 - Enable on demand batch call for recovery
  
    public database.QueryLocator start(database.BatchableContext bcTemp)
    {
        //START 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches              
        Date startDate = referenceDate.toStartOfMonth();
        Date endDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
        //START 04/20/2015 D-2764 & D-2765 Added by J.Sarion - Postage Batch Implementation
    
    // START D-3666 LISEN 10/7/2015 - Enable on demand batch call for recovery
    String query = 'SELECT ID FROM Contact WHERE Recipient_Indicator__c = true ';
        //START D-3666 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
        if(!contactIdSet.isEmpty()){
            query += ' AND Id IN :contactIdSet'; 
        }
        //END D-3666 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
    // END D-3666 LISEN 10/7/2015 - Enable on demand batch call for recovery
    
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
    // START D-3666 LISEN 10/7/2015 - Enable on demand batch call for recovery
        //START D-3666 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
        Logger logger = new Logger(SP_DeliveryChargesBatch.class.getName(), 'SP005', bcTemp.getJobID());
        try{
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
              Billing_Type__c, Zuora__SubscriptionStartDate__c, New_Contract_Period_1__c, Contract_End_Date_1__c,Recipient_Contact__c, Zuora__SubscriptionEndDate__c//START-END D-3285 07/27/2015 Added by J.Sarion - added Zuora__SubscriptionEndDate__c
              FROM Zuora__Subscription__c
              WHERE
                Recipient_Contact__c IN :conIdSET AND
                Subscription_Type_1__c = :SUBTYPE_POSTAGE AND 
                Billing_Type__c != :FULL_PRE AND // Start/End D-4376 01Feb16 JohnD
                (
                  (   //1
                    Zuora__Status__c = :STATUS_ACTIVE AND
                    Billing_Type__c = :MR_POST AND
                    //START D-3225 07/09/2015 Added by J.Sarion - Create usage on the start month
                    Zuora__SubscriptionStartDate__c <= :firstDayOfMonth AND 
                    //END D-3225 07/09/2015 Added by J.Sarion - Create usage on the start month
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
              Billing_Type__c, Zuora__SubscriptionStartDate__c, New_Contract_Period_1__c, Contract_End_Date_1__c,Recipient_Contact__c, Zuora__SubscriptionEndDate__c//START-END D-3285 07/27/2015 Added by J.Sarion - added Zuora__SubscriptionEndDate__c
              FROM Zuora__Subscription__c
              WHERE
                Recipient_Contact__c IN :conIdSET AND
                Subscription_Type_1__c = :SUBTYPE_POSTAGE AND 
                Billing_Type__c != :FULL_PRE AND // Start/End D-4376 01Feb16 JohnD
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
        //START D-3225 07/09/2015 Added by J.Sarion - Update Usage Start Date
        if(referenceDate != null) {
          startDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);//KARL D-2830
        } else {
          startDate = Date.today().addMonths(1).toStartofMonth().addDays(-1);
        }
        if(sub.Zuora__SubscriptionEndDate__c != null){
          if(sub.Billing_Type__c == MR_PRE && ((sub.Zuora__SubscriptionEndDate__c.month()-1) == (referenceDate.month()-1) && sub.Zuora__SubscriptionEndDate__c.year() == referenceDate.year())){
            startDate = sub.Zuora__SubscriptionStartDate__c;
          }
          if(sub.Billing_Type__c == MR_POST && sub.Zuora__SubscriptionEndDate__c.month() == referenceDate.month() && sub.Zuora__SubscriptionEndDate__c.year() == referenceDate.year()){
            startDate = sub.Zuora__SubscriptionEndDate__c;
          }
        }
        //END D-3225 07/09/2015 Added by J.Sarion - Update Usage Start Date
        
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
        //START D-3225 07/09/2015 Added by J.Sarion - Update Usage Start Date
        if(referenceDate != null) {
          startDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
        } else {
          startDate = Date.today().addMonths(1).toStartofMonth().addDays(-1);
        }
        if(sub.Zuora__SubscriptionEndDate__c != null){
          if(sub.Billing_Type__c == MR_PRE && ((sub.Zuora__SubscriptionEndDate__c.month()-1) == (referenceDate.month()-1) && sub.Zuora__SubscriptionEndDate__c.year() == referenceDate.year())){
            startDate = sub.Zuora__SubscriptionStartDate__c;
          }
          if(sub.Billing_Type__c == MR_POST && sub.Zuora__SubscriptionEndDate__c.month() == referenceDate.month() && sub.Zuora__SubscriptionEndDate__c.year() == referenceDate.year()){
            startDate = sub.Zuora__SubscriptionEndDate__c;
          }
        }
        //END D-3225 07/09/2015 Added by J.Sarion - Update Usage Start Date
        
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
    }catch(Exception e){
            logger.logBatchFailure(e, allScopes);
            logger.save();
            
            isApexJobSuccessful = false;
        }
        //END D-3666 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
    // END D-3666 LISEN 10/7/2015 - Enable on demand batch call for recovery
    }
    /* @description 
     * Finish method will call the batch service facade as part of Control-M
     * @param bcTemp - predefined parameter
     * @return void
     */ 
    public void finish(database.batchableContext bcTemp){
        // START 04/07/2015 D-2698 Kevin Evasco - BatchPostageMonthlyUsage fix
        //START D-3666 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
        if(!isApexJobSuccessful){
            BatchJobHelper.updateJobStatus(bcTemp.getJobId(), false);
        }else{
            BatchJobHelper.updateJobStatus(bcTemp.getJobId(), true);
        }
        //END D-3666 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
        // END 04/07/2015 D-2698 Kevin Evasco - BatchPostageMonthlyUsage fix
    }
}