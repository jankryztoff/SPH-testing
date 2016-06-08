@isTest(SeeAllData=false)
private class BT_TH_VSS085DX_ManageOrdersTest2{
    static testMethod void testBT_TH_VSS085DX_ManageOrders(){
        //start test data
        //List<Account> acc = TestDataFactory.createAccount(1, 'Direct Corporate');
        //database.insert(acc);
        Map <String,Schema.RecordTypeInfo> contactRecordType = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecTypeId = contactRecordType.get('Direct Corporate').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name='Test Account 1';
        acc.Phone='000001';
        acc.Email__c = 'john@doe.com';
        acc.RecordTypeId = accRecTypeId;
        acc.AccountNumber='AN0001';
        acc.Unique_Entity_Number__c = '000001';
        acc.Contact_Person__c = 'Contact Person 1';
        insert acc;      
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';
        pub.publication_code__c = '01';
        database.insert(pub);
        
        Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.Id;
        database.insert(subVen);
        
        List<Subscription_Vendor_Publication__c> svp = TestDataFactory.createVendorPublication(1);
        for(Subscription_Vendor_Publication__c sv:svp){
            sv.Subscription_Vendor__c = subVen.Id;
            sv.HDS_Subscription_Id__c = '123456';
        }
        database.insert(svp);
        
        List<BT_CO_VSS_ImportVendorSubscription__c> recordsList = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        for(Integer i=0;i<3;i++){
            BT_CO_VSS_ImportVendorSubscription__c ivs = new BT_CO_VSS_ImportVendorSubscription__c();
            ivs.SubscriptionUpdateIndicator__c = 'A';
            ivs.HdsSubscriptionId__c = '123456';
            ivs.PublicationCode__c = '01';
            ivs.SubscriptionCopies__c = '312356565456897415665551235';
            recordsList.add(ivs);
        }
        database.insert(recordsList);
        
        BT_TH_VSS085DX_ManageMaps mapManager = new BT_TH_VSS085DX_ManageMaps();
        mapManager.setSubVenPubListForInsert(svp);
        //end test data
    
        test.startTest();
            BT_TH_VSS085DX_ManageOrders mOrders = new BT_TH_VSS085DX_ManageOrders();
            
            try{
            mOrders.execute(recordsList, mapManager);
            }catch(exception e){}
        test.stopTest();
    }
}