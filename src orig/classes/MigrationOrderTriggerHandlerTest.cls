@IsTest (seeAllData = True)
private class MigrationOrderTriggerHandlerTest {

            static Account testAccount;
            static Order__c testOrder;  
            static Contact testContact;
            static Zuora__CustomerAccount__c testBillingAccount;  
            
    static testmethod void testOrder()
    {
            testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            Database.insert (testAccount);
            
            testContact = TestDataFactory.createContact(1)[0];
            testContact.AccountId = testAccount.Id;
            testContact.Recipient_Indicator__c = true;
            Database.insert (testContact);
            
            testOrder = TestDataFactory.createOrder(1)[0];
            testOrder.Account__c = testAccount.Id; 
            testOrder.Order_Legacy_Id__c = 'IDNGNEIRGA';
            testOrder.Recipient_Contact__c = testContact.Id;
            testOrder.Credit_Balance__c = 100.00;
            testOrder.Delivery_Charge__c = 100.00;
            testOrder.Billing_Account_Creation_Mode__c = 'Use created Billing Account';
            testOrder.isChangeOfSubEntry__c = False;
            testOrder.isWaive__c = False;
            Database.insert (testOrder);
            
            testOrder = [SELECT Id, Order_Legacy_Id__c FROM Order__c WHERE Id = :testOrder.Id];
            
            Test.startTest();
            MigrationOrderTriggerHandler moth = new MigrationOrderTriggerHandler();
            moth.doBeforeInsert(new List<Order__c> { testOrder });
            
            Test.stopTest();
            
            System.assertEquals(testOrder.Order_Legacy_Id__c, 'IDNGNEIRGA');
    }
    
    static testmethod void testOrder2()
    {
            testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            Database.insert (testAccount);
            
            testContact = TestDataFactory.createContact(1)[0];
            testContact.AccountId = testAccount.Id;
            testContact.Recipient_Indicator__c = true;
            Database.insert (testContact);

            testBillingAccount = TestDataFactory.createBillingAccount(1)[0];
            testBillingAccount.Zuora__Account__c = testAccount.Id;
            testBillingAccount.Billing_Type__c = 'Full Prepaid';
            Database.insert (testBillingAccount);
            
            testOrder = TestDataFactory.createOrder(1)[0];
            testOrder.Billing_Account__c = testBillingAccount.Id;
            testOrder.Account__c = testAccount.Id; 
            testOrder.Order_Legacy_Id__c = 'IDNGNEIRGA';
            testOrder.Recipient_Contact__c = testContact.Id;
            testOrder.Credit_Balance__c = 100.00;
            testOrder.Delivery_Charge__c = 100.00;
            testOrder.Billing_Account_Creation_Mode__c = 'Use created Billing Account';
            testOrder.isChangeOfSubEntry__c = False;
            testOrder.isWaive__c = False;
            testOrder.Billing_Type__c = 'Full Prepaid';
            Database.insert (testOrder);

            testOrder = [SELECT Id, Order_Legacy_Id__c, Account__c FROM Order__c WHERE Id = :testOrder.Id];
            
            Map<Id, Order__c> orderMap = new Map<Id, Order__c>();
            orderMap.put(testOrder.id, testOrder);
            
            Map<Id, Order__c> orderMap2 = new Map<Id, Order__c>();
            orderMap2.put(testOrder.id, testOrder);
            
            Test.startTest();
            MigrationOrderTriggerHandler moth = new MigrationOrderTriggerHandler();
            moth.doBeforeUpdate(new List<Order__c> { testOrder }, orderMap , new List<Order__c> { testOrder }, orderMap2);
            Test.stopTest();
            
            System.assertEquals(testOrder.Order_Legacy_Id__c, 'IDNGNEIRGA');
    }
}