@isTest(seeAllData = True)
private class SubscriptionUtilTest{
    
    /*
    *   @description: This test method executes mostly all methods used in the
    *               base class to test if it's working with a Package Type of 'Add on'.
    *   @Parameters: N/A
    *   @return: N/A
    */ 
    
    static testMethod void test_SubscriptionUtil(){
        //This prepares the data needed 
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
        
        Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
        promopack.Promotion__c = promo.id;
        promopack.Package_Name__c = pack.id;
        database.insert(promopack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        zProduct.zqu__SKU__c = 'Product SKU';
        database.insert(zProduct);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
        database.insert(addressRec);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con);
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);            
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Order_Type__c = ConstantsSLB.getOther('Order_Type Renewal');
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
        order.Billing_Contact__c= con1.id;
        database.insert(order);
        
        Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        //subRecord.Order__c = order.id;
        subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
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
        subRecord.Main_Package_1__c = pack.id;
        database.insert(subRecord);
        
        Product_Family__c prodFamily = new Product_Family__c();
        prodFamily.Product_Family__c = 'CODEFAMILY2424';
        prodFamily.Product_Family_Name__c = 'CODEFAMILY2424';
        database.insert(prodFamily);
        
        /*Package_Product_Family__c family = new Package_Product_Family__c();
        family.Package_Name__c = pack.id;
        family.Product_Family__c = prodFamily.id;
        insert family;*/
        
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
        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        database.insert(cas);
        
        Promotion_Gift__c promgift = TestDataFactory.createPromotionGift(1)[0];
        promgift.Gift_Inventory__c = 1;
        promgift.Gift_Issued__c = 1;
        promgift.Gift_Redeemed__c = 1;
        database.insert(promgift);
        
        Order_Line_Item_Gift__c oligift = TestDataFactory.createItemGift(1)[0];
        oligift.Order_Line_Item__c = oli.id;
        oligift.Promotion_Gift__c = promgift.id;
        oligift.Redemption_Date__c = date.today();
        
        Test.startTest();
        
        
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
        SAF.Flag_Code__c = 'TEST';
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
        tmpAsia1.Contact__c = con.Id;
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
        publicationList[0].Published_Days__c = '7';
        publicationList[0].Publication_Type__c = 'A';
        publicationList[1].Product_Family__c = 'Time';
        publicationList[1].Published_Days__c = '7';
        publicationList[1].Publication_Type__c = 'A';
        database.insert(publicationList);
        
        
        //create oliv
        List<Order_Line_Item_Vendor__c> orderLineItemList = TestDataFactory.createOrderLineItemVendor(2);
        for(Order_Line_Item_Vendor__c oliv:orderLineItemList){
            oliv.Order__c = order.id;
        }
        
        //set specialPublications
        //orderLineItemList[0].Publication__c = publicationList[0].Id;
        
        //set Wrapper_Number__c
        //orderLineItemList[1].Wrapper_Number__c = 1;
        database.insert(orderLineItemList);
        
        
        PageReference pRef = Page.StopSub_Order_Entry_Direct_Edit;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('def_parent_id', cas.Id);
        ApexPages.currentPage().getParameters().put('accountId', acc.Id);
        ApexPages.currentPage().getParameters().put('orderId', order.Id);
        ApexPages.currentPage().getParameters().put('recordtype',constantsSLB.getKeyId('Account_Direct Corporate'));
        ApexPages.currentPage().getParameters().put('subRecordId', subRecord.Id);        
        ApexPages.currentPage().getParameters().put('Id', oli.Id);
        ApexPages.currentPage().getParameters().put('Id', pub.id);
        
        //StopSubOrderEntryDirectController StopSubOrderEntryDirect = new StopSubOrderEntryDirectController();
        //StopSubOrderEntryDirect.myId = subRecord.id;
        //StopSubOrderEntryDirect.getOrder();
        //StopSubOrderEntryDirect.setOrder();     
        //StopSubOrderEntryDirect.setSubscriptionRecords();        
        
        //StopSubOrderEntryDirect.isSRDValid(StopSubOrderEntryDirect.getSelectedSubscription());
        //StopSubOrderEntryDirect.isSRDValid(StopSubOrderEntryDirect.getSelectedSubscription(), StopSubOrderEntryDirect.getPublication(StopSubOrderEntryDirect.getSelectedSubscription()));
        //StopSubOrderEntryDirect.getGivenCopies(StopSubOrderEntryDirect.getSelectedSubscription());
        //StopSubOrderEntryDirect.getAdminFee(StopSubOrderEntryDirect.getSelectedSubscription());
        //StopSubOrderEntryDirect.getRefund(StopSubOrderEntryDirect.getSelectedSubscription());

        //Will not enter the If condition because of the Case created that is MAGAZINE
        //StopSubOrderEntryDirect.getMissedCopies(StopSubOrderEntryDirect.getSelectedSubscription());
        //StopSubOrderEntryDirect.removeSubscriptionRecord();
        
        //StopSubOrderEntryDirect.doSave();
        //PageReference pgSaveAsDraft = StopSubOrderEntryDirect.saveAsDraft();  
        //PageReference pgCancel = StopSubOrderEntryDirect.doCancel();    
        
        //List<Order_Line_Item__c> myOliList = new List<Order_Line_Item__c>();
        //myOliList.add(oli);
        
        //StopSubOrderEntryDirect.checkFieldsInOrder(myOliList);
        
        /*StopSubOrderEntryDirect.checkRetention();
        StopSubOrderEntryDirect.getOLI();
        StopSubOrderEntryDirect.getSubscriptions()
        StopSubOrderEntryDirect.doSave();
        StopSubOrderEntryDirect.getAccount();*/
        
        Test.stopTest();     
  
    }

         static testMethod void SubscriptionUtilTest3(){
          
            //Create a new user with Standard User Profile
            User testUser = new User(
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
            
            System.runAs(testUser) {
            
                Project__c pro = TestDataFactory.createProject(1)[0];
                pro.Project_Description__c = 'This is a new confidential project.';
                Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
                singpostAdd.House_Block_Number__c = 'TEST';
                singpostAdd.Address_Type__c = 'A';
                singpostAdd.Name = '99';
                Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack = TestDataFactory.createPackage(1)[0];
                pack.Billing_Type__c = 'Full Prepaid';
                pack.Package_Type__c = 'Base';
                pack.Subscription_Period__c = '18';
                pack.Package_Code__c = 'afds132';
                Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
                zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
                Gift__c gift = TestDataFactory.createGift(1)[0];
                gift.Gift_Type__c = 'Premium';
                gift.One_Time_Charge__c = 55;
                insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
                
                zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                prdRatePlan.zqu__ZProduct__c = zProduct.Id;
                prdRatePlan.RatePlanType__c= 'Bill Plan';
                prdRatePlan.zqu__EffectiveStartDate__c= date.today();
                prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
                prdRatePlan.zqu__Deleted__c = false;
                prdRatePlan.name = 'Test Tier Name0';
                prdRatePlan.SubscriptionFrequency__c = '2' ;
                
                Address__c add = TestDataFactory.createAddress(1)[0];
                add.Address_Type__c = 'A';
                add.Block_House_Number__c ='TEST';
                add.Level_Number__c ='xx';
                add.Unit_Number__c = 'yy';
                add.Postal_Code__c = singpostAdd.Id;
                
                
                Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
                billingAcc.Zuora__Account__c = vendorSubsAcct.Id;
                
                Promotion_Gift__c pg = TestDataFactory.createPromotionGift(1)[0];
                pg.Gift__c = gift.Id;
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                Post_Sector_Ops_Rep_Mapping__c psorm = TestDataFactory.createPostSector(1)[0];
                psorm.Postal_Sector_Code__c = Decimal.valueOf('99');//singpostAdd.Name;
                psorm.Vendor_Ops__c = UserInfo.getUserId();
                insert new List<sObject>{prdRatePlan, add, billingAcc, pg, par, psorm};
                
                zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
                prpc.PublicationCode__c = 'XXXX';
                prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
                Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                pItem.Package__c = pack.Id;
                pItem.Product_Rate_Plan__c = prdRatePlan.Id;
                pItem.Duration_in_months__c = '3';
                pItem.Effective_Start_Month__c = '3';
                
                Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
                venAlloc.SingPost_Address__c = singpostAdd.Id;
                venAlloc.Vendor_Account__c = venAccount.Id;
                venAlloc.Parcel_Name__c = par.Id;
                insert new List<sObject>{prpc, pItem, venAlloc};
                
                zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
                prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
                prpct.zqu__PriceFormat__c = 'Per Unit';
                prpct.zqu__Currency__c ='SGD';
                insert prpct;
                
                List<Publication__c> pubList = TestDataFactory.createPublication(1);
                for(Publication__c svp: pubList) {
                    svp.Publication_Code__c = prpc.PublicationCode__c;
                    svp.Published_Days__c = 'Y';
                    svp.Publication_Type__c = 'Y';
                    svp.Published_Days__c = '0';
                }
                insert pubList;
                
                Contact con = TestDataFactory.createContact(1)[0];
                con.AccountId = vendorSubsAcct.Id;
                con.Address__c = add.Id;
                con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con.Recipient_Indicator__c = true;
                insert con;
                
                Contact con1 = TestDataFactory.createContact(1)[0];
                con1.Address__c = add.Id;
                con1.AccountId = vendorSubsAcct.Id;
                con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                con1.Billing_Indicator__c = true;
                insert con1;
                
                Order__c order = TestDataFactory.createOrder(1)[0];
                order.Account__c = vendorSubsAcct.Id; 
                order.Recipient_Contact__c = con.Id;
                order.Billing_Account__c = billingAcc.Id;
                order.Informed_Customer__c = True;
                order.Order_Type__c = 'Renewal';
                order.Status__c = 'Draft';
                order.Eligible_for_Retention__c = TRUE;
                order.Payment_Mode__c = 'Credit Card';
                order.Billing_Contact__c = con1.id;
                order.Case_Record_Type__c = 'Complaint - Magazine';
                order.Category__c = 'Subscription Request';
                order.Sub_Category__c ='Stop Subscription';
                order.Credit_Balance__c = 0;
                order.Delivery_Charge__c = 0;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Order_Type__c = 'Change of Subscription Package';
                order.PO_Number__c = 'PO00000';
                insert order;
                
                Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
                cas.IsEscalated = true;
                cas.Order__c = order.Id;
                insert cas;

                Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
                oli.Order__c = order.Id;
                oli.Vendor_Subscription_ID__c = subsVen.Id;
                oli.Main_Package_ID__c = pack.Id;
                oli.Vendor_Mailing_Agent__c = venAccount.Id;
                oli.Order__c = order.Id;
                oli.End_Date__c = Date.Today().addDays(30);
                oli.Main_Package_ID__c = pack.Id;
                oli.Term_Length__c = 0;
                oli.Main_Package_Period__c = 0;
                oli.Earliest_Start_Date__c = date.today();
                oli.Earliest_Stop_Date__c = Date.Today().addDays(2);
                oli.Stop_Request_Date__c =  date.Today().addDays(4);
                oli.Terminating_Reason__c = 'Others';
                oli.Amount_To_Refund__c = 0;
                oli.Admin_Charge__c = 0;
                oli.Fee_Waiver__c = TRUE;
                oli.Fee_Override__c = TRUE;
                oli.Override_Reason__c = 'TEST';
                oli.Suppress_Notification_Stop__c = TRUE;
                oli.Main_Package_Type__c = 'Base';
                insert oli;
            
                Order_Line_Item_Gift__c olig = TestDataFactory.createItemGift(1)[0];
                olig.Order_Line_Item__c = oli.Id;
                olig.Promotion_Gift__c = pg.Id;
                insert olig;
                
                Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                zSub.Zuora__Account__c = vendorSubsAcct.Id;
                zSub.Zuora__CustomerAccount__c = billingAcc.Id;
                zSub.Order_Line_Item_Number__c = oli.Id;
                zSub.Order_Number__c = order.Id;
                zSub.Suppress_Vendor_Start_Notice__c = 'false';
                zSub.Supressed_Acknowledgement_Letter__c = 'false';
                zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                zSub.Urgent__c = 'false';
                zSub.Vendor_Conversion__c = 'false';
                zSub.Charity__c = 'false';
                zSub.Sponsor__c = 'false';
                zSub.Recipient_Contact__c = con.Id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Status__c = 'Active';
                zSub.Order_Number_1__c = order.id;
                zSub.Parent_Transaction_ID__c = '231222221111';
                Test.startTest();
                insert zSub;
                
                Zuora__SubscriptionProductCharge__c spc = TestDataFactory.createSubProductCharge(1)[0];
                spc.Zuora__Subscription__c = zSub.Id;
                spc.Zuora__RatePlanName__c = 'Test Tier Name0';
                insert spc;
                Zuora__ZInvoice__c zzi = new Zuora__ZInvoice__c();
                zzi.Zuora__BillingAccount__c = billingAcc.id;
                zzi.Zuora__Balance2__c = 150;
                insert zzi;
            
            
            External_Payment__c externalPaymentRecord = new External_Payment__c(
                Payment_amount__c = 2,
                Expiration_Date__c = Date.today(),
                Billing_Contact_email__c = 'test@sample.com',
                Billing_Contact_First_Name__c = 'John',
                Billing_Contact_Last_Name__c = 'Doe',
                Transaction_Status__c = 'F',
                Transaction_Type__c = 'F',
                Transaction_Amount__c = 100,
                Billing_Account__c = billingAcc.Id,
                Transaction_Date__c = Date.today(),
                Payment_Method__c = 'Credit Card',
                Parent_Transaction_ID__c = '231222221111'
            );
            //Test.setMock(WebServiceMock.class, new zApiAmend());
            insert externalPaymentRecord;
            
            externalPaymentRecord.Payment_Method__c = 'Credit Card';
            externalPaymentRecord.Payment_amount__c = 3;
            externalPaymentRecord.Transaction_Amount__c = 100;
            externalPaymentRecord.Transaction_Date__c = Date.today();
            update externalPaymentRecord;    

            Test.stopTest();
            }
        } 
 
}