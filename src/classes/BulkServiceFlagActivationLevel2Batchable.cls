public class BulkServiceFlagActivationLevel2Batchable implements Database.Batchable<SObject>, Database.Stateful {
    
    list<ServiceFlagActivationParamWrapper> paramList = new list<ServiceFlagActivationParamWrapper>();
    
    public BulkServiceFlagActivationLevel2Batchable(list<ServiceFlagActivationParamWrapper> paramListParam) {
        this.paramList = paramListParam;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([select id from Asia1__c limit 1]);
    }
    
    public void execute(Database.BatchableContext context, list<Asia1__c> scope) {
        System.enqueueJob(new BulkServiceFlagActivationLevel2Queueable(paramList));
    }
    
    public void finish(Database.BatchableContext context) {}
}