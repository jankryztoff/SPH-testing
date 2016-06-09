/**
 * Class Name: BatchAddressAssignmentCreateScheduler 
 * @author: Jb Domingo
 * Date: 9/5/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Scheduler for BatchAddressAssignmentCreate Class
 *
 */
global class BatchAddressAssignmentCreateScheduler implements Schedulable{
    /* @description Executes BatchAddressAssignmentCreate batch
     * 
     * @param SchedulableContext - object to keep track of the scheduled job once it's scheduled
     * @return void
     */
    global void execute(SchedulableContext sc) {

         BatchAddressAssignmentCreate batchAddAssignCreateObj = new BatchAddressAssignmentCreate();
         Database.executeBatch(batchAddAssignCreateObj);             
    }
}