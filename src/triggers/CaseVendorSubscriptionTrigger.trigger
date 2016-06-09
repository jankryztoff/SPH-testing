trigger CaseVendorSubscriptionTrigger on Case_Vendor_Subscription__c (after delete, after insert, after update, before delete, before insert, before update) {
 TriggerFactory.createHandler(CaseVendorSubscriptionTriggerHandler.class);
 }