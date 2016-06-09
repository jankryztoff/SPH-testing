@isTest (seeAllData= False)                    
private class ChangeSubscriptionServiceTest2 {

    //List of variables
    static List<Country__c> cntryList;
    static Account acnt;
    static List<Singpost_Address__c> singpostalList;
    static List<Address__c> addrList;
    static List<Contact> cntctList;
    static Zuora__CustomerAccount__c custAccount;
    static Package__c packge;
    static zqu__ZProduct__c zProducts;
    static zqu__ProductRatePlan__c prodRatePlan;
    static Product_Family__c prodFamily;
    static Package_Item__c packItem;
    static Order__c orders;
    static List<Order_Line_Item__c> orderItemList;
    static Order_Line_Item__c ordLineItem;
    static Zuora__Subscription__c zuoraSubscription;
    static Promotion__c prom;
    static Promotion_Package__c promPackage;
    static AddressWrapper addrWrap;
    static List<ContactWrapper> conWrapperList;
    static ContactWrapper conWrapper;
    static ContactWrapper conWrapper2;
    static List<Zuora__Subscription__c> zSubscriptionList;
    static RestRequest restReq;
    static RestResponse restResp;
    static SubscriptionWrapper subWrapper;
    static OrderLineItemWrapper oliWrapper;
    static final String SYSAD = 'System Administrator';

    /**
    * @author       Paul Jarred Aguiling
    * @date         4.15.2016
    * @description  Setup test data
    * @revision(s)
    */
    public static void setUpTestData() {
       
            //Setup Country__c records
            cntryList = TestDataFactory.createCountry(2);
            cntryList[0].Country_Name__c = 'Singapore';
            cntryList[0].Code__c = 'Singapore';
            cntryList[1].Country_Name__c = 'Philippines';
            cntryList[1].Code__c = 'Philippines';
            insert cntryList;
            
            //Setup Account records
            acnt = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acnt.NRIC__c = 'T1234567R';
            acnt.Name = 'Test Account';
            acnt.Phone = '123-456';
            acnt.Email__c = 'test@test.com';
            acnt.Date_of_Birth__c = date.today();
            acnt.Gender__c = 'Male';
            acnt.Race__c = 'Chinese';
            acnt.Language__c = 'Others';
            acnt.Contact_Person__c = 'Contact Person';
            acnt.Sub_Group__c = 'Freelist(MY)';
            acnt.Generate_Account_Number__c = true;

            insert acnt;
    
            //Setup Postal records
            singpostalList = TestDataFactory.createSingpostAddress(2);
            singpostalList[0].Name = 'SPostal';
            singpostalList[0].House_Block_Number__c = 'TEST';
            singpostalList[0].Address_Type__c = 'A';
            singpostalList[0].Building_Name__c = 'Building';
            singpostalList[0].Street_Name__c = 'Street';
            singpostalList[1].Name = 'PPostal';
            singpostalList[1].House_Block_Number__c = 'TEST';
            singpostalList[1].Address_Type__c = 'A';
            singpostalList[1].Building_Name__c = 'Building';
            singpostalList[1].Street_Name__c = 'Street';
            insert singpostalList;
            
            //Address
            addrList = TestDataFactory.createAddress(2);
            addrList[0].Address_Type__c = 'A';
            addrList[0].Postal_Code__c = singpostalList[0].Id;
            addrList[0].Block_House_Number__c ='TEST';
            addrList[0].Level_Number__c ='xx';
            addrList[0].Unit_Number__c = 'yy';
            addrList[0].Country__c = cntryList[0].id;
            addrList[0].Address_1__c = 'Address 1';
            addrList[0].Address_2__c = 'Address 2';
            addrList[0].Address_3__c = 'Address 3';
            addrList[0].Address_4__c = 'Address 4';
            addrList[1].Address_Type__c = 'A';
            addrList[1].Postal_Code__c = singpostalList[1].Id;
            addrList[1].Block_House_Number__c ='TEST';
            addrList[1].Level_Number__c ='xx';
            addrList[1].Unit_Number__c = 'yy';
            addrList[1].Country__c = cntryList[1].id;
            addrList[1].Address_1__c = 'Address 1';
            addrList[1].Address_2__c = 'Address 2';
            addrList[1].Address_3__c = 'Address 3';
            addrList[1].Address_4__c = 'Address 4';
            insert addrList; 
            
            //Setup Contact records
            cntctList = TestDataFactory.createContact(2);
            cntctList[0].Address__c = addrList[0].Id;
            cntctList[0].AccountId = acnt.Id;
            cntctList[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            cntctList[0].Billing_Indicator__c = true;
            cntctList[0].FirstName = 'Test';
            cntctList[0].LastName = 'Contact';
            cntctList[0].Passport__c = 'PassTest';
            cntctList[0].HomePhone__c = '123 456';
            cntctList[0].Mobile_Number__c = '123456';
            cntctList[0].Email = 'test@test.com';
            cntctList[1].Address__c = addrList[1].Id;
            cntctList[1].AccountId = acnt.Id;
            cntctList[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            cntctList[1].Billing_Indicator__c = true;
            cntctList[1].FirstName = 'Test1';
            cntctList[1].LastName = 'Contact';
            insert cntctList;
            
            String ZuoraExternalId = 'try1234';
            String ZuoraZuoraIdc = 'Test1';
            String PackageCodec   = 'afds132';
            String PromotionCodec = 'yasyd97';
            
            //Setup Zuora__CustomerAccount__c
            custAccount = TestDataFactory.createBillingAccount(1)[0];
            custAccount.Zuora__Account__c = acnt.Id;
            custAccount.Billing_Contact__c = cntctList[1].Id;
            custAccount.Zuora__Zuora_Id__c = ZuoraZuoraIdc;
            custAccount.Billing_Type__c = 'Full Prepaid';
            custAccount.Zuora__DefaultPaymentMethod__c = 'Other';
            custAccount.Zuora__AccountNumber__c = 'Test1';
            
            insert custAccount;
    
            //Setup Package records
            packge = TestDataFactory.createPackage(1)[0];
            packge.Billing_Type__c = 'Full Prepaid';
            packge.Package_Type__c = 'Grace Period';
            packge.Subscription_Period__c = '1';
            packge.Package_Code__c = PackageCodec;
            packge.Product_Family_Current_Package__c = 'test';
            insert packge;
            
            //Setup zqu__ZProduct__c records
            zProducts = TestDataFactory.createZProduct(1)[0];
            zProducts.ProductSubType__c = 'Magazine';
            zProducts.zqu__ZuoraId__c = 'Test';
            insert zProducts ;
            
            //Setup zqu__ProductRatePlan__c records
            prodRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
            prodRatePlan.zqu__ZProduct__c = zProducts.Id;
            prodRatePlan.RatePlanType__c= 'Proration';
            prodRatePlan.zqu__EffectiveStartDate__c= date.today();
            prodRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prodRatePlan.zqu__Deleted__c = false;
            prodRatePlan.zqu__ZuoraId__c = 'Test';
            insert prodRatePlan;
    
            //Setup Product_Family__c records
            prodFamily = new Product_Family__c();
            prodFamily.Product_Family__c = 'Trythis';
            prodFamily.Product_Family_Name__c = 'testtest';
            insert prodFamily;
            
            //Setup Package Item records
            packItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            packItem.Package__c = packge.id;
            packItem.Product_Rate_Plan__c = prodRatePlan.id;
            packItem.Name = 'Test Pack Item';
            packItem.Product_Family__c = prodFamily.Id;
            insert packItem;
            
            //Setup Order records
            orders = TestDataFactory.createOrder(1)[0];
            orders.Account__c = acnt.Id;
            orders.Informed_Customer__c = TRUE;
            orders.Order_Type__c = 'Renewal';
            orders.Status__c = 'Draft';
            orders.Eligible_for_Retention__c = TRUE;
            orders.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            orders.Payment_Mode__c = 'Credit Card';
            orders.Billing_Account__c = custAccount.id;
            orders.Billing_Type__c = 'Full Prepaid';
            orders.Billing_Contact__c = cntctList[1].id;
            orders.Case_Record_Type__c = 'Complaint - Magazine';
            orders.Category__c = 'Subscription Request';
            orders.Sub_Category__c ='Stop Subscription';
            orders.Credit_Balance__c = 0;
            orders.Delivery_Charge__c = 0;
            orders.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            orders.Order_Type__c = 'Change of Subscription Package';
            orders.PO_Number__c = 'PO00000';
            orders.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
            orders.Delivery_Charge_Type__c = 'C';
            orders.Subscriber_Charge__c = 10.00;
            insert orders;
             
            //Order Line Item
            orderItemList = new List<Order_Line_Item__c>(1);
            ordLineItem = TestDataFactory.createOrderLineItem(1)[0];
            ordLineItem.Order__c = orders.Id;
            ordLineItem.Start_Date__c = date.today().addDays(1);
            ordLineItem.End_Date__c = date.Today().addDays(4);
            ordLineItem.Main_Package_ID__c = packge.Id;
            ordLineItem.Term_Length__c = 0;
            ordLineItem.Main_Package_Period__c = 0;
            ordLineItem.Earliest_Start_Date__c = date.today();
            ordLineItem.Earliest_Stop_Date__c = Date.Today().addDays(2);
            ordLineItem.Stop_Request_Date__c =  date.Today().addDays(4);
            ordLineItem.Terminating_Reason__c = 'Others';
            ordLineItem.Amount_To_Refund__c = 0;
            ordLineItem.Admin_Charge__c = 0;
            ordLineItem.Fee_Waiver__c = TRUE;
            ordLineItem.Fee_Override__c = FALSE;
            ordLineItem.Override_Reason__c = 'TEST';
            ordLineItem.Suppress_Notification_Stop__c = TRUE;
            ordLineItem.Main_Package_Type__c = 'Base';
            insert ordLineItem;
            orderItemList.add(ordLineItem);
            
            //Setup Zoura Records
            zuoraSubscription = TestDataFactory.createSubscription(1)[0];
            zuoraSubscription.Zuora__Account__c = acnt.Id;
            zuoraSubscription.Order_Line_Item_Number__c = ordLineItem.Id;
            zuoraSubscription.Subscriber_Contact__c = cntctList[0].Id;
            zuoraSubscription.Recipient_Contact__c = cntctList[0].Id;
            zuoraSubscription.Main_Package_1__c = packge.Id;
            zuoraSubscription.Main_Package__c = packge.Id;
            zuoraSubscription.Zuora__Status__c = 'Active';
            zuoraSubscription.Order_Number__c = orders.Id;
            zuoraSubscription.Suppress_Vendor_Start_Notice__c = 'false';
            zuoraSubscription.Supressed_Acknowledgement_Letter__c = 'false';
            zuoraSubscription.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zuoraSubscription.Urgent__c = 'false';
            zuoraSubscription.Vendor_Conversion__c = 'false';
            zuoraSubscription.Charity__c = 'false';
            zuoraSubscription.Subscription_Type__c = 'Publication';
            zuoraSubscription.Subscription_Type_1__c = 'Publication';
            zuoraSubscription.Zuora__SubscriptionEndDate__c= date.today();
            zuoraSubscription.Zuora__SubscriptionStartDate__c = date.today();
            zuoraSubscription.Zuora__CustomerAccount__c = custAccount.Id;
            zuoraSubscription.Contact__c = cntctList[0].id;
            zuoraSubscription.Zuora__External_Id__c = ZuoraExternalId;
            zuoraSubscription.Zuora__Zuora_Id__c = ZuoraExternalId;
            insert zuoraSubscription;
            
            //Setup Promotion Records
            prom = new Promotion__c();
            prom.Name = 'Promotion';
            prom.Promotion_Code__c = PromotionCodec;
            prom.Effective_Start_Date__c = date.today();
            prom.Effective_End_Date__c = date.today().addDays(1);
            prom.Contract__c = 'Yes';
            prom.Contract_Period__c = '0';
            prom.Penalty_Charge__c = '100';
            prom.Penalty_Charge_Override__c = 500.00;
            database.insert(prom);
            
            promPackage = TestDataFactory.createPromotionPackage(1)[0];
            promPackage.Promotion__c = prom.id;
            promPackage.Package_Name__c = packge.id;
            database.insert(promPackage);
            
            addrWrap = new AddressWrapper();
            addrWrap.houseBlockNumber = addrList[0].Block_House_Number__c;
            addrWrap.levelNumber = addrList[0].Level_Number__c;
            addrWrap.unitNumber = addrList[0].Unit_Number__c;
            addrWrap.postalCode = addrList[0].Postal_Code__c;
            addrWrap.streetName = 'Strawberry St';
            addrWrap.buildingName = addrList[0].Building_Name__c;
            addrWrap.country = 'Singapore';
            addrWrap.singpostAddressType = addrList[0].Address_Type__c;   
            addrWrap.Address1 = 'BLK6 LOT5 Paz Village';
            addrWrap.Address2 = addrList[0].Address_2__c;
            addrWrap.Address3 = addrList[0].Address_3__c;
            addrWrap.Address4 = addrList[0].Address_4__c;
            
            conWrapperList = new List<ContactWrapper>();
            conWrapper = new ContactWrapper();
            conWrapper.billingIndicator = 'Y'; 
            conWrapper.recipientIndicator = 'Y';
            conWrapper.salutation = '';
            conWrapper.customerName= cntctList[0].FirstName;
            conWrapper.nric = cntctList[0].NRIC__c;
            conWrapper.passport = cntctList[0].Passport__c;
            conWrapper.homeNumber = cntctList[0].Home_Phone_display__c;
            conWrapper.mobileNumber1 = cntctList[0].Mobile_Number__c;
            conWrapper.emailAddress1 = cntctList[0].Email;
            conWrapper.address = addrWrap; 
            conWrapperList.add(conWrapper);
            
            conWrapper2 = new ContactWrapper();
            conWrapper2.billingIndicator = 'Y'; 
            conWrapper2.recipientIndicator = 'Y';
            conWrapper2.salutation = '';
            conWrapper2.customerName= cntctList[1].FirstName;
            conWrapper2.nric = cntctList[1].NRIC__c;
            conWrapper2.passport = cntctList[1].Passport__c;
            conWrapper2.homeNumber = '09107620428';
            conWrapper2.mobileNumber1 = cntctList[1].Mobile_Number__c;
            conWrapper2.emailAddress1 = cntctList[1].Email;
            conWrapper2.address = addrWrap; 
            conWrapperList.add(conWrapper2);   
            
            zSubscriptionList = [SELECT Id, Order_Number__c, Order_Line_Item_Number__c, Zuora__CustomerAccount__r.Id, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Zuora__Account__r.Id, Main_Package_1__r.Effective_End_Date__c, Main_Package_1__r.Product_Family_Current_Package__c, Main_Package_1__r.Package_Code__c, Zuora__Account__r.Account_Auto_Number__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Address__r.Country_Name__c, Zuora__CustomerAccount__r.Billing_Type__c FROM Zuora__Subscription__c WHERE Zuora__External_Id__c = :ZuoraExternalId AND Zuora__Status__c = 'Active' LIMIT 1];
            subWrapper = new SubscriptionWrapper();
            subWrapper.subscriptionId = ZuoraExternalId;
            subWrapper.accountNumber = ''+zSubscriptionList[0].Zuora__Account__r.Account_Auto_Number__c; 
            subWrapper.accountRecordType = '';
            subWrapper.billingAccountId = '';
            subWrapper.recipientId = '';     
            subWrapper.orderType = '';
            subWrapper.creationMode = ''; 
            subWrapper.paypalBAID = null;  
            subWrapper.paypalEmail = null;  
            
            oliWrapper = new OrderLineItemWrapper();
            oliWrapper.promotioncode = PromotionCodec;
            oliWrapper.packagecode = PackageCodec;
            oliWrapper.addonpackagecode = 'test';
            oliWrapper.quantity = 3;
            oliWrapper.startDate = '02/18/2015';
            oliWrapper.giftCode = new List<String>();
            oliWrapper.giftCode.add('code');
            oliWrapper.contractenddate = '02/19/2015';
            
            //Setting request and response
            restReq = new RestRequest();
            restResp = new RestResponse();
            restReq.requestURI = '/services/apexrest/ChangeSubscriptionService/*';
            restReq.httpMethod = 'POST';     
    }    

    /**
    * @author       Paul Jarred Aguiling
    * @date         4.15.2016
    * @description  Setup user record
    * @revision(s)
    */
    static User createUser(String value) {
        UserRole usrRole = [SELECT id, Name from UserRole LIMIT 1];
        Profile prof = [SELECT Id FROM Profile WHERE Name=: value LIMIT 1];
        User usr = new User(Alias = 'test122',Email='test2@test.sph.com',
                       EmailEncodingKey='UTF-8', LastName='Testing123', 
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                       ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserRoleId = usrRole.Id,
                       UserName='testDeploymentUser@sph.com', Title='Testing123');
        insert usr;

        return usr;
    }
    
    public class ChangeSubscriptionServiceRequest 
    {
        SubscriptionWrapper subscription;
        List<ContactWrapper> contacts;
        OrderLineItemWrapper orderLineItem;
    }
    public class SubscriptionWrapper 
    {
        String subscriptionId = 'try1234';
        String accountNumber;
        String accountRecordType;
        String billingAccountId;
        String recipientId;     
        String orderType;
        String creationMode;
        String paypalBAID;
        String paypalEmail;
    }
    public class ContactWrapper 
    {
        String salutation;
        String customerName;
        String nric;
        String passport;
        String billingIndicator;
        String recipientIndicator;
        String homeNumber;
        String mobileNumber1;
        String emailAddress1;
        AddressWrapper address;     
    }
    public class AddressWrapper 
    {
        String houseBlockNumber;
        String levelNumber;
        String unitNumber;
        String postalCode;
        String streetName;
        String buildingName;
        String country;
        String singpostAddressType;   
        String Address1;
        String Address2;
        String Address3;
        String Address4;
    }
    public class OrderLineItemWrapper 
    {        
        public String promotioncode;
        public String packagecode;
        public String addonpackagecode;
        public String ldapId;
        public Integer quantity;
        public String startDate;
        public List<String> giftCode; // = new List<String> {'Code1'};
        public String contractenddate;
        
    }

    static void setCustomSettings() {
    
        //Cir_Planner_Schedule__c
        List<Cir_Planner_Schedule__c> cpsList = new List<Cir_Planner_Schedule__c>{
            new Cir_Planner_Schedule__c(Name='CIR Plan Schedule', Mon_Fri_End_Time__c=Date.today(),
                Mon_Fri_Start_Time__c=Date.today(),Sat_PH_End_Time__c=Date.today(),Sat_PH_Start_Time__c=Date.today(),
                Sun_End_Time__c=Date.today(),Sun_Start_Time__c=Date.today())
        };
        Database.insert(cpsList);
        
        //
        RecordType Case_ChangeinAddress = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Change of Address/Vendor' LIMIT 1];
        RecordType Contact_CustomerContact = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Customer Contact' LIMIT 1];
        RecordType Address_Local = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Local' LIMIT 1];
        RecordType addressOverseas = [SELECT id, Name FROM RecordType WHERE SobjectType='Address__c' AND Name='Overseas' LIMIT 1];
        RecordType directCorporate = [SELECT id, Name FROM RecordType WHERE SobjectType='Account' AND Name='Direct Corporate' LIMIT 1];
        
        
        //Key_Id__c
        List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role', Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='Case_Change in Address', Id__c=Case_ChangeinAddress.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Contact_Customer Contact', Id__c=Contact_CustomerContact.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Local', Id__c=Address_Local.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Address_Overseas', Id__c=addressOverseas.id ,Type__c='RecordType'),
            new Key_Id__c(Name='Account_Direct Corporate', Id__c=directCorporate.id ,Type__c='RecordType')
        };
        Database.insert(kisList);
        
        //Batch_Configuration_Settings__c.getInstance('SP_VendorNotificationsBatch');
        List<Batch_Configuration_Settings__c> bcsList = new List<Batch_Configuration_Settings__c>{
            new Batch_Configuration_Settings__c(Name='SP_VendorNotificationsBatch', Batch_Size__c=10, 
                Max_Retries__c=10, Notification_Recipients__c='', Number_Of_Days_To_Retrieve__c=30)
        };
        Database.insert(bcsList);
        
        //Other__c
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        Database.insert(otherList);
        //ConstantsSLB.getOther('DTL').split(':');
        
    }

    /**
    * @author       Paul Jarred Aguiling
    * @date         4.15.2016
    * @description  Test method for processRequest()
    * @revision(s)
    */
    static testMethod void testProcessRequest() {
        User usr = createUser(SYSAD);

        System.runAs(usr) {
            setCustomSettings();
            setUpTestData();

            RestContext.request = restReq;
            RestContext.response= restResp;
            
            String newString = ''+ acnt.id;
            String accountString = '' + acnt.Account_Auto_Number__c;
            String recordString = 'Direct Corporate';
            String productFamilyParam = packge.Product_Family_Current_Package__c;
            String countryCodeParam = 'code';
            String postalCodeParam = 'postal';
            String levelNumberParam = 'level';
            String unitNumberParam = 'unit';
            
            ChangeSubscriptionServiceRequest ChgSubsSvsRequest = new ChangeSubscriptionServiceRequest();
            ChgSubsSvsRequest.subscription = subWrapper;
            ChgSubsSvsRequest.contacts = conWrapperList;
            ChgSubsSvsRequest.orderLineItem = oliWrapper;
            List<Order_Line_Item__c> newVar = ChangeSubscriptionService.getNewOrderLineItems(orders);

            Test.startTest();
                ChangeSubscriptionService.updateSubscriptionEndDateFuture(zuoraSubscription, zuoraSubscription.Zuora__SubscriptionEndDate__c);
                ChangeSubscriptionService.getOrderLineItem(ordLineItem.id);
                ChangeSubscriptionService.getBillingAccount(newString);
                ChangeSubscriptionService.getAccount(accountString);
                ChangeSubscriptionService.validateSimilarSubscriptions(recordString, accountString, productFamilyParam, countryCodeParam, postalCodeParam, levelNumberParam, unitNumberParam);

                String jsonStr = JSON.serialize(ChgSubsSvsRequest);
                ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
                
                system.assertNotEquals(null, esh);
                
                ChangeSubscriptionService.ChangeSubscriptionServiceResponse response = ChangeSubscriptionService.processRequest(esh);  
                System.assertNotEquals(null, response);
            Test.stopTest();
        }
    }

    /**
    * @author       Paul Jarred Aguiling
    * @date         4.15.2016
    * @description  Test method for processRequest()
    * @revision(s)
    */
    static testMethod void testProcessRequest2() {
        User usr = createUser(SYSAD);

        System.runAs(usr) {
            setCustomSettings();
            setUpTestData();

            subWrapper.paypalBAID = '12345';  
            subWrapper.paypalEmail = 'test@email.com';  

            RestContext.request = restReq;
            RestContext.response= restResp;
            
            String newString = ''+ acnt.id;
            String accountString = '' + acnt.Account_Auto_Number__c;
            String recordString = 'Direct Corporate';
            String productFamilyParam = packge.Product_Family_Current_Package__c;
            String countryCodeParam = 'code';
            String postalCodeParam = 'postal';
            String levelNumberParam = 'level';
            String unitNumberParam = 'unit';
            
            ChangeSubscriptionServiceRequest ChgSubsSvsRequest = new ChangeSubscriptionServiceRequest();
            ChgSubsSvsRequest.subscription = subWrapper;
            ChgSubsSvsRequest.contacts = conWrapperList;
            ChgSubsSvsRequest.orderLineItem = oliWrapper;
            List<Order_Line_Item__c> newVar = ChangeSubscriptionService.getNewOrderLineItems(orders);

            Test.startTest();
                ChangeSubscriptionService.updateSubscriptionEndDateFuture(zuoraSubscription, zuoraSubscription.Zuora__SubscriptionEndDate__c);
                ChangeSubscriptionService.getOrderLineItem(ordLineItem.id);
                ChangeSubscriptionService.getBillingAccount(newString);
                ChangeSubscriptionService.getAccount(accountString);
                ChangeSubscriptionService.validateSimilarSubscriptions(recordString, accountString, productFamilyParam, countryCodeParam, postalCodeParam, levelNumberParam, unitNumberParam);

                String jsonStr = JSON.serialize(ChgSubsSvsRequest);
                ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
                
                system.assertNotEquals(null, esh);
                
                ChangeSubscriptionService.ChangeSubscriptionServiceResponse response = ChangeSubscriptionService.processRequest(esh);  
                System.assertNotEquals(null, response);
            Test.stopTest();
        }
    }

    /**
    * @author       Paul Jarred Aguiling
    * @date         4.15.2016
    * @description  Test method for processRequest()
    * @revision(s)
    */
    static testMethod void testProcessRequest3() {
        User usr = createUser(SYSAD);

        System.runAs(usr) {
            setCustomSettings();
            setUpTestData();

            conWrapperList = new List<ContactWrapper>();
            conWrapper.recipientIndicator = 'N';
            conWrapper.billingIndicator = 'Y';
            conWrapperList.add(conWrapper);
            conWrapper2.recipientIndicator = 'Y';
            conWrapper2.billingIndicator = 'N';
            conWrapperList.add(conWrapper2); 

            String billAccoutNumber = [select Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where id =: custAccount.Id].Zuora__Zuora_Id__c; 
            subWrapper.billingAccountId = billAccoutNumber;
            subWrapper.recipientId = cntctList[0].id;  
            Account acc = [SELECT Account_Auto_Number__c FROM Account WHERE Id = : acnt.Id];
            subWrapper.accountNumber = acc.Account_Auto_Number__c;

            
            RestContext.request = restReq;
            RestContext.response= restResp;
            
            String newString = ''+ acnt.id;
            String accountString = '' + acnt.Account_Auto_Number__c;
            String recordString = 'Direct Corporate';
            String productFamilyParam = packge.Product_Family_Current_Package__c;
            String countryCodeParam = 'code';
            String postalCodeParam = 'postal';
            String levelNumberParam = 'level';
            String unitNumberParam = 'unit';
            
            ChangeSubscriptionServiceRequest ChgSubsSvsRequest = new ChangeSubscriptionServiceRequest();
            ChgSubsSvsRequest.subscription = subWrapper;
            ChgSubsSvsRequest.contacts = conWrapperList;
            ChgSubsSvsRequest.orderLineItem = oliWrapper;
            List<Order_Line_Item__c> newVar = ChangeSubscriptionService.getNewOrderLineItems(orders);

            Test.startTest();
                ChangeSubscriptionService.updateSubscriptionEndDateFuture(zuoraSubscription, zuoraSubscription.Zuora__SubscriptionEndDate__c);
                ChangeSubscriptionService.getOrderLineItem(ordLineItem.id);
                ChangeSubscriptionService.getBillingAccount(newString);
                ChangeSubscriptionService.getAccount(accountString);
                ChangeSubscriptionService.validateSimilarSubscriptions(recordString, accountString, productFamilyParam, countryCodeParam, postalCodeParam, levelNumberParam, unitNumberParam);

                String jsonStr = JSON.serialize(ChgSubsSvsRequest);
                ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
                
                system.assertNotEquals(null, esh);
                
                ChangeSubscriptionService.ChangeSubscriptionServiceResponse response = ChangeSubscriptionService.processRequest(esh);  
                System.assertNotEquals(null, response);
            Test.stopTest();
        }
    }
    

//    static testMethod void testChangeSubscriptionService10(){
        
//            setCustomSettings();
       
//            List<Country__c> CtryList = TestDataFactory.createCountry(2);
//            CtryList[0].Country_Name__c = 'Singapore';
//            CtryList[1].Country_Name__c = 'Philippines';
//            insert CtryList;
            
//            //Account
//            Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
//            acct.NRIC__c = 'T1234567R';
//            acct.Name = 'Test Account';
//            acct.Phone = '123-456';
//            acct.Email__c = 'test@test.com';
//            acct.Date_of_Birth__c = date.today();
//            acct.Gender__c = 'Male';
//            acct.Race__c = 'Chinese';
//            acct.Language__c = 'Others';
//            acct.Contact_Person__c = 'Contact Person';
//            acct.Sub_Group__c = 'Freelist(MY)';
//            acct.Generate_Account_Number__c = true;
//            //acct.AccountNumber = '00112233';
//            //acct.Account_Auto_Number__c = '00112233';
//            insert acct;
            
//            //update acct;
            
//            //System.assertEquals(acct.AccountNumber, acct.Account_Auto_Number__c, 'This should be equal.');
    
//            // postal
//            List<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
//            postal[0].Name = 'SPostal';
//            postal[0].House_Block_Number__c = 'TEST';
//            postal[0].Address_Type__c = 'A';
//            postal[0].Building_Name__c = 'Building';
//            postal[0].Street_Name__c = 'Street';
//            postal[1].Name = 'PPostal';
//            postal[1].House_Block_Number__c = 'TEST';
//            postal[1].Address_Type__c = 'A';
//            postal[1].Building_Name__c = 'Building';
//            postal[1].Street_Name__c = 'Street';
//            insert postal;
            
//            //Address
//            List<Address__c> addressRecList = TestDataFactory.createAddress(2);
//            addressRecList[0].Address_Type__c = 'A';
//            addressRecList[0].Postal_Code__c = postal[0].Id;
//            addressRecList[0].Block_House_Number__c ='TEST';
//            addressRecList[0].Level_Number__c ='xx';
//            addressRecList[0].Unit_Number__c = 'yy';
//            addressRecList[0].Country__c = CtryList[0].id;
//            addressRecList[0].Address_1__c = 'Address 1';
//            addressRecList[0].Address_2__c = 'Address 2';
//            addressRecList[0].Address_3__c = 'Address 3';
//            addressRecList[0].Address_4__c = 'Address 4';
//            addressRecList[1].Address_Type__c = 'A';
//            addressRecList[1].Postal_Code__c = postal[1].Id;
//            addressRecList[1].Block_House_Number__c ='TEST';
//            addressRecList[1].Level_Number__c ='xx';
//            addressRecList[1].Unit_Number__c = 'yy';
//            addressRecList[1].Country__c = CtryList[1].id;
//            addressRecList[1].Address_1__c = 'Address 1';
//            addressRecList[1].Address_2__c = 'Address 2';
//            addressRecList[1].Address_3__c = 'Address 3';
//            addressRecList[1].Address_4__c = 'Address 4';
//            insert addressRecList; 
            
//            //Contact
//            List<Contact> cntct = TestDataFactory.createContact(2);
//            cntct[0].Address__c = addressRecList[0].Id;
//            cntct[0].AccountId = acct.Id;
//            cntct[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
////cntct[0].Recipient_Indicator__c = true;
//            cntct[0].Billing_Indicator__c = true;
//            cntct[0].FirstName = 'Test';
//            cntct[0].LastName = 'Contact';
//            cntct[0].Passport__c = 'PassTest';
//            cntct[0].HomePhone__c = '123 456';
//            cntct[0].Mobile_Number__c = '123456';
//            cntct[0].Email = 'test@test.com';
//            cntct[1].Address__c = addressRecList[1].Id;
//            cntct[1].AccountId = acct.Id;
//            cntct[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
//            cntct[1].Billing_Indicator__c = true;
//            cntct[1].FirstName = 'Test1';
//            cntct[1].LastName = 'Contact';
//            insert cntct;
            
//            //==>
//            String ZuoraExternalId = 'try1234';
//            String ZuoraZuoraIdc = 'Test1';
//            String PackageCodec   = 'afds132';
//            String PromotionCodec = 'yasyd97';
            
//            // billing account
//            Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
//            billAcct.Zuora__Account__c = acct.Id;
//            billAcct.Billing_Contact__c = cntct[1].Id;
//            billAcct.Zuora__Zuora_Id__c = ZuoraZuoraIdc;
//            billAcct.Billing_Type__c = 'Full Prepaid';
//            billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
//            billAcct.Zuora__AccountNumber__c = 'Test1';
            
//            insert billAcct;
    
//            // package
//            //FROM Package__c WHERE Package_Code__c = :packageCodeParam
//            Package__c iPack = TestDataFactory.createPackage(1)[0];
//            iPack.Billing_Type__c = 'Full Prepaid';
//            iPack.Package_Type__c = 'Grace Period';
//            iPack.Subscription_Period__c = '1';
//            iPack.Package_Code__c = PackageCodec;
//            iPack.Product_Family_Current_Package__c = 'test';
//            insert iPack;
            
//            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
//            zProduct.ProductSubType__c = 'Magazine';
//            zProduct.zqu__ZuoraId__c = 'Test';
//            insert zProduct ;
            
//            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
//            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
//            prdRatePlan.RatePlanType__c= 'Proration';
//            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
//            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
//            prdRatePlan.zqu__Deleted__c = false;
//            prdRatePlan.zqu__ZuoraId__c = 'Test';
//            insert prdRatePlan;
    
//            Product_Family__c prodfam = new Product_Family__c();
//            prodfam.Product_Family__c = 'Trythis';
//            prodfam.Product_Family_Name__c = 'testtest';
//            insert prodfam;
            
//            // package item
//            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
//            pItem.Package__c = iPack.id;
//            pItem.Product_Rate_Plan__c = prdRatePlan.id;
//            pItem.Name = 'Test Pack Item';
//            pItem.Product_Family__c = prodfam.Id;
//            insert pItem;
            
//            Order__c order_c = TestDataFactory.createOrder(1)[0];
//            order_c.Account__c = acct.Id;
//            order_c.Informed_Customer__c = TRUE;
////order_c.Recipient_Contact__c = cntct[0].Id;
//            order_c.Order_Type__c = 'Renewal';
//            order_c.Status__c = 'Draft';
//            order_c.Eligible_for_Retention__c = TRUE;
//            order_c.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
//            order_c.Payment_Mode__c = 'Credit Card';
//            order_c.Billing_Account__c = billAcct.id;
//            order_c.Billing_Type__c = 'Full Prepaid';
//            order_c.Billing_Contact__c = cntct[1].id;
//            order_c.Case_Record_Type__c = 'Complaint - Magazine';
//            order_c.Category__c = 'Subscription Request';
//            order_c.Sub_Category__c ='Stop Subscription';
//            order_c.Credit_Balance__c = 0;
//            order_c.Delivery_Charge__c = 0;
//            order_c.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
//            order_c.Order_Type__c = 'Change of Subscription Package';
//            order_c.PO_Number__c = 'PO00000';
//            order_c.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
//            order_c.Delivery_Charge_Type__c = 'C';
//            order_c.Subscriber_Charge__c = 10.00;
//            insert order_c;
    
//            /*Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
//            cas.Order__c = order_c.Id;
//            insert cas; */
             
//            //Order Line Item
//            List<Order_Line_Item__c> newList = new List<Order_Line_Item__c>(1);
//            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
//            orderline.Order__c = order_c.Id;
//            orderline.Start_Date__c = date.today().addDays(1);
//            orderline.End_Date__c = date.Today().addDays(4);
//            orderline.Main_Package_ID__c = iPack.Id;
//            orderline.Term_Length__c = 0;
//            orderline.Main_Package_Period__c = 0;
//            orderline.Earliest_Start_Date__c = date.today();
//            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
//            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
//            orderline.Terminating_Reason__c = 'Others';
//            orderline.Amount_To_Refund__c = 0;
//            orderline.Admin_Charge__c = 0;
//            orderline.Fee_Waiver__c = TRUE;
//            orderline.Fee_Override__c = FALSE;
//            orderline.Override_Reason__c = 'TEST';
//            orderline.Suppress_Notification_Stop__c = TRUE;
//            orderline.Main_Package_Type__c = 'Base';
//            insert orderline;
//            newList.add(orderline);
//            // subscrption
//            //subscription.Main_Package_1__r.Product_Family_Current_Package__c != packageRecord.Product_Family_Current_Package__c
            
//            //FROM Zuora__Subscription__c WHERE Zuora__External_Id__c = :subscriptionId 
//            //AND Zuora__Status__c = 'Active' LIMIT 1]
//            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
//            sub.Zuora__Account__c = acct.Id;
//            sub.Order_Line_Item_Number__c = orderline.Id;
//            sub.Subscriber_Contact__c = cntct[0].Id;
//            sub.Recipient_Contact__c = cntct[0].Id;
//            sub.Main_Package_1__c = iPack.Id;
//            sub.Main_Package__c = iPack.Id;
//            sub.Zuora__Status__c = 'Active';
//            sub.Order_Number__c = order_c.Id;
//            sub.Suppress_Vendor_Start_Notice__c = 'false';
//            sub.Supressed_Acknowledgement_Letter__c = 'false';
//            sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
//            sub.Urgent__c = 'false';
//            sub.Vendor_Conversion__c = 'false';
//            sub.Charity__c = 'false';
//            sub.Subscription_Type__c = 'Publication';
//            sub.Subscription_Type_1__c = 'Publication';
//            sub.Zuora__SubscriptionEndDate__c= date.today();
//            sub.Zuora__SubscriptionStartDate__c = date.today();
//            sub.Zuora__CustomerAccount__c = billAcct.Id;
//            sub.Contact__c = cntct[0].id;
//            sub.Zuora__External_Id__c = ZuoraExternalId;
//            //sub.Main_Package_1__c = iPack.id;
//            //sub.Zuora__Zuora_Id__c = ZuoraZuoraIdc;
//            sub.Zuora__Zuora_Id__c = ZuoraExternalId;
//            insert sub;
            
            
//            //PromoEligibilityRule:            
//            /*promoList = [SELECT id, name, Promotion_Code__c, Contract_Period__c FROM Promotion__c WHERE Promotion_Code__c IN: promoCodeSet AND Contract_Period__c IN: promoPeriodSet];*/
//            /*promoPackList = [SELECT Id, Package_Name__c, Promotion__c, Promotion_Name__c, 
//                                    Package_Name__r.Package_Code__c, Package_Name__r.Product_Family_Current_Package__c
//                                    FROM Promotion_Package__c
//                                    WHERE Promotion__c IN :promoIdSet]*/
//            //--->         
//            Promotion__c promo = new Promotion__c();
//            promo.Name = 'Promotion';
//            promo.Promotion_Code__c = PromotionCodec;
//            promo.Effective_Start_Date__c = date.today();
//            promo.Effective_End_Date__c = date.today().addDays(1);
//            promo.Contract__c = 'Yes';
//            promo.Contract_Period__c = '0';
//            promo.Penalty_Charge__c = '100';
//            promo.Penalty_Charge_Override__c = 500.00;
//            database.insert(promo);
            
//            Promotion_Package__c promopack = TestDataFactory.createPromotionPackage(1)[0];
//            promopack.Promotion__c = promo.id;
//            promopack.Package_Name__c = iPack.id;
//            database.insert(promopack);
//            //<---
            
//            /*PackageEligibilityCheck: 
//                subscriptionValidation: 
//                    Select Id,Zuora__Zuora_Id__c from Zuora__Subscription__c where Zuora__Zuora_Id__c = :SubscriptionId*/
            
            
            
            
//            //<==
            
//            AddressWrapper addWrap = new AddressWrapper();
//            addWrap.houseBlockNumber = addressRecList[0].Block_House_Number__c;
//            addWrap.levelNumber = addressRecList[0].Level_Number__c;
//            addWrap.unitNumber = addressRecList[0].Unit_Number__c;
//            addWrap.postalCode = addressRecList[0].Postal_Code__c;
//            addWrap.streetName = 'Strawberry St';
//            addWrap.buildingName = addressRecList[0].Building_Name__c;
//            addWrap.country = 'Singapore';
//            addWrap.singpostAddressType = addressRecList[0].Address_Type__c;   
//            addWrap.Address1 = 'BLK6 LOT5 Paz Village';
//            addWrap.Address2 = addressRecList[0].Address_2__c;
//            addWrap.Address3 = addressRecList[0].Address_3__c;
//            addWrap.Address4 = addressRecList[0].Address_4__c;
            
//            List<ContactWrapper> conWrapList = new List<ContactWrapper>();
//            ContactWrapper conWrap = new ContactWrapper();
//            conWrap.billingIndicator = 'Y'; 
//            conWrap.recipientIndicator = 'Y';
//            conWrap.salutation = '';
//            conWrap.customerName= cntct[0].FirstName;
//            conWrap.nric = cntct[0].NRIC__c;
//            conWrap.passport = cntct[0].Passport__c;
//            conWrap.homeNumber = cntct[0].Home_Phone_display__c;
//            conWrap.mobileNumber1 = cntct[0].Mobile_Number__c;
//            conWrap.emailAddress1 = cntct[0].Email;
//            conWrap.address = addWrap; 
//            conWrapList.add(conWrap);
            
//            ContactWrapper conWrap2 = new ContactWrapper();
//            conWrap2.billingIndicator = 'Y'; 
//            conWrap2.recipientIndicator = 'Y';
//            conWrap2.salutation = '';
//            conWrap2.customerName= cntct[1].FirstName;
//            conWrap2.nric = cntct[1].NRIC__c;
//            conWrap2.passport = cntct[1].Passport__c;
//            conWrap2.homeNumber = '09107620428';
//            conWrap2.mobileNumber1 = cntct[1].Mobile_Number__c;
//            conWrap2.emailAddress1 = cntct[1].Email;
//            conWrap2.address = addWrap; 
//            conWrapList.add(conWrap2);   
            
//            //--ulti
//            List<Zuora__Subscription__c> subscriptionList = [SELECT Id, Order_Number__c, Order_Line_Item_Number__c, Zuora__CustomerAccount__r.Id, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Zuora__Account__r.Id, Main_Package_1__r.Effective_End_Date__c, Main_Package_1__r.Product_Family_Current_Package__c, Main_Package_1__r.Package_Code__c, Zuora__Account__r.Account_Auto_Number__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Address__r.Country_Name__c, Zuora__CustomerAccount__r.Billing_Type__c FROM Zuora__Subscription__c WHERE Zuora__External_Id__c = :ZuoraExternalId AND Zuora__Status__c = 'Active' LIMIT 1];
            
//            /*request.subscription.subscriptionId, 
//              request.subscription.accountNumber*/
            
//            SubscriptionWrapper subsWrap = new SubscriptionWrapper();
////subsWrap.subscriptionId = ZuoraZuoraIdc;
//            subsWrap.subscriptionId = ZuoraExternalId;
//            subsWrap.accountNumber = ''+subscriptionList[0].Zuora__Account__r.Account_Auto_Number__c;  // <---- April
//            subsWrap.accountRecordType = '';
//            subsWrap.billingAccountId = '';
//            subsWrap.recipientId = '';     
//            subsWrap.orderType = '';
//            subsWrap.creationMode = ''; 
//            subsWrap.paypalBAID = '1234567890';  
//            subsWrap.paypalEmail = 'a@a.com';  
            
//            OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
//            oliWrap.promotioncode = PromotionCodec;
//            oliWrap.packagecode = PackageCodec;
//            oliWrap.addonpackagecode = 'test';
//            //oliWrap.ldapId = '';
//            oliWrap.quantity = 3;
//            oliWrap.startDate = '02/18/2015';
//            oliWrap.giftCode = new List<String>();
//            oliWrap.giftCode.add('code');
//            oliWrap.contractenddate = '02/19/2015';
            
            
//            ChangeSubscriptionService.ContactWrapper cWrap = new ChangeSubscriptionService.ContactWrapper();
//            ChangeSubscriptionService.OrderLineItemWrapper olWrap = new ChangeSubscriptionService.OrderLineItemWrapper();
//            ChangeSubscriptionService.AddressWrapper adWrap = new ChangeSubscriptionService.AddressWrapper();
//            ChangeSubscriptionService.SubscriptionWrapper subWrap= new ChangeSubscriptionService.SubscriptionWrapper();
//            ChangeSubscriptionService.ChangeSubscriptionServiceRequest request = new ChangeSubscriptionService.ChangeSubscriptionServiceRequest();
    
//            system.assertNotEquals(null, cWrap);
//            system.assertNotEquals(null, olWrap );
//            system.assertNotEquals(null, adWrap );
//            system.assertNotEquals(null, subWrap);
//            system.assertNotEquals(null, request );
            
//            RestRequest req = new RestRequest();
//            RestResponse res = new RestResponse();
//            req.requestURI = '/services/apexrest/ChangeSubscriptionService/*';
//            req.httpMethod = 'POST';
//            RestContext.request = req;
//            RestContext.response= res;
            
//            String newString = ''+ acct.id;
//            String accountString = '' + acct.Account_Auto_Number__c;
//            String recordString = 'Direct Corporate';
//            String productFamilyParam = iPack.Product_Family_Current_Package__c;
//            String countryCodeParam = 'code';
//            String postalCodeParam = 'postal';
//            String levelNumberParam = 'level';
//            String unitNumberParam = 'unit';
            
//            ChangeSubscriptionServiceRequest ChgSubsSvsRequest = new ChangeSubscriptionServiceRequest();
//            ChgSubsSvsRequest.subscription = subsWrap;
//            ChgSubsSvsRequest.contacts = conWrapList;
//            ChgSubsSvsRequest.orderLineItem = oliWrap;
//            List<Order_Line_Item__c> newVar = ChangeSubscriptionService.getNewOrderLineItems(order_c);
//            //ChangeSubscriptionService.updateSubscriptionEndDate(sub,newList);
//            //
//            ChangeSubscriptionService.updateSubscriptionEndDateFuture(sub, sub.Zuora__SubscriptionEndDate__c);
//            ChangeSubscriptionService.getOrderLineItem(orderline.id);
//            ChangeSubscriptionService.getBillingAccount(newString);
//            ChangeSubscriptionService.getAccount(accountString);
//            ChangeSubscriptionService.validateSimilarSubscriptions(recordString, accountString, productFamilyParam, countryCodeParam, postalCodeParam, levelNumberParam, unitNumberParam);
//            //
//            String jsonStr = JSON.serialize(ChgSubsSvsRequest);
//            ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
//            system.assertNotEquals(null, esh);
            
//            ChangeSubscriptionService.ChangeSubscriptionServiceResponse response = ChangeSubscriptionService.processRequest(esh);  
//            System.assertNotEquals(null, response);
//    }

        static testMethod void testisValidNull(){
        
        
            setCustomSettings();
        
       
            List<Country__c> CtryList = TestDataFactory.createCountry(2);
            CtryList[0].Country_Name__c = 'Singapore';
            CtryList[1].Country_Name__c = 'Philippines';
            insert CtryList;
            
            Recordtype recType = [SELECT Id, Name FROM Recordtype WHERE Name =: 'Vendor'];
            //Account
            Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.Recordtypeid = recType.id;
            acct.NRIC__c = 'T1234567R';
            acct.Name = 'Test Account';
            acct.Phone = '123-456';
            acct.Email__c = 'test@test.com';
            acct.Date_of_Birth__c = date.today();
            acct.Gender__c = 'Male';
            acct.Race__c = 'Chinese';
            acct.Language__c = 'Others';
            acct.Contact_Person__c = 'Contact Person';
            acct.Sub_Group__c = 'Freelist(MY)';
            acct.Generate_Account_Number__c = true;
            //acct.AccountNumber = '00112233';
            //acct.Account_Auto_Number__c = '00112233';
            insert acct;
            
            //update acct;
            
            //System.assertEquals(acct.AccountNumber, acct.Account_Auto_Number__c, 'This should be equal.');
    
            // postal
            List<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
            postal[0].Name = 'SPostal';
            postal[0].House_Block_Number__c = 'TEST';
            postal[0].Address_Type__c = 'A';
            postal[0].Building_Name__c = 'Building';
            postal[0].Street_Name__c = 'Street';
            postal[1].Name = 'PPostal';
            postal[1].House_Block_Number__c = 'TEST';
            postal[1].Address_Type__c = 'A';
            postal[1].Building_Name__c = 'Building';
            postal[1].Street_Name__c = 'Street';
            insert postal;
            
            //Address
            List<Address__c> addressRecList = TestDataFactory.createAddress(2);
            addressRecList[0].Address_Type__c = 'A';
            addressRecList[0].Postal_Code__c = postal[0].Id;
            addressRecList[0].Block_House_Number__c ='TEST';
            addressRecList[0].Level_Number__c ='xx';
            addressRecList[0].Unit_Number__c = 'yy';
            addressRecList[0].Country__c = CtryList[0].id;
            addressRecList[0].Address_1__c = 'Address 1';
            addressRecList[0].Address_2__c = 'Address 2';
            addressRecList[0].Address_3__c = 'Address 3';
            addressRecList[0].Address_4__c = 'Address 4';
            addressRecList[1].Address_Type__c = 'A';
            addressRecList[1].Postal_Code__c = postal[1].Id;
            addressRecList[1].Block_House_Number__c ='TEST';
            addressRecList[1].Level_Number__c ='xx';
            addressRecList[1].Unit_Number__c = 'yy';
            addressRecList[1].Country__c = CtryList[1].id;
            addressRecList[1].Address_1__c = 'Address 1';
            addressRecList[1].Address_2__c = 'Address 2';
            addressRecList[1].Address_3__c = 'Address 3';
            addressRecList[1].Address_4__c = 'Address 4';
            insert addressRecList; 
            
            //Contact
            List<Contact> cntct = TestDataFactory.createContact(2);
            cntct[0].Address__c = addressRecList[0].Id;
            cntct[0].AccountId = acct.Id;
            cntct[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
//cntct[0].Recipient_Indicator__c = true;
            cntct[0].Billing_Indicator__c = true;
            cntct[0].FirstName = 'Test';
            cntct[0].LastName = 'Contact';
            cntct[0].Passport__c = 'PassTest';
            cntct[0].HomePhone__c = '123 456';
            cntct[0].Mobile_Number__c = '123456';
            cntct[0].Email = 'test@test.com';
            cntct[1].Address__c = addressRecList[1].Id;
            cntct[1].AccountId = acct.Id;
            cntct[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            cntct[1].Billing_Indicator__c = true;
            cntct[1].FirstName = 'Test1';
            cntct[1].LastName = 'Contact';
            insert cntct;
            
            //==>
            // billing account
            Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
            billAcct.Zuora__Account__c = acct.Id;
            billAcct.Billing_Contact__c = cntct[1].Id;
            billAcct.Zuora__Zuora_Id__c = 'Test1';
            billAcct.Billing_Type__c = 'Full Prepaid';
            billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
            billAcct.Zuora__AccountNumber__c = 'Test1';
            
            insert billAcct;
    
            // package
            //FROM Package__c WHERE Package_Code__c = :packageCodeParam
            Package__c iPack = TestDataFactory.createPackage(1)[0];
            iPack.Billing_Type__c = 'Full Prepaid';
            iPack.Package_Type__c = 'Grace Period';
            iPack.Subscription_Period__c = '1';
            iPack.Package_Code__c = 'afds132';
            iPack.Product_Family_Current_Package__c = 'test';
            insert iPack;
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.ProductSubType__c = 'Magazine';
            zProduct.zqu__ZuoraId__c = 'Test';
            insert zProduct ;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Proration';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            prdRatePlan.zqu__ZuoraId__c = 'Test';
            insert prdRatePlan;
    
            Product_Family__c prodfam = new Product_Family__c();
            prodfam.Product_Family__c = 'Trythis';
            prodfam.Product_Family_Name__c = 'testtest';
            insert prodfam;
            
            // package item
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = iPack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
            pItem.Product_Family__c = prodfam.Id;
            insert pItem;
            
            Order__c order_c = TestDataFactory.createOrder(1)[0];
            order_c.Account__c = acct.Id;
            order_c.Informed_Customer__c = TRUE;
//order_c.Recipient_Contact__c = cntct[0].Id;
            order_c.Order_Type__c = 'Renewal';
            order_c.Status__c = 'Draft';
            order_c.Eligible_for_Retention__c = TRUE;
            order_c.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order_c.Payment_Mode__c = 'Credit Card';
            order_c.Billing_Account__c = billAcct.id;
            order_c.Billing_Type__c = 'Full Prepaid';
            order_c.Billing_Contact__c = cntct[1].id;
            order_c.Case_Record_Type__c = 'Complaint - Magazine';
            order_c.Category__c = 'Subscription Request';
            order_c.Sub_Category__c ='Stop Subscription';
            order_c.Credit_Balance__c = 0;
            order_c.Delivery_Charge__c = 0;
            order_c.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order_c.Order_Type__c = 'Change of Subscription Package';
            order_c.PO_Number__c = 'PO00000';
            order_c.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
            order_c.Delivery_Charge_Type__c = 'C';
            order_c.Subscriber_Charge__c = 10.00;
            insert order_c;
    
            /*Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order_c.Id;
            insert cas; */
             
            //Order Line Item
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order_c.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.Today().addDays(4);
            orderline.Main_Package_ID__c = iPack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            insert orderline;
            
            // subscrption
            //subscription.Main_Package_1__r.Product_Family_Current_Package__c != packageRecord.Product_Family_Current_Package__c
            
            //FROM Zuora__Subscription__c WHERE Zuora__External_Id__c = :subscriptionId 
            //AND Zuora__Status__c = 'Active' LIMIT 1]
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__Account__c = acct.Id;
            sub.Order_Line_Item_Number__c = orderline.Id;
            sub.Subscriber_Contact__c = cntct[0].Id;
            sub.Recipient_Contact__c = cntct[0].Id;
            sub.Main_Package_1__c = iPack.Id;
            sub.Main_Package__c = iPack.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Order_Number__c = order_c.Id;
            sub.Suppress_Vendor_Start_Notice__c = 'false';
            sub.Supressed_Acknowledgement_Letter__c = 'false';
            sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            sub.Urgent__c = 'false';
            sub.Vendor_Conversion__c = 'false';
            sub.Charity__c = 'false';
            sub.Subscription_Type__c = 'Publication';
            sub.Subscription_Type_1__c = 'Publication';
            sub.Zuora__SubscriptionEndDate__c= date.today();
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Zuora__CustomerAccount__c = billAcct.Id;
            sub.Contact__c = cntct[0].id;
            String ZuoraExternalId = 'try1234';
            sub.Zuora__Zuora_Id__c = ZuoraExternalId;
            sub.Zuora__External_Id__c = ZuoraExternalId;
            //sub.Main_Package_1__c = iPack.id;
            insert sub;
            
            List<Publication__c> pub = TestDataFactory.createPublication(1);
            pub[0].Product_Family__c = 'Soap';
            insert pub;
            
            List<Subscription_Vendor__c> subVen = TestDataFactory.createSubscriptionVendor(1);
            subVen[0].Account__c = acct.id;
            subVen[0].Status__c = 'Active';
            insert subVen;
            
            List<Subscription_Vendor_Publication__c> subVenPub = TestDataFactory.createVendorPublication(1);
            subVenPub[0].Subscription_Vendor__c = subVen[0].id;
            insert subVenPub;
            
            
            //FROM Promotion__c WHERE Promotion_Code__c = :promotionCodeParam LIMIT 1]
            List<Promotion__c> promo = TestDataFactory.createPromoList(1);
            promo[0].Name = 'Promotion';
            promo[0].Promotion_Code__c = 'test';
            promo[0].Effective_Start_Date__c = Date.today();
            promo[0].Effective_End_Date__c = Date.today().addDays(30);
            promo[0].Contract__c = 'Yes';
            promo[0].Contract_Period__c = '2';
            promo[0].Penalty_Charge__c = '100';
            promo[0].Penalty_Charge_Override__c = 500.00;   
            
            insert promo;
            //<==
            
            AddressWrapper addWrap = new AddressWrapper();
            addWrap.houseBlockNumber = addressRecList[0].Block_House_Number__c;
            addWrap.levelNumber = addressRecList[0].Level_Number__c;
            addWrap.unitNumber = addressRecList[0].Unit_Number__c;
            addWrap.postalCode = addressRecList[0].Postal_Code__c;
            addWrap.streetName = 'Strawberry St';
            addWrap.buildingName = addressRecList[0].Building_Name__c;
            addWrap.country = 'Singapore';
            addWrap.singpostAddressType = addressRecList[0].Address_Type__c;   
            addWrap.Address1 = 'BLK6 LOT5 Paz Village';
            addWrap.Address2 = addressRecList[0].Address_2__c;
            addWrap.Address3 = addressRecList[0].Address_3__c;
            addWrap.Address4 = addressRecList[0].Address_4__c;
            
            List<ContactWrapper> conWrapList = new List<ContactWrapper>();
            ContactWrapper conWrap = new ContactWrapper();
            conWrap.billingIndicator = 'Y'; 
            conWrap.recipientIndicator = 'Y';
            conWrap.salutation = '';
            conWrap.customerName= cntct[0].FirstName;
            conWrap.nric = cntct[0].NRIC__c;
            conWrap.passport = cntct[0].Passport__c;
            conWrap.homeNumber = cntct[0].Home_Phone_display__c;
            conWrap.mobileNumber1 = cntct[0].Mobile_Number__c;
            conWrap.emailAddress1 = cntct[0].Email;
            conWrap.address = addWrap; 
            conWrapList.add(conWrap);
            
            ContactWrapper conWrap2 = new ContactWrapper();
            conWrap2.billingIndicator = 'Y'; 
            conWrap2.recipientIndicator = 'Y';
            conWrap2.salutation = '';
            conWrap2.customerName= cntct[1].FirstName;
            conWrap2.nric = cntct[1].NRIC__c;
            conWrap2.passport = cntct[1].Passport__c;
            conWrap2.homeNumber = '09107620428';
            conWrap2.mobileNumber1 = cntct[1].Mobile_Number__c;
            conWrap2.emailAddress1 = cntct[1].Email;
            conWrap2.address = addWrap; 
            conWrapList.add(conWrap2);   
            
            //--ulti
            List<Zuora__Subscription__c> subscriptionList = [SELECT Id, Order_Number__c, Order_Line_Item_Number__c, Zuora__CustomerAccount__r.Id, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Zuora__Account__r.Id, Main_Package_1__r.Effective_End_Date__c, Main_Package_1__r.Product_Family_Current_Package__c, Main_Package_1__r.Package_Code__c, Zuora__Account__r.Account_Auto_Number__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Address__r.Country_Name__c, Zuora__CustomerAccount__r.Billing_Type__c FROM Zuora__Subscription__c WHERE Zuora__External_Id__c = :ZuoraExternalId AND Zuora__Status__c = 'Active' LIMIT 1];
            String billAccoutNumber = [select Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where id =: billAcct.Id].Zuora__Zuora_Id__c; 
            SubscriptionWrapper subsWrap = new SubscriptionWrapper();
            subsWrap.subscriptionId = ZuoraExternalId;
            subsWrap.accountNumber = '' +subscriptionList[0].Zuora__Account__r.Account_Auto_Number__c;  // <---- April
            subsWrap.accountRecordType = '';
            subsWrap.billingAccountId =billAccoutNumber;
            subsWrap.recipientId = '1';
            subsWrap.orderType = '';
            subsWrap.creationMode = '';   
            subsWrap.paypalBAID = ''; 
            subsWrap.paypalEmail = '';
            
            OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
            oliWrap.promotioncode = '';
            oliWrap.packagecode = 'afds132';
            oliWrap.addonpackagecode = 'test';
            //oliWrap.ldapId = '';
            oliWrap.quantity = 3;
            oliWrap.startDate = '02/18/2015';
            oliWrap.giftCode = new List<String>();
            oliWrap.giftCode.add('code');
            oliWrap.contractenddate = '12/19/2015';
            
            
            ChangeSubscriptionService.ContactWrapper cWrap = new ChangeSubscriptionService.ContactWrapper();
            ChangeSubscriptionService.OrderLineItemWrapper olWrap = new ChangeSubscriptionService.OrderLineItemWrapper();
            ChangeSubscriptionService.AddressWrapper adWrap = new ChangeSubscriptionService.AddressWrapper();
            ChangeSubscriptionService.SubscriptionWrapper subWrap= new ChangeSubscriptionService.SubscriptionWrapper();
            ChangeSubscriptionService.ChangeSubscriptionServiceRequest request = new ChangeSubscriptionService.ChangeSubscriptionServiceRequest();
    
            system.assertNotEquals(null, cWrap);
            system.assertNotEquals(null, olWrap );
            system.assertNotEquals(null, adWrap );
            system.assertNotEquals(null, subWrap);
            system.assertNotEquals(null, request );
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ChangeSubscriptionService1/*';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= res;
            
            ChangeSubscriptionServiceRequest ChgSubsSvsRequest = new ChangeSubscriptionServiceRequest();
            ChgSubsSvsRequest.subscription = subsWrap;
            ChgSubsSvsRequest.contacts = conWrapList;
            ChgSubsSvsRequest.orderLineItem = oliWrap;
            
          
            
            String jsonStr = JSON.serialize(ChgSubsSvsRequest);
            ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
            system.assertNotEquals(null, esh);
            
            ChangeSubscriptionService.processRequest(esh);  
         
    }

    static testMethod void testIsValidNull02(){
        
            setCustomSettings();
       
            List<Country__c> CtryList = TestDataFactory.createCountry(2);
            CtryList[0].Country_Name__c = 'Singapore';
            CtryList[1].Country_Name__c = 'Philippines';
            insert CtryList;
            
            Recordtype recType = [SELECT Id, Name FROM Recordtype WHERE Name =: 'Vendor'];
            //Account
            Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acct.Recordtypeid = recType.id;
            acct.NRIC__c = 'T1234567R';
            acct.Name = 'Test Account';
            acct.Phone = '123-456';
            acct.Email__c = 'test@test.com';
            acct.Date_of_Birth__c = date.today();
            acct.Gender__c = 'Male';
            acct.Race__c = 'Chinese';
            acct.Language__c = 'Others';
            acct.Contact_Person__c = 'Contact Person';
            acct.Sub_Group__c = 'Freelist(MY)';
            acct.Generate_Account_Number__c = true;
            //acct.AccountNumber = '00112233';
            //acct.Account_Auto_Number__c = '00112233';
            insert acct;
            
            //update acct;
            
            //System.assertEquals(acct.AccountNumber, acct.Account_Auto_Number__c, 'This should be equal.');
    
            // postal
            List<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
            postal[0].Name = 'SPostal';
            postal[0].House_Block_Number__c = 'TEST';
            postal[0].Address_Type__c = 'A';
            postal[0].Building_Name__c = 'Building';
            postal[0].Street_Name__c = 'Street';
            postal[1].Name = 'PPostal';
            postal[1].House_Block_Number__c = 'TEST';
            postal[1].Address_Type__c = 'A';
            postal[1].Building_Name__c = 'Building';
            postal[1].Street_Name__c = 'Street';
            insert postal;
            
            //Address
            List<Address__c> addressRecList = TestDataFactory.createAddress(2);
            addressRecList[0].Address_Type__c = 'A';
            addressRecList[0].Postal_Code__c = postal[0].Id;
            addressRecList[0].Block_House_Number__c ='TEST';
            addressRecList[0].Level_Number__c ='xx';
            addressRecList[0].Unit_Number__c = 'yy';
            addressRecList[0].Country__c = CtryList[0].id;
            addressRecList[0].Address_1__c = 'Address 1';
            addressRecList[0].Address_2__c = 'Address 2';
            addressRecList[0].Address_3__c = 'Address 3';
            addressRecList[0].Address_4__c = 'Address 4';
            addressRecList[1].Address_Type__c = 'A';
            addressRecList[1].Postal_Code__c = postal[1].Id;
            addressRecList[1].Block_House_Number__c ='TEST';
            addressRecList[1].Level_Number__c ='xx';
            addressRecList[1].Unit_Number__c = 'yy';
            addressRecList[1].Country__c = CtryList[1].id;
            addressRecList[1].Address_1__c = 'Address 1';
            addressRecList[1].Address_2__c = 'Address 2';
            addressRecList[1].Address_3__c = 'Address 3';
            addressRecList[1].Address_4__c = 'Address 4';
            insert addressRecList; 
            
            //Contact
            List<Contact> cntct = TestDataFactory.createContact(2);
            cntct[0].Address__c = addressRecList[0].Id;
            cntct[0].AccountId = acct.Id;
            cntct[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
//cntct[0].Recipient_Indicator__c = true;
            cntct[0].Billing_Indicator__c = true;
            cntct[0].FirstName = 'Test';
            cntct[0].LastName = 'Contact';
            cntct[0].Passport__c = 'PassTest';
            cntct[0].HomePhone__c = '123 456';
            cntct[0].Mobile_Number__c = '123456';
            cntct[0].Email = 'test@test.com';
            cntct[1].Address__c = addressRecList[1].Id;
            cntct[1].AccountId = acct.Id;
            cntct[1].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            cntct[1].Billing_Indicator__c = true;
            cntct[1].FirstName = 'Test1';
            cntct[1].LastName = 'Contact';
            insert cntct;
            
            //==>
            // billing account
            Zuora__CustomerAccount__c billAcct = TestDataFactory.createBillingAccount(1)[0];
            billAcct.Zuora__Account__c = acct.Id;
            billAcct.Billing_Contact__c = cntct[1].Id;
            billAcct.Zuora__Zuora_Id__c = 'Test1';
            billAcct.Billing_Type__c = 'Full Prepaid';
            billAcct.Zuora__DefaultPaymentMethod__c = 'Other';
            billAcct.Zuora__AccountNumber__c = '1';
            
            insert billAcct;
    
            // package
            //FROM Package__c WHERE Package_Code__c = :packageCodeParam
            Package__c iPack = TestDataFactory.createPackage(1)[0];
            iPack.Billing_Type__c = 'Full Prepaid';
            iPack.Package_Type__c = 'Grace Period';
            iPack.Subscription_Period__c = '1';
            iPack.Package_Code__c = 'afds132';
            iPack.Product_Family_Current_Package__c = 'test';
            insert iPack;
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.ProductSubType__c = 'Magazine';
            zProduct.zqu__ZuoraId__c = 'Test';
            insert zProduct ;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0]; 
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Proration';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            prdRatePlan.zqu__ZuoraId__c = 'Test';
            insert prdRatePlan;
    
            Product_Family__c prodfam = new Product_Family__c();
            prodfam.Product_Family__c = 'Trythis';
            prodfam.Product_Family_Name__c = 'testtest';
            insert prodfam;
            
            // package item
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = iPack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
            pItem.Product_Family__c = prodfam.Id;
            insert pItem;
            
            Order__c order_c = TestDataFactory.createOrder(1)[0];
            order_c.Account__c = acct.Id;
            order_c.Informed_Customer__c = TRUE;
//order_c.Recipient_Contact__c = cntct[0].Id;
            order_c.Order_Type__c = 'Renewal';
            order_c.Status__c = 'Draft';
            order_c.Eligible_for_Retention__c = TRUE;
            order_c.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order_c.Payment_Mode__c = 'Credit Card';
            order_c.Billing_Account__c = billAcct.id;
            order_c.Billing_Type__c = 'Full Prepaid';
            order_c.Billing_Contact__c = cntct[1].id;
            order_c.Case_Record_Type__c = 'Complaint - Magazine';
            order_c.Category__c = 'Subscription Request';
            order_c.Sub_Category__c ='Stop Subscription';
            order_c.Credit_Balance__c = 0;
            order_c.Delivery_Charge__c = 0;
            order_c.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order_c.Order_Type__c = 'Change of Subscription Package';
            order_c.PO_Number__c = 'PO00000';
            order_c.Payment_Method_ID__c = '2c92c0f949f126b80149f292e0fb527c';
            order_c.Delivery_Charge_Type__c = 'C';
            order_c.Subscriber_Charge__c = 10.00;
            insert order_c;
    
            /*Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order_c.Id;
            insert cas; */
             
            //Order Line Item
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order_c.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.Today().addDays(4);
            orderline.Main_Package_ID__c = iPack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = FALSE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            insert orderline;
            
            // subscrption
            //subscription.Main_Package_1__r.Product_Family_Current_Package__c != packageRecord.Product_Family_Current_Package__c
            
            //FROM Zuora__Subscription__c WHERE Zuora__External_Id__c = :subscriptionId 
            //AND Zuora__Status__c = 'Active' LIMIT 1]
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__Account__c = acct.Id;
            sub.Order_Line_Item_Number__c = orderline.Id;
            sub.Subscriber_Contact__c = cntct[0].Id;
            sub.Recipient_Contact__c = cntct[0].Id;
            sub.Main_Package_1__c = iPack.Id;
            sub.Main_Package__c = iPack.Id;
            sub.Zuora__Status__c = 'Active';
            sub.Order_Number__c = order_c.Id;
            sub.Suppress_Vendor_Start_Notice__c = 'false';
            sub.Supressed_Acknowledgement_Letter__c = 'false';
            sub.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            sub.Urgent__c = 'false';
            sub.Vendor_Conversion__c = 'false';
            sub.Charity__c = 'false';
            sub.Subscription_Type__c = 'Publication';
            sub.Subscription_Type_1__c = 'Publication';
            sub.Zuora__SubscriptionEndDate__c= date.today();
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Zuora__CustomerAccount__c = billAcct.Id;
            sub.Contact__c = cntct[0].id;
            String ZuoraExternalId = 'try1234';
            sub.Zuora__Zuora_Id__c = ZuoraExternalId;
            sub.Zuora__External_Id__c = ZuoraExternalId;
            //sub.Main_Package_1__c = iPack.id;
            insert sub;
            
            List<Publication__c> pub = TestDataFactory.createPublication(1);
            pub[0].Product_Family__c = 'Soap';
            insert pub;
            
            List<Subscription_Vendor__c> subVen = TestDataFactory.createSubscriptionVendor(1);
            subVen[0].Account__c = acct.id;
            subVen[0].Status__c = 'Active';
            insert subVen;
            
            List<Subscription_Vendor_Publication__c> subVenPub = TestDataFactory.createVendorPublication(1);
            subVenPub[0].Subscription_Vendor__c = subVen[0].id;
            insert subVenPub;
            
            
            //FROM Promotion__c WHERE Promotion_Code__c = :promotionCodeParam LIMIT 1]
            List<Promotion__c> promo = TestDataFactory.createPromoList(1);
            promo[0].Name = 'Promotion';
            promo[0].Promotion_Code__c = 'test';
            promo[0].Effective_Start_Date__c = Date.today();
            promo[0].Effective_End_Date__c = Date.today().addDays(30);
            promo[0].Contract__c = 'Yes';
            promo[0].Contract_Period__c = '2';
            promo[0].Penalty_Charge__c = '100';
            promo[0].Penalty_Charge_Override__c = 500.00;   
            
            insert promo;
            //<==
            
            AddressWrapper addWrap = new AddressWrapper();
            addWrap.houseBlockNumber = addressRecList[0].Block_House_Number__c;
            addWrap.levelNumber = addressRecList[0].Level_Number__c;
            addWrap.unitNumber = addressRecList[0].Unit_Number__c;
            addWrap.postalCode = addressRecList[0].Postal_Code__c;
            addWrap.streetName = 'Strawberry St';
            addWrap.buildingName = addressRecList[0].Building_Name__c;
            addWrap.country = 'Singapore';
            addWrap.singpostAddressType = addressRecList[0].Address_Type__c;   
            addWrap.Address1 = 'BLK6 LOT5 Paz Village';
            addWrap.Address2 = addressRecList[0].Address_2__c;
            addWrap.Address3 = addressRecList[0].Address_3__c;
            addWrap.Address4 = addressRecList[0].Address_4__c;
            
            List<ContactWrapper> conWrapList = new List<ContactWrapper>();
            ContactWrapper conWrap = new ContactWrapper();
            conWrap.billingIndicator = 'N'; 
            conWrap.recipientIndicator = 'N';
            conWrap.salutation = 'Mr.';
            conWrap.customerName= cntct[0].FirstName;
            conWrap.nric = cntct[0].NRIC__c;
            conWrap.passport = cntct[0].Passport__c;
            conWrap.homeNumber = cntct[0].Home_Phone_display__c;
            conWrap.mobileNumber1 = cntct[0].Mobile_Number__c;
            conWrap.emailAddress1 = cntct[0].Email;
            conWrap.address = addWrap; 
            conWrapList.add(conWrap);
            
            ContactWrapper conWrap2 = new ContactWrapper();
            conWrap2.billingIndicator = 'N'; 
            conWrap2.recipientIndicator = 'Y';
            conWrap2.salutation = 'Mr.';
            conWrap2.customerName= cntct[1].FirstName;
            conWrap2.nric = cntct[1].NRIC__c;
            conWrap2.passport = cntct[1].Passport__c;
            conWrap2.homeNumber = '09107620428';
            conWrap2.mobileNumber1 = cntct[1].Mobile_Number__c;
            conWrap2.emailAddress1 = cntct[1].Email;
            conWrap2.address = addWrap; 
            conWrapList.add(conWrap2);   
            
            //--ulti
            List<Zuora__Subscription__c> subscriptionList = [SELECT Id, Order_Number__c, Order_Line_Item_Number__c, Zuora__CustomerAccount__r.Id, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Zuora__Account__r.Id, Main_Package_1__r.Effective_End_Date__c, Main_Package_1__r.Product_Family_Current_Package__c, Main_Package_1__r.Package_Code__c, Zuora__Account__r.Account_Auto_Number__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Address__r.Country_Name__c, Zuora__CustomerAccount__r.Billing_Type__c FROM Zuora__Subscription__c WHERE Zuora__External_Id__c = :ZuoraExternalId AND Zuora__Status__c = 'Active' LIMIT 1];
            String billAccoutNumber = [select Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where id =: billAcct.Id].Zuora__Zuora_Id__c; 
            SubscriptionWrapper subsWrap = new SubscriptionWrapper();
            subsWrap.subscriptionId = ZuoraExternalId;
            subsWrap.accountNumber = '' +subscriptionList[0].Zuora__Account__r.Account_Auto_Number__c;  // <---- April
            subsWrap.accountRecordType = '';
            subsWrap.billingAccountId = '1';
            subsWrap.recipientId = '1';     
            subsWrap.orderType = '';
            subsWrap.creationMode = '';   
            subsWrap.paypalBAID = ''; 
            subsWrap.paypalEmail = '';
            
            OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
            oliWrap.promotioncode = '';
            oliWrap.packagecode = 'afds132';
            oliWrap.addonpackagecode = 'test';
            //oliWrap.ldapId = '';
            oliWrap.quantity = 3;
            oliWrap.startDate = '02/18/2015';
            oliWrap.giftCode = new List<String>();
            oliWrap.giftCode.add('code');
            oliWrap.contractenddate = '12/19/2015';
            
/*            
            ChangeSubscriptionService.ContactWrapper cWrap = new ChangeSubscriptionService.ContactWrapper();
            ChangeSubscriptionService.OrderLineItemWrapper olWrap = new ChangeSubscriptionService.OrderLineItemWrapper();
            ChangeSubscriptionService.AddressWrapper adWrap = new ChangeSubscriptionService.AddressWrapper();
            ChangeSubscriptionService.SubscriptionWrapper subWrap= new ChangeSubscriptionService.SubscriptionWrapper();
            ChangeSubscriptionService.ChangeSubscriptionServiceRequest request = new ChangeSubscriptionService.ChangeSubscriptionServiceRequest();
    
            system.assertNotEquals(null, cWrap);
            system.assertNotEquals(null, olWrap );
            system.assertNotEquals(null, adWrap );
            system.assertNotEquals(null, subWrap);
            system.assertNotEquals(null, request );
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ChangeSubscriptionService1/*';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= res;
*/            
            ChangeSubscriptionServiceRequest ChgSubsSvsRequest = new ChangeSubscriptionServiceRequest();
            ChgSubsSvsRequest.subscription = subsWrap;
            ChgSubsSvsRequest.contacts = conWrapList;
            ChgSubsSvsRequest.orderLineItem = oliWrap;
            
            String jsonStr = JSON.serialize(ChgSubsSvsRequest);
            ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
            system.assertNotEquals(null, esh);
            
            ChangeSubscriptionService.processRequest(esh);  
    }
    
    static testMethod void testGetOrder01() {
        
        List<Singpost_Address__c> postalList = TestDataFactory.createSingpostAddress(1);
        Database.insert(postalList);
        
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        acc.Singpost_Address__c = postalList[0].id;
        acc.Active__c = true;
        acc.Vendor_Communication_Preference__c = 'Both';
        Database.insert(acc);
        
        List<Order__c> orderList = TestDataFactory.createOrder(1);
        orderList[0].Account__c = acc.id;
        Database.insert(orderList);
        
        System.assertNotEquals(null, ChangeSubscriptionService.getOrder(orderList[0].id));
    }
    
    
    static testMethod void testSearchAddress01() {
        
        /*SELECT Id, RecordTypeId, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c 
            FROM Address__c WHERE Country__r.Country_Name__c = :addressDetails.country AND Postal_Code__r.Name = :addressDetails.postalCode AND Unit_Number__c = :addressDetails.unitNumber];*/
        
        List<Singpost_Address__c> postalList = TestDataFactory.createSingpostAddress(1);
        postalList[0].Name = 'SGPostalOffice';
        Database.insert(postalList);
        
        List<Country__c> countryList = TestDataFactory.createCountry(1);
        countryList[0].Code__c = GlobalVariableClass.SINGAPORE_CODE;
        countryList[0].Country_Name__c = GlobalVariableClass.SINGAPORE_CODE;
        Database.insert(countryList);
        
        List<Address__c> addressList = TestDataFactory.createAddress(1);
        addressList[0].Country__c = countryList[0].id;
        addressList[0].Postal_Code__c = postalList[0].id;
        addressList[0].Unit_Number__c = '123';
        Database.insert(addressList);
        
        AddressWrapper address = new AddressWrapper();
        address.houseBlockNumber = 'testData';
        address.levelNumber = 'testData';
        address.unitNumber = '123';
        address.postalCode = 'SGPostalOffice';
        address.streetName = 'testData';
        address.buildingName = 'testData';
        address.country = GlobalVariableClass.SINGAPORE_CODE;
        address.singpostAddressType = 'testData';   
        address.Address1 = 'testData';
        address.Address2 = 'testData';
        address.Address3 = 'testData';
        address.Address4 = 'testData';
        
    
        String jsonStr = JSON.serialize(address);
        ChangeSubscriptionService.AddressWrapper addWrap = (ChangeSubscriptionService.AddressWrapper)JSON.deserialize(jsonStr, ChangeSubscriptionService.AddressWrapper.class);
        
        ChangeSubscriptionService.searchAddress(addWrap);
        //System.assertNotEquals(null, ChangeSubscriptionService.searchAddress(addWrap));
    }
    
    
    static testMethod void testCreateAddress01() {
        
        setCustomSettings();
        
        List<Singpost_Address__c> postalList = TestDataFactory.createSingpostAddress(1);
        postalList[0].Name = 'SG123';
        Database.insert(postalList);
        
        List<Country__c> countryList = TestDataFactory.createCountry(1);
        countryList[0].Code__c = GlobalVariableClass.SINGAPORE_CODE;
        Database.insert(countryList);
        
        AddressWrapper address = new AddressWrapper();
        address.houseBlockNumber = 'testData';
        address.levelNumber = '123';
        address.unitNumber = '1234567';
        address.postalCode = 'SG123';
        address.streetName = '1';
        address.buildingName = '1';
        address.country = GlobalVariableClass.SINGAPORE_CODE;
        address.singpostAddressType = 'testData';   
        address.Address1 = 'testData';
        address.Address2 = 'testData';
        address.Address3 = 'testData';
        address.Address4 = 'testData';
        
    
        String jsonStr = JSON.serialize(address);
        ChangeSubscriptionService.AddressWrapper addWrap = (ChangeSubscriptionService.AddressWrapper)JSON.deserialize(jsonStr, ChangeSubscriptionService.AddressWrapper.class);
        
    
        System.assertNotEquals(null, ChangeSubscriptionService.createAddress(addWrap));
    }
    
    
    static testMethod void testIsBillingTypevalid01() {
        
        String billaccBillingType;
        String pkgcode;
        
        //-1
        System.assertEquals(False, ChangeSubscriptionService.isBillingTypevalid(billaccBillingType, pkgcode));
        
        //-2
        billaccBillingType = 'ba';
        System.assertEquals(False, ChangeSubscriptionService.isBillingTypevalid(billaccBillingType, pkgcode));
        
        //-3
        //SELECT Id, Billing_Type__c,Package_Code__c  FROM Package__c WHERE Package_Code__c = :packagecode
        
        List<Package__c> packageList = TestDataFactory.createPackage(1);
        Database.insert(packageList);
        
        billaccBillingType = 'ba';
        pkgcode = 'PackageCode0';
        System.assertEquals(False, ChangeSubscriptionService.isBillingTypevalid(billaccBillingType, pkgcode));
    }
    
    static testMethod void testValidateMandatoryFields01() {
    
        //-1  
        AddressWrapper addWrap = new AddressWrapper();
        addWrap.houseBlockNumber = 'Block_House_Number__c';
        addWrap.levelNumber = 'Level_Number__c';
        addWrap.unitNumber = 'Unit_Number__c';
        addWrap.postalCode = 'Postal_Code__c';
        addWrap.streetName = 'Strawberry St';
        addWrap.buildingName = 'Building_Name__c';
        addWrap.country = 'Singapore';
        addWrap.singpostAddressType = 'Address_Type__c';   
        addWrap.Address1 = 'BLK6 LOT5 Paz Village';
        addWrap.Address2 = 'Address_2__c';
        addWrap.Address3 = 'Address_3__c';
        addWrap.Address4 = 'Address_4__c';
    
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
        ContactWrapper conWrap = new ContactWrapper();
        conWrap.billingIndicator = 'N'; 
        conWrap.recipientIndicator = 'N';
        conWrap.salutation = '';
        conWrap.customerName= 'FirstName';
        conWrap.nric = 'NRIC__c';
        conWrap.passport = 'Passport__c';
        conWrap.homeNumber = 'Home_Phone_display__c';
        conWrap.mobileNumber1 = 'Mobile_Number__c';
        conWrap.emailAddress1 = 'Email';
        conWrap.address = addWrap; 
        conWrapList.add(conWrap);
        
        ContactWrapper conWrap2 = new ContactWrapper();
        conWrap2.billingIndicator = 'N'; 
        conWrap2.recipientIndicator = 'N';
        conWrap2.salutation = '';
        conWrap2.customerName= 'FirstName';
        conWrap2.nric = 'NRIC__c';
        conWrap2.passport = 'Passport__c';
        conWrap2.homeNumber = '09107620428';
        conWrap2.mobileNumber1 = 'Mobile_Number__c';
        conWrap2.emailAddress1 = 'Email';
        conWrap2.address = addWrap; 
        //conWrapList.add(conWrap2);   
        
        SubscriptionWrapper subsWrap = new SubscriptionWrapper();
        subsWrap.subscriptionId = 'ZuoraExternalId';
        subsWrap.accountNumber = null;
        subsWrap.accountRecordType = '';
        subsWrap.billingAccountId ='1';
        subsWrap.recipientId = '';     
        subsWrap.orderType = '';
        subsWrap.creationMode = '';   
        subsWrap.paypalBAID = '1'; 
        subsWrap.paypalEmail = '';
        
        OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
        oliWrap.promotioncode = '';
        oliWrap.packagecode = 'afds132';
        oliWrap.addonpackagecode = 'test';
        //oliWrap.ldapId = '';
        oliWrap.quantity = 3;
        oliWrap.startDate = '02/18/2015';
        oliWrap.giftCode = new List<String>();
        oliWrap.giftCode.add('code');
        oliWrap.contractenddate = '12/19/2015';
                
        ChangeSubscriptionServiceRequest ChgSubsSvsRequest = new ChangeSubscriptionServiceRequest();
        ChgSubsSvsRequest.subscription = subsWrap;
        ChgSubsSvsRequest.contacts = null;
        ChgSubsSvsRequest.orderLineItem = oliWrap;
      
        
        String jsonStr = JSON.serialize(ChgSubsSvsRequest);
        ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
        //if(request.contacts == null)
        //if(request.contacts.size() == 1)
        /*if((request.subscription.billingAccountId != null && request.subscription.billingAccountId != '') &&
            ((request.subscription.paypalBAID != null && request.subscription.paypalBAID != '') || (request.subscription.paypalEmail != null && request.subscription.paypalEmail != '')))*/   
            
        System.assertEquals(False, ChangeSubscriptionService.validateMandatoryFields(esh));
        
        //-2
        subsWrap = new SubscriptionWrapper();
        subsWrap.subscriptionId = 'ZuoraExternalId';
        subsWrap.accountNumber = null;
        subsWrap.accountRecordType = '';
        subsWrap.billingAccountId =null;
        subsWrap.recipientId = '';     
        subsWrap.orderType = '';
        subsWrap.creationMode = '';   
        subsWrap.paypalBAID = null; 
        subsWrap.paypalEmail = '1';
        
        ChgSubsSvsRequest.subscription = subsWrap;
        ChgSubsSvsRequest.contacts = conWrapList;
        ChgSubsSvsRequest.orderLineItem = oliWrap;
        
        jsonStr = JSON.serialize(ChgSubsSvsRequest);
        esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
        /*if(request.subscription.paypalEmail != null && request.subscription.paypalEmail != '' && (request.subscription.paypalBAID == null || request.subscription.paypalBAID == ''))*/
        System.assertEquals(False, ChangeSubscriptionService.validateMandatoryFields(esh));
        
        //-3
        conWrapList.add(conWrap2);
        ChgSubsSvsRequest.subscription = subsWrap;
        ChgSubsSvsRequest.contacts = conWrapList;
        ChgSubsSvsRequest.orderLineItem = oliWrap;
        
        jsonStr = JSON.serialize(ChgSubsSvsRequest);
        esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
        /*if(contactWrapper1.recipientIndicator != 'Y' && contactWrapper2.recipientIndicator != 'Y')*/
        System.assertEquals(False, ChangeSubscriptionService.validateMandatoryFields(esh));
        
        //-4
        ContactWrapper conWrap3 = new ContactWrapper();
        conWrapList.add(conWrap3);
        ChgSubsSvsRequest.subscription = subsWrap;
        ChgSubsSvsRequest.contacts = conWrapList;
        ChgSubsSvsRequest.orderLineItem = oliWrap;
        
        jsonStr = JSON.serialize(ChgSubsSvsRequest);
        esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
        /*if(request.contacts.size() > 2)*/
        System.assertEquals(False, ChangeSubscriptionService.validateMandatoryFields(esh));
        
        //-4.1
        subsWrap = new SubscriptionWrapper();
        subsWrap.subscriptionId = 'ZuoraExternalId';
        subsWrap.accountNumber = null;
        subsWrap.accountRecordType = '';
        subsWrap.billingAccountId = null;
        subsWrap.recipientId = '';     
        subsWrap.orderType = '';
        subsWrap.creationMode = '';   
        subsWrap.paypalBAID = null; 
        subsWrap.paypalEmail = null;
        
        conWrapList = new List<ContactWrapper>();
        
        ChgSubsSvsRequest.subscription = subsWrap;
        ChgSubsSvsRequest.contacts = conWrapList;
        ChgSubsSvsRequest.orderLineItem = oliWrap;
        
        jsonStr = JSON.serialize(ChgSubsSvsRequest);
        esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
        /*if(request.contacts.size() == 0)*/
        System.assertEquals(False, ChangeSubscriptionService.validateMandatoryFields(esh));
        
        //-5
        subsWrap = new SubscriptionWrapper();
        subsWrap.subscriptionId = 'ZuoraExternalId';
        subsWrap.accountNumber = null;
        subsWrap.accountRecordType = '';
        subsWrap.billingAccountId = null;
        subsWrap.recipientId = '';     
        subsWrap.orderType = '';
        subsWrap.creationMode = '';   
        subsWrap.paypalBAID = null; 
        subsWrap.paypalEmail = null;
        
        ChgSubsSvsRequest.subscription = subsWrap;
        ChgSubsSvsRequest.contacts = null;
        ChgSubsSvsRequest.orderLineItem = oliWrap;
        
        jsonStr = JSON.serialize(ChgSubsSvsRequest);
        esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
        /*if(request.contacts == null)*/
        System.assertEquals(False, ChangeSubscriptionService.validateMandatoryFields(esh));
        
        //-6
        conWrapList = new List<ContactWrapper>();
        conWrapList.add(conWrap);
        
        ChgSubsSvsRequest.subscription = subsWrap;
        ChgSubsSvsRequest.contacts = conWrapList;
        ChgSubsSvsRequest.orderLineItem = oliWrap;
        
        jsonStr = JSON.serialize(ChgSubsSvsRequest);
        esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
        /*if(request.contacts.size() == 1)*/
        System.assertEquals(False, ChangeSubscriptionService.validateMandatoryFields(esh));
        
        
        //-7
        conWrapList.add(conWrap2);
        
        ChgSubsSvsRequest.subscription = subsWrap;
        ChgSubsSvsRequest.contacts = conWrapList;
        ChgSubsSvsRequest.orderLineItem = oliWrap;
        
        jsonStr = JSON.serialize(ChgSubsSvsRequest);
        esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
        /*if(request.contacts.size() == 1)*/
        System.assertEquals(False, ChangeSubscriptionService.validateMandatoryFields(esh));
        
        //-8
        conWrapList.add(conWrap2);
        conWrapList.add(conWrap3);
        
        ChgSubsSvsRequest.subscription = subsWrap;
        ChgSubsSvsRequest.contacts = conWrapList;
        ChgSubsSvsRequest.orderLineItem = oliWrap;
        
        jsonStr = JSON.serialize(ChgSubsSvsRequest);
        esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
        /*else if(contactCountPrintFlag == false)*/
        System.assertEquals(False, ChangeSubscriptionService.validateMandatoryFields(esh));
        
    }
}