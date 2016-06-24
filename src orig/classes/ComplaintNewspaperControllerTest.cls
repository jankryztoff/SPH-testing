/**
* Class Name: <ComplaintNewspaperControllerTest>
* @author: <KarlTan>
* Date: <8/16/2014>
* Requirement/Project Name: <SPH>
* @description<Test Class for ComplaintNewspaperController>
*/

@isTest (seeAllData= True)
public class ComplaintNewspaperControllerTest {
    
    
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
            //START CCB.002 Modified by: Francis Benzon
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con[0].Recipient_Indicator__c = true;
            //END CCB.002 Modified by: Francis Benzon
            con[0].Phone = '1234567';
            insert con;
            
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';            
            
            insert pkg;
            
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
            
            insert testCase;
            System.debug('@@@@@@'+ 'testcase = ' + testcase.Id);
            Case_Vendor_Subscription__c cVenSub = new Case_Vendor_Subscription__c();
            cVenSub.Subscription_Vendor__c = subVen[0].id;
            cVenSub.Complaint_From__c = system.today();
            cVenSub.Complaint_To__c = system.today();
            cVenSub.Case__c = testCase.id;
            insert cVenSub;          
            
            System.debug('@@@@@@'+ 'casevendor = ' + cVenSub.Id);                                
            
            Test.startTest();
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', testCase.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            compNewsCont.goodwillCopiesSelected = 'TEST';
            compNewsCont.subSelected4 = 'test';
            compNewsCont.subSelected3 = 'test';
            compNewsCont.subSelected5 = 'test';
            compNewsCont.objcase = testcase;
            compNewsCont.objcase.AccountId = acc.Id;
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.objcase.Contactid = con[0].id;
            
            
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
            compNewsCont.computePaperFee(insertCaseSubsList);
            compNewsCont.computeCreditAmount(insertCaseSubsList);
            Test.stopTest();    
            
        }           
    }
    /*
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
            Test.startTest();
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
            
            Case_Subscription__c ncSub = new Case_Subscription__c();
            ncSub.Account__c = acc.id;
            ncSub.Address__c = addressRec.Id;
            ncSub.Subscription__c = zSubs[0].id;
            ncSub.Complaint_From__c = system.today()-3;
            ncSub.Complaint_To__c = system.today()-3;
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
            
                     
        //    Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
         //   pub.Publication_Code__c = 'PUB1';
          //  pub.Published_Days__c = 'YYYYNNY';
          //  pub.Publication_Type__c = 'M';
          //  insert pub;
            
            Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
            npub.Publication_Code__c = 'PUB1';
            npub.Published_Days__c = 'YYYYYNN';
            npub.Publication_Type__c = 'M';
            npub.Publish_Pattern__c = 'Weekend';
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
            
            
            Case_Vendor_Fee__c caseVenFee = new Case_Vendor_Fee__c ();
            caseVenFee.Case__c = testcase.id;
            database.insert(caseVenFee);
            
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
            //compNewsCont.getCoverPrice(npub.Publication_Code__c, 'Sunday', npub.Id);
            compNewsCont.getNonPubDates(npub.Publication_Code__c);
            compNewsCont.getNonPubdays(); 
            
            //try-jess
            compNewsCont.save();
            compNewsCont.computePaperFee(insertCaseSubsList);
            compNewsCont.computeCreditAmount(insertCaseSubsList);
            Test.stopTest();   
            
           
        }           
    }*/
    
    
    
}