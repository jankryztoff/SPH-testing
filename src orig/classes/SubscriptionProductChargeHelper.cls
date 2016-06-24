/**
 * Class Name: <SubscriptionProductChargeHelper>
 * @author: <Arockia Presilda>
 * Date: <23/06/2015>
 * Requirement/Project Name: <SPH>
 * @description<Populate Publication charge>
 */
public class SubscriptionProductChargeHelper {
    
    public Static void calculatePubCharge(Map<Id, List<Zuora__SubscriptionProductCharge__c>> spcMap) {
        system.debug('spcMapHelper : ' + spcMap);
        Set<ID> SubId = spcMap.keySet();
       
        for(Id tempSubId : SubId){
            Double discountPrice = 0.00;
            List<Zuora__SubscriptionProductCharge__c> tempSPCList = spcMap.get(tempSubId);
            system.debug('tempSPCList: ' + tempSPCList);
            for(Zuora__SubscriptionProductCharge__c tempSPC : tempSPCList){
                //START [UD-3224] [Sailaja] [16 Nov 2015]:Fix checking Discount SPC
                if('DISC' == tempSPC.Product_Code__c){
                    discountPrice = tempSPC.Zuora__Price__c;
                    break;
                }
                //END [UD-3224] [Sailaja]
            }
            
            for(Zuora__SubscriptionProductCharge__c tempSPC : tempSPCList){
                if(tempSPC.Zuora__ExtendedAmount__c > 0){
                /*START [UD-3224] [Sailaja] [16 Nov 2015]:[Publication Charge Rounding Issue, setScale]*/
                    tempSPC.Publication_Charge__c = (tempSPC.Zuora__ExtendedAmount__c - ((tempSPC.Zuora__ExtendedAmount__c * discountPrice)/100)).setScale(2,RoundingMode.HALF_UP);
                /*END [UD-3224] [Sailaja] [16 Nov 2015]*/
                }
            }
             system.debug('spcMapHelperend : ' + spcMap);
        }
    }

}