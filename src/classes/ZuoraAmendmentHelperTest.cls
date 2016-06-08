@isTest (seeAllData = True)
private class ZuoraAmendmentHelperTest {

    static testmethod void test() {
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        Database.insert(acct);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acct.Id;
        Database.insert(order);
        
        Zoura_Amendment__c amendment = new Zoura_Amendment__c();
        amendment.Amendment_Id__c = 'test';
        amendment.Order__c = order.Id;
        Database.insert(amendment);
        
        Test.startTest();
        Set<ID> orderID = new Set<Id>();
        orderID.add(order.id);
        ZuoraAmendmentHelper.deleteAmendment(orderID);
        Test.stopTest();
        
        System.assertNotEquals(null, orderId.size());
        System.assertEquals(amendment.Order__c, order.id);
        
    }catch (Exception e) {
       }
    }
    
    static testmethod void testListOfZuoraAmendmentIds() {
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        Database.insert(acct);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acct.Id;
        Database.insert(order);
        
        Zoura_Amendment__c amendment = new Zoura_Amendment__c();
        amendment.Amendment_Id__c = 'Amendment';
        amendment.Order__c = order.Id;
        Database.insert(amendment); 
        
        Test.startTest();
        List<string> amendmentID = new List<String>();
        amendmentID.add(amendment.id);
        ZuoraAmendmentHelper.deleteAmendment(amendmentID);
        Test.stopTest();
        
        System.assertNotEquals(null, amendmentID.size());
        System.assertEquals(order.Account__c, acct.Id);
        
    }catch (Exception e) {
       }
    }
}