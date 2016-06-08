@isTest(seeAllData = TRUE)

public class BatchAddAssignmentEffDateSchedTest {
    static testmethod void testBatchAddAssignmentEffDateSched() {
       
        Test.startTest();
        System.schedule('BatchAddAssignmentEffDateSchedule Test', '0 58 * * * ?', new BatchAddAssignmentEffDateScheduler());
        Test.stopTest(); 
        }
}