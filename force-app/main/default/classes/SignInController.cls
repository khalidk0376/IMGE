/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 15 2019
 * @description :   [This class using for user sign in into the community with the custom signin VF page]
 * Test Class   :   SignInControllerTest
 * Modification Log-----
 * Modified by  :   Shay.Spoonmore@informa.com (20190611)
 **/
global without sharing class SignInController {

    global String username {get; set;}
    global String password {get; set;}
    global Boolean rememberme {get; set;}
    
    @testVisible private String startUrl {get; set;}
    @testVisible private String postLoginUrl {get; set;}
    
    public esso_User essoUser = new esso_User();
    public CommunityBaseController controller {get; set;}
    
    public static final Integer usernameCookieMaxAge = 60*60*24*365;     // 1 year
    
    @TestVisible private Boolean testIs {get; set;}
    @TestVisible private Boolean testSuccessfulLogin {get; set;}
    
    public Boolean returningFederatedUser {get; set;}
    
    public String loginNotification {
    
      get {
        if(String.isBlank(loginNotification)) {
          loginNotification = CommunityUtility.getLabelMessage(controller.siteBranding, label.Communities_Login_Notification);
        }
        return loginNotification;
      }
      private set;
    }
    
    // CONSTRUCTOR
    public SignInController(CommunityBaseController controller) {
      this.controller = controller;
    
      startUrl = System.currentPageReference().getParameters().get('startURL');
      System.debug('*** -- SignIn startUrl: ' + startUrl);
      System.debug('*** -- page getParameters: ' + System.currentPageReference().getParameters());
    
      // If a starturl is provided capture this in the referral URL cookie
      // so that post login / fed auth flow will redirect ot this page
      if(String.isNotBlank(startUrl)) {
        // set the site branding referral url to the start url
        this.controller.siteBranding.setReferralUrl(startUrl);
        // reset the referral url cookie
        this.controller.siteBranding.setReturnURLCookie(null, false);
      }
    
      testSuccessfulLogin = false;
      testIs = false;
    
      // Look for cookie on page load and prepopulate username
      rememberUser();
    
      // Look for federated cookie on page load
      //federatedUser();
    
      // Now look for username param as this overrides all stored values
      if(System.currentPageReference().getParameters().containsKey('u')) {
        username = System.currentPageReference().getParameters().get('u');
        System.debug('Shiv UserName' +username);
      }
    
      //Apply Business Email verification message
      businessEmailMessage();
    
      //do reset email process and display message
      resetPasswordMessage();
    
    }
    
    private void resetPasswordMessage()
    {
        
        //Display message to verify user
      Cookie rp= esso_User.resetPasswordGetCookie();
    
      if(rp != null && String.isNotBlank(rp.getValue())  )
      {
        System.debug('#### !DEBUG! resetPasswordGetCookie(): ' + rp.getValue());
    
        // Check if reset was successful
        Boolean resetSuccessful = Site.forgotPassword(rp.getValue());
        if(resetSuccessful || esso_ConfigurationTest.isTest)
        {
          username = rp.getValue();
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, '&nbsp;&nbsp;' + label.Communities_Forgot_Password_Submit_Confirm));
        }
        else {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + label.Communities_Forgot_Password_Reset_Error));
        }
        //Expire cookie
        esso_User.resetPasswordExpireCookie();
      }
    
    }
    
    private void businessEmailMessage()
    {
        
        //Display message to verify user
      Cookie be = esso_User.businessEmailGetCookie();
    
      if(be != null && String.isNotBlank(be.getValue())  )
      {
        System.debug('#### !DEBUG!  businessEmailMessage(): ' + be.getValue());
        List<String> v = be.getValue().split(';');
        String businessEmailMessage= Label.esso_BusinessEmailMessage;
        //'Business email “<b>{businessEmail}</b>” already exist and requires verification before continuing. Please login with this user to verify or re-login with “{provider}” to change.';
        businessEmailMessage=businessEmailMessage.replace('{businessEmail}', v[0]);
        businessEmailMessage=businessEmailMessage.replace('{provider}',v[2]);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '&nbsp;&nbsp;' + businessEmailMessage ));
          
        username = v[0];
      }
    
    }
    
    
    
    
    global PageReference login() {
    
      System.debug('*** -- pre SignIn startUrl: ' + startUrl);
    
      // Check if a startURL was provided and set value if blank
      // IEP-1367 - Update to send via start page so seamless cookie is set always on login regardess of route
      if(String.isNotBlank(startUrl)) {
        system.debug('CommunityBaseController.getStartPage().getUrl():'+CommunityBaseController.getStartPage().getUrl() );
        postLoginUrl = CommunityBaseController.getStartPage().getUrl() + '?referralurl=' + startUrl;
      }else{
        postLoginUrl = this.controller.getStartPageWithParams().getUrl();
      }
    
      //Add param for default provider to now how user logged in
      if(postLoginUrl.contains('?')) {postLoginUrl += '&provider=' + esso_Configuration.DEFAULT_PROVIDER;} else {postLoginUrl += '?provider=' + esso_Configuration.DEFAULT_PROVIDER;}
    
      System.debug('#### !DEBUG! Post SignIn startUrl: ' + startUrl);
      System.debug('#### !DEBUG! Post SignIn postLoginUrl: ' + postLoginUrl);
    
      //redirect informa employee
      PageReference employeeRedirect = essoUser.employeeRedirect(username);
      if (employeeRedirect != null) 
      {
        return employeeRedirect;
      }
    
      PageReference returnPage =  Site.login(username, password, postLoginUrl);
    
      if(returnPage != null || (Test.isRunningTest() && testSuccessfulLogin)) {
        // Set the remember be cookie
        setRememberMeCookie();
    
        //Do business email verification and redirect back to provider to verify and call reghandler to re-map current user to provider user
            esso_User essoUser = new esso_User();
            PageReference redirectToProvider = essoUser.businessEmailVerified(username);
        returnPage = (redirectToProvider == null ? returnPage : redirectToProvider);
      }
    
      return returnPage;
    }
    
    
    
    global PageReference forgotPassword(){
    
      PageReference returnPage = controller.goToForgotPassword();
      returnPage.getParameters().put('u', username);
      return returnPage;
    }
    
    @testVisible
    private Cookie getRememberMeCookie(){
      return ApexPages.currentPage().getCookies().get('rusr');
    }
    
    private void rememberUser(){
    
      rememberme = false;
    
      // If no param is found search for cookie set via IdentiyBrandingService
      Cookie rememberMeCookie = getRememberMeCookie();
    
      if(rememberMeCookie != null) {
        // Extract the value from the remember me cookie
        username = XssSecurityHelper.getXssCleanString(rememberMeCookie.getValue());
        rememberme = (String.IsNotBlank(username));
      }
    }
    
    private void setRememberMeCookie(){
    
      // Set the cookie age based on the remember me variable
      Integer maxAge = (rememberme && isValidUsername()) ? usernameCookieMaxAge : 0; // -1 = session, 0 = delete
    
      // create the cookie
      Cookie rememberMeCookie = new Cookie('rusr', username, null, maxAge, true);
    
      // Assign cookie to page
      ApexPages.currentPage().setCookies(new List<Cookie> {rememberMeCookie});
    }
    
    @testVisible
    private Cookie getFedAuthUserCookie(){
      return ApexPages.currentPage().getCookies().get('fedusr');
    }
    
    
    
    /* private void federatedUser(){
          returningFederatedUser = false;
    
          // check for federated user cookie
          Cookie fedAuthUserCookie = getFedAuthUserCookie();
    
          if(fedAuthUserCookie != null){
              // Extract the value from the remember me cookie
              username = XssSecurityHelper.getXssCleanString(fedAuthUserCookie.getValue());
              returningFederatedUser = (String.IsNotBlank(username));
          }
       }*/
    
    /* 2018-11-06 Logic moved to UI Javascript and JQuery page updates
       public void cancelFederatedQuickSignIn(){
        returningFederatedUser = false;
       }
     */
    
    public PageReference authValidate(){
    
      /* PageReference returnPage;
    
         Boolean initiatefedauthsso = (ApexPages.currentPage().getParameters().containsKey('initiatefedauthsso')) ? Boolean.valueOf(ApexPages.currentPage().getParameters().get('initiatefedauthsso')) : false;
         String returncommunity = (ApexPages.currentPage().getParameters().containsKey('returncommunity')) ? ApexPages.currentPage().getParameters().get('returncommunity') : '';
    
         FederatedSsoController sso = new FederatedSsoController();
         String ssoClientId = sso.ssoclientid;
    
         // Fed auth SSO iniated redirect onto client auth provider
         if(String.isNotBlank(username) && initiatefedauthsso && String.isNotBlank(returncommunity)){
           String ssoURL = FederatedSSOController.getSsoUrl(username, returnCommunity);
           if(String.isNotBlank(ssoURL)){
               returnPage = new PageReference(ssoURL);
           }
         }else if(String.isNotBlank(ssoClientId) && initiatefedauthsso && String.isNotBlank(returncommunity)){
    
           String ssoURL = FederatedSSOController.getClientSsoUrl(ssoClientId, returnCommunity);
    
           if(String.isNotBlank(ssoURL)){
               returnPage = new PageReference(ssoURL);
           }
         }else{
           // Check if user is authenticated and redirect onto start page
           returnPage = controller.forwardAuthUserToStartPage();
         }
         return returnPage;*/
    
      return controller.forwardAuthUserToStartPage();
    }
    
    private Boolean isValidUsername(){
      Boolean isValid = false;
      if(!XssSecurityHelper.isXssVulnerable(username)) {
        List<User> users = [SELECT Id FROM User WHERE Username = :username LIMIT 1];
        isValid = (users != null && !users.isEmpty());
      }
      return isValid;
    }
    
    }