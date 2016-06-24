/* April Veloso
   10/20/2015
   Test Class for PaperFeeCalculator
*/

@isTest(seeAllData = False)
public with sharing class PaperFeeCalculatorTest{


    static testmethod void test1(){
       Integer counter; 
         
       Other__c other = new Other__c();
       other.Name = 'DTL';
       other.Value__c = '23:59';
       insert(other); 

        Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '30012551';
        insert(key); 
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acct;
        
        Zuora__CustomerAccount__c billingAccount = TestDataFactory.createBillingAccount(1)[0];
        billingAccount.Zuora__Account__c = acct.Id;
        insert billingAccount;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Replaced_by_Vendor__c = true;
        insert cas;
         
        Publication__c pub =TestdataFactory.createPublication(1)[0];        
        pub.Platform_Type__c = 'Print';
        pub.Publication_Type__c ='N';
        pub.Frequency_Code__c = 'D';
        pub.Publication_Next_Start_Date__c = date.today();
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Code__c = 'SPO';
        database.insert(pub);
        
        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Zuora__CustomerAccount__c = billingAccount.Id;
        subscription.Frequency__c = 'Mon - Fri';
        insert subscription;
        
        List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(2);
        for(Case_Subscription__c cs: caseSub){
            cs.Case__c = cas.Id;
            cs.Subscription__c = subscription.Id;
            cs.Complaint_Copies__c = 5;
            cs.Complaint_From__c = date.today().addDays(-15);
            cs.Complaint_To__c = date.today().addDays(-1);
            cs.Replace_From__c = date.today().addDays (-13);
            cs.Replace_To__c = date.today().addDays(-12);
            cs.Replacement_Copies__c = 4;
        }
        database.insert(caseSub); 
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestdataFactory.createSubscriptionProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c spc: zSubProdCharge){
            spc.Zuora__Subscription__c =subscription .id;
            spc.PublicationCode__c = 'SPO';
            spc.Zuora__UOM__c = 'Copy Weekday';
            spc.Zuora__Price__c = 10.00;
        }
        database.insert(zSubProdCharge);
        
        map<String,Publication__c> pi = new map<String,Publication__c>();
        pi.put('SPO', pub);
        
        /*Zuora__SubscriptionProductCharge__c spc : [select Zuora__Subscription__c, Zuora__Price__c, Zuora__UOM__c, 
                PublicationCode__c from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c in :subscriptionIdSet 
                and Zuora__UOM__c in :uomCopySet]) {*/
                
          Test.startTest();
          PaperFeeCalculator feeCalculator = new PaperFeeCalculator();
          UsageHelper.PublicationInformation = pi;
          PaperFeeCalculator.compute(caseSub);
          
          subscription.Frequency__c = 'Sat - Sun';
          PaperFeeCalculator.compute(caseSub);
          
          caseSub[0].Complaint_Copies__c = null;
          caseSub[1].Complaint_Copies__c = null;
          update caseSub;
          
          cas.Replaced_by_Vendor__c = false;
          update cas;
          
          PaperFeeCalculator.compute(caseSub);
          Test.stopTest();  
    }
    
    static testmethod void test2(){
       Integer counter; 
         
       Other__c other = new Other__c();
       other.Name = 'DTL';
       other.Value__c = '23:59';
       insert(other); 

        Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '30012551';
        insert(key); 
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acct;
        
        Zuora__CustomerAccount__c billingAccount = TestDataFactory.createBillingAccount(1)[0];
        billingAccount.Zuora__Account__c = acct.Id;
        insert billingAccount;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Replaced_by_Vendor__c = true;
        insert cas;
         
        Publication__c pub =TestdataFactory.createPublication(1)[0];        
        pub.Platform_Type__c = 'Print';
        pub.Publication_Type__c ='N';
        pub.Frequency_Code__c = 'D';
        pub.Publication_Next_Start_Date__c = date.today();
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Code__c = 'SPO';
        database.insert(pub);
        
        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Zuora__CustomerAccount__c = billingAccount.Id;
        subscription.Frequency__c = 'Sat - Sun';
        insert subscription;
        
        List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(2);
        for(Case_Subscription__c cs: caseSub){
            cs.Case__c = cas.Id;
            cs.Subscription__c = subscription.Id;
            cs.Complaint_Copies__c = 5;
            cs.Complaint_From__c = date.today().addDays(-15);
            cs.Complaint_To__c = date.today().addDays(-1);
            cs.Replace_From__c = date.today().addDays (-13);
            cs.Replace_To__c = date.today().addDays(-12);
            cs.Replacement_Copies__c = 4;
        }
        database.insert(caseSub); 
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestdataFactory.createSubscriptionProductCharge(3);
        for(Zuora__SubscriptionProductCharge__c spc: zSubProdCharge){
            spc.Zuora__Subscription__c =subscription .id;
            spc.PublicationCode__c = 'SPO';
            spc.Zuora__UOM__c = GlobalVariableClass.UOM_COPYSAT;
            spc.Zuora__Price__c = 10.00;
            if(counter==2){
                spc.Zuora__UOM__c = GlobalVariableClass.UOM_COPYSUN;
            }
            counter++;
        }
        database.insert(zSubProdCharge);
        
        map<String,Publication__c> pi = new map<String,Publication__c>();
        pi.put('SPO', pub);
        
        /*Zuora__SubscriptionProductCharge__c spc : [select Zuora__Subscription__c, Zuora__Price__c, Zuora__UOM__c, 
                PublicationCode__c from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c in :subscriptionIdSet 
                and Zuora__UOM__c in :uomCopySet]) {*/
                
          Test.startTest();
          PaperFeeCalculator feeCalculator = new PaperFeeCalculator();
          UsageHelper.PublicationInformation = pi;
          PaperFeeCalculator.compute(caseSub);
          Test.stopTest();  
    }
}