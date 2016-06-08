/**
Class Name: SP_CancelFuturePStopTest
@author: Ana Fe Dumangas
Date: 7/14/15
Project/Requirement: SPH
@description This class is test class for SP_CancelFuturePStop
**/

@isTest(SeeAllData=true)
private class SP_CancelFuturePStopTest{
    static testMethod void testSP_CancelFuturePStop(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__CustomerAccount__c BA = TestDataFactory.createBillingAccount(1)[0];
        BA.Zuora__Account__c = acc.Id;
        database.insert(BA);
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = BA.Id;
        subs.Zuora__Zuora_Id__c = null;
        database.insert(subs);
    
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(1);
        ordLine[0].Order__c = ord.Id;
        ordLine[0].Main_Package_ID__c = pack.Id;
        ordLine[0].Stop_Request_Date__c = date.today()+1;
        ordLine[0].Subscription__c = subs.Id;
        database.insert(ordLine);
        
        test.startTest();
        
        SP_CancelFuturePStop cancel = new SP_CancelFuturePStop();
        database.executeBatch(cancel, 200);
        
        SP_CancelFuturePStop cancel1 = new SP_CancelFuturePStop(date.today());
        Database.BatchableContext BC;
        cancel1.start(BC);
        cancel1.execute(BC, ordLine);
    }
    
    static testMethod void testSP_CancelFuturePStop2(){
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        Order__c ord = TestDataFactory.createOrder(1)[0];
        ord.Account__c = acc.Id;
        database.insert(ord);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__CustomerAccount__c BA = TestDataFactory.createBillingAccount(1)[0];
        BA.Zuora__Account__c = acc.Id;
        database.insert(BA);
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__CustomerAccount__c = BA.Id;
        //subs.Zuora__Zuora_Id__c = '122456';
        database.insert(subs);
    
        List<Order_Line_Item__c> ordLine = TestDataFactory.createOrderLineItem(1);
        ordLine[0].Order__c = ord.Id;
        ordLine[0].Main_Package_ID__c = pack.Id;
        ordLine[0].Stop_Request_Date__c = date.today()+1;
        ordLine[0].Subscription__c = subs.Id;
        database.insert(ordLine);
        
        test.startTest();
        
        SP_CancelFuturePStop cancel = new SP_CancelFuturePStop();
        database.executeBatch(cancel, 200);
        
        SP_CancelFuturePStop cancel1 = new SP_CancelFuturePStop(date.today());
        Database.BatchableContext BC;
        cancel1.start(BC);
        cancel1.execute(BC, ordLine);
    }
}