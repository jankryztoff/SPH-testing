/**
 * Class Name:  BatchAdhocSetSubActiveFlag
 * @author: Zhu, Wenjun
 * Date: 15 April 2015
 * Requirement/Project Name: CRSM Project
 * @description: Adhoc Batch to set Active flag for migrated / past subscriptions
 *
 *	Note: run the following code before executing this batch - clean the Sub active flag. If more than 10K, run multiple times
	List<Zuora__Subscription__c> lstSubs = [SELECT Id, Name, Is_Active__c FROM Zuora__Subscription__c WHERE Is_Active__c = true LIMIT 10000];
	for(Zuora__Subscription__c sub : lstSubs)
		sub.Is_Active__c = false;
	UPDATE lstSubs;
 */
 
global class BatchAdhocSetSubActiveFlag implements Database.Batchable<sObject> {    
    
	global final static String SUBTYPE_DEL = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    global final static String FULL_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
    global final static String MR_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    global final static String MR_POST = GlobalVariableClass.RECURRING_POSTPAID;
	
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT ID FROM Contact WHERE Recipient_Indicator__c = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> lstContacts){
        Set<ID> setRecipientIDs = new Set<ID>();
        for(Contact contact : lstContacts)
            setRecipientIDs.add(contact.Id);
        
        DeliveryChargeHelper.updateAllSubsActiveFlag(setRecipientIDs, Date.today());
    }
    
    global void finish(Database.BatchableContext BC) {  
    }
}