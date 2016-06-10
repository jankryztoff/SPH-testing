/*
 * Class Name: NewSubscriptionService
 * @author: Kevin H. Evasco
 * Date: 09/06/2014
 * Project/Requirement: ESHOP Start SubscriptionFrequency__c
 * @description This class generates Credit Card Failure Notification Letter Print Requests
 * 
 * History: 09/06/2014 Kevin Evasco Created Apex Webservice
 * History: 12/09/2014 Kevin Evasco Updated class to insert billing and recipient contact using a single DML instead of two seperate DMLs.
 * History: 29/1/2015 Joban Bir Singh - Updated class to add check for illegal characters in the address string  
 * History: 03/16/15 D-2284 Kevin Evasco - Vendor Assignment should only be done when delivered by vendor.
 * History: 03/17/15 D-2417 Kevin Evasco - Single case should be created even for multiple order line items.
 * History: 04/22/15 D-2743 Kevin Evasco - Major code change for Quote Creation Implementation + Paypal 
 * History: 06/15/15 D-3021 Kevin Evasco - UAT Hotfix. Major code change to fix glitches and work flows.
 * History: 06/22/15 D-3138 Kevin Evasco - UAT Hotfix. Placed rollback logic properly.
 */
 
@RestResource(urlMapping='/NewSubscriptionService/*')                        
global with sharing class NewSubscriptionService {
    private static NewSubscriptionServiceResponse response = new NewSubscriptionServiceResponse();
    private static Zuora__CustomerAccount__c billingAccountStatic;
    private static String billingAccountCreationMode;
    private static ContactWrapper recipientContactWrapper;
    private static ContactWrapper billingContactWrapper;
    private static Boolean isBothRecipientAndBilling = false;
    private static Contact recipientBillingContact;
//START: D-1154 1/8/2015 Added by Kristine Campang - added variables
    private static Asia1__c asia1;
    private static Order__c orderRecord;
//END: D-1154 1/8/2015 
  //START: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon Avoid null pointer by try catch
  public static String addressTypeDeliveryChargeType;
  //END: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon
  
    //START 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion checkbox assignment
    public static Boolean vendorConversionFlag = false; 
    public static Subscription_Vendor__c vendorSubscription;
    //END 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion checkbox assignment
  
    private static Boolean createCaseFlag = false; //START/END 03/16/15 D-2417 Kevin Evasco - Single case should be created even for multiple order line items.
    private static Boolean isWaitingForVendorAssignment = false; //START/END 05/04/2015 CR-005 Kevin Evasco - PayPal CR
    private static String origin; //START/END 05/04/2015 CR-005 Kevin Evasco - PayPal CR
  
    private static Set<String> noDeliveryPublications = new Set<String>{'TABL','MY'}; //START/END 08 October 2015 UD-2968 Kevin Evasco - Set of Product Codes without Delivery Fee
  
    private static String paypalBillingAccountZID; //START/END 03 February 2016 UD-3844 Kevin Evasco - Paypal Rollback
  
    global class NewSubscriptionServiceResponse {
        String svc_status;
        String error_code;
        String error_message = '';
        String subscriberId;
        String subscriptionId;
        String orderid;
        String debug = '';
    }
    
    global class NewSubscriptionServiceRequest {
        AccountWrapper subscriberAccount; 
        List<ContactWrapper> contacts;
        OrderWrapper order;       
    }
    
    global class AccountWrapper {
        String accountName;
        String accountNumber; 
        String recordType;
    }
        
    global class ContactWrapper {
        String contactId;
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
    //START: D-1154 1/8/2015 Added by Kristine Campang - removed variable from OrderLine level and moved to Order Level
    global class OrderWrapper {
        String billingAccountNumber;
        String paymentMode;
        String paymentMethodId;
        String ReferenceId;
        String ldapId;
        //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
        String paypalbaID;
        String paypalemail;
        //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
        List<OrderLineItemWrapper> orderLineItems;
        // START : D-2093 2/4/2015 Alyana Navarro
        String vendorConversion = 'N';
        // END : D-2093 2/4/2015
    }
    
    global class OrderLineItemWrapper {        
        public String promotioncode;
        public String packagecode;
        public String addonpackagecode; 
        public Integer quantity;
        public String startDate;
        public List<String> giftCode;
        public String contractenddate;
        
    }
    //END: D-1154 1/8/2015 Added by Kristine Campang
    
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
    
    //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
    public static String billingAccountZID;
    //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
    //public static String defaultPaymentMethodId;
    public static Map<Id, Contact> contactMap; //START 08 July 2015 D-3232 Kevin Evasco - Hotfix    
    
    @HttpPost
    global static NewSubscriptionServiceResponse processRequest(NewSubscriptionServiceRequest request) {
        Savepoint savepointBeforeDML;
        origin = 'ESHOP Start Subscription';
        //START 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion checkbox assignment
        if(request.order.vendorConversion == 'Y' || request.order.vendorConversion == 'y') {
            vendorConversionFlag = true;
        }       
        //END 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion checkbox assignment
        
        try{
            //Map<Id, Contact> contactMap; //START 08 July 2015 D-3232 Kevin Evasco - Hotfix    
        
            //response.svc_status = 'SUCCESS';
            response.svc_status = GlobalVariableClass.SVC_STATUS_SUCCESS;        
            //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
            Boolean isValid = true;
            String packageBillingType = getBillingType(request);      
            String baBillingType;
            if(packageBillingType != null)
                baBillingType = getBABillingType(packageBillingType);        
            else
                isValid = false;
            
            //START 03 February 2016 UD-3844 Kevin Evasco - Paypal Rollback 
            if(isValid) {
                initializeContactWrapperInstances(request.contacts);
                //START 08 July 2015 D-3232 Kevin Evasco - Hotfix           
                contactMap = getContacts(billingContactWrapper, recipientContactWrapper);
                if(contactMap.size() != getNumberOfExpectedContacts(request.contacts)) {
                    isValid = false;            
                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                    response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;          
                    response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;               
                    response.debug += 'Number of contacts not similar. '; 
                }
                //END 08 July 2015 D-3232 Kevin Evasco - Hotfix
            }
            
            if(isValid) {
                System.debug('baBillingType 1 : '+baBillingType);
                if(request.order.paymentMode == 'Paypal'){
                
                    if(request.order.billingAccountNumber != null && request.order.billingAccountNumber != '') {
                        billingAccountStatic = getPayPalBillingAccount(request, baBillingType);
                        //request.order.paymentMethodId = defaultPaymentMethodId;
                    } else {
                        boolean ispaypalsuccesful = createPaypal(request, baBillingType);
                        if(!ispaypalsuccesful) {        
                            isValid = false;
                            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;          
                            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
                            response.debug += 'Paypal payment creation not successful. ';
                        }    
                    }
                }
            }
            
            //KRITHIKA DHARMARAJAN PAYPAL CR
            // START : D-1176 12/16/2014 Alyana Navarro - Variable that holds if field is mandatory and used in If statement.
            if(isValid) {
                isValid = validateMandatoryFields(request);
            }
            //END 03 February 2016 UD-3844 Kevin Evasco - Paypal Rollback
            //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
            
            //START 04/21/2015 UD-0975 Kevin Evasco - Mandatory Parameters validation
            if(isValid) {           
                isValid = validateValues(request);
            }           
            savepointBeforeDML = Database.setSavepoint();
            /*
            if(isValid){
                isValid = checkInvalidCharacters(request.contacts);
            } */     
            
            /*
            //START UD-1149 12-May-2015 Added by Raviteja - Checking Package Eligibility
            if(isValid) {
                Set<String> productFamilySet = New Set<String>();
                productFamilySet = getPackage(request.order.orderLineItems);
                if(productFamilySet.size() > 0){
                    isValid = isUniqueProductFamily(productFamilySet, String.Valueof(request.subscriberAccount.accountNumber));
                }
                else{
                    isValid = False;
                }
            }
            //End UD-1149 12-May-2015 Added by Raviteja             
            */
            //START 08 July 2015 D-3232 Kevin Evasco - Hotfix
            /*
            contactMap = getContacts(billingContactWrapper, recipientContactWrapper);
            if(contactMap.size() != getNumberOfExpectedContacts(request.contacts)) {
                isValid = false;            
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;          
                response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;               
                response.debug += 'Number of contacts not similar. '; 
            }*/
            //END 08 July 2015 D-3232 Kevin Evasco - Hotfix
            Set<String> productFamiliesSet = getProductFamilies(request.order.orderLineItems);
            //if(isValid && request.subscriberAccount.accountNumber != null && request.subscriberAccount.accountNumber != ''){
            //START 03 February 2016 Kevin Evasco - Rollback fix
            if(isValid) {
                if(recipientContactWrapper != null){
                    if(recipientContactWrapper.contactId != null && recipientContactWrapper.contactId != ''){
                        
                        Contact recipientContactRecord = contactMap.get(recipientContactWrapper.contactId);
                        if(recipientContactRecord != null)
                            isValid = validateSimilarSubscriptions('null',request.subscriberAccount.accountNumber, productFamiliesSet, 'null', 'null', 'null', 'null');
                        else
                            isValid = false;
                    }
                    if(recipientContactWrapper.address != null){
                        isValid = validateSimilarSubscriptions('null', request.subscriberAccount.accountNumber, productFamiliesSet, recipientContactWrapper.address.country, recipientContactWrapper.address.postalCode, recipientContactWrapper.address.levelNumber, recipientContactWrapper.address.unitNumber);
                    }
                }
                
                if(isValid == false) {
                    isValid = false;            
                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                    response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                    response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;   
                    response.debug += 'Already subscribed to this product family using the similar address. '; 
                }
            }
            //END 03 February 2016 Kevin Evasco - Rollback fix
            //}
            
            //START 17 December 2015 D-4114 Kevin Evasco - Future COA on Recipient Contact Validation
            if(isValid){
                if(recipientContactWrapper != null){
                    if(recipientContactWrapper.contactId != null && recipientContactWrapper.contactId != ''){
                        String errorMessage = SM_SubscriptionHelper.validateFutureDatedCOA(recipientContactWrapper.contactId,null,GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION);
                        if(errorMessage != null) {
                            isValid = false;            
                            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                            response.error_message = errorMessage;   
                            response.debug += errorMessage; 
                        }
                    }
                }
            }               
            //END 17 December 2015 D-4114 Kevin Evasco - Future COA on Recipient Contact Validation     
            
            //START 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion
            if(vendorConversionFlag) {
                if(productFamiliesSet.size() > 1) {
                    isValid = false;
                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                    response.error_code = GlobalVariableClass.NSS_ERROR_CODE_MULTIPLE_VENSUB;
                    response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_MULTIPLE_VENSUB;   
                } else {
                    String uniqueProductFamily;
                    for(String productFamilyElem : productFamiliesSet) {
                        uniqueProductFamily = productFamilyElem;
                    }
                    List<Subscription_Vendor__c> subscriptionVendorList = getVendorSubscriptions(recipientContactWrapper, uniqueProductFamily);
                    
                    if(subscriptionVendorList.size() == 1) {
                        vendorSubscription = subscriptionVendorList[0];
                        vendorSubscription.Subscription_Stop_Date__c = convertDate(request.order.orderLineItems[0].StartDate);
                        update vendorSubscription;
                    } else if (subscriptionVendorList.size() > 1) {
                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                        response.error_code = GlobalVariableClass.NSS_ERROR_CODE_MULTIPLE_VENSUB;
                        response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_MULTIPLE_VENSUB;   
                    } else {
                        request.order.vendorConversion = 'N';
                        vendorConversionFlag = false;
                    }
                }
            }
            //END 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion
            
            // START : D-1647 1/28/2015 Alyana Navarro - Added to validate if order line item is eligible.
            
            Account account;
            if(isValid){        
                try {
                    //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal
                    System.debug('baBillingType createAccount : '+baBillingType); 
                    account = createAccount(request.subscriberAccount, request.order, baBillingType);
                    //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
                } catch(Exception e) {
                    isValid = false; 
                    //START 20 October 2015 D-3726 Kevin Evasco - Added debugs for account creation failure
                    response.debug += 'Type: ' + e.getTypeName() + ' ';
                    response.debug += 'Message: ' + e.getMessage() + ' ';
                    response.debug += 'Stack Trace: ' + e.getStackTraceString();        
                    //END 20 October 2015 D-3726 Kevin Evasco - Added debugs for account creation failure
                }
            }
            
            if(isValid){
            
                for(OrderLineItemWrapper orderLineItemDetails : request.order.orderLineItems){
          // START : D-2093 2/4/2015 Alyana Navarro
                    if(orderLineItemDetails.promotionCode != null && orderLineItemDetails.promotionCode != '' && orderLineItemDetails.promotionCode != 'null'){
                        Integer monthsBet = convertDate(orderLineItemDetails.startDate).monthsBetween(convertDate(orderLineItemDetails.contractEndDate));
                        PackageEligibilityCheck.PackageEligibilityCheckRequest packageEligibilityCheckRequest = new PackageEligibilityCheck.PackageEligibilityCheckRequest();
                        
                        packageEligibilityCheckRequest.Packageid = orderLineItemDetails.packageCode ;
                        packageEligibilityCheckRequest.Promotionid = orderLineItemDetails.promotionCode;
                        packageEligibilityCheckRequest.Action = 'CAN ADD';//KRITHIKA DHARMARAJAN changed action as CAN ADD
                        packageEligibilityCheckRequest.SubscriptionId = '';
                        packageEligibilityCheckRequest.subscriberid = request.subscriberAccount.accountNumber; //START/END UD-2208 03 August 2015 Kevin Evasco - Only need to pass the account number for use existing account scenario
                        packageEligibilityCheckRequest.contractPeriod = String.valueOf(monthsBet);
                        
                        packageEligibilityCheckRequest.vendorConversion = request.order.vendorConversion;
                        system.debug('=================>Packageeligibity request'+packageEligibilityCheckRequest);
                        PackageEligibilityCheck.PackageEligibilityCheckResponse packageEligibilityCheckResponse = PackageEligibilityCheck.processRequest(packageEligibilityCheckRequest);                
                        system.debug('=================>Packageeligibity request'+packageEligibilityCheckResponse);
                        if(packageEligibilityCheckResponse.eligibilityFlg == GlobalVariableClass.BOOLEAN_FALSE){
                            isValid = false;                
                            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                            response.error_code = GlobalVariableClass.NOT_ELIGIBLE_ERROR_CODE;                   
                            response.error_message = GlobalVariableClass.NOT_ELIGIBLE_ERROR_MESSAGE;
                        }
                    }
            // END : D-2093 2/4/2015
                }                                   
            }   
            //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
            if(isValid) {     
                // END : D-1647 1/28/2015
                Contact recipientContact;
                
                // START: 12/09/2014 Kevin Evasco Updated class to insert billing and recipient contact using a single DML instead of two seperate DMLs.
                if(isBothRecipientAndBilling == true)
                {
                    if(recipientContactWrapper.contactId == null || recipientContactWrapper.contactId == ''){
                        recipientContact = createContact(request.contacts, account.Id, 'Both');                 
                        insert recipientContact;
                    }
                    else
                        recipientContact = contactMap.get(recipientContactWrapper.contactId);
                    
                    BilConId = recipientContact.Id;
                    RecConId = recipientContact.Id;
                    //START: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon Avoid null error during execution             
                    
                    if(request.order.paymentMode == 'Paypal'){              
                        billingAccountCreationMode = 'Use created Billing Account';
                    }
                    else if(request.order.billingAccountNumber == null || request.order.billingAccountNumber == '') {           
                        billingAccountCreationMode = 'Create New Billing Account';
                    }
                    //END: D-1591 01/22/2015 Added by S.Puli, FrancisBenzon   
                }               
                else
                {           
                    List<Contact> contactList = new List<Contact>();
                    Contact billingContact;                     
                    if(request.order.paymentMode == 'Paypal'){
                        if(billingAccountStatic == null) {
                            if(billingContactWrapper.contactId == null || billingContactWrapper.contactId == ''){
                                billingContact = createContact(request.contacts, account.Id, 'Billing Contact');                        
                                contactList.add(billingContact);
                            }
                            else
                                billingContact = contactMap.get(billingContactWrapper.contactId);
                            billingAccountCreationMode = 'Use created Billing Account';
                        } else {                        
                            BilConId = billingAccountStatic.Billing_Contact__r.Id;
                            billingAccountCreationMode = 'Use existing Billing Account';
                        }
                    
                    } else if(request.order.billingAccountNumber == null || request.order.billingAccountNumber == '')
                    {     
                        if(billingContactWrapper.contactId == null || billingContactWrapper.contactId == ''){
                            billingContact = createContact(request.contacts, account.Id, 'Billing Contact');                        
                            contactList.add(billingContact);
                        }                       
                        else
                            billingContact = contactMap.get(billingContactWrapper.contactId);
                        billingAccountCreationMode = 'Create New Billing Account';
                        
                    }               
                    if(recipientContactWrapper.contactId == null || recipientContactWrapper.contactId == ''){
                        recipientContact = createContact(request.contacts, account.Id, 'Recipient Contact');                    
                        contactList.add(recipientContact);
                    }
                    else
                        recipientContact = contactMap.get(recipientContactWrapper.contactId);
                    insert contactList;             
                    
                    // START 03/24/15 D-2363 Kevin Evasco Delivery Subscription Creation
                    if(request.order.billingAccountNumber == null || request.order.billingAccountNumber == '' || (request.order.paymentMode == 'Paypal' && billingAccountStatic == null)){
                        BilConId = billingContact.Id;
                    }                
                    // END 03/24/15 D-2363 Kevin Evasco Delivery Subscription Creation
                    
                    RecConId = recipientContact.Id;
                }
                // END: 12/09/2014 Kevin Evasco Updated class to insert billing and recipient contact using a single DML instead of two seperate DMLs.
                //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
                
                if(response.svc_status != GlobalVariableClass.SVC_STATUS_FAILURE)
                {
                //Start Added by FrancisBenzon Postage Charge build - Added recordtype in query
                recipientContact = [SELECT Id, Address__r.Postal_Code__r.Name, Address__r.Block_House_Number__c, Address__r.Level_Number__c,
                                    Address__r.Unit_Number__c, Address__r.Address_Type__c, Address__r.RecordType.Name
                                    FROM Contact 
                                    WHERE Id = :recipientContact.Id];
                //End Added by FrancisBenzon Postage Charge build - Added recordtype in query
                }
                
                Zuora__CustomerAccount__c billingAccount;
                //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
                if(response.svc_status != GlobalVariableClass.SVC_STATUS_FAILURE && request.order.paymentMode != 'Paypal')
                {
                    billingAccount = getBillingAccount(request.order.billingAccountNumber, account.Id, request.contacts);
                    // START 03/24/15 D-2363 Kevin Evasco Delivery Subscription Creation
                    if(BilConId == null && billingAccount != null) {
                        BilConId = billingAccount.Billing_Contact__r.Id; 
                    }
                    // END 03/24/15 D-2363 Kevin Evasco Delivery Subscription Creation
                } else if(billingAccountStatic != null) {
                    billingAccount = billingAccountStatic;
                }
                

                if(response.svc_status != GlobalVariableClass.SVC_STATUS_FAILURE)
                {
                    orderRecord = createOrder(request.order, account, billingAccount, recipientContact, packageBillingType);  
                }
                //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
                if(response.svc_status != GlobalVariableClass.SVC_STATUS_FAILURE)
                {
                string sAccAutoNumber = [select Account_Auto_Number__c from Account where id =: account.Id].Account_Auto_Number__c;
                string sOrderAutoNumber = [select Name from Order__c where id =: orderRecord.Id].Name;
                response.subscriberId = sAccAutoNumber;
                response.orderid = sOrderAutoNumber;
               
                //--------------------Submit
                //START 23 October 2015 D-3491 D-3760 Kevin Evasco - Update Status to Pending
                orderRecord.Status__c = GlobalVariableClass.STATUS_PENDING;
                //orderRecord.Status__c = GlobalVariableClass.TS_CLOSED;
                //END 23 October 2015 D-3491 D-3760 Kevin Evasco - Update Status to Pending
                
                update orderRecord;
                
                //if(isWaitingForVendorAssignment == false) { //START/END UD-2045 23 July 2015 Kevin Evasco - Should be able to start a subscription even if there is vendor conflict.
                    Subscription_Handler sh = new Subscription_Handler();
                    sh.origin = 'ESHOP Webservice';
                    sh.zBillingAccountId = billingAccountZID;//START/END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
                    sh.Subscription_Handler_Direct(orderRecord);
                    //--------------------------
                //} //START/END UD-2045 23 July 2015 Kevin Evasco - Should be able to start a subscription even if there is vendor conflict.
                //--------------------------
                }
                /*
                else
                {
                    String allPackageCode = '';
                    String emailAddress;
                    String name;
                    //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
                    emailAddress = billingContactWrapper.emailAddress1;
                    name = billingContactWrapper.firstName;
                    
                    for(OrderLineItemWrapper oliw : request.order.orderLineItems)
                    {
                        allPackageCode += oliw.packageCode + '<br/>';
                    }
                    
                    SendEshopCustomerEmail sendEmail = new SendEshopCustomerEmail();
                    sendEmail.SendEshopCustomerEmailFailure(name, emailAddress, allPackageCode);
                    //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
                }
                */                 
            }
            if(isValid == false) {
                //START 03 February 2016 UD-3844 Kevin Evasco - Paypal Rollback
                if(paypalBillingAccountZID != null)
                    rollBackZuoraRecords(paypalBillingAccountZID);
                //END 03 February 2016 UD-3844 Kevin Evasco - Paypal Rollback
             
                if(savepointBeforeDML != null){
                    System.debug('Before Rollback 1');
                    Database.rollback(savepointBeforeDML);
                    System.debug('Before Rollback 1');
                } else {
                    System.debug('Empty rollback 1');
                }
            }
        } catch(Exception e) {      
            //START 03 February 2016 UD-3844 Kevin Evasco - Paypal Rollback
            if(paypalBillingAccountZID != null)
                rollBackZuoraRecords(paypalBillingAccountZID);
            //END 03 February 2016 UD-3844 Kevin Evasco - Paypal Rollback
            
            if(savepointBeforeDML != null){
                System.debug('Before Rollback 2');
                Database.rollback(savepointBeforeDML);
                System.debug('After Rollback 2');
            } else {
                    System.debug('Empty rollback 2');
                }
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_GENERIC;
            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_GENERIC;
            response.debug += 'Type: ' + e.getTypeName() + ' ';
            response.debug += 'Message: ' + e.getMessage() + ' ';
            response.debug += 'Stack Trace: ' + e.getStackTraceString();
        }
        // END : D-1176 12/16/2014    
        
        return response;
    }
    
    //START UD-1149 12-May-2015 Added by Raviteja - getting list of product families from OrderLineItemWrapper
    public static Set<String> getProductFamilies(List<OrderLineItemWrapper> lstorderLineItemWrapper) {
        Set<String> productFamiliesSet = new Set<String>();
        Set<String> packageCodeSet = new Set<String>();
        
        for(OrderLineItemWrapper orderLineItemWrapperElement : lstorderLineItemWrapper) {
            if(orderLineItemWrapperElement.packagecode != null && orderLineItemWrapperElement.packagecode != '' && !String.isBlank(orderLineItemWrapperElement.packagecode)) {
                packageCodeSet.add(orderLineItemWrapperElement.packagecode);
            }
        }             
        for(Package__c packageparam :[SELECT Id, Product_Family_Current_Package__c FROM Package__c WHERE Package_Code__c IN :packageCodeSet]){
            if(packageparam.Product_Family_Current_Package__c != Null){
                     productFamiliesSet.add(packageparam.Product_Family_Current_Package__c);              
                }
         }
        
        return productFamiliesSet;
    }
    // Validating the Package 
    public static boolean isUniqueProductFamily(Set<String> productFamilies, String accountNumber){
        List<Zuora__Subscription__c> subList = [SELECT Id,Main_Package_1__c,Zuora__Account__c FROM Zuora__Subscription__c WHERE Main_Package_1__r.Product_Family_Current_Package__c IN :productFamilies AND Zuora__Account__r.AccountNumber =:accountNumber AND Zuora__Account__r.Status__c = 'Active'];
        
        if(subList.size() > 0)
        return false;
        else
        return true;
    }  
    //End UD-1149 12-May-2015 Added by Raviteja 
    
    /*
    // START 03/24/15 D-2363 Kevin Evasco Delivery Subscription Creation
    private static void sendEmailFailureNotification(NewSubscriptionServiceRequest request)
    {
        String allPackageCode = '';
        String emailAddress;
        String name;
        
        try
        {
            if(request.order.billingAccountNumber != null && request.order.billingAccountNumber != '')
                {
                    emailAddress = billingAccountStatic.Billing_Contact__r.Email__c;
                    name = billingAccountStatic.Billing_Contact__r.Name;
                }
                else
                {
                    if(Billing_Contact != null)
                    {
                        emailAddress = Billing_Contact.Email__c;
                        name = Billing_Contact.Name;
                    }
                    else
                    {
                        emailAddress = 'test@test.com';
                        name = 'Subscriber';                    
                    }
                }
                
                for(OrderLineItemWrapper oliw : request.order.orderLineItems)
                {
                    allPackageCode += oliw.packageCode + '<br/>';
                }
                
                SendEshopCustomerEmail sendEmail = new SendEshopCustomerEmail();
                sendEmail.SendEshopCustomerEmailFailure(name, emailAddress, allPackageCode); 
        }
        catch(Exception e)
        {
        }
    }
    */
    // END 03/24/15 D-2363 Kevin Evasco Delivery Subscription Creation
    
    private static Account createAccount(AccountWrapper accountDetails, OrderWrapper orderDetails, String billingTypeParam) //START/END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
    {
        List<Account> accountList = new List<Account>();
        Account accountRecord;
        System.debug('baBillingType billingTypeParam in createAccount : '+billingTypeParam);
        if(accountDetails.accountNumber == null || accountDetails.accountNumber == '')
        {
            accountRecord = new Account();
            accountRecord.Status__c = 'Active';
            accountRecord.NRIC__c = billingContactWrapper.nric;
            accountRecord.Passport__c = billingContactWrapper.passport;
            accountRecord.Mobile__c = billingContactWrapper.mobileNumber1;
            accountRecord.Email__c = billingContactWrapper.emailAddress1;
            accountRecord.Telephone_Residence__c = billingContactWrapper.homeNumber;
            accountRecord.Acknowledgement_Letter__c = 'Email';
            System.debug('baBillingType accountRecord.Billing_Type__c : '+billingTypeParam);
            accountRecord.Billing_Type__c = billingTypeParam; //START/END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
            accountRecord.Eshop_Ref_No__c = orderDetails.ReferenceId;
            
            //START 20 October 2015 D-3726 Kevin Evasco - Home Phone and Hand Phone Assignment
                       //D-3912 25/11/2015  START   24/11/2015 COMMENTING PHONE FIELD AT ACCOUNT LEVEL KRITHIKA DHARMARAJAN
            //accountRecord.Phone = billingContactWrapper.homeNumber; 
                     //D-3912 25/11/2015  END   24/11/2015 COMMENTING PHONE FIELD AT ACCOUNT LEVEL KRITHIKA DHARMARAJAN
            accountRecord.Handphone_Number__c = billingContactWrapper.mobileNumber1;
            //END 20 October 2015 D-3726 Kevin Evasco - Home Phone and Hand Phone Assignment
            
            if(accountRecord.Name == null || accountRecord.Name == '')
            {
                accountRecord.Name = billingContactWrapper.firstName + ' ' + billingContactWrapper.lastName;
            }
            else
            {
                accountRecord.Name = accountDetails.accountName;
            }
            //accountRecord.Account_Auto_Number__c = '';
                      
            if(accountDetails.recordType == 'Direct Corporate') 
            {            
                accountRecord.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate');
            }
            else if(accountDetails.recordType == 'Direct Individual')
            {
                accountRecord.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual');
            }     
            try
            {
                insert accountRecord;
                // START : D-1647 1/28/2015 Alyana Navarro
                accountRecord = [SELECT Id, Eshop_Ref_No__c, Name, Account_Auto_Number__c FROM Account WHERE Id =: accountRecord.Id];
                // END : D-1647 1/28/2015
            }
            catch(Exception e)
            {          
                System.debug('problem' + e.getMessage());        
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_code = 'EXES0014';
                response.error_message += OnlineExceptions.getErrorMessage('EXES0014');
            }
        }else{
            accountList = [SELECT Id, Eshop_Ref_No__c, Name, Account_Auto_Number__c FROM Account WHERE Account_Auto_Number__c =: accountDetails.accountNumber];
        
            if(accountList.size() > 0)
            {
                accountRecord = accountList.get(0);
            }
            else
            {
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_code = 'EXES0015';
                response.error_message += OnlineExceptions.getErrorMessage('EXES0015');                 
            }
        }                                        
        
        return accountRecord;
    }
    
    private static Zuora__CustomerAccount__c getBillingAccount(String billingAccountNumber, Id parentAccountId, List<ContactWrapper> contactDetails)
    {
        List<Zuora__CustomerAccount__c> billingAccountList;
        Zuora__CustomerAccount__c billingAccount;
        
        if(billingAccountNumber  != null  && billingAccountNumber  !=  ''){
            //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
            billingAccountList = [SELECT Id, Billing_Contact__r.Id, Billing_Contact__r.Email__c, Billing_Contact__r.Name, Zuora__Credit_Balance__c, Zuora__PaymentMethod_Type__c, Zuora__Account__c, Zuora__External_Id__c 
                                    FROM Zuora__CustomerAccount__c 
                                    WHERE Zuora__AccountNumber__c = :billingAccountNumber LIMIT 1];
            //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
                                    
        }else{
            
            billingAccountList = null;
            billingAccountNumber = null;
        }
        
        
        
        if( !(billingAccountList == null || billingAccountList.size() == 0))
        {                  
            billingAccount = billingAccountList.get(0);
            billingAccountStatic = billingAccount;
            billingAccount.Zuora__Account__c = parentAccountId;             
            billingAccountZID = billingAccount.Zuora__External_Id__c; //START/END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
            
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
        
        //START 20 October 2015 D-3726 Kevin EVasco - Home Phone assignment
        contactRecord.HomePhone__c = contactDetails.homeNumber;
        //END 20 October 2015 D-3726 Kevin EVasco - Home Phone assignment
        
        Address__c addressRecord = searchAddress(contactDetails.address);       
        if(addressRecord == null)
        {
            addressRecord = createAddress(contactDetails.address);
        }         
        
        contactRecord.Address__c = addressRecord.Id;
        
        if(contactDetails.billingIndicator == 'Y' && type == 'Billing Contact')
        {
            contactRecord.Billing_Indicator__c  = true;            
            contactRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            
            
            BilConId = contactRecord.Id;
        }
        else if(contactDetails.recipientIndicator == 'Y' && type == 'Recipient Contact')
        {
            contactRecord.Recipient_Indicator__c = true;            
            contactRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
           
            
            RecConId = contactRecord.Id;
        }
        else if(contactDetails.billingIndicator == 'Y' &&contactDetails.recipientIndicator == 'Y' && type == 'Both')
        {
            contactRecord.Billing_Indicator__c  = true;  
            contactRecord.Recipient_Indicator__c = true;            
            contactRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Francis Benzon
            
            
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
    
    private static Integer getNumberOfExpectedContacts(List<ContactWrapper> contactDetails){
        //START 08 July 2015 D-3232 Kevin Evasco - Hotfix
        Set<Id> contactIdSet = new Set<Id>();
        for(ContactWrapper contactWrapperElement : contactDetails) {
            if(contactWrapperElement.contactId != null && contactWrapperElement.contactId != '')
                contactIdSet.add(contactWrapperElement.contactId);
        }
        
        return contactIdSet.size();
        //END 08 July 2015 D-3232 Kevin Evasco - Hotfix
    }
    
    private static Map<Id, Contact> getContacts(ContactWrapper recipientContactWrapperParam, ContactWrapper billingContactWrapperParam){
        Map<Id, Contact> contactMapResult = new Map<Id, Contact>();
        Set<Id> contactIdSet = new Set<Id>();
        
        if(recipientContactWrapperParam.contactId != null && recipientContactWrapperParam.contactId != '')
        try{
        contactIdSet.add(recipientContactWrapperParam.contactId);
        }catch(Exception e){
        }
        
        if(billingContactWrapperParam.contactId != null && recipientContactWrapperParam.contactId != '')
        try{
        contactIdSet.add(billingContactWrapperParam.contactId);
        }catch(Exception e){            
        }
        //START 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion
        for(Contact contactElement : [SELECT Id, Address__r.Country__r.Country_Name__c, Address__r.Country__r.Code__c, Address__r.Postal_Code__r.Name, Address__r.Unit_Number__c, Address__r.Level_Number__c,Address__r.Address_Type__c,Address__c FROM Contact WHERE Id IN :contactIdSet]) { //START/END 08 July 2015 D-3232 Kevin Evasco - Hotfix
            //D-4114 KRITHIKA D 21/12/2015 HOTFIX SIT ADDED ADDRESS_TYPE__C IN CONTACT
            contactMapResult.put(contactElement.Id, contactElement);
        }
        //END 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion
        return contactMapResult;
    }
    
    public static Address__c searchAddress(AddressWrapper addressDetails)
    {
        Address__c addressRecord;  
        List<Address__c> addressList;
        if(addressDetails.country == GlobalVariableClass.SINGAPORE_CODE) //START/END: D-3066 06/19/2015 Kevin Evasco: Changed country code from SIN to SG
        {
            addressList = [SELECT Id, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Code__c = :addressDetails.country AND Postal_Code__r.Name = :addressDetails.postalCode AND Unit_Number__c = :addressDetails.unitNumber AND Level_Number__c = :addressDetails.levelNumber];
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
        
        if(addressDetails.country == GlobalVariableClass.SINGAPORE_CODE) //START/END: D-3066 06/19/2015 Kevin Evasco: Changed country code from SIN to SG
        {
          // Start D-1766 01/23/2015 JohnD add buildingName as parameter 
            Singpost_Address__c singpostAddress = getSingpostAddress(addressDetails.postalCode, addressDetails.buildingName, addressDetails.houseBlockNumber);
            // End D-1766 01/23/2015 JohnD
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
        List<Country__c> countryList = [SELECT Id, Country_Name__c FROM Country__c WHERE Code__c = :countryCode]; //START/END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
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
    
    // Start D-1766 01/23/2015 JohnD modify the method adding validation on building name
    public static Singpost_Address__c getSingpostAddress(String postalCode, string buildingName, String houseBlockNumberParam)
    {
        Boolean isValidAddress = true;
        Singpost_Address__c singpostAddressRecord;
        List<Singpost_Address__c> singpostAddressList = new list<Singpost_Address__c>();
        
        if (postalCode != null && postalCode.containsOnly('1234567890') && postalCode.length() == 6 ) { // D- 1851 Changes made by Joban
          
          singpostAddressList = [SELECT Id, Building_Name__c FROM Singpost_Address__c WHERE Name = :postalCode AND House_Block_Number__c = :houseBlockNumberParam LIMIT 1];
                   
          if (singpostAddressList.size() > 0) {            
            singpostAddressRecord = singpostAddressList.get(0);            
            if (buildingName != singpostAddressRecord.Building_Name__c && buildingName != '' && buildingName != null)                
                isValidAddress = false;         
          } else {            
              isValidAddress = false;            
          }
        
        } else {
            isValidAddress = false;  
        }
        
        if(isValidAddress == false) {
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
            response.debug += 'Singpost address does not exist. '; 
        }
        
        return singpostAddressRecord;
    }
    // End D-1766 01/23/2015 JohnD
    
    
    
    
    private static Order__c createOrder(OrderWrapper orderDetails, Account parentAccount, Zuora__CustomerAccount__c billingAccount, Contact recipientContact, String billingTypeParam) //START/END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
    {
        set<Id> sId = new set<Id>();
        
        sId.add(BilConId);
        sId.add(RecConId);
        
        
        for(Contact con: [select id, Email__c, name, Zone__c,Billing_Indicator__c, Recipient_Indicator__c, 
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
        
        orderRecord = new Order__c();
        
        orderRecord.Billing_Type__c = billingTypeParam; //START/END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
        
        orderRecord.Account__c = parentAccount.Id;
        //START: D-1563 01/20/2014 Added by S.Puli
        orderRecord.DTL_Date__c = SM_SubscriptionHelper.getDtlDate();
        //END: D-1563 01/20/2014 Added by S.Puli
        if(orderDetails.paymentMode == 'IPP'){
            orderRecord.Payment_Mode__c = 'Other';
            orderRecord.Other_Payment_Mode__c = 'IPP';//KRITHIKA D D-1573 2/23/2015
        }else{
            orderRecord.Payment_Mode__c = orderDetails.paymentMode;
            orderRecord.Other_Payment_Mode__c = '';
            //START: D-1563 01/16/2014 Added by S.Puli Uncomment to pass the paymentmethodid
            if(orderDetails.paymentMode=='Credit Card'){
                orderRecord.Payment_Method_ID__c = orderDetails.paymentMethodId;
            }
            //END: D-1563 01/16/2014 Added by S.Puli
            //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
            if(orderDetails.paymentMode=='Paypal'){
               orderRecord.Payment_Method_ID__c = orderDetails.paymentMethodId;
            }
            //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
        }
        
        if(billingAccountCreationMode == 'Create New Billing Account'){
            orderRecord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            orderRecord.Billing_Contact__c = Billing_Contact.Id;
            orderRecord.Credit_Balance__c = 0;
        }
        //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
        else if(billingAccountCreationMode == 'Use created Billing Account') {
            orderRecord.Billing_Account_Creation_Mode__c = 'Use created Billing Account';
            orderRecord.Billing_Contact__c = Billing_Contact.Id;
            orderRecord.Credit_Balance__c = 0; 
        }
        //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
        else{
            orderRecord.Billing_Account__c = billingAccount.Id;
            orderRecord.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';  
            orderRecord.Billing_Contact__c = billingAccount.Billing_Contact__r.Id;          
            
            orderRecord.Credit_Balance__c = 0;          
            if(billingaccount.Zuora__Credit_Balance__c != null){
                orderRecord.Credit_Balance__c = billingaccount.Zuora__Credit_Balance__c;
            }
        }
        
        orderRecord.Order_Type__c = 'Start';
        orderRecord.Order_Type1__c = 'Start';
        
        
        orderRecord.Recipient_Contact__c = recipientContact.Id;
        
        string recipientAddressType = Recipient_Contact.Address__r.Address_Type__c;
        Id recipientAddressId = Recipient_Contact.Address__c;
        
        orderRecord.Delivery_Charge_Type__c = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType);
        
        //START: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon Avoid null pointer by try catch
        addressTypeDeliveryChargeType =  recipientAddressType + orderRecord.Delivery_Charge_Type__c;
        //END: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon
        
        //STAREND 27 September 2015 UD-2860 Kevin Evasco - Use the SM_SubscriptionHelper to get the Subscriber Charge and Vendor Credit.
        Map<String, Decimal> chargeMap = SM_SubscriptionHelper.getCharges(orderRecord.Recipient_Contact__c, orderRecord.Delivery_Charge_Type__c, null, null);
        
        //START 23 October 2015 D-3491 D-3760 Kevin Evasco - Set charge to 0 if null
        if(chargeMap.get('SubscriberCharge') == null)
            chargeMap.put('SubscriberCharge',0);
        if(chargeMap.get('VendorCredit') == null)
            chargeMap.put('VendorCredit',0);
        //END 23 October 2015 D-3491 D-3760 Kevin Evasco - Set charge to 0 if null
        
        
        orderRecord.Subscriber_Charge__c = chargeMap.get('SubscriberCharge');
        orderRecord.Vendor_Credit__c = chargeMap.get('VendorCredit');       
        //END 27 September 2015 UD-2860 Kevin Evasco - Use the SM_SubscriptionHelper to get the Subscriber Charge and Vendor Credit.
        
        orderRecord.Zone_Charge__c = ConstantsSLB.getPostageCharge(Recipient_Contact.Zone__c);
        
        orderRecord.Monthly_Delivery_Charge_for_Full_Payment__c = 0; //months * delivery charge     
        
        DeliveryChargeCheck.DeliveryChargeCheckRequest deliveryChargeRequest = new DeliveryChargeCheck.DeliveryChargeCheckRequest();
        deliveryChargeRequest.postalCode = recipientContact.Address__r.Postal_Code__r.Name;
        deliveryChargeRequest.blkno = recipientContact.Address__r.Block_House_Number__c;
        deliveryChargeRequest.levelno = recipientContact.Address__r.Level_Number__c;
        deliveryChargeRequest.unitno = recipientContact.Address__r.Unit_Number__c;
        deliveryChargeRequest.subscriberid = parentAccount.Account_Auto_Number__c;
        
        DeliveryChargeCheck.DeliveryChargeCheckResponse deliveryChargeResponse = DeliveryChargeCheck.processRequest(deliveryChargeRequest);
        
        //orderRecord.Delivery_Charge__c = Decimal.valueOf(deliveryChargeResponse.delivery_charge);     
        //START: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon Avoid null pointer by try catch
        orderRecord.Delivery_Charge__c = chargeMap.get('SubscriberCharge'); 
        //END: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon       
        
        orderRecord.Status__c = 'Draft';
        orderRecord.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
        
        
        
        orderRecord.Informed_Customer__c = true;
        
        insert orderRecord;
        //START D-1156 1/13/2015 Added by FrancisBenzon - VARIABLES
        //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
        orderRecord = [SELECT Id, Recipient_Contact__r.Address__r.Postal_Code__c, Account__r.Account_Auto_Number__c,
                        Billing_Contact__c, Recipient_Contact__r.Address__c, Recipient_Contact__c,
                        Account__c, Acquisition_Type__c, Remarks__c, Parent_Case__c, Billing_Account_Creation_Mode__c, Billing_Account__c, FP_Del_Usage__c, Subscriber_Charge__c, Payment_Mode__c, Other_Payment_Mode__c, Delivery_Charge_Type__c, Payment_Method_ID__c, Billing_Type__c, Delivery_Charge__c
                        FROM Order__c 
                        WHERE Id = :orderRecord.Id];        
        //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
        createOrderLineItems(orderDetails.orderLineItems, orderRecord, orderDetails.ldapid, recipientContact, null); //START/END 20 October 2015 D-3377 and D-3376 Kevin Evasco - Restrict vendor assignment if the vendor has been assigned already
        //END D-1156 1/13/2015 Added by FrancisBenzon - VARIABLES
        
        return orderRecord;
    }
    
    @future(callout = true)
    public static void retrieveUserDetails(String ldapid, Id contactId, Map<Id,Id> orderLineItemId_packageId_Map, Set<Id> allPackagesIdSetParam){ //START/END 12 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription creation. 
        Map<String,Object> userDetailsMap = AsiaOneServicesController.viewUserDetails(ldapId);
        List<Asia1_Subscription__c> asia1SubscriptionList = new List<Asia1_Subscription__c>();
        
        Map<Id,Set<Id>> packageAccessFlagMap = retrieveServiceFlags(allPackagesIdSetParam); //START/END 12 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription creation. 
        
            asia1 = new Asia1__c();
            asia1.Contact__c = contactId;
            asia1.User_ID_LDAP_ID__c = ldapId;
            asia1.Display_Name__c = String.valueof(userDetailsMap.get('Display Name'));
            asia1.Email__c = String.valueof(userDetailsMap.get('E-Mail'));
            asia1.Email_Address__c = String.valueof(userDetailsMap.get('E-Mail'));
            asia1.Secret_Answer__c = String.valueof(userDetailsMap.get('Password Answer'));
            asia1.Secret_Question__c = String.valueof(userDetailsMap.get('Pasword Question'));
            asia1.Password__c = ConstantsSLB.getAsiaOnePassword('AsiaOne');
            //START 06022016 PD-0250 Topher Camilon - Asia1 Subscription Activation
            asia1.Status__c = GlobalVariableClass.ASIAONE_CREATED;  
            //END 06022016 PD-0250 Topher Camilon - Asia1 Subscription Activation
            insert asia1;
        
        //START 27 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription Activation
        for(Id orderLineItemIdElem : orderLineItemId_packageId_Map.keySet()){
            
            Set<Id> packageAccessFlagList = packageAccessFlagMap.get(orderLineItemId_packageId_Map.get(orderLineItemIdElem));
            if(packageAccessFlagList == null) {
                Asia1_Subscription__c asia1Subscription = new Asia1_Subscription__c();
                asia1Subscription.Asia1__c = asia1.Id;
                asia1Subscription.Order_Line_Item__c = orderLineItemIdElem; 
                //START 06022016 PD-0250 Topher Camilon - Asia1 Subscription Activation
                //START 06072016 PD-0249 Topher Camilon - Asia1 No Service Flag Disabled
                asia1Subscription.Status__c = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;     
                //END 06072016 PD-0249 Topher Camilon - Asia1 No Service Flag Disabled                          
                //asia1Subscription.Status__c = GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED;
                //END 06022016 PD-0250 Topher Camilon - Asia1 Subscription Activation
                asia1SubscriptionList.add(asia1Subscription);
            }
            else {
                for(Id packageAccessFlagId : packageAccessFlagList) {
                    Asia1_Subscription__c asia1Subscription = new Asia1_Subscription__c();
                    asia1Subscription.Asia1__c = asia1.Id;
                    asia1Subscription.Order_Line_Item__c = orderLineItemIdElem;
                    //START 06022016 PD-0250 Topher Camilon - Asia1 Subscription Activation
                    //asia1Subscription.Status__c = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;                                    
                    asia1Subscription.Status__c = GlobalVariableClass.ASIA1_SUBSCRIPITON_STATUS_ENABLED;
                    //END 06022016 PD-0250 Topher Camilon - Asia1 Subscription Activation
                    asia1Subscription.Service_Access_Flag__c = packageAccessFlagId; 
                    asia1SubscriptionList.add(asia1Subscription);
                }
            }
        }
        //END 27 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription Activation 
        insert asia1SubscriptionList;

    }
    
    
    public static void createOrderLineItems(List<OrderLineItemWrapper> orderLineItemDetailsList, Order__c parentOrder, String ldapid, Contact recipientContact, Id vendorMailingAgentId)//Start/End Added by FrancisBenzon Postage Charge Build - added input parameter //START/END D-3377 and D-3376 Vendor / Mailing Agent Assignment
    {
        List<Order_Line_Item__c> orderLineItemRecordsList = new List<Order_Line_Item__c>();
        List<Asia1__c> asia1List = new List<Asia1__c>();
        List<Package__c> packageList = new List<Package__c>();
        List<Order__c> orderList = new List<Order__c>();
        List<Package_Item__c> packageItemList = new List<Package_Item__c>();
        List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c>();
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        List<zqu__ZProduct__c> productList = new List<zqu__ZProduct__c>();
        List<Product_Publication__c> productPublicationList = new List<Product_Publication__c>();
        List<Promotion_Gift__c> promotionGiftList = new List<Promotion_Gift__c>();
        List<Order_Line_Item_Gift__c> orderLineItemGiftList = new List<Order_Line_Item_Gift__c>();
    //START: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon Avoid null pointer by try catch
    List<Order__c> parentOrdList = new List<Order__c>();
    //END: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon
        //START: D-1154 1/8/2015 Added by Kristine Campang - removed variable
        //Set<String> ldapIdSet = new Set<String>();
        //END: D-1154 1/8/2015 Added by Kristine Campang
        Set<Id> allPackagesIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        Set<Id> packageItemIdSet = new Set<Id>(); 
        Set<Id> productRatePlanIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        Set<String> giftIdSet = new Set<String>();
        Set<Id> promotionIdSet = new Set<Id>();
        Set<Id> promotionGiftIdSet = new Set<Id>();
        //START 12 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription Activation
        //Set<Id> orderLineItemIdSet = new Set<Id>();
        
        //Map<Id,List<Package_Access_Flag__c>> packageAccessFlagMap;
        Map<Id,Id> orderLineItemId_packageId_Map = new Map<Id,Id>();
        //END 12 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription Activation
        Map<String,Asia1__c> asia1Map = new Map<String,Asia1__c>();
        
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
        
        //START D-1156 1/13/2015 Added by FrancisBenzon - VARIABLES
        Id postalCodeId;
        List<Vendor_Allocation__c> venAllocList = new List<Vendor_Allocation__c>();                        
        //END D-1156 1/13/2015 Added by FrancisBenzon - VARIABLES
        //Start Added by FrancisBenzon Postage Charge Subscription - Variable 1/19/2015 Updated 1/21/2015
        Boolean hasPostageCharge = false;
        String pubDeliveredBy;
        String DirectSubDelMethod = ConstantsSLB.getKeyId('Publication Delivered By');
        //End Added by FrancisBenzon Postage Charge Subscription - Variable 1/19/2015 Updated 1/21/2015
        
        
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
            for(Package__c p: [select Id, Package_Code__c, Product_Family_Current_Package__c from Package__c where Package_Code__c IN: sPackageCode]){ //START/END 08 October 2015 UD-2968 Kevin Evasco - Added Product_Family_Current_Package__c
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
        //Start Added by FrancisBenzon : Added isNewspaper and isMagazine on query
        //START // End D-2969 17-June-2015 Added by Raviteja  - Added Is_Print__c,Is_Digital__c,Is_All_In_One__c Fields in SOQL 
        packageItemList = [SELECT Id, Package__r.Id, Package__r.Billing_Type__c, Billing_Type__c, Product_Rate_Plan__r.Id, 
                            Product_Rate_Plan__r.zqu__ZProduct__r.Id, Is_Newspaper__c, Is_Magazine__c,Is_Print__c,Is_Digital__c,Is_All_In_One__c 
                            FROM Package_Item__c 
                            WHERE Package__c IN :allPackagesIdSet];
        //End Added by FrancisBenzon : Added isNewspaper and isMagazine on query
        for(Package_Item__c packageItem : packageItemList)
        {
        system.debug('>>>>>CHA packageItem.Package__r.Billing_Type__c  ' + packageItem.Package__r.Billing_Type__c );
system.debug('>>>>>CHA packageItem.Billing_Type__c ' + packageItem.Billing_Type__c);
            if(packageItem.Package__r.Billing_Type__c == packageItem.Billing_Type__c)
            {
                List<Package_Item__c> packageItemTempList = package_packageItemMap.get(packageItem.Package__r.Id);
                if(packageItemTempList == null)
                {
                    packageItemTempList = new List<Package_Item__c>();
                }
                packageItemTempList.add(packageItem);
                system.debug('>>>>>CHA packageItem ' + packageItem);
system.debug('>>>>>CHA packageItem.Package__r.Id ' + packageItem.Package__r.Id);
system.debug('>>>>>CHA packageItemTempList ' + packageItemTempList);
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
        // START : D-2093 2/5/2015 Alyana Navarro
        if(parentOrder.Recipient_Contact__c != null) {
            postalCodeId = parentOrder.Recipient_Contact__r.Address__r.Postal_Code__c;
            if(postalCodeId != null) {
                venAllocList = [SELECT Id, Vendor_Account__c FROM Vendor_Allocation__c
                                WHERE SingPost_Address__c = :postalCodeId];                                     
            }
        }
        // END : D-2093 2/5/2015
        for(OrderLineItemWrapper orderLineItemDetails : orderLineItemDetailsList)
        {            
                Order_Line_Item__c orderLineItemRecord = new Order_Line_Item__c();
                
                orderLineItemRecord.Order__c = parentOrder.Id;
                //START: D-1563 01/20/2014 Added by S.Puli
                orderLineItemRecord.DTL_Date__c = SM_SubscriptionHelper.getDtlDate();
                //END: D-1563 01/20/2014 Added by S.Puli
                //START 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion checkbox assignment
                if(vendorConversionFlag) {
                    orderLineItemRecord.Vendor_Conversion__c = vendorConversionFlag;
                    orderLineItemRecord.Vendor_Subscription_ID__c = vendorSubscription.Id;
                    orderLineItemRecord.Parent_Account__c = vendorSubscription.Account__c;
                }
                //END 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion checkbox assignment
                
                //START 26 November 2015 UD-3301 Kevin Evasco - Contract Period / Contract End Date assignment 
                if(orderLineItemDetails.promotioncode != ''){
                    
                    Id PromId = mPromCode_Prom.get(orderLineItemDetails.promotioncode);                    
                    Promotion__c promotion = mProm.get(PromId);
                    
                    orderLineItemRecord.Promotion_ID__c = PromId; 
                    
                    if(mProm.get(PromId) != null) {
                        
                        date dStart = convertDate(orderLineItemDetails.startdate);
                        String contractPeriodStr = promotion.Contract_Period__c;
                        if(contractPeriodStr != null && contractPeriodStr != '') {
                            Integer contractPeriodInt = Integer.valueOf(contractPeriodStr);
                            orderLineItemRecord.New_Contract_Period__c = contractPeriodInt;
                            orderLineItemRecord.Contract_End_Date__c = dStart.addMonths(contractPeriodInt).addDays(-1);
                        }
                        
                        String sPenalty = mProm.get(PromId).Penalty_Charge__c;
                        if(sPenalty == '' || sPenalty == null)
                            orderLineItemRecord.Penalty_Charge__c = 0;
                        else
                            orderLineItemRecord.Penalty_Charge__c = decimal.valueOf(sPenalty);
                    }          
                }                
                //END 26 November 2015 UD-3301 Kevin Evasco - Contract Period / Contract End Date assignment 
                
                Id pckId = mPckgCode_Pckg.get(orderLineItemDetails.packagecode);
                Id pckIdAddon = mPckgCode_Pckg.get(orderLineItemDetails.addOnPackagecode);
                
                //START 08 October 2015 Kevin Evasco UD-2968 - No delivery fee for TABL and MY  
                Package__c packageRecord = mPckg.get(pckId);
                if(packageRecord != null){
                    if(noDeliveryPublications.contains(packageRecord.Product_Family_Current_Package__c)){
                        parentOrder.Delivery_Charge_Type__c = 'Z';
                        parentOrder.Delivery_Charge__c = 0;
                        parentOrder.Subscriber_Charge__c = 0;
                        parentOrder.Vendor_Credit__c = 0;          
                    }
                }
                //END 08 October 2015 Kevin Evasco UD-2968 - No delivery fee for TABL and MY
                
                
                orderLineItemRecord.Main_Package_ID__c = pckId;
                //Start: Added By FrancisBenzon Postage Charge Build - Specify Delivered by depending on criteria 1/19/2015 Updated 1/21/2015
        //START: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon Avoid null pointer by try catch
        //START D-2969 17-June-2015 Added by Raviteja  - Commented the exisiting code and applying whole code in  packageItemList for loop
        /*
        try
        { 
          pubDeliveredBy = product_productPublicationMap.get(productRatePlanMap.get(packageItemList[0].Product_Rate_Plan__r.Id).zqu__ZProduct__r.Id)[0].Publication_Code__r.Direct_Sub_Delivery_Method__c;
        } catch (exception e){
          pubDeliveredBy = null;
        }
        if(recipientContact.Address__r.RecordTypeId != ConstantsSLB.getkeyid('Address_Local'))
        {
          orderLineItemRecord.Delivered_By__c = 'Mailing Agent';
          orderLineItemRecord.Direct_Sub_Delivery_Method__c = 'Mailing Agent'; 
          parentOrder.Delivery_Charge__c = 0;
          hasPostageCharge = true; 
        }
        else if(recipientContact.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Local')&& (pubDeliveredBy == null || pubDeliveredBy == DirectSubDelMethod))
        {          
          if(packageItemList[0].Is_Newspaper__c == true)                
          {
            orderLineItemRecord.Delivered_By__c = 'Vendor';
            orderLineItemRecord.Direct_Sub_Delivery_Method__c = 'Vendor';
            parentOrder.Delivery_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
          }
          else if(packageItemList[0].Is_Magazine__c == true)
          {
            orderLineItemRecord.Delivered_By__c = 'Mailing Agent';
            orderLineItemRecord.Direct_Sub_Delivery_Method__c = 'Mailing Agent';
            parentOrder.Delivery_Charge__c = 0;
            hasPostageCharge = true; 
          }
        }
        else if(recipientContact.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Local'))
        {
          orderLineItemRecord.Delivered_By__c = pubDeliveredBy;
          orderLineItemRecord.Direct_Sub_Delivery_Method__c = pubDeliveredBy; 
          if(pubDeliveredBy == 'Vendor')
          {
            parentOrder.Delivery_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
          }
          else if(pubDeliveredBy == 'Mailing Agent')
          {
            parentOrder.Delivery_Charge__c = 0;
            hasPostageCharge = true; 
          }
        }
        */
        for(Package_Item__c objpackageItem : packageItemList ){         
        try
        { 
          pubDeliveredBy = product_productPublicationMap.get(productRatePlanMap.get(objpackageItem.Product_Rate_Plan__r.Id).zqu__ZProduct__r.Id)[0].Publication_Code__r.Direct_Sub_Delivery_Method__c;
        } catch (exception e){
          pubDeliveredBy = null;
        }
        system.debug('>>>>>CHA recipientContact.Address__r.RecordTypeId ' + recipientContact.Address__r.RecordTypeId);
        system.debug('>>>>>CHA pubDeliveredBy ' + pubDeliveredBy);
        system.debug('>>>>>CHA DirectSubDelMethod ' + DirectSubDelMethod);
        if(recipientContact.Address__r.RecordTypeId != ConstantsSLB.getkeyid('Address_Local'))
        {
          orderLineItemRecord.Delivered_By__c = 'Mailing Agent';
          orderLineItemRecord.Direct_Sub_Delivery_Method__c = 'Mailing Agent'; 
          parentOrder.Delivery_Charge__c = 0;
          parentOrder.Subscriber_Charge__c = 0; //START/END 26 September 2015 UD-2860 - Update subscriber charge to 0 if no delivery is needed
          hasPostageCharge = true; 
        }
        else if(recipientContact.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Local')&& (pubDeliveredBy == null || pubDeliveredBy == DirectSubDelMethod))
        { 
            system.debug('>>>>>CHA objpackageItem.Is_Magazine__c ' + objpackageItem.Is_Magazine__c);
            system.debug('>>>>>CHA orderLineItemRecord.Delivered_By__c ' + orderLineItemRecord.Delivered_By__c);
          //Start D-3151 23-June-2015 Added by Raviteja - updating the if conidition logic for All-in-One Package       
          if((objpackageItem.Is_Newspaper__c == true && objpackageItem.Is_Print__c == True && (orderLineItemRecord.Delivered_By__c == Null || orderLineItemRecord.Delivered_By__c == 'None')) 
              || (objpackageItem.Is_Newspaper__c == true && objpackageItem.Is_All_In_One__c == True && (orderLineItemRecord.Delivered_By__c == Null || orderLineItemRecord.Delivered_By__c == 'None')))           
           //End D-3151 23-June-2015 Added by Raviteja  
          {
            orderLineItemRecord.Delivered_By__c = 'Vendor';
            orderLineItemRecord.Direct_Sub_Delivery_Method__c = 'Vendor';
            //parentOrder.Delivery_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType); //START/END 26 September 2015 UD-2860 - Use the value from SM_SubscriptionHelper subscriber charge
          }
          else if(objpackageItem.Is_Magazine__c == true && (orderLineItemRecord.Delivered_By__c == Null || orderLineItemRecord.Delivered_By__c == 'None'))
          {
            orderLineItemRecord.Delivered_By__c = 'Mailing Agent';
            orderLineItemRecord.Direct_Sub_Delivery_Method__c = 'Mailing Agent';
            parentOrder.Delivery_Charge__c = 0;
            parentOrder.Subscriber_Charge__c = 0; //START/END 26 September 2015 UD-2860 - Update subscriber charge to 0 if no delivery is needed
            hasPostageCharge = true; 
          }
        }
        else if(recipientContact.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Local'))
        {
          orderLineItemRecord.Delivered_By__c = pubDeliveredBy;
          orderLineItemRecord.Direct_Sub_Delivery_Method__c = pubDeliveredBy; 
          system.debug('>>>>>CHA pubDeliveredBy ' + pubDeliveredBy);
          if(pubDeliveredBy == 'Vendor')
          {
            //parentOrder.Delivery_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType); //START/END 26 September 2015 UD-2860 - Use the value from SM_SubscriptionHelper subscriber charge
          }
          else if(pubDeliveredBy == 'Mailing Agent')
          {
            parentOrder.Delivery_Charge__c = 0;
            parentOrder.Subscriber_Charge__c = 0; //START/END 26 September 2015 UD-2860 - Update subscriber charge to 0 if no delivery is needed
            hasPostageCharge = true; 
          }
        }       
        system.debug('>>>>>CHA orderLineItemRecord.Delivered_By__c ' + orderLineItemRecord.Delivered_By__c);
        if(orderLineItemRecord.Delivered_By__c == null){
            orderLineItemRecord.Delivered_By__c = 'None';
            orderLineItemRecord.Direct_Sub_Delivery_Method__c = pubDeliveredBy;
            parentOrder.Delivery_Charge__c = 0;
            parentOrder.Subscriber_Charge__c = 0; //START/END 26 September 2015 UD-2860 - Update subscriber charge to 0 if no delivery is needed
            hasPostageCharge = false;  
        }      
        
        //START 12 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription record update
        if(objpackageItem.Is_Digital__c == true) {
            orderLineItemRecord.Is_Digital__c = true;
        }
        //END 12 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription record update
       } // for loop end
        //End D-2969 17-June-2015 Added by Raviteja
        
        //START 26 September 2015 UD-2860 - Update subscriber charge to 0 if no delivery is needed
        if(parentOrder.Delivery_Charge__c == null){
            parentOrder.Delivery_Charge__c = 0;
            parentOrder.Subscriber_Charge__c = 0;
        }
        //END 26 September 2015 UD-2860 - Update subscriber charge to 0 if no delivery is needed
        
        //END: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon
                //orderLineItemRecord.Delivered_By__c = product_productPublicationMap.get(productRatePlanMap.get(package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id).zqu__ZProduct__r.Id)[0].Publication_Code__r.Direct_Sub_Delivery_Method__c;
                //orderLineItemRecord.Direct_Sub_Delivery_Method__c = product_productPublicationMap.get(productRatePlanMap.get(package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id).zqu__ZProduct__r.Id)[0].Publication_Code__r.Direct_Sub_Delivery_Method__c;
                //End: Added By FrancisBenzon Postage Charge Build - Specify Delivered by depending on criteria 1/19/2015 Updated 1/21/2015
                                 
                orderLineItemRecord.Qty__c = orderLineItemDetails.quantity;
                orderLineItemRecord.Start_Date__c = convertDate(orderLineItemDetails.StartDate);
                orderLineItemRecord.Main_Package_Billing_Type__c = packageMap.get(pckId).Billing_Type__c;
                orderLineItemRecord.Main_Package_Sub_Type__c = packageMap.get(pckId).Subscription_Type__c;//Package_Sub_Type__c;
                orderLineItemRecord.Main_Package_Type__c =  packageMap.get(pckId).Package_Type__c;
                
                orderLineItemRecord.Subscribed_as__c = 'New Buy';
                
                String termLength = packageMap.get(pckId).Subscription_Period__c;
                if(termLength != 'N/A' && termLength != null && termLength != '') //START/END 08 July 2015 D-3232 Kevin Evasco - Hotfix
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
                system.debug('>>>>>CHA pckId ' + pckId);
system.debug('>>>>>CHA package_packageItemMap.get(pckId) ' + package_packageItemMap.get(pckId));
system.debug('>>>>>CHA package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id ' + package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id);
system.debug('>>>>>CHA productRatePlanMap.get(package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id) ' + productRatePlanMap.get(package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id));
system.debug('>>>>>CHA productRatePlanMap.get(package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id).SubscriptionFrequency__c ' + productRatePlanMap.get(package_packageItemMap.get(pckId)[0].Product_Rate_Plan__r.Id).SubscriptionFrequency__c);
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
                // START 03/16/15 D-2284 Kevin Evasco - Vendor Assignment should only be done when delivered by vendor.
                //START 20 October 2015 D-3377 and D-3376 Kevin Evasco - Restrict vendor assignment if the vendor has been assigned already
                if(orderLineItemRecord.Delivered_By__c == 'Vendor' && vendorMailingAgentId == null)
                {
                    //START D-1156 1/13/2015 Added by FrancisBenzon - assign Vendor to OLI and create Case if none.
                    if(venAllocList.size() > 1 || venAllocList.size() == 0) {
                        orderLineItemRecord.Vendor_Mailing_Agent__c = null;
                        createCaseFlag = true; //START/END 03/16/15 D-2417 Kevin Evasco - Single case should be created even for multiple order line items.
                        //START 05/04/2015 CR-005 Kevin Evasco - PayPal CR
                        if(venAllocList.size() == 0){ 
                            //response.error_message = 'No vendor is assigned for the Contact Address. Please assign manually. ';   
                            isWaitingForVendorAssignment = true;
                        } else if(venAllocList.size() > 1){
                            //response.error_message = 'More than one vendor is assigned for the Contact Address. Please assign manually. ';
                            isWaitingForVendorAssignment = true;
                        }
                        //END 05/04/2015 CR-005 Kevin Evasco - PayPal CR
                    }
                    else if(venAllocList.size() == 1) {
                        orderLineItemRecord.Vendor_Mailing_Agent__c = venAllocList[0].Vendor_Account__c;
                    }           
                    //END D-1156 1/13/2015 Added by FrancisBenzon - assign Vendor to OLI and create Case if none.
                } else if(vendorMailingAgentId != null) {
                    createCaseFlag = false;
                    orderLineItemRecord.Vendor_Mailing_Agent__c = vendorMailingAgentId;
                }       
                //END 20 October 2015 D-3377 and D-3376 Kevin Evasco - Restrict vendor assignment if the vendor has been assigned already               
                // END 03/16/15 D-2284 Kevin Evasco - Vendor Assignment should only be done when delivered by vendor.           
                //START: D-1154 1/8/2015 Added by Kristine Campang - removed lines and transferred to Order Level
                //END: D-1154 1/8/2015 Added by Kristine Campang 
                orderLineItemRecordsList.add(orderLineItemRecord);
                orderLineItemWrapperMap.put(counter,orderLineItemDetails);
                
            counter++;
        }
        
        //START 03/16/15 D-2417 Kevin Evasco - Single case should be created even for multiple order line items.
        //START 23 October 2015 D-3491 D-3760 Kevin Evasco - Always Create Case for Start Subscription
        if(origin == 'ESHOP Start Subscription'){         
            Case caseRecord = createCase(parentOrder,isWaitingForVendorAssignment);
            
            for(Order_Line_Item__c orderLineItemElem : orderLineItemRecordsList) {
                orderLineItemElem.Case__c = caseRecord.Id;
            }
        }
        //END 23 October 2015 D-3491 D-3760 Kevin Evasco - Always Create Case for Start Subscription
        //END 03/16/15 D-2417 Kevin Evasco - Single case should be created even for multiple order line items.
        
        // START : D-2093 2/5/2015 Alyana Navarro
        parentOrdList.add(parentOrder);
        // END : D-2093 2/5/2015
              
        //packageAccessFlagMap = retrieveServiceFlags(allPackagesIdSet); //START/END 12 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription Activation
        //START: D-1154 1/8/2015 Added by Kristine Campang - removed lines
        //END: D-1154 1/8/2015 Added by Kristine Campang        
        insert orderLineItemRecordsList; 
    //START: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon Avoid null error during execution
    update parentOrdList;
        //END: D-1591, D-1883 01/22/2015 Added by S.Puli, FrancisBenzon
        //Start Added By FrancisBenzon Postage Charge Subscription : Calculation of Postage Charge
        system.debug('>>>>>CHA hasPostageCharge ' + hasPostageCharge);
        if(hasPostageCharge) {
            for(Order_Line_Item__c oli : orderLineItemRecordsList) {
                oli.Postage_Charge__c = PostageChargeHelper.getPostageChargeForLineItem(parentOrder.Recipient_Contact__c, oli);
            }
            update orderLineItemRecordsList;
        }
        //End Added By FrancisBenzon Postage Charge Subscription : Calculation of Postage Charge
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
            //Package_Access_Flag__c packageAccessFlag = packageAccessFlagMap.get(orderLineItem.Main_Package_ID__r.Id); //START/END 12 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription Activation
            
            orderLineItemId_packageId_Map.put(orderLineItem.Id, orderLineItem.Main_Package_ID__c); //START/END 12 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription Activation
            
            List<Promotion_Gift__c> promotionGiftTempList = promo_promoGiftMap.get(orderLineItem.Promotion_ID__r.Id);
            
            if(promotionGiftTempList != null)
            {
                for(Promotion_Gift__c promotionGift : promotionGiftTempList)
                {
                    Order_Line_Item_Gift__c orderLineItemGift = new Order_Line_Item_Gift__c();
                    orderLineItemGift.Order_Line_Item__c = orderLineItem.Id;
                    orderLineItemGift.Promotion_Gift__c = promotionGift.Id;
                    //START D-3036 - 18-Jun-2015 Added by Raviteja - Assiging Quantity to Order Line Item Gift
                     orderLineItemGift.Order_Quantity__c = orderLineItem.Qty__c;   
                    //End D-3036 - 18-Jun-2015 Added by Raviteja  
                    
                    orderLineItemGift.Hidden_Status__c = 'Provisioning'; //START/END 23 October 2015 D-3491 D-3760 Kevin Evasco - Default Status to Provisioning
                    
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
        
        //START: D-1154 1/8/2015 Removed by Kristine Campang - removed lines for batch viewUserDetails
        /* 
        Asia1BatchUpdate asia1Batchable = new Asia1BatchUpdate(ldapIdSet);
        Database.executeBatch(asia1Batchable,10);    
        */
        //END: D-1154 1/8/2015 Removed by Kristine Campang 
        Map<Id,Decimal> totalGiftPriceMap = calculateTotalGiftPrice(promo_orderLineItemGiftMap);        
        for(Order_Line_Item__c orderLineItem : orderLineItemRecordsList)
        {
            orderLineItem.Total_Gift_Price__c = totalGiftPriceMap.get(orderLineItem.Promotion_ID__r.Id);
        }
        
        update orderLineItemRecordsList;
        
        //START: D-1154 1/8/2015 Added by Kristine Campang - added for retrieval of user details from Asia1
        if(ldapId != '' && ldapId != null){
            retrieveUserDetails(ldapid, parentOrder.Recipient_Contact__c, orderLineItemId_packageId_Map, allPackagesIdSet); //START/END 12 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription Activation
        }
        //END: D-1154 1/8/2015 Added by Kristine Campang 
    }
    
    //START 28 October 2015 D-3491 Kevin Evasco - updated to return case record
    //START D-1156 1/13/2015 Added by FrancisBenzon - create case if Vendor is not assigned
    public static Case createCase(Order__c thisOrder, Boolean isWaitingForVendorAssignmentParam) //START/END 23 October 2015 D-3491 D-3760 Kevin Evasco - Added isWaitingForVendorAssignmentParam Param
    {
        //List<Case> caseList = new List<Case>();
        Case thisCase = new Case();
        //try {
            thisCase.Subject = GlobalVariableClass.SUBJECT_START_SUBSCRIPTION; 
            thisCase.RecordTypeID = ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION);
            thisCase.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            thisCase.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_START_SUBCRIPTION;
            thisCase.Status = GlobalVariableClass.STATUS_PENDING;
            
            //START 23 October 2015 D-3491 D-3760 Kevin Evasco - Added isWaitingForVendorAssignmentParam Param
            if(isWaitingForVendorAssignmentParam)
                thisCase.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
            else
                thisCase.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;       
            //END 23 October 2015 D-3491 D-3760 Kevin Evasco - Added isWaitingForVendorAssignmentParam Param                
            
            thisCase.Subscriber__c = thisOrder.Billing_Contact__c;
            thisCase.Recipient_Address__c = thisOrder.Recipient_Contact__r.Address__c;
            thisCase.Recipient__c = thisOrder.Recipient_Contact__c;
            thisCase.AccountId = thisOrder.Account__c;
            thisCase.Origin = thisOrder.Acquisition_Type__c;
            thisCase.Order__c = thisOrder.Id;
            thisCase.Description = thisOrder.Remarks__c;
            if(thisOrder.Parent_Case__c != null || thisOrder.Parent_Case__c != 'null') {
                thisCase.ParentId = thisOrder.Parent_Case__c; 
            }   
            
            //caseList.add(thisCase);
            insert thisCase;
            return thisCase;
        /*}
        catch(exception e) {
            system.debug(e.getMessage());
        } */  
    }   
    //END 28 October 2015 D-3491 Kevin Evasco - updated to return case record
    //END D-1156 1/13/2015 Added by FrancisBenzon - create case if Vendor is not assigned
    
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
    
    private static Map<String,Asia1__c> filterNewLdapIds(Set<String> ldapIds)
    {
        Map<String,Asia1__c> result = new Map<String,Asia1__c>();
        List<Asia1__c> asia1List = [SELECT Id,User_ID_LDAP_ID__c FROM Asia1__c WHERE User_ID_LDAP_ID__c IN: ldapIds];
        
        for(Asia1__c asiaOne : asia1List)
        {
            ldapIds.remove(asia1.User_ID_LDAP_ID__c);
            result.put(asia1.User_ID_LDAP_ID__c, asia1);
        }       
        
        return result;
    }

    //START 12 August 2015 UD-2271 Kevin Evasco - Retrieve Package -> Service Flags Map
    private static Map<Id,Set<Id>> retrieveServiceFlags(Set<Id> packageIdSet) {
        
        Map<Id,Set<Id>> packageAccessFlagMap = new Map<Id,Set<Id>>();
        
        List<Package_Access_Flag__c> packageAccessFlagList = [SELECT Id, Package_Service_Access_Flag__c, Package__r.Id FROM Package_Access_Flag__c WHERE Package__c IN :packageIdSet];
        
        for(Package_Access_Flag__c packageAccessFlag : packageAccessFlagList)
        {
            if(packageAccessFlagMap.get(packageAccessFlag.Package__r.Id) == null)
                packageAccessFlagMap.put(packageAccessFlag.Package__r.Id, new Set<Id>());
            packageAccessFlagMap.get(packageAccessFlag.Package__r.Id).add(packageAccessFlag.Package_Service_Access_Flag__c);
        }
        
        return packageAccessFlagMap;
    }
    //END 12 August 2015 UD-2271 Kevin Evasco - Retrieve Package -> Service Flags Map
   
    
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
    
    // START : D-1176 12/16/2014 Alyana Navarro - Method for validation if field is mandatory.
    public static boolean validateMandatoryFields(NewSubscriptionServiceRequest request)
    {
        boolean result = true;
        
        if(request.order.paymentMethodId == null || request.order.paymentMethodId == '')
        {
            //START: D-1563 01/16/2014 Added by S.Puli Filter for Credit Card payment mode
            if(request.order.paymentMode == 'Credit Card'){
            //END: D-1679 01/16/2014 Added by S.Puli
                result = false;
                //START: D-1563 01/16/2014 Added by S.Puli Filter for Credit Card payment mode
                response.error_message += 'Payment Method ID is mandatory for Credit Card. ';
            } else {
                result = true;
            }
            //END: D-1679 01/16/2014 Added by S.Puli
        }
        //START 04/21/2015 UD-0975 Kevin Evasco - Mandatory Parameters validation
        for(ContactWrapper contactWrapperElement : request.contacts) {          
            if(contactWrapperElement.contactId == null || contactWrapperElement.contactId == ''){           
                if((contactWrapperElement.mobileNumber1 == null || contactWrapperElement.mobileNumber1 == '') && 
                    (contactWrapperElement.mobileNumber1 == null || contactWrapperElement.mobileNumber1 == '')){
                    result = false;
                }
                
                if(contactWrapperElement.emailAddress1 == null || contactWrapperElement.emailAddress1 == ''){
                    result = false;
                }
                if(contactWrapperElement.address.country == GlobalVariableClass.SINGAPORE_CODE){ //START/END: D-3066 06/19/2015 Kevin Evasco: Changed country code from SIN to SG
                    if(contactWrapperElement.address.houseBlockNumber == null || contactWrapperElement.address.houseBlockNumber == ''){
                        result = false;
                    }
                    if(contactWrapperElement.address.levelNumber == null || contactWrapperElement.address.levelNumber == ''){
                        result = false;
                    }
                    if(contactWrapperElement.address.unitNumber == null || contactWrapperElement.address.unitNumber == ''){
                        result = false;
                    }
                    if(contactWrapperElement.address.postalCode == null || contactWrapperElement.address.postalCode == ''){
                        result = false;
                    }
                    if(contactWrapperElement.address.streetName == null || contactWrapperElement.address.streetName == ''){
                        result = false;
                    }               
                }   
            }
        }   

        if(request.order.ldapId == null || request.order.ldapId == '') {
            result = false;
        }       
        
        for(OrderLineItemWrapper orderLineItemWrapperElement : request.order.orderLineItems) {
            if((orderLineItemWrapperElement.contractEndDate == null || orderLineItemWrapperElement.contractEndDate == '') && orderLineItemWrapperElement.promotionCode != null && orderLineItemWrapperElement.promotionCode != '') {
                result = false;
            }
        }   
        
        //START 05/04/2015 CR-005 Kevin Evasco - PayPal CR 
        if(request.order.paymentMode == 'PayPal' && (request.order.billingAccountNumber == null || request.order.billingAccountNumber == '')) {
            if(request.order.paypalbaID == null || request.order.paypalbaID == '')
                result = false;
            if(request.order.paypalemail == null || request.order.paypalemail == '')
                result = false;
        }
        //END 05/04/2015 CR-005 Kevin Evasco - PayPal CR 
        
        if(result == false) {
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_MANDATORY;         
            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_MANDATORY; 
        }
        
        //END 04/21/2015 UD-0975 Kevin Evasco - Mandatory Parameters validation
        
        return result;
    }
    // END : D-1176 12/16/2014
    
    //START 04/21/2015 UD-0975 Kevin Evasco - Mandatory Parameters validation
    //START: D-1679 01/16/2014 Added by S.Puli Filter correct values of payment mode
    public static boolean validateValues(NewSubscriptionServiceRequest request)
    {
        boolean result = true;
        
        if(request.order.paymentMode != 'Check' && request.order.paymentMode != 'Cash' && request.order.paymentMode != 'Credit Card' && request.order.paymentMode != 'Other' && request.order.paymentMode != 'IPP' && request.order.paymentMode != 'Paypal' ){
            result = false;         
            response.debug += 'Payment Mode is invalid. '; 
        }      

        for(OrderLineItemWrapper orderLineItemElement : request.order.orderLineItems) {
            try
            {
                if(convertDate(orderLineItemElement.startDate) <= Date.today()){
                    result = false;
                    response.debug += 'Earliest start date is tomorrow. ';
                }
            }catch(Exception e){
                result = false;
                response.debug += 'Start Date format is invalid. ';
            }
        }
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        
        for(ContactWrapper contactWrapperElement : request.contacts) {   
            if(contactWrapperElement.contactId == null || contactWrapperElement.contactId == ''){
                Matcher emailMatcher = emailPattern.matcher(contactWrapperElement.emailAddress1);
                if(!emailMatcher.matches()) {
                    result = false;                 
                    response.debug += 'Email format is incorrect. '; 
                }
            }
        }
            
        if(AsiaOneServicesController.viewUserDetails(request.order.ldapId).get('User-View') != 'Success'){        
            result = false;
            response.debug += 'Failed to retrieve Asia1 User Details. '; //START/END 12 August 2015 UD-2271 Kevin Evasco - Asia1 Subscription creation. 
        }    
        
        //START 05/04/2015 CR-005 Kevin Evasco - PayPal CR 
        if(request.order.paymentMode == 'PayPal'){
            if(request.order.paymentMethodId == null || request.order.paymentMethodId == ''){
                result = false;             
                response.debug += 'Payment Method was not generated for paypal. '; 
            }
        }
        //END 05/04/2015 CR-005 Kevin Evasco - PayPal CR 
        
        if(result == false) {
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
            response.debug += 'Values not valid. '; 
        }
        //START D-3159 25-June-2015 Added by Raviteja - Validating The Billing Account Billing Type with the Package Billing Type.
         if(result == True && request.order.billingAccountNumber != Null && request.order.billingAccountNumber != '' && request.order.billingAccountNumber.Trim() != ''){
              result = isBillingTypevalid(request.order.billingAccountNumber,request.order.orderLineItems);
              if(result == false) {
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_code = 'EXGN0022';
                response.error_message = 'The Billing Type does not match the Package Billing Type';
                response.debug += 'The Billing Account Billing Type does not match the Package Billing Type. '; 
            }      
        }
        //End D-3159 25-June-2015 Added by Raviteja 
        
        return result;
    }
    //END: D-1679 01/16/2014 Added by S.Puli
    
    //END 04/21/2015 UD-0975 Kevin Evasco - Mandatory Parameters validation
    
    //START 04/21/2015 UD-0975 Kevin Evasco - Mandatory Parameters validation
    //START:D-1851 Added by Joban
    public static boolean checkInvalidCharacters(List<ContactWrapper> contactDetails)
    {            
        boolean checkPassed = true;
        ContactWrapper contact1 = contactDetails.get(0);
        ContactWrapper contact2 = contactDetails.get(1);
        checkPassed =    
        contact1.address.houseBlockNumber.containsNone('~`!@$%^&*()_+={}[]|;<>?') &&
        contact1.address.levelNumber.containsNone('~`!@$%^&*()_+={}[]|;<>?')&&
        contact1.address.unitNumber.containsNone('~`!@$%^&*()_+={}[]|;<>?') &&
        contact1.address.postalCode.containsNone('~`!@$%^&*()_+={}[]|;<>?') &&
        contact1.address.streetName.containsNone('~`!@$%^&*()_+={}[]|;<>?') && 
        contact1.address.country.containsNone('~`!@$%^&*()_+={}[]|;<>?') &&
        contact1.address.singpostAddressType.containsNone('~`!@$%^&*()_+={}[]|;<>?') &&
        contact1.address.Address1.containsNone('~`!@$%^&*()_+={}[]|;<>?') &&
        contact2.address.houseBlockNumber.containsNone('~`!@$%^&*()_+={}[]|;<>?') &&
        contact2.address.levelNumber.containsNone('~`!@$%^&*()_+={}[]|;<>?')&&
        contact2.address.unitNumber.containsNone('~`!@$%^&*()_+={}[]|;<>?') &&
        contact2.address.postalCode.containsNone('~`!@$%^&*()_+={}[]|;<>?') &&
        contact2.address.streetName.containsNone('~`!@$%^&*()_+={}[]|;<>?') && 
        contact2.address.country.containsNone('~`!@$%^&*()_+={}[]|;<>?') &&
        contact2.address.singpostAddressType.containsNone('~`!@$%^&*()_+={}[]|;<>?') ;
        if(contact1.address.postalCode.containsOnly('1234567890') &&
           contact2.address.postalCode.containsOnly('1234567890') &&
           contact1.address.postalCode.length() == 6 && 
           contact2.address.postalCode.length() == 6){
            checkPassed = checkPassed && TRUE;
        }
        if(contact1.address.Address1 != null){
            checkPassed = checkPassed && contact1.address.Address1.containsNone('~`!@$%^&*()_+={}[]|;<>?');
        }
        if(contact1.address.Address2 != null){
            checkPassed = checkPassed && contact1.address.Address2.containsNone('~`!@$%^&*()_+={}[]|;<>?');
        }
        if(contact1.address.Address3 != null){
            checkPassed = checkPassed && contact1.address.Address3.containsNone('~`!@$%^&*()_+={}[]|;<>?');
        }
        if(contact1.address.Address4 != null){
            checkPassed = checkPassed && contact1.address.Address4.containsNone('~`!@$%^&*()_+={}[]|;<>?');
        }
        if(contact2.address.Address1 != null){
            checkPassed = checkPassed && contact2.address.Address1.containsNone('~`!@$%^&*()_+={}[]|;<>?');
        }
        if(contact2.address.Address2 != null){
            checkPassed = checkPassed && contact2.address.Address2.containsNone('~`!@$%^&*()_+={}[]|;<>?');
        }
        if(contact2.address.Address3 != null){
            checkPassed = checkPassed && contact2.address.Address3.containsNone('~`!@$%^&*()_+={}[]|;<>?');
        }
        if(contact2.address.Address4 != null){
            checkPassed = checkPassed && contact2.address.Address4.containsNone('~`!@$%^&*()_+={}[]|;<>?');
        }
        
        if(checkPassed == false)
        {
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
            response.debug += 'Invalid character/s used. '; 
        }
        
        return checkPassed;         
    }
    //END 04/21/2015 UD-0975 Kevin Evasco - Mandatory Parameters validation
    public static Boolean validateSimilarSubscriptions(String subscriptionIdParam, String accountNumberParam, Set<String> productFamiliesParam, String countryCodeParam, String postalCodeParam, String levelNumberParam, String unitNumberParam)
    {
        Boolean isValid = true;
        List<Zuora__Subscription__c> subscriptionList = [SELECT Id FROM Zuora__Subscription__c WHERE 
            Zuora__External_Id__c != :subscriptionIdParam AND
            Zuora__Status__c = 'Active' AND
            Subscription_Type_1__c = 'Publication' AND
            Main_Package_1__r.Product_Family_Current_Package__c IN :productFamiliesParam AND
            Recipient_Contact__r.Address__r.Country__r.Code__c = :countryCodeParam AND
            Recipient_Contact__r.Address__r.Postal_Code__r.Name = :postalCodeParam AND 
            Recipient_Contact__r.Address__r.Unit_Number__c = :unitNumberParam AND 
            Recipient_Contact__r.Address__r.Level_Number__c = :levelNumberParam LIMIT 1]; //START/END 04/16/2015 UD-0934 Kevin Evasco - Used Zuora External Id instead of Zuora Id
        if(subscriptionList.size() > 0)
            isValid = false;                
            
        return isValid;
    }
    
    //END: D-1851 Added by Joban
    //START 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
    public static boolean createPaypal(NewSubscriptionServiceRequest request, String billingType){
        Boolean isSuccessful = true;
        
        PaypalHelper.BillingAccountWrapper billingAccountZInstance = new PaypalHelper.BillingAccountWrapper();
        billingAccountZInstance.name = billingContactWrapper.firstName + billingContactWrapper.lastName;
        billingAccountZInstance.batch = 'Batch19';
        billingAccountZInstance.billCycleday = 1;
        billingAccountZInstance.billingType = billingType;
        
        String newBillingAccountZID = PaypalHelper.createBillingAccount(billingAccountZInstance);       
        paypalBillingAccountZID = newBillingAccountZID; //START/END 03 February 2016 UD-3844 Kevin Evasco - Paypal Rollback
        
        PaypalHelper.BillingContactWrapper billingContactZInstance = new PaypalHelper.BillingContactWrapper();
        billingContactZInstance.accountId = newBillingAccountZID;
        billingContactZInstance.firstName = billingContactWrapper.firstName;
        billingContactZInstance.lastName = billingContactWrapper.lastName;      
        
        //START 08 July 2015 D-3232 Kevin Evasco - Hotfix
        if(billingContactWrapper.contactId ==  null || billingContactWrapper.contactId == '') {
            Country__c countryRecord = getCountry(billingContactWrapper.address.country);      
            if(countryRecord != null)
                billingContactZInstance.country = countryRecord.Country_Name__c;
            else
                billingContactZInstance.country = 'Singapore';
        } else {            
            billingContactZInstance.country = contactMap.get(billingContactWrapper.contactId).Address__r.Country__r.Country_Name__c;
        }
        //END 08 July 2015 D-3232 Kevin Evasco - Hotfix
        
        
        String newBillingContactZID = PaypalHelper.createBillingContact(billingContactZInstance);
        
        //START 05 January 2015 D-4111 Kevin Evasco - Set Billing Account default payment method
        //PaypalHelper.updateBillingAccount(newBillingAccountZID,newBillingContactZID);
        
        String newPaymentMethodZID = PaypalHelper.createPaymentMethodId(request.order.paypalbaID,request.order.paypalemail,newBillingAccountZID);       
        
        PaypalHelper.updateBillingAccount(newBillingAccountZID,newBillingContactZID, newPaymentMethodZID);
        //END 05 January 2015 D-4111 Kevin Evasco - Set Billing Account default payment method
        
        if(newBillingAccountZID != null)
            billingAccountZID = newBillingAccountZID;
        else
            isSuccessful = false;
        
        if(newPaymentMethodZID != null )
            request.order.paymentMethodId = newPaymentMethodZID; //START/END 05/04/2015 CR-005 Kevin Evasco - PayPal CR 
        else
            isSuccessful = true;
        
        return isSuccessful;             
    }
    
    public static Zuora__CustomerAccount__c getPayPalBillingAccount(NewSubscriptionServiceRequest request, String billingType){
        Zuora__CustomerAccount__c payPalBillingAccount;
        try{
        payPalBillingAccount = [SELECT Id, Billing_Contact__r.Id, Billing_Contact__r.Email__c, Billing_Contact__r.Name, Zuora__Credit_Balance__c, Zuora__PaymentMethod_Type__c, Zuora__Account__c, Zuora__External_Id__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c
                                FROM Zuora__CustomerAccount__c 
                                WHERE Zuora__AccountNumber__c = :request.order.billingAccountNumber /* AND Billing_Type__c = :billingType AND Zuora__Default_Payment_Method__r.Zuora__PaypalBaid__c = :request.order.paypalbaID AND Zuora__Default_Payment_Method__r.Zuora__PaypalEmail__c = :request.order.paypalemail*/ LIMIT 1];
            billingAccountZID = payPalBillingAccount.Zuora__External_Id__c;
            request.order.paymentMethodId = payPalBillingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c;
        }catch(Exception e){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
            response.debug += 'Billing Account does not exist. '; 
        }
                                    
        return payPalBillingAccount;
    }
    
    //START D-3159 25-June-2015 Added by Raviteja - Validating The Billing Account Billing Type with the Package Billing Type.
    public static Boolean isBillingTypevalid(String billingAccountNumber, List<OrderLineItemWrapper> lstorderLineItemWrapper){
        Boolean isValid = True;
        String baBillingType = '';
        Set<String> packageCodeSet = new Set<String>();
        List<Zuora__CustomerAccount__c> billingAccountList = New List<Zuora__CustomerAccount__c>();
                
        billingAccountList = [SELECT Id, Billing_Type__c FROM Zuora__CustomerAccount__c 
                                    WHERE Zuora__AccountNumber__c = :billingAccountNumber AND Billing_Type__c != Null LIMIT 1];
      if(!billingAccountList.isEmpty()){
              baBillingType = billingAccountList[0].Billing_Type__c;
              for(OrderLineItemWrapper orderLineItemWrapperElement : lstorderLineItemWrapper) {
                if(orderLineItemWrapperElement.packagecode != null && orderLineItemWrapperElement.packagecode != '' && !String.isBlank(orderLineItemWrapperElement.packagecode) && orderLineItemWrapperElement.packagecode.Trim() != '') {
                    packageCodeSet.add(orderLineItemWrapperElement.packagecode);
                }
            }             
            for(Package__c packageparam :[SELECT Id, Billing_Type__c,Package_Code__c  FROM Package__c WHERE Package_Code__c IN :packageCodeSet AND Billing_Type__c != Null]){
                String pkBillingType = packageparam.Billing_Type__c;
                if(isValid == True){                         
                          if(pkBillingType != baBillingType){                     
                                 isValid = False;
                                 break;                     
                         }             
                    }else{   
                        isValid = False;
                        break;
                        }     
                  }
      }else{
          isValid = False;     
          }  
                                 
      return isValid;
    }
    //End D-3159 25-June-2015 Added by Raviteja 
    
    public static String getBillingType(NewSubscriptionServiceRequest request) {
        String packageBillingType;
        
        try{
            Package__c packageRecord = [SELECT Billing_Type__c FROM Package__c WHERE Package_Code__c = :request.order.orderLineItems[0].packageCode LIMIT 1];
            packageBillingType = packageRecord.Billing_Type__c;                 
        }catch(Exception e) { 
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
            response.debug += 'Package does not exist. '; 
        }
        
        return packageBillingType;
    }
    
    public static String getBABillingType(String billingTypeParam) {
        String baBillingType;        
        //START D-3159 25-June-2015 Added by Raviteja - Implementing New Billing Type concept for Billing Account type
        baBillingType = billingTypeParam;
        //End D-3159 25-June-2015 Added by Raviteja 
        return baBillingType;
    }
    //END 04/22/15 D-2743 Kevin Evasco - New Quote Creation Implementation + Paypal 
    
    //START 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion
    public static List<Subscription_Vendor__c> getVendorSubscriptions(ContactWrapper recipientContactParam, String productFamily) {
        
        List<Subscription_Vendor__c> vendorSubscriptionsResult = new List<Subscription_Vendor__c>();
        
        String postalCodeFilter;
        String levelNumberFilter;
        String unitNumberFilter;
        String countryCodeFilter;
        
        if(recipientContactParam.contactId != null && recipientContactParam.contactId != ''){
            Contact recipientContact = contactMap.get(recipientContactParam.contactId);
            postalCodeFilter = recipientContact.Address__r.Postal_Code__r.Name;
            levelNumberFilter = recipientContact.Address__r.Level_Number__c;
            unitNumberFilter = recipientContact.Address__r.Unit_Number__c;  
            countryCodeFilter = recipientContact.Address__r.Country__r.Code__c;
        } else {                
            postalCodeFilter = recipientContactParam.address.postalCode;
            levelNumberFilter = recipientContactParam.address.levelNumber;
            unitNumberFilter = recipientContactParam.address.unitNumber;    
            countryCodeFilter = recipientContactParam.address.country;              
        }
        
        if(countryCodeFilter == GlobalVariableClass.SINGAPORE_CODE) //START/END: D-3066 06/19/2015 Kevin Evasco: Changed country code from SIN to SG
        {   
            List<Subscription_Vendor__c> vendorSubscriptionsTempList = [SELECT Id, Account__c, Subscription_Stop_Date__c FROM Subscription_Vendor__c WHERE 
                                        Recipient__r.Address__r.Country__r.Code__c = :countryCodeFilter AND 
                                        Recipient__r.Address__r.Postal_Code__r.Name = :postalCodeFilter AND 
                                        Recipient__r.Address__r.Level_Number__c = :levelNumberFilter AND 
                                        Recipient__r.Address__r.Unit_Number__c = :unitNumberFilter];
            
            Set<Id> vendorSubscriptionIds = new Set<Id>();
            for(Subscription_Vendor__c vendorSubscriptionElement : vendorSubscriptionsTempList) {
                vendorSubscriptionIds.add(vendorSubscriptionElement.Id);
            }
            
            List<Subscription_Vendor_Publication__c> vendorSubscriptionPublicationList = [SELECT Id, Subscription_Vendor__r.Id FROM Subscription_Vendor_Publication__c WHERE Subscription_Vendor__r.Id IN :vendorSubscriptionIds AND Publication__r.Product_Family__c = :productFamily];
            
            Set<Id> vendorSubPubIdSet = new Set<Id>();
            for(Subscription_Vendor_Publication__c vendorSubscriptionPublicationElem : vendorSubscriptionPublicationList) {
                vendorSubPubIdSet.add(vendorSubscriptionPublicationElem.Subscription_Vendor__r.Id);
            }
            
            for(Subscription_Vendor__c vendorSubscriptionElement : vendorSubscriptionsTempList) {
                if(vendorSubPubIdSet.contains(vendorSubscriptionElement.Id)) {
                    vendorSubscriptionsResult.add(vendorSubscriptionElement);
                }
            }
            
        }
        
        return vendorSubscriptionsResult;
    }
    //END 29 July 2015 UD-1907 Kevin Evasco - Vendor Conversion
    
    //START 03 February 2016 UD-3844 Kevin Evasco - Rollback Zuora records
    @future(Callout=true)
    public static void rollBackZuoraRecords(String newBillingAccountZIDParam){
        List<String> accountIdList = new List<String>();
        accountIdList.add(newBillingAccountZIDParam);
        
        Zuora.zapi zApiInstance = new Zuora.zapi();
        List<Zuora.zApi.DeleteResult> deleteResults = zApiInstance.zdelete('Account',accountIdList);
    }
    //END 03 February 2016 UD-3844 Kevin Evasco - Rollback Zuora records
}

/* Sample Request Parameter:

    {
    "request" : 
    {
        "subscriberAccount" :
        {
            "accountNumber" : "30000461",
            "accountName" : "Vin Account Test 2",
            "recordType" : "Direct Corporate"
        },
        "contacts" :
        [
            {
                "salutation" : "Mr.",
                "firstName" : "Kevin",
                "lastName" : "Evasco",
                "nric" : "T5275174A",
                "passport" : "2",
                "billingIndicator" : "N",
                "recipientIndicator" : "Y",
                "homeNumber" : "5",
                "mobileNumber1" : "6",
                "emailAddress1" : "kevin.h.evasco@accenture.com",
                "address" : 
                {
                    "houseBlockNumber" : "1",
                    "levelNumber" : "27",
                    "unitNumber" : "98",
                    "postalCode" : "680224",
                    "streetName" : "5",
                    "buildingName" : "6",
                    "country" : "SIN",                  
                    "singpostAddressType" : "P",
                    "Address1" : "ADDRESS 1",
                    "Address2" : "ADDRESS 2",
                    "Address3" : "ADDRESS 3",
                    "Address4" : "ADDRESS 4"
                }        
            },
            {
                "salutation" : "Mr.",
                "firstName" : "Kevin",
                "lastName" : "Evasco",
                "nric" : "T5275174B",
                "passport" : "2",
                "billingIndicator" : "Y",
                "recipientIndicator" : "N",
                "homeNumber" : "5",
                "mobileNumber1" : "6",
                "emailAddress1" : "kevin.h.evasco@accenture.com",
                "address" : 
                {
                    "houseBlockNumber" : "1",
                    "levelNumber" : "27",
                    "unitNumber" : "98",
                    "postalCode" : "a02N0000003aNsW",
                    "streetName" : "5",
                    "buildingName" : "6",
                    "country" : "Singapore",                  
                    "singpostAddressType" : "P",
                    "Address1" : "ADDRESS 1",
                    "Address2" : "ADDRESS 2",
                    "Address3" : "ADDRESS 3",
                    "Address4" : "ADDRESS 4"
                }        
            }
        ],
        "order" :
        {
            "billingAccountNumber" : "2c92c0f848820882014887b31bd91ed7",
            "paymentMode" : "Credit Card",
            "paymentMethodId" : "1",
            "ldapId" : "2222222217",   
            "ReferenceId" : "",
            "orderLineItems" :
            [
                {
                    "promotioncode" : "STAIOFPNK",
                    "packagecode" : "STAIONK",                    
                    "addonpackagecode" : "1312",
                    "quantity" : 16,
                    "startDate" : "09/30/2014",   
                    "giftcode" : ["TTG", "NGP"],
                    "contractenddate" : "09/30/2015"    
                }
            ]
        }    
    }
}

Sample Test in Workbench: /services/apexrest/NewSubscriptionService/data/v29.0

*/