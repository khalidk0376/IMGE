/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Shay.Spoonmore@informa.com
 * Created On   :   20200611
 * @description :   [IM IdP Connected App Handler for custom attributes]
 * Test Class   :
 * Modification Log-----
 * Modified by  :	Shay.Spoonmore@informa.com
 **/
global class esso_ConnectedAppHandler extends Auth.ConnectedAppPlugin
{

public List<ThirdPartyLink> tpls = new List<ThirdPartyLink>();

global override Map<String,String> customAttributes(Id userId, Id connectedAppId, Map<String,String> formulaDefinedAttributes, Auth.InvocationContext context)
{
	// system.debug('### !DEBUG! Auth.InvocationContext: ' + context);
	// AuthSession authSession = [SELECT CreatedDate,Id,IsCurrent,LastModifiedDate,LoginHistoryId,LoginHistory.application,LoginType,LogoutUrl,NumSecondsValid,ParentId,SessionSecurityLevel,SessionType,SourceIp,UsersId,UserType FROM AuthSession where  UsersId = :userId ORDER BY CreatedDate DESC LIMIT 1 ]  ;
	// system.debug('### !DEBUG! AuthSession: ' + authSession);
	esso_User essoUser = new esso_User();

	User u = essoUser.getUserById(userId);

	if( String.isBlank( u.esso_LastLoginProviderType__c))
	{
		u.esso_LastLoginProviderType__c=esso_Configuration.DEFAULT_PROVIDER;
		u.esso_LastLoginProviderId__c=u.Id;
	}

	formulaDefinedAttributes.put('IsInformaEmployee',  String.valueOf(u.esso_Is_Informa_Employee__c));
	formulaDefinedAttributes.put('LoggedInProviderType',  u.esso_LastLoginProviderType__c);
	formulaDefinedAttributes.put('LoggedInProviderId',  u.esso_LastLoginProviderId__c);
	//formulaDefinedAttributes.put('BusinessEmail',  u.esso_Business_Email__c);
	formulaDefinedAttributes.put('IsBusinessEmail',  u.esso_QA_Business_Email__c);

	//Add all Third Party RemoteIdentifier
	//list<ThirdPartyAccountLink> thirdPartyAccountLinks = [SELECT Handle,Id,IsNotSsoUsable,Provider,RemoteIdentifier,SsoProviderId,SsoProviderName,ThirdPartyAccountLinkKey,UserId FROM ThirdPartyAccountLink WHERE UserId = :userId];
	List<ThirdPartyLink> thirdPartyAccountLinks = getThirdPartyLink(userId);
	//Related User and provider information
	list<esso_User_Provider_Info__c> euspi = new list<esso_User_Provider_Info__c>();


	String strJsonThirdPartyAccountLink = '[]';
	String strJsonUserProviderInfo = '[]';

	if (thirdPartyAccountLinks.size() > 0 )
	{
		//get all Identifiers and Providers to user provider info
		set<String> identifiers = new set<String>();
		set<String> providers = new set<String>();

		for(ThirdPartyLink p: thirdPartyAccountLinks)
		{
			identifiers.add(p.RemoteIdentifier);
			providers.add(p.Provider);
		}

		//map user to provider email
		euspi = essoUser.getUserProviderInfoByUserProviderIds(providers, identifiers);
		Map<string,esso_User_Provider_Info__c> mapUserProviderToEmail = new Map<string,esso_User_Provider_Info__c>();
		for (esso_User_Provider_Info__c up : euspi)
		{
			mapUserProviderToEmail.put(up.UserId__c + '-' + up.Identifier__c, up);
		}

		strJsonThirdPartyAccountLink = '[';
		for(ThirdPartyLink p: thirdPartyAccountLinks)
		{
			String email = null;
			if(euspi.size()>0)
			{
				esso_User_Provider_Info__c up = mapUserProviderToEmail.get(p.UserId + '-' + p.RemoteIdentifier);
				if(up != null) { email = '"'+ up.Email__c +'"';}
			}

			strJsonThirdPartyAccountLink += '{"Provider": "'+ p.Provider +'","RemoteIdentifier": "'+ p.RemoteIdentifier +'","SfdcUserId": "'+ p.UserId +'","Email": '+ email +'},';
		}

		if (strJsonThirdPartyAccountLink.endsWith(',')) {strJsonThirdPartyAccountLink = strJsonThirdPartyAccountLink.left(strJsonThirdPartyAccountLink.length()-1);}

		strJsonThirdPartyAccountLink += ']';


	}

	formulaDefinedAttributes.put('ThirdPartyProviders',  strJsonThirdPartyAccountLink);





	// for(string key : formulaDefinedAttributes.keySet())
	// {
	// 	system.debug('### !DEBUG! attributeMap key: ' + key + '; value: ' + formulaDefinedAttributes.get(key));
	// }

	return formulaDefinedAttributes;
}

Public List<ThirdPartyLink> getThirdPartyLink(String userId)
{
	list<ThirdPartyAccountLink> thirdPartyAccountLinks = [SELECT Handle,Id,IsNotSsoUsable,Provider,RemoteIdentifier,SsoProviderId,SsoProviderName,ThirdPartyAccountLinkKey,UserId FROM ThirdPartyAccountLink WHERE UserId = :userId];
	for (ThirdPartyAccountLink t : thirdPartyAccountLinks)
	{
		ThirdPartyLink tpl = new ThirdPartyLink(t.RemoteIdentifier,t.Provider,t.UserId);
		// tpl.Provider = t.Provider;
		// tpl.RemoteIdentifier = t.RemoteIdentifier;
		// tpl.UserId = t.UserId;
		tpls.add(tpl);
	}

	return tpls;
}

Public class ThirdPartyLink
{

Public String RemoteIdentifier { public get; public set;}
Public String Provider { public get; public set;}
Public String UserId { public get; public set;}
public ThirdPartyLink()
{
	//Necessary for initializing class without constructor parameters
	system.debug('Constructor Being Called'); // Added by Palla Kishore for the ticket BK-19604
}
public ThirdPartyLink(String remoteIdentifier, String provider, Id userId)
{
	RemoteIdentifier=remoteIdentifier;
	Provider=provider;
	UserId=userId;
}

}


}