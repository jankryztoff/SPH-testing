/**
 * Class Name: <SP_ProrationUtility>
 * @author: <KristinaIranzo>
 * Date: <10/10/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for SP_ProrationUtility>
 * History: April Veloso for code coverage
 */
@isTest (seeAllData=true)
private class SP_ProrationUtilityTest {  
     //private static                                            
    
    /**
    *testmethod that calls the getNonDeliverCredit() method 
    * @name <testGetNonDeliverCredit>
    * @param <none>
    * @return <none>
    * @throws exception-<none>
    * @see 
    */
  testmethod static void testGetNonDeliverCredit()
  {
        //prepareTestData();
       try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
            
            List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
            accList[0].Name = 'Test Account';
            accList[0].AccountNumber = '';
            insert accList;
                   
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            insert packageList;
                  
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id; 
            billAccountList[0].Zuora__AccountNumber__c = '001122';
            insert billAccountList; 
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SIN';
            //country.Zone__c = zone.Id;
            insert country;
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '12';
            add.Unit_Number__c = '13';
            add.Country__c = country.Id;
            insert add;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = accList[0].id;
            con.Address__c = add.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;      
                   
            List<Order__c> orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].id;
            orderList[0].Subscriber_Charge__c = 100; 
            orderList[0].Delivery_Charge__c = 20; 
            orderList[0].Recipient_Contact__c = con.id;  
            orderList[0].Billing_Type__C = 'Full Prepaid';                     
            insert orderList;
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;        
            orderLineItemList[0].Start_Date__c = system.today()+3; //jurna-10-26-15
            insert orderLineItemList;
                     
            List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Name = 'Ron';
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zsubList[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;     
            zsubList[0].Main_Package_1__c = packageList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Product_Code__c = 'CD001';
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Subscription_Type__c = 'Publication';  
            zsubList[0].Zuora__SubscriptionStartDate__c = date.Today() +1;
            zsubList[0].Zuora__SubscriptionEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__TermEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__Status__c = 'Cancelled';
            zsubList[0].Subscription_End_Date__c = String.valueOf(date.today()+90);
            zsubList[0].Delivered_By__c = 'Mailing Agent'; 
            zsubList[0].Delivered_By_1__c = 'Mailing Agent';
            zsubList[0].Billing_Type__c =  'Full Prepaid'; 
            zsubList[0].Number_of_Copies__c= 100;
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Qty__c = 20;
            insert zsubList;      
            //System.debug('Subscription_End_Date__c' + zsubList[0].Zuora__SubscriptionEndDate__c);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Base';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '12';
            pack.Effective_Start_Date__c = date.today();
            pack.Effective_End_Date__c = date.today() + 5;
            insert pack;
             
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
            
            List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);    
            subProdCharge[0].Name = 'Credit Copy Sat';
            subProdCharge[0].PublicationCode__c = 'BHAO';
            subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
            subProdCharge[0].Zuora__UOM__c = 'Credit Copy Weekday';
            subProdCharge[0].Zuora__Quantity__c = 5;
            subProdCharge[0].Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge[0].Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            insert subProdCharge;
            
            Zuora__SubscriptionProductCharge__c spc = new  Zuora__SubscriptionProductCharge__c();
            spc.Zuora__Subscription__c = zsubList[0].id;
            insert spc;
            
            //NewsPaper
            
            List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(1);
            prpc[0].Name = 'Credit Copy Sat';
            prpc[0].zqu__ProductRatePlan__c = prps[0].id;
            prpc[0].PublicationCode__c = 'BHAO';
            prpc[0].zqu__UOM__c = 'Credit Copy Sat';
            insert prpc;    
            
            zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc2.Name = 'April';
            prpc2.zqu__ProductRatePlan__c = prps[1].id;
            prpc2.PublicationCode__c = 'BHAt';
            prpc2.zqu__UOM__c = 'Credit Copy Mon';
            prpc2.zqu__ZuoraId__c = 'ABCDEFG12435';
            insert prpc2;
            
            List<Publication__c> publi = TestDataFactory.createPublication(1);
            publi[0].Name = 'Beat Harry';    
            publi[0].Publication_Code__c = 'BHAO';
            publi[0].Published_Days__c = 'YYYYYYY';
            publi[0].Publication_Type__c = 'M';
            publi[0].Frequency_Code__c = 'D';
            publi[0].Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publi);
            
            Publication__c publica = TestDataFactory.createPublication(1)[0];
            publica.Name = 'Beat Harry';    
            publica.Publication_Code__c = 'BHAO';
            publica.Published_Days__c = 'YYYYYYY';
            publica.Publication_Type__c = 'N';
            publica.Frequency_Code__c = 'D';
            publica.Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publica);
            
            List<Non_Publication_Day__c> npub = TestDataFactory.createNonPublicationDay(1);
            npub[0].Publication__c = publi[0].id;
            npub[0].Publication_Code__c = 'BHAO';
            npub[0].Non_Publication_Date__c = date.today()+1;
            insert npub;
            
            List<Temp_Stop__c> tStop =  TestDataFactory.createTempStop(1);
            tStop[0].Cancelled__c = false;
            tStop[0].Temp_Stop_Date__c = Date.Today() +1;
            tStop[0].Restart_Date__c = date.Today() +45;
            insert tStop;
            
            Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
            tempStop.Temp_Stop__c = tStop[0].id; 
            tempStop.Subscription__c = zsubList[0].id;
            insert tempStop;
           
            Usage__c u2 = new Usage__c(); 
                        
            ID keyId = zsubList[0].id;  
            
            Set<id> subId = new Set<id>();
            subId.add(zsubList[0].id);
            
            Set<Date> dateSet = new Set<Date>();
            dateSet.add(date.today()+14); 
            
            
            //System.debug('SubId' + subId);
            Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();        
            //mapSubsIdToSubProdCharges.put(keyId , subProdCharge);    
             
            Set<String> ratePlanCharges = new Set<String>();
            ratePlanCharges.add('AB123');
            
            //Set<String> pubCodes = new Set<String>;
            
            Map<Id, zqu__ProductRatePlanCharge__c> mapProdRatePlnCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
            //mapProdRatePlnCharge.put(keyId, prpc2);
            // insert mapSubProdChargeIdToProdRatePlanCharge; 
           
                               
            Date endD = date.Today() +45;
            Date startD = Date.Today() +30;
            Date graceEndDate = date.Today() +65;
            String subStatus = 'Active';
            String billingType= 'Recurring Prepaid';
            Id graceSub = null;
            Decimal zuoraQty = 1;
            Boolean isInCopyUom = true;
            Boolean isInCreditCopyUom = true;
            Boolean isInIssueUom = true;
            Boolean isInNoCreditUOM = true;
            Boolean hasMondayIssue = true;
            Boolean hasTuesdayIssue = true;
            Boolean hasWednesdayIssue = true;
            Boolean hasThursdayIssue = true;
            Boolean hasFridayIssue = true;
            Boolean hasSaturdayIssue = true;
            Boolean hasSundayIssue = true;
            
 
            
            Zuora__Subscription__c subList = [SELECT Id, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Zuora__SubscriptionStartDate__c,
                                                Billing_Type__c, Delivered_By_1__c,Zuora__SubscriptionEndDate__c,
                                                (SELECT Zuora__Quantity__c, Zuora__RatePlanName__c, Name, Id, Zuora__ProductSKU__c, Zuora__ChargeNumber__c, Zuora__UOM__c, Zuora__Type__c 
                                                 FROM Zuora__Subscription_Product_Charges__r) x 
                                                FROM Zuora__Subscription__c WHERE id =:zsubList[0].id];
             System.assertnotEquals(null, subList.Zuora__SubscriptionEndDate__c);
            
           /* List<Usage__c> getNonDeliverC = new List<Usage__c>();
            insert getNonDeliverC;*/
     
            /*System.assert(!subId.isEmpty());
            System.Debug('zSub' + zsubList[0].Zuora__SubscriptionEndDate__c);
            System.Debug('endDate' + endD);*/
            
    
     /*Integer monthsBetween = endDate.monthsBetween(zsubList[0].Zuora__SubscriptionEndDate__c);  
     System.assertEquals(3, monthsBetween);*/
             
            Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();
          
           Map<String, Set<Date>> mapPub = new Map<String, Set<Date>> ();
           mapPub.put('BHAO', dateSet);
      
            Test.startTest();
            SP_ProrationUtility controller = new SP_ProrationUtility();
            //List<Usage__c> getNonDeliverC = new SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            List<Usage__c> u = SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            SP_ProrationUtility.populateSubscriptionToSpC(mapSubsIdToSubProdCharges, zsubList, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populateSpCToRatePlanCharge(mapProdRatePlnCharge, prpc, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populatePubCodeToPublication(mapPubCodeToPublication, publi);
            Set<Date> returnDate =  SP_ProrationUtility.getTempStopDateSet(zsubList[0].id, startD , endD );
            
            Usage__c returnU = SP_ProrationUtility.createUsage (dateSet, spc, u2, startD, endD, graceEndDate, subStatus, billingType, graceSub, zuoraQty, isInCopyUom, isInCreditCopyUom, isInIssueUom, isInNoCreditUOM, hasMondayIssue, hasTuesdayIssue, hasWednesdayIssue, hasThursdayIssue, hasFridayIssue, hasSaturdayIssue, hasSundayIssue );
          
            SP_ProrationUtility.populatePubCodeToNonPubDates(mapPub, npub);
     
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_EXPIRED', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_POSTPAID', 1, true, true, true, true, true, true, true, true, true, true);
            Test.stopTest();
       }catch(Zuora.zRemoteException e) {}  
         catch(Zuora.zAPIException e) {}  
  }
  
  testmethod static void testZuoraUOM()
  {
        //prepareTestData();
       try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
            
            List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
            accList[0].Name = 'Test Account';
            accList[0].AccountNumber = '';
            insert accList;
                   
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            insert packageList;
                  
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id; 
            billAccountList[0].Zuora__AccountNumber__c = '001122';
            insert billAccountList; 
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SIN';
            //country.Zone__c = zone.Id;
            insert country;
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '12';
            add.Unit_Number__c = '13';
            add.Country__c = country.Id;
            insert add;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = accList[0].id;
            con.Address__c = add.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;      
                   
            List<Order__c> orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].id;
            orderList[0].Subscriber_Charge__c = 100; 
            orderList[0].Delivery_Charge__c = 20; 
            orderList[0].Recipient_Contact__c = con.id;  
            orderList[0].Billing_Type__C = 'Full Prepaid';                     
            insert orderList;
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;        
            orderLineItemList[0].Start_Date__c = system.today()+3; //jurna-10-26-15
            insert orderLineItemList;
                     
            List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Name = 'Ron';
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zsubList[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;     
            zsubList[0].Main_Package_1__c = packageList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Product_Code__c = 'CD001';
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Subscription_Type__c = 'Publication';  
            zsubList[0].Zuora__SubscriptionStartDate__c = date.Today() +1;
            zsubList[0].Zuora__SubscriptionEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__TermEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__Status__c = 'Cancelled';
            zsubList[0].Subscription_End_Date__c = String.valueOf(date.today()+90);
            zsubList[0].Delivered_By__c = 'Mailing Agent'; 
            zsubList[0].Delivered_By_1__c = 'Mailing Agent';
            zsubList[0].Billing_Type__c =  'Full Prepaid'; 
            zsubList[0].Number_of_Copies__c= 100;
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Qty__c = 20;
            insert zsubList;      
            //System.debug('Subscription_End_Date__c' + zsubList[0].Zuora__SubscriptionEndDate__c);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Base';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '12';
            pack.Effective_Start_Date__c = date.today();
            pack.Effective_End_Date__c = date.today() + 5;
            insert pack;
             
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
            
            List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);    
            subProdCharge[0].Name = 'Credit Copy Sat';
            subProdCharge[0].PublicationCode__c = 'BHAO';
            subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
            subProdCharge[0].Zuora__UOM__c = 'Credit Copy Sat';
            subProdCharge[0].Zuora__Quantity__c = 5;
            subProdCharge[0].Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge[0].Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            insert subProdCharge;
            
            //NewsPaper
            
            List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(1);
            prpc[0].Name = 'Credit Copy Sat';
            prpc[0].zqu__ProductRatePlan__c = prps[0].id;
            prpc[0].PublicationCode__c = 'BHAO';
            prpc[0].zqu__UOM__c = 'Credit Copy Sat';
            insert prpc;    
            
            zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc2.Name = 'April';
            prpc2.zqu__ProductRatePlan__c = prps[1].id;
            prpc2.PublicationCode__c = 'BHAt';
            prpc2.zqu__UOM__c = 'Credit Copy Mon';
            prpc2.zqu__ZuoraId__c = 'ABCDEFG12435';
            insert prpc2;
            
            List<Publication__c> publi = TestDataFactory.createPublication(1);
            publi[0].Name = 'Beat Harry';    
            publi[0].Publication_Code__c = 'BHAO';
            publi[0].Published_Days__c = 'YYYYYYY';
            publi[0].Publication_Type__c = 'N';
            publi[0].Frequency_Code__c = 'D';
            publi[0].Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publi);
            
            Publication__c publica = TestDataFactory.createPublication(1)[0];
            publica.Name = 'Beat Harry';    
            publica.Publication_Code__c = 'BHAO';
            publica.Published_Days__c = 'YYYYYYY';
            publica.Publication_Type__c = 'N';
            publica.Frequency_Code__c = 'B';
            publica.Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publica);
            
            List<Non_Publication_Day__c> npub = TestDataFactory.createNonPublicationDay(1);
            npub[0].Publication__c = publi[0].id;
            npub[0].Publication_Code__c = 'BHAO';
            npub[0].Non_Publication_Date__c = date.today()+1;
            insert npub;
            
            ID keyId = zsubList[0].id;  
            
            Set<id> subId = new Set<id>();
            subId.add(zsubList[0].id);
            
            Set<Date> dateSet = new Set<Date>();
            dateSet.add(date.today()+14); 
            
           
            Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();        
            
            Set<String> ratePlanCharges = new Set<String>();
            ratePlanCharges.add('AB123');
            
                        
            Map<Id, zqu__ProductRatePlanCharge__c> mapProdRatePlnCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
          
           
            Date endD = date.Today() +45;
            Date startD = Date.Today() +30;
            
            Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();
       
            Test.startTest();
           
            SP_ProrationUtility controller = new SP_ProrationUtility();
            List<Usage__c> u = SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            SP_ProrationUtility.populateSubscriptionToSpC(mapSubsIdToSubProdCharges, zsubList, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populateSpCToRatePlanCharge(mapProdRatePlnCharge, prpc, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populatePubCodeToPublication(mapPubCodeToPublication, publi);
           
           Test.stopTest();
       }catch(Zuora.zRemoteException e) {}  
         catch(Zuora.zAPIException e) {}  
  }
  testmethod static void testZuoraUOM2()
  {
        //prepareTestData();
       try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
            
            List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
            accList[0].Name = 'Test Account';
            accList[0].AccountNumber = '';
            insert accList;
                   
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            insert packageList;
                  
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id; 
            billAccountList[0].Zuora__AccountNumber__c = '001122';
            insert billAccountList; 
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SIN';
            //country.Zone__c = zone.Id;
            insert country;
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '12';
            add.Unit_Number__c = '13';
            add.Country__c = country.Id;
            insert add;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = accList[0].id;
            con.Address__c = add.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;      
                   
            List<Order__c> orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].id;
            orderList[0].Subscriber_Charge__c = 100; 
            orderList[0].Delivery_Charge__c = 20; 
            orderList[0].Recipient_Contact__c = con.id;  
            orderList[0].Billing_Type__C = 'Full Prepaid';                     
            insert orderList;
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;        
            orderLineItemList[0].Start_Date__c = system.today()+3; //jurna-10-26-15
            insert orderLineItemList;
                     
            List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Name = 'Ron';
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zsubList[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;     
            zsubList[0].Main_Package_1__c = packageList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Product_Code__c = 'CD001';
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Subscription_Type__c = 'Publication';  
            zsubList[0].Zuora__SubscriptionStartDate__c = date.Today() +1;
            zsubList[0].Zuora__SubscriptionEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__TermEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__Status__c = 'Cancelled';
            zsubList[0].Subscription_End_Date__c = String.valueOf(date.today()+90);
            zsubList[0].Delivered_By__c = 'Mailing Agent'; 
            zsubList[0].Delivered_By_1__c = 'Mailing Agent';
            zsubList[0].Billing_Type__c =  'Full Prepaid'; 
            zsubList[0].Number_of_Copies__c= 100;
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Qty__c = 20;
            insert zsubList;      
            //System.debug('Subscription_End_Date__c' + zsubList[0].Zuora__SubscriptionEndDate__c);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Base';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '12';
            pack.Effective_Start_Date__c = date.today();
            pack.Effective_End_Date__c = date.today() + 5;
            insert pack;
             
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
                prp.SubscriptionFrequency__c = '2';
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
            
            List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);    
            subProdCharge[0].Name = 'Credit Copy Sat';
            subProdCharge[0].PublicationCode__c = 'BHAO';
            subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
            subProdCharge[0].Zuora__UOM__c = 'Credit Copy Sun';
            subProdCharge[0].Zuora__Quantity__c = 5;
            subProdCharge[0].Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge[0].Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            insert subProdCharge;
            
            //NewsPaper
            
            List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(1);
            prpc[0].Name = 'Credit Copy Sat';
            prpc[0].zqu__ProductRatePlan__c = prps[0].id;
            prpc[0].PublicationCode__c = 'BHAO';
            prpc[0].zqu__UOM__c = 'Credit Copy Sat';
            insert prpc;    
            
            zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc2.Name = 'April';
            prpc2.zqu__ProductRatePlan__c = prps[1].id;
            prpc2.PublicationCode__c = 'BHAt';
            prpc2.zqu__UOM__c = 'Credit Copy Mon';
            prpc2.zqu__ZuoraId__c = 'ABCDEFG12435';
            insert prpc2;
            
            List<Publication__c> publi = TestDataFactory.createPublication(1);
            publi[0].Name = 'Beat Harry';    
            publi[0].Publication_Code__c = 'BHAO';
            publi[0].Published_Days__c = 'YYYYYYY';
            publi[0].Publication_Type__c = 'N';
            publi[0].Frequency_Code__c = 'D';
            publi[0].Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publi);
            
            Publication__c publica = TestDataFactory.createPublication(1)[0];
            publica.Name = 'Beat Harry';    
            publica.Publication_Code__c = 'BHAO';
            publica.Published_Days__c = 'YYYYYYY';
            publica.Publication_Type__c = 'N';
            publica.Frequency_Code__c = 'Y';
            publica.Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publica);
            
            List<Non_Publication_Day__c> npub = TestDataFactory.createNonPublicationDay(1);
            npub[0].Publication__c = publi[0].id;
            npub[0].Publication_Code__c = 'BHAO';
            npub[0].Non_Publication_Date__c = date.today()+1;
            insert npub;
            
            ID keyId = zsubList[0].id;  
            
            Set<id> subId = new Set<id>();
            subId.add(zsubList[0].id);
            
            Set<Date> dateSet = new Set<Date>();
            dateSet.add(date.today()+14); 
            
           
            Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();        
            
            Set<String> ratePlanCharges = new Set<String>();
            ratePlanCharges.add('AB123');
            
                        
            Map<Id, zqu__ProductRatePlanCharge__c> mapProdRatePlnCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
          
           
            Date endD = date.Today() +45;
            Date startD = Date.Today() +30;
            Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();
               
            Test.startTest();
            SP_ProrationUtility controller = new SP_ProrationUtility();
           
            List<Usage__c> u = SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            SP_ProrationUtility.populateSubscriptionToSpC(mapSubsIdToSubProdCharges, zsubList, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populateSpCToRatePlanCharge(mapProdRatePlnCharge, prpc, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populatePubCodeToPublication(mapPubCodeToPublication, publi);
            Test.stopTest();
       }catch(Zuora.zRemoteException e) {}  
         catch(Zuora.zAPIException e) {}  
  }
   testmethod static void testcreateUsage2()
  {
        //prepareTestData();
       try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
            
            List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
            accList[0].Name = 'Test Account';
            accList[0].AccountNumber = '';
            insert accList;
                   
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            insert packageList;
                  
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id; 
            billAccountList[0].Zuora__AccountNumber__c = '001122';
            insert billAccountList; 
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SIN';
            //country.Zone__c = zone.Id;
            insert country;
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '12';
            add.Unit_Number__c = '13';
            add.Country__c = country.Id;
            insert add;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = accList[0].id;
            con.Address__c = add.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;      
                   
            List<Order__c> orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].id;
            orderList[0].Subscriber_Charge__c = 100; 
            orderList[0].Delivery_Charge__c = 20; 
            orderList[0].Recipient_Contact__c = con.id;  
            orderList[0].Billing_Type__C = 'Full Prepaid';                     
            insert orderList;
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;        
            orderLineItemList[0].Start_Date__c = system.today()+3; //jurna-10-26-15
            insert orderLineItemList;
                     
            List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Name = 'Ron';
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zsubList[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;     
            zsubList[0].Main_Package_1__c = packageList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Product_Code__c = 'CD001';
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Subscription_Type__c = 'Publication';  
            zsubList[0].Zuora__SubscriptionStartDate__c = date.Today() +1;
            zsubList[0].Zuora__SubscriptionEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__TermEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__Status__c = 'Cancelled';
            zsubList[0].Subscription_End_Date__c = String.valueOf(date.today()+90);
            zsubList[0].Delivered_By__c = 'Mailing Agent'; 
            zsubList[0].Delivered_By_1__c = 'Mailing Agent';
            zsubList[0].Billing_Type__c =  'Full Prepaid'; 
            zsubList[0].Number_of_Copies__c= 100;
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Qty__c = 20;
            insert zsubList;      
            //System.debug('Subscription_End_Date__c' + zsubList[0].Zuora__SubscriptionEndDate__c);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Base';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '12';
            pack.Effective_Start_Date__c = date.today();
            pack.Effective_End_Date__c = date.today() + 5;
            insert pack;
             
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
                prp.SubscriptionFrequency__c = '3';
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
            
            List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);    
            subProdCharge[0].Name = 'Credit Copy Sat';
            subProdCharge[0].PublicationCode__c = 'BHAO';
            subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
            subProdCharge[0].Zuora__UOM__c = 'Credit Copy Weekday';
            subProdCharge[0].Zuora__Quantity__c = 5;
            subProdCharge[0].Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge[0].Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            insert subProdCharge;
            
            Zuora__SubscriptionProductCharge__c spc = new  Zuora__SubscriptionProductCharge__c();
            spc.Zuora__Subscription__c = zsubList[0].id;
            insert spc;
            
            //NewsPaper
            
            List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(1);
            prpc[0].Name = 'Credit Copy Sat';
            prpc[0].zqu__ProductRatePlan__c = prps[0].id;
            prpc[0].PublicationCode__c = 'BHAO';
            prpc[0].zqu__UOM__c = 'Credit Copy Sat';
            insert prpc;    
            
            zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc2.Name = 'April';
            prpc2.zqu__ProductRatePlan__c = prps[1].id;
            prpc2.PublicationCode__c = 'BHAt';
            prpc2.zqu__UOM__c = 'Credit Copy Mon';
            prpc2.zqu__ZuoraId__c = 'ABCDEFG12435';
            insert prpc2;
            
            List<Publication__c> publi = TestDataFactory.createPublication(1);
            publi[0].Name = 'Beat Harry';    
            publi[0].Publication_Code__c = 'BHAO';
            publi[0].Published_Days__c = 'YYYYYYY';
            publi[0].Publication_Type__c = 'M';
            publi[0].Frequency_Code__c = 'M';
            publi[0].Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publi);
            
            Publication__c publica = TestDataFactory.createPublication(1)[0];
            publica.Name = 'Beat Harry';    
            publica.Publication_Code__c = 'BHAO';
            publica.Published_Days__c = 'YYYYYYY';
            publica.Publication_Type__c = 'N';
            publica.Frequency_Code__c = 'D';
            publica.Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publica);
            
            List<Non_Publication_Day__c> npub = TestDataFactory.createNonPublicationDay(1);
            npub[0].Publication__c = publi[0].id;
            npub[0].Publication_Code__c = 'BHAO';
            npub[0].Non_Publication_Date__c = date.today()+1;
            insert npub;
            
            List<Temp_Stop__c> tStop =  TestDataFactory.createTempStop(1);
            tStop[0].Cancelled__c = false;
            tStop[0].Temp_Stop_Date__c = Date.Today() +1;
            tStop[0].Restart_Date__c = date.Today() +45;
            insert tStop;
            
            Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
            tempStop.Temp_Stop__c = tStop[0].id; 
            tempStop.Subscription__c = zsubList[0].id;
            insert tempStop;
           
            Usage__c u2 = new Usage__c(); 
                        
            ID keyId = zsubList[0].id;  
            
            Set<id> subId = new Set<id>();
            subId.add(zsubList[0].id);
            
            Set<Date> dateSet = new Set<Date>();
            dateSet.add(date.today()+14); 
            
            
            //System.debug('SubId' + subId);
            Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();        
            //mapSubsIdToSubProdCharges.put(keyId , subProdCharge);    
             
            Set<String> ratePlanCharges = new Set<String>();
            ratePlanCharges.add('AB123');
            
            //Set<String> pubCodes = new Set<String>;
            
            Map<Id, zqu__ProductRatePlanCharge__c> mapProdRatePlnCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
            //mapProdRatePlnCharge.put(keyId, prpc2);
            // insert mapSubProdChargeIdToProdRatePlanCharge; 
           
         
                      
            Date endD = date.Today() +45;
            Date startD = Date.Today() +30;
            Date graceEndDate = date.Today() +65;
            String subStatus = 'Expired';
            String billingType= 'Recurring Prepaid';
            Id graceSub = null;
            Decimal zuoraQty = 1;
            Boolean isInCopyUom = true;
            Boolean isInCreditCopyUom = true;
            Boolean isInIssueUom = true;
            Boolean isInNoCreditUOM = true;
            Boolean hasMondayIssue = true;
            Boolean hasTuesdayIssue = true;
            Boolean hasWednesdayIssue = true;
            Boolean hasThursdayIssue = true;
            Boolean hasFridayIssue = true;
            Boolean hasSaturdayIssue = true;
            Boolean hasSundayIssue = true;
            
    
                       
             Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();
      
            Test.startTest();
            SP_ProrationUtility controller = new SP_ProrationUtility();
            //List<Usage__c> getNonDeliverC = new SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            List<Usage__c> u = SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            SP_ProrationUtility.populateSubscriptionToSpC(mapSubsIdToSubProdCharges, zsubList, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populateSpCToRatePlanCharge(mapProdRatePlnCharge, prpc, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populatePubCodeToPublication(mapPubCodeToPublication, publi);
            Set<Date> returnDate =  SP_ProrationUtility.getTempStopDateSet(zsubList[0].id, startD , endD );
            
            Usage__c returnU = SP_ProrationUtility.createUsage (dateSet, spc, u2, startD, endD, graceEndDate, subStatus, billingType, graceSub, zuoraQty, isInCopyUom, isInCreditCopyUom, isInIssueUom, isInNoCreditUOM, hasMondayIssue, hasTuesdayIssue, hasWednesdayIssue, hasThursdayIssue, hasFridayIssue, hasSaturdayIssue, hasSundayIssue );
          
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_EXPIRED', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_POSTPAID', 1, true, true, true, true, true, true, true, true, true, true);
            Test.stopTest();
       }catch(Zuora.zRemoteException e) {}  
         catch(Zuora.zAPIException e) {}  
  }
   testmethod static void testcreateUsage3()
  {
        //prepareTestData();
       try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
            
            List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
            accList[0].Name = 'Test Account';
            accList[0].AccountNumber = '';
            insert accList;
                   
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            insert packageList;
                  
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id; 
            billAccountList[0].Zuora__AccountNumber__c = '001122';
            insert billAccountList; 
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SIN';
            //country.Zone__c = zone.Id;
            insert country;
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '12';
            add.Unit_Number__c = '13';
            add.Country__c = country.Id;
            insert add;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = accList[0].id;
            con.Address__c = add.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;      
                   
            List<Order__c> orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].id;
            orderList[0].Subscriber_Charge__c = 100; 
            orderList[0].Delivery_Charge__c = 20; 
            orderList[0].Recipient_Contact__c = con.id;  
            orderList[0].Billing_Type__C = 'Full Prepaid';                     
            insert orderList;
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;        
            orderLineItemList[0].Start_Date__c = system.today()+3; //jurna-10-26-15
            insert orderLineItemList;
                     
            List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Name = 'Ron';
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zsubList[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;     
            zsubList[0].Main_Package_1__c = packageList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Product_Code__c = 'CD001';
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Subscription_Type__c = 'Publication';  
            zsubList[0].Zuora__SubscriptionStartDate__c = date.Today() +1;
            zsubList[0].Zuora__SubscriptionEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__TermEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__Status__c = 'Cancelled';
            zsubList[0].Subscription_End_Date__c = String.valueOf(date.today()+90);
            zsubList[0].Delivered_By__c = 'Mailing Agent'; 
            zsubList[0].Delivered_By_1__c = 'Mailing Agent';
            zsubList[0].Billing_Type__c =  'Recurring Prepaid'; 
            zsubList[0].Number_of_Copies__c= 100;
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Qty__c = 20;
            insert zsubList;      
            //System.debug('Subscription_End_Date__c' + zsubList[0].Zuora__SubscriptionEndDate__c);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Base';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '12';
            pack.Effective_Start_Date__c = date.today();
            pack.Effective_End_Date__c = date.today() + 5;
            insert pack;
             
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
            
            List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);    
            subProdCharge[0].Name = 'Credit Copy Sat';
            subProdCharge[0].PublicationCode__c = 'BHAO';
            subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
            subProdCharge[0].Zuora__UOM__c = 'Credit Copy Weekday';
            subProdCharge[0].Zuora__Quantity__c = 5;
            subProdCharge[0].Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge[0].Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            insert subProdCharge;
            
            Zuora__SubscriptionProductCharge__c spc = new  Zuora__SubscriptionProductCharge__c();
            spc.Zuora__UOM__c = 'Weekday';
            spc.Zuora__ChargeNumber__c = '15';
            spc.Zuora__Subscription__c = zsubList[0].id;
            insert spc;
            
            //NewsPaper
            
            List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(1);
            prpc[0].Name = 'Credit Copy Sat';
            prpc[0].zqu__ProductRatePlan__c = prps[0].id;
            prpc[0].PublicationCode__c = 'BHAO';
            prpc[0].zqu__UOM__c = 'Credit Copy Sat';
            insert prpc;    
            
            zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc2.Name = 'April';
            prpc2.zqu__ProductRatePlan__c = prps[1].id;
            prpc2.PublicationCode__c = 'BHAt';
            prpc2.zqu__UOM__c = 'Credit Copy Mon';
            prpc2.zqu__ZuoraId__c = 'ABCDEFG12435';
            insert prpc2;
            
            List<Publication__c> publi = TestDataFactory.createPublication(1);
            publi[0].Name = 'Beat Harry';    
            publi[0].Publication_Code__c = 'BHAO';
            publi[0].Published_Days__c = 'YYYYYYY';
            publi[0].Publication_Type__c = 'M';
            publi[0].Frequency_Code__c = 'D';
            publi[0].Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publi);
            
            Publication__c publica = TestDataFactory.createPublication(1)[0];
            publica.Name = 'Beat Harry';    
            publica.Publication_Code__c = 'BHAO';
            publica.Published_Days__c = 'YYYYYYY';
            publica.Publication_Type__c = 'N';
            publica.Frequency_Code__c = 'W';
            publica.Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publica);
            
            List<Non_Publication_Day__c> npub = TestDataFactory.createNonPublicationDay(1);
            npub[0].Publication__c = publi[0].id;
            npub[0].Publication_Code__c = 'BHAO';
            npub[0].Non_Publication_Date__c = date.today()+1;
            insert npub;
            
            List<Temp_Stop__c> tStop =  TestDataFactory.createTempStop(1);
            tStop[0].Cancelled__c = false;
            tStop[0].Temp_Stop_Date__c = Date.Today() +1;
            tStop[0].Restart_Date__c = date.Today() +45;
            insert tStop;
            
            Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
            tempStop.Temp_Stop__c = tStop[0].id; 
            tempStop.Subscription__c = zsubList[0].id;
            insert tempStop;
           
            Usage__c u2 = new Usage__c(); 
                        
            ID keyId = zsubList[0].id;  
            
            Set<id> subId = new Set<id>();
            subId.add(zsubList[0].id);
            
            Set<Date> dateSet = new Set<Date>();
            dateSet.add(date.today()+14); 
            
            
            //System.debug('SubId' + subId);
            Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();        
            //mapSubsIdToSubProdCharges.put(keyId , subProdCharge);    
             
            Set<String> ratePlanCharges = new Set<String>();
            ratePlanCharges.add('AB123');
            
            //Set<String> pubCodes = new Set<String>;
            
            Map<Id, zqu__ProductRatePlanCharge__c> mapProdRatePlnCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
            //mapProdRatePlnCharge.put(keyId, prpc2);
            // insert mapSubProdChargeIdToProdRatePlanCharge; 
           
         
                      
            Date endD = date.Today() +45;
            Date startD = Date.Today() +30;
            
            Date substart = date.Today()+1;
            Date subEnd = date.Today()+30;
            Date graceEndDate = date.Today() +65;
            String subStatus = 'Expired';
            String billingType= 'Recurring Postpaid';
            Id graceSub = null;
            Decimal zuoraQty = 1;
            Boolean isInCopyUom = true;
            Boolean isInCreditCopyUom = true;
            Boolean isInIssueUom = true;
            Boolean isInNoCreditUOM = true;
            Boolean hasMondayIssue = true;
            Boolean hasTuesdayIssue = true;
            Boolean hasWednesdayIssue = true;
            Boolean hasThursdayIssue = true;
            Boolean hasFridayIssue = true;
            Boolean hasSaturdayIssue = true;
            Boolean hasSundayIssue = true;
            
 
            
            Zuora__Subscription__c subList = [SELECT Id, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Zuora__SubscriptionStartDate__c,
                                                Billing_Type__c, Delivered_By_1__c,Zuora__SubscriptionEndDate__c,
                                                (SELECT Zuora__Quantity__c, Zuora__RatePlanName__c, Name, Id, Zuora__ProductSKU__c, Zuora__ChargeNumber__c, Zuora__UOM__c, Zuora__Type__c 
                                                 FROM Zuora__Subscription_Product_Charges__r) x 
                                                FROM Zuora__Subscription__c WHERE id =:zsubList[0].id];
             System.assertnotEquals(null, subList.Zuora__SubscriptionEndDate__c);
            
           /* List<Usage__c> getNonDeliverC = new List<Usage__c>();
            insert getNonDeliverC;*/
     
            /*System.assert(!subId.isEmpty());
            System.Debug('zSub' + zsubList[0].Zuora__SubscriptionEndDate__c);
            System.Debug('endDate' + endD);*/
            
    
     /*Integer monthsBetween = endDate.monthsBetween(zsubList[0].Zuora__SubscriptionEndDate__c);  
     System.assertEquals(3, monthsBetween);*/
             
             Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();
      
            Test.startTest();
            SP_ProrationUtility controller = new SP_ProrationUtility();
            //List<Usage__c> getNonDeliverC = new SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            List<Usage__c> u = SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            SP_ProrationUtility.populateSubscriptionToSpC(mapSubsIdToSubProdCharges, zsubList, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populateSpCToRatePlanCharge(mapProdRatePlnCharge, prpc, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populatePubCodeToPublication(mapPubCodeToPublication, publi);
            Set<Date> returnDate =  SP_ProrationUtility.getTempStopDateSet(zsubList[0].id, startD , endD );
            
            Usage__c returnU = SP_ProrationUtility.createUsage (dateSet, spc, u2, substart , subEnd, graceEndDate, subStatus, billingType, graceSub, zuoraQty, isInCopyUom, isInCreditCopyUom, isInIssueUom, isInNoCreditUOM, hasMondayIssue, hasTuesdayIssue, hasWednesdayIssue, hasThursdayIssue, hasFridayIssue, hasSaturdayIssue, hasSundayIssue );
          
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_EXPIRED', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_POSTPAID', 1, true, true, true, true, true, true, true, true, true, true);
            Test.stopTest();
       }catch(Zuora.zRemoteException e) {}  
         catch(Zuora.zAPIException e) {}  
  }
    testmethod static void testcreateUsage4()
      {
        //prepareTestData();
       try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
            
            List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
            accList[0].Name = 'Test Account';
            accList[0].AccountNumber = '';
            insert accList;
                   
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            insert packageList;
                  
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id; 
            billAccountList[0].Zuora__AccountNumber__c = '001122';
            insert billAccountList; 
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SIN';
            insert country;
            //country.Zone__c = zone.Id;
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '12';
            add.Unit_Number__c = '13';
            add.Country__c = country.Id;
            insert add;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = accList[0].id;
            con.Address__c = add.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;      
                   
            List<Order__c> orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].id;
            orderList[0].Subscriber_Charge__c = 100; 
            orderList[0].Delivery_Charge__c = 20; 
            orderList[0].Recipient_Contact__c = con.id;  
            orderList[0].Billing_Type__C = 'Full Prepaid';                     
            insert orderList;
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;        
            orderLineItemList[0].Start_Date__c = system.today()+3; //jurna-10-26-15
            insert orderLineItemList;
                     
            List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Name = 'Ron';
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;
            zsubList[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id;     
            zsubList[0].Main_Package_1__c = packageList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Product_Code__c = 'CD001';
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Subscription_Type__c = 'Publication';  
            zsubList[0].Zuora__SubscriptionStartDate__c = date.Today() +1;
            zsubList[0].Zuora__SubscriptionEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__TermEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__Status__c = 'Cancelled';
            zsubList[0].Subscription_End_Date__c = String.valueOf(date.today()+90);
            zsubList[0].Delivered_By__c = 'Mailing Agent'; 
            zsubList[0].Delivered_By_1__c = 'Mailing Agent';
            zsubList[0].Billing_Type__c =  'Full Prepaid'; 
            zsubList[0].Number_of_Copies__c= 100;
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Qty__c = 20;
            insert zsubList;      
            //System.debug('Subscription_End_Date__c' + zsubList[0].Zuora__SubscriptionEndDate__c);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Base';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '12';
            pack.Effective_Start_Date__c = date.today();
            pack.Effective_End_Date__c = date.today() + 5;
            insert pack;
             
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
            
            List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);    
            subProdCharge[0].Name = 'Credit Copy Sat';
            subProdCharge[0].PublicationCode__c = 'BHAO';
            subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
            subProdCharge[0].Zuora__UOM__c = 'Credit Copy Weekday';
            subProdCharge[0].Zuora__Quantity__c = 5;
            subProdCharge[0].Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge[0].Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            insert subProdCharge;
            
            Zuora__SubscriptionProductCharge__c spc = new  Zuora__SubscriptionProductCharge__c();
            spc.Zuora__Subscription__c = zsubList[0].id;
            insert spc;
            
            //NewsPaper
            
            List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(1);
            prpc[0].Name = 'Credit Copy Sat';
            prpc[0].zqu__ProductRatePlan__c = prps[0].id;
            prpc[0].PublicationCode__c = 'BHAO';
            prpc[0].zqu__UOM__c = 'Credit Copy Sat';
            insert prpc;    
            
            zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc2.Name = 'April';
            prpc2.zqu__ProductRatePlan__c = prps[1].id;
            prpc2.PublicationCode__c = 'BHAt';
            prpc2.zqu__UOM__c = 'Credit Copy Mon';
            prpc2.zqu__ZuoraId__c = 'ABCDEFG12435';
            insert prpc2;
            
            List<Publication__c> publi = TestDataFactory.createPublication(1);
            publi[0].Name = 'Beat Harry';    
            publi[0].Publication_Code__c = 'BHAO';
            publi[0].Published_Days__c = 'YYYYYYY';
            publi[0].Publication_Type__c = 'M';
            publi[0].Frequency_Code__c = 'F';
            publi[0].Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publi);
            
            Publication__c publica = TestDataFactory.createPublication(1)[0];
            publica.Name = 'Beat Harry';    
            publica.Publication_Code__c = 'BHAO';
            publica.Published_Days__c = 'YYYYYYY';
            publica.Publication_Type__c = 'N';
            publica.Frequency_Code__c = 'D';
            publica.Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publica);
            
            List<Non_Publication_Day__c> npub = TestDataFactory.createNonPublicationDay(1);
            npub[0].Publication__c = publi[0].id;
            npub[0].Publication_Code__c = 'BHAO';
            npub[0].Non_Publication_Date__c = date.today()+1;
            insert npub;
            
            List<Temp_Stop__c> tStop =  TestDataFactory.createTempStop(1);
            tStop[0].Cancelled__c = false;
            tStop[0].Temp_Stop_Date__c = Date.Today() +1;
            tStop[0].Restart_Date__c = date.Today() +45;
            insert tStop;
            
            Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
            tempStop.Temp_Stop__c = tStop[0].id; 
            tempStop.Subscription__c = zsubList[0].id;
            insert tempStop;
           
            Usage__c u2 = new Usage__c(); 
                        
            ID keyId = zsubList[0].id;  
            
            Set<id> subId = new Set<id>();
            subId.add(zsubList[0].id);
            
            Set<Date> dateSet = new Set<Date>();
            dateSet.add(date.today()+14); 
            
            
            //System.debug('SubId' + subId);
            Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();        
            //mapSubsIdToSubProdCharges.put(keyId , subProdCharge);    
             
            Set<String> ratePlanCharges = new Set<String>();
            ratePlanCharges.add('AB123');
            
            //Set<String> pubCodes = new Set<String>;
            
            Map<Id, zqu__ProductRatePlanCharge__c> mapProdRatePlnCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
            //mapProdRatePlnCharge.put(keyId, prpc2);
            // insert mapSubProdChargeIdToProdRatePlanCharge; 
           
         
                      
            Date endD = date.Today() +45;
            Date startD = Date.Today() +30;
            Date graceEndDate = date.Today() +65;
            String subStatus = 'Expired';
            String billingType= 'Recurring Postpaid';
            Id graceSub = zsubList[0].id;
            Decimal zuoraQty = 1;
            Boolean isInCopyUom = true;
            Boolean isInCreditCopyUom = true;
            Boolean isInIssueUom = true;
            Boolean isInNoCreditUOM = true;
            Boolean hasMondayIssue = true;
            Boolean hasTuesdayIssue = true;
            Boolean hasWednesdayIssue = true;
            Boolean hasThursdayIssue = true;
            Boolean hasFridayIssue = true;
            Boolean hasSaturdayIssue = true;
            Boolean hasSundayIssue = true;
            
 
            
            Zuora__Subscription__c subList = [SELECT Id, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Zuora__SubscriptionStartDate__c,
                                                Billing_Type__c, Delivered_By_1__c,Zuora__SubscriptionEndDate__c,
                                                (SELECT Zuora__Quantity__c, Zuora__RatePlanName__c, Name, Id, Zuora__ProductSKU__c, Zuora__ChargeNumber__c, Zuora__UOM__c, Zuora__Type__c 
                                                 FROM Zuora__Subscription_Product_Charges__r) x 
                                                FROM Zuora__Subscription__c WHERE id =:zsubList[0].id];
             System.assertnotEquals(null, subList.Zuora__SubscriptionEndDate__c);
            
           /* List<Usage__c> getNonDeliverC = new List<Usage__c>();
            insert getNonDeliverC;*/
     
            /*System.assert(!subId.isEmpty());
            System.Debug('zSub' + zsubList[0].Zuora__SubscriptionEndDate__c);
            System.Debug('endDate' + endD);*/
            
    
     /*Integer monthsBetween = endDate.monthsBetween(zsubList[0].Zuora__SubscriptionEndDate__c);  
     System.assertEquals(3, monthsBetween);*/
             
             Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();
      
            Test.startTest();
            SP_ProrationUtility controller = new SP_ProrationUtility();
            //List<Usage__c> getNonDeliverC = new SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            List<Usage__c> u = SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            SP_ProrationUtility.populateSubscriptionToSpC(mapSubsIdToSubProdCharges, zsubList, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populateSpCToRatePlanCharge(mapProdRatePlnCharge, prpc, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populatePubCodeToPublication(mapPubCodeToPublication, publi);
            Set<Date> returnDate =  SP_ProrationUtility.getTempStopDateSet(zsubList[0].id, startD , endD );
            
            Usage__c returnU = SP_ProrationUtility.createUsage (dateSet, spc, u2, startD, endD, graceEndDate, subStatus, billingType, graceSub, zuoraQty, isInCopyUom, isInCreditCopyUom, isInIssueUom, isInNoCreditUOM, hasMondayIssue, hasTuesdayIssue, hasWednesdayIssue, hasThursdayIssue, hasFridayIssue, hasSaturdayIssue, hasSundayIssue );
          
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_EXPIRED', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_POSTPAID', 1, true, true, true, true, true, true, true, true, true, true);
            Test.stopTest();
       }catch(Zuora.zRemoteException e) {}  
         catch(Zuora.zAPIException e) {}  
    }
  
    testmethod static void testRecurringPrepaid()
    {
        //prepareTestData();
       try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
            
            List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
            accList[0].Name = 'Test Account';
            accList[0].AccountNumber = '';
            insert accList;
                   
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            insert packageList;
                  
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id; 
            billAccountList[0].Zuora__AccountNumber__c = '001122';
            insert billAccountList; 
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SIN';
            //country.Zone__c = zone.Id;
            insert country;
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '12';
            add.Unit_Number__c = '13';
            add.Country__c = country.Id;
            insert add;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = accList[0].id;
            con.Address__c = add.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;      
                   
            List<Order__c> orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].id;
            orderList[0].Subscriber_Charge__c = 100; 
            orderList[0].Delivery_Charge__c = 20; 
            orderList[0].Recipient_Contact__c = con.id;  
            orderList[0].Billing_Type__C = 'Recurring Prepaid';                     
            insert orderList;
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;        
            orderLineItemList[0].Main_Package_Billing_Type__c = 'Recurring Prepaid';
            orderLineItemList[0].Start_Date__c = system.today()+3; //jurna-10-26-15
            insert orderLineItemList;
                     
            List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Name = 'Ron';
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id; 
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;    
            zsubList[0].Main_Package_1__c = packageList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Product_Code__c = 'CD001';
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Subscription_Type__c = 'Publication';  
            zsubList[0].Zuora__SubscriptionStartDate__c = date.Today() +1;
            zsubList[0].Zuora__SubscriptionEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__TermEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__Status__c = 'Cancelled';
            zsubList[0].Subscription_End_Date__c = String.valueOf(date.today()+90);
            zsubList[0].Delivered_By__c = 'Mailing Agent'; 
            zsubList[0].Delivered_By_1__c = 'Mailing Agent';
            zsubList[0].Billing_Type__c =  'Recurring Prepaid'; 
            zsubList[0].Number_of_Copies__c= 100;
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Qty__c = 20;
            insert zsubList;      
            //System.debug('Subscription_End_Date__c' + zsubList[0].Zuora__SubscriptionEndDate__c);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Base';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '12';
            pack.Effective_Start_Date__c = date.today();
            pack.Effective_End_Date__c = date.today() + 5;
            insert pack;
             
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
            
            List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);    
            subProdCharge[0].Name = 'Credit Copy Sat';
            subProdCharge[0].PublicationCode__c = 'BHAO';
            subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
            subProdCharge[0].Zuora__UOM__c = 'Credit Copy Weekday';
            subProdCharge[0].Zuora__Quantity__c = 5;
            subProdCharge[0].Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge[0].Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            insert subProdCharge;
            
            Zuora__SubscriptionProductCharge__c spc = new  Zuora__SubscriptionProductCharge__c();
            spc.Zuora__Subscription__c = zsubList[0].id;
            insert spc;
            
            //NewsPaper
            
            List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(1);
            prpc[0].Name = 'Credit Copy Sat';
            prpc[0].zqu__ProductRatePlan__c = prps[0].id;
            prpc[0].PublicationCode__c = 'BHAO';
            prpc[0].zqu__UOM__c = 'Credit Copy Sat';
            insert prpc;    
            
            zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc2.Name = 'April';
            prpc2.zqu__ProductRatePlan__c = prps[1].id;
            prpc2.PublicationCode__c = 'BHAt';
            prpc2.zqu__UOM__c = 'Credit Copy Mon';
            prpc2.zqu__ZuoraId__c = 'ABCDEFG12435';
            insert prpc2;
            
            List<Publication__c> publi = TestDataFactory.createPublication(1);
            publi[0].Name = 'Beat Harry';    
            publi[0].Publication_Code__c = 'BHAO';
            publi[0].Published_Days__c = 'YYYYYYY';
            publi[0].Publication_Type__c = 'M';
            publi[0].Frequency_Code__c = 'D';
            publi[0].Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publi);
            
            Publication__c publica = TestDataFactory.createPublication(1)[0];
            publica.Name = 'Beat Harry';    
            publica.Publication_Code__c = 'BHAO';
            publica.Published_Days__c = 'YYYYYYY';
            publica.Publication_Type__c = 'N';
            publica.Frequency_Code__c = 'D';
            publica.Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publica);
            
            List<Non_Publication_Day__c> npub = TestDataFactory.createNonPublicationDay(1);
            npub[0].Publication__c = publi[0].id;
            npub[0].Publication_Code__c = 'BHAO';
            npub[0].Non_Publication_Date__c = date.today()+1;
            insert npub;
            
            List<Temp_Stop__c> tStop =  TestDataFactory.createTempStop(1);
            tStop[0].Cancelled__c = false;
            tStop[0].Temp_Stop_Date__c = Date.Today() +1;
            tStop[0].Restart_Date__c = date.Today() +45;
            insert tStop;
            
            Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
            tempStop.Temp_Stop__c = tStop[0].id; 
            tempStop.Subscription__c = zsubList[0].id;
            insert tempStop;
           
            Usage__c u2 = new Usage__c(); 
                        
            ID keyId = zsubList[0].id;  
            
            Set<id> subId = new Set<id>();
            subId.add(zsubList[0].id);
            
            Set<Date> dateSet = new Set<Date>();
            dateSet.add(date.today()+14); 
            
            
            //System.debug('SubId' + subId);
            Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();        
            //mapSubsIdToSubProdCharges.put(keyId , subProdCharge);    
             
            Set<String> ratePlanCharges = new Set<String>();
            ratePlanCharges.add('AB123');
            
            //Set<String> pubCodes = new Set<String>;
            
            Map<Id, zqu__ProductRatePlanCharge__c> mapProdRatePlnCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
            //mapProdRatePlnCharge.put(keyId, prpc2);
            // insert mapSubProdChargeIdToProdRatePlanCharge; 
           
         
                      
            Date endD = date.Today() +45;
            Date startD = Date.Today() +30;
            Date graceEndDate = date.Today() +65;
            String subStatus = 'Active';
            String billingType= 'Recurring Prepaid';
            Id graceSub = null;
            Decimal zuoraQty = 1;
            Boolean isInCopyUom = true;
            Boolean isInCreditCopyUom = true;
            Boolean isInIssueUom = true;
            Boolean isInNoCreditUOM = true;
            Boolean hasMondayIssue = true;
            Boolean hasTuesdayIssue = true;
            Boolean hasWednesdayIssue = true;
            Boolean hasThursdayIssue = true;
            Boolean hasFridayIssue = true;
            Boolean hasSaturdayIssue = true;
            Boolean hasSundayIssue = true;
            
 
            
            Zuora__Subscription__c subList = [SELECT Id, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Zuora__SubscriptionStartDate__c,
                                                Billing_Type__c, Delivered_By_1__c,Zuora__SubscriptionEndDate__c,
                                                (SELECT Zuora__Quantity__c, Zuora__RatePlanName__c, Name, Id, Zuora__ProductSKU__c, Zuora__ChargeNumber__c, Zuora__UOM__c, Zuora__Type__c 
                                                 FROM Zuora__Subscription_Product_Charges__r) x 
                                                FROM Zuora__Subscription__c WHERE id =:zsubList[0].id];
             System.assertnotEquals(null, subList.Zuora__SubscriptionEndDate__c);
            
           /* List<Usage__c> getNonDeliverC = new List<Usage__c>();
            insert getNonDeliverC;*/
     
            /*System.assert(!subId.isEmpty());
            System.Debug('zSub' + zsubList[0].Zuora__SubscriptionEndDate__c);
            System.Debug('endDate' + endD);*/
            
    
     /*Integer monthsBetween = endDate.monthsBetween(zsubList[0].Zuora__SubscriptionEndDate__c);  
     System.assertEquals(3, monthsBetween);*/
             
            Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();
          
           Map<String, Set<Date>> mapPub = new Map<String, Set<Date>> ();
           mapPub.put('BHAO', dateSet);
      
            Test.startTest();
            SP_ProrationUtility controller = new SP_ProrationUtility();
            //List<Usage__c> getNonDeliverC = new SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            List<Usage__c> u = SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            /*
            SP_ProrationUtility.populateSubscriptionToSpC(mapSubsIdToSubProdCharges, zsubList, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populateSpCToRatePlanCharge(mapProdRatePlnCharge, prpc, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populatePubCodeToPublication(mapPubCodeToPublication, publi);
            Set<Date> returnDate =  SP_ProrationUtility.getTempStopDateSet(zsubList[0].id, startD , endD );
            
            Usage__c returnU = SP_ProrationUtility.createUsage (dateSet, spc, u2, startD, endD, graceEndDate, subStatus, billingType, graceSub, zuoraQty, isInCopyUom, isInCreditCopyUom, isInIssueUom, isInNoCreditUOM, hasMondayIssue, hasTuesdayIssue, hasWednesdayIssue, hasThursdayIssue, hasFridayIssue, hasSaturdayIssue, hasSundayIssue );
          
            SP_ProrationUtility.populatePubCodeToNonPubDates(mapPub, npub);
            */
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_EXPIRED', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_POSTPAID', 1, true, true, true, true, true, true, true, true, true, true);
            Test.stopTest();
       }catch(Zuora.zRemoteException e) {}  
         catch(Zuora.zAPIException e) {}  
  }
  
  testmethod static void testRecurringPostpaid()
    {
        //prepareTestData();
       try {
            Test.setMock(WebServiceMock.class, new zLoginMock());        
            
            List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');   
            accList[0].Name = 'Test Account';
            accList[0].AccountNumber = '';
            insert accList;
                   
            
            List<Package__c> packageList = TestDataFactory.createPackage(1);
            insert packageList;
                  
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = accList[0].id; 
            billAccountList[0].Zuora__AccountNumber__c = '001122';
            insert billAccountList; 
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            postal.Street_Name__c = 'Test Street';
            postal.Building_Name__c = 'Test Building';
            postal.House_Block_Number__c = '13';
            insert postal;
            
            //Create Zone
            Zone__c zone = new Zone__c();
            insert zone;
            
            //Create Country   
            Country__c country = TestDataFactory.createCountry(1)[0];
            country.Name = 'SINGAPORE';
            country.Country_Name__c = 'SINGAPORE';
            country.Code__c = 'SIN';
            //country.Zone__c = zone.Id;
            insert country;
            
            Address__c add = TestDataFactory.createAddress(1)[0];
            add.Name = 'Test Address';
            add.Postal_Code__c = postal.id;
            add.Legacy_Created_By__c = 'Creator';
            add.Legacy_Created_Date__c = String.valueOf(date.today() - 3);
            add.Legacy_Updated_By__c = 'Modifier';
            add.Legacy_Updated_Date__c = String.valueOf(date.today()); 
            add.Block_House_Number__c = '22';
            add.Level_Number__c = '12';
            add.Unit_Number__c = '13';
            add.Country__c = country.Id;
            insert add;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = accList[0].id;
            con.Address__c = add.id;
            con.MailingCountry = 'Singapore';
            con.MailingCity = 'Singapore';
            con.MailingStreet = '123 Test Street';
            con.MailingPostalCode = '1000';
            con.Recipient_Indicator__c = true;
            insert con;      
                   
            List<Order__c> orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = accList[0].id;
            orderList[0].Subscriber_Charge__c = 100; 
            orderList[0].Delivery_Charge__c = 20; 
            orderList[0].Recipient_Contact__c = con.id;  
            orderList[0].Billing_Type__C = 'Recurring Postpaid';                     
            insert orderList;
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = packageList[0].id;        
            orderLineItemList[0].Main_Package_Billing_Type__c = 'Recurring Postpaid';
            orderLineItemList[0].Start_Date__c = system.today()+3; //jurna-10-26-15
            insert orderLineItemList;
                     
            List<Zuora__Subscription__c> zsubList = TestDataFactory.createSubscription(1);
            //set values
            zsubList[0].Zuora__Account__c = accList[0].id;
            zsubList[0].Name = 'Ron';
            zsubList[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            zsubList[0].Qty1__c ='20';  
            zsubList[0].Order_Number__c = orderList[0].id;        
            zsubList[0].Order_Line_Item_Number_1__c = orderLineItemList[0].id; 
            zsubList[0].Order_Line_Item_Number__c = orderLineItemList[0].id;    
            zsubList[0].Main_Package_1__c = packageList[0].id;
            zsubList[0].Delivery_Charge__c = 200;
            zsubList[0].Product_Code__c = 'CD001';
            zsubList[0].Subscription_Type_1__c = 'Publication';
            zsubList[0].Subscription_Type__c = 'Publication';  
            zsubList[0].Zuora__SubscriptionStartDate__c = date.Today() +1;
            zsubList[0].Zuora__SubscriptionEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__TermEndDate__c = Date.Today() +90;
            zsubList[0].Zuora__Status__c = 'Cancelled';
            zsubList[0].Subscription_End_Date__c = String.valueOf(date.today()+90);
            zsubList[0].Delivered_By__c = 'Mailing Agent'; 
            zsubList[0].Delivered_By_1__c = 'Mailing Agent';
            zsubList[0].Billing_Type__c =  'Recurring Prepaid'; 
            zsubList[0].Number_of_Copies__c= 100;
            zsubList[0].Number_of_Copies1__c =  '100';
            zsubList[0].Qty__c = 20;
            insert zsubList;      
            //System.debug('Subscription_End_Date__c' + zsubList[0].Zuora__SubscriptionEndDate__c);
            
            Package__c pack = TestDataFactory.createPackage(1)[0];    
            pack.Package_Type__c = 'Base';
            pack.Name = 'ST Print Test';
            pack.Subscription_Type__c = 'Termed';
            pack.Package_Code__c = 'STEST12';
            pack.Subscription_Period__c = '12';
            pack.Effective_Start_Date__c = date.today();
            pack.Effective_End_Date__c = date.today() + 5;
            insert pack;
             
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
            
            List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);    
            subProdCharge[0].Name = 'Credit Copy Sat';
            subProdCharge[0].PublicationCode__c = 'BHAO';
            subProdCharge[0].Zuora__Subscription__c = zsubList[0].id;
            subProdCharge[0].Zuora__UOM__c = 'Credit Copy Weekday';
            subProdCharge[0].Zuora__Quantity__c = 5;
            subProdCharge[0].Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge[0].Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            insert subProdCharge;
            
            Zuora__SubscriptionProductCharge__c spc = new  Zuora__SubscriptionProductCharge__c();
            spc.Zuora__Subscription__c = zsubList[0].id;
            insert spc;
            
            //NewsPaper
            
            List<zqu__ProductRatePlanCharge__c> prpc = TestDataFactory.createProductRatePlanCharge(1);
            prpc[0].Name = 'Credit Copy Sat';
            prpc[0].zqu__ProductRatePlan__c = prps[0].id;
            prpc[0].PublicationCode__c = 'BHAO';
            prpc[0].zqu__UOM__c = 'Credit Copy Sat';
            insert prpc;    
            
            zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc2.Name = 'April';
            prpc2.zqu__ProductRatePlan__c = prps[1].id;
            prpc2.PublicationCode__c = 'BHAt';
            prpc2.zqu__UOM__c = 'Credit Copy Mon';
            prpc2.zqu__ZuoraId__c = 'ABCDEFG12435';
            insert prpc2;
            
            List<Publication__c> publi = TestDataFactory.createPublication(1);
            publi[0].Name = 'Beat Harry';    
            publi[0].Publication_Code__c = 'BHAO';
            publi[0].Published_Days__c = 'YYYYYYY';
            publi[0].Publication_Type__c = 'M';
            publi[0].Frequency_Code__c = 'D';
            publi[0].Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publi);
            
            Publication__c publica = TestDataFactory.createPublication(1)[0];
            publica.Name = 'Beat Harry';    
            publica.Publication_Code__c = 'BHAO';
            publica.Published_Days__c = 'YYYYYYY';
            publica.Publication_Type__c = 'N';
            publica.Frequency_Code__c = 'D';
            publica.Publication_Next_Start_Date__c = date.Today() +14;
            //System.debug('Publication__c' + pub[0].id);
            database.insert(publica);
            
            List<Non_Publication_Day__c> npub = TestDataFactory.createNonPublicationDay(1);
            npub[0].Publication__c = publi[0].id;
            npub[0].Publication_Code__c = 'BHAO';
            npub[0].Non_Publication_Date__c = date.today()+1;
            insert npub;
            
            List<Temp_Stop__c> tStop =  TestDataFactory.createTempStop(1);
            tStop[0].Cancelled__c = false;
            tStop[0].Temp_Stop_Date__c = Date.Today() +1;
            tStop[0].Restart_Date__c = date.Today() +45;
            insert tStop;
            
            Subscription_Temp_Stop__c tempStop = new Subscription_Temp_Stop__c();
            tempStop.Temp_Stop__c = tStop[0].id; 
            tempStop.Subscription__c = zsubList[0].id;
            insert tempStop;
           
            Usage__c u2 = new Usage__c(); 
                        
            ID keyId = zsubList[0].id;  
            
            Set<id> subId = new Set<id>();
            subId.add(zsubList[0].id);
            
            Set<Date> dateSet = new Set<Date>();
            dateSet.add(date.today()+14); 
            
            
            //System.debug('SubId' + subId);
            Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();        
            //mapSubsIdToSubProdCharges.put(keyId , subProdCharge);    
             
            Set<String> ratePlanCharges = new Set<String>();
            ratePlanCharges.add('AB123');
            
            //Set<String> pubCodes = new Set<String>;
            
            Map<Id, zqu__ProductRatePlanCharge__c> mapProdRatePlnCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
            //mapProdRatePlnCharge.put(keyId, prpc2);
            // insert mapSubProdChargeIdToProdRatePlanCharge; 
           
         
                      
            Date endD = date.Today() +45;
            Date startD = Date.Today() +30;
            Date graceEndDate = date.Today() +65;
            String subStatus = 'Active';
            String billingType= 'Recurring Prepaid';
            Id graceSub = null;
            Decimal zuoraQty = 1;
            Boolean isInCopyUom = true;
            Boolean isInCreditCopyUom = true;
            Boolean isInIssueUom = true;
            Boolean isInNoCreditUOM = true;
            Boolean hasMondayIssue = true;
            Boolean hasTuesdayIssue = true;
            Boolean hasWednesdayIssue = true;
            Boolean hasThursdayIssue = true;
            Boolean hasFridayIssue = true;
            Boolean hasSaturdayIssue = true;
            Boolean hasSundayIssue = true;
            
 
            
            Zuora__Subscription__c subList = [SELECT Id, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Zuora__SubscriptionStartDate__c,
                                                Billing_Type__c, Delivered_By_1__c,Zuora__SubscriptionEndDate__c,
                                                (SELECT Zuora__Quantity__c, Zuora__RatePlanName__c, Name, Id, Zuora__ProductSKU__c, Zuora__ChargeNumber__c, Zuora__UOM__c, Zuora__Type__c 
                                                 FROM Zuora__Subscription_Product_Charges__r) x 
                                                FROM Zuora__Subscription__c WHERE id =:zsubList[0].id];
             System.assertnotEquals(null, subList.Zuora__SubscriptionEndDate__c);
            
           /* List<Usage__c> getNonDeliverC = new List<Usage__c>();
            insert getNonDeliverC;*/
     
            /*System.assert(!subId.isEmpty());
            System.Debug('zSub' + zsubList[0].Zuora__SubscriptionEndDate__c);
            System.Debug('endDate' + endD);*/
            
    
     /*Integer monthsBetween = endDate.monthsBetween(zsubList[0].Zuora__SubscriptionEndDate__c);  
     System.assertEquals(3, monthsBetween);*/
             
            Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();
          
           Map<String, Set<Date>> mapPub = new Map<String, Set<Date>> ();
           mapPub.put('BHAO', dateSet);
      
            Test.startTest();
            SP_ProrationUtility controller = new SP_ProrationUtility();
            //List<Usage__c> getNonDeliverC = new SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            List<Usage__c> u = SP_ProrationUtility.getNonDeliverCredit(subId, startD, endD);
            /*
            SP_ProrationUtility.populateSubscriptionToSpC(mapSubsIdToSubProdCharges, zsubList, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populateSpCToRatePlanCharge(mapProdRatePlnCharge, prpc, ratePlanCharges, subProdCharge);
            SP_ProrationUtility.populatePubCodeToPublication(mapPubCodeToPublication, publi);
            Set<Date> returnDate =  SP_ProrationUtility.getTempStopDateSet(zsubList[0].id, startD , endD );
            
            Usage__c returnU = SP_ProrationUtility.createUsage (dateSet, spc, u2, startD, endD, graceEndDate, subStatus, billingType, graceSub, zuoraQty, isInCopyUom, isInCreditCopyUom, isInIssueUom, isInNoCreditUOM, hasMondayIssue, hasTuesdayIssue, hasWednesdayIssue, hasThursdayIssue, hasFridayIssue, hasSaturdayIssue, hasSundayIssue );
          
            SP_ProrationUtility.populatePubCodeToNonPubDates(mapPub, npub);
            */
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_EXPIRED', 'RECURRING_PREPAID', 1, true, true, true, true, true, true, true, true, true, true);
          //SP_ProrationUtility.createUsage(dateSet, subProdCharge, usage, date.today(), date.today(), 'STATUS_ACTIVE', 'RECURRING_POSTPAID', 1, true, true, true, true, true, true, true, true, true, true);
            Test.stopTest();
       }catch(Zuora.zRemoteException e) {}  
         catch(Zuora.zAPIException e) {}  
  }
  
 
}