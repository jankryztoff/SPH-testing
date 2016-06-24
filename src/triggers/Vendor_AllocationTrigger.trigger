trigger Vendor_AllocationTrigger on Vendor_Allocation__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Vendor_AllocationTriggerHandler.class);
}