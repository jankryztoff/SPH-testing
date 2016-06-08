/**
   @Author Joy Suarez
   @name CreateGiftLettersBatchControllerTest
   @CreateDate 2/26/2015
   @Description Test class for CreateGiftLettersBatchController
   @Version <1.0>
   @reference <Referenced program names>
  */


@isTest (SeeAllData = false)
//@isTest (SeeAllData = false)
private class CreateGiftLettersBatchControllerTest {
    
    @testSetup 
        static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createBatchInterface(); 
        insert CustomSettingsDataFactory.createPlannerSched();
    
    } 
    
    static User setUser() {
        UserRole usrRole = [SELECT id, Name from UserRole LIMIT 1];
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User usr = new User(Alias = 'test122',Email='test2@test.sph.com',
                       EmailEncodingKey='UTF-8', LastName='Testing123', 
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                       ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserRoleId = usrRole.Id,
                       UserName='testDeploymentUserSPX00@sph.com', Title='Testing123');
        insert usr;

        return usr;
    }

    static void setUpCustomSetData() {
        /*
        //CustomSettings
        RecordType Case_ChangeinAddress = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Change of Address/Vendor' LIMIT 1];
        RecordType Contact_CustomerContact = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Customer Contact' LIMIT 1];
        RecordType Address_Local = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Local' LIMIT 1];
        RecordType addressOverseas = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Overseas' LIMIT 1];
        RecordType directCorporate = [SELECT id, Name FROM RecordType WHERE SobjectType='Account' AND Name='Direct Corporate' LIMIT 1];
        RecordType addressAirline = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Airline' LIMIT 1];
        RecordType addressInternal = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Internal' LIMIT 1];
        
        //Key_Id__c
        List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role', Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='Case_Change in Address', Id__c=Case_ChangeinAddress.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Contact_Customer Contact', Id__c=Contact_CustomerContact.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Local', Id__c=Address_Local.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Overseas', Id__c=addressOverseas.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Internal', Id__c=addressInternal.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Airline', Id__c=addressAirline.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Account_Direct Corporate', Id__c=directCorporate.id ,Type__c='RecordType')
        };
        Database.insert(kisList);

        //Other__c
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        Database.insert(otherList);

        Billing_Batch__c billingBatch = new Billing_Batch__c();
        billingBatch.Next_Batch_Number__c   = 14;
        billingBatch.Batch__c               = '13,14,15';
        billingBatch.Name                   = 'Full Prepaid';
        insert billingBatch;

        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        */
    }

    //private static User setUser() {
        
    //    User testUser = new User(
    //        Alias = 'stndrd',
    //        Email='standarduser@test.com', 
    //        EmailEncodingKey='UTF-8',
    //        LastName='Test',
    //        LanguageLocaleKey='en_US', 
    //        LocaleSidKey='en_US',
    //        ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
    //        TimeZoneSidKey='America/Los_Angeles',
    //        UserName='standard@test.com'
    //    );
        
    //    return testUser;
    //}
    
    private static Project__c setPro() {
        Project__c pro = TestDataFactory.createProject(1)[0];
            pro.Project_Description__c = 'This is a new confidential project.';
            insert pro;
        return pro;
    }
    
    private static Account setVendorSubsAcct() {
        Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            vendorSubsAcct.AccountNumber = '12345';
            insert vendorSubsAcct;
        return vendorSubsAcct;
    }
    
    private static Singpost_Address__c setSingpostAdd() {
        Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
            singpostAdd.Name = '100050';
            insert singpostAdd;
        return singpostAdd;
    }
    
     private static Subscription_Vendor__c setSubsVen() {
        Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
            insert subsVen;
         return subsVen;
    }
    
    private static Package__c setPack() {
        Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Bundled';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Subscription_Period__c = '18';
            insert pack;
        return pack;
    }

    private static Account setVenAccount() {
        Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
        venAccount.Name = 'newAccount';
            insert venAccount;
        return venAccount;
    }
    
    private static zqu__ZProduct__c setZProduct() {
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.ProductFamily__c = 'BH';
            insert zProduct;
        return zProduct;
    }
    
    private static Gift__c setGift() {
        Gift__c gift = TestDataFactory.createGift(1)[0];
            gift.Gift_Type__c = 'Premium';
            gift.Gift_Code__c  = '1233333';
            gift.One_Time_Charge__c = 100;
            insert gift;
        return gift;
    }
    
    private static Promotion__c setPromotion(){
        Promotion__c promotion = TestDataFactory.createPromotion(1)[0];
            promotion.Contract_Period__c = '2';
            promotion.Effective_Start_Date__c = date.Today();
            promotion.Effective_End_Date__c = date.Today()+7;
            promotion.Promotion_Code__c = '10054';
            insert promotion;
        return promotion;
    }
        
    private static Gift_Letter_Batch__c setGlbc(String acctNbr, Promotion__c promotion, Gift__c gift) {
        Gift_Letter_Batch__c glbc = new Gift_Letter_Batch__c(
                Promo_Code__c='10054',
                Gift_Code__c='1233333',
                Customer_Account_Number__c=acctNbr,
                Start_Date__c = date.Today(),
                End_Date__c = date.Today()+7,
                Redemption_Start_Date__c=date.Today()+4,
                Redemption_End_Date__c=date.Today()+7,
                Batch_Date__c=date.today(),
                Promotion__c = promotion.Id,
                Gift__c = gift.Id,
                Letter_Template__c='Gift Letter');   
                //insert glbc;
        return glbc;
    }
        
    private static zqu__ProductRatePlan__c setPrdRatePlan(zqu__ZProduct__c zProduct) {
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            insert prdRatePlan;
        return prdRatePlan;
    }
    
    private static Address__c setAddress(Singpost_Address__c singpostAdd,Country__c countryToAddress) {
        Address__c add = TestDataFactory.createAddress(1)[0];
            add.Postal_Code__c = singpostAdd.Id;
            add.Country__c = countryToAddress.Id;
            insert add;
        return add;
    }
    //START D-4432 Gdelrosario : added to create cater for country  
    
    private static Country__c setCountry() {
            Country__c countr = TestDataFactory.createCountry(1)[0];
            countr.Code__c = 'Zz';
            insert countr;
        return countr;
    }
    
    //END D-4432 Gdelrosario : added to create cater for country
    private static Zuora__CustomerAccount__c setBillingAcc(Account venAccount) {
        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
            billingAcc.Zuora__Account__c = venAccount.Id;
            billingAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            billingAcc.Billing_Type__c = 'Full Prepaid';
            insert billingAcc;
        return billingAcc;
    }
    
    private static Parcel__c setParcel(Project__c pro) {
        Parcel__c par = TestDataFactory.createParcel(1)[0];
            par.Project_Name__c = pro.Id;
            par.Allocation_Type__c = 'SDA';
            par.Description__c = 'Description';
            insert par;
        return par;
    }
    
    private static Product_Family__c setProdFam() {
        Product_Family__c prodFam = new Product_Family__c(Product_Family__c = 'AS');
            insert prodFam;
        return prodFam;
    }
    
    private static Package_Item__c setPackItemBase(Package__c pack, zqu__ProductRatePlan__c prdRatePlan, Product_Family__c prodFam) {
        Package_Item__c pItemBase = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
            pItemBase.Package__c = pack.Id;
            pItemBase.Product_Rate_Plan__c = prdRatePlan.Id;
            pItemBase.Duration_in_months__c = '3';
            pItemBase.Effective_Start_Month__c = '3';
            pItemBase.Product_Family__c = prodFam.Id;
            insert pItemBase;
        return pItemBase;
    }
    
    private static zqu__ProductRatePlanCharge__c setProductRatePlanCharge(zqu__ProductRatePlan__c prdRatePlan) {
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            insert prpc;
        return prpc;
    }
    
    private static Package_Item__c setPackItem(zqu__ProductRatePlan__c prdRatePlan, Package_Item__c pItemBase, Package__c pack) {
        Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Bundle Discount')[0];
            pItem.Duration_in_months__c = '3';
            pItem.Effective_Start_Month__c = '3';
            pItem.Package__c = pack.Id;
            pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            pItem.Base_Package_Item__c = pItemBase.Id;
            insert pItem;
        return pItem;
    }
    
    private static Vendor_Allocation__c setVenAlloc(Singpost_Address__c singpostAdd, Account venAccount, Parcel__c par) {
        Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
            venAlloc.Allocated__c = true;
            venAlloc.SingPost_Address__c = singpostAdd.Id;
            venAlloc.Vendor_Account__c = venAccount.Id;
            venAlloc.Parcel_Name__c = par.Id;
            insert venAlloc;
        return venAlloc;
    }
    
    private static zqu__ProductRatePlanChargeTier__c setProdRatePlanCharTier(zqu__ProductRatePlanCharge__c prpc) {
        zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
            prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
            prpct.zqu__PriceFormat__c = 'Per Unit';
            prpct.zqu__Currency__c ='SGD';
            insert prpct;
        return prpct;
    }
    
    private static Publication__c setPublication() {
        Publication__c publication = TestDataFactory.createPublication(1)[0];
            publication.Publication_Code__c = 'SUT';
            publication.Publication_Type__c = '2';
            publication.Published_Days__c = 'NNNYYNN';
            insert publication;
        return publication;
    }    
    
    private static Contact setCon(Account venAccount, Address__c add) {

        Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = venAccount.Id;
            //con.Recipient_Contact__c = 1;
            con.Address__c = add.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
        return con;
    }
    
     private static Contact setCon2(Account venAccount, Address__c add) {
        Contact con2 = TestDataFactory.createContact(1)[0];
            con2.AccountId = venAccount.Id;
            //con.Recipient_Contact__c = 1;
            con2.Billing_Indicator__c = true;
            con2.Address__c = add.Id;
            con2.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            //con2.Recipient_Indicator__c = true;
            insert con2;
        return con2;
    }
    //START D-4432 Gdelrosario 14.3.2016
    private static Address__c setAddress(Country__c countryToAddress) {
        Address__c addr = TestDataFactory.createAddress(1)[0];
            addr.Level_Number__c = '21';
            addr.Country__c = countryToAddress.Id;
            insert addr; 
        return addr;
    }
     //END D-4432 Gdelrosario 14.3.2016
     
    private static Order__c setOrder(Account venAccount, Contact con, Zuora__CustomerAccount__c billingAcc, boolean isInformedCustomer) {
        Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = venAccount.Id;
            order.Recipient_Contact__c = con.Id;
            order.Billing_Account__c = billingAcc.Id;
            //order.Informed_Customer__c = true;
            order.Informed_Customer__c = isInformedCustomer;
            order.Billing_Type__c = 'Full Prepaid';
            order.Subscriber_Charge__c = 15;
            order.DTL_Date__c = date.Today();
            order.Order_Type__c = 'Change of Subscription';
            //order.Billing_Contact__c //joy
            insert order; 
        return order;
    }
    
    private static Order__c setOrder2(Account venAccount, Contact con, Zuora__CustomerAccount__c billingAcc, boolean isInformedCustomer) {
        Order__c order2 = TestDataFactory.createOrder(1)[0];
            order2.Account__c = venAccount.Id;
            //order.Recipient_Contact__c = con.Id;
            order2.Billing_Account__c = billingAcc.Id;
            //order.Informed_Customer__c = true;
            order2.Informed_Customer__c = isInformedCustomer;
            order2.Billing_Type__c = 'Full Prepaid';
            order2.Subscriber_Charge__c = 15;
            order2.DTL_Date__c = date.Today();
            order2.Order_Type__c = 'Change of Subscription';
            order2.Billing_Contact__c = con.id;
            insert order2; 
        return order2;
    }
                
    private static Case setCase(Order__c order) {
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            insert cas; 
        return cas;
    }
    
    private static Promotion_Gift__c setPromoGift(Gift__c gift, Promotion__c promotion) {
        Promotion_Gift__c pg =  new Promotion_Gift__c(
                    Gift_Inventory__c = 1000,
                    Gift_Issued__c = 200,
                    Gift_Redeemed__c = 0,
                    Gift__c = gift.id,
                    Redemption_Start_Date__c = date.Today()+4,
                    Redemption_End_Date__c = date.Today()+7,
                    Promotion__c = promotion.id
                    );
        return pg;
    }            
    
    private static Order_Line_Item__c setOrderLineItem(Order__c order, Subscription_Vendor__c subsVen, Package__c pack, Account venAccount) {
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Vendor_Subscription_ID__c = subsVen.Id;
            oli.Main_Package_ID__c = pack.Id;
            oli.Vendor_Mailing_Agent__c = venAccount.Id;
            oli.Start_Date__c = date.today()+3; //joy
            insert oli;
        return oli;
    }
         
    private static Order_Line_Item_Gift__c setOrderLineItemGift(Order_Line_Item__c oli, List<Promotion_Gift__c> pgList, Integer j) {
        Order_Line_Item_Gift__c olig = new Order_Line_Item_Gift__c(
                    Order_Line_Item__c = oli.id,
                    Promotion_Gift__c = pgList[j].id,
                    Has_Letter_Attached__c = false
                );
        return olig;
    }
      
    private static Zuora__Subscription__c setZSub(Account venAccount, Order_Line_Item__c oli, Order__c order, Contact con, Zuora__CustomerAccount__c billingAcc) {
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0]; 
            zSub.Zuora__Account__c = venAccount.Id;
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
            zSub.Zuora__CustomerAccount__c = billingAcc.Id;
            zSub.Number_of_Copies__c=100;
            zSub.Number_of_Copies1__c =  '100';
            zSub.Qty__c = 20;
            zSub.Zuora__Status__c='Cancelled';
            zSub.Zuora__SubscriptionStartDate__c=date.today();
            //zSub.Zuora__SubscriptionEndDate__c= date.today().addDays(100);
            zSub.Zuora__SubscriptionEndDate__c= null;
            zSub.Term_Length__c= 2;
   
            insert zSub;
        return zSub;
    }
    
    private static Zuora__Subscription__c setZSub2(Account venAccount, Order__c order2, Contact con, Zuora__CustomerAccount__c billingAcc) {
        Zuora__Subscription__c zSub2 = TestDataFactory.createSubscription(1)[0]; 
            zSub2.Zuora__Account__c = venAccount.Id;
            zSub2.Order_Number__c = order2.Id;
            zSub2.Suppress_Vendor_Start_Notice__c = 'false';
            zSub2.Supressed_Acknowledgement_Letter__c = 'false';
            zSub2.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub2.Urgent__c = 'false';
            zSub2.Vendor_Conversion__c = 'false';
            zSub2.Charity__c = 'false';
            zSub2.Sponsor__c = 'false';
            zSub2.Recipient_Contact__c = con.Id;
            zSub2.Zuora__CustomerAccount__c = billingAcc.Id;
            zSub2.Number_of_Copies__c=100;
            zSub2.Number_of_Copies1__c =  '100';
            zSub2.Qty__c = 20;
            zSub2.Zuora__Status__c='Cancelled';
            zSub2.Zuora__SubscriptionStartDate__c=date.today();
            //zSub.Zuora__SubscriptionEndDate__c= date.today().addDays(100);
            zSub2.Zuora__SubscriptionEndDate__c= null;
            zSub2.Term_Length__c= 2;
   
            insert zSub2;
        return zSub2;
    }
    
    private static Order_Line_Item__c setOrderLineItem2(Zuora__Subscription__c zSub2,Order__c order2, Subscription_Vendor__c subsVen, Package__c pack, Account venAccount) {
        Order_Line_Item__c oli2 = TestDataFactory.createOrderLineItem(1)[0];
            oli2.Order__c = order2.Id;
            oli2.Subscription__c = zSub2.Id;
            oli2.Main_Package_ID__c = pack.Id;
            oli2.Vendor_Mailing_Agent__c = venAccount.Id;
            oli2.Start_Date__c = date.today()+3; //joy
            insert oli2;
        return oli2;
    }
      
     private static Zuora__SubscriptionProductCharge__c setzSubProdCharge(Zuora__Subscription__c zSub2) {
        Zuora__SubscriptionProductCharge__c  zSubProdCharge = TestDataFactory.createSubProductCharge(1)[0];
        zSubProdCharge.Zuora__ProductSKU__c = 'SKU-0000075';
        zSubProdCharge.Zuora__Subscription__c = zSub2.id;
        zSubProdCharge.Zuora__RatePlanName__c= 'RATE_PLAN_NAME';
        zSubProdCharge.Zuora__Model__c = 'Discount-Percentage';
        zSubProdCharge.Zuora__ProductName__c = 'discount';
        insert zSubProdCharge; 
        return zSubProdCharge;
    }  
    
    private static zqu__ZProduct__c setzquZprod() {
        zqu__ZProduct__c zquzProd2 = TestDataFactory.createZProduct(1)[0];
        zquzProd2.zqu__SKU__c = 'SKU-0000075';
        zquzProd2.ProductPlatform__c = 'Print';
        insert zquzProd2; 
        return zquzProd2;
    }  
    
    private static zqu__ProductRatePlan__c setzquProdratePlan(zqu__ZProduct__c zquzProd2) {
        zqu__ProductRatePlan__c prdRatePlan2 = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan2.zqu__ZProduct__c = zquzProd2.Id;
        prdRatePlan2.RatePlanType__c = 'Bill Plan'; 
        prdRatePlan2.RatePlanSubType__c = 'Standard'; 
        prdRatePlan2.Name = 'RATE_PLAN_NAME';
        insert prdRatePlan2;
        return prdRatePlan2;
    }  
       
    private static zqu__ProductRatePlanCharge__c setzquProdratePlanCharge(zqu__ProductRatePlan__c prdRatePlan2) {
        zqu__ProductRatePlanCharge__c prpc2 = TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc2.zqu__ProductRatePlan__c = prdRatePlan2.Id;
        prpc2.PublicationCode__c = 'PUB1';
        prpc2.Name = 'RATE_PLAN_NAME';
        
        insert prpc2;
        return prpc2;
    }      
   /**
    *  To test CreateGiftLettersBatchControllerTest 
    *  @name testCreateGiftLettersBatch
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testCreateGiftLettersBatch(){
        //static void testCreateGiftLettersBatch(){
    
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
    
        User testUser = setUser();
        
        System.runAs(testUser) {
            setUpCustomSetData();
    
            Project__c pro = setPro();                        
            Account vendorSubsAcct = setVendorSubsAcct();            
            Singpost_Address__c singpostAdd = setSingpostAdd();            
            Subscription_Vendor__c subsVen = setSubsVen();            
            Package__c pack = setPack();           
            Account venAccount = setVenAccount();            
            zqu__ZProduct__c zProduct = setZProduct();            
            Gift__c gift = setGift();
            //insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
            String acctNbr = [SELECT AccountNumber FROM Account WHERE Id = :vendorSubsAcct.Id][0].AccountNumber;
            
            String acctNbr2 = [SELECT AccountNumber FROM Account WHERE Id = :venAccount.Id][0].AccountNumber;
            System.debug('venAccount2: >>> ' + acctNbr2);
            
            Promotion__c promotion = setPromotion();
            
            List<Gift_Letter_Batch__c> glb = new List<Gift_Letter_Batch__c>();
            
            Gift_Letter_Batch__c glbc = setGlbc(acctNbr2, promotion, gift);
            insert glbc;
                                 
            zqu__ProductRatePlan__c prdRatePlan = setPrdRatePlan(zProduct);
            //START D-4432 Gdelrosario 14.3.2016
            Country__c country1 = setCountry();
            Address__c add = setAddress(singpostAdd,country1);    
            //END D-4432 Gdelrosario         
            Zuora__CustomerAccount__c billingAcc = setBillingAcc(venAccount);            
            Parcel__c par = setParcel(pro);

            //insert new List<sObject>{prdRatePlan, add, billingAcc, par/*, psorm*/};            
            Product_Family__c prodFam = setProdFam();            
            Package_Item__c pItemBase = setPackItemBase(pack, prdRatePlan, prodFam);            
            //insert new List<sObject>{pItemBase};
            
            zqu__ProductRatePlanCharge__c prpc = setProductRatePlanCharge(prdRatePlan);
            Package_Item__c pItem = setPackItem(prdRatePlan, pItemBase, pack);            
            Vendor_Allocation__c venAlloc = setVenAlloc(singpostAdd, venAccount, par);
            
            //insert new List<sObject>{prpc, pItem, venAlloc};            
            zqu__ProductRatePlanChargeTier__c prpct = setProdRatePlanCharTier(prpc);                
            Publication__c publication = setPublication();            
            Contact con = setCon(venAccount, add); 
            //START D-4432 Gdelrosario 14.3.2016           
            Address__c addr = setAddress(country1);
            //END D-4432 Gdelrosario 14.3.2016
            Order__c order = setOrder(venAccount, con, billingAcc, false) ;
            system.assertNotEquals(null, order);            
            Case cas = setCase(order);
            
            List<Promotion_Gift__c> pgList = new List<Promotion_Gift__c>();
            for(Integer i=0;i<5;i++){ //i < 200
                Promotion_Gift__c pg =  setPromoGift(gift, promotion);                
                pgList.add(pg);
            }
            insert pgList;
            
            Order_Line_Item__c oli = setOrderLineItem(order, subsVen, pack, venAccount);

            List<Order_Line_Item_Gift__c> oligList = new List<Order_Line_Item_Gift__c>();
            for(Integer j=0;j<5;j++){ //i < 200
                Order_Line_Item_Gift__c olig = setOrderLineItemGift(oli, pgList, j);
                oligList.add(olig);
            }
            insert oligList;
            
            Test.startTest();
            
            Zuora__Subscription__c zSub = setZSub(venAccount, oli, order, con, billingAcc);
            system.debug(zSub);
            
            Map<String, sObject> valuesToParseMap = new Map<String, sObject> ();
            
            
           
            PageReference pRef = Page.CreateGiftLettersBatchPage;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('Id', glbc.Id);
            CreateGiftLettersBatchController controller = new CreateGiftLettersBatchController();
            controller.giftLetterBatchList = [SELECT Id, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, 
                                   Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c 
                                   FROM Gift_Letter_Batch__c  WHERE Id =: apexpages.currentpage().getparameters().get('Id') LIMIT 1];
     
            
            for(CreateGiftLettersBatchController.OrderObj o: controller.getOrderList1()) {
                o.selected = true;
            }
            controller.generateGiftLetter();
            
            Id giftLetterBatchId = apexpages.currentpage().getparameters().get('Id');
            List<Gift_Letter_Batch__c> giftLetterBatchList = [SELECT Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c FROM Gift_Letter_Batch__c  WHERE Id =: giftLetterBatchId LIMIT 1];
            system.debug('2giftLetterBatchList[0].Promotion__r.Promotion_Code__c: ' + giftLetterBatchList[0].Promotion__r.Promotion_Code__c);
            system.debug('2giftLetterBatchList[0].Gift__r.Gift_Code__c: ' + giftLetterBatchList[0].Gift__r.Gift_Code__c);
            system.debug('2giftLetterBatchList[0].Customer_Account_Number__c: ' + giftLetterBatchList[0].Customer_Account_Number__c);
            system.debug('2giftLetterBatchList[0].Start_Date__c: ' + giftLetterBatchList[0].Start_Date__c);
            system.debug('2giftLetterBatchList[0].End_Date__c: ' + giftLetterBatchList[0].End_Date__c);
            //system.debug('giftLetterBatchList[0].End_Date__c: ' + giftLetterBatchList[0].End_Date__c);
            
            system.debug('2Query Start');
            System.debug('2query you: ' + giftLetterBatchList);
            
            
            List<Order_Line_Item_Gift__c> oliga = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, // START-END : D-1141 2/6/2015 Alyana Navarro
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new field to the query.
                                                Has_Letter_Attached__c
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                FROM Order_Line_Item_Gift__c 
                                                
                          //START:D-1022 1/13/15 Added by Manolo Valeña - Updated the Clauses to compare the Promotion Code field of the Promotion lookup and the Gift Code field of the Gift lookup.
                          WHERE order_Line_Item__r.Order__r.Account__r.AccountNumber =: giftLetterBatchList[0].Customer_Account_Number__c
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga AccountNumber: ' + oliga.size());
            System.debug('2oliga AccountNumber: ' + oliga);
            
            
            List<Order_Line_Item_Gift__c> oliga2 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, // START-END : D-1141 2/6/2015 Alyana Navarro
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new field to the query.
                                                Has_Letter_Attached__c
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                FROM Order_Line_Item_Gift__c 
                                                
                          //START:D-1022 1/13/15 Added by Manolo Valeña - Updated the Clauses to compare the Promotion Code field of the Promotion lookup and the Gift Code field of the Gift lookup.
                          WHERE promotion_gift__r.Promotion__r.Promotion_Code__c =: giftLetterBatchList[0].Promotion__r.Promotion_Code__c
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga Promotion_Code__c: ' + oliga2.size());
            System.debug('2oliga Promotion_Code__c: ' + oliga2);
            
            List<Order_Line_Item_Gift__c> oliga3 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, // START-END : D-1141 2/6/2015 Alyana Navarro
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new field to the query.
                                                Has_Letter_Attached__c
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                FROM Order_Line_Item_Gift__c 
                                                
                          //START:D-1022 1/13/15 Added by Manolo Valeña - Updated the Clauses to compare the Promotion Code field of the Promotion lookup and the Gift Code field of the Gift lookup.
                          WHERE promotion_gift__r.Gift__r.Gift_Code__c =: giftLetterBatchList[0].Gift__r.Gift_Code__c
                                                //END:D-1022 1/13/15 Added by Manolo Valeña
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga Gift_Code__c: ' + oliga3.size());
            System.debug('2oliga Gift_Code__c: ' + oliga3);
            
            List<Order_Line_Item_Gift__c> oliga4 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, // START-END : D-1141 2/6/2015 Alyana Navarro
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new field to the query.
                                                Has_Letter_Attached__c
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                FROM Order_Line_Item_Gift__c 
                                                
                          //START:D-1022 1/13/15 Added by Manolo Valeña - Updated the Clauses to compare the Promotion Code field of the Promotion lookup and the Gift Code field of the Gift lookup.
                          WHERE Order_Line_Item__r.Order__r.DTL_Date__c >=: giftLetterBatchList[0].Start_Date__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c <=: giftLetterBatchList[0].End_Date__c
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new filter.
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga DTL_Date__c: ' + oliga4.size());
            System.debug('2oliga DTL_Date__c: ' + oliga4);
                                                                            
           List<Order_Line_Item_Gift__c> oliga5 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, // START-END : D-1141 2/6/2015 Alyana Navarro
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new field to the query.
                                                Has_Letter_Attached__c
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                FROM Order_Line_Item_Gift__c 
                                                
                          //START:D-1022 1/13/15 Added by Manolo Valeña - Updated the Clauses to compare the Promotion Code field of the Promotion lookup and the Gift Code field of the Gift lookup.
                          WHERE Has_Letter_Attached__c = false
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga Has_Letter_Attached__c: ' + oliga5.size());
            System.debug('2oliga Has_Letter_Attached__c: ' + oliga5);
            
            
            List<Order_Line_Item_Gift__c> oliga6 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, // START-END : D-1141 2/6/2015 Alyana Navarro
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new field to the query.
                                                Has_Letter_Attached__c
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                FROM Order_Line_Item_Gift__c 
                                                
                          //START:D-1022 1/13/15 Added by Manolo Valeña - Updated the Clauses to compare the Promotion Code field of the Promotion lookup and the Gift Code field of the Gift lookup.
                          WHERE promotion_gift__r.Promotion__r.Promotion_Code__c =: giftLetterBatchList[0].Promotion__r.Promotion_Code__c
                          AND promotion_gift__r.Gift__r.Gift_Code__c =: giftLetterBatchList[0].Gift__r.Gift_Code__c
                                                //END:D-1022 1/13/15 Added by Manolo Valeña
                          
                          AND order_Line_Item__r.Order__r.Account__r.AccountNumber =: giftLetterBatchList[0].Customer_Account_Number__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c >=: giftLetterBatchList[0].Start_Date__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c <=: giftLetterBatchList[0].End_Date__c
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new filter.
                                                AND Has_Letter_Attached__c = false
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga all: ' + oliga6.size());
            System.debug('2oliga all: ' + oliga6);
            
            
            
            //List<Contact> contactList  = [SELECT Id, FirstName, LastName, Address__r.Id, Salutation FROM Contact WHERE Id IN: contactIdSet];
            //System.debug('contactList: ' + contactList.size());
            //System.debug('contactList: ' + contactList);
            
            controller.showCustomerList();
            controller.generateGiftLetterBatch();
            //controller.previewPage();
            System.assertNotEquals(null, controller.cancel());
            System.assertNotEquals(null, controller.displayPreview(valuesToParseMap));
            
            Test.stopTest();
          }
          }catch(Zuora.zRemoteException e) {
          }
  }  
           
    
    /**
    *  To test CreateGiftLettersBatchControllerTest 
    *  @name testCreateGiftLettersBatch2
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testMethod void testCreateGiftLettersBatch2(){
        //static void testCreateGiftLettersBatch2(){
    
        try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
    
        User testUser = setUser();
        
        System.runAs(testUser) {
            setUpCustomSetData();  

            Project__c pro = setPro();                        
            Account vendorSubsAcct = setVendorSubsAcct();            
            Singpost_Address__c singpostAdd = setSingpostAdd();            
            Subscription_Vendor__c subsVen = setSubsVen();            
            Package__c pack = setPack();           
            Account venAccount = setVenAccount();            
            zqu__ZProduct__c zProduct = setZProduct();            
            Gift__c gift = setGift();
            
            //insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
            
            String acctNbr = [SELECT AccountNumber FROM Account WHERE Id = :vendorSubsAcct.Id][0].AccountNumber;
            
            String acctNbr2 = [SELECT AccountNumber FROM Account WHERE Id = :venAccount.Id][0].AccountNumber;
            System.debug('venAccount2: >>> ' + acctNbr2);
            
            Promotion__c promotion = setPromotion();
            
            List<Gift_Letter_Batch__c> glb = new List<Gift_Letter_Batch__c>();
            //Gift_Letter_Batch__c glbc = setGlbc('', promotion, gift);
            //Gift_Letter_Batch__c glbc2 = setGlbc('', promotion, gift);
            Gift_Letter_Batch__c glbc = setGlbc(acctNbr2, promotion, gift);
            Gift_Letter_Batch__c glbc2 = setGlbc(acctNbr2, promotion, gift);
            glb.add(glbc);
            glb.add(glbc2);    
            insert glb;
                             
            zqu__ProductRatePlan__c prdRatePlan = setPrdRatePlan(zProduct);            
            //START D-4432 Gdelrosario 14.3.2016
            Country__c country1 = setCountry();
            Address__c add = setAddress(singpostAdd,country1);    
            //END D-4432 Gdelrosario            
            Zuora__CustomerAccount__c billingAcc = setBillingAcc(venAccount);            
            Parcel__c par = setParcel(pro);

            //insert new List<sObject>{prdRatePlan, add, billingAcc, par/*, psorm*/};            
            Product_Family__c prodFam = setProdFam();            
            Package_Item__c pItemBase = setPackItemBase(pack, prdRatePlan, prodFam);
            //insert new List<sObject>{pItemBase};
            
            zqu__ProductRatePlanCharge__c prpc = setProductRatePlanCharge(prdRatePlan);            
            Package_Item__c pItem = setPackItem(prdRatePlan, pItemBase, pack);            
            Vendor_Allocation__c venAlloc = setVenAlloc(singpostAdd, venAccount, par);            
            //insert new List<sObject>{prpc, pItem, venAlloc};
            
            zqu__ProductRatePlanChargeTier__c prpct = setProdRatePlanCharTier(prpc);                
            Publication__c publication = setPublication();            
            Contact con = setCon(venAccount, add);
            //START D-4432 Gdelrosario 14.3.2016
            Address__c addr = setAddress(country1);   
            //END D-4432 Gdelrosario 14.3.2016
            Order__c order = setOrder(venAccount, con, billingAcc, true);
            //order.Informed_Customer__c = True;
            system.assertNotEquals(null, order);
            
            Case cas = setCase(order);
            
            List<Promotion_Gift__c> pgList = new List<Promotion_Gift__c>();
            for(Integer i=0;i<5;i++){ //i < 200
                Promotion_Gift__c pg =  setPromoGift(gift, promotion);
                pgList.add(pg);
            }
            insert pgList;

            Order_Line_Item__c oli = setOrderLineItem(order, subsVen, pack, venAccount);
            List<Order_Line_Item_Gift__c> oligList = new List<Order_Line_Item_Gift__c>();
            for(Integer j=0;j<5;j++){ //i < 200
                Order_Line_Item_Gift__c olig = setOrderLineItemGift(oli, pgList, j);
                oligList.add(olig);
            }
            insert oligList;
            
            Test.startTest();
            Zuora__Subscription__c zSub = setZSub(venAccount, oli, order, con, billingAcc);
            system.debug('zSub2: >>> ' + zSub);
            
            Map<String, sObject> valuesToParseMap = new Map<String, sObject> ();          
           
            PageReference pRef = Page.CreateGiftLettersBatchPage;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('Id', glbc2.Id);
            CreateGiftLettersBatchController controller = new CreateGiftLettersBatchController();
            controller.giftLetterBatchList = [SELECT Id, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, 
                                   Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c 
                                   FROM Gift_Letter_Batch__c  WHERE Id =: apexpages.currentpage().getparameters().get('Id') LIMIT 1];
     
            
            for(CreateGiftLettersBatchController.OrderObj o: controller.getOrderList1()) {
                o.selected = true;
            }            
            
            controller.generateGiftLetter();
            
            Id giftLetterBatchId = apexpages.currentpage().getparameters().get('Id');
            List<Gift_Letter_Batch__c> giftLetterBatchList = [SELECT Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c FROM Gift_Letter_Batch__c  WHERE Id =: giftLetterBatchId LIMIT 1];
            system.debug('2giftLetterBatchList[0].Promotion__r.Promotion_Code__c: ' + giftLetterBatchList[0].Promotion__r.Promotion_Code__c);
            system.debug('2giftLetterBatchList[0].Gift__r.Gift_Code__c: ' + giftLetterBatchList[0].Gift__r.Gift_Code__c);
            system.debug('2giftLetterBatchList[0].Customer_Account_Number__c: ' + giftLetterBatchList[0].Customer_Account_Number__c);
            system.debug('2giftLetterBatchList[0].Start_Date__c: ' + giftLetterBatchList[0].Start_Date__c);
            system.debug('2giftLetterBatchList[0].End_Date__c: ' + giftLetterBatchList[0].End_Date__c);
            //system.debug('giftLetterBatchList[0].End_Date__c: ' + giftLetterBatchList[0].End_Date__c);
            
            system.debug('2Query Start');
            System.debug('2query you: ' + giftLetterBatchList);
            
            
            List<Order_Line_Item_Gift__c> oliga = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, // START-END : D-1141 2/6/2015 Alyana Navarro
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new field to the query.
                                                Has_Letter_Attached__c
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                FROM Order_Line_Item_Gift__c 
                                                
                          //START:D-1022 1/13/15 Added by Manolo Valeña - Updated the Clauses to compare the Promotion Code field of the Promotion lookup and the Gift Code field of the Gift lookup.
                          WHERE order_Line_Item__r.Order__r.Account__r.AccountNumber =: giftLetterBatchList[0].Customer_Account_Number__c
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga: ' + oliga.size());
            System.debug('2oliga: ' + oliga);
            
            
            controller.showCustomerList();
            controller.generateGiftLetterBatch();
            //controller.previewPage();
            //controller.cancel();
            //controller.displayPreview(valuesToParseMap);
            
            System.assertNotEquals(null, controller.cancel());
            System.assertNotEquals(null, controller.displayPreview(valuesToParseMap));
           
            Test.stopTest();
        }
          }catch(Zuora.zRemoteException e) {
          }  
                  
    
  }  
    /**
    *  To test CreateGiftLettersBatchControllerTest 
    *  @name testCreateGiftLettersBatch2
    *  @param none
    *  @return none
    *  @throws na
    */ 
    //START D-4432 Gdelrosario 
    /*
    static testMethod void testCreateGiftLettersBatch3(){
        //static void testCreateGiftLettersBatch3(){
    
         try {
            //Test.setMock(WebServiceMock.class, new zLoginMock());
    
        User testUser = setUser();
        
        System.runAs(testUser) {
    
            Project__c pro = TestDataFactory.createProject(1)[0];
            pro.Project_Description__c = 'This is a new confidential project.';
            
            Account vendorSubsAcct = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            vendorSubsAcct.AccountNumber = '12345';
            
            Singpost_Address__c singpostAdd = TestDataFactory.createSingpostAddress(1)[0];
            singpostAdd.Name = '99';
            
            Subscription_Vendor__c subsVen = TestDataFactory.createSubscriptionVendor(1)[0];
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Bundled';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Subscription_Period__c = '18';

            Account venAccount = TestDataFactory.createAccount(1, 'Vendor')[0];
            venAccount.AccountNumber = '12345';
                        
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.ProductFamily__c = 'BH';
            
            Gift__c gift = TestDataFactory.createGift(1)[0];
            gift.Gift_Type__c = 'Premium';
            gift.Gift_Code__c  = '1233333';
            gift.One_Time_Charge__c = 100;
            
            insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
            
            String acctNbr = [SELECT AccountNumber FROM Account WHERE Id = :vendorSubsAcct.Id][0].AccountNumber;
            System.debug('acctNbr: >>> ' + acctNbr);
            
            
            String acctNbr2 = [SELECT AccountNumber FROM Account WHERE Id = :venAccount.Id][0].AccountNumber;
            System.debug('venAccount2: >>> ' + acctNbr2);
            venAccount.AccountNumber = acctNbr2;
            
            Promotion__c promotion = TestDataFactory.createPromotion(1)[0];
            promotion.Contract_Period__c = '2';
            promotion.Effective_Start_Date__c = date.Today();
            promotion.Effective_End_Date__c = date.Today()+7;
            promotion.Promotion_Code__c = '10054';
            insert promotion;
            
            System.debug('1 promotion: ' + promotion);
            System.debug('1 promotion.Promotion_Code__c: ' + promotion.Promotion_Code__c);
            
            
            List<Gift_Letter_Batch__c> glb = new List<Gift_Letter_Batch__c>();
            Gift_Letter_Batch__c glbc = new Gift_Letter_Batch__c(
                Promo_Code__c='10054',
                Gift_Code__c='1233333',
                //Customer_Account_Number__c='',
                Customer_Account_Number__c=acctNbr2,
                Start_Date__c = date.Today(),
                End_Date__c = date.Today()+7,
                Redemption_Start_Date__c=date.Today()+4,
                Redemption_End_Date__c=date.Today()+7,
                Batch_Date__c=date.today(),
                Promotion__c = promotion.Id,
                Gift__c = gift.Id,
                Letter_Template__c='Gift Letter');
            Gift_Letter_Batch__c glbc2 = new Gift_Letter_Batch__c(
                Promo_Code__c='10054',
                Gift_Code__c='1233333',
                //Customer_Account_Number__c='',
                Customer_Account_Number__c=acctNbr2,
                Start_Date__c = date.Today(),
                End_Date__c = date.Today()+7,
                Redemption_Start_Date__c=date.Today()+4,
                Redemption_End_Date__c=date.Today()+7,
                Batch_Date__c=date.today(),
                Promotion__c = promotion.Id,
                Gift__c = gift.Id,
                Letter_Template__c='Gift Letter');
             Gift_Letter_Batch__c glbc3 = new Gift_Letter_Batch__c(
                Promo_Code__c='10054',
                Gift_Code__c='1233333',
                //Customer_Account_Number__c='',
                Customer_Account_Number__c=acctNbr2,
                Start_Date__c = date.Today(),
                End_Date__c = date.Today()+7,
                Redemption_Start_Date__c=date.Today()+4,
                Redemption_End_Date__c=date.Today()+7,
                Batch_Date__c=date.today(),
                Promotion__c = promotion.Id,
                Gift__c = gift.Id,
                Letter_Template__c='Gift Letter');

            glb.add(glbc);
            glb.add(glbc2);
            glb.add(glbc3);    
            insert glb;
                            
                          
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            //START D-4432 Gdelrosario 14.3.2016
            //Address__c add = TestDataFactory.createAddress(1)[0];
            Country__c country1 = setCountry();
            Address__c add = setAddress(singpostAdd,country1); 
            add.Postal_Code__c = singpostAdd.Id;
            add.Country__c = country1.Id;
            //END D-4432 Gdelrosario  
            
            
            Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(1)[0];
            billingAcc.Zuora__Account__c = venAccount.Id;
            billingAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            billingAcc.Billing_Type__c = 'Full Prepaid';
            
            Parcel__c par = TestDataFactory.createParcel(1)[0];
            par.Project_Name__c = pro.Id;
            par.Allocation_Type__c = 'SDA';
            par.Description__c = 'Description';
            //START D-4432 Gdelrosario : commented below line
            //insert new List<sObject>{prdRatePlan, add, billingAcc, par};
            //END D-4432 Gdelrosario : commented below line
            Product_Family__c prodFam = new Product_Family__c(Product_Family__c = 'AS');
            insert prodFam;
            
            Package_Item__c pItemBase = TestDataFactory.createPackageItem(1, 'Bundle Product')[0];
            pItemBase.Package__c = pack.Id;
            pItemBase.Product_Rate_Plan__c = prdRatePlan.Id;
            pItemBase.Duration_in_months__c = '3';
            pItemBase.Effective_Start_Month__c = '3';
            pItemBase.Product_Family__c = prodFam.Id;
            insert new List<sObject>{pItemBase};
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
           
            
            Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Bundle Discount')[0];
            pItem.Duration_in_months__c = '3';
            pItem.Effective_Start_Month__c = '3';
            pItem.Package__c = pack.Id;
            pItem.Product_Rate_Plan__c = prdRatePlan.Id;
            pItem.Base_Package_Item__c = pItemBase.Id;
            
            Vendor_Allocation__c venAlloc = TestDataFactory.createVendorAlloc(1)[0];
            venAlloc.Allocated__c = true;
            venAlloc.SingPost_Address__c = singpostAdd.Id;
            venAlloc.Vendor_Account__c = venAccount.Id;
            venAlloc.Parcel_Name__c = par.Id;
            insert new List<sObject>{prpc, pItem, venAlloc};
            
            zqu__ProductRatePlanChargeTier__c prpct = TestDataFactory.createProductRatePlanChargeTier(1)[0];
            prpct.zqu__ProductRatePlanCharge__c = prpc.Id;
            prpct.zqu__PriceFormat__c = 'Per Unit';
            prpct.zqu__Currency__c ='SGD';
            insert prpct;
                
            Publication__c publication = TestDataFactory.createPublication(1)[0];
            publication.Publication_Code__c = 'SUT';
            publication.Publication_Type__c = '2';
             publication.Published_Days__c = 'NNNYYNN';
            insert publication;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = venAccount.Id;
            con.Address__c = add.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
            //START D-4432 Gdelrosario
            Country__c countr;
            countr = TestDataFactory.createCountry(1)[0];
            countr.Code__c = 'Zz';
            database.insert(countr);
            //END D-4432 Gdelrosario
            Address__c addr = TestDataFactory.createAddress(1)[0];
            addr.Level_Number__c = '21';
            //START D-4432 Gdelrosario
            addr.Country__c = countr.Id;
            //END D-4432 Gdelrosario
            insert addr;

            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = venAccount.Id;
            order.Account__r = venAccount;
            order.Recipient_Contact__c = con.Id;
            order.Billing_Account__c = billingAcc.Id;
            order.Informed_Customer__c = True;
            order.Billing_Type__c = 'Full Prepaid';
            order.Subscriber_Charge__c = 15;
            order.DTL_Date__c = date.Today();
            order.Order_Type__c = 'Change of Subscription'; //joy
            insert order;
            system.assertNotEquals(null, order);
            
            System.debug('1 order: ' + order);
            System.debug('1 order.DTL_Date__c: ' + order.DTL_Date__c);
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            insert cas;
            
            List<Promotion_Gift__c> pgList = new List<Promotion_Gift__c>();
            for(Integer i=0;i<5;i++){
                Promotion_Gift__c pg =  new Promotion_Gift__c(
                    Gift_Inventory__c = 1000,
                    Gift_Issued__c = 200,
                    Gift_Redeemed__c = 0,
                    Gift__c = gift.id,
                    Gift__r = gift,
                    Redemption_Start_Date__c = date.Today()+4,
                    Redemption_End_Date__c = date.Today()+7,
                    Promotion__c = promotion.id,
                    Promotion__r = promotion
                );
                pgList.add(pg);
                
            }
            insert pgList;
            
            for(Promotion_Gift__c pig : pgList) {
                System.debug('1 pg: ' + pig.Gift__c);
                System.debug('2 pg: ' + pig.Gift__r.Gift_Code__c);
            }
            
            Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            oli.Order__c = order.Id;
            oli.Order__r = order;
            oli.Vendor_Subscription_ID__c = subsVen.Id;
            oli.Main_Package_ID__c = pack.Id;
            oli.Vendor_Mailing_Agent__c = venAccount.Id;
            oli.Start_Date__c = date.today()+2; //joy
            //oli.Subscription__c = zSub.Id;
            insert oli;
            
            System.debug('oli.order_Line_Item__r.Order__r.Account__r.AccountNumber: ' + oli.Order__r.Account__r.AccountNumber);
            System.debug('oli.Order_Line_Item__r.Order__r.DTL_Date__c: ' + oli.Order__r.DTL_Date__c);
            System.debug('oli.order_Line_Item__r.Order__: ' + oli.Order__c);
            
            List<Order_Line_Item_Gift__c> oligList = new List<Order_Line_Item_Gift__c>();
            for(Integer j=0;j<5;j++){
                Order_Line_Item_Gift__c olig = new Order_Line_Item_Gift__c(
                    Order_Line_Item__c = oli.id,
                    Order_Line_Item__r = oli,                    
                    Promotion_Gift__c = pgList[j].id,
                    Promotion_Gift__r = pgList[j],
                    Has_Letter_Attached__c = false
                );
                System.debug('1 olig.promotion_gift__c: ' + pgList[j].id);
                //olig.Promotion_Gift__c
                //olig.Has_Letter_Attached__c = false;
                //Order_Line_Item__r.Order__r.Account__c = venAccount
                olig.Order_Line_Item__r.Order__r = order;
                olig.Order_Line_Item__r.Order__r.Account__r.AccountNumber = acctNbr2;
                oligList.add(olig);
            }
            insert oligList;
            
            for(Order_Line_Item_Gift__c ol : oligList) {
                System.debug('==================');
                System.debug('ol.promotion_gift__r.Promotion__r.Promotion_Code__c: ' + ol.promotion_gift__r.Promotion__r.Promotion_Code__c);
                System.debug('ol.promotion_gift__r.Gift__r.Gift_Code__c: ' + ol.promotion_gift__r.Gift__r.Gift_Code__c);
                System.debug('ol.promotion_gift__c: ' + ol.promotion_gift__c);
                System.debug('ol.Has_Letter_Attached__c: ' + ol.Has_Letter_Attached__c);
                System.debug('olig.Order_Line_Item__r.Order__r.Account__r.AccountNumber: ' + ol.Order_Line_Item__r.Order__r.Account__r.AccountNumber);
                System.debug('ol: ' + ol);
                //acctNbr
            }
            

            Test.startTest();
            
            Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0]; 
            zSub.Zuora__Account__c = venAccount.Id;
            zSub.Order_Line_Item_Number__c = oli.Id;
            zSub.Order_Number__c = order.Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Sponsor__c = 'false';
            zSub.Zuora__CustomerAccount__c = billingAcc.Id;
            zSub.Recipient_Contact__c = con.Id;
            zSub.Number_of_Copies__c=100;
            zSub.Number_of_Copies1__c =  '100';
            zSub.Qty__c = 20;
            zSub.Zuora__Status__c='Cancelled';
            zSub.Zuora__SubscriptionStartDate__c=date.today();
            //zSub.Zuora__SubscriptionEndDate__c= date.today().addDays(100);
            zSub.Zuora__SubscriptionEndDate__c= null;
            zSub.Term_Length__c= 2;
            //zSub.Zuora__CustomerAccount__c = billingAcc.Id;
            insert zSub;
            
            system.debug(zSub);
            
            
            
            Map<String, sObject> valuesToParseMap = new Map<String, sObject> ();
            
           
           
            PageReference pRef = Page.CreateGiftLettersBatchPage;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('Id', glbc2.Id);
            
            CreateGiftLettersBatchController controller = new CreateGiftLettersBatchController();
            
            controller.getOrderList1();
            
            controller.giftLetterBatchList = [SELECT Id, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, 
                                   Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c 
                                   FROM Gift_Letter_Batch__c  WHERE Id =: apexpages.currentpage().getparameters().get('Id') LIMIT 1];
     
            
            for(CreateGiftLettersBatchController.OrderObj o: controller.getOrderList1()) {
                o.selected = false;
            }
            
            
            controller.generateGiftLetter();
            
            Id giftLetterBatchId = apexpages.currentpage().getparameters().get('Id');
            List<Gift_Letter_Batch__c> giftLetterBatchList = [SELECT Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c FROM Gift_Letter_Batch__c  WHERE Id =: giftLetterBatchId LIMIT 1];
            system.debug('giftLetterBatchList[0].Promotion__r.Promotion_Code__c: ' + giftLetterBatchList[0].Promotion__r.Promotion_Code__c);
            system.debug('giftLetterBatchList[0].Gift__r.Gift_Code__c: ' + giftLetterBatchList[0].Gift__r.Gift_Code__c);
            system.debug('giftLetterBatchList[0].Customer_Account_Number__c: ' + giftLetterBatchList[0].Customer_Account_Number__c);
            system.debug('giftLetterBatchList[0].Start_Date__c: ' + giftLetterBatchList[0].Start_Date__c);
            system.debug('giftLetterBatchList[0].End_Date__c: ' + giftLetterBatchList[0].End_Date__c);
            //system.debug('giftLetterBatchList[0].End_Date__c: ' + giftLetterBatchList[0].End_Date__c);
            
            system.debug('Query Start');
            System.debug('query you: ' + giftLetterBatchList);
            
            
            List<Order_Line_Item_Gift__c> oliga = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, // START-END : D-1141 2/6/2015 Alyana Navarro
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                //START:D-2180 2/13/15 Added by Manolo Valeña - Added new field to the query.
                                                Has_Letter_Attached__c
                                                //END:D-2180 2/13/15 Added by Manolo Valeña
                                                FROM Order_Line_Item_Gift__c 
                                                
                          //START:D-1022 1/13/15 Added by Manolo Valeña - Updated the Clauses to compare the Promotion Code field of the Promotion lookup and the Gift Code field of the Gift lookup.
                          WHERE order_Line_Item__r.Order__r.Account__r.AccountNumber =: giftLetterBatchList[0].Customer_Account_Number__c
                                                ORDER BY CreatedDate ASC];
            System.debug('oliga: ' + oliga.size());
            
            controller.showCustomerList();
            controller.generateGiftLetterBatch();
            //controller.previewPage();
            //controller.cancel();
            //controller.OrderObj();
            //controller.displayPreview(valuesToParseMap);
            
            System.assertNotEquals(null, controller.cancel());
            System.assertNotEquals(null, controller.displayPreview(valuesToParseMap));
            
            
            CreateGiftLettersBatchController cglb = new CreateGiftLettersBatchController();
            //cglb.giftLetterBatchId = dfhj.id;
            cglb.showListofCustomers = true;
            cglb.showLetter = true;
            cglb.orderLineItemGiftId ='sdf';
            cglb.orderLineItemGiftId = 'dsg';
            
        
             //CreateGiftLettersBatchController.OrderObj ooj = new CreateGiftLettersBatchController.OrderObj();

            Test.stopTest();
         }
      }catch(Zuora.zRemoteException e) {
      }
  }*/
  //END D-4432 Gdelrosario 
    
    static testMethod void testCreateGiftLettersBatch4(){
        //static void testCreateGiftLettersBatch(){
    
     try {
        Test.setMock(WebServiceMock.class, new zLoginMock());
    
        User testUser = setUser();
        
        System.runAs(testUser) {
            setUpCustomSetData();

            Project__c pro = setPro();                        
            Account vendorSubsAcct = setVendorSubsAcct();            
            Singpost_Address__c singpostAdd = setSingpostAdd();            
            Subscription_Vendor__c subsVen = setSubsVen();            
            Package__c pack = setPack();           
            Account venAccount = setVenAccount();            
            zqu__ZProduct__c zProduct = setZProduct();            
            Gift__c gift = setGift();
            //insert new List<sObject>{pro, vendorSubsAcct, singpostAdd, subsVen, pack, venAccount, zProduct, gift};
            String acctNbr = [SELECT AccountNumber FROM Account WHERE Id = :vendorSubsAcct.Id][0].AccountNumber;
            
            String acctNbr2 = [SELECT AccountNumber FROM Account WHERE Id = :venAccount.Id][0].AccountNumber;
            System.debug('venAccount2: >>> ' + acctNbr2);
            
            Promotion__c promotion = setPromotion();
            
            List<Gift_Letter_Batch__c> glb = new List<Gift_Letter_Batch__c>();
            
            Gift_Letter_Batch__c glbc = setGlbc(acctNbr2, promotion, gift);
            insert glbc;
                                 
            zqu__ProductRatePlan__c prdRatePlan = setPrdRatePlan(zProduct);
            //START D-4432 Gdelrosario 14.3.2016
            Country__c country1 = setCountry();
            Address__c add = setAddress(singpostAdd,country1);    
            //END D-4432 Gdelrosario  
           
            Zuora__CustomerAccount__c billingAcc = setBillingAcc(venAccount);            
            Parcel__c par = setParcel(pro);

            //insert new List<sObject>{prdRatePlan, add, billingAcc, par/*, psorm*/};            
            Product_Family__c prodFam = setProdFam();            
            Package_Item__c pItemBase = setPackItemBase(pack, prdRatePlan, prodFam);            
            //insert new List<sObject>{pItemBase};
            
            zqu__ProductRatePlanCharge__c prpc = setProductRatePlanCharge(prdRatePlan);
            Package_Item__c pItem = setPackItem(prdRatePlan, pItemBase, pack);            
            Vendor_Allocation__c venAlloc = setVenAlloc(singpostAdd, venAccount, par);
            
            //insert new List<sObject>{prpc, pItem, venAlloc};            
            zqu__ProductRatePlanChargeTier__c prpct = setProdRatePlanCharTier(prpc);                
            Publication__c publication = setPublication();            
            Contact con = setCon(venAccount, add);  
            //START D-4432 Gdelrosario 14.3.2016          
            Address__c addr = setAddress(country1);
            //START D-4432 Gdelrosario 14.3.2016
            Order__c order = setOrder(venAccount, con, billingAcc, false) ;
            system.assertNotEquals(null, order);            
            Case cas = setCase(order);
            
            List<Promotion_Gift__c> pgList = new List<Promotion_Gift__c>();
            for(Integer i=0;i<5;i++){ //i < 200
                Promotion_Gift__c pg =  setPromoGift(gift, promotion);                
                pgList.add(pg);
            }
            insert pgList;
            
            Order_Line_Item__c oli = setOrderLineItem(order, subsVen, pack, venAccount);

            List<Order_Line_Item_Gift__c> oligList = new List<Order_Line_Item_Gift__c>();
            for(Integer j=0;j<5;j++){ //i < 200
                Order_Line_Item_Gift__c olig = setOrderLineItemGift(oli, pgList, j);
                oligList.add(olig);
            }
            insert oligList;
            
            Test.startTest();
            
            Zuora__Subscription__c zSub = setZSub(venAccount, oli, order, con, billingAcc);
            system.debug(zSub);
            
            Map<String, sObject> valuesToParseMap = new Map<String, sObject> ();
            
            
           
            PageReference pRef = Page.CreateGiftLettersBatchPage;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('Id', glbc.Id);
            CreateGiftLettersBatchController controller = new CreateGiftLettersBatchController();
            controller.giftLetterBatchList = [SELECT Id, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, 
                                   Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c 
                                   FROM Gift_Letter_Batch__c  WHERE Id =: apexpages.currentpage().getparameters().get('Id') LIMIT 1];
     
            
            for(CreateGiftLettersBatchController.OrderObj o: controller.getOrderList1()) {
                o.selected = true;
            }
            //controller.generateGiftLetter();
            controller.previewPage();
            controller.showCustomerList();
            controller.generateGiftLetterBatch();            
            System.assertNotEquals(null, controller.cancel());
            System.assertNotEquals(null, controller.displayPreview(valuesToParseMap));
            
            Test.stopTest();
          }
          }catch(Zuora.zRemoteException e) {
          }
  }
    
    static testMethod void newTest(){
        
    
     
    
        User testUser = setUser();
        
        System.runAs(testUser) {
            setUpCustomSetData();

            Project__c pro = setPro();                        
            Account vendorSubsAcct = setVendorSubsAcct();            
            Singpost_Address__c singpostAdd = setSingpostAdd();            
            Subscription_Vendor__c subsVen = setSubsVen();            
            Package__c pack = setPack();           
            Account venAccount = setVenAccount();            
            zqu__ZProduct__c zProduct = setZProduct();            
            Gift__c gift = setGift();
            
            String acctNbr = [SELECT AccountNumber FROM Account WHERE Id = :vendorSubsAcct.Id][0].AccountNumber;
            
            String acctNbr2 = [SELECT AccountNumber FROM Account WHERE Id = :venAccount.Id][0].AccountNumber;
            System.debug('venAccount2: >>> ' + acctNbr2);
            
            Promotion__c promotion = setPromotion();
            
            List<Gift_Letter_Batch__c> glb = new List<Gift_Letter_Batch__c>();
            
            Gift_Letter_Batch__c glbc = setGlbc(acctNbr2, promotion, gift);
            glbc.Customer_Account_Number__c = null;
            insert glbc;
                                 
            zqu__ProductRatePlan__c prdRatePlan = setPrdRatePlan(zProduct);
            //START D-4432 Gdelrosario 14.3.2016
            Country__c country1 = setCountry();
            Address__c add = setAddress(singpostAdd,country1);    
            //END D-4432 Gdelrosario  
           
            Zuora__CustomerAccount__c billingAcc = setBillingAcc(venAccount);            
            Parcel__c par = setParcel(pro);

            //insert new List<sObject>{prdRatePlan, add, billingAcc, par/*, psorm*/};            
            Product_Family__c prodFam = setProdFam();            
            Package_Item__c pItemBase = setPackItemBase(pack, prdRatePlan, prodFam);            
            //insert new List<sObject>{pItemBase};
            
            zqu__ProductRatePlanCharge__c prpc = setProductRatePlanCharge(prdRatePlan);
            Package_Item__c pItem = setPackItem(prdRatePlan, pItemBase, pack);            
            Vendor_Allocation__c venAlloc = setVenAlloc(singpostAdd, venAccount, par);
            
            //insert new List<sObject>{prpc, pItem, venAlloc};            
            zqu__ProductRatePlanChargeTier__c prpct = setProdRatePlanCharTier(prpc);                
            Publication__c publication = setPublication();            
            Contact con = setCon(venAccount, add);    
            //START D-4432 Gdelrosario 14.3.2016        
            Address__c addr = setAddress(country1);
            //END  D-4432 Gdelrosario 14.3.2016
            Order__c order = setOrder(venAccount, con, billingAcc, false) ;
            system.assertNotEquals(null, order);            
            Case cas = setCase(order);
            
            List<Promotion_Gift__c> pgList = new List<Promotion_Gift__c>();
            for(Integer i=0;i<5;i++){ //i < 200
                Promotion_Gift__c pg =  setPromoGift(gift, promotion);                
                pgList.add(pg);
            }
            insert pgList;
            
            Order_Line_Item__c oli = setOrderLineItem(order, subsVen, pack, venAccount);

            List<Order_Line_Item_Gift__c> oligList = new List<Order_Line_Item_Gift__c>();
            for(Integer j=0;j<5;j++){ //i < 200
                Order_Line_Item_Gift__c olig = setOrderLineItemGift(oli, pgList, j);
                oligList.add(olig);
            }
            insert oligList;
            
            Test.startTest();
            
            Zuora__Subscription__c zSub = setZSub(venAccount, oli, order, con, billingAcc);
            system.debug(zSub);
            
            Map<String, sObject> valuesToParseMap = new Map<String, sObject> ();
            
            
           
            PageReference pRef = Page.CreateGiftLettersBatchPage;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('Id', glbc.Id);
            CreateGiftLettersBatchController controller = new CreateGiftLettersBatchController();
            controller.giftLetterBatchList = [SELECT Id, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, 
                                   Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c 
                                   FROM Gift_Letter_Batch__c  WHERE Id =: apexpages.currentpage().getparameters().get('Id') LIMIT 1];
     
            
            for(CreateGiftLettersBatchController.OrderObj o: controller.getOrderList1()) {
                o.selected = true;
            }
            controller.generateGiftLetter();
            
            Id giftLetterBatchId = apexpages.currentpage().getparameters().get('Id');
            List<Gift_Letter_Batch__c> giftLetterBatchList = [SELECT Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c FROM Gift_Letter_Batch__c  WHERE Id =: giftLetterBatchId LIMIT 1];
            system.debug('2giftLetterBatchList[0].Promotion__r.Promotion_Code__c: ' + giftLetterBatchList[0].Promotion__r.Promotion_Code__c);
            system.debug('2giftLetterBatchList[0].Gift__r.Gift_Code__c: ' + giftLetterBatchList[0].Gift__r.Gift_Code__c);
            system.debug('2giftLetterBatchList[0].Customer_Account_Number__c: ' + giftLetterBatchList[0].Customer_Account_Number__c);
            system.debug('2giftLetterBatchList[0].Start_Date__c: ' + giftLetterBatchList[0].Start_Date__c);
            system.debug('2giftLetterBatchList[0].End_Date__c: ' + giftLetterBatchList[0].End_Date__c);
            
            
            system.debug('2Query Start');
            System.debug('2query you: ' + giftLetterBatchList);
            
            
            List<Order_Line_Item_Gift__c> oliga = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE order_Line_Item__r.Order__r.Account__r.AccountNumber =: giftLetterBatchList[0].Customer_Account_Number__c
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga AccountNumber: ' + oliga.size());
            System.debug('2oliga AccountNumber: ' + oliga);
            
            
            List<Order_Line_Item_Gift__c> oliga2 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE promotion_gift__r.Promotion__r.Promotion_Code__c =: giftLetterBatchList[0].Promotion__r.Promotion_Code__c
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga Promotion_Code__c: ' + oliga2.size());
            System.debug('2oliga Promotion_Code__c: ' + oliga2);
            
            List<Order_Line_Item_Gift__c> oliga3 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE promotion_gift__r.Gift__r.Gift_Code__c =: giftLetterBatchList[0].Gift__r.Gift_Code__c
                                                
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga Gift_Code__c: ' + oliga3.size());
            System.debug('2oliga Gift_Code__c: ' + oliga3);
            
            List<Order_Line_Item_Gift__c> oliga4 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE Order_Line_Item__r.Order__r.DTL_Date__c >=: giftLetterBatchList[0].Start_Date__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c <=: giftLetterBatchList[0].End_Date__c
                                                
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga DTL_Date__c: ' + oliga4.size());
            System.debug('2oliga DTL_Date__c: ' + oliga4);
                                                                            
           List<Order_Line_Item_Gift__c> oliga5 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE Has_Letter_Attached__c = false
                                                
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga Has_Letter_Attached__c: ' + oliga5.size());
            System.debug('2oliga Has_Letter_Attached__c: ' + oliga5);
            
            
            List<Order_Line_Item_Gift__c> oliga6 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE promotion_gift__r.Promotion__r.Promotion_Code__c =: giftLetterBatchList[0].Promotion__r.Promotion_Code__c
                          AND promotion_gift__r.Gift__r.Gift_Code__c =: giftLetterBatchList[0].Gift__r.Gift_Code__c
                                                
                          
                          AND order_Line_Item__r.Order__r.Account__r.AccountNumber =: giftLetterBatchList[0].Customer_Account_Number__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c >=: giftLetterBatchList[0].Start_Date__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c <=: giftLetterBatchList[0].End_Date__c
                                                
                                                AND Has_Letter_Attached__c = false
                                                
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga all: ' + oliga6.size());
            System.debug('2oliga all: ' + oliga6);

            controller.showCustomerList();
            controller.generateGiftLetterBatch();
            System.assertNotEquals(null, controller.cancel());
            System.assertNotEquals(null, controller.displayPreview(valuesToParseMap));
            
            Test.stopTest();
          }
  }  
    
    static testMethod void newTest2(){
        
    
     
    
        User testUser = setUser();
        
        System.runAs(testUser) {
            setUpCustomSetData();
    
            Project__c pro = setPro();  
                                  
            Account vendorSubsAcct = setVendorSubsAcct();            
            Singpost_Address__c singpostAdd = setSingpostAdd();            
            Subscription_Vendor__c subsVen = setSubsVen();            
            Package__c pack = setPack();           
            Account venAccount = setVenAccount();            
            zqu__ZProduct__c zquzProd2 = setzquZprod(); 
            zqu__ProductRatePlan__c prdRatePlan2 = setzquProdratePlan(zquzProd2);          
            Gift__c gift = setGift();
            
            
            String acctNbr = [SELECT AccountNumber FROM Account WHERE Id = :vendorSubsAcct.Id][0].AccountNumber;
            
            String acctNbr2 = [SELECT AccountNumber FROM Account WHERE Id = :venAccount.Id][0].AccountNumber;
            System.debug('venAccount2: >>> ' + acctNbr2);
            
            Promotion__c promotion = setPromotion();
            
            List<Gift_Letter_Batch__c> glb = new List<Gift_Letter_Batch__c>();
            
            Gift_Letter_Batch__c glbc = setGlbc(acctNbr2, promotion, gift);
            insert glbc;
                                 
            
            //START D-4432 Gdelrosario 14.3.2016
            Country__c country1 = setCountry();
            Address__c add = setAddress(singpostAdd,country1);    
            //END D-4432 Gdelrosario  
          
            Zuora__CustomerAccount__c billingAcc = setBillingAcc(venAccount);            
            Parcel__c par = setParcel(pro);

            //insert new List<sObject>{prdRatePlan, add, billingAcc, par/*, psorm*/};            
            Product_Family__c prodFam = setProdFam();            
            Package_Item__c pItemBase = setPackItemBase(pack, prdRatePlan2, prodFam);            
            //insert new List<sObject>{pItemBase};
            
            //zqu__ProductRatePlanCharge__c prpc2 = setProductRatePlanCharge(prdRatePlan2);
            Package_Item__c pItem = setPackItem(prdRatePlan2, pItemBase, pack);            
            Vendor_Allocation__c venAlloc = setVenAlloc(singpostAdd, venAccount, par);
            
            //insert new List<sObject>{prpc, pItem, venAlloc};            
                           
            Publication__c publication = setPublication();            
            Contact con = setCon2(venAccount, add);    
            //START D-4432 Gdelrosario 14.3.2016 
            Address__c addr = setAddress(country1);
            //END  D-4432 Gdelrosario 14.3.2016
            Order__c order2 = setOrder2(venAccount, con, billingAcc, false) ;
            system.assertNotEquals(null, order2);            
            Case cas = setCase(order2);
            
            List<Promotion_Gift__c> pgList = new List<Promotion_Gift__c>();
            for(Integer i=0;i<5;i++){ //i < 200
                Promotion_Gift__c pg =  setPromoGift(gift, promotion);                
                pgList.add(pg);
            }
            insert pgList;
            
            
            
            Test.startTest();
            
            Zuora__Subscription__c zSub2 = setZSub2(venAccount, order2, con, billingAcc);
            system.debug(zSub2);
            
            Order_Line_Item__c oli = setOrderLineItem2(zSub2, order2, subsVen, pack, venAccount);
            
            
            
             
            //zqu__ProductRatePlanChargeTier__c prpct = setProdRatePlanCharTier(prpc2); 
            List<Order_Line_Item_Gift__c> oligList = new List<Order_Line_Item_Gift__c>();
            for(Integer j=0;j<5;j++){ //i < 200
                Order_Line_Item_Gift__c olig = setOrderLineItemGift(oli, pgList, j);
                oligList.add(olig);
            }
            insert oligList;
            
            Map<String, sObject> valuesToParseMap = new Map<String, sObject> ();
            
            Zuora__SubscriptionProductCharge__c zSubProdCharge = setzSubProdCharge(zSub2);
            zqu__ProductRatePlanCharge__c prpc2 = setzquProdratePlanCharge(prdRatePlan2);
            
            PageReference pRef = Page.CreateGiftLettersBatchPage;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('Id', glbc.Id);
            CreateGiftLettersBatchController controller = new CreateGiftLettersBatchController();
            controller.giftLetterBatchList = [SELECT Id, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, 
                                   Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c 
                                   FROM Gift_Letter_Batch__c  WHERE Id =: apexpages.currentpage().getparameters().get('Id') LIMIT 1];
     
            
            for(CreateGiftLettersBatchController.OrderObj o: controller.getOrderList1()) {
                o.selected = true;
            }
            controller.generateGiftLetter();
            
            Id giftLetterBatchId = apexpages.currentpage().getparameters().get('Id');
            List<Gift_Letter_Batch__c> giftLetterBatchList = [SELECT Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c, Customer_Account_Number__c, Redemption_Start_Date__c, Redemption_End_Date__c, Letter_Template__c, Start_Date__c, End_Date__c, Gift_Code__c, Promo_Code__c FROM Gift_Letter_Batch__c  WHERE Id =: giftLetterBatchId LIMIT 1];
            system.debug('2giftLetterBatchList[0].Promotion__r.Promotion_Code__c: ' + giftLetterBatchList[0].Promotion__r.Promotion_Code__c);
            system.debug('2giftLetterBatchList[0].Gift__r.Gift_Code__c: ' + giftLetterBatchList[0].Gift__r.Gift_Code__c);
            system.debug('2giftLetterBatchList[0].Customer_Account_Number__c: ' + giftLetterBatchList[0].Customer_Account_Number__c);
            system.debug('2giftLetterBatchList[0].Start_Date__c: ' + giftLetterBatchList[0].Start_Date__c);
            system.debug('2giftLetterBatchList[0].End_Date__c: ' + giftLetterBatchList[0].End_Date__c);
            
            
            system.debug('2Query Start');
            System.debug('2query you: ' + giftLetterBatchList);
            
            
            List<Order_Line_Item_Gift__c> oliga = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE order_Line_Item__r.Order__r.Account__r.AccountNumber =: giftLetterBatchList[0].Customer_Account_Number__c
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga AccountNumber: ' + oliga.size());
            System.debug('2oliga AccountNumber: ' + oliga);
            
            
            List<Order_Line_Item_Gift__c> oliga2 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE promotion_gift__r.Promotion__r.Promotion_Code__c =: giftLetterBatchList[0].Promotion__r.Promotion_Code__c
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga Promotion_Code__c: ' + oliga2.size());
            System.debug('2oliga Promotion_Code__c: ' + oliga2);
            
            List<Order_Line_Item_Gift__c> oliga3 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE promotion_gift__r.Gift__r.Gift_Code__c =: giftLetterBatchList[0].Gift__r.Gift_Code__c
                                                
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga Gift_Code__c: ' + oliga3.size());
            System.debug('2oliga Gift_Code__c: ' + oliga3);
            
            List<Order_Line_Item_Gift__c> oliga4 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE Order_Line_Item__r.Order__r.DTL_Date__c >=: giftLetterBatchList[0].Start_Date__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c <=: giftLetterBatchList[0].End_Date__c
                                                
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga DTL_Date__c: ' + oliga4.size());
            System.debug('2oliga DTL_Date__c: ' + oliga4);
                                                                            
           List<Order_Line_Item_Gift__c> oliga5 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE Has_Letter_Attached__c = false
                                                
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga Has_Letter_Attached__c: ' + oliga5.size());
            System.debug('2oliga Has_Letter_Attached__c: ' + oliga5);
            
            
            List<Order_Line_Item_Gift__c> oliga6 = [SELECT Name, Promotion_Gift__c, Order_Line_Item__r.Order__r.Account__r.Name, 
                                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                                Account_Record_Type_Hidden__c, CreatedDate, 
                                                Gift_Letter_Batch_Id__c, 
                                                Order_Line_Item__r.Main_Package_ID__r.Id, Promotion_Gift__r.Id,
                                                promotion_gift__r.Promotion__r.Effective_Start_Date__c, promotion_gift__r.Promotion__r.Effective_End_Date__c,
                                                promotion_gift__r.Redemption_Start_Date__c, promotion_gift__r.Redemption_End_Date__c,
                                                
                                                Has_Letter_Attached__c
                                                
                                                FROM Order_Line_Item_Gift__c 
                                                
                          
                          WHERE promotion_gift__r.Promotion__r.Promotion_Code__c =: giftLetterBatchList[0].Promotion__r.Promotion_Code__c
                          AND promotion_gift__r.Gift__r.Gift_Code__c =: giftLetterBatchList[0].Gift__r.Gift_Code__c
                                                
                          
                          AND order_Line_Item__r.Order__r.Account__r.AccountNumber =: giftLetterBatchList[0].Customer_Account_Number__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c >=: giftLetterBatchList[0].Start_Date__c
                                                AND Order_Line_Item__r.Order__r.DTL_Date__c <=: giftLetterBatchList[0].End_Date__c
                                                
                                                AND Has_Letter_Attached__c = false
                                                
                                                ORDER BY CreatedDate ASC];
            System.debug('2oliga all: ' + oliga6.size());
            System.debug('2oliga all: ' + oliga6);

            controller.showCustomerList();
            controller.generateGiftLetterBatch();
            System.assertNotEquals(null, controller.cancel());
            System.assertNotEquals(null, controller.displayPreview(valuesToParseMap));
            
            Test.stopTest();
          }
  }  
}