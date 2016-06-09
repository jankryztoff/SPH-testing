@isTest(seeAllData = TRUE)

public class BatchAddressAssignCreateSchedTest {
    static testmethod void test() {
       
        Test.startTest();
        System.schedule('BatchAddressAssignmentCreateSchedule Test', '0 58 * * * ?', new BatchAddressAssignmentCreateScheduler());
        Test.stopTest(); 
        }
}