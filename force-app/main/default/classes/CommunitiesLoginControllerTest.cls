/**
    # File..................: 
    # Helpper Class ........: 
    # Test Class............: CommunitiesLoginControllerTest,CommunitiesLoginController
    # Version...............: 
    # Created by............: rajesh kumar yadav
    # Created Date..........: 
    # Last Modified by......: rajesh kumar yadav
    # Last Modified Date....: 
    # Ticket....BK-3750
# Description...........: 
* An apex page controller that exposes the site login functionality
*/
@IsTest public with sharing class CommunitiesLoginControllerTest {
    @IsTest(SeeAllData=false) 
    public static void testCommunitiesLoginController () {
        CommunitiesLoginController controller = new CommunitiesLoginController();
        System.assertEquals(null, controller.forwardToAuthPage(), 'Instance is must to load site page, it cannot return null');       
    }    
}