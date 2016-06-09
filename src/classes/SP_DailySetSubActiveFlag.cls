/**
 * Class Name:  SP_DailySetSubActiveFlag
 * @author: Zhu, Wenjun
 * Date: 15 April 2015
 * Requirement/Project Name: CRSM Project
 * @description: Daily Scheduled Batch to set Active flag for New Started and Expired Subscriptions
 *
 */
 
global class SP_DailySetSubActiveFlag implements Database.Batchable<sObject>, Database.AllowsCallouts {    
    
	global final static String SUBTYPE_DEL = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    global final static String FULL_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
    global final static String MR_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    global final static String MR_POST = GlobalVariableClass.RECURRING_POSTPAID;
	global final Date runDt;
	
	//START - D3673 19-Oct-2015 LISEN - Added logic for batch recovery
	Set<Id> selectiveIds = null;
	Boolean isApexJobSuccessful = true;
	
	global SP_DailySetSubActiveFlag(){
		this.runDt = Date.today();
	}
	//END - D3673 19-Oct-2015 LISEN - Added logic for batch recovery
    
    global SP_DailySetSubActiveFlag(Date inputDate)
    {
        this.runDt = inputDate;
    }
	
	//START - D3673 19-Oct-2015 LISEN - Added logic for batch recovery
	global SP_DailySetSubActiveFlag(Set<Id> selectiveIds, Date inputDate){
		this.selectiveIds = selectiveIds;
		this.runDt = inputDate;
	}
	//END - D3673 19-Oct-2015 LISEN - Added logic for batch recovery
    
    global List<Contact> start(Database.BatchableContext BC){
        Set<ID> setRecipientIDs = new Set<ID>();
		Date yesterday = this.runDt.addDays(-1);
        
		//START - D3673 19-Oct-2015 LISEN - Added logic for batch recovery
        //Check if batch runs by selective contact ids and date
		if(selectiveIds != null){
			for(Zuora__Subscription__c sub: [SELECT Id, Name, Recipient_Contact__c FROM Zuora__Subscription__c 
                        WHERE (Zuora__SubscriptionEndDate__c = :yesterday OR Zuora__SubscriptionStartDate__c = :runDt)
						AND Recipient_Contact__c = :selectiveIds])
            setRecipientIDs.add(sub.Recipient_Contact__c);
		}else{
			//Batch runs by provided date
			//Query All Newly Started / Expired Subscriptions. Assumption : < 50K
			for(Zuora__Subscription__c sub: [SELECT Id, Name, Recipient_Contact__c FROM Zuora__Subscription__c 
                        WHERE Zuora__SubscriptionEndDate__c = :yesterday OR Zuora__SubscriptionStartDate__c = :runDt])
            setRecipientIDs.add(sub.Recipient_Contact__c);
		}
		//END - D3673 19-Oct-2015 LISEN - Added logic for batch recovery
		
        return [SELECT ID FROM Contact WHERE Recipient_Indicator__c = true AND ID in : setRecipientIDs];
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> lstContacts){
		//START - D3673 19-Oct-2015 LISEN - Added logic for batch recovery
		Logger logger = new Logger(STP050DXSendQuotesToZuoraBatch.class.getName(), 'SP056', BC.getJobID());
		try{
			Set<ID> setRecipientIDs = new Set<ID>();
			for(Contact contact : lstContacts)
				setRecipientIDs.add(contact.Id);
			
			DeliveryChargeHelper.updateAllSubsActiveFlag(setRecipientIDs, this.runDt);
		}catch(Exception e){
			logger.logBatchFailure(e, lstContacts);
			
			isApexJobSuccessful = false;
		}finally{
			logger.save();
		}
		//END - D3673 19-Oct-2015 LISEN - Added logic for batch recovery
    }
    
    global void finish(Database.BatchableContext BC) {  
	   /***************************** Update Batch Job Scheduler **************************/   
		//START - D3673 19-Oct-2015 LISEN - Added logic for batch recovery
		if(!isApexJobSuccessful){
        	BatchJobHelper.updateJobStatus(BC.getJobId(), false); 
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
		//END - D3673 19-Oct-2015 LISEN - Added logic for batch recovery
    }
}