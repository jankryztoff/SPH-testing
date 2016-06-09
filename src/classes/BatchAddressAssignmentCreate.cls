/**
 * Class Name: BatchAddressAssignmentCreate 
 * @author: Jb Domingo
 * Date: 9/5/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch class that creates address assignments
 *
 */
global class BatchAddressAssignmentCreate implements Database.Batchable<sObject>
{
   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bcTemp - predefined parameter 
    * @return list of objects from Order Object
    */
    global database.QueryLocator start(database.BatchableContext bcTemp)
    {
        return database.getQueryLocator([SELECT Id, CaseNumber, Account.Id, Effective_Date__c, Contact.Id, Contact.Address__r.Id FROM Case WHERE Effective_Date__c =: date.today()]);
    }
    /* @description Executes the business logic and creates Address Assignment objects
     * 
     * @param bcTemp - predefined parameter 
     * @param allScopes - a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(database.batchableContext bcTemp, list<Case> allScopes){
        
        List<Address_Assignment__c> addressAssignList = new List<Address_Assignment__c>();
        for(Case c:allScopes){
                Address_Assignment__c addAssignObj = new Address_Assignment__c();
                addAssignObj.Contact__c = c.Contact.Id;
                addAssignObj.Address__c = c.Contact.Address__r.Id;
                addAssignObj.Effective_Date__c = c.Effective_Date__c;
                addAssignObj.Status__c = 'Active';
                addressAssignList.add(addAssignObj);
        }
        
        try{
            insert addressAssignList;
        }
        catch(Exception e){
            //error handling tbd
        }    
    }

    global void finish(database.batchableContext bcTemp){   
        
    }     
    
}