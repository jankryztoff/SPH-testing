/*
 * Class Name: SP_RenewalReminderHelper
 * @author: Kevin H. Evasco
 * Date: 11/19/2015
 * Project/Requirement: Letter Printing - Renewal Reminder Helper
 * @description This class contains utility methods for Renewal Reminder Letter Batch
 * 
 * History: 11/19/2015 Kevin Evasco Created Utility Class
 */
 
 
public class SP_RenewalReminderHelper {

    public static String LANGUAGE_MEDIUM_ENGLISH = 'E';
    public static String LANGUAGE_MEDIUM_CHINESE = 'C';
    //START: D-4262 1-12-2016 Added by Kristine Balaoing - added logging mechanism
    public static List<Exception> exceptionList = new List<Exception>();
    //END: D-4262 1-12-2016 Added by Kristine Balaoing
    
    public class DeliveryPostageFee{
        public Decimal deliveryFee;
        public Decimal postageFee;
    }
    
    public class RenewalRateGroup{
        public Map<Id, RenewalRate> orderLineItemRenewalRateMap = new Map<Id, RenewalRate>();
        public Set<Id> invalidOrderLineItemIdSet = new Set<Id>();
    }

    public class RenewalRate{
        public Decimal renewalBaseRate1;
        public Decimal renewalBaseRate2;
        public Decimal renewalDiscRate1;
        public Decimal renewalDiscRate2;
        public Decimal renewalNewspaperRate;
    }
    
    public static Map<Id,String> getSubscriptionLanguageMediumMap(Set<Id> subscriptionIdSetParam) {    
        Set<String> pubCodeSet = new Set<String>();
        
        List<Publication__c> publicationList = new List<Publication__c>();
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();     
        
        Map<Id, Set<String>> subIdPubCodeSetMap = new Map<Id, Set<String>>();
        Map<String, Publication__c> publicationMap = new Map<String, Publication__c>();
        Map<Id, String> subscriptionLanguageMediumMap = new Map<Id, String>();
        //START: D-4262 1-12-2015 Added by Kristine Balaoing - added logging mechanism
        try{
            
            subProdChargeList = [SELECT id, name, Zuora__Subscription__c, PublicationCode__c 
                             FROM Zuora__SubscriptionProductCharge__c 
                             WHERE Zuora__Subscription__c IN: subscriptionIdSetParam];
            
            for(Zuora__SubscriptionProductCharge__c subProdCharge : subProdChargeList){
                if(subIdPubCodeSetMap.containsKey(subProdCharge.Zuora__Subscription__c)){
                    if(subProdCharge.PublicationCode__c != null && subProdCharge.PublicationCode__c != ''){
                        subIdPubCodeSetMap.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge.PublicationCode__c);
                    }
                } else {
                    if(subProdCharge.PublicationCode__c != null && subProdCharge.PublicationCode__c != ''){
                        subIdPubCodeSetMap.put(subProdCharge.Zuora__Subscription__c, new Set<String>{subProdCharge.PublicationCode__c});
                    }
                }
                pubCodeSet.add(subProdCharge.PublicationCode__c);
            }
            
            publicationList = [SELECT id, name, Publication_Code__c, Language_Medium__c 
                               FROM Publication__c 
                               WHERE Publication_Code__c IN: pubCodeSet];
            
            for(Publication__c pub : publicationList){
                publicationMap.put(pub.Publication_Code__c, pub);
            }
            
            for(Id subId : subIdPubCodeSetMap.keySet()){
                String languageMedium = LANGUAGE_MEDIUM_ENGLISH;
                Boolean isEnglish = true;
                if(subIdPubCodeSetMap.containsKey(subId) && subIdPubCodeSetMap.get(subId).size() > 0){
                    isEnglish = false;
                    for(String pubCode : subIdPubCodeSetMap.get(subId)){
                        if(publicationMap.containsKey(pubCode)){
                            if(publicationMap.get(pubCode).Language_Medium__c == null || publicationMap.get(pubCode).Language_Medium__c != LANGUAGE_MEDIUM_CHINESE){
                                isEnglish = true;
                                break;
                            } 
                        }
                    }
                }
                
                if(!isEnglish)
                    languageMedium = LANGUAGE_MEDIUM_CHINESE;
                
                subscriptionLanguageMediumMap.put(subId, languageMedium);
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
            //END: D-4262 1-12-2016 Added by Kristine Balaoing 
        return subscriptionLanguageMediumMap;
    }   

    public static String getFinalLanguageMedium(List<Letter_Print_Request__c> letterPrintRequestListParam, String languageMedium){
        
        //START: D-4262 1-12-2016 Added by Kristine Balaoing
        try{    
            for(Letter_Print_Request__c letterPrintRequestElem : letterPrintRequestListParam){
                if(languageMedium == SP_RenewalReminderHelper.LANGUAGE_MEDIUM_ENGLISH || 
                    letterPrintRequestElem.Language_Medium__c == SP_RenewalReminderHelper.LANGUAGE_MEDIUM_ENGLISH ){
                    return SP_RenewalReminderHelper.LANGUAGE_MEDIUM_ENGLISH;
                }
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        //END: D-4262 1-12-2016 Added by Kristine Balaoing
        
        return SP_RenewalReminderHelper.LANGUAGE_MEDIUM_CHINESE;
    } 
    
    public static String getFinalLanguageMedium(List<Zuora__Subscription__c> subscriptionListParam, Map<Id,String> subscriptionId_languageMediumMapParam){
        
        //START: D-4262 1-12-2016 Added by Kristine Balaoing
        try{
            for(Zuora__Subscription__c subscriptionElem : subscriptionListParam){
                if(subscriptionId_languageMediumMapParam.get(subscriptionElem.Id) == SP_RenewalReminderHelper.LANGUAGE_MEDIUM_ENGLISH)
                    return SP_RenewalReminderHelper.LANGUAGE_MEDIUM_ENGLISH;
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        //END: D-4262 1-12-2016 Added by Kristine Balaoing
        
        return SP_RenewalReminderHelper.LANGUAGE_MEDIUM_CHINESE;
    } 

    //Required Subscription Fields: Id, Product_Code__c, Delivered_By__c, Recipient_Contact__c, Order_Number_1__r.Delivery_Charge_Type__c, Order_Line_Item_Number_1__c, Qty__c
    // START : UD-3701 1/15/2016 Alyana Navarro
    public static Map<Id, Map<Id, DeliveryPostageFee>> getrecipientDeliveryPostageFeeMap(Map<Id, List<Zuora__Subscription__c>> parentLPRSubscriptionListMap){
        Set<Id> orderLineItemIdSet = new Set<Id>();
        Set<String> noDeliveryProductsSet = new Set<String>();
        
        Map<Id, Map<Id, DeliveryPostageFee>> parentLPRRecipientDeliveryPostageFeeMapMap = new Map<Id, Map<Id, DeliveryPostageFee>>();
        Map<Id,Order_Line_Item__c> orderLineItemMap = new Map<Id,Order_Line_Item__c>();
        
        // START : UD-3510 1/8/2016 Alyana Navarro
        Map<Id, Zuora__Subscription__c> orderLineItemIdDelSubMap = new Map<Id, Zuora__Subscription__c>();
        Map<Id, Id> orderLIRecipientContactIdMap = new Map<Id, Id>();
        Map<Id, Decimal> orderLineItemPostageFeeMap = new Map<Id, Decimal>();
        Map<Id, Contact> recipientContactMap = new Map<Id, Contact>();
        Map<Id, Set<String>> contactDelChargeTypeMap = new Map<Id, Set<String>>();  
        Map<Id, Map<String, Map<String, Decimal>>> contactDelChargeTypeChargesMap = new Map<Id, Map<String, Map<String, Decimal>>>();
        // END : UD-3510 1/8/2016 Alyana Navarro
        
        for(Product_Code__c noDeliveryProductElem : [SELECT Id, Product_Code__c FROM Product_Code__c]) {
            noDeliveryProductsSet.add(noDeliveryProductElem.Product_Code__c);
        }
         
        for(Id parentLPRId : parentLPRSubscriptionListMap.keySet()){
            for(Zuora__Subscription__c subscriptionElem : parentLPRSubscriptionListMap.get(parentLPRId)) {
                orderLineItemIdSet.add(subscriptionElem.Order_Line_Item_Number_1__c);
                
                // START : UD-3510 1/8/2016 Alyana Navarro
                if(!orderLIRecipientContactIdMap.containsKey(subscriptionElem.Order_Line_Item_Number_1__c)){
                    orderLIRecipientContactIdMap.put(subscriptionElem.Order_Line_Item_Number_1__c, subscriptionElem.Recipient_Contact__c);
                }       
                if(!recipientContactMap.containsKey(subscriptionElem.Recipient_Contact__c)){
                    recipientContactMap.put(subscriptionElem.Recipient_Contact__c, subscriptionElem.Recipient_Contact__r);
                }
                if(contactDelChargeTypeMap.containsKey(subscriptionElem.Recipient_Contact__c)){
                    contactDelChargeTypeMap.get(subscriptionElem.Recipient_Contact__c).add(subscriptionElem.Delivery_Charge_Type__c);
                } else {
                    contactDelChargeTypeMap.put(subscriptionElem.Recipient_Contact__c, new Set<String>{subscriptionElem.Delivery_Charge_Type__c});
                }
                // END : UD-3510 1/8/2016 Alyana Navarro
            }
        }
        
        // START : UD-3510 1/8/2016 Alyana Navarro
        for(Zuora__Subscription__c subscription : [SELECT id, name, Subscription_Charge__c, Order_Line_Item_Number_1__c
                                                   FROM Zuora__Subscription__c 
                                                   WHERE Order_Line_Item_Number_1__c IN: orderLineItemIdSet
                                                        AND Subscription_Type__c = 'Delivery']){
            orderLineItemIdDelSubMap.put(subscription.Order_Line_Item_Number_1__c, subscription);
        }
        // END : UD-3510 1/8/2016 Alyana Navarro
        
        orderLineItemMap = new Map<Id,Order_Line_Item__c>([SELECT Id, Main_Package_ID__c, Addon_Package__c FROM Order_Line_Item__c WHERE Id IN :orderLineItemIdSet]);
        
        // START : UD-3510 1/8/2016 Alyana Navarro
        contactDelChargeTypeChargesMap = SM_SubscriptionHelper.getChargesForRenewalLetter(contactDelChargeTypeMap, recipientContactMap);
        orderLineItemPostageFeeMap = PostageChargeHelper.getPostageChargeForLineItemRenewalLetter(orderLineItemMap, orderLIRecipientContactIdMap);
        // END : UD-3510 1/8/2016 Alyana Navarro
                
        for(Id parentLPRId : parentLPRSubscriptionListMap.keySet()){
            for(Zuora__Subscription__c subscriptionElem : parentLPRSubscriptionListMap.get(parentLPRId)){
                Decimal tempDeliveryPostageFee = 0;
                
                if(!parentLPRRecipientDeliveryPostageFeeMapMap.containsKey(parentLPRId))
                    parentLPRRecipientDeliveryPostageFeeMapMap.put(parentLPRId, new Map<Id, DeliveryPostageFee>());
                
                if(!parentLPRRecipientDeliveryPostageFeeMapMap.get(parentLPRId).containsKey(subscriptionElem.Recipient_Contact__c)){
                    parentLPRRecipientDeliveryPostageFeeMapMap.get(parentLPRId).put(subscriptionElem.Recipient_Contact__c, new DeliveryPostageFee());
                }
                
                if(noDeliveryProductsSet.contains(subscriptionElem.Product_Code__c) == false) {
                    if(subscriptionElem.Delivered_By__c == 'Vendor'){
                        if(subscriptionElem.Delivery_Charge_Type__c != 'S') {
                        Map<String, Decimal> chargeMap = contactDelChargeTypeChargesMap.get(subscriptionElem.Recipient_Contact__c).get(subscriptionElem.Delivery_Charge_Type__c); // START-END : UD-3510 1/8/2016 Alyana Navarro
                            if(chargeMap.get('SubscriberCharge') != null)
                                tempDeliveryPostageFee = chargeMap.get('SubscriberCharge');
                        } else {
                            tempDeliveryPostageFee = orderLineItemIdDelSubMap.get(subscriptionElem.Order_Line_Item_Number_1__c).Subscription_Charge__c; // START-END : UD-3510 1/8/2016 Alyana Navarro
                        }
                                               
                        // START : UD-3507 1/5/2016 Alyana Navarro                      
                        if(parentLPRRecipientDeliveryPostageFeeMapMap.get(parentLPRId).get(subscriptionElem.Recipient_Contact__c).deliveryFee == null || parentLPRRecipientDeliveryPostageFeeMapMap.get(parentLPRId).get(subscriptionElem.Recipient_Contact__c).deliveryFee < tempDeliveryPostageFee){
                            parentLPRRecipientDeliveryPostageFeeMapMap.get(parentLPRId).get(subscriptionElem.Recipient_Contact__c).deliveryFee = tempDeliveryPostageFee; 
                        }                       
                        // END : UD-3507 1/5/2016 Alyana Navarro                        
                    } else if(subscriptionElem.Delivered_By__c == 'Mailing Agent'){
                        Order_Line_Item__c orderLineItem = orderLineItemMap.get(subscriptionElem.Order_Line_Item_Number_1__c);
                        if(orderLineItem != null){
                            Decimal postageChargeForOLI = orderLineItemPostageFeeMap.get(orderLineItem.id); // START-END : UD-3510 1/8/2016 Alyana Navarro
                            if(postageChargeForOLI != null && subscriptionElem.Qty__c != null)
                                tempDeliveryPostageFee = postageChargeForOLI * subscriptionElem.Qty__c;
                        }                        
                        // START : UD-3507 1/5/2016 Alyana Navarro
                        if(parentLPRRecipientDeliveryPostageFeeMapMap.get(parentLPRId).get(subscriptionElem.Recipient_Contact__c).postageFee == null || parentLPRRecipientDeliveryPostageFeeMapMap.get(parentLPRId).get(subscriptionElem.Recipient_Contact__c).postageFee < tempDeliveryPostageFee){
                            parentLPRRecipientDeliveryPostageFeeMapMap.get(parentLPRId).get(subscriptionElem.Recipient_Contact__c).postageFee = tempDeliveryPostageFee; 
                        }
                        // END : UD-3507 1/5/2016 Alyana Navarro                        
                    }
                } else {                    
                    // START : UD-3507 1/5/2016 Alyana Navarro
                    if(parentLPRRecipientDeliveryPostageFeeMapMap.get(parentLPRId).get(subscriptionElem.Recipient_Contact__c).deliveryFee == null || parentLPRRecipientDeliveryPostageFeeMapMap.get(parentLPRId).get(subscriptionElem.Recipient_Contact__c).deliveryFee < tempDeliveryPostageFee){
                        parentLPRRecipientDeliveryPostageFeeMapMap.get(parentLPRId).get(subscriptionElem.Recipient_Contact__c).deliveryFee = tempDeliveryPostageFee; 
                    }
                    // END : UD-3507 1/5/2016 Alyana Navarro                   
                }
            }
        }
        
        
        return parentLPRRecipientDeliveryPostageFeeMapMap;
    }
    // END : UD-3701 1/15/2016 Alyana Navarro
    //START PD-0147 13May2016 Added By C. Lin - Add batchMode parameter
    //START PD-0146 Gdelrosario : added scenario for not adhoc
    public static Set<Id> getSuspendedOrderLineItemSet(List<Zuora__Subscription__c> subscriptionList, Map<String, zqu__ZProduct__c> productMap, Date adhocBatchRunDate, Boolean isAdhoc, String batchMode){        
        Set<Id> suspendedOrderLineItemId = new Set<Id>();
        Map<Id, List<Zuora__Subscription__c>> orderLineItemSubscriptionListMap = new Map<Id, List<Zuora__Subscription__c>>();
        
        //START: D-4262 1-12-2016 Added by Kristine Balaoing
        try{
            for(Zuora__Subscription__c subscription : subscriptionList){            
                if(orderLineItemSubscriptionListMap.containsKey(subscription.Order_Line_Item_Number_1__c)){
                    orderLineItemSubscriptionListMap.get(subscription.Order_Line_Item_Number_1__c).add(subscription);
                } else {
                    orderLineItemSubscriptionListMap.put(subscription.Order_Line_Item_Number_1__c, new List<Zuora__Subscription__c>{subscription});
                
                }           
            }
            
            for(Id orderLineItemId : orderLineItemSubscriptionListMap.keySet()){
                Boolean isOrderLineSuspended = true;
                for(Zuora__Subscription__c subscription : orderLineItemSubscriptionListMap.get(orderLineItemId)){
                    if(productMap.containsKey(subscription.Product_Code__c)) {
                        if(!isAdhoc){
                        //START D-4354 27.1.2016 Gdelrosario : added the custom setting for configurability
                        if(subscription.Main_Package_Product_Sub_Type_Mapping__c == 'Magazine'){
                            if(subscription.Zuora__SubscriptionEndDate__c == Date.Today().addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Magazine',true))){
                                if(!productMap.get(subscription.Product_Code__c).Suppress_Renewal_Letter__c){
                                    isOrderLineSuspended = false;
                                }
                            } else if(subscription.Zuora__SubscriptionEndDate__c == Date.Today().addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Magazine',false))){
                                if(!productMap.get(subscription.Product_Code__c).Suppress_Reminder_Letter__c){
                                    isOrderLineSuspended = false;
                                }
                            }
                        }else if(subscription.Main_Package_Product_Sub_Type_Mapping__c == 'Newspaper'){
                            if(subscription.Zuora__SubscriptionEndDate__c == Date.Today().addDays((ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Newspaper',true)))){
                                if(!productMap.get(subscription.Product_Code__c).Suppress_Renewal_Letter__c){
                                    isOrderLineSuspended = false;
                                }
                            } else if(subscription.Zuora__SubscriptionEndDate__c == Date.Today().addDays((ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Newspaper',false)))){
                                if(!productMap.get(subscription.Product_Code__c).Suppress_Reminder_Letter__c){
                                    isOrderLineSuspended = false;
                                }
                            }
                        }
                    //END D-4354 27.1.2016 Gdelrosario : added the custom setting for configurability
                    } else {
                            if(batchMode == 'N'){
                                if(subscription.Main_Package_Product_Sub_Type_Mapping__c == 'Magazine'){
                                    if(subscription.Zuora__SubscriptionEndDate__c == adhocBatchRunDate.addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Magazine',true))){
                                        if(!productMap.get(subscription.Product_Code__c).Suppress_Renewal_Letter__c){
                                            isOrderLineSuspended = false;
                                        }
                                    } else if(subscription.Zuora__SubscriptionEndDate__c == adhocBatchRunDate.addDays(ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Magazine',false))){
                                        if(!productMap.get(subscription.Product_Code__c).Suppress_Reminder_Letter__c){
                                            isOrderLineSuspended = false;
                                        }
                                    }
                                }else if(subscription.Main_Package_Product_Sub_Type_Mapping__c == 'Newspaper'){
                                    if(subscription.Zuora__SubscriptionEndDate__c == adhocBatchRunDate.addDays((ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Newspaper',true)))){
                                        if(!productMap.get(subscription.Product_Code__c).Suppress_Renewal_Letter__c){
                                            isOrderLineSuspended = false;
                                        }
                                    } else if(subscription.Zuora__SubscriptionEndDate__c == adhocBatchRunDate.addDays((ConstantsSLB.getRenewalNotificationDay('Renewal Notifications Values','Newspaper',false)))){
                                        if(!productMap.get(subscription.Product_Code__c).Suppress_Reminder_Letter__c){
                                            isOrderLineSuspended = false;
                                        }
                                    }
                                }
                            }else{
                                isOrderLineSuspended = false;
                            }
                        }
                    } else {
                        suspendedOrderLineItemId.add(orderLineItemId);
                    }
                }
                
                if(isOrderLineSuspended){
                    suspendedOrderLineItemId.add(orderLineItemId);
                }
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        return suspendedOrderLineItemId;
    }
    //END PD-0146 Gdelrosario : added scenario for not adhoc
    //END PD-0147 13May2016 Added By C. Lin
    public static Set<Id> getOrderLineItemWithInvalidPackage(List<Zuora__Subscription__c> subscriptionList){
        Set<Id> suspendedOrderLineItemId = new Set<Id>();
        
        //START: D-4262 1-12-2016 Added by Kristine Balaoing
        try{
            // START : D-4004 12/2/2015 Alyana Navarro
            for(Zuora__Subscription__c subscription : subscriptionList){
                if(subscription.Main_Package_1__r.Effective_End_Date__c == null || subscription.Main_Package_1__r.Effective_End_Date__c <= Date.Today()){
                    suspendedOrderLineItemId.add(subscription.Order_Line_Item_Number_1__c);
                }
            }
            // END : D-4004 12/2/2015 Alyana Navarro
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        //END: D-4262 1-12-2016 Added by Kristine Balaoing
        return suspendedOrderLineItemId;
    }
    
    // START : UD-3338 12/3/2015 Alyana Navarro
    public static String getSubscriptionTableLabel(String publicationType, Map<String, zqu__ZProduct__c> productMap, Map<id, Package__c> packageMap, List<Zuora__Subscription__c> subscriptionList){
        String subscriptionLabel = '';
        
        //START: D-4262 1-12-2016 Added by Kristine Balaoing
        try{
            if(publicationType == 'Magazine'){
                for(Integer counter = 0; counter < subscriptionList.size(); counter++){
                    subscriptionLabel += productMap.get(subscriptionList[counter].Product_Code__c).name;
                    
                    if((counter + 1) != subscriptionList.size()){
                        subscriptionLabel += '/';
                    }
                }
            } else if(publicationType == 'Newspaper'){
                Zuora__Subscription__c subscription = subscriptionList[0];
                if(packageMap.get(subscription.Main_Package_1__c).RenewalPkgCodeNewspaper__c != null){
                    subscriptionLabel = packageMap.get(subscription.Main_Package_1__c).RenewalPkgCodeNewspaper__r.name;
                } else if(packageMap.get(subscription.Main_Package_1__c).Same_Pck_Renewal_Newspaper__c){
                    subscriptionLabel = packageMap.get(subscription.Main_Package_1__c).name;
                } else if(productMap.get(subscription.Product_Code__c).RenewalPkgCodeNewspaper__c != null && packageMap.get(subscription.Main_Package_1__c).Package_Type__c != 'Bundle'){
                    subscriptionLabel = productMap.get(subscription.Product_Code__c).RenewalPkgCodeNewspaper__r.name;
                }
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        
        //END: D-4262 1-12-2016 Added by Kristine Balaoing
        return subscriptionLabel;
    }
    // END : UD-3338 12/3/2015 Alyana Navarro
    public static RenewalRateGroup getRenewalRates(List<Zuora__Subscription__c> subscriptionList, Map<Id, Package__c> mainPackageMap, Map<String, zqu__ZProduct__c> productMap){       
        RenewalRate renewalRateRec;
        RenewalRateGroup renewalRateGroupRec = new RenewalRateGroup();
        Set<Id> invalidOrderLineItemIdSet = new Set<Id>();
        
        //START: D-4262 1-12-2016 Added by Kristine Balaoing
        try{
            // START : D-3997 11/26/2015 Alyana Navarro
            for(Zuora__Subscription__c subscription : subscriptionList){
                Boolean isPackageBundle = false;
                renewalRateRec = new RenewalRate();
                if(mainPackageMap.containsKey(subscription.Main_Package_1__c)){
                    Package__c packageRec = mainPackageMap.get(subscription.Main_Package_1__c);
                    zqu__ZProduct__c productRec = productMap.get(subscription.Product_Code__c);
                    if(subscription.Main_Package_Product_Sub_Type_Mapping__c == 'Magazine'){
                        if(packageRec.RenewalPkgCodeMag1YrBase__c != null){
                            renewalRateRec.renewalBaseRate1 = packageRec.RenewalPkgCodeMag1YrBase__r.Package_Price__c;
                        } else if(packageRec.Same_Pck_Renewal_Mag_1_Yr_Base__c){
                            renewalRateRec.renewalBaseRate1 = packageRec.Package_Price__c;
                        } else if(productRec.RenewalPkgCodeMag1YrBase__c != null && packageRec.Package_Type__c != 'Bundle'){                    
                            renewalRateRec.renewalBaseRate1 = productRec.RenewalPkgCodeMag1YrBase__r.Package_Price__c;                      
                        } else {
                            invalidOrderLineItemIdSet.add(subscription.Order_Line_Item_Number_1__c);
                        }
                        
                        if(packageRec.RenewalPkgCodeMag2YrBase__c != null){
                            renewalRateRec.renewalBaseRate2 = packageRec.RenewalPkgCodeMag2YrBase__r.Package_Price__c;
                        } else if(packageRec.Same_Pck_Renewal_Mag_2_Yr_Base__c){
                            renewalRateRec.renewalBaseRate2 = packageRec.Package_Price__c;
                        } else if(productRec.RenewalPkgCodeMag2YrBase__c != null && packageRec.Package_Type__c != 'Bundle'){
                            //START: D-4089 12-14-2015 Added by Kristine Balaoing - added null checker to avoid attempt to dereference a null object error
                            if(productRec.RenewalPkgCodeMag2YrBase__r.Package_Price__c <> null){
                                renewalRateRec.renewalBaseRate2 = productRec.RenewalPkgCodeMag2YrBase__r.Package_Price__c;
                            }
                            //END: D-4089 12-14-2015 Added by Kristine Balaoing
                        } else {
                            invalidOrderLineItemIdSet.add(subscription.Order_Line_Item_Number_1__c);
                        }
                        
                        if(packageRec.RenewalPkgCodeMag1YrDisc__c != null){
                            renewalRateRec.renewalDiscRate1 = packageRec.RenewalPkgCodeMag1YrDisc__r.Package_Price__c;
                        } else if(packageRec.Same_Pck_Renewal_Mag_1_Yr_Disc__c){
                            renewalRateRec.renewalDiscRate1 = packageRec.Package_Price__c;
                        } else if(productRec.RenewalPkgCodeMag1YrDisc__c != null && packageRec.Package_Type__c != 'Bundle'){
                            renewalRateRec.renewalDiscRate1 = productRec.RenewalPkgCodeMag1YrDisc__r.Package_Price__c;
                        } else {
                            invalidOrderLineItemIdSet.add(subscription.Order_Line_Item_Number_1__c);
                        }
                        
                        if(packageRec.RenewalPkgCodeMag2YrDisc__c != null){
                            renewalRateRec.renewalDiscRate2 = packageRec.RenewalPkgCodeMag2YrDisc__r.Package_Price__c;
                        } else if(packageRec.Same_Pck_Renewal_Mag_2_Yr_Disc__c){
                            renewalRateRec.renewalDiscRate2 = packageRec.Package_Price__c;
                        } else if(productRec.RenewalPkgCodeMag2YrDisc__c != null && packageRec.Package_Type__c != 'Bundle'){
                            renewalRateRec.renewalDiscRate2 = productRec.RenewalPkgCodeMag2YrDisc__r.Package_Price__c;
                        } else {
                            invalidOrderLineItemIdSet.add(subscription.Order_Line_Item_Number_1__c);
                        }
                    } else if(subscription.Main_Package_Product_Sub_Type_Mapping__c == 'Newspaper'){                                
                        if(packageRec.RenewalPkgCodeNewspaper__c != null){
                            renewalRateRec.renewalNewspaperRate = packageRec.RenewalPkgCodeNewspaper__r.Package_Price__c;
                        } else if(packageRec.Same_Pck_Renewal_Newspaper__c){
                            renewalRateRec.renewalNewspaperRate = packageRec.Package_Price__c;
                        } else if(productRec.RenewalPkgCodeNewspaper__c != null && packageRec.Package_Type__c != 'Bundle'){
                            renewalRateRec.renewalNewspaperRate = productRec.RenewalPkgCodeNewspaper__r.Package_Price__c;
                        } else {
                            invalidOrderLineItemIdSet.add(subscription.Order_Line_Item_Number_1__c);
                        }
                    }
                }                       
                
                if(!invalidOrderLineItemIdSet.contains(subscription.Order_Line_Item_Number_1__c)){
                    renewalRateGroupRec.orderLineItemRenewalRateMap.put(subscription.Order_Line_Item_Number_1__c, renewalRateRec);
                }           
            }
            // END : D-3997 11/26/2015 Alyana Navarro
            renewalRateGroupRec.invalidOrderLineItemIdSet.addAll(invalidOrderLineItemIdSet);
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList);
        //END: D-4262 1-12-2016 Added by Kristine Balaoing
        return renewalRateGroupRec; 
    }
}