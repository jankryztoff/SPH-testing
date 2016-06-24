@isTest
private class BillingBatchAllocationQueueableTest {

	static testMethod void execute() {
		
		//insert TestDataFactory.createBillingBatch();
		list<Account> accountList = TestDataFactory.createAccount(3, 'Direct Individual');
		insert accountList;
		
		list<Zuora__CustomerAccount__c> billingAccountList = TestDataFactory.createBillingAccount(3);
		billingAccountList[0].Billing_Type__c = 'Full Prepaid';
		billingAccountList[0].Zuora__Account__c = accountList[0].Id;
		billingAccountList[1].Billing_Type__c = 'Recurring Prepaid';
		billingAccountList[1].Zuora__Account__c = accountList[1].Id;
		billingAccountList[2].Billing_Type__c = 'Recurring Postpaid';
		billingAccountList[2].Zuora__Account__c = accountList[2].Id;
		
		Test.startTest();
		insert billingAccountList;
		System.enqueueJob(new BillingBatchAllocationQueueable(new set<id>{billingAccountList[0].Id, billingAccountList[1].Id, billingAccountList[2].Id}));
		Test.stopTest();
	}
    
}