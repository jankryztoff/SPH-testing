/**
* Class Name: SP_AddressAssignmentCallOut 
* @author: Jayson Sarion
* Date: 01/14/2014
* Requirement/Project Name: Singapore Press Holdings
* @description Batch class extension of BatchAddressAssignmentEffectiveDate
* History:
*/
global class SP_AddressAssignmentCallOut implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    global final List<Map<String, Object>> subMapList;
    
    //START D-3243 07/16/2015 Added by J.Sarion - Get Job ID
    global final Id JOB_ID;
    //START UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
    global Map<ID, Set<String>> mapNewContactToSub = new Map<ID, Set<String>>();
    //END UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
    global Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
    //END D-3243 07/16/2015 Added by J.Sarion - Get Job IDLEntity
    
    //START UD-2890 9/25/2015 Added By C. Lin - Add Auto Sync after batch runs
    global Set<Id> setBillingAccountId = new Set<Id>();
    //END UD-2890 9/25/2015 Added By C. Lin
    
    public SP_AddressAssignmentCallOut(List<Map<String, Object>> subMapList)
    {
        this.subMapList = subMapList;
    }
    
    //START D-3243 07/16/2015 Added by J.Sarion - Pass JobId
    //START UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to List of String
    public SP_AddressAssignmentCallOut(List<Map<String, Object>> subMapList, Map<ID, Set<String>> mapNewContactToSub, Map<String, Id> mapDelZuoraIdToOldAddressId, Id jobID)
    {
        //END UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to List of String
        JOB_ID = jobID;
        this.subMapList = subMapList;
        this.mapNewContactToSub = mapNewContactToSub;
        this.mapDelZuoraIdToOldAddressId = mapDelZuoraIdToOldAddressId;
    }
    //END D-3243 07/16/2015 Added by J.Sarion - Pass JobId

   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bc- predefined parameter 
    * @return list of objects from Address Assignment Object
    */  
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id FROM Account LIMIT 1]);
    }
    
    /* @description Executes the callout to zuora
     * 
     * @param BC- predefined parameter 
     * @param scope - a list of sObjects from the initial database query
     * @return void
     */  
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        Logger logger = new Logger(SP_AddressAssignmentCallOut.class.getName(),'SP000'); //START END D-1011 MD-28 Dags 18/06/15
        
        //START UD-2890 9/25/2015 Added By C. Lin - Add Auto Sync after batch runs
        Set<String> setSubZuoraId = new Set<String>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        //END UD-2890 9/25/2015 Added By C. Lin
        
        //START UD-2162 08/14/2015 Added by J.Sarion - 50 zObjects per update callout
        if (!subMapList.isEmpty()) {
            List<Map<String, Object>> subMapList_batchOfMax = new List<Map<String, Object>>();
            Integer REQUEST_MAX_USAGE = 50;
            Integer counter = 0;
            ZuoraCallOut updateCallOut = new ZuoraCallOut();
            
            for (counter = 0; counter < subMapList.size(); counter++) {     
                subMapList_batchOfMax.add(subMapList[counter]);
                
                //START UD-2890 9/25/2015 Added By C. Lin - Add Auto Sync after batch runs
                setSubZuoraId.add(String.valueOf(subMapList[counter].get('Id')));
                //END UD-2890 9/25/2015 Added By C. Lin
                
                if (math.mod(counter + 1, REQUEST_MAX_USAGE) == 0 || counter == (subMapList.size() - 1)) {
                    for (Map<String, String> result : updateCallOut.updateZObjects(subMapList_batchOfMax, 'Subscription')) {
                        if (result.get('Status') == 'Success') {
                            String zuoraId;
                            zuoraId = result.get('Id');
                        }
                        else {
                            //START D-1011 MD-28 Dags 18/06/15 - Using Logger                 
                            logger.log(false,result.get('Message'));
                            //END D-1011 MD-28 Dags 18/06/15 - Using Logger                                     
                        }
                    }
                    
                    subMapList_batchOfMax = new list<map<string, object>>();
                }
            }
            
            //START UD-2890 9/25/2015 Added By C. Lin - Add Auto Sync after batch runs
            subList = [SELECT Id, Zuora__CustomerAccount__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :setSubZuoraId AND Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Publication'];
            
            for(Zuora__Subscription__c sub : subList){
                if(sub.Zuora__CustomerAccount__c != null){
                    setBillingAccountId.add(sub.Zuora__CustomerAccount__c);
                }
            }
            //END UD-2890 9/25/2015 Added By C. Lin
            
            Logger.save();//START END D-1011 MD-28 Dags 18/06/15
        }
        //END UD-2162 08/14/2015 Added by J.Sarion - 50 zObjects per update callout
    }
    
    global void finish(database.batchableContext BC){   
        //START D-3243 07/16/2015 Added by J.Sarion - Update Job Status. Call BatchCOADeliveryCharge
        if(!mapNewContactToSub.isEmpty()){
            BatchCOADeliveryCharge delChargeBatch = new BatchCOADeliveryCharge(mapNewContactToSub, mapDelZuoraIdToOldAddressId, JOB_ID);
            Database.executeBatch(delChargeBatch, 10);
        }
        else{
            //START UD-2890 9/25/2015 Added By C. Lin - Add Auto Sync after batch runs
            //Perform Zuora Sync
            //START D-3651 10/02/2015 Added by J.Sarion - set emailNotificationEnabled to false
            Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
            syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
            syncManager.syncObjectIdSet  = setBillingAccountId;
            syncManager.emailNotificationEnabled = false;
            
            List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
            //END D-3651 10/02/2015 Added by J.Sarion - set emailNotificationEnabled to false
            //END UD-2890 9/25/2015 Added By C. Lin
            
            BatchJobHelper.updateJobStatus(JOB_ID);
        }
        /*
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
        */
        //END D-3243 07/16/2015 Added by J.Sarion - Update Job Status
    }
}