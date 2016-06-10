/**
 * Class Name:  SP_UpdateCoverPriceOnSubscription
 * @author: Joban Bir SIngh
 * Date: 18 March 2015
 * Requirement/Project Name: CRSM Project
 * @description: This will update all the subsriptions with the cover price that the user updates in Zuora.
 * History: D-2699 08/04/15 Wenjun : disable Sync Email and move varibles to execute method
 */
 
global class SP_UpdateCoverPriceOnSubscription implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts {    

    global final String PRODUCTCODESTRING;
    global List<String> listProductCodes = new List<String>();
    global String query;
    
    global SP_UpdateCoverPriceOnSubscription(String productCode){
      PRODUCTCODESTRING = productCode; 
      listProductCodes = PRODUCTCODESTRING.split(',');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {     
        //Fetch all the eligible subscription records
        query = ' Select Billing_Type__c, Subscription_Type_1__c, Zuora__CustomerAccount__c, Zuora__SubscriptionEndDate__c, ';
        query +=' Zuora__SubscriptionStartDate__c, Zuora__Zuora_Id__c, Contract_End_Date_1__c, Product_Code__c, CreatedDate ';
        query +=' FROM Zuora__Subscription__c ';
        query +=' Where Product_Code__c in :listProductCodes AND Zuora__Status__c = \'Active\' '; 
        query +=' AND (Billing_Type__c = \'Recurring Prepaid\' OR Billing_Type__c = \'Recurring Postpaid\')';
        //START 30/04/15 UD-0776 Wenjun : change condition after Custom Sync implementation
        query +=' AND Subscription_Type_1__c = \'Publication\' AND (LastModifiedDate != Today OR Zuora__Version__c = 1)';
        //END 30/04/15 UD-0776 Wenjun
        query +=' AND (Zuora__TermSettingType__c = \'EVERGREEN\' OR Zuora__SubscriptionEndDate__c > THIS_MONTH) Limit 1000';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope) {
        //START D-3085 JTeves 6/10/2015 Try/Catch modification
        List<Exception> exceptionList = new List<Exception>();
        //END D-3085 JTeves 6/10/2015 Try/Catch modification
        List<Zuora.zApi.AmendRequest> listAmendmentRequest = new List<Zuora.zApi.AmendRequest>();
        Set<Id> setBillingAccountId = new Set<Id>();
        List<Zuora__Subscription__c> listSubscriptionRecords = new List<Zuora__Subscription__c>();
            
        for(Zuora__Subscription__c subRec : scope){
            //START D-3003 Wenjun 21/05/15 : To support Evergreen
            if(subRec.Contract_End_Date_1__c != subRec.Zuora__SubscriptionEndDate__c || subRec.Zuora__SubscriptionEndDate__c == NULL)
            {
                listSubscriptionRecords.add(subRec);
            }
            //END D-3003 Wenjun 21/05/15
            if(subRec.Zuora__CustomerAccount__c != null && subRec.Contract_End_Date_1__c != subRec.Zuora__SubscriptionEndDate__c)
                setBillingAccountId.add(subRec.Zuora__CustomerAccount__c);
        }
        if(!listSubscriptionRecords.isEmpty()){
            listAmendmentRequest.addAll(DeliveryChargeHelper.createCoverPriceAmendmentReqs(listSubscriptionRecords));
        }
        Zuora.zApi zuorApi = new Zuora.zApi();
		//START D-3268 Modified By C.I.Salas - Test Coverage
		if (!Test.isRunningTest()) {
			zuorApi.zlogin();
		}
		//END D-3268 Modified By C.I.Salas - Test Coverage
        if(!listAmendmentRequest.isEmpty()){
            //Send Amendment Request one by one
            for(Zuora.zApi.AmendRequest amendRequest :listAmendmentRequest)
            {
            //START D-3085 MGaelo 6/5/2015 Try/Catch modification
                try{
                Zuora.zApi.AmendResult amendResult = zuorApi.zamend(new List<Zuora.zApi.AmendRequest>{amendRequest});
                if(!amendResult.success)
                   System.debug(Logginglevel.ERROR, System.Label.ERR_CODC_AMEND + ' : ' + amendResult);
                } catch (exception e) {
                    //START D-3085 JTeves 6/10/2015 Try/Catch modification
                    exceptionList.add(e);
                    //END D-3085 JTeves 6/10/2015 Try/Catch modification
                 } 
            }
            //END D-3085 MGaelo 6/5/2015 Try/Catch modification
        }
        //Perform Zuora Sync
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
        syncManager.syncObjectIdSet  = setBillingAccountId;
        //Disable Email Notification for On-demand Sync
        syncManager.emailNotificationEnabled = false;
        
        List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
        
        //START D-3085 JTeves 6/10/2015 Try/Catch modification
        if(!exceptionList.isEmpty()) {
            ExceptionLogger.log(exceptionList);
        }
        //END D-3085 JTeves 6/10/2015 Try/Catch modification
    }        
               
    global void finish(Database.BatchableContext BC) {   
        //Query for pending updates - this job may be scheduled one more time due to Zuora Sync. 
        //But the job will do nothing if the Sync result is back within the period
        system.debug('Query------------'+query);
        sObject[] lstPendingSubs = Database.query(query);
        
        //Schedule 10 minutes Batch Job to overcome Zuora Call Limit
        if(lstPendingSubs != null && !lstPendingSubs.isEmpty())
        {
            SP_UpdateCoverPriceOnSubscription batch = new SP_UpdateCoverPriceOnSubscription(PRODUCTCODESTRING);
            System.scheduleBatch(batch, 'Change of CoverPrice', 10, 10);
        }
    }
}