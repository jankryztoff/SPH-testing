/**
   @Author Val Lu
   @name ChangeSubscriptionServiceTest 
   @CreateDate 02/26/2015
   @Modified by Ana Dumangas
   @Modified date 6/19/15  
   @Description To test ChangeSubscriptionService class
   @Version <1.0>
  */
@isTest (seeAllData= True)                    
private class ChangeSubscriptionServiceTest { 

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

    /**
    *  To test ChangeSubscriptionService class
    *  @name testChangeSubscriptionService1
    *  @param none
    *  @return none
    *  @throws na
    */      
    static testMethod void testChangeSubscriptionService1(){
        
       
            List<Country__c> CtryList = TestDataFactory.createCountry(2);
            CtryList[0].Country_Name__c = 'Singapore';
            CtryList[1].Country_Name__c = 'Philippines';
            insert CtryList;
            
            //Account
            Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
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
            
            sub.Zuora__External_Id__c = ZuoraExternalId;
            //sub.Main_Package_1__c = iPack.id;
            insert sub;
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
            
            SubscriptionWrapper subsWrap = new SubscriptionWrapper();
            subsWrap.subscriptionId = ZuoraExternalId;
            subsWrap.accountNumber = ''+subscriptionList[0].Zuora__Account__r.Account_Auto_Number__c;  // <---- April
            subsWrap.accountRecordType = '';
            subsWrap.billingAccountId = '';
            subsWrap.recipientId = '';     
            subsWrap.orderType = '';
            subsWrap.creationMode = '';    
            
            OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
            oliWrap.promotioncode = 'test';
            oliWrap.packagecode = 'afds132';
            oliWrap.addonpackagecode = 'test';
            //oliWrap.ldapId = '';
            oliWrap.quantity = 3;
            oliWrap.startDate = '02/18/2015';
            oliWrap.giftCode = new List<String>();
            oliWrap.giftCode.add('code');
            oliWrap.contractenddate = '02/19/2015';
            
            
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
            req.requestURI = '/services/apexrest/ChangeSubscriptionService/*';
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
         
            
            List<ContactWrapper> conWrapListEmpty = new List<ContactWrapper>();
            ChangeSubscriptionServiceRequest ChgSubsSvsRequest1 = new ChangeSubscriptionServiceRequest();
            
            system.assertNotEquals(null, ChgSubsSvsRequest1);
            
            ChgSubsSvsRequest1.subscription = subsWrap;
            ChgSubsSvsRequest1.contacts = conWrapListEmpty;
            ChgSubsSvsRequest1.orderLineItem = oliWrap;
            
             String orderLineItemId =  String.valueOf(orderline.id);
            
            
            String jsonStr1 = JSON.serialize(ChgSubsSvsRequest1);
            ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh1 = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr1, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            Order_Line_Item__c returnA =  ChangeSubscriptionService.getOrderLineItem(orderLineItemId);
           
            system.assertNotEquals(null, esh1);
            
            ChangeSubscriptionService.processRequest(esh1);
    }
   
  
    /**
    *  To test ChangeSubscriptionService class
    *  @name testChangeSubscriptionService2
    *  @param none
    *  @return none
    *  @throws na
    */     
   static testMethod void testChangeSubscriptionService2(){
            List<Country__c> CtryList = TestDataFactory.createCountry(2);
            CtryList[0].Country_Name__c = 'Singapore';
            CtryList[1].Country_Name__c = 'Philippines';
            insert CtryList;
            
            //Account
            Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
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
            acct.AccountNumber = '00112233';
            insert acct;
    
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
            cntct[0].Recipient_Indicator__c = true;
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
            order_c.Recipient_Contact__c = cntct[0].Id;
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
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__Account__c = acct.Id;
            sub.Order_Line_Item_Number__c = orderline.Id;
            sub.Subscriber_Contact__c = cntct[0].Id;
            sub.Recipient_Contact__c = cntct[0].Id;
            sub.Main_Package_1__c = iPack.Id;
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
            sub.Zuora__External_Id__c = 'try1234';
            sub.Main_Package_1__c = iPack.id;
            insert sub;
            
            Test.startTest();
            
            AddressWrapper addWrapSIN = new AddressWrapper();
            addWrapSIN.houseBlockNumber = addressRecList[1].Block_House_Number__c;
            addWrapSIN.levelNumber = addressRecList[1].Level_Number__c;
            addWrapSIN.unitNumber = addressRecList[1].Unit_Number__c;
            addWrapSIN.postalCode = addressRecList[1].Postal_Code__c;
            addWrapSIN.streetName = 'Strawberry St';
            addWrapSIN.buildingName = addressRecList[1].Building_Name__c;
            addWrapSIN.country = 'SIN';
            addWrapSIN.singpostAddressType = addressRecList[1].Address_Type__c;   
            addWrapSIN.Address1 = 'BLK6 LOT5 Paz Village';
            addWrapSIN.Address2 = addressRecList[1].Address_2__c;
            addWrapSIN.Address3 = addressRecList[1].Address_3__c;
            addWrapSIN.Address4 = addressRecList[1].Address_4__c;
            
            AddressWrapper addWrapPH = new AddressWrapper();
            addWrapPH.houseBlockNumber = addressRecList[1].Block_House_Number__c;
            addWrapPH.levelNumber = addressRecList[1].Level_Number__c;
            addWrapPH.unitNumber = addressRecList[1].Unit_Number__c;
            addWrapPH.postalCode = addressRecList[1].Postal_Code__c;
            addWrapPH.streetName = 'Strawberry St';
            addWrapPH.buildingName = addressRecList[1].Building_Name__c;
            addWrapPH.country = 'PH';
            addWrapPH.singpostAddressType = addressRecList[1].Address_Type__c;   
            addWrapPH.Address1 = 'BLK6 LOT5 Paz Village';
            addWrapPH.Address2 = addressRecList[1].Address_2__c;
            addWrapPH.Address3 = addressRecList[1].Address_3__c;
            addWrapPH.Address4 = addressRecList[1].Address_4__c;     
            
            List<ContactWrapper> conWrapList = new List<ContactWrapper>();
            ContactWrapper conWrap = new ContactWrapper();
            conWrap.billingIndicator = 'Y'; 
            conWrap.customerName = cntct[0].FirstName;
            conWrap.recipientIndicator = 'Y';
            conWrap.salutation = '';
            conWrap.nric = cntct[0].NRIC__c;
            conWrap.passport = cntct[0].Passport__c;
            conWrap.homeNumber = cntct[0].Home_Phone_display__c;
            conWrap.mobileNumber1 = cntct[0].Mobile_Number__c;
            conWrap.emailAddress1 = cntct[0].Email;
            conWrap.address = addWrapSIN; 
            conWrapList.add(conWrap);
            
            ContactWrapper conWrap2 = new ContactWrapper();
            conWrap2.billingIndicator = 'Y'; 
            conWrap2.customerName = cntct[1].FirstName;
            conWrap2.recipientIndicator = 'Y';
            conWrap2.salutation = '';
            conWrap2.nric = cntct[1].NRIC__c;
            conWrap2.passport = cntct[1].Passport__c;
            conWrap2.homeNumber = '09107620428';
            conWrap2.mobileNumber1 = cntct[1].Mobile_Number__c;
            conWrap2.emailAddress1 = cntct[1].Email;
            conWrap2.address = addWrapPH; 
            conWrapList.add(conWrap2);   
            
            //Test.startTest();
            
            OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
            oliWrap.promotioncode = 'test';
            oliWrap.packagecode = 'test';
            oliWrap.addonpackagecode = 'test';
            oliWrap.ldapId = 'Test1';
            oliWrap.quantity = 3;
            oliWrap.startDate = '02/18/2015';
            //oliWrap.giftCode = new List<String>();
            oliWrap.contractenddate = '02/19/2015';
            
            String accAutoNumber = [select Account_Auto_Number__c from Account where id =: acct.Id].Account_Auto_Number__c; 
            
            String billAccoutNumber = [select Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where id =: billAcct.Id].Zuora__Zuora_Id__c; 
            
            SubscriptionWrapper subsWrap = new SubscriptionWrapper();
            subsWrap.subscriptionId = sub.Zuora__Zuora_Id__c;
            subsWrap.accountNumber = accAutoNumber;
            subsWrap.accountRecordType = '';
           // subsWrap.billingAccountId ='';// billAccoutNumber;
            subsWrap.recipientId = cntct[0].id;     
            subsWrap.orderType = '';
            subsWrap.creationMode = '';    
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ChangeSubscriptionService/*';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= res;
            
            ChangeSubscriptionServiceRequest ChgSubsSvsRequest = new ChangeSubscriptionServiceRequest();
            
            system.assertNotEquals(null, ChgSubsSvsRequest);
            
            ChgSubsSvsRequest.subscription = subsWrap;
            ChgSubsSvsRequest.contacts = conWrapList;
            ChgSubsSvsRequest.orderLineItem = oliWrap;
            
            String subscriptionIdParam = 'A';
            String accountNumberParam = acct.Account_Auto_Number__c;
            String productFamilyParam = 'test';
            String countryCodeParam = 'code1';
            String postalCodeParam = 'code2';
            String levelNumberParam = 'code3';
            String unitNumberParam = 'code4';
           // String orderLineItemId = String.valueOf(orderline.id);
            
            // test service
            String jsonStr = JSON.serialize(ChgSubsSvsRequest);
            ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            Boolean returnA = ChangeSubscriptionService.validateSimilarSubscriptions(subscriptionIdParam,accountNumberParam, productFamilyParam, countryCodeParam, postalCodeParam, levelNumberParam, unitNumberParam);
            //Order_Line_Item__c returnO = ChangeSubscriptionService.getOrderLineItem(orderLineItemId);
            system.assertNotEquals(null, esh);
            
            ChangeSubscriptionService.processRequest(esh); 
            
            Test.stopTest();
    }  

    /**
    *  To test ChangeSubscriptionService class
    *  @name testChangeSubscriptionService3
    *  @param none
    *  @return none
    *  @throws na
   */     
 static testMethod void testChangeSubscriptionService3(){
            List<Country__c> CtryList = TestDataFactory.createCountry(2);
            CtryList[0].Country_Name__c = 'Singapore';
            CtryList[1].Country_Name__c = 'Philippines';
            insert CtryList;
            
            //Account
            Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
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
            insert acct;
    
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
            
            Test.startTest();
            
            // get account
            Account acct1 = ChangeSubscriptionService.getAccount(acct.Account_Auto_Number__c);
            system.assertEquals(null, acct1);
            
            // get contact
            //Contact cntct1 = ChangeSubscriptionService.getContact(cntct[0].id);
            List<Contact> contactList = [SELECT Id, Address__r.RecordTypeId, Account.Account_Auto_Number__c FROM Contact WHERE Id =: cntct[0].id];        
            Contact cntct1 = ChangeSubscriptionService.getContact(cntct[0].id, contactList.get(0).Account.Account_Auto_Number__c);
            system.assertNotEquals(null, cntct1);
            
            // country does not exist
            Country__c cntry1 = ChangeSubscriptionService.getCountry('DoesNotExists');
            system.assertEquals(null, cntry1);
            
            // country exist
            Country__c cntry2 = ChangeSubscriptionService.getCountry(CtryList[0].Code__c);
            system.assertNotEquals(null, cntry2);
            
            // address does not exist
            Singpost_Address__c singAdd1 = ChangeSubscriptionService.getSingpostAddress('DoesNotExists');
            system.assertEquals(null, singAdd1);
            
            // address exist
            Singpost_Address__c singAdd2 = ChangeSubscriptionService.getSingpostAddress(Postal[0].name);
            system.assertNotEquals(null, singAdd2);
            
            // billing account
            Zuora__CustomerAccount__c bill = ChangeSubscriptionService.getBillingAccount('DoesNotExists');
            system.assertEquals(null, bill);
            
            // order
            Order__c ord = ChangeSubscriptionService.getOrder('DoesNotExists');
            system.assertEquals(null, ord);
            
       
            Test.stopTest();
    }
   
    /**
    *  To test ChangeSubscriptionService class
    *  @name testChangeSubscriptionService4
    *  @param none
    *  @return none
    *  @throws na
    */     
 /*APRIL static testMethod void testChangeSubscriptionService4(){
            List<Country__c> CtryList = TestDataFactory.createCountry(2);
            CtryList[0].Country_Name__c = 'Singapore';
            CtryList[1].Country_Name__c = 'Philippines';
            insert CtryList;
            
            //Account
            Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
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
            insert acct;
    
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
            cntct[0].Recipient_Indicator__c = true;
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
    
            List<Package__c> iPack = TestDataFactory.createPackage(5);
            iPack[0].Billing_Type__c = 'Full Prepaid';
            iPack[0].Package_Type__c = 'Base Product';
            iPack[0].Subscription_Period__c = '12';
            iPack[0].Package_Code__c = 'afds132';
            iPack[1].Billing_Type__c = 'Full Prepaid';
            iPack[1].Package_Type__c = 'Base Product';
            iPack[1].Subscription_Period__c = '24';
            iPack[1].Package_Code__c = '132afds';
            
            iPack[2].Billing_Type__c = 'Full Prepaid';
            iPack[2].Package_Type__c = 'Base Product';
            iPack[2].Subscription_Period__c = '24';
            iPack[2].Package_Sub_Type__c = 'Termed';
            iPack[2].Package_Code__c = '132qwer';
            
            iPack[3].Billing_Type__c = 'Full Prepaid';
            iPack[3].Package_Type__c = 'Base Product';
            iPack[3].Subscription_Period__c = '24';
            iPack[3].Package_Sub_Type__c = 'Single';
            iPack[3].Package_Code__c = '132poiu';
            
            iPack[4].Billing_Type__c = 'Full Prepaid';
            iPack[4].Package_Type__c = 'Base Product';
            iPack[4].Subscription_Period__c = '12';
            iPack[4].Package_Code__c = 'ghfg132';
            insert iPack;
     
            List<zqu__ZProduct__c> zProduct = TestDataFactory.createZProduct(5);
            zProduct[0].ProductSubType__c = 'Magazine';
            zProduct[0].zqu__ZuoraId__c = 'Test1';
            zProduct[1].ProductSubType__c = 'Magazine';
            zProduct[1].zqu__ZuoraId__c = 'Test2';
            zProduct[2].ProductSubType__c = 'Magazine';
            zProduct[2].zqu__ZuoraId__c = 'Test3';
            zProduct[3].ProductSubType__c = 'Magazine';
            zProduct[3].zqu__ZuoraId__c = 'Test4';
            zProduct[4].ProductSubType__c = 'Newspaper';
            zProduct[4].zqu__ZuoraId__c = 'Test5';
            insert zProduct ;
            
            List<zqu__ProductRatePlan__c> prdRatePlan = TestDataFactory.createProductRatePlan(5); 
            prdRatePlan[0].zqu__ZProduct__c = zProduct[0].Id;
            prdRatePlan[0].RatePlanType__c= 'Bill Plan';
            prdRatePlan[0].zqu__EffectiveStartDate__c= date.today();
            prdRatePlan[0].zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan[0].zqu__Deleted__c = false;
            prdRatePlan[0].zqu__ZuoraId__c = 'Test1';
            prdRatePlan[1].zqu__ZProduct__c = zProduct[1].Id;
            prdRatePlan[1].RatePlanType__c= 'Bill Plan';
            prdRatePlan[1].zqu__EffectiveStartDate__c= date.today();
            prdRatePlan[1].zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan[1].zqu__Deleted__c = false;
            prdRatePlan[1].zqu__ZuoraId__c = 'Test2';
            
            prdRatePlan[2].zqu__ZProduct__c = zProduct[2].Id;
            prdRatePlan[2].RatePlanType__c= 'Bill Plan';
            prdRatePlan[2].zqu__EffectiveStartDate__c= date.today();
            prdRatePlan[2].zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan[2].zqu__Deleted__c = false;
            prdRatePlan[2].zqu__ZuoraId__c = 'Test3';
            prdRatePlan[3].zqu__ZProduct__c = zProduct[3].Id;
            prdRatePlan[3].zqu__EffectiveStartDate__c= date.today();
            prdRatePlan[3].zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan[3].zqu__Deleted__c = false;
            prdRatePlan[3].zqu__ZuoraId__c = 'Test4'; 
            prdRatePlan[3].RatePlanType__c = 'Discount';
            
            prdRatePlan[4].zqu__ZProduct__c = zProduct[4].Id;
            prdRatePlan[4].RatePlanType__c= 'Bill Plan';
            prdRatePlan[4].zqu__EffectiveStartDate__c= date.today();
            prdRatePlan[4].zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan[4].zqu__Deleted__c = false;
            prdRatePlan[4].zqu__ZuoraId__c = 'Test5';       
            insert prdRatePlan;
            
            // package item
            List<Package_Item__c> pItem = TestDataFactory.createPackageItem(5,'Base Product');
            pItem[0].Package__c = iPack[0].id;
            pItem[0].Product_Rate_Plan__c = prdRatePlan[0].id;
            pItem[0].Name = 'Test Pack Item1';
            pItem[1].Package__c = iPack[1].id;
            pItem[1].Product_Rate_Plan__c = prdRatePlan[1].id;
            pItem[1].Name = 'Test Pack Item2';
            
            pItem[2].Package__c = iPack[2].id;
            pItem[2].Product_Rate_Plan__c = prdRatePlan[2].id;
            pItem[2].Name = 'Test Pack Item3';
            
            pItem[3].Package__c = iPack[2].id;
            pItem[3].Product_Rate_Plan__c = prdRatePlan[3].id;
            pItem[3].Name = 'Test Pack Item4';
            pItem[3].Effective_Start_Month__c = '1';
            pItem[3].Duration_in_months__c = '2';
            pItem[3].RecordTypeId = constantsSLB.getKeyID('Package Item_Discount');
            pItem[3].Base_Package_Item__c = pItem[2].id;
       
       
            pItem[4].Package__c = iPack[4].id;
            pItem[4].Product_Rate_Plan__c = prdRatePlan[4].id;
            pItem[4].Name = 'Test Pack Item5';   
            insert pItem;
            
            
            /*Test.startTest();
     
            // Magazine - 12
            String  RenewPackageCode = ChangeSubscriptionService.getRenewalPackageCode(iPack[0].Package_Code__c);
            system.assertEquals(null, RenewPackageCode);
            
            // Magazine - 24
            String  RenewPackageCode1 = ChangeSubscriptionService.getRenewalPackageCode(iPack[1].Package_Code__c);
            system.assertEquals(null, RenewPackageCode1);
            
            // Magazine - 12 discounted = true;
            String  RenewPackageCode2 = ChangeSubscriptionService.getRenewalPackageCode(iPack[2].Package_Code__c);
            system.assertEquals(null, RenewPackageCode2);
            
            // Magazine - 24 discounted = true;
            String  RenewPackageCode3 = ChangeSubscriptionService.getRenewalPackageCode(iPack[3].Package_Code__c);
            system.assertEquals(null, RenewPackageCode3);
            
            // Newspaper 
            String  RenewPackageCode4 = ChangeSubscriptionService.getRenewalPackageCode(iPack[4].Package_Code__c);
            system.assertEquals(null, RenewPackageCode4);
            
            
            
            Test.stopTest(); */
              
//APRIL }

    /**
    *  To test ChangeSubscriptionService class
    *  @name testChangeSubscriptionService5
    *  @param none
    *  @return none
    *  @throws na
    */      
/*APRIL   static testMethod void testChangeSubscriptionService5(){
            List<Country__c> CtryList = TestDataFactory.createCountry(2);
            CtryList[0].Country_Name__c = 'Singapore';
            CtryList[1].Country_Name__c = 'Philippines';
            insert CtryList;
            
            //Account
            Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
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
            insert acct;
    
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
            
            SubscriptionWrapper subsWrap = new SubscriptionWrapper();
            subsWrap.subscriptionId = '';
            subsWrap.accountNumber = '';
            subsWrap.accountRecordType = '';
            subsWrap.billingAccountId = '';
            subsWrap.recipientId = '';     
            subsWrap.orderType = '';
            subsWrap.creationMode = '';    
            
            OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
            oliWrap.promotioncode = 'test';
            oliWrap.packagecode = 'test';
            oliWrap.addonpackagecode = 'test';
            //oliWrap.ldapId = '';
            oliWrap.quantity = 3;
            oliWrap.startDate = '02/18/2015';
            //oliWrap.giftCode = new List<String>();
            oliWrap.contractenddate = '02/19/2015';
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ChangeSubscriptionService/*';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= res;
            
            ChangeSubscriptionServiceRequest ChgSubsSvsRequest = new ChangeSubscriptionServiceRequest();
            ChgSubsSvsRequest.subscription = subsWrap;
            ChgSubsSvsRequest.contacts = null;
            ChgSubsSvsRequest.orderLineItem = oliWrap;
            
          
            
            String jsonStr = JSON.serialize(ChgSubsSvsRequest);
            ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
            system.assertNotEquals(null, esh);
            
            ChangeSubscriptionService.processRequest(esh);  
         
            
            List<ContactWrapper> conWrapListEmpty = new List<ContactWrapper>();
            ChangeSubscriptionServiceRequest ChgSubsSvsRequest1 = new ChangeSubscriptionServiceRequest();
            
            system.assertNotEquals(null, ChgSubsSvsRequest1);
            
            ChgSubsSvsRequest1.subscription = subsWrap;
            ChgSubsSvsRequest1.contacts = conWrapListEmpty;
            ChgSubsSvsRequest1.orderLineItem = oliWrap;
            
            String jsonStr1 = JSON.serialize(ChgSubsSvsRequest1);
            ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh1 = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr1, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            
            system.assertNotEquals(null, esh1);
            
            ChangeSubscriptionService.processRequest(esh1);
    }APRIL */
    
  
  static testMethod void testChangeSubscriptionService5(){
    
     List<Country__c> CtryList = TestDataFactory.createCountry(2);
            CtryList[0].Country_Name__c = 'Singapore';
            CtryList[1].Country_Name__c = 'Philippines';
            insert CtryList;
            
            //Account
            Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
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
            //FROM Zuora__Subscription__c WHERE Zuora__External_Id__c = :subscriptionId 
            //AND Zuora__Status__c = 'Active' LIMIT 1]
            Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
            sub.Zuora__Account__c = acct.Id;
            sub.Order_Line_Item_Number__c = orderline.Id;
            sub.Subscriber_Contact__c = cntct[0].Id;
            sub.Recipient_Contact__c = cntct[0].Id;
            sub.Main_Package_1__c = iPack.Id;
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
            
            sub.Zuora__External_Id__c = ZuoraExternalId;
            sub.Main_Package_1__c = iPack.id;
            insert sub;
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
            
            SubscriptionWrapper subsWrap = new SubscriptionWrapper();
            subsWrap.subscriptionId = ZuoraExternalId;
            subsWrap.accountNumber = ''+subscriptionList[0].Zuora__Account__r.Account_Auto_Number__c;  // <---- April
            subsWrap.accountRecordType = '';
            //subsWrap.billingAccountId = '';
            subsWrap.recipientId = '';     
            subsWrap.orderType = '';
            subsWrap.creationMode = '';    
            
            OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
            oliWrap.promotioncode = 'null';
            oliWrap.packagecode = 'afds132';
            oliWrap.addonpackagecode = 'test';
            //oliWrap.ldapId = '';
            oliWrap.quantity = 3;
            oliWrap.startDate = '02/18/2015';
            //oliWrap.giftCode = new List<String>();
            oliWrap.contractenddate = '02/19/2015';
            
            
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
            req.requestURI = '/services/apexrest/ChangeSubscriptionService/*';
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
         
            
            List<ContactWrapper> conWrapListEmpty = new List<ContactWrapper>();
            ChangeSubscriptionServiceRequest ChgSubsSvsRequest1 = new ChangeSubscriptionServiceRequest();
            
            system.assertNotEquals(null, ChgSubsSvsRequest1);
            
            ChgSubsSvsRequest1.subscription = subsWrap;
            ChgSubsSvsRequest1.contacts = conWrapListEmpty;
            ChgSubsSvsRequest1.orderLineItem = oliWrap;
            
             String orderLineItemId =  String.valueOf(orderline.id);
            
            
            String jsonStr1 = JSON.serialize(ChgSubsSvsRequest1);
            ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh1 = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr1, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            Order_Line_Item__c returnA =  ChangeSubscriptionService.getOrderLineItem(orderLineItemId);
            system.assertNotEquals(null, esh1);
            
            ChangeSubscriptionService.processRequest(esh1);
    }
   
  
    /**
    *  To test ChangeSubscriptionService class
    *  @name testChangeSubscriptionService2
    *  @param none
    *  @return none
    *  @throws na
    */     
   static testMethod void testgetContactisNull(){
            List<Country__c> CtryList = TestDataFactory.createCountry(2);
            CtryList[0].Country_Name__c = 'Singapore';
            CtryList[1].Country_Name__c = 'Philippines';
            insert CtryList;
            
            //Account
            Account acct = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
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
            acct.AccountNumber = '00112233';
            insert acct;
    
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
            cntct[0].Recipient_Indicator__c = true;
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
            order_c.Recipient_Contact__c = cntct[0].Id;
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
            sub.Zuora__External_Id__c = 'try1234';
            insert sub;
            
            Test.startTest();
            
            AddressWrapper addWrapSIN = new AddressWrapper();
            addWrapSIN.houseBlockNumber = addressRecList[1].Block_House_Number__c;
            addWrapSIN.levelNumber = addressRecList[1].Level_Number__c;
            addWrapSIN.unitNumber = addressRecList[1].Unit_Number__c;
            addWrapSIN.postalCode = addressRecList[1].Postal_Code__c;
            addWrapSIN.streetName = 'Strawberry St';
            addWrapSIN.buildingName = addressRecList[1].Building_Name__c;
            addWrapSIN.country = 'SIN';
            addWrapSIN.singpostAddressType = addressRecList[1].Address_Type__c;   
            addWrapSIN.Address1 = 'BLK6 LOT5 Paz Village';
            addWrapSIN.Address2 = addressRecList[1].Address_2__c;
            addWrapSIN.Address3 = addressRecList[1].Address_3__c;
            addWrapSIN.Address4 = addressRecList[1].Address_4__c;
            
            AddressWrapper addWrapPH = new AddressWrapper();
            addWrapPH.houseBlockNumber = addressRecList[1].Block_House_Number__c;
            addWrapPH.levelNumber = addressRecList[1].Level_Number__c;
            addWrapPH.unitNumber = addressRecList[1].Unit_Number__c;
            addWrapPH.postalCode = addressRecList[1].Postal_Code__c;
            addWrapPH.streetName = 'Strawberry St';
            addWrapPH.buildingName = addressRecList[1].Building_Name__c;
            addWrapPH.country = 'PH';
            addWrapPH.singpostAddressType = addressRecList[1].Address_Type__c;   
            addWrapPH.Address1 = 'BLK6 LOT5 Paz Village';
            addWrapPH.Address2 = addressRecList[1].Address_2__c;
            addWrapPH.Address3 = addressRecList[1].Address_3__c;
            addWrapPH.Address4 = addressRecList[1].Address_4__c;     
            
            List<ContactWrapper> conWrapList = new List<ContactWrapper>();
            ContactWrapper conWrap = new ContactWrapper();
            conWrap.billingIndicator = 'Y'; 
            conWrap.customerName = cntct[0].FirstName;
            conWrap.recipientIndicator = 'Y';
            conWrap.salutation = '';
            conWrap.nric = cntct[0].NRIC__c;
            conWrap.passport = cntct[0].Passport__c;
            conWrap.homeNumber = cntct[0].Home_Phone_display__c;
            conWrap.mobileNumber1 = cntct[0].Mobile_Number__c;
            conWrap.emailAddress1 = cntct[0].Email;
            conWrap.address = addWrapSIN; 
            conWrapList.add(conWrap);
            
            ContactWrapper conWrap2 = new ContactWrapper();
            conWrap2.billingIndicator = 'Y'; 
            conWrap2.customerName = cntct[1].FirstName;
            conWrap2.recipientIndicator = 'Y';
            conWrap2.salutation = '';
            conWrap2.nric = cntct[1].NRIC__c;
            conWrap2.passport = cntct[1].Passport__c;
            conWrap2.homeNumber = '09107620428';
            conWrap2.mobileNumber1 = cntct[1].Mobile_Number__c;
            conWrap2.emailAddress1 = cntct[1].Email;
            conWrap2.address = addWrapPH; 
            conWrapList.add(conWrap2);   
            
            //Test.startTest();
            
            OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
            oliWrap.promotioncode = '';
            oliWrap.packagecode = 'afds132';
            oliWrap.addonpackagecode = 'test';
            oliWrap.ldapId = 'Test1';
            oliWrap.quantity = 3;
            oliWrap.startDate = '02/18/2015';
            //oliWrap.giftCode = new List<String>();
            oliWrap.contractenddate = '02/19/2015';
            
            String accAutoNumber = [select Account_Auto_Number__c from Account where id =: acct.Id].Account_Auto_Number__c; 
            
            String billAccoutNumber = [select Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where id =: billAcct.Id].Zuora__Zuora_Id__c; 
            
            SubscriptionWrapper subsWrap = new SubscriptionWrapper();
            subsWrap.subscriptionId = sub.Zuora__Zuora_Id__c;
            subsWrap.accountNumber = accAutoNumber;
            subsWrap.accountRecordType = '';
            //subsWrap.billingAccountId ='';// billAccoutNumber;
            subsWrap.recipientId = billAccoutNumber;     
            subsWrap.orderType = '';
            subsWrap.creationMode = '';
            //subsWrap.paypalBAID  = 'BAID';  
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ChangeSubscriptionService/*';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= res;
            
            ChangeSubscriptionServiceRequest ChgSubsSvsRequest = new ChangeSubscriptionServiceRequest();
            
            system.assertNotEquals(null, ChgSubsSvsRequest);
            
            ChgSubsSvsRequest.subscription = subsWrap;
            ChgSubsSvsRequest.contacts = conWrapList;
            ChgSubsSvsRequest.orderLineItem = oliWrap;
            
            String subscriptionIdParam = 'A';
            String accountNumberParam = acct.Account_Auto_Number__c;
            String productFamilyParam = 'test';
            String countryCodeParam = 'code1';
            String postalCodeParam = 'code2';
            String levelNumberParam = 'code3';
            String unitNumberParam = 'code4';
           // String orderLineItemId = String.valueOf(orderline.id);
            
            // test service
            String jsonStr = JSON.serialize(ChgSubsSvsRequest);
            ChangeSubscriptionService.ChangeSubscriptionServiceRequest esh = (ChangeSubscriptionService.ChangeSubscriptionServiceRequest)JSON.deserialize(jsonStr, ChangeSubscriptionService.ChangeSubscriptionServiceRequest.class);
            Boolean returnA = ChangeSubscriptionService.validateSimilarSubscriptions(subscriptionIdParam,accountNumberParam, productFamilyParam, countryCodeParam, postalCodeParam, levelNumberParam, unitNumberParam);
            //Order_Line_Item__c returnO = ChangeSubscriptionService.getOrderLineItem(orderLineItemId);
            system.assertNotEquals(null, esh);
            
            ChangeSubscriptionService.processRequest(esh); 
            
            Test.stopTest();
    }  
    
    static testMethod void testisValidNull(){
        
        
       
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
            subsWrap.recipientId = '';     
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
   
    static testMethod void testisValidTrueandPaypalBAIDnotNUll(){
        
        
       
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
            subsWrap.subscriptionId = null;
            subsWrap.accountNumber = null;
            /*subsWrap.subscriptionId = ZuoraExternalId;
            subsWrap.accountNumber = '' +subscriptionList[0].Zuora__Account__r.Account_Auto_Number__c;  // <---- April*/
            subsWrap.accountRecordType = '';
            subsWrap.billingAccountId = null;
            subsWrap.recipientId = billAccoutNumber;     
            subsWrap.orderType = '';
            subsWrap.creationMode = '';   
            subsWrap.paypalBAID = 'BAID'; 
            subsWrap.paypalEmail = '';
            
            OrderLineItemWrapper oliWrap = new OrderLineItemWrapper();
            oliWrap.promotioncode = null;
            oliWrap.packagecode = null;
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
    static testMethod void testProceedisTrue(){
        
        
       
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
            subsWrap.accountNumber = '';// +subscriptionList[0].Zuora__Account__r.Account_Auto_Number__c;  // <---- April
            subsWrap.accountRecordType = '';
            //subsWrap.billingAccountId = '';// billAccoutNumber;
            subsWrap.recipientId = ''+cntct[0].id;     
            subsWrap.orderType = '';
            subsWrap.creationMode = '';   
            subsWrap.paypalBAID = 'BAID'; 
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
    
}