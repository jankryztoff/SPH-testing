//test class for BT_AB_HDS037DX_DailyVendorSubscriptionP2
@isTest
private class BT_AB_HDS037DX_DailyVendorSubsP2Test{
    static testMethod void testBT_AB_HDS037DX_DailyVendorSubscriptionP2(){
        //start custom settings
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        
        BatchInterface_Settings__c integ = new BatchInterface_Settings__c();
        integ.Name = 'Endpoint Delegator';
        integ.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(integ);
        //end custom settings
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '6000';
        database.insert(postal);
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Block_House_Number__c = '12';
        add.Postal_Code__c = postal.Id;
        database.insert(add);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Recipient_Number__c = 123456;
        con.Address__c = add.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Account accQ = [SELECT Id, Account_Auto_Number__c FROM Account WHERE Id=:acc.Id];
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Term_Length1__c = '0.1';
        sub.Product_Code__c = '01';
        sub.Recipient_Contact__c = con.Id;
        sub.Frequency_1__c = 'Default';
        sub.Qty1__c = '3';
        sub.Vendor_1__c = acc.Id;
        sub.Zuora__Account__c = accQ.Id;
        database.insert(sub);
        
        Zuora__Subscription__c subQ = [SELECT Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE id=:sub.Id];
        
        BT_CO_Batch_Run_Request__c batchRun = new BT_CO_Batch_Run_Request__c();
        batchRun.Interface_ID__c = 'HDS037DX';
        batchRun.End_Time__c = null;
        batchRun.Batch_Run_Date__c = (subQ.Zuora__SubscriptionEndDate__c).addDays(-1);
        database.insert(batchRun);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductCode__c = '01';
        database.insert(zp);
        
        List<Publication__c> pub = TestDataFactory.createPublication(2);
        for(Publication__c p: pub){
            p.Platform_Type__c = 'Print';   
            p.Published_Days__c = 'YYYYYYY';
        }
        database.insert(pub);
        
        Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
        prodPub.ZProduct__c = zp.Id;
        prodPub.Publication_Code__c = pub[0].Id;
        database.insert(prodPub);
        
        Product_Publication__c pp = new Product_Publication__c();
        pp.ZProduct__c = zp.Id;
        pp.Publication_Code__c = pub[1].Id;
        database.insert(pp);
        //end test data
    
        test.startTest();
            BT_AB_HDS037DX_DailyVendorSubscriptionP2 batch = new BT_AB_HDS037DX_DailyVendorSubscriptionP2();
            ID batchID = database.executeBatch(batch, 200);
            system.assertNotEquals(batchID, null);
        test.stopTest();
    }
}