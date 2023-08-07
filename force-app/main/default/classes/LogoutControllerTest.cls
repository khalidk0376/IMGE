/**
 * Application        :  Informa Markets Identity (IM IdP)
 * Created By         :  Mahesh (Girikon)
 * Created On:        :  June 12 2019
 * @description       : [ This test class covers the apex class : LogoutController,FederatedAuthProviderUtility]
 * Modification log --
 * Modified by        : 	Shay.Spoonmore@informa.com (20200901)
 **/
@isTest
private class LogoutControllerTest {

@TestSetup
private static void setupData()
{
    esso_Configuration__c config = new esso_Configuration__c();

    config.Adobe_Analytics_Id__c = 'xyz';
    config.Branding_Default__c = 'informa';
    config.Enable_Return_URL_Whitelist_Check__c =true;
    config.Enable_Xss_Input_Detection__c=true;
    config.Enable_Xss_Parameter_Detection__c=true;
    config.Identity_Profile_Name__c = esso_ConfigurationTest.identityProfileName;
    config.Name = 'config';
    config.reCAPTCHA_Disable__c =false;
    config.reCAPTCHA_Endpoint__c = 'https://www.google.com/recaptcha/api/siteverify';
    config.reCAPTCHA_Private_Key__c  = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe';
    config.reCAPTCHA_Public_Key__c = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI';
    config.Enable_Return_URL_Whitelist_Check__c= false;
    insert config;

	//esso_ConfigurationTest.setupData();
	esso_UserTest.setupData();
	SiteBrandingIdentifierTest.defaultSiteBranding();

	esso_Site_Branding__c customBrand = SiteBrandingIdentifierTest.createSiteBranding('LogoutBrand', 'LogoutBrand', 'LogoutBrand', 'Markets', true);
	customBrand.Default_Landing_Page__c = 'https://www.LogoutBrandUrl.com';
	update customBrand;

}
    
    
@isTest static void testRedirectDefault() {

	Test.setCurrentPage(Page.logout);

	ApexPages.currentPage().getParameters().put('referralurl', 'www.google.com');

	System.runAs(esso_UserTest.guest){

		CommunityBaseController controller = new CommunityBaseController();

		LogoutController conExt = new LogoutController(controller);

		PageReference returnPage = conExt.redirect();

		//System.assertEquals('https://www.informa.com', returnPage.getUrl(),'The first and second parameter value should be match');
		// Confirm there is redirect
		//System.assertEquals('https://www.informa.com', conExt.redirectLocation,'The first and second parameter value should be match');
		// Confirm the IDE session Cookie should exist and should not be deleted
		//System.assertEquals(true, conExt.deleteIdeSessionCookie,'The first and second parameter value should be match');
	}
}

@isTest static void testRedirectDefaultBlank() {

	Test.setCurrentPage(Page.logout);

	ApexPages.currentPage().getParameters().put('referralurl', '');

	System.runAs(esso_UserTest.guest){

		CommunityBaseController controller = new CommunityBaseController();

		LogoutController conExt = new LogoutController(controller);

		PageReference returnPage = conExt.redirect();

		//System.assertEquals('https://www.informa.com', returnPage.getUrl(),'The first and second parameter value should be match');
		// Confirm there is redirect
	
	}
}

@isTest static void testRedirectCustom() {



	Cookie brand = new Cookie('brand', 'LogoutBrand', null, 1, false);
	Cookie rurl = new Cookie('rurl', 'https://www.LogoutBrandUrl.com', null, 1, false);

	PageReference logout = Page.logout;
	logout.setCookies(new List<Cookie> {brand, rurl});

	Test.setCurrentPage(logout);

	System.runAs(esso_UserTest.guest){

		CommunityBaseController controller = new CommunityBaseController();

		LogoutController conExt = new LogoutController(controller);

		PageReference returnPage = conExt.redirect();

		//System.assertEquals('https://www.LogoutBrandUrl.com', returnPage.getUrl(),'The first and second parameter value should be match');
		// Confirm there is redirect
		//System.assertEquals('https://www.LogoutBrandUrl.com', conExt.redirectLocation,'The first and second parameter value should be match');
		// Confirm the IDE session Cookie should be deleted due to guest user
		//System.assertEquals(true, conExt.deleteIdeSessionCookie,'The first and second parameter value should be match');
	}
}

@isTest static void test_method_three() {



	Test.setCurrentPage(Page.logout);

	System.runAs(esso_UserTest.guest){

		CommunityBaseController controller = new CommunityBaseController();

		LogoutController conExt = new LogoutController(controller);

		PageReference returnPage = conExt.redirect();

		//System.assertEquals('https://www.informa.com', returnPage.getUrl(),'The first and second parameter value should be match');
		// Confirm there is redirect
		//System.assertEquals('https://www.informa.com', conExt.redirectLocation,'The first and second parameter value should be match');
		// Confirm the IDE session Cookie should exist and should not be deleted
		//System.assertEquals(true, conExt.deleteIdeSessionCookie,'The first and second parameter value should be match');
	}
}

@isTest static void testReferralId() {

	esso_Site_branding__c branding = [SELECT Default_Landing_Page__c,Referral_Id__c FROM esso_Site_branding__c WHERE Referral_Id__c = 'LogoutBrand'];
	Test.setCurrentPage(Page.logout);

	ApexPages.currentPage().getParameters().put('referralid', branding.Referral_Id__c);

	System.runAs(esso_UserTest.guest){

		CommunityBaseController controller = new CommunityBaseController();
		LogoutController conExt = new LogoutController(controller);
		PageReference returnPage = conExt.redirect();

		//System.assertEquals(new PageReference(branding.Default_Landing_Page__c).geturl(), returnPage.getUrl(),'The first and second parameter value should be match');
		// Confirm there is redirect
		//System.assertEquals(branding.Default_Landing_Page__c, conExt.redirectLocation,'The first and second parameter value should be match');
		// Confirm the IDE session Cookie should exist and should not be deleted
		//System.assertEquals(true, conExt.deleteIdeSessionCookie,'The first and second parameter value should be match');
	}
}

@isTest static void test_method_six() {

	// Run in context of logged in SF User

     Cookie brand = new Cookie('brand', 'Informa', null, 1, false);
    Cookie rurl = new Cookie('rurl', 'http://www.informa.com', null, 1, false);

    PageReference regPage = Page.registration;
    regpage.setCookies(new List<Cookie> {brand, rurl});


    Test.setCurrentPage(regpage);

	Test.setCurrentPage(Page.logout);

	ApexPages.currentPage().getParameters().put('referralurl', 'www.google.com');

	CommunityBaseController controller = new CommunityBaseController();

	LogoutController conExt = new LogoutController(controller);

	PageReference returnPage = conExt.redirect();

	// Confirm the IDE session Cookie should exist and should not be deleted
	//System.assertEquals(false, conExt.deleteIdeSessionCookie,'The first and second parameter value should be match');
}

@isTest static void test_method_seven() {

	// Run in context of logged in SF fed auth User

	User communityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.guest, null, false);
	communityUser.Email = 'apex.unit.test@restservice.com';
	communityUser.Username = 'apex.unit.test@restservice.com';
	//communityUser.Is_Federated__c = true;
	insert communityUser;
    
    System.runAs(communityUser){
    SiteBrandingIdentifier.referralId = 'informa';

	Test.setCurrentPage(Page.logout);

	
		ApexPages.currentPage().getParameters().put('referralurl', 'https://www.google.com');
		ApexPages.currentPage().getParameters().put('referralid', 'informa');

		CommunityBaseController controller = new CommunityBaseController();
        LogoutController conExt = new LogoutController(controller);

		PageReference returnPage = conExt.redirect();

		// Confirm there is redirect is not to the logout endpoint but the identity service
		//System.assertNotEquals(LogoutController.SF_LOGOUT_ENDPOINT, returnPage.getUrl(),'The first and second parameter value should be not match');
		// Confirm url is for the identity logout service
		//System.assertEquals(FederatedAuthProviderUtility.getDefaultCommunityURL() + '/services/apexrest/identity/informa/logout?referralurl=' + EncodingUtil.urlEncode('http://www.google.com', 'UTF-8'), returnPage.getUrl());
    }
}
}