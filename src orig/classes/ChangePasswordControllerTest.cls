/**
 * An apex page controller that exposes the change password functionality
 */
@IsTest public with sharing class ChangePasswordControllerTest {
    @IsTest(SeeAllData=true) public static void testChangePasswordController() {
    
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = 'oldPassword1230!';
        controller.newPassword = 'NewPassword1230!'; 
        controller.verifyNewPassword = 'NewPassword1230!';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }    
}