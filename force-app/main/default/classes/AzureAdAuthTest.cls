/**
 * Application        :  Informa Azure AD Provider
 * Created By         :  Shay.Spoonmore@informa.com (20200901)
 * Created On:        :  20200901
 * @description       :  [Azure AD Provider to use for SSO]
 * Modification log --
 * Modified by        :  Shay.Spoonmore@informa.com (20200901)
 **/
@isTest
public with sharing class AzureAdAuthTest {

private static final String AccessToken = 'access_token';
private static final String IdToken = 'id_token';
private static final String ClientId = 'testKey';
private static final String ClientSecret = 'testSecret';
private static final String AuthorizationEndpoint = 'http://www.dummy.com/authurl';
private static final String TokenEndpoint = 'http://www.dummyhost.com/accessTokenUri';
private static final String UserEndpoint = 'https://graph.microsoft.com/v1.0/me';
private static final String RedirectUri = 'http://localhost/services/authcallback/orgId/IM_IdP_Informa';
private static final String Scope = 'openid profile email';

// In the real world scenario, the key and value would be read
// from the (custom fields in) custom metadata type record.
private static Map<String,String> setupAuthProviderConfig (string usernamePrefix)
{
	Map<String,String> authProviderConfiguration = new Map<String,String>();
	authProviderConfiguration.put('Client_Id__c', ClientId);
	authProviderConfiguration.put('Client_Secret__c', ClientSecret);
	authProviderConfiguration.put('Authorization_Endpoint__c', AuthorizationEndpoint);
	authProviderConfiguration.put('Token_Endpoint__c', TokenEndpoint);
	authProviderConfiguration.put('User_Endpoint__c',UserEndpoint);
	authProviderConfiguration.put('Redirect_URI__c',RedirectUri);
	authProviderConfiguration.put('Scope__c',Scope);
	authProviderConfiguration.put('Username_Suffix__c',usernamePrefix);
	return authProviderConfiguration;

}

static testMethod void testInitiateMethod()
{
	String stateToPropogate = 'mocktestState';
	Map<String,String> authProviderConfiguration = setupAuthProviderConfig('');
	AzureAdAuth azureAd = new AzureAdAuth();

	PageReference actualUrl = azureAd.initiate(authProviderConfiguration, stateToPropogate);
    // 3rd Parameter is added by Palla Kishore for the ticket BK-19602
	System.assertEquals(true, (actualUrl.getUrl().startsWith(AuthorizationEndpoint )), 'Here Value is not same');
	System.assertEquals('AzureAdAuthProvider__mdt', azureAd.getCustomMetadataType(), 'Here Value is not same');
}

static testMethod void testTokenCallback()
{
	Map<String,String> authProviderConfiguration = setupAuthProviderConfig('');
	AzureAdAuth azureAd = new AzureAdAuth();

	Test.setMock(HttpCalloutMock.class, new  AzureTokenResponseMock());

	Map<String,String> queryParams = new Map<String,String>();
	queryParams.put('code','code');
	queryParams.put('state','mocktestState');
	Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams);
	Auth.AuthProviderTokenResponse actualAuthProvResponse = azureAd.handleCallback(authProviderConfiguration, cbState);
	Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse('AzureAdAuth', AccessToken, null, 'mocktestState');

	System.assertEquals(expectedAuthProvResponse.provider,actualAuthProvResponse.provider, 'Expected should equal actual');
	System.assertEquals(expectedAuthProvResponse.oauthToken, actualAuthProvResponse.oauthToken, 'Expected should equal actual');
	System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualAuthProvResponse.oauthSecretOrRefreshToken, 'Expected should equal actual');
	System.assertEquals(expectedAuthProvResponse.state, actualAuthProvResponse.state, 'Expected should equal actual');
	System.assertNotEquals(expectedAuthProvResponse.state, null, 'Expected should not be null');

}

static testMethod void testGetUserInfo() 
{ 
    Map<String,String> authProviderConfiguration = setupAuthProviderConfig('');
	AzureAdAuth azureAd = new AzureAdAuth();

    Test.setMock(HttpCalloutMock.class, new  AzureUserResponseMock());
    
    Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse('AzureAdAuth', IdToken  ,ClientSecret, 'mocktestState'); 
    Auth.UserData actualUserData = azureAd.getUserInfo(authProviderConfiguration, response) ; 

    System.assertEquals(actualUserData.lastName, 'test',  'Expected should equal actual'); 



}


// Implement a mock http response generator for Azure Token
public class AzureUserResponseMock implements HttpCalloutMock
{
public HTTPResponse respond(HTTPRequest req)
{
	String json = '';
	json += '{';
	json += '"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users/$entity",';
	json += '"businessPhones": [ "+19413333333" ],';
	json += '"displayName": "test, test",';
	json += '"givenName": "test",';
	json += '"jobTitle": "Senior Backend Developer",';
	json += '"mail": "test.test@informausa.com",';
	json += '"mobilePhone": "+1 (333) 333-3333",';
	json += '"officeLocation": "US Sarasota 101 Paramount DR",';
	json += '"preferredLanguage": null,';
	json += '"surname": "test",';
	json += '"userPrincipalName": "test.test@informa.com",';
	json += '"id": "5c12eb03-3333-3333-3333-3a57ab8de41d"';
	json += '}';
	// Create a fake response
	HttpResponse res = new HttpResponse();
	res.setHeader('Content-Type', 'application/json');
	res.setBody(json);
	res.setStatusCode(200);
	return res;
}

}

// Implement a mock http response generator for Azure Token
public class AzureTokenResponseMock implements HttpCalloutMock
{
public HTTPResponse respond(HTTPRequest req)
{
	String json = '';
	json += '{';
	json += '"token_type": "Bearer",';
	json += '"scope": "email openid profile User.Read",';
	json += '"expires_in": 3599,';
	json += '"ext_expires_in": 3599,';
	json += '"access_token": "' + AccessToken + '",';
	json += '"id_token": "' + IdToken + '"';
	json += '}';
	// Create a fake response
	HttpResponse res = new HttpResponse();
	res.setHeader('Content-Type', 'application/json');
	res.setBody(json);
	res.setStatusCode(200);
	return res;
}

}


}