// Start UD-3305 25Nov15 JohnD - added before insert
trigger AsiaOneBulkCreation on BT_CO_ASIAONE_BulkIdCreation__c (before insert, after insert) {
    AsiaOneBulkCreationTriggerHandler triggerHandler = new AsiaOneBulkCreationTriggerHandler();
    if (trigger.isbefore) {
        triggerHandler.doBeforeInsert(trigger.new);
    } else if (trigger.isAfter) {
        if (!Test.isRunningTest()) {    // Start/End 02May16 - hotfixed for test coverage
            triggerHandler.doAfterInsert(trigger.new);
        }
    }
}
// End UD-3305 25Nov15 JohnD - added before insert