/*
* Class Name: <StopSubOrderEntryDirectControllerTest>
* @author: Thayne Recato Dy
* Date: 2/11/2015
* Requirement/Project Name: <SPH>
* @description: This is the test class for StopSubOrderEntryDirectController
*/
@isTest
private class StopSubOrderEntryDirectControllerTest{
    
    /*
    *   @description: This test method executes mostly all methods used in the
    *               base class to test if it's working with a Package Type of 'Add on'.
    *   @Parameters: N/A
    *   @return: N/A
    */ 
    
     @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
    }  
    
    static testMethod void testStopSubOrderEntryDirectController(){
        //try{
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '1234';
            database.insert(postal);
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            acc.Name = 'TEST';
            acc.NRIC__c = 'T1234567R';
            database.insert(acc);
            
            Billing_Batch__c testBillingBatch = new Billing_Batch__c(Name= 'Full Prepaid', Batch__c = '13,14,15', Next_Batch_Number__c = 13);
            insert testBillingBatch;
            
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
            try{
                //database.insert(oli);
            }catch(exception e) {
                system.debug(':::ERROR ' + e);
            }
          
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
        try{
            //database.insert(oli);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
                
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
        
        Billing_Batch__c testBillingBatch = new Billing_Batch__c(Name= 'Full Prepaid', Batch__c = '13,14,15', Next_Batch_Number__c = 13);
            insert testBillingBatch;
        
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
        try{
            database.insert(oli);
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
        
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
    
    
    static testMethod void testmethod_1() {
        id rtAdd =  Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Local').getRecordTypeId(); 
        id rtacct =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct SPH Inter-Division').getRecordTypeId(); 
        Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.RecordTypeId = rtacct;
        insert acc;
        
        Account acc2 = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc2.Name = 'second test';
        acc2.AccountNumber = '1235589';
        insert acc2;
        
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        insert postal;
        
        Billing_Batch__c testBillingBatch = new Billing_Batch__c(Name= 'Full Prepaid', Batch__c = '13,14,15', Next_Batch_Number__c = 13);
            insert testBillingBatch;
        
        //Add On Package
        list<zqu__ZProduct__c> listZproducts = new list<zqu__ZProduct__c>();
        
        zqu__ZProduct__c zProductAddOn = TestDataFactory.createZProduct(1)[0];
        zProductAddOn.ProductPlatform__c = 'Online';
        zProductAddOn.ProductSubType__c = 'Newspaper';
        zProductAddOn.ProductFamily__c = 'Test ZB';
        zProductAddOn.ProductType__c = 'Product';
        zProductAddOn.zqu__ZuoraId__c = 'dfhsfvkefigegv';
        listZproducts.add(zProductAddOn);
        
        //Main Package
        zqu__ZProduct__c zProductMain = TestDataFactory.createZProduct(1)[0];
        zProductMain.ProductPlatform__c = 'Smartphone';
        zProductMain.ProductSubType__c = 'Newspaper';
        zProductMain.ProductFamily__c = 'Test ZB';
        zProductMain.ProductType__c = 'Product';
        
        listZproducts.add(zProductMain);
        
        insert listZproducts;
        
        Zone__c testZone = new Zone__c();
        testZone.Name = '648';
        testZone.Zone_Name_External_Id__c = 'tst135';
        insert testZone;
        
        list<Zone_Product__c> zoneProductLst = new List<Zone_Product__c>();
        Zone_Product__c zoneProd = new Zone_Product__c();
        zoneProd.Effective_Start_Date__c = date.today();
        zoneProd.Zone__c = testZone.id;
        zoneProd.Postage_Charge__c = 648;
        zoneProd.Product__c = listZproducts[1].Id;
        zoneProductLst.add(zoneProd);
        
        Zone_Product__c zoneProd2 = new Zone_Product__c();
        zoneProd2.Effective_Start_Date__c = date.today();
        zoneProd2.Zone__c = testZone.id;
        zoneProd2.Postage_Charge__c = 648;
        zoneProd2.Product__c = listZproducts[0].Id;
        zoneProductLst.add(zoneProd2);
        insert zoneProductLst;
        
        Country__c testCountry = new Country__c();
        testCountry.Name = 'USA';
        testCountry.Account__c = acc.id;
        testCountry.Code__c = '6A12';
        testCountry.Country_Name__c = 'Canada';
        testCountry.Zone__c = testZone.id;
        testCountry.Zonal_Code__c = '648';
        insert testCountry;
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.RecordTypeId = rtAdd;
        addressRec.Country__c = testCountry.id;
        insert addressRec;
        
       // Key_Id__c keyId  = Key_Id__c.getInstance('NEXT_RECIPIENT_NUMBER');//(Name=,Id__c='30465208', Type__c='Number');
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        con.Billing_Indicator__c = true;
        insert con;
        
        List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
        billAccountList[0].Zuora__Account__c = acc.id;
        billAccountList[0].Name = 'TEST';     
        billAccountList[0].Zuora__Credit_Balance__c = 0;
        billAccountList[0].Payment_Mode__c = 'Cash';
        billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
        billAccountList[0].Zuora__DefaultPaymentMethod__c = 'ACH';
        billAccountList[0].Other_PaymentMethod__c = 'Invoice';
        billAccountList[0].ARMS_Customer_Number__c = 'jx8l22';
        billAccountList[0].ARMS_Account_Number__c  = 'tst';
        insert billAccountList;
        
        

        zqu__ProductRatePlan__c prdRatePlanMain = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlanMain.zqu__ZProduct__c = listZproducts[1].Id;
        prdRatePlanMain.SubscriptionFrequency__c = '0';
        prdRatePlanMain.RatePlanType__c = 'Bill Plan';
        prdRatePlanMain.BillingType__c  = 'Recurring Prepaid';
        prdRatePlanMain.BillingPeriod__c = '12';
        insert prdRatePlanMain;
        
        zqu__ProductRatePlanCharge__c prpcMain = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpcMain.zqu__ProductRatePlan__c = prdRatePlanMain.Id;
        insert prpcMain;
        
        List<Product_Family__c> prodfam = TestDataFactory.createProductFamily(1);
        prodfam[0].Product_Family_Name__c = 'Test ZB';
        insert prodfam;
        
        Package__c packMain = TestDataFactory.createPackage(1)[0];
        packMain.Name = 'TestNameMain';
        packMain.Package_Code__c = 'MAINPCK';
        packMain.Package_Price__c = 2;
        packMain.Subscription_Type__c = 'Evergreen';
        packMain.Product_Family_Current_Package__c = 'Test ZB';
        packMain.Subscription_Period__c = '1';
        packMain.Billing_Type__c = 'Recurring Prepaid';
        packMain.Package_Type__c = 'Base';
        packMain.Subscription_Period_1__c = '12';
        packMain.Subscription_Period__c = '12';
        
        insert packMain;
        
        Package_Item__c pItemMain = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain.Package__c = packMain.Id;
        pItemMain.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain.Product_Family__c = prodfam[0].id;
        insert pItemMain;
        
        Service_Access_Flag__c safRecMain =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRecMain.Name = 'TestFlag_sphone';
        safRecMain.Flag_Description__c = 'test description sphone';
        insert safRecMain;
        
        Package_Access_Flag__c pckAFMain = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAFMain.Package__c = packMain.Id;
        pckAFMain.No_of_Concurrent_Users__c = 2;
        pckAFMain.Package_Service_Access_Flag__c = safRecMain.Id;
        insert pckAFMain;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = listZproducts[0].Id;
        prdRatePlan.SubscriptionFrequency__c = '0';
        prdRatePlan.RatePlanType__c = 'Discount';
        prdRatePlan.BillingType__c  = 'Recurring Prepaid';
        prdRatePlan.BillingPeriod__c = '12';
        prdRatePlan.zqu__ZuoraId__c = 'zidrateadnadha';
        insert prdRatePlan;
        
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
        prpc.zqu__ZuoraId__c  = 'zidchargehrhr';
        insert prpc;
        
        Package__c packAddOn = TestDataFactory.createPackage(1)[0];
        packAddOn.Name = 'TestName';
        packAddOn.Package_Code__c = 'TESTADDON';
        packAddOn.Package_Price__c = 2;
        packAddOn.Subscription_Type__c = 'Evergreen';
        packAddOn.Product_Family_Current_Package__c = 'TA';
        packAddOn.Package_Sub_Type__c = 'Tiered';
        packAddOn.Subscription_Period__c = '1';
        packAddOn.Billing_Type__c = 'Recurring Postpaid';
        packAddOn.Package_Type__c = 'Discount';
        packAddOn.Subscription_Period_1__c = '12';
        packAddOn.Subscription_Period__c = '12';
        insert packAddOn;
        
        
        Package_Item__c pItemMain2 = TestDataFactory.createPackageItem(1, 'Base Product')[0];
        pItemMain2.Package__c = packAddOn.Id;
        pItemMain2.Product_Rate_Plan__c = prdRatePlanMain.Id;
        pItemMain2.Product_Family__c = prodfam[0].id;
        insert pItemMain2;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Discount')[0];
        pItem.Package__c = packAddOn.Id;
        pItem.Product_Rate_Plan__c = prdRatePlan.Id;
        pItem.Product_Family__c = prodfam[0].id;
        insert pItem;
        
        Service_Access_Flag__c safRec =  TestDataFactory.createServiceAccessFlag(1)[0];
        safRec.Name = 'Test Flag';
        safRec.Flag_Description__c = 'test description';
        insert safRec;
        
        Package_Access_Flag__c pckAF = TestDataFactory.createPackageAccessFlag(1)[0];
        pckAF.Package__c = packAddOn.Id;
        pckAF.No_of_Concurrent_Users__c = 1;
        pckAF.Package_Service_Access_Flag__c = safRec.Id;
        insert pckAF;
                
      //  Key_Id__c key = Key_Id__c.getInstance('Account_Direct SPH Inter-Division');
       // 
        Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
        orderRec_0.Account__c = acc.Id;
        orderRec_0.Recipient_Contact__c = con.Id;
        orderRec_0.Billing_Contact__c = con.Id;
        orderRec_0.Delivery_Charge_Type__c = 'Z Test';
        orderRec_0.Billing_Type__c = 'Recurring Prepaid';
          orderRec_0.Billing_Account__c = billAccountList[0].id;
         orderRec_0.Credit_Balance__c = 0;
         orderRec_0.Payment_Mode__c = 'Other';
         orderRec_0.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        orderRec_0.Other_Payment_Mode__c  = 'Freelist';
        orderRec_0.Debt_Management_Treatment__c = 'SUBL';
       // orderRec_0.Create_ARMS_Customer_Account__c =false;
       // orderRec_0.Business_Profile__c = 'NONE';
        //
        //orderRec_0.Customer_Name__c = 'test';
       // orderRec_0.Customer_No__c = 'jx8l22';
        //orderRec_0.ARMS_Account_Number__c = 'jx8l22';
        //orderRec_0.Debt_Management_Treatment__c =  'NORM';
        //orderRec_0.Business_Profile__c = 'NORMAL';
        system.debug('\n\n ****limit queries 1***** ' +  Limits.getQueries() + '\n\n' );
        insert orderRec_0;  
        
        
        
        
       // Other__c testOther = Other__c.getInstance('Contact_Recordtype_Overseas');
        
        Promotion__c promo = TestDataFactory.createPromotion(1)[0]; 
        promo.Name = 'Promotions';
        promo.Contract_Period__c ='12';
        promo.Penalty_Charge__c = '100';   
        promo.Promotion_Code__c = 'jsl8x';
        insert promo;
        
        // Start VPernicia 4/2/16: UD-3896
        Promotion_Package__c PromPak = TestDataFactory.createPromotionPackage(1)[0]; 
        PromPak.Package_Name__c = packAddOn.id;
        PromPak.Promotion__c = promo.id;
        insert PromPak;
        
        //create Promotion gift
        Promotion_Gift__c newPG = TestDataFactory.createPromotionGift(1)[0];
        newPG.Gift_Inventory__c = 1000;
        newPG.Gift_Issued__c = 100;
        newPG.Gift_Redeemed__c = 100;
        insert newPG;
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];                                                     
        pub.Publication_Code__c = 'PUB1';
        pub.Published_Days__c = 'YYYYYYY';
        pub.Publication_Type__c = 'N';
        pub.Platform_Type__c = 'Print';       
        insert pub;
        
        Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  listZproducts[1].id;
        insert prodPubRec;
        
        system.debug('\n\n ****limit queries 2***** ' +  Limits.getQueries() + '\n\n' );
        
        
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        orderline[0].Main_Package_ID__c = packMain.Id;
        orderline[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline[0].Order__c = orderRec_0.Id;
        orderline[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderLine[0].Addon_Package__c = packAddOn.Id;
        orderline[0].Asia1_Creation_Mode__c = 'Bulk'; 
        orderline[0].Delivered_By__c  = 'Vendor';    
        orderline[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline[0].Main_Package_Billing_Type__c = 'Recurring';
        orderline[0].Qty__c = 6;
        orderline[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline[0].Start_Date__c = date.today().addDays(3);
        orderline[0].Term_Length__c = 7;
        orderline[0].New_Contract_Period__c = 3;
        orderline[0].Promotion_ID__c = null;//promo.id;
        orderline[0].Term_is_discussed__c = false;
        
        test.startTest();
        
        insert orderline[0];
        
        
        
        
        List<Order_Line_Item__c> orderline1 = TestDataFactory.createOrderLineItem(1);
        orderline1[0].Main_Package_ID__c = packMain.Id;
        orderline1[0].Is_Digital__c = TRUE;
        //orderline[0].Is_All_In_One__c = TRUE;
        orderline1[0].Order__c = orderRec_0.Id;
        orderline1[0].Add_On_Package_Subscription_Rate__c = 10.00;
       // orderline1[0].Addon_Package__c = packAddOn.Id;
        orderline1[0].Asia1_Creation_Mode__c = 'Bulk'; 
        //orderline1[0].Delivered_By__c  = 'Mailing Agent';    
        orderline1[0].Main_Package_Subscription_Rate__c = 90.00; 
        orderline1[0].Main_Package_Billing_Type__c = 'Recurring';
        orderline1[0].Qty__c = 3;
        orderline1[0].Main_Package_Sub_Type__c = 'Evergreen';
        orderline1[0].Start_Date__c =date.today().addDays(3);
        orderline1[0].Term_Length__c = 3;
        orderline1[0].New_Contract_Period__c = 3;
        orderline1[0].Promotion_ID__c = null;//promo.id;
        orderline1[0].Term_is_discussed__c = false;
        orderline1[0].Delivered_By__c = 'Vendor';
        insert orderline1[0];
        
        Zuora__Subscription__c subRecord2 = TestDataFactory.createSubscription(1)[0];
         subRecord2.Zuora__Account__c = acc.Id;
         subRecord2.Order_Number__c = orderRec_0.Id;
        subRecord2.Order_Number_1__c = orderRec_0.id;
        subRecord2.Subscriber_Contact__c = con.Id;
        subRecord2.Recipient_Contact__c = con.Id;
        subRecord2.Main_Package_1__c = packAddOn.id;
        subRecord2.Zuora__Status__c = 'Active';
        subRecord2.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord2.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord2.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord2.Urgent__c = 'false';
        subRecord2.Vendor_Conversion__c = 'false';
        subRecord2.Charity__c = 'false';
        subRecord2.Billing_Type__c = 'Full Prepaid';
        subRecord2.Bundled_With__c = 'TEST';
        subRecord2.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord2.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord2.Zuora__SubscriptionStartDate__c = date.today();
        subRecord2.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord2.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
        subRecord2.Main_Package__c = packAddOn.id;
        subRecord2.Zuora__CustomerAccount__c = billAccountList[0].Id; 
        insert subRecord2;
        //Zuora_HPM_Settings__c hpm = Zuora_HPM_Settings__c.getInstance('Amex');
        /* 
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        //subRecord.Order__c = order.id;
        subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
        subRecord.Main_Package_1__c = packAddOn.id;
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
        subRecord.Main_Package__c = packAddOn.id;
        subRecord.Zuora__CustomerAccount__c = billAccountList[0].Id; 
        //START: Tine Test Classes 04/24/2016 
        try{
            database.insert(subRecord);
        }catch(Exception e){
            System.debug('Error ' + e);
        }*/
        Asia1__c asia1 = TestDataFactory.createAsiaOne(1)[0];
        asia1.Contact__c = con.Id;
        asia1.User_ID_LDAP_ID__c = 'userId27';
        asia1.Order_Number__c = orderRec_0.Name;
        asia1.Display_Name__c = 'acn@sphcom.sg';
        asia1.Password__c = 'jx8mng1';
        insert asia1;
        
        Asia1_Subscription__c asia1Sub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asia1Sub.Asia1__c = asia1.Id;
        asia1Sub.Order_Line_Item__c = orderline1[0].Id;
        asia1Sub.Service_Access_Flag__c = safRec.Id;
        asia1Sub.Status__c = 'Enabled';
        insert asia1Sub;
        
        PageReference pRef = Page.StopSub_Order_Entry_Direct_Edit;
        apexpages.currentPage().getParameters().put('accountid',acc.id);
        Test.setCurrentPage(pRef);
        
       try{
           StopSubOrderEntryDirectController ssec = new StopSubOrderEntryDirectController();
        ssec.account = acc;
        StopSubOrderEntryDirectController.SubscriptionWrapper asiaSubWrap = new StopSubOrderEntryDirectController.SubscriptionWrapper();
        asiaSubWrap.enableaddButton = true;
        list<StopSubOrderEntryDirectController.SubscriptionWrapper> asiaSubWrapList = new list<StopSubOrderEntryDirectController.SubscriptionWrapper>();
        asiaSubWrapList.add(asiaSubWrap);
        ssec.allSubscriptionResultList  = asiaSubWrapList;
        StopSubOrderEntryDirectController.OrderLineItemWrapper OLIWrapper = new StopSubOrderEntryDirectController.OrderLineItemWrapper();
        list<StopSubOrderEntryDirectController.OrderLineItemWrapper > oliWrapperList = new list<StopSubOrderEntryDirectController.OrderLineItemWrapper >();
        ssec.relatedSubscriptionResultList = oliWrapperList;
       } catch(Exception e){
           system.debug('\n\n ***DEBUG ERROR ****  ' + e.getMessage() + '\n\n' );
           system.debug('\n\n ***DEBUG ERROR ****  ' + e.getLineNUmber() + '\n\n' );
           system.debug('\n\n ***DEBUG ERROR ****  ' + e.getStackTraceString() + '\n\n' );
       }
        
    Test.stopTest();    
    } 
    
}//END StopSubOrderEntryDirectControlleTest