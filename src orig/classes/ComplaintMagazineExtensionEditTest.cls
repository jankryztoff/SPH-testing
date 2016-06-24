/**
 * Class Name: <ComplaintMagazineExtensionEditTest>
 * @author: <KarlTan, MarkJhustinPinoy>
 * @revised: <Thayne Recato Dy - 02/10/2015>
 * Date: <8/16/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for ComplaintMagazineExtensionEdit>
 */
@isTest (seeAllData = TRUE)
private class ComplaintMagazineExtensionEditTest {
    
    /*
    *   @description: This test method executes the constructor of the base class
    *               and provides the right Account for the conditions in it.
    *   @Parameters: N/A
    *   @return: N/A
    */     
    static testmethod void testForRightVendorForInitialization() {
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        User userCMEET = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='compmagext1@test.com'
                );
        
            //The test will run as the user created.
            System.runAs(userCMEET) {
                
                Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
                insert acc;
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                //addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
    
                List<Contact> con = TestDataFactory.createContact(1);
                con[0].Address__c = addressRec.Id;
                con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con[0].Recipient_Indicator__c = true;
                con[0].Phone = '1234567';
                con[0].AccountId = acc.Id;
                insert con;            
    
                //create order
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Recipient_Contact__c = con[0].Id;
                order.Billing_Type__c = 'Full Prepaid';
                System.debug('DEBUG con.Id' + con[0].Id);
                order.Informed_Customer__c = True;
                insert order;   
                
                test.StartTest();
                //create case
                Case cas = new Case();
                cas.AccountId = acc.id;
                cas.Order__c = order.Id;
                cas.Origin = 'Phone';
                cas.Priority = 'Medium';
                cas.Date_Replaced__c = system.today();
                cas.Status = 'New';
                insert cas;
                
                //create Package
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Base';
                pack.Name = 'Test Package';
                pack.Package_Code__c = 'testcode';
                insert pack;
                
                //create Order Line Item
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.End_Date__c = date.today().addDays(5);
                orderline.Main_Package_ID__c = pack.Id;
                //orderline.Addon_Package__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Earliest_Start_Date__c = date.today();
                orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                insert orderline;
                    
                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];   
                billingAcc.Zuora__Account__c = acc.Id;
                billingAcc.Billing_Type__c = 'Full Prepaid';
                insert billingAcc;
                
                List <Zuora__Subscription__c> SubsList = new List <Zuora__Subscription__c>();
                Zuora__Subscription__c Sub = new Zuora__Subscription__c();
                Sub.Zuora__Account__c = acc.id;
                Sub.Zuora__CustomerAccount__c = billingAcc.id;
                Sub.Name= 'CS0000000110';
                Sub.Qty__c = 10;
                Sub.Qty1__c = '10';
                Sub.Number_of_Copies__c= 10;
                //Subs.Number_of_Copies1__c ='10';
                Sub.Order_Number__c = order.id;
                Sub.Order_Number_1__c = order.id;
                Sub.Next_Earliest_Start_Date__c= date.today();
                Sub.Unique_Address_Id__c= 'asdasdasd';
                Sub.Year_to_Date_Temp_Stop_Days__c= 2;
                Sub.Previous_Year_Temp_Stop_Days__c= 2;
                Sub.Legacy_Create_Date__c='2014-08-07';
                Sub.Legacy_Create_By__c='test';
                Sub.Legacy_Update_Date__c='test';
                Sub.Legacy_Update_By__c='test';
                Sub.Legacy_Subscription_ID__c='test';
                Sub.Cheque_details__c='test';
                Sub.DTL__c='test';
                Sub.Paypal_Payment_Profile_Id__c='test';
                Sub.Pub_Tag__c='test';
                //Subs.Sponsored_Indicator__c=
                Sub.Subscribe_As__c='test';
                Sub.Zuora__SubscriptionStartDate__c= Date.newInstance(2015,07,07);
                Sub.Zuora__SubscriptionEndDate__c= Date.newInstance(2015,10,11);
                Sub.Subscription_Grace_Period_End_Date__c= 'test';
                Sub.Gift_ID__c= 'test';
                Sub.Redeem_Date__c= 'test';
                Sub.Gift_ID_2__c= 'test';
                Sub.Redeem_Date_2__c= 'test';
                Sub.Subscriber_Contact__c= con[0].Id;
                Sub.Recipient_Contact__c= con[0].Id;
                Sub.Subscription_Charge__c= 223.0;
                Sub.Term_Length__c= 2;
                Sub.Order_Line_Item_Number__c= orderline.id;
                Sub.Main_Package_1__c= pack.id;
                Sub.Zuora__Zuora_Id__c= 'test';
                Sub.Delivered_by_1__c = 'Mailing Agent';
                Sub.Billing_Type__c = 'Full Prepaid';
                SubsList.add(Sub);
                insert SubsList;
                
                /*Map<String, SObject> sObjMap = new Map<String, SObject>(); 
                sObjMap = TestDataFactory.createSubscriptionPackage();           
                Zuora__Subscription__c subRecs = (Zuora__Subscription__c ) sObjMap.get('Zuora__Subscription__c');
                subRecs.Zuora__Account__c = vendorSubsAcct.id;                
                Test.startTest();
                database.insert(subRecs);*/
                              

                //List<Case> CasRecType = [SELECT RecordTypeId FROM Case WHERE ContactId =:con.Id];                     
                /*
                Case_Subscription__c subs = new Case_Subscription__c();
                subs.Case__c = cas.id;
                subs.Account__c = acc.Id;
                subs.Subscription__c = subslist[0].id;        
                subs.Address__c = addressrec.id;        
                database.insert(subs);
                */
                Subscription_Vendor__c subsVendor = new Subscription_Vendor__c();
                database.insert(subsVendor);
                
                Case_Vendor_Subscription__c csv = new Case_Vendor_Subscription__c();
                csv.Case__c = cas.id;
                csv.Subscription_Vendor__c = subsVendor.id;
                database.insert(csv);
                
                System.assertNotEquals(NULL, cas);
                                
                //initialize page and controllers with the condition of with ID for the account ID but wrong Vendor
                PageReference pgRef = Page.ComplaintMagazineEditPage;
                Test.setCurrentPage(pgRef);
                ApexPages.currentPage().getParameters().put('id', cas.id);
                ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
                ComplaintMagazineExtensionEdit compMagextn = new ComplaintMagazineExtensionEdit (stdCtrlr);
                
                
                Test.stopTest();
            }
            }catch(Zuora.zRemoteException e) {
          }  
                  
    
  }
    /*
    *   @description: This test method executes the constructor of the base class
    *               and provides the wrong Account for the conditions in it.
    *   @Parameters: N/A
    *   @return: N/A
    */     
    static testmethod void testForWrongVendorForInitialization() {
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());    
        User user2 = new User(
                Alias = 'stndrd',
                Email='standarduser@test.com', 
                EmailEncodingKey='UTF-8',
                LastName='Test',
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
                TimeZoneSidKey='America/Los_Angeles',
                UserName='complaintmagext2@test.com'
                );
        
            //The test will run as the user created.
            System.runAs(user2) {
                
                Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'), Email__c = 'test@test.com', Mobile__c = '1234567890' );
                insert acc;
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                //addressRec.Postal_Code__c = postal.Id;
                insert addressRec;
    
                List<Contact> con = TestDataFactory.createContact(1);
                con[0].Address__c = addressRec.Id;
                con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con[0].Recipient_Indicator__c = true;
                con[0].Phone = '1234567';
                con[0].AccountId = acc.Id;
                insert con;            
    
                //create order
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = acc.Id;
                order.Recipient_Contact__c = con[0].Id;
                order.Billing_Type__c = 'Full Prepaid';
                System.debug('DEBUG con.Id' + con[0].Id);
                order.Informed_Customer__c = True;
                insert order;   
                
                test.StartTest();
                //create case
                Case cas = new Case();
                cas.AccountId = acc.id;
                cas.Order__c = order.Id;
                cas.Origin = 'Phone';
                cas.Priority = 'Medium';
                cas.Date_Replaced__c = system.today();
                cas.Status = 'New';
                insert cas;
                
                //create Package
                
                Package__c pack = new Package__c();
                pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Base';
                pack.Name = 'Test Package';
                pack.Package_Code__c = 'testcode';
                insert pack;
                
                //create Order Line Item
                
                Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                orderline.Order__c = order.Id;
                orderline.Start_Date__c = date.today().addDays(1);
                orderline.End_Date__c = date.today().addDays(5);
                orderline.Main_Package_ID__c = pack.Id;
                //orderline.Addon_Package__c = pack.Id;
                orderline.Term_Length__c = 0;
                orderline.Main_Package_Period__c = 0;
                orderline.Earliest_Start_Date__c = date.today();
                orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
                orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                orderline.Terminating_Reason__c = 'Others';
                orderline.Amount_To_Refund__c = 0;
                orderline.Admin_Charge__c = 0;
                orderline.Fee_Waiver__c = TRUE;
                orderline.Fee_Override__c = FALSE;
                orderline.Override_Reason__c = 'TEST';
                orderline.Suppress_Notification_Stop__c = TRUE;
                orderline.Main_Package_Type__c = 'Base';
                insert orderline;
                    
                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];   
                billingAcc.Zuora__Account__c = acc.Id;
                billingAcc.Billing_Type__c = 'Full Prepaid';
                insert billingAcc;
                
                List <Zuora__Subscription__c> SubsList = new List <Zuora__Subscription__c>();
                Zuora__Subscription__c Sub = new Zuora__Subscription__c();
                Sub.Zuora__Account__c = acc.id;
                Sub.Zuora__CustomerAccount__c = billingAcc.id;
                Sub.Name= 'CS0000000110';
                Sub.Qty__c = 10;
                Sub.Qty1__c = '10';
                Sub.Number_of_Copies__c= 10;
                //Subs.Number_of_Copies1__c ='10';
                Sub.Order_Number__c = order.id;
                Sub.Order_Number_1__c = order.id;
                Sub.Next_Earliest_Start_Date__c= date.today();
                Sub.Unique_Address_Id__c= 'asdasdasd';
                Sub.Year_to_Date_Temp_Stop_Days__c= 2;
                Sub.Previous_Year_Temp_Stop_Days__c= 2;
                Sub.Legacy_Create_Date__c='2014-08-07';
                Sub.Legacy_Create_By__c='test';
                Sub.Legacy_Update_Date__c='test';
                Sub.Legacy_Update_By__c='test';
                Sub.Legacy_Subscription_ID__c='test';
                Sub.Cheque_details__c='test';
                Sub.DTL__c='test';
                Sub.Paypal_Payment_Profile_Id__c='test';
                Sub.Pub_Tag__c='test';
                //Subs.Sponsored_Indicator__c=
                Sub.Subscribe_As__c='test';
                Sub.Zuora__SubscriptionStartDate__c= Date.newInstance(2015,07,07);
                Sub.Zuora__SubscriptionEndDate__c= Date.newInstance(2015,10,11);
                Sub.Subscription_Grace_Period_End_Date__c= 'test';
                Sub.Gift_ID__c= 'test';
                Sub.Redeem_Date__c= 'test';
                Sub.Gift_ID_2__c= 'test';
                Sub.Redeem_Date_2__c= 'test';
                Sub.Subscriber_Contact__c= con[0].Id;
                Sub.Recipient_Contact__c= con[0].Id;
                Sub.Subscription_Charge__c= 223.0;
                Sub.Term_Length__c= 2;
                Sub.Order_Line_Item_Number__c= orderline.id;
                Sub.Main_Package_1__c= pack.id;
                Sub.Zuora__Zuora_Id__c= 'test';
                Sub.Delivered_by_1__c = 'Mailing Agent';
                Sub.Billing_Type__c = 'Full Prepaid';
                SubsList.add(Sub);
                insert SubsList;
                
                /*Map<String, SObject> sObjMap = new Map<String, SObject>(); 
                sObjMap = TestDataFactory.createSubscriptionPackage();           
                Zuora__Subscription__c subRecs = (Zuora__Subscription__c ) sObjMap.get('Zuora__Subscription__c');
                subRecs.Zuora__Account__c = vendorNotSubsAcct.id;                
                Test.startTest();
                database.insert(subRecs);*/
                        

                /*Case_Subscription__c subs = new Case_Subscription__c();
                subs.Case__c = cas.id;
                subs.Account__c = acc.Id;
                subs.Subscription__c = subsList[0].id;        
                subs.Address__c = addressrec.id;        
                //database.insert(subs);
                  */  
                Subscription_Vendor__c subsVendor = new Subscription_Vendor__c();
                database.insert(subsVendor);
                
                Case_Vendor_Subscription__c csv = new Case_Vendor_Subscription__c();
                csv.Case__c = cas.id;
                csv.Subscription_Vendor__c = subsVendor.id;
                database.insert(csv);
                                
                System.assertNotEquals(NULL, cas);
                
                //initialize page and controllers with the condition of with ID for the account ID but wrong Vendor
                PageReference pgRef = Page.ComplaintMagazineEditPage;
                Test.setCurrentPage(pgRef);
                ApexPages.currentPage().getParameters().put('id', cas.id);
                ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
                ComplaintMagazineExtensionEdit compMagextn = new ComplaintMagazineExtensionEdit (stdCtrlr);
                
                Test.stopTest();
            }
            }catch(Zuora.zRemoteException e) {
          }  
                  
    
  }
    /*
    *   @description: This test method executes the constructor of the base class
    *               and provides a NULL Case for the conditions in it.
    *   @Parameters: N/A
    *   @return: N/A
    */     
    static testmethod void testForInitializationWithNull() {
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
             User user3 = new User(
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
            System.runAs(user3) {
            
                Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                vendorSubsAcct .NRIC__c = 'T1234567R';
                database.insert(vendorSubsAcct);
                
                Account vendorNotSubsAcct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                vendorNotSubsAcct .NRIC__c = 'T7654321R';
                database.insert(vendorNotSubsAcct);
                
                Address__c add = TestDataFactory.createAddress(1)[0];
                database.insert(add);
                
                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];   
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                billingAcc.Billing_Type__c = 'Full Prepaid';
                database.insert(billingAcc);
                
                Contact con = TestDataFactory.createContact(1)[0];
                con.AccountId = vendorSubsAcct.Id;
                con.Address__c = add.Id;
                //START CCB.002 Modified by: Francis Benzon
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                //END CCB.002 Modified by: Francis Benzon
                database.insert(con);
            
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = vendorSubsAcct.Id; 
                order.Recipient_Contact__c = con.Id;
                order.Billing_Account__c = billingAcc.Id;
                order.Billing_Type__c = 'Full Prepaid';
                order.Informed_Customer__c = True;
                database.insert(order);
                
                RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];

                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.IsEscalated = true;
                cas.Order__c = order.Id;
                cas.AccountId = vendorSubsAcct.Id;
                cas.ContactId = con.Id;
                cas.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1].id;//'012N00000008kI8IAI';
                database.insert(cas);
                
                Test.startTest();
                
                System.assertNotEquals(NULL, vendorNotSubsAcct.Id);
                    
                //initialize page and controllers with the condition of NULL account ID and right Vendor
                PageReference pgRef = Page.ComplaintMagazineEditPage;
                Test.setCurrentPage(pgRef);
                ApexPages.currentPage().getParameters().put('id', NULL);
                ApexPages.currentPage().getParameters().put('accountId', vendorSubsAcct.Id);
                ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
                ComplaintMagazineExtensionEdit compMagextn = new ComplaintMagazineExtensionEdit (stdCtrlr);
                
                //initialize page and controllers with the condition of NULL account ID and wrong Vendor
                ApexPages.currentPage().getParameters().put('id', NULL);
                ApexPages.currentPage().getParameters().put('accountId', vendorNotSubsAcct.Id);
                ApexPages.StandardController newStdCtrlr = new ApexPages.StandardController(cas);
                ComplaintMagazineExtensionEdit newCompMagextn = new ComplaintMagazineExtensionEdit (newStdCtrlr);
                
                newCompMagextn.save();
                
                Test.stopTest();
            }
            }catch(Zuora.zRemoteException e) {
          }  
                  
    
  }
    /*
    *   @description: This test method executes the all methods and its conditions.
    *   @Parameters: N/A
    *   @return: N/A
    */     
    static testMethod void testFetchAccountDetails(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        //Create a new user with Standard User Profile
        User user4 = new User(
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
        System.runAs(user4) {
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '123';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            insert postal;
            
            Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            vendorSubsAcct .NRIC__c = 'T1234567R';
            database.insert(vendorSubsAcct);
            
            Account vendorNotSubsAcct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            vendorNotSubsAcct .NRIC__c = 'T7654321R';
            database.insert(vendorNotSubsAcct);
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Postal_Code__c = postal.Id;
            database.insert(add);
            
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];  
            billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
            billingAcc.Billing_Type__c = 'Full Prepaid';
            database.insert(billingAcc);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = vendorSubsAcct.Id;
            con.Address__c = add.Id;
            //START CCB.002 Modified by: Francis Benzon
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            database.insert(con);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = vendorSubsAcct.Id; 
            order.Recipient_Contact__c = con.Id;
            order.Billing_Account__c = billingAcc.Id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Informed_Customer__c = True;
            database.insert(order);
            
            RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.IsEscalated = true;
            cas.Order__c = order.Id;
            cas.AccountId = vendorSubsAcct.Id;
            cas.ContactId = con.Id;
            cas.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1].id; //'012N00000008kI8IAI';
            database.insert(cas);       
            
            System.assertNotEquals(NULL, cas);
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
            for(Zuora__Subscription__c subRecs : subList){
                subRecs.Zuora__CustomerAccount__c = billingAcc.Id;
                subRecs.Zuora__Account__c = vendorSubsAcct.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Term_Length__c = 2;
                subRecs.Zuora__SubscriptionStartDate__c = date.today().addMonths(1).toStartofMonth().addDays(-1);
                //subRecs.Zuora__SubscriptionStartDate__c = subDate;
                subRecs.Zuora__SubscriptionEndDate__c = null;
                //subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(60);
                //subRecs.Zuora__SubscriptionEndDate__c = subDate.addMonths(integer.valueOf(subRecs.Term_Length__c)).addDays(-1);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                subRecs.Number_of_Copies__c = 100;
            }
            insert subList;
            
            /*List<Case_Subscription__c> casSubList = TestDataFactory.createCaseSubscription(2);
                for(Case_Subscription__c casSubRec : casSubList){
                    casSubRec.Account__c = vendorSubsAcct.Id;
                    casSubRec.Address__c = add.Id;
                    casSubRec.Case__c = cas.Id;
                    casSubRec.Subscription__c = subList[0].Id;
                    //casSubRec.Complaint_From__c = date.today();
                    //casSubRec.Complaint_To__c = date.today().addDays(10);
                }
            insert casSubList;*/
            
            List<Subscription_Vendor__c> subVenList = TestDataFactory.createSubscriptionVendor(1);
            for(Subscription_Vendor__c subVen : subVenList){
                subVen.Account__c = vendorSubsAcct.Id;
                subVen.Recipient__c = con.Id;
                subVen.Order_Number__c = order.Id;
            }
            insert subVenList;
            
            List<Case_Vendor_Subscription__c> caseVenSubList = TestDataFactory.createCaseVendorSub(1);
            for(Case_Vendor_Subscription__c caseVenSub : caseVenSubList){
                caseVenSub.Account__c = vendorSubsAcct.Id;
                caseVenSub.Address__c = add.Id;
                caseVenSub.Case__c = cas.Id;
                caseVenSub.Subscription_Vendor__c = subVenList[0].Id;
            }
            insert caseVenSubList;

            /*Set<Id> caseVenSubId = new Set<Id>();
            for(Case_Vendor_Subscription__c casVenSub : caseVenSubList){
                caseVenSubId.add(casVenSub.Id);
            }*/
            
            Test.startTest();
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', cas.Id);
            ApexPages.currentPage().getParameters().put('accountId', vendorSubsAcct.Id);
            ApexPages.currentPage().getParameters().put('contactId', con.Id);
            ApexPages.currentPage().getParameters().put('index', '2');
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintMagazineExtensionEdit compMagextn = new ComplaintMagazineExtensionEdit (stdCtrlr);
            
            //compMagextn.cas.AccountId = vendorSubsAcct.Id;
            compMagextn.cas.Origin = 'Phone';
            compMagextn.cas.Priority = 'Medium';
            compMagextn.cas.Date_Replaced__c = system.today();
            compMagextn.cas.Status = 'New';
            
            
            compMagextn.save();
            compMagextn.addRow();            
            compMagextn.cancel();
            //using removeRow() method has some error in getting the parameter of the ApexPages.currentpages.....
            compMagextn.removeRow();
            compMagextn.addRow();
            compMagextn.save();
            compMagextn.fetchAccountDetails();
            
            //Added this for the else in fetchAccountDetails. I don't know if this is the right method to do this.
            //Thayne Jarrett Recato Dy
            compMagextn.cas.AccountId = vendorNotSubsAcct.id;
            compMagextn.fetchAccountDetails();            
            compMagextn.addRow();  
            //compMagextn.removeRow();
            compMagextn.cancel();
            
            compMagextn.cas.id = null;   
            compMagextn.cancel();
            compMagextn.fetchAccountDetails();
            //compMagextn.checkPlatformType();
            
            Test.stopTest();
        }//end runuseras
        }catch(Zuora.zRemoteException e) {
          }  
                  
    
  }
  
  static testMethod void testFetchAccountDetails2(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        //Create a new user with Standard User Profile
        User user5 = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(user5) {
            
            Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            vendorSubsAcct.NRIC__c = 'T1234567R';
            database.insert(vendorSubsAcct);
            
            Account vendorNotSubsAcct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            vendorNotSubsAcct.NRIC__c = 'T7654321R';
            database.insert(vendorNotSubsAcct);
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            database.insert(add);
            
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];  
            billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
            billingAcc.Billing_Type__c = 'Full Prepaid';
            database.insert(billingAcc);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = vendorSubsAcct.Id;
            con.Address__c = add.Id;
            //START CCB.002 Modified by: Francis Benzon
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            database.insert(con);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = vendorSubsAcct.Id; 
            order.Recipient_Contact__c = con.Id;
            order.Billing_Account__c = billingAcc.Id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Informed_Customer__c = True;
            database.insert(order);
            
            RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.IsEscalated = true;
            cas.Order__c = order.Id;
            cas.AccountId = vendorSubsAcct.Id;
            cas.ContactId = con.Id;
            cas.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1].id;//'012N00000008kI8IAI';
            database.insert(cas);  
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0]; 
            zProduct.ProductPlatform__c = 'Print';
            zProduct.ProductSubType__c = 'Newspaper';
            zProduct.ProductCode__c = 'STSU';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.SubscriptionFrequency__c = '2';
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            insert prdRatePlan;
            
            List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
            prodfam[0].Product_Family_Name__c = 'TestNAme';
            insert prodfam;
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            packageList[0].Package_Code__c = 'packsample';
            packageList[0].Subscription_Type__c = 'Termed';
            packageList[0].Package_Sub_Type__c = 'Single';
            packageList[0].Subscription_Period__c = '12';
            packageList[0].Billing_Type__c = 'Full Prepaid';
            insert packageList;
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
            for(Zuora__Subscription__c subRecs : subList){
                subRecs.Zuora__CustomerAccount__c = billingAcc.Id;
                subRecs.Zuora__Account__c = vendorSubsAcct.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Term_Length__c = 2;
                subRecs.Zuora__SubscriptionStartDate__c = date.today().addMonths(1).toStartofMonth().addDays(-1);
                //subRecs.Zuora__SubscriptionStartDate__c = subDate;
                subRecs.Zuora__SubscriptionEndDate__c = null;
                //subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(60);
                //subRecs.Zuora__SubscriptionEndDate__c = subDate.addMonths(integer.valueOf(subRecs.Term_Length__c)).addDays(-1);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                subRecs.Number_of_Copies__c = 100;
                subRecs.Main_Package_1__c = packageList[0].id; //fritz
            }
            insert subList;
            
            
            
            //System.assertNotEquals(NULL, cas);
            
            Test.startTest();
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', cas.Id);
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            ApexPages.currentPage().getParameters().put('index', '2');
            ApexPages.currentPage().getParameters().put('accountId', vendorSubsAcct.Id);
            ApexPages.currentPage().getParameters().put('indexValue','1');
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            
            ComplaintMagazineExtensionEdit compMagextn = new ComplaintMagazineExtensionEdit (stdCtrlr);
            
            //compMagextn.cas.AccountId = vendorSubsAcct.Id;
            //compMagextn.cas.Origin = 'Phone';
            //compMagextn.cas.Priority = 'Medium';
           // compMagextn.cas.Date_Replaced__c = system.today();
            //compMagextn.cas.Status = 'New';
            
            
            compMagextn.save();
            compMagextn.addRow();            
            compMagextn.cancel();
            //using removeRow() method has some error in getting the parameter of the ApexPages.currentpages.....
            compMagextn.removeRow();
            compMagextn.addRow();
            compMagextn.save();
            compMagextn.fetchAccountDetails();
            
            //Added this for the else in fetchAccountDetails. I don't know if this is the right method to do this.
            //Thayne Jarrett Recato Dy
            //compMagextn.cas.AccountId = vendorNotSubsAcct.id;
            compMagextn.fetchAccountDetails();            
            compMagextn.addRow();  
            compMagextn.removeRow();
            compMagextn.cancel();
            //compMagextn.cas.id = null;   
            //compMagextn.cancel();
            compMagextn.fetchAccountDetails();
            try{
                compMagextn.checkPlatformType();
            }
            catch(exception e)
            {
                system.debug(':::ERROR ' + e);
            }
            compMagextn.returnChecker(2);
            
            Test.stopTest();
        }//end runuseras
        }catch(Zuora.zRemoteException e) {
          }  
                  
    
  }
  
  static testMethod void testFetchAccountDetails3(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        //Create a new user with Standard User Profile
        User user5 = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(user5) {
            
            Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            vendorSubsAcct .NRIC__c = 'T1234567R';
            database.insert(vendorSubsAcct);
            
            Account vendorNotSubsAcct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            vendorNotSubsAcct .NRIC__c = 'T7654321R';
            database.insert(vendorNotSubsAcct);
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            database.insert(add);
            
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];  
            billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
            billingAcc.Billing_Type__c = 'Full Prepaid';
            database.insert(billingAcc);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = vendorSubsAcct.Id;
            con.Address__c = add.Id;
            //START CCB.002 Modified by: Francis Benzon
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            database.insert(con);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = vendorSubsAcct.Id; 
            order.Recipient_Contact__c = con.Id;
            order.Billing_Account__c = billingAcc.Id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Informed_Customer__c = True;
            database.insert(order);
            
            RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.IsEscalated = true;
            cas.Order__c = order.Id;
            cas.AccountId = vendorSubsAcct.Id;
            cas.ContactId = con.Id;
            cas.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1].Id;//'012N00000008kI8IAI';
            database.insert(cas);
            
            //System.assertNotEquals(NULL, cas);
            
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__CustomerAccount__c = billingAcc.Id;
                subRecs.Zuora__Account__c = vendorSubsAcct.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Term_Length__c = 2;
                subRecs.Zuora__SubscriptionStartDate__c = date.today().addMonths(1).toStartofMonth().addDays(-1);
                //subRecs.Zuora__SubscriptionStartDate__c = subDate;
                subRecs.Zuora__SubscriptionEndDate__c = null;
                //subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(60);
                //subRecs.Zuora__SubscriptionEndDate__c = subDate.addMonths(integer.valueOf(subRecs.Term_Length__c)).addDays(-1);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.id;
                subRecs.Number_of_Copies__c = 100;
            insert subRecs;

            Case_Subscription__c casSub = TestDataFactory.createCaseSubscription(1)[0];
                casSub.Account__c = vendorSubsAcct.Id;
                casSub.Address__c = add.Id;
                casSub.Case__c = cas.Id;
                casSub.Subscription__c = subRecs.Id;
            insert casSub;
            
            //List<Package_Item__c> packItemList = TestDataFactory.createPackageItem(1, 'Bundle Product');
            
            Test.startTest();
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', cas.Id);
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            ApexPages.currentPage().getParameters().put('accountId', vendorSubsAcct.Id);
            ApexPages.currentPage().getParameters().put('index', '2');
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintMagazineExtensionEdit compMagextn = new ComplaintMagazineExtensionEdit (stdCtrlr);
            
            //compMagextn.cas.AccountId = vendorSubsAcct.Id;
            //compMagextn.cas.Origin = 'Phone';
            //compMagextn.cas.Priority = 'Medium';
            //compMagextn.cas.Date_Replaced__c = system.today();
            //compMagextn.cas.Status = 'New';
            //compMagextn.isDirect = true;
            compMagextn.cas.id = null;
            compMagextn.save();
            compMagextn.addRow();            
            compMagextn.cancel();
            //using removeRow() method has some error in getting the parameter of the ApexPages.currentpages.....
            compMagextn.removeRow();
            compMagextn.addRow();
            compMagextn.save();
            compMagextn.fetchAccountDetails();
            
            
            //Added this for the else in fetchAccountDetails. I don't know if this is the right method to do this.
            //Thayne Jarrett Recato Dy
            //compMagextn.cas.AccountId = vendorNotSubsAcct.id;
            //compMagextn.fetchAccountDetails();            
            //compMagextn.addRow();  
            //compMagextn.removeRow();
            //compMagextn.cancel();
            //compMagextn.fetchAccountDetails();
            
            Test.stopTest();
        }//end runuseras
        }catch(Zuora.zRemoteException e) {
          }  
                 
  }
  
  static testMethod void testFetchAccountDetails3B(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        //Create a new user with Standard User Profile
        User user5 = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(user5) {
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '123';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            insert postal;
            
            Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            vendorSubsAcct .NRIC__c = 'T1234567R';
            database.insert(vendorSubsAcct);
            
            Account vendorNotSubsAcct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            vendorNotSubsAcct .NRIC__c = 'T7654321R';
            database.insert(vendorNotSubsAcct);
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Postal_Code__c = postal.Id;
            database.insert(add);
            
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];  
            billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
            billingAcc.Billing_Type__c = 'Full Prepaid';
            database.insert(billingAcc);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = vendorSubsAcct.Id;
            con.Address__c = add.Id;
            //START CCB.002 Modified by: Francis Benzon
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            database.insert(con);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = vendorSubsAcct.Id; 
            order.Recipient_Contact__c = con.Id;
            order.Billing_Account__c = billingAcc.Id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Informed_Customer__c = True;
            database.insert(order);
            
            RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.IsEscalated = true;
            cas.Order__c = order.Id;
            cas.AccountId = vendorSubsAcct.Id;
            cas.ContactId = con.Id;
            cas.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1].Id;//'012N00000008kI8IAI';
            database.insert(cas);
            
            //System.assertNotEquals(NULL, cas);
            
            List<Subscription_Vendor__c> subVenList = TestDataFactory.createSubscriptionVendor(1);
            for(Subscription_Vendor__c subVen : subVenList){
                subVen.Account__c = vendorSubsAcct.Id;
                subVen.Recipient__c = con.Id;
                subVen.Order_Number__c = order.Id;
            }
            insert subVenList;
            
            List<Case_Vendor_Subscription__c> caseVenSubList = TestDataFactory.createCaseVendorSub(1);
            for(Case_Vendor_Subscription__c caseVenSub : caseVenSubList){
                caseVenSub.Account__c = vendorSubsAcct.Id;
                caseVenSub.Address__c = add.Id;
                caseVenSub.Case__c = cas.Id;
                caseVenSub.Subscription_Vendor__c = subVenList[0].Id;
            }
            insert caseVenSubList;
            
            Test.startTest();
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', cas.Id);
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            ApexPages.currentPage().getParameters().put('accountId', vendorSubsAcct.Id);
            ApexPages.currentPage().getParameters().put('index', '2');
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintMagazineExtensionEdit compMagextn = new ComplaintMagazineExtensionEdit (stdCtrlr);
            
            //compMagextn.cas.AccountId = vendorSubsAcct.Id;
            //compMagextn.cas.Origin = 'Phone';
            //compMagextn.cas.Priority = 'Medium';
            //compMagextn.cas.Date_Replaced__c = system.today();
            //compMagextn.cas.Status = 'New';
            //compMagextn.isDirect = true;
            compMagextn.cas.id = null;
            compMagextn.save();
            compMagextn.addRow();            
            compMagextn.cancel();
            //using removeRow() method has some error in getting the parameter of the ApexPages.currentpages.....
            compMagextn.removeRow();
            compMagextn.addRow();
            compMagextn.save();
            compMagextn.fetchAccountDetails();
            
            
            //Added this for the else in fetchAccountDetails. I don't know if this is the right method to do this.
            //Thayne Jarrett Recato Dy
            //compMagextn.cas.AccountId = vendorNotSubsAcct.id;
            //compMagextn.fetchAccountDetails();            
            //compMagextn.addRow();  
            //compMagextn.removeRow();
            //compMagextn.cancel();
            //compMagextn.fetchAccountDetails();
            
            Test.stopTest();
        }//end runuseras
        }catch(Zuora.zRemoteException e) {
          }  
                 
  }
  
  static testMethod void testFetchAccountDetails4(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        //Create a new user with Standard User Profile
        User user5 = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(user5) {
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '123';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            insert postal;
        
            Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            vendorSubsAcct .NRIC__c = 'T1234567R';
            database.insert(vendorSubsAcct);
            
            Account vendorNotSubsAcct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            vendorNotSubsAcct .NRIC__c = 'T7654321R';
            database.insert(vendorNotSubsAcct);
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Postal_Code__c = postal.Id;
            database.insert(add);
            
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];  
            billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
            billingAcc.Billing_Type__c = 'Full Prepaid';
            database.insert(billingAcc);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = vendorSubsAcct.Id;
            con.Address__c = add.Id;
            //START CCB.002 Modified by: Francis Benzon
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            database.insert(con);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = vendorSubsAcct.Id; 
            order.Recipient_Contact__c = con.Id;
            order.Billing_Account__c = billingAcc.Id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Informed_Customer__c = True;
            database.insert(order);
            
            RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.IsEscalated = true;
            cas.Order__c = order.Id;
            cas.AccountId = vendorSubsAcct.Id;
            cas.ContactId = con.Id;
            cas.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1].Id;//'012N00000008kI8IAI';
            database.insert(cas);
            
            List<Subscription_Vendor__c> subVenList = TestDataFactory.createSubscriptionVendor(1);
            for(Subscription_Vendor__c subVen : subVenList){
                subVen.Account__c = vendorSubsAcct.Id;
                subVen.Recipient__c = con.Id;
                subVen.Order_Number__c = order.Id;
            }
            insert subVenList;
            
            List<Case_Vendor_Subscription__c> caseVenSubList = TestDataFactory.createCaseVendorSub(1);
            for(Case_Vendor_Subscription__c caseVenSub : caseVenSubList){
                caseVenSub.Account__c = vendorSubsAcct.Id;
                caseVenSub.Address__c = add.Id;
                caseVenSub.Case__c = cas.Id;
                caseVenSub.Subscription_Vendor__c = subVenList[0].Id;
            }
            insert caseVenSubList;

            Test.startTest();
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', cas.Id);
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            ApexPages.currentPage().getParameters().put('index', '2');
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintMagazineExtensionEdit compMagextn = new ComplaintMagazineExtensionEdit (stdCtrlr);
                compMagextn.fetchAccountDetails();
                compMagextn.returnChecker(1);
                compMagextn.isDirect = TRUE;
            
            Test.stopTest();
        }//end runuseras
        }catch(Zuora.zRemoteException e) {
          }  
                 
  }
  
  static testMethod void testFetchAccountDetails4B(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        //Create a new user with Standard User Profile
        User user5 = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(user5) {
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '123';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            insert postal;
        
            Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            vendorSubsAcct .NRIC__c = 'T1234567R';
            database.insert(vendorSubsAcct);
            
            Account vendorNotSubsAcct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            vendorNotSubsAcct .NRIC__c = 'T7654321R';
            database.insert(vendorNotSubsAcct);
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Postal_Code__c = postal.Id;
            database.insert(add);
            
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];  
            billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
            billingAcc.Billing_Type__c = 'Full Prepaid';
            database.insert(billingAcc);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = vendorSubsAcct.Id;
            con.Address__c = add.Id;
            //START CCB.002 Modified by: Francis Benzon
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            database.insert(con);
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = vendorSubsAcct.Id; 
            order.Recipient_Contact__c = con.Id;
            order.Billing_Account__c = billingAcc.Id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Informed_Customer__c = True;
            database.insert(order);
            
            RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.IsEscalated = true;
            cas.Order__c = order.Id;
            cas.AccountId = vendorSubsAcct.Id;
            cas.ContactId = con.Id;
            cas.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1].Id;//'012N00000008kI8IAI';
            database.insert(cas);
            
            Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                subRecs.Zuora__CustomerAccount__c = billingAcc.Id;
                subRecs.Zuora__Account__c = vendorSubsAcct.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Term_Length__c = 2;
                subRecs.Zuora__SubscriptionStartDate__c = date.today().addMonths(1).toStartofMonth().addDays(-1);
                //subRecs.Zuora__SubscriptionStartDate__c = subDate;
                subRecs.Zuora__SubscriptionEndDate__c = null;
                //subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(60);
                //subRecs.Zuora__SubscriptionEndDate__c = subDate.addMonths(integer.valueOf(subRecs.Term_Length__c)).addDays(-1);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.id;
                subRecs.Number_of_Copies__c = 100;
            insert subRecs;

            Case_Subscription__c casSub = TestDataFactory.createCaseSubscription(1)[0];
                casSub.Account__c = vendorSubsAcct.Id;
                casSub.Address__c = add.Id;
                casSub.Case__c = cas.Id;
                casSub.Subscription__c = subRecs.Id;
            insert casSub;

            Test.startTest();
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', cas.Id);
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            ApexPages.currentPage().getParameters().put('index', '2');
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintMagazineExtensionEdit compMagextn = new ComplaintMagazineExtensionEdit (stdCtrlr);
                compMagextn.fetchAccountDetails();
                compMagextn.returnChecker(1);
                compMagextn.isDirect = TRUE;
            
            ComplaintMagazineExtensionEdit.WrapCaseSubscription wrapper = new ComplaintMagazineExtensionEdit.WrapCaseSubscription(casSub);
            List<ComplaintMagazineExtensionEdit.WrapCaseSubscription> wrapperList = new List<ComplaintMagazineExtensionEdit.WrapCaseSubscription>();
            wrapperList.add(wrapper);
                compMagextn.wrapCaseSubList = wrapperList;
            
            Test.stopTest();
        }//end runuseras
        }catch(Zuora.zRemoteException e) {
          }  
                 
  }

  static testMethod void testFetchAccountDetails5(){
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        //Create a new user with Standard User Profile
        User user4 = new User(
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
        System.runAs(user4) {
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '123';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            insert postal;
            
            Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            vendorSubsAcct .NRIC__c = 'T1234567R';
            database.insert(vendorSubsAcct);
            
            Account vendorNotSubsAcct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            vendorNotSubsAcct .NRIC__c = 'T7654321R';
            database.insert(vendorNotSubsAcct);
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Postal_Code__c = postal.Id;
            database.insert(add);
            
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];  
            billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
            billingAcc.Billing_Type__c = 'Full Prepaid';
            database.insert(billingAcc);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = vendorSubsAcct.Id;
            con.Address__c = add.Id;
            //START CCB.002 Modified by: Francis Benzon
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            database.insert(con);
            
            //fritz
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0]; 
            zProduct.ProductPlatform__c = 'Print';
            zProduct.ProductSubType__c = 'Newspaper';
            zProduct.ProductCode__c = 'STSU';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.SubscriptionFrequency__c = '2';
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            insert prdRatePlan;
            
            List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
            prodfam[0].Product_Family_Name__c = 'TestNAme';
            insert prodfam;
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            packageList[0].Package_Code__c = 'packsample';
            packageList[0].Subscription_Type__c = 'Termed';
            packageList[0].Package_Sub_Type__c = 'Single';
            packageList[0].Subscription_Period__c = '12';
            packageList[0].Billing_Type__c = 'Full Prepaid';
            insert packageList;
            
            Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            pItem.Package__c = packageList[0].Id;
            pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            pItem.Duration_in_months__c = '1';
            pItem.Effective_Start_Month__c = '1';
            pItem.Product_Family__c = prodfam[0].id;
            insert pItem;
            //fritz
                        
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = vendorSubsAcct.Id; 
            order.Recipient_Contact__c = con.Id;
            order.Billing_Account__c = billingAcc.Id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Informed_Customer__c = True;
            database.insert(order);
            
            RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1][0];
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.IsEscalated = true;
            cas.Order__c = order.Id;
            cas.AccountId = vendorSubsAcct.Id;
            cas.ContactId = con.Id;
            cas.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Change_of_Credit_Card' LIMIT 1].id;//'012N00000008kI8IAI';
            database.insert(cas);       
            
            System.assertNotEquals(NULL, cas);
            
            List<Zuora__Subscription__c> subList = TestDataFactory.createSubscription(2);
            for(Zuora__Subscription__c subRecs : subList){
                subRecs.Zuora__CustomerAccount__c = billingAcc.Id;
                subRecs.Zuora__Account__c = vendorSubsAcct.Id;
                subRecs.Zuora__Zuora_Id__c = '1123';
                subRecs.Term_Length__c = 2;
                subRecs.Zuora__SubscriptionStartDate__c = date.today().addMonths(1).toStartofMonth().addDays(-1);
                //subRecs.Zuora__SubscriptionStartDate__c = subDate;
                subRecs.Zuora__SubscriptionEndDate__c = null;
                //subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(60);
                //subRecs.Zuora__SubscriptionEndDate__c = subDate.addMonths(integer.valueOf(subRecs.Term_Length__c)).addDays(-1);
                subRecs.Subscriber_Contact__c = con.Id;
                subRecs.Recipient_Contact__c = con.Id;
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number__c = order.Id;
                subRecs.Billing_Type__c = 'Full Prepaid';
                subRecs.Subscription_Type_1__c = 'Publication';
                subRecs.Subscription_Type__c = 'Publication';
                subRecs.Zuora__Status__c = 'Active';
                subRecs.Order_Number_1__c = order.id;
                subRecs.Number_of_Copies__c = 100;
                subRecs.Main_Package_1__c = packageList[0].id; //fritz
            }
            insert subList;
            
            List<Case_Subscription__c> casSubList = TestDataFactory.createCaseSubscription(2);
                for(Case_Subscription__c casSubRec : casSubList){
                    casSubRec.Account__c = vendorSubsAcct.Id;
                    casSubRec.Address__c = add.Id;
                    casSubRec.Case__c = cas.Id;
                    casSubRec.Subscription__c = subList[0].Id;
                }
            insert casSubList;
            
            List<Subscription_Vendor__c> subVenList = TestDataFactory.createSubscriptionVendor(1);
            for(Subscription_Vendor__c subVen : subVenList){
                subVen.Account__c = vendorSubsAcct.Id;
                subVen.Recipient__c = con.Id;
                subVen.Order_Number__c = order.Id;
            }
            try 
            {
                insert subVenList;
            }
            catch(exception e) {
                system.debug('::ERROR ' + e);
            }
            
            
            List<Case_Vendor_Subscription__c> caseVenSubList = TestDataFactory.createCaseVendorSub(1);
            for(Case_Vendor_Subscription__c caseVenSub : caseVenSubList){
                caseVenSub.Account__c = vendorSubsAcct.Id;
                caseVenSub.Address__c = add.Id;
                caseVenSub.Case__c = cas.Id;
                caseVenSub.Subscription_Vendor__c = subVenList[0].Id;
            }
            try 
            {
                //insert caseVenSubList; //CHA 22April2016
            }
            catch(exception e) {
                system.debug('::ERROR ' + e);
            }
            
            Set<Id> caseSubId = new Set<Id>();
            for(Case_Subscription__c casSubRec : casSubList){
            caseSubId.add(casSubRec.Id);
            }
            
            Test.startTest();
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', cas.Id);
            ApexPages.currentPage().getParameters().put('accountId', vendorSubsAcct.Id);
            ApexPages.currentPage().getParameters().put('contactId', con.Id);
            ApexPages.currentPage().getParameters().put('index', '2');
            ApexPages.currentPage().getParameters().put('indexValue','1');
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintMagazineExtensionEdit compMagextn = new ComplaintMagazineExtensionEdit (stdCtrlr);
            
            //compMagextn.cas.AccountId = vendorSubsAcct.Id;
            compMagextn.cas.Origin = 'Phone';
            compMagextn.cas.Priority = 'Medium';
            compMagextn.cas.Date_Replaced__c = system.today();
            compMagextn.cas.Status = 'New';
            
            
            try{compMagextn.save();}catch(Exception e){system.debug('compMagextn.save' + e);} //CHA
            compMagextn.addRow();            
            compMagextn.cancel();
            //using removeRow() method has some error in getting the parameter of the ApexPages.currentpages.....
            //compMagextn.removeRow(); //fritz
            compMagextn.addRow();
            try{compMagextn.save();}catch(Exception e){system.debug('compMagextn.save' + e);} //CHA
            compMagextn.fetchAccountDetails();
            
            //Added this for the else in fetchAccountDetails. I don't know if this is the right method to do this.
            //Thayne Jarrett Recato Dy
            compMagextn.cas.AccountId = vendorNotSubsAcct.id;
            compMagextn.fetchAccountDetails();            
            compMagextn.addRow();  
            compMagextn.removeRow();
            compMagextn.cancel();
            
            compMagextn.cas.id = null;   
            compMagextn.cancel();
            compMagextn.fetchAccountDetails();
            try
            {
                compMagextn.checkPlatformType();
            
            }
            catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
            Test.stopTest();
        }//end runuseras
        }catch(Zuora.zRemoteException e) {
          }  
                  
    
  }
       
}// end of ComplaintMagazineExtensionEditTest