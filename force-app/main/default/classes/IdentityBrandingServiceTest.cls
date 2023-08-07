/**
 * Created/Modified By     :  Mahesh (Girikon)
 * Created On:             :  June 12 2019
 * @description            : [This test class covers the apex class : IdentityBrandingService]
 * Modification log --
 * Modified by  :  Rajesh Kumar on BK-6910 - 29-07-2020 
 **/
@isTest
private class IdentityBrandingServiceTest {

	@testSetup static void setup(){
		esso_ConfigurationTest.setupData();
	}

	@isTest static void testAuthGETRequest() {
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' and name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.AUTHORIZE_ENDPOINT, null, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
			//System.assertEquals('<script>document.cookie = "apex__brand=testbrand;Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + '; SameSite=Lax; Secure"; document.cookie = "apex__rurl=' + IdentityBrandingService.AUTHORIZE_ENDPOINT +';Path=/;Max-Age=' + SiteBrandingIdentifier.referralUrlCookieMaxAge + '; SameSite=Lax; Secure"; window.location = "'+ IdentityBrandingService.AUTHORIZE_ENDPOINT + '";</script>', res.responseBody.toString(),'The first and second parameter value should be match');
		}
	}

	@isTest static void testAuthGETRequest_two() {
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' and name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			// Additional backslash added to end of service endpoint e.g. /services/oauth2/authorize/ ending / should be stripped off end to get branding
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand1', IdentityBrandingService.AUTHORIZE_ENDPOINT + '/', null, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
			System.assertEquals('<script>document.cookie = "apex__brand=informa;Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + '; SameSite=Lax; Secure"; document.cookie = "apex__rurl=' + IdentityBrandingService.AUTHORIZE_ENDPOINT +';Path=/;Max-Age=' + SiteBrandingIdentifier.referralUrlCookieMaxAge + '; SameSite=Lax; Secure"; window.location = "'+ IdentityBrandingService.AUTHORIZE_ENDPOINT + '";</script>', res.responseBody.toString(),'The first and second parameter value should be match the default branding');
		}
	}

	@isTest static void testAuthGETRequestWithParams() {
		Account fedAuthAccount = new Account(Name ='autossoclient');
		insert fedAuthAccount;
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' and name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.AUTHORIZE_ENDPOINT, new Map<String, String> {'client_id' => 'ABC123', 'idessoclientid' => 'autossoclient'}, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
		}
	}

	@isTest static void testSAMLGETRequest() {
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' And name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.SAML_ENDPOINT, null, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			//Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
			//System.assertEquals('<script>document.cookie = "apex__brand=testbrand;Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + '; SameSite=Lax; Secure"; document.cookie = "apex__rurl=' + IdentityBrandingService.SAML_ENDPOINT +';Path=/;Max-Age=' + SiteBrandingIdentifier.referralUrlCookieMaxAge + '; SameSite=Lax; Secure"; window.location = "'+ IdentityBrandingService.SAML_ENDPOINT + '";</script>', res.responseBody.toString(),'The first and second parameter value should be match');
		}
	}

	@isTest static void testWEBGETRequest() {

		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' And name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.WEB_ENDPOINT, null, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
			//System.assertEquals('<script>document.cookie = "apex__brand=testbrand;Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + '; SameSite=Lax; Secure"; document.cookie = "apex__rurl=' + IdentityBrandingService.WEB_ENDPOINT +';Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + '; SameSite=Lax; Secure"; window.location = "'+ IdentityBrandingService.WEB_ENDPOINT + '";</script>', res.responseBody.toString(),'The first and second parameter value should be match');
		}
	}

	@isTest static void testLOGOUTGETRequest() {
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' And name = 'Informa Markets Site Guest User'AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			String referralurl = 'http://' + community.Name.toLowerCase() + '.informa.com';
			String referralurlEncoded = EncodingUtil.urlEncode(referralurl, 'UTF-8');
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.CUSTOM_LOGOUT_ENDPOINT, new Map<String, String> {'referralurl' => referralurl}, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
		}
	}

	@isTest static void testAuthGETRequest_IdeAppSecuritySettingsEnabled() {
		XssSecurityHelperTest.setupSettings(true);
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' And name ='Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.AUTHORIZE_ENDPOINT, null, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
			//System.assertEquals('<script>document.cookie = "apex__brand=testbrand;Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + '; SameSite=Lax; Secure"; document.cookie = "apex__rurl=' + IdentityBrandingService.AUTHORIZE_ENDPOINT +';Path=/;Max-Age=' + SiteBrandingIdentifier.referralUrlCookieMaxAge + '; SameSite=Lax; Secure"; window.location = "'+ IdentityBrandingService.AUTHORIZE_ENDPOINT + '";</script>', res.responseBody.toString(),'The first and second parameter value should be match');
		}
	}

	@isTest static void testAuthGETRequest_two_IdeAppSecuritySettingsEnabled() {
		XssSecurityHelperTest.setupSettings(true);
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' And name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			// Additional backslash added to end of service endpoint e.g. /services/oauth2/authorize/ ending / should be stripped off end to get branding
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.AUTHORIZE_ENDPOINT + '/', null, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
			//System.assertEquals('<script>document.cookie = "apex__brand=testbrand;Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + '; SameSite=Lax; Secure"; document.cookie = "apex__rurl=' + IdentityBrandingService.AUTHORIZE_ENDPOINT +';Path=/;Max-Age=' + SiteBrandingIdentifier.referralUrlCookieMaxAge + '; SameSite=Lax; Secure"; window.location = "'+ IdentityBrandingService.AUTHORIZE_ENDPOINT + '";</script>', res.responseBody.toString(),'The first and second parameter value should be match');
		}
	}

	@isTest static void testAuthGETRequestWithParams_IdeAppSecuritySettingsEnabled() {
		XssSecurityHelperTest.setupSettings(true);
		Account fedAuthAccount = new Account(Name = 'autossoclient');
		insert fedAuthAccount;
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' And name ='Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.AUTHORIZE_ENDPOINT, new Map<String, String> {'client_id' => 'ABC123', 'idessoclientid' => 'autossoclient'}, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
		}
	}

	@isTest static void testSAMLGETRequest_IdeAppSecuritySettingsEnabled() {
		XssSecurityHelperTest.setupSettings(true);
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' And name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.SAML_ENDPOINT, null, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
			//System.assertEquals('<script>document.cookie = "apex__brand=testbrand;Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + '; SameSite=Lax; Secure"; document.cookie = "apex__rurl=' + IdentityBrandingService.SAML_ENDPOINT +';Path=/;Max-Age=' + SiteBrandingIdentifier.referralUrlCookieMaxAge + '; SameSite=Lax; Secure"; window.location = "'+ IdentityBrandingService.SAML_ENDPOINT + '";</script>', res.responseBody.toString(),'The first and second parameter value should be match');
		}
	}

	@isTest static void testWEBGETRequest_IdeAppSecuritySettingsEnabled() {
		XssSecurityHelperTest.setupSettings(true);
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' And name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.WEB_ENDPOINT, null, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			//System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
			//System.assertEquals('<script>document.cookie = "apex__brand=testbrand;Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + '; SameSite=Lax; Secure"; document.cookie = "apex__rurl=' + IdentityBrandingService.WEB_ENDPOINT +';Path=/;Max-Age=' + SiteBrandingIdentifier.brandCookieMaxAge + '; SameSite=Lax; Secure"; window.location = "'+ IdentityBrandingService.WEB_ENDPOINT + '";</script>', res.responseBody.toString(),'The first and second parameter value should be match');
		}
	}

	@isTest static void testLOGOUTGETRequest_IdeAppSecuritySettingsEnabled() {
		XssSecurityHelperTest.setupSettings(true);
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' And name = 'Informa Markets Site Guest User'AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			// Get value from whitelist
			String referralurl;
			List<esso_Whitelist_Return_URLs__c> whiteList = SsoApplicationSecurity.getWhiteListUrls();
			if(whiteList != null && !whiteList.isEmpty()) {
				referralurl = whiteList[0].URL__c;
			}
			if(referralurl !=null) {
				String referralurlEncoded = EncodingUtil.urlEncode(referralurl, 'UTF-8');
			}
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.CUSTOM_LOGOUT_ENDPOINT, new Map<String, String> {'referralurl' => referralurl}, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
		}
	}

	@isTest static void testLOGOUTGETRequest_IdeAppSecuritySettingsEnabled_bad_url() {
		XssSecurityHelperTest.setupSettings(true);
		User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' And name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
		System.runAs(guestSiteUser){
			RestResponse res = new RestResponse();
			Network community = [SELECT Name FROM Network LIMIT 1]; // Get a community
			String referralurl = 'https://www.invalid-site.com';
			String referralurlEncoded = EncodingUtil.urlEncode(referralurl, 'UTF-8');
			RestRequest req = setRestRequest(community.Name.toLowerCase(), 'testbrand', IdentityBrandingService.CUSTOM_LOGOUT_ENDPOINT, new Map<String, String> {'referralurl' => referralurl}, 'GET');
			RestContext.request = req;
			RestContext.response = res;
			// Call Get
			IdentityBrandingService.doGet();
			System.assertEquals(200, res.statusCode,'The first and second parameter value should be match');
			System.assertEquals('text/html', res.headers.get('Content-Type'),'The first and second parameter value should be match');
		}
	}

	private static RestRequest setRestRequest(String community, String brand, String service, Map<String, String> parameters, String method){
		RestRequest req = new RestRequest();
		req.requestURI = '/identity/' + brand + service;
		req.httpMethod = method;
		// Loop through params and add them to the request
		if(parameters != null && !parameters.isEmpty()) {
			for(String key : parameters.keySet()) {
				req.addParameter(key, parameters.get(key));
			}
		}

		return req;
	}
}