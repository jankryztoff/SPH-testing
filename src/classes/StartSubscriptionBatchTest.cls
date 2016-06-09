@isTest(seeAllData= True)
private class StartSubscriptionBatchTest{

    public static Key_Id__c acctRecType = [Select Id, Name, Id__c, Type__c FROM Key_Id__c WHERE NAME = 'Account_Direct Individual' LIMIT 1];
    
    static testmethod void unitTest(){
    
        Account account = new Account(Name = 'SPHAccountTest', RecordTypeId = acctRecType.Id__c, Status__c = 'Active', Active__c = true, Email__c = 'test@sample.com', Mobile__c = '1234567');
        insert account;
        
        List<Order__c> orders = TestDataFactory.createOrder(2);
        for(Order__c order: orders){
            order.Account__c = account.id;
        }
        insert orders;
        
        Set<String> newOrderIdSet_str = new Set<String>();
        for(Order__c order: orders){
            newOrderIdSet_str.add(order.id);
        }
        
        StartSubscriptionBatch batch = new StartSubscriptionBatch(newOrderIdSet_str);
        ID batchprocessid = Database.executeBatch(batch, 200);
        System.assertNotEquals(null, batchprocessid);
        
    }
}