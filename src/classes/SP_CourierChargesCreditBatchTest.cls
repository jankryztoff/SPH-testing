/**
Class Name: SP_CourierChargesCreditBatchTest

*/


@isTest(seeAllData = TRUE)

public class SP_CourierChargesCreditBatchTest{

    static testmethod void testStart() {
        Integer count;
    
       //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Vendor');
        accounts[0].Vendor_Group__c = 'A';
        accounts[0].AccountNumber = 'accnt number';
        insert accounts; 
        
       //Zuora__CustomerAccount__c
       Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
       defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
       defaultPayment.Zuora__Account__c = accounts[0].id; 
       insert defaultPayment;
    
      //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(2);
        count = 0;
        for(Order__c ord: orders){
            ord.Account__c = accounts[0].id;
            ord.Effective_Date__c = date.today();
            ord.Subscriber_charge__c = 100;
            count++;
        } 
        insert orders; 
        
        
        //Package__c
        List<Package__c> pack = TestDataFactory.createPackage(1);
        database.insert(pack);
        
        //Order_Line_Item__c
        List<Order_Line_Item__c> ordLineItem = TestDataFactory.createOrderLineItem(2);
        count = 0;
        for(Order_Line_Item__c ordLine: ordLineItem){
            ordLine.Postage_Charge__c = 100 + count;
            ordLine.Order__c = orders[0].Id;
            ordLine.Main_Package_ID__c = pack[0].Id;
            count++;
        } 
        insert ordLineItem;
        
      /*  //Zuora__Subscription__c
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(1);
        subs[0].Order_Number_1__c = orders[0].Id;
        subs[0].Vendor_1__c = accounts[0].id;
        subs[0].Zuora__CustomerAccount__c = defaultPayment.Id;
        subs[0].Number_of_Copies1__c = '3';    
        subs[0].Subscription_Type_1__c = 'Publication';
        database.insert(subs); 
        
        orders[0].Subscription__c = subs[0].Id;
        orders[0].Order_Type__c = 'Change of Subscription';
        database.update(orders); */
    
       Test.startTest();
       
       SP_CourierChargesCreditBatch batch= new SP_CourierChargesCreditBatch();
       /*database.batchableContext bcTemp = ;
       batch.start(bcTemp);
       batch.execute(bcTemp, orders);*/
       //Id batchId = Database.executeBatch(batch,200);
       Database.executeBatch(batch,200);
      
       Test.stopTest();
       
       //System.AssertEquals(batchId, null);
    }
}