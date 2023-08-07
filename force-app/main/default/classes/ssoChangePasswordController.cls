/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-20)]
 * Created On   :   May 16 2019
 * @description :   [An apex page controller that exposes the change password functionality]
 * Test Class   :   ssoChangePasswordControllerTest
 * Modification Log-----
 * Modified by  :   Shay.Spoonmore@informa.com (20200720)
 **/
public with sharing class ssoChangePasswordController {

public String oldPassword {get; set { oldPassword = value == null ? value : value.trim(); } }
public String newPassword {get; set { newPassword = value == null ? value : value.trim(); } }
public String verifyNewPassword {get; set { verifyNewPassword = value == null ? value : value.trim(); } }
public Boolean isFederated {get; private set;}
public User userforUpdate { get;  set;}        // Used on visualforce page to capture registration data
public User userDetail  {get;  set;}        // Used on visualforce page to capture registration data
public Boolean privacyPolicy { get;  set;}
//public String  userId { get;  set;}
//public String  fName { get;  set;}
// public String  lName { get;  set;}
// public String  country { get;  set;}
private CommunityBaseController controller {get; set;}

@TestVisible
private Boolean successfulPWChangeTest {get; set;}     // variable used in unit tests to mimic process of changing passord standard method returns null in test classes

// CONSTRUCTOR
public ssoChangePasswordController(CommunityBaseController controller) {
	System.debug('####!DEBUG! UserInfo.getUserId(): ' + UserInfo.getUserId() + '; ' + UserInfo.getUserName());
	//userId = UserInfo.getUserId();
	this.controller = controller;
	successfulPWChangeTest = false;
	// Set the is federated flag based on the current user
	// used in page logic to hide change password fields and display message to user
	this.isFederated = false;
	userforUpdate= new User();
	
	userDetail=[select Id,FirstName,LastName,country,CountryCode,esso_Privacy_Policy_Agreed__c From User where Id=:UserInfo.getUserId()];
	// fName=userDetail.FirstName;
	// lName=userDetail.LastName;
	//country=userDetail.country;
	// system.debug('userid===='+UserInfo.getUserId());
	//system.debug('userDetail==='+userDetail);
	/* if(!Auth.CommunitiesUtil.isGuestUser()){
	      isFederated = [SELECT Is_Federated__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Is_Federated__c;
	   }*/
}
public PageReference changePassword() {

	PageReference returnPage;

	//if(validate() && !isFederated) {
	if(validate())
	{
		returnPage = IdentityAuth.changePassword(UserInfo.getUserId(), newPassword, verifyNewPassword, oldpassword);
		updateUser();


		if (returnPage != null || (Test.isRunningTest() && successfulPWChangeTest))
		{

			if  (String.isNotBlank(controller.siteBranding.referralUrl))
			{
				returnPage = new PageReference(controller.siteBranding.referralUrl);
			}

			//Do business email verification and redirect back to provider to verify and call reghandler to re-map current user to provider user
			esso_User essoUser = new esso_User();
			PageReference redirectToProvider = essoUser.businessEmailVerified(UserInfo.getUserName());
			returnPage = (redirectToProvider == null ? returnPage : redirectToProvider);

		}
	}


	return returnPage;
}

private Boolean validate(){

	// check if old password has been provided if password has not expired and is being changed
	if(!Site.isPasswordExpired() && String.isBlank(oldPassword)) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.site.old_password + ' required'));
	}

	// Validate password was provided
	if(String.isBlank(newPassword)) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.site.new_password + ' required'));
	} if(String.isBlank(verifyNewPassword)) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.site.verify_new_password + ' required'));
	}else if (!isValidPassword()) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.esso_ErrorPasswordMatch));
	}

	return !ApexPages.hasMessages();
}

public PageReference updateUser() {
	//Update User
	User u = [Select Id,FirstName,LastName,CountryCode,esso_Privacy_Policy_Agreed__c From User Where Id=:UserInfo.getUserId()];

	if(string.isBlank(u.FirstName))
	{
		u.FirstName = userforUpdate.FirstName;
	}
	if(u.LastName=='{updatelast}')
	{
		u.LastName  = userforUpdate.LastName;
	}
	else{
		u.LastName=u.LastName;
	}
	if(string.isBlank(u.CountryCode))
	{
		u.Countrycode = userforUpdate.Countrycode;
	}
	if(u.esso_Privacy_Policy_Agreed__c==false)
	{
		u.esso_Privacy_Policy_Agreed__c= privacyPolicy;
	}


	//20200612 Anybody who resets password is a local account - set to Informa Markets Identity
	u.esso_LastLoginProviderType__c = esso_Configuration.DEFAULT_PROVIDER;
	u.esso_LastLoginProviderId__c = UserInfo.getUserId();

	Database.SaveResult userResult = Database.update(u, false);
	return null;
}

private boolean isValidPassword() {
	return newPassword == verifyNewPassword;
}
}