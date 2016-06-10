@isTest
private class BatchPostageMonthlyUsageTest2 {

	@testSetup 
	static void setupData() {
		
		insert CustomSettingsDataFactory.createKey_Id();
		insert CustomSettingsDataFactory.createOther();
		insert CustomSettingsDataFactory.createBatchInterface();
		insert CustomSettingsDataFactory.createBillingBatch();
		insert CustomSettingsDataFactory.createPlannerSched();
		insert CustomSettingsDataFactory.createDateConfig();
	}

	static testMethod void testMetod01() {

        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        database.insert(country);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Block_House_Number__c =  'TEST';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Address__c = address.id;
        con.Recipient_Indicator__c = false;
        database.insert(con);
        
         
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].name = 'April Summer';
        billAccountList[0].Zuora__Account__c = acc.id; 
        billAccountList[0].Billing_Contact__c = con.id;
        billAccountList[0].ARMS_Account_Number__c = '027101021';
        billAccountList[0].Other_PaymentMethod__c ='Invoice';
        billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
        billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Payment_Mode__c = 'CREDITCARD';
        database.insert(billAccountList);
                              
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base Product';
        database.insert(pack);
       
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Name = 'NUM124';
        zSub.Billing_Type__c = 'Full Prepaid';
        zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
        zSub.Subscription_Type_1__c = 'Publication';
        zSub.Subscription_Type__c = 'Publication';
        zSub.Zuora__Account__c = acc.id;
        zSub.Zuora__Status__c = 'Cancelled';
        zSub.Recipient_Contact__c = con.id;
        zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
        zSub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
        zSub.Zuora__AutoRenew__c = False;
        zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
        zSub.Number_of_Copies__c=100;
        zSub.Number_of_Copies1__c =  '100';
        zSub.Qty__c = 20;
        zSub.Subscription_Type_1__c = 'Publication';
        zSub.Subscription_Type__c = 'Publication';
        zSub.Term_Length__c = 1;
        zSub.Term_Length1__c = '1';
        zSub.Main_Package_1__c = pack.id;
        zSub.Main_Package__c = pack.id;
        database.insert(zSub); 
        
        Integer type = 1;
        Set<String> referenceIds = new Set<String>();
        String newID = '' + zSub.id; 
        referenceIds.add(newID);
        
        List<Contact> allScopes = [SELECT AccountId, Address__c,Recipient_Indicator__c From Contact];
        
        Test.startTest();
        BatchPostageMonthlyUsage batch = new BatchPostageMonthlyUsage(referenceIds, type);
        ID batchprocessid = Database.executeBatch(batch,200);
        
        Database.BatchableContext bcTemp;
        Test.stopTest();		
	}
	
	
	static testMethod void method02() {

	    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
	    acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
	    database.insert(acc);
	    
	    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
	    postal.Building_Name__c = 'Ebloc2';
	    database.insert(postal);
	    
	    Country__c country = TestDataFactory.createCountry(1)[0]; 
	    country.Country_Name__c = 'SINGAPORE'; 
	    database.insert(country);
	    
	    Address__c address = TestDataFactory.createAddress(1)[0];
	    address.Block_House_Number__c =  'TEST';
	    address.Postal_Code__c = postal.id;
	    address.Level_Number__c = '17';
	    address.Unit_Number__c = 'Unit 5';
	    address.Country__c = country.id;
	    database.insert(address);
	    
	    contact con = TestDataFactory.createContact(1)[0];
	    con.AccountId = acc.Id;
	    con.Address__c = address.Id;
	    con.Recipient_Indicator__c = true;
	    con.LastName = 'Last Name';
	    con.Billing_Indicator__c = true; 
	    con.FirstName = 'First Name';
	    con.Phone = '1234567';
	    con.Mobile_Number__c = '09155568874'; 
	    con.Mobile_Number_2__c = '09112234567';
	    insert con;
	     
	    List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
	    billAccountList[0].name = 'April Summer';
	    billAccountList[0].Zuora__Account__c = acc.id; 
	    billAccountList[0].Billing_Contact__c = con.id;
	    billAccountList[0].ARMS_Account_Number__c = '027101021';
	    billAccountList[0].Other_PaymentMethod__c ='Invoice';
	    billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
	    billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
	    billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
	    billAccountList[0].Payment_Mode__c = 'CREDITCARD';
	    billAccountList[0].Zuora__AccountNumber__c = '0212542185415451';
	    database.insert(billAccountList);
	                          
	    Package__c pack = TestDataFactory.createPackage(1)[0];
	    pack.Package_Type__c = 'Base Product';
	    database.insert(pack);
	    
	    Order__c order = TestDataFactory.createOrder(1)[0];
	    order.Account__c = acc.Id;
	    order.Informed_Customer__c = TRUE;
	    order.Recipient_Contact__c = con.Id;
	    order.Subscriber_Charge__c = 100.00;
	    database.insert(order);
	   
	    Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
	    zSub.Name = 'NUM124';
	    zSub.Billing_Type__c = 'RECURRING PREPAID';
	    zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
	    zSub.Subscription_Type_1__c = 'Publication';
	    zSub.Subscription_Type__c = 'Publication';
	    zSub.Zuora__Account__c = acc.id;
	    zSub.Zuora__Status__c = 'Cancelled';
	    zSub.Recipient_Contact__c = con.id;
	    zSub.Name = 'S0000000';
	    zSub.Order_Number__c = order.id;
	    zSub.Order_Number_1__c = order.id;
	    zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
	    zSub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
	    zSub.Zuora__AutoRenew__c = False;
	    zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
	    zSub.Number_of_Copies__c=100;
	    zSub.Number_of_Copies1__c =  '100';
	    zSub.Qty__c = 20;
	    zSub.Subscription_Type_1__c = 'Postage';
	    zSub.Subscription_Type__c = 'Postage';
	    zSub.Term_Length__c = 1;
	    zSub.Term_Length1__c = '1';
	    zSub.Main_Package_1__c = pack.id;
	    zSub.Main_Package__c = pack.id;
	    zSub.Zuora__SubscriptionStartDate__c  = date.today();
	    zSub.Zuora__SubscriptionEndDate__c = date.today().addDays(60);
	    database.insert(zSub); 
	    
	    Integer type = 2;
	    Set<String> referenceIds = new Set<String>();
	    String newID = '0212542185415451'; 
	    referenceIds.add(newID);
	    
	    List<Contact> allScopes = [SELECT AccountId, Address__c,Recipient_Indicator__c From Contact];
	    
	    Test.startTest();
	    BatchPostageMonthlyUsage batch = new BatchPostageMonthlyUsage(referenceIds, type);
	    ID batchprocessid = Database.executeBatch(batch,200);
	    
	    Database.BatchableContext bcTemp;
	    Test.stopTest();		
	}
	
	
	static testMethod void method03() {
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        database.insert(country);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Block_House_Number__c =  'TEST';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        database.insert(address);
        
        List<Contact> con = TestDataFactory.createContact(1);
        con[0].AccountId = acc.Id;
        con[0].Address__c = address.id;
        con[0].Recipient_Indicator__c = true;
        con[0].Recipient_Number__c = 123456; 
        database.insert(con);
        
         
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].name = 'April Summer';
        billAccountList[0].Zuora__Account__c = acc.id; 
        billAccountList[0].Billing_Contact__c = con[0].id;
        billAccountList[0].ARMS_Account_Number__c = '027101021';
        billAccountList[0].Other_PaymentMethod__c ='Invoice';
        billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
        billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Payment_Mode__c = 'CREDITCARD';
        database.insert(billAccountList);
                              
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base Product';
        database.insert(pack);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con[0].Id;
        order.Subscriber_Charge__c = 100.00;
        database.insert(order);
       
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Name = 'NUM124';
        zSub.Billing_Type__c = 'Full Prepaid';
        zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
        zSub.Zuora__Account__c = acc.id;
        zSub.Zuora__Status__c = 'Cancelled';
        zSub.Recipient_Contact__c = con[0].id;
        zSub.Name = 'S0000000';
        zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
        zSub.Zuora__SubscriptionEndDate__c = null; //date.Today() + 5;
        zSub.Zuora__AutoRenew__c = False;
        zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
        zSub.Number_of_Copies__c=100;
        zSub.Number_of_Copies1__c =  '100';
        zSub.Qty__c = 20;
        zSub.Subscription_Type_1__c = 'Postage';
        zSub.Subscription_Type__c = 'Postage';
        zSub.Term_Length__c = 1;
        zSub.Term_Length1__c = '1';
        zSub.Main_Package_1__c = pack.id;
        zSub.Main_Package__c = pack.id;
        zSub.Order_Number_1__c = order.id;
        database.insert(zSub); 
        
        Integer type = 1;
        Set<String> referenceIds = new Set<String>();
        String newID = '' + zSub.id; 
        referenceIds.add(newID);
        
        List<Contact> allScopes = [SELECT AccountId, Address__c,Recipient_Indicator__c From Contact];
        
        Test.startTest();
        BatchPostageMonthlyUsage batch = new BatchPostageMonthlyUsage(referenceIds, type);
        ID batchprocessid = Database.executeBatch(batch,200);
        
        Database.BatchableContext bcTemp;
        Test.stopTest();		
	}


	static testMethod void method04() {

        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        database.insert(country);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Block_House_Number__c =  'TEST';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        database.insert(address);
        
        List<Contact> con = TestDataFactory.createContact(1);
        con[0].AccountId = acc.Id;
        con[0].Address__c = address.id;
        con[0].Recipient_Indicator__c = true;                   
        database.insert(con);
        
         
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].name = 'April Summer';
        billAccountList[0].Zuora__Account__c = acc.id; 
        billAccountList[0].Billing_Contact__c = con[0].id;
        billAccountList[0].ARMS_Account_Number__c = '027101021';
        billAccountList[0].Other_PaymentMethod__c ='Invoice';
        billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
        billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Payment_Mode__c = 'CREDITCARD';
        database.insert(billAccountList);
                              
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base Product';
        database.insert(pack);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con[0].Id;
        order.Subscriber_Charge__c = 100.00;
        database.insert(order);
       
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Name = 'NUM124';
        zSub.Billing_Type__c = 'Recurring Prepaid';
        zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
        zSub.Zuora__Account__c = acc.id;
        zSub.Zuora__Status__c = 'Cancelled';
        zSub.Recipient_Contact__c = con[0].id;
        zSub.Name = 'S0000000';
        zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
        zSub.Zuora__SubscriptionEndDate__c = date.Today() + 30;
        zSub.Zuora__AutoRenew__c = False;
        zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
        zSub.Number_of_Copies__c=100;
        zSub.Number_of_Copies1__c =  '100';
        zSub.Qty__c = 20;
        zSub.Subscription_Type_1__c = 'Postage';
        zSub.Subscription_Type__c = 'Postage';
        zSub.Term_Length__c = 1;
        zSub.Term_Length1__c = '1';
        zSub.Main_Package_1__c = pack.id;
        zSub.Main_Package__c = pack.id;
        zSub.Order_Number_1__c = order.id;
        database.insert(zSub); 
        
        Integer type = 1;
        Set<String> referenceIds = new Set<String>();
        String newID = '' + zSub.id; 
        referenceIds.add(newID);
        
        List<Contact> allScopes = [SELECT AccountId, Address__c,Recipient_Indicator__c From Contact];
        
        Test.startTest();
        BatchPostageMonthlyUsage batch = new BatchPostageMonthlyUsage(referenceIds, type);
        ID batchprocessid = Database.executeBatch(batch,200);
        
        Database.BatchableContext bcTemp;
        Test.stopTest();		
	}
	
	
	static testMethod void method05() {

        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Building_Name__c = 'Ebloc2';
        database.insert(postal);
        
        Country__c country = TestDataFactory.createCountry(1)[0]; 
        country.Country_Name__c = 'SINGAPORE'; 
        database.insert(country);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        address.Block_House_Number__c =  'TEST';
        address.Postal_Code__c = postal.id;
        address.Level_Number__c = '17';
        address.Unit_Number__c = 'Unit 5';
        address.Country__c = country.id;
        database.insert(address);
        
        List<Contact> con = TestDataFactory.createContact(1);
        con[0].AccountId = acc.Id;
        con[0].Address__c = address.id;
        con[0].Recipient_Indicator__c = true;
        database.insert(con);
        
         
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].name = 'April Summer';
        billAccountList[0].Zuora__Account__c = acc.id; 
        billAccountList[0].Billing_Contact__c = con[0].id;
        billAccountList[0].ARMS_Account_Number__c = '027101021';
        billAccountList[0].Other_PaymentMethod__c ='Invoice';
        billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
        billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Payment_Mode__c = 'CREDITCARD';
        database.insert(billAccountList);
                              
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Base Product';
        database.insert(pack);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con[0].Id;
        order.Subscriber_Charge__c = 100.00;
        database.insert(order);
       
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Name = 'NUM124';
        zSub.Billing_Type__c = 'Recurring Postpaid';
        zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
        zSub.Zuora__Account__c = acc.id;
        zSub.Zuora__Status__c = 'Cancelled';
        zSub.Recipient_Contact__c = con[0].id;
        zSub.Name = 'S0000000';
        zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
        zSub.Zuora__SubscriptionEndDate__c = date.Today() + 30;
        zSub.Zuora__AutoRenew__c = False;
        zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
        zSub.Number_of_Copies__c=100;
        zSub.Number_of_Copies1__c =  '100';
        zSub.Qty__c = 20;
        zSub.Subscription_Type_1__c = 'Postage';
        zSub.Subscription_Type__c = 'Postage';
        zSub.Term_Length__c = 1;
        zSub.Term_Length1__c = '1';
        zSub.Main_Package_1__c = pack.id;
        zSub.Main_Package__c = pack.id;
        zSub.Order_Number_1__c = order.id;
        database.insert(zSub); 
        
        Integer type = 1;
        Set<String> referenceIds = new Set<String>();
        String newID = '' + zSub.id; 
        referenceIds.add(newID);
        
        List<Contact> allScopes = [SELECT AccountId, Address__c,Recipient_Indicator__c From Contact];
        
        Test.startTest();
        BatchPostageMonthlyUsage batch = new BatchPostageMonthlyUsage(referenceIds, type);
        ID batchprocessid = Database.executeBatch(batch,200);
        
        Database.BatchableContext bcTemp;
        Test.stopTest();		
	}
	
	
	static testMethod void testMethod06() {
                    
        List<Contact> contacts = TestDataFactory.createContact(1);
        for (Contact con : contacts) {
            con.Company_Name__c = 'Test';
            con.Recipient_Indicator__c = true;
        }
        Database.insert(contacts);
        
        Test.startTest();
        BatchPostageMonthlyUsage batch = new BatchPostageMonthlyUsage();
        ID batchprocessid = Database.executeBatch(batch,200);
        
        Database.BatchableContext bcTemp;
		
	}
}