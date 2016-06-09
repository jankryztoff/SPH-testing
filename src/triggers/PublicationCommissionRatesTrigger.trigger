/**
* Class Name: PublicationCommissionRatesTrigger
* @author: Rom Edison Reyes
* Date: 04/28/2015
* Requirement/Project Name: Singapore Press Holdings
* @description Trigger for Publication Commission Rates
*/
trigger PublicationCommissionRatesTrigger on Publication_Commission_Rates__c (after update) {

    PubCommissionRatesTriggerHandler handler = new PubCommissionRatesTriggerHandler();
    
    if(Trigger.isAfter && Trigger.isUpdate){ 
        handler.doAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }  
}