/**
   @Author Kirk Yngwie Enriquez
   @name LP_HappyCallLetterChineseControllerTest
   @CreateDate 06/29/2015
   @Description To test LP_HappyCallLetterChineseController class
   @Version <1.0>
  */

@isTest(SeeAllData=true)
private class LP_HappyCallLetterChineseControllerTest{
    
    static testmethod void testLP_HappyCallLetterChineseControllerBase(){
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct SPH-Interdivision');
        insert accounts;
        
      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Grace Period';
            packagee.Subscription_Period__c = '1';
            packagee.Subscription_Type__c = 'Termed';
            
        }
        insert packages;
        
      //Country__c
        List<Country__c> countries = TestDataFactory.createCountry(1);
        insert countries;
        
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
            
        }
        insert postalAddresses;  
        
        SPH_Section__c sphSection = new SPH_Section__c();
        //sphSection.Section_Code__c = 'testSection';
        sphSection.Section_Name__c = 'testName';
        insert sphSection;
        
        SPH_Department__c sphDept = new SPH_Department__c();
        sphDept.Department_Name__c = 'testName';
        insert sphDept;
        
        SPH_Division__c sphDivision = new SPH_Division__c();
        sphDivision.Name = 'testName';      
        insert sphDivision;
        
        SPH_Company__c sphCompany = new SPH_Company__c();
        sphCompany.Company_Name__c = 'testName';
        insert sphCompany;
        
        SPH_Location__c sphLocation = new SPH_Location__c();
        sphLocation.Location_Name__c = 'testName';
        insert sphLocation;
        
       
        
      //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
            address.Country__c = countries[count].id;
            address.Block_House_Number__c = '21B';
            address.Level_Number__c = '123';
            address.Unit_Number__c = '19';
            address.Postal_Code__c = postalAddresses[0].id;
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Internal');
            address.Postal_Code__c = postalAddresses[0].id;
            address.Section_Code__c = sphSection.Id;
            address.Department__c = sphDept.Id;
            address.Division_Code__c = sphDivision.Id;
            address.Company_Code__c = sphCompany.Id;
            address.Location_Code__c = sphLocation.Id;
        }
        insert addresses;  
        
      //Contact
        List<Contact> contacts = TestDataFactory.createContact(1);
        count = 0;
        for(Contact contact: contacts){
            contact.Address__c = addresses[count].id;
            contact.AccountId = accounts[count].id;
            contact.Recipient_Indicator__c = true;
            contact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');

        }
        insert contacts;  

        // billing account
        Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
        billAcct.Zuora__Account__c = accounts[0].Id;
        billAcct.Billing_Contact__c = contacts[0].Id;
        billAcct.Zuora__Zuora_Id__c = 'Test1';
        billAcct.Billing_Type__c = 'Full Prepaid';
        billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcct.Zuora__AccountNumber__c = 'Test1';
        
        insert billAcct;        
        
      //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(1);
        count = 0;
        for(Order__c ord: orders){
            ord.Account__c = accounts[count].id;
            ord.Recipient_Contact__c = contacts[count].id;
        }
        insert orders;

      //Order_Line_Item__c
        List<Order_Line_Item__c> orderLineItems = TestDataFactory.createOrderLineItem(1);
        count = 0;
        for (Order_Line_Item__c oli : orderLineItems) {
            oli.Order__c = orders[count].id; 
            oli.Main_Package_ID__c = packages[count].id;
            oli.Start_Date__c = date.today()+1;
        }        
        insert orderLineItems;
      
      //Promotion__c
        List<Promotion__c> promotions = TestDataFactory.createPromotion(1);
        for(Promotion__c promotion: promotions){
            promotion.Contract_Period__c = '36';
        }
        insert promotions;  
        
      //Promotion_Gift__c
        List<Promotion_Gift__c> promotionGifts = TestDataFactory.createPromotionGift(1);
        count = 0;
        for(Promotion_Gift__c promotionGift: promotionGifts){
            promotionGift.Promotion__c = promotions[count].id;
        }
        insert promotionGifts;        

        //Gift__c
        List<Gift__c> gifts = TestDataFactory.createGift(1);
        insert gifts;        
        
        Gift_Letter_Batch__c giftLetterBatch = new Gift_Letter_Batch__c();
        /*
        giftLetterBatch.Redemption_Venue__c = 'Sample';
        giftLetterBatch.Customer_Account_Number__c = '1';
        giftLetterBatch.Redemption_End_Date__c = Date.today().addDays(60);
        giftLetterBatch.Redemption_Start_Date__c = Date.today().addDays(1);
        */
        giftLetterBatch.Redemption_Venue__c = 'Funan DigitaLife Mall: #03-32, 109 North Bridge Road, Singapore 179097 Tel: 6837 8186';
        giftLetterBatch.Letter_Template__c = 'Premium (Chi)';
        giftLetterBatch.Promo_Chinese_Name__c = 'Sample Chinese Name';
        giftLetterBatch.Start_Date__c = Date.today().addDays(1);
        giftLetterBatch.End_Date__c = Date.today().addDays(30);
        giftLetterBatch.Promotion__c = promotions[0].id;
        giftLetterBatch.Gift__c = gifts[0].id;
        insert giftLetterBatch;        
        
      //Order_Line_Item_Gift__c
        List<Order_Line_Item_Gift__c> orderLineItemGifts = TestDataFactory.createItemGift(1);
        count=0;        
        for (Order_Line_Item_Gift__c olig : orderLineItemGifts) {
            olig.Order_Line_Item__c = orderLineItems[count].id;
            olig.Promotion_Gift__c = promotionGifts[count].id;
            olig.Gift_Letter_Batch_Id__c = giftLetterBatch.id;
            count++;            
        }      
        insert orderLineItemGifts;  
        
      //Gift_Letter_Batch__c
        /*Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c, Promo_Chinese_Name__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];*/

        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Zuora__Account__c = accounts[0].Id;
            zSub.Order_Line_Item_Number__c = orderLineItems[0].Id;
            zSub.Subscriber_Contact__c = contacts[0].Id;
            zSub.Recipient_Contact__c = contacts[0].Id;
            zSub.Main_Package_1__c = packages[0].Id;
            zSub.Main_Package__c = packages[0].Id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = orders[0].Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Zuora__SubscriptionEndDate__c= date.today().addDays(30);
            zSub.Zuora__SubscriptionStartDate__c = date.today();
            zSub.Zuora__CustomerAccount__c = billAcct.Id;
            zsub.Contact__c = contacts[0].id;
            insert zSub;
        
      //zqu__ZProduct__c
        List<zqu__ZProduct__c> products = TestDataFactory.createZProduct(1);
        insert products; 
        
      //Product_Rate_Plan__c
        List<zqu__ProductRatePlan__c> productPlans = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c productPlan: productPlans){
            productPlan.RatePlanType__c = 'Proration';
            productPlan.zqu__ZProduct__c = products[0].id;
        }
        insert productPlans;
        
      //Product_Family__c
        Product_Family__c productFamily = new Product_Family__c();
        productFamily.Product_Family__c = 'Sample Product Family';
        insert productFamily;
        
      //Package_Item__c 
        List<Package_Item__c > packageItems = TestDataFactory.createPackageItem(1, 'Base Product' );
        for(Package_Item__c packageItem: packageItems){
            packageItem.Package__c = packages[0].id;
            packageItem.Product_Rate_Plan__c = productPlans[0].id;
            packageItem.Product_Family__c = productFamily.id;
        }
        insert packageItems;

        PageReference pgRef = Page.LP_HappyCallLetterChinese;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterChineseController lp = new LP_HappyCallLetterChineseController();
    }
    
    static testmethod void testLP_HappyCallLetterChineseControllerBundle2(){
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert accounts;
        
      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Bundle';
            packagee.Subscription_Period__c = '1';
            packagee.Subscription_Type__c = 'Termed';
            
        }
        insert packages;
        
      //Country__c
        List<Country__c> countries = TestDataFactory.createCountry(1);
        insert countries;
        
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;   
        
      //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
            address.Country__c = countries[count].id;
            address.Block_House_Number__c = '21B';
            address.Level_Number__c = '123';
            address.Unit_Number__c = '19';
            address.Postal_Code__c = postalAddresses[0].id;
        }
        insert addresses;  
        
      //Contact
        List<Contact> contacts = TestDataFactory.createContact(1);
        count = 0;
        for(Contact contact: contacts){
            contact.Address__c = addresses[count].id;
            contact.AccountId = accounts[count].id;
            contact.Recipient_Indicator__c = true;
        }
        insert contacts;  

        // billing account
        Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
        billAcct.Zuora__Account__c = accounts[0].Id;
        billAcct.Billing_Contact__c = contacts[0].Id;
        billAcct.Zuora__Zuora_Id__c = 'Test1';
        billAcct.Billing_Type__c = 'Full Prepaid';
        billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcct.Zuora__AccountNumber__c = 'Test1';
        
        insert billAcct;            
        
      //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(1);
        count = 0;
        for(Order__c ord: orders){
            ord.Account__c = accounts[count].id;
            ord.Recipient_Contact__c = contacts[count].id;
        }
        insert orders;

      //Order_Line_Item__c
        List<Order_Line_Item__c> orderLineItems = TestDataFactory.createOrderLineItem(1);
        count = 0;
        for (Order_Line_Item__c oli : orderLineItems) {
            oli.Order__c = orders[count].id; 
            oli.Main_Package_ID__c = packages[count].id;
            oli.Start_Date__c = date.today()+1;
        }        
        insert orderLineItems;
      
      //Promotion__c
        List<Promotion__c> promotions = TestDataFactory.createPromotion(1);
        for(Promotion__c promotion: promotions){
            promotion.Contract_Period__c = '36';
        }
        insert promotions;  
        
      //Promotion_Gift__c
        List<Promotion_Gift__c> promotionGifts = TestDataFactory.createPromotionGift(1);
        count = 0;
        for(Promotion_Gift__c promotionGift: promotionGifts){
            promotionGift.Promotion__c = promotions[count].id;
        }
        insert promotionGifts;        
    
      //Order_Line_Item_Gift__c
        List<Order_Line_Item_Gift__c> orderLineItemGifts = TestDataFactory.createItemGift(1);
        count=0;        
        for (Order_Line_Item_Gift__c olig : orderLineItemGifts) {
            olig.Order_Line_Item__c = orderLineItems[count].id;
            olig.Promotion_Gift__c = promotionGifts[count].id;
            count++;            
        }      
        insert orderLineItemGifts;  
        
      //Gift__c
        List<Gift__c> gifts = TestDataFactory.createGift(1);
        insert gifts;
        
      //Gift_Letter_Batch__c
        /*Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c, Promo_Chinese_Name__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];*/
                                                   
        Gift_Letter_Batch__c giftLetterBatch = new Gift_Letter_Batch__c();
        giftLetterBatch.Redemption_Venue__c = 'Funan DigitaLife Mall: #03-32, 109 North Bridge Road, Singapore 179097 Tel: 6837 8186';
        giftLetterBatch.Redemption_End_Date__c = Date.today().addDays(30);
        giftLetterBatch.Promo_Chinese_Name__c = 'Sample Chinese Name';
        giftLetterBatch.Letter_Template__c = 'Premium (Chi)';
        giftLetterBatch.Start_Date__c = Date.today().addDays(1);
        giftLetterBatch.End_Date__c = Date.today().addDays(30);
        giftLetterBatch.Promotion__c = promotions[0].id;
        giftLetterBatch.Gift__c = gifts[0].id;
        insert giftLetterBatch;

        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Zuora__Account__c = accounts[0].Id;
            zSub.Order_Line_Item_Number__c = orderLineItems[0].Id;
            zSub.Subscriber_Contact__c = contacts[0].Id;
            zSub.Recipient_Contact__c = contacts[0].Id;
            zSub.Main_Package_1__c = packages[0].Id;
            zSub.Main_Package__c = packages[0].Id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = orders[0].Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Zuora__SubscriptionEndDate__c= date.today().addDays(30);
            zSub.Zuora__SubscriptionStartDate__c = date.today();
            zSub.Zuora__CustomerAccount__c = billAcct.Id;
            zsub.Contact__c = contacts[0].id;
            insert zSub;
        
      //zqu__ZProduct__c
        List<zqu__ZProduct__c> products = TestDataFactory.createZProduct(1);
        insert products; 
        
      //Product_Rate_Plan__c
        List<zqu__ProductRatePlan__c> productPlans = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c productPlan: productPlans){
            productPlan.RatePlanType__c = 'Bill Plan';
            productPlan.zqu__ZProduct__c = products[0].id;
        }
        insert productPlans;
        
      //Product_Family__c
        Product_Family__c productFamily = new Product_Family__c();
        productFamily.Product_Family__c = 'Sample Product Family';
        insert productFamily;
        
      //Package_Item__c 
        List<Package_Item__c > packageItems = TestDataFactory.createPackageItem(2, 'Bundle Product' );
        for(Package_Item__c packageItem: packageItems){
            packageItem.Package__c = packages[0].id;
            packageItem.Product_Rate_Plan__c = productPlans[0].id;
            packageItem.Product_Family__c = productFamily.id;
        }
        //insert packageItems;

        PageReference pgRef = Page.LP_HappyCallLetterChinese;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterChineseController lp = new LP_HappyCallLetterChineseController();
    }
    
    static testmethod void testLP_HappyCallLetterChineseControllerBundle1(){
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert accounts;
        
       RecordType bundlerecordtype = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Bundle_Product' LIMIT 1]; 
       System.debug('gddr >>>  ::' +  bundlerecordtype.Id);

      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Bundle';
            packagee.Subscription_Period__c = '1';
            packagee.Subscription_Type__c = 'Termed';
           
        }
        insert packages;
        
      //Country__c
        List<Country__c> countries = TestDataFactory.createCountry(1);
        countries[0].Country_Name__c = 'Singapore';
        insert countries;
        
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;  
                        
        
        
      //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
            address.Country__c = countries[0].id;
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
            address.Block_House_Number__c = '21B';
            address.Level_Number__c = '123';
            address.Unit_Number__c = '19';
            address.Postal_Code__c = postalAddresses[0].id;            
            address.Address_1__c = 'add1';   
            address.Address_2__c = 'add2';
            address.Address_3__c = 'add3';
            address.Address_4__c = 'add4'; 
                  
        }
        insert addresses;  
        
      //Contact
        List<Contact> contacts = TestDataFactory.createContact(1);
        for(Contact contact: contacts){
            contact.Address__c = addresses[0].id;
            contact.AccountId = accounts[0].id;
            contact.Recipient_Indicator__c = true;
            contact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        }
        insert contacts;  

        // billing account
        Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
        billAcct.Zuora__Account__c = accounts[0].Id;
        billAcct.Billing_Contact__c = contacts[0].Id;
        billAcct.Zuora__Zuora_Id__c = 'Test1';
        billAcct.Billing_Type__c = 'Full Prepaid';
        billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcct.Zuora__AccountNumber__c = 'Test1';
        
        insert billAcct;          
        
      //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord: orders){
            ord.Account__c = accounts[0].id;
            ord.Recipient_Contact__c = contacts[0].id;
        }
        insert orders;

      //Order_Line_Item__c
        List<Order_Line_Item__c> orderLineItems = TestDataFactory.createOrderLineItem(1);
        count = 0;
        for (Order_Line_Item__c oli : orderLineItems) {
            oli.Order__c = orders[count].id; 
            oli.Main_Package_ID__c = packages[count].id;
            oli.Start_Date__c = date.today()+1;
            
        }        
        insert orderLineItems;
      
      //Promotion__c
        List<Promotion__c> promotions = TestDataFactory.createPromotion(1);
        for(Promotion__c promotion: promotions){
            promotion.Contract_Period__c = '36';
        }
        insert promotions;  
        
      //Promotion_Gift__c
        List<Promotion_Gift__c> promotionGifts = TestDataFactory.createPromotionGift(1);
        count = 0;
        for(Promotion_Gift__c promotionGift: promotionGifts){
            promotionGift.Promotion__c = promotions[count].id;
        }
        insert promotionGifts;        
    
      //Order_Line_Item_Gift__c
        List<Order_Line_Item_Gift__c> orderLineItemGifts = TestDataFactory.createItemGift(1);
        count=0;        
        for (Order_Line_Item_Gift__c olig : orderLineItemGifts) {
            olig.Order_Line_Item__c = orderLineItems[count].id;
            olig.Promotion_Gift__c = promotionGifts[count].id;
            count++;            
        }      
        insert orderLineItemGifts;  
        
      //Gift__c
        List<Gift__c> gifts = TestDataFactory.createGift(1);
        insert gifts;
        
      //Gift_Letter_Batch__c
        /*Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c, Promo_Chinese_Name__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];*/
                                                   
        Gift_Letter_Batch__c giftLetterBatch = new Gift_Letter_Batch__c();
        giftLetterBatch.Redemption_Venue__c = 'Funan DigitaLife Mall: #03-32, 109 North Bridge Road, Singapore 179097 Tel: 6837 8186';
        giftLetterBatch.Redemption_End_Date__c = Date.today().addDays(30);
        giftLetterBatch.Promo_Chinese_Name__c = 'Sample Chinese Name';
        giftLetterBatch.Letter_Template__c = 'Premium (Chi)';
        giftLetterBatch.Start_Date__c = Date.today().addDays(1);
        giftLetterBatch.End_Date__c = Date.today().addDays(30);
        giftLetterBatch.Promotion__c = promotions[0].id;
        giftLetterBatch.Gift__c = gifts[0].id;
        insert giftLetterBatch;
 
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Zuora__Account__c = accounts[0].Id;
            zSub.Order_Line_Item_Number__c = orderLineItems[0].Id;
            zSub.Subscriber_Contact__c = contacts[0].Id;
            zSub.Recipient_Contact__c = contacts[0].Id;
            zSub.Main_Package_1__c = packages[0].Id;
            zSub.Main_Package__c = packages[0].Id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = orders[0].Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Zuora__SubscriptionEndDate__c= date.today().addDays(30);
            zSub.Zuora__SubscriptionStartDate__c = date.today();
            zSub.Zuora__CustomerAccount__c = billAcct.Id;
            zsub.Contact__c = contacts[0].id;
            zsub.New_Contract_Period_1__c = 1;
            zsub.New_Contract_Period__c = '1';
            insert zSub;        
        
      //zqu__ZProduct__c
        List<zqu__ZProduct__c> products = TestDataFactory.createZProduct(1);
        insert products; 
        
      //Product_Rate_Plan__c
        List<zqu__ProductRatePlan__c> productPlans = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c productPlan: productPlans){
            productPlan.RatePlanType__c = 'Bill Plan';
            productPlan.zqu__ZProduct__c = products[0].id;
        }
        insert productPlans;
        
      //Product_Family__c
        Product_Family__c productFamily = new Product_Family__c();
        productFamily.Product_Family__c = 'Sample Product Family';
        insert productFamily;
        
      //Package_Item__c 
        List<Package_Item__c > packageItems = TestDataFactory.createPackageItem(1, 'Bundle Product' );
        for(Package_Item__c packageItem: packageItems){
            packageItem.Package__c = packages[0].id;
            packageItem.Product_Rate_Plan__c = productPlans[0].id;
            packageItem.Product_Family__c = productFamily.id;
            packageItem.RecordTypeId = bundlerecordtype.Id;
        }
        //insert packageItems;


        PageReference pgRef = Page.LP_HappyCallLetterChinese;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterChineseController lp = new LP_HappyCallLetterChineseController(); 
    }
    
    static testmethod void testLP_HappyCallLetterChineseControllerBundle4(){
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Individual');
        accounts[0].Airline_Indicator__c = true;
        insert accounts;
        


      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Bundle';
            packagee.Subscription_Period__c = '1';
            packagee.Subscription_Type__c = 'Termed';
        
        }
        insert packages;
        
      //Country__c
        List<Country__c> countries = TestDataFactory.createCountry(1);
        countries[0].Country_Name__c = 'Singapore';
        insert countries;
        
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;   
        
        City__c City = new City__c();
        City.City_Name__c = 'TestName';
        City.Flight_Number_1__c = '087';
        City.Flight_Number_2__c = '088';
        City.Country__c = countries[0].Id;
        insert City;       
        
        Packing_Grp__c packingGrp = new Packing_Grp__c();
        packingGrp.Airline__c = 'Airline';
        insert packingGrp; 
        
        
        
      //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
            address.Country__c = countries[0].id;
            address.RecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
            address.Block_House_Number__c = '21B';
            address.Level_Number__c = '123';
            address.Unit_Number__c = '19';
            address.Postal_Code__c = postalAddresses[0].id;
            address.City__c = City.id;
            address.Packing_Code__c = packingGrp.Id;
                   
        }
        insert addresses;  
        
      //Contact
        List<Contact> contacts = TestDataFactory.createContact(1);
        for(Contact contact: contacts){
            contact.Address__c = addresses[0].id;
            contact.AccountId = accounts[0].id;
            contact.Recipient_Indicator__c = true;
            contact.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        }
        insert contacts;  

        // billing account
        Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
        billAcct.Zuora__Account__c = accounts[0].Id;
        billAcct.Billing_Contact__c = contacts[0].Id;
        billAcct.Zuora__Zuora_Id__c = 'Test1';
        billAcct.Billing_Type__c = 'Full Prepaid';
        billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcct.Zuora__AccountNumber__c = 'Test1';
        
        insert billAcct;          
        
      //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord: orders){
            ord.Account__c = accounts[0].id;
            ord.Recipient_Contact__c = contacts[0].id;
        }
        insert orders;

      //Order_Line_Item__c
        List<Order_Line_Item__c> orderLineItems = TestDataFactory.createOrderLineItem(1);
        count = 0;
        for (Order_Line_Item__c oli : orderLineItems) {
            oli.Order__c = orders[count].id; 
            oli.Main_Package_ID__c = packages[count].id;
            oli.Start_Date__c = date.today()+1;
            
        }        
        insert orderLineItems;
      
      //Promotion__c
        List<Promotion__c> promotions = TestDataFactory.createPromotion(1);
        for(Promotion__c promotion: promotions){
            promotion.Contract_Period__c = '36';
        }
        insert promotions;  
        
      //Promotion_Gift__c
        List<Promotion_Gift__c> promotionGifts = TestDataFactory.createPromotionGift(1);
        count = 0;
        for(Promotion_Gift__c promotionGift: promotionGifts){
            promotionGift.Promotion__c = promotions[count].id;
        }
        insert promotionGifts;        
    
      //Order_Line_Item_Gift__c
        List<Order_Line_Item_Gift__c> orderLineItemGifts = TestDataFactory.createItemGift(1);
        count=0;        
        for (Order_Line_Item_Gift__c olig : orderLineItemGifts) {
            olig.Order_Line_Item__c = orderLineItems[count].id;
            olig.Promotion_Gift__c = promotionGifts[count].id;
            count++;            
        }      
        insert orderLineItemGifts;  
        
      //Gift__c
        List<Gift__c> gifts = TestDataFactory.createGift(1);
        insert gifts;
        
      //Gift_Letter_Batch__c
        /*Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c, Promo_Chinese_Name__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];*/
                                                   
        Gift_Letter_Batch__c giftLetterBatch = new Gift_Letter_Batch__c();
        giftLetterBatch.Redemption_Venue__c = 'Funan DigitaLife Mall: #03-32, 109 North Bridge Road, Singapore 179097 Tel: 6837 8186';
        giftLetterBatch.Redemption_End_Date__c = Date.today().addDays(30);
        giftLetterBatch.Promo_Chinese_Name__c = 'Sample Chinese Name';
        giftLetterBatch.Letter_Template__c = 'Premium (Chi)';
        giftLetterBatch.Start_Date__c = Date.today().addDays(1);
        giftLetterBatch.End_Date__c = Date.today().addDays(30);
        giftLetterBatch.Promotion__c = promotions[0].id;
        giftLetterBatch.Gift__c = gifts[0].id;
        insert giftLetterBatch;
 
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
            zSub.Zuora__Account__c = accounts[0].Id;
            zSub.Order_Line_Item_Number__c = orderLineItems[0].Id;
            zSub.Subscriber_Contact__c = contacts[0].Id;
            zSub.Recipient_Contact__c = contacts[0].Id;
            zSub.Main_Package_1__c = packages[0].Id;
            zSub.Main_Package__c = packages[0].Id;
            zSub.Zuora__Status__c = 'Active';
            zSub.Order_Number__c = orders[0].Id;
            zSub.Suppress_Vendor_Start_Notice__c = 'false';
            zSub.Supressed_Acknowledgement_Letter__c = 'false';
            zSub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSub.Urgent__c = 'false';
            zSub.Vendor_Conversion__c = 'false';
            zSub.Charity__c = 'false';
            zSub.Subscription_Type__c = 'Publication';
            zSub.Subscription_Type_1__c = 'Publication';
            zSub.Zuora__SubscriptionEndDate__c= date.today().addDays(30);
            zSub.Zuora__SubscriptionStartDate__c = date.today();
            zSub.Zuora__CustomerAccount__c = billAcct.Id;
            zsub.Contact__c = contacts[0].id;
            zsub.New_Contract_Period_1__c = 1;
            zsub.New_Contract_Period__c = '1';
            insert zSub;        
        
      //zqu__ZProduct__c
        List<zqu__ZProduct__c> products = TestDataFactory.createZProduct(1);
        insert products; 
        
      //Product_Rate_Plan__c
        List<zqu__ProductRatePlan__c> productPlans = TestDataFactory.createProductRatePlan(1);
        for(zqu__ProductRatePlan__c productPlan: productPlans){
            productPlan.RatePlanType__c = 'Bill Plan';
            productPlan.zqu__ZProduct__c = products[0].id;
        }
        insert productPlans;
        
      //Product_Family__c
        Product_Family__c productFamily = new Product_Family__c();
        productFamily.Product_Family__c = 'Sample Product Family';
        insert productFamily;
        
      //Package_Item__c 
        List<Package_Item__c > packageItems = TestDataFactory.createPackageItem(1, 'Bundle Product' );
        for(Package_Item__c packageItem: packageItems){
            packageItem.Package__c = packages[0].id;
            packageItem.Product_Rate_Plan__c = productPlans[0].id;
            packageItem.Product_Family__c = productFamily.id;
        }
        //insert packageItems;

        PageReference pgRef = Page.LP_HappyCallLetterChinese;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterChineseController lp = new LP_HappyCallLetterChineseController(); 
    }
    
    static testmethod void testLP_HappyCallLetterChineseControllerVenueLine4(){
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert accounts;
        
      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Bundle';
            packagee.Subscription_Period__c = '1';
            packagee.Subscription_Type__c = 'Termed';
            
        }
        insert packages;
        
      //Country__c
        List<Country__c> countries = TestDataFactory.createCountry(1);
        insert countries;
        
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;   
        
      //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
            address.Country__c = countries[count].id;
            address.Block_House_Number__c = '21B';
            address.Level_Number__c = '123';
            address.Unit_Number__c = '19';
            address.Postal_Code__c = postalAddresses[0].id;
        }
        insert addresses;  
        
      //Contact
        List<Contact> contacts = TestDataFactory.createContact(1);
        count = 0;
        for(Contact contact: contacts){
            contact.Address__c = addresses[count].id;
            contact.AccountId = accounts[count].id;
            contact.Recipient_Indicator__c = true;
        }
        insert contacts;  

      //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(1);
        count = 0;
        for(Order__c ord: orders){
            ord.Account__c = accounts[count].id;
            ord.Recipient_Contact__c = contacts[count].id;
        }
        insert orders;

      //Order_Line_Item__c
        List<Order_Line_Item__c> orderLineItems = TestDataFactory.createOrderLineItem(1);
        count = 0;
        for (Order_Line_Item__c oli : orderLineItems) {
            oli.Order__c = orders[count].id; 
            oli.Main_Package_ID__c = packages[count].id;
            oli.Start_Date__c = date.today()+1;
        }        
        insert orderLineItems;
      
      //Promotion__c
        List<Promotion__c> promotions = TestDataFactory.createPromotion(1);
        for(Promotion__c promotion: promotions){
            promotion.Contract_Period__c = '36';
        }
        insert promotions;  
        
      //Promotion_Gift__c
        List<Promotion_Gift__c> promotionGifts = TestDataFactory.createPromotionGift(1);
        count = 0;
        for(Promotion_Gift__c promotionGift: promotionGifts){
            promotionGift.Promotion__c = promotions[count].id;
        }
        insert promotionGifts;        
    
      //Order_Line_Item_Gift__c
        List<Order_Line_Item_Gift__c> orderLineItemGifts = TestDataFactory.createItemGift(1);
        count=0;        
        for (Order_Line_Item_Gift__c olig : orderLineItemGifts) {
            olig.Order_Line_Item__c = orderLineItems[count].id;
            olig.Promotion_Gift__c = promotionGifts[count].id;
            count++;            
        }      
        insert orderLineItemGifts;  
        
      //Gift__c
        List<Gift__c> gifts = TestDataFactory.createGift(1);
        insert gifts;
        
      //Gift_Letter_Batch__c
        /*Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c, Promo_Chinese_Name__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];*/
                                                   
        Gift_Letter_Batch__c giftLetterBatch = new Gift_Letter_Batch__c();
        giftLetterBatch.Redemption_Venue__c = 'This<br>Is<br>A<br>Sample';
        giftLetterBatch.Redemption_End_Date__c = Date.today().addDays(30);
        giftLetterBatch.Promo_Chinese_Name__c = 'Sample Chinese Name';
        giftLetterBatch.Letter_Template__c = 'Premium (Chi)';
        giftLetterBatch.Start_Date__c = Date.today().addDays(1);
        giftLetterBatch.End_Date__c = Date.today().addDays(30);
        giftLetterBatch.Promotion__c = promotions[0].id;
        giftLetterBatch.Gift__c = gifts[0].id;
        insert giftLetterBatch;

        PageReference pgRef = Page.LP_HappyCallLetterChinese;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterChineseController lp = new LP_HappyCallLetterChineseController(); 
    }
    
    static testmethod void testLP_HappyCallLetterChineseControllerVenueLineMore4(){
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert accounts;
        
      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Bundle';
            packagee.Subscription_Period__c = '1';
            packagee.Subscription_Type__c = 'Termed';
            
        }
        insert packages;
        
      //Country__c
        List<Country__c> countries = TestDataFactory.createCountry(1);
        insert countries;
        
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;   
        
      //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
            address.Country__c = countries[count].id;
            address.Block_House_Number__c = '21B';
            address.Level_Number__c = '123';
            address.Unit_Number__c = '19';
            address.Postal_Code__c = postalAddresses[0].id;
        }
        insert addresses;  
        
      //Contact
        List<Contact> contacts = TestDataFactory.createContact(1);
        count = 0;
        for(Contact contact: contacts){
            contact.Address__c = addresses[count].id;
            contact.AccountId = accounts[count].id;
            contact.Recipient_Indicator__c = true;
        }
        insert contacts;  

      //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(1);
        count = 0;
        for(Order__c ord: orders){
            ord.Account__c = accounts[count].id;
            ord.Recipient_Contact__c = contacts[count].id;
        }
        insert orders;

      //Order_Line_Item__c
        List<Order_Line_Item__c> orderLineItems = TestDataFactory.createOrderLineItem(1);
        count = 0;
        for (Order_Line_Item__c oli : orderLineItems) {
            oli.Order__c = orders[count].id; 
            oli.Main_Package_ID__c = packages[count].id;
            oli.Start_Date__c = date.today()+1;
        }        
        insert orderLineItems;
      
      //Promotion__c
        List<Promotion__c> promotions = TestDataFactory.createPromotion(1);
        for(Promotion__c promotion: promotions){
            promotion.Contract_Period__c = '36';
        }
        insert promotions;  
        
      //Promotion_Gift__c
        List<Promotion_Gift__c> promotionGifts = TestDataFactory.createPromotionGift(1);
        count = 0;
        for(Promotion_Gift__c promotionGift: promotionGifts){
            promotionGift.Promotion__c = promotions[count].id;
        }
        insert promotionGifts;        
    
      //Order_Line_Item_Gift__c
        List<Order_Line_Item_Gift__c> orderLineItemGifts = TestDataFactory.createItemGift(1);
        count=0;        
        for (Order_Line_Item_Gift__c olig : orderLineItemGifts) {
            olig.Order_Line_Item__c = orderLineItems[count].id;
            olig.Promotion_Gift__c = promotionGifts[count].id;
            count++;            
        }      
        insert orderLineItemGifts;  
        
      //Gift__c
        List<Gift__c> gifts = TestDataFactory.createGift(1);
        insert gifts;
        
      //Gift_Letter_Batch__c
        /*Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c, Promo_Chinese_Name__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];*/
                                                   
        Gift_Letter_Batch__c giftLetterBatch = new Gift_Letter_Batch__c();
        giftLetterBatch.Redemption_Venue__c = 'This<br>Is<br>A<br>Sample<br>Line';
        giftLetterBatch.Redemption_End_Date__c = Date.today().addDays(30);
        giftLetterBatch.Promo_Chinese_Name__c = 'Sample Chinese Name';
        giftLetterBatch.Letter_Template__c = 'Premium (Chi)';
        giftLetterBatch.Start_Date__c = Date.today().addDays(1);
        giftLetterBatch.End_Date__c = Date.today().addDays(30);
        giftLetterBatch.Promotion__c = promotions[0].id;
        giftLetterBatch.Gift__c = gifts[0].id;
        insert giftLetterBatch;

        PageReference pgRef = Page.LP_HappyCallLetterChinese;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterChineseController lp = new LP_HappyCallLetterChineseController(); 
    }
    
    static testmethod void testLP_HappyCallLetterChineseControllerNullGift(){
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert accounts;
        
      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Bundle';
            packagee.Subscription_Period__c = '1';
            packagee.Subscription_Type__c = 'Termed';
            
        }
        insert packages;
        
      //Country__c
        List<Country__c> countries = TestDataFactory.createCountry(1);
        insert countries;
        
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;   
        
      //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
            address.Country__c = countries[count].id;
            address.Block_House_Number__c = '21B';
            address.Level_Number__c = '123';
            address.Unit_Number__c = '19';
            address.Postal_Code__c = postalAddresses[0].id;
        }
        insert addresses;  
        
      //Contact
        List<Contact> contacts = TestDataFactory.createContact(1);
        count = 0;
        for(Contact contact: contacts){
            contact.Address__c = addresses[count].id;
            contact.AccountId = accounts[count].id;
            contact.Recipient_Indicator__c = true;
        }
        insert contacts;  

      //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(1);
        count = 0;
        for(Order__c ord: orders){
            ord.Account__c = accounts[count].id;
            ord.Recipient_Contact__c = contacts[count].id;
        }
        insert orders;

      //Order_Line_Item__c
        List<Order_Line_Item__c> orderLineItems = TestDataFactory.createOrderLineItem(1);
        count = 0;
        for (Order_Line_Item__c oli : orderLineItems) {
            oli.Order__c = orders[count].id; 
            oli.Main_Package_ID__c = packages[count].id;
            oli.Start_Date__c = date.today()+1;
        }        
        insert orderLineItems;
      
      //Promotion__c
        List<Promotion__c> promotions = TestDataFactory.createPromotion(1);
        for(Promotion__c promotion: promotions){
            promotion.Contract_Period__c = '36';
        }
        insert promotions;  
        
      //Promotion_Gift__c
        List<Promotion_Gift__c> promotionGifts = TestDataFactory.createPromotionGift(1);
        count = 0;
        for(Promotion_Gift__c promotionGift: promotionGifts){
            promotionGift.Promotion__c = promotions[count].id;
        }
        insert promotionGifts;        
    
      //Order_Line_Item_Gift__c
        List<Order_Line_Item_Gift__c> orderLineItemGifts = TestDataFactory.createItemGift(1);
        count=0;        
        for (Order_Line_Item_Gift__c olig : orderLineItemGifts) {
            olig.Order_Line_Item__c = orderLineItems[count].id;
            olig.Promotion_Gift__c = promotionGifts[count].id;
            count++;            
        }      
        insert orderLineItemGifts;  
        
      //Gift__c
        List<Gift__c> gifts = TestDataFactory.createGift(1);
        insert gifts;

        PageReference pgRef = Page.LP_HappyCallLetterChinese;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', null);
        
        LP_HappyCallLetterChineseController lp = new LP_HappyCallLetterChineseController(); 
        lp.blockHouseNum = 'test';
        lp.levelNum = 'test';
        lp.unitNum = 'test';
        lp.buildingName = 'test';
        lp.stName = 'test';
        lp.giftDesnum = 1;        
        lp.barcode = 'test';
        lp.pubDes = 'test';
        lp.rDetails = 'test';
        lp.rVenueLine1 = 'test';
        lp.rVenueLine2 = 'test';
        lp.rVenueLine3 = 'test';
        lp.rVenueLine4 = 'test';
        lp.rStartDate = date.today()+1;
        
    }
}