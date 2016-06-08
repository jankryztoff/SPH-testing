/* TODO Descriptions 
*Base Class: LP_HappyCallLetterController
*
*/

// Positive
@isTest (SeeAllData=true)
public class LP_HappyCallLetterControllerTest {
 
    static testMethod void testLP_HappyCallLetterControllerBase() {
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert accounts;
        
      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Grace Period';
            packagee.Subscription_Period__c = '1';
            packagee.Subscription_Type__c = 'Termed';
        }
        insert packages;  
        
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
        
      //Postal__c
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;
        
        Blob myBlob = Blob.valueof('This is a sample attachment.');
        
      //Attachment
        Attachment attachment = new Attachment();
        attachment.ParentId = postalAddresses[0].id;
        attachment.Name = 'Sample Attachment';
        attachment.Body = myBlob;
        insert attachment;
        
      //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
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
            contact.FirstName = 'Test';
            contact.LastName = 'Test';
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
            oli.Start_Date__c = date.today().addDays(2);
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
        Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];

        PageReference pgRef = Page.LP_HappyCallLetter;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterController testObj = new LP_HappyCallLetterController();
    }
    
    static testMethod void testLP_HappyCallLetterControllerBundle2() {
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert accounts;
        
      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Grace Period';
            packagee.Package_Sub_Type__c = 'Single';
            packagee.Subscription_Period__c = '1';
        }
        insert packages;  
        
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
        List<Package_Item__c > packageItems = TestDataFactory.createPackageItem(2, 'Base Product' );
        for(Package_Item__c packageItem: packageItems){
            packageItem.Package__c = packages[count].id;
            packageItem.Product_Rate_Plan__c = productPlans[count].id;
            packageItem.Product_Family__c = productFamily.id;
        }
        insert packageItems;
        
      //Postal__c
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;
        
        Blob myBlob = Blob.valueof('This is a sample attachment.');
        
      //Attachment
        Attachment attachment = new Attachment();
        attachment.ParentId = postalAddresses[0].id;
        attachment.Name = 'Sample Attachment';
        attachment.Body = myBlob;
        insert attachment;
        
      //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
            address.Address_1__c = 'test';
            address.Address_2__c = 'test';
            address.Address_3__c = 'test';
            address.Address_4__c = 'test';
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
            contact.FirstName = 'Test';
            contact.LastName = 'Test';
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
            oli.Start_Date__c = date.today().addDays(2);
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
        Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];
        
        Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
        billAcct.Zuora__Account__c = accounts[0].Id;
        billAcct.Billing_Contact__c = contacts[0].Id;
        billAcct.Zuora__Zuora_Id__c = 'Test1';
        billAcct.Billing_Type__c = 'Full Prepaid';
        billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcct.Zuora__AccountNumber__c = 'Test1';
        insert billAcct; 
                                                   
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__Account__c = accounts[0].Id;
        zSub.Order_Line_Item_Number_1__c = orderLineItems[0].id;
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
        zSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        zSub.New_Contract_Period_1__c = 1;
        insert zSub;
        
        PageReference pgRef = Page.LP_HappyCallLetter;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterController testObj = new LP_HappyCallLetterController();
    }
    
    static testMethod void testLP_HappyCallLetterControllerBundle3() {
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert accounts;
        
      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Grace Period';
            packagee.Package_Sub_Type__c = 'Single';
            packagee.Subscription_Period__c = '1';
        }
        insert packages;  
        
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
        List<Package_Item__c > packageItems = TestDataFactory.createPackageItem(2, 'Base Product' );
        for(Package_Item__c packageItem: packageItems){
            packageItem.Package__c = packages[count].id;
            packageItem.Product_Rate_Plan__c = productPlans[count].id;
            packageItem.Product_Family__c = productFamily.id;
        }
        insert packageItems;
        
      //Postal__c
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;
        
        Blob myBlob = Blob.valueof('This is a sample attachment.');
        
      //Attachment
        Attachment attachment = new Attachment();
        attachment.ParentId = postalAddresses[0].id;
        attachment.Name = 'Sample Attachment';
        attachment.Body = myBlob;
        insert attachment;
        
      //Address
        RecordType recType = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Overseas'];
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
            address.Address_1__c = 'test';
            address.Address_2__c = 'test';
            address.Address_3__c = 'test';
            address.Address_4__c = 'test';
            address.Block_House_Number__c = '21B';
            address.Level_Number__c = '123';
            address.Unit_Number__c = '19';
            address.Postal_Code__c = postalAddresses[0].id;
            address.RecordTypeId = recType.Id;
        }  
        insert addresses;
        
      //Contact
        List<Contact> contacts = TestDataFactory.createContact(1);
        count = 0;
        for(Contact contact: contacts){
            contact.Address__c = addresses[count].id;
            contact.AccountId = accounts[count].id;    
            contact.Recipient_Indicator__c = true;
            contact.FirstName = 'Test';
            contact.LastName = 'Test';
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
            oli.Start_Date__c = date.today().addDays(2);
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
        Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];
        
        Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
        billAcct.Zuora__Account__c = accounts[0].Id;
        billAcct.Billing_Contact__c = contacts[0].Id;
        billAcct.Zuora__Zuora_Id__c = 'Test1';
        billAcct.Billing_Type__c = 'Full Prepaid';
        billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcct.Zuora__AccountNumber__c = 'Test1';
        insert billAcct; 
                                                   
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__Account__c = accounts[0].Id;
        zSub.Order_Line_Item_Number_1__c = orderLineItems[0].id;
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
        zSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        zSub.New_Contract_Period_1__c = 1;
        insert zSub;
        
        PageReference pgRef = Page.LP_HappyCallLetter;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterController testObj = new LP_HappyCallLetterController();
    }
    
    static testMethod void testLP_HappyCallLetterControllerBundle4() {
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert accounts;
        
      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Grace Period';
            packagee.Package_Sub_Type__c = 'Single';
            packagee.Subscription_Period__c = '1';
        }
        insert packages;  
        
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
        List<Package_Item__c > packageItems = TestDataFactory.createPackageItem(2, 'Base Product' );
        for(Package_Item__c packageItem: packageItems){
            packageItem.Package__c = packages[count].id;
            packageItem.Product_Rate_Plan__c = productPlans[count].id;
            packageItem.Product_Family__c = productFamily.id;
        }
        insert packageItems;
        
      //Postal__c
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;
        
        Blob myBlob = Blob.valueof('This is a sample attachment.');
        
      //Attachment
        Attachment attachment = new Attachment();
        attachment.ParentId = postalAddresses[0].id;
        attachment.Name = 'Sample Attachment';
        attachment.Body = myBlob;
        insert attachment;
        
      //Address
        RecordType recType = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Internal'];
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
            address.Address_1__c = 'test';
            address.Address_2__c = 'test';
            address.Address_3__c = 'test';
            address.Address_4__c = 'test';
            address.Block_House_Number__c = '21B';
            address.Level_Number__c = '123';
            address.Unit_Number__c = '19';
            address.Postal_Code__c = postalAddresses[0].id;
            address.RecordTypeId = recType.Id;
        }  
        insert addresses;
        
      //Contact
        List<Contact> contacts = TestDataFactory.createContact(1);
        count = 0;
        for(Contact contact: contacts){
            contact.Address__c = addresses[count].id;
            contact.AccountId = accounts[count].id;    
            contact.Recipient_Indicator__c = true;
            contact.FirstName = 'Test';
            contact.LastName = 'Test Test';
            contact.Billing_Indicator__c = TRUE;
        }
        insert contacts;  

      //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(1);
        count = 0;
        for(Order__c ord: orders){
            ord.Account__c = accounts[count].id;
            ord.Recipient_Contact__c = contacts[count].id;
            ord.Billing_Contact__c = contacts[count].id;
        }
        insert orders;

      //Order_Line_Item__c
        List<Order_Line_Item__c> orderLineItems = TestDataFactory.createOrderLineItem(1);
        count = 0;
        for (Order_Line_Item__c oli : orderLineItems) {
            oli.Order__c = orders[count].id; 
            oli.Main_Package_ID__c = packages[count].id;
            oli.Start_Date__c = date.today().addDays(2);
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
        Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];
        
        Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
        billAcct.Zuora__Account__c = accounts[0].Id;
        billAcct.Billing_Contact__c = contacts[0].Id;
        billAcct.Zuora__Zuora_Id__c = 'Test1';
        billAcct.Billing_Type__c = 'Full Prepaid';
        billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcct.Zuora__AccountNumber__c = 'Test1';
        insert billAcct; 
                                                   
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__Account__c = accounts[0].Id;
        zSub.Order_Line_Item_Number_1__c = orderLineItems[0].id;
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
        zSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        zSub.New_Contract_Period_1__c = 1;
        insert zSub;
        
        PageReference pgRef = Page.LP_HappyCallLetter;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterController testObj = new LP_HappyCallLetterController();
        
       //TODO
        List<String> delAddrList = new List<String>();
        delAddrList.Add('Test');
        testObj.giftDes = 'Test';
        testObj.giftDesnum = 1;
        testObj.postalCode = 'Test';
        testObj.delAddr = delAddrList;
        testObj.rVenue = 'Test';
        testObj.barcode = 'Test';
        testObj.rDetails = 'Test';
        testObj.rEndDate = date.today().addDays(10);
        testObj.rStartDate = date.today().addDays(2);
        testObj.cntry = 'Test';
        testObj.giftLetterBatchId = 'Test';
        testObj.ProductCode = 'Test';
        testObj.ProductName = 'Test';
        testObj.blockHouseNum = 'Test';
        testObj.levelNum = 'Test';
        testObj.unitNum = 'Test';
        testObj.buildingName  = 'Test';
        testObj.stName = 'Test';
        testObj.address1  = 'Test';
        testObj.address2  = 'Test';
        testObj.address3  = 'Test';
        testObj.address4  = 'Test';
        testObj.address5  = 'Test';
        testObj.contactName  = 'Test';
        testObj.billingContactName  = 'Test';
    }
    
    static testMethod void testLP_HappyCallLetterControllerBundle5() {
    
        Integer count = 0;   
        
      //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        insert accounts;
        
      //Main_Package_ID__c
        List<Package__c> packages = TestDataFactory.createPackage(1);
        for(Package__c packagee: packages){
            packagee.Package_Type__c = 'Base';//TODO jhen
            packagee.Package_Sub_Type__c = 'Single';
            packagee.Subscription_Period__c = '1';
        }
        insert packages;  
        
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
        List<Package_Item__c > packageItems = TestDataFactory.createPackageItem(2, 'Base Product' );
        for(Package_Item__c packageItem: packageItems){
            packageItem.Package__c = packages[count].id;
            packageItem.Product_Rate_Plan__c = productPlans[count].id;
            packageItem.Product_Family__c = productFamily.id;
        }
        insert packageItems;
        
      //Postal__c
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;
        
        Blob myBlob = Blob.valueof('This is a sample attachment.');
        
      //Attachment
        Attachment attachment = new Attachment();
        attachment.ParentId = postalAddresses[0].id;
        attachment.Name = 'Sample Attachment';
        attachment.Body = myBlob;
        insert attachment;
        
      //Address
        RecordType recType = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Address__c' AND Name = 'Internal'];
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
            address.Address_1__c = 'test';
            address.Address_2__c = 'test';
            address.Address_3__c = 'test';
            address.Address_4__c = 'test';
            address.Block_House_Number__c = '21B';
            address.Level_Number__c = '123';
            address.Unit_Number__c = '19';
            address.Postal_Code__c = postalAddresses[0].id;
            address.RecordTypeId = recType.Id;
        }  
        insert addresses;
        
      //Contact
        List<Contact> contacts = TestDataFactory.createContact(1);
        count = 0;
        for(Contact contact: contacts){
            contact.Address__c = addresses[count].id;
            contact.AccountId = accounts[count].id;    
            contact.Recipient_Indicator__c = true;
            contact.FirstName = 'Test';
            contact.LastName = 'Test Test';
            contact.Billing_Indicator__c = TRUE;
        }
        insert contacts;  

      //Order__c
        List<Order__c> orders = TestDataFactory.createOrder(1);
        count = 0;
        for(Order__c ord: orders){
            ord.Account__c = accounts[count].id;
            ord.Recipient_Contact__c = contacts[count].id;
            ord.Billing_Contact__c = contacts[count].id;
        }
        insert orders;

      //Order_Line_Item__c
        List<Order_Line_Item__c> orderLineItems = TestDataFactory.createOrderLineItem(1);
        count = 0;
        for (Order_Line_Item__c oli : orderLineItems) {
            oli.Order__c = orders[count].id; 
            oli.Main_Package_ID__c = packages[count].id;
            oli.Start_Date__c = date.today().addDays(2);
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
        Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];
        
        Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
        billAcct.Zuora__Account__c = accounts[0].Id;
        billAcct.Billing_Contact__c = contacts[0].Id;
        billAcct.Zuora__Zuora_Id__c = 'Test1';
        billAcct.Billing_Type__c = 'Full Prepaid';
        billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcct.Zuora__AccountNumber__c = 'Test1';
        insert billAcct; 
                                                   
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__Account__c = accounts[0].Id;
        zSub.Order_Line_Item_Number_1__c = orderLineItems[0].id;
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
        zSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        zSub.New_Contract_Period_1__c = 1;
        insert zSub;
        
        PageReference pgRef = Page.LP_HappyCallLetter;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterController testObj = new LP_HappyCallLetterController();
        
       //TODO
        List<String> delAddrList = new List<String>();
        delAddrList.Add('Test');
        testObj.giftDes = 'Test';
        testObj.giftDesnum = 1;
        testObj.postalCode = 'Test';
        testObj.delAddr = delAddrList;
        testObj.rVenue = 'Test';
        testObj.barcode = 'Test';
        testObj.rDetails = 'Test';
        testObj.rEndDate = date.today().addDays(10);
        testObj.rStartDate = date.today().addDays(2);
        testObj.cntry = 'Test';
        testObj.giftLetterBatchId = 'Test';
        testObj.ProductCode = 'Test';
        testObj.ProductName = 'Test';
        testObj.blockHouseNum = 'Test';
        testObj.levelNum = 'Test';
        testObj.unitNum = 'Test';
        testObj.buildingName  = 'Test';
        testObj.stName = 'Test';
        testObj.address1  = 'Test';
        testObj.address2  = 'Test';
        testObj.address3  = 'Test';
        testObj.address4  = 'Test';
        testObj.address5  = 'Test';
        testObj.contactName  = 'Test';
        testObj.billingContactName  = 'Test';
    }
    
    static testMethod void testLP_HappyCallLetterControllerBundle1() {
    
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
            packageItem.Package__c = packages[count].id;
            packageItem.Product_Rate_Plan__c = productPlans[count].id;
            packageItem.Product_Family__c = productFamily.id;
        }
        //insert packageItems; //by jjzs apr072016
        
      //Postal__c
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;
        
        Blob myBlob = Blob.valueof('This is a sample attachment.');
        
      //Attachment
        Attachment attachment = new Attachment();
        attachment.ParentId = postalAddresses[0].id;
        attachment.Name = 'Sample Attachment';
        attachment.Body = myBlob;
        insert attachment;
        
      //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
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
            contact.FirstName = 'Test';
            contact.LastName = 'Test';
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
            oli.Start_Date__c = date.today().addDays(2);
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
        Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];
        
        Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
        billAcct.Zuora__Account__c = accounts[0].Id;
        billAcct.Billing_Contact__c = contacts[0].Id;
        billAcct.Zuora__Zuora_Id__c = 'Test1';
        billAcct.Billing_Type__c = 'Full Prepaid';
        billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
        billAcct.Zuora__AccountNumber__c = 'Test1';
        insert billAcct; 
                                                   
        Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
        zSub.Zuora__Account__c = accounts[0].Id;
        zSub.Order_Line_Item_Number_1__c = orderLineItems[0].id;
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
        zSub.Subscription_Type_1__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
        zSub.New_Contract_Period_1__c = 1;
        insert zSub;

        PageReference pgRef = Page.LP_HappyCallLetter;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', giftLetterBatch.id);
        
        LP_HappyCallLetterController testObj = new LP_HappyCallLetterController();
    }
    
    static testMethod void testLP_HappyCallLetterControllerNullGiftId() {
    
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
            packageItem.Package__c = packages[count].id;
            packageItem.Product_Rate_Plan__c = productPlans[count].id;
            packageItem.Product_Family__c = productFamily.id;
        }
        //insert packageItems;
        
      //Postal__c
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
        }
        insert postalAddresses;
        
        Blob myBlob = Blob.valueof('This is a sample attachment.');
        
      //Attachment
        Attachment attachment = new Attachment();
        attachment.ParentId = postalAddresses[0].id;
        attachment.Name = 'Sample Attachment';
        attachment.Body = myBlob;
        insert attachment;
        
      //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
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
            contact.FirstName = 'Test';
            contact.LastName = 'Test';
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
            oli.Start_Date__c = date.today().addDays(2);
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
        Gift_Letter_Batch__c giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c
                                                   FROM Gift_Letter_Batch__c LIMIT 1];

        PageReference pgRef = Page.LP_HappyCallLetter;        
        Test.setCurrentPage(pgRef);        
        ApexPages.currentPage().getParameters().put('id', orderLineItemGifts[0].id);
        ApexPages.currentPage().getParameters().put('giftLetterBatchId', null);
        
        LP_HappyCallLetterController testObj = new LP_HappyCallLetterController();
    }
}