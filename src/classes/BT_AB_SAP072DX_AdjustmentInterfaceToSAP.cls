/*
 * Class Name: BT_AB_SAP072DX_AdjustmentInterfaceToSAP
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - SAP072DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for SAP072DX batch job. Used together with BT_AS_SAP072DX_AdjustmentInterfaceToSAP Schedulable
 * 
 * History: 08/26/2014 Kevin Evasco Created Skeletal Apex Batchable
 */


global class BT_AB_SAP072DX_AdjustmentInterfaceToSAP implements Database.Batchable<sObject>
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    global final String query = 'SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = \'SAP072DX Sample Source\'';    
    
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
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        
        // TO-DO: Instantiate set to contain the IDs of the related objects, if there are any
        // Set<Id> accountIdSet = new Set<Id>();
        // Set<Id> contactIdSet = new Set<Id>();
        Set<Id> primaryObjectIdSet = new Set<Id>();
        
        for(sObject record : scope)
        {
            // TO-DO: Instantiate set to contain the IDs of the related objects, if there are any
            //accountIdSet.add(record.AccountId);
            //contactIdSet.add(record.Primary_Contact__c);
            primaryObjectIdSet.add(record.Id);
        }
        
        // TO-DO: Instantiate Map and List to contain the related objects, if there are any. Include fields needed to be exposed in SOQL query.
        // List<Account> accountList = [SELECT Id FROM Account WHERE Id IN :accountIdSet];
        // Map<Id, Account> accountMap = new Map<Id,Account>(accountList);
        //
        // List<Account> contactList = [SELECT Id FROM Contact WHERE Id IN :contactIdSet];
        // Map<Id, Contact> contactMap = new Map<Id,Contact>(contactList);      
        
        // TO-DO: Instantiate Map and List to contain the related child objects, if there are any. Include fields needed to be exposed in SOQL query.
        /*
        List<sObject> detailsList = [SELECT Id FROM sObject WHERE ParentId IN :primaryObjectIdSet];
        Map<Id, List<sObject>> detailsMap = new Map<Id, List<sObject>>();
        for(sObject detailRecord : detailsList)
        {
            List<sObject> detailsContainer = detailsMap.get(detailRecord.ParentId);
            if(detailsContainer == null)
            {
                detailsContainer = new List<sObject>();
            }
            detailsContainer.add(detailRecord);
            
            detailsMap.put(detailRecord.ParentId, detailsContainer);
        }
        */
        
        for(sObject record : scope)
        {                       
            // TO-DO: Get related object via map
            // Account relatedAccount = accountMap.get(record.AccountId);
            // Contact relatedContact = contactMap.get(record.Primary_Contact__c);          
        
            String exportData = '';     
            // TO-DO: Prepare export data here. Concatenate information from primary object fields and related object fields. Data should be separated by comma ','
            // exportData += record.export_data__c + ',';
            // exportData += relatedAccount.Name + ',';
            // exportData += relatedContact.Address;
        
            // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.job_id__c = '1';
            datapoolRecord.group_id__c = 'Master';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;
            
            datapoolList.add(datapoolRecord);
            
            // TO-DO: Populate detail data here. For every master, get corresponding child records.
            /*
            List<sObject> detailRecords = detailsMap.get(record.Id)
            if(detailRecords != null)
            {
                for(sObject detailRecord : detailRecords)
                {
                    // TO-DO: Prepare export data here. Concatenate information from primary object fields and related object fields. Data should be separated by comma ','
                    // exportData = ''; 
                    // exportData += record.export_data__c + ',';
                    // exportData += RelatedObjectOfChild.Field__c;
                    
                    BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
                    datapoolRecord.job_id__c = '1';
                    datapoolRecord.group_id__c = 'Detail';
                    datapoolRecord.run_for_date__c = Date.today();      
                    datapoolRecord.insert_time__c = DateTime.now(); 
                    datapoolRecord.export_data__c = exportData;             
                
                    datapoolList.add(datapoolRecord);
                }
            }
            */
        }
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_SAP072DX_AdjustmentInterfaceToSAP insert operation failed.');
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