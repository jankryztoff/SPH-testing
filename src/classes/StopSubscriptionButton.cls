/**
 * Class Name: StopSubscriptionButton 
 * @author: Jb Domingo
 * Date: 12/4/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Stop Subscription Send to ZBilling
 *
 */
global class StopSubscriptionButton{
    webservice static String stopSub(String subStopCaseId){
        String result = ''; // Start/End D-2660 01Apr15 JohnD
        system.debug('DEBUG!');
        Set<Id> subscriptionIdSet = new Set<Id>();
        Case stopSubCase = new Case();
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
        Map<Id,Date> zSub_StopDate_Map = new Map<Id,Date>();
        if(subStopCaseId != null){
            //START 1/26/15 J.Sarion : Add Order__c in SOQL Query
            stopSubCase = [SELECT Id, Order__c, Sub_Status__c FROM Case WHERE Id =: subStopCaseId]; // Start/End D-2660 01Apr15 JohnD added Sub_Status field
            //END 1/26/15 J.Sarion
            system.debug(stopSubCase);          
            if(stopSubCase != null){
                oliList = [SELECT Id, Subscription__c, Case__c, Stop_Request_Date__c FROM Order_Line_Item__c WHERE Case__c =: stopSubCase.Id];  
                system.debug(oliList);                  
                for(Order_Line_Item__c oli:oliList){
                    if(oli != null){
                        system.debug('oliListSubscription:'+oli.Subscription__c+':'+'oliListStopRequestDate:'+oli.Stop_Request_Date__c);                        
                        subscriptionIdSet.add(oli.Subscription__c);
                        zSub_StopDate_Map.put(oli.Subscription__c, oli.Stop_Request_Date__c);
                    }
                }
                
                if (!zSub_StopDate_Map.isEmpty()) {
                    try {
                        // Start D-2660 01Apr15 JohnD replaced method call and added error message
                        SM_SubscriptionCancellationHelper.cancelSubscriptions(zSub_StopDate_Map, GlobalVariableClass.SUBJECT_STOP_SUBSCRIPTION);
                        
                        if (SM_SubscriptionCancellationHelper.isSuccess == false) {
                        	result = SM_SubscriptionCancellationHelper.errorMessage;
                        	
                        	stopSubCase.Sub_Status__c = 'Zuora Issue - Subscription Cancellation';
			                // Start D-2693 06Apr15 JohnD added to update the status of the Order
                        	list<Order__c> orderList = new list<Order__c>();
			                if (stopSubCase.Order__c != null) {
			                	orderList = [select Id, Status__c from Order__c where Id = :stopSubCase.Order__c limit 1]; 
			                	if (orderList != null && orderList.size() > 0) {
			                		orderList[0].Status__c = GlobalVariableClass.SUB_STATUS_CLOSE;
			                	}
			                }
			                // End D-2693 06Apr15 JohnD added to update the status of the Order 
                        	
                        	// Start D-2693 06Apr15 JohnD renamed e to e2
                        	try {
                        		update stopSubCase;
                        		update orderList;
                        	} catch (exception e2) {
                        		ExceptionLogger.log(new list<exception>{ e2 } );
                        	} 
                        	// End D-2693 06Apr15 JohnD renamed e to e2
                        }
                        // End D-2660 01Apr15 JohnD replaced method call and added error message
                    } catch (Exception e){
                    	// Start D-2693 06Apr15 JohnD null pointer
                    	
                        result = 'Error: ';
                        if (e.getMessage() != null) {
                        
                         result += (string)e.getMessage();
                        } else {
                        	result += 'Unknown';
                        	ExceptionLogger.log(new list<exception>{ e });
                        }
                        // End D-2693 06Apr15 JohnD null pointer
                    }
                }
            }
        }
        return result;
    }
}