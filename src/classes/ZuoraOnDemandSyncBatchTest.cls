/**
   @Author Val Lu
   @name ZuoraOnDemandSyncBatchTest
   @CreateDate 02/26/2015
   @Description To test ZuoraOnDemandSyncBatch class
   @Version <1.0>
  */
@isTest (Seealldata = TRUE)
private class ZuoraOnDemandSyncBatchTest {
    /**
    *  To test ZuoraOnDemandSyncBatch class
    *  @name unitTest1
    *  @param none
    *  @return none
    *  @throws na
    */
    static testmethod void unitTest1(){
        Set<String> idSet = new Set<String>();
        
        List<Account> acc = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert acc;
        
        Id accountId = acc[0].Id;
        
        //Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
 
        ZuoraOnDemandSyncBatch batch = new ZuoraOnDemandSyncBatch(idSet, accountId);
        ID batchprocessid = Database.executeBatch(batch, 200);
        
        system.assertNotEquals(null, batchprocessid);
        
    }
    
}