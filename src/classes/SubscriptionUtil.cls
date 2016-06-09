public class SubscriptionUtil{

    public Zuora__Subscription__c zuoSubscrpt;
    public Set<Id> subsIdSet;
    public String contractDate;
    public List<Zuora__SubscriptionProductCharge__c> zuoSubProdCharg;
    public List<zqu__ProductRatePlan__c> zquProdRatePlan;

    public Map<Id, String> mapZuoProdCharge_ProdCode;
    public Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapZuoSubs_ZuoSubProdCharge;
    public Map<Id, Set<String>> mapProdRatePlanChargeId_toPublicationCode;
    public Map<Id, Set<String>>  mapSubsId_toRatePlan;
    public Set<String> setRatePlan;
    public Set<String> publiCode;
    public String result;

    //variables for Product Rate Plan
    public Set<Id> ratePlanIds;
    public List<zqu__ProductRatePlan__c> productRatePlanList;
    public Map<String, zqu__ProductRatePlan__c> mapProdRatePlanName_toProductRatePlanRec;

    //variables for Product Rate Plan and Charges
    public List<zqu__ProductRatePlanCharge__c> prodRatePlanChargesList;
    public Map<String, List<zqu__ProductRatePlanCharge__c>> mapProdRatePlan_toProdRatePlanCharge;

    //variables for Publication
    public List<Publication__c> pubList;
    public Map<String, Publication__c> mapPublicCode_toPublicRec;
    public Map<Id, List<Publication__c>> mapSubsId_toPublicRec;
    public Map<Id, List<Publication__c>> mapSubsId_toPubList;
    public Set<String> pubCodeSetperPRC;

    //variables for Temp Stop
    public Temp_Stop__c TempStopRec;
    //START D-4080 Gdelrosario 11/12/2015 : added instantiation as part of review
    public List<Subscription_Temp_Stop__c> SubTempStopList = new List<Subscription_Temp_Stop__c>();
    public Set<Id> TempStopSet = new Set<Id>();
    //END D-4080 Gdelrosario 11/12/2015 : added instantiation as part of review

    //Computation Variables
    public Decimal paymentPerMonth;
    public Date startDate;
    public Date endDate;
    public Decimal remMonthsRefund; 
    public Integer remDays;
    public Integer monthDiff;
    public Integer stopDiff;
    public Date lastDay;
    public Date startMo;
    public Decimal proratedAmt;
    //START D-4080 Gdelrosario 11/12/2015 : added instantiation as part of review
    public List<Publication_Price__c> coverPriceList = new List<Publication_Price__c>();
    //END D-4080 Gdelrosario 11/12/2015 : added instantiation as part of review
    public String dayOfWeek;
    public Boolean isRefundable;
    public Boolean Refundable;
    public Integer numberOfDays;
    public Date lastDayOfMonth;
    public Decimal prorationAmountForRemainingDaysBef;
    public Decimal prorationAmountForRemainingDaysAft;
    public Map<String, Decimal> dayToCoverPriceMap;
    public Map<String, Map<String, Decimal>> pubToMapDayCoverPriceMap;
    public Date startOfTheMonth;
    public Decimal totalProration;
    public List<Non_Publication_Day__c> nonPubDates;
    //START D-4080 Gdelrosario 11/12/2015 : added instantiation as part of review
    public Set<Date> nonPubDatesWithinSet = new Set<Date>();
    //END D-4080 Gdelrosario 11/12/2015 : added instantiation as part of review
    public String subfreq;
    public Decimal covPrice;
    //varibles for Usage
    //START D-4080 Gdelrosario 11/12/2015 : added instantiation as part of review
    public Map<String, object> usageMap = new Map<String, object>();
    public List<Map<String, object>> listMap = new List<Map<String, Object>>();
    public List<Usage__c> usageToZuora = new List<Usage__c>();
    //END D-4080 Gdelrosario 11/12/2015 : added instantiation as part of review
    
    //START UD-1168 6/15/2015 Added By C. Lin - Allow multiple subscriptions in a Rate Plan
    Map<String, Set<Id>> ratePlanNameToSubIdSetMap;
    //END UD-1168 6/15/2015 Added By C. Lin
    
    public static Map<String, List<Non_Publication_Day__c>> subIdNonPubListMap;
    
    public void getSubToPub(Id subscriptionId){
    
        //Computation Variables Instantiation
        result = 'RESULT';
        nonPubDates = new List<Non_Publication_Day__c>();
        prorationAmountForRemainingDaysBef = 0.00;
        prorationAmountForRemainingDaysAft = 0.00;
        totalProration = 0.00;
        monthDiff = 0;
        remMonthsRefund = 0.00;
        paymentPerMonth = 0.00;
        proratedAmt = 0.00;
        
        

        //instantiates variables
        zuoSubProdCharg = new List<Zuora__SubscriptionProductCharge__c>();
        zquProdRatePlan = new List<zqu__ProductRatePlan__c>();
        mapZuoProdCharge_ProdCode = new Map<Id, String>();
        mapZuoSubs_ZuoSubProdCharge = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
        mapProdRatePlanChargeId_toPublicationCode = new Map<Id, Set<String>>();
        mapSubsId_toRatePlan = new Map<Id, Set<String>>();
        dayToCoverPriceMap = new Map<String, Decimal>() ;
        pubToMapDayCoverPriceMap = new Map<String, Map<String, Decimal>>();
        setRatePlan = new Set<String>();
        publiCode = new Set<String>();
        subsIdSet = new Set<Id>();
        //instantiates Product Rate Plan Variables
        ratePlanIds = new Set<Id>();
        productRatePlanList = new List<zqu__ProductRatePlan__c>();
        mapProdRatePlanName_toProductRatePlanRec = new Map<String, zqu__ProductRatePlan__c>();

        //instantiates Product Rate Plan Charges Variables
        prodRatePlanChargesList = new List<zqu__ProductRatePlanCharge__c>();
        mapProdRatePlan_toProdRatePlanCharge = new Map<String, List<zqu__ProductRatePlanCharge__c>>();
        pubCodeSetperPRC = new Set<String>();

        //instantiates Publication variables
        pubList = new List<Publication__c>();
        mapPublicCode_toPublicRec = new Map<String, Publication__c>();
        mapSubsId_toPublicRec = new Map<Id, List<Publication__c>>();
        mapSubsId_toPubList = new Map<Id, List<Publication__c>>();

        //Zuora Subscription Stop
        zuoSubscrpt = [SELECT Id,    Billing_Type__c, Contract_End_Date_1__c, Credit_Balance__c, Frequency_1__c, 
                        Number_of_Copies__c, Product_Code__c, Promotion__c, Promotion_Contract_Period_1__c, 
                        Zuora__SubscriptionEndDate__c, Zuora__SubscriptionStartDate__c, Zuora__TermEndDate__c, 
                        Term_Length__c, Zuora__TermStartDate__c
                        FROM Zuora__Subscription__c
                        WHERE Id = :subscriptionId];
        //list of Subscription Product and Charges under Subscription                           
        zuoSubProdCharg = [SELECT Id, Zuora__RatePlanName__c, Zuora__ProductName__c, Product_Code__c, Zuora__ProductSKU__c, Zuora__Price__c, Zuora__BillingPeriod__c, Zuora__Subscription__c
                            FROM Zuora__SubscriptionProductCharge__c
                            WHERE Zuora__Subscription__c =:subscriptionId];

        mapZuoSubs_ZuoSubProdCharge.put(subscriptionId, zuoSubProdCharg);//map of Zuora Subscription Id to List of Subscription Product and Charges


        //assumption: There is only one Rate Plan under that Subcription
        for(Zuora__SubscriptionProductCharge__c zSPC : zuoSubProdCharg){
                setRatePlan.add(zSPC.Zuora__RatePlanName__c);
                if(setRatePlan.size()>0){
                    mapSubsId_toRatePlan.put(zSPC.Zuora__Subscription__c,setRatePlan);
                }
        }
        
        System.debug('SEEEEEEEEEEET Product Rate Plan:' + setRatePlan);
        System.debug('MAP Subscription Product Charge Id to Rate Plan Names:' + mapSubsId_toRatePlan);
        //List all Product Rate Plan under Subscription Product and Charges
        if(setRatePlan.size()>0){
            productRatePlanList = [SELECT Id, Name, BillingType__c, Product_Code__c, RatePlanCode__c, RatePlanType__c, SubscriptionFrequency__c
                                    FROM zqu__ProductRatePlan__c
                                    WHERE Name IN :setRatePlan]; 
        }
        
        for(zqu__ProductRatePlan__c prodRatePlanRec : productRatePlanList){
                ratePlanIds.add(prodRatePlanRec.Id);
                mapProdRatePlanName_toProductRatePlanRec.put(prodRatePlanRec.Name, prodRatePlanRec);
        }
    
        System.debug('RATE Plan IDs:' + ratePlanIds);
        System.debug('MAP of Product Rate Plan Name to Product Rate Plan Record:' + mapProdRatePlanName_toProductRatePlanRec);
        //List all Product Rate Plan Charges under Product Rate Plan
        if(setRatePlan.size()>0){
                prodRatePlanChargesList = [SELECT Id, zqu__Type__c, zqu__RecurringPeriod__c, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.Name,  Product_Code__c,                            PublicationCode__c
                                            FROM zqu__ProductRatePlanCharge__c
                                            WHERE zqu__ProductRatePlan__r.Name IN : setRatePlan];
        }                          
        System.debug('LIST Product Rate Plan Charges:' + prodRatePlanChargesList);
        
        for(zqu__ProductRatePlanCharge__c prodRatePlanChargeRec : prodRatePlanChargesList){
                publiCode.add(prodRatePlanChargeRec.PublicationCode__c);
                mapProdRatePlan_toProdRatePlanCharge.put(prodRatePlanChargeRec.zqu__ProductRatePlan__r.Name, prodRatePlanChargesList);
                if(mapProdRatePlanChargeId_toPublicationCode.containsKey(prodRatePlanChargeRec.Id)){
                    mapProdRatePlanChargeId_toPublicationCode.get(prodRatePlanChargeRec.Id).add(prodRatePlanChargeRec.PublicationCode__c);
                }
                else{
                    mapProdRatePlanChargeId_toPublicationCode.put(prodRatePlanChargeRec.Id, new Set<String>{prodRatePlanChargeRec.PublicationCode__c});                 
                }
        }
        
        System.debug('SET of Publication Code:' +  publiCode);
        System.debug('MAP of Product Rate Plan to Product Rate Plan Charges List:' +  mapProdRatePlan_toProdRatePlanCharge);
        System.debug('MAP of Product Rate Plan Charges Id to Publication Codes:' +  mapProdRatePlanChargeId_toPublicationCode);
        
        //List all Publications under the Product Rate Plan Charges
        if(publiCode.size()>0){
                pubList = [SELECT Id, Name, Publication_Code__c, Publish_Pattern__c, Published_Days__c, Publication_Type__c, Earliest_Start_Date__c
                            FROM Publication__c
                            WHERE Publication_Code__c IN :publiCode];
                mapSubsId_toPubList.put(subscriptionId, pubList);           
                //gets all Non Pub Dates Related to the Subscription
                nonPubDates = [SELECT Id, Non_Publication_Date__c, Publication__c, Publication_Code__c, 
                            Publication__r.Published_Days__c, Publication__r.Publication_Type__c
                            FROM Non_Publication_Day__c
                            WHERE Publication_Code__c IN :publiCode];
        }
        
        for(Publication__c publicRec : pubList){
                mapPublicCode_toPublicRec.put(publicRec.Publication_Code__c, publicRec);
                if(mapSubsId_toPublicRec.containsKey(subscriptionId)){
                    mapSubsId_toPublicRec.get(subscriptionId).add(publicRec);
                    
                }
                else{
                    mapSubsId_toPublicRec.put(subscriptionId, new List<Publication__c> {publicRec});
                }
                
        }                          
    }
    
    public Map<Id, List<Publication__c>> subIdToPubListMap(Set<Id> subIdSet) {
        List<Zuora__SubscriptionProductCharge__c> subProChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        List<Publication__c> pubList = new List<Publication__c>();
        Map<Id, List<Zuora__SubscriptionProductCharge__c>> subIdToSpcListMap = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
        Map<Id, String> subIdToRatePlanNameMap = new Map<Id, String>();
        Map<String, Id> ratePlanNameToSubIdMap = new Map<String, Id>();
        //START UD-1168 6/15/2015 Added By C. Lin - Allow multiple subscriptions in a Rate Plan
        ratePlanNameToSubIdSetMap = new Map<String, Set<Id>>();
        //END UD-1168 6/15/2015 Added By C. Lin
        Map<String, Set<String>> ratePlanNameToPubCodeList = new Map<String, Set<String>>();
        Map<Id, Set<String>> subIdToPubCodeSetMap = new Map<Id, Set<String>>();
        Map<Id, List<Publication__c>> subIdToPubList = new Map<Id, List<Publication__c>>();
        Map<String, Publication__c> pubCodeToPubMap = new Map<String, Publication__c>();
        Set<String> pubCodeSet = new Set<String>();       
        
        if (!subIdSet.isEmpty()) {
            subProChargeList = [SELECT Id, Zuora__RatePlanName__c, Zuora__Subscription__c, Zuora__ProductSKU__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN :subIdSet];
        }
        
        for (Zuora__SubscriptionProductCharge__c subProdCharge :subProChargeList) {
            if (!subIdToRatePlanNameMap.containsKey(subProdCharge.Zuora__Subscription__c)) {
                subIdToRatePlanNameMap.put(subProdCharge.Zuora__Subscription__c, subProdCharge.Zuora__RatePlanName__c);
            }
            //START UD-1168 6/15/2015 Added By C. Lin - Allow multiple subscriptions in a Rate Plan
            /*if (!ratePlanNameToSubIdMap.containsKey(subProdCharge.Zuora__RatePlanName__c)) {
                ratePlanNameToSubIdMap.put(subProdCharge.Zuora__RatePlanName__c, subProdCharge.Zuora__Subscription__c);
            }*/
            
            if (ratePlanNameToSubIdSetMap.containsKey(subProdCharge.Zuora__RatePlanName__c)) {
                ratePlanNameToSubIdSetMap.get(subProdCharge.Zuora__RatePlanName__c).add(subProdCharge.Zuora__Subscription__c);
            }else{
                ratePlanNameToSubIdSetMap.put(subProdCharge.Zuora__RatePlanName__c, new Set<Id>{subProdCharge.Zuora__Subscription__c});
            }
            //END UD-1168 6/15/2015 Added By C. Lin
            if (subIdToSpcListMap.containsKey(subProdCharge.Zuora__Subscription__c)) {
                subIdToSpcListMap.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge);
            }
            else {
                subIdToSpcListMap.put(subProdCharge.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c>{subProdCharge});
            }
        }
        if (!subIdToRatePlanNameMap.values().isEmpty()) {
            prodRatePlanChargeList = [SELECT Id, Name, PublicationCode__c, zqu__ProductRatePlan__r.Name, zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__r.Name = :subIdToRatePlanNameMap.values()];
        }
        for (zqu__ProductRatePlanCharge__c prodRatePlanCharge :prodRatePlanChargeList) {
            //START UD-1168 6/15/2015 Added By C. Lin - Allow multiple subscriptions in a Rate Plan
            if(ratePlanNameToSubIdSetMap.containsKey(prodRatePlanCharge.zqu__ProductRatePlan__r.Name)){
                for(Id sId : ratePlanNameToSubIdSetMap.get(prodRatePlanCharge.zqu__ProductRatePlan__r.Name)){
                    if (subIdToPubCodeSetMap.containsKey(sId)) {
                        subIdToPubCodeSetMap.get(sId).add(prodRatePlanCharge.PublicationCode__c);
                    }
                    else {
                        subIdToPubCodeSetMap.put(sId, new Set<String>());                
                        subIdToPubCodeSetMap.get(sId).add(prodRatePlanCharge.PublicationCode__c);
                    }
                }
            }
            
            /*if (subIdToPubCodeSetMap.containsKey(ratePlanNameToSubIdMap.get(prodRatePlanCharge.zqu__ProductRatePlan__r.Name))) {
            //if (!ratePlanNameToSubIdMap.containsKey(prodRatePlanCharge.zqu__ProductRatePlan__r.Name)) {
                subIdToPubCodeSetMap.get(ratePlanNameToSubIdMap.get(prodRatePlanCharge.zqu__ProductRatePlan__r.Name)).add(prodRatePlanCharge.PublicationCode__c);
            }
            else {
                subIdToPubCodeSetMap.put(ratePlanNameToSubIdMap.get(prodRatePlanCharge.zqu__ProductRatePlan__r.Name), new Set<String>());                
                subIdToPubCodeSetMap.get(ratePlanNameToSubIdMap.get(prodRatePlanCharge.zqu__ProductRatePlan__r.Name)).add(prodRatePlanCharge.PublicationCode__c);
            }*/
            //END UD-1168 6/15/2015 Added By C. Lin
            pubCodeSet.add(prodRatePlanCharge.PublicationCode__c);
        }
        if (!pubCodeSet.isEmpty()) {
            pubList = [SELECT Id, Name, Publication_Code__c, Publish_Pattern__c, Published_Days__c, Publication_Type__c, Earliest_Start_Date__c FROM Publication__c WHERE Publication_Code__c IN :pubCodeSet];
        }
        for (Publication__c pub :pubList) {
            pubCodeToPubMap.put(pub.Publication_Code__c, pub);
        }
        
        for(String sub : subIdSet) {
            if(subIdToPubCodeSetMap.containsKey(sub)) {
                for (String pubCode :subIdToPubCodeSetMap.get(sub)) {
                    if (pubCodeToPubMap.containsKey(pubCode)) {
                        if (subIdToPubList.containsKey(sub)) {
                            subIdToPubList.get(sub).add(pubCodeToPubMap.get(pubCode));
                        }
                        else {
                            subIdToPubList.put(sub, new List<Publication__c>());
                            subIdToPubList.get(sub).add(pubCodeToPubMap.get(pubCode));
                        }
                    }
                }
            }
        }
        system.debug('===========subIdToPubList' + subIdToPubList);
        
        getNonPubDays(subIdToPubCodeSetMap, subIdSet, pubCodeSet);
        
        return subIdToPubList;
    }
    
    public void getNonPubDays(Map<id, Set<String>> subIdPubCodeMap, Set<id> subIdSet, Set<String> pubCodeSet){
        subIdNonPubListMap = new Map<String, List<Non_Publication_Day__c>>();
        Map<String, Non_Publication_Day__c> subIdNonPubMap = new Map<String, Non_Publication_Day__c>();  
        List<Non_Publication_Day__c> nonPubDayList = [SELECT Id, Publication__c, Publication_Code__c, Non_Publication_Date__c FROM Non_Publication_Day__c WHERE Publication_Code__c IN : pubCodeSet];
    
        for(Non_Publication_Day__c nonPub : nonPubDayList){
            subIdNonPubMap.put(nonPub.Publication_Code__c, nonPub);
        }
    
        for(String sub : subIdSet) {
            if(subIdPubCodeMap.containsKey(sub)) {
                for (String pubCode : subIdPubCodeMap.get(sub)) {
                    if (subIdNonPubMap.containsKey(pubCode)) {
                        if (subIdNonPubListMap.containsKey(sub)) {
                            subIdNonPubListMap.get(sub).add(subIdNonPubMap.get(pubCode));
                        } else {
                            subIdNonPubListMap.put(sub, new List<Non_Publication_Day__c> {subIdNonPubMap.get(pubCode)});
                        }
                    }
                }
            }
        }
    }
}