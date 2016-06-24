/**
 * Class Name: <createCaseTest>
 * @author: <KristineCampang>
 * Date: <8/16/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for createCase>
 */

@isTest (seeAllData= True)
public class createCaseTest{


    static testMethod void testCreateCase(){
        //variables
        List<Account> accRecList = new List<Account>();
        List<Order__c> orderList = new List<Order__c>();
        List<Order__c> orderListVendor = new List<Order__c>();
        List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Vendor__c> orderLineItemVendorList = new List<Order_Line_Item_Vendor__c>(); 
        List<Zuora__CustomerAccount__c> billingAccountList = new List<Zuora__CustomerAccount__c>();
        List<Contact> contactList = new List<Contact>();
        List<Address__c> addList = new List<Address__c>();
        List<Singpost_Address__c> singPostList = new List<Singpost_Address__c>();
        List<Package__c> packageList = new List<Package__c>();
        List<Case> caseList = new List<Case>();
        Map<Id, Id> mapOrder_Case = new Map<Id, Id>();
        
    
        
        //adding account Records
        accRecList.addAll(TestDataFactory.createAccount(1, 'Direct Corporate'));
        accRecList.addAll(TestDataFactory.createAccount(1, 'Vendor Subscriber'));
        insert accRecList;
        
        //adding Billing Contact Records
        billingAccountList = TestDataFactory.createBillingAccount(2);
        billingAccountList[0].Zuora__Account__c = accRecList[0].id;
        billingAccountList[1].Zuora__Account__c = accRecList[1].id;
        insert billingAccountList;

        
        //adding Singpost Address
        singPostList = TestDataFactory.createSingpostAddress(2);    
        insert singPostList;
        
        //adding Package Records
        packageList = TestDataFactory.createPackage(5);
        insert packageList;
        
        //adding Address List
        addList = TestDataFactory.createAddress(1);
        addList[0].Postal_Code__c = singPostList[0].Id;
        insert addList;
        
         //adding Contact Records
        contactList = TestDataFactory.createContact(5);
        contactList[1].Address__c = addList[0].Id; 
        contactList[1].AccountId = accRecList[0].Id;
        //START CCB.002 Modified by: Francis Benzon
        contactList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contactList[1].Recipient_Indicator__c = true;
        
        contactList[2].Address__c = addList[0].Id; 
        contactList[2].AccountId = accRecList[1].Id;
        contactList[2].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contactList[2].Recipient_Indicator__c = true;
        
        //contactList[3].Address__c = addList[0].Id; 
        contactList[3].AccountId = accRecList[0].Id;
        //START CCB.002 Modified by: Francis Benzon
        contactList[3].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        contactList[3].Recipient_Indicator__c = true;
        //END CCB.002 Modified by: Francis Benzon
        insert contactList;
        
        system.debug('accRecList deb:'+accRecList[0]);
        system.debug('accRecList rectype deb:'+accRecList[0].RecordTypeId);
        
        //create a new Order Record
        //first Order Record for Direct
        orderList = TestDataFactory.createOrder(3);
        system.debug('orderList deb:'+orderList);
        orderList[0].Account__c = accRecList[0].Id;
        orderList[0].Billing_Account__c= billingAccountList[0].Id;
        orderList[0].Recipient_Contact__c= contactList[1].Id;
        orderList[0].Acquisition_Type__c= 'Call';
        orderList[0].Remarks__c= 'Good Job!';
        orderList[0].Stop_Request_Date__c = Date.today();
        orderList[0].isOrderLegacy__c = true; //EGC 4/9/2016 added this field
        orderList[1].Account__c = accRecList[0].Id;
        orderList[1].Billing_Account__c= billingAccountList[0].Id;
        orderList[1].Recipient_Contact__c= contactList[3].Id;
        orderList[1].Acquisition_Type__c= 'Call';
        orderList[1].Remarks__c= 'Good Job!';
        orderList[1].Stop_Request_Date__c = Date.today();
        orderList[1].isOrderLegacy__c = true; //EGC 4/9/2016 added this field
        orderList[2].Account__c = accRecList[0].Id;
        orderList[2].Billing_Account__c= billingAccountList[0].Id;
        //orderList[2].Recipient_Contact__c= contactList[3].Id;
        orderList[2].Acquisition_Type__c= 'Call';
        orderList[2].Remarks__c= 'Good Job!';
        orderList[2].Stop_Request_Date__c = Date.today();
        orderList[2].isOrderLegacy__c = true; //EGC 4/9/2016 added this field
        insert orderList;        
        
        system.debug('orderList[0] deb:'+orderList[0]);
        
        //Second Order Record for Vendor 
        orderListVendor = TestDataFactory.createOrder(1);
        orderListVendor[0].Account__c = accRecList[1].Id;
        orderListVendor[0].Billing_Account__c= billingAccountList[1].Id;
        orderListVendor[0].Recipient_Contact__c= contactList[2].Id;
        //orderListVendor[0].Billing_Contact__c = contactList[3].Id;
        orderListVendor[0].Informed_Customer__c = TRUE;
        orderListVendor[0].Acquisition_Type__c= 'Call';
        orderListVendor[0].Remarks__c= 'Good Job Vendor!';
        orderListVendor[0].Stop_Request_Date__c = Date.Today().addDays(1);
        orderListVendor[0].isOrderLegacy__c = true; //EGC 4/9/2016 added this field
        insert orderListVendor;
        
        system.debug('orderListVendor[0] deb:'+orderListVendor[0]);
        
        caseList = [SELECT Id, Order__c
                     FROM Case
                     WHERE (Order__c IN :orderList) OR (Order__c IN :orderListVendor)];   //|| orderListVendor
        for (Case cRec: caseList)
        {
            mapOrder_Case.put(cRec.Order__c, cRec.Id);
        }
        

        //create Order Line Items
        orderLineItemList = TestDataFactory.createOrderLineItem(3); //adding records to the list
        orderLineItemList[0].Order__c = orderList[0].Id;
        orderLineItemList[0].Main_Package_ID__c = packageList[0].Id;
        orderLineItemList[0].Start_Date__c = Date.Today().addDays(2);
        orderLineItemList[0].Earliest_Start_Date__c = Date.Today().addDays(5);
        orderLineItemList[1].Order__c = orderList[0].Id;
        orderLineItemList[1].Main_Package_ID__c = packageList[1].Id;
        orderLineItemList[2].Order__c = orderList[1].Id;
        orderLineItemList[2].Main_Package_ID__c = packageList[2].Id;
        orderLineItemList[2].Start_Date__c = Date.Today().addDays(2);
        orderLineItemList[2].Earliest_Start_Date__c = Date.Today();
        orderLineItemList[2].Urgent_Stop__c = true;
        orderLineItemList[2].Fee_Waiver__c = true;

        
        
        insert orderLineItemList;
        
        //create Order Line Item Vendors
        orderLineItemVendorList = TestDataFactory.createOrderLineItemVendor(3); //adding records to the list
        orderLineItemVendorList[0].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[0].Start_Date__c = Date.today().addDays(1);
        orderLineItemVendorList[0].Stop_Date__c = date.today().addDays(30);
        orderLineItemVendorList[0].Urgent__c = true;
        orderLineItemVendorList[1].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[1].Start_Date__c = date.today().addDays(1);
        orderLineItemVendorList[1].Stop_Date__c = date.today().addDays(30);
        orderLineItemVendorList[2].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[2].Start_Date__c = date.today().addDays(1);
        orderLineItemVendorList[2].Stop_Date__c = date.today().addDays(30);
        insert orderLineItemVendorList; 
        
        Test.startTest();
        createCase cc = new createCase();
        cc.createCase2(orderList, true);
        cc.createCase2(orderList, false);
        cc.UpdateOrderLineItems(mapOrder_Case, true);
        cc.UpdateOrderLineItems(mapOrder_Case, false);
        Test.stopTest();
        
    }
    
    static testMethod void testCreateCaseForStopSubscription(){
        //variables
        List<Account> accRecList = new List<Account>();
        List<Order__c> orderList = new List<Order__c>();
        List<Order__c> orderListVendor = new List<Order__c>();
        List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Vendor__c> orderLineItemVendorList = new List<Order_Line_Item_Vendor__c>(); 
        List<Zuora__CustomerAccount__c> billingAccountList = new List<Zuora__CustomerAccount__c>();
        List<Contact> contactList = new List<Contact>();
        List<Address__c> addList = new List<Address__c>();
        List<Singpost_Address__c> singPostList = new List<Singpost_Address__c>();
        List<Package__c> packageList = new List<Package__c>();
        List<Case> caseList = new List<Case>();
        Map<Id, Id> mapOrder_Case = new Map<Id, Id>();
        
        
    
        
        //adding account Records
        accRecList.addAll(TestDataFactory.createAccount(1, 'Direct Corporate'));
        accRecList.addAll(TestDataFactory.createAccount(1, 'Vendor Subscriber'));
        insert accRecList;
        
        //adding Billing Contact Records
        billingAccountList = TestDataFactory.createBillingAccount(2);
        billingAccountList[0].Zuora__Account__c = accRecList[0].id;
        billingAccountList[1].Zuora__Account__c = accRecList[1].id;
        insert billingAccountList;

        
        //adding Singpost Address
        singPostList = TestDataFactory.createSingpostAddress(2);    
        insert singPostList;
        
        //adding Package Records
        packageList = TestDataFactory.createPackage(5);
        insert packageList;
        
        //adding Address List
        addList = TestDataFactory.createAddress(1);
        addList[0].Postal_Code__c = singPostList[0].Id;
        insert addList;
        
         //adding Contact Records
        contactList = TestDataFactory.createContact(5);
        contactList[1].Address__c = addList[0].Id; 
        contactList[1].AccountId = accRecList[0].Id;
        contactList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        contactList[1].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        contactList[2].Address__c = addList[0].Id; 
        contactList[2].AccountId = accRecList[1].Id;
        contactList[2].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        contactList[2].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert contactList;
        
        
        system.debug('accRecList deb:'+accRecList[0]);
        system.debug('accRecList rectype deb:'+accRecList[0].RecordTypeId);
        
        //create a new Order Record
        //first Order Record for Direct
        orderList = TestDataFactory.createOrder(1);
        system.debug('orderList deb:'+orderList);
        orderList[0].Account__c = accRecList[0].Id;
        orderList[0].Billing_Account__c= billingAccountList[0].Id;
        orderList[0].Recipient_Contact__c= contactList[1].Id;
        //orderList[0].Billing_Contact__c = contactList[1].Id;
        orderList[0].Acquisition_Type__c= 'Call';
        orderList[0].Remarks__c= 'Good Job!';
        orderList[0].Stop_Request_Date__c = Date.today();
        orderList[0].isOrderLegacy__c = true; //EGC 4/9/2016 added this field
        orderList[0].Urgent_Stop__c = true;
        insert orderList;
        
        system.debug('orderList[0] deb:'+orderList[0]);
        
        //Second Order Record for Vendor 
        orderListVendor = TestDataFactory.createOrder(1);
        orderListVendor[0].Account__c = accRecList[1].Id;
        orderListVendor[0].Billing_Account__c= billingAccountList[1].Id;
        orderListVendor[0].Recipient_Contact__c= contactList[2].Id;
        //orderListVendor[0].Billing_Contact__c = contactList[2].Id;
        orderListVendor[0].Informed_Customer__c = TRUE;
        orderListVendor[0].Acquisition_Type__c= 'Call';
        orderListVendor[0].Remarks__c= 'Good Job Vendor!';
        orderListVendor[0].Stop_Request_Date__c = Date.today();
        orderListVendor[0].isOrderLegacy__c = true; //EGC 4/9/2016 added this field
        insert orderListVendor;
        
        system.debug('orderListVendor[0] deb:'+orderListVendor[0]);
        
        caseList = [SELECT Id, Order__c
                     FROM Case
                     WHERE (Order__c IN :orderList) OR (Order__c IN :orderListVendor)];   //|| orderListVendor
        for (Case cRec: caseList)
        {
            mapOrder_Case.put(cRec.Order__c, cRec.Id);
        }
        

        //create Order Line Items
        orderLineItemList = TestDataFactory.createOrderLineItem(3); //adding records to the list
        orderLineItemList[0].Order__c = orderList[0].Id;
        orderLineItemList[0].Main_Package_ID__c = packageList[0].Id;
        orderLineItemList[0].Start_Date__c = Date.Today().addDays(2);
        orderLineItemList[0].Earliest_Start_Date__c = Date.Today().addDays(5);
        orderLineItemList[0].Urgent_Stop__c = true;
        orderLineItemList[0].Fee_Waiver__c = true;
        orderLineItemList[1].Order__c = orderList[0].Id;
        orderLineItemList[1].Main_Package_ID__c = packageList[1].Id;
        orderLineItemList[2].Order__c = orderList[0].Id;
        orderLineItemList[2].Main_Package_ID__c = packageList[2].Id;
        orderLineItemList[2].Start_Date__c = Date.Today().addDays(2);
        orderLineItemList[2].Earliest_Start_Date__c = Date.Today().addDays(-1);
        
        
        insert orderLineItemList;
        
        //create Order Line Item Vendors
        orderLineItemVendorList = TestDataFactory.createOrderLineItemVendor(3); //adding records to the list
        orderLineItemVendorList[0].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[0].Start_Date__c = Date.today().addDays(1);
        orderLineItemVendorList[0].Stop_Date__c = date.today().addDays(30);
        orderLineItemVendorList[0].Urgent__c = true;
        orderLineItemVendorList[0].Earliest_Stop_Date__c = date.today().addDays(5);
        orderLineItemVendorList[1].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[1].Start_Date__c = Date.today().addDays(1);
        orderLineItemVendorList[1].Stop_Date__c = date.today().addDays(30);
        orderLineItemVendorList[1].Earliest_Stop_Date__c = date.today().addDays(2);
        orderLineItemVendorList[2].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[2].Start_Date__c = Date.today().addDays(1);
        orderLineItemVendorList[2].Stop_Date__c = date.today().addDays(30);
        insert orderLineItemVendorList; 
        
        createCase cc = new createCase();
        cc.createCaseForStopSubscription(orderList, true);
        cc.createCaseForStopSubscription(orderList, false);
        cc.createCaseForStopSubscription(orderListVendor, false);
        cc.UpdateOrderLineItems(mapOrder_Case, true);
        cc.UpdateOrderLineItems(mapOrder_Case, false);
        
        
    }
    
    static testMethod void testCreateCaseRenewal(){
        //variables
        List<Account> accRecList = new List<Account>();
        List<Order__c> orderList = new List<Order__c>();
        List<Order__c> orderListVendor = new List<Order__c>();
        List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Vendor__c> orderLineItemVendorList = new List<Order_Line_Item_Vendor__c>(); 
        List<Zuora__CustomerAccount__c> billingAccountList = new List<Zuora__CustomerAccount__c>();
        List<Contact> contactList = new List<Contact>();
        List<Address__c> addList = new List<Address__c>();
        List<Singpost_Address__c> singPostList = new List<Singpost_Address__c>();
        List<Package__c> packageList = new List<Package__c>();
        List<Case> caseList = new List<Case>();
        Map<Id, Id> mapOrder_Case = new Map<Id, Id>();
        
        
    
        
        //adding account Records
        accRecList.addAll(TestDataFactory.createAccount(1, 'Direct Corporate'));
        accRecList.addAll(TestDataFactory.createAccount(1, 'Vendor Subscriber'));
        insert accRecList;
        
        //adding Billing Contact Records
        billingAccountList = TestDataFactory.createBillingAccount(2);
        billingAccountList[0].Zuora__Account__c = accRecList[0].id;
        billingAccountList[1].Zuora__Account__c = accRecList[1].id;
        insert billingAccountList;

        
        //adding Singpost Address
        singPostList = TestDataFactory.createSingpostAddress(2);    
        insert singPostList;
        
        //adding Package Records
        packageList = TestDataFactory.createPackage(5);
        insert packageList;
        
        //adding Address List
        addList = TestDataFactory.createAddress(1);
        addList[0].Postal_Code__c = singPostList[0].Id;
        insert addList;
        
         //adding Contact Records
        contactList = TestDataFactory.createContact(5);
        contactList[1].Address__c = addList[0].Id; 
        contactList[1].AccountId = accRecList[0].Id;
        contactList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        contactList[1].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        contactList[2].Address__c = addList[0].Id; 
        contactList[2].AccountId = accRecList[1].Id;
        contactList[2].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        contactList[2].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        contactList[3].Address__c = addList[0].Id; 
        contactList[3].AccountId = accRecList[0].Id;
        contactList[3].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        contactList[3].Billing_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert contactList;
        
        
        system.debug('accRecList deb:'+accRecList[0]);
        system.debug('accRecList rectype deb:'+accRecList[0].RecordTypeId);
        
        //create a new Order Record
        //first Order Record for Direct
        orderList = TestDataFactory.createOrder(1);
        system.debug('orderList deb:'+orderList);
        orderList[0].Account__c = accRecList[0].Id;
        orderList[0].Billing_Account__c= billingAccountList[0].Id;
        orderList[0].Recipient_Contact__c= contactList[1].Id;
        orderList[0].Billing_Contact__c = contactList[3].Id;
        orderList[0].Acquisition_Type__c= 'Call';
        orderList[0].Remarks__c= 'Good Job!';
        orderList[0].Stop_Request_Date__c = Date.today();
        orderList[0].isOrderLegacy__c = true; //EGC 4/9/2016 added this field
        insert orderList;
        
        system.debug('orderList[0] deb:'+orderList[0]);
        
        //Second Order Record for Vendor 
        orderListVendor = TestDataFactory.createOrder(1);
        orderListVendor[0].Account__c = accRecList[1].Id;
        orderListVendor[0].Billing_Account__c= billingAccountList[1].Id;
        orderListVendor[0].Recipient_Contact__c= contactList[2].Id;
        //orderListVendor[0].Billing_Contact__c = contactList[2].Id;
        orderListVendor[0].Informed_Customer__c = TRUE;
        orderListVendor[0].Acquisition_Type__c= 'Call';
        orderListVendor[0].Remarks__c= 'Good Job Vendor!';
        orderListVendor[0].Stop_Request_Date__c = Date.today();
        orderListVendor[0].isOrderLegacy__c = true; //EGC 4/9/2016 added this field
        insert orderListVendor;
        
        system.debug('orderListVendor[0] deb:'+orderListVendor[0]);
        
        caseList = [SELECT Id, Order__c
                     FROM Case
                     WHERE (Order__c IN :orderList) OR (Order__c IN :orderListVendor)];   //|| orderListVendor
        for (Case cRec: caseList)
        {
            mapOrder_Case.put(cRec.Order__c, cRec.Id);
        }
        

        //create Order Line Items
        orderLineItemList = TestDataFactory.createOrderLineItem(3); //adding records to the list
        orderLineItemList[0].Order__c = orderList[0].Id;
        orderLineItemList[0].Main_Package_ID__c = packageList[0].Id;
        orderLineItemList[0].Start_Date__c = Date.Today().addDays(2);
        orderLineItemList[0].Earliest_Start_Date__c = Date.Today().addDays(5);
        orderLineItemList[1].Order__c = orderList[0].Id;
        orderLineItemList[1].Main_Package_ID__c = packageList[1].Id;
        orderLineItemList[2].Order__c = orderList[0].Id;
        orderLineItemList[2].Main_Package_ID__c = packageList[2].Id;
        orderLineItemList[2].Start_Date__c = Date.Today().addDays(2);
        orderLineItemList[2].Earliest_Start_Date__c = Date.Today().addDays(-1);
        
        
        insert orderLineItemList;
        
        //create Order Line Item Vendors
        orderLineItemVendorList = TestDataFactory.createOrderLineItemVendor(3); //adding records to the list
        orderLineItemVendorList[0].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[0].Start_Date__c = Date.today().addDays(1);
        orderLineItemVendorList[0].Stop_Date__c = date.today().addDays(30);
        orderLineItemVendorList[0].Urgent__c = true;
        orderLineItemVendorList[1].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[1].Start_Date__c = Date.today().addDays(1);
        orderLineItemVendorList[1].Stop_Date__c = date.today().addDays(30);
        orderLineItemVendorList[2].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[2].Start_Date__c = Date.today().addDays(1);
        orderLineItemVendorList[2].Stop_Date__c = date.today().addDays(30);
        insert orderLineItemVendorList; 
        
        createCase cc = new createCase();
        cc.CreateCaseRenewal(orderList, true);
        cc.CreateCaseRenewal(orderList, false);
        cc.CreateCaseRenewal(orderListVendor, false);
        cc.UpdateOrderLineItems(mapOrder_Case, true);
        cc.UpdateOrderLineItems(mapOrder_Case, false);
        
        
    }

    static testMethod void testCreateCaseForChangeofSubscription(){
        //variables
        List<Account> accRecList = new List<Account>();
        List<Order__c> orderList = new List<Order__c>();
        List<Order__c> orderListVendor = new List<Order__c>();
        List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
        List<Order_Line_Item_Vendor__c> orderLineItemVendorList = new List<Order_Line_Item_Vendor__c>(); 
        List<Zuora__CustomerAccount__c> billingAccountList = new List<Zuora__CustomerAccount__c>();
        List<Contact> contactList = new List<Contact>();
        List<Address__c> addList = new List<Address__c>();
        List<Singpost_Address__c> singPostList = new List<Singpost_Address__c>();
        List<Package__c> packageList = new List<Package__c>();
        List<Case> caseList = new List<Case>();
        Map<Id, Id> mapOrder_Case = new Map<Id, Id>();
        
        
    
        
        //adding account Records
        accRecList.addAll(TestDataFactory.createAccount(1, 'Direct Corporate'));
        accRecList.addAll(TestDataFactory.createAccount(1, 'Vendor Subscriber'));
        insert accRecList;
        
        //adding Billing Contact Records
        billingAccountList = TestDataFactory.createBillingAccount(2);
        billingAccountList[0].Zuora__Account__c = accRecList[0].id;
        billingAccountList[1].Zuora__Account__c = accRecList[1].id;
        insert billingAccountList;

        
        //adding Singpost Address
        singPostList = TestDataFactory.createSingpostAddress(2);    
        insert singPostList;
        
        //adding Package Records
        packageList = TestDataFactory.createPackage(5);
        insert packageList;
        
        //adding Address List
        addList = TestDataFactory.createAddress(1);
        addList[0].Postal_Code__c = singPostList[0].Id;
        insert addList;
        
         //adding Contact Records
        contactList = TestDataFactory.createContact(5);
        contactList[1].Address__c = addList[0].Id; 
        contactList[1].AccountId = accRecList[0].Id;
        contactList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        contactList[1].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        contactList[2].Address__c = addList[0].Id; 
        contactList[2].AccountId = accRecList[1].Id;
        contactList[2].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        contactList[2].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert contactList;
        
        system.debug('accRecList deb:'+accRecList[0]);
        system.debug('accRecList rectype deb:'+accRecList[0].RecordTypeId);
        
        //create a new Order Record
        //first Order Record for Direct
        orderList = TestDataFactory.createOrder(1);
        system.debug('orderList deb:'+orderList);
        orderList[0].Account__c = accRecList[0].Id;
        orderList[0].Billing_Account__c= billingAccountList[0].Id;
        orderList[0].Recipient_Contact__c= contactList[1].Id;
        //orderList[0].Billing_Contact__c = contactList[1].Id;
        orderList[0].Acquisition_Type__c= 'Call';
        orderList[0].Remarks__c= 'Good Job!';
        orderList[0].Stop_Request_Date__c = Date.today();
        orderList[0].isOrderLegacy__c = true; //EGC 4/9/2016 added this field
        insert orderList;
        
        //START EGC 4/9/2016
        //Since we are just calling the method here, the orderList must be queried
        List<Order__c> insertedOrder = [SELECT Id, Account__c, Billing_Account__c, Recipient_Contact__c, 
                                        Reason_Code__c, Creation_Mode__c, Order_Action__c, Admin_Charge__c, Effective_Date__c,
                                        Request_for_Waiving_of_Admin_Charge__c, No_Vendor_Needed__c, Recipient_Contact__r.Id, 
                                        Recipient_Contact__r.Address__r.Postal_Code__c, Subscription__c, Recipient_Contact__r.Address__c, 
                                        Acquisition_Type__c, Remarks__c, Stop_Request_Date__c, isOrderLegacy__c, Billing_Contact__c 
                                        FROM Order__c WHERE Id =: orderList[0].Id];
        //END EGC 4/9/2016
        
        system.debug('orderList[0] deb:'+orderList[0]);
        
        //Second Order Record for Vendor 
        orderListVendor = TestDataFactory.createOrder(1);
        orderListVendor[0].Account__c = accRecList[1].Id;
        orderListVendor[0].Billing_Account__c= billingAccountList[1].Id;
        orderListVendor[0].Recipient_Contact__c= contactList[2].Id;
        //orderListVendor[0].Billing_Contact__c = contactList[2].Id;
        orderListVendor[0].Informed_Customer__c = TRUE;
        orderListVendor[0].Acquisition_Type__c= 'Call';
        orderListVendor[0].Remarks__c= 'Good Job Vendor!';
        orderListVendor[0].Stop_Request_Date__c = Date.today();
        orderListVendor[0].isOrderLegacy__c = true; //EGC 4/9/2016 added this field
        insert orderListVendor;
        //cc.CreateCaseForChangeofSubscription(orderListVendor, false);
        
        system.debug('orderListVendor[0] deb:'+orderListVendor[0]);
        
        caseList = [SELECT Id, Order__c
                     FROM Case
                     WHERE (Order__c IN :orderList) OR (Order__c IN :orderListVendor)];   //|| orderListVendor
        for (Case cRec: caseList)
        {
            mapOrder_Case.put(cRec.Order__c, cRec.Id);
        }
        

        //create Order Line Items
        orderLineItemList = TestDataFactory.createOrderLineItem(3); //adding records to the list
        orderLineItemList[0].Order__c = orderList[0].Id;
        orderLineItemList[0].Main_Package_ID__c = packageList[0].Id;
        orderLineItemList[0].Start_Date__c = Date.Today().addDays(2);
        orderLineItemList[0].Earliest_Start_Date__c = Date.Today().addDays(5);
        orderLineItemList[0].Fee_Waiver__c = true;
        orderLineItemList[1].Order__c = orderList[0].Id;
        orderLineItemList[1].Main_Package_ID__c = packageList[1].Id;
        orderLineItemList[2].Order__c = orderList[0].Id;
        orderLineItemList[2].Main_Package_ID__c = packageList[2].Id;
        orderLineItemList[2].Start_Date__c = Date.Today().addDays(2);
        orderLineItemList[2].Earliest_Start_Date__c = Date.Today().addDays(-1);
        
        
        insert orderLineItemList;
        
        //create Order Line Item Vendors
        orderLineItemVendorList = TestDataFactory.createOrderLineItemVendor(3); //adding records to the list
        orderLineItemVendorList[0].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[0].Start_Date__c = Date.today().addDays(1);
        orderLineItemVendorList[0].Stop_Date__c = date.today().addDays(30);
        orderLineItemVendorList[1].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[1].Start_Date__c = Date.today().addDays(1);
        orderLineItemVendorList[1].Stop_Date__c = date.today().addDays(30);
        orderLineItemVendorList[2].Order__c = orderListVendor[0].Id;
        orderLineItemVendorList[2].Start_Date__c = Date.today().addDays(1);
        orderLineItemVendorList[2].Stop_Date__c = date.today().addDays(30);
        insert orderLineItemVendorList; 
        
        createCase cc = new createCase();
        cc.CreateCaseForChangeofSubscription(insertedOrder, true);
        cc.UpdateOrderLineItems(mapOrder_Case, true);
        cc.UpdateOrderLineItems(mapOrder_Case, false);
        
        
    }
}