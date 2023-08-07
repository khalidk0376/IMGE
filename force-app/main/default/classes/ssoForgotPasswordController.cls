/**
 * Application            :  Informa Markets Identity (IM IdP)
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-20)]
 * Created On   :   June 12 2019
 * @description :   [An apex page controller that exposes the site forgot password functionality]
 * Test Class   :   ssoForgotPasswordControllerTest
 * Modification Log-----
 * Modified by  :   Shay.Spoonmore@informa.com (20200707)
 * Ticket No    : BK-14521 Updating API Version
 **/
public without sharing class ssoForgotPasswordController {
public String username {get; set;}

public String forgotNotification {
  get {
    if(String.isBlank(forgotNotification)) {
      forgotNotification = CommunityUtility.getLabelMessage(controller.siteBranding, label.Communities_Forgot_Password_Notification);
    }
    return forgotNotification;
  }
  private set;
}

public Boolean isFederatedDomain {get; private set;}

/* reCAPTCHA object */
public ReCAPTCHAService reCaptcha {get; private set;}

public CommunityBaseController controller {get; set;}

// CONSTRUCTOR
public ssoForgotPasswordController(CommunityBaseController controller) {
  this.controller = controller;
  reCaptcha = new ReCAPTCHAService();
  username = ApexPages.currentPage().getParameters().get('u');
    system.debug('username ::::'+username);
  //isFederatedDomain = false;
}

public PageReference sendForgotPassword(){

  string responseRecaptcha = ApexPages.currentPage().getParameters().get('g-recaptcha-response');
  System.debug('####!DEBUG! validate() reCAPTCHA response: ' + responseRecaptcha);

  if (!string.isBlank(responseRecaptcha) || reCaptcha.isDisabled==true )
  {
    reCaptcha.recaptchaVerify();

    if (!reCaptcha.reCAPTCHA_Verified)
    {
      //PUT error messages here!
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;'+ Label.esso_reCaptcha_Problem));
      System.debug('####!DEBUG!  RegistrationController.validate(): reCaptcha failed Response= ' + responseRecaptcha);
      return null;
    }

  }
  else
  {
    //PUT error messages here!
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;'+ Label.esso_reCaptcha_Problem));
    System.debug('####!DEBUG! reCAPTCHA - Empty Response: ' + responseRecaptcha);
    return null;
  }

  Boolean isValidUsername = Site.isValidUsername(username);
  Boolean resetSuccessful = false;

  // Check if username is valid and present error if not
  if(isValidUsername) {

    // Set the brand & return URL cookie cookie if it is not already set as we are not able to add parameters to the forgot passwword email links
    // The cookie solution will need to control the change password branding
    String referralId = SiteBrandingIdentifier.referralId;
    controller.siteBranding.setCookies(null, false);

    // Now check if the username provided is setup for federated
    //FederatedAuthProvider fedProvider = FederatedAuthProviderUtility.checkForProvider(username);

    /*if(fedProvider != null){
         // is federated so show message instead of requesting reset
         isFederatedDomain = true;
         return null;
       }*/
    //else{
    // Rest password



    //update user branding for forgot password request for email template
   	system.debug('new user name ' + username);
    List<User> users = new List<User>();
    //String profileId = [Select Id From Profile where name=: esso_Configuration.setting.Identity_Profile_Name__c Limit 1].Id;
    users = [SELECT Id, esso_BrandId__c,esso_BrandName__c,esso_BrandSupportEmail__c,LocaleSidKey,LanguageLocaleKey,esso_LocalLanguage__c FROM User WHERE ProfileId=: esso_User.ProfileId and Username = :username];
    System.debug('#### !DEBUG! users.size():' + users.size());
    if (users.size() > 0) {
      user u=users[0];

      Esso_Site_Branding__c b = SiteBrandingIdentifier.siteBrandings.get(esso_Configuration.setting.Branding_Default__c);  if(SiteBrandingIdentifier.isValidReferralId){  b = SiteBrandingIdentifier.siteBrandings.get(SiteBrandingIdentifier.referralId);  }      b.Product_Name__c = (b.Product_Name__c == null ? b.Name : b.Product_Name__c);
      if (String.isBlank(u.esso_BrandId__c) || u.esso_BrandId__c.toLowerCase() != b.Referral_Id__c.toLowerCase() || u.esso_BrandName__c != b.Product_Name__c || u.esso_BrandSupportEmail__c != b.Customer_Support_Email__c)
      {
        u.LocaleSidKey = b.Language__c;        u.LanguageLocaleKey = b.Language__c;
        u.esso_LocalLanguage__c= b.Language__c;        u.esso_BrandId__c=b.Referral_Id__c.toLowerCase();
        u.esso_BrandName__c=b.Product_Name__c;        u.esso_BrandSupportEmail__c= b.Customer_Support_Email__c;
        System.debug('#### !DEBUG! Forgot Password Update User Branding' + u);
        Database.SaveResult userResult = Database.update(u, false);
      }

      esso_User.resetPasswordSetCookie(username);      return   controller.goToLogin();

    }
    // Check if reset was successful
    // resetSuccessful = Site.forgotPassword(username);
    // if(resetSuccessful || Test.isRunningTest())
    // {
    //   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, '&nbsp;&nbsp;' + label.Communities_Forgot_Password_Submit_Confirm));
    // }

    //Redirect to signin to handle reset email process when username exists
    

  }

  // If username or reset request is false provde an error
  // if(!isValidUsername || !resetSuccessful) 
  // {
  //   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '&nbsp;&nbsp;' + label.Communities_Forgot_Password_Reset_Error));
  // }

  //redirect user to register
  esso_User.resetPasswordSelfRegSetCookie(username);
  return   controller.goToSelfReg();
}

public PageReference cancelFederatedMsg(){
  PageReference returnPage = Page.ForgotPassword;
  returnPage.getParameters().put('u', username);
  returnPage.setRedirect(true);
  return returnPage;
}
}