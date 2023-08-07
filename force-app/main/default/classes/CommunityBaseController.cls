/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 01 2019
 * @description :   [For Header, Footer Branding of Informa Markets Community.]
 * Test Class   :   CommunityBaseControllerTest
 * Modification Log-----
 * Modified by  :   Shay.Spoonmore@informa.com (20200813)
 * Ticket No    : BK-14521 Updating API Version
 **/
public with sharing class CommunityBaseController {

    public SiteBrandingIdentifier siteBranding { get; private set;}
    public String loginURL {get; private set;}
    Public String localLanguage {get; public set;}
    Public String adobeAnalyticId {get {return esso_Configuration.setting.Adobe_Analytics_Id__c;} private set;}
    Public String urlSelfReg {get {return goToSelfReg().getURL();} private set;}
    Public String urlLogin {get {return goToLogin().getURL();} private set;}
    Public Boolean isSocialNetwork {get {return esso_Configuration.isSocialNetwork;} private set;}
    Public Boolean isInformaEmployeeIdentity {get {return esso_Configuration.isInformaEmployeeIdentity;} private set;}
    Public esso_Configuration.SocialNetwork informaEmployeeIdentity {get {return esso_Configuration.informaEmployeeIdentity;} private set;}
    Public String UserID {get; set;}
    
    private static String testNetworkId {
      get {
        CommunityBaseController.setTestNetworkId(testNetworkId);
        return testNetworkId;
      }
      set;
    }
    
    public String passwordPolicy {
      get {
        if(String.isBlank(passwordPolicy)) {
          // Gets the password policy text from the site guest user profile to display on screen to user.
          // Dynamically changes when profile settings are updated
          passwordPolicy = Site.getPasswordPolicyStatement();
        }
        return passwordPolicy;
      }
      private set;
    }
    
    // CONSTRUCTOR
    public CommunityBaseController() {
    
      // Instantiate the branding object
      siteBranding = new SiteBrandingIdentifier();
    
      // verify parameters against whitelists
      SSOApplicationSecurity.verifyPageParameters();
      UserId= UserInfo.getUserId();
      
      //First attempt to get the referralid from the url param
      localLanguage= String.isBlank(siteBranding.language) ? UserInfo.getLocale() : siteBranding.language;
      
      System.debug('####!DEBUG! CommunityBaseController: SiteBrandingIdentifier.isValidReferralId='+ SiteBrandingIdentifier.isValidReferralId + '; referralId='+ SiteBrandingIdentifier.referralId + '; localLanguage=' + localLanguage + '; UserInfo.getUserId()=' + UserInfo.getUserId() + '; UserInfo.getLocale();' + UserInfo.getLocale());
      
      
      
      //SAS-20200131- "delete code after 30 days". problem - if referalid is not valid this errors because of "with sharing" looking up user loacal by SOQL. works in prod not sand, salesforce implemented security change. fix - code not needed becuase userinfo has function getLocale() 
      //if(!SiteBrandingIdentifier.isValidReferralId && UserID != null)
      //{
      //  List<User> usr= New List<User>();
      //  //Querying on User object to get the LocalesidKey basis of UserID
      //  usr =[Select Id,name,LocaleSidKey From User Where Id=:UserInfo.getUserId() Limit 1];
      //  localLanguage = usr[0].LocaleSidKey;
      //}
    
    
      loginURL = getPageReferenceURL(goToLogin());
    }
    
    private String getPageReferenceURL(PageReference returnPage){
      return (returnPage != null) ? returnPage.getUrl() : null;
    }
    
    public PageReference goToLogout(){
    
      PageReference returnPage;
    
      if(getCurrentNetworkId() != null) {
    
        // Gets the logout url for the community using the network class.  This returns the page community will redirect to post logout and not the actual logout url
        String logoutURLStr = Network.getLogoutUrl(getCurrentNetworkId());
        returnPage = (String.isNotBlank(logoutURLStr)) ? new PageReference(logoutURLStr) : null;
      }
      return returnPage;
    }
    
    public PageReference goToLogin(){
    
      PageReference returnPage;
    
      if(getCurrentNetworkId() != null) {
    
        // Gets the login url for the community using the network class
        String loginURL = Network.getLoginUrl(getCurrentNetworkId());
        returnPage = (String.isNotBlank(loginURL)) ? new PageReference(loginURL) : null;
      }
      return addBrandingParams(returnPage); // return the page reference with re-applying branding parameter to keep branding consistent on redirect
    }
    
    
    
    public PageReference goToSelfReg(){
    
      PageReference returnPage;
    
      if(getCurrentNetworkId() != null) {
    
        // Gets the self registration url for the community using the network class
        String selfRegUrl = Network.getSelfRegUrl(getCurrentNetworkId());
        returnPage = (String.isNotBlank(selfRegUrl)) ? new PageReference(selfRegUrl) : null;
      }
      return addBrandingParams(returnPage); // return the page reference with re-applying branding parameter to keep branding consistent on redirect
    }
    
    public PageReference goToForgotPassword(){
      return addBrandingParams(Page.ssoForgotPassword);
    }
    
    public PageReference goToDefaultLandingPage(){
      return (String.isNotBlank(siteBranding.defaultLandingUrl)) ? new PageReference(siteBranding.defaultLandingUrl) : null;
    }
    
    @TestVisible   // Test visible required as testing Network class will return null, direct testing of method requried
    private PageReference addBrandingParams(PageReference returnPage){
    
      // Check if page reference & site branding exists and if a referral id was provided
      if(returnPage != null && siteBranding != null) {   
        if(String.isNotBlank(SiteBrandingIdentifier.referralId)) {
          // Add the referral id as a param to the return page
          string referralId = SiteBrandingIdentifier.referralId;                          
          if (referralId.length()>100) {
            referralId = siteBranding.verticalDefaultBranding.Referral_Id__c;
          }
          returnPage.getParameters().put('referralId', SiteBrandingIdentifier.referralId);
        }
        if(String.isNotBlank(siteBranding.referralUrl) && siteBranding.referralUrl.length() < 2500) {                         
          returnPage.getParameters().put('referralurl', siteBranding.referralURl);
          //returnPage.getParameters().put('referralurl', EncodingUtil.urlEncode(siteBranding.referralURl, 'UFT-8'));
        }
      }
      return returnPage;
    }
    
    public static String getCurrentNetworkId(){
      // Get the current network Id not when in unit tests, otherwise use value that would be set in test class
      return (Test.isRunningTest()) ? testNetworkId : Network.getNetworkId();
    }
    
    
    @TestVisible
    // Method used in test
    private static void setTestNetworkId(String unitTestId){
    
      // Set network id based on param or query a community from network obj
      CommunityBaseController.testNetworkId = (String.isBlank(unitTestId)) ? [SELECT Id FROM Network LIMIT 1].Id : unitTestId;
    }
    
    public static PageReference getStartPage(){
      return Page.landing;
      //return null;
    
    }
    
    public PageReference getStartPageWithParams(){
      return addBrandingParams(getStartPage());
    }
    
    public PageReference forwardAuthUserToStartPage(){
    
      //System.debug('*** -- Auth.CommunitiesUtil.isGuestUser()' + Auth.CommunitiesUtil.isGuestUser());
      //System.debug('*** -- Auth.CommunitiesUtil.isInternalUser()' + Auth.CommunitiesUtil.isInternalUser());
      //System.debug('*** -- Userinfo.getSessionId() != null )' + (Userinfo.getSessionId() != null));
    
      PageReference returnPage;
      if (Userinfo.getSessionId() != null && (!Auth.CommunitiesUtil.isGuestUser() || Auth.CommunitiesUtil.isInternalUser())) {
        // Redirect to post login landing page if user is authenticated user
        returnPage = getStartPageWithParams();
      }
      return returnPage; // returns null if user is unauthenticated to continue action as required.
    }
    }