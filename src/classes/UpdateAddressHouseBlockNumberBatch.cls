/*
 * Class Name: SP_GenerateLetterPrintBatch
 * @author: Kevin H. Evasco
 * Date: 01/22/2014
 * Project/Requirement: SPH - D-1656
 * @description This class populates House Block Number at the Address Object given the Singpost Address House Block Number.
 * 
 * History: 01/22/2014 Kevin Evasco Created Apex Batch
 */

global class UpdateAddressHouseBlockNumberBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext bc)
    {               
        return Database.getQueryLocator([SELECT Id, Block_House_Number__c, Postal_Code__r.House_Block_Number__c FROM Address__c]); 
    }
     
    /* @description Generates Acknowledgment Letter for Newly Created Subscriptions.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<Address__c> scope)
    {       
        for(Address__c addressRecord : scope)
        {
            if(addressRecord.Block_House_Number__c != addressRecord.Postal_Code__r.House_Block_Number__c)
            {
                addressRecord.Block_House_Number__c = addressRecord.Postal_Code__r.House_Block_Number__c;
            }
        }
        
        Database.update(scope);
    }   
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {        
    }
    
}