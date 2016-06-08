/**
 * Class Name: Asia1SubsDeactivationBatchable_Test
 * @author: April Grace Veloso
 * Date: 08/26/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description: Test Class for Asia1SubscriptionDeactivationBatchable
 */

@isTest
public with sharing class Asia1SubsDeactivationBatchable_Test{
    
     @testSetup 
        static void setupData() {
            insert CustomSettingsDataFactory.createKey_Id();
            insert CustomSettingsDataFactory.createOther(); 
            insert CustomSettingsDataFactory.createIntegration_Settings();
            insert CustomSettingsDataFactory.createBatchInterface(); 
           
        } 
    
    static testmethod void test(){
           
            //Create an Address record
            List<Address__c> addressList = TestDataFactory.createAddress(1);
            insert addressList;
           
            //insert account
            Map <String,Schema.RecordTypeInfo> accountRecordType = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id acctRecTypeId = accountRecordType.get('Direct SPH Inter-Division').getRecordTypeId();
           
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.RecordTypeId = acctRecTypeId;
            database.insert(acc);
            
            // insert contact
            Map <String,Schema.RecordTypeInfo> contactRecordType = contact.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id conRecTypeId = contactRecordType.get('Customer Contact').getRecordTypeId();
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c =addressList[0].id; 
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = conRecTypeId;
            database.insert(con);         
             
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Billing_Contact__c = con.id;
            billAccountList[0].ARMS_Account_Number__c = '027101021';
            billAccountList[0].Other_PaymentMethod__c ='Invoice';
            billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
            billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
            billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
            billAccountList[0].Payment_Mode__c = 'CREDITCARD';
            database.insert(billAccountList);
         
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Name = 'NUM124';
            zSub.Subscription_Type__c = 'Full Prepaid';
            zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__Status__c = 'Cancelled';
            zSub.Recipient_Contact__c = con.id;
            zSub.Zuora__SubscriptionEndDate__c = date.Today();
            database.insert(zSub);
            
            List<Service_Access_Flag__c> servAccess = Testdatafactory.createServiceAccessFlag(1);
            servAccess[0].Name = 'AccessOne';
            database.insert(servAccess);
            
            List<Asia1__c> asiaOne = Testdatafactory.createAsiaOne(1);
            asiaOne[0].Display_Name__c = 'Asia1';
            asiaOne[0].User_ID_LDAP_ID__c = 'UserLdap1';
            asiaOne[0].Password__c = 'ab12cd';
            database.insert(asiaOne);
            
            List<Asia1_Subscription__c> asiaOneSub= TestdataFactory.createAsiaOneSubscription(1);
            asiaOneSub[0].Asia1__c = asiaOne[0].id;
            asiaOneSub[0].Status__c = 'Enabled';
            asiaOneSub[0].Subscription__c = zSub.id;
            asiaOneSub[0].Service_Access_Flag__c = servAccess[0].id;
            database.insert(asiaOneSub);
            
            Asia1SubscriptionDeactivationBatchable batch = new Asia1SubscriptionDeactivationBatchable();
            ID batchprocessid = Database.executeBatch(batch,200);
            System.assertNotEquals(null, batchprocessid);
            
            Asia1SubscriptionDeactivationBatchable batch2 = new Asia1SubscriptionDeactivationBatchable(asiaOne[0].id);
            ID batchprocessid2 = Database.executeBatch(batch2,200);
    }
    static testmethod void testActive(){
           
            //Create an Address record
            List<Address__c> addressList = TestDataFactory.createAddress(1);
            insert addressList;
           
            //insert account
            Map <String,Schema.RecordTypeInfo> accountRecordType = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id acctRecTypeId = accountRecordType.get('Direct SPH Inter-Division').getRecordTypeId();
           
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.RecordTypeId = acctRecTypeId;
            database.insert(acc);
            
            // insert contact
            Map <String,Schema.RecordTypeInfo> contactRecordType = contact.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id conRecTypeId = contactRecordType.get('Customer Contact').getRecordTypeId();
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c =addressList[0].id; 
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = conRecTypeId;
            database.insert(con);        
             
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Billing_Contact__c = con.id;
            billAccountList[0].ARMS_Account_Number__c = '027101021';
            billAccountList[0].Other_PaymentMethod__c ='Invoice';
            billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
            billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
            billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
            billAccountList[0].Payment_Mode__c = 'CREDITCARD';
            insert billAccountList;
           
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Name = 'NUM124';
            zSub.Subscription_Type__c = 'Full Prepaid';
            zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Recipient_Contact__c = con.id;
            zSub.Zuora__SubscriptionEndDate__c = date.Today();
            insert zSub; 
            
            List<Service_Access_Flag__c> servAccess = Testdatafactory.createServiceAccessFlag(1);
            servAccess[0].Name = 'AccessOne';
            insert servAccess;
            
            List<Asia1__c> asiaOne = Testdatafactory.createAsiaOne(1);
            asiaOne[0].Display_Name__c = 'Asia1';
            asiaOne[0].User_ID_LDAP_ID__c = 'UserLdap1';
            asiaOne[0].Password__c = 'ab12cd';
            insert asiaOne;
            
            List<Asia1_Subscription__c> asiaOneSub= TestdataFactory.createAsiaOneSubscription(1);
            asiaOneSub[0].Asia1__c = asiaOne[0].id;
            asiaOneSub[0].Status__c = 'Enabled';
            asiaOneSub[0].Subscription__c = zSub.id;
            asiaOneSub[0].Service_Access_Flag__c = servAccess[0].id;
            insert asiaOneSub;
            
            Asia1SubscriptionDeactivationBatchable batch = new Asia1SubscriptionDeactivationBatchable();
            ID batchprocessid = Database.executeBatch(batch,200);
            System.assertNotEquals(null, batchprocessid);
    }
}