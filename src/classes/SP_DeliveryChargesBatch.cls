/**
 * Class Name: SP_DeliveryChargesBatch
 * @author: Manolo Valena/Jayson Sarion
 * Date: 
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Process to handle delivery charges for Temp Stop Subscription
 * History: UD-2176 Added by M.Valena && J.Sarion 08/05/2015 - Recode class based on the correct implementation of Del Charge usage creation
 * History: D-3476 9/7/2015 - Updated whole class to resolve multiple issues.
 */

global class SP_DeliveryChargesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String mainQuery;
    public Integer durationInDays;
    public String UOM;
    public Date startDate;
    public Date endDate;
    public ID thisAccId;
    
    Set<Id> subRecipientAddressIdSet = new Set<Id>();
    Set<String> billingAccountIdSet = new Set<String>();
    Set<Id> allPublicationSubscriptionIdSet = new Set<Id>();
    List<Zuora__Subscription__c> allPublicationSubscriptionList = new List<Zuora__Subscription__c>();
    Set<String> sameRecipientAddressSet = new Set<String>();
    Map<Id, Date> startDateMap = new Map<Id, Date>();
    Map<Id, Date> endDateMap = new Map<Id, Date>();
    List<Id> failedRecords = new List<Id>();
    
    Map<Id, List<Subscription_Temp_Stop__c>> recipientContactToSubscriptionsMap = new Map<Id, List<Subscription_Temp_Stop__c>>();
    Map<Id, List<Subscription_Temp_Stop__c>> recipientContactToSubscriptionsMap2 = new Map<Id, List<Subscription_Temp_Stop__c>>();
    Set<Id> recipientContactSet = new Set<Id>();
    Set<Id> stcIdSet = new Set<Id>();
    
    Map<Id, Zuora__SubscriptionProductCharge__c> recipientContactToSPCMap = new Map<Id, Zuora__SubscriptionProductCharge__c>();
    Map<Id, Set<Id>> recipientToTotalSubs = new Map<Id, Set<Id>>();
    Map<Id, List<Zuora__Subscription__c>> recipientToDeliverySubs = new Map<Id, List<Zuora__Subscription__c>>();
    Map<Id, Zuora__Subscription__c> contactToHighestDelSubMap = new Map<Id, Zuora__Subscription__c>();
    Map<Id, Set<Id>> recipientToTotalSubsFromTStop = new Map<Id, Set<Id>>();
    Map<Id, Zuora__SubscriptionProductCharge__c> subIdToSpcMap = new Map<Id, Zuora__SubscriptionProductCharge__c>();
    Map<Id, Date> subscriptionIdToEndDate = new Map<Id, Date>();
  
    Map<Id, List<Subscription_Temp_Stop__c>> subToTStops = new Map<Id, List<Subscription_Temp_Stop__c>>();
    Set<String> pCode = new Set<String>();
    Map<Id, String> subToPCodeMap = new Map<Id, String>();
    Map<Id, String> subToPlatformMap = new Map<Id, String>();
    Map<String, String> prodCodeToPlatformMap = new Map<String, String>();
    
    Set<Id> packageIdSet = new Set<Id>();
  
    private final static Date referenceDate = UsageHelper.getUsageReferenceDate(); 
		

	//START D-3654 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
    //START D-3654 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
    //START D-4080 Gdelrosario : added instantiation for code review
    private Set<String> referenceIdsAsString = new Set<String>();
    //END  D-4080 Gdelrosario : added instantiation for code review
    private Set<Id> referenceIdsAsId;
    private Integer type;
    Boolean isApexJobSuccessful = true;
    
    global SP_DeliveryChargesBatch(){
    
    }
    
    global SP_DeliveryChargesBatch(Set<String> referenceIds, Integer type){
        referenceIdsAsString = referenceIds;
        if(type == 1){
            referenceIdsAsId = new Set<Id>();
            for(String refId :referenceIds){
                referenceIdsAsId.add(Id.valueOf(refId));
            }
        }
        this.type = type;
    }
	//END D-3654 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
    //END D-3654 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String onGoing = 'On-going';
        String activeStat = 'Active';
        String subTypePub = 'Publication';
        String cancelled = 'Cancelled';
        
        Date startDate = referenceDate.toStartOfMonth();
        Date endDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
        
		/*
		 * Get all Subscription Temp Stops that are not yet cancelled, and with a subscription that is either active, or cancelled and having
		 * a subscription end date within the reference month. The restart date should also be within the reference month.
		 */
		String query = 'SELECT Id, Subscription__c, Subscription__r.Recipient_Contact__r.Address__c, '+
                        'Subscription__r.Zuora__CustomerAccount__c, Temp_Stop__c,  '+
                        'Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Temp_Stop_Status__c '+ 
                        'FROM Subscription_Temp_Stop__c '+
                        'WHERE Temp_Stop__r.Temp_Stop_Status__c !=: cancelled '+ 
                        'AND Subscription__r.Subscription_Type_1__c =: subTypePub '+
                        'AND Subscription__r.Zuora__Status__c =: activeStat ';
        
		//START D-3654 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
        //START D-3654 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts
        if(referenceIdsAsId != null && type != null && type == 1){
            query += 'AND Id IN :referenceIdsAsId ';
        }else if(referenceIdsAsString != null && type != null && type == 2){
            query += 'AND Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c IN :referenceIdsAsString ';
        }
        
        if(referenceDate != null) {
            query += 'AND Temp_Stop__r.Restart_Date__c >=: startDate AND Temp_Stop__r.Restart_Date__c <=: endDate';
        } else {        
            query += 'AND Temp_Stop__r.Restart_Date__c >= THIS_MONTH AND Temp_Stop__r.Restart_Date__c <= THIS_MONTH';
        }
        //END D-3654 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts
		//END D-3654 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
		
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List<Subscription_Temp_Stop__c> scope) {

		//START D-3654 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
        //START D-3654 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
        Logger logger = new Logger(SP_DeliveryChargesBatch.class.getName(), 'SP005', BC.getJobID());
        try{
			list<Usage__c> usageList = new list<Usage__c>();
			List<Zuora__SubscriptionProductCharge__c> delSubSPCList = new List<Zuora__SubscriptionProductCharge__c>();
			Usage__c usage;
			set<Id> usageIdSet = new set<Id>();
			Set<Id> delSubIdSet = new Set<Id>();
			Set<String> digitalValsSet = new Set<String>{'Online', 'Tablet', 'Smartphone', 'All-In-One'};
			
			for(Subscription_Temp_Stop__c subTempStop : scope)
			{
				//Get all recipient contacts from the scope.
				stcIdSet.add(subTempStop.Id);
				if(subTempStop.Subscription__r.Recipient_Contact__c != null) {
					recipientContactSet.add(subTempStop.Subscription__r.Recipient_Contact__c);
				}
			}
			
			if(recipientContactSet.size() > 0) {
				/*
				 * Query all subscriptions having the same recipient in the set of recipients above.
				 * Results are filtered to publication and delivery subscriptions that are either active, or 
				 * cancelled and having a subscription end date within the reference date.
				 */
				List<Zuora__Subscription__c> zSubList = [SELECT Id, Name, Recipient_Contact__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Subscription_Type_1__c, Billing_Type__c, Zuora__SubscriptionStartDate__c,
														 Contract_End_Date_1__c, Zuora__SubscriptionEndDate__c, Product_Code__c, Main_Package_1__c
														 FROM Zuora__Subscription__c 
														 WHERE Recipient_Contact__c IN : recipientContactSet 
														 AND Zuora__Status__c =: GlobalVariableClass.ZUORA_STATUS_ACTIVE
														 AND (Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION OR Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY)];
			
				for(Zuora__Subscription__c zs : zSubList) {
					packageIdSet.add(zs.Main_Package_1__c);
					pCode.add(zs.Product_Code__c);
					if(!subToPCodeMap.containsKey(zs.Id) &&
						zs.Product_Code__c != NULL) {
						subToPCodeMap.put(zs.Id, zs.Product_Code__c);
					}
				}
				
				/*
				* Create Map for Product Code to Product Platform.
				* This will be used to check if the Subscription is Print, Online, Tablet, Smartphone, and All-In-One.
				* Digital Subscription will not be considered for checking if the Recipient Contact will have a refund for whole months.
				*/
				if(!packageIdSet.isEmpty()){
					for(Package_Item__c pi :[SELECT Product_Rate_Plan__r.zqu__ZProduct__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.Product_Code__c FROM Package_Item__c WHERE Package__c IN :packageIdSet]){
						if(!prodCodeToPlatformMap.containsKey(pi.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c) &&
							pi.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c != NULL) {
							prodCodeToPlatformMap.put(pi.Product_Rate_Plan__r.Product_Code__c, pi.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c);
						}
					}
				}
				
				if(subToPCodeMap.keySet().size() > 0) {
					for(Id subIdR : subToPCodeMap.keySet()) {
						if(prodCodeToPlatformMap.containsKey(subToPCodeMap.get(subIdR))) {
							if(!subToPlatformMap.containsKey(subIdR)) {
								//subToPlatformMap contains all subscriptions from the subscription query above with their corresponding product platform.
								subToPlatformMap.put(subIdR, prodCodeToPlatformMap.get(subToPCodeMap.get(subIdR)));
							}
						}
					}
				}
				
				//Query all Subscription Temp Stop records having a recipient contact retrieved from the scope.
				List<Subscription_Temp_Stop__c> stcList = [SELECT Id, Subscription__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Subscription__r.Id, Subscription__r.Zuora__SubscriptionStartDate__c, Subscription__r.Product_Code__c,
														   Subscription__r.Recipient_Contact__c, Subscription__r.Zuora__SubscriptionEndDate__c, Subscription__r.Zuora__TermSettingType__c
														   FROM Subscription_Temp_Stop__c
														   WHERE Subscription__r.Recipient_Contact__c IN : recipientContactSet
														   AND Temp_Stop__r.Temp_Stop_Status__c !=: GlobalVariableClass.STATUS_CANCELLED];
				
				for(Subscription_Temp_Stop__c stcr : stcList) {
					if(subToPlatformMap.containsKey(stcr.Subscription__r.Id) &&
					  (!digitalValsSet.contains(subToPlatformMap.get(stcr.Subscription__r.Id)))) {
						//Condition for temp stop records having a restart date of equal to or greater than the first day of the reference date.
						if(stcr.Temp_Stop__r.Restart_Date__c >= referenceDate.toStartOfMonth()) {
							
							//subToTStops map contains subscriptions and their corresponding subscription temp stop records.
							if(subToTStops.containsKey(stcr.Subscription__r.Id)) {
								subToTStops.get(stcr.Subscription__r.Id).add(stcr); 
							}
							else {
								subToTStops.put(stcr.Subscription__r.Id, new List<Subscription_Temp_Stop__c>{stcr});
							}
							
							//recipientToTotalSubsFromTStop map contains recipient contacts and their corresponding subscription records that are connected to a subscription temp stop record.
							if(recipientToTotalSubsFromTStop.containsKey(stcr.Subscription__r.Recipient_Contact__c)) {
								recipientToTotalSubsFromTStop.get(stcr.Subscription__r.Recipient_Contact__c).add(stcr.Subscription__c);
							}
							else {
								recipientToTotalSubsFromTStop.put(stcr.Subscription__r.Recipient_Contact__c, new Set<Id>{stcr.Subscription__c});
							}
						}
						//Condition for temp stop records that have already restarted before the reference date.
						else {
							if(recipientContactToSubscriptionsMap2.containsKey(stcr.Subscription__r.Recipient_Contact__c)) {
								recipientContactToSubscriptionsMap2.get(stcr.Subscription__r.Recipient_Contact__c).add(stcr);
							}
							else {
								recipientContactToSubscriptionsMap2.put(stcr.Subscription__r.Recipient_Contact__c, new List<Subscription_Temp_Stop__c>{stcr});
							}
							
							/*
							 * subscriptionIdToEndDate map contains subscriptions and their corresponding end dates. Used to determine if a 
							 * whole month should be refunded or not.
							 */
							if((stcr.Subscription__r.Zuora__TermSettingType__c == GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED) ||
							   (stcr.Subscription__r.Zuora__TermSettingType__c == GlobalVariableClass.EVERGREEN &&
								stcr.Subscription__r.Zuora__SubscriptionEndDate__c != null)) {
								subscriptionIdToEndDate.put(stcr.Subscription__c, stcr.Subscription__r.Zuora__SubscriptionEndDate__c);
							}
						}
					}
				}
				
				if(recipientToTotalSubsFromTStop.keySet().size() > 0) {
					for(Id recConId : recipientToTotalSubsFromTStop.keySet()) {
						for(Id subId : recipientToTotalSubsFromTStop.get(recConId)) {
							if(subToTStops.containsKey(subId)) {
								Subscription_Temp_Stop__c stRecord;
								for(Subscription_Temp_Stop__c stRec : subToTStops.get(subId)) {
									if(stRecord == NULL) {
										stRecord = stRec;
									}
									else {
										if(stRec.Subscription__r.Id == stRecord.Subscription__r.Id &&
										   stRec.Temp_Stop__r.Restart_Date__c < stRecord.Temp_Stop__r.Restart_Date__c) {
											stRecord = stRec;
										}
									}
								}
								
								if(recipientContactToSubscriptionsMap.containsKey(stRecord.Subscription__r.Recipient_Contact__c)) { 
									recipientContactToSubscriptionsMap.get(stRecord.Subscription__r.Recipient_Contact__c).add(stRecord);
								}
								else {
									recipientContactToSubscriptionsMap.put(stRecord.Subscription__r.Recipient_Contact__c, new List<Subscription_Temp_Stop__c>{stRecord});
								}
							}
						}
					}
				}

				for(Zuora__Subscription__c zsRec : zSubList) {
					if(subToPlatformMap.containsKey(zsRec.Id) &&
					  (!digitalValsSet.contains(subToPlatformMap.get(zsRec.Id)))) {
						if(zsRec.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION) {
							if(recipientToTotalSubs.containsKey(zsRec.Recipient_Contact__c)) {
								recipientToTotalSubs.get(zsRec.Recipient_Contact__c).add(zsRec.Id);
							}
							else {
								recipientToTotalSubs.put(zsRec.Recipient_Contact__c, new Set<Id>{zsRec.Id});
							}
						}
					}
					if(zsRec.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY) {
						delSubIdSet.add(zsRec.Id);
						if(recipientToDeliverySubs.containsKey(zsRec.Recipient_Contact__c)) {
							recipientToDeliverySubs.get(zsRec.Recipient_Contact__c).add(zsRec);
						}
						else {
							recipientToDeliverySubs.put(zsRec.Recipient_Contact__c, new List<Zuora__Subscription__c>{zsRec});
						}
					}
				}
			}
			
			if(!delSubIdSet.isEmpty()){
				delSubSPCList = [SELECT Id, Zuora__ChargeNumber__c, Zuora__ProductSKU__c, Zuora__UOM__c, Zuora__Subscription__c, PublicationCode__c 
								 FROM Zuora__SubscriptionProductCharge__c 
								 WHERE Zuora__Subscription__c IN : delSubIdSet 
								 AND Zuora__UOM__c LIKE '%Credit%'];
				
				for(Zuora__SubscriptionProductCharge__c spc : delSubSPCList){
					subIdToSpcMap.put(spc.Zuora__Subscription__c, spc);
				}
			}

			for(Id recCon : recipientContactToSubscriptionsMap.keySet()) {
				if(recipientContactToSubscriptionsMap.get(recCon).size() > 0) {
					if(recipientToTotalSubs.get(recCon).size() == recipientToTotalSubsFromTStop.get(recCon).size()) {
						Map<Date, Integer> stcToMonthsMap = new Map<Date, Integer>();
						for(Subscription_Temp_Stop__c stc : recipientContactToSubscriptionsMap.get(recCon)) {
							Integer numbOfMonths = 0;
							if(stc.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(stc.Temp_Stop__r.Restart_Date__c) > 1) {    
								numbOfMonths = stc.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(stc.Temp_Stop__r.Restart_Date__c) - 1;
								
								Integer count = numbOfMonths;
								while(count > 0) {
									if(stcToMonthsMap.containsKey(stc.Temp_Stop__r.Temp_Stop_Date__c.addMonths(count).toStartOfMonth())) {
										stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c.addMonths(count).toStartOfMonth(), stcToMonthsMap.get(stc.Temp_Stop__r.Temp_Stop_Date__c.addMonths(count).toStartOfMonth()) + 1);
									}
									else {
										stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c.addMonths(count).toStartOfMonth(), 1);
									}
									count--;
								}
								
								if(stc.Temp_Stop__r.Temp_Stop_Date__c == stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth()) {
									if(stcToMonthsMap.containsKey(stc.Temp_Stop__r.Temp_Stop_Date__c)) {
										stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c, stcToMonthsMap.get(stc.Temp_Stop__r.Temp_Stop_Date__c) + 1);
									}
									else {
										stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c, 1);
									}
								}
								else if(stc.Temp_Stop__r.Temp_Stop_Date__c == stc.Subscription__r.Zuora__SubscriptionStartDate__c) {
									if(stcToMonthsMap.containsKey(stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth())) {
										stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth(), stcToMonthsMap.get(stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth()) + 1);
									}
									else {
										stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth(), 1);
									}
								}
							}
							else if(stc.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(stc.Temp_Stop__r.Restart_Date__c) == 1) {
								if(stc.Temp_Stop__r.Temp_Stop_Date__c == stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth()) {
									if(stcToMonthsMap.containsKey(stc.Temp_Stop__r.Temp_Stop_Date__c)) {
										stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c, stcToMonthsMap.get(stc.Temp_Stop__r.Temp_Stop_Date__c) + 1);
									}
									else {
										stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c, 1);
									}
								}
								else if(stc.Temp_Stop__r.Temp_Stop_Date__c == stc.Subscription__r.Zuora__SubscriptionStartDate__c) {
									if(stcToMonthsMap.containsKey(stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth())) {
										stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth(), stcToMonthsMap.get(stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth()) + 1);
									}
									else {
										stcToMonthsMap.put(stc.Temp_Stop__r.Temp_Stop_Date__c.toStartOfMonth(), 1);
									}
								}
							}               
						}
						
						Integer usageCount = 0;
						for(Date uniqueDate : stcToMonthsMap.keySet()) {
							if(stcToMonthsMap.get(uniqueDate) > 0) {
								if(recipientContactToSubscriptionsMap2.containsKey(recCon)) {
									Integer s = recipientContactToSubscriptionsMap2.get(recCon).size();
									for(Subscription_Temp_Stop__c xx : recipientContactToSubscriptionsMap2.get(recCon)) {
										if(subscriptionIdToEndDate.containsKey(xx.Subscription__c)) {
											if(uniqueDate > subscriptionIdToEndDate.get(xx.Subscription__c).toStartofMonth()) {
												s--;
											}
										}
									}
									if(s == 0) {
										usageCount++;
									}
								}
								else{
									if(stcToMonthsMap.get(uniqueDate) == recipientContactToSubscriptionsMap.get(recCon).size()){
										usageCount++;
									}
								}
							}
						}

						if(recipientToDeliverySubs.containsKey(recCon)) {
							for(Zuora__Subscription__c dcSub : recipientToDeliverySubs.get(recCon)) {
								if(!contactToHighestDelSubMap.containsKey(recCon)) {
									contactToHighestDelSubMap.put(recCon, dcSub);
								}
								else if(DeliveryChargeHelper.isHigherInHierarchy(dcSub, contactToHighestDelSubMap.get(recCon))) {
									contactToHighestDelSubMap.put(recCon, dcSub);
								}
							}
						}

						if(usageCount > 0 && contactToHighestDelSubMap.containsKey(recCon)) {
							usageList.add(createUsage(usageCount, contactToHighestDelSubMap.get(recCon)));
						}
					}
				}
			}
			UsageHelper.loadUniqueUsages(usageList, false);
		}catch(Exception e){
            logger.logBatchFailure(e, scope);
            logger.save();
            
            isApexJobSuccessful = false;
        }

		//END D-3654 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
        //END D-3654 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
    }
        

    global void finish(Database.BatchableContext BC) {
        //START D-3654 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
        if(!isApexJobSuccessful){
            BatchJobHelper.updateJobStatus(BC.getJobId(), false);
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
        //END D-3654 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
    }
    
    public Usage__c createUsage(Integer qty, Zuora__Subscription__c sub) {
        Usage__c usage = new Usage__c();
        usage.Status__c = GlobalVariableClass.STATUS_NEW;
        usage.Quantity__c = qty;
        usage.Account_Id__c = sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
        usage.Subscription_Id__c = sub.Name;
        usage.UOM__c = (subIdToSpcMap.containsKey(sub.Id) ? subIdToSpcMap.get(sub.Id).Zuora__UOM__c : GlobalVariableClass.EMPTYSTR);
        usage.Rate_Plan_Charge_Id__c = (subIdToSpcMap.containsKey(sub.Id) ? subIdToSpcMap.get(sub.Id).Zuora__ChargeNumber__c : GlobalVariableClass.EMPTYSTR); 
        usage.Publication_Code__c = (subIdToSpcMap.containsKey(sub.Id) ? subIdToSpcMap.get(sub.Id).PublicationCode__c : GlobalVariableClass.EMPTYSTR); 
        usage.Start_Date__c = referenceDate.toStartOfMonth();
        usage.Usage_Type__c = UsageHelper.USAGE_TYPE_DELIVERY_CHARGE;

        return usage;
    }
}