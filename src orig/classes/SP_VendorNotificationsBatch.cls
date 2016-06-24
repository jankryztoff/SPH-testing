/**
 * Class Name: SP_VendorNotificationsBatch 
 * @author: Jb Domingo
 * Date: 9/25/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Class that send email notifications to Vendor and Vendor Staff
 * //dev 10.13.2014 added/modified daystToRetrieveInt variable for query string.
 */
/*History: Updated class for UD-2016 - inclusion of multi pub notification with same address into one email/sms/task
 *Added by: Sherwin Puli
 *Date: July 29, 2015
 *History: 07-Nov-15 Updates for UD-3170, get Alias from Post Sector Ops Mapping>>Vendor Ops>>Alias 
 */ 
 
global class SP_VendorNotificationsBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {

    //Start: D-2075 02/25/2014 Added by S.Puli
    list<exception> exceptionList = new list<exception>(); // declare this at the outermost within your class
    //End: D-2075 02/25/2014 Added by S.Puli
  global Batch_Configuration_Settings__c batchSettings; //by default, fetch cases closed on the past 30 days
   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param BC - predefined parameter 
    * @return list of objects from Order Object
    */ 
    
    //Start: MD-54 03/12/2015 Jason Abolac
    public static SMS_Outbound__c bound;
    public static List<SMS_Outbound__c> smsOutboundList = new List<SMS_Outbound__c>();
    //public List<String> mobileNumber = new List<String>();
    public static List<String> venStaffMobileNumberList = new List<String>();
    public static String venMobileNumber;
    //End: MD-54 03/12/2015 Jason Abolac
    public static Map<Id, String> subToOutputMAP = new Map<Id, String>();//Start/End: D-2184 03/14/2014 Added by S.Puli
    public static Map<Id, String> subToSmsOutputMAP = new Map<Id, String>();//Start/End: D-2544 04/16/2015 Added by J.Abolac
    
    // START 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
    global final String sessionId;
    global static String vendorRepRoleId = Key_Id__c.getInstance('Vendor Rep Role').Id__c;
    
    public static List<Task> taskList = new List<Task>();
    public static List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
    public static Task task;
    public static Set<String> venStaffid = new Set<String>();   
    public static Map<Id, User> vendorStaffId_partnerUser = new Map<Id, User>();
    //START: D-3662 11/16/2015 Added by Kristine Balaoing - hotfix added variables for batch recovery 
    global Set<Id> selectiveIds = new Set<Id>();
    global Boolean isAdhoc = false;
    //END: D-3662 11/16/2015 Added by Kristine Balaoing
    
    //START: D-3662 11/16/2015 Added by Kristine Balaoing - hotfix added for batch recovery
//START: D- 3662 Retest Failed 11/19/2015 Added by Kristine Balaoing - added for batch recovery/reorganize code sequence
//END: D-3662 11/16/2015 Added by Kristine Balaoing
    //START UD-2016 27-July-2015 Added By S.Puli - add logic for multi pub

    
    global class mailTextWrapper {
        global string mailBodyTop;
        global string mailBodyMid;
        global string mailBodyBottom;
        global list<string> mailtoAddress; 
        
        global string SMSmessageTop;
        global string SMSmessageMid;
        global string SMSmessageBottom;
        global List<string> SMSMobile;
        
        global String OwnerId;
        global List<String> WhoId;
        global string Description;
        global string taskSubject;
        
        global boolean sendMailKey;
        global string RecordTypeId;
        global string transactionPartnerCOS;
        global string transactionNameCOS;
        global string addressId;
        global string vendorId;

    }
    
    global Map<String, mailTextWrapper> mailText_Map;
    global Map<Id, Id> mailRemarks_Map;
    //END UD-2016 27-July-2015 Added By S.Puli
    
    //START D-3388 11-Sept-2015 Added By S.Puli
    public Map<Id, Map<Id,boolean>> coaWithTempRestartTom = new Map<Id, Map<Id,boolean>>();
    public Map<Id, Map<Id,boolean>> coaInBetwnTStop = new Map<Id, Map<Id,boolean>>();
    //END D-3388 11-Sept-2015 Added By S.Puli
    public SP_VendorNotificationsBatch() {
        //START UD-2016 27-July-2015 Added By S.Puli - add logic for multi pub
        mailText_Map = new Map<String, mailTextWrapper>();
        mailRemarks_Map = new Map<Id, Id>();
        //END UD-2016 27-July-2015 Added By S.Puli - add logic for multi pub
    }
    // END : UD-0982 5/12/2015 MGaelo
    // END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
    
    
    public SP_VendorNotificationsBatch(Set<Id> caseList){
        mailText_Map = new Map<String, mailTextWrapper>();
        mailRemarks_Map = new Map<Id, Id>();
        this.selectiveIds = caseList;
        this.isAdhoc = true;
    }
    
    //END: D- 3662 Retest Failed 11/19/2015 Added by Kristine Balaoing
    global Database.QueryLocator start(Database.BatchableContext BC) {
      batchSettings = Batch_Configuration_Settings__c.getInstance('SP_VendorNotificationsBatch');
      Integer daysToRetriveInt = Integer.valueOf(batchSettings.Number_Of_Days_To_Retrieve__c); 
        //START: D-1623 01/14/2014 Added by S.Puli
        //START: D-2393 03/04/2014 Added by S.Puli
        //START: D-2522 03/18/2014 Added by S.Puli
        //START: MD-61 03/26/2015 Added by S.PULI - TEMP STOP + COA functionality
        //START D-2913 05/18/2015 Jason A./Sherwin P.
        //START D-2999 05/20/2015 Added By S.Puli
        //START: D-3130 18/06/2015 Added by S.Puli 
    //START UD-2016 10-Aug-2015 Added By S.Puli
        //START D-3388 17-Sept-2015 Added By S.Puli
    //START UD-1921 21-Oct-2015 Added By S.Puli
    //START UD-3170 05-Nov-2015 Added by S.Puli
        //START D-4074 10-Dec-2015 Added By S.Puli
        
        String CASE_STATUS_CLOSED = 'Closed';
        String CHANGE_OF_ADDRESS = 'Change_of_Address';
        String CHANGE_OF_VENDOR_TYPE = 'Change of Vendor'; 
        String CHANGE_OF_ADDRESS_TYPE1 = GlobalVariableClass.DELIVERYADDLOC;
        String CHANGE_OF_ADDRESS_TYPE2 = GlobalVariableClass.BILLDELIVERYADD;
        String START_SUBSCRIPTION = 'Start_Subscription';
        String CHANGE_OF_SUBSCRIPTION = 'Change_of_Subscription';
        String RENEWAL_OF_SUBSCRIPTION = 'Renewal_of_Subscription';
        String STOP_SUBSCRIPTION = 'Stop_Subscription';  
        String Z_SUBSCRIPTION_TYPE_PUB = 'PUBLICATION';
        String TSTOP_SUBSCRIPTION = 'Temp_Stop_Subscription';
        String CASE_SUB_STATUS_TSTOP_REJECTED = 'Temp Stop Rejected';
        String CASE_TEMP_STOP_TYPE_CANCELLED = 'Cancel';

        //Prepare the cutoff dates
        Date dtEffStart = Date.today();        
        Date dtEffEnd = dtEffStart.addDays(1);    
        
        String query = '';
        query = 'SELECT Case__c, Subscription__c ';
        query += ' FROM ';
        query += '      Case_Subscription__c ';
        query += ' WHERE ';
        query += '      (Case__r.Status = :CASE_STATUS_CLOSED ';
        query += '      OR (Case__r.Sub_Category__c = \'Stop Subscription\' ';
        //START: UD-3764 01/15/2015 added by Jason A.
        query += '      AND (Case__r.Sub_Status__c = \'Ready for Submission\' ';
        query += '      OR Case__r.Sub_Status__c = \'Provisioning\') ';
        //END: UD-3764 01/15/2015 added by Jason A.
        query += '      AND Case__r.Status = \'Pending\'))';
        query += '      AND (NOT Case__r.Sub_Status__c LIKE \'%Rejected%\' ) ';
        query += '      AND (Case__r.Sub_Status__c <> \'Request Recalled\' ) ';
        query += '      AND (Case__r.Temp_Stop__r.Temp_Stop_Status__c <> \'Cancelled\' ) ';
        query += '      AND (Case__r.account.recordtype.name != \'Vendor Subscriber\' ) ';
        query += '      AND (Subscription__r.Subscription_Type__c = \'Publication\' ) ';

        //AND Subscription__r.Subscription_Type__c <= :Z_SUBSCRIPTION_TYPE_PUB '
        query += '      AND ( ';


        //Change of Address (including Change of Vendor) with Effective Date = Tomorrow
        query += '              (   Case__r.RecordType.DeveloperName = :CHANGE_OF_ADDRESS ';
        query += '                  AND Case__r.Effective_Date__c = :dtEffEnd';
        query += '                  AND (   Case__r.Change_of_Address_Type__c = :CHANGE_OF_ADDRESS_TYPE1';
        query += '                          OR Case__r.Change_of_Address_Type__c = :CHANGE_OF_ADDRESS_TYPE2'; 
        query += '                          OR Case__r.Change_of_Address_Type__c = :CHANGE_OF_VENDOR_TYPE'; 
        query += '                  ) ';
        query += '              ) ';


        //Renewal of Subscription and Change of Subscriptions with the Subscription Start Date = Tomorrow
        query += '             OR (';       
        query += '                  ( Subscription__r.Zuora__SubscriptionStartDate__c = :dtEffEnd ';        
        query += '                      AND (Subscription__r.Zuora__SubscriptionEndDate__c > :dtEffStart';//Start/End PD-0198 01-Jun-2016 Added By S.Puli 
        query += '                      OR Subscription__r.Zuora__SubscriptionEndDate__c = null )';//Start/End PD-0198 01-Jun-2016 Added By S.Puli 
        query += '                  ) AND ( '; 
        query += '                      Case__r.RecordType.DeveloperName = :START_SUBSCRIPTION ';
        query += '                      OR Case__r.RecordType.DeveloperName = :CHANGE_OF_SUBSCRIPTION ';
        query += '                  ) ';
        query += '             ) ';


        //Stop Subscription. Subscription Start Date <= Tomorrow AND Stop Request Date is Tomorrow (Special Handling)
        //Special Handling: Go to order line items to see the stop request date. Stop Request Date is dependent on the publications which can vary for Bundled Package Subscription
        // Please refer to the pseudocode below for the special handling
        query += '             OR (';   
        query += '                  Case__r.RecordType.DeveloperName = :STOP_SUBSCRIPTION';
        query += '                  AND Subscription__r.Zuora__SubscriptionEndDate__c = :dtEffStart ';
        query += '                  AND Subscription__r.Zuora__SubscriptionStartDate__c < :dtEffStart ';//Start/End PD-0198 01-Jun-2016 Added By S.Puli 
        query += '             ) ';



        //Temp Stop. 
        query += '             OR (';   
        query += '                  Case__r.RecordType.DeveloperName = :TSTOP_SUBSCRIPTION ';
        query += '                  AND Case__r.Temp_Stop__r.Cancelled__c = FALSE ';
        query += '                  AND Case__r.Sub_Status__c != :CASE_SUB_STATUS_TSTOP_REJECTED ';     
        query += '                  AND Case__r.Temp_Stop_Type__c != :CASE_TEMP_STOP_TYPE_CANCELLED ';
        query += '                  AND (   Case__r.Temp_Stop_Date__c = :dtEffEnd ';
        query += '                          OR Case__r.Restart_Date__c = :dtEffEnd ';
        query += '                  )';
        query += '             ) ';

        query += '      ) ';
        
        //
        if (Test.isRunningTest()){
            query += ' Limit 200';
        }
        //End D-1983 02/25/2015 S.Puli
        //{
           // query += ' AND Subject = \'[SP_VendorNotificationsBatchTest] TEST_CLASS\'';
       // }
       //START: D-3662 11/16/2015 Added by Kristine Balaoing - hotfix added for batch recovery
       if(isAdhoc){
            query += ' AND Case__c IN :selectiveIds';
       }
       //END D-4074 10-Dec-2015 Added By S.Puli
       //END: D-3662 11/16/2015 Added by Kristine Balaoing
        return Database.getQueryLocator(query);    
    }
    /* @description Executes the business logic.Sends email notification to Vendor and Vendor Staff based on scenarios
     * 
     * @param BC - predefined parameter 
     * @param scope - a list of sObjects from the initial database query
     * @return void
     */ 
    //START D-4074 10-Dec-2015 Added By S.Puli
    global void execute(Database.BatchableContext BC, List<Case_Subscription__c> initialCaseSubsList) {       
    //START UD-3158 28-Nov-2015 Added By S.Puli - changing location to increase range
    Set<Id> initialCaseIds = new Set<Id>();
    if(initialCaseSubsList.size()>0){
        for(Case_Subscription__c cs : initialCaseSubsList){
            initialCaseIds.add(cs.Case__c);
        }
    }
    List<Case> scope = new List<Case>();
    if(initialCaseIds.size()>0){    
        //Start UD-3457 26-Jan-2016 Added By S.Puli
        scope = [Select Id, Remarks__c, CaseNumber, RecordType.Name, Account.Id, Subscription_Name__c, 
        Temp_Stop__r.Id, Restart_Date__c, Temp_Stop_Date__c, Temp_Stop__r.Temp_Stop_Date__c, 
        Temp_Stop__r.Restart_Date__c, CSO_Remarks__c, Sub_Category__c, Stop_Request_Date__c, Effective_Date__c, 
        Vendor__r.Email__c, Vendor__c, New_Address__r.Postal_Code__c, Vendor__r.RecordType.Name, 
        Requires_Urgent_Approval__c, Urgent_Request__c, Temp_Stop__r.Remarks__c, COA__c, Temp_Stop_Sub__c, 
        Vendor__r.Vendor_Communication_Preference__c, RecordTypeId, Sub_Status__c, Change_of_Address_Type__c, 
        New_Address__c, Vendor__r.Handphone_Number__c, Temp_Stop__r.Temp_Stop_Status__c, Temp_Stop__r.Qty__c, 
        Contact_To_Update__c, Contact_To_Update__r.Address__r.Postal_Code__r.Name, New_Address__r.Postal_Code__r.Name, Vendor__r.Active__c  
        FROM Case WHERE Id IN: initialCaseIds];
        //End UD-3457 26-Jan-2016 Added By S.Puli
    }
    //END D-4074 10-Dec-2015 Added By S.Puli
    try{
    //END UD-3158 28-Nov-2015 Added By S.Puli
        Boolean isSendEmail = false; // START-END : UD-0982 5/7/2015 MGaelo
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();       
        Set<Id> addressIdSet = new Set<Id>();
        Set<Id> singpostAddressIdSet = new Set<Id>();
        Set<Id> subscriptionIdSet = new Set<Id>();
        Set<string> pubCodeIdSet = new Set<string>();
        Set<string> ratePlanChargeIdSet = new Set<string>();
        Set<String> toAddressesSet = new Set<String>();
        //START D-0490 12/11/2014 JB Domingo - Added vendor id set 
        Set<Id> vendorAccountIdSet = new Set<Id>();
        //END D-0490 12/11/2014 JB Domingo 
        
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Map<Id,Address__c> addressMap = new Map<Id,Address__c>();
        Map<Id,Singpost_Address__c> singpostAddressMap = new Map<Id,Singpost_Address__c>();
        Map<Id,Zuora__Subscription__c> subscriptionMap = new Map<Id,Zuora__Subscription__c>();
        Map<Id, Zuora__SubscriptionProductCharge__c> subProdChargeMap = new Map<Id, Zuora__SubscriptionProductCharge__c>();
        Map<Id, Zuora__SubscriptionProductCharge__c> COS_subProdChargeMap = new Map<Id, Zuora__SubscriptionProductCharge__c>();//Start/End: D-2184 03/17/2014 Added by S.Puli
        
        //START: D-1961
        Map<String , Publication__c> publicationMap = new Map<String, Publication__c>(); 
        Map<String , Publication__c> COS_publicationMap = new Map<String, Publication__c>(); //Start/End: D-2184 03/17/2014 Added by S.Puli
        set<string> pubCode = new set<string>();
        Map <string, string> details = new  Map <string, string>();
        integer myCounter=0;
        //START: D-1961
                           
        Map<String, zqu__ProductRatePlanCharge__c> productRatePlanChargeMap = new Map<String, zqu__ProductRatePlanCharge__c>();
        Map<Id,List<Case_Subscription__c>> case_caseSubscriptionMap = new Map<Id,List<Case_Subscription__c>>();       
        Map<Id,List<Contact>> account_VendorStaffMap = new Map<Id,List<Contact>>();
        //START D-2913 05/18/2015 Jason A./Sherwin P.
        List<Address_Assignment__c> addAsignmentlist = new list<Address_Assignment__c>();
        
         //END D-2913 05/18/2015 Jason A./Sherwin P.
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Address__c> addressList = new List<Address__c>();
        List<Singpost_Address__c> singpostAddressList = new List<Singpost_Address__c>();
        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();     
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        List<Publication__c> publicationList = new List<Publication__c>();
        List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        //1813
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        //1813
        List<Case_Subscription__c> caseSubscriptionList = new List<Case_Subscription__c>();
        List<Contact> vendorStaffList = new List<Contact>();
        List<Case_Subscription__c> caseSubscriptionsList = new List<Case_Subscription__c>();
        List<Contact> vendorStaffsList = new List<Contact>(); 
        List<String> toAddresses = new List<String>();
        
        Account acct = new Account();
        Address__c addressObj = new Address__c(); 
        Boolean sendMail;       
        Contact con = new Contact(); 
        //1813       
        //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //1813
        Publication__c publicationObj = new Publication__c();      
        Singpost_Address__c singpostAddressObj = new Singpost_Address__c();
        String transactionName; 
        String sub = '';
        Zuora__SubscriptionProductCharge__c subProdChargeObj = new Zuora__SubscriptionProductCharge__c();        
        Zuora__Subscription__c subscription = new Zuora__Subscription__c();
        
        //START: D-1623 01/14/2014 Added by S.Puli
        List<Zuora__Subscription__c> subscripList = new List<Zuora__Subscription__c>();
        Set<Id> subsIdSet = new Set<Id>();
        Map<Id, Date> caseStopDateMap = new Map<Id, Date>();
        Map<Id, Id> caseSubsMAP = new Map<Id, Id>();
        
        // START D-2199    2015-02-17    Mic De Lara
        String classification = '' ;
        // END D-2199
        //START UD-0289 AddedBy Francisbenzon : variables 
        Boolean isPrint;
        Boolean isDigital;  
        Set<Id> packageIdSet = new Set<Id>();
        List<Package_Item__c> baseProdPackItemList = new List<Package_Item__c>();
        Map<Id, Package_Item__c> packagePackItemsMap = new Map<Id, Package_Item__c>();
        String freqDef = ' ';
        String freq = ' ';
        String phD = '0';
        String phE = '0';
        //END UD-0289 AddedBy Francisbenzon : variables 
        
        //START D-2999 05/20/2015 Added By S.Puli
        List<Case> casesCoa_LIST = new List<Case>();
        Map<Id, Address__c> addressMapForStart = new Map<Id, Address__c>(); //2913
        Map<String , Publication__c> noSundayPubMap = new Map<String, Publication__c>(); 
        //END D-2999 05/20/2015 Added By S.Puli
        
        //START: D-1961
        //START UD-0289 AdddedBy FrancisBenzon : added pub days in query
        //START D-2999 05/20/2015 Added By S.Puli
        //Start UD-1345 06/04/2015 Added By Jason A. 
        List <Publication__c> pubList = [Select Publication_Code__c, Sunday_Publication__r.Publication_Code__c, Published_Days__c,                                  
        Sunday_Publication__c, Has_Sunday_Pub__c, Publish_Pattern__c
                                          FROM Publication__c Where (Sunday_Publication__c <> '' AND Has_Sunday_Pub__c = true) 
                                          OR (Platform_Type__c='Print' AND Published_Days__c = 'YYYYYYY' AND Publish_Pattern__c = null AND Has_Sunday_Pub__c = false)];
                                        
        //END UD-1345 06/04/2015 Added By Jason A.                                
        List <Publication__c> noSunPubList = [Select Publication_Code__c, Sunday_Publication__r.Publication_Code__c, Published_Days__c,                                  
        Sunday_Publication__c, Has_Sunday_Pub__c, Publish_Pattern__c
                                          FROM Publication__c Where Has_Sunday_Pub__c = false];
                                          
        For (Publication__c pub :noSunPubList) {
            noSundayPubMap.put(pub.Publication_Code__c, pub); 
        }
        //END D-2999 05/20/2015 Added By S.Puli
        //END UD-0289 AdddedBy FrancisBenzon : added pub days in query
        For (Publication__c pub :pubList) {
            publicationMap.put(pub.Publication_Code__c, pub); 
            COS_publicationMap.put(pub.Publication_Code__c, pub); //Start/End: D-2184 03/17/2014 Added by S.Puli
        }    
        //START: D-3130 18/06/2015 Added by S.Puli 
        //END: D-3130 18/06/2015 Added by S.Puli 
        //END: D-1623 01/14/2014 Added by S.Puli
        
        //Get Ids of cases and accounts
        //Start: D-2075 02/25/2014 Added by S.Puli
        Map<Id, List<String>> caseToAddressVendorMap = new Map<Id, List<String>>();
        Map<Id, List<Vendor_Allocation__c>> verifySingleVendorAlloc = new Map<Id, List<Vendor_Allocation__c>>();
        Set<String> emailCheckerSet = new Set<String>();
        Map<Id, Id> newVendorAccIdMap = new Map<Id,Id>();
        String vendorStaffRecTypeId = ConstantsSLB.getKeyId('Contact_Vendor Staff');
        Map<Id, String> aliasCOAMap = new Map<Id, String>();
        Map<Id, Set<Id>> COA_conMap = new Map<Id, Set<Id>>();
        Set<Id> postSet = new Set<Id>();
        List<Vendor_Allocation__c> vaCheck;
        //START: D-3130 18/06/2015 Added by S.Puli
        List <Contact> cList = new List<Contact>(); 
        List<User> uList = new List<User>();
        //END: D-3130 18/06/2015 Added by S.Puli
    //START: MD-61 03/26/2015 Added by S.PULI - TEMP STOP + COA functionality
        Map<Case, Id> tempStopWithCOA_MAP = new Map<Case, Id>();
        List<Case> coaCase_LIST = new List<Case>();
        Set<Id> coaCase_SET = new Set<Id>();
        Map<Id, List<Case>> sub_CaseList_MAP = new Map<Id, List<Case>>();
        List<Case_Subscription__c> coaCaseSub_LIST = new List<Case_Subscription__c>();
        Map<Id, Case> coaIdToObj_MAP = new Map<Id, Case>();
        Map<Case, Case> tempCaseToCOACases_MAP = new Map<Case, Case>();
    //END: MD-61 03/26/2015 Added by S.PULI - TEMP STOP + COA functionality
        //End: D-2075 02/25/2014 Added by S.Puli
        
        
        //START D-2913 05/18/2015 Jason A./Sherwin P.
        Map<Id, List<Vendor_Allocation__c>> verifySingleVendorAllocTrue = new Map<Id, List<Vendor_Allocation__c>>();
        Set<Id> caseCoaIds = new Set<Id>();
        //END D-2913 05/18/2015 Jason A./Sherwin P.
        if(scope != null){
            for(Case caseObj: scope){
                caseIdSet.add(caseObj.Id);  
                accountIdSet.add(caseObj.Account.Id);
            
            //Start: D-2075 02/25/2014 Added by S.Puli
                if(caseObj.RecordTypeId == ConstantsSLB.getKeyId('Case_Change in Address') && caseObj.Effective_Date__c == Date.today()+1){
        //START D-2913 05/18/2015 Jason A./Sherwin P.
                    //START D-2999 05/20/2015 Added By S.Puli
                    caseCoaIds.add(caseObj.Id);
                    if(caseObj.Sub_Status__c != GlobalVariableClass.SUB_STATUS_WAITING_FOR_COA_APPROVAL && caseObj.Sub_Status__c != GlobalVariableClass.SUB_STATUS_COA_REJECTED && 
                    (caseObj.Change_of_Address_Type__c ==GlobalVariableClass.CHANGEVENDOR || caseObj.Change_of_Address_Type__c ==GlobalVariableClass.DELIVERYADDLOC || 
                    caseObj.Change_of_Address_Type__c ==GlobalVariableClass.BILLDELIVERYADD)){
                        casesCoa_LIST.add(caseObj);
                    }
                    //END D-2999 05/20/2015 Added By S.Puli
                    //START: D-3130 18/06/2015 Added by S.Puli
                    //END: D-3130 18/06/2015 Added by S.Puli 
                }
                //START: MD-61 03/26/2015 Added by S.PULI - TEMP STOP + COA functionality
                //START: D-3130 18/06/2015 Added by S.Puli
                if(caseObj.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && (caseObj.Temp_Stop__r.Restart_Date__c == Date.today()+1 || 
                caseObj.Temp_Stop__r.Temp_Stop_Date__c == Date.today()+1)&& caseObj.COA__c == true){
                    tempStopWithCOA_MAP.put(caseObj, caseObj.AccountId);
                }
                //END: D-3130 18/06/2015 Added by S.Puli
                //END: MD-61 03/26/2015 Added by S.PULI
            }
            //End: D-2075 02/25/2014 Added by S.Puli
        }
        
        //START: MD-61 03/26/2015 Added by S.PULI - TEMP STOP + COA functionality
        if(tempStopWithCOA_MAP.size()>0){
        //START D-2913 05/18/2015 Jason A./Sherwin P.
        //START D-2999 05/20/2015 Added By S.Puli
        // Start D-3312 03Aug15 JohnD - added Vendor__r.Vendor_Communication_Preference__c and Vendor__r.Handphone_Number__c fields
            //Start UD-3457 26-Jan-2016 Added By S.Puli
            coaCase_LIST = [Select Id, RecordTypeId, Effective_Date__c, AccountId, Change_of_Address_Type__c, Vendor__c, 
                    Vendor__r.RecordType.Name, Vendor__r.Email__c, New_Address__r.Postal_Code__c, Vendor__r.Vendor_Communication_Preference__c, 
                    Vendor__r.Handphone_Number__c, Vendor__r.Active__c 
                    From Case Where AccountId IN :tempStopWithCOA_MAP.values() 
                    AND RecordTypeId = :ConstantsSLB.getKeyId('Case_Change in Address') //START/END UD-3158 08-Dec-2015 Added by s.Puli AND Effective_Date__c >= TODAY 
                    AND Sub_Status__c != :GlobalVariableClass.SUB_STATUS_WAITING_FOR_COA_APPROVAL 
                    AND Sub_Status__c != :GlobalVariableClass.SUB_STATUS_COA_REJECTED 
                    AND (Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR 
                    OR Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC 
                    OR Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD)];
            //End UD-3457 26-Jan-2016 Added By S.Puli
        // End D-3312 03Aug15 JohnD - added Vendor__r.Vendor_Communication_Preference__c and Vendor__r.Handphone_Number__c fields
        //END D-2999 05/20/2015 Added By S.Puli
        //END D-2913 05/18/2015 Jason A./Sherwin P.
        }
        if(coaCase_LIST.size()>0){
            for(Case c: coaCase_LIST){
                coaCase_SET.add(c.Id);
                coaIdToObj_MAP.put(c.Id, c);
            }
        }
        if(coaCase_SET.size()>0){
            // Start D-3312 03Aug15 JohnD - added Vendor__r.Vendor_Communication_Preference__c and Vendor__r.Handphone_Number__c fields
            //START UD-3170 05-Nov-2015 Added by S.Puli
            coaCaseSub_LIST = [Select Id, Case__c, Case__r.Effective_Date__c, Subscription__c, Case__r.New_Address__r.Postal_Code__c, 
                    Case__r.Vendor__r.Handphone_Number__c, Case__r.Vendor__r.Vendor_Communication_Preference__c, Case__r.New_Address__r.Postal_Code__r.Name,
                    Case__r.Contact_To_Update__c, Case__r.Contact_To_Update__r.Address__r.Postal_Code__r.Name, Case__r.Vendor__c, Case__r.Contact_To_Update__r.Address__c,
                    Case__r.Contact_To_Update__r.Address__r.Postal_Code__c 
                    From Case_Subscription__c Where Case__c IN :coaCase_SET];
            //END UD-3170 05-Nov-2015 Added by S.Puli
            // End D-3312 03Aug15 JohnD - added Vendor__r.Vendor_Communication_Preference__c and Vendor__r.Handphone_Number__c fields
        }
        //START UD-3170 05-Nov-2015 Added by S.Puli
        Map<Id, String> coaCaseWithTempToZoneName = new Map<Id, String>();
        if(coaCaseSub_LIST.size()>0){
            for(Case_Subscription__c cs :  coaCaseSub_LIST){
                //Start UD-3457 26-Jan-2016 Added By S.Puli
                if(cs.Case__r.Vendor__c <> null){
                    if(cs.Case__r.Contact_To_Update__c <> null){
                        if(cs.Case__r.Contact_To_Update__r.Address__c <> null){
                            if(cs.Case__r.Contact_To_Update__r.Address__c <> null){
                                if(cs.Case__r.Contact_To_Update__r.Address__r.Postal_Code__c <> null){
                                    if(cs.Case__r.Contact_To_Update__r.Address__r.Postal_Code__r.Name.length() > 2){
                                        coaCaseWithTempToZoneName.put(cs.Case__c, cs.Case__r.Contact_To_Update__r.Address__r.Postal_Code__r.Name.subString(0,2));
                                    }else{
                                        coaCaseWithTempToZoneName.put(cs.Case__c, cs.Case__r.Contact_To_Update__r.Address__r.Postal_Code__r.Name);
                                    }
                                }
                            }
                        }
                    }
                }else if(cs.Case__r.New_Address__c <> null){
                    if(cs.Case__r.New_Address__r.Postal_Code__c <> null){
                        if(cs.Case__r.New_Address__r.Postal_Code__r.Name <> null){
                            if(cs.Case__r.New_Address__r.Postal_Code__r.Name.length() > 2){
                                coaCaseWithTempToZoneName.put(cs.Case__c, cs.Case__r.New_Address__r.Postal_Code__r.Name.subString(0,2));
                            }else{
                                coaCaseWithTempToZoneName.put(cs.Case__c, cs.Case__r.New_Address__r.Postal_Code__r.Name);
                            }
                        }
                    }
                }
                //End UD-3457 26-Jan-2016 Added By S.Puli
                if(sub_CaseList_MAP.containskey(cs.Subscription__c)){
                    sub_CaseList_MAP.get(cs.Subscription__c).add(coaIdToObj_MAP.get(cs.Case__c));
                } else{
                    sub_CaseList_MAP.put(cs.Subscription__c, new List<Case>{coaIdToObj_MAP.get(cs.Case__c)});
                }
            }
        }
        //END UD-3170 05-Nov-2015 Added by S.Puli
        //Temp_Stop_Sub__c
        Date currDate;
        //START: D-3130 18/06/2015 Added by S.Puli
        Map<Id, Id> coaCasesToTempCase_MAP = new Map<Id, Id>();
        Map<Id, boolean> tempStopCaseToKey_MAP = new Map<Id, boolean>();
        boolean booleanKey = false;
        //END: D-3130 18/06/2015 Added by S.Puli
    //START UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
    Map<Id, boolean> tempRestartWithCoaTom = new Map<Id, boolean>();
        boolean booleanKeyForRestartCoa = false;
    //END UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
        
        //start D-3388 11-Sept-2015 Added by S.Puli
        Map<Id, boolean> tempStopRestartWithCOATom = new Map<Id, boolean>();
        //end D-3388 11-Sept-2015 Added by S.Puli
        //START UD-3170 05-Nov-2015 Added by S.Puli
        Map<Id, String> tempCaseToUserAlias_Map = new Map<Id, String>();
        //END UD-3170 05-Nov-2015 Added by S.Puli
        if(sub_CaseList_MAP.size()>0){
            for(Case c : tempStopWithCOA_MAP.keyset()){
                //START: D-3130 18/06/2015 Added by S.Puli
                //START UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                booleanKeyForRestartCoa = false;
                booleanKey = false;
                //if(c.Restart_Date__c == Date.today()+1){
                    if(sub_CaseList_MAP.containskey(c.Temp_Stop_Sub__c) && sub_CaseList_MAP.get(c.Temp_Stop_Sub__c) <> null){
                        for(Case ca : sub_CaseList_MAP.get(c.Temp_Stop_Sub__c)){
                            //start D-3388 11-Sept-2015 Added by S.Puli
                            if(ca.Effective_Date__c == c.Restart_Date__c){
                                tempStopRestartWithCOATom.put(c.Id, true);
                            }
                            //END D-3388 11-Sept-2015 Added by S.Puli
                            for(currDate = c.Temp_Stop_Date__c; currDate <= c.Restart_Date__c; currDate = currDate.addDays(1)){
                                if(ca.Effective_Date__c == currDate){
                                    if(c.Restart_Date__c == Date.today()+1){
                                        tempCaseToCOACases_MAP.put(c, ca);
                                        coaCasesToTempCase_MAP.put(ca.Id, c.Id);
                                    }
                                }
                                if(ca.Effective_Date__c == c.Temp_Stop_Date__c){
                                    booleanKey = true;
                                }
                                if(ca.Effective_Date__c == c.Restart_Date__c){
                                    booleanKeyForRestartCoa = true;
                                }
                            }       
                        }
                    }

                tempStopCaseToKey_MAP.put(c.Id, booleanKey);
                tempRestartWithCoaTom.put(c.Id, booleanKeyForRestartCoa);
                //END UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                //END: D-3130 18/06/2015 Added by S.Puli
                            }
                        }       
        //START UD-3170 05-Nov-2015 Added by S.Puli
        Map<String, String> zoneNameToAlias_MAP = new Map<String, String>();
        List<Post_Sector_Ops_Rep_Mapping__c> tempRestartPostSectorMapping_List = new List<Post_Sector_Ops_Rep_Mapping__c>();
        if(coaCaseWithTempToZoneName.size()>0){
            tempRestartPostSectorMapping_List = [Select Id, Zone__r.Name, Vendor_Ops__c, Vendor_Ops__r.Alias, Vendor_Ops__r.IsActive 
            From Post_Sector_Ops_Rep_Mapping__c 
            Where Zone__r.Name In :coaCaseWithTempToZoneName.values() AND Vendor_Ops__c <> null AND Vendor_Ops__r.IsActive = true];
            if(tempRestartPostSectorMapping_List.size() > 0){
                for(Post_Sector_Ops_Rep_Mapping__c postRec : tempRestartPostSectorMapping_List){
                    if(postRec.Zone__c <> null && postRec.Vendor_Ops__c <> null){
                        //Start UD-3457 26-Jan-2016 Added By S.Puli
                        if(postRec.Zone__r.Name.length()>2){
                            zoneNameToAlias_MAP.put(postRec.Zone__r.Name.subString(0,2), postRec.Vendor_Ops__r.Alias);
                        }else{
                            zoneNameToAlias_MAP.put(postRec.Zone__r.Name, postRec.Vendor_Ops__r.Alias);
                        }
                        //End UD-3457 26-Jan-2016 Added By S.Puli
                    }
                }
            }
        }
        if(coaCasesToTempCase_MAP.size()>0){
            if(zoneNameToAlias_MAP.size() > 0){
                for(Id coaCaseId : coaCasesToTempCase_MAP.keySet()){
                    if(coaCaseWithTempToZoneName.size() > 0){
                        if(coaCaseWithTempToZoneName.containsKey(coaCaseId)){
                            if(zoneNameToAlias_MAP.containsKey(coaCaseWithTempToZoneName.get(coaCaseId))){
                                tempCaseToUserAlias_Map.put(coaCasesToTempCase_MAP.get(coaCaseId), zoneNameToAlias_MAP.get(coaCaseWithTempToZoneName.get(coaCaseId)));
                            }
                        }
                    }
                }
            }
        }
        //END UD-3170 05-Nov-2015 Added by S.Puli
        //START: D-3130 18/06/2015 Added by S.Puli 
        Map<Id, List<String>> tempWithCoaToVendorEmail_MAP = new Map<Id, List<String>>();
        Map<Id, Id> coaCaseToVendorId_MAP = new Map<Id, Id>();
        Map<Id, List<String>> tempToNewMobile_Map = new Map<Id, List<String>>();
        if(coaCase_LIST.size()>0){
            for(Case coaCase : coaCase_LIST){
                if(coaCase.Vendor__c<>null){
                    coaCaseToVendorId_MAP.put(coaCase.Id, coaCase.Vendor__c);
                    if(coaCasesToTempCase_MAP.containsKey(coaCase.Id)){
                        //Start UD-3457 26-Jan-2016 Added By S.Puli
                        if(coaCase.Vendor__r.Active__c){
                            if(coaCase.Vendor__r.Vendor_Communication_Preference__c <> 'SMS'){

                                if(!tempWithCoaToVendorEmail_MAP.containskey(coaCasesToTempCase_MAP.get(coaCase.Id)) && coaCase.Vendor__r.Email__c <> null){
                                    tempWithCoaToVendorEmail_MAP.put(coaCasesToTempCase_MAP.get(coaCase.Id), new List<String>{coaCase.Vendor__r.Email__c});
                                }
                            }
                            if(coaCase.Vendor__r.Vendor_Communication_Preference__c <> 'Email'){
                                if(!tempToNewMobile_Map.containskey(coaCasesToTempCase_MAP.get(coaCase.Id))){
                                    if(coaCase.Vendor__r.Handphone_Number__c <> null && coaCase.Vendor__r.Handphone_Number__c<>''){
                                        tempToNewMobile_Map.put(coaCasesToTempCase_MAP.get(coaCase.Id), new List<String>{coaCase.Vendor__r.Handphone_Number__c});
                                    }
                                }
                            }
                        }
                        //End UD-3457 26-Jan-2016 Added By S.Puli
                    }
                }
            }
        }
        
        List<Address_Assignment__c> tempStopCoa_Address_LIST = new List<Address_Assignment__c>();
        if(tempCaseToCOACases_MAP.size()>0){
            //Start UD-3457 26-Jan-2016 Added By S.Puli
            tempStopCoa_Address_LIST = [Select Id, Subscription__c, Vendor__c, Case__c, Contact_ID__c, Subscription_Vendor__c, Address__c, 
            Contact__c, Vendor__r.Vendor_Communication_Preference__c,Vendor__r.Email__c, Vendor__r.Handphone_Number__c,
            Vendor__r.Active__c 
            from Address_Assignment__c where Case__c IN :tempCaseToCOACases_MAP.values()];
            //End UD-3457 26-Jan-2016 Added By S.Puli
        }
        
        Map<Id, Id> tempToNewAddId_MAP = new Map<Id, Id>();
        Map<Id, Address__c> tempToNewAdd_MAP = new Map<Id, Address__c>();
        
        if(tempStopCoa_Address_LIST.size()>0){
            for(Address_Assignment__c add : tempStopCoa_Address_LIST){
                coaCaseToVendorId_MAP.put(add.Case__c, add.Vendor__c);
                if(coaCasesToTempCase_MAP.containskey(add.Case__c)){
                    if(!tempToNewAddId_MAP.containsKey(coaCasesToTempCase_MAP.get(add.Case__c))){
                        tempToNewAddId_MAP.put(coaCasesToTempCase_MAP.get(add.Case__c), add.Address__c);
                    }
                    //Start UD-3457 26-Jan-2016 Added By S.Puli
                    if(add.Vendor__r.Active__c){
                        if(add.Vendor__r.Vendor_Communication_Preference__c <> 'SMS'){

                            if(!tempWithCoaToVendorEmail_MAP.containskey(coaCasesToTempCase_MAP.get(add.Case__c))){
                                //Start UD-3457 26-Jan-2016 Added By S.Puli
                                if(add.Vendor__r.Email__c <> null){ 
                                    tempWithCoaToVendorEmail_MAP.put(coaCasesToTempCase_MAP.get(add.Case__c), new List<String>{add.Vendor__r.Email__c});
                                }
                                //End UD-3457 26-Jan-2016 Added By S.Puli
                            }
                            if(add.Vendor__r.Vendor_Communication_Preference__c <> 'Email'){
                                //system.debug('preference>>'+add.Vendor__r.Vendor_Communication_Preference__c);
                                if(!tempToNewMobile_Map.containskey(coaCasesToTempCase_MAP.get(add.Case__c))){
                                    if(add.Vendor__r.Handphone_Number__c <> null && add.Vendor__r.Handphone_Number__c<>''){
                                        tempToNewMobile_Map.put(coaCasesToTempCase_MAP.get(add.Case__c), new List<String>{add.Vendor__r.Handphone_Number__c});
                                    }
                                }
                            }
                        }
                        else if(add.Vendor__r.Vendor_Communication_Preference__c <> 'Email'){
                            //system.debug('preference>>'+add.Vendor__r.Vendor_Communication_Preference__c);
                            if(!tempToNewMobile_Map.containskey(coaCasesToTempCase_MAP.get(add.Case__c))){
                                if(add.Vendor__r.Handphone_Number__c <> null && add.Vendor__r.Handphone_Number__c<>''){
                                    tempToNewMobile_Map.put(coaCasesToTempCase_MAP.get(add.Case__c), new List<String>{add.Vendor__r.Handphone_Number__c});
                                }
                            }
                        }
                    }
                    //End UD-3457 26-Jan-2016 Added By S.Puli
                }
            }
        }
        if(tempToNewAddId_MAP.size()>0){
            for(Address__c addRec : [SELECT Id, Street_Name__c, Building_Name__c, Block_House_Number__c, Level_Number__c, Unit_Number__c, Postal_Code__r.Id 
            FROM Address__c WHERE Id IN :tempToNewAddId_MAP.values()]){
                if(!tempToNewAdd_MAP.containskey(addRec.Id)){
                    tempToNewAdd_MAP.put(addRec.Id, addRec);
                }
            }
        }
        List<Contact> coaVenstaff_LIST = new List<Contact>();
        List<User> tempCaseToUser_List = new List<User>();
        Map<Id, Id> tempCaseToUserId_Map = new Map<Id, Id>();
        //START UD-3170 05-Nov-2015 Added by S.Puli
        //REMOVE Map<Id, String> tempCaseToUserAlias_Map = new Map<Id, String>();
        //END UD-3170 05-Nov-2015 Added by S.Puli
        Map<Id, Set<Id>> tempCaseToContacts_Map = new Map<Id, Set<Id>>();
        if(coaCaseToVendorId_MAP.size()>0){
            //START: D-3140 20/06/2015 Added by S.Puli
            coaVenstaff_LIST = [Select Id, Name, AccountId, RecordTypeId, Email, Active__c, Vendor_Communication_Preference__c, HomePhone__c 
            From Contact Where RecordTypeId = :vendorStaffRecTypeId And AccountId IN :coaCaseToVendorId_MAP.values() AND Active__c = true];
            
            if(coaVenstaff_LIST.size()>0){
                for(Contact c : coaVenstaff_LIST){
                    for(Id casId : coaCaseToVendorId_MAP.keyset()){
                        if(coaCaseToVendorId_MAP.get(casId) == c.AccountId){
                            if(coaCasesToTempCase_MAP.containskey(casId)){
                                if(!tempCaseToContacts_Map.containsKey(coaCasesToTempCase_MAP.get(casId))){
                                    tempCaseToContacts_Map.put(coaCasesToTempCase_MAP.get(casId), new Set<Id>{c.Id});
                                }
                                else{
                                    tempCaseToContacts_Map.get(coaCasesToTempCase_MAP.get(casId)).add(c.Id);
                                }
                                if(c.Vendor_Communication_Preference__c <> 'SMS'){
                                    //Start UD-3457 26-Jan-2016 Added By S.Puli
                                    if(c.Email <> null){
                                        if(tempWithCoaToVendorEmail_MAP.containskey(coaCasesToTempCase_MAP.get(casId))){
                                            tempWithCoaToVendorEmail_MAP.get(coaCasesToTempCase_MAP.get(casId)).add(c.Email);
                                        } else{
                                            tempWithCoaToVendorEmail_MAP.put(coaCasesToTempCase_MAP.get(casId), new List<string>{c.Email});
                                        }
                                    }
                                    //End UD-3457 26-Jan-2016 Added By S.Puli
                                    if(c.Vendor_Communication_Preference__c <> 'Email' && c.HomePhone__c<> null && c.HomePhone__c<> ''){
                                        if(!tempToNewMobile_Map.containsKey(coaCasesToTempCase_MAP.get(casId))){
                                            tempToNewMobile_Map.put(coaCasesToTempCase_MAP.get(casId), new List<String>{String.valueOf(c.HomePhone__c)});
                                        }
                                        else{
                                            tempToNewMobile_Map.get(coaCasesToTempCase_MAP.get(casId)).add(String.valueOf(c.HomePhone__c));
                                        }
                                    }
                                } else if(c.Vendor_Communication_Preference__c <> 'Email' && c.HomePhone__c<> null && c.HomePhone__c<> ''){
                                    if(!tempToNewMobile_Map.containsKey(coaCasesToTempCase_MAP.get(casId))){
                                        tempToNewMobile_Map.put(coaCasesToTempCase_MAP.get(casId), new List<String>{String.valueOf(c.HomePhone__c)});
                                    }
                                    else{
                                        tempToNewMobile_Map.get(coaCasesToTempCase_MAP.get(casId)).add(String.valueOf(c.HomePhone__c));
                                    }
                                }
                            }
                        }
                    }
                }
                //END: D-3140 20/06/2015 Added by S.Puli
                //START UD-2016 27-July-2015 Added By S.Puli
                tempCaseToUser_List = [Select Id, Name, Profile.UserLicense.Name, Alias, ContactId 
                From User 
                Where Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE AND ContactId IN :coaVenstaff_LIST AND IsActive = true];
                //END UD-2016 27-July-2015 Added By S.Puli
                
                if(tempCaseToUser_List.size()>0){
                    for(Contact c : coaVenstaff_LIST){
                        for(Id casId : coaCaseToVendorId_MAP.keyset()){
                            if(coaCaseToVendorId_MAP.get(casId) == c.AccountId){
                                if(coaCasesToTempCase_MAP.containskey(casId)){
                                    for(User userRec : tempCaseToUser_List){
                                        if(userRec.ContactId == c.Id){
                                            if(!tempCaseToUserId_Map.containsKey(casId)){
                                                tempCaseToUserId_Map.put(coaCasesToTempCase_MAP.get(casId), userRec.Id);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map
        //END: D-3130 18/06/2015 Added by S.Puli 
        if(scope != null){
            for(Case caseObj: scope){
                caseIdSet.add(caseObj.Id);  
                accountIdSet.add(caseObj.Account.Id);
            

                if(caseObj.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObj.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObj.COA__c == true){
                Case coaCaseRec = tempCaseToCOACases_MAP.get(caseObj);
                    //START 04/14/2015 D-2636 and D-2638 Kevin Evasco updated sms output to have the same value as email output.
                    if(coaCaseRec != null){
                        if(coaCaseRec.Vendor__c != null){
            //START D-2999 05/20/2015 Added By S.Puli 2913
                      if(coaCaseRec.Vendor__r.RecordType.Name==GlobalVariableClass.VENDOR && coaCaseRec.Vendor__r.Vendor_Communication_Preference__c != 'SMS'){
            //END  D-2999 05/20/2015 Added By S.Puli 2913
                            //START: D-3130 18/06/2015 Added by S.Puli 
                            //newVendorAccIdMap.put(coaCaseRec.Id, coaCaseRec.Vendor__c);
                            
                            }
                            
                        }

                    }
                        //END: D-3130 18/06/2015 Added by S.Puli
                    //END 04/14/2015 D-2636 and D-2638 Kevin Evasco updated sms output to have the same value as email output.
                }
            }

        }
        
        //END: MD-61 03/26/2015 Added by S.PULI - TEMP STOP + COA functionality
        //tempCaseToCOACases_MAP
        //Start: D-2075 02/25/2014 Added by S.Puli
        //START D-2913 05/18/2015 Jason A./Sherwin P.
        //START D-2999 05/20/2015 Added By S.Puli
        Set<Id> addressId_SET = new Set<Id>();
        //START: D-3130 18/06/2015 Added by S.Puli 
        Map<Id, List<String>> coaStartToNewMobile_MAP = new Map<Id, List<String>>();
        Map<Id, Id> coaStartToVendorId_MAP = new Map<Id, Id>();
        Map<Id,Id> coaStartToVendorId_ALL_Map = new Map<Id,Id>();
        Map<Id,List<String>> coaStartToEmails_Map = new Map<Id,List<String>> ();
        //START UD-3170 05-Nov-2015 Added by S.Puli - transfer to here
        Map<Id, String> coaToUserAlias_MAP = new Map<Id, String>();
        Map<Id, String> coaToZone = new Map<Id, String>();
        List<Post_Sector_Ops_Rep_Mapping__c> coaPostSectorMapping_List = new List<Post_Sector_Ops_Rep_Mapping__c>();
        //END UD-3170 05-Nov-2015 Added by S.Puli
        if(caseCoaIds.size()>0 && casesCoa_LIST.size()>0){
        //END: D-3130 18/06/2015 Added by S.Puli 
            //START D-2913 05/18/2015 Jason A./Sherwin P.
            //START: D-3130 18/06/2015 Added by S.Puli 
            Set<ID> coaVendorIdset = new Set<ID>();
            for(Case caseObj: casesCoa_LIST){
            //START UD-3170 05-Nov-2015 Added by S.Puli     
                if(caseObj.Vendor__c <> null ){
                    if(caseObj.Contact_To_Update__r.Address__c <> null){
                        if(caseObj.Contact_To_Update__r.Address__r.Postal_Code__c <> null){
                            if(caseObj.Contact_To_Update__r.Address__r.Postal_Code__r.Name <> null){
                                if(caseObj.Contact_To_Update__r.Address__r.Postal_Code__r.Name.length()>2){
                                    coaToZone.put(caseObj.Id,caseObj.Contact_To_Update__r.Address__r.Postal_Code__r.Name.subString(0,2));
                                }else{
                                    coaToZone.put(caseObj.Id,caseObj.Contact_To_Update__r.Address__r.Postal_Code__r.Name);
                                }
                            }
                        }
                    }
                    
                    coaVendorIdset.add(caseObj.Vendor__c);
                    if(!coaStartToVendorId_ALL_Map.containsKey(caseObj.Id)){
                        coaStartToVendorId_ALL_Map.put(caseObj.Id, caseObj.Vendor__c );
                    }
                    //Start UD-3457 26-Jan-2016 Added By S.Puli
                    if((caseObj.Vendor__r.Vendor_Communication_Preference__c <> GlobalVariableClass.SMS_Preference && caseObj.Vendor__r.Email__c <> null)&& caseObj.Vendor__r.Active__c){
                        if(!coaStartToEmails_Map.containsKey(caseObj.Id)){
                            coaStartToEmails_Map.put(caseObj.Id, new List<String>{caseObj.Vendor__r.Email__c});
                        }
                    }
                    if((caseObj.Vendor__r.Vendor_Communication_Preference__c == GlobalVariableClass.SMS_Preference || 
                    caseObj.Vendor__r.Vendor_Communication_Preference__c == GlobalVariableClass.REFERENCE_BOTH)&& caseObj.Vendor__r.Active__c){
                        if(!coaStartToNewMobile_MAP.containsKey(caseObj.Id)){
                            coaStartToNewMobile_MAP.put(caseObj.Id, new List<String>{caseObj.Vendor__r.Handphone_Number__c});
                        }
                        else{
                            coaStartToNewMobile_MAP.get(caseObj.Id).add(caseObj.Vendor__r.Handphone_Number__c);
                        }
                    }
                    //End UD-3457 26-Jan-2016 Added By S.Puli
                }else if(caseObj.New_Address__c <> null && caseObj.Vendor__c == null){//New_Address__r.Postal_Code__r.Name
                    if(caseObj.New_Address__r.Postal_Code__c <> null){
                        if(caseObj.New_Address__r.Postal_Code__r.Name <> null){
                            if(caseObj.New_Address__r.Postal_Code__r.Name.length()>2){
                                coaToZone.put(caseObj.Id,caseObj.New_Address__r.Postal_Code__r.Name.subString(0,2));
                            }else{
                                coaToZone.put(caseObj.Id,caseObj.New_Address__r.Postal_Code__r.Name);
                            }
                        }
                    }
                }               
                //END UD-3170 05-Nov-2015 Added by S.Puli
            }
            //START UD-3170 05-Nov-2015 Added by S.Puli coaToUserAlias_MAP
            if(coaToZone.size() > 0){
                coaPostSectorMapping_List = [Select Id, Zone__r.Name, Vendor_Ops__c, Vendor_Ops__r.Alias, Vendor_Ops__r.IsActive 
                From Post_Sector_Ops_Rep_Mapping__c 
                Where Zone__r.Name In :coaToZone.values() AND Vendor_Ops__c <> null AND Vendor_Ops__r.IsActive = true];
                if(coaPostSectorMapping_List.size() > 0){
                    for(Post_Sector_Ops_Rep_Mapping__c coaZoneToAlias : coaPostSectorMapping_List){
                        for(ID coaZoneToKey : coaToZone.keySet()){
                            if(coaZoneToAlias.Zone__r.Name == coaToZone.get(coaZoneToKey)){
                                coaToUserAlias_MAP.put(coaZoneToKey, coaZoneToAlias.Vendor_Ops__r.Alias);
                            }
                        }
                    }
                }
            }
            //Start UD-3457 26-Jan-2016 Added By S.Puli
            List<Address_Assignment__c> addAssign_list = [Select Id, Subscription__c, Vendor__c, Case__c, Contact_ID__c, 
            Subscription_Vendor__c, Address__c, Contact__c, Vendor__r.Vendor_Communication_Preference__c, 
            Vendor__r.Handphone_Number__c, Vendor__r.Email__c, Address__r.Postal_Code__c, Address__r.Postal_Code__r.Name,
            Vendor__r.Active__c
            from Address_Assignment__c where Case__c IN :caseCoaIds];
            //End UD-3457 26-Jan-2016 Added By S.Puli
            //END UD-3170 05-Nov-2015 Added by S.Puli
            //END D-2913 05/18/2015 Jason A./Sherwin P.
            
            
            if(addAssign_list.size()>0){
                for(Address_Assignment__c AD : addAssign_list){
                    //Start UD-3457 26-Jan-2016 Added By S.Puli
                    if(!coaStartToNewMobile_MAP.containsKey(AD.Case__c)){
                        coaStartToVendorId_MAP.put(AD.Case__c, AD.Vendor__c);
                        if((AD.Vendor__r.Vendor_Communication_Preference__c == GlobalVariableClass.REFERENCE_BOTH || 
                        AD.Vendor__r.Vendor_Communication_Preference__c == GlobalVariableClass.SMS_Preference)&& AD.Vendor__r.Active__c){
                            if(AD.Vendor__r.Handphone_Number__c <> null){
                                coaStartToNewMobile_MAP.put(AD.Case__c, new List<String>{String.valueOf(AD.Vendor__r.Handphone_Number__c)});
                            }
                        }
                    }
                    
                    //START D-2999 05/20/2015 Added By S.Puli
                    addressId_SET.add(AD.Address__c);
                    //END D-2999 05/20/2015 Added By S.Puli
                    if(AD.Vendor__c <> null && AD.Case__c <> null){
                        coaVendorIdset.add(AD.Vendor__c);
                        if((AD.Vendor__r.Vendor_Communication_Preference__c <> GlobalVariableClass.SMS_Preference && AD.Vendor__r.Email__c <> null)&& AD.Vendor__r.Active__c){
                            if(!coaStartToEmails_Map.containsKey(AD.Case__c)){
                                coaStartToEmails_Map.put(AD.Case__c, new List<String>{AD.Vendor__r.Email__c});
                            }
                        }
                    }
                    //End UD-3457 26-Jan-2016 Added By S.Puli
                }
            }
            //END: D-3130 18/06/2015 Added by S.Puli 
            //START D-2999 05/20/2015 Added By S.Puli
            List<Address__c> addressForCoa_LIST = [SELECT Id, Street_Name__c, Building_Name__c, Block_House_Number__c, Level_Number__c, Unit_Number__c, Postal_Code__r.Id 
            FROM Address__c WHERE Id IN :addressId_SET];
            if(addressForCoa_LIST.size()>0){
                for(Address__c addr : addressForCoa_LIST){
                    addressMapForStart.put(addr.Id, addr);
                }
            }
            //END D-2999 05/20/2015 Added By S.Puli
            //START D-2913 05/18/2015 Jason A./Sherwin P.
            List<Vendor_Allocation__c> vendorNew = [Select Id, SingPost_Address__c, Vendor_Account__c, Vendor_Account__r.Email__c, 
            Vendor_Account__r.Vendor_Communication_Preference__c From Vendor_Allocation__c Where Vendor_Account__c IN :coaVendorIdset];
            //END D-2913 05/18/2015 Jason A./Sherwin P.
    //END D-2999 05/20/2015 Added By S.Puli
            Map<Id, Vendor_Allocation__c> addIdToVendorAlloc = new Map<Id, Vendor_Allocation__c>();
            if(vendorNew.size()>0){
                for(Vendor_Allocation__c val : vendorNew){
                    for(Address_Assignment__c ad : addAssign_list){
                        if(addIdToVendorAlloc.containsKey(ad.Id)){
                            //do nothing
                        } else{
                            addIdToVendorAlloc.put(ad.Id, val);
                        }
                    }
                }
            }
            //list<Case_Subscription__c> casesub_list = [Select ID, Case__c, Subscription__c from Case_Subscription__c Where Case__c IN :caseCoaIds]
            for(Case caseObj: casesCoa_LIST){
                //START: D-3130 18/06/2015 Added by S.Puli
                if(vendorNew.size()>0){
                    for(Vendor_Allocation__c vRec : vendorNew){
                        if(caseObj.Vendor__c <> null && vRec.Vendor_Account__c == caseObj.Vendor__c){
                            if(!verifySingleVendorAllocTrue.containsKey(caseObj.Id)){
                                verifySingleVendorAllocTrue.put(caseObj.Id, new List<Vendor_Allocation__c>{vRec});
                            }
                        }
                    }
                }
                for(Address_Assignment__c a : addAssign_list){
                    if(!coaStartToVendorId_ALL_Map.containsKey(a.Case__c) && a.Vendor__c <> null){
                        coaStartToVendorId_ALL_Map.put(a.Case__c, a.Vendor__c);
                    }
                    if(caseObj.Id == a.Case__c){
                        if(verifySingleVendorAllocTrue.containskey(caseObj.Id)){
                            //do nothing
                        } else {
                            verifySingleVendorAllocTrue.put(caseObj.Id, new List<Vendor_Allocation__c>{addIdToVendorAlloc.get(a.Id)});
                        }
                    }
                    
                }
                //END: D-3130 18/06/2015 Added by S.Puli
            }
        }
        //END D-2913 05/18/2015 Jason A./Sherwin P.
        //START: D-3130 18/06/2015 Added by S.Puli
        for(Case caseObj: scope){
        //END: D-3130 18/06/2015 Added by S.Puli
        //START D-2913 05/18/2015 Jason A./Sherwin P.
                    //START UD-0289 5/19/15 AddedBy FrancisBenzon : added checking to avoid attempt to dereference null
                    if(verifySingleVendorAllocTrue.get(caseObj.Id)<>null && !verifySingleVendorAllocTrue.get(caseObj.Id).isEmpty()){
                    //END UD-0289 5/19/15 AddedBy FrancisBenzon : added checking to avoid attempt to dereference null
                        //START: D-3130 18/06/2015 Added by S.Puli
                        //REMOVE if(verifySingleVendorAllocTrue.get(caseObj.Id).size() == 1){
                        //END: D-3130 18/06/2015 Added by S.Puli
                        List <Vendor_Allocation__c> vTempList = new List <Vendor_Allocation__c>();
                        vTempList = verifySingleVendorAllocTrue.get(caseObj.Id);
                        //START UD-0289 5/19/15 AddedBy FrancisBenzon : added checking to avoid attempt to dereference null
                        if(vTempList[0] != null)
                        {
                            newVendorAccIdMap.put(caseObj.Id, vTempList[0].Vendor_Account__c);
        //END D-2913 05/18/2015 Jason A./Sherwin P.
                            if(caseToAddressVendorMap.get(caseObj.Id)<>null){
                                if(!emailCheckerSet.contains(vTempList[0].Vendor_Account__r.Email__c)){
                                    emailCheckerSet.add(vTempList[0].Vendor_Account__r.Email__c);
                                    //START D-2913 05/18/2015 Jason A./Sherwin P.
                                    //START: D-3130 18/06/2015 Added by S.Puli
                                    if(vTempList[0].Vendor_Account__r.Vendor_Communication_Preference__c != GlobalVariableClass.SMS_Preference){
                                    //END: D-3130 18/06/2015 Added by S.Puli
                                        caseToAddressVendorMap.get(caseObj.Id).add(vTempList[0].Vendor_Account__r.Email__c);
                                    }
                                    //END D-2913 05/18/2015 Jason A./Sherwin P.
                                }
                            }
                            else{
                            
                                if(!emailCheckerSet.contains(vTempList[0].Vendor_Account__r.Email__c)){
                                    emailCheckerSet.add(vTempList[0].Vendor_Account__r.Email__c);
                                    //START D-2913 05/18/2015 Jason A./Sherwin P.
                                    //START: D-3130 18/06/2015 Added by S.Puli
                                    if(vTempList[0].Vendor_Account__r.Vendor_Communication_Preference__c != GlobalVariableClass.SMS_Preference){
                                    //END: D-3130 18/06/2015 Added by S.Puli
                                        caseToAddressVendorMap.put(caseObj.Id, new List<String>{vTempList[0].Vendor_Account__r.Email__c});
                                    }
                                    //END D-2913 05/18/2015 Jason A./Sherwin P.
                                }
                            }
                        }
                        //END UD-0289 5/19/15 AddedBy FrancisBenzon : added checking to avoid attempt to dereference null    
                        //START: D-3130 18/06/2015 Added by S.Puli
                        //REMOVE }
                        //END: D-3130 18/06/2015 Added by S.Puli
                    }
        //START: D-3130 18/06/2015 Added by S.Puli
        }
        /**REMOVE
                }
            }
        }**/
        Map<Id, Set<Id>> coaStartToTaskCon_MAP = new Map<Id, Set<Id>>();
        Map<Id,Id> coaToUserTask_MAP = new Map<Id,Id>();
        Set<Id> coaContacts_SET = new Set<Id>();
        //END: D-3130 18/06/2015 Added by S.Puli
        if(newVendorAccIdMap<>null && newVendorAccIdMap.size()>0){
        //START D-2913 05/18/2015 Jason A./Sherwin P.
        //START: D-3130 18/06/2015 Added by S.Puli
        
        cList = [Select Id, Name, AccountId, RecordTypeId, Email, Active__c, Vendor_Communication_Preference__c,HomePhone__c 
        From Contact Where RecordTypeId = :vendorStaffRecTypeId And AccountId IN :coaStartToVendorId_ALL_Map.values() AND Active__c = true];
        //END: D-3130 18/06/2015 Added by S.Puli
        //END D-2913 05/18/2015 Jason A./Sherwin P.
            //START: D-3130 18/06/2015 Added by S.Puli
            if(cList.size()>0){
                for(Case caseObj: scope){
                    for(Contact c : cList){
                        
                        if(coaStartToVendorId_ALL_Map.containsKey(caseObj.Id)){
                            if(coaStartToVendorId_ALL_Map.get(caseObj.Id) == c.AccountId){
                                coaContacts_SET.add(c.Id);
                                if(!coaStartToTaskCon_MAP.containsKey(caseObj.Id)){
                                    coaStartToTaskCon_MAP.put(caseObj.Id, new Set<Id>{c.Id});
                                }
                                else{
                                    coaStartToTaskCon_MAP.get(caseObj.Id).add(c.Id);
                                }
                            }
                        }
                        if(c.Vendor_Communication_Preference__c != GlobalVariableClass.SMS_Preference){
                            if(coaStartToVendorId_ALL_Map.containsKey(caseObj.Id)){
                                if(coaStartToVendorId_ALL_Map.get(caseObj.Id) == c.AccountId){
                                    if(c.Email <> null){
                                        if(!coaStartToEmails_Map.containsKey(caseObj.Id)){
                                            coaStartToEmails_Map.put(caseObj.Id, new List<String>{c.Email});
                                        }
                                        else{
                                            coaStartToEmails_Map.get(caseObj.Id).add(c.Email);
                                        }
                                    }
                                }
                            }
                            if(coaStartToVendorId_ALL_Map.get(caseObj.Id) == c.AccountId){
                                if(COA_conMap.get(caseObj.Id)<>null){
                                    COA_conMap.get(caseObj.Id).add(c.Id);
                                } else {
                                    COA_conMap.put(caseObj.Id, new Set<Id>{c.Id});
                                }
                                if(caseToAddressVendorMap.containsKey(caseObj.Id)){
                                    Set<String> venStaf = new Set<String>();
                                    for(String s : caseToAddressVendorMap.get(caseObj.Id)){
                                        if(s == c.Email){
                                            venStaf.add(s);
                                        }
                                    }
                                    if(venStaf.size()==0){
                                        caseToAddressVendorMap.get(caseObj.Id).add(c.Email);
                                    }
                                } else {
                                    caseToAddressVendorMap.put(caseObj.Id, new List<String>{c.Email});
                                }
                            }
                        }
                        if(c.Vendor_Communication_Preference__c != GlobalVariableClass.Email_Preference && c.HomePhone__c <> null){
                            if(coaStartToVendorId_ALL_Map.containsKey(caseObj.Id)){
                                if(coaStartToVendorId_ALL_Map.get(caseObj.Id) == c.AccountId){
                                    if(!coaStartToNewMobile_MAP.containsKey(caseObj.Id)){
                                        coaStartToNewMobile_MAP.put(caseObj.Id, new List<String>{String.valueOf(c.HomePhone__c)});
                                    }
                                    else{
                                        coaStartToNewMobile_MAP.get(caseObj.Id).add(String.valueOf(c.HomePhone__c));
                                    }
                                }
                            }
                        }   
                    } 
                }
            }
            //END: D-3130 18/06/2015 Added by S.Puli
        }
        //START: D-3130 18/06/2015 Added by S.Puli
        //START UD-2016 27-July-2015 Added By S.Puli
        uList = [Select Id, Name, Profile.UserLicense.Name, Alias, ContactId From User Where Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE AND ContactId IN :coaContacts_SET AND IsActive = true];
        //END UD-2016 27-July-2015 Added By S.Puli
        //START UD-1820 Added by Jason A./S. Puli
        //END UD-1820 Added by Jason A./S. Puli
        if(cList.size()>0){
            for(Case caseObj: scope){
                for(Contact c : cList){
                    for(user uRec : uList){
                        if(coaStartToVendorId_ALL_Map.containsKey(caseObj.Id)){
                            if(coaStartToVendorId_ALL_Map.get(caseObj.Id) == c.AccountId){
                                if(uRec.ContactId == c.Id){
                                    if(!coaToUserTask_MAP.containsKey(caseObj.Id)){
                                        coaToUserTask_MAP.put(caseObj.Id, uRec.Id);
                                        //START UD-1820 Added by Jason A./S. Puli
                                        //END UD-1820 Added by Jason A./S. Puli
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //END: D-3130 18/06/2015 Added by S.Puli
        Set<Id> conSet = new Set<Id>();
        if(COA_conMap.size()>0 && COA_conMap<>null){
            for(Set<Id> s : COA_conMap.values()){
                for(Id t : s){
                    conSet.add(t);
                }
            }
            //START: D-3130 18/06/2015 Added by S.Puli
            /**REMOVE
            uList = [Select Id, Name, Profile.UserLicense.Name, Alias, ContactId From User Where Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE AND ContactId IN :conSet];
            **/
            //END: D-3130 18/06/2015 Added by S.Puli
            for(Case caseObj: scope){
                for(User u : uList){
                    if(u.ContactId<>null){
                        if(COA_conMap.get(caseObj.Id)<>null){
                            if(COA_conMap.get(caseObj.Id).contains(u.ContactId)){
                                if(u.Alias<>null){
                                    aliasCOAMap.put(caseObj.Id, u.Alias);
                                }
                            }
                        }
                    }
                }
            }
        }   
        //End: D-2075 02/25/2014 Added by S.Puli
        //START: D-1961
        //Get Account objects         
        accountList = [SELECT Id, RecordTypeId, Email__c, Vendor_Communication_Preference__c, RecordType.Name FROM Account WHERE Id IN: accountIdSet];//Start/End: UD-0982 05/06/2015 Added by MGaelo
        for(Account acc:accountList){
            accountMap.put(acc.Id, acc);
        }
        //END: D-1961    

        //Get Cases and related Subscriptions
        caseSubscriptionList = [SELECT Id, Case__c, Subscription__c, Case__r.RecordTypeId FROM Case_Subscription__c WHERE Case__c IN: caseIdSet];//Start/End: D-2184 03/17/2014 Added by S.Puli
        //START: D-3130 18/06/2015 Added by S.Puli
        Map<Id, Set<Id>> caseToSubs_MAP = new Map<Id, Set<Id>>();
        Set<Id> coaSubIds_SET = new Set<Id>();
        boolean coaBoolean = false;
        //START: D-3140 20/06/2015 Added by S.Puli
        Map<Id, Map<Id,boolean>> coaToKeyIdentifier_MAP = new Map<Id, Map<Id,boolean>>();
        ID COA_ID = ConstantsSLB.getKeyId('Case_Change in Address');
        //END: D-3140 20/06/2015 Added by S.Puli
        if(caseSubscriptionList.size()>0){
            for(Case_Subscription__c caseSubObj : caseSubscriptionList){
                subscriptionIdSet.add(caseSubObj.Subscription__c);
                List<Case_Subscription__c> caseSubscriptionTempList = case_caseSubscriptionMap.get(caseSubObj.Case__c);
                if(caseSubscriptionTempList == null){
                    caseSubscriptionTempList = new List<Case_Subscription__c>();
                }
                caseSubscriptionTempList.add(caseSubObj);
                case_caseSubscriptionMap.put(caseSubObj.Case__c,caseSubscriptionTempList);
                //START: D-3140 20/06/2015 Added by S.Puli
                if(caseSubObj.Case__r.RecordTypeId == COA_ID){
                //END: D-3140 20/06/2015 Added by S.Puli
                    coaSubIds_SET.add(caseSubObj.Subscription__c);
                    if(!caseToSubs_MAP.containsKey(caseSubObj.Case__c)){
                        caseToSubs_MAP.put(caseSubObj.Case__c, new Set<Id>{caseSubObj.Subscription__c});
                    }
                    else{
                        caseToSubs_MAP.get(caseSubObj.Case__c).add(caseSubObj.Subscription__c);
                    }
                }
            }
            if(coaSubIds_SET.size()>0){
        //START UD-2016 10-Aug-2015 Added By S.Puli
        //START D-3388 11-Sept-2015 Added By S.Puli
                for(Case_Subscription__c csRec : [Select Id, Case__c, Subscription__c, Case__r.RecordTypeId, Case__r.Temp_Stop_Date__c, Case__r.Temp_Stop__r.Temp_Stop_Status__c, Case__r.Restart_Date__c, Case__r.COA__c from Case_Subscription__c Where Subscription__c IN :coaSubIds_SET AND Case__r.RecordTypeId = :ConstantsSLB.getKeyId('Case_Temp Stop') AND Case__r.COA__c = true AND Case__r.Temp_Stop__r.Temp_Stop_Status__c <> :GlobalVariableClass.TS_STATUS_CANCELLED]){
        //END UD-2016 10-Aug-2015 Added By S.Puli
                    //system.debug('csRec>>'+csRec);
                    if(csRec.Case__r.Temp_Stop_Date__c == date.today()+1){
                        if(caseToSubs_MAP.size()>0){
                        //START: D-3140 20/06/2015 Added by S.Puli
                            for(Id caseId : caseToSubs_MAP.keyset()){  
                                for(Id subId : caseToSubs_MAP.get(caseId)){
                                    coaBoolean = false;
                                    if(subId == csRec.Subscription__c){
                                        coaBoolean = true;
                                    }
                                    //START UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                    if(coaToKeyIdentifier_MAP.containsKey(caseId)){
                                        if(coaToKeyIdentifier_MAP.get(caseId).containsKey(subId)){
                                            if(coaToKeyIdentifier_MAP.get(caseId).get(subId) == false){//do this if identifier is FALSE
                                                coaToKeyIdentifier_MAP.get(caseId).put(subId, coaBoolean);
                                            }
                                        }else{
                                            coaToKeyIdentifier_MAP.get(caseId).put(subId, coaBoolean);
                                        }
                                    }else{
                                        coaToKeyIdentifier_MAP.put(caseId, new Map<Id, boolean>{subId=>coaBoolean});
                                    }
                                    //END UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                } 
                            }
                        }
                    }
                    if(csRec.Case__r.Restart_Date__c == date.today()+1){
                        if(caseToSubs_MAP.size()>0){
                            for(Id caseId : caseToSubs_MAP.keyset()){  
                                for(Id subId : caseToSubs_MAP.get(caseId)){
                                    coaBoolean = false;
                                    if(subId == csRec.Subscription__c){
                                        coaBoolean = true;
                                    }
                                    //START UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                    if(coaWithTempRestartTom.containsKey(caseId)){
                                        if(coaWithTempRestartTom.get(caseId).containsKey(subId)){
                                            if(coaWithTempRestartTom.get(caseId).get(subId) == false){//do this if identifier is FALSE
                                                coaWithTempRestartTom.get(caseId).put(subId, coaBoolean);
                                            }
                                        }
                                        else{
                                            coaWithTempRestartTom.get(caseId).put(subId, coaBoolean);
                                        }
                                    }else{
                                        coaWithTempRestartTom.put(caseId, new Map<Id, boolean>{subId=>coaBoolean});
                                    }
                                    //END UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                } 
                            }
                        }
                    }
                    if(csRec.Case__r.Restart_Date__c > date.today()+1 && csRec.Case__r.Temp_Stop_Date__c < date.today()+1){
                        if(caseToSubs_MAP.size()>0){
                            for(Id caseId : caseToSubs_MAP.keyset()){  
                                for(Id subId : caseToSubs_MAP.get(caseId)){
                                    coaBoolean = false;
                                    if(subId == csRec.Subscription__c){
                                        coaBoolean = true;
                                    }
                                    //START UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                    if(coaInBetwnTStop.containsKey(caseId)){
                                        if(coaInBetwnTStop.get(caseId).containsKey(subId)){
                                            if(coaInBetwnTStop.get(caseId).get(subId) == false){//do this if identifier is FALSE
                                                coaInBetwnTStop.get(caseId).put(subId, coaBoolean);
                                            }
                                        }
                                        else{
                                            coaInBetwnTStop.get(caseId).put(subId, coaBoolean);
                                        }
                                    }else{
                                        coaInBetwnTStop.put(caseId, new Map<Id, boolean>{subId=>coaBoolean});
                                    }
                                    //END UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                } 
                            }
                        }
                    }
                    //END: D-3140 20/06/2015 Added by S.Puli
                }
                //END D-3388 11-Sept-2015 Added By S.Puli
            }
        }
        //END: D-3130 18/06/2015 Added by S.Puli
        
        //Get Subscriptions  
        //START D-2075 02/25/2015 S.Puli - add Urgent_1__c
        //Start: MD-54 03/12/2015 Jason Abolac
    //Start: D-2184 03/17/2014 Added by S.Puli
    //Start: UD-0982 05/05/2014 Added by MGaelo
        //START UD-0289 AddedBy FrancisBenzon : added query field and new logic
        //START D-2913 05/18/2015 Jason A./Sherwin P.
        //START: D-3118 18/06/2015 Added by S.Puli
        //Start UD-3057 09-Oct-2015 Added by S.Puli - add filter to include subscriptions delivered by Vendor only
        //START UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
        //START UD-3170 05-Nov-2015 Added by S.Puli
        subscriptionList = [SELECT Id, Name, Subscriber_Contact__c, Recipient_Contact__c, Recipient_Contact__r.FirstName, 
                            Recipient_Contact__r.LastName, Vendor_1__r.Id, Frequency_1__c, Vendor_1__r.Handphone_Number__c,Ph_d__c, Ph_e__c,
                            Number_of_Copies__c, Vendor_1__r.Email__c, Effective_End_Date__c, Vendor_1__r.Vendor_Communication_Preference__c,
                            Effective_Start_Date__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Vendor_1__r.Active__c,
                            Vendor_Subscription_To_Convert_1__c, Classification__c, Order_Number_1__r.Vendor_Sms_Remarks__c, Urgent_1__c, Order_Line_Item_Number_1__r.Based_Order_Line_Item__c, Main_Package_1__c, Vendor_1__r.RecordType.Name, Order_Line_Item_Number_1__r.Vendor_Conversion__c,
                            Delivered_By_1__c, Order_Line_Item_Number_1__r.Supressed_Vendor_Notification_New_Sub__c, Order_Line_Item_Number_1__r.Suppress_Vendor_Start_notice__c ,
                            Recipient_Contact__r.Address__r.Postal_Code__r.Name 
                            FROM Zuora__Subscription__c WHERE Id IN:subscriptionIdSet AND Delivered_By_1__c = :GlobalVariableClass.VENDOR];
        //END UD-3170 05-Nov-2015 Added by S.Puli
        Set<Id> validSubIds = new Set<Id>();
        if(subscriptionList.size()>0){
            for(Zuora__Subscription__c subRec : subscriptionList){
                if(subRec.Zuora__SubscriptionEndDate__c == date.today()){
                    validSubIds.add(subRec.Id);
                }
            }
        }
        List<Order_Line_Item__c> oliForStopSubs = new List<Order_Line_Item__c>();
        Map<Id, boolean> subsToSuppressKey = new Map<Id, boolean>();
        if(validSubIds.size() > 0){
            oliForStopSubs = [Select Id, Subscription__c, Suppress_Notification_Stop__c From Order_Line_Item__c Where Subscription__c IN :validSubIds];
            if(oliForStopSubs.size()>0){
                for(Order_Line_Item__c oliRec : oliForStopSubs){
                    if(!subsToSuppressKey.containsKey(oliRec.Subscription__c)){
                        subsToSuppressKey.put(oliRec.Subscription__c, oliRec.Suppress_Notification_Stop__c);
                    }
                }
            }
        }
        //END UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
        //END UD-3057 09-Oct-2015 Added by S.Puli
        //END: D-3118 18/06/2015 Added by S.Puli
        //END D-2913 05/18/2015 Jason A./Sherwin P.
                //END: UD-0982 05/05/2014 Added by MGaelo
                //End: D-2184 03/17/2014 Added by S.Puli
        //End: MD-54 03/12/2015 Jason Abolac                    
        //END D-2075 02/25/2015 S.Puli              
        Set<Id> startPackIds = new Set<Id>();
        Map<Id, Package_Item__c> startPackToPackItemsMap = new Map<Id, Package_Item__c>();
        for(Zuora__Subscription__c sublist : subscriptionList)
        {   
            startPackIds.add(sublist.Main_Package_1__c);
        }
        //Start 07/13/2015 UD-1849 removed by Jason A./Alyana N.
        //Start UD-3552 11-Jan-2016 Added By S.Puli
        List<Package_Item__c> startPackageItems = [Select Id, Is_Print__c,  Is_All_In_One__c, Is_Digital_2__c, Package__c
                                                    From Package_Item__c 
                                                    Where Package__c IN :startPackIds
                                                    AND (RecordTypeId = :ConstantsSLB.getKeyId('Package Item_Base Product') 
                                                    OR RecordTypeId = :ConstantsSLB.getKeyId('Package Item_Bundle Product')) 
                                                    AND (Product_Platform__c = :GlobalVariableClass.PLATFORM_PRINT 
                                                    OR Product_Platform__c = :GlobalVariableClass.PLATFORM_AIO)];
        //End UD-3552 11-Jan-2016 Added By S.Puli
        //END 07/13/2015 UD-1849 removed by Jason A./Alyana N.
        for(Package_Item__c pItem : startPackageItems)
        {
            startPackToPackItemsMap.put(pItem.Package__c, pItem);
        }
        //END UD-0289 AddedBy FrancisBenzon
        
        List<Zuora__SubscriptionProductCharge__c> mySPCList = new List<Zuora__SubscriptionProductCharge__c>();
        //Start: D-2184 03/17/2014 Added by S.Puli
        Set<Id> COS_Subs_Set = new set<Id>();
        
        if(caseSubscriptionList.size()>0 && caseSubscriptionList<>null){
            for(Case_Subscription__c cs : caseSubscriptionList){
                //START/END UD-0289 AddedBy FrancisBenzon : casted string to id
                if(cs.Case__r.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription')){
                    COS_Subs_Set.add(cs.Subscription__c);
                }
            }
        }

    //START UD-3126 12-Nov-2015 Added By S.Puli
    Set<Id> newSubsId_SET = new Set<Id>();
    Map<Id, Zuora__Subscription__c> newSubIdToRecord = new Map<Id, Zuora__Subscription__c>();
    Map<Id, Zuora__Subscription__c> oldSubIdToRecord = new Map<Id, Zuora__Subscription__c>();
    //END UD-3126 12-Nov-2015 Added By S.Puli
        //START UD-0289 AddedBy FrancisBenzon : added fields to be queried 
        //Start UD-3057 09-Oct-2015 Added by S.Puli - add filter to include subscriptions delivered by vendor only
        //START UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
        List<Zuora__Subscription__c> subscription_COS_List = [SELECT Id, Name, Subscriber_Contact__c, Recipient_Contact__c, 
                    Recipient_Contact__r.FirstName, Recipient_Contact__r.LastName, Vendor_1__r.Id, Frequency_1__c, Vendor_1__r.Handphone_Number__c,
                            Number_of_Copies__c, Vendor_1__r.Email__c, Effective_End_Date__c, Main_Package_1__c,
                            Effective_Start_Date__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, 
                            Vendor_Subscription_To_Convert_1__c, Classification__c, Order_Number_1__r.Vendor_Sms_Remarks__c, Urgent_1__c, Order_Line_Item_Number_1__r.Based_Order_Line_Item__c, Zuora__Status__c, Ph_d__c, Ph_e__c, Delivered_By_1__c, Order_Line_Item_Number_1__r.Supressed_Vendor_Notification_New_Sub__c,
                            Order_Line_Item_Number_1__r.Suppress_Vendor_Start_notice__c 
                            FROM Zuora__Subscription__c WHERE Id IN :COS_Subs_Set AND Zuora__Status__c = 'Active' AND Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION AND Delivered_By_1__c = :GlobalVariableClass.VENDOR];    //Start - End: D-2549 03/24/15 Jason Abolac
        //END UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
        //End UD-3057 09-Oct-2015 Added by S.Puli
        //END UD-0289 AddedBy FrancisBenzon : added fields to be queried 
        Set<Id> COA_OLI_Set = new  Set<Id>();
        Map<Id, Id> COS_newSubToOldSub = new Map<Id, Id>();
        Map<Id, Id> COS_OldOLI_To_NewSubs_MAP = new Map<Id, Id>();


        if(subscription_COS_List.size()>0 && subscription_COS_List<>null){
            for(Zuora__Subscription__c subs : subscription_COS_List){
        //START UD-3126 12-Nov-2015 Added By S.Puli
        newSubIdToRecord.put(subs.Id, subs);
        //END UD-3126 12-Nov-2015 Added By S.Puli
                if(subs.Order_Line_Item_Number_1__c<>null){
                    if(subs.Order_Line_Item_Number_1__r.Based_Order_Line_Item__c <> null){
                        COA_OLI_Set.add((id)subs.Order_Line_Item_Number_1__r.Based_Order_Line_Item__c);
                        COS_OldOLI_To_NewSubs_MAP.put(subs.Order_Line_Item_Number_1__r.Based_Order_Line_Item__c, subs.Id);
            //START UD-3126 12-Nov-2015 Added By S.Puli
            newSubsId_SET.add(subs.Id);
            //END UD-3126 12-Nov-2015 Added By S.Puli
                    }
                }
            }
        }
        //START UD-0289 AddedBy FrancisBenzon : added fields to be queried 
        List<Zuora__Subscription__c> subscription_COS_Cancelled_List = [SELECT Id, Name, Subscriber_Contact__c, Recipient_Contact__c, Recipient_Contact__r.FirstName, Recipient_Contact__r.LastName, Vendor_1__r.Id, Frequency_1__c, Vendor_1__r.Handphone_Number__c,
                            Number_of_Copies__c, Vendor_1__r.Email__c, Effective_End_Date__c, Ph_d__c, Ph_e__c, Main_Package_1__c,
                            Effective_Start_Date__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, 
                            Vendor_Subscription_To_Convert_1__c, Classification__c, Order_Number_1__r.Vendor_Sms_Remarks__c, Urgent_1__c, Order_Line_Item_Number_1__r.Based_Order_Line_Item__c, Zuora__Status__c, Order_Line_Item_Number_1__c
                            FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c IN :COA_OLI_Set AND Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION];    //Start - End: D-2549 03/24/15 Jason Abolac
        //END UD-0289 AddedBy FrancisBenzon : added fields to be queried 
        Set<Id> COS_Cancelled_SET = new Set<Id>();
        //START/END UD-0289 AddedBy FrancisBenzon : reaarranged checking
        if(subscription_COS_Cancelled_List <> null && subscription_COS_Cancelled_List.size()>0){
            for(Zuora__Subscription__c COAsubs : subscription_COS_Cancelled_List){  
        //START UD-3126 12-Nov-2015 Added By S.Puli
        oldSubIdToRecord.put(COAsubs.Id, COAsubs);
        //END UD-3126 12-Nov-2015 Added By S.Puli
                COS_Cancelled_SET.add((id)COAsubs.Id);
                COS_newSubToOldSub.put(COS_OldOLI_To_NewSubs_MAP.get(COAsubs.Order_Line_Item_Number_1__c), COAsubs.Id);
                //START UD-0289 AddedBy FrancisBenzon START UD-0289 AddedBy FrancisBenzon
                packageIdSet.add(COAsubs.Main_Package_1__c);
                //END UD-0289 AddedBy FrancisBenzon START UD-0289 AddedBy FrancisBenzon
            }
            //Start 07/13/2015 UD-1849 removed by Jason A./Alyana N.
            //START UD-0289 AddedBy FrancisBenzon 
            //Start UD-3552 11-Jan-2016 Added By S.Puli
            baseProdPackItemList = [Select Id, Is_Print__c, Is_All_In_One__c, Is_Digital_2__c, Package__c, Product_Platform__c
                                    From Package_Item__c 
                                    Where Package__c IN :packageIdSet
                                    AND (RecordTypeId = :ConstantsSLB.getKeyId('Package Item_Base Product') OR RecordTypeId = :ConstantsSLB.getKeyId('Package Item_Bundle Product')) 
                                    AND (Product_Platform__c = :GlobalVariableClass.PLATFORM_PRINT OR Product_Platform__c = :GlobalVariableClass.PLATFORM_AIO)];
            //End UD-3552 11-Jan-2016 Added By S.Puli
            //END 07/13/2015 UD-1849 removed by Jason A./Alyana N.
            if(baseProdPackItemList != null && !baseProdPackItemList.isEmpty())
            {
                for(Package_Item__c pItem : baseProdPackItemList)
                {
                    packagePackItemsMap.put(pItem.Package__c, pItem);
                }
            }
            //END UD-0289 AddedBy FrancisBenzon 
        }
        //Start UD-1345 06/04/2015 Added By Jason A. 
        //START UD-3126 12-Nov-2015 Added By S.Puli
        List<Zuora__SubscriptionProductCharge__c> COS_subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        if(COS_Cancelled_SET.size() > 0 || newSubsId_SET.size() > 0){
            COS_subProdChargeList = [SELECT Zuora__Subscription__c, Zuora__UOM__c, Zuora__RatePlanName__c, PublicationCode__c FROM Zuora__SubscriptionProductCharge__c WHERE (Zuora__Subscription__c IN: COS_Cancelled_SET OR Zuora__Subscription__c IN :newSubsId_SET)];
        }
        //End UD-1345 06/04/2015 Added By Jason A. 
        Map <id, List<Zuora__SubscriptionProductCharge__c>> COS_subToSPC = new Map <id, List<Zuora__SubscriptionProductCharge__c>>(); 
         
        if(COS_subProdChargeList != null && COS_subProdChargeList.size()>0){       
            for(Zuora__SubscriptionProductCharge__c subProdCharge: COS_subProdChargeList){
                if(COS_Cancelled_SET.contains(subProdCharge.Zuora__Subscription__c)){
                    if (COS_subToSPC.containskey(subProdCharge.Zuora__Subscription__c)) {
                        COS_subToSPC.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge);
        
                    }
                    else {
                        COS_subToSPC.put(subProdCharge.Zuora__Subscription__c, new List <Zuora__SubscriptionProductCharge__c> {subProdCharge});
                    }    
                  
                    COS_subProdChargeMap.put(subProdCharge.Zuora__Subscription__c, subProdCharge);
                }
            }
        }
        
        Map<Id, Set<String>> oldSubToSpc = new Map<Id, Set<String>>();
        Map<Id, Set<String>> newSubToSpc = new Map<Id, Set<String>>();
        Set<Id> nonProvisioningCOS = new Set<Id>();
        if(COS_subProdChargeList.size()>0){
            for(Zuora__SubscriptionProductCharge__c oldSpc : COS_subProdChargeList){
                if(COS_Cancelled_SET.contains(oldSpc.Zuora__Subscription__c)){
                    if(oldSpc.PublicationCode__c <> null && oldSpc.Zuora__Subscription__c <> null){
                        if(!oldSubToSpc.containsKey(oldSpc.Zuora__Subscription__c)){
                            oldSubToSpc.put(oldSpc.Zuora__Subscription__c, new Set<String>{oldSpc.PublicationCode__c});
                        }else{
                            oldSubToSpc.get(oldSpc.Zuora__Subscription__c).add(oldSpc.PublicationCode__c);
                        }
                    }
                }else if(newSubsId_SET.contains(oldSpc.Zuora__Subscription__c)){
                    if(oldSpc.PublicationCode__c <> null && oldSpc.Zuora__Subscription__c <> null){
                        if(!newSubToSpc.containsKey(oldSpc.Zuora__Subscription__c)){
                            newSubToSpc.put(oldSpc.Zuora__Subscription__c, new Set<String>{oldSpc.PublicationCode__c});
                        }else{
                            newSubToSpc.get(oldSpc.Zuora__Subscription__c).add(oldSpc.PublicationCode__c);
                        }
                    }
                }
            }
        }
        
        if(subscription_COS_List.size() > 0){
            for(Zuora__Subscription__c newSubs : subscription_COS_List){
                if(COS_newSubToOldSub.containsKey(newSubs.Id)){
                    if(oldSubIdToRecord.containsKey(COS_newSubToOldSub.get(newSubs.Id))){
                        Zuora__Subscription__c oldSubRec = oldSubIdToRecord.get(COS_newSubToOldSub.get(newSubs.Id));
                        boolean provisionKey = false;
                        provisionKey = checkForNonProvision(newSubs, oldSubRec, newSubToSpc, oldSubToSpc, publicationMap, noSundayPubMap);
                        if(provisionKey){
                            nonProvisioningCOS.add(newSubs.Id);
                        }
                    }
                }
            }
        }
        
        //END UD-3126 12-Nov-2015 Added By S.Puli
        //Get details for cancelled subscription cosSubToDetailMAP<old sub - to - Detail>, COS_newSubToOldSub <oldsub - to - newSub>
        Map<Id, String> cosSubToDetailMAP = new Map<Id, String>();
        //START/END UD-0289 5/18 AddedBy FrancisBenzon : inverted checking so that null will be checked first
        if(subscription_COS_Cancelled_List <> null && subscription_COS_Cancelled_List.size()>0){
            for(Zuora__Subscription__c eachSubs : subscription_COS_Cancelled_List){
                //START UD-0289 AddedBy FrancisBenzon 
                if(eachSubs.Ph_d__c)
                {
                    phD = string.valueOf(eachSubs.Number_of_Copies__c).substringBefore('.');
                }               
                if(eachSubs.Ph_e__c) 
                {
                    phE = string.valueOf(eachSubs.Number_of_Copies__c).substringBefore('.');
                }               
                //END UD-0289 AddedBy FrancisBenzon 
                if (COS_subProdChargeList != null) {
                     pubCode.clear();
                     //START UD-0289 AddedBy FrancisBenzon : checking
                    if(COS_subToSPC.get(eachSubs.Id) != null && !COS_subToSPC.get(eachSubs.Id).isEmpty())
                    {
                        for(Zuora__SubscriptionProductCharge__c spc: COS_subToSPC.get(eachSubs.Id)){
        //Start UD-1345 06/04/2015 Added By Jason A. 
                            if (spc.PublicationCode__c != null && (spc.Zuora__UOM__c == 'Copy Weekday' || spc.Zuora__UOM__c == 'Copy Sat' || spc.Zuora__UOM__c == 'Copy Sun')) {
        //End UD-1345 06/04/2015 Added By Jason A. 
                             pubCode.add(spc.PublicationCode__c);
                             //START UD-0289 AddedBy FrancisBenzon
                             pubCode.remove(null);
                             //END UD-0289 AddedBy FrancisBenzon
                            }  
                        }
                    }
                    //END UD-0289 AddedBy FrancisBenzon : checking
                     details.clear();
                      myCounter = 1;
                     for (string eachPubCode: pubCode) {
                     myCounter = myCounter +1;
                        
                        if (publicationMap.containskey(eachPubCode)) {
                            
                            Publication__c pub = new Publication__c();
                            pub = publicationMap.get(eachPubCode);
                            // START : UD-0985 7/6/2015 Alyana Navarro
                                                                                
                            if (details.containskey(pub.Sunday_Publication__r.Publication_Code__c)) {                                   
                                if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQUENCY_DEFAULT 
                                        || eachSubs.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_FRISUN 
                                        || eachSubs.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_SATSUN){
                                    sub = string.valueOf(eachPubCode) + '/' + sub;
                                    //START D-2392 02/25/2015 S.Puli - Email notification for change of address
                                    details.put(pub.Sunday_Publication__r.Publication_Code__c, sub);
                                    //End D-2392 02/25/2015 S.Puli - Email notification for change of address
                                } else if(eachSubs.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_MONFRI || eachSubs.Frequency_1__c == GlobalVariableClass.FREQUENCY_MONSAT){
                                    sub = string.valueOf(eachPubCode);
                                    details.put(pub.Sunday_Publication__r.Publication_Code__c, sub);                                    
                                }
                            } else {
                                sub = '';
        //Start UD-1345 06/04/2015 Added By Jason A. 
                                if(pub.Sunday_Publication__c == null ){
                                        sub = string.valueOf(eachPubCode);
                                    }else{
                                        if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQUENCY_DEFAULT 
                                            || eachSubs.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_FRISUN 
                                            || eachSubs.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_SATSUN){
                                            sub = string.valueOf(eachPubCode) + '/' + pub.Sunday_Publication__r.Publication_Code__c;
                                        } else if(eachSubs.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_MONFRI || eachSubs.Frequency_1__c == GlobalVariableClass.FREQUENCY_MONSAT) {
                                            sub = string.valueOf(eachPubCode);
                                        }                                        
                                    }
                            // END : UD-0985 7/6/2015 Alyana Navarro
        //End UD-1345 06/04/2015 Added By Jason A. 
                                if(eachSubs != null){
                                    string numOfCopy = '';
                                    //START UD-0289 AddedBy FrancisBenzon START UD-0289 AddedBy FrancisBenzon
                                    //START UD-0289 5/19/15 AddedBy FrancisBenzon : added checking to avoid null pointers
                                    try
                                                //START UD-1820 and UD-1823 07/1015 AddedBy Jason A : Notification
                                    {
                                    numOfCopy = string.valueOf(eachSubs.Number_of_Copies__c).substringBefore('.');
                                        if(packagePackItemsMap.containsKey(eachSubs.Main_Package_1__c))
                                        {
                                //START 07/13/2015 UD-1849 removed by Jason A./Alyana N.
                                            if(packagePackItemsMap.get(eachSubs.Main_Package_1__c).Is_Print__c || packagePackItemsMap.get(eachSubs.Main_Package_1__c).Is_All_In_One__c)
                                //END 07/13/2015 UD-1849 removed by Jason A./Alyana N.
                                            {
                                                if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT)
                                                {    
                                                    freqDef = pub.Published_Days__c.replace('Y', numOfCopy);  
                                                    freq = freqDef.replace('N', '0') + phD + phE;                                     
                                                }
                                                else if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_MONFRI) 
                                                {
                                                    freq = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + '0' + numOfCopy + '0';
                                                }
                                                else if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_MONSAT)
                                                {
                                                    freq = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + numOfCopy + numOfCopy;
                                                }
                                                else if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_SATSUN)
                                                {
                                                    freq = '0' + '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + '0' + numOfCopy;
                                                }
                                                else if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_FRISUN)
                                                {
                                                    freq = '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy;
                                                }                                      
                                                //START: UD-0798 18/06/2015 Added by S.Puli
                                                if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c <> null && pub.Published_Days__c == 'YYYYYYN'){
                                //START UD-2016 27-July-2015 Added By S.Puli
                                //START UD-2117 26-Aug-2015 Added By J.Abolac
                                                        freq = freq.substring(0, freq.length() - ((2*(numOfCopy.length()))+1));
                                                        freq += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.DAILY +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c <> null && pub.Published_Days__c == 'NNNNYYN'){
                                                        freq = freq.substring(0, freq.length() - ((2*(numOfCopy.length()))+1));
                                                        freq += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c <> null && pub.Published_Days__c == 'NNNNNYN'){
                                                        freq = freq.substring(0, freq.length() - ((1*(numOfCopy.length()))+2));
                                                        freq += numOfCopy + '0' + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq +') ';    
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'YYYYYYY'){
                                                        freq = freq.substring(0, freq.length() - ((3*(numOfCopy.length()))));
                                                        freq += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.DAILY +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'YYYYYNN'){
                                                        //Start D-4729 26-Apr-2016 Added by S.Puli
                                                        //freq = freq.substring(0, freq.length() - ((1*(numOfCopy.length()))+2));
                                                        freq = freq.substring(0, ((5*(numOfCopy.length()))+1));
                                                        //Start UD-3457 26-Jan-2016 Added By S.Puli
                                                        freq += '0' + numOfCopy + '0';
                                                        //End UD-3457 26-Jan-2016 Added By S.Puli
                                                        //End D-4729 26-Apr-2016 Added by S.Puli
                                                        sub += ' ('+GlobalVariableClass.FREQ_MONFRI +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'NNNNYYY'){
                                                        freq = freq.substring(0, freq.length() - ((3*(numOfCopy.length()))));
                                                        freq += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'NNNNNYY'){
                                                        freq = freq.substring(0, freq.length() - ((2*(numOfCopy.length()))+1));
                                                        freq += numOfCopy + '0' + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'YYYYYYN'){
                                                        freq = freq.substring(0, freq.length() - ((2*(numOfCopy.length()))+1));
                                                        freq += '0' + numOfCopy + numOfCopy;
                                //EDIT UD-2016 27-July-2015 Added By S.Puli
                                //END UD-2117 26-Aug-2015 Added By J.Abolac
                                                        sub += ' ('+GlobalVariableClass.FREQ_MONSAT +'>'+freq +') ';
                                                    } else{
                                                        sub += ' ('+string.valueOf(eachSubs.Frequency_1__c)+'>'+freq +') ';
                                                    }
                                                //END: UD-0798 18/06/2015 Added by S.Puli
                                                //END UD-1820 and UD-1823 07/1015 AddedBy Jason A : Notification
                                            }
                                            /*
                                            else
                                            {
                                                //START: UD-0798 18/06/2015 Added by S.Puli
                                                if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT ){
                                                    sub += ' ('+GlobalVariableClass.DAILY+'>'+string.valueOf(eachSubs.Number_of_Copies__c).substringBefore('.')+') ';
                                                } else{
                                                    sub += ' ('+string.valueOf(eachSubs.Frequency_1__c)+'>'+string.valueOf(eachSubs.Number_of_Copies__c).substringBefore('.')+') ';//START/END: D-2522 03/18/2014 Added by S.Puli 
                                                }
                                                //END: UD-0798 18/06/2015 Added by S.Puli
                                            }
                                            */
                                        }
                                    }
                                    catch(exception e)
                                    {
                                        
                //START UD-3158 28-Nov-2015 Added By S.Puli
                exceptionList.add(e);
                //END UD-3158 28-Nov-2015 Added By S.Puli
                                    }
                                }
                                    //END UD-0289 5/19/15 AddedBy FrancisBenzon : added checking to avoid null pointers                                   
                                    //END UD-0289 AddedBy FrancisBenzon START UD-0289 AddedBy FrancisBenzon
                                
                                    //START UD-0289 AddedBy FrancisBenzon
                                    //START D-2913 05/18/2015 Jason A./Sherwin P.
                                                        //details.put(pub.Publication_Code__c, sub);
                                    details.put(pub.Sunday_Publication__r.Publication_Code__c, sub);
                                    //START D-2913 05/18/2015 Jason A./Sherwin P.
                                    //END UD-0289 AddedBy FrancisBenzon
                            }
                        }
                        else { // if pub code has no look up publication
                            if (!details.containskey(eachPubCode)) {
                                 sub = '';
                                 sub = string.valueOf(eachPubCode);
                                
                                //START UD-0289 AddedBy FrancisBenzon : published Days Conversion
                                //START D-2999 05/20/2015 Added By S.Puli
                                //List<Publication__c> thisPub = [Select Published_Days__c, Publish_Pattern__c, Sunday_Publication__c From Publication__c Where Publication_Code__c = :eachPubCode limit 1];
                                List<Publication__c> thisPub = new List<Publication__c>();
                                thisPub.add(noSundayPubMap.get(eachPubCode));
                                //END D-2999 05/20/2015 Added By S.Puli
                                 if(eachSubs != null){                                  
                                    string numOfCopy = '';                                 
                                    if(eachSubs.Number_of_Copies__c <> null && eachSubs.Frequency_1__c <> null){   
                                        //START UD-0289 5/19/15 AddedBy FrancisBenzon : added checking to avoid null pointers   
                                        try
                                                //START UD-1820 and UD-1823 07/1015 AddedBy Jason A : Notification
                                        {
                                        //Start UD- 1987 07/24/2015 Added by : Jason A
                                        numOfCopy = string.valueOf(eachSubs.Number_of_Copies__c).substringBefore('.');
                                            if(packagePackItemsMap.containsKey(eachSubs.Main_Package_1__c))
                                            {
                                                if(packagePackItemsMap.get(eachSubs.Main_Package_1__c).Is_Print__c || packagePackItemsMap.get(eachSubs.Main_Package_1__c).Is_All_In_One__c)
                                                {                                           
                                                    if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT)
                                                    {
                                                        freqDef = thisPub[0].Published_Days__c.replace('Y', numOfCopy);
                                                        freq = freqDef.replace('N', '0') + phD + phE;
                                                    }
                                                    else if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_MONFRI) 
                                                    {
                                                        freq = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + '0' + numOfCopy + '0';
                                                    }
                                                    else if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_MONSAT)
                                                    {
                                                        freq = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + numOfCopy + numOfCopy;
                                                    }
                                                    else if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_SATSUN)
                                                    {
                                                        freq = '0' + '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + '0' + numOfCopy;
                                                    }
                                                    else if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_FRISUN)
                                                    {
                                                        freq = '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy;
                                                    }
                                                    //logic for binary 
                                                    //START: UD-0798 18/06/2015 Added by S.Puli
                                //START UD-2016 27-July-2015 Added By S.Puli 
                                //START UD-2117 26-Aug-2015 Added By J.Abolac
                                                    if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c <> null && thisPub[0].Published_Days__c == 'YYYYYYN'){
                                                        freq = freq.substring(0, freq.length() - ((2*(numOfCopy.length()))+1));
                                                        freq += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.DAILY +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c <> null && thisPub[0].Published_Days__c == 'NNNNYYN'){
                                                        freq = freq.substring(0, freq.length() - ((2*(numOfCopy.length()))+1));
                                                        freq += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c <> null && thisPub[0].Published_Days__c == 'NNNNNYN'){
                                                        freq = freq.substring(0, freq.length() - ((1*(numOfCopy.length()))+2));
                                                        freq += numOfCopy + '0' + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq +') ';    
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'YYYYYYY'){
                                                        freq = freq.substring(0, freq.length() - ((3*(numOfCopy.length()))));
                                                        freq += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.DAILY +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'YYYYYNN'){
                                                        //Start D-4729 26-Apr-2016 Added by S.Puli
                                                        //freq = freq.substring(0, freq.length() - ((1*(numOfCopy.length()))+2));
                                                        freq = freq.substring(0, ((5*(numOfCopy.length()))+1));
                                                        //Start UD-3457 26-Jan-2016 Added By S.Puli
                                                        freq += '0' + numOfCopy + '0';
                                                        //End UD-3457 26-Jan-2016 Added By S.Puli
                                                        //End D-4729 26-Apr-2016 Added by S.Puli
                                                        sub += ' ('+GlobalVariableClass.FREQ_MONFRI +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'NNNNYYY'){
                                                        freq = freq.substring(0, freq.length() - ((3*(numOfCopy.length()))));
                                                        freq += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'NNNNNYY'){
                                                        freq = freq.substring(0, freq.length() - ((2*(numOfCopy.length()))+1));
                                                        freq += numOfCopy + '0' + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq +') ';
                                                    }else if (eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'YYYYYYN'){
                                                        freq = freq.substring(0, freq.length() - ((2*(numOfCopy.length()))+1));
                                                        freq += '0' + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_MONSAT +'>'+freq +') ';
                                                    } else{
                                                        sub += ' ('+string.valueOf(eachSubs.Frequency_1__c)+'>'+freq +') ';
                                                    }
                                //END UD-2117 26-Aug-2015 Added By J.Abolac
                                //END UD-2016 27-July-2015 Added By S.Puli 
                                                    //END: UD-0798 18/06/2015 Added by S.Puli
                                                    //END UD-1820 and UD-1823 07/1015 AddedBy Jason A : Notification
                                                }
                                                /*
                                                else
                                                {   
                                                    numOfCopy = string.valueOf(eachSubs.Number_of_Copies__c).substringBefore('.');
                                                    //START: UD-0798 18/06/2015 Added by S.Puli
                                                    if(eachSubs.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT){
                                                        sub += ' ('+GlobalVariableClass.DAILY+'>'+freq +'>'+numOfCopy+') ';
                                                    } else{
                                                        sub += ' ('+string.valueOf(eachSubs.Frequency_1__c)+'>'+numOfCopy+') '; 
                                                    }
                                                    //END: UD-0798 18/06/2015 Added by S.Puli
                                                }
                                                */
                                            }
                                        }
                                        catch(Exception e)
                                        {
                                           
                       //START UD-3158 28-Nov-2015 Added By S.Puli
                       exceptionList.add(e);
                       //END UD-3158 28-Nov-2015 Added By S.Puli
                                        }
                                    }
                                    //END UD-0289 5/19/15 AddedBy FrancisBenzon : added checking to avoid null pointers                                                                        
                                     
                                        //END D-2075 02/25/2015 S.Puli
                                 }
                                if(thisPub[0].Publish_Pattern__c != GlobalVariableClass.CREATEVENDORSTART_WEEKEND && thisPub[0].Sunday_Publication__c == null)
                                {
                                    details.put(eachPubCode, sub);
                                }
                                //END UD-0289 AddedBy FrancisBenzon : published Days Conversion                             
                            }                        
                        }
                    }                                          
                        
                }
                sub = '';
                myCounter = 0;
                for (String perSub : details.keyset()) {
                    myCounter += 1;
                    sub += details.get(perSub);
                    cosSubToDetailMAP.put(eachSubs.Id, sub);
                }
            }
        }
        
    //End: D-2184 03/17/2014 Added by S.Puli
        //START UD-3170 05-Nov-2015 Added by S.Puli
        Set<String> zoneNameSet = new Set<String>();
        //END UD-3170 05-Nov-2015 Added by S.Puli
        //START D-1983 02/25/2015 S.Puli
        Set<Id> vendorIdset = new Set<Id>();
        if(subscriptionList != null && subscriptionList.size()>0){
        //END D-1983 02/25/2015 S.Puli
            for(Zuora__Subscription__c zSub:subscriptionList){
                subscriptionMap.put(zSub.Id,zSub);
                contactIdSet.add(zSub.Recipient_Contact__c);
                vendorAccountIdSet.add(zSub.Vendor_1__r.Id);
                //START D-1983 02/25/2015 S.Puli
                vendorIdset.add(zSub.Vendor_1__r.Id);
                //ENd D-1983 02/25/2015 S.Puli
                //START UD-3170 05-Nov-2015 Added by S.Puli -Recipient_Contact__r.Address__r.Postal_Code__r.Name
                if(zSub.Recipient_Contact__c <> null){
                    if(zSub.Recipient_Contact__r.Address__c <> null){
                        if(zSub.Recipient_Contact__r.Address__r.Postal_Code__c <> null){
                            if(zSub.Recipient_Contact__r.Address__r.Postal_Code__r.Name.length() > 2){
                                String postalSectorKey = '';
                                postalSectorKey = zSub.Recipient_Contact__r.Address__r.Postal_Code__r.Name.substring(0,2);
                                zoneNameSet.add(postalSectorKey);
                            }
                        }
                    }
                }
                //END UD-3170 05-Nov-2015 Added by S.Puli
            }
            
        //START D-1983 02/25/2015 S.Puli Query user with partner community license
        }
        Map<Id,Id> vendorStaffContactIdMAP = new Map<Id,Id>();
        Map<Id, String> conId_AliasMap = new Map<Id, String>();
        Map<Id, id> conId_NameMap = new Map<Id, Id>(); //Start-End: MD-16 03/12/2015 Jason Abolac
        //START UD-3170 05-Nov-2015 Added by S.Puli
        List<Post_Sector_Ops_Rep_Mapping__c> postSectorMapping_List = new List<Post_Sector_Ops_Rep_Mapping__c>();
        //END UD-3170 05-Nov-2015 Added by S.Puli
        if(vendorIdset<>null && vendorIdset.size()>0){
            //Start UD-0982 05/05/2015 MGaelo 
            List<Contact> vendStaffList = [Select Id, Name, RecordType.Name, Vendor_Communication_Preference__c, AccountId From Contact Where AccountId IN :vendorIdset AND RecordType.Name = :GlobalVariableClass.VENDOR_STAFF AND Active__c = true];
            List<Account> vendorList = [SELECT id, name, Vendor_Communication_Preference__c FROM Account WHERE Id IN: vendorIdset]; 
            //End: UD-0982 05/05/2015 MGaelo
        
            if(vendStaffList<>null &&vendStaffList.size()>0){
                for(Contact c : vendStaffList){
                    vendorStaffContactIdMAP.put(c.Id,c.AccountId);
                }
            }
            //START UD-2016 27-July-2015 Added By S.Puli
            List<User> userList = [Select Id, Name, Profile.UserLicense.Name, Alias, ContactId From User Where Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE AND ContactId IN :vendorStaffContactIdMAP.keyset() AND IsActive = true];
            //END UD-2016 27-July-2015 Added By S.Puli
            
            //START UD-3170 05-Nov-2015 Added by S.Puli
            postSectorMapping_List = [Select Id, Zone__r.Name, Vendor_Ops__c, Vendor_Ops__r.Alias, Vendor_Ops__r.IsActive From Post_Sector_Ops_Rep_Mapping__c Where Zone__r.Name In :zoneNameSet AND Vendor_Ops__c <> null AND Vendor_Ops__r.IsActive = true];
            
            if(postSectorMapping_List.size()>0){
                for(Post_Sector_Ops_Rep_Mapping__c postSectRec : postSectorMapping_List){
                    if(postSectRec.Vendor_Ops__r.Alias <> null){
                        for(Zuora__Subscription__c subToAlias : subscriptionList){
                            if(subToAlias.Recipient_Contact__c <> null){
                                if(subToAlias.Recipient_Contact__r.Address__c <> null){
                                    if(subToAlias.Recipient_Contact__r.Address__r.Postal_Code__c <> null){
                                        //Start UD-3457 26-Jan-2016 Added By S.Puli
                                        if(subToAlias.Recipient_Contact__r.Address__r.Postal_Code__r.Name <> null){
                                            if(subToAlias.Recipient_Contact__r.Address__r.Postal_Code__r.Name.length()>2){
                                                if(subToAlias.Recipient_Contact__r.Address__r.Postal_Code__r.Name.subString(0,2) == postSectRec.Zone__r.Name){
                                                    conId_AliasMap.put(subToAlias.Recipient_Contact__c, postSectRec.Vendor_Ops__r.Alias);
                                                }
                                            }else{
                                                if(subToAlias.Recipient_Contact__r.Address__r.Postal_Code__r.Name == postSectRec.Zone__r.Name){
                                                    conId_AliasMap.put(subToAlias.Recipient_Contact__c, postSectRec.Vendor_Ops__r.Alias);
                                                }
                                            }
                                        }
                                        //End UD-3457 26-Jan-2016 Added By S.Puli
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            //END UD-3170 05-Nov-2015 Added by S.Puli
            if(userList<>null && userList.size()>0){
                for(User u : userList){
                    conId_NameMap.put(vendorStaffContactIdMAP.get(u.ContactId), u.id); //Start-End: MD-16 03/12/2015 Jason Abolac
                    vendorStaffId_partnerUser.put(u.ContactId,u); // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                }
            }
        }
        
        //END D-1983 02/25/2015 S.Puli
        
        //START D-0490 12/12/2014 JB Domingo - Get Contacts(Vendor Staff) for every Account
        //Get Contacts(Vendor Staff) for every Account
        //START UD-1834 10-July-2015 Added by S.Puli
        vendorStaffList = [SELECT Id, Account.Id, Email, HomePhone__c, Vendor_Communication_Preference__c, Active__c FROM Contact WHERE Account.Id IN: vendorAccountIdSet AND RecordTypeId =: vendorStaffRecTypeId AND Active__c = true]; //Start-End: MD-54 03/12/2015 Jason Abolac //Start UD-0982 05/05/2015 MGaelo 
        if(vendorStaffList != null){
            for(Contact vendorStaff:vendorStaffList){
                /*List<Contact> vendorStaffTempList = account_VendorStaffMap.get(vendorStaff.Account.Id);
                if(vendorStaffTempList == null){
                    vendorStaffTempList = new List<Contact>();
                }
                vendorStaffTempList.add(vendorStaff);
                //START D-2913 05/18/2015 Jason A./Sherwin P.
                */
                if(!account_VendorStaffMap.containskey(vendorStaff.Account.Id)){    
                    account_VendorStaffMap.put(vendorStaff.Account.Id, new List<Contact>{vendorStaff});
                //START: D-3121 18/06/2015 Added by S.Puli
                } else{
                    account_VendorStaffMap.get(vendorStaff.Account.Id).add(vendorStaff);
                }
                //END: D-3121 18/06/2015 Added by S.Puli
        //END D-2913 05/18/2015 Jason A./Sherwin P.
            }
        }
        //END UD-1834 10-July-2015 Added by S.Puli
             
        //END D-0490 12/12/2014 JB Domingo  
        
        //START CommentedOut By FrancisBenzon : duplicate query, compare query below
        //Get Subscription Product and Charges
        /*subProdChargeList = [SELECT Zuora__Subscription__c, Zuora__RatePlanName__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN: subscriptionIdSet];*/
        //END CommentedOut By FrancisBenzon : duplicate query, compare query below
        
        //START D-1803 01/27/2015 Marvin Gatchalian - added code to include all SPC per subscription
        //Start UD-1345 06/04/2015 Added By Jason A. 
        subProdChargeList = [SELECT Zuora__Subscription__c, Zuora__RatePlanName__c, PublicationCode__c, Zuora__UOM__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN: subscriptionIdSet];
        
        Map <id, List<Zuora__SubscriptionProductCharge__c>> subToSPC = new Map <id, List<Zuora__SubscriptionProductCharge__c>>(); 
        
        if(subProdChargeList.size()>0){       
            for(Zuora__SubscriptionProductCharge__c subProdCharge: subProdChargeList){
                if(subProdCharge.PublicationCode__c <> null && subProdCharge.Zuora__Subscription__c <> null){
        //End UD-1345 06/04/2015 Added By Jason A. 
                if (subToSPC.containskey(subProdCharge.Zuora__Subscription__c)) {
                    subToSPC.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge);
    
                }
                else {
                    subToSPC.put(subProdCharge.Zuora__Subscription__c, new List <Zuora__SubscriptionProductCharge__c> {subProdCharge});
                }    
              
                subProdChargeMap.put(subProdCharge.Zuora__Subscription__c, subProdCharge);
                ratePlanChargeIdSet.add(subProdCharge.Zuora__RatePlanName__c);
                }
            }
        }
        //END D-1803 01/27/2015 Marvin Gatchalian - added code to include all SPC per subscription
    
        //START D-0490 12/12/2014 JB Domingo - Updated the query     
        //Get Product Rate Plan and Charges
        prodRatePlanChargeList = [SELECT Id, Name, zqu__ProductRatePlan__r.Name, PublicationCode__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__r.Name IN: ratePlanChargeIdSet]; 
        if(prodRatePlanChargeList != null){
            for(zqu__ProductRatePlanCharge__c prodRatePlanCharge:prodRatePlanChargeList){
                productRatePlanChargeMap.put(prodRatePlanCharge.zqu__ProductRatePlan__r.Name, prodRatePlanCharge);
                //pubCodeIdSet.add(prodRatePlanCharge.PublicationCode__c);
            }
        }
        //END D-0490 12/12/2014 JB Domingo

        //Get contacts
        contactList = [SELECT Id, FirstName, LastName, Address__r.Id, Salutation FROM Contact WHERE Id IN: contactIdSet];
        if(contactList != null){
            for(Contact c : contactList){
                contactMap.put(c.Id, c);
                addressIdSet.add(c.Address__r.Id);
            }
        }
        //Get Addresses based on Contacts
        addressList = [SELECT Id, Street_Name__c, Building_Name__c, Block_House_Number__c, Level_Number__c, Unit_Number__c, Postal_Code__r.Id FROM Address__c WHERE Id IN: addressIdSet];    
        if(addressList != null){       
            for(Address__c address : addressList){
                addressMap.put(address.Id, address);
                singpostAddressIdSet.add(address.Postal_Code__r.Id);
            }
        }
        
        //Get SingpostAddress based on Addresses
        singpostAddressList = [SELECT Id, Name FROM Singpost_Address__c WHERE Id IN: singpostAddressIdSet];
        if(singpostAddressList != null){
            for(Singpost_Address__c singpostAddress : singpostAddressList){
                singpostAddressMap.put(singpostAddress.Id, singpostAddress);
            }
        }
        
        //Get the related objects for every Case
        for(Case caseObject: scope){
            //1813
            Messaging.SingleEmailMessage mail = getEmail();  
            //1813
            
            //START D-0490 12/11/2014 JB Domingo - Email was not sent. 
        //START UD-2016 10-Aug-2015 Added By S.Puli

            //toAddressesSet = new Set<String>();
            //toAddresses = new List<String>();   
        //END UD-2016 10-Aug-2015 Added By S.Puli

            String issueDate;
            sub = '';
            //END D-0490 12/11/2014 JB Domingo          
            
            if(case_caseSubscriptionMap != null){
                caseSubscriptionsList = case_caseSubscriptionMap.get(caseObject.Id);
            }
            
            if(accountMap != null && caseObject != null){
                acct = accountMap.get(caseObject.Account.Id);
            }  
            
            if(caseSubscriptionsList != null){
                for(Case_Subscription__c caseSubObject: caseSubscriptionsList){
        //START UD-2016 10-Aug-2015 Added By S.Puli 
                toAddressesSet = new Set<String>();
                toAddresses = new List<String>(); 
        //END UD-2016 10-Aug-2015 Added By S.Puli 
                    sendMail = false; 
                
                        zqu__ProductRatePlanCharge__c productRatePlan;
                        //START D-3388 11-Sept-2015 Added By S.Puli
                        subscription = new Zuora__Subscription__c();
                        if(subscriptionMap != null && caseSubObject != null){
                            if(subscriptionMap.containsKey(caseSubObject.Subscription__c)){
                                if(subscriptionMap.get(caseSubObject.Subscription__c) <> null){
                                    subscription = subscriptionMap.get(caseSubObject.Subscription__c);
                                }
                                else{
                                    continue;
                                }
                            }
                            else{
                                continue;
                            }
                            // START : UD-0982 5/7/2015 MGaelo Added condition for VendorCommunicationPreference
                            //START D-2913 05/18/2015 Jason A./Sherwin P.
                            //Start UD-3457 26-Jan-2016 Added By S.Puli
                            if(subscription.Vendor_1__c <> null){
                                if((subscription.Vendor_1__r.Vendor_Communication_Preference__c == 'Both' || subscription.Vendor_1__r.Vendor_Communication_Preference__c == 'Email') && subscription.Vendor_1__r.Active__c == true && subscription.Vendor_1__r.RecordType.Name == GlobalVariableClass.VENDOR){
                                //END D-2913 05/18/2015 Jason A./Sherwin P.
                                    if(subscription.Vendor_1__r.Email__c != null){                             
                                        toAddressesSet.add(subscription.Vendor_1__r.Email__c);
                                        isSendEmail = true;
                                    }
                                }
                            }
                            //End UD-3457 26-Jan-2016 Added By S.Puli
                            //END D-3388 11-Sept-2015 Added By S.Puli
                            // END : UD-0982 5/7/2015 MGaelo
                            //Start: MD-54 03/12/2015 Jason Abolac
                    //START UD-2016 27-July-2015 Added By S.Puli 
                            venMobileNumber = null;
                            //START D-3388 11-Sept-2015 Added By S.Puli
                            if(subscription.Vendor_1__c <> null){
                            //Start UD-3457 26-Jan-2016 Added By S.Puli
                                if(subscription.Vendor_1__r.Vendor_Communication_Preference__c <> 'Email' && subscription.Vendor_1__r.Active__c){
                                    venMobileNumber = subscription.Vendor_1__r.Handphone_Number__c;
                                }
                            //End UD-3457 26-Jan-2016 Added By S.Puli
                            }
                            //END D-3388 11-Sept-2015 Added By S.Puli
                    //END UD-2016 27-July-2015 Added By S.Puli 
                            //End: MD-54 03/12/2015 Jason Abolac
              //START D-0490 12/12/2014 JB Domingo - Get all vendor staff              
                            if(account_VendorStaffMap != null){
                                vendorStaffsList = account_VendorStaffMap.get(subscription.Vendor_1__c);             
                            }
              //END D-0490 12/12/2014 JB Domingo
                        }

                        if(contactMap != null && subscription != null){            
                            con = contactMap.get(subscription.Recipient_Contact__c);                     
                        }

                        if(subProdChargeMap != null && subscription != null){
                            subProdChargeObj = subProdChargeMap.get(subscription.Id);
                        }
                
                        if(productRatePlanChargeMap != null && subProdChargeObj != null){
                            productRatePlan = productRatePlanChargeMap.get(subProdChargeObj.Zuora__RatePlanName__c);
                        }

                        if(addressMap != null && con != null){
                            addressObj = addressMap.get(con.Address__r.Id);
                        }
                        
                        if(singpostAddressMap != null && addressObj != null){
                            singpostAddressObj = singpostAddressMap.get(addressObj.Postal_Code__r.Id);
                        }  
            
            //START D-1803 01/27/2015 Marvin Gatchalian - Get each publication code per subscription and remove existing code which is single record only
            
                //START D-0490 12/12/2014 JB Domingo - Get publication code
                        //if(productRatePlan != null){
                           //system.debug(productRatePlan.PublicationCode__c);                  
                           //sub = string.valueOf(productRatePlan.PublicationCode__c);   
                        //}
                //END D-0490 12/12/2014  
                    List <Zuora__SubscriptionProductCharge__c> spcList = new List <Zuora__SubscriptionProductCharge__c>();
                    spcList = subToSPC.get(subscription.Id);
                    
                    //START D-1961 02/03/2015 Marvin Gatcsubscription.Idhalian  - Change format from {ST, SUT} to ST/SUT
                    //set<string> pubCode = new set<string>();
                    
                    if (spcList != null) {
                         pubCode.clear();
                         for(Zuora__SubscriptionProductCharge__c spc: spcList){
                            
        //Start UD-1345 06/04/2015 Added By Jason A. 
                             if (spc.PublicationCode__c != null && (spc.Zuora__UOM__c == 'Copy Weekday' || spc.Zuora__UOM__c == 'Copy Sat' || spc.Zuora__UOM__c == 'Copy Sun'))  {
        //End UD-1345 06/04/2015 Added By Jason A. 
                                 pubCode.add(spc.PublicationCode__c);
                                //START AddedBy FrancisBenzon : remove null
                                pubCode.remove(null);
                                //END AddedBy FrancisBenzon : remove null
                                
                             }  
                         }
                         details.clear();
                          myCounter = 1;
                        
                         for (string eachPubCode: pubCode) {
                         myCounter = myCounter +1;
                            
                        //START UD-0289 AddedBy FrancisBenzon : variables
                        string phDStart = '0';
                        string phEStart = '0';
                        string freq3 = ' ';
                        string freq4 = ' ';
                        //Start UD-3379 20-Jan-2016 Added By S.Puli
                        if(subscription.Ph_d__c)
                        {
                            phDStart = string.valueOf(subscription.Number_of_Copies__c).substringBefore('.');
                            //scenario 1: wala sya sa map
                            //scenario 2: nasa map sya pero false
                            //scenario 3: nasa map sya at true
                            //Start UD-3379 02-Feb-2016 Added By S.Puli
                            if(!tempStopCaseToKey_MAP.containsKey(caseObject.Id) || (tempStopCaseToKey_MAP.containsKey(caseObject.Id) && !tempStopCaseToKey_MAP.get(caseObject.Id))){
                                if(caseObject.Temp_Stop__r <> null){
                                    if(caseObject.Temp_Stop__r.Temp_Stop_Date__c <> null){
                                        if(caseObject.Temp_Stop__r.Temp_Stop_Date__c == date.today()+1){
                                            if(caseObject.Temp_Stop__r.Qty__c <> null){
                                                phDStart = string.valueOf(caseObject.Temp_Stop__r.Qty__c).substringBefore('.');
                                            }   
                                        }
                                    }
                                }
                            }
                            //End UD-3379 02-Feb-2016 Added By S.Puli
                        }
                        if(subscription.Ph_e__c) 
                        {
                            phEStart = string.valueOf(subscription.Number_of_Copies__c).substringBefore('.');
                            //Start UD-3379 02-Feb-2016 Added By S.Puli
                            if(!tempStopCaseToKey_MAP.containsKey(caseObject.Id) || (tempStopCaseToKey_MAP.containsKey(caseObject.Id) && !tempStopCaseToKey_MAP.get(caseObject.Id))){  
                                if(caseObject.Temp_Stop__r <> null){
                                    if(caseObject.Temp_Stop__r.Temp_Stop_Date__c <> null){
                                        if(caseObject.Temp_Stop__r.Temp_Stop_Date__c == date.today()+1){
                                            if(caseObject.Temp_Stop__r.Qty__c <> null){
                                                phEStart = string.valueOf(caseObject.Temp_Stop__r.Qty__c).substringBefore('.');
                                            }
                                        }
                                    }
                                }
                            }
                            //End UD-3379 02-Feb-2016 Added By S.Puli
                        }
                        //End UD-3379 20-Jan-2016 Added By S.Puli
                        //END UD-0289 AddedBy FrancisBenzon : variables  
                            if (publicationMap.containskey(eachPubCode)) {
                                
                                Publication__c pub = new Publication__c();
                                pub = publicationMap.get(eachPubCode);
                                // START : UD-0985 7/6/2015 Alyana Navarro
                                if (details.containskey(pub.Sunday_Publication__r.Publication_Code__c)) {
                                    if(subscription.Frequency_1__c == GlobalVariableClass.FREQUENCY_DEFAULT 
                                        || subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_FRISUN 
                                        || subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_SATSUN){
                                        sub = string.valueOf(eachPubCode) + '/' + sub;

                                        //START D-2392 02/25/2015 S.Puli - Email notification for change of address
                                        details.put(pub.Sunday_Publication__r.Publication_Code__c, sub);
                                        //End D-2392 02/25/2015 S.Puli - Email notification for change of address
                                    } else if(subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_MONFRI || subscription.Frequency_1__c == GlobalVariableClass.FREQUENCY_MONSAT){
                                        sub = string.valueOf(eachPubCode);
                                        details.put(pub.Sunday_Publication__r.Publication_Code__c, sub);
                                    }
                                } else {
                                     sub = '';
        //Start UD-1345 06/04/2015 Added By Jason A. 
                                     if(pub.Sunday_Publication__c == null ){
                                        sub = string.valueOf(eachPubCode);
                                     }else{
                                        if(subscription.Frequency_1__c == GlobalVariableClass.FREQUENCY_DEFAULT 
                                            || subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_FRISUN 
                                            || subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_SATSUN){
                                            sub = string.valueOf(eachPubCode) + '/' + pub.Sunday_Publication__r.Publication_Code__c;
                                        } else if(subscription.Frequency_1__c == GlobalVariableClass.SUB_FREQUENCY_MONFRI || subscription.Frequency_1__c == GlobalVariableClass.FREQUENCY_MONSAT){
                                            sub = string.valueOf(eachPubCode);
                                        }
                                     }
                                // END : UD-0985 7/6/2015 Alyana Navarro
        //End UD-1345 06/04/2015 Added By Jason A. 
                                     if(subscription != null){
                                        string numOfCopy = '';
                                         //START UD-0289 AddedBy FrancisBenzon
                                        try{
                                        //START UD-1820 and UD-1823 07/1015 AddedBy Jason A : Notification
                                        //Start UD- 1987 07/24/2015 Added by : Jason A
                                        if(subscription.Number_of_Copies__c <> null && subscription.Frequency_1__c <> null){
                                            numOfCopy = string.valueOf(subscription.Number_of_Copies__c).substringBefore('.');
                                            //START D-3388 17-Sept-2015 Added By S.Puli
                                            //Start UD-3379 20-Jan-2016 Added By S.Puli
                                            //Start UD-3379 02-Feb-2016 Added By S.Puli
                                            if(!tempStopCaseToKey_MAP.containsKey(caseObject.Id) || (tempStopCaseToKey_MAP.containsKey(caseObject.Id) && !tempStopCaseToKey_MAP.get(caseObject.Id))){   
                                                if(caseObject.Temp_Stop__r <> null){
                                                    if(caseObject.Temp_Stop__r.Temp_Stop_Date__c <> null){
                                                        if(caseObject.Temp_Stop__r.Temp_Stop_Date__c == date.today()+1){
                                                            if(caseObject.Temp_Stop__r.Qty__c <> null){
                                                                numOfCopy = string.valueOf(caseObject.Temp_Stop__r.Qty__c).substringBefore('.');
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            //End UD-3379 02-Feb-2016 Added By S.Puli
                                            //End UD-3379 20-Jan-2016 Added By S.Puli
                                            //END D-3388 17-Sept-2015 Added By S.Puli
                                            if(startPackToPackItemsMap.containsKey(subscription.Main_Package_1__c)){
                                                if(startPackToPackItemsMap.get(subscription.Main_Package_1__c).Is_Print__c || startPackToPackItemsMap.get(subscription.Main_Package_1__c).Is_All_In_One__c)
                                                {
                                                    
                                                    if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT )
                                                    {
                                                        freq3 = pub.Published_Days__c.replace('Y', numOfCopy);                                                
                                                        freq4 = freq3.replace('N', '0') + phDStart + phEStart;                                              
                                                    
                                                    }
                                                    else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_MONFRI) 
                                                    {
                                                        freq4 = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + '0' + numOfCopy + '0';
                                                        
                                                    }
                                                    else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_MONSAT)
                                                    {
                                                        freq4 = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + numOfCopy + numOfCopy;
                                                        
                                                    }
                                                    else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_SATSUN)
                                                    {
                                                        freq4 = '0' + '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + '0' + numOfCopy;
                                                        
                                                    }
                                                    else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_FRISUN)
                                                    {
                                                        freq4 = '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy;
                                                        
                                                    }
                                                    //logic for binary 
                                                    //START: UD-0798 18/06/2015 Added by S.Puli
                                         //END UD-1820 and UD-1823 07/1015 AddedBy Jason A : Notification
                                                    if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c <> null && pub.Published_Days__c == 'YYYYYYN'){
                                //START UD-2016 27-July-2015 Added By S.Puli 
                                //START UD-2117 26-Aug-2015 Added By J.Abolac
                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.DAILY +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c <> null && pub.Published_Days__c == 'NNNNYYN'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c <> null && pub.Published_Days__c == 'NNNNNYN'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((1*(numOfCopy.length()))+2));
                                                        freq4 += numOfCopy + '0' + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq4 +') ';   
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'YYYYYYY'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((3*(numOfCopy.length()))));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.DAILY +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'YYYYYNN'){
                                                        //Start D-4729 26-Apr-2016 Added by S.Puli
                                                        //freq4 = freq4.substring(0, freq4.length() - ((1*(numOfCopy.length()))+2));
                                                        freq4 = freq4.substring(0, ((5*(numOfCopy.length()))+1));
                                                        //Start UD-3457 26-Jan-2016 Added By S.Puli
                                                        freq4 += '0' + numOfCopy + '0';
                                                        //End UD-3457 26-Jan-2016 Added By S.Puli
                                                        //End D-4729 26-Apr-2016 Added by S.Puli
                                                        sub += ' ('+GlobalVariableClass.FREQ_MONFRI +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'NNNNYYY'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((3*(numOfCopy.length()))));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'NNNNNYY'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += numOfCopy + '0' + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && pub.Sunday_Publication__c == null && pub.Published_Days__c == 'YYYYYYN'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += '0' + numOfCopy + numOfCopy;
                                //END UD-2117 26-Aug-2015 Added By J.Abolac
                                //END UD-2016 27-July-2015 Added By S.Puli 
                                                        sub += ' ('+GlobalVariableClass.FREQ_MONSAT +'>'+freq4 +') ';
                                                    } else{
                                                        sub += ' ('+string.valueOf(subscription.Frequency_1__c)+'>'+freq4 +') ';
                                                    }
                                                    //END: UD-0798 18/06/2015 Added by S.Puli
                                                }
                                                /*
                                                else
                                                {
                                                    //START: UD-0798 18/06/2015 Added by S.Puli
                                                    if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT ){
                                                        sub += ' ('+GlobalVariableClass.DAILY+'>'+string.valueOf(subscription.Number_of_Copies__c).substringBefore('.')+') ';
                                                    } else{
                                                        sub += ' ('+string.valueOf(subscription.Frequency_1__c)+'>'+string.valueOf(subscription.Number_of_Copies__c).substringBefore('.')+') ';//START/END: D-2522 03/18/2014 Added by S.Puli 
                                                    }
                                                    //END: UD-0798 18/06/2015 Added by S.Puli
                                                } 
                                                */
                                            }
                                        }
                                        //END UD- 1987 07/24/2015 Added by : Jason A
                                        } catch(Exception e){
                                            
                    //START UD-3158 28-Nov-2015 Added By S.Puli
                    exceptionList.add(e);
                    //END UD-3158 28-Nov-2015 Added By S.Puli
                                        }
                                        //END UD-0289 AddedBy FrancisBenzon       
                                    }
                                        //START UD-0289 AddedBy FrancisBenzon
                                        details.put(pub.Sunday_Publication__r.Publication_Code__c, sub);
                                        //details.put(pub.Publication_Code__c, sub);
                                        //END UD-0289 AddedBy FrancisBenzon
                                }
                            }
                            else { // if pub code has no look up publication
                                if (!details.containskey(eachPubCode)) {
                                     sub = '';
                                     sub = string.valueOf(eachPubCode);
                                     //START UD-0289 AddedBy FrancisBenzon : logic for published Days
                                    //START D-2999 05/20/2015 Added By S.Puli
                                    //List<Publication__c> thisPub = [Select Published_Days__c, Publish_Pattern__c, Sunday_Publication__c From Publication__c Where Publication_Code__c = :eachPubCode limit 1];
                                    List<Publication__c> thisPub = new List<Publication__c>();
                                    thisPub.add(noSundayPubMap.get(eachPubCode));
                                    //END D-2999 05/20/2015 Added By S.Puli
                                     if(subscription != null){
                                        //START D-2075 02/25/2015 S.Puli
                                        string numOfCopy = '';
                                        if(subscription.Number_of_Copies__c <> null && subscription.Frequency_1__c <> null){//Start/End: D-2184 03/17/2014 Added by S.Puli
                                            //START/END UD-0289 5/19/15 CommentedOut by francisbenzon : transfered code in line 1181
                                            try{
                                            //START UD-1820 and UD-1823 07/1015 AddedBy Jason A : Notification
                                            //Start UD- 1987 07/24/2015 Added by : Jason A
                                            numOfCopy = string.valueOf(subscription.Number_of_Copies__c).substringBefore('.');
                                            //START D-3388 17-Sept-2015 Added By S.Puli
                                            //Start UD-3379 20-Jan-2016 Added By S.Puli
                                            //Start UD-3379 02-Feb-2016 Added By S.Puli
                                            if(!tempStopCaseToKey_MAP.containsKey(caseObject.Id) || (tempStopCaseToKey_MAP.containsKey(caseObject.Id) && !tempStopCaseToKey_MAP.get(caseObject.Id))){
                                                if(caseObject.Temp_Stop__r <> null){
                                                    if(caseObject.Temp_Stop__r.Temp_Stop_Date__c <> null){
                                                        if(caseObject.Temp_Stop__r.Temp_Stop_Date__c == date.today()+1){
                                                            if(caseObject.Temp_Stop__r.Qty__c <> null){
                                                                numOfCopy = string.valueOf(caseObject.Temp_Stop__r.Qty__c).substringBefore('.');
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            //End UD-3379 02-Feb-2016 Added By S.Puli
                                            //End UD-3379 20-Jan-2016 Added By S.Puli
                                            //END D-3388 17-Sept-2015 Added By S.Puli
                                                if(startPackToPackItemsMap.containsKey(subscription.Main_Package_1__c)){
                                                    if(startPackToPackItemsMap.get(subscription.Main_Package_1__c).Is_Print__c || startPackToPackItemsMap.get(subscription.Main_Package_1__c).Is_All_In_One__c)
                                                    {                                               
                                                        if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT)
                                                        {
                                                            freq3 = thisPub[0].Published_Days__c.replace('Y', numOfCopy);
                                //START UD-2016 27-July-2015 Added By S.Puli 
                                                            freq4 = freq3.replace('N', '0') + phDStart + phEStart;
                                                    
                                                        }
                                                        else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_MONFRI) 
                                                        {
                                                            freq4 = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + '0' + numOfCopy + '0';
                                                    
                                                        }
                                                        else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_MONSAT)
                                                        {
                                                            freq4 = numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy + '0' + numOfCopy + numOfCopy;
                                                    
                                                        }
                                                        else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_SATSUN)
                                                        {
                                                            freq4 = '0' + '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + '0' + numOfCopy;
                                                    
                                                        }
                                                        else if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_FRISUN)
                                                        {
                                                            freq4 = '0' + '0' + '0' + '0' + numOfCopy + numOfCopy + numOfCopy + numOfCopy + numOfCopy;
                                                    
                                                        }
                                             //END UD-1820 and UD-1823 07/1015 AddedBy Jason A : Notification
                                             //START UD-2117 26-Aug-2015 Added By J.Abolac
                                                        //logic for binary 
                                                        //START: UD-0798 18/06/2015 Added by S.Puli
                                                    if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c <> null && thisPub[0].Published_Days__c == 'YYYYYYN'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.DAILY +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c <> null && thisPub[0].Published_Days__c == 'NNNNYYN'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c <> null && thisPub[0].Published_Days__c == 'NNNNNYN'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((1*(numOfCopy.length()))+2));
                                                        freq4 += numOfCopy + '0' + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq4 +') ';   
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'YYYYYYY'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((3*(numOfCopy.length()))));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.DAILY +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'YYYYYNN'){
                                                        //Start D-4729 26-Apr-2016 Added by S.Puli
                                                        //freq4 = freq4.substring(0, freq4.length() - ((1*(numOfCopy.length()))+2));
                                                        freq4 = freq4.substring(0, ((5*(numOfCopy.length()))+1));
                                                        //Start UD-3457 26-Jan-2016 Added By S.Puli
                                                        freq4 += '0' + numOfCopy + '0';
                                                        //End UD-3457 26-Jan-2016 Added By S.Puli
                                                        //End D-4729 26-Apr-2016 Added by S.Puli
                                                        sub += ' ('+GlobalVariableClass.FREQ_MONFRI +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'NNNNYYY'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((3*(numOfCopy.length()))));
                                                        freq4 += numOfCopy + numOfCopy + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_FRISUN +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'NNNNNYY'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += numOfCopy + '0' + numOfCopy;
                                                        sub += ' ('+GlobalVariableClass.FREQ_SATSUN +'>'+freq4 +') ';
                                                    }else if (subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT && thisPub[0].Sunday_Publication__c == null && thisPub[0].Published_Days__c == 'YYYYYYN'){
                                                        freq4 = freq4.substring(0, freq4.length() - ((2*(numOfCopy.length()))+1));
                                                        freq4 += '0' + numOfCopy + numOfCopy;
                                //END UD-2117 26-Aug-2015 Added By J.Abolac
                                //END UD-2016 27-July-2015 Added By S.Puli 
                                                        sub += ' ('+GlobalVariableClass.FREQ_MONSAT +'>'+freq4 +') ';
                                                    } else{
                                                        sub += ' ('+string.valueOf(subscription.Frequency_1__c)+'>'+freq4 +') ';
                                                    }
                                                        //END: UD-0798 18/06/2015 Added by S.Puli
                                                    }
                                                    /*
                                                    else
                                                    {
                                                        //START UD-0289 5/19/15 AddedBy by francisbenzon : transfered code logic here
                                                        numOfCopy = string.valueOf(subscription.Number_of_Copies__c).substringBefore('.');
                                                        //END UD-0289 5/19/15 AddedBy by francisbenzon : transfered code logic here
                                                        //START: UD-0798 18/06/2015 Added by S.Puli
                                                        if(subscription.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT){
                                                            sub += ' ('+GlobalVariableClass.DAILY+'>'+numOfCopy+') ';
                                                        } else{
                                                            sub += ' ('+string.valueOf(subscription.Frequency_1__c)+'>'+numOfCopy+') ';
                                                        }
                                                        //END: UD-0798 18/06/2015 Added by S.Puli
                                                    }
                                                    */
                                                }
                                            //END UD- 1987 07/24/2015 Added by : Jason A
                                            } catch(Exception e){
                                                
                        //START UD-3158 28-Nov-2015 Added By S.Puli
                        exceptionList.add(e);
                        //END UD-3158 28-Nov-2015 Added By S.Puli
                                            }
                                        }//Start/End: D-2184 03/17/2014 Added by S.Puli
                                        //END D-2075 02/25/2015 S.Puli
                                     }
                                    if(thisPub[0].Publish_Pattern__c != GlobalVariableClass.CREATEVENDORSTART_WEEKEND && thisPub[0].Sunday_Publication__c == null)
                                    {
                                        details.put(eachPubCode, sub);
                                    }
                                    //END UD-0289 AddedBy FrancisBenzon : logic for published Days                                  
                                }
                                
                            }
                        } 
                         
                            
                     }
                     //START UD-0289 5/19/15 AddedBy FrancisBenzon : code needs to instantiate sub to avoid duplicate prints.
                     sub = ''; //START-END : UD-0982 5/13/2015
                     //END UD-0289 5/19/15 AddedBy FrancisBenzon : code needs to instantiate sub to avoid duplicate prints.
                     myCounter = 0;
                     for (String perSub : details.keyset()) {
                         myCounter += 1;
                         sub += details.get(perSub);

                     }
                     
                    //Check if the scenarios are met. If a scenario was met, this will set a flag named 
                    //sendMail to TRUE.  
                    //START D-0490 12/11/2014 JB Domingo - Email was not sent. Modified conditions.  
                    system.debug('acct.RecordTypeId'+acct.RecordTypeId);
                    system.debug('caseObject.RecordTypeId'+caseObject.RecordTypeId);
                    system.debug('subscription'+subscription);              
                    if(acct != null){
                                                    
                                                    
                        if(acct.RecordTypeId == ConstantsSLB.getKeyId('Account_Direct Corporate')||acct.RecordTypeId == ConstantsSLB.getKeyId('Account_Direct Individual') ||acct.RecordTypeId == ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division')){
                            //START D-D-2075 02/25/2015 S.Puli
                            //START UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                            //Start PD-0198 01-Jun-2016 Added By S.Puli
                            if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Start Sub') && subscription.Zuora__SubscriptionStartDate__c == Date.today()+1 && 
                            (subscription.Zuora__SubscriptionEndDate__c == null || Date.today() < subscription.Zuora__SubscriptionEndDate__c) && subscription.Urgent_1__c == false && (subscription.Order_Line_Item_Number_1__r.Supressed_Vendor_Notification_New_Sub__c == false && subscription.Order_Line_Item_Number_1__r.Suppress_Vendor_Start_notice__c == false)){ //Start Direct Subscription - Subscription Fulfillment
                            //End PD-0198 01-Jun-2016 Added By S.Puli
                            //END UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                            //END D-D-2075 02/25/2015 S.Puli
                                //START: D-3118 18/06/2015 Added by S.Puli
                                if(subscription.Order_Line_Item_Number_1__r.Vendor_Conversion__c){
                                    transactionName = GlobalVariableClass.START_CONVERSION;
                                } else{
                                    transactionName = GlobalVariableClass.START_NEW;
                                }
                                //END: D-3118 18/06/2015 Added by S.Puli
                                sendMail = true;
                                issueDate = convertDateToString(subscription.Zuora__SubscriptionStartDate__c);
                            //START D-D-2075 02/25/2015 S.Puli
                            }
                            //START UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                            //Start PD-0198 01-Jun-2016 Added By S.Puli
                            else if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Start Sub') && subscription.Zuora__SubscriptionStartDate__c == Date.today()+1 && 
                            (subscription.Zuora__SubscriptionEndDate__c == null || Date.today() < subscription.Zuora__SubscriptionEndDate__c) && subscription.Urgent_1__c == true && subscription.Order_Line_Item_Number_1__r.Supressed_Vendor_Notification_New_Sub__c == false && subscription.Order_Line_Item_Number_1__r.Suppress_Vendor_Start_notice__c == false){
                            //End PD-0198 01-Jun-2016 Added By S.Puli
                            //END UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                                //START: D-3118 18/06/2015 Added by S.Puli
                                if(subscription.Order_Line_Item_Number_1__r.Vendor_Conversion__c){
                                    transactionName = GlobalVariableClass.START_CONVERSION;
                                } else {
                                    transactionName = GlobalVariableClass.START_URGENT;
                                }
                                //END: D-3118 18/06/2015 Added by S.Puli
                                sendMail = true;
                                issueDate = convertDateToString(subscription.Zuora__SubscriptionStartDate__c);
                                system.debug('sendMail1'+sendMail);
                            //END D-D-2075 02/25/2015 S.Puli
                            } 
                            //START: D-3121 18/06/2015 Added by S.Puli
                            //START UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                            //Start PD-0198 01-Jun-2016 Added By S.Puli
                            else if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Stop') && subscription.Zuora__SubscriptionEndDate__c == Date.today() && subscription.Zuora__SubscriptionStartDate__c < Date.today()){ //START D-1623 03/21/2015 S.Puli Stop Direct Subscription - Subscription Integration 
                            //End PD-0198 01-Jun-2016 Added By S.Puli
                                if(subsToSuppressKey.containsKey(subscription.Id)){
                                    if(!subsToSuppressKey.get(subscription.Id)){
                                        transactionName = GlobalVariableClass.STOP_URGENT ;
                                        sendMail = true;
                                        //START UD-3197 03-Nov-2015 Added by S.Puli
                                        issueDate = convertDateToString(subscription.Zuora__SubscriptionEndDate__c.addDays(1)); //START-END D-2544 04/15/2015 Jason Abolac
                                        //END UD-3197 03-Nov-2015 Added by S.Puli                      
                                        system.debug('sendMail2'+sendMail);
                                    }
                                }
                                else{
                                    transactionName = GlobalVariableClass.STOP_URGENT ;
                                    sendMail = true;
                                    //START UD-3197 03-Nov-2015 Added by S.Puli
                                    issueDate = convertDateToString(subscription.Zuora__SubscriptionEndDate__c.addDays(1)); //START-END D-2544 04/15/2015 Jason Abolac  
                                    //END UD-3197 03-Nov-2015 Added by S.Puli                      
                                }
                            //END UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                            }
                            //END: D-3121 18/06/2015 Added by S.Puli
                            //START D-2393 02/27/2015 S.Puli
                            else if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObject.Temp_Stop__r.Temp_Stop_Date__c == Date.today()+1 && caseObject.Requires_Urgent_Approval__c == false){ //Temp-Stop Direct Subscription - Subscription Integration
                            //END D-2393 02/27/2015 S.Puli
                                // START D-2199    2015-02-17    Mic De Lara
                                //START D-2393 02/27/2015 S.Puli
                                transactionName = GlobalVariableClass.STOP_TEMPSTOP;
                                //END D-2393 02/27/2015 S.Puli
                                // END D-2199
                                sendMail = true;
                                issueDate = convertDateToString(caseObject.Temp_Stop__r.Temp_Stop_Date__c);                                                        
                            }
                            //START D-2393 02/27/2015 S.Puli
                            else if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObject.Temp_Stop__r.Temp_Stop_Date__c == Date.today()+1 && caseObject.Requires_Urgent_Approval__c == true){ //Temp-Stop Direct Subscription - Subscription Integration
                                transactionName = GlobalVariableClass.STOP_TEMPSTOP_URGENT ;
                                sendMail = true;
                                issueDate = convertDateToString(caseObject.Temp_Stop__r.Temp_Stop_Date__c);                                                        
                            }
                            else if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObject.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObject.Requires_Urgent_Approval__c == false){ //Temp-Stop Direct Subscription - Subscription Integration
                                // START D-2199    2015-02-17    Mic De Lara
                                transactionName = GlobalVariableClass.TS_RESTART ;
                                // END D-2199
                                sendMail = true;
                                issueDate = convertDateToString(caseObject.Temp_Stop__r.Restart_Date__c);                                                      
                            }
                            else if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObject.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObject.Requires_Urgent_Approval__c == true){ //Temp-Stop Direct Subscription - Subscription Integration
                                // START D-2199    2015-02-17    Mic De Lara
                                transactionName = GlobalVariableClass.TS_URGENTRESTART ;
                                //END D-2393 02/27/2015 S.Puli
                                // END D-2199
                                sendMail = true;
                                issueDate = convertDateToString(caseObject.Temp_Stop__r.Restart_Date__c);                                                      
                                system.debug('sendMail3'+sendMail);     
                            }
                //Start: D-2184 03/17/2014 Added by S.Puli
                //START/END UD-0289 AddedBy FrancisBenzon : casted string to Id
                            //START UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                            else if(caseObject.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription') && subscription.Zuora__SubscriptionStartDate__c == Date.today()+1 && subscription.Order_Line_Item_Number_1__r.Supressed_Vendor_Notification_New_Sub__c == false && subscription.Order_Line_Item_Number_1__r.Suppress_Vendor_Start_notice__c == false){ //Change of Subscription Package � Fulfillment
                            //END UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                                if(caseObject.Urgent_Request__c == true){
                                    transactionName = GlobalVariableClass.START_URGENT;
                                } else {
                                    transactionName = GlobalVariableClass.START_NEW;
                                }
                //End: D-2184 03/17/2014 Added by S.Puli
                                sendMail = true;
                                issueDate = convertDateToString(subscription.Zuora__SubscriptionStartDate__c);//Start/End: D-2184 03/17/2014 Added by S.Puli                                                                                 
                            }
                            else if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Change in Address') && caseObject.Effective_Date__c == Date.today()+1){ 
                                //transactionName = GlobalVariableClass.STOP_URGENT;
                                transactionName = GlobalVariableClass.COA_STOP;//remove hard code
                                sendMail = true;
                                issueDate = convertDateToString(caseObject.Effective_Date__c);                                                                                 
                                system.debug('sendMail4'+sendMail);                                 
                            }
                            //END D-2075 02/25/2015 S.Puli - Email notification for change of address
                            // START D-2199    2015-02-17    Mic De Lara
                            classification = GlobalVariableClass.NOTIF_CLASS_DIRECT ;
                            // END D-2199
                        }
                        //START D-4074 10-Dec-2015 Added By S.Puli
                        /**REMOVE
                        else if(acct.RecordTypeId == ConstantsSLB.getKeyId('Account_Vendor Subscriber')||acct.RecordTypeId == ConstantsSLB.getKeyId('Account_Vendor')){
                            if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Stop') && subscription.Effective_End_Date__c == Date.today()+1){ //Stop Vendor Subscription � Normal Stop Request
                                transactionName = GlobalVariableClass.STOP_URGENT;
                                sendMail = true;  
                                issueDate = convertDateToString(subscription.Effective_End_Date__c);                                                                                                               
                                system.debug('sendMail5'+sendMail);                             
                            } 
                            else if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Start Sub') && subscription.Effective_Start_Date__c == Date.today()+1){ //Start Vendor Subscription � Normal Start Request
                                transactionName = GlobalVariableClass.START_NEW;
                                sendMail = true;  
                                issueDate = convertDateToString(subscription.Effective_Start_Date__c);                                                                                                                                         
                                system.debug('sendMail6'+sendMail);                             
                            }
                            else if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObject.Temp_Stop__r.Temp_Stop_Date__c == Date.today()+1){ //Temp-Stop Vendor Subscription � Normal Stop Request (Vendor Ops)
                                // START D-2199    2015-02-17    Mic De Lara
                                transactionName = GlobalVariableClass.STOP_TEMPSTOP_URGENT ;
                                // END D-2199
                                sendMail = true;
                                issueDate = convertDateToString(caseObject.Temp_Stop__r.Temp_Stop_Date__c);                                                                                                                                                                        
                                system.debug('sendMail7'+sendMail);                             
                            }
                            else if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObject.Temp_Stop__r.Restart_Date__c == Date.today()+1){ //Temp-Stop Vendor Subscription � Normal Stop Request (Salesforce)
                                // START D-2199    2015-02-17    Mic De Lara
                                transactionName = GlobalVariableClass.STOP_TEMPSTOP_URGENT ;
                                // END D-2199
                                sendMail = true;
                                issueDate = convertDateToString(caseObject.Temp_Stop__r.Restart_Date__c);                                                                                                                                                                                                  
                                system.debug('sendMail8'+sendMail);                             
                            }   
                            else if(subscription.Vendor_Subscription_To_Convert_1__c != null && subscription.Zuora__SubscriptionEndDate__c == Date.today()+1){ //Vendor to Direct Subscription - Subscription Integration
                                transactionName = GlobalVariableClass.START_CONVERSION;
                                sendMail = true;   
                                issueDate = convertDateToString(subscription.Zuora__SubscriptionEndDate__c);
                                system.debug('sendMail9'+sendMail);                             
                            }

                            // START D-2199    2015-02-17    Mic De Lara
                            classification = GlobalVariableClass.NOTIF_CLASS_VENDOR ;
                            // END D-2199
                        }**/
                        //END D-4074 10-Dec-2015 Added By S.Puli
                    }
                    //END D-0490 12/11/2014 JB Domingo 
                    system.debug('toAddressesSet'+toAddressesSet);                  
                    // START : UD-0982 5/7/2015 MGaelo Added condition for VendorCommunicationPreference
                    if(toAddressesSet.size() > 0){
                        toAddresses.addAll(toAddressesSet);
                    }
                    // END : UD-0982 5/7/2015 MGaelo
                    system.debug('toAddresses'+toAddresses);
                    //Get all Vendor Staff contacts and add it to the mail recipient list.
                    venStaffMobileNumberList = new List<String>();//Start/End PD-0145 16-Apr-2016 Added By S.Puli - reset values 
                    if(vendorStaffsList != null){
                        //Start/End PD-0145 16-Apr-2016 Added By S.Puli - transfer UP: venStaffMobileNumberList = new List<String>(); //Start - End: MD-54 03/12/2015 Jason Abolac
                        venStaffid = new Set<String>(); // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                        //Start UD-3457 25-Jan-2015 Added By S.Puli
                        for(Contact venCon:vendorStaffsList){  
                            if(venCon.Id != null){
                                venStaffid.add(venCon.Id);
                            }
                            if(venCon.Email != null){
                                //START D-0490 12/11/2014 JB Domingo - Email was not sent.      
                                // START : UD-0982 5/7/2015 MGaelo Added condition for VendorCommunicationPreference
                                if(toAddresses.size() < 100){
                                    if((venCon.Vendor_Communication_Preference__c == 'Both' || venCon.Vendor_Communication_Preference__c == 'Email') && venCon.Active__c){
                                        toAddresses.add(venCon.Email);
                                        isSendEmail = true;
                                    }
                                }
                                // END : UD-0982 5/7/2015 MGaelo
                                //END D-0490 12/11/2014 JB Domingo

                                // START 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                                
                                // END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                            }
                            // START : UD-0982 5/7/2015 MGaelo Added condition for VendorCommunicationPreference
                            if((venCon.Vendor_Communication_Preference__c == 'Both' || venCon.Vendor_Communication_Preference__c == 'SMS') && venCon.Active__c && venCon.HomePhone__c != null){                                 
                                venStaffMobileNumberList.add(venCon.HomePhone__c); //Start- End: MD-54 03/12/2015 Jason Abolac   
                            }
                            // END : UD-0982 5/7/2015 MGaelo
                        }
                        //End UD-3457 25-Jan-2015 Added By S.Puli
                    }
                    //If a scenario was satisfied, this will add the mail to the notification list.
                    if(sendMail == true){
                    
                        //START UD-2016 27-July-2015 Added By S.Puli - add logic for multi pub
                        //Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage(); //START/END UD-0982 MGaelo 5/6/2015
                        
                        //START: D-1813 02/05/2015 Modified by Marvin Gatchalian - do not send an email if publication code is blank
                        //START: D-1623 01/14/2014 Added by S.Puli
                        if(sub != '' && sub != null){ // START-END : UD-0982 5/13/2015 Alyana Navarro - Remove filter of toAddress
                            //Start: D-2075 02/25/2014 Added by S.Puli
                            System.debug('TRY 1');
                            //START UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference
                            //START: D-3130 18/06/2015 Added by S.Puli
                            //START UD-1820 Added by Jason A./S. Puli
                            if((transactionName <> GlobalVariableClass.TS_URGENTRESTART && transactionName <> GlobalVariableClass.TS_RESTART) || caseObject.COA__c == false){
                            //start D-3388 11-Sept-2015 Added by S.Puli
                                system.debug('isSendEmail>>'+isSendEmail);
                                if(caseObject.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObject.Temp_Stop__r.Temp_Stop_Date__c == Date.today()+1 && caseObject.COA__c){
                                    if(tempStopCaseToKey_MAP.containsKey(caseObject.Id)){
                                    
                                        if(tempStopCaseToKey_MAP.get(caseObject.Id)){
                                            //mailTemp = 
                                            transactionName = GlobalVariableClass.STOP_URGENT;
                                            
                                            //START/END UD-3158 06-Dec-2015 Removed By S.Puli if(isSendEmail){
                                                //mailList.add(mailTemp); // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                                            //START/END UD-3158 06-Dec-2015 Removed By S.Puli }
                                        }
                                        constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                    }
                                }
                                else if(transactionName == GlobalVariableClass.COA_STOP){
                                    if(coaWithTempRestartTom.containsKey(caseObject.Id)){
                                        if(coaWithTempRestartTom.get(caseObject.Id).containsKey(subscription.Id)){  
                                            if(coaWithTempRestartTom.get(caseObject.Id).get(subscription.Id) == true){
                                                transactionName = GlobalVariableClass.STOP_URGENT;
                                            }
                                        }
                                    }
                                    
                                    if(coaInBetwnTStop.containsKey(caseObject.Id)){
                                        if(coaInBetwnTStop.get(caseObject.Id).containsKey(subscription.Id)){
                                            if(coaInBetwnTStop.get(caseObject.Id).get(subscription.Id)){
                                                transactionName = GlobalVariableClass.STOP_URGENT;
                                            }
                                        }
                                    }
                                    
                                    
                                    if(coaToKeyIdentifier_MAP.containsKey(caseObject.Id)){


                                        if(coaToKeyIdentifier_MAP.get(caseObject.Id).containsKey(subscription.Id)){
                                            if(!coaToKeyIdentifier_MAP.get(caseObject.Id).get(subscription.Id)){
                                                constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                            }
                                        }
                                    }
                                    else{
                                        constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                    }
                                    
                                    //COA_START
                                    if(coaInBetwnTStop.containsKey(caseObject.Id)){
                                        if(coaInBetwnTStop.get(caseObject.Id).containsKey(subscription.Id)){
                                            if(!coaInBetwnTStop.get(caseObject.Id).get(subscription.Id)){
                                                transactionName = GlobalVariableClass.COA_START;
                                                isSendEmail = true;

                                                if(caseObject.New_Address__c <> null && addressMapForStart.containskey(caseObject.New_Address__c)){
                                                    addressObj = new Address__c();
                                                    addressObj = addressMapForStart.get(caseObject.New_Address__c);
                                                }
                                                if(coaToKeyIdentifier_MAP.containsKey(caseObject.Id)){


                                                    if(coaToKeyIdentifier_MAP.get(caseObject.Id).containsKey(subscription.Id)){
                                                        if(!coaToKeyIdentifier_MAP.get(caseObject.Id).get(subscription.Id)){

                                                            constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                                        }
                                                    }
                             

                                                } 
                                                else{
         
                                                    constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                                }
                                            }
                                        }
                                    }
                                    //START UD-3170 05-Nov-2015 Added by S.Puli
                                    else{
                                        transactionName = GlobalVariableClass.COA_START;
                                        isSendEmail = true;
                                        
                                        if(caseObject.New_Address__c <> null && addressMapForStart.containskey(caseObject.New_Address__c)){
                                            addressObj = new Address__c();
                                            addressObj = addressMapForStart.get(caseObject.New_Address__c);
                                        }
                                        if(coaToKeyIdentifier_MAP.containsKey(caseObject.Id)){


                                            if(coaToKeyIdentifier_MAP.get(caseObject.Id).containsKey(subscription.Id)){
                                                if(!coaToKeyIdentifier_MAP.get(caseObject.Id).get(subscription.Id)){

                                                    constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                                }
                                            }
                     

                                        } 
                                        else{
 
                                            constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                        }
                                    }
                                    //END UD-3170 05-Nov-2015 Added by S.Puli
                                }
                                else {
                                    
                                //START UD-3126 12-Nov-2015 Added By S.Puli
                                    //mailTemp = 
                                if(caseObject.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription')){
                                    if(!nonProvisioningCOS.contains(subscription.Id)){  
                                        constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                        //START/END UD-3158 06-Dec-2015 Removed By S.Puli if(isSendEmail){
                                            //mailList.add(mailTemp); // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                                        //START/END UD-3158 06-Dec-2015 Removed By S.Puli } 
                                    }
                                }else{
                                    constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                    //START/END UD-3158 06-Dec-2015 Removed By S.Puli if(isSendEmail){
                                        //mailList.add(mailTemp); // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                                        
                                        
                                        
                                    //START/END UD-3158 06-Dec-2015 Removed By S.Puli }                                                                   
                                }
                                //END UD-3126 12-Nov-2015 Added By S.Puli
                                }
                            //end D-3388 11-Sept-2015 Added by S.Puli
                            }
                            //END: D-3130 18/06/2015 Added by S.Puli
                            //START D-3388 11-Sept-2015 Added By S.Puli - transfer location
                            /*
                            if(transactionName == GlobalVariableClass.COA_STOP)
                            {
                                transactionName = GlobalVariableClass.COA_START;
                                isSendEmail = true;
                                //START D-2999 05/20/2015 Added By S.Puli 2913
                                if(caseObject.New_Address__c <> null && addressMapForStart.containskey(caseObject.New_Address__c)){
                                    addressObj = new Address__c();
                                    addressObj = addressMapForStart.get(caseObject.New_Address__c);
                                }
                                //END D-2999 05/20/2015 Added By S.Puli 2913
                //Start D-2184 03/17/2014 Added by S.Puli
                                //START: D-3130 18/06/2015 Added by S.Puli
                                system.debug('caseObject COAStart'+caseObject.Id+'coaToKeyIdentifier_MAP>'+coaToKeyIdentifier_MAP);
                                if(coaToKeyIdentifier_MAP.containsKey(caseObject.Id)){
                    //START: D-3140 20/06/2015 Added by S.Puli

                                    if(coaToKeyIdentifier_MAP.get(caseObject.Id).containsKey(subscription.Id)){
                                        if(!coaToKeyIdentifier_MAP.get(caseObject.Id).get(subscription.Id)){
                                            //mailTemp = 
                                            constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                            system.debug('isSendEmail'+isSendEmail+'sendEMailCOAStart'+caseObject.Id);
                                            if(isSendEmail){
                                                //mailList.add(mailTemp); // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                                            } // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                                        }
                                    }
                    //END: D-3140 20/06/2015 Added by S.Puli

                                } 
                                else{
                                    //mailTemp = 
                                    constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                        
                                    if(isSendEmail){
                                        //mailList.add(mailTemp);
                                    }
                                }
                                //END: D-3130 18/06/2015 Added by S.Puli
                            }
                            */
                            //END D-3388 11-Sept-2015 Added By S.Puli
                            // START : UD-0982 5/12/2015 MGaelo
                            //START/END UD-0289 AddedBy FrancisBenzon : casted String to Id
                            if(caseObject.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription'))
                            {
                            // END : UD-0982 5/12/2015 MGaelo
                //START UD-3126 12-Nov-2015 Added By S.Puli
                if(!nonProvisioningCOS.contains(subscription.Id)){
                    sub = '';
                    sub = cosSubToDetailMAP.get(COS_newSubToOldSub.get(subscription.Id));
                    
                    transactionName = GlobalVariableClass.STOP_URGENT;
                    //START: D-3130 18/06/2015 Added by S.Puli
                    //mailTemp = 
                    constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                    //END: D-3130 18/06/2015 Added by S.Puli
                }
                //END UD-3126 12-Nov-2015 Added By S.Puli
                                //START/END UD-3158 06-Dec-2015 Removed By S.Puli if(isSendEmail){
                                    //mailList.add(mailTemp); // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                                    
                                //START UD-3158 06-Dec-2015 Removed By S.Puli } // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment //END UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference
                //End: D-2184 03/17/2014 Added by S.Puli
                            }
                            //End: D-2075 02/25/2014 Added by S.Puli
                            //START: D-3130 18/06/2015 Added by S.Puli
                            if((transactionName == GlobalVariableClass.TS_URGENTRESTART || transactionName == GlobalVariableClass.TS_RESTART) && caseObject.COA__c){
                                //START UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                //caseToAddressVendorMap = tempWithCoaToVendorEmail_MAP;
                                if(tempRestartWithCoaTom.containsKey(caseObject.Id)){
                                    if(!tempRestartWithCoaTom.get(caseObject.Id)){
                                        if(tempToNewAddId_MAP.containskey(caseObject.Id)){
                                            if(tempToNewAdd_MAP.containskey(tempToNewAddId_MAP.get(caseObject.Id))){
                                                addressObj = new Address__c();
                                                addressObj = tempToNewAdd_MAP.get(tempToNewAddId_MAP.get(caseObject.Id));
                                            }
                                        }
                                        //mailTemp = 
                                        constructMail (transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                                    }
                                }
                                //if(isSendEmail){
                                    //mailList.add(mailTemp); // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                                //}                            
                                //END UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                            }
                            //END UD-1820 Added by Jason A./S. Puli
                            //END: D-3130 18/06/2015 Added by S.Puli                            
                        }                                               
                        //END: D-1623 01/14/2014 Added by S.Puli
                        //END: D-1813 02/05/2015 Modified by Marvin Gatchalian - do not send an email if publication code is blank
                        //END UD-2016 27-July-2015 Added By S.Puli - add logic for multi pub
                    }
        //START D-2913 05/18/2015 Jason A./Sherwin P.
        //START UD-2016 10-Aug-2015 Added By S.Puli 
                    //toAddressesSet.clear();
        //END UD-2016 10-Aug-2015 Added By S.Puli 
                    //START UD-2016 27-July-2015 Added By S.Puli - add logic for multi pub
                    //toAddresses.clear();
                    //END UD-2016 27-July-2015 Added By S.Puli - add logic for multi pub
        //END D-2913 05/18/2015 Jason A./Sherwin P.
                }               
            }  
            
        }         
        //START UD-2016 27-July-2015 Added By S.Puli
        //insert smsOutboundList; //Start-End: MD-54 03/12/2015 Jason Abolac
        // START 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
        Database.insert(caseTeamList,false);
        //Database.insert(taskList,false); 
        // END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
        //START UD-3158 28-Nov-2015 Added By S.Puli
        //REMOVE try{
        //END UD-3158 28-Nov-2015 Added By S.Puli
    //Start: D-2075 02/25/2014 Added by S.Puli
            //Messaging.sendEmail(mailList, false);
        //END UD-2016 27-July-2015 Added By S.Puli
    //End: D-2075 02/25/2014 Added by S.Puli
        }
        catch(Exception e){
            //Start: D-2075 02/25/2014 Added by S.Puli
            exceptionList.add(e);//error handling tbd
            //End: D-2075 02/25/2014 Added by S.Puli
        }
        //Start: D-2075 02/25/2014 Added by S.Puli      
        ExceptionLogger.log(exceptionList); // you must invoke this at the end of your execution script
        //End: D-2075 02/25/2014 Added by S.Puli
    }
    
    global void finish(Database.BatchableContext BC) {
        String shortID = String.valueOf(BC.getJobId()).subString(0,15);
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :BC.getJobId()];

        if(batchJobSchedulerList.size() > 0)
        {
            BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
            batchJobScheduler.Status__c = 'SUCCESS';
            batchJobScheduler.End_Time__c = DateTime.now();
        
            BatchServiceFacade a1F = new BatchServiceFacade();
            BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
            serviceRequestVO.setJobStatus(0);
            serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
            serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
            a1F.delegateBatchCall(serviceRequestVO);

            update batchJobScheduler;           
            
      
        }   
        //START UD-2016 27-July-2015 Added By S.Puli 
        
        List<Messaging.SingleEmailMessage> mail_LIST = new List<Messaging.SingleEmailMessage>();
        List<SMS_Outbound__c> smsList = new List<SMS_Outbound__c>();
        List<Task> task_LIST = new List<Task>();
        if(mailText_Map.size() > 0){

            for(mailTextWrapper data : mailText_Map.values()){
            
                if(data.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription')){
                    for(mailTextWrapper dataCOS : mailText_Map.values()){
                        if(data.vendorId == dataCOS.vendorId && data.addressId == dataCOS.addressId){
                            if(data.transactionNameCOS == GlobalVariableClass.STOP_URGENT){
                                if(data.transactionPartnerCOS == dataCOS.transactionNameCOS){
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        mail.setToAddresses(data.mailtoAddress);
                                        mail.setSubject(GlobalVariableClass.EMAIL_DELIVERY_NOTIFICATION);
                                        //Start PD-0198 01-Jun-2016 Added By S.Puli
                                        String bodyCOS = '';
                                        bodyCOS = '';
                                        if(data.mailBodyTop <> null && data.mailBodyTop <> ''){
                                            bodyCOS += data.mailBodyTop;
                                        }
                                        if(data.mailBodyMid <> null && data.mailBodyMid <> ''){
                                            bodyCOS += data.mailBodyMid;
                                        }
                                        if(data.mailBodyBottom <> null && data.mailBodyBottom <> ''){
                                            bodyCOS += data.mailBodyBottom + '<br/>';
                                        }
                                        //End PD-0198 01-Jun-2016 Added By S.Puli
                                        bodyCOS +=  dataCOS.mailBodyTop + dataCOS.mailBodyMid + dataCOS.mailBodyBottom;
                                        
                                        mail.setHtmlBody(bodyCOS);
                                    
                                    if(data.sendMailKey){
                                        mail_LIST.add(mail);
                                    }
                                        //Start PD-0198 01-Jun-2016 Added By S.Puli
                                        String bodySMS = '';
                                        if(data.SMSmessageTop <> null && data.SMSmessageTop <> ''){
                                            bodySMS += data.SMSmessageTop;
                                        }
                                        if(data.SMSmessageMid <> null && data.SMSmessageMid <> ''){
                                            bodySMS += data.SMSmessageMid;
                                        }
                                        if(data.SMSmessageBottom <> null && data.SMSmessageBottom <> ''){
                                            bodySMS += data.SMSmessageBottom + ' ';
                                        }
                                        //End PD-0198 01-Jun-2016 Added By S.Puli
                                        bodySMS +=  dataCOS.SMSmessageTop + dataCOS.SMSmessageMid + dataCOS.SMSmessageBottom;
                                        
                                    for(String mobileNum : data.SMSMobile){
                                        SMS_Outbound__c txtMsg = new SMS_Outbound__c();
                                            txtMsg.SMS_status__c = GlobalVariableClass.STATUS_NEW;
                                            txtMsg.SMS_message__c = bodySMS;
                                            txtMsg.Mobile__c = mobileNum;
                                        smsList.add(txtMsg);
                                    }
                                    
                                    for(String conId : data.WhoId){
                                        Task taskRecord = new Task();
                                            taskRecord.OwnerId = data.OwnerId;
                                            taskRecord.WhoId = conId;
                                            taskRecord.Description = bodySMS;
                                            taskRecord.ActivityDate = Date.Today();
                                            taskRecord.subject = data.taskSubject;
                                            taskRecord.Status = 'Open';
                                        task_LIST.add(taskRecord);
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                } else{
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(data.mailtoAddress);
                        mail.setSubject(GlobalVariableClass.EMAIL_DELIVERY_NOTIFICATION);
                        mail.setHtmlBody(data.mailBodyTop + data.mailBodyMid + data.mailBodyBottom);
                        
                    if(data.sendMailKey){
                        mail_LIST.add(mail);
                    }
                    
                    for(String mobileNum : data.SMSMobile){
                        SMS_Outbound__c txtMsg = new SMS_Outbound__c();
                            txtMsg.SMS_status__c = GlobalVariableClass.STATUS_NEW;
                            txtMsg.SMS_message__c = data.SMSmessageTop + data.SMSmessageMid + data.SMSmessageBottom;
                            txtMsg.Mobile__c = mobileNum;
                        smsList.add(txtMsg);
                    }
                    
                    for(String conId : data.WhoId){
                        Task taskRecord = new Task();
                            taskRecord.OwnerId = data.OwnerId;
                            taskRecord.WhoId = conId;
                            taskRecord.Description = data.SMSmessageTop + data.SMSmessageMid + data.SMSmessageBottom;
                            taskRecord.ActivityDate = Date.Today();
                            taskRecord.subject = data.taskSubject;
                            taskRecord.Status = 'Open';
                        task_LIST.add(taskRecord);
                    }
                }
            }
            //Start UD-3457 26-Jan-2016 Added By S.Puli
            
            boolean isError = false;
            Logger logger = new Logger(SP_VendorNotificationsBatch.class.getName(), 'SP017', BC.getJobID());
            Messaging.SendEmailResult[] mailResult = Messaging.sendEmail(mail_LIST, false);
            for(Integer counter = 0; counter < mailResult.size(); counter++){
                String emailFailure = '';
                if (!mailResult[counter].isSuccess() ) {
                    for(Messaging.SendEmailError emailError : mailResult[counter].getErrors()){
                        emailFailure += '* ' + emailError.getMessage() + '\n';
                    }
                    
                    logger.log(true, emailFailure);
                    isError = true;
                }
            }
            
            //Database.insert(smsList, false);
            Database.SaveResult[] smsResult = Database.insert(smsList, false);
            for(Database.SaveResult sms : smsResult){
                String smsFailure = '';
                if (!sms.isSuccess()) {
                    for(Database.Error smsError : sms.getErrors()){
                        smsFailure += smsError.getStatusCode()+'* ' + smsError.getMessage() + '\n';
                    }
                    
                    logger.log(true, smsFailure);
                    isError = true;
                }
            }
            
            //Database.insert(task_LIST, false);
            Database.SaveResult[] taskResult = Database.insert(task_LIST, false);
            for(Database.SaveResult tas : taskResult){
                String taskFailure = '';
                if (!tas.isSuccess()) {
                    for(Database.Error taskError : tas.getErrors()){
                        taskFailure += taskError.getStatusCode()+'* ' + taskError.getMessage() + '\n';
                    }
                    
                    logger.log(true, taskFailure);
                    isError = true;
                }
            }
            
            if(isError){
                logger.save();          
            }
            //End UD-3457 26-Jan-2016 Added By S.Puli
        }
        //END UD-2016 27-July-2015 Added By S.Puli
            
    }
    
    // 1813
    public static Messaging.SingleEmailMessage getEmail() {

        Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
        mailMessage.setSaveAsActivity(false);
        return mailMessage;

    }
    // 1813
  
    
    //START D-1192 12/12/2014 JB Domingo - added method for date format                                                      
    public static String convertDateToString(Date dateValue)
    {
        Integer day = dateValue.day();
        Integer month = dateValue.month();
        Integer year= dateValue.year();
        
        String dayString;
        String monthString;
        String yearString = String.valueOf(year);
        
        if(day<10)
        {
            dayString = '0' + String.valueOf(day);
        }
        else
        {
            dayString = String.valueOf(day);
        }
        
        if(month<10)
        {
            monthString = '0' + String.valueOf(month);
        }
        else
        {
            monthString = String.valueOf(month);
        }
        
        String dateString =  dayString + '/' + monthString + '/' + yearString;
        
        return dateString;
    } 
    //END D-1192 12/12/2014 JB Domingo    
    
    //Start: D-2075 02/25/2014 Added by S.Puli
    //START: D-3130 18/06/2015 Added by S.Puli
    //START UD-1820 Added by Jason A./S. Puli
    //START UD-2016 27-July-2015 Added By S.Puli - fill up mailTextFields and put in Map mailText_Map
    //public static Messaging.SingleEmailMessage constructMail (String transactionNameParam, List<String> toAddressesParam, Case caseObjectParam, Zuora__Subscription__c subscriptionParam, Map<Id, String> conId_AliasMapParam, String issueDateParam, String subParam, Address__c addressObjParam, Singpost_Address__c singpostAddressObjParam, String classificationParam, Map<Id, List<String>> coaStartToEmails_MapParam, Map<Id, String> aliasCOAMapParam, Map<Id, id> conId_NameMapParam, String sessionId,  Map<Id, List<String>> tempCaseToVendorEmail_MAPParam, Map<Id, List<String>> tempToNewMobile_MapParam, Map<Id, List<String>> coaStartToNewMobile_MAPParam, Map<Id, Set<Id>> coaStartToTaskCon_MAPParam, Map<Id,Id> coaToUserTask_MAPParam, Map<Id, Id> tempCaseToUserId_MapParam, Map<Id, String> tempCaseToUserAlias_MapParam, Map <Id, Set<Id>>tempCaseToContacts_MapParam, Map<Id, String> coaToUserAlias_MAPParam) // START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention //Start/End: D-2184 03/17/2014 Added by S.Puli 
    public void constructMail (String transactionNameParam, List<String> toAddressesParam, Case caseObjectParam, Zuora__Subscription__c subscriptionParam, Map<Id, String> conId_AliasMapParam, String issueDateParam, String subParam, Address__c addressObjParam, Singpost_Address__c singpostAddressObjParam, String classificationParam, Map<Id, List<String>> coaStartToEmails_MapParam, Map<Id, String> aliasCOAMapParam, Map<Id, id> conId_NameMapParam, String sessionId,  Map<Id, List<String>> tempCaseToVendorEmail_MAPParam, Map<Id, List<String>> tempToNewMobile_MapParam, Map<Id, List<String>> coaStartToNewMobile_MAPParam, Map<Id, Set<Id>> coaStartToTaskCon_MAPParam, Map<Id,Id> coaToUserTask_MAPParam, Map<Id, Id> tempCaseToUserId_MapParam, Map<Id, String> tempCaseToUserAlias_MapParam, Map <Id, Set<Id>>tempCaseToContacts_MapParam, Map<Id, String> coaToUserAlias_MAPParam, boolean isSendEmailParam) // START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention //Start/End: D-2184 03/17/2014 Added by S.Puli 
    //END UD-1820 Added by Jason A./S. Puli
    //END: D-3130 18/06/2015 Added by S.Puli
    {
        
        mailTextWrapper mailTextFields = new mailTextWrapper();
        mailTextFields.SMSMobile = new List<string>();
        mailTextFields.WhoId = new List<string>();
        String key = '';
        //START D-3388 11-Sept-2015 Added By S.Puli
        //Start UD-3379 20-Jan-2016 Added By S.Puli
        if(addressObjParam <> null && subscriptionParam <> null){
            if(caseObjectParam.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription')){
                key = string.valueOf(addressObjParam.id) + string.valueOf(subscriptionParam.Vendor_1__c)+transactionNameParam+'COS';
            }
            else if(transactionNameParam == GlobalVariableClass.COA_START){
                String restartWithCoaKey = '';
                restartWithCoaKey = transactionNameParam;
                    if(coaWithTempRestartTom.containsKey(caseObjectParam.Id)){
                        if(coaWithTempRestartTom.get(caseObjectParam.Id).containsKey(subscriptionParam.Id)){    
                            if(coaWithTempRestartTom.get(caseObjectParam.Id).get(subscriptionParam.Id) == true){
                                restartWithCoaKey = GlobalVariableClass.START_NEW;
                            }
                        }
                    }
                
                key = string.valueOf(addressObjParam.id) + string.valueOf(subscriptionParam.Vendor_1__c)+restartWithCoaKey;
            }
            else if((transactionNameParam == GlobalVariableClass.TS_URGENTRESTART || transactionNameParam == GlobalVariableClass.TS_RESTART) && caseObjectParam.COA__c ){
                String restartWithCoaKey = '';
                restartWithCoaKey = GlobalVariableClass.START_NEW;
                key = string.valueOf(addressObjParam.id) + string.valueOf(subscriptionParam.Vendor_1__c)+restartWithCoaKey;
            }
            else{
                key = string.valueOf(addressObjParam.id) + string.valueOf(subscriptionParam.Vendor_1__c)+transactionNameParam;
            }
        }
        //End UD-3379 20-Jan-2016 Added By S.Puli
        //END D-3388 11-Sept-2015 Added By S.Puli
        mailTextFields.sendMailKey = false;
        if(isSendEmailParam){
            mailTextFields.sendMailKey = true;
        }
        //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //START: D-3130 18/06/2015 Added by S.Puli
                    //START: D-3130 18/06/2015 Added by S.Puli
            //if(!mailText_Map.containsKey(key)){
            
                if(transactionNameParam == GlobalVariableClass.COA_START){
                    //mail.setToAddresses(coaStartToEmails_MapParam.get(caseObjectParam.Id)); //vendor
                    //START UD-3158 06-Dec-2015 Added By S.Puli - to address attempt to de-reference null object
                    if(coaStartToEmails_MapParam.containsKey(caseObjectParam.Id)){
                        if(coaStartToEmails_MapParam.get(caseObjectParam.Id).size()>0){
                            mailTextFields.mailtoAddress = coaStartToEmails_MapParam.get(caseObjectParam.Id);
                        }
                    }
                    //END UD-3158 06-Dec-2015 Added By S.Puli
                }
                else if((transactionNameParam == GlobalVariableClass.TS_URGENTRESTART || transactionNameParam == GlobalVariableClass.TS_RESTART) && caseObjectParam.COA__c){
                    //mail.setToAddresses(tempCaseToVendorEmail_MAPParam.get(caseObjectParam.Id));
                    //START D-3388 11-Sept-2015 Added By S.Puli
                    if(tempCaseToVendorEmail_MAPParam.containsKey(caseObjectParam.Id)){
                        if(tempCaseToVendorEmail_MAPParam.get(caseObjectParam.Id).size()>0){
                            mailTextFields.mailtoAddress = tempCaseToVendorEmail_MAPParam.get(caseObjectParam.Id);
                        }
                    } else{
                        if(toAddressesParam.size()>0){  
                            mailTextFields.mailtoAddress = toAddressesParam;
                        }
                    }
                    //END D-3388 11-Sept-2015 Added By S.Puli
                }
                
                else{
                //END: D-3130 18/06/2015 Added by S.Puli
                    //mail.setToAddresses(toAddressesParam); //vendor
                    if(toAddressesParam.size()>0){  
                        mailTextFields.mailtoAddress = toAddressesParam;
                    }
                }
            //}
            //mail.setSubject('Case:'+caseObjectParam.CaseNumber+' Subscription:'+subscriptionParam.Name);Delivery Notification
            //START: D-0490 / 12/08/2014 / R.Mayo
            //Description: Fixed the format of the email 

            String output = '';
            String smsoutput = ''; //Start-End: MD-54 03/12/2015 Jason Abolac
            String output3 = '';
            String smsoutput3 = '';
            String output4 = '';
            String smsoutput4 = '';
            String output5 = '';
            String smsoutput5 = '';
            

            //START D-1983 02/25/2015 S.Puli 
            //START: D-3130 18/06/2015 Added by S.Puli
            //START UD-1820 Added by Jason A./S. Puli
            //mailBodyTop
                if(!mailText_Map.containsKey(key)){
                    if((caseObjectParam.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription') && transactionNameParam == GlobalVariableClass.STOP_URGENT) || caseObjectParam.RecordTypeId != (Id) ConstantsSLB.getKeyId('Case_Change of Subscription')){
                        //START UD-3170 05-Nov-2015 Added by S.Puli
                        if(transactionNameParam == GlobalVariableClass.COA_START && coaToUserAlias_MAPParam.size()>0 && coaToUserAlias_MAPParam.get(caseObjectParam.Id)<>null){
                            output += coaToUserAlias_MAPParam.get(caseObjectParam.Id)+' ';
                            smsoutput += coaToUserAlias_MAPParam.get(caseObjectParam.Id)+' '; //Start-End: MD-54 03/12/2015 Jason Abolac
                        }
                        //END UD-1820 Added by Jason A./S. Puli
                        else if((transactionNameParam == GlobalVariableClass.TS_URGENTRESTART || transactionNameParam == GlobalVariableClass.TS_RESTART) && caseObjectParam.COA__c){
                        //START D-3388 17-Sept-2015 Added By S.Puli
                            if(tempCaseToUserAlias_MapParam.containsKey(caseObjectParam.Id)){
                                output += tempCaseToUserAlias_MapParam.get(caseObjectParam.Id)+' ';
                                smsoutput += tempCaseToUserAlias_MapParam.get(caseObjectParam.Id)+' ';
                            }
                            else{
                                output += conId_AliasMapParam.get(subscriptionParam.Recipient_Contact__c)+' ';
                                smsoutput += conId_AliasMapParam.get(subscriptionParam.Recipient_Contact__c)+' ';
                            }
                        //END D-3388 17-Sept-2015 Added By S.Puli
                        }
                        else if(transactionNameParam <> GlobalVariableClass.COA_START && subscriptionParam.Recipient_Contact__c != null && conId_AliasMapParam.get(subscriptionParam.Recipient_Contact__c) <> null && ((transactionNameParam <> GlobalVariableClass.TS_URGENTRESTART && transactionNameParam <> GlobalVariableClass.TS_RESTART) || caseObjectParam.COA__c == false)) 
                        {
                            output += conId_AliasMapParam.get(subscriptionParam.Recipient_Contact__c)+' ';
                            smsoutput += conId_AliasMapParam.get(subscriptionParam.Recipient_Contact__c)+' '; //Start-End: MD-54 03/12/2015 Jason Abolac
                        }
                        //END UD-3170 05-Nov-2015 Added by S.Puli
                    }
                    //END: D-3130 18/06/2015 Added by S.Puli
                    //END D-1983 s.Puli
                    //START D-0490 12/12/2014 JB Domingo - Get Issue Date                                                        
                    if(issueDateParam != null){
                        issueDateParam.replace(' 00:00:00',''); 
                        output += issueDateParam+' ';
                        smsoutput += issueDateParam+' '; //Start-End: MD-54 03/12/2015 Jason Abolac
                    }
                    //END D-0490 12/12/2014 JB Domingo                               
                                 
                    if (transactionNameParam != null && transactionNameParam != 'null')
                    {
                        //START UD-0289 AddedBy FrancisBenzon : added space START UD-0289 AddedBy FrancisBenzon
                        //START: UD-0798 18/06/2015 Added by S.Puli
                        //START D-3388 11-Sept-2015 Added By S.Puli
                        if(transactionNameParam == GlobalVariableClass.COA_START){
                            String newTransName = '';
                            newTransName = transactionNameParam;
                            
                            if(coaWithTempRestartTom.containsKey(caseObjectParam.Id)){
                                if(coaWithTempRestartTom.get(caseObjectParam.Id).containsKey(subscriptionParam.Id)){    
                                    if(coaWithTempRestartTom.get(caseObjectParam.Id).get(subscriptionParam.Id) == true){
                                        newTransName = GlobalVariableClass.START_NEW;
                                    }
                                }
                            }
                            
                            output += '-' + newTransName + ' ' + '&nbsp;' +'</br>';
                            //END: UD-0798 18/06/2015 Added by S.Puli
                            smsoutput += '-' + newTransName + ' ' + ' '; //Start-End: MD-54 03/12/2015 Jason Abolac
                        }
                        else if((transactionNameParam == GlobalVariableClass.TS_URGENTRESTART || transactionNameParam == GlobalVariableClass.TS_RESTART) && caseObjectParam.COA__c ){
                            String newTransNameRestart = '';
                            newTransNameRestart = GlobalVariableClass.START_NEW;
                            
                            output += '-' + newTransNameRestart + ' ' + '&nbsp;' +'</br>';
                            smsoutput += '-' + newTransNameRestart + ' ' + ' ';
                        }
                        else{
                            output += '-' + transactionNameParam + ' ' + '&nbsp;' +'</br>';
                            //END: UD-0798 18/06/2015 Added by S.Puli
                            smsoutput += '-' + transactionNameParam + ' ' + ' '; //Start-End: MD-54 03/12/2015 Jason Abolac
                        }
                        //END D-3388 11-Sept-2015 Added By S.Puli
                        //END UD-0289 AddedBy FrancisBenzon : added space START UD-0289 AddedBy FrancisBenzon
                    }
                    //Start PD-0198 01-Jun-2016 Added By S.Puli
                    if(caseObjectParam.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription') && transactionNameParam == GlobalVariableClass.STOP_URGENT && subParam == null){
                        output = '';
                        smsoutput = '';
                        if(conId_AliasMapParam.get(subscriptionParam.Recipient_Contact__c) <> null){
                            output = conId_AliasMapParam.get(subscriptionParam.Recipient_Contact__c)+' ';
                            smsoutput = conId_AliasMapParam.get(subscriptionParam.Recipient_Contact__c)+' ';
                            mailTextFields.mailBodyTop = output;
                            mailTextFields.SMSmessageTop = smsoutput;
                        }
                    }else{
                        mailTextFields.mailBodyTop = output;
                        mailTextFields.SMSmessageTop = smsoutput;
                    }
                    //End PD-0198 01-Jun-2016 Added By S.Puli
                }
            
            //mailBodyMid
            if(!mailText_Map.containsKey(key)){
                if (subParam != null && subParam != 'null')

                {
                    output4 += subParam.removeEnd(' ');
                    smsoutput4 += subParam.removeEnd(' '); //Start-End: MD-54 03/12/2015 Jason Abolac
                    //Start PD-0198 01-Jun-2016 Added By S.Puli
                    if(caseObjectParam.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription') && transactionNameParam == GlobalVariableClass.STOP_URGENT && subParam == null){
                        output4 = '';
                        smsoutput4 = '';
                    }else{
                        mailTextFields.mailBodyMid = output4;
                        mailTextFields.SMSmessageMid = smsoutput4;
                    }
                    //End PD-0198 01-Jun-2016 Added By S.Puli
                }
            }else {
                if (subParam != null && subParam != 'null')
                {
                    String newSub = '';
                    newSub = mailText_Map.get(key).mailBodyMid + ', '+subParam.removeEnd(' ');
                    //Start PD-0198 01-Jun-2016 Added By S.Puli
                    if(caseObjectParam.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription') && transactionNameParam == GlobalVariableClass.STOP_URGENT && subParam == null){
                        newSub = '';
                    }else{
                        mailText_Map.get(key).mailBodyMid = newSub;
                        mailText_Map.get(key).SMSmessageMid = newSub;
                    }
                    //End PD-0198 01-Jun-2016 Added By S.Puli
                }
            }
            //mailBodyBottom
            if(!mailText_Map.containsKey(key)){
                output3 += '</br>'+' @';
                smsoutput3 += ' '+' @';
                //START UD-0289 AddedBy FrancisBenzon : checking of null pointer for possible null address
                if(addressObjParam != null)
                {
                    if (addressObjParam.Block_House_Number__c != null)
                    {
                        output3 += string.valueOf(addressObjParam.Block_House_Number__c)+' ';
                        smsoutput3 += string.valueOf(addressObjParam.Block_House_Number__c)+' '; //Start-End: MD-54 03/12/2015 Jason Abolac
                    }

                    if (addressObjParam.Street_Name__c != null)
                    //START: D-0490 / 12/09/2014 / R.Mayo
                    //Description: Fixed the format of the email 
                    {
                        output3 += addressObjParam.Street_Name__c+' ';
                        smsoutput3 += addressObjParam.Street_Name__c+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
                    }
                    //END: D-0490 / 12/09/2014 / R.Mayo

                    if (addressObjParam.Building_Name__c != null)
                    //START: D-0490 / 12/09/2014 / R.Mayo
                    //Description: Fixed the format of the email 
                    {
                        output3 += addressObjParam.Building_Name__c+' ';
                        smsoutput3 += addressObjParam.Building_Name__c+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
                    }
                    //END: D-0490 / 12/09/2014 / R.Mayo

                    if (addressObjParam.Level_Number__c != null)

                    {
                    //START D-2075 02/27/2015 S.Puli
                        output3 += '#'+string.valueOf(addressObjParam.Level_Number__c);
                        smsoutput3 += '#'+string.valueOf(addressObjParam.Level_Number__c);  //Start-End: MD-54 03/12/2015 Jason Abolac
                    //End D-2075 02/27/2015 S.Puli
                    }

                    if (addressObjParam.Unit_Number__c != null)
                    {
                    //START D-2075 02/27/2015 S.Puli
                        output3 += '-'+string.valueOf(addressObjParam.Unit_Number__c)+' ';
                        smsoutput3 += '-'+string.valueOf(addressObjParam.Unit_Number__c)+' ';  //Start-End: MD-54 03/12/2015 Jason Abolac
                    //End D-2075 02/27/2015 S.Puli
                    }
                }           
                //END UD-0289 AddedBy FrancisBenzon : checking of null pointer for possible null address
                //Start D-3117 06/17 remove by Jason A.    
                    //output3 += ' '+subscriptionParam.Classification__c+' ';
                //End D-3117 06/17 remove by Jason A.  
                    output3 += ' ' + classificationParam + ' ' ;
                    smsoutput3 += ' ' + classificationParam + ' ' ;  //Start-End: MD-54 03/12/2015 Jason Abolac
                //Start PD-0198 01-Jun-2016 Added By S.Puli
                if(caseObjectParam.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription') && transactionNameParam == GlobalVariableClass.STOP_URGENT && subParam == null){
                    output3 = '';
                    smsoutput3 = '';
                }else{
                    mailTextFields.mailBodyBottom = output3;
                    mailTextFields.SMSmessageBottom = smsoutput3;
                }
                //End PD-0198 01-Jun-2016 Added By S.Puli
            }   
            
            
                //START: D-0490 / 12/10/2014 / R.Mayo
                //Description: Fixed the null
                //START: D-2522 03/18/2014 Added by S.Puli
                if(caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop')){
                    if (caseObjectParam.Temp_Stop__r.Remarks__c != null && caseObjectParam.Temp_Stop__r.Remarks__c != '')
                    //END: D-0490 / 12/10/2014 / R.Mayo


                    //START: D-0490 / 12/09/2014 / R.Mayo
                    //Description: Fixed the format of the email 
                    {
                        output5 += ' (' + caseObjectParam.Temp_Stop__r.Remarks__c + ') ';
                        //START 04/09/2015 D-2636 and D-2638 Kevin Evasco updated sms output to have the same value as email output.
                        smsoutput5 += ' (' + caseObjectParam.Temp_Stop__r.Remarks__c + ') ';  //Start-End: MD-54 03/12/2015 Jason Abolac 
                        //END 04/09/2015 D-2636 and D-2638 Kevin Evasco updated sms output to have the same value as email output.
                        if(!mailRemarks_Map.containsKey(caseObjectParam.Id)){   
                            mailRemarks_Map.put(caseObjectParam.Id, subscriptionParam.Id);
                            if(!mailText_Map.containsKey(key)){
                                mailTextFields.mailBodyBottom = mailTextFields.mailBodyBottom + output5;
                                mailTextFields.SMSmessageBottom = mailTextFields.SMSmessageBottom + smsoutput5;
                            }else{
                                mailText_Map.get(key).mailBodyBottom = mailText_Map.get(key).mailBodyBottom + ', '+output5;
                                mailText_Map.get(key).SMSmessageBottom = mailText_Map.get(key).SMSmessageBottom + ', '+smsoutput5;
                            }
                        }
                    }
                //Start: D-2549 03/24/15 Jason Abolac
                } 
                // START : UD-0982 5/12/2015 MGaelo
                //START/END UD-0289 AddedBy FrancisBenzon : casted string to Id
                //START D-2999 05/21/2015 Jason A./Sherwin P.
                else if(caseObjectParam.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription') || caseObjectParam.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change in Address')){
                //END D-2999 05/21/2015 Jason A./Sherwin P.
                    if (caseObjectParam.Remarks__c != null && caseObjectParam.Remarks__c != '')
                    //END: D-0490 / 12/10/2014 / R.Mayo


                    //START: D-0490 / 12/09/2014 / R.Mayo
                    //Description: Fixed the format of the email 
                    {
                        output5 += ' (' + caseObjectParam.Remarks__c + ') ';
                        //START 04/09/2015 D-2636 and D-2638 Kevin Evasco updated sms output to have the same value as email output.
                        smsoutput5 += ' (' + caseObjectParam.Remarks__c + ') ';
                        //END 04/09/2015 D-2636 and D-2638 Kevin Evasco updated sms output to have the same value as email output.
                        //Start PD-0198 01-Jun-2016 Added By S.Puli
                        if((caseObjectParam.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription') && transactionNameParam == GlobalVariableClass.STOP_URGENT && subParam <> null) || caseObjectParam.RecordTypeId <> (Id) ConstantsSLB.getKeyId('Case_Change of Subscription')){
                            if(!mailRemarks_Map.containsKey(caseObjectParam.Id)){   
                                mailRemarks_Map.put(caseObjectParam.Id, subscriptionParam.Id);
                                if(!mailText_Map.containsKey(key)){
                                    mailTextFields.mailBodyBottom = mailTextFields.mailBodyBottom + output5;
                                    mailTextFields.SMSmessageBottom = mailTextFields.SMSmessageBottom + smsoutput5;
                                }else{
                                    mailText_Map.get(key).mailBodyBottom = mailText_Map.get(key).mailBodyBottom + ', '+output5;
                                    mailText_Map.get(key).SMSmessageBottom = mailText_Map.get(key).SMSmessageBottom + ', '+smsoutput5;
                                }
                            }else if(transactionNameParam == GlobalVariableClass.COA_START || transactionNameParam == GlobalVariableClass.STOP_URGENT){
                                if(mailRemarks_Map.containsKey(caseObjectParam.Id)){
                                    if(mailRemarks_Map.get(caseObjectParam.Id) == subscriptionParam.Id){
                                        if(!mailText_Map.containsKey(key)){
                                            mailTextFields.mailBodyBottom = mailTextFields.mailBodyBottom + output5;
                                            mailTextFields.SMSmessageBottom = mailTextFields.SMSmessageBottom + smsoutput5;
                                        }else{
                                            mailText_Map.get(key).mailBodyBottom = mailText_Map.get(key).mailBodyBottom + ', '+output5;
                                            mailText_Map.get(key).SMSmessageBottom = mailText_Map.get(key).SMSmessageBottom + ', '+smsoutput5;
                                        }
                                    }
                                }
                            }
                        }
                        //End PD-0198 01-Jun-2016 Added By S.Puli
                    }
                }
                //End: D-2549 03/24/15 Jason Abolac
                else {
                //END: D-2522 03/18/2014 Added by S.Puli
                    if (subscriptionParam.Order_Number_1__r.Vendor_Sms_Remarks__c != null && subscriptionParam.Order_Number_1__r.Vendor_Sms_Remarks__c != '')
                    //END: D-0490 / 12/10/2014 / R.Mayo


                    //START: D-0490 / 12/09/2014 / R.Mayo
                    //Description: Fixed the format of the email 
                    {
                        output5 += ' ('+subscriptionParam.Order_Number_1__r.Vendor_Sms_Remarks__c+') ';
                        smsoutput5 += ' ('+subscriptionParam.Order_Number_1__r.Vendor_Sms_Remarks__c+') ';  //Start-End: MD-54 03/12/2015 Jason Abolac
                        if(!mailRemarks_Map.containsKey(caseObjectParam.Id)){   
                            mailRemarks_Map.put(caseObjectParam.Id, subscriptionParam.Id);
                            if(!mailText_Map.containsKey(key)){
                                mailTextFields.mailBodyBottom = mailTextFields.mailBodyBottom + output5;
                                mailTextFields.SMSmessageBottom = mailTextFields.SMSmessageBottom + smsoutput5;
                            }else{
                                mailText_Map.get(key).mailBodyBottom = mailText_Map.get(key).mailBodyBottom + ', '+output5;
                                mailText_Map.get(key).SMSmessageBottom = mailText_Map.get(key).SMSmessageBottom + ', '+output5;
                            }
                        }
                    }
                }//START/END: D-2522 03/18/2014 Added by S.Puli
                //END: D-0490 / 12/09/2014 / R.Mayo
                
                
            /* START : UD-0982 5/12/2015 MGaelo - Move
            //Start: MD-54 03/12/2015 Jason Abolac                   
            for(String venStaffMobNum : venStaffMobileNumberList){
                if(venStaffMobNum != null){
                    bound = new SMS_Outbound__c();
                    bound.SMS_status__c = 'New';
                    bound.SMS_message__c = smsoutput;
                    bound.Mobile__c = venStaffMobNum;
                    smsOutboundList.add(bound);
                }           
            }
            //START UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference    
            if((subscriptionParam.Vendor_1__r.Vendor_Communication_Preference__c == 'Both' || subscriptionParam.Vendor_1__r.Vendor_Communication_Preference__c == 'SMS') && subscriptionParam.Vendor_1__r.Active__c){
                if(venMobileNumber != null){
                    bound = new SMS_Outbound__c();
                    bound.SMS_status__c = 'New';
                    bound.SMS_message__c = smsoutput;
                    bound.Mobile__c = venMobileNumber;
                    smsOutboundList.add(bound);
                }
            }
            //END UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference
            //End: MD-54 03/12/2015 Jason Abolac
            END : UD-0982 5/12/2015 MGaelo */
        
        // START 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
        
        //START: D-3130 18/06/2015 Added by S.Puli
        if(transactionNameParam == GlobalVariableClass.COA_START){
            if(coaStartToTaskCon_MAPParam.containsKey(caseObjectParam.Id) && coaToUserTask_MAPParam.containsKey(caseObjectParam.Id)){
                for(Id venStaff : coaStartToTaskCon_MAPParam.get(caseObjectParam.Id)){
                        if(conId_NameMapParam.containsKey(subscriptionParam.Vendor_1__r.Id)){
                            if(conId_NameMapParam.get(subscriptionParam.Vendor_1__r.Id) != NULL) {
                                //task = new task();
                                //task.OwnerId = coaToUserTask_MAPParam.get(caseObjectParam.Id);
                                //task.WhatId = caseObjectParam.Id;
                                //task.WhoId = venStaff;
                                //task.Description = smsoutput;
                                //task.ActivityDate = Date.today();
                                //task.subject = 'Notification (' + caseObjectParam.RecordType.Name + ')';
                                //task.Status = 'Open';                   
                                //taskList.add(task);
                                mailTextFields.OwnerId = coaToUserTask_MAPParam.get(caseObjectParam.Id);
                                mailTextFields.WhoId.add(venStaff);
                                mailTextFields.taskSubject = 'Notification (' + caseObjectParam.RecordType.Name + ')';
      
                            if(vendorStaffId_partnerUser.containsKey(venStaff)){
                                CaseTeamMember member = new CaseTeamMember();
                                member.ParentId = caseObjectParam.Id;
                                member.MemberId = vendorStaffId_partnerUser.get(venStaff).Id;                   
                                member.TeamRoleId = vendorRepRoleId;                
                                caseTeamList.add(member);
                            }
                            
     
                            }
                        }

                }
            }
        }
        else if((transactionNameParam == GlobalVariableClass.TS_URGENTRESTART || transactionNameParam == GlobalVariableClass.TS_RESTART) && caseObjectParam.COA__c){
            if(tempCaseToContacts_MapParam.containsKey(caseObjectParam.Id) && tempCaseToUserId_MapParam.containsKey(caseObjectParam.Id)){
                for(Id venStaff : tempCaseToContacts_MapParam.get(caseObjectParam.Id)){
                    if(caseObjectParam.RecordTypeId != ConstantsSLB.getKeyId('Case_Change of Subscription')){ 
                    
                        if(conId_NameMapParam.containsKey(subscriptionParam.Vendor_1__r.Id)){
                            if(conId_NameMapParam.get(subscriptionParam.Vendor_1__r.Id) != NULL) {
                                //task = new task();
                                //task.OwnerId = tempCaseToUserId_MapParam.get(caseObjectParam.Id);
                                //task.WhatId = caseObjectParam.Id;
                                //task.WhoId = venStaff;
                                //task.Description = smsoutput;
                                //task.ActivityDate = Date.today();
                                //task.subject = 'Notification (' + caseObjectParam.RecordType.Name + ')';
                                //task.Status = 'Open';                   
                                //taskList.add(task);    
                                mailTextFields.OwnerId = tempCaseToUserId_MapParam.get(caseObjectParam.Id);
                                mailTextFields.WhoId.add(venStaff);
                                mailTextFields.taskSubject = 'Notification (' + caseObjectParam.RecordType.Name + ')';
         
                            if(vendorStaffId_partnerUser.containsKey(venStaff)){
                                CaseTeamMember member = new CaseTeamMember();
                                member.ParentId = caseObjectParam.Id;
                                member.MemberId = vendorStaffId_partnerUser.get(venStaff).Id;                   
                                member.TeamRoleId = vendorRepRoleId;                
                                caseTeamList.add(member);
                            }
                            
     
                            }
                        }
                        
                    } 
                }
            }
        }
        else{
            for(String venStaff : venStaffid){
                if(caseObjectParam.RecordTypeId != ConstantsSLB.getKeyId('Case_Change of Subscription')){  //Start/End: D-2544 04/16/2015 Added by J.Abolac
                    // START : D-2566 4/21/2015 Alyana Navarro
                    if(conId_NameMapParam.containsKey(subscriptionParam.Vendor_1__r.Id)){
                        if(conId_NameMapParam.get(subscriptionParam.Vendor_1__r.Id) != NULL) {
                            //task = new task();
                            //task.OwnerId = conId_NameMapParam.get(subscriptionParam.Vendor_1__r.Id);
                            //task.WhatId = caseObjectParam.Id;
                            //task.WhoId = venStaff;
                            //task.Description = smsoutput;
                            //task.ActivityDate = Date.today();
                            //task.subject = 'Notification (' + caseObjectParam.RecordType.Name + ')';
                            //task.Status = 'Open';                   
                            //taskList.add(task);      
                            mailTextFields.OwnerId = conId_NameMapParam.get(subscriptionParam.Vendor_1__r.Id);
                            mailTextFields.WhoId.add(venStaff);
                            mailTextFields.taskSubject = 'Notification (' + caseObjectParam.RecordType.Name + ')';
                            
                    //START UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference       
                        if(vendorStaffId_partnerUser.containsKey(venStaff)){
                            CaseTeamMember member = new CaseTeamMember();
                            member.ParentId = caseObjectParam.Id;
                            member.MemberId = vendorStaffId_partnerUser.get(venStaff).Id;                   
                            member.TeamRoleId = vendorRepRoleId;                
                            caseTeamList.add(member);
                        }
                        
                    //END UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference    
                        }
                    }
                    // END : D-2566 4/21/2015 Alyana Navarro
                } //Start/End: D-2544 04/16/2015 Added by J.Abolac
            }
        }

        //END: D-3130 18/06/2015 Added by S.Puli
        // END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
            
        // START : UD-0982 5/12/2015 MGaelo
        //START/END UD-0289 AddedBy FrancisBenzon : casted string to Id
        mailTextFields.RecordTypeId = null;
        if(caseObjectParam.RecordTypeId == (Id) ConstantsSLB.getKeyId('Case_Change of Subscription')){
        // END : UD-0982 5/12/2015 MGaelo
            mailTextFields.RecordTypeId =(Id) ConstantsSLB.getKeyId('Case_Change of Subscription');
            if(addressObjParam <> null)//Start/End PD-0145 16-Apr-2016 Added By S.Puli
                mailTextFields.addressId = string.valueOf(addressObjParam.id);
            mailTextFields.vendorId = string.valueOf(subscriptionParam.Vendor_1__c);
            if(transactionNameParam == GlobalVariableClass.START_NEW  || transactionNameParam == GlobalVariableClass.START_URGENT ){
                subToOutputMAP.put(subscriptionParam.Id, transactionNameParam);
                
                subToSmsOutputMAP.put(subscriptionParam.Id, smsoutput); //Start/End: D-2544 04/16/2015 Added by J.Abolac
                if(transactionNameParam == GlobalVariableClass.START_NEW){
                    mailTextFields.transactionNameCOS = GlobalVariableClass.START_NEW;
                }else{
                    mailTextFields.transactionNameCOS = GlobalVariableClass.START_URGENT;
                }
            } else{
                mailTextFields.transactionNameCOS = GlobalVariableClass.STOP_URGENT;
                if(subToOutputMAP.containsKey(subscriptionParam.Id)){
                    if(subToOutputMAP.get(subscriptionParam.Id) == GlobalVariableClass.START_NEW){
                        mailTextFields.transactionPartnerCOS = GlobalVariableClass.START_NEW;
                    } else {
                        mailTextFields.transactionPartnerCOS = GlobalVariableClass.START_URGENT;
                    }
                }
                string totalOutput = '';                
                string smstotaloutput = ''; //Start/End: D-2544 04/16/2015 Added by J.Abolac
                // START : UD-0982 5/12/2015 MGaelo
                //START UD-0289 AddedBy FrancisBenzon : cut alias for 2nd instance of string
                //Integer indexOutputemail = subToOutputMAP.get(subscriptionParam.Id).indexOf(' ') + 1;
                //String output2 = subToOutputMAP.get(subscriptionParam.Id).substring(indexOutputemail, subToOutputMAP.get(subscriptionParam.Id).length());
                Integer indexOutputSMS = subToSmsOutputMAP.get(subscriptionParam.Id).indexOf(' ') + 1;
                String smsoutput2 = subToSmsOutputMAP.get(subscriptionParam.Id).substring(indexOutputSMS, subToSmsOutputMAP.get(subscriptionParam.Id).length());
                
                //totalOutput = output + '<br/>'+ output2; //Start - End: D-2549 03/24/15 Jason Abolac
                smstotaloutput = smsoutput + ' ' + smsoutput2; //Start/End: D-2544 04/16/2015 Added by J.Abolac              
                //END UD-0289 AddedBy FrancisBenzon : cut alias for 2nd instance of string
                // END : UD-0982 5/12/2015 MGaelo
                    //mail.setHtmlBody(totalOutput); UD-2016
                // START : UD-0982 5/12/2015 MGaelo
                //Start: MD-54 03/12/2015 Jason Abolac                   
                for(String venStaffMobNum : venStaffMobileNumberList){
                    if(venStaffMobNum != null){
                        //bound = new SMS_Outbound__c();
                        //bound.SMS_status__c = 'New';
                        //bound.SMS_message__c = smstotaloutput;
                        //bound.Mobile__c = venStaffMobNum;
                        //smsOutboundList.add(bound);
                        mailTextFields.SMSMobile.add(venStaffMobNum);
                    }           
                }
                //START UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference    
                if((subscriptionParam.Vendor_1__r.Vendor_Communication_Preference__c == 'Both' || subscriptionParam.Vendor_1__r.Vendor_Communication_Preference__c == 'SMS') && subscriptionParam.Vendor_1__r.Active__c){
                    if(venMobileNumber != null){
                        //bound = new SMS_Outbound__c();
                        //bound.SMS_status__c = 'New';
                        //bound.SMS_message__c = smstotaloutput;
                        //bound.Mobile__c = venMobileNumber;
                        //smsOutboundList.add(bound);
                        mailTextFields.SMSMobile.add(venMobileNumber);
                    }
                }
                //END UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference
                //End: MD-54 03/12/2015 Jason Abolac
                // END : UD-0982 5/12/2015 MGaelo
                    //Start: D-2544 04/16/2015 Added by J.Abolac
                    for(String venStaff : venStaffid){
                        // START : D-2566 4/21/2015 Alyana Navarro
                        if(conId_NameMapParam.containsKey(subscriptionParam.Vendor_1__c)){
                            if(conId_NameMapParam.get(subscriptionParam.Vendor_1__c) != NULL) {
                                //task = new task();
                                //task.OwnerId = conId_NameMapParam.get(subscriptionParam.Vendor_1__c);
                                //task.WhatId = caseObjectParam.Id;
                                //task.WhoId = venStaff;
                                //task.Description = smstotaloutput;
                                //task.ActivityDate = Date.today();
                                //task.subject = 'Notification (' + caseObjectParam.RecordType.Name + ')';
                                //task.Status = 'Open';
                                //taskList.add(task);
                                mailTextFields.OwnerId = conId_NameMapParam.get(subscriptionParam.Vendor_1__c);
                                mailTextFields.WhoId.add(venStaff);
                                mailTextFields.taskSubject = 'Notification (' + caseObjectParam.RecordType.Name + ')';
                        // START : UD-0982 5/12/2015 MGaelo
                                if(vendorStaffId_partnerUser.containsKey(venStaff)){
                                    CaseTeamMember member = new CaseTeamMember();
                                    member.ParentId = caseObjectParam.Id;
                                    member.MemberId = vendorStaffId_partnerUser.get(venStaff).Id;
                                    member.TeamRoleId = vendorRepRoleId;                
                                    caseTeamList.add(member);
                                }
                        // END : UD-0982 5/12/2015 MGaelo
                                
                            }
                        }
                        // END : D-2566 4/21/2015 Alyana Navarro
                    }
                    //End: D-2544 04/16/2015 Added by J.Abolac
                
            }
        } else{//End: D-2184 03/17/2014 Added by S.Puli
        //mail.setHtmlBody(output); UD-2016
        // START : UD-0982 5/12/2015 MGaelo
        //Start: MD-54 03/12/2015 Jason Abolac                   
        for(String venStaffMobNum : venStaffMobileNumberList){
            if(venStaffMobNum != null){
                //bound = new SMS_Outbound__c();
                //bound.SMS_status__c = 'New';
                //bound.SMS_message__c = smsoutput;
                //START: D-3130 18/06/2015 Added by S.Puli
                    if(((transactionNameParam == GlobalVariableClass.TS_URGENTRESTART || transactionNameParam == GlobalVariableClass.TS_RESTART) && caseObjectParam.COA__c) || transactionNameParam == GlobalVariableClass.COA_START){
                        //bound.Mobile__c = null;
                        mailTextFields.SMSMobile.clear();
                    }
                    else{
                        //bound.Mobile__c = venStaffMobNum;
                        //smsOutboundList.add(bound);
                        mailTextFields.SMSMobile.add(venStaffMobNum);
                    }
                //END: D-3130 18/06/2015 Added by S.Puli  
            }           
        }
        //START UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference  
        //START: D-3130 18/06/2015 Added by S.Puli      
        //if((subscriptionParam.Vendor_1__r.Vendor_Communication_Preference__c == 'Both' || subscriptionParam.Vendor_1__r.Vendor_Communication_Preference__c == 'SMS') && subscriptionParam.Vendor_1__r.Active__c){
            
            
            if((transactionNameParam == GlobalVariableClass.TS_URGENTRESTART || transactionNameParam == GlobalVariableClass.TS_RESTART) && caseObjectParam.COA__c){
                if(tempToNewMobile_MapParam.size()>0 && tempToNewMobile_MapParam.containsKey(caseObjectParam.Id)){
                    for(String num : tempToNewMobile_MapParam.get(caseObjectParam.Id)){
                        //bound = new SMS_Outbound__c();
                        //bound.SMS_status__c = 'New';
                        //bound.SMS_message__c = smsoutput;
                        //bound.Mobile__c = num;
                        //smsOutboundList.add(bound);
                        mailTextFields.SMSMobile.add(num);
                    }
                }
            }
            else if(transactionNameParam == GlobalVariableClass.COA_START){
                if(coaStartToNewMobile_MAPParam.size()>0 && coaStartToNewMobile_MAPParam.containsKey(caseObjectParam.Id)){
                    for(String num : coaStartToNewMobile_MAPParam.get(caseObjectParam.Id)){
                        //bound = new SMS_Outbound__c();
                        //bound.SMS_status__c = 'New';
                        //bound.SMS_message__c = smsoutput;
                        //bound.Mobile__c = num;
                        //smsOutboundList.add(bound);
                        mailTextFields.SMSMobile.add(num);
                    }
                }
            }else{
                if(venMobileNumber != null){
                   
                    //bound = new SMS_Outbound__c();
                    //bound.SMS_status__c = 'New';
                    //bound.SMS_message__c = smsoutput;
                    //bound.Mobile__c = venMobileNumber;
                    //smsOutboundList.add(bound);
                    mailTextFields.SMSMobile.add(venMobileNumber);
                    
                
                }
            }
        //}
        //END: D-3130 18/06/2015 Added by S.Puli
        //END UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference
        //End: MD-54 03/12/2015 Jason Abolac
        // END : UD-0982 5/12/2015 MGaelo
                        
        //END: D-0490 / 12/08/2014 / R.Mayo
        //Description: Fixed the format of the email   
        }//Start/End: D-2184 03/17/2014 Added by S.Puli
        //return mail;
        
        if(!mailText_Map.containsKey(key)){
            mailText_Map.put(key, mailTextFields);
        }
        system.debug('mailText_Map>>'+mailText_Map);
    //END UD-2016 27-July-2015 Added By S.Puli 
    }
    //End: D-2075 02/25/2014 Added by S.Puli    
    
    //START UD-3126 12-Nov-2015 Added By S.Puli
    public boolean checkForNonProvision(Zuora__Subscription__c cosNewSubRec, Zuora__Subscription__c cosOldSubRec, Map<Id, Set<String>> newSubToSpc, Map<Id, Set<String>> oldSubToSpc, Map<String, Publication__c> publicationMap, Map<String, Publication__c> noSundayPubMap){
        boolean provKey = false;
        if(cosNewSubRec.Number_of_Copies__c  == cosOldSubRec.Number_of_Copies__c){
            if(oldSubToSpc.containsKey(cosOldSubRec.Id)){
                if(newSubToSpc.containsKey(cosNewSubRec.Id)){
                    for(String oldPub : oldSubToSpc.get(cosOldSubRec.Id)){
                        for(String newPub : newSubToSpc.get(cosNewSubRec.Id)){
                            if(oldPub == newPub){
                                if(cosNewSubRec.Frequency_1__c  == cosOldSubRec.Frequency_1__c){
                                    provKey = true;
                                }else if(cosNewSubRec.Frequency_1__c == 'Default'){
                                    if(publicationMap.containsKey(newPub)){
                                        if(cosOldSubRec.Frequency_1__c == 'Mon - Fri' && publicationMap.get(newPub).Published_Days__c == 'YYYYYNN'){
                                            provKey = true;
                                        }
                                        else if(cosOldSubRec.Frequency_1__c == 'Fri - Sun' && publicationMap.get(newPub).Published_Days__c == 'NNNNYYY'){
                                            provKey = true;
                                        }
                                        else if(cosOldSubRec.Frequency_1__c == 'Sat - Sun' && publicationMap.get(newPub).Published_Days__c == 'NNNNNYY'){
                                            provKey = true;
                                        }
                                        else if(cosOldSubRec.Frequency_1__c == 'Mon - Sat' && publicationMap.get(newPub).Published_Days__c == 'YYYYYYN'){
                                            provKey = true;
                                        }
                                    }
                                    else if(noSundayPubMap.containsKey(newPub)){
                                        if(cosOldSubRec.Frequency_1__c == 'Mon - Fri' && noSundayPubMap.get(newPub).Published_Days__c == 'YYYYYNN'){
                                            provKey = true;
                                        }
                                        else if(cosOldSubRec.Frequency_1__c == 'Fri - Sun' && noSundayPubMap.get(newPub).Published_Days__c == 'NNNNYYY'){
                                            provKey = true;
                                        }
                                        else if(cosOldSubRec.Frequency_1__c == 'Sat - Sun' && noSundayPubMap.get(newPub).Published_Days__c == 'NNNNNYY'){
                                            provKey = true;
                                        }
                                        else if(cosOldSubRec.Frequency_1__c == 'Mon - Sat' && noSundayPubMap.get(newPub).Published_Days__c == 'YYYYYYN'){
                                            provKey = true;
                                        }
                                    }
                                }else if(cosOldSubRec.Frequency_1__c == 'Default'){
                                    if(publicationMap.containsKey(oldPub)){
                                        if(cosNewSubRec.Frequency_1__c == 'Mon - Fri' && publicationMap.get(oldPub).Published_Days__c == 'YYYYYNN'){
                                            provKey = true;
                                        }
                                        else if(cosNewSubRec.Frequency_1__c == 'Fri - Sun' && publicationMap.get(oldPub).Published_Days__c == 'NNNNYYY'){
                                            provKey = true;
                                        }
                                        else if(cosNewSubRec.Frequency_1__c == 'Sat - Sun' && publicationMap.get(oldPub).Published_Days__c == 'NNNNNYY'){
                                            provKey = true;
                                        }
                                        else if(cosNewSubRec.Frequency_1__c == 'Mon - Sat' && publicationMap.get(oldPub).Published_Days__c == 'YYYYYYN'){
                                            provKey = true;
                                        }
                                    }
                                    else if(noSundayPubMap.containsKey(oldPub)){
                                        if(cosNewSubRec.Frequency_1__c == 'Mon - Fri' && noSundayPubMap.get(oldPub).Published_Days__c == 'YYYYYNN'){
                                            provKey = true;
                                        }
                                        else if(cosNewSubRec.Frequency_1__c == 'Fri - Sun' && noSundayPubMap.get(oldPub).Published_Days__c == 'NNNNYYY'){
                                            provKey = true;
                                        }
                                        else if(cosNewSubRec.Frequency_1__c == 'Sat - Sun' && noSundayPubMap.get(oldPub).Published_Days__c == 'NNNNNYY'){
                                            provKey = true;
                                        }
                                        else if(cosNewSubRec.Frequency_1__c == 'Mon - Sat' && noSundayPubMap.get(oldPub).Published_Days__c == 'YYYYYYN'){
                                            provKey = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
                
        return provKey;
    }
    //END UD-3126 12-Nov-2015 Added By S.Puli
    
}