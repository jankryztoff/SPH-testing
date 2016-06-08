@isTest(seeAllData = true)
public class AcknowledgementController_V2Test{
    
    static testMethod void testAcknowledgementController1(){
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            
            Profile prof = [Select Id From Profile Where Name = 'Standard User' LIMIT 1];
            User testUser = new User(
                Alias = 'standard',
                Email='standarduser@gmail.com', 
                EmailEncodingKey='UTF-8',
                LastName='Testing',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = prof.Id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='userstand3541987*@testorg.com'
            );
            
            System.runAs(testUser){
            
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Name = 'Test Name';
                //pack.Number_Of_Promotions__c = 12;  //
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                insert new List<sObject>{venAccount, pack, subsVen};
            
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
            
                Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Name = 'Test Name';
                insert acc;    
                
                Country__c countr = TestDataFactory.createCountry(1)[0];
                countr.Country_Name__c = 'Test Country';
                insert countr;
           
                City__c cit =TestDataFactory.createCity(1)[0];
                cit.City_Name__c = 'Cebu City';
                cit.Flight_Number_1__c = '12';
                cit.Flight_Number_2__c = '10';
                insert cit;                
                   
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Unit_Number__c = 'abcdef';
                addressRec.Country__c = countr.Id;         
                addressRec.Name ='Test Name';
                addressRec.Address_Type__c = 'A';
                addressRec.Address_1__c= 'J';
                addressRec.Address_2__c = 'O';
                addressRec.Address_3__c = 'Y';
                addressRec.Address_4__c = 'Z';
                addressRec.City__c = cit.Id;
                insert addressRec;        
                
                Contact conList = TestDataFactory.createContact(1)[0];
                conList.LastName = 'Gonzales';
                conList.AccountId = acc.Id;
                conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList.Recipient_Indicator__c = true;
                conList.HomePhone = '12345';
                conList.Address__c = addressRec.Id;
                insert conList;
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0]; 
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
                billAcc.Zuora__Account__c = acc.id; 
                insert billAcc;
                
                Contact conList2 = TestDataFactory.createContact(1)[0];
                conList2.LastName = 'Gonzales';
                conList2.FirstName = 'Alex';
                conList2.AccountId = acc.Id;
                conList2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList2.Billing_Indicator__c = true;
                conList2.Address__c = addressRec.Id;
                insert conList2;
            
                Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList.Id;
                orderRec.Billing_Contact__c = conList2.Id;
                orderRec.Subscriber_Charge__c = 15;
                orderRec.DTL_Date__c = date.today();
                orderRec.Delivery_Charge__c = 2;
                insert orderRec;
            
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.End_Date__c = Date.Today().addDays(100);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Case__c = cas.id;
                orderline.Vendor_Mailing_Agent__c = venAccount.Id;
                orderline.Vendor_Subscription_ID__c = subsVen.Id;
                orderline.Main_Package_Product_Sub_Type__c =GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER;
                insert orderline;
                
                test.startTest();  
                Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Order_Line_Item_Number__c = orderline.Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Order_Number__c = orderRec.Id;
                sub.Contact__c = conList2.Id;
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Main_Package_1__c = pack.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__CustomerAccount__c = billAcc.id;
                sub.Number_of_Copies__c=100;
                sub.Number_of_Copies1__c =  '100';
                sub.Qty__c = 20;
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
                sub.Subscription_Charge__c = 12;
                sub.Order_Number_1__c = orderRec.Id;
                sub.Order_Line_Item_Number_1__c =orderline.Id; 
                sub.Term_Length__c = 12;
                sub.Payment_Mode_1__c = 'Other';
                sub.Billing_Type__c = 'Full Prepaid';
                sub.Other_PaymentMethod_1__c = 'Invoice';
                sub.Frequency_1__c= 'Mon - Fri';
                sub.New_Contract_Period_1__c = 2;
                sub.Zuora__SubscriptionEndDate__c=null;
                sub.Zuora__SubscriptionStartDate__c=date.today();
                sub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE; 
                sub.Zuora__TermSettingType__c = 'EVERGREEN';
                insert sub; 
            
                //Test.startTest();
                PageReference pageRef = Page.AcknowledgementLetter;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id',billAcc.Id); 
                AcknowledgementController_V2 ack = new AcknowledgementController_V2();
                ack.generateAcknowledgementController();
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e) {}   
    }     
    
    static testMethod void testAcknowledgementController2(){
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            
            Profile prof = [Select Id From Profile Where Name = 'Standard User' LIMIT 1];
            User testUser = new User(
                Alias = 'standard',
                Email='standarduser@gmail.com', 
                EmailEncodingKey='UTF-8',
                LastName='Testing',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = prof.Id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='userstand3541987*@testorg.com'
            );
            
            System.runAs(testUser){
            
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Name = 'Test Name';
                //pack.Number_Of_Promotions__c = 12;  //
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                insert new List<sObject>{venAccount, pack, subsVen};
            
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
            
                Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Name = 'Test Name';
                insert acc;    
                
                Country__c countr = TestDataFactory.createCountry(1)[0];
                countr.Country_Name__c = 'Test Country';
                insert countr;
           
                City__c cit =TestDataFactory.createCity(1)[0];
                cit.City_Name__c = 'Cebu City';
                cit.Flight_Number_1__c = '12';
                cit.Flight_Number_2__c = '10';
                insert cit;                
                   
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Unit_Number__c = 'abcdef';
                addressRec.Country__c = countr.Id;         
                addressRec.Name ='Test Name';
                addressRec.Address_Type__c = 'A';
                addressRec.Address_1__c= 'J';
                addressRec.Address_2__c = 'O';
                addressRec.Address_3__c = 'Y';
                addressRec.Address_4__c = 'Z';
                addressRec.City__c = cit.Id;
                insert addressRec;        
                
                Contact conList = TestDataFactory.createContact(1)[0];
                conList.LastName = 'Gonzales';
                conList.AccountId = acc.Id;
                conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList.Recipient_Indicator__c = true;
                conList.HomePhone = '12345';
                conList.Address__c = addressRec.Id;
                insert conList;
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0]; 
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
                billAcc.Zuora__Account__c = acc.id; 
                insert billAcc;
                
                Contact conList2 = TestDataFactory.createContact(1)[0];
                conList2.LastName = 'Gonzales';
                conList2.FirstName = 'Alex';
                conList2.AccountId = acc.Id;
                conList2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList2.Billing_Indicator__c = true;
                conList2.Address__c = addressRec.Id;
                insert conList2;
            
                Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList.Id;
                orderRec.Billing_Contact__c = conList2.Id;
                orderRec.Subscriber_Charge__c = 15;
                orderRec.DTL_Date__c = date.today();
                orderRec.Delivery_Charge__c = 2;
                insert orderRec;
            
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.End_Date__c = Date.Today().addDays(100);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Case__c = cas.id;
                orderline.Vendor_Mailing_Agent__c = venAccount.Id;
                orderline.Vendor_Subscription_ID__c = subsVen.Id;
                orderline.Main_Package_Product_Sub_Type__c =GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER;
                insert orderline;
                
                test.startTest();  
                Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Order_Line_Item_Number__c = orderline.Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Order_Number__c = orderRec.Id;
                sub.Contact__c = conList2.Id;
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Main_Package_1__c = pack.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__CustomerAccount__c = billAcc.id;
                sub.Number_of_Copies__c=100;
                sub.Number_of_Copies1__c =  '100';
                sub.Qty__c = 20;
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
                sub.Subscription_Charge__c = 12;
                sub.Order_Number_1__c = orderRec.Id;
                sub.Order_Line_Item_Number_1__c =orderline.Id; 
                sub.Term_Length__c = 12;
                sub.Payment_Mode_1__c = 'Other';
                sub.Billing_Type__c = 'Full Prepaid';
                sub.Other_PaymentMethod_1__c = 'Invoice';
                sub.Frequency_1__c= 'Mon - Fri';
                sub.New_Contract_Period_1__c = 2;
                sub.Zuora__SubscriptionEndDate__c=null;
                sub.Zuora__SubscriptionStartDate__c=date.today();
                sub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE; 
                sub.Zuora__TermSettingType__c = 'EVERGREEN';
                insert sub; 
            
                //Test.startTest();
                PageReference pageRef = Page.AcknowledgementLetter;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id',billAcc.Id); 
                AcknowledgementController_V2 ack = new AcknowledgementController_V2();
                ack.generateAcknowledgementController();
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e) {}   
    }  
    
    static testMethod void testAcknowledgementController3(){
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            
            Profile prof = [Select Id From Profile Where Name = 'Standard User' LIMIT 1];
            User testUser = new User(
                Alias = 'standard',
                Email='standarduser@gmail.com', 
                EmailEncodingKey='UTF-8',
                LastName='Testing',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = prof.Id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='userstand3541987*@testorg.com'
            );
            
            System.runAs(testUser){
            
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Name = 'Test Name';
                //pack.Number_Of_Promotions__c = 12;  //
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                insert new List<sObject>{venAccount, pack, subsVen};
            
                Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
            
                Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Name = 'Test Name';
                insert acc;    
                
                Country__c countr = TestDataFactory.createCountry(1)[0];
                countr.Country_Name__c = 'Test Country';
                insert countr;
           
                City__c cit =TestDataFactory.createCity(1)[0];
                cit.City_Name__c = 'Cebu City';
                cit.Flight_Number_1__c = '12';
                cit.Flight_Number_2__c = '10';
                insert cit;                
                   
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Unit_Number__c = 'abcdef';
                addressRec.Country__c = countr.Id;         
                addressRec.Name ='Test Name';
                addressRec.Address_Type__c = 'A';
                addressRec.Address_1__c= 'J';
                addressRec.Address_2__c = 'O';
                addressRec.Address_3__c = 'Y';
                addressRec.Address_4__c = 'Z';
                addressRec.City__c = cit.Id;
                insert addressRec;        
                
                Contact conList = TestDataFactory.createContact(1)[0];
                conList.LastName = 'Gonzales';
                conList.AccountId = acc.Id;
                conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList.Recipient_Indicator__c = true;
                conList.HomePhone = '12345';
                conList.Address__c = addressRec.Id;
                insert conList;
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0]; 
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
                billAcc.Zuora__Account__c = acc.id; 
                insert billAcc;
                
                Contact conList2 = TestDataFactory.createContact(1)[0];
                conList2.LastName = 'Gonzales';
                conList2.FirstName = 'Alex';
                conList2.AccountId = acc.Id;
                conList2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList2.Billing_Indicator__c = true;
                conList2.Address__c = addressRec.Id;
                insert conList2;
            
                Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList.Id;
                orderRec.Billing_Contact__c = conList2.Id;
                orderRec.Subscriber_Charge__c = 15;
                orderRec.DTL_Date__c = date.today();
                orderRec.Delivery_Charge__c = 2;
                insert orderRec;
            
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.End_Date__c = Date.Today().addDays(100);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Case__c = cas.id;
                orderline.Vendor_Mailing_Agent__c = venAccount.Id;
                orderline.Vendor_Subscription_ID__c = subsVen.Id;
                orderline.Main_Package_Product_Sub_Type__c =GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER;
                insert orderline;
                
                test.startTest();  
                Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Order_Line_Item_Number__c = orderline.Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Order_Number__c = orderRec.Id;
                sub.Contact__c = conList2.Id;
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Main_Package_1__c = pack.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__CustomerAccount__c = billAcc.id;
                sub.Number_of_Copies__c=100;
                sub.Number_of_Copies1__c =  '100';
                sub.Qty__c = 20;
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
                sub.Subscription_Charge__c = 12;
                sub.Order_Number_1__c = orderRec.Id;
                sub.Order_Line_Item_Number_1__c =orderline.Id; 
                sub.Term_Length__c = 12;
                sub.Payment_Mode_1__c = 'Other';
                sub.Billing_Type__c = 'Full Prepaid';
                sub.Other_PaymentMethod_1__c = 'Invoice';
                sub.Frequency_1__c= 'Mon - Fri';
                sub.New_Contract_Period_1__c = 2;
                sub.Zuora__SubscriptionEndDate__c=null;
                sub.Zuora__SubscriptionStartDate__c=date.today();
                sub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE; 
                sub.Zuora__TermSettingType__c = 'EVERGREEN';
                insert sub; 
            
                //Test.startTest();
                PageReference pageRef = Page.AcknowledgementLetter;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id',billAcc.Id); 
                AcknowledgementController_V2 ack = new AcknowledgementController_V2();
                ack.generateAcknowledgementController();
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e) {}   
    } 
    
    static testMethod void testAcknowledgementController4(){
        
        try {
            Test.setMock(WebServiceMock.class, new zLoginMock());
            
            Profile prof = [Select Id From Profile Where Name = 'Standard User' LIMIT 1];
            User testUser = new User(
                Alias = 'standard',
                Email='standarduser@gmail.com', 
                EmailEncodingKey='UTF-8',
                LastName='Testing',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = prof.Id, 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='userstand3541987*@testorg.com'
            );
            
            System.runAs(testUser){
            
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Test Name';
            //pack.Number_Of_Promotions__c = 12;  //
            Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
            insert new List<sObject>{venAccount, pack, subsVen};
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
                
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                acc.NRIC__c = 'T1234567R';
                acc.Name = 'Test Name';
                acc.Airline_Indicator__c = true;
                insert acc;    
                
            Country__c countr = TestDataFactory.createCountry(1)[0];
                countr.Country_Name__c = 'Test Country';
                insert countr;
                
               City__c cit =TestDataFactory.createCity(1)[0];
               cit.City_Name__c = 'Cebu City';
               cit.Flight_Number_1__c = '12';
               cit.Flight_Number_2__c = '10';
               insert cit;                
                
                Packing_Grp__c packgroup =  new Packing_Grp__c();
                packgroup.Airline__c = 'J';
                insert packgroup; 
                   
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
               addressRec.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                addressRec.Block_House_Number__c = '12';
                addressRec.Address_Type__c= 'P';
                addressRec.Postal_Code__c = postal.Id;
                addressRec.Unit_Number__c = 'abcdef';
                addressRec.Country__c = countr.Id;         
                addressRec.Name ='Test Name';
                addressRec.Address_Type__c = 'A';
                addressRec.Packing_Code__c = packgroup.Id;
                addressRec.City__c = cit.Id;
                addressRec.Unit_Number__c = '1234';
                addressRec.Level_Number__c = '123';
                insert addressRec;        
                
            Contact conList = TestDataFactory.createContact(1)[0];
                conList.LastName = 'Gonzales';
                conList.AccountId = acc.Id;
                conList.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList.Recipient_Indicator__c = true;
                conList.HomePhone = '12345';
                conList.Address__c = addressRec.Id;
                insert conList;
                
           Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0]; 
                billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; 
                billAcc.Zuora__Account__c = acc.id; 
                insert billAcc;
                
            Contact conList2 = TestDataFactory.createContact(1)[0];
                conList2.LastName = 'Gonzales';
                conList2.FirstName = 'Alex';
                conList2.AccountId = acc.Id;
                conList2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                conList2.Billing_Indicator__c = true;
                conList2.Address__c = addressRec.Id;
                insert conList2;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList.Id;
                orderRec.Billing_Contact__c = conList2.Id;
                orderRec.Subscriber_Charge__c = 15;
                orderRec.DTL_Date__c = date.today();
                orderRec.Delivery_Charge__c = 2;
                insert orderRec;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.Order__c = orderRec.Id;
                insert cas;
                
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = orderRec.Id;
                //orderline.End_Date__c = date.newInstance(2015, 4, 14);
                orderline.Start_Date__c = Date.Today().addDays(1);
                orderline.End_Date__c = Date.Today().addDays(100);
                orderline.Main_Package_ID__c = pack.Id;
                orderline.Case__c = cas.id;
                orderline.Vendor_Mailing_Agent__c = venAccount.Id;
                orderline.Vendor_Subscription_ID__c = subsVen.Id;
                orderline.Main_Package_Product_Sub_Type__c ='Test Line';
                insert orderline;
           
            test.startTest();    
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Order_Line_Item_Number__c = orderline.Id;
                sub.Zuora__Account__c = acc.Id;
                sub.Order_Number__c = orderRec.Id;
                sub.Contact__c = conList2.Id;
                sub.Subscriber_Contact__c = conList.Id;
                sub.Recipient_Contact__c = conList.Id;
                sub.Main_Package_1__c = pack.Id;
                sub.Zuora__Status__c = 'Active';
                sub.Zuora__CustomerAccount__c = billAcc.id;
                sub.Number_of_Copies__c = 100;
                sub.Number_of_Copies1__c =  '100';
                sub.Qty__c = 20;
                sub.Subscription_Type__c = 'Publication';
                sub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
                sub.Subscription_Charge__c = 12;
                sub.Order_Number_1__c = orderRec.Id;
                sub.Order_Line_Item_Number_1__c =orderline.Id; 
                sub.Term_Length__c = 12;
                sub.Payment_Mode_1__c = 'Other';
                sub.Payment_Mode__c = 'Other';
                sub.Billing_Type__c = 'Full Prepaid';
                sub.Other_PaymentMethod_1__c = 'Invoice';
                sub.Frequency_1__c= 'Mon - Fri';
                sub.New_Contract_Period_1__c = 2;
                sub.Zuora__SubscriptionEndDate__c=null;
                sub.Zuora__SubscriptionStartDate__c=date.today();
                sub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;  
                insert sub; 
            
                //Test.startTest();
                PageReference pageRef = Page.AcknowledgementLetter;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id',billAcc.Id); 
                AcknowledgementController_V2 ack = new AcknowledgementController_V2();
                ack.generateAcknowledgementController();
                Test.stopTest();
            }
        }catch(Zuora.zRemoteException e) {}   
    } 
}