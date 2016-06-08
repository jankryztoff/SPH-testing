public class TestQueueable2 implements Queueable {
    public void execute(QueueableContext context) {
        Id jobID = System.enqueueJob(new TestQueueable());
        system.debug('==========>jobID' + ' ' + jobID); 
        system.debug('==========> Execute Queueable2....'); 
    }
}