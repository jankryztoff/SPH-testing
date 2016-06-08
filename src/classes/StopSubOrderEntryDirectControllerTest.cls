/*
* Class Name: <StopSubOrderEntryDirectControllerTest>
* @author: Thayne Recato Dy
* Date: 2/11/2015
* Requirement/Project Name: <SPH>
* @description: This is the test class for StopSubOrderEntryDirectController
*/
@isTest(seeAllData = True)
private class StopSubOrderEntryDirectControllerTest{
    
    /*
    *   @description: This test method executes mostly all methods used in the
    *               base class to test if it's working with a Package Type of 'Add on'.
    *   @Parameters: N/A
    *   @return: N/A
    */ 
    static testMethod void testStopSubOrderEntryDirectController(){
        //try{
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            database.insert(postal);
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'TEST';
            acc.NRIC__c = 'T1234567R';
            database.insert(acc);
            
            Promotion__c promo = new Promotion__c();
            promo.Name = 'promotor';
            promo.Promotion_Code__c = 'yasyd97';
            promo.Effective_Start_Date__c = date.today();
            promo.Effective_End_Date__c = date.today().addDays(1);
            promo.Contract__c = 'Yes';
            promo.Contract_Period__c = '2';
            database.insert(promo);
            
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_ADDON; // Add On
            pack.Billing_Type__c = 'Full Prepaid';        
            pack.Effective_End_Date__c = date.today().addDays(31);
            pack.Effective_Start_Date__c = date.today();
            pack.Subscription_Period__c = '1';
            database.insert(pack);
            
            Package__c myPack = [SELECT Id, Package_Type__c
                                FROM Package__c
                                WHERE Id =: pack.id];
            
            System.assertEquals('Add On', myPack.Package_Type__c);
            
            Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
            promopack.Promotion__c = promo.id;
            promopack.Package_Name__c = pack.id;
            database.insert(promopack);
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.zqu__SKU__c = 'Product SKU';
            database.insert(zProduct);
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            database.insert(billAcc);
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            database.insert(addressRec);
            
            //Contact con = TestDataFactory.createContact(1)[0];
            //con.Address__c = addressRec.Id;
            //con.AccountId = acc.Id;
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            //con.Recipient_Indicator__c = true;
            //database.insert(con);

            //Contact con1 = TestDataFactory.createContact(1)[0];
            //con1.Address__c = addressRec.Id;
            //con1.AccountId = acc.Id;
            //con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            //con1.Billing_Indicator__c = true;
            //database.insert(con1);      

             List<Contact> conLst = TestDataFactory.createContact(2);
            for(Contact con:conLst){
                con.Address__c = addressRec.Id;
                con.AccountId = acc.Id;
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                con.Billing_Indicator__c = true;
            }
            database.insert(conLst);      
            
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            order.Category__c = 'Subscription Request';
            order.Eligible_for_Retention__c = TRUE;
            order.Informed_Customer__c = TRUE;
            order.Sub_Category__c ='Stop Subscription';
            order.Recipient_Contact__c = conLst[0].Id;
            order.Status__c = GlobalVariableClass.STATUS_DRAFT;
            //order.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
            order.Check_Amount__c = 100;
            order.Check_Issuing_Bank__c = 'BLANK';
            order.Check_No__c = 'SPACE';
            order.Check_Dated__c = date.today();
            order.Remarks_Check__c = 'TESTTESTTEST';     
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;     
            order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Billing_Contact__c= conLst[1].Id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Subscriber_charge__c = 100;
            database.insert(order);
            
            Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
            subRecord.Zuora__Account__c = acc.Id;
            //subRecord.Order__c = order.id;
            subRecord.Order_Number__c = order.Id;
            subRecord.Order_Number_1__c = order.id;
            subRecord.Subscriber_Contact__c = conLst[0].Id;
            subRecord.Recipient_Contact__c = conLst[0].Id;
            subRecord.Main_Package_1__c = pack.id;
            subRecord.Zuora__Status__c = 'Active';
            subRecord.Suppress_Vendor_Start_Notice__c = 'false';
            subRecord.Supressed_Acknowledgement_Letter__c = 'false';
            subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecord.Urgent__c = 'false';
            subRecord.Vendor_Conversion__c = 'false';
            subRecord.Charity__c = 'false';
            subRecord.Billing_Type__c = 'Full Prepaid';
            subRecord.Bundled_With__c = 'TEST';
            subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
            subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
            subRecord.Zuora__SubscriptionStartDate__c = date.today();
            subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
            subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
            subRecord.Main_Package__c = pack.id;
            subRecord.Zuora__CustomerAccount__c = billAcc.Id; 
            //START: Tine Test Classes 04/24/2016 
            try{
                database.insert(subRecord);
            }catch(Exception e){
                System.debug('Error ' + e);
            }
            
            Product_Family__c prodFamily = new Product_Family__c();
            prodFamily.Product_Family__c = 'CODEFAMILY2424';
            prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
            database.insert(prodFamily);
            
            List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
            for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
                spc.Name = 'Sub Product Charge Test';
                spc.Zuora__Subscription__c = subRecord.id;
                spc.Zuora__RatePlanName__c = 'Sample Rate'; 
                spc.Zuora__ProductSKU__c = 'Product SKU'; 
            }
            database.insert(subProductCharge);
            
            List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(1);
            for(zqu__ProductRatePlan__c prp:productRatePlan) {
                prp.Name = subProductCharge[0].Zuora__RatePlanName__c;
                prp.zqu__ZProduct__c = zProduct.id;
                prp.RatePlanCode__c = 'Super Plan';
                prp.SubscriptionFrequency__c = '0';
                prp.zqu__ZuoraId__c = subRecord.id;
                prp.RatePlanType__c = 'Bill Plan';  
                prp.RatePlanSubType__c = 'Standard';
            }
            database.insert(productRatePlan);
            
            List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1);
            for(zqu__ProductRatePlanCharge__c prpc:productRatePlanCharge) {
                prpc.Name = subProductCharge[0].Zuora__RatePlanName__c;
                prpc.zqu__ProductRatePlan__c = productRatePlan[0].id;
                prpc.PublicationCode__c = 'PUB1';
                prpc.zqu__ZuoraId__c = subRecord.id;
            }
            database.insert(productRatePlanCharge);
            
            List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
            for (Package_Item__c pItem : pItems) {
                pItem.Package__c = pack.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                pItem.Product_Rate_Plan__c = productRatePlan[0].id;
                pItem.Product_Family__c = prodFamily.id;
            }
            database.insert(pItems);
            
            order.Base_Subscription__c= subRecord.id;
            database.update(order);
            
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Earliest_Start_Date__c = date.today();
            oli.Start_Date__c =  date.today().addDays(5);
            oli.Fee_Waiver__c = TRUE;
            oli.Order__c = order.id;
            oli.Main_Package_ID__c = pack.id;
            oli.Main_Package_Period__c = 1;
            oli.Qty__c = 1;
            oli.Term_Length__c = 1;
            oli.Main_Package_Billing_Type__c = 'Full Prepaid';
            oli.Main_Package_Type__c = 'Base';
            oli.Main_Package_Frequency__c = 'Default';
            oli.Delivered_By__c = 'None';
            database.insert(oli);
            try{
            test.startTest();
            //Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            //cas.Order__c = order.Id;
            
            //  database.insert(cas);
            
            Promotion_Gift__c promgift = TestDataFactory.createPromotionGift(1)[0];
            promgift.Gift_Inventory__c = 1;
            promgift.Gift_Issued__c = 1;
            promgift.Gift_Redeemed__c = 1;
            database.insert(promgift);
            
            
            subRecord.Order_Line_Item_Number__c = oli.id;
            
            database.update(subRecord);
            
            
            List <Publication__c> pubList = new List <Publication__c>();
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Test';
            pub.Publication_Code__c = 'PUB1';
            pub.Published_Days__c = 'YYYYNNY';
            pub.Publication_Type__c = 'M';
            pub.Publish_Pattern__c = 'Weekdays';
            pubList.add(pub);
            
            Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
            npub.Publication_Code__c = 'PUB1';
            npub.Published_Days__c = 'YYYYNNY';
            npub.Publication_Type__c = 'M';
            npub.Publish_Pattern__c = 'Weekdays';
            pubList.add(npub);
            database.insert(pubList);          
            
            List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'PUB1';
            nonpub.Publication__c = npub.Id;
            nonPubList.add(nonpub);
            database.insert(nonPubList);       
            
            Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
            //SAF.Flag_Code__c = 'TEST';
            SAF.Flag_Description__c = 'TESTx';
            database.insert(SAF);
            
            Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
            PAF.Package__c = pack.Id;
            PAF.No_of_Concurrent_Users__c = 2;
            PAF.Package_Service_Access_Flag__c = SAF.Id;
            database.insert(PAF);
            
            //create Asia1__c
            Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
            tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
            tmpAsia1.Display_Name__c = 'Test';
            tmpAsia1.Email__c = 'test@email.com' ;
            tmpAsia1.Password__c = 'aBcD3Fg';
            tmpAsia1.Contact__c = conLst[0].Id;
            database.insert(tmpAsia1);
            
            List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
            
            asiaSubList[0].Asia1__c = tmpAsia1.Id;
            asiaSubList[0].Subscription__c = subRecord.Id;
            asiaSubList[0].Status__c = 'Enabled';
            asiaSubList[0].Order_Line_Item__c = oli.Id;
            asiaSubList[0].Service_Access_Flag__c = SAF.Id;
            database.insert(asiaSublist)   ;
            
            //create publications
            List<Publication__c> publicationList = TestDataFactory.createPublication(2);
            publicationList[0].Product_Family__c = 'Stray';
            publicationList[0].Published_Days__c = 'NNNNNNN';
            publicationList[0].Publication_Type__c = 'A';
            publicationList[1].Product_Family__c = 'Time';
            publicationList[1].Published_Days__c = 'NNNNNNN';
            publicationList[1].Publication_Type__c = 'A';
            database.insert(publicationList);
            
            
            //create oliv
            List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
            for(Order_Line_Item_Vendor__c oliv:orderLineItemList){
                oliv.Order__c = order.id;
                oliv.Start_Date__c = date.today()+2;
            }        
            database.insert(orderLineItemList);
            
            
            
            PageReference pRef = Page.StopSub_Order_Entry_Direct_Edit;
            Test.setCurrentPage(pRef);
            //ApexPages.currentPage().getParameters().put('def_parent_id', cas.Id);
            ApexPages.currentPage().getParameters().put('accountId', acc.Id);
            ApexPages.currentPage().getParameters().put('orderId', order.Id);
            ApexPages.currentPage().getParameters().put('recordtype',constantsSLB.getKeyId('Account_Direct Corporate'));
            ApexPages.currentPage().getParameters().put('subRecordId', subRecord.Id); 
        //try{
            //Test.startTest();

            
            StopSubOrderEntryDirectController StopSubOrderEntryDirect = new StopSubOrderEntryDirectController();
            StopSubOrderEntryDirect.myId = subRecord.id;
            StopSubOrderEntryDirect.getOrder();
            StopSubOrderEntryDirect.setOrder();     
            StopSubOrderEntryDirect.setSubscriptionRecords();        
            
            StopSubOrderEntryDirect.isSRDValid(StopSubOrderEntryDirect.getSelectedSubscription());
            StopSubOrderEntryDirect.isSRDValid(StopSubOrderEntryDirect.getSelectedSubscription(), StopSubOrderEntryDirect.getPublication(StopSubOrderEntryDirect.getSelectedSubscription()));
            StopSubOrderEntryDirect.getGivenCopies(StopSubOrderEntryDirect.getSelectedSubscription());
            StopSubOrderEntryDirect.getAdminFee(StopSubOrderEntryDirect.getSelectedSubscription());
            StopSubOrderEntryDirect.getRefund(StopSubOrderEntryDirect.getSelectedSubscription());

            //Will not enter the If condition because of the Case created that is MAGAZINE
            StopSubOrderEntryDirect.getMissedCopies(StopSubOrderEntryDirect.getSelectedSubscription());
            StopSubOrderEntryDirect.removeSubscriptionRecord();
            
            StopSubOrderEntryDirect.doSave();
            StopSubOrderEntryDirect.saveAsDraft();  
            StopSubOrderEntryDirect.doCancel();    
            
            List<Order_Line_Item__c> myOliList = new List<Order_Line_Item__c>();
            myOliList.add(oli);
            
            StopSubOrderEntryDirect.checkFieldsInOrder(myOliList);
                    
            Test.stopTest();
        }catch(Exception e){
            
        }
        
        
    }//END testMethod testStopSubOrderEntryDirectController()
    
    /*
    *   @description: This test method executes the some methods in the base class to
    *               check if certain conditions are met with a Package Type of 'Bundle'.
    *   @Parameters: N/A
    *   @return: N/A
    */ 
    static testmethod void testForGetSubscriptionFirstIf() {
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);
        
        Promotion__c promo = new Promotion__c();
        promo.Name = 'promotor';
        promo.Promotion_Code__c = 'yasyd97';
        promo.Effective_Start_Date__c = date.today();
        promo.Effective_End_Date__c = date.today().addDays(1);
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        database.insert(promo);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = GlobalVariableClass.PACKAGETYPE_BUNDLE; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Package__c myPack = [SELECT Id, Package_Type__c
                            FROM Package__c
                            WHERE Id =: pack.id];
        
        System.assertEquals('Bundle', myPack.Package_Type__c);
        
        Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
        promopack.Promotion__c = promo.id;
        promopack.Package_Name__c = pack.id;
        database.insert(promopack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        database.insert(zProduct);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        database.insert(billAcc);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        //Contact con = TestDataFactory.createContact(1)[0];
        //con.Address__c = addressRec.Id;
        //con.AccountId = acc.Id;
        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        //con.Recipient_Indicator__c = true;
        //database.insert(con);

        //Contact con1 = TestDataFactory.createContact(1)[0];
        //con1.Address__c = addressRec.Id;
        //con1.AccountId = acc.Id;
        //con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        //con1.Billing_Indicator__c = true;
        //database.insert(con1);     
        
          
        List<Contact> conLst = TestDataFactory.createContact(2);
        for(Contact con:conLst){
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
        }
        database.insert(conLst);


        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = conLst[0].Id;
        //order.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= conLst[0].id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Subscriber_charge__c = 100;
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Recipient_Contact__c = conLst[1].id;
        //subRecord.Order__c = order.id;
        subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = conLst[1].id;
        //subRecord.Recipient_Contact__c = con.Id;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package__c = pack.id;
        subRecord.Zuora__CustomerAccount__c = billAcc.Id; 
        //START: Tine Test Classes 04/24/2016
        //try{
            database.insert(subRecord);
        //}catch(Exception e){
            //System.debug(e);
        //}
        
        Product_Family__c prodFamily = new Product_Family__c();
        prodFamily.Product_Family__c = 'CODEFAMILY2424';
        prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
        database.insert(prodFamily);
                
        List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
            spc.Name = 'Sub Product Charge Test';
            spc.Zuora__Subscription__c = subRecord.id;
            spc.Zuora__RatePlanName__c = 'Sample Rate'; 
            spc.Zuora__ProductSKU__c = 'Product SKU'; 
        }
        database.insert(subProductCharge);
        
        List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c prp:productRatePlan) {
            prp.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prp.zqu__ZProduct__c = zProduct.id;
            prp.RatePlanCode__c = 'Super Plan';
            prp.SubscriptionFrequency__c = '1';
            prp.zqu__ZuoraId__c = subRecord.id;
            prp.RatePlanType__c = 'Bill Plan';  
            prp.RatePlanSubType__c = 'Standard';
            prp.zqu__ZuoraId__c = 'ZI' + '1';
        }
        database.insert(productRatePLan);
        
        List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1);
        for(zqu__ProductRatePlanCharge__c prpc:productRatePlanCharge) {
            prpc.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prpc.zqu__ProductRatePlan__c = productRatePlan[0].id;
            prpc.PublicationCode__c = 'PUB1';
            prpc.zqu__ZuoraId__c = subRecord.id;
            prpc.zqu__ZuoraId__c = 'ZID' + '2';
        }
        database.insert(productRatePlanCharge);
        
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Bundle Product');
        for (Package_Item__c pItem : pItems) {
            pItem.Package__c = pack.Id;
            pItem.Duration_in_months__c = '3';
            pItem.Effective_Start_Month__c = '3';
            pItem.Product_Rate_Plan__c = productRatePlan[0].id;
            pItem.Product_Family__c = prodFamily.id;
        }
        database.insert(pItems);
        
        order.Base_Subscription__c= subRecord.id;
        database.update(order);
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c =  date.today().addDays(5);
        oli.Stop_Request_Date__c = date.today().addDays(6);
        oli.Terminating_Reason__c = 'Package - Upgrade';
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        database.insert(oli);
                
        Promotion_Gift__c promgift = TestDataFactory.createPromotionGift(1)[0];
        promgift.Gift_Inventory__c = 1;
        promgift.Gift_Issued__c = 1;
        promgift.Gift_Redeemed__c = 1;
        database.insert(promgift);
        try{
        Test.startTest();
        //Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        //cas.Order__c = order.Id;
        //database.insert(cas);
        
        subRecord.Order_Line_Item_Number__c = oli.id;
        
        database.update(subRecord);             
        
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'M';
        pub.Publish_Pattern__c = 'Weekdays';
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'M';
        npub.Publish_Pattern__c = 'Weekdays';
        pubList.add(npub);
        database.insert(pubList);        
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);   
        
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        database.insert(SAF);
        
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        database.insert(PAF);
        
        //create Asia1__c
        Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
        tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        tmpAsia1.Display_Name__c = 'Test';
        tmpAsia1.Email__c = 'test@email.com' ;
        tmpAsia1.Password__c = 'aBcD3Fg';
        tmpAsia1.Contact__c = conLst[0].id;
        database.insert(tmpAsia1);
        
        List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
        
        asiaSubList[0].Asia1__c = tmpAsia1.Id;
        asiaSubList[0].Subscription__c = subRecord.Id;
        asiaSubList[0].Status__c = 'Enabled';
        asiaSubList[0].Order_Line_Item__c = oli.Id;
        asiaSubList[0].Service_Access_Flag__c = SAF.Id;
        database.insert(asiaSubList);  
        
        //create publications
        List<Publication__c> publicationList = TestDataFactory.createPublication(2);
        publicationList[0].Product_Family__c = 'Stray';
        publicationList[0].Published_Days__c = 'YYYYYYY';
        publicationList[0].Publication_Type__c = 'A';
        publicationList[1].Product_Family__c = 'Time';
        publicationList[1].Published_Days__c = 'YYYYYYY';
        publicationList[1].Publication_Type__c = 'A';
        database.insert(publicationList);
        
        
        //create oliv
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        for(Order_Line_Item_Vendor__c oliv:orderLineItemList){
            oliv.Order__c = order.id;
            oliv.Start_Date__c = date.today()+2;
        }
        
        database.insert(orderLineItemList);
        
        //Test.startTest();

        PageReference pRef = Page.StopSub_Order_Entry_Direct_Edit;
        Test.setCurrentPage(pRef);
        //ApexPages.currentPage().getParameters().put('def_parent_id', cas.Id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('orderId', order.Id);
        ApexPages.currentPage().getParameters().put('recordtype',constantsSLB.getKeyId('Account_Direct Corporate'));
        ApexPages.currentPage().getParameters().put('subRecordId', subRecord.Id);        
        //ApexPages.currentPage().getParameters().put('Id', oli.Id);
        //ApexPages.currentPage().getParameters().put('Id', pub.id);
        
        StopSubOrderEntryDirectController StopSubOrderEntryDirect = new StopSubOrderEntryDirectController();
        StopSubOrderEntryDirect.myId = subRecord.id;
        StopSubOrderEntryDirect.getOrder();
        StopSubOrderEntryDirect.setOrder();    
        StopSubOrderEntryDirect.setSubscriptionRecords(); 
        StopSubOrderEntryDirect.removeSubscriptionRecord();     
        
        //Will enter the If condition because the Case created is Newspaper.
        StopSubOrderEntryDirect.getMissedCopies(StopSubOrderEntryDirect.getSelectedSubscription());
              
        
        Test.stopTest();
        }catch(Exception e){}
    }//ENDtestForGetSubscriptionFirstIf()
    
    /*
    *   @description: This test method executes some methods for publication purposes in the 
    *               base class with a Package Type of 'Grace period'.
    *   @Parameters: N/A
    *   @return: N/A
    */ 
    static testMethod void testForGetSubscriptionNotInCondition(){
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = '1234';
        database.insert(postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);
        
        Promotion__c promo = new Promotion__c();
        promo.Name = 'promotor';
        promo.Promotion_Code__c = 'yasyd97';
        promo.Effective_Start_Date__c = date.today();
        promo.Effective_End_Date__c = date.today().addDays(1);
        promo.Contract__c = 'Yes';
        promo.Contract_Period__c = '2';
        database.insert(promo);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Package_Type__c = 'Grace Period'; // Add On
        pack.Billing_Type__c = 'Full Prepaid';        
        pack.Effective_End_Date__c = date.today().addDays(31);
        pack.Effective_Start_Date__c = date.today();
        pack.Subscription_Period__c = '1';
        database.insert(pack);
        
        Package__c myPack = [SELECT Id, Package_Type__c
                            FROM Package__c
                            WHERE Id =: pack.id];
        
        System.assertEquals('Grace Period', myPack.Package_Type__c);
        
        Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
        promopack.Promotion__c = promo.id;
        promopack.Package_Name__c = pack.id;
        database.insert(promopack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        database.insert(zProduct);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        database.insert(billAcc);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        //Contact con = TestDataFactory.createContact(1)[0];
        //con.Address__c = addressRec.Id;
        //con.AccountId = acc.Id;
        //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        //con.Recipient_Indicator__c = true;
        //database.insert(con);
        //Contact con1 = TestDataFactory.createContact(1)[0];
        //con1.Address__c = addressRec.Id;
        //con1.AccountId = acc.Id;
        //con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        //con1.Billing_Indicator__c = true;
        //database.insert(con1);             
        
        List<Contact> conLst = TestDataFactory.createContact(2);
        for(Contact con:conLst){
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
        }
        database.insert(conLst);

        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = conLst[0].Id;
        //order.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';     
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;     
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= conLst[1].Id;
        order.Billing_Type__c = 'Full Prepaid';
        order.Subscriber_charge__c = 100;
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        //subRecord.Order__c = order.id;
        subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = conLst[0].Id;
        subRecord.Recipient_Contact__c = conLst[0].Id;
        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord.Main_Package__c = pack.id;
        subRecord.Zuora__CustomerAccount__c = billAcc.Id; 
        database.insert(subRecord);
        
        Product_Family__c prodFamily = new Product_Family__c();
        prodFamily.Product_Family__c = 'CODEFAMILY2424';
        prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
        database.insert(prodFamily);
                
        List<Zuora__SubscriptionProductCharge__c> subProductCharge = TestDataFactory.createSubProductCharge(2);
        for(Zuora__SubscriptionProductCharge__c spc:subProductCharge){
            spc.Name = 'Sub Product Charge Test';
            spc.Zuora__Subscription__c = subRecord.id;
            spc.Zuora__RatePlanName__c = 'Sample Rate'; 
            spc.Zuora__ProductSKU__c = 'Product SKU'; 
        }
        database.insert(subProductCharge);
        
        List<zqu__ProductRatePlan__c> productRatePlan = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c prp:productRatePlan) {
            prp.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prp.zqu__ZProduct__c = zProduct.id;
            prp.RatePlanCode__c = 'Super Plan';
            prp.SubscriptionFrequency__c = '2';
            prp.zqu__ZuoraId__c = subRecord.id;
            prp.RatePlanType__c = 'Proration';  
            prp.RatePlanSubType__c = 'Standard';
        }
        database.insert(productRatePlan);
        
        List<zqu__ProductRatePlanCharge__c> productRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1);
        for(zqu__ProductRatePlanCharge__c prpc:productRatePlanCharge) {
            prpc.Name = subProductCharge[0].Zuora__RatePlanName__c;
            prpc.zqu__ProductRatePlan__c = productRatePlan[0].id;
            prpc.PublicationCode__c = 'PUB1';
            prpc.zqu__ZuoraId__c = subRecord.id;
        }
        database.insert(productRatePlanCharge);
        
        List<Package_Item__c> pItems = TestDataFactory.createPackageItem(1, 'Base Product');
        for (Package_Item__c pItem : pItems) {
            pItem.Package__c = pack.Id;
            pItem.Duration_in_months__c = '3';
            pItem.Effective_Start_Month__c = '3';
            pItem.Product_Rate_Plan__c = productRatePlan[0].id;
            pItem.Product_Family__c = prodFamily.id;
        }
        database.insert(pItems);
        
        order.Base_Subscription__c= subRecord.id;
        database.update(order);
        
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
        oli.Earliest_Start_Date__c = date.today();
        oli.Start_Date__c =  date.today().addDays(5);
        oli.Order__c = order.id;
        oli.Main_Package_ID__c = pack.id;
        oli.Main_Package_Period__c = 1;
        oli.Qty__c = 1;
        oli.Term_Length__c = 1;
        oli.Main_Package_Billing_Type__c = 'Full Prepaid';
        oli.Main_Package_Type__c = 'Base';
        oli.Main_Package_Frequency__c = 'Default';
        oli.Delivered_By__c = 'None';
        database.insert(oli);
        
        Promotion_Gift__c promgift = TestDataFactory.createPromotionGift(1)[0];
        promgift.Gift_Inventory__c = 1;
        promgift.Gift_Issued__c = 1;
        promgift.Gift_Redeemed__c = 1;
        database.insert(promgift);
        
        try{
        Test.StartTest();
        //Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        //cas.Order__c = order.Id;
        //database.insert(cas);
        
        subRecord.Order_Line_Item_Number__c = oli.id;
        
        database.update(subRecord);
        
        
        List <Publication__c> pubList = new List <Publication__c>();
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Name = 'Test';
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYNNY';
        pub.Publication_Type__c = 'M';
        pub.Publish_Pattern__c = 'Weekdays';
        pubList.add(pub);
        
        Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
        npub.Publication_Code__c = 'PUB1';
        npub.Published_Days__c = 'YYYYNNY';
        npub.Publication_Type__c = 'M';
        npub.Publish_Pattern__c = 'Weekdays';
        pubList.add(npub);
        database.insert(pubList);        
        
        List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
        Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
        nonpub.Non_Publication_Date__c = date.today();
        nonpub.Publication_Code__c = 'PUB1';
        nonpub.Publication__c = npub.Id;
        nonPubList.add(nonpub);
        database.insert(nonPubList);      
        
        Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
        //SAF.Flag_Code__c = 'TEST';
        SAF.Flag_Description__c = 'TESTx';
        database.insert(SAF);
        
        Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
        PAF.Package__c = pack.Id;
        PAF.No_of_Concurrent_Users__c = 2;
        PAF.Package_Service_Access_Flag__c = SAF.Id;
        database.insert(PAF);
        
        //create Asia1__c
        Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
        tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
        tmpAsia1.Display_Name__c = 'Test';
        tmpAsia1.Email__c = 'test@email.com' ;
        tmpAsia1.Password__c = 'aBcD3Fg';
        tmpAsia1.Contact__c = conLst[0].Id;
        database.insert(tmpAsia1);
        
        List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
        
        asiaSubList[0].Asia1__c = tmpAsia1.Id;
        asiaSubList[0].Subscription__c = subRecord.Id;
        asiaSubList[0].Status__c = 'Enabled';
        asiaSubList[0].Order_Line_Item__c = oli.Id;
        asiaSubList[0].Service_Access_Flag__c = SAF.Id;
        database.insert(asiaSubList);   
        
        //create publications
        List<Publication__c> publicationList = TestDataFactory.createPublication(2);
        publicationList[0].Product_Family__c = 'Stray';
        publicationList[0].Published_Days__c = 'NNNNNNN';
        publicationList[0].Publication_Type__c = 'A';
        publicationList[1].Product_Family__c = 'Time';
        publicationList[1].Published_Days__c = 'NNNNNNN';
        publicationList[1].Publication_Type__c = 'A';
        database.insert(publicationList);
        
        
        //create oliv
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        for(Order_Line_Item_Vendor__c oliv:orderLineItemList){
            oliv.Order__c = order.id;
            oliv.Start_Date__c = date.today()+2;
        }
        database.insert(orderLineItemList);
        
        //Test.startTest();
        
        PageReference pRef = Page.StopSub_Order_Entry_Direct_Edit;
        Test.setCurrentPage(pRef);
        //ApexPages.currentPage().getParameters().put('def_parent_id', cas.Id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('orderId', order.Id);
        ApexPages.currentPage().getParameters().put('recordtype',constantsSLB.getKeyId('Account_Direct Corporate'));
        ApexPages.currentPage().getParameters().put('subRecordId', subRecord.Id);   
        
        StopSubOrderEntryDirectController StopSubOrderEntryDirect = new StopSubOrderEntryDirectController();
        StopSubOrderEntryDirect.myId = subRecord.id;
        StopSubOrderEntryDirect.getOrder();
        StopSubOrderEntryDirect.setOrder();     
        StopSubOrderEntryDirect.setSubscriptionRecords();     
        
        StopSubOrderEntryDirect.doSave();
        StopSubOrderEntryDirect.saveAsDraft();  
        StopSubOrderEntryDirect.doCancel();
        
        Test.stopTest();
        }catch(Exception e){}
        
        
    }//END testMethod testForGetSubscriptionNotInCondition() */  
    
    /*
    *   @description: This test method executes the SetOrder() method 
    *           in the base class.
    *   @Parameters: N/A
    *   @return: N/A
    */   
    static testMethod void testSetOrder() {
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);
        
        Test.startTest();
        
        PageReference pRef = Page.StopSub_Order_Entry_Direct_Edit;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('recordtype',constantsSLB.getKeyId('Account_Direct Corporate'));
        String recordType = ApexPages.currentPage().getParameters().get('recordtype');
        
        System.assertNotEquals('Direct Individual', recordType);
        
        
        StopSubOrderEntryDirectController StopSubOrderEntryDirect = new StopSubOrderEntryDirectController(); 
        StopSubOrderEntryDirect.setOrder();
        
        Test.stopTest();
    }//END testMethod testSetOrder()
        
    /*
    *   @description: This test method executes the SetOrder() method 
    *           in the base class with wrong RecordType.
    *   @Parameters: N/A
    *   @return: N/A
    *   
    */
    static testMethod void testWrongSetOrder() {
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);
        
        Test.startTest();
        
        PageReference pRef = Page.StopSub_Order_Entry_Direct_Edit;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('recordtype', GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION);        
        String recordTypeId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_RECORDTYPE);
        
        System.assertNotEquals(recordTypeId, GlobalVariableClass.PARAMETER_RECORDTYPE);
        
        try {
            StopSubOrderEntryDirectController StopSubOrderEntryDirect = new StopSubOrderEntryDirectController(); 
            StopSubOrderEntryDirect.setOrder();
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        
        Test.stopTest();
    }//END testMethod testWrongSetOrder()
        
    /*
    *   @description: This test method executes a NULL 
    *           accountId to go to the other condition in the 
    *           base class(GetAccount()).
    *   @Parameters: N/A
    *   @return: N/A
    *   
    */
    static testMethod void testGetWrongAccount() {        
        Test.startTest();
        
        PageReference pRef = Page.StopSub_Order_Entry_Direct_Edit;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('accountId', 'WrongID123456');        
        String accountId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_ACCOUNTID);
        
        System.assertEquals('WrongID123456', accountId);
        
        try {
            StopSubOrderEntryDirectController StopSubOrderEntryDirect = new StopSubOrderEntryDirectController();            
        }catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        
        Test.stopTest();
    }//END testMethod testGetWrongAccount()*/   
        
    /*
    *   @description: This test method executes a NULL 
    *           orderId to go to the other condition in the 
    *           base class(GetOrder()).
    *   @Parameters: N/A
    *   @return: N/A
    *   
    */
    static testMethod void testGetNullOrder() {
        Test.startTest();
        
        PageReference pRef = Page.StopSub_Order_Entry_Direct_Edit;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('orderId', NULL);        
        String orderId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_ORDERID);
        
        System.assertEquals(NULL, orderId);
        
        try {
            StopSubOrderEntryDirectController StopSubOrderEntryDirect = new StopSubOrderEntryDirectController();        
            StopSubOrderEntryDirect.getOrder();
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        Test.stopTest();        
    }//END testMethod testGetNullOrder()
    
    
}//END StopSubOrderEntryDirectControlleTest