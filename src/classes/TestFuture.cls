public class TestFuture {
    
    @future 
    public static void doFuture() {
    printLog();
        Id jobID = System.enqueueJob(new TestQueueable());
        system.debug('==========>jobID' + ' ' + jobID); 
    }
    
    public static void printLog()
    {
        system.debug('==========>Debug...'); 
    }
}