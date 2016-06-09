trigger SubscriptionVendorTrigger on Subscription_Vendor__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
    
TriggerFactory.createHandler(SubscriptionVendorTriggerHandler.class);

}