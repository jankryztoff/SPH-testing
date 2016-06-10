/**
@Author <Rom Edison Reyes>
@name <RenewalController_Test>
@CreateDate <02/16/2015>
@Description <Test Class for RenewalController>
@Version <1.0>
@reference <none>
*/
@isTest
private class RenewalController_Test
{
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
    }  


    static List<Zuora__Subscription__c> zSubs = null;
    
    static Map<String, sObject> sObjectMap; //by JJZS
    Date newDate;
    
    /*
    * Test for RenewalController with all values filled up 
    * @name <testRenewalController>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */   
    static testmethod void testIfSubIdEquals(){
        prepareAllSubscriptionData();
        
        Zuora__Subscription__c subId = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c2');
        
        Test.startTest();
            
            
            Letter_Print_Request__c lprMaster = new Letter_Print_Request__c();
            lprMaster.Letter_Type__c =  SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            lprMaster.Billing_Account__c = zSubs[0].Zuora__CustomerAccount__c;
            lprMaster.Language_Medium__c  = SP_RenewalReminderHelper.LANGUAGE_MEDIUM_ENGLISH;
            database.insert(lprMaster, false);
            
            Letter_Print_Request__c lpr = new Letter_Print_Request__c();
            lpr.Letter_Type__c =  SP_GenerateLetterPrintBatch.firstRenewalReminderForNewspaper;
            lpr.Billing_Account__c = zSubs[0].Zuora__CustomerAccount__c;
            lpr.Language_Medium__c  = SP_RenewalReminderHelper.LANGUAGE_MEDIUM_ENGLISH;
            lpr.Record_ID__c = zSubs[0].Id;
            lpr.Parent_Letter_Print_Request__c = lprMaster.Id;
            lpr.Status__c = 'Tagged';
            database.insert(lpr, false);
            
            PageReference pageRef = Page.LP_MagazineRenewal;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',lprMaster.Id); 
            RenewalController controller = new RenewalController();            
            Date tod = controller.Today;
            //newDate = controller.NewDate;
            try{
                controller.setFields();
            }catch(exception e){}
            
            //System.assertEquals(date.today()+14, newDate);
            //System.debug('DDDEBUG:' + [SELECT Zuora__CustomerAccount__c,Recipient_Contact_1__c FROM Zuora__Subscription__c WHERE id=:zSubs[0].id]); 
            //System.debug('DDDEBUG 2:' + [SELECT Recipient_Contact__c FROM Zuora__Subscription__c WHERE id=:zSubs[0].id]);
        Test.stopTest();
        
        //System.assertEquals(zSubs[0].id, controller.subId);  
    }

    static testmethod void useAllData(){
        
        prepareAllSubscriptionData();
        
        List<Zuora__Subscription__c> zSubList = new List<Zuora__Subscription__c>();
        zSubList.add((Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c1'));
        zSubList.add((Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c2'));
        Zuora__Subscription__c sub = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c1');

        RenewalController controller = new RenewalController();
        
        controller.billingContactName = 'Jefferson';
        //controller.contactName = 'Jefferson Duck';
        //controller.contactMailingAddress = 'Vermont';
        //controller.paymentAmount = 100.00;
        //controller.expirationDate = Date.today();
        //controller.mailingBlk = 'churva';
        //controller.mailingStreet = 'churva';
        //controller.mailingLevel = 'churva';
        //controller.mailingUnit = 'churva';
        //controller.mailingBuilding = 'churva';
        //controller.mailingPostalCode = 'churva';
        controller.mainPackage = 'churva';
        controller.subscriptionEndDate= Date.today();
        controller.subscriptionCharge = 100.00;
        controller.finalAddress = 'churva';
        //controller.mailingCountry = 'churva';      
        
        //controller.pubCode = 'churva';
        //controller.giftName = 'churva';
        //controller.giftDescription = 'churva';
        controller.subAccountNum = 'churva';
        controller.accountName = 'churva';
        controller.recipientName = 'churva';
        controller.recAccountNum = 'churva';
        
        //controller.pub1 = 'churva';
        controller.frequency = 'churva';
        controller.numberOfCopies = 100.00;
        controller.subscriptionExpiry = 'churva';
        //controller.rCode1Sub  = 'churva';
        //controller.rCode1Disc  = 'churva';
        //controller.rCode2Sub  = 'churva';
        //controller.rCode2Disc  = 'churva';
        controller.acct  = 'churva';

        //controller.z = zSubList;
        controller.type = 'churva';
        controller.notifKey = 'churva';
        //controller.expiryDate =  Date.today();
        //controller.expiryDate = Date.today();
        //controller.dateOutput = 'churva';
        controller.dateOutput = Date.today();
        //controller.address1 = 'churva';
        //controller.address2 = 'churva';
        //controller.address3 = 'churva';
        //controller.address4 = 'churva';
        //controller.address5 = 'churva';
        controller.barcodeAttId = 'churva';
        controller.barChecker = true;
        controller.LastRows = new List<string>();
        controller.LastRows.add('churva');
        controller.LastRows.add('churvaness');
        controller.MagazineCnt = 1;
        controller.NewsPaperCnt = 1;
        controller.EmailAddress = 'churva';
        controller.HomeNumber = 'churva';
        controller.OfficeNumber = 'churva';
        controller.MobileNumber = 'churva';
        controller.newsDelCharge = 100.00;
        controller.newsTotal = 100.00;
        //RenewalController.MagazineRenewalDetails rc_mrd = new  RenewalController.MagazineRenewalDetails();
        //controller.pubCode = 'churva';
        //controller.frequencyCode = 'churva';
        //controller.subEndDate = Date.today();
        //controller.renewal1 = 'churva';
        //controller.renewal1Disc = 'churva';
        //controller.renewal2 = 'churva';
        //controller.renewal2Disc = 'churva';
//        controller.magazineRenewList.add(rc_mrd);
    
        //RenewalController.NewspaperRenewalDetails rc_nr = new RenewalController.NewspaperRenewalDetails();
        
        //rc_nr.pubCode = 'churva';
        //rc_nr.frequencyCode = 'churva';
        //controller.subCopies = 1;
        //rc_nr.subEndDate = Date.today();
        //controller.subCharge = 100.00;   
//        controller.newspaperRenewList.add(rc_nr);
        //controller.subId = sub.Id;
        try{
            controller.setFields();
        }catch(exception e){} 
        //controller.magazineRenewal();
        
//TODO
        
        
/*        
        Zuora__Subscription__c zSub = [SELECT Subscriber_Contact__c, Recipient_Contact__c, Recipient_Contact__r.Name, Contact__r.Name, Order_Number_1__c, 
                    Zuora__Account__r.Name, Order_Line_Item_Number_1__c, Frequency_1__c, Number_of_Copies__c, Main_Package_1__c, Main_Package_1__r.name, Contact__r.Address__r.Block_House_Number__c, Contact__r.Address__r.Postal_Code__r.Street_Name__c,
                    Contact__r.Address__r.Level_Number__c, Recipient_Contact__r.Address__r.Name, Contact__r.Address__r.Unit_Number__c, Zuora__SubscriptionEndDate__c, Contact__r.Address__r.Postal_Code__r.Building_Name__c, Contact__r.Address__r.Postal_Code__r.Name,Zuora__CustomerAccount__c, Contact__r.Address__r.Country_Name__c, Contact__r.MailingAddress, Unique_Delivery_Identifier__c,
                    Contact__r.Address__r.Country__r.Country_Name__c, Subscription_Charge__c, Subscriber_Contact__r.Account.AccountNumber, Zuora__Account__r.AccountNumber, Zuora__Account__c, Zuora__Account__r.Account_Auto_Number__c, Contact__r.MailingCountry,
                    Recipient_Contact__r.Account.AccountNumber, Delivered_By_1__c, Contact__r.Address__r.Airline_Number__c, 
                    Contact__r.Address__r.City__c, Contact__r.Address__r.Flight_Number_1__c, Contact__r.Address__r.Flight_Number_2__c,
                    Contact__r.Address__r.Address_1__c, Contact__r.Address__r.Address_2__c, Contact__r.Address__r.Address_3__c, 
                    Contact__r.Address__r.Address_4__c, Contact__r.Address__r.Location_Code__r.Name, Contact__r.Address__r.Company_Code__r.Name, 
                    Contact__r.Address__r.Division_Code__r.Name, Contact__r.Address__r.Department__r.Name, 
                    Contact__r.Address__r.Section_Code__r.Name, is2ndPDFGenerated__c, Contact__r.Address__r.RecordType.Name, Contact__r.Email, 
                    Contact__r.Mobile_Number__c, Contact__r.Office_Number__c, Contact__r.HomePhone__c, is1stPDFGenerated__c, 
                    Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Zuora__CustomerAccount__r.Billing_Contact__c, 
                    Zuora__CustomerAccount__r.Billing_Contact__r.Name, Zuora__CustomerAccount__r.Billing_Contact__r.Email, 
                    Zuora__CustomerAccount__r.Billing_Contact__r.Homephone__c, Zuora__CustomerAccount__r.Billing_Contact__r.Office_Number__c, 
                    Zuora__CustomerAccount__r.Billing_Contact__r.Mobile_Number__c, Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Postal_Code__c, 
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Postal_Code__r.Id,                          
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Block_House_Number__c,      
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Street_Name__c,     
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Level_Number__c,        
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Unit_Number__c,     
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Building_Name__c,       
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Country__r.Country_Name__c,     
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Postal_Code__r.Name,        
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,        
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Department__r.Department_Name__c,       
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Division_Code__r.Name,      
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Company_Code__r.Name,       
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c,        
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Location_Code__r.Location_Name__c,      
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.City__r.City_Name__c,       
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Airline_Number__c,      
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Flight_Number_1__c,     
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Flight_Number_2__c,     
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Address_1__c,       
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Address_2__c,       
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Address_3__c,       
                    Zuora__CustomerAccount__r.Billing_Contact__r.Address__r.Address_4__c
                    FROM Zuora__Subscription__c 
                    WHERE Id =: sub.Id];
        
        String finalAddress = AddressHelper.formatAddress(zSub.Zuora__CustomerAccount__r.Billing_Contact__r,false,false);
        System.assertEquals(null,finalAddress);
*/        
        
    }

    /*
    * Test for RenewalController with some Address and SingPost Address Values = null
    * @name <testRenewalControllerNullAddress>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */ 
    static testmethod void testLastRowsCheck(){
        list<string> str = new list<string>(26);
        prepareAllSubscriptionData();  
            
       
        for (integer x = 0; x <= 25; x++){             
            str[x] = '1';       
        }

        Test.startTest();
            PageReference pageRef = Page.LP_MagazineRenewal;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',zSubs[0].id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(zSubs[0]);  
            RenewalController controller = new RenewalController();
            Date tod = controller.Today;
            //Date newDate = controller.NewDate;
            //controller.initialize();
            controller.initializeMZ();
        Test.stopTest();
        //System.debug('DDDEBUG NULL:' + [SELECT Zuora__CustomerAccount__c,Recipient_Contact_1__c FROM Zuora__Subscription__c WHERE id=:zSubs[0].id]);
        //System.debug('DDDEBUG NULL 2:' + [SELECT Recipient_Contact__c FROM Zuora__Subscription__c WHERE id=:zSubs[0].id]);
        System.assertEquals(date.today(), tod);
        System.assertEquals(str, controller.LastRows);
        
    }
    
    static testmethod void initializeNPTest(){
        System.debug('initializeNPTest start');
        prepareAllSubscriptionData();
        
        Zuora__Subscription__c subId = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c2');
        
        Test.startTest();            
            PageReference pageRef = Page.LP_MagazineRenewal;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',zSubs[0].id);        
            RenewalController controller = new RenewalController();
            controller.initializeNP();
            //controller.initializeMZ();
        Test.stopTest();
        System.debug('initializeNPTest end');
    }
    
   static testmethod void initializeMZTest(){
        System.debug('initializeMZTest start');
        prepareAllSubscriptionData();
        
        Test.startTest();  
            PageReference pageRef = Page.LP_MagazineRenewal;
            Test.setCurrentPage(pageRef);
            RenewalController controller = new RenewalController();
            controller.initializeMZ();
        Test.stopTest();
        System.debug('initializeMZTest end');
    }
    
    static testmethod void initializeCHNPTest(){
        System.debug('initializeCHNPTest start');
        prepareAllSubscriptionData();
        
        Test.startTest();            
            PageReference pageRef = Page.LP_MagazineRenewal;
            Test.setCurrentPage(pageRef);
            RenewalController controller = new RenewalController();
            controller.initializeCHNP();
        Test.stopTest();
        System.debug('initializeCHNPTest end');
    }
    
    static testmethod void initializeCHMZTest(){
        System.debug('initializeCHMZTest start');
        prepareAllSubscriptionData();
        
        Test.startTest();            
            PageReference pageRef = Page.LP_MagazineRenewal;
            Test.setCurrentPage(pageRef);
            RenewalController controller = new RenewalController();
            controller.initializeCHMZ();
        Test.stopTest();
        System.debug('initializeCHMZTest end');
    }
    
   static testmethod void dummyTestLOL_HEHEHE(){
        
        prepareAllSubscriptionData();
        
        Zuora__Subscription__c subId = (Zuora__Subscription__c) sObjectMap.get('Zuora__Subscription__c1');
        
        Zuora__Subscription__c zSub;
        
              zSub = [SELECT Subscriber_Contact__c, Recipient_Contact__c, Recipient_Contact__r.Name, Contact__r.Name, Order_Number_1__c, 
                    Zuora__Account__r.Name, Order_Line_Item_Number_1__c, Frequency_1__c, Number_of_Copies__c, Main_Package_1__c, Main_Package_1__r.name, Contact__r.Address__r.Block_House_Number__c, Contact__r.Address__r.Postal_Code__r.Street_Name__c,
                    Contact__r.Address__r.Level_Number__c, Recipient_Contact__r.Address__r.Name, Contact__r.Address__r.Unit_Number__c, Zuora__SubscriptionEndDate__c, Contact__r.Address__r.Postal_Code__r.Building_Name__c, Contact__r.Address__r.Postal_Code__r.Name,Zuora__CustomerAccount__c, Contact__r.Address__r.Country_Name__c, Contact__r.MailingAddress, Unique_Delivery_Identifier__c,
                    Contact__r.Address__r.Country__r.Country_Name__c, Subscription_Charge__c, Subscriber_Contact__r.Account.AccountNumber, Zuora__Account__r.AccountNumber, Zuora__Account__c, Zuora__Account__r.Account_Auto_Number__c, Contact__r.MailingCountry,
                    Recipient_Contact__r.Account.AccountNumber, Delivered_By_1__c, Contact__r.Address__r.Airline_Number__c, 
                    Contact__r.Address__r.City__c, Contact__r.Address__r.Flight_Number_1__c, Contact__r.Address__r.Flight_Number_2__c,
                    Contact__r.Address__r.Address_1__c, Contact__r.Address__r.Address_2__c, Contact__r.Address__r.Address_3__c, 
                    Contact__r.Address__r.Address_4__c, Contact__r.Address__r.Location_Code__c, Contact__r.Address__r.Company_Code__c, 
                    Contact__r.Address__r.Division_Code__c, Contact__r.Address__r.Department__c, Contact__r.Address__r.Section_Code__c, 
                    Contact__r.Address__r.RecordType.Name, Contact__r.Email, Contact__r.Mobile_Number__c, Contact__r.Office_Number__c, Contact__r.HomePhone__c
                    FROM Zuora__Subscription__c 
                    WHERE Id =: subId.Id];
        

        
        
//      System.assertEquals(null,ConstantsSLB.getKeyId('Address_Local'));
    }

    /*
    * Test for RenewalController with some Address and SingPost Address Values = null
    * @name <testRenewalControllerNullAddress>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */    
    private static void prepareAllSubscriptionData(){
        
        //resets sObjectMap - by JJZS
        sObjectMap = null;
        sObjectMap = new Map<String, sObject>();
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        postal.Street_Name__c = 'Test Street';
        postal.Building_Name__c = 'Test Building';
        postal.House_Block_Number__c = '13';
        sObjectMap.put('Singpost_Address__c', postal);
        insert postal;
        
        //Create Zone
        Zone__c zone = new Zone__c();
        sObjectMap.put('Zone__c', zone);
        insert zone;
        
        //Create Country   
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Name = 'SINGAPORE';
        country.Country_Name__c = 'SINGAPORE';
        country.Code__c = 'SIN';
        //country.Zone__c = zone.Id;
        sObjectMap.put('Country__c', country);
        insert(country);
        
        //Create Address
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Name = 'Test Address';
        add.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
        add.Postal_Code__c = postal.id;
        add.Legacy_Created_By__c = 'Creator';
        add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
        add.Legacy_Updated_By__c = 'Modifier';
        add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
        add.Block_House_Number__c = '22';
        add.Level_Number__c = '03';
        add.Unit_Number__c = '13';
        add.Country__c = country.Id;       
        sObjectMap.put('Address__c', add);
        insert add;
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test Account';
        acc.AccountNumber = '';
        sObjectMap.put('Account', acc);
        insert acc;
        
        //Create Contact   
        Contact con = TestDataFactory.createContact(1)[0];        
        con.Email = 'test@email.com';
        con.Homephone__c = '1234567';
        con.Office_Number__c = '1234567';
        con.Mobile_Number__c = '09229010321';
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        con.Address__c = add.id;
        con.MailingCountry = 'Singapore';
        con.MailingCity = 'Singapore';
        con.MailingStreet = '123 Test Street';
        con.MailingPostalCode = '1000';
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        sObjectMap.put('Contact', con);
        insert con;
        
        Order__c order = TestDataFactory.createOrder(1)[0];      
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 20; 
        order.Subscriber_Charge__c = 200; //Added by JJZS
        order.Recipient_Contact__c = con.id;
        order.Billing_Contact__c = con.id;
        sObjectMap.put('Order__c', order);
        insert order;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];    
        pack.Package_Type__c = 'Base';
        pack.Name = 'ST Print Test';
        pack.Subscription_Type__c = 'Termed';
        pack.Package_Code__c = 'STEST12';
        pack.Subscription_Period__c = '12';
        pack.Effective_Start_Date__c = date.today();
        pack.Effective_End_Date__c = date.today() + 5;
        pack.Same_Pck_Renewal_Newspaper__c = true;
        pack.Package_Price__c = 50.00;
        sObjectMap.put('Package__c', pack);
        insert pack;
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c = date.today()+1;
        oli.End_Date__c = date.Today()+364;
        oli.Order__c = order.id;
        oli.Main_Package_Period__c = 2;
        oli.Qty__c = 1;
        oli.Term_Length__c = 12;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Sub_Type__c = 'Termed';
        oli.Main_Package_Product_Sub_Type__c = 'Newspaper';
        sObjectMap.put('Order_Line_Item__c', oli);
        insert oli;
        
        System.debug('oli.Start_Date__c' +oli.Start_Date__c);
        System.debug('oli.End_Date__c'+oli.End_Date__c);
        
        Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
        bill.Zuora__Account__c = acc.Id;
        bill.Billing_Contact__c = con.id;
        sObjectMap.put('Zuora__CustomerAccoount__c', bill);
        insert bill;    
        
        //ApexPages.currentPage().getParameters().put('id', zsubs[0].Id); 
        //RenewalPkgCodeNewspaper__c
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'THE STRAITS TIMES PRINT TEST';
        zProd.zqu__SKU__c = 'SKU-12345678';
        zProd.ProductCode__c = 'TEST';
        zProd.ProductType__c = 'Product';
        zProd.ProductPlatform__c = 'Print';
        zProd.ProductFamily__c = 'ST';
        zProd.ProductSubType__c = 'Newspaper';
        zProd.RenewalPkgCodeNewspaper__c = pack.Id;
        sObjectMap.put('zqu__ZProduct__c', zProd);
        insert zProd;
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.Name = 'PRODUCT RATE PLAN TEST';
        prp.RatePlanCode__c = 'STEST13TS';
        prp.RatePlanType__c = 'Bill Plan';
        prp.zqu__ZProduct__c = zProd.Id;
        sObjectMap.put('zqu__ProductRatePlan__c', prp);
        insert prp;
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packItem.Package__c = pack.Id;
        packItem.Product_Rate_Plan__c = prp.Id;
        packItem.Price__c = 50.00;
        sObjectMap.put('Package_Item__c', packItem);
        insert packItem;   
        
        //Create Zuora Subscription    
        zSubs = TestDataFactory.createSubscription(2);       
        for(Zuora__Subscription__c zSub: zSubs)
        {
            zSub.Subscriber_Contact__c = con.Id;
            zSub.Recipient_Contact__c = con.Id;
            zSub.Recipient_Contact_1__c = con.Id;    
            zSub.Contact__c = con.Id; 
            zSub.Zuora__Account__c = acc.id;
            zSub.Order_Number_1__c = order.Id;
            zSub.Order_Line_Item_Number__c =  oli.id; 
            zSub.Order_Line_Item_Number_1__c =  oli.id;
            zSub.Delivery_Charge__c = 200;
            //zSub.Subscription_Charge__c = 200;
            zSub.Frequency__c = 'Default';    
            zSub.Frequency_1__c = 'Default';
            zSub.Number_of_Copies__c = 1;
            zSub.Number_of_Copies1__c = '1';
            zSub.Qty__c = 1;
            zSub.Qty1__c = '1';
            zSub.Subscription_End_Date__c = String.valueOf(date.today()+5);
            zSub.Main_Package__c = pack.id;
            zSub.Main_Package_1__c = pack.id;
            zSub.Zuora__CustomerAccount__c = bill.Id;
            zSub.Subscription_Charge__c = 30;
            zSub.Delivered_By_1__c = 'Vendor';
            zSub.Delivered_By__c = 'Vendor';
            zsub.Unique_Delivery_Identifier__c = 'Test';
            zsub.is1stPDFGenerated__c= true;
            zsub.is2ndPDFGenerated__c = false;
            zsub.Product_Code__c = 'TEST';
            zsub.Zuora__SubscriptionStartDate__c = date.today()+1;
            zsub.Zuora__SubscriptionEndDate__c = date.today()+364;
            zsub.Term_Length__c = 12;
            zsub.Term_Length1__c = '12';
            zsub.Zuora__TermSettingType__c = 'TERMED';
            //zSub.Main_Package_Product_Sub_Type_Mapping__c = 'Newspaper';
        }
        zSubs[0].Name = 'BA-S99999999';
        zSubs[0].Subscription_Type__c = 'Delivery'; //added by JJZS
        zSubs[1].Name = 'BA-S12342264';
        zSubs[1].Subscription_Type__c = 'Delivery'; //added by JJZS
        system.debug('view01' + zSubs[0].Delivery_Charge__c);
        system.debug('view02' + zSubs[1].Delivery_Charge__c);
        sObjectMap.put('Zuora__Subscription__c1', zSubs[0]);
        sObjectMap.put('Zuora__Subscription__c2', zSubs[1]);
        insert zSubs;
        
        Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubProductCharge(1)[0];    
        subProdCharge.Name = 'Copy Sat';
        subProdCharge.PublicationCode__c = 'BH';
        subProdCharge.Zuora__Subscription__c = zSubs[0].id;
        sObjectMap.put('Zuora__SubscriptionProductCharge__c', subProdCharge);
        insert subProdCharge;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Beat Harry';    
        pub.Publication_Code__c = 'BH';
        pub.Published_Days__c = 'YYYYYYN';
        pub.Publication_Type__c = 'N';
        pub.Frequency_Code__c = 'D';
        sObjectMap.put('Publication__c', pub);
        insert pub;

        RenewalController rc1 = new RenewalController();
        //rc1.newspaperRenewal();
        

    }
    
    
    private static void prepareAllSubscriptionData2(){
        
        //resets sObjectMap - by JJZS
        sObjectMap = null;
        sObjectMap = new Map<String, sObject>();
        
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        postal.Street_Name__c = 'Test Street';
        postal.Building_Name__c = 'Test Building';
        postal.House_Block_Number__c = '13';
        sObjectMap.put('Singpost_Address__c', postal);
        insert postal;
        
        //Create Zone
        Zone__c zone = new Zone__c();
        sObjectMap.put('Zone__c', zone);
        insert zone;
        
        //Create Country   
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Name = 'SINGAPORE';
        country.Country_Name__c = 'SINGAPORE';
        country.Code__c = 'SIN';
        //country.Zone__c = zone.Id;
        sObjectMap.put('Country__c', country);
        insert country;
        
        //Create Address
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.Name = 'Test Address';
        add.Postal_Code__c = postal.id;
        add.Legacy_Created_By__c = 'Creator';
        add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
        add.Legacy_Updated_By__c = 'Modifier';
        add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
        add.Block_House_Number__c = '22';
        add.Level_Number__c = '03';
        add.Unit_Number__c = '13';
        add.Country__c = country.Id;
        sObjectMap.put('Address__c', add);
        insert add;
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test Account';
        acc.AccountNumber = 'test';
        sObjectMap.put('Account', acc);
        insert acc;
        
        //Create Contact   
        Contact con = TestDataFactory.createContact(1)[0];       
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        con.Address__c = add.id;
        con.MailingCountry = 'Singapore';
        con.MailingCity = 'Singapore';
        con.MailingStreet = '123 Test Street';
        con.MailingPostalCode = '1000';
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        sObjectMap.put('Contact', con);
        insert con;
        
        Order__c order = TestDataFactory.createOrder(1)[0];      
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 20; 
        order.Subscriber_Charge__c = 200; //Added by JJZS
        order.Recipient_Contact__c = con.id;
        order.Billing_Contact__c = con.id;
        sObjectMap.put('Order__c', order);
        insert order;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];    
        pack.Package_Type__c = 'Base';
        pack.Name = 'ST Print Test';
        pack.Subscription_Type__c = 'Termed';
        pack.Package_Code__c = 'STEST12';
        pack.Subscription_Period__c = '12';
        pack.Effective_Start_Date__c = date.today();
        pack.Effective_End_Date__c = date.today() + 5;
        sObjectMap.put('Package__c', pack);
        insert pack;
    
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c = date.today()+1;
        oli.End_Date__c = date.Today()  +2;
        oli.Order__c = order.id;
        oli.Main_Package_Period__c = 2;
        oli.Qty__c = 3;
        oli.Term_Length__c = 5;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Sub_Type__c = 'Termed';
        sObjectMap.put('Order_Line_Item__c', oli);
        insert oli;
        
        System.debug('oli.Start_Date__c' +oli.Start_Date__c);
        System.debug('oli.End_Date__c'+oli.End_Date__c);
        
        Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
        bill.Zuora__Account__c = acc.Id;
        sObjectMap.put('Zuora__CustomerAccoount__c', bill);
        insert bill;    
        
        //Create Zuora Subscription    
        zSubs = TestDataFactory.createSubscription(2);
       
        for(Zuora__Subscription__c zSub: zSubs)
        {
            zSub.Subscriber_Contact__c = con.Id;
            zSub.Recipient_Contact__c = con.Id;
            zSub.Recipient_Contact_1__c = con.Id;    
            zSub.Contact__c = con.Id; 
            zSub.Zuora__Account__c = acc.id;
            zSub.Order_Number_1__c = order.Id;
            zSub.Order_Line_Item_Number__c =  oli.id; 
            zSub.Order_Line_Item_Number_1__c =  oli.id;
            zSub.Delivery_Charge__c = 200;
            //zSub.Subscription_Charge__c = 200;
            zSub.Frequency__c = 'Default';    
            zSub.Frequency_1__c = 'Default';
            zSub.Number_of_Copies__c = 1;
            zSub.Subscription_End_Date__c = String.valueOf(date.today()+5);
            zSub.Main_Package__c = pack.id;
            zSub.Main_Package_1__c = pack.id;
            zSub.Zuora__SubscriptionEndDate__c = date.today() +5;
            zSub.Zuora__CustomerAccount__c = bill.Id;
            zSub.Subscription_Charge__c = 30;
            zSub.Delivered_By_1__c = 'Vendor';
            zSub.Delivered_By__c = 'Vendor';
        }
        zSubs[0].Name = 'BA-S00002264';
        zSubs[0].Subscription_Type__c = 'Delivery'; //added by JJZS
        zSubs[1].Name = 'BA-S12342264';
        zSubs[1].Subscription_Type__c = 'Delivery'; //added by JJZS
        system.debug('view01' + zSubs[0].Delivery_Charge__c);
        system.debug('view02' + zSubs[1].Delivery_Charge__c);
        sObjectMap.put('Zuora__Subscription__c1', zSubs[0]);
        sObjectMap.put('Zuora__Subscription__c2', zSubs[1]);
        insert zSubs;
        
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'THE STRAITS TIMES PRINT TEST';
        zProd.zqu__SKU__c = 'SKU-12345678';
        zProd.ProductCode__c = 'TEST';
        zProd.ProductType__c = 'Product';
        zProd.ProductPlatform__c = 'Print';
        zProd.ProductFamily__c = 'ST';
        zProd.ProductSubType__c = 'Newspaper';
        sObjectMap.put('zqu__ZProduct__c', zProd);
        insert zProd;
        
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.Name = 'PRODUCT RATE PLAN TEST';
        prp.RatePlanCode__c = 'STEST13TS';
        prp.RatePlanType__c = 'Bill Plan';
        prp.zqu__ZProduct__c = zProd.Id;
        sObjectMap.put('zqu__ProductRatePlan__c', prp);
        insert prp;
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packItem.Package__c = pack.Id;
        packItem.Product_Rate_Plan__c = prp.Id;
        sObjectMap.put('Package_Item__c', packItem);
        insert packItem;   
        
        Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubProductCharge(1)[0];    
        subProdCharge.Name = 'Copy Sat';
        subProdCharge.PublicationCode__c = 'BH';
        subProdCharge.Zuora__Subscription__c = zSubs[0].id;
        sObjectMap.put('Zuora__SubscriptionProductCharge__c', subProdCharge);
        insert subProdCharge;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Beat Harry';    
        pub.Publication_Code__c = 'BH';
        pub.Published_Days__c = 'YYYYYYN';
        pub.Publication_Type__c = 'N';
        pub.Frequency_Code__c = 'D';
        sObjectMap.put('Publication__c', pub);
        insert pub;

        RenewalController rc1 = new RenewalController();
        //rc1.magazineRenewal();
        

    }
}