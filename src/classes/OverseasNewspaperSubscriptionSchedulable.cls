public class OverseasNewspaperSubscriptionSchedulable implements Schedulable {

    public void execute(SchedulableContext sc) {
        
        OverseasNewspaperSubscriptionBatchable onsb = new OverseasNewspaperSubscriptionBatchable();
        Database.executeBatch(onsb);
    }
}