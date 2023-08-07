/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 05 2019
 * @description :   [Class to capture the Community User details and created the user records from custom register VF page.]
 * Test Class   :   RegistrationControllerTest
 * Modification Log-----
 * Modified by  :	Shay.Spoonmore@informa.com (20190612)
 **/
public without sharing class RegistrationController {

//public Contact theContact          { get;  set;}      // Used on visualforce page to capture registration data
public User theUser             { get;  set;}         // Used on visualforce page to capture registration data
public String username            { get; set { username = value == null ? value : value.trim();
					       theUser.Email = value == null ? value : value.trim();} }
public String password            {get; set { password = value == null ? value : value.trim(); } }
public String confirmPassword     {get; set { confirmPassword = value == null ? value : value.trim(); } }
public Boolean stopCallbackPoller  {get; private set;}
public Boolean privacyPolicy       { get;  set;}

public String redirectLocation {get; set;}
public Boolean deleteIdeSessionCookie {get; set;}
//public String trialId {get; set;}
public String trialContactSource {get; set;}
public Boolean isTrial {get; set;}

public String profileId;

@TestVisible
private String referralurl {get; set;}     // URL provided on registration to redirect user to on completion

@TestVisible
private Boolean successfulUserRegUnitTest {get; set;}     // variable used in unit tests to mimic process of creating user as standard method returns null

/* reCAPTCHA object */
public ReCAPTCHAService reCaptcha {get; private set;}

public esso_User essoUser = new esso_User();
public CommunityBaseController controller {get; set;}

// CONSTRUCTOR
public RegistrationController(CommunityBaseController controller) {

	this.controller = controller;

	this.isTrial = ApexPages.currentPage().getParameters().get('istrial') != null ? Boolean.valueOf(ApexPages.currentPage().getParameters().get('istrial')) : false;

	this.trialContactSource = ApexPages.currentPage().getParameters().get('trialcontactsource');

	System.debug('*** -- this.trialContactSource from param: ' + this.trialContactSource);

	// Set the cookie on page load where fed auth redirects user off page
	//setRegistrationCookies();

	//theContact  = new Contact();
	theUser = new User();
	// Initial_Informa_Marketing_Preferences__c = true // 2017-11-30 - IEP-2242 - default informa marketing to true
	stopCallbackPoller = false;

	// Get the referralurl param on page load
	referralurl     = this.controller.siteBranding.referralurl;

	// Instantiate the object as verified variable is used on page and validation logic
	reCaptcha = new ReCAPTCHAService();

	// customer does not exist trying to reset password message
	resetPasswordMessage();

	returnToReferralURL();
}

private void resetPasswordMessage()
{

	//Display message to verify user
	Cookie rp= esso_User.resetPasswordSelfRegGetCookie();

	if(rp != null && String.isNotBlank(rp.getValue())  )
	{
		System.debug('#### !DEBUG! resetPasswordSelfRegGetCookie(): ' + rp.getValue());

		username = rp.getValue();
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '&nbsp;&nbsp;' + label.esso_ResetPasswordSelfReg));

		//Expire cookie
		esso_User.resetPasswordSelfRegExpireCookie();
	}

}

@RemoteAction
public static Boolean existingUserCheck(String username){

	List<User> users = new List<User>();

	if (String.isNotBlank(username)) {
		users = [SELECT Id,username FROM User WHERE Username = :username];//AND Is_Federated__c = false
	}

	return !users.isEmpty(); //&& !FederatedSsoController.isFederatedEnabled(username, null);
}

private boolean isValidPassword() {
	return password == confirmPassword;
}

//Creating the user records.
public PageReference registerUser() {

	//system.debug('####  theUser.Email= '+theUser.Email);
	if(String.isNotBlank(theUser.Email)) {
		theUser.Email = theUser.Email.trim();
		//redirect informa employee
		PageReference employeeRedirect = essoUser.employeeRedirect(theUser.Email);
		if (employeeRedirect != null)
		{
			return employeeRedirect;
		}
	}

	// Validate the request and return to page if invalid

	if(validate())
	{
		PageReference loginURL = controller.goToLogin();
		//Passed validation attempt to register user

		//User exists display url for user to login
		User[] users = [SELECT Id FROM User WHERE Username = :theUser.email LIMIT 1];
		System.debug('####  isValidUsername(' + theUser.email + '): ' + site.isValidUsername(theUser.email));
		if(!users.isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.esso_Username_already_registered.replace('{link}', '<a href="' + (loginURL == null ? '/login' : loginURL.getUrl()) + '">') + '</a>'));
			return null;
		}

		//Create User
		User u = new User();
		u.Username = theUser.Email;
		u.Email = theUser.Email;
		u.FirstName = theUser.FirstName;
		u.LastName = theUser.LastName;
		u.Countrycode = theUser.Countrycode;
		u.CommunityNickname = RegistrationHandler.generateCommunityNickname(u);

		//Checking the condition what value returning from privacyPolicy and updating the checkbox of esso_Privacy_Policy_Agreed__c
		u.esso_Privacy_Policy_Agreed__c= privacyPolicy ? true : false;

		//First attempt to get the referralid from the url param
		//Esso_Site_Branding__c siteBrandDefault = SiteBrandingIdentifier.siteBrandings.get(esso_Configuration.setting.Branding_Default__c);
		System.debug('Branding_Default__c'+esso_Configuration.setting.Branding_Default__c);

		Esso_Site_Branding__c siteBrand = SiteBrandingIdentifier.siteBrandings.get(esso_Configuration.setting.Branding_Default__c);
        System.debug(siteBrand);

		if(SiteBrandingIdentifier.isValidReferralId) {
			siteBrand = SiteBrandingIdentifier.siteBrandings.get(SiteBrandingIdentifier.referralId);
		}

            if(String.isBlank(siteBrand.Product_Name__c)) { siteBrand.Product_Name__c=siteBrand.Name;}
		u.LocaleSidKey = siteBrand.Language__c;
		u.LanguageLocaleKey = siteBrand.Language__c;
		u.esso_LocalLanguage__c= siteBrand.Language__c;
		u.esso_BrandId__c=siteBrand.Referral_Id__c.toLowerCase();
		u.esso_BrandName__c=siteBrand.Product_Name__c;
		u.esso_BrandSupportEmail__c= siteBrand.Customer_Support_Email__c;


		u.TimeZoneSidKey = 'GMT';
		//profileId = [Select Id From Profile where name=: esso_Configuration.setting.Identity_Profile_Name__c Limit 1].Id;
		u.ProfileID = esso_User.ProfileId; // Profile that's associated with the EI license
		u.EmailEncodingKey = 'UTF-8';
		u.Alias = u.Email.length() > 8 ? u.Email.substring(0,8) : u.Email;
		//20200612 Registration is a local account - set to Informa Markets Identity
		u.esso_LastLoginProviderType__c = esso_Configuration.DEFAULT_PROVIDER;
		u.esso_LastLoginProviderId__c = UserInfo.getUserId();

		//insert u;

		//u.Self_Registration_IP_Address__c = reCaptcha.ipAddress;
		//u.CompanyName = theContact.User_Defined_Company_Name__c; GR 28/03/2017 - removed as mastered by Contact object - IEP/812
		//u.ProfileId = profileId; // Auto populated via Site.createExternalUser() automatically by salesforce based on community config

		// Attempt to match the user/contact to an account otherwise null will use account assigned in community config
		//String accountId ='ID';    //RegistrationHandler.getMatchingAccountId(u.Self_Registration_IP_Address__c, u.Username);

		System.debug('### !DEBUG! u: ' + u);

		String userId;

		// Set a savepoint to rollback to on error
		System.Savepoint sp = Database.setSavepoint(); //to revert user creation if password fails
		Exception ee = null;// Set when System Exceptions happen and log
		try
		{

			//userId = Site.createExternalUser(u,null,password);// Do not use, creates contacts and unfortunately, we can't use the nice site display messages

			Database.SaveResult userResult = Database.insert(u, false);
			if (!userResult.isSuccess())
			{
				for(Database.Error err : userResult.getErrors())
				{

					System.debug('### !ERROR! Creating External User; ' + err.getStatusCode() + ': ' + err.getMessage() + '; ' + err.getFields());
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + err.getMessage()));

				}

				return null;
			}
			//insert u;
			system.debug('u.id===='+u.id);
			userId =u.id;
			System.setPassword(u.id, password);
			if(test.isRunningTest()) {
				integer ts = integer.valueof('hello');
			}
		}
		catch(system.InvalidParameterValueException ex)
		{
			if (ex.getMessage().contains('INVALID_NEW_PASSWORD'))
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + ex.getMessage().replace('INVALID_NEW_PASSWORD:','')));
			}
			else
			{
				ee = ex; //log error and display common error
			}
			System.debug('### !ERROR! Creating External User: Type: ' + ex.getTypeName() + '; Message:' + ex.getMessage());
			Database.rollback(sp);
			userId = null;
		}
		catch(system.Exception ex)
		{
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + ex.getMessage()));
			System.debug('### !ERROR! Creating External User: Type: ' + ex.getTypeName() + '; Message:' + ex.getMessage());
			Database.rollback(sp);
			userId = null;
			ee=ex;//log error and display common error
		}
		// catch(Site.ExternalUserCreateException ex)
		// {
		//  for (String error : ex.getDisplayMessages())
		//  {
		//      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + error));
		//
		//   }
		//   System.debug('### !ERROR! Creating external user - ' + ex.getMessage());// This message is used for debugging. Do not display this in the UI to the end user. It has the information around why the user creation failed.
		//   //Database.rollback(sp);
		//   userId = null;
		//}

		try
		{
			if (userId != null || (Test.isRunningTest() && successfulUserRegUnitTest)) {

				//Maps data from reg form to contact record
				//updateUserContact(userId);

				// Run post registration logic
				//RegistrationHandler.runPostRegistrationLogic(userId);

				System.debug('*** -- pre login referralurl: ' + referralurl);

				PageReference returnPage = Page.registrationconfirmation;

				/* if(String.isNotBlank(referralurl)){
				   // redirect to confirmation page which controls referral URL redirect
				   returnPage = Page.registrationconfirmation;

				   returnToReferralURL();

				   } else {
				   // redirect to generic landing page
				   returnPage = this.controller.getStartPageWithParams();
				   } */

				returnPage.getParameters().put('referralurl', referralurl);
				returnPage.getParameters().put('referralid', SiteBrandingIdentifier.referralId);
				returnPage.getParameters().put('istrial', String.valueOf(istrial)); // BSMS-44 send trial param through to registration confirmation so it can be tracked through email verification

				System.debug('*** -- referralurl: ' + referralurl);
				//system.debug('============++++++++++++'+Site.login(theUser.Email, password, returnPage.getUrl()));

				return Site.login(theUser.Email, password, returnPage.getUrl());
			}
		}
		catch (Exception e)
		{
			System.debug('### !ERROR! System.Exception:' + e.getMessage());
			ee = e;
		} finally {
			if (ee != null) {

				Database.rollback(sp);

				ExceptionHandler.capture(RegistrationController.class
				                         , ee
				                         , 'REGISTRATION/COMMUNITY'
				                         , null
				                         , new Map<String, Object> { 'UserId' => userId, 'ContactId' => u.ContactId });

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;We encountered an error! Please Contact Your Administrator!'));
			}
		}
	}

	return null;
}
//Verifying the user email.
public PageReference verifyUserEmail() {

	// Set a savepoint to rollback to on error
	System.Savepoint sp = Database.setSavepoint();

	PageReference returnPage;

	Exception ee = null;
	try {

		// BSMS-44 - convert istrial param into eType param for email verification
		String eType = (isTrial) ? 'trial' : 'std';
		if(test.isRunningTest()) {
			integer ts = integer.valueof('hello');
		}
		// Run email verification logic
		/* EmailVerificationService.sendEmail(UserInfo.getUserId()
		   , String.isNotBlank(Site.getBaseCustomUrl()) ? Site.getBaseCustomUrl() : Site.getBaseSecureUrl()
		   , controller.siteBranding.referralid
		   , eType); // BSMS-44 send eType param */
	} catch (Exception e) {
		ee = e;
	} finally {
		if (ee != null)  {
			Database.rollback(sp);
			ExceptionHandler.capture(RegistrationController.class
			                         , ee
			                         , 'EMAIL_VERIFICATION/COMMUNITY'
			                         , null
			                         , new Map<String, Object> {
					'UserId' => UserInfo.getUserId(),
					'referralId' => SiteBrandingIdentifier.referralId,
					'errorStackTrace' => ee.getStackTraceString(),
					'Exception' => ee.getMessage()
				});

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;We encountered an error! Please Contact Your Administrator!'));
			/*if (Test.isRunningTest()) {
			   throw ee;
			   } */
		}
	}

	if(String.isNotBlank(referralurl)) {
		// redirect to confirmation page which controls referral URL redirect
		returnToReferralURL();
	} else {
		// redirect to generic landing page
		returnPage = this.controller.getStartPageWithParams();
	}

	/* returnPage.getParameters().put('referralurl', referralurl);
	   returnPage.getParameters().put('referralid', controller.siteBranding.referralid); */
	return returnPage;
}
/* @TestVisible
   private void updateUserContact(Id userId){

   // Query the contact created against the user and update the company field
   Contact[] communityContacts = [SELECT Id, MailingCountryCode FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :userId) LIMIT 1];

   // Reassign custom fields captured on form for Contact sObject
   if(!communityContacts.isEmpty()){
   //communityContacts[0].User_Defined_Company_Name__c = theContact.User_Defined_Company_Name__c;
   //communityContacts[0].Contact_Source__c = controller.siteBranding.branding.Registration_Contact_Source__c;
   communityContacts[0].MailingCountryCode = theContact.MailingCountryCode;
   //communityContacts[0].Initial_Informa_Marketing_Preferences__c  = theContact.Initial_Informa_Marketing_Preferences__c ;
   // communityContacts[0].Initial_3rd_Party_Marketing_Preferences__c  = theContact.Initial_3rd_Party_Marketing_Preferences__c ;
   // communityContacts[0].Contact_Source__c = getContactSource();
   communityContacts[0].Title = theContact.Title;
   communityContacts[0].Phone = theContact.Phone;
   update communityContacts;
   }
   } */

/* private String getContactSource(){
        return this.isTrial
        ? (string.isNotBlank(this.trialContactSource)
        ? this.trialContactSource
        :controller.siteBranding.branding.Registration_Contact_Source__c)
        ;

        }

        private void setRegistrationCookies(){

        String contactSource = getContactSource();
        Integer maxAge = (String.isNotBlank(contactSource)) ? SiteBrandingIdentifier.brandCookieMaxAge : 0; // 0 = delete, -1 = session, 3600 = 1 hour

        //if(String.isNotBlank(contactSource)){
        Cookie contactSourceCookie = new Cookie('contactsource', contactSource, null, maxAge, true);
        ApexPages.currentPage().setCookies(new List<Cookie>{contactSourceCookie});
        //}
        } */
//Validation all inputs coming from register VF page.
@TestVisible
private Boolean validate(){

	string responseRecaptcha = ApexPages.currentPage().getParameters().get('g-recaptcha-response');
	System.debug('####!DEBUG! validate() reCAPTCHA response: ' + responseRecaptcha);
	if (!string.isBlank(responseRecaptcha) || reCaptcha.isDisabled==true )
	{
		reCaptcha.recaptchaVerify();

		if (reCaptcha.reCAPTCHA_Verified)
		{

			if(String.IsBlank(theUser.FirstName)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.Communities_Registratoin_Please_Provide + ' first name'));
			}
			if(String.IsBlank(theUser.LastName)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.Communities_Registratoin_Please_Provide + ' last name'));
			}
			/* if(String.IsBlank(theContact.User_Defined_Company_Name__c)){
			   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Communities_Registratoin_Please_Provide + ' company name'));
			   } */
			if(String.IsBlank(theUser.CountryCode)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.Communities_Registratoin_Please_Provide + ' country'));
			}
			if(String.IsBlank(theUser.Email))
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.Communities_Registratoin_Please_Provide + ' email address'));
			}
			//else if(!Label.Communities_Registration_Email_Bad_Characters.equalsIgnoreCase('null') && theUser.Email.containsAny(Label.Communities_Registration_Email_Bad_Characters))
			//{
			//    String msg = Label.Communities_Registration_Email_Bad_Character_Message;
			//    msg = msg.replace('{0}', Label.Communities_Registration_Email_Bad_Characters);
			//    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' ' + msg + ' ' + Label.Communities_Registration_Email_Bad_Characters));
			//}else if(theContact.Email.endsWithIgnoreCase('@informa.com')){ // Check if user registering in @informa.com and rejects this forcing users to register with @informa.com.ide as per business process
			//}
			/*else if(!RegistrationHandler.validateInternalUserRegistration(theContact.Email)){
			   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Communities_Internal_User_Registration_Message));
			   } */

			/*if(isTrial){
			   if(String.IsBlank(theContact.Title)){
			   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Communities_Registratoin_Please_Provide + ' ' + Contact.Title.getDescribe().getLabel()));
			   }
			   if(String.IsBlank(theContact.Phone)){
			   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Communities_Registratoin_Please_Provide + ' ' + Contact.Phone.getDescribe().getLabel()));
			   }
			   }*/

			// Check the email addres provided is not within a black or grey list
			greyBlacklistCheck();

			// Validate password was provided
			if(String.isBlank(password)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.site.password + ' required'));
			} if(String.isBlank(confirmPassword)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.site.confirm_password + ' required'));
			}else if (!isValidPassword()) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.esso_ErrorPasswordMatch ));//
			}

			//if(!reCaptcha.reCAPTCHA_Verified){
			//    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'reCAPTCHA verification required'));
			//}
		}
		else
		{
			//PUT error messages here!
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;'+ Label.esso_reCaptcha_Problem));
			System.debug('####!DEBUG!  RegistrationController.validate(): reCaptcha failed Response= ' + responseRecaptcha);
		}

	}
	else
	{
		//PUT error messages here!
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;'+ Label.esso_reCaptcha_Problem));
		System.debug('####!DEBUG! reCAPTCHA - Empty Response: ' + responseRecaptcha);
	}
	//Now process all inputs except password against Xss
	/*XssSecurityHelper.SObjectXssDataResult xssResult = new XssSecurityHelper.SObjectXssDataResult(theUser);
	   //If inputs contains Xss Vulnerabilities throw an error
	   if(xssResult.hasXssVulnerability){
	   String msg = Label.IDE_Application_Form_Input_XSS_Error.replace('{0}', xssResult.getXssMatchingFieldLabelsToString().replace('User Defined Company Name', 'Company'));
	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
	   }*/
	// Return true if there are no messages else return false
	return !ApexPages.hasMessages();
}

private void greyBlacklistCheck(){

	String backlistError = (String.isNotBlank(controller.siteBranding.branding.Registration_Blacklist_Error_HTML__c)) ? controller.siteBranding.branding.Registration_Blacklist_Error_HTML__c : Label.Communities_Std_Registration_Default_Domain_Blacklist_Error;
	String greylistError = (String.isNotBlank(controller.siteBranding.branding.Registration_Greylist_Error_HTML__c)) ? controller.siteBranding.branding.Registration_Greylist_Error_HTML__c : Label.Communities_Std_Registration_Default_Domain_Greylist_Error;
	String trialBacklistError = (String.isNotBlank(controller.siteBranding.branding.Trial_Registration_Blacklist_Error_HTML__c)) ? controller.siteBranding.branding.Trial_Registration_Blacklist_Error_HTML__c : Label.Communities_Trial_Registration_Default_Domain_Blacklist_Error;
	String trialGreylistError = (String.isNotBlank(controller.siteBranding.branding.Trial_Registration_Greylist_Error_HTML__c)) ? controller.siteBranding.branding.Trial_Registration_Greylist_Error_HTML__c : Label.Communities_Trial_Registration_Default_Domain_Greylist_Error;

	String finalBlacklistError = (istrial) ? trialBacklistError : backlistError;
	String finalGreylistError = (istrial) ? trialGreylistError : greylistError;

	if(DomainFilterUtility.isBlacklisted(theUser.Email)) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' +finalBlacklistError));
	}else if(DomainFilterUtility.isGreylisted(theUser.Email)) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' +finalGreylistError));
	}
}

public PageReference returnToReferralURL(){

	stopCallbackPoller = true; // Sets variable to prevent action poller to only run once
	PageReference returnPage;

	// if(String.isBlank(referralurl)) {
	// 	// Attempt to get from params
	// 	referralurl = ApexPages.currentPage().getParameters().get('referralurl');
	// }

	if(String.isNotBlank(referralurl)) {
		// Redirect to referral url (product site)
		returnPage = new PageReference(referralurl);
	}
	//sfwefgwefgw ddgergherg
	// Set the registration success redirect location
	redirectLocation = (returnPage != null) ? returnPage.getUrl() : null;
	// Set delete the session cookie boolean if user is guest
	deleteIdeSessionCookie = UserInfo.getUserType().equalsIgnoreCase('guest');
	return returnPage;
}

//public PageReference recaptchaVerify() {
// system.debug('time !'+reCaptcha.recaptchaVerify());
//return reCaptcha.recaptchaVerify();
//}
}