/*
Author: Christian C. Coquilla
Class: SP_CreateCreditNoteBatch  
Date: April 6, 2016
*/


@isTest(seeAllData = true)
public class SP_CreateCreditNoteBatchTest {
    static testmethod void unitTest1() { 
        
        Account acct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acct.NRIC__c = 'T1234567R';
        insert acct;    
        
       Address__c add = TestDataFactory.createAddress(1)[0];
       add.Address_Unique_ID__c = '123152test';
       insert add; 
        
       Contact con = TestDataFactory.createContact(1)[0];
       con.AccountId = acct.Id;
       con.Recipient_Indicator__c = true;
       con.Recipient_Number__c = 123456;
       con.Address__c = add.Id;
       con.LastName = 'Last Name';
       con.FirstName = 'First Name';
       con.Phone = '1234567';
       con.Mobile_Number__c = '09155568874'; 
       con.Mobile_Number_2__c = '09112234567';       
       insert con;
       
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       //billAcc.Zuora__AccountNumber__c = 'z123sgd';
       billAcc.Zuora__Account__c = acct.Id;
       billAcc.Billing_Type__c = 'Recurring Prepaid';
       insert billAcc;
        
       Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
       subscription.Zuora__Zuora_Id__c  = '123456789';
       subscription.Zuora__Account__c = acct.Id;
       subscription.Recipient_Contact__c = con.Id;
       subscription.Recipient_Contact_1__c = con.Id;
       subscription.Subscription_Type_1__c =  'DELIVERY';
       subscription.Subscription_Type__c = 'DELIVERY';
       subscription.Zuora__CustomerAccount__c = billAcc.Id;
       subscription.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_MR_POST;
       subscription.Zuora__SubscriptionStartDate__c = date.today().addDays(21).toStartOfMonth();
       subscription.New_Contract_Period_1__c = 1;
       subscription.Contract_End_Date_1__c = date.Today();
       subscription.Zuora__Status__c = 'Active';
       subscription.Zuora__SubscriptionEndDate__c = null;
       insert subscription; 
       
       Zuora__ZInvoice__c zinv = TestDataFactory.createInvoice(1)[0];
       zinv.Zuora__TotalAmount__c = -1;
       zinv.InvoicePaymentFailure__c = 'Y';
       zinv.Is_CN_Processed__c = false;
       zinv.Zuora__Status__c = 'cancelText';
       zinv.Zuora__AdjustmentAmount__c = 0;
       zinv.Zuora__Zuora_Id__c = '123456789';
       zinv.Zuora__ZuoraId__c = '123456789';
       insert zinv;
       
       List<Invoice_Line_Item__c> iliList = new List<Invoice_Line_Item__c>();
       Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
       ili.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
       ili.Charge_Amount__c = -1; // 38% to 30%
       ili.Subscription__c = subscription.Id;
       ili.Invoice_ID__c = zinv.Zuora__Zuora_Id__c;
       ili.Applied_To_Invoice_Item_ID__c = null;
       ili.Charge_Name__c = 'LineItemchargeName';
       insert ili;
     
       iliList.add(ili);
      
       //system.assertEquals(null, ili.Applied_To_Invoice_Item_ID__c);
       
       Zuora__SubscriptionProductCharge__c subsProd = testDataFactory.createSubscriptionProductCharge(1)[0];
       subsProd.Zuora__UOM__c = 'LANDED'; 
       subsProd.Zuora__Subscription__c = subscription.Id;
       insert subsProd; 
       
       set<Id> invset = new set<Id>();
       invset.add(zinv.Id);
           
    Test.startTest();
    
    SP_CreateCreditNoteBatch batch = new SP_CreateCreditNoteBatch(invset);
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        
    Test.stopTest();
    }
    
    static testmethod void unitTest2() { 
        
        Account acct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acct.NRIC__c = 'T1234567R';
        insert acct;    
        
       Address__c add = TestDataFactory.createAddress(1)[0];
       add.Address_Unique_ID__c = '123152test';
       insert add; 
        
       Contact con = TestDataFactory.createContact(1)[0];
       con.AccountId = acct.Id;
       con.Recipient_Indicator__c = true;
       con.Recipient_Number__c = 123456;
       con.Address__c = add.Id;
       con.LastName = 'Last Name';
       con.FirstName = 'First Name';
       con.Phone = '1234567';
       con.Mobile_Number__c = '09155568874'; 
       con.Mobile_Number_2__c = '09112234567';       
       insert con;
       
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       //billAcc.Zuora__AccountNumber__c = 'z123sgd';
       billAcc.Zuora__Account__c = acct.Id;
       billAcc.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
       insert billAcc;
        
       Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
       subscription.Zuora__Zuora_Id__c  = '123456789';
       subscription.Zuora__Account__c = acct.Id;
       subscription.Recipient_Contact__c = con.Id;
       subscription.Recipient_Contact_1__c = con.Id;
       subscription.Subscription_Type_1__c =  'DELIVERY';
       subscription.Subscription_Type__c = 'DELIVERY';
       subscription.Zuora__CustomerAccount__c = billAcc.Id;
       subscription.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_MR_POST;
       subscription.Zuora__SubscriptionStartDate__c = date.today().addDays(21).toStartOfMonth();
       subscription.New_Contract_Period_1__c = 1;
       subscription.Contract_End_Date_1__c = date.Today();
       subscription.Zuora__Status__c = 'Active';
       subscription.Zuora__SubscriptionEndDate__c = null;
       insert subscription; 
       
       Zuora__ZInvoice__c zinv = TestDataFactory.createInvoice(1)[0];
       zinv.Zuora__TotalAmount__c = -1;
       zinv.InvoicePaymentFailure__c = 'Y';
       zinv.Is_CN_Processed__c = false;
       zinv.Zuora__Status__c = 'cancelText';
       zinv.Zuora__AdjustmentAmount__c = 0;
       zinv.Zuora__Zuora_Id__c = '123456789';
       zinv.Zuora__ZuoraId__c = '123456789';
       insert zinv;
       
       List<Invoice_Line_Item__c> iliList = new List<Invoice_Line_Item__c>();
       Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
       ili.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
       ili.Charge_Amount__c = -1;
       ili.Subscription__c = subscription.Id;
       ili.Invoice_ID__c = zinv.Zuora__Zuora_Id__c;
       ili.Applied_To_Invoice_Item_ID__c = null;
       ili.Charge_Name__c = 'LineItem';
       insert ili;
     
       iliList.add(ili);
      
       //system.assertEquals(null, ili.Applied_To_Invoice_Item_ID__c);
       
       Zuora__SubscriptionProductCharge__c subsProd = testDataFactory.createSubscriptionProductCharge(1)[0];
       subsProd.Zuora__UOM__c = 'LANDED'; 
       subsProd.Zuora__Subscription__c = subscription.Id;
       insert subsProd; 
       
       set<Id> invset = new set<Id>();
       invset.add(zinv.Id);
           
    Test.startTest();
    
    SP_CreateCreditNoteBatch batch = new SP_CreateCreditNoteBatch(invset);
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        
    Test.stopTest();
    }
    
    static testmethod void unitTest3() { 
        
        Account acct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acct.NRIC__c = 'T1234567R';
        insert acct;    
        
       Address__c add = TestDataFactory.createAddress(1)[0];
       add.Address_Unique_ID__c = '123152test';
       insert add; 
        
       Contact con = TestDataFactory.createContact(1)[0];
       con.AccountId = acct.Id;
       con.Recipient_Indicator__c = true;
       con.Recipient_Number__c = 123456;
       con.Address__c = add.Id;
       con.LastName = 'Last Name';
       con.FirstName = 'First Name';
       con.Phone = '1234567';
       con.Mobile_Number__c = '09155568874'; 
       con.Mobile_Number_2__c = '09112234567';       
       insert con;
       
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       //billAcc.Zuora__AccountNumber__c = 'z123sgd';
       billAcc.Zuora__Account__c = acct.Id;
       billAcc.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
       insert billAcc;
        
       Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
       subscription.Zuora__Zuora_Id__c  = '123456789';
       subscription.Zuora__Account__c = acct.Id;
       subscription.Recipient_Contact__c = con.Id;
       subscription.Recipient_Contact_1__c = con.Id;
       subscription.Subscription_Type_1__c =  'DELIVERY';
       subscription.Subscription_Type__c = 'DELIVERY';
       subscription.Zuora__CustomerAccount__c = billAcc.Id;
       subscription.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
       subscription.Zuora__SubscriptionStartDate__c = date.today().addDays(21).toStartOfMonth();
       subscription.New_Contract_Period_1__c = 1;
       subscription.Contract_End_Date_1__c = date.Today();
       subscription.Zuora__Status__c = 'Active';
       subscription.Zuora__SubscriptionEndDate__c = null;
       insert subscription; 
       
       Zuora__ZInvoice__c zinv = TestDataFactory.createInvoice(1)[0];
       zinv.Zuora__TotalAmount__c = -1;
       zinv.InvoicePaymentFailure__c = 'Y';
       zinv.Is_CN_Processed__c = false;
       zinv.Zuora__Status__c = 'cancelText';
       zinv.Zuora__AdjustmentAmount__c = 0;
       zinv.Zuora__Zuora_Id__c = '123456789';
       zinv.Zuora__ZuoraId__c = '123456789';
       zinv.Zuora__BillingAccount__c = billAcc.Id;
       zinv.Zuora__TaxAmount__c = 100;
       zinv.Zuora__AmountWithoutTax__c = 300;
       zinv.Zuora__TaxExemptAmount__c = 200;
       insert zinv;
       
       List<Invoice_Line_Item__c> iliList = new List<Invoice_Line_Item__c>();
       Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
       ili.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
       ili.Charge_Amount__c = -1;
       ili.Subscription__c = subscription.Id;
       ili.Invoice_ID__c = zinv.Zuora__Zuora_Id__c;
       ili.Applied_To_Invoice_Item_ID__c = null;
       ili.Charge_Name__c = 'LineItem';
       ili.Tax_Amount__c = 100;
       ili.Tax_Exempt_Amount__c = 200;
       insert ili;
       
       Invoice_Line_Item__c ili2 = new Invoice_Line_Item__c();
       ili2.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
       ili2.Charge_Amount__c = 100;
       ili2.Subscription__c = subscription.Id;
       //ili2.Invoice_ID__c = zinv.Zuora__Zuora_Id__c;
       ili2.Applied_To_Invoice_Item_ID__c = null;
       ili2.Charge_Name__c = 'LineItem';
       ili2.Tax_Amount__c = 100;
       ili2.Tax_Exempt_Amount__c = 200;
       insert ili2;
       
       Invoice_Line_Item__c ili3 = new Invoice_Line_Item__c();
       ili3.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
       ili3.Charge_Amount__c = 100;
       ili3.Subscription__c = subscription.Id;
       //ili3.Invoice_ID__c = zinv.Zuora__Zuora_Id__c;
       ili3.Applied_To_Invoice_Item_ID__c = null;
       ili3.Charge_Name__c = 'LineItem';
       ili3.Tax_Amount__c = 100;
       ili3.Tax_Exempt_Amount__c = 200;
       insert ili3;
     
       iliList.add(ili);
       iliList.add(ili2);
       iliList.add(ili3);
       //system.assertEquals(null, ili.Applied_To_Invoice_Item_ID__c);
       
       Zuora__SubscriptionProductCharge__c subsProd = testDataFactory.createSubscriptionProductCharge(1)[0];
       subsProd.Zuora__UOM__c = 'LANDED'; 
       subsProd.Zuora__Subscription__c = subscription.Id;
       insert subsProd; 
       
       List<Credit_Note__c> creditList = new List<Credit_Note__c>();
       Credit_Note__c credit = new Credit_Note__c();
       credit.Billing_Account__c = billAcc.Id;
       credit.Document_Date__c = date.today();
       credit.Source_Invoice__c = null;      
       insert credit;
       creditList.add(credit);
          
       set<Id> invset = new set<Id>();
       invset.add(zinv.Id);
           
    Test.startTest();
    
    SP_CreateCreditNoteBatch batch = new SP_CreateCreditNoteBatch(invset);
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        
    Test.stopTest();
    }
    
    static testmethod void unitTest4() { 
        
        Account acct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acct.NRIC__c = 'T1234567R';
        insert acct;    
        
       Address__c add = TestDataFactory.createAddress(1)[0];
       add.Address_Unique_ID__c = '123152test';
       insert add; 
        
       Contact con = TestDataFactory.createContact(1)[0];
       con.AccountId = acct.Id;
       con.Recipient_Indicator__c = true;
       con.Recipient_Number__c = 123456;
       con.Address__c = add.Id;
       con.LastName = 'Last Name';
       con.FirstName = 'First Name';
       con.Phone = '1234567';
       con.Mobile_Number__c = '09155568874'; 
       con.Mobile_Number_2__c = '09112234567';       
       insert con;
       
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       //billAcc.Zuora__AccountNumber__c = 'z123sgd';
       billAcc.Zuora__Account__c = acct.Id;
       billAcc.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_MR_POST;
       insert billAcc;
        
       Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
       subscription.Zuora__Zuora_Id__c  = '123456789';
       subscription.Zuora__Account__c = acct.Id;
       subscription.Recipient_Contact__c = con.Id;
       subscription.Recipient_Contact_1__c = con.Id;
       subscription.Subscription_Type_1__c =  'DELIVERY';
       subscription.Subscription_Type__c = 'DELIVERY';
       subscription.Zuora__CustomerAccount__c = billAcc.Id;
       subscription.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
       subscription.Zuora__SubscriptionStartDate__c = date.today().addDays(21).toStartOfMonth();
       subscription.New_Contract_Period_1__c = 1;
       subscription.Contract_End_Date_1__c = date.Today();
       subscription.Zuora__Status__c = 'Active';
       subscription.Zuora__SubscriptionEndDate__c = null;
       insert subscription; 
       
       Zuora__ZInvoice__c zinv = TestDataFactory.createInvoice(1)[0];
       zinv.Zuora__TotalAmount__c = -1;
       zinv.InvoicePaymentFailure__c = 'Y';
       zinv.Is_CN_Processed__c = false;
       zinv.Zuora__Status__c = 'cancelText';
       zinv.Zuora__AdjustmentAmount__c = 0;
       zinv.Zuora__Zuora_Id__c = '123456789';
       zinv.Zuora__ZuoraId__c = '123456789';
       zinv.Zuora__BillingAccount__c = billAcc.Id;
       zinv.Zuora__TaxAmount__c = 100;
       zinv.Zuora__AmountWithoutTax__c = 300;
       zinv.Zuora__TaxExemptAmount__c = 200;
       insert zinv;
       
       List<Invoice_Line_Item__c> iliList = new List<Invoice_Line_Item__c>();
       Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
       ili.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
       ili.Charge_Amount__c = -1;
       ili.Subscription__c = subscription.Id;
       ili.Invoice_ID__c = zinv.Zuora__Zuora_Id__c;
       ili.Applied_To_Invoice_Item_ID__c = null;
       ili.Charge_Name__c = 'LineItem';
       ili.Tax_Amount__c = 100;
       ili.Tax_Exempt_Amount__c = 200;
       insert ili;
       
       Invoice_Line_Item__c ili2 = new Invoice_Line_Item__c();
       ili2.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
       ili2.Charge_Amount__c = 100;
       ili2.Subscription__c = subscription.Id;
       //ili2.Invoice_ID__c = zinv.Zuora__Zuora_Id__c;
       ili2.Applied_To_Invoice_Item_ID__c = null;
       ili2.Charge_Name__c = 'LineItem';
       ili2.Tax_Amount__c = 100;
       ili2.Tax_Exempt_Amount__c = 200;
       insert ili2;
       
       Invoice_Line_Item__c ili3 = new Invoice_Line_Item__c();
       ili3.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
       ili3.Charge_Amount__c = 100;
       ili3.Subscription__c = subscription.Id;
       //ili3.Invoice_ID__c = zinv.Zuora__Zuora_Id__c;
       ili3.Applied_To_Invoice_Item_ID__c = null;
       ili3.Charge_Name__c = 'LineItem';
       ili3.Tax_Amount__c = 100;
       ili3.Tax_Exempt_Amount__c = 200;
       insert ili3;
     
       iliList.add(ili);
       iliList.add(ili2);
       iliList.add(ili3);
       //system.assertEquals(null, ili.Applied_To_Invoice_Item_ID__c);
       
       Zuora__SubscriptionProductCharge__c subsProd = testDataFactory.createSubscriptionProductCharge(1)[0];
       subsProd.Zuora__UOM__c = 'LANDED'; 
       subsProd.Zuora__Subscription__c = subscription.Id;
       insert subsProd; 
       
       List<Credit_Note__c> creditList = new List<Credit_Note__c>();
       Credit_Note__c credit = new Credit_Note__c();
       credit.Billing_Account__c = billAcc.Id;
       credit.Document_Date__c = date.today();
       credit.Source_Invoice__c = null;      
       insert credit;
       creditList.add(credit);
          
       set<Id> invset = new set<Id>();
       invset.add(zinv.Id);
           
    Test.startTest();
    
    SP_CreateCreditNoteBatch batch = new SP_CreateCreditNoteBatch(invset);
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        
    Test.stopTest();
    }
    static testmethod void unitTest5() { 
        
        Account acct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acct.NRIC__c = 'T1234567R';
        insert acct;    
        
       Address__c add = TestDataFactory.createAddress(1)[0];
       add.Address_Unique_ID__c = '123152test';
       insert add; 
        
       Contact con = TestDataFactory.createContact(1)[0];
       con.AccountId = acct.Id;
       con.Recipient_Indicator__c = true;
       con.Recipient_Number__c = 123456;
       con.Address__c = add.Id;
       con.LastName = 'Last Name';
       con.FirstName = 'First Name';
       con.Phone = '1234567';
       con.Mobile_Number__c = '09155568874'; 
       con.Mobile_Number_2__c = '09112234567';       
       insert con;
       
       Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
       //billAcc.Zuora__AccountNumber__c = 'z123sgd';
       billAcc.Zuora__Account__c = acct.Id;
       billAcc.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_MR_POST;
       insert billAcc;
        
       Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
       subscription.Zuora__Zuora_Id__c  = '123456789';
       subscription.Zuora__Account__c = acct.Id;
       subscription.Recipient_Contact__c = con.Id;
       subscription.Recipient_Contact_1__c = con.Id;
       subscription.Subscription_Type_1__c =  'DELIVERY';
       subscription.Subscription_Type__c = 'DELIVERY';
       subscription.Zuora__CustomerAccount__c = billAcc.Id;
       subscription.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
       subscription.Zuora__SubscriptionStartDate__c = date.today().addDays(21).toStartOfMonth();
       subscription.New_Contract_Period_1__c = 1;
       subscription.Contract_End_Date_1__c = date.Today();
       subscription.Zuora__Status__c = 'Active';
       subscription.Zuora__SubscriptionEndDate__c = null;
       insert subscription; 
       
       Zuora__ZInvoice__c zinv = TestDataFactory.createInvoice(1)[0];
       zinv.Zuora__TotalAmount__c = -1;
       zinv.InvoicePaymentFailure__c = 'Y';
       zinv.Is_CN_Processed__c = false;
       zinv.Zuora__Status__c = 'cancelText';
       zinv.Zuora__AdjustmentAmount__c = 0;
       zinv.Zuora__Zuora_Id__c = '123456789';
       zinv.Zuora__ZuoraId__c = '123456789';
       zinv.Zuora__BillingAccount__c = billAcc.Id;
       zinv.Zuora__TaxAmount__c = 100;
       zinv.Zuora__AmountWithoutTax__c = 300;
       zinv.Zuora__TaxExemptAmount__c = 200;
       insert zinv;
       
       List<Invoice_Line_Item__c> iliList = new List<Invoice_Line_Item__c>();
       Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
       ili.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
       ili.Charge_Amount__c = -1;
       ili.Subscription__c = subscription.Id;
       ili.Invoice_ID__c = zinv.Zuora__Zuora_Id__c;
       ili.Applied_To_Invoice_Item_ID__c = null;
       ili.Charge_Name__c = 'LineItem';
       ili.Tax_Amount__c = 100;
       ili.Tax_Exempt_Amount__c = 200;
       insert ili;
       
       Invoice_Line_Item__c ili2 = new Invoice_Line_Item__c();
       ili2.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
       ili2.Charge_Amount__c = 100;
       ili2.Subscription__c = subscription.Id;
       //ili2.Invoice_ID__c = zinv.Zuora__Zuora_Id__c;
       ili2.Applied_To_Invoice_Item_ID__c = null;
       ili2.Charge_Name__c = 'LineItem';
       ili2.Tax_Amount__c = 100;
       ili2.Tax_Exempt_Amount__c = 200;
       insert ili2;
       
       Invoice_Line_Item__c ili3 = new Invoice_Line_Item__c();
       ili3.Subscription_ID__c = subscription.Zuora__Zuora_Id__c;
       ili3.Charge_Amount__c = 100;
       ili3.Subscription__c = subscription.Id;
       //ili3.Invoice_ID__c = zinv.Zuora__Zuora_Id__c;
       ili3.Applied_To_Invoice_Item_ID__c = null;
       ili3.Charge_Name__c = 'LineItem';
       ili3.Tax_Amount__c = 100;
       ili3.Tax_Exempt_Amount__c = 200;
       insert ili3;
     
       iliList.add(ili);
       iliList.add(ili2);
       iliList.add(ili3);
       //system.assertEquals(null, ili.Applied_To_Invoice_Item_ID__c);
       
       Zuora__SubscriptionProductCharge__c subsProd = testDataFactory.createSubscriptionProductCharge(1)[0];
       subsProd.Zuora__UOM__c = 'LANDED'; 
       subsProd.Zuora__Subscription__c = subscription.Id;
       insert subsProd; 
       
       List<Credit_Note__c> creditList = new List<Credit_Note__c>();
       Credit_Note__c credit = new Credit_Note__c();
       credit.Billing_Account__c = billAcc.Id;
       credit.Document_Date__c = date.today();
       credit.Source_Invoice__c = null;      
       insert credit;
       creditList.add(credit);
       
       List<Credit_Note_Item__c> creditItemList = new List<Credit_Note_Item__c>();
       Credit_Note_Item__c creditItem = new Credit_Note_Item__c();
       creditItem.Credit_Note__c = credit.Id;
       //credit.Document_Date__c = date.today();
       //credit.Source_Invoice__c = null;      
       insert creditItem;
       creditItemList.add(creditItem);
          
       set<Id> invset = new set<Id>();
       invset.add(zinv.Id);
           
    Test.startTest();
    
    SP_CreateCreditNoteBatch batch = new SP_CreateCreditNoteBatch(invset);
        ID batchprocessid = Database.executeBatch(batch, 200); 
        System.assertNotEquals(null, batchprocessid);
        
    Test.stopTest();
    }
}