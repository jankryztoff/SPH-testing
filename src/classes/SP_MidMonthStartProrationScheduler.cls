/**
 * Class Name: SP_MidMonthStartProrationScheduler
 * @author: Karl Tan
 * Date: 
 * Requirement/Project Name: CRSM Project
 * @description Schedulable Batch for Mid- Month Start Proration 
 * 
 */
global class SP_MidMonthStartProrationScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        SP_MidMonthStartProrationBatch bP = new SP_MidMonthStartProrationBatch(); 
        database.executebatch(bP);
    }
}