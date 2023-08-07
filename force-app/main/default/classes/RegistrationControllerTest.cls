/**
 * Application            :  Informa Markets Identity (IM IdP)
 * Created/Modified By    :  Mahesh (Girikon)
 * Created On:            :  June 11 2019
 * @description           : [This test class covers the apex class : registrationController]
 * Modification log --
 * Modified by            :   Shay.Spoonmore@informa.com (20200828)
 **/
@isTest
private class RegistrationControllerTest {

@testSetup static void setup()
{
	esso_ConfigurationTest.setupData();
	esso_UserTest.setupData();
    EmailTemplate validEmailTemplate = new EmailTemplate(isActive = true, Name = 'testTemplate001', DeveloperName = 'testTemplate001', TemplateType = 'custom', FolderId = UserInfo.getUserId(), Subject = 'Your Subject Here', Body = 'test', HtmlValue = 'HtmlTest');
	//	insert validEmailTemplate;

      esso_Site_Branding__c siteBrandingObject = new esso_Site_Branding__c(
        Name = 'informa',
        Footer_Background_Colour__c = '#000000',
        Footer_Font_Colour__c  = '#FFFFFF',
        Footer_Logo_File_Name__c = 'logo.jpeg',
        Headings_Font_Colour__c = '#AAAAAA',
        Page_Background_Colour__c = '#FFFFFF',
        Page_Image__c = 'pageImage.jpeg',
        Product_Logo_File_Name__c = 'productImage.jpeg',
        Primary_Colour__c = '#BBBBBB',
        Referral_Id__c = 'informa',
        Secondary_Colour__c = '#CCCCCC',
        Standard_Font_Colour__c = '#000000',
        Product_Name__c = 'productName',
        Division__c = 'division',
        Language__c='en_US',
        Branding_Type__c = 'Vertical',
        // Client_Services_Contact_Email__c = 'help@informa.com',
        Default_Landing_Page__c = 'https://www.informa.com',
        Registration_Contact_Source__c = 'A55_Website Registrant (FREE)',
        Customer_Support_Page__c = 'https://informa.com/contact-us'
        );
    insert siteBrandingObject;
    System.debug('@@@'+siteBrandingObject.Referral_Id__c);
     Set<string> referralIds = new Set<string>();
           
     referralIds.add(esso_Configuration.setting.Branding_Default__c.toLowerCase());
            System.debug('@@@referralIds'+referralIds);

            List<Esso_Site_Branding__c> s = [SELECT Footer_Background_Colour__c, Footer_Logo_File_Name__c, Name, Page_Background_Colour__c,
                                             Primary_Colour__c,Language__c,Referral_Id__c, Secondary_Colour__c, Standard_Font_Colour__c, Footer_Font_Colour__c,
                                             Headings_Font_Colour__c, Page_Image__c, Product_Logo_File_Name__c, reCAPTCHA_Theme__c, Footer_Image_Location__c,
                                             Registration_HTML_Markup__c, Product_Name__c, Division__c, Default_Landing_Page__c,Favourite_Icon_Logo_File_Name__c, Branding_Type__c, Registration_Contact_Source__c,Copyright_HTML__c, Customer_Support_Page__c,
                                             Registration_Blacklist_Error_HTML__c, Registration_Greylist_Error_HTML__c,Trial_Registration_Blacklist_Error_HTML__c,Trial_Registration_Greylist_Error_HTML__c, Registration_Button__c,
                                             Customer_Support_Email__c,Customer_Support_Phone_Overide__c,Customer_Support_Phone_EMEA__c,Customer_Support_Phone_AMERICAS__c,Email_Template_Logo__c,Email_Template_Button_Link_Hex_Color__c
                                             FROM Esso_Site_Branding__c WHERE Referral_Id__c =: referralIds ];
            System.debug('@@@Esso_Site_Branding__c'+s);

	
}
   
    @isTest static void verifyUserEmail() 
{

	Test.setCurrentPage(Page.Registration);

	System.runAs(esso_UserTest.guest){


    esso_User.resetPasswordSelfRegSetCookie('joe.bloggs@NoUserExists.com');

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();
    RegistrationController regController = new RegistrationController(controller);

    PageReference pageRef = Page.registration; // Add your VF page Name here
		Test.setCurrentPage(pageRef);
        try{

		PageReference returnPage = regController.verifyUserEmail(); // registerUser will always return null when the page isn't accessed as a sit
        }
        catch(exception e){
            system.debug(e);
        }

		Test.stopTest();
	}
}

@isTest static void resetPasswordMessage() 
{

	Test.setCurrentPage(Page.Registration);

	System.runAs(esso_UserTest.guest){


    esso_User.resetPasswordSelfRegSetCookie('joe.bloggs@NoUserExists.com');

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();
    RegistrationController regController = new RegistrationController(controller);

    PageReference pageRef = Page.registration; // Add your VF page Name here
		Test.setCurrentPage(pageRef);

		PageReference returnPage = regController.registerUser(); // registerUser will always return null when the page isn't accessed as a site
		System.assertEquals(true, ApexPages.hasMessages(),'The first and second parameter value should be match');
		

		Test.stopTest();
	}
}

@isTest static void employeeRedirect() 
{

  Test.setCurrentPage(Page.Registration);
  // Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));


  System.runAs(esso_UserTest.guest)
  {

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();
    RegistrationController regController = new RegistrationController(controller);
    		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = 'joe.bloggs@informa.com';
		regController.username='joe.bloggs@informa.com';
		regController.theUser.Countrycode = 'GB';
		regController.password = 'P@$$word123!';
		regController.confirmPassword = 'P@$$word123!';
		regController.privacyPolicy= true;
		regController.profileId= esso_User.ProfileId;


		PageReference pageRef = Page.registration; 
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

		PageReference returnPage = regController.registerUser(); 
		System.assertEquals(true, (returnPage.getUrl().contains('/services/auth/sso/')),'Employee should be redirected to ' + returnPage.getUrl());
		

		Test.stopTest();
	}
}

@isTest static void regValidation() 
{

  Test.setCurrentPage(Page.Registration);
  // Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));


  System.runAs(esso_UserTest.guest)
  {

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();
    RegistrationController regController = new RegistrationController(controller);
    		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = '';
		regController.theUser.LastName = '';
		regController.theUser.Email = '';
		regController.username='';//joe.bloggs@informa.validation.com
		regController.theUser.Countrycode = '';
		regController.password = '';
		regController.confirmPassword = '';
		regController.privacyPolicy= true;
		regController.profileId= esso_User.ProfileId;


		PageReference pageRef = Page.registration; 
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

    //PageReference returnPage = regController.registerUser(); 
    System.assertEquals(false, regController.validate(),'The first and second parameter value should be match');
		System.assertEquals(true, ApexPages.hasMessages(),'The first and second parameter value should be match');
		

		Test.stopTest();
	}
}
@isTest static void regValidationDomainFilter1() 
{
  

  esso_Domain_Filter__c df1 = new esso_Domain_Filter__c(Name='informa.BLACKLIST.com',Type__c='BLACKLIST',Active__c=true);
  //esso_Domain_Filter__c df2 = new esso_Domain_Filter__c(Name='informa.GREYLIST.com',Type__c='GREYLIST',Active__c=true);
  List<esso_Domain_Filter__c> dfs = new List<esso_Domain_Filter__c>();
  dfs.add(df1);
  //dfs.add(df2);
  insert(dfs );

  Test.setCurrentPage(Page.Registration);
  // Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));


  System.runAs(esso_UserTest.guest)
  {

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();
    RegistrationController regController = new RegistrationController(controller);
    		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = '';
		regController.theUser.LastName = '';
		regController.theUser.Email = 'joe.bloggs@informa.BLACKLIST.com';
		regController.username='joe.bloggs@informa.BLACKLIST.com';
		regController.theUser.Countrycode = '';
		regController.password = '';
		regController.confirmPassword = '';
		regController.privacyPolicy= true;
		regController.profileId= esso_User.ProfileId;


		PageReference pageRef = Page.registration; 
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

    //PageReference returnPage = regController.registerUser(); 
    System.assertEquals(false, regController.validate(),'The first and second parameter value should be match');
    System.assertEquals(true, ApexPages.hasMessages(),'The first and second parameter value should be match');
    

    


		Test.stopTest();
	}
}
@isTest static void regValidationDomainFilter2() 
{
  

  //esso_Domain_Filter__c df1 = new esso_Domain_Filter__c(Name='informa.BLACKLIST.com',Type__c='BLACKLIST',Active__c=true);
  esso_Domain_Filter__c df2 = new esso_Domain_Filter__c(Name='informa.GREYLIST.com',Type__c='GREYLIST',Active__c=true);
  List<esso_Domain_Filter__c> dfs = new List<esso_Domain_Filter__c>();
  //dfs.add(df1);
  dfs.add(df2);
  insert(dfs );

  Test.setCurrentPage(Page.Registration);
  // Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));


  System.runAs(esso_UserTest.guest)
  {

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();
    RegistrationController regController = new RegistrationController(controller);
    		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = '';
		regController.theUser.LastName = '';
		regController.theUser.Email = 'joe.bloggs@informa.GREYLIST.com';
		regController.username='joe.bloggs@informa.GREYLIST.com';
		regController.theUser.Countrycode = '';
		regController.password = '';
		regController.confirmPassword = '';
		regController.privacyPolicy= true;
		regController.profileId= esso_User.ProfileId;


		PageReference pageRef = Page.registration; 
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

    //PageReference returnPage = regController.registerUser(); 
    System.assertEquals(false, regController.validate(),'The first and second parameter value should be match');
    System.assertEquals(true, ApexPages.hasMessages(),'The first and second parameter value should be match');
    

		Test.stopTest();
	}
}

@isTest static void registerUserBadData() {

	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	
		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();
    RegistrationController regController = new RegistrationController(controller);

		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = 'BadEmail.com';
		regController.theUser.Countrycode = 'GB';
		regController.password = 'P@$$word123!';
		regController.confirmPassword = 'P@$$word123!';
		regController.privacyPolicy= true;

		regController.profileId= esso_User.ProfileId;
		PageReference pageRef = Page.registration; // Add your VF page Name here
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

		PageReference returnPage = regController.registerUser(); 

    System.assertEquals(null, returnPage,'The first and second parameter value should be match');
    System.assertEquals(true, ApexPages.hasMessages(),'The first and second parameter value should be match');

		Test.stopTest();
}


@isTest static void registerUserBadPassword() {

	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	    
   
		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();
    RegistrationController regController = new RegistrationController(controller);

		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = 'joe.bloggs@apex.unit.test.com';
		regController.theUser.Countrycode = 'GB';
		regController.password = 'BadPassword';
		regController.confirmPassword = 'BadPassword';
		regController.privacyPolicy= true;

		regController.profileId= esso_User.ProfileId;
		PageReference pageRef = Page.registration; // Add your VF page Name here
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

		PageReference returnPage = regController.registerUser(); 

    System.assertEquals(null, returnPage,'The first and second parameter value should be match');
    System.assertEquals(true, ApexPages.hasMessages(),'The first and second parameter value should be match');

		Test.stopTest();
	
}


@isTest static void registerUserExisting() {



	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	System.runAs(esso_UserTest.guest){

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();

		RegistrationController regController = new RegistrationController(controller);

		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = esso_UserTest.imIdpBusiness.Username;
		regController.theUser.Countrycode = 'GB';
		regController.password = 'P@$$word123!';
		regController.confirmPassword = 'P@$$word123!';
		regController.privacyPolicy= true;

		regController.profileId= esso_User.ProfileId;
		PageReference pageRef = Page.registration; // Add your VF page Name here
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

		PageReference returnPage = regController.registerUser(); // registerUser will always return null when the page isn't accessed as a site

		//Assert no apex page messages were generated by registering the user
		//System.assertEquals(false, ApexPages.hasMessages());

		//PageReference returnPage = regController.registerUser(); 
    System.assertEquals(null, returnPage,'The first and second parameter value should be match');
    System.assertEquals(true, ApexPages.hasMessages(),'The first and second parameter value should be match');

		Test.stopTest();
	}
}


@isTest static void registerUser_Success_nostartUrl() {



	//System.debug('*** -- guestSiteUser: ' + guestSiteUser);

	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	
		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();

		RegistrationController regController = new RegistrationController(controller);

		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = 'joe.bloggs@apex.unit.test.com';
		regController.username='joe.bloggs@apex.unit.test.com';
		// regController.theContact.User_Defined_Company_Name__c = 'Test Corp';
		regController.theUser.Countrycode = 'GB';
		regController.password = 'P@$$word123!';
		regController.confirmPassword = 'P@$$word123!';
		regController.privacyPolicy= true;

		regController.profileId= esso_User.ProfileId;


		PageReference pageRef = Page.registration; // Add your VF page Name here
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);
		// Call reCaptcha like page does before allowing registration
		//regController.recaptchaVerify();


		// Attempt to register the user
		regController.successfulUserRegUnitTest = true;

		PageReference returnPage = regController.registerUser(); // registerUser will always return null when the page isn't accessed as a site

		//Assert no apex page messages were generated by registering the user
		//System.assertEquals(false, ApexPages.hasMessages());

		// Confirm default redirect
		System.assertEquals('https://www.informa.com', regController.redirectLocation,'The first and second parameter value should be match');
		// Confirm the IDE session Cookie should exist and should not be deleted
		//System.assertEquals(true, regController.deleteIdeSessionCookie,'The first and second parameter value should be match');

		Test.stopTest();
	
}

@isTest static void registerUserBadReferraltUrl() {


	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	
		Test.startTest();

		ApexPages.currentPage().getParameters().put('referralurl', '');

		CommunityBaseController controller = new CommunityBaseController();

		RegistrationController regController = new RegistrationController(controller);

		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = 'No.joe.bloggs@apex.unit.test.com';
		regController.username= 'No.joe.bloggs@apex.unit.test.com';
		// regController.theContact.User_Defined_Company_Name__c = 'Test Corp';
		regController.theUser.Countrycode = 'GB';
		regController.password = 'P@$$word123!';
		regController.confirmPassword = 'P@$$word123!';
		regController.privacyPolicy= true;

		regController.profileId= esso_User.ProfileId;


		PageReference pageRef = Page.registration; // Add your VF page Name here
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);
		regController.successfulUserRegUnitTest = true;
		PageReference returnPage = regController.returnToReferralURL(); // registerUser will always return null when the page isn't accessed as a site
		System.assertEquals(SiteBrandingIdentifierTest.defaultSiteBranding().Default_Landing_Page__c, returnPage.getUrl(),'The first and second parameter value should be match');
		Test.stopTest();
	}



@isTest static void registerUser_Success_withStartUrl() {


	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	
		Test.startTest();

		ApexPages.currentPage().getParameters().put('referralurl', 'informa.com');

		CommunityBaseController controller = new CommunityBaseController();

		RegistrationController regController = new RegistrationController(controller);

		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = 'joe.bloggs@apex.unit.test.com';
		regController.username= 'joe.bloggs@apex.unit.test.com';
		// regController.theContact.User_Defined_Company_Name__c = 'Test Corp';
		regController.theUser.Countrycode = 'GB';
		regController.password = 'P@$$word123!';
		regController.confirmPassword = 'P@$$word123!';
		regController.privacyPolicy= true;

		regController.profileId= esso_User.ProfileId;


		PageReference pageRef = Page.registration; // Add your VF page Name here
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

		// Call reCaptcha like page does before allowing registration
		// regController.recaptchaVerify();

		// Attempt to register the user
		regController.successfulUserRegUnitTest = true;
		PageReference returnPage = regController.registerUser(); // registerUser will always return null when the page isn't accessed as a site

		// Assert no apex page messages were generated by registering the user
		//System.assertEquals(false, ApexPages.hasMessages());

		// Confirm there is no redirect
		//System.assertEquals('informa.com', regController.redirectLocation,'The first and second parameter value should be match');
		// Confirm the IDE session Cookie should exist and should not be deleted
		//System.assertEquals(true, regController.deleteIdeSessionCookie,'The first and second parameter value should be match');

		Test.stopTest();
	
}

@isTest static void registerUser_Success_And_Verfiy_Success() {


	//'Default', 'informa', 'informa', 'Busisness Intellience'
	esso_Site_Branding__c siteBrandingObject = new esso_Site_Branding__c(
		Name = 'Default',
		Footer_Background_Colour__c = '#000000',
		Footer_Font_Colour__c  = '#FFFFFF',
		Footer_Logo_File_Name__c = 'logo.jpeg',
		Headings_Font_Colour__c = '#AAAAAA',
		Page_Background_Colour__c = '#FFFFFF',
		Page_Image__c = 'pageImage.jpeg',
		Product_Logo_File_Name__c = 'productImage.jpeg',
		Primary_Colour__c = '#BBBBBB',
		Referral_Id__c = 'informa1',
		Secondary_Colour__c = '#CCCCCC',
		Standard_Font_Colour__c = '#000000',
		Product_Name__c = 'informa',
		Division__c = 'Busisness Intellience',
		Branding_Type__c = 'Vertical',
		//Client_Services_Contact_Email__c = 'help@informa.com',
		Default_Landing_Page__c = 'https://www.informa.com',
		Registration_Contact_Source__c = 'A55_Website Registrant (FREE)',
		Customer_Support_Page__c = 'https://informa.com/contact-us'
		                           //Email_Verification_Email_Template__c = 'testTemplate001',
		                           //Enable_Email_Verification__c = true
		);
	insert siteBrandingObject;

	/* Site_Branding__c siteBranding = [select Id, Referral_Id__c, Enable_Email_Verification__c, Email_Verification_Email_Template__c from Site_Branding__c where Referral_Id__c = 'informa' limit 1];
	   siteBranding.Email_Verification_Email_Template__c = 'testTemplate';
	   siteBranding.Enable_Email_Verification__c = true;
	   update siteBranding; */

	

	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	
		//we have to have this insert in different user context due to mixed dmls issues
		
		Test.startTest();

		ApexPages.currentPage().getParameters().put('referralid', 'informa1');

		CommunityBaseController controller = new CommunityBaseController();

		RegistrationController regController = new RegistrationController(controller);

		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = 'joe.bloggs@apex.unit.test.com';
		// regController.theContact.User_Defined_Company_Name__c = 'Test Corp';
		regController.theUser.Countrycode = 'GB';
		regController.password = 'P@$$word123!';
		regController.confirmPassword = 'P@$$word123!';
		regController.privacyPolicy= true;

		regController.profileId= esso_User.ProfileId;


		PageReference pageRef = Page.registration; // Add your VF page Name here
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		pageRef.getParameters().put('referralid', String.valueOf('informa'));
		Test.setCurrentPage(pageRef);
		// Call reCaptcha like page does before allowing registration
		//regController.recaptchaVerify();

		// Attempt to register the user
		regController.successfulUserRegUnitTest = true;
		PageReference confirmationPage = regController.registerUser(); // registerUser will always return null when the page isn't accessed as a site
		PageReference redirectPage = regController.verifyUserEmail();

		// Assert no apex page messages were generated by registering the user
		// System.assertEquals(false, ApexPages.hasMessages());

		// Confirm default redirect
		System.assertEquals('https://www.informa.com', regController.redirectLocation,'The first and second parameter value should be match');
		// Confirm the IDE session Cookie should exist and should not be deleted
		//System.assertEquals(true, regController.deleteIdeSessionCookie,'The first and second parameter value should be match');

		Test.stopTest();
	
}

@isTest static void registerUser_Success_And_Verfiy_Fail() {


	//'Default', 'informa', 'informa', 'Busisness Intellience'
	esso_Site_Branding__c siteBrandingObject = new esso_Site_Branding__c(
		Name = 'Default',
		Footer_Background_Colour__c = '#000000',
		Footer_Font_Colour__c  = '#FFFFFF',
		Footer_Logo_File_Name__c = 'logo.jpeg',
		Headings_Font_Colour__c = '#AAAAAA',
		Page_Background_Colour__c = '#FFFFFF',
		Page_Image__c = 'pageImage.jpeg',
		Product_Logo_File_Name__c = 'productImage.jpeg',
		Primary_Colour__c = '#BBBBBB',
		Referral_Id__c = 'informa2',
		Secondary_Colour__c = '#CCCCCC',
		Standard_Font_Colour__c = '#000000',
		Product_Name__c = 'informa',
		Division__c = 'Markets',
		Branding_Type__c = 'Vertical',
		//Client_Services_Contact_Email__c = 'help@informa.com',
		Default_Landing_Page__c = 'https://www.informa.com',
		Registration_Contact_Source__c = 'A55_Website Registrant (FREE)',
		Customer_Support_Page__c = 'https://informa.com/contact-us'
		                           //Email_Verification_Email_Template__c = 'testTemplate001',
		                           //Enable_Email_Verification__c = true
		);
	insert siteBrandingObject;

	/* Site_Branding__c siteBranding = [select Id, Referral_Id__c, Enable_Email_Verification__c, Email_Verification_Email_Template__c from Site_Branding__c where Referral_Id__c = 'informa' limit 1];
	   siteBranding.Email_Verification_Email_Template__c = 'testTemplate';
	   siteBranding.Enable_Email_Verification__c = true;
	   update siteBranding; */


	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	
		//we have to have this insert in different user context due to mixed dmls issues
		/* EmailTemplate validEmailTemplate = new EmailTemplate(isActive = true, Name = 'testTemplate001', DeveloperName = 'testTemplate001', TemplateType = 'custom', FolderId = UserInfo.getUserId(), Subject = 'Your Subject Here', Body = 'test', HtmlValue = 'HtmlTest');
		   insert validEmailTemplate; */

		Test.startTest();

		ApexPages.currentPage().getParameters().put('referralid', 'informa2');

		CommunityBaseController controller = new CommunityBaseController();

		RegistrationController regController = new RegistrationController(controller);

		// Populate the sObject bind to the registration form
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = 'joe.bloggs@apex.unit.test.com';
		// regController.theContact.User_Defined_Company_Name__c = 'Test Corp';
		regController.theUser.Countrycode = 'GB';
		regController.password = 'test123456';
		regController.confirmPassword = 'test123456';
		regController.privacyPolicy= true;

		regController.profileId= esso_User.ProfileId;


		// Call reCaptcha like page does before allowing registration
		// regController.recaptchaVerify();

		// Attempt to register the user
		regController.successfulUserRegUnitTest = true;
		PageReference confirmationPage = regController.registerUser(); // registerUser will always return null when the page isn't accessed as a site
		//PageReference redirectPage = regController.verifyUserEmail();
		RegistrationController.existingUserCheck('theUser.Email');

		//Assert no apex page messages were generated by registering the user
		//System.assertEquals(true, ApexPages.hasMessages());

		// Confirm there is no redirect
		//System.assertEquals(null, regController.redirectLocation);
		// Confirm the IDE session Cookie should exist and should not be deleted
		//System.assertEquals(true, regController.deleteIdeSessionCookie);
		System.assert (ApexPages.hasMessages(),'Should return some Vf page error message');
		Test.stopTest();
	
}

@isTest static void registerUser_Fail_Validation_one() {


	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	System.runAs(esso_UserTest.guest){

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();

		RegistrationController regController = new RegistrationController(controller);

		// No registration details provided error should be thrown
		PageReference returnPage = regController.registerUser();

		System.assert (ApexPages.hasMessages(),'Should return some Vf page error message');

		Test.stopTest();
	}
}

@isTest static void registerUser_Fail_Validation_two() {



	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));


	System.runAs(esso_UserTest.guest){

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();

		RegistrationController regController = new RegistrationController(controller);
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = 'reg@apex.unit.test.com';
		//regController.theContact.User_Defined_Company_Name__c = 'Test Corp';
		regController.theUser.CountryCode = 'GB';
		regController.password = 'P@$$word123!';
		regController.confirmPassword = 'P@$$word12345678!';
		regController.privacyPolicy= true;

		regController.profileId= esso_User.ProfileId;


		// Call reCaptcha like page does before allowing registration
		// regController.recaptchaVerify();
		PageReference pageRef = Page.registration;
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

		// Non matching passwords
		PageReference returnPage = regController.registerUser();

		// Passwords did not match
		//System.assertEquals('&nbsp;&nbsp;' + Label.site.passwords_dont_match, ApexPages.getMessages()[0].getSummary(),'The first and second parameter value should be match');
		System.assertEquals('&nbsp;&nbsp;'+'Password did not match or length is to long', ApexPages.getMessages()[0].getSummary(),'The first and second parameter value should be match');

		Test.stopTest();
	}
}

/*  @isTest static void registerUser_Fail_Validation_three() {

      // Create site branding data
      setupData();

      User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' AND IsActive = true LIMIT 1];

      Test.setCurrentPage(Page.Registration);

      // Set the mock response from reCatpcha callout
   Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

      // Create site branding data duplicate user and attempt to register same email address
      User existingCommunityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);

      System.runAs(guestSiteUser){

          Test.startTest();

          CommunityBaseController controller = new CommunityBaseController();

          RegistrationController regController = new RegistrationController(controller);

          // Populate the sObject bind to the registration form
          regController.theUser.FirstName = 'Joe';
          regController.theUser.LastName = 'Bloggs';
          regController.theUser.Email = existingCommunityUser.Email;
         //regController.theContact.User_Defined_Company_Name__c = 'Test Corp';
          regController.theUser.CountryCode = 'GB';
          regController.password = 'P@$$word123!';
          regController.confirmPassword = 'P@$$word123!';
          regController.privacyPolicy= true ;


          // Call reCaptcha like page does before allowing registration
         // regController.recaptchaVerify();
          PageReference pageRef = Page.registration;
          pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
          pageRef.getParameters().put('referralid', String.valueOf('informa'));
          Test.setCurrentPage(pageRef);

          // Attempt to register the user
          PageReference returnPage = regController.registerUser(); // registerUser will always return null when the page isn't accessed as a site

          // Assert no apex page messages were generated by registering the user
          System.assertEquals(true, ApexPages.getMessages()[0].getSummary().startsWith('Username already registered.'));

          Test.stopTest();
      }
   }*/

@isTest static void registerUser_Fail_Validation_four() {



	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));


		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();

		RegistrationController regController = new RegistrationController(controller);

		//Populate the sObject bind to the registration form
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = 'registration' + Label.Communities_Registration_Email_Bad_Characters + '@apexunittest4.com';
		//regController.theContact.User_Defined_Company_Name__c = 'Test Corp';
		regController.theUser.CountryCode = 'GB';
		regController.password = 'P@$$word123!';
		regController.confirmPassword = 'P@$$word123!';
		regController.privacyPolicy= true;

		regController.profileId= esso_User.ProfileId;


		// Call reCaptcha like page does before allowing registration
		//regController.recaptchaVerify();
		PageReference pageRef = Page.registration;
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

		// Attempt to register the user
		PageReference returnPage = regController.registerUser(); // registerUser will always return null when the page isn't accessed as a site

		if(!label.Communities_Registration_Email_Bad_Characters.equalsIgnoreCase('null')) {

			String errorMsg = Label.Communities_Registration_Email_Bad_Character_Message;
			errorMsg = errorMsg.replace('{0}', Label.Communities_Registration_Email_Bad_Characters);
			System.assertEquals('&nbsp;&nbsp;We encountered an error! Please Contact Your Administrator!', ApexPages.getMessages()[0].getSummary(),'The first and second parameter value should be match');
		}

		Test.stopTest();
	
}

@isTest static void registerUser_Fail_Validation_five() {


	//List<reCAPTCHA_Settings__c> lstRecaptcha = new List<reCAPTCHA_Settings__c>();
	//reCAPTCHA_Settings__c recaptcha = new reCAPTCHA_Settings__c();
	//recaptcha.Disable__c= true;
	//lstRecaptcha.add(recaptcha);
	//insert lstRecaptcha;

	Test.setCurrentPage(Page.Registration);

	// Set the mock response from reCatpcha callout
	Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": false,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	System.runAs(esso_UserTest.guest){

		Test.startTest();

		CommunityBaseController controller = new CommunityBaseController();

		RegistrationController regController = new RegistrationController(controller);

		//Populate the sObject bind to the registration form
		// regController.theUser.FirstName = '<img onerror="alert(\'XSS\')"/>';
		regController.theUser.FirstName = 'Joe';
		regController.theUser.LastName = 'Bloggs';
		regController.theUser.Email = 'registration' + '@apexunittest4.com';
		//regController.theContact.User_Defined_Company_Name__c = 'Test Corp';
		regController.theUser.CountryCode = 'GB';
		regController.password = 'P@$$word123!';
		regController.confirmPassword = 'P@$$word123!';
		regController.privacyPolicy= true;

		regController.profileId= esso_User.ProfileId;


		// Call reCaptcha like page does before allowing registration
		//regController.recaptchaVerify();
		PageReference pageRef = Page.registration;
		pageRef.getParameters().put('g-recaptcha-response', String.valueOf('success'));
		Test.setCurrentPage(pageRef);

		// Attempt to register the user
		PageReference returnPage = regController.registerUser(); // registerUser will always return null when the page isn't accessed as a site

		// First Name contains Xss characters and will return a error
		System.assert (ApexPages.hasMessages(),'Should return some Vf page error message');

		Test.stopTest();
	}
}

}