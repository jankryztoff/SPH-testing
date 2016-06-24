@isTest (seeAllData= True)
private class ChangeInAddressExtensionEditTest {
    //This prepares the needed data for the testing of class    
    static testMethod void testChangeInAddress(){
        
        //Create a new user with Standard User Profile
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(u) {
            
            List<Account> accList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            List<Case> caseList = new List<Case>(); 
            List<Package__c> packageList = new List<Package__c>();
            List<Zuora__Subscription__c> zuoSubList = new List<Zuora__Subscription__c>();
            List<Address_Assignment__c> addAssignmentList = new List<Address_Assignment__c>();
            List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
            List<Order__c> orderList = new List<Order__c>();
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            //Test.startTest();
            insert postal;
            
            //create Account Records
            accList = TestDataFactory.createAccount(1, 'Vendor');
            accList[0].NRIC__c = 'T1234567R';
            insert accList;
            
            //create Main Package Records
            packageList = TestDataFactory.createPackage(1);
            insert packageList;
            
            //create Billing Account Records
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = accList[0].Id;
            insert billAcc;
            
            //create Address Records
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            //create Contact Records
            conList = TestDataFactory.createContact(1);
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            conList[0].AccountId = accList[0].Id;
            conList[0].Address__c = addressRec.Id;
            conList[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
            insert conList;
            
            //create Order Records
            orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].Id;
            orderList[0].Informed_Customer__c = TRUE;
            orderList[0].Recipient_Contact__c = conList[0].Id;
            
            insert orderList ; 
         
            //insert Case Records
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderList[0].Id;
            
            //ChangeInAddress
            Case cCase = new Case();
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');
            cCase.Order__c = orderList[0].Id;
            cCase.POP_Start_Date__c = date.today()-5;
            cCase.New_Address__c = addressRec.Id; //modified by AAD
            insert cCase;
            
            Address_Assignment__c aa = new Address_Assignment__c();
            aa.Address__c = addressRec.Id;
            //aa.Case__c = changeInAddress.Id;
            aa.Contact__c = conList[0].Id;
            aa.Effective_Date__c = date.today();
            aa.Status__c = 'Active';
            aa.End_Date__c = date.today().addDays(2); 
            //aa.Subscription_Vendor__c = sv.id;
            //aa.Active__c = True; 
            insert aa;
            
            Vendor_Allocation__c vend = TestDataFactory.createVendorAlloc(1)[0];
            vend.SingPost_Address__c = postal.Id;
            //vend.Status__c = 'active';
            vend.Vendor_Account__c = accList[0].Id;
            vend.Allocated__c = true;
            database.insert(vend);
            
            Test.startTest();
            PageReference pRef = Page.ChangeInAddressCaseEditPage;
            Test.setCurrentPage(pRef);
            ApexPages.StandardController stdController = new ApexPages.Standardcontroller(cCase);
            ChangeInAddressExtensionEdit CIA = new ChangeInAddressExtensionEdit(stdController);
            CIA.save();
            
            ApexPages.StandardController stdController1 = new ApexPages.Standardcontroller(cCase);
            ChangeInAddressExtensionEdit CIA1 = new ChangeInAddressExtensionEdit(stdController1);
            CIA1.changeInAddress.Effective_Date__c = Date.today().addDays(-2); 
            CIA1.save();
            
            CIA1.updateAssignment();
            
            /*ApexPages.StandardController stdController2 = new ApexPages.Standardcontroller(cas);
            ChangeInAddressExtensionEdit CIA2 = new ChangeInAddressExtensionEdit(stdController2);
            CIA2.changeInAddress.Effective_Date__c = Date.today(); 
            CIA2.save();*/
            //CIA2.saveandnew();
            
            /*ApexPages.StandardController stdController3 = new ApexPages.Standardcontroller(cas);
            ChangeInAddressExtensionEdit CIA3 = new ChangeInAddressExtensionEdit(stdController3);
            CIA3.changeInAddress.Effective_Date__c = Date.today(); 
            CIA3.save();*/
            //CIA3.saveandnew();
            
            Test.stopTest();
            
            
        }
    }
    
    static testMethod void testChangeInAddress2(){
        
        //Create a new user with Standard User Profile
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(u) {
            
            List<Account> accList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            List<Case> caseList = new List<Case>(); 
            List<Package__c> packageList = new List<Package__c>();
            List<Zuora__Subscription__c> zuoSubList = new List<Zuora__Subscription__c>();
            List<Address_Assignment__c> addAssignmentList = new List<Address_Assignment__c>();
            List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
            List<Order__c> orderList = new List<Order__c>();
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            //Test.startTest();
            insert postal;
            
            //create Account Records
            accList = TestDataFactory.createAccount(1, 'Vendor');
            accList[0].NRIC__c = 'T1234567R';
            insert accList;
            
            //create Main Package Records
            packageList = TestDataFactory.createPackage(1);
            insert packageList;
            
            //create Billing Account Records
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = accList[0].Id;
            insert billAcc;
            
            //create Address Records
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            //create Contact Records
            conList = TestDataFactory.createContact(1);
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            conList[0].AccountId = accList[0].Id;
            conList[0].Address__c = addressRec.Id;
            conList[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
            insert conList;
            
            //create Order Records
            orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].Id;
            orderList[0].Informed_Customer__c = TRUE;
            orderList[0].Recipient_Contact__c = conList[0].Id;
            
            insert orderList ; 
         
            //insert Case Records
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderList[0].Id;
            
            //ChangeInAddress
            Case cCase = new Case();
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');
            cCase.AccountId = accList[0].Id;
            cCase.Order__c = orderList[0].Id;
            cCase.POP_Start_Date__c = date.today()-5;
            cCase.New_Address__c = addressRec.Id; //modified by AAD
            cCase.Vendor__c = null;
            cCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
            cCase.Contact_To_Update__c = conList[0].id;
            cCase.Vendor__c = accList[0].id;
            cCase.Effective_Date__c = date.today();
            insert cCase;
            
            Address_Assignment__c aa = new Address_Assignment__c();
            aa.Address__c = addressRec.Id;
            aa.Case__c = cCase.Id;
            aa.Contact__c = conList[0].Id;
            aa.Effective_Date__c = date.today();
            aa.Status__c = 'Active';
            aa.End_Date__c = date.today().addDays(2); 
            //aa.Subscription_Vendor__c = sv.id;
            //aa.Active__c = True; 
            insert aa;
            
            Vendor_Allocation__c vend = TestDataFactory.createVendorAlloc(1)[0];
            vend.SingPost_Address__c = postal.Id;
            //vend.Status__c = 'active';
            vend.Vendor_Account__c = accList[0].Id;
            vend.Allocated__c = true;
            database.insert(vend);
            
            Test.startTest();
            PageReference pRef = Page.ChangeInAddressCaseEditPage;
            Test.setCurrentPage(pRef);
            ApexPages.StandardController stdController = new ApexPages.Standardcontroller(cCase);
            ChangeInAddressExtensionEdit CIA = new ChangeInAddressExtensionEdit(stdController);
            CIA.save();
            
            ApexPages.StandardController stdController1 = new ApexPages.Standardcontroller(cCase);
            ChangeInAddressExtensionEdit CIA1 = new ChangeInAddressExtensionEdit(stdController1);
            CIA1.changeInAddress.Effective_Date__c = Date.today().addDays(-2); 
            CIA1.save();
            
            CIA1.updateAssignment();
            
            ApexPages.StandardController stdController2 = new ApexPages.Standardcontroller(cCase);
            ChangeInAddressExtensionEdit CIA2 = new ChangeInAddressExtensionEdit(stdController2);
            CIA2.changeInAddress.Vendor__c = null; 
            CIA2.save();
            
            cCase.Change_of_Address_Type__c = GlobalVariableClass.DELIVERYADDLOC;
            update cCase;
            
            CIA2.updateAssignment();
            
            Test.stopTest();
            
            
        }
    }
    
    static testMethod void testChangeInAddress3(){
        
        //Create a new user with Standard User Profile
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
       
        
        //The test will run as the user created.
        System.runAs(u) {
            
            List<Account> accList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            List<Case> caseList = new List<Case>(); 
            List<Package__c> packageList = new List<Package__c>();
            List<Address_Assignment__c> addAssignmentList = new List<Address_Assignment__c>();
            List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
            List<Order__c> orderList = new List<Order__c>();
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            //Test.startTest();
            insert postal;
            
            //create Account Records
            accList = TestDataFactory.createAccount(1, 'Vendor');
            accList[0].NRIC__c = 'T1234567R';
            insert accList;
            
            //create Main Package Records
            packageList = TestDataFactory.createPackage(1);
            packageList[0].Subscription_Period__c = '15';         
            insert packageList;
            
            //create Billing Account Records
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = accList[0].Id;
            insert billAcc;
            
            //create Address Records
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            //create Contact Records
            conList = TestDataFactory.createContact(1);
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            conList[0].AccountId = accList[0].Id;
            conList[0].Address__c = addressRec.Id;
            conList[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
            insert conList;
            
            //create Order Records
            orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].Id;
            orderList[0].Informed_Customer__c = TRUE;
            orderList[0].Recipient_Contact__c = conList[0].Id;
            orderList[0].Subscriber_charge__c = 100;
            
            insert orderList ; 
         
            //insert Case Records
         /*  Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderList[0].Id;
            database.insert(cas); */
            
           // RecordType rec = [SELECT Id, Name FROM RecordType WHERE Name='Change of Address/Vendor'];
            
            //ChangeInAddress
            Case cCase = new Case();
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');
           // cCase.RecordTypeId = rec.Id;
            cCase.AccountId = accList[0].Id;
            cCase.Order__c = orderList[0].Id;
            cCase.POP_Start_Date__c = date.today();
            cCase.New_Address__c = null;
            cCase.Vendor__c = null;
            cCase.Change_of_Address_Type__c = GlobalVariableClass.BILLINGADD;
            cCase.Contact_To_Update__c = conList[0].id;
            cCase.Effective_Date__c = date.today()+1;
            insert cCase;
            
           /* Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
            defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
            defaultPayment.Zuora__Account__c = accList[0].Id;
            insert defaultPayment;
            
            //create order line item
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0]; 
            oli.Order__c = orderList[0].Id; 
            oli.Main_Package_ID__c = packageList[0].id; 
            insert oli;
            
            
            List<Zuora__Subscription__c> zuoSubList = TestDataFactory.createSubscription(1);
            zuoSubList[0].Zuora__CustomerAccount__c = defaultPayment.id;
            zuoSubList[0].Zuora__Account__c = accList[0].Id;
            zuoSubList[0].Order_Line_Item_Number__c = oli.Id;
            zuoSubList[0].Order_Number__c = orderList[0].Id;
            zuoSubList[0].Suppress_Vendor_Start_Notice__c = 'false';
            zuoSubList[0].Supressed_Acknowledgement_Letter__c = 'false';
            zuoSubList[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zuoSubList[0].Urgent__c = 'false';
            zuoSubList[0].Vendor_Conversion__c = 'false';
            zuoSubList[0].Charity__c = 'false';
            zuoSubList[0].Acquisition_Type__c = 'TEST';            
            zuoSubList[0].Legacy_Create_Date__c = String.valueof(system.today());
            zuoSubList[0].Legacy_Create_By__c = 'abcde';
            zuoSubList[0].Legacy_Update_Date__c = String.valueof(system.today());
            zuoSubList[0].Legacy_Update_By__c = 'abcde';
            zuoSubList[0].Legacy_Subscription_ID__c ='abcde'; 
            zuoSubList[0].Sponsor_1__c = true;
            zuoSubList[0].Number_of_Copies1__c = '3';
            
            database.insert(zuoSubList); */
            
            Address_Assignment__c aa = new Address_Assignment__c();
            aa.Address__c = addressRec.Id;
            aa.Case__c = cCase.Id;
            aa.Contact__c = conList[0].Id;
            aa.Effective_Date__c = date.today();
            aa.Status__c = 'Active';
            aa.End_Date__c = date.today().addDays(2); 
            //aa.Subscription__c = zuoSubList[0].Id;
            insert aa;
            
           /* Vendor_Allocation__c vend = TestDataFactory.createVendorAlloc(1)[0];
            vend.SingPost_Address__c = postal.Id;
            //vend.Status__c = 'active';
            vend.Vendor_Account__c = accList[0].Id;
            vend.Allocated__c = true;
            database.insert(vend);  */
            
            Test.startTest();
            
            PageReference pRef = Page.ChangeInAddressCaseEditPage;
            Test.setCurrentPage(pRef);
            
            ApexPages.StandardController stdController = new ApexPages.Standardcontroller(cCase);
            ChangeInAddressExtensionEdit CIA = new ChangeInAddressExtensionEdit(stdController);
            CIA.changeInAddress.New_Address__c = null; 
            CIA.save();
            
            cCase.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
            update cCase;
            
            ApexPages.StandardController stdController1 = new ApexPages.Standardcontroller(cCase);
            ChangeInAddressExtensionEdit CIA1 = new ChangeInAddressExtensionEdit(stdController1);
            CIA1.changeInAddress.New_Address__c = addressRec.Id; 
            CIA1.changeInAddress.Effective_Date__c = date.today();
            CIA1.save();
            
            ChangeInAddressExtensionEdit.SubscriptionWrapper subs = new ChangeInAddressExtensionEdit.SubscriptionWrapper();
            subs.selectSub = true;
            subs.subName = 'subName';
            subs.subId = null;
            subs.contactName = '';
            subs.vendorName = '';
            subs.status = '';
            
            List<ChangeInAddressExtensionEdit.SubscriptionWrapper> subsList = new List<ChangeInAddressExtensionEdit.SubscriptionWrapper>();
            subsList.add(subs);
            
            CIA1.showSubTable = true;
            CIA1.subscriptionWrapper = subs;
            CIA1.subWrapperList = subsList;
            
            Test.stopTest();
            
            
        }
    } 
    
    static testMethod void testChangeInAddress4(){
        
        //Create a new user with Standard User Profile
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(u) {
            
            List<Account> accList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            List<Case> caseList = new List<Case>(); 
            List<Package__c> packageList = new List<Package__c>();
            List<Zuora__Subscription__c> zuoSubList = new List<Zuora__Subscription__c>();
            List<Address_Assignment__c> addAssignmentList = new List<Address_Assignment__c>();
            List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
            List<Order__c> orderList = new List<Order__c>();
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            //Test.startTest();
            insert postal;
            
            //create Account Records
            accList = TestDataFactory.createAccount(1, 'Vendor');
            accList[0].NRIC__c = 'T1234567R';
            insert accList;
            
            //create Main Package Records
            packageList = TestDataFactory.createPackage(1);
            insert packageList;
            
            //create Billing Account Records
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = accList[0].Id;
            insert billAcc;
            
            //create Address Records
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            //create Contact Records
            conList = TestDataFactory.createContact(1);
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            conList[0].AccountId = accList[0].Id;
            conList[0].Address__c = addressRec.Id;
            conList[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
            insert conList;
            
            //create Order Records
            orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].Id;
            orderList[0].Informed_Customer__c = TRUE;
            orderList[0].Recipient_Contact__c = conList[0].Id;
            
            insert orderList ; 
         
            //insert Case Records
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderList[0].Id;
            
            //ChangeInAddress
            Case cCase = new Case();
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');
            cCase.AccountId = accList[0].Id;
            cCase.Order__c = orderList[0].Id;
            cCase.POP_Start_Date__c = date.today()-5;
            cCase.New_Address__c = addressRec.Id; //modified by AAD
            cCase.Vendor__c = null;
            cCase.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
            cCase.Contact_To_Update__c = conList[0].id;
            cCase.Vendor__c = accList[0].id;
            cCase.Effective_Date__c = date.today();
            insert cCase;
            
            Zuora__Subscription__c subs = TestDataFactory.createSubscription(1)[0];
            subs.Zuora__CustomerAccount__c = billAcc.Id;
            database.insert(subs);
            
            Address_Assignment__c aa = new Address_Assignment__c();
            aa.Address__c = addressRec.Id;
            aa.Case__c = cCase.Id;
            aa.Contact__c = conList[0].Id;
            aa.Effective_Date__c = date.today();
            aa.Status__c = 'Active';
            aa.End_Date__c = date.today().addDays(2); 
            aa.Subscription__c = subs.Id;
            //aa.Subscription_Vendor__c = sv.id;
            //aa.Active__c = True; 
            insert aa;
            
           /* Vendor_Allocation__c vend = TestDataFactory.createVendorAlloc(1)[0];
            vend.SingPost_Address__c = postal.Id;
            //vend.Status__c = 'active';
            vend.Vendor_Account__c = accList[0].Id;
            vend.Allocated__c = true;
            database.insert(vend); */
            
            Test.startTest();
            PageReference pRef = Page.ChangeInAddressCaseEditPage;
            Test.setCurrentPage(pRef);
            
            ApexPages.StandardController stdController2 = new ApexPages.Standardcontroller(cCase);
            ChangeInAddressExtensionEdit CIA2 = new ChangeInAddressExtensionEdit(stdController2);
            CIA2.changeInAddress.Vendor__c = null; 
            CIA2.save();
            
            cCase.Change_of_Address_Type__c = GlobalVariableClass.DELIVERYADDLOC;
            update cCase;
            
            CIA2.updateAssignment();
            
            Test.stopTest();
            
            
        }
    }
    
}