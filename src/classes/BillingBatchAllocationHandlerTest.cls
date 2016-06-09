/*
* Class Name: <BillingBatchAllocationHandlerTest>
* @author: Thayne Recato Dy
* Date: 2/9/2015
* Modified by: Ana Fe Dumangas
* Modified Date: 6/30/15
* Requirement/Project Name: <SPH>
* @description: This is the test class for BillingBatchAllocationHandler
* History: D-4463 22Mar16 JohnD - totally revised code to align with the new logic
*/
@isTest
private class BillingBatchAllocationHandlerTest {
    
	static testMethod void allocateBatchNumberTest() {
		
		//TestDataFactory.createBillingBatch(); 
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
		
		BillingBatchAllocationHandler.allocateBatchNumber(new set<id>{billingAccountList[0].Id, billingAccountList[1].Id, billingAccountList[2].Id});
		
		for (Billing_Batch__c bb : [select Name, Next_Batch_Number__c from Billing_Batch__c]) {
			if (bb.Name == 'Full Prepaid') {
				system.assertEquals(bb.Next_Batch_Number__c, 14);
			} else if (bb.Name == 'Recurring Prepaid') {
				system.assertEquals(bb.Next_Batch_Number__c, 2);
			} else if (bb.Name == 'Recurring Postpaid') {
				system.assertEquals(bb.Next_Batch_Number__c, 16);
			}
		}
		Test.stopTest();
	}

}