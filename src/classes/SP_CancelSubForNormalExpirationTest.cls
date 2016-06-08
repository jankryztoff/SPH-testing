/*
* Class Name: <SP_CancelSubForNormalExpirationTest>
* @author: Thayne Recato Dy
* Date: 2/17/2015
* Requirement/Project Name: <SPH>
* @description: This is the test class for SP_CancelSubForNormalExpiration
*/
@isTest(seeAllData = true)
private class SP_CancelSubForNormalExpirationTest {
    
    /*@description: This test method execute a batch for SP_CancelSubForNormalExpiration */
    static testmethod void testCancelSubForNormalExpiration() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
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
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
        billAcc.Billing_Type__c = 'Full Prepaid';
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
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
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
        order.Subscriber_charge__c = 0;
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.Id;
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
        subRecord.Zuora__SubscriptionStartDate__c = date.today().addDays(1);
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__AutoRenew__c = false;
        subRecord.Sponsor_1__c = true;
        database.insert(subRecord);
        
        order.Base_Subscription__c= subRecord.id;
        database.update(order);
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c =  date.today().addDays(5);
        oli.Fee_Waiver__c = TRUE;
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        oli.Grace_Days__c = 0;
        database.insert(oli);
        
        System.assertNotEquals(NULL, order);
        
        Test.startTest();
        
        subRecord.Order_Line_Item_Number__c = oli.id;        
        database.update(subRecord);        
        
        try {            
            Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
            SP_CancelSubForNormalExpiration batch = new SP_CancelSubForNormalExpiration();
            ID batchprocessid = Database.executeBatch(batch, 100);
            
            BATCH_JOB_SCHEDULER__c batchScheduler1 = new BATCH_JOB_SCHEDULER__c();
            batchScheduler1.Status__c = 'ACTIVE';
            batchScheduler1.Batch_Code__c = 'ASM02';
            batchScheduler1.Batch_Run_Date__c = Date.today();
            batchScheduler1.SFDC_Job_id__c = batchprocessid ;    
            insert batchScheduler1;  
            
            Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
            SP_CancelSubForNormalExpiration batch2 = new SP_CancelSubForNormalExpiration();
            ID batchprocessid2 = Database.executeBatch(batch2, 100);
            
            BATCH_JOB_SCHEDULER__c batchScheduler2 = new BATCH_JOB_SCHEDULER__c();
            batchScheduler2.Status__c = 'ACTIVE';
            batchScheduler2.Batch_Code__c = 'ASM02';
            batchScheduler2.Batch_Run_Date__c = Date.today();
            batchScheduler2.SFDC_Job_id__c = batchprocessid2;       
            insert batchScheduler2 ;   
            
        }catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        
        
        Test.stopTest();
    }
}