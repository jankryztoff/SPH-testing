@isTest(SeeAllData=true)
public class ZoneProductTriggerTest {

    public static testMethod void ZoneProductTriggerTest(){
    //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        System.runAs(testUser) {
            //prepareTestData();
            Test.startTest();
                //update eligList;
                //delete eligList;
                
                ZoneProductTriggerHandler handler = new ZoneProductTriggerHandler();
                handler.runBeforeInsertTrigger();
                handler.runBeforeUpdateTrigger();
                handler.runAfterInsertTrigger();
                handler.runAfterUpdateTrigger();
                handler.runBeforeDeleteTrigger();
                handler.runAfterDeleteTrigger();
            Test.stopTest();
            }
        }
}