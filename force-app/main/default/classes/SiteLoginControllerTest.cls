/**
    # File..................: 
    # Helpper Class ........: 
    # Test Class............: SiteLoginControllerTest,SiteLoginController
    # Version...............: 
    # Created by............: rajesh kumar yadav
    # Created Date..........: 
    # Last Modified by......: rajesh kumar yadav
    # Last Modified Date....: 
    # Ticket....BK-3750
    # Description...........: 
 * An apex page controller that exposes the site login functionality
 */
@IsTest public with sharing class SiteLoginControllerTest {
    @IsTest(SeeAllData=false) public static void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
        System.assertEquals(controller.login(), null, 'For login the parameter cannot be null');                           
    }    
}