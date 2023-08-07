/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Shay.Spoonmore@informa.com (20200821)
 * Created On   :   20200710
 * @description :   [One place to get all user info]
 * Test Class   :   esso_UserTest
 * Modification Log-----
 * Modified by  :   Shay.Spoonmore@informa.com (20200821)
 **/
@isTest
public with sharing class esso_UserTest {
public static string guestName= 'Informa Markets Site Guest User';



@testSetup static void setup()
{
	esso_ConfigurationTest.setupData();
	esso_UserTest.setupData();
}

public static user guest {get {

				  if (guest == null)
				  {
					  guest = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' and name =:guestName AND IsActive = true LIMIT 1];
				  }

				  return guest;
			  }
	                  set;}

public static user imIdP {get {

				  if (imIdP == null)
				  {
					  esso_UserTest.setupData();
				  }

				  return imIdP;
			  }
	                  set;}

public static user imIdpBusiness {get {

				  if (imIdpBusiness == null)
				  {
					  esso_UserTest.setupData();
				  }

				  return imIdpBusiness;
			  }
	                  set;}

static testmethod void testUserData() {
	esso_User essoUser = new esso_User();
	user u = essoUser.getUserById(esso_UserTest.imIdP.Id);
	System.assertEquals(true,(u != null), 'IM.IdP@informa.com user by Id');

	u = essoUser.getUserByUsername(esso_UserTest.imIdP.Username);
	System.assertEquals(true,(u != null), 'IM.IdP@informa.com user by username');

	system.debug('#### !DEBUG! user('+esso_UserTest.imIdP.Username+')('+esso_UserTest.imIdP.Id+'): ' + u);

	System.runAs(u)
	{
		System.assertEquals(u.Id,esso_User.getCurrentWebUser.Id, 'The value should be current user');
	}

	system.debug('#### !DEBUG! guest user: ' + guest);
	System.runAs(guest)
	{
		System.assertEquals(esso_User.isGuestUser(), true, 'The value should be guest user');
	}

}

static testmethod void testAuthData() {

	esso_User essoUser = new esso_User();
	map<string,string> a = new map<string,string>();
	a.put('Test1', 'Test1');
	a.put('Test2', 'Test2');
	a.put('language', 'en_US');

	Auth.UserData data = new Auth.UserData(esso_UserTest.imIdP.Username,esso_UserTest.imIdP.FirstName,esso_UserTest.imIdP.LastName,'', esso_UserTest.imIdP.Username
	                                       ,null, 'testuserlong', 'en_US', 'linkedin-test',null, a);
	//Update esso_User_Provider_Info__c
	esso_User.collectAuthProviderInfo(esso_UserTest.imIdP.Id,data,data.provider);
	esso_User_Provider_Info__c upi = essoUser.getUserProviderInfoByUserId(esso_UserTest.imIdP.Id)[0];
	System.assertEquals(upi.UserId__c, esso_UserTest.imIdP.Id,'The value should be return true');

	//Update esso_User_Provider_Info__c
	data.email = esso_UserTest.imIdP.Username + '-Update';
	esso_User.collectAuthProviderInfo(esso_UserTest.imIdP.Id,data,data.provider);
	List<esso_User_Provider_Info__c> upis = essoUser.getUserProviderInfoByUserId(esso_UserTest.imIdP.Id);

	System.assertEquals(true,(upis.size() >= 5), 'The value should be return true');
	System.assertEquals(data.email,(esso_UserTest.imIdP.Username + '-Update'), 'The value should be return true');

    //Update email back esso_User_Provider_Info__c
    a = new map<string,string>();
	a.put('Test1', 'update');
	a.put('Test2', 'update');
	a.put('language', 'en_US');

	data = new Auth.UserData(esso_UserTest.imIdP.Username,esso_UserTest.imIdP.FirstName,esso_UserTest.imIdP.LastName,'', esso_UserTest.imIdP.Username
	                                       ,null, 'testuserlong', 'en_US', 'linkedin-test',null, a);
    data.email = 'change.' + esso_UserTest.imIdP.Username ;
    data.Username = 'change.' + esso_UserTest.imIdP.Username ;
	esso_User.collectAuthProviderInfo(esso_UserTest.imIdP.Id,data,data.provider);

	//Get esso_User_Provider_Info__c
	System.assertEquals(esso_UserTest.imIdP.Id,essoUser.getUserProviderInfoByUserId(esso_UserTest.imIdP.Id, data.provider)[0].UserId__c, 'User exist in esso_User_Provider_Info__c');


	set<string> providers = new set<string>();
	set<string> identifiers = new set<string>();

	providers.add(esso_RegHandlerInforma.PROVIDER);
	providers.add(esso_RegHandlerLinkedIn.PROVIDER);
	providers.add(data.provider);

	identifiers.add(esso_UserTest.imIdP.Username);
	identifiers.add(esso_UserTest.imIdP.Username + 'not');

	System.assertEquals(true,(essoUser.getUserProviderInfoByUserProviderIds(providers, identifiers).size()>=3), '3 or more records should exist in User exist in esso_User_Provider_Info__c');

	System.assertEquals(true,(essoUser.getThirdPartyLinkByUserId(esso_RegHandlerInforma.PROVIDER, esso_UserTest.imIdP.Username).size()==0), 'No records should exist ThirdPartyAccountLink');

	System.assertEquals(true,esso_User.isInformaEmployee(esso_UserTest.imIdP.Username), 'Is a informa Employee?');

}

static testmethod void testUserMixedDmlOperations()
{
    esso_User essoUser = new esso_User();
	map<string,string> a = new map<string,string>();
	a.put('Test1', esso_RegHandlerLinkedIn.PROVIDER);
	a.put('Test2', esso_RegHandlerLinkedIn.PROVIDER);
	a.put('language', 'en_US');

	Auth.UserData data = new Auth.UserData(esso_UserTest.imIdP.Username,esso_UserTest.imIdP.FirstName,esso_UserTest.imIdP.LastName,'', esso_UserTest.imIdP.Username
	                                       ,null, esso_UserTest.imIdP.Username, 'en_US', esso_RegHandlerLinkedIn.PROVIDER,null, a);

    //Trigger DML mixed object error and fire future update
    test.startTest();
    data.email= 'DMLissue.' + esso_UserTest.imIdP.Username;
    //data.Username = data.email;
    User uDmlMix = new User(Id=esso_UserTest.imIdP.Id, email=esso_UserTest.imIdP.Email, LastName = esso_UserTest.imIdP.LastName);
    update uDmlMix;
    esso_User.collectAuthProviderInfo(esso_UserTest.imIdP.Id,data,data.provider);
    test.stopTest();
    System.assertEquals(data.Email,essoUser.getUserProviderInfoByUserId(esso_UserTest.imIdP.Id, data.provider)[0].Email__c, 'Update User and esso_User_Provider_Info__c is Mixed DML oppertion');

}

static testmethod void testCookies()
{
	PageReference signinPage = Page.signin;
	Test.setCurrentPage(signinPage);

	System.runAs(guest)
	{

		Test.startTest();

		esso_User.businessEmailSetCookie(esso_UserTest.imIdP.Username, esso_UserTest.imIdP.Id, esso_RegHandlerLinkedIn.PROVIDER);

		Cookie businessEmailCookie = esso_User.businessEmailGetCookie();

		System.assertEquals(true,(businessEmailCookie != null), 'businessEmailCookie has value');

		esso_User.businessEmailExpireCookie();

		businessEmailCookie = esso_User.businessEmailGetCookie();

		System.assertEquals(true,String.isBlank( businessEmailCookie.getValue()), 'businessEmailCookie has expired');




		esso_User.resetPasswordSelfRegSetCookie(esso_UserTest.imIdP.Username);

		Cookie resetPasswordCookie = esso_User.resetPasswordSelfRegGetCookie();

		System.assertEquals(true,(resetPasswordCookie != null), 'resetPasswordSelfReg has value');

		esso_User.resetPasswordSelfRegExpireCookie();

		resetPasswordCookie = esso_User.resetPasswordSelfRegGetCookie();

		System.assertEquals(true,String.isBlank( resetPasswordCookie.getValue()), 'resetPasswordSelfReg has expired');




		esso_User.resetPasswordSetCookie(esso_UserTest.imIdP.Username);

		resetPasswordCookie = esso_User.resetPasswordGetCookie();

		System.assertEquals(true,(resetPasswordCookie != null), 'resetPasswordCookie has value');

		esso_User.resetPasswordExpireCookie();

		resetPasswordCookie = esso_User.resetPasswordGetCookie();

		System.assertEquals(true,String.isBlank( resetPasswordCookie.getValue()), 'resetPasswordCookie has expired');


		Test.stopTest();
	}

}

static testmethod void testEmployeeRedirect()
{
	PageReference signinPage = Page.signin;
	Test.setCurrentPage(signinPage);

	System.runAs(guest)
	{

		Test.startTest();
		esso_User essoUser = new esso_User();


		signinPage = essoUser.employeeRedirect(esso_UserTest.imIdP.Username);
		system.debug('#### !DEBUG! employeeRedirect Url: ' + signinPage.getUrl());

		System.assertEquals(signinPage.getUrl(),'/services/auth/sso/IM_IdP_Informa', 'Is employeeRedirect /services/auth/sso/IM_IdP_Informa');

		Test.stopTest();
	}
}

static testmethod void testBusinessEmailVerified()
{
	PageReference signinPage = Page.signin;
	Test.setCurrentPage(signinPage);

	System.runAs(guest)
	{

		Test.startTest();
        esso_User essoUser = new esso_User();
        


		esso_User.businessEmailSetCookie(esso_UserTest.imIdP.Username, esso_UserTest.imIdpBusiness.Id, esso_RegHandlerLinkedIn.PROVIDER);


		signinPage = essoUser.businessEmailVerified(esso_UserTest.imIdP.Username);
		system.debug('#### !DEBUG! BusinessEmailRedirect Url: ' + signinPage.getUrl());

		System.assertEquals(signinPage.getUrl(),'/services/auth/sso/IM_IdP_LinkedIn', 'Is Social Redirect /services/auth/sso/IM_IdP_LinkedIn');

		Test.stopTest();
	}
}

static testmethod void testCheckBusinesEmailVerified() {

    esso_User essoUser = new esso_User();
    User u = new User(Id=esso_UserTest.imIdpBusiness.Id, esso_Business_Email_Verified__c=System.Now(),esso_Business_Email__c=esso_UserTest.imIdp.Email);
    update u;
    u = essoUser.CheckBusinesEmailVerified(esso_UserTest.imIdpBusiness.Username, esso_RegHandlerLinkedIn.PROVIDER);
    System.assertEquals(esso_UserTest.imIdp.Username,u.Username, 'User should switch to the business email user');

    //reset user
    u = new User(Id=esso_UserTest.imIdpBusiness.Id, esso_Business_Email_Verified__c=null,esso_Business_Email__c=null);
    update u;

}


public static void setupData()
{
    esso_User essoUser = new esso_User();
    
    //Employee/test user data
	User u = essoUser.getUserByUsername('IM.IdP@informa.com');
	if ( u == null)
	{
		
		u = new User();
		u.Username = 'IM.IdP@informa.com';
		u.Email = u.Username;
		u.FirstName = 'IM-IdP-First';
		u.LastName = 'IM-IdP-Last';
		u.Countrycode = 'US';
		u.CommunityNickname = RegistrationHandler.generateCommunityNickname(u);
		u.esso_Privacy_Policy_Agreed__c=  true;
		u.LocaleSidKey = 'en_US';
		u.LanguageLocaleKey = u.LocaleSidKey;
		u.TimeZoneSidKey = 'GMT';
		u.ProfileID = esso_User.ProfileId; // Profile that's associated with the EI license
		u.EmailEncodingKey = 'UTF-8';
		u.Alias = u.Email.length() > 8 ? u.Email.substring(0,8) : u.Email;
		u.esso_LastLoginProviderType__c = esso_Configuration.DEFAULT_PROVIDER;
		u.esso_QA_Business_Email__c=null;
		u.esso_Business_Email__c=null;
		u.esso_Business_Email_Verified__c=null;
		u.esso_Is_Informa_Employee__c = false;
		insert u;

		//Create provider data
		esso_User_Provider_Info__c upi = new esso_User_Provider_Info__c();
		list<esso_User_Provider_Info__c> upis = new list<esso_User_Provider_Info__c>();
		upi = new esso_User_Provider_Info__c(AttributeMap__c='Bla Bla..', Email__c='IM.IdP@informa.com', Identifier__c='IM.IdP@informa.com', Name = esso_RegHandlerInforma.PROVIDER,UserId__c=u.Id );
		upis.add(upi);
		upi = new esso_User_Provider_Info__c(AttributeMap__c='Bla Bla..', Email__c='IM.IdP@informa.com', Identifier__c='IM.IdP@informa.com', Name = esso_RegHandlerLinkedIn.PROVIDER,UserId__c=u.Id );
		upis.add(upi);
		upi = new esso_User_Provider_Info__c(AttributeMap__c='Bla Bla..', Email__c='IM.IdP@informa.com', Identifier__c='IM.IdP@informa.com', Name = 'facebook',UserId__c=u.Id );
		upis.add(upi);
		upi = new esso_User_Provider_Info__c(AttributeMap__c='Bla Bla..', Email__c='IM.IdP@informa.com', Identifier__c='IM.IdP@informa.com', Name = 'git',UserId__c=u.Id );
		upis.add(upi);
		insert upis;

	}

    imIdP = u;
    

    //Business email user data
    u = essoUser.getUserByUsername('IM.IdP@business.com');
	if ( u == null)
	{
		u = new User();
		u.Username = 'IM.IdP@business.com';
		u.Email = u.Username;
		u.FirstName = 'IM-IdP-First';
		u.LastName = 'IM-IdP-Last';
		u.Countrycode = 'US';
		u.CommunityNickname = RegistrationHandler.generateCommunityNickname(u);
		u.esso_Privacy_Policy_Agreed__c=  true;
		u.LocaleSidKey = 'en_US';
		u.LanguageLocaleKey = u.LocaleSidKey;
		u.TimeZoneSidKey = 'GMT';
		u.ProfileID = esso_User.ProfileId; // Profile that's associated with the EI license
		u.EmailEncodingKey = 'UTF-8';
		u.Alias = u.Email.length() > 8 ? u.Email.substring(0,8) : u.Email;
		u.esso_LastLoginProviderType__c = esso_Configuration.DEFAULT_PROVIDER;
		u.esso_QA_Business_Email__c=null;
		u.esso_Business_Email__c=null;
		u.esso_Business_Email_Verified__c=null;
		u.esso_Is_Informa_Employee__c = false;

        insert u;
        
		//Create provider data
		esso_User_Provider_Info__c upi = new esso_User_Provider_Info__c();
		list<esso_User_Provider_Info__c> upis = new list<esso_User_Provider_Info__c>();
		upi = new esso_User_Provider_Info__c(AttributeMap__c='Bla Bla..', Email__c='IM.IdP@informa.com', Identifier__c='IM.IdP@business.com', Name = esso_RegHandlerInforma.PROVIDER,UserId__c=u.Id );
		upis.add(upi);
		upi = new esso_User_Provider_Info__c(AttributeMap__c='Bla Bla..', Email__c='IM.IdP@informa.com', Identifier__c='IM.IdP@business.com', Name = esso_RegHandlerLinkedIn.PROVIDER,UserId__c=u.Id );
		upis.add(upi);
		upi = new esso_User_Provider_Info__c(AttributeMap__c='Bla Bla..', Email__c='IM.IdP@informa.com', Identifier__c='IM.IdP@business.com', Name = 'facebook',UserId__c=u.Id );
		upis.add(upi);
		upi = new esso_User_Provider_Info__c(AttributeMap__c='Bla Bla..', Email__c='IM.IdP@informa.com', Identifier__c='IM.IdP@business.com', Name = 'git',UserId__c=u.Id );
		upis.add(upi);
		insert upis;

	}

    imIdpBusiness = u;

}

public static void setTestUserBusinessBack()
{

	//set user back to defaults
	User u = new User(Id=esso_UserTest.imIdpBusiness.Id,username=esso_UserTest.imIdpBusiness.Username,FirstName=esso_UserTest.imIdpBusiness.FirstName,LastName=esso_UserTest.imIdpBusiness.LastName,CountryCode=esso_UserTest.imIdpBusiness.CountryCode, esso_Privacy_Policy_Agreed__c=true
	,esso_QA_Business_Email__c=esso_UserTest.imIdpBusiness.esso_QA_Business_Email__c, esso_Business_Email__c=esso_UserTest.imIdpBusiness.esso_Business_Email__c);
	update u;

}

}