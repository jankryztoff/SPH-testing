/*
 * @description: this method will calculate the applicable delivery charge for full-prepaid transaction.
 *      this will cater different scenarios
 *      1. multiple order line items with the same start and end dates (year-month)
 *      2. over lapping start/end dates
 *      3. existing full delivery subscription
 */

public class FullPrepaidDeliveryChargeCalculator {
    
    // Start D-2874 09May15 JohnD - replaced all the entire logic for UD-0715
    /*
     * @description: this method will calculate the applicable delivery charge and create usages if applicable.
     *      this method is invoke from subscriptiontriggerhandler
     * @param lstSub : list of newly created subscriptions
     * @return: list of temporarily modified subscriptions values to be used in creating the usages. 
     *      the changes will not be saved 
     * 
     */
    public static list<Zuora__Subscription__c> calculate(list<Zuora__Subscription__c> lstSub) {
        return lstSub;
    }
    
    /*
     * @description: this method will calculate the applicable delivery charge fo full-prepaid order line item.
     *      this method is invoke from sm_startsubscriptionentrycontroller, sm_changeofsubscriptionentrycontroller,
     *      and sm_renewalofsubscriptionetnrycontroller
     * @param orderId : the id of the order
     * @param subscriberCharge : the monthly delivery charge according to the configured values or user input
     * @return: total applicable delivery charge
     */
    public static map<string, decimal> calculate(id orderId, decimal subscriberCharge) {

        map<string, decimal> chargeName_amount = new map<string, decimal>(); 
        decimal fullPrepaidSubscriberCharge = 0.0;
        decimal recurringSubscriberCharge = 0.0;

		//START UD-1432 06/02/2015 Removed by: J. Sarion - Removed Qty__c in the computation
        //START D-3032 05/27/2015 Added by: J. Sarion - Added Postage Charge = 0 in WHERE clause and added Qty__c in the computation
		//START D-3105 05/27/2015 Added by: J. Sarion - Added Main Package Sub Type = Newspaper
        for (Order_Line_Item__c oli : [select Main_Package_Billing_Type__c, Term_Length__c, Qty__c from Order_Line_Item__c 
                where Order__c = :orderId AND Postage_Charge__c = 0 AND Main_Package_Product_Sub_Type__c = 'Newspaper']) {
            
            if (oli.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE) {
                if (oli.Term_Length__c != null && subscriberCharge != null) {
                    fullPrepaidSubscriberCharge += (subscriberCharge * oli.Term_Length__c) ;    
                } 
            } else {
                recurringSubscriberCharge = subscriberCharge;
                break;
            }             
        }
		//END D-3105 05/27/2015 Added by: J. Sarion - Added Main Package Sub Type = Newspaper
        //END D-3032 05/27/2015 Added by: J. Sarion - Added Postage Charge = 0 in WHERE clause and added Qty__c in the computation
		//END UD-1432 06/02/2015 Removed by: J. Sarion - Removed Qty__c in the computation
        chargeName_amount.put(GlobalVariableClass.BILLING_TYPE_FULL, fullPrepaidSubscriberCharge);
        chargeName_amount.put(GlobalVariableClass.BILLING_TYPE_RECURRING, recurringSubscriberCharge);
        
        return chargeName_amount;
    }
    // End D-2874 09May15 JohnD - replaced all the entire logic for UD-0715
}