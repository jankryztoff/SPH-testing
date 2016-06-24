@isTest(seeAllData = TRUE)

public class SP_SendEscalationEmailSchedulerTest{
    static testmethod void testSP_SendEscalationEmailScheduler() {
       
        Test.startTest();
        System.schedule('SP_SendEscalationEmailSchedule Test', '0 58 * * * ?', new SP_SendEscalationEmailScheduler());
        Test.stopTest(); 
        }
}