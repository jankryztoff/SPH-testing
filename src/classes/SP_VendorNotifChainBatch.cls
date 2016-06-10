/**
 * Class Name: SP_VendorNotifChainBatch 
 * @author: Sherwin Puli
 * Date: 08-June-2016
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Class that send email notifications for Migrated Subs (Start and Stop) and Normal Expiry Scenario
 */

 
global class SP_VendorNotifChainBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    
    list<exception> exceptionList = new list<exception>(); // declare this at the outermost within your class

   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param BC - predefined parameter 
    * @return list of objects from Order Object
    */ 
    
    public static SMS_Outbound__c bound;
    public static List<SMS_Outbound__c> smsOutboundList = new List<SMS_Outbound__c>();
    public static List<String> venStaffMobileNumberList = new List<String>();
    public static String venMobileNumber;
    public static Map<Id, String> subToOutputMAP = new Map<Id, String>();
    public static Map<Id, String> subToSmsOutputMAP = new Map<Id, String>();
    
    //Prepare the cutoff dates
    public Date dtEffStart = Date.today();        
    public Date dtEffEnd = dtEffStart.addDays(1);
    
    global final String sessionId;
    global static String vendorRepRoleId = Key_Id__c.getInstance('Vendor Rep Role').Id__c;
    
    public static List<Task> taskList = new List<Task>();
    public static List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
    public static Task task;
    public static Set<String> venStaffid = new Set<String>();   
    public static Map<Id, User> vendorStaffId_partnerUser = new Map<Id, User>();
    global Set<Id> selectiveIds = new Set<Id>();
    global Boolean isAdhoc = false;

    
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

    public Map<Id, Map<Id,boolean>> coaWithTempRestartTom = new Map<Id, Map<Id,boolean>>();
    public Map<Id, Map<Id,boolean>> coaInBetwnTStop = new Map<Id, Map<Id,boolean>>();

    public SP_VendorNotifChainBatch() {
        mailText_Map = new Map<String, mailTextWrapper>();
        mailRemarks_Map = new Map<Id, Id>();
    }
    
    
    public SP_VendorNotifChainBatch(Set<Id> sublist){
        mailText_Map = new Map<String, mailTextWrapper>();
        mailRemarks_Map = new Map<Id, Id>();
        this.selectiveIds = sublist;
        this.isAdhoc = true;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String publication = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        //Prepare the cutoff dates
        String query = '';
        query = 'SELECT Id, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Term_Length__c, Subscription_Type__c ';
        query += ' FROM ';
        query += '      Zuora__Subscription__c ';
        query += ' WHERE ';
        query += ' (( Zuora__SubscriptionStartDate__c = :dtEffEnd AND (Zuora__SubscriptionEndDate__c >= :dtEffEnd OR Zuora__SubscriptionEndDate__c = null))';
        query += ' OR';
        query += ' ( Zuora__SubscriptionEndDate__c = :dtEffStart AND Zuora__SubscriptionStartDate__c <= :dtEffStart ))';
        query += ' AND Subscription_Type__c = :publication';
        
        //
        if (Test.isRunningTest()){
            query += ' Limit 200';
        }

       if(isAdhoc){
            query += ' AND Id IN :selectiveIds';
       }

        return Database.getQueryLocator(query);    
    }
    
    /* @description Executes the business logic.Sends email notification to Vendor and Vendor Staff based on scenarios
     * 
     * @param BC - predefined parameter 
     * @param scope - a list of sObjects from the initial database query
     * @return void
     */ 

    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> initialSubs) {       
    
        String START_SUBSCRIPTION = 'Start_Subscription';
        String CHANGE_OF_SUBSCRIPTION = 'Change_of_Subscription';
        String RENEWAL_OF_SUBSCRIPTION = 'Renewal_of_Subscription';
        String STOP_SUBSCRIPTION = 'Stop_Subscription';
        
        Set<Id> initialSubIds = new Set<Id>();
        Set<Id> subsToFilter = new Set<Id>();
        List<Zuora__Subscription__c> scope = new List<Zuora__Subscription__c>();
        
        if(initialSubs.size()>0){
            for(Zuora__Subscription__c sub : initialSubs){
                initialSubIds.add(sub.Id);
            }
        }
        List<Case_Subscription__c> caseSubsToFilter = new List<Case_Subscription__c>();
        if(!initialSubIds.isEmpty()){    
            caseSubsToFilter = [Select ID,Case__c,Subscription__c From Case_Subscription__c Where ((
            (Case__r.RecordType.DeveloperName = :START_SUBSCRIPTION 
            OR Case__r.RecordType.DeveloperName = :CHANGE_OF_SUBSCRIPTION) 
            //OR Case__r.RecordType.DeveloperName = :RENEWAL_OF_SUBSCRIPTION) 
            AND Subscription__r.Zuora__SubscriptionStartDate__c = :dtEffEnd) 
            OR (Case__r.RecordType.DeveloperName = :STOP_SUBSCRIPTION 
            AND Subscription__r.Zuora__SubscriptionEndDate__c = :dtEffStart)) 
            AND Subscription__c In :initialSubIds];

            if(!caseSubsToFilter.isEmpty()){
                
                for(Case_Subscription__c cs : caseSubsToFilter){
                    if(cs.Subscription__c <> null){
                        subsToFilter.add(cs.Subscription__c);
                    }
                }
            }
            for(Zuora__Subscription__c subRec : initialSubs){
                if(!subsToFilter.isEmpty()){
                    if(!subsToFilter.contains(subRec.Id)){
                        if(subRec.Zuora__SubscriptionStartDate__c == dtEffEnd){
                            scope.add(subRec);
                        }else if(subRec.Zuora__SubscriptionEndDate__c <> null){ 
                            if(subRec.Zuora__SubscriptionEndDate__c == dtEffStart 
                            && subRec.Zuora__SubscriptionStartDate__c.addMonths(integer.valueOf(subRec.Term_Length__c)).addDays(-1) == subRec.Zuora__SubscriptionEndDate__c){
                                scope.add(subRec);
                            }                           
                        }
                    }
                }else{
                    scope.add(subRec);
                }
            }
        }

        system.assertEquals(scope, null);
        system.assertEquals(1,2);
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
        
    }
    
}