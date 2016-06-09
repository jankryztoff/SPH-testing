@isTest
public class AdjustmentExtensionEditTest{

    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();  
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
    }  

    static testMethod void method01()
    {
         //variables
		User cso = TestDataFactory.prepareTestUsers();
		
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Zuora_Id__c = 'test data';
        billAcc.Zuora__External_Id__c = 'test data';
        billAcc.Zuora__Credit_Balance__c = 100000;
        billAcc.Zuora__DefaultPaymentMethod__c = GlobalVariableClass.CHEQUE;
        database.insert(billAcc);

        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con);

        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BASE; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Zuora__TermSettingType__c = 'Termed';
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__CustomerAccount__c = billAcc.Id; 
        SubscriptionTriggerHandler.preventExecution = true;
        database.insert(subRecord);

        //Create Invoice
        Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Name = 'Test Invoince';
        zInvoice.Zuora__Account__c = acc.id;
        zInvoice.Zuora__BillingAccount__c = billAcc.Id;
        zInvoice.Zuora__Balance2__c = 500;
        zInvoice.Zuora__TotalAmount__c = 500;
        zInvoice.Zuora__InvoiceDate__c = date.today().addDays(-2);
        zInvoice.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        insert zInvoice;
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Invoice_Id__c = zInvoice.Zuora__Zuora_Id__c;
        ili.Subscription__c = subRecord.Id;
        ili.Charge_Amount__c = 20000;
        insert ili;
        
        Case cas = TestDataFactory.createCase(1, 'Enquiry')[0];
        cas.Adjustment_Amount__c = 10.00;
        database.insert(cas); //Test Class Update Cha
        
        System.runAs(cso) {
            Test.startTest(); 
            PageReference pRef = Page.AdjustmentsCaseEditPage;
            Test.setCurrentPage(pRef);
            
            ApexPages.CurrentPage().getParameters().put('billingaccountId',billAcc.id);
            ApexPages.CurrentPage().getParameters().put('RecordType', ConstantsSLB.getKeyId('Case_Adjustments'));
            ApexPages.CurrentPage().getParameters().put('accountId', acc.id);
            ApexPages.CurrentPage().getParameters().put('accountId', acc.id);
            ApexPages.CurrentPage().getParameters().put('def_parent_id', cas.id);
            
            ApexPages.StandardController stdController = new ApexPages.Standardcontroller(new Case());
            AdjustmentExtensionEdit  controller = new AdjustmentExtensionEdit(stdController);
            controller.adjustment.Billing_Account_Name__c = billAcc.id;
            controller.adjustment.Accountid = acc.id;
            controller.adjustment.contactid = con.id;
            controller.adjustment.Subscription_Name__c = subRecord.id;
            controller.adjustment.Invoice__c = zInvoice.id;
            controller.adjustment.Category__c = 'Subscription Request';
            controller.adjustment.Sub_Category__c = 'Adjustment';
            controller.adjustment.Status = 'New';
            controller.adjustment.Origin = 'Email';
            controller.adjustment.Priority = 'Medium';
            controller.adjustment.Adjustment_Status__c = 'Sucess';
            controller.adjustment.Subject__c = 'Invoice Adjustment';
            controller.adjustment.Description = 'Invoice Adjustment';
            controller.adjustment.recordtypeid = ConstantsSLB.getKeyId('Case_Adjustments');
            controller.cancel();
            //Test Negative Amount
            controller.adjustment.Adjustment_Amount__c = zInvoice.Zuora__TotalAmount__c + 1;
            pRef = controller.submitAdjustment();
            
            System.assertEquals(null, pRef);
            
            controller.adjustment.Adjustment_Amount__c = 10;
            controller.submitAndNew();
            controller.submitAdjustment();
            Test.stopTest(); 
        }
    }
    
    static testMethod void method02()
    {
         //variables
		User cso = TestDataFactory.prepareTestUsers();
		
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Zuora_Id__c = 'test data';
        billAcc.Zuora__External_Id__c = 'test data';
        billAcc.Zuora__Credit_Balance__c = 100000;
        billAcc.Zuora__DefaultPaymentMethod__c = GlobalVariableClass.CHEQUE;
        database.insert(billAcc);

        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con);

        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BASE; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Zuora__TermSettingType__c = 'Termed';
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__CustomerAccount__c = billAcc.Id; 
        SubscriptionTriggerHandler.preventExecution = true;
        database.insert(subRecord);

        //Create Invoice
        Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Name = 'Test Invoince';
        zInvoice.Zuora__Account__c = acc.id;
        zInvoice.Zuora__BillingAccount__c = billAcc.Id;
        zInvoice.Zuora__Balance2__c = 500;
        zInvoice.Zuora__TotalAmount__c = 500;
        zInvoice.Zuora__InvoiceDate__c = date.today().addDays(2);
        zInvoice.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        insert zInvoice;
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Invoice_Id__c = zInvoice.Zuora__Zuora_Id__c;
        //ili.Subscription__c = subRecord.Id;
        ili.Charge_Amount__c = 20000;
        insert ili;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        cas.Adjustment_Amount__c = 10.00;
        //database.insert(cas); //Test Class Update Cha
        
        System.runAs(cso) {
            Test.startTest(); 
            PageReference pRef = Page.AdjustmentsCaseEditPage;
            Test.setCurrentPage(pRef);
            
            ApexPages.CurrentPage().getParameters().put('billingaccountId',billAcc.id);
            
            ApexPages.StandardController stdController = new ApexPages.Standardcontroller(new Case());
            AdjustmentExtensionEdit  controller = new AdjustmentExtensionEdit(stdController);
            controller.adjustment.Billing_Account_Name__c = billAcc.id;
            controller.adjustment.Accountid = acc.id;
            controller.adjustment.contactid = con.id;
            controller.adjustment.Subscription_Name__c = subRecord.id;
            controller.adjustment.Invoice__c = zInvoice.id;
            controller.adjustment.Category__c = 'Subscription Request';
            controller.adjustment.Sub_Category__c = 'Adjustment';
            controller.adjustment.Status = 'New';
            controller.adjustment.Origin = 'Email';
            controller.adjustment.Priority = 'Medium';
            controller.adjustment.Adjustment_Status__c = 'Sucess';
            controller.adjustment.Subject__c = 'Invoice Adjustment';
            controller.adjustment.Description = 'Invoice Adjustment';
            controller.adjustment.recordtypeid = ConstantsSLB.getKeyId('Case_Adjustments');
            controller.cancel();
            //Test Negative Amount
            controller.adjustment.Adjustment_Amount__c = -10;
            pRef = controller.submitAdjustment();
            
            System.assertEquals(null, pRef);
            
            controller.adjustment.Adjustment_Amount__c = 10;
            controller.submitAndNew();
            Test.stopTest(); 
        }
    }
    
    static testMethod void method03()
    {
         //variables
		User cso = TestDataFactory.prepareTestUsers();
		
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Zuora_Id__c = 'test data';
        billAcc.Zuora__External_Id__c = 'test data';
        billAcc.Zuora__Credit_Balance__c = 100000;
        billAcc.Zuora__DefaultPaymentMethod__c = GlobalVariableClass.CHEQUE;
        database.insert(billAcc);

        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con);

        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BASE; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Zuora__TermSettingType__c = 'Termed';
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__CustomerAccount__c = billAcc.Id; 
        SubscriptionTriggerHandler.preventExecution = true;
        database.insert(subRecord);

        //Create Invoice
        Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        zInvoice.Name = 'Test Invoince';
        zInvoice.Zuora__Account__c = acc.id;
        zInvoice.Zuora__BillingAccount__c = billAcc.Id;
        zInvoice.Zuora__Balance2__c = 500;
        zInvoice.Zuora__TotalAmount__c = 500;
        zInvoice.Zuora__InvoiceDate__c = date.today().addDays(2);
        zInvoice.Zuora__Zuora_Id__c = ResponseUtility.generateExternalId();
        insert zInvoice;
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        cas.Adjustment_Amount__c = 10.00;
        
        System.runAs(cso) {
            Test.startTest(); 
            PageReference pRef = Page.AdjustmentsCaseEditPage;
            Test.setCurrentPage(pRef);
            
            ApexPages.CurrentPage().getParameters().put('billingaccountId',billAcc.id);
            
            ApexPages.StandardController stdController = new ApexPages.Standardcontroller(new Case());
            AdjustmentExtensionEdit  controller = new AdjustmentExtensionEdit(stdController);
            controller.adjustment.Billing_Account_Name__c = billAcc.id;
            controller.adjustment.Accountid = acc.id;
            controller.adjustment.contactid = con.id;
            controller.adjustment.Subscription_Name__c = subRecord.id;
            controller.adjustment.Invoice__c = zInvoice.id;
            controller.adjustment.Category__c = 'Subscription Request';
            controller.adjustment.Sub_Category__c = 'Adjustment';
            controller.adjustment.Status = 'New';
            controller.adjustment.Origin = 'Email';
            controller.adjustment.Priority = 'Medium';
            controller.adjustment.Adjustment_Status__c = 'Sucess';
            controller.adjustment.Subject__c = 'Invoice Adjustment';
            controller.adjustment.Description = 'Invoice Adjustment';
            controller.adjustment.recordtypeid = ConstantsSLB.getKeyId('Case_Adjustments');
            controller.cancel();
            //Test Negative Amount
            controller.adjustment.Adjustment_Amount__c = -10;
            pRef = controller.submitAdjustment();
            
            System.assertEquals(null, pRef);
            
            controller.adjustment.Adjustment_Amount__c = 10;
            controller.submitAndNew();
            Test.stopTest(); 
        }
    }
    
    
}