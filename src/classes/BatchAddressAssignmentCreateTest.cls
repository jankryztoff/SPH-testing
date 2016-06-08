/**
 * Class Name: <BatchAddressAssignmentCreateTest>
 * @author: <JhustinPinoy>
 * Date: <9/27/2014>
 * Requirement/Project Name: <SPH>
 * Modified by: <Rom Edison Reyes>
 * @description<Test Class for BatchAddressAssignmentCreate>
 */

@isTest(seeAllData = TRUE)
private class BatchAddressAssignmentCreateTest {
  
    /**
    * Test method for BatchAddressAssignmentCreate class 
    * @name <testBatchAddressAssignmentCreate>
    * @param <none>
    * @return <none>
    * @throws exception - <none>
    * @see <none>
    */  
    static testmethod void testBatchAddressAssignmentCreate()
    {        
        Case cas = TestDataFactory.createCase(1, 'Complaint - Digital')[0];
        cas.Effective_Date__c = date.today();
        insert cas;
        
        Test.startTest();
        BatchAddressAssignmentCreate batch = new BatchAddressAssignmentCreate();
        Id batchprocessid = Database.executeBatch(batch, 200);
        Test.stopTest();
        List<Case> cases = [SELECT Id from Case where id=: cas.id];
        System.assert(cases.size() > 0);
    }

}