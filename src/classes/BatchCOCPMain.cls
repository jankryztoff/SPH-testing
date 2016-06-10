/**
 * Class Name:  BatchCOCPMain
 * @author: Wenjun Zhu
 * Date: 18 March 2015
 * Requirement/Project Name: CRSM Project
 * @description: Main execution class for Mass Cover Price Change Batch. 
    This batch will auto-schedule itself few minutes later to process the remaining. This is to overcome the Zuora API Limit
 * History: 19/04/2016 [D-4382] Wenjun : Changes for supporting Daily / Monthly execution
 * History: 20/04/2016 [D-4806] Wenjun : Add Job Run Date parameter
 */
 
global class BatchCOCPMain implements Database.Batchable<sObject>, Database.AllowsCallouts {    
    
    global final String SUB_TYPE_PUB = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
    global Date jobRunDate;
    
    //Contructor for Full Run
    global BatchCOCPMain(Date executionDay){
        jobRunDate = executionDay;
    }
    
    global String getQueryString(){
        String query = ' Select Billing_Type__c, Subscription_Type_1__c, Zuora__CustomerAccount__c, Zuora__SubscriptionEndDate__c, ';
        query +=' Zuora__SubscriptionStartDate__c, Zuora__Zuora_Id__c, Contract_End_Date_1__c, Product_Code__c ';
        query +=' FROM Zuora__Subscription__c Where Subscription_Type_1__c = :SUB_TYPE_PUB AND For_Mass_Update__c = true Limit 1000';
        
        return query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        //Fetch all the eligible subscription records
        return Database.getQueryLocator(getQueryString());
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> lstSubsInScope) {
        List<Zuora.zApi.AmendRequest> listAmendmentRequest = new List<Zuora.zApi.AmendRequest>();
        Logger logger = new Logger(BatchCOCPMain.class.getName()); 

        for(Zuora__Subscription__c subRec : lstSubsInScope){
            subRec.For_Mass_Update__c = false;
        }
        
        listAmendmentRequest.addAll(DeliveryChargeHelper.createCoverPriceAmendmentReqs(lstSubsInScope, jobRunDate));
        
        if(!listAmendmentRequest.isEmpty())
        {
            try
            {
                Zuora.zApi zuorApi = new Zuora.zApi();
            
                if (!Test.isRunningTest()) { zuorApi.zlogin(); }
                
                //Send Amendment Request one by one
                for(Zuora.zApi.AmendRequest amendRequest :listAmendmentRequest)
                {
                    try
                    {
                        Zuora.zApi.AmendResult amendResult = zuorApi.zamend(new List<Zuora.zApi.AmendRequest>{amendRequest});
                        if(!amendResult.success)
                        {
                           System.debug(System.Label.ERR_CODC_AMEND + ' : ' + amendResult);
                           logger.log(false, System.Label.ERR_CODC_AMEND + ' : ' + amendResult);
                         }
                       
                    }
                    catch(Exception e){
                        logger.log(e);
                    }
                }
            }
            catch (Exception e) {
                logger.log(e);
            } 
        }
        
        //Uncheck the Mass Update
        SubscriptionTriggerHandler.preventExecution = true;
        Database.update(lstSubsInScope, false);
        
        //Save logs
        logger.save();
    }        
               
    global void finish(Database.BatchableContext BC) {   
        //Query for pending updates - this job will auto-schedule itself few minutes later if there is remaining 
        sObject[] lstPendingSubs = Database.query(getQueryString());
        //Schedule 5 minutes Batch Job to overcome Zuora Call Limit
        if(lstPendingSubs != null && !lstPendingSubs.isEmpty())
        {
            BatchCOCPMain batch = new BatchCOCPMain(jobRunDate);
            System.scheduleBatch(batch, 'Mass Change Cover Price', 1, 10);
        }
    }
}