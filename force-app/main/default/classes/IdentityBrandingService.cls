/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-55)]
 * Created On   :   May 15 2019
 * @description :   [This class using for Identity Branding Service]
 * Test Class   :   IdentityBrandingServiceTest
 * Modification Log-----
 * Modified by  :
 **/
@RestResource(urlMapping='/identity/*')
global with sharing class IdentityBrandingService {

@TestVisible private static final String AUTHORIZE_ENDPOINT = '/services/oauth2/authorize';
@TestVisible private static final String SAML_ENDPOINT = '/idp/endpoint/HttpRedirect';
@TestVisible private static final String WEB_ENDPOINT = '/signin';
@TestVisible private static final String CUSTOM_LOGOUT_ENDPOINT = '/logout';
@TestVisible private static final String SF_LOGOUT_ENDPOINT = '/secur/logout.jsp';

@HttpGet
global static void doGet() {
	System.debug('####!DEBUG! IdentityBrandingService - FederatedAuthProviderUtility.getDefaultCommunityURL():'+ FederatedAuthProviderUtility.getDefaultCommunityURL() + '; URL.getSalesforceBaseUrl().getHost():' + URL.getSalesforceBaseUrl().getHost() + '; URL.getCurrentRequestUrl().getPath(): ' + URL.getCurrentRequestUrl().getPath());
	RestRequest req = RestContext.request;
	RestResponse res = RestContext.response;
	Boolean isLogoutProcess = false;
	String redirectUrl = '';
	String brand = '';

	// Get the site prefix to add to redirecturl as its not present in requestUri
	String sitePathPreix = Site.getPathPrefix();

	System.debug('*** -- sitePathPreix: ' + sitePathPreix);
	System.debug('*** -- req.requestUri: ' + req.requestUri);

	// Get the url from the brand referral Id from the Uri
	String brandBefore = req.requestUri.remove('/identity/');
	System.debug('*** -- brandBefore: ' +brandBefore);





	// Get the SSO Client Id from the request & validate it matches a client Id
	// String ideSsoClientId = validateIdeSsoClientId(req.params.get('idessoclientid'));
	// Add value back to params for param processing
	// req.params.put('idessoclientid', ideSsoClientId);

	// Strip off last / i.e./services/oauth2/authorize/
	brandBefore = (String.isNotBlank(brandBefore) && brandBefore.endsWith('/')) ? brandBefore.substringBeforeLast('/') : brandBefore;

	// Get the brand only from the Uri and set redirect Url
	if (brandBefore.contains(AUTHORIZE_ENDPOINT)) {

		brand = brandBefore.remove(AUTHORIZE_ENDPOINT);
		redirectUrl = AUTHORIZE_ENDPOINT;

	} else if (brandBefore.contains(SAML_ENDPOINT)) {

		brand = brandBefore.remove(SAML_ENDPOINT);
		redirectUrl = SAML_ENDPOINT;

	} else if (brandBefore.contains(CUSTOM_LOGOUT_ENDPOINT)) {

		brand = brandBefore.remove(CUSTOM_LOGOUT_ENDPOINT);
		//redirectUrl = SF_LOGOUT_ENDPOINT; //20/06/2017 - Updated to redirect to custom VF page to detect if user is logged in
		redirectUrl =  Page.logout.getUrl();

		isLogoutProcess = true;

	} else { // If endpoint is not oAuth or SAML - get community login url

		// Unknown endpoint requested so extract URL from first / after brand string
		brand = brandBefore.substringBefore('/');

		// Check if context is within a community
		String networkId = Network.getNetworkId();

		// Set the redirect url to be the community login page, else set the WEB_ENDPOINT variable
		redirectUrl = (String.IsNotBlank(networkId)) ? Network.getLoginUrl(networkId).replace(Site.getBaseUrl(),'') : WEB_ENDPOINT;
	}

	System.debug('####!DEBUG! IdentityBrandingService - Received Brand: ' + brand);
	SiteBrandingIdentifier.referralId=brand;


	// Get the referral url from the request and process against whitelist
	String referralurlParam = SSOApplicationSecurity.processReturnUrlString(req.params.get('referralurl'));
    // Add value back to params for param processing
	req.params.put('referralurl', referralurlParam);
	System.debug('####!DEBUG! IdentityBrandingService - referralurlParam:' + referralurlParam);

	// Reconstruct the redirect url adding the site prefix if there is one
	redirectUrl = String.isNotBlank(sitePathPreix) ? sitePathPreix + redirectUrl : redirectUrl;

	if(isLogoutProcess) redirectUrl ='https://' + URL.getSalesforceBaseUrl().getHost() + redirectUrl; //SAS

	
	//System.debug('*** -- redirectUrl: ' + redirectUrl);

	String paramStr = '?';

	// Loop through page params passed in and reconstruct onto response body redirect url
	if(req.params != null && !req.params.isEmpty()) {
		for (String parameterName :  req.params.keySet() ) {
			//paramStr += parameterName + '=' + EncodingUtil.urlEncode(req.params.get(parameterName), 'UTF-8') + '&'; // 2018-12-05 - Updated to process params against xss values
			String paramValue = req.params.get(parameterName);
			String xssCleanParam = XssSecurityHelper.getXssCleanString(paramValue);
			if(String.isNotBlank(xssCleanParam)) {
				paramStr += parameterName + '=' + SsoApplicationSecurity.encode(xssCleanParam) + '&';
			}
		}

		// Remove last '&' added by param loop
		paramStr = (paramStr.endsWithIgnoreCase('&'))
		           ? paramStr.substringBeforeLast('&') :
		           (paramStr != '?') ? paramStr : '';
		System.debug('####!DEBUG! IdentityBrandingService - redirectUrl params:' + paramStr);
		// Verify URL against whitelist and XSS, then re add params else redirect to exception page
		

		redirectUrl = (SsoApplicationSecurity.isValidReturnUrl(redirectUrl)) ? redirectUrl + paramStr : Page.Exception.getUrl();
	}

	System.debug('####!DEBUG! IdentityBrandingService - SiteBrandingIdentifier.isValidReferralId: ' + SiteBrandingIdentifier.isValidReferralId + '; SiteBrandingIdentifier.referralId: ' + SiteBrandingIdentifier.referralId);
	if(!SiteBrandingIdentifier.isValidReferralId)//Check Branding and replace with default
	{
		brand=esso_Configuration.setting.Branding_Default__c.toLowerCase();
	}
	

	Datetime brandCookieExpiry = Datetime.now().addSeconds(SiteBrandingIdentifier.brandCookieMaxAge);
	Datetime redirectUrlCookieExpiry = Datetime.now().addSeconds(SiteBrandingIdentifier.referralUrlCookieMaxAge);

	String cookieExpiryDTFormat = 'EEE, dd MMM yyyy HH:mm:ss';

	String brandCookieExpiryStr = brandCookieExpiry.format(cookieExpiryDTFormat, 'GMT') + ' UTC';
	String redirectUrlCookieExpiryStr = brandCookieExpiry.format(cookieExpiryDTFormat, 'GMT')  + ' UTC';

	// Sets the redirect url to a set url for logout or the actual requested endpoint e.g. '/services/oauth2/authorize'
	String cookieRedirectURL = (isLogoutProcess && String.isNotBlank(referralurlParam)) ? EncodingUtil.urlEncode(referralurlParam, 'UTF-8') : redirectUrl;

	// Create javascript string to add to body of service response
	String bodyString = '<script>';
	bodyString += 'document.cookie = "apex__brand=' + brand + ';Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + '; SameSite=Lax; Secure"; ';

	// SAS 20190905 - Only needed for logout process - don't create a redirect cookie if referalurl is not whitelisted
	if ((isLogoutProcess && String.isNotBlank(referralurlParam)) || !isLogoutProcess) bodyString += 'document.cookie = "apex__rurl=' + cookieRedirectURL + ';Path=/;Max-Age=' + SiteBrandingIdentifier.referralUrlCookieMaxAge + '; SameSite=Lax; Secure"; ';

	/*if(String.isNotBlank(ideSsoClientId) && !isLogoutProcess){
	     // Creates a custom cookie object setting the cookie data on the top level .informa.com domain instead of the community the rest is being made from
	     CustomCookie ideSSOClientIdCookie = new CustomCookie('idessoclientid', ideSsoClientId, SiteBrandingIdentifier.referralUrlCookieMaxAge, Label.Communities_Production_Cookie_Top_Level_Domain, null, true, true);
	     // Creates the cookie script output from the class details
	     bodyString += 'document.cookie = "' + ideSSOClientIdCookie.name + '=' + ideSSOClientIdCookie.value + ';Domain='+ ideSSOClientIdCookie.domain + ';Path=' + ideSSOClientIdCookie.path + ';Max-Age=' + ideSSOClientIdCookie.maxAge + ';secure"; ';
	   }else if(isLogoutProcess){
	     // Clear the client auto SSO ID cookie to prevent auto login
	     CustomCookie ideSSOClientIdCookie = new CustomCookie('idessoclientid', ideSsoClientId, SiteBrandingIdentifier.referralUrlCookieMaxAge, Label.Communities_Production_Cookie_Top_Level_Domain, null, true, true);
	     bodyString += 'document.cookie = "' + ideSSOClientIdCookie.name + '=;Domain='+ ideSSOClientIdCookie.domain + ';Path=' + ideSSOClientIdCookie.path + ';Max-Age=0;secure"; ';
	   }*/
	bodyString += 'window.location = "' + redirectUrl + '";</script>';

	//String bodyString = '<script>document.cookie = "apex__brand=' + brand + ';Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + ';"; document.cookie = "apex__rurl=' + cookieRedirectURL + ';Path=/;Max-Age=' + SiteBrandingIdentifier.referralUrlCookieMaxAge + ';"; ';
	//bodyString += 'window.location = "' + redirectUrl + '";</script>';

	System.debug('*** -- bodyString: ' + bodyString);

	// Set the service response and apply javascript setting the cookie and page redirect as the body
	res.addHeader('Content-Type', 'text/html');
	res.statusCode = 200;
	res.responseBody = Blob.valueOf(bodyString);
}

/* private static String validateIdeSsoClientId(String ideSsoClientId){
     // Check for an account with the ID and return the ID provided else return null
     List<Account> accounts = [SELECT Name FROM Account WHERE Federated_Auth_Client_SSO_ID__c != null AND Federated_Auth_Client_SSO_ID__c = :ideSsoClientId LIMIT 1];
     return (accounts != null && !accounts.isEmpty()) ? ideSsoClientId : null;
   }*/
}