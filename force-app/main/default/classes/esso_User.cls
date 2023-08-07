/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Shay.Spoonmore@informa.com (20200710)
 * Created On   :   20200710
 * @description :   [One place to get all user info]
 * Test Class   :   esso_UserTest
 * Modification Log-----
 * Modified by  :   Shay.Spoonmore@informa.com (20200710)
 **/

public without sharing class esso_User {
public static final String INFORMA_EMAIL_SUFFIX = '@informa.com';


public static Boolean isInformaEmployee(String username)
{
	return (String.isNotBlank(username)?username.endsWithIgnoreCase(INFORMA_EMAIL_SUFFIX):false);
}

public static String ProfileId {
	get {
		if (ProfileId == null)
		{
			Profile p = [Select Id,name From Profile where name=: esso_Configuration.setting.Identity_Profile_Name__c Limit 1];
			System.debug('####!DEBUG! Cached IM IdP Profile: ' + p);
			ProfileId = p.Id;
		}

		return ProfileId;
	}
	private set;
}


public static User getCurrentWebUser {
	get {


		if (getCurrentWebUser  == null)
		{
			esso_User u = new esso_User();

			getCurrentWebUser = u.getUserById(UserInfo.getUserId());
		}

		return getCurrentWebUser;
	}

	private set;
}

public static Boolean isGuestUser()
{
	return UserInfo.getUserType().equalsIgnoreCase('guest');
}

public user getUserById(string userId)
{
	List<User> u = new List<User>();
	u = [SELECT Id, IsActive, FirstName, LastName, Username, CreatedDate, Email, CountryCode,country, esso_Privacy_Policy_Agreed__c,
	     LocaleSidKey,LanguageLocaleKey,esso_LocalLanguage__c,esso_BrandId__c,esso_BrandName__c,esso_BrandSupportEmail__c,
	     esso_LastLoginProviderType__c, esso_LastLoginProviderId__c, esso_Business_Email__c, esso_QA_Business_Email__c, ProfileId,esso_Business_Email_Verified__c,
	     esso_Is_Informa_Employee__c,
	     MobilePhone,Phone,Street,Title
	     FROM User WHERE ProfileId=: esso_User.ProfileId and Id = : userId LIMIT 1];


	return u.size() == 0 ? null : u[0];
}

public user getUserByUsername(string username)
{
	List<User> u = new List<User>();
	u = [SELECT Id, IsActive, FirstName, LastName, Username, CreatedDate, Email, CountryCode,country, esso_Privacy_Policy_Agreed__c,
	     LocaleSidKey,LanguageLocaleKey,esso_LocalLanguage__c,esso_BrandId__c,esso_BrandName__c,esso_BrandSupportEmail__c,
	     esso_LastLoginProviderType__c, esso_LastLoginProviderId__c, esso_Business_Email__c, esso_QA_Business_Email__c, ProfileId,esso_Business_Email_Verified__c,
	     esso_Is_Informa_Employee__c,
	     MobilePhone,Phone,Street,Title
	     FROM User WHERE ProfileId=: esso_User.ProfileId and Username = : username LIMIT 1];
	return u.size() == 0 ? null : u[0];
}

public List<ThirdPartyAccountLink> getThirdPartyLinkByUserId(string userId, string provider)//used in the reg handler to check for  provider linked accounts
{

	List<ThirdPartyAccountLink> tpal = new List<ThirdPartyAccountLink>();
	tpal = [SELECT Handle,Id,IsNotSsoUsable,Provider,RemoteIdentifier,SsoProviderId,SsoProviderName,ThirdPartyAccountLinkKey,UserId
	        FROM ThirdPartyAccountLink WHERE UserId=:userId AND Provider=:provider LIMIT 1];

	system.debug('#### !DEBUG! getThirdPartyLinkByUserId: ' + userId + ';' + provider + '; ' + tpal);

	return tpal;
}



public list<esso_User_Provider_Info__c> getUserProviderInfoByUserId(string userId)
{

	return [SELECT AttributeMap__c,CreatedById,CreatedDate,CurrencyIsoCode,Email__c,Id,Identifier__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,SystemModstamp,UserId__c,Username__c
	        FROM esso_User_Provider_Info__c WHERE UserId__c=: userId ];//
}

public list<esso_User_Provider_Info__c> getUserProviderInfoByUserId(string userId, string provider)
{
	return [SELECT AttributeMap__c,CreatedById,CreatedDate,CurrencyIsoCode,Email__c,Id,Identifier__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,SystemModstamp,UserId__c,Username__c
	        FROM esso_User_Provider_Info__c WHERE UserId__c=: userId and name=: provider];//
}

public list<esso_User_Provider_Info__c> getUserProviderInfoByUserId(string userId, string provider,  string identifier)// used for getting exact user provider info
{
	return [SELECT AttributeMap__c,CreatedById,CreatedDate,CurrencyIsoCode,Email__c,Id,Identifier__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,SystemModstamp,UserId__c,Username__c
	        FROM esso_User_Provider_Info__c WHERE UserId__c=: userId and name=: provider and Identifier__c=: identifier ];//
}

public list<esso_User_Provider_Info__c> getUserProviderInfoByUserProviderIds(set<string> providers, set<string> identifiers)// used for getting all info for idToken and UserInfo atributes
{
	return [SELECT AttributeMap__c,CreatedById,CreatedDate,CurrencyIsoCode,Email__c,Id,Identifier__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,SystemModstamp,UserId__c,Username__c
	        FROM esso_User_Provider_Info__c WHERE Name =: providers AND Identifier__c=: identifiers];//
}

public Static void businessEmailSetCookie(String username, String userId, string provider){

	//create cookie to kick off business email verification process
	Integer maxAge = 1800; // -1 = session, 0 = delete, 900secs 15min
	Cookie businessEmailCookie = new Cookie('beusr', username + ';' + userId + ';' + provider, null, maxAge, true, 'Strict');
	ApexPages.currentPage().setCookies(new List<Cookie> {businessEmailCookie});
}

public Static Cookie businessEmailGetCookie(){
	return ApexPages.currentPage().getCookies().get('beusr');
}

public Static void businessEmailExpireCookie(){

	//expire cookie to end business email verification process
	Integer maxAge = 0; // -1 = session, 0 = delete, 900secs 15min
	Cookie businessEmailCookie = new Cookie('beusr', '', null, maxAge, true, 'Strict');
	ApexPages.currentPage().setCookies(new List<Cookie> {businessEmailCookie});
}

public Static void resetPasswordSetCookie(String username){

	//create cookie to kick off reset email verification process
	Integer maxAge = 120; // -1 = session, 0 = delete, 900secs 15min
	Cookie businessEmailCookie = new Cookie('resetusr', username, null, maxAge, true, 'Strict');
	ApexPages.currentPage().setCookies(new List<Cookie> {businessEmailCookie});
}

public Static void resetPasswordExpireCookie(){

	//expire cookie to end reset email verification process
	Integer maxAge = 0; // -1 = session, 0 = delete, 900secs 15min
	Cookie businessEmailCookie = new Cookie('resetusr', '', null, maxAge, true, 'Strict');
	ApexPages.currentPage().setCookies(new List<Cookie> {businessEmailCookie});
}

public Static Cookie resetPasswordGetCookie(){
	return ApexPages.currentPage().getCookies().get('resetusr');
}

public Static void resetPasswordSelfRegSetCookie(String username){

	//create cookie to kick off reset email verification process
	Integer maxAge = 120; // -1 = session, 0 = delete, 900secs 15min
	Cookie businessEmailCookie = new Cookie('selfregusr', username, null, maxAge, true, 'Strict');
	ApexPages.currentPage().setCookies(new List<Cookie> {businessEmailCookie});
}

public Static void resetPasswordSelfRegExpireCookie(){

	//expire cookie to end reset email verification process
	Integer maxAge = 0; // -1 = session, 0 = delete, 900secs 15min
	Cookie businessEmailCookie = new Cookie('selfregusr', '', null, maxAge, true, 'Strict');
	ApexPages.currentPage().setCookies(new List<Cookie> {businessEmailCookie});
}

public Static Cookie resetPasswordSelfRegGetCookie(){
	return ApexPages.currentPage().getCookies().get('selfregusr');
}

// public Static void userTestingCleanup()
// {

// 	//Cleanup script for testing
// 	//Revoke third party account link
// 	List<ThirdPartyAccountLink> tpal = new List<ThirdPartyAccountLink>();
// 	tpal = [SELECT Handle,Id,IsNotSsoUsable,Provider,RemoteIdentifier,SsoProviderId,SsoProviderName,ThirdPartyAccountLinkKey,UserId
// 	        FROM ThirdPartyAccountLink WHERE Provider in ('LinkedIn') ];

// 	system.debug('#### !DEBUG! ThirdPartyAccountLink: ' + tpal.size() );
// 	for (ThirdPartyAccountLink r : tpal)
// 	{
// 		system.debug('#### !DEBUG! Auth.AuthToken.revokeAccess(\'' + r.SsoProviderId + '\',\'' + r.Provider+ '\',\'' + r.UserId+ '\',\'' +  r.RemoteIdentifier + '\'): ' + Auth.AuthToken.revokeAccess(r.SsoProviderId, r.Provider, r.UserId, r.RemoteIdentifier));
// 		//Auth.AuthToken.revokeAccess(r.SsoProviderId, r.Provider, r.UserId, r.RemoteIdentifier);
// 	}

// 	// make all users inactive with a diff username
// 	List<User> users = [SELECT Id, IsActive, FirstName, LastName, Username, CreatedDate, Email, CountryCode,country, esso_Privacy_Policy_Agreed__c,
// 	                    LocaleSidKey,LanguageLocaleKey,esso_LocalLanguage__c,esso_BrandId__c,esso_BrandName__c,esso_BrandSupportEmail__c,
// 	                    esso_LastLoginProviderType__c, esso_LastLoginProviderId__c, esso_Business_Email__c, esso_QA_Business_Email__c, ProfileId,esso_Business_Email_Verified__c
// 	                    FROM User WHERE ProfileId=: esso_User.ProfileId AND IsActive=true];

// 	List<User> updateUsers = new List<User>();
// 	for (User u : users) {

// 		User updateUser = new User(Id=u.Id);
// 		updateUser.IsActive = false;

// 		string username =  u.Username.split('@')[0] + '@del.' + DateTime.now().format('yyyyMMddHHmmssS');
// 		if (username.length() > 80)
// 		{
// 			username = username.left(80);
// 		}


// 		updateUser.username = username;


// 		updateUsers.add(updateUser);
// 	}


// 	system.debug('#### !DEBUG! updateUsers : ' + updateUsers );
// 	update updateUsers;

// }

public PageReference employeeRedirect(String username)
{
	PageReference informaRedirect = null;

	if(isInformaEmployee(username) && esso_Configuration.isInformaEmployeeIdentity)
	{

		if (String.isNotBlank(esso_Configuration.informaEmployeeIdentity.Auth_Provider_URL_Suffix)) 
		{
			informaRedirect = new PageReference('/services/auth/sso/' + esso_Configuration.informaEmployeeIdentity.Auth_Provider_URL_Suffix);
		}

	}


	Return informaRedirect;
}

public PageReference businessEmailVerified(String username)
{
	System.debug('#### !DEBUG!  businessEmailVerified() :' );

	Cookie be = esso_User.businessEmailGetCookie();
	PageReference providerRedirect = null;

	if(be !=null )
	{
		System.debug('#### !DEBUG!  businessEmailVerified(): ' + be.getValue());
		List<String> v = be.getValue().split(';');
		string businessEmail= v[0];
		string providerLinkedUserId=v[1];
		string provider =v[2];

		//expire business email verification cookie
		esso_User.businessEmailExpireCookie();

		if(username.equalsIgnoreCase(businessEmail))
		{

			//Get current and provider linked user
			esso_User essoUser= new esso_User();
			user currentUser = essoUser.getUserByUsername(username);
			user providerLinkedUser = essoUser.getUserById(providerLinkedUserId);

			//Get provider redirect url
			esso_Configuration_Social_Networks__c si = [SELECT Auth_Provider_Id__c,Auth_Provider_Name__c,Auth_Provider_URL_Suffix__c,Id,Name
			                                            FROM esso_Configuration_Social_Networks__c WHERE Enabled__c = true AND Name=:provider Limit 1];

			//Revoke previously account linkage
			boolean isProviderLinkedEmailRevoked= false;
			isProviderLinkedEmailRevoked = (test.isRunningTest()? true : Auth.AuthToken.revokeAccess(si.Auth_Provider_Id__c, provider.toLowerCase(), providerLinkedUser.Id, providerLinkedUser.esso_LastLoginProviderId__c));
			system.debug('#### !DEBUG! Revoke linkage to old user: ' + providerLinkedUser.username  + ';' + isProviderLinkedEmailRevoked  + ';' + providerLinkedUser.esso_LastLoginProviderId__c);

			//update current user business email question to yes
			List<User> users = new List<User>();
			User u = new User();
			u.id = currentUser.Id;
			u.esso_QA_Business_Email__c = 'Yes';
			u.esso_Business_Email__c = null;
			u.esso_LastLoginProviderId__c = providerLinkedUser.esso_LastLoginProviderId__c;
			u.esso_LastLoginProviderType__c = providerLinkedUser.esso_LastLoginProviderType__c;
			users.add(u);

			//update provider linked user as verified
			u = new User();
			u.Id = providerLinkedUser.Id;
			u.esso_Business_Email__c = businessEmail;
			u.esso_Business_Email_Verified__c = System.now();
			u.esso_QA_Business_Email__c = 'No';
			users.add(u);
			List<Database.SaveResult> userResult = Database.update(users, false);

			//Redirect customer back to provider to link verified user
			System.debug('#### !DEBUG! businessEmailVerified(): esso_Configuration_Social_Networks__c - ' + si);
			providerRedirect =  (si != null) ? new PageReference('/services/auth/sso/' + si.Auth_Provider_URL_Suffix__c) : null;

		}

	}

	Return providerRedirect;
}

public static void collectAuthProviderInfo(String userId,Auth.UserData data,String provider)
{
	esso_User essoUser = new esso_User();
	list<esso_User_Provider_Info__c> uspibui = essoUser.getUserProviderInfoByUserId(userId,provider,data.identifier);
	if (uspibui == null || uspibui.size()==0) 
	{
		esso_User_Provider_Info__c i = new esso_User_Provider_Info__c();
		i.AttributeMap__c=data.attributeMap.toString();
		i.Email__c=data.email;
		i.Name=provider;
		i.Identifier__c=data.identifier;
		i.UserId__c=userId;
		i.Username__c=data.username;
		System.debug('#### !DEBUG! collectAuthProviderInfo-provider: ' + provider + '; insert: ' + i);
		insert i;
		

	}
	else 
	{
		Boolean isUpdate = false;
		esso_User_Provider_Info__c u = uspibui[0];
		
		if (u.AttributeMap__c!=data.attributeMap.toString()) 
		{
			u.AttributeMap__c=data.attributeMap.toString();
			isUpdate = true;
		}
		
		if (u.Email__c!=data.email) {
			u.Email__c=data.email;
			isUpdate = true;
		}

		//if (u.Identifier__c!=data.identifier) {
		//	u.Identifier__c=data.identifier;
		//	isUpdate = true;
		//}

		if (u.Username__c!=data.username) {
			u.Username__c=data.username;
			isUpdate = true;
		}
		//u.Name=provider;
		//u.UserId__c=userId;
		//u.Id = uspibui[0].Id;
		System.debug('#### !DEBUG! collectAuthProviderInfo-provider: ' + provider + '; update: ' + u);

		//Handle MIXED_DML_OPERATION
		try {
			if(isUpdate) {update u;}
		  } catch (Exception e) {
			System.debug('#### !ERROR! cause: ' + e.getCause() + '; message: ' + e.getMessage());
			esso_User.updateUserProviderInfo(uspibui[0].Id,data.attributeMap.toString(),data.email, data.identifier,data.username);
		  }


	}

	

}

@future
public static void  updateUserProviderInfo(String Id,String attributeMap,String email, String identifier, String username)
{
	esso_User_Provider_Info__c u = new esso_User_Provider_Info__c();
	u.AttributeMap__c=attributeMap;
	u.Email__c=email;
	u.Identifier__c=identifier;
	u.Username__c=username;
	u.Id = Id;
	System.debug('#### !DEBUG! @future updateUserProviderInfo: ' + u);
	update u;
}



public user CheckBusinesEmailVerified(string providerEmail,string provider)
{
	user u = new User();
	
	//esso_User essoUser = new esso_User();
	User providerLinkedUser = getUserByUsername(providerEmail);
	u=providerLinkedUser;// default linked provider user

	system.debug('#### !DEBUG! providerLinkedUser: ' + providerLinkedUser);
	if(providerLinkedUser != null && providerLinkedUser.esso_Business_Email_Verified__c != null && providerLinkedUser.esso_Business_Email__c!=null)
	{	//Get business email user to link provider and continue
		User bussnessEmailUser = getUserByUsername(providerLinkedUser.esso_Business_Email__c);
		system.debug('#### !DEBUG! bussnessEmailUser: ' + bussnessEmailUser);
		if(	bussnessEmailUser != null)
		{
			//Revoke previously account linkage when exists
			List<ThirdPartyAccountLink> tpal= getThirdPartyLinkByUserId(u.Id,provider);
			boolean isProviderLinkedEmailRevoked= false;
			if ((tpal !=null && tpal.size()>0) || test.isRunningTest())
			{
				isProviderLinkedEmailRevoked = (test.isRunningTest()? true : Auth.AuthToken.revokeAccess(tpal[0].SsoProviderId, provider.toLowerCase(), u.Id, tpal[0].RemoteIdentifier));
            }
            system.debug('#### !DEBUG! Revoke linkage to old user: ' + providerLinkedUser.username  + ';' + isProviderLinkedEmailRevoked  + ';' + tpal);
			
			system.debug('#### !DEBUG! bussnessEmailUser: ' + bussnessEmailUser);
			u=bussnessEmailUser;
		}

	}
	
	Return u;
}




}