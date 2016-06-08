public class BillingBatchAllocationQueueable implements Queueable, Database.AllowsCallouts {

    set<id> billingAccountIdSet = new set<id>();
    
    public BillingBatchAllocationQueueable(set<id> billingAccountIdSetParam) {
        this.billingAccountIdSet = billingAccountIdSetParam;
    }
    
    public void execute(QueueableContext context) {
    	BillingBatchAllocationHandler.allocateBatchNumber(billingAccountIdSet);
    }        
}