/**
 * Class Name: <GlobalVariableClassTest>
 * @author: <JhustinPinoy>
 * Date: <9/27/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for GlobalVariableClass>
 */

@isTest (Seealldata = TRUE)
public class GlobalVariableClassTest {
    
    
    static testMethod void testGlobalVariableClass(){
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
        
        //System.runAs(testUser) {
            
            Test.startTest();
            
            List<String> constants = new List<String> {
                GlobalVariableClass.USERNAME,
                GlobalVariableClass.SVC,
                GlobalVariableClass.IP,
                GlobalVariableClass.API_ENABLE_SERVICE,
                GlobalVariableClass.API_CHECK_USER,
                GlobalVariableClass.DISPLAY_NAME,
                GlobalVariableClass.API_CHECK_DISPLAY_NAME,
                GlobalVariableClass.FFF,
                GlobalVariableClass.UUU,
                GlobalVariableClass.PPP,
                GlobalVariableClass.API_CHECK_AUTH,
                GlobalVariableClass.API_CHECK_AUTH2,
                GlobalVariableClass.API_CHECK_AUTH3,
                GlobalVariableClass.PASSWORD,
                GlobalVariableClass.PASS_CHALLENGE,
                GlobalVariableClass.PASS_RESPONSE,
                GlobalVariableClass.FNAME,
                GlobalVariableClass.LNAME,
                GlobalVariableClass.EMAIL,
                GlobalVariableClass.PHONE,
                GlobalVariableClass.ENABLE,
                GlobalVariableClass.API_SIGNUP,
                GlobalVariableClass.API_VIEW_USER_DETAILS,
                GlobalVariableClass.API_RESET_PASSWORD,
                GlobalVariableClass.NEWPASSWORD,
                GlobalVariableClass.API_ENABLE_ACCOUNT,
                GlobalVariableClass.EMPTYSTR,
                GlobalVariableClass.API_DISABLE_SERVICE,
                GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY,
                GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION,
                GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE
            };
            
            System.assertNotEquals(null, constants);
            GlobalVariableClass variableClass = new GlobalVariableClass();
            GlobalVariableClass.dummyMethod();
            Test.stopTest();
            
        //}
    }
}