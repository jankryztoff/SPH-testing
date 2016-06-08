/*
* Class Name: SP_CancelFuturePStop
* @Author: Wenjun Zhu
* Date: 21 June 2015
* Requirement/Project Name: CRSM Project
* @Description Batch Apex Class to cancel Subscriptions at PStop Request Date - 1
* @History D-3150 21/06/15 Wenjun - Created batchable class
* @History SIT Hotfix 23/06/15 Wenjun - Add on-demand sync
*
*/
global class SP_CancelFuturePStop implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{ 
    Date referenceDate; 
    final Static String STOP_SUB_CATEGORY = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;
    final Static String STOP_SUB_STATUS = GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION;
    //START D-3194 07/01/2015 Added by J.Sarion - Added criteria for Sub Status equals Provisioning
    final Static String STOP_SUB_STATUS_PROVISIONING = GlobalVariableClass.SUB_STATUS_PROVISIONING;
	//END D-3194 07/01/2015 Added by J.Sarion - Added criteria for Sub Status equals Provisioning
	
    Set<Id> setBillingAccountId;
    
    //Default Constructor
    global SP_CancelFuturePStop()
    {
        referenceDate = Date.today().addDays(1);
        setBillingAccountId = new Set<Id>();
    }
    
    //Constructor with input of PSTOP Date to process
    global SP_CancelFuturePStop(Date inputDt)
    {
        referenceDate = inputDt;
        setBillingAccountId = new Set<Id>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Query all the PStop Cases with Sub Status as "Ready For Submission"
        String query = 'SELECT Id, Case__c, Order__c, Subscription__c, Subscription__r.Zuora__CustomerAccount__c,Stop_Request_Date__c ';
        query       += 'FROM Order_Line_Item__c ';
        query       += 'WHERE Case__r.Sub_Category__c = : STOP_SUB_CATEGORY ';
        query       += 'AND (Case__r.Sub_Status__c = :STOP_SUB_STATUS OR Case__r.Sub_Status__c = :STOP_SUB_STATUS_PROVISIONING)'; //START-END D-3194 07/01/2015 Added by J.Sarion - Added criteria for Sub Status equals Provisioning
        query       += 'AND Stop_Request_Date__c <= : referenceDate AND Stop_Request_Date__c > TODAY';
        
        return Database.getQueryLocator(query);
    }
    
    //Logic copied from StopSubscriptionButton
    global void execute(Database.BatchableContext BC, List<Order_Line_Item__c> lstOlis){
        Map<ID, Date> mapSubIDToStopDate = new Map<ID, Date>();
        List<Case> lstCasesToUpd = new List<Case>();
        List<Order__c> lstOrdersToUpd = new List<Order__c>();
        List<exception> lstExceptions = new List<exception>();
        
        for(Order_Line_Item__c oli : lstOlis)  
        {
            mapSubIDToStopDate.put(oli.Subscription__c, oli.Stop_Request_Date__c);
            setBillingAccountId.add(oli.Subscription__r.Zuora__CustomerAccount__c);
        }
            
        if (!mapSubIDToStopDate.isEmpty()) 
        {
            try {
                SM_SubscriptionCancellationHelper.cancelSubscriptions(mapSubIDToStopDate, GlobalVariableClass.SUBJECT_STOP_SUBSCRIPTION);
                
                if (SM_SubscriptionCancellationHelper.isSuccess == false) 
                {
                    for(Order_Line_Item__c oli : lstOlis) 
                    {
                        Case stopCase = new Case (ID = oli.Case__c);
                        stopCase.Sub_Status__c = 'Zuora Issue - Subscription Cancellation';
                        lstCasesToUpd.add(stopCase);
                        
                        Order__c order = new Order__c(ID = oli.Order__c);
                        order.Status__c = GlobalVariableClass.SUB_STATUS_CLOSE;
                        lstOrdersToUpd.add(order);
                    }
                    
                    try {
                        if(!lstCasesToUpd.isEmpty())
                            update lstCasesToUpd;
                        if(!lstOrdersToUpd.isEmpty())
                            update lstOrdersToUpd;
                    } catch (Exception dmlException) {
                        lstExceptions.add(dmlException);
                    } 
                }
            } catch (Exception e){
                lstExceptions.add(e);
            }
        }
        
        if(!lstExceptions.isEmpty())
            ExceptionLogger.log(lstExceptions);
    }
    
    global void finish (Database.BatchableContext BC){ 
        //Perform Zuora Sync
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
        syncManager.syncObjectIdSet  = setBillingAccountId;
        syncManager.emailNotificationEnabled = false;
        
        List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
        System.debug('>>>>> Sync Result:' + syncResult);
        
        //Update Job Status
        BatchJobHelper.updateJobStatus(BC.getJobId());
    } 
}