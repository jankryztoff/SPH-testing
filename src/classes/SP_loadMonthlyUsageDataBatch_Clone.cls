/**
     * Class Name: SP_loadMonthlyUsageDataBatch
     * @author: Crisanto de Llamas
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Batch Apex Class to Create monthly Usage data to be send to Zuora
     * History : 02/04/2015 D-1614, D-1622, JohnD Totally refactor the class.
     * History : 20Apr15 D-2782 added missed out code block for email notification
     */

global class SP_loadMonthlyUsageDataBatch_Clone implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {    

  global Database.queryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator([select Id from Usage__c where Status__c = 'New']);
  }
  
  global void execute(Database.BatchableContext bc, list<Usage__c> usageList) {
    
    set<id> usageIdSet = new set<id>();
    for (Usage__c usage : usageList) {
      usageIdSet.add(usage.Id);
    }
    
        UsageHelper.sentToZuoraCalloutNonFuture(usageIdSet); //START/END 04/01/2015 D-2686 Kevin Evasco - Only non future methods can be called in batchable's execute method
  }
  
  global void finish(Database.BatchableContext bc) {
      // Start D-2782 20Apr15 JohnD added missed code logic during D-1622
      string failedRec;
        for (Usage__c usage : [select Id from Usage__c where Send_to_Zuora_Time__c = today 
            and Status__c = :GlobalVariableClass.ZUORA_FAILED]) {
              
          if (failedRec == null) {
            failedRec = usage.Id;
          } else {
            failedRec += ', ' + usage.Id;
          }
        }
        
        if (failedRec != null) {
          
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          String[] toAddresses = new String[] {ConstantsSLB.getEmail('Usage Email')};
          mail.setToAddresses(toAddresses);
          mail.setSubject(GlobalVariableClass.FAILED_USAGE_TO_ZUORA);
          mail.setPlainTextBody
          (GlobalVariableClass.FAILED_USAGE_RECORDS_TO_ZUORA + failedRec);
          Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          system.debug('JohnD ::: ' + emailResult);
          
        }
      // End D-2782 20Apr15 JohnD added missed code logic during D-1622
    BatchJobHelper.updateJobStatus(BC.getJobId());
  }  

}