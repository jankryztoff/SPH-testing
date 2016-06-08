@isTest(seeAllData = TRUE)

public class SP_CourierChargesCreditSchedulableTest {

    static testmethod void test() {
    
       Test.startTest();
       System.schedule('SP_CourierChargesCreditSchedulable Test', '0 58 * * * ?', new SP_CourierChargesCreditSchedulable());
       Test.stopTest();
    }
}