/*
 * Class Name: BT_AB_AGD106DX_ExportInvoiceTest
 * Date: 17 May 2017
 * Project/Requirement: Test class for BT_AB_AGD106DX_ExportInvoice
 */
@isTest 
private class BT_AB_AGD106DX_ExportInvoiceTest{

    @testSetup static void setup(){

        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct Individual').getRecordTypeId();
        Id accRecTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct Corporate').getRecordTypeId();
        Id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();

        BT_CO_Batch_Run_Request__c dummyBatchRunReq = new BT_CO_Batch_Run_Request__c();
        dummyBatchRunReq.Batch_Run_Date__c = Date.today();
        dummyBatchRunReq.End_Time__c = System.now()+1;
        dummyBatchRunReq.Interface_ID__c = 'AGD106DX';
        dummyBatchRunReq.Start_Time__c = System.now();

        insert dummyBatchRunReq;

        Other__c othercSettings1 = new Other__c();
        othercSettings1.Name = 'GST';
        othercSettings1.Value__c = '7';

        insert othercSettings1;

        Other__c othercSettings2 = new Other__c();
        othercSettings2.Name = 'Order_Type Renewal';
        othercSettings2.Value__c = 'Renewal';
        
        insert othercSettings2;

        Other__c othercSettings3 = new Other__c();
        othercSettings3.Name = 'DTL';
        othercSettings3.Value__c = '23:59';
        
        insert othercSettings3;

        Key_Id__c keyIdSetting1 = new Key_Id__c();
        keyIdSetting1.Name = 'Account_Direct Individual';
        keyIdSetting1.Id__c = accRecTypeId;

        insert keyIdSetting1;



        Key_Id__c keyIdSetting2 = new Key_Id__c();
        keyIdSetting2.Name = 'Contact_Customer Contact';
        keyIdSetting2.Id__c = conRecTypeId;

        insert keyIdSetting2;

        Key_Id__c keyIdSetting3  = new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER',
                                                Id__c='30465208',
                                                Type__c='Number');
        
        insert keyIdSetting3;


        BatchInterface_Settings__c biSettings = new BatchInterface_Settings__c();
        biSettings.Name = 'Endpoint Delegator';
        biSettings.Value__c = 'http://tstcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';

        insert biSettings;


        Account acc = new Account(Name = 'Test Account',
                                Email__c = 'testcrsm@sph.crsm',
                                RecordTypeId = accRecTypeId,
                                Attention_To_Care_Of_Indicator__c = 'C');
                    
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;

        insert addressRec;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Phone = '1234567';
        con.Address__c = addressRec.Id; 
        con.RecordTypeId = conRecTypeId;
        con.Recipient_Indicator__c = true;

        insert con;

        Zuora__CustomerAccount__c dummyzCusAcc = TestDataFactory.createBillingAccount(1)[0];
        //dummyzCusAcc.Name='Test Billing Account';
        dummyzCusAcc.Billing_Type__c = '';
        dummyzCusAcc.Zuora__Account__c = acc.Id;
        dummyzCusAcc.ARMS_Debt_Management__c = 'SUBH';
        dummyzCusAcc.AGD_Unit__c = 'test';

        insert dummyzCusAcc;
        insert CustomSettingsDataFactory.createBillingBatch();
    }

    static testMethod void test01(){

        Account existingAccRec = [Select Id, RecordTypeId from Account LIMIT 1];
        Zuora__CustomerAccount__c existingCusAccRec = [Select Id,
                                                            AGD_Unit__c,
                                                            Zuora__Account__c,
                                                            Billing_Type__c from Zuora__CustomerAccount__c where Zuora__Account__c =: existingAccRec.Id LIMIT 1];
        Contact existingConRec = [Select Id,
                                        Recipient_Number__c,
                                        Salutation,
                                        Name from Contact LIMIT 1];

        Package__c pkg = TestDataFactory.createPackage(1)[0];
        pkg.Subscription_Period__c = '15';            
        
        insert pkg;

        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = existingAccRec.Id;
        order.Recipient_Contact__c = existingConRec.Id;
        order.Informed_Customer__c = True;
        order.Subscriber_charge__c = 100;
        // 'Change of Subscription Package';
        
        insert order;

        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0]; 
        oli.Order__c = order.Id; 
        oli.Main_Package_ID__c = pkg.id;

        insert oli;

        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Cash'; 
        defaultPayment.Zuora__Account__c = existingAccRec.id; 
        
        insert defaultPayment;

        List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
        zSubs[0].Zuora__Account__c = existingAccRec.id;
        zSubs[0].Order_Line_Item_Number__c = oli.Id;
        zSubs[0].Order_Number__c = order.Id;
        zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
        zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
        zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs[0].Urgent__c = 'false';
        zSubs[0].Vendor_Conversion__c = 'false';
        zSubs[0].Charity__c = 'false';
        zSubs[0].Acquisition_Type__c = 'TEST';            
        zSubs[0].Legacy_Create_Date__c = String.valueof(system.today());
        zSubs[0].Legacy_Create_By__c = 'abcde';
        zSubs[0].Legacy_Update_Date__c = String.valueof(system.today());
        zSubs[0].Legacy_Update_By__c = 'abcde';
        zSubs[0].Legacy_Subscription_ID__c ='abcde'; 
        zSubs[0].Zuora__CustomerAccount__c = defaultPayment.Id;
        zSubs[0].Sponsor_1__c = false;
        zSubs[0].Name = 'Subscription 1';
        zSubs[0].Main_Package_1__c = pkg.id;
        zSubs[0].Billing_Type__c = 'Recurring Prepaid';
        zSubs[0].Contract_End_Date_1__c = date.today()+30;
        zSubs[0].Subscription_Type__c = 'Publication';//
        zSubs[0].Recipient_Contact__c = existingConRec.Id;

        insert zSubs;

        Invoice_Line_Item__c dummyInvLineItem1 = new Invoice_Line_Item__c();
        dummyInvLineItem1.Name = 'test1';
        dummyInvLineItem1.Invoice_ID__c = '2c92c0f953078a3501530e39baf74965';
        dummyInvLineItem1.Subscription__c = zSubs[0].id;
        dummyInvLineItem1.Charge_Amount__c = 1.2;
        dummyInvLineItem1.Tax_Amount__c = 2207.94;

        insert dummyInvLineItem1;

        System.debug('@#$ Invoice_ID__c: ' + dummyInvLineItem1.Invoice_ID__c);

        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'test';
        inv.Zuora__InvoiceDate__c = date.today();
        inv.Zuora__TargetDate__c =  date.today()+5;
        inv.Zuora__Zuora_Id__c = 'test2';
        inv.ARMS_Invoice_ID__c = '0027105322';
        inv.Zuora__Account__c = existingAccRec.Id; //accountid
        inv.Zuora__BillingAccount__c = existingCusAccRec.Id; //accountid
        inv.Zuora__Description__c = '';
        inv.Zuora__External_Id__c = '2c92c0f953078a3501530e39baf74965'; //dummyInvLineItem2.Id; 
        inv.Zuora__TaxAmount__c = 88.36;
        inv.Zuora__TotalAmount__c = 1350.1;
        inv.Zuora__AmountWithoutTax__c = 1261.74;

        insert inv;

        
        Test.startTest();
            BT_AB_AGD106DX_ExportInvoice exInvoiceBatch = new BT_AB_AGD106DX_ExportInvoice();
            Database.executeBatch(exInvoiceBatch);
        Test.stopTest();
    }
    // static testMethod void testExportInvoice(){
        
    //  Test.startTest();
 //        BT_AB_AGD106DX_ExportInvoice edi = new BT_AB_AGD106DX_ExportInvoice();
 //        Database.executeBatch(edi);
 //        Test.stopTest();
    // } No for me, Currently, I need to be at home not late than 2-3 hours because I need to help my wife to take care of our 3 months old baby.

}