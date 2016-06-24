/**
 * Class Name:  BatchMassCOP
 * @author: 
 * Date: 24 June 2016
 * Requirement/Project Name: CRSM Project
 * @description: Main job for Mass Change of Package CR
 */
 
global class BatchMassCOP implements Database.Batchable<sObject>, Database.Stateful {    
    
    Set<String> setSubNames;
    
    //Contructor for Full Run
    global BatchMassCOP(){
    }
    
    //Contructor for Targeted Run
    global BatchMassCOP(Set<String> selectiveSubs){
        setSubNames = selectiveSubs;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        //Dummy query below - Please change
        String query = ' Select ID, Name, Product_Code__c,Zuora__SubscriptionEndDate__c, Contract_End_Date_1__c FROM Zuora__Subscription__c LIMIT 1';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope) {
        //Execute Code Block Logic
    }        
               
    global void finish(Database.BatchableContext BC) 
    {
        //Finish Code Block Logic
    }
}