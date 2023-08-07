/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Shay.Spoonmore@informa.com
 * Created On   :   20200801
 * @description :   [IM IdP LinkedIn RegHandler]
 * Test Class   :
 * Modification Log-----
 * Modified by  : 	Shay.Spoonmore@informa.com
 **/
Global class esso_RegHandlerInforma implements Auth.RegistrationHandler {
public static final String PROVIDER = 'IM IdP Informa';
private static final String DEFAULT_COMPANY = 'Informa';
esso_User essoUser = new esso_User();



void debugInfo(Auth.UserData data)
{
	System.debug('#### !DEBUG! Auth.UserData: ' + data);
	System.debug('#### !DEBUG! data.attributeMap: ' + data.attributeMap);




	for(string key : data.attributeMap.keySet())
	{
		system.debug('#### !DEBUG! attributeMap key: ' + key + '; value: ' + data.attributeMap.get(key));
	}



}


global User createUser(Id portalId, Auth.UserData data){


	debugInfo(data);

	User existingUser = essoUser.getUserByUsername(data.userName);

	system.debug('#### !DEBUG! existingUser: ' + existingUser);
	if (existingUser != null)
	{
		updateUser(existingUser.Id, data.attributeMap.get('sfdc_networkid'), data);
		return existingUser;
	}
	else
	{

		User u = new User();
		u.username = data.userName;
		u.email = data.email == null ? data.userName : data.email;
		//u.FederationIdentifier = data.userName;
		u.lastName = data.lastName;
		u.firstName = data.firstName;
		u.CompanyName = DEFAULT_COMPANY;
		u.Street = data.attributeMap.get('officeLocation');
		u.MobilePhone = data.attributeMap.get('mobilePhone');
		u.Phone = data.attributeMap.get('businessPhone1');
		u.Title = data.attributeMap.get('jobTitle');

		String alias = u.username;
		//Alias must be 8 characters or less
		if(alias.length() > 8) {
			alias = alias.substring(0, 8);
		}
		u.alias = alias;
		u.languagelocalekey = UserInfo.getLocale();
		u.localesidkey = UserInfo.getLocale();
		u.emailEncodingKey = 'UTF-8';
		u.timeZoneSidKey = UserInfo.getTimeZone().toString();//'America/Los_Angeles';
		u.profileId = esso_User.ProfileId;
		u.esso_LastLoginProviderType__c = PROVIDER;
		u.esso_LastLoginProviderId__c = data.identifier;
		u.esso_Is_Informa_Employee__c = true;
		u.esso_QA_Business_Email__c = 'Yes';
		u.esso_Business_Email__c = null;
		u.esso_Business_Email_Verified__c = System.now();
		insert u;
		System.debug('#### !DEBUG! esso_RegHandlerInforma-createUser; provider: ' + provider + '; insert: ' + u);
		esso_User.collectAuthProviderInfo(u.Id,data,PROVIDER);

		return u;

	}
}


global void updateUser(Id userId, Id portalId, Auth.UserData data){

	debugInfo(data);
	
	User u = [SELECT Id, Username, Email,Street,MobilePhone,Phone,Title, CompanyName,esso_LastLoginProviderType__c,esso_LastLoginProviderId__c,esso_Is_Informa_Employee__c,esso_QA_Business_Email__c FROM USER WHERE Id =: userId ]; //essoUser.getUserById(userId);

	//u.username = data.username;
	u.email = data.email == null ? data.userName : data.email;


	String street = data.attributeMap.get('officeLocation');
	String mobilePhone = data.attributeMap.get('mobilePhone');
	String phone = data.attributeMap.get('businessPhone1');
	String title = data.attributeMap.get('jobTitle');

	if (street != null && u.Street != street)  {u.Street = street;}
	if (mobilePhone != null && u.MobilePhone != mobilePhone) {u.MobilePhone = mobilePhone;}
	if (phone != null && u.Phone != phone ) {u.Phone = phone;}
	if (title != null && u.Title != title) {u.Title = title;}
	if (u.CompanyName == null) {u.CompanyName = DEFAULT_COMPANY;}
	u.esso_LastLoginProviderType__c = PROVIDER;
	u.esso_LastLoginProviderId__c = data.identifier;
	u.esso_Is_Informa_Employee__c = true;
	u.esso_QA_Business_Email__c = 'Yes';
	u.esso_Business_Email__c = null;
	u.esso_Business_Email_Verified__c = System.now();
	
	update(u);
	System.debug('#### !DEBUG! esso_RegHandlerInforma-updateUser; provider: ' + provider + '; update: ' + u);
	esso_User.collectAuthProviderInfo(u.Id,data,PROVIDER);//collect provider info

}
}