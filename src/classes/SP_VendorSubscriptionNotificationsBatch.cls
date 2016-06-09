/*
 * Class Name: SP_VendorSubscriptionNotificationsBatch 
 * @author: Marvin Gatchalian
 * Date: 03/03/2015  - During UAT phase
 * Requirement/Project Name: Singapore Press Holdings
 * @describption Batch Class that send email notifications to Vendor and Vendor Staff for Vendor Subscriber
 */
//START D-2212 
global class SP_VendorSubscriptionNotificationsBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    //Start UD-3457 26-Jan-2016 Added By S.Puli
    list<exception> exceptionList = new list<exception>(); // declare this at the outermost within your class
    //End UD-3457 26-Jan-2016 Added By S.Puli
     global Batch_Configuration_Settings__c batchSettings; //by default, fetch cases closed on the past 30 days
     Static Integer Mon;
     Static Integer Tue;
     Static Integer Wed;
     Static Integer Thu;
     Static Integer Fri;
     Static Integer Sat;
     Static Integer Sun;
     Static Integer PHd;
     Static Integer PHe;
     Static String frequencyDay;
     Static String frequencyDigit;
    //START D-3727 16-Oct-2015 Added by S.Puli 
    Static Integer MonTS;
    Static Integer TueTS;
    Static Integer WedTS;
    Static Integer ThuTS;
    Static Integer FriTS;
    Static Integer SatTS;
    Static Integer SunTS;
    Static Integer PHdTS;
    Static Integer PHeTS;
    Static String frequencyDigitTS;
    //END D-3727 16-Oct-2015 Added by S.Puli
   
    // START 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
    global final String sessionId;
    global static String vendorRepRoleId = Key_Id__c.getInstance('Vendor Rep Role').Id__c;
    
    //Start UD-2016 VPernicia: Comment-out
    //public static List<Task> taskList = new List<Task>();
    //End UD-2016 VPernicia: Comment-out
    public static List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
    public static Task task;
    public static Set<String> venStaffid = new Set<String>();   
    public static Map<Id, User> vendorStaffId_partnerUser = new Map<Id, User>();
    //START MGaelo 4/16/2015 D-2532 Add SMS_Outbound__c
    public static SMS_Outbound__c bound;
    //Start UD-2016 VPernicia: Comment-out
    //public static List<SMS_Outbound__c> smsOutboundList = new List<SMS_Outbound__c>();
    //End UD-2016 VPernicia Comment-out
    //public static List<String> venStaffMobileNumberList = new List<String>();
    public static String venMobileNumber;
  public static set<String> venStaffMobileNumberList = new set<String>(); //START/END D-2532 MGaelo 4/16/2015 added for VendorSubscription
    //END MGaelo 4/16/2015 D-2532 Add SMS_Outbound__c
    
    //START D-2913 JasonA./Sherwin P. 05/21
     Map<Id, Address__c> addressMapForStart = new Map<Id, Address__c>();
    //END D-2913 JasonA./Sherwin P. 05/21
    //START UD-2016 VPernicia 07/27/15
    global Map<string, MailSMSWrapper> mapConcatenated = new Map<string, MailSMSWrapper>();
    global Map<Id, Id> mailRemarks_Map = new Map<Id, Id>();
    //START: D-3669 11/16/2015 Added by Kristine Balaoing - hotfix added for batch recovery
    global Set<Id> failedRecIds = new Set<Id>();
    global Boolean isAdhoc = false;
    //END: D-3669 11/16/2015 Added by Kristine Balaoing 
    public set<id> setCaseId = new set<id>();
    //START D-3727 16-Oct-2015 Added by S.Puli
    public Map<Id, Map<Id,boolean>> coaWithTempRestartTom = new Map<Id, Map<Id,boolean>>();
    public Map<Id, Map<Id,boolean>> coaInBetwnTStop = new Map<Id, Map<Id,boolean>>();
    public static Map<Id, Map<Id, Decimal>> subIdToCaseIdToTempStopQty_MAP = new Map<Id, Map<Id, Decimal>>();
    //END D-3727 16-Oct-2015 Added by S.Puli
    //START UD-2016 VPernicia 07/27/15
    // START : UD-0982 5/11/2015 MGaelo
    public SP_VendorSubscriptionNotificationsBatch(){
    
    }
    // END : UD-0982 5/11/2015 MGaelo
    public SP_VendorSubscriptionNotificationsBatch(String sessionIdParam)
    {
        sessionId = sessionIdParam;
    }
    //START: D-3669 11/16/2015 Added by Kristine Balaoing - added for batch recovery
    public SP_VendorSubscriptionNotificationsBatch(Set<Id> caseIds)
    {
        if(caseIds <> null){
            this.failedRecIds = caseIds;
            this.isAdhoc = true;
        }
    }
    //END: D-3669 11/16/2015 Added by Kristine Balaoing
    // END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        batchSettings = Batch_Configuration_Settings__c.getInstance('SP_VendorNotificationsBatch');
        Integer daysToRetriveInt = Integer.valueOf(batchSettings.Number_Of_Days_To_Retrieve__c); 
           
           //START D-2492 03-12-2015 Marvin Gatchalian
        //START D-4074 10-Dec-2015 Added By S.Puli
        /** REMOVE
        String query = 'Select Id, CaseNumber, RecordType.Name, Account.Id, Subscription_Name__c, Temp_Stop__r.Id, ';
               query += 'Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, CSO_Remarks__c, Sub_Category__c, ';
               query += 'Stop_Request_Date__c, Effective_Date__c, Vendor__r.Email__c, Vendor__c, New_Address__r.Postal_Code__c, ';
               //Start D-2913 JasonA./Sherwin P. 05/19
               query += 'Vendor__r.RecordType.Name, Vendor__r.Vendor_Communication_Preference__c, Vendor__r.Active__c, Urgent_Request__c, Requires_Urgent_Approval__c, Additional_Termination_Comments__c, Temp_Stop__r.Remarks__c, Order_Number__r.Remarks__c, Remarks__c, ';
               //END-2913 JasonA./Sherwin P. 05/19
               //END D-2492 03-12-2015 Marvin Gatchalian
               //START: D-3140 20/06/2015 Added by S.Puli
               //START UD-2016 27-July-2015 Added By Von P./S.Puli
               //START D-3727 16-Oct-2015 Added by S.Puli
               query += 'Sub_Status__c,Change_of_Address_Type__c,Vendor__r.Handphone_Number__c,COA__c, Temp_Stop__r.Temp_Stop_Status__c, Temp_Stop__r.Temp_Stop_Qty__c,';
               //END D-3727 16-Oct-2015 Added by S.Puli
               //END UD-2016 27-July-2015 Added By Von P./S.Puli
               //END: D-3140 20/06/2015 Added by S.Puli
       //START UD-3170 05-Nov-2015 Added by S.Puli
       query += ' Contact_To_Update__c, Contact_To_Update__r.Address__r.Postal_Code__r.Name, New_Address__r.Postal_Code__r.Name,';
       //END UD-3170 05-Nov-2015 Added by S.Puli
               query += '(select id, Subscription_Vendor__c, case__r.RecordTypeId, case__r.Temp_Stop__r.Restart_Date__c, ';
               query += ' case__r.Temp_Stop__r.Temp_Stop_Date__c, Subscription_Vendor__r.Recipient__c, Subscription_Vendor__r.Vendor__c,'; // START-END : UD-0982 5/12/2015 MGaelo
               query += ' Subscription_Vendor__r.Subscription_Start_Date__c';
               query += ' from Case_Vendor_Subscriptions__r), ';
               query += '    (select id, Stop_Request_Date__c, Subscription_Vendor__c, ';
               query += '    Subscription_Vendor__r.Recipient__c, Publication__c ';
               query += '    from Order_Line_Items1__r)';
               
               
               query += ' FROM Case WHERE (account.recordtype.name = \'Vendor Subscriber\' OR account.recordtype.name = \'Vendor\') ';
               //START UD-2016 27-July-2015 Added By Von P./S.Puli
               query += ' AND Temp_Stop__r.Temp_Stop_Status__c <> \'Cancelled\' ';
               //END UD-2016 27-July-2015 Added By Von P./S.Puli
               //START D-2496 03-12-2015 Marvin Gatchalian
               //query += ' AND account.status__c <> \'Inactive\'';
               //END D-2496 03-12-2015 Marvin Gatchalian
               query += ' AND ClosedDate = LAST_N_DAYS:' + daysToRetriveInt;
            //START UD-3168 28-Oct-2015 Added by S.Puli - Only send notif for complete stop case
            query += ' AND Sub_Status__c <> \'Request Recalled\'';
            //END UD-3168 28-Oct-2015 Added by S.Puli - Only send notif for complete stop case
            //START UD-3197 03-Nov-2015 Added by S.Puli
            query += ' AND (NOT(Sub_Status__c Like \'%Reject%\'))';
            //END UD-3197 03-Nov-2015 Added by S.Puli
        //START: D-3669 11/17/2015 Added by Kristine Balaoing - hotfix added for batch recovery
        **/
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
        
        query = 'SELECT Case__c, Subscription_Vendor__c ';
        query += ' FROM ';
        query += '      Case_Vendor_Subscription__c ';
        query += ' WHERE ';
        query += '      Case__r.Status = :CASE_STATUS_CLOSED ';
        query += '      AND (NOT Case__r.Sub_Status__c LIKE \'%Rejected%\' ) ';
        query += '      AND (Case__r.Sub_Status__c <> \'Request Recalled\' ) ';
        query += '      AND (Case__r.Temp_Stop__r.Temp_Stop_Status__c <> \'Cancelled\' ) ';
        query += '      AND (Case__r.account.recordtype.name = \'Vendor Subscriber\' OR Case__r.account.recordtype.name = \'Vendor\' ) ';

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
        query += '                  ( Subscription_Vendor__r.Subscription_Start_Date__c = :dtEffEnd ';        
        query += '                      ';      
        query += '                  ) AND ( '; 
        query += '                      Case__r.RecordType.DeveloperName = :START_SUBSCRIPTION ';
        query += '                  ) ';
        query += '             ) ';


        //Stop Subscription. Subscription Start Date <= Tomorrow AND Stop Request Date is Tomorrow (Special Handling)
        //Special Handling: Go to order line items to see the stop request date. Stop Request Date is dependent on the publications which can vary for Bundled Package Subscription
        // Please refer to the pseudocode below for the special handling
        query += '             OR (';   
        query += '                  Case__r.RecordType.DeveloperName = :STOP_SUBSCRIPTION';
        query += '                  AND Subscription_Vendor__r.Subscription_Stop_Date__c = :dtEffEnd ';
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
        
        if(isAdhoc){
            query += ' AND Case__c IN:failedRecIds';
        }   
        //END D-4074 10-Dec-2015 Added By S.Puli
        //END: D-3669 11/17/2015 Added by Kristine Balaoing      
        if (Test.isRunningTest()) {
            query += ' Limit 200';
        }
      
        return Database.getQueryLocator(query);    
    }
    //START D-4074 10-Dec-2015 Added By S.Puli
    global void execute(Database.BatchableContext BC, List<Case_Vendor_Subscription__c> initialCaseVenSubs) {
        //Start UD-3457 26-Jan-2016 Added By S.Puli
        try{
        //End UD-3457 26-Jan-2016 Added By S.Puli
            List<Case> scope = new List<Case>();
            Set<Id> initialCaseSubs = new Set<Id>();
            if(initialCaseVenSubs.size()>0){
                for(Case_Vendor_Subscription__c initialCSV : initialCaseVenSubs){
                    initialCaseSubs.add(initialCSV.Case__c);
                }
            }
            if(initialCaseSubs.size()>0){
                scope = [Select Id, CaseNumber, RecordType.Name, Account.Id, Subscription_Name__c, Temp_Stop__r.Id, Temp_Stop__r.Temp_Stop_Date__c, 
                Temp_Stop__r.Restart_Date__c, CSO_Remarks__c, Sub_Category__c, Stop_Request_Date__c, Effective_Date__c, Vendor__r.Email__c, Vendor__c, 
                New_Address__r.Postal_Code__c, Vendor__r.RecordType.Name, Vendor__r.Vendor_Communication_Preference__c, Vendor__r.Active__c, 
                Urgent_Request__c, Requires_Urgent_Approval__c, Additional_Termination_Comments__c, Temp_Stop__r.Remarks__c, Order_Number__r.Remarks__c, 
                Remarks__c, Sub_Status__c,Change_of_Address_Type__c,Vendor__r.Handphone_Number__c,COA__c, Temp_Stop__r.Temp_Stop_Status__c, 
                Temp_Stop__r.Temp_Stop_Qty__c, Contact_To_Update__c, Contact_To_Update__r.Address__r.Postal_Code__r.Name, New_Address__r.Postal_Code__r.Name, 
                (select id, Subscription_Vendor__c, case__r.RecordTypeId, case__r.Temp_Stop__r.Restart_Date__c, case__r.Temp_Stop__r.Temp_Stop_Date__c, 
                Subscription_Vendor__r.Recipient__c, Subscription_Vendor__r.Vendor__c, Subscription_Vendor__r.Subscription_Start_Date__c from 
                Case_Vendor_Subscriptions__r), (select id, Stop_Request_Date__c, Subscription_Vendor__c, Subscription_Vendor__r.Recipient__c, 
                Publication__c from Order_Line_Items1__r) 
                From Case 
                Where Id IN :initialCaseSubs];
            }
        
        //END D-4074 10-Dec-2015 Added By S.Puli
            //START D-3727 16-Oct-2015 Added by S.Puli
            Map <string, string> detailsTS = new  Map <string, string>();
            String partialTemplateTS = '';
            //END D-3727 16-Oct-2015 Added by S.Puli
            Boolean isSendEmail = false; // START-END : UD-0982 5/7/2015 MGaelo
                    
            Set<Id> caseIdSet = new Set<Id>();
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> contactIdSet = new Set<Id>();
            Set<Id> subscriptionVendorIdSet = new Set<Id>();
            Set<Id> subscriptionVendorTempStopIdSet = new Set<Id>();
            Set<Id> addressIdSet = new Set<Id>();
            Set<Id> singpostAddressIdSet = new Set<Id>();
            set<string> pubCode = new set<string>();
            Set<Id> vendorAccountIdSet = new Set<Id>(); // START-END : UD-0982 5/11/2015 MGaelo
            
            List<Subscription_Vendor__c> subscriptionVendorList = new List<Subscription_Vendor__c>();
            List<String> toAddresses = new List<String>();
            //Start UD-2014 VPernicia Comment-out
            //List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            //End UD-2014 VPernicia Comment-out
            List<Contact> vendorStaffList = new List<Contact>();
            List<Account> vendorAccountList = new List<Account>();
            List<Address__c> addressList = new List<Address__c>();
            List<Singpost_Address__c> singpostAddressList = new List<Singpost_Address__c>();
            List <Subscription_Vendor_Publication__c> svPub = new List <Subscription_Vendor_Publication__c>();
            List<Contact> vendorStaffsList = new List<Contact>(); //START/END D-2532 MGaelo 4/16/2015 added for VendorSubscription
            
            Map <String , Publication__c> publicationMap = new Map<String, Publication__c>(); 
            Map <Id, List<Case_Vendor_Subscription__c>> mapCaseToCaseVendorSubscription = new Map<Id, List<Case_Vendor_Subscription__c>>();
            Map <Id, Case> mapSubscriptionVendorToCase  = new Map<Id, Case>(); // VS to Case
            Map <Id, List<Case>> mapSubscriptionVendorToCaseList  = new Map<Id, List<Case>>(); // VS to Case List
            Map <Id, Id> vendorStaffContactIdMAP = new Map <Id, Id>(); // Vendor ID to Contact ID
            Map <Id, Contact> contactVendorStaff = new Map <Id, Contact>(); //Vendor Staff Contact only
            Map <Id, List<Contact>> accountVendorToVendorStaff = new  Map <Id, List<Contact>>(); //Vendor Account to VendorStaff
            Map <Id, String> conId_AliasMap = new Map<Id, String>(); //Vendor ID to Alias
            Map <Id, List<Contact>> account_VendorStaffMap = new Map<Id, List<Contact>>();
            Map <Id, Contact> contactMap = new Map<Id, Contact>();
            Map <Id, Address__c> addressMap = new Map<Id, Address__c>();
            Map <Id, Singpost_Address__c> singpostAddressMap = new Map<Id,Singpost_Address__c>();
            Map <string, string> details = new  Map <string, string>();
            Map <string, Subscription_Vendor_Publication__c> pubCodeToDailyMap = new Map <string, Subscription_Vendor_Publication__c>(); // pubCode to Daily
            Map<Id,Subscription_Vendor__c> subscriptionvenMap = new Map<Id,Subscription_Vendor__c>(); //START/END D-2532 MGaelo 4/16/2015 added Subscription
            Map<Id, List<String>> caseToAddressVendorMap = new Map<Id, List<String>>(); // START END D-2913
            String issueDate;
            String transactionName; 
            String partialTemplate;
            String classification;

            String vendorStaffRecTypeId = ConstantsSLB.getKeyId('Contact_Vendor Staff');
            
            Boolean sendMail;
            Integer myCounter;                                                       
            Contact currentContact = new Contact(); 
            Address__c addressObj = new Address__c(); 
            Singpost_Address__c singpostAddressObj = new Singpost_Address__c();
            Subscription_Vendor__c subven = new Subscription_Vendor__c(); //START/END D-2532 MGaelo 4/16/2015 Added SubscriptionVendor
            
            //START: D-3140 20/06/2015 Added by S.Puli
            Map<Id, Case> coaIdToCase_MAP = new Map<Id, Case>();
            Map<Id, Id> coaCaseToVendorId_MAP = new Map<Id, Id>();
            Set<Id> coaNoVendor_SET = new Set<Id>();
            Map<Id, List<String>> coaCaseToNewMobile_MAP = new Map<Id, List<String>>();
            Map<Id, Set<Id>> coaCaseToTaskContact_MAP = new Map<Id, Set<Id>>();
            Map<Id, Id> coaCaseToTaskUser_MAP = new Map<Id, Id>();
            Set<Id> tempStopWithCoa_SET = new Set<Id>();
            Set<Id> tempRestartWithCoa_SET = new Set<Id>();
            Map<Id, String> coaCaseToAlias_MAP = new Map<Id, String>();
            Set<Id> conId_SET = new Set<Id>();
            //END: D-3140 20/06/2015 Added by S.Puli
            //START UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
            Map<Id, Set<Id>> startCasesToSubs_Map = new Map<Id, Set<Id>>();
            //END UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
            List <Publication__c> pubList = [Select Publication_Code__c, Sunday_Publication__r.Publication_Code__c 
                                              FROM Publication__c];
           

            For (Publication__c pub :pubList) {
                if (pub.Sunday_Publication__c <> null ) {
                    publicationMap.put (pub.Publication_Code__c, pub); 
                }
            } 
            
            //Get Vendor Account
        // START : UD-0982 5/12/2015 MGaelo
            //START/END D-2532 MGaelo 4/16/2015 Added Home Phone    
                //START: D-3140 20/06/2015 Added by S.Puli - add active = true
                //Start D-4333 18-Jan-2016 Added By S.Puli
                //Start UD-3457 26-Jan-2016 Added By S.Puli - include InActive Vendor accounts to get all Active contacts even if account is InActive
                vendorAccountList = [Select Id, Name, Email__c, (Select Id, Name, Email, RecordType.Name, Address__r.Id, HomePhone__c, Vendor_Communication_Preference__c, Active__c
                                                                    From Contacts where 
                                                                    RecordType.Name = :GlobalVariableClass.VENDOR_STAFF AND Active__c = true)
                                       From Account Where RecordType.Name = 'Vendor'];
                //End UD-3457 26-Jan-2016 Added By S.Puli
                //End D-4333 18-Jan-2016 Added By S.Puli
                //END: D-3140 20/06/2015 Added by S.Puli
        // END : UD-0982 5/12/2015 MGaelo
                for (Account eachAccount :vendorAccountList ) {
                    accountVendorToVendorStaff.put(eachAccount.id , eachAccount.Contacts);
                    for (Contact c :eachAccount.Contacts) {
                        vendorStaffContactIdMAP.put(c.Id, eachAccount.id);
                    }
                }
            
            // START : D-2913 5/14/2015 Jason A./Sherwin P
            Set<Id> vendorIdCoaSet = new Set<Id>();
            Set<Id> vendorIdCovSet = new Set<Id>();
        //START D-3009 05/22/2015 Jason A./Sherwin P.
            Map<Id, String> aliasCOAMap = new Map<Id, String>();
        //END D-3009 05/22/2015 Jason A./Sherwin P.
            List<Contact> vendorStaffCoaList = new List<Contact>();
            List<Contact> vendorStaffCOVendorList = new List<Contact>();
            List<Address_Assignment__c> addressAssignmentList = new List<Address_Assignment__c>();
            Map<Id, List<Contact>> vendorIdVendorStaffCoaListMap = new Map<Id, List<Contact>>();
            Map<Id, List<Contact>> vendorIdVendorStaffCOAVendorListMap = new Map<Id, List<Contact>>();
            Map<Id, List<Address_Assignment__c>> caseIdAddressAssignListMap = new Map<Id, List<Address_Assignment__c>>();
        //START D-3009 05/22/2015 Jason A./Sherwin P.
            Map<Id, Id> caseIdToVendor_MAP = new Map<Id, Id>();
            Map <id, id> mapVendorToStaff_MAP = new Map <id, id>();
            Map<Id, String> userIdToAlias_MAP = new Map<Id, String>();
        //END D-3009 05/22/2015 Jason A./Sherwin P.
        //START: D-3170 20/06/2015 Added by S.Puli
        Map<Id, String> caseIdToZoneName = new Map<Id, String>();
        //END: D-3170 20/06/2015 Added by S.Puli
            if(scope != null){
                for(Case caseObj : scope){
                    if(caseObj.RecordTypeId == ConstantsSLB.getKeyId('Case_Change in Address') && caseObj.Effective_Date__c == Date.today()+1){
                        caseIdSet.add(caseObj.Id); 
        //START D-3009 05/22/2015 Jason A./Sherwin P.
                        if(caseObj.Vendor__c != null){
                            vendorIdCovSet.add(caseObj.Vendor__c);
                        }
        //END D-3009 05/22/2015 Jason A./Sherwin P.
                        //START: D-3140 20/06/2015 Added by S.Puli
                        if(caseObj.Sub_Status__c != GlobalVariableClass.SUB_STATUS_WAITING_FOR_COA_APPROVAL && caseObj.Sub_Status__c != GlobalVariableClass.SUB_STATUS_COA_REJECTED && (caseObj.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR || caseObj.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC || caseObj.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD)){
                            coaIdToCase_MAP.put(caseObj.Id, caseObj);
                            //START UD-3170 05-Nov-2015 Added by S.Puli
                            if(caseObj.Vendor__c != null){
                                if(caseObj.Contact_To_Update__c <> null){
                                    if(caseObj.Contact_To_Update__r.Address__c <> null){
                                        if(caseObj.Contact_To_Update__r.Address__r.Postal_Code__c <> null){
                                            if(caseObj.Contact_To_Update__r.Address__r.Postal_Code__r.Name.length() > 2){
                                                caseIdToZoneName.put(caseObj.Id, caseObj.Contact_To_Update__r.Address__r.Postal_Code__r.Name.subString(0,2));
                                            }
                                        }
                                    }
                                }
                                if(!coaCaseToVendorId_MAP.containsKey(caseObj.Id)){
                                    coaCaseToVendorId_MAP.put(caseObj.Id, caseObj.Vendor__c);
                                    if(caseObj.Vendor__r.Vendor_Communication_Preference__c <> GlobalVariableClass.Email_Preference){
                                        if(!coaCaseToNewMobile_MAP.containsKey(caseObj.Id)){
                                            if(caseObj.Vendor__r.Handphone_Number__c <> null){
                                                coaCaseToNewMobile_MAP.put(caseObj.Id, new List<String>{caseObj.Vendor__r.Handphone_Number__c});
                                            }
                                            else{
                                                system.debug('Vendor Hand Phone is empty for case ' + caseObj.Id);
                                            }
                                        }
                                    }
                                }
                            } else{
                                coaNoVendor_SET.add(caseObj.Id);
                                if(caseObj.New_Address__c <> null){
                                    if(caseObj.New_Address__r.Postal_Code__c <> null){
                                        if(caseObj.New_Address__r.Postal_Code__r.Name.length() > 2){
                                            caseIdToZoneName.put(caseObj.Id, caseObj.New_Address__r.Postal_Code__r.Name.subString(0,2));
                                        }
                                    }
                                }
                            }
                            //END UD-3170 05-Nov-2015 Added by S.Puli
                        }
                        
                    }
                    if(caseObj.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObj.Temp_Stop__r.Temp_Stop_Date__c == Date.today()+1 && caseObj.COA__c){
                        tempStopWithCoa_SET.add(caseObj.Id);
                    
                    }
                    if(caseObj.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObj.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObj.COA__c){
                        tempRestartWithCoa_SET.add(caseObj.Id);
                    
                    }
                    //END: D-3140 20/06/2015 Added by S.Puli    
                }
            //START UD-3170 05-Nov-2015 Added by S.Puli
            List<Post_Sector_Ops_Rep_Mapping__c> coaStartPostSectorMapping_List = new List<Post_Sector_Ops_Rep_Mapping__c>();
            if(caseIdToZoneName.size()>0){
                coaStartPostSectorMapping_List = [Select Id, Zone__r.Name, Vendor_Ops__c, Vendor_Ops__r.Alias, Vendor_Ops__r.IsActive From Post_Sector_Ops_Rep_Mapping__c Where Zone__r.Name In :caseIdToZoneName.values() AND Vendor_Ops__c <> null AND Vendor_Ops__r.IsActive = true];
                if(coaStartPostSectorMapping_List.size() > 0){
                    for(Post_Sector_Ops_Rep_Mapping__c postRec : coaStartPostSectorMapping_List){
                        if(postRec.Zone__c <> null){
                            for(Id coaCaseId : caseIdToZoneName.keySet()){
                                if(caseIdToZoneName.get(coaCaseId) == postRec.Zone__r.Name){
                                    if(postRec.Vendor_Ops__c <> null){
                                        coaCaseToAlias_MAP.put(coaCaseId, postRec.Vendor_Ops__r.Alias);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //END UD-3170 05-Nov-2015 Added by S.Puli
                //START: D-3140 20/06/2015 Added by S.Puli
                system.debug('coaNoVendor_SET>>'+coaNoVendor_SET);
                addressAssignmentList = [SELECT Id, Subscription__c, Vendor__c, Vendor__r.Email__c, Case__c, Contact_ID__c, Subscription_Vendor__c, 
                                         Address__c, Contact__c, Vendor__r.Vendor_Communication_Preference__c, Vendor__r.Active__c, Vendor__r.RecordType.Name, Vendor__r.Handphone_Number__c 
                                         FROM Address_Assignment__c 
                                         WHERE Case__c IN: coaNoVendor_SET];
                //END: D-3140 20/06/2015 Added by S.Puli
                // START : D-2913 5/21/2015 Jason A./Sherwin P
                Set<Id> addressesIdSet = new Set<Id>();
                if(addressAssignmentList.size()>0){
                    for(Address_Assignment__c addr : addressAssignmentList){
                        if(addr.Address__c <> null){
                            addressesIdSet.add(addr.Address__c);
        //START: D-3140 20/06/2015 Added by S.Puli
                            if(addr.Vendor__c<> null && addr.Vendor__r.RecordType.Name == GlobalVariableClass.VENDOR){
                                caseIdToVendor_MAP.put(addr.Case__c, addr.Vendor__c);
                                if(!coaCaseToVendorId_MAP.containsKey(addr.Case__c)){   
                                    coaCaseToVendorId_MAP.put(addr.Case__c, addr.Vendor__c);
                                    if(addr.Vendor__r.Vendor_Communication_Preference__c <> GlobalVariableClass.Email_Preference){
                                        if(!coaCaseToNewMobile_MAP.containsKey(addr.Case__c)){
                                            if(addr.Vendor__r.Handphone_Number__c <> null){
                                                coaCaseToNewMobile_MAP.put(addr.Case__c, new List<String>{addr.Vendor__r.Handphone_Number__c});
                                            }
                                            else{
                                                system.debug('Vendor Hand Phone is empty for case ' + addr.Case__c);
                                            }
                                        }
                                    }
                                }
                                //END: D-3140 20/06/2015 Added by S.Puli
                            }
        //END D-3009 05/22/2015 Jason A./Sherwin P.
                        }
                    }
                }
                
                List<Address__c> addressRecord_LIST = [SELECT Id, Street_Name__c, Building_Name__c, Block_House_Number__c, Level_Number__c, Unit_Number__c, Postal_Code__r.Id FROM Address__c WHERE Id IN :addressesIdSet];
                
                if(addressRecord_LIST.size()>0){
                    for(Address__c addr : addressRecord_LIST){
                        addressMapForStart.put(addr.Id, addr);
                    }
                }
                // END : D-2913 5/21/2015 Jason A./Sherwin P
                for(Address_Assignment__c addAssign : addressAssignmentList){
                    vendorIdCoaSet.add(addAssign.Vendor__c);
                    if(caseIdAddressAssignListMap.containsKey(addAssign.Case__c)){
                        caseIdAddressAssignListMap.get(addAssign.Case__c).add(addAssign);
                    } else {
                        caseIdAddressAssignListMap.put(addAssign.Case__c, new List<Address_Assignment__c>{addAssign});
                    }
                }
                // START : D-2913 5/19/2015 Jason A./Sherwin P.
                //START: D-3140 20/06/2015 Added by S.Puli
                vendorStaffCoaList = [SELECT id, name, AccountId, Email,Vendor_Communication_Preference__c, Active__c,HomePhone__c FROM Contact WHERE AccountId IN: vendorIdCoaSet AND Active__c = true];
                vendorStaffCOVendorList = [SELECT id, name, AccountId, Email, Vendor_Communication_Preference__c, Active__c,HomePhone__c FROM Contact WHERE AccountId IN: vendorIdCovSet AND Active__c = true];
                //END: D-3140 20/06/2015 Added by S.Puli
               // END : D-2913 5/19/2015 Jason A./Sherwin P.
        //START D-3009 05/22/2015 Jason A./Sherwin P.
                //START: D-3140 20/06/2015 Added by S.Puli
                if(coaCaseToVendorId_MAP.size()>0 && coaIdToCase_MAP.size()>0){
                    for(Id caseId : coaIdToCase_MAP.keyset()){
                        if(coaCaseToVendorId_MAP.containsKey(caseId)){
                            
                                for(Contact vendorStaff : vendorStaffCoaList){
                                    if(coaCaseToVendorId_MAP.get(caseId) == vendorStaff.AccountId){
                                        conId_SET.add(vendorStaff.Id);
                                        if(!coaCaseToTaskContact_MAP.containsKey(caseId)){
                                            coaCaseToTaskContact_MAP.put(caseId, new Set<Id>{vendorStaff.Id});
                                        } else{
                                            coaCaseToTaskContact_MAP.get(caseId).add(vendorStaff.Id);
                                        }
                                        if(vendorStaff.Vendor_Communication_Preference__c <> GlobalVariableClass.SMS_Preference){
                                            if(vendorIdVendorStaffCoaListMap.containsKey(vendorStaff.AccountId)){
                                                vendorIdVendorStaffCoaListMap.get(vendorStaff.AccountId).add(vendorStaff);
                                                mapVendorToStaff_MAP.put(vendorStaff.AccountId, vendorStaff.Id);
                                            } else {
                                                vendorIdVendorStaffCoaListMap.put(vendorStaff.AccountId, new List<Contact>{vendorStaff});
                                                mapVendorToStaff_MAP.put(vendorStaff.AccountId, vendorStaff.Id);
                                                
                                            }
                                        }
                                        if(vendorStaff.Vendor_Communication_Preference__c <> GlobalVariableClass.Email_Preference && vendorStaff.HomePhone__c <> null){
                                            if(!coaCaseToNewMobile_MAP.containsKey(caseId)){
                                                coaCaseToNewMobile_MAP.put(caseId, new List<String>{vendorStaff.HomePhone__c});
                                            }else{
                                                coaCaseToNewMobile_MAP.get(caseId).add(vendorStaff.HomePhone__c);   
                                            }
                                        }
                                    }
                                }
                                
                                
                                
                                
                                
                                for(Contact vendorStaff : vendorStaffCOVendorList){
                                    if(coaCaseToVendorId_MAP.get(caseId) == vendorStaff.AccountId){
                                        conId_SET.add(vendorStaff.Id);
                                        if(!coaCaseToTaskContact_MAP.containsKey(caseId)){
                                            coaCaseToTaskContact_MAP.put(caseId, new Set<Id>{vendorStaff.Id});
                                        } else{
                                            coaCaseToTaskContact_MAP.get(caseId).add(vendorStaff.Id);
                                        }
                                        if(vendorStaff.Vendor_Communication_Preference__c <> GlobalVariableClass.SMS_Preference){
                                            if(vendorIdVendorStaffCOAVendorListMap.containsKey(vendorStaff.AccountId)){
                                                vendorIdVendorStaffCOAVendorListMap.get(vendorStaff.AccountId).add(vendorStaff);
                                                mapVendorToStaff_MAP.put(vendorStaff.AccountId, vendorStaff.Id);
                                            } else {
                                                vendorIdVendorStaffCOAVendorListMap.put(vendorStaff.AccountId, new List<Contact>{vendorStaff});
                                                mapVendorToStaff_MAP.put(vendorStaff.AccountId, vendorStaff.Id);
                                            }
                                        }
                                        if(vendorStaff.Vendor_Communication_Preference__c <> GlobalVariableClass.Email_Preference && vendorStaff.HomePhone__c <> null){
                                            if(!coaCaseToNewMobile_MAP.containsKey(caseId)){
                                                coaCaseToNewMobile_MAP.put(caseId, new List<String>{vendorStaff.HomePhone__c});
                                            }else{
                                                coaCaseToNewMobile_MAP.get(caseId).add(vendorStaff.HomePhone__c);   
                                            }
                                        }                                   
                                    }
                                }
                            
                        }
                    }
                }
                //END: D-3140 20/06/2015 Added by S.Puli
                    //START: D-3140 20/06/2015 Added by S.Puli
                    system.debug('coaCaseToNewMobile_MAP>>'+coaCaseToNewMobile_MAP);
                    system.debug('coaCaseToTaskContact_MAP>>'+coaCaseToTaskContact_MAP);
                    system.debug('mapVendorToStaff_MAP>>'+mapVendorToStaff_MAP);
                    //Start D-4333 18-Jan-2016 Added By S.Puli
                    List<User> newCoaUserList = [Select Id, Name, ContactId, Alias, Contact.AccountId From User Where ContactId In :conId_SET AND Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE and isActive=true];
                    //End D-4333 18-Jan-2016 Added By S.Puli
                    if(newCoaUserList.size()>0){
                        for(User u : newCoaUserList){
                            userIdToAlias_MAP.put(u.ContactId, u.Alias);
                            if(coaCaseToVendorId_MAP.size()>0){ 
                                for(Id casId : coaCaseToVendorId_MAP.keyset()){
                                    if(coaCaseToVendorId_MAP.containsKey(casId)){

                                            if(coaCaseToVendorId_MAP.get(casId) == u.Contact.AccountId){
                                                if(!coaCaseToTaskUser_MAP.containsKey(casId)){
                                                    coaCaseToTaskUser_MAP.put(casId, u.Id);
                                                }
                            //START UD-3170 05-Nov-2015 Added by S.Puli - relocate the below lines
                            /*
                                                if(!coaCaseToAlias_MAP.containsKey(casId)){
                                                    coaCaseToAlias_MAP.put(casId, u.Alias);
                                                }*/
                            //END UD-3170 05-Nov-2015 Added by S.Puli
                                            }
                                        
                                    }
                                }
                            }
                        }
                    }

                    //END: D-3140 20/06/2015 Added by S.Puli
                for(Case caseObj: scope){                 
                    accountIdSet.add(caseObj.Account.Id);
                    
                    if(caseObj.RecordTypeId == ConstantsSLB.getKeyId('Case_Change in Address') && caseObj.Effective_Date__c == Date.today()+1){         
                        if(caseObj.Vendor__c<>null && caseObj.Vendor__r.RecordType.Name==GlobalVariableClass.VENDOR){
                            if(caseToAddressVendorMap.get(caseObj.Id)<>null){
                                if(caseObj.Vendor__r.Email__c != null){
                                    // START : D-2913 5/19/2015 Jason A./Sherwin P.
                                            if((caseObj.Vendor__r.Vendor_Communication_Preference__c == 'Both' || caseObj.Vendor__r.Vendor_Communication_Preference__c == 'Email') && caseObj.Vendor__r.Active__c == true && caseObj.Vendor__r.RecordType.Name == 'Vendor'){
                                                caseToAddressVendorMap.get(caseObj.Id).add(caseObj.Vendor__r.Email__c);
                                            }
                                    // END : D-2913 5/19/2015 Jason A./Sherwin P.
                                }
                                if(vendorIdVendorStaffCOAVendorListMap.containsKey(caseObj.Vendor__c)){
                                    for(Contact vendorStaff : vendorIdVendorStaffCOAVendorListMap.get(caseObj.Vendor__c)){
                                        if(vendorStaff.Email != null){

                                            caseToAddressVendorMap.get(caseObj.id).add(vendorStaff.Email);
                                        }
                                    }
                                }
                            } else {
                                // START : D-2913 5/19/2015 Jason A./Sherwin P.
                                if((caseObj.Vendor__r.Vendor_Communication_Preference__c == 'Both' || caseObj.Vendor__r.Vendor_Communication_Preference__c == 'Email') && caseObj.Vendor__r.Active__c == true && caseObj.Vendor__r.RecordType.Name == 'Vendor'){
                                    caseToAddressVendorMap.put(caseObj.Id, new List<String>{caseObj.Vendor__r.Email__c});
                                    }
                                // END : D-2913 5/19/2015 Jason A./Sherwin P.
                                if(vendorIdVendorStaffCOAVendorListMap.containsKey(caseObj.Vendor__c)){
                                    for(Contact vendorStaff : vendorIdVendorStaffCOAVendorListMap.get(caseObj.Vendor__c)){
                                        if(vendorStaff.Email != null){
                                            caseToAddressVendorMap.get(caseObj.Id).add(vendorStaff.Email);
                                        }
                                    }
                                }
                            }
                        } else if(caseObj.New_Address__c != null){
                            if(caseToAddressVendorMap.containsKey(caseObj.id)){
                                if(caseIdAddressAssignListMap.containsKey(caseObj.id)){                         
                                    for(Address_Assignment__c addAssign : caseIdAddressAssignListMap.get(caseObj.id)){
                                        // START : D-2913 5/19/2015 Jason A./Sherwin P.
                                        if(addAssign.Vendor__r.Email__c != null){
                                            if((addAssign.Vendor__r.Vendor_Communication_Preference__c == 'Both' || addAssign.Vendor__r.Vendor_Communication_Preference__c == 'Email') && addAssign.Vendor__r.Active__c == true && addAssign.Vendor__r.RecordType.Name == 'Vendor'){
                                                caseToAddressVendorMap.get(caseObj.id).add(addAssign.Vendor__r.Email__c);
                                            }
                                        // END : D-2913 5/19/2015 Jason A./Sherwin P.
                                        }
                                    
                                        if(vendorIdVendorStaffCoaListMap.containsKey(addAssign.Vendor__c)){
                                            for(Contact venStaffCon : vendorIdVendorStaffCoaListMap.get(addAssign.Vendor__c)){
                                                //Start UD-3457 26-Jan-2016 Added By S.Puli
                                                if(venStaffCon.Email <> null){
                                                    caseToAddressVendorMap.get(caseObj.id).add(venStaffCon.Email);
                                                }
                                                //End UD-3457 26-Jan-2016 Added By S.Puli
                                            }
                                        }                                    
                                    }
                                }
                            } else {
                                caseToAddressVendorMap.put(caseObj.id, new List<String>());
                                if(caseIdAddressAssignListMap.containsKey(caseObj.id)){
                                    for(Address_Assignment__c addAssign : caseIdAddressAssignListMap.get(caseObj.id)){
                                        // START : D-2913 5/19/2015 Jason A./Sherwin P.
                                        if(addAssign.Vendor__r.Email__c != null){
                                            if((addAssign.Vendor__r.Vendor_Communication_Preference__c == 'Both' || addAssign.Vendor__r.Vendor_Communication_Preference__c == 'Email') && addAssign.Vendor__r.Active__c == true && addAssign.Vendor__r.RecordType.Name == 'Vendor'){
                                                caseToAddressVendorMap.get(caseObj.id).add(addAssign.Vendor__r.Email__c);
                                            }
                                                if(vendorIdVendorStaffCoaListMap.containsKey(addAssign.Vendor__c)){
                                                    for(Contact venStaffCon : vendorIdVendorStaffCoaListMap.get(addAssign.Vendor__c)){
                                                        //Start UD-3457 26-Jan-2016 Added By S.Puli
                                                        if(venStaffCon.Email <> null){
                                                            caseToAddressVendorMap.get(caseObj.id).add(venStaffCon.Email);
                                                        }
                                                        //End UD-3457 26-Jan-2016 Added By S.Puli
                                                    }
                                                }
                                            
                                        }
                                        // END : D-2913 5/19/2015 Jason A./Sherwin P.
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            // END : D-2913 5/19/2015 Jason A./Sherwin P.
            
            //START: D-3140 20/06/2015 Added by S.Puli
            Map<Id, Set<Id>> coaCaseToSubIds_MAP = new Map<Id, Set<Id>>();
            Set<Id> coaVenSubIds = new Set<Id>();
            Map<Id, Map<Id,boolean>> coaStartToSubsIdentifier_MAP = new Map<Id, Map<Id,boolean>>();
            Map<Id, Set<Id>> coaCaseToOldVendor_Map = new Map<Id, Set<Id>>();
            List<Contact> coaVenStaf_List = new List<Contact>();
            Map<Id, Set<String>> coaCaseToOldMobile = new Map<Id, Set<String>>();
            Set<Id> coaOldVendors_SET = new Set<Id>();
            boolean coaStartBoolean = false;
            if(coaIdToCase_MAP.size()>0){
                for(Case_Vendor_Subscription__c cvSubs : [Select Id, Case__c,Case__r.RecordTypeId, Subscription_Vendor__c, Subscription_Vendor__r.Vendor__c, Subscription_Vendor__r.Vendor__r.Vendor_Communication_Preference__c, Subscription_Vendor__r.Vendor__r.Handphone_Number__c From Case_Vendor_Subscription__c Where Case__c IN :coaIdToCase_MAP.keyset()]){
                    coaVenSubIds.add(cvSubs.Subscription_Vendor__c);
                    if(!coaCaseToSubIds_MAP.containsKey(cvSubs.Case__c)){
                        coaCaseToSubIds_MAP.put(cvSubs.Case__c, new Set<Id>{cvSubs.Subscription_Vendor__c});
                    }else{
                        coaCaseToSubIds_MAP.get(cvSubs.Case__c).add(cvSubs.Subscription_Vendor__c);
                    }
                    if(cvSubs.Subscription_Vendor__r.Vendor__c <> null){
                        coaOldVendors_SET.add(cvSubs.Subscription_Vendor__r.Vendor__c);
                        if(!coaCaseToOldVendor_Map.containsKey(cvSubs.Case__c)){
                            coaCaseToOldVendor_Map.put(cvSubs.Case__c, new Set<Id>{cvSubs.Subscription_Vendor__r.Vendor__c});
                            
                            if(cvSubs.Subscription_Vendor__r.Vendor__r.Vendor_Communication_Preference__c <> GlobalVariableClass.Email_Preference && cvSubs.Subscription_Vendor__r.Vendor__r.Handphone_Number__c <> null){
                                if(!coaCaseToOldMobile.containsKey(cvSubs.Case__c)){
                                    coaCaseToOldMobile.put(cvSubs.Case__c, new Set<String>{cvSubs.Subscription_Vendor__r.Vendor__r.Handphone_Number__c});
                                }
                                else{
                                    coaCaseToOldMobile.get(cvSubs.Case__c).add(cvSubs.Subscription_Vendor__r.Vendor__r.Handphone_Number__c);
                                }
                            }
                        }else{
                            coaCaseToOldVendor_Map.get(cvSubs.Case__c).add(cvSubs.Subscription_Vendor__r.Vendor__c);
                            
                            if(cvSubs.Subscription_Vendor__r.Vendor__r.Vendor_Communication_Preference__c <> GlobalVariableClass.Email_Preference && cvSubs.Subscription_Vendor__r.Vendor__r.Handphone_Number__c <> null){
                                if(!coaCaseToOldMobile.containsKey(cvSubs.Case__c)){
                                    coaCaseToOldMobile.put(cvSubs.Case__c, new Set<String>{cvSubs.Subscription_Vendor__r.Vendor__r.Handphone_Number__c});
                                }
                                else{
                                    coaCaseToOldMobile.get(cvSubs.Case__c).add(cvSubs.Subscription_Vendor__r.Vendor__r.Handphone_Number__c);
                                }
                            }
                        }
                    }
                }
                if(coaVenSubIds.size()>0 && coaCaseToSubIds_MAP.size()>0){
                    //START UD-2016 27-July-2015 Added By Von P./S.Puli
                    //START D-3727 16-Oct-2015 Added by S.Puli
                    for(Case_Vendor_Subscription__c cvSubs : [Select Id, Case__c,Case__r.RecordTypeId, Subscription_Vendor__c, Case__r.Temp_Stop_Date__c, Case__r.Temp_Stop__r.Temp_Stop_Status__c, Case__r.COA__c, Case__r.Restart_Date__c From Case_Vendor_Subscription__c Where Subscription_Vendor__c IN :coaVenSubIds AND Case__r.RecordTypeId = :ConstantsSLB.getKeyId('Case_Temp Stop') AND Case__r.Restart_Date__c > today AND Case__r.COA__c = true AND Case__r.Temp_Stop__r.Temp_Stop_Status__c <> :GlobalVariableClass.TS_STATUS_CANCELLED]){
                    //END UD-2016 27-July-2015 Added By Von P./S.Puli
                        if(cvSubs.Case__r.Temp_Stop_Date__c == Date.Today()+1){
                            for(Id caseId : coaCaseToSubIds_MAP.keyset()){
                                for(Id subsId : coaCaseToSubIds_MAP.get(caseId)){
                                    coaStartBoolean = false;
                                    //Start UD-3379 20-Jan-2016 Added By S.Puli
                                    if(subsId == cvSubs.Subscription_Vendor__c){
                                        coaStartBoolean = true;
                                    
                                        //START UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                        
                                        if(coaStartToSubsIdentifier_MAP.containsKey(caseId)){
                                            if(coaStartToSubsIdentifier_MAP.get(caseId).containsKey(subsId)){
                                                if(coaStartToSubsIdentifier_MAP.get(caseId).get(subsId) == false){  
                                                    coaStartToSubsIdentifier_MAP.get(caseId).put(subsId, coaStartBoolean);
                                                }
                                            }else{
                                                coaStartToSubsIdentifier_MAP.get(caseId).put(subsId, coaStartBoolean);
                                            }
                                        }else{
                                            coaStartToSubsIdentifier_MAP.put(caseId, new Map<Id,boolean>{subsId => coaStartBoolean});
                                        }
                                    }
                                    //End UD-3379 20-Jan-2016 Added By S.Puli
                                    //END UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                }
                            }
                        }
                        if(cvSubs.Case__r.Restart_Date__c == Date.Today()+1){
                            for(Id caseId : coaCaseToSubIds_MAP.keyset()){
                                for(Id subsId : coaCaseToSubIds_MAP.get(caseId)){
                                    boolean coaRestartTom = false;
                                    //Start UD-3379 20-Jan-2016 Added By S.Puli
                                    if(subsId == cvSubs.Subscription_Vendor__c){
                                        coaRestartTom = true;
                                        
                                        //START UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                        if(coaWithTempRestartTom.containsKey(caseId)){
                                            if(coaWithTempRestartTom.get(caseId).containsKey(subsId)){
                                                if(coaWithTempRestartTom.get(caseId).get(subsId) == false){ 
                                                    coaWithTempRestartTom.get(caseId).put(subsId, coaRestartTom);
                                                }
                                            }else{
                                                coaWithTempRestartTom.get(caseId).put(subsId, coaRestartTom);
                                            }
                                        }else{
                                            coaWithTempRestartTom.put(caseId, new Map<Id,boolean>{subsId => coaRestartTom});
                                        }
                                    }
                                    //End UD-3379 20-Jan-2016 Added By S.Puli
                                    //END UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                }
                            }
                        }
                        if(cvSubs.Case__r.Restart_Date__c > date.today()+1 && cvSubs.Case__r.Temp_Stop_Date__c < date.today()+1){
                            for(Id caseId : coaCaseToSubIds_MAP.keyset()){
                                for(Id subsId : coaCaseToSubIds_MAP.get(caseId)){
                                    boolean coaInBetween = false;
                                    //Start UD-3379 20-Jan-2016 Added By S.Puli
                                    if(subsId == cvSubs.Subscription_Vendor__c){
                                        coaInBetween = true;
                                        //START UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                        if(coaInBetwnTStop.containsKey(caseId)){
                                            if(coaInBetwnTStop.get(caseId).containsKey(subsId)){
                                                if(coaInBetwnTStop.get(caseId).get(subsId) == false){   
                                                    coaInBetwnTStop.get(caseId).put(subsId, coaInBetween);
                                                }
                                            }else{
                                                coaInBetwnTStop.get(caseId).put(subsId, coaInBetween);
                                            }
                                        }else{
                                            coaInBetwnTStop.put(caseId, new Map<Id,boolean>{subsId => coaInBetween});
                                        }
                                    }
                                    //End UD-3379 20-Jan-2016 Added By S.Puli
                                    //END UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                }
                            }
                        }
                    //END D-3727 16-Oct-2015 Added by S.Puli
                    }
                }
                if(coaCaseToOldVendor_Map.size()>0){
                    coaVenStaf_List = [Select Id, Name, AccountId, RecordTypeId, Email, Active__c, Vendor_Communication_Preference__c,HomePhone__c From Contact Where RecordTypeId = :vendorStaffRecTypeId And AccountId IN :coaOldVendors_SET AND Active__c = true];
                    
                    if(coaVenStaf_List.size()>0){
                        for(Contact vCon : coaVenStaf_List){
                            if(vCon.Vendor_Communication_Preference__c <> GlobalVariableClass.Email_Preference && vCon.HomePhone__c <> null){
                                for(Id casId : coaCaseToOldVendor_Map.keySet()){    
                                    for(Id venId : coaCaseToOldVendor_Map.get(casId)){
                                        if(venId == vCon.AccountId){
                                            if(!coaCaseToOldMobile.containsKey(casId)){
                                                coaCaseToOldMobile.put(casId, new Set<String>{vCon.HomePhone__c});
                                            }
                                            else{
                                                coaCaseToOldMobile.get(casId).add(vCon.HomePhone__c);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                
                }
            }
            
            //tempStopWithCoa_SET
            Set<Id> tempStopVenSubIds = new Set<Id>();
            Map<Id, Set<Id>> tempStopCaseToSubIds_MAP = new Map<Id, Set<Id>>();
            boolean tempStopBoolean = false;
            Map<Id, Map<Id, boolean>> tempStopToSubsIdentifier_MAP = new Map<Id, Map<Id, boolean>>();
            if(tempStopWithCoa_SET.size()>0){
                for(Case_Vendor_Subscription__c cvSubs : [Select Id, Case__c,Case__r.RecordTypeId, Subscription_Vendor__c From Case_Vendor_Subscription__c Where Case__c IN :tempStopWithCoa_SET]){
                    tempStopVenSubIds.add(cvSubs.Subscription_Vendor__c);
                    if(!tempStopCaseToSubIds_MAP.containsKey(cvSubs.Case__c)){
                        tempStopCaseToSubIds_MAP.put(cvSubs.Case__c, new Set<Id>{cvSubs.Subscription_Vendor__c});
                    }else{
                        tempStopCaseToSubIds_MAP.get(cvSubs.Case__c).add(cvSubs.Subscription_Vendor__c);
                    }
                }
                if(tempStopVenSubIds.size()>0 && tempStopCaseToSubIds_MAP.size()>0){
                    for(Case_Vendor_Subscription__c cvSubs : [Select Id, Case__c,Case__r.RecordTypeId, Subscription_Vendor__c, Case__r.Temp_Stop_Date__c, Case__r.Change_of_Address_Type__c From Case_Vendor_Subscription__c Where Subscription_Vendor__c IN :tempStopVenSubIds AND Case__r.Effective_Date__c = tomorrow AND (Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD)]){
                        for(Id caseId : tempStopCaseToSubIds_MAP.keyset()){
                            for(Id subsId : tempStopCaseToSubIds_MAP.get(caseId)){
                                tempStopBoolean = false;
                                if(subsId == cvSubs.Subscription_Vendor__c){
                                    tempStopBoolean = true;
                                }
                                if(tempStopToSubsIdentifier_MAP.containsKey(caseId)){
                                //START UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo  
                                    if(tempStopToSubsIdentifier_MAP.get(caseId).containsKey(subsId)){
                                        if(tempStopToSubsIdentifier_MAP.get(caseId).get(subsId) == false){
                                            tempStopToSubsIdentifier_MAP.get(caseId).put(subsId, tempStopBoolean);
                                        }
                                    }else{
                                        tempStopToSubsIdentifier_MAP.get(caseId).put(subsId, tempStopBoolean);
                                    }
                                //END UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
                                }else{
                                    tempStopToSubsIdentifier_MAP.put(caseId, new Map<Id,boolean>{subsId => tempStopBoolean});
                                }
                            }
                        }
                    }
                }
            
            }
            //tempRestartWithCoa_SET
            Set<Id> tempRestartVenSubIds = new Set<Id>();
            Map<Id, Id> tempRestartCaseToSubIds_MAP = new Map<Id, Id>();
            //Start UD-3379 05-Feb-2016 Added By S.Puli
            Map<Id, Set<Id>> coaCaseToTempCase = new Map<Id, Set<Id>>();
            //End UD-3379 05-Feb-2016 Added By S.Puli
            Map<Id, Id> tempRestartToVendor = new Map<Id, Id>();
            Map<Id, List<String>> tempRestartToNewEmailAdd  = new Map<Id, List<String>>();
            Map<Id, List<String>> tempRestartToNewMobile =  new Map<Id, List<String>>();
            List<Address_Assignment__c> tempRestartAddAssignmentList  = new List<Address_Assignment__c>();
            Map<Id, Id> tempRestartToAdd_MAP = new Map<Id, Id>();
            List<Address__c> tempRestartAddress_LIST = new List<Address__c>();
            Map<Id, Address__c> addIdToRecord_MAP = new Map<Id, Address__c>();
            List<Contact> tempRestartContact_LIST = new List<Contact>();
            Map<Id, Set<Id>> tempRestartToContactSet_MAP = new Map<Id, Set<Id>>();
            Set<Id> tempVenStaff_SET = new Set<Id>();
            List<User> tempRestartUser_LIST = new List<User>();
            Map<Id, String> tempRestartToAlias_MAP = new Map<Id, String>();
            Map<Id, Id> tempRestartToUserId_MAP = new Map<Id, Id>();
        //START UD-3170 05-Nov-2015 Added by S.Puli
        Map<Id, String> tempCoaToZoneName = new Map<Id, String>();
        //END UD-3170 05-Nov-2015 Added by S.Puli
            if(tempRestartWithCoa_SET.size()>0){
                
                
                for(Case_Vendor_Subscription__c cvSubs : [Select Id, Case__c,Case__r.RecordTypeId, Subscription_Vendor__c From Case_Vendor_Subscription__c Where Case__c IN :tempRestartWithCoa_SET]){
                    tempRestartVenSubIds.add(cvSubs.Subscription_Vendor__c);
                    if(!tempRestartCaseToSubIds_MAP.containsKey(cvSubs.Case__c)){
                        tempRestartCaseToSubIds_MAP.put(cvSubs.Case__c, cvSubs.Subscription_Vendor__c);
                    }
                }
                if(tempRestartVenSubIds.size()>0 && tempRestartCaseToSubIds_MAP.size()>0){
            //START UD-3170 05-Nov-2015 Added by S.Puli
                    for(Case_Vendor_Subscription__c cvSubs : [Select Id, Case__c,Case__r.RecordTypeId, Subscription_Vendor__c, Case__r.Temp_Stop_Date__c, Case__r.Change_of_Address_Type__c, Case__r.Vendor__c, Case__r.Vendor__r.RecordType.Name,Case__r.Vendor__r.Vendor_Communication_Preference__c, Case__r.Vendor__r.Handphone_Number__c,Case__r.Vendor__r.Email__c,Case__r.Contact_To_Update__c, Case__r.Contact_To_Update__r.Address__r.Postal_Code__r.Name, Case__r.New_Address__r.Postal_Code__r.Name,Case__r.New_Address__c From Case_Vendor_Subscription__c Where Subscription_Vendor__c IN :tempRestartVenSubIds AND Case__r.Effective_Date__c = tomorrow AND (Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD)]){
                        for(Id caseId : tempRestartCaseToSubIds_MAP.keyset()){
                            if(tempRestartCaseToSubIds_MAP.get(caseId) == cvSubs.Subscription_Vendor__c){
                                //Start UD-3379 05-Feb-2016 Added By S.Puli
                                //coaCaseToTempCase.put(cvSubs.Case__c, caseId);
                                if(!coaCaseToTempCase.containsKey(cvSubs.Case__c)){
                                    coaCaseToTempCase.put(cvSubs.Case__c, new Set<Id>{caseId});
                                }else{
                                    coaCaseToTempCase.get(cvSubs.Case__c).add(caseId);
                                }
                                if(cvSubs.Case__r.Vendor__c <> null && cvSubs.Case__r.Vendor__r.RecordType.Name == GlobalVariableClass.VENDOR){
                                    //tempRestartToVendor.put(coaCaseToTempCase.get(cvSubs.Case__c), cvSubs.Case__r.Vendor__c);
                                    if(coaCaseToTempCase.containsKey(cvSubs.Case__c)){
                                        for(Id tempC : coaCaseToTempCase.get(cvSubs.Case__c)){
                                            if(!tempRestartToVendor.containsKey(tempC)){
                                                tempRestartToVendor.put(tempC, cvSubs.Case__r.Vendor__c);
                                            }
                                        }
                                    }
                                    if(cvSubs.Case__r.Vendor__r.Vendor_Communication_Preference__c <> GlobalVariableClass.SMS_Preference && cvSubs.Case__r.Vendor__r.Email__c <> null){                         
                                        if(!tempRestartToNewEmailAdd.containsKey(caseId)){
                                            tempRestartToNewEmailAdd.put(caseId, new List<String>{cvSubs.Case__r.Vendor__r.Email__c});
                                        }else{
                                            tempRestartToNewEmailAdd.get(caseId).add(cvSubs.Case__r.Vendor__r.Email__c);
                                        }
                                    }
                                    if(cvSubs.Case__r.Vendor__r.Vendor_Communication_Preference__c <> GlobalVariableClass.Email_Preference && cvSubs.Case__r.Vendor__r.Handphone_Number__c <> null){
                                        if(!tempRestartToNewMobile.containsKey(caseId)){
                                            tempRestartToNewMobile.put(caseId, new List<String>{cvSubs.Case__r.Vendor__r.Handphone_Number__c});
                                        }else{
                                            tempRestartToNewMobile.get(caseId).add(cvSubs.Case__r.Vendor__r.Handphone_Number__c);
                                        }
                                    }
                                    if(cvSubs.Case__r.Contact_To_Update__c <> null){
                                        if(cvSubs.Case__r.Contact_To_Update__r.Address__c <> null){
                                            if(cvSubs.Case__r.Contact_To_Update__r.Address__r.Postal_Code__c <> null){
                                                if(cvSubs.Case__r.Contact_To_Update__r.Address__r.Postal_Code__r.Name.length()>2){
                                                    tempCoaToZoneName.put(caseId, cvSubs.Case__r.Contact_To_Update__r.Address__r.Postal_Code__r.Name.subString(0,2));
                                                }
                                            }
                                        }
                                    }
                                }else{
                                    if(cvSubs.Case__r.New_Address__c <> null){
                                        if(cvSubs.Case__r.New_Address__r.Postal_Code__c <> null){
                                            if(cvSubs.Case__r.New_Address__r.Postal_Code__r.Name.length()>2){
                                                tempCoaToZoneName.put(caseId, cvSubs.Case__r.New_Address__r.Postal_Code__r.Name.subString(0,2));
                                            }
                                        }
                                    }                           
                                }
                                //End UD-3379 05-Feb-2016 Added By S.Puli
                            }
                        }
                    }
                    //END UD-3170 05-Nov-2015 Added by S.Puli
                }
                
            }
            //START UD-3170 05-Nov-2015 Added by S.Puli
            List<Post_Sector_Ops_Rep_Mapping__c> tempRestartPostSecMapping_List = new List<Post_Sector_Ops_Rep_Mapping__c>();
            
            if(tempCoaToZoneName.size() > 0){
                tempRestartPostSecMapping_List = [Select Id, Zone__r.Name, Vendor_Ops__c, Vendor_Ops__r.Alias, Vendor_Ops__r.IsActive From Post_Sector_Ops_Rep_Mapping__c Where Zone__r.Name In :tempCoaToZoneName.values() AND Vendor_Ops__c <> null AND Vendor_Ops__r.IsActive = true];
                if(tempRestartPostSecMapping_List.size() > 0){
                    for(Post_Sector_Ops_Rep_Mapping__c tempCoaPost : tempRestartPostSecMapping_List){
                        if(tempCoaPost.Zone__c <> null && tempCoaPost.Vendor_Ops__c <> null){
                            for(Id tempRestartCase : tempCoaToZoneName.keySet()){
                                if(tempCoaToZoneName.get(tempRestartCase) == tempCoaPost.Zone__r.Name){
                                    tempRestartToAlias_MAP.put(tempRestartCase, tempCoaPost.Vendor_Ops__r.Alias);
                                }
                            }
                        }
                    }
                }
            }
            //END UD-3170 05-Nov-2015 Added by S.Puli
            if(coaCaseToTempCase.size()>0){
                tempRestartAddAssignmentList = [SELECT Id, Subscription__c, Vendor__c, Vendor__r.Email__c, Case__c, Subscription_Vendor__c, 
                                         Address__c, Contact__c, Vendor__r.Vendor_Communication_Preference__c, Vendor__r.Active__c, Vendor__r.RecordType.Name, Vendor__r.Handphone_Number__c 
                                         FROM Address_Assignment__c 
                                         WHERE Case__c IN: coaCaseToTempCase.keySet() AND Vendor__r.RecordType.Name = :GlobalVariableClass.VENDOR AND Vendor__r.Active__c = true];
                                         
                if(tempRestartAddAssignmentList.size()>0){
                    for(Address_Assignment__c add : tempRestartAddAssignmentList){
                        if(add.Vendor__c <> null){
                            //Start UD-3379 05-Feb-2016 Added By S.Puli
                            for(Id initCasId : coaCaseToTempCase.keySet()){
                                for(Id caseId : coaCaseToTempCase.get(initCasId)){
                                    if(add.Case__c == initCasId){
                                        if(!tempRestartToVendor.containsKey(caseId)){
                                            tempRestartToVendor.put(caseId, add.Vendor__c);
                                        }
                                        if(!tempRestartToAdd_MAP.containsKey(caseId)){
                                            tempRestartToAdd_MAP.put(caseId, add.Address__c);
                                        }
                                        if(add.Vendor__r.Vendor_Communication_Preference__c <> GlobalVariableClass.SMS_Preference && add.Vendor__r.Email__c <> null){
                                            if(!tempRestartToNewEmailAdd.containsKey(caseId)){
                                                tempRestartToNewEmailAdd.put(caseId, new List<String>{add.Vendor__r.Email__c});
                                            }else{
                                                tempRestartToNewEmailAdd.get(caseId).add(add.Vendor__r.Email__c);
                                            }
                                        }
                                        if(add.Vendor__r.Vendor_Communication_Preference__c <> GlobalVariableClass.Email_Preference && add.Vendor__r.Handphone_Number__c <> null){
                                            if(!tempRestartToNewMobile.containsKey(caseId)){
                                                tempRestartToNewMobile.put(caseId, new List<String>{add.Vendor__r.Handphone_Number__c});
                                            }else{
                                                tempRestartToNewMobile.get(caseId).add(add.Vendor__r.Handphone_Number__c);
                                            }
                                        }
                                    }
                                }
                            }
                            //End UD-3379 05-Feb-2016 Added By S.Puli
                        }
                    }
                }
                
                if(tempRestartToAdd_MAP.size()>0){
                    tempRestartAddress_LIST = [Select Id, Street_Name__c, Building_Name__c, Block_House_Number__c, Level_Number__c, Unit_Number__c, Postal_Code__r.Id FROM Address__c WHERE Id IN: tempRestartToAdd_MAP.values()];
                    if(tempRestartAddress_LIST.size()>0){
                        for(Address__c add : tempRestartAddress_LIST){
                            addIdToRecord_MAP.put(add.Id, add);
                        }
                    }
                }
                
            }
            
            if(tempRestartToVendor.size()>0){
                tempRestartContact_LIST = [Select Id, Name, AccountId, RecordTypeId, Email, Active__c, Vendor_Communication_Preference__c,HomePhone__c From Contact Where RecordTypeId = :vendorStaffRecTypeId And AccountId IN :tempRestartToVendor.values() AND Active__c = true];
                
                if(tempRestartContact_LIST.size()>0){
                    for(Id casId : tempRestartToVendor.keySet()){
                        for(Contact con : tempRestartContact_LIST){
                            tempVenStaff_SET.add(con.Id);
                            if(tempRestartToVendor.get(casId) == con.AccountId){
                                if(!tempRestartToContactSet_MAP.containsKey(casId)){
                                    tempRestartToContactSet_MAP.put(casId, new Set<Id>{con.Id});
                                }else{
                                    tempRestartToContactSet_MAP.get(casId).add(con.Id);
                                }
                                if(con.Vendor_Communication_Preference__c <> GlobalVariableClass.SMS_Preference && con.Email <> null){
                                    if(!tempRestartToNewEmailAdd.containsKey(casId)){
                                        tempRestartToNewEmailAdd.put(casId, new List<String>{con.Email});
                                    }else{
                                        tempRestartToNewEmailAdd.get(casId).add(con.Email);
                                    }
                                }
                                if(con.Vendor_Communication_Preference__c <> GlobalVariableClass.Email_Preference && con.HomePhone__c <> null){
                                    if(!tempRestartToNewMobile.containsKey(casId)){
                                        tempRestartToNewMobile.put(casId, new List<String>{con.HomePhone__c});
                                    }else{
                                        tempRestartToNewMobile.get(casId).add(con.HomePhone__c);
                                    }
                                }
                            }
                        }
                    }
                    if(tempVenStaff_SET.size()>0){
                        //Start D-4333 18-Jan-2016 Added By S.Puli
                        tempRestartUser_LIST = [Select Id, Name, Profile.UserLicense.Name, Alias, ContactId From User Where Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE AND ContactId IN :tempVenStaff_SET and isActive = true];
                        //End D-4333 18-Jan-2016 Added By S.Puli
                        if(tempRestartUser_LIST.size()>0){
                            for(User uRec : tempRestartUser_LIST){
                                for(Id casId : tempRestartToContactSet_MAP.keySet()){
                                    for(Id conId : tempRestartToContactSet_MAP.get(casId)){
                                        if(conId == uRec.ContactId){
                                            //START UD-3170 05-Nov-2015 Added by S.Puli - relocate code below
                                            /*if(!tempRestartToAlias_MAP.containsKey(casId)){
                                                tempRestartToAlias_MAP.put(casId, uRec.Alias);
                                            }*/
                                            //END UD-3170 05-Nov-2015 Added by S.Puli
                                            if(!tempRestartToUserId_MAP.containsKey(casId)){
                                                tempRestartToUserId_MAP.put(casId, uRec.Id);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP
            //tempRestartToAdd_MAP,addIdToRecord_MAP
            //END: D-3140 20/06/2015 Added by S.Puli
            //Get Vendor Account
            List<Case> casesPerSubscriptionList = new List<Case>();
            if(scope != null){
                for(Case caseObj: scope){
                    caseIdSet.add(caseObj.Id);  
                    accountIdSet.add(caseObj.Account.Id);
                    mapCaseToCaseVendorSubscription.put(caseObj.id, caseObj.Case_Vendor_Subscriptions__r);

                    for(Case_Vendor_Subscription__c cvs :caseObj.Case_Vendor_Subscriptions__r) {
                    //START D-2532 MGaelo 4/16/2015 Checking of subscription
                        // START : UD-0982 5/12/2015 MGaelo
                                vendorAccountIdSet.add(cvs.Subscription_Vendor__r.Vendor__c); 
                                /*venMobileNumber = '';
                                venMobileNumber = subven.Vendor__r.Handphone_Number__c;*/
                            // END : UD-0982 5/12/2015 MGaelo    
                        
                    //END D-2532 MGaelo 4/16/2015 Checking of subscription    
                        contactIdSet.add(cvs.Subscription_Vendor__r.Recipient__c);
                        
                        if (cvs.case__r.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') &&         
                           (cvs.case__r.Temp_Stop__r.Temp_Stop_Date__c == Date.today()+1 || 
                            cvs.case__r.Temp_Stop__r.Restart_Date__c == Date.today()+1)) {                     // For Temp Stop Subscription (Vendor)
                            
                            subscriptionVendorTempStopIdSet.add(cvs.Subscription_Vendor__c);
                            //mapSubscriptionVendorToCase.put(cvs.Subscription_Vendor__c, caseObj);
                          
                            if (mapSubscriptionVendorToCaseList.containsKey(cvs.Subscription_Vendor__c)) {
                                mapSubscriptionVendorToCaseList.get(cvs.Subscription_Vendor__c).add(caseObj);
                            }
                            else {
                                mapSubscriptionVendorToCaseList.put(cvs.Subscription_Vendor__c, new List <Case> {caseObj});
                            }
                        }
        //START D-3009 05/22/2015 Jason A./Sherwin P.
                        else if (cvs.Subscription_Vendor__r.Subscription_Start_Date__c == Date.today() + 1 && cvs.case__r.RecordTypeId == ConstantsSLB.getKeyId('Case_Start Sub')) { // For Start Subscription (Vendor)
                            subscriptionVendorIdSet.add(cvs.Subscription_Vendor__c);
                            //mapSubscriptionVendorToCase.put(cvs.Subscription_Vendor__c, caseObj);

                            if (mapSubscriptionVendorToCaseList.containsKey(cvs.Subscription_Vendor__c)) {
                                mapSubscriptionVendorToCaseList.get(cvs.Subscription_Vendor__c).add(caseObj);
                            }
                            else {
                                mapSubscriptionVendorToCaseList.put(cvs.Subscription_Vendor__c, new List <Case> {caseObj});
                            }
                            //START UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                            if(!startCasesToSubs_Map.containsKey(caseObj.Id)){
                                startCasesToSubs_Map.put(caseObj.Id, new Set<Id>{cvs.Subscription_Vendor__c});
                            }
                            else {
                                startCasesToSubs_Map.get(caseObj.Id).add(cvs.Subscription_Vendor__c);
                            }
                            //END UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                        }
                        
                        // START : D-2913 5/19/2015 Jason A./Sherwin P.
                        if (cvs.case__r.RecordTypeId == ConstantsSLB.getKeyId('Case_Change in Address') && caseObj.Effective_Date__c == Date.today() + 1 ) { 
                            subscriptionVendorIdSet.add(cvs.Subscription_Vendor__c);

                            if (mapSubscriptionVendorToCaseList.containsKey(cvs.Subscription_Vendor__c)) {
                                mapSubscriptionVendorToCaseList.get(cvs.Subscription_Vendor__c).add(caseObj);
                            }
                            else {
                                mapSubscriptionVendorToCaseList.put(cvs.Subscription_Vendor__c, new List <Case> {caseObj});
                            }
                        }
                        // END : D-2913 5/19/2015 Jason A./Sherwin P.
        //END D-3009 05/22/2015 Jason A./Sherwin P.                
                    }
                    
                    
                    if (caseObj.RecordTypeId == ConstantsSLB.getKeyId('Case_Stop')) {                           // For Stop Subscription (Vendor)
                        
                        //START UD-2016 27-July-2015 Added By S.Puli
                        Map<Id,Id> stopOliChecker = new Map<Id,Id>();
                        //END UD-2016 27-July-2015 Added By S.Puli
                        
                        for (Order_Line_Item_Vendor__c oliVendor :caseObj.Order_Line_Items1__r) { // Start/End UD-2016 VPernicia uncomment
                        //START D-2496 03-12-2015 Marvin Gatchalian
                            if (caseObj.Order_Line_Items1__r <> null && caseObj.Order_Line_Items1__r.size() > 0) {
                        //END D-2496 03-12-2015 Marvin Gatchalian    
                        
                                //Order_Line_Item_Vendor__c oliVendor = caseObj.Order_Line_Items1__r[0]; // Start/End UD-2016 VPernicia Comment-out
                            
                            
                                contactIdSet.add(oliVendor.Subscription_Vendor__r.Recipient__c);
                                if (oliVendor.Stop_Request_Date__c == Date.today() + 1) { 
                                                               
                                    subscriptionVendorIdSet.add(oliVendor.Subscription_Vendor__c);
                                    //mapSubscriptionVendorToCase.put(oliVendor.Subscription_Vendor__c, caseObj);
                                    //START UD-2016 27-July-2015 Added By S.Puli
                                    if(!stopOliChecker.containsKey(oliVendor.Subscription_Vendor__c)){
                                        if (mapSubscriptionVendorToCaseList.containsKey(oliVendor.Subscription_Vendor__c)) {
                                            mapSubscriptionVendorToCaseList.get(oliVendor.Subscription_Vendor__c).add(caseObj);
                                        }
                                        else {
                                            mapSubscriptionVendorToCaseList.put(oliVendor.Subscription_Vendor__c, new List <Case> {caseObj});
                                        }
                                        stopOliChecker.put(oliVendor.Subscription_Vendor__c, oliVendor.Id);
                                    }
                                    //END UD-2016 27-July-2015 Added By S.Puli
                                }
                            }
                        } // Start/End UD-2016 VPernicia uncomment
                        
                    }
                    
                    //START UD-3170 05-Nov-2015 Added by S.Puli
                    
                }           
            }
            if(vendorAccountIdSet.size()>0){
            //Start D-4333 18-Jan-2016 Added By S.Puli
            vendorStaffsList = [SELECT id, name, Email, HomePhone__c, Vendor_Communication_Preference__c, Active__c FROM Contact WHERE AccountId IN: vendorAccountIdSet And Active__c = true]; // START-END : UD-0982 5/12/2015 MGaelo
            //End D-4333 18-Jan-2016 Added By S.Puli
                    //START MGaelo 4/16/2015 D-2532 Checking VendorStaff
                if(vendorStaffsList != null){
                        venStaffMobileNumberList = new Set<String>(); 
                        for(Contact venCon:vendorStaffsList){                           
                        // START : UD-0982 5/7/2015 MGaelo
                        if((venCon.Vendor_Communication_Preference__c == 'Both' || venCon.Vendor_Communication_Preference__c == 'SMS') && venCon.Active__c){
                        //START D-3202 7/15/2015 added by Jason A./Sherwin P. 
                            //venStaffMobileNumberList.add(venCon.HomePhone__c);
                        //END D-3202 7/15/2015 added by Jason A./Sherwin P.
                        }
                        if(venCon.Email != null){    
                            if(toAddresses.size() < 100){
                                toAddresses.add(venCon.Email);                                                                  
                            }
                        }                   
                        // END : UD-0982 5/7/2015 MGaelo
                    }
                }
            }
            //END UD-3170 05-Nov-2015 Added by S.Puli
             //END MGaelo 4/16/2015 D-2532 Checking VendorStaff
            // Get Vendor and Vendor Staff
            //START UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification 
            List<Order_Line_Item_Vendor__c> startOrderLine_List = new List<Order_Line_Item_Vendor__c>();
            Map<Id, Map<Id, boolean>> caseToPubToKey_MAP = new Map<Id, Map<Id, boolean>>();
            if(startCasesToSubs_Map.size() > 0){
                startOrderLine_List = [SELECT Case__c, Notify_Vendor__c, Order__c, Publication__c, Start_Date__c FROM Order_Line_Item_Vendor__c WHERE Case__c IN :startCasesToSubs_Map.keyset() AND Start_Date__c = tomorrow];
                if(startOrderLine_List.size()>0){
                    for(Order_Line_Item_Vendor__c oliVRec : startOrderLine_List){
                        if(!caseToPubToKey_MAP.containsKey(oliVRec.Case__c)){
                            caseToPubToKey_MAP.put(oliVRec.Case__c, new Map<Id, boolean>{oliVRec.Publication__c => oliVRec.Notify_Vendor__c});
                        }
                        else{
                            caseToPubToKey_MAP.get(oliVRec.Case__c).put(oliVRec.Publication__c, oliVRec.Notify_Vendor__c);
                        }
                    }
                }
            }
            //END UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification

            Map<Id, id> conId_NameMap = new Map<Id, Id>(); // START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
            if(accountIdSet <> null && accountIdSet.size() > 0){
            //START D-3202 7/15/2015 added by Jason A./Sherwin P. 
            //START UD-0982 MGaelo Added VendorCommunicationPreference
                List<Contact> vendStaffList = [Select Id, Name, Email, RecordType.Name, Address__r.Id, Vendor_Communication_Preference__c,
                                                 AccountId,  Active__c From Contact
                                                 Where AccountId IN :vendorAccountIdSet AND RecordType.Name = :GlobalVariableClass.VENDOR_STAFF AND Active__c = true];
            //END UD-0982 MGaelo Added VendorCommunicationPreference 
            //END D-3202 7/15/2015 added by Jason A./Sherwin P.
             
                if(vendStaffList <> null && vendStaffList.size() > 0){
                    for(Contact c : vendStaffList){

                        contactVendorStaff.put (c.Id, c);
                        addressIdSet.add(c.Address__r.Id);
                    }
                }
                
                // Start UD-2016 VPernicia: Add order by and isActive
            
                List<User> userList = [Select Id, Name, Profile.UserLicense.Name, Alias, ContactId From User Where Profile.UserLicense.Name = :GlobalVariableClass.USER_LICENSE AND ContactId IN :vendorStaffContactIdMAP.keyset() and isActive=true Order by Createddate asc];
                // End UD-2016 VPernicia: Add order by
            
                if(userList <> null && userList.size() > 0){
                    for(User u : userList){
                        conId_NameMap.put(vendorStaffContactIdMAP.get(u.ContactId), u.id); // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                        vendorStaffId_partnerUser.put(u.ContactId,u); // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                    }
                }
            }
            // Get Vendor and Vendor Staff
            
            //Get Contacts(Vendor Staff) for every Account
            //START D-2532 MGaelo 4/16/2015 Added Home Phone
            //Start D-4333 18-Jan-2016 Added By S.Puli
            vendorStaffList = [SELECT Id, Account.Id, Email, HomePhone__c FROM Contact WHERE Account.Id IN :accountIdSet AND RecordTypeId = :vendorStaffRecTypeId and Active__c = true];
            //End D-4333 18-Jan-2016 Added By S.Puli
            //END D-2532 MGaelo 4/16/2015 Added Home Phone
            if(vendorStaffList != null){
                for(Contact vendorStaff:vendorStaffList){
                    List<Contact> vendorStaffTempList = account_VendorStaffMap.get(vendorStaff.Account.Id);
                    if(vendorStaffTempList == null){
                        vendorStaffTempList = new List<Contact>();
                    }
                    vendorStaffTempList.add(vendorStaff);
                    account_VendorStaffMap.put(vendorStaff.Account.Id,vendorStaffTempList);
                }
            }
            //Get Contacts(Vendor Staff) for every Account
            
            //Get contacts
            contactMap =  new Map<Id, Contact>([SELECT Id, FirstName, LastName, Address__r.Id, Salutation FROM Contact WHERE Id IN: contactIdSet]);
            if(contactMap  != null){
                for(Contact c : contactMap.values()){
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
            //Get Addresses based on Contacts
            
            //Get SingpostAddress based on Addresses
            singpostAddressMap = new Map<ID, Singpost_Address__c>([SELECT Id, Name FROM Singpost_Address__c WHERE Id IN: singpostAddressIdSet]);
     
           // if(singpostAddressList != null){
           //     for(Singpost_Address__c singpostAddress : singpostAddressList){
           //         singpostAddressMap.put(singpostAddress.Id, singpostAddress);
           //     }
           // }
           //Get SingpostAddress based on Addresses
           
            subscriptionVendorIdSet.addall(subscriptionVendorTempStopIdSet);
            //START D-2532 MGaelo 4/16/2015 Added HandphoneNumber
            //START UD-0982 MGaelo 5/6/2015 Added VendorCommunicationPreference
            //Start UD-3057 09-Oct-2015 Added by S.Puli - add filter to include subscriptions delivered by vendor only
            //START D-3727 16-Oct-2015 Added by S.Puli
            //START UD-3140 22-Oct-2015 Added by S.Puli
            Map<Id, List<Subscription_Vendor_Publication__c>> subTosubVenPub = new Map<Id, List<Subscription_Vendor_Publication__c>>();
            List<Subscription_Vendor_Publication__c> subVenPub_LIST = new List<Subscription_Vendor_Publication__c>();
            List<Order_Line_Item_Vendor__c> stopOrderLines = new List<Order_Line_Item_Vendor__c>();
            List<Case_Vendor_Subscription__c> casVenSubs_LIST = new List<Case_Vendor_Subscription__c>();
            Map<Id, boolean> stopSubToKey = new Map<Id, boolean>();
            //START UD-3170 05-Nov-2015 Added by S.Puli
            Map<Id, String> subIdToZoneName = new Map<Id, String>();
            Map<String, String> zoneNameToAlias = new Map<String, String>();
            List<Post_Sector_Ops_Rep_Mapping__c> postSectorMapping_List = new List<Post_Sector_Ops_Rep_Mapping__c>();
            //END UD-3170 05-Nov-2015 Added by S.Puli
            if (subscriptionVendorIdSet <> null) {
                //START UD-3170 05-Nov-2015 Added by S.Puli
                subscriptionVendorList = [select id, Name, Subscription_Start_Date__c, Vendor__r.RecordType.Name, Vendor__r.Vendor_Communication_Preference__c, Subscription_Stop_Date__c, Vendor__c, Vendor__r.email__c, Vendor__r.Active__c, Order_Number__r.Vendor_Sms_Remarks__c, Recipient__c, Recipient__r.Address__c,Recipient__r.Address__r.Postal_Code__r.Name, Vendor__r.Handphone_Number__c,(select id, Publication__r.Publication_Code__c, Mon__c, Tue__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c, PHd__c, PHe__c, Subscription_Vendor__c from Subscription_Vendor_Publications__r) from Subscription_Vendor__c where id in :subscriptionVendorIdSet AND Vendor__r.RecordType.Name = :GlobalVariableClass.VENDOR];
                //END UD-3170 05-Nov-2015 Added by S.Puli
                
                casVenSubs_LIST = [Select Id, Case__c, Subscription_Vendor__c, Case__r.RecordTypeId, Case__r.Temp_Stop__r.Temp_Stop_Qty__c, Case__r.Temp_Stop__r.Temp_Stop_Date__c From Case_Vendor_Subscription__c Where Subscription_Vendor__c In :subscriptionVendorIdSet And Case__r.RecordTypeId = :ConstantsSLB.getKeyId('Case_Temp Stop') And Case__r.Temp_Stop__c <> null And Case__r.Temp_Stop__r.Temp_Stop_Date__c = tomorrow AND Case__r.Temp_Stop__r.Temp_Stop_Status__c <> :GlobalVariableClass.TS_STATUS_CANCELLED];
                system.debug('casVenSubs_LIST: '+casVenSubs_LIST);
                if(casVenSubs_LIST.size()>0){
                    for(Case_Vendor_Subscription__c csvRec : casVenSubs_LIST){
                        if(!subIdToCaseIdToTempStopQty_MAP.containsKey(csvRec.Subscription_Vendor__c)){
                            subIdToCaseIdToTempStopQty_MAP.put(csvRec.Subscription_Vendor__c, new Map<Id, Decimal>{csvRec.Case__c => csvRec.Case__r.Temp_Stop__r.Temp_Stop_Qty__c});
                        }
                        else{
                            subIdToCaseIdToTempStopQty_MAP.get(csvRec.Subscription_Vendor__c).put(csvRec.Case__c, csvRec.Case__r.Temp_Stop__r.Temp_Stop_Qty__c);
                        }
                    }
                }
                //START UD-3170 05-Nov-2015 Added by S.Puli
                if(subscriptionVendorList.size() > 0){
                    for(Subscription_Vendor__c subsVenToZone : subscriptionVendorList){
                        if(subsVenToZone.Recipient__c <> null){
                            if(subsVenToZone.Recipient__r.Address__c <> null){
                                if(subsVenToZone.Recipient__r.Address__r.Postal_Code__c <> null){
                                    if(subsVenToZone.Recipient__r.Address__r.Postal_Code__r.Name.length() > 2){
                                        subIdToZoneName.put(subsVenToZone.Id, subsVenToZone.Recipient__r.Address__r.Postal_Code__r.Name.subString(0,2));
                                    }
                                }
                            }
                        }
                    }
                }
                if(subIdToZoneName.size()>0){
                    postSectorMapping_List = [Select Id, Zone__r.Name, Vendor_Ops__c, Vendor_Ops__r.Alias, Vendor_Ops__r.IsActive From Post_Sector_Ops_Rep_Mapping__c Where Zone__r.Name In :subIdToZoneName.values() AND Vendor_Ops__c <> null AND Vendor_Ops__r.IsActive = true];
                    if(postSectorMapping_List.size()>0){
                        for(Post_Sector_Ops_Rep_Mapping__c postRec : postSectorMapping_List){
                            for(Id subId : subIdToZoneName.keySet()){
                                if(subIdToZoneName.get(subId) == postRec.Zone__r.Name){
                                    if(postRec.Vendor_Ops__c <> null){
                                        conId_AliasMap.put(subId, postRec.Vendor_Ops__r.Alias);
                                    }
                                }
                            }
                        }
                    }
                }
                //END UD-3170 05-Nov-2015 Added by S.Puli
                
                if(subscriptionVendorIdSet.size() > 0){
                    //Start Sub
                    subVenPub_LIST = [SELECT Subscription_Vendor__c, Subscription_Vendor__r.Subscription_Start_Date__c, Publication__c FROM Subscription_Vendor_Publication__c WHERE Subscription_Vendor__c IN :subscriptionVendorIdSet AND Subscription_Vendor__r.Subscription_Start_Date__c = Tomorrow];
                    
                    if(subVenPub_LIST.size()>0){
                        for(Subscription_Vendor_Publication__c subVenPubs : subVenPub_LIST){
                            if(!subTosubVenPub.containsKey(subVenPubs.Subscription_Vendor__c)){
                                subTosubVenPub.put(subVenPubs.Subscription_Vendor__c, new List<Subscription_Vendor_Publication__c>{subVenPubs});
                            }
                            else{
                                subTosubVenPub.get(subVenPubs.Subscription_Vendor__c).add(subVenPubs);
                            }
                        }
                    }
                    //Stop Sub
                    stopOrderLines = [SELECT Subscription_Vendor__c,Subscription_Vendor__r.Subscription_Stop_Date__c, Suppress_Vendor_Notification__c FROM Order_Line_Item_Vendor__c WHERE Subscription_Vendor__r.Subscription_Stop_Date__c = tomorrow AND Subscription_Vendor__c IN :subscriptionVendorIdSet];
                    if(stopOrderLines.size()>0){
                        for(Order_Line_Item_Vendor__c stopOli : stopOrderLines){
                            if(!stopSubToKey.containsKey(stopOli.Subscription_Vendor__c)){
                                stopSubToKey.put(stopOli.Subscription_Vendor__c, stopOli.Suppress_Vendor_Notification__c);
                            }
                        }
                    }
                }
            }
            //END UD-3140 22-Oct-2015 Added by S.Puli
            //END D-3727 16-Oct-2015 Added by S.Puli
            //END UD-3057 09-Oct-2015 Added by S.Puli
            //END UD-0982 MGaelo 5/6/2015 Added VendorCommunicationPreference
            //END D-2532 MGaelo 4/16/2015 Added HandphoneNumber
            
            
            //Start of Main Looping
            
            for (Subscription_Vendor__c subsVendor :subscriptionVendorList) {
                
                if (mapSubscriptionVendorToCaseList.containsKey(subsVendor.id)) {
                
                    svPub = subsVendor.Subscription_Vendor_Publications__r;
                    if (svPub != null) {
                        //START UD-2016 27-July-2015 Added By Von P./S.Puli
                        //pubCode.clear();
                        pubCode = new set<string>();
                        //END UD-2016 27-July-2015 Added By Von P./S.Puli
                        Mon=0;Tue=0;Wed=0;Thu=0;Fri=0;Sat=0;Sun=0;PHd=0;PHe=0;
                        //START D-3727 16-Oct-2015 Added by S.Puli
                        MonTS=0;TueTS=0;WedTS=0;ThuTS=0;FriTS=0;SatTS=0;SunTS=0;PHdTS=0;PHeTS=0;
                        frequencyDigitTS = '';
                        //END D-3727 16-Oct-2015 Added by S.Puli
                        frequencyDay  = '';
                        frequencyDigit = '';
                        for(Subscription_Vendor_Publication__c svp: svPub){
                            if (svp.Publication__c != null) {
                                    pubCode.add(svp.Publication__r.Publication_Code__c);
                                //rollUpDays(Mon, Tue, Wed, Thu, Fri, Sat, Sun, PHd, PHe, svp);
                                rollUpDays(svp);
                            }  
                        }
                        ArrangeFrequency();
                        //START UD-2016 27-July-2015 Added By Von P./S.Puli
                        details.clear();
                        //details = new  Map <string, string>();
                        //END UD-2016 27-July-2015 Added By Von P./S.Puli
                        //START D-3727 16-Oct-2015 Added by S.Puli
                        system.debug('frequencyDigitTS: '+frequencyDigitTS);
                        detailsTS.clear();
                        for (string eachPubCode: pubCode) {
                            Publication__c pub = new Publication__c();
                            pub = publicationMap.get(eachPubCode);
                            
                            if (publicationMap.containskey(eachPubCode)) {
                                if (details.containskey(pub.Sunday_Publication__r.Publication_Code__c)) {
                                    //Start UD-3158 09-Dec-2015 Added By S.Puli
                                    //Start UD-3379 02-Feb-2016 Added By S.Puli
                                    partialTemplateTS = string.valueOf(eachPubCode) + '/' + partialTemplateTS;
                                    //End UD-3379 02-Feb-2016 Added By S.Puli
                                    partialTemplate = string.valueOf(eachPubCode) + '/' + partialTemplate;
                                    details.put(pub.Sunday_Publication__r.Publication_Code__c, partialTemplate);
                                    detailsTS.put(pub.Sunday_Publication__r.Publication_Code__c, partialTemplateTS);
                                    //End UD-3158 09-Dec-2015 Added By S.Puli
                                }
                                else {
                                    partialTemplate = '';
                                    partialTemplateTS = '';
                    // START : UD-0985 7/8/2015 Alyana Navarro
                                    if(Sun > 0){
                                        partialTemplate = string.valueOf(eachPubCode) + '/' + pub.Sunday_Publication__r.Publication_Code__c;
                                        partialTemplateTS = string.valueOf(eachPubCode) + '/' + pub.Sunday_Publication__r.Publication_Code__c;
                                    } else {
                                        partialTemplate = string.valueOf(eachPubCode);
                                        partialTemplateTS = string.valueOf(eachPubCode);
                                    }
                    // END : UD-0985 7/8/2015 Alyana Navarro
                                    if(subsVendor != null){
                                        partialTemplate += ' (' + frequencyDay + ' > ' + frequencyDigit + ')';    
                                        partialTemplateTS += ' (' + frequencyDay + ' > ' + frequencyDigitTS + ')'; 
                                    }
                                    details.put(pub.Sunday_Publication__r.Publication_Code__c, partialTemplate);
                                    detailsTS.put(pub.Sunday_Publication__r.Publication_Code__c, partialTemplateTS);
                                }
                            }
                            else { // if pub code has no look up publication
                                if (!details.containskey(eachPubCode)) {
                                    partialTemplate = '';
                                    partialTemplateTS = '';
                                    partialTemplate = string.valueOf(eachPubCode);
                                    partialTemplateTS = string.valueOf(eachPubCode);
                                    if(subsVendor != null){
                                        partialTemplate += ' (' + frequencyDay +  ' > ' + frequencyDigit + ')';
                                        partialTemplateTS += ' (' + frequencyDay +  ' > ' + frequencyDigitTS + ')';
                                    }
                                    details.put(eachPubCode, partialTemplate );
                                    detailsTS.put(eachPubCode, partialTemplateTS );
                                }
                            }
          
                        }
                    }
                    // Arranging pubcode format
                    
                    partialTemplate  = '';
                    partialTemplateTS  = '';
                    myCounter = 0;
                    for (String perSub : details.keyset()) {
                        myCounter += 1;
                     
                        if (details.size() == myCounter && details.size() > 1) {
                            partialTemplate += 'and ' + details.get(perSub);
                            partialTemplateTS += 'and ' + detailsTS.get(perSub);
                        }
                        else {
                            partialTemplate += details.get(perSub);
                            partialTemplateTS += detailsTS.get(perSub);
                        }
                    }
                
                    //END D-3727 16-Oct-2015 Added by S.Puli
                    
                   
                   
                   // Need to loop in cases for each subscription
                   // Need to loop in cases for each subscription
                   // Need to loop in cases for each subscription
                   //casesPerSubscriptionList.clear();         //START-END D-2913 05/18/2015 Jason A./Sherwin P.
                   if (mapSubscriptionVendorToCaseList.containskey(subsVendor.id)) {
                       casesPerSubscriptionList = mapSubscriptionVendorToCaseList.get(subsVendor.id);
                       
                   }
                   if (casesPerSubscriptionList.size() > 0 && casesPerSubscriptionList <> null) {
                       
                       for(Case currentCase :casesPerSubscriptionList ) {
                            //START D-3727 16-Oct-2015 Added by S.Puli
                            if(subIdToCaseIdToTempStopQty_MAP.containsKey(subsVendor.id)){
                                if(subIdToCaseIdToTempStopQty_MAP.get(subsVendor.id).containsKey(currentCase.Id)){
                                    //Start UD-3379 20-Jan-2016 Added By S.Puli         
                                    if(tempStopToSubsIdentifier_MAP.containsKey(currentCase.Id)){
                                        if(!tempStopToSubsIdentifier_MAP.get(currentCase.Id).get(subsVendor.Id)){
                                            partialTemplate = partialTemplateTS;
                                        }
                                    }else{
                                        partialTemplate = partialTemplateTS;
                                    }
                                    //End UD-3379 20-Jan-2016 Added By S.Puli
                                }
                            }
                            //END D-3727 16-Oct-2015 Added by S.Puli
                            // START 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                            venStaffid = new Set<String>();
                            // END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment                       
                       
                            //currentCase = mapSubscriptionVendorToCase.get(subsVendor.id);
                            //START UD-2016 27-July-2015 Added By Von P./S.Puli
                            //toAddresses.clear();
                            toAddresses = new List<String>();
                            //END UD-2016 27-July-2015 Added By Von P./S.Puli
                            // START : D-2532 MGaelo 4/16/2015 Added logic for VenSub sms output
                            if (subsVendor.Vendor__r.Email__c <> null) {
                                // START : UD-0982 5/7/2015 MGaelo
                                if((subsVendor.Vendor__r.Vendor_Communication_Preference__c == 'Both' || subsVendor.Vendor__r.Vendor_Communication_Preference__c == 'Email') && subsVendor.Vendor__r.Active__c){
                                    toAddresses.add(subsVendor.Vendor__r.Email__c); 
                                    isSendEmail = true;
                                }
                                // END : UD-0982 5/7/2015 MGaelo
                            }
                            //START D-3202 7/15/2015 added by Jason A./Sherwin P. 
                            venStaffMobileNumberList = new Set<String>();
                            //END D-3202 7/15/2015 added by Jason A./Sherwin P.
                            if (accountVendorToVendorStaff.containsKey(subsVendor.Vendor__c)) {                         
                                List<Contact> myContactList = new List<Contact>();
                                myContactList = accountVendorToVendorStaff.get(subsVendor.Vendor__c);
                                for (Contact myContact :myContactList ) {
                                    //Start UD-3457 26-Jan-2016 Added By S.Puli
                                    if(myContact.Active__c){
                                        venStaffid.add(myContact.Id);
                                    
                                        if (myContact.email != null ) {
                                            // START : UD-0982 5/7/2015 MGaelo
                                            if((myContact.Vendor_Communication_Preference__c == 'Both' || myContact.Vendor_Communication_Preference__c == 'Email') && myContact.Active__c){
                                                toAddresses.add(myContact.email);
                                                isSendEmail = true;
                                            }
                                            // END : UD-0982 5/7/2015 MGaelo
                                            //REMOVE venStaffid.add(myContact.Id); // /START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment  
                                        }
                                        
                                        // START : UD-0982 5/7/2015 MGaelo
                                        if(contactVendorStaff.containsKey(myContact.id)){
                                            if(contactVendorStaff.get(myContact.id).Vendor_Communication_Preference__c == 'SMS' || contactVendorStaff.get(myContact.id).Vendor_Communication_Preference__c == 'Both'){
                                                if(myContact.HomePhone__c != null){
                                                    venStaffMobileNumberList.add(myContact.HomePhone__c);
                                                }
                                            }
                                        }
                                    }
                                    //End UD-3457 26-Jan-2016 Added By S.Puli
                                    // END : UD-0928 5/7/2015 MGaelo
                                }
                            }
                            if(subsVendor.Vendor__r.Handphone_Number__c != null){
                                venMobileNumber = subsVendor.Vendor__r.Handphone_Number__c;
                            }
                            // END : D-2532 MGaelo 4/16/2015 Added logic for VenSub sms output
                            if(contactMap != null && subsVendor != null){            
                                currentContact = contactMap.get(subsVendor.Recipient__c);   
                                
                            }
                            
                            if(addressMap != null && currentContact != null){
                                addressObj = addressMap.get(currentContact.Address__r.Id);
                            }
                            
                            if(singpostAddressMap != null && addressObj != null){
                                singpostAddressObj = singpostAddressMap.get(addressObj.Postal_Code__r.Id);
                            } 
                            
                            
                            // START UD-2016 VPernicia: Add filter for stop subs stop date is tomorrow
                            if(currentCase.RecordTypeId == ConstantsSLB.getKeyId('Case_Stop') && subsVendor.Subscription_Stop_Date__c == Date.today()+1){ //Stop Vendor Subscription ? Normal Stop Request
                            // END UD-2016 VPernicia
                                //if (!currentCase.Urgent_Request__c) {
                                //    transactionName = GlobalVariableClass.STOP_NORMAL;
                                //}
                                //else if (currentCase.Urgent_Request__c) {
                                //   
                                //}
                                //START UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                                if(stopSubToKey.containsKey(subsVendor.Id)){
                                    if(!stopSubToKey.get(subsVendor.Id)){
                                        transactionName = GlobalVariableClass.STOP_URGENT;
                                        sendMail = true;  
                                        issueDate = convertDateToString(Date.today()+1);                                                                                                               
                                    }
                                }
                                //END UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                            } 
                            else if(currentCase.RecordTypeId == ConstantsSLB.getKeyId('Case_Start Sub') && subsVendor.Subscription_Start_Date__c == Date.today()+1){ //Start Vendor Subscription ? Normal Start Request
                                //START UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                                if(subTosubVenPub.containsKey(subsVendor.Id)){
                                    if(caseToPubToKey_MAP.containsKey(currentCase.Id)){
                                        if(caseToPubToKey_MAP.get(currentCase.Id).size()>0){
                                            for(Id pubId : caseToPubToKey_MAP.get(currentCase.Id).keySet()){
                                                if(subTosubVenPub.get(subsVendor.Id).size() > 0){
                                                    if(subTosubVenPub.get(subsVendor.Id)[0].Publication__c == pubId){
                                                        if(caseToPubToKey_MAP.get(currentCase.Id).get(pubId)){
                                                            if (currentCase.Urgent_Request__c) {
                                                                transactionName = GlobalVariableClass.START_URGENT; 
                                                            }
                                                            else if (!currentCase.Urgent_Request__c) {
                                                                transactionName = GlobalVariableClass.START_NEW;
                                                            }
                                                            sendMail = true;  
                                                            issueDate = convertDateToString(subsVendor.Subscription_Start_Date__c);                                                                                                                                         
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                //END UD-3140 22-Oct-2015 Added by S.Puli - suppress vendor notification
                            }
                            else if(currentCase.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && currentCase.Temp_Stop__r.Temp_Stop_Date__c == Date.today()+1){ //Temp-Stop Vendor Subscription ? Normal Stop Request (Vendor Ops)
                                
                                if(currentCase.Requires_Urgent_Approval__c){
                                    transactionName = GlobalVariableClass.STOP_TEMPSTOP_URGENT;
                                } else {
                                    transactionName = GlobalVariableClass.STOP_TEMPSTOP;
                                }
                                sendMail = true;
                                issueDate = convertDateToString(currentCase.Temp_Stop__r.Temp_Stop_Date__c);                                                                                                                                                                        
                            }
                            else if(currentCase.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && currentCase.Temp_Stop__r.Restart_Date__c == Date.today()+1){ //Temp-Stop Vendor Subscription ? Normal Stop Request (Salesforce)
                                //transactionName = GlobalVariableClass.STOP_TEMPSTOP_URGENT ;
                                
                                if(currentCase.Requires_Urgent_Approval__c){
                                    transactionName = GlobalVariableClass.TS_URGENTRESTART;
                                } else {
                                    transactionName = GlobalVariableClass.TS_RESTART;
                                }
                                
                                sendMail = true;
                                issueDate = convertDateToString(currentCase.Temp_Stop__r.Restart_Date__c);                                                                                                                                                                                                  
            //START D-2913 05/18/2015 Jason A./Sherwin P.
                            } else if(currentCase.RecordTypeId == ConstantsSLB.getKeyId('Case_Change in Address') && currentCase.Effective_Date__c == Date.today()+1){
                                transactionName = GlobalVariableClass.COA_STOP;
                                sendMail = true;
                                issueDate = convertDateToString(currentCase.Effective_Date__c);
            //END D-2913 05/18/2015 Jason A./Sherwin P.
                            }
                            /* Should be part of Direct Notfication since this is not yet officially Vendor
                            else if(subsVendor.Vendor_Subscription_To_Convert_1__c != null && subsVendor.Subscription_Stop_Date__c == Date.today()+1){ //Vendor to Direct Subscription - Subscription Integration
                                transactionName = GlobalVariableClass.START_CONVERSION;
                                sendMail = true;   
                                issueDate = convertDateToString(subsVendor.Subscription_Stop_Date__c);
                            }  Should be part of Direct Notfication since this is not yet officially Vendor 
                            */
            
                            classification = GlobalVariableClass.NOTIF_CLASS_VENDOR ;
                            if(sendMail == true){
                            
                               //START UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference
                                Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage(); 
                               if(partialTemplate != '' && partialTemplate != null){ // START-END : UD-1423 6/3/2015 Alyana Navarro - Remove part of the condition.
                                //START: D-3140 20/06/2015 Added by S.Puli
                                    system.debug('tempStopToSubsIdentifier_MAP>>'+tempStopToSubsIdentifier_MAP);
                                    //START D-3727 16-Oct-2015 Added by S.Puli
                                    if(currentCase.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && currentCase.Temp_Stop__r.Temp_Stop_Date__c == Date.today()+1 && currentCase.COA__c){
                                        //Start UD-3379 02-Feb-2016 Added By S.Puli
                                        if(tempStopToSubsIdentifier_MAP.containsKey(currentCase.Id)){
                                            if(tempStopToSubsIdentifier_MAP.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                if(tempStopToSubsIdentifier_MAP.get(currentCase.Id).get(subsVendor.Id)){
                                                    transactionName = GlobalVariableClass.STOP_URGENT;
                                                }
                                                
                                                constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                            currentCase, subsVendor, conId_AliasMap, 
                                                                            issueDate, partialTemplate, addressObj,
                                                                            singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                
                                            }
                                        }else{
                                            constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                            currentCase, subsVendor, conId_AliasMap, 
                                                                            issueDate, partialTemplate, addressObj,
                                                                            singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                        }
                                        //End UD-3379 02-Feb-2016 Added By S.Puli
                                    }
                                    else if(currentCase.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && currentCase.Temp_Stop__r.Restart_Date__c == Date.today()+1 && currentCase.COA__c){
                                        //tempRestartToAdd_MAP,addIdToRecord_MAP
                                        
                                        if(tempRestartToAdd_MAP.containsKey(currentCase.Id)){
                                            addressObj = new Address__c();
                                            if(addIdToRecord_MAP.containsKey(tempRestartToAdd_MAP.get(currentCase.Id))){
                                                addressObj = addIdToRecord_MAP.get(tempRestartToAdd_MAP.get(currentCase.Id));
                                            }
                                        }
                                        system.debug('addressObj>>'+addressObj);
                                        //Start UD-2016 VPernicia
                                        constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                    currentCase, subsVendor, conId_AliasMap, 
                                                                    issueDate, partialTemplate, addressObj,
                                                                    singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                                    
                                        //if(isSendEmail){
                                        //    mailList.add(mailTemp);
                                        //}
                                        //End UD-2016 VPernicia
                                        system.debug('Temp_Restart'+mailTemp);
                                        system.debug('isSendEmail'+isSendEmail);
                                        
                                    }
                                    else if(transactionName == GlobalVariableClass.COA_STOP){
                                        //Start UD-3379 20-Jan-2016 Added By S.Puli
                                        if(coaStartToSubsIdentifier_MAP.containsKey(currentCase.Id) || coaWithTempRestartTom.containsKey(currentCase.Id) || coaInBetwnTStop.containsKey(currentCase.Id)){
                                            if(coaStartToSubsIdentifier_MAP.containsKey(currentCase.Id)){
                                                if(coaStartToSubsIdentifier_MAP.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                    if(coaStartToSubsIdentifier_MAP.get(currentCase.Id).get(subsVendor.Id) <> true){
                                                        constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                        currentCase, subsVendor, conId_AliasMap, 
                                                                        issueDate, partialTemplate, addressObj,
                                                                        singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                    }
                                                }else if(!coaWithTempRestartTom.containsKey(currentCase.Id) && !coaInBetwnTStop.containsKey(currentCase.Id)){
                                                    constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                        currentCase, subsVendor, conId_AliasMap, 
                                                                        issueDate, partialTemplate, addressObj,
                                                                        singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                }
                                                if(coaWithTempRestartTom.containsKey(currentCase.Id)){
                                                    if(coaWithTempRestartTom.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                        if(coaWithTempRestartTom.get(currentCase.Id).get(subsVendor.Id) == true){
                                                            transactionName = GlobalVariableClass.STOP_URGENT;
                                                        }
                                                            constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                            currentCase, subsVendor, conId_AliasMap, 
                                                                            issueDate, partialTemplate, addressObj,
                                                                            singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                        
                                                    }
                                                }
                                                if(coaInBetwnTStop.containsKey(currentCase.Id)){
                                                    if(coaInBetwnTStop.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                        if(coaInBetwnTStop.get(currentCase.Id).get(subsVendor.Id) == true){
                                                            transactionName = GlobalVariableClass.STOP_URGENT;
                                                        }
                                                        constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                            currentCase, subsVendor, conId_AliasMap, 
                                                                            issueDate, partialTemplate, addressObj,
                                                                            singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                    }
                                                }
                                            }
                                            if(coaWithTempRestartTom.containsKey(currentCase.Id)){
                                                if(coaWithTempRestartTom.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                    if(coaWithTempRestartTom.get(currentCase.Id).get(subsVendor.Id) == true){
                                                        transactionName = GlobalVariableClass.STOP_URGENT;
                                                    }
                                                        constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                        currentCase, subsVendor, conId_AliasMap, 
                                                                        issueDate, partialTemplate, addressObj,
                                                                        singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                    
                                                }else if(!coaStartToSubsIdentifier_MAP.containsKey(currentCase.Id) && !coaInBetwnTStop.containsKey(currentCase.Id)){
                                                    constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                        currentCase, subsVendor, conId_AliasMap, 
                                                                        issueDate, partialTemplate, addressObj,
                                                                        singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                }
                                                if(coaStartToSubsIdentifier_MAP.containsKey(currentCase.Id)){
                                                    if(coaStartToSubsIdentifier_MAP.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                        if(coaStartToSubsIdentifier_MAP.get(currentCase.Id).get(subsVendor.Id) <> true){
                                                            constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                            currentCase, subsVendor, conId_AliasMap, 
                                                                            issueDate, partialTemplate, addressObj,
                                                                            singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                        }
                                                    }
                                                }
                                                if(coaInBetwnTStop.containsKey(currentCase.Id)){
                                                    if(coaInBetwnTStop.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                        if(coaInBetwnTStop.get(currentCase.Id).get(subsVendor.Id) == true){
                                                            transactionName = GlobalVariableClass.STOP_URGENT;
                                                        }
                                                        constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                            currentCase, subsVendor, conId_AliasMap, 
                                                                            issueDate, partialTemplate, addressObj,
                                                                            singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                    }
                                                }
                                            }
                                            if(coaInBetwnTStop.containsKey(currentCase.Id)){
                                                if(coaInBetwnTStop.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                    if(coaInBetwnTStop.get(currentCase.Id).get(subsVendor.Id) == true){
                                                        transactionName = GlobalVariableClass.STOP_URGENT;
                                                    }
                                                    constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                        currentCase, subsVendor, conId_AliasMap, 
                                                                        issueDate, partialTemplate, addressObj,
                                                                        singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                }else if(!coaStartToSubsIdentifier_MAP.containsKey(currentCase.Id) && !coaWithTempRestartTom.containsKey(currentCase.Id)){
                                                    constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                        currentCase, subsVendor, conId_AliasMap, 
                                                                        issueDate, partialTemplate, addressObj,
                                                                        singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                }
                                                if(coaStartToSubsIdentifier_MAP.containsKey(currentCase.Id)){
                                                    if(coaStartToSubsIdentifier_MAP.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                        if(coaStartToSubsIdentifier_MAP.get(currentCase.Id).get(subsVendor.Id) <> true){
                                                            constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                            currentCase, subsVendor, conId_AliasMap, 
                                                                            issueDate, partialTemplate, addressObj,
                                                                            singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                        }
                                                    }
                                                }
                                                if(coaWithTempRestartTom.containsKey(currentCase.Id)){
                                                    if(coaWithTempRestartTom.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                        if(coaWithTempRestartTom.get(currentCase.Id).get(subsVendor.Id) == true){
                                                            transactionName = GlobalVariableClass.STOP_URGENT;
                                                        }
                                                            constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                            currentCase, subsVendor, conId_AliasMap, 
                                                                            issueDate, partialTemplate, addressObj,
                                                                            singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                        
                                                    }
                                                }
                                            }
                                        }else{
                                            constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                    currentCase, subsVendor, conId_AliasMap, 
                                                                    issueDate, partialTemplate, addressObj,
                                                                    singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                        }
                                        
                                        //COA_START
                                        
                                        transactionName = GlobalVariableClass.COA_START;
                                        
                                        if(currentCase.Vendor__c <> null){
                                            if(mapVendorToStaff_MAP.containskey(currentCase.Vendor__c)){
                                                if(userIdToAlias_MAP.containskey(mapVendorToStaff_MAP.get(currentCase.Vendor__c))){
                                                    conId_AliasMap.put(currentCase.Id, userIdToAlias_MAP.get(mapVendorToStaff_MAP.get(currentCase.Vendor__c)));
                                                }
                                            }
                                        } else{
                                            if(caseIdToVendor_MAP.containskey(currentCase.Id)){
                                                if(mapVendorToStaff_MAP.containskey(caseIdToVendor_MAP.get(currentCase.Id))){
                                                    if(userIdToAlias_MAP.containskey(mapVendorToStaff_MAP.get(caseIdToVendor_MAP.get(currentCase.Id)))){
                                                            conId_AliasMap.put(currentCase.Id,  userIdToAlias_MAP.get(mapVendorToStaff_MAP.get(caseIdToVendor_MAP.get(currentCase.Id))));
                                                    }
                                                }
                                            }
                                        }
                                        if(currentCase.New_Address__c <> null && addressMapForStart.containskey(currentCase.New_Address__c)){
                                            addressObj = new Address__c();
                                            addressObj = addressMapForStart.get(currentCase.New_Address__c);
                                        }

                                        if(coaStartToSubsIdentifier_MAP.containsKey(currentCase.Id) || coaWithTempRestartTom.containsKey(currentCase.Id) || coaInBetwnTStop.containsKey(currentCase.Id)){
                                            if(coaStartToSubsIdentifier_MAP.containsKey(currentCase.Id)){   
                                                if(!coaStartToSubsIdentifier_MAP.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                    isSendEmail = true;
                                                    constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                        currentCase, subsVendor, conId_AliasMap, 
                                                                        issueDate, partialTemplate, addressObj,
                                                                        singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                                        
                                                }
                                            }
                                            if(coaWithTempRestartTom.containsKey(currentCase.Id)){  
                                                if(!coaWithTempRestartTom.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                    isSendEmail = true;
                                                    constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                        currentCase, subsVendor, conId_AliasMap, 
                                                                        issueDate, partialTemplate, addressObj,
                                                                        singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                                        
                                                }
                                            }
                                            if(coaInBetwnTStop.containsKey(currentCase.Id)){    
                                                if(!coaInBetwnTStop.get(currentCase.Id).containsKey(subsVendor.Id)){
                                                    isSendEmail = true;
                                                    constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                        currentCase, subsVendor, conId_AliasMap, 
                                                                        issueDate, partialTemplate, addressObj,
                                                                        singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                                        
                                                }
                                            }
                                        }else{
                                            isSendEmail = true;
                                            constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                currentCase, subsVendor, conId_AliasMap, 
                                                                issueDate, partialTemplate, addressObj,
                                                                singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                        }
                                        
                                    //End UD-3379 20-Jan-2016 Added By S.Puli    
                                    }else{
                                        //Start UD-2016 VPernicia
                                        constructMail(isSendEmail, caseToAddressVendorMap, transactionName, toAddresses, 
                                                                    currentCase, subsVendor, conId_AliasMap, 
                                                                    issueDate, partialTemplate, addressObj,
                                                                    singpostAddressObj, classification, conId_NameMap, sessionId, coaCaseToNewMobile_MAP, coaCaseToTaskContact_MAP, coaCaseToTaskUser_MAP, tempRestartToNewEmailAdd, tempRestartToNewMobile, tempRestartToContactSet_MAP, tempRestartToUserId_MAP, tempRestartToAlias_MAP, coaCaseToAlias_MAP, coaCaseToOldMobile);
                                                                    
                                        //if(isSendEmail){
                                        //    mailList.add(mailTemp); // START/END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
                                        //} // START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
                                        //End UD-2016 VPernicia
                                    }
                                //END UD-0982 MGaelo 5/6/2015 Added condition for VendorCommunicationPreference
                               }
                            }
                        // Need to loop in cases for each subscription
                        // Need to loop in cases for each subscription
                      }  // Need to loop in cases for each subscription
                    }
                }
            }              
           //Start: D-2532 03/12/2015 MGaelo sms output
           //Start UD-2016 VPernicia
           
            Database.insert(caseTeamList,false);
        //Start UD-3457 26-Jan-2016 Added By S.Puli
        }catch(Exception e){
            exceptionList.add(e);//error handling
        }
        
        ExceptionLogger.log(exceptionList); // you must invoke this at the end of your execution script
        //End UD-3457 26-Jan-2016 Added By S.Puli
    }
     
     
     public static void ArrangeFrequency () {
     
         boolean daily;
         daily=true;
         if (Mon <> 0) {
             frequencyDay = 'Mon/';
             daily= true;
         }
         else {daily= false;}
         if (Tue <> 0) {
             frequencyDay += 'Tue/';
         }
         else {daily= false;}
         if (Wed <> 0) {
             frequencyDay += 'Wed/';
         }
         else {daily= false;}
         if (Thu <> 0) {
             frequencyDay += 'Thu/';
         }
         else {daily= false;}
         if (Fri <> 0) {
             frequencyDay += 'Fri/';
         }
         else {daily= false;}
         if (Sat <> 0) {
             frequencyDay += 'Sat/';
         }
         else {daily= false;}
         if (Sun <> 0) {
             frequencyDay += 'Sun/';
         }
         else {daily= false;}
         if (daily) {
             frequencyDay = 'Daily';
         }
         else{
             frequencyDay = frequencyDay.left(frequencyDay.length() -1);
         }
         
         frequencyDigit = string.valueOf(Mon) + string.valueOf(Tue) + string.valueOf(Wed) + string.valueOf(Thu) + string.valueOf(Fri) + 
                  string.valueOf(Sat) + string.valueOf(Sun) + string.valueOf(PHd) + string.valueOf(PHe);
        //START D-3727 16-Oct-2015 Added by S.Puli
        if(MonTS <> null || TueTS <> null || WedTS <> null || ThuTS <> null || FriTS <> null || SatTS <> null || SunTS <> null || PHdTS <> null || PHeTS <> null){
            frequencyDigitTS = string.valueOf(MonTS) + string.valueOf(TueTS) + string.valueOf(WedTS) + string.valueOf(ThuTS) + string.valueOf(FriTS) + 
                  string.valueOf(SatTS) + string.valueOf(SunTS) + string.valueOf(PHdTS) + string.valueOf(PHeTS);
        }
        //END D-3727 16-Oct-2015 Added by S.Puli
      
     }
      
      //public static void rollUpDays (Integer Mon, Integer Tue, Integer Wed, Integer Thu, Integer Fri, Integer Sat, Integer Sun1, Integer PHd, Integer PHe, Subscription_Vendor_Publication__c subVenPub) {
      public static void rollUpDays (Subscription_Vendor_Publication__c subVenPub) {
        
        //START D-3727 16-Oct-2015 Added by S.Puli - use subIdToCaseIdToTempStopQty_MAP
        if (subVenPub.Mon__c <> null && subVenPub.Mon__c <> 0) {
            Mon += integer.valueOf(subVenPub.Mon__c);
            if(subIdToCaseIdToTempStopQty_MAP.containsKey(subVenPub.Subscription_Vendor__c)){
                MonTS = integer.valueOf(subIdToCaseIdToTempStopQty_MAP.get(subVenPub.Subscription_Vendor__c).values()[0]);
            }
        }
        if (subVenPub.Tue__c <> null && subVenPub.Tue__c <> 0) {
            Tue += integer.valueOf(subVenPub.Tue__c);
            if(subIdToCaseIdToTempStopQty_MAP.containsKey(subVenPub.Subscription_Vendor__c)){
                TueTS = integer.valueOf(subIdToCaseIdToTempStopQty_MAP.get(subVenPub.Subscription_Vendor__c).values()[0]);
            }
        }
        if (subVenPub.Wed__c <> null && subVenPub.Wed__c <> 0) {
            Wed += integer.valueOf(subVenPub.Wed__c);
            if(subIdToCaseIdToTempStopQty_MAP.containsKey(subVenPub.Subscription_Vendor__c)){
                WedTS = integer.valueOf(subIdToCaseIdToTempStopQty_MAP.get(subVenPub.Subscription_Vendor__c).values()[0]);
            }
        }
        if (subVenPub.Thu__c <> null && subVenPub.Thu__c <> 0) {
            Thu += integer.valueOf(subVenPub.Thu__c);
            if(subIdToCaseIdToTempStopQty_MAP.containsKey(subVenPub.Subscription_Vendor__c)){
                ThuTS = integer.valueOf(subIdToCaseIdToTempStopQty_MAP.get(subVenPub.Subscription_Vendor__c).values()[0]);
            }
        }
        if (subVenPub.Fri__c <> null && subVenPub.Fri__c <> 0) {
            Fri+= integer.valueOf(subVenPub.Fri__c);
            if(subIdToCaseIdToTempStopQty_MAP.containsKey(subVenPub.Subscription_Vendor__c)){
                FriTS = integer.valueOf(subIdToCaseIdToTempStopQty_MAP.get(subVenPub.Subscription_Vendor__c).values()[0]);
            }
        }
        if (subVenPub.Sat__c <> null && subVenPub.Sat__c <> 0) {
            Sat += integer.valueOf(subVenPub.Sat__c);
            if(subIdToCaseIdToTempStopQty_MAP.containsKey(subVenPub.Subscription_Vendor__c)){
                SatTS = integer.valueOf(subIdToCaseIdToTempStopQty_MAP.get(subVenPub.Subscription_Vendor__c).values()[0]);
            }
        }
        if (subVenPub.Sun__c <> null && subVenPub.Sun__c <> 0) {
            Sun+= integer.valueOf(subVenPub.Sun__c);
            if(subIdToCaseIdToTempStopQty_MAP.containsKey(subVenPub.Subscription_Vendor__c)){
                SunTS = integer.valueOf(subIdToCaseIdToTempStopQty_MAP.get(subVenPub.Subscription_Vendor__c).values()[0]);
            }
        }
        if (subVenPub.PHd__c <> null && subVenPub.PHd__c <> 0) {
            PHd += integer.valueOf(subVenPub.PHd__c);
            if(subIdToCaseIdToTempStopQty_MAP.containsKey(subVenPub.Subscription_Vendor__c)){
                PHdTS = integer.valueOf(subIdToCaseIdToTempStopQty_MAP.get(subVenPub.Subscription_Vendor__c).values()[0]);
            }
        }
        if (subVenPub.PHe__c <> null && subVenPub.PHe__c <> 0) {
            PHe += integer.valueOf(subVenPub.Phe__c);
            if(subIdToCaseIdToTempStopQty_MAP.containsKey(subVenPub.Subscription_Vendor__c)){
                PHeTS = integer.valueOf(subIdToCaseIdToTempStopQty_MAP.get(subVenPub.Subscription_Vendor__c).values()[0]);
            }
        }
        //END D-3727 16-Oct-2015 Added by S.Puli
      }
     
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
    
        //START D-2913 05/18/2015 Jason A./Sherwin P.
    //START: D-3140 20/06/2015 Added by S.Puli
    //Start UD-2016 VPernicia
    public void constructMail (Boolean isSendEmail, Map<Id, List<String>> caseToAddressVendorMapParam, String transactionNameParam, 
                                                               List<String> toAddressesParam, Case caseObjectParam, Subscription_Vendor__c subscriptionParam,
                                                               Map<Id, String> conId_AliasMapParam, String issueDateParam, String subParam, Address__c addressObjParam,
                                                               Singpost_Address__c singpostAddressObjParam, String classificationParam, Map<Id, id> conId_NameMapParam, String sessionId, Map<Id, List<String>> coaCaseToNewMobile_MAPParam, Map<Id, Set<Id>> coaCaseToTaskContact_MAPParam, Map<Id, Id> coaCaseToTaskUser_MAPParam, Map<Id, List<String>> tempRestartToNewEmailAddParam, Map<Id, List<String>> tempRestartToNewMobileParam, Map<Id, Set<Id>> tempRestartToContactSet_MAPParam, Map<Id, Id> tempRestartToUserId_MAPParam, Map<Id, String> tempRestartToAlias_MAPParam, Map<Id, String> coaCaseToAlias_MAPParam, Map<Id, Set<String>> coaCaseToOldMobileParam) // START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
    {
    //END: D-3140 20/06/2015 Added by S.Puli
        //START: D-3140 20/06/2015 Added by S.Puli
        //START D-3727 16-Oct-2015 Added by S.Puli
        string mapKey = '';
        if(caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObjectParam.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObjectParam.COA__c){
            String restartKey = '';
            restartKey = GlobalVariableClass.START_NEW;
            mapKey = string.valueOf(addressObjParam.id) + string.valueOf(subscriptionParam.vendor__c) + restartKey;
        }
        else{
            mapKey = string.valueOf(addressObjParam.id) + string.valueOf(subscriptionParam.vendor__c) + transactionNameParam;
        }
        //END D-3727 16-Oct-2015 Added by S.Puli
        MailSMSWrapper MWrapper = new MailSMSWrapper();
        
        //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();       
        MWrapper.mailisSendEmail = isSendEmail;
        MWrapper.mailtoAddress = new list<string>();
        if(transactionNameParam == GlobalVariableClass.COA_START){
            MWrapper.mailtoAddress = caseToAddressVendorMapParam.get(caseObjectParam.Id);
            //mail.setToAddresses(caseToAddressVendorMapParam.get(caseObjectParam.Id)); 
        } 
        else if(caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObjectParam.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObjectParam.COA__c){
            //START UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
            if(tempRestartToNewEmailAddParam.containsKey(caseObjectParam.Id)){
                MWrapper.mailtoAddress = tempRestartToNewEmailAddParam.get(caseObjectParam.Id);
                //mail.setToAddresses(tempRestartToNewEmailAddParam.get(caseObjectParam.Id)); 
            }else{
                MWrapper.mailtoAddress = toAddressesParam;
            }
            //END UD-3158 06-Dec-2015 Added By S.Puli - fix error in coa temp stop combo
        }
        else {
            MWrapper.mailtoAddress = toAddressesParam;
            //mail.setToAddresses(toAddressesParam);
        }
        //END: D-3140 20/06/2015 Added by S.Puli
        //End D-2913 05/18/2015 Jason A./Sherwin P.
        //mail.setSubject('Case:'+caseObjectParam.CaseNumber+' Subscription:'+subscriptionParam.Name);

        
        String output = '';
        String plainTextOutput = ''; // START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
        String smsoutput = ''; //Start-End: D-2532 4/16/2015 MGaelo smsoutput
    //START D-3009 05/22/2015 Jason A./Sherwin P.
        //START: D-3140 20/06/2015 Added by S.Puli
        if (!mapConcatenated.containsKey(mapKey)) {
        //START UD-3170 05-Nov-2015 Added by S.Puli
            if(transactionNameParam == GlobalVariableClass.COA_START && coaCaseToAlias_MAPParam.containskey(caseObjectParam.Id)) {
                output += coaCaseToAlias_MAPParam.get(caseObjectParam.Id)+' ';
                smsoutput += coaCaseToAlias_MAPParam.get(caseObjectParam.Id)+' '; //Start-End: D-2532 4/16/2015 MGaelo smsoutput
                plainTextOutput += coaCaseToAlias_MAPParam.get(caseObjectParam.Id)+' '; // START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
                //END: D-3140 20/06/2015 Added by S.Puli
            }
        //END D-3009 05/22/2015 Jason A./Sherwin P.
            //START: D-3140 20/06/2015 Added by S.Puli
            if(caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObjectParam.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObjectParam.COA__c){
                if(tempRestartToAlias_MAPParam.containsKey(caseObjectParam.Id)){
                    output += tempRestartToAlias_MAPParam.get(caseObjectParam.Id)+' ';
                    smsoutput += tempRestartToAlias_MAPParam.get(caseObjectParam.Id)+' ';
                    plainTextOutput += tempRestartToAlias_MAPParam.get(caseObjectParam.Id)+' ';
                }
            }
            else if(transactionNameParam <> GlobalVariableClass.COA_START && subscriptionParam.Vendor__c != null && conId_AliasMapParam.get(subscriptionParam.Id) <> null || (caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObjectParam.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObjectParam.COA__c == false)) {
                output += conId_AliasMapParam.get(subscriptionParam.Id)+' ';
                smsoutput += conId_AliasMapParam.get(subscriptionParam.Id)+' '; //Start-End: D-2532 4/16/2015 MGaelo smsoutput
                plainTextOutput += conId_AliasMapParam.get(subscriptionParam.Id)+' '; // START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
            }
            //END: D-3140 20/06/2015 Added by S.Puli
            //END UD-3170 05-Nov-2015 Added by S.Puli                                 
            if(issueDateParam != null) {
                issueDateParam.replace(' 00:00:00',''); 
                output += issueDateParam+' ';
                smsoutput += issueDateParam+' ';//Start-End: D-2532 4/16/2015 MGaelo smsoutput
                plainTextOutput += issueDateParam+' '; // START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
            }
                                
            //START D-3727 16-Oct-2015 Added by S.Puli
            if(caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObjectParam.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObjectParam.COA__c == true){
                String newTransNameRestart = '';
                newTransNameRestart = GlobalVariableClass.START_NEW;
                
                output += '- ' + newTransNameRestart +'&nbsp;'+'</br>';
                smsoutput += '- ' + newTransNameRestart + ' ';
                plainTextOutput += '- ' + newTransNameRestart + ' '; 
            }
            else if (transactionNameParam != null && transactionNameParam != 'null') {
                //START: D-3140 20/06/2015 Added by S.Puli
                output += '- ' + transactionNameParam +'&nbsp;'+'</br>';
                //END: D-3140 20/06/2015 Added by S.Puli
                smsoutput += '- ' + transactionNameParam + ' '; //Start-End: D-2532 4/16/2015 MGaelo smsoutput
                plainTextOutput += '- ' + transactionNameParam + ' '; // START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
            }
            //END D-3727 16-Oct-2015 Added by S.Puli
        }

        if (subParam != null && subParam != 'null') {
            output += subParam ;
            smsoutput += subParam; //Start-End: D-2532 4/16/2015 MGaelo smsoutput
            plainTextOutput += subParam;// START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
        }
        
        if (mapConcatenated.containsKey(mapKey)) {
            // For Email
            String mapKeyValue = mapConcatenated.get(mapKey).mailBody;
            mapKeyValue = mapKeyValue + ', ' + output;
            MWrapper.mailBody = mapKeyValue;

            // For SMS
            String mapKeyValue2 = mapConcatenated.get(mapKey).SMSmessage;
            smsoutput = mapKeyValue2 + ', ' + smsoutput;
            
            // For Task
            String mapKeyValue3 = mapConcatenated.get(mapKey).Description;
            plainTextOutput = mapKeyValue3 + ', ' + plainTextOutput;
        } else {
            // For Email
            MWrapper.mailBody = output;
        }
        
        String output2 = '</br> @';
        String plainTextOutput2 = ' @';
        String smsoutput2 = ' @';
                        
        if (addressObjParam.Block_House_Number__c != null) {
            output2 += string.valueOf(addressObjParam.Block_House_Number__c)+' ';
            smsoutput2 += string.valueOf(addressObjParam.Block_House_Number__c)+' '; //Start-End: D-2532 4/16/2015 MGaelo smsoutput
            plainTextOutput2 += string.valueOf(addressObjParam.Block_House_Number__c)+' ';// START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
        }

        if (addressObjParam.Street_Name__c != null) {
            output2 += addressObjParam.Street_Name__c+' ';
            smsoutput2 += addressObjParam.Street_Name__c+' '; //Start-End: D-2532 4/16/2015 MGaelo smsoutput
            plainTextOutput2 += addressObjParam.Street_Name__c+' ';// START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
        }


        if (addressObjParam.Building_Name__c != null) {
            output2 += addressObjParam.Building_Name__c+' ';
            smsoutput2 += addressObjParam.Building_Name__c+' ';//Start-End: D-2532 4/16/2015 MGaelo smsoutput
            plainTextOutput2 += addressObjParam.Building_Name__c+' ';// START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
        }

        if (addressObjParam.Level_Number__c != null) {
             output2 += '#'+string.valueOf(addressObjParam.Level_Number__c);
             smsoutput2 += '#'+string.valueOf(addressObjParam.Level_Number__c); //Start-End: D-2532 4/16/2015 MGaelo smsoutput
             plainTextOutput2 += '#'+string.valueOf(addressObjParam.Level_Number__c);// START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
        }

        if (addressObjParam.Unit_Number__c != null) {
            output2 += '-'+string.valueOf(addressObjParam.Unit_Number__c)+' ';
            smsoutput2 += '-'+string.valueOf(addressObjParam.Unit_Number__c)+' '; //Start-End: D-2532 4/16/2015 MGaelo smsoutput
            plainTextOutput2 += '-'+string.valueOf(addressObjParam.Unit_Number__c)+' ';// START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
        }
                     
        output2 += ' ' + classificationParam + ' ' ;      
        smsoutput2 += ' ' + classificationParam + ' ' ;      //Start-End: D-2532 4/16/2015 MGaelo smsoutput
        plainTextOutput2 += ' ' + classificationParam + ' ' ;// START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention                          
        
        
        String output3 = '';
        String smsoutput3 = '';
        String plainTextOutput3 = '';
        
        //START D-2492 03-12-2015 Marvin Gatchalian
        if (caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Start Sub') ) {
            if(!mailRemarks_Map.containsKey(caseObjectParam.Id)){
                mailRemarks_Map.put(caseObjectParam.Id, subscriptionParam.Id);
                if (subscriptionParam.Order_Number__r.Vendor_Sms_Remarks__c != null && subscriptionParam.Order_Number__r.Vendor_Sms_Remarks__c != '') {
                    output3 += ' ('+subscriptionParam.Order_Number__r.Vendor_Sms_Remarks__c+') ';
                    smsoutput3 += ' ('+subscriptionParam.Order_Number__r.Vendor_Sms_Remarks__c+') '; //Start-End: D-2532 4/16/2015 MGaelo smsoutput
                    plainTextOutput3 += ' ('+subscriptionParam.Order_Number__r.Vendor_Sms_Remarks__c+') ';// START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
                    setCaseId.add(caseObjectParam.id);
                }
            }
        }
        else if (caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop')) {
            if(!mailRemarks_Map.containsKey(caseObjectParam.Id)){
                mailRemarks_Map.put(caseObjectParam.Id, subscriptionParam.Id);
                if (caseObjectParam.Temp_Stop__r.Remarks__c != null && caseObjectParam.Temp_Stop__r.Remarks__c != '') {
                    output3 += ' (' + caseObjectParam.Temp_Stop__r.Remarks__c + ') ';
                    smsoutput3 += ' (' + caseObjectParam.Temp_Stop__r.Remarks__c + ') '; //Start-End: D-2532 4/16/2015 MGaelo smsoutput
                    plainTextOutput3 += ' (' + caseObjectParam.Temp_Stop__r.Remarks__c + ') ';// START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
                    setCaseId.add(caseObjectParam.id);
                }
            }
        }
        else if (caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Stop')) {
            if(!mapConcatenated.containsKey(mapKey)){
                if (caseObjectParam.Order_Number__r.Remarks__c != null && caseObjectParam.Order_Number__r.Remarks__c != '') {
                    output3 += ' (' + caseObjectParam.Order_Number__r.Remarks__c + ') ';
                    smsoutput3 += ' (' + caseObjectParam.Order_Number__r.Remarks__c + ') '; //Start-End: D-2532 4/16/2015 MGaelo smsoutput
                    plainTextOutput3 += ' (' + caseObjectParam.Order_Number__r.Remarks__c + ') ';// START/END 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
                    setCaseId.add(caseObjectParam.id);
                }
            }
        }
        //END D-2492 03-12-2015 Marvin Gatchalian
        //START D-2913 JasonA./Sherwin P. 05/21
        else if (caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Change in Address')) {
            if(!mapConcatenated.containsKey(mapKey)){
                if(!mailRemarks_Map.containsKey(caseObjectParam.Id)){
                    mailRemarks_Map.put(caseObjectParam.Id, subscriptionParam.Id);
                    if (caseObjectParam.Remarks__c != null && caseObjectParam.Remarks__c != '') {
                        output3 += ' (' + caseObjectParam.Remarks__c + ') ';
                        smsoutput3 += ' (' + caseObjectParam.Remarks__c + ') '; 
                        plainTextOutput3 += ' (' + caseObjectParam.Remarks__c + ') ';
                        setCaseId.add(caseObjectParam.id);
                    }
                }
                else if(mailRemarks_Map.containsKey(caseObjectParam.Id)){
                    if(mailRemarks_Map.get(caseObjectParam.Id) == subscriptionParam.Id){
                        if(transactionNameParam == GlobalVariableClass.COA_START){
                            if (caseObjectParam.Remarks__c != null && caseObjectParam.Remarks__c != '') {
                                output3 += ' (' + caseObjectParam.Remarks__c + ') ';
                                smsoutput3 += ' (' + caseObjectParam.Remarks__c + ') '; 
                                plainTextOutput3 += ' (' + caseObjectParam.Remarks__c + ') ';
                                setCaseId.add(caseObjectParam.id);
                            }
                        }
                    }       
                }
            }
        }
        //END D-2913 JasonA./Sherwin P. 05/21
        
        if (mapConcatenated.containsKey(mapKey)) {
            
            // For Email
            String mapKeyValue = mapConcatenated.get(mapKey).mailBodyRemarks;
            
            if (mapKeyValue == null || mapKeyValue == '') {
                mapKeyValue = output3; 
            } else if (output3 != null && output3 != '') {
                mapKeyValue = mapKeyValue + ', ' + output3;
            } 
            MWrapper.mailBodyRemarks = mapKeyValue;
            
            // For SMS
            String mapKeyValue2 = mapConcatenated.get(mapKey).SMSRemarks;
            
            if (mapKeyValue2 == null || mapKeyValue2 == '') {
                mapKeyValue2 = smsoutput3; 
            } else if (smsoutput3 != null && smsoutput3 != '') {
                mapKeyValue2 = mapKeyValue2 + ', ' + smsoutput3;
            } 
            MWrapper.SMSRemarks = mapKeyValue2;
            
            // For Task
            String mapKeyValue3 = mapConcatenated.get(mapKey).DescriptionRemarks;
            
            if (mapKeyValue3 == null || mapKeyValue3 == '') {
                mapKeyValue3 = plainTextOutput3; 
            } else if (plainTextOutput3 != null && plainTextOutput3 != '') {
                mapKeyValue3 = mapKeyValue3 + ', ' + plainTextOutput3;
            } 
            MWrapper.DescriptionRemarks = mapKeyValue3;
            
        } else {
            // For Email
            MWrapper.mailBodyRemarks = output3;
            // For SMS
            MWrapper.SMSRemarks = smsoutput3;
            // For Task
            MWrapper.DescriptionRemarks = plainTextOutput3;
        }
        
        MWrapper.mailBodyAddress = output2;
        MWrapper.SMSmessage2 = smsoutput2;
        MWrapper.Description2 = plainTextOutput2;
        
        
        MWrapper.SMSMobile = new list<string>();
        //Start D-2532 4/16/2015 MGaelo
        //START: D-3140 20/06/2015 Added by S.Puli
        if(transactionNameParam == GlobalVariableClass.COA_START){
            if(coaCaseToNewMobile_MAPParam.containsKey(caseObjectParam.Id)){
                for(String venNum : coaCaseToNewMobile_MAPParam.get(caseObjectParam.Id)){
                    //bound = new SMS_Outbound__c();
                    //MWrapper.SMSstatus = 'New';
                    MWrapper.SMSmessage = smsoutput;
                    MWrapper.SMSMobile.add(venNum);
                    //smsOutboundList.add(bound);
                }
            }
        }
        else if(caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObjectParam.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObjectParam.COA__c){
            if(tempRestartToNewMobileParam.containsKey(caseObjectParam.Id)){
                for(String venNum : tempRestartToNewMobileParam.get(caseObjectParam.Id)){
                    //bound = new SMS_Outbound__c();
                    //MWrapper.SMSstatus = 'New';
                    MWrapper.SMSmessage = smsoutput;
                    MWrapper.SMSMobile.add(venNum);
                    //smsOutboundList.add(bound);
                }
            }
        }else if(transactionNameParam == GlobalVariableClass.COA_STOP){
            if(coaCaseToOldMobileParam.containsKey(caseObjectParam.Id)){
                for(String venNum : coaCaseToOldMobileParam.get(caseObjectParam.Id)){
                    //bound = new SMS_Outbound__c();
                    //MWrapper.SMSstatus = 'New';
                    MWrapper.SMSmessage = smsoutput;
                    MWrapper.SMSMobile.add(venNum);
                    //smsOutboundList.add(bound);
                }
            }
        }
        else{
            for(String venStaffMobNum : venStaffMobileNumberList){
                if(venStaffMobNum != null){
                    //bound = new SMS_Outbound__c();
                    //MWrapper.SMSstatus = 'New';
                    MWrapper.SMSmessage = smsoutput;
                    MWrapper.SMSMobile.add(venStaffMobNum);
                    //smsOutboundList.add(bound);
                }           
            }
        }
        //END: D-3140 20/06/2015 Added by S.Puli
        //Start UD-0982 4/16/2015 MGaelo Added condition for VendorCommunicationPreference
        //START: D-3140 20/06/2015 Added by S.Puli
        if(transactionNameParam <> GlobalVariableClass.COA_START){
            if(caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObjectParam.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObjectParam.COA__c){
                //do nothing
            }
            else if(transactionNameParam == GlobalVariableClass.COA_STOP){
                //do nothing
            }
            else{
                if((subscriptionParam.Vendor__r.Vendor_Communication_Preference__c == 'Both' || subscriptionParam.Vendor__r.Vendor_Communication_Preference__c == 'SMS') && subscriptionParam.Vendor__r.Active__c){   
                    if(venMobileNumber != null){
                        //bound = new SMS_Outbound__c();
                        //MWrapper.SMSstatus = 'New';
                        MWrapper.SMSmessage = smsoutput;
                        MWrapper.SMSMobile.add(venMobileNumber);
                        //smsOutboundList.add(bound);
                    }
                }
            }
        }
        //END: D-3140 20/06/2015 Added by S.Puli
        //END UD-0982 4/16/2015 MGaelo Added condition for VendorCommunicationPreference
        
            //End D-2532 4/16/2015 MGaelo
    
        MWrapper.WhoId = new list<id>();
    
        // START 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
        //START: D-3140 20/06/2015 Added by S.Puli
        if(transactionNameParam == GlobalVariableClass.COA_START){
            if(coaCaseToTaskContact_MAPParam.containsKey(caseObjectParam.Id)){
                for(Id venStaff : coaCaseToTaskContact_MAPParam.get(caseObjectParam.Id)){
                // START : UD-0982 5/12/2015 MGaelo
                        if(coaCaseToTaskUser_MAPParam.containsKey(caseObjectParam.Id)){
                            //task = new task();
                            MWrapper.OwnerId = coaCaseToTaskUser_MAPParam.get(caseObjectParam.Id);
                            MWrapper.WhatId = caseObjectParam.Id;
                            MWrapper.WhoId.add(venStaff);
                            MWrapper.Description = plainTextOutput;
                            //MWrapper.ActivityDate = Date.today();
                            MWrapper.subject = 'Notification (' + caseObjectParam.RecordType.Name + ')';
                            //MWrapper.Status = 'Open';
                            //taskList.add(task);
                            
                            CaseTeamMember member = new CaseTeamMember();
                            member.ParentId = caseObjectParam.Id;
                            member.MemberId = coaCaseToTaskUser_MAPParam.get(caseObjectParam.Id);
                            member.TeamRoleId = vendorRepRoleId;                
                            caseTeamList.add(member);
                        }
                // END : UD-0982 5/12/2015 MGaelo
                    
                }
            }
        }
        else if(caseObjectParam.RecordTypeId == ConstantsSLB.getKeyId('Case_Temp Stop') && caseObjectParam.Temp_Stop__r.Restart_Date__c == Date.today()+1 && caseObjectParam.COA__c){
            if(tempRestartToContactSet_MAPParam.containsKey(caseObjectParam.Id)){
                for(Id venStaff : tempRestartToContactSet_MAPParam.get(caseObjectParam.Id)){
                // START : UD-0982 5/12/2015 MGaelo
                        if(tempRestartToUserId_MAPParam.containsKey(caseObjectParam.Id)){
                            //task = new task();
                            MWrapper.OwnerId = tempRestartToUserId_MAPParam.get(caseObjectParam.Id);
                            MWrapper.WhatId = caseObjectParam.Id;
                            MWrapper.WhoId.add(venStaff);
                            MWrapper.Description = plainTextOutput;
                            //MWrapper.ActivityDate = Date.today();
                            MWrapper.subject = 'Notification (' + caseObjectParam.RecordType.Name + ')';
                            //MWrapper.Status = 'Open';
                            //taskList.add(task);
                            
                            CaseTeamMember member = new CaseTeamMember();
                            member.ParentId = caseObjectParam.Id;
                            member.MemberId = tempRestartToUserId_MAPParam.get(caseObjectParam.Id);
                            member.TeamRoleId = vendorRepRoleId;                
                            caseTeamList.add(member);
                        }
                // END : UD-0982 5/12/2015 MGaelo
                    
                }
            }
        }
        else{
            for(String venStaff : venStaffid){
                if(conId_NameMapParam.get(subscriptionParam.Vendor__c) != NULL) {
            // START : UD-0982 5/12/2015 MGaelo
                    if(vendorStaffId_partnerUser.containsKey(venStaff)){
                        //task = new task();
                        MWrapper.OwnerId = vendorStaffId_partnerUser.get(venStaff).Id;
                        MWrapper.WhatId = caseObjectParam.Id;
                        MWrapper.WhoId.add(venStaff);
                        MWrapper.Description = plainTextOutput;
                        //MWrapper.ActivityDate = Date.today();
                        MWrapper.subject = 'Notification (' + caseObjectParam.RecordType.Name + ')';
                        //MWrapper.Status = 'Open';
                        //taskList.add(task);
                        
                        CaseTeamMember member = new CaseTeamMember();
                        member.ParentId = caseObjectParam.Id;
                        member.MemberId = vendorStaffId_partnerUser.get(venStaff).Id;
                        member.TeamRoleId = vendorRepRoleId;                
                        caseTeamList.add(member);
                    }
            // END : UD-0982 5/12/2015 MGaelo
                }
            }
        }
        //END: D-3140 20/06/2015 Added by S.Puli
        // END 03/23/2015 MD-16 Kevin Evasco - Vendor Task Assignment
        
        mapConcatenated.put(mapKey, MWrapper);
        // START 03/23/2015 MD-16 FOR REMOVAL
        /*
        // START 03/23/2015 MD-16 Kevin Evasco - Push Notification using Chatter's @mention
        if(conId_NameMapParam.get(subscriptionParam.Vendor__c) != null) {
            ChatterUtility.addMentionComment(caseObjectParam.Id, conId_NameMapParam.get(subscriptionParam.Vendor__c),plainTextOutput, sessionId);
        }*/
        // END 03/23/2015 MD-16 FOR REMOVAL
        
        //mail.setHtmlBody(output); Von

        //return mail; Von
    }
    //End UD-2016 VPernicia
    
    
    
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
    //START UD-2016 VPernicia 07/27/15
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<SMS_Outbound__c> smsOutboundList = new List<SMS_Outbound__c>();
        List<Task> taskList = new List<Task>();
        for (string keySets: mapConcatenated.keyset()) {
            
            string strMailBody = '';
            string strSMSBody = '';
            string strTaskBody = '';
            
            if (mapConcatenated.get(keySets).mailisSendEmail) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setSubject(GlobalVariableClass.EMAIL_DELIVERY_NOTIFICATION);
                mail.setToAddresses(mapConcatenated.get(keySets).mailtoAddress);
                
                strMailBody = mapConcatenated.get(keySets).mailBody + mapConcatenated.get(keySets).mailBodyAddress + mapConcatenated.get(keySets).mailBodyRemarks;
                                
                mail.setHtmlBody(strMailBody);
            
                mailList.add(mail);
            }
            
            for (integer x=0; x<mapConcatenated.get(keySets).SMSMobile.size(); x++) {
                bound = new SMS_Outbound__c();
                bound.SMS_status__c = 'New';
                bound.SMS_message__c = mapConcatenated.get(keySets).SMSmessage + mapConcatenated.get(keySets).SMSmessage2 + mapConcatenated.get(keySets).SMSRemarks;
                bound.Mobile__c = mapConcatenated.get(keySets).SMSMobile[x];
                smsOutboundList.add(bound);
            }
            
            for (integer x=0; x<mapConcatenated.get(keySets).WhoId.size(); x++) {
                task = new task();
                task.OwnerId = mapConcatenated.get(keySets).OwnerId;
                //task.WhatId = mapConcatenated.get(keySets).WhatId;
                task.WhoId = mapConcatenated.get(keySets).WhoId[x];
                task.Description = mapConcatenated.get(keySets).Description + mapConcatenated.get(keySets).Description2 + mapConcatenated.get(keySets).DescriptionRemarks;
                task.ActivityDate = Date.today();
                task.subject = mapConcatenated.get(keySets).subject;
                task.Status = 'Open';
                taskList.add(task);
            }
        }
        //Start UD-3457 26-Jan-2016 Added By S.Puli 
        //Messaging.sendEmail(mailList, false);
        boolean isError = false;
        Logger logger = new Logger(SP_VendorSubscriptionNotificationsBatch.class.getName(), 'SP044', BC.getJobID());
        Messaging.SendEmailResult[] mailResult = Messaging.sendEmail(mailList, false);
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
        
        //insert smsOutboundList;
        Database.SaveResult[] smsResult = Database.insert(smsOutboundList, false);
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
        
        //insert taskList;
        Database.SaveResult[] taskResult = Database.insert(taskList, false);
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
    //END UD-2016 VPernicia 07/27/15
    }
    //START UD-2016 VPernicia 07/27/15
    global class MailSMSWrapper {
        global string mailBody;
        global string mailBodyAddress;
        global string mailBodyRemarks;
        global list<string> mailtoAddress;
        global boolean mailisSendEmail;
        
        global string SMSmessage;
        global string SMSmessage2;
        global string SMSRemarks;
        global list<string> SMSMobile;
        
        global id OwnerId;
        global id WhatId;
        global list<id> WhoId;
        global string Description;
        global string Description2;
        global string DescriptionRemarks;
        global string subject;      
    }
    //END UD-2016 VPernicia 07/27/15
}
//END D-2212