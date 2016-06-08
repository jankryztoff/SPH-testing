@isTest

public class SP_loadMonthlyUsageDataBatchSchedTest {

    static testmethod void test() {
        
       Test.startTest();
       System.schedule('SP_loadMonthlyUsageDataBatchScheduler Test', '0 58 * * * ?', new SP_loadMonthlyUsageDataBatchScheduler());
       Test.stopTest();
    }
}