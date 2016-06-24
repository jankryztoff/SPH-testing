/*
     * History: 12/14/14 Product Catalogue  Kevin Evasco - Updated to include proration charges
     * History: Code Review(Null in where clause causes full table scans - 100K Record Issue Limit) 16-Feb-2015 Raviteja 
     * History: D- 2197 / K. Tan / Modified to populate Old Subscription to update it by New Subscription created from Renewal Batch
     * History: MD-26 D-1907 / K. Tan / Added delivery charges for this renewal bulk quote handler
    */
    public class Renewal_Quote_Handler_Bulk{
        
        public static string PaymentMode;
        public static string sDeliveryChargeType;
        public static string zBillingAccount;
        public static Id AccountId;
        public static string CCPaymentMethodID;
        public static Set<Id> orderSet = new Set<Id>();
        public static Set<String> quoteNameSet = new Set<String>();
    // START K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    
        public static String sAirline = ConstantsSLB.getKeyId('AddAirline');
        public static String sOverseas = ConstantsSLB.getKeyId('AddOverseas');
        public static String sLocal = ConstantsSLB.getKeyId('AddLocal');
        public static String sInternal = ConstantsSLB.getKeyId('AddInternal');  
        public static String TERM_EVER_GREEN = ConstantsSLB.getKeyId('SubTermTypeEvergreen');
        public static String CURRENCY_SGD = ConstantsSLB.getKeyId('CurrencySGD');
        public static String INVOICE_PROC_OPTION = ConstantsSLB.getKeyId('QuoteInvoiceProcessingSubscription');
        public static Set<Id> accountIDset = new Set<Id>();
        public static Set<String> recipientAddUniqueIdSet = new Set<String>();
        public static Map<Id, Set<String>> accountToAddressMap = new  Map<Id, Set<String>> ();
        public static Boolean bHasVendorDelivery;
        public static Boolean bCreateDeliverySubscription;
        public static zqu__ProductRatePlan__c ratePlanDelivery;
        Map<Id, zqu__ProductRatePlan__c> orderIdToProductRatePlanMap = new Map<Id, zqu__ProductRatePlan__c>();
        List<zqu__Quote__c> zQuoteListRet = new List<zqu__Quote__c>();
        zqu__Quote__c quoteReturn; 
        public static String RT_ID_BUNDLE_PROD = ConstantsSLB.getKeyId('Package Item_Bundle Product');
    // END K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    

        //START 12/15/14 Product Catalogue Kevin Evasco - Updated to include proration charges
        public String source = '';
        public static Set<Id> result_createdQuoteIdSet = new Set<Id>();
        //END 12/15/14 Product Catalogue Kevin Evasco - Updated to include proration charges
        
        //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
        zqu__ProductRatePlan__c postagePrp = new zqu__ProductRatePlan__c();
        zqu__ProductRatePlanChargeTier__c postagePrpct = new zqu__ProductRatePlanChargeTier__c();
        List<zqu__ProductRatePlanCharge__c> postagePrpcList = new List<zqu__ProductRatePlanCharge__c>();
        List<zqu__ProductRatePlanChargeTier__c> postagePrpctList = new List<zqu__ProductRatePlanChargeTier__c>();
        Map<Id, List<zqu__ProductRatePlanCharge__c>> postagePrpIdToPrpcListMap = new Map<Id, List<zqu__ProductRatePlanCharge__c>>();
        Map<Id, zqu__ProductRatePlanChargeTier__c> postagePrpcIdToPrpctMap = new Map<Id, zqu__ProductRatePlanChargeTier__c>();
        Map<Id, zqu__Quote__c> quoteIdToQuote = new Map<Id, zqu__Quote__c>();
        Map<Id, zqu__ProductRatePlan__c> postagePrpIdToPrpMap = new Map<Id, zqu__ProductRatePlan__c>();
        Map<Id, Order_Line_Item__c> oliIdToOliMap = new Map<Id, Order_Line_Item__c>();
        Map<Id, Id> postageQuoteToOliMap = new Map<Id, Id>();
        //END 01/19/15 J. Sarion - Updated to include proration charges
        
        public static Boolean hasVendorDelivery = false; // START 03/26/2015 MD-59 Kevin Evasco - Restrict Delivery Rate Plan validation for Vendor Delivery only
        
        public Set<string> bulkQuoteCreation(Set<id> orderIdSet, String origin){
            Set<id> orderLineItemIdSet = new Set<id>();
            Set<id> packageIdSet = new Set<id>();
            Set<string> quoteAccountZuoraIdSet = new Set<string>();

            List<Order__c> orderList = new List<Order__c>();
            List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
            List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
            //Map<id, id> orderIdAccountIdMap = new Map<id, id>();
            //Map<id, id> orderIdRecipientAddIdMap = new Map<id, id>();
            Map<id, List<Order_Line_Item__c>> orderIdOrderLineItemMap = new Map<id, List<Order_Line_Item__c>>();
            Map<id, List<Order_Line_Item_Gift__c>> orderLineToGiftMap = new Map<id, List<Order_Line_Item_Gift__c>>();       
            //Map<id, Map<id, Package_Item__c>> orderLineToPackageItemMap = new Map<id, Map<id, Package_Item__c>>();
            Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c>();
            Map<id, List<Package_Item__c>> packIdToPackItemListMap = new Map<id, List<Package_Item__c>>();
            Map<id, List<zqu__ProductRatePlanCharge__c>> prpIdToprpcListMap = new Map<id, List<zqu__ProductRatePlanCharge__c>>();
            Map<id, zqu__ProductRatePlanChargeTier__c> ratePlanChargeTierMap = new Map<id, zqu__ProductRatePlanChargeTier__c>();
            Map<String, Set<id>> quoteIdToQuoteMap = new Map<String, Set<id>>();
            Map<Id, zqu__ProductRatePlan__c> prpIdToPrpMap = new Map<Id, zqu__ProductRatePlan__c>();
            Map<Id, Set<Id>> orderIdToQuoteIdSetMap = new Map<Id, Set<Id>>();
            Map<Id, String> orderIdToSubZuoraIdMap = new Map<Id, String>();       
            List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
            
            orderSet = orderIdSet;
        
            orderList = getOrder(orderIdSet);       
     // START K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    
           
            for(Order__c order : orderList){            
                orderIdToOrderMap.put(order.Id, order);
                accountIDset.add(order.Account__c);
                recipientAddUniqueIdSet.add(order.Recipient_Contact__r.Address__r.Address_Unique_ID__c);
            }
     // END K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    

            orderIdOrderLineItemMap = getOrderLineItem(orderIdSet);                     
            
            for(Id orderId : orderIdOrderLineItemMap.keySet()){                             
                for(Order_Line_Item__c orderLineItem : orderIdOrderLineItemMap.get(orderId)){
                    // START 03/26/2015 MD-59 Kevin Evasco - Restrict Delivery Rate Plan validation for Vendor Delivery only
                    if(orderLineItem.Delivered_By__c == GlobalVariableClass.OLIDELIVEREDBY_VENDOR) {
                        hasVendorDelivery = true;
                    }
                    // END 03/26/2015 MD-59 Kevin Evasco - Restrict Delivery Rate Plan validation for Vendor Delivery only
                    orderLineItemList.add(orderLineItem);
                    orderLineItemIdSet.add(orderLineItem.id);
                    if(orderLineItem.Main_Package_ID__c != null){
                        packageIdSet.add(orderLineItem.Main_Package_ID__c);
                    }
                    if(orderLineItem.Addon_Package__c != null){
                        packageIdSet.add(orderLineItem.Addon_Package__c);
                    }
                }
            }
            
            //START SPH Code Review - 16-Feb-2015 Added by Raviteja - included if condition in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit
               orderIdSet.remove(null); 
            //End SPH Code Review - 16-Feb-2015 Added by Raviteja 
            
            subList = [SELECT Id, Zuora__Zuora_Id__c, Order_Number_1__c FROM Zuora__Subscription__c WHERE Order_Number_1__c IN :orderIdSet];
        
            for (Zuora__Subscription__c sub :subList) {
                orderIdToSubZuoraIdMap.put(sub.Order_Number_1__c, sub.Zuora__Zuora_Id__c);
            }
            
            orderLineToGiftMap = getOrderLineItemGifts(orderLineItemIdSet);
            
            packIdToPackItemListMap = getPackage(packageIdSet, orderIdOrderLineItemMap);
            
            prpIdToPrpMap = getProductRatePlan(packIdToPackItemListMap);
            
            prpIdToprpcListMap = getProdRatePlanCharge(prpIdToPrpMap);
            
            ratePlanChargeTierMap = getProdRatePlanChargeTier(prpIdToprpcListMap);
    // START K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges
    
            orderIdToProductRatePlanMap = getDeliveryCharge(orderList);
    // START K. Tan MD-18 D-2592 /3-18-2015 /New Implememtation of Delivery charges    
       
            //deliverySubscriptionCheck();
            
            for(Id orderId : orderIdOrderLineItemMap.keySet()){                             
                for(Order_Line_Item__c orderLineItem : orderIdOrderLineItemMap.get(orderId)){
                    bCreateDeliverySubscription = false;
                                
                            
                    
                        
                    if(orderLineItem.Delivered_By__c == 'Vendor' && ratePlanDelivery != NULL) {
                        bCreateDeliverySubscription = true;    
                    }
                    system.debug('>>>>>>>>>>>>>>>>>>>>>bHasVendorDelivery' + ' ' + bCreateDeliverySubscription);
                    system.debug('>>>>>>>>>>>>>>>>>>>>>bCreateDeliverySubscription' + ' ' + bCreateDeliverySubscription);

                    if(bCreateDeliverySubscription == true) {
                        quoteReturn = new zqu__Quote__c ();
                        quoteReturn = createQuoteDelivery(orderIdToOrderMap.get(orderId), orderLineItem, ConstantsSLB.getkeyid('SubTypeDel'), origin );
                        zQuoteListRet.add(quoteReturn);
                    }
                }
            }
    // END K. Tan MD-18 D-2592 /3-21-2015 /New Implememtation of Delivery charges    
            
            insert zQuoteListRet;
            for(zqu__Quote__c zquoret :zQuoteListRet){
                try{
                    List<zqu.zChargeGroup> lstChargeGroups = new List<zqu.zChargeGroup>();

                    zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(zquoret.Id, orderIdToProductRatePlanMap.get(Id.valueOf(zquoret.Order_Number__c)).Id);
                    lstChargeGroups.add(chargeGroup); 
                    zqu.zQuoteUtil.addChargeGroups(lstChargeGroups); 

                }
                catch(exception e){
                    system.debug('ERROR' + e.getMessage());
                }               
                
                
            }
            
    // END K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    
            
            
            
            //START 12/14/14 Product Catalogue Kevin Evasco - Updated to include proration charges
            quoteIdToQuoteMap = createQuote(orderIdOrderLineItemMap, packIdToPackItemListMap, orderLineToGiftMap, orderIdToOrderMap, orderIdToSubZuoraIdMap);
            
            addQuoteChargeToQuote(orderLineItemList, packIdToPackItemListMap, quoteIdToQuoteMap, prpIdToprpcListMap, ratePlanChargeTierMap, prpIdToPrpMap);    
            
            for (String quoteName :quoteIdToQuoteMap.keySet()) {
                quoteNameSet.add(quoteName);
            }
            
            quoteList = [SELECT Id, zqu__ZuoraAccountID__c FROM zqu__Quote__c WHERE Id IN :result_createdQuoteIdSet];
            
            List<zqu__QuoteCharge__c> result_quoteChargeList;       
            List<zqu__ProductRatePlan__c> result_productRatePlanList;
            Set<Id> result_productIdSet = new Set<Id>();
            Map<Id,Id> result_quote_product_map = new Map<Id,Id>();
            Map<Id,List<Id>> result_product_productRatePlanList_map = new Map<Id,List<Id>>();
            
            
            for (zqu__Quote__c quote :quoteList) {
                quoteAccountZuoraIdSet.add(quote.zqu__ZuoraAccountID__c);
            }        
            
            //START SPH Code Review - 16-Feb-2015 Added by Raviteja - included if condition in order to avoid Null in where clause causes full table scans - 100K Record Issue Limit
               result_createdQuoteIdSet.remove(null); 
            //End SPH Code Review - 16-Feb-2015 Added by Raviteja 
            
            result_quoteChargeList = [SELECT Id, zqu__Quote__r.Id, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Id FROM zqu__QuoteCharge__c WHERE zqu__Quote__c IN :result_createdQuoteIdSet];
            
            for(zqu__QuoteCharge__c result_quoteCharge : result_quoteChargeList)
            {
                result_productIdSet.add(result_quoteCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Id);
                result_quote_product_map.put(result_quoteCharge.zqu__Quote__r.Id, result_quoteCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Id);
            }
            
            if(source == 'Grace Period Batch')
            {
                result_productRatePlanList = [SELECT Id, zqu__ZProduct__c FROM zqu__ProductRatePlan__c WHERE zqu__ZProduct__c IN :result_productIdSet AND RatePlanType__c = 'Proration' AND RatePlanSubType__c = 'NonChargeable'];
            }
            else
            {           
                result_productRatePlanList = [SELECT Id, zqu__ZProduct__c FROM zqu__ProductRatePlan__c WHERE zqu__ZProduct__c IN :result_productIdSet AND RatePlanType__c = 'Proration'];
            }       
            
            for(zqu__ProductRatePlan__c result_productRatePlan : result_productRatePlanList)
            {
                if(result_product_productRatePlanList_map.get(result_productRatePlan.zqu__ZProduct__c) == null)
                {
                    result_product_productRatePlanList_map.put(result_productRatePlan.zqu__ZProduct__c, new List<Id>());
                }
                result_product_productRatePlanList_map.get(result_productRatePlan.zqu__ZProduct__c).add(result_productRatePlan.Id);
            }
            
            for (zqu__Quote__c quote :quoteList) {
                Id result_productId;
                List<Id> result_corresponding_productRatePlanList = new List<Id>(); //START-END D-4080 12-11-2015 added by Jason A. for code review
                if (result_quote_product_map.containsKey(quote.Id)) {
                    result_productId = result_quote_product_map.get(quote.Id);
                }
                if (result_product_productRatePlanList_map.containsKey(result_productId)) {
                    result_corresponding_productRatePlanList = result_product_productRatePlanList_map.get(result_productId);
                }
                if (result_corresponding_productRatePlanList != null) {
                    for(Id productRatePlanId : result_corresponding_productRatePlanList)
                    {
                        system.debug('>>>>>IN ');
                        zqu.zChargeGroup cg1 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productRatePlanId);
                        zqu.zQuoteUtil.addChargeGroup(cg1);    
                    }
                }
            }
            //END12/14/14  Product Catalogue Kevin Evasco - Updated to include proration charges
            
            return quoteNameSet;
        }
        
        public Map<id, List<Order_Line_Item__c>> getOrderLineItem(Set<id> orderIdSet){
            Map<id, List<Order_Line_Item__c>> orderIdOrderLineItemMap = new Map<id, List<Order_Line_Item__c>>();
            List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
            //START D-1149 02/17/15 K.Tan- Updated to cater Old Subscriptions 
            // START K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    

            orderLineItemList = [Select Term_Length__c, Start_Date__c, Qty__c, Postage_Charge__c, Order__r.Id, Order__c, Name, Main_Package_Sub_Type__c, 
                                     Main_Package_ID__r.Package_Sub_Type__c, Main_Package_ID__r.Package_Type__c, Main_Package_ID__r.Name, Main_Package_ID__c, Id, 
                                     End_Date__c, Case__c, Auto_Renew__c, Addon_Package__r.Package_Sub_Type__c, Addon_Package__r.Name, Addon_Package__c, 
                                     Addon_Package__r.Package_Type__c, Main_Package_Billing_Type__c, Add_On_Package_Product_Sub_Type__c, 
                                     Add_On_Package_Product_Platform__c, Main_Package_ID__r.Subscription_Type__c, Main_Package_ID__r.Subscription_Period__c, 
                                     Addon_Package__r.Subscription_Period__c, Main_Package_Product_Sub_Type__c, Main_Package_Product_Platform__c, Charity__c, 
                                     Promotion_ID__c, Contract_End_Date__c, New_Contract_Period__c, Promotion_Contract_Period__c, Delivered_By__c, 
                                     Main_Package_Frequency__c, Urgent__c, Generate_Invoice__c, Suppress_Vendor_Start_notice__c, 
                                     Supressed_Acknowledgement_Letter__c, Old_Subscription__c, Suppress_Renewal_and_Reminder_Letter__c, Vendor_Mailing_Agent__c, Vendor_Conversion__c, 
                                     Vendor_Subscription_ID__c, Order__r.Account__c, Order__r.Recipient_Contact__r.Address_Unique_Id__c
                                 FROM Order_Line_Item__c 
                                 WHERE order__c IN : orderIdSet];
            // END K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    
                     
            //END D-1149 02/17/15 K.Tan- Updated to cater Old Subscriptions 

            for(Order_Line_Item__c orderLineItem : orderLineItemList){
                if(orderIdOrderLineItemMap.containsKey(orderLineItem.order__c)){
                    orderIdOrderLineItemMap.get(orderLineItem.order__c).add(orderLineItem);
                } else{
                    orderIdOrderLineItemMap.put(orderLineItem.order__c, new List<Order_Line_Item__c>{orderLineItem});
                }
                
            //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
            oliIdToOliMap.put(orderLineItem.Id, orderLineItem);
            //END 01/19/15 J. Sarion - Updated to include proration charges
            }
            
            return orderIdOrderLineItemMap;
        }
        
        public List<Order__c> getOrder(Set<id> orderIdSet){
            List<Order__c> orderList = new List<Order__c>();
           // START K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    

            orderList = [SELECT Id, Name, Account__c, Account__r.Id, Billing_Account__c, Recipient_Contact__c, 
                             Billing_Account_External_ID__c, Payment_Mode__c, Other_Payment_Mode__c, Payment_Method_ID__c,
                             Billing_Contact__c, Billing_Contact__r.Id, Recipient_Contact__r.Address_Unique_Id__c,
                             Billing_Account_Creation_Mode__c, FP_Del_Usage__c , Recipient_Type__c, Recipient_Address__c,
                             Recipient_Add_Type__c, Acquisition_Type__c, Cost_Centre__c,Delivery_Charge_Type__c, Subscriber_Charge__c,
                             Vendor_Credit__c, PO_Number__c, Delivery_Start_Date__c, Sponsor__c, Remarks__c,
                             Base_Subscription__c, Recipient_Contact__r.Address__c, Recipient_Contact__r.Address__r.Address_Unique_ID__c, Debt_Management_Treatment__c
                         FROM Order__c 
                         WHERE id IN : orderIdSet];
           // END K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    
             
            return orderList;
        }
        
        public Map<id, List<Order_Line_Item_Gift__c>> getOrderLineItemGifts(Set<id> orderLineItemIdSet){
            List<Order_Line_Item_Gift__c> orderLineItemGiftList = new List<Order_Line_Item_Gift__c>();
            Map<id, List<Order_Line_Item_Gift__c>> orderLineToGiftMap = new Map<id, List<Order_Line_Item_Gift__c>>();
            
            orderLineItemGiftList = [SELECT Id, Type__c, Name, Price__c,Order_Line_Item__r.Id  
                                     FROM Order_Line_Item_Gift__c 
                                     WHERE Order_Line_Item__c IN : orderLineItemIdSet AND Type__c = 'Premium'
                                     ORDER BY Order_Line_Item__r.Id ASC];
                                     
            for(Order_Line_Item_Gift__c orderLineItemGift : orderLineItemGiftList){
                if(orderLineToGiftMap.containsKey(orderLineItemGift.Order_Line_Item__c)){
                    orderLineToGiftMap.get(orderLineItemGift.Order_Line_Item__c).add(orderLineItemGift);
                } else{
                    orderLineToGiftMap.put(orderLineItemGift.Order_Line_Item__c, new List<Order_Line_Item_Gift__c>{orderLineItemGift});
                }           
            }
            
            return orderLineToGiftMap;
        }
        
        public Map<id, List<Package_Item__c>> getPackage(Set<id> packageIdSet, Map<id, List<Order_Line_Item__c>> orderIdOrderLineItemMap){
            Package_Item__c packageItemRec = new Package_Item__c();
            List<Package_Item__c> packageItemList = new List<Package_Item__c>();
            Map<id, List<Package_Item__c>> packageItemMap = new Map<id, List<Package_Item__c>>();
            //Map<id, Map<id, Package_Item__c>> orderLineToPackageItemMap = new Map<id, Map<String, Package_Item__c>>();
            
            packageItemList = [SELECT Name, Id, Bundle_Item_No__c, Package__r.Id, RecordType.name, Base_Package_Item__c, Product_Rate_Plan__c, Package__c
                               FROM Package_Item__c
                               WHERE Package__c IN: packageIdSet
                               ORDER BY Bundle_Item_No__c ASC, Base_Package_Item__c ASC];
            
            for(Package_Item__c packageItem : packageItemList){
                if(packageItemMap.containsKey(packageItem.Package__c)){
                    packageItemMap.get(packageItem.Package__c).add(packageItem);
                } else {
                    packageItemMap.put(packageItem.Package__c, new List<Package_Item__c>{packageItem});
                }           
            }
                    
            /*for(Id orderId : orderIdOrderLineItemMap.keySet()){
                for(Order_Line_Item__c orderLineItem : orderIdOrderLineItemMap.get(orderId)){
                    orderLineToPackageItemMap.put(orderLineItem.id, new Map<id, Package_Item__c>());                
                    if(packageItemMap.containsKey(orderLineItem.Main_Package_ID__c)){
                        packageItemRec = packageItemMap.get(orderLineItem.Main_Package_ID__c);
                        orderLineToPackageItemMap.get(orderLineItem.id).put(packageItemRec.id, packageItemRec);
                    }
                    if(packageItemMap.containsKey(orderLineItem.Addon_Package__c)){
                        packageItemRec = packageItemMap.get(orderLineItem.Addon_Package__c);
                        orderLineToPackageItemMap.get(orderLineItem.id).put(packageItemRec.id, packageItemRec);
                    }               
                }
            } */
            
            return packageItemMap;
        }
        
        // product rate plan ; key : package item ; value : product rate plan
        public Map<id, zqu__ProductRatePlan__c> getProductRatePlan(Map<id, List<Package_Item__c>> packageItemMap){
            zqu__ProductRatePlan__c prodRatePlanRec = new zqu__ProductRatePlan__c();
            Set<id> prodRatePlanSet = new Set<id>();
            List<zqu__ProductRatePlan__c> prodRatePlanList = new List<zqu__ProductRatePlan__c>();
            Map<id, zqu__ProductRatePlan__c> ratePlanMap = new Map<id, zqu__ProductRatePlan__c>();
            Map<id, zqu__ProductRatePlan__c> prodRatePlanIdRatePlanMap = new Map<id, zqu__ProductRatePlan__c>();
            
            for(Id packageId : packageItemMap.keySet()){
                for(Package_Item__c packItem : packageItemMap.get(packageId)){
                    prodRatePlanSet.add(packItem.Product_Rate_Plan__c);
                }
            }
            
            //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
            prodRatePlanList = [SELECT Id,Name,zqu__ZProduct__c,zqu__ZProduct__r.ProductCode__c,
                     zqu__ZProduct__r.ProductType__c,zqu__ZProduct__r.ProductSubType__c, RatePlanCode__c, zqu__Deleted__c FROM zqu__ProductRatePlan__c WHERE Id IN : prodRatePlanSet OR (RatePlanCode__c = 'CHGPOS' AND zqu__Deleted__c = false)];
            
            for(zqu__ProductRatePlan__c prodratePlan : prodRatePlanList){
                ratePlanMap.put(prodRatePlan.id, prodRatePlan);
                
                if (prodratePlan.RatePlanCode__c == 'CHGPOS' && prodratePlan.zqu__Deleted__c == false) {
                    postagePrpIdToPrpMap.put(prodratePlan.Id, prodratePlan);
                }
            }
            //END 01/19/15 J. Sarion - Updated to include proration charges
            
            for(Id packageId : packageItemMap.keySet()){
                for(Package_Item__c packItem : packageItemMap.get(packageId)){
                    if(ratePlanMap.containsKey(packItem.Product_Rate_Plan__c)){
                        prodRatePlanIdRatePlanMap.put(packItem.Product_Rate_Plan__c, ratePlanMap.get(packItem.Product_Rate_Plan__c));
                    }
                }
            }
            
            return prodRatePlanIdRatePlanMap;
        }
        // product rate plan charge ; key : product rate plan ; value : product rate plan charge
        public Map<id, List<zqu__ProductRatePlanCharge__c>> getProdRatePlanCharge(Map<id, zqu__ProductRatePlan__c> prodRatePlanIdRatePlanMap){
            Set<id> prodRatePlanIdSet = new Set<id>();
            List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();     
            Map<id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanChargemap = new Map<id, List<zqu__ProductRatePlanCharge__c>>();
                    
            for(zqu__ProductRatePlan__c prodRatePlan : prodRatePlanIdRatePlanMap.values()){
                prodRatePlanIdSet.add(prodRatePlan.id);
            }
            
            prodRatePlanChargeList = [SELECT id, name, sum__c, zqu__UOM__c, zqu__RecurringPeriod__c, zqu__Model__c, zqu__Type__c,                                 zqu__Upto_How_Many_Periods__c, zqu__ZuoraId__c, zqu__ProductRatePlan__c,                                 zqu__Discount_Level__c 
                                      FROM zqu__ProductRatePlanCharge__c 
                                      WHERE zqu__ProductRatePlan__c IN :prodRatePlanIdSet];
            
            for(zqu__ProductRatePlanCharge__c prodRatePlanCharge : prodRatePlanChargeList){
                if(prodRatePlanChargemap.containsKey(prodRatePlanCharge.zqu__ProductRatePlan__c)){
                    prodRatePlanChargemap.get(prodRatePlanCharge.zqu__ProductRatePlan__c).add(prodRatePlanCharge);
                } else {
                    prodRatePlanChargemap.put(prodRatePlanCharge.zqu__ProductRatePlan__c, new List<zqu__ProductRatePlanCharge__c>{prodRatePlanCharge});
                }           
            }

            return prodRatePlanChargemap;
        }
    // START K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    

        public Map<Id, zqu__ProductRatePlan__c> getDeliveryCharge(List<Order__c> ordList){
                zqu__ProductRatePlan__c deliveryRatePlan_Internal;
                zqu__ProductRatePlan__c deliveryRatePlan_HDB;
                zqu__ProductRatePlan__c deliveryRatePlan_Apartment;
                zqu__ProductRatePlan__c deliveryRatePlan_Landed;
                String defaultDeliveryChargeType; //For determine the Delivery Rate Plan
                
                List<zqu__ProductRatePlan__c> lstDeliveryRatePlans =[Select zqu__ZProduct__r.ProductType__c, zqu__ZProduct__r.ProductSubType__c, zqu__ZProduct__c, Id, Name From zqu__ProductRatePlan__c

                Where 
                zqu__ZProduct__r.ProductCode__c =: GlobalVariableClass.PRODUCT_CODE_DELCHG and zqu__Deleted__c = false];

                
                if(!lstDeliveryRatePlans.isEmpty()){
                    for(zqu__ProductRatePlan__c drp: lstDeliveryRatePlans){
                        system.debug(drp.name == ConstantsSLB.getProductRatePlanDeliveryCharge('HDB DELIVERY CHARGE'));
                        if (drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount'))){
                            deliveryRatePlan_Internal = drp;
                        }else if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('HDB DELIVERY CHARGE'))){
                            deliveryRatePlan_HDB = drp;
                        }else if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('APT DELIVERY CHARGE'))){ 
                            deliveryRatePlan_Apartment = drp;
                        }else if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('LANDED DELIVERY CHARGE'))){
                            deliveryRatePlan_Landed = drp;
                        }
                    }
                }
                
                //SET Delivery Rate Plan to Use
                for(Order__c ord : ordList){
                    
                    defaultDeliveryChargeType = ConstantsSLB.getDefaultDeliveryChargeType(ord.Recipient_Add_Type__c);
                    if(ord.Recipient_Type__c == sInternal){
                        ratePlanDelivery = deliveryRatePlan_Internal;
                        orderIdToProductRatePlanMap.put(ord.id,ratePlanDelivery);
                    }
                    else if(ord.Recipient_Type__c == sLocal || ord.Recipient_Type__c == sAirline){
                        
                        if(defaultDeliveryChargeType == 'H'){
                            
                            ratePlanDelivery = deliveryRatePlan_HDB;
                            
                            orderIdToProductRatePlanMap.put(ord.id,ratePlanDelivery);
                            
                        }
                        else if(defaultDeliveryChargeType== 'C'){
                            ratePlanDelivery = deliveryRatePlan_Apartment;
                            orderIdToProductRatePlanMap.put(ord.id,ratePlanDelivery);
                        }
                        else if(defaultDeliveryChargeType == 'L'){
                            ratePlanDelivery = deliveryRatePlan_Landed;
                        }    orderIdToProductRatePlanMap.put(ord.id,ratePlanDelivery);
                        
                    }
                }

                
                if(ratePlanDelivery == NULL && hasVendorDelivery) { // START/END 03/26/2015 MD-59 Kevin Evasco - Restrict Delivery Rate Plan validation for Vendor Delivery only
                    throw new CustomException(System.Label.ERR_NO_DELIVERY_RATE_PLAN);
                }
            
                return orderIdToProductRatePlanMap;
            
            
            
            
        }

    // END K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    

        //product rate plan charge tier ; key : product rate plan charge id ; value : product rate plan charge tier 
        public Map<id, zqu__ProductRatePlanChargeTier__c> getProdRatePlanChargeTier(Map<id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanChargemap){
            Set<id> prodRatePlanChargeIdSet = new Set<id>();
            List<zqu__ProductRatePlanChargeTier__c> ratePlanChargeTierList = new List<zqu__ProductRatePlanChargeTier__c>();
            //Map<id, List<zqu__ProductRatePlanChargeTier__c>> ratePlanChargeTierMap = new Map<id, List<zqu__ProductRatePlanChargeTier__c>>();
            Map<id, zqu__ProductRatePlanChargeTier__c> ratePlanChargeTierMap = new Map<id, zqu__ProductRatePlanChargeTier__c>();
            
            for(Id ratePlanId : prodRatePlanChargemap.keySet()){
                for(zqu__ProductRatePlanCharge__c ratePlanCharge : prodRatePlanChargemap.get(ratePlanId)){
                    prodRatePlanChargeIdSet.add(ratePlanCharge.id);
                }
            }
            
            ratePlanChargeTierList = [SELECT id, name,  zqu__ProductRatePlanCharge__c, zqu__PriceFormat__c, zqu__Currency__c
                                      FROM zqu__ProductRatePlanChargeTier__c 
                                      WHERE zqu__ProductRatePlanCharge__c IN : prodRatePlanChargeIdSet];
                                      
            for(zqu__ProductRatePlanChargeTier__c ratePlanChargeTier : ratePlanChargeTierList){
                ratePlanChargeTierMap.put(ratePlanChargeTier.zqu__ProductRatePlanCharge__c, ratePlanChargeTier);
                
                /*if(ratePlanChargeTierMap.containsKey(ratePlanChargeTier.zqu__ProductRatePlanCharge__c)){
                    ratePlanChargeTierMap.get(ratePlanChargeTier.zqu__ProductRatePlanCharge__c).add(ratePlanChargeTier);
                } else {
                    ratePlanChargeTierMap.put(ratePlanChargeTier.zqu__ProductRatePlanCharge__c, new List<zqu__ProductRatePlanChargeTier__c>{ratePlanChargeTier});
                }*/
            }
            
            return ratePlanChargeTierMap;
        }
        
        /*Start Creation of Quotes
        *
        */
        public Map<String, Set<id>> createQuote (Map<Id, List<Order_Line_Item__c>> orderIdToOliListMap, Map<Id, List<Package_Item__c>> packageIdToPackageItemListMap, Map<Id, List<Order_Line_Item_Gift__c>> oliIdToOliGiftListMap, Map<Id, Order__c> orderIdToOrderMap, Map<Id, String> orderIdToSubZuoraIdMap) {

            Map<String, List<zqu__Quote__c>> oliNameToQuoteListMap = new Map<String, List<zqu__Quote__c>>();
            Map<Id, zqu__Quote__c> packageItemIdToQuoteMap = new Map<Id, zqu__Quote__c>();
            List<zqu__Quote__c> zQuoteList = new List<zqu__Quote__c>();
            List<zqu__QuoteCharge__c> zQuoteChargeList = new List<zqu__QuoteCharge__c>();
            List<Package_Item__c> packageItemList;
            List<Package_Item__c> packageItemAddOnList = new List<Package_Item__c>(); //START-END D-4080 12-11-2015 added by Jason A. for code review
            zqu__Quote__c zQuote;
            Boolean isFullPrepaid;
            String packageType;
            Integer iTerm;
            String origin = 'Renewal';
            
            for (Id orderId :orderIdToOliListMap.keySet()) {
                for (Order_Line_Item__c oli :orderIdToOliListMap.get(orderId)) {
                    zQuote = new zqu__Quote__c();
                    //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
                    Order__c order = orderIdToOrderMap.get(orderId);
                    //END 01/19/15 J. Sarion - Updated to include proration charges
                    
                    if (oli.Main_Package_ID__c != null) {
                        //Check if Main Package Billing Type is Full Prepaid
                        isFullPrepaid = false;
                        if (oli.Main_Package_Billing_Type__c == 'Full Prepaid') {
                            isFullPrepaid = true;
                        }
                        
                        //packageType values are: Add On, Base, Bundle, Discount, 
                        packageType = oli.Main_Package_ID__r.Package_Type__c;
                        
                        if (oli.Main_Package_ID__r.Subscription_Type__c == 'Termed') {
                            try {
                                iTerm = integer.valueof(oli.Main_Package_ID__r.Subscription_Period__c);
                            }
                            catch (exception e) {
                                iTerm = 0;
                            }
                        }
                        
                        packageItemList = new List<Package_Item__c>();
                        
                        if (!packageIdToPackageItemListMap.isEmpty()) {
                            if (packageIdToPackageItemListMap.containsKey(oli.Main_Package_ID__c)) {
                                packageItemList = packageIdToPackageItemListMap.get(oli.Main_Package_ID__c);
                            }
                        }
                        
                        /* Bundle package which will loop twice
                        *  Base package will loop once
                        */
                        for (Package_Item__c pkgItem :packageItemList) {
                            if (pkgItem.RecordType.Name.contains('Product')) {
                                String subType = ConstantsSLB.getkeyid('SubTypePub');
                            
                                //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
                                zQuote = zBuildQoutesPackage(oli, orderIdToOrderMap, iTerm, true, subType, true, false, false, isFullPrepaid, null, orderIdToSubZuoraIdMap);
                                //END 01/19/15 J. Sarion - Updated to include proration charges
                                
                                //Create Map for Order Id to its related Quotes
                                if (oliNameToQuoteListMap.containsKey(oli.Name)) {
                                    oliNameToQuoteListMap.get(oli.Name).add(zQuote);
                                }
                                else {
                                    oliNameToQuoteListMap.put(oli.Name, new List<zqu__Quote__c>{zQuote});
                                }
                                
                                packageItemIdToQuoteMap.put(pkgItem.Id, zQuote);
                                
                                zQuoteList.add(zQuote);
                            }
                        }
                        
                        if (oli.Addon_Package__c != null) {
                            packageItemAddOnList = packageIdToPackageItemListMap.get(oli.Addon_Package__c);

                            if (packageItemAddOnList != null) {

                                for (Package_Item__c pkgItem: packageItemAddOnList) {
                                    if(pkgItem.RecordType.name.contains('Product')){

                                        string subType = ConstantsSLB.getkeyid('SubTypePub');
                                    

                                        //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
                                        zQuote = zBuildQoutesPackage(oli, orderIdToOrderMap, 1, true, subType, false, true, false, isFullPrepaid, null, orderIdToSubZuoraIdMap);
                                        //END 01/19/15 J. Sarion - Updated to include proration charges

                                        //Create Map for Order Id to its related Quotes
                                        if (oliNameToQuoteListMap.containsKey(oli.Name)) {
                                            oliNameToQuoteListMap.get(oli.Name).add(zQuote);
                                        }
                                        else {
                                            oliNameToQuoteListMap.put(oli.Name, new List<zqu__Quote__c>{zQuote});
                                        }
                                        
                                        packageItemIdToQuoteMap.put(pkgItem.Id, zQuote);
                                        
                                        zQuoteList.add(zQuote);
                                    }
                                }                   
                            }
                        }
                        
                        if (!oliIdToOliGiftListMap.isEmpty()) {
                            boolean bGiftQuoteCreated = false;
                            if (oliIdToOliGiftListMap.containskey(oli.Id) && oliIdToOliGiftListMap.get(oli.Id) != null){
                                
                                for(Order_Line_Item_Gift__c g: oliIdToOliGiftListMap.get(oli.Id)){
                                    system.debug('GIFTS UNDER OLI::::::' + g);
                                    if(g.type__c == 'Premium'){
                                        if (!bGiftQuoteCreated){
                                            bGiftQuoteCreated=true;
                                            string subType = ConstantsSLB.getkeyid('SubTypePub');
                                        

                                            //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
                                            zQuote = zBuildQoutesPackage(oli, orderIdToOrderMap, 1, true, subType, false, false, true, isFullPrepaid, null, orderIdToSubZuoraIdMap);
                                            //END 01/19/15 J. Sarion - Updated to include proration charges
                                            
                                            //Create Map for Order Id to its related Quotes
                                            if (oliNameToQuoteListMap.containsKey(oli.Name)) {
                                                oliNameToQuoteListMap.get(oli.Name).add(zQuote);
                                            }
                                            else {
                                                oliNameToQuoteListMap.put(oli.Name, new List<zqu__Quote__c>{zQuote});
                                            }
                                            
                                            zQuoteList.add(zQuote);                                    
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
                    //START D-1689 23/01/15 Wenjun: Postage Charge is required for each publication
                    if (oli.Delivered_By__c == 'Mailing Agent') {
                        zQuoteList.add(zBuildPostageQuote(order, oli, ConstantsSLB.getkeyid('SubTypePostage'), null));
                    }
                    //END D-1689 23/01/15 Wenjun
                    //END 01/19/15 J. Sarion - Updated to include proration charges
                }
            }
            
            //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
            if (!zQuoteList.isEmpty()) {
                insert zQuoteList;
            }
            
            for (zqu__Quote__c quote :zQuoteList) {
                if (quote.Subscription_Type__c == 'Postage') {
                    postageQuoteToOliMap.put(quote.Id, quote.Order_Line_Item_Number__c);
                }
            }
            //END 01/19/15 J. Sarion - Updated to include proration charges
            
            Map<String, Set<id>> quoteIdToQuoteMap = new Map<String, Set<id>>();
            
            //START 12/15/14 Product Catalogue Kevin Evasco - Updated to include proration charges
            result_createdQuoteIdSet = new Set<Id>();       
            //END 12/15/14 Product Catalogue Kevin Evasco - Updated to include proration charges
            
            for (zqu__Quote__c zQuotes : zQuoteList) {
                if (zQuotes.Subscription_Type__c != 'Postage') {
                    if (quoteIdToQuoteMap.containsKey(zQuotes.name)) {
                        quoteIdToQuoteMap.get(zQuotes.name).add(zQuotes.id);
                    }
                    else {
                        quoteIdToQuoteMap.put(zQuotes.name, new Set<id>{zQuotes.id});
                    }
                }
                
                //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
                if(zQuotes.Subscription_Type__c == 'Postage'){
                    quoteIdToQuote = new Map<Id, zqu__Quote__c>();  
                    quoteIdToQuote.put(zQuotes.Id, zQuotes);
                }
                //END 01/19/15 J. Sarion - Updated to include proration charges
                
                //START 12/15/14 Product Catalogue Kevin Evasco - Updated to include proration charges
                result_createdQuoteIdSet.add(zQuotes.id);           
                //END 12/15/14 Product Catalogue Kevin Evasco - Updated to include proration charges
            }
            
            return quoteIdToQuoteMap;
        }

        public zqu__Quote__c zBuildQoutesPackage (Order_Line_Item__c oli, map<Id, Order__c> orderIdToOrderMap, Integer iTerm, 
                                                boolean bBundledWith, string subType, boolean bMain, boolean bAddOn, boolean bGift, 
                                                boolean isFullPrepaid, String origin, Map<Id, String> orderIdToSubZuoraIdMap){
            zqu__Quote__c q1 = new zqu__Quote__c ();

            q1.Name = oli.Name;
            q1.zqu__SubscriptionType__c = 'New Subscription';                 
            q1.zqu__ValidUntil__c = date.today().addMonths(1);
            
            q1.zqu__StartDate__c = oli.Start_Date__c;
            q1.zqu__Service_Activation_Date__c = oli.Start_Date__c;
            
            q1.zqu__Subscription_Term_Type__c = oli.Main_Package_ID__r.Subscription_Type__c;
            
            q1.Qty1__c= oli.Qty__c ;
            q1.Term_Length1__c = oli.Term_Length__c;
            //q1.Generate_Invoice1__c = oli.Generate_Invoice__c;
            q1.Generate_Invoice1__c = true;        
            q1.zqu__Currency__c = ConstantsSLB.getkeyid('CurrencySGD');
            q1.zqu__InvoiceProcessingOption__c = ConstantsSLB.getkeyid('QuoteInvoiceProcessingSubscription');
            q1.zqu__PaymentTerm__c = 'Due Upon Receipt';
            
            //Check if New Billing Account or Existing Billing Account
            
            //if(oli.Main_Package_ID__r.Subscription_Type__c == 'Termed'){
            if(oli.Main_Package_ID__r.Subscription_Type__c == ConstantsSLB.getkeyid('SubTermTypeTermed') ){

                if (bGift){
                    q1.zqu__InitialTerm__c = 1;
                    q1.zqu__RenewalTerm__c = 0;
                }else{
                
              //START D-1149  02/17/15 K.Tan- Updated to cater Term Length

                    if (oli.Term_Length__c != null) {

                        q1.zqu__InitialTerm__c = Integer.valueof(oli.Term_Length__c);
              //END D -1149 02/17/15 K.Tan- Updated to cater Term Length
                
                    } else {
                        q1.zqu__InitialTerm__c = 0;
                    }
                    q1.zqu__RenewalTerm__c = 0;
                }
            }
            
            //Additional Fields to populate
            if (bBundledWith){
                q1.Bundled_With__c                      = oli.id;
            }
            
            q1.Subscription_Type__c                     = subType;        
            q1.zqu__AutoRenew__c                        = oli.Auto_Renew__c;
            q1.Charity__c                               = oli.Charity__c;
            q1.Delivered_By__c                          = oli.Delivered_By__c;
            
            System.debug('VIN DEBUUUUG: ' + orderIdToOrderMap);
            if (orderIdToOrderMap.get(oli.Order__r.Id) != null) {
                if (orderIdToOrderMap.get(oli.Order__r.Id).Billing_Account_External_ID__c != null) {
                    q1.zqu__ZuoraAccountID__c = orderIdToOrderMap.get(oli.Order__r.Id).Billing_Account_External_ID__c; 
                }
                else {
                    q1.zqu__BillToContact__c= orderIdToOrderMap.get(oli.Order__r.Id).Billing_Contact__r.Id;   
                }        
                q1.Vendor__c = orderIdToOrderMap.get(oli.Order__r.Id).Account__r.Id;
                q1.Payment_Mode__c       = orderIdToOrderMap.get(oli.Order__r.Id).Payment_Mode__c; 
                q1.zqu__PaymentMethod__c = orderIdToOrderMap.get(oli.Order__r.Id).Payment_Mode__c;      
                q1.Other_PaymentMethod__c = orderIdToOrderMap.get(oli.Order__r.Id).Other_Payment_Mode__c;
                q1.zqu__Account__c = orderIdToOrderMap.get(oli.Order__r.Id).Account__c;        
                q1.zqu__SoldToContact__c = orderIdToOrderMap.get(oli.Order__r.Id).Recipient_Contact__c;       
                q1.zqu__ElectronicPaymentMethodId__c        = orderIdToOrderMap.get(oli.Order__r.Id).Payment_Method_ID__c;      
                q1.Cost_Center__c                           = orderIdToOrderMap.get(oli.Order__r.Id).Cost_Centre__c;
                q1.Acquisition_Type__c                      = orderIdToOrderMap.get(oli.Order__r.Id).Acquisition_Type__c;
                q1.Delivery_Charge_Type__c                  = orderIdToOrderMap.get(oli.Order__r.Id).Delivery_Charge_Type__c;
                q1.Subscriber_Charge__c                     = orderIdToOrderMap.get(oli.Order__r.Id).Subscriber_Charge__c;
                q1.Vendor_Credit__c                         = orderIdToOrderMap.get(oli.Order__r.Id).Vendor_Credit__c;
                q1.Frequency__c                             = oli.Main_Package_Frequency__c;            
                q1.Sponsor__c                               = orderIdToOrderMap.get(oli.Order__r.Id).Sponsor__c;
                q1.PO_Number__c                             = orderIdToOrderMap.get(oli.Order__r.Id).PO_Number__c;
                if (orderIdToOrderMap.get(oli.Order__r.Id).Recipient_Contact__c != null) {
                    q1.Recipient_Contact__c                 = string.valueOf(orderIdToOrderMap.get(oli.Order__r.Id).Recipient_Contact__c);
                }
                //START D-1149 02/17/15 K.Tan- Updated to cater Term Length

                q1.Related_Subscription__c = oli.Old_Subscription__c;
               //END D-1149 02/17/15 K.Tan- Updated to cater Term Length

            }
            
            
            if(oli.Contract_End_Date__c != null){
                q1.Contract_End_Date__c                 = oli.Contract_End_Date__c;
            }
            
            q1.Promotion_Contract_Period__c             = oli.Promotion_Contract_Period__c;
            q1.New_Contract_Period__c                   = oli.New_Contract_Period__c;
           
            
            if(bMain){
                q1.Main_Package__c                      = oli.Main_Package_ID__c;
                q1.Package_Product_Sub_Type__c          = oli.Main_Package_Product_Sub_Type__c;
                
                if(oli.Vendor_Conversion__c){
                    q1.Vendor_Conversion__c             = oli.Vendor_Conversion__c;
                    q1.Vendor_Subscription_To_Convert__c= oli.Vendor_Subscription_ID__c; 
                }
                 
            }else if(bAddOn){   
                q1.Main_Package__c                      = oli.Addon_Package__c;
                q1.Package_Product_Sub_Type__c          = oli.Add_On_Package_Product_Sub_Type__c;
            }else if(bGift){
                q1.Main_Package__c                      = null;
                q1.Package_Product_Sub_Type__c          = null;
            }
         
             
            q1.Order_Line_Item_Number__c                = oli.Id;
            q1.Order_Number__c                          = oli.Order__c;
            q1.Order_Line_Item_Number_1__c              = oli.Id;
            
            
            q1.Urgent__c                                = oli.Urgent__c;
            //q1.zqu__GenerateInvoice__c                  = oli.Generate_Invoice__c;
            q1.zqu__GenerateInvoice__c                  = true;
            q1.Suppress_Vendor_Start_Notice__c          = oli.Suppress_Vendor_Start_notice__c;
            q1.Supressed_Acknowledgement_Letter__c      = oli.Supressed_Acknowledgement_Letter__c;
            q1.Supressed_Renewal_and_Reminder_Letter__c = oli.Suppress_Renewal_and_Reminder_Letter__c;  
            
            q1.Vendor__c                                = oli.Vendor_Mailing_Agent__c;
            
            if(isFullPrepaid){
                q1.zqu__ProcessPayment__c               = true;
            }

            return q1;          
        }
        
        public void addQuoteChargeToQuote(List<Order_Line_Item__c> oliList, Map<id, List<Package_Item__c>> packIdToPackageItemListMap, Map<String, Set<id>> oliNameToQuoteId, Map<id, List<zqu__ProductRatePlanCharge__c>> prpIdToprpcListMap, Map<id, zqu__ProductRatePlanChargeTier__c> prcIdToPrpctMap, Map<Id, zqu__ProductRatePlan__c> prpIdToPrpMap){
    // START K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    
            Map<Id, List<zqu.zChargeGroup>> mapQuoteIdToChargeGroups = new Map<Id, List<zqu.zChargeGroup>>(); // START/END 03/26/2015 MD-59 Kevin Evasco - Quote Charges should be added using Charge Group
            zqu__QuoteCharge__c quoteCharge;
            List<zqu__QuoteCharge__c> quoteChargeList = new List<zqu__QuoteCharge__c>();
            Integer count = 0;
            
            //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
            Map<Id, List<zqu__QuoteCharge__c>>  quoteToquoteChargeMap = new Map<Id, List<zqu__QuoteCharge__c>>();
            
            
            for (Order_Line_Item__c oli :oliList) {
                
                for (Package_Item__c pkgItem : packIdToPackageItemListMap.get(oli.Main_Package_ID__c)) {
                    
                    count = 0;
                    for (Id quoteId :oliNameToQuoteId.get(oli.Name)) {
                        if(count != 1 && !quoteToquoteChargeMap.containsKey(quoteId)){
                            for (zqu__ProductRatePlanCharge__c prpc :prpIdToprpcListMap.get(pkgItem.Product_Rate_Plan__c)) {
                                
                                quoteCharge = new zqu__QuoteCharge__c();
                                
                                quoteCharge.Name = prpc.Name;
                                quoteCharge.zqu__Quote__c = quoteId;
                                quoteCharge.zqu__ProductRatePlanCharge__c =  prpc.id;
                                quoteCharge.zqu__Quantity__c = oli.Qty__c;
                                quoteCharge.zqu__EffectivePrice__c = prpc.sum__c;
                                quoteCharge.zqu__UOM__c = prpc.zqu__UOM__c;
                                quoteCharge.zqu__Period__c = prpc.zqu__RecurringPeriod__c;
                                quoteCharge.zqu__Model__c = prpc.zqu__Model__c;
                                quoteCharge.zqu__FeeType__c = prcIdToPrpctMap.get(prpc.Id).zqu__PriceFormat__c;//'Per Unit';
                                quoteCharge.zqu__Currency__c = prcIdToPrpctMap.get(prpc.Id).zqu__Currency__c;//'SGD';
                                quoteCharge.zqu__TimeProductAdded__c = String.ValueOf(Datetime.now());
                                quoteCharge.zqu__ChargeType__c = prpc.zqu__Type__c;
                                quoteCharge.zqu__PeriodNumeric__c = prpc.zqu__Upto_How_Many_Periods__c;
                                quoteCharge.zqu__RatePlanCharge_ZuoraID__c = prpc.zqu__ZuoraId__c;
                                quoteCharge.RecordTypeId = ConstantsSLB.getkeyid('Default Quote Charge'); 
                                quoteCharge.zqu__ProductName__c = string.ValueOf(prpIdToPrpMap.get(prpc.zqu__ProductRatePlan__c).Name);
                                quoteCharge.zqu__ProductRatePlanName__c = prpc.Name;
                                
                                quoteCharge.zqu__Discount_Level__c = prpc.zqu__Discount_Level__c;
                                quoteCharge.zqu__Upto_How_Many_Periods__c = prpc.zqu__Upto_How_Many_Periods__c;
                                
                                quoteChargeList.add(quoteCharge);
                                if(quoteToquoteChargeMap.containsKey(quoteId)){
                                    quoteToquoteChargeMap.get(quoteId).add(quoteCharge);    
                                }
                                else{
                                    quoteToquoteChargeMap.put(quoteId, new List<zqu__QuoteCharge__c>{quoteCharge});
                                        
                                }
                            }
                            count++;
                        }
                    }
                }
            }
                // END K. Tan MD-26 D-1907 /3-18-2015 /Added to cater Delivery charges    
            // START 03/26/2015 MD-59 Kevin Evasco - Quote Charges should be added using Charge Group
            zqu__ProductRatePlan__c ratePlanPostage = [SELECT Id,Name,zqu__ZProduct__c,zqu__ZProduct__r.ProductCode__c,
                               zqu__ZProduct__r.ProductType__c,zqu__ZProduct__r.ProductSubType__c 
                               FROM zqu__ProductRatePlan__c 
                               WHERE RatePlanCode__c = 'CHGPOS' AND zqu__Deleted__c = false limit 1]; 
            // END 03/26/2015 MD-59 Kevin Evasco - Quote Charges should be added using Charge Group
            
            for (Id postageId :postageQuoteToOliMap.keySet()) {
                if (quoteIdToQuote.containsKey(postageId)) {
                
                    zqu__Quote__c quote = quoteIdToQuote.get(postageId);
                    if (oliIdToOliMap.containsKey(quote.Order_Line_Item_Number__c)) {
                    
                    
                        Order_Line_Item__c oli = oliIdToOliMap.get(quote.Order_Line_Item_Number__c);
                        //START D-1689 23/01/15 Wenjun: Postage Charge is required for each publication
                        if (quote.Subscription_Type__c == 'Postage' && oli.Delivered_By__c == 'Mailing Agent') {
                            // START 03/26/2015 MD-59 Kevin Evasco - Quote Charges should be added using Charge Group
                            zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(quote.Id, ratePlanPostage.Id);     
                            if(mapQuoteIdToChargeGroups.get(quote.Id) == null)
                            {
                                mapQuoteIdToChargeGroups.put(quote.Id, new List<zqu.zChargeGroup>());
                            }
                            mapQuoteIdToChargeGroups.get(quote.Id).add(chargeGroup);                            
                            // END 03/26/2015 MD-59 Kevin Evasco - Quote Charges should be added using Charge Group
                        }
                        //END D-1689 23/01/15 Wenjun
                    }
                }
            }
            //END 01/19/15 J. Sarion - Updated to include proration charges
            
            insert quoteChargeList;
            
            // START 03/26/2015 MD-59 Kevin Evasco - Quote Charges should be added using Charge Group
            try{
                for(Id quoteID : mapQuoteIdToChargeGroups.keySet()) {
                    List<zqu.zChargeGroup> lstChargeGroups = mapQuoteIdToChargeGroups.get(quoteID);

                    if(lstChargeGroups != NULL && !lstChargeGroups.isEmpty()) {
                        //Add up to 30 Charge Groups to a Quote
                        if(lstChargeGroups.size() > 30)
                            throw new CustomException(System.Label.ERR_MAX_30_CHARGE_GROUP);
                        else
                            zqu.zQuoteUtil.addChargeGroups(lstChargeGroups);
                    }
                }
            }
            catch(Exception e){
                System.debug(System.LoggingLevel.ERROR, 'Charge Group Error: ' + e.getMessage() + ' : ' + e.getStackTraceString());
            }           
            // END 03/26/2015 MD-59 Kevin Evasco - Quote Charges should be added using Charge Group
            
        }
        
        //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
        public zqu__Quote__c zBuildPostageQuote (Order__c orderObj, Order_Line_Item__c itemObj, String sSubType, String origin) {
            zqu__Quote__c quote = new zqu__Quote__c ();    
            quote.Name                                     = itemObj.Name;
            quote.zqu__SubscriptionType__c                 = 'New Subscription';                    
            quote.zqu__ValidUntil__c                       = Date.Today().addMonths(1);
            quote.Qty1__c                                  = itemObj.Qty__c ;
            quote.Term_Length1__c                          = itemObj.Term_Length__c;
            quote.zqu__Subscription_Term_Type__c           = ConstantsSLB.getkeyid('SubTermTypeEvergreen');
            quote.zqu__Currency__c                         = ConstantsSLB.getkeyid('CurrencySGD');
            quote.zqu__InvoiceProcessingOption__c          = ConstantsSLB.getkeyid('QuoteInvoiceProcessingSubscription');
            quote.zqu__PaymentTerm__c                      = 'Due Upon Receipt';
            quote.zqu__StartDate__c                        = itemObj.Start_Date__c;
            quote.zqu__Service_Activation_Date__c          = itemObj.Start_Date__c;
            quote.Acquisition_Type__c                      = orderObj.Acquisition_Type__c;      
            quote.zqu__Account__c                          = orderObj.Account__c;        
            quote.Payment_Mode__c                          = orderObj.Payment_Mode__c; 
            quote.zqu__PaymentMethod__c                    = orderObj.Payment_Mode__c; 
            quote.Other_PaymentMethod__c                   = orderObj.Other_Payment_Mode__c;
            quote.zqu__SoldToContact__c                    = orderObj.Recipient_Contact__c;
            //Check if New Billing Account or Existing Billing Account
            if(orderObj.Billing_Account_External_ID__c != null){
                quote.zqu__ZuoraAccountID__c               = orderObj.Billing_Account_External_ID__c;   
            }else{
                quote.zqu__BillToContact__c                = orderObj.Billing_Contact__r.Id;   
            }
            
            //START 13/01/15 Wenjun: set addtional fields and set Vendor__c to Vendor_Mailing_Agent__c
            quote.zqu__AutoRenew__c                        = itemObj.Auto_Renew__c;
            quote.Charity__c                               = itemObj.Charity__c;
            quote.Delivered_By__c                          = itemObj.Delivered_By__c;
            quote.Vendor__c                                = itemObj.Vendor_Mailing_Agent__c;
            quote.Main_Package__c                          = itemObj.Main_Package_ID__c; // Start/End D-3197 17Jul15 JohnD
            //END 13/01/15 Wenjun
            quote.zqu__ElectronicPaymentMethodId__c        = orderObj.Payment_Method_ID__c;
            //D-0914 Populate Recipient Contact of Delivery Subscription
            quote.Recipient_Contact__c                     = orderObj.Recipient_Contact__c;            
            quote.Subscription_Type__c                     = sSubType;
            quote.Order_Number__c                          = orderObj.ID;
            quote.Order_Line_Item_Number__c                = itemObj.Id;
            quote.Order_Line_Item_Number_1__c              = itemObj.Id;
            quote.zqu__ProcessPayment__c                   = false;
            quote.zqu__GenerateInvoice__c                  = false;
            quote.Generate_Invoice1__c                     = false; 
        
            if(itemObj.Main_Package_ID__r.Subscription_Type__c == ConstantsSLB.getkeyid('SubTermTypeTermed') ){
                if (itemObj.Main_Package_ID__r.Subscription_Period__c != null) {
                    quote.zqu__InitialTerm__c = Integer.valueof(itemObj.Main_Package_ID__r.Subscription_Period__c);
                } else {
                    quote.zqu__InitialTerm__c = 0;
                }
                quote.zqu__RenewalTerm__c = 0;
            }
            return quote;
        }
        
        
        public List<zqu__QuoteCharge__c> zPopulateQuoteChargePostage(Id zQuoteId,Order_Line_Item__c oli) {                  
            List<zqu__QuoteCharge__c> lstCharges = new List<zqu__QuoteCharge__c>();
        
            if (postagePrp != null) {
                for(zqu__ProductRatePlanCharge__c prpc: postagePrpIdToPrpcListMap.get(postagePrp.ID)){

                    zqu__QuoteCharge__c zQuoteCharge = new zqu__QuoteCharge__c();
                    
                    zQuoteCharge.Name = prpc.Name;
                    zQuoteCharge.zqu__Quote__c = zQuoteId;
                    zQuoteCharge.zqu__ProductRatePlanCharge__c =  prpc.id;
                    zQuoteCharge.zqu__Quantity__c = (oli.Qty__c == 0) ? 1 : oli.Qty__c;

                    if(oli.Charity__c){
                        zQuoteCharge.zqu__EffectivePrice__c = 0;
                    }
                    else{
                        if (oli.Postage_Charge__c != null) {
                            zQuoteCharge.zqu__EffectivePrice__c = (prpc.sum__c < 0) ? -(oli.Postage_Charge__c) : oli.Postage_Charge__c;
                        }
                        else {
                            zQuoteCharge.zqu__EffectivePrice__c = 0;
                        }
                    }
                    
                    zQuoteCharge.zqu__UOM__c = prpc.zqu__UOM__c;
                    zQuoteCharge.zqu__Period__c = prpc.zqu__RecurringPeriod__c;
                    zQuoteCharge.zqu__Model__c = prpc.zqu__Model__c;

                    if (postagePrpcIdToPrpctMap.containsKey(prpc.Id)) {
                        zQuoteCharge.zqu__FeeType__c = (postagePrpcIdToPrpctMap.get(prpc.Id).zqu__PriceFormat__c != null ? postagePrpcIdToPrpctMap.get(prpc.Id).zqu__PriceFormat__c : null);//'Per Unit';
                        zQuoteCharge.zqu__Currency__c = (postagePrpcIdToPrpctMap.get(prpc.Id).zqu__Currency__c != null ? postagePrpcIdToPrpctMap.get(prpc.Id).zqu__Currency__c : null);//'SGD';
                    }
                    
                    zQuoteCharge.zqu__TimeProductAdded__c = String.ValueOf(Datetime.now());
                    zQuoteCharge.zqu__ChargeType__c = prpc.zqu__Type__c;
                    zQuoteCharge.zqu__PeriodNumeric__c = prpc.zqu__Upto_How_Many_Periods__c;
                    zQuoteCharge.zqu__RatePlanCharge_ZuoraID__c = prpc.zqu__ZuoraId__c;
                    zQuoteCharge.RecordTypeId = ConstantsSLB.getkeyid('Default Quote Charge'); 
                    zQuoteCharge.zqu__ProductName__c = postagePrp.Name;
                    zQuoteCharge.zqu__ProductRatePlanName__c = prpc.Name;
                    
                    zQuoteCharge.zqu__Discount_Level__c = prpc.zqu__Discount_Level__c;
                    zQuoteCharge.zqu__Upto_How_Many_Periods__c = prpc.zqu__Upto_How_Many_Periods__c;

                    lstCharges.add(zQuoteCharge); 
                }
            }
            return lstCharges;      
        }
        
            
                         
    
                               
            
                                
        
    // START K. Tan MD-26 D- 2592 /3-21-2015 /Added to cater Delivery charges    
        public zqu__Quote__c createQuoteDelivery (Order__c orderObj, Order_Line_Item__c ordItem, String sSubType, String origin){
            zqu__Quote__c q1 = new zqu__Quote__c ();    
            q1.Name                                     = ordItem.Name;
            q1.zqu__SubscriptionType__c                 = 'New Subscription';                    
            q1.zqu__ValidUntil__c                       = Date.Today().addMonths(1);
            //START: D-2910 Added by JTeves 15-May-2105 - Copy Term Type and Term Length from Main Subscription
            //q1.zqu__Subscription_Term_Type__c           = TERM_EVER_GREEN;
            q1.zqu__Subscription_Term_Type__c           = ordItem.Main_Package_ID__r.Subscription_Type__c;
            q1.Term_Length1__c = ordItem.Term_Length__c;
            if (ordItem.Term_Length__c != null) {
                q1.zqu__InitialTerm__c = Integer.valueof(ordItem.Term_Length__c);
            } else {
                q1.zqu__InitialTerm__c = 0;
            }
            q1.zqu__RenewalTerm__c = 0;
            //END: D-2910 Added by JTeves 15-May-2105 - Copy Term Type and Term Length from Main Subscription
            q1.zqu__Currency__c                         = CURRENCY_SGD;
            q1.zqu__InvoiceProcessingOption__c          = INVOICE_PROC_OPTION;
            if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBL) {
                q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBL;
            }
            else if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBH) {
                q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBH;
            }
            else if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.GOVT) {
                q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_GOVT;   
            }
            else {
                q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_NORM;
            }
            q1.zqu__StartDate__c                        = orderObj.Delivery_Start_Date__c;
            q1.zqu__Service_Activation_Date__c          = orderObj.Delivery_Start_Date__c;
            q1.Acquisition_Type__c                      = orderObj.Acquisition_Type__c;      
            q1.zqu__Account__c                          = orderObj.Account__c;        
            q1.Payment_Mode__c                          = orderObj.Payment_Mode__c; 
            q1.zqu__PaymentMethod__c                    = orderObj.Payment_Mode__c; 
            q1.Other_PaymentMethod__c                   = orderObj.Other_Payment_Mode__c;
            q1.zqu__SoldToContact__c                    = orderObj.Recipient_Contact__c;
            if(orderObj.Billing_Account_External_ID__c != null  || origin == 'ESHOP Webservice'){
                q1.zqu__ZuoraAccountID__c               = orderObj.Billing_Account_External_ID__c;   
            }else{
                q1.zqu__BillToContact__c                = orderObj.Billing_Contact__r.Id;   
            }
            
            q1.zqu__ElectronicPaymentMethodId__c        = orderObj.Payment_Method_ID__c;
            q1.Recipient_Contact__c                     = orderObj.Recipient_Contact__c;            
            q1.Subscription_Type__c                     = sSubType;
            q1.Order_Number__c                          = orderObj.ID;
            q1.Delivery_Charge_Type__c                  = orderObj.Delivery_Charge_Type__c;
            q1.zqu__ProcessPayment__c                   = false;
            q1.zqu__GenerateInvoice__c                  = false;
            q1.Generate_Invoice1__c                     = false;
            q1.Unique_Delivery_Identifier__c           = orderObj.Recipient_Contact__r.Address__r.Address_Unique_Id__c;
            q1.Delivered_By__c                          = ordItem.Delivered_By__c;
            q1.Vendor__c                                = ordItem.Vendor_Mailing_Agent__c;
            q1.Recipient_Contact__c                     = orderObj.Recipient_Contact__c;            
            q1.Order_Number__c                          = orderObj.ID;
            q1.Order__c                                 = orderObj.ID; // Start/End UD-0275 11-03-2015 JohnD
            q1.Order_Line_Item_Number__c                = ordItem.Id;
            q1.Order_Line_Item_Number_1__c              = ordItem.Id;
            q1.Subscriber_Charge__c                     = orderObj.Subscriber_Charge__c;
            q1.Vendor_Credit__c                         = orderObj.Vendor_Credit__c;
            q1.Main_Package__c                          = ordItem.Main_Package_ID__c; // Start/End D-3197 16/7/2015 GDelRosario
            try{
                Promotion_Package__c proPack = [Select Package_Name__c From Promotion_Package__c
                                                Where Package_Name__c =: ordItem.Main_Package_Id__c LIMIT 1];
                
                if(proPack != null)
                {
                    q1.Contract_End_Date__c = ordItem.Contract_End_Date__c; 
                    q1.New_Contract_Period__c = ordItem.New_Contract_Period__c;
                }
             }
            catch(Exception e)
            {
                q1.Contract_End_Date__c = null;
                q1.New_Contract_Period__c = null;
            }
            q1.Promotion_Contract_Period__c     = ordItem.Promotion_Contract_Period__c; 
        return q1;
        }
    // END K. Tan MD-18 D-2592 /3-18-2015 / New Implememtation of Delivery charges   

            
                
                
        
        
        
    }