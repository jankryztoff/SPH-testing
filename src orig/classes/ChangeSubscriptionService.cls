/*
 * Class Name: ChangeSubscriptionService
 * @author: Kevin H. Evasco
 * Date: 09/06/2014
 * Project/Requirement: ESHOP Change of Subscription
 * 
 * History: 10/22/2014 Kevin Evasco Created Apex Webservice
 * History: 01/27/2014 D-1654 Kevin Evasco Updated to include case creation
 * History: 01/27/2014 D-2224 Kevin Evasco Updated reference CancelSubscriptionBatch
 * History: D-2534 03/19/2015 Kevin Evasco Create Order for Stop Subscription, utilize Subscription Cancellation Helper
 * History: 05/22/15 D-3022 Kevin Evasco - UAT Hotfix. Major code change to fix glitches and work flows.
 */

@RestResource(urlMapping='/ChangeSubscriptionService/*')                        
global with sharing class ChangeSubscriptionService 
{
    private static ChangeSubscriptionServiceResponse response = new ChangeSubscriptionServiceResponse();    
    private static ContactWrapper recipientContactWrapper;
    private static ContactWrapper billingContactWrapper;
    private static Contact recipientContact;
    private static Contact billingContact;
    private static String billingAccountCreationMode;
    private static Boolean sameContactForBillingAndDelivery;
    
    //START 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
    public static String billingAccountZID;
    public static Map<String,String> paypalResultMap = new Map<String,String>();
    public static Boolean isPaypal = false;
    //END 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR   
    
    //START 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - COS Order Types
    public static final string COS_PACKAGE = 'Change of Subscription Package';
    public static final string COS_QUANTITY = 'Change of Subscription Quantity';
    //END 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - COS Order Types   
        
    global class ChangeSubscriptionServiceResponse
    {
        String svc_status;
        String error_code;
        String error_message = '';
        String orderid;
        String debug = '';
    }
    
    global class ChangeSubscriptionServiceRequest 
    {
        SubscriptionWrapper subscription;
        List<ContactWrapper> contacts;
        OrderLineItemWrapper orderLineItem;
    }
    
    global class SubscriptionWrapper 
    {
        String subscriptionId;
        String accountNumber;
        String accountRecordType;
        String billingAccountId;
        String recipientId;     
        String orderType;
        String creationMode;
        //START 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
        String paypalBAID;
        String paypalEmail;
        //END 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
    }
    
    global class ContactWrapper 
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
    
    global class AddressWrapper 
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
    
    global class OrderLineItemWrapper 
    {        
        public String promotioncode;
        public String packagecode;
        public String addonpackagecode;
        public String ldapId;
        public Integer quantity;
        public String startDate;
        public List<String> giftCode;
        public String contractenddate;

    }
    
    @HttpPost
    global static ChangeSubscriptionServiceResponse processRequest(ChangeSubscriptionServiceRequest request) 
    {
        Zuora__Subscription__c subscription;
        Promotion__c promotion;
        List<Gift__c> giftList;
        Package__c packageRecord;       
        String renewalPackageCode;
            
        response.svc_status = GlobalVariableClass.SVC_STATUS_SUCCESS;
        
        //Savepoint savepointBeforeDML = Database.setSavepoint();  //START/END 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
        initializeContactWrapperInstances(request.contacts);   
        Boolean isValid = validateMandatoryFields(request);
        Boolean isPromoNotFound = false;
        
        if(request.subscription.recipientId != null && request.subscription.recipientId != ''){
            system.debug('>>>>acnt.Account_Auto_Number__c: ' + request.subscription.accountNumber);
            recipientContact = getContact(request.subscription.recipientId, request.subscription.accountNumber);
            if(recipientContact == null){           
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
                isValid = false;                    
            }
        }   
        
        if(isValid == true)
        {
            subscription = getSubscription(request.subscription.subscriptionId, request.subscription.accountNumber);
            if(request.orderLineItem.promotioncode != null && request.orderLineItem.promotioncode != ''){
                promotion = getPromotion(request.orderLineItem.promotioncode);
                if(promotion == null)
                    isPromoNotFound = true;
            }
            giftList = getGifts(request.orderLineItem.giftCode);
            packageRecord = getPackage(request.orderLineItem.packagecode);
            
           /* ------------- START 21 July 2015 D-3259 Kevin Evasco - Fixed null pointer exception issue.
            System.debug('subscription : '+subscription);    
            System.debug('isPromoNotFound : '+isPromoNotFound);
            System.debug('packageRecord : '+packageRecord);
            System.debug('subscription.Main_Package_1__r.Product_Family_Current_Package__c : '+subscription.Main_Package_1__r.Product_Family_Current_Package__c);
            System.debug('packageRecord.Product_Family_Current_Package__c : '+packageRecord.Product_Family_Current_Package__c);
          ------------- END 21 July 2015 D-3259 Kevin Evasco - Fixed null pointer exception issue. */
            
            if(subscription == null || isPromoNotFound == true || packageRecord == null ||subscription.Main_Package_1__r.Product_Family_Current_Package__c != packageRecord.Product_Family_Current_Package__c){
                isValid = false;            
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
            }
            
            if(request.orderLineItem.giftCode != null) {
                if(request.orderLineItem.giftCode.size() > 0 && request.orderLineItem.giftCode.size() == 0) {
                    isValid = false;            
                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                    response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                    response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
                }
            }
        }
        
        if(request.orderLineItem.promotioncode != null && request.orderLineItem.promotioncode != '' && request.orderLineItem.promotioncode != 'null'){
            Integer monthsBet = NewSubscriptionService.convertDate(request.orderLineItem.startDate).monthsBetween(NewSubscriptionService.convertDate(request.orderLineItem.contractenddate));
            PackageEligibilityCheck.PackageEligibilityCheckRequest packageEligibilityCheckRequest = new PackageEligibilityCheck.PackageEligibilityCheckRequest();
            
            packageEligibilityCheckRequest.Packageid = request.orderLineItem.packagecode ;
            packageEligibilityCheckRequest.Promotionid = request.orderLineItem.promotioncode;
            packageEligibilityCheckRequest.Action = 'CAN CHANGE';//KRITHIKA DHARMARAJAN changed action as CAN ADD
            packageEligibilityCheckRequest.SubscriptionId = request.subscription.subscriptionId;
            packageEligibilityCheckRequest.subscriberid = request.subscription.accountNumber;
            packageEligibilityCheckRequest.contractPeriod = String.valueOf(monthsBet);
            
            packageEligibilityCheckRequest.vendorConversion = 'N';
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
        
        //START 17 December 2015 D-4113 Kevin Evasco - Future COA on Recipient Contact / Pending TSOP Validation
        if(isValid){
            String errorMessage = SM_SubscriptionHelper.validateFutureDatedCOA(subscription.Recipient_Contact__c,NewSubscriptionService.convertDate(request.orderLineItem.startDate),GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION);
            if(errorMessage != null) {
                isValid = false;            
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                response.error_message = errorMessage;   
                response.debug += errorMessage; 
            }
        }               
        
        if(isValid){        
            String errorMessage = SM_SubscriptionHelper.checkTStopRestartDates(subscription.Id,NewSubscriptionService.convertDate(request.orderLineItem.startDate),GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION);
            if(errorMessage != null) {
                isValid = false;            
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                response.error_message = errorMessage;   
                response.debug += errorMessage; 
            }
        }
        //END 17 December 2015 D-4113 Kevin Evasco - Future COA on Recipient Contact / Pending TSOP Validation
        
        //START 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
        if(isValid && request.subscription.paypalBAID != null && request.subscription.paypalBAID != '') {
            isPaypal = true;
            
            PaypalHelper.BillingInformationWrapper billingInformation = new PaypalHelper.BillingInformationWrapper();
            billingInformation.paypalBAID = request.subscription.paypalBAID;
            billingInformation.paypalEmail = request.subscription.paypalEmail;
            billingInformation.firstName = subscription.Contact__r.firstName;
            billingInformation.lastName = subscription.Contact__r.lastName;
            billingInformation.country = subscription.Contact__r.Address__r.Country_Name__c;
            billingInformation.billingType = subscription.Zuora__CustomerAccount__r.Billing_Type__c;
            
            try{
            paypalResultMap = PaypalHelper.createPaypal(billingInformation);
            } catch(Exception e) {
                isValid = false;
            }
            
            if(paypalResultMap.get(PaypalHelper.KEY_STATUS) != PaypalHelper.VALUE_SUCCESSFUL)
                isValid = false;
                
            if(isValid == false){
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;   
                response.debug += 'Paypal Billing Account Creation failed. ';            
            }
        }
        Savepoint savepointBeforeDML = Database.setSavepoint();   
        //END 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
        
        if(isValid == true)
        {
        try
        {
            Boolean proceed = true;                     
            
            Account accountRecord;
            Zuora__CustomerAccount__c billingAccountRecord;
            
            if(request.subscription.accountNumber != null && request.subscription.accountNumber != '')
            {
                accountRecord = getAccount(request.subscription.accountNumber);
                if(accountRecord == null)
                {
                    proceed = false;                    
                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                    response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                    response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
                }
            }
            else
            {
                accountRecord = createAccount(request.subscription.accountRecordType);
            }
            
            if(proceed == true)
            {
                if(sameContactForBillingAndDelivery == true)
                {                   
                    Contact contactRecord = createContact(recipientContactWrapper, accountRecord.Id, 'Recipient and Billing Contact');
                    recipientContact = contactRecord;
                    billingContact = contactRecord;
                }
                
                if((request.subscription.billingAccountId == null || request.subscription.billingAccountId == '') && isPaypal == false) //START/END 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
                {
                    Contact contactRecord = createContact(billingContactWrapper, accountRecord.Id, 'Billing Contact');
                    billingContact = contactRecord;
                }           
                
                if(request.subscription.recipientId == null || request.subscription.recipientId == '')
                {
                    Contact contactRecord = createContact(recipientContactWrapper, accountRecord.Id, 'Recipient Contact');
                    recipientContact = contactRecord;
                }
            }
            
            if(proceed == true)
            {
                if(request.subscription.billingAccountId != null && request.subscription.billingAccountId != '')
                {
                    billingAccountRecord = getBillingAccount(request.subscription.billingAccountId);
                    if(billingAccountRecord == null)
                    {   
                        //START D-3159 29-June-2015 Added by Raviteja - Assigning Proceed value as false before shoing error
                        proceed = false;
                        //End D-3159 29-June-2015 Added by Raviteja 
                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                        response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                        response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
                    }
                    
                    //START D-3159 29-June-2015 Added by Raviteja - Validating The Billing Account Billing Type with the Package Billing Type.
                    else{
                      proceed = isBillingTypevalid(billingAccountRecord.Billing_Type__c,request.orderLineItem.packagecode);
                      if(proceed == false) {
                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                        response.error_code = 'EXES0005';
                        response.error_message = 'The Billing Type does not match the Package Billing Type';
                        response.debug += 'The Billing Account Billing Type does not match the Package Billing Type. '; 
                        }      
                    }
                    //End D-3159 29-June-2015 Added by Raviteja 
                }
            }           
            
            if(proceed == true)
            {
                Set<String> zAccountIdSet = new Set<String>();
                zAccountIdSet.add(subscription.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c);   
                
                //START 21 October 2015 D-3377/D-3376 Kevin Evasco - Retain Vendor Mailing Agent Assignment
                Id vendorMailingAgentId;
                List<Order_Line_Item__c> orderLineItemWithVendor = [SELECT Id, Vendor_Mailing_Agent__c FROM Order_Line_Item__c WHERE Order__c = :subscription.Order_Number__c AND Vendor_Mailing_Agent__c != null LIMIT 1];
                if(!orderLineItemWithVendor.isEmpty()){
                    vendorMailingAgentId = orderLineItemWithVendor.get(0).Vendor_Mailing_Agent__c;
                }
                //END 21 October 2015 D-3377/D-3376 Kevin Evasco - Retain Vendor Mailing Agent Assignment
                
                Order__c oldOrder = getOrder(subscription.Order_Number__c);
                Order__c newOrder = (Order__c)SObjectAllFieldCloner.cloneObject(oldOrder,oldOrder.getsObjectType());                
                newOrder.Order_Legacy_Id__c  = null;
                newOrder.Account__c = accountRecord.Id;
                
                //START 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - New Order Field Assignments
                newOrder.Subscription__c = subscription.Id;
                newOrder.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
                
                
                if(request.orderLineItem.promotioncode != subscription.Promotion_1__r.Promotion_Code__c ||
                    (request.orderLineItem.promotioncode ==  '' && subscription.Promotion_1__r.Promotion_Code__c == null) ||
                    request.orderLineItem.packagecode != subscription.Main_Package_1__r.Package_Code__c){
                    newOrder.Order_Type__c = COS_PACKAGE;
                }else{
                    newOrder.Order_Type__c = COS_QUANTITY;
                }

                newOrder.Order_Type1__c = 'Change of Subscription';
                //END 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - New Order Field Assignments   
        
                //START 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
                if(isPaypal) {
                    newOrder.Billing_Account_Creation_Mode__c = 'Use created Billing Account';
                    newOrder.Billing_Account__c = null;
                    newOrder.Payment_Method_ID__c = paypalResultMap.get(PaypalHelper.KEY_PAYMENT_METHOD_ZID);
                    newOrder.Payment_Mode__c = 'PayPal';
                    
                } else {
                    if(request.subscription.billingAccountId == null || request.subscription.billingAccountId == '') { //START/END 21 July 2015 D-3259 Kevin Evasco - Fixed null pointer exception issue.
                        newOrder.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
                        newOrder.Billing_Contact__c = billingContact.Id;
                        newOrder.Credit_Balance__c = 0;
                    }       
                    else
                    {                   
                        newOrder.Billing_Account__c = billingAccountRecord.Id;
                        newOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';  
                        newOrder.Billing_Contact__c = billingAccountRecord.Billing_Contact__r.Id;          
                        
                        newOrder.Credit_Balance__c = 0;          
                        if(billingAccountRecord.Zuora__Credit_Balance__c != null)
                        {
                            newOrder.Credit_Balance__c = billingAccountRecord.Zuora__Credit_Balance__c;
                        }
                    }                   
                    
                    if(billingAccountRecord.Zuora__Default_Payment_Method__r.Zuora__External_Id__c != null)
                        newOrder.Payment_Method_ID__c = billingAccountRecord.Zuora__Default_Payment_Method__r.Zuora__External_Id__c;
                }
                //START D-3159 29-June-2015 Added by Raviteja - Updating the order billing type value from Package billing type. 
                newOrder.Billing_Type__c = packageRecord.Billing_Type__c;
                //END D-3159 29-June-2015 Added by Raviteja     
                //END 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
                    
                insert newOrder; 
                newOrder = [SELECT Id, Recipient_Contact__r.Address__r.Postal_Code__c, Account__r.Account_Auto_Number__c,
                        Billing_Contact__c, Recipient_Contact__r.Address__c, Recipient_Contact__c, Delivery_Charge__c, Vendor_Credit__c, //START/END 12 October 2015 UD-3082 Kevin Evasco - Added Delivery Charge and Vendor Credit
                        Account__c, Acquisition_Type__c, Remarks__c, Parent_Case__c, Billing_Account_Creation_Mode__c, Billing_Account__c, FP_Del_Usage__c, Subscriber_Charge__c, Payment_Mode__c, Other_Payment_Mode__c, Delivery_Charge_Type__c, Payment_Method_ID__c, Billing_Type__c, Billing_Account__r.Zuora__External_Id__c
                        FROM Order__c 
                        WHERE Id = :newOrder.Id];
                
                NewSubscriptionService.OrderLineItemWrapper orderLineItem = new NewSubscriptionService.OrderLineItemWrapper();
                orderLineItem.promotioncode = request.orderLineItem.promotioncode;
                orderLineItem.packagecode = request.orderLineItem.packagecode;
                orderLineItem.addonpackagecode = request.orderLineItem.addonpackagecode;
                orderLineItem.quantity = request.orderLineItem.quantity;
                orderLineItem.startDate = request.orderLineItem.startDate;
                orderLineItem.giftCode = request.orderLineItem.giftCode;
                orderLineItem.contractenddate = request.orderLineItem.contractenddate;
                
                List<NewSubscriptionService.OrderLineItemWrapper> orderLineItemList = new List<NewSubscriptionService.OrderLineItemWrapper>();
                orderLineItemList.add(orderLineItem);
                //START D-0821 1/14/2015 Added By C. Lin - Add missing parameter
                //START: D-1668 01/22/2015 Added by P.Villarica - Added missing parameter
                NewSubscriptionService.createOrderLineItems(orderLineItemList,newOrder,request.orderLineItem.ldapId, recipientContact, vendorMailingAgentId); //START/END 20 October 2015 D-3377 and D-3376 Kevin Evasco - Retain Vendor Mailing Agent assignment
                //END: D-1668 01/22/2015 Added by P.Villarica
                //END D-0821 1/14/2015 Added By C. Lin              
                
                Subscription_Handler sh = new Subscription_Handler();
                sh.origin = 'ESHOP Change of Subscription'; //START/END 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - Changed Origin to ESHOP Change of Subscription
                //START 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
                if(isPaypal) {
                    sh.zBillingAccountId = paypalResultMap.get(PaypalHelper.KEY_BILLING_ACCOUNT_ZID);
                }
                //END 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
                sh.Subscription_Handler_Direct(newOrder);                
                
                //START D-1654 01/27/2014 Kevin Evasco Updated to include case creation
                //START 04/16/2015 UD-0934 Kevin Evasco - Return order name instead of order id.
                newOrder = [SELECT Id, Name, Recipient_Contact__r.Id, Reason_Code__c, Remarks__c, Creation_Mode__c, Order_Action__c, Admin_Charge__c, Request_for_Waiving_of_Admin_Charge__c, Effective_Date__c, Subscription__c, Acquisition_Type__c, Recipient_Contact__c, Recipient_Contact__r.Address__c, Billing_Contact__c, Account__c, No_Vendor_Needed__c  FROM Order__C WHERE Id = :newOrder.Id]; //START/END D-2534 03/19/2015 Kevin Evasco Create Order for Stop Subscription, utilize Subscription Cancellation Helper
                
                response.orderid = newOrder.Name; 
                //START 04/16/2015 UD-0934 Kevin Evasco - Return order name instead of order id.
                
                //START 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - Removed case creation from this class. Case creation is done in Subscription_Handler
                /*
                List<Order__c> orderList = new List<Order__c>();
                orderList.add(newOrder);
                createCase caseCreator = new createCase();
                caseCreator.createCaseForChangeOfSubscription(orderList,true);
                */
                //END 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - Removed case creation from this class. Case creation is done in Subscription_Handler
                //END D-1654 01/27/2014 Kevin Evasco Updated to include case creation
                
                //START D-2224 02/23/2015 Kevin Evasco: Updated reference CancelSubscriptionBatch
                Set<String> orderIdSet = new Set<String>();
                Set<String> subscriptionIdSet = new Set<String>();
                
                orderIdSet.add(oldOrder.Id);
                subscriptionIdSet.add(request.subscription.subscriptionId);
                
                //START 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - Urgent Invoicing Logic
                List<Order_Line_Item__c> newOrderLineItemList = getNewOrderLineItems(newOrder);
                updateSubscriptionEndDate(subscription, newOrderLineItemList); //START/END 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - Update Subscription End Date
                
                if(!newOrderLineItemList.isEmpty()){
                    Order_Line_Item__c newOrderLineItem = newOrderLineItemList.get(0);
                
                    if((newOrderLineItem.Order__r.Subscription__r.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE && newOrderLineItem.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE) || (newOrderLineItem.Order__r.Subscription__r.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE && newOrderLineItem.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE) || (newOrderLineItem.Order__r.Subscription__r.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE && newOrderLineItem.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE && newOrderLineItem.Start_Date__c.toStartOfMonth() == Date.today().toStartOfMonth())) {
                        CancelSubscriptionBatch cancelSubscriptionBatch = new CancelSubscriptionBatch(orderIdSet,subscriptionIdSet, NewSubscriptionService.convertDate(request.orderLineItem.startDate), zAccountIdSet, subscription.Zuora__Account__r.Id);             
                        //END D-2224 02/23/2015 Kevin Evasco: Updated reference CancelSubscriptionBatch
                        Database.executeBatch(cancelSubscriptionBatch);
                    }
                }
                //END 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - Urgent Invoicing Logic
                     
            }
            
            
            if(proceed == false)
            {           
                Database.rollback(savepointBeforeDML);
            }           
        }
        catch(Exception e)
        {        
            Database.rollback(savepointBeforeDML);
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_GENERIC;
            response.error_message = GlobalVariableClass.GENERICERROR;
            /*
            if(e.getTypeName().contains('DMLException'))
            {                
                //response.error_code = 'EXES0001';
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_MANDATORY;
                //response.error_message = 'Mandatory validation failed. ';
                response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_MANDATORY;
            }
            else if(e.getTypeName().contains('TypeException'))
            {            
                //response.error_code = 'EXES0004';
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                //response.error_message = 'Invalid input. Backend validation failed. ';
                response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
            }
            */
            response.debug += 'Type: ' + e.getTypeName() + ' ';
            response.debug += 'Message: ' + e.getMessage() + ' ';
            response.debug += 'Stack Trace: ' + e.getStackTraceString();
        }
        }
        
        return response;
    }
    
    private static void initializeContactWrapperInstances(List<ContactWrapper> contactDetails)
    {     
        if(contactDetails != null)      
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
                    sameContactForBillingAndDelivery = true;
                }
            }
        }
    }
    
    public static Zuora__Subscription__c getSubscription(String subscriptionId, String accountNumberParam)
    {   
        Zuora__Subscription__c subscription;
        
        //START 17 December 2015 D-4113 Kevin Evasco - Added Recipient_Contact__c
        //START 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - Added Promotion_1__r.Promotion_Code__c
          //START/END D-3828 30-Oct-2015 Added by Raviteja  - Added Order_Line_Item_Number_1__c in SOQL
        List<Zuora__Subscription__c> subscriptionList = 
            [SELECT Id, Order_Number__c, Order_Line_Item_Number__c, Zuora__CustomerAccount__r.Id, Order_Line_Item_Number_1__c, 
            Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Zuora__Account__r.Id, Main_Package_1__r.Effective_End_Date__c,
            Main_Package_1__r.Product_Family_Current_Package__c, Main_Package_1__r.Package_Code__c, 
            Zuora__Account__r.Account_Auto_Number__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Address__r.Country_Name__c, 
            Zuora__CustomerAccount__r.Billing_Type__c, Promotion_1__r.Promotion_Code__c, Recipient_Contact__c
            FROM Zuora__Subscription__c             
            WHERE Zuora__External_Id__c = :subscriptionId AND Zuora__Status__c = 'Active' LIMIT 1]; //START/END 04/16/2015 UD-0934 Kevin Evasco - Used Zuora External Id instead of Zuora Id //START/END 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
        //END 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - Promotion_1__r.Promotion_Code__c
        //END 17 December 2015 D-4113 Kevin Evasco - Added Recipient_Contact__c
        
        if(subscriptionList.size() > 0)
        {
            if(accountNumberParam != null && accountNumberParam != '' && subscriptionList[0].Zuora__Account__r.Account_Auto_Number__c == accountNumberParam)        
            subscription = subscriptionList.get(0);
        }
        
        return subscription;
    }
    
    public static Boolean validateSimilarSubscriptions(String subscriptionIdParam, String accountNumberParam, String productFamilyParam, String countryCodeParam, String postalCodeParam, String levelNumberParam, String unitNumberParam)
    {
        Boolean isValid = true;
        List<Zuora__Subscription__c> subscriptionList = [SELECT Id FROM Zuora__Subscription__c WHERE 
            Zuora__External_Id__c != :subscriptionIdParam AND
            Zuora__Account__r.Account_Auto_Number__c =: accountNumberParam AND 
            Zuora__Status__c = 'Active' AND
            Subscription_Type_1__c = 'Publication' AND
            (Main_Package_1__r.Product_Family_Current_Package__c = :productFamilyParam OR
            (Recipient_Contact__r.Address__r.Country__r.Code__c = :countryCodeParam AND
            Recipient_Contact__r.Address__r.Postal_Code__r.Name = :postalCodeParam AND 
            Recipient_Contact__r.Address__r.Unit_Number__c = :unitNumberParam AND 
            Recipient_Contact__r.Address__r.Level_Number__c = :levelNumberParam)) LIMIT 1]; //START/END 04/16/2015 UD-0934 Kevin Evasco - Used Zuora External Id instead of Zuora Id
        if(subscriptionList.size() > 0)
            isValid = false;                
            
        return isValid;
    }
    
    public static Order__c getOrder(String orderId)
    {
        Order__c order;
        List<Order__c> orderList = [SELECT Id FROM Order__c WHERE Id = :orderId];
        if(orderList.size() > 0)
        {
            order = orderList.get(0);
        }
        
        return order;
    }
    
    public static Package__c getPackage(String packageCodeParam) {
        Package__c packageResult;
        //START D-3159 29-June-2015 Added by Raviteja - Adding Billing_Type__c in SOQL.
        List<Package__c> packageList = [SELECT Id, Billing_Type__c,Subscription_Period__c, Product_Family_Current_Package__c FROM Package__c WHERE Package_Code__c = :packageCodeParam];
        //END D-3159 29-June-2015 Added by Raviteja 
        if(packageList.size() > 0)
            packageResult = packageList.get(0);
            
        return packageResult;
    }
    
    public static Promotion__c getPromotion(String promotionCodeParam) {
        Promotion__c promoResult;
        
        List<Promotion__c> promoList = [SELECT Id FROM Promotion__c WHERE Promotion_Code__c = :promotionCodeParam LIMIT 1];
        if(promoList.size() > 0)
            promoResult = promoList.get(0);
        
        return promoResult;
    }
    
    public static List<Gift__c> getGifts(List<String> giftCodesParam) {
        Set<String> giftCodeSet = new Set<String>();
        
        if(giftCodesParam != null) 
            for(String giftCodeElement : giftCodesParam)
                giftCodeSet.add(giftCodeElement);
    
        List<Gift__c> giftsResult = [SELECT Id FROM Gift__c WHERE Gift_Code__c IN :giftCodeSet LIMIT 1];
        
        return giftsResult;
    }
    
    public static Order_Line_Item__c getOrderLineItem(String orderLineItemId)
    {
        Order_Line_Item__c orderLineItem;
        List<Order_Line_Item__c> orderLineItemList = [SELECT Id, Qty__c FROM Order_Line_Item__c WHERE Id = :orderLineItemId];
        if(orderLineItemList.size() > 0)
        {
            orderLineItem = orderLineItemList.get(0);
        }
        
        return orderLineItem;
    }      
    
    public static Zuora__CustomerAccount__c getBillingAccount(String billingAccountNumber)
    {
        Zuora__CustomerAccount__c billingAccount;
        //START D-3159 29-June-2015 Added by Raviteja - Added Billing_Type__c field in SOQL
        List<Zuora__CustomerAccount__c> billingAccountList = [SELECT Id, Billing_Type__c,Billing_Contact__r.Id, Zuora__Credit_Balance__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c FROM Zuora__CustomerAccount__c WHERE Zuora__AccountNumber__c = :billingAccountNumber]; //START/END 04/16/2015 UD-0934 Kevin Evasco - Used Billing Account Number instead of Zuora Id
        //End D-3159 29-June-2015 Added by Raviteja
        if(billingAccountList.size() > 0)
        {
            billingAccount = billingAccountList.get(0);
        }
        
        return billingAccount;
    }
    
    public static Account getAccount(String accountNumber)
    {
        Account accountRecord;
        List<Account> accountList = [SELECT Id FROM Account WHERE Account_Auto_Number__c =: accountNumber];
        if(accountList.size() > 0)
        {
            accountRecord = accountList.get(0);
        }
    
        return accountRecord;
    }
    
    private static Account createAccount(String recordType)
    {
        Account accountRecord = new Account();
        accountRecord.Name = recipientContactWrapper.customerName;
        
        if(recordType == 'Direct Corporate') 
        {            
            accountRecord.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate');
        }
        else if(recordType == 'Direct Individual')
        {
            accountRecord.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Individual');
        }     
        insert accountRecord;
        
        return accountRecord;
    }
    
    public static Contact getContact(String contactId, String accountNumberParam)
    {
        Contact contactRecord;
        //START: D-1668 01/22/2015 Added by P.Villarica - Added Address__r.RecordTypeId in the query
        List<Contact> contactList = [SELECT Id, Address__r.RecordTypeId, Account.Account_Auto_Number__c FROM Contact WHERE Id =: contactId];
        //END: D-1668 01/22/2015 Added by P.Villarica

        if(contactList.size() > 0)
        {
            System.debug('>>>>>contactList.get(0).Account.Account_Auto_Number__c: ' + contactList.get(0).Account.Account_Auto_Number__c);
            System.debug('>>>>>accountNumberParam: ' + accountNumberParam);
            if(accountNumberParam != null && accountNumberParam != '' && contactList.get(0).Account.Account_Auto_Number__c == accountNumberParam)           
                contactRecord = contactList.get(0);
        }
    
        return contactRecord;
    }
    
    private static Contact createContact(ContactWrapper contactDetails, Id parentAccountId, String type)
    {       
        Contact contactRecord = new Contact();
        contactRecord.AccountId = parentAccountId;
        contactRecord.Salutation = contactDetails.salutation;
        contactRecord.FirstName = 'First Name ';
        contactRecord.LastName = contactDetails.customerName;
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
        
        if(type == 'Billing Contact')
        {
            contactRecord.Billing_Indicator__c  = true;            
            contactRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Charles Lin
            insert contactRecord;
        }
        else if(type == 'Recipient Contact')
        {
            contactRecord.Recipient_Indicator__c = true;            
            contactRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');//START/END CCB.002 Modified by: Charles Lin
            insert contactRecord;
        }
        else if(type == 'Recipient and Billing Contact')
        {           
            contactRecord.Recipient_Indicator__c = true;   
            contactRecord.Billing_Indicator__c  = true;           
            // TO-DO: contactRecord.RecordTypeId = ConstantsSLB.getKeyId('Contact_Billing Contact');
            insert contactRecord;
        }

        return contactRecord;
    }
    
    
    
    public static Address__c searchAddress(AddressWrapper addressDetails)
    {
        Address__c addressRecord;  
        List<Address__c> addressList;
        if(addressDetails.country == GlobalVariableClass.SINGAPORE_CODE) //START/END 06/02/2015 D-3066 Kevin Evasco - Changed country code from 'SIN' to 'SG'
        {
            //START: D-1668 01/22/2015 Added by P.Villarica - Added missing parameter
            addressList = [SELECT Id, RecordTypeId, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Country_Name__c = :addressDetails.country AND Postal_Code__r.Name = :addressDetails.postalCode AND Unit_Number__c = :addressDetails.unitNumber]; //START/END 04/16/2015 UD-0934 Kevin Evasco - Use Country Name instead of country code
            //END: D-1668 01/22/2015 Added by P.Villarica
        }
        else
        {
            //START: D-1668 01/22/2015 Added by P.Villarica - Added missing parameter
            addressList = [SELECT Id, RecordTypeId, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Country_Name__c = :addressDetails.country AND Address_1__c = :addressDetails.Address1 AND Address_2__c = :addressDetails.Address2 AND Address_3__c = :addressDetails.Address3 AND Address_4__c = :addressDetails.Address4]; //START/END 04/16/2015 UD-0934 Kevin Evasco - Use Country Name instead of country code
            //END: D-1668 01/22/2015 Added by P.Villarica
        }
        
        if(addressList.size() > 0)
        {
            addressRecord = addressList.get(0);
        }
        
        return addressRecord;
    }
    
    public static Address__c createAddress(AddressWrapper addressDetails)
    {
        Address__c newAddress = new Address__c();               
        
        if(addressDetails.country == GlobalVariableClass.SINGAPORE_CODE) //START/END 06/02/2015 D-3066 Kevin Evasco - Changed country code from 'SIN' to 'SG'
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
        List<Country__c> countryList = [SELECT Id FROM Country__c WHERE Code__c = :countryCode]; //START/END 04/16/2015 UD-0934 Kevin Evasco - Use Country Name instead of country code
        if(countryList.size() > 0)
        {
            countryRecord = countryList.get(0);
        }
        else
        {       
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
        }
        
        return countryRecord;
    }   
    //START D-3159 29-June-2015 Added by Raviteja - Validating The Billing Account Billing Type with the Package Billing Type.
    public static Boolean isBillingTypevalid(String billaccBillingType, String pkgcode){
        Boolean isValid = True;
        String packagecode = pkgcode;
        String baBillingType = billaccBillingType;
       System.debug(' packagecode : '+packagecode);  
       System.debug(' baBillingType : '+baBillingType);                
        
      if(baBillingType != Null){    
            if(packagecode != null && packagecode != '' && !String.isBlank(packagecode) && packagecode.Trim() != '') {
                for(Package__c packageparam :[SELECT Id, Billing_Type__c,Package_Code__c  FROM Package__c WHERE Package_Code__c = :packagecode]){
                    String pkBillingType = packageparam.Billing_Type__c;
                    System.debug(' isValid : '+isValid);
                    System.debug(' baBillingType : '+baBillingType);
                    System.debug(' pkBillingType  : '+pkBillingType );
                if(pkBillingType != Null && isValid == True){                       
                                if(pkBillingType != baBillingType){
                                    isValid = False;  
                                    break;                          
                                }                                      
                    }else{   
                        isValid = False;
                        break;
                        }     
              }
            
            }
            else{
              isValid = False;     
              }             
        
      }else{
          isValid = False;     
          }  
                                 
      return isValid;
    }
    //End D-3159 29-June-2015 Added by Raviteja 
    
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
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
        }
        
        return singpostAddressRecord;
    }
    
    public static boolean validateMandatoryFields(ChangeSubscriptionServiceRequest request)
    {
        Boolean result = true;
        Boolean contactCountPrintFlag = false;
        
        
        if(request.subscription.accountNumber == null || request.subscription.accountNumber == '' || request.subscription.recipientId == null || request.subscription.recipientId == '')
        {
            if(request.contacts == null)
            {
                result = false;
            }
            else if(request.contacts.size() == 0)
            {
                result = false;
            }
            else
            {
                if(request.contacts.size() == 1)
                {
                    ContactWrapper contactWrapper = request.contacts.get(0);
                    if(contactWrapper.recipientIndicator != 'Y')
                    {                   
                        result = false;
                    }
                }
                else if(request.contacts.size() == 2)
                {       
                    ContactWrapper contactWrapper1 = request.contacts.get(0);
                    ContactWrapper contactWrapper2 = request.contacts.get(1);
                    if(contactWrapper1.recipientIndicator != 'Y' && contactWrapper2.recipientIndicator != 'Y')
                    {                   
                        result = false;
                    }
                }
                else
                {
                    result = false;
                }
            }
        }
        //START 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
        if((request.subscription.billingAccountId != null && request.subscription.billingAccountId != '') &&
            ((request.subscription.paypalBAID != null && request.subscription.paypalBAID != '') || (request.subscription.paypalEmail != null && request.subscription.paypalEmail != '')))
            result = false;
            
        if(request.subscription.paypalBAID != null && request.subscription.paypalBAID != '' && (request.subscription.paypalEmail == null || request.subscription.paypalEmail == ''))
            result = false;         
            
        if(request.subscription.paypalEmail != null && request.subscription.paypalEmail != '' && (request.subscription.paypalBAID == null || request.subscription.paypalBAID == ''))
            result = false;
        if(request.subscription.billingAccountId == null || request.subscription.billingAccountId == '')
        {
            if((request.subscription.paypalBAID == null || request.subscription.paypalBAID != '') && (request.subscription.paypalEmail == null || request.subscription.paypalEmail == '')) {
                if(request.contacts == null)
                {
                    result = false;
                }
                else if(request.contacts.size() == 0)
                {
                    result = false;
                }
                else
                {
                    if(request.contacts.size() == 1)
                    {
                        ContactWrapper contactWrapper = request.contacts.get(0);
                        if(contactWrapper.billingIndicator != 'Y')
                        {                   
                            result = false;
                        }
                    }
                    else if(request.contacts.size() == 2)
                    {       
                        ContactWrapper contactWrapper1 = request.contacts.get(0);
                        ContactWrapper contactWrapper2 = request.contacts.get(1);
                        if(contactWrapper1.billingIndicator != 'Y' && contactWrapper2.billingIndicator != 'Y')
                        {                   
                            result = false;
                        }
                    }
                    else if(contactCountPrintFlag == false)
                    {
                        result = false;
                    }
                }
            }
        }       
        //END 07/01/15 D-3199 Kevin Evasco - Change of Subscription Paypal CR
        if(request.contacts != null)
        {
            for(ContactWrapper contactWrapper : request.contacts)
            {
                if(contactWrapper.customerName == null || contactWrapper.customerName == '')
                {               
                    result = false;
                }
                
                if(contactWrapper.billingIndicator == null || contactWrapper.billingIndicator == '')
                {               
                    result = false;
                }
                
                if(contactWrapper.recipientIndicator == null || contactWrapper.recipientIndicator == '')
                {               
                    result = false;
                }
            }
        }      
        
        if(result == false)
        {           
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_MANDATORY;
            response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_MANDATORY;
        }
        
        return result;
    }   
    
    //START 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - Update End Date of the Old Subscription 
    public static List<Order_Line_Item__c> getNewOrderLineItems (Order__c orderParam) {     
        List<Order_Line_Item__c> orderLineItems = [SELECT Order__c, Order__r.Subscription__c, Order__r.Subscription__r.Billing_Type__c, Order__r.Subscription__r.Order_Line_Item_Number__c, Main_Package_Billing_Type__c, Urgent__c, Fee_Waiver__c, Start_Date__c  FROM Order_Line_Item__c WHERE Order__c = :orderParam.Id];
        return orderLineItems;
    }
    
    public static void updateSubscriptionEndDate(Zuora__Subscription__c subscritioptionParam, List<Order_Line_Item__c> newOrderLineItemListParam) {     
        if(!newOrderLineItemListParam.isEmpty()) {
            Date effectiveDate = newOrderLineItemListParam.get(0).Start_Date__c.addDays(-1);
             //START D-3828 30-Oct-2015 Added by Raviteja  - Updating logic for delivery subsription as well
            //updateSubscriptionEndDateFuture(subscritioptionParam.Id, effectiveDate);
            updateSubscriptionEndDateFuture(subscritioptionParam, effectiveDate);
            //End D-3828 30-Oct-2015 Added by Raviteja
        }
    }
    //START D-3828 30-Oct-2015 Added by Raviteja  - Updating logic for delivery subsription as well
    /*
    public static void updateSubscriptionEndDateFuture(Id subIdParam, Date endDateParam) {
        Zuora__Subscription__c oldSubscription = [SELECT Id, Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Id = :subIdParam LIMIT 1];
        oldSubscription.Zuora__SubscriptionEndDate__c = endDateParam;           
        SubscriptionTriggerHandler.preventExecution = true;
        Database.update(oldSubscription, false);
    }
    */
    public static void updateSubscriptionEndDateFuture(Zuora__Subscription__c subscritioptionParam, Date endDateParam) {
        List<Zuora__Subscription__c> oldSubscription = New List<Zuora__Subscription__c>();
        for(Zuora__Subscription__c oldsub : [SELECT Id, Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c = :subscritioptionParam.Order_Line_Item_Number_1__c]){
            oldsub.Zuora__SubscriptionEndDate__c = endDateParam; 
            oldSubscription.add(oldsub);    
        }
        
        if(!oldSubscription.isEmpty()){
            SubscriptionTriggerHandler.preventExecution = true;
            Database.update(oldSubscription, false);
        }
    }
    //End D-3828 30-Oct-2015 Added by Raviteja
    //END 21 October 2015 D-3244 D-3025 D-3645 Kevin Evasco - Update End Date of the Old Subscription
}

/***************** SAMPLE JSON REQUEST:
URL: /services/apexrest/ChangeSubscriptionService/v29.0

{
    "request" : 
    {
        "subscription" :
        {           
            "subscriptionId" : "2c92c0f949145e4a01492d902f025c7e",
            "accountNumber" : "30007357",
            "accountRecordType" : "Direct Corporate", 
            "billingAccountId" : "2c92c0f848a2eace0148afc659972ae3",
            "orderType" : "",
            "creationMode" : ""
        },
        "contacts" :
        [
            {
                "salutation" : "Mr.",
                "customerName" : " Evasco",
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
                    "levelNumber" : "50",
                    "unitNumber" : "80",
                    "postalCode" : "088271",
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
                "customerName" : " Evasco",
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
                    "levelNumber" : "50",
                    "unitNumber" : "80",
                    "postalCode" : "088271",
                    "streetName" : "5",
                    "buildingName" : "6",
                    "country" : "SIN",                  
                    "singpostAddressType" : "P",
                    "Address1" : "ADDRESS 1",
                    "Address2" : "ADDRESS 2",
                    "Address3" : "ADDRESS 3",
                    "Address4" : "ADDRESS 4"
                }        
            }
        ],
        "orderLineItem" :
        {
            "promotioncode" : "MAG12PROMO",
            "packagecode" : "PKG0001",                    
            "addonpackagecode" : "1312",
            "ldapId" : "2222222217",   
            "quantity" : 16,
            "startDate" : "09/30/2014",   
            "giftcode" : ["TTG", "NGP"],
            "contractenddate" : "09/30/2015"    
        }           
    }
}

**************************************/