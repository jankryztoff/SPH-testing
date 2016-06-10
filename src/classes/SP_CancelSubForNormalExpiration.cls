/**
* Class Name: SP_CancelSubForNormalExpiration
* @author: 
* Date: 
* Requirement/Project Name: Singapore Press Holdings
* @description:
* History: Logic now caters for cancellation of Grace Period subscriptions and Original subscriptions of that were renewed.
*/
global class SP_CancelSubForNormalExpiration implements Database.Batchable<sObject>, Database.AllowsCallouts {
    //START:  D-2658 4/1/15 Added by Karl Tan - Added Cancel Subscription for Normal Expiration.               
    global Batch_Configuration_Settings__c batchSettings; // configuration data for SP_CancelSubForNormalExpiration
    //END:  D-2658 4/1/15 Added by Karl Tan - Added Cancel Subscription for Normal Expiration.               

    //Start D-2336 02/27/2015 Added by ABanaag - cater for cancellation of Grace Period subs & Renewed subs
    Date tomorrow = date.today()+1;
    Date yesterday = date.today()-1;
    datetime dt;
    string dFormat;
    //End D-2336 02/27/2015 Added by ABanaag - cater for cancellation of Grace Period subs & Renewed subs
    
   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bc- predefined parameter 
    * @return list of objects from Subscription Object
    */  
    global Database.QueryLocator start(Database.BatchableContext BC) {
    //START:  D-2658 4/1/15 Added by Karl Tan - Added Cancel Subscription for Normal Expiration.                   
    batchSettings = Batch_Configuration_Settings__c.getInstance('SP_CancelSubForNormalExpiration');
    //END:  D-2658 4/1/15 Added by Karl Tan - Added Cancel Subscription for Normal Expiration.               

        //Start D-2336 02/27/2015 Added by ABanaag - cater for cancellation of Grace Period subs & Renewed subs
        return Database.getQueryLocator([SELECT Id, Name, Zuora__SubscriptionEndDate__c, Zuora__Zuora_Id__c FROM Zuora__Subscription__c WHERE 
        Zuora__Status__c != :GlobalVariableClass.STATUS_CANCELLED AND (Zuora__SubscriptionEndDate__c =: tomorrow OR Zuora__SubscriptionEndDate__c =: yesterday)]); //START/END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
        //End D-2336 02/27/2015 Added by ABanaag - cater for cancellation of Grace Period subs & Renewed subs
    }
        
    
    
    /* @description Executes the business logic
     * @param BC- predefined parameter 
     * @param scope - a list of sObjects from the initial database query
     * @return void
     */
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope) {
        Map<String, Object> subStopMap;
        List<Map<String, Object>> subStopMapList = new List<Map<String, Object>>();
		Logger logger = new Logger(SP_loadMonthlyUsageDataBatch.class.getName(),'SP043'); //START END D-1011 MD-28 Dags 18/06/15
        
        
        for (Zuora__Subscription__c sub :scope) {
        	//Start D-2336 02/27/2015 Added by ABanaag - cater for cancellation of Grace Period subs & Renewed subs        
            Date endDate = sub.Zuora__SubscriptionEndDate__c;
            dt = datetime.newinstance(endDate.year(), endDate.month(), endDate.day());
            subStopMap = new Map<String, Object>();
            dFormat = (string.valueOf(dt)).replaceAll( '\\s+', 'T');
            //End D-2336 02/27/2015 Added by ABanaag - cater for cancellation of Grace Period subs & Renewed subs
                
            subStopMap.put(globalvariableclass.CONTRACT_EFFECTIVEDATE, dFormat);
            subStopMap.put(globalvariableclass.DESCRIPTION, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
            subStopMap.put(globalvariableclass.EFFECTIVE_DATE, dFormat);
            subStopMap.put(globalvariableclass.NAME, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
            subStopMap.put(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
            subStopMap.put(globalvariableclass.SUBSCRIPTION_ID, sub.Zuora__Zuora_Id__c);
            subStopMap.put(globalvariableclass.TYPE, globalvariableclass.CANCELATION);
            subStopMapList.add(subStopMap);
        }
        

        
        if (!subStopMapList.isEmpty()) {
            ZuoraCallOut amendCallOut = new ZuoraCallOut();
            List<Map<String,String>> returnVarStopSub = amendCallOut.amendZObjects(subStopMapList); 
            for(Map<String,String> resultMapStopSub :returnVarStopSub){ 
                if (resultMapStopSub.get('Status') == 'Success') {
                    //TBD
                    system.debug('>>>>>>>>>>>>>>>>>>>>>>>>resultMapStopSub' + resultMapStopSub);
                }
                else {
                    //TBD
                    system.debug('>>>>>>>>>>>>>>>>>>>>>>>>resultMapStopSub' + resultMapStopSub);
				    logger.log(false,resultMapStopSub.get('Message'));  //START END D-1011 MD-28 Dags 18/06/15
                }
            }
			 Logger.save(); //START END D-1011 MD-28 Dags 18/06/15
        }      
    }
    
    global void finish(database.batchableContext BC){   
        BatchJobHelper.updateJobStatus(BC.getJobId()); //START-END KRITHIKA DHARMARAJAN 4/17/2014 D-2770 START-END KRITHIKA DHARMARAJAN D-3080 HOTFIX
    }
}