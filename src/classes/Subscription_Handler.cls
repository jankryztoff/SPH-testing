/**
 * History: 08/Jan/2015 D-1592 Wenjun : Order Postage Charge Field Change
 * History: 02/Jul/2015 MD-28 Wenjun: Remove Wrong Logic - Invoice Processing for Full Prepaid
*/
public class Subscription_Handler {

    //[JohnD 9/26] added to be used in renewal
    public string origin = ''; //START/END 05/15/2015 D-3024 Kevin Evasco - ESHOP Hotfix 
    Public String zBillingAccountId;//START/END 04/20/2015 D-2743 Kevin Evasco - For New Subscription Paypal Payment
    
    //ORDER MUST HAVE THESE FOLLOWING FIELDS:
        // id, name, Recipient_Type__c, FP_Del_Usage__c,Account__c, Subscription_Start_Date__c, 
        // Payment_Mode__c, Billing_Contact__c, Recipient_Contact__c, Payment_Method_ID__c,
        // Subscriber_Charge__c, Delivery_Charge_Type__c, Recipient_Address__c

    public void Subscription_Handler_Direct(Order__c SOrder){
        
        list<Order__c> lOrder = new list<Order__c>();
        //START 01/08/15 D-1592 Wenjun - Postage Charges : Postage Fields Change
        //START 01/23/15 D-1802 Jerella - Request_for_Waiving_of_Admin_Charge and Admin_Charge fields added on query
        // Start D-2005 02/08/2015 JohnD added No_Vendor_Needed__c field
        //START/END D-2003 D-1977 02/11/2015 FrancisBenzon added Urgent_Stop__c, isWaive__c, Delivery_Charge__c field
        lOrder = [SELECT Request_for_Waiving_of_Admin_Charge__c, Admin_Charge__c, Id, Name, Account__c, Remarks__c, Parent_Case__c, Acquisition_Type__c, Recipient_Contact__c, Recipient_Contact__r.Address__c, Base_Subscription__c,
                  PO_Number__c, Total_Monthly_Postage_Charge__c, Total_Postage_Charge__c, Billing_Contact__c, Reason_Code__c, Creation_Mode__c, Order_Action__c, Delivery_Charge__c, 
                  Effective_Date__c, Subscription__c, Recipient_Type__c, Debt_Management_Treatment__c, Other_Payment_Mode__c, No_Vendor_Needed__c, Urgent_Stop__c, isWaive__c 
                  FROM Order__c WHERE id =: SOrder.Id];
        // End D-2005 02/08/2015 JohnD
        //END 01/23/15 D-1802 Jerella - Request_for_Waiving_of_Admin_Charge and Admin_Charge fields added on query
        //END 01/08/15 D-1592 Wenjun - Postage Charges
        //lOrder.add(SOrder);
        //START UD-1349 05/25/15 RReyes - sets value of origin if null
        if(origin == null){
            origin = 'Start Subscription';
        }
        //END UD-1349 05/25/15 RReyes - sets value of origin if null

        //START D-3423 Wenjun 27 Aug 15: All assignment logic will be in Vendor Assignment
        //Create Case
        list<Case> lCase = new list<Case>();
        createCase c = new createCase();
        system.debug(':::ORIGIN4 ' + origin);
        if (origin == 'Renewal of Subscription' || origin == 'ESHOP Renewal of Subscription')
            lCase = c.createCaseRenewal(lOrder, true);
        else if (origin.contains(GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION))
        {
            system.debug(':::CREATECASEFORCOS');
            lCase = c.createCaseForChangeOfSubscription(lOrder, true);
        }       
        else if (origin.contains('ESHOP') == false)
            lCase = c.createCase2(lOrder,true);
        
        // Assign Vendor / Mailing Agent  
        //START PD-0422 AddedBy KatherinePunzalan : added Vendor Value for Mailing Agent Renewal Subs -->
        List<Order_Line_Item__c> lOrderLineItems = [SELECT Id, Delivered_By__c, Recipient_Postal_Code__c, Vendor_Mailing_Agent__c, 
                        Main_Package_Product_Platform__c, Order__r.Recipient_Contact__r.Address__r.Recordtype.DeveloperName, 
                        Case__r.Subscription_Name__c, Case__r.Subscription_Name__r.Delivered_By_1__c, Case__r.Subscription_Name__r.Vendor_1__c,
                        Order__r.Base_Subscription__r.Vendor_1__c, Order__r.Order_Type__c
                        FROM Order_Line_Item__c where Order__c =: SOrder.Id];
        //END PD-0422 AddedBy KatherinePunzalan : added Vendor Value for Mailing Agent Renewal Subs -->
        Vendor_Assignment vendorAssignment = new Vendor_Assignment();
        vendorAssignment.Assign_Vendor_To_Order_line_Items(lOrderLineItems);
        //END D-3423 Wenjun 27 Aug 15
        
        //Get Order the is not urgent
        list<Order__c> lOrderToCreate = new list<Order__c>();
        lOrderToCreate = OrderToCreate(lOrder);
        map<Id, Order__c> mOrder = new map<Id, Order__c>();
        mOrder.putAll(lOrder);       
        
    //FrancisBenzon Debugs for UD-3337
    system.debug(':::ORIGIN ' + origin);
    //FrancisBenzon Debugs for UD-3337
    
        //Create Order the is not urgent
        //START UD-1595 AddedBy Fritz/Jeff : call Queuable class for COS
        if(origin != GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION)
        { 
      //FrancisBenzon Debugs for UD-3337
      system.debug(':::ORDERS ' + lOrderToCreate.size());
      //FrancisBenzon Debugs for UD-3337
            if(lOrderToCreate.size()>0 || origin.contains('ESHOP')){ //START/END 05/15/2015 D-3024 Kevin Evasco - ESHOP Hotfix 
                CreateQuotes(SOrder,origin);
            }
        }
             
        //END UD-1595 AddedBy Fritz/Jeff : call Queuable class for COS
    }
    
    public void CreateQuotes(Order__c SOrder,String origin){
    
            list<Id> lQuoteIds = new list<Id>();
            list<Id> lQuoteIds2 = new list<Id>();
            //list<zqu__QuoteCharge__c> lQuoteCharges = new list<zqu__QuoteCharge__c>();    
            
            string PaymentMode = '';
            string PaymentModeOther = '';
            string sDeliveryChargeType= '';
            boolean bCreateNewBillingAccount  = false;
            boolean bCreateDeliverySubscription=false;
            boolean bPayDeliveryChargeNow = false;
            ID ExistingDeliverySubscriptionId; 
            ID SFBillingAccount;
            string zBillingAccount;
            decimal SubscriberCharge = 0;
            ID AccountId;
            decimal DeliveryFPSubscriptionUsage;
            string CCPaymentMethodId; 
            
            //Start UD-678 VPernicia/MGatchalian 4/06/2015            
            list<id> lstofOrderLine = new list<id>();
            
            for (Order_Line_Item__c OliList: [select id, Main_Package_Billing_Type__c, (select id from Order_Line_Item_Gifts__r) from Order_Line_Item__c where Order__c =: SOrder.id]) {
                lstofOrderLine.add(OliList.id);
                
                for (Order_Line_Item_Gift__c OliGiftList: OliList.Order_Line_Item_Gifts__r) {
                    lstofOrderLine.add(OliGiftList.id);
                }
                
                if(OliList.Main_Package_Billing_Type__c == 'Full Prepaid') {
                    bPayDeliveryChargeNow = true;
                }
            }
            
            for (zqu__Quote__c QuoteList: [select id from zqu__Quote__c where Order_Line_Item_Number_1__c in: lstofOrderLine]) {
                lQuoteIds.add(QuoteList.id);
            }
            
            if(SOrder.Billing_Account_Creation_Mode__c == 'Create New Billing Account'){
                System.debug('CREATE NEW BILLING ACCOUNT');
                bCreateNewBillingAccount = true;

                //START D-2759 Wenjun 13/04/15 - Convert Billing Type
                //START UD-1595 move dml statement to queuable class for COS to allow synchronous sent to z-billing
                if(SOrder.Billing_Type__c != null && origin != 'Change of Subscription')
                {
                    Account accToUpd = new Account(Id = SOrder.Account__c);
                    //START D-3159 and D-3160 02-July-2015 Added by Raviteja - Implementing New Splitting Billing Type Scenario - Commented existing mapping
                    accToUpd.Billing_Type__c = SOrder.Billing_Type__c;
                    //End D-3159 and D-3160 02-July-2015 Added by Raviteja  
                    UPDATE accToUpd;
                }
                //END UD-1595 move dml statement to queuable class for COS to allow synchronous sent to z-billing
                //END D-2759 Wenjun 13/04/15
            }else{
                System.debug('DO NOT CREATE NEW BILLING ACCOUNT');
                bCreateNewBillingAccount = false;
                //START 04/20/2015 D-2743 Kevin Evasco - For New Subscription Paypal Payment
                if(zBillingAccountId != null)
                {
                    sfBillingAccount = null;
                    zBillingAccount = zBillingAccountId;
                }
                else
                {
                    sfBillingAccount = SOrder.Billing_Account__c;
                    zBillingAccount = SOrder.Billing_Account__r.Zuora__External_Id__c;
                }
                //END 04/20/2015 D-2743 Kevin Evasco - For New Subscription Paypal Payment
            }
            
            SubscriberCharge = SOrder.Subscriber_Charge__c;
            PaymentMode = SOrder.Payment_Mode__c;
            PaymentModeOther = SOrder.Other_Payment_Mode__c;
            sDeliveryChargeType = SOrder.Delivery_Charge_Type__c;    
            bCreateDeliverySubscription = true;//Quote_Handler_POC.bCreateDeliverySubscription;
            AccountId = SOrder.Account__c;
            DeliveryFPSubscriptionUsage = SOrder.FP_Del_Usage__c;
            CCPaymentMethodId = SOrder.Payment_Method_ID__c;
            //End UD-678 VPernicia/MGatchalian 4/06/2015
            
            
            //START 05/15/2015 D-3024 Kevin Evasco - ESHOP Hotfix 
            if(origin.contains('ESHOP'))
            {
                SendQuotesToZuoraBatch sendQuotesToZuoraBatch = new SendQuotesToZuoraBatch(lQuoteIds, PaymentMode, PaymentModeOther, sDeliveryChargeType, 
                                    bCreateNewBillingAccount, bCreateDeliverySubscription, bPayDeliveryChargeNow, 
                                    ExistingDeliverySubscriptionId, SFBillingAccount, zBillingAccount, SubscriberCharge,
                                    AccountId, SOrder.Id, DeliveryFPSubscriptionUsage, CCPaymentMethodId);
                //START PD-0250 For Test Class 06152016
                if(!Test.isRunningTest()){
                    Database.executeBatch(sendQuotesToZuoraBatch,1); //START/END 04/20/2015 D-2743 Kevin Evasco - Set batch size to 1
                }
                //END PD-0250 For Test Class 06152016
           }
            /*else if(origin == 'Change of Subscription') {
                SendQuotesToZuora2 zSendQuote = new SendQuotesToZuora2();    
                zSendQuote.NonFutureSendQuoteToZBilling(lQuoteIds, PaymentMode, PaymentModeOther, sDeliveryChargeType, 
                                    bCreateNewBillingAccount, bCreateDeliverySubscription, bPayDeliveryChargeNow, 
                                    ExistingDeliverySubscriptionId, SFBillingAccount, zBillingAccount, SubscriberCharge,
                                    AccountId, SOrder.Id, DeliveryFPSubscriptionUsage, CCPaymentMethodId);
            }*/
            else
            {
      system.debug(':::SENDINGQUOTES');
            SendCreatedQuoteToZuora(lQuoteIds, PaymentMode, PaymentModeOther, sDeliveryChargeType, 
                                    bCreateNewBillingAccount, bCreateDeliverySubscription, bPayDeliveryChargeNow, 
                                    ExistingDeliverySubscriptionId, SFBillingAccount, zBillingAccount, SubscriberCharge,
                                    AccountId, SOrder.Id, DeliveryFPSubscriptionUsage, CCPaymentMethodId);
               
             
            }
            //END 05/15/2015 D-3024 Kevin Evasco - ESHOP Hotfix 
        /*TimeZone Implications
        */
        
        //START MD-28 02/Jul/2015 Wenjun: Remove Wrong Logic - Invoice Processing for Full Prepaid
        //START: D-1355 01/06/15 Added by ABanaag
        /*
        List<Order__c> orders = [SELECT ID, Billing_Type__c FROM Order__c where id =: sorder.id];
        if(orders.size()>0){
            string billingType = orders[0].Billing_Type__c;
            
            if (billingType == 'Full Prepaid') {
                invoicePaymentProcess(SOrder, lQuoteIds); 
            }
        }
        
        else {
            ApexPages.Message error= new ApexPages.Message(ApexPages.Severity.Warning,'No order found. No quote will be created.');
            ApexPages.addMessage(error);
        }
        //END: D-1355 01/06/15 Added by ABanaag
        */
        //END MD-28 02/Jul/2015 Wenjun
    }
    
    public void SendCreatedQuoteToZuora(list<Id> lQuoteIds,string PaymentMode, string PaymentModeOther, string sDeliveryChargeType,
                                        boolean bCreateNewBillingAccount, boolean bCreateDeliverySubscription, boolean bPayDeliveryChargeNow,
                                        ID ExistingDeliverySubscriptionId, ID SFBillingAccount, string zBillingAccount, decimal SubscriberCharge,
                                        ID AccountId, ID OrderId, decimal DeliveryFPSubscriptionUsage, string CCPaymentMethodI){
            
            //START UD-1595 6/23/15 AddedBy FBenzon/JTeves - make sendtozbilling callout a synch process
            if(origin == 'Change of Subscription')
            {
        system.debug(':::SENDQUOTESCALLOUT');
                SendQuotesToZuora2.performCallout(lQuoteIds, PaymentMode, PaymentModeOther, sDeliveryChargeType, 
                                    bCreateNewBillingAccount, bCreateDeliverySubscription, bPayDeliveryChargeNow, 
                                    ExistingDeliverySubscriptionId, SFBillingAccount, zBillingAccount, SubscriberCharge,
                                    AccountId, OrderId, DeliveryFPSubscriptionUsage, CCPaymentMethodI);
            }
            else {
                SendQuotesToZuora2 zSendQuote = new SendQuotesToZuora2();
                zSendQuote.RecievedData(lQuoteIds, PaymentMode, PaymentModeOther, sDeliveryChargeType, 
                                        bCreateNewBillingAccount, bCreateDeliverySubscription, bPayDeliveryChargeNow, 
                                        ExistingDeliverySubscriptionId, SFBillingAccount, zBillingAccount, SubscriberCharge,
                                        AccountId, OrderId, DeliveryFPSubscriptionUsage, CCPaymentMethodI); //Fritz origin
            }
            //END UD-1595 6/23/15 AddedBy FBenzon/JTeves - make sendtozbilling callout a synch process
            
    }
    
       
    public list<Order__c> OrderToCreate(list<Order__c> lOrder){
        //Create Quote if Case is not Urgent
        list<Order__c> lOrderToCreate = new list<Order__c>();
        set<ID> sOrderToCreateQuote = new set<ID>();
        set<id> sOrderID = (new Map<Id,SObject>(lOrder)).keySet();
        list<Case> lCase = new list<Case>([Select Id, Status, Sub_Status__c, Order__c from Case where Order__c in: sOrderID]);
        
        for(Case cas:lCase){
      system.debug(':::CASESUBSTAT ' + cas.Sub_Status__c +  ' ' + GlobalVariableClass.SUB_STATUS_PROVISIONING);
            if (cas.Sub_Status__c == GlobalVariableClass.SUB_STATUS_PROVISIONING){
                sOrderToCreateQuote.add(cas.Order__c);        
            }
        }
        system.debug(':::LORDERTOCREATE ' + sOrderToCreateQuote.size());
    system.debug(':::LORDERS ' + lOrder);
        if(sOrderToCreateQuote.size()>0){
            for(Order__c o:lOrder){
                if (sOrderToCreateQuote.contains(o.Id)){
                    lOrderToCreate.add(o);
                }
            }
        }
        
        return lOrderToCreate;
        
    }
     //START MD-28 02/Jul/2015 Wenjun: Remove Wrong Logic & Redundant Codes
    /*  
    //Update the correct field of the subscription upon sync from Zuora
    public void Update_Subscription_Orig_Fields(list<Zuora__Subscription__c> lSub){
        
        //map<id, id> orderId_recipientId = new map<id, id>();
        //map<id, id> orderId_billingContactId = new map<id, id>();
        //map<id, Order__c> orderId_order = new map<id, Order__c>();
        set<id> orderIds = new set<id>();
        Map<Id, Id> orderAndSubMap = new Map<Id, Id>(); //START/END D-0810 Added By: FrancisBenzon Map needed
        Map<Id, Integer> orderGracePeriodMap = new Map<Id, Integer>(); //START/END D-0810 Added By: FrancisBenzon Map needed
        // [JohnD 12/12] D-1185 variable declaration
        boolean isChangeOfQuantity = false; 
        map<string, string> zuoraSubscriptionId_quantity = new map<string, string>();
        // end D-1185
        
        //2324
        for (Zuora__Subscription__c sub : lSub) {
            if (sub.Order_Number__c != null) {               
                orderIds.add((id)sub.Order_Number__c);              
            }
        }//2324
        
        // [JohnD 12/10] D-0636
        // added Classification, Sub_Classifcation and Reason_Code fields in the query
        //Charles 11/19 For Generate Invoice, Term is discussed
        //START 01/08/15 D-1592 Wenjun - Postage Charges : Remove field Order.Postage_Charge__c
        // Start D-2005 02/08/2015 JohnD added Vendor_Mailing_Agent__c
        //START D-2003, 1977, 0726 AddedBy FrancisBenzon/April Banaag 2/13/15 : Added Main_Package_Subscription_Rate__c in query to prevent error
        Map <Id, Order_Line_Item__c> orderLineItemId_orderLineItem = new Map<Id, Order_Line_Item__c>([SELECT Id, Generate_Invoice__c, Main_Package_Billing_Type__c,
            Term_is_discussed__c, Order__c,  Order__r.Recipient_Contact__c, Order__r.Billing_Contact__c, Promotion_ID__c,
            Order__r.PO_Number__c, Main_Package_Subscription_Rate__c, Classification__c, Sub_Classification__c, Reason_Code__c, Qty__c, Postage_Charge__c, Vendor_Mailing_Agent__c   
            FROM Order_Line_Item__c WHERE Order__c IN:orderIds]);
        //END D-2003, 1977, 0726 AddedBy FrancisBenzon/April Banaag 2/13/15 : Added Delivery_Charge__c in query to prevent error
        // End D-2005 02/08/2005 JohnD
        //END 01/08/15 D-1592 Wenjun - Postage Charges
        // end D-0636
                
        // [JohnD 12/12] D-1185
        // added for change of subscription quantity where the order and order line item associated
        // to the amended subscription will be replaced by the new order and new order line item
        map<id, Order_Line_Item__c> oldOrderLineItemId_newOrderLineItem = new map<id, Order_Line_Item__c>();
        //START 01/08/15 D-1592 Wenjun - Postage Charges : Remove field Order.Postage_Charge__c
        //START 2/9/15 D-1977, D-0726 FrancisBenzon/April Banaag : Added Vendor/Mailing Agent, Main_Package_Subscription_Rate__c, to Query. Cause of error in zuora for creation of subs.
        for (Order_Line_Item__c tmp : [SELECT Id, Generate_Invoice__c, Main_Package_Billing_Type__c,
                Term_is_discussed__c, Order__c,  Order__r.Recipient_Contact__c, Order__r.Billing_Contact__c, Promotion_ID__c,
                Order__r.PO_Number__c, Classification__c, Sub_Classification__c, Reason_Code__c, Qty__c, Postage_Charge__c,
                Main_Package_Subscription_Rate__c, Based_Order_Line_Item__c, Order__r.Order_type__c, Vendor_Mailing_Agent__c FROM Order_Line_Item__c 
                WHERE Based_Order_Line_Item__c in :orderLineItemId_orderLineItem.keySet()]) {
            oldOrderLineItemId_newOrderLineItem.put(tmp.Based_Order_Line_Item__c, tmp);
        }
        //END 2/9/15 D-1977, D-0726 FrancisBenzon/April Banaag : Added Vendor/Mailing Agent, Main_Package_Subscription_Rate__c, to Query. Cause of error in zuora for creation of subs.
        //END 01/08/15 D-1592 Wenjun - Postage Charges
        // end D-1185

        //START: D-0254 12/03/14 Added by J.Sarion ? Mapping of Order Id to Order 
        Map<Id, Order__c> orderIdToOrderMap = new Map<id, Order__c>([SELECT Recipient_Contact__c FROM Order__c WHERE Id IN :orderIds]);
        //END: D-0254 12/03/14 Added by J.Sarion
        
        //START: D-0810 12/10/14 Added by FrancisBenzon Description: Mapping of order and subscription old and new values
        try {
            //START D-1960 and D-1686 and D-0726 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
            List<Order__c> orderListWithSubGrace = new List<Order__c>([SELECT Id, Subscription__c, Subscription__r.Order_Line_Item_Number_1__r.Grace_Days__c 
                                                                        FROM Order__c
                                                                        WHERE Id IN :orderIds
                                                                        AND Subscription__r.Order_Line_Item_Number_1__r.Grace_Days__c != 0]);
            //END D-1960 and D-1686 and D-0726 12/02/15 Kevin Evasco/April Banaag : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
            system.debug('>>>List' + orderListWithSubGrace);
            for(Order__c orderSub : orderListWithSubGrace) {
                if(orderSub.Subscription__c != null) {
                    orderAndSubMap.put(orderSub.Id, orderSub.Subscription__c);
                    orderGracePeriodMap.put(orderSub.Id, integer.valueOf(orderSub.Subscription__r.Order_Line_Item_Number_1__r.Grace_Days__c)); //START/END D-1960 and D-1686 and D-0726 12/02/15 Kevin Evasco/April Banaag : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
                }               
            }
        }
        catch(exception e) {
            system.debug(e.getMessage());
        }
        //END: D-0810 12/10/14 Added by FrancisBenzon Description: Mapping of order and subscription old and new values
        
        // retrieve respective recipients
        for (Zuora__Subscription__c sub:lSub) {
            id orderLineItemId;
            
            if(sub.Order_Line_Item_Number__c != null && sub.Order_Line_Item_Number__c instanceof Id){
                sub.Order_Line_Item_Number_1__c = Id.valueOf(sub.Order_Line_Item_Number__c);//2324 
                orderLineItemId = Id.valueOf(sub.Order_Line_Item_Number__c);
            }
            
            Order_Line_Item__c orderLineItem = orderLineItemId_orderLineItem.get(orderLineItemId);
            
            // [JohnD 12/12] D-1185
            if (oldOrderLineItemId_newOrderLineItem.get(orderLineItemId) != null) {
                if (oldOrderLineItemId_newOrderLineItem.get(orderLineItemId).Order__c != null) {
                    if (oldOrderLineItemId_newOrderLineItem.get(orderLineItemId).Order__r.Order_type__c == ConstantsSLB.getOther('Order_Type COS_Quantity')) {
                        orderLineItem = (oldOrderLineItemId_newOrderLineItem.get(orderLineItemId));
                        sub.Order_Line_Item_Number_1__c = orderLineItem.Id;//2324
                        sub.Order_Line_Item_Number__c = orderLineItem.Id;//2324 
                        isChangeOfQuantity = true;
                    }
                }
            }
            
            // end D-1185
            
            if(sub.Vendor_Subscription_To_Convert__c != null && sub.Vendor_Subscription_To_Convert__c instanceof Id) {
                sub.Vendor_Subscription_To_Convert_1__c = Id.valueOf(sub.Vendor_Subscription_To_Convert__c);
            }
            if(sub.Main_Package__c != null && sub.Main_Package__c instanceof Id) {
                sub.Main_Package_1__c = Id.valueOf(sub.Main_Package__c);
            }
            if(sub.Vendor__c != null && sub.Vendor__c instanceof Id) {
                sub.Vendor_1__c = Id.valueOf(sub.Vendor__c);
            }
            if(sub.Contract_End_Date__c != null) {
                sub.Contract_End_Date_1__c = date.valueof(sub.Contract_End_Date__c);
            }
            if(sub.New_Contract_Period__c != null) {
                sub.New_Contract_Period_1__c = decimal.valueof(sub.New_Contract_Period__c);
            }
            if(sub.Penalty_Charge__c != null) {
                sub.Penalty_Charge_1__c = decimal.valueof(sub.Penalty_Charge__c);
            }
            if(sub.Promotion_Contract_Period__c != null) {
                sub.Promotion_Contract_Period_1__c = decimal.valueof(sub.Promotion_Contract_Period__c);
            }
            if(sub.Vendor_Credit__c != null) {
                sub.Vendor_Credit_1__c = decimal.valueof(sub.Vendor_Credit__c);
            }
            if(sub.Promotion__c != null && sub.Promotion__c instanceof Id) {
                sub.Promotion_1__c = Id.valueof(sub.Promotion__c);
            }
            sub.Other_PaymentMethod_1__c = sub.Other_PaymentMethod__c;
            sub.Payment_Mode_1__c = sub.Payment_Mode__c; 
            sub.Acquisition_Type_1__c = sub.Acquisition_Type__c;
            sub.Asia1_Creation_Mode_1__c = sub.Asia1_Creation_Mode__c;
            sub.Delivered_By_1__c = sub.Delivered_By__c;
            sub.Delivery_Charge_Type_1__c = sub.Delivery_Charge_Type__c;
            sub.Frequency_1__c = sub.Frequency__c;
            sub.Subscription_Type_1__c = sub.Subscription_Type__c;
            
            if(sub.Suppress_Vendor_Start_Notice__c !=null){
                sub.Suppress_Vendor_Start_Notice_1__c = boolean.valueof(sub.Suppress_Vendor_Start_Notice__c);
            }
            if(sub.Supressed_Acknowledgement_Letter__c != null){
                sub.Supressed_Acknowledgement_Letter_1__c = boolean.valueof(sub.Supressed_Acknowledgement_Letter__c);
            }
            if(sub.Supressed_Renewal_and_Reminder_Letter__c!=null){
                sub.Supressed_Renewal_and_Reminder_Letter_1__c = boolean.valueof(sub.Supressed_Renewal_and_Reminder_Letter__c);
            }
            if(sub.Urgent__c!=null){
                sub.Urgent_1__c = boolean.valueof(sub.Urgent__c);
            }
            if(sub.Vendor_Conversion__c!=null){
                sub.Vendor_Conversion_1__c = boolean.valueof(sub.Vendor_Conversion__c);
            }
            if(sub.Charity__c!=null){
                sub.Charity_1__c = boolean.valueof(sub.Charity__c);
            }
            if(sub.Sponsor__c!=null){
                sub.Sponsor_1__c = boolean.valueOf(sub.Sponsor__c);
            }
            if(sub.Qty1__c!=null){
                
                // [JohnD 12/12] D-1185
                // since custom fields in zuora environment cannot be updated thru z.amend managed method
                // the qty must be derived from order line item. this only applies during change of subscription
                // in quantity scenario
                if (isChangeOfQuantity == true && orderLineItem.Qty__c != null) {
                    sub.Qty1__c = string.valueOf(orderLineItem.Qty__c);
                    zuoraSubscriptionId_quantity.put(sub.Zuora__Zuora_Id__c, sub.Qty1__c);
                }
                // end D-1185
                
                sub.Qty__c = decimal.valueOf(sub.Qty1__c);
                //sub.Number_of_Copies__c = decimal.valueOf(sub.Qty1__c);
                
            }
            if(sub.Qty__c!=null){
               sub.Number_of_Copies__c = sub.Qty__c;
                
            }
            if(sub.Term_Length1__c!=null){
               sub.Term_Length__c = decimal.valueOf(sub.Term_Length1__c);  
            }
            if(sub.Generate_Invoice1__c!=null){
               sub.Generate_Invoice__c = boolean.valueOf(sub.Generate_Invoice1__c);  
            }
            //Start/End D-0726 and D-1960 and D-1686 April Banaag/kevin Evasco - lines of code deleted
            
            if (orderLineItem != null) {
              
              // Start D-2005 02/08/2015 JohnD
              // Start D-1890 02/12/2015 J.Sarion Check if Vendor from Zuora sync is not null
              if (sub.Vendor__c != null && sub.Vendor__c instanceof Id) {
                sub.Vendor_1__c = Id.valueOf(sub.Vendor__c);
              }
              else {
                  sub.Vendor_1__c = orderLineItem.Vendor_Mailing_Agent__c;
                  sub.Vendor__c = orderLineItem.Vendor_Mailing_Agent__c;
              }
              // End D-1890 02/12/2015
              // End D-2005 02/08/2015
              
              // [JohnD 12/10] D-0636
              // mapping of classification, sub -classification, and reason code from 
              // order line item into its corresponding subscription
              sub.Classification__c = orderLineItem.Classification__c;
              sub.Sub_Classification__c = orderLineItem.Sub_classification__c;
              sub.Reason_Code__c = orderLineItem.Reason_Code__c;
              // end D-0636
              
              if (orderLineItem.Order__c != null) {
                //START: D-1904 2/2/15 Added by J.Sarion - Added criteria: Subscription Type Delivery
                if(sub.Recipient_Contact_1__c != null && sub.Recipient_Contact_1__c instanceof Id) {
                    sub.Recipient_Contact__c = sub.Recipient_Contact_1__c;
                }
                else {
                    sub.Recipient_Contact__c = orderLineItem.Order__r.Recipient_Contact__c;
                }
                //END: D-1904 2/2/15 Added by J.Sarion
                sub.Subscriber_Contact__c = orderLineItem.Order__r.Recipient_Contact__c;
                sub.Contact__c = orderLineItem.Order__r.Billing_Contact__c;
                sub.Order_Number_1__c = orderLineItem.Order__c;//2324 
                //START 01/08/15 D-1592 Wenjun - Postage Charges : Refer to Order Line Item
                sub.Postage_Charge__c = orderLineItem.Postage_Charge__c; 
                //END 01/08/15 D-1592 Wenjun - Postage Charges
              }
                sub.Billing_Type__c = orderLineItem.Main_Package_Billing_Type__c;
                sub.Generate_Invoice__c = orderLineItem.Generate_Invoice__c;
                sub.Term_is_discussed__c = orderLineItem.Term_is_discussed__c;
                sub.Promotion_1__c = orderLineItem.Promotion_ID__c;
            }
            //START: D-1904 2/2/15 Added by J.Sarion - Added criteria: Subscription Type Delivery
            //START: D-0254 12/03/14 Added by J.Sarion - Populate Recipient Contact for Delivery Subscription
            if (sub.Order_Number__c != null && sub.Recipient_Contact__c == null && sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY) {
                if (orderIdToOrderMap.containsKey(Id.valueOf(sub.Order_Number__c))) {
                    sub.Recipient_Contact__c = (orderIdToOrderMap.get(Id.valueOf(sub.Order_Number__c)).Recipient_Contact__c != null ? orderIdToOrderMap.get(Id.valueOf(sub.Order_Number__c)).Recipient_Contact__c : null);
                }
                
            }

            //END: D-0254 12/03/14 Added by J.Sarion
            //END: D-1904 2/2/15 Added by J.Sarion
            
            //START D-0810 Added By: FrancisBenzon Description: Populate Grace Period identifiers for new Grace Period Subscriptions
            if(orderAndSubMap.containsKey(sub.Order_Number_1__c)) {
                sub.Grace_Period_Subscription__c = orderAndSubMap.get(sub.Order_Number_1__c);
            }
            if(orderGracePeriodMap.containsKey(sub.Order_Number_1__c)) {
                //sub.Grace_Period__c = orderGracePeriodMap.get(sub.Order_Number_1__c); //Start/End D-0726 and D-1960 and D-1686 April Banaag/kevin Evasco - for deletion
            }
            //END D-0810 Added By: FrancisBenzon Description: Populate Grace Period identifiers for new Grace Period Subscriptions
            //Start D-0726 02/13/2015 Added by ABanaag - populate sub charge 
            //START AddedBy FrancisBenzon D-2003 : checking for null pointer
            if(orderLineItem != null  && orderLineItem.Main_Package_Subscription_Rate__c!= null){
                sub.Subscription_Charge__c = orderLineItem.Main_Package_Subscription_Rate__c;
            }
            //END AddedBy FrancisBenzon D-2003 : checking for null pointer
            //End D-0726 02/13/2015 Added by ABanaag - populate sub charge 
        }
    }


    public void invoicePaymentProcess(Order__c SOrder, List<Id> lQuoteIds) {
        List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
        List<Zuora.zObject> zobjs;
        //Start AddedBy FrancisBenzon D-2038 : to catch attempt to dereference null pointer.
        List<Map<String, Object>> invoiceMapList = new  List<Map<String, Object>>();
        List<Map<String, Object>> paymentMapList = new List<Map<String, Object>>();
        //End AddedBy FrancisBenzon D-2038 : to catch attempt to dereference null pointer.
        Set<String> paymentZuoraIdSet = new Set<String>();
        //START 09/01/2015 Wenjun : Not in use - cause error
        //Order_Line_Item__c oli = new Order_Line_Item__c();
        //END 09/01/2015 Wenjun
        String invoiceZuoraId;
        String zoql;
        //ZuoraCallOut zCallOut = new ZuoraCallOut();    //Hot FIX for The callout was unsuccessful after 4 attempts:
        
        //START 09/01/2015 Wenjun : Not in use - cause error
        /*
        if (SOrder != null) {
            oli = [SELECT Id, Name, Main_Package_Billing_Type__c FROM Order_Line_Item__c WHERE Order__c = :SOrder.Id];
        }
        */
        //END 09/01/2015 Wenjun
        
        //Start AddedBy FrancisBenzon D-2038 : to catch attempt to dereference null pointer.
        /*
        if(lQuoteIds != null) {
            if (!lQuoteIds.isEmpty()) {
                //START 02/19/2015 JTeves - Code Review - NULL Keyword in SOQL WHERE Clause
                quoteList = [SELECT Id, Name, zqu__Service_Activation_Date__c, zqu__ZuoraAccountID__c, Main_Package__c FROM zqu__Quote__c WHERE Id IN :lQuoteIds AND Main_Package_isNull__c = 'FALSE' limit 1];
                //END 02/19/2015 JTeves
            }
        }
        if(quoteList != null) {
            if (!quoteList.isEmpty()) {
                invoiceMapList = generateInvoice(quoteList);
            }
        }
        if(invoiceMapList != null) {
            if (!invoiceMapList.isEmpty()) {
                List<Map<String,String>> results = zCallOut.generateInvoiceList(invoiceMapList);
                
                for (Map<String,String> resultMap :results) {               
                    if (resultMap.get('Status') == 'Success') {
                        invoiceZuoraId = resultMap.get('Id');
                    }
                }
            }
        }
        //End AddedBy FrancisBenzon D-2038 : to catch attempt to dereference null pointer.
       
        if (invoiceZuoraId != null) {
            zoql = 'SELECT AccountID, Amount, Balance, Id from Invoice Where id = \'' + invoiceZuoraId + '\'';
            zobjs = zCallOut.queryZObject(zoql);
        }
        
        //START 09/01/2015 Wenjun: Fix existing bug which block unit testing
        if (zobjs != NULL && !zobjs.isEmpty()) {
            paymentMapList = createPayment(zobjs);
        }
        //END 09/01/2015 Wenjun
        
        //START 09/01/2015 Wenjun: Fix existing bug which block unit testing
        if (paymentMapList!=NULL && !paymentMapList.isEmpty()) {
        //END 09/01/2015 Wenjun
             
            List<Map<String,String>> returnVar = zCallOut.loadZObjects(paymentMapList, 'Payment'); 
            for(Map<String,String> resultMap :returnVar){ 
                if (resultMap.get('Status') == 'Success') {
                    //TBD
                    paymentZuoraIdSet.add(resultMap.get('Id'));
                }
                else {
                    //TBD
                }
            }
        }
    }

    public List<Map<String, Object>> generateInvoice(List<zqu__Quote__c> quoteList) {
        List<Map<String, Object>> invoiceMapList = new List<Map<String, Object>>();
        Map<String, Object> invoiceMap;
        String invoiceZuoraId;
        DateTime d = system.now();
        DateTime dt = datetime.newinstance(d.year(), d.month(), d.day(), d.hour(), d.minute(), d.second());
        string dFormat = (string.valueOf(dt)).replaceAll( '\\s+', 'T');

        for (zqu__Quote__c quote :quoteList) {
            invoiceMap = new Map<String, Object>();
            Date firstDayOfMonth = quote.zqu__Service_Activation_Date__c.toStartOfMonth();
            Date serviceActivationDate;
            
            if (firstDayOfMonth == quote.zqu__Service_Activation_Date__c) {
                serviceActivationDate = quote.zqu__Service_Activation_Date__c;
            }
            else {
                serviceActivationDate = date.newinstance(quote.zqu__Service_Activation_Date__c.year(), quote.zqu__Service_Activation_Date__c.month()+1, 1);
            }

            DateTime serviceActivationDateTime = datetime.newinstance(serviceActivationDate.year(), serviceActivationDate.month()+1, 1);
            String sadFormat = (string.valueOf(serviceActivationDateTime)).replaceAll( '\\s+', 'T');
            
            invoiceMap.put('AccountId', quote.zqu__ZuoraAccountID__c);
            invoiceMap.put('InvoiceDate', dFormat);
            invoiceMap.put('TargetDate', sadFormat);
            
            invoiceMapList.add(invoiceMap);
        }

        return invoiceMapList;   
    }

    public List<Map<String, Object>> createPayment(List<Zuora.zObject> zobjs) {
        List<Map<String, Object>> paymentMapList = new List<Map<String, Object>>();
        Zuora__CustomerAccount__c billAcc;
        Zuora__PaymentMethod__c paymentMethod;
        String paymentMethodId;
        String zuoraId;
        datetime d = system.now();
        datetime dt = datetime.newinstance(d.year(), d.month(), d.day(), d.hour(), d.minute(), d.second());
        string dFormat = (string.valueOf(dt)).replaceAll( '\\s+', 'T'); 
        
        if (zobjs.get(0).getValue('AccountID') != null) {
            zuoraId = (String) zobjs.get(0).getValue('AccountID');
            billAcc = [SELECT Id, Zuora__Default_Payment_Method__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = :zuoraId];
        }
        if (billAcc.Zuora__Default_Payment_Method__c != null) {
            paymentMethodId = billAcc.Zuora__Default_Payment_Method__c;
        }
        if (paymentMethodId != null) {
            paymentMethod = [SELECT Id, Zuora__External_Id__c FROM Zuora__PaymentMethod__c WHERE Id = :paymentMethodId];
        }
        
        Map<String, Object> paymentMap = new Map<String, Object>();
        paymentMap.put('AccountId', zuoraId);      
        paymentMap.put('Amount', zobjs.get(0).getValue('Balance'));
        paymentMap.put('AppliedInvoiceAmount', zobjs.get(0).getValue('Balance'));
        paymentMap.put('EffectiveDate', dFormat);
        paymentMap.put('Gateway', ConstantsSLB.getKeyId('PaymentGatewayId'));//From Billing Account
        paymentMap.put('InvoiceId', zobjs.get(0).getValue('AccountID'));
        paymentMap.put('PaymentMethodId', billAcc.Zuora__External_Id__c);//From Billing Account
        paymentMap.put('Type', 'Electronic');
        
        paymentMapList.add(paymentMap);
        
        return paymentMapList;
    }
     */
    //END MD-28 02/Jul/2015 Wenjun: Remove Wrong Logic 
}