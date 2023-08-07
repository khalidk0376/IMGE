/**************************************************************************
** Application      :   Informa Markets Identity (IM IdP)
** Last Modified    :   shay.spoonmore@informa.com 2020-06-18
** @description     :   [Checks user is logged in]
***************************************************************************/
public class esso_CustomerCheckController 
{
    public string ResponseJson {get; set;}
    private static string Communityhost = URL.getSalesforceBaseUrl().getHost();
    private static string CommunityPath = URL.getCurrentRequestUrl().getPath();
    private System.PageReference ApexPage = null;
    
    

    public  PageReference CheckCustomer()
    {
        
        HeaderCookieInformation();// debug info
        
        ApexPage = new PageReference('/signin');// Default redirect to always go home
        ApexPage.setRedirect(false);//server side redirect
        
        string refererUrl = ApexPages.currentPage().getHeaders().Keyset().contains('Referer') ? ApexPages.currentPage().getHeaders().get('Referer') : '';
        refererUrl = refererUrl.endsWith('/') ? refererUrl.left(refererUrl.length()-1) : refererUrl;
        
        System.debug('####!DEBUG! referal = '+ refererUrl + '; ' + SsoApplicationSecurity.isValidReturnUrl(refererUrl) );


        if (string.isBlank(refererUrl) || !refererUrl.startsWithIgnoreCase('https://')){return ApexPage;} // No referer or not secure, send home
        SsoApplicationSecurity.customerCheckBrandingUrlLookUp =   refererUrl;     
        if (!SsoApplicationSecurity.isValidReturnUrl(refererUrl)){return ApexPage;} // Not whitlisted send home
        
        //set default page headers
        ApexPages.currentPage().getHeaders().put('Content-Type', 'application/javascript');
        ApexPages.currentPage().getHeaders().put('Access-Control-Allow-Origin', refererUrl);
        ApexPages.currentPage().getHeaders().put('Access-Control-Allow-Credentials', 'true');
        ApexPages.currentPage().getHeaders().put('Access-Control-Allow-Methods', 'GET');
        
        //Check if users is logged in
        if(userInfo.getUserType() != 'Guest' && userInfo.getSessionId() !=null)
        {
           	ApexPages.currentPage().getHeaders().put('IdP', 'true');
           	ResponseJson = 'userCheck({"IdP":true});';
            
        }
        else
        {
            
			ApexPages.currentPage().getHeaders().put('IdP', 'false');
           ResponseJson = 'userCheck({"IdP":false});';      
            
        }
        
        
        return null;
    }
    
    



    
 static void HeaderCookieInformation()
    {
        System.debug('####!DEBUG! Host: ' + communityhost + '; UserType: ' + userInfo.getUserType() + '; UserSessionId: ' + userInfo.getSessionId()+ '; Query: ' + URL.getCurrentRequestUrl().getQuery() + '; path' + CommunityPath );
        
        //for(string item : ApexPages.currentPage().getHeaders().keySet())
       // {
       //     System.debug('####!DEBUG! Page Header - '+ item +': '+ ApexPages.currentPage().getHeaders().get(item));
       // }
        
        //for(string item : ApexPages.currentPage().getCookies().keySet())
       // {
       //     System.debug('####!DEBUG! Cookies - '+ item +': '+ ApexPages.currentPage().getCookies().get(item).getName());
       // }
    }

}