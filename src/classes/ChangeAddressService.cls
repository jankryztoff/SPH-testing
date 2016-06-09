/*
 * Class Name: NewSubscriptionService
 * @author: Kevin H. Evasco
 * Date: 09/06/2014
 * Project/Requirement: ESHOP Start SubscriptionFrequency__c
 * @description This class generates Credit Card Failure Notification Letter Print Requests
 * 
 * History: 10/19/2014 Kevin Evasco Created Apex Webservice
 * History: 01/28/2015 D-1775 Kevin Evasco Updated mandatory field validation
 * History: 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
 * History: 01/29/2015 D-1776, D-1777 Kevin Evasco Replaced all 'SIN' with GlobalVariableClass.SINGAPORE_CODE
 * History: 02/06/2015 D-1651 Krithika D modified if condition to handle null pointer exception
 */
@RestResource(urlMapping='/ChangeAddressService/*')                        
global with sharing class ChangeAddressService {
    private static String singaporeName = 'Singapore'; //START/END 04/16/2015 Kevin Evasco UD-0928 - Use Country Name instead of Country Code
    private static ChangeAddressServiceResponse response = new ChangeAddressServiceResponse();
    //START D-1683 1/21/2015 Added By C. Lin - Fixed error messages for Invalid Input.
    private static Boolean proceed = true;
    //END D-1683 1/21/2015 Added By C. Lin
    
    global class ChangeAddressServiceResponse {
        String svc_status;
        String error_code;
        String error_message = '';
        String orderid;
        String debug = '';
        public String getSvc_status() {
        return svc_status;
    }
    public void setSvc_status(String svc_status) {
        this.svc_status = svc_status;
    }
    public String getError_code() {
        return error_code;
    }
    public void setError_code(String error_code) {
        this.error_code = error_code;
    }
    public String getError_message() {
        return error_message;
    }
    public void setError_message(String error_message) {
        this.error_message = error_message;
    }
    public String getOrderid() {
        return orderid;
    }
    public void setOrderid(String orderid) {
        this.orderid = orderid;
    }
    public String getDebug() {
        return debug;
    }
    public void setDebug(String debug) {
        this.debug = debug;
    }
    }
    
    global class ChangeAddressServiceRequest {
        String customerAccountNumber;
        String billingAccountNumber;
        List<String> subscriptions;
        String country;
        String postalCode;
        String blockNumber;   
        String levelNumber;
        String streetName;
        String buildingName;
        String unitNumber;
        String Address1;
        String Address2;
        String Address3;
        String Address4;
        String billingIndicator;
        String deliveryIndicator;
        String effectiveDate;
        
        public String getCustomerAccountNumber() {
        return customerAccountNumber;
    }
    public void setCustomerAccountNumber(String customerAccountNumber) {
        this.customerAccountNumber = customerAccountNumber;
    }
    public String getBillingAccountNumber() {
        return billingAccountNumber;
    }
    public void setBillingAccountNumber(String billingAccountNumber) {
        this.billingAccountNumber = billingAccountNumber;
    }
    public List<String> getSubscriptions() {
        return subscriptions;
    }
    public void setSubscriptions(List<String> subscriptions) {
        this.subscriptions = subscriptions;
    }
    public String getCountry() {
        return country;
    }
    public void setCountry(String country) {
        this.country = country;
    }
    public String getPostalCode() {
        return postalCode;
    }
    public void setPostalCode(String postalCode) {
        this.postalCode = postalCode;
    }
    public String getBlockNumber() {
        return blockNumber;
    }
    public void setBlockNumber(String blockNumber) {
        this.blockNumber = blockNumber;
    }
    public String getLevelNumber() {
        return levelNumber;
    }
    public void setLevelNumber(String levelNumber) {
        this.levelNumber = levelNumber;
    }
    public String getStreetName() {
        return streetName;
    }
    public void setStreetName(String streetName) {
        this.streetName = streetName;
    }
    public String getBuildingName() {
        return buildingName;
    }
    public void setBuildingName(String buildingName) {
        this.buildingName = buildingName;
    }
    public String getUnitNumber() {
        return unitNumber;
    }
    public void setUnitNumber(String unitNumber) {
        this.unitNumber = unitNumber;
    }
    public String getAddress1() {
        return Address1;
    }
    public void setAddress1(String address1) {
        Address1 = address1;
    }
    public String getAddress2() {
        return Address2;
    }
    public void setAddress2(String address2) {
        Address2 = address2;
    }
    public String getAddress3() {
        return Address3;
    }
    public void setAddress3(String address3) {
        Address3 = address3;
    }
    public String getAddress4() {
        return Address4;
    }
    public void setAddress4(String address4) {
        Address4 = address4;
    }
    public String getBillingIndicator() {
        return billingIndicator;
    }
    public void setBillingIndicator(String billingIndicator) {
        this.billingIndicator = billingIndicator;
    }
    public String getDeliveryIndicator() {
        return deliveryIndicator;
    }
    public void setDeliveryIndicator(String deliveryIndicator) {
        this.deliveryIndicator = deliveryIndicator;
    }
    public String getEffectiveDate() {
        return effectiveDate;
    }
    public void setEffectiveDate(String effectiveDate) {
        this.effectiveDate = effectiveDate;
    }
    }
    
    @HttpPost
    global static ChangeAddressServiceResponse processRequest(ChangeAddressServiceRequest request) {
        //response.svc_status = 'SUCCESS';
        response.svc_status = GlobalVariableClass.SVC_STATUS_SUCCESS;
        
        Savepoint savepointBeforeDML = Database.setSavepoint();     
        Boolean validationResult = validateMandatoryFields(request);
        if(validationResult == true)
        {
        try
        {
            //START D-1683 1/21/2015 Added By C. Lin - Fixed error messages for Invalid Input.
            //Boolean proceed = true;
            //END D-1683 1/21/2015 Added By C. Lin
            Boolean targetIsOverseas = false;
            
            Contact newRecipientContact;
            
            Set<String> zAccountIdSet = new Set<String>();
            Set<String> subscriptionIdSetForCancellation = new Set<String>();
            Set<String> orderIdSet = new Set<String>();
            Set<String> orderLineItemIdSet = new Set<String>();
            Set<String> orderLineItemIdSetForUpdate = new Set<String>();
            Set<Id> billingContactIdSet = new Set<Id>();
            Set<Id> recipientContactIdSet = new Set<Id>();
            Set<Id> billingRecipientContactIdSet = new Set<Id>();   
            //START 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription     
            Set<String> newOrderIdSet = new Set<String>();
            Set<String> orderIdForStopSubscription = new Set<String>();
            //END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription   
            
            List<Order__c> newOrderList = new List<Order__c>();
            List<Order__c> oldOrderList = new List<Order__c>();
            List<Order_Line_Item__c> oldOrderLineItemList = new List<Order_Line_Item__c>();
            List<Order_Line_Item__c> newOrderLineItemList = new List<Order_Line_Item__c>();
            List<Order_Line_Item_Gift__c> oldOrderLineItemGiftList = new List<Order_Line_Item_Gift__c>();
            List<Order_Line_Item_Gift__c> newOrderLineItemGiftList = new List<Order_Line_Item_Gift__c>();
            List<Contact> billingContactList = new List<Contact>();
            List<Contact> recipientContactList = new List<Contact>();
            List<Contact> contactsForUpdate = new List<Contact>();
            List<Contact> contactsForInsert = new List<Contact>();
            
            Map<String,String> orderId_subscriptionId_map = new Map<String,String>();
            Map<Id,Order_Line_Item__c> olig_oli_map = new Map<Id,Order_Line_Item__c>();
            Map<Id,Id> recipientId_billingId_map = new Map<Id,Id>();
            Map<Id,Case> billingId_case_map = new Map<Id,Case>();
            Map<Id,Contact> billingRecipientContactMap = new Map<Id,Contact>();
            Map<Id,Id> orderLineItemId_subId_map = new Map<Id,Id>();//START/END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
                
            
            Country__c country;
            if(proceed == true)
            {
                country = getCountry(request.country);
                if(country == null)
                {
                    proceed = false;
                }
            }
            
            //START 01/28/2015 D-1775 Kevin Evasco Moved code block
            Singpost_Address__c singpostAddress;
            if(proceed == true && request.country == singaporeName) //START/END 01/28/2015 D-1775 Kevin Evasco Get singpost for local addresses only //START/END 04/16/2015 Kevin Evasco UD-0928 - Use Country Name instead of Country Cod
            {           
                // Start D-1766 01/23/2015 JohnD add buildingName as parameter 
                singpostAddress = getSingpostAddress(request.postalCode,request.levelNumber,request.streetName,request.unitNumber,request.blockNumber,request.buildingName);
                // End D-1766 01/23/2015 JohnD
                if(singpostAddress == null)
                {
                    proceed = false;
                }
            }
            
            Address__c addressRecord;
            if(proceed == true)
            {
                //START 01/28/2015 D-1775 Kevin Evasco Pass singpost address record for local addresses.
                if(request.country == singaporeName) //START/END 04/16/2015 Kevin Evasco UD-0928 - Use Country Name instead of Country Code
                {
                    addressRecord = getAddress(request,country.Id,singpostAddress.Id);
                    system.debug('================>addressrecord'+addressRecord);
                }
                else
                {
                    addressRecord = getAddress(request,country.Id,null);
                    system.debug('================>addressrecord'+addressRecord);
                }
                //END 01/28/2015 D-1775 Kevin Evasco Pass singpost address record for local addresses.
            }
            
            if(request.country != singaporeName) //START/END 04/16/2015 Kevin Evasco UD-0928 - Use Country Name instead of Country Code
            {
                targetIsOverseas = true;
            }       
            //END 01/28/2015 D-1775 Kevin Evasco Moved code block           
                
            Account accountRecord;
            if(proceed == true)
            {
                accountRecord = getAccount(request.customerAccountNumber);
                if(accountRecord == null)
                {
                    proceed = false;
                }
                
            }
            
            Zuora__CustomerAccount__c billingAccount;
            Zuora__CustomerAccount__c customerAccount; //START/END UD-1050 29-Apr-2015 Added by Raviteja - (Scenario 1)
            if(proceed == true)
            {
                billingAccount = getBillingAccount(request.billingAccountNumber);
                //START UD-1050 29-Apr-2015 Added by Raviteja  - (Scenario 1) Commented the exisiting condition and added new condition
                customerAccount= getCustomerAccount(request.customerAccountNumber,request.billingAccountNumber,request.subscriptions);               
              // if(billingAccount == null)
             //START UD-1050 04-May-2015 Added by Raviteja  - (Scenario 1) Commented the existing condition and added new condition
             //if(billingAccount == null && customerAccount == null) 
             if(billingAccount == null || customerAccount == null)  
              //End UD-1050 04-May-2015 Added by Raviteja - (Scenario 1)
              //End UD-1050 29-Apr-2015 Added by Raviteja - (Scenario 1)                
                {
                    proceed = false;
                }
                else
                {
                    billingContactIdSet.add(billingAccount.Billing_Contact__r.Id);
                    //START 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
                    if(request.deliveryIndicator == 'Y')
                    {
                        Contact oldBillingContact = getContact(billingAccount.Billing_Contact__r.Id);   
                        system.debug('=============>oldbillingcontact'+oldBillingContact);                    
                        newRecipientContact = (Contact) SObjectAllFieldCloner.cloneObject(oldBillingContact, oldBillingContact.getsObjectType());
                        
                        newRecipientContact.Recipient_Indicator__c = true;
                        newRecipientContact.Billing_Indicator__c = false;
                        newRecipientContact.Address__c = addressRecord.Id;
                        newRecipientContact.id=null;//Krithika Dharmarajan 5/15/2015  Hot Fix
                        newRecipientContact.Contact_Legacy_Id__c=null; //Krithika Dharmarajan 5/15/2015  Hot Fix
                        system.debug('===========>neewrecipientcontact'+newRecipientContact);
                        insert newRecipientContact;
                        newRecipientContact = [SELECT Id, Address__r.Address_Type__c, Address__r.RecordTypeId FROM Contact WHERE Id = :newRecipientContact.Id]; 
                    }   
                    //END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription      
                }
            }
                
            if(proceed == true)
            {               
                Boolean subscriptionIsNull = true;
                //START D-1768 1/22/2015 Added By C. Lin - Validate invalid subscriptions.
                integer invalidSubscription = 0;
                //START D-1651 12/2/2015 Krithika D Null pointer Exception
                if(request.subscriptions != null)
                {
                for(String sub : request.subscriptions){
                if(sub == ''){
                invalidSubscription++;
                }
                } 
                }
                //END D-1651 12/2/2015 Krithika D Null pointer Exception
                if(invalidSubscription > 0){
                    proceed = false;
                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                    response.error_message += GlobalVariableClass.CAS_ERROR_MESSAGE_INVALID_SUBID;
                    response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
                }
                //END D-1768 1/22/2015 Added By C. Lin
                
                //START D-1768 1/22/2015 Added By C. Lin - Validate invalid subscriptions.
                if(!request.subscriptions.isempty() && invalidSubscription == 0)
                //END D-1768 1/22/2015 Added By C. Lin
                {
                    if(request.subscriptions.size() > 0)
                    {
                        List<Zuora__Subscription__c> subscriptionsList = getSubscriptions(request.subscriptions);
                        if(subscriptionsList != null)
                        {                                                               
                            for(Zuora__Subscription__c subscription : subscriptionsList)
                            {                               
                                orderIdSet.add(subscription.Order_Number__c);
                                orderLineItemIdSet.add(subscription.Order_Line_Item_Number__c);
                                orderLineItemId_subId_map.put(subscription.Order_Line_Item_Number__c,subscription.Id);//START/END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
                                zAccountIdSet.add(subscription.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c);   
                                orderId_subscriptionId_map.put(subscription.Order_Number__c,subscription.Zuora__Zuora_Id__c);
                                
                                billingContactIdSet.add(subscription.Contact__r.Id);
                                recipientContactIdSet.add(subscription.Recipient_Contact__r.Id);
                                
                                recipientId_billingId_map.put(subscription.Recipient_Contact__r.Id, subscription.Contact__r.Id);
                                
                                if(billingAccount.Billing_Contact__r.Id != subscription.Contact__r.Id)
                                {
                                    proceed = false;                            
                                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                                    response.error_message += 'Subscription ' + subscription.Name + '\'s Billing Contact is the different from Billing Account ' + billingAccount.Name + '\'s Billing Contact';
                                    //START D-1683 1/21/2015 Added By C. Lin - Fixed error messages for Invalid Input. Add Error Code.
                                    response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
                                    //END D-1683 1/21/2015 Added By C. Lin
                                }                           
                            }
                        }
                        else
                        {
                            proceed = false;
                        }
                        
                        subscriptionIsNull = false;
                    }
                }
                
                //START D-1768 1/22/2015 Added By C. Lin - Validate invalid subscriptions.
                if(subscriptionIsNull == true && invalidSubscription == 0)
                //END D-1768 1/22/2015 Added By C. Lin
                {
                    //START 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription  
                    List<Zuora__Subscription__c> allSubscriptionsList = getAllSubscriptions(accountRecord.Id, billingAccount.Id);
                    if(allSubscriptionsList != null)
                    {                                                               
                        for(Zuora__Subscription__c subscription : allSubscriptionsList)
                        {         
                    //END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription                       
                            orderIdSet.add(subscription.Order_Number__c);
                            orderLineItemIdSet.add(subscription.Order_Line_Item_Number__c);
                            zAccountIdSet.add(subscription.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c);   
                            orderId_subscriptionId_map.put(subscription.Order_Number__c,subscription.Zuora__Zuora_Id__c);
                            
                            recipientContactIdSet.add(subscription.Recipient_Contact__r.Id);                            
                            recipientId_billingId_map.put(subscription.Recipient_Contact__r.Id, subscription.Contact__r.Id);                        
                        }
                    }
                }
            }               
            
            //START D-1683 1/21/2015 Added By C. Lin - Fixed error messages for Invalid Input.
            if(proceed == true){
            //END D-1683 1/21/2015 Added By C. Lin
            List<Address_Assignment__c> addressAssignments = new List<Address_Assignment__c>();
            List<Case> billingAddressChangeCases = new List<Case>();
            List<Case> deliveryAddressChangeCases = new List<Case>();
            if(request.billingIndicator == 'Y')
            {
                billingContactList = [SELECT Id, Address__c, Billing_Indicator__c, Recipient_Indicator__c FROM Contact Where ID IN :billingContactIdSet];               
                for(Contact contactRecord : billingContactList)
                {               
                    Case caseRecord = createCase(accountRecord.Id, contactRecord, request, 'Billing Contact', null);
                    billingAddressChangeCases.add(caseRecord);
                    billingId_case_map.put(contactRecord.Id, caseRecord);
                    
                    Address_Assignment__c addressAssignment = new Address_Assignment__c();
                    addressAssignment.Contact__c = contactRecord.Id;
                    addressAssignment.Effective_Date__c = DateUtility.convertDate(request.effectiveDate,'/','MDY');
                    addressAssignment.Address__c = addressRecord.Id;
                    addressAssignment.Status__c = 'Active'; 
                    addressAssignments.add(addressAssignment);
                    system.debug('============addressassignment'+addressAssignments);
                }                               
            }
            
                
            if(billingAddressChangeCases.size() > 0)
            {
                insert billingAddressChangeCases;
            }
            
            if(request.deliveryIndicator == 'Y')
            {
                recipientContactList = [SELECT Id, Address__r.Country_Name__c, Address__r.Country__r.Code__c FROM Contact Where ID IN :recipientContactIdSet];     
                for(Contact contactRecord : recipientContactList)
                {
                    Case parentCase = billingId_case_map.get(recipientId_billingId_map.get(contactRecord.Id));
                    Case caseRecord = createCase(accountRecord.Id, contactRecord, request, 'Recipient Contact', parentCase);
                    deliveryAddressChangeCases.add(caseRecord);
                    
                //START 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
                    if(targetIsOverseas == false && contactRecord.Address__r.Country__r.Code__c == GlobalVariableClass.SINGAPORE_CODE)
                    {
                        Address_Assignment__c addressAssignment = new Address_Assignment__c();
                        addressAssignment.Contact__c = contactRecord.Id;
                        addressAssignment.Effective_Date__c = DateUtility.convertDate(request.effectiveDate,'/','MDY');
                        addressAssignment.Address__c = addressRecord.Id;
                        addressAssignment.Status__c = 'Active'; 
                        addressAssignments.add(addressAssignment);
                    }       
                //END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
                }       
            }       
            
            if(deliveryAddressChangeCases.size() > 0)
            {
                insert deliveryAddressChangeCases;
            }
            
            if(addressAssignments.size() > 0)
            {
                insert addressAssignments;
            }
                        
            Map<Id,Order__c> oldOrder_newOrder_map = new Map<Id,Order__c>();
            Map<Id,Order__c> oldOrderMap = new Map<Id,Order__c>();  
            oldOrderList = getOrders(orderIdSet);           
            
            for(Order__c oldOrder : oldOrderList)
            {               
                Order__c newOrder = (Order__c)SObjectAllFieldCloner.cloneObject(oldOrder,oldOrder.getsObjectType());
                newOrder.Billing_Account__c = billingAccount.Id;    
                newOrder.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)'; 
                
                Boolean oldDeliveryIsOverseas = false;                
                if(request.deliveryIndicator == 'Y' && oldOrder.Recipient_Contact__r.Address__r.Country__r.Code__c != GlobalVariableClass.SINGAPORE_CODE)//START/END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
                {
                    oldDeliveryIsOverseas = true;
                }
                
                if(targetIsOverseas == true || oldDeliveryIsOverseas == true)
                {                   
                    //START 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
                    orderIdForStopSubscription.add(oldOrder.Id);
                    newOrder.Recipient_Contact__c = newRecipientContact.Id;
                    //END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
                    newOrderList.add(newOrder);
                    subscriptionIdSetForCancellation.add(orderId_subscriptionId_map.get(oldOrder.Id));  
                }
                oldOrder_newOrder_map.put(oldOrder.Id,newOrder);    
                oldOrderMap.put(oldOrder.Id,oldOrder);              
            }      
            update oldOrderList;
            insert newOrderList;
            
            oldOrderLineItemList = getOrderLineItems(orderLineItemIdSet);           
            
            //START 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
            Set<Id> allPackageIdSet = new Set<Id>();
            List<Order__c> ordersToUpdate = new List<Order__c>();
            for(Order_Line_Item__c orderLineItem : oldOrderLineItemList)
            {
                allPackageIdSet.add(orderLineItem.Main_Package_ID__r.Id);
            }
            Map<Id,List<Package_Item__c>> package_packageItemMap = new Map<Id,List<Package_Item__c>>();
            Map<Id,zqu__ProductRatePlan__c> productRatePlanMap = new Map<Id,zqu__ProductRatePlan__c>();
            Map<Id,List<Product_Publication__c>> product_productPublicationMap = new Map<Id,List<Product_Publication__c>>();
            Map<Id,Date> earliestStartDateMap = getEarliestStartDateMap(allPackageIdSet, package_packageItemMap, productRatePlanMap, product_productPublicationMap);    
            //END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription           
            
            for(Order_Line_Item__c orderLineItem : oldOrderLineItemList)
            {
                Order_Line_Item__c newOrderLineItem = (Order_Line_Item__c)SObjectAllFieldCloner.cloneObject(orderLineItem,orderLineItem.getsObjectType());
                
                Order__c orderRecord = oldOrder_newOrder_map.get(newOrderLineItem.Order__c);
                Order__c oldOrder = oldOrderMap.get(newOrderLineItem.Order__c);
                Boolean oldDeliveryIsOverseas = false;
                
                if(request.deliveryIndicator == 'Y' && oldOrder.Recipient_Contact__r.Address__r.Country__r.Code__c != GlobalVariableClass.SINGAPORE_CODE) //START/END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
                {
                    oldDeliveryIsOverseas = true;
                }
                if(targetIsOverseas == true || oldDeliveryIsOverseas == true)
                {
                    newOrderLineItem.Order__c = orderRecord.Id;  
                    //START 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
                    newOrderLineItem.Earliest_Start_Date__c = earliestStartDateMap.get(orderLineItem.Main_Package_ID__r.Id);   newOrderLineItem.Start_Date__c = NewSubscriptionService.convertDate(request.effectiveDate);
                    
                    String addressTypeDeliveryChargeType =  newRecipientContact.Address__r.Address_Type__c + orderRecord.Delivery_Charge_Type__c;
                    String DirectSubDelMethod = ConstantsSLB.getKeyId('Publication Delivered By');
                    String pubDeliveredBy;
                    Boolean hasPostageCharge = false;
                    
                    try
                    {
                        pubDeliveredBy = product_productPublicationMap.get(productRatePlanMap.get(package_packageItemMap.get(orderLineItem.Main_Package_ID__r.Id)[0].Product_Rate_Plan__r.Id).zqu__ZProduct__r.Id)[0].Publication_Code__r.Direct_Sub_Delivery_Method__c;
                    }
                    catch(Exception e)
                    {       
                        pubDeliveredBy = null;
                    }

                    if(newRecipientContact.Address__r.RecordTypeId != ConstantsSLB.getkeyid('Address_Local'))
                    {
                        newOrderLineItem.Delivered_By__c = 'Mailing Agent';
                        newOrderLineItem.Direct_Sub_Delivery_Method__c = 'Mailing Agent';                   
                        orderRecord.Delivery_Charge__c = 0;
                        hasPostageCharge = true;    
                    }
                    else if(newRecipientContact.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Local') && (pubDeliveredBy == null || pubDeliveredBy == DirectSubDelMethod))
                    {
                        if(package_packageItemMap.get(orderLineItem.Main_Package_ID__r.Id)[0].Is_Newspaper__c == true)
                        {
                            newOrderLineItem.Delivered_By__c = 'Vendor';
                            newOrderLineItem.Direct_Sub_Delivery_Method__c = 'Vendor';
                            orderRecord.Delivery_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
                            orderRecord.Subscriber_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
                        }
                        else if(package_packageItemMap.get(orderLineItem.Main_Package_ID__r.Id)[0].Is_Magazine__c == true)
                        {
                            newOrderLineItem.Delivered_By__c = 'Mailing Agent';
                            newOrderLineItem.Direct_Sub_Delivery_Method__c = 'Mailing Agent';
                            orderRecord.Delivery_Charge__c = 0;
                            hasPostageCharge = true;    
                        }
                    }
                    else if(newRecipientContact.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Local'))
                    {
                        newOrderLineItem.Delivered_By__c = pubDeliveredBy;
                        newOrderLineItem.Direct_Sub_Delivery_Method__c = pubDeliveredBy;                
                        if(pubDeliveredBy == 'Vendor')
                        {
                            orderRecord.Delivery_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
                            orderRecord.Subscriber_Charge__c = ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
                        }
                        else if(pubDeliveredBy == 'Mailing Agent')
                        {
                            orderRecord.Delivery_Charge__c = 0;
                            hasPostageCharge = true;    
                        }
                    }
                    if(hasPostageCharge)
                    {
                        newOrderLineItem.Postage_Charge__c = PostageChargeHelper.getPostageChargeForLineItem(newRecipientContact.Id, newOrderLineItem);
                    }
                    ordersToUpdate.add(orderRecord);
                    //END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
                    newOrderLineItemList.add(newOrderLineItem);
                    orderLineItemIdSetForUpdate.add(orderLineItem.Id);
                    olig_oli_map.put(orderLineItem.Id, newOrderLineItem);
                }
                
                orderLineItem.Subscription__c = orderLineItemId_subId_map.get(orderLineItem.Id);//START/END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
            }
            
            //START 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
            if(oldOrderLineItemList.size() > 0)
            {
                Database.update(oldOrderLineItemList);
            }
            //END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription

            if(newOrderLineItemList.size() > 0)
            {
                insert newOrderLineItemList;    
                update ordersToUpdate; //START/END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
            }
            
            oldOrderLineItemGiftList = getOrderLineItemGifts(orderLineItemIdSetForUpdate);
            
            for(Order_Line_Item_Gift__c orderLineItemGift : oldOrderLineItemGiftList)
            {
                Order_Line_Item_Gift__c newOrderLineItemGift  =(Order_Line_Item_Gift__c)SObjectAllFieldCloner.cloneObject(orderLineItemGift,orderLineItemGift.getsObjectType());
                                
                Order_Line_Item__c newOrderLineItem = olig_oli_map.get(orderLineItemGift.Order_Line_Item__c);
                newOrderLineItemGift.Order_Line_Item__c = newOrderLineItem.Id;
                
                newOrderLineItemGiftList.add(newOrderLineItemGift);
            }
            
            insert newOrderLineItemGiftList;
            //START D-1683 1/21/2015 Added By C. Lin - Fixed error messages for Invalid Input.
            }
            //END D-1683 1/21/2015 Added By C. Lin            
            
            //START 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription             
            if(proceed == true)
            {
                if(orderIdForStopSubscription.size() > 0 && subscriptionIdSetForCancellation.size() > 0)
                {
                    if(newOrderList.size() > 0)
                    {
                        for(Order__c newOrder : newOrderList)
                        {
                            newOrderIdSet.add(newOrder.Id);
                        }       
                    }
                    StartSubscriptionBatch startSubscriptionBatchInstance = new StartSubscriptionBatch(newOrderIdSet);
                    Database.executeBatch(startSubscriptionBatchInstance,1);     
                
                    CancelSubscriptionBatch cancelSubscriptionBatchInstance = new CancelSubscriptionBatch(orderIdForStopSubscription, subscriptionIdSetForCancellation, NewSubscriptionService.convertDate(request.effectiveDate), zAccountIdSet, billingAccount.Zuora__Account__r.Id);
                    Database.executeBatch(cancelSubscriptionBatchInstance,10);     
                }                   
            }   
            //END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription               
            
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
            response.debug += 'Type: ' + e.getTypeName() + ' ';
            response.debug += 'Message: ' + e.getMessage() + ' ';
            response.debug += 'Stack Trace: ' + e.getStackTraceString();
        }
        }
        else
        {           
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.NSS_ERROR_CODE_MANDATORY;
        }
        
        return response;
    }
    
    public static List<Zuora__Subscription__c> getSubscriptions(List<String> subscriptionIds)
    {
        Set<String> subscriptionIdSet = new Set<String>();
        Set<String> missingSubscriptionIdSet = new Set<String>();
        for(String subscriptionId : subscriptionIds)
        {   
            if(subscriptionId != null && subscriptionId != '')
            {
                subscriptionIdSet.add(subscriptionId);
            }
        }
        missingSubscriptionIdSet.addAll(subscriptionIdSet);
        List<Zuora__Subscription__c> subscriptionList = [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__External_Id__c, Order_Number__c, Order_Line_Item_Number__c, Zuora__CustomerAccount__r.Id, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Zuora__Account__r.Id, Contact__r.Id, Recipient_Contact__r.Id, Recipient_Contact__c FROM Zuora__Subscription__c WHERE Zuora__External_Id__c IN :subscriptionIdSet]; //START/END 04/16/2015 UD-0928 Kevin Evasco - Used Zuora External Id instead of Zuora Id
        
        for(Zuora__Subscription__c subscription : subscriptionList)
        {
            missingSubscriptionIdSet.remove(subscription.Zuora__External_Id__c); //START/END 04/16/2015 UD-0928 Kevin Evasco - Used Zuora External Id instead of Zuora Id
        }
        
        for(String subscriptionId : missingSubscriptionIdSet)
        {       
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_message = 'Subscription ' + subscriptionId + ' does not exist. ';
            //START D-1683 1/22/2015 Added By C. Lin - Fixed error messages for Invalid Input. Add Error Code.
            response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            //END D-1683 1/22/2015 Added By C. Lin
        }       
        
        if(missingSubscriptionIdSet.size() > 0)
        {
            subscriptionList = null;
        }
        
        return subscriptionList;
    }
    // Added Order_Line_Item_Number_1__r.Main_Package_Billing_Type__c
    public static List<Zuora__Subscription__c> getAllSubscriptions(Id accountId, Id billingAccountId)
    {
        List<Zuora__Subscription__c> subscriptionList = [SELECT Id, Name, Zuora__Zuora_Id__c, Order_Number__c, Order_Line_Item_Number__c,Order_Line_Item_Number_1__r.Main_Package_Billing_Type__c, Zuora__CustomerAccount__r.Id, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Zuora__Account__r.Id, Contact__r.Id, Recipient_Contact__r.Id, Recipient_Contact__c FROM Zuora__Subscription__c WHERE Zuora__CustomerAccount__r.Id = :billingAccountId AND Zuora__Account__r.Id = :accountId];
                
        return subscriptionList;
    }
    
    public static List<Order__c> getOrders(Set<String> orderIdSet)
    {
        //START 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
        List<Order__c> orderList = [SELECT Id, Billing_Contact__c, Billing_Contact__r.Id, Recipient_Contact__r.Id, Billing_Contact__r.Address__r.Country_Name__c, Recipient_Contact__r.Address__r.Country__r.Code__c, Recipient_Contact__r.Address__c, Account__c, Remarks__c, Acquisition_Type__c, Recipient_Contact__c, Base_Subscription__c, Send_to_Retention__c, Eligible_for_Retention__c, Stop_Request_Date__c, Earliest_Stop_Date__c, Parent_Case__c FROM Order__c WHERE Id IN :orderIdSet];
        //END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
        
        return orderList;
    }
    // added Main_Package_Billing_Type__c field , AND Main_Package_Billing_Type__c != Null in SOQL //Krithika Dharmarajan 5/15/2015  Hot Fix
    public static List<Order_Line_Item__c> getOrderLineItems(String orderId)
    {
        List<Order_Line_Item__c> orderLineItemList = [SELECT Id, Order__r.Id,Main_Package_Billing_Type__c, Main_Package_ID__r.Id FROM Order_Line_Item__c WHERE Order__r.Id = :orderId AND Main_Package_Billing_Type__c != Null]; //START/END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
        
        return orderLineItemList;
    }
    // added Main_Package_Billing_Type__c field and AND Main_Package_Billing_Type__c != Null in SOQL //Krithika Dharmarajan 5/15/2015  Hot Fix
    public static List<Order_Line_Item__c> getOrderLineItems(Set<String> orderLineItemId)
    {
        List<Order_Line_Item__c> orderLineItemList = [SELECT Id, Order__r.Id,Main_Package_Billing_Type__c, Main_Package_ID__r.Id FROM Order_Line_Item__c WHERE Id IN :orderLineItemId AND Main_Package_Billing_Type__c != Null]; //START/END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
        
        
        return orderLineItemList;
    }
    
    public static List<Order_Line_Item_Gift__c> getOrderLineItemGifts(Set<String> orderLineItemId)
    {
        List<Order_Line_Item_Gift__c> orderLineItemGiftList = [SELECT Id, Order_Line_Item__c FROM Order_Line_Item_Gift__c WHERE Order_Line_Item__r.Id IN :orderLineItemId];
        
        return orderLineItemGiftList;
    }
    
    
    public static String getRenewalPackageCode(String packageCode)
    {
        String renewalPackageCode;
        //START D-4413 2.3.2106 Gdelrosario - Get Renewal Package Code from Package  object instead of Package Item object. 
        //START D-0821 1/8/2015 Added By C. Lin - Get Renewal Package Code from Package Item object instead of Package object. Only Newspaper and Magazine has Renewal Package Code.
        Id prodId;
        String zProductType;
        Boolean discounted = false;
        Id packId;
        String subPeriod;
        
        List<Package__c> packageList = [SELECT Id, Subscription_Period__c,RenewalPkgCodeNewspaper__c, RenewalPkgCodeMag1YrBase__c, RenewalPkgCodeMag1YrDisc__c, 
                                             RenewalPkgCodeMag2YrBase__c, RenewalPkgCodeMag2YrDisc__c, RenewalPkgCodeNewspaper__r.Package_Code__c, 
                                             RenewalPkgCodeMag1YrBase__r.Package_Code__c, RenewalPkgCodeMag1YrDisc__r.Package_Code__c, 
                                             RenewalPkgCodeMag2YrBase__r.Package_Code__c, RenewalPkgCodeMag2YrDisc__r.Package_Code__c
                                        FROM Package__c WHERE Package_Code__c = :packageCode];
        
        Map<id,Package__c> packMap = new Map<Id,Package__c>();

        for(Package__c pack : packageList){
            packId = pack.Id;
            subPeriod = pack.Subscription_Period__c;
            packMap.put(pack.Id,pack);
        }
        // START : UD-3048 11/11/2015 Alyana Navarro 
        List<Package_Item__c> packageItemList = [SELECT Id, Name, RecordTypeId, Product_Rate_Plan__r.zqu__ZProduct__c 
                                                        FROM Package_Item__c WHERE Package__c = :packId];
        
        for(Package_Item__c packageItem : packageItemList){
            if(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')){ 
                prodId = packageItem.Product_Rate_Plan__r.zqu__ZProduct__c;
            }
            
            if(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Discount') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Discount')){
                discounted = true;
            }
        }
        // END : UD-3048 11/11/2015 Alyana Navarro 
        
        List<zqu__ZProduct__c> productsList = [SELECT Id, Name, ProductSubType__c FROM zqu__ZProduct__c WHERE Id = : prodId];
        
        for(zqu__ZProduct__c product : productsList){
            zProductType = product.ProductSubType__c;
        }
        // START : UD-3048 11/11/2015 Alyana Navarro 
        if(discounted == false){
            for(Package_Item__c packageItem : packageItemList){
                if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Newspaper'){
                    renewalPackageCode = packMap.get(packageItem.Package__c).RenewalPkgCodeNewspaper__r.Package_Code__c;
                    //renewalPackageCode = packageItem.RenewalPkgCodeNewspaper__r.Package_Code__c;
                }else if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Magazine'){
                    if(subPeriod == '12'){
                        renewalPackageCode =  packMap.get(packageItem.Package__c).RenewalPkgCodeMag1YrBase__r.Package_Code__c;
                        //renewalPackageCode = packageItem.RenewalPkgCodeMag1YrBase__r.Package_Code__c;
                    }else if(subPeriod == '24'){
                        renewalPackageCode = packMap.get(packageItem.Package__c).RenewalPkgCodeMag2YrBase__r.Package_Code__c;
                        //renewalPackageCode = packageItem.RenewalPkgCodeMag2YrBase__r.Package_Code__c;
                    }
                }
            }
        }else{
            for(Package_Item__c packageItem : packageItemList){
                if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Magazine'){
                    if(subPeriod == '12'){
                        renewalPackageCode = packMap.get(packageItem.Package__c).RenewalPkgCodeMag1YrDisc__r.Package_Code__c;
                        //renewalPackageCode = packageItem.RenewalPkgCodeMag1YrDisc__r.Package_Code__c;
                    }else if(subPeriod == '24'){
                        renewalPackageCode = packMap.get(packageItem.Package__c).RenewalPkgCodeMag2YrDisc__r.Package_Code__c;
                        //renewalPackageCode = packageItem.RenewalPkgCodeMag2YrDisc__r.Package_Code__c;
                    }
                }
            }
        }
        // END : UD-3048 11/11/2015 Alyana Navarro 
        //END D-0821 1/8/2015 Added By C. Lin
        //END D-4413 2.3.2106 Gdelrosario - Get Renewal Package Code from Package  object instead of Package Item object. 
        return renewalPackageCode;
    }
    
    public static Zuora__CustomerAccount__c getBillingAccount(String billingAccountNumber)
    {
        Zuora__CustomerAccount__c billingAccount;
        List<Zuora__CustomerAccount__c> billingAccountList = [SELECT Id, Name, Zuora__Account__r.Id, Billing_Contact__r.Id, Billing_Contact__r.Billing_Indicator__c, Billing_Contact__r.Recipient_Indicator__c FROM Zuora__CustomerAccount__c WHERE Zuora__AccountNumber__c = :billingAccountNumber]; //START/END 04/16/2015 UD-0928 Kevin Evasco - Used Billing Account Number instead of Zuora Id
        if(billingAccountList.size() > 0)
        {
            billingAccount = billingAccountList.get(0);  
        }
        else
        {       
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            //START D-1683 1/22/2015 Added By C. Lin - Fixed error messages for Invalid Input.
            response.error_message += GlobalVariableClass.CAS_ERROR_MESSAGE_BILL_ACCOUNT_NUMBER + billingAccountNumber + '. ';
            response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            //END D-1683 1/22/2015 Added By C. Lin
        }
        
        return billingAccount;
    }

    //START UD-1050 28-Apr-2015 Added by Raviteja  - (Scenario 1) Created New Method to validate the Customer Account
     public static Zuora__CustomerAccount__c getCustomerAccount(String customerAccountNumber,String billingAccountNumber,List<String> subscriptions)
     {
        Zuora__CustomerAccount__c billingAccount;
        List<Zuora__CustomerAccount__c> billingAccountList = [SELECT Id, Name, Zuora__Account__r.Id, Billing_Contact__r.Id, Billing_Contact__r.Billing_Indicator__c, Billing_Contact__r.Recipient_Indicator__c,Zuora__Account__r.AccountNumber FROM Zuora__CustomerAccount__c WHERE Zuora__AccountNumber__c = :billingAccountNumber AND Zuora__Account__r.AccountNumber =:customerAccountNumber]; 
        system.debug('=================>'+billingAccountList);
        //START UD-1050 29-Apr-2015 Added by Raviteja - Applying if Condition for SOQL
        //List<Zuora__Subscription__c> subscriptionList = [SELECT Id, Name, Zuora__Account__r.AccountNumber, Zuora__External_Id__c FROM Zuora__Subscription__c WHERE Zuora__External_Id__c IN :subscriptions AND Zuora__Account__r.AccountNumber =:customerAccountNumber]; 
        List<Zuora__Subscription__c> subscriptionList = New List<Zuora__Subscription__c>();   
       
        if(subscriptions.size() > 0){      
        subscriptionList = [SELECT Id, Name, Zuora__Account__r.AccountNumber, Zuora__External_Id__c FROM Zuora__Subscription__c WHERE Zuora__External_Id__c IN :subscriptions AND Zuora__Account__r.AccountNumber =:customerAccountNumber AND Zuora__CustomerAccount__r.Zuora__AccountNumber__c = :billingAccountNumber];  //UD-1172 KRITHIKA DHARMARJAN START-END         
        system.debug('===============>'+subscriptionList);
        }
        //End UD-1050 29-Apr-2015 Added by Raviteja     
        //START UD-1050 29-Apr-2015 Added by Raviteja - Udpated the logic for Eshop to allow blank subscriptions
        //if(billingAccountList.size() > 0 && ( subscriptionList.size() >0 && subscriptionList.size() == subscriptions.size() ) )
        if(billingAccountList.size() > 0 && subscriptionList.size() == subscriptions.size()  )
        //End UD-1050 29-Apr-2015 Added by Raviteja
        {
            billingAccount = billingAccountList.get(0);  
        }
        else
        {       
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;                     
            response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            if(!(billingAccountList.size()>0)){
             response.error_message += GlobalVariableClass.CAS_ERROR_MESSAGE_BILL_ACCOUNT + customerAccountNumber + '. ';
            }
            //START UD-1050 29-Apr-2015 Added by Raviteja - Udpated the logic for Eshop to allow blank subscriptions
            //if(!(subscriptionList.size()>0) && subscriptionList.size() != subscriptions.size() ){
            if(subscriptionList.size() != subscriptions.size() ){
             //End UD-1050 29-Apr-2015 Added by Raviteja
             response.error_message += GlobalVariableClass.CAS_ERROR_MESSAGE_SUBSCRIPTION + customerAccountNumber + '. ';
            }
        }
        return billingAccount;
    }
    //End UD-1050 28-Apr-2015 Added by Raviteja - (Scenario 1)
    
    public static Account getAccount(String accountNumber)
    {
        Account accountRecord;
        List<Account> accountList = [SELECT Id FROM Account WHERE Account_Auto_Number__c =: accountNumber];
        if(accountList.size() > 0)
        {
            accountRecord = accountList.get(0);
        }
        //START D-1683 1/21/2015 Added By C. Lin - Fixed error messages for Invalid Input.
        else
        {       
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_message += GlobalVariableClass.CAS_ERROR_MESSAGE_ACCOUNT_NUMBER + accountNumber + '. ';
            response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
        }
        //END D-1683 1/21/2015 Added By C. Lin
        
        return accountRecord;
    }
    
    public static Contact getContact(String contactId)
    {
        Contact contactRecord;
        List<Contact> contactList = [SELECT Id FROM Contact WHERE Id =: contactId];
        if(contactList.size() > 0)
        {
            contactRecord = contactList.get(0);
        }
    
        return contactRecord;
    }
    
    public static Country__c getCountry(String countryCode)
    {
        Country__c countryRecord;
        List<Country__c> countryList = [SELECT Id FROM Country__c WHERE Country_Name__c = :countryCode]; //START/END 04/16/2015 UD-0928 Kevin Evasco - Use Country Name instead of country code
        if(countryList.size() > 0)
        {
            countryRecord = countryList.get(0);
        }
        else
        {       
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            //START D-1683 1/21/2015 Added By C. Lin - Fixed error messages for Invalid Input.
            response.error_message += GlobalVariableClass.CAS_ERROR_MESSAGE_COUNTRY + countryCode + '. ';
            response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            //END D-1683 1/21/2015 Added By C. Lin
        }
        
        return countryRecord;
    }   
    
    // Start D-1766 01/23/2015 JohnD modify the method adding validation on building name
    public static Singpost_Address__c getSingpostAddress(String postalCode,String levelNumber,String streetName,String unitNumber,String blockNumber,String buildingName)
    {

        Singpost_Address__c singpostAddressRecord;
        List<Singpost_Address__c> singpostAddressList = new list<Singpost_Address__c>();
        
        if (postalCode != null) {
        
           
            system.debug('building name from request============>'+buildingName);
            
            singpostAddressList = [SELECT Id, Building_Name__c,House_Block_Number__c,Floor__c,Unit__c,Street_Name__c FROM Singpost_Address__c WHERE Name = :postalCode limit 1];
                    
            if (singpostAddressList.size() > 0) {
                
                singpostAddressRecord = singpostAddressList.get(0);
                 system.debug('building name=========>'+singpostAddressRecord.Building_Name__c);
                 //UD-1172 KRITHIKA DHARMARAJAN START
                if(buildingName == '' || buildingName == ' ') {
                        buildingName = null ;
                }
                //UD-1172 KRITHIKA DHARMARAJAN END 
                if (buildingName != singpostAddressRecord.Building_Name__c) { //UD-1172 KRITHIKA DHARMARAJAN START-END 
                    
                    response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                    response.error_code = 'EXES0019';
                    response.error_message += OnlineExceptions.getErrorMessage('EXES0019');
                    singpostAddressRecord = null; //START/END UD-1050 28-Apr-2015 Added by Raviteja - (Scenario 2) Assigning Null value into singpostAddressRecord.
                    
                }
                
            } else {
                
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_message += GlobalVariableClass.CAS_ERROR_MESSAGE_SINGPOST + postalCode + '. ';
                response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
                
            }
        
        } else {
            
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            //START D-1683 1/21/2015 Added By C. Lin - Fixed error messages for Invalid Input.
            response.error_message += GlobalVariableClass.CAS_ERROR_MESSAGE_SINGPOST + postalCode + '. ';
            response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            //END D-1683 1/21/2015 Added By C. Lin
        }
        
        return singpostAddressRecord;
    }
    // End D-1766 01/23/2015 JohnD
    
    
    public static Address__c getAddress(ChangeAddressServiceRequest request, Id countryId, Id postalCodeId)
    {
        Address__c addressRecord;  
        List<Address__c> addressList;
        if(request.country == singaporeName) //START/END 04/16/2015 UD-0928 Kevin Evasco - Use Country Name instead of country code
        {
            addressList = [SELECT Id, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Country_Name__c = :request.country AND Postal_Code__r.Name = :request.postalCode AND Unit_Number__c = :request.unitNumber AND Level_Number__c =:request.levelNumber]; //START/END 04/16/2015 UD-0928 Kevin Evasco - Use Country Name instead of country code
            system.debug('===================addressrecordwithunitnum'+addressList);
        }
        else
        {
            addressList = [SELECT Id, Postal_Code__r.Name, Country_Name__c, Country__r.Code__c FROM Address__c WHERE Country__r.Country_Name__c = :request.country AND Address_1__c = :request.Address1 AND Address_2__c = :request.Address2 AND Address_3__c = :request.Address3 AND Address_4__c = :request.Address4]; //START/END 04/16/2015 UD-0928 Kevin Evasco - Use Country Name instead of country code
            system.debug('===================addressrecordwithunitnum'+addressList);
        }
        
        if(addressList.size() > 0)
        {
            addressRecord = addressList.get(0);
            system.debug('picking current address record');
        }
        else
        {
            system.debug('creating new address record');
            Address__c newAddress = new Address__c();
            newAddress.Country__c = countryId;          
            
            if(request.country == singaporeName) //START/END 04/16/2015 UD-0928 Kevin Evasco - Use Country Name instead of country code
            {
                newAddress.Postal_Code__c = postalCodeId;
                newAddress.Block_House_Number__c = request.blockNumber;
                newAddress.Level_Number__c = request.levelNumber;
                //newAddress.Street_Name__c = request.streetName; 
                //newAddress.Building_Name__c = request.buildingName;
                newAddress.Unit_Number__c = request.unitNumber;
                newAddress.RecordTypeId = ConstantsSLB.getkeyid('Address_Local');            
            }
            else
            {
                newAddress.Address_1__c = request.Address1;
                newAddress.Address_2__c = request.Address2;
                newAddress.Address_3__c = request.Address3;
                newAddress.Address_4__c = request.Address4;
                newAddress.RecordTypeId = ConstantsSLB.getkeyid('Address_Overseas');
            }           
            
            insert newAddress;
            addressRecord = newAddress;
        }               
        
        return addressRecord;
    }
    
    public static Case createCase(Id accountId, Contact contactRecord, ChangeAddressServiceRequest request, String caller, Case parentCase)
    {       
        Case caseRecord = new Case();
        caseRecord.RecordTypeId = ConstantsSLB.getKeyId('Case_Change in Address');
        caseRecord.AccountId = accountId;
        caseRecord.ContactId = contactRecord.Id;
        caseRecord.Category__c = 'Subscription Request';
        caseRecord.Sub_Category__c = 'Change of Address';
        
        if(caller == 'Billing Contact')
        {           
            if(request.billingIndicator == 'Y' && request.deliveryIndicator == 'Y')
            {
                caseRecord.Change_of_Address_Type__c = 'Change of Billing and Delivery Address';
            }
            else if(request.billingIndicator == 'Y')
            {
                caseRecord.Change_of_Address_Type__c = 'Change of Billing Address';
            }           
        }
        else
        {
            Boolean sourceIsOverseas = false;
            if(contactRecord.Address__r.Country_Name__c != singaporeName) //START/END 04/16/2015 UD-0928 Kevin Evasco - Use Country Name instead of country code
            {
                sourceIsOverseas = true;
            }
            
            if(sourceIsOverseas == false && request.country == singaporeName) //START/END 04/16/2015 UD-0928 Kevin Evasco - Use Country Name instead of country code
            {               
                caseRecord.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local';
            }
                        
            if(sourceIsOverseas == false && request.country != singaporeName) //START/END 04/16/2015 UD-0928 Kevin Evasco - Use Country Name instead of country code
            {               
                caseRecord.Change_of_Address_Type__c = 'Change of Delivery address - Local to Overseas';
            }
                        
            if(sourceIsOverseas == true && request.country != singaporeName) //START/END 04/16/2015 UD-0928 Kevin Evasco - Use Country Name instead of country code
            {               
                caseRecord.Change_of_Address_Type__c = 'Change of Delivery Address - Overseas to Overseas';
            }
                        
            if(sourceIsOverseas == true && request.country == singaporeName) //START/END 04/16/2015 UD-0928 Kevin Evasco - Use Country Name instead of country code
            {               
                caseRecord.Change_of_Address_Type__c = 'Change of Delivery address - Overseas to Local';
            }
        }
        
        caseRecord.Origin = 'Eshop/Ecomz';
        caseRecord.Creation_Mode_picklist__c= 'Eshop/Ecomz';
        caseRecord.Priority = 'Medium';
        caseRecord.Status = 'New';
        caseRecord.Effective_Date__c = DateUtility.convertDate(request.effectiveDate,'/','MDY');
        
        if(parentCase != null)
        {
            caseRecord.ParentId = parentCase.Id;
        }
        
        return caseRecord;
    }
    
    public static boolean validateMandatoryFields(ChangeAddressServiceRequest request)
    {
        boolean result = true;
        
        if(request.customerAccountNumber == null || request.customerAccountNumber == '')
        {
            result = false;
            response.error_message += 'Customer Account Number is mandatory. ';
        }
        
        if(request.billingAccountNumber == null || request.billingAccountNumber == '')
        {
            result = false;
            response.error_message += 'Billing Account ID is mandatory. ';
        }
        /*
        if(request.subscriptions == null || request.subscriptions.size() == 0)
        {
            result = false;
            response.error_message += 'Subscription ID is mandatory. ';
        }*/
        
        if(request.country == null || request.country == '')
        {
            result = false;
            response.error_message += 'Country is mandatory. ';
        }       
        //START 01/28/2015 D-1775 Kevin Evasco Updated mandatory field validation
        if(request.country == singaporeName) //START/END 04/16/2015 UD-0928 Kevin Evasco - Use Country Name instead of country code
        {
            if(request.postalCode == null || request.postalCode == '')
            {
                result = false;
                response.error_message += GlobalVariableClass.ESHOP_COA_Mandatory_PostalCode;
                response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            }       
            
            if(request.blockNumber == null || request.blockNumber == '')
            {
                result = false;
                response.error_message += GlobalVariableClass.ESHOP_COA_Mandatory_BlockNumber;
                response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            }   
            
            if(request.levelNumber == null || request.levelNumber == '')
            {
                result = false;
                response.error_message += GlobalVariableClass.ESHOP_COA_Mandatory_LevelNumber;
                response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            }   
            
            if(request.streetName == null || request.streetName == '')
            {
                result = false;
                response.error_message += GlobalVariableClass.ESHOP_COA_Mandatory_StreetName;
                response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            }   
           // UD-1172 START KRITHIKA DHARMARAJAN BUILDING NAME MADE NOT MANDATORY
           // if(request.buildingName == null || request.buildingName == '')
           // {
           //     result = false;
           //     response.error_message += GlobalVariableClass.ESHOP_COA_Mandatory_BuildingName;
           //     response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
           //  }   
           // UD-1172 END KRITHIKA DHARMARAJAN BUILDING NAME MADE NOT MANDATORY
            if(request.unitNumber == null || request.unitNumber == '')
            {
                result = false;
                //START D-1778 1/21/2015 Added By C. Lin - Change error message to Unit Number instead of Building Name.
                //response.error_message += 'Unit Number is mandatory. ';
                response.error_message += GlobalVariableClass.ESHOP_COA_Mandatory_UnitNumber;
                response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
                //END D-1778 1/21/2015 Added By C. Lin
            }
        }
        else
        {
            if(request.Address1 == null || request.Address1 == '')
            {
                result = false;
                response.error_message += GlobalVariableClass.ESHOP_COA_Mandatory_Address1;
                response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            }
        }
        //END 01/28/2015 D-1775 Kevin Evasco Updated mandatory field validation
                
        if((request.billingIndicator == null || request.billingIndicator == '') &&
            (request.deliveryIndicator == null || request.deliveryIndicator == ''))
        {
            result = false;
            response.error_message += 'Please provide billing/delivery indicator. ';
        }   
        Date requestDate = NewSubscriptionService.convertDate(request.effectiveDate);// KRITHIKA DHARMARAJAN UD-1172 START-END
        system.debug('===============requestdate'+requestDate);
        system.debug(Date.Today());
        if(request.effectiveDate == null || request.effectiveDate == '' || requestDate <= Date.Today()) // KRITHIKA DHARMARAJANUD-1172 START-END
        {
            result = false;
            response.error_message += 'Effective Date is mandatory and Effective date must be greater than current date.  ';
        }   
        
        return result;
    }
    
    //START 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
    public static Map<Id,Date> getEarliestStartDateMap(Set<Id> packageIdSet, Map<Id,List<Package_Item__c>> package_packageItemMap,
        Map<Id,zqu__ProductRatePlan__c> productRatePlanMap, Map<Id,List<Product_Publication__c>> product_productPublicationMap)
    {
        List<Package__c> packageList = new List<Package__c>();
        List<Package_Item__c> packageItemList = new List<Package_Item__c>();
        List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c>();
        List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        List<zqu__ZProduct__c> productList = new List<zqu__ZProduct__c>();
        List<Product_Publication__c> productPublicationList = new List<Product_Publication__c>();

        Set<Id> packageItemIdSet = new Set<Id>(); 
        Set<Id> productRatePlanIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();

        Map<Id,Package__c> packageMap = new Map<Id,Package__c>();
        Map<Id,List<zqu__ProductRatePlanCharge__c>> productRatePlan_productRatePlanChargeMap = new Map<Id,List<zqu__ProductRatePlanCharge__c>>();
        Map<Id,zqu__ZProduct__c> productMap = new Map<Id,zqu__ZProduct__c>();
        Map<Id,List<Product_Publication__c>> package_productPublicationMap = new Map<Id,List<Product_Publication__c>>();

        packageList = [SELECT Id, Billing_Type__c, Package_Sub_Type__c, Package_Type__c, Subscription_Period__c, Subscription_Type__c
                        FROM Package__c WHERE Id IN :packageIdSet];
        for(Package__c packageRecord : packageList)
        {
            packageMap.put(packageRecord.Id, packageRecord);            
        }    

        packageItemList = [SELECT Id, Package__r.Id, Package__r.Billing_Type__c, Billing_Type__c, Product_Rate_Plan__r.Id, Product_Rate_Plan__r.zqu__ZProduct__r.Id, Is_Newspaper__c, Is_Magazine__c FROM Package_Item__c WHERE Package__c IN :packageIdSet];

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

        Map<Id,Date> earliestStartDateMap = NewSubscriptionService.getEarliestStartDateMap(package_productPublicationMap);
            
        return earliestStartDateMap;
    }
    //END 01/29/2015 D-1776, D-1777 Kevin Evasco Updated to include case creation for stop and start subscription
}

/***************** SAMPLE JSON REQUEST:
URL: /services/apexrest/ChangeAddressService/v29.0

{
    "request" :
    {
        "customerAccountNumber" : "30075168",
        "billingAccountNumber" : "2c92c0f8491452d8014931eb7fac1ec8",
        "subscriptions" : ["2c92c0f849369b8701494836b25c4c6d","2c92c0f849369b8801493c75861606e7"],
        "country" : "SIN",
        "postalCode" : "088271",
        "blockNumber" : "60",   
        "levelNumber" : "71",
        "streetName" : "Vin Street",
        "buildingName" : "Vin Building",
        "unitNumber" : "77",
        "Address1" : "",
        "Address2" : "",
        "Address3" : "",
        "Address4" : "",
        "billingIndicator" : "Y",
        "deliveryIndicator" : "Y",
        "effectiveDate" : "10/30/2014"
    }
}

**************************************/