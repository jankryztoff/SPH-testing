@isTest (seeAllData= True)
public class ComplaintNewspaperControllerMergeTest {
    
    
    ///static Account acc;    
    static testMethod void testSingleVendorSub(){
        
        //Create a new user with Standard User Profile
        
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [SELECT id FROM Profile WHERE NAME = 'System Administrator' Limit 1].Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
       //System.assertEquals('', String.valueOf(u));
        
        //The test will run as the user created.
        System.runAs(u) {
            //create a new case record
            
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            
            insert new List<sObject>{postal,acc};
                
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Address__c = addressRec.Id;
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;
            con[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
            insert con; 
            
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';            
            
            insert pkg;
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            System.debug('DEBUG con.Id' + con[0].Id);
            order.Informed_Customer__c = True;
            insert order;   
            
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Start_Date__c = date.today()+1;
            oli.Main_Package_ID__c = pkg[0].Id;
            insert oli;
            System.debug('@@@@@@'+ 'packageid = ' + pkg[0].Id);
            
            List<Subscription_Vendor__c> subVen = TestDataFactory.createSubscriptionVendor(1);
            insert subVen;  
            System.debug('@@@@@@'+ 'subscripvendor = ' + subVen[0].Id);
            
            
            Case testCase = new Case();
            testCase.AccountId = acc.id;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Date_Replaced__c = system.today();
            testCase.Status = 'New';
            testCase.contactId = con[0].Id;
            
            insert testCase;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; 
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            Subs[0].Zuora__Account__c = acc.id;
            Subs[0].Order_Line_Item_Number__c = oli.Id;
            Subs[0].Order_Number__c = order.Id;
            Subs[0].Subscriber_Contact__c = con[0].Id;
            Subs[0].Recipient_Contact__c = con[0].Id;
            Subs[0].Main_Package_1__c = pkg[0].id;
            Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
            Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
            Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Subs[0].Urgent__c = 'false';
            Subs[0].Vendor_Conversion__c = 'false';
            Subs[0].Charity__c = 'false';
            Subs[0].Zuora__CustomerAccount__c = billAcc.Id;
            Subs[0].Zuora__SubscriptionStartDate__c = system.today()-3;
            Subs[0].Zuora__SubscriptionEndDate__c = system.today()-3;
            
            insert Subs;
            
            
            System.debug('@@@@@@'+ 'testcase = ' + testcase.Id);
            Case_Vendor_Subscription__c cVenSub = new Case_Vendor_Subscription__c();
            cVenSub.Subscription_Vendor__c = subVen[0].id;
            cVenSub.Complaint_From__c = system.today();
            cVenSub.Complaint_To__c = system.today();
            cVenSub.Case__c = testCase.id;
            insert cVenSub;          
            
            Case_Subscription__c cSub = new Case_Subscription__c();
            cSub.Account__c = acc.id;
            cSub.Subscription__c = Subs[0].id;
            cSub.Address__c = addressRec.Id;
            cSub.Complaint_From__c = system.today();
            cSub.Complaint_To__c = system.today();
            cSub.Case__c = testCase.id;
            insert cSub;   
            
            System.debug('@@@@@@'+ 'casevendor = ' + cVenSub.Id);                                
            
            Test.startTest();
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintNewspaperPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('Id', testCase.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            compNewsCont.goodwillCopiesSelected = 'TEST';
            compNewsCont.subSelected4 = 'test';
            compNewsCont.subSelected3 = 'test';
            compNewsCont.subSelected5 = 'test';
            compNewsCont.objcase.AccountId = acc.Id;
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.objcase.Contactid = con[0].id;
            
            ComplaintNewspaperController.CaseSubWrapper csw = new ComplaintNewspaperController.CaseSubWrapper(cSub);
            csw.caseVendorSubscription= cVenSub;
            List<ComplaintNewspaperController.CaseSubWrapper> sampleList = new List<ComplaintNewspaperController.CaseSubWrapper>();
            sampleList.add(csw);
            system.debug('jinono' + sampleList);
            
            compNewsCont.CSubWrapperList = sampleList;
            compNewsCont.save();
            compNewsCont.isDirect = true;
            compNewsCont.save();
            compNewsCont.addRow();
            compNewsCont.cancel();
            //compMagextn.removingRow();
            
            Test.stopTest();
            
        }           
    }
    
    
    
    
    
    ///static Account acc;
    /* */    
    static testMethod void testSingleDirectSub(){
        
        //Create a new user with Standard User Profile
        
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [SELECT id FROM Profile WHERE NAME = 'System Administrator' Limit 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
      //System.assertEquals('', String.valueOf(u));
        
        //The test will run as the user created.
        System.runAs(u) {
            
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';             
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc, pkg[0]};
                
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; 
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Address__c = addressRec.Id;
            //START CCB.002 Modified by: Francis Benzon
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con[0].Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;          
            insert con;            
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            System.debug('DEBUG con.Id' + con[0].Id);
            order.Informed_Customer__c = True;
            insert order;   
            
            //create case
            Case cas = new Case();
            cas.AccountId = acc.id;
            cas.Order__c = order.Id;
            cas.Origin = 'Phone';
            cas.Priority = 'Medium';
            cas.Date_Replaced__c = system.today();
            cas.Status = 'New';
            insert cas;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            //create order line item
            //Order_Line_Item_Vendor__c oli = TestDataFactory.createOrderLineItemVendor(1)[0]; *remove by chan
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Main_Package_ID__c = pack.Id;
            oli.Start_Date__c = date.today()+1;
            insert oli;
            
            
            List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Order_Line_Item_Number__c = oli.Id;
            zsubs[0].Order_Line_Item_Number_1__c = oli.Id;
            zSubs[0].Order_Number__c = order.Id;
            zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
            zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
            zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSubs[0].Urgent__c = 'false';
            zSubs[0].Vendor_Conversion__c = 'false';
            zSubs[0].Charity__c = 'false';
            zSubs[0].Acquisition_Type__c = 'TEST';            
            zSubs[0].Legacy_Create_Date__c = String.valueof(system.today());
            zSubs[0].Legacy_Create_By__c = 'abcde';
            zSubs[0].Legacy_Update_Date__c = String.valueof(system.today());
            zSubs[0].Legacy_Update_By__c = 'abcde';
            zSubs[0].Legacy_Subscription_ID__c ='abcde'; 
            zSubs[0].Zuora__CustomerAccount__c = billAcc.Id;
            insert zSubs;                         
            
            Case testCase = new Case();
            testCase.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            testCase.Order__c = order.Id;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Date_Replaced__c = system.today();
            testCase.Status = 'New';
            testCase.AccountId = acc.Id;
            testCase.Account__c = acc.id;
            insert testCase;
            
            List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            Subs[0].Zuora__Account__c = acc.id;
            Subs[0].Order_Line_Item_Number__c = oli.Id;
            Subs[0].Order_Number__c = order.Id;
            Subs[0].Subscriber_Contact__c = con[0].Id;
            Subs[0].Recipient_Contact__c = con[0].Id;
            Subs[0].Main_Package_1__c = pkg[0].id;
            Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
            Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
            Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Subs[0].Urgent__c = 'false';
            Subs[0].Vendor_Conversion__c = 'false';
            Subs[0].Charity__c = 'false';
            Subs[0].Legacy_Create_Date__c = String.valueof(system.today());
            Subs[0].Legacy_Create_By__c = 'abcde';
            Subs[0].Legacy_Update_Date__c = String.valueof(system.today());
            Subs[0].Legacy_Update_By__c = 'abcde';
            Subs[0].Legacy_Subscription_ID__c ='abcde'; 
            Subs[0].Zuora__CustomerAccount__c = billAcc.Id;
            Test.startTest();
            insert Subs;
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = zSubs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c= 'RATE_PLAN_NAME';
            zSubProdCharge[0].Zuora__Account__c = acc.id;
            zSubProdCharge[0].Zuora__UOM__c = 'Goodwill';
            insert zSubProdCharge;  
            
            Case_Subscription__c cSub = new Case_Subscription__c();
            cSub.Account__c = acc.id;
            cSub.Address__c = addressRec.Id;
            cSub.Subscription__c = Subs[0].id;
            cSub.Complaint_From__c = system.today();
            cSub.Complaint_To__c = system.today();
            cSub.Case__c = testCase.id;
            insert cSub;          
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpc.PublicationCode__c = 'PUB1';
            insert prpc;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
            pub.Publication_Code__c = 'PUB1';
            pub.Published_Days__c = 'YYYYNNY';
            pub.Publication_Type__c = 'M';
            insert pub;
            
            //Test.startTest();
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('def_parent_id', testcase.id);
            ApexPages.currentPage().getParameters().put('id', testcase.id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            compNewsCont.goodwillCopiesSelected = 'TEST';
            compNewsCont.subSelected5 = 'test';
            compNewsCont.objcase = testcase;
            compNewsCont.objcase.AccountId = acc.Id;
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.objcase.Contactid = con[0].id;
            compNewsCont.isDirect = true;
            
            //System.assertEquals(null, compNewsCont.CSubWrapperList);
            
            compNewsCont.save();
            compNewsCont.addRow();
            compNewsCont.cancel();
            //compMagextn.removingRow();
            //compNewsCont.removeRows();                                    
            Test.stopTest();    
            
        }           
    }
    static testMethod void testCreateNew(){
        
        //Create a new user with Standard User Profile
        
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [SELECT id FROM Profile WHERE NAME = 'System Administrator' Limit 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
       //System.assertEquals('', String.valueOf(u));
        
        //The test will run as the user created.
        System.runAs(u) {
            //create a new case record
            
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc};
                
                
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Phone = '1234567';
            con[0].Address__c = addressRec.Id;
            //START CCB.002 Modified by: Francis Benzon
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con[0].Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            insert con;
            
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';            
            insert pkg;
            
            List<Subscription_Vendor__c> subVen = TestDataFactory.createSubscriptionVendor(1);
            subVen[0].Recipient__c = con[0].Id;
            insert subVen;  
            
            
            Case testCase = new Case();
            testCase.AccountId = acc.id;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Date_Replaced__c = system.today();
            testCase.Status = 'New';
            
            insert testCase;
            
            Case_Vendor_Subscription__c cVenSub = new Case_Vendor_Subscription__c();
            cVenSub.Subscription_Vendor__c = subVen[0].id;
            cVenSub.Complaint_From__c = system.today();
            cVenSub.Complaint_To__c = system.today();
            cVenSub.Case__c = testCase.id;
            cVenSub.Address__c = addressRec.Id;
            insert cVenSub;          
            
            
            
            Test.startTest();
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            //ApexPages.currentPage().getParameters().put('id', testCase.Id);
            Apexpages.currentpage().getParameters().put('index', '0');
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Case());
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            compNewsCont.objcase.AccountId = acc.Id;
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.isDirect = false;
            compNewsCont.save();
            
            
            compNewsCont.addRow();
            compNewsCont.cancel();
            //compMagextn.removingRow();
            compNewsCont.fetchAccountDetails();
            compNewsCont.removeRows();
            Test.stopTest();
            
        }           
    }
    ///static Account acc;
    /* */    
    static testMethod void testCaseSubs(){
        
        //Create a new user with Standard User Profile
        
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [SELECT id FROM Profile WHERE NAME = 'System Administrator' Limit 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
       //System.assertEquals('', String.valueOf(u));
        
        //The test will run as the user created.
        System.runAs(u) {
            
            Map<Id, List<Zuora__SubscriptionProductCharge__c>> subsIdToSubProductAndChargesMap = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
            Map<Id,Map<String, Double>> sProdChargeUOMToPrice = new Map<Id,Map<String, Double>>();
            Map<Id,Boolean> cSubRecDiscount = new Map<Id,Boolean>();
            
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';             
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc, pkg[0]};
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; 
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
                
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Address__c = addressRec.Id;
            //START CCB.002 Modified by: Francis Benzon
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con[0].Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;          
            insert con;            
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            System.debug('DEBUG con.Id' + con[0].Id);
            order.Informed_Customer__c = True;
            insert order;   
            
            //create case
            Case cas = new Case();
            cas.AccountId = acc.id;
            cas.Order__c = order.Id;
            cas.Origin = 'Phone';
            cas.Priority = 'Medium';
            cas.Date_Replaced__c = system.today();
            cas.Status = 'New';
            insert cas;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            //create order line item
            //Order_Line_Item_Vendor__c oli = TestDataFactory.createOrderLineItemVendor(1)[0]; *remove by Chan
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Start_Date__c = date.today()+1;
            oli.Main_Package_ID__c = pack.Id;
            insert oli;
            
            List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Order_Line_Item_Number__c = oli.Id;
            zsubs[0].Order_Line_Item_Number_1__c = oli.Id;
            zSubs[0].Order_Number__c = order.Id;
            zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
            zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
            zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSubs[0].Urgent__c = 'false';
            zSubs[0].Vendor_Conversion__c = 'false';
            zSubs[0].Charity__c = 'false';
            zSubs[0].Acquisition_Type__c = 'TEST';            
            zSubs[0].Legacy_Create_Date__c = String.valueof(system.today());
            zSubs[0].Legacy_Create_By__c = 'abcde';
            zSubs[0].Legacy_Update_Date__c = String.valueof(system.today());
            zSubs[0].Legacy_Update_By__c = 'abcde';
            zSubs[0].Legacy_Subscription_ID__c ='abcde'; 
            zsubs[0].Zuora__CustomerAccount__c = billAcc.Id;
            insert zSubs;                         
            
            Case testCase = new Case();
            testCase.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            testCase.Order__c = order.Id;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Date_Replaced__c = system.today();
            testCase.Status = 'New';
            insert testCase;
            
            List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            Subs[0].Zuora__Account__c = acc.id;
            Subs[0].Order_Line_Item_Number__c = oli.Id;
            Subs[0].Order_Number__c = order.Id;
            Subs[0].Subscriber_Contact__c = con[0].Id;
            Subs[0].Recipient_Contact__c = con[0].Id;
            Subs[0].Main_Package_1__c = pkg[0].id;
            Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
            Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
            Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Subs[0].Urgent__c = 'false';
            Subs[0].Vendor_Conversion__c = 'false';
            Subs[0].Charity__c = 'false';
            Subs[0].Acquisition_Type__c = 'TEST';
            Subs[0].Legacy_Create_Date__c = String.valueof(system.today());
            Subs[0].Legacy_Create_By__c = 'abcde';
            Subs[0].Legacy_Update_Date__c = String.valueof(system.today());
            Subs[0].Legacy_Update_By__c = 'abcde';
            Subs[0].Legacy_Subscription_ID__c ='abcde';
            Subs[0].Zuora__CustomerAccount__c = billAcc.Id; 
            Test.startTest();
            insert Subs;
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000086';
            zSubProdCharge[0].Name = 'Copy Mon';
            zSubProdCharge[0].Zuora__Model__c = 'Per Unit Pricing';
            zSubProdCharge[0].Zuora__Subscription__c = zSubs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c= 'ST PRORATIONS';
            zSubProdCharge[0].Zuora__Price__c = .8;
            zSubProdCharge[0].Zuora__UOM__c = 'Copy Mon';
            
            
            insert zSubProdCharge;  
            
            List <Case_Subscription__c> caseSubList = new List <Case_Subscription__c> ();
            
            //Zuora__SubscriptionProductCharge__c subProdCharge : subProdCharges;
            Case_Subscription__c cSub = new Case_Subscription__c();
            cSub.Account__c = acc.id;
            cSub.Address__c = addressRec.Id;
            cSub.Subscription__c = Subs[0].id;
            cSub.Complaint_From__c = system.today();
            cSub.Complaint_To__c = system.today();
            cSub.Case__c = testCase.id;
            cSub.Complaint_Copies__c = 3;
            caseSubList.add(cSub);
            insert caseSubList;          
            
            cSubRecDiscount.put(cSub.id,true);
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpc.PublicationCode__c = 'PUB1';
            insert prpc;
            
            Map<String, Publication__c> pubCodesToPublicationMap = new Map<String, Publication__c>(); 
            boolean isWeekDayIssue = true;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
            pub.Publication_Code__c = 'PUB1';
            pub.Published_Days__c = 'YYYYYNN';
            pub.Publication_Type__c = 'M';
            pub.Publish_Pattern__c = 'Weekday';
            pub.Product_Family__c = 'Berit' ;
            insert pub;
            
            Publication__c pub1 = TestDataFactory.createPublication(1)[0];                                                     
            pub1.Publication_Code__c = 'PUB1';
            pub1.Published_Days__c = 'YYYYYNN';
            pub1.Publication_Type__c = 'M';
            pub1.Publish_Pattern__c = 'Weekend';
            pub1.Product_Family__c = 'Berit' ;
            insert pub1;
            
            pubCodesToPublicationMap.put(pub.Publication_Code__c, pub);
            double totalPaperFee;
            
            Publication_Price__c PubPriceRec = new Publication_Price__c();
            PubPriceRec.Cover_Price__c = 20;
            PubPriceRec.Day_of_Week__c = 'M';
            PubPriceRec.Publication_Code__c = pub.Publication_Code__c;
            PubPriceRec.Publication__c = pub.Id;
            PubPriceRec.Effective_Date__c = date.today();
            insert PubPriceRec;
            
            Publication_Price__c PubPriceRec1 = new Publication_Price__c();
            PubPriceRec1.Cover_Price__c = 20;
            PubPriceRec1.Day_of_Week__c = 'S';
            PubPriceRec1.Publication_Code__c = pub1.Publication_Code__c;
            PubPriceRec1.Publication__c = pub1.Id;
            PubPriceRec1.Effective_Date__c = date.today();
            insert PubPriceRec1;
            
            //Test.startTest();
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', testCase.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
                        /*compNewsCont.objcase.AccountId = acc.Id;
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.isDirect = TRUE;
            compNewsCont.save();*/
            
            compNewsCont.isDirect = TRUE;
            //compNewsCont.getCoverPrice(pub.Publication_Code__c, 'Monday', pub.Id);
            compNewsCont.objcase.Paper_Fee__c = totalPaperFee;
            compNewsCont.callComputatePaperFee();
            compNewsCont.computePaperFee(caseSubList);
            compNewsCont.computeCreditAmount(caseSubList);
            //compNewsCont.getNonPubDates(npub.Publication_Code__c);
            //compNewsCont.getNonPubdays();
            
            Test.stopTest();
            
        }           
    }
    static testMethod void testremoveRows(){
        
        //Create a new user with Standard User Profile
        
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [SELECT id FROM Profile WHERE NAME = 'System Administrator' Limit 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        //System.assertEquals('', String.valueOf(u));
        
        //The test will run as the user created.
        System.runAs(u) {
            
            //Variables for determining Non Pub Days
            Map<String, Set<Date>> pubCodesToNonPubDatesMap = new Map<String, Set<Date>>();
            Map<Id, Set<Date>> subsIdTopubCodesToNonPubDatesMap = new Map<Id, Set<Date>>();
            
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';             
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc, pkg[0]};
                
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; 
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            
            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Address__c = addressRec.Id;
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;
            con[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
            insert con;            
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            System.debug('DEBUG con.Id' + con[0].Id);
            order.Informed_Customer__c = True;
            insert order;   
            
            //create case
            Case cas = new Case();
            cas.AccountId = acc.id;
            cas.Order__c = order.Id;
            cas.Origin = 'Phone';
            cas.Priority = 'Medium';
            cas.Date_Replaced__c = system.today();
            cas.Status = 'New';
            insert cas;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            //create order line item
            //Order_Line_Item_Vendor__c oli = TestDataFactory.createOrderLineItemVendor(1)[0]; *remove by Chan
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Start_Date__c = date.today()+1;
            oli.Main_Package_ID__c = pack.Id;
            insert oli;
            
            
            List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Order_Line_Item_Number__c = oli.Id;
            zsubs[0].Order_Line_Item_Number_1__c = oli.Id;
            zSubs[0].Order_Number__c = order.Id;
            zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
            zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
            zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSubs[0].Urgent__c = 'false';
            zSubs[0].Vendor_Conversion__c = 'false';
            zSubs[0].Charity__c = 'false';
            zSubs[0].Acquisition_Type__c = 'TEST';
            zSubs[0].Zuora__CustomerAccount__c = billAcc.Id;
            insert zSubs;                         
            
            Case testCase = new Case();
            testCase.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            testCase.Order__c = order.Id;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Date_Replaced__c = system.today();
            testCase.Status = 'New';
            insert testCase;
            
            List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            Subs[0].Zuora__Account__c = acc.id;
            Subs[0].Order_Line_Item_Number__c = oli.Id;
            Subs[0].Order_Number__c = order.Id;
            Subs[0].Subscriber_Contact__c = con[0].Id;
            Subs[0].Recipient_Contact__c = con[0].Id;
            Subs[0].Main_Package_1__c = pkg[0].id;
            Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
            Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
            Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Subs[0].Urgent__c = 'false';
            Subs[0].Vendor_Conversion__c = 'false';
            Subs[0].Charity__c = 'false';
            Subs[0].Zuora__CustomerAccount__c = billAcc.Id;
            Test.startTest();
            insert Subs;
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = zSubs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c= 'RATE_PLAN_NAME';
            insert zSubProdCharge;  
            
            Case_Subscription__c cSub = new Case_Subscription__c();
            cSub.Account__c = acc.id;
            cSub.Address__c = addressRec.Id;
            cSub.Subscription__c = Subs[0].id;
            cSub.Complaint_From__c = system.today();
            cSub.Complaint_To__c = system.today();
            cSub.Case__c = testCase.id;
            insert cSub;          
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            Map<String, Set<String>> ratePlanNameToPubCodesMap = new Map<String, Set<String>>();
            List<zqu__ProductRatePlan__c> subProdToProdRatePlanList = new List<zqu__ProductRatePlan__c>();
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            subProdToProdRatePlanList.add(prdRatePlan);
            insert subProdToProdRatePlanList;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpc.PublicationCode__c = 'PUB1';
            insert prpc;
            
                        /*
            Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
            pub.Publication_Code__c = 'PUB1';
            pub.Published_Days__c = 'YYYYNNY';
            pub.Publication_Type__c = 'M';
            insert pub;*/
            
            Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
            npub.Publication_Code__c = 'PUB1';
            npub.Published_Days__c = 'YYYYNNY';
            npub.Publication_Type__c = 'M';
            npub.Publish_Pattern__c = 'Weekday';
            insert npub;
            
            Publication_Price__c PubPriceRec = new Publication_Price__c();
            PubPriceRec.Cover_Price__c = 20;
            PubPriceRec.Day_of_Week__c = 'T';
            PubPriceRec.Publication_Code__c = npub.Publication_Code__c;
            PubPriceRec.Publication__c = npub.Id;
            PubPriceRec.Effective_Date__c = date.today();
            insert PubPriceRec;            
            
            List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'PUB1';
            nonpub.Publication__c = npub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;
            
            List<Case_Subscription__c> insertCaseSubsList = new List <Case_Subscription__c>();
            
            //Test.startTest();
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', testCase.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            compNewsCont.objcase.AccountId = acc.Id;
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.isDirect = true;
            
            //System.assertEquals(null, compNewsCont.CSubWrapperList);
            
            //compNewsCont.save();
            //compNewsCont.objcase.Paper_Fee__c = totalPaperFee;
            //compNewsCont.removeRows();
            //compNewsCont.getCoverPrice(npub.Publication_Code__c, 'Tuesday', npub.Id);
            compNewsCont.getNonPubDates(npub.Publication_Code__c);
            compNewsCont.getNonPubdays(); 
            
            //try-jess
            compNewsCont.save();
            compNewsCont.computePaperFee(insertCaseSubsList);
            compNewsCont.computeCreditAmount(insertCaseSubsList);
            Test.stopTest();    
            
        }           
    }
    
    
    static testMethod void testWithsubs(){
        
        //Create a new user with Standard User Profile
        
        User u = new User(
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
        
        //System.assertEquals('', String.valueOf(u));
        
        //The test will run as the user created.
        System.runAs(u) {
            
            //Variables for determining Non Pub Days
            Map<String, Set<Date>> pubCodesToNonPubDatesMap = new Map<String, Set<Date>>();
            Map<Id, Set<Date>> subsIdTopubCodesToNonPubDatesMap = new Map<Id, Set<Date>>();
            
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Vendor Subscriber'));
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';             
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc, pkg[0]};
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; 
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Address__c = addressRec.Id;
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;
            con[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
            insert con;            
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            System.debug('DEBUG con.Id' + con[0].Id);
            order.Informed_Customer__c = True;
            insert order;   
            
            //create case
            Case cas = new Case();
            cas.AccountId = acc.id;
            cas.Order__c = order.Id;
            cas.Origin = 'Phone';
            cas.Priority = 'Medium';
            cas.Date_Replaced__c = system.today();
            cas.Status = 'New';
            insert cas;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            //create order line item
            //Order_Line_Item_Vendor__c oli = TestDataFactory.createOrderLineItemVendor(1)[0]; *remove by Chan
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Start_Date__c = date.today()+1;
            oli.Main_Package_ID__c = pack.Id;
            insert oli;
            
            
            List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Order_Line_Item_Number__c = oli.Id;
            zsubs[0].Order_Line_Item_Number_1__c = oli.Id;
            zSubs[0].Order_Number__c = order.Id;
            zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
            zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
            zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSubs[0].Urgent__c = 'false';
            zSubs[0].Vendor_Conversion__c = 'false';
            zSubs[0].Charity__c = 'false';
            zSubs[0].Acquisition_Type__c = 'TEST';
            zSubs[0].Zuora__CustomerAccount__c = billAcc.Id;
            insert zSubs;                         
            
            Case testCase = new Case();
            testCase.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            testCase.Order__c = order.Id;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Date_Replaced__c = system.today();
            testCase.Status = 'New';
            insert testCase;
            
            List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            Subs[0].Zuora__Account__c = acc.id;
            Subs[0].Order_Line_Item_Number__c = oli.Id;
            Subs[0].Order_Number__c = order.Id;
            Subs[0].Subscriber_Contact__c = con[0].Id;
            Subs[0].Recipient_Contact__c = con[0].Id;
            Subs[0].Main_Package_1__c = pkg[0].id;
            Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
            Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
            Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Subs[0].Urgent__c = 'false';
            Subs[0].Vendor_Conversion__c = 'false';
            Subs[0].Charity__c = 'false';
            Subs[0].Zuora__CustomerAccount__c = billAcc.Id;
            Test.startTest();
            insert Subs;
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = zSubs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c= 'RATE_PLAN_NAME';
            zSubProdCharge[0].Zuora__Model__c = ConstantsSLB.getUOM('Discount-Percentage');
            zSubProdCharge[0].Zuora__Price__c = 100;
            insert zSubProdCharge;  
            
            Case_Subscription__c cSub = new Case_Subscription__c();
            cSub.Account__c = acc.id;
            cSub.Address__c = addressRec.Id;
            cSub.Subscription__c = Subs[0].id;
            cSub.Complaint_From__c = system.today();
            cSub.Complaint_To__c = system.today();
            cSub.Case__c = testCase.id;
            insert cSub;   
            
            Case_Subscription__c ncSub = new Case_Subscription__c();
            ncSub.Account__c = acc.id;
            ncSub.Address__c = addressRec.Id;
            ncSub.Subscription__c = zSubs[0].id;
            ncSub.Complaint_From__c = system.today()-2;
            ncSub.Complaint_To__c = system.today()-2;
            ncSub.Complaint_Copies__c = 1;
            ncSub.Replacement_Copies__c = 1;
            ncSub.Case__c = testCase.id;
            insert ncSub; 
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            Map<String, Set<String>> ratePlanNameToPubCodesMap = new Map<String, Set<String>>();
            List<zqu__ProductRatePlan__c> subProdToProdRatePlanList = new List<zqu__ProductRatePlan__c>();
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            subProdToProdRatePlanList.add(prdRatePlan);
            insert subProdToProdRatePlanList;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpc.PublicationCode__c = 'PUB1';
            insert prpc;
            
                        
          //  Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
          //  pub.Publication_Code__c = 'PUB1';
           // pub.Published_Days__c = 'YYYYNNY';
           // pub.Publication_Type__c = 'M';
           // insert pub;
            
            Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
            npub.Publication_Code__c = 'PUB1';
            npub.Published_Days__c = 'YYYYNNY';
            npub.Publication_Type__c = 'M';
            npub.Publish_Pattern__c = 'Weekday';
            npub.Product_Family__c = 'Tamil';
            insert npub;
            
            Publication_Price__c PubPriceRec = new Publication_Price__c();
            PubPriceRec.Cover_Price__c = 20;
            PubPriceRec.Day_of_Week__c = 'S';
            PubPriceRec.Publication_Code__c = npub.Publication_Code__c;
            PubPriceRec.Publication__c = npub.Id;
            PubPriceRec.Effective_Date__c = date.today();
            insert PubPriceRec;            
            
            List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'PUB1';
            nonpub.Publication__c = npub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;
            
            List<Case_Subscription__c> insertCaseSubsList = new List <Case_Subscription__c>([Select Id, Account__c, Address__c, Subscription__c, Complaint_From__c, Complaint_To__c, Complaint_Copies__c, Replacement_Copies__c, Case__c From Case_Subscription__c Where Id = : ncSub.Id]);
            //Test.startTest();
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', testCase.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            compNewsCont.objcase.AccountId = acc.Id;
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.isDirect = true;
            
            //System.assertEquals(null, compNewsCont.CSubWrapperList);
            
            //compNewsCont.save();
            //compNewsCont.objcase.Paper_Fee__c = totalPaperFee;
            //compNewsCont.removeRows();
            //compNewsCont.getCoverPrice(npub.Publication_Code__c, 'Saturday', npub.Id);
            compNewsCont.getNonPubDates(npub.Publication_Code__c);
            compNewsCont.getNonPubdays(); 
            
            //try-jess
            compNewsCont.save();
            //compNewsCont.computePaperFee(insertCaseSubsList);
            //compNewsCont.computeCreditAmount(insertCaseSubsList);
            Test.stopTest();    
            
        }           
    }
 
    static testMethod void testWithNosubs(){
        
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
        
        //System.assertEquals('', String.valueOf(u));
        
        //The test will run as the user created.
        System.runAs(u) {
            
            //Variables for determining Non Pub Days
            Map<String, Set<Date>> pubCodesToNonPubDatesMap = new Map<String, Set<Date>>();
            Map<Id, Set<Date>> subsIdTopubCodesToNonPubDatesMap = new Map<Id, Set<Date>>();
            
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Mailing Agent'));
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';             
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc, pkg[0]};
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; 
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Address__c = addressRec.Id;
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;
            con[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
            insert con;            
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            System.debug('DEBUG con.Id' + con[0].Id);
            order.Informed_Customer__c = True;
            insert order;   
            
            //create case
            Case cas = new Case();
            cas.AccountId = acc.id;
            cas.Order__c = order.Id;
            cas.Origin = 'Phone';
            cas.Priority = 'Medium';
            cas.Date_Replaced__c = system.today();
            cas.Status = 'New';
            insert cas;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            //create order line item
            //Order_Line_Item_Vendor__c oli = TestDataFactory.createOrderLineItemVendor(1)[0]; *remove by Chan
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Start_Date__c = date.today()+1;
            oli.Main_Package_ID__c = pack.Id;
            insert oli;
            
            
            List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Order_Line_Item_Number__c = oli.Id;
            zsubs[0].Order_Line_Item_Number_1__c = oli.Id;
            zSubs[0].Order_Number__c = order.Id;
            zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
            zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
            zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSubs[0].Urgent__c = 'false';
            zSubs[0].Vendor_Conversion__c = 'false';
            zSubs[0].Charity__c = 'false';
            zSubs[0].Acquisition_Type__c = 'TEST';
            zSubs[0].Zuora__CustomerAccount__c = billAcc.Id;
            insert zSubs;                         
            Test.startTest();
            Case testCase = testdatafactory.createcase(1,'Complaint - Newspaper')[0];
            //testCase.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            testCase.Order__c = order.Id;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Date_Replaced__c = system.today();
            testCase.Status = 'New';
            insert testCase;
            
            List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            Subs[0].Zuora__Account__c = acc.id;
            Subs[0].Order_Line_Item_Number__c = oli.Id;
            Subs[0].Order_Number__c = order.Id;
            Subs[0].Subscriber_Contact__c = con[0].Id;
            Subs[0].Recipient_Contact__c = con[0].Id;
            Subs[0].Main_Package_1__c = pkg[0].id;
            Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
            Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
            Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Subs[0].Urgent__c = 'false';
            Subs[0].Vendor_Conversion__c = 'false';
            Subs[0].Charity__c = 'false';
            Subs[0].Zuora__CustomerAccount__c = billAcc.Id;
            
            insert Subs;
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = zSubs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c= 'RATE_PLAN_NAME';
            //zSubProdCharge[0].Zuora__Model__c = ConstantsSLB.getUOM('Discount-Percentage');
            //zSubProdCharge[0].Zuora__Price__c = 100;
            insert zSubProdCharge;  
            
            Case_Subscription__c cSub = new Case_Subscription__c();
            cSub.Account__c = acc.id;
            cSub.Address__c = addressRec.Id;
            cSub.Subscription__c = Subs[0].id;
            cSub.Complaint_From__c = system.today();
            cSub.Complaint_To__c = system.today();
            cSub.Case__c = testCase.id;
            insert cSub;   
            
            Set<Id> cSubIds = new Set<Id>();
            List<Case_Subscription__c> cSList = new List<Case_Subscription__c>();
            
            for(Integer i=0;i<7;i++){
                Case_Subscription__c ncSub = new Case_Subscription__c();
                ncSub.Account__c = acc.id;
                ncSub.Address__c = addressRec.Id;
                ncSub.Subscription__c = zSubs[0].id;
                ncSub.Complaint_From__c = system.today()-i;
                ncSub.Complaint_To__c = system.today()-i;
                ncSub.Complaint_Copies__c = 1;
                ncSub.Case__c = testCase.id;
                cSList.add(ncSub);
            }
            
            insert cSList;
            
            for(Case_Subscription__c csLoop : cSList){
                cSubIds.add(csLoop.Id);
            }
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c='SKU-0000075';
            insert zProduct;
            
            Map<String, Set<String>> ratePlanNameToPubCodesMap = new Map<String, Set<String>>();
            List<zqu__ProductRatePlan__c> subProdToProdRatePlanList = new List<zqu__ProductRatePlan__c>();
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c = 'Proration';
            prdRatePlan.RatePlanSubType__c = 'Standard';
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            subProdToProdRatePlanList.add(prdRatePlan);
            insert subProdToProdRatePlanList;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpc.PublicationCode__c = 'PUB1';
            prpc.zqu__UOM__c = 'Copy Sat';
            insert prpc;
            
                     
        //    Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
         //   pub.Publication_Code__c = 'PUB1';
          //  pub.Published_Days__c = 'YYYYNNY';
          //  pub.Publication_Type__c = 'M';
          //  insert pub;
            
            Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
            npub.Publication_Code__c = 'PUB1';
            npub.Published_Days__c = 'YYYYYYN';
            npub.Publication_Type__c = 'M';
            npub.Publish_Pattern__c = 'Weekend';
            npub.Product_Family__c = 'Tamil';
            insert npub;
            
            Test.stopTest();
            Publication_Price__c PubPriceRec = new Publication_Price__c();
            PubPriceRec.Cover_Price__c = 20;
            PubPriceRec.Day_of_Week__c = 'S';
            PubPriceRec.Publication_Code__c = npub.Publication_Code__c;
            PubPriceRec.Publication__c = npub.Id;
            PubPriceRec.Effective_Date__c = date.today();
            insert PubPriceRec;            
            
            List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'PUB1';
            nonpub.Publication__c = npub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;
            
            
            Case_Vendor_Fee__c caseVenFee = new Case_Vendor_Fee__c ();
            caseVenFee.Case__c = testcase.id;
            database.insert(caseVenFee);
            
            List<Case_Subscription__c> insertCaseSubsList = new List <Case_Subscription__c>([Select Id, Account__c, Address__c, Subscription__c, Complaint_From__c, Complaint_To__c, Complaint_Copies__c, Replacement_Copies__c, Case__c From Case_Subscription__c Where Id IN : cSubIds]);
            system.debug('jinono' + insertCaseSubsList);
            //Test.startTest();
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', testCase.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            compNewsCont.objcase.AccountId = acc.Id;
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.isDirect = true;
            
            //System.assertEquals(null, compNewsCont.CSubWrapperList);
            
            //compNewsCont.save();
            //compNewsCont.objcase.Paper_Fee__c = totalPaperFee;
            //compNewsCont.removeRows();
            //compNewsCont.getCoverPrice(npub.Publication_Code__c, 'Sunday', npub.Id);
            compNewsCont.getNonPubDates(npub.Publication_Code__c);
            compNewsCont.getNonPubdays(); 
            
            //try-jess
            compNewsCont.save();
            //compNewsCont.getGoodwillAmount();
            //compNewsCont.computePaperFee(insertCaseSubsList);
            //compNewsCont.computeCreditAmount(insertCaseSubsList);
        }           
    }
    
     static testMethod void testWithsubs2(){
        
        //Create a new user with Standard User Profile
        
        User u = new User(
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
        
        //System.assertEquals('', String.valueOf(u));
        
        //The test will run as the user created.
        System.runAs(u) {
            
            //Variables for determining Non Pub Days
            Map<String, Set<Date>> pubCodesToNonPubDatesMap = new Map<String, Set<Date>>();
            Map<Id, Set<Date>> subsIdTopubCodesToNonPubDatesMap = new Map<Id, Set<Date>>();
            
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Vendor Subscriber'));
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';             
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc, pkg[0]};
                
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; 
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Address__c = addressRec.Id;
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;
            con[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
            insert con;            
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            System.debug('DEBUG con.Id' + con[0].Id);
            order.Informed_Customer__c = True;
            insert order;   
            
            //create case
            Case cas = new Case();
            cas.AccountId = acc.id;
            cas.Order__c = order.Id;
            cas.Origin = 'Phone';
            cas.Priority = 'Medium';
            cas.Date_Replaced__c = system.today();
            cas.Status = 'New';
            insert cas;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            //create order line item
            //Order_Line_Item_Vendor__c oli = TestDataFactory.createOrderLineItemVendor(1)[0]; *remove by Chan
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Start_Date__c = date.today()+1;
            oli.Main_Package_ID__c = pack.Id;
            insert oli;
            
            
            List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Order_Line_Item_Number__c = oli.Id;
            zsubs[0].Order_Line_Item_Number_1__c = oli.Id;
            zSubs[0].Order_Number__c = order.Id;
            zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
            zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
            zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSubs[0].Urgent__c = 'false';
            zSubs[0].Vendor_Conversion__c = 'false';
            zSubs[0].Charity__c = 'false';
            zSubs[0].Acquisition_Type__c = 'TEST';
            zSubs[0].Zuora__CustomerAccount__c = billAcc.Id;
            insert zSubs;                         
            
            Case testCase = new Case();
            testCase.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            testCase.Order__c = order.Id;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Date_Replaced__c = system.today();
            testCase.Status = 'New';
            insert testCase;
            
            List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            Subs[0].Zuora__Account__c = acc.id;
            Subs[0].Order_Line_Item_Number__c = oli.Id;
            Subs[0].Order_Number__c = order.Id;
            Subs[0].Subscriber_Contact__c = con[0].Id;
            Subs[0].Recipient_Contact__c = con[0].Id;
            Subs[0].Main_Package_1__c = pkg[0].id;
            Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
            Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
            Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Subs[0].Urgent__c = 'false';
            Subs[0].Vendor_Conversion__c = 'false';
            Subs[0].Charity__c = 'false';
            Subs[0].Zuora__CustomerAccount__c = billAcc.Id;
            Subs[0].Zuora__SubscriptionStartDate__c = system.today()-3;
            Subs[0].Zuora__SubscriptionEndDate__c = system.today()-3;
            Test.startTest();
            insert Subs;
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = zSubs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c= 'RATE_PLAN_NAME';
            zSubProdCharge[0].Zuora__Model__c = ConstantsSLB.getUOM('Discount-Percentage');
            zSubProdCharge[0].Zuora__Price__c = 100;
            insert zSubProdCharge;  
            
            Case_Subscription__c cSub = new Case_Subscription__c();
            cSub.Account__c = acc.id;
            cSub.Address__c = addressRec.Id;
            cSub.Subscription__c = Subs[0].id;
            cSub.Complaint_From__c = system.today();
            cSub.Complaint_To__c = system.today();
            cSub.Case__c = testCase.id;
            insert cSub;   
            
            Case_Subscription__c ncSub = new Case_Subscription__c();
            ncSub.Account__c = acc.id;
            ncSub.Address__c = addressRec.Id;
            ncSub.Subscription__c = zSubs[0].id;
            ncSub.Complaint_From__c = system.today()-2;
            ncSub.Complaint_To__c = system.today()-2;
            ncSub.Complaint_Copies__c = 1;
            ncSub.Replacement_Copies__c = 1;
            ncSub.Case__c = testCase.id;
            insert ncSub; 
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            Map<String, Set<String>> ratePlanNameToPubCodesMap = new Map<String, Set<String>>();
            List<zqu__ProductRatePlan__c> subProdToProdRatePlanList = new List<zqu__ProductRatePlan__c>();
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            subProdToProdRatePlanList.add(prdRatePlan);
            insert subProdToProdRatePlanList;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpc.PublicationCode__c = 'PUB1';
            insert prpc;
            
                        
          //  Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
          //  pub.Publication_Code__c = 'PUB1';
           // pub.Published_Days__c = 'YYYYNNY';
           // pub.Publication_Type__c = 'M';
           // insert pub;
            
            Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
            npub.Publication_Code__c = 'PUB1';
            npub.Published_Days__c = 'YYYYNNY';
            npub.Publication_Type__c = 'M';
            npub.Publish_Pattern__c = 'Weekday';
            npub.Product_Family__c = 'Tamil';
            insert npub;
            
            Publication_Price__c PubPriceRec = new Publication_Price__c();
            PubPriceRec.Cover_Price__c = 20;
            PubPriceRec.Day_of_Week__c = 'S';
            PubPriceRec.Publication_Code__c = npub.Publication_Code__c;
            PubPriceRec.Publication__c = npub.Id;
            PubPriceRec.Effective_Date__c = date.today();
            insert PubPriceRec;            
            
            List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'PUB1';
            nonpub.Publication__c = npub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;
            
            List<Case_Subscription__c> insertCaseSubsList = new List <Case_Subscription__c>([Select Id, Account__c, Address__c, Subscription__c, Complaint_From__c, Complaint_To__c, Complaint_Copies__c, Replacement_Copies__c, Case__c From Case_Subscription__c Where Id = : ncSub.Id]);
            //Test.startTest();
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', testCase.Id);
            ApexPages.currentPage().getParameters().put('accountId', testCase.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            compNewsCont.objcase.AccountId = acc.Id;
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.isDirect = true;
            
            //System.assertEquals(null, compNewsCont.CSubWrapperList);
            
            //compNewsCont.save();
            //compNewsCont.objcase.Paper_Fee__c = totalPaperFee;
            //compNewsCont.removeRows();
            //compNewsCont.getCoverPrice(npub.Publication_Code__c, 'Saturday', npub.Id);
            compNewsCont.getNonPubDates(npub.Publication_Code__c);
            compNewsCont.getNonPubdays(); 
            
            //try-jess
            compNewsCont.save();
            //compNewsCont.computePaperFee(insertCaseSubsList);
            //compNewsCont.computeCreditAmount(insertCaseSubsList);
            Test.stopTest();    
            
        }           
    }       
    

     static User testUser(){
        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [SELECT id FROM Profile WHERE NAME = 'System Administrator' Limit 1].Id,//(Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );    
        
        return u;
    }
    
    static Map<string, Id> testData(){
        Map<string, Id> data = new Map<string, Id>();
        /*
        Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '123463195';
        key.Type__c = 'Number';
        database.insert(key);
        
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList); 
    */
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        acc.Vendor_Code__c = '123';
        insert acc;
        data.put('Account', acc.Id);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        insert postal;
        
        data.put('Singpost_Address__c', postal.Id);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        data.put('Address__c', addressRec.Id);
        
        List<Contact> con = TestDataFactory.createContactRecType(1, 'Customer Contact');
        con[0].AccountId = acc.Id;
        con[0].Phone = '1234567';
        con[0].Address__c = addressRec.Id;
        //con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[0].Recipient_Indicator__c = true;
        insert con;
        data.put('Contact', con[0].Id);
            
        List<Package__c> pkg = TestDataFactory.createPackage(1);
        pkg[0].Subscription_Period__c = '15';            
        insert pkg;
        data.put('Package__c', pkg[0].Id);
            
        List<Subscription_Vendor__c> subVen = TestDataFactory.createSubscriptionVendor(1);
        subVen[0].Recipient__c = con[0].Id;
        subVen[0].Vendor__c = null;
        insert subVen;  
        data.put('Subscription_Vendor__c', subVen[0].Id);
            
        Case testCase = new Case();
        testCase.AccountId = acc.id;
        testCase.Origin = 'Phone';
        testCase.Priority = 'Medium';
        testCase.Date_Replaced__c = system.today();
        testCase.Status = 'New';
        testCase.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Complaint - Newspaper' LIMIT 1].Id;
        insert testCase;
        data.put('Case', testCase.Id);
            
        Case_Vendor_Subscription__c cVenSub = new Case_Vendor_Subscription__c();
        cVenSub.Subscription_Vendor__c = subVen[0].id;
        cVenSub.Complaint_From__c = system.today();
        cVenSub.Complaint_To__c = system.today();
        cVenSub.Case__c = testCase.id;
        cVenSub.Address__c = addressRec.Id;
        insert cVenSub;     
        data.put('Case_Vendor_Subscription__c', cVenSub.Id);     
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Recipient_Contact__c = con[0].Id;
        order.Informed_Customer__c = True;
        order.Subscriber_charge__c = 100;
        insert order;   
        data.put('Order__c', order.Id);
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0]; 
        oli.Order__c = order.Id; 
        oli.Main_Package_ID__c = pkg[0].id; 
        data.put('Order_Line_Item__c', oli.Id);
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = acc.id; 
        insert defaultPayment; 
        data.put('Zuora__CustomerAccount__c', defaultPayment.Id);
        
        List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
        Subs[0].Zuora__Account__c = acc.id;
        Subs[0].Order_Line_Item_Number__c = oli.Id;
        Subs[0].Order_Number__c = order.Id;
        Subs[0].Subscriber_Contact__c = con[0].Id;
        Subs[0].Recipient_Contact__c = con[0].Id;
        Subs[0].Main_Package__c = pkg[0].id;
        Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
        Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
        Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        Subs[0].Urgent__c = 'false';
        Subs[0].Vendor_Conversion__c = 'false';
        Subs[0].Charity__c = 'false';
        Subs[0].Legacy_Create_Date__c = String.valueof(system.today());
        Subs[0].Legacy_Create_By__c = 'abcde';
        Subs[0].Legacy_Update_Date__c = String.valueof(system.today());
        Subs[0].Legacy_Update_By__c = 'abcde';
        Subs[0].Legacy_Subscription_ID__c ='abcde'; 
        Subs[0].Zuora__CustomerAccount__c = defaultPayment.Id;
        Subs[0].Sponsor_1__c = true;
        Subs[0].Name = 'Subscription 2';
        Subs[0].Zuora__SubscriptionStartDate__c = null;
        Subs[0].Term_Length__c = 30;
        subs[0].Zuora__SubscriptionEndDate__c = null;
        insert Subs;
        data.put('Zuora__Subscription__c2', Subs[0].Id);
        
        List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
        //List<Zuora__Subscription__c> zSubs = new List<Zuora__Subscription__c>();
        zSubs[0].Zuora__Account__c = acc.id;
        zSubs[0].Order_Line_Item_Number__c = oli.Id;
        zSubs[0].Order_Number__c = order.Id;
        zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
        zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
        zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        zSubs[0].Urgent__c = 'false';
        zSubs[0].Vendor_Conversion__c = 'false';
        zSubs[0].Charity__c = 'false';
        zSubs[0].Acquisition_Type__c = 'TEST';            
        zSubs[0].Legacy_Create_Date__c = String.valueof(system.today());
        zSubs[0].Legacy_Create_By__c = 'abcde';
        zSubs[0].Legacy_Update_Date__c = String.valueof(system.today());
        zSubs[0].Legacy_Update_By__c = 'abcde';
        zSubs[0].Legacy_Subscription_ID__c ='abcde'; 
        zSubs[0].Zuora__CustomerAccount__c = defaultPayment.Id;
        zSubs[0].Sponsor_1__c = true;
        zSubs[0].Name = 'Subscription 1';
        zSubs[0].Main_Package__c = pkg[0].id;
        zSubs[0].Zuora__SubscriptionStartDate__c = null;
        zSubs[0].Term_Length__c = 30;
        zsubs[0].Zuora__SubscriptionEndDate__c = null;
        insert zSubs;        
        data.put('Zuora__Subscription__c', zSubs[0].Id);    
        
        List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
        zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
        zSubProdCharge[0].Zuora__Subscription__c = Subs[0].id;
        zSubProdCharge[0].Zuora__RatePlanName__c= 'RATE_PLAN_NAME';
        zSubProdCharge[0].Zuora__Model__c = 'Discount-Percentage';
        zSubProdCharge[0].Zuora__ProductName__c = 'discount';
        insert zSubProdCharge;  
        data.put('Zuora__SubscriptionProductCharge__c', zSubProdCharge[0].id);
        
        Case_Subscription__c cSub = new Case_Subscription__c();
        cSub.Account__c = acc.id;
        cSub.Address__c = addressRec.Id;
        cSub.Subscription__c = Subs[0].id;
        cSub.Complaint_From__c = system.today()-15;
        cSub.Complaint_To__c = system.today()-10;
        cSub.Case__c = testCase.id;
        cSub.Legacy_Create_Date__c = String.valueof(system.today());
        cSub.Complaint_Copies__c = 3;
        try{insert cSub;}catch(Exception e){System.debug('insert Case Subscription error' + e);} //CHA 22April2016
        data.put('Case_Subscription__c', cSub.Id);              
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'SKU-0000075';
        zProduct.ProductPlatform__c = 'Print';
        insert zProduct;
        data.put('zqu__ZProduct__c', zProduct.Id);
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c = 'Bill Plan'; 
        prdRatePlan.RatePlanSubType__c = 'Standard'; 
        prdRatePlan.Name = 'RATE_PLAN_NAME';
        insert prdRatePlan;
        data.put('zqu__ProductRatePlan__c', prdRatePlan.id);
        
        Product_Family__c productFamily = testDataFactory.createProductFamily(1)[0];       
        database.insert(productFamily);
        data.put('Product_Family__c', productFamily.Id);
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packItem.Package__c = pkg[0].id;
        packItem.Product_Family__c = productFamily.Id;
        packItem.Product_Rate_Plan__c = prdRatePlan.Id;
        Test.startTest();
        database.insert(packItem);
        data.put('Package_Item__c', packItem.Id);
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.PublicationCode__c = 'PUB1';
        
        insert prpc;
        data.put('zqu__ProductRatePlanCharge__c', prpc.Id);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        data.put('Publication__c', pub.Id);
        
        Publication_Price__c PubPriceRec = new Publication_Price__c();
        PubPriceRec.Cover_Price__c = 20;
        PubPriceRec.Day_of_Week__c = 'M';
        PubPriceRec.Publication_Code__c = pub.Publication_Code__c;
        PubPriceRec.Publication__c = pub.Id;
        PubPriceRec.Effective_Date__c = date.today();
        insert PubPriceRec;
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = pub.Id;
        nonPubList.add(nonpub);
        insert nonPubList;
        
        Product_Publication__c proPub = TestDataFactory.createProductPublication(1)[0];
        proPub.ZProduct__c = zProduct.Id;
        proPub.Publication_Code__c = pub.Id;
        database.insert(proPub);
        data.put('Product_Publication__c', proPub.Id);
    
        return data;
        
    } 
    
    static testMethod void testSave3(){
    
    
        //defaultCustomSetting();
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];//new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'));
        acc.Vendor_Code__c = '123';
        acc.Mobile__c = '1234567';
        acc.Email__c = 'sample@a.com';
        database.insert(acc);
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '123';
        database.insert(postal);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        List<Contact> con = TestDataFactory.createContact(1);
        con[0].AccountId = acc.Id;
        con[0].Phone = '1234567';
        con[0].Address__c = addressRec.Id;
        con[0].RecordTypeId = [SELECT Id, Name from RecordType WHERE sObjectType = 'Contact' AND Name = 'Customer Contact'].Id; //ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[0].Recipient_Indicator__c = true;
        database.insert(con);
        
        List<Package__c> pkg = TestDataFactory.createPackage(1);
        pkg[0].Subscription_Period__c = '15';            
        database.insert(pkg);
        
        Case testCase = new Case();
        testCase.AccountId = acc.id;
        testCase.Origin = 'Phone';
        testCase.Priority = 'Medium';
        testCase.Date_Replaced__c = system.today();
        testCase.Status = 'New';
        testCase.RecordTypeId = [SELECT Id from RecordType WHERE sObjectType = 'Case' AND Name = 'Complaint - Newspaper'].Id;//ConstantsSLB.getKeyId('Case_Complaint Newspaper');
        database.insert(testCase);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Recipient_Contact__c = con[0].Id;
        order.Informed_Customer__c = True;
        order.Subscriber_charge__c = 100;
        database.insert(order);   
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0]; 
        oli.Order__c = order.Id; 
        oli.Main_Package_ID__c = pkg[0].id;
        oli.Start_Date__c = date.Today()+1; 
        database.insert(oli);
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = acc.id; 
        insert defaultPayment; 
        
        List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
        Subs[0].Zuora__Account__c = acc.id;
        Subs[0].Order_Line_Item_Number__c = oli.Id;
        Subs[0].Order_Number__c = order.Id;
        Subs[0].Subscriber_Contact__c = con[0].Id;
        Subs[0].Recipient_Contact__c = con[0].Id;
        Subs[0].Main_Package__c = pkg[0].id;
        Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
        Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
        Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
        Subs[0].Urgent__c = 'false';
        Subs[0].Vendor_Conversion__c = 'false';
        Subs[0].Charity__c = 'false';
        Subs[0].Legacy_Create_Date__c = String.valueof(system.today());
        Subs[0].Legacy_Create_By__c = 'abcde';
        Subs[0].Legacy_Update_Date__c = String.valueof(system.today());
        Subs[0].Legacy_Update_By__c = 'abcde';
        Subs[0].Legacy_Subscription_ID__c ='abcde'; 
        Subs[0].Zuora__CustomerAccount__c = defaultPayment.Id;
        Subs[0].Sponsor_1__c = true;
        Subs[0].Name = 'Subscription 2';
        Subs[0].Zuora__SubscriptionStartDate__c = null;
        Subs[0].Term_Length__c = 30;
        subs[0].Zuora__SubscriptionEndDate__c = null;
        database.insert(Subs);
        
        Integer i=0;
        List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(2);
        for(Case_Subscription__c cSub : caseSub){
            cSub.Account__c = acc.Id;
            cSub.Address__c = addressRec.Id;
            cSub.Case__c = testCase.Id;
            cSub.Subscription__c = Subs[0].Id;
            if(i==0){
                cSub.Complaint_From__c = date.today()-10;
                cSub.Complaint_To__c = date.today()-5;
            }
            else{
                cSub.Complaint_From__c = date.today()-2;
                cSub.Complaint_To__c = date.today();    
            }
        }      
        database.insert(caseSub);
        
        test.startTest(); //CHA 22April2016
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            
            ApexPages.currentPage().getParameters().put('id', testCase.Id);
            ApexPages.currentPage().getParameters().put('RecordType', testCase.RecordTypeId);
            
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);   
            
            compNewsCont.objcase = testCase;
            compNewsCont.objcase.contactId = con[0].Id; 
            
            ComplaintNewspaperController.CaseSubWrapper caseSubW = new ComplaintNewspaperController.CaseSubWrapper(caseSub[0]);
            caseSubW.caseSubscription = caseSub[0];
            caseSubW.caseSubscription.Subscription__c = Subs[0].Id;
            caseSubW.caseSubscription.Case__c = testCase.Id;
            List<ComplaintNewspaperController.CaseSubWrapper> caseSubWList = new List<ComplaintNewspaperController.CaseSubWrapper>();
            caseSubWList.add(caseSubW);
            compNewsCont.CSubWrapperList = caseSubWList;
            
            //system.assertEquals(caseSub.Subscription__c, compNewsCont.CSubWrapperList[0].CaseSubscription.Subscription__c);
            
            compNewsCont.save();
        test.StopTest();
    } 
    
 static testMethod void testNullObjectID(){
        
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
        
      //System.assertEquals('', String.valueOf(u));
        
        //The test will run as the user created.
        System.runAs(u) {
            
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';             
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc, pkg[0]};
                
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; 
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Address__c = addressRec.Id;
            //START CCB.002 Modified by: Francis Benzon
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con[0].Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;          
            insert con;            
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            System.debug('DEBUG con.Id' + con[0].Id);
            order.Informed_Customer__c = True;
            insert order;   
            
            //create case
            Case cas = new Case();
            cas.AccountId = acc.id;
            cas.Order__c = order.Id;
            cas.Origin = 'Phone';
            cas.Priority = 'Medium';
            cas.Date_Replaced__c = system.today();
            cas.Status = 'New';
            insert cas;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            //create order line item
            //Order_Line_Item_Vendor__c oli = TestDataFactory.createOrderLineItemVendor(1)[0]; *remove by chan
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Main_Package_ID__c = pack.Id;
            oli.Start_Date__c = date.today()+1;
            insert oli;
            
            
            List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Order_Line_Item_Number__c = oli.Id;
            zsubs[0].Order_Line_Item_Number_1__c = oli.Id;
            zSubs[0].Order_Number__c = order.Id;
            zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
            zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
            zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSubs[0].Urgent__c = 'false';
            zSubs[0].Vendor_Conversion__c = 'false';
            zSubs[0].Charity__c = 'false';
            zSubs[0].Acquisition_Type__c = 'TEST';            
            zSubs[0].Legacy_Create_Date__c = String.valueof(system.today());
            zSubs[0].Legacy_Create_By__c = 'abcde';
            zSubs[0].Legacy_Update_Date__c = String.valueof(system.today());
            zSubs[0].Legacy_Update_By__c = 'abcde';
            zSubs[0].Legacy_Subscription_ID__c ='abcde'; 
            zSubs[0].Zuora__CustomerAccount__c = billAcc.Id;
            insert zSubs;                         
            
            Case testCase = new Case();
            testCase.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            testCase.Order__c = order.Id;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Date_Replaced__c = system.today();
            testCase.Status = 'New';
            testCase.AccountId = acc.Id;
            testCase.Account__c = acc.id;
            insert testCase;
            
            List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            Subs[0].Zuora__Account__c = acc.id;
            Subs[0].Order_Line_Item_Number__c = oli.Id;
            Subs[0].Order_Number__c = order.Id;
            Subs[0].Subscriber_Contact__c = con[0].Id;
            Subs[0].Recipient_Contact__c = con[0].Id;
            Subs[0].Main_Package_1__c = pkg[0].id;
            Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
            Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
            Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Subs[0].Urgent__c = 'false';
            Subs[0].Vendor_Conversion__c = 'false';
            Subs[0].Charity__c = 'false';
            Subs[0].Legacy_Create_Date__c = String.valueof(system.today());
            Subs[0].Legacy_Create_By__c = 'abcde';
            Subs[0].Legacy_Update_Date__c = String.valueof(system.today());
            Subs[0].Legacy_Update_By__c = 'abcde';
            Subs[0].Legacy_Subscription_ID__c ='abcde'; 
            Subs[0].Zuora__CustomerAccount__c = billAcc.Id;
            Test.startTest();
            insert Subs;
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = zSubs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c= 'RATE_PLAN_NAME';
            zSubProdCharge[0].Zuora__Account__c = acc.id;
            zSubProdCharge[0].Zuora__UOM__c = 'Goodwill';
            insert zSubProdCharge;  
            
            Case_Subscription__c cSub = new Case_Subscription__c();
            cSub.Account__c = acc.id;
            cSub.Address__c = addressRec.Id;
            cSub.Subscription__c = Subs[0].id;
            cSub.Complaint_From__c = system.today();
            cSub.Complaint_To__c = system.today();
            cSub.Case__c = testCase.id;
            insert cSub;          
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpc.PublicationCode__c = 'PUB1';
            insert prpc;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
            pub.Publication_Code__c = 'PUB1';
            pub.Published_Days__c = 'YYYYNNY';
            pub.Publication_Type__c = 'M';
            insert pub;
            
            //Test.startTest();
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('def_parent_id', testcase.id);
            //ApexPages.currentPage().getParameters().put('id', testcase.id);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('RecordType',testcase.id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
           
             compNewsCont.goodwillCopiesSelected = 'TEST';
            compNewsCont.subSelected5 = 'test';
            compNewsCont.objcase.id = null;
            /*compNewsCont.objcase.AccountId = acc.Id;
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.objcase.Contactid = con[0].id;
            compNewsCont.isDirect = true;*/
            
            //System.assertEquals(null, compNewsCont.CSubWrapperList);
            
            compNewsCont.save();
            compNewsCont.addRow();
            compNewsCont.cancel();
            //compMagextn.removingRow();
            //compNewsCont.removeRows();                                    
            Test.stopTest();    
            
        }           
    }
    static testMethod void testnotNullObjectID(){
        
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
        
      //System.assertEquals('', String.valueOf(u));
        
        //The test will run as the user created.
        System.runAs(u) {
            
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';             
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc, pkg[0]};
                
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; 
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            insert billAcc;
            
            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Address__c = addressRec.Id;
            //START CCB.002 Modified by: Francis Benzon
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con[0].Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;          
            insert con;            
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            System.debug('DEBUG con.Id' + con[0].Id);
            order.Informed_Customer__c = True;
            insert order;   
            
            //create case
            Case cas = new Case();
            cas.AccountId = acc.id;
            cas.Order__c = order.Id;
            cas.Origin = 'Phone';
            cas.Priority = 'Medium';
            cas.Date_Replaced__c = system.today();
            cas.Status = 'New';
            insert cas;
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            //create order line item
            //Order_Line_Item_Vendor__c oli = TestDataFactory.createOrderLineItemVendor(1)[0]; *remove by chan
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Main_Package_ID__c = pack.Id;
            oli.Start_Date__c = date.today()+1;
            insert oli;
            
            
            List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Order_Line_Item_Number__c = oli.Id;
            zsubs[0].Order_Line_Item_Number_1__c = oli.Id;
            zSubs[0].Order_Number__c = order.Id;
            zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
            zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
            zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSubs[0].Urgent__c = 'false';
            zSubs[0].Vendor_Conversion__c = 'false';
            zSubs[0].Charity__c = 'false';
            zSubs[0].Acquisition_Type__c = 'TEST';            
            zSubs[0].Legacy_Create_Date__c = String.valueof(system.today());
            zSubs[0].Legacy_Create_By__c = 'abcde';
            zSubs[0].Legacy_Update_Date__c = String.valueof(system.today());
            zSubs[0].Legacy_Update_By__c = 'abcde';
            zSubs[0].Legacy_Subscription_ID__c ='abcde'; 
            zSubs[0].Zuora__CustomerAccount__c = billAcc.Id;
            insert zSubs;                         
            
            Case testCase = new Case();
            testCase.RecordTypeId = ConstantsSLB.getKeyId('Case_Start Sub');
            testCase.Order__c = order.Id;
            testCase.Origin = 'Phone';
            testCase.Priority = 'Medium';
            testCase.Date_Replaced__c = system.today();
            testCase.Status = 'New';
            testCase.AccountId = acc.Id;
            testCase.Account__c = acc.id;
            insert testCase;
            
            List<Zuora__Subscription__c> Subs =  TestDataFactory.createSubscription(1);
            //zSubs[0].Subscriber_Contact__c = con[0].id;
            Subs[0].Zuora__Account__c = acc.id;
            Subs[0].Order_Line_Item_Number__c = oli.Id;
            Subs[0].Order_Number__c = order.Id;
            Subs[0].Subscriber_Contact__c = con[0].Id;
            Subs[0].Recipient_Contact__c = con[0].Id;
            Subs[0].Main_Package_1__c = pkg[0].id;
            Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
            Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
            Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Subs[0].Urgent__c = 'false';
            Subs[0].Vendor_Conversion__c = 'false';
            Subs[0].Charity__c = 'false';
            Subs[0].Legacy_Create_Date__c = String.valueof(system.today());
            Subs[0].Legacy_Create_By__c = 'abcde';
            Subs[0].Legacy_Update_Date__c = String.valueof(system.today());
            Subs[0].Legacy_Update_By__c = 'abcde';
            Subs[0].Legacy_Subscription_ID__c ='abcde'; 
            Subs[0].Zuora__CustomerAccount__c = billAcc.Id;
            Test.startTest();
            insert Subs;
            
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = zSubs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c= 'RATE_PLAN_NAME';
            zSubProdCharge[0].Zuora__Account__c = acc.id;
            zSubProdCharge[0].Zuora__UOM__c = 'Goodwill';
            insert zSubProdCharge;  
            
            Case_Subscription__c cSub = new Case_Subscription__c();
            cSub.Account__c = acc.id;
            cSub.Address__c = addressRec.Id;
            cSub.Subscription__c = Subs[0].id;
            cSub.Complaint_From__c = system.today();
            cSub.Complaint_To__c = system.today();
            cSub.Case__c = testCase.id;
            insert cSub;          
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c = 'Bill Plan';
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpc.PublicationCode__c = 'PUB1';
            insert prpc;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
            pub.Publication_Code__c = 'PUB1';
            pub.Published_Days__c = 'YYYYNNY';
            pub.Publication_Type__c = 'M';
            insert pub;
            
            //Test.startTest();
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('def_parent_id', testcase.id);
            //ApexPages.currentPage().getParameters().put('id', testcase.id);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('RecordType',testcase.id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
           
             compNewsCont.goodwillCopiesSelected = 'TEST';
            compNewsCont.subSelected5 = 'test';
            compNewsCont.objcase = testcase;
            //compNewsCont.objcase.AccountId = acc.Id;
            //compNewsCont.objcase.Origin = 'Phone';
           // compNewsCont.objcase.Priority = 'Medium';
            //compNewsCont.objcase.Date_Replaced__c = system.today();
            //compNewsCont.objcase.Status = 'New';
            compNewsCont.objcase.Contactid = con[0].id;
           // compNewsCont.isDirect = true;
            
            //System.assertEquals(null, compNewsCont.CSubWrapperList);
            
            compNewsCont.save();
            compNewsCont.addRow();
            compNewsCont.cancel();
            //compMagextn.removingRow();
            //compNewsCont.removeRows();                                    
            Test.stopTest();    
            
        }           
    
        
    }
    static testMethod void testComplaintNewspaperControllerNotVendor2(){
    try{
            Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
            cir.Name = 'CIR Plan Schedule';
            cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
            cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
            cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
            cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
            database.insert(cir);
            
            List<Other__c> otherList = new List<Other__c>{
                new Other__c(Name='DTL', Value__c='23:59')
            };
            database.insert(otherList);
            
            Key_Id__c key = new Key_Id__c();
            key.Name = 'Package Item_Base Product';
            key.Id__c = '012N00000008jCOIAY';
            key.Type__c = 'RecordType';
            database.insert(key);
            
            Error_Messages__c error = new Error_Messages__c();
            error.Name = 'BlankContactInCase';
            error.Apex_Class_Trigger_Name__c = 'ChangeInAddressExtensionNew';
            error.Description__c = 'For Change of address with address type of Change of Billing address and Delivery address or Change of Billing';
            error.Message__c = 'Contact cannot be empty.';
            database.insert(error);
            
            Error_Messages__c error2 = new Error_Messages__c();
            error2.Name = 'Negative Goodwill';
            error2.Description__c = 'Error message when goodwill amount is a negative value';
            error2.Message__c = 'Goodwill Amount cannot be a negative value.';
            database.insert(error2);
            
            Error_Messages__c error3 = new Error_Messages__c();
            error3.Name = 'Validate Complaint- Newspaper';
            error3.Message__c = 'Package platform should be Newspaper.';
            database.insert(error3);
    
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            database.insert(acc);
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Building_Name__c = 'Ebloc2';
            insert postal;
            
            Country__c country = TestDataFactory.createCountry(1)[0]; 
            country.Country_Name__c = 'SINGAPORE'; 
            insert country;
                        
            Address__c ad = TestDataFactory.createAddress(1)[0];
            ad.Postal_Code__c = postal.id;
            database.insert(ad);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Address__c = ad.id;
            con.Recipient_Indicator__c = true;
            database.insert(con);
        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.AccountId = acc.Id;
            cas.contactId = con.Id;
            cas.Notify_Vendor__c = true;
            database.insert(cas);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            database.insert(pack);
            
            zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
            zp.ProductSubType__c = 'Newspaper';
            database.insert(zp);
            
            zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
            prp.zqu__ZProduct__c = zp.Id;
            database.insert(prp);
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            packItem.Package__c = pack.Id;
            packItem.Product_Rate_Plan__c = prp.Id;
            database.insert(packItem);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            database.insert(billAcc);
            
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Main_Package__c = pack.Id;
            sub.Recipient_Contact__c = con.id;
            database.insert(sub);
            
            List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(2);
            for(Case_Subscription__c cs : caseSub){
                cs.Case__c = cas.Id;
                cs.Subscription__c = sub.Id;
                cs.Goodwill_Amount__c = 1;
            }
            database.insert(caseSub);
            
            Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1)[0];
            database.insert(subVen);
            
            List<Case_Vendor_Subscription__c> caseVen = TestDataFactory.createCaseVendorSub(2);
            for(Case_Vendor_Subscription__c cv : caseVen){
                cv.Case__c = cas.Id;
                cv.Subscription_Vendor__c = subVen.Id;
                cv.Goodwill_Amount__c = 1;
            }
            database.insert(caseVen);
            
            test.startTest();
            PageReference pgRef = Page.ComplaintNewspaperPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('Id', cas.Id);
            ApexPages.currentPage().getParameters().put('def_parent_id', cas.Id);
            
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintNewsPaperController cont = new ComplaintNewsPaperController(stdCtrlr);
            
            cont.save();
            test.stopTest(); 
            }catch(Exception e){}
          
     }
     

    
}