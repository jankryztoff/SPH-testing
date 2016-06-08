@isTest(seeAllData = true)
private class InvLineItem_TriggerHandlerTest{
    
    static testmethod void unitTest(){
        
        User cso = TestDataFactory.prepareTestUsers();
        
        System.runAs(cso){
            Test.startTest();
            
            InvLineItem_TriggerHandler invLineItem = new InvLineItem_TriggerHandler();
            
            invLineItem.runBeforeInsertTrigger();
            invLineItem.runBeforeUpdateTrigger();
            invLineItem.runBeforeDeleteTrigger();
            invLineItem.runAfterInsertTrigger();
            invLineItem.runAfterUpdateTrigger();
            invLineItem.runAfterDeleteTrigger();
            //invLineItem.bulkBefore();
            //invLineItem.beforeInsert();
            //invLineItem.getSubId();
            
            Test.stopTest();
        }
    }
    
    static testmethod void unitTest2(){
        
        User cso = TestDataFactory.prepareTestUsers();
        
        System.runAs(cso){
            Test.startTest();
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            insert acc;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.id;
            insert billAcc;
            
            Contact con = TestDataFactory.createContact(1)[0];
            insert con;
            
            Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
            subs.Zuora__CustomerAccount__c = billAcc.id;
            subs.Number_of_Copies__c = 1;
            subs.Number_of_Copies1__c = '1';
            subs.Recipient_Contact__c = con.id;
            subs.Name = '123';
            insert subs;
            
            Invoice_Line_Item__c invLine = new Invoice_Line_Item__c();
            invLine.Charge_Amount__c = 100.00;
            invLine.Subscription_Number__c = '123';
            //invLine.Subscription__c = subs.id;
            insert invLine;
            
            invLine.Charge_Amount__c = 50.00;
            update invLine;
            
            delete invLine;
            
            Test.stopTest();
        }
    }
}