/**
@Author Michiko Santoyo
@name ChangeInAddressExtensionNewTest
@CreateDate 10/23/2014
@modified by Emmanuel Flores
@modified date 06/19/2015 
@Description Test Class for ChangeInAddressExtensionNew class
@Version <1.0>
@reference
*/  
@isTest (seeAllData= True)
private class ChangeInAddressExtensionNewTest {   
    
    /**
    * Initial Test Method
    * @name testChangeInAddress
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */  
    static testMethod void testChangeInAddress(){
        
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
            UserName='caien1@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(u) { 
            
            List<Account> accList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            List<Case> caseList = new List<Case>(); 
            List<Package__c> packageList = new List<Package__c>();
            List<Zuora__Subscription__c> zuoSubList = new List<Zuora__Subscription__c>();
            List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
            List<Order__c> orderList = new List<Order__c>();
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            
            //create Account Records
            accList = TestDataFactory.createAccount(1, 'Vendor Subscriber');
            accList[0].NRIC__c = 'T1234567R';
            insert accList;
            
            //create Main Package Records
            packageList = TestDataFactory.createPackage(1);
            insert packageList;
            
            //create Billing Account Records
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = accList[0].Id;
            insert billAcc;
            
            //START UD-3347 22Mar2016 Added By C. Lin
            Zone__c zoneRec = TestDataFactory.createZone(1)[0];
            zoneRec.Name = 'XXX';
            database.insert(zoneRec);
            
            Country__c countryRec = TestDataFactory.createCountry(1)[0];
            countryRec.Code__c = 'XX';
            countryRec.Country_Name__c = 'Singapore';
            countryRec.Zone__c = zoneRec.Id;
            database.insert(countryRec);
            //END UD-3347 22Mar2016 Added By C. Lin
            
            //create Address Records
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
            insert addressRec;
            
            //create Contact Records
            conList = TestDataFactory.createContact(1);
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            conList[0].AccountId = accList[0].Id;
            conList[0].Address__c = addressRec.Id;
            conList[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
            insert conList;
            
            //create Order Records
            orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].Id;
            orderList[0].Informed_Customer__c = TRUE;
            orderList[0].Recipient_Contact__c = conList[0].Id;
            insert orderList ; 
            
            //insert Case Records
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderList[0].Id;
            
            //ChangeInAddress
            Case cCase = new Case();
            conList[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');
            cCase.Order__c = orderList[0].Id;
            cCase.Contact_To_Update__c = conList[0].id;
            cCase.AccountId = accList[0].id;
            cCase.Change_of_Address_Type__c = 'Change of Billing address';
            insert cCase;                        
           
            
            //added by George Santos - 1/30/2015
            Subscription_Vendor__c subvend = new Subscription_Vendor__c();
            subvend.Account__c = accList[0].id;
            subvend.Recipient__c = conList[0].id;
            subvend.Status__c = 'Active';
            insert subvend;
            
            //START - added by George Santos for not Vendor Type Account - 1/30/2015
            List<Account> accList2 = TestDataFactory.createAccount(1, 'Direct Corporate');
            insert accList2;
            
            List<Contact> conList2 = TestDataFactory.createContact(1);
            conList2[0].AccountId = accList2[0].id;
            conList2[0].Recipient_Indicator__C = TRUE;
            conList2[0].Billing_Indicator__c = true;//ADD 02/25
            insert conList2;
            
            List<Order__c> orderList2 = TestDataFactory.createOrder(1);
            orderList2[0].Account__c = accList2[0].Id;
            orderList2[0].Informed_Customer__c = TRUE;
            orderList2[0].Recipient_Contact__c = conList2[0].Id;
            orderList2[0].Billing_Contact__c = conList2[0].Id;//ADD 02/25
            insert orderList2 ;

            Case cCase2 = new Case();
            conList2[0].RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');
            cCase2.Order__c = orderList2[0].Id;
            cCase2.Contact_To_Update__c = conList2[0].id;
            cCase2.AccountId = accList2[0].id;
            cCase2.Change_of_Address_Type__c =  'Change of Delivery Address – Local to Local';
            insert cCase2;
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList2[0].id;
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;
            orderLineItemList[0].start_Date__c = date.Today()+1;
            insert orderLineItemList;

            Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
            bill.Zuora__Account__c = accList2[0].Id;
            insert bill;//ADD 02/25
            
            Zuora__Subscription__c zsub = new Zuora__Subscription__c();
            zsub.name = 'S00000000';        
            zsub.Zuora__Account__c = accList2[0].id;
            zsub.Zuora__Status__c = 'Active';
            //zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
            //zSub.Order_Line_Item_Number_1__c = orderLineItemList[0].id;
            zsub.Recipient_Contact__c = conList2[0].id;
            zSub.Main_Package_1__c = packageList[0].id;
            zSub.Main_Package__c = packageList[0].id;
            zSub.Zuora__CustomerAccount__c = bill.id; //ADD 02/25
            insert zsub;
            
          /*  Case_Subscription__c caseSubList = TestDataFactory.createCaseSubscription(1)[0];
            caseSubList.Account__c = accList2[0].Id;
            caseSubList.Case__c = cCase2.Id;
            caseSubList.Subscription__c = zsub.Id; 
            insert caseSubList;
          */  
            
            //END - added by George Santos - 1/30/2015
            
            //modified by George Santos - 2/4/2014
            Test.startTest();
            String error = '';
            try{
                PageReference pRef5 = Page.ChangeInAddressCaseNewPage;
                pRef5.getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, accList2[0].Id);
                Test.setCurrentPage(pRef5);
                Case newCase = new Case();    
                newCase.AccountId = accList2[0].id;
                ApexPages.StandardController stdController5 = new ApexPages.Standardcontroller(newCase);
                ChangeInAddressExtensionNew CIA5 = new ChangeInAddressExtensionNew (stdController5);
                //CIA5.executeOnload();
                
                PageReference pRef = Page.ChangeInAddressCaseNewPage;
                pRef.getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, accList[0].Id);
                Test.setCurrentPage(pRef);
                ApexPages.StandardController stdController = new ApexPages.Standardcontroller(cCase);
                ChangeInAddressExtensionNew CIA = new ChangeInAddressExtensionNew (stdController);
                CIA.compareAddress();
                CIA.getSubscriptions();
                CIA.populatePOPStartDate();
                CIA.checkAllSubs();
                CIA.checkAddressType();
                CIA.createAssignment();
                CIA.cancel();
                CIA.save();
                
                //added by George Santos for not Vendor Account - 1/30/2015
                PageReference pRef2 = Page.ChangeInAddressCaseNewPage;
                pRef2.getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, accList2[0].Id);
                ApexPages.StandardController stdController3 = new ApexPages.Standardcontroller(cCase2);
                ChangeInAddressExtensionNew CIA3 = new ChangeInAddressExtensionNew (stdController3);                              
                Test.setCurrentPage(pRef2);
                CIA3.getSubscriptions();
                CIA3.populatePOPStartDate();
                CIA3.compareAddress();
                CIA3.checkAllSubs();
                CIA3.checkAddressType();
                CIA3.createAssignment();
                CIA3.cancel();
                CIA3.save();
                
                ApexPages.StandardController stdController1 = new ApexPages.Standardcontroller(cCase);
                ChangeInAddressExtensionNew CIA1 = new ChangeInAddressExtensionNew (stdController1);
                CIA1.getSubscriptions();
                CIA1.populatePOPStartDate();
                CIA1.changeInAddress.Effective_Date__c = Date.today().addDays(-2);
                CIA1.changeInAddress.POP_Start_Date__c = date.today()-3; 
                CIA1.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;              
                //CIA1.changeInAddress.New_Address__c = accList[0].Id;
                CIA1.createAssignment(); 
                CIA1.save();
                
                ApexPages.StandardController stdController2 = new ApexPages.Standardcontroller(cas);
                ChangeInAddressExtensionNew CIA2 = new ChangeInAddressExtensionNew (stdController2);
                CIA2.getSubscriptions();
                CIA2.populatePOPStartDate();
                CIA2.changeInAddress.Effective_Date__c = Date.today();
                CIA2.changeInAddress.POP_Start_Date__c = date.today()-1; 
                CIA2.changeInAddress.ContactId = conList2[0].Id;
                CIA2.changeInAddress.Category__c = GlobalVariableClass.CASEDIGITAL;
                CIA2.changeInAddress.Sub_Category__c = 'Change of Address';                
                CIA2.save(); 
            }catch(exception e)
            {
                error = e.getMessage() + ' ' + e.getStackTraceString();
            }
            Test.stopTest();
            //Assert if expected value is equal to actual value
            System.assertEquals('', error);
        }
    }
    

    /**
    * Test method for createCaseSubscription() for Vendor Subscription account
    * @name testCreateCaseSubSelectSubTrueVendorSub
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
   static testMethod void testCreateCaseSubSelectSubTrueVendorSub()
    {
        //Create 'Vendor Subscriber' Account
        Account venSub = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        insert venSub;
        
        //Create Vendor Account
        Account vendor = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert vendor;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = venSub.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = venSub.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, venSub.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        //controller.changeInAddress = cas;
        //controller.subWrapperList.add(subWrap);
        
        String error = '';
        try{
            controller.getSubscriptions();
            controller.subWrapperList = subWrapperList;
            controller.createCaseSubscription();    }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }
    
    static testMethod void testCreateCaseSubSelectTrueVendorBillDeliverAd()
    {
        //Create 'Vendor Subscriber' Account
        Account venSub = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        insert venSub;
        
        //Create Vendor Account
        Account vendor = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert vendor;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = venSub.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = venSub.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, venSub.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = false;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
 
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD; 
        controller.changeInAddress.Vendor__c =venSub.Id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.New_Address__c = addr.Id;
        controller.subWrapperList = subWrapperList;       
        
        //controller.changeInAddress = cas;
        //controller.subWrapperList.add(subWrap);
        
        String error = '';
        try{
            controller.getSubscriptions();
            controller.subWrapperList = subWrapperList;            
            controller.createCaseSubscription();    }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }

static testMethod void testCreateCaseSubSelectTrueNonVendorBillDeliverAd()
    {       
        
        //Create Vendor Account
        Account vendor = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert vendor;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = vendor.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = vendor.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, vendor.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = false;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
 
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD; 
        controller.changeInAddress.Vendor__c = vendor.Id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.New_Address__c = addr.Id;
        controller.subWrapperList = subWrapperList;       
        
        //controller.changeInAddress = cas;
        //controller.subWrapperList.add(subWrap);
        
        String error = '';
        try{
            controller.getSubscriptions();
            controller.subWrapperList = subWrapperList;            
            controller.createCaseSubscription();    }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }

    /**
    * Test method for createCaseSubscription() for Non-Vendor;
    * @name testCreateCaseSubSelectSubTrueNonVendor
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testCreateCaseSubSelectSubTrueNonVendor()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        Recordtype rec = [SELECT ID, Name FROM RecordType WHERE name = 'Vendor Subscriber'];
        acc.RecordType = rec;
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();        
        Account acct = new Account();
        
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        //controller.changeInAddress = cas;
        //controller.subWrapperList.add(subWrap);
        
        String error = '';
        try{
            controller.getSubscriptions();
            controller.subWrapperList = subWrapperList;
            controller.createCaseSubscription();    }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);  
    }
    
    /**
    * Test method for CompareAddressCheck = true | Returns null
    * @name testCreateAssignmentDelivery
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testCreateAssignmentDelivery()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address'); 
        cas.Change_of_Address_Type__c = 'Change of Billing address';   
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        
        Subscription_Vendor__c subvend = new Subscription_Vendor__c();
        subvend.Account__c = acc.id;
        subvend.Recipient__c = con.id;
        subvend.Status__c = 'Active';
        insert subvend;
        
       
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
         
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.DELIVERYADDLOC; 
        controller.changeInAddress.Vendor__c = acc.Id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.New_Address__c = addr.Id;
        controller.subWrapperList = subWrapperList;
        String error = '';
        try{
            controller.createAssignment();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);controller.createAssignment();    
    }
  
    /**
    * Test method for Address Type = Change Vendor|Vendor != null | Effective Date!= null
    * @name testChangeVendorNotNull
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testChangeVendorNotNull()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() + 1;
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.getSubscriptions();
        controller.populatePOPStartDate();
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR; 
        controller.changeInAddress.Vendor__c = acc.Id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        //controller.subWrapperList.add(subWrap);
        controller.subWrapperList = subWrapperList;
        controller.changeInAddress.ContactId = con.Id;
        controller.changeInAddress.Category__c = GlobalVariableClass.CASEDIGITAL;
        controller.changeInAddress.Sub_Category__c = 'Change of Address';
        String error = '';
        try{            
            controller.save();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }
    
    //
    /**
    * Test method for contact to update = null | Returns null
    * @name testSaveContactNull
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testSaveContactNull()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        //cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today()+1; 
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.getSubscriptions();
        controller.populatePOPStartDate();
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR; 
        controller.changeInAddress.Vendor__c = acc.Id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.Contact_To_Update__c = null;  
        controller.changeInAddress.ContactId = con.Id;
        controller.changeInAddress.Category__c = GlobalVariableClass.CASEDIGITAL;
        controller.changeInAddress.Sub_Category__c = 'Change of Address';              
        //controller.subWrapperList.add(subWrap);
        controller.subWrapperList = subWrapperList;
        String error = '';
        try{
            controller.save();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }

    
    /**
    * Test method for Vendor = null | Returns null
    * @name testSaveVendorNull
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testSaveVendorNull()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; 
        insert billAcc;
        
        Package__c pack = testDataFactory.createPackage(1)[0];
        insert pack;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today()+1;
        insert cas;
        
        Zuora__Subscription__c zsub = new Zuora__Subscription__c();
        zsub.name = 'S00000000';        
        zsub.Zuora__Account__c = acc.id;
        zsub.Zuora__Status__c = 'Active';
        //zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
        //zSub.Order_Line_Item_Number_1__c = orderLineItemList[0].id;
        zsub.Recipient_Contact__c = con.id;
        zSub.Main_Package_1__c = pack.id;
        //zSub.Main_Package__c = packageList[0].id;
        zSub.Zuora__CustomerAccount__c = billAcc.id; //ADD 02/25
        zsub.Vendor_1__c = acc.Id;
        insert zsub;                
        
        Subscription_Vendor__c subvend = testDataFactory.createSubscriptionVendor(1)[0];
        subvend.Account__c = acc.id;
        subvend.Recipient__c = con.id;
        subvend.Status__c = 'Active';
        subvend.Vendor__c = acc.Id;
        subvend.Subscription_Stop_Date__c = date.today()+1;
        insert subvend;
        
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));        
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR; 
        controller.changeInAddress.Vendor__c = null;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.Contact_To_Update__c = con.Id;
        controller.changeInAddress.ContactId = con.Id;
        controller.changeInAddress.Category__c = GlobalVariableClass.CASEDIGITAL;
        controller.changeInAddress.Sub_Category__c = 'Change of Address';
        String error = '';
        try{
            controller.getSubscriptions();
            controller.subWrapperList = subWrapperList;
            controller.populatePOPStartDate();
            controller.save();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }
    
    static testMethod void testSaveVendorNull1()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert acc;
        
        Account acc1 = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert acc1;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Vendor Contact');//START/END CCB.002 Modified by: Francis Benzon //START END UD-3347 22Mar2016 Added By C. Lin
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; 
        insert billAcc;
        
        Package__c pack = testDataFactory.createPackage(1)[0];
        insert pack;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today()+1;
        insert cas;
        
        Zuora__Subscription__c zsub = new Zuora__Subscription__c();
        zsub.name = 'S00000000';        
        zsub.Zuora__Account__c = acc.id;
        zsub.Zuora__Status__c = 'Active';
        //zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
        //zSub.Order_Line_Item_Number_1__c = orderLineItemList[0].id;
        zsub.Recipient_Contact__c = con.id;
        zSub.Main_Package_1__c = pack.id;
        //zSub.Main_Package__c = packageList[0].id;
        zSub.Zuora__CustomerAccount__c = billAcc.id; //ADD 02/25
        zsub.Vendor_1__c = acc.Id;
        insert zsub;
        
        Vendor_Allocation__c venAlloc = testDataFactory.createVendorAlloc(1)[0];
        venAlloc.Vendor_Account__c = acc1.Id;
        venAlloc.SingPost_Address__c = postal.Id;
        venAlloc.Effective_End_Date__c = date.today()+1;
        venAlloc.Allocated__c = true;
        venAlloc.Operated__c = FALSE;
        insert venAlloc;

        
        Subscription_Vendor__c subvend = testDataFactory.createSubscriptionVendor(1)[0];
        subvend.Account__c = acc.id;
        subvend.Recipient__c = con.id;
        subvend.Status__c = 'Active';
        subvend.Vendor__c = acc.Id;
        subvend.Subscription_Stop_Date__c = date.today()+1;
        insert subvend;
        
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));        
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR; 
        controller.changeInAddress.Vendor__c = acc.Id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.Contact_To_Update__c = con.Id;
        controller.changeInAddress.ContactId = con.Id;
        controller.changeInAddress.Category__c = GlobalVariableClass.CASEDIGITAL;
        controller.changeInAddress.Sub_Category__c = 'Change of Address';
        String error = '';
        try{
            controller.getSubscriptions();
            controller.subWrapperList = subWrapperList;
            controller.populatePOPStartDate();
            controller.save();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }
    
  /*  static testmethod void testSaveInvalidVendor()
    { 
    
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
            UserName='caien1@test.com'
        );
        
        //The test will run as the user created.
        System.runAs(u) { 
            
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Account acc1 = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc1;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        insert postal;
       
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        insert addr;
        
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;        
        
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; 
        insert billAcc;
        
        Package__c pack = testDataFactory.createPackage(1)[0];
        insert pack;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.Account__c = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today()+1;
        insert cas;
        
        Zuora__Subscription__c zsub = new Zuora__Subscription__c();
        zsub.name = 'S00000000';        
        zsub.Zuora__Account__c = acc.id;
        zsub.Zuora__Status__c = 'Active';
        //zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
        //zSub.Order_Line_Item_Number_1__c = orderLineItemList[0].id;
        zsub.Recipient_Contact__c = con.id;
        zSub.Main_Package_1__c = pack.id;
        //zSub.Main_Package__c = packageList[0].id;
        zSub.Zuora__CustomerAccount__c = billAcc.id; //ADD 02/25
        zsub.Vendor_1__c = acc.Id;
        insert zsub;

        
        Subscription_Vendor__c subvend = testDataFactory.createSubscriptionVendor(1)[0];
        subvend.Account__c = acc.id;
        subvend.Recipient__c = con.id;
        subvend.Status__c = 'Active';
        subvend.Vendor__c = acc.Id;
        subvend.Subscription_Stop_Date__c = date.today()+1;
        insert subvend;
        
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));        
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR; 
        controller.changeInAddress.Vendor__c = acc1.Id;
        controller.changeInAddress.Contact_To_Update__c = con.Id; 
        controller.changeInAddress.Effective_Date__c  = date.today()+1;               
        
        String error = '';
        try{
            controller.subWrapperList = subWrapperList;
            controller.getSubscriptions();            
            controller.populatePOPStartDate();
            controller.save();               
            }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }
    }
    */
    /**
    *SubWrapperList is not empty and Address Type = Delivery Add. Loc.
    * @name testSaveSubWrapListNotEmpty
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testSaveSubWrapListNotEmpty()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.getSubscriptions();
        controller.populatePOPStartDate();
        controller.changeInAddress.Change_of_Address_Type__c =  GlobalVariableClass.DELIVERYADDLOC; 
        controller.changeInAddress.Vendor__c = acc.id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        //controller.subWrapperList.add(subWrap);
        controller.subWrapperList = subWrapperList;
        String error = '';
        try{
            controller.save();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error); controller.save();
    }
    
    //START UD-3347 22Mar2016 Added By C. Lin
    /**
    *SubWrapperList is empty and Address Type = Delivery Add. Loc.
    * @name testSaveSubWrapListEmpty
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testSaveSubWrapListEmpty()
    {
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today()+1;
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_CONTACTID, con.id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.DEFPARID, cas.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.getSubscriptions();
        controller.changeInAddress.Change_of_Address_Type__c =  GlobalVariableClass.BILLINGADD; 
        controller.changeInAddress.AccountId = acc.id;
        controller.changeInAddress.ContactId = con.id;
        controller.changeInAddress.Effective_Date__c  = date.today() + 2;
        controller.changeInAddress.POP_Start_Date__c = Date.today();
        controller.changeInAddress.Category__c = 'Subscription Request';
        controller.changeInAddress.Sub_Category__c = 'Change of Address';
        controller.changeInAddress.Contact_To_Update__c = con.id;
        controller.changeInAddress.New_Address__c = addr.Id;
        controller.subWrapperList = subWrapperList;
        
        String error = '';
        try{
            controller.save();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error); controller.save();
    }
    
    /**
    *Waiting For Vendor Assignment Case existing
    * @name testWithWFVACase
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testWithWFVACase()
    {
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.ContactId = con.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today()+1;
        cas.Sub_Status__c = 'Waiting For Vendor Assignment';
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_CONTACTID, con.id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.DEFPARID, cas.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.getSubscriptions();
        controller.changeInAddress.Change_of_Address_Type__c =  GlobalVariableClass.BILLINGADD; 
        controller.changeInAddress.AccountId = acc.id;
        controller.changeInAddress.ContactId = con.id;
        controller.changeInAddress.Effective_Date__c  = date.today() + 2;
        controller.changeInAddress.POP_Start_Date__c = Date.today();
        controller.changeInAddress.Category__c = 'Subscription Request';
        controller.changeInAddress.Sub_Category__c = 'Change of Address';
        controller.changeInAddress.Contact_To_Update__c = con.id;
        controller.changeInAddress.New_Address__c = addr.Id;
        controller.subWrapperList = subWrapperList;
        
        String error = '';
        try{
            controller.save();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error); controller.save();
    }
    //END UD-3347 22Mar2016 Added By C. Lin
    
    /**
    * cas is empty and Effective Date = null
    * @name testEffectiveDateIsNull
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testEffectiveDateIsNull()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.getSubscriptions();
        controller.populatePOPStartDate();
        controller.changeInAddress.Change_of_Address_Type__c =  GlobalVariableClass.DELIVERYADDLOC; 
        controller.changeInAddress.Vendor__c = acc.id;
        controller.changeInAddress.Effective_Date__c  = null;
        //controller.subWrapperList.add(subWrap);
        controller.subWrapperList = subWrapperList;
        String error = '';
        try{
            controller.save();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }
    
    /**
    * cas is empty and Effective Date = null
    * @name testCompareAddress
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testCompareAddress()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        //ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        //subWrap.selectSub = true;
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.changeInAddress.Change_of_Address_Type__c =  GlobalVariableClass.DELIVERYADDLOC; 
        controller.changeInAddress.Vendor__c = acc.id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.New_Address__c = addr.Id;
        //controller.subWrapperList.add(subWrap);
        String error = '';
        try{
            controller.compareAddress();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);controller.compareAddress();
    }
        
    /**
    * Test class that calls the checkAddressType  method
    * @name testCheckAddressType
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
  static testMethod void testCheckAddressType()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        //ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        //subWrap.selectSub = true;
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.changeInAddress.Change_of_Address_Type__c =  GlobalVariableClass.DELIVERYADDLOC; 
        controller.changeInAddress.Vendor__c = acc.id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.New_Address__c = addr.Id;
        controller.changeInAddress.contactId = con.Id;
        //controller.subWrapperList.add(subWrap);
        String error = '';
        try{
            controller.save();       
            controller.checkAddressType();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
        
    }
    
    /**
    * Check Contact Eligibility| Add Type = Billing| Billing Indicator = false
    * @name testCheckContactEligibilityBilling
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testCheckContactEligibilityBilling()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Billing_Indicator__c = false;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        //ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        //subWrap.selectSub = true;
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.BILLINGADD;
        controller.changeInAddress.Vendor__c = acc.id;
        controller.changeInAddress.Contact_to_Update__c = con.id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.New_Address__c = addr.Id;
        //controller.subWrapperList.add(subWrap);
        String error = '';
        try{
            controller.checkContactEligibility();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }
    
    /**
    * Check Contact Eligibility| Add Type = Delivery| Recipient Indicator = false
    * @name testCheckContactEligibilityDelivery
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testCheckContactEligibilityDelivery()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Billing_Indicator__c = false;
        con.Recipient_Indicator__c = false;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        //ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        //subWrap.selectSub = true;
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.DELIVERYADDLOC;
        controller.changeInAddress.Vendor__c = acc.id;
        controller.changeInAddress.Contact_to_Update__c = con.id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.New_Address__c = addr.Id;
        //controller.subWrapperList.add(subWrap);
        String error = '';
        try{
            controller.checkContactEligibility();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
        
    }
    
    
    /**
    * Check Contact Eligibility| Add Type = BillDeliveryAdd| Recipient Indicator = false
    * @name testCheckContactEligibilityBillDelivery
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testCheckContactEligibilityBillDelivery()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Billing_Indicator__c = false;
        con.Recipient_Indicator__c = false;
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        //ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        //subWrap.selectSub = true;
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
        controller.changeInAddress.Vendor__c = acc.id;
        controller.changeInAddress.Contact_to_Update__c = con.id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.New_Address__c = addr.Id;
        
        //controller.subWrapperList.add(subWrap);
        String error = '';
        try{

            controller.checkContactEligibility();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }      
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
        
    }
    
    
    /**
    * Check Populate Pop Start Date| SubWrapList NOT empty
    * @name testPopulatePopStartDate
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testPopulatePopStartDate()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        //Create Vendor Account
        Account accVen = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert accVen;
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Billing Account Records
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Billing_Indicator__c = false;
        con.Recipient_Indicator__c = false;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        packageList[0].Package_Type__c = 'Grace Period';  
        packageList[0].Subscription_Period__c = '1'; 
        insert packageList;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;                
        
        Zuora__Subscription__c subList= testDataFactory.createSubscription(1)[0];
        subList.name = 'S00000000';        
        subList.Zuora__Account__c = acc.id;
        subList.Zuora__Status__c = 'Active';
       // zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
        subList.Recipient_Contact__c = con.id;
        subList.Main_Package_1__c = packageList[0].Id;
        subList.Main_Package__c = packageList[0].id;
        //subList.Subscription_Type__c = 'Publication';
        subList.Zuora__CustomerAccount__c = billAcc.id;
        //subList.Zuora__SubscriptionEndDate__c = date.Today()+5;
        //subList.Zuora__TermSettingType__c = 'TERMED';
        //subList.Vendor_1__c = acc.Id;
        //subList.Zuora__TermSettingType__c = 'EVERGREEN';
        insert subList;
        
        Subscription_Vendor__c subvend = testDataFactory.createSubscriptionVendor(1)[0];
        subvend.Account__c = acc.id;
        subvend.Recipient__c = con.id;
        subvend.Status__c = 'Active';
        subvend.Vendor__c = acc.Id;
        subvend.Subscription_Stop_Date__c = date.today()+1;
        insert subvend;
        
        
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Delivery';
        zProduct.ProductPlatform__c = 'print';
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Proration';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        Product_Family__c productFamily = TestdataFactory.createProductFamily(1)[0];
        insert productFamily;

        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.PublicationCode__c = 'Code';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c packageItemList = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItemList.Package__c = packageList[0].id;
        packageItemList.Product_Family__c = productFamily.Id;
        packageItemList.Product_Rate_Plan__c = prdRatePlan.Id;
        packageItemList.Name = 'Test Pack Item'; 

        insert packageItemList;
        
        Publication__c publication = TestDataFactory.createPublication(1)[0];
        publication.Platform_Type__c = 'print';
        publication.Publication_Code__c = 'code';
        publication.Product_Category__c = 'print';
        publication.Earliest_Start_Date__c = date.today()+1;
        insert publication;

        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true; 
        subwrap.subId = subList.Id; 
        subwrap.mainPack = packageList[0].Name;              
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
       controller.getSubscriptions();
        controller.populatePOPStartDate();
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
        controller.changeInAddress.Vendor__c = accVen.id; //START END UD-3347 22Mar2016 Added By C. Lin
        controller.changeInAddress.Contact_to_Update__c = con.id;
        controller.changeInAddress.POP_Start_Date__c = date.Today();
        controller.changeInAddress.Effective_Date__c  = date.today()+1;
        controller.changeInAddress.New_Address__c = addr.Id;
        controller.changeInAddress.ContactId = con.Id;
        controller.changeInAddress.Category__c = GlobalVariableClass.CASEDIGITAL;
        controller.changeInAddress.Sub_Category__c = 'Change of Address';
        controller.subWrapperList = subWrapperList;
        String error = '';
        try{
              controller.save();
             //controller.getSubscriptions();
             
            //controller.populatePOPStartDate();   
            }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }
    /*//jurna
    static testmethod void testPopulatePopStartDate2()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        insert addr;
        
        //create Billing Account Records
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Billing_Indicator__c = false;
        con.Recipient_Indicator__c = false;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        packageList[0].Package_Type__c = 'Grace Period';  
        packageList[0].Subscription_Period__c = '1'; 
        insert packageList;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.COntactId=con.id;
        cas.Category__c=GlobalVariableClass.CASEDIGITAL;
        cas.Sub_Status__c='Newspaper Redelivered';
        cas.Sub_Category__c = 'Change of Address';
        cas.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
        cas.New_Address__c = addr.id;
        cas.Vendor__c=acc.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;                
        
        Zuora__Subscription__c subList= testDataFactory.createSubscription(1)[0];
        subList.name = 'S00000000';        
        subList.Zuora__Account__c = acc.id;
        subList.Zuora__Status__c = 'Active';
       // zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
        subList.Recipient_Contact__c = con.id;
        subList.Main_Package_1__c = packageList[0].Id;
        subList.Main_Package__c = packageList[0].id;
        //subList.Subscription_Type__c = 'Publication';
        subList.Zuora__CustomerAccount__c = billAcc.id;
        //subList.Zuora__SubscriptionEndDate__c = date.Today()+5;
        //subList.Zuora__TermSettingType__c = 'TERMED';
        //subList.Vendor_1__c = acc.Id;
        //subList.Zuora__TermSettingType__c = 'EVERGREEN';
        insert subList;
        
        Subscription_Vendor__c subvend = testDataFactory.createSubscriptionVendor(1)[0];
        subvend.Account__c = acc.id;
        subvend.Recipient__c = con.id;
        subvend.Status__c = 'Active';
        subvend.Vendor__c = acc.Id;
        subvend.Subscription_Stop_Date__c = date.today()+1;
        insert subvend;
        
        
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Delivery';
        zProduct.ProductPlatform__c = 'print';
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Proration';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        Product_Family__c productFamily = TestdataFactory.createProductFamily(1)[0];
        insert productFamily;

        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.PublicationCode__c = 'Code';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c packageItemList = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItemList.Package__c = packageList[0].id;
        packageItemList.Product_Family__c = productFamily.Id;
        packageItemList.Product_Rate_Plan__c = prdRatePlan.Id;
        packageItemList.Name = 'Test Pack Item'; 

        insert packageItemList;
        
        Publication__c publication = TestDataFactory.createPublication(1)[0];
        publication.Platform_Type__c = 'print';
        publication.Publication_Code__c = 'code';
        publication.Product_Category__c = 'print';
        publication.Earliest_Start_Date__c = date.today()+1;
        insert publication;

        Subscription_Vendor_Publication__c subVenPublication = testDataFactory.createVendorPublication(1)[0];
        subVenPublication.Subscription_Vendor__c = subVend.Id;
        subVenPublication.Publication__c = publication.Id;
        insert subVenPublication;
        
        /*Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true; 
        subwrap.subId = subList.Id; 
        subwrap.mainPack = packageList[0].Name;              
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.StandardController controller = new ApexPages.StandardController(cas);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_CONTACTID, con.id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ID, cas.id);
        ChangeInAddressExtensionNew sc = new ChangeInAddressExtensionNew(controller); 
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true; 
        //subwrap.subId = subList.Id; 
        subwrap.subId = subList.Id;
        subwrap.mainPack = packageList[0].Name;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        sc.compareAddress();
        //sc.getSubscriptions();
        sc.subWrapperList = subWrapperList;
        try{
        sc.save();
        }catch(Exception e){
        SYstem.debug(e);
        }
        /*Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
       controller.getSubscriptions();
        controller.populatePOPStartDate();
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
        controller.changeInAddress.Vendor__c = acc.id;
        controller.changeInAddress.Contact_to_Update__c = con.id;
        controller.changeInAddress.POP_Start_Date__c = date.Today();
        //controller.changeInAddress.Effective_Date__c  = date.today()+1;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.New_Address__c = addr.Id;
        controller.changeInAddress.ContactId = con.Id;
        controller.changeInAddress.Category__c = GlobalVariableClass.CASEDIGITAL;
        controller.changeInAddress.Sub_Category__c = 'Change of Address';
        controller.subWrapperList = subWrapperList;
        String error = '';
        try{
              controller.save();
             controller.getSubscriptions();
             
            //controller.populatePOPStartDate();   
            }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    } */
    /*//
    static testmethod void testPopulatePopStartDate3()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        insert addr;
        
        //create Billing Account Records
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Billing_Indicator__c = false;
        con.Recipient_Indicator__c = false;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        packageList[0].Package_Type__c = 'Grace Period';  
        packageList[0].Subscription_Period__c = '1'; 
        insert packageList;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.COntactId=con.id;
        cas.Category__c=GlobalVariableClass.CASEDIGITAL;
        cas.Sub_Status__c='Newspaper Redelivered';
        cas.Sub_Category__c = 'Change of Address';
        //cas.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR;
        cas.New_Address__c = addr.id;
        //cas.Vendor__c=acc.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;                
        
        Zuora__Subscription__c subList= testDataFactory.createSubscription(1)[0];
        subList.name = 'S00000000';        
        subList.Zuora__Account__c = acc.id;
        subList.Zuora__Status__c = 'Active';
       // zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
        subList.Recipient_Contact__c = con.id;
        subList.Main_Package_1__c = packageList[0].Id;
        subList.Main_Package__c = packageList[0].id;
        //subList.Subscription_Type__c = 'Publication';
        subList.Zuora__CustomerAccount__c = billAcc.id;
        //subList.Zuora__SubscriptionEndDate__c = date.Today()+5;
        //subList.Zuora__TermSettingType__c = 'TERMED';
        //subList.Vendor_1__c = acc.Id;
        //subList.Zuora__TermSettingType__c = 'EVERGREEN';
        insert subList;
        
        Subscription_Vendor__c subvend = testDataFactory.createSubscriptionVendor(1)[0];
        subvend.Account__c = acc.id;
        subvend.Recipient__c = con.id;
        subvend.Status__c = 'Active';
        subvend.Vendor__c = acc.Id;
        subvend.Subscription_Stop_Date__c = date.today()+2;
        insert subvend;
        
        
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Delivery';
        zProduct.ProductPlatform__c = 'print';
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Proration';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        Product_Family__c productFamily = TestdataFactory.createProductFamily(1)[0];
        insert productFamily;

        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.PublicationCode__c = 'Code';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c packageItemList = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItemList.Package__c = packageList[0].id;
        packageItemList.Product_Family__c = productFamily.Id;
        packageItemList.Product_Rate_Plan__c = prdRatePlan.Id;
        packageItemList.Name = 'Test Pack Item'; 

        insert packageItemList;
        
        Publication__c publication = TestDataFactory.createPublication(1)[0];
        publication.Platform_Type__c = 'print';
        publication.Publication_Code__c = 'code';
        publication.Product_Category__c = 'print';
        publication.Earliest_Start_Date__c = date.today()+1;
        insert publication;

        Subscription_Vendor_Publication__c subVenPublication = testDataFactory.createVendorPublication(1)[0];
        subVenPublication.Subscription_Vendor__c = subVend.Id;
        subVenPublication.Publication__c = publication.Id;
        insert subVenPublication;
        
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.StandardController controller = new ApexPages.StandardController(cas);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_CONTACTID, con.id);
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ID, cas.id);
        ChangeInAddressExtensionNew sc = new ChangeInAddressExtensionNew(controller); 
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true; 
        //subwrap.subId = subList.Id; 
        subwrap.subId = subList.Id;
        subwrap.mainPack = packageList[0].Name;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        sc.compareAddress();
        //sc.getSubscriptions();
        sc.subWrapperList = subWrapperList;
        try{
        sc.save();
        }catch(Exception e){
        System.debug(e);
        }
        
    } */
    
        static testMethod void testPopulatePopStartDateDeliverAdLocAddress(){
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Billing Account Records
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Billing_Indicator__c = false;
        con.Recipient_Indicator__c = false;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        packageList[0].Package_Type__c = 'Grace Period';  
        packageList[0].Subscription_Period__c = '1'; 
        insert packageList;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        insert cas;                
        
        Zuora__Subscription__c subList= testDataFactory.createSubscription(1)[0];
        subList.name = 'S00000000';        
        subList.Zuora__Account__c = acc.id;
        subList.Zuora__Status__c = 'Active';
       // zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
        subList.Recipient_Contact__c = con.id;
        subList.Main_Package_1__c = packageList[0].Id;
        subList.Main_Package__c = packageList[0].id;
        //subList.Subscription_Type__c = 'Publication';
        subList.Zuora__CustomerAccount__c = billAcc.id;
        //subList.Zuora__SubscriptionEndDate__c = date.Today()+5;
        //subList.Zuora__TermSettingType__c = 'TERMED';
        //subList.Vendor_1__c = acc.Id;
        //subList.Zuora__TermSettingType__c = 'EVERGREEN';
        insert subList;
        
        Subscription_Vendor__c subvend = testDataFactory.createSubscriptionVendor(1)[0];
        subvend.Account__c = acc.id;
        subvend.Recipient__c = con.id;
        subvend.Status__c = 'Active';
        subvend.Vendor__c = acc.Id;
        subvend.Subscription_Stop_Date__c = date.today()+1;
        insert subvend;
        
        
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Delivery';
        zProduct.ProductPlatform__c = 'print';
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Proration';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        Product_Family__c productFamily = TestdataFactory.createProductFamily(1)[0];
        insert productFamily;

        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.PublicationCode__c = 'Code';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c packageItemList = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItemList.Package__c = packageList[0].id;
        packageItemList.Product_Family__c = productFamily.Id;
        packageItemList.Product_Rate_Plan__c = prdRatePlan.Id;
        packageItemList.Name = 'Test Pack Item'; 

        insert packageItemList;
        
        Publication__c publication = TestDataFactory.createPublication(1)[0];
        publication.Platform_Type__c = 'print';
        publication.Publication_Code__c = 'code';
        publication.Product_Category__c = 'print';
        publication.Earliest_Start_Date__c = date.today()+1;
        insert publication;

        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true; 
        subwrap.subId = subList.Id; 
        subwrap.mainPack = packageList[0].Name;              
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
       controller.getSubscriptions();
        controller.populatePOPStartDate();
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.DELIVERYADDLOC;
        controller.changeInAddress.Vendor__c = acc.id;
        controller.changeInAddress.Contact_to_Update__c = con.id;
        controller.changeInAddress.POP_Start_Date__c = date.Today();
        controller.changeInAddress.Effective_Date__c  = null; //date.today()+1; //START END UD-3347 22Mar2016 Added By C. Lin
        controller.changeInAddress.New_Address__c = addr.Id;
        controller.subWrapperList = subWrapperList;
        controller.changeInAddress.ContactId = con.Id;
        controller.changeInAddress.Category__c = GlobalVariableClass.CASEDIGITAL;
        controller.changeInAddress.Sub_Category__c = 'Change of Address';
        String error = '';
        try{
              controller.save();
             //controller.getSubscriptions();
             
            //controller.populatePOPStartDate();   
            }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }
    
    
    
    
    static testMethod void testPopulatePopStartDateDeliverAdLocAddress2(){
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Billing Account Records
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Billing_Indicator__c = false;
        con.Recipient_Indicator__c = false;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        packageList[0].Package_Type__c = 'Grace Period';  
        packageList[0].Subscription_Period__c = '1'; 
        insert packageList;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.Account__c = acc.id;//jurna
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() +1;
        cas.Sub_Status__c = 'Waiting for Vendor Assignment';
        insert cas;                
        
        Zuora__Subscription__c subList= testDataFactory.createSubscription(1)[0];
        subList.name = 'S00000000';        
        subList.Zuora__Account__c = acc.id;
        subList.Zuora__Status__c = 'Active';
       // zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
        subList.Recipient_Contact__c = con.id;
        subList.Main_Package_1__c = packageList[0].Id;
        subList.Main_Package__c = packageList[0].id;
        //subList.Subscription_Type__c = 'Publication';
        subList.Zuora__CustomerAccount__c = billAcc.id;
        //subList.Zuora__SubscriptionEndDate__c = date.Today()+5;
        //subList.Zuora__TermSettingType__c = 'TERMED';
        //subList.Vendor_1__c = acc.Id;
        //subList.Zuora__TermSettingType__c = 'EVERGREEN';
        insert subList;
        
        Subscription_Vendor__c subvend = testDataFactory.createSubscriptionVendor(1)[0];
        subvend.Account__c = acc.id;
        subvend.Recipient__c = con.id;
        subvend.Status__c = 'Active';
        subvend.Vendor__c = acc.Id;
        subvend.Subscription_Stop_Date__c = date.today()+1;
        insert subvend;
        
        
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Delivery';
        zProduct.ProductPlatform__c = 'print';
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Proration';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        Product_Family__c productFamily = TestdataFactory.createProductFamily(1)[0];
        insert productFamily;

        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.PublicationCode__c = 'Code';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        Package_Item__c packageItemList = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItemList.Package__c = packageList[0].id;
        packageItemList.Product_Family__c = productFamily.Id;
        packageItemList.Product_Rate_Plan__c = prdRatePlan.Id;
        packageItemList.Name = 'Test Pack Item'; 

        insert packageItemList;
        
        Publication__c publication = TestDataFactory.createPublication(1)[0];
        publication.Platform_Type__c = 'print';
        publication.Publication_Code__c = 'code';
        publication.Product_Category__c = 'print';
        publication.Earliest_Start_Date__c = date.today()+1;
        insert publication;

        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true; 
        subwrap.subId = subList.Id; 
        subwrap.mainPack = packageList[0].Name;              
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
       controller.getSubscriptions();
        controller.populatePOPStartDate();
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.DELIVERYADDLOC;
        controller.changeInAddress.Vendor__c = acc.id;
        controller.changeInAddress.Contact_to_Update__c = con.id;
        controller.changeInAddress.POP_Start_Date__c = date.Today();
        controller.changeInAddress.Effective_Date__c  = date.today()+1;
        controller.changeInAddress.New_Address__c = addr.Id;
        controller.subWrapperList = subWrapperList;
        controller.changeInAddress.ContactId = con.Id;
        controller.changeInAddress.Category__c = GlobalVariableClass.CASEDIGITAL;
        controller.changeInAddress.Sub_Category__c = 'Change of Address';
        String error = '';
        try{
              controller.save();
             //controller.getSubscriptions();
             
            //controller.populatePOPStartDate();   
            }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }
   

    
    /**
    * Test method for Address Type = Change Vendor|Vendor != null | Effective Date!= null | With Zuora Subscription
    * @name testChangeVendorNotNullWithSub
    * @param none
    * @return none
    * @throws exception - exception when an execution fails, for assertion
    * @see 
    */
    static testMethod void testChangeVendorNotNullWithSub()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];        
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today() + 1;
        insert cas;
        
        
        //create Main Package Records
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        packageList[0].Package_Type__c = 'Grace Period';  
        packageList[0].Subscription_Period__c = '1'; 
        insert packageList;
        
        //create Billing Account Records
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        /*
        //create Address Records
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        insert addressRec;
        */
        //create Contact Records
        List<Contact> conList = TestDataFactory.createContact(1);
        conList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        conList[0].AccountId = acc.Id;
        conList[0].Address__c = addr.Id;
        conList[0].Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert conList;
        
        //create Order Records
        List<Order__c> orderList = TestDataFactory.createOrder(1);
        orderList[0].Account__c = acc.Id;
        orderList[0].Informed_Customer__c = TRUE;
        orderList[0].Recipient_Contact__c = conList[0].Id;
        insert orderList ; 
        
        List<Contact> conList2 = TestDataFactory.createContact(1);
        conList2[0].AccountId = acc.id;
        conList2[0].Recipient_Indicator__C = TRUE;
        insert conList2;
        
        List<Order__c> orderList2 = TestDataFactory.createOrder(1);
        orderList2[0].Account__c = acc.Id;
        orderList2[0].Informed_Customer__c = TRUE;
        orderList2[0].Recipient_Contact__c = conList2[0].Id;
        insert orderList2 ;
        
        List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
        orderLineItemList[0].Order__c = orderList2[0].id;
        orderLineItemList[0].Main_Package_ID__c = packageList[0].id;
        orderLineItemList[0].start_Date__c = date.Today()+1;
        insert orderLineItemList;
        
        Zuora__Subscription__c subList= testDataFactory.createSubscription(1)[0];
        subList.name = 'S00000000';        
        subList.Zuora__Account__c = acc.id;
        subList.Zuora__Status__c = 'Active';
       // zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
        subList.Recipient_Contact__c = con.id;
        subList.Main_Package_1__c = packageList[0].id;
        subList.Main_Package__c = packageList[0].id;
        subList.Subscription_Type__c = 'Publication';
        subList.Subscription_Type_1__c = 'Publication';
        subList.Zuora__CustomerAccount__c = billAcc.id;
        subList.Zuora__SubscriptionEndDate__c = date.Today()+5;
        //subList.Zuora__TermSettingType__c = 'TERMED';
        subList.Vendor_1__c = acc.Id;
        subList.Zuora__TermSettingType__c = 'EVERGREEN';
        insert subList;
        
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.ProductSubType__c = 'Delivery';
        zProduct.ProductPlatform__c = 'print';
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Proration';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        Product_Family__c productFamily = TestdataFactory.createProductFamily(1)[0];
        insert productFamily;
                
        Package_Item__c packageItemList = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packageItemList.Package__c = packageList[0].id;
        packageItemList.Product_Family__c = productFamily.Id;
        packageItemList.Product_Rate_Plan__c = prdRatePlan.Id;
        packageItemList.Name = 'Test Pack Item'; 
               
        insert packageItemList;
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        subwrap.subName = 'Name';
        subwrap.mainPack = 'MainPack';
        subwrap.contactName = 'contactName';
        subwrap.vendorName  = 'vendorName';
        subwrap.status = 'Active';
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));
        
        controller.checkExistingVendor();
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR; 
        controller.changeInAddress.New_Address__c = addr.Id;
        controller.changeInAddress.Vendor__c = acc.Id;
        controller.changeInAddress.Effective_Date__c  = date.today()+1;
        controller.changeInAddress.Contact_To_Update__c = con.Id;
        controller.subscriptionWrapper  = subwrap;
        controller.changeInAddress.ContactId = con.Id;
        controller.changeInAddress.Category__c = GlobalVariableClass.CASEDIGITAL;
        controller.changeInAddress.Sub_Category__c = 'Change of Address';
        String error = '';
        try{
            controller.getSubscriptions();
            controller.subWrapperList = subWrapperList;
            controller.populatePOPStartDate();     
            controller.save();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
        
    }
    static testMethod void testGetSubscription()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; 
        insert billAcc;
        
        Package__c pack = testDataFactory.createPackage(1)[0];
        insert pack;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today()+1;
        insert cas;
        
        Zuora__Subscription__c zsub = new Zuora__Subscription__c();
        zsub.name = 'S00000000';        
        zsub.Zuora__Account__c = acc.id;
        zsub.Zuora__Status__c = 'Active';
        //zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
        //zSub.Order_Line_Item_Number_1__c = orderLineItemList[0].id;
        zsub.Recipient_Contact__c = con.id;
        zSub.Main_Package_1__c = pack.id;
        //zSub.Main_Package__c = packageList[0].id;
        zSub.Zuora__CustomerAccount__c = billAcc.id; //ADD 02/25
        zsub.Vendor_1__c = acc.Id;
        insert zsub;

        
        Subscription_Vendor__c subvend = testDataFactory.createSubscriptionVendor(1)[0];
        subvend.Account__c = acc.id;
        subvend.Recipient__c = con.id;
        subvend.Status__c = 'Active';
        subvend.Vendor__c = acc.Id;
        subvend.Subscription_Stop_Date__c = date.today()+1;
        insert subvend;
        
        Publication__c publication = TestDataFactory.createPublication(1)[0];
        publication.Platform_Type__c = 'print';
        publication.Product_Category__c = 'print';
        insert publication;
        
        Subscription_Vendor_Publication__c subVenPublication = testDataFactory.createVendorPublication(1)[0];
        subVenPublication.Subscription_Vendor__c = subVend.Id;
        subVenPublication.Publication__c = publication.Id;
        insert subVenPublication;
        
        
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));        
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.BILLINGADD; 
        controller.changeInAddress.Vendor__c = acc.Id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        
        String error = '';
        try{
            controller.getSubscriptions();
            controller.subWrapperList = subWrapperList;
            controller.populatePOPStartDate();
            controller.save();   }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }
  
  static testMethod void testGetSubscriptioVendorChangeInAdd()
    {
        
        //Create Non-Vendor Account
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        insert acc;
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        //START UD-3347 22Mar2016 Added By C. Lin
        Zone__c zoneRec = TestDataFactory.createZone(1)[0];
        zoneRec.Name = 'XXX';
        database.insert(zoneRec);
        
        Country__c countryRec = TestDataFactory.createCountry(1)[0];
        countryRec.Code__c = 'XX';
        countryRec.Country_Name__c = 'Singapore';
        countryRec.Zone__c = zoneRec.Id;
        database.insert(countryRec);
        //END UD-3347 22Mar2016 Added By C. Lin
        
        //create Address Records
        Address__c addr = TestDataFactory.createAddress(1)[0];
        addr.Address_Type__c='P';
        addr.Postal_Code__c = postal.Id;
        addr.Country__c = countryRec.Id; //START END UD-3347 22Mar2016 Added By C. Lin
        insert addr;
        
        //create Contact Records
        Contact con = TestDataFactory.createContact(1)[0];
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
        con.AccountId = acc.Id;
        con.Address__c = addr.Id;
        con.Recipient_Indicator__c = true;//START/END CCB.002 Modified by: Francis Benzon
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; 
        insert billAcc;
        
        Package__c pack = testDataFactory.createPackage(1)[0];
        insert pack;
        
        //Create Case (ChangeInAddress)
        Case cas = new Case();//TestDataFactory.createCase(1, 'Change of Address/Vendor');
        cas.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');    
        cas.Contact_To_Update__c = con.id;
        cas.AccountId = acc.Id;
        cas.New_Address__c = addr.id;
        cas.Effective_Date__c = date.today()+1;
        insert cas;
        
        Zuora__Subscription__c zsub = new Zuora__Subscription__c();
        zsub.name = 'S00000000';        
        zsub.Zuora__Account__c = acc.id;
        zsub.Zuora__Status__c = 'Active';
        //zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
        //zSub.Order_Line_Item_Number_1__c = orderLineItemList[0].id;
        zsub.Recipient_Contact__c = con.id;
        zSub.Main_Package_1__c = pack.id;
        //zSub.Main_Package__c = packageList[0].id;
        zSub.Zuora__CustomerAccount__c = billAcc.id; //ADD 02/25
        zsub.Vendor_1__c = acc.Id;
        insert zsub;

        
        Subscription_Vendor__c subvend = testDataFactory.createSubscriptionVendor(1)[0];
        subvend.Account__c = acc.id;
        subvend.Recipient__c = con.id;
        subvend.Status__c = 'Active';
        subvend.Vendor__c = acc.Id;
        subvend.Subscription_Stop_Date__c = date.today()+1;
        insert subvend;
        
        Publication__c publication = TestDataFactory.createPublication(1)[0];
        publication.Platform_Type__c = 'print';
        publication.Product_Category__c = 'print';
        insert publication;
        
        Subscription_Vendor_Publication__c subVenPublication = testDataFactory.createVendorPublication(1)[0];
        subVenPublication.Subscription_Vendor__c = subVend.Id;
        subVenPublication.Publication__c = publication.Id;
        insert subVenPublication;
        
        
        
        Test.startTest();
        PageReference pageRef = Page.ChangeInAddressCaseNewPage;
        ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.id);
        ChangeInAddressExtensionNew.SubscriptionWrapper subWrap = new ChangeInAddressExtensionNew.SubscriptionWrapper();
        subWrap.selectSub = true;
        List<ChangeInAddressExtensionNew.SubscriptionWrapper> subWrapperList = new List<ChangeInAddressExtensionNew.SubscriptionWrapper>();
        subWrapperList.add(subWrap);
        
        Case sCon = new Case();
        ChangeInAddressExtensionNew controller = new ChangeInAddressExtensionNew(new ApexPages.StandardController(sCon));        
        controller.changeInAddress.Change_of_Address_Type__c = GlobalVariableClass.CHANGEVENDOR; 
        controller.changeInAddress.Vendor__c = acc.Id;
        controller.changeInAddress.Effective_Date__c  = date.today();
        controller.changeInAddress.Contact_To_Update__c = con.Id;
        controller.changeInAddress.ContactId = con.Id;
        controller.changeInAddress.Category__c = GlobalVariableClass.CASEDIGITAL;
        controller.changeInAddress.Sub_Category__c = 'Change of Address';
        String error = '';
        try{
            controller.getSubscriptions();
            controller.subWrapperList = subWrapperList;
            controller.populatePOPStartDate();
            controller.save(); 
            controller.selectBundleSub();  }
        catch(exception e){
            error = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();
        //Assert if expected value is equal to actual value
        System.assertEquals('', error);
    }

}