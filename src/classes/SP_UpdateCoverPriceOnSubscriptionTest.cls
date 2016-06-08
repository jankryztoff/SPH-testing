/**
Class Name: SP_UpdateCoverPriceOnSubscriptionTest
@author: Ana Fe Dumangas
Date: 6/30/15
Descriprion: Test class for SP_UpdateCoverPriceOnSubscription
*/

@isTest(seeAllData = TRUE)

public class SP_UpdateCoverPriceOnSubscriptionTest{

    static testmethod void testStart(){
        Integer count;
    
       //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        database.insert(accounts); 
    
      //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(2);
        count = 0;
        for(Order__c ord: orders){
            ord.Account__c = accounts[count].id;
        } 
        database.insert(orders); 
        
        //Zuora__CustomerAccount__c
        Zuora__CustomerAccount__c billAccnt = TestDataFactory.createBillingAccount(1)[0];
        billAccnt.Zuora__Account__c = accounts[0].id;
        database.insert(billAccnt);
       
        //Zuora__Subscription__c
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        count=0;
        for(Zuora__Subscription__c sub: subs){
            sub.Product_Code__c = 'code'+count;
            sub.Zuora__CustomerAccount__c = billAccnt.Id;
            sub.Number_of_Copies1__c = '3';
        }
        database.insert(subs); 
        
        Zuora__SubscriptionProductCharge__c spc =  TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subs[0].Id;
        database.insert(spc);
        
       Test.startTest();
       try{
       Test.setMock(WebServiceMock.class, new zLoginMock());
       SP_UpdateCoverPriceOnSubscription batch= new SP_UpdateCoverPriceOnSubscription('code');
       //ID batchprocessid = Database.executeBatch(batch,200);
         Database.BatchableContext BC;
         batch.start(BC);
         batch.execute(BC, subs);
         batch.finish(BC);
         
         Test.stopTest();
       }
       catch(Zuora.zRemoteException e){
           String error = e.getMessage();
       }
       
    }
}