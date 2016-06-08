/**
 * Class Name: ZoneProductTriggerHandler
 * @author: Manolo Valena
 * Date: 2/2/2015
 * Requirement/Project Name: SPH
 * @description Trigger Handler for Zone Product Object
 */

public class ZoneProductTriggerHandler implements TriggerHandlerInterface{
    
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    Map<Id, List<Id>> mapProductToZones;
    Map<Id, List<Date>> mapZoneProductToStartDate;
    List<Zone_Product__c> existingZoneProductList;
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !ZoneProductTriggerHandler.isBeforeInsertTriggerCalled;
        ZoneProductTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !ZoneProductTriggerHandler.isBeforeUpdateTriggerCalled;
        ZoneProductTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !ZoneProductTriggerHandler.isBeforeDeleteTriggerCalled;
        ZoneProductTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !ZoneProductTriggerHandler.isAfterInsertTriggerCalled;
        ZoneProductTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !ZoneProductTriggerHandler.isAfterUpdateTriggerCalled;
        ZoneProductTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !ZoneProductTriggerHandler.isAfterDeleteTriggerCalled;
        ZoneProductTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
        
    public void bulkBefore() 
    {
        //START:D-1894 2/2/15 Added by Manolo Valeña - Passes all new Zone Product records to the CheckZoneProductRecords method.
        if(trigger.isInsert)
        {
            CheckZoneProductRecords(trigger.new);
        }    
        //END:D-1894 2/2/15 Added by Manolo Valeña
    }
        
    public void bulkAfter() {
        
    }
    
    public void beforeInsert(SObject so) {
       
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }
    
    public void beforeDelete(SObject so) {
    
    }
    
    public void afterInsert(SObject so) {
        
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {
        
    }
    
    /*
     *Checks Zone Product records being inserted. If there are already 2 existing record having the same product and zone of a record to be inserted,
     *an error will be shown. If there is only 1 existing record of the same product and zone, the new record is only added if its effective
     *start date is a future date compared to the existing one.
     */
    //START:D-1894 2/2/15 Added by Manolo Valeña - Added new method that validates the Zone Product records being inserted.
    public void CheckZoneProductRecords(List <Zone_Product__c> newZoneProductRecords)
    {
        mapProductToZones = new Map<Id, List<Id>>();
        mapZoneProductToStartDate = new Map<Id, List<Date>>();
        existingZoneProductList = new List<Zone_Product__c>();
        
        existingZoneProductList = [SELECT Id, Product__c, Zone__c, Effective_Start_Date__c FROM Zone_Product__c];
        
        for(Zone_Product__c zoneProd : existingZoneProductList)
        {
            if(mapProductToZones.containsKey(zoneProd.Product__c))
            {
                mapProductToZones.get(zoneProd.Product__c).add(zoneProd.Zone__c);
                mapZoneProductToStartDate.get(zoneProd.Product__c).add(zoneProd.Effective_Start_Date__c); 
            }
            else
            {
                mapProductToZones.put(zoneProd.Product__c, new List<Id>{zoneProd.Zone__c});
                mapZoneProductToStartDate.put(zoneProd.Product__c, new List<Date>{zoneProd.Effective_Start_Date__c});
            }
        }
        
        for(Zone_Product__c newZoneProd : newZoneProductRecords)
        {
            if(mapProductToZones.containsKey(newZoneProd.Product__c))
            {
                Integer count = 0;
                Boolean sameStartDate = false;
                for(Id zone : mapProductToZones.get(newZoneProd.Product__c))
                {
                    if(newZoneProd.Zone__c == zone)
                    {
                        count = count + 1;
                        if(count == 1)
                        {
                            for(Date startDate : mapZoneProductToStartDate.get(newZoneProd.Product__c))
                            {
                                if(newZoneProd.Effective_Start_Date__c == startDate)
                                {
                                    sameStartDate = true;
                                    newZoneProd.addError('There is already an existing record with the same ZProduct, Zone, and Effective Start Date. Please change the start date with a future date');
                                }
                            }
                        }
                        else if(count == 2 && sameStartDate == false)
                        {
                            newZoneProd.addError('There is already a record with a future-dated effective start date having the same ZProduct and Zone');
                        }
                    }
                }
            }
        }
    }
    //END:D-1894 2/2/15 Added by Manolo Valeña
}