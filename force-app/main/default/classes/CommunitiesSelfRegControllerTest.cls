/**
 # File..................: 
    # Helpper Class ........: 
    # Test Class............: CommunitiesSelfRegControllerTest,CommunitiesSelfRegController
    # Version...............: 
    # Created by............: rajesh kumar yadav
    # Created Date..........: 
    # Last Modified by......: rajesh kumar yadav
    # Last Modified Date....: 
    # Ticket....BK-3750
    # Description...........: 
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
//Ticket No. BK-14521 Updating API Version
@IsTest public with sharing class CommunitiesSelfRegControllerTest {
    @IsTest(SeeAllData=false) 
    public static void testCommunitiesSelfRegController() {
        
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null,'User is not blank.');    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null,'User is not blank.');  
    }       
}