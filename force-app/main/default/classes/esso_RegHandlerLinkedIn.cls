/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Shay.Spoonmore@informa.com
 * Created On   :   20200611
 * @description :   [IM IdP LinkedIn RegHandler]
 * Test Class   :
 * Modification Log-----
 * Modified by  :
 **/

global class esso_RegHandlerLinkedIn implements Auth.RegistrationHandler {

public static final String PROVIDER = 'LinkedIn';



global boolean canCreateUser(Auth.UserData data) {
	Boolean isUser = String.isNotBlank(data.email);
	return isUser;
}

void debugInfo(Auth.UserData data)
{
	System.debug('#### !DEBUG! Auth.UserData: ' + data);
	System.debug('#### !DEBUG! data.attributeMap: ' + data.attributeMap);
	System.debug('#### !DEBUG! Email: ' + data.email);
	System.debug('#### !DEBUG! preferredLocale: ' + data.attributeMap.get('lastName'));

	for(string key : data.attributeMap.keySet())
	{
		system.debug('#### !DEBUG! attributeMap key: ' + key + '; value: ' + data.attributeMap.get(key));
	}



}

global User createUser(Id portalId, Auth.UserData data){

	debugInfo(data);

	if(!canCreateUser(data)) {
		//Returning null or throwing an exception fails the SSO flow
		return null;
	}


	if(data.attributeMap.containsKey('sfdc_networkid')) {

		esso_User essoUser = new esso_User();
		User existingUser = essoUser.CheckBusinesEmailVerified(data.email, PROVIDER);

		system.debug('#### !DEBUG! esso_RegHandlerLinkedIn-createUser; existingUser: ' + existingUser);
		if (existingUser != null)
		{
			updateUser(existingUser.Id, data.attributeMap.get('sfdc_networkid'), data);
			return existingUser;
		}
		else
		{
			//Create User
			User u = new User();
			u.Username = data.email;
			u.Email = data.email;
			u.FirstName = data.firstName;
			u.LastName = (String.isBlank(data.lastName) ? '{updatelast}': data.lastName);
			// u.Countrycode = theUser.Countrycode;
			u.CommunityNickname = RegistrationHandler.generateCommunityNickname(u);
			u.LocaleSidKey = 'en_US';
			u.LanguageLocaleKey = 'en_US';



			u.TimeZoneSidKey = 'GMT';
			u.ProfileID = esso_User.ProfileId;
			u.EmailEncodingKey = 'UTF-8';
			u.Alias = u.Email.length() > 8 ? u.Email.substring(0,8) : u.Email;
			u.esso_LastLoginProviderType__c = PROVIDER;
			u.esso_LastLoginProviderId__c = data.identifier;
			insert u;

			System.debug('#### !DEBUG! esso_RegHandlerLinkedIn-createUser; provider: ' + provider + '; insert: ' + u);
			esso_User.collectAuthProviderInfo(u.Id,data,PROVIDER);

			return u;
		}
	} else 
	{
		return null;
	}
}



// public user CheckBusinesEmailVerified(string providerEmail)
// {
// 	user u = new User();
	
// 	esso_User essoUser = new esso_User();
// 	User providerLinkedUser = essoUser.getUserByUsername(providerEmail);
// 	u=providerLinkedUser;// default linked provider user

// 	system.debug('#### !DEBUG! providerLinkedUser: ' + providerLinkedUser);
// 	if(providerLinkedUser != null && providerLinkedUser.esso_Business_Email_Verified__c != null && providerLinkedUser.esso_Business_Email__c!=null)
// 	{	//Get business email user to link provider and continue
// 		User bussnessEmailUser = essoUser.getUserByUsername(providerLinkedUser.esso_Business_Email__c);
// 		system.debug('#### !DEBUG! bussnessEmailUser: ' + bussnessEmailUser);
// 		if(	bussnessEmailUser != null)
// 		{
// 			//Revoke previously account linkage when exists
// 			List<ThirdPartyAccountLink> tpal= essoUser.getThirdPartyLinkByUserId(u.Id,PROVIDER);
// 			boolean isProviderLinkedEmailRevoked= false;
// 			if (tpal !=null && tpal.size()>0)
// 			{
// 				isProviderLinkedEmailRevoked = Auth.AuthToken.revokeAccess(tpal[0].SsoProviderId, PROVIDER.toLowerCase(), u.Id, tpal[0].RemoteIdentifier);
//             }
//             system.debug('#### !DEBUG! Revoke linkage to old user: ' + providerLinkedUser.username  + ';' + isProviderLinkedEmailRevoked  + ';' + tpal);
			
// 			system.debug('#### !DEBUG! bussnessEmailUser: ' + bussnessEmailUser);
// 			u=bussnessEmailUser;
// 		}

// 	}
	
// 	Return u;
// }

// public user CheckBusinesEmailVerifiedByUserId(Id userId)
// {
// 	user u = new User();
// 	u.Id=userId;// default linked provider user
// 	esso_User essoUser = new esso_User();
// 	User providerLinkedUser = essoUser.getUserById(userId);
	

// 	system.debug('#### !DEBUG! providerLinkedUser: ' + providerLinkedUser);
// 	if(providerLinkedUser.esso_Business_Email_Verified__c != null && providerLinkedUser.esso_Business_Email__c!=null)
// 	{	//Get business email user to link provider and continue
// 		User bussnessEmailUser = essoUser.getUserByUsername(providerLinkedUser.esso_Business_Email__c);
// 		system.debug('#### !DEBUG! bussnessEmailUser: ' + bussnessEmailUser);
// 		if(	bussnessEmailUser != null)
// 		{
// 			//Revoke previously account linkage
// 			ThirdPartyAccountLink tpal= essoUser.getThirdPartyLinkByUserId(providerLinkedUser.Id,PROVIDER);
			
// 			boolean isProviderLinkedEmailRevoked= false;
// 			if (tpal !=null)
// 			{
// 				isProviderLinkedEmailRevoked = Auth.AuthToken.revokeAccess(tpal.SsoProviderId, PROVIDER.toLowerCase(), providerLinkedUser.Id, tpal.RemoteIdentifier);
//             }
//             system.debug('#### !DEBUG! Revoke linkage to old user: ' + providerLinkedUser.username  + ';' + isProviderLinkedEmailRevoked  + ';' + tpal);

			
// 			u.Id=bussnessEmailUser.Id;
// 		}

// 	}
	

// 	system.debug('#### !DEBUG! CheckBusinesEmailVerifiedByUserId: ' + u);
// 	Return u;
// }

global void updateUser(Id userId, Id portalId, Auth.UserData data){

	debugInfo(data);

	//User u = CheckBusinesEmailVerifiedByUserId(userId);
	User u = new User(Id=userId);
	
	//u.username = data.username + '@myorg.com';
	//u.email = data.email;
	//u.isActive = true;
	if(String.isNotBlank(data.lastName)){ u.lastName = data.lastName;}
	if(String.isNotBlank(data.firstName)){u.firstName = data.firstName;}
	//String alias = data.username;
	//Alias must be 8 characters or less
	//if(alias.length() > 8) {
	//alias = alias.substring(0, 8);
	//}
    //u.alias = alias;
    u.esso_LastLoginProviderType__c = PROVIDER;
	u.esso_LastLoginProviderId__c = data.identifier;
	update(u);
	
	System.debug('#### !DEBUG! esso_RegHandlerLinkedIn-updateUser; provider: ' + provider + '; update: ' + u);
	esso_User.collectAuthProviderInfo(u.Id,data,PROVIDER);
}
}