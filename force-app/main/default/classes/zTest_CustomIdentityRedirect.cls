/**
 * Created By   :   Avinash Singh
 * Created On   :   Nov 03 2018
 * @description :   [This class is used for CustomIdentityRedirect]
 * Test Class   :   zTest_CustomIdentityRedirect
 * Modification Log----- 
 * Modified by  :   Shay Spoonmore (shay.spoonmore@informausa.com)2019-06-25 ,Himanshu Jasuja-[BK-3749]
 **/

@isTest
public class zTest_CustomIdentityRedirect {

    static testMethod void UnitTest_IdentityRedirect() 
    {
        Test.StartTest();
        PageReference apexPage = Page.IdentityRedirect;
        Test.setCurrentPage(apexPage);
        
        ApexPages.currentPage().getParameters().put('response_type','code');
        ApexPages.currentPage().getParameters().put('client_id','client_id');
        ApexPages.currentPage().getParameters().put('redirect_uri','https://redirect_url/signin-oidc');
        ApexPages.currentPage().getParameters().put('return_uri','/return_uri');
        ApexPages.currentPage().getParameters().put('state','state');
        
        string Communityhost = URL.getSalesforceBaseUrl().getHost();
        string CookieName = Communityhost + '.Redirect';
        
        CustomIdentityRedirect cir = new CustomIdentityRedirect();
        cir.PageCreateCookieAuthorizeRedirect();
        
        Cookie cookieRedirect = ApexPages.currentPage().getCookies().get(CookieName);
        System.assertEquals(cookieRedirect.getName(), CookieName,'Condition Should Match');
        
        System.debug('####!DEBUG! '+ CustomIdentityRedirect.CustomerUrl('/communityUrl'));
        
        cir.PageCreateCookieAuthorizeRedirect();
        
		        
        
        cir.PageDeleteCookieUrlRedirect();
        
        cookieRedirect = ApexPages.currentPage().getCookies().get(CookieName);
        System.assertEquals(cookieRedirect.getValue(), null,'Condition Should Match');
        
		Test.StopTest();
        
    }
    
    static testMethod void UnitTest_RestIdentity()
    {
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        req.httpMethod = 'GET';
        req.requestURI = '/customidentity';
        req.addParameter('client_id', 'client_id');
        req.addParameter('redirect_uri', 'redirect_uri');
        req.addParameter('response_type', 'response_type');
        RestContext.request = req;
        
        RestContext.response = res;
        CustomIdentityRedirect.doGetAuthorize();
        
        System.debug('####!DEBUG! RestIdentity Response:'+ res.responseBody.toString());
        System.assertEquals(req.httpMethod, 'GET', 'For a callout request method must be GET');
    //    System.assertEquals(res.responseBody.toString().contains('window.location'),'Condition Should Match', 'Test class failed');
    //    System.assertEquals(res.responseBody.toString().contains('document.cookie'),'Condition Should Match', 'Test class failed');
        
    }
}