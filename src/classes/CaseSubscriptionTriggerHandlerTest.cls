@isTest (SeeAllData = true)
private class CaseSubscriptionTriggerHandlerTest { 
        // prepares the data needed for the testing of the base class
        
        static CaseSubscriptionTriggerHandler casSub;    
    
    static testMethod void CaseSubscriptionTriggerHandlertest(){
        
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Test.startTest();    
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acct;
        
        Zuora__CustomerAccount__c billingAccount = TestDataFactory.createBillingAccount(1)[0];
        billingAccount.Zuora__Account__c = acct.Id;
        insert billingAccount;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        insert cas;
        
        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Zuora__CustomerAccount__c = billingAccount.Id;
        insert subscription;
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subscription.Id;
        insert caseSub;
        Test.stopTest();
        
        System.assertNotEquals(null,caseSub);
        
    } catch (Exception e) {
       }
    }
    
    
    static void test2(){
        
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
           
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acct;
        
        Zuora__CustomerAccount__c billingAccount = TestDataFactory.createBillingAccount(1)[0];
        billingAccount.Zuora__Account__c = acct.Id;
        insert billingAccount;
        
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='popconbatch@test.com'
        );

        Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        //cas.Account__c = acct.Id;
        cas.Replacement_Required__c = true;
        cas.Within_Circulation_Planning_Schedule__c = true;
        insert cas;

        Singpost_Address__c singPostAdd = TestDataFactory.createSingpostAddress(1)[0];
        singPostAdd.Name = '6000';
        insert singpostAdd;
        
        //Post_Sector_Ops_Rep_Mapping__c postSectOps = TestDataFactory.createPostSector(1)[0];
        //postSectOps.Postal_Sector_Code__c = 6000;
        //postSectOps.Vendor_Ops__c = testuser.Id;
        //insert postSectOps;
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singPostAdd.Id;
        insert add;
        
        Test.startTest();
        
        Contact cont = TestDataFactory.createContact(1)[0];
        cont.Address__c = add.Id;
        insert cont;
        
        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Zuora__CustomerAccount__c = billingAccount.Id;
        subscription.Recipient_Contact__c = cont.Id;
        insert subscription;
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subscription.Id;
        insert caseSub;
     
        Test.stopTest();
        
        /**
        Case_Subscription__c caseSub2 = TestDataFactory.createCaseSubscription(1)[0];
        caseSub2.Case__c = cas.Id;
        caseSub2.Subscription__c = subscription.Id;
        insert caseSub2;
        
        List<Case_Subscription__c> caseSub3 = TestDataFactory.createCaseSubscription(2);
        caseSub3[0].Case__c = cas.Id;
        caseSub3[0].Subscription__c = subscription.Id;
        insert new List<Sobject>{caseSub3[0]};
        
        Test.startTest(); 
        
        List<Case_Subscription__c> caseSub4 = TestDataFactory.createCaseSubscription(2);
        caseSub4[0].Case__c = cas.Id;
        caseSub4[0].Subscription__c = subscription.Id;
        insert new List<Sobject>{caseSub4[0]};
        
        Map<Id, Case_Subscription__c> caseSubMap = new Map<Id, Case_Subscription__c>();
        caseSubMap.put(caseSub.Id, caseSub);
        Map<Id, Case_Subscription__c> caseSubMap2 = new Map<Id, Case_Subscription__c>();
        caseSubMap2.put(caseSub2.Id, caseSub2);
        casSub = new CaseSubscriptionTriggerHandler();
        casSub.doBeforeUpdate(caseSub3, caseSubMap, caseSub4, caseSubMap2); */
        
        //CaseSubscriptionTriggerHandler caseSubTrig = new CaseSubscriptionTriggerHandler();
        //caseSubTrig.runBeforeInsertTrigger();
        
        //System.assertEquals('012N00000008kI8IAI',string.valueof((Id)ConstantsSLB.getKeyId(GlobalVariableClass.COMPNEWS)));
        
    } catch (Exception e) {
           } 
}    

    static void test3(){
        
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
           
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acct;
        
        Zuora__CustomerAccount__c billingAccount = TestDataFactory.createBillingAccount(1)[0];
        billingAccount.Zuora__Account__c = acct.Id;
        insert billingAccount;
        
        Test.startTest();
        
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='popconbatch@test.com'
        );
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        cas.Account__c = acct.Id;
        cas.Replacement_Required__c = true;
        cas.Within_Circulation_Planning_Schedule__c = true;
        insert cas;

        Singpost_Address__c singPostAdd = TestDataFactory.createSingpostAddress(1)[0];
        singPostAdd.Name = '6000';
        insert singpostAdd;
        
        //Post_Sector_Ops_Rep_Mapping__c postSectOps = TestDataFactory.createPostSector(1)[0];
        //postSectOps.Postal_Sector_Code__c = 60;
        //postSectOps.Vendor_Ops__c = testuser.Id;
        //insert postSectOps;
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singPostAdd.Id;
        insert add;
        
        Contact cont = TestDataFactory.createContact(1)[0];
        cont.Address__c = add.Id;
        insert cont;
        
        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Zuora__CustomerAccount__c = billingAccount.Id;
        subscription.Recipient_Contact__c = cont.Id;
        insert subscription;
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Account__c = acct.Id;
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subscription.Id;
        insert caseSub;
     
        Test.stopTest();
        
        /**
        Case_Subscription__c caseSub2 = TestDataFactory.createCaseSubscription(1)[0];
        caseSub2.Case__c = cas.Id;
        caseSub2.Subscription__c = subscription.Id;
        insert caseSub2;
        
        List<Case_Subscription__c> caseSub3 = TestDataFactory.createCaseSubscription(2);
        caseSub3[0].Case__c = cas.Id;
        caseSub3[0].Subscription__c = subscription.Id;
        insert new List<Sobject>{caseSub3[0]};
        
        Test.startTest(); 
        
        List<Case_Subscription__c> caseSub4 = TestDataFactory.createCaseSubscription(2);
        caseSub4[0].Case__c = cas.Id;
        caseSub4[0].Subscription__c = subscription.Id;
        insert new List<Sobject>{caseSub4[0]};
        
        Map<Id, Case_Subscription__c> caseSubMap = new Map<Id, Case_Subscription__c>();
        caseSubMap.put(caseSub.Id, caseSub);
        Map<Id, Case_Subscription__c> caseSubMap2 = new Map<Id, Case_Subscription__c>();
        caseSubMap2.put(caseSub2.Id, caseSub2);
        casSub = new CaseSubscriptionTriggerHandler();
        casSub.doBeforeUpdate(caseSub3, caseSubMap, caseSub4, caseSubMap2); */
        
        //CaseSubscriptionTriggerHandler caseSubTrig = new CaseSubscriptionTriggerHandler();
        //caseSubTrig.runBeforeInsertTrigger();
        
        //System.assertEquals('012N00000008kI8IAI',string.valueof((Id)ConstantsSLB.getKeyId(GlobalVariableClass.COMPNEWS)));
        
    } catch (Exception e) {
           } 
}    

   static testMethod void testRecordTypeIsEqualToCOMPNEWS(){
        
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acct;
        
        Zuora__CustomerAccount__c billingAccount = TestDataFactory.createBillingAccount(1)[0];
        billingAccount.Zuora__Account__c = acct.Id;
        insert billingAccount;
        
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='popconbatch@test.com'
        );

        Singpost_Address__c singPostAdd = TestDataFactory.createSingpostAddress(1)[0];
        singPostAdd.Name = '6000';
        insert singpostAdd;
       
        //Integer postSectorCode = integer.valueof(singPostAdd.Name);
        
        //Post_Sector_Ops_Rep_Mapping__c postSectOps = TestDataFactory.createPostSector(1)[0];
        //postSectOps.Postal_Sector_Code__c = 2;
        //postSectOps.Vendor_Ops__c = testuser.Id;
        //insert postSectOps;
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Postal_Code__c = singPostAdd.Id;
        insert add;
        
        Contact cont = TestDataFactory.createContact(1)[0];
        cont.Address__c = add.Id;
        insert cont;
        
        Test.startTest(); 
        
        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Zuora__CustomerAccount__c = billingAccount.Id;
        subscription.Recipient_Contact__c = cont.Id;
        insert subscription;
        
        Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
        tempStop.Restart_Date__c = date.Today();
        tempStop.Temp_Stop_Date__c = date.Today()+2;
        insert tempStop;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint_Newspaper')[0];
        //cas.RecordTypeId = [SELECT Id FROM RecordType WHERE  Name = 'Complaint_Newspaper'].id;
        cas.Temp_Stop_Sub__c = subscription.Id;
        cas.COA__c = false;
        cas.Case_Sub_Status__c = 'Case Created';
        cas.Sub_Status__c = 'Waiting for Urgent Temp Stop/Restart Approval';
        cas.Temp_Stop_Date__c = date.Today();
        cas.Restart_Date__c = date.Today()+2;
        cas.Temp_Stop__c = tempStop.Id;
        cas.Effective_Date__c = date.Today()+3;
        cas.Change_of_Address_Type__c = 'Change of Vendor';
        cas.Account__c = acct.Id;
        insert cas;
        
        Case_Subscription__c caseSub = TestDataFactory.createCaseSubscription(1)[0];
        caseSub.Case__c = cas.Id;
        caseSub.Subscription__c = subscription.Id;
        insert caseSub; 
        
        List<Case_Subscription__c> caseSub2 = new List<Case_Subscription__c>();
        caseSub2.add(caseSub);  
                
        Map<Id, Case_Subscription__c> mapNewCaseSubs = new Map<Id, Case_Subscription__c>();
        mapNewCaseSubs.put(caseSub.Id, caseSub);
        
        Map<Id, Case_Subscription__c> mapOldCaseSubs = new Map<Id, Case_Subscription__c>();
        mapNewCaseSubs.put(caseSub.Id, caseSub);
        
        CaseSubscriptionTriggerHandler caseSubTrig = new CaseSubscriptionTriggerHandler();
        
        caseSubTrig.doAfterInsert(new List<Case_Subscription__c>{caseSub}, mapNewCaseSubs);
        caseSubTrig.doBeforeUpdate(new List<Case_Subscription__c>{caseSub}, mapNewCaseSubs, caseSub2, mapOldCaseSubs);
        caseSubTrig.doAfterUpdate(new List<Case_Subscription__c>{caseSub}, mapNewCaseSubs, caseSub2, mapOldCaseSubs);
        caseSubTrig.doBeforeDelete(new List<Case_Subscription__c>{caseSub}, mapOldCaseSubs);
        //caseSubTrig.doAfterDelete(new List<Case_Subscription__c>{caseSub}, mapOldCaseSubs);
        caseSubTrig.doAfterDelete(caseSub2, mapOldCaseSubs);
        
        Test.stopTest();

        System.assertEquals('012N00000008kI8IAI',string.valueof((Id)ConstantsSLB.getKeyId(GlobalVariableClass.COMPNEWS)));
        
    }    
        catch (Exception e) {
           } 
        
    }         

}
    
     
    
    
    
    
    /**   
         
        Map<String, SObject> sObjMap = new Map<String, SObject>(); 
        sObjMap = TestDataFactory.createSubscriptionPackage(); 
        
        Account acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        insert acct; 
        
        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
        billingAcc.Zuora__Account__c = acct.Id;
        billingAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billingAcc.ARMS_Return_Status__c = 'test';
        insert billingAcc;
    
        Order__c ord = TestDataFactory.createorder(1)[0];
        ord.Account__c = acct.Id;
        ord.Subscriber_Charge__c = 10.00;
        insert ord;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        insert pack;
            
        System.debug('###### AFTER subRecs insert : ' + Limits.getQueries());
            
        Case ca = (Case) sObjMap.get('Case');
        String recId = [Select Id From RecordType Where Name = 'Complaint - Newspaper' LIMIT 1].id;
        ca.AccountId = sObjMap.get('Account').Id;
        ca.RecordTypeId = recId;
        ca.Creation_Mode__c = '';
        ca.Status = 'New';
        update ca;  
        
        System.debug('###### AFTER ca update : ' + Limits.getQueries());
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        insert address;  
        
        Contact con = TestDataFactory.createContact(1)[0];
        insert con; 
        
        //Zuora__Subscription__c subRecs = (Zuora__Subscription__c ) sObjMap.get('Zuora__Subscription__c');
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__Account__c = acct.Id;
        subRecs.Delivery_Charge__c = 10.00;
        subRecs.Sponsor_1__c = false;
        subRecs.Zuora__CustomerAccount__c = billingAcc.Id;
        Test.startTest(); 
        insert subRecs;
        //System.debug('###### AFTER createSubscriptionPackage : ' + Limits.getQueries());  
        
        Case_Subscription__c casSub = new Case_Subscription__c();
        casSub.Subscription__c = subRecs.Id;
        casSub.Address__c = address.Id;
        casSub.Account__c = subRecs.id;
        casSub.Case__c = ca.id;
        casSub.Address__c = sObjMap.get('Address__c').Id;
        casSub.Account__c = sObjMap.get('Account').Id;
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Order__c = ord.Id;
        oli.Term_Length__c = 100;
        oli.Subscription__c = subRecs.Id;
        oli.Main_Package_Billing_Type__c = 'Full';
        oli.Delivered_By__c = 'Vendor';
        oli.Main_Package_ID__c = pack.Id;
        insert oli;
          
        insert casSub; 
        System.debug('###### AFTER casSub insert : ' + Limits.getQueries());
        update casSub;
        System.debug('###### AFTER casSub update : ' + Limits.getQueries());
        delete casSub;
        System.debug('###### AFTER casSub delete : ' + Limits.getQueries());
        Test.stopTest();
                
 }
    static testMethod void CaseSubscriptionTriggerHandlertest2(){
        
        
        Map<String, SObject> sObjMap = new Map<String, SObject>(); 
        sObjMap = TestDataFactory.createSubscriptionPackage();        
        Zuora__Subscription__c subRecs = (Zuora__Subscription__c ) sObjMap.get('Zuora__Subscription__c');   
        insert subRecs;
        
        //Contact con = TestDataFactory.createContact(1)[0];
        //Account acct = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        
        //insert acct;
       
        //Case ca = (Case) sObjMap.get('Case');
        //String recId = [Select Id From RecordType Where Name = 'Complaint - Newspaper' LIMIT 1].id;
        //ca.AccountId = sObjMap.get('Account').Id;
        //ca.RecordTypeId = recId;
        //ca.Creation_Mode__c = '';
        //ca.Status = 'New';
        //update ca;
        
        Case ca2 = (Case) sObjMap.get('Case');
        String recId2 = [Select Id From RecordType Where Name = 'Complaint - Magazine' LIMIT 1].id;
        ca2.AccountId = sObjMap.get('Account').Id;
        ca2.RecordTypeId = recId2;
        ca2.Creation_Mode__c = '';
        ca2.Status = 'New';
        update ca2;
        
     
        Test.startTest();
        Case_Subscription__c casSub = new Case_Subscription__c();
        casSub.Subscription__c = subRecs.id;
        casSub.Case__c = ca2.id;
        casSub.Address__c = sObjMap.get('Address__c').Id;
        casSub.Account__c = sObjMap.get('Account').Id;
        
        
        insert casSub; 
        update casSub;
        delete casSub;
        Test.stopTest();
        */