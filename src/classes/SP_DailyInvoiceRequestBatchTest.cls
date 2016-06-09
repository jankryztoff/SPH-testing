@isTest// (seeAllData = True)
private class SP_DailyInvoiceRequestBatchTest{
    
    @testSetup 
    static void setupData() {
        /*
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        
        */
       
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
		insert CustomSettingsDataFactory.createBatchInterface(); 
        insert CustomSettingsDataFactory.createBatchConfig();
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createCharge();
        insert CustomSettingsDataFactory.createChargeType();
        insert CustomSettingsDataFactory.createZuora_HPM_Settings();
        insert CustomSettingsDataFactory.createError_Messages();
        insert CustomSettingsDataFactory.createARMSInterface();
        insert CustomSettingsDataFactory.createUom();
        insert CustomSettingsDataFactory.createUnit_of_Measure();
		insert CustomSettingsDataFactory.createBillingBatch();
		insert CustomSettingsDataFactory.createDateConfig();
    } 
    
    static testmethod void testStart() {
    
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        accounts[0].Vendor_Group__c = 'A';
        accounts[0].AccountNumber = 'accnt number';
		accounts[0].GST_Invoice__c = 'Yes';
        insert accounts;
		
		Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;

        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
		
		Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = accounts[0].Id;
        con.Phone = '1234567';
        con.Address__c = addressRec.Id; 
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;	
		
		Zuora__CustomerAccount__c billAccount = TestDataFactory.createBillingAccount(1)[0]; 
        billAccount.Zuora__DefaultPaymentMethod__c = 'Other'; 
        billAccount.Zuora__Account__c = accounts[0].id; 
        billAccount.Zuora__LastInvoiceDate__c = Date.today();
        billAccount.Billing_Type__c = 'Full Prepaid';
        insert billAccount;
			
        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Recipient_Contact__c = con.Id;
        subscription.Zuora__Status__c = 'Active';
        subscription.Zuora__Account__c = accounts[0].Id;
        subscription.Zuora__CustomerAccount__c =billAccount.Id;
        insert subscription;

        Daily_Invoice__c dInv = new Daily_Invoice__c();
        dInv.Billing_Account__c = billAccount.id;
        dInv.Invoice_Date__c = Date.today();
        dInv.Total_Amt__c = 10;
		dInv.Is_PDF_Generated__c  = false;
        insert dInv;
        
		List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(1);
        invoice[0].Zuora__BillingAccount__c = billAccount.id;
        invoice[0].Zuora__InvoiceDate__c = Date.today();
        invoice[0].Zuora__TotalAmount__c = 2.14;
        invoice[0].Zuora__Balance2__c = 10;
        invoice[0].Zuora__TaxExemptAmount__c = 0;
        invoice[0].Zuora__PaymentAmount__c = 1;
        invoice[0].Zuora__TaxAmount__c = 0.14;
        invoice[0].Previous_Balance__c = '0';        
        invoice[0].Daily_Invoice__c = dInv.Id;
		invoice[0].Zuora__Zuora_Id__c = '1234567890';
		insert invoice;
		
        Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
        invLineItem.Invoice_ID__c = '1234567890';
        invLineItem.Charge_Amount__c = 1;
		invLineItem.Tax_Amount__c = 0.07;
        invLineItem.Applied_To_Invoice_Item_ID__c = null;
		invLineItem.subscription__c = subscription.id;
		invLineItem.Subscription_Number__c = subscription.Name;
		invLineItem.UOM__c = 'Credit Copy Weekday';
        insert invLineItem;
		
		Invoice_Line_Item__c invLineItem2 = new Invoice_Line_Item__c();
        invLineItem2.Invoice_ID__c = '1234567890';
        invLineItem2.Charge_Amount__c = 1;
		invLineItem2.Tax_Amount__c = 0.07;
        invLineItem2.Applied_To_Invoice_Item_ID__c = null;
		invLineItem2.subscription__c = subscription.id;
		invLineItem2.Subscription_Number__c = subscription.Name;
		invLineItem.UOM__c = 'Credit Copy Sat';
        insert invLineItem2;
        
        Test.startTest();
        SP_DailyInvoiceRequestBatch batch = new SP_DailyInvoiceRequestBatch('Daily_Inv_Letter',5,'', false);   
        Database.executeBatch(batch,200);
		
        Test.stopTest();
        
    
    }
    
    static testmethod void testStartB() {
    
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        accounts[0].Vendor_Group__c = 'A';
        accounts[0].AccountNumber = 'accnt number';
        insert accounts;

		Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;

        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
		
		Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = accounts[0].Id;
        con.Phone = '1234567';
        con.Address__c = addressRec.Id; 
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;	
		
		
        Zuora__CustomerAccount__c billAccount = TestDataFactory.createBillingAccount(1)[0]; 
        billAccount.Zuora__DefaultPaymentMethod__c = 'Other'; 
		billAccount.Other_PaymentMethod__c = 'Invoice';
        billAccount.Zuora__Account__c = accounts[0].id; 
        billAccount.Zuora__LastInvoiceDate__c = Date.today();
        billAccount.Billing_Type__c = 'Full Prepaid';
        insert billAccount;
        
		Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Recipient_Contact__c = con.Id;
        subscription.Zuora__Status__c = 'Active';
        subscription.Zuora__Account__c = accounts[0].Id;
        subscription.Zuora__CustomerAccount__c =billAccount.Id;
        insert subscription;
        
        Daily_Invoice__c dInv = new Daily_Invoice__c();
        dInv.Billing_Account__c = billAccount.id;
        dInv.Invoice_Date__c = Date.today();
        dInv.Total_Amt__c = 10;
		dInv.Is_PDF_Generated__c  = false;
        insert dInv;
        
		List<Zuora__ZInvoice__c> invoice = TestDataFactory.createInvoice(1);
        invoice[0].Zuora__BillingAccount__c = billAccount.id;
        invoice[0].Zuora__InvoiceDate__c = Date.today();
        invoice[0].Zuora__TotalAmount__c = 2.14;
        invoice[0].Zuora__Balance2__c = 10;
        invoice[0].Zuora__TaxExemptAmount__c = 0;
        invoice[0].Zuora__PaymentAmount__c = 1;
        invoice[0].Zuora__TaxAmount__c = 0.14;
        invoice[0].Previous_Balance__c = '0';        
        invoice[0].Daily_Invoice__c = dInv.Id;
		invoice[0].Zuora__Zuora_Id__c = '1234567890';
		insert invoice;
		
        Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
        invLineItem.Invoice_ID__c = '1234567890';
        invLineItem.Charge_Amount__c = 1;
		invLineItem.Tax_Amount__c = 0.07;
        invLineItem.Applied_To_Invoice_Item_ID__c = null;
		invLineItem.subscription__c = subscription.id;
		invLineItem.Subscription_Number__c = subscription.Name;
		invLineItem.UOM__c = 'Credit Copy Weekday';
        insert invLineItem;
		
		Invoice_Line_Item__c invLineItem2 = new Invoice_Line_Item__c();
        invLineItem2.Invoice_ID__c = '1234567890';
        invLineItem2.Charge_Amount__c = 1;
		invLineItem2.Tax_Amount__c = 0.07;
        invLineItem2.Applied_To_Invoice_Item_ID__c = null;
		invLineItem2.subscription__c = subscription.id;
		invLineItem2.Subscription_Number__c = subscription.Name;
		invLineItem.UOM__c = 'Credit Copy Sat';
        insert invLineItem2;
        
        set<id> dailyInvID = new set<id>();
        dailyInvID.add(dInv.id);

        Set<String> baNames = new Set<String>();
        baNames.add(billAccount.Name);
        
        Test.startTest();
        SP_DailyInvoiceRequestBatch batch= new SP_DailyInvoiceRequestBatch('Daily_Inv_Letter',5,'', dailyInvID);
        SP_DailyInvoiceRequestBatch batch2 = new SP_DailyInvoiceRequestBatch('Daily_Inv_Letter',5,'', false);
        Database.executeBatch(batch,200);
        Database.executeBatch(batch2,200);
        Test.stopTest();
        
    
    }


}