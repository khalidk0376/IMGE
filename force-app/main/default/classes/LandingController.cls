/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 09 2019
 * @description :   [Landing VF page controller used to detect user auth, collect missing info and redirect to login page if not authenticated]
 * Test Class   :   LandingControllerTest
 * Modification Log-----
 * Modified by  :   Shay.Spoonmore@informa.com (20200709)
 **/
public without sharing class LandingController {

  public Boolean isTestIgnore  = false;//used to allow testmethod scenario coverage
  private CommunityBaseController controller {get; set;}
  public esso_User essoUser = new esso_User();
  public User theUser             { get;  set;}
  public Boolean privacyPolicy       { get;  set;} public String redirectLocation {get; set;}
  public Boolean deleteIdeSessionCookie {get; set;}
  public Boolean isVissibleBusinessEmail {get; set;}
  public String BusinessEmail {get; set;}
  
  public static final Integer federatedAuthCookieMaxAge = 60*60*24*365;     // 1 year
  
  @TestVisible
  public User currentUser {get {return (currentUser != null ? currentUser : esso_User.getCurrentWebUser);  }  private set;} public user existingBusinessEmail  { get { existingBusinessEmail = essoUser.getUserByUsername(BusinessEmail);  return existingBusinessEmail;  }
    private set;
  }
  
  // CONSTRUCTOR
  public LandingController(CommunityBaseController controller) {  this.controller = controller;  deleteIdeSessionCookie = esso_User.isGuestUser();  if (esso_User.isGuestUser()) {
  
    authValidate();
  }
  
    else{ 
      if(!isTestIgnore)  {  
        theUser = new User();  theUser.FirstName = currentUser.FirstName;  theUser.LastName = currentUser.LastName;  theUser.esso_Privacy_Policy_Agreed__c = (privacyPolicy == true ? true : currentUser.esso_Privacy_Policy_Agreed__c);  theUser.CountryCode = currentUser.Countrycode;  theUser.esso_QA_Business_Email__c = currentUser.esso_QA_Business_Email__c;  theUser.esso_Business_Email__c = (BusinessEmail==null ? currentUser.esso_Business_Email__c : BusinessEmail);theUser.Email = currentUser.Email;  privacyPolicy = theUser.esso_Privacy_Policy_Agreed__c;  BusinessEmail = theUser.esso_Business_Email__c;  
      }  
        if(currentUser.username.contains('@login.phone')){            theUser.esso_QA_Business_Email__c = 'No';  
        }  
          isVissibleBusinessEmail = true;    if(isDefaultProvider())    {             isVissibleBusinessEmail = false;
          }  } } 
          @testVisible 
          private PageReference updateUserInfo(){   PageReference businessEmailVerification = null;  Esso_Site_Branding__c siteBrand = SiteBrandingIdentifier.siteBrandings.get(esso_Configuration.setting.Branding_Default__c);  
            if(SiteBrandingIdentifier.isValidReferralId) {    siteBrand = SiteBrandingIdentifier.siteBrandings.get(SiteBrandingIdentifier.referralId);  }
  
  
    //Update user info, branding, or Provider
    User u = new User();  if(isRequiredUserInfo(currentUser))  {    u.Id= UserInfo.getUserId();    u.FirstName = theUser.FirstName;    u.LastName = theUser.LastName;    u.CountryCode = theUser.CountryCode;    u.esso_Privacy_Policy_Agreed__c= privacyPolicy ? true : false;  if(!isDefaultProvider() && (BusinessEmail != currentUser.esso_Business_Email__c || theUser.esso_QA_Business_Email__c != currentUser.esso_QA_Business_Email__c))  { if(theUser.esso_QA_Business_Email__c == 'Yes' || (theUser.esso_QA_Business_Email__c == 'No' && BusinessEmail == currentUser.username)){  u.esso_Business_Email__c = null; u.esso_QA_Business_Email__c= 'Yes';  }  else{ if (isExistingBusinessEmail())  { esso_User.businessEmailSetCookie( BusinessEmail, UserInfo.getUserId(), currentUser.esso_LastLoginProviderType__c ); businessEmailVerification = controller.goToLogout();    }else  {  u.username=BusinessEmail;    u.email=BusinessEmail;  u.esso_Business_Email__c = null;  u.esso_QA_Business_Email__c = 'Yes';  }  }}  }  if(isUpdateUserBranding(currentUser, siteBrand))  {    u.Id= UserInfo.getUserId();    u.LocaleSidKey = siteBrand.Language__c;    u.LanguageLocaleKey = siteBrand.Language__c;    u.esso_LocalLanguage__c= siteBrand.Language__c;    u.esso_BrandId__c=siteBrand.Referral_Id__c.toLowerCase();    u.esso_BrandName__c=siteBrand.Product_Name__c;    u.esso_BrandSupportEmail__c= siteBrand.Customer_Support_Email__c;  }  if(isDefaultProviderUpdate(currentUser))  {    u.Id= UserInfo.getUserId();    u.esso_LastLoginProviderType__c = esso_Configuration.DEFAULT_PROVIDER;    u.esso_LastLoginProviderId__c = UserInfo.getUserId();  }  if(u.Id != null )  {    Database.SaveResult userResult = Database.update(u, false);  }  return businessEmailVerification;}
  private boolean isExistingBusinessEmail(){  Boolean is = false;  if (existingBusinessEmail != null) {is = true;  }  return is;} private boolean isDefaultProvider(){  Boolean is = false;  if(System.currentPageReference().getParameters().containsKey('provider')) {    if(System.currentPageReference().getParameters().get('provider') == esso_Configuration.DEFAULT_PROVIDER)  {  is = true;  }}  return is;} private boolean isDefaultProviderUpdate(User u){  Boolean isUpdate = false;  if(isDefaultProvider())  {    if(u.esso_LastLoginProviderType__c != esso_Configuration.DEFAULT_PROVIDER || u.esso_LastLoginProviderId__c != UserInfo.getUserId())    {isUpdate = true;}  } return isUpdate;}private boolean isUpdateUserBranding(User u, Esso_Site_Branding__c b ){  Boolean isUpdate = false;  if(String.isBlank(u.esso_BrandId__c) || u.esso_BrandId__c.toLowerCase() != b.Referral_Id__c.toLowerCase() || u.esso_BrandName__c != b.Product_Name__c || u.esso_BrandSupportEmail__c != b.Customer_Support_Email__c)  {isUpdate = true;}  return isUpdate;}
  
  private Boolean isRequiredUserInfo(User u){  Boolean isUpdate = false;  if(  (string.isBlank(u.FirstName) || u.LastName=='{updatelast}' || string.isBlank(u.CountryCode) || u.esso_Privacy_Policy_Agreed__c==false) ||    (!isDefaultProvider() && ( (u.esso_QA_Business_Email__c != 'Yes' && u.esso_Business_Email__c == null) || u.esso_QA_Business_Email__c == null))  )  {isUpdate = true;}  return isUpdate;} public PageReference userUpdate(){  if(userValidate())  {  PageReference businessEmailVerificationLogout = updateUserInfo();  currentUser = essoUser.getUserById(UserInfo.getUserId());  return (businessEmailVerificationLogout == null) ? authValidate() : businessEmailVerificationLogout;  }  return null; } private Boolean userValidate(){  if( String.IsBlank(theUser.FirstName) ) {    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.Communities_Registratoin_Please_Provide + ' first name'));  }  if(theUser.LastName == '{updatelast}' ) {  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.Communities_Registratoin_Please_Provide + ' last name'));} if(String.IsBlank(theUser.CountryCode) )   { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.Communities_Registratoin_Please_Provide + ' country'));}
  if(theUser.esso_QA_Business_Email__c == 'No' && String.IsBlank(BusinessEmail) )   {    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + Label.Communities_Registratoin_Please_Provide + ' work email'));  }  return !ApexPages.hasMessages();} public PageReference authValidate(){  PageReference returnPage;  if(esso_User.isGuestUser()) {    return controller.goToLogin();  }  else  {    if(isRequiredUserInfo(currentUser)) {return null;}    updateUserInfo();     String referralurl = controller.siteBranding.referralurl;    referralurl = (String.isNotBlank(referralurl)? referralurl: ApexPages.currentPage().getParameters().get('starturl'));   if(String.isNotBlank(referralurl)) {referralurl = validateRedirectUrl(referralurl);  returnPage = new PageReference(referralurl);    }  }  if(returnPage != null)  {    redirectLocation = returnPage.getUrl();  }  return SSOApplicationSecurity.processReturnPageReference(returnPage);}private String validateRedirectUrl(String referralurl){   String frontdoorUrl = Site.getPathPrefix() + '/secur/frontdoor.jsp';  if(String.isNotBlank(referralurl) && referralurl.startsWith(frontdoorUrl)) {String queryString = referralurl.substringAfter('?');     List<String> params = queryString.split('&');  Map<String, String> paramsMap = new Map<String, String>();
  
      // loop through params to put into a map
      for(String param : params) {  if(param.contains('=')) {  String paramKey = param.substringBefore('=').tolowerCase();  if(param.indexOf('=') < (param.length() - 1)) {  String paramValue = param.substringAfter('=');          paramsMap.put(paramKey, paramValue);  }  }  }    if(paramsMap.containskey('returl') && String.isNotBlank(paramsMap.get('returl'))) {    referralurl = EncodingUtil.urlDecode(paramsMap.get('returl'), 'UTF-8');  
      }
    }
    return referralurl;
  }
  }