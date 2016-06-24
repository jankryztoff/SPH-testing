/*
 * History: D-1846 20/01/2015 Wenjun: Postage Charges
 *          D-2224 23/02/2015 Kevin Evasco: Updated reference CancelSubscriptionBatch
 *          Hotfix 23/02/2015 Kevin Evasco: Major code update to fix glitches
 */
@RestResource(urlMapping='/RenewSubscriptionService/*')                        
global with sharing class RenewSubscriptionService {
    private static RenewSubscriptionServiceResponse response = new RenewSubscriptionServiceResponse();
    //START 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
    public static String billingAccountZID;
    public static Map<String,String> paypalResultMap = new Map<String,String>();
    public static Boolean isPaypal = false;
    public static Boolean isChangingBA = false; //START/END D-3277 23 July 2015 Kevin Evasco - PayPal CR Hotfix
    //END 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
    
    global class RenewSubscriptionServiceResponse {
        String svc_status;
        String error_code;
        String error_message = '';
        String orderid;
        String debug = '';
    }
    
    global class RenewSubscriptionServiceRequest {
        String subscriptionId;
        String subscriberId;
        String packageCode;
        String billingAccountNumber;
        String paymentMethodId;
        String subscriptionEndDate;
        String subscriptionStartDate;   
        String contractEndDate;  
        List<String> giftCode;
        //START 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
        String paypalBAID;
        String paypalEmail;
        //END 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
    }
    
    @HttpPost
    global static RenewSubscriptionServiceResponse processRequest(RenewSubscriptionServiceRequest request) {
        Account accountRecord;
        Zuora__CustomerAccount__c billingAccount;
        Zuora__Subscription__c subscription;
        List<Gift__c> giftList;
        Package__c packageRecord;       
        Package__c renewalPackageRecord;
        String renewalPackageCode;
        
        response.svc_status = GlobalVariableClass.SVC_STATUS_SUCCESS;
          
        //Savepoint savepointBeforeDML = Database.setSavepoint(); //START/END 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
        Boolean isValid = true;

        isValid = validateMandatoryFields(request);     
        
        if(isValid == true)
        {
            accountRecord = getAccount(request.subscriberId);
            if(accountRecord == null)
            {
                isValid = false;                
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
            }
        }
        if(isValid)
        {
            subscription = getSubscription(request.subscriptionId);
            if(subscription == null)
            {
                isValid = false;                
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
            }
            else if(subscription.Zuora__Account__r.Id != accountRecord.Id)
            {
                isValid = false;                
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;          
            }
        }
        
        //START D-3277 23 July 2015 Kevin Evasco - PayPal CR Hotfix
        if(isValid) {
            if(request.paypalBAID != null && request.paypalBAID != '') {
                isPaypal = true;
            }
            if(request.billingAccountNumber != null && request.billingAccountNumber != '') {
                isChangingBA = true;
            }
            if(isChangingBA == false && isPaypal == false) {
                if(subscription.Zuora__CustomerAccount__r.Zuora__Default_Payment_Method__r.Zuora__External_Id__c == null) {                 
                    isValid = false;                
                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                    response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                    response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
                    response.debug += 'Billing Account does not have a Default Payment Method. ';
                }
            }
        }
        //END D-3277 23 July 2015 Kevin Evasco - PayPal CR Hotfix
        
        if(isValid)
        {
            giftList = getGifts(request.giftCode);
            
            if(request.packageCode == null || request.packageCode == '')
                request.packageCode = subscription.Main_Package_1__r.Package_Code__c;
            
            packageRecord = getPackage(request.packageCode);          
            renewalPackageCode = getRenewalPackageCode(packageRecord);          
            
            Boolean isBANotFound = false;
            if(request.billingAccountNumber != null && request.billingAccountNumber != ''){
                billingAccount = getBillingAccount(request.billingAccountNumber);
                if(billingAccount == null)
                    isBANotFound = true;            
            }
                
            if(accountRecord == null || subscription == null || isBANotFound || packageRecord == null ||subscription.Main_Package_1__r.Product_Family_Current_Package__c != packageRecord.Product_Family_Current_Package__c){
                isValid = false;            
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
            }
            
            if(request.giftCode != null) {
                if(request.giftCode.size() > 0 && giftList.size() == 0) {
                    isValid = false;            
                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                    response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                    response.error_message += GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT;
                }
            }
        }
        
        if(isValid == true) {           
            if(renewalPackageCode == null)
                renewalPackageCode = subscription.Main_Package_1__r.Package_Code__c;
                
            renewalPackageRecord = getPackage(renewalPackageCode);
        }       
        //START D-3159 25-June-2015 Added by Raviteja - Added EverGreen Subscription Cannot be Renewal message
        if(isValid == true && subscription.Zuora__SubscriptionEndDate__c == null) {         
                isValid = false;
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_INVALID_INPUT; 
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_GENERIC;   
                response.debug += 'EverGreen Subscription Cannot be Renewal.';   
        }        
        //End D-3159 25-June-2015 Added by Raviteja 
        
        //START D-3277 23 July 2015 Kevin Evasco - PayPal CR Hotfix
        if(isChangingBA == false && isPaypal == false) {
            //START D-3159 25-June-2015 Added by Raviteja - 
            if(isValid == true){
            
                if(subscription.Zuora__CustomerAccount__r.Billing_Type__c != Null && renewalPackageRecord.Billing_Type__c != Null){
                     if(subscription.Zuora__CustomerAccount__r.Billing_Type__c == 'Full Prepaid' || renewalPackageRecord.Billing_Type__c == 'Full Prepaid'){
                            if(subscription.Zuora__CustomerAccount__r.Billing_Type__c != renewalPackageRecord.Billing_Type__c){
                                isValid = False;                                                                      
                            }                           
                     }else if(!renewalPackageRecord.Billing_Type__c.contains(subscription.Zuora__CustomerAccount__r.Billing_Type__c)){                     
                             isValid = False;                                          
                     }
                }else{
                    isValid = false;
                  }
                  
               if(isValid == false){
                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                    response.error_message = 'The Billing Type does not match the Package Billing Type'; 
                    response.error_code = 'EXES0005';   
                    response.debug += 'Billing Account Billing Type is : '+subscription.Zuora__CustomerAccount__r.Billing_Type__c+ ' And Package Billing Type is : '+renewalPackageRecord.Billing_Type__c;            
                }
            
            }        
            //End UD-3159 25-June-2015 Added by Raviteja 
        } else if(isChangingBA == true) {
            if(billingAccount.Billing_Type__c != renewalPackageRecord.Billing_Type__c) {
                isValid = false;
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_message = 'The Billing Type does not match the Package Billing Type'; 
                response.error_code = 'EXES0005';   
                response.debug += 'Billing Account Billing Type is : '+billingAccount.Billing_Type__c+ ' And Package Billing Type is : '+renewalPackageRecord.Billing_Type__c;       
            }
        }
        //END D-3277 23 July 2015 Kevin Evasco - PayPal CR Hotfix
        
        //START 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
        if(isValid && request.paypalBAID != null && request.paypalBAID != '') {
            isPaypal = true;
            
            PaypalHelper.BillingInformationWrapper billingInformation = new PaypalHelper.BillingInformationWrapper();
            billingInformation.paypalBAID = request.paypalBAID;
            billingInformation.paypalEmail = request.paypalEmail;
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
        
        //START 17 December 2015 D-4115 Kevin Evasco - Future COA on Recipient Contact
        if(isValid){
            String errorMessage = SM_SubscriptionHelper.validateFutureDatedCOA(subscription.Recipient_Contact__c,null,GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION);
            if(errorMessage != null) {
                isValid = false;            
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;   
                response.error_code = GlobalVariableClass.NSS_ERROR_CODE_INVALID_INPUT;
                response.error_message = errorMessage;   
                response.debug += errorMessage; 
            }
        }               
        //END 17 December 2015 D-4115 Kevin Evasco - Future COA on Recipient Contact
        
        Savepoint savepointBeforeDML = Database.setSavepoint();   
        //END 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
        
        if(isValid == true)
        {
        try
        {            
            Zuora__Subscription__c gracePeriodSubscription;
            if(subscription.Grace_Period_Subscription__r.Zuora__Zuora_Id__c != null && subscription.Grace_Period_Subscription__r.Zuora__Zuora_Id__c != '')
                gracePeriodSubscription = getSubscription(subscription.Grace_Period_Subscription__r.Zuora__Zuora_Id__c);
            
            //START 21 October 2015 D-3377/D-3376 Kevin Evasco - Retain Vendor Mailing Agent Assignment
            Id vendorMailingAgentId;
            List<Order_Line_Item__c> orderLineItemWithVendor = [SELECT Id, Vendor_Mailing_Agent__c FROM Order_Line_Item__c WHERE Order__c = :subscription.Order_Number__c AND Vendor_Mailing_Agent__c != null LIMIT 1];
            if(!orderLineItemWithVendor.isEmpty()){
                vendorMailingAgentId = orderLineItemWithVendor.get(0).Vendor_Mailing_Agent__c;
            }
            //END 21 October 2015 D-3377/D-3376 Kevin Evasco - Retain Vendor Mailing Agent Assignment
            system.debug('>>>>>CHA subscription.Order_Number__c ' + subscription.Order_Number__c);
            Order__c oldOrder = getOrder(subscription.Order_Number__c);
            system.debug('>>>>>CHA oldOrder ' + oldOrder);
            system.debug('>>>>>CHA oldOrder.getsObjectType() ' + oldOrder.getsObjectType());
            Order__c newOrder = (Order__c)SObjectAllFieldCloner.cloneObject(oldOrder,oldOrder.getsObjectType());
            newOrder.Order_Legacy_Id__c  = null; //START/END 05/10/2015 UD-1230, UD-1231,UD-1232, UD-1233 Kevin Evasco - Hotfix
            //START 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
            if(isPaypal) {
                newOrder.Payment_Method_ID__c = paypalResultMap.get(PaypalHelper.KEY_PAYMENT_METHOD_ZID);
                newOrder.Payment_Mode__c = 'PayPal';
            } else {
                newOrder.Payment_Method_ID__c = subscription.Zuora__CustomerAccount__r.Zuora__Default_Payment_Method__r.Zuora__External_Id__c;
            }
            //END 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
            Date subscriptionStartDate = subscription.Zuora__SubscriptionEndDate__c.addDays(1);
            newOrder.Subscription_Start_Date__c = subscription.Zuora__SubscriptionEndDate__c.addDays(1);
            newOrder.Subscription_End_Date__c = subscriptionStartDate.addMonths(Integer.valueOf(renewalPackageRecord.Subscription_Period__c));
            //newOrder.Contract_End_Date__c = DateUtility.convertDate(request.contractEndDate,'/','MDY');
            newOrder.Account__c = accountRecord.Id;
            //START 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
            if(isPaypal) {
                newOrder.Billing_Account_Creation_Mode__c = 'Use created Billing Account';
                newOrder.Billing_Account__c = null;
                
            } else {
                newOrder.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';  
                if(billingAccount != null)
                    newOrder.Billing_Account__c = billingAccount.Id;
                else
                    newOrder.Billing_Account__c = subscription.Zuora__CustomerAccount__r.Id;
            }
            //END 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
            newOrder.OwnerId = UserInfo.getUserId(); //START/END D-3277 23 July 2015 Kevin Evasco - PayPal CR Hotfix
            insert newOrder;            
            
            String sOrderAutoNumber = [SELECT Name FROM Order__c WHERE Id =: newOrder.Id].Name;
            response.orderid = sOrderAutoNumber;
            
            Order_Line_Item__c oldOrderLineItem = getOrderLineItem(subscription.Order_Line_Item_Number__c);
            
            
            NewSubscriptionService.OrderLineItemWrapper orderLineItem = new NewSubscriptionService.OrderLineItemWrapper();
            orderLineItem.packagecode = renewalPackageCode;
            orderLineItem.quantity = Integer.valueOf(oldOrderLineItem.Qty__c);          
            
            // TO-DO:
            orderLineItem.startDate = String.valueOf(subscriptionStartDate.month()) + '/' + String.valueOf(subscriptionStartDate.day()) + '/' + String.valueOf(subscriptionStartDate.year());
            orderLineItem.giftCode = request.giftCode;
            //orderLineItem.contractEndDate = request.contractEndDate;
            
            List<NewSubscriptionService.OrderLineItemWrapper> orderLineItemList = new List<NewSubscriptionService.OrderLineItemWrapper>();
            orderLineItemList.add(orderLineItem);
            
            //START D-0821 1/14/2015 Added By C. Lin - Add missing parameter
            //START D-1846 20/01/2015 Wenjun : Set New Postage Charge
            Contact recipientContact = getRecipientContact(newOrder.Recipient_Contact__c);
            NewSubscriptionService.createOrderLineItems(orderLineItemList,newOrder,null,recipientContact, vendorMailingAgentId); //START/END 20 October 2015 D-3377 and D-3376 Kevin Evasco - Retain Vendor Mailing Agent assignment
            //END D-1846 20/01/2015 Wenjun
            //END D-0821 1/14/2015 Added By C. Lin
            
            Date startDate;
            if(gracePeriodSubscription != null && Date.today() >= subscription.Zuora__SubscriptionEndDate__c)
                startDate = repopulateOrderLineItemStartDate(newOrder.Id, null, renewalPackageRecord);
            else
                startDate = repopulateOrderLineItemStartDate(newOrder.Id, subscription.Zuora__SubscriptionEndDate__c.addDays(1), renewalPackageRecord);     
                
            newOrder.Subscription_Start_Date__c = startDate;    
            newOrder.Subscription_End_Date__c = startDate.addMonths(Integer.valueOf(renewalPackageRecord.Subscription_Period__c));
            newOrder.Base_Subscription__c = subscription.Id; //START END PD-0210 18May2016 Added By C. Lin - Populate Base Subscription of Order with old sub
            
            update newOrder;
            newOrder = [SELECT Id, Recipient_Contact__r.Address__r.Postal_Code__c, Account__r.Account_Auto_Number__c,
                        Billing_Contact__c, Recipient_Contact__r.Address__c, Recipient_Contact__c, Delivery_Charge__c, Vendor_Credit__c, //START/END 12 October 2015 UD-3082 Kevin Evasco - Added Delivery Charge and Vendor Credit
                        Account__c, Acquisition_Type__c, Remarks__c, Parent_Case__c, Billing_Account_Creation_Mode__c, Billing_Account__c, FP_Del_Usage__c, Subscriber_Charge__c, Payment_Mode__c, Other_Payment_Mode__c, Delivery_Charge_Type__c, Payment_Method_ID__c, Billing_Type__c, Billing_Account__r.Zuora__External_Id__c
                        FROM Order__c 
                        WHERE Id = :newOrder.Id];
                        
            if(isValid == true)
            {
                Subscription_Handler sh = new Subscription_Handler();
                sh.origin = 'ESHOP Renewal of Subscription';
                //START 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
                if(isPaypal) {
                    sh.zBillingAccountId = paypalResultMap.get(PaypalHelper.KEY_BILLING_ACCOUNT_ZID);
                }
                //END 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
                sh.Subscription_Handler_Direct(newOrder);      
            
                if(gracePeriodSubscription != null)
                {               
                    Set<String> zAccountIdSet = new Set<String>();
                    zAccountIdSet.add(gracePeriodSubscription.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c);   
                    
                    //START D-2224 02/23/2015 Kevin Evasco: Updated reference CancelSubscriptionBatch
                    Set<String> orderIdSet = new Set<String>();
                    Set<String> subscriptionIdSet = new Set<String>();
                    
                    orderIdSet.add(oldOrder.Id);
                    subscriptionIdSet.add(gracePeriodSubscription.Zuora__Zuora_Id__c);
                    
                    CancelSubscriptionBatch cancelSubscriptionBatch = new CancelSubscriptionBatch(orderIdSet, subscriptionIdSet, startDate, zAccountIdSet, gracePeriodSubscription.Zuora__Account__r.Id);                   
                    //END D-2224 02/23/2015 Kevin Evasco: Updated reference CancelSubscriptionBatch
                    Database.executeBatch(cancelSubscriptionBatch);     
                }
            }
        }
        catch(Exception e)
        {        
            system.debug('>>>>>CHA e ' + e);
            Database.rollback(savepointBeforeDML);
            response.orderid = null;
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_GENERIC;
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_GENERIC;
            //START 05/10/2015 UD-1230, UD-1231,UD-1232, UD-1233 Kevin Evasco - Hotfix
            //response.error_code = GlobalVariableClass.GENERICERROR;
            /* REMOVED. Wrong implementation for exceptions
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
            
            //START: D-1685 01/26/2015 Added by Mark Gatdula, Error message for request with invalid/incorrect account number
            else if(e.getTypeName().contains('ListException'))
            {            
                    response.error_code = GlobalVariableClass.ERROR_CODE_EITHER;
                    response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_NO_CUSTOMER;
            }
            //END: D-1685 01/26/2015 Added by Mark Gatdula
            REMOVED. Wrong implementation for exceptions */
            //END 05/10/2015 UD-1230, UD-1231,UD-1232, UD-1233 Kevin Evasco - Hotfix
            response.debug += 'Type: ' + e.getTypeName() + ' ';
            response.debug += 'Message: ' + e.getMessage() + ' ';
            response.debug += 'Stack Trace: ' + e.getStackTraceString();
        }
        }
        system.debug('>>>>>CHA response ' + response);
        system.debug('>>>>>CHA response.debug ' + response.debug);
        return response;
    }
    
    //START 05/10/2015 UD-1230, UD-1231,UD-1232, UD-1233 Kevin Evasco - Hotfix
    public static Zuora__Subscription__c getSubscription(String subscriptionId)
    {
        Zuora__Subscription__c subscription;
        //START 17 December 2015 D-4115 Kevin Evasco - Added Recipient_Contact__c
        //START D-3159 29-June-2015 Added by Raviteja - Added Zuora__CustomerAccount__r.Billing_Type__c field in the SOQL
        List<Zuora__Subscription__c> subscriptionList = [SELECT Id, Zuora__SubscriptionEndDate__c, Zuora__CustomerAccount__r.Billing_Type__c,Order_Number__c, Order_Line_Item_Number__c, Zuora__CustomerAccount__r.Id, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Zuora__Account__r.Id, Zuora__Zuora_Id__c, Grace_Period_Subscription__r.Zuora__Zuora_Id__c, Main_Package_1__r.Effective_End_Date__c, Main_Package_1__r.Product_Family_Current_Package__c, Main_Package_1__r.Package_Code__c, Zuora__CustomerAccount__r.Zuora__Default_Payment_Method__r.Zuora__External_Id__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Address__r.Country_Name__c, Recipient_Contact__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c = :subscriptionId AND Status_Formula__c = 'Active' AND Main_Package_1__r.Effective_End_Date__c >= :Date.Today() AND Main_Package_1__r.Effective_Start_Date__c <= :Date.Today() LIMIT 1]; //START/END 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
        //End D-3159 29-June-2015 Added by Raviteja 
        //END 17 December 2015 D-4115 Kevin Evasco - Added Recipient_Contact__c
        if(subscriptionList.size() > 0){
            subscription = subscriptionList.get(0);
            //START D-3277 23 July 2015 Kevin Evasco - PayPal CR Hotfix
            //if(subscription.Zuora__CustomerAccount__r.Zuora__Default_Payment_Method__r.Zuora__External_Id__c == null)
            //    subscription = null;
            //END D-3277 23 July 2015 Kevin Evasco - PayPal CR Hotfix
        }
        return subscription;
    }
    
    public static List<Gift__c> getGifts(List<String> giftCodesParam) {
        Set<String> giftCodeSet = new Set<String>();
        
        if(giftCodesParam != null) 
            for(String giftCodeElement : giftCodesParam)
                giftCodeSet.add(giftCodeElement);
    
        List<Gift__c> giftsResult = [SELECT Id FROM Gift__c WHERE Gift_Code__c IN :giftCodeSet LIMIT 1];
        
        return giftsResult;
    }
    //END 05/10/2015 UD-1230, UD-1231,UD-1232, UD-1233 Kevin Evasco - Hotfix
    
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
    
    public static Package__c getPackage(String packageCodeParam) {
        Package__c packageResult;
        //START D-3159 29-June-2015 Added by Raviteja - Added Billing_Type__c field in SOQL
        List<Package__c> packageList = [SELECT Id, Billing_Type__c,Subscription_Period__c, Product_Family_Current_Package__c FROM Package__c WHERE Package_Code__c = :packageCodeParam AND Effective_End_Date__c >= :Date.Today() AND Effective_Start_Date__c <= :Date.Today()];
        //End D-3159 29-June-2015 Added by Raviteja 
        if(packageList.size() > 0)
            packageResult = packageList.get(0);
            
        return packageResult;
    }
    
    public static String getRenewalPackageCode(Package__c packageParam)
    {
        String renewalPackageCode;
        
        //START D-0821 1/8/2015 Added By C. Lin - Get Renewal Package Code from Package Item object instead of Package object. Only Newspaper and Magazine has Renewal Package Code.
        Id prodId;
        String zProductType;
        Boolean discounted = false;
        Id packId;
        String subPeriod;
                
        packId = packageParam.Id;
        subPeriod = packageParam.Subscription_Period__c;

        //START D-4413 Gdelrosario reverted the pulling of data of Package code to Package instead of Package_Item__c
        Package__c packageSelected = [SELECT Id, RenewalPkgCodeNewspaper__c, RenewalPkgCodeNewspaper__r.Package_Code__c, 
                                    RenewalPkgCodeMag1YrBase__c,RenewalPkgCodeMag1YrBase__r.Package_Code__c, RenewalPkgCodeMag1YrDisc__c,RenewalPkgCodeMag1YrDisc__r.Package_Code__c, RenewalPkgCodeMag2YrBase__c,RenewalPkgCodeMag2YrBase__r.Package_Code__c, RenewalPkgCodeMag2YrDisc__c,RenewalPkgCodeMag2YrDisc__r.Package_Code__c
                                        FROM Package__c WHERE Id = : packId];
        
        List<Package_Item__c> packageItemList = new List<Package_Item__c>(); // START-END : UD-3048 11/11/2015 Alyana Navarro 
        // START : UD-3048 11/11/2015 Alyana Navarro 
        packageItemList = [SELECT Id, Name, RecordTypeId, Product_Rate_Plan__r.zqu__ZProduct__c, Product_Family2__c
                            FROM Package_Item__c WHERE Package__c = :packId];
        // END : UD-3048 11/11/2015 Alyana Navarro 
        for(Package_Item__c packageItem : packageItemList){
            if(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')){ 
                prodId = packageItem.Product_Rate_Plan__r.zqu__ZProduct__c;
            }
            
            if(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Discount') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Discount')){
                discounted = true;
            }
        }
        
        List<zqu__ZProduct__c> productsList = [SELECT Id, Name, ProductSubType__c FROM zqu__ZProduct__c WHERE Id = : prodId];
        
        for(zqu__ZProduct__c product : productsList){
            zProductType = product.ProductSubType__c;
        }
        
        // START : UD-3048 11/11/2015 Alyana Navarro 
        if(discounted == false){
            for(Package_Item__c packageItem : packageItemList){
                if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Newspaper'){
                    renewalPackageCode = packageSelected.RenewalPkgCodeNewspaper__r.Package_Code__c;
                    //renewalPackageCode = packageItem.RenewalPkgCodeNewspaper__r.Package_Code__c;
                }else if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Magazine'){
                    if(subPeriod == '12'){
                        renewalPackageCode = packageSelected.RenewalPkgCodeMag1YrBase__r.Package_Code__c;
                        //renewalPackageCode = packageItem.RenewalPkgCodeMag1YrBase__r.Package_Code__c;
                    }else if(subPeriod == '24'){
                        renewalPackageCode = packageSelected.RenewalPkgCodeMag2YrBase__r.Package_Code__c;
                        //renewalPackageCode = packageItem.RenewalPkgCodeMag2YrBase__r.Package_Code__c;
                    }
                }
            }
        }else{
            for(Package_Item__c packageItem : packageItemList){
                if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Magazine'){
                    if(subPeriod == '12'){
                        renewalPackageCode = packageSelected.RenewalPkgCodeMag1YrDisc__r.Package_Code__c;
                        //renewalPackageCode = packageItem.RenewalPkgCodeMag1YrDisc__r.Package_Code__c;
                    }else if(subPeriod == '24'){
                        renewalPackageCode = packageSelected.RenewalPkgCodeMag2YrDisc__r.Package_Code__c;
                        //renewalPackageCode = packageItem.RenewalPkgCodeMag2YrDisc__r.Package_Code__c;
                    }
                }
            }
        }
        //END D-4413 Gdelrosario reverted the pulling of data of Package code to Package instead of Package_Item__c
        // END : UD-3048 11/11/2015 Alyana Navarro 
        //END D-0821 1/8/2015 Added By C. Lin
        
        return renewalPackageCode;
    }
    
    public static Zuora__CustomerAccount__c getBillingAccount(String billingAccountNumber)
    {
        Zuora__CustomerAccount__c billingAccount;
        List<Zuora__CustomerAccount__c> billingAccountList = [SELECT Id, Billing_Type__c FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = :billingAccountNumber AND Zuora__Default_Payment_Method__r.Zuora__External_Id__c != null]; //START/END D-3277 23 July 2015 Kevin Evasco - PayPal CR Hotfix
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
    
    public static boolean validateMandatoryFields(RenewSubscriptionServiceRequest request)
    {
        boolean result = true;
        
        if(request.subscriptionId == null || request.subscriptionId == '')
            result = false;
        
        if(request.subscriberId == null || request.subscriberId == '')
            result = false;
        /*
        if(request.subscriptionEndDate == null || request.subscriptionEndDate == '')
            result = false;
        
        if(request.subscriptionStartDate == null || request.subscriptionStartDate == '')
            result = false;
        
        if(request.packageCode == null || request.packageCode == '')  
            result = false;
        */
        //START 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
        if((request.billingAccountNumber != null && request.billingAccountNumber != '') &&
            ((request.paypalBAID != null && request.paypalBAID != '') || (request.paypalEmail != null && request.paypalEmail != '')))
            result = false;
            
        if(request.paypalBAID != null && request.paypalBAID != '' && (request.paypalEmail == null || request.paypalEmail == ''))
            result = false;         
            
        if(request.paypalEmail != null && request.paypalEmail != '' && (request.paypalBAID == null || request.paypalBAID == ''))
            result = false;
        
        if(result == false) {           
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;  
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_MANDATORY;
            response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_MANDATORY;
        }
        //END 07/01/15 D-3198 Kevin Evasco - Renewal of Subscription Paypal CR
        return result;
    }
    
    public static Date repopulateOrderLineItemStartDate(Id orderId, Date startDate, Package__c renewalPackageParam)
    {
        system.debug('>>>>>CHA orderId ' + orderId);
        Date startDateResult; 
        List<Order_Line_Item__c> orderLineItems = [SELECT Id, Earliest_Start_Date__c, Start_Date__c FROM Order_Line_Item__c WHERE Order__r.Id = :orderId];
        
        if(orderLineItems.size() > 0)
        {
            for(Order_Line_Item__c orderLineItem : orderLineItems)
            {
                if(startDate == null)
                {
                    orderLineItem.Start_Date__c = orderLineItem.Earliest_Start_Date__c;
                }
                else
                {
                    orderLineItem.Start_Date__c = startDate;
                }
                orderLineItem.End_Date__c = orderLineItem.Start_Date__c.addMonths(Integer.valueOf(renewalPackageParam.Subscription_Period__c));
                startDateResult = orderLineItem.Start_Date__c;              
                
                if(orderLineItem.Earliest_Start_Date__c == null)
                {
                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                    response.error_message += 'Order Line Item does not have an Earliest Start Date. ';
                }
            }
            system.debug('>>>>>CHA orderLineItems ' + orderLineItems);
            update orderLineItems;
        }
        system.debug('>>>>>CHA startDateResult ' + startDateResult);
        return startDateResult;
    }
    
    //START D-1846 20/01/2015 Wenjun : New Method to retrieve Recipient Contact
    public static Contact getRecipientContact(ID contactID)
    {
        Contact recipientContact = [SELECT Id, Address__r.Postal_Code__r.Name, Address__r.Block_House_Number__c, Address__r.Level_Number__c,
                                    Address__r.Unit_Number__c, Address__r.Address_Type__c, Address__r.RecordType.Name
                                    FROM Contact WHERE Id = :contactID];
        return recipientContact;
    }
    //END D-1846 20/01/2015 Wenjun
}

/***************** SAMPLE JSON REQUEST:
URL: /services/apexrest/RenewSubscriptionService/v29.0

{
    "request" :
    {
        "subscriptionId" : "2c92c0f849369b8801493ce03ec34516",
        "subscriberId" : "30075166",
        "billingAccountNumber" : "",
        "packageCode" : "123",
        "paymentMethodId" : "1",
        "subscriptionEndDate" : "10/29/2014",
        "contractEndDate" : "11/29/2014",
        "subscriptionStartDate" : "09/29/2014",
        "giftCode" :  ["TTG", "NGP"]
    }
}

**************************************/