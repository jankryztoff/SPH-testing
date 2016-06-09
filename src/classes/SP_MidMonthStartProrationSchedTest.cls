@isTest

public class SP_MidMonthStartProrationSchedTest {

    static testmethod void test() {
        
       Test.startTest();
       System.schedule('SP_MidMonthStartProrationScheduler Test', '0 58 * * * ?', new SP_MidMonthStartProrationScheduler());
       Test.stopTest();
    }
}