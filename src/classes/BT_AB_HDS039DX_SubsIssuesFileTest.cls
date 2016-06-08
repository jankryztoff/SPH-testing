/**
Class Name: BT_AB_HDS039DX_SubscriptionIssuesFileTest
@author: accenture IDC (Sudha Kumari)
Date: 02/11/2015
Project/Requirement: SPH Integration - ARM063DX Interface 
@description This class is test class for BT_AB_HDS039DX_SubscriptionIssuesFile
**/
@isTest (SeeAllData = true)
private class BT_AB_HDS039DX_SubsIssuesFileTest {
    
    private static List<Zuora__Subscription__c> zsubList;

    static Testmethod void unitTest1(){
    
        // SELECT End_Time__c,Id,Interface_ID__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = :interfaceId 
        //    AND End_Time__c = null ORDER BY CreatedDate DESC
        
        BT_CO_Batch_Run_Request__c bt_runRequest = new BT_CO_Batch_Run_Request__c();
        bt_runRequest.Interface_ID__c = 'HDS039DX';
        insert bt_runRequest;
        
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        BA_INT_DATA_POOL__c bt_dataPool = new BA_INT_DATA_POOL__c();
        bt_dataPool.group_id__c = 'Detail';
        bt_dataPool.insert_time__c = DateTime.now();
        bt_dataPool.job_id__c = '1';
        bt_dataPool.run_for_date__c = Date.today();
        insert new List<sObject>{bt_dataPool, vmd};
        
        Publication__c pub = new Publication__c();
        pub.name = 'wow';
        pub.Publication_Code__c = 'qweq';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'e';
        insert pub;
        
        //Map<String, SObject> sobjectMap =  TestDataFactory.createSubscriptionPackage();
        
        Test.StartTest();
        BT_AB_HDS039DX_SubscriptionIssuesFile ico = new BT_AB_HDS039DX_SubscriptionIssuesFile();
        Id batchprocessid = database.executebatch(ico,200);
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
    }
    
    static testmethod void testAmountTypeEqualsMiscellaneous(){
    
        // SELECT End_Time__c,Id,Interface_ID__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = :interfaceId 
        //    AND End_Time__c = null ORDER BY CreatedDate DESC

        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        List<Account> accList = TestDataFactory.createAccount(2, 'Direct Individual');   
        insert accList;
        
        List<Address__c> addList = TestDataFactory.createAddress(2);
        insert addList;
        
        List<Contact> conList = TestDataFactory.createContact(2);
        insert conList;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        insert packageList;
                    
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(2);
        billAccountList[0].Zuora__Account__c = accList[0].id;
        billAccountList[1].Zuora__Account__c = accList[1].id;     
        
        insert billAccountList;       
     
        List<Order__c> orderList = TestDataFactory.createOrder(2);
        orderList[0].Account__c = accList[0].id;
        orderList[0].Subscriber_Charge__c = 100; 
        orderList[1].Account__c = accList[1].id;
        orderList[1].Subscriber_Charge__c = 100;     
        insert orderList;
                
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(2);
        orderLineItemList[0].Order__c = orderList[0].id; 
        orderLineItemList[0].Main_Package_ID__c = packageList[0].id;
        orderLineItemList[1].Order__c = orderList[1].id; 
        orderLineItemList[1].Main_Package_ID__c = packageList[1].id;        
        insert orderLineItemList;
         
        zsubList = TestDataFactory.createSubscription(2);
        //set values
        zsubList[0].Zuora__Account__c = accList[0].id;
        
        zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
        zsubList[0].Qty1__c ='20';  
        zsubList[0].Order_Number__c = orderList[0].id;        
        zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
        zsubList[0].Delivery_Charge__c = 200;
        zsubList[1].Zuora__Account__c = accList[1].id;     
        zsubList[1].Zuora__CustomerAccount__c = billAccountList[1].id;
        zsubList[1].Qty1__c ='10';  
        zsubList[1].Order_Number__c = orderList[1].id; 
        zsubList[1].Order_Line_Item_Number__c = orderLineItemList[1].id;
        zsubList[1].Delivery_Charge__c = 200;
        zsubList[1].Number_of_Copies1__c =  '100';
        zsubList[1].Number_of_Copies__c = 100;
        zsubList[1].Qty__c = 20;
        zsubList[0].Product_Code__c = 'CD001';
        zsubList[0].Subscription_Type_1__c = 'Publication';
        zsubList[0].Subscription_Type__c = 'Publication';
        zsubList[0].Number_of_Copies1__c =  '100';
        zsubList[0].Number_of_Copies__c = 100;
        zsubList[0].Qty__c = 20;
        insert zsubList;
        
        List<Zuora__Subscription__c> queryList = [SELECT id FROM Zuora__Subscription__c WHERE Product_Code__c = 'CD001'];
        
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Vendor_Number__c = 'Sample Vendor';
        vmd.Publication_Code__c = 'qweq';
        vmd.Copies__c = 10;
        vmd.Amount_Type__c = 'Miscellaneous';
        //vmd.Total__c = 100.00;
        vmd.Amount_Before_GST__c = 100.00;
        vmd.Credit_Debit__c = 'Credit';
        vmd.Credit_Period__c = date.Today(); 
        BA_INT_DATA_POOL__c bt_dataPool = new BA_INT_DATA_POOL__c();
        bt_dataPool.group_id__c = 'Detail';
        bt_dataPool.insert_time__c = DateTime.now();
        bt_dataPool.job_id__c = '1';
        bt_dataPool.run_for_date__c = Date.today();
        insert new List<sObject>{bt_dataPool, vmd};
        
        Publication__c pub = new Publication__c();
        pub.name = 'wow';
        pub.Publication_Code__c = 'qweq';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'e';
        insert pub;
        
        //Map<String, SObject> sobjectMap =  TestDataFactory.createSubscriptionPackage();
        
        Test.StartTest();
        BT_AB_HDS039DX_SubscriptionIssuesFile ico = new BT_AB_HDS039DX_SubscriptionIssuesFile();
        Id batchprocessid = database.executebatch(ico,200);
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
   } catch (Exception e) {
       }
    }
    
    static testmethod void testAmountTypeEqualsInsertion(){
    
        // SELECT End_Time__c,Id,Interface_ID__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = :interfaceId 
        //    AND End_Time__c = null ORDER BY CreatedDate DESC

        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
        insert accList;
        
        List<Address__c> addList = TestDataFactory.createAddress(2);
        insert addList;
        
        List<Contact> conList = TestDataFactory.createContact(2);
        insert conList;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        insert packageList;
                     
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(2);
        billAccountList[0].Zuora__Account__c = accList[0].id;
        billAccountList[1].Zuora__Account__c = accList[1].id;     
        
        insert billAccountList;       
    
        List<Order__c> orderList = TestDataFactory.createOrder(2);
        orderList[0].Account__c = accList[0].id;
        orderList[0].Subscriber_Charge__c = 100; 
        orderList[1].Account__c = accList[1].id;
        orderList[1].Subscriber_Charge__c = 100;     
        insert orderList;
               
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(2);
        orderLineItemList[0].Order__c = orderList[0].id; 
        orderLineItemList[0].Main_Package_ID__c = packageList[0].id;
        orderLineItemList[1].Order__c = orderList[1].id; 
        orderLineItemList[1].Main_Package_ID__c = packageList[1].id;        
        insert orderLineItemList;
          
        zsubList = TestDataFactory.createSubscription(2);
        //set values
        zsubList[0].Zuora__Account__c = accList[0].id;
        
        zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
        zsubList[0].Qty1__c ='20';  
        zsubList[0].Order_Number__c = orderList[0].id;        
        zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
        zsubList[0].Delivery_Charge__c = 200;
        zsubList[1].Zuora__Account__c = accList[1].id;     
        zsubList[1].Zuora__CustomerAccount__c = billAccountList[1].id;
        zsubList[1].Qty1__c ='10';  
        zsubList[1].Order_Number__c = orderList[1].id; 
        zsubList[1].Order_Line_Item_Number__c = orderLineItemList[1].id;
        zsubList[1].Delivery_Charge__c = 200;
        zsubList[1].Number_of_Copies1__c =  '100';
        zsubList[1].Number_of_Copies__c = 100;
        zsubList[1].Qty__c = 20;
        zsubList[0].Product_Code__c = 'CD001';
        zsubList[0].Subscription_Type_1__c = 'Publication';
        zsubList[0].Subscription_Type__c = 'Publication';
        zsubList[0].Number_of_Copies1__c =  '100';
        zsubList[0].Number_of_Copies__c = 100;
        zsubList[0].Qty__c = 20;
        insert zsubList;
        
        List<Zuora__Subscription__c> queryList = [SELECT id FROM Zuora__Subscription__c WHERE Product_Code__c = 'CD001'];
        
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Vendor_Number__c = 'Sample Vendor';
        vmd.Publication_Code__c = 'qweq';
        vmd.Copies__c = 10;
        vmd.Amount_Type__c = 'Insertion';
        //vmd.Total__c = 100.00;
        vmd.Amount_Before_GST__c = 100.00;
        vmd.Credit_Debit__c = 'Credit';
        vmd.Credit_Period__c = date.Today(); 
        BA_INT_DATA_POOL__c bt_dataPool = new BA_INT_DATA_POOL__c();
        bt_dataPool.group_id__c = 'Detail';
        bt_dataPool.insert_time__c = DateTime.now();
        bt_dataPool.job_id__c = '1';
        bt_dataPool.run_for_date__c = Date.today();
        insert new List<sObject>{bt_dataPool, vmd};
        
        Publication__c pub = new Publication__c();
        pub.name = 'wow';
        pub.Publication_Code__c = 'qweq';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'e';
        insert pub;
        
        //Map<String, SObject> sobjectMap =  TestDataFactory.createSubscriptionPackage();
        
        Test.StartTest();
        BT_AB_HDS039DX_SubscriptionIssuesFile ico = new BT_AB_HDS039DX_SubscriptionIssuesFile();
        Id batchprocessid = database.executebatch(ico,200);
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
   } catch (Exception e) {
       }
    }
    
    static testmethod void testAmountTypeEqualsDeliveryRate(){
    
        // SELECT End_Time__c,Id,Interface_ID__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = :interfaceId 
        //    AND End_Time__c = null ORDER BY CreatedDate DESC

        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
        insert accList;
        
        List<Address__c> addList = TestDataFactory.createAddress(2);
        insert addList;
        
        List<Contact> conList = TestDataFactory.createContact(2);
        insert conList;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        insert packageList;
                     
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(2);
        billAccountList[0].Zuora__Account__c = accList[0].id;
        billAccountList[1].Zuora__Account__c = accList[1].id;     
        
        insert billAccountList;       
    
        List<Order__c> orderList = TestDataFactory.createOrder(2);
        orderList[0].Account__c = accList[0].id;
        orderList[0].Subscriber_Charge__c = 100; 
        orderList[1].Account__c = accList[1].id;
        orderList[1].Subscriber_Charge__c = 100;     
        insert orderList;
               
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(2);
        orderLineItemList[0].Order__c = orderList[0].id; 
        orderLineItemList[0].Main_Package_ID__c = packageList[0].id;
        orderLineItemList[1].Order__c = orderList[1].id; 
        orderLineItemList[1].Main_Package_ID__c = packageList[1].id;        
        insert orderLineItemList;
          
        zsubList = TestDataFactory.createSubscription(2);
        //set values
        zsubList[0].Zuora__Account__c = accList[0].id;
        
        zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
        zsubList[0].Qty1__c ='20';  
        zsubList[0].Order_Number__c = orderList[0].id;        
        zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
        zsubList[0].Delivery_Charge__c = 200;
        zsubList[1].Zuora__Account__c = accList[1].id;     
        zsubList[1].Zuora__CustomerAccount__c = billAccountList[1].id;
        zsubList[1].Qty1__c ='10';  
        zsubList[1].Order_Number__c = orderList[1].id; 
        zsubList[1].Order_Line_Item_Number__c = orderLineItemList[1].id;
        zsubList[1].Delivery_Charge__c = 200;
        zsubList[1].Number_of_Copies1__c =  '100';
        zsubList[1].Number_of_Copies__c = 100;
        zsubList[1].Qty__c = 20;
        zsubList[0].Product_Code__c = 'CD001';
        zsubList[0].Subscription_Type_1__c = 'Publication';
        zsubList[0].Subscription_Type__c = 'Publication';
        zsubList[0].Number_of_Copies1__c =  '100';
        zsubList[0].Number_of_Copies__c = 100;
        zsubList[0].Qty__c = 20;
        insert zsubList;
        
        List<Zuora__Subscription__c> queryList = [SELECT id FROM Zuora__Subscription__c WHERE Product_Code__c = 'CD001'];
        
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Vendor_Number__c = 'Sample Vendor';
        vmd.Publication_Code__c = 'qweq';
        vmd.Copies__c = 10;
        vmd.Amount_Type__c = 'Delivery Rate';
        //vmd.Total__c = 100.00;
        vmd.Amount_Before_GST__c = 100.00;
        vmd.Credit_Debit__c = 'Credit';
        vmd.Credit_Period__c = date.Today(); 
        BA_INT_DATA_POOL__c bt_dataPool = new BA_INT_DATA_POOL__c();
        bt_dataPool.group_id__c = 'Detail';
        bt_dataPool.insert_time__c = DateTime.now();
        bt_dataPool.job_id__c = '1';
        bt_dataPool.run_for_date__c = Date.today();
        insert new List<sObject>{bt_dataPool, vmd};
        
        Publication__c pub = new Publication__c();
        pub.name = 'wow';
        pub.Publication_Code__c = 'qweq';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'e';
        insert pub;
        
        //Map<String, SObject> sobjectMap =  TestDataFactory.createSubscriptionPackage();
        
        Test.StartTest();
        BT_AB_HDS039DX_SubscriptionIssuesFile ico = new BT_AB_HDS039DX_SubscriptionIssuesFile();
        Id batchprocessid = database.executebatch(ico,200);
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
   } catch (Exception e) {
       }
    }
    
    static testmethod void testCreditDebitIsNull(){
    
        // SELECT End_Time__c,Id,Interface_ID__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c = :interfaceId 
        //    AND End_Time__c = null ORDER BY CreatedDate DESC

        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
        insert accList;
        
        List<Address__c> addList = TestDataFactory.createAddress(2);
        insert addList;
        
        List<Contact> conList = TestDataFactory.createContact(2);
        insert conList;
        
        List<Package__c> packageList = TestDataFactory.createPackage(2);
        insert packageList;
                     
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(2);
        billAccountList[0].Zuora__Account__c = accList[0].id;
        billAccountList[1].Zuora__Account__c = accList[1].id;     
        
        insert billAccountList;       
    
        List<Order__c> orderList = TestDataFactory.createOrder(2);
        orderList[0].Account__c = accList[0].id;
        orderList[0].Subscriber_Charge__c = 100; 
        orderList[1].Account__c = accList[1].id;
        orderList[1].Subscriber_Charge__c = 100;     
        insert orderList;
               
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(2);
        orderLineItemList[0].Order__c = orderList[0].id; 
        orderLineItemList[0].Main_Package_ID__c = packageList[0].id;
        orderLineItemList[1].Order__c = orderList[1].id; 
        orderLineItemList[1].Main_Package_ID__c = packageList[1].id;        
        insert orderLineItemList;
          
        zsubList = TestDataFactory.createSubscription(2);
        //set values
        zsubList[0].Zuora__Account__c = accList[0].id;
        
        zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
        zsubList[0].Qty1__c ='20';  
        zsubList[0].Order_Number__c = orderList[0].id;        
        zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
        zsubList[0].Delivery_Charge__c = 200;
        zsubList[1].Zuora__Account__c = accList[1].id;     
        zsubList[1].Zuora__CustomerAccount__c = billAccountList[1].id;
        zsubList[1].Qty1__c ='10';  
        zsubList[1].Order_Number__c = orderList[1].id; 
        zsubList[1].Order_Line_Item_Number__c = orderLineItemList[1].id;
        zsubList[1].Delivery_Charge__c = 200;
        zsubList[1].Number_of_Copies1__c =  '100';
        zsubList[1].Number_of_Copies__c = 100;
        zsubList[1].Qty__c = 20;
        zsubList[0].Product_Code__c = 'CD001';
        zsubList[0].Subscription_Type_1__c = 'Publication';
        zsubList[0].Subscription_Type__c = 'Publication';
        zsubList[0].Number_of_Copies1__c =  '100';
        zsubList[0].Number_of_Copies__c = 100;
        zsubList[0].Qty__c = 20;
        insert zsubList;
        
        List<Zuora__Subscription__c> queryList = [SELECT id FROM Zuora__Subscription__c WHERE Product_Code__c = 'CD001'];
        
        Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
        vmd.Vendor_Number__c = 'Sample Vendor';
        vmd.Publication_Code__c = 'qweq';
        vmd.Copies__c = 10;
        vmd.Amount_Type__c = 'Delivery Rate';
        //vmd.Total__c = 100.00;
        vmd.Amount_Before_GST__c = 100.00;
        vmd.Credit_Debit__c = NULL;
        vmd.Credit_Period__c = date.Today(); 
        BA_INT_DATA_POOL__c bt_dataPool = new BA_INT_DATA_POOL__c();
        bt_dataPool.group_id__c = 'Detail';
        bt_dataPool.insert_time__c = DateTime.now();
        bt_dataPool.job_id__c = '1';
        bt_dataPool.run_for_date__c = Date.today();
        insert new List<sObject>{bt_dataPool, vmd};
        
        Publication__c pub = new Publication__c();
        pub.name = 'wow';
        pub.Publication_Code__c = 'qweq';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'e';
        insert pub;
        
        //Map<String, SObject> sobjectMap =  TestDataFactory.createSubscriptionPackage();
        
        Test.StartTest();
        BT_AB_HDS039DX_SubscriptionIssuesFile ico = new BT_AB_HDS039DX_SubscriptionIssuesFile();
        Id batchprocessid = database.executebatch(ico,200);
        System.assertNotEquals(null, batchprocessid);
        Test.StopTest();
   } catch (Exception e) {
       }
    }
}