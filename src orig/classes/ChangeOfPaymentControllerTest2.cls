@isTest (Seealldata = TRUE)
private class ChangeOfPaymentControllerTest2 {

	static User testUserCOP; 
	static Case c;
	static Account acc;
	static Zuora__CustomerAccount__c zacc;

	private static void testCreateUser() {
		testUserCOP = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='changeofpaymentcontroller@test.com'
        );
	}

	private static void testDataPrep() {
        testCreateUser();
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'), Email__c = 'sample@email.com', Mobile__c = '1234567');
            insert acc;
                
            zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc.id, Name = 'Test Account', Zuora__Batch__c = 'Batch1', ARMS_ID__c = 'SampleId');
            zacc.ARMS_Return_Message__c = 'Sample Message';
            zacc.Billing_Type__c = 'Recurring Prepaid';
            zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
            zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
            zacc.ARMS_Business_Profile__c = 'GOVT';
            zacc.ARMS_Debt_Management__c = 'GOVT';
            zacc.ARMS_ID__c = 'Sample ID';
            zacc.Zuora__Account__c = acc.id; 
            insert zacc; 
            
            Contact con = TestDataFactory.createContact(1)[0];
            insert con;
            
            Order__c orderAcc = new Order__c(Account__c = acc.id, Credit_Balance__c = decimal.valueof('20.00'), Delivery_Charge__c = decimal.valueof('3.00'), Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'));
            insert orderAcc; 
                
            c = new Case(AccountId = acc.id, Billing_Account_Name__c = zacc.id, RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'CreditCard');
            insert c;  
            
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Order_Number_1__c = orderAcc.id;
            zSub.Zuora__CustomerAccount__c = zacc.Id;
            zSub.Billing_Type__c = 'Recurring Prepaid';
            insert zSub;
        }

	}

	@isTest static void test_searchCusNameSuccess() {
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchCust(true));   
            
        	Test.startTest();

	            PageReference pgR = Page.ChangeOfPaymentType;
	            Test.setCurrentPage(pgR);
	                
	            ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
	            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
	            ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
	            ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
	            
	            changePayment.aCust = 'Test Account';
	            changePayment.thisCase.Payment_Mode__c = 'CreditCard';
	           
	            changePayment.searchCusName();

            Test.stopTest();
            System.assert(changePayment.armsCusWrapList<>null); 
        }
	}

	@isTest static void test_searchCusNameFail() {
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchCust(null));   
            
        	Test.startTest();

	            PageReference pgR = Page.ChangeOfPaymentType;
	            Test.setCurrentPage(pgR);
	                
	            ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
	            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
	            ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
	            ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
	            
	            changePayment.aCust = 'Test Account';
	            changePayment.thisCase.Payment_Mode__c = 'CreditCard';
	            
	            //changePayment.searchAccName();
	            changePayment.searchCusName();

            Test.stopTest();
            System.assert(changePayment.armsCusWrapList==null); 
        }
	}

	@isTest static void test_searchCusNameNotExisting() {
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchCust(false));   
            
        	Test.startTest();

	            PageReference pgR = Page.ChangeOfPaymentType;
	            Test.setCurrentPage(pgR);
	                
	            ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
	            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
	            ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
	            ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
	            
	            changePayment.aCust = 'Test Account';
	            changePayment.thisCase.Payment_Mode__c = 'CreditCard';
	            
	            //changePayment.searchAccName();
	            changePayment.searchCusName();

            Test.stopTest();
            System.assert(changePayment.armsCusWrapList==null); 
        }
	}

	@isTest static void test_searchAccName_0() {
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('0'));   
            
        	Test.startTest();

	            PageReference pgR = Page.ChangeOfPaymentType;
	            Test.setCurrentPage(pgR);
	                
	            ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
	            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
	            ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
	            ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
	            
	            changePayment.aCust = 'Test Account';
	            changePayment.thisCase.Payment_Mode__c = 'CreditCard';
	            
	            changePayment.searchAccName();

            Test.stopTest();
            //System.assert(changePayment.awList<>null); 
        }
	}

	@isTest static void test_searchAccName_1() {
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('1'));   
            
        	Test.startTest();

	            PageReference pgR = Page.ChangeOfPaymentType;
	            Test.setCurrentPage(pgR);
	                
	            ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
	            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
	            ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
	            ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
	            
	            changePayment.aCust = 'Test Account';
	            changePayment.thisCase.Payment_Mode__c = 'CreditCard';
	            
	            changePayment.searchAccName();

            Test.stopTest();
            //System.assert(changePayment.awList<>null); 
        }
	}

	@isTest static void test_searchAccName_8() {
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('8'));   
            
        	Test.startTest();

	            PageReference pgR = Page.ChangeOfPaymentType;
	            Test.setCurrentPage(pgR);
	                
	            ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
	            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
	            ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
	            ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
	            
	            changePayment.aCust = 'Test Account';
	            changePayment.thisCase.Payment_Mode__c = 'CreditCard';
	            
	            changePayment.searchAccName();

            Test.stopTest();
            //System.assert(changePayment.awList<>null); 
        }
	}

	@isTest static void test_searchAccName_n() {
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('n'));   
            
        	Test.startTest();

	            PageReference pgR = Page.ChangeOfPaymentType;
	            Test.setCurrentPage(pgR);
	                
	            ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
	            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
	            ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
	            ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
	            
	            changePayment.aCust = 'Test Account';
	            changePayment.thisCase.Payment_Mode__c = 'CreditCard';
	            
	            changePayment.searchAccName();

            Test.stopTest();
            //System.assert(changePayment.awList<>null); 
        }
	}

	@isTest static void test_searchAccName_null() {
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('x'));   
            
        	Test.startTest();

	            PageReference pgR = Page.ChangeOfPaymentType;
	            Test.setCurrentPage(pgR);
	                
	            ApexPages.currentPage().getParameters().put('RecordType', c.RecordTypeId);
	            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
	            ApexPages.currentPage().getParameters().put('billingaccountId', zacc.Id);
	            ChangeOfPaymentController changePayment = new ChangeOfPaymentController ();    
	            
	            changePayment.aCust = 'Test Account';
	            changePayment.thisCase.Payment_Mode__c = 'CreditCard';
	            
	            changePayment.searchAccName();

            Test.stopTest();
            //System.assert(changePayment.awList<>null); 
        }
	}

}