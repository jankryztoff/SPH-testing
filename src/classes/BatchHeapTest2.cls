global class BatchHeapTest2 implements Database.Batchable<sObject> {

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('SELECT ID FROM Singpost_Address__c LIMIT 1');
   }

   global void execute(Database.BatchableContext BC, List<Singpost_Address__c> scope){
    }

   global void finish(Database.BatchableContext BC)
   {
       String jobID;
         BatchHeapTest batchJob = new BatchHeapTest();
         jobID = Database.executeBatch(batchJob);
         
        System.debug('============>' + jobID); 
                  BatchHeapTest batchJob3 = new BatchHeapTest();
         jobID = Database.executeBatch(batchJob3);
         
         System.debug('============>' + jobID);
   } 
   }