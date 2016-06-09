@isTest(seeAllData = false)
public class SP_BatchCreateCreditBalanceTest{

    static testmethod void testBatch(){
        Test.startTest();
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
    
        List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        insert keyy;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;    
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        billAcc.Zuora__Credit_Balance__c = 1;
        insert billAcc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;   
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;    
        
        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Billing_Indicator__c = true;
        conList[0].LastName = 'Last Nmmame';
        conList[0].FirstName = 'First Nasjme';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; //02-27-15 Added by JPO to cover else-if conditions for lines 608-618
        conList[0].Mobile_Number_2__c = '09112234567';
        insert conList;    
        
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Name= 'CS0000000110';
        zuoSubList[0].Number_of_Copies__c= 10;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Next_Earliest_Start_Date__c= date.today();
        zuoSubList[0].Unique_Address_Id__c= 'asdasdasd';
        zuoSubList[0].Year_to_Date_Temp_Stop_Days__c= 2;
        zuoSubList[0].Previous_Year_Temp_Stop_Days__c= 2;
        zuoSubList[0].Legacy_Create_Date__c='2014-08-07';
        zuoSubList[0].Legacy_Create_By__c='test';
        zuoSubList[0].Legacy_Update_Date__c='test';
        zuoSubList[0].Legacy_Update_By__c='test';
        zuoSubList[0].Legacy_Subscription_ID__c='test';
        zuoSubList[0].Cheque_details__c='test';
        zuoSubList[0].DTL__c='test';
        zuoSubList[0].Paypal_Payment_Profile_Id__c='test';
        zuoSubList[0].Pub_Tag__c='test';
        zuoSubList[0].Subscribe_As__c='test';
        zuoSubList[0].Zuora__SubscriptionEndDate__c= null;
        zuoSubList[0].Zuora__SubscriptionStartDate__c= Date.today().addDays(1);
        zuoSubList[0].Subscription_Grace_Period_End_Date__c= 'test';
        zuoSubList[0].Gift_ID__c= 'test';
        zuoSubList[0].Redeem_Date__c= 'test';
        zuoSubList[0].Gift_ID_2__c= 'test';
        zuoSubList[0].Redeem_Date_2__c= 'test';
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Charge__c= 223.0;
        zuoSubList[0].Term_Length__c= 2;
        zuoSubList[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Main_Package_1__c = packageList[0].Id;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Subscription_Type__c  = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        insert zuoSubList;
        
        Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
        zInv.Zuora__BillingAccount__c = billAcc.id;
        zInv.Zuora__Balance2__c = 1;
        insert zInv;
        
        
        SP_BatchCreateCreditBalance batch = new SP_BatchCreateCreditBalance();
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    }
    
    static testmethod void testBatch2(){
    
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
    
        List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        insert keyy;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;    
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        billAcc.Zuora__Credit_Balance__c = 2;
        insert billAcc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;   
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;    
        
        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Billing_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Namex';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; //02-27-15 Added by JPO to cover else-if conditions for lines 608-618
        conList[0].Mobile_Number_2__c = '09112234567';
        insert conList;    
        
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Name= 'CS0000000110';
        zuoSubList[0].Number_of_Copies__c= 10;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Next_Earliest_Start_Date__c= date.today();
        zuoSubList[0].Unique_Address_Id__c= 'asdasdasd';
        zuoSubList[0].Year_to_Date_Temp_Stop_Days__c= 2;
        zuoSubList[0].Previous_Year_Temp_Stop_Days__c= 2;
        zuoSubList[0].Legacy_Create_Date__c='2014-08-07';
        zuoSubList[0].Legacy_Create_By__c='test';
        zuoSubList[0].Legacy_Update_Date__c='test';
        zuoSubList[0].Legacy_Update_By__c='test';
        zuoSubList[0].Legacy_Subscription_ID__c='test';
        zuoSubList[0].Cheque_details__c='test';
        zuoSubList[0].DTL__c='test';
        zuoSubList[0].Paypal_Payment_Profile_Id__c='test';
        zuoSubList[0].Pub_Tag__c='test';
        zuoSubList[0].Subscribe_As__c='test';
        zuoSubList[0].Zuora__SubscriptionEndDate__c= null;
        zuoSubList[0].Zuora__SubscriptionStartDate__c= Date.today().addDays(1);
        zuoSubList[0].Subscription_Grace_Period_End_Date__c= 'test';
        zuoSubList[0].Gift_ID__c= 'test';
        zuoSubList[0].Redeem_Date__c= 'test';
        zuoSubList[0].Gift_ID_2__c= 'test';
        zuoSubList[0].Redeem_Date_2__c= 'test';
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Charge__c= 223.0;
        zuoSubList[0].Term_Length__c= 2;
        zuoSubList[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Main_Package_1__c = packageList[0].Id;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Subscription_Type__c  = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        insert zuoSubList;
        
        Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
        zInv.Zuora__BillingAccount__c = billAcc.id;
        zInv.Zuora__Balance2__c = 1;
        insert zInv;
        
        Test.startTest();
        SP_BatchCreateCreditBalance batch = new SP_BatchCreateCreditBalance();
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    }
    
    static testmethod void testBatch3(){
    
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
    
        List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        insert keyy;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;    
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        billAcc.Zuora__Credit_Balance__c = 2;
        billAcc.Zuora__Balance__c = 5;
        insert billAcc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;   
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;    
        
        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Billing_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Namxe';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; //02-27-15 Added by JPO to cover else-if conditions for lines 608-618
        conList[0].Mobile_Number_2__c = '09112234567';
        insert conList;    
        
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Name= 'CS0000000110';
        zuoSubList[0].Number_of_Copies__c= 10;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Next_Earliest_Start_Date__c= date.today();
        zuoSubList[0].Unique_Address_Id__c= 'asdasdasd';
        zuoSubList[0].Year_to_Date_Temp_Stop_Days__c= 2;
        zuoSubList[0].Previous_Year_Temp_Stop_Days__c= 2;
        zuoSubList[0].Legacy_Create_Date__c='2014-08-07';
        zuoSubList[0].Legacy_Create_By__c='test';
        zuoSubList[0].Legacy_Update_Date__c='test';
        zuoSubList[0].Legacy_Update_By__c='test';
        zuoSubList[0].Legacy_Subscription_ID__c='test';
        zuoSubList[0].Cheque_details__c='test';
        zuoSubList[0].DTL__c='test';
        zuoSubList[0].Paypal_Payment_Profile_Id__c='test';
        zuoSubList[0].Pub_Tag__c='test';
        zuoSubList[0].Subscribe_As__c='test';
        zuoSubList[0].Zuora__SubscriptionEndDate__c= null;
        zuoSubList[0].Zuora__SubscriptionStartDate__c= Date.today().addDays(1);
        zuoSubList[0].Subscription_Grace_Period_End_Date__c= 'test';
        zuoSubList[0].Gift_ID__c= 'test';
        zuoSubList[0].Redeem_Date__c= 'test';
        zuoSubList[0].Gift_ID_2__c= 'test';
        zuoSubList[0].Redeem_Date_2__c= 'test';
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Charge__c= 223.0;
        zuoSubList[0].Term_Length__c= 2;
        zuoSubList[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Main_Package_1__c = packageList[0].Id;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Subscription_Type__c  = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        insert zuoSubList;
        
        Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
        zInv.Zuora__BillingAccount__c = billAcc.id;
        zInv.Zuora__Balance2__c = 5;
        zInv.Zuora__TotalAmount__c = 10;
        insert zInv;
        
        Test.startTest();
        SP_BatchCreateCreditBalance batch = new SP_BatchCreateCreditBalance();
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    }
    
    static testmethod void testBatch4(){
    
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
    
        List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        insert keyy;
        
        List<Account> accList = TestDataFactory.createAccount(3, 'Vendor Subscriber');
        accList[0].NRIC__c = 'T1234567R';
        insert accList;    
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Other_PaymentMethod__c = GlobalVariableClass.INVOICE;
        billAcc.Zuora__Credit_Balance__c = 0;
        billAcc.Zuora__Balance__c = 5;
        insert billAcc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[1].Billing_Type__c = 'Full Prepaid';
        insert packageList;   
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;    
        
        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].AccountId = accList[0].Id;
        conList[0].Address__c = addressRec.Id;
        conList[0].Billing_Indicator__c = true;
        conList[0].LastName = 'Last Name';
        conList[0].FirstName = 'First Name';
        conList[0].Phone = '1234567';
        conList[0].Mobile_Number__c = '09155568874'; //02-27-15 Added by JPO to cover else-if conditions for lines 608-618
        conList[0].Mobile_Number_2__c = '09112234567';
        insert conList;    
        
        List <Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Name= 'CS0000000110';
        zuoSubList[0].Number_of_Copies__c= 10;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Next_Earliest_Start_Date__c= date.today();
        zuoSubList[0].Unique_Address_Id__c= 'asdasdasd';
        zuoSubList[0].Year_to_Date_Temp_Stop_Days__c= 2;
        zuoSubList[0].Previous_Year_Temp_Stop_Days__c= 2;
        zuoSubList[0].Legacy_Create_Date__c='2014-08-07';
        zuoSubList[0].Legacy_Create_By__c='test';
        zuoSubList[0].Legacy_Update_Date__c='test';
        zuoSubList[0].Legacy_Update_By__c='test';
        zuoSubList[0].Legacy_Subscription_ID__c='test';
        zuoSubList[0].Cheque_details__c='test';
        zuoSubList[0].DTL__c='test';
        zuoSubList[0].Paypal_Payment_Profile_Id__c='test';
        zuoSubList[0].Pub_Tag__c='test';
        zuoSubList[0].Subscribe_As__c='test';
        zuoSubList[0].Zuora__SubscriptionEndDate__c= null;
        zuoSubList[0].Zuora__SubscriptionStartDate__c= Date.today().addDays(1);
        zuoSubList[0].Subscription_Grace_Period_End_Date__c= 'test';
        zuoSubList[0].Gift_ID__c= 'test';
        zuoSubList[0].Redeem_Date__c= 'test';
        zuoSubList[0].Gift_ID_2__c= 'test';
        zuoSubList[0].Redeem_Date_2__c= 'test';
        zuoSubList[0].Subscriber_Contact__c= conList[0].Id;
        zuoSubList[0].Recipient_Contact__c= conList[0].Id;
        zuoSubList[0].Subscription_Charge__c= 223.0;
        zuoSubList[0].Term_Length__c= 2;
        zuoSubList[0].Zuora__Zuora_Id__c= '2c92c0f849f118740149f2a6a6f967ed';
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Main_Package_1__c = packageList[0].Id;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Subscription_Type__c  = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        insert zuoSubList;
        
        Zuora__ZInvoice__c zInv = TestDataFactory.createInvoice(1)[0];
        zInv.Zuora__BillingAccount__c = billAcc.id;
        zInv.Zuora__Balance2__c = 5;
        zInv.Zuora__TotalAmount__c = 10;
        insert zInv;
        
        Test.startTest();
        SP_BatchCreateCreditBalance batch = new SP_BatchCreateCreditBalance();
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    }
    
    static testmethod void testBatch5(){
    
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
    
        List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        insert keyy;
        
        Date batchRunDate = date.today().addDays(2);
        
        Test.startTest();
        SP_BatchCreateCreditBalance batch = new SP_BatchCreateCreditBalance(batchRunDate);
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    
    }
    
    static testmethod void testBatch6(){
    
        Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
        insert dtl;
    
        List<Key_Id__c> keyy = TestDataFactory.createKeyIds();
        insert keyy;
        
        Set<String> selectiveIds = new Set<String>();
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        insert acc;
        selectiveIds.add(String.ValueOf(acc.Id));
        
        Test.startTest();
        SP_BatchCreateCreditBalance batch = new SP_BatchCreateCreditBalance(selectiveIds, 2);
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        Test.stopTest();
    
    }
}