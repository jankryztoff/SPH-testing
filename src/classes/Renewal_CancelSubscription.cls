/**
 * Class Name: Renewal_CancelSubscription
 * @author: FrancisMartinBenzon
 * Date: 8/26/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Sets Subscription Status to Expired, Zuora Cancel Callout
 */

public class Renewal_CancelSubscription {

    //this method is use as prerequisite for login in 
    public static String amendApiCall(Zuora.zObject[] amendments) {
        Zuora.zApi zuorApi = new Zuora.zApi();
        //START D-3268 Modified By C.I.Salas - Test Coverage
		if (!Test.isRunningTest()) {
			zuorApi.zLogin();
		}
		//END D-3268 Modified By C.I.Salas - Test Coverage
        
        //Amend Request
        Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();       
  
        amendRequest.amendments = amendments;
        
        // Amend Options
        Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
        amendmentOption.GenerateInvoice = false;
        amendmentOption.ProcessPayments = false;
        amendRequest.AmendOptions = amendmentOption;
                        
        // Amend Preview
        Zuora.zApi.PreviewOptions previewOptions = new Zuora.zApi.PreviewOptions();
        previewOptions.EnablePreviewMode = false;
        amendRequest.previewOptions = previewOptions;        

        Zuora.zApi.AmendResult result = zuorApi.zamend(new List < Zuora.zApi.AmendRequest > {
        amendRequest
        });
 
        return String.valueOf(result.success);
    }
    /**
    * @description : method is used to cancel subscriptions
    *           
    */    
    public static Zuora.zObject cancelAmendment(String zuoraId, Date dayAfterEndDate) {
                
        String zuoraDate =  formatDateToZuora(dayAfterEndDate);  
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('Type', 'Cancellation');
        amendment.setValue('Status', 'Completed');
        amendment.setValue('SubscriptionId', zuoraId);
        amendment.setValue('Name', 'Cancel a Subscripiton Amendment');
        amendment.setValue('EffectiveDate', Zuora.zUtil.getZuoraDate(dayAfterEndDate));
        amendment.setValue('ContractEffectiveDate', Zuora.zUtil.getZuoraDate(dayAfterEndDate));
        //amendment.setValue('ContractEffectiveDate', dayAfterEndDate);
        return amendment;                  
    }
    
    //Filtered Subscription records to be included in the callout for amendment.
    
    /**
    * @description : this method is use to query bulk record from SFDC to zuora
    *           
    */ 

    @future (callout = true)
    public static void getSubscriptionParams(Id subId) {
    Zuora.zObject[] amendments = new List<Zuora.zObject>();
    Date endDateYesterday = date.today().addDays(-1); 
    
        //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
        if (subId != null || endDateYesterday != null){
        for(Zuora__Subscription__c subs : [SELECT Id, Zuora__Zuora_Id__c, Zuora__SubscriptionEndDate__c, Zuora__Status__c, Request_Expiration__c FROM Zuora__Subscription__c
                                                            WHERE Id = :subId OR (Zuora__SubscriptionEndDate__c = :endDateYesterday)]) {
            amendments.add(cancelAmendment(subs.Zuora__Zuora_Id__c, subs.Zuora__SubscriptionEndDate__c.addDays(1)));
        } 
        system.debug(amendments);
        amendApiCall(amendments);
        } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
    }
    
    //Convert date format date to zuora format of date.
    public static String formatDateToZuora(Date formatDate){

        DateTime stp = (DateTime)formatDate;
        String mydate = string.valueof(stp.format('YYYY-MM-d'));
        String d = mydate+'T00:00:00';
        return d;
    }

    
}