/**
* Class Name: <ChangeOfPaymentController>
* @author: <valgacad>
* Date: <9/18/2014>
* Requirement/Project Name: <CRSM Project>
* @description<Test Class for ChangeOfPaymentController>
*/

@isTest (seeAllData=True)
public class ChangeOfPaymentControllerTest{
    
    static testMethod void VCPC1stTest(){
        // Test.setMock(WebServiceMock.class, new zApiTest());
        // Test.setMock(WebServiceMock.class, new zLoginMock());
        // Test.setMock(WebServiceMock.class, new zCreateAccountMock());
        // Test.setMock(WebServiceMock.class, new zUpdateMock());
        Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchCust(true));
           
        //  ssec.aCust = 'second test'; 
        //Create a new user with Standard User Profile
        //START KINGSLEY
        Id profId = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'].Id;
        User testUserCOP = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profId,
            //ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='changeofpaymentcontroller@test.com'
        );
        //END KINGSLEY
        //The test will run as the user created.
        System.runAs(testUserCOP) {
            //try {
                
                
                
                Account acc = new Account(Name = 'Test Account',
                                        RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'),
                                        Email__c = 'sample@email.com',
                                        Mobile__c = '1234567');
                insert acc;
                
                Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id,
                                                                                Name = 'Test Account',
                                                                                Zuora__Batch__c = 'Batch1',
                                                                                ARMS_ID__c = 'SampleId');
                zacc.ARMS_Return_Message__c = 'Sample Message';
                zacc.Billing_Type__c = 'Recurring Prepaid';
                zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
                zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
                zacc.ARMS_Business_Profile__c = 'GOVT';
                zacc.ARMS_Debt_Management__c = 'SUBH';
                zacc.ARMS_ID__c = '';
                zacc.ARMS_Return_Status__c = 'ReturnS';
                insert zacc;
                
                Order__c orderAcc = new Order__c(Account__c = acc.id,
                                                Credit_Balance__c = decimal.valueof('20.00'),
                                                Delivery_Charge__c = decimal.valueof('3.00'),
                                                Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'));
                insert orderAcc;
                
                Case c = new Case(AccountId = acc.id,
                                Billing_Account_Name__c = zacc.id,
                                RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'CreditCard');
                insert c;  
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Order_Number_1__c = orderAcc.id;
                zSub.Zuora__CustomerAccount__c = zacc.Id;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                insert zSub;
                
                //----JG
                PageReference pgR = Page.ChangeOfPaymentType;
                Test.setCurrentPage(pgR);
                
                ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
                ApexPages.currentPage().getParameters().put('accountId', acc.Id);
                ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
                
                Test.startTest();
                ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
                
                changePayment.aCust = 'Sample Cust';
                changePayment.thisCase.Payment_Mode__c = 'CreditCard';

                changePayment.ARMS_Return_Message = 'Sample Message';
                changePayment.ARMS_Return_Status = 'ReturnS';
                
                changePayment.getBillAccName(); 
                changePayment.searchCusName();
                changePayment.cancelSearch();
                // changePayment.searchAccName();
                changePayment.changeBillingAccount();
                
                
                changePayment.saveRecord();
                changePayment.updateOrderAndSubscriptions('Other', 'CreditCard');

                Test.stopTest();
            //}
            //catch(Zuora.zRemoteException e){}  
        }
    } 

    static testMethod void VCPC3rdTest(){
        // Test.setMock(WebServiceMock.class, new zApiTest());
        // Test.setMock(WebServiceMock.class, new zLoginMock());
        // Test.setMock(WebServiceMock.class, new zCreateAccountMock());
        // Test.setMock(WebServiceMock.class, new zUpdateMock());
        // Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('8'));
        Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchCust(false));
        //Create a new user with Standard User Profile
        //START KINGSLEY
        Id profId = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'].Id;
        User testUserCOP = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profId,
            //ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='changeofpaymentcontroller@test.com'
        );
        //END KINGSLEY
        //The test will run as the user created.
        System.runAs(testUserCOP) {
            //try {
                
                
                
                Account acc = new Account(Name = 'Test Account',
                                        RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'),
                                        Email__c = 'sample@email.com',
                                        Mobile__c = '1234567');
                insert acc;
                
                Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id,
                                                                                Name = 'Test Account',
                                                                                Zuora__Batch__c = 'Batch1',
                                                                                ARMS_ID__c = 'SampleId');
                zacc.ARMS_Return_Message__c = 'Sample Message';
                zacc.Billing_Type__c = 'Recurring Prepaid';
                zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
                zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
                zacc.ARMS_Business_Profile__c = 'GOVT';
                zacc.ARMS_Debt_Management__c = 'GOVT';
                //zacc.ARMS_ID__c = '';
                zacc.ARMS_Return_Status__c = 'ReturnS';
                zacc.Create_ARMS_Customer_Account__c = true;
                insert zacc;
                
                Order__c orderAcc = new Order__c(Account__c = acc.id,
                                                Credit_Balance__c = decimal.valueof('20.00'),
                                                Delivery_Charge__c = decimal.valueof('3.00'),
                                                Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'));
                insert orderAcc;
                
                Case c = new Case(AccountId = acc.id,
                                Billing_Account_Name__c = zacc.id,
                                RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'Invoice');
                insert c;  
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Order_Number_1__c = orderAcc.id;
                zSub.Zuora__CustomerAccount__c = zacc.Id;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                insert zSub;
                
                //----JG
                PageReference pgR = Page.ChangeOfPaymentType;
                Test.setCurrentPage(pgR);
                
                ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
                ApexPages.currentPage().getParameters().put('accountId', acc.Id);
                ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
                
                Test.startTest();
                ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
                
                ////Scenerio 2:  Simulate Null Payment Mode
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = NULL;
                changePayment.thisBillingAccount = null;

                changePayment.searchCusName();
                changePayment.cancelSearch();
                // changePayment.searchAccName();

                changePayment.saveRecord(); 
                
                changePayment = new ChangeOfPaymentController ();
                
                changePayment.dummySubscription = zSub;
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Invoice';
                changePayment.thisBillingAccount = zacc;
                
                changePayment.getAcquisitionTypes();
                //changePayment.getDeliveryChargeTypes();
                changePayment.fetchBillingAccount();
                changePayment.getSource();
                //changePayment.updateBillingAccountArms();
                
                
                changePayment.saveRecord(); 
                Test.stopTest();
 
        }
    }

    static testMethod void VCPC4thTest(){
        // Test.setMock(WebServiceMock.class, new zApiTest());
        // Test.setMock(WebServiceMock.class, new zLoginMock());
        // Test.setMock(WebServiceMock.class, new zCreateAccountMock());
        // Test.setMock(WebServiceMock.class, new zUpdateMock());
        Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('1'));
        //Create a new user with Standard User Profile
        //START KINGSLEY
        Id profId = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'].Id;
        User testUserCOP = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profId,
            //ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='changeofpaymentcontroller@test.com'
        );
        //END KINGSLEY
        //The test will run as the user created.
        System.runAs(testUserCOP) {
            //try {
                
                
                
                Account acc = new Account(Name = 'Test Account',
                                        RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'),
                                        Email__c = 'sample@email.com',
                                        Mobile__c = '1234567');
                insert acc;
                
                Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id,
                                                                                Name = 'Test Account',
                                                                                Zuora__Batch__c = 'Batch1',
                                                                                ARMS_ID__c = 'SampleId');
                zacc.ARMS_Return_Message__c = 'Sample Message';
                zacc.Billing_Type__c = 'Recurring Prepaid';
                zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
                zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
                zacc.ARMS_Business_Profile__c = 'GOVT';
                zacc.ARMS_Debt_Management__c = 'SUBL';
                zacc.ARMS_ID__c = '';
                zacc.ARMS_Return_Status__c = 'ReturnS';
                insert zacc;
                
                Order__c orderAcc = new Order__c(Account__c = acc.id,
                                                Credit_Balance__c = decimal.valueof('20.00'),
                                                Delivery_Charge__c = decimal.valueof('3.00'),
                                                Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'));
                insert orderAcc;
                
                Case c = new Case(AccountId = acc.id,
                                Billing_Account_Name__c = zacc.id,
                                RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'Cheque');
                insert c;  
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Order_Number_1__c = orderAcc.id;
                zSub.Zuora__CustomerAccount__c = zacc.Id;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                insert zSub;
                
                //----JG
                PageReference pgR = Page.ChangeOfPaymentType;
                Test.setCurrentPage(pgR);
                
                ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
                ApexPages.currentPage().getParameters().put('accountId', acc.Id);
                ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
                
                Test.startTest();
                ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
                changePayment.aCust = 'test';
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Cheque';
                //changePayment.updateCreateCustomerService();
                
                //try{
                // changePayment.searchCusName();
                
                changePayment.searchAccName();
                changePayment.cancelSearch();

                changePayment.saveRecord();

                List<ChangeOfPaymentController.armsWrapper> armsList = new List<ChangeOfPaymentController.armsWrapper>();
                ChangeOfPaymentController.armsWrapper arms = new ChangeOfPaymentController.armsWrapper();
               
                arms.arName = 'Sample arName';
                arms.isTick = true;
                armsList.add(arms);

                changePayment.armsCusWrapList = armsList;
                changePayment.addPopAcc();

                Test.stopTest();
 
        }
    }

    static testMethod void VCPC5thTest(){
        // Test.setMock(WebServiceMock.class, new zApiTest());
        // Test.setMock(WebServiceMock.class, new zLoginMock());
        // Test.setMock(WebServiceMock.class, new zCreateAccountMock());
        // Test.setMock(WebServiceMock.class, new zUpdateMock());
        Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('8'));
        //Create a new user with Standard User Profile
        //START KINGSLEY
        Id profId = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'].Id;
        User testUserCOP = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profId,
            //ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='changeofpaymentcontroller@test.com'
        );
        //END KINGSLEY
        //The test will run as the user created.
        System.runAs(testUserCOP) {
            //try {
                
                
                
                Account acc = new Account(Name = 'Test Account',
                                        RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'),
                                        Email__c = 'sample@email.com',
                                        Mobile__c = '1234567');
                insert acc;
                
                Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id,
                                                                                Name = 'Test Account',
                                                                                Zuora__Batch__c = 'Batch1',
                                                                                ARMS_ID__c = 'SampleId');
                zacc.ARMS_Return_Message__c = 'Sample Message';
                zacc.Billing_Type__c = 'Recurring Prepaid';
                zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
                zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
                zacc.ARMS_Business_Profile__c = 'GOVT';
                zacc.ARMS_Debt_Management__c = 'GOVT';
                // zacc.ARMS_ID__c = '';
                zacc.ARMS_Return_Status__c = 'ReturnS';
                zacc.Create_ARMS_Customer_Account__c = true;
                insert zacc;
                
                Order__c orderAcc = new Order__c(Account__c = acc.id,
                                                Credit_Balance__c = decimal.valueof('20.00'),
                                                Delivery_Charge__c = decimal.valueof('3.00'),
                                                Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'));
                insert orderAcc;
                
                Case c = new Case(AccountId = acc.id,
                                Billing_Account_Name__c = zacc.id,
                                RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'Cash');
                insert c;  
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Order_Number_1__c = orderAcc.id;
                zSub.Zuora__CustomerAccount__c = zacc.Id;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                insert zSub;
                
                //----JG
                PageReference pgR = Page.ChangeOfPaymentType;
                Test.setCurrentPage(pgR);
                
                ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
                ApexPages.currentPage().getParameters().put('accountId', acc.Id);
                ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
                
                Test.startTest();
                ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
                
                // changePayment = new ChangeOfPaymentController ();
                changePayment.aCust = 'test';
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Cash';
                //changePayment.updateCreateCustomerService();

                changePayment.searchAccName();
                changePayment.cancelSearch();
                //try{
                changePayment.saveRecord();
                changePayment.updateCreateCustomerService();
                changePayment.paymentGetway = 'Amex';
                changePayment.creditCardType = 'American Express';
                changePayment.retrieveSource();

                List<ChangeOfPaymentController.armsWrapper> armsList = new List<ChangeOfPaymentController.armsWrapper>();
                ChangeOfPaymentController.armsWrapper arms = new ChangeOfPaymentController.armsWrapper();
                ChangeOfPaymentController.armsWrapper arms2 = new ChangeOfPaymentController.armsWrapper();
                arms.arName = 'Sample arName';
                arms.isTick = true;
                armsList.add(arms);

                arms2.arName = 'Sample arName2';
                arms2.isTick = true;
                armsList.add(arms2);
                changePayment.armsCusWrapList = armsList;
                
                changePayment.addPopAcc();
                changePayment.closePopup();
                
                ////Scenerio 6: Cancel 
                changePayment.cancel();
                Test.stopTest();
 
        }
    }

    static testMethod void VCPC6thTest(){
        // Test.setMock(WebServiceMock.class, new zApiTest());
        // Test.setMock(WebServiceMock.class, new zLoginMock());
        // Test.setMock(WebServiceMock.class, new zCreateAccountMock());
        // Test.setMock(WebServiceMock.class, new zUpdateMock());
        Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount(''));
        //Create a new user with Standard User Profile
        //START KINGSLEY
        Id profId = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'].Id;
        User testUserCOP = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profId,
            //ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='changeofpaymentcontroller@test.com'
        );
        //END KINGSLEY
        //The test will run as the user created.
        System.runAs(testUserCOP) {
            //try {
                
                
                
                Account acc = new Account(Name = 'Test Account',
                                        RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'),
                                        Email__c = 'sample@email.com',
                                        Mobile__c = '1234567');
                insert acc;
                
                Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id,
                                                                                Name = 'Test Account',
                                                                                Zuora__Batch__c = 'Batch1',
                                                                                ARMS_ID__c = 'SampleId');
                zacc.ARMS_Return_Message__c = 'Sample Message';
                zacc.Billing_Type__c = 'Recurring Prepaid';
                zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
                zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
                zacc.ARMS_Business_Profile__c = 'GOVT';
                zacc.ARMS_Debt_Management__c = 'GOVT';
                zacc.ARMS_ID__c = '';
                zacc.ARMS_Return_Status__c = 'ReturnS';
                insert zacc;
                
                Order__c orderAcc = new Order__c(Account__c = acc.id,
                                                Credit_Balance__c = decimal.valueof('20.00'),
                                                Delivery_Charge__c = decimal.valueof('3.00'),
                                                Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'));
                insert orderAcc;
                
                Case c = new Case(AccountId = acc.id,
                                Billing_Account_Name__c = zacc.id,
                                RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'Cheque');
                insert c;  
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Order_Number_1__c = orderAcc.id;
                zSub.Zuora__CustomerAccount__c = zacc.Id;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                insert zSub;
                
                //----JG
                PageReference pgR = Page.ChangeOfPaymentType;
                Test.setCurrentPage(pgR);
                
                ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
                ApexPages.currentPage().getParameters().put('accountId', acc.Id);
                ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
                
                Test.startTest();
                ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
                
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Cheque';
                changePayment.thisOrder.Check_Issuing_Bank__c = null;
                changePayment.thisOrder.Check_Amount__c = null;
                changePayment.thisOrder.Check_No__c = '';
                changePayment.thisOrder.Check_Dated__c = null;
                
                //try{
                changePayment.saveRecord(); 
                Test.stopTest();
 
        }
    }

    static testMethod void VCPC7thTestErrorPath(){
        Test.setMock(WebServiceMock.class, new zApiTest());
        Test.setMock(WebServiceMock.class, new zLoginMock());
        Test.setMock(WebServiceMock.class, new zCreateAccountMock());
        Test.setMock(WebServiceMock.class, new zUpdateMock());
        //Create a new user with Standard User Profile
        //START KINGSLEY
        Id profId = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'].Id;
        User testUserCOP = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profId,
            //ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='changeofpaymentcontroller@test.com'
        );
        //END KINGSLEY
        //The test will run as the user created.
        System.runAs(testUserCOP) {
            //try {
                
                
                
                Account acc = new Account(Name = 'Test Account',
                                        RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'),
                                        Email__c = 'sample@email.com',
                                        Mobile__c = '1234567');
                insert acc;
                
                Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id,
                                                                                Name = 'Test Account',
                                                                                Zuora__Batch__c = 'Batch1',
                                                                                ARMS_ID__c = 'SampleId');
                zacc.ARMS_Return_Message__c = 'Sample Message';
                zacc.Billing_Type__c = 'Recurring Prepaid';
                zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
                zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
                zacc.ARMS_Business_Profile__c = 'NONE';
                zacc.ARMS_Debt_Management__c = 'GOVT';
                zacc.ARMS_ID__c = '';
                zacc.ARMS_Return_Status__c = 'ReturnS';
                insert zacc;
                
                Order__c orderAcc = new Order__c(Account__c = acc.id,
                                                Credit_Balance__c = decimal.valueof('20.00'),
                                                Delivery_Charge__c = decimal.valueof('3.00'),
                                                Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'));
                insert orderAcc;
                
                Case c = new Case(AccountId = acc.id,
                                Billing_Account_Name__c = zacc.id,
                                RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'Invoice');
                insert c;  
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Order_Number_1__c = orderAcc.id;
                zSub.Zuora__CustomerAccount__c = zacc.Id;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                insert zSub;
                
                //----JG
                PageReference pgR = Page.ChangeOfPaymentType;
                Test.setCurrentPage(pgR);
                
                ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
                ApexPages.currentPage().getParameters().put('accountId', acc.Id);
                ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
                
                Test.startTest();
                ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
                
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Invoice';
                
                //try{
                changePayment.saveRecord(); 
                Test.stopTest();
 
        }
    }

    static testMethod void VCPC8thTestErrorPath(){
        Test.setMock(WebServiceMock.class, new zApiTest());
        Test.setMock(WebServiceMock.class, new zLoginMock());
        Test.setMock(WebServiceMock.class, new zCreateAccountMock());
        Test.setMock(WebServiceMock.class, new zUpdateMock());
        //Create a new user with Standard User Profile
        //START KINGSLEY
        Id profId = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'].Id;
        User testUserCOP = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profId,
            //ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='changeofpaymentcontroller@test.com'
        );
        //END KINGSLEY
        //The test will run as the user created.
        System.runAs(testUserCOP) {
            //try {
                
                
                
                Account acc = new Account(Name = 'Test Account',
                                        RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'),
                                        Email__c = 'sample@email.com',
                                        Mobile__c = '1234567');
                insert acc;
                
                Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id,
                                                                                Name = 'Test Account',
                                                                                Zuora__Batch__c = 'Batch1',
                                                                                ARMS_ID__c = 'SampleId');
                zacc.ARMS_Return_Message__c = 'Sample Message';
                zacc.Billing_Type__c = 'Recurring Prepaid';
                zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
                zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
                zacc.ARMS_Business_Profile__c = 'NONE';
                zacc.ARMS_Debt_Management__c = 'GOVT';
                zacc.ARMS_ID__c = '';
                zacc.ARMS_Return_Status__c = 'ReturnS';
                insert zacc;
                
                Order__c orderAcc = new Order__c(Account__c = acc.id,
                                                Credit_Balance__c = decimal.valueof('20.00'),
                                                Delivery_Charge__c = decimal.valueof('3.00'),
                                                Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'));
                insert orderAcc;
                
                Case c = new Case(AccountId = acc.id,
                                Billing_Account_Name__c = zacc.id,
                                RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = '');
                insert c;  
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Order_Number_1__c = orderAcc.id;
                zSub.Zuora__CustomerAccount__c = zacc.Id;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                insert zSub;
                
                //----JG
                PageReference pgR = Page.ChangeOfPaymentType;
                Test.setCurrentPage(pgR);
                
                ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
                ApexPages.currentPage().getParameters().put('accountId', acc.Id);
                ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
                
                Test.startTest();
                ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
                
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = '';
                
                //try{
                changePayment.saveRecord(); 
                Test.stopTest();
 
        }
    }

    static testMethod void VCPC9thTestErrorPath(){
        Test.setMock(WebServiceMock.class, new zApiTest());
        Test.setMock(WebServiceMock.class, new zLoginMock());
        Test.setMock(WebServiceMock.class, new zCreateAccountMock());
        Test.setMock(WebServiceMock.class, new zUpdateMock());
        //Create a new user with Standard User Profile
        //START KINGSLEY
        Id profId = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'].Id;
        User testUserCOP = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profId,
            //ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='changeofpaymentcontroller@test.com'
        );
        //END KINGSLEY
        //The test will run as the user created.
        System.runAs(testUserCOP) {
            //try {
                
                
                
                Account acc = new Account(Name = 'Test Account',
                                        RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'),
                                        Email__c = 'sample@email.com',
                                        Mobile__c = '1234567');
                insert acc;
                
                Zuora__CustomerAccount__c zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id,
                                                                                Name = 'Test Account',
                                                                                Zuora__Batch__c = 'Batch1',
                                                                                ARMS_ID__c = 'SampleId');
                zacc.ARMS_Return_Message__c = 'Sample Message';
                zacc.Billing_Type__c = 'Recurring Prepaid';
                zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
                zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
                zacc.ARMS_Business_Profile__c = 'NONE';
                zacc.ARMS_Debt_Management__c = 'GOVT';
                zacc.ARMS_ID__c = '';
                zacc.ARMS_Return_Status__c = 'ReturnS';
                insert zacc;
                
                Order__c orderAcc = new Order__c(Account__c = acc.id,
                                                Credit_Balance__c = decimal.valueof('20.00'),
                                                Delivery_Charge__c = decimal.valueof('3.00'),
                                                Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'),
                                                Check_Issuing_Bank__c = NULL,
                                                Check_No__c = NULL,
                                                Check_Dated__c = NULL,
                                                Check_Amount__c = NULL);
                insert orderAcc;
                
                Case c = new Case(AccountId = acc.id,
                                Billing_Account_Name__c = zacc.id,
                                RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'Cheque');
                insert c;  
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Order_Number_1__c = orderAcc.id;
                zSub.Zuora__CustomerAccount__c = zacc.Id;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                insert zSub;
                
                //----JG
                PageReference pgR = Page.ChangeOfPaymentType;
                Test.setCurrentPage(pgR);
                
                ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
                ApexPages.currentPage().getParameters().put('accountId', acc.Id);
                ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
                
                Test.startTest();
                ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
                
                changePayment = new ChangeOfPaymentController ();
                changePayment.thisCase.AccountId = acc.Id;
                changePayment.thisCase.Billing_Account_Name__c = zacc.id;
                changePayment.thisCase.Payment_Mode__c = 'Cheque';
                changePayment.thisOrder.Check_Issuing_Bank__c = '';
                changePayment.thisOrder.Check_No__c = '';
                changePayment.thisOrder.Check_Dated__c = NULL;
                changePayment.thisOrder.Check_Issuing_Bank__c = '';
                
                //try{
                changePayment.saveRecord(); 
                Test.stopTest();
 
        }
    }
    //sets all getters and setters by jowie
    static testmethod void setAllUncoveredAttributes(){
        
        ChangeOfPaymentController copc = new ChangeOfPaymentController();
        copc.ARMS_Return_Message = 'test';
        copc.ARMS_Return_Status = 'text';
        copc.ARMS_Total_Outstanding_Amount = 1.0;
        copc.ARMS_Update_Ind = true;
        copc.Credit_Term  = 1.0;
        
        copc.Credit_Limit_Internal = 1.0;
        copc.Credit_Limit_External = 1.0;
        
        copc.Credit_Reference = 'test';
        copc.acquisitionType = 'test';
        copc.deliveryChargeType = 'test';
        copc.billingAccountOption = 'test';
        copc.glCode = 'test';
        copc.paymentMethodId = 'test';
        
        copc.fullPaymentMonthlyDeliveryCharge = 1.0;
        copc.subscriberCharge = 1.0; 
        copc.vendorCredit = 1.0; 
        copc.amountPaid = 1.0; 
        copc.isSponsored = true;
        copc.dtlDate = date.Today();
        
        
        ChangeOfPaymentController.armsWrapper copc_aw = new ChangeOfPaymentController.armsWrapper();
        copc_aw.arPOC = 'test';        
        copc_aw.arAddress = 'test';        
        copc_aw.arPostcode = 'test';      
        copc_aw.arStatus = 'test';  
        copc_aw.arAccNum = 'test';     
        copc_aw.arType = 'test';       
        copc_aw.arCredTerm = 'test';        
        copc_aw.arCredTermRef = 'test';        
        copc_aw.arDebtMgmt = 'test';       
        copc_aw.arCompCode = 'test';        
        copc_aw.arCreateDate = 'test';      
        copc_aw.arBLInd = 'test';       
        copc_aw.BLClrCd = 'test';      
        copc_aw.BLRsn = 'test';      
        copc_aw.IdTyp = 'test';       
        copc_aw.IdN = 'test';  
        copc_aw.PpCntryC = 'test';
        copc_aw.CrRskRtg = 'test';      
        copc_aw.CrLmtInt = 'test';    
        copc_aw.CrLmtExt = 'test';   
        copc_aw.CityM = 'test';         
        copc_aw.Cntry = 'test';     
        copc_aw.PoBoxN = 'test';        
        copc_aw.AttnI = 'test';        
        copc_aw.StfI = 'test';  
        copc_aw.GstOOSI = 'test';       
        copc_aw.UpdId = 'test';       
        copc_aw.UpdDte = 'test';        
        copc_aw.UpdTme = 'test';     
        copc_aw.arDate = 'test';       
        copc_aw.arAddress3 = 'test';        
        copc_aw.arAddress4 = 'test'; 
    }
    
    


}