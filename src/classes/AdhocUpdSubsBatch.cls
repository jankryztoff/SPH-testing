/**
 * Class Name: AdhocUpdSubsBatch
 * @author: Zhu, Wenjun
 * Date: 31 Aug 2015
 * @description: For patching subscription data   
 */
 
global class AdhocUpdSubsBatch implements Database.Batchable<sObject> {    
    global final String query;
    
    global AdhocUpdSubsBatch (String strInput)
    {
        this.query = strInput;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {     
        return Database.getQueryLocator(query);
    }
    
    //Delete records in batch - to manage the 10K DML Limit
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> lstRecords) {
		for(Zuora__Subscription__c sub : lstRecords)
        {
            sub.Redeem_Date_2__c = null;
        }
        update lstRecords;
    }        
               
    global void finish(Database.BatchableContext BC) {
    }
}