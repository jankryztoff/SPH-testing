@isTest
private class SP_CreateDailyInvoiceBatchTest{

    static testmethod void testStart() {
    
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        accounts[0].Vendor_Group__c = 'A';
        accounts[0].AccountNumber = 'accnt number';
        insert accounts;

        Zuora__CustomerAccount__c billAccount = TestDataFactory.createBillingAccount(1)[0]; 
        billAccount.Zuora__DefaultPaymentMethod__c = 'Other'; 
        billAccount.Zuora__Account__c = accounts[0].id; 
        billAccount.Zuora__LastInvoiceDate__c = Date.today();
        billAccount.Billing_Type__c = 'Full Prepaid';
        insert billAccount;
        
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(1);
        invoice[0].Zuora__BillingAccount__c = billAccount.id;
        invoice[0].Zuora__InvoiceDate__c = Date.today();
        invoice[0].Zuora__TotalAmount__c = -1;
        invoice[0].Zuora__Balance2__c = 10;
        invoice[0].Zuora__TaxExemptAmount__c = 2;
        invoice[0].Zuora__PaymentAmount__c = 1;
        invoice[0].Zuora__TaxAmount__c = 1;
        invoice[0].Previous_Balance__c = '0';        
        insert invoice;
        
        /*Daily_Invoice__c dInv = new Daily_Invoice__c();
        dInv.Billing_Account__c = billAccount.id;
        dInv.Invoice_Date__c = Date.today();
        dInv.Total_Amt__c = 10;
        insert dInv;*/
        

        Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
        invLineItem.Invoice_ID__c = invoice[0].id;
        invLineItem.Charge_Amount__c = 1;
        invLineItem.Applied_To_Invoice_Item_ID__c = null;
        insert invLineItem;
        Set<String> baNames = new Set<String>();
        baNames.add(billAccount.Name);
        Test.startTest();
        SP_CreateDailyInvoiceBatch batch = new SP_CreateDailyInvoiceBatch();     
        Database.executeBatch(batch,200);
        SP_CreateDailyInvoiceBatch batchB = new SP_CreateDailyInvoiceBatch(Date.today(), baNames);     
        Database.executeBatch(batchB,200);
        Test.stopTest();
        
    
    }
    
    static testmethod void testStartB() {
    
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        accounts[0].Vendor_Group__c = 'A';
        accounts[0].AccountNumber = 'accnt number';
        insert accounts;

        Zuora__CustomerAccount__c billAccount = TestDataFactory.createBillingAccount(1)[0]; 
        billAccount.Zuora__DefaultPaymentMethod__c = 'Other'; 
        billAccount.Zuora__Account__c = accounts[0].id; 
        billAccount.Zuora__LastInvoiceDate__c = Date.today();
        billAccount.Billing_Type__c = 'Full Prepaid';
        insert billAccount;
        
        List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(1);
        invoice[0].Zuora__BillingAccount__c = billAccount.id;
        invoice[0].Zuora__InvoiceDate__c = Date.today();
        invoice[0].Zuora__TotalAmount__c = 10;
        invoice[0].Zuora__Balance2__c = 10;
        invoice[0].Zuora__TaxExemptAmount__c = 2;
        invoice[0].Zuora__PaymentAmount__c = 1;
        invoice[0].Zuora__TaxAmount__c = 1;
        invoice[0].Previous_Balance__c = '0';        
        insert invoice;
        
        Daily_Invoice__c dInv = new Daily_Invoice__c();
        dInv.Billing_Account__c = billAccount.id;
        dInv.Invoice_Date__c = Date.today();
        dInv.Total_Amt__c = 10;
        insert dInv;
        
        Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
        invLineItem.Invoice_ID__c = String.valueof(invoice[0].id);
        invLineItem.Charge_Amount__c = 1;
        invLineItem.Applied_To_Invoice_Item_ID__c = null;
        insert invLineItem;
        
        Set<String> baNames = new Set<String>();
        baNames.add(billAccount.Name);
        
        Test.startTest();
        
        SP_CreateDailyInvoiceBatch batch = new SP_CreateDailyInvoiceBatch(Date.today());
        Database.executeBatch(batch,200);
        
        SP_CreateDailyInvoiceBatch batch2= new SP_CreateDailyInvoiceBatch(Date.today(), baNames);
        Database.executeBatch(batch2,200);
        
        Test.stopTest();
        
    
    }


}