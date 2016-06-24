/*
 * Class Name: BT_AB_AGD106DX_ExportDailyInvoiceTest
 * Date: 17 May 2017
 * Project/Requirement: Test class for BT_AB_AGD106DX_ExportDailyInvoice
 */
@isTest (SeeAllData=true)
private class BT_AB_AGD106DX_ExportDailyInvoiceTest{

	private static testMethod void exportDailyInvoiceTest(){

		setTestData();

        Test.startTest();
        BT_AB_AGD106DX_ExportDailyInvoice edi = new BT_AB_AGD106DX_ExportDailyInvoice();
        Database.executeBatch(edi);
        Test.stopTest();

        List<BA_INT_DATA_POOL__c> dataPoolList = [SELECT Name,Id FROM BA_INT_DATA_POOL__c WHERE Name = 'AGD106DX'];
        System.assert(dataPoolList.size() > 0);
	}



	private static void setTestData(){
		Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct Corporate').getRecordTypeId();
		Id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();

    	Account acc = new Account(Name = 'Test Account',
							Email__c = 'testcrsm@sph.crsm',
		                  	RecordTypeId = accRecTypeId,
		                  	Attention_To_Care_Of_Indicator__c = 'A'); 
    	insert acc;

    	Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;

		Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = conRecTypeId;
        con.Recipient_Indicator__c = true;
        insert con;
        
		Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Billing_Contact__c = con.id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.AGD_Unit__c = '1';
        insert billAcc;

		Package__c pkg = TestDataFactory.createPackage(1)[0];
        pkg.Subscription_Period__c = '15';            
        insert pkg;

		Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Recipient_Contact__c = con.Id;
        order.Informed_Customer__c = True;
        order.Subscriber_charge__c = 100;
        insert order;

        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0]; 
        oli.Order__c = order.Id; 
        oli.Main_Package_ID__c = pkg.id;
		insert oli;						

		Daily_Invoice__c dailyInvoice = new Daily_Invoice__c();
		dailyInvoice.ARMS_Invoice_ID__c = '0271231';
		dailyInvoice.Invoice_Date__c = Date.today();
		dailyInvoice.Total_Amt__c = 123.12;
		dailyInvoice.Billing_Account__c = billAcc.Id;
		dailyInvoice.To_ARMS_Time__c = null;
		dailyInvoice.Tax_Amt__c = 2;
		insert dailyInvoice;

		Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
		subscription.Zuora__Status__c = 'Active';
		subscription.Zuora__Account__c = acc.Id;
		subscription.Zuora__CustomerAccount__c =billAcc.Id;
        subscription.Order_Line_Item_Number__c = oli.Id;
        subscription.Order_Number__c = order.Id;
        subscription.Recipient_Contact__c = con.Id;
		insert subscription;

        Invoice_Line_Item__c newInvoice = new Invoice_Line_Item__c();
        newInvoice.Unit_Price__c = 1;
        newInvoice.Quantity__c = 1;
        newInvoice.Tax_Amount__c = 1;
        newInvoice.Charge_Amount__c = 1;
        newInvoice.Charge_Description__c = 'test';
        newInvoice.Charge_Name__c = 'test';
        newInvoice.Product_Name__c = 'Postage Charge';
        newInvoice.Subscription__c = subscription.Id;
        newInvoice.Invoice_ID__c = '12314123987adf03kjsdf';
        insert newInvoice;

        Zuora__ZInvoice__c zInvoice = TestDataFactory.createInvoice(1)[0];
        zInvoice.Zuora__External_Id__c = '12314123987adf03kjsdf';
        zInvoice.Zuora__BillingAccount__c = billAcc.Id;
        zInvoice.Zuora__Account__c = acc.Id;
        zInvoice.Daily_Invoice__c = dailyInvoice.Id;
        zInvoice.Zuora__Description__c = 'test';
        zInvoice.Zuora__InvoiceDate__c = Date.today();
        zInvoice.Zuora__TaxAmount__c = 1;
        zInvoice.Zuora__TotalAmount__c = 123;
        zInvoice.Zuora__AmountWithoutTax__c = 122;

        insert zInvoice;
	}


}