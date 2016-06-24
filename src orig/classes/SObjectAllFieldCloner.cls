/*
 * History D-1826 19/01/2015 Wenjun : Add one new utility method to pass in object ID List instead of object list. 
 * 							   This is to save unnecessary SOQL made
 */
public class SObjectAllFieldCloner {

    public static List<sObject> cloneObjects(List<sObject> sObjects,Schema.SObjectType objectType)
    {
        // A list of IDs representing the objects to clone
        List<Id> sObjectIds = new List<Id>{};
        
        // A list of fields for the sObject being cloned
        List<String> sObjectFields = new List<String>{};
        
        // A list of new cloned sObjects
        List<sObject> clonedSObjects = new List<sObject>{};

        // Get all the fields from the selected object type using 
        // the get describe method on the object type.
        if(objectType != null)
        {
          sObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
        }

        // If there are no objects sent into the method, 
        // then return an empty list
        if (sObjects != null && !sObjects.isEmpty() && !sObjectFields.isEmpty())
        {

            // Strip down the objects to just a list of Ids.
            for (sObject objectInstance: sObjects)
            {
                sObjectIds.add(objectInstance.Id);
            }

            /* Using the list of sObject IDs and the object type, 
             we can construct a string based SOQL query 
             to retrieve the field values of all the objects.*/

            String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0); 

            for (Integer i=1 ; i < sObjectFields.size() ; i++)
            {
                allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
            }

            allSObjectFieldsQuery += ' FROM ' + objectType.getDescribe().getName() + ' WHERE ID IN (\'' + sObjectIds.get(0) + '\'';

            for (Integer i=1 ; i < sObjectIds.size() ; i++)
            {
                allSObjectFieldsQuery += ', \'' + sObjectIds.get(i) + '\'';
            }

            allSObjectFieldsQuery += ')';

            try
            {
                // Execute the query. For every result returned, 
                // use the clone method on the generic sObject 
                // and add to the collection of cloned objects
                for (SObject sObjectFromDatabase:Database.query(allSObjectFieldsQuery))
                {
                    clonedSObjects.add(sObjectFromDatabase.clone(false,true));  
                }

            }
            catch (exception e)
            {           
            }
        }    

        // return the cloned sObject collection.
        return clonedSObjects;
    }
    
    //START D-1826 19/01/2015 Wenjun : new utility method to pass in object ID List and return old ID to new sObject Map
    //@Param: sObjectIds - A list of IDs representing the objects to clone
    public static Map<Id,sObject> cloneObjects(List<Id> sObjectIds,Schema.SObjectType objectType)
    {
        system.debug('*****@@sObjectIds: '+sObjectIds.size());
        // A list of fields for the sObject being cloned
        List<String> sObjectFields = new List<String>{};
        
        // Map storing existing Record ID to new cloned sObject
        Map<Id,sObject> mapOldIdToClonedObj = new Map<Id,sObject>();

        // Get all the fields from the selected object type using 
        // the get describe method on the object type.
        if(objectType != null)
        {
          sObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
        }

        // If there are no objects sent into the method, then return an empty list
        if (sObjectIds != null && !sObjectIds.isEmpty() && !sObjectFields.isEmpty())
        {
            /* Using the list of sObject IDs and the object type, we can construct a string based SOQL query 
             to retrieve the field values of all the objects.*/

            String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0); 

            for (Integer i=1 ; i < sObjectFields.size() ; i++)
            {
                allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
            }

            allSObjectFieldsQuery += ' FROM ' + objectType.getDescribe().getName() + ' WHERE ID IN (\'' + sObjectIds.get(0) + '\'';
            system.debug('*****@@sObjectIds1: '+sObjectIds.size());
            for (Integer i=1 ; i < sObjectIds.size() ; i++)
            {
                allSObjectFieldsQuery += ', \'' + sObjectIds.get(i) + '\'';
            }

            allSObjectFieldsQuery += ')';

            try
            {
                // Execute the query. For every result returned, use the clone method on the generic sObject 
                // and add to the collection of cloned objects
                for (SObject sObjectFromDatabase:Database.query(allSObjectFieldsQuery))
                    mapOldIdToClonedObj.put(sObjectFromDatabase.Id, sObjectFromDatabase.clone(false,true));
            }
            catch (exception e)
            {           
            }
        }    

        // return the cloned sObject collection.
        return mapOldIdToClonedObj;
    }
    // END D-1826 19/01/2015 Wenjun
    
    public static sObject cloneObject(sObject sObjectRecord,Schema.SObjectType objectType)
    {       
        // A list of fields for the sObject being cloned
        List<String> sObjectFields = new List<String>{};
        
        // A list of new cloned sObjects
        List<sObject> clonedSObjectList = new List<sObject>();

        // Get all the fields from the selected object type using 
        // the get describe method on the object type.
        if(objectType != null)
        {
            sObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
        }

        // If there are no objects sent into the method, 
        // then return an empty list
        if (sObjectRecord != null && !sObjectFields.isEmpty())
        {

            String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0); 

            for (Integer i=1 ; i < sObjectFields.size() ; i++)
            {
                allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
            }

            allSObjectFieldsQuery += ' FROM ' + objectType.getDescribe().getName() + ' WHERE ID = \'' + sObjectRecord.Id + '\'';

            try
            {
                for (SObject sObjectFromDatabase:Database.query(allSObjectFieldsQuery))
                {
                    clonedSObjectList.add(sObjectFromDatabase.clone(false,true));  
                }

            }
            catch (exception e)
            {           
            }
        }    

        
        // return the cloned sObject collection.
        return clonedSObjectList.get(0);
    }
}