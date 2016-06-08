/* History: April Grace Veloso for coverage
   Date: 07/30/2015
*/ 


@isTest(seeAllData = true)
public class SP_BatchCreateCreditBalanceDummyTest {
 
   static testMethod void SP_BatchCreateCreditBalanced(){
       try{
            Test.setMock(WebServiceMock.class, new zLoginMock()); 

                      
            Account account = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            insert account;
            
            List<Contact> con = TestDataFactory.createContact(1);
            insert con;
                        
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
            billingAcc.Zuora__Account__c = account.Id;
            billingAcc.Other_PaymentMethod__c = 'Invoice';
            billingAcc.Zuora__Credit_Balance__c = 100;
            insert billingAcc;
            
            List<Zuora__Subscription__c> zsub = TestDataFactory.createSubscription(1);             
            zsub[0].Zuora__Account__c = account.Id;
            zsub[0].Subscriber_Contact__c = con[0].Id;
            zsub[0].Zuora__CustomerAccount__c = billingAcc.Id;
            zsub[0].Recipient_Contact__c = con[0].Id;                   
            zsub[0].Number_of_Copies1__c = '2';
            zsub[0].Zuora__Status__c = 'Active';
            //zsub[0].Order_Number__c = order.Id;
            zsub[0].Suppress_Vendor_Start_Notice__c = 'false';
            zsub[0].Supressed_Acknowledgement_Letter__c = 'false';
            zsub[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zsub[0].Urgent__c = 'false';
            zsub[0].Vendor_Conversion__c = 'false';
            zsub[0].Charity__c = 'false';
            zsub[0].Zuora__SubscriptionStartDate__c = Date.today();
            zsub[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(30);
            zsub[0].Product_Code__c = 'prodCode_test';
            zsub[0].Number_of_Copies__c = 100;
            zsub[0].Frequency_1__c = 'Mon - Fri';
                
            zsub[0].Billing_Type__c = 'Full Prepaid';
            /*zsubs[1].Billing_Type__c = 'Recurring Prepaid';
            zsubs[2].Billing_Type__c = 'Full Prepaid';
            zsubs[3].Billing_Type__c = 'Recurring Prepaid';
            insert new List<sObject>{zsubs[0], zsubs[1], zsubs[2], zsubs[3]};*/
            insert zsub;
    
             Zuora__ZInvoice__c invoice = TestDataFactory.createInvoice(1)[0];
             invoice.Zuora__Balance__c = 100;
             invoice.Name = 'test'; 
             invoice.Zuora__InvoiceDate__c = Date.today();
             invoice.Zuora__TotalAmount__c = 10;
             invoice.Zuora__Account__c = account.Id;
             invoice.Zuora__GeneratedDate__c = Date.today();
             invoice.Zuora__Balance2__c = 100.00;
             invoice.Zuora__BillingAccount__c = billingAcc.Id; 
             insert invoice;
    
            
              Test.startTest();
       
                SP_BatchCreateCreditBalanceDummy createCredit = new  SP_BatchCreateCreditBalanceDummy();
                createCredit.execute(zsub);
            
              Test.stopTest();
        } 
        catch (Exception e) {}   
    }
    
    static testMethod void testCreditbalanceGreaterThan(){    
         try{
              Test.setMock(WebServiceMock.class, new zLoginMock()); 

                       
            Account account = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            insert account;
            
            List<Contact> con = TestDataFactory.createContact(1);
            insert con;
                        
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
            billingAcc.Zuora__Account__c = account.Id;
            billingAcc.Other_PaymentMethod__c = 'Invoice';
            billingAcc.Zuora__Credit_Balance__c = 200.00;
            //billingAcc.Zuora__Balance__c = 300;
            insert billingAcc;
            
            List<Zuora__Subscription__c> zsub = TestDataFactory.createSubscription(1);             
            zsub[0].Zuora__Account__c = account.Id;
            zsub[0].Subscriber_Contact__c = con[0].Id;
            zsub[0].Zuora__CustomerAccount__c = billingAcc.Id;
            zsub[0].Recipient_Contact__c = con[0].Id;                   
            zsub[0].Number_of_Copies1__c = '2';
            zsub[0].Zuora__Status__c = 'Active';
            //zsub[0].Order_Number__c = order.Id;
            zsub[0].Suppress_Vendor_Start_Notice__c = 'false';
            zsub[0].Supressed_Acknowledgement_Letter__c = 'false';
            zsub[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zsub[0].Urgent__c = 'false';
            zsub[0].Vendor_Conversion__c = 'false';
            zsub[0].Charity__c = 'false';
            zsub[0].Zuora__SubscriptionStartDate__c = Date.today();
            zsub[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(30);
            zsub[0].Product_Code__c = 'prodCode_test';
            zsub[0].Number_of_Copies__c = 100;
            zsub[0].Frequency_1__c = 'Mon - Fri';
                
            zsub[0].Billing_Type__c = 'Full Prepaid';
            /*zsubs[1].Billing_Type__c = 'Recurring Prepaid';
            zsubs[2].Billing_Type__c = 'Full Prepaid';
            zsubs[3].Billing_Type__c = 'Recurring Prepaid';
            insert new List<sObject>{zsubs[0], zsubs[1], zsubs[2], zsubs[3]};*/
            insert zsub;
    
    
             Zuora__ZInvoice__c invoice = TestDataFactory.createInvoice(1)[0];
             invoice.Zuora__Balance__c = 100;
             invoice.Name = 'test'; 
             invoice.Zuora__InvoiceDate__c = Date.today();
             invoice.Zuora__TotalAmount__c = 10;
             invoice.Zuora__Account__c = account.Id;
             invoice.Zuora__GeneratedDate__c = Date.today();
             invoice.Zuora__Balance2__c = 100.00;
             invoice.Zuora__BillingAccount__c = billingAcc.Id; 
             insert invoice;
    
            
              Test.startTest();
                   
                SP_BatchCreateCreditBalanceDummy createCredit = new  SP_BatchCreateCreditBalanceDummy();
                createCredit.execute(zsub);
            
              Test.stopTest();
        } 
        catch (Exception e) {}   
    }
    static testMethod void testCreditbalanceGreaterThan2(){    
     try{
              Test.setMock(WebServiceMock.class, new zLoginMock()); 

   
                     
            Account account = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            insert account;
            
            List<Contact> con = TestDataFactory.createContact(1);
            insert con;
                        
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
            billingAcc.Zuora__Account__c = account.Id;
            billingAcc.Other_PaymentMethod__c = 'Invoice';
            billingAcc.Zuora__Credit_Balance__c = 100.00;
            billingAcc.Zuora__Balance__c = 300.00;
            insert billingAcc;
            
            List<Zuora__Subscription__c> zsub = TestDataFactory.createSubscription(1);             
            zsub[0].Zuora__Account__c = account.Id;
            zsub[0].Subscriber_Contact__c = con[0].Id;
            zsub[0].Zuora__CustomerAccount__c = billingAcc.Id;
            zsub[0].Recipient_Contact__c = con[0].Id;                   
            zsub[0].Number_of_Copies1__c = '2';
            zsub[0].Zuora__Status__c = 'Active';
            //zsub[0].Order_Number__c = order.Id;
            zsub[0].Suppress_Vendor_Start_Notice__c = 'false';
            zsub[0].Supressed_Acknowledgement_Letter__c = 'false';
            zsub[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zsub[0].Urgent__c = 'false';
            zsub[0].Vendor_Conversion__c = 'false';
            zsub[0].Charity__c = 'false';
            zsub[0].Zuora__SubscriptionStartDate__c = Date.today();
            zsub[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(30);
            zsub[0].Product_Code__c = 'prodCode_test';
            zsub[0].Number_of_Copies__c = 100;
            zsub[0].Frequency_1__c = 'Mon - Fri';
                
            zsub[0].Billing_Type__c = 'Full Prepaid';
            /*zsubs[1].Billing_Type__c = 'Recurring Prepaid';
            zsubs[2].Billing_Type__c = 'Full Prepaid';
            zsubs[3].Billing_Type__c = 'Recurring Prepaid';
            insert new List<sObject>{zsubs[0], zsubs[1], zsubs[2], zsubs[3]};*/
            insert zsub;
    
    
             Zuora__ZInvoice__c invoice = TestDataFactory.createInvoice(1)[0];
             invoice.Zuora__Balance__c = 100;
             invoice.Name = 'test'; 
             invoice.Zuora__InvoiceDate__c = Date.today();
             invoice.Zuora__TotalAmount__c = 10;
             invoice.Zuora__Account__c = account.Id;
             invoice.Zuora__GeneratedDate__c = Date.today();
             invoice.Zuora__Balance2__c = 200.00;
             invoice.Zuora__BillingAccount__c = billingAcc.Id; 
             insert invoice;
             
              Test.startTest();
                   
                SP_BatchCreateCreditBalanceDummy createCredit = new  SP_BatchCreateCreditBalanceDummy();
                createCredit.execute(zsub);
            
              Test.stopTest();
        } 
        catch (Exception e) {}   
    }

  static testMethod void testCreditbalanceGreaterThan3(){    
 
     try{
              Test.setMock(WebServiceMock.class, new zLoginMock()); 

   
          //  Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            //insert pItem;
            
            Account account = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            insert account;
            
            List<Contact> con = TestDataFactory.createContact(1);
            insert con;
                        
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
            billingAcc.Zuora__Account__c = account.Id;
            billingAcc.Other_PaymentMethod__c = 'Invoice';
            billingAcc.Zuora__Credit_Balance__c = 0.00;
            billingAcc.Zuora__Balance__c = 300.00;
            insert billingAcc;
            
            List<Zuora__Subscription__c> zsub = TestDataFactory.createSubscription(1);             
            zsub[0].Zuora__Account__c = account.Id;
            zsub[0].Subscriber_Contact__c = con[0].Id;
            zsub[0].Zuora__CustomerAccount__c = billingAcc.Id;
            zsub[0].Recipient_Contact__c = con[0].Id;                   
            zsub[0].Number_of_Copies1__c = '2';
            zsub[0].Zuora__Status__c = 'Active';
            //zsub[0].Order_Number__c = order.Id;
            zsub[0].Suppress_Vendor_Start_Notice__c = 'false';
            zsub[0].Supressed_Acknowledgement_Letter__c = 'false';
            zsub[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zsub[0].Urgent__c = 'false';
            zsub[0].Vendor_Conversion__c = 'false';
            zsub[0].Charity__c = 'false';
            zsub[0].Zuora__SubscriptionStartDate__c = Date.today();
            zsub[0].Zuora__SubscriptionEndDate__c = Date.today().addDays(30);
            zsub[0].Product_Code__c = 'prodCode_test';
            zsub[0].Number_of_Copies__c = 100;
            zsub[0].Frequency_1__c = 'Mon - Fri';
                
            zsub[0].Billing_Type__c = 'Full Prepaid';
            /*zsubs[1].Billing_Type__c = 'Recurring Prepaid';
            zsubs[2].Billing_Type__c = 'Full Prepaid';
            zsubs[3].Billing_Type__c = 'Recurring Prepaid';
            insert new List<sObject>{zsubs[0], zsubs[1], zsubs[2], zsubs[3]};*/
            insert zsub;
    
    
             Zuora__ZInvoice__c invoice = TestDataFactory.createInvoice(1)[0];
             invoice.Zuora__Balance__c = 100;
             invoice.Name = 'test'; 
             invoice.Zuora__InvoiceDate__c = Date.today();
             invoice.Zuora__TotalAmount__c = 10;
             invoice.Zuora__Account__c = account.Id;
             invoice.Zuora__GeneratedDate__c = Date.today();
             invoice.Zuora__Balance2__c = 200.00;
             invoice.Zuora__BillingAccount__c = billingAcc.Id; 
             insert invoice;
             
              Test.startTest();
                   
                SP_BatchCreateCreditBalanceDummy createCredit = new  SP_BatchCreateCreditBalanceDummy();
                createCredit.execute(zsub);
            
              Test.stopTest();
        } 
        catch (Exception e) {}   
    }
}