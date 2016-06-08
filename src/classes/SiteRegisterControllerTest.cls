/**
 * Class Name: SiteRegisterControllerTest
 * @author: Alfred Abrina
 * Date: 02/12/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description test class for SiteRegisterController
 *
 */
@IsTest (SeeAllData=true)
private with sharing class SiteRegisterControllerTest {
    private static Id PORTAL_ACCOUNT_ID = '001x000xxx35tPN';
/**test method for site register
*name testRegistration
*param: username, password, email, nickname
*/
    static testMethod void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        String username = 'test@force.com';
        String email = 'test@force.com';
        String nickname = 'test';
        controller.username = username;
        controller.email = email;
        controller.communityNickname = nickname;
        System.assert(controller.registerUser() == null);    
        
        String password = 'abcd1234';
        String confirmPassword = 'abcd123';
        controller.password = password;
        controller.confirmPassword = confirmPassword;
        System.assert(controller.registerUser() == null);  
        
    }     
  }