global class SP_PopConsolidationScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        SP_PopConsolidationBatch bP = new SP_PopConsolidationBatch(); 
        database.executebatch(bP);
    }
}