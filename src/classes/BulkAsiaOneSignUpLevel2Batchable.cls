public class BulkAsiaOneSignUpLevel2Batchable implements Database.Batchable<SObject> {
    
    set<id> asia1IdSet = new set<id>();
    
    public BulkAsiaOneSignUpLevel2Batchable(set<id> asia1IdSetParam) {
        this.asia1IdSet = asia1IdSetParam;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([select id from Asia1__c where Id in :asia1IdSet]);
    }
    
    public void execute(Database.BatchableContext context, list<Asia1__c> scope) {
        
        set<id> asia1IdSet2 = new set<id>();
        
        for (Asia1__c asia1 : scope) {
            asia1IdSet2.add(asia1.Id);
        }
        
        System.enqueueJob(new BulkAsiaOneSignUpLevel2Queueable(asia1IdSet2));
    }
    
    public void finish(Database.BatchableContext context) {
    }
}