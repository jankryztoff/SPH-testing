/**
  * Class Name: BT_TH_STP050DX_StopPressSubscriptionTest
  * @author: Accenture IDC - Nilesh
  * Date: 10 Feb 2015
  * Requirement/Project Name: SPH Project
  * @description Test Class for BT_TH_STP050DX_StopPressSubscription
  * 
  */
@isTest
public class xTestClass {
    
    static void getCustomSettings()
    {
        BatchInterface_Settings__c btis = new BatchInterface_Settings__c();
        btis.Name = GlobalVariableClass.ENDPOINTDELEGATOR;
        btis.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert btis;
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = date.valueOf('2014-08-19T14:00:00.000+0000');
        cir.Mon_Fri_Start_Time__c = date.valueOf('2014-08-19T00:00:00.000+0000');
        cir.Sat_PH_End_Time__c = date.valueOf('2014-08-18T09:00:00.000+0000');
        cir.Sat_PH_Start_Time__c = date.valueOf('2014-08-18T00:00:00.000+0000');
        cir.Sun_End_Time__c = date.valueOf('2014-08-18T09:00:00.000+0000');
        cir.Sun_Start_Time__c = date.valueOf('2014-08-18T09:00:00.000+0000');  
        insert cir;
        
        //KeyId
        Map<String, Map<String, Id>> rcTypeMap = new Map<String, Map<String, Id>>();
        for(RecordType rt : [SELECT Id, Name, SObjectType FROM RecordType]) {
            if(!rcTypeMap.containsKey(rt.SObjectType)) {
                rcTypeMap.put(rt.SObjectType, new Map<String, Id>());
            }
            rcTypeMap.get(rt.SObjectType).put(rt.Name, rt.Id);
        }
        
        insert new List<Key_Id__c>{
            new Key_Id__c(Name='Contact_Customer Contact',Id__c=rcTypeMap.get('Contact').get('Customer Contact')), 
            new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER',Id__c='123457742'),
            new Key_Id__c(Name='Account_Direct Corporate',Id__c=rcTypeMap.get('Account').get('Direct Corporate')),
            new Key_Id__c(Name='Case_Start Sub',Id__c= rcTypeMap.get('Case').get('Start Subscription'))
                };
        insert new list<Other__c>{new Other__c(Name='DTL', Value__c='14:00'), new Other__c(Name='Order_Type Renewal', Value__c='Renewal')};
    }
    
    
    static testMethod void externalPaymentTriggerHandlerTest() {
        getCustomSettings();
        Singpost_Address__c postal = new Singpost_Address__c();
        postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c address = new Address__c();
        address = TestDataFactory.createAddress(1)[0];
        address.Postal_Code__c = postal.Id;
        insert address;
        
        //Account acct = new Account();
        Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acct.Name = 'TestAcct';
        acct.NRIC__c = 'T1234567R';
        acct.Email__c = 'test@test.com';
        acct.Mobile__c = '123456';
        insert acct;
        
        Contact con = new Contact();
        con = TestDataFactory.createContact(1)[0];
        con.AccountId = acct.Id;
        con.Address__c = address.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        Zuora__CustomerAccount__c zua =  TestDataFactory.createBillingAccount(1)[0];
        zua.Zuora__Account__c = acct.Id;
        zua.Zuora__PaymentMethodType__c = 'Paypal';
        insert zua;
        

        External_Payment__c xp = new External_Payment__c();
        xp.Name = 'External Payment Test 1';
        xp.Billing_Account__c = zua.Id;
        xp.Transaction_Amount__c = 1000.00;
        xp.Transaction_Date__c = date.today();
        xp.Transaction_type__c = 'D';
        
        insert xp;
        
        xp.Transaction_Amount__c = 2000.00;
        update xp;
        
    }
}