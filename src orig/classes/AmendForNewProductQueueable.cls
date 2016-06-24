/*
* Class Name: AmendForNewProductQueueable
* @Author: Kevin Evasco
* Date: 23 June 2015
* Requirement/Project Name: CRSM Project
* @Description Queueable class for New Product Amendment
* @History UD-1676 23 June 2015 Kevin Evasco - Created queueable class
*
*/

public class AmendForNewProductQueueable implements Queueable, Database.AllowsCallouts {
    
    public static String subscriptionId;
    public static Decimal adminCharge;
    public static Date contractEffectiveDate;
    public static Date customerAcceptanceDate;
    public static Date effectiveDate;
    public static Date serviceActivationDate;
    
    public AmendForNewProductQueueable(String subscriptionIdParam, Decimal adminChargeParam, Date contractEffectiveDateParam, Date customerAcceptanceDateParam, Date effectiveDateParam, Date serviceActivationDateParam) {
        subscriptionId = subscriptionIdParam;
        adminCharge = adminChargeParam;
        contractEffectiveDate= contractEffectiveDateParam;
        customerAcceptanceDate = customerAcceptanceDateParam;
        effectiveDate = effectiveDateParam;
        serviceActivationDate = serviceActivationDateParam;
    }    
    
    public void execute(QueueableContext context){
        AdminCharge_Amendment adminChargeCall = new AdminCharge_Amendment();
        adminChargeCall.amendForNewProduct(subscriptionId, adminCharge,contractEffectiveDate, customerAcceptanceDate, effectiveDate, serviceActivationDate);
    }

}