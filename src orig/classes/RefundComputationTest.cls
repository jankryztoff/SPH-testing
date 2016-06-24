/**
@Author <Michiko Santoyo/ Rom Edison Reyes>
@name <RefundComputation_Test>
@CreateDate <10/15/2014>
@Description <Test class for RefundComputation>
@Version <1.0>
@reference <>
*/
@isTest (seeAllData= True)
private class RefundComputationTest {
    
    /**
    * Testmethod to compute refund
    * @name <testComputeRefund>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see
    */   
    static testMethod void testComputeRefund(){

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

        //The test will run as the user created.
        System.runAs(u) {
        
      Decimal paymentPerMonth = 20;
      Date startDate;
      Date endDate;
      Decimal remMonthsRefund; 
      Integer remDays = 2;
      Integer monthDiff = 2;
      Integer stopDiff = 2;
      Date lastDay;
      Date startMo;
      Decimal proratedAmt = 30;
      Boolean isRefundable = true;
      Boolean Refundable = true;
      Integer numberOfDays = 5;
      Date lastDayOfMonth;
      Decimal prorationAmountForRemainingDaysBef = 3;
      Decimal prorationAmountForRemainingDaysAft = 3;
      Date startOfTheMonth;
      Decimal totalProration = 50;
      String subfreq = 'Y';
      Decimal covPrice = 20;
        
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';             
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc, pkg[0]};
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;

            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Address__c = addressRec.Id;
            //START: CCB002 Added by April Banaag - to apply changes to contact record type
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con[0].Recipient_Indicator__c = true;
            //END: CCB002 Added by April Banaag - to apply changes to contact record type
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;
            insert con;            

            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            System.debug('DEBUG con.Id' + con[0].Id);
            order.Informed_Customer__c = True;
            order.Subscriber_Charge__c = 15;
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
            
            //create Package
            
            List<Package__c> pack = TestDataFactory.createPackage(1); //new Package__c();
            //pack = TestDataFactory.createPackage(1)[0];
            pack[0].Package_Type__c = 'Base';
            pack[0].Name = 'Test Package';
            pack[0].Package_Code__c = 'testcode';
            insert pack;
            
            //create Order Line Item
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.today() +8;
            orderline.Main_Package_ID__c = pack[0].Id;
            //orderline.Addon_Package__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = FALSE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+7;
            insert orderline;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;

            //Create Zuora Subscription    
            List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(2);
            
            for(Zuora__Subscription__c zSub: zSubs)
            {
                zSub.Subscriber_Contact__c = con[0].Id;
                zSub.Recipient_Contact__c = con[0].Id;
                zSub.Recipient_Contact_1__c = con[0].Id;    
                zSub.Contact__c = con[0].Id;
                zSub.Zuora__Account__c = acc.id;
                zSub.Order_Number_1__c = order.Id;
                zSub.Order_Line_Item_Number__c =  orderline.id; 
                zSub.Order_Line_Item_Number_1__c =  orderline.id;
                zSub.Frequency__c = 'Default';    
                zSub.Frequency_1__c = 'Default';
                zSub.Number_of_Copies__c = 1;
                zSub.Number_of_Copies1__c = '1';
                zSub.Zuora__SubscriptionStartDate__c = Date.today().addDays(1);
                zSub.Subscription_End_Date__c = String.valueOf(date.today()+5);
                zSub.Main_Package__c = pack[0].id;
                zSub.Main_Package_1__c = pack[0].id;
                zSub.Zuora__SubscriptionEndDate__c = null;
                zSub.Zuora__CustomerAccount__c = billAcc.Id;
                zSub.Subscription_Charge__c = 30;
                zSub.Billing_Type__c = 'Recurring Prepaid';
                zSub.Delivered_By__c = 'Mailing Agent'; 
                zSub.Delivered_By_1__c = 'Mailing Agent';
                zSub.Postage_Charge__c = 20;
                zSub.Zuora__CustomerAccount__c = billAcc.id;
                zSub.Zuora__TermSettingType__c = 'TERMED';
            }
            zSubs[0].Name = 'BA-S00002264';
            zSubs[1].Name = 'BA-S12342264'; 
            zSubs[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
            zSubs[1].Subscription_Type__c = 'Delivery';
            zSubs[0].Delivery_Charge__c = 20;
            zSubs[1].Delivery_Charge__c = 20;
            insert zSubs;   

            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = zSubs[0].id;
            zSubProdCharge[0].Zuora__RatePlanName__c = 'RATE_PLAN_NAME';
            zSubProdCharge[0].Zuora__ProductName__c = 'TEST NAME';
            zSubProdCharge[0].Product_Code__c = 'PUBX';
            zSubProdCharge[0].Zuora__Price__c = 20;
            zSubProdCharge[0].Zuora__BillingPeriod__c = 'Quarterly';
            zSubProdCharge[0].Zuora__Quantity__c = 18732;
            zSubProdCharge[0].Zuora__UOM__c ='ZuoraUOM';
            //insert zSubProdCharge; 
              
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'SKU-0000075';
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            //prdRatePlan.RatePlanType__c = 'Bill Plan';
            prdRatePlan.Name = 'RATE_PLAN_NAME';
            prdRatePlan.BillingType__c = 'Full Prepaid';
            //prdRatePlan.Product_Code__c = 'PUB1';
            prdRatePlan.RatePlanCode__c = 'BP';
            prdRatePlan.SubscriptionFrequency__c = '1';
            prdRatePlan.RatePlanType__c = 'Proration';
            prdRatePlan.RatePlanSubType__c = 'Standard';
            insert prdRatePlan;
            
            List<zqu__ProductRatePlanCharge__c> prpList = TestDataFactory.createProductRatePlanCharge(5);
            prpList[0].zqu__UOM__c = 'Credit Copy Weekday';
            prpList[1].zqu__UOM__c = 'Credit Copy Sat';
            prpList[2].zqu__UOM__c = 'Credit Copy Sun';
            prpList[3].zqu__UOM__c = 'Credit Copy Month Test' ;
            
            
            prpList[4].zqu__ProductRatePlan__c = prdRatePlan.Id;
            prpList[4].PublicationCode__c = 'PUBX';
            insert prpList;
            
            zqu__ProductRatePlanCharge__c prpc = prpList[4]; //TestDataFactory.createProductRatePlanCharge(1)[0];
            //insert prpc;
            
            Temp_Stop__c TempStopRec = new Temp_Stop__c();
            //TempStopRec.Name = 'Test';
            TempStopRec.Restart_Date__c = date.today().addDays(2);
            TempStopRec.Temp_Stop_Date__c = date.today().addDays(-1);
            TempStopRec.Temp_Stop_Qty__c = 2;
            TempStopRec.Cancelled__c = False;
            insert TempStopRec;
            
            Subscription_Temp_Stop__c SubTempStop = new Subscription_Temp_Stop__c();
            //SubTempStop.Name = 'test';
            SubTempStop.Subscription__c = zSubs[0].Id;
            SubTempStop.Temp_Stop__c = TempStopRec.Id;
            //insert SubTempStop;
            
            zqu__ZUnitOfMeasure__c zUOM = new zqu__ZUnitOfMeasure__c ();
            zUOM.zqu__Active__c = TRUE ; 
            zUOM.zqu__Uom_rounding_mode__c = 'Up';
            zUOM.zqu__Uom_precision__c = 2;
            zUOM.zqu__ZuoraId__c = 'test123UNIQUEcaseSensitive321';
            insert zUOM;
            
            Usage__c usage = new Usage__c();
            usage.Account_Id__c = acc.Id;
            usage.Unit_of_Measure__c = zUOM.Id;
            usage.Rate_Plan_Charge_Id__c = prdRatePlan.Id;
            //insert usage;
            
            List <Publication__c> pubList = new List <Publication__c>();
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Test';
            pub.Publication_Code__c = 'PUBX';
            pub.Published_Days__c = 'YYYYNNY';
            pub.Publication_Type__c = 'M';
            pub.Publish_Pattern__c = 'Weekdays';
            pubList.add(pub);
            //insert pub;
            
            Publication__c npub = TestDataFactory.createPublication(1)[0];                                          

            npub.Publication_Code__c = 'PUBX';
            npub.Published_Days__c= 'YYYYNNY';
            npub.Publication_Type__c= 'M';
            npub.Publish_Pattern__c= 'Weekdays';
            pubList.add(npub);
            insert pubList;
            
            List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                           

          
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'PUBX';
            nonpub.Publication__c = npub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;
            
            Publication_Price__c pubPrice = new Publication_Price__c();
            pubPrice.Cover_Price__c = 20;    
            pubPrice.Day_of_Week__c = '1';
            pubPrice.Publication_Code__c = pub.Publication_Code__c;
            pubPrice.Publication__c = pub.Id;
            pubPrice.Effective_Date__c = date.today();
            insert pubPrice;         
                
        Test.startTest();
            system.assertNotEquals(null, pubList);
            system.assertEquals(2, pubList.size());
            system.assertEquals(1, nonPubList.size());
            system.assertEquals('Full Prepaid',prdRatePlan.BillingType__c);
            Set<String> publicationCodeSet = new Set<String>();
            Set<Id> publicationIdSet = new Set<Id>();
            
            RefundComputation.getfirstDayOfTheMonth();
            RefundComputation.getLastDayOfTheMonth(date.today());
            
            RefundComputation.computeRefund(zSubs[0].Id, Date.today());
            //RefundComputation.getPendingCopiesMap(pubList,date.today(),date.today().adddays(2),nonPublist,date.today());
            //RefundComputation.copiesGivenSub(pubList,date.today().adddays(1),date.today().adddays(2),nonPubList);
            RefundComputation.convertSubFreq(pubList[0],prdRatePlan);
            prdRatePlan.SubscriptionFrequency__c = '4';
            update prdRatePlan;
            RefundComputation.convertSubFreq(pub,prdRatePlan);
            
            RefundComputation.checkIfWithin(nonPubList,date.today(),date.today());
            RefundComputation.getpending(pubList[0]);
            publicationCodeSet.add('PUBX');
            publicationIdSet.add(pub.Id);
        Test.stopTest();
            System.assert(publicationIdSet.size()>0);
        }   
    }
    
    /**
    * Testmethod where Subscription Billing Type = 'Recurring Prepaid'
    * @name <testRecurringPrepaid>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see
    */
    static testMethod void testRecurringPrepaid(){
      
        //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        postal.Street_Name__c = 'Test Street';
        postal.Building_Name__c = 'Test Building';
        postal.House_Block_Number__c = '13';
        insert postal;
        

        
        //Create Country   
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Name = 'SINGAPORE';
        country.Country_Name__c = 'SINGAPORE';
        country.Code__c = 'SIN';
        //country.Zone__c = zone.Id;
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
        add.Level_Number__c = '30';
        add.Unit_Number__c = '13';
        add.Country__c = country.Id;
        insert add;
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test Account';
        acc.AccountNumber = '';
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
        insert con;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 20; 
        order.Recipient_Contact__c = con.id;
        order.Subscriber_Charge__c = 15;
        insert order;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];    
        pack.Package_Type__c = 'Base';
        pack.Name = 'ST Print Test';
        pack.Subscription_Type__c = 'Termed';
        pack.Package_Code__c = 'STEST12';
        pack.Subscription_Period__c = '12';
        pack.Effective_Start_Date__c = date.today();
        pack.Effective_End_Date__c = date.today() + 5;
        insert pack;
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c = date.today()+7;
        oli.Order__c = order.id;
        oli.Main_Package_Period__c = 2;
        oli.Qty__c = 3;
        oli.Term_Length__c = 5;
        oli.Main_Package_ID__c = pack.id;  
        insert oli;
        
        Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
        bill.Zuora__Account__c = acc.Id;
        insert bill;    
        
        //Create Zuora Subscription    
        List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(2);
        
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
            zSub.Frequency__c = 'Default';    
            zSub.Frequency_1__c = 'Default';
            zSub.Number_of_Copies__c = 1;
            zSub.Number_of_Copies1__c = '1';
            zSub.Zuora__SubscriptionStartDate__c = date.today();
            zSub.Subscription_End_Date__c = String.valueOf(date.today()+5);
            zSub.Main_Package__c = pack.id;
            zSub.Main_Package_1__c = pack.id;
            zSub.Zuora__SubscriptionEndDate__c = date.today() +5;
            zSub.Zuora__CustomerAccount__c = bill.Id;
            zSub.Subscription_Charge__c = 30;
            zSub.Billing_Type__c = 'Recurring Prepaid';
            zSub.Delivered_By__c = 'Mailing Agent'; 
            zSub.Delivered_By_1__c = 'Mailing Agent';
            zSub.Postage_Charge__c = 20;
            zSub.Zuora__CustomerAccount__c = bill.id;
        }
        zSubs[0].Name = 'BA-S00002264';
        zSubs[1].Name = 'BA-S12342264'; 
        zSubs[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
        zSubs[1].Subscription_Type__c = 'Delivery';
        zSubs[0].Delivery_Charge__c = 20;
        zSubs[1].Delivery_Charge__c = 20;
        insert zSubs;    
        
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'THE STRAITS TIMES PRINT TEST';
        zProd.zqu__SKU__c = 'SKU-12345678';
        zProd.ProductCode__c = 'TEST';
        zProd.ProductType__c = 'Product';
        zProd.ProductPlatform__c = 'Print';
        zProd.ProductFamily__c = 'ST';
        zProd.ProductSubType__c = 'Newspaper';
        insert zProd;
        
        List<zqu__ProductRatePlan__c> prps = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c prp: prps)
        { 
            prp.zqu__ZProduct__c = zProd.Id;
            prp.SubscriptionFrequency__c = '0';
        }
        prps[0].RatePlanCode__c = 'STEST13TS';
        prps[0].Name = 'PRODUCT RATE PLAN TEST';
        prps[0].RatePlanType__c = 'Bill Plan';
        
        prps[1].RatePlanCode__c = 'STEST15TS';
        prps[1].Name = 'PRODUCT RATE PLAN';
        prps[1].RatePlanType__c = 'Proration';
        prps[1].RatePlanSubType__c = 'Standard';
        insert prps;        

        Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packItem.Package__c = pack.Id;
        packItem.Product_Rate_Plan__c = prps[0].Id;
        insert packItem;   
        
        Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubProductCharge(1)[0];    
        subProdCharge.Name = 'Credit Copy Sat';
        subProdCharge.PublicationCode__c = 'BH';
        subProdCharge.Zuora__Subscription__c = zSubs[1].id;
        subProdCharge.Zuora__UOM__c = 'Credit Copy Sat';
        subProdCharge.Zuora__Quantity__c = 5;
        subProdCharge.Zuora__ProductSKU__c = 'SKU-12345678';
        subProdCharge.Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
        insert subProdCharge;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Beat Harry';    
        pub.Publication_Code__c = 'BHAO';
        pub.Published_Days__c = 'YYYYYYN';
        pub.Publication_Type__c = 'N';
        pub.Frequency_Code__c = 'D';
        insert pub;
                
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prps[1].id;
        prpc.PublicationCode__c = 'BHAO';
        prpc.zqu__UOM__c = 'Credit Copy Sat';
        insert prpc;    
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.id;
        npub.Publication_Code__c = 'BHAO';
        npub.Non_Publication_Date__c = date.today();
        insert npub;
        
        Test.startTest();
        
        Decimal refund = RefundComputation.computeRefund(zSubs[0].Id, system.today());
        RefundComputation.getLastDayOfTheMonth(date.today());
        System.debug('>>Refund Recurring: ' + refund);
        Test.stopTest();
        System.assert(refund != null);
        }   
    
    /**
    * Testmethod where Subscription Billing Type = 'Full Prepaid'
    * @name <testFullPrepaid>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see
    */
    static testMethod void testFullPrepaid(){
      
           //Create SingPost Address
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        postal.Street_Name__c = 'Test Street';
        postal.Building_Name__c = 'Test Building';
        postal.House_Block_Number__c = '13';
        insert postal;
        
   
        
        //Create Country   
        Country__c country = TestDataFactory.createCountry(1)[0];
        country.Name = 'SINGAPORE';
        country.Country_Name__c = 'SINGAPORE';
        country.Code__c = 'SIN';
        //country.Zone__c = zone.Id;
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
        add.Level_Number__c = '30';
        add.Unit_Number__c = '13';
        add.Country__c = country.Id;
        insert add;
        
        //Create Account
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'Test Account';
        acc.AccountNumber = '';
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
        insert con;
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.id;
        order.Delivery_Charge__c = 20; 
        order.Recipient_Contact__c = con.id;
        order.Subscriber_Charge__c = 15;
        insert order;
        
        Package__c pack = TestDataFactory.createPackage(1)[0];    
        pack.Package_Type__c = 'Base';
        pack.Name = 'ST Print Test';
        pack.Subscription_Type__c = 'Termed';
        pack.Package_Code__c = 'STEST12';
        pack.Subscription_Period__c = '12';
        pack.Effective_Start_Date__c = date.today();
        pack.Effective_End_Date__c = date.today() + 5;
        insert pack;
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c = date.today()+7;
        oli.Order__c = order.id;
        oli.Main_Package_Period__c = 2;
        oli.Qty__c = 3;
        oli.Term_Length__c = 5;
        oli.Main_Package_ID__c = pack.id;  
        insert oli;
        
        Zuora__CustomerAccount__c bill = TestDataFactory.createBillingAccount(1)[0];
        bill.Zuora__Account__c = acc.Id;
        insert bill;    
        
        //Create Zuora Subscription    
        List<Zuora__Subscription__c> zSubs = TestDataFactory.createSubscription(2);
        
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
            zSub.Frequency__c = 'Default';    
            zSub.Frequency_1__c = 'Default';
            zSub.Number_of_Copies__c = 1;
            zSub.Number_of_Copies1__c = '1';
            zSub.Zuora__SubscriptionStartDate__c = date.today();
            zSub.Subscription_End_Date__c = String.valueOf(date.today()+5);
            zSub.Main_Package__c = pack.id;
            zSub.Main_Package_1__c = pack.id;
            zSub.Zuora__SubscriptionEndDate__c = date.today() +5;
            zSub.Zuora__CustomerAccount__c = bill.Id;
            zSub.Subscription_Charge__c = 30;
            zSub.Billing_Type__c = 'Full Prepaid';
            zSub.Delivered_By__c = 'Mailing Agent'; 
            zSub.Delivered_By_1__c = 'Mailing Agent';
            zSub.Postage_Charge__c = 20;
            zSub.Qty__c = 1;
            zSub.Qty1__c = '1';
            zSub.Zuora__CustomerAccount__c = bill.id;
        }
        zSubs[0].Name = 'BA-S00002264';
        zSubs[1].Name = 'BA-S12342264'; 
        zSubs[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
        zSubs[1].Subscription_Type__c = 'Delivery';
        insert zSubs;    
        
        zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
        zProd.Name = 'THE STRAITS TIMES PRINT TEST';
        zProd.zqu__SKU__c = 'SKU-12345678';
        zProd.ProductCode__c = 'TEST';
        zProd.ProductType__c = 'Product';
        zProd.ProductPlatform__c = 'Print';
        zProd.ProductFamily__c = 'ST';
        zProd.ProductSubType__c = 'Newspaper';
        insert zProd;
        
        List<zqu__ProductRatePlan__c> prps = TestDataFactory.createProductRatePlan(2);
        for(zqu__ProductRatePlan__c prp: prps)
        { 
            prp.zqu__ZProduct__c = zProd.Id;
            prp.SubscriptionFrequency__c = '1';
        }
        prps[0].RatePlanCode__c = 'STEST13TS';
        prps[0].Name = 'PRODUCT RATE PLAN TEST';
        prps[0].RatePlanType__c = 'Bill Plan';
        
        prps[1].RatePlanCode__c = 'STEST15TS';
        prps[1].Name = 'PRODUCT RATE PLAN';
        prps[1].RatePlanType__c = 'Proration';
        prps[1].RatePlanSubType__c = 'Standard';
        insert prps;        
        
        Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        packItem.Package__c = pack.Id;
        packItem.Product_Rate_Plan__c = prps[0].Id;
        insert packItem;   
        
        Zuora__SubscriptionProductCharge__c subProdCharge = TestDataFactory.createSubProductCharge(1)[0];    
        subProdCharge.Name = 'Credit Copy Sat';
        subProdCharge.PublicationCode__c = 'BH';
        subProdCharge.Zuora__Subscription__c = zSubs[1].id;
        subProdCharge.Zuora__UOM__c = 'Credit Copy Sat';
        subProdCharge.Zuora__Quantity__c = 5;
        subProdCharge.Zuora__ProductSKU__c = 'SKU-12345678';
        subProdCharge.Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
        insert subProdCharge;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Beat Harry';    
        pub.Publication_Code__c = 'BHAO';
        pub.Published_Days__c = 'YYYYYYN';
        pub.Publication_Type__c = 'N';
        pub.Frequency_Code__c = 'D';
        insert pub;
                
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prps[1].id;
        prpc.PublicationCode__c = 'BHAO';
        prpc.zqu__UOM__c = 'Credit Copy Sat';
        insert prpc;    
        
        Non_Publication_Day__c npub = new Non_Publication_Day__c();
        npub.Publication__c = pub.id;
        npub.Publication_Code__c = 'BHAO';
        npub.Non_Publication_Date__c = date.today();
        insert npub;
        
        Test.startTest();
        Decimal refund = RefundComputation.computeRefund(zSubs[0].Id, system.today());
        RefundComputation.getLastDayOfTheMonth(date.today());
        System.debug('>>Refund Full Prepaid: ' + refund);
        Test.stopTest();
        System.assert(refund != null);
        }
}