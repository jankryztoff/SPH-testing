@isTest                   
public class BT_CO_ARMS_ExportCustomerInvoiceTest{
static testMethod void invoiceAccountTest()
    {
        
        Integer i;   
   
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeID = '012N00000008icG';
        try{
        insert acc;   
        }catch(exception e){}
        Zuora__CustomerAccount__c a = new Zuora__CustomerAccount__c();
        a.Name = 'Test Billing Account'+i;
        a.Zuora__Account__c = acc.id;
        a.ARMS_Account_Number__c = '123456';
        a.ARMS_Customer_Number__c = '5678';
        try{
        insert a;  
        }catch(exception e){}
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = '1234';
        inv.Zuora__Account__c = acc.id;
        inv.Zuora__BillingAccount__c = a.id;
        insert inv;
        
        BT_CO_ARMS_ExportCustomerInvoice__c expinv1 = new BT_CO_ARMS_ExportCustomerInvoice__c ();
        expinv1.Name = '567388';
        expinv1.invoiceNumber__c = '1234';  
        expinv1.accountNumber__c = '123456';
        expinv1.invoiceDate__c = '20140303';
        expinv1.invoiceDueDate__c = '20140506';
        expinv1.synonym__c = '5678';
        //expinv1.Validation_Status__c = 'Passed';
        expinv1.invoiceAmount__c = '5433.25';
        expinv1.invoiceOutstandingAmount__c = '2000.00' ;
        insert expinv1 ;     
        
        
       
        BT_CO_ARMS_ExportCustomerInvoice__c expinv2 = new BT_CO_ARMS_ExportCustomerInvoice__c ();
        expinv2.Name = '547';
        expinv2.invoiceNumber__c = '1734';
        expinv2.accountNumber__c = '12456';   
       // expinv2.Validation_Status__c = 'Passed';
        insert expinv2 ;
        
        
    
    BT_CO_ARMS_ExportCustomerInvoice__c recordUpdate = [select invoiceNumber__c from BT_CO_ARMS_ExportCustomerInvoice__c  where Name = :'567388'];
    recordUpdate.invoiceNumber__c = '2023';
    update recordUpdate;
    
        
        
        
        
  
    
    
    
    
    
        
   
    
    }
    }