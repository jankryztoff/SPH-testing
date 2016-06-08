@isTest 
private class BT_TH_VSS085DX_ManageSubVenPubTest{
    static testMethod void testBT_TH_VSS085DX_ManageSubVenPublications() {
    //try {
  
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
        //List<Account> accnt = new List<Account>();        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        //acc.Id = '123456789';
        acc.Name = 'Vendor';
        acc.Vendor_Code__c = '01';
        acc.HDS_Recipient_Id__c = null;
        //accnt[1].Name = 'Vendor';
        //accnt[1].Vendor_Code__c = '01';
        //accnt.add(accnt[0]);
        //accnt.add(accnt[1]);
        database.insert(acc);
        
        Account acc2 = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc2.Name = 'Vendor';
        acc2.Vendor_Code__c = '01';
        acc2.HDS_Recipient_Id__c = '123';
        database.insert(acc2);
        
        Subscription_Vendor__c subVen = testDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.Id;
        insert subVen;
        
        Publication__c pub = testDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';
        insert pub;
        
        Subscription_Vendor_Publication__c subVenPub = testDataFactory.createVendorPublication(1)[0];
        subVenPub.HDS_Subscription_Id__c = '12345';
        subVenPub.Subscription_Vendor__c = subVen.Id;
        subVenPub.Publication__c = pub.Id;        
        insert subVenPub;
        
        //Subscription_Vendor__c sVen = testDataFactory.createSubscriptionVendor(1)[0];
        //database.insert(sVen);
        
                
        List<BT_CO_VSS_ImportVendorSubscription__c> importVenSubList = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        BT_CO_VSS_ImportVendorSubscription__c importVenSub = new BT_CO_VSS_ImportVendorSubscription__c();
        importVenSub.Name = 'VSS085DX';
        importVenSub.Batch_Run_Date__c = date.today();
        importVenSub.subscriptionCopies__c = '123456789123456789123456789';
        importVenSub.HdsSubscriptionId__c = '12345';
        importVenSub.SubscriptionUpdateIndicator__c = 'U';
        importVenSub.crsmVendorSubscriptionId__c = [SELECT Name FROM Subscription_Vendor__c WHERE id=:subVen.Id].Name;
        importVenSub.PublicationCode__c = '01';
        importVenSub.HdsRecipientId__c = null;
        
        importVenSubList.add(importVenSub);
        
        //START PD-0081 11-May-2016 Added by Raviteja - insert the record to increase the BT_TH_VSS085DX_ManageSubVenPublications code coverage
        BT_CO_VSS_ImportVendorSubscription__c importVenSub2 = new BT_CO_VSS_ImportVendorSubscription__c();
        importVenSub2.Name = 'VSS085DX';
        importVenSub2.Batch_Run_Date__c = date.today();
        importVenSub2.subscriptionCopies__c = '123456789123456789123456789';
        importVenSub2.HdsSubscriptionId__c = '12345';
        importVenSub2.SubscriptionUpdateIndicator__c = 'A';
        importVenSub2.crsmVendorSubscriptionId__c = [SELECT Name FROM Subscription_Vendor__c WHERE id=:subVen.Id].Name;
        importVenSub2.PublicationCode__c = '01';
        importVenSub2.HdsRecipientId__c = null;
        
        importVenSubList.add(importVenSub2);
        //END PD-0081 11-May-2016 Added by Raviteja
        
        database.insert(importVenSub);
        
        Set<String> setVendorSub = new Set<String>();
        setVendorSub.add(acc.Vendor_Code__c);
        setVendorSub.add(acc.Name);
        
        Set<String> hdsRecipientIDSet = new Set<String>();
        hdsRecipientIDSet.add(acc2.HDS_Recipient_Id__c);
        
        test.startTest();
            BT_TH_VSS085DX_ManageMaps newManageMap = new BT_TH_VSS085DX_ManageMaps();
            //newManageMap.getAccountsMapByHDSRecipientId(hdsRecipientIDSet, true);
         
            BT_TH_VSS085DX_ManageSubVenPublications manageSubven = new BT_TH_VSS085DX_ManageSubVenPublications();
            manageSubven.execute(importVenSubList, newManageMap);
        test.stopTest(); 
       // }catch(Exception e){
       // System.Debug(e);
       // }   
        }
        
        static testMethod void testBT_TH_VSS085DX_ManageSubVenPublications2() {
    //try {
  
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
        //List<Account> accnt = new List<Account>();        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        //acc.Id = '123456789';
        acc.Name = 'Vendor';
        acc.Vendor_Code__c = '01';
        acc.HDS_Recipient_Id__c = null;
        //accnt[1].Name = 'Vendor';
        //accnt[1].Vendor_Code__c = '01';
        //accnt.add(accnt[0]);
        //accnt.add(accnt[1]);
        database.insert(acc);
        
        Account acc2 = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc2.Name = 'Vendor';
        acc2.Vendor_Code__c = '01';
        acc2.HDS_Recipient_Id__c = '123';
        database.insert(acc2);
        
        Subscription_Vendor__c subVen = testDataFactory.createSubscriptionVendor(1)[0];
        subVen.Account__c = acc.Id;
        insert subVen;
        
        Publication__c pub = testDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '01';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';
        insert pub;
        
        Subscription_Vendor_Publication__c subVenPub = testDataFactory.createVendorPublication(1)[0];
        subVenPub.HDS_Subscription_Id__c = '12345';
        subVenPub.Subscription_Vendor__c = subVen.Id;
        subVenPub.Publication__c = pub.Id;        
        insert subVenPub;
        
        Subscription_Vendor__c sVen = testDataFactory.createSubscriptionVendor(1)[0];
        database.insert(sVen);
        
                
        List<BT_CO_VSS_ImportVendorSubscription__c> importVenSubList = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        BT_CO_VSS_ImportVendorSubscription__c importVenSub = new BT_CO_VSS_ImportVendorSubscription__c();
        importVenSub.Name = 'VSS085DX';
        importVenSub.Batch_Run_Date__c = date.today();
        importVenSub.subscriptionCopies__c = '123456789123456789123456789';
        importVenSub.HdsSubscriptionId__c = '12345';
        importVenSub.SubscriptionUpdateIndicator__c = 'U';
        importVenSub.crsmVendorSubscriptionId__c = [SELECT Name FROM Subscription_Vendor__c WHERE id=:sVen.Id].Name;
        importVenSub.PublicationCode__c = '01';
        importVenSub.HdsRecipientId__c = null;
        
        importVenSubList.add(importVenSub);
        database.insert(importVenSub);
        
        Set<String> setVendorSub = new Set<String>();
        setVendorSub.add(acc.Vendor_Code__c);
        setVendorSub.add(acc.Name);
        
        Set<String> hdsRecipientIDSet = new Set<String>();
        hdsRecipientIDSet.add(acc2.HDS_Recipient_Id__c);
        
        test.startTest();
            BT_TH_VSS085DX_ManageMaps newManageMap = new BT_TH_VSS085DX_ManageMaps();
            //newManageMap.getAccountsMapByHDSRecipientId(hdsRecipientIDSet, true);
         
            BT_TH_VSS085DX_ManageSubVenPublications manageSubven = new BT_TH_VSS085DX_ManageSubVenPublications();
            manageSubven.execute(importVenSubList, newManageMap);
        test.stopTest(); 
       // }catch(Exception e){
       // System.Debug(e);
       // }   
        }
    
}