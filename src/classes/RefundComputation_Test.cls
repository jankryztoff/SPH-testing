@isTest (seeAllData= True)
private class RefundComputation_Test {
    
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
            order.Subscriber_Charge__c = 10.00;
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
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Base';
            pack.Name = 'Test Package';
            pack.Package_Code__c = 'testcode';
            insert pack;
            
            //create Order Line Item
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.today() +5;
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
            orderline.Fee_Waiver__c = FALSE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+3;
            insert orderline;
            
            Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();
            billAcc.Zuora__Account__c = acc.id;
            insert billAcc;
            
            List <Zuora__Subscription__c> SubsList = TestDataFactory.createSubscription(1); //new List <Zuora__Subscription__c>();
            //Zuora__Subscription__c Subs = new Zuora__Subscription__c();
            for(Zuora__Subscription__c Subs: SubsList){
                Subs.Zuora__Account__c = acc.id;
                Subs.Name= 'CS0000000110';
                Subs.Qty__c = 10;
                Subs.Qty1__c = '10';
                Subs.Number_of_Copies__c= 10;
                Subs.Number_of_Copies1__c ='10';
                Subs.Order_Number__c = order.id;
                Subs.Order_Number_1__c = order.id;
                Subs.Next_Earliest_Start_Date__c= date.today();
                Subs.Unique_Address_Id__c= 'asdasdasd';
                Subs.Year_to_Date_Temp_Stop_Days__c= 2;
                Subs.Previous_Year_Temp_Stop_Days__c= 2;
                Subs.Legacy_Create_Date__c='2014-08-07';
                Subs.Legacy_Create_By__c='test';
                Subs.Legacy_Update_Date__c='test';
                Subs.Legacy_Update_By__c='test';
                Subs.Legacy_Subscription_ID__c='test';
                Subs.Cheque_details__c='test';
                Subs.DTL__c='test';
                Subs.Paypal_Payment_Profile_Id__c='test';
                Subs.Pub_Tag__c='test';
                //Subs.Sponsored_Indicator__c=
                Subs.Subscribe_As__c='test';
                Subs.Zuora__SubscriptionStartDate__c= Date.newInstance(2015,07,07);
                Subs.Zuora__SubscriptionEndDate__c= Date.newInstance(2015,10,11);
                Subs.Subscription_Grace_Period_End_Date__c= 'test';
                Subs.Gift_ID__c= 'test';
                Subs.Redeem_Date__c= 'test';
                Subs.Gift_ID_2__c= 'test';
                Subs.Redeem_Date_2__c= 'test';
                Subs.Subscriber_Contact__c= con[0].Id;
                Subs.Recipient_Contact__c= con[0].Id;
                Subs.Subscription_Charge__c= 223.0;
                Subs.Term_Length__c= 2;
                Subs.Order_Line_Item_Number__c= orderline.id;
                Subs.Main_Package_1__c= pack.id;
                Subs.Zuora__Zuora_Id__c= 'test';
                Subs.Delivered_by_1__c = 'Mailing Agent';
                Subs.Billing_Type__c = 'Full Prepaid';
                Subs.Zuora__CustomerAccount__c = billAcc.id;
                Subs.Subscription_Charge__c = 100.00;
            }
            //SubsList.add(Subs);
            insert SubsList;
            
            System.assertNotEquals(null, SubsList[0].id);

            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = SubsList[0].id;
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
            TempStopRec.Restart_Date__c = date.today().addDays(3);
            TempStopRec.Temp_Stop_Date__c = date.today();
            TempStopRec.Temp_Stop_Qty__c = 2;
            TempStopRec.Cancelled__c = False;
            insert TempStopRec;
            
            Subscription_Temp_Stop__c SubTempStop = new Subscription_Temp_Stop__c();
            //SubTempStop.Name = 'test';
            SubTempStop.Subscription__c = SubsList[0].Id;
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
            system.assertEquals(2, pubList.size());
            system.assertEquals(1, nonPubList.size());
            system.assertEquals('Full Prepaid',prdRatePlan.BillingType__c);
            Set<String> publicationCodeSet = new Set<String>();
            Set<Id> publicationIdSet = new Set<Id>();
            
            //RefundComputation.getfirstDayOfTheMonth();
            //RefundComputation.getLastDayOfTheMonth(date.today());
            try
            {
                 RefundComputation.computeRefund(SubsList[0].Id, Date.today());
            }catch(exception e) 
            {
                system.debug(':::ERROR ' + e);
            }
           
            //RefundComputation.getPendingCopiesMap(pubList,date.today(),date.today().adddays(2),nonPublist,date.today());
            //RefundComputation.copiesGivenSub(pubList,date.today().adddays(1),date.today().adddays(2),nonPubList);
            //RefundComputation.convertSubFreq(pubList[0],prdRatePlan);
            //prdRatePlan.SubscriptionFrequency__c = '4';
            //update prdRatePlan;
            //RefundComputation.convertSubFreq(pub,prdRatePlan);
            
            //RefundComputation.checkIfWithin(nonPubList,date.today(),date.today());
            //RefundComputation.getpending(pubList[0]);
            //publicationCodeSet.add('PUBX');
            //publicationIdSet.add(pub.Id);
        Test.stopTest();
            //System.assert(publicationIdSet.size()>0);
        }   
    }

}