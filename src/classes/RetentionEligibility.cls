/**
 * Class Name: RetentionEligibility
 * @author: Kristine Campang
 * Date: 9/26/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Class that checks Retention Eligibility
 *
 */

public with sharing class RetentionEligibility{
        
    //instantiates variables
    public Boolean isWithin;
    public Boolean isRetentionEligible;
    public Boolean isDailyPub;
    public  Map<Id, List<Publication__c>> mapSubsPublicationList;
    
    public Boolean checkRetentionEligibilty(Id subscriptionId, Date stpDate){
			//START Code Review 2/17/2015 Added By C. Lin - Null in where clause causes full table scans - 100K Record Issue Limit
			Zuora__Subscription__c subscriptionRec = new Zuora__Subscription__c();
			if(subscriptionId != null){
				subscriptionRec = [SELECT Id, Contract_End_Date_1__c, Promotion__c, Zuora__Account__r.RecordTypeId FROM Zuora__Subscription__c WHERE Id=:subscriptionId];
            }
			//END Code Review 2/17/2015 Added By C. Lin
			
            Set<Id> setTrue = new Set<Id>();
            mapSubsPublicationList = new Map<Id, List<Publication__c>>();
            //checks if Stop Date is within the contract end date
			//START Code Review 2/18/2015 Added By C. Lin - Null in where clause causes full table scans - 100K Record Issue Limit
			if(subscriptionRec != null){
				isWithin = AdminFeeComputation.checkIfWithin(stpDate, subscriptionRec.Contract_End_Date_1__c);
			}
			//END Code Review 2/18/2015 Added By C. Lin
            //get Publication of Subscription
            SubscriptionUtil subUtil = new SubscriptionUtil();
            subUtil.getSubToPub(subscriptionId);
            mapSubsPublicationList = subUtil.mapSubsId_toPubList;
            isDailyPub = checkIfDaily(subscriptionId);
			//START Code Review 2/18/2015 Added By C. Lin - Null in where clause causes full table scans - 100K Record Issue Limit
			if(subscriptionRec != null){
				//START D-2168 2/12/2015 Added By S.PULI -modify criteria for retention eligibility for stop subs
				if(((subscriptionRec.Zuora__Account__r.RecordTypeId == ConstantsSLB.getKeyId(globalvariableclass.ACCOUNT_DIRECT_INDIVIDUAL)) || (subscriptionRec.Zuora__Account__r.RecordTypeId == ConstantsSLB.getKeyId(globalvariableclass.ACCOUNT_VENDOR_SUBSCRIBER)))
					  && (isWithin==FALSE || subscriptionRec.Contract_End_Date_1__c == null) && isDailyPub==true){
				//END D-2168 2/12/2015 Added By S.PULI
					   isRetentionEligible = true; 
					}
				else{
					isRetentionEligible = false;
				}
			}else{
				isRetentionEligible = false;
			}
			//END Code Review 2/18/2015 Added By C. Lin
     
        return isRetentionEligible; 
    }
    
    //This method is only use for checking if the type of publication is a Newspaper.
    public Boolean checkIfDaily(Id subsId){
            Set<Id> setDaily = new Set<Id>();
            Boolean isDaily = false;
            if(mapSubsPublicationList.containsKey(subsId)){
                for(Publication__c publicRec : mapSubsPublicationList.get(subsId)){
                        if(publicRec.Publication_Type__c =='N'){
                            setDaily.add(publicRec.Id);
                        }
                }
                if(setDaily.size()>0){
                    isDaily = true;
                }
   
            }
         return isDaily;
    }
	
	//START: UD-2984 10/7/15 Added by Manolo Valena
	public Map<Id, Boolean> checkRetentionEligibiltyMultipleSubscriptions(Set<Id> subscriptionIds, Map<Id, Date> subToStopDate) {
		List<Zuora__Subscription__c> subscriptionRecs = new List<Zuora__Subscription__c>();
		Map<Id, Boolean> subToWithinMap = new Map<Id, Boolean>();
		Map<Id, Boolean> subToCheckDailyMap = new Map<Id, Boolean>();
		Map<Id, Boolean> subToIsRetentionEligibleMap = new Map<Id, Boolean>();
		mapSubsPublicationList = new Map<Id, List<Publication__c>>();
		SubscriptionUtil subUtil = new SubscriptionUtil();
		
		if(subscriptionIds.size() > 0){
			subscriptionRecs = [SELECT Id, Contract_End_Date_1__c, Promotion__c, Zuora__Account__r.RecordTypeId 
								FROM Zuora__Subscription__c 
								WHERE Id IN: subscriptionIds];
		}
		
		if(subscriptionRecs.size() > 0){
			for(Zuora__Subscription__c zSub : subscriptionRecs) {
				if(subToStopDate.containsKey(zSub.Id)) {
					Boolean isWithinBool = AdminFeeComputation.checkIfWithin(subToStopDate.get(zSub.Id), zSub.Contract_End_Date_1__c);
					subToWithinMap.put(zSub.Id, isWithinBool);
				}
			}
		}
		
		if(subscriptionIds.size() > 0) {
			mapSubsPublicationList = subUtil.subIdToPubListMap(subscriptionIds);
			for(Id subId : subscriptionIds) {
				Boolean isDailyPubBool = checkIfDaily(subId);
				subToCheckDailyMap.put(subId, isDailyPubBool);
			}
		}
		
		if(subscriptionRecs.size() > 0) {
			for(Zuora__Subscription__c zSubRec : subscriptionRecs) {
				if(subToWithinMap.containsKey(zSubRec.Id) && subToCheckDailyMap.containsKey(zSubRec.Id)) {	
					if(((zSubRec.Zuora__Account__r.RecordTypeId == ConstantsSLB.getKeyId(globalvariableclass.ACCOUNT_DIRECT_INDIVIDUAL)) || 
						(zSubRec.Zuora__Account__r.RecordTypeId == ConstantsSLB.getKeyId(globalvariableclass.ACCOUNT_VENDOR_SUBSCRIBER))) && 
					   (subToWithinMap.get(zSubRec.Id) == FALSE || zSubRec.Contract_End_Date_1__c == null) && 
					    subToCheckDailyMap.get(zSubRec.Id) == true) {
						subToIsRetentionEligibleMap.put(zSubRec.Id, true);
					}
					else {
						subToIsRetentionEligibleMap.put(zSubRec.Id, false);
					}
				}
			}
		}
		
		return subToIsRetentionEligibleMap;
	}
	//END: UD-2984 10/7/15 Added by Manolo Valena
}