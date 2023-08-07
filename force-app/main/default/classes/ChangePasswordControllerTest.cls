/**
    # File..................: 
    # Helpper Class ........: 
    # Test Class............: ChangePasswordControllerTest,ChangePasswordController
    # Version...............: 
    # Created by............: rajesh kumar yadav
    # Created Date..........: 
    # Last Modified by......: rajesh kumar yadav
    # Last Modified Date....: 
    # Ticket....BK-3750
    # Description...........: 
 * An apex page controller that exposes the change password functionality
 */
//Ticket No. BK-14521 Updating API Version
@IsTest public with sharing class ChangePasswordControllerTest {
    @IsTest(SeeAllData=false) public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(), null, 'Password cannot be blank');                           
    }    
}