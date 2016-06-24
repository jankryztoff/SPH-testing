@isTest
private class BT_AB_ARM105DX_ExportInvoiceTest{


/*
 * Class Name: BT_AB_ARM105DX_ExportInvoiceTest
 * Date: 17 May 2017
 * Project/Requirement: Test class for BT_AB_ARM105DX_ExportInvoice
 */

    @testSetup
    static void setupData() {
        
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createBatchInterface();
        insert CustomSettingsDataFactory.createBillingBatch();
    }

    static testMethod void method1(){
        //custom settings

        BatchInterface_Settings__c biSettings = new BatchInterface_Settings__c();
        biSettings.Name = 'Endpoint Delegator';
        biSettings.Value__c = 'http://tstcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';

        insert biSettings;

        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;

        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;

        Account acc = TestDataFactory.createAccount(1, 'Direct Invidual')[0];
        acc.Attention_To_Care_Of_Indicator__c = 'C';
        insert acc;
        
        Id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();

        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = acc.Id;
        con.Phone = '1234567';
        con.Address__c = addressRec.Id; 
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        billAcc.Billing_Contact__c = con.id;
        billAcc.Billing_Type__c = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcc.AGD_Unit__c = '1';
        billAcc.Zuora__Balance__c = 200;
        insert billAcc;

        zqu__ZProduct__c zProduct = new zqu__ZProduct__c();
        zProduct.Name ='zProduct Test';
        zProduct.zqu__ZuoraId__c = ResponseUtility.generateExternalId();
        zProduct.ProductCode__c = 'HWB';
        zProduct.ProductType__c = 'Product';
        zProduct.ProductSubType__c = 'Newspaper';
        zProduct.zqu__SKU__c = 'SKU-00000176';
        insert zProduct;
        
        Daily_Invoice__c dailyInvoice = new Daily_Invoice__c();
        dailyInvoice.ARMS_Invoice_ID__c = '0271231';
        dailyInvoice.Invoice_Date__c = Date.today();
        dailyInvoice.Total_Amt__c = 123.12;
        dailyInvoice.Billing_Account__c = billAcc.Id;
        dailyInvoice.To_ARMS_Time__c = Date.Today();
        dailyInvoice.Prev_Bal__c = 100;
        
        insert dailyInvoice;

        Zuora__Subscription__c subscription = TestDataFactory.createSubscription(1)[0];
        subscription.Recipient_Contact__c = con.Id;
        subscription.Zuora__Status__c = 'Active';
        subscription.Zuora__Account__c = acc.Id;
        subscription.Zuora__CustomerAccount__c =billAcc.Id;
        SubscriptionTriggerHandler.preventExecution = true;
        insert subscription;

        Zuora__ZInvoice__c zInvoice = TestDataFactory.createInvoice(1)[0];
        zInvoice.Zuora__External_Id__c = ResponseUtility.generateExternalId();
        zInvoice.Zuora__BillingAccount__c = billAcc.Id;
        zInvoice.Zuora__Account__c = acc.Id;
        zInvoice.Daily_Invoice__c = dailyInvoice.Id;
        zInvoice.Zuora__Description__c = 'test';
        zInvoice.Zuora__InvoiceDate__c = Date.today();
        zInvoice.Zuora__TaxAmount__c = 1;
        zInvoice.Zuora__TotalAmount__c = 123;
        zInvoice.Zuora__AmountWithoutTax__c = 122;
        zInvoice.Previous_Balance__c = '300';
        zInvoice.Zuora__PaymentAmount__c= 5;
        zInvoice.ARMS_invoice_id__c = ResponseUtility.generateExternalId().substring(0, 10);
        insert zInvoice;

        Invoice_Line_Item__c newInvoice = new Invoice_Line_Item__c();
        newInvoice.Invoice_ID__c = dailyInvoice.Id;
        newInvoice.Unit_Price__c = 1;
        newInvoice.Quantity__c = 1;
        newInvoice.Tax_Amount__c = 1;
        newInvoice.Charge_Amount__c = 1;
        newInvoice.Charge_Description__c = 'test';
        newInvoice.Charge_Name__c = 'test';
        newInvoice.Product_Name__c = 'Postage Charge';
        newInvoice.Product_ID__c = zProduct.zqu__ZuoraId__c;
        newInvoice.Subscription__c = subscription.Id;
        newInvoice.Invoice_ID__c = zInvoice.Zuora__External_Id__c;
        insert newInvoice;
        
        List<Daily_Invoice__c> dIList = new List<Daily_Invoice__c>();
        dIList.add(dailyInvoice);

        Test.startTest();
        BT_AB_ARM105DX_ExportInvoice edi = new BT_AB_ARM105DX_ExportInvoice();
        database.executeBatch(edi, 20);
        Test.stopTest();
    }

}