/*
 * Class Name: Asia1BatchUpdate
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration
 * @description This class updates existing Asia1 records with no user information (display name, password, email)
 * 
 * History: 09/12/2014 Kevin Evasco Created Apex Batchable
 */


global class Asia1BatchUpdate implements Database.Batchable<sObject>
{
    global final String query;    
    
    public Asia1BatchUpdate(Set<String> ldapIdSet)
    {
        String ldapIdSetQuery = '' + ldapIdSet;
        ldapIdSetQuery = '(' + ldapIdSetQuery.subString(1,ldapIdSetQuery.length()-1) + ')';
        
        query = 'SELECT Id, User_ID_LDAP_ID__c, Display_Name__c FROM Asia1__c WHERE Display_Name__c =\'Unknown\' AND Password__c = \'Unknown\'';
        
        System.debug(query);
    }
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {               
        List<Asia1__c> asia1ForUpdate = new List<Asia1__c>();
        for(sObject record : scope)
        {
            Asia1__c asia1Record = (Asia1__c) record;        
            
            //Map<String,Object> userDetailsMap = AsiaOneServicesController.viewUserDetails(asia1Record.User_ID_LDAP_ID__c);
            
            //asia1Record.Display_Name__c = (String) userDetailsMap.get('Display Name');
            //asia1Record.Email__c = (String) userDetailsMap.get('E-Mail');
            
            asia1Record.Display_Name__c = 'Vin_Evasco';
            
            asia1ForUpdate.add(asia1Record);
        }
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            update asia1ForUpdate;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('Asia1BatchUpdate Failed');
        }
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
        // TO-DO: Insert Nitin's webservice callout here
    }
}