/**
     * Class Name: SP_loadMonthlyUsageDataBatch
     * @author: Crisanto de Llamas
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Batch Apex Class to Create monthly Usage data to be send to Zuora
     * History : 02/04/2015 D-1614, D-1622, JohnD Totally refactor the class.
     * History : 20Apr15 D-2782 added missed out code block for email notification
     */

global class SP_loadMonthlyUsageDataBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {    

    //START D-3495 09/30/2015 Added by J.Sarion - Batch recovery procedure
    Set<Id> usageIdSet = new Set<Id>();
    final static String STATUS_NEW = GlobalVariableClass.STATUS_NEW;
    final static String STOPTYPE_NONDELIVERY = GlobalVariableClass.NON_DELIVERY;
	final static String Closed = GlobalVariableClass.STATUS_CLOSED;//Start/End D-4452 04-Apr-2016 Added By S.Puli - do not exclude non delivery
    
    //START D-3495 LISEN 10/9/2015 - Enable on demand batch based on selective usages or accounts
  Boolean isApexJobSuccessful = true;
    Set<String> selectiveIds = null;
    Integer type;
    final Static Integer SELECTIVE_USAGES = 1;
    final Static Integer SELECTIVE_ACCOUNTS = 2;
    
    //Constructor for cancelling specific subscriptions or billing account numbers
    global SP_loadMonthlyUsageDataBatch(Set<String> selectiveIds, Integer type)
    {
        this.selectiveIds = selectiveIds;
        this.type = type;
    }
    //END D-3495 LISEN 10/9/2015 - Enable on demand batch based on selective usages or billing account numbers
    
    public SP_loadMonthlyUsageDataBatch(){
        
    }
    //END D-3495 09/30/2015 Added by J.Sarion - Batch recovery procedure

    global Database.queryLocator start(Database.BatchableContext bc) {
            //START UD-2878 24-Sept-2015 Added by S.Puli - Remove usages for non delivery
        //START D-3495 09/30/2015 Added by J.Sarion - Batch recovery procedure
        String query = 'SELECT Id, StopType__c, Case__r.Status '; //Start/End D-4452 04-Apr-2016 Added By S.Puli - do not exclude non delivery
        query       += 'FROM Usage__c WHERE ';
        
        //START D-3495 LISEN 10/9/2015 - Enable on demand batch based on selective usages or accounts
        //Start D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery
        //Start D-4452 04-Apr-2016 Added By S.Puli - do not exclude non delivery
		//Start D-4452 05-Apr-2016 Added By S.Puli
        if(selectiveIds != null && !selectiveIds.isEmpty()){
            if(type == SELECTIVE_USAGES){
                //START D-3495 10/16/2015 Added by C. Lin - Update Query
                query += ' Id =: selectiveIds AND Status__c = :STATUS_NEW AND (Case__r.RecordType.DeveloperName != \'Complaint_Newspaper\' OR Case__r.Status = :Closed)';
                //END D-3495 10/16/2015 Added by C. Lin
            }else if(type == SELECTIVE_ACCOUNTS){
                //START D-3495 10/16/2015 Added by C. Lin - Update Query
                query += ' Account_Id__c IN :selectiveIds AND Status__c = :STATUS_NEW AND (Case__r.RecordType.DeveloperName != \'Complaint_Newspaper\' OR Case__r.Status = :Closed)';
                //END D-3495 10/16/2015 Added by C. Lin
            }
        }
        else{
            query   += 'Status__c = :STATUS_NEW AND ( Case__r.RecordType.DeveloperName != \'Complaint_Newspaper\' OR Case__r.Status = :Closed)';
        }
		//End D-4452 05-Apr-2016 Added By S.Puli
        //End D-4452 04-Apr-2016 Added By S.Puli
		//End D-4452 02-Apr-2016 Added By S.Puli
        //END D-3495 LISEN 10/9/2015 - Enable on demand batch based on selective usages or accounts
        
        return Database.getQueryLocator(query);
        //END D-3495 09/30/2015 Added by J.Sarion - Batch recovery procedure
            //END UD-2878 24-Sept-2015 Added by S.Puli
    }
    
    global void execute(Database.BatchableContext bc, list<Usage__c> usageList) {
        //START D-3495 LISEN 10/9/2015 - Enable on demand batch based on selective usages or accounts for batch recovery
        //Start D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery
    Logger logger = new Logger(SP_loadMonthlyUsageDataBatch.class.getName(), 'SP008', BC.getJobID());
        try{
            set<id> usageIdSet = new set<id>();
            for (Usage__c usage : usageList) {
                usageIdSet.add(usage.Id);
            }
                if (!Test.isRunningTest())
                UsageHelper.sentToZuoraCalloutNonFuture(usageIdSet); //START/END 04/01/2015 D-2686 Kevin Evasco - Only non future methods can be called in batchable's execute method
            }catch(Exception e){    
                logger.logBatchFailure(e, usageList);
                logger.save();
            }
      isApexJobSuccessful = false;
        //End D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery
        //END D-3495 LISEN 10/9/2015 - Enable on demand batch based on selective usages or accounts for batch recovery
    }
    
    global void finish(Database.BatchableContext bc) {
        // Start D-2782 20Apr15 JohnD added missed code logic during D-1622
        string failedRec;
        string toAddress = ConstantsSLB.getEmail('Usage Email');//Start/End D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery 
        for (Usage__c usage : [select Id from Usage__c where Send_to_Zuora_Time__c = today 
                and Status__c = :GlobalVariableClass.ZUORA_FAILED]) {
                    
            if (failedRec == null) {
                failedRec = usage.Id;
            } else {
                failedRec += ', ' + usage.Id;
            }
        }
        
        //START: D-4198 1-7-2015 Added by Kristine Balaoing - reordered actions to avoid uncommitted work pending
        // End D-2782 20Apr15 JohnD added missed code logic during D-1622
    
    //START D-3495 LISEN 10/9/2015 - Enable on demand batch based on selective usages or accounts for batch recovery
        if(!isApexJobSuccessful){
          BatchJobHelper.updateJobStatus(BC.getJobId(), false); 
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
        //Start D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery 
        if(Test.isRunningTest()) {
            failedRec = 'testrec';
            toAddress = 'test@google.com';
        }
        
        if (failedRec != null) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {toAddress};
            mail.setSubject(GlobalVariableClass.FAILED_USAGE_TO_ZUORA);
            mail.setPlainTextBody
            (GlobalVariableClass.FAILED_USAGE_RECORDS_TO_ZUORA + failedRec);
            mail.setToAddresses(toAddresses);
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('JohnD ::: ' + emailResult);
            
        }
        //END: D-4198 1-7-2015 Added by Kristine Balaoing
        //End D-4452 02-Apr-2016 Added By S.Puli - do not exclude non delivery     
    //END D-3495 LISEN 10/9/2015 - Enable on demand batch based on selective usages or accounts for batch recovery
    }   

}