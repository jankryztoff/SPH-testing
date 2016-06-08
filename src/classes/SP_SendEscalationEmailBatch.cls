/**
 * Class Name: SP_SendEscalationEmailBatch
 * @author: Sherwin Puli
 * Date: 03/26/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description: MD-62 Batch Class that send email notifications to Vendor and Vendor Staff for Escalated Cases every hour
 */
 
 global class SP_SendEscalationEmailBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
 
    global Batch_Configuration_Settings__c batchSettings;
    
    public static Set<Id> casId_SET = new Set<Id>();
    /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bc- predefined parameter 
    * @return list of objects from Subscription Object
    */     
   
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String complaintId = ConstantsSLB.getKeyId('Complaint_Newspaper');
        String query = 'SELECT Id, IsEscalated, Status, CreatedDate From Case Where Status != \'Closed\' AND IsEscalated = true ';
        query += 'AND RecordTypeId = \''+complaintId+'\'';
        if (Test.isRunningTest()){
            query += ' Limit 200';
        }
        return Database.getQueryLocator(query);
    }
 
     /* @description Executes the business logic and creates Usage object
     * 
     * @param bc- predefined parameter 
     * @param allScopes - a list of sObjects from the initial database query
     * @return void
     */    
    
    global void execute(Database.BatchableContext BC, List<Case> scope) {
    
        if(scope.size()>0 && scope<>null){
            for(Case c : scope){
                casId_SET.add(c.Id);                
            }
            try{
				EmailNotificationCreation.createEmailNotFuture(casId_SET);
			} catch (exception e){
			}
        }
    
    }
 
    global void finish(Database.BatchableContext BC) {
    
        SP_SendEscalationEmailScheduler sendEscalation = new SP_SendEscalationEmailScheduler();
        String sched = '0 0 * * * ?';
        String jobID = system.schedule('SP_SendEscalationEmailBatch', sched, sendEscalation);
    
    } 
 
}