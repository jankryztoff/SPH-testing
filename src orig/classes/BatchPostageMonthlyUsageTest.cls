/**
 * Class Name: <BatchPostageMonthlyUsageTest>
 * @author: <Flores, Emmanuel>
 * Date: <7/2/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for BatchPostageMonthlyUsage>
 */
@isTest(seeAllData = false)
private class BatchPostageMonthlyUsageTest {

    
    static testmethod void unitTest() {
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        List<Contact> contacts = TestDataFactory.createContact(1);
        for (Contact con : contacts) {
            con.Company_Name__c = 'Test';
            //con.Recipient_Indicator__c = TRUE;
        }
        Database.insert(contacts);
        
        BatchPostageMonthlyUsage batch = new BatchPostageMonthlyUsage();
        //ID batchprocessid = Database.executeBatch(batch,1);
        //System.assertNotEquals(null, batchprocessid);
        
        Database.BatchableContext bcTemp;
        batch.start(bcTemp);
        batch.execute(bcTemp, contacts);
        batch.finish(bcTemp);
        }
         catch(Zuora.zRemoteException e) {
          }
    } 
    
    static testmethod void unitTest2() {
        Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            insert(key); 


        Other__c other = new Other__c();
           other.Name = 'DTL';
           other.Value__c = '23:59';
           insert(other); 
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir); 
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            
            Date referenceDate = UsageHelper.getUsagereferenceDate();
          
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.Building_Name__c = 'Test Building';
            postal.Street_Name__c = 'Test';
            insert postal;
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.Name = 'Test';
            acc.AccountNumber = '12345';
            insert acc;
    
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Unit_Number__c = 'yy';
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Address_Unique_ID__c = 'test123';
            insert addressRec;
            
            List<Contact> con = TestDataFactory.createContact(1);
            con[0].AccountId = acc.Id;
            con[0].Address__c = addressRec.id;
            con[0].Recipient_Indicator__c = true;
           // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            insert con;
            
            Set<Id> conIdSet = new Set<Id>();
            conIdSet.add(con[0].Id);
           
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Zuora__AccountNumber__c = '12345';
            billAcc.Billing_Type__c = 'Full Prepaid';
            billAcc.Zuora__DefaultPaymentMethod__c  = 'Other';
            insert billAcc;
            
            
            
            Package__c pack =  TestDataFactory.createPackage(1)[0];
            pack.Package_Price__c = 10.00;
            pack.Package_Type__c = 'Bundle';
            insert pack;
      
            
             List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1);
                for(Zuora__Subscription__c zSub : sub){
                    zSub.Zuora__Account__c = acc.Id;
                    zSub.Vendor_1__c = acc.Id;
                    zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
                    zSub.Recipient_Contact__c = con[0].Id;
                    zSub.Other_PaymentMethod_1__c = 'Freelist';
                    zSub.Number_of_Copies__c = 100;
                    //zSub.Order_Number_1__c = order.Id;
                   //zSub.Order_Line_Item_Number_1__c = oli.Id;
                    zSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
                    zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
                    zSub.Invoice_Line_Item_Charge__c = 0;
                    zSub.Zuora__CustomerAccount__c = billAcc.Id;
                    zSub.Billing_Type__c = 'Recurring Postpaid';
                    zSub.Zuora__SubscriptionStartDate__c = System.today().toStartOfMonth();// referenceDate.addMonths(1).toStartOfMonth().addDays(-1);
                    //zSub.Zuora__SubscriptionEndDate__c = null;
                    zSub.Zuora__SubscriptionEndDate__c = date.Today().addDays(20); //referenceDate.addMonths(1).toStartOfMonth().addDays(10);
                    zSub.New_Contract_Period_1__c = 2;
                    zSub.Contract_End_Date_1__c = date.today().addDays(30);
                    zSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
                    //zSub.Zuora__Status__c = GlobalVariableClass.STATUS_CANCELLED;
                    zSub.Term_Length__c = 1;
                    zSub.Term_Length1__c = '1';
                    zSub.Main_Package_1__c = pack.Id;
                    zSub.Main_Package__c = pack.id;
                    
                }    
            insert sub;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con[0].Id;
            order.Subscriber_Charge__c = 100.00;
            order.Base_Subscription__c = sub[0].id;
            order.Status__c = 'Void';
            //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
            order.Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
            order.Urgent_Stop__c = true;
            order.isWaive__c = true;
            database.insert (order);
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Start_Date__c = sub[0].Zuora__SubscriptionEndDate__c.addDays(1);
            orderLineItem.Main_Package_ID__c = pack.id;
            orderLineItem.amount_to_refund__c = 100.00;
            orderLineItem.Subscription__c = sub[0].id;
            orderLineItem.fee_override__c = false;
            orderLineItem.admin_charge__c = 2.00;
            database.insert(orderLineItem);
            
            
            BatchPostageMonthlyUsage batch = new BatchPostageMonthlyUsage();
            Database.BatchableContext bcTemp;
            batch.start(bcTemp);
            batch.execute(bcTemp, con);
            batch.finish(bcTemp);
             }
             catch(Zuora.zRemoteException e) {
              }
    }
    
    static testmethod void unitTest3() {
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Date referenceDate = UsageHelper.getUsagereferenceDate();
      
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.Building_Name__c = 'Test Building';
        postal.Street_Name__c = 'Test';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'Test';
        acc.AccountNumber = '12345';
        insert acc;

        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Unit_Number__c = 'yy';
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Address_Unique_ID__c = 'test123';
        insert addressRec;
        
        List<Contact> contacts = TestDataFactory.createContact(2);
        for (Contact con : contacts) {
            con.Company_Name__c = 'Test';
            con.Address__c = addressRec.Id;
        }
        Database.insert(contacts);
        
        Set<Id> conIdSet = new Set<Id>();
        for (Contact con : contacts) {
            conIdSet.add(con.Id);
        }
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '12345';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c  = 'Other';
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        insert order; 
        
        Package__c pack =  TestDataFactory.createPackage(1)[0];
        pack.Package_Price__c = 10.00;
        pack.Package_Type__c = 'Bundle';
        insert pack;
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Main_Package_Product_Sub_Type__c = 'Test';
        oli.Order__c = order.Id;
        oli.Main_Package_ID__c = pack.Id;
        insert oli;
        
         List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1);
            for(Zuora__Subscription__c zSub : sub){
                zSub.Zuora__Account__c = acc.Id;
                zSub.Vendor_1__c = acc.Id;
                zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
                zSub.Recipient_Contact__c = contacts[0].Id;
                zSub.Other_PaymentMethod_1__c = 'Freelist';
                zSub.Number_of_Copies__c = 100;
                zSub.Order_Number_1__c = order.Id;
                zSub.Order_Line_Item_Number_1__c = oli.Id;
                zSub.Main_Package_1__c = pack.Id;
                zSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
                zSub.Invoice_Line_Item_Charge__c = 0;
                zSub.Zuora__CustomerAccount__c = billAcc.Id;
                zSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
                zSub.Zuora__SubscriptionStartDate__c = System.today().toStartOfMonth();//referenceDate.addMonths(1).toStartOfMonth().addDays(-1);
                zSub.Zuora__SubscriptionEndDate__c = null;
                //zSub.Zuora__SubscriptionEndDate__c = referenceDate.addMonths(1).toStartOfMonth().addDays(10);
                zSub.New_Contract_Period_1__c = 2;
                zSub.Contract_End_Date_1__c = date.today().addDays(30);
                zSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
                //zSub.Zuora__Status__c = GlobalVariableClass.STATUS_CANCELLED;
            }    
        insert sub;
        
        BatchPostageMonthlyUsage batch = new BatchPostageMonthlyUsage();
        Database.BatchableContext bcTemp;
        batch.start(bcTemp);
        batch.execute(bcTemp, contacts);
        batch.finish(bcTemp);
         }
         catch(Zuora.zRemoteException e) {
          }
    }
    
    static testmethod void unitTest3B() {
    try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        Date referenceDate = UsageHelper.getUsagereferenceDate();
      
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.Building_Name__c = 'Test Building';
        postal.Street_Name__c = 'Test';
        insert postal;
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'Test';
        acc.AccountNumber = '12345';
        insert acc;

        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Unit_Number__c = 'yy';
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Address_Unique_ID__c = 'test123';
        insert addressRec;
        
        List<Contact> contacts = TestDataFactory.createContact(2);
        for (Contact con : contacts) {
            con.Company_Name__c = 'Test';
            con.Address__c = addressRec.Id;
        }
        Database.insert(contacts);
        
        Set<Id> conIdSet = new Set<Id>();
        for (Contact con : contacts) {
            conIdSet.add(con.Id);
        }
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__AccountNumber__c = '12345';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c  = 'Other';
        insert billAcc;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        insert order; 
        
        Package__c pack =  TestDataFactory.createPackage(1)[0];
        pack.Package_Price__c = 10.00;
        pack.Package_Type__c = 'Bundle';
        insert pack;
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Main_Package_Product_Sub_Type__c = 'Test';
        oli.Order__c = order.Id;
        oli.Main_Package_ID__c = pack.Id;
        insert oli;
        
         List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(1);
            for(Zuora__Subscription__c zSub : sub){
                zSub.Zuora__Account__c = acc.Id;
                zSub.Vendor_1__c = acc.Id;
                zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
                zSub.Recipient_Contact__c = contacts[0].Id;
                zSub.Other_PaymentMethod_1__c = 'Freelist';
                zSub.Number_of_Copies__c = 100;
                zSub.Order_Number_1__c = order.Id;
                zSub.Order_Line_Item_Number_1__c = oli.Id;
                zSub.Main_Package_1__c = pack.Id;
                zSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
                zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE;
                zSub.Invoice_Line_Item_Charge__c = 0;
                zSub.Zuora__CustomerAccount__c = billAcc.Id;
                zSub.Billing_Type__c = GlobalVariableClass.RECURRING_POSTPAID;
                zSub.Zuora__SubscriptionStartDate__c = referenceDate.toStartOfMonth();
                //zSub.Zuora__SubscriptionEndDate__c = null;
                zSub.Zuora__SubscriptionEndDate__c = referenceDate.toStartOfMonth().addDays(2);
                //zSub.Zuora__SubscriptionEndDate__c = referenceDate.addMonths(1).toStartOfMonth().addDays(10);
                zSub.New_Contract_Period_1__c = 2;
                zSub.Contract_End_Date_1__c = date.today().addDays(30);
                zSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
                
                //zSub.Zuora__Status__c = GlobalVariableClass.STATUS_CANCELLED;
            }    
        insert sub;
        
        BatchPostageMonthlyUsage batch = new BatchPostageMonthlyUsage();
        Database.BatchableContext bcTemp;
        batch.start(bcTemp);
        batch.execute(bcTemp, contacts);
        batch.finish(bcTemp);
         }
         catch(Zuora.zRemoteException e) {
          }
    }
    
    static testmethod void unitTest4() {

        Set<String> stringSet;
            stringSet.add('0125adv');
        Integer type = 1;

        BatchPostageMonthlyUsage newbatch = new BatchPostageMonthlyUsage(stringSet, type);
        ID batchprocessid = Database.executeBatch(newbatch,200);
        System.assertNotEquals(null, batchprocessid);
        
    } 
 }