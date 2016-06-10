public class BulkQuoteHandler {
    
    final string ADDRESS_TYPE_AIRLINE = ConstantsSLB.getKeyId('AddAirline');
    final string ADDRESS_TYPE_OVERSEAS = ConstantsSLB.getKeyId('AddOverseas');
    final string ADDRESS_TYPE_LOCAL = ConstantsSLB.getKeyId('AddLocal');
    final string ADDRESS_TYPE_INTERNAL = ConstantsSLB.getKeyId('AddInternal');  
    final string TERM_EVER_GREEN = ConstantsSLB.getKeyId('SubTermTypeEvergreen');
    final string CURRENCY_SGD = ConstantsSLB.getKeyId('CurrencySGD');
    final string INVOICE_PROC_OPTION = ConstantsSLB.getKeyId('QuoteInvoiceProcessingSubscription');
    final string RT_ID_BUNDLE_PROD = ConstantsSLB.getKeyId('Package Item_Bundle Product');
    final string TERM_TYPE_TERMED = ConstantsSLB.getkeyid('SubTermTypeTermed');
    final string NEW_SUBSCRIPTION = 'New Subscription';
    final string PAYMENT_TERM = 'Due Upon Receipt';
    final string ERR_RECORD_LOCK = 'UNABLE_TO_LOCK_ROW';
    
    public String source = '';

    map<id, list<zqu__ProductRatePlanCharge__c>> postagePrpIdToPrpcListMap = new map<id, list<zqu__ProductRatePlanCharge__c>>();
    map<id, zqu__ProductRatePlanChargeTier__c> postagePrpcIdToPrpctMap = new map<id, zqu__ProductRatePlanChargeTier__c>();
    map<id, zqu__Quote__c> quoteIdToQuote = new map<id, zqu__Quote__c>();
    map<id, zqu__ProductRatePlan__c> postagePrpIdToPrpMap = new map<id, zqu__ProductRatePlan__c>();
    map<id, Order_Line_Item__c> oliIdToOliMap = new map<id, Order_Line_Item__c>();
    map<id, Id> postageQuoteToOliMap = new map<id, Id>();
    map<id, map<id, id>> orderLineItemId_packageItemId_productId;   // use to mapped in creating quote charge
    map<id, id> packageItemId_productId;            
    map<id, string> packageItemId_subscriptionFrequency = new map<id, string>();    //START-END D-4080 12-14-2015 added by Jason A. for code review
    map<id, map<string, id>> productId_frequency_prorationRatePlanId = new map<id, map<string, id>>();  // use to mapped in creating quote charge
    map<string, id> frequency_prorationRatePlanId;
    map<id, id> productId_nonChargeableProrationRatePlanId = new map<id, id>();
    map<id, string> quoteId_frequency = new map<id, string>();
    map<id, zqu__ProductRatePlan__c> orderIdToProductRatePlanMap = new map<id, zqu__ProductRatePlan__c>();
    map<string, string> frequencyName_frequencyCode = new map<string, string>();
    
    list<zqu__Quote__c> zQuoteListRet = new list<zqu__Quote__c>();
    list<zqu__ProductRatePlanCharge__c> postagePrpcList = new list<zqu__ProductRatePlanCharge__c>();
    list<zqu__ProductRatePlanChargeTier__c> postagePrpctList = new list<zqu__ProductRatePlanChargeTier__c>();
    list<exception> exceptionList = new list<exception>();
    
    set<id> accountIDset = new set<id>();
    set<id> result_createdQuoteIdSet = new set<id>();
    set<string> recipientAddUniqueIdSet = new set<string>();
    
    zqu__ProductRatePlan__c ratePlanDelivery;
    zqu__Quote__c quoteReturn; 
    zqu__ProductRatePlan__c postagePrp = new zqu__ProductRatePlan__c();
    zqu__ProductRatePlanChargeTier__c postagePrpct = new zqu__ProductRatePlanChargeTier__c();

    boolean bCreateDeliverySubscription;
    boolean hasVendorDelivery = false;
    map<id, boolean> orderId_hasVendorDelivery = new map<id, boolean>();    // Start/End UD-3541 18Jan16 JohnD
    string frequency;
    
    //START UD-3660 4March2016 FrancisBenzon : variables for discount
    public static String RT_ID_BUNDLE_DISC = ConstantsSLB.getKeyId('Package Item_Bundle Discount');
    public static String RT_ID_DISC = ConstantsSLB.getKeyId('Package Item_Discount');
    public static String RT_ID_EXT_DISC = ConstantsSLB.getKeyId('Package Item_Extension Discount');
    Set<ID> setDiscRatePlanIDs = new Set<ID>();
    Map<ID, Decimal> mapRatePlanIDToDisc = new Map<Id, Decimal>();
    Map<String, Decimal> mapQuoteIdToDisc = new Map<String, Decimal>();
    Map<Id, list<Package_Item__c>> mPackageToPackageItems = new Map<Id, list<Package_Item__c>>();
    Map<Id, String> mapPackItemToQuoteName = new Map<Id, String>();
    Map<Id, Date> package_oliStartDateMap = new Map<Id, Date>();
    Map<String, DiscountChargeWrapper> mapDiscountCharges = new Map<String, DiscountChargeWrapper>();
    map<id, list<Package_Item__c>> basePackageItemId_discountPackageItemList = new map<id, list<Package_Item__c>>();
    //END UD-3660 4March2016 FrancisBenzon : variables for discount
    
    // Start UD-3660 JohnD 11Apr16
    map<id, id> quoteId_packageItemId = new map<id, id>();
    map<id, id> packageItemId_productRatePlanId = new map<id, id>();
    list<zqu__Quote__c> quote2CleanList = new list<zqu__Quote__c>();
    map<id, list<id>> quoteId_ratePlanIdList = new map<id, list<id>>();
    list<zqu__Quote__c> consolidatedQuoteList = new list<zqu__Quote__c>();
    set<id> consolidatedProductIdSet = new set<id>();
    map<id, id> pckageItemId_productId = new map<id, id>();
    map<id, decimal> orderLineItemId_postageChargeAmount = new map<id, decimal>();
    Logger logger = new Logger(BulkQuoteHandler.class.getName());
    // End UD-3660 JohnD 11Apr16
    public set<string> bulkQuoteCreation(set<id> orderIdSet, String origin) {

        map<id, list<Order_Line_Item__c>> orderIdOrderLineItemMap = new map<id, list<Order_Line_Item__c>>();
        map<id, list<Order_Line_Item_Gift__c>> orderLineToGiftMap = new map<id, list<Order_Line_Item_Gift__c>>();       
        map<id, Order__c> orderIdToOrderMap = new map<id, Order__c>();
        map<id, list<Package_Item__c>> packIdToPackItemListMap = new map<id, list<Package_Item__c>>();
        map<id, list<zqu__ProductRatePlanCharge__c>> prpIdToprpcListMap = new map<id, list<zqu__ProductRatePlanCharge__c>>();
        map<id, zqu__ProductRatePlanChargeTier__c> ratePlanChargeTierMap = new map<id, zqu__ProductRatePlanChargeTier__c>();
        map<string, set<id>> quoteIdToQuoteMap = new map<string, set<id>>();
        map<id, zqu__ProductRatePlan__c> prpIdToPrpMap = new map<id, zqu__ProductRatePlan__c>();
        map<id, set<id>> orderIdToQuoteIdSetMap = new map<id, set<id>>();
        map<id, String> orderIdToSubZuoraIdMap = new map<id, String>();       
        map<id,Id> result_quote_product_map = new map<id,Id>();
        map<id,list<id>> result_product_productRatePlanList_map = new map<id,list<id>>();
        
        list<Order__c> orderList = new list<Order__c>();
        list<zqu__Quote__c> quoteList = new list<zqu__Quote__c>();
        list<Zuora__Subscription__c> subList = new list<Zuora__Subscription__c>();
        list<Order_Line_Item__c> orderLineItemList = new list<Order_Line_Item__c>();
        list<zqu__QuoteCharge__c> result_quoteChargeList;       
        list<zqu__ProductRatePlan__c> result_productRatePlanList;

        set<string> quoteNameSet = new set<string>();
        set<id> orderLineItemIdSet = new set<id>();
        set<id> packageIdSet = new set<id>();
        set<string> quoteAccountZuoraIdSet = new set<string>();
        set<id> result_productIdSet = new set<id>();

        boolean isRecordLock = true;
        
        orderList = getOrder(orderIdSet);       
       system.debug('===>TEST orderIdSet: ' + orderIdSet);
       system.debug('===>TEST orderList: ' + orderList);
        for (Order__c order : orderList) {            
            orderIdToOrderMap.put(order.Id, order);
            accountIDset.add(order.Account__c);
            recipientAddUniqueIdSet.add(order.Recipient_Contact__r.Address__r.Address_Unique_ID__c);
        }

        orderIdOrderLineItemMap = getOrderLineItem(orderIdSet);                     
        
       system.debug('===>TEST orderIdOrderLineItemMap.keySet(): ' + orderIdOrderLineItemMap.keySet());
        for (Id orderId : orderIdOrderLineItemMap.keySet()) {                             

            hasVendorDelivery = false;  // Start/End UD-3541 18Jan16 JohnD
            for (Order_Line_Item__c orderLineItem : orderIdOrderLineItemMap.get(orderId)) {

                if (orderLineItem.Delivered_By__c == GlobalVariableClass.OLIDELIVEREDBY_VENDOR) {
                    hasVendorDelivery = true;
                }

                orderLineItemList.add(orderLineItem);
                orderLineItemIdSet.add(orderLineItem.id);
                
                if (orderLineItem.Main_Package_ID__c != null) {
                    packageIdSet.add(orderLineItem.Main_Package_ID__c);
                }
                
                if (orderLineItem.Addon_Package__c != null) {
                    packageIdSet.add(orderLineItem.Addon_Package__c);
                }
            }
            
            orderId_hasVendorDelivery.put(orderId, hasVendorDelivery);  // Start/End UD-3541 18Jan16 JohnD
       system.debug('===>TEST orderId_hasVendorDelivery: ' + orderId_hasVendorDelivery);
        }
        
        prepareProrationVariables(orderLineItemList);
        orderIdSet.remove(null); 
        
        subList = [SELECT Id, Zuora__Zuora_Id__c, Order_Number_1__c FROM Zuora__Subscription__c WHERE Order_Number_1__c IN :orderIdSet];
    
        for (Zuora__Subscription__c sub :subList) {
            orderIdToSubZuoraIdMap.put(sub.Order_Number_1__c, sub.Zuora__Zuora_Id__c);
        }
        
        orderLineToGiftMap = getOrderLineItemGifts(orderLineItemIdSet);
        packIdToPackItemListMap = getPackage(packageIdSet, orderIdOrderLineItemMap);
        prpIdToPrpMap = getProductRatePlan(packIdToPackItemListMap);
        prpIdToprpcListMap = getProdRatePlanCharge(prpIdToPrpMap);
        ratePlanChargeTierMap = getProdRatePlanChargeTier(prpIdToprpcListMap);
        orderIdToProductRatePlanMap = getDeliveryCharge(orderList);
        //START UD-3660 4March2016 FrancisBenzon :  Query Discount Percentage
        if(!setDiscRatePlanIDs.isEmpty())
        {
            for(zqu__ProductRatePlanCharge__c charge: [SELECT zqu__ProductRatePlan__c,sum__c FROM zqu__ProductRatePlanCharge__c 
                                                        WHERE zqu__Deleted__c = false 
                                                        and zqu__ProductRatePlan__c in :setDiscRatePlanIDs])
            {
                mapRatePlanIDToDisc.put(charge.zqu__ProductRatePlan__c, charge.sum__c);
            }
            system.debug(':::MapRpToDISC ' + mapRatePlanIDToDisc);
        }   
        //END UD-3660 4March2016 FrancisBenzon :  Query Discount Percentage
        
        // start create delivery quote
        for (Id orderId : orderIdOrderLineItemMap.keySet()) {                             

            for (Order_Line_Item__c orderLineItem : orderIdOrderLineItemMap.get(orderId)) {
                
                bCreateDeliverySubscription = false;
                 system.debug(':::DeliveredBy ' + orderLineItem.Delivered_By__c + ' :::ratePlanDelivery ' + ratePlanDelivery);
                if (orderLineItem.Delivered_By__c == 'Vendor' && ratePlanDelivery != NULL) {
                    bCreateDeliverySubscription = true;    
                }

                if (bCreateDeliverySubscription == true) {
                    system.debug(':::DELIVERYPARAMS ' + orderIdToOrderMap.get(orderId) + ' :::OLI '  + orderLineItem + ' ' + ConstantsSLB.getkeyid('SubTypeDel') + ' orig ' + origin);
                    quoteReturn = new zqu__Quote__c ();
                    quoteReturn = createQuoteDelivery(orderIdToOrderMap.get(orderId), orderLineItem, ConstantsSLB.getkeyid('SubTypeDel'), origin );
                    
                    if (quoteReturn != null) {
                        zQuoteListRet.add(quoteReturn);
                        
                    }
                }
            }
        }
        // end create delivery quote
        
        // Start UD-3660 11Apr16 JohnD - new method created for record locking issue
        // Start - insist insertion
        /*
        while (isRecordLock) {
            
            try {
                
                insert zQuoteListRet;
                isRecordLock = false;
            
                consolidatedQuoteList.addAll(zQuoteListRet);    // Start/End UD-3660 11Apr16 JohnD 
            } catch (dmlexception e) {
                isRecordLock = e.getMessage().contains('UNABLE_TO_LOCK_ROW');
            }               
        }
        */
        // End - insist insertion
        if(!zQuoteListRet.isEmpty()){
            zQuoteListRet = insertQuotes(zQuoteListRet);
        	consolidatedQuoteList.addAll(zQuoteListRet);
        }
        
        // End UD-3660 11Apr16 JohnD - revised approach on retry mechanism
        
        // Start UD-3660 11Apr16 JohnD - revised approach, create quote charges in one execution
        //if(!zQuoteListRet.isEmpty() ){
        if(!zQuoteListRet.isEmpty() ){
            for (zqu__Quote__c zquoret :zQuoteListRet) {

                if (quoteId_ratePlanIdList.get(zquoret.Id) == null) {
                    quoteId_ratePlanIdList.put(zquoret.Id, new list<id>());
                }
                
                quoteId_ratePlanIdList.get(zquoret.Id).add(orderIdToProductRatePlanMap.get(Id.valueOf(zquoret.Order_Number__c)).Id);
                /* commented out
                try {
                
                    list<zqu.zChargeGroup> lstChargeGroups = new list<zqu.zChargeGroup>();
    
                    zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(zquoret.Id, orderIdToProductRatePlanMap.get(Id.valueOf(zquoret.Order_Number__c)).Id);
                    lstChargeGroups.add(chargeGroup); 
                    zqu.zQuoteUtil.addChargeGroups(lstChargeGroups); 
                
                } catch(exception e) {
                    exceptionList.add(e);
                }
                */              
            }
        }
            
           
       // }
        
        // End UD-3660 11Apr16 JohnD - revised approach, create quote charges in one execution
        
        system.debug('===>TEST orderIdOrderLineItemMap: ' + orderIdOrderLineItemMap);
        quoteIdToQuoteMap = createQuote(orderIdOrderLineItemMap, packIdToPackItemListMap, orderLineToGiftMap, orderIdToOrderMap, orderIdToSubZuoraIdMap);
        system.debug('===>TEST quoteIdToQuoteMap: ' + quoteIdToQuoteMap);
        addQuoteChargeToQuote(orderLineItemList, packIdToPackItemListMap, quoteIdToQuoteMap, prpIdToprpcListMap, ratePlanChargeTierMap, prpIdToPrpMap);    
        
        //START UD-3660 4March2016 FrancisBenzon : setup discount charges
         for(Order_Line_Item__c oli:orderLineItemList)
         {
            for(Package_Item__c pckItm : packIdToPackItemListMap.get(oli.Main_Package_ID__c))
            {
                if(RT_ID_DISC == pckItm.RecordTypeId || RT_ID_BUNDLE_DISC == pckItm.RecordTypeId || RT_ID_EXT_DISC == pckItm.RecordTypeId)
                {
                    Id baseItemId = pckItm.Base_Package_Item__c;
                    if(baseItemId == NULL || !mapPackItemToQuoteName.containsKey(baseItemId))
                        throw new CustomException(System.Label.ERR_INVALID_PACKAGE + ' Item ID: ' + pckItm.Id);
                    
                     //Prepare data for later overwrite
                    String key = mapPackItemToQuoteName.get(baseItemId) + '-' +pckItm.Product_Rate_Plan__c;
                    Integer startMonth = Integer.valueOf(pckItm.Effective_Start_Month__c);
                    
                    Integer duration;
                    Boolean isNone = false;
                    if(pckItm.Duration_in_months__c != 'N/A'){
                        duration = Integer.valueOf(pckItm.Duration_in_months__c); }
                    else{
                        duration = 0;
                        isNone = true;
                    }
                    
                    
                    if(startMonth == 1)
                    {
                        Decimal discountRate = mapRatePlanIDToDisc.get(pckItm.Product_Rate_Plan__c);
                        mapQuoteIdToDisc.put(mapPackItemToQuoteName.get(baseItemId), discountRate);
                    }
                            
                    mapDiscountCharges.put(key, new DiscountChargeWrapper(startMonth, duration, oli.Start_Date__c, isNone));
                }
            }
            system.debug(':::MapQuoteIdToDisc ' + mapQuoteIdToDisc);
            system.debug(':::mapDiscountCharges ' + mapDiscountCharges);
         }
            
        //END UD-3660 4March2016 FrancisBenzon : setup discount charges
        System.debug('#$# quoteIdToQuoteMap.keySet():' + quoteIdToQuoteMap.keySet());
        for (String quoteName :quoteIdToQuoteMap.keySet()) {
            quoteNameSet.add(quoteName);
        }
        System.debug('#$# quoteNameSet:' + quoteNameSet);
        // Start UD-3660 JohnD 08Apr16
        // 11Apr16 quoteList = [SELECT Id, zqu__ZuoraAccountID__c, Frequency__c, Order_Number__c, zqu__Description__c  FROM zqu__Quote__c WHERE Id IN :result_createdQuoteIdSet];   // Start/End UD-2865
        // End UD-3660 JohnD 08Apr16
        
        // Start UD-3660 11Apr16 JohnD - proration quotes
        result_productRatePlanList = [SELECT Id, zqu__ZProduct__c, SubscriptionFrequency__c, RatePlanSubType__c  
                FROM zqu__ProductRatePlan__c WHERE zqu__ZProduct__c IN :consolidatedProductIdSet 
                AND RatePlanType__c = 'Proration' and zqu__Deleted__c = false];     // Start UD-3660 11Apr16 JohnD - changed variable reference
        

        for (zqu__ProductRatePlan__c prp : result_productRatePlanList) {
            
            if (prp.RatePlanSubType__c == 'Standard') {
                
                frequency_prorationRatePlanId = new map<string, id>();
                
                if (productId_frequency_prorationRatePlanId.get(prp.zqu__zProduct__c) != null) {
                    frequency_prorationRatePlanId = productId_frequency_prorationRatePlanId.get(prp.zqu__zProduct__c);
                }
                
                frequency_prorationRatePlanId.put(prp.SubscriptionFrequency__c, prp.Id);
                productId_frequency_prorationRatePlanId.put(prp.zqu__zProduct__c, frequency_prorationRatePlanId);
            
            } else {
                productId_nonChargeableProrationRatePlanId.put(prp.zqu__zProduct__c, prp.Id);
            }
            
            // Start UD-3660 11Apr16 JohnD - revised logic
            if (result_product_productRatePlanList_map.get(prp.zqu__ZProduct__c) == null) {
                result_product_productRatePlanList_map.put(prp.zqu__ZProduct__c, new list<id>());
            }
            
            result_product_productRatePlanList_map.get(prp.zqu__ZProduct__c).add(prp.Id);
            // End UD-3660 11Apr16 JohnD - revised logic
        }
        
        /* Start UD-3660 11Apr16 JohnD - commented out
        if (result_productRatePlanList != null) {

            for (zqu__ProductRatePlan__c result_productRatePlan : result_productRatePlanList) {
                
                if (result_product_productRatePlanList_map.get(result_productRatePlan.zqu__ZProduct__c) == null) {
                    result_product_productRatePlanList_map.put(result_productRatePlan.zqu__ZProduct__c, new list<id>());
                }
                
                result_product_productRatePlanList_map.get(result_productRatePlan.zqu__ZProduct__c).add(result_productRatePlan.Id);
            }
        }*/
        
        for (zqu__Quote__c quote :consolidatedQuoteList) {
            
            id result_productId;
            string quoteFrequency = frequencyName_frequencyCode.get(quote.Frequency__c);
            list<id> result_corresponding_productRatePlanList = new list<id>(); // Start/End UD-2865 22Sep15 JohnD - instantiated
            
            // Start UD-3660 11Apr16 JohnD - 
            if (quote.zqu__Description__c instanceOf id && packageItemId_productId.containsKey(quote.zqu__Description__c)) {
                result_productId = packageItemId_productId.get(quote.zqu__Description__c);
            }
            // End UD-3660 11Apr16 JohnD - 
            if (result_product_productRatePlanList_map.containsKey(result_productId)) {
                result_corresponding_productRatePlanList = result_product_productRatePlanList_map.get(result_productId);
            }
            
            if (result_corresponding_productRatePlanList != null && !result_corresponding_productRatePlanList.isEmpty()) {  // Start/End UD-2865 - added isempty
                
                list<id> ratePlanIdList = new list<id>();
                    
                frequency_prorationRatePlanId = productId_frequency_prorationRatePlanId.get(result_productId);
                if (frequency_prorationRatePlanId.get(quoteFrequency) != null) {
                    ratePlanIdList.add(frequency_prorationRatePlanId.get(quoteFrequency));
                }
                
                if (productId_nonChargeableProrationRatePlanId.get(result_productId) != null) {
                    ratePlanIdList.add(productId_nonChargeableProrationRatePlanId.get(result_productId));
                }
                
                if (quoteId_ratePlanIdList.get(quote.Id) == null) {
                    quoteId_ratePlanIdList.put(quote.Id, new list<id>());
                }
                
                quoteId_ratePlanIdList.get(quote.Id).addAll(ratePlanIdList);
                //list<zqu.zChargeGroup> cg1 = zqu.zQuoteUtil.getChargeGroups(quote.Id, ratePlanIdList);
                //zqu.zQuoteUtil.addChargeGroups(cg1);    
            }  
        }
        // End UD-3660 11Apr15 JohnD - prorations quotes
        
        // Start UD-3660 11Apr15 JohnD - create quote charges
        
        system.debug('Johnxxxxxxx :: ' + quoteId_ratePlanIdList);
        if(quoteId_ratePlanIdList != null && !quoteId_ratePlanIdList.isEmpty()){
            for (id quoteId : quoteId_ratePlanIdList.keySet()) {
            system.debug('===>BQH quoteId: ' + quoteId + '\n quoteId_ratePlanIdList.get(quoteId): ' + quoteId_ratePlanIdList.get(quoteId) + '\n quoteId_ratePlanIdList: ' + quoteId_ratePlanIdList);
            
            // Start UD-3660 24May2016 JC Aduan : to avoid manage package class callout upon test class
            if(!test.isRunningTest()){
                zqu.zQuoteUtil.addChargeGroups(zqu.zQuoteUtil.getChargeGroups(quoteId, quoteId_ratePlanIdList.get(quoteId)));
            }
            // End UD-3660 24May2016 JC Aduan : and to throw a return value for this method       
        }
            
        }
        
        // End UD-3660 11Apr15 John
        
        
        // start override prices
        /* Start UD-3660 11Apr16 commented out - not in use
        for (zqu__Quote__c quote :quoteList) {
            quoteAccountZuoraIdSet.add(quote.zqu__ZuoraAccountID__c);
        } End UD-3660 11Apr16 commented out - not in use */       
        
        result_createdQuoteIdSet.remove(null); 
        //START UD-3660 4March2016 FrancisBenzon : update quoteCharge with discount
        result_quoteChargeList = [SELECT Id, zqu__Quote__r.Id, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Id,
                                    zqu__Quote__r.Name, zqu__Quote__c, zqu__Quantity__c, zqu__Quote__r.Qty1__c, zqu__UOM__c, zqu__Model__c,  
                                    zqu__EffectivePrice__c, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, zqu__Description__c,
                                    zqu__Quote__r.zqu__Description__c, zqu__Quote__r.Order_Line_Item_Number_1__r.Postage_Charge__c,
                                    zqu__Quote__r.Subscription_Type__c 
                                    FROM zqu__QuoteCharge__c WHERE zqu__Quote__c IN :quoteId_ratePlanIdList.keySet()]; // Start/End UD-3660 11Apr16 - changed variable  refennce and added field//fritz2
        
        for (zqu__QuoteCharge__c result_quoteCharge : result_quoteChargeList) {
            
            result_productIdSet.add(result_quoteCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Id);
            result_quote_product_map.put(result_quoteCharge.zqu__Quote__r.Id, result_quoteCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Id);
            
            //START PD-0041 FrancisBenzon 19May16 : set correct quoteChargeQty
            if(result_quoteCharge.zqu__Quantity__c != NULL && result_quoteCharge.zqu__Quantity__c > 0)
                    result_quoteCharge.zqu__Quantity__c = result_quoteCharge.zqu__Quote__r.Qty1__c;
            //END PD-0041 FrancisBenzon 19May16 : set correct quoteChargeQty
            
            if(mapQuoteIdToDisc.containsKey(result_quoteCharge.zqu__Quote__r.Name) && result_quoteCharge.zqu__EffectivePrice__c < 0 && result_quoteCharge.zqu__Model__c == GlobalVariableClass.SPC_MODEL_UNIT)
            {
                Decimal discRate = mapQuoteIdToDisc.get(result_quoteCharge.zqu__Quote__r.Name);
                if(discRate != NULL) 
                {
                    Decimal newPrice = result_quoteCharge.zqu__EffectivePrice__c * (1 - discRate/100);
                    newPrice = newPrice.setScale(2, System.RoundingMode.HALF_UP);
                    result_quoteCharge.zqu__EffectivePrice__c = newPrice;
                }
            }
            // Start UD-3660 11Apr16 JohnD 
            else if (result_quoteCharge.zqu__Quote__r.Subscription_Type__c == 'Postage'
                    && result_quoteCharge.zqu__UOM__c <> GlobalVariableClass.DUMMY_CHARGE) {
                //Overwrite Postage Charge Value
                Decimal postageAmt = result_quoteCharge.zqu__Quote__r.Order_Line_Item_Number_1__r.Postage_Charge__c;
                result_quoteCharge.zqu__EffectivePrice__c = 
                    (ConstantsSLB.getUOM('PostageCharge') == result_quoteCharge.zqu__UOM__c) ?  postageAmt: -postageAmt;
            }
            // End UD-3660 11Apr16 JohnD
            
             else
            {
                String key = result_quoteCharge.zqu__Quote__r.Name + '-'+ result_quoteCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c;
                DiscountChargeWrapper discountCharge = mapDiscountCharges.get(key);

                //Overwrite Discount Quotes
                if(discountCharge != NULL)
                {
                     Integer startMonth = discountCharge.effectStartMonth;
                     if(startMonth != 1) //For Tiered Discount
                     {
                         result_quoteCharge.zqu__TriggerEvent__c = 'SpecificDate';
                         Date startDate = discountCharge.startDate;
                         Integer intMthToAdd = (startDate.day() == 1) ? startMonth -1 : startMonth;
                         result_quoteCharge.zqu__TriggerDate__c = startDate.toStartOfMonth().addMonths(intMthToAdd);
                     }
                    
                    //Set Up To How Many Months 
                    //START UD-0460 MGaelo Add logic for N/A duration and up to how many periods
                    if(discountCharge.isNone){
                        result_quoteCharge.zqu__Upto_How_Many_Periods__c = null;
                    }else{
                        result_quoteCharge.zqu__Upto_How_Many_Periods__c = discountCharge.duration;
                    }
                    //END UD-0460 MGaelo Add logic for N/A duration and up to how many periods
                }
            }
            //END UD-3660 4March2016 FrancisBenzon : update quoteCharge with discount
        }
        // end override prices
        
        //START UD-3660 4March2016 FrancisBenzon : setup discount charges
        update result_quoteChargeList;
        /************ update result_quoteChargeList; *****/
        
        
        //END UD-3660 4March2016 FrancisBenzon : update quoteCharge with discount
      
       /*  start UD-3660 11Apr16 JohnD - commented out 
       result_productRatePlanList = [SELECT Id, zqu__ZProduct__c, SubscriptionFrequency__c, RatePlanSubType__c  
                FROM zqu__ProductRatePlan__c WHERE zqu__ZProduct__c IN :result_productIdSet 
                AND RatePlanType__c = 'Proration' and zqu__Deleted__c = false];
        
        for (zqu__ProductRatePlan__c prp : result_productRatePlanList) {
            
            if (prp.RatePlanSubType__c == 'Standard') {
                
                frequency_prorationRatePlanId = new map<string, id>();
                
                if (productId_frequency_prorationRatePlanId.get(prp.zqu__zProduct__c) != null) {
                    frequency_prorationRatePlanId = productId_frequency_prorationRatePlanId.get(prp.zqu__zProduct__c);
                }
                
                frequency_prorationRatePlanId.put(prp.SubscriptionFrequency__c, prp.Id);
                productId_frequency_prorationRatePlanId.put(prp.zqu__zProduct__c, frequency_prorationRatePlanId);
            
            } else {
                productId_nonChargeableProrationRatePlanId.put(prp.zqu__zProduct__c, prp.Id);
            }
        }
        
        if (result_productRatePlanList != null) {

            for (zqu__ProductRatePlan__c result_productRatePlan : result_productRatePlanList) {
                
                if (result_product_productRatePlanList_map.get(result_productRatePlan.zqu__ZProduct__c) == null) {
                    result_product_productRatePlanList_map.put(result_productRatePlan.zqu__ZProduct__c, new list<id>());
                }
                
                result_product_productRatePlanList_map.get(result_productRatePlan.zqu__ZProduct__c).add(result_productRatePlan.Id);
            }
        }
        
        for (zqu__Quote__c quote :quoteList) {
            
            id result_productId;
            string quoteFrequency = frequencyName_frequencyCode.get(quote.Frequency__c);
            list<id> result_corresponding_productRatePlanList = new list<id>(); // Start/End UD-2865 22Sep15 JohnD - instantiated
            
            if (result_quote_product_map.containsKey(quote.Id)) {
                result_productId = result_quote_product_map.get(quote.Id);
            }

            if (result_product_productRatePlanList_map.containsKey(result_productId)) {
                result_corresponding_productRatePlanList = result_product_productRatePlanList_map.get(result_productId);
            }
            
            if (result_corresponding_productRatePlanList != null && !result_corresponding_productRatePlanList.isEmpty()) {  // Start/End UD-2865 - added isempty
                
                list<id> ratePlanIdList = new list<id>();
                    
                frequency_prorationRatePlanId = productId_frequency_prorationRatePlanId.get(result_productId);
                if (frequency_prorationRatePlanId.get(quoteFrequency) != null) {
                    ratePlanIdList.add(frequency_prorationRatePlanId.get(quoteFrequency));
                }
                
                if (productId_nonChargeableProrationRatePlanId.get(result_productId) != null) {
                    ratePlanIdList.add(productId_nonChargeableProrationRatePlanId.get(result_productId));
                }
                
                list<zqu.zChargeGroup> cg1 = zqu.zQuoteUtil.getChargeGroups(quote.Id, ratePlanIdList);
                zqu.zQuoteUtil.addChargeGroups(cg1);    
            }
            // Start UD-3660 JohnD 08Apr16 - clean up
            if (quote.zqu__Description__c != null) {
                quote.zqu__Description__c = null;
                quote2CleanList.add(quote);
            }
                
            // End UD-3660 JohnD 08Apr16 - clean up
        }
        */
        // Start UD-3660 JohnD 11Apr16 - cleanup
        for (zqu__Quote__c quote2Clean : consolidatedQuoteList) {
            quote2Clean.zqu__Description__c = null;
            quote2CleanList.add(quote2Clean);
        }
        
        try {
            update quote2CleanList;
        } catch (exception e) {
            exceptionList.add(e);
        }
        // End UD-3660 JohnD 08Apr16 - clean
        if (!exceptionList.isEmpty()) {
            ExceptionLogger.log(exceptionList);
        }
        
        System.debug('## quoteNameSet: ' + quoteNameSet);
        return quoteNameSet;
    }
    
    
    private map<id, list<Order_Line_Item__c>> getOrderLineItem(set<id> orderIdSet) {

       system.debug('===>TEST getOrderLineItem orderIdSet: ' + orderIdSet);
        map<id, list<Order_Line_Item__c>> orderIdOrderLineItemMap = new map<id, list<Order_Line_Item__c>>();
        list<Order_Line_Item__c> orderLineItemList = new list<Order_Line_Item__c>();

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

       system.debug('===>TEST orderLineItemList: ' + orderLineItemList);
        for (Order_Line_Item__c orderLineItem : orderLineItemList) {
            if (orderIdOrderLineItemMap.containsKey(orderLineItem.order__c)) {
                orderIdOrderLineItemMap.get(orderLineItem.order__c).add(orderLineItem);
            } else{
                orderIdOrderLineItemMap.put(orderLineItem.order__c, new list<Order_Line_Item__c>{orderLineItem});
            }
            
            oliIdToOliMap.put(orderLineItem.Id, orderLineItem);
            orderLineItemId_postageChargeAmount.put(orderLineItem.Id, orderLineItem.Postage_Charge__c); // Start/End UD-3660 11Apr16 JohnD
        }
        
        return orderIdOrderLineItemMap;
    }
    
    private list<Order__c> getOrder(set<id> orderIdSet) {

        list<Order__c> orderList = new list<Order__c>();

        orderList = [SELECT Id, Name, Account__c, Account__r.Id, Billing_Account__c, Recipient_Contact__c, 
                         Billing_Account_External_ID__c, Payment_Mode__c, Other_Payment_Mode__c, Payment_Method_ID__c,
                         Billing_Contact__c, Billing_Contact__r.Id, Recipient_Contact__r.Address_Unique_Id__c,
                         Billing_Account_Creation_Mode__c, FP_Del_Usage__c , Recipient_Type__c, Recipient_Address__c,
                         Recipient_Add_Type__c, Acquisition_Type__c, Cost_Centre__c,Delivery_Charge_Type__c, Subscriber_Charge__c,
                         Vendor_Credit__c, PO_Number__c, Delivery_Start_Date__c, Sponsor__c, Remarks__c,
                         Base_Subscription__c, Recipient_Contact__r.Address__c, Recipient_Contact__r.Address__r.Address_Unique_ID__c, Debt_Management_Treatment__c
                     FROM Order__c 
                     WHERE id IN : orderIdSet];

        return orderList;
    }
    
    private map<id, list<Order_Line_Item_Gift__c>> getOrderLineItemGifts(set<id> orderLineItemIdSet) {
        
        list<Order_Line_Item_Gift__c> orderLineItemGiftList = new list<Order_Line_Item_Gift__c>();
        map<id, list<Order_Line_Item_Gift__c>> orderLineToGiftMap = new map<id, list<Order_Line_Item_Gift__c>>();
        
        orderLineItemGiftList = [SELECT Id, Type__c, Name, Price__c,Order_Line_Item__r.Id  
                                 FROM Order_Line_Item_Gift__c 
                                 WHERE Order_Line_Item__c IN : orderLineItemIdSet AND Type__c = 'Premium'
                                 ORDER BY Order_Line_Item__r.Id ASC];
                                 
        for (Order_Line_Item_Gift__c orderLineItemGift : orderLineItemGiftList) {
            if (orderLineToGiftMap.containsKey(orderLineItemGift.Order_Line_Item__c)) {
                orderLineToGiftMap.get(orderLineItemGift.Order_Line_Item__c).add(orderLineItemGift);
            } else{
                orderLineToGiftMap.put(orderLineItemGift.Order_Line_Item__c, new list<Order_Line_Item_Gift__c>{orderLineItemGift});
            }           
        }
        
        return orderLineToGiftMap;
    }

    
    private map<id, list<Package_Item__c>> getPackage(set<id> packageIdSet, map<id, list<Order_Line_Item__c>> orderIdOrderLineItemMap) {
        
        Package_Item__c packageItemRec = new Package_Item__c();
        list<Package_Item__c> packageItemList = new list<Package_Item__c>();
        map<id, list<Package_Item__c>> packageItemMap = new map<id, list<Package_Item__c>>();
        //START UD-3660 4March2016 FrancisBenzon : added fields
        packageItemList = [SELECT Name, Id, Bundle_Item_No__c, Package__r.Id, RecordType.name, Base_Package_Item__c, Product_Rate_Plan__c, Package__c,
                            RecordTypeID, RecordType.DeveloperName, Is_Newspaper__c, Is_Print__c, Product_Rate_Plan__r.zqu__ZProduct__c, 
                            Product_Rate_Plan__r.zqu__ZProduct__r.ProductFamily__c, Product_Rate_Plan__r.Product_Code__c,
                            Effective_Start_Month__c, Duration_in_months__c, Product_Rate_Plan__r.zqu__ZuoraId__c, 
                            Product_Rate_Plan__r.SubscriptionFrequency__c 
                           FROM Package_Item__c
                           WHERE Package__c IN: packageIdSet
                           ORDER BY Bundle_Item_No__c ASC, Base_Package_Item__c ASC];
        system.debug(':::PACKAGEItems ' + packageItemList);
        //END UD-3660 4March2016 FrancisBenzon : added fields
        for (Package_Item__c packageItem : packageItemList) {
            if (packageItemMap.containsKey(packageItem.Package__c)) {
                packageItemMap.get(packageItem.Package__c).add(packageItem);
            } else {
                packageItemMap.put(packageItem.Package__c, new list<Package_Item__c>{packageItem});
            }           
            //START UD-3660 4March2016 FrancisBenzon : get discount packageItems
            if(RT_ID_DISC == packageItem.RecordTypeId || RT_ID_BUNDLE_DISC == packageItem.RecordTypeId || RT_ID_EXT_DISC == packageItem.RecordTypeId)
                setDiscRatePlanIDs.add(packageItem.Product_Rate_Plan__c);   
            
            if (packageItem.Base_Package_Item__c != null) 
            {
                
                if (basePackageItemId_discountPackageItemList.containsKey(packageItem.Base_Package_Item__c)) {
                    basePackageItemId_discountPackageItemList.get(packageItem.Base_Package_Item__c).add(packageItem);
                } else {
                    basePackageItemId_discountPackageItemList.put(packageItem.Base_Package_Item__c, new list<Package_Item__c>{packageItem});
                }
            }
            //END UD-3660 4March2016 FrancisBenzon : get discount packageItems
            
            // Start UD-3660 11Apr16 JohnD
            packageItemId_productRatePlanId.put(packageItem.Id, packageItem.Product_Rate_Plan__c);
            packageItemId_productId.put(packageItem.Id, packageItem.Product_Rate_Plan__r.zqu__ZProduct__c);
            // End UD-3660 11Apr16 JohnD
        } 

        return packageItemMap;
    }
    

    // product rate plan ; key : package item ; value : product rate plan
    private map<id, zqu__ProductRatePlan__c> getProductRatePlan(map<id, list<Package_Item__c>> packageItemMap) {
        
        zqu__ProductRatePlan__c prodRatePlanRec = new zqu__ProductRatePlan__c();
        set<id> prodRatePlanSet = new set<id>();
        list<zqu__ProductRatePlan__c> prodRatePlanList = new list<zqu__ProductRatePlan__c>();
        map<id, zqu__ProductRatePlan__c> ratePlanMap = new map<id, zqu__ProductRatePlan__c>();
        map<id, zqu__ProductRatePlan__c> prodRatePlanIdRatePlanMap = new map<id, zqu__ProductRatePlan__c>();
        
        for (Id packageId : packageItemMap.keySet()) {
            for (Package_Item__c packItem : packageItemMap.get(packageId)) {
                prodRatePlanSet.add(packItem.Product_Rate_Plan__c);
            }
        }
        
        prodRatePlanList = [SELECT Id,Name,zqu__ZProduct__c,zqu__ZProduct__r.ProductCode__c,
                 zqu__ZProduct__r.ProductType__c,zqu__ZProduct__r.ProductSubType__c, RatePlanCode__c, zqu__Deleted__c 
                 FROM zqu__ProductRatePlan__c WHERE (Id IN : prodRatePlanSet OR RatePlanCode__c = 'CHGPOS') AND zqu__Deleted__c = false];   // Start/End UD-2865 22Sep15 JohnD - changed grouping
        
        for (zqu__ProductRatePlan__c prodratePlan : prodRatePlanList) {
            ratePlanMap.put(prodRatePlan.id, prodRatePlan);
            consolidatedProductIdSet.add(prodratePlan.zqu__ZProduct__c);    // Start/End UD-3660 11Apr16 JohnD
            if (prodratePlan.RatePlanCode__c == 'CHGPOS' && prodratePlan.zqu__Deleted__c == false) {
                postagePrpIdToPrpMap.put(prodratePlan.Id, prodratePlan);
            }
        }
        
        for (Id packageId : packageItemMap.keySet()) {
            for (Package_Item__c packItem : packageItemMap.get(packageId)) {
                if (ratePlanMap.containsKey(packItem.Product_Rate_Plan__c)) {
                    prodRatePlanIdRatePlanMap.put(packItem.Product_Rate_Plan__c, ratePlanMap.get(packItem.Product_Rate_Plan__c));
                }
            }
        }
        
        return prodRatePlanIdRatePlanMap;
    }
    
    
    // product rate plan charge ; key : product rate plan ; value : product rate plan charge
    private map<id, list<zqu__ProductRatePlanCharge__c>> getProdRatePlanCharge(map<id, zqu__ProductRatePlan__c> prodRatePlanIdRatePlanMap) {
        
        set<id> prodRatePlanIdSet = new set<id>();
        list<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList = new list<zqu__ProductRatePlanCharge__c>();     
        map<id, list<zqu__ProductRatePlanCharge__c>> prodRatePlanChargemap = new map<id, list<zqu__ProductRatePlanCharge__c>>();
                
        for (zqu__ProductRatePlan__c prodRatePlan : prodRatePlanIdRatePlanMap.values()) {
            prodRatePlanIdSet.add(prodRatePlan.id);
        }
        
        prodRatePlanChargeList = [SELECT id, name, sum__c, zqu__UOM__c, zqu__RecurringPeriod__c, zqu__Model__c, zqu__Type__c, 
                zqu__Upto_How_Many_Periods__c, zqu__ZuoraId__c, zqu__ProductRatePlan__c, zqu__Discount_Level__c 
                FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c IN :prodRatePlanIdSet and zqu__Deleted__c = false];    // Start/End UD-2865 22Sep15 JohnD - added deleted in where clause
        
        for (zqu__ProductRatePlanCharge__c prodRatePlanCharge : prodRatePlanChargeList) {
            if (prodRatePlanChargemap.containsKey(prodRatePlanCharge.zqu__ProductRatePlan__c)) {
                prodRatePlanChargemap.get(prodRatePlanCharge.zqu__ProductRatePlan__c).add(prodRatePlanCharge);
            } else {
                prodRatePlanChargemap.put(prodRatePlanCharge.zqu__ProductRatePlan__c, new list<zqu__ProductRatePlanCharge__c>{prodRatePlanCharge});
            }           
        }

        return prodRatePlanChargemap;
    }

    
    private map<id, zqu__ProductRatePlan__c> getDeliveryCharge(list<Order__c> ordList) {
        
        zqu__ProductRatePlan__c deliveryRatePlan_Internal;
        zqu__ProductRatePlan__c deliveryRatePlan_HDB;
        zqu__ProductRatePlan__c deliveryRatePlan_Apartment;
        zqu__ProductRatePlan__c deliveryRatePlan_Landed;
        String defaultDeliveryChargeType; //For determine the Delivery Rate Plan
        
        list<zqu__ProductRatePlan__c> lstDeliveryRatePlans =[Select zqu__ZProduct__r.ProductType__c, zqu__ZProduct__r.ProductSubType__c, zqu__ZProduct__c, Id, Name 
                From zqu__ProductRatePlan__c Where zqu__ZProduct__r.ProductCode__c =: GlobalVariableClass.PRODUCT_CODE_DELCHG and zqu__Deleted__c = false];

        if (!lstDeliveryRatePlans.isEmpty()) {
            
            for (zqu__ProductRatePlan__c drp: lstDeliveryRatePlans) {
                
                if (drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount'))) {
                    deliveryRatePlan_Internal = drp;
                } else if (drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('HDB DELIVERY CHARGE'))) {
                    deliveryRatePlan_HDB = drp;
                } else if (drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('APT DELIVERY CHARGE'))) { 
                    deliveryRatePlan_Apartment = drp;
                } else if (drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('LANDED DELIVERY CHARGE'))) {
                    deliveryRatePlan_Landed = drp;
                }
            }
        }

        //SET Delivery Rate Plan to Use
        for (Order__c ord : ordList) {
            
            defaultDeliveryChargeType = ConstantsSLB.getDefaultDeliveryChargeType(ord.Recipient_Add_Type__c);

             system.debug('\n\n ***DEBUG ord.Recipient_Type__c ' + ord.Recipient_Type__c + '\n\n **** ' + ADDRESS_TYPE_INTERNAL + '\n\n'  );
            if (ord.Recipient_Type__c == ADDRESS_TYPE_INTERNAL) {
                ratePlanDelivery = deliveryRatePlan_Internal;
            } else if (ord.Recipient_Type__c == ADDRESS_TYPE_LOCAL || ord.Recipient_Type__c == ADDRESS_TYPE_AIRLINE) {
                
                if (defaultDeliveryChargeType == 'H') {
                    ratePlanDelivery = deliveryRatePlan_HDB;
                } else if (defaultDeliveryChargeType== 'C') {
                    ratePlanDelivery = deliveryRatePlan_Apartment;
                } else if (defaultDeliveryChargeType == 'L') {
                    ratePlanDelivery = deliveryRatePlan_Landed;
                }    
            }
            

            orderIdToProductRatePlanMap.put(ord.id, ratePlanDelivery);
            system.debug('\n\n ***DEBUG ratePlanDelivery ' + ratePlanDelivery + '\n\n' );
             system.debug('\n\n ***DEBUG orderId_hasVendorDelivery.get(ord.Id) ' + orderId_hasVendorDelivery.get(ord.Id) + '\n\n' );
            // Start UD-3541 18Jan16 JohnD
            if (orderId_hasVendorDelivery.get(ord.Id) && ratePlanDelivery == null) {
                throw new CustomException(System.Label.ERR_NO_DELIVERY_RATE_PLAN);
            }
            // End UD-3541 18Jan16 JohnD
        }
        
        // Start UD-3541 18Jan16 JohnD - commented out
        //if (ratePlanDelivery == NULL && hasVendorDelivery) { // Restrict Delivery Rate Plan validation for Vendor Delivery only
        //    throw new CustomException(System.Label.ERR_NO_DELIVERY_RATE_PLAN);
        //}
        // End UD-3541 18Jan16 JohnD - commented out
        return orderIdToProductRatePlanMap;
    }

    
    //product rate plan charge tier ; key : product rate plan charge id ; value : product rate plan charge tier 
    private map<id, zqu__ProductRatePlanChargeTier__c> getProdRatePlanChargeTier(map<id, list<zqu__ProductRatePlanCharge__c>> prodRatePlanChargemap) {
        
        set<id> prodRatePlanChargeIdSet = new set<id>();
        list<zqu__ProductRatePlanChargeTier__c> ratePlanChargeTierList = new list<zqu__ProductRatePlanChargeTier__c>();
        map<id, zqu__ProductRatePlanChargeTier__c> ratePlanChargeTierMap = new map<id, zqu__ProductRatePlanChargeTier__c>();
        
        for (Id ratePlanId : prodRatePlanChargemap.keySet()) {
            for (zqu__ProductRatePlanCharge__c ratePlanCharge : prodRatePlanChargemap.get(ratePlanId)) {
                prodRatePlanChargeIdSet.add(ratePlanCharge.id);
            }
        }
        
        ratePlanChargeTierList = [SELECT id, name,  zqu__ProductRatePlanCharge__c, zqu__PriceFormat__c, zqu__Currency__c
                                  FROM zqu__ProductRatePlanChargeTier__c 
                                  WHERE zqu__ProductRatePlanCharge__c IN : prodRatePlanChargeIdSet];
                                  
        for (zqu__ProductRatePlanChargeTier__c ratePlanChargeTier : ratePlanChargeTierList) {
            ratePlanChargeTierMap.put(ratePlanChargeTier.zqu__ProductRatePlanCharge__c, ratePlanChargeTier);
        }
        
        return ratePlanChargeTierMap;
    }
    

    private map<string, set<id>> createQuote(map<id, list<Order_Line_Item__c>> orderIdToOliListMap, map<id, list<Package_Item__c>> packageIdToPackageItemListMap, map<id, list<Order_Line_Item_Gift__c>> oliIdToOliGiftListMap, map<id, Order__c> orderIdToOrderMap, map<id, String> orderIdToSubZuoraIdMap) {

        map<string, list<zqu__Quote__c>> oliNameToQuoteListMap = new map<string, list<zqu__Quote__c>>();
        map<id, zqu__Quote__c> packageItemIdToQuoteMap = new map<id, zqu__Quote__c>();
        list<zqu__Quote__c> zQuoteList = new list<zqu__Quote__c>();
        list<zqu__QuoteCharge__c> zQuoteChargeList = new list<zqu__QuoteCharge__c>();
        list<Package_Item__c> packageItemList;
        list<Package_Item__c> packageItemAddOnList = new list<Package_Item__c>(); //START-END D-4080 12-14-2015 added by Jason A. for code review
        zqu__Quote__c zQuote;
        Boolean isFullPrepaid;
        String packageType;
        Integer iTerm;
        
        system.debug('===>TEST orderIdToOliListMap.keySet(): ' + orderIdToOliListMap.keySet());
        for (Id orderId :orderIdToOliListMap.keySet()) {
            
        system.debug('===>TEST orderIdToOliListMap.get(orderId): ' + orderIdToOliListMap.get(orderId));
            for (Order_Line_Item__c oli :orderIdToOliListMap.get(orderId)) {
                zQuote = new zqu__Quote__c();
                Order__c order = orderIdToOrderMap.get(orderId);
                
                if (oli.Main_Package_ID__c != null) {

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
                    
                    packageItemList = new list<Package_Item__c>();
                    
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
                            zQuote = zBuildQoutesPackage(oli, orderIdToOrderMap, iTerm, true, subType, true, false, false, isFullPrepaid, null, orderIdToSubZuoraIdMap, pkgItem.Id);    // Start/End UD-2865 23Sep15 JohnD- added parameter
                            
                            //Create Map for Order Id to its related Quotes
                            if (oliNameToQuoteListMap.containsKey(oli.Name)) {
                                oliNameToQuoteListMap.get(oli.Name).add(zQuote);
                            }
                            else {
                                oliNameToQuoteListMap.put(oli.Name, new list<zqu__Quote__c>{zQuote});
                            }
                            //START UD-3660 4March2016 FrancisBenzon: pItem_QuoteNameMap
                            mapPackItemToQuoteName.put(pkgItem.Id, zQuote.Name);
                            //END UD-3660 4March2016 FrancisBenzon: pItem_QuoteNameMap
                            packageItemIdToQuoteMap.put(pkgItem.Id, zQuote);
                            zQuoteList.add(zQuote);
                        }
                    }
                    
                    if (oli.Addon_Package__c != null) {
                        
                        packageItemAddOnList = packageIdToPackageItemListMap.get(oli.Addon_Package__c);

                        if (packageItemAddOnList != null) {

                            for (Package_Item__c pkgItem: packageItemAddOnList) {
                                
                                if (pkgItem.RecordType.name.contains('Product')) {

                                    string subType = ConstantsSLB.getkeyid('SubTypePub');
                                    zQuote = zBuildQoutesPackage(oli, orderIdToOrderMap, 1, true, subType, false, true, false, isFullPrepaid, null, orderIdToSubZuoraIdMap, pkgItem.Id);    // Start/End UD-2865 23Sep15 JohnD- added parameter

                                    //Create Map for Order Id to its related Quotes
                                    if (oliNameToQuoteListMap.containsKey(oli.Name)) {
                                        oliNameToQuoteListMap.get(oli.Name).add(zQuote);
                                    }
                                    else {
                                        oliNameToQuoteListMap.put(oli.Name, new list<zqu__Quote__c>{zQuote});
                                    }
                                    
                                    //START UD-3660 4March2016 FrancisBenzon: pItem_QuoteNameMap
                                    mapPackItemToQuoteName.put(pkgItem.Id, zQuote.Name);
                                    //END UD-3660 4March2016 FrancisBenzon: pItem_QuoteNameMap
                                    packageItemIdToQuoteMap.put(pkgItem.Id, zQuote);
                                    
                                    zQuoteList.add(zQuote);
                                }
                            }                   
                        }
                    }
                    
                    if (!oliIdToOliGiftListMap.isEmpty()) {
                        boolean bGiftQuoteCreated = false;
                        if (oliIdToOliGiftListMap.containskey(oli.Id) && oliIdToOliGiftListMap.get(oli.Id) != null) {
                            
                            for (Order_Line_Item_Gift__c g: oliIdToOliGiftListMap.get(oli.Id)) {
                                
                                if (g.type__c == 'Premium') {
                                    
                                    if (!bGiftQuoteCreated) {
                                        
                                        bGiftQuoteCreated=true;
                                        string subType = ConstantsSLB.getkeyid('SubTypeGift');
                                        zQuote = zBuildQoutesPackage(oli, orderIdToOrderMap, 1, true, subType, false, false, true, isFullPrepaid, null, orderIdToSubZuoraIdMap, null);
                                        
                                        //Create Map for Order Id to its related Quotes
                                        if (oliNameToQuoteListMap.containsKey(oli.Name)) {
                                            oliNameToQuoteListMap.get(oli.Name).add(zQuote);
                                        }
                                        else {
                                            oliNameToQuoteListMap.put(oli.Name, new list<zqu__Quote__c>{zQuote});
                                        }
                                        
                                        zQuoteList.add(zQuote);                                    
                                    }
                                }
                            }
                        }
                    }
                }
                
                if (oli.Delivered_By__c == 'Mailing Agent' && oli.Main_Package_Product_Platform__c != 'Online') { //START/END UD-3357 12/15/15 RReyes - Postage should not be created for online packages
                    zQuoteList.add(zBuildPostageQuote(order, oli, ConstantsSLB.getkeyid('SubTypePostage')));
                }
            }
        }
        
        if (!zQuoteList.isEmpty()) {
            
            // Start UD-3660 11Apr16 JohnD - revised approach on retry mechanism
            /* commented out
            boolean isRecordLock = true;
            while (isRecordLock) {
                try {
                    insert zQuoteList;
                    isRecordLock = false;
                    
                    consolidatedQuoteList.addAll(zQuoteList);
                } catch (dmlexception e) {
                    isRecordLock = e.getMessage().contains('UNABLE_TO_LOCK_ROW');
                }               
            }
            */
            zQuoteList = insertQuotes(zQuoteList);
            consolidatedQuoteList.addAll(zQuoteList);
            // End UD-3660 11Apr16 JohnD - revised approach on retry mechanism
        }
        
        // Start UD-3660 11Apr16 JohnD - commented out to avoid redundant iteration
        /*
        for (zqu__Quote__c quote :zQuoteList) {
            if (quote.Subscription_Type__c == 'Postage') {
                postageQuoteToOliMap.put(quote.Id, quote.Order_Line_Item_Number__c);
            }
        }
        */
        // End UD-3660 11Apr16 JohnD - commented out to avoid redundant iteration
        
        map<string, set<id>> quoteIdToQuoteMap = new map<string, set<id>>();
        
        result_createdQuoteIdSet = new set<id>();
        
        system.debug('===>TEST zQuoteList: ' + zQuoteList);
        for (zqu__Quote__c zQuotes : zQuoteList) {
            // Start UD-3660 JohnD 08Apr16 - package item mapping
            if (zQuotes.zqu__Description__c != null && !zQuotes.zqu__Description__c.startsWith('Free') 
                    && zQuotes.zqu__Description__c instanceof id) {
                
                quoteId_packageItemId.put(zQuotes.Id, zQuotes.zqu__Description__c);
                
            }
            // End UD-3660 JohnD 08Apr16 - package item mapping
            if (zQuotes.Subscription_Type__c != 'Postage') {
                
        system.debug('===>TEST quoteIdToQuoteMap.containsKey(zQuotes.name): ' + quoteIdToQuoteMap.containsKey(zQuotes.name));
                if (quoteIdToQuoteMap.containsKey(zQuotes.name)) {
                    quoteIdToQuoteMap.get(zQuotes.name).add(zQuotes.id);
                }
                else {
                    quoteIdToQuoteMap.put(zQuotes.name, new set<id>{zQuotes.id});
                }
            }
            
            if (zQuotes.Subscription_Type__c == 'Postage') {
                quoteIdToQuote.put(zQuotes.Id, zQuotes);
                postageQuoteToOliMap.put(zQuotes.Id, zQuotes.Order_Line_Item_Number__c);    // Start/End UD-3660 11Apr16 JohnD
            }
            
            result_createdQuoteIdSet.add(zQuotes.id);           
        }
        system.debug('===>TEST END quoteIdToQuoteMap: ' + quoteIdToQuoteMap);
        return quoteIdToQuoteMap;
    }

    
    private zqu__Quote__c zBuildQoutesPackage (Order_Line_Item__c oli, map<id, Order__c> orderIdToOrderMap, Integer iTerm, 
                                            boolean bBundledWith, string subType, boolean bMain, boolean bAddOn, boolean bGift, 
                                            boolean isFullPrepaid, String origin, map<id, String> orderIdToSubZuoraIdMap, id packageItemIdParam) {      // Start/End UD-2865 23Sep15 JohnD- added parameter
        
        zqu__Quote__c q1 = new zqu__Quote__c ();
        
        q1.Name = oli.Name;
        q1.zqu__SubscriptionType__c = NEW_SUBSCRIPTION;                 
        q1.zqu__ValidUntil__c = date.today().addMonths(1);
        //START PD-0041 FrancisBenzon 20May16 : start date for recurring 1st of month
        if(oli.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE && oli.Start_Date__c.day() == 1)
            q1.zqu__StartDate__c                    = oli.Start_Date__c.addDays(-1);
        else
            q1.zqu__StartDate__c                    = oli.Start_Date__c;
        
        //q1.zqu__StartDate__c = oli.Start_Date__c; 
        q1.zqu__TermStartDate__c                    = oli.Start_Date__c;
        //END PD-0041 FrancisBenzon 20May16 : start date for recurring 1st of month
        q1.zqu__Service_Activation_Date__c = oli.Start_Date__c;
        
        q1.zqu__Subscription_Term_Type__c = oli.Main_Package_ID__r.Subscription_Type__c;
        
        q1.Qty1__c= oli.Qty__c ;
        q1.Term_Length1__c = oli.Term_Length__c;
        q1.Generate_Invoice1__c = true;        
        q1.zqu__Currency__c = CURRENCY_SGD;
        q1.zqu__InvoiceProcessingOption__c = INVOICE_PROC_OPTION;
        q1.zqu__PaymentTerm__c = PAYMENT_TERM;
        q1.zqu__Description__c = packageItemIdParam;    // Start/End UD-3660 JohnD 08Apr16 - temporary store the package item
        //Check if New Billing Account or Existing Billing Account
        
        if (oli.Main_Package_ID__r.Subscription_Type__c == TERM_TYPE_TERMED) {

            if (bGift) {
                q1.zqu__InitialTerm__c = 1;
                q1.zqu__RenewalTerm__c = 0;
            } else {
            
                if (oli.Term_Length__c != null) {
                    q1.zqu__InitialTerm__c = Integer.valueof(oli.Term_Length__c);
                } else {
                    q1.zqu__InitialTerm__c = 0;
                }
                q1.zqu__RenewalTerm__c = 0;
            }
        }
        
        //Additional Fields to populate
        if (bBundledWith) {
            q1.Bundled_With__c                      = oli.id;
        }
        
        q1.Subscription_Type__c                     = subType;        
        q1.zqu__AutoRenew__c                        = oli.Auto_Renew__c;
        q1.Charity__c                               = oli.Charity__c;
        q1.Delivered_By__c                          = oli.Delivered_By__c;
        
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
            q1.Frequency__c                             = ConstantsSLB.getProductFrequency(packageItemId_subscriptionFrequency.get(packageItemIdParam));    // Start/End UD-2865 24Sep15 JohnD                  
            q1.Sponsor__c                               = orderIdToOrderMap.get(oli.Order__r.Id).Sponsor__c;
            q1.PO_Number__c                             = orderIdToOrderMap.get(oli.Order__r.Id).PO_Number__c;
            if (orderIdToOrderMap.get(oli.Order__r.Id).Recipient_Contact__c != null) {
                q1.Recipient_Contact__c                 = string.valueOf(orderIdToOrderMap.get(oli.Order__r.Id).Recipient_Contact__c);
            }

            q1.Related_Subscription__c = oli.Old_Subscription__c;
        }
        
        
        if (oli.Contract_End_Date__c != null) {
            q1.Contract_End_Date__c                 = oli.Contract_End_Date__c;
        }
        
        q1.Promotion_Contract_Period__c             = oli.Promotion_Contract_Period__c;
        q1.New_Contract_Period__c                   = oli.New_Contract_Period__c;
       
        
        if (bMain) {
            q1.Main_Package__c                      = oli.Main_Package_ID__c;
            q1.Package_Product_Sub_Type__c          = oli.Main_Package_Product_Sub_Type__c;
            
            if (oli.Vendor_Conversion__c) {
                q1.Vendor_Conversion__c             = oli.Vendor_Conversion__c;
                q1.Vendor_Subscription_To_Convert__c= oli.Vendor_Subscription_ID__c; 
            }
             
        }else if (bAddOn) {   
            q1.Main_Package__c                      = oli.Addon_Package__c;
            q1.Package_Product_Sub_Type__c          = oli.Add_On_Package_Product_Sub_Type__c;
        }else if (bGift) {
            q1.Main_Package__c                      = null;
            q1.Package_Product_Sub_Type__c          = null;
        }
     
         
        q1.Order_Line_Item_Number__c                = oli.Id;
        q1.Order_Number__c                          = oli.Order__c;
        q1.Order_Line_Item_Number_1__c              = oli.Id;
        
        
        q1.Urgent__c                                = oli.Urgent__c;
        q1.zqu__GenerateInvoice__c                  = true;
        q1.Suppress_Vendor_Start_Notice__c          = oli.Suppress_Vendor_Start_notice__c;
        q1.Supressed_Acknowledgement_Letter__c      = oli.Supressed_Acknowledgement_Letter__c;
        q1.Supressed_Renewal_and_Reminder_Letter__c = oli.Suppress_Renewal_and_Reminder_Letter__c;  
        
        q1.Vendor__c                                = oli.Vendor_Mailing_Agent__c;
        //q1.Billing_Type__c                        = oli.Main_Package_Billing_Type__c;
        if (isFullPrepaid) {
            q1.zqu__ProcessPayment__c               = true;
        }

        return q1;          
    }
    
    
    private void addQuoteChargeToQuote(list<Order_Line_Item__c> oliList, map<id, list<Package_Item__c>> packIdToPackageItemListMap, map<string, set<id>> oliNameToQuoteId, map<id, list<zqu__ProductRatePlanCharge__c>> prpIdToprpcListMap, map<id, zqu__ProductRatePlanChargeTier__c> prcIdToPrpctMap, map<id, zqu__ProductRatePlan__c> prpIdToPrpMap) {
        
        map<id, list<zqu.zChargeGroup>> mapQuoteIdToChargeGroups = new map<id, list<zqu.zChargeGroup>>(); // Quote Charges should be added using Charge Group
        zqu__QuoteCharge__c quoteCharge;
        list<zqu__QuoteCharge__c> quoteChargeList = new list<zqu__QuoteCharge__c>();
        Integer count = 0;
        
        map<id, list<zqu__QuoteCharge__c>>  quoteToquoteChargeMap = new map<id, list<zqu__QuoteCharge__c>>();
        
        system.debug('===>TEST oliList: ' + oliList);
        // Start UD-3660 JohnD 08Apr16 - update logic
        for (Order_Line_Item__c oli :oliList) 
        {
        system.debug('===>TEST oliNameToQuoteId.get(oli.Name): ' + oliNameToQuoteId.get(oli.Name));
            //START UD-3660 4March2016 FrancisBenzon : update quoteCharge with discount
            for (Id quoteId :oliNameToQuoteId.get(oli.Name)) {
                
                list<id> productRatePlanIdList = new list<id>();
                id pkgItemId = quoteId_packageItemId.get(quoteId);
                
                        //START D-4610 2Apr16 FrancisBenzon : null pointer checking
                // start add discount
                if(basePackageItemId_discountPackageItemList.containsKey(pkgItemId))
                {
                     for (Package_Item__c discPkg : basePackageItemId_discountPackageItemList.get(pkgItemId)) {
                        productRatePlanIdList.add(discPkg.Product_Rate_Plan__c);
                    }
                }
               
                // end add discount
                        //END D-4610 2Apr16 FrancisBenzon : null pointer checking
                // Start UD-3660 11Apr16 JohnD - revised approach
                productRatePlanIdList.add(packageItemId_productRatePlanId.get(pkgItemId));
                
                if (quoteId_ratePlanIdList.get(quoteId) == null) {
                    quoteId_ratePlanIdList.put(quoteId, new list<id>());
                }
                
                quoteId_ratePlanIdList.get(quoteId).addAll(productRatePlanIdList);
                
                /* commented out
                list<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId, productRatePlanIdList);
                mapQuoteIdToChargeGroups.put(quoteId, chargeGroups); 
                */
                // End UD-3660 11Apr16 JohnD - revised approach
            }
        }
        // End UD-3660 JohnD 08Apr16 - update logic
        zqu__ProductRatePlan__c ratePlanPostage = [SELECT Id,Name,zqu__ZProduct__c,zqu__ZProduct__r.ProductCode__c,
                           zqu__ZProduct__r.ProductType__c,zqu__ZProduct__r.ProductSubType__c 
                           FROM zqu__ProductRatePlan__c 
                           WHERE RatePlanCode__c = 'CHGPOS' AND zqu__Deleted__c = false and zqu__ZProduct__r.ProductCode__c = 'POSCHG' limit 1]; 
        
        for (Id postageId :postageQuoteToOliMap.keySet()) {
            
            if (quoteIdToQuote.containsKey(postageId)) {
            
                zqu__Quote__c quote = quoteIdToQuote.get(postageId);
                
                if (oliIdToOliMap.containsKey(quote.Order_Line_Item_Number__c)) {
                
                    Order_Line_Item__c oli = oliIdToOliMap.get(quote.Order_Line_Item_Number__c);
                    // Postage Charge is required for each publication
                    if (quote.Subscription_Type__c == 'Postage' && oli.Delivered_By__c == 'Mailing Agent') {

                        // Start UD-3660 11Apr16 JohnD - revised approach
                        if (quoteId_ratePlanIdList.get(quote.Id) == null) {
                            quoteId_ratePlanIdList.put(quote.Id, new list<id>());
                        }
                        quoteId_ratePlanIdList.get(quote.Id).add(ratePlanPostage.Id);
                        /* commented out
                        zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(quote.Id, ratePlanPostage.Id);     
                        if (mapQuoteIdToChargeGroups.get(quote.Id) == null)
                        {
                            mapQuoteIdToChargeGroups.put(quote.Id, new list<zqu.zChargeGroup>());
                        }
                        mapQuoteIdToChargeGroups.get(quote.Id).add(chargeGroup);
                        */
                        // End UD-3660 11Apr16 JohnD - revised approach                     
                    }
                }
            }
        }
        
        // Start UD-3660 11Apr16 JohnD - revised approach
        /*
        try {
            
            for (Id quoteID : mapQuoteIdToChargeGroups.keySet()) {
                
                list<zqu.zChargeGroup> lstChargeGroups = mapQuoteIdToChargeGroups.get(quoteID);

                if (lstChargeGroups != NULL && !lstChargeGroups.isEmpty()) {
                    //Add up to 30 Charge Groups to a Quote
                    if (lstChargeGroups.size() > 30)
                        throw new CustomException(System.Label.ERR_MAX_30_CHARGE_GROUP);
                    else
                        zqu.zQuoteUtil.addChargeGroups(lstChargeGroups);
                }
            }
        }
        catch(Exception e) {
            exceptionList.add(e);
        }
        */
        // End UD-3660 11Apr16 JohnD - revised approach         
        //END UD-3660 4March2016 FrancisBenzon : update quoteCharge with discount
    }
    
    
    //START 01/19/15 J. Sarion - Updated to include creation of Postage Subscription
    private zqu__Quote__c zBuildPostageQuote (Order__c orderObj, Order_Line_Item__c itemObj, String sSubType) {
        
        zqu__Quote__c quote = new zqu__Quote__c ();    
        quote.Name                                     = itemObj.Name;
        quote.zqu__SubscriptionType__c                 = NEW_SUBSCRIPTION;                    
        quote.zqu__ValidUntil__c                       = Date.Today().addMonths(1);
        quote.Qty1__c                                  = itemObj.Qty__c ;
        quote.Term_Length1__c                          = itemObj.Term_Length__c;
        quote.zqu__Subscription_Term_Type__c           = itemObj.Main_Package_ID__r.Subscription_Type__c; //START/END PD-0041 FrancisBenzon 18May16 : sub term type depending on termtype
        quote.zqu__Currency__c                         = CURRENCY_SGD;
        quote.zqu__InvoiceProcessingOption__c          = INVOICE_PROC_OPTION;
        quote.zqu__PaymentTerm__c                      = PAYMENT_TERM;
        
        //START PD-0041 FrancisBenzon 20May16 : start date for recurring 1st of month
        if(itemObj.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE && itemObj.Start_Date__c.day() == 1)
            quote.zqu__StartDate__c                    = itemObj.Start_Date__c.addDays(-1);
        else
            quote.zqu__StartDate__c                    = itemObj.Start_Date__c;
        //quote.zqu__StartDate__c                        = itemObj.Start_Date__c;
        quote.zqu__TermStartDate__c                    = itemObj.Start_Date__c;
        //END PD-0041 FrancisBenzon 20May16 : start date for recurring 1st of month
        
        quote.zqu__Service_Activation_Date__c          = itemObj.Start_Date__c;
        quote.Acquisition_Type__c                      = orderObj.Acquisition_Type__c;      
        quote.zqu__Account__c                          = orderObj.Account__c;        
        quote.Payment_Mode__c                          = orderObj.Payment_Mode__c; 
        quote.zqu__PaymentMethod__c                    = orderObj.Payment_Mode__c; 
        quote.Other_PaymentMethod__c                   = orderObj.Other_Payment_Mode__c;
        quote.zqu__SoldToContact__c                    = orderObj.Recipient_Contact__c;
        
        if (orderObj.Billing_Account_External_ID__c != null) {
            quote.zqu__ZuoraAccountID__c               = orderObj.Billing_Account_External_ID__c;   
        } else {
            quote.zqu__BillToContact__c                = orderObj.Billing_Contact__r.Id;   
        }
        
        quote.zqu__AutoRenew__c                        = itemObj.Auto_Renew__c;
        quote.Charity__c                               = itemObj.Charity__c;
        quote.Delivered_By__c                          = itemObj.Delivered_By__c;
        quote.Vendor__c                                = itemObj.Vendor_Mailing_Agent__c;
        quote.Main_Package__c                          = itemObj.Main_Package_ID__c;
        quote.zqu__ElectronicPaymentMethodId__c        = orderObj.Payment_Method_ID__c;
        quote.Recipient_Contact__c                     = orderObj.Recipient_Contact__c;            
        quote.Subscription_Type__c                     = sSubType;
        quote.Order_Number__c                          = orderObj.ID;
        quote.Order_Line_Item_Number__c                = itemObj.Id;
        quote.Order_Line_Item_Number_1__c              = itemObj.Id;
        quote.zqu__ProcessPayment__c                   = false;
        quote.zqu__GenerateInvoice__c                  = false;
        quote.Generate_Invoice1__c                     = false;
        //quote.Billing_Type__c                            = itemObj.Main_Package_Billing_Type__c;
    
        if (itemObj.Main_Package_ID__r.Subscription_Type__c == TERM_TYPE_TERMED) {
            if (itemObj.Main_Package_ID__r.Subscription_Period__c != null) {
                quote.zqu__InitialTerm__c = Integer.valueof(itemObj.Main_Package_ID__r.Subscription_Period__c);
            } else {
                quote.zqu__InitialTerm__c = 0;
            }
            quote.zqu__RenewalTerm__c = 0;
        }
        
        return quote;
    }
    
    //START UD-3660 AddedBy FrancisBenzon 18Mar16 : commented out as method not used
    /*
    private list<zqu__QuoteCharge__c> zPopulateQuoteChargePostage(Id zQuoteId,Order_Line_Item__c oli) {                  
        
        list<zqu__QuoteCharge__c> lstCharges = new list<zqu__QuoteCharge__c>();
        
        if (postagePrp != null) {
            
            for (zqu__ProductRatePlanCharge__c prpc: postagePrpIdToPrpcListMap.get(postagePrp.ID)) {

                zqu__QuoteCharge__c zQuoteCharge = new zqu__QuoteCharge__c();
                
                zQuoteCharge.Name = prpc.Name;
                zQuoteCharge.zqu__Quote__c = zQuoteId;
                zQuoteCharge.zqu__ProductRatePlanCharge__c =  prpc.id;
                zQuoteCharge.zqu__Quantity__c = (oli.Qty__c == 0) ? 1 : oli.Qty__c;

                if (oli.Charity__c) {
                    zQuoteCharge.zqu__EffectivePrice__c = 0;
                } else {
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
    */
    //END UD-3660 AddedBy FrancisBenzon 18Mar16 : commented out as method not used
    
    private zqu__Quote__c createQuoteDelivery(Order__c orderObj, Order_Line_Item__c ordItem, String sSubType, String origin) {
        system.debug(':::DELIVERY QUOTE METHOD');
        zqu__Quote__c q1 = new zqu__Quote__c ();    
        q1.Name                                     = ordItem.Name;
        q1.zqu__SubscriptionType__c                 = NEW_SUBSCRIPTION;                    
        q1.zqu__ValidUntil__c                       = Date.Today().addMonths(1);
        q1.zqu__Subscription_Term_Type__c           = ordItem.Main_Package_ID__r.Subscription_Type__c;
        q1.Term_Length1__c = ordItem.Term_Length__c;
        if (ordItem.Term_Length__c != null) {
            q1.zqu__InitialTerm__c = Integer.valueof(ordItem.Term_Length__c);
        } else {
            q1.zqu__InitialTerm__c = 0;
        }
        q1.zqu__RenewalTerm__c = 0;
        q1.zqu__Currency__c                         = CURRENCY_SGD;
        q1.zqu__InvoiceProcessingOption__c          = INVOICE_PROC_OPTION;
        if (orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBL) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBL;
        }
        else if (orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBH) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBH;
        }
        else if (orderObj.Debt_Management_Treatment__c == GlobalVariableClass.GOVT) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_GOVT;   
        }
        else {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_NORM;
        }
        
        //START PD-0041 FrancisBenzon 20May16 : start date for recurring 1st of month
        if(ordItem.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE && ordItem.Start_Date__c.day() == 1)
            q1.zqu__StartDate__c                    = ordItem.Start_Date__c.addDays(-1);
        else
            q1.zqu__StartDate__c                    = ordItem.Start_Date__c;
        //quote.zqu__StartDate__c                        = ordItem.Start_Date__c;
        q1.zqu__TermStartDate__c                    = ordItem.Start_Date__c;
        //END PD-0041 FrancisBenzon 20May16 : start date for recurring 1st of month             
        
        q1.zqu__Service_Activation_Date__c          = orderObj.Delivery_Start_Date__c;
        q1.Acquisition_Type__c                      = orderObj.Acquisition_Type__c;      
        q1.zqu__Account__c                          = orderObj.Account__c;        
        q1.Payment_Mode__c                          = orderObj.Payment_Mode__c; 
        q1.zqu__PaymentMethod__c                    = orderObj.Payment_Mode__c; 
        q1.Other_PaymentMethod__c                   = orderObj.Other_Payment_Mode__c;
        q1.zqu__SoldToContact__c                    = orderObj.Recipient_Contact__c;
        if (orderObj.Billing_Account_External_ID__c != null  || origin == 'ESHOP Webservice') {
            q1.zqu__ZuoraAccountID__c               = orderObj.Billing_Account_External_ID__c;   
        } else {
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
        q1.Order__c                                 = orderObj.ID; 
        q1.Order_Line_Item_Number__c                = ordItem.Id;
        q1.Order_Line_Item_Number_1__c              = ordItem.Id;
        q1.Subscriber_Charge__c                     = orderObj.Subscriber_Charge__c;
        q1.Vendor_Credit__c                         = orderObj.Vendor_Credit__c;
        q1.Main_Package__c                          = ordItem.Main_Package_ID__c;
        q1.Contract_End_Date__c                     = ordItem.Contract_End_Date__c;
        q1.Promotion_Contract_Period__c             = ordItem.Promotion_Contract_Period__c; 
        q1.Qty1__c                                  = ordItem.Qty__c;
        //q1.Billing_Type__c                        = ordItem.Main_Package_Billing_Type__c;
        return q1;
    }


    private void prepareProrationVariables(list<Order_Line_Item__c> orderLineItemListParam) {
        
        for (Product_Frequency__c pf : Product_Frequency__c.getAll().values()) {
            frequencyName_frequencyCode.put((string)pf.get('Frequency__c'), (string)pf.get('Name'));
        }       
        orderLineItemId_packageItemId_productId = new map<id, map<id, id>>();   // use to mapped in creating quote charge
        packageItemId_subscriptionFrequency = new map<id, string>();    // use to mapped in creating quote charge
        map<id, set<id>> packageId_orderLineItemIdSet = new map<id, set<id>>();
        set<id> orderLineItemIdSet;
        
        for (Order_Line_Item__c oli : orderLineItemListParam) {
            
            orderLineItemIdSet = new set<id>();
            
            if (packageId_orderLineItemIdSet.get(oli.Main_Package_Id__c) != null) {
                orderLineItemIdSet = packageId_orderLineItemIdSet.get(oli.Main_Package_Id__c);
            }
            
            orderLineItemIdSet.add(oli.Id);
            packageId_orderLineItemIdSet.put(oli.Main_Package_Id__c, orderLineItemIdSet);
        }
        
        for (Package_Item__c pi : [select id, Package__c, Product_Rate_Plan__r.zqu__ZProduct__c, Product_Rate_Plan__r.SubscriptionFrequency__c 
                from Package_Item__c where Package__c in :packageId_orderLineItemIdSet.keySet()]) {
            
            for (id oliId : packageId_orderLineItemIdSet.get(pi.Package__c)) {
                
                packageItemId_productId = new map<id, id>();
                
                if (orderLineItemId_packageItemId_productId.get(oliId) != null) {
                    packageItemId_productId = orderLineItemId_packageItemId_productId.get(oliId);
                }
                
                packageItemId_productId.put(pi.Package__c, pi.Product_Rate_Plan__r.zqu__ZProduct__c);
                orderLineItemId_packageItemId_productId.put(oliId, packageItemId_productId);
            }
            
            packageItemId_subscriptionFrequency.put(pi.Id, pi.Product_Rate_Plan__r.SubscriptionFrequency__c);
        }
    }
    //START UD-3660 4March2016 FrancisBenzon : discountWrapper
    public class DiscountChargeWrapper
    {
        public Integer effectStartMonth {get; set;}
        public Integer duration {get; set;}
        public Date startDate;
        public boolean isNone;
        
        public DiscountChargeWrapper(Integer int1, Integer int2, Date dateObj, boolean isNone)//START/END UD-0460 MGaelo- added isNone parameter
        {
            this.effectStartMonth = int1; 
            this.duration = int2; 
            this.startDate = dateObj; 
            this.isNone = isNone;
        }
    }
    //END UD-3660 4March2016 FrancisBenzon : discountWrapper
    
    
    // Start UD-3660 10Apr16 JohnD - temporary retry mechanism. 
    private list<zqu__Quote__c> insertQuotes(list<zqu__Quote__c> quoteListParam) {
        
        try {
            insert quoteListParam;
        } catch (exception firstEx) {
            if (firstEx.getMessage().contains(ERR_RECORD_LOCK)) {
                try {
                    insert quoteListParam;
                } catch (exception secondEx) {
                    if (secondEx.getMessage().contains(ERR_RECORD_LOCK)) {
                        try {
                            insert quoteListParam;
                        } catch (exception thirdEx) {
                            logger.log(thirdEx);
                        }
                    } else {
                        logger.log(secondEx);
                    }
                }
            } else {
                logger.log(firstEx);
            }
        }
        
        if (!logger.isEmpty()) {
            logger.save();
            throw new CustomException(System.Label.BO_ERR_RECORD_LOCK);
        }

        return quoteListParam;
    }
    // End UD-3660 10Apr16 JohnD
}