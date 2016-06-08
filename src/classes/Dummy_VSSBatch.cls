global class Dummy_VSSBatch implements Database.Batchable<sObject>,Database.AllowsCallouts  {   
    
    global Database.QueryLocator start(Database.BatchableContext BC) {     
        return Database.getQueryLocator([SELECT Case__c, Case__r.CaseNumber
            FROM Case_Subscription__c WHERE Case__r.Status = 'Closed' 
            AND Case__r.Effective_Date__c >= 2015-08-01 AND Case__r.Effective_Date__c <= 2015-08-31
            AND (Case__r.Change_of_Address_Type__c = 'Change of Billing and Delivery Address' OR Case__r.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local')
            AND CreatedById = '00590000003xHcO'
            AND LastModifiedDate = LAST_N_DAYS:7]);
    }
    
    global void execute(Database.BatchableContext BC, List<Case_Subscription__c> lstRecords) {
        List<Address_Assignment__c> aaList = [SELECT Case__c FROM Address_Assignment__c WHERE Case__r.Status = 'Closed' 
            AND Case__r.Effective_Date__c >= 2015-08-01 AND Case__r.Effective_Date__c <= 2015-08-31
            AND (Case__r.Change_of_Address_Type__c = 'Change of Billing and Delivery Address' OR Case__r.Change_of_Address_Type__c = 'Change of Delivery Address - Local to Local')
            AND CreatedById = '00590000003xHcO'
            AND LastModifiedDate = LAST_N_DAYS:7];

        Set<Id> caseIdSet = new Set<Id>();
        
        for(Address_Assignment__c aaElem : aaList){
            caseIdSet.add(aaElem.Case__c);
        }
        
        for(Case_Subscription__c csElem : lstRecords){
            if(caseIdSet.contains(csElem.Case__c))
                System.debug(csElem.Case__r.CaseNumber);
        }

    }        
               
    global void finish(Database.BatchableContext BC) {
    }
}