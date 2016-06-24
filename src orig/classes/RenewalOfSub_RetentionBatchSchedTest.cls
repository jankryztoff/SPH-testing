@isTest (Seealldata = TRUE)

public class RenewalOfSub_RetentionBatchSchedTest {

    static testmethod void test() {
        
       Test.startTest();
       System.schedule('RenewalOfSub_RetentionBatchScheduler Test', '0 58 * * * ?', new RenewalOfSub_RetentionBatchScheduler());
       //added this
       //Integer configurableNumberOfDays = Integer.valueOf(ConstantsSLB.getKeyId('DaysBeforeSubscriptionEndDate'));
       Test.stopTest();
    }
}