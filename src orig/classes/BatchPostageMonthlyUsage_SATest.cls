@isTest
private class BatchPostageMonthlyUsage_SATest {

    static testmethod void testTypeis1(){
            Test.setMock(WebServiceMock.class, new zLoginMock());
            
            /*Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            database.insert(key);*/
    
            Other__c other = new Other__c();
            other.Name = 'DTL';
            other.Value__c = '23:59';
            database.insert(other); 
           
            Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            database.insert(cirPlannerSchedule);
            
            Date_Configuration__C dateConfig = new Date_Configuration__c();
            dateConfig.Name = 'Usage Reference Date';
            dateConfig.Date__c = Date.today();
            database.insert(dateConfig);

            try {
               // Test.setMock(WebServiceMock.class, new zLoginMock());   
                User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = [SELECT id from Profile Where Name ='Standard User'].id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
            
                    System.runAs(u){
                    
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
                    //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
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
                   // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    database.insert(con);
                    
                     
                    List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                    billAccountList[0].name = 'April Summer';
                    //billAccountList [0].id = zInv.id;
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
                   // zSub.Order_Line_Item_Number__c = orderLineItem.id;
                    zSub.Recipient_Contact__c = con.id;
                    zSub.Name = 'S0000000';
                    //zSub.Order_Number__c = order.id;
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
                    Set<String> acctNumbers = new Set<String>();
                    String newID = acc.AccountNumber; 
                    acctNumbers.add(newID);
                    
                    List<Contact> allScopes = [SELECT AccountId, Address__c,Recipient_Indicator__c From Contact WHERE Recipient_Indicator__c = true AND Account.AccountNumber IN :acctNumbers];
                    
                    Test.startTest();
                    //BatchPostageMonthlyUsage batch = new BatchPostageMonthlyUsage();
                    BatchPostageMonthlyUsage_SelectAccounts batch = new BatchPostageMonthlyUsage_SelectAccounts(acctNumbers);
                    ID batchprocessid = Database.executeBatch(batch,200);
                    //System.assertNotEquals(null, batchprocessid);
                    
                    Database.BatchableContext bcTemp;
                   // SP_DeliveryChargesBatch newBatch = new SP_DeliveryChargesBatch();
                   // Logger logger = new Logger(SP_DeliveryChargesBatch.class.getName(), 'SP005', bcTemp.getJobID());
                   // batch.start(bcTemp);
                  //  batch.execute(bcTemp, allScopes );
                    //batch.finish(bcTemp);
                    Test.stopTest();
                }
          }
          catch(Zuora.zRemoteException e) {}
     }
        static testmethod void testBatchPostageMonthlyUsageTest() {
             try {
                    Test.setMock(WebServiceMock.class, new zLoginMock());
                    
                    Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                    acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
                    database.insert(acc);
                    
                    List<Contact> contacts = TestDataFactory.createContact(1);
                    for (Contact con : contacts) {
                        con.Company_Name__c = 'Test';
                        con.Recipient_Indicator__c = true;
                        con.AccountId = acc.id;
                    }
                    Database.insert(contacts);
                    
                    Set<String> acctNumbers = new Set<String>();
                    String newID = acc.AccountNumber; 
                    acctNumbers.add(newID);
                    
                    Test.startTest();
                    BatchPostageMonthlyUsage_SelectAccounts batch = new BatchPostageMonthlyUsage_SelectAccounts(acctNumbers);
                    ID batchprocessid = Database.executeBatch(batch,200);
                    //System.assertNotEquals(null, batchprocessid);
                   
                    BatchPostageMonthlyUsage_SelectAccounts batch1 = new BatchPostageMonthlyUsage_SelectAccounts(acctNumbers);
                    Database.BatchableContext bcTemp;
                    
                    batch1.start(bcTemp);
                    batch1.execute(bcTemp, contacts);
                   // batch.finish(bcTemp);
                }
                 catch(Zuora.zRemoteException e) {}
    } 
    static testmethod void testsubEnddatenotNUll(){
            Test.setMock(WebServiceMock.class, new zLoginMock());
/*
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            database.insert(key); 
*/    
            Other__c other = new Other__c();
            other.Name = 'DTL';
            other.Value__c = '23:59';
            database.insert(other); 
           
            Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            database.insert(cirPlannerSchedule);
            
            Date_Configuration__C dateConfig = new Date_Configuration__c();
            dateConfig.Name = 'Usage Reference Date';
            dateConfig.Date__c = Date.today().addDays(30);
            database.insert(dateConfig);

            try {
               // Test.setMock(WebServiceMock.class, new zLoginMock());   
                User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = [SELECT id from Profile Where Name ='Standard User'].id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
            
                    System.runAs(u){
                    
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
                    //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
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
                    //con[0].Recipient_Number__c = 299999912;
                    //con[0].Recipient_Number_Show__c = '299999912';
                   // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    database.insert(con);
                    
                     
                    List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                    billAccountList[0].name = 'April Summer';
                    //billAccountList [0].id = zInv.id;
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
                   // zSub.Order_Line_Item_Number__c = orderLineItem.id;
                    zSub.Recipient_Contact__c = con[0].id;
                    zSub.Name = 'S0000000';
                    //zSub.Order_Number__c = order.id;
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
                    Set<String> acctNumbers = new Set<String>();
                    String newID = acc.AccountNumber; 
                    acctNumbers.add(newID);
                    
                    Test.startTest();
                    BatchPostageMonthlyUsage_SelectAccounts batch = new BatchPostageMonthlyUsage_SelectAccounts(acctNumbers);
                    ID batchprocessid = Database.executeBatch(batch,200);
                    //System.assertNotEquals(null, batchprocessid);
                   
                    BatchPostageMonthlyUsage_SelectAccounts batch1 = new BatchPostageMonthlyUsage_SelectAccounts(acctNumbers);
                    Database.BatchableContext bcTemp;
                    
                    batch1.start(bcTemp);
                    batch1.execute(bcTemp, con);
                }
          }
          catch(Zuora.zRemoteException e) {}
     }      
      static testmethod void testsubPostpaidList(){
            Test.setMock(WebServiceMock.class, new zLoginMock());
            /*
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            database.insert(key); 
            */
            Other__c other = new Other__c();
            other.Name = 'DTL';
            other.Value__c = '23:59';
            database.insert(other); 
           
            Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            database.insert(cirPlannerSchedule);
            
            Date_Configuration__C dateConfig = new Date_Configuration__c();
            dateConfig.Name = 'Usage Reference Date';
            dateConfig.Date__c = Date.today().addDays(30);
            database.insert(dateConfig);

            try {
               // Test.setMock(WebServiceMock.class, new zLoginMock());   
                User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = [SELECT id from Profile Where Name ='Standard User'].id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
            
                    System.runAs(u){
                    
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
                    //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
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
                    //con[0].Recipient_Number_Show__c = '123456';
                    //con[0].Billing_Indicator__c = TRUE;
                   // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    database.insert(con);
                    
                     
                    List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                    billAccountList[0].name = 'April Summer';
                    //billAccountList [0].id = zInv.id;
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
                   // zSub.Order_Line_Item_Number__c = orderLineItem.id;
                    zSub.Recipient_Contact__c = con[0].id;
                    zSub.Name = 'S0000000';
                    //zSub.Order_Number__c = order.id;
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
                    Set<String> acctNumbers = new Set<String>();
                    String newID = acc.AccountNumber; 
                    acctNumbers.add(newID);
                    
                    Test.startTest();
                    BatchPostageMonthlyUsage_SelectAccounts batch = new BatchPostageMonthlyUsage_SelectAccounts(acctNumbers);
                    ID batchprocessid = Database.executeBatch(batch,200);
                    //System.assertNotEquals(null, batchprocessid);
                   
                    BatchPostageMonthlyUsage_SelectAccounts batch1 = new BatchPostageMonthlyUsage_SelectAccounts(acctNumbers);
                    Database.BatchableContext bcTemp;
                    
                    batch1.start(bcTemp);
                    batch1.execute(bcTemp, con);
                    Test.stopTest();
                }
          }
          catch(Zuora.zRemoteException e) {}
     }
     static testmethod void testbillingType(){
            Test.setMock(WebServiceMock.class, new zLoginMock());
            /*
            Key_Id__c key = new Key_Id__c();
            key.Name = 'NEXT_RECIPIENT_NUMBER';
            key.Id__c = '30012551';
            database.insert(key); 
            */
            Other__c other = new Other__c();
            other.Name = 'DTL';
            other.Value__c = '23:59';
            database.insert(other); 
           
            Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            database.insert(cirPlannerSchedule);
            
            Date_Configuration__C dateConfig = new Date_Configuration__c();
            dateConfig.Name = 'Usage Reference Date';
            dateConfig.Date__c = Date.today().addDays(30);
            database.insert(dateConfig);

            try {
               // Test.setMock(WebServiceMock.class, new zLoginMock());   
                User u = new User(
                    Alias = 'stndrd',
                    Email='standarduser@test.com', 
                    EmailEncodingKey='UTF-8',
                    LastName='Test',
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US',
                    ProfileId = [SELECT id from Profile Where Name ='Standard User'].id,
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standard@test.com'
                    );
            
                    System.runAs(u){
                    
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
                    //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
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
                    //con[0].Recipient_Number__c = 299999912;
                    //con[0].Recipient_Number_Show__c = '299999912';
                   // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    database.insert(con);
                    
                     
                    List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                    billAccountList[0].name = 'April Summer';
                    //billAccountList [0].id = zInv.id;
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
                   // zSub.Order_Line_Item_Number__c = orderLineItem.id;
                    zSub.Recipient_Contact__c = con[0].id;
                    zSub.Name = 'S0000000';
                    //zSub.Order_Number__c = order.id;
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
                    Set<String> acctNumbers = new Set<String>();
                    String newID = acc.AccountNumber; 
                    acctNumbers.add(newID);
                    
                    Test.startTest();
                    BatchPostageMonthlyUsage_SelectAccounts batch = new BatchPostageMonthlyUsage_SelectAccounts(acctNumbers);
                    ID batchprocessid = Database.executeBatch(batch,200);
                    //System.assertNotEquals(null, batchprocessid);
                   
                    BatchPostageMonthlyUsage_SelectAccounts batch1 = new BatchPostageMonthlyUsage_SelectAccounts(acctNumbers);
                    Database.BatchableContext bcTemp;
                    
                    batch1.start(bcTemp);
                    batch1.execute(bcTemp, con);
                    Test.stopTest();
                }
          }
          catch(Zuora.zRemoteException e) {}
     }   
}