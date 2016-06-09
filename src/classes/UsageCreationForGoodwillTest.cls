@isTest
private class UsageCreationForGoodwillTest{
    static testMethod void testUsageCreationForGoodwill(){
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
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        //List<Case> cases = TestDataFactory.createCase(2, 'Stop Subscription');
        List<Case> cases = TestDataFactory.createCase(2, 'Complaint - Digital');
        for(Case cas: cases){
            cas.Status = 'Closed';
            cas.Goodwill_Amount__c = 1;
            cas.Goodwill_Approval_Status__c = 'Approved';
        }
        database.insert(cases);
        
        Set<Id> caseID = new Set<Id>();
        for(Case cas: cases){
            caseID.add(cas.Id);
        }
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        database.insert(subRecs);
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cases[0].ID;
        caseSub.Subscription__c = subRecs.Id;
        database.insert(caseSub);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Name = 'Goodwill';
        spc.Zuora__Price__c = 1;
        database.insert(spc);
        
        test.startTest();
            UsageCreationForGoodwill.createUsageForGoodwill(caseID);
        test.stopTest();   
    }
    
    static testMethod void testUsageCreationForGoodwill2(){
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
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
    
        List<Case> cases = TestDataFactory.createCase(2, 'Stop Subscription');
        //List<Case> cases = TestDataFactory.createCase(2, 'Complaint - Digital');
        for(Case cas: cases){
            cas.Status = 'Closed';
            cas.Goodwill_Amount__c = 1;
            cas.Goodwill_Approval_Status__c = 'Approved';
            //c.Goodwill_Amount_Newspaper__c = 1;
        }
        database.insert(cases);
        
        Set<Id> caseID = new Set<Id>();
        for(Case cas: cases){
            caseID.add(cas.Id);
        }
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        database.insert(subRecs);
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cases[0].ID;
        caseSub.Subscription__c = subRecs.Id;
        caseSub.Goodwill_Amount__c = 1;
        database.insert(caseSub);
        
        Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubscriptionProductCharge(1)[0];
        spc.Zuora__Subscription__c = subRecs.Id;
        spc.Name = 'Goodwill';
        spc.Zuora__Price__c = 1;
        database.insert(spc);
        
        test.startTest();
            UsageCreationForGoodwill.createUsageForGoodwill(caseID);
        test.stopTest();   
    }
}