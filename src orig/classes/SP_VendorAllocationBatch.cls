/**
* Class Name: SP_VendorAllocationBatch 
* @author: Jayson Sarion
* Date: 01/12/2014
* Requirement/Project Name: Singapore Press Holdings
* @description Batch class that updates the vendor of subscription when the effective date
  of Vendor Assignment record is equal to Date today
* History: D-2905 05/14/2015 Update class to refer to Case for the Subscriptions and Subscription Vendors to be updated.
*/
//START: D-4349 1-20-2016 Added by Kristine Balaoing - added logging mechanism
global class SP_VendorAllocationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bc- predefined parameter 
    * @return list of objects from Address Assignment Object
    */
    
  //START D-1904 2/2/2015 Added By J.Sarion - Added callout to zuora to update vendor
    List<Map<String, Object>> subMapList = new List<Map<String, Object>>();
  //END D-1904 2/2/2015 Added By J.Sarion
  
    //START D-3604 9/23/2015 Added By C. Lin - Constructor for specific Address Assignment record
    Set<Id> setBillingAccountId = new Set<Id>();
    Date referenceDate;
    Id specificCaseId;
    Boolean isApexJobSuccessful = true; 
    //END: D-4349 1-20-2016 Added by Kristine Balaoing 
    
    global SP_VendorAllocationBatch()
    {
        referenceDate = date.today();
    }
    
    global SP_VendorAllocationBatch(Date inputDt)
    {
        referenceDate = inputDt;
    }
    
    global SP_VendorAllocationBatch(Id caseId)
    {
        specificCaseId = caseId;
    }
    //END D-3604 9/23/2015 Added By C. Lin
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Date dt = date.today(); //START END D-3604 9/23/2015 Added By C. Lin - Remove
    //START D-1904 2/2/2015 Added By J.Sarion - Added callout to zuora to update vendor
        //START D-3222 7/13/2015 Added By C. Lin - Added Subscription__r.Order_Line_Item_Number_1__c, CreatedDate
        
        //START D-3604 9/23/2015 Added By C. Lin - Modified Query for Batch Job Recovery. Add Subscription__r.Zuora__CustomerAccount__c.
        String query = 'SELECT Id, Effective_Date__c, Vendor__c, CreatedDate, (SELECT Id, Subscription__c, Subscription__r.Zuora__Zuora_Id__c, Subscription__r.Order_Line_Item_Number_1__c, Subscription__r.Zuora__CustomerAccount__c FROM Case_Subscriptions__r), (SELECT Id, Subscription_Vendor__c FROM Case_Vendor_Subscriptions__r) FROM Case WHERE ';
        
        if(referenceDate != null){
            query += 'Effective_Date__c = :referenceDate';
        }else if(specificCaseId != null){
            query += 'Id = :specificCaseId';
        }
        
        return Database.getQueryLocator(query);
        //END D-3604 9/23/2015 Added By C. Lin
        
        //END D-3222 7/13/2015 Added By C. Lin
    //END D-1904 2/2/2015 Added By J.Sarion
    }
    
    /* @description Executes the business logic and creates Usage object
     * 
     * @param BC- predefined parameter 
     * @param scope - a list of sObjects from the initial database query
     * @return void
     */  
    global void execute(Database.BatchableContext BC, List<Case> scope) {
        Map<String, Object> subMap;
        Map<Id, Id> subVenIdToVendorMap = new Map<Id, Id>();
        List<Map<String, Object>> subMapList = new List<Map<String, Object>>();
        List<Subscription_Vendor__c> subVenList = new List<Subscription_Vendor__c>();
        Set<Id> subIdVenSet = new Set<Id>();
        //START D-3222 7/13/2015 Added By C. Lin - For delivery and postage sub
        Set<Id> oliSet = new Set<Id>();
        Map<Id, Id> oliToNewVendorMap = new Map<Id, Id>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        Map<String, Case> subToCaseMap = new Map<String, Case>();
        //START D-3222 7/13/2015 Added By C. Lin
        
        //START D-3222 7/13/2015 Added By C. Lin - For delivery and postage sub
        //START: D-4349 1-20-2016 Added by Kristine Balaoing - added logger
        Logger logger;
        
        if(!Test.isRunningTest()){
            logger = new Logger(SP_VendorAllocationBatch.class.getName(), 'SP048', BC.getJobID()); 
        }
        
        try{
            for (Case c :scope) {
                for (Case_Subscription__c caseSub :c.Case_Subscriptions__r) {
                    //START D-3604 9/23/2015 Added By C. Lin - Add Auto Sync after batch runs
                    setBillingAccountId.add(caseSub.Subscription__r.Zuora__CustomerAccount__c);
                    //END D-3604 9/23/2015 Added By C. Lin
                    
                    if(subToCaseMap.containsKey(caseSub.Subscription__r.Zuora__Zuora_Id__c)){
                        if(c.CreatedDate > subToCaseMap.get(caseSub.Subscription__r.Zuora__Zuora_Id__c).CreatedDate){
                            subToCaseMap.put(caseSub.Subscription__r.Zuora__Zuora_Id__c, c);
                            
                            if(caseSub.Subscription__r.Order_Line_Item_Number_1__c != null){
                                oliSet.add(caseSub.Subscription__r.Order_Line_Item_Number_1__c);
                                oliToNewVendorMap.put(caseSub.Subscription__r.Order_Line_Item_Number_1__c, c.Vendor__c);
                            }
                        }
                    }else{
                        subToCaseMap.put(caseSub.Subscription__r.Zuora__Zuora_Id__c, c);
                        
                        if(caseSub.Subscription__r.Order_Line_Item_Number_1__c != null){
                            oliSet.add(caseSub.Subscription__r.Order_Line_Item_Number_1__c);
                            oliToNewVendorMap.put(caseSub.Subscription__r.Order_Line_Item_Number_1__c, c.Vendor__c);
                        }
                    }
                }
                
                for (Case_Vendor_Subscription__c caseSubVen :c.Case_Vendor_Subscriptions__r) {
                    subIdVenSet.add(caseSubVen.Subscription_Vendor__c);
                    subVenIdToVendorMap.put(caseSubVen.Subscription_Vendor__c, c.Vendor__c);
                }
            }
            //END D-3222 7/13/2015 Added By C. Lin
            
            //START D-3222 7/13/2015 Added By C. Lin - For delivery and postage sub
            for (String subZuoraId : subToCaseMap.keySet()) {
                subMap = new Map<String, Object>();
                
                subMap.put('Id', subZuoraId);
                subMap.put('Vendor__c', subToCaseMap.get(subZuoraId).Vendor__c);
                
                subMapList.add(subMap);
            }
            
            subList = [SELECT Id, Order_Line_Item_Number_1__c, Zuora__Zuora_Id__c, Vendor_1__c FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c IN :oliSet AND Subscription_Type_1__c = 'Delivery'];
            
            for(Zuora__Subscription__c subscription : subList){
                subMap = new Map<String, Object>();
                
                subMap.put('Id', subscription.Zuora__Zuora_Id__c);
                if(oliToNewVendorMap.containsKey(subscription.Order_Line_Item_Number_1__c)){
                    subMap.put('Vendor__c', oliToNewVendorMap.get(subscription.Order_Line_Item_Number_1__c));
                }
                
                subMapList.add(subMap);
            }
            //END D-3222 7/13/2015 Added By C. Lin
            
            if (!subIdVenSet.isEmpty())
                subVenList = [SELECT Id, Vendor__c FROM Subscription_Vendor__c WHERE Id IN :subIdVenSet];
            
            for (Subscription_Vendor__c subVen :subVenList) {
                if (subVenIdToVendorMap.containsKey(subVen.Id))
                    subVen.Vendor__c = subVenIdToVendorMap.get(subVen.Id);
            }
        
            if(!subMapList.isEmpty()) {
                ZuoraCallOut zCallOut = new ZuoraCallOut();
                List<Map<String,String>> returnVar = zCallOut.updateZObjects(subMapList, 'Subscription'); 
                system.debug('>>>>>>>>>>>>>>>returnVar' + returnVar);
                for(Map<String,String> result :returnVar){ 
                    if (result.get('Status') == 'Success') {
                        String zuoraId;
                        zuoraId = result.get('Id');
                        system.debug('>>>>> updateZuoraId' + zuoraId);
                    }
                    else {
                        system.debug('>>>>> updateFailed' + result.get('Message'));
                    }
                }
            }
            //START D-3043 5/29/2015 Added By C. Lin - Fix callout issue. Move DML after callout.
            try {
                update subVenList;
            } catch (Exception e) {
                system.debug(e);
            }
            //END D-3043 5/29/2015 Added By C. Lin
        }catch(Exception e){
            logger.logBatchFailure(e, scope);
            logger.save();
            
            isApexJobSuccessful = false;
            
        }
        //END: D-4349 1-20-2016 Added by Kristine Balaoing
    }
    
    global void finish(database.batchableContext BC){
        
        //START: D-4349 1-20-2016 Added by Kristine Balaoing - added logging mechanism
        Logger loggerFinish; 
        //START: D-4373 2-4-2016 Added by Kristine Balaoing - changed logging details   
        if(!Test.isRunningTest()){
        loggerFinish = new Logger(SP_VendorAllocationBatch.class.getName(), 'SP048');
        }
        //END: D-4373 2-4-2016 Added by Kristine Balaoing
        
        try{
            //START D-3604 9/23/2015 Added By C. Lin - Add Auto Sync after batch runs
            //Perform Zuora Sync
            if(!setBillingAccountId.isEmpty()){
                Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
                syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
                syncManager.syncObjectIdSet  = setBillingAccountId;
                //START: D-4373 2-4-2016 Added by Kristine Balaoing - set emailNotif to false to avoid uncommitted work pending issue. 
                syncManager.emailNotificationEnabled = false;
                //END: D-4373 2-4-2016 Added by Kristine Balaoing
                List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
                System.debug('>>>>> Sync Result:' + syncResult);
            }
            //END D-3604 9/23/2015 Added By C. Lin
            
            if(!isApexJobSuccessful){
                BatchJobHelper.updateJobStatus(BC.getJobId(), false); //START-END KRITHIKA DHARMARAJAN 4/17/2015 D-2770
            }else{
                BatchJobHelper.updateJobStatus(BC.getJobId(), true);
            }
        }catch(Exception e){
            loggerFinish.log(e);
            loggerFinish.save();
        }
        //END: D-4349 1-20-2016 Added by Kristine Balaoing  
    }
}