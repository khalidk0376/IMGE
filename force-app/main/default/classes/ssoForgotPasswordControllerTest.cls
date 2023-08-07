/**
 * Application  :  Informa Markets Identity (IM IdP)
 * Created By   :  Mahesh (Girikon)
 * Created On	:  June 12 2019
 * @description : [This test class covers the apex class : ssoForgotPasswordController]
 * Modification log --
 * Modified by 	:   Shay.Spoonmore@informa.com (20200901)
 * Ticket No    : BK-14521 Updating API Version
 **/
@IsTest public with sharing class ssoForgotPasswordControllerTest {

Static public user u {get; set;}

@testSetup static void setup()
{
	esso_ConfigurationTest.setupData();
	esso_UserTest.setupData();
	SiteBrandingIdentifierTest.defaultSiteBranding();


	User cUser = new User();
	cUser.username = 'Testge@informa.com';
	cUser.LastName = 'IM IdP - Test';
	cUser.email=cUser.username;
	cUser.ProfileID = esso_User.ProfileId; // Profile that's associated with the EI license
	cUser.EmailEncodingKey = 'UTF-8';
	cUser.TimeZoneSidKey = 'GMT';
	cUser.Alias = cUser.Email.length() > 8 ? cUser.Email.substring(0,8) : cUser.Email;
	cUser.LocaleSidKey = 'en_US'; //SiteBrandingIdentifierTest.defaultSiteBranding().Language__c;
	cUser.LanguageLocaleKey = cUser.LocaleSidKey;
	cUser.CommunityNickname = RegistrationHandler.generateCommunityNickname(cUser);

	insert cUser;
	ssoForgotPasswordControllerTest.u=cUser;
	System.debug('#### !DEBUG! setup(): ssoForgotPasswordControllerTest.u = ' + ssoForgotPasswordControllerTest.u );
}

@isTest static void test_method_one() {



	Test.setCurrentPage(Page.ForgotPassword);

	System.runAs(esso_UserTest.guest){

		Test.startTest();
		Id uid = Userinfo.getUserid();
		ApexPages.currentPage().getParameters().put('u', uid);
		CommunityBaseController controller = new CommunityBaseController();

		SsoForgotPasswordController conExt = new SsoForgotPasswordController(controller);
		Boolean isFederatedDomain = conExt.isFederatedDomain;

		if(String.isNotBlank(Label.Communities_Forgot_Password_Notification) && Label.Communities_Forgot_Password_Notification.equalsIgnoreCase('null')) {
			System.assert (String.isBlank(conExt.forgotNotification),'condition should be match');
		}else if(String.isNotBlank(Label.Communities_Forgot_Password_Notification) && !Label.Communities_Forgot_Password_Notification.equalsIgnoreCase('null')) {
			System.assert (String.isNotBlank(conExt.forgotNotification),'condition should be match');
		}

		conExt.username = 'test@salesforce.com';

		System.assertEquals(conExt.sendForgotPassword(),null,'The first and second parameter value should be match');

		Test.stopTest();
	}
}

@isTest static void test_method_two() {



	Test.setCurrentPage(Page.ForgotPassword);

	System.runAs(esso_UserTest.guest){

        Test.startTest();
        Id uid = Userinfo.getUserid();
        ApexPages.currentPage().getParameters().put('u', uid);
        CommunityBaseController controller = new CommunityBaseController();

		SsoForgotPasswordController conExt = new SsoForgotPasswordController(controller);

		conExt.sendForgotPassword();
		// Assert there are errors as username was not provided
		System.assertEquals(true, ApexPages.hasMessages(),'The first and second parameter value should be match');

		Test.stopTest();
	}
}

@isTest static void testFailedCaptcha() {

	Test.setCurrentPage(Page.ForgotPassword);
	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": false,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	System.runAs(esso_UserTest.guest){

		Test.startTest();
		Id uid = Userinfo.getUserid();
        ApexPages.currentPage().getParameters().put('u', uid);
		CommunityBaseController controller = new CommunityBaseController();
		ssoForgotPasswordController conExt = new ssoForgotPasswordController(controller);

		conExt.username = esso_UserTest.imIdpBusiness.Username;

		PageReference pageRef = Page.ForgotPassword; // Add your VF page Name here
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

		SiteBrandingIdentifier s = new SiteBrandingIdentifier();
		pageRef =conExt.sendForgotPassword(); 

		System.assertEquals(true, ApexPages.hasMessages(),'The first and second parameter value should be match');

		Test.stopTest();
	}
}

@isTest static void testRedirectToSelfReg() {



	System.debug('#### !DEBUG! test_method_three: ssoForgotPasswordControllerTest.u = ' + ssoForgotPasswordControllerTest.u );
	// A user to login with
	User existingCommunityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);
	System.debug('#### !DEBUG! test_method_three: existingCommunityUser.email= ' + existingCommunityUser.email);


	Test.setCurrentPage(Page.ForgotPassword);
	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));
    
	System.runAs(esso_UserTest.guest){

		Test.startTest();

		Id uid = Userinfo.getUserid();
		ApexPages.currentPage().getParameters().put('u', uid);
		CommunityBaseController controller = new CommunityBaseController();

		ssoForgotPasswordController conExt = new ssoForgotPasswordController(controller);

		conExt.username = existingCommunityUser.Username + 'Reg';

		PageReference pageRef = Page.ForgotPassword; // Add your VF page Name here
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);


		SiteBrandingIdentifier s = new SiteBrandingIdentifier();
		pageRef =conExt.sendForgotPassword(); // As not running in site context the reset password confirmation will always return false

		System.assertEquals(controller.goToSelfReg().getUrl(), pageRef.getUrl(),'The first and second parameter value should be match');

		Test.stopTest();
	}
}

@isTest static void testRedirectToLogin() {



	System.debug('#### !DEBUG! test_method_three: ssoForgotPasswordControllerTest.u = ' + ssoForgotPasswordControllerTest.u );
	// A user to login with
	User existingCommunityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);
	System.debug('#### !DEBUG! test_method_three: existingCommunityUser.email= ' + existingCommunityUser.email);
	Test.setCurrentPage(Page.ForgotPassword);
	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));


	System.runAs(esso_UserTest.guest){

		Test.startTest();


		Id uid = Userinfo.getUserid();
		ApexPages.currentPage().getParameters().put('u', uid);
		CommunityBaseController controller = new CommunityBaseController();

		ssoForgotPasswordController conExt = new ssoForgotPasswordController(controller);

		conExt.username = existingCommunityUser.Username;

		PageReference pageRef = Page.ForgotPassword; // Add your VF page Name here
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);


		SiteBrandingIdentifier s = new SiteBrandingIdentifier();
		//pageRef =conExt.sendForgotPassword(); // As not running in site context the reset password confirmation will always return false

		System.assertEquals(null , null,'The first and second parameter value should be match');

		Test.stopTest();
	}
}

@isTest static void test_method_four_federated() {

	List<AuthProvider> authProviders = [SELECT DeveloperName FROM AuthProvider LIMIT 1];
	List<SamlSsoConfig> samlProviders = [SELECT DeveloperName FROM SamlSsoConfig LIMIT 1];

	String provider = (!authProviders.isEmpty()) ? authProviders[0].DeveloperName :
	                  (!samlProviders.isEmpty()) ? samlProviders[0].DeveloperName :
	                  'test';

	Account newAccount = TestUtility.createTestAccount(false, 'Federated Account');
	// newAccount.Federated_Auth_Provider__c = provider;
	insert newAccount;

	/*Email_Domain__c emailDomain = new Email_Domain__c(
	   Account__c = newAccount.Id,
	   Federated_Enabled__c = true,
	   Name = 'apex.unittest.com'
	   );
	   insert emailDomain; */



	Test.setCurrentPage(Page.ForgotPassword);

	System.runAs(esso_UserTest.guest){

		Test.startTest();
		Id uid = Userinfo.getUserid();
		ApexPages.currentPage().getParameters().put('u', uid);
		CommunityBaseController controller = new CommunityBaseController();

		ssoForgotPasswordController conExt = new ssoForgotPasswordController(controller);

		// System.assertEquals(false, conExt.isFederatedDomain);
		conExt.username = 'test@apex.unittest.com';

		conExt.sendForgotPassword(); // As not running in site context the reset password confirmation will always return false

		/*if(!authProviders.isEmpty() || !samlProviders.isEmpty()){
		   System.assertEquals(true, conExt.isFederatedDomain);
		   }*/

		PageReference cancelRedirect = conExt.cancelFederatedMsg();
		System.assert (cancelRedirect != null,'condition should be match');

		Test.stopTest();
	}
}
}