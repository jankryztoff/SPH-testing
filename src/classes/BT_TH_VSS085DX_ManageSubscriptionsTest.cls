@isTest
private class BT_TH_VSS085DX_ManageSubscriptionsTest{
    static testMethod void testBT_TH_VSS085DX_ManageSubscriptions(){
        Integer counter;
        
        //start custom settings
        Other__c other = new Other__c();
        other.Name = 'DTL';
        other.Value__c = '23:59';
        database.insert(other);
        //end custom settings
        
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.HDS_Recipient_Id__c = null;
        database.insert(acc);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.HDS_Contact_Id__c = null;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__Account__c = acc.Id;
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        database.insert(sub);
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        database.insert(subVen);
        
        Subscription_Vendor__c subVenQ = [SELECT Id, Name FROM Subscription_Vendor__c WHERE Id=:subVen.Id];
        
        List<BT_CO_VSS_ImportVendorSubscription__c> importVenList = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        for(counter=0;counter<2;counter++){
            BT_CO_VSS_ImportVendorSubscription__c importVen = new BT_CO_VSS_ImportVendorSubscription__c();
            importVen.publicationCode__c = '01';
            importVen.HdsRecipientId__c = null;
            importVen.HdsContactId__c = null;
            importVen.HdsSubscriptionId__c = sub.Id;
            importVen.CrsmVendorSubscriptionId__c = subVenQ.Name;
            importVen.SubscriptionUpdateIndicator__c = 'A';
            importVenList.add(importVen);
        }
        database.insert(importVenList);
        
        BT_TH_VSS085DX_ManageMaps maps = new BT_TH_VSS085DX_ManageMaps();
        //end test data
        
        test.startTest();
            BT_TH_VSS085DX_ManageSubscriptions batch = new BT_TH_VSS085DX_ManageSubscriptions();
            batch.execute(importVenList, maps);
        test.stopTest();
    }
}