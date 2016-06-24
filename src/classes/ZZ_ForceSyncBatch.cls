global class ZZ_ForceSyncBatch implements Database.Batchable<sObject>  {    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {     
        return Database.getQueryLocator('Select ID, Name from Grace_Period__c');
    }
    
    global void execute(Database.BatchableContext BC, List<Grace_Period__c> lstRecords) {
        Set<String> setBillingAccountId = new Set<String> ();
        for(Grace_Period__c item: lstRecords)
            setBillingAccountId.add(item.Name);
            
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
        syncManager.syncZuoraObjectIdSet  = setBillingAccountId;
        syncManager.emailNotificationEnabled = false;
        
        List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
    }        
               
    global void finish(Database.BatchableContext BC) {
    }
}