@isTest (seeAllData= false)
private class BT_AB_DIR094DX_VendorPerformanceDTest {
    static testMethod void testVendorPerformanceDirect() {
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
        
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Vendor_Code__c = '01';
        database.insert(acc);
    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Status = 'Pending';
        cas.Sub_Status__c = 'Approved';
        cas.Sub_Category__c = 'Miscellaneous';
        cas.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
        cas.AccountId = acc.Id;
        database.insert(cas);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        database.insert(zp);
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.RatePlanType__c= 'Bill Plan';
        prp.zqu__ZProduct__c = zp.Id;
        database.insert(prp);
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        packItem.Package__c = pack.Id;
        packItem.Product_Rate_Plan__c = prp.Id;
        database.insert(packItem);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Product_Code__c = '01';
        sub.Vendor_1__c = acc.Id;
        sub.Vendor__c = acc.Id;
        sub.Main_Package_1__c = pack.Id;
        database.insert(sub);
    
        List<Case_Subscription__c> caseSubs = TestDataFactory.createCaseSubscription(200);
        for(Case_Subscription__c cs: caseSubs){
            cs.Case__c = cas.Id;
            cs.Subscription__c = sub.Id;
        }
        database.insert(caseSubs);
        
        Set<Id> caseSubsId = new Set<Id>();
        for(Case_Subscription__c cs : caseSubs){
            caseSubsId.add(cs.Id);
        }
        
        List<Id> packageIDs  = new List<Id>();
        packageIDs.add(pack.id);
        
        List<Case_Subscription__c> casesub = [SELECT id,Subscription__r.Product_Code__c, Case__c, Case__r.Account_Record_Type__c, Case__r.CaseNumber, Case__r.AccountId, Subscription__c, Subscription__r.Main_Package_1__c, Subscription__r.Vendor_1__r.Vendor_Code__c, Subscription__r.Vendor_1__r.Vendor_Group__c, Case__r.Status, Case__r.Sub_Status__c, Case__r.RecordType.DeveloperName, Case__r.Sub_Category__c, Case__r.CreatedDate, Subscription__r.Frequency__c,Complaint_From__c, Complaint_To__c FROM Case_Subscription__c WHERE id IN: caseSubsId];
        //system.debug(casesub.Case__r.Sub_Status__c+':'+casesub.Case__r.RecordType.DeveloperName+':'+casesub.Case__r.Status);
        //system.debug(casesub.Case__r.Sub_Category__c+','+ casesub.Case__r.CreatedDate);
        
        Zuora__Subscription__c subQ = [SELECT Main_Package_1__c, Id FROM Zuora__Subscription__c WHERE id=:sub.Id];
        system.debug(subQ.Main_Package_1__c);
        //system.debug(casesub.Subscription__r.Main_Package_1__c);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'TestPub';
        pub.Publication_Code__c = '01';
        pub.Platform_Type__c = 'Print';
        pub.Publication_Type__c = 'N';
        database.insert(pub);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.PublicationCode__c = '01';
        database.insert(prpc);
       
        
        test.startTest();
            BT_AB_DIR094DX_VendorPerformanceDirect batch = new BT_AB_DIR094DX_VendorPerformanceDirect();
            //BT_AB_DIR094DX_VendorPerfCloneTest batch = new BT_AB_DIR094DX_VendorPerfCloneTest();
            database.executeBatch(batch, 200);
               
            Database.BatchableContext BC;
            batch.execute(BC, casesub);
        test.stopTest();    
    }
}