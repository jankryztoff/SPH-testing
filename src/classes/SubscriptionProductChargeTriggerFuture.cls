public class SubscriptionProductChargeTriggerFuture {
    @future
    public static void updateSubscriptionChargePublication(Set<Id> setSubscription){
        Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubSPC = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
        Map<Id, Zuora__Subscription__c> mapSub = new Map<Id, Zuora__Subscription__c>();

        // get SPC records for each Subscription in Susbcription Set
        for(Zuora__Subscription__c sub : [SELECT Id, Name, (SELECT Id, Product_Code__c, Zuora__ExtendedAmount__c, Zuora__Price__c FROM Zuora__Subscription_Product_Charges__r WHERE Zuora__Type__c = :GlobalVariableClass.SPC_TYPE_RECURRING)
                                  FROM Zuora__Subscription__c 
                                  WHERE Id = :setSubscription
                                  AND Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION]){
            mapSubSPC.put(sub.Id, sub.Zuora__Subscription_Product_Charges__r);
            mapSub.put(sub.Id, sub);
                                      
            System.debug('Total SPC: ' + mapSubSPC.get(sub.Id).size());
        }

        // calculate subscription charge
        for(Id subId : mapSubSPC.keySet()){
            double mainCharge = 0.00;
            double discRate = 0.00;
            
            for(Zuora__SubscriptionProductCharge__c spc : mapSubSPC.get(subId)){
                // get total SPC charge
                if(spc.Zuora__ExtendedAmount__c > 0){
                    mainCharge += spc.Zuora__ExtendedAmount__c;
                }

                // if there is discount SPC, get discount rate
                if(spc.Product_Code__c == 'DISC'){
                    discRate = spc.Zuora__Price__c/100;                 
                }
            }

            double finalCharge = mainCharge - ((decimal) mainCharge * discRate).setScale(2, RoundingMode.HALF_UP);

            // update corresponding Subscription record
            mapSub.get(subId).Subscription_Charge__c = finalCharge;
            
            System.debug('Final charge : ' + mapSub.get(subId).Subscription_Charge__c);
        }
        
        System.debug('Total subs to update : ' + mapSub.size());
        
        // update Subscription list
        update mapSub.values();
    }
}