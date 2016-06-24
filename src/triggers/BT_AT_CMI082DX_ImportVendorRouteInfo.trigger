/**
 * Trigger Name: BT_AT_CMI082DX_ImportVendorRouteInfo
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - CMI082DX Interface
 * Description: This trigger contains the business logic for CMI082DX interface.
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger
 */

trigger BT_AT_CMI082DX_ImportVendorRouteInfo on BT_CO_CMIS_POP_ImportVendorRouteInfo__c (before insert, before update) 
{
    
    List<BT_CO_CMIS_POP_ImportVendorRouteInfo__c> recordsList = trigger.new;
    
    // Instantiate list of objects to be inserted
    // Replace "sObject" with the actual object you will be using
    // List<sObject> recordsForInsertionList1 = new List<sObject>();
    // List<sObject> recordsForInsertionList2 = new List<sObject>();
    
    for(BT_CO_CMIS_POP_ImportVendorRouteInfo__c record : recordsList)
    {
        // Instantiate objects to be included in recordsForInsertionList
        // Replace "sObject" with the actual object you will be using
        // sObject object1 = new sObject();
        // sObject object2 = new sObject();        
        
        // Place code for mapping and business logic here
        System.debug('description__c'+record.description__c);
        System.debug('dropPoint__c'+record.dropPoint__c);
        System.debug('publicationCode__c'+record.publicationCode__c);
        System.debug('route__c'+record.route__c);
        System.debug('routeSystem__c'+record.routeSystem__c);
        System.debug('variedFixed__c'+record.variedFixed__c);
        System.debug('vendorId__c'+record.vendorId__c);
        
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
        System.debug('BT_AT_CMI082DX_ImportVendorRouteInfo Upsert operation failed.');
    }    
    
    */
    
}