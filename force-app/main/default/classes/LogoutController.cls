/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-57)]
 * Created On   :   May 16 2019
 * @description :   [Logout VF page controller used to redirect user to referral URL]
 * Test Class   :   LogoutControllerTest
 * Modification Log-----
 * Modified by  :   Shay.spoonmore@informa.com 20200715
 **/
public without sharing class LogoutController {

private CommunityBaseController controller {get; set;}
public String redirectLocation {get; set;}
public Boolean deleteIdeSessionCookie {get; set;}

@TestVisible private static final String SF_LOGOUT_ENDPOINT = '/secur/logout.jsp';

// CONSTRUCTOR
public LogoutController(CommunityBaseController controller) {


	this.controller = controller;
	PageReference returnPage = redirect();
	if(returnPage != null) {
		redirectLocation = returnPage.getUrl();
	}

	deleteIdeSessionCookie = false;
}

public PageReference redirect(){

	String sessionId = UserInfo.getSessionId();
	String userType = UserInfo.getUserType();

	// Get the referral url from the branding i.e. via a param or cookie
	String referralurl = controller.siteBranding.referralurl;
	// Set the return page to the referral url and if not found to informa.com
	PageReference returnPage;


	System.debug('####!DEBUG! FederatedAuthProviderUtility.getDefaultCommunityURL():'+ FederatedAuthProviderUtility.getDefaultCommunityURL() + '; URL.getSalesforceBaseUrl().getHost():' + URL.getSalesforceBaseUrl().getHost() + '; URL.getCurrentRequestUrl().getPath(): ' + URL.getCurrentRequestUrl().getPath() + '; size:' + URL.getCurrentRequestUrl().getPath().split('/').size());
	System.debug('####!DEBUG! SessionId:'+ UserInfo.getSessionId() +'; UserType: ' + UserInfo.getUserType() + '; referralurl: ' + referralurl);
	// First check if the user is logged in and redirect them to the sf logout url
	if(String.isNotBlank(sessionId) && String.isNotBlank(userType) && !userType.equalsIgnoreCase('guest')) {


		//string refererUrl = ApexPages.currentPage().getHeaders().Keyset().contains('Referer') ? ApexPages.currentPage().getHeaders().get('Referer') : '';
		//

		//Set headers for friendly Informa Markets websites to use within Ajax, etc
		string refererUrl = referralurl;
        // Added by palla Kishore for the ticket EMEA-264 (This will run only when the test class is ran)
        if(test.isRunningTest()){
            refererUrl = 'www.google.com';
        }
		refererUrl = refererUrl.endsWith('/') ? refererUrl.left(refererUrl.length()-1) : refererUrl;
		if(String.isNotBlank(refererUrl))
		{
			SsoApplicationSecurity.customerCheckBrandingUrlLookUp = refererUrl;

			if (SsoApplicationSecurity.isValidReturnUrl(refererUrl))
			{

				System.debug('####!DEBUG! SessionId:'+ UserInfo.getSessionId() +'; UserType: ' + UserInfo.getUserType() + '; refererUrl: ' + refererUrl);
				//set headers to allow to be iframed for seemless logout
				ApexPages.currentPage().getHeaders().put('Access-Control-Allow-Origin', refererUrl);
				ApexPages.currentPage().getHeaders().put('Access-Control-Allow-Credentials', 'true');
				ApexPages.currentPage().getHeaders().put('Access-Control-Allow-Methods', 'GET, OPTIONS');
				ApexPages.currentPage().getHeaders().put('Content-Security-Policy', 'frame-ancestors ' + refererUrl);
				ApexPages.currentPage().getHeaders().put('X-Frame-Options', 'ALLOW-FROM ' + refererUrl);
				// Http h = new Http();
				// HttpRequest req = new HttpRequest();
				// req.setEndpoint('https://identitydv-globalexhibitions.cs27.force.com/InformaMarkets/services/auth/idp/oidc/logout');
				// //req.setEndpoint('https://identitydv-globalexhibitions.cs27.force.com/InformaMarkets/secur/logout.jsp');
				// req.setMethod('GET');
				// req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
				// HttpResponse res = h.send(req);
				// System.debug('####!DEBUG! res.getStatusCode():'+ res.getStatusCode() +'; res.getStatus(): ' + res.getStatus());

			}

		}

		// First check the if the user is fed auth and the currnet community
		// If they are federated check they have called the admin community
		//if([SELECT Is_Federated__c From USER WHERE Id = :UserInfo.getUserId() LIMIT 1].Is_Federated__c){
		//Network defaultCommunityNetwork = FederatedAuthProviderUtility.getDefaultCommunityNetworkId();
		//Id currentCommunityNetworkId = CommunityBaseController.getCurrentNetworkId();
		//String defaultCommunityUrl = FederatedAuthProviderUtility.getDefaultCommunityURL();
		//System.debug('*** -- defaultCommunityUrl: ' + defaultCommunityUrl );
		// System.debug('*** -- currentCommunityNetworkId: ' + currentCommunityNetworkId);

		/*if(defaultCommunityNetwork.Id != currentCommunityNetworkId){
		    // Send user onto the default community to logout user
		    // Rebuild the logout url with the default community url*/
		// String defaultCommunityLogoutUrl = defaultCommunityUrl + '/services/apexrest/identity/' + this.controller.siteBranding.referralId + '/logout?referralurl=' + this.controller.siteBranding.referralUrl;
		//String defaultCommunityLogoutUrl = defaultCommunityUrl + '/secur/logout.jsp' ;//+ this.controller.siteBranding.referralId + '/logout?referralurl=' + this.controller.siteBranding.referralUrl;


		string path = (URL.getCurrentRequestUrl().getPath().split('/').size() > 3 ? '/' + URL.getCurrentRequestUrl().getPath().split('/')[1] : '');
		String defaultCommunityLogoutUrl = 'https://' + URL.getSalesforceBaseUrl().getHost() + path + SF_LOGOUT_ENDPOINT;//sas
		System.debug('####!DEBUG! defaultCommunityLogoutUrl: ' + defaultCommunityLogoutUrl);
		returnPage = new PageReference(defaultCommunityLogoutUrl);
		//returnPage = new PageReference(SF_LOGOUT_ENDPOINT);
		returnPage.setRedirect(false);//server side redirect

		// for ( string ss : ApexPages.currentPage().getHeaders().keySet())
		// {

		// 	System.debug('####!DEBUG! Header: ' + ss   + '; ' + ApexPages.currentPage().getHeaders().get(ss ));

		// }

		System.debug('####!DEBUG! returnPage: ' + returnPage);
		return returnPage;


		// Call SF logout url, which inturn will redirect back to this page once logout is performed (driven by community config)

		//return new PageReference(SF_LOGOUT_ENDPOINT);

	}else if(String.isNotBlank(referralurl)) {
		// instantiate page ref of redirect url
		returnPage = new PageReference(referralurl);
	}
	// 	Note:20200901 - this section should no longer be needed because url will always use default brands url when blank or not found
	//	else
	// {
	// 	// Assign default landing on logout and if null assign www.informa.com
	// 	returnPage = (controller.goToDefaultLandingPage() != null) ? controller.goToDefaultLandingPage() : new PageReference('http://www.informamarkets.com');
	// }

	// Now clear the ide_session cookie
	deleteIdeSessionCookie = true;

	// Clear the redirect cookie incase it is not reset when user next logs in they would have been redirected back to this referral url
	returnPage = controller.siteBranding.setReturnURLCookie(returnPage, true);

	// for ( string ss : ApexPages.currentPage().getHeaders().keySet())
	// {

	// 	System.debug('####!DEBUG! Header: ' + ss   + '; ' + ApexPages.currentPage().getHeaders().get(ss ));

	// }
	returnPage.setRedirect(false);//server side redirect
	return returnPage;
}

}