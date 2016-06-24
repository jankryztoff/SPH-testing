/**
 * Class Name: AdminFeeComputation
 * @author: Kristine Campang
 * Date: 9/26/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Class for Admin Fee Computation
 * History : 2/16/2015 - Joban - Code Review Activity : Modified code to prevent SOQL errors
 */

public class  AdminFeeComputation{
    
    //Subscription Variables
    public Static Zuora__Subscription__c zuoraSubRec;
    public Static Decimal adminCharge;
    public Static Promotion__c promotionRec;
    public Static Map<Id, Promotion__c> subsIdToPromotionMap; 
    public Static Boolean isWithin;
    
/*Description: this method is used to compute admin charge based on the contract end date, stop request date and promotion package.
 *Parameter: Id subscriptionId and Date stopReqDate
 *Return: adminCharge
 */
    
    public Static Decimal computeAdminCharge(Id subscriptionId, Date stopReqDate){
            
            //instantiates Variables
            subsIdToPromotionMap = new Map<Id, Promotion__c>();
            //START D-3270 7/22/2015 Added by Manolo Valena
            List<Exception> exceptionList = new List<Exception>();
            //END D-3270 7/22/2015 Added by Manolo Valena
            
            //Subscription Query
            if(subscriptionId !=null){ // 2/16/2015 - Joban - Code Review Activity : Added null check
                zuoraSubRec = [SELECT Id, Contract_End_Date_1__c, Promotion_1__c FROM Zuora__Subscription__c WHERE Id=:subscriptionId];
            }
            try{
                if(zuoraSubRec.Promotion_1__c!=null){// 2/16/2015 - Joban - Code Review Activity : Added null check
                    promotionRec = [SELECT Id, Penalty_Charge__c, Promotion_Code__c, Penalty_Charge_Add_On__c, Penalty_Charge_Override__c
                                   FROM Promotion__c
                                   WHERE Id =:zuoraSubRec.Promotion_1__c];
                }
                subsIdToPromotionMap.put(zuoraSubRec.Id, promotionRec);
            } 
            catch(Exception e){
                adminCharge = 0.00;
            }
            //call method checkIfWithin to check if the stopdate is within the contract end date and compute for adminCharge.
            isWithin = checkIfWithin(stopReqDate, zuoraSubRec.Contract_End_Date_1__c);
            
            //START D-3270 7/22/2015 Added by Manolo Valena - Added try catch to catch error when there is no promotion but there is contract end date.
            try {
                if(subsIdToPromotionMap.containsKey(subscriptionId)){
                    if(isWithin){
                        //START D-2048 2/2/2015 Added By C. Lin - Penalty Charge Override should be the Admin Charge/Admin Fee if available.
                        if(subsIdToPromotionMap.get(subscriptionId).Penalty_Charge_Override__c != null){
                            adminCharge = subsIdToPromotionMap.get(subscriptionId).Penalty_Charge_Override__c;
                        } else if(subsIdToPromotionMap.get(subscriptionId).Penalty_Charge__c != null){
                            adminCharge = Decimal.valueof(subsIdToPromotionMap.get(subscriptionId).Penalty_Charge__c);
                        } else {
                            adminCharge = 0.00;
                        }
                        //END D-2048 2/2/2015 Added By C. Lin
                    }
                    else{
                        adminCharge = 0.00;
                    }
                }
                return adminCharge;
            }
            catch(Exception e) {
                adminCharge = 0;
                exceptionList.add(new CustomException(e.getMessage()));
                if(!exceptionList.isEmpty()) {
                    ExceptionLogger.log(exceptionList);
                }
                return adminCharge;
            }
            //END D-3270 7/22/2015 Added by Manolo Valena
    }
    
    /*Description: this method is used to check if the stopdate is within the contract end date.
     *Parameter: Date stopDate, Date contractEndDate
     *Return: isWithin
     */   
 
    public Static Boolean checkIfWithin(Date stopDate, Date contractEndDate){
        if(stopDate<=contractEndDate){
                isWithin = TRUE;
        }
        else {
             isWithin = FALSE;
        }    
        system.debug('>>>>>isWithin ' + stopDate + ' ' + contractEndDate);
        system.debug('>>>>>isWithin ' + isWithin);
        return isWithin;
    }
    
    //START UD-2549 3/16/2016 Added by J.Sarion - bulkified computeAdminCharge
    /*Description: this method is used to compute admin charge based on the contract end date, stop request date and promotion package.
     *Parameter: Map<String, Date> Subscription Zuora Id to Earliest Stop Date
     *Return: Map<String, Decimal> Subscription Zuora Id to AdminCharge
     */
    public static Map<String, Decimal> computeAdminChargeBulk(Map<String, Date> subZuoraIdToEarliestDateMap) {
        //Lists
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        List<Promotion__c> promoList = new List<Promotion__c>();
        
        //Maps
        Map<Id, List<Zuora__Subscription__c>> promoIdToSubListMap = new Map<Id, List<Zuora__Subscription__c>>(); 
        Map<String, Decimal> subZuoraIdToAdminChargeMap = new Map<String, Decimal>();
        
        //Sets
        system.debug('>>>>>subZuoraIdToEarliestDateMap.keySet() ' + subZuoraIdToEarliestDateMap.keySet());
        subList = [SELECT Id, Contract_End_Date_1__c, Promotion_1__c, Zuora__Zuora_Id__c 
                   FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :subZuoraIdToEarliestDateMap.keySet() AND Promotion_1__c != null AND Subscription_Type_1__c = 'Publication'];
        //system.assertequals(subList, null);           
        system.debug('>>>>>subList ' + subList);
        for(Zuora__Subscription__c sub :subList) {
            system.debug('>>>>>sub ' + sub.Promotion_1__c);
            if(promoIdToSubListMap.containsKey(sub.Promotion_1__c)) {
                promoIdToSubListMap.get(sub.Promotion_1__c).add(sub);
            }
            else {
                promoIdToSubListMap.put(sub.Promotion_1__c, new List<Zuora__Subscription__c>{sub});
            }
        }
        system.debug('>>>>>promoIdToSubListMap ' + promoIdToSubListMap);
        if(!promoIdToSubListMap.isEmpty()) {
            promoList = [SELECT Id, Penalty_Charge__c, Promotion_Code__c, Penalty_Charge_Add_On__c, Penalty_Charge_Override__c 
                         FROM Promotion__c 
                         WHERE Id IN :promoIdToSubListMap.keySet()];
                         
            system.debug('>>>>>promoList ' + promoList);
            if(!promoList.isEmpty()) {
                for(Promotion__c promo :promoList) {                
                    system.debug('>>>>>promo.Penalty_Charge_Override__c ' + promo.Penalty_Charge_Override__c);
                    system.debug('>>>>>promo.Penalty_Charge__c ' + promo.Penalty_Charge__c);
                    if(promo.Penalty_Charge_Override__c != null){
                        adminCharge = promo.Penalty_Charge_Override__c;
                    } else if(promo.Penalty_Charge__c != null){
                        adminCharge = Decimal.valueof(promo.Penalty_Charge__c);
                    } else {
                        adminCharge = 0.00;
                    }
                    
                    if(promoIdToSubListMap.containsKey(promo.Id)) {
                        for(Zuora__Subscription__c sub :promoIdToSubListMap.get(promo.Id)) {
                            if(checkIfWithin(subZuoraIdToEarliestDateMap.get(sub.Zuora__Zuora_Id__c), sub.Contract_End_Date_1__c)) {
                                subZuoraIdToAdminChargeMap.put(sub.Zuora__Zuora_Id__c, adminCharge);
                            }
                        }
                    }
                }
            }
        }
        system.debug('>>>>>subZuoraIdToAdminChargeMap ' + subZuoraIdToAdminChargeMap);
        return subZuoraIdToAdminChargeMap;
    }
    //END UD-2549 3/16/2016 Added by J.Sarion
}