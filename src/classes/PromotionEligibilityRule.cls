public class PromotionEligibilityRule {

    public static Map<String, Boolean> getEligibility(Id accId, String action, Set<String> promoCodes, String pkgCode, Id subsId) {
        // Query subscriptions related to account
        //system.asserteQUALS(NULL, promoCodes);
        Map<String, Boolean> returnVar = new Map<String, Boolean>();
        Account acct = [SELECT id, RecordType.Name, (SELECT id, Order_Number__c, Promotion_1__r.Promotion_Code__c, Zuora__SubscriptionEndDate__c, Contract_End_Date_1__c  FROM Zuora__Subscriptions__r) FROM Account WHERE id =: accId];   
        String accCustomerStatus;
        
        // Verify if Vendor account or account has existing subscriptions or none 
        if(acct.RecordType.Name == 'Vendor' || acct.RecordType.Name == 'Vendor Subscriber') {
            accCustomerStatus = 'Vendor Customer';
        }
        else {
            if(acct.Zuora__Subscriptions__r.size() == 0) {
                accCustomerStatus = 'New Customer';
            
            }
            else {
                accCustomerStatus = 'Existing Customer';
                 
            }
        }
        
        Map<String, List<Zuora__Subscription__c>> mapPromocodeSubscription = new Map<String, List<Zuora__Subscription__c>>();       
        for(Zuora__Subscription__c zSub : acct.Zuora__Subscriptions__r) {
            if(mapPromocodeSubscription.containsKey(zSub.Promotion_1__r.Promotion_Code__c)) {     
                mapPromocodeSubscription.get(zSub.Promotion_1__r.Promotion_Code__c).add(zSub);      
            }
            else{
                mapPromocodeSubscription.put(zSub.Promotion_1__r.Promotion_Code__c, new List<Zuora__Subscription__c>{zSub});
                          
            }
        }       
           
        //Create Set of Eligibility Rules from Promotion Eligibility Rule              
        Set<Id> eligibilityRuleIds = new Set<Id>();
        List<Promotion_Eligibility_Rule__c> pErs = [SELECT Id, Promotion__r.Promotion_Code__c, Eligibility_Rule__c FROM Promotion_Eligibility_Rule__c WHERE Promotion__r.Promotion_Code__c IN : promoCodes];
        for(Promotion_Eligibility_Rule__c pEr : pErs ) {
                eligibilityRuleIds.add(pEr.Eligibility_Rule__c);               
        }       
        
        // Map Promocode to List of Eligibility Rule
        Map<String, List<Eligibility_Rule__c>> mapPromoCodeEligRule = new Map<String, List<Eligibility_Rule__c>>();
        Map<Id, Eligibility_Rule__c> eRuleMap = new Map<Id, Eligibility_Rule__c>([SELECT Id, Contract_Subscription_Rule__c, Action__c, Current_Platform__c, Condition__c, Eligibility_Rule__c, Contract_Type__c, Subsciber_Status__c, Customer_Status__c, Date__c, (SELECT Id, Date__c, Days__c FROM Promotion_Eligibility_Rules__r) FROM Eligibility_Rule__c WHERE id IN : eligibilityRuleIds]);   
        for(Promotion_Eligibility_Rule__c promEligRule : pErs ) {
            if(mapPromoCodeEligRule.containsKey(promEligRule.Promotion__r.Promotion_Code__c)) {
                if(eRuleMap.containsKey(promEligRule.Eligibility_Rule__c)) {
                    mapPromoCodeEligRule.get(promEligRule.Promotion__r.Promotion_Code__c).add(eRuleMap.get(promEligRule.Eligibility_Rule__c));
                }
            }
            else{
                if(eRuleMap.containsKey(promEligRule.Eligibility_Rule__c)) {
                    mapPromoCodeEligRule.put(promEligRule.Promotion__r.Promotion_Code__c, new List<Eligibility_Rule__c>{eRuleMap.get(promEligRule.Eligibility_Rule__c)});
                }           
            }      
        }
        
        
        
        for(String proCode : promoCodes) {
            returnVar.put(proCode, false); 
        }
        
        
        for(String pCode : mapPromoCodeEligRule.keySet()) {
            List<Eligibility_Rule__c> eligRules  = new List<Eligibility_Rule__c>();
            List<Zuora__Subscription__c> zSubs = new List<Zuora__Subscription__c>();
            eligRules = mapPromoCodeEligRule.get(pCode);
            String subscriberStatus;
            Boolean isEligible = false;
            if(mapPromocodeSubscription.containsKey(pCode)){
                subscriberStatus = null;
                zSubs = mapPromocodeSubscription.get(pCode);
            }
            else {
                subscriberStatus = 'New Subscriber';
            }
            
            if(accCustomerStatus == 'Vendor Customer' || accCustomerStatus == 'New Customer') {
                if(action == 'Add') {
                    isEligible = true;
                    
                }
            }
            else {
                system.debug(eligRules);
                for(Eligibility_Rule__c elRule : eligRules) {
                    for(Promotion_Eligibility_Rule__c per : elRule.Promotion_Eligibility_Rules__r) {
                        system.debug(zSubs);
                        for(Zuora__Subscription__c sub : zSubs) {
                            if(per.Date__c != null) {
                                if(elRule.Condition__c == '<') {
                                    if(elRule.Contract_Subscription_Rule__c == 'Subscription End Date') {
                                        isEligible = sub.Zuora__SubscriptionEndDate__c < per.Date__c;
                                        
                                    }
                                    else if(elRule.Contract_Subscription_Rule__c == 'Contract End Date') {
                                        isEligible = sub.Contract_End_Date_1__c < per.Date__c;
                                        
                                    }
                                }
                                else if(elRule.Condition__c == '>') {
                                    if(elRule.Contract_Subscription_Rule__c == 'Subscription End Date') {
                                        isEligible = sub.Zuora__SubscriptionEndDate__c > per.Date__c;
                                        
                                    }
                                    else if(elRule.Contract_Subscription_Rule__c == 'Contract End Date') {
                                        isEligible = sub.Contract_End_Date_1__c > per.Date__c;
                                        
                                    }                           
                                }
                                else if(elRule.Condition__c == '<=') {
                                    if(elRule.Contract_Subscription_Rule__c == 'Subscription End Date') {
                                        isEligible = sub.Zuora__SubscriptionEndDate__c <= per.Date__c;
                                        
                                    }
                                    else if(elRule.Contract_Subscription_Rule__c == 'Contract End Date') {
                                        isEligible = sub.Contract_End_Date_1__c <= per.Date__c;
                                    }                           
                                }
                                else if(elRule.Condition__c == '>=') {
                                    if(elRule.Contract_Subscription_Rule__c == 'Subscription End Date') {
                                        isEligible = sub.Zuora__SubscriptionEndDate__c >= per.Date__c;
                                        
                                    }
                                    else if(elRule.Contract_Subscription_Rule__c == 'Contract End Date') {
                                        isEligible = sub.Contract_End_Date_1__c >= per.Date__c;
                                        
                                    }                               
                                }                       

                            }
                            else {
                                if(elRule.Condition__c == '<') {
                                    if(elRule.Contract_Subscription_Rule__c == 'Subscription End Date') {
                                        isEligible = sub.Zuora__SubscriptionEndDate__c < (date.today().addDays(Integer.valueof(per.Days__c)));
                                        
                                    }
                                    else if(elRule.Contract_Subscription_Rule__c == 'Contract End Date') {
                                        isEligible = sub.Contract_End_Date_1__c < (date.today().addDays(Integer.valueof(per.Days__c)));
                                        
                                    }
                                }
                                else if(elRule.Condition__c == '>') {
                                    if(elRule.Contract_Subscription_Rule__c == 'Subscription End Date') {
                                        isEligible = sub.Zuora__SubscriptionEndDate__c > (date.today().addDays(Integer.valueof(per.Days__c)));
                                        
                                    }
                                    else if(elRule.Contract_Subscription_Rule__c == 'Contract End Date') {
                                        isEligible = sub.Contract_End_Date_1__c > (date.today().addDays(Integer.valueof(per.Days__c)));
                                        
                                    }                           
                                }
                                else if(elRule.Condition__c == '<=') {
                                    if(elRule.Contract_Subscription_Rule__c == 'Subscription End Date') {
                                        isEligible = sub.Zuora__SubscriptionEndDate__c <= (date.today().addDays(Integer.valueof(per.Days__c)));
                                        
                                    }
                                    else if(elRule.Contract_Subscription_Rule__c == 'Contract End Date') {
                                        isEligible = sub.Contract_End_Date_1__c <= (date.today().addDays(Integer.valueof(per.Days__c)));
                                    }                           
                                }
                                else if(elRule.Condition__c == '>=') {
                                    if(elRule.Contract_Subscription_Rule__c == 'Subscription End Date') {
                                        isEligible = sub.Zuora__SubscriptionEndDate__c >= (date.today().addDays(Integer.valueof(per.Days__c)));
                                        
                                    }
                                    else if(elRule.Contract_Subscription_Rule__c == 'Contract End Date') {
                                        isEligible = sub.Contract_End_Date_1__c >= (date.today().addDays(Integer.valueof(per.Days__c)));
                                        
                                    }                               
                                }                           
                            }
                        }
                    }
                }
            }

            returnVar.put(pCode, isEligible);
        }

        return returnVar;
    }
}