@isTest (seeAllData= True)
public class ComplaintNewspaperControllerTestApril {

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
            UserName='standard10@test.com'
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
            UserName='standard11@test.com'
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