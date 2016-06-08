/**
* Class Name: <ComplaintNewspaperController2Test>
* @author: 
* Date: 
* Requirement/Project Name: <SPH>
* @description<Test Class for ComplaintNewspaperController>
*/
@isTest(seeAllData = true)
private class ComplaintNewspaperController2Test {

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
    /*
    static testMethod void testCreateNew(){
        
        User u=testUser();
        
        Map<string, Id> data = testData(); 
        
        //Test.startTest();
        
        System.runAs(u) {
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            Apexpages.currentpage().getParameters().put('index', '0');
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Case());
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            compNewsCont.objcase.AccountId = data.get('Account');
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.isDirect = false;
            String error = '';
            try{
                
                //compNewsCont.save();
                
                compNewsCont.addRow();
                
                ApexPages.currentPage().getParameters().put('accountId', data.get('Account'));
                compNewsCont.cancel();
                
                compNewsCont.fetchAccountDetails();
                compNewsCont.removeRows();
                Zuora__SubscriptionProductCharge__c spc = [SELECT Id FROM Zuora__SubscriptionProductCharge__c WHERE Id=:data.get('Zuora__SubscriptionProductCharge__c') LIMIT 1];
                compNewsCont.objSpc = spc;
            }catch(exception e)
            {
                error = e.getMessage();
            }
            
            System.assertEquals('', error); 
        }    
       
        Test.stopTest();       
    }  
    */
    /*
   static testMethod void testCreateWithAccount(){
       
        Map<string, Id> data = testData(); 
        
        User u = testUser();
        
        //Test.startTest();
        
        System.runAS(u){
        
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(2)[1];
            prdRatePlan.zqu__ZProduct__c = data.get('zqu__ZProduct__c');
            prdRatePlan.RatePlanType__c = 'Bill Plan'; 
            prdRatePlan.RatePlanSubType__c = 'Standard'; 
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            insert prdRatePlan;
            
            //Package_Item__c packItem = new Package_Item__c(id=data.get('Package_Item__c'));   
            //packItem.Package__c = pkg.id;
            //database.update(packItem);
            
            List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
            zSubs[0].Zuora__Account__c = data.get('Account');
            zSubs[0].Order_Line_Item_Number__c = data.get('Order_Line_Item__c');
            zSubs[0].Order_Number__c = data.get('Order__c');
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
            zSubs[0].Zuora__CustomerAccount__c = data.get('Zuora__CustomerAccount__c');
            zSubs[0].Sponsor_1__c = true;
            zSubs[0].Name = 'Subscription 1';
            zSubs[0].Main_Package__c = data.get('Package__c');
            zSubs[0].Zuora__SubscriptionStartDate__c = null;
            zSubs[0].Term_Length__c = 30;
            zsubs[0].Zuora__SubscriptionEndDate__c = null;
            insert zSubs;    
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            cas.AccountId = data.get('Account');
            database.insert(cas);
            
            Case_Subscription__c caseSub = new Case_Subscription__c();
            caseSub.Subscription__c = zSubs[0].Id;
            caseSub.Case__c = cas.Id;
            caseSub.Account__c = data.get('Account');
            //database.insert(caseSub); //CHA 22April2016
            
            
            Package_Item__c packItem = [SELECT id, Package__c FROM Package_Item__c WHERE id=:data.get('Package_Item__c') AND Package__c != null];
            database.delete(packItem); 
            
            Package_Item__c packItems = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItems.Package__c = data.get('Package__c');
            packItems.Product_Rate_Plan__c = data.get('zqu__ProductRatePlan__c');
            database.insert(packItems);
            
            system.assertNotEquals(packItems.Package__c, null);
           
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            Apexpages.currentpage().getParameters().put('index', '0');
            ApexPages.currentPage().getParameters().put('accountId', data.get('Account'));
            ApexPages.currentPage().getParameters().put('contactId', data.get('Contact'));
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Case());
            //ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            ComplaintNewspaperController.CaseSubWrapper caseSubW = new ComplaintNewspaperController.CaseSubWrapper(caseSub);
            
            caseSubW.caseSubscription.Subscription__c = zSubs[0].Id;
            
            Case_Vendor_Subscription__c caseVen = [SELECT id, Subscription_Vendor__c, Complaint_From__c, Complaint_To__c, Case__c FROM Case_Vendor_Subscription__c WHERE id =: data.get('Case_Vendor_Subscription__c')];
            
            caseSubW.caseVendorSubscription = caseVen;
            
            List<ComplaintNewspaperController.CaseSubWrapper> caseSubWList = new List<ComplaintNewspaperController.CaseSubWrapper>();
            caseSubWList.add(caseSubW);
            
            //System.assertEquals(caseSubW.caseSubscription.Subscription__r.Main_Package_1__c, packItem.Package__c);
           //System.assertEquals(zSubs[0].Main_Package_1__c, packItem.Package__c);
            
            compNewsCont.CSubWrapperList = caseSubWList;
            
            String error = '';
            try{
                compNewsCont.save();
            }catch(exception e){
                error = e.getMessage();
            }
            
        //    System.assertEquals(error, '');      
       }
        
        Test.stopTest();
    }  
    */
    /*
    static testMethod void testCreateWithAccountPackItem(){
                
        //test.startTest();
    
        Map<string, Id> data = testData(); 
        
        Account acc = [SELECT Id FROM Account WHERE id=:data.get('Account')];
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND Name='Direct Corporate'].Id;
        acc.Mobile__c = '123456789';
        database.update(acc);
        
       
           PageReference pgRef = Page.ComplaintMagazineEditPage;
           Test.setCurrentPage(pgRef);
           Apexpages.currentpage().getParameters().put('index', '0');
           ApexPages.currentPage().getParameters().put('accountId', acc.Id);
           ApexPages.currentPage().getParameters().put('contactId', data.get('Contact'));
           ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Case());  
           ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
           
           Zuora__Subscription__c zs = [SELECT id, Zuora__Account__c, Main_Package_1__c, Main_Package_isNull__c FROM Zuora__Subscription__c WHERE id=:data.get('Zuora__Subscription__c2')];
           system.assertNotEquals(zs.Id, null);
           system.assertNotEquals(zs.Zuora__Account__c, null);
           system.assertEquals(zs.Main_Package_isNull__c, 'FALSE');
           system.assertNotEquals(zs.Main_Package_1__c, null);
       
        test.stopTest();
                
           Case_Subscription__c caseSub = [SELECT id FROM Case_Subscription__c WHERE id=:data.get('Case_Subscription__c')];  
           //Case_Subscription__c caseSub = new Case_Subscription__c(id=data.get('Case_Subscription__c'));
           
           ComplaintNewspaperController.CaseSubWrapper caseSubW = new ComplaintNewspaperController.CaseSubWrapper(caseSub);
           caseSubW.caseSubscription.Subscription__c = zs.Id;
           
           List<ComplaintNewspaperController.CaseSubWrapper> caseSubWList = new List<ComplaintNewspaperController.CaseSubWrapper>();
           
           caseSubWList.add(caseSubW);
           
           compNewsCont.CSubWrapperList = caseSubWList;
           compNewsCont.save(); 
       
    }  
    */
    /*
    static testMethod void testCreateWithAccount2(){
       
        Map<string, Id> data = testData(); 
        
        //Test.startTest();
        
        //initialize page and controllers
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        Apexpages.currentpage().getParameters().put('index', '0');
        Account acc = new Account(id=data.get('Account'));
        acc.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Direct Corporate' LIMIT 1].Id;
        acc.Mobile__c = '123456';
        database.update(acc);
        
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('contactId', data.get('Contact'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Case());
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
        
        Case_Subscription__c caseSub = new Case_Subscription__c(id=data.get('Case_Subscription__c'));
 
        
        ComplaintNewspaperController.CaseSubWrapper caseSubW = new ComplaintNewspaperController.CaseSubWrapper(caseSub);
        caseSubW.caseSubscription.Subscription__c = data.get('Zuora__Subscription__c');
        
        List<ComplaintNewspaperController.CaseSubWrapper> caseSubWList = new List<ComplaintNewspaperController.CaseSubWrapper>();
        caseSubWList.add(caseSubW);
            
        Package_Item__c packItem = new Package_Item__c(id=data.get('Package_Item__c'));
        
        System.assertEquals(caseSubW.caseSubscription.Subscription__r.Main_Package_1__c, packItem.Package__c);
        
        compNewsCont.CSubWrapperList = caseSubWList;
        
        Case cas = new Case(id=data.get('Case'));
        cas.contactId = data.get('Contact');
        cas.AccountId = null;
        
        compNewsCont.objcase = cas; 
        compNewsCont.objcase.Notify_Vendor__c = true;    
        
        String error = '';
        try{
            compNewsCont.save();
            
            compNewsCont.objcase.Replaced_by_Courier__c = true;
            compNewsCont.save();
        }catch(exception e){
            error = e.getMessage();
        }
        
        System.assert(error == ''); 
        
        Subscription_Vendor__c subs = [SELECT id, Name, Vendor__c FROM Subscription_Vendor__c WHERE id=: data.get('Subscription_Vendor__c')];
        
        Case_Vendor_Subscription__c caseVenSub = [SELECT id FROM Case_Vendor_Subscription__c WHERE id=: data.get('Case_Vendor_Subscription__c')];
        
        compNewsCont.subSelected3 = '123';
        compNewsCont.subSelected = '';
        compNewsCont.subSelected2 = '123';
        compNewsCont.subSelected4 = '123';
        PageReference pageref = compNewsCont.retPackageName();
        PageReference pageref1 = compNewsCont.retPackageName1();
        
        ComplaintNewspaperController.CaseSubWrapper caseSubW1 = new ComplaintNewspaperController.CaseSubWrapper(caseSub);
        caseSubW1.caseSubscription.Subscription__c = data.get('Zuora__Subscription__c');
        
        List<ComplaintNewspaperController.CaseSubWrapper> caseSubWList1 = new List<ComplaintNewspaperController.CaseSubWrapper>();
        caseSubW1.counterWrap = 123;
        caseSubW1.caseVendorSubscription = caseVenSub;
        caseSubWList1.add(caseSubW1);
        
        compNewsCont.CSubWrapperList = caseSubWList1;
        
        //system.assertequals();

        compNewsCont.isNotDirectDisplay(subs.Name, compNewsCont.subSelected4);
        compNewsCont.isNotDirectDisplay('Name', compNewsCont.subSelected4);
        
        subs.Vendor__c = data.get('Account');
        database.update(subs);
        
        compNewsCont.isNotDirectDisplay(subs.Name, compNewsCont.subSelected4);
        
        Zuora__Subscription__c zs = [SELECT Id, Name, Main_Package_1__c FROM Zuora__Subscription__c WHERE id=:data.get('Zuora__Subscription__c')];
        
        compNewsCont.returnChecker('123',zs.Name);
        
        compNewsCont.returnChecker('123',zs.Name);
        
        Test.stopTest();
    }  
    */
    /*
    static testMethod void testCreateWithAccount3(){
       
        Map<string, Id> data = testData(); 
        
        //RecordType rec = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND Name='Complaint - Newspaper'];
        
        //Case cas = new Case(id=data.get('Case'));
        //cas.RecordTypeId = rec.Id;
        //database.update(cas);
        
        //Test.startTest();
        
        //initialize page and controllers
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        Apexpages.currentpage().getParameters().put('index', '0');
        //ApexPages.currentPage().getParameters().put('RecordType', cas.RecordTypeId);
        Account acc = new Account(id=data.get('Account'));
        acc.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Direct Corporate' LIMIT 1].Id;
        acc.Mobile__c = '123456';
        database.update(acc);
        
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('contactId', data.get('Contact'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Case());
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
        
        Case_Subscription__c caseSub = new Case_Subscription__c(id=data.get('Case_Subscription__c'));
 
        
        ComplaintNewspaperController.CaseSubWrapper caseSubW = new ComplaintNewspaperController.CaseSubWrapper(caseSub);
        caseSubW.caseSubscription.Subscription__c = data.get('Zuora__Subscription__c');
        
        List<ComplaintNewspaperController.CaseSubWrapper> caseSubWList = new List<ComplaintNewspaperController.CaseSubWrapper>();
        caseSubWList.add(caseSubW);
            
        Package_Item__c packItem = new Package_Item__c(id=data.get('Package_Item__c'));
        
        System.assertEquals(caseSubW.caseSubscription.Subscription__r.Main_Package_1__c, packItem.Package__c);
        
        compNewsCont.CSubWrapperList = caseSubWList;
        
        Case cas = new Case(id=data.get('Case'));
        cas.contactId = data.get('Contact');
        cas.AccountId = null;
        
        compNewsCont.objcase = cas; 
        
        String error = '';
        try{
            compNewsCont.save();
            
            compNewsCont.objcase.Replaced_by_Courier__c = true;
            compNewsCont.save();
        }catch(exception e){
            error = e.getMessage();
        }
        
        System.assert(error == ''); 
        
        Subscription_Vendor__c subs = [SELECT id, Name, Vendor__c FROM Subscription_Vendor__c WHERE id=: data.get('Subscription_Vendor__c')];
        
        Case_Vendor_Subscription__c caseVenSub = [SELECT id FROM Case_Vendor_Subscription__c WHERE id=: data.get('Case_Vendor_Subscription__c')];
        
        compNewsCont.subSelected3 = '123';
        compNewsCont.subSelected = '';
        compNewsCont.subSelected2 = '123';
        compNewsCont.subSelected4 = '123';
        PageReference pageref = compNewsCont.retPackageName();
        PageReference pageref1 = compNewsCont.retPackageName1();
        
        ComplaintNewspaperController.CaseSubWrapper caseSubW1 = new ComplaintNewspaperController.CaseSubWrapper(caseSub);
        caseSubW1.caseSubscription.Subscription__c = data.get('Zuora__Subscription__c');
        
        List<ComplaintNewspaperController.CaseSubWrapper> caseSubWList1 = new List<ComplaintNewspaperController.CaseSubWrapper>();
        caseSubW1.counterWrap = 123;
        caseSubW1.caseVendorSubscription = caseVenSub;
        caseSubWList1.add(caseSubW1);
        
        compNewsCont.CSubWrapperList = caseSubWList1;
        
        //system.assertequals();

        compNewsCont.isNotDirectDisplay(subs.Name, compNewsCont.subSelected4);
        compNewsCont.isNotDirectDisplay('Name', compNewsCont.subSelected4);
        
        subs.Vendor__c = data.get('Account');
        database.update(subs);
        
        compNewsCont.isNotDirectDisplay(subs.Name, compNewsCont.subSelected4);
        
        Zuora__Subscription__c zs = [SELECT Id, Name, Main_Package_1__c FROM Zuora__Subscription__c WHERE id=:data.get('Zuora__Subscription__c')];
        
        compNewsCont.returnChecker('123',zs.Name);
        
        compNewsCont.returnChecker('123',zs.Name);
        
        Test.stopTest();
    }  
    */
    /*
   static testMethod void testSingleVendorSub(){
   
       
        User u = testUser();
        
        Map<string, Id> data = testData(); 
        
        //Test.startTest();
        
        System.runAs(u){                             
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', data.get('Case'));
            Id casId = data.get('Case');
            Case cas = new case(Id=casId, AccountId = data.get('Account'));
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            compNewsCont.objcase.AccountId = data.get('Account');
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            
            compNewsCont.save();
            compNewsCont.addRow();
            compNewsCont.cancel();
            
            Case nullCas = new Case();
            System.assert(nullCas.Id==null);
            ApexPages.StandardController stdCtrlr2 = new ApexPages.StandardController(nullCas);
            ComplaintNewspaperController compNewsCont2 = new ComplaintNewspaperController (stdCtrlr2);
            
            Account accnt = [SELECT id FROM Account WHERE RecordType.Name!='Vendor Subscriber' AND RecordType.Name!='Vendor' LIMIT 1];
            Case cas2 = new case(Id=data.get('Case'));
            cas2.AccountId = accnt.Id;
            update cas2;
            ApexPages.StandardController stdCtrlr3 = new ApexPages.StandardController(cas2);
            ComplaintNewspaperController compNewsCont3 = new ComplaintNewspaperController (stdCtrlr3);
            
            Test.stopTest();
            
        }           
    }    
    */
    /*
    static testMethod void testSingleDirectSub(){
  
       User u = testUser();
            
       Map<string, Id> data = testData();
       
       //Test.startTest();   
            
       System.runAs(u) { 
       
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', data.get('Case'));
            Case cas = new Case(Id=data.get('Case'));
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            compNewsCont.objcase.AccountId = data.get('Account');
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.isDirect = true;
            System.assertNotEquals(null, compNewsCont.CSubWrapperList); 
            
            compNewsCont.save();
            compNewsCont.addRow();
            compNewsCont.cancel();                                   
            Test.stopTest();    
            
        }           
    }    
    */
    /*
     static testMethod void testCaseSubs(){
        
        User u = testUser();
        
        Map<string, Id> data = testData();
        double totalPaperFee;
        
        
        //List<Case_Subscription__c> insertCaseSubsList = [SELECT Id, Replacement_Copies__c, Replace_From__c, Replace_To__c, Complaint_Copies__c, Name, Subscription__c, Complaint_From__c, Complaint_To__c FROM Case_Subscription__c WHERE Name!=null LIMIT 2];
        //System.assertEquals(insertCaseSubsList.size(), 2);
        
        //insertCaseSubsList[0].Complaint_From__c = date.today()-10;
        //insertCaseSubsList[0].Complaint_To__c = date.today()-1;
        
        List<Case_Subscription__c> insertCaseSubsList = [SELECT id, Name FROM Case_Subscription__c WHERE id=:data.get('Case_Subscription__c')];
        
        database.update(insertCaseSubsList);
        
        //Test.startTest();
        System.runAs(u){
            try{
                //initialize page and controllers
                PageReference pgRef = Page.ComplaintMagazineEditPage;
                Test.setCurrentPage(pgRef);
                ApexPages.currentPage().getParameters().put('id', data.get('Case'));
                Case testCase = new Case(id=data.get('Case'));
                ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
                ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
                compNewsCont.isDirect = TRUE;
                compNewsCont.objcase.Paper_Fee__c = totalPaperFee;
                
                compNewsCont.objcase.Vendor_Chargeable_Paper__c = true;
                compNewsCont.callComputatePaperFee();
                compNewsCont.computePaperFee(insertCaseSubsList);
                //compNewsCont.computePaperFee(caseSubList);
                compNewsCont.computeCreditAmount(insertCaseSubsList);
            }
            catch(Exception e){
            
            }
        }      
        
        Test.stopTest();     
        System.assert(insertCaseSubsList.size()>0);
        System.assertNotEquals(null, insertCaseSubsList[0].Name);
    }  
    */
    /*
    static testMethod void testremoveRows(){
   
        User u = testUser();
        
        Map<string, Id> data = testData();
        
        List<Case_Subscription__c> insertCaseSubsList = [SELECT Id, Name, Replacement_Copies__c, Replace_From__c, Replace_To__c, Subscription__c, Complaint_From__c, Complaint_To__c, Complaint_Copies__c FROM Case_Subscription__c WHERE Name!=null LIMIT 4];
            
        //Test.startTest(); 
        System.runAs(u) {
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', data.get('Case'));
            Case testCase = new Case(id=data.get('Case'));
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            compNewsCont.objcase.AccountId = data.get('Account');
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.isDirect = true;
            
            Publication__c npub = new Publication__c(id=data.get('Publication__c'));
            compNewsCont.getNonPubDates(npub.Publication_Code__c);
            compNewsCont.getNonPubdays(); 
            
            string error = '';
            
            try{
                    compNewsCont.save();
                    compNewsCont.addRow();
                    compNewsCont.fetchAccountDetails();
                    compNewsCont.removeRows();
                    
                    compNewsCont.objcase = testCase;
                    compNewsCont.cancel();
                }catch(exception e)
                {
                    error = e.getMessage();
                }
            
            Test.stopTest();    
            System.assert(insertCaseSubsList.size()>0);
        }           
    } 
    */
    /*
   static testMethod void testWithsubs(){
   
        User u = testUser();
        
        Map<string, Id> data = testData();
        
        //Test.startTest();   
            System.runAs(u) {
            List<Case_Subscription__c> insertCaseSubsList = [SELECT id, Complaint_Copies__c, Replacement_Copies__c, Replace_From__c, Replace_To__c, Complaint_From__c, Complaint_To__c, Subscription__c FROM Case_Subscription__c WHERE Id = :data.get('Case_Subscription__c')];
            List<Case_Subscription__c> insertCaseSubsList2 = [SELECT id, Replacement_Copies__c, Replace_From__c, Replace_To__c, Complaint_From__c, Complaint_To__c, Subscription__c, Complaint_Copies__c FROM Case_Subscription__c WHERE Subscription__r.Main_Package_1__c!=null LIMIT 10];
            
            //System.assertNotEquals(insertCaseSubsList[0].Subscription__r.Main_Package_1__c, null);
            System.assertNotEquals(insertCaseSubsList[0].Id, null);
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.currentPage().getParameters().put('id', data.get('Case'));
            Case testCase = new Case(id=data.get('Case'));
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            compNewsCont.objcase.AccountId = data.get('Account');
            compNewsCont.objcase.Origin = 'Phone';
            compNewsCont.objcase.Priority = 'Medium';
            compNewsCont.objcase.Date_Replaced__c = system.today();
            compNewsCont.objcase.Status = 'New';
            compNewsCont.isDirect = true;
            compNewsCont.getNonPubDates(data.get('Publication__c'));
            compNewsCont.getNonPubdays(); 
            //compNewsCont.save();
            compNewsCont.computePaperFee(insertCaseSubsList);
            compNewsCont.computeCreditAmount(insertCaseSubsList);
            compNewsCont.computeCreditAmount(insertCaseSubsList2);
            Test.stopTest();    
            System.assertNotEquals(null, compNewsCont.CSubWrapperList);
        }
    }   
    */
    /*
     static testMethod void testGetCopyPrice(){
        Map<string, Id> data = testData();
        User u = testUser();
        
        //Test.startTest(); 
        
        System.runAs(u){
        
        List <Case_Subscription__c> caseSubList = new List <Case_Subscription__c> ();
        
        Case_Subscription__c cSub = new Case_Subscription__c(id=data.get('Case_Subscription__c'));
        
        caseSubList.add(cSub);
        
        List<zqu__ProductRatePlanCharge__c> prpcList = TestDataFactory.createProductRatePlanCharge(4);
        for(zqu__ProductRatePlanCharge__c prpc: prpcList)
        {   prpc.zqu__ProductRatePlan__c = data.get('zqu__ProductRatePlan__c');
         prpc.PublicationCode__c = 'BHAO';
        }
        prpcList[0].zqu__UOM__c = 'Copy Sat';
        prpcList[0].zqu__ZuoraId__c = 'id001';
        prpcList[1].zqu__UOM__c = 'Copy Weekday'; 
        prpcList[1].zqu__ZuoraId__c = 'id002';    
        prpcList[2].zqu__UOM__c = 'Copy Sun';   
        prpcList[2].zqu__ZuoraId__c = 'id003';   
        prpcList[3].zqu__UOM__c = 'Copy MonthBHAO';
        prpcList[3].zqu__ZuoraId__c = 'id004';
        insert prpcList;  
        
        //initialize page and controllers
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', data.get('Case'));
        Case testCase = new Case(id=data.get('Case'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
        Map<String, Map<String, Decimal>> price = ComplaintNewspaperController.getCopyPrice(prpcList, 'BHAO');          
        Test.stopTest();
        System.assert(price.size()>0);       
    }
    
 }  
    */
    /*
  static testMethod void testUsageCallOut(){
        Map<string, Id> data = testData();
        User u = testUser();
        
        //Test.startTest(); 
        
        System.runAs(u){
        
        
        List <Case_Subscription__c> caseSubList = new List <Case_Subscription__c> ();
        
        Case_Subscription__c cSub = new Case_Subscription__c(id=data.get('Case_Subscription__c'));
        
        caseSubList.add(cSub);
        
        Integer count = 0;
        List<zqu__ProductRatePlanCharge__c> prpcList = TestDataFactory.createProductRatePlanCharge(4);
        for(zqu__ProductRatePlanCharge__c prpc: prpcList)
        {   prpc.zqu__ProductRatePlan__c = data.get('zqu__ProductRatePlan__c');
         prpc.PublicationCode__c = 'BHAO';
         prpc.zqu__ZuoraId__c = 'id'+count;
        }
        prpcList[0].zqu__UOM__c = 'Copy Sat';
        prpcList[0].zqu__ZuoraId__c = 'id001';
        prpcList[1].zqu__UOM__c = 'Copy Weekday'; 
        prpcList[1].zqu__ZuoraId__c = 'id002';    
        prpcList[2].zqu__UOM__c = 'Copy Sun';   
        prpcList[2].zqu__ZuoraId__c = 'id003';   
        prpcList[3].zqu__UOM__c = 'Copy MonthBHAO';
        prpcList[3].zqu__ZuoraId__c = 'id004';
        
        insert prpcList;  
        
        Usage__c usage = new Usage__c();
        usage.UOM__c = 'Copy Sat';
        usage.Quantity__c = 10;
        usage.Status__c = 'Failed';
        usage.Account_Id__c = string.valueOf(data.get('Account'));
        usage.Subscription_Id__c = 'BA-S00002477';
        usage.Rate_Plan_Charge_Id__c = 'C-00058656';
        usage.Start_Date__c = date.today();
        insert usage;
        
        Set<id> usageId = new Set<id>();
        usageId.add(usage.id);
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', data.get('Case'));
        Case testCase = new Case(id=data.get('Case'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
        String error = '';
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        ComplaintNewspaperController.usageCallOut(usageId);
        Test.stopTest();
        }catch(Zuora.zRemoteException e)
        {
            error = e.getMessage();
        }        
    } 
 }    
    */
    /*
  static testMethod void testComputeCreditAmountNoDiscount(){
        Map<string, Id> data = testData();
        User u = testUser();
    
        //Test.startTest(); 
        
        System.runAs(u){
        
        List <Case_Subscription__c> caseSubList = new List <Case_Subscription__c> ();
        
        Case_Subscription__c cSub = new Case_Subscription__c(id=data.get('Case_Subscription__c'));
        
        caseSubList.add(cSub);
        
        //initialize page and controllers
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', data.get('Case'));
        case testCase = new Case(id=data.get('Case'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
        String error = '';
        compNewsCont.isDirect = TRUE;
        try{
            compNewsCont.computeCreditAmount(caseSubList);   
        }catch(exception e)
        {
            error = e.getMessage();
        }
        Test.stopTest();
        System.debug(error);
        
        }
        
    }  
    */
    /*
    static testMethod void testComputeCreditAmountElse(){
        Map<string, Id> data = testData();
        
        //Test.startTest(); 
        
        List <Case_Subscription__c> caseSubList = new List <Case_Subscription__c> ();
        
        Case_Subscription__c cSub = new Case_Subscription__c(id=data.get('Case_Subscription__c'));
        
        caseSubList.add(cSub);
             
        //initialize page and controllers
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', data.get('Case'));
        Case testCase = new Case(id=data.get('Case'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
        String error = '';
        compNewsCont.isDirect = TRUE;
        try{
            compNewsCont.computeCreditAmount(caseSubList);   
        }catch(exception e)
        {
            error = e.getMessage();
        }
        Test.stopTest();
        System.debug(error);
        
    } 
    */
    /*
    static testMethod void testComputeCreditAmount2Discounts(){
        Map<string, Id> data = testData();
        User u = testUser();
        
        //Test.startTest(); 
       
        System.runAs(u){
        
        List <Case_Subscription__c> caseSubList = new List <Case_Subscription__c> ();
        
        Case_Subscription__c caseSub = new Case_Subscription__c(id=data.get('Case_Subscription__c'));
        
        caseSubList.add(caseSub);       
        
        //initialize page and controllers
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', data.get('Case'));
        Case testCase = new Case(id=data.get('Case'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
        String error = '';
        compNewsCont.isDirect = TRUE;
        try{
            compNewsCont.computePaperFee(caseSubList);
            compNewsCont.computeCreditAmount(caseSubList);   
        }catch(exception e)
        {
            error = e.getMessage();
        }
        Test.stopTest();
        
    } 

  }      
    */
    /*
   static testMethod void testComputePaperFee(){
        Map<string, Id> data = testData();
        User u = testUser();
         
        zqu__ProductRatePlan__c zqu = [SELECT id, RatePlanSubType__c, RatePlanType__c, Name, zqu__ZProduct__r.zqu__SKU__c FROM zqu__ProductRatePlan__c WHERE id=:data.get('zqu__ProductRatePlan__c')];
        zqu.RatePlanType__c = 'Proration';
        zqu.RatePlanSubType__c = 'Standard';
        database.update(zqu);
        
        zqu__ProductRatePlanCharge__c prpc = [SELECT Id, zqu__UOM__c FROM zqu__ProductRatePlanCharge__c WHERE Id=:data.get('zqu__ProductRatePlanCharge__c')];
        prpc.zqu__UOM__c = 'Copy Weekday';
        
        database.update(prpc);
       
        //Test.startTest(); 
        
        System.runAs(u){            
        
        List <Case_Subscription__c> caseSubList = new List <Case_Subscription__c> ();
        
        Case_Subscription__c caseSub = [SELECT id, Subscription__c FROM Case_Subscription__c WHERE id=:data.get('Case_Subscription__c')];
        
        Case_Subscription__c cSub = new Case_Subscription__c();
        cSub.Account__c = data.get('Account');
        cSub.Address__c = data.get('Address__c');
        cSub.Subscription__c = data.get('Zuora__Subscription__c2');
        cSub.Complaint_From__c = system.today()-15;
        cSub.Complaint_To__c = system.today()-10;
        cSub.Case__c = data.get('Case');
        cSub.Legacy_Create_Date__c = String.valueof(system.today());
        //Test.startTest();
        insert cSub;  
        
        caseSubList.add(caseSub);  
        caseSubList.add(cSub);  
        
        //initialize page and controllers
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', data.get('Case'));
        Case testCase = new Case(id=data.get('Case'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);    
        String error = '';
        try{
        compNewsCont.computePaperFee(caseSubList);   
        
        prpc.zqu__UOM__c = 'Copy Sat';
        compNewsCont.computePaperFee(caseSubList);
        
        prpc.zqu__UOM__c = 'Copy Sun';
        compNewsCont.computePaperFee(caseSubList);
        
        //Publication__c pub = [SELECT Id, Published_Days__c FROM Publication__c WHERE Id=:data.get('Publication__c')];
        //pub.Published_Days__c = 'YYYYYYY';
        //database.update(pub);
        //compNewsCont.computePaperFee(caseSubList);
        }catch(exception e)
        {
            error = e.getMessage();
        }
        Test.stopTest();
        System.debug(error);
        
        }
        
    }   
    */
    /*
    static testMethod void testComputePaperFee2(){
        Map<string, Id> data = testData();
        User u = testUser();
        
        //Test.startTest(); 
        
        zqu__ProductRatePlan__c zqu = [SELECT id, RatePlanSubType__c, RatePlanType__c, Name, zqu__ZProduct__r.zqu__SKU__c FROM zqu__ProductRatePlan__c WHERE id=:data.get('zqu__ProductRatePlan__c')];
        zqu.RatePlanType__c = 'Proration';
        zqu.RatePlanSubType__c = 'Standard';
        database.update(zqu);
        
        zqu__ProductRatePlanCharge__c prpc = [SELECT Id, zqu__UOM__c FROM zqu__ProductRatePlanCharge__c WHERE Id=:data.get('zqu__ProductRatePlanCharge__c')];
        prpc.zqu__UOM__c = 'Copy Weekday';
        database.update(prpc);
       
        
        Test.stopTest();
        
        System.runAs(u){            
        
        List <Case_Subscription__c> caseSubList = new List <Case_Subscription__c> ();
        
        Case_Subscription__c caseSub = [SELECT id, Subscription__c FROM Case_Subscription__c WHERE id=:data.get('Case_Subscription__c')];
        
        caseSubList.add(caseSub);  
        caseSubList.add(caseSub);  
        
        //initialize page and controllers
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', data.get('Case'));
        Case testCase = new Case(id=data.get('Case'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);    
        String error = '';
        try{
         
        
        prpc.zqu__UOM__c = 'Copy Sat';
        compNewsCont.computePaperFee(caseSubList);
        
        prpc.zqu__UOM__c = 'Copy Sun';
        compNewsCont.computePaperFee(caseSubList);
        compNewsCont.computePaperFee(caseSubList); 
        
        //Publication__c pub = [SELECT Id, Published_Days__c FROM Publication__c WHERE Id=:data.get('Publication__c')];
        //pub.Published_Days__c = 'YYYYYYY';
        //database.update(pub);
        //compNewsCont.computePaperFee(caseSubList);
        }catch(exception e){}
        }
        
    }   
    */
    /*
    static testMethod void testComputePaperFee3(){
        Map<string, Id> data = testData();
        
        User u = testUser();
        
        zqu__ProductRatePlan__c zqu = [SELECT id, RatePlanSubType__c, RatePlanType__c, Name, zqu__ZProduct__r.zqu__SKU__c FROM zqu__ProductRatePlan__c WHERE id=:data.get('zqu__ProductRatePlan__c')];
        zqu.RatePlanType__c = 'Proration';
        zqu.RatePlanSubType__c = 'Standard';
        database.update(zqu);
        
        zqu__ProductRatePlanCharge__c prpc = [SELECT Id, zqu__UOM__c FROM zqu__ProductRatePlanCharge__c WHERE Id=:data.get('zqu__ProductRatePlanCharge__c')];
        prpc.zqu__UOM__c = 'Copy Weekday';
        database.update(prpc);
        
        Publication__c pub = [SELECT Id FROM Publication__c WHERE Id=:data.get('Publication__c')];
       
        //Test.startTest(); 
        
        System.runAs(u){            
        
        List <Case_Subscription__c> caseSubList = new List <Case_Subscription__c> ();
        
        Case_Subscription__c caseSub = [SELECT id, Subscription__c FROM Case_Subscription__c WHERE id=:data.get('Case_Subscription__c')];
        
        caseSubList.add(caseSub);    
        
        //initialize page and controllers
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', data.get('Case'));
        Case testCase = new Case(id=data.get('Case'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr); 
        
        String error = '';
        try{
        compNewsCont.computePaperFee(caseSubList);   
        
        prpc.zqu__UOM__c = 'Copy Sat';
        compNewsCont.computePaperFee(caseSubList);
        
        prpc.zqu__UOM__c = 'Copy Sun';
        compNewsCont.computePaperFee(caseSubList);
        compNewsCont.computePaperFee(caseSubList);
        }catch(exception e)
        {
            error = e.getMessage();
        }
        Test.stopTest();
        System.debug(error);
        
        }
        
    }   
    */
    /*
    static testMethod void testComputePaperFee4(){
        Map<string, Id> data = testData();
        User u = testUser();
                
        //Test.startTest(); 
        
        zqu__ProductRatePlan__c zqu = [SELECT id, RatePlanSubType__c, RatePlanType__c, Name, zqu__ZProduct__r.zqu__SKU__c FROM zqu__ProductRatePlan__c WHERE id=:data.get('zqu__ProductRatePlan__c')];
        zqu.RatePlanType__c = 'Proration';
        zqu.RatePlanSubType__c = 'Standard';
        database.update(zqu);
        
        zqu__ProductRatePlanCharge__c prpc = [SELECT Id, zqu__UOM__c FROM zqu__ProductRatePlanCharge__c WHERE Id=:data.get('zqu__ProductRatePlanCharge__c')];
        prpc.zqu__UOM__c = 'Copy Weekday';
        database.update(prpc);
       
        
        System.runAs(u){            
        
        List <Case_Subscription__c> caseSubList = new List <Case_Subscription__c> ();
        
        Case_Subscription__c caseSub = [SELECT id, Subscription__c FROM Case_Subscription__c WHERE id=:data.get('Case_Subscription__c')];
        caseSub.Complaint_To__c = system.today()-9;
        database.update(caseSub);
        
        Test.stopTest();
        
        caseSubList.add(caseSub);  
         
        
        //initialize page and controllers
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', data.get('Case'));
        Case testCase = new Case(id=data.get('Case'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);    
        String error = '';
        try{
        compNewsCont.computePaperFee(caseSubList); 
          
        caseSubList.add(caseSub); 
        prpc.zqu__UOM__c = 'Copy Sat';
        compNewsCont.computePaperFee(caseSubList);
        
        caseSubList.add(caseSub);
        prpc.zqu__UOM__c = 'Copy Sun';
        compNewsCont.computePaperFee(caseSubList);
        
        //Publication__c pub = [SELECT Id, Published_Days__c FROM Publication__c WHERE Id=:data.get('Publication__c')];
        //pub.Published_Days__c = 'YYYYYYY';
        //database.update(pub);
        //compNewsCont.computePaperFee(caseSubList);
        }catch(exception e)
        {
            error = e.getMessage();
        }
        System.debug(error);
        
        }
        
    }   
    */
    /*
    static testMethod void testComputePaperFee5(){
        Map<string, Id> data = testData();
        User u = testUser();
        
        //Test.startTest(); 
        
        zqu__ProductRatePlan__c zqu = [SELECT id, RatePlanSubType__c, RatePlanType__c, Name, zqu__ZProduct__r.zqu__SKU__c FROM zqu__ProductRatePlan__c WHERE id=:data.get('zqu__ProductRatePlan__c')];
        zqu.RatePlanType__c = 'Proration';
        zqu.RatePlanSubType__c = 'Standard';
        database.update(zqu);
        
        zqu__ProductRatePlanCharge__c prpc = [SELECT Id, zqu__UOM__c FROM zqu__ProductRatePlanCharge__c WHERE Id=:data.get('zqu__ProductRatePlanCharge__c')];
        prpc.zqu__UOM__c = 'Copy Weekday';
        database.update(prpc);
       
        
        System.runAs(u){            
        
        List <Case_Subscription__c> caseSubList = new List <Case_Subscription__c> ();
        
        Case_Subscription__c caseSub = [SELECT id, Subscription__c FROM Case_Subscription__c WHERE id=:data.get('Case_Subscription__c')];
        caseSub.Complaint_To__c = system.today()-9;
        database.update(caseSub);
                
        Test.stopTest();
        
        caseSubList.add(caseSub);  
        caseSubList.add(caseSub);
        
        //initialize page and controllers
        PageReference pgRef = Page.ComplaintMagazineEditPage;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('id', data.get('Case'));
        Case testCase = new Case(id=data.get('Case'));
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
        ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);    
        String error = '';
        try{
        compNewsCont.computePaperFee(caseSubList); 
          
        prpc.zqu__UOM__c = 'Copy Sat';
        compNewsCont.computePaperFee(caseSubList);
        
        prpc.zqu__UOM__c = 'Copy Sun';
        compNewsCont.computePaperFee(caseSubList);
        
        Publication__c pub = [SELECT Id, Published_Days__c FROM Publication__c WHERE Id=:data.get('Publication__c')];
        pub.Published_Days__c = 'YYYYYYY';
        database.update(pub);
        compNewsCont.computePaperFee(caseSubList);
        }catch(exception e)
        {
            error = e.getMessage();
        }
        System.debug(error);
        
        }
        
    }   
    */
    /*
    static testMethod void testSave(){
        Map<string, Id> data = testData();
        
        //test.startTest();
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            
            Case testCase = [SELECT Id, AccountId FROM Case WHERE id=:data.get('Case')]; 
            testCase.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Complaint - Newspaper'].Id;
            database.update(testCase);
            
            ApexPages.currentPage().getParameters().put('id', data.get('Case'));
            ApexPages.currentPage().getParameters().put('RecordType', testCase.RecordTypeId);
            
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);   
            
            compNewsCont.objcase.Id = null;
            compNewsCont.objcase.contactId = data.get('Contact'); 
            
            Case_Subscription__c caseSub = [SELECT id, Subscription__c, Case__c FROM Case_Subscription__c WHERE id=:data.get('Case_Subscription__c')];
            system.assertNotEquals(caseSub.Id, null);
            
            ComplaintNewspaperController.CaseSubWrapper caseSubW = new ComplaintNewspaperController.CaseSubWrapper(caseSub);
            caseSubW.caseSubscription = caseSub;
            caseSubW.caseSubscription.Subscription__c = data.get('Zuora__Subscription__c2');
            caseSubW.caseSubscription.Case__c = testCase.Id;
            List<ComplaintNewspaperController.CaseSubWrapper> caseSubWList = new List<ComplaintNewspaperController.CaseSubWrapper>();
            caseSubWList.add(caseSubW);
            compNewsCont.CSubWrapperList = caseSubWList;
            
            system.assertEquals(caseSub.Subscription__c, compNewsCont.CSubWrapperList[0].CaseSubscription.Subscription__c);
            
            compNewsCont.save();
        test.StopTest();
    } 
    */
    /*
    static testMethod void testSave2(){
    
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
        
        List<Contact> con = TestDataFactory.createContactRecType(1,'Customer Contact');
        con[0].AccountId = acc.Id;
        con[0].Phone = '1234567';
        con[0].Address__c = addressRec.Id;
        //con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[0].Recipient_Indicator__c = true;
        database.insert(con);
        
        
        List<Package__c> pkg = TestDataFactory.createPackage(1);
        pkg[0].Subscription_Period__c = '15';            
        database.insert(pkg);
        
        //Case testCase = testDataFactory.createCase(1, 'Complaint Newspaper')[0];
        Case testCase = new Case();
        testCase.AccountId = acc.id;
        testCase.Origin = 'Phone';
        testCase.Priority = 'Medium';
        testCase.Date_Replaced__c = system.today();
        testCase.Status = 'New';
        testCase.RecordTypeId = [SELECT id, Name FROM RecordType WHERE sObjecttype = 'CASE' and Name = 'Complaint - Newspaper' LIMIT 1].Id;//ConstantsSLB.getKeyId('Case_Complaint Newspaper');
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
                cSub.Complaint_To__c = date.today()-2;
            }
            else{
                cSub.Complaint_From__c = date.today()-21;
                cSub.Complaint_To__c = date.today()-20;    
            }
        }      
        database.insert(caseSub);
        
        //test.startTest();
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
            caseSubW.caseSubscription.Complaint_To__c = date.today()-30;
            caseSubW.caseSubscription.Complaint_To__c = date.today()-60;
            caseSubW.caseSubscription.Subscription__c = Subs[0].Id;
            caseSubW.caseSubscription.Case__c = testCase.Id;
            //caseSubW.caseVendorSubscription = cVenSub;
            List<ComplaintNewspaperController.CaseSubWrapper> caseSubWList = new List<ComplaintNewspaperController.CaseSubWrapper>();
            caseSubWList.add(caseSubW);
            compNewsCont.CSubWrapperList = caseSubWList;
            
            compNewsCont.save();
        test.StopTest();
    } 
    */
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
    /*
    static testMethod void testSave4(){
    
        //defaultCustomSetting();
    
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];//new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor'));
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
        con[0].RecordTypeId = [SELECT Id from RecordType WHERE sObjectType = 'Contact' AND Name = 'Customer Contact'].Id; //ConstantsSLB.getKeyId('Contact_Customer Contact');
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
                cSub.Complaint_To__c = date.today()-2;
            }
            else{
                cSub.Complaint_From__c = date.today()-21;
                cSub.Complaint_To__c = date.today()-20;    
            }
        }      
        database.insert(caseSub);
        
        //test.startTest();
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            
            ApexPages.currentPage().getParameters().put('id', testCase.Id);
            ApexPages.currentPage().getParameters().put('RecordType', testCase.RecordTypeId);
            ApexPages.currentPage().getParameters().put('index', '0');
            
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(testCase);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);   
            
            compNewsCont.objcase.Id = null;
            compNewsCont.objcase.contactId = con[0].Id; 
            
            ComplaintNewspaperController.CaseSubWrapper caseSubW = new ComplaintNewspaperController.CaseSubWrapper(caseSub[0]);
            caseSubW.caseSubscription = caseSub[0];
            caseSubW.caseSubscription.Complaint_To__c = date.today()-30;
            caseSubW.caseSubscription.Complaint_To__c = date.today()-60;
            caseSubW.caseSubscription.Subscription__c = Subs[0].Id;
            caseSubW.caseSubscription.Case__c = testCase.Id;
            //caseSubW.caseVendorSubscription = cVenSub;
            List<ComplaintNewspaperController.CaseSubWrapper> caseSubWList = new List<ComplaintNewspaperController.CaseSubWrapper>();
            //caseSubWList.add(caseSubW);
            compNewsCont.CSubWrapperList = caseSubWList;
            //compNewsCont.CSubWrapperList.counterWrap = 0;
            
            compNewsCont.save();
            //compNewsCont.removeRows();
        test.StopTest();
    } 
    */
    /*
    static testMethod void testCreateWithAccountNotOverlappingPeriod(){
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];//new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
        acc.Vendor_Code__c = '123';
        insert acc;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        
        List<Contact> con = TestDataFactory.createContact(1);
        con[0].AccountId = acc.Id;
        con[0].Phone = '1234567';
        con[0].Address__c = addressRec.Id;
        con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con[0].Recipient_Indicator__c = true;
        insert con;
        
        Zuora__CustomerAccount__c defaultPayment = TestDataFactory.createBillingAccount(1)[0]; 
        defaultPayment.Zuora__DefaultPaymentMethod__c = 'Other'; 
        defaultPayment.Zuora__Account__c = acc.id; 
        insert defaultPayment; 
        
        List<Package__c> pkg = TestDataFactory.createPackage(1);
        pkg[0].Subscription_Period__c = '15';            
        insert pkg;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Recipient_Contact__c = con[0].Id;
        order.Informed_Customer__c = True;
        order.Subscriber_charge__c = 100;
        insert order;   
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0]; 
        oli.Order__c = order.Id; 
        oli.Main_Package_ID__c = pkg[0].id; 
        
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
        
        Case testCase = new Case();
        testCase.AccountId = acc.id;
        testCase.Origin = 'Phone';
        testCase.Priority = 'Medium';
        testCase.Date_Replaced__c = system.today();
        testCase.Status = 'New';
        //testCase.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Complaint - Newspaper'].Id;
        insert testCase;
        
        Case_Subscription__c cSub = new Case_Subscription__c();
        cSub.Account__c = acc.id;
        cSub.Address__c = addressRec.Id;
        cSub.Subscription__c = Subs[0].id;
        cSub.Complaint_From__c = system.today()-15;
        cSub.Complaint_To__c = system.today()-10;
        cSub.Case__c = testCase.id;
        cSub.Legacy_Create_Date__c = String.valueof(system.today());
        insert cSub;  
        
        List<Subscription_Vendor__c> subVen = TestDataFactory.createSubscriptionVendor(1);
        subVen[0].Recipient__c = con[0].Id;
        subVen[0].Vendor__c = null;
        insert subVen;  
        
        Case_Vendor_Subscription__c caseVen = new Case_Vendor_Subscription__c();
        caseVen.Subscription_Vendor__c = subVen[0].id;
        caseVen.Complaint_From__c = null;
        caseVen.Complaint_To__c = null;
        caseVen.Case__c = testCase.id;
        caseVen.Address__c = addressRec.Id;
        insert caseVen;   
       
        User u = testUser();
        
        Test.startTest(); //CHA 22April2016
        
        System.runAS(u){
            
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            Apexpages.currentpage().getParameters().put('index', '0');
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('contactId', con[0].Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Case());
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            ComplaintNewspaperController.CaseSubWrapper caseSubW = new ComplaintNewspaperController.CaseSubWrapper(cSub);
            
            caseSubW.caseSubscription.Subscription__c = Subs[0].id;
            
            caseSubW.caseVendorSubscription = caseVen;
            
            List<ComplaintNewspaperController.CaseSubWrapper> caseSubWList = new List<ComplaintNewspaperController.CaseSubWrapper>();
            caseSubWList.add(caseSubW);
            
            compNewsCont.CSubWrapperList = caseSubWList;
            
            String error = '';
            try{
                compNewsCont.save();
            }catch(exception e){
                error = e.getMessage();
            }
            
            System.assertEquals(error, '');      
       }
        
        Test.stopTest();
    }  
    */
    /*
    static testMethod void testcomputeCreditAmount(){
        Map<string, Id> data = testData();
        
        List<Case_Subscription__c> caseSubs = [SELECT Id, Complaint_Copies__c, Replacement_Copies__c, Subscription__c, Case__c, Complaint_From__c, Complaint_To__c, Replace_From__c, Replace_To__c FROM Case_Subscription__c WHERE id=:data.get('Case_Subscription__c')];
        system.assertNotEquals(caseSubs[0].Complaint_Copies__c, null);
        system.assertNotEquals(caseSubs[0].Complaint_From__c, null);
        system.assertNotEquals(caseSubs[0].Complaint_To__c, null);
        
        //test.startTest();
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Case());
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            compNewsCont.computeCreditAmount(caseSubs);
        test.stopTest();
    }
    */
    /*
    static testMethod void newTest001(){
       
        Map<string, Id> data = testData(); 
        
        User u = testUser();
        
        //Test.startTest();
        
        System.runAS(u){
        
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(2)[1];
            prdRatePlan.zqu__ZProduct__c = data.get('zqu__ZProduct__c');
            prdRatePlan.RatePlanType__c = 'Bill Plan'; 
            prdRatePlan.RatePlanSubType__c = 'Standard'; 
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            insert prdRatePlan;
            
            //Package_Item__c packItem = new Package_Item__c(id=data.get('Package_Item__c'));   
            //packItem.Package__c = pkg.id;
            //database.update(packItem);
            
            List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
            zSubs[0].Zuora__Account__c = data.get('Account');
            zSubs[0].Order_Line_Item_Number__c = data.get('Order_Line_Item__c');
            zSubs[0].Order_Number__c = data.get('Order__c');
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
            zSubs[0].Zuora__CustomerAccount__c = data.get('Zuora__CustomerAccount__c');
            zSubs[0].Sponsor_1__c = true;
            zSubs[0].Name = 'Subscription 1';
            zSubs[0].Main_Package__c = data.get('Package__c');
            zSubs[0].Zuora__SubscriptionStartDate__c = null;
            zSubs[0].Term_Length__c = 30;
            zsubs[0].Zuora__SubscriptionEndDate__c = null;
            insert zSubs;    
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
            cas.AccountId = data.get('Account');
            database.insert(cas);
            
            //CHA 22April2016
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '123';
            database.insert(postal);
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            database.insert(addressRec);
            //CHA 22April2016
            
            Case_Subscription__c caseSub = new Case_Subscription__c();
            caseSub.Subscription__c = zSubs[0].Id;
            caseSub.Case__c = cas.Id;
            caseSub.Account__c = data.get('Account');
            caseSub.Complaint_From__c = date.today()-10; //CHA 22April2016
            caseSub.Complaint_To__c = date.today()-5; //CHA 22April2016
            caseSub.Address__c = addressRec.Id; //CHA 22April2016
            database.insert(caseSub);
            
            
            Package_Item__c packItem = [SELECT id, Package__c FROM Package_Item__c WHERE id=:data.get('Package_Item__c') AND Package__c != null];
            database.delete(packItem); 
            
            Package_Item__c packItems = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItems.Package__c = data.get('Package__c');
            packItems.Product_Rate_Plan__c = data.get('zqu__ProductRatePlan__c');
            database.insert(packItems);
            
            system.assertNotEquals(packItems.Package__c, null);
           
            //initialize page and controllers
            PageReference pgRef = Page.ComplaintMagazineEditPage;
            Test.setCurrentPage(pgRef);
            Apexpages.currentpage().getParameters().put('index', '0');
            ApexPages.currentPage().getParameters().put('accountId', data.get('Account'));
            ApexPages.currentPage().getParameters().put('contactId', data.get('Contact'));
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Case());
            //ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(cas);
            ComplaintNewspaperController compNewsCont = new ComplaintNewspaperController (stdCtrlr);
            
            compNewsCont.goodwillCopiesSelected = '';
            compNewsCont.subSelected5 ='5'; 
            compNewsCont.isDirect = true;
            compNewsCont.getGoodwillAmount();
       }
        
        Test.stopTest();
    }  
    */
    
   static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        /*
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        */
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;
        
        Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
            insert cirPlannerSchedule;
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
        batchInterfaceSetting.Name = 'Endpoint Delegator';
        batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting;
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c();
        delType.Name = 'A';
        delType.Default_Delivery_Charge_Type__c = 'C';
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c();
        delCharge.Name ='AC';
        delCharge.Vendor_Credit__c = 9.00;
        delCharge.Subscriber_Charge__c = 9.00;
        insert delCharge;
    } 
}