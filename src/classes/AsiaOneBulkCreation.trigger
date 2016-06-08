trigger AsiaOneBulkCreation on BT_CO_ASIAONE_BulkIdCreation__c (after insert) {

	AsiaOneBulkCreationTriggerHandler triggerHandler = new AsiaOneBulkCreationTriggerHandler();
	triggerHandler.doAfterInsert(trigger.new);
}