/**
 * Trigger Name: BT_AT_ARM068DX_ExportAccountSummary
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - ARM068DX Interface
 * Description: This trigger contains the business logic for ARM068DX interface.
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger
 */

trigger BT_AT_ARM068DX_ExportAccountSummary on BT_CO_ARMS_ExportAccountSummary__c (before insert, before update) 
{
    
    List<BT_CO_ARMS_ExportAccountSummary__c> recordsList = trigger.new;
    
    // Instantiate list of objects to be inserted
    // Replace "sObject" with the actual object you will be using
    // List<sObject> recordsForInsertionList1 = new List<sObject>();
    // List<sObject> recordsForInsertionList2 = new List<sObject>();
    
    for(BT_CO_ARMS_ExportAccountSummary__c record : recordsList)
    {
        // Instantiate objects to be included in recordsForInsertionList
        // Replace "sObject" with the actual object you will be using
        // sObject object1 = new sObject();
        // sObject object2 = new sObject();        
        
        // Place code for mapping and business logic here
        /*
        System.debug('accountNumber__c'+record.accountNumber__c);
        System.debug('accountType__c'+record.accountType__c);
        System.debug('bankCode__c'+record.bankCode__c);
        System.debug('companyCode__c'+record.companyCode__c);
        System.debug('giroAccountNumber__c'+record.giroAccountNumber__c);
        */

        
        // Add object1 to recordsForInsertionList1;
        // recordsForInsertionList1.add(object1);
        
        // Add object2 to recordsForInsertionList2;
        // recordsForInsertionList1.add(object1);        
    }   
    
    // Execute upsert operation to insert new records or update existing records in salesforce
    /*
    
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try
    {
        upsert recordsForInsertionList1;
        upsert recordsForInsertionList2;
    }
    catch(Exception e)
    {    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_ARM068DX_ExportAccountSummary Upsert operation failed.');
    }    
    
    */
    
}