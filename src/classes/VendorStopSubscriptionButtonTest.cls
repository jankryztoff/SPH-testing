/**
 * Class Name: <VendorStopSubscriptionButtonTest>
 * @author: <Thayne Recato Dy>
 * Date: <8/16/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for VendorStopSubscriptionButton>
 */
@isTest(seeAllData = true)
private class VendorStopSubscriptionButtonTest {
    
    /*
    *   @description: This test method executes the stopVenSub() method ain the base class
    *   @Parameters: N/A
    *   @return: N/A
    */ 
    static testmethod void testStopVendorSub() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);

        Id recordTypeId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Vendor Subscriber' LIMIT 1].Id;
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc .NRIC__c = 'T1234567R';
        acc.RecordTypeId = recordTypeId;
        database.insert(acc);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
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
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);            
        
        Zuora__CustomerAccount__c billingAccount = TestDataFactory.createBillingAccount(1)[0];
        billingAccount.Zuora__Account__c = acc.Id;
        billingAccount.Billing_Type__c = 'Full Prepaid';
        billingAccount.Zuora__DefaultPaymentMethod__c = 'Other';
        billingAccount.ARMS_Return_Status__c = 'test';
        database.insert(billingAccount);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Billing_Account__c = billingAccount.Id;
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        //subRecord.Order__c = order.id;
        subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
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
        subRecord.Subscription_Charge__c = 100;
        subRecord.Zuora__CustomerAccount__c = billingAccount.Id;
        database.insert(subRecord);
        
        Test.startTest();
        
        order.Base_Subscription__c= subRecord.id;
        database.update(order);
        
        Case cas = TestDataFactory.createCase(1, 'Stop Subscription')[0];
        cas.Order__c = order.Id;
        cas.Account__c = acc.id;
        cas.AccountID = acc.id;
        database.insert(cas);
        
        Subscription_Vendor__c sv = TestDataFactory.createSubscriptionVendor(1)[0];
        sv.Account__c = acc.Id;
        database.insert(sv);  
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0]; 
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'NNNNNNN';
        npub.Publication_Type__c = 'N';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Platform_Type__c = 'Print';
        pubList.add(npub);
        database.insert(pubList);
        
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c(); 
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);
        
        List<Subscription_Vendor_Publication__c> svp = TestDataFactory.createSubVendorPublication(2);
        svp[0].Subscription_Vendor__c = sv.id;
        svp[0].Order__c = order.Id;
        svp[0].Publication__c = pub.Id;
        svp[1].Subscription_Vendor__c = sv.id;
        svp[1].Order__c = order.Id;
        svp[1].Publication__c = npub.Id;
        database.insert(svp);
        
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        orderLineItemList[0].Case__c = cas.id;
        orderLineItemList[0].Order__c = order.Id;
        orderLineItemList[0].Start_Date__c = date.today().addDays(2);
        orderLineItemList[0].Stop_Date__c = date.today().addDays(10);
        orderLineItemList[0].Publication__c = pub.id;
        orderLineItemList[0].Stop_Request_Date__c = date.today();
        orderLineItemList[0].Subscription_Vendor__c = sv.id;
        orderLineItemList[1].Case__c = cas.id;
        orderLineItemList[1].Order__c = order.Id;
        orderLineItemList[1].Start_Date__c = date.today().addDays(2);
        orderLineItemList[1].Stop_Date__c = date.today().addDays(10);
        orderLineItemList[1].Publication__c = npub.id;
        orderLineItemList[1].Stop_Request_Date__c = date.today();
        orderLineItemList[1].Subscription_Vendor__c = sv.id;
        database.insert(orderLineItemList);
        
        String result;
        result = VendorStopSubscriptionButton.stopVendorSub(cas.id);
        
        System.assertEquals('Success', result);
        
        Test.stopTest();
    }
    
    /*
    *   @description: This test method will test if the main method of the base class
    *               catches a non existent case id.
    *   @Parameters: N/A
    *   @return: N/A
    */ 
    static testmethod void testErrorCaseId() {
        String result;
        Test.startTest();
        try {

            result = VendorStopSubscriptionButton.stopVendorSub('SAMPLECASEIDERROR');
            
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        Test.stopTest();
        
        System.assertEquals('Error in cancelling subscription.', result);
    }
    
    /*
    *   @description: This test method will test the condition if the Account is not a 'Vendor Subsciber'.
    *   @Parameters: N/A
    *   @return: N/A
    */ 
    static testmethod void testWrongCaseIDType() {
        
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Id recordTypeId = [Select Id From RecordType Where SObjectType='Account' And Name = 'Direct Individual' LIMIT 1].Id;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc .NRIC__c = 'T1234567R';
        acc.RecordTypeId = recordTypeId;
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
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
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);
        
        Zuora__CustomerAccount__c billingAccount = TestDataFactory.createBillingAccount(1)[0];
        billingAccount.Zuora__Account__c = acc.Id;
        billingAccount.Billing_Type__c = 'Full Prepaid';
        billingAccount.Zuora__DefaultPaymentMethod__c = 'Other';
        database.insert(billingAccount);            
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Billing_Account__c = billingAccount.Id;
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        cas.Account__c = acc.id;
        cas.AccountID = acc.id;
        database.insert(cas);
        
        Test.startTest();
        
        String result;        
        result = VendorStopSubscriptionButton.stopVendorSub(cas.id);
        
        System.assertEquals('Case should be Vendor Stop Subscription.', result);
        
        Test.stopTest();
    }catch (Exception e) {
       }
    }
}