/**
 * Author: Accenture Dev - Sherwin Puli
 * Created: February 17, 2016
 * Description: Trigger for Subscription_Vendor_Publication__c. Will invoke Trigger Handler to process each Trigger Event. 
                No logic shall be in this class
**/
trigger SubscriptionVenPubTrigger on Subscription_Vendor_Publication__c (after delete, after insert, after update, before delete, before insert, before update)
{
    SubscriptionVenPubTriggerHandler handler = new SubscriptionVenPubTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert){
        handler.doBeforeInsert(Trigger.new);
    }
    
    else if(Trigger.isBefore && Trigger.isUpdate){
        handler.doBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
    /*
    else if(Trigger.isBefore && Trigger.isDelete){
        handler.doBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isAfter && Trigger.isInsert){
        handler.doAfterInsert(Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isAfter && Trigger.isUpdate){
        handler.doAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isAfter && Trigger.isDelete){
        handler.doAfterDelete(Trigger.old, Trigger.oldMap);
    }
    */
}