global class RenewalOfSub_RetentionBatchScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        RenewalOfSub_RetentionOutboundBatch RRO = new RenewalOfSub_RetentionOutboundBatch(); 
        database.executebatch(RRO);
    }
}