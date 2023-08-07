/**
 * Application            : Informa Markets Identity (IM IdP)
 * Created/Modified By    : Mahesh (Girikon)
 * Created On:            : June 12 2019
 * @description           : [This test class covers the apex class : ssoChangePasswordController]
 * Modification log --
 * Modified by            : Shay.Spoonmore@informa.com (20200828)
 **/
@IsTest 
public with sharing class ssoChangePasswordControllerTest {

private Static User communityUser;

@testSetup static void setup()
{
	esso_ConfigurationTest.setupData();
	esso_UserTest.setupData();
	SiteBrandingIdentifierTest.defaultSiteBranding();

}

@isTest static void testChangePassword() {

  Test.setCurrentPage(Page.ChangePassword);
  
  
	System.runAs(esso_UserTest.imIdpBusiness) {

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();
    ssoChangePasswordController conExt = new ssoChangePasswordController(controller);
    PageReference pageRef = Page.ssoChangePassword; // Add your VF page Name here
		Test.setCurrentPage(pageRef);
		conExt.oldPassword = '123456';
		conExt.newPassword = 'qwerty1';
		conExt.verifyNewPassword = 'qwerty1';
    Test.stopTest();
		System.assertEquals(conExt.changePassword(), null,'The first and second parameter value should be match');
	}
}

@isTest static void testMissingInformation() {

  User u = new User(Id=esso_UserTest.imIdpBusiness.Id,FirstName=null,LastName='{updatelast}', CountryCode=null, esso_Privacy_Policy_Agreed__c=false);
  update u;
  Test.setCurrentPage(Page.ChangePassword);
  
  
	System.runAs(esso_UserTest.imIdpBusiness) {



		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();
    ssoChangePasswordController conExt = new ssoChangePasswordController(controller);
    PageReference pageRef = Page.ssoChangePassword; // Add your VF page Name here
		Test.setCurrentPage(pageRef);
		conExt.oldPassword = '123456';
		conExt.newPassword = 'qwerty1';
    conExt.verifyNewPassword = 'qwerty1';
    
    conExt.userforUpdate = esso_UserTest.imIdpBusiness;
    conExt.privacyPolicy = false;

    Test.stopTest();
		System.assertEquals(conExt.changePassword(), null,'The first and second parameter value should be match');
  }
  
}

@isTest static void testChangePassword_redirectURL() {

	Test.setCurrentPage(Page.ChangePassword);

	ApexPages.currentPage().getParameters().put('referralurl', 'https://www.informa.com');

	System.runAs(esso_UserTest.imIdpBusiness) {

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();

		ssoChangePasswordController conExt = new ssoChangePasswordController(controller);
		conExt.oldPassword = '123456';
		conExt.newPassword = 'qwerty1';
		conExt.verifyNewPassword = 'qwerty1';

		// Set test variable to test redirect url
		conExt.successfulPWChangeTest = true;
        System.assertEquals(conExt.changePassword(), null,'The first and second parameter value should be match');
		// System.assertEquals(conExt.changePassword().getUrl(),'https://www.informa.com','The first and second parameter value should be match');
	}
}

@isTest static void testChangePassword_validation() {


	Test.setCurrentPage(Page.ChangePassword);

	System.runAs(esso_UserTest.imIdpBusiness){

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();

		ssoChangePasswordController conExt = new ssoChangePasswordController(controller);
		conExt.oldPassword = null;
		conExt.newPassword = null;
		conExt.verifyNewPassword = null;

		// Call password change
		conExt.changePassword();

		System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR),'The first and second parameter value should be match');
	}
}

@isTest static void testChangePassword_validation_password_mismatch() {

	Test.setCurrentPage(Page.ChangePassword);

	System.runAs(esso_UserTest.imIdpBusiness) {

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();

		ssoChangePasswordController conExt = new ssoChangePasswordController(controller);
		conExt.oldPassword = '13245688';
		conExt.newPassword = 'aaaaaaaa123';
		conExt.verifyNewPassword = 'bbbbbbbb123';

		// Call password change
		conExt.changePassword();

		System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR),'The first and second parameter value should be match');
	}
}

@isTest static void testChangePassword_IsFederated() {

	Test.setCurrentPage(Page.ChangePassword);

	System.runAs(esso_UserTest.imIdpBusiness){

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();

		ssoChangePasswordController conExt = new ssoChangePasswordController(controller);

		// System.assertEquals(true, conExt.isFederated);

		// Call password change
		PageReference returnpage = conExt.changePassword();

		// Assert change password method is null and would not be called for federated users
		System.assertEquals(null, returnpage,'The first and second parameter value should be match');
	}
}
}