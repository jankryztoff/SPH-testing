/**
* Class Name: VendorTempStopController
* @author: Thayne Recato Dy
* Date: February 26, 2015
* Requirement/Project Name: <SPH>
* @description : This is a test class for VendorTempStopController
* Edit: April veloso <04/07/2016>
**/
@isTest(seealldata=true)

private class VendorTempStopControllerTest {
    
    /*@description: This test method executes the method setSelectedRecord() and 
    *           some of its conditions. */
    static testmethod void testSetSelectedRecordPart1() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Date_Since__c = date.today();
        acc.Contact_Person__c = 'Me';
        acc.AccountNumber = '0000-1111';
        acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
        acc.Status__c = 'Active';
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
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
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        database.insert(cas);
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subsVen.Account__c = acc.id;
        subsVen.Order_Number__c = order.id;
        subsVen.Recipient__c = con.id;
        subsVen.Vendor__c = acc.id;
        subsVen.Subscription_Start_Date__c = date.today().addDays(1);
        subsVen.Subscription_Stop_Date__c = date.today().addDays(5);
        subsVen.Status__c = 'Active';
        database.insert(subsVen);
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'M';
        pub.Publish_Pattern__c = 'Weekdays';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pubList.add(pub);        
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];    
        npub.Name = 'Test 2';
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'M';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        database.insert(pubList);       
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pubList[0].id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);   
        
        Temp_Stop__c tempStop = new Temp_Stop__c();
        tempStop.Case__c = cas.id;
        tempStop.Order__c = order.id;
        tempStop.Temp_Stop_Date__c = date.today().addDays(1);
        tempStop.Restart_Date__c = date.today().addDays(2);
        database.insert(tempStop);
        
        Vendor_Temp_Stop__c venTempStop = new Vendor_Temp_Stop__c();
        venTempStop.Publication__c = pubList[0].id;
        venTempStop.Subscription_Vendor__c = subsVen.id;
        venTempStop.Temp_Stop__c = tempStop.id;
        database.insert(ventempStop);
        
        Subscription_Vendor_Publication__c subsVenPub = TestDataFactory.createSubVendorPublication(1)[0];
        subsVenPub.Account__c = acc.id;
        subsVenPub.Order__c = order.id;
        subsVenPub.Publication__c = pubList[0].id;
        subsVenPub.Subscription_Vendor__c = subsVen.id;
        subsVenPub.Mon__c = 0;
        subsVenPub.Tue__c = 1;
        subsVenPub.Wed__c = 2;
        subsVenPub.Thu__c = 3;
        subsVenPub.Fri__c = 4;
        subsVenPub.Sat__c = 5;
        subsVenPub.Sun__c = 6;
        database.insert(subsVenPub);
        
        Non_Publication_Day__c npubday = [SELECT Id
                                         FROM Non_Publication_Day__c
                                         WHERE Publication__c =: pubList[0].id];
        
        System.assertEquals(nonPubList[0].id, npubday.id);
        
        Test.startTest();
        
        PageReference pgRef = Page.VendorTempStopSubs;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('accountId', acc.id);
        VendorTempStopController controller = new VendorTempStopController();
        
        controller.getListTempStopType();
        controller.getselectedTempStopType();
        
        controller.myId = subsVenPub.id;
        controller.vfSubId = subsVen.id;
        
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.newInstance(2015, 2, 23);
        controller.subscriptionResultList[0].restartDate = date.newInstance(2015, 2, 23);
        controller.setSelectedRecords();
        controller.getDateUrgency();
        
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.newInstance(2015, 2, 24);
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = NULL;
        controller.setSelectedRecords();        
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.newInstance(2015, 2, 24);
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today();
        controller.setSelectedRecords();        
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.newInstance(2015, 2, 24);
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1);
        controller.subscriptionResultList[0].subStartDate = date.today().addDays(2); 
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(2);
        controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.newInstance(2015, 2, 24);
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1);
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(1);
        controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.newInstance(2015, 2, 24);
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(5);
        controller.subscriptionResultList[0].subStartDate = date.today().addDays(4);
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(6);
        controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(8);
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(5);
        controller.subscriptionResultList[0].subStartDate = date.today().addDays(4);
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(6);
        controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(8);
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(5);
        controller.subscriptionResultList[0].subStartDate = date.today().addDays(4);
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(8);
        controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(8);
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(5);
        controller.subscriptionResultList[0].subStartDate = date.today().addDays(4);
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(9);
        controller.subscriptionResultList[0].earliestStartDate = NULL;
        controller.setSelectedRecords();
                
        Test.stopTest();
    }    
    
    /*@description: This test method executes the method setSelectedRecord() and 
    *           some of its conditions. */
    static testmethod void testSetSelectedRecordPart2() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Date_Since__c = date.today();
        acc.Contact_Person__c = 'Me';
        acc.AccountNumber = '0000-1111';
        acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
        acc.Status__c = 'Active';
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
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
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subsVen.Account__c = acc.id;
        subsVen.Order_Number__c = order.id;
        subsVen.Recipient__c = con.id;
        subsVen.Vendor__c = acc.id;
        subsVen.Subscription_Start_Date__c = date.today().addDays(1);
        subsVen.Subscription_Stop_Date__c = date.today().addDays(5);
        subsVen.Status__c = 'Active';
        database.insert(subsVen);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        //cas.Temp_Stop_VSub__c = subsVen.Id;
        //cas.Status = 'Pending';
        database.insert(cas);
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'M';
        pub.Publish_Pattern__c = 'Weekdays';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];    
        npub.Name = 'Test 2';
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'M';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        database.insert(pubList);       
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pubList[0].id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);   
        
        Temp_Stop__c tempStop = new Temp_Stop__c();
        tempStop.Case__c = cas.id;
        tempStop.Order__c = order.id;
        tempStop.Temp_Stop_Date__c = date.today().addDays(1);
        tempStop.Restart_Date__c = date.today().addDays(2);
        database.insert(tempStop);
        
        List <Vendor_Temp_Stop__c> venTempStopList = new List <Vendor_Temp_Stop__c>();
        Vendor_Temp_Stop__c venTempStop = new Vendor_Temp_Stop__c();
        venTempStop.Publication__c = pubList[0].id;
        venTempStop.Subscription_Vendor__c = subsVen.id;
        venTempStop.Temp_Stop__c = tempStop.id;
        venTempStopList.add(venTempStop);
        database.insert(venTempStopList);
        
        Subscription_Vendor_Publication__c subsVenPub = TestDataFactory.createSubVendorPublication(1)[0];
        subsVenPub.Account__c = acc.id;
        subsVenPub.Order__c = order.id;
        subsVenPub.Publication__c = pubList[0].id;
        subsVenPub.Subscription_Vendor__c = subsVen.id;
        subsVenPub.Mon__c = 0;
        subsVenPub.Tue__c = 1;
        subsVenPub.Wed__c = 2;
        subsVenPub.Thu__c = 3;
        subsVenPub.Fri__c = 4;
        subsVenPub.Sat__c = 5;
        subsVenPub.Sun__c = 6;
        database.insert(subsVenPub);
        
        Non_Publication_Day__c npubday = [SELECT Id
                                         FROM Non_Publication_Day__c
                                         WHERE Publication__c =: pubList[0].id];
        
        System.assertEquals(nonPubList[0].id, npubday.id);
        
        Test.startTest();
        
        PageReference pgRef = Page.VendorTempStopSubs;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('accountId', acc.id);
        VendorTempStopController controller = new VendorTempStopController();
                
        controller.myId = subsVenPub.id;
        controller.vfSubId = subsVen.id;
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.newInstance(2015, 2, 03);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(2);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today()+1;
        //controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(2);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(3);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today();
        controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(221);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(225);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today();
        controller.vendorTempStopRecList = venTempStopList;
        controller.requestSource = 'Call';
        controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(221);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(225);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today().addDays(2);
        controller.vendorTempStopRecList = venTempStopList;
        controller.requestSource = 'Eshop';
        controller.setSelectedRecords();
        controller.checkDuplicateSubscription();
        controller.tstopId = venTempStop.id;
        
        controller.followUpTask = TRUE;
        controller.submit();
        controller.cancel();
        
        //List<Vendor_Temp_Stop__c> venlist = new List<Vendor_Temp_Stop__c>();
        //venlist.add(venTempStop[0].id);
        //controller.validateOverlapping(venTempStopList , date.today(), date.today()+3, venTempStopList[0].id, venTempStop.Subscription_Vendor__c);
        //controller.highestQuantity(venTempStop.Subscription_Vendor__c, tempStop.Temp_Stop_Date__c, tempStop.Restart_Date__c);
        controller.removeSubscriptionRecord();
        
        /*Integer crmdur = integer.valueOf(ConstantsSLB.getKeyId('CRSMDuration'));
        System.assertEquals(controller.subscriptionResultList[0].tp.Temp_Stop_Date__c.monthsBetween(controller.subscriptionResultList[0].tp.Restart_Date__c), crmdur);*/
        Test.stopTest();
    }
    
    static testmethod void testSetSelectedRecordPart2b() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Date_Since__c = date.today();
        acc.Contact_Person__c = 'Me';
        acc.AccountNumber = '0000-1111';
        acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
        acc.Status__c = 'Active';
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
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
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subsVen.Account__c = acc.id;
        subsVen.Order_Number__c = order.id;
        subsVen.Recipient__c = con.id;
        subsVen.Vendor__c = acc.id;
        subsVen.Subscription_Start_Date__c = date.today().addDays(1);
        subsVen.Subscription_Stop_Date__c = date.today().addDays(5);
        subsVen.Status__c = 'Active';
        database.insert(subsVen);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        cas.Temp_Stop_VSub__c = subsVen.Id;
        cas.Status = 'Pending';
        database.insert(cas);

        Case casTemp = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        casTemp.Order__c = order.Id;
        casTemp.Temp_Stop_VSub__c = subsVen.Id;
        casTemp.Status = 'Pending';
        database.insert(casTemp);
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'M';
        pub.Publish_Pattern__c = 'Weekdays';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];    
        npub.Name = 'Test 2';
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'M';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        database.insert(pubList);       
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pubList[0].id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);   
        
        Temp_Stop__c tempStop = new Temp_Stop__c();
        tempStop.Case__c = cas.id;
        tempStop.Order__c = order.id;
        tempStop.Temp_Stop_Date__c = date.today().addDays(1);
        tempStop.Restart_Date__c = date.today().addDays(2);
        database.insert(tempStop);
        
        List <Vendor_Temp_Stop__c> venTempStopList = new List <Vendor_Temp_Stop__c>();
        Vendor_Temp_Stop__c venTempStop = new Vendor_Temp_Stop__c();
        venTempStop.Publication__c = pubList[0].id;
        venTempStop.Subscription_Vendor__c = subsVen.id;
        venTempStop.Temp_Stop__c = tempStop.id;
        venTempStopList.add(venTempStop);
        database.insert(venTempStopList);
        
        Subscription_Vendor_Publication__c subsVenPub = TestDataFactory.createSubVendorPublication(1)[0];
        subsVenPub.Account__c = acc.id;
        subsVenPub.Order__c = order.id;
        subsVenPub.Publication__c = pubList[0].id;
        subsVenPub.Subscription_Vendor__c = subsVen.id;
        subsVenPub.Mon__c = 0;
        subsVenPub.Tue__c = 1;
        subsVenPub.Wed__c = 2;
        subsVenPub.Thu__c = 3;
        subsVenPub.Fri__c = 4;
        subsVenPub.Sat__c = 5;
        subsVenPub.Sun__c = 6;
        database.insert(subsVenPub);
        
        Non_Publication_Day__c npubday = [SELECT Id
                                         FROM Non_Publication_Day__c
                                         WHERE Publication__c =: pubList[0].id];
        
        System.assertEquals(nonPubList[0].id, npubday.id);
        
        Test.startTest();
        
        PageReference pgRef = Page.VendorTempStopSubs;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('accountId', acc.id);
        VendorTempStopController controller = new VendorTempStopController();
                
        controller.myId = subsVenPub.id;
        controller.vfSubId = subsVen.id;
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.newInstance(2015, 2, 03);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(2);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today()+1;
        //controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(2);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(3);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today();
        controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(221);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(225);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today();
        controller.vendorTempStopRecList = venTempStopList;
        controller.requestSource = 'Call';
        controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(221);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(225);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today().addDays(2);
        controller.vendorTempStopRecList = venTempStopList;
        controller.requestSource = 'Eshop';
        controller.setSelectedRecords();
        controller.checkDuplicateSubscription();
        controller.tstopId = venTempStop.id;
        
        controller.followUpTask = TRUE;
        controller.submit();
        controller.cancel();
        
        controller.validateOverlapping(venTempStopList , date.today(), date.today()+3, venTempStopList[0].id, venTempStop.Subscription_Vendor__c);
        controller.highestQuantity(venTempStop.Subscription_Vendor__c, tempStop.Temp_Stop_Date__c, tempStop.Restart_Date__c);
        controller.removeSubscriptionRecord();
        
        //else coverage
        List<Case> caselist = new List<Case>();
        caselist.add(casTemp);
        
        controller.subToPendingCasesMap = null;
        controller.subToPendingCasesMap = new Map<ID,List<Case>>(); 
        controller.subToPendingCasesMap.put(casTemp.Id,caselist);
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 0;
        controller.setSelectedRecords();
        
        /*Integer crmdur = integer.valueOf(ConstantsSLB.getKeyId('CRSMDuration'));
        System.assertEquals(controller.subscriptionResultList[0].tp.Temp_Stop_Date__c.monthsBetween(controller.subscriptionResultList[0].tp.Restart_Date__c), crmdur);*/
        Test.stopTest();
    }
    
    static testmethod void testSetSelectedRecordPart3() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Date_Since__c = date.today();
        acc.Contact_Person__c = 'Me';
        acc.AccountNumber = '0000-1111';
        acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
        acc.Status__c = 'Active';
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
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
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        database.insert(cas);
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subsVen.Account__c = acc.id;
        subsVen.Order_Number__c = order.id;
        subsVen.Recipient__c = con.id;
        subsVen.Vendor__c = acc.id;
        subsVen.Subscription_Start_Date__c = date.today().addDays(1);
        subsVen.Subscription_Stop_Date__c = date.today().addDays(5);
        subsVen.Status__c = 'Active';
        database.insert(subsVen);
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'M';
        pub.Publish_Pattern__c = 'Weekdays';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];    
        npub.Name = 'Test 2';
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'M';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        database.insert(pubList);       
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pubList[0].id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);   
        /*
        Temp_Stop__c tempStop = new Temp_Stop__c();
        tempStop.Case__c = cas.id;
        tempStop.Order__c = order.id;
        tempStop.Temp_Stop_Date__c = date.today().addDays(1);
        tempStop.Restart_Date__c = date.today().addDays(2);
        database.insert(tempStop);
        */
        /*List <Vendor_Temp_Stop__c> venTempStopList = new List <Vendor_Temp_Stop__c>();
        Vendor_Temp_Stop__c venTempStop = new Vendor_Temp_Stop__c();
        venTempStop.Publication__c = pubList[0].id;
        venTempStop.Subscription_Vendor__c = subsVen.id;
        venTempStop.Temp_Stop__c = tempStop.id;
        venTempStopList.add(venTempStop);
        database.insert(venTempStopList);*/
        
        Subscription_Vendor_Publication__c subsVenPub = TestDataFactory.createSubVendorPublication(1)[0];
        subsVenPub.Account__c = acc.id;
        subsVenPub.Order__c = order.id;
        subsVenPub.Publication__c = pubList[0].id;
        subsVenPub.Subscription_Vendor__c = subsVen.id;
        subsVenPub.Mon__c = 0;
        subsVenPub.Tue__c = 1;
        subsVenPub.Wed__c = 2;
        subsVenPub.Thu__c = 3;
        subsVenPub.Fri__c = 4;
        subsVenPub.Sat__c = 5;
        subsVenPub.Sun__c = 6;
        database.insert(subsVenPub);
        
        Non_Publication_Day__c npubday = [SELECT Id
                                         FROM Non_Publication_Day__c
                                         WHERE Publication__c =: pubList[0].id];
        
        System.assertEquals(nonPubList[0].id, npubday.id);
        
        Test.startTest();
        
        PageReference pgRef = Page.VendorTempStopSubs;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('accountId', acc.id);
        VendorTempStopController controller = new VendorTempStopController();
                
        controller.myId = subsVenPub.id;
        controller.vfSubId = subsVen.id;
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.newInstance(2015, 2, 03);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(2);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today()+1;
        //controller.setSelectedRecords();
        
        //controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(2);
        //must be greater than today
        //controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(3);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today();
        controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(221);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(225);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today();
       controller.vendorTempStopRecList = null;
        controller.requestSource = 'Call';
        //controller.setSelectedRecords();
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(221);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(225);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today().addDays(2);
        controller.vendorTempStopRecList = null;
        controller.requestSource = 'Eshop';
        //controller.setSelectedRecords();
        controller.checkDuplicateSubscription();
        //controller.tstopId = venTempStop.id;
        
        controller.followUpTask = TRUE;
        controller.submit();
        controller.cancel();
        
        controller.removeSubscriptionRecord();
        
        /*Integer crmdur = integer.valueOf(ConstantsSLB.getKeyId('CRSMDuration'));
        System.assertEquals(controller.subscriptionResultList[0].tp.Temp_Stop_Date__c.monthsBetween(controller.subscriptionResultList[0].tp.Restart_Date__c), crmdur);*/
        Test.stopTest();
    }
    
    static testmethod void testSetSelectedRecordPart4() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Date_Since__c = date.today();
        acc.Contact_Person__c = 'Me';
        acc.AccountNumber = '0000-1111';
        acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
        acc.Status__c = 'Active';
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
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
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        database.insert(cas);
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subsVen.Account__c = acc.id;
        subsVen.Order_Number__c = order.id;
        subsVen.Recipient__c = con.id;
        subsVen.Vendor__c = acc.id;
        subsVen.Subscription_Start_Date__c = date.today().addDays(1);
        subsVen.Subscription_Stop_Date__c = date.today().addDays(5);
        subsVen.Status__c = 'Active';
        database.insert(subsVen);
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'M';
        pub.Publish_Pattern__c = 'Weekdays';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];    
        npub.Name = 'Test 2';
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'M';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        database.insert(pubList);       
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pubList[0].id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);   
        /*
        Temp_Stop__c tempStop = new Temp_Stop__c();
        tempStop.Case__c = cas.id;
        tempStop.Order__c = order.id;
        tempStop.Temp_Stop_Date__c = date.today().addDays(1);
        tempStop.Restart_Date__c = date.today().addDays(2);
        database.insert(tempStop);
        */
        /*List <Vendor_Temp_Stop__c> venTempStopList = new List <Vendor_Temp_Stop__c>();
        Vendor_Temp_Stop__c venTempStop = new Vendor_Temp_Stop__c();
        venTempStop.Publication__c = pubList[0].id;
        venTempStop.Subscription_Vendor__c = subsVen.id;
        venTempStop.Temp_Stop__c = tempStop.id;
        venTempStopList.add(venTempStop);
        database.insert(venTempStopList);*/
        
        Subscription_Vendor_Publication__c subsVenPub = TestDataFactory.createSubVendorPublication(1)[0];
        subsVenPub.Account__c = acc.id;
        subsVenPub.Order__c = order.id;
        subsVenPub.Publication__c = pubList[0].id;
        subsVenPub.Subscription_Vendor__c = subsVen.id;
        subsVenPub.Mon__c = 0;
        subsVenPub.Tue__c = 1;
        subsVenPub.Wed__c = 2;
        subsVenPub.Thu__c = 3;
        subsVenPub.Fri__c = 4;
        subsVenPub.Sat__c = 5;
        subsVenPub.Sun__c = 6;
        database.insert(subsVenPub);
        
        Non_Publication_Day__c npubday = [SELECT Id
                                         FROM Non_Publication_Day__c
                                         WHERE Publication__c =: pubList[0].id];
        
        System.assertEquals(nonPubList[0].id, npubday.id);
        
        Test.startTest();
        
        PageReference pgRef = Page.VendorTempStopSubs;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('accountId', acc.id);
        VendorTempStopController controller = new VendorTempStopController();
                
        controller.myId = subsVenPub.id;
        controller.vfSubId = subsVen.id;
        
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.newInstance(2015, 2, 03);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(2);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today()+1;
        //controller.setSelectedRecords();
        
        //controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(1);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(2); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(3);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today();
        //controller.setSelectedRecords();
        /*
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(221);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(225);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today();
       controller.vendorTempStopRecList = null;
        controller.requestSource = 'Call';
        //controller.setSelectedRecords();
        */
        /*
        controller.subscriptionResultList[0].tp.Temp_Stop_Qty__c = 100;
        controller.subscriptionResultList[0].tp.Restart_Date__c = date.today().addDays(221);
        //must be greater than today
        controller.subscriptionResultList[0].tp.Temp_Stop_Date__c = date.today().addDays(1); 
        //must be greater than Temp Stop Date
        controller.subscriptionResultList[0].subEndDate = date.today().addDays(225);
        //must be less than Restart Date
        controller.subscriptionResultList[0].subStartDate = date.newInstance(2015, 2, 01);
        //must not be null
        controller.subscriptionResultList[0].earliestStartDate = date.today().addDays(2);
        controller.vendorTempStopRecList = null;
        controller.requestSource = 'Eshop';
        //controller.setSelectedRecords();
        controller.checkDuplicateSubscription();
        //controller.tstopId = venTempStop.id;
        */
        controller.followUpTask = TRUE;
        controller.submit();
        controller.cancel();
        
        controller.removeSubscriptionRecord();
        
        /*Integer crmdur = integer.valueOf(ConstantsSLB.getKeyId('CRSMDuration'));
        System.assertEquals(controller.subscriptionResultList[0].tp.Temp_Stop_Date__c.monthsBetween(controller.subscriptionResultList[0].tp.Restart_Date__c), crmdur);*/
        Test.stopTest();
    }
    
    /*@description: This test method executes the method setVendorTempStopRecord() 
    *           when selectedTempStopType is globalvariableclass.TS_RADIO_UPDATE_TEMP_STOP*/
    static testmethod void testSetVendorTempStopRecordPart1() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Date_Since__c = date.today();
        acc.Contact_Person__c = 'Me';
        acc.AccountNumber = '0000-1111';
        acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
        acc.Status__c = 'Active';
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
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
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        database.insert(cas);
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subsVen.Account__c = acc.id;
        subsVen.Order_Number__c = order.id;
        subsVen.Recipient__c = con.id;
        subsVen.Vendor__c = acc.id;
        subsVen.Subscription_Start_Date__c = date.today().addDays(1);
        subsVen.Subscription_Stop_Date__c = date.today().addDays(5);
        subsVen.Status__c = 'Active';
        database.insert(subsVen);
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'M';
        pub.Publish_Pattern__c = 'Weekdays';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];    
        npub.Name = 'Test 2';
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'M';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        database.insert(pubList);       
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pubList[0].id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);   
        
        Temp_Stop__c tempStop = new Temp_Stop__c();
        tempStop.Case__c = cas.id;
        tempStop.Order__c = order.id;
        tempStop.Temp_Stop_Date__c = date.today().addDays(1);
        tempStop.Restart_Date__c = date.today().addDays(2);
        database.insert(tempStop);
        
        Vendor_Temp_Stop__c venTempStop = new Vendor_Temp_Stop__c();
        venTempStop.Publication__c = pubList[0].id;
        venTempStop.Subscription_Vendor__c = subsVen.id;
        venTempStop.Temp_Stop__c = tempStop.id;
        database.insert(ventempStop);
        
        Subscription_Vendor_Publication__c subsVenPub = TestDataFactory.createSubVendorPublication(1)[0];
        subsVenPub.Account__c = acc.id;
        subsVenPub.Order__c = order.id;
        subsVenPub.Publication__c = pubList[0].id;
        subsVenPub.Subscription_Vendor__c = subsVen.id;
        subsVenPub.Mon__c = 0;
        subsVenPub.Tue__c = 1;
        subsVenPub.Wed__c = 2;
        subsVenPub.Thu__c = 3;
        subsVenPub.Fri__c = 4;
        subsVenPub.Sat__c = 5;
        subsVenPub.Sun__c = 6;
        database.insert(subsVenPub);
        
        Non_Publication_Day__c npubday = [SELECT Id
                                         FROM Non_Publication_Day__c
                                         WHERE Publication__c =: pubList[0].id];
        
        System.assertEquals(nonPubList[0].id, npubday.id);
        
        Test.startTest();
        
        PageReference pgRef = Page.VendorTempStopSubs;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('accountId', acc.id);
        VendorTempStopController controller = new VendorTempStopController();
        
        controller.vendorTempStop = venTempStop;
        controller.myIdUpdate = venTempStop.id;
        controller.setTempStopType(globalvariableclass.TS_RADIO_UPDATE_TEMP_STOP);
        controller.setVendorTempStopRecords();
        
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Qty__c = 100;
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c = date.today().addDays(1);
        controller.vendorTempStop.Temp_Stop__r.Restart_Date__c = date.today();
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Stop_Date__c = date.today();        
        controller.setVendorTempStopRecords();
        
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Qty__c = 100;
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c = date.today().addDays(1);
        controller.vendorTempStop.Temp_Stop__r.Restart_Date__c = date.today();
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Stop_Date__c = date.today().addDays(10);        
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Start_Date__c = date.today().addDays(2);
        controller.setVendorTempStopRecords();
        
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Qty__c = 100;
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c = date.today().addDays(1);
        controller.vendorTempStop.Temp_Stop__r.Restart_Date__c = date.today();
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Stop_Date__c = date.today().addDays(10);        
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Start_Date__c = date.today().addDays(1);
        controller.setVendorTempStopRecords();
        
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Qty__c = 100;
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c = date.today().addDays(1);
        controller.vendorTempStop.Temp_Stop__r.Restart_Date__c = date.today().addDays(11);
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Stop_Date__c = date.today().addDays(10);        
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Start_Date__c = date.today().addDays(-1);
        controller.setVendorTempStopRecords();
        
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Qty__c = 100;
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c = date.today().addDays(1);
        controller.vendorTempStop.Temp_Stop__r.Restart_Date__c = date.today().addDays(11);
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Stop_Date__c = date.today().addDays(11);        
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Start_Date__c = date.today().addDays(-1);
        controller.setVendorTempStopRecords();
        
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Qty__c = 100;
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c = date.today().addDays(1);
        controller.vendorTempStop.Temp_Stop__r.Restart_Date__c = date.today().addDays(211);
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Stop_Date__c = date.today().addDays(212);        
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Start_Date__c = date.today().addDays(-1);
        controller.requestSource = 'Call';
        controller.setVendorTempStopRecords();
        
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Qty__c = 100;
        controller.vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c = date.today().addDays(1);
        controller.vendorTempStop.Temp_Stop__r.Restart_Date__c = date.today().addDays(211);
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Stop_Date__c = date.today().addDays(212);        
        controller.vendorTempStop.Subscription_Vendor__r.Subscription_Start_Date__c = date.today().addDays(-1);
        controller.requestSource = 'Eshop';
        controller.setVendorTempStopRecords();
        controller.checkDuplicateTempStopToUpdate();  
        
        controller.followUpTask = TRUE;
        controller.submit();
                
        controller.removeTempStopToUpdate();
        
        Test.stopTest();
    }
    
    /*@description: This test method executes the method setVendorTempStopRecord() 
    *           when selectedTempStopType is globalvariableclass.TS_RADIO_CANCEL_TEMP_STOP*/
    static testmethod void testSetVendorTempStopRecordPart2() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Date_Since__c = date.today();
        acc.Contact_Person__c = 'Me';
        acc.AccountNumber = '0000-1111';
        acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
        acc.Status__c = 'Active';
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
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
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
        
        database.insert(order);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        database.insert(cas);
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subsVen.Account__c = acc.id;
        subsVen.Order_Number__c = order.id;
        subsVen.Recipient__c = con.id;
        subsVen.Vendor__c = acc.id;
        subsVen.Subscription_Start_Date__c = date.today().addDays(1);
        subsVen.Subscription_Stop_Date__c = date.today().addDays(5);
        subsVen.Status__c = 'Active';
        database.insert(subsVen);
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'M';
        pub.Publish_Pattern__c = 'Weekdays';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];    
        npub.Name = 'Test 2';
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'M';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        database.insert(pubList);       
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pubList[0].id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);   
        
        Temp_Stop__c tempStop = new Temp_Stop__c();
        tempStop.Case__c = cas.id;
        tempStop.Order__c = order.id;
        tempStop.Temp_Stop_Date__c = date.today().addDays(1);
        database.insert(tempStop);
        
        Vendor_Temp_Stop__c venTempStop = new Vendor_Temp_Stop__c();
        venTempStop.Publication__c = pubList[0].id;
        venTempStop.Subscription_Vendor__c = subsVen.id;
        venTempStop.Temp_Stop__c = tempStop.id;
        database.insert(ventempStop);
        
        Subscription_Vendor_Publication__c subsVenPub = TestDataFactory.createSubVendorPublication(1)[0];
        subsVenPub.Account__c = acc.id;
        subsVenPub.Order__c = order.id;
        subsVenPub.Publication__c = pubList[0].id;
        subsVenPub.Subscription_Vendor__c = subsVen.id;
        subsVenPub.Mon__c = 0;
        subsVenPub.Tue__c = 1;
        subsVenPub.Wed__c = 2;
        subsVenPub.Thu__c = 3;
        subsVenPub.Fri__c = 4;
        subsVenPub.Sat__c = 5;
        subsVenPub.Sun__c = 6;
        database.insert(subsVenPub);
        
        Non_Publication_Day__c npubday = [SELECT Id
                                         FROM Non_Publication_Day__c
                                         WHERE Publication__c =: pubList[0].id];
        
        System.assertEquals(nonPubList[0].id, npubday.id);
        
        Test.startTest();
        
        PageReference pgRef = Page.VendorTempStopSubs;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('accountId', acc.id);
        VendorTempStopController controller = new VendorTempStopController();
        
        controller.vendorTempStop = venTempStop;
        controller.myIdCancel = venTempStop.id;
        controller.setTempStopType(globalvariableclass.TS_RADIO_CANCEL_TEMP_STOP);
        controller.setVendorTempStopRecords();
        controller.checkDuplicateTempStopToCancel();
        
        controller.followUpTask = TRUE;
        controller.submit();
        
        controller.removeTempStopToCancel();
        
        Test.stopTest();
    }
    
    static testmethod void newTest001() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        acc.Date_Since__c = date.today();
        acc.Contact_Person__c = 'Me';
        acc.AccountNumber = '0000-1111';
        acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor');
        acc.Status__c = 'Active';
        database.insert(acc);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Credit_Balance__c = 50000.00;
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
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        order.Billing_Type__c = 'Full Prepaid';
        database.insert(order);
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        database.insert(cas);
        
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
        subsVen.Account__c = acc.id;
        subsVen.Order_Number__c = order.id;
        subsVen.Recipient__c = con.id;
        subsVen.Vendor__c = acc.id;
        subsVen.Subscription_Start_Date__c = date.today().addDays(1);
        subsVen.Subscription_Stop_Date__c = date.today().addDays(5);
        subsVen.Status__c = 'Active';
        database.insert(subsVen);
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'M';
        pub.Publish_Pattern__c = 'Weekdays';
        pub.Earliest_Start_Date__c = date.today().addDays(1);
        pubList.add(pub);        
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];    
        npub.Name = 'Test 2';
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'M';
        npub.Publish_Pattern__c = 'Weekdays';
        npub.Earliest_Start_Date__c = date.today().addDays(2);
        pubList.add(npub);
        database.insert(pubList);       
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pubList[0].id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);   
        
        Temp_Stop__c tempStop = new Temp_Stop__c();
        tempStop.Case__c = cas.id;
        tempStop.Order__c = order.id;
        tempStop.Temp_Stop_Date__c = date.today().addDays(1);
        tempStop.Restart_Date__c = date.today().addDays(2);
        database.insert(tempStop);
        
        Vendor_Temp_Stop__c venTempStop = new Vendor_Temp_Stop__c();
        venTempStop.Publication__c = pubList[0].id;
        venTempStop.Subscription_Vendor__c = subsVen.id;
        venTempStop.Temp_Stop__c = tempStop.id;
        database.insert(ventempStop);
        
        Subscription_Vendor_Publication__c subsVenPub = TestDataFactory.createSubVendorPublication(1)[0];
        subsVenPub.Account__c = acc.id;
        subsVenPub.Order__c = order.id;
        subsVenPub.Publication__c = pubList[0].id;
        subsVenPub.Subscription_Vendor__c = subsVen.id;
        subsVenPub.Mon__c = 0;
        subsVenPub.Tue__c = 1;
        subsVenPub.Wed__c = 2;
        subsVenPub.Thu__c = 3;
        subsVenPub.Fri__c = 4;
        subsVenPub.Sat__c = 5;
        subsVenPub.Sun__c = 6;
        database.insert(subsVenPub);
        
        Non_Publication_Day__c npubday = [SELECT Id
                                         FROM Non_Publication_Day__c
                                         WHERE Publication__c =: pubList[0].id];
        
        System.assertEquals(nonPubList[0].id, npubday.id);
        
        Test.startTest();
        
        PageReference pgRef = Page.VendorTempStopSubs;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('accountId', acc.id);
        VendorTempStopController vencont = new VendorTempStopController();
        vencont.myId = 'subsVen.id';
        VendorTempStopController.SubscriptionWrapper subwrap1 = new VendorTempStopController.SubscriptionWrapper();
        subwrap1.subId = 'subsVen.id';
        VendorTempStopController.SelectedWrapper selwrap1 = new VendorTempStopController.SelectedWrapper();
        selwrap1.tp1 = tempStop;
        selwrap1.tempStopId = tempStop.id;
        selwrap1.tempStopQty = 1;
        List<VendorTempStopController.SelectedWrapper> selwrap1List = new List<VendorTempStopController.SelectedWrapper>();
        selwrap1List.add(selwrap1);
        vencont.tempStopRequestList = selwrap1List;
        vencont.tempStop = '';
        vencont.restartDate = '';
        vencont.order = order;
        vencont.subfreq = '';
        vencont.isPubDay = true;
        vencont.vendStopId = '';
        vencont.myColor = '';
        subwrap1.tempStopQty = 1.0;
        subwrap1.tempStopDate = date.Today();
        subwrap1.tempStopToUpdate = tempStop.id;
        selwrap1.subStartDate = date.Today();
        selwrap1.subEndDate = date.Today()+1;
        selwrap1.pubCode = '';
        selwrap1.isShown = true;
        
        try{
            vencont.tempstopwrapper = selwrap1;
            vencont.createRecordsOnSave();
        }catch(Exception e){}
        
        vencont.removeSubscriptionRecord();
        try{
            vencont.checkDuplicateSubscription();
        }catch(Exception e){}
        
        Test.stopTest();
        }
  }