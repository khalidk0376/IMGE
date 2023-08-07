/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2019-06-25
***************************************************************************/
@RestResource(urlMapping='/customidentity/*')
global with sharing class CustomIdentityRedirect {
    
    private static string AuthorizeEndpoint = '/services/oauth2/authorize';
    private static integer CookieMaxAge = 120;//seconds
    private static string VsRedirectPage = '/IdentityRedirect';
    private  static string VsExceptionPage = '/Exception';
    private static string Communityhost = URL.getSalesforceBaseUrl().getHost();
    private static string CommunityPath = URL.getCurrentRequestUrl().getPath();
    private  static string CommunityName = CommunityPath.split('/')[1];
    private static string CookieName = Communityhost + '.Redirect';
    String rUrl= '';
    
    private System.PageReference ApexPage = null;
    
    @HttpGet
    global static void doGetAuthorize() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        //System.debug('####!DEBUG! CommunityName:'+ CommunityName +'; Communityhost: "' + Communityhost +'"');
        
        string responseType = req.params.get('response_type');
        string clientId = req.params.get('client_id');
        string redirectUri = req.params.get('redirect_uri');
        
        string bodyString = '<script>';
        
        System.debug('####!DEBUG! '+ communityName +' - Host: ' + communityhost + '; Query: ' + URL.getCurrentRequestUrl().getQuery() + '; path' + CommunityPath );
        
        if (req.params != null && !req.params.isEmpty() && redirectUri != null && responseType != null && clientId != null)
        {
            string authorizeUrl='';
            //System.debug('####!DEBUG! '+ communityName +' - Create Cookie: ' + cookieName);
            datetime redirectUrlCookieExpiry = Datetime.now().addSeconds(CookieMaxAge);
            string cookieExpiryDTFormat = 'EEE, dd MMM yyyy HH:mm:ss';
            string redirectUrlCookieExpiryStr = redirectUrlCookieExpiry.format(cookieExpiryDTFormat, 'GMT')  + ' UTC';
            
            string authorizeParams = '';
            for(string item : req.params.keySet())
            {
                authorizeParams += item + '=' + EncodingUtil.urlEncode(req.params.get(item), 'UTF-8') + '&';
            }
            
            if (authorizeParams.endsWith('&'))authorizeParams = '?' + authorizeParams.removeEnd('&');
            //Build Authorize Url
            authorizeUrl= '/' + CommunityName + AuthorizeEndpoint ;//CustomerCenter/services/oauth2/authorize
            authorizeUrl += authorizeParams;
            
            //System.debug('####!DEBUG! '+ communityName +' - SFDC Authorization URL: '+ authorizeUrl);
            
            // Create unique customer cookie to redirect to application
            
            System.debug('####!DEBUG! '+ communityName +' - Cookie "'+ cookieName +'" created with return customer url "'+ redirectUri +'"');
            bodyString += 'document.cookie = "apex__'+ CookieName +'=' + authorizeUrl + ';Path=/;Max-Age=' + redirectUrlCookieExpiryStr + ';secure"; ';
            bodyString += 'window.location = "' + authorizeUrl + '";</script>';
            
        }
        else
        {
            bodyString = '<script>window.location = "https://' + communityhost+ '/' + CommunityName + VsExceptionPage + '";</script>';
        }
        
        System.debug('####!DEBUG! bodyString: '+ bodyString );
        
        res.addHeader('Content-Type', 'text/html');
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(bodyString);
    }
    
    public  PageReference PageCreateCookieAuthorizeRedirect()//PageReference 
    {
        ApexPage = new PageReference(Communityhost);// Default redirect to always go home
        ApexPage.setRedirect(false);//server side redirect
        
        String authorizeRedirect = CreateCookieAuthorizeRedirect();
        
        if (authorizeRedirect != null)
        {
            System.debug('####!DEBUG! '+ communityName +' - Set Redirect to "' + authorizeRedirect +'"');
            ApexPage=new PageReference(authorizeRedirect);
            ApexPage.setRedirect(false);
            //rUrl = authorizeRedirect;
            
        }
        else
        {
            ApexPage=PageDeleteCookieUrlRedirect();
        }
        
        
        return ApexPage;
    }
    
    
    
    public string CreateCookieAuthorizeRedirect()
    {
        string authorizeUrl = null;
        string communityUrl = ApexPages.currentPage().getURL();
        string responseType = ApexPages.currentPage().getParameters().get('response_type');
        string clientId = ApexPages.currentPage().getParameters().get('client_id');
        string redirectUri = ApexPages.currentPage().getParameters().get('redirect_uri');
        
        //string redirectUrl = ApexPages.currentPage().getParameters().get('redirect_url');
        //string returnUri = ApexPages.currentPage().getParameters().get('return_uri');
        //string state = ApexPages.currentPage().getParameters().get('state');
        //string eventCode = ApexPages.currentPage().getParameters().get('eventcode');//branding
        //string eventEdition = ApexPages.currentPage().getParameters().get('eventedition');//branding
        
        System.debug('####!DEBUG! '+ communityName +' - Host: ' + communityhost + '; Query: ' + URL.getCurrentRequestUrl().getQuery() + '; path' + CommunityPath );
        
        if (ApexPages.currentPage().getParameters() != null && !ApexPages.currentPage().getParameters().isEmpty() && redirectUri != null && responseType != null && clientId != null)
        {
            //System.debug('####!DEBUG! '+ communityName +' - Create Cookie: ' + cookieName);
            //Cookie hostRedirect = ApexPages.currentPage().getCookies().get(cookieName);
            //if (hostRedirect==null)
            //{
            //Build Authorize Url
            //authorizeUrl= 'https://' + communityhost+ '/' + CommunityName + AuthorizeEndpoint ;//CustomerCenter/services/oauth2/authorize
            //authorizeUrl += '?client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8'); 
            //authorizeUrl += '&redirect_uri=' + (redirectUri != null?EncodingUtil.urlEncode(redirectUri, 'UTF-8') :EncodingUtil.urlEncode(redirectUrl, 'UTF-8'));
            //authorizeUrl += '&response_type=' + EncodingUtil.urlEncode(responseType, 'UTF-8');
            //if(state!=null) authorizeUrl += '&state=' + EncodingUtil.urlEncode(state, 'UTF-8');
            //Add Branding
            //if(eventcode!=null) authorizeUrl += '&eventcode=' + EncodingUtil.urlEncode(eventcode, 'UTF-8');
            //if(eventEdition !=null) authorizeUrl += '&eventedition=' + EncodingUtil.urlEncode(eventEdition, 'UTF-8');
            
            //if(returnUri!=null)
            //{
            //   redirectUrl = 'https://' + (redirectUri != null? redirectUri.Split('/')[2]:redirectUrl.Split('/')[2]);//get domain only to return to customer application
            //  redirectUrl = redirectUrl + (returnUri == null? '':returnUri);// add customer uri, location to return
            //}
            //  else
            //  {
            //      redirectUrl = redirectUri;
            //  }
            
            System.debug('####!DEBUG! '+ communityName +' - SFDC Authorization URL: '+ authorizeUrl);
            authorizeUrl= '/' + CommunityName + AuthorizeEndpoint ;
            
            string authorizeParams = '';
            for(string item : ApexPages.currentPage().getParameters().keySet())
            {
                authorizeParams += item + '=' + EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get(item).escapeHtml4(), 'UTF-8') + '&';
            }
            
            if (authorizeParams.endsWith('&')) authorizeParams = '?' + authorizeParams.removeEnd('&');
            authorizeUrl += authorizeParams;   
            
            // Create unique customer cookie to redirect to application
            //hostRedirect = new Cookie(CookieName,redirectUrl,null,CookieMaxAge,true);
            Cookie hostRedirect = new Cookie(CookieName,authorizeUrl,null,CookieMaxAge,true);
            ApexPages.currentPage().setCookies(new Cookie[]{hostRedirect});
            
            System.debug('####!DEBUG! '+ communityName +' - Cookie "'+ cookieName +'" created with return customer url "'+ authorizeUrl+'"');
            //}
            
        }
        else
        {
            System.debug('####!ERROR! Missing authorization required parameters. Query parameters provided: '+ URL.getCurrentRequestUrl().getQuery() + '; path' + CommunityPath );
            authorizeUrl=VsExceptionPage;
        }
        
        
        return  authorizeUrl;  
    }
    
    public PageReference PageDeleteCookieUrlRedirect()
    {  
        
        string webRedirect = DeleteCookieUrlRedirect();
        if (webRedirect != null)
        {
            ApexPage=new PageReference(webRedirect);
            ApexPage.setRedirect(false);
            
        } 
        
        return ApexPage;
    }
    
    public static string CustomerUrl(string uri)
    {
        Cookie cookieRedirect = ApexPages.currentPage().getCookies().get(CookieName);
        
        if (cookieRedirect != null)
        {
            System.debug('####!DEBUG! cookieRedirect.getValue(): '+ cookieRedirect.getValue());
            uri=cookieRedirect.getValue();
            System.debug('####!DEBUG! '+ communityName +' - Cookie "'+ CookieName +'" exists and sending customer to custom redirect "'+ uri +'"');
        }
        
        return uri;
    }
    
    
    public string DeleteCookieUrlRedirect()
    {
        string redirectUrl = null;
        
        
        Cookie cookieRedirect = ApexPages.currentPage().getCookies().get(CookieName);
        
        if (cookieRedirect != null)
        {
            redirectUrl = cookieRedirect.getValue();//customer aplication url
            cookieRedirect = new Cookie(cookieName,null,null,0,true);//set maxage to zero, the cookie is deleted.
            ApexPages.currentPage().setCookies(new Cookie[]{cookieRedirect});
            
            
            System.debug('####!DEBUG! '+ communityName +' - Deleting Cookie "'+ CookieName +'" and sending customer to url "'+ redirectUrl +'"');            
        }
        
        return  redirectUrl;  
    }
    
    
}