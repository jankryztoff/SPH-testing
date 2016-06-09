@isTest
global class NewSubscriptionServiceTest5{
    
	static testMethod void testRollBackZuoraRecords(){        
        List<String> accountIdList = new List<String>();
        accountIdList.add('Param');
        
        //Zuora.zapi zApiInstance = new Zuora.zapi();
        //List<Zuora.zApi.DeleteResult> deleteResults = zApiInstance.zdelete('Account',accountIdList);
        
        Test.StartTest();
        NewSubscriptionService.rollBackZuoraRecords('Rollback');
        Test.StopTest();  
    }
    
    static testMethod void testRetrieveUserDetails(){
        Test.StartTest();
    	NewSubscriptionService.retrieveUserDetails('test', '5009000001GUoxv', new Map<Id,Id>(), new Set<Id>());
        NewSubscriptionService.createOrderLineItems(new List<NewSubscriptionService.OrderLineItemWrapper>(), new Order__c(), 'ldapid', new Contact(), '00D90000000rcem');
        Test.StopTest();
    }
}