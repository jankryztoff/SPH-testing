/**
 * Description: Trigger for Contact. Will invoke Trigger Handler to process each Trigger Event. 
                No logic shall be in this class
**/
trigger MigrationSubscriptionTrigger on Zuora__Subscription__c (before insert, after insert, before update, after update, before delete, after delete)
{
    MigrationSubscriptionTriggerHandler handler = new MigrationSubscriptionTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isUpdate) 
        handler.doBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        
    //START D-2920 05122015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created    
    else if(Trigger.isBefore && Trigger.isInsert) 
        handler.doBeforeInsert(Trigger.new);    
    //END D-2920 05122015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created   
    
    //START D-3171 07082015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created    
    else if(Trigger.isAfter && Trigger.isUpdate) 
        handler.doAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap); 
    //END D-3171 07082015 Christopher Camilon - To update the Subscription End Date after the Migrated Subscription is Created     
        
    /*
    else if(Trigger.isAfter && Trigger.isUpdate) 
        handler.doAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    */
}