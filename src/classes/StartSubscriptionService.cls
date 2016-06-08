/**Class Name: <StartSubscriptionService> 
* @author: <CarlosEsplana> 
* Date: <11/15/2014> 
* Requirement/Project Name: <SPH> 
* @description<REST Webservice for Start Subscription> 
*/

@RestResource(urlMapping='/StartSubscriptionService/*')                        
    global with sharing class StartSubscriptionService {
        private static StartSubscriptionServiceResponse response = new StartSubscriptionServiceResponse();
        private static String billingAccountCreationMode;
        private static ContactWrapper recipientContactWrapper;
        private static ContactWrapper billingContactWrapper;
        private static Boolean isBothRecipientAndBilling = false;
        private static Contact recipientBillingContact;

        global class StartSubscriptionServiceResponse {
            String svc_status;
            String error_code;
            String error_message = '';
            String subscriberId;
            String subscriptionId;
            String orderid;
            String accountId;
            String debug = '';
        }
        
        global class StartSubscriptionServiceRequest {
            AccountWrapper subscriberAccount; 
            List<ContactWrapper> contacts;
            OrderWrapper order;       
        }
        
        global class AccountWrapper {
            String accountName;
            String accountNumber; 
            String recordType;
            String phone;
            String email;
            String dateBirth;
            String gender;
            String race;
            String language;
            String contactPerson;
            String uniqueEntityNumber;
            String businessNature;
            String staffId;
            String subGroup;
        }
            
        global class ContactWrapper {
            String salutation;
            String firstName;
            String lastName;
            String nric;
            String passport;
            String billingIndicator;
            String recipientIndicator;
            String homeNumber;
            String mobileNumber1;
            String emailAddress1;
            AddressWrapper address;
        }
        
        global class OrderWrapper {
            String billingAccountNumber;
            String paymentMode;
            String paymentMethodId;
            String deliveryChargeType;
            String ReferenceId;
            List<OrderLineItemWrapper> orderLineItems;
        }
        
        global class OrderLineItemWrapper {
            public String Id;        
            public String promotioncode;
            public String packagecode;
            public String addonpackagecode;
            public String ldapId;
            public Integer quantity;
            public String startDate;
            public List<String> giftCode;
            public String contractenddate;
            public List<Asia1__c> asia1Items;             
        }
        
        global class AddressWrapper {
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
        
        
        public static Contact Billing_Contact {get; set;}
        public static Contact Recipient_Contact {get; set;}
        Public static ID BilConId {get; set;}
        Public static ID RecConId {get; set;}
        
        @HttpPost
        global static StartSubscriptionServiceResponse processRequest(StartSubscriptionServiceRequest request) {
            //response.svc_status = 'SUCCESS';
            response.svc_status = GlobalVariableClass.SVC_STATUS_SUCCESS;
            
            Savepoint savepointBeforeDML = Database.setSavepoint();
            try
            {
            initializeContactWrapperInstances(request.contacts);
            Account account = createAccount(request.subscriberAccount, request.order);
            Contact recipientContact;
            
            if(isBothRecipientAndBilling == true)
            {
                recipientContact = createContact(request.contacts, account.Id, 'Both');
            }
            else
            {
                recipientContact = createContact(request.contacts, account.Id, 'Recipient Contact');
            }
            
            if(response.svc_status != GlobalVariableClass.SVC_STATUS_FAILURE)
            {
            recipientContact = [SELECT Id, Address__r.Postal_Code__r.Name, Address__r.Block_House_Number__c, Address__r.Level_Number__c, Address__r.Unit_Number__c, Address__r.Address_Type__c FROM Contact WHERE Id = :recipientContact.Id];
            }
            
            Zuora__CustomerAccount__c billingAccount;
            if(response.svc_status != GlobalVariableClass.SVC_STATUS_FAILURE)
            {
                billingAccount = getBillingAccount(request.order.billingAccountNumber, account.Id, request.contacts);
            }
            
            
            Order__c orderRecord;

            if(response.svc_status != GlobalVariableClass.SVC_STATUS_FAILURE)
            {
                orderRecord = createOrder(request.order, account, billingAccount, recipientContact);  
            }
    
            if(response.svc_status != GlobalVariableClass.SVC_STATUS_FAILURE)
            {
            string sAccAutoNumber = [select Account_Auto_Number__c from Account where id =: account.Id].Account_Auto_Number__c;
            string sOrderAutoNumber = [select Name from Order__c where id =: orderRecord.Id].Name;
            response.subscriberId = sAccAutoNumber;
            response.orderid = sOrderAutoNumber;
           
            //--------------------Submit
           //orderRecord.Status__c = 'Pending';
            orderRecord.Status__c = GlobalVariableClass.TS_PENDING;
            update orderRecord;
            
            Subscription_Handler sh = new Subscription_Handler();
            sh.Subscription_Handler_Direct(orderRecord);
            //--------------------------
            
                //Sync from Zuora to SFDC
                if (billingAccount != null){
                    Set<id> billingAccountIdSet = new Set<id>();
                    billingAccountIdSet.add(billingAccount.Id);
                    onDemandSyncFromZoura(billingAccountIdSet);
                }
            
            }
            
            }catch(Exception e)
            {        
                Database.rollback(savepointBeforeDML);
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_GENERIC;
                response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_GENERIC;
                if(e.getTypeName().contains('DMLException'))
                {                
                    response.error_code = GlobalVariableClass.NSS_ERROR_CODE_MANDATORY;
                    response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_MANDATORY;
                }
                else if(e.getTypeName().contains('TypeException'))
                {            
                    response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                    response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
                }
                response.error_message += 'Type: ' + e.getTypeName() + ' ';
                response.error_message += 'Message: ' + e.getMessage() + ' ';
                response.error_message += 'Stack Trace: ' + e.getStackTraceString();
            }
            
            
            
            return response;
        }
        
        private static Account createAccount(AccountWrapper accountDetails, OrderWrapper orderDetails)
        {
            List<Account> accountList = new List<Account>();
            Account accountRecord;
            boolean bHasRef = false;
            
            if(orderDetails.ReferenceId!=null){bHasRef = true;}
            
            accountRecord = new Account();
            accountRecord.Name = accountDetails.accountName;
            accountRecord.AccountNumber = accountDetails.accountNumber;
            accountRecord.Gender__c = accountDetails.gender;
            accountRecord.Language__c = accountDetails.language;
            accountRecord.Phone = accountDetails.phone;
            accountRecord.Email__c = accountDetails.email;
            accountRecord.Race__c = accountDetails.race;
            accountRecord.Language__c = accountDetails.language;
            accountRecord.Contact_Person__c = accountDetails.contactPerson;
            accountRecord.Unique_Entity_Number__c = accountDetails.uniqueEntityNumber;
            accountRecord.Business_Nature__c = accountDetails.businessNature;
            //START: D-1091 Modified by FrancisBenzon corrected assignment String to String
            if (accountDetails.staffId != null) {
                accountRecord.Staff_ID__c = String.valueOf(accountDetails.staffId);         
            }
            //END: D-1091 Modified by FrancisBenzon corrected assignment String to String 
            accountRecord.Sub_Group__c = accountDetails.subGroup;       
            accountRecord.Status__c = 'Active';
            accountRecord.NRIC__c = billingContactWrapper.nric;
            accountRecord.Passport__c = billingContactWrapper.passport;
            accountRecord.Mobile__c = billingContactWrapper.mobileNumber1;
            accountRecord.Email__c = billingContactWrapper.emailAddress1;
            accountRecord.Telephone_Residence__c = billingContactWrapper.homeNumber;
            
            if(accountDetails.recordType == 'Direct Corporate') 
            {            
                accountRecord.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate');
            }
            else if(accountDetails.recordType == 'Direct Individual')
            {
                accountRecord.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual');
            }            
            else if(accountDetails.recordType == 'Direct SPH Inter-Division')
            {
                accountRecord.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
            }
            
            insert accountRecord;
                       
            if(accountRecord == null){
                response.debug += 'Account is null';
            } else {
                system.debug('accountRecord.Id = ' + accountRecord.Id);
                response.accountId = accountRecord.Id;
            }
                                               
            return accountRecord;
        }
        
        private static Zuora__CustomerAccount__c getBillingAccount(String billingAccountNumber, Id parentAccountId, List<ContactWrapper> contactDetails)
        {
            List<Zuora__CustomerAccount__c> billingAccountList;
            Zuora__CustomerAccount__c billingAccount;
            
            if(billingAccountNumber  != null  && billingAccountNumber  !=  ''){
                billingAccountList = [SELECT Id, Billing_Contact__r.Id, Zuora__Credit_Balance__c, Zuora__PaymentMethod_Type__c, Zuora__Account__c 
                                        FROM Zuora__CustomerAccount__c 
                                        WHERE Zuora__External_Id__c = :billingAccountNumber LIMIT 1];
                                        
                //system.assertequals(1,3);
            }else{
                
                //system.assertequals(1,2);
                billingAccountList = null;
                billingAccountNumber = null;
            }
            
            //system.assertequals(billingAccountList, null);
            
            if( billingAccountList == null || billingAccountList.size() == 0)
            {   
                if(isBothRecipientAndBilling == false)
                {
                    Contact billingContact = createContact(contactDetails, parentAccountId, 'Billing Contact');       
                }                      
                
                billingAccountCreationMode = 'Create New Billing Account';
            }
            else
            {                  
                billingAccount = billingAccountList.get(0);
                billingAccount.Zuora__Account__c = parentAccountId;             
                
                List<Contact> billingContactList = [SELECT Id, AccountId FROM Contact WHERE Id = :billingAccount.Billing_Contact__r.Id];
                if(billingContactList.size()>0)
                {
                    Contact billingContact = billingContactList.get(0);
                    if(billingContact.AccountId != parentAccountId)
                    {
                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                        response.error_code = 'EXES0014';
                        response.error_message += 'Billing Contact\'s Parent Account is not the Subscriber Account. ';
                        return null;
                    }
                }
                else
                {
                    if(isBothRecipientAndBilling == false)
                    {
                        Contact billingContact = createContact(contactDetails, parentAccountId, 'Billing Contact');  
                        billingAccount.Billing_Contact__c = billingContact.Id;     
                    }
                    else
                    {                       
                        billingAccount.Billing_Contact__c = recipientBillingContact.Id;     
                    }
                }
                
                
                update billingAccount;
                
                
                billingAccountCreationMode = 'Use existing Billing Account';
            }
            
            return billingAccount;
        }
        
        private static void initializeContactWrapperInstances(List<ContactWrapper> contactDetails)
        {            
            for(ContactWrapper contactWrapper : contactDetails)
            {
                if(contactWrapper.billingIndicator == 'Y')
                {
                    billingContactWrapper = contactWrapper;
                }
                if(contactWrapper.recipientIndicator == 'Y')
                {
                    recipientContactWrapper = contactWrapper;
                }
                if(contactWrapper.billingIndicator == 'Y' && contactWrapper.recipientIndicator == 'Y')
                {
                    isBothRecipientAndBilling = true;
                }
            }
        }
        
        private static Contact createContact(List<ContactWrapper> contactDetailsList, Id parentAccountId, String type)
        {
            ContactWrapper contactDetails;
            for(ContactWrapper contactWrapper : contactDetailsList)
            {
                if(contactWrapper.billingIndicator == 'Y' && type == 'Billing Contact')
                {
                    contactDetails = contactWrapper;
                }
                else if(contactWrapper.recipientIndicator == 'Y' && type == 'Recipient Contact')
                {
                    contactDetails = contactWrapper;
                }
                if(contactWrapper.billingIndicator == 'Y' &&contactWrapper.recipientIndicator == 'Y' && type == 'Both')
                {
                    contactDetails = contactWrapper;
                }
            }
            
            Contact contactRecord = new Contact();
            contactRecord.AccountId = parentAccountId;
            contactRecord.Salutation = contactDetails.salutation;
            contactRecord.FirstName = contactDetails.firstName;
            contactRecord.LastName = contactDetails.lastName;
            contactRecord.NRIC__c = contactDetails.nric;
            contactRecord.Passport__c = contactDetails.passport;
            contactRecord.HomePhone = contactDetails.homeNumber;
            contactRecord.Mobile_Number__c = contactDetails.mobileNumber1;
            contactRecord.Email__c = contactDetails.emailAddress1;        
                        
            Address__c addressRecord = searchAddress(contactDetails.address);       
            if(addressRecord == null)
            {
                addressRecord = createAddress(contactDetails.address);
            }                   
        
            contactRecord.Address__c = addressRecord.Id;
            
            if(contactDetails.billingIndicator == 'Y' && type == 'Billing Contact')
            {
                contactRecord.Billing_Indicator__c  = true;            
                contactRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Billing Contact');
                insert contactRecord;
                
                BilConId = contactRecord.Id;
            }
            else if(contactDetails.recipientIndicator == 'Y' && type == 'Recipient Contact')
            {
                contactRecord.Recipient_Indicator__c = true;            
                contactRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
                insert contactRecord;
                
                RecConId = contactRecord.Id;
            }
            else if(contactDetails.billingIndicator == 'Y' &&contactDetails.recipientIndicator == 'Y' && type == 'Both')
            {
                contactRecord.Billing_Indicator__c  = true;  
                contactRecord.Recipient_Indicator__c = true;            
                contactRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Billing Contact');
                insert contactRecord;
                
                recipientBillingContact = contactRecord;
                
                BilConId = contactRecord.Id;
                RecConId = contactRecord.Id;
            }
            else
            {
                return null;
            }
            
            return contactRecord;
        }
        
        public static Address__c searchAddress(AddressWrapper addressDetails)
        {
            Address__c addressRecord;  
            List<Address__c> addressList;
            if(addressDetails.country == 'SIN')
            {
                addressList = [SELECT Id, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Code__c = :addressDetails.country AND Postal_Code__r.Name = :addressDetails.postalCode AND Unit_Number__c = :addressDetails.unitNumber];
            }
            else
            {
                addressList = [SELECT Id, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Code__c = :addressDetails.country AND Address_1__c = :addressDetails.Address1 AND Address_2__c = :addressDetails.Address2 AND Address_3__c = :addressDetails.Address3 AND Address_4__c = :addressDetails.Address4];
            }
            
            if(addressList.size() > 0)
            {
                addressRecord = addressList.get(0);
            }
            
            return addressRecord;
        }
        
        /*
        private static Address__c createAddress(AddressWrapper addressDetails)
        {
            Address__c addressRecord = new Address__c();
            
            
            if(addressDetails.unitNumber != null || addressDetails.unitNumber != ''){
                addressRecord.Block_House_Number__c = addressDetails.houseBlockNumber;
                addressRecord.Level_Number__c = addressDetails.levelNumber;
                addressRecord.Unit_Number__c = addressDetails.unitNumber;
                List<Singpost_Address__c> post = new List<Singpost_Address__c>();
                post = [ select id from Singpost_Address__c where SingPost_Key__c =:addressDetails.postalCode ];
                for(Singpost_Address__c temp:post)
                {
                addressRecord.Postal_Code__c = temp.id;
                }   
               // addressRecord.Postal_Code__r.SingPost_Key__c = addressDetails.postalCode;
                //addressRecord.Postal_Code__c = addressDetails.postalCode;
                //addressRecord.Street_Name__c = addressDetails.streetName;
                //addressRecord.Building_Name__c = addressDetails.buildingName; 
                addressRecord.RecordTypeId = ConstantsSLB.getkeyid('Address_Local');   
            }else{
                addressRecord.Address_1__c = addressDetails.Address1;
                addressRecord.Address_2__c = addressDetails.Address2;
                addressRecord.Address_3__c = addressDetails.Address3;
                addressRecord.Address_4__c = addressDetails.Address4;
                addressRecord.RecordTypeId = ConstantsSLB.getkeyid('Address_Overseas');
            }
            
            addressRecord.Address_Type__c = addressDetails.singpostAddressType;
            
            List<Country__c> countryList = [SELECT Id FROM Country__c WHERE Country_Name__c = :addressDetails.country LIMIT 1];
            
            if(countryList.size() > 0)
            {
                addressRecord.Country__c = countryList.get(0).Id;
            }
            
            insert addressRecord;
            
            return addressRecord;
        }
        */
        
        public static Address__c createAddress(AddressWrapper addressDetails)
        {
            Address__c newAddress = new Address__c();               
            
            if(addressDetails.country == 'SIN')
            {
                Singpost_Address__c singpostAddress = getSingpostAddress(addressDetails.postalCode);
                if(singpostAddress != null)
                {
                    newAddress.Postal_Code__c = singpostAddress.Id;
                }
                newAddress.Block_House_Number__c = addressDetails.houseBlockNumber;
                newAddress.Level_Number__c = addressDetails.levelNumber;
                //newAddress.Street_Name__c = addressDetails.streetName;
                //newAddress.Building_Name__c = addressDetails.buildingName;
                newAddress.Unit_Number__c = addressDetails.unitNumber;
                newAddress.RecordTypeId = ConstantsSLB.getkeyid('Address_Local');            
            }
            else
            {
                newAddress.Address_1__c = addressDetails.Address1;
                newAddress.Address_2__c = addressDetails.Address2;
                newAddress.Address_3__c = addressDetails.Address3;
                newAddress.Address_4__c = addressDetails.Address4;
                newAddress.RecordTypeId = ConstantsSLB.getkeyid('Address_Overseas');
            }                   
            
            Country__c countryRecord = getCountry(addressDetails.country);      
            if(countryRecord != null)
            {
                newAddress.Country__c = countryRecord.Id;  
            }
            
            insert newAddress;
            
            return newAddress;
        }
    
        public static Country__c getCountry(String countryCode)
        {
            Country__c countryRecord;
            List<Country__c> countryList = [SELECT Id FROM Country__c WHERE Code__c = :countryCode];
            if(countryList.size() > 0)
            {
                countryRecord = countryList.get(0);
            }
            else
            {       
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_code = 'EXES0012';
                response.error_message += OnlineExceptions.getErrorMessage('EXES0012');
            }
            
            return countryRecord;
        }   
        
        public static Singpost_Address__c getSingpostAddress(String postalCode)
        {
            Singpost_Address__c singpostAddressRecord;
            List<Singpost_Address__c> singpostAddressList = [SELECT Id FROM Singpost_Address__c WHERE Name = :postalCode];
            if(singpostAddressList.size() > 0)
            {
                singpostAddressRecord = singpostAddressList.get(0);
            }
            else
            {       
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_code = 'EXES0013';
                response.error_message += OnlineExceptions.getErrorMessage('EXES0013');
            }
            
            return singpostAddressRecord;
        }
        
        
        private static Order__c createOrder(OrderWrapper orderDetails, Account parentAccount, Zuora__CustomerAccount__c billingAccount, Contact recipientContact)
        {
            set<Id> sId = new set<Id>();
            
            sId.add(BilConId);
            sId.add(RecConId);
            
            
            for(Contact con: [select id, name, Zone__c,Billing_Indicator__c, Recipient_Indicator__c, 
                                Address__c, Address__r.Address_Type__c
                                from Contact where id IN:sId ]){
                if(con.Billing_Indicator__c)
                {
                    Billing_Contact = con;
                }
                if(con.Recipient_Indicator__c)
                {
                    Recipient_Contact = con;
                }
                
            }
            
            Order__c orderRecord = new Order__c();
            
            orderRecord.Account__c = parentAccount.Id;
            
            if(orderDetails.paymentMode == 'IPP'){
                orderRecord.Payment_Mode__c = 'Other';
                orderRecord.Other_Payment_Mode__c = 'External Parties';
            }else{
                orderRecord.Payment_Mode__c = orderDetails.paymentMode;
                orderRecord.Other_Payment_Mode__c = '';
                //orderRecord.Payment_Method_ID__c = orderDetails.paymentMethodId;
            }
            
            if(billingAccountCreationMode == 'Create New Billing Account'){
                orderRecord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                orderRecord.Billing_Contact__c = Billing_Contact.Id;
                orderRecord.Credit_Balance__c = 0;
            }else{
                orderRecord.Billing_Account__c = billingAccount.Id;
                orderRecord.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';  
                orderRecord.Billing_Contact__c = billingAccount.Billing_Contact__r.Id;          
                
                orderRecord.Credit_Balance__c = 0;          
                if(billingaccount.Zuora__Credit_Balance__c != null){
                    orderRecord.Credit_Balance__c = billingaccount.Zuora__Credit_Balance__c;
                }
            }
            
            orderRecord.Creation_Mode__c = 'createNew';
            
            
            orderRecord.Recipient_Contact__c = recipientContact.Id;
            
            string recipientAddressType = Recipient_Contact.Address__r.Address_Type__c;
            Id recipientAddressId = Recipient_Contact.Address__c;
            
            orderRecord.Delivery_Charge_Type__c = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType);
            
            string addressTypeDeliveryChargeType =  recipientAddressType + orderRecord.Delivery_Charge_Type__c;
            
            //system.assertequals(addressTypeDeliveryChargeType, null);
            //system.assertequals(1, 2);
            
            orderRecord.Subscriber_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
            orderRecord.Vendor_Credit__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
            
            orderRecord.Zone_Charge__c = ConstantsSLB.getPostageCharge(Recipient_Contact.Zone__c);
            
            orderRecord.Monthly_Delivery_Charge_for_Full_Payment__c = 0; //months * delivery charge     
            
            DeliveryChargeCheck.DeliveryChargeCheckRequest deliveryChargeRequest = new DeliveryChargeCheck.DeliveryChargeCheckRequest();
            deliveryChargeRequest.postalcode = recipientContact.Address__r.Postal_Code__r.Name;
            deliveryChargeRequest.blkno = recipientContact.Address__r.Block_House_Number__c;
            deliveryChargeRequest.levelno = recipientContact.Address__r.Level_Number__c;
            deliveryChargeRequest.unitno = recipientContact.Address__r.Unit_Number__c;
            deliveryChargeRequest.subscriberid = parentAccount.Account_Auto_Number__c;
            
            DeliveryChargeCheck.DeliveryChargeCheckResponse deliveryChargeResponse = DeliveryChargeCheck.processRequest(deliveryChargeRequest);
            
            if(deliveryChargeResponse.delivery_charge!= null){             
                orderRecord.Delivery_Charge__c = Decimal.valueOf(deliveryChargeResponse.delivery_charge);
            } else {
                orderRecord.Delivery_Charge__c = Decimal.valueOf('0.0'); 
            }      
            
            orderRecord.Status__c = 'Draft';
            orderRecord.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';            
            orderRecord.Informed_Customer__c = true;
            
            insert orderRecord;
            
            
            
            createOrderLineItems(orderDetails.orderLineItems, orderRecord);
            
            
            return orderRecord;
        }
        
        public static void createOrderLineItems(List<OrderLineItemWrapper> orderLineItemDetailsList, Order__c parentOrder)
        {
            List<Order_Line_Item__c> orderLineItemRecordsList = new List<Order_Line_Item__c>();
            List<Package__c> packageList = new List<Package__c>();
            List<Order__c> orderList = new List<Order__c>();
            List<Package_Item__c> packageItemList = new List<Package_Item__c>();
            List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c>();
            List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
            List<zqu__ZProduct__c> productList = new List<zqu__ZProduct__c>();
            List<Product_Publication__c> productPublicationList = new List<Product_Publication__c>();
            List<Promotion_Gift__c> promotionGiftList = new List<Promotion_Gift__c>();
            List<Order_Line_Item_Gift__c> orderLineItemGiftList = new List<Order_Line_Item_Gift__c>();
            
            Set<String> ldapIdSet = new Set<String>();
            Set<Id> allPackagesIdSet = new Set<Id>();
            Set<Id> orderIdSet = new Set<Id>();
            Set<Id> packageItemIdSet = new Set<Id>(); 
            Set<Id> productRatePlanIdSet = new Set<Id>();
            Set<Id> productIdSet = new Set<Id>();
            Set<String> giftIdSet = new Set<String>();
            Set<Id> promotionIdSet = new Set<Id>();
            Set<Id> promotionGiftIdSet = new Set<Id>();
            Set<Id> orderLineItemIdSet = new Set<Id>();
            
            Map<Id,Package_Access_Flag__c> packageAccessFlagMap;
            
            Map<Integer,OrderLineItemWrapper> orderLineItemWrapperMap = new Map<Integer,OrderLineItemWrapper>();
            Map<Id,Package__c> packageMap = new Map<Id,Package__c>();
            Map<Id,List<Package_Item__c>> package_packageItemMap = new Map<Id,List<Package_Item__c>>();
            Map<Id,zqu__ProductRatePlan__c> productRatePlanMap = new Map<Id,zqu__ProductRatePlan__c>();
            Map<Id,List<zqu__ProductRatePlanCharge__c>> productRatePlan_productRatePlanChargeMap = new Map<Id,List<zqu__ProductRatePlanCharge__c>>();
            Map<Id,zqu__ZProduct__c> productMap = new Map<Id,zqu__ZProduct__c>();
            Map<Id,List<Product_Publication__c>> package_productPublicationMap = new Map<Id,List<Product_Publication__c>>();
            Map<Id,List<Product_Publication__c>> product_productPublicationMap = new Map<Id,List<Product_Publication__c>>();
            Map<Id,List<Promotion_Gift__c>> promo_promoGiftMap = new Map<Id,List<Promotion_Gift__c>>();
            Map<Id,List<Order_Line_Item_Gift__c>> promo_orderLineItemGiftMap = new Map<Id,List<Order_Line_Item_Gift__c>>();
            
            integer counter = 0;
            
            
            set<string> sPackageCode = new set<string>();
            set<string> sPromotionCode = new set<string>();
            set<string> sGiftCode = new set<string>();
            
            
            for(OrderLineItemWrapper orderLineItemDetails : orderLineItemDetailsList)
            {        
                sPackageCode.add(orderLineItemDetails.packagecode);
                sPackageCode.add(orderLineItemDetails.addOnPackagecode);
                sPromotionCode.add(orderLineItemDetails.promotioncode);
                if(orderLineItemDetails.giftCode != null && orderLineItemDetails.giftCode.size() > 0)
                {
                    for(String giftId : orderLineItemDetails.giftCode)
                    {
                        sGiftCode.add(giftId);
                    }
                }
            }    
            
            map<string, Id> mPckgCode_Pckg = new map<string, Id>();
            map<string, Id>  mPromCode_Prom = new map<string, Id>();
            map<Id, Package__c>  mPckg = new map<Id, Package__c>();
            map<Id, Promotion__c>  mProm = new map<Id, Promotion__c>();
            
            
            if(sPackageCode.size()>0){          
                for(Package__c p: [select Id, Package_Code__c from Package__c where Package_Code__c IN: sPackageCode]){
                    mPckg.put(p.Id, p);
                    mPckgCode_Pckg.put(p.Package_Code__c, p.Id);
                    sPackageCode.add(p.Id);
                    allPackagesIdSet.add(p.Id);
                }
            }
            if(sPromotionCode.size()>0){
                for(Promotion__c p: [select Id, Contract_Period__c, Penalty_Charge__c, Promotion_Code__c from Promotion__c where Promotion_Code__c IN: sPromotionCode]){
                    mProm.put(p.Id, p);
                    mPromCode_Prom.put(p.Promotion_Code__c, p.Id);
                    promotionIdSet.add(p.Id);
                }
            }
            if(sGiftCode.size()>0){         
                for( Gift__c g :[select Id from Gift__c where Gift_Code__c IN: sGiftCode]){
                    giftIdSet.add(string.valueof(g.Id));
                }
                
            }
            
            packageList = [SELECT Id, Billing_Type__c, Package_Sub_Type__c, Package_Type__c, Subscription_Period__c, Subscription_Type__c
                            FROM Package__c WHERE Id IN :allPackagesIdSet];
            for(Package__c packageRecord : packageList)
            {
                packageMap.put(packageRecord.Id, packageRecord);            
            }    

            packageItemList = [SELECT Id, Package__r.Id, Package__r.Billing_Type__c, Billing_Type__c, Product_Rate_Plan__r.Id, Product_Rate_Plan__r.zqu__ZProduct__r.Id FROM Package_Item__c WHERE Package__c IN :allPackagesIdSet];
            
            for(Package_Item__c packageItem : packageItemList)
            {
                if(packageItem.Package__r.Billing_Type__c == packageItem.Billing_Type__c)
                {
                    List<Package_Item__c> packageItemTempList = package_packageItemMap.get(packageItem.Package__r.Id);
                    if(packageItemTempList == null)
                    {
                        packageItemTempList = new List<Package_Item__c>();
                    }
                    packageItemTempList.add(packageItem);
                    
                    package_packageItemMap.put(packageItem.Package__r.Id, packageItemTempList);            
                    productRatePlanIdSet.add(packageItem.Product_Rate_Plan__r.Id);
                }
            }
            
            productRatePlanList = [SELECT Id, SubscriptionFrequency__c, zqu__ZProduct__r.Id , zqu__ZProduct__r.ProductSubType__c, zqu__ZProduct__r.ProductPlatform__c
                                    FROM zqu__ProductRatePlan__c WHERE Id IN :productRatePlanIdSet];
            
            for(zqu__ProductRatePlan__c productRatePlan : productRatePlanList)
            {
                productRatePlanMap.put(productRatePlan.Id, productRatePlan);
                productIdSet.add(productRatePlan.zqu__ZProduct__r.Id);
            }        
            
            productRatePlanChargeList = [SELECT Id, zqu__ProductRatePlan__r.Id, sum__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c IN :productRatePlanIdSet];
            
            for(zqu__ProductRatePlanCharge__c productRatePlanCharge : productRatePlanChargeList)
            {
                List<zqu__ProductRatePlanCharge__c> productRatePlanChargeTempList = productRatePlan_productRatePlanChargeMap.get(productRatePlanCharge.zqu__ProductRatePlan__r.Id);
                if(productRatePlanChargeTempList == null)
                {
                    productRatePlanChargeTempList = new List<zqu__ProductRatePlanCharge__c>();
                }
                productRatePlanChargeTempList.add(productRatePlanCharge);            
            
                productRatePlan_productRatePlanChargeMap.put(productRatePlanCharge.zqu__ProductRatePlan__r.Id,productRatePlanChargeTempList);
            }
            
            productList = [SELECT Id FROM zqu__ZProduct__c WHERE Id IN :productIdSet];
            
            for(zqu__ZProduct__c productRecord : productList)
            {        
                productMap.put(productRecord.Id,productRecord);     
            }

            productPublicationList = [SELECT Id, ZProduct__c, ZProduct__r.Id, Publication_Code__r.Earliest_Start_Date__c, Publication_Code__r.Direct_Sub_Delivery_Method__c
                                        FROM Product_Publication__c WHERE ZProduct__c IN :productIdSet];
            
                
            for(Product_Publication__c productPublicationRecord : productPublicationList)
            {   
                List<Product_Publication__c> productPublicationTempList = product_productPublicationMap.get(productPublicationRecord.ZProduct__r.Id);
                if(productPublicationTempList == null)
                {
                    productPublicationTempList = new List<Product_Publication__c>();
                }
                productPublicationTempList.add(productPublicationRecord);
                product_productPublicationMap.put(productPublicationRecord.ZProduct__r.Id,productPublicationTempList);
            }
            
            
            for(Id keyId : package_packageItemMap.keySet())
            {            
                List<Package_Item__c> packageTempList = package_packageItemMap.get(keyId);
                
                for(Package_Item__c packageItemRecord : packageTempList)
                {              
                    List<Product_Publication__c> productPublicationTempList = product_productPublicationMap.get(packageItemRecord.Product_Rate_Plan__r.zqu__ZProduct__r.Id);  
                                 
                    package_productPublicationMap.put(keyId,productPublicationTempList); 
                }          
            }     
            
            Map<Id,Decimal> subscriptionRateMap = calculateSubscriptionRate(package_packageItemMap,productRatePlan_productRatePlanChargeMap);
            
            Map<Id,Date> earliestStartDateMap = getEarliestStartDateMap(package_productPublicationMap);
            
            counter = 0;
            for(OrderLineItemWrapper orderLineItemDetails : orderLineItemDetailsList)
            {
                PackageEligibilityCheck.PackageEligibilityCheckRequest packageEligibilityCheckRequest = new PackageEligibilityCheck.PackageEligibilityCheckRequest();
                packageEligibilityCheckRequest.Packageid = orderLineItemDetails.packageCode ;
                packageEligibilityCheckRequest.Promotionid = orderLineItemDetails.promotionCode;
                packageEligibilityCheckRequest.Action = 'CAN ADD';
                packageEligibilityCheckRequest.SubscriptionId = '';
                packageEligibilityCheckRequest.subscriberid = parentOrder.Account__r.Account_Auto_Number__c;            
                
                PackageEligibilityCheck.PackageEligibilityCheckResponse packageEligibilityCheckResponse = PackageEligibilityCheck.processRequest(packageEligibilityCheckRequest);
                
                // TO-DO: Temporary, this is always true. There are things to work on for package eligibility rule.
                if(packageEligibilityCheckResponse.eligibilityFlg == 'true' || true)
                {
                    Order_Line_Item__c orderLineItemRecord = new Order_Line_Item__c();
                    
                    orderLineItemRecord.Order__c = parentOrder.Id;
                    
                    if(orderLineItemDetails.promotioncode != ''){
                        
                        Id PromId = mPromCode_Prom.get(orderLineItemDetails.promotioncode);
                        
                        orderLineItemRecord.Promotion_ID__c = PromId; 
                        
                        string sPenalty;
                        if(mProm.get(PromId) != null)
                        {
                            sPenalty = mProm.get(PromId).Penalty_Charge__c;
                        }
                        if(sPenalty == '' || sPenalty == null){
                            orderLineItemRecord.Penalty_Charge__c = 0;
                        }else{
                            orderLineItemRecord.Penalty_Charge__c = decimal.valueOf(mProm.get(PromId).Penalty_Charge__c);
                        }
                        
                        
                        
                        date dStart = convertDate(orderLineItemDetails.startdate);
                        if(orderLineItemDetails.contractenddate != null && orderLineItemDetails.contractenddate != '')
                        {
                            integer iContractEndDate = dStart.monthsBetween(convertDate(orderLineItemDetails.contractenddate));
                            orderLineItemRecord.New_Contract_Period__c = iContractEndDate;
                            orderLineItemRecord.Contract_End_Date__c = convertDate(orderLineItemDetails.contractenddate);
                        }
                        
                        
                    }
                    
                    
                    Id pckId = mPckgCode_Pckg.get(orderLineItemDetails.packagecode);
                    Id pckIdAddon = mPckgCode_Pckg.get(orderLineItemDetails.addOnPackagecode);
                    
                    orderLineItemRecord.Main_Package_ID__c = pckId;
                    
                    orderLineItemRecord.Delivered_By__c = product_productPublicationMap.get(productRatePlanMap.get(package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id).zqu__ZProduct__r.Id)[0].Publication_Code__r.Direct_Sub_Delivery_Method__c;
                    orderLineItemRecord.Direct_Sub_Delivery_Method__c = product_productPublicationMap.get(productRatePlanMap.get(package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id).zqu__ZProduct__r.Id)[0].Publication_Code__r.Direct_Sub_Delivery_Method__c;
        
                    orderLineItemRecord.Qty__c = orderLineItemDetails.quantity;
                    orderLineItemRecord.Start_Date__c = convertDate(orderLineItemDetails.StartDate);
                    orderLineItemRecord.Main_Package_Billing_Type__c = packageMap.get(pckId).Billing_Type__c;
                    orderLineItemRecord.Main_Package_Sub_Type__c = packageMap.get(pckId).Subscription_Type__c;//Package_Sub_Type__c;
                    orderLineItemRecord.Main_Package_Type__c =  packageMap.get(pckId).Package_Type__c;
                    
                    orderLineItemRecord.Subscribed_as__c = 'New Buy';
                    
                    String termLength = packageMap.get(pckId).Subscription_Period__c;
                    if(termLength != 'N/A')
                    {
                        orderLineItemRecord.Term_Length__c = Integer.valueOf(termLength);
                        orderLineItemRecord.Main_Package_Period__c = Integer.valueOf(termLength);
                        Date startDate = orderLineItemRecord.Start_Date__c;
                        orderLineItemRecord.End_Date__c = startDate.addMonths(Integer.valueOf(termLength)); 
                    }else{
                        orderLineItemRecord.Main_Package_Period__c = 0;
                        orderLineItemRecord.Term_Length__c = 0;
                    }
                    
                    
                    orderLineItemRecord.Main_Package_Subscription_Rate__c = subscriptionRateMap.get(pckId);
                    
                    orderLineItemRecord.Earliest_Start_Date__c = earliestStartDateMap.get(pckId);                   
                    
                    if(orderLineItemDetails.addOnPackagecode != '' && orderLineItemDetails.addOnPackagecode != null){
                        orderLineItemRecord.Addon_Package__c = pckIdAddon;
                        orderLineItemRecord.Add_On_Package_Product_Sub_Type__c = packageMap.get(pckIdAddon).Package_Sub_Type__c;
                        orderLineItemRecord.Add_On_Package_Subscription_Rate__c = subscriptionRateMap.get(pckIdAddon);
                    }
                    
                    String subscriptionFrequencyNum = productRatePlanMap.get(package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id).SubscriptionFrequency__c;
                    String subscriptionFrequencyText;
                    
                    if(subscriptionFrequencyNum == '0')
                    {
                        subscriptionFrequencyText = 'Default';
                    }
                    else if(subscriptionFrequencyNum == '1')
                    {
                        subscriptionFrequencyText = 'Mon - Fri';
                    }
                    else if(subscriptionFrequencyNum == '2')
                    {
                        subscriptionFrequencyText = 'Sat - Sun';
                    }
                    else if(subscriptionFrequencyNum == '3')
                    {
                        subscriptionFrequencyText = 'Mon - Sat';
                    }
                    
                    orderLineItemRecord.Main_Package_Frequency__c = subscriptionFrequencyText;
                    
                    
                    orderLineItemRecord.Main_Package_Product_Sub_Type__c = productRatePlanMap.get(package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id).zqu__ZProduct__r.ProductSubType__c;
                    orderLineItemRecord.Main_Package_Product_Platform__c = productRatePlanMap.get(package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id).zqu__ZProduct__r.ProductPlatform__c;
                    
                    if(orderLineItemDetails.ldapId != '' && orderLineItemDetails.ldapId != null){
                        ldapIdSet.add(orderLineItemDetails.ldapId);
                    }
                    orderLineItemRecordsList.add(orderLineItemRecord);
                    orderLineItemWrapperMap.put(counter,orderLineItemDetails);
                }
                else
                {
                    response.debug += 'Order Line Item is not eligible.';
                }
                counter++;
            }
            
            packageAccessFlagMap = retrieveServiceFlags(allPackagesIdSet);
            
            
            insert orderLineItemRecordsList;     
            Set<Id> resultOrderLineItemIdSet = (new Map<Id,SObject>(orderLineItemRecordsList)).keySet();
            orderLineItemRecordsList = [SELECT Id, Promotion_ID__r.Id, Total_Gift_Price__c, Main_Package_ID__r.Id, Qty__c FROM Order_Line_Item__c WHERE Id IN: resultOrderLineItemIdSet];
                    
            promotionGiftList = [SELECT Id,Promotion__r.Id,Gift__r.Gift_Cost__c FROM Promotion_Gift__c WHERE Promotion__r.Id IN :promotionIdSet AND Gift__c IN :giftIdSet];
            
            for(Promotion_Gift__c promotionGift : promotionGiftList)
            {
                List<Promotion_Gift__c> promotionGiftTempList = promo_promoGiftMap.get(promotionGift.Promotion__r.Id);
                if(promotionGiftTempList == null)
                {
                    promotionGiftTempList = new List<Promotion_Gift__c>();
                }
                promotionGiftTempList.add(promotionGift);
                
                promo_promoGiftMap.put(promotionGift.Promotion__r.Id,promotionGiftTempList); 
                
                promotionGiftIdSet.add(promotionGift.Id);
            }
                            
            counter = 0;
            for(Order_Line_Item__c orderLineItem : orderLineItemRecordsList)
            {
                Package_Access_Flag__c packageAccessFlag = packageAccessFlagMap.get(orderLineItem.Main_Package_ID__r.Id);
                
                orderLineItemIdSet.add(orderLineItem.Id);
                
                List<Promotion_Gift__c> promotionGiftTempList = promo_promoGiftMap.get(orderLineItem.Promotion_ID__r.Id);
                
                if(promotionGiftTempList != null)
                {
                    for(Promotion_Gift__c promotionGift : promotionGiftTempList)
                    {
                        Order_Line_Item_Gift__c orderLineItemGift = new Order_Line_Item_Gift__c();
                        orderLineItemGift.Order_Line_Item__c = orderLineItem.Id;
                        orderLineItemGift.Promotion_Gift__c = promotionGift.Id;
                        
                        orderLineItemGiftList.add(orderLineItemGift);
                    }
                }
                
                counter++;
            }
            
            insert orderLineItemGiftList;
            
            Set<Id> resultOrderLineItemGiftIdSet = (new Map<Id,SObject>(orderLineItemGiftList)).keySet();
            
            orderLineItemGiftList = [SELECT Id, Price__c, Order_Line_Item__r.Qty__c, Promotion_Gift__r.Gift__r.Gift_Cost__c, Promotion_Gift__r.Promotion__r.Id FROM Order_Line_Item_Gift__c WHERE Id IN: resultOrderLineItemGiftIdSet];
            
            for(Order_Line_Item_Gift__c orderLineItemGift : orderLineItemGiftList)
            {
                List<Order_Line_Item_Gift__c> orderLineItemGiftTempList = promo_orderLineItemGiftMap.get(orderLineItemGift.Promotion_Gift__r.Promotion__r.Id);
                if(orderLineItemGiftTempList == null)
                {
                    orderLineItemGiftTempList = new List<Order_Line_Item_Gift__c>();
                }
                orderLineItemGiftTempList.add(orderLineItemGift);
                
                promo_orderLineItemGiftMap.put(orderLineItemGift.Promotion_Gift__r.Promotion__r.Id,orderLineItemGiftTempList);
            }
            
            Map<Id,Decimal> totalGiftPriceMap = calculateTotalGiftPrice(promo_orderLineItemGiftMap);        
            
            for(Order_Line_Item__c orderLineItem : orderLineItemRecordsList)
            {
                orderLineItem.Total_Gift_Price__c = totalGiftPriceMap.get(orderLineItem.Promotion_ID__r.Id);
            }
            update orderLineItemRecordsList;
            
            String packageId;
            for(String packageKeyId : mPckgCode_Pckg.keySet()){
                packageId = mPckgCode_Pckg.get(packageKeyId);
            }

            List<Id> resultOrderLineItemIdList = new List<Id>();
            resultOrderLineItemIdList.addAll(resultOrderLineItemIdSet);
            
            createAsia1Record(orderLineItemDetailsList, parentOrder, resultOrderLineItemIdList);
        }
        
        public static Map<Id,Date> getEarliestStartDateMap(Map<Id,List<Product_Publication__c>> package_productPublicationMap)
        {
            Map<Id,Date> earliestStartDateMap = new Map<Id,Date>();
            
            for(Id keyId : package_productPublicationMap.keySet())
            {       
                List<Product_Publication__c> productPublicationTempList = package_productPublicationMap.get(keyId);
                Date earliestStartDate = getEarliestStartDate(productPublicationTempList);
                earliestStartDateMap.put(keyId,earliestStartDate);
            }
            
            return earliestStartDateMap;
        }
        
        
        
        public static Date getEarliestStartDate(List<Product_Publication__c> productPublicationList)
        {
            if(productPublicationList == null)
                return null;
                
            Date earliestDate = productPublicationList.get(0).Publication_Code__r.Earliest_Start_Date__c;
            
            for(Product_Publication__c productPublicationRecord : productPublicationList)
            {
                Date tempDate = productPublicationRecord.Publication_Code__r.Earliest_Start_Date__c;
                if(tempDate < earliestDate)
                    earliestDate = tempDate;
            }
            
            return earliestDate;
        }
        
        public static Map<Id,Decimal> calculateTotalGiftPrice(Map<Id,List<Order_Line_Item_Gift__c>> promo_orderLineItemGiftMap)
        {
            Map<Id,Decimal> totalGiftPriceMap = new Map<Id,Decimal>();
            
            for(Id promoId : promo_orderLineItemGiftMap.keySet())
            {
                Decimal totalGiftPrice = 0;
                List<Order_Line_Item_Gift__c> orderLineItemGiftList = promo_orderLineItemGiftMap.get(promoId);
                for(Order_Line_Item_Gift__c orderLineItemGift : orderLineItemGiftList)
                {
                    totalGiftPrice += orderLineItemGift.Price__c;
                }
                totalGiftPriceMap.put(promoId, totalGiftPrice);
            }        
            
            return totalGiftPriceMap;
        }
        
        public static Map<Id,Decimal> calculateSubscriptionRate(
            Map<Id,List<Package_Item__c>> package_packageItemMap,
            Map<Id,List<zqu__ProductRatePlanCharge__c>> productRatePlan_productRatePlanChargeMap
            )
        {
            Map<Id,Decimal> subscriptionRateMap = new Map<Id,Decimal>();
            for(Id packageId : package_packageItemMap.keySet())
            {
                Decimal totalSubscriptionRate = 0;
                List<Package_Item__c> packageItemList = package_packageItemMap.get(packageId);
                for(Package_Item__c packageItem : packageItemList)
                {
                    List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = productRatePlan_productRatePlanChargeMap.get(packageItem.Product_Rate_Plan__r.Id);
                    
                    for(zqu__ProductRatePlanCharge__c productRatePlanCharge : productRatePlanChargeList)
                    {
                        totalSubscriptionRate += productRatePlanCharge.sum__c;
                    }
                }
                subscriptionRateMap.put(packageId, totalSubscriptionRate);
            }
            
            return subscriptionRateMap;
        }

        private static Map<Id,Package_Access_Flag__c> retrieveServiceFlags(Set<Id> packageIdSet) {
            
            Map<Id,Package_Access_Flag__c> packageAccessFlagMap = new Map<Id,Package_Access_Flag__c>();
            
            List<Package_Access_Flag__c> packageAccessFlagList = [SELECT Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, No_of_Concurrent_Users__c, Package_Access_Flag__c.Package__r.Id FROM Package_Access_Flag__c WHERE Package__c IN :packageIdSet];
            
            for(Package_Access_Flag__c packageAccessFlag : packageAccessFlagList)
            {
                packageAccessFlagMap.put(packageAccessFlag.Package__r.Id, packageAccessFlag);
            }
            
            return packageAccessFlagMap;
        }
       
        private static void createAsia1Record(List<OrderLineItemWrapper> orderLineItemDetailsList, Order__c parentOrder, List<Id> resultOrderLineItemIdList)
        {
            if (orderLineItemDetailsList != null) {
            
                integer ictr =0;
                for(OrderLineItemWrapper orderLineItemDetail : orderLineItemDetailsList)
                {
                    for(Asia1__c asia1Rec : orderLineItemDetail.asia1Items)
                    {
                        system.debug('User_ID_LDAP_ID__c: ' + asia1Rec.User_ID_LDAP_ID__c);
                        system.debug('Password__c: ' + asia1Rec.Password__c);
                        system.debug('Display_Name__c: ' + asia1Rec.Display_Name__c);
                        
                        Asia1__c asia1obj = new Asia1__c();
                        asia1obj.User_ID_LDAP_ID__c = asia1Rec.User_ID_LDAP_ID__c;
                        asia1obj.Password__c = asia1Rec.Password__c;
                        asia1obj.Display_Name__c = asia1Rec.Display_Name__c;
                        asia1obj.Contact__c = parentOrder.Recipient_Contact__c;
                        asia1obj.Email__c = asia1Rec.Email__c;
                        asia1obj.Status__c = 'Pending Creation';
                        
                        insert asia1obj;
                        
                        system.debug('Asia1 Record ID: ' + asia1obj.Id);
                        system.debug('OrderLineItemId: ' + resultOrderLineItemIdList.get(ictr));
                        
                        createAsia1Subscriptions(asia1obj.Id, resultOrderLineItemIdList.get(ictr));
                        registerAsia1Accounts(asia1obj.Id);
                    }
                    ictr++;
                }
            }
            
        }
        
        public static void createAsia1Subscriptions(id asia1Id, id orderLineItemId) {
       
           list<Asia1_Subscription__c> asia1SubscriptionList = new list<Asia1_Subscription__c>();
           id packageId;
           
           packageId = [select Main_Package_Id__c from Order_Line_Item__c where Id = :orderLineItemId].Main_Package_Id__c;
           
           for (Package_Access_Flag__c tmp : [select Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, 
                    No_of_Concurrent_Users__c from Package_Access_Flag__c where Package__c = :packageId]) {
                         
                  Asia1_Subscription__c asia1Subscription = new Asia1_Subscription__c();
                  
                  asia1Subscription.Concurrent__c = tmp.No_of_Concurrent_Users__c;
                  asia1Subscription.Order_Line_Item__c = orderLineItemId;
                  asia1Subscription.Service_Access_Flag__c = tmp.Package_Service_Access_Flag__c;
                  asia1Subscription.Asia1__c = asia1Id;
                  asia1Subscription.Status__c = 'Disabled';
                  
                  asia1SubscriptionList.add(asia1Subscription);
            }
            
            insert asia1SubscriptionList;
        }

        public static void registerAsia1Accounts(id orderId) {
       
           list<Asia1__c> asia1List = new list<Asia1__c>();
           set<id> asia1IdSet = new set<id>();
           
           // retrieve asia1 ids
           for (Asia1_Subscription__c tmp : [select Asia1__c from Asia1_Subscription__c 
                         where Order_Line_Item__r.Order__c = :orderId and Asia1__r.Status__c = 'Pending Creation']) {
                  
                  asia1IdSet.add(tmp.Asia1__c);
           }
           // end retrieve asia1 ids
           
           // prepare and register asia1 details for registration
           for (Asia1__c tmp : [select User_ID_LDAP_ID__c, Display_Name__c, First_Name__c, Last_Name__c, 
                         Status__c, Log__c, Phone__c, Password__c, Email__c, 
                         (select Service_Access_Flag__r.Name from Asia1_Subscriptions__r) 
                         from Asia1__c where Id in :asia1IdSet limit 100]) {
                  
                  string serviceFlags = '';
                  integer i = 0;
                  for (Asia1_Subscription__c tmp2 : tmp.Asia1_Subscriptions__r) {
                         
                         if (i > 0) {
                               serviceFlags += '|'; 
                         }

                         serviceFlags += tmp2.Service_Access_Flag__r.Name;
                         i++;
                  }
                               
                         map<string, string> asia1newCreate = new map<string, string>();
                         asia1newCreate.put(GlobalVariableClass.SVC, serviceFlags);
                         asia1newCreate.put(GlobalVariableClass.USERNAME, tmp.User_ID_LDAP_ID__c);
                         asia1newCreate.put(GlobalVariableClass.PASSWORD, tmp.Password__c);
                         asia1newCreate.put(GlobalVariableClass.FNAME, tmp.First_Name__c);
                         asia1newCreate.put(GlobalVariableClass.LNAME, tmp.Last_Name__c);
                         asia1newCreate.put(GlobalVariableClass.PHONE, tmp.Phone__c);
                         asia1newCreate.put(GlobalVariableClass.DISPLAY_NAME, tmp.Display_Name__c);
                         asia1newCreate.put(GlobalVariableClass.EMAIL, tmp.Email__c);
                         asia1newCreate.put(GlobalVariableClass.ENABLE, 'false');
                         asia1newCreate.put(GlobalVariableClass.IP, '');
           
                         map<string, Object> asia1Return = AsiaOneServicesController.createAccount(asia1newCreate);
                         
                         if (asia1Return.get('Sign-Up') == 'Success') {
                         
                               tmp.Status__c = 'Created';
                         
                         } else {
                               
                               tmp.Status__c = 'Error Creation';
                               
                               if (asia1Return.get('Error') != null) {
                                      tmp.Log__c = string.valueOf(asia1Return.get('Error'));
                               } else if (asia1Return.get('Errors') != null) {
                                      tmp.Log__c = string.valueOf(asia1Return.get('Errors'));
                               }
                         }
                         
                         asia1List.add(tmp);               
           }
           // end prepare and register asia1 details for registration
           
           update asia1List;
        }
        

        public static void onDemandSyncFromZoura(set<id> billingAccountIdSet) {
            Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
            syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
            syncManager.syncObjectIdSet = billingAccountIdSet;
            List<Zuora.SyncResult> syncResult = syncManager.sendRequest();       
        }
        
        public static Date convertDate(String myDate)
        {
            String[] myDateOnly = myDate.split(' ');
            String[] strDate = myDateOnly[0].split('/');
            Integer myIntMonth = integer.valueOf(strDate[0]);
            Integer myIntDay = integer.valueOf(strDate[1]);
            Integer myIntYear = integer.valueOf(strDate[2]);
            
            Date d = Date.newInstance(myIntYear, myIntMonth, myIntDay);
            return d;
        }
    }