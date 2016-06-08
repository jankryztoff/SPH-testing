/*
 * Class Name: STP050DXSendQuotesToZuoraBatch
 * @author: Kevin H. Evasco
 * Date: 06/16/2015
 * Project/Requirement: SPH Integration
 * @description This class performs zuora on demand sync through apex batchable.
 * 
 * History: 06/16/2015 Kevin Evasco Created Apex Batchable
 */


global class STP050DXSendQuotesToZuoraBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{    
    list<zqu.zQuoteUtil.ZBillingQuoteCollection> quotes = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
    ID AccountId; 
    
    //START D-3731 15-Oct-2015 LISEN - added logic for recovery and logging
    Set<String> selectiveIds = null;
    Boolean isApexJobSuccessful = true;
    
    global STP050DXSendQuotesToZuoraBatch(){
    
    }
    
    global STP050DXSendQuotesToZuoraBatch(Set<String> selectiveIds){
        this.selectiveIds = selectiveIds;
    }
    //END D-3731 15-Oct-2015 LISEN - added logic for recovery and logging

    global Database.QueryLocator start(Database.BatchableContext BC)
    {        
        Set<Id> orderIdSet = new Set<Id>();
        
        //START D-3731 15-Oct-2015 LISEN - added logic for recovery and logging 
        List<BT_CO_STPPRS_StopPressSubscription__c> stopPressList;
        if(selectiveIds != null){
            stopPressList = [SELECT Id, Order__r.Id, Order__r.Account__r.Id FROM BT_CO_STPPRS_StopPressSubscription__c WHERE Quotes_Created__c = false AND Validation_Status__c = 'Passed' AND Order__r.id = :selectiveIds];
        }else{
            stopPressList = [SELECT Id, Order__r.Id, Order__r.Account__r.Id FROM BT_CO_STPPRS_StopPressSubscription__c WHERE Quotes_Created__c = false AND Validation_Status__c = 'Passed'];
        }

        for(BT_CO_STPPRS_StopPressSubscription__c stopPressElement : stopPressList) {
            orderIdSet.add(stopPressElement.Order__r.Id);
            AccountId = stopPressElement.Order__r.Account__r.Id;        
        }
        //END D-3731 15-Oct-2015 LISEN - added logic for recovery and logging
        
        return Database.getQueryLocator([SELECT Id, Billing_Account__r.Zuora__Zuora_Id__c, Account__r.Id FROM Order__c WHERE Id IN :orderIdSet]);
    }   
    
    global void execute(Database.BatchableContext BC, List<Order__c> scope)
    {     
        
        //START D-3731 15-Oct-2015 LISEN - added logic for recovery and logging
        //START D-3920 6-Nov-2015 Johnmar Diamante - added isRunningTest() to skip logger error
        Logger logger;
        if(!Test.isRunningTest()){
        logger = new Logger(STP050DXSendQuotesToZuoraBatch.class.getName(), 'SP056', BC.getJobID());
         }
        //END D-3920 6-Nov-2015 Johnmar Diamante- added !Test.isRunningTest() to skip logger error 
        
        try{
            Order__c orderRecord = scope.get(0);
            Set<Id> orderLineItemIdSet = new Set<Id>();
            Boolean bCreateNewBillingAccount = false;
            List<Order_Line_Item__c> oliList = [SELECT Id, Order__r.Billing_Account_Creation_Mode__c FROM Order_Line_Item__c WHERE Order__c = :orderRecord.Id];
            for(Order_Line_Item__c oliElement : oliList) {
                Quote_Handler quoteHandler = new Quote_Handler();
                quoteHandler.Create_Quotes(orderRecord,'ESHOP Webservice',oliElement.Id);
                orderLineItemIdSet.add(oliElement.Id);
                if(oliElement.Order__r.Billing_Account_Creation_Mode__c == 'Create New Billing Account') {
                    bCreateNewBillingAccount = true;
                }
            }
            
            List<Id> lQuoteIds = new List<Id>();
            
            for (zqu__Quote__c QuoteList: [select id from zqu__Quote__c where Order_Line_Item_Number_1__c IN :orderLineItemIdSet AND zqu__Status__c = 'New']) { //END 09 October 2015 D-3629 Kevin Evasco - Only send 'New' quotes
                    lQuoteIds.add(QuoteList.id);
            }
            
            Set<Id> quoteIDSet = new Set<Id>();
            zqu.zQuoteUtil.ZBillingQuoteCollection quote = new zqu.zQuoteUtil.ZBillingQuoteCollection();
            quote.sfdcAccountId  = orderRecord.Account__r.Id;   
            
            if (bCreateNewBillingAccount){ 
                quote.zAccountId     = 'new';       
            }else{
                quote.zAccountId = orderRecord.Billing_Account__r.Zuora__Zuora_Id__c;           
            }
            
            list<zqu.zQuoteUtil.ZBillingQuoteRequest> lQReq = new list<zqu.zQuoteUtil.ZBillingQuoteRequest>();
            for(Id i: lQuoteIds){
                zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
                
                req.sfdcQuoteId = i;
                req.enableAccountAutoPay = false;
                lQReq.add(req);
                quoteIDSet.add(i);
            }
                    
            List<zqu__QuoteCharge__c> quoteChargesList = [SELECT Id, Name, zqu__Quote__c, zqu__ProductName__c, zqu__ProductRatePlanName__c, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Name FROM zqu__QuoteCharge__c WHERE zqu__Quote__c IN :quoteIDSet];
            
            Map<Id, List<zqu__QuoteCharge__c>> quote_quoteCharges_map = new Map<Id, List<zqu__QuoteCharge__c>>();
            
            for(zqu__QuoteCharge__c qCharge : quoteChargesList)
            {
                if(quote_quoteCharges_map.get(qCharge.zqu__Quote__c) == null)
                {
                    quote_quoteCharges_map.put(qCharge.zqu__Quote__c, new List<zqu__QuoteCharge__c>());
                }
                quote_quoteCharges_map.get(qCharge.zqu__Quote__c).add(qCharge);
            }
            
            for(Id idValue : quote_quoteCharges_map.keySet())
            {
                List<zqu__QuoteCharge__c> qChargeList = quote_quoteCharges_map.get(idValue);
                Integer counter = 1;
                for(zqu__QuoteCharge__c qCharge : qChargeList)
                {               
                    System.debug('Quote Charge #' + counter + ' for Quote ' + idValue + ': ' + qCharge);
                    counter++;
                }
            }
            
            system.debug('QUOTE REQUESTS:::' + lQReq);
            
            
            quote.quoteRequests = lQReq;
            quotes.add(quote);
            
            for(Id idValue : quote_quoteCharges_map.keySet())
            {       
                List<zqu.zChargeGroup> quoteChgGrps = zqu.zQuoteUtil.getChargeGroups(idValue);
                for( zqu.ZChargeGroup oneChgGrp : quoteChgGrps )
                {
                    system.debug('oneChgGrp.groupID = ' + oneChgGrp.groupID ) ;
                    system.debug('oneChgGrp.productName = ' + oneChgGrp.productName) ;
                    system.debug('oneChgGrp.rateplanName = ' + oneChgGrp.rateplanName ) ;
                    system.debug('oneChgGrp.zCharges size = ' + oneChgGrp.zCharges.size( ) ) ;
                }       
            }
            
            List<BT_CO_STPPRS_StopPressSubscription__c> stopPressList = [SELECT Id, Quotes_Created__c FROM BT_CO_STPPRS_StopPressSubscription__c WHERE Order__r.Id = :orderRecord.Id];
                for(BT_CO_STPPRS_StopPressSubscription__c stopPressElement : stopPressList) {
                    stopPressElement.Quotes_Created__c = true;              
                }
                update stopPressList;          
        }catch(Exception e){
            logger.logBatchFailure(e, scope);
            
            isApexJobSuccessful = false;
        }finally{
            logger.save();
        }
        //END D-3731 15-Oct-2015 LISEN - added logic for recovery and logging
    }
    
    global void finish(Database.BatchableContext BC)
    {       
        
        //START 09 October 2015 D-3629 Kevin Evasco - Seperate methods for callout and DML
        //START D-3271 22 July 2015 Kevin Evasco - SP056 should not fail even if there are no records passed by stoppress.
        BATCH_JOB_SCHEDULER__c batchJobScheduler = BatchJobHelper.delegateBatchCall(BC.getJobId(),true);
        
        if(quotes.size() > 0) {
            Set<String> zAccountId = new Set<String>();
            List<zqu.zQuoteUtil.zBillingResult> results = zqu.zQuoteUtil.sendToZBilling(quotes);
            
            list<string> lResult = new list<string>();
            set<string> zSubId = new set<string>();
            
            for (zqu.zQuoteUtil.zBillingResult result : results ) {
                //Returns are: Status:zAccountId:zSubscriptionId
                
                System.debug('RESULTS > '+ result);
                System.debug('SEND RESULT > '+ result.success + ':'+ result.zAccountId + ':'+result.zSubscriptionId);           
                lResult.add(result.success + ':'+ result.zAccountId + ':'+result.zSubscriptionId);
                zAccountId.add(result.zAccountId);
                zSubId.add(result.zSubscriptionId);                   
            }   
            
            ZuoraOnDemandSyncBatch zuoraOnDemanSyncBatch = new ZuoraOnDemandSyncBatch(zAccountId, AccountId);
            Database.executeBatch(zuoraOnDemanSyncBatch);
        }     
        
        if(batchJobScheduler != null)
            update batchJobScheduler;
        
        //END D-3271 22 July 2015 Kevin Evasco - SP056 should not fail even if there are no records passed by stoppress.        
        //END 09 October 2015 D-3629 Kevin Evasco - Seperate methods for callout and DML
    }
}