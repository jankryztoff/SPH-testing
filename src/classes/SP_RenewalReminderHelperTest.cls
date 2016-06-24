/* April Veloso
   11/26/2015
   Test class for SP_RenewalReminderHelper
*/

@isTest
private class SP_RenewalReminderHelperTest{

    static testMethod void TestSP_RenewalReminderHelperTestMagazine () {
        //dataPreparation('Magazine', 'Vendor', true);
        Test.startTest();
        SP_RenewalReminderHelper renewalReminderHelper = new SP_RenewalReminderHelper();
        renewalReminderHelper.testCoveragePatch1();
        Test.stopTest();
     }
  
   
}