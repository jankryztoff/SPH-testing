/**
 * Class Name: TestDataFactory 
 * @author: Jb Domingo
 * Date: 8/11/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Utility Class for test data creation
 *
 */
@isTest                   
public class TestDataFactory { 
    /**
     * @description 
     *      This method creates one or more account test data.   
     * 
     * @param numAccts - number of account to be created
     * @param recType - account record type name
     * @return accountList - list of created accounts
     * @throws exception - none
     */     
    public static List<Account> createAccount(Integer numAccts, String recType) {
        List<Account> accountList = new List<Account>(); 
        //Get the record type ID using the recType parameter. recType will be the Record type name.
        List<RecordType> rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name =: recType LIMIT 1];  
        
        //Create the account object and assign values to the required account fields.
        for(Integer i=0;i<numAccts;i++){
            Account accountRecord = new Account(Name='Test Accoun' + i, Phone='00000' + i);
            
            accountRecord.Email__c = 'john@doe.com';
            accountRecord.Mobile__c = '09324947204';
            
            if(rt.size() > 0){
                //Set the record type of the account 
                accountRecord.RecordTypeId = rt[0].Id;
            }

            if(recType == 'Direct Corporate'){
                accountRecord.AccountNumber='AN000' + i;
                accountRecord.Unique_Entity_Number__c = '00000' + i;
                accountRecord.Contact_Person__c = 'Contact Person ' + i;
            }
            else if(recType == 'Direct SPH Inter-Division'){
                accountRecord.Contact_Person__c = 'Contact Person ' + i;              
                //START: D-1091 Modified by FrancisBenzon corrected assignment String to String
                accountRecord.Staff_ID__c = '0' + i;
                //END: D-1091 Modified by FrancisBenzon corrected assignment String to String                                   
            }
            else if(recType == 'Mailing Agent'){
                accountRecord.Mailing_Agent_Code__c = '00000' + i;
                accountRecord.PostalCode__c = '00000' + i;
            }
            //Add the account object to the account list 
            accountList.add(accountRecord);
        }
        
        return accountList;
    }
    
    /**
     * @description 
     *      This method creates one or more contact test data. 
     * 
     * @param numContacts - number of contact to be created
     * @param recType - contact record type name
     * @return contactList - list of created contacts
     * @throws exception - none
     */ 
    public static List<Contact> createContactRecType(Integer numContacts, String recType) {

        // Start JohnD
        try {
            Key_Id__c contactNextNumber = createContactNextNumber ();
            if (contactNextNumber == null) {
                insert contactNextNumber;
            }
        } catch (exception e) {}
        // End JohnD
        
        List<Contact> contactList = new List<Contact>();
        //Get the record type ID using the recType parameter. recType will be the Record type name.     
        List<RecordType> rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name =: recType LIMIT 1];
 
        //Create the contact object and assign values to the required account fields. 
        for(Integer i=0;i<numContacts;i++){
            Contact contactRecord = new Contact(FirstName='TestContactFirstname'+ i, LastName='TestContactLastname' + i,
                                                Salutation='MR.', Email='sampleemailaddress' + i + '@email.com', 
                                                Phone='111222333' + i);
                                                
            if(rt.size() > 0){
                //Set the record type of the contact                
                contactRecord.RecordTypeId = rt[0].Id;
            }                                       
            //Add the contact object to the contact list 
            contactList.add(contactRecord);
        }
        
        return contactList;
    }
    
    public static List<Contact> createContact(Integer numContacts) {

        // Start JohnD
        try {
            Key_Id__c contactNextNumber = createContactNextNumber ();
            if (contactNextNumber == null) {
                insert contactNextNumber;
            }
        } catch (exception e) {}
        // End JohnD

        List<Contact> contactList = new List<Contact>();
    
        for(Integer i=0;i<numContacts;i++){
            Contact contactRecord = new Contact(FirstName='TestContactFirstname'+ i, LastName='TestContactLastname' + i,
                                                Salutation='MR.', Email='sampleemailaddress' + i + '@email.com', 
                                                Phone='111222333' + i);     
            contactList.add(contactRecord);
        }
        
        return contactList;
    }  

    public static List<Contact> createContact2(Integer numContacts) {

        List<Contact> contactList = new List<Contact>();
    
        for(Integer i=0;i<numContacts;i++){
            Contact contactRecord = new Contact(FirstName='TestContactFirstname'+ i, LastName='TestContactLastname' + i,
                                                Salutation='MR.', Email='sampleemailaddress' + i + '@email.com', 
                                                Phone='111222333' + i);     
            contactList.add(contactRecord);
        }
        
        return contactList;
    }        
        
    public static List<Parcel__c> createParcel(Integer numParcels) {
        List<Parcel__c> parcelList = new List<Parcel__c>();
        
        for(Integer i=0;i<numParcels;i++){
            Parcel__c parcelRecord = new Parcel__c(Name='TestParcel' + i);
            parcelList.add(parcelRecord);
        }
        return parcelList;
    }   
    
    public static List<Publication__c> createPublication(Integer numPublications) {
        List<Publication__c> publicationList = new List<Publication__c>();
        date earliestStartDate = date.today().addDays(1);
        
        for(Integer i=0;i<numPublications;i++){
            Publication__c publicationRecord = new Publication__c(Name='TestPublication' + i, Publication_Code__c='ST' + i, Published_Days__c = 'YYYYYYN', 
                    Publication_Type__c = 'N', Earliest_Start_Date__c=earliestStartDate);
            
            publicationList.add(publicationRecord);
        }
        return publicationList;
    }

    public static List<Subscription_Vendor_Publication__c> createVendorPublication(Integer numVenPublications) {
        List<Subscription_Vendor_Publication__c> venPublicationList = new List<Subscription_Vendor_Publication__c>();
        
        for(Integer i=0;i<numVenPublications;i++){
            //Subscription_Vendor_Publication__c venPublicationRecord = new Subscription_Vendor_Publication__c(Publication__c='Subscription Vendor' + i);
            Subscription_Vendor_Publication__c venPublicationRecord = new Subscription_Vendor_Publication__c();
            venPublicationList .add(venPublicationRecord);
        }
        return venPublicationList;
    }   
    
    public static List<Vendor_Allocation__c> createVendorAlloc(Integer numVendorAllocations) {
        List<Vendor_Allocation__c> vendorAllocationList = new List<Vendor_Allocation__c>();
        
        for(Integer i=0;i<numVendorAllocations;i++){
            Vendor_Allocation__c vendorAllocRecord = new Vendor_Allocation__c(Effective_Start_Date__c= date.today());
            vendorAllocationList.add(vendorAllocRecord);
        }
        return vendorAllocationList;
    }   
    
    public static List<Singpost_Address__c> createSingpostAddress(Integer numSingpostAddress) {
        List<Singpost_Address__c> singpostAddressList = new List<Singpost_Address__c>();
        
        for(Integer i=0;i<numSingpostAddress;i++){
            Singpost_Address__c  singpostAddressRecord = new Singpost_Address__c(Name='SA'+i, Address_Type__c='P',
                                                                                 Street_Name__c='TestStreet' + i,Building_Name__c='TestBldgName'+i,
                                                                                 Number_of_Units__c=i);
            singpostAddressList.add(singpostAddressRecord);
        }
        return singpostAddressList;
    }   
    
    public static List<Post_Sector_Ops_Rep_Mapping__c> createPostSector(Integer numPostSectorMappings) {
        List<Post_Sector_Ops_Rep_Mapping__c> postSectorList = new List<Post_Sector_Ops_Rep_Mapping__c>();
        
        //Zone__c from object Post_Sector_Ops_Rep_Mapping__c was changed from Text to Look up.
        //Query to get the id for Zone__c field.
        Postal_Zone__c pZone = new Postal_Zone__c(Postal_Zone__c = 'A');//hardcoded [SELECT id, name, postal_zone__c FROM Postal_Zone__c WHERE postal_zone__c = 'A'];
        insert pZone;
        
        for(Integer i=0;i<numPostSectorMappings;i++){
            //previous code
            //Post_Sector_Ops_Rep_Mapping__c postSectorRecord = new Post_Sector_Ops_Rep_Mapping__c(Postal_Sector_Code__c=i,
            //                                                                                     Zone__c = 'A');
            Post_Sector_Ops_Rep_Mapping__c postSectorRecord = new Post_Sector_Ops_Rep_Mapping__c(Postal_Sector_Code__c=i,
                                                                                                 Zone__c = pZone.id);
            postSectorList.add(postSectorRecord);
        }
        return postSectorList;
    }

    public static List<Case> createCase(Integer numCases, String recType) {
        List<Case> caseList = new List<Case>();
        List<RecordType> rt = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name=: recType LIMIT 1];
        
        for(Integer i=0;i<numCases;i++){
            Case caseRecord = new Case(Subject='Subject' + i, Status='New', 
                                       RecordTypeId = rt[0].id, Origin='Email');
                                       
            if(recType == 'Complaint - Digital'){
                caseRecord.Category__c = 'Technical Issues';
            }
            else if(recType == 'Complaint - Magazine'){
                caseRecord.Priority = 'Medium';
                caseRecord.Date_Replaced__c = date.today();
            }
            else if(recType == 'Complaint - Newspaper'){
                caseRecord.Priority = 'Medium';
                caseRecord.Date_Replaced__c = date.today();         
                caseRecord.Reclass_Sub_Category__c = 'Non Start';
            }
    
            caseList.add(caseRecord);
        }
        return caseList;
    }   

    public static List<Task> createTask(Integer numTasks) {
        List<Task> taskList = new List<Task>();
        
        for(Integer i=0;i<numTasks;i++){
            Task taskRecord = new Task(Subject='Call', Priority='Normal', Status= 'Open');
            taskList.add(taskRecord);
        }
        return taskList;
    }   
    
    public static List<Order__c> createOrder(Integer numOrders) {
        List<Order__c> orderList = new List<Order__c>();
        
        for(Integer i=0;i<numOrders;i++){
            Order__c orderRecord = new Order__c(/*Total_Full_Prepaid_Charge__c=1000.00,*/ /*Total_Monthly_Recurring_Charge__c=1000.00,*/
                                                Credit_Balance__c=20000.00, /*Postage_Charge__c=200.00,*/ Delivery_Charge__c=100.00,
                                                Monthly_Delivery_Charge_for_Full_Payment__c=100.00);
            orderList.add(orderRecord);
        }
        return orderList;
    }
    
    public static List<Zuora__CustomerAccount__c> createBillingAccount(Integer numBillingAccounts) {
        
        // Start D-4463 29Mar16 JohnD - just to prevent duplicate values 
        try {
            insert createBillingBatch();    // Start/End D-4463 29Mar16 John
        } catch (exception e) {}
        // End D-4463 29Mar16 JohnD
        
        List<Zuora__CustomerAccount__c> billingAccountList = new List<Zuora__CustomerAccount__c>();
        
        for(Integer i=0;i<numBillingAccounts;i++){
            Zuora__CustomerAccount__c billingAccountRecord = new Zuora__CustomerAccount__c(Name='Test Billing Account'+i);
            billingAccountRecord.Billing_Type__c = 'Full Prepaid';
            billingAccountRecord.Zuora__DefaultPaymentMethod__c = 'CreditCard';
            billingAccountList.add(billingAccountRecord);
            
        }
        
        
        return billingAccountList;
    }
    
    public static List<Zuora__Subscription__c> createSubscription(Integer numSubscriptions) {
        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
    
        for(Integer i=0;i<numSubscriptions;i++){
            Zuora__Subscription__c subscriptionRecord = new Zuora__Subscription__c(Name='Test Subscription'+i, Zuora__Zuora_Id__c='ZID'+i,
                                                                                   Next_Earliest_Start_Date__c = date.today()+30, //Order_Number__c='ON00000'+i,
                                                                                   //Order_Line_Item_Number__c='OLIN00000'+i, 
                                                                                   Unique_Address_Id__c='UAID00000'+i, Zuora__Version__c = 1, 
                                                                                   Delivery_Charge__c=200.00, Vendor_Credit_1__c=20000.00, /*Subscription_Charge__c=100.00,*/
                                                                                   Term_Length__c=10, Number_of_Copies__c=3, Zuora__SubscriptionEndDate__c=date.today()+100,
                                                                                   Zuora__SubscriptionStartDate__c=date.today().addDays(1),  
                                                                                   Legacy_Create_By__c='User'+i, Legacy_Create_Date__c='10/24/2014',
                                                                                   Legacy_Subscription_ID__c='LSUB00000'+i, Legacy_Update_By__c='User'+i,
                                                                                   Legacy_Update_Date__c='10/24/2014', Number_of_Copies1__c = '1');
            subscriptionList.add(subscriptionRecord);
        }
        return subscriptionList;
    }
    
    public static List<Zuora__Subscription__c> createActiveSubscription(Integer numSubscriptions, Id orderLineItem,Id customerAccount) {
        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
    
        for(Integer i=0;i<numSubscriptions;i++){
            Zuora__Subscription__c subscriptionRecord = new Zuora__Subscription__c(Name='Test Subscription'+i, Zuora__Zuora_Id__c='ZID'+i,
                                                                                   Next_Earliest_Start_Date__c = date.today()+30, //Order_Number__c='ON00000'+i,
                                                                                   //Order_Line_Item_Number__c='OLIN00000'+i, 
                                                                                   Unique_Address_Id__c='UAID00000'+i, Zuora__Version__c = 1, 
                                                                                   Delivery_Charge__c=200.00, Vendor_Credit_1__c=20000.00, /*Subscription_Charge__c=100.00,*/
                                                                                   Term_Length__c=10, Number_of_Copies__c=3, Zuora__SubscriptionEndDate__c=date.today()+100,
                                                                                   Zuora__SubscriptionStartDate__c=date.today().addDays(1),  
                                                                                   Legacy_Create_By__c='User'+i, Legacy_Create_Date__c='10/24/2014',
                                                                                   Legacy_Subscription_ID__c='LSUB00000'+i, Legacy_Update_By__c='User'+i,
                                                                                   Legacy_Update_Date__c='10/24/2014', Number_of_Copies1__c = '1',
                                                                                   Zuora__Status__c = 'Active', Subscription_Type__c = 'Publication', Subscription_Type_1__c = 'Publication',
                                                                                   Order_Line_Item_Number_1__c = orderLineItem, Zuora__CustomerAccount__c = customerAccount);
            subscriptionList.add(subscriptionRecord);
        }
        return subscriptionList;
    }    
    public static List<ARMS_Activity__c> createArmsActivity(Integer numArmsActivity) {
        List<ARMS_Activity__c> armsActivityList = new List<ARMS_Activity__c>();
    
        for(Integer i=0;i<numArmsActivity;i++){
            ARMS_Activity__c armsActivityRecord = new ARMS_Activity__c(Name='Test Arms Activity'+i);
            armsActivityList.add(armsActivityRecord);
        }
        return armsActivityList;
    }
    
    public static List<Zuora__Product__c> createProduct(Integer numProducts) {
        List<Zuora__Product__c> productList = new List<Zuora__Product__c>();
    
        for(Integer i=0;i<numProducts;i++){
            Zuora__Product__c productRecord = new Zuora__Product__c(Name='Test Product'+i);
            productList.add(productRecord);
        }
        return productList;
    }
    
    public static List<zqu__ProductRatePlan__c> createProductRatePlan(Integer numProductRatePlans) {
        List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c>();
    
        for(Integer i=0;i<numProductRatePlans;i++){
            zqu__ProductRatePlan__c productRatePlanRecord = new zqu__ProductRatePlan__c(Name='Test Product Rate Plan'+i, RatePlanCode__c='TestRatePlan'+i,
                                                                                        zqu__ZuoraId__c='ZID'+i, RatePlanType__c='Bill Plan');
            productRatePlanList.add(productRatePlanRecord);
        }
        return productRatePlanList;
    }
    public static List<zqu__ProductRatePlan__c> createProductRatePlan2(Integer numProductRatePlans, Id zProduct) {
        List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c>();
    
        for(Integer i=0;i<numProductRatePlans;i++){
            zqu__ProductRatePlan__c productRatePlanRecord = new zqu__ProductRatePlan__c(Name='Test Product Rate Plan'+i, RatePlanCode__c='TestRatePlan'+i,
                                                                                        zqu__ZuoraId__c='ZID'+i, RatePlanType__c='Bill Plan',zqu__ZProduct__c= zProduct);
            productRatePlanList.add(productRatePlanRecord);
        }
        return productRatePlanList;
    }

    public static List<zqu__ProductRatePlanCharge__c> createProductRatePlanCharge(Integer numProductRatePlanCharges) {
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
    
        for(Integer i=0;i<numProductRatePlanCharges;i++){
            zqu__ProductRatePlanCharge__c productRatePlanChargeRecord = new zqu__ProductRatePlanCharge__c(Name='Test Product Rate Plan Charge'+i, zqu__ZuoraId__c='ZID'+i);
            productRatePlanChargeList.add(productRatePlanChargeRecord);
        }
        return productRatePlanChargeList;
    }   
    
    public static List<Package__c> createPackage(Integer numPackages) {
        List<Package__c> packageList = new List<Package__c>();
    
        for(Integer i=0;i<numPackages;i++){
            Package__c packageRecord = new Package__c(Name='Test Package'+i, Package_Type__c='Base',
                                                      Subscription_Type__c='Termed', Package_Code__c='PackageCode'+i,
                                                      Effective_Start_Date__c=date.today(), Effective_End_Date__c=date.today()+100, Subscription_Period__c='18');
            packageList.add(packageRecord);
        }
        return packageList;
    }

    public static List<Package_Item__c> createPackageItem(Integer numPackageItems, String recType) {
        List<Package_Item__c> packageItemList = new List<Package_Item__c>();
        List<RecordType> rt = [SELECT id, Name FROM RecordType WHERE SobjectType='Package_Item__c' AND Name=: recType LIMIT 1];
    
        for(Integer i=0;i<numPackageItems;i++){
            Package_Item__c packageItemRecord = new Package_Item__c(Name='Test Package Item'+i, RecordTypeId = rt[0].id);
            
            if(recType == 'Bundle Discount'){
                packageItemRecord.Bundle_Item_No__c=8;
                packageItemRecord.Duration_in_months__c='10';
                packageItemRecord.Effective_Start_Month__c='1';
            }
            else if(recType == 'Bundle Product'){
                packageItemRecord.Bundle_Item_No__c=8;
            }
            else if(recType == 'Discount'){
                packageItemRecord.Duration_in_months__c='10';
                packageItemRecord.Effective_Start_Month__c='1';
            }
            //else if(recType == 'Discount'){
            //    packageItemRecord.Duration_in_months__c='10';
            else if(recType == 'Base Product'){
                packageItemRecord.Duration_in_months__c='10';
                packageItemRecord.Effective_Start_Month__c='1';
            }
            else if(recType == 'Extension Product'){
                packageItemRecord.Duration_in_months__c='10';
            }                                                            
            packageItemList.add(packageItemRecord);
        }
        return packageItemList;
    }   

    public static List<Promotion__c> createPromotion(Integer numPromotions) {
        List<Promotion__c> promotionList = new List<Promotion__c>();
    
        for(Integer i=0;i<numPromotions;i++){
            Promotion__c promotionRecord = new Promotion__c(Name='Test Promotion'+i, Promotion_Code__c='PC'+i, 
                                                            Contract__c='Yes', Effective_End_Date__c=date.today()+100, 
                                                            Effective_Start_Date__c=date.today());
            promotionList.add(promotionRecord);
        }
        return promotionList;
    }   

    public static List<Promotion_Package__c> createPromotionPackage(Integer numPromotionPackages) {
        List<Promotion_Package__c> promotionPackageList = new List<Promotion_Package__c>();
    
        for(Integer i=0;i<numPromotionPackages;i++){
            Promotion_Package__c promotionPackageRecord = new Promotion_Package__c(/**Name='Test Promotion Package'+i*/);
            promotionPackageList.add(promotionPackageRecord);
        }
        return promotionPackageList;
    }
    
    public static List<Promotion__c> createPromoList(Integer numPromo){
        List<Promotion__c> promoList = new List<Promotion__c>();
        
        for(Integer i=0;i<numPromo;i++){
            Promotion__c promoRecord = new Promotion__c(Name='Test Promo'+i);
            promoList.add(promoRecord);
        }
        return promoList;        
    }
    
    public static User prepareTestusers() {
        
        // Start JohnD -
        Id profileId = [select Id from Profile where Name = 'System Administrator'].Id;
        system.debug('Johnxxxx :: ' + profileId);
        return new User(
            Alias = 'standard',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profileId, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
        // End JohnD
    }
    
    public static User prepareTestusers(String profName) {
        Profile prof = [Select Id From Profile Where Name =: profName Limit 1];
        return new User(
            Alias = 'standard',
            Email='standarduser@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = prof.id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userstand3541987*@testorg.com'
        );
    }
    
    public static List<Promotion_Gift__c> createPromotionGift(Integer numPromotionPackageGifts) {
        List<Promotion_Gift__c> promotionPackageGiftList = new List<Promotion_Gift__c>();
    
        for(Integer i=0;i<numPromotionPackageGifts;i++){
            Promotion_Gift__c promotionPackageGiftRecord = new Promotion_Gift__c(Gift_Inventory__c=1000,
                                                                                 Gift_Issued__c=100, Gift_Redeemed__c=100);
            promotionPackageGiftList.add(promotionPackageGiftRecord);
        }
        return promotionPackageGiftList;
    }   

    public static List<Gift__c> createGift(Integer numGifts) {
        List<Gift__c> giftList = new List<Gift__c>();
    
        for(Integer i=0;i<numGifts;i++){
            Gift__c giftRecord = new Gift__c(Name='Test Gift'+i, Gift_Code__c='GC'+i,
                                             Gift_Type__c='FREE');
            giftList.add(giftRecord);
        }
        return giftList;
    }         
    
    public static List<Eligibility_Rule__c> createEligibilityRule(Integer numEligibilityRules) {
        List<Eligibility_Rule__c> eligibilityRuleList = new List<Eligibility_Rule__c>();
    
        for(Integer i=0;i<numEligibilityRules;i++){
            Eligibility_Rule__c eligibilityRuleRecord = new Eligibility_Rule__c(Name='Test Eligibility Rule'+i, Customer_Status__c='New Customer',
                                                                                Effective_Start_Date__c=date.today(),Effective_End_Date__c=date.today()+100);
            eligibilityRuleList.add(eligibilityRuleRecord);
        }
        return eligibilityRuleList;
    }   

    public static List<Promotion_Eligibility_Rule__c> createPromEligibilityRule(Integer numPromEligibilityRules) {
        List<Promotion_Eligibility_Rule__c> promEligibilityRuleList = new List<Promotion_Eligibility_Rule__c>();
    
        for(Integer i=0;i<numPromEligibilityRules;i++){
            Promotion_Eligibility_Rule__c promEligibilityRuleRecord = new Promotion_Eligibility_Rule__c(Product_Family__c='ST',
                                                                                                        Current_Platform__c='Online');
            promEligibilityRuleList.add(promEligibilityRuleRecord);
        }
        return promEligibilityRuleList;
    }        

    public static List<Order_Line_Item_Gift__c> createItemGift(Integer numOrderLineItemGifts) {
        List<Order_Line_Item_Gift__c> orderLineItemGiftList = new List<Order_Line_Item_Gift__c>();
    
        for(Integer i=0;i<numOrderLineItemGifts;i++){
            Order_Line_Item_Gift__c orderLineItemGiftRecord = new Order_Line_Item_Gift__c();
            orderLineItemGiftList.add(orderLineItemGiftRecord);
        }
        return orderLineItemGiftList;
    }  

    public static List<Order_Line_Item__c> createOrderLineItem(Integer numOrderLineItems) {
        List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();

        integer termLength = 12;
        date startDate = date.today().addDays(1);
        date endDate = startDate.addMonths(termLength);
    
        for(Integer i=0;i<numOrderLineItems;i++){
            Order_Line_Item__c orderLineItemRecord = new Order_Line_Item__c(New_Contract_Period__c=30, DTL_Date__c=date.today(),
                                                                            Earliest_Start_Date__c=date.today(), Start_Date__c=startDate, 
                                                                            End_Date__c=endDate, Main_Package_Period__c=termLength,
                                                                            Qty__c=100, /*Subscription_Rate__c=100,*/ Term_Length__c=termLength,
                                                                            Delivered_By__c='Vendor', Main_Package_Billing_Type__c='Full Prepaid',
                                                                            Main_Package_Frequency__c='Default', Main_Package_Sub_Type__c='Termed',
                                                                            Is_Digital__c = true,
                                                                            Main_Package_Type__c='Base'); 
            orderLineItemList.add(orderLineItemRecord);
        }
        return orderLineItemList;
    }   
    
    public static List<Subscription_Vendor_Publication__c> createSubVendorPublication(Integer numSubVendorPublications) {
        List<Subscription_Vendor_Publication__c> subVendorPublicationList = new List<Subscription_Vendor_Publication__c>();
    
        for(Integer i=0;i<numSubVendorPublications;i++){
            Subscription_Vendor_Publication__c subVendorPublicationRecord = new Subscription_Vendor_Publication__c(Mon__c=1,Tue__c=1,Wed__c=1,Thu__c=1,
                                                                                                                   Fri__c=1,Sat__c=1,Sun__c=1,PHd__c=1,PHe__c=1);
            subVendorPublicationList.add(subVendorPublicationRecord);
        }
        return subVendorPublicationList;
    } 
    
    public static List<Asia1__c> createAsiaOne(Integer numAsiaOne) {
        List<Asia1__c> asiaOneList = new List<Asia1__c>();
    
        for(Integer i=0;i<numAsiaOne;i++){
            Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='Test Asia One1'+i, Email__c='testasiaone'+i+'@email.com');
            asiaOneList.add(asiaOneRecord);
        }
        return asiaOneList;
    }   

    public static List<Asia1_Subscription__c> createAsiaOneSubscription(Integer numAsiaOneSubscriptions) {
        List<Asia1_Subscription__c> asiaOneSubscriptionList = new List<Asia1_Subscription__c>();
    
        for(Integer i=0;i<numAsiaOneSubscriptions;i++){
            Asia1_Subscription__c asiaOneSubscriptionRecord = new Asia1_Subscription__c(Status__c='Enabled');
            asiaOneSubscriptionList.add(asiaOneSubscriptionRecord);
        }
        return asiaOneSubscriptionList;
    } 

    public static List<Address__c> createAddress(Integer numAddresses) {
        List<Address__c> addressList = new List<Address__c>();
    //test
        List<Country__c> countryList = createCountry(1);
        insert countryList;
        for(Integer i=0;i<numAddresses;i++){
            Address__c addressRecord = new Address__c(Name=i + 'Test Address', country__c=countryList[0].id);            
            //addressRecord.country__c = countryList[0].id;
            addressList.add(addressRecord);
        }
        return addressList;
    //test
    }   
    
    public static List<Country__c> createCountry(Integer numCountries) {
        List<Country__c> countryList = new List<Country__c>();
    
        for(Integer i=0;i<numCountries;i++){
            Country__c countryRecord = new Country__c(Name='Test Country'+i, Country_Name__c='Country Test'+i);
            countryList.add(countryRecord);
        }
        return countryList;
    }   
    
    public static List<Zone__c> createZone(Integer numZone) {
        List<Zone__c> zoneList = new List<Zone__c>();
    
        for(Integer i=0;i<numZone;i++){
            Zone__c zoneRecord = new Zone__c(Name='Test Zone'+i);
            zoneList.add(zoneRecord);
        }
        return zoneList;
    } 

    public static List<Case_Subscription__c> createCaseSubscription(Integer numCaseSubscriptions) {
        List<Case_Subscription__c> caseSubscriptionList = new List<Case_Subscription__c>();
    
        for(Integer i=0;i<numCaseSubscriptions;i++){
            Case_Subscription__c caseSubscriptionRecord = new Case_Subscription__c();
            caseSubscriptionList.add(caseSubscriptionRecord);
        }
        return caseSubscriptionList;
    }   
    
    public static List<Case_Vendor_Subscription__c> createCaseVendorSub(Integer numCaseVendorSubscriptions) {
        List<Case_Vendor_Subscription__c> caseVendorSubscriptionList = new List<Case_Vendor_Subscription__c>();
    
        for(Integer i=0;i<numCaseVendorSubscriptions;i++){
            Case_Vendor_Subscription__c caseVendorSubscriptionRecord = new Case_Vendor_Subscription__c();
            caseVendorSubscriptionList.add(caseVendorSubscriptionRecord);
        }
        return caseVendorSubscriptionList;
    }   
    
    public static List<City__c> createCity(Integer numCities) {
        List<City__c> cityList = new List<City__c>();
    
        for(Integer i=0;i<numCities;i++){
            City__c cityRecord = new City__c(Name='Test City'+i);
            cityList.add(cityRecord);
        }
        return cityList;
    }   

    public static List<Digital_Complaint_Items__c> createDigitalComplaintItem(Integer numDigitalComplaintItems, String recType) {
        List<Digital_Complaint_Items__c> digitalComplaintItemList = new List<Digital_Complaint_Items__c>();
        List<RecordType> rt = [SELECT id, Name FROM RecordType WHERE SobjectType='Digital_Complaint_Items__c' AND Name=: recType LIMIT 1];
        
        for(Integer i=0;i<numDigitalComplaintItems;i++){
            Digital_Complaint_Items__c digitalComplaintItemRecord = new Digital_Complaint_Items__c(Name='Test Digital Complaint'+i, RecordTypeId = rt[0].id);
        
            if(recType == 'Deactivate User'){
                digitalComplaintItemRecord.First_Name__c='Test First Name'+i;
                digitalComplaintItemRecord.Last_Name__c='Test Last Name'+i;
                digitalComplaintItemRecord.Email__c='testdigitalcomplaint'+i+'@email.com';
            }
            else if(recType == 'Force Logout'){
                digitalComplaintItemRecord.SPH_Online_User_Id__c='TestUserId'+i;
            } 
            else if(recType == 'Reset Password'){
                digitalComplaintItemRecord.SPH_Online_User_Id__c='TestUserId'+i;
                digitalComplaintItemRecord.New_Password__c='testpassword'+i;
            } 

            digitalComplaintItemList.add(digitalComplaintItemRecord);
        }
        return digitalComplaintItemList;
    }   
    
    public static List<External_Payment__c> createExternalPayment(Integer numExternalPayments) {
        List<External_Payment__c> externalPaymentList = new List<External_Payment__c>();
    
        for(Integer i=0;i<numExternalPayments;i++){
            External_Payment__c externalPaymentRecord = new External_Payment__c(Name='Test External Payment'+i,
                                                                                Transaction_Date__c=date.today(),
                                                                                Transaction_Amount__c=100.00);
            externalPaymentList.add(externalPaymentRecord);
        }
        return externalPaymentList;
    }
    
    public static List<Product_Publication__c> createProductPublication(Integer numProductPublications) {
        List<Product_Publication__c> productPublicationList = new List<Product_Publication__c>();
    
        for(Integer i=0;i<numProductPublications;i++){
            Product_Publication__c productPublicationRecord = new Product_Publication__c();
            productPublicationList.add(productPublicationRecord);
        }
        return productPublicationList;
    }

    public static List<Project__c> createProject(Integer numProjects) {
        List<Project__c> projectList = new List<Project__c>();
    
        for(Integer i=0;i<numProjects;i++){
            Project__c projectRecord = new Project__c(Name='Test Project'+i, Project_Description__c='Test Description'+i);
            projectList.add(projectRecord);
        }
        return projectList;
    }
    
    public static List<Publication_Mapping__c> createPublicationMapping(Integer numPublicationMappings) {
        List<Publication_Mapping__c> publicationMappingList = new List<Publication_Mapping__c>();
    
        for(Integer i=0;i<numPublicationMappings;i++){
            Publication_Mapping__c publicationMappingRecord = new Publication_Mapping__c(Direct_Subscription_Mailing_Agents__c=TRUE, Direct_Subscription__c=TRUE,
                                                                                         Vendor_Subscription_Mailing_Agents__c=FALSE, Vendor_Subscription__c=FALSE);
            publicationMappingList.add(publicationMappingRecord);
        }
        return publicationMappingList;
    }
       
    public static List<Service_Access_Flag__c> createServiceAccessFlag(Integer numSvcAccessFlags) {
        List<Service_Access_Flag__c> svcAccessFlagList = new List<Service_Access_Flag__c>();
    
        for(Integer i=0;i<numSvcAccessFlags;i++){
            Service_Access_Flag__c svcAccessFlagRecord = new Service_Access_Flag__c(Name='Test Service Access Flag'+i);
            svcAccessFlagList.add(svcAccessFlagRecord);
        }
        return svcAccessFlagList;
    }   
    
    public static List<Subscription_Vendor__c> createSubscriptionVendor(Integer numSubscriptionVendors) {
        List<Subscription_Vendor__c> subscriptionVendorList = new List<Subscription_Vendor__c>();
    
        for(Integer i=0;i<numSubscriptionVendors;i++){
            Subscription_Vendor__c subscriptionVendorRecord = new Subscription_Vendor__c();
            subscriptionVendorList.add(subscriptionVendorRecord);
        }
        return subscriptionVendorList;
    }
    
    public static List<Zuora__SubscriptionProductCharge__c> createSubscriptionProductCharge(Integer numSubscriptionProductCharge){
        List<Zuora__SubscriptionProductCharge__c> subscriptionProductChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        
        for(Integer i=0;i<numSubscriptionProductCharge;i++){
            Zuora__SubscriptionProductCharge__c subscriptionProductCharge = new Zuora__SubscriptionProductCharge__c();
            subscriptionProductChargeList.add(subscriptionProductCharge);
        }
        return subscriptionProductChargeList;
    }
    
    public static List<Package_Access_Flag__c> createPackageAccessFlag(Integer numPackageAccessFlags) {
        List<Package_Access_Flag__c> packageAccessFlagList = new List<Package_Access_Flag__c>();
    
        for(Integer i=0;i<numPackageAccessFlags;i++){
            Package_Access_Flag__c packageAccessFlagRecord = new Package_Access_Flag__c();
            packageAccessFlagList.add(packageAccessFlagRecord);
        }
        return packageAccessFlagList;
    }   
    
    public static List<Order_Line_Item_Vendor__c> createOrderLineItemVendor(Integer numOrderLineItemVendor) {
        List<Order_Line_Item_Vendor__c> orderLineItemVendorList = new List<Order_Line_Item_Vendor__c>();
    
        for(Integer i=0;i<numOrderLineItemVendor;i++){
            Order_Line_Item_Vendor__c orderLineItemVendorRecord = new Order_Line_Item_Vendor__c(Mon__c=1,Tue__c=1,Wed__c=1,Thu__c=1,
                                                                                                Fri__c=1,Sat__c=1,Sun__c=1,PHd__c=1,PHe__c=1,
                                                                                                Start_Date__c=date.today()+2);
            orderLineItemVendorList.add(orderLineItemVendorRecord);
        }
        return orderLineItemVendorList;
    }   
    
    public static List<Zuora__CrmId_Change_Result__c> createCrmIdChangeResult(Integer numCrmIdChangeResults) {
        List<Zuora__CrmId_Change_Result__c> crmIdChangeResultList = new List<Zuora__CrmId_Change_Result__c>();
        
        for(Integer i=0;i<numCrmIdChangeResults;i++){
            Zuora__CrmId_Change_Result__c  crmIdChangeResultRecord = new Zuora__CrmId_Change_Result__c(Name='CrmId'+i);
            crmIdChangeResultList.add(crmIdChangeResultRecord);
        }
        return crmIdChangeResultList;
    } 
    
    public static List<zqu__Field_Set_Config__c> createFieldSetConfig(Integer numFieldSetConfigs) {
        List<zqu__Field_Set_Config__c> fieldSetConfigList = new List<zqu__Field_Set_Config__c>();
        
        for(Integer i=0;i<numFieldSetConfigs;i++){
            zqu__Field_Set_Config__c  fieldSetConfigRecord = new zqu__Field_Set_Config__c(Name='Test Field Set Config'+i);
            fieldSetConfigList.add(fieldSetConfigRecord);
        }
        return fieldSetConfigList;
    }
    
    public static List<zqu__Format_Object__c> createFormatObject(Integer numFormatObjects) {
        List<zqu__Format_Object__c> formatObjectList = new List<zqu__Format_Object__c>();
        
        for(Integer i=0;i<numFormatObjects;i++){
            zqu__Format_Object__c  formatObjectRecord = new zqu__Format_Object__c(Name='Test Format Object'+i);
            formatObjectList.add(formatObjectRecord);
        }
        return formatObjectList;
    }
    
    public static List<zqu__Hosted_Page_Setting__c> createHostedPageSetting(Integer numHostedPageSettings) {
        List<zqu__Hosted_Page_Setting__c> hostedPageSettingList = new List<zqu__Hosted_Page_Setting__c>();
        
        for(Integer i=0;i<numHostedPageSettings;i++){
            zqu__Hosted_Page_Setting__c  hostedPageSettingRecord = new zqu__Hosted_Page_Setting__c(Name='Test Hosted Page Setting'+i, 
                                                                                                   zqu__App_URL__c='www.testhostedpage'+i+'.com');
            hostedPageSettingList.add(hostedPageSettingRecord);
        }
        return hostedPageSettingList;
    }
    
    public static List<Zuora__ZInvoice__c> createInvoice(Integer numInvoice) {
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
        
        for(Integer i=0;i<numInvoice;i++){
            Zuora__ZInvoice__c  invoiceRecord = new Zuora__ZInvoice__c(Name='Test Invoice'+i, 
                                                                       Zuora__Zuora_Id__c='ZID'+i);
            invoiceList.add(invoiceRecord);
        }
        return invoiceList;
    }   
    
    public static List<Zuora__PaymentInvoice__c> createInvoicePayment(Integer numInvoicePayments) {
        List<Zuora__PaymentInvoice__c> invoicePaymentList = new List<Zuora__PaymentInvoice__c>();
        
        for(Integer i=0;i<numInvoicePayments;i++){
            Zuora__PaymentInvoice__c  invoicePaymentRecord = new Zuora__PaymentInvoice__c(Zuora__ApplyAmount__c=100.00);
            invoicePaymentList.add(invoicePaymentRecord);
        }
        return invoicePaymentList;
    }   
    
    public static List<zqu__List_Filter__c> createListFilter(Integer numListFilters) {
        List<zqu__List_Filter__c> listfilterList = new List<zqu__List_Filter__c>();
        
        for(Integer i=0;i<numListFilters;i++){
            zqu__List_Filter__c  listFilterRecord = new zqu__List_Filter__c(Name='Test Filter Name'+i);
            listfilterList.add(listFilterRecord);
        }
        return listfilterList;
    }   

    public static List<zqu__List_Filter_Item__c> createListFilterItem(Integer numListFilterItems) {
        List<zqu__List_Filter_Item__c> listfilterItemList = new List<zqu__List_Filter_Item__c>();
        
        for(Integer i=0;i<numListFilterItems;i++){
            zqu__List_Filter_Item__c  listFilterItemRecord = new zqu__List_Filter_Item__c(Name='Test List Filter Item Name'+i);
            listfilterItemList.add(listFilterItemRecord);
        }
        return listfilterItemList;
    }
    
    public static List<Zuora__ObjectStub__c> createObjectStub(Integer numObjectStubs) {
        List<Zuora__ObjectStub__c> objectStubList = new List<Zuora__ObjectStub__c>();
        
        for(Integer i=0;i<numObjectStubs;i++){
            Zuora__ObjectStub__c  objectStubRecord = new Zuora__ObjectStub__c(Name='Test Object Stub'+i);
            objectStubList.add(objectStubRecord);
        }
        return objectStubList;
    }   
    
    public static List<Zuora__Payment__c> createPayment(Integer numPayments) {
        List<Zuora__Payment__c> paymentList = new List<Zuora__Payment__c>();
        
        for(Integer i=0;i<numPayments;i++){
            Zuora__Payment__c paymentRecord = new Zuora__Payment__c(Name='TestPayment'+i, Zuora__Amount__c=100.00,
                                                                     Zuora__PaymentMethod__c='Payment Method'+i, Zuora__EffectiveDate__c=date.today());
            paymentList.add(paymentRecord);
        }
        return paymentList;
    }   
    
    public static List<Zuora__PaymentMethod__c> createPaymentMethod(Integer numPaymentMethods) {
        List<Zuora__PaymentMethod__c> paymentMethodList = new List<Zuora__PaymentMethod__c>();
        
        for(Integer i=0;i<numPaymentMethods;i++){
            Zuora__PaymentMethod__c  paymentMethodRecord = new Zuora__PaymentMethod__c(Name='Test Payment Method'+i);
            paymentMethodList.add(paymentMethodRecord);
        }
        return paymentMethodList;
    }       
    
    public static List<Zuora__PaymentTerm__c> createPaymentTerm(Integer numPaymentTerms) {
        List<Zuora__PaymentTerm__c> paymentTermList = new List<Zuora__PaymentTerm__c>();
        
        for(Integer i=0;i<numPaymentTerms;i++){
            Zuora__PaymentTerm__c  paymentTermRecord = new Zuora__PaymentTerm__c(Name='Test Payment Term'+i);
            paymentTermList.add(paymentTermRecord);
        }
        return paymentTermList;
    }       
    
    public static List<zqu__ProductRatePlanChargeTier__c> createProductRatePlanChargeTier(Integer numProductRatePlan) {
        List<zqu__ProductRatePlanChargeTier__c> productRatePlanList = new List<zqu__ProductRatePlanChargeTier__c>();
        
        for(Integer i=0;i<numProductRatePlan;i++){
            zqu__ProductRatePlanChargeTier__c productRatePlanRecord = new zqu__ProductRatePlanChargeTier__c(Name='Test Tier Name'+i);
            productRatePlanList.add(productRatePlanRecord);
        }
        return productRatePlanList;
    }   
    
    public static List<zqu__Quote__c> createQuote(Integer numQuotes) {
        List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
        
        for(Integer i=0;i<numQuotes;i++){
            zqu__Quote__c quoteRecord = new zqu__Quote__c(Name='Test Quote Name'+i);
            quoteList.add(quoteRecord);
        }
        return quoteList;
    }   
    
    public static List<zqu__QuoteAmendment__c> createQuoteAmendment(Integer numQuoteAmendments) {
        List<zqu__QuoteAmendment__c> quoteAmendmentList = new List<zqu__QuoteAmendment__c>();
        
        for(Integer i=0;i<numQuoteAmendments;i++){
            zqu__QuoteAmendment__c quoteAmendmentRecord = new zqu__QuoteAmendment__c(Name='Test Quote Amendment Name'+i);
            quoteAmendmentList.add(quoteAmendmentRecord);
        }
        return quoteAmendmentList;
    }   
    
    public static List<zqu__QuoteCharge__c> createQuoteCharge(Integer numQuoteCharges) {
        List<zqu__QuoteCharge__c> quoteChargeList = new List<zqu__QuoteCharge__c>();
        
        for(Integer i=0;i<numQuoteCharges;i++){
            zqu__QuoteCharge__c quoteChargeRecord = new zqu__QuoteCharge__c(Name='Test Quote Charge Name'+i);
            quoteChargeList.add(quoteChargeRecord);
        }
        return quoteChargeList;
    }
    
    public static List<zqu__QuoteChargeSummary__c> createQuoteChargeSummary(Integer numQuoteChargeSummary) {
        List<zqu__QuoteChargeSummary__c> quoteChargeSummaryList = new List<zqu__QuoteChargeSummary__c>();
        
        for(Integer i=0;i<numQuoteChargeSummary;i++){
            zqu__QuoteChargeSummary__c quoteChargeSummaryRecord = new zqu__QuoteChargeSummary__c(Name='Test Quote Charge Summary Name'+i);
            quoteChargeSummaryList.add(quoteChargeSummaryRecord);
        }
        return quoteChargeSummaryList;
    }

    public static List<zqu__QuoteCharge_Tier__c> createQuoteChargeTier(Integer numQuoteChargeTiers) {
        List<zqu__QuoteCharge_Tier__c> quoteChargeTierList = new List<zqu__QuoteCharge_Tier__c>();
        
        for(Integer i=0;i<numQuoteChargeTiers;i++){
            zqu__QuoteCharge_Tier__c quoteChargeTierRecord = new zqu__QuoteCharge_Tier__c(Name='Test Quote Charge Tier Name'+i);
            quoteChargeTierList.add(quoteChargeTierRecord);
        }
        return quoteChargeTierList;
    }

    public static List<zqu__Quote_Processing_Data__c> createQuoteProcessingData(Integer numQuoteProcessingData) {
        List<zqu__Quote_Processing_Data__c> quoteProcessingDataList = new List<zqu__Quote_Processing_Data__c>();
        
        for(Integer i=0;i<numQuoteProcessingData;i++){
            zqu__Quote_Processing_Data__c quoteProcessingDataRecord = new zqu__Quote_Processing_Data__c(zqu__Data_Key__c='DK'+i, zqu__Session_Id__c='SID'+i);
            quoteProcessingDataList.add(quoteProcessingDataRecord);
        }
        return quoteProcessingDataList;
    }   
    
    public static List<zqu__QuoteRatePlan__c> createQuoteRatePlan(Integer numQuoteRatePlans) {
        List<zqu__QuoteRatePlan__c> quoteRatePlanList = new List<zqu__QuoteRatePlan__c>();
        
        for(Integer i=0;i<numQuoteRatePlans;i++){
            zqu__QuoteRatePlan__c quoteRatePlanRecord = new zqu__QuoteRatePlan__c(Name='Quote Rate Plan'+i);
            quoteRatePlanList.add(quoteRatePlanRecord);
        }
        return quoteRatePlanList;
    }

    public static List<zqu__QuoteRatePlanCharge__c> createQuoteRatePlanCharge(Integer numQuoteRatePlanCharges) {
        List<zqu__QuoteRatePlanCharge__c> quoteRatePlanChargeList = new List<zqu__QuoteRatePlanCharge__c>();
        
        for(Integer i=0;i<numQuoteRatePlanCharges;i++){
            zqu__QuoteRatePlanCharge__c quoteRatePlanChargeRecord = new zqu__QuoteRatePlanCharge__c(Name='Quote Rate Plan Charge'+i);
            quoteRatePlanChargeList.add(quoteRatePlanChargeRecord);
        }
        return quoteRatePlanChargeList;
    }
    
    public static List<zqu__QuoteTCVStatus__c> createQuoteTcvStatus(Integer numQuoteTcvStatus) {
        List<zqu__QuoteTCVStatus__c> quoteTcvStatusList = new List<zqu__QuoteTCVStatus__c>();
        
        for(Integer i=0;i<numQuoteTcvStatus;i++){
            zqu__QuoteTCVStatus__c quoteTcvStatusRecord = new zqu__QuoteTCVStatus__c();
            quoteTcvStatusList.add(quoteTcvStatusRecord);
        }
        return quoteTcvStatusList;
    }   

    public static List<zqu__Quote_Template__c> createQuoteTemplate(Integer numTemplates) {
        List<zqu__Quote_Template__c> quoteTemplateList = new List<zqu__Quote_Template__c>();
        
        for(Integer i=0;i<numTemplates;i++){
            zqu__Quote_Template__c quoteTemplateRecord = new zqu__Quote_Template__c(Name='Test Quote Template'+i, zqu__Template_Id__c='QTID'+i,
                                                                                    zqu__Quote_Type__c='New Subscription');
            quoteTemplateList.add(quoteTemplateRecord);
        }
        return quoteTemplateList;
    }
    
    public static List<zqu__QuoteWizardStep__c> createQuoteWizardStep(Integer numQuoteWizardSteps) {
        List<zqu__QuoteWizardStep__c> quoteWizardStepList = new List<zqu__QuoteWizardStep__c>();
        
        for(Integer i=0;i<numQuoteWizardSteps;i++){
            zqu__QuoteWizardStep__c quoteWizardStepRecord = new zqu__QuoteWizardStep__c(Name='Test Quote Wizard'+i, zqu__BackButtonText__c='Back'+i,
                                                                                        zqu__NextButtonText__c='Next'+i, zqu__ProgressBarText__c='Progress'+i,
                                                                                        zqu__StepNumber__c=1, zqu__SubscriptionType__c='New Subscription',
                                                                                        zqu__PageName__c='testpagename'+i);
            quoteWizardStepList.add(quoteWizardStepRecord);
        }
        return quoteWizardStepList;
    }
    
    public static List<zqu__ZProduct__c> createZProduct(Integer numZProducts) {
        List<zqu__ZProduct__c> zProductList = new List<zqu__ZProduct__c>();
        
        for(Integer i=0;i<numZProducts;i++){
            zqu__ZProduct__c zProductRecord = new zqu__ZProduct__c(Name='Test Quote Wizard'+i, zqu__SKU__c='SKU'+i,
                                                                   ProductCode__c='Product Code'+i, zqu__ZuoraId__c='ZID'+i,
                                                                   ProductType__c='Product Type'+i,ProductPlatform__c = 'Online'); 
            zProductList.add(zProductRecord);
        }
        return zProductList;
    }   
    
    public static List<Zuora__UnitOfMeasure__c> createUnitOfMeasure(Integer numUnitOfMeasure) {
        List<Zuora__UnitOfMeasure__c> unitOfMeasureList = new List<Zuora__UnitOfMeasure__c>();
        
        for(Integer i=0;i<numUnitOfMeasure;i++){
            Zuora__UnitOfMeasure__c unitOfMeasureRecord = new Zuora__UnitOfMeasure__c(Name='Test Unit of Measure'+i);
            unitOfMeasureList.add(unitOfMeasureRecord);
        }
        return unitOfMeasureList;
    }   
    
    public static List<zqu__ZUnitOfMeasure__c> createZUnitOfMeasure(Integer numZUnitOfMeasure) {
        List<zqu__ZUnitOfMeasure__c> zUnitOfMeasureList = new List<zqu__ZUnitOfMeasure__c>();
        
        for(Integer i=0;i<numZUnitOfMeasure;i++){
            zqu__ZUnitOfMeasure__c zUnitOfMeasureRecord = new zqu__ZUnitOfMeasure__c(Name='Test Unit of Measure'+i, zqu__ZuoraId__c='ZID'+i,
                                                                                     zqu__Uom_rounding_mode__c='Up', zqu__Uom_precision__c=100);
            zUnitOfMeasureList.add(zUnitOfMeasureRecord);
        }
        return zUnitOfMeasureList;
    }
    
    public static List<Zuora__Refund__c> createRefund(Integer numRefunds) {
        List<Zuora__Refund__c> refundList = new List<Zuora__Refund__c>();
        
        for(Integer i=0;i<numRefunds;i++){
            Zuora__Refund__c refundRecord = new Zuora__Refund__c(Name='Test Refund'+i, Zuora__Amount__c=100.00);
            refundList.add(refundRecord);
        }
        return refundList;
    }   
    
    public static List<Zuora__RefundInvoicePayment__c> createRefundInvPayment(Integer numRefundInvPayments) {
        List<Zuora__RefundInvoicePayment__c> refundInvPaymentList = new List<Zuora__RefundInvoicePayment__c>();
        
        for(Integer i=0;i<numRefundInvPayments;i++){
            Zuora__RefundInvoicePayment__c refundInvPaymentRecord = new Zuora__RefundInvoicePayment__c();
            refundInvPaymentList.add(refundInvPaymentRecord);
        }
        return refundInvPaymentList;
    }       
    
    public static List<Zuora__SubscriptionProductCharge__c> createSubProductCharge(Integer numSubProductCharges) {
        List<Zuora__SubscriptionProductCharge__c> subProductChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        
        for(Integer i=0;i<numSubProductCharges;i++){
            Zuora__SubscriptionProductCharge__c subProductChargeRecord = new Zuora__SubscriptionProductCharge__c(Name='Test Subscription Product Charge'+i, 
                                                                                                                 Zuora__Zuora_Id__c='ZID'+i);
            subProductChargeList.add(subProductChargeRecord);
        }
        return subProductChargeList;
    }   
    
    public static List<Zuora__Sync_History__c> createSyncHistory(Integer numSyncHistory) {
        List<Zuora__Sync_History__c> syncHistoryList = new List<Zuora__Sync_History__c>();
        
        for(Integer i=0;i<numSyncHistory;i++){
            Zuora__Sync_History__c syncHistoryRecord = new Zuora__Sync_History__c(Name='Test Sync History'+i);
            syncHistoryList.add(syncHistoryRecord);
        }
        return syncHistoryList;
    }
    
    public static List<Publication_Price__c> createPublicationPrice(integer numPubPrice){
        List<Publication_Price__c> pubPriceList = new List<Publication_Price__c>();
        for(Integer i=0;i<numPubPrice;i++){
            Publication_Price__c pubPrice  = new Publication_Price__c();
            pubPriceList.add(pubPrice);
        }
        return pubPriceList;
    }
    
    public static List<Non_Publication_Day__c> createNonPublicationDay(integer numNonPubDay){
        List<Non_Publication_Day__c> nonPubDayList = new List<Non_Publication_Day__c>();
        for(Integer i=0;i<numNonPubDay;i++){
            Non_Publication_Day__c nonPubDay = new Non_Publication_Day__c(Publication_Code__c='ST',
                Non_Publication_Date__c=Date.today());
            nonPubDayList.add(nonPubDay);
        }
        return nonPubDayList;
    }
    
    public static List<Vendor_Temp_Stop__c> createVendorTempStop(integer numVenTempStop){
        List<Vendor_Temp_Stop__c> venTempStopList = new List<Vendor_Temp_Stop__c>();
        for(Integer i=0;i<numVenTempStop;i++){
            Vendor_Temp_Stop__c venTempStop = new Vendor_Temp_Stop__c();
            venTempStopList.add(venTempStop);
        }
        return venTempStopList;
    }
    
    public static List<Temp_Stop__c> createTempStop(integer numTempStop){
        List<Temp_Stop__c> tempStopList = new List<Temp_Stop__c>();
        for(Integer i=0;i<numTempStop;i++){
            Temp_Stop__c tempStop = new Temp_Stop__c();
            tempStopList.add(tempStop);
        }
        return tempStopList;
    }
    
    public static List<Vendor_POP_Batch__c> createVendorPopBatch(integer numVenPopBatch){
        List<Vendor_POP_Batch__c> venPopBatchList= new List<Vendor_POP_Batch__c>();
        for(Integer i=0;i<numVenPopBatch;i++){
            Vendor_POP_Batch__c venPopBatch = new Vendor_POP_Batch__c(Subscription_Name__c = 'Subscription Name'+i,
                Publication_Issue_Date__c = Date.Today(), Total_Direct_Subscriptions__c = 1, Publication_Code__c='Publication Code'+i, 
                Vendor_Group__c='Vendor Group'+i, Vendor_Number__c='Vendor Number'+i, Total_Sponsored_Copies__c = 1, 
                Total_Local_Freelist_Copies__c = 1,  Total_Local_Subscription_Copies__c = 1,  Total_Overseas_Freelist_Copies__c = 1, 
                Total_Overseas_Subscription_Copies__c = 1);
            venPopBatchList.add(venPopBatch);
        }
        return venPopBatchList;
    }

    // JOY
    /*
    Vendor_POP_Batch__c vendorPopBatch = new Vendor_POP_Batch__c();
        Subscription_Name__c = 'Subscription Name'+i
        Publication_Issue_Date__c = Date.Today(),
        Total_Direct_Subscriptions__c = 1,
        Publication_Code__c='Publication Code'+i, 
        Vendor_Group__c='Vendor Group'+i,
        Vendor_Number__c='Vendor Number'+i,
        Total_Sponsored_Copies__c = 1, 
        Total_Local_Freelist_Copies__c = 1, 
        Total_Local_Subscription_Copies__c = 1, 
        Total_Overseas_Freelist_Copies__c = 1, 
        Total_Overseas_Subscription_Copies__c = 1
    */
    
    public static Map<String, SObject> createSubscriptionPackage(){
        Map<String, SObject> objectMap = new Map<String, SObject>(); 
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        //insert postal;
       
        objectMap.put('Singpost_Address__c', postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        //insert acc;
        
        objectMap.put('Account', acc);
        

        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        //insert pack;
        
        objectMap.put('Package__c', pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        //insert zProduct;
        
        objectMap.put('zqu__ZProduct__c', zProduct);
        
        insert objectMap.values();
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        objectMap.put('Package_Item__c', pItem);   
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        insert billAcc;
        
        objectMap.put('Zuora__CustomerAccount__c', billAcc);   
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        
        objectMap.put('Address__c', addressRec);   
        
        //Query contact record type
        Map<String, Id> recMap = getRecordTypes();

        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = recMap.get('Customer_Contact');//ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        try{
        insert con;
        }catch(exception e){}
        objectMap.put('Recipient Contact', con);   
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = recMap.get('Customer_Contact');//ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        try{
        insert con1;
        }catch(exception e){}
        objectMap.put('Billing Contact', con1);   
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        //order.Postage_Charge__c = 200.00;
        insert order;
        
        objectMap.put('Order__c', order);   
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        objectMap.put('Case', cas);   
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.Earliest_Start_Date__c = Date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE; //changed by JJZS
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        objectMap.put('Order_Line_Item__c', orderline);  

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Generate_Invoice1__c = 'false';
        objectMap.put('Zuora__Subscription__c', subRecs);  
        system.debug('rrrrrrrrrrrrrrrrrrrrrr object map'+objectMap);
        return objectMap;
    }

    public static Map<String, SObject> createSubscriptionPackageUpdated(){
        Map<String, SObject> objectMap = new Map<String, SObject>(); 
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        //insert postal;
       
        objectMap.put('Singpost_Address__c', postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        //insert acc;
        
        objectMap.put('Account', acc);
        

        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        //insert pack;
        
        objectMap.put('Package__c', pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        //insert zProduct;
        
        objectMap.put('zqu__ZProduct__c', zProduct);
        
        insert objectMap.values();
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Bill Plan';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        objectMap.put('Package_Item__c', pItem);   
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other'; //added by jjzs
        insert billAcc;
        
        objectMap.put('Zuora__CustomerAccount__c', billAcc);   
        
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        insert addressRec;
        
        objectMap.put('Address__c', addressRec);   
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        objectMap.put('Recipient Contact', con);   
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        objectMap.put('Billing Contact', con1);   
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        order.Billing_Type__c = billAcc.Billing_Type__c; // added by jjzs
        //order.Postage_Charge__c = 200.00;
        insert order;
        
        objectMap.put('Order__c', order);   
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        objectMap.put('Case', cas);   
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = Date.Today().addDays(100);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Start_Date__c = Date.Today().addDays(1);
        orderline.Earliest_Start_Date__c = Date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  Date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = FALSE; //changed by JJZS
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        objectMap.put('Order_Line_Item__c', orderline);  

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Order_Line_Item_Number_1__c = orderline.Id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Generate_Invoice1__c = 'false';
        subRecs.Sponsor_1__c = false;
        objectMap.put('Zuora__Subscription__c', subRecs);  
        system.debug('rrrrrrrrrrrrrrrrrrrrrr object map'+objectMap);
        return objectMap;
    }
  
    public static Map<String, SObject> createSubscriptionPackage20(){
        Map<String, SObject> objectMap = new Map<String, SObject>(); 
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        //insert postal;
        
        objectMap.put('Singpost_Address__c', postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        
        //insert acc;
        
        objectMap.put('Account', acc);
        
        Country__c country = new Country__c();
        country.Name = 'ZZ';
        country.Code__c = 'ZZ';
        country.Country_Name__c = 'ZZambia';
        
        objectMap.put('Country__c', country);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        //insert pack;
        
        objectMap.put('Package__c', pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        //insert zProduct;
        
        objectMap.put('zqu__ZProduct__c', zProduct);
        
        insert objectMap.values();
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Ptoration';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        objectMap.put('Package_Item__c', pItem);   
           
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = country.Id;
        addressRec.Address_1__c = 'Address 1';
        addressRec.Address_2__c = 'Address 2';
        addressRec.Address_3__c = 'Address 3';
        addressRec.Address_4__c = 'Address 4';
        insert addressRec;
        
        objectMap.put('Address__c', addressRec);   
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        objectMap.put('Recipient Contact', con);   
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        objectMap.put('Billing Contact', con1);   
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Billing_Contact__c = con1.id;
        insert billAcc;
        
        objectMap.put('Zuora__CustomerAccount__c', billAcc);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        //order.Postage_Charge__c = 200.00;
        insert order;
        
        objectMap.put('Order__c', order);   
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        objectMap.put('Case', cas);   
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.newInstance(2017, 12, 2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        objectMap.put('Order_Line_Item__c', orderline);  

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        
        objectMap.put('Zuora__Subscription__c', subRecs);  
        
        return objectMap;
    }

        public static Map<String, SObject> createSubscriptionPackage2(){
        Map<String, SObject> objectMap = new Map<String, SObject>(); 
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        //insert postal;
        
        objectMap.put('Singpost_Address__c', postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        
        //insert acc;
        
        objectMap.put('Account', acc);
        
        Country__c country = new Country__c();
        country.Name = 'ZZ';
        country.Code__c = 'ZZ';
        country.Country_Name__c = 'ZZambia';
        
        objectMap.put('Country__c', country);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        //insert pack;
        
        objectMap.put('Package__c', pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        //insert zProduct;
        
        objectMap.put('zqu__ZProduct__c', zProduct);
        
        insert objectMap.values();
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= 'Ptoration';
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        //insert pItem; 
        
        objectMap.put('Package_Item__c', pItem);   
           
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = country.Id;
        addressRec.Address_1__c = 'Address 1';
        addressRec.Address_2__c = 'Address 2';
        addressRec.Address_3__c = 'Address 3';
        addressRec.Address_4__c = 'Address 4';
        insert addressRec;
        
        objectMap.put('Address__c', addressRec);   
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        objectMap.put('Recipient Contact', con);   
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        objectMap.put('Billing Contact', con1);   
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Billing_Contact__c = con1.id;
        insert billAcc;
        
        objectMap.put('Zuora__CustomerAccount__c', billAcc);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        //order.Postage_Charge__c = 200.00;
        insert order;
        
        objectMap.put('Order__c', order);   
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        objectMap.put('Case', cas);   
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.newInstance(2017, 12, 2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Start_Date__c = Date.Today().addDays(2);
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(3);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        objectMap.put('Order_Line_Item__c', orderline);  

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        
        objectMap.put('Zuora__Subscription__c', subRecs);  
        
        return objectMap;
    }

    
    public static Map<String, SObject> createSubscriptionPackage3(String ratePlanType, String recordType_name, String packageType){ //modified for JJZSs 
        Map<String, SObject> objectMap = new Map<String, SObject>(); 
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        postal.Name = 'SPostal';
        postal.House_Block_Number__c = 'TEST';
        postal.Address_Type__c = 'A';
        //insert postal;
        
        objectMap.put('Singpost_Address__c', postal);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.NRIC__c = 'T1234567R';
        
        //insert acc;
        
        objectMap.put('Account', acc);
        
        Country__c country = new Country__c();
        country.Name = 'ZZ';
        country.Code__c = 'ZZ';
        country.Country_Name__c = 'ZZambia';
        
        objectMap.put('Country__c', country);
        
        Package__c pack = new Package__c();
        pack = TestDataFactory.createPackage(1)[0];
        pack.Name = 'Pack name';
        pack.Billing_Type__c = 'Full Prepaid';
        pack.Package_Type__c = 'Base';
        pack.Subscription_Period__c = '18';
        pack.Package_Code__c = 'afds132';
        //insert pack;
        
        objectMap.put('Package__c', pack);
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        //insert zProduct;
        
        objectMap.put('zqu__ZProduct__c', zProduct);
        
        insert objectMap.values();
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
        prdRatePlan.zqu__ZProduct__c = zProduct.Id;
        prdRatePlan.RatePlanType__c= ratePlanType;
        prdRatePlan.zqu__EffectiveStartDate__c= date.today();
        prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
        prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        objectMap.put('zqu__ProductRatePlan__c', prdRatePlan);
        
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        zprpc.Name = 'Product Rate Plan Charge';
        zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
        zprpc.zqu__ZuoraId__c = '3689922200';
        insert zprpc;
        
        objectMap.put('zqu__ProductRatePlanCharge__c', zprpc);
                
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prdRatePlan.id;
        pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        objectMap.put('Package_Item__c', pItem);   
           
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c = 'A';
        addressRec.Postal_Code__c = postal.Id;
        addressRec.Block_House_Number__c ='TEST';
        addressRec.Level_Number__c ='xx';
        addressRec.Unit_Number__c = 'yy';
        addressRec.Country__c = country.Id;
        addressRec.Address_1__c = 'Address 1';
        addressRec.Address_2__c = 'Address 2';
        addressRec.Address_3__c = 'Address 3';
        addressRec.Address_4__c = 'Address 4';
        insert addressRec;
        
        objectMap.put('Address__c', addressRec);   
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        insert con;
        
        objectMap.put('Recipient Contact', con);   
        
        Contact con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        insert con1;
        
        objectMap.put('Billing Contact', con1);   
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Zuora__Zuora_Id__c = '2c332123456789665f456789h65';
        billAcc.Billing_Contact__c = con1.id;
        insert billAcc;
        
        objectMap.put('Zuora__CustomerAccount__c', billAcc);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Informed_Customer__c = TRUE;
        order.Recipient_Contact__c = con.Id;
        order.Order_Type__c = 'Renewal';
        order.Status__c = 'Draft';
        order.Eligible_for_Retention__c = TRUE;
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Credit Card';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Contact__c = con1.id;
        order.Case_Record_Type__c = 'Complaint - Magazine';
        order.Category__c = 'Subscription Request';
        order.Sub_Category__c ='Stop Subscription';
        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Order_Type__c = 'Change of Subscription Package';
        order.PO_Number__c = 'PO00000';
        //order.Postage_Charge__c = 200.00;
        insert order;
        
        objectMap.put('Order__c', order);   
                    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        cas.Order__c = order.Id;
        insert cas;
        
        objectMap.put('Case', cas);   
        
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
        orderline.Order__c = order.Id;
        orderline.End_Date__c = date.newInstance(2017, 12, 2);
        orderline.Main_Package_ID__c = pack.Id;
        orderline.Term_Length__c = 0;
        orderline.Main_Package_Period__c = 0;
        orderline.Earliest_Start_Date__c = date.today();
        orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
        orderline.Stop_Request_Date__c =  date.Today().addDays(4);
        orderline.Terminating_Reason__c = 'Others';
        orderline.Amount_To_Refund__c = 0;
        orderline.Admin_Charge__c = 0;
        orderline.Fee_Waiver__c = TRUE;
        orderline.Fee_Override__c = TRUE;
        orderline.Override_Reason__c = 'TEST';
        orderline.Suppress_Notification_Stop__c = TRUE;
        orderline.Main_Package_Type__c = 'Base';
        insert orderline;
        
        objectMap.put('Order_Line_Item__c', orderline);  

        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__Account__c = acc.Id;
        subRecs.Zuora__Zuora_Id__c = '1123';
        subRecs.Zuora__SubscriptionEndDate__c = date.today().addDays(30);
        subRecs.Subscriber_Contact__c = con.Id;
        subRecs.Recipient_Contact__c = con.Id;
        subRecs.Main_Package_1__c = pack.id;
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number__c = order.Id;
        subRecs.Suppress_Vendor_Start_Notice__c = 'false';
        subRecs.Supressed_Acknowledgement_Letter__c = 'false';
        subRecs.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecs.Urgent__c = 'false';
        subRecs.Vendor_Conversion__c = 'false';
        subRecs.Charity__c = 'false';
        subRecs.Billing_Type__c = 'Full Prepaid';
        subRecs.Order_Line_Item_Number__c = orderline.id;
        subRecs.Subscription_Type_1__c = 'Publication';
        subRecs.Subscription_Type__c = 'Publication';
        subRecs.Zuora__Status__c = 'Active';
        subRecs.Order_Number_1__c = order.id;
        subRecs.Generate_Invoice1__c = 'false';
        
        objectMap.put('Zuora__Subscription__c', subRecs);  
        
        return objectMap;
    }

    // Start 20/11/2015  by Ana Fe Dumangas D-3920 fix
    public static List<BT_CO_VBS_CreditDebit__c> createBT_CO_VBS_CreditDebit(Integer numVBSCD) {
        List<BT_CO_VBS_CreditDebit__c> syncVBSCDList = new List<BT_CO_VBS_CreditDebit__c>();
        
        for(Integer i=0;i<numVBSCD;i++){
            BT_CO_VBS_CreditDebit__c syncVBSCD = new BT_CO_VBS_CreditDebit__c(Vendor_Group__c='1', Vendor_Number__c = ''+i, Publication_Code__c = 'A' +i, Posting_Date__c = date.today(), Job_Id__c = 'J'+i);
            syncVBSCDList.add(syncVBSCD);
        }
        return syncVBSCDList;
    }
    // End 20/11/2015  by Ana Fe Dumangas D-3920 fix
    
    public static List<VDC_CREDITNOTE__c> createVDC_CREDITNOTE(Integer numVBSCN) {
        List<VDC_CREDITNOTE__c> syncVBSCNList = new List<VDC_CREDITNOTE__c>();
        
        for(Integer i=0;i<numVBSCN;i++){
            VDC_CREDITNOTE__c syncVBSCN = new VDC_CREDITNOTE__c(Name = 'Sample'+i);
            syncVBSCNList.add(syncVBSCN);
        }
        return syncVBSCNList;
    }
    
    // Start 20/11/2015  by Ana Fe Dumangas D-3920 fix
    public static List<Key_Id__c> createKeyIds() {
        List<Key_Id__c> keyIdList = new List<Key_Id__c>{
            new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER',Id__c = '123462697',Type__c = 'Number')
        };
        return keyIdList;
    }
    // End 20/11/2015  by Ana Fe Dumangas D-3920 fix
    
    public static Cir_Planner_Schedule__c createCir_Planner_Schedule(){
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'Sample CIR';
        cir.Mon_Fri_End_Time__c = system.now();
        cir.Mon_Fri_Start_Time__c = system.now();
        cir.Sat_PH_End_Time__c = system.now(); 
        cir.Sat_PH_Start_Time__c = system.now();
        cir.Sun_End_Time__c = system.now();
        cir.Sun_Start_Time__c = system.now();
        
        return cir;
    }
    
    public static List<BT_CO_VSS_CreditDebit__c> createBT_CO_VSS_CreditDebit(Integer numVBSCD) {
        List<BT_CO_VSS_CreditDebit__c> syncVSSCDList = new List<BT_CO_VSS_CreditDebit__c>();
        
        for(Integer i=0;i<numVBSCD;i++){
            BT_CO_VSS_CreditDebit__c syncVSSCD = new BT_CO_VSS_CreditDebit__c(Vendor_Group__c='1', Vendor_Number__c = ''+i, Publication_Code__c = 'A' +i, Posting_Date__c = date.today(), Job_Id__c = 'J'+i);
            syncVSSCDList.add(syncVSSCD);
        }
        return syncVSSCDList;
    }
    
    public static List<Case_Vendor_Subscription__c> createCaseVendorSubscription(Integer numVBSCD) {
        List<Case_Vendor_Subscription__c> caseVenSubsList = new List<Case_Vendor_Subscription__c>();
        
        for(Integer i=0;i<numVBSCD;i++){
            Case_Vendor_Subscription__c caseVenSubs = new Case_Vendor_Subscription__c();
            caseVenSubsList.add(caseVenSubs);
        }
        return caseVenSubsList;
    }
    
    public static List<Product_Family__c> createProductFamily(Integer numProdFamily) {
        List<Product_Family__c> productFamilyList = new List<Product_Family__c>();
        
        for(Integer i=0;i<numProdFamily;i++){
            Product_Family__c productFamily = new Product_Family__c(Product_Family__c = 'tmp'+i,
                    Product_Family_Name__c = 'temp product family name');
            productFamilyList.add(productFamily);
        }
        return productFamilyList;
    }
    
    public static List<Promo_Eligibility_Rule_Product_Family__c> createPromoEligRuleProdFamily(Integer numPromoEligRuleProdFamily) {
        List<Promo_Eligibility_Rule_Product_Family__c> promoEligRuleProdFamilyList = new List<Promo_Eligibility_Rule_Product_Family__c>();
        
        for(Integer i=0;i<numPromoEligRuleProdFamily;i++){
            Promo_Eligibility_Rule_Product_Family__c promoEligRuleProdFamily = new Promo_Eligibility_Rule_Product_Family__c(Name = 'temp perpf');
                    
            promoEligRuleProdFamilyList.add(promoEligRuleProdFamily);
        }
        return promoEligRuleProdFamilyList;
    }
    
    // Start D-4463 22Mar16 JohnD - added for implementation of billing batch load balancing
    public static list<Billing_Batch__c> createBillingBatch() {
        
        list<Billing_Batch__c> billingBatchList = new list<Billing_Batch__c>();
        map<string, string> billingType_batches = new map<string, string>();
        billingType_batches.put('Full Prepaid', '13:13,14,15');
        billingType_batches.put('Recurring Prepaid', '1:1,2,3,4,5,6,7,8,9,10,11,12,');
        billingType_batches.put('Recurring Postpaid', '16:16');
        list<string> batches = new list<string>();
        
        for (string billingType : billingType_batches.keySet()) {
            
            batches = billingType_batches.get(billingType).split(':');
            Billing_Batch__c billingBatch = new Billing_Batch__c();
            billingBatch.Name = billingType;
            billingBatch.Batch__c = batches[1];
            billingBatch.Next_Batch_Number__c = integer.valueOf(batches[0]);
            billingBatchList.add(billingBatch);
        }
        
        return billingBatchList;
    }
    // End D-4463 22Mar16 JohnD - added for implementation of billing batch load balancing
    
    // Start JohnD
    public static map<string, id> getRecordTypes() {
        
        map<string, id> developerName_id = new map<string, id>();
        
        for (RecordType rt : [select Id, DeveloperName from RecordType]) {
            developerName_id.put(rt.DeveloperName, rt.Id);
        }
        
        return developerName_id;
    }
    
    public static Key_Id__c createContactNextNumber() {
        Key_Id__c nextRepNum = new Key_Id__c();
        nextRepNum = Key_Id__c.getValues('NEXT_RECIPIENT_NUMBER');
        if (nextRepNum == null) {
            return new Key_Id__c(Name = 'NEXT_RECIPIENT_NUMBER', Id__c = '300000');
        }
        else {
            nextRepNum = null;
            return nextRepNum;
        }
            
            
    }
    // End JohnD
}