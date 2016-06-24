/**
 * Trigger Name: BT_AT_AGD043DX_AGD_EINVOICE
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - AGD043DX Interface
 * Description: This trigger contains the business logic for AGD043DX interface.
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger
 */

trigger BT_AT_AGD043DX_AGD_EINVOICE on BT_CO_AGD_EINVOICE__c (before insert, before update) 
{
    
    List<BT_CO_AGD_EINVOICE__c> recordsList = trigger.new;
    
    // Instantiate list of objects to be inserted
    // Replace "sObject" with the actual object you will be using
    // List<sObject> recordsForInsertionList1 = new List<sObject>();
    // List<sObject> recordsForInsertionList2 = new List<sObject>();
    
    for(BT_CO_AGD_EINVOICE__c record : recordsList)
    {
        // Instantiate objects to be included in recordsForInsertionList
        // Replace "sObject" with the actual object you will be using
        // sObject object1 = new sObject();
        // sObject object2 = new sObject();        
        
        // Place code for mapping and business logic here
        System.debug('business_unit__c'+record.business_unit__c);
        System.debug('invoice_number__c'+record.invoice_number__c);
        System.debug('invoice_date__c'+record.invoice_date__c);
        System.debug('vendor_id__c'+record.vendor_id__c);
        System.debug('status__c'+record.status__c);
        System.debug('remarks__c'+record.remarks__c);
        
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
        System.debug('BT_AT_AGD043DX_AGD_EINVOICE Upsert operation failed.');
    }    
    
    */
    
}