/*
 * Class Name: ZuoraOnDemandSyncBatch
 * @author: Kevin H. Evasco
 * Date: 10/16/2014
 * Project/Requirement: SPH Integration
 * @description This class performs zuora on demand sync through apex batchable.
 * 
 * History: 09/12/2014 Kevin Evasco Created Apex Batchable
 */


global class ZuoraOnDemandSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    //START D-4085 Gdelrosario : Removed new instantiation for zAccountIdSet
    //START D-4076 Gdelrosario : added new instantiation for zAccountIdSet
    global final Set<String> zAccountIdSet;
    //END D-4076 Gdelrosario : added new instantiation for zAccountIdSet
    //END D-4085 Gdelrosario : Removed new instantiation for zAccountIdSet
    global final Id accountId;
    
    public ZuoraOnDemandSyncBatch(Set<String> zAccountIdSet, Id accountId)
    {
        this.zAccountIdSet = zAccountIdSet;
        this.accountId = accountId;
    }
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
        syncManager.syncZuoraObjectIdSet = this.zAccountIdSet; 
        List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
        System.debug('SYNC MANAGER::: ' + syncManager);
        System.debug('SYNC RESULT::: ' + syncResult);
        
        return Database.getQueryLocator('SELECT Id FROM Account WHERE Id = \'' +  accountId + '\'');
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {                       
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
    }
}