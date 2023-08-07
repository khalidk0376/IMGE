/**
 * Application        :  Informa Azure AD Provider
 * Created By         :  Shay.Spoonmore@informa.com (20200901)
 * Created On:        :  20200901
 * @description       :  [Azure AD Provider to use for SSO]
 * Modification log --
 * Modified by        :  Shay.Spoonmore@informa.com (20200901)
 **/
global class AzureAdAuth extends Auth.AuthProviderPluginClass {

private String clientId;
private String clientSecret;
private String accessTokenUrl;
private String authorizationUrl;
private String scope;
private String userEndpoint;
private String redirectUri;
private String usernameSuffix;
private String provider = 'AzureAdAuth';

// This method is responsible for returning the custom metadata storing the api credentials and other details
global String getCustomMetadataType() {
	return 'AzureAdAuthProvider__mdt';
}

// This method is responsible to initiate the authorization code flow
global PageReference initiate(Map<String, String> authProviderConfiguration, String stateToPropagate) {
	clientId = authProviderConfiguration.get('Client_Id__c');
	authorizationUrl = authProviderConfiguration.get('Authorization_Endpoint__c');
	scope = authProviderConfiguration.get('Scope__c');
	redirectUri = authProviderConfiguration.get('Redirect_URI__c');
	String url = authorizationUrl + '?scope='+ EncodingUtil.urlEncode(scope, 'UTF-8') +'&client_id='+ EncodingUtil.urlEncode(clientId, 'UTF-8')  +'&redirect_uri='+ EncodingUtil.urlEncode(redirectUri, 'UTF-8')  +'&state='+stateToPropagate + '&response_type=code';
	System.debug('### authorization code flow : ' + url);
	//Map<String,String> parameters = pageReference.getParameters();
	// System.debug('### queryParams.get(referralurl) : ' + parameters.get('referralurl'));
	return new PageReference(url);
}

/*
   This method is responsible to handle the callback from authorization code flow
   set the access token, refresh token and other parameters
 */
global Auth.AuthProviderTokenResponse handleCallback(Map<String, String> authProviderConfiguration, Auth.AuthProviderCallbackState state) {

	clientId = authProviderConfiguration.get('Client_Id__c');
	clientSecret = authProviderConfiguration.get('Client_Secret__c');
	scope = authProviderConfiguration.get('Scope__c');
	redirectUri = authProviderConfiguration.get('Redirect_URI__c');
	accessTokenUrl = authProviderConfiguration.get('Token_Endpoint__c');

	Map<String,String> queryParams = state.queryParameters;
	String code = queryParams.get('code');
	String sfdcState = queryParams.get('state');

	HttpRequest req = new HttpRequest();
	req.setEndpoint(accessTokenURL);
	req.setHeader('Accept','application/json');
	req.setMethod('POST');
	req.setBody('client_id='+ EncodingUtil.urlEncode(clientId, 'UTF-8') +'&client_secret='+ EncodingUtil.urlEncode(clientSecret, 'UTF-8') +'&code='+code+'&redirect_uri='+EncodingUtil.urlEncode(redirectUri, 'UTF-8')+'&state='+sfdcState+'&grant_type=authorization_code');

	Http http = new Http();
	HTTPResponse res = http.send(req);
	String responseBody = res.getBody();

	System.debug('### TokenResponse : ' + responseBody);


	AzureAdResponse response = (AzureAdResponse) JSON.deserialize(responseBody, AzureAdResponse.class);

	return new Auth.AuthProviderTokenResponse('AzureAdAuth', response.access_token, null, sfdcState);
}

// This method is responsible to get the user information used for authentication from the external api
// AzureAdUserInfoResponse UserInfoData(string url, string token)
// {
// 	AzureAdUserInfoResponse uir = new AzureAdUserInfoResponse();

// 	HttpRequest req = new HttpRequest();
// 	req.setHeader('Authorization', 'Bearer ' + token);
// 	req.setEndpoint(url);
// 	req.setMethod('GET');

// 	Http http = new Http();
// 	HTTPResponse res = http.send(req);
// 	String responseBody = res.getBody();

// 	System.debug('### UserInfoData : ' + responseBody);

// 	uir = (AzureAdUserInfoResponse) JSON.deserialize(responseBody, AzureAdUserInfoResponse.class);

// 	return uir;
// }

AzureAdUserProfileResponse UserProfileData(string url, string token)
{
	AzureAdUserProfileResponse uir = new AzureAdUserProfileResponse();

	HttpRequest req = new HttpRequest();
	req.setHeader('Authorization', 'Bearer ' + token);
	req.setHeader('Content-Type','application/json');
	req.setHeader('Accept','application/json');
	req.setEndpoint(url);
	req.setMethod('GET');

	Http http = new Http();
	HTTPResponse res = http.send(req);
	String responseBody = res.getBody();

	System.debug('### UserProfileData : ' + responseBody);

	uir = (AzureAdUserProfileResponse) JSON.deserialize(responseBody, AzureAdUserProfileResponse.class);

	return uir;
}

// Auth.UserData UserInfoDataMap(AzureAdUserInfoResponse r){

// 	String identifier = r.sub;
// 	String firstName= r.given_name;
// 	String lastName = r.family_name;
// 	String fullName = r.name;
// 	String email = r.email;
// 	String link = null;
// 	String userName =  null;
// 	String locale=  null;
// 	//String provider
// 	String siteLoginUrl=  null;
// 	Map<String,String> attributeMap = new Map<String,String>();
// 	attributeMap.put('sub', r.sub);

// 	return new Auth.UserData(
// 		identifier,
// 		firstName,
// 		lastName,
// 		fullName,
// 		email,
// 		link,
// 		userName,
// 		locale,
// 		provider,
// 		siteLoginUrl,
// 		attributeMap
// 		);
// }
Auth.UserData UserProfileDataMap(AzureAdUserProfileResponse r){

	String identifier = r.userPrincipalName;
	String firstName= r.givenName;
	String lastName = r.surname;
	String fullName = r.displayName;
	String email = r.mail;
	String link = null;
	String userName =  r.userPrincipalName;
	String locale=  r.preferredLanguage;
	//String provider
	String siteLoginUrl=  null;
	Map<String,String> attributeMap = new Map<String,String>();
	attributeMap.put('id', r.id);
	attributeMap.put('userPrincipalName', r.userPrincipalName);
	attributeMap.put('jobTitle', r.jobTitle);
	attributeMap.put('officeLocation', r.officeLocation);
	attributeMap.put('usernameSuffix', usernameSuffix);
	for (Integer i = 0; i < r.businessPhones.size(); i++)
	{
		attributeMap.put('businessPhone'+ (i+1), r.businessPhones[i]);
	}

	attributeMap.put('mobilePhone', r.mobilePhone);

	return new Auth.UserData(
		identifier,
		firstName,
		lastName,
		fullName,
		email,
		link,
		userName,
		locale,
		provider,
		siteLoginUrl,
		attributeMap
		);
}


global Auth.UserData getUserInfo(Map<String, String> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {

	userEndpoint = authProviderConfiguration.get('User_Endpoint__c');
	usernameSuffix =authProviderConfiguration.get('Username_Suffix__c');
	String token = response.oauthToken;

	//AzureAdUserInfoResponse infoApiResponse = UserInfoData(userInfoUrl, token);
	AzureAdUserProfileResponse userProfile = UserProfileData(userEndpoint, token);

	System.debug('### businessPhones : ' + userProfile.businessPhones);



	return UserProfileDataMap(userProfile);
	//return UserInfoDataMap(infoApiResponse);
}

// Wrapper class to handle User Info API response
public class AzureAdUserInfoResponse {
public String sub;
public String name;
public String family_name;
public String given_name;
public String email;
}

public class AzureAdUserGroupsResponse {
//https://graph.microsoft.com/v1.0/me/memberOf?$select=id,displayName,mailNickname
public String id;
public String displayName;
public String mailNickname;
}


public class AzureAdUserProfileResponse {
public String[] businessPhones;
public String displayName;
public String givenName;
public String jobTitle;
public String mail;
public String mobilePhone;
public String officeLocation;
public String preferredLanguage;
public String surname;
public String userPrincipalName;
public String id;
}

// Wrapper class to handle Access Token API response
public class AzureAdResponse {
public String access_token;
public String id_token;
public String token_type;
public String scope;
}

}