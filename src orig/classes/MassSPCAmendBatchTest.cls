@isTest(SeeAllData=true)
private class MassSPCAmendBatchTest{
    static testMethod void testMassSPCAmendBatch(){
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(BillAcc);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Legacy_Update_By__c = 'Migration - For Amendment';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Zuora__SubscriptionStartDate__c = date.today()+31;
        database.insert(subRecs);
        
        Zuora__SubscriptionProductCharge__c subProd = TestDataFactory.createSubscriptionProductCharge(1)[0];
        subProd.Zuora__Subscription__c = subRecs.Id;
        subProd.Zuora__Model__c = 'Per Unit Pricing';
        subProd.Name = 'Name';
        subProd.Zuora__ProductSKU__c = 'SKU01';
        subProd.Zuora__RatePlanName__c = 'Name';
        database.insert(subProd);
        
        Zuora__SubscriptionProductCharge__c subProd2 = TestDataFactory.createSubscriptionProductCharge(1)[0];
        subProd2.Zuora__Subscription__c = subRecs.Id;
        subProd2.Zuora__Model__c = 'Per Unit Pricing';
        subProd2.Name = 'Name';
        subProd2.Zuora__ProductSKU__c = 'SKU01';
        subProd2.Zuora__RatePlanName__c = 'Name';
        database.insert(subProd2);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.zqu__SKU__c = 'SKU01';
        database.insert(zp);
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        prp.Name = 'Name';
        database.insert(prp);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.Name = 'Name';
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.zqu__Deleted__c = false;
        database.insert(prpc); 
        //end test data
    
        test.startTest();
            MassSPCAmendBatch batch = new MassSPCAmendBatch();
            Id batchId = database.executeBatch(batch, 200);
            system.assertNotEquals(batchId, null);
        test.stopTest();
    }
}