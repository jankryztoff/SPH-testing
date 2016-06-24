@isTest (seeAllData= true)
private class SM_StartSubscriptionEntry_Test4 {
	
	static User testUserCOP; 
	static Case c;
	static Account acc1;
	static Zuora__CustomerAccount__c zacc;
	static Order__c orderRec_0;
	static List<Order_Line_Item__c> orderline;
	static List<Order_Line_Item__c> orderline1;
	static Package__c packMain;
	static Singpost_Address__c postal;
	static List<zqu__ZProduct__c> listZproducts;
	static Contact con;
	static List<Zuora__CustomerAccount__c> billAccountList;

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
        	//acc1 = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'), Email__c = 'sample@email.com', Mobile__c = '1234567');
         //   insert acc1;
	        acc1 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
	        acc1.Name = 'TEST';
	        acc1.AccountNumber = '123456789';
	        insert acc1;
                
            //zacc = new Zuora__CustomerAccount__c(Zuora__Account__c = acc1.id, Name = 'Test Account', Zuora__Batch__c = 'Batch1', ARMS_ID__c = 'SampleId');
            //zacc.ARMS_Return_Message__c = 'Sample Message';
            //zacc.Billing_Type__c = 'Recurring Prepaid';
            //zacc.Zuora__BillToAddress1__c = 'Sample Bill To Address 1';
            //zacc.Zuora__BillToAddress2__c = 'Sample Bill To Address 2';
            //zacc.ARMS_Business_Profile__c = 'GOVT';
            //zacc.ARMS_Debt_Management__c = 'GOVT';
            //zacc.ARMS_ID__c = 'Sample ID';
            //zacc.Zuora__Account__c = acc1.id; 
            //insert zacc; 
            postal = TestDataFactory.createSingpostAddress(1)[0];
        	insert postal;

	        listZproducts = new list<zqu__ZProduct__c>();
	        
	        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
	        zProductAddOn.ProductPlatform__c = 'Online';
	        zProductAddOn.ProductSubType__c = 'Newspaper';
	        zProductAddOn.ProductFamily__c = 'Test ZB';
	        zProductAddOn.ProductType__c = 'Product';
	        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
	        listZproducts.add(zProductAddOn);
	        
	        //Main Package
	        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
	        zProductMain.ProductPlatform__c = 'Smartphone';
	        zProductMain.ProductSubType__c = 'Newspaper';
	        zProductMain.ProductFamily__c = 'Test ZB';
	        zProductMain.ProductType__c = 'Product';
	        listZproducts.add(zProductMain);
	        
	        insert listZproducts;

	        con = TestDataFactory.createContact(1)[0];
	        //con.Address__c = addressRec.Id;
	        con.AccountId = acc1.Id;
	        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
	        con.Recipient_Indicator__c = true;
	        con.Billing_Indicator__c = true;
	        insert con;

	        billAccountList = TestDataFactory.createBillingAccount(1);
	        billAccountList[0].Zuora__Account__c = acc1.id;
	        billAccountList[0].Name = 'TEST';     
	        billAccountList[0].Zuora__Credit_Balance__c = 0;
	        billAccountList[0].Payment_Mode__c = 'Cash';
	        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
	        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
	        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
	        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
	        billAccountList[0].ARMS_Account_Number__c  = 'tst';
	        insert billAccountList;
            
            Order__c orderAcc = new Order__c(Account__c = acc1.id, Credit_Balance__c = decimal.valueof('20.00'), Delivery_Charge__c = decimal.valueof('3.00'), Monthly_Delivery_Charge_for_Full_Payment__c = decimal.valueof('20.00'));
            insert orderAcc; 
                
            c = new Case(AccountId = acc1.id, Billing_Account_Name__c = billAccountList[0].id, RecordTypeId = ConstantsSLB.getKeyId('Case_Change of Payment Type'), Payment_Mode__c = 'CreditCard');
            insert c;  
            
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Order_Number_1__c = orderAcc.id;
            zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
            zSub.Billing_Type__c = 'Recurring Prepaid';
            insert zSub;

	        packMain = TestDataFactory.createPackage(1)[0];
	        packMain.Name = 'TestNameMain';
	        packMain.Package_Code__c = 'MAINPCK';
	        packMain.Package_Price__c = 2;
	        packMain.Subscription_Type__c = 'Evergreen';
	        packMain.Product_Family_Current_Package__c = 'Test ZB';
	        packMain.Subscription_Period__c = '1';
	        packMain.Billing_Type__c = 'Recurring Prepaid';
	        packMain.Package_Type__c = 'Base';
	        packMain.Subscription_Period_1__c = '12';
	        packMain.Subscription_Period__c = '12';
	        
	        insert packMain;

	        orderRec_0 = TestDataFactory.createOrder(1)[0];
	        orderRec_0.Account__c = acc1.Id;
	        orderRec_0.Recipient_Contact__c = con.Id;
	        orderRec_0.Billing_Contact__c = con.Id;
	        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
	        orderRec_0.Credit_Balance__c = 0;
	        orderRec_0.Payment_Mode__c = 'Other';
	        orderRec_0.Other_Payment_Mode__c  = 'Invoice';
	        orderRec_0.Customer_No__c = 'jx8l22';
	        orderRec_0.ARMS_Account_Number__c = 'jx8l22';
	        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
	        insert orderRec_0;

	        orderline = TestDataFactory.createOrderLineItem(1);
	        orderline[0].Main_Package_ID__c = packMain.Id;
	        orderline[0].Is_Digital__c = TRUE;
	        orderline[0].Order__c = orderRec_0.Id;
	        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
	        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
	        orderline[0].Delivered_By__c  = 'Mailing Agent';    
	        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
	        orderline[0].Main_Package_Billing_Type__c = 'Full Prepaid';
	        orderline[0].Qty__c = 6;
	        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
	        orderline[0].Start_Date__c = date.today().addDays(3);
	        orderline[0].Term_Length__c = 7;
	        orderline[0].New_Contract_Period__c = 3;
	        orderline[0].Promotion_ID__c = null;
	        orderline[0].Term_is_discussed__c = false;
	        insert orderline[0];

	        orderline1 = TestDataFactory.createOrderLineItem(1);
	        orderline1[0].Main_Package_ID__c = packMain.Id;
	        orderline1[0].Is_Digital__c = TRUE;
	        orderline1[0].Order__c = orderRec_0.Id;
	        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
	        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
	        orderline1[0].Delivered_By__c  = 'Mailing Agent';    
	        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
	        orderline1[0].Main_Package_Billing_Type__c = 'Full Prepaid';
	        orderline1[0].Qty__c = 3;
	        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
	        orderline1[0].Start_Date__c =date.today().addDays(3);
	        orderline1[0].Term_Length__c = 3;
	        orderline1[0].New_Contract_Period__c = 3;
	        orderline1[0].Promotion_ID__c = null;//promo.id;
	        orderline1[0].Term_is_discussed__c = false;
	        insert orderline1[0];

        }
	}
  
    static testMethod void unitTest_SearchCustomerInvalidResponse(){
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchCust(null));   
            
        	Test.startTest();

	        PageReference pageRef = Page.SM_StartSubscriptionEntry;
	        pageRef.getParameters().put('accountId', acc1.Id);
	        pageRef.getParameters().put('id', orderRec_0.id);
	        Test.setCurrentPage(pageRef);
	            
			SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
	        ssec.thisOrder = orderRec_0;
	        ssec.orderLineItem = orderline1[0];
	        ssec.orderLineItemList = new list<Order_Line_Item__c>();
	        ssec.orderLineItemList.add(orderline[0]);
	        ssec.orderLineItemList.add(orderline1[0]);  
			ssec.aCust = 'TEST'; 

            ssec.searchCusName();

            Test.stopTest();
            //System.assert(changePayment.armsCusWrapList==null); 
        }
    }

    static testMethod void unitTest_SearchCustomerSuccess(){
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchCust(true));   
            
        	Test.startTest();

	        PageReference pageRef = Page.SM_StartSubscriptionEntry;
	        pageRef.getParameters().put('accountId', acc1.Id);
	        pageRef.getParameters().put('id', orderRec_0.id);
	        Test.setCurrentPage(pageRef);
	            
			SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
	        ssec.thisOrder = orderRec_0;
	        ssec.orderLineItem = orderline1[0];
	        ssec.orderLineItemList = new list<Order_Line_Item__c>();
	        ssec.orderLineItemList.add(orderline[0]);
	        ssec.orderLineItemList.add(orderline1[0]);  
			ssec.aCust = 'TEST'; 

            ssec.searchCusName();

            Test.stopTest();
            //System.assert(changePayment.armsCusWrapList==null); 
        }
    }

    static testMethod void unitTest_SearchCustomerFail(){
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchCust(false));   
            
        	Test.startTest();

	        PageReference pageRef = Page.SM_StartSubscriptionEntry;
	        pageRef.getParameters().put('accountId', acc1.Id);
	        pageRef.getParameters().put('id', orderRec_0.id);
	        Test.setCurrentPage(pageRef);
	            
			SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
	        ssec.thisOrder = orderRec_0;
	        ssec.orderLineItem = orderline1[0];
	        ssec.orderLineItemList = new list<Order_Line_Item__c>();
	        ssec.orderLineItemList.add(orderline[0]);
	        ssec.orderLineItemList.add(orderline1[0]);  
			ssec.aCust = 'TEST'; 

            ssec.searchCusName();

            Test.stopTest();
            //System.assert(changePayment.armsCusWrapList==null); 
        }
    }

    static testMethod void unitTest_SearchCustomerApexPageError(){
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {                             
		  	Test.startTest();

	        PageReference pageRef = Page.SM_StartSubscriptionEntry;
	        pageRef.getParameters().put('accountId', acc1.Id);
	        pageRef.getParameters().put('id', orderRec_0.id);
	        Test.setCurrentPage(pageRef);
	            
			SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
	        ssec.thisOrder = orderRec_0;
	        ssec.orderLineItem = orderline1[0];
	        ssec.orderLineItemList = new list<Order_Line_Item__c>();

            ssec.searchCusName();

            Test.stopTest();
            //System.assert(changePayment.armsCusWrapList==null); 
        }
    }


    static testMethod void unitTest_SearchAccountSuccess(){
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('0'));   
            
        	Test.startTest();

	        PageReference pageRef = Page.SM_StartSubscriptionEntry;
	        pageRef.getParameters().put('accountId', acc1.Id);
	        pageRef.getParameters().put('id', orderRec_0.id);
	        Test.setCurrentPage(pageRef);
	            
			SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
	        ssec.thisOrder = orderRec_0;
	        ssec.orderLineItem = orderline1[0];
	        ssec.orderLineItemList = new list<Order_Line_Item__c>();
	        ssec.orderLineItemList.add(orderline[0]);
	        ssec.orderLineItemList.add(orderline1[0]);  
			ssec.aCust = 'TEST'; 

            ssec.searchAccName();

            Test.stopTest();
            //System.assert(changePayment.armsCusWrapList==null); 
        }
    }

    static testMethod void unitTest_SearchAccountNotExisting(){
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('1'));   
            
        	Test.startTest();

	        PageReference pageRef = Page.SM_StartSubscriptionEntry;
	        pageRef.getParameters().put('accountId', acc1.Id);
	        pageRef.getParameters().put('id', orderRec_0.id);
	        Test.setCurrentPage(pageRef);
	            
			SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
	        ssec.thisOrder = orderRec_0;
	        ssec.orderLineItem = orderline1[0];
	        ssec.orderLineItemList = new list<Order_Line_Item__c>();
	        ssec.orderLineItemList.add(orderline[0]);
	        ssec.orderLineItemList.add(orderline1[0]);  
			ssec.aCust = 'TEST'; 

            ssec.searchAccName();

            Test.stopTest();
            //System.assert(changePayment.armsCusWrapList==null); 
        }
    }

    static testMethod void unitTest_SearchAccountTooManyRecords(){
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('8'));   
            
        	Test.startTest();

	        PageReference pageRef = Page.SM_StartSubscriptionEntry;
	        pageRef.getParameters().put('accountId', acc1.Id);
	        pageRef.getParameters().put('id', orderRec_0.id);
	        Test.setCurrentPage(pageRef);
	            
			SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
	        ssec.thisOrder = orderRec_0;
	        ssec.orderLineItem = orderline1[0];
	        ssec.orderLineItemList = new list<Order_Line_Item__c>();
	        ssec.orderLineItemList.add(orderline[0]);
	        ssec.orderLineItemList.add(orderline1[0]);  
			ssec.aCust = 'TEST'; 

            ssec.searchAccName();

            Test.stopTest();
            //System.assert(changePayment.armsCusWrapList==null); 
        }
    }

	static testMethod void unitTest_SearchAccount_ELSE(){
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('n'));   
            
        	Test.startTest();

	        PageReference pageRef = Page.SM_StartSubscriptionEntry;
	        pageRef.getParameters().put('accountId', acc1.Id);
	        pageRef.getParameters().put('id', orderRec_0.id);
	        Test.setCurrentPage(pageRef);
	            
			SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
	        ssec.thisOrder = orderRec_0;
	        ssec.orderLineItem = orderline1[0];
	        ssec.orderLineItemList = new list<Order_Line_Item__c>();
	        ssec.orderLineItemList.add(orderline[0]);
	        ssec.orderLineItemList.add(orderline1[0]);  
			ssec.aCust = 'TEST'; 

            ssec.searchAccName();

            Test.stopTest();
            //System.assert(changePayment.armsCusWrapList==null); 
        }
    }

    static testMethod void unitTest_SearchAccountFail(){
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {
        	//Test.setMock(WebServiceMock.class, new zLoginMock());                                
        	Test.setMock(WebServiceMock.class, new ResponseGeneratorMockSearchAccount('x'));   
            
        	Test.startTest();

	        PageReference pageRef = Page.SM_StartSubscriptionEntry;
	        pageRef.getParameters().put('accountId', acc1.Id);
	        pageRef.getParameters().put('id', orderRec_0.id);
	        Test.setCurrentPage(pageRef);
	            
			SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
	        ssec.thisOrder = orderRec_0;
	        ssec.orderLineItem = orderline1[0];
	        ssec.orderLineItemList = new list<Order_Line_Item__c>();
	        ssec.orderLineItemList.add(orderline[0]);
	        ssec.orderLineItemList.add(orderline1[0]);  
			ssec.aCust = 'TEST'; 

            ssec.searchAccName();

            Test.stopTest();
            //System.assert(changePayment.armsCusWrapList==null); 
        }
    }

    static testMethod void unitTest_SearchAccountApexPageError(){
		testCreateUser();      
		testDataPrep();
        
        //The test will run as the user created.
        System.runAs(testUserCOP) {  
            
        	Test.startTest();

	        PageReference pageRef = Page.SM_StartSubscriptionEntry;
	        pageRef.getParameters().put('accountId', acc1.Id);
	        pageRef.getParameters().put('id', orderRec_0.id);
	        Test.setCurrentPage(pageRef);
	            
			SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController();
	        ssec.thisOrder = orderRec_0;
	        ssec.orderLineItem = orderline1[0];
	        ssec.orderLineItemList = new list<Order_Line_Item__c>();

            ssec.searchAccName();

            Test.stopTest();
            //System.assert(changePayment.armsCusWrapList==null); 
        }
    }

}