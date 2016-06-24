/**
   @Author <Marjorie Gaelo>
   @name <AsiaOneServicesController_Test>
   @Description <Test class for AsiaOneServicesController>
   @CreateDate <2/6/2015>
   @Version <1.0>
  */

@isTest
private class AsiaOneServicesController_Test {
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createOther();
    }
    
     /**
    *  @description This method executes during class instantiation. 
    *  @name <testAsiaOneServc>
    */
    static testMethod void testAsiaOneServc(){
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;        
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;        
    
        Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
        asia.ASIAONE_Legacy_Id__c = 'tsh4sa5';
        asia.Legacy_Created_Date__c = '1232014';
        asia.Legacy_Created_By__c = 'lando';
        asia.Legacy_Updated_Date__c = '11409';
        asia.Legacy_Updated_By__c = 'doland';
        asia.Display_Name__c = 'asiasd';
        asia.User_ID_LDAP_ID__c = 'ldap@sing.com';
        asia.Password__c = 'ddfdf5654';
        insert asia;
        
        Asia1_Subscription__c asiasub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asiasub.Asia1__c = asia.id;
        asiasub.Status__c = 'Disabled';
        insert asiasub;   
        
        
       /* Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        insert billAcc;
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__Account__c = acc.Id;
        subs.Subscriber_Contact__c = con.id;
        subs.Recipient_Contact__c = con.id; 
        subs.Zuora__CustomerAccount__c = billAcc.id;
        insert subs;*/
        
        /*Asia1_Subscription__c asiasub2 = new Asia1_Subscription__c();
        asiasub2.Asia1__c = asia.id;
        asiasub2.Status__c = 'Enabled';
        update asiasub2;*/
        
       // Set<id> asia1SubscriptionIdSet = new Set<id>();
       // asia1SubscriptionIdSet.add(asiasub.id);
        
    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
        Map<String,Object> responseMap = new Map<String,Object>();
        
        responseMap = AsiaOneServicesController.verifyUser('username', 'samplePassword','samSerFlag');
        responseMap = AsiaOneServicesController.verifyUser2('SampUse', 'samplePassword');
        responseMap = AsiaOneServicesController.verifyUserFacebook('face@book.com');
        responseMap = AsiaOneServicesController.createAccount(new Map<String, String>());
        responseMap = AsiaOneServicesController.enableService('servena','eneserv');
        system.debug('\n\n ***debug responseMap *****  ' + responseMap +'\n\n');
        AsiaOneServicesController.enableServiceFuture('servfuture','ensfutu',asiasub.id);
        //AsiaOneServicesController.enableServicesFuture('disuseacc', 'eneserv', asia1SubscriptionIdSet, subs.id);
        //system.debug('\n\n ***debug responseMap 2 *****  ' + responseMap.get(AsiaOneServicesController.ACTIVATE_R) +'\n\n');
        responseMap = AsiaOneServicesController.disableService('disservc','servcdis');
        responseMap = AsiaOneServicesController.validateUserName('vusernme');
        responseMap = AsiaOneServicesController.validateDisplayName('valdisnme');
        responseMap = AsiaOneServicesController.viewUserDetails('usedetail');
        responseMap = AsiaOneServicesController.resetUserPassword('resetuse','usepass');
        responseMap = AsiaOneServicesController.enableUserAccount('useacc');
        responseMap = AsiaOneServicesController.disableUserAccount('disuseacc');
        
        Test.stopTest();
    }
    //jurna
    
    static testMethod void testAsiaOneServc2(){
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;        
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;        
    
        List<Asia1__c> asia = TestDataFactory.createAsiaOne(2);
        asia[0].ASIAONE_Legacy_Id__c = 'tsh4sa5';
        asia[0].Legacy_Created_Date__c = '1232014';
        asia[0].Legacy_Created_By__c = 'lando';
        asia[0].Legacy_Updated_Date__c = '11409';
        asia[0].Legacy_Updated_By__c = 'doland';
        asia[0].Display_Name__c = 'asiasd';
        asia[0].User_ID_LDAP_ID__c = 'ldap@sing.com';
        asia[0].Password__c = 'ddfdf5654';
        
        asia[1].ASIAONE_Legacy_Id__c = 'tsh4sa1';
        asia[1].Legacy_Created_Date__c = '1232014';
        asia[1].Legacy_Created_By__c = 'lando';
        asia[1].Legacy_Updated_Date__c = '11409';
        asia[1].Legacy_Updated_By__c = 'doland';
        asia[1].Display_Name__c = 'asiasd';
        asia[1].User_ID_LDAP_ID__c = 'ldap@sing.com';
        asia[1].Password__c = 'ddfdf5654';
        insert asia;
        
        List<Asia1_Subscription__c> asiasub = TestDataFactory.createAsiaOneSubscription(2);
        asiasub[0].Asia1__c = asia[0].id;
        asiasub[0].Status__c = 'Disabled';
        
        asiasub[1].Asia1__c = asia[1].id;
        asiasub[1].Status__c = 'Disabled';
        insert asiasub;   

        /*Asia1_Subscription__c asiasub2 = new Asia1_Subscription__c();
        asiasub2.Asia1__c = asia.id;
        asiasub2.Status__c = 'Enabled';
        update asiasub2;*/
        
        Set<id> asia1SubscriptionIdSet = new Set<id>();
        asia1SubscriptionIdSet.add(asiasub[0].id);
        asia1SubscriptionIdSet.add(asiasub[1].id);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        insert billAcc;
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__Account__c = acc.Id;
        subs.Subscriber_Contact__c = con.id;
        subs.Recipient_Contact__c = con.id; 
        subs.Zuora__CustomerAccount__c = billAcc.id;
        insert subs;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
        Map<String,Object> responseMap = new Map<String,Object>();
        responseMap = AsiaOneServicesController.verifyUser('username', 'samplePassword','samSerFlag');
        responseMap = AsiaOneServicesController.verifyUser2('SampUse', 'samplePassword');
        responseMap = AsiaOneServicesController.verifyUserFacebook('face@book.com');
        responseMap = AsiaOneServicesController.createAccount(new Map<String, String>());
        responseMap = AsiaOneServicesController.enableService('servena','eneserv');
        system.debug('\n\n ***debug responseMap  ' + responseMap +'\n\n');
        AsiaOneServicesController.enableServiceFuture('servfuture','ensfutu',asiasub[0].id);
        responseMap = AsiaOneServicesController.disableService('disservc','servcdis');
        responseMap = AsiaOneServicesController.validateUserName('vusernme');
        responseMap = AsiaOneServicesController.validateDisplayName('valdisnme');
        responseMap = AsiaOneServicesController.viewUserDetails('usedetail');
        responseMap = AsiaOneServicesController.resetUserPassword('resetuse','usepass');
        responseMap = AsiaOneServicesController.enableUserAccount('useacc');
        responseMap = AsiaOneServicesController.disableUserAccount('disuseacc');
        
        
         system.debug('\n\n ***debug activate_r' + AsiaOneServicesController.SUCCESS + '\n\n');
        if(AsiaOneServicesController.ACTIVATE_R == responseMap.get('Activate')){
        system.debug('\n\n ***I m here \n\n');
        }
        responseMap = AsiaOneServicesController.updateConcurrent('useacc','servcdis','quota');
        
        AsiaOneServicesController.enableServicesFuture('disuseacc', 'eneserv', asia1SubscriptionIdSet, subs.id);
        
        AsiaOneServicesController.disableServicesFuture('disservc', 'servcdis', asia1SubscriptionIdSet);
        AsiaOneServicesController.disableServiceFuture('disservc', 'servcdis', asiasub[0].id);
        Test.stopTest();
    }
    
    
    private static testMethod void testAsiaOneServce_3(){
     
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.NRIC__c = 'T1234567R';
        insert acc;        
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;        
    
        Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
        asia.ASIAONE_Legacy_Id__c = 'tsh4sa5';
        asia.Legacy_Created_Date__c = '1232014';
        asia.Legacy_Created_By__c = 'lando';
        asia.Legacy_Updated_Date__c = '11409';
        asia.Legacy_Updated_By__c = 'doland';
        asia.Display_Name__c = 'asiasd';
        asia.User_ID_LDAP_ID__c = 'ldap@sing.com';
        asia.Password__c = 'ddfdf5654';
        insert asia;
        
        Asia1_Subscription__c asiasub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asiasub.Asia1__c = asia.id;
        asiasub.Status__c = 'Disabled';
        insert asiasub;   
        
        
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        insert billAcc;
        
        Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
        subs.Zuora__Account__c = acc.Id;
        subs.Subscriber_Contact__c = con.id;
        subs.Recipient_Contact__c = con.id; 
        subs.Zuora__CustomerAccount__c = billAcc.id;
        insert subs;
        
        /*Asia1_Subscription__c asiasub2 = new Asia1_Subscription__c();
        asiasub2.Asia1__c = asia.id;
        asiasub2.Status__c = 'Enabled';
        update asiasub2;*/
        
        Set<id> asia1SubscriptionIdSet = new Set<id>();
        asia1SubscriptionIdSet.add(asiasub.id);
        
    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
        Map<String,Object> responseMap = new Map<String,Object>();
        
        responseMap = AsiaOneServicesController.verifyUser('username', 'samplePassword','samSerFlag');
        responseMap = AsiaOneServicesController.verifyUser2('SampUse', 'samplePassword');
        responseMap = AsiaOneServicesController.verifyUserFacebook('face@book.com');
        responseMap = AsiaOneServicesController.createAccount(new Map<String, String>());
        responseMap = AsiaOneServicesController.enableService('servena','eneserv');
        system.debug('\n\n ***debug responseMap *****  ' + responseMap +'\n\n');
        AsiaOneServicesController.enableServiceFuture('servfuture','ensfutu',asiasub.id);
        AsiaOneServicesController.enableServicesFuture('disuseacc', 'eneserv', asia1SubscriptionIdSet, subs.id);
        system.debug('\n\n ***debug responseMap 2 *****  ' + responseMap +'\n\n');
        responseMap = AsiaOneServicesController.disableService('disservc','servcdis');
        responseMap = AsiaOneServicesController.validateUserName('vusernme');
        responseMap = AsiaOneServicesController.validateDisplayName('valdisnme');
        responseMap = AsiaOneServicesController.viewUserDetails('usedetail');
        responseMap = AsiaOneServicesController.resetUserPassword('resetuse','usepass');
        responseMap = AsiaOneServicesController.enableUserAccount('useacc');
        responseMap = AsiaOneServicesController.disableUserAccount('disuseacc');
        
        Test.stopTest();
    }
}