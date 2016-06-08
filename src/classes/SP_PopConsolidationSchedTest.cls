@isTest

public class SP_PopConsolidationSchedTest {

    static testmethod void test() {
        
       Test.startTest();
       System.schedule('SP_PopConsolidationScheduler Test', '0 58 * * * ?', new SP_PopConsolidationScheduler());
       Test.stopTest();
    }
}