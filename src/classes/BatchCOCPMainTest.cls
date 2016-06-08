/**
Class Name: BatchCOCPMainTest
@author: Christian Coquilla
Date: 4/12/16
Descriprion: Test class for BatchCOCPMain
*/

@isTest(seeAllData = TRUE)

public class BatchCOCPMainTest{

    static testmethod void testCOCPMain(){
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
            sub.Product_Code__c = 'CODE';
            sub.Zuora__CustomerAccount__c = billAccnt.Id;
            sub.Number_of_Copies1__c = '3';
        }
        database.insert(subs); 
        
        //SPC
        Zuora__SubscriptionProductCharge__c spc =  TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subs[0].Id;
    spc.Zuora__Price__c = 10.00;
    spc.Zuora__RatePlanName__c = 'Test Rate Plan';
    spc.Name = 'Test Charge Name';
    spc.Zuora__Model__c = GlobalVariableClass.SPC_MODEL_UNIT;
        spc.PublicationCode__c = 'PUB';
        database.insert(spc);
        
        //Z-Product
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.zqu__Deleted__c = false;
    zProd.ProductCode__c = 'Code';
        database.insert(zProd);
    
        //Rate Plan 
        zqu__ProductRatePlan__c zRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        zRatePlan.zqu__Deleted__c = false;
    zRatePlan.Name = 'Test Rate Plan';
    zRatePlan.zqu__ZProduct__c = zProd.Id;
        database.insert(zRatePlan);
    
    //Rate Plan Charge
        zqu__ProductRatePlanCharge__c zRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
        zRatePlanCharge.zqu__Deleted__c = false;
    zRatePlanCharge.Name = 'Test Charge Name';
    zRatePlanCharge.PublicationCode__c = 'PUB';
        zRatePlanCharge.zqu__ProductRatePlan__c = zRatePlan.id;
        database.insert(zRatePlanCharge);
        
       Test.startTest();
       try{
           Test.setMock(WebServiceMock.class, new zLoginMock());
           BatchCOCPMain batch= new BatchCOCPMain(date.today());
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