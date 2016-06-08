/** 
 * Class Name: SP_SendEscalationEmailScheduler
 * @author: Sherwin Puli
 * Date: March 28, 2015
 * Requirement/Project Name: CRSM Project
 * @description Schedulable Batch for Escalated Complaint Cases 
 * 
 */
global class SP_SendEscalationEmailScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        SP_SendEscalationEmailBatch spEscalate = new SP_SendEscalationEmailBatch(); 
        database.executebatch(spEscalate);
    }
}