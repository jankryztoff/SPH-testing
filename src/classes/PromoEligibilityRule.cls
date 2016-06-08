public class PromoEligibilityRule {
     //variables
     String Promo;
     String platform;
     List<Publication__c> publicationsList;
     //START: D-1627 1/22/2015 Added by Kristine Campang - added varible
     Map<String, List<Promotion_Eligibility_Rule__c>> mapPromoEligRule;
     //END: D-1627 1/22/2015 Added by Kristine Campang
     Map<String, List<Zuora__Subscription__c>> mapPromocodeSubscription; 
     Map<String, Set<String>> mapPromoToPackageList;
     Map<String, String> mapPackageCodeToProductFamily;
     Map<String, Promotion__c> mapPromoConCatContractToPromotionRec;
     Map<String, Set<String>> mapPromoToPackageCodeSet;
     Map<String, Promotion__c> mapPromoCodeToPromoCodeRec;
     List<Promotion__c> promotionList;
     List<Set<String>> valuesSet;
     Set<String> FinalContractSet;
     Set<String> prodFamSet;
     Set<String> PackageCodeSet;
     Set<Boolean> boolSet;
     Set<Id> promoIdSet;
     Date dateParam;
     String accCustomerStatus;
     Zuora__Subscription__c zuoSub;
     
    //START:D-1629 2/5/15 Added by Manolo Valeña - Added a new parameter for the getEligibility method.
    public Map<String, Set<String>> getEligibility(Id accId, String action, Map<String , Set<String>> promoCodeContractSet, String pkgCode, Id subsId, Boolean booleanVar) {    
    //END:D-1629 2/5/15 Added by Manolo Valeña
    
        //variable instantiation 
        publicationsList = new List<Publication__c>();
        prodFamSet= new Set<String>();
        //START D-2888 5/27/2015 Added by Manolo Valena - This should be removed as this is relocated within the loop of the logic.
        //boolSet = new Set<Boolean>();
        //END D-2888 5/27/2015 Added by Manolo Valena
        promoIdSet = new Set<Id>();
        promotionList = new List<Promotion__c>();
        valuesSet = new List<Set<String>>();
        FinalContractSet = new Set<String>();
        mapPromoToPackageCodeSet = new Map<String, Set<String>>();
        //START: D-1627 1/22/2015 Added by Kristine Campang - changed variable declaration
        mapPromoEligRule = new Map<String, List<Promotion_Eligibility_Rule__c>>();
        //END: D-1627 1/22/2015 Added by Kristine Campang
        mapPromoCodeToPromoCodeRec = new Map<String, Promotion__c>();
        mapPromocodeSubscription = new Map<String, List<Zuora__Subscription__c>>();
        mapPackageCodeToProductFamily = new Map<String, String>();  
        mapPromoToPackageList = new Map<String, Set<String>>();
        //START: D-1628, D-1629, D-605, D-1627 1/22/2015 Added by Kristine Campang - added variables
        Map<String, List<Promotion__c>> promoListMap = new Map<String, List<Promotion__c>>();  
        Set<String> promoCodeSet = new Set<String>();
        Set<String> promoPeriodSet = new Set<String>();
        Map<String, Promotion__c> mapPromoConCatContractToPromotionRec = new Map<String, Promotion__c>();
        Map<String, String> mapZSubToProdFam = new Map<String, String>();
        Set<String> setRatePlan = new Set<String>();
        List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c>();
        List<Zuora__SubscriptionProductCharge__c> zuoSubProdCharg = new List<Zuora__SubscriptionProductCharge__c>();
        //START 2/18/15 MGAELO Code Review: Added declaration of variable
        Account acct = new Account();
        List<Promotion__c> promoList = new List<Promotion__c>();
        List<Promotion_Package__c> promoPackList = new List<Promotion_Package__c>();
        List<Promotion_Eligibility_Rule__c> pErs = new List<Promotion_Eligibility_Rule__c>();
        //END 2/18/15 Added MGAELO 
        
        //END: D-1628, D-1629, D-605, D-1627 1/22/2015 Added by Kristine Campang
        
        //START:D-1629 2/5/15 Added by Manolo Valeña - Added the field "Parent.Id" to the query.
        //START:D-1835 and D-1834 1/29/15 Added by Manolo Valeña - Added the "Zuora__Status__c" field to the query.
        //START: 2/18/15 Code Review: MGaelo Check if accId is null and moved declation of acct
        if (accId !=null){
                    acct = [SELECT id, RecordType.Name, 
                             (SELECT id, Order_Number__c, Promotion_1__r.Promotion_Code__c,                     Zuora__SubscriptionEndDate__c, Contract_End_Date_1__c, Zuora__Status__c, 
                             //START:UD-2977 11/5/15 Added by Manolo Valena - Added the fields Order_Line_Item_Number_1__c and Contract_End_Date_1__c for the subscription query.
                             Main_Package_1__r.Product_Family_Current_Package__c, Order_Line_Item_Number_1__c, Subscription_Type_1__c FROM Zuora__Subscriptions__r), Parent.Id  
                             //END:UD-2977 11/5/15 Added by Manolo Valena 
                             FROM Account 
                             WHERE id =: accId];   
        }
        //END 2/18/15 Added by MGaelo
        //END:D-1835 and D-1834 1/29/15 Added by Manolo Valeña
        //END:D-1629 2/5/15 Added by Manolo Valeña
        
        //START:UD-2977 11/5/15 Added by Manolo Valena - Map all subscriptions of the Account with their corresponding product platform.
        Map<Id, List<Zuora__Subscription__c>> bundleOliToSubsMap = new Map<Id, List<Zuora__Subscription__c>>();
        Set<Id> subscriptionIdSet = new Set<Id>();
        Set<String> zRPNSet = new Set<String>();
        Set<String> zSKUSet = new Set<String>();
        Map<Id, Set<String>> subscriptionToSPCSKUsMap = new Map<Id, Set<String>>(); 
        Map<String, String> skuToProductPlatformMap = new Map<String, String>();
        Map<Id, String> subscriptionToProductPlatformMap = new Map<Id, String>();
        
        if(acct.Zuora__Subscriptions__r.size() > 0) {
            for(Zuora__Subscription__c zsRec : acct.Zuora__Subscriptions__r) {
                //Map all order line items with their corresponding subscription records. This is for bundle.
                if(zsRec.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION) {
                    if(bundleOliToSubsMap.containsKey(zsRec.Order_Line_Item_Number_1__c)) {
                        bundleOliToSubsMap.get(zsRec.Order_Line_Item_Number_1__c).add(zsRec);
                    }
                    else {
                        bundleOliToSubsMap.put(zsRec.Order_Line_Item_Number_1__c, new List<Zuora__Subscription__c>{zsRec});
                    }
                    subscriptionIdSet.add(zsRec.Id);
                }
            }
        }
        
        if(subscriptionIdSet.size() > 0) {
            for(Zuora__SubscriptionProductCharge__c zSPCRec : [SELECT Id, Zuora__RatePlanName__c, Zuora__ProductName__c,
                                                                      Zuora__Quantity__c, Product_Code__c, Zuora__ProductSKU__c, 
                                                                      Zuora__Price__c, Zuora__BillingPeriod__c, Zuora__Subscription__c
                                                               FROM Zuora__SubscriptionProductCharge__c
                                                               WHERE Zuora__Subscription__c IN: subscriptionIdSet
                                                               AND Zuora__Model__c != 'Discount-Percentage']) {
                zRPNSet.add(zSPCRec.Zuora__RatePlanName__c);
                zSKUSet.add(zSPCRec.Zuora__ProductSKU__c);
                
                if(subscriptionToSPCSKUsMap.containsKey(zSPCRec.Zuora__Subscription__c)) {
                    if(zSPCRec.Zuora__ProductSKU__c != null) {  
                        subscriptionToSPCSKUsMap.get(zSPCRec.Zuora__Subscription__c).add(zSPCRec.Zuora__ProductSKU__c);
                    }
                }
                else {
                    if(zSPCRec.Zuora__ProductSKU__c != null) {
                        subscriptionToSPCSKUsMap.put(zSPCRec.Zuora__Subscription__c, new Set<String>{zSPCRec.Zuora__ProductSKU__c});
                    }
                }
            }
        }
        
        if(zRPNSet.size() > 0 && zSKUSet.size() > 0) {
            for(zqu__ProductRatePlan__c prpRec : [SELECT Id, Name, BillingType__c, Product_Code__c, 
                                                         RatePlanCode__c, RatePlanType__c, zqu__ZProduct__r.zqu__SKU__c,
                                                         SubscriptionFrequency__c, zqu__ZProduct__r.ProductPlatform__c
                                                  FROM zqu__ProductRatePlan__c
                                                  WHERE Name IN: zRPNSet 
                                                  AND zqu__ZProduct__r.zqu__SKU__c IN: zSKUSet
                                                  AND RatePlanType__c = 'Bill Plan'
                                                  AND zqu__Deleted__c = false]) {
                if(!skuToProductPlatformMap.containsKey(prpRec.zqu__ZProduct__r.zqu__SKU__c)) { 
                    skuToProductPlatformMap.put(prpRec.zqu__ZProduct__r.zqu__SKU__c, prpRec.zqu__ZProduct__r.ProductPlatform__c);
                }
            }
        }
        
        if(subscriptionToSPCSKUsMap.keySet().size() > 0) {
            for(Id sId : subscriptionToSPCSKUsMap.keySet()) {
                for(String sku : subscriptionToSPCSKUsMap.get(sId)) {
                    if(skuToProductPlatformMap.containsKey(sku)) {  
                        if(!subscriptionToProductPlatformMap.containsKey(sId)) {    
                            subscriptionToProductPlatformMap.put(sId, skuToProductPlatformMap.get(sku));
                        }
                    }
                }
            }
        }
        //END:UD-2977 11/5/15 Added by Manolo Valena
        
        //START:D-1629 2/5/15 Added by Manolo Valeña - Created new query to get product families of the subscription vendors.
        List<Subscription_Vendor__c> subVen = [SELECT (SELECT Id, Publication__r.Product_Family__c FROM Subscription_Vendor_Publications__r LIMIT 1) 
                                               FROM Subscription_Vendor__c 
                                               WHERE Account__c =: acct.Parent.Id 
                                               AND Status__c = 'Active'];
        //END:D-1629 2/5/15 Added by Manolo Valeña
        
        // Verify if Vendor account or account has existing subscriptions or none 
        if(acct.RecordType.Name == 'Vendor' || acct.RecordType.Name == 'Vendor Subscriber') 
        {
            accCustomerStatus = 'Vendor Customer';
        }
        else 
        {
            //START:D-1629 2/5/15 Added by Manolo Valeña - Added an if-else statement to take into account the additional parameter added, which is booleanVar.
            if(booleanVar == null || !booleanVar)
            {
                if(acct.Zuora__Subscriptions__r.size() == 0) 
                {
                    accCustomerStatus = 'New Customer';
                }
                else 
                {
                    accCustomerStatus = 'Existing Customer';   
                }
            }
            else
            {
                accCustomerStatus = 'Vendor Customer';
            }
            //END:D-1629 2/5/15 Added by Manolo Valeña
        }
        
        //START: D-1627, 1628, 1629 1/21/2015 Added by Kristine Campang - added new approach for getting map of promocode to contractDates
        promoCodeSet = promoCodeContractSet.KeySet();
        valuesSet = promoCodeContractSet.values();
        for(Set<String> contractSet : valuesSet){
            for(String contractString : contractSet){    
                promoPeriodSet.add(contractString);
            }
        }
        //Start 2/18/15 MGaelo Code Review: Check if promoCodeSet is null and moved promoList declaration
        if (promoCodeSet.size()>0 && promoPeriodSet.size()>0){
            promoList = [SELECT id, name, Promotion_Code__c, Contract_Period__c FROM Promotion__c WHERE Promotion_Code__c IN: promoCodeSet AND Contract_Period__c IN: promoPeriodSet];
        }
        //END 2/18/15 Added by MGaelo
        System.debug('PROMOLIST:' + promoList);

        for(Promotion__c promo : promoList){
            if(promoCodeContractSet.containsKey(promo.Promotion_Code__c)){
                if(promoCodeContractSet.get(promo.Promotion_Code__c).contains(promo.Contract_Period__c)){
                    if(promoListMap.containsKey(promo.Promotion_Code__c)){
                        promoListMap.get(promo.Promotion_Code__c).add(promo);
                    } 
                    else {
                        promoListMap.put(promo.Promotion_Code__c, new List<Promotion__c> {promo});
                    }
                }
            }
        }
        for(String promoCd : promoListMap.KeySet()){
            for(Promotion__c promoRec : promoListMap.get(promoCd)){
                promotionList.add(promoRec);
                promoIdSet.add(promoRec.Id);
            }
        }
        System.debug('PROMOTIONLIST' + promotionList);
        
        if(subsId!=null){
            zuoSub = [SELECT Id, Order_Number__c, Promotion_1__r.Promotion_Code__c,Zuora__SubscriptionEndDate__c,                    Contract_End_Date_1__c, 
                                //START:UD-2977 11/5/15 Added by Manolo Valena - Added the fields Main_Package_1__r.Package_Type__c and Order_Line_Item_Number_1__c.
                                Main_Package_1__r.Product_Family_Current_Package__c, Main_Package_1__r.Package_Type__c, Order_Line_Item_Number_1__c
                                //END:UD-2977 11/5/15 Added by Manolo Valena
                                FROM Zuora__Subscription__c
                                WHERE Id = :subsId];
            zuoSubProdCharg = [SELECT Id, Zuora__RatePlanName__c, Zuora__ProductName__c,                                                        Zuora__Quantity__c, Product_Code__c,                                                        Zuora__ProductSKU__c, Zuora__Price__c, Zuora__BillingPeriod__c,                                                         Zuora__Subscription__c
                                                                    FROM Zuora__SubscriptionProductCharge__c
                                                                    WHERE Zuora__Subscription__c =:subsId];
                                
            for(Zuora__SubscriptionProductCharge__c zSPC : zuoSubProdCharg){
                setRatePlan.add(zSPC.Zuora__RatePlanName__c);
             }
          
            //List all Product Rate Plan under Subscription Product and Charges

            if(setRatePlan.size()>0){
                //START:D-1632 1/23/15 Added by Manolo Vale�a - Added missing fields in the query. "zqu__ZProduct__r.ProductPlatform__c"
                productRatePlanList = [SELECT Id, Name, BillingType__c, Product_Code__c, RatePlanCode__c, RatePlanType__c, SubscriptionFrequency__c, zqu__ZProduct__r.ProductPlatform__c
                                        FROM zqu__ProductRatePlan__c
                                        WHERE Name IN :setRatePlan AND zqu__ZProduct__r.zqu__SKU__c = :zuoSubProdCharg[0].Zuora__ProductSKU__c and RatePlanType__c = 'Bill Plan']; 
                //END:D-1632 1/23/15 Added by Manolo Vale�a
            }
            //START:D-1632 1/23/15 Added by Manolo Vale�a - Added an if else condition to remove out of bounds error when the list is null.
            if(!productRatePlanList.isEmpty())
            {
                zqu__ProductRatePlan__c ratePlan = productRatePlanList[0];
                platform = ratePlan.zqu__ZProduct__r.ProductPlatform__c;
            }
            else
            {
                platform = null;
            }
            //END:D-1632 1/23/15 Added by Manolo Vale�a
        }
            
        //END: D-1627, 1628, 1629 1/21/2015 Added by Kristine Campang
        //START MGaelo 2/18/15 Code Review: Check if promoIdSet and promoPackList is null and moved declaration
        if (promoIdSet.size()>0){
            promoPackList = [SELECT Id, Package_Name__c, Promotion__c, Promotion_Name__c, 
                                                        Package_Name__r.Package_Code__c, Package_Name__r.Product_Family_Current_Package__c
                                                        FROM Promotion_Package__c
                                                        WHERE Promotion__c IN :promoIdSet];
        }
        
        if(promoPackList !=null){
            for(Promotion_Package__c promoPack : promoPackList){
                //PackageCodeSet.add(promoPack.Package_Name__r.Package_Code__c);
                mapPackageCodeToProductFamily.put(promoPack.Package_Name__r.Package_Code__c, promoPack.Package_Name__r.Product_Family_Current_Package__c);
                
                //map of Promo to PackageCodede Set
                if(mapPromoToPackageCodeSet.containsKey(promoPack.Promotion__c)){
                    mapPromoToPackageCodeSet.get(promoPack.Promotion__c).add(promoPack.Package_Name__r.Package_Code__c);
                }
                else{
                    mapPromoToPackageCodeSet.put(promoPack.Promotion__c , new Set<String>{promoPack.Package_Name__r.Package_Code__c});
                }
            }
        }
        //END 2/18/15 Added by MGaelo
        for(Zuora__Subscription__c zSub : acct.Zuora__Subscriptions__r) {
            prodFamSet.add(zSub.Main_Package_1__r.Product_Family_Current_Package__c);
            //compare it with the searched Package (look at all subscritpion irrespective of the status)
            //Zuora is deleting subscription (looks like we only have the active subscriptions)
            //START: D-1627 1/22/2015 Added by Kristine Campang - added map of subscription to Prod Family
            mapZSubToProdFam.put(zSub.Id, zSub.Main_Package_1__r.Product_Family_Current_Package__c);
        }
        
        Set<Id> eligibilityRuleIds = new Set<Id>();
        //START:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a - Added "(select Id, Product_Family__r.Product_Family__c from Promo_Eligibility_Rule_Product_Families__r)" to the query.
        //START:D-1632 1/23/15 Added by Manolo Vale�a - Added missing fields in the query. "Eligibility_Rule__r.Contract_Status__c" and "Current_Platform__c"
        //START 2/18/15 MGAELO Code Review: Check if promoIdSet is null and moved declaration of pErs
        if (promoIdSet.size()>0){
             pErs = [SELECT Id, Promotion__r.Promotion_Code__c, Eligibility_Rule__c, Package_List__c                                            ,Promotion__r.Contract_Period__c , Promotion__c, Product_Family__c,
                                                        Eligibility_Rule__r.Customer_Status__c, Eligibility_Rule__r.Action__c, Eligibility_Rule__r.Condition__c, Eligibility_Rule__r.Subsciber_Status__c, Eligibility_Rule__r.Contract_Subscription_Rule__c, Date__c, Days__c, Eligibility_Rule__r.Contract_Status__c, Current_Platform__c,
                                                        (select Id, Product_Family__r.Product_Family__c from Promo_Eligibility_Rule_Product_Families__r)
                                                        FROM Promotion_Eligibility_Rule__c 
                                                        WHERE Promotion__r.Id IN :promoIdSet];
        }
        //END 2/18/15 Added by MGAELO
        //END:D-1632 1/23/15 Added by Manolo Vale�a 
        //END:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a      
        //END: D-1627 1/22/2015 Added by Kristine Campang
            
        //START: D-1629, D-1628 1/22/2015 Added by Kristine Campang - changed map of promotion to list of promotion eligibility rules
        //START 2/18/15 MGAELO Code Review: check if pErs is null
        if (pErs !=null){
            for(Promotion_Eligibility_Rule__c promEligRule : pErs){

                if(mapPromoEligRule.containsKey(promEligRule.Promotion__c)) {
                    mapPromoEligRule.get(promEligRule.Promotion__c).add(promEligRule);
                }
                else{
                    mapPromoEligRule.put(promEligRule.Promotion__c, new List<Promotion_Eligibility_Rule__c>{promEligRule});         
                }      
            }
        }
        //END 2/18/15 Added by MGAELO 
        //to return all packages under that promotion if no eligibility rule is attached to that 
        for(String promotionCode : mapPromoToPackageCodeSet.KeySet()){  
            if(!mapPromoEligRule.containsKey(promotionCode)){
                    //String pCode = mapPromoCodeToPromoCodeRec.get(promotionCode).Promotion_Code__c;
                    mapPromoToPackageList.put(promotionCode, mapPromoToPackageCodeSet.get(promotionCode));
            }
        }
        System.debug('RESULT MAP:' + mapPromoToPackageList);
        //END: D-1629, D-1628 1/22/2015 Added by Kristine Campang
        //START: D-1629, D-1628, D-1627 1/22/2015 Added by Kristine Campang - added filters for checking eligibility
        for(String pCode : mapPromoEligRule.keySet()) {
            //String promotionCode = mapPromoCodeToPromoCodeRec.get(pCode).Promotion_Code__c;
            if(mapPromoToPackageCodeSet.containsKey(pCode)){
                for(String packCOde : mapPromoToPackageCodeSet.get(pCode)){
                    
                    List<Promotion_Eligibility_Rule__c> promotionEligRules  = new List<Promotion_Eligibility_Rule__c>();
                    List<Zuora__Subscription__c> zSubs = new List<Zuora__Subscription__c>();
                    promotionEligRules = mapPromoEligRule.get(pCode);
                    String subscriberStatus;
                    Boolean isEligible = false;
                    
                    if(promotionEligRules.size()>0){
                        for(Promotion_Eligibility_Rule__c  promElRule : promotionEligRules) {
              //START D-2888 5/27/2015 Added by Manolo Valena - Relocated instantiation of boolSet boolean variable within the loop to fix issue of promotion being ineligible when 2 or more "Change" eligibility rules are existing.
                            boolSet = new Set<Boolean>();
                            //END D-2888 5/27/2015 Added by Manolo Valena
                            if(action == promElRule.Eligibility_Rule__r.Action__c && accCustomerStatus == promElRule.Eligibility_Rule__r.Customer_Status__c) {    
                                /*------------New Customer and Vendor Customer----------*/
                                //START:D-1629 2/5/15 Added by Manolo Valeña - Separated the customer status logic.
                                if(accCustomerStatus == 'New Customer') 
                                {
                                    
                                    if(promElRule.Package_List__c !=null)
                                    {
                                        System.debug(promElRule.Package_List__c);
                                        System.debug(packCOde);
                                        getPackageList(promElRule.Package_List__c, packCOde);
                                        System.debug(getPackageList(promElRule.Package_List__c, packCOde));
                                        if(getPackageList(promElRule.Package_List__c, packCOde))
                                        {
                                            if(mapPromoToPackageList.containsKey(pCode))
                                            {
                                                mapPromoToPackageList.get(pCode).add(packCOde);
                                            }
                                            else
                                            {
                                                mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                            }
                                        }
                                    }   
                                }
                                //END:D-1629 2/5/15 Added by Manolo Valeña
                                //START:D-1629 2/5/15 Added by Manolo Valeña - Added a new condition that checks eligible promotions for Vendor Customer.
                                if(accCustomerStatus == 'Vendor Customer')
                                {
                                    Integer match = 0;
                                    for(Subscription_Vendor__c sv : subVen)
                                    {
                                        if(!sv.Subscription_Vendor_Publications__r.isEmpty())
                                        {
                                            if(sv.Subscription_Vendor_Publications__r[0].Publication__r.Product_Family__c == mapPackageCodeToProductFamily.get(packCOde))
                                            {
                                                match = 1;
                                            }   
                                        }
                                    }
                                    
                                    if(match == 1)
                                    {
                                        if(promElRule.Package_List__c !=null)
                                        {
                                            getPackageList(promElRule.Package_List__c, packCOde);
                                            if(getPackageList(promElRule.Package_List__c, packCOde))
                                            {
                                                if(mapPromoToPackageList.containsKey(pCode))
                                                {
                                                    mapPromoToPackageList.get(pCode).add(packCOde);
                                                }
                                                else
                                                {
                                                    mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                }
                                            }
                                        }
                                    }
                                }
                                //END:D-1629 2/5/15 Added by Manolo Valeña
                                
                                /*---------END New Customer and Vendor Customer-----------*/
                                /*---------START Existing Customer---------------*/
                                if(accCustomerStatus == 'Existing Customer'){
                                    subscriberStatus = getSubscriberStatus(packCOde);
                                    System.debug('SUBSCRIBER STATUS:' + subscriberStatus);
                                    /*------Can ADD for Existing Customer -------*/

                                    if(action == 'Add'){
                                        /*-------------------New Subscriber--------*/
                                        if(subscriberStatus == 'New Subscriber'){
                                            
                                            if(promElRule.Eligibility_Rule__r.Subsciber_Status__c == 'New Subscriber'){
                                                //added for package Eligibility
                                                if(promElRule.Package_List__c !=null){
                                                    if(getPackageList(promElRule.Package_List__c, packCOde)){
                                                        if(mapPromoToPackageList.containsKey(pCode)){
                                                            mapPromoToPackageList.get(pCode).add(packCOde);
                                                        }
                                                        else{
                                                            mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                        }
                                                    }
                                                }
                                            }

                                        }
                                        /*---------Old Subscriber / NA------------*/
                                        if(subscriberStatus == null){
                                            //Product Family Condition
                                            if(promElRule.Product_Family__c !=null){
                                                for(String prodFam : prodFamSet){
                                                    if(checkIfSubsProdFamIsSpecified(promElRule.Product_Family__c, prodFam)){
                                                        if(promElRule.Package_List__c !=null){
                                                            if(getPackageList(promElRule.Package_List__c, packCOde)){
                                                                if(mapPromoToPackageList.containsKey(pCode)){
                                                                    mapPromoToPackageList.get(pCode).add(packCOde);
                                                                }
                                                                else{
                                                                    mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            //No Subscription of Same Product is Active and  Expired before / after
                      //START UD -1301 - Promotion Eligibility Hot Fixing 22-May-2015 Added by Raviteja - Commented existing Zuora__Subscription__c list assignment and implemented logic for most recent subscription.
                                            List<Zuora__Subscription__c> lstsub = New List<Zuora__Subscription__c>();
                                            String prdfamily = mapPackageCodeToProductFamily.get(packCOde);
                                            lstsub = getrecentsubscription(acct.Zuora__Subscriptions__r, prdfamily, promElRule.Eligibility_Rule__r.Contract_Subscription_Rule__c);
                                          
                                            //for(Zuora__Subscription__c zSub : acct.Zuora__Subscriptions__r){
                       for(Zuora__Subscription__c zSub : lstsub){
                                            //End UD -1301 - Promotion Eligibility Hot Fixing 22-May-2015 Added by Raviteja                                
                                                System.debug(zSub);
                                                if(mapZSubToProdFam.get(zSub.Id) == mapPackageCodeToProductFamily.get(packCOde)){
                                                    if(promElRule.Eligibility_Rule__r.Contract_Subscription_Rule__c != null){
                                                        dateParam = getContractSubscriptionRule(zSub,promElRule.Eligibility_Rule__r.Contract_Subscription_Rule__c);
                                                        //with Date 
                                                        if(promElRule.Date__c != null) {
                                                            if(getPromotionEligibility(promElRule.Eligibility_Rule__r.Condition__c, promElRule.Date__c, dateParam, null)){
                                                                //added for package Eiligibility
                                                                if(promElRule.Package_List__c !=null){
                                                                    if(getPackageList(promElRule.Package_List__c, packCOde)){
                                                                        if(mapPromoToPackageList.containsKey(pCode)){
                                                                            mapPromoToPackageList.get(pCode).add(packCOde);
                                                                        }
                                                                        else{
                                                                            mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        //With Days
                                                        if(promElRule.Days__c!=null){
                                                            if(getPromotionEligibility(promElRule.Eligibility_Rule__r.Condition__c, promElRule.Date__c, dateParam, promElRule.Days__c)){
                                                                //added for package Eligibility_Rule__c
                                                                if(promElRule.Package_List__c !=null){
                                                                    System.debug('PACKAGE LIST:' + promElRule.Package_List__c);
                                                                    if(getPackageList(promElRule.Package_List__c, packCOde)){
                                                                        if(mapPromoToPackageList.containsKey(pCode)){
                                                                            mapPromoToPackageList.get(pCode).add(packCOde);
                                                                        }
                                                                        else{
                                                                            mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    /*----------end Can Add for Existing Customer-----------*/
                                    /*-----------CAN CHANGE for Existing Customer-----------*/
                                    if(action == 'Change'){
                                    /*----------Existing Customer Old Subscriber--------------*/
                                        
                                        //START:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a - Added code that checks if the product families specified in the promotion eligibility rule can be found in any of all the active subscriptions of the account.
                                        Boolean equalExist = false;
                                        Boolean stopCheck = false;
                                        for(Promo_Eligibility_Rule_Product_Family__c perpF : promElRule.Promo_Eligibility_Rule_Product_Families__r)
                                        {
                                            for(Zuora__Subscription__c zuoSubscription : acct.Zuora__Subscriptions__r)
                                            {
                                                if(zuoSubscription.Main_Package_1__r.Product_Family_Current_Package__c != null)
                                                {
                                                    if(zuoSubscription.Main_Package_1__r.Product_Family_Current_Package__c.contains(perpF.Product_Family__r.Product_Family__c) && stopCheck == false && zuoSubscription.Zuora__Status__c.Equals(GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE))
                                                    {
                                                        equalExist = true;
                                                        stopCheck = true;
                                                    }
                                                }
                                            }
                                        }
                                        //END:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a
                                        
                                        //START:UD-2977 11/5/15 Added by Manolo Valena
                                        String zSubContractStatus;
                                        Integer countWithContract = 0;
                                        Integer countWithoutContract = 0;
                                        Integer totalBundleSubs = 0;
                                        Set<String> productPlatformSet = new Set<String>();
                                        String bundleEligibleProductPlatform = GlobalVariableClass.EMPTYSTR;
                                        Integer trueCount = 0;
                                        Date dateP;
                                        
                                        //Check for Contract Status of selected subscription that is part of a bundle.
                                        if(zuoSub.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_BUNDLE) {
                                            if(bundleOliToSubsMap.containsKey(zuoSub.Order_Line_Item_Number_1__c)) {
                                                for(Zuora__Subscription__c zdRecL : bundleOliToSubsMap.get(zuoSub.Order_Line_Item_Number_1__c)) {
                                                    if(getContractStatus(zdRecL.Contract_End_Date_1__c) == 'With Contract') {
                                                        countWithContract = countWithContract + 1;
                                                    }
                                                    else if(getContractStatus(zdRecL.Contract_End_Date_1__c) == 'Without contract') {
                                                        countWithoutContract = countWithoutContract + 1;
                                                    }
                                                    totalBundleSubs = totalBundleSubs + 1;
                                                }
                                                if(totalBundleSubs == countWithContract) {
                                                    zSubContractStatus = 'With Contract';
                                                }
                                                else if(totalBundleSubs == countWithoutContract) {
                                                    zSubContractStatus = 'Without contract';
                                                }
                                                else {
                                                    continue;
                                                }
                                            }
                                        }
                                        //Check for Contract Status of selected subscription that is not part of a bundle.
                                        else {
                                            zSubContractStatus = getContractStatus(zuoSub.Contract_End_Date_1__c);
                                        }
                                        
                                        //Check for Current Platform of selected subscription that is part of a bundle.
                                        if(zuoSub.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_BUNDLE &&
                                           promElRule.Current_Platform__c != null) {
                                            if(bundleOliToSubsMap.containsKey(zuoSub.Order_Line_Item_Number_1__c)) {
                                                for(Zuora__Subscription__c zsRecL : bundleOliToSubsMap.get(zuoSub.Order_Line_Item_Number_1__c)) {
                                                    if(subscriptionToProductPlatformMap.containsKey(zsRecL.Id)) {
                                                        productPlatformSet.add(subscriptionToProductPlatformMap.get(zsRecL.Id));
                                                    }
                                                }
                                                
                                                if(productPlatformSet.size() > 0) {
                                                    for(String keyPP : productPlatformSet) {
                                                        String formattedCurrentPlatformR = promElRule.Current_Platform__c + ';';
                                                        if(getCurrentPlatformEligibility(formattedCurrentPlatformR, keyPP)) {
                                                            bundleEligibleProductPlatform = keyPP;
                                                            trueCount = trueCount + 1;
                                                        }
                                                    }
                                                    
                                                    if(trueCount == productPlatformSet.size()) {
                                                        platform = bundleEligibleProductPlatform;
                                                    }
                                                    else {
                                                        continue;
                                                    }
                                                }
                                            }
                                        }
                                        
                                        //Check for Contract Date/Days of selected subscription that is part of a bundle.
                                        Integer trueCountCDate = 0;
                                        Integer trueCountCDays = 0;
                                        
                                        if(zuoSub.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_BUNDLE &&
                                           promElRule.Eligibility_Rule__r.Contract_Status__c == 'With Contract' &&
                                           promElRule.Eligibility_Rule__r.Contract_Subscription_Rule__c != null) {
                                            if(bundleOliToSubsMap.containsKey(zuoSub.Order_Line_Item_Number_1__c)) {
                                                for(Zuora__Subscription__c zsRecC : bundleOliToSubsMap.get(zuoSub.Order_Line_Item_Number_1__c)) {
                                                    dateP = getContractSubscriptionRule(zsRecC, promElRule.Eligibility_Rule__r.Contract_Subscription_Rule__c);
                                                    if(promElRule.Date__c != null) {
                                                        if(getPromotionEligibility(promElRule.Eligibility_Rule__r.Condition__c, promElRule.Date__c, dateP, null)) {
                                                            trueCountCDate = trueCountCDate + 1;
                                                        }
                                                    }
                                                    if(promElRule.Days__c != null) {
                                                        if(getPromotionEligibility(promElRule.Eligibility_Rule__r.Condition__c, promElRule.Date__c, dateP, promElRule.Days__c)) {
                                                            trueCountCDays = trueCountCDays + 1;
                                                        }
                                                    }
                                                }
                                                
                                                if(promElRule.Date__c != null) {
                                                    if(trueCountCDate != totalBundleSubs) {
                                                        continue;
                                                    }
                                                }
                                                if(promElRule.Days__c != null) {
                                                    if(trueCountCDays != totalBundleSubs) {
                                                        continue;
                                                    }
                                                }
                                            }
                                        }
                                        //END:UD-2977 11/5/15 Added by Manolo Valena
                                        
                                        if(promElRule.Eligibility_Rule__r.Subsciber_Status__c == null){
                                            if(zSubContractStatus == promElRule.Eligibility_Rule__r.Contract_Status__c){
                                                /*----------------With Contract-----------*/
                                                if(promElRule.Eligibility_Rule__r.Contract_Status__c == 'With Contract'){ 
                                                    /*-------checks for contract Subscription Rule------*/
                                                    if(promElRule.Eligibility_Rule__r.Contract_Subscription_Rule__c != null){
                                                        dateParam = getContractSubscriptionRule(zuoSub, promElRule.Eligibility_Rule__r.Contract_Subscription_Rule__c);
                                                        //with Date 
                                                        if(promElRule.Date__c != null) {
                                                            if(getPromotionEligibility(promElRule.Eligibility_Rule__r.Condition__c, promElRule.Date__c, dateParam, null)){
                                                                //added for package Eiligibility
                                                                if(promElRule.Package_List__c !=null)
                                                                {
                                                                    //START:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a - Created if else statements to cover the different scenarios for determining what promotions are eligible.
                                                                    if(promElRule.Current_Platform__c != null && promElRule.Promo_Eligibility_Rule_Product_Families__r.isEmpty())
                                                                    {
                                                                        String formattedCurrentPlatform = promElRule.Current_Platform__c + ';';
                                                                        if(getCurrentPlatformEligibility(formattedCurrentPlatform, platform))
                                                                        {
                                                                            boolSet.add(true);
                                                                        }
                                                                        else
                                                                        {
                                                                            boolSet.add(false);
                                                                        }
                                                                        
                                                                        if(getPackageList(promElRule.Package_List__c, packCOde) && boolSet.size() == 1 && boolSet.contains(true))
                                                                        {
                                                                            if(mapPromoToPackageList.containsKey(pCode))
                                                                            {
                                                                                mapPromoToPackageList.get(pCode).add(packCOde);
                                                                            }
                                                                            else
                                                                            {
                                                                                mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                            }
                                                                        }
                                                                    }
                                                                    else if(promElRule.Current_Platform__c == null && !promElRule.Promo_Eligibility_Rule_Product_Families__r.isEmpty())
                                                                    {
                                                                        if(getPackageList(promElRule.Package_List__c, packCOde) && equalExist)
                                                                        {
                                                                            if(mapPromoToPackageList.containsKey(pCode))
                                                                            {
                                                                                mapPromoToPackageList.get(pCode).add(packCOde);
                                                                            }
                                                                            else
                                                                            {
                                                                                mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                            }
                                                                        }
                                                                    }
                                                                    else if(promElRule.Current_Platform__c != null && !promElRule.Promo_Eligibility_Rule_Product_Families__r.isEmpty())
                                                                    {
                                                                        String formattedCurrentPlatform = promElRule.Current_Platform__c + ';';
                                                                        if(getCurrentPlatformEligibility(formattedCurrentPlatform, platform))
                                                                        {
                                                                            boolSet.add(true);
                                                                        }
                                                                        else
                                                                        {
                                                                            boolSet.add(false);
                                                                        }
                                                                        
                                                                        if(getPackageList(promElRule.Package_List__c, packCOde) && boolSet.size() == 1 && boolSet.contains(true) && equalExist)
                                                                        {
                                                                            if(mapPromoToPackageList.containsKey(pCode))
                                                                            {
                                                                                mapPromoToPackageList.get(pCode).add(packCOde);
                                                                            }
                                                                            else
                                                                            {
                                                                                mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                            }
                                                                        }
                                                                    }
                                                                    else
                                                                    {
                                                                        if(getPackageList(promElRule.Package_List__c, packCOde))
                                                                        {
                                                                            if(mapPromoToPackageList.containsKey(pCode))
                                                                            {
                                                                                mapPromoToPackageList.get(pCode).add(packCOde);
                                                                            }
                                                                            else
                                                                            {
                                                                                mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                            }
                                                                        }
                                                                    }
                                                                    //END:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a
                                                                }
                                                            }
                                                        }
                                                        //With Days
                                                        if(promElRule.Days__c!=null){
                                                            if(getPromotionEligibility(promElRule.Eligibility_Rule__r.Condition__c, promElRule.Date__c, dateParam, promElRule.Days__c)){
                                                                //added for package Eligibility_Rule__c
                                                                if(promElRule.Package_List__c !=null)
                                                                {
                                                                    //START:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a - Created if else statements to cover the different scenarios for determining what promotions are eligible.
                                                                    if(promElRule.Current_Platform__c != null && promElRule.Promo_Eligibility_Rule_Product_Families__r.isEmpty())
                                                                    {
                                                                        String formattedCurrentPlatform = promElRule.Current_Platform__c + ';';
                                                                        if(getCurrentPlatformEligibility(formattedCurrentPlatform, platform))
                                                                        {
                                                                            boolSet.add(true);
                                                                        }
                                                                        else
                                                                        {
                                                                            boolSet.add(false);
                                                                        }
                                                                        
                                                                        if(getPackageList(promElRule.Package_List__c, packCOde) && boolSet.size() == 1 && boolSet.contains(true))
                                                                        {
                                                                            if(mapPromoToPackageList.containsKey(pCode))
                                                                            {
                                                                                mapPromoToPackageList.get(pCode).add(packCOde);
                                                                            }
                                                                            else
                                                                            {
                                                                                mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                            }
                                                                        }
                                                                    }
                                                                    else if(promElRule.Current_Platform__c == null && !promElRule.Promo_Eligibility_Rule_Product_Families__r.isEmpty())
                                                                    {
                                                                        if(getPackageList(promElRule.Package_List__c, packCOde) && equalExist)
                                                                        {
                                                                            if(mapPromoToPackageList.containsKey(pCode))
                                                                            {
                                                                                mapPromoToPackageList.get(pCode).add(packCOde);
                                                                            }
                                                                            else
                                                                            {
                                                                                mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                            }
                                                                        }
                                                                    }
                                                                    else if(promElRule.Current_Platform__c != null && !promElRule.Promo_Eligibility_Rule_Product_Families__r.isEmpty())
                                                                    {
                                                                        String formattedCurrentPlatform = promElRule.Current_Platform__c + ';';
                                                                        if(getCurrentPlatformEligibility(formattedCurrentPlatform, platform))
                                                                        {
                                                                            boolSet.add(true);
                                                                        }
                                                                        else
                                                                        {
                                                                            boolSet.add(false);
                                                                        }
                                                                        
                                                                        if(getPackageList(promElRule.Package_List__c, packCOde) && boolSet.size() == 1 && boolSet.contains(true) && equalExist)
                                                                        {
                                                                            if(mapPromoToPackageList.containsKey(pCode))
                                                                            {
                                                                                mapPromoToPackageList.get(pCode).add(packCOde);
                                                                            }
                                                                            else
                                                                            {
                                                                                mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                            }
                                                                        }
                                                                    }
                                                                    else
                                                                    {
                                                                        if(getPackageList(promElRule.Package_List__c, packCOde))
                                                                        {
                                                                            if(mapPromoToPackageList.containsKey(pCode))
                                                                            {
                                                                                mapPromoToPackageList.get(pCode).add(packCOde);
                                                                            }
                                                                            else
                                                                            {
                                                                                mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                            }
                                                                        }
                                                                    }
                                                                    //END:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                /*-------End With Contract------------*/
                                                /*---------------- START Without Contract-----------*/
                                                if(promElRule.Eligibility_Rule__r.Contract_Status__c == 'Without Contract'){
                                                    if(promElRule.Package_List__c !=null){
                            //START UD -1301 - Promotion Eligibility Hot Fixing 20-May-2015 Added by Raviteja - Commented existing mapPromoToPackageList assignment and implemted the logic for without contract
                            /*
                                                        if(getPackageList(promElRule.Package_List__c, packCOde)){
                                                            if(mapPromoToPackageList.containsKey(pCode)){
                                                                mapPromoToPackageList.get(pCode).add(packCOde);
                                                            }
                                                            else{
                                                                mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                            }
                                                        }
                            */
                            //START:PROMOELIG 5/20/15 Added by Manolo Valena
                                                        if(promElRule.Current_Platform__c != null && promElRule.Promo_Eligibility_Rule_Product_Families__r.isEmpty())
                                                        {
                                                            String formattedCurrentPlatform = promElRule.Current_Platform__c + ';';
                                                            if(getCurrentPlatformEligibility(formattedCurrentPlatform, platform))
                                                            {
                                                                boolSet.add(true);
                                                            }
                                                            else
                                                            {
                                                                boolSet.add(false);
                                                            }
                                                            
                                                            if(getPackageList(promElRule.Package_List__c, packCOde) && boolSet.size() == 1 && boolSet.contains(true))
                                                            {
                                                                if(mapPromoToPackageList.containsKey(pCode))
                                                                {
                                                                    mapPromoToPackageList.get(pCode).add(packCOde);
                                                                }
                                                                else
                                                                {
                                                                    mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                }
                                                            }
                                                        }
                                                        else if(promElRule.Current_Platform__c == null && !promElRule.Promo_Eligibility_Rule_Product_Families__r.isEmpty())
                                                        {
                                                            if(getPackageList(promElRule.Package_List__c, packCOde) && equalExist)
                                                            {
                                                                if(mapPromoToPackageList.containsKey(pCode))
                                                                {
                                                                    mapPromoToPackageList.get(pCode).add(packCOde);
                                                                }
                                                                else
                                                                {
                                                                    mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                }
                                                            }
                                                        }
                                                        else if(promElRule.Current_Platform__c != null && !promElRule.Promo_Eligibility_Rule_Product_Families__r.isEmpty())
                                                        {
                                                            String formattedCurrentPlatform = promElRule.Current_Platform__c + ';';
                                                            if(getCurrentPlatformEligibility(formattedCurrentPlatform, platform))
                                                            {
                                                                boolSet.add(true);
                                                            }
                                                            else
                                                            {
                                                                boolSet.add(false);
                                                            }
                                                            
                                                            if(getPackageList(promElRule.Package_List__c, packCOde) && boolSet.size() == 1 && boolSet.contains(true) && equalExist)
                                                            {
                                                                if(mapPromoToPackageList.containsKey(pCode))
                                                                {
                                                                    mapPromoToPackageList.get(pCode).add(packCOde);
                                                                }
                                                                else
                                                                {
                                                                    mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                }
                                                            }
                                                        }
                                                        else
                                                        {
                                                            if(getPackageList(promElRule.Package_List__c, packCOde))
                                                            {
                                                                if(mapPromoToPackageList.containsKey(pCode))
                                                                {
                                                                    mapPromoToPackageList.get(pCode).add(packCOde);
                                                                }
                                                                else
                                                                {
                                                                    mapPromoToPackageList.put(pCode, new Set<String>{packCOde});
                                                                }
                                                            }
                                                        }
                                                        //END:PROMOELIG 5/20/15 Added by Manolo Valena
                                                        //End UD -1301 - Promotion Eligibility Hot Fixing 20-May-2015 Added by Raviteja 
                                                   
                                                    }
                                                }
                                                /*------END without Contract-----------*/
                                            }
                                        }   
                                    }
                                    /*-----End Can Change for Existing Customer----------*/ 
                                /*-----------------End Existing Customer---------------*/  
                                }
                                //END: D-1629, D-1628, D-1627 1/22/2015 Added by Kristine Campang
                            }
                        }
                    }
                }
            }
        }
        return mapPromoToPackageList;
    }

    public Boolean getPackageList(String packageList, String packageCode){
        String pckListSemiColon;
        String formatPckCode = packageCode + ';';
        Boolean isPackageEligible = false;
        pckListSemiColon = packageList + ';';
        System.debug(pckListSemiColon);
        System.debug(formatPckCode);
        
        if(pckListSemiColon.contains(formatPckCode)){
            isPackageEligible = true;
        }
        
        return isPackageEligible;
    }
    
    public Boolean getCurrentPlatformEligibility(String curPlatform, String subPlatform){
        Boolean isPlatformEligible = false;
        String formatSubPlatform = subPlatform + ';';
        
        if(curPlatform.contains(formatSubPlatform)){
            isPlatformEligible = true;
        }
        
        return isPlatformEligible;
    }
    
    public String getSubscriberStatus(String packageCode){
        String subsStatus;
        if(mapPackageCodeToProductFamily.containsKey(packageCode)){
            if(!prodFamSet.contains(mapPackageCodeToProductFamily.get(packageCode))){
                subsStatus = 'New Subscriber';
            }
            if(prodFamSet.contains(mapPackageCodeToProductFamily.get(packageCode))){
                subsStatus = null;
            }
        }
        return subsStatus;
        
    }
    
    public Boolean checkIfSubsProdFamIsSpecified(String specifiedProdFam, String prodFamily){
        Boolean isSpecified = false;
        String formattedSpecifiedProdFam = specifiedProdFam + ';';
        String formattedProdFamily = prodFamily + ';';
        
        if(formattedSpecifiedProdFam.contains(formattedProdFamily)){
                isSpecified = true;
        }
        
        return isSpecified;
    }
    
    public Date getContractSubscriptionRule(Zuora__Subscription__c zuoraSub, String contractSubsRule){
        Date dateResult;
        
        if(contractSubsRule == 'Subscription End Date'){
            dateResult = zuoraSub.Zuora__SubscriptionEndDate__c;
        }
        if(contractSubsRule == 'Contract End Date'){
            dateResult = zuoraSub.Contract_End_Date_1__c;
        }
        //START UD-2284 08/28/15 RReyes - sets value for dateResult if null to prevent exception
        if(dateResult == null){
            dateResult = Date.newInstance(2049,12,31);
        }
        //END UD-2284 08/28/15 RReyes - sets value for dateResult if null to prevent exception
        
        return dateResult;
    }
  //START UD -1301 - Promotion Eligibility Hot Fixing 22-May-2015 Added by Raviteja - Implemented logic for most recent subscription based on Subscription enddate and platform
    public List<Zuora__Subscription__c> getrecentsubscription(List<Zuora__Subscription__c> zuoraSub, String strProductFamily,String contractRule){    
        String contractSubsRule = contractRule;//Eligibility_Rule__r.Contract_Subscription_Rule__c
        String Productfamily = strProductFamily;
        List<Id> lstsubids = New List<Id>();  
        List<Zuora__Subscription__c> lstsubs =  New List<Zuora__Subscription__c>();     
        for(Zuora__Subscription__c sub: zuoraSub){
            if(sub.Main_Package_1__r.Product_Family_Current_Package__c == Productfamily ){
                lstsubids.add(sub.id);
                }
         }           
        
        if(contractSubsRule == 'Subscription End Date'){
            lstsubs = [select Id,Name, Contract_End_Date_1__c, Zuora__SubscriptionEndDate__c,Main_Package_1__c, Main_Package_1__r.Product_Family_Current_Package__c from Zuora__Subscription__c where Id In :zuoraSub ORDER BY Zuora__SubscriptionEndDate__c DESC NULLS LAST limit 1];
        }
        if(contractSubsRule == 'Contract End Date'){
            lstsubs = [select Id,Name, Contract_End_Date_1__c, Zuora__SubscriptionEndDate__c,Main_Package_1__c, Main_Package_1__r.Product_Family_Current_Package__c from Zuora__Subscription__c where Id In :zuoraSub ORDER BY Contract_End_Date_1__c DESC NULLS LAST limit 1];
        }    
        
         return  lstsubs;
    }
    //End UD -1301 - Promotion Eligibility Hot Fixing 22-May-2015 Added by Raviteja
 
    //START: D-1629 1/22/2014 Added by Kristine Campang - changed operations for days scenarios according to timeline showed
    public Boolean getPromotionEligibility(String condition, Date datebase, Date sDate, String days){
        Boolean isPromotionEligible = false;
        
        if(days == null){
            if(condition == '<'){
                isPromotionEligible = sDate < datebase;
            }
            if(condition == '>'){
                isPromotionEligible = sDate > datebase;
            }
            if(condition == '<='){
                isPromotionEligible = sDate <= datebase;
            }
            if(condition == '>='){
                isPromotionEligible = sDate >= datebase;
            }
        }
        else{
            if(condition == '<'){
        //START UD -1301 - Promotion Eligibility Hot Fixing 22-May-2015 Added by Raviteja - Updated the logic 
                isPromotionEligible = sDate < (date.today() - Integer.valueOf(days));
         Integer daysBetween = (sDate.daysBetween(date.today()));
               System.debug('daysBetween  : '+daysBetween );
               isPromotionEligible = daysBetween < Integer.valueOf(days);              
              //End UD -1301 - Promotion Eligibility Hot Fixing 22-May-2015 Added by Raviteja           
            }
            if(condition == '>'){
                //START:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a - Updated the logic to meet the correct functionality.
        //START UD -1301 - Promotion Eligibility Hot Fixing 22-May-2015 Added by Raviteja - Updated the logic 
                isPromotionEligible = (date.today() < sDate) && (sDate < (date.today().addDays(Integer.valueof(days))));
        Integer daysBetween = (sDate.daysBetween(date.today()));                                
                 if(date.today() > sDate){                    
                    isPromotionEligible = daysBetween > Integer.valueOf(days);
                }
                System.debug('isPromotionEligible for >   : '+isPromotionEligible );
                //End UD -1301 - Promotion Eligibility Hot Fixing 22-May-2015 Added by Raviteja 
                //END:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a
            }
            if(condition == '<='){
                isPromotionEligible = sDate <= (date.today() - Integer.valueOf(days));
            }
            if(condition == '>='){
                //START:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a - Updated the logic to meet the correct functionality.
        //START UD -1301 - Promotion Eligibility Hot Fixing 22-May-2015 Added by Raviteja - Updated the logic 
                //isPromotionEligible = (date.today() <= sDate) && (sDate <= (date.today().addDays(Integer.valueof(days))));
        Integer daysBetween = (sDate.daysBetween(date.today()));                                
                 if(date.today() > sDate){                    
                    isPromotionEligible = daysBetween >= Integer.valueOf(days);
                    }
                System.debug('isPromotionEligible for >   : '+isPromotionEligible );
                //End UD -1301 - Promotion Eligibility Hot Fixing 22-May-2015 Added by Raviteja 
               
                //END:D-1835 and D-1834 1/29/15 Added by Manolo Vale�a
            }
        }
        
        return isPromotionEligible;
    }
     //END: D-1629 1/22/2014 Added by Kristine Campang
    //START: D- 1628 1/22/2014 Added by Kristine Campang - added contract considerations
    public String getContractStatus (Date zSubContractEndDate){
        String contractStatus;
        
        if(zSubContractEndDate >= date.today()){
            contractStatus = 'With contract';
        }
        else if(zSubContractEndDate < date.today()){
            contractStatus = 'Without Contract';
        }
        else if(zSubContractEndDate == null){
            contractStatus = 'Without Contract';
        }
        
        return contractStatus;
    }
    //END: D- 1628 1/22/2014 Added by Kristine Campang
}