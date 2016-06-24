/*
* Class Name: SP_CancelSubscriptionInZuora
* @Author: Karl Tan / Charles Lin
* Date: 08 July 2015
* Requirement/Project Name: CRSM Project
* @Description Batch Apex Class to cancel Subscriptions at PStop Request Date - 1
* Cancel Subscription
* History: D-3228 Updated Class for COS on 7/10/2015 by Charles Lin
* History: D-3537 Hotfix Wenjun 10/Sep/15: Process all case status i.e. filter by Sub End Date only; Fix issue for normal expiration
*/

global class SP_CancelSubscriptionInZuora implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{ 
    Date referenceDate;
    Date refDateAddOne;
    Set<Id> setBillingAccountId;
    final Static String STOP_SUB_CATEGORY = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;    
    final Static String STOP_SUB_STATUS = GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION;
    final Static String STOP_SUB_STATUS_PROVISIONING = GlobalVariableClass.SUB_STATUS_PROVISIONING;
    final Static String STATUS_CANCEL = globalVariableClass.STATUS_CANCELLED;
    final Static String SUB_STATUS_SUBS_CREATED = GlobalVariableClass.SUB_STATUS_SUBS_CREATED;
    final Static String CHANGE_OF_SUBSCRIPTION = GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION;
    final Static String STOP_SUBSCRIPTION = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
    
    //START D-3675 LISEN 10/9/2015 - Enable on demand batch based on selective subscriptions or accounts
    List<String> selectiveIds = null;
    Integer type;
    final Static Integer SELECTIVE_SUBSCRIPTIONS = 1;
    final Static Integer SELECTIVE_ACCOUNTS = 2;
    
    //START D-3675 10/14/2015 Added By C. Lin - Add isApexJobSuccessful
    Boolean isApexJobSuccessful = true;
    //END D-3675 10/14/2015 Added By C. Lin
    //END D-3675 LISEN 10/9/2015 - Enable on demand batch based on selective subscriptions or accounts
    
    //START D-3513 Bill Run Hotfix Wenjun 04/Sep/15 - Change Filter Criteria and Constructors to support test simulation
    Boolean forAllPastData;
    String subIDToCancel;
    
    //Default Constructor
    global SP_CancelSubscriptionInZuora()
    {
        referenceDate = Date.today();
        refDateAddOne = referenceDate.addDays(1);
        setBillingAccountId = new Set<Id>();
        forAllPastData = true;
        
    }
    
    //Constructor with input of PSTOP Date to process
    global SP_CancelSubscriptionInZuora(Date inputDt, Boolean runForFullPast)
    {
        referenceDate = inputDt;
        refDateAddOne = referenceDate.addDays(1);
        setBillingAccountId = new Set<Id>();
        forAllPastData = runForFullPast;
        
    }
    
    //Constructor for cancelling specific subscription
    global SP_CancelSubscriptionInZuora(String subID)
    {
        subIDToCancel = subID;
        setBillingAccountId = new Set<Id>();
    }
    
    //START D-3675 LISEN 10/9/2015 - Enable on demand batch based on selective subscriptions or accounts
    //Constructor for cancelling specific subscriptions or account numbers
    global SP_CancelSubscriptionInZuora(List<String> selectiveIds, Integer type, Date inputDt)
    {
        referenceDate = inputDt;
        this.selectiveIds = selectiveIds;
        this.type = type;
        setBillingAccountId = new Set<Id>();
    }
    //END D-3675 LISEN 10/9/2015 - Enable on demand batch based on selective subscriptions or accounts
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Query all Active subscriptions with end date = reference date or end date = reference date + 1
        String query = 'SELECT Id, Name, Zuora__SubscriptionEndDate__c,Zuora__CustomerAccount__c, Zuora__Zuora_Id__c, Order_Line_Item_Number_1__c, '; 
        query       += ' Order_Line_Item_Number_1__r.Order__r.Subscription__c, Order_Number_1__c, Term_Length__c, Zuora__SubscriptionStartDate__c, Zuora__TermSettingType__c ';
        query       += ' FROM Zuora__Subscription__c WHERE ';
        
        //START D-3675 LISEN 10/9/2015 - Enable on demand batch based on selective subscriptions or accounts
        if(selectiveIds != null && !selectiveIds.isEmpty()){
            if(type == SELECTIVE_SUBSCRIPTIONS){
                query += ' ID IN :selectiveIds ';
            }else if(type == SELECTIVE_ACCOUNTS){
                //START D-3675 10/14/2015 Added By C. Lin - Change to Billing Account Number
                //query += ' Zuora__Account__r.AccountNumber IN :selectiveIds ';
                query += ' Zuora__CustomerAccount__r.Zuora__AccountNumber__c IN :selectiveIds AND Zuora__SubscriptionEndDate__c <= :referenceDate ';
                //END D-3675 10/14/2015 Added By C. Lin
            }
        }else{
            if(referenceDate == null && subIDToCancel != null)
            {
                query   += ' ID = :subIDToCancel ';
            }
            else if(forAllPastData)
            {
                query   += ' Zuora__SubscriptionEndDate__c <= :referenceDate '; //START END UD-3634 12Feb2016 Added By C. Lin - Should be today instead of today+1
            }
            else
            {
                query   += ' (Zuora__SubscriptionEndDate__c = :referenceDate) '; //START END UD-3634 12Feb2016 Added By C. Lin - Remove OR Zuora__SubscriptionEndDate__c = :refDateAddOne
            }
        }
        //END D-3675 LISEN 10/9/2015 - Enable on demand batch based on selective subscriptions or accounts
        
        query       += 'AND Zuora__Status__c != :STATUS_CANCEL AND Order_Line_Item_Number_1__c != null ';
        return Database.getQueryLocator(query);
    }
    //END D-3513 Bill Run Hotfix Wenjun 04/Sep/15
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> subList){
        //START D-3920 5-Nov-2015 Jensar Joey Sayson- edited logger start
        //START D-3733 20-Oct-2015 LISEN - Added logic to get processed subscription detail
        //Logger logger = new Logger(SP_CancelSubscriptionInZuora.class.getName(),'SP057', BC.getJobID());
        //END D-3733 20-Oct-2015 LISEN - Added logic to get processed subscription detail
        
        Logger logger;
        
        if(!Test.isRunningTest()) {
            logger = new Logger(SP_CancelSubscriptionInZuora.class.getName(),'SP057', BC.getJobID());
        }
        
        //END D-3920 5-Nov-2015 Jensar Joey Sayson- edited logger end       //START D-3675 10/14/2015 Added By C. Lin - Add Logger
        try{
            Map<Id, Date> mapSubIDToStopDate = new Map<Id, Date>();
            Map<string, string> returnZuoraEffectiveToSubscriptionName = new Map<string, string>();
            List<Case> lstCasesToUpd = new List<Case>();
            List<Order__c> lstOrdersToUpd = new List<Order__c>();
            Map<String, Object> subStopMap = new Map<String, Object>();
            List<Map<String, Object>> subStopMapList = new List<Map<String, Object>>();
            List<Zuora__Subscription__c> lstNormalExpiry = new List<Zuora__Subscription__c>();
            Set<Id> subIds = new Set<Id>();
        //START-END UD-3764 1/27/2016 removed fix of D-3898
            
            for(Zuora__Subscription__c sub : subList)  
            {
                subIds.add(sub.id);
                if(sub.Zuora__TermSettingType__c == 'Termed' && sub.Term_Length__c != null)
                {
                    if(sub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(sub.Term_Length__c)).addDays(-1) == sub.Zuora__SubscriptionEndDate__c){
                        lstNormalExpiry.add(sub);
                        
                        if(sub.Zuora__CustomerAccount__c != null){
                            setBillingAccountId.add(sub.Zuora__CustomerAccount__c);
                        }
                    }
                }
        //START-END UD-3764 1/27/2016 removed fix of D-3898
            }
            System.debug('>>>>>>>>>>>>>>>>List of Sub IDS' + ' ' + subIds);
            System.debug('>>>>>>>>>>>>>>>>lstNormalExpiry' + ' ' + lstNormalExpiry);
            
            /****************** Process PSTOP and COS *************************/
            //START Hotfix Wenjun 09/09/15 : Shall process all case status i.e. filter by Sub End Date only
            List<Order_Line_Item__c> lstOliStopCOS = [SELECT Id, Case__c, Order__c, Subscription__c, Subscription_Name__c,  
                        Case__r.Sub_Status__c, Subscription__r.Zuora__CustomerAccount__c,Stop_Request_Date__c, Start_Date__c, 
                        Order__r.Order_Type__c, Subscription__r.Zuora__Zuora_Id__c, Subscription__r.Name, Case__r.RecordType.Name,
                        //START: D-3898 11/12/15 Added by Manolo Valena
                        //START UD-2549 4/5/2016 Added by J.Sarion
                        Order__r.Subscription__r.Zuora__Zuora_Id__c, Order__r.Subscription__r.Zuora__CustomerAccount__c,
                        Subscription__r.Zuora__SubscriptionEndDate__c, Subscription__r.Zuora__SubscriptionStartDate__c, Subscription__r.Billing_Type__c, 
                        Order__r.Subscription__c, Order__r.Subscription__r.Zuora__SubscriptionEndDate__c, Order__r.Subscription__r.Zuora__SubscriptionStartDate__c, 
                        Order__r.Subscription__r.Billing_Type__c, Terminating_Reason__c 
                        //END UD-2549 4/5/2016 Added by J.Sarion
                        //END: D-3898 11/12/15 Added by Manolo Valena
            FROM Order_Line_Item__c 
            WHERE (Subscription__c IN :subIds AND Case__r.RecordType.Name = :STOP_SUBSCRIPTION) OR 
            (Order__r.Subscription__c IN :subIds AND Case__r.RecordType.Name = :CHANGE_OF_SUBSCRIPTION)];
            //END Hotfix Wenjun 09/09/15 
            
            for(Order_Line_Item__c oli : lstOliStopCOS){
                
                //START: UD-2893 9/21/15 Added by Manolo Valena - Added filter.
                if(oli.Case__r.RecordType.Name == STOP_SUBSCRIPTION && oli.Case__r.Sub_Status__c != GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_STOP){ //Stop Subscription
                //END: UD-2893 9/21/15 Added by Manolo Valena
        //START-END UD-3764 1/27/2016 removed fix of D-3898
                        if(oli.Subscription__r.Zuora__CustomerAccount__c != null){
                            setBillingAccountId.add(oli.Subscription__r.Zuora__CustomerAccount__c);
                        }
                        if(oli.Stop_Request_Date__c != null){
                            mapSubIDToStopDate.put(oli.Subscription__c, oli.Stop_Request_Date__c);
                            
                            //START UD-2549 4/5/2016 Added by J.Sarion - Set Cancel Date to Start Date + 1 if PStop Date <= Start Date 
                            if(oli.Subscription__r.Billing_Type__c == 'Full Prepaid' && (oli.Terminating_Reason__c == 'Payment failure - Credit card' || oli.Terminating_Reason__c == 'Payment failure - PayPal')) {
                                if(oli.Stop_Request_Date__c <= oli.Subscription__r.Zuora__SubscriptionStartDate__c) {
                                    mapSubIDToStopDate.put(oli.Subscription__c, oli.Subscription__r.Zuora__SubscriptionStartDate__c.addDays(1));
                                }
                            }
                            //END UD-2549 4/5/2016 Added by J.Sarion - Set Cancel Date to Start Date + 1 if PStop Date <= Start Date 
                        }
                        if(oli.Subscription__r.Zuora__Zuora_Id__c != null && oli.Subscription__r.Name != null){
                            returnZuoraEffectiveToSubscriptionName.put(oli.Subscription__r.Zuora__Zuora_Id__c, oli.Subscription__r.Name);
                        }
                    }
                else { //COS
                    if(oli.Order__r.Subscription__r.Zuora__CustomerAccount__c != null){
                        setBillingAccountId.add(oli.Order__r.Subscription__r.Zuora__CustomerAccount__c);
                    }
                    if(oli.Start_Date__c != null){
                        mapSubIDToStopDate.put(oli.Order__r.Subscription__c, oli.Start_Date__c);
                    }
                    if(oli.Subscription__r.Zuora__Zuora_Id__c != null && oli.Subscription__r.Name != null){
                        returnZuoraEffectiveToSubscriptionName.put(oli.Subscription__r.Zuora__Zuora_Id__c, oli.Subscription__r.Name);
                    }
                }
        //START-END UD-3764 1/27/2016 removed fix of D-3898
            }


            
            //START: D-3632 10/1/15 Added by Manolo Valena
            /****************** Process Normal Expiry Susbcriptions *************************/
            if(!lstNormalExpiry.isEmpty())
            {
                //START D-3733 20-Oct-2015 LISEN - Added logic to get processed subscription detail
                String processedSubscriptions = '';
                for(Zuora__Subscription__c subNorm : lstNormalExpiry) {
                    //START D-3262 07/20/2015 Added by J.Sarion - Set Cancellation Date to Subscription End Date +1 day
                    Date cancelDate = subNorm.Zuora__SubscriptionEndDate__c.addDays(1);
                    //END D-3262 07/20/2015 Added by J.Sarion - Set Cancellation Date to Subscription End Date +1 day
                    String strCancelDt = Zuora.Zutil.getZuoraDate(cancelDate);
                    
                    subStopMap = new Map<String, Object>(); //START-END D-3675 10/15/2015 Added By C. Lin - instantiate subStopMap
                    subStopMap.put(Globalvariableclass.CONTRACT_EFFECTIVEDATE, strCancelDt);
                    subStopMap.put(Globalvariableclass.DESCRIPTION, Globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
                    subStopMap.put(Globalvariableclass.EFFECTIVE_DATE, strCancelDt);
                    subStopMap.put(Globalvariableclass.NAME, Globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
                    subStopMap.put(Globalvariableclass.STATUS, Globalvariableclass.COMPLETED);
                    subStopMap.put(Globalvariableclass.SUBSCRIPTION_ID, subNorm.Zuora__Zuora_Id__c);
                    subStopMap.put(Globalvariableclass.TYPE, Globalvariableclass.CANCELATION);
                    subStopMapList.add(subStopMap);       

                    processedSubscriptions += subNorm.Zuora__Zuora_Id__c + ';';
                }
                
                if (!subStopMapList.isEmpty()) {
                    ZuoraCallOut amendCallOut = new ZuoraCallOut();
                    List<Map<String,String>> lstAmendResult = amendCallOut.amendZObjects(subStopMapList); 
                    
                    for(Map<String,String> amendResult :lstAmendResult){

                        if (amendResult.get('Status') != 'Success') 
                        {
                            logger.log(false, amendResult.get('Message'), processedSubscriptions);
                        }
                    }
                }    
                //END D-3733 20-Oct-2015 LISEN - Added logic to get processed subscription detail       
            }
            else if(!mapSubIDToStopDate.isEmpty())
            {
                //START D-3733 20-Oct-2015 LISEN - Added logic to get processed subscription detail
                SM_SubscriptionCancellationHelper.cancelSubscriptions(mapSubIDToStopDate, GlobalVariableClass.SUBJECT_STOP_SUBSCRIPTION);
                
                if (SM_SubscriptionCancellationHelper.isSuccess == false)
                {
                    for(Order_Line_Item__c oli : lstOliStopCOS)
                    {
                        Case stopCase = new Case (ID = oli.Case__c);
                        stopCase.Sub_Status__c = 'Zuora Issue - Subscription Cancellation';
                        lstCasesToUpd.add(stopCase);
                        
                        Order__c order = new Order__c(ID = oli.Order__c);
                        order.Status__c = GlobalVariableClass.STATUS_CLOSE; // START- END UD-3761 K. Tan 1/28/2015 Shall refer to STATUS_CLOSE instead  
                        lstOrdersToUpd.add(order);
                        
                        logger.log(false, SM_SubscriptionCancellationHelper.errorMessage, String.valueOf(oli.Case__c));
                    }
                    
                    try {
                        if(!lstCasesToUpd.isEmpty())
                            update lstCasesToUpd;
                        if(!lstOrdersToUpd.isEmpty())
                            update lstOrdersToUpd;
                    } catch (Exception dmlException) {
                        throw dmlException;
                    }
                }
                //END D-3733 20-Oct-2015 LISEN - Added logic to get processed subscription detail
            }
            //END: D-3632 10/1/15 Added by Manolo Valena
                
        }catch(Exception e){
            logger.logBatchFailure(e, subList);
            
            isApexJobSuccessful = false;
        }finally{
            logger.save();
        }
        //END D-3675 10/14/2015 Added By C. Lin
    }
    
    global void finish (Database.BatchableContext BC){ 
        //START D-4652 FrancisBenzon 19Apr16 : cancel ondemand sync as there is already real time sync
        //Perform Zuora Sync
        /*Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
        syncManager.syncObjectIdSet  = setBillingAccountId;
        syncManager.emailNotificationEnabled = false;
        
        List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
        */
        //END D-4652 FrancisBenzon 19Apr16 : cancel ondemand sync as there is already real time sync
        
        //Update Job Status
        //START D-3675 10/14/2015 Added By C. Lin - Enable on demand batch call for recovery
        if(!isApexJobSuccessful){
            BatchJobHelper.updateJobStatus(BC.getJobId(), false);
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
        //END D-3675 10/14/2015 Added By C. Lin
    } 
}