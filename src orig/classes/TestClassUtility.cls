/*
Utility class for running test class. DO NOT deploy to Production
*/

public class TestClassUtility {
    // Enqueue all classes ending in "Test". 
    public static void enqueueTests(string testClassNames) {
		
		set<string> testClassNameSet = new set<string>();
		string testClassNameRefined = testClassNames.replace(' ','');
		id jobId;
		
		
		for (string className : testClassNameRefined.split(',')) {
			testClassNameSet.add(className);
		}
		
		ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
        for (ApexClass tcls : [SELECT Id FROM ApexClass  WHERE Name in :testClassNameSet]) {
        	queueItems.add(new ApexTestQueueItem(ApexClassId = tcls.Id));
        }
        
        if (!queueItems.isEmpty()) {
        	insert queueItems;
        }
        
        // Get the job ID of the first queue item returned.
        ApexTestQueueItem item = [select ParentJobId from ApexTestQueueItem where Id=:queueItems[0].Id LIMIT 1];
        list<ApexTestQueueItem> itemList = [select id from ApexTestQueueItem where ParentJobId = :item.ParentJobId];
  
  		system.debug('JobId : ' + item.ParentJobId);
  		system.debug('Total Test Classes Queued : ' + itemList.size());
    }

    // Get the status and pass rate for each class
    // whose tests were run by the job.
    // that correspond to the specified job ID.
    public static void checkClassStatus(ID jobId) {
        ApexTestQueueItem[] items = 
           [SELECT ApexClass.Name, Status, ExtendedStatus 
            FROM ApexTestQueueItem 
            WHERE ParentJobId=:jobId];
        for (ApexTestQueueItem item : items) {
            String extStatus = item.extendedstatus == null ? '' : item.extendedStatus;
            System.debug(item.ApexClass.Name + ': ' + item.Status + extStatus);
        }
    }

    // Get the result for each test method that was executed.
    public static void checkMethodStatus(ID jobId) {
        ApexTestResult[] results = 
           [SELECT Outcome, ApexClass.Name, MethodName, Message, StackTrace 
            FROM ApexTestResult 
            WHERE AsyncApexJobId=:jobId];
        for (ApexTestResult atr : results) {
            System.debug(atr.ApexClass.Name + '.' + atr.MethodName + ': ' + atr.Outcome);
            if (atr.message != null) {
                System.debug(atr.Message + '\n at ' + atr.StackTrace);
            }
        }
    }   
}