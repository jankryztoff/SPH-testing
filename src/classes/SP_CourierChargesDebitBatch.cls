/**
 * Class Name: SP_CourierChargesDebitBatch 
 * @author: Jb Domingo
 * Date: 9/11/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Class that creates Vendor Monthly Data - Debit
 *
 */
global class SP_CourierChargesDebitBatch implements Database.Batchable<sObject>
{
   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bcTemp - predefined parameter 
    * @return list of objects from Case Object
    */ 
    global database.QueryLocator start(database.BatchableContext bcTemp){
        return database.getQueryLocator([SELECT Courier_Fee__c, Paper_Fee__c, Subscription_Name__r.Vendor_1__c,
                                                Subscription_Name__r.Vendor_1__r.AccountNumber,
                                                Subscription_Name__r.Vendor_1__r.Vendor_Group__c
                                                FROM Case      
                                                WHERE Effective_Date__c = THIS_MONTH 
                                                AND Vendor_Chargeable_Courier__c = TRUE]);
    }
    /* @description Executes the business logic and creates Vendor Monthly Data object
     * 
     * @param bcTemp - predefined parameter 
     * @param allScopes - a list of sObjects from the initial database query
     * @return void
     */
    global void execute(database.batchableContext bcTemp, list<Case> allScopes){
        List<Vendor_Monthly_Data__c> vendorMonthlyDataList = new List<Vendor_Monthly_Data__c>();
		//START: D-1151 01/05/15 Added by J.Sarion – Update Courier and Paper Fee Grouping per Vendor per Pub per Sub
		List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
		List<Account> accountList = new List<Account>();
		Map<Id, Account> accountMap = new Map<Id, Account>();
		Map<Id, Set<String>> subIdToPubCodeMap = new Map<Id, Set<String>>();
		Map<Id, Map<String, Decimal>> vendorPubCourierChargeMap = new Map<Id, Map<String, Decimal>>();
		Map<Id, Map<String, Decimal>> vendorPubPaperFeeMap = new Map<Id, Map<String, Decimal>>();
		Map<Id, Map<String, Map<Id, Decimal>>> vendorPubSubCourierChargeMap = new Map<Id, Map<String, Map<Id, Decimal>>>();
		Map<Id, Map<String, Map<Id, Decimal>>> vendorPubSubPaperFeeMap = new Map<Id, Map<String, Map<Id, Decimal>>>();
		Set<Id> subSet = new Set<Id>();
		Set<Id> vendorSet = new Set<Id>();
		Decimal courierCharge = 0;
		Decimal paperFee = 0;
		
		for (Case caseObj :allScopes) {
			subSet.add(caseObj.Subscription_Name__c);
			
			if (caseObj.Subscription_Name__r.Vendor_1__c != null) { 
				vendorSet.add(caseObj.Subscription_Name__r.Vendor_1__c);
			}
		}
		
		if (!vendorSet.isEmpty()) {
			accountList = [SELECT Id, Vendor_Group__c, AccountNumber FROM Account WHERE Id IN :vendorSet];
		}
		
        for (Account acc :accountList) {
            accountMap.put(acc.Id , acc);
        }
		
		if (!subSet.isEmpty()) {
			subList = [SELECT Id, (SELECT PublicationCode__c FROM Zuora__Subscription_Product_Charges__r) FROM Zuora__Subscription__c WHERE Id IN :subSet];
		}

		for (Zuora__Subscription__c sub :subList) {
			for (Zuora__SubscriptionProductCharge__c spc :sub.Zuora__Subscription_Product_Charges__r) {
				if (subIdToPubCodeMap.containsKey(sub.Id)) {
					subIdToPubCodeMap.get(sub.Id).add(spc.PublicationCode__c);
				}
				else {
					subIdToPubCodeMap.put(sub.Id, new Set<String>());
					subIdToPubCodeMap.get(sub.Id).add(spc.PublicationCode__c);
				}
			}
		}

		for (Case caseObj :allScopes) {
			if (caseObj.Subscription_Name__r.Vendor_1__c != null && caseObj.Subscription_Name__c != null) {
				if (subIdToPubCodeMap.containsKey(caseObj.Subscription_Name__c)) {
					for (String pub :subIdToPubCodeMap.get(caseObj.Subscription_Name__c)) {
						//Courier Fee: Vendor Per Pub
						if (vendorPubCourierChargeMap.containsKey(caseObj.Subscription_Name__r.Vendor_1__c)) {
							if (vendorPubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).containsKey(pub)) {
								courierCharge = (caseObj.Courier_Fee__c != null ? caseObj.Courier_Fee__c : 0);
								courierCharge += vendorPubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub);
								vendorPubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).put(pub, courierCharge);
							}
							else {
								courierCharge = (caseObj.Courier_Fee__c != null ? caseObj.Courier_Fee__c : 0);
								vendorPubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).put(pub, courierCharge);
							}
						}
						else {
							courierCharge = (caseObj.Courier_Fee__c != null ? caseObj.Courier_Fee__c : 0);
							vendorPubCourierChargeMap.put(caseObj.Subscription_Name__r.Vendor_1__c, new Map<String, Decimal>());
							vendorPubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).put(pub, courierCharge);
						}
						
						//Courier Fee: Vendor Per Pub Per Sub
						if (vendorPubSubCourierChargeMap.containsKey(caseObj.Subscription_Name__r.Vendor_1__c)) {
							if (vendorPubSubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).containsKey(pub)) {
								if (vendorPubSubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).containsKey(caseObj.Subscription_Name__c)) {
									courierCharge = (caseObj.Courier_Fee__c != null ? caseObj.Courier_Fee__c : 0);
									courierCharge += vendorPubSubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).get(caseObj.Subscription_Name__c);
									vendorPubSubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).put(caseObj.Subscription_Name__c, courierCharge);
								}
								else {
									courierCharge = (caseObj.Courier_Fee__c != null ? caseObj.Courier_Fee__c : 0);
									vendorPubSubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).put(caseObj.Subscription_Name__c, courierCharge);
								}
							}
							else {
								courierCharge = (caseObj.Courier_Fee__c != null ? caseObj.Courier_Fee__c : 0);
								vendorPubSubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).put(pub, new Map<Id, Decimal>());
								vendorPubSubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).put(caseObj.Subscription_Name__c, courierCharge);
							}
						}
						else {
							courierCharge = (caseObj.Courier_Fee__c != null ? caseObj.Courier_Fee__c : 0);
							vendorPubSubCourierChargeMap.put(caseObj.Subscription_Name__r.Vendor_1__c, new Map<String, Map<Id, Decimal>>());
							vendorPubSubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).put(pub, new Map<Id, Decimal>());
							vendorPubSubCourierChargeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).put(caseObj.Subscription_Name__c, courierCharge);
						}
						
						//Paper Fee: Vendor Per Pub
						if (vendorPubPaperFeeMap.containsKey(caseObj.Subscription_Name__r.Vendor_1__c)) {
							if (vendorPubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).containsKey(pub)) {
								paperFee = (caseObj.Paper_Fee__c != null ? caseObj.Paper_Fee__c : 0);
								paperFee += vendorPubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub);
								vendorPubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).put(pub, paperFee);
							}
							else {
								paperFee = (caseObj.Paper_Fee__c != null ? caseObj.Paper_Fee__c : 0);
								vendorPubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).put(pub, paperFee);
							}
						}
						else {
							paperFee = (caseObj.Paper_Fee__c != null ? caseObj.Paper_Fee__c : 0);
							vendorPubPaperFeeMap.put(caseObj.Subscription_Name__r.Vendor_1__c, new Map<String, Decimal>());
							vendorPubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).put(pub, paperFee);
						}
						
						//Paper Fee: Vendor Per Pub Per Sub
						if (vendorPubSubPaperFeeMap.containsKey(caseObj.Subscription_Name__r.Vendor_1__c)) {
							if (vendorPubSubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).containsKey(pub)) {
								if (vendorPubSubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).containsKey(caseObj.Subscription_Name__c)) {
									paperFee = (caseObj.Paper_Fee__c != null ? caseObj.Paper_Fee__c : 0);
									paperFee += vendorPubSubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).get(caseObj.Subscription_Name__c);
									vendorPubSubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).put(caseObj.Subscription_Name__c, paperFee);
								}
								else {
									paperFee = (caseObj.Paper_Fee__c != null ? caseObj.Paper_Fee__c : 0);
									vendorPubSubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).put(caseObj.Subscription_Name__c, paperFee);
								}
							}
							else {
								paperFee = (caseObj.Paper_Fee__c != null ? caseObj.Paper_Fee__c : 0);
								vendorPubSubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).put(pub, new Map<Id, Decimal>());
								vendorPubSubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).put(caseObj.Subscription_Name__c, paperFee);
							}
						}
						else {
							paperFee = (caseObj.Paper_Fee__c != null ? caseObj.Paper_Fee__c : 0);
							vendorPubSubPaperFeeMap.put(caseObj.Subscription_Name__r.Vendor_1__c, new Map<String, Map<Id, Decimal>>());
							vendorPubSubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).put(pub, new Map<Id, Decimal>());
							vendorPubSubPaperFeeMap.get(caseObj.Subscription_Name__r.Vendor_1__c).get(pub).put(caseObj.Subscription_Name__c, paperFee);
						}
					}
				}
			}
		}
		
		for (Id vendor :vendorSet) {
			if (vendorPubCourierChargeMap.containsKey(vendor)) {
				for (String pub :vendorPubCourierChargeMap.get(vendor).keySet()) {
					vendorMonthlyDataList.add(courierPaperFeePub(vendorPubCourierChargeMap, accountMap, vendor, pub, null, null));
				}
			}
			
			if (vendorPubPaperFeeMap.containsKey(vendor)) {
				for (String pub :vendorPubPaperFeeMap.get(vendor).keySet()) {
					vendorMonthlyDataList.add(courierPaperFeePub(vendorPubPaperFeeMap, accountMap, vendor, pub, null, 'Miscellaneous'));
				}
			}
			
			if (vendorPubSubCourierChargeMap.containsKey(vendor)) {
				for (String pub :vendorPubSubCourierChargeMap.get(vendor).keySet()) {
					for (Id sub : vendorPubSubCourierChargeMap.get(vendor).get(pub).keySet()) {
						vendorMonthlyDataList.add(courierPaperFeePubSub(vendorPubSubCourierChargeMap, accountMap, vendor, pub, sub, null));
					}
				}
			}
			
			if (vendorPubSubPaperFeeMap.containsKey(vendor)) {
				for (String pub :vendorPubSubPaperFeeMap.get(vendor).keySet()) {
					for (Id sub : vendorPubSubPaperFeeMap.get(vendor).get(pub).keySet()) {
						vendorMonthlyDataList.add(courierPaperFeePubSub(vendorPubSubPaperFeeMap, accountMap, vendor, pub, sub, 'Miscellaneous'));
					}
				}
			}
		}

        try{
            insert vendorMonthlyDataList;
        }
        catch(Exception e){
            //error handling tbd
        }        
    }
	//END: D-1151 01/05/15 Added by J.Sarion

    global void finish(database.batchableContext BC){   
        String shortID = String.valueOf(BC.getJobId()).subString(0,15);
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :BC.getJobId()];

        if(batchJobSchedulerList.size() > 0)
        {
            BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
            batchJobScheduler.Status__c = 'SUCCESS';
            batchJobScheduler.End_Time__c = DateTime.now();
            update batchJobScheduler;           
            
            //System.debug('*********************** inside final'+ this.query);
            BatchServiceFacade a1F = new BatchServiceFacade();
            BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
            serviceRequestVO.setJobStatus(0);
            serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
            serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
            System.debug('################ before');
            a1F.delegateBatchCall(serviceRequestVO);
            System.debug('################ after');             
        }
    }

	//START: D-1151 01/05/15 Added by J.Sarion – Update Courier and Paper Fee Grouping per Vendor per Pub per Sub
	public Vendor_Monthly_Data__c courierPaperFeePub(Map<Id, Map<String, Decimal>> courierPaperFeePubMap, Map<Id, Account> accountMap, Id vendor, String pub, String sub, String amountType) {
		Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
		vmd.Amount_Before_GST__c = courierPaperFeePubMap.get(vendor).get(pub);
		vmd.Amount_Type__c = amountType;
		vmd.Credit_Debit__c = 'Debit';  
		vmd.GST_Amount__c = courierPaperFeePubMap.get(vendor).get(pub) * GlobalVariableClass.GST_AMOUNT;
		vmd.Vendor__c= vendor;
		vmd.Publication_Code__c = pub;
		vmd.Subscription__c = sub;
		
		if (accountMap.containsKey(vendor)) {
			vmd.Vendor_Group__c = accountMap.get(vendor).Vendor_Group__c;
			vmd.Vendor_Number__c = accountMap.get(vendor).AccountNumber;
		}
		
		return vmd;
	}
	
	public Vendor_Monthly_Data__c courierPaperFeePubSub(Map<Id, Map<String, Map<Id, Decimal>>> courierPaperFeePubSubMap, Map<Id, Account> accountMap, Id vendor, String pub, String sub, String amountType) {
		Vendor_Monthly_Data__c vmd = new Vendor_Monthly_Data__c();
		vmd.Amount_Before_GST__c = courierPaperFeePubSubMap.get(vendor).get(pub).get(sub);
		vmd.Amount_Type__c = amountType;
		vmd.Credit_Debit__c = 'Debit';  
		vmd.GST_Amount__c = courierPaperFeePubSubMap.get(vendor).get(pub).get(sub) * GlobalVariableClass.GST_AMOUNT;
		vmd.Vendor__c= vendor;
		vmd.Publication_Code__c = pub;
		vmd.Subscription__c = sub;
		
		if (accountMap.containsKey(vendor)) {
			vmd.Vendor_Group__c = accountMap.get(vendor).Vendor_Group__c;
			vmd.Vendor_Number__c = accountMap.get(vendor).AccountNumber;
		}
		
		return vmd;
	}
	//END: D-1151 01/05/15 Added by J.Sarion
}