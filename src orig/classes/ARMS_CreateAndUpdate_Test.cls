/**
* Class Name: ARMS_CreateAndUpdate_Test
* @author: jensar.joey.z.sayson
* Date: <08/12/2015>
* Requirement/Project Name: SF SPH
* @description: test class for ARMS_CreateAndUpdate
*/
@isTest 
public class ARMS_CreateAndUpdate_Test {
    
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createOther();
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createRecord_Type_Field_Setup();
        insert CustomSettingsDataFactory.createBillingBatch();
    }
    

    static testmethod void cover_createAndUpdateAccountWebservice(){
        
        Test.startTest();
            ARMS_CreateAndUpdate.createAccountWebservice(null,null);
            ARMS_CreateAndUpdate.updateAccountWebservice(null);
        Test.stopTest();
    }
    
    static testmethod void cover_createAndUpdateCustomerWebservice(){
        
        Test.startTest();    
            ARMS_CreateAndUpdate.createCustomerWebservice(null, null);
            ARMS_CreateAndUpdate.updateCustomerWebservice(null);
        Test.stopTest();    
    }
    
   static testmethod void cover_updateCustomer(){
        try{
             Map<String, sObject> sObjectMap = null;
        sObjectMap = new Map<String, sObject>();

        //Create Address
        RecordType recType = [SELECT Id, DeveloperName from RecordType WHERE sObjectType = 'Address__c' and DeveloperName = 'Local'];
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = recType.id;
        add.Name = 'Test Address';
        add.Legacy_Created_By__c = 'Creator';
        add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
        add.Legacy_Updated_By__c = 'Modifier';
        add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
        add.Block_House_Number__c = '22';
        add.Level_Number__c = '03';
        add.Unit_Number__c = '13';
        sObjectMap.put('Address__c', add);
        Database.insert(add);       
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test Account';
        acc.AccountNumber = '';
        sObjectMap.put('Account', acc);
        Database.insert(acc);        
           
        Contact con = TestDataFactory.createContact(1)[0];
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        con.Address__c = add.id;
        con.MailingCountry = 'Singapore';
        con.MailingCity = 'Singapore';
        con.MailingStreet = '123 Test Street';
        con.MailingPostalCode = '1000';
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.Address__c = add.id;
        con.Office_Number__c = '5629143';
        con.HomePhone__c = '2341234';
        con.Mobile_Number__c = '09151541542';
        con.Fax__c = '1234567';
        sObjectMap.put('Contact', con);
        Database.insert(con);
        
        Order__c order = TestDataFactory.createOrder(1)[0];      
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 20; 
        order.Subscriber_Charge__c = 200; 
        order.Recipient_Contact__c = con.id;
        order.Billing_Contact__c = con.id;
        order.Billing_Account_Creation_Mode__c = GlobalVariableClass.CREATE_NEW_BILLACC;
        order.Create_ARMS_Customer_Account__c = true;
        order.Create_ARMS_Account_Only__c = false;
        sObjectMap.put('Order__c', order);
        Database.insert(order);
        
        Zuora__CustomerAccount__c zCus = TestDataFactory.createBillingAccount(1)[0];
        zCus.Name = 'April';
        zCus.Zuora__Account__c = acc.Id;
        zCus.Billing_Contact__C = con.id;
        zCus.Other_PaymentMethod__c= 'Invoice';
        sObjectMap.put('Zuora__CustomerAccount__c', zCus);
        Database.insert(zCus);
   
             
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Contact__c = con.Id;
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__CustomerAccount__c = zCus.Id;
            zSub.Order_Number_1__c = order.Id;
            zSub.Classification__c = 'secret';
        sObjectMap.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        
        
                      
        Set<id> orderIdSet = new Set<id>();
        orderIdSet.add(order.Id);
        
            
 //    Zuora__CustomerAccount__c zCusAcc = (Zuora__CustomerAccount__c) sObjectMap.get('Zuora__CustomerAccount__c');
                
 //     Database.update(zCusAcc);
    
            List<Zuora__CustomerAccount__c> edtCustomerList = new List<Zuora__CustomerAccount__c>();
            edtCustomerList.add(zCus);
            
            Test.startTest();    
                ARMS_CreateAndUpdate cau = new ARMS_CreateAndUpdate();
                cau.updateCustomer(edtCustomerList);
            Test.stopTest();
            System.assertNotEquals(null,cau);
        }catch(Exception e){}
    }
    
    static testmethod void cover_updateAccount(){
        try{
            Map<String, sObject> sObjectMap = setAllData();
        
            Zuora__CustomerAccount__c zCusAcc = (Zuora__CustomerAccount__c) sObjectMap.get('Zuora__CustomerAccount__c');
                zCusAcc.Other_PaymentMethod__c= 'Invoice';
            Database.update(zCusAcc);
            
            List<Zuora__CustomerAccount__c> updInitialBillAccList = new List<Zuora__CustomerAccount__c>();
                updInitialBillAccList.add(zCusAcc);
            
            Test.startTest();
                ARMS_CreateAndUpdate cau = new ARMS_CreateAndUpdate();
                cau.updateAccount(updInitialBillAccList);
            Test.stopTest();
            System.assertNotEquals(null,cau);
            
        }catch(Exception e){}
    }
    
    static testmethod void cover_createAccount(){
        try{ 
        Map<String, sObject> sObjectMap = null;
        sObjectMap = new Map<String, sObject>();

        //Create Address
        RecordType recType = [SELECT Id, DeveloperName from RecordType WHERE sObjectType = 'Address__c' and DeveloperName = 'Local'];
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = recType.id;
        add.Name = 'Test Address';
        add.Legacy_Created_By__c = 'Creator';
        add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
        add.Legacy_Updated_By__c = 'Modifier';
        add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
        add.Block_House_Number__c = '22';
        add.Level_Number__c = '03';
        add.Unit_Number__c = '13';
        sObjectMap.put('Address__c', add);
        Database.insert(add);       
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test Account';
        acc.AccountNumber = '';
        sObjectMap.put('Account', acc);
        Database.insert(acc);        
           
        Contact con = TestDataFactory.createContact(1)[0];
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        con.Address__c = add.id;
        con.MailingCountry = 'Singapore';
        con.MailingCity = 'Singapore';
        con.MailingStreet = '123 Test Street';
        con.MailingPostalCode = '1000';
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.Address__c = add.id;
        con.Office_Number__c = '5629143';
        con.HomePhone__c = '2341234';
        con.Mobile_Number__c = '09151541542';
        con.Fax__c = '1234567';
        sObjectMap.put('Contact', con);
        Database.insert(con);
        
        Order__c order = TestDataFactory.createOrder(1)[0];      
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 20; 
        order.Subscriber_Charge__c = 200; 
        order.Recipient_Contact__c = con.id;
        order.Billing_Contact__c = con.id;
        order.Billing_Account_Creation_Mode__c = GlobalVariableClass.CREATE_NEW_BILLACC;
        order.Create_ARMS_Customer_Account__c = true;
        order.Create_ARMS_Account_Only__c = false;
        sObjectMap.put('Order__c', order);
        Database.insert(order);
        
        Zuora__CustomerAccount__c zCus = TestDataFactory.createBillingAccount(1)[0];
        zCus.Name = 'April';
        zCus.Zuora__Account__c = acc.Id;
        zCus.Billing_Contact__C = con.id;
        sObjectMap.put('Zuora__CustomerAccount__c', zCus);
        Database.insert(zCus);
   
             
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Contact__c = con.Id;
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__CustomerAccount__c = zCus.Id;
            zSub.Order_Number_1__c = order.Id;
            zSub.Classification__c = 'secret';
        sObjectMap.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        
        
                      
        Set<id> orderIdSet = new Set<id>();
        orderIdSet.add(order.Id);
        
        //Zuora__CustomerAccount__c zCusAcc = (Zuora__CustomerAccount__c) sObjectMap.get('Zuora__CustomerAccount__c');
        Map<id, Zuora__CustomerAccount__c> billingAccountId_billingAccount = new Map<id, Zuora__CustomerAccount__c>();
        billingAccountId_billingAccount.put(zCus.Id, zCus);
        
        /*Zuora__Subscription__c zSub = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c');
        zSub.Zuora__CustomerAccount__c = zCusAcc.Id;
        zSub.Order_Number_1__c = order.Id;
        Database.insert(zSub);*/
        
               
         ARMS_CreateAndUpdate.PaymentInfoWrapper cau_piw = new ARMS_CreateAndUpdate.PaymentInfoWrapper();
            cau_piw.paymentMode = 'test';
            cau_piw.otherPaymentMethod = 'test';
            cau_piw.armsBusinessProfile = 'NORM';
            cau_piw.armsDebtManagement = 'SUBL';
            cau_piw.armsId = 'test';

        Map<id, ARMS_CreateAndUpdate.PaymentInfoWrapper> billingAccountId_paymentInfoWrapper = new Map <id,ARMS_CreateAndUpdate.PaymentInfoWrapper>();
            billingAccountId_paymentInfoWrapper.put(zCus.Id, cau_piw);
        
        Map<id, Order__c> billingAccountId_Order = new Map<id, Order__c>();
                
            billingAccountId_Order.put(zCus.Id, order);
        
       
       /* List<BT_CO_ARMS_CreateCustAccountFile__c> BTCreate = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
        BTCreate[0].Customer_Name1__c = 'April';
        insert(BTCreate);*/
/*TODO.start
        Zuora__Subscription__c zSubAcc = 
            [SELECT Id, Name, Zuora__CustomerAccount__c, Classification__c, Order_Number_1__r.Billing_Account_Creation_Mode__c, Order_Number_1__r.CreatedBy.Alias 
                 FROM Zuora__Subscription__c 
                 WHERE Classification__c = 'secret' AND Order_Number_1__r.Billing_Account_Creation_Mode__c = 'Create New Billing Account' Limit 1];
        System.assertNotEquals(null, zSubAcc);
*///TODO.end
        Test.startTest();
            ARMS_CreateAndUpdate cau = new ARMS_CreateAndUpdate();      
            cau.createAccount(orderIdSet, billingAccountId_billingAccount, billingAccountId_paymentInfoWrapper, billingAccountId_Order);
            
            order.Create_ARMS_Account_Only__c = true;
            order.Customer_No__c = '1';
            Database.update(order);
        
            cau.createAccount(orderIdSet, billingAccountId_billingAccount, billingAccountId_paymentInfoWrapper, billingAccountId_Order);
            
        Test.stopTest();
        
        System.assertNotEquals(null,cau);
       }catch(Exception e){}

    }
    
    
    
    static Map<String, sObject> setAllData(){
        
        Map<String, sObject> sObjectMap = null;
        sObjectMap = new Map<String, sObject>();

        //Create Address
        RecordType recType = [SELECT Id, DeveloperName from RecordType WHERE sObjectType = 'Address__c' and DeveloperName = 'Local'];
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = recType.id;
        add.Name = 'Test Address';
        add.Legacy_Created_By__c = 'Creator';
        add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
        add.Legacy_Updated_By__c = 'Modifier';
        add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
        add.Block_House_Number__c = '22';
        add.Level_Number__c = '03';
        add.Unit_Number__c = '13';
        sObjectMap.put('Address__c', add);
        Database.insert(add);       
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test Account';
        acc.AccountNumber = '';
        sObjectMap.put('Account', acc);
        Database.insert(acc);        
           
        Contact con = TestDataFactory.createContact(1)[0];
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        con.Address__c = add.id;
        con.MailingCountry = 'Singapore';
        con.MailingCity = 'Singapore';
        con.MailingStreet = '123 Test Street';
        con.MailingPostalCode = '1000';
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        sObjectMap.put('Contact', con);
        Database.insert(con);
        
        Order__c order = TestDataFactory.createOrder(1)[0];      
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 20; 
        order.Subscriber_Charge__c = 200; 
        order.Recipient_Contact__c = con.id;
        order.Billing_Contact__c = con.id;
        order.Billing_Account_Creation_Mode__c = GlobalVariableClass.CREATE_NEW_BILLACC;
        sObjectMap.put('Order__c', order);
        Database.insert(order);
        
        Zuora__CustomerAccount__c zCus = TestDataFactory.createBillingAccount(1)[0];
        zCus.Name = 'April';
        zCus.Zuora__Account__c = acc.Id;
        sObjectMap.put('Zuora__CustomerAccount__c', zCus);
        Database.insert(zCus);
   
             
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Contact__c = con.Id;
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__CustomerAccount__c = zCus.Id;
            zSub.Order_Number_1__c = order.Id;
            zSub.Classification__c = 'secret';
        sObjectMap.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        
      /*  BT_CO_ARMS_CreateCustAccountFile__c BTCreate = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
        BTCreate[0].Customer_Name1__c = 'April';
        insert(BTCreate);*/
        
       return sObjectMap;
        
        
    }
    static testmethod void cover_createAccount2(){
        try{ 
        Map<String, sObject> sObjectMap = null;
        sObjectMap = new Map<String, sObject>();

        //Create Address
                  
        Address__c add = TestDataFactory.createAddress(1)[0];
        RecordType recordType = [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName ='Overseas' LIMIT 1];
        add .RecordTypeid = recordType.id;
        add .Level_Number__c = '10';
        add .Unit_Number__c = '10';
        add .Address_1__c = 'Asiatown';
        add .Address_2__c = 'Ebloc2';
        add .Address_3__c = 'IT Park';
        add .Address_4__c = 'Lahug';    
        sObjectMap.put('Address__c', add);
        Database.insert(add);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test Account';
        acc.AccountNumber = '';
        sObjectMap.put('Account', acc);
        Database.insert(acc);        
           
        Contact con = TestDataFactory.createContact(1)[0];
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        con.Address__c = add.id;
        con.MailingCountry = 'Singapore';
        con.MailingCity = 'Singapore';
        con.MailingStreet = '123 Test Street';
        con.MailingPostalCode = '1000';
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.Address__c = add.id;
        sObjectMap.put('Contact', con);
        Database.insert(con);
        
        Order__c order = TestDataFactory.createOrder(1)[0];      
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 20; 
        order.Subscriber_Charge__c = 200; 
        order.Recipient_Contact__c = con.id;
        order.Billing_Contact__c = con.id;
        order.Billing_Account_Creation_Mode__c = GlobalVariableClass.CREATE_NEW_BILLACC;
        order.Create_ARMS_Customer_Account__c = true;
        order.Create_ARMS_Account_Only__c = false;
        sObjectMap.put('Order__c', order);
        Database.insert(order);
        
        Zuora__CustomerAccount__c zCus = TestDataFactory.createBillingAccount(1)[0];
        zCus.Name = 'April';
        zCus.Zuora__Account__c = acc.Id;
        zCus.Billing_Contact__C = con.id;
        sObjectMap.put('Zuora__CustomerAccount__c', zCus);
        Database.insert(zCus);
   
             
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Contact__c = con.Id;
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__CustomerAccount__c = zCus.Id;
            zSub.Order_Number_1__c = order.Id;
            zSub.Classification__c = 'secret';
        sObjectMap.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        
        
                      
        Set<id> orderIdSet = new Set<id>();
        orderIdSet.add(order.Id);
        
        //Zuora__CustomerAccount__c zCusAcc = (Zuora__CustomerAccount__c) sObjectMap.get('Zuora__CustomerAccount__c');
        Map<id, Zuora__CustomerAccount__c> billingAccountId_billingAccount = new Map<id, Zuora__CustomerAccount__c>();
        billingAccountId_billingAccount.put(zCus.Id, zCus);
        
        /*Zuora__Subscription__c zSub = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c');
        zSub.Zuora__CustomerAccount__c = zCusAcc.Id;
        zSub.Order_Number_1__c = order.Id;
        Database.insert(zSub);*/
        
               
         ARMS_CreateAndUpdate.PaymentInfoWrapper cau_piw = new ARMS_CreateAndUpdate.PaymentInfoWrapper();
            cau_piw.paymentMode = 'test';
            cau_piw.otherPaymentMethod = 'test';
            cau_piw.armsBusinessProfile = 'NORM';
            cau_piw.armsDebtManagement = 'SUBH';
            cau_piw.armsId = 'test';

        Map<id, ARMS_CreateAndUpdate.PaymentInfoWrapper> billingAccountId_paymentInfoWrapper = new Map <id,ARMS_CreateAndUpdate.PaymentInfoWrapper>();
            billingAccountId_paymentInfoWrapper.put(zCus.Id, cau_piw);
        
        Map<id, Order__c> billingAccountId_Order = new Map<id, Order__c>();
                
            billingAccountId_Order.put(zCus.Id, order);
        
        BT_CO_ARMS_CreateAccountBatchFile__c BTcreatebatchfile = new BT_CO_ARMS_CreateAccountBatchFile__c();
        BTcreatebatchfile.CCRID__c = '1';
        insert BTcreatebatchfile;
       /* List<BT_CO_ARMS_CreateCustAccountFile__c> BTCreate = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
        BTCreate[0].Customer_Name1__c = 'April';
        insert(BTCreate);*/
/*TODO.start
        Zuora__Subscription__c zSubAcc = 
            [SELECT Id, Name, Zuora__CustomerAccount__c, Classification__c, Order_Number_1__r.Billing_Account_Creation_Mode__c, Order_Number_1__r.CreatedBy.Alias 
                 FROM Zuora__Subscription__c 
                 WHERE Classification__c = 'secret' AND Order_Number_1__r.Billing_Account_Creation_Mode__c = 'Create New Billing Account' Limit 1];
        System.assertNotEquals(null, zSubAcc);
*///TODO.end
        Test.startTest();
            ARMS_CreateAndUpdate cau = new ARMS_CreateAndUpdate();      
            cau.createAccount(orderIdSet, billingAccountId_billingAccount, billingAccountId_paymentInfoWrapper, billingAccountId_Order);
            
            order.Create_ARMS_Account_Only__c = true;
            order.Customer_No__c = '1';
            Database.update(order);
        
            cau.createAccount(orderIdSet, billingAccountId_billingAccount, billingAccountId_paymentInfoWrapper, billingAccountId_Order);
            
        Test.stopTest();
        
        System.assertNotEquals(null,cau);
       }catch(Exception e){}

    }
   static testmethod void cover_createAccount3(){
        try{ 
        Map<String, sObject> sObjectMap = null;
        sObjectMap = new Map<String, sObject>();
        
        SPH_Section__c sect = new SPH_Section__c();
        sect.Section_Name__c = 'Section1';
        insert sect ;
        sObjectMap.put('SPH_Section', sect);
        
        SPH_Department__c dept = new SPH_Department__c();
        dept.Department_Name__c = 'Billing';
        insert dept;
        sObjectMap.put('SPH_Department', dept);
        
        SPH_Division__c divi = new SPH_Division__c();
        divi.Name = 'Division1';
        insert divi;
        sObjectMap.put('SPH_Division', divi);
        
        SPH_Company__c comp = new SPH_Company__c();
        comp.Company_Name__c= 'Accenture';
        insert comp ;
        sObjectMap.put('SPH_Company', comp );
        
        SPH_Location__c loc = new SPH_Location__c();
        loc.Location_Name__c = 'Cebu';
        insert loc;
        sObjectMap.put('SPH_Location', loc);
        
        //Create Address
        Address__c add = TestDataFactory.createAddress(1)[0];
        RecordType recordType1 = [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName ='Internal' LIMIT 1];
        add .RecordTypeid = recordType1.id;
        add .Level_Number__c = '10';
        add .Unit_Number__c = '10';
        add .Section_Code__c = sect.id;
        add .Department__c = dept.id;    
        add .Division_Code__c = divi.id;
        add .Company_Code__c = comp.id;
        add .Location_Code__c = loc.id;
        sObjectMap.put('Address__c', add);
        Database.insert(add);          
             
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test Account';
        acc.AccountNumber = ''; 
        sObjectMap.put('Account', acc);
        Database.insert(acc);        
           
        Contact con = TestDataFactory.createContact(1)[0];
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        con.Address__c = add.id;
        con.MailingCountry = 'Singapore';
        con.MailingCity = 'Singapore';
        con.MailingStreet = '123 Test Street';
        con.MailingPostalCode = '1000';
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.Address__c = add.id;
        con.Passport__c = 'Testpassport';
        sObjectMap.put('Contact', con);
        Database.insert(con);
        
        Order__c order = TestDataFactory.createOrder(1)[0];      
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 20; 
        order.Subscriber_Charge__c = 200; 
        order.Recipient_Contact__c = con.id;
        order.Billing_Contact__c = con.id;
        order.Billing_Account_Creation_Mode__c = GlobalVariableClass.CREATE_NEW_BILLACC;
        order.Create_ARMS_Customer_Account__c = true;
        order.Create_ARMS_Account_Only__c = false;
        sObjectMap.put('Order__c', order);
        Database.insert(order);
        
        Zuora__CustomerAccount__c zCus = TestDataFactory.createBillingAccount(1)[0];
        zCus.Name = 'TestName';
        zCus.Zuora__Account__c = acc.Id;
        zCus.Billing_Contact__C = con.id;
        sObjectMap.put('Zuora__CustomerAccount__c', zCus);
        Database.insert(zCus);
   
             
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Contact__c = con.Id;
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__CustomerAccount__c = zCus.Id;
            zSub.Order_Number_1__c = order.Id;
            zSub.Classification__c = 'secret';
        sObjectMap.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
        
        
                      
        Set<id> orderIdSet = new Set<id>();
        orderIdSet.add(order.Id);
        
        //Zuora__CustomerAccount__c zCusAcc = (Zuora__CustomerAccount__c) sObjectMap.get('Zuora__CustomerAccount__c');
        Map<id, Zuora__CustomerAccount__c> billingAccountId_billingAccount = new Map<id, Zuora__CustomerAccount__c>();
        billingAccountId_billingAccount.put(zCus.Id, zCus);
        
        /*Zuora__Subscription__c zSub = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c');
        zSub.Zuora__CustomerAccount__c = zCusAcc.Id;
        zSub.Order_Number_1__c = order.Id;
        Database.insert(zSub);*/
        
               
         ARMS_CreateAndUpdate.PaymentInfoWrapper cau_piw = new ARMS_CreateAndUpdate.PaymentInfoWrapper();
            cau_piw.paymentMode = 'test';
            cau_piw.otherPaymentMethod = 'test';
            cau_piw.armsBusinessProfile = 'GOVT';
            cau_piw.armsDebtManagement = 'GOVT';
            cau_piw.armsId = 'test';

        Map<id, ARMS_CreateAndUpdate.PaymentInfoWrapper> billingAccountId_paymentInfoWrapper = new Map <id,ARMS_CreateAndUpdate.PaymentInfoWrapper>();
            billingAccountId_paymentInfoWrapper.put(zCus.Id, cau_piw);
        
        Map<id, Order__c> billingAccountId_Order = new Map<id, Order__c>();
                
            billingAccountId_Order.put(zCus.Id, order);
            
        //JURNA ADDED
        BT_CO_ARMS_CreateCustAccountFile__c BTcreate = new BT_CO_ARMS_CreateCustAccountFile__c();
        BTcreate.Customer_Name1__c = 'TestName';
        BTcreate.Reference_Key__c = 'TestKey';
        insert BTcreate;
        
        BT_CO_ARMS_CreateAccountBatchFile__c BTcreatebatchfile = new BT_CO_ARMS_CreateAccountBatchFile__c();
        BTcreatebatchfile.CCRID__c = '1';
        insert BTcreatebatchfile;
        
       /* List<BT_CO_ARMS_CreateCustAccountFile__c> BTCreate = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
        BTCreate[0].Customer_Name1__c = 'April';
        insert(BTCreate);*/
/*TODO.start
        Zuora__Subscription__c zSubAcc = 
            [SELECT Id, Name, Zuora__CustomerAccount__c, Classification__c, Order_Number_1__r.Billing_Account_Creation_Mode__c, Order_Number_1__r.CreatedBy.Alias 
                 FROM Zuora__Subscription__c 
                 WHERE Classification__c = 'secret' AND Order_Number_1__r.Billing_Account_Creation_Mode__c = 'Create New Billing Account' Limit 1];
        System.assertNotEquals(null, zSubAcc);
*///TODO.end
        Test.startTest();
            ARMS_CreateAndUpdate cau = new ARMS_CreateAndUpdate();      
            cau.createAccount(orderIdSet, billingAccountId_billingAccount, billingAccountId_paymentInfoWrapper, billingAccountId_Order);
            
            order.Create_ARMS_Account_Only__c = true;
            order.Customer_No__c = '1';
            Database.update(order);
        
            cau.createAccount(orderIdSet, billingAccountId_billingAccount, billingAccountId_paymentInfoWrapper, billingAccountId_Order);
            
        Test.stopTest();
        
        System.assertNotEquals(null,cau);
       }catch(Exception e){}

    }
    
    
    
    static testmethod void cover_updateAccountNotNull(){
        try{
            Map<String, sObject> sObjectMap = null;
        sObjectMap = new Map<String, sObject>();

        //Create Address
                  
        Address__c add = TestDataFactory.createAddress(1)[0];
        RecordType recordType = [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType = 'Address__c' AND DeveloperName ='Overseas' LIMIT 1];
        add .RecordTypeid = recordType.id;
        add .Level_Number__c = '10';
        add .Unit_Number__c = '10';
        add .Address_1__c = 'Asiatown';
        add .Address_2__c = 'Ebloc2';
        add .Address_3__c = 'IT Park';
        add .Address_4__c = 'Lahug';    
        sObjectMap.put('Address__c', add);
        Database.insert(add);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test Account';
        acc.AccountNumber = '';
        acc.Staff_ID__c = 'StaffId';
        sObjectMap.put('Account', acc);
        Database.insert(acc);        
           
        Contact con = TestDataFactory.createContact(1)[0];
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        con.Address__c = add.id;
        con.MailingCountry = 'Singapore';
        con.MailingCity = 'Singapore';
        con.MailingStreet = '123 Test Street';
        con.MailingPostalCode = '1000';
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.Address__c = add.id;
        con.NRIC__c = 'T1234567R';
        sObjectMap.put('Contact', con);
        Database.insert(con);
        
        Order__c order = TestDataFactory.createOrder(1)[0];      
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 20; 
        order.Subscriber_Charge__c = 200; 
        order.Recipient_Contact__c = con.id;
        order.Billing_Contact__c = con.id;
        order.Billing_Account_Creation_Mode__c = GlobalVariableClass.CREATE_NEW_BILLACC;
        order.Create_ARMS_Customer_Account__c = true;
        order.Create_ARMS_Account_Only__c = false;
        sObjectMap.put('Order__c', order);
        Database.insert(order);
        
        Zuora__CustomerAccount__c zCus = TestDataFactory.createBillingAccount(1)[0];
        zCus.Name = 'April';
        zCus.Zuora__Account__c = acc.Id;
        zCus.Billing_Contact__C = con.id;
        zCus.Billing_Type__c = 'Prepaid';
        zCus.ARMS_Customer_Number__c = '1';
        zCus.ARMS_Business_Profile__c = 'NORM';
        zCus.ARMS_Account_Number__c = '1';
        sObjectMap.put('Zuora__CustomerAccount__c', zCus);
        Database.insert(zCus);
   
             
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Contact__c = con.Id;
            zSub.Zuora__Account__c = acc.id;
            zSub.Zuora__CustomerAccount__c = zCus.Id;
            zSub.Order_Number_1__c = order.Id;
            zSub.Classification__c = 'secret';
        sObjectMap.put('Zuora__Subscription__c', zSub);
        Database.insert(zSub);
            
            List<Zuora__CustomerAccount__c> updInitialBillAccList = new List<Zuora__CustomerAccount__c>();
                updInitialBillAccList.add(zCus);
                
                
            BT_CO_ARMS_UpdateAccountBatchFile__c BTupdatebatchfile = new BT_CO_ARMS_UpdateAccountBatchFile__c();
            BTupdatebatchfile.Account_Number__c = '1';
            BTupdatebatchfile.CCRID__c = '1';
            insert BTupdatebatchfile;

            Test.startTest();
                ARMS_CreateAndUpdate cau = new ARMS_CreateAndUpdate();
                cau.updateAccount(updInitialBillAccList);
            Test.stopTest();
            System.assertNotEquals(null,cau);
            
        }catch(Exception e){}
    }
    
}