/**
 # Helpper Class ........: 
# Test Class............: ForgotPasswordControllerTest,ForgotPasswordController
# Version...............: 
# Created by............: rajesh kumar yadav
# Created Date..........: 
# Last Modified by......: rajesh kumar yadav
# Last Modified Date....: 
# Ticket....BK-3750
# Description...........: 
 * An apex page controller that exposes the site forgot password functionality
 */
//Ticket No. BK-14521 Updating API Version
@IsTest 
public with sharing class ForgotPasswordControllerTest {
  	 @IsTest(SeeAllData=false) 
    public static void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    	controller.forgotPassword();
    	System.assertEquals(controller.forgotPassword(), null , 'For resetting password value must not be null'); 
    }
}