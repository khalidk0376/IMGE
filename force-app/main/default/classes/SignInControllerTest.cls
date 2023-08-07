/**
 * Application            :   Informa Markets Identity (IM IdP)
 * Created/Modified By    :  Mahesh (Girikon)
 * Created On:            :  June 12 2019
 * @description           : [This test class covers the apex class : SignInController]
 * Modification log --
 * Modified by            :   Shay.Spoonmore@informa.com (20200828)
**/
@isTest
private without sharing class SignInControllerTest {
   
  @TestSetup
  private static void setupData(){
 
    
    esso_ConfigurationTest.setupData();
    esso_UserTest.setupData();
    SiteBrandingIdentifierTest.defaultSiteBranding();
    
    
  }
 
  @isTest static void testNoUser() {
     
    
 
    Test.setCurrentPage(Page.signin);
     
    System.runAs(esso_UserTest.guest){
 
      Test.startTest();
 
      CommunityBaseController controller = new CommunityBaseController();
 
      SignInController signInCon = new SignInController(controller);
 
      if(String.isNotBlank(Label.Communities_Login_Notification) && Label.Communities_Login_Notification.equalsIgnoreCase('null')){
        System.assert(String.isBlank(signInCon.loginNotification),'condition should be match');
      }else if(String.isNotBlank(Label.Communities_Login_Notification) && !Label.Communities_Login_Notification.equalsIgnoreCase('null')){
        System.assert(String.isNotBlank(signInCon.loginNotification),'condition should be match');
      }
 
      // No username found
      System.assertEquals(null, signInCon.username,'The first and second parameter value should be match');
 
      signInCon.login();
 
      // Assert no apex page messages were generated
      System.assertEquals(false, ApexPages.hasMessages(),'The first and second parameter value should be match');
       
      Test.stopTest();
    }
  }
 
  @isTest static void testForgotPasswordUrl() {
 
     
    CommunityBaseController controller = new CommunityBaseController();
 
    SignInController signInCon = new SignInController(controller);
 
    System.assertEquals(true, signInCon.forgotPassword().getUrl().startsWith(Page.ssoForgotPassword.getUrl()),'Forgot password should contain ' + Page.ssoForgotPassword.getUrl());
  }
 
  @isTest static void testSetUserCookie() {
 
    Cookie usernameCookie = new Cookie('rusr', esso_UserTest.imIdpBusiness.Username, null, SignInController.usernameCookieMaxAge, true);
 
    PageReference signinPage = Page.signin;
    signinPage.setCookies(new List<Cookie>{usernameCookie});
 
    Test.setCurrentPage(signinPage);
     
    System.runAs(esso_UserTest.guest){
 
      Test.startTest();
 
      CommunityBaseController controller = new CommunityBaseController();
 
      SignInController signInCon = new SignInController(controller);
 
      // Assert username is extracted from cookie and assigned to username on instantiation
      System.assertEquals(esso_UserTest.imIdpBusiness.Username, signInCon.username,'Page username should be the same as the cookie ' + esso_UserTest.imIdpBusiness.Username);
 
      signInCon.password = 'password123';
 
      // set test variable to mimic successful login as unit test return null for site.login() method
      signInCon.testSuccessfulLogin = true;
 
      signInCon.login();
 
      // Assert no apex page messages were generated
      System.assertEquals(false, ApexPages.hasMessages(),'The first and second parameter value should be match');
 
      Cookie rememberMeCookie = ApexPages.currentPage().getCookies().get('rusr');
 
      System.assertEquals(usernameCookie.getValue(), rememberMeCookie.getValue(),'The first and second parameter value should be match');
      System.assertEquals(usernameCookie.getMaxAge(), rememberMeCookie.getMaxAge(),'The first and second parameter value should be match');
       
      Test.stopTest();
    }
  }
 
  @isTest static void testNoUserCookie() {
 
   
 
    Cookie usernameCookie = new Cookie('rusr', 'test@test.com', null, SignInController.usernameCookieMaxAge, true);
 
    PageReference signinPage = Page.signin;
    signinPage.setCookies(new List<Cookie>{usernameCookie});
 
    Test.setCurrentPage(signinPage);
     
    System.runAs(esso_UserTest.guest){
 
      Test.startTest();
 
      CommunityBaseController controller = new CommunityBaseController();
 
      SignInController signInCon = new SignInController(controller);
 
      // Assert username is extracted from cookie and assigned to username on instantiation
      System.assertEquals('test@test.com', signInCon.username,'The first and second parameter value should be match');
 
      signInCon.password = 'password123';
 
      // set test variable to mimic successful login as unit test return null for site.login() method
      signInCon.testSuccessfulLogin = true;
 
      signInCon.rememberme = false; // Set to false to clear cookie
 
      signInCon.login();
 
      // Assert no apex page messages were generated
      System.assertEquals(false, ApexPages.hasMessages(),'The first and second parameter value should be match');
 
      Cookie rememberMeCookie = signInCon.getRememberMeCookie();
 
      System.assertEquals(usernameCookie.getValue(), rememberMeCookie.getValue(),'The first and second parameter value should be match');
      System.assertEquals(0, rememberMeCookie.getMaxAge(),'The first and second parameter value should be match');
       
      Test.stopTest();
    }
  }
 
  @isTest static void test_method_signin_redirect() {
 
    PageReference signinPage = Page.signin;
    signinPage.getParameters().put('startURL', 'https://www.informa.com');
 
    Test.setCurrentPage(signinPage);
     
    System.runAs(esso_UserTest.guest){
 
      Test.startTest();
 
      CommunityBaseController controller = new CommunityBaseController();
 
      SignInController signInCon = new SignInController(controller);
      signInCon.username = 'test@test.com';
      signInCon.password = 'password123';
 
      // set test variable to mimic successful login as unit test return null for site.login() method
      signInCon.testSuccessfulLogin = true;
      signInCon.rememberme = false; // Set to false to clear cookie
      signInCon.login();
 
      // Assert no apex page messages were generated
      System.assertEquals(false, ApexPages.hasMessages(),'The first and second parameter value should be match');
 
      //System.assertEquals(CommunityBaseController.getStartPage().getUrl() + '?referralurl=https://www.informa.com&provider=Informa Markets Identity', signInCon.postLoginUrl,'The first and second parameter value should be match');
 
      // Assert referral url cookie exists and is the same as the start url param
      System.assert(ApexPages.currentPage().getCookies().get('rurl') != null,'The first and second parameter value should be match');
     // System.assertEquals('https://www.informa.com', ApexPages.currentPage().getCookies().get('rurl').getValue(),'The first and second parameter value should be match');
       
      Test.stopTest();
    }
  } 

  @isTest static void testEmployeeRedirect() {
 
    PageReference signinPage = Page.signin;
    // signinPage.getParameters().put('u', esso_UserTest.imIdp.Username);
    // signinPage.returningFederatedUser=false;
 
    Test.setCurrentPage(signinPage);
     
    System.runAs(esso_UserTest.guest){
 
      Test.startTest();
 
      CommunityBaseController controller = new CommunityBaseController();
      SignInController signInCon = new SignInController(controller);
      signInCon.returningFederatedUser=false;
      signInCon.username = esso_UserTest.imIdp.Username;
      PageReference l =signInCon.login();
 

      System.assertEquals(true, (l.getUrl().contains('/services/auth/sso/')),'Employee should be redirected to ' + l.getUrl());
       
      Test.stopTest();
    }
  }


  @isTest static void testBusinessEmailMessage() {
 
    PageReference signinPage = Page.signin;
    
    
 
    Test.setCurrentPage(signinPage);
     
    System.runAs(esso_UserTest.guest){
 
      Test.startTest();
 
      CommunityBaseController controller = new CommunityBaseController();
      esso_User.businessEmailSetCookie(esso_UserTest.imIdpBusiness.Username, esso_UserTest.imIdpBusiness.Id, esso_RegHandlerLinkedIn.PROVIDER);
      SignInController signInCon = new SignInController(controller);
      
 
      // Assert no apex page messages were generated
      System.assertEquals(true, ApexPages.hasMessages(),'Display Business Email Message');
      //System.assertEquals('https://www.informa.com', ApexPages.currentPage().getCookies().get('rurl').getValue(),'The first and second parameter value should be match');
       
      Test.stopTest();
    }
  } 

  @isTest static void testResetPasswordMessageFail() {
 
    PageReference signinPage = Page.signin;
    User u = new User(Id=esso_UserTest.imIdpBusiness.Id, Username=esso_UserTest.imIdpBusiness.Username +'.NoExist');
    update u;
    
 
    Test.setCurrentPage(signinPage);
     
    System.runAs(esso_UserTest.guest){
 
      Test.startTest();
 
      CommunityBaseController controller = new CommunityBaseController();
      esso_User.resetPasswordSetCookie(esso_UserTest.imIdpBusiness.Username);
      SignInController signInCon = new SignInController(controller);
      
 
      // Assert no apex page messages were generated
      System.assertEquals(true, ApexPages.hasMessages(),'Display forgot Message');
      //System.assertEquals('https://www.informa.com', ApexPages.currentPage().getCookies().get('rurl').getValue(),'The first and second parameter value should be match');
       
      Test.stopTest();
    }
  } 

  @isTest static void testResetPasswordMessageSuccess() {
 
    PageReference signinPage = Page.signin;
    User u = new User(Id=esso_UserTest.imIdpBusiness.Id, Username=esso_UserTest.imIdpBusiness.Username,Email=esso_UserTest.imIdpBusiness.Username);
    update u;
 
    Test.setCurrentPage(signinPage);
     
    System.runAs(esso_UserTest.guest){
 
      Test.startTest();
      esso_ConfigurationTest.isTest = true;
      CommunityBaseController controller = new CommunityBaseController();
      esso_User.resetPasswordSetCookie(u.Username);
      SignInController signInCon = new SignInController(controller);
      
      
 
      // Assert no apex page messages were generated
      System.assertEquals(true, ApexPages.hasMessages(),'Display forgot Message');
      //System.assertEquals('https://www.informa.com', ApexPages.currentPage().getCookies().get('rurl').getValue(),'The first and second parameter value should be match');
       
      Test.stopTest();
    }
  } 
 
  @isTest static void test_federated_cookie() {
 
    
 
    Cookie fedUsernameCookie = new Cookie('fedusr', 'test@test.com', null, 100, false);
 
    PageReference signinPage = Page.signin;
    signinPage.setCookies(new List<Cookie>{fedUsernameCookie});
 
    Test.setCurrentPage(signinPage);
     
    System.runAs(esso_UserTest.guest){
 
      Test.startTest();
 
      CommunityBaseController controller = new CommunityBaseController();
 
      SignInController signInCon = new SignInController(controller);
 
       // Assert username is extracted from cookie and assigned to username on instantiation
      // System.assertEquals('test@test.com', signInCon.username);
 
     //System.assertEquals(true, signInCon.returningFederatedUser);
  
 
      // Assert no apex page messages were generated
      System.assertEquals(false, ApexPages.hasMessages(),'The first and second parameter value should be match');
 
      Cookie fedCookie = signInCon.getFedAuthUserCookie();
 
      System.assertEquals(fedUsernameCookie.getValue(), fedCookie.getValue(),'The first and second parameter value should be match');
      System.assertEquals(fedUsernameCookie.getMaxAge(), fedCookie.getMaxAge(),'The first and second parameter value should be match');
       
      Test.stopTest();
    }
  }
 
  @isTest static void test_authValidate_positive_SAML(){
    
 
    List<SamlSsoConfig> providers = [SELECT DeveloperName FROM SamlSsoConfig LIMIT 1];
    List<Network> communityNetworks = [SELECT Id, Name FROM Network LIMIT 1];
     
    if(!providers.isEmpty() && !communityNetworks.isEmpty()){
 
      Account acc = TestUtility.createTestAccount(false, 'Federated Client');
     //acc.Federated_Auth_Provider__c = providers[0].DeveloperName;
      insert acc;
 
     /*Email_Domain__c emailDomain = new Email_Domain__c(
        Account__c = acc.Id,
        Name = 'sso.com',
        Federated_Enabled__c = true
      );
      insert emailDomain; */
 
 
      PageReference signinPage = Page.signin;
      signinPage.getParameters().put('initiatefedauthsso', 'true');
      signinPage.getParameters().put('returncommunity', communityNetworks[0].Name);
      signinPage.getParameters().put('u', 'test@sso.com');
 
      Test.setCurrentPage(signinPage);
       
      System.runAs(esso_UserTest.guest){
 
        Test.startTest();
 
        CommunityBaseController controller = new CommunityBaseController();
 
        SignInController signInCon = new SignInController(controller);
 
        // Assert username is extracted param cookie and assigned to username on instantiation
        System.assertEquals('test@sso.com', signInCon.username,'The first and second parameter value should be match');
 
        // Page load method run
        PageReference redirect = signInCon.authValidate();
 
        //assert not null and SSO redirect is returned
       //System.assertNotEquals(null, redirect);
         
        Test.stopTest();
      }
    }
  }
 
  /*@isTest static void test_authValidate_positive_OpenID(){
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' AND IsActive = true LIMIT 1];
 
    List<AuthProvider> providers = [SELECT DeveloperName FROM AuthProvider LIMIT 1];
    List<Network> communityNetworks = [SELECT Id, Name FROM Network LIMIT 1];
     
    if(!providers.isEmpty() && !communityNetworks.isEmpty()){
 
      Account acc = TestUtility.createTestAccount(false, 'Federated Client');
     //acc.Federated_Auth_Provider__c = providers[0].DeveloperName;
      insert acc;
 
      /*Email_Domain__c emailDomain = new Email_Domain__c(
        Account__c = acc.Id,
        Name = 'sso.com',
        Federated_Enabled__c = true
      );
      insert emailDomain; 
 
 
      PageReference signinPage = Page.signin;
      signinPage.getParameters().put('initiatefedauthsso', 'true');
      signinPage.getParameters().put('returncommunity', communityNetworks[0].Name);
      signinPage.getParameters().put('u', 'test@sso.com');
 
      Test.setCurrentPage(signinPage);
       
      System.runAs(guestSiteUser){
 
        Test.startTest();
 
        CommunityBaseController controller = new CommunityBaseController();
 
        SignInController signInCon = new SignInController(controller);
 
        // Assert username is extracted param cookie and assigned to username on instantiation
        System.assertEquals('test@sso.com', signInCon.username);
 
        // Page load method run
        PageReference redirect = signInCon.authValidate();
 
        // assert not null and SSO redirect is returned
       //System.assertNotEquals(null, redirect);
         
        Test.stopTest();
      }
    }
  } */
 
 /*@isTest static void test_authValidate_logged_in_user(){
 
    Account acc = TestUtility.createTestAccount(true, 'Federated Client');
    Contact testContact = TestUtility.createTestContact(FALSE, 'Test First', 'Test Last', acc.Id);
      Profile endUserPrfl =[Select Id,Name From Profile Where Name='End User'];
        testContact.Email = 'apex.unit.test@registration.com';
        insert testContact;
 
        User testCommunityUser  = new User(alias = 'communit', Email = testContact.Email,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', ProfileId = endUserPrfl.Id,
                                    timezonesidkey='America/Los_Angeles', username= testContact.Email, IsActive = TRUE, ContactId = testContact.id);
 
        insert testCommunityUser;
 
    PageReference signinPage = Page.signin;
 
    Test.setCurrentPage(signinPage);
     
    System.runAs(testCommunityUser){
 
      Test.startTest();
 
      CommunityBaseController controller = new CommunityBaseController();
 
      SignInController signInCon = new SignInController(controller);
 
      // Page load method run
      PageReference redirect = signInCon.authValidate();
 
      // assert not null and redirect is to the start page
      System.assertNotEquals(controller.forwardAuthUserToStartPage(), redirect);
       
      Test.stopTest();
    }
  }*/
 
  /*@isTest static void test_authValidate_auto_sso(){
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' AND IsActive = true LIMIT 1];
 
    List<SamlSsoConfig> providers = [SELECT DeveloperName FROM SamlSsoConfig LIMIT 1];
    List<Network> communityNetworks = [SELECT Id, Name FROM Network LIMIT 1];
     
    if(!providers.isEmpty() && !communityNetworks.isEmpty()){
 
      Account acc = TestUtility.createTestAccount(false, 'Federated Client');
     //acc.Federated_Auth_Provider__c = providers[0].DeveloperName;
     //acc.Federated_Auth_Client_SSO_ID__c = 'AUTOSSO';
      insert acc;
 
     /*Email_Domain__c emailDomain = new Email_Domain__c(
        Account__c = acc.Id,
        Name = 'sso.com',
        Federated_Enabled__c = true
      );
      insert emailDomain;
 
 
      PageReference signinPage = Page.signin;
      signinPage.getParameters().put('initiatefedauthsso', 'true');
      signinPage.getParameters().put('returncommunity', communityNetworks[0].Name);
 
      Cookie ssoCientIdCookie = new Cookie('idessoclientid', 'AUTOSSO', null, 3600, true);
      signinPage.setCookies(new List<Cookie>{ssoCientIdCookie});
 
      Test.setCurrentPage(signinPage);
       
      System.runAs(guestSiteUser){
 
        Test.startTest();
 
        CommunityBaseController controller = new CommunityBaseController();
 
        SignInController signInCon = new SignInController(controller);
 
        // Page load method run
        PageReference redirect = signInCon.authValidate();
 
        //assert not null and SSO redirect is returned
       //System.assertNotEquals(null, redirect);
         
        Test.stopTest();
      }
    }
  }*/
 
 /*@isTest static void test_method_signin_redirect_IdeAppSecurityEnabeld() {
 
    securitySettingsSetup(true);
 
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' AND IsActive = true LIMIT 1];
 
    System.debug('*** -- guestSiteUser: ' + guestSiteUser);
 
    String returnURL = [SELECT Default_Landing_Page__c FROM esso_Site_Branding__c LIMIT 1].Default_Landing_Page__c;
 
    PageReference signinPage = Page.signin;
    signinPage.getParameters().put('startURL', returnURL);
 
    Test.setCurrentPage(signinPage);
     
    System.runAs(guestSiteUser){
 
      Test.startTest();
 
      CommunityBaseController controller = new CommunityBaseController();
 
      SignInController signInCon = new SignInController(controller);
      signInCon.username = 'test@test.com';
      signInCon.password = 'password123';
 
      // set test variable to mimic successful login as unit test return null for site.login() method
      signInCon.testSuccessfulLogin = true;
      signInCon.rememberme = false; // Set to false to clear cookie
      signInCon.login();
 
      // Assert no apex page messages were generated
      System.assertEquals(false, ApexPages.hasMessages());
 
      System.assertEquals(CommunityBaseController.getStartPage().getUrl() + '?referralurl=' + returnURL, signInCon.postLoginUrl);
 
      // Assert referral url cookie exists but has no value as it was not whitelisted and has been removed
      System.assertEquals(returnURL, ApexPages.currentPage().getCookies().get('rurl').getValue());
       
      Test.stopTest();
    }
  }*/
 
 /*@isTest static void test_method_signin_redirect_IdeAppSecurityEnabeld_Whitelisted() {
 
    securitySettingsSetup(true);
 
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' AND IsActive = true LIMIT 1];
 
    System.debug('*** -- guestSiteUser: ' + guestSiteUser);
 
    PageReference signinPage = Page.signin;
    signinPage.getParameters().put('startURL', 'http://www.bad-address.com');
 
    Test.setCurrentPage(signinPage);
     
    System.runAs(guestSiteUser){
 
      Test.startTest();
 
      CommunityBaseController controller = new CommunityBaseController();
 
      SignInController signInCon = new SignInController(controller);
      signInCon.username = 'test@test.com';
      signInCon.password = 'password123';
 
      // set test variable to mimic successful login as unit test return null for site.login() method
      signInCon.testSuccessfulLogin = true;
      signInCon.rememberme = false; // Set to false to clear cookie
      signInCon.login();
 
      // Assert no apex page messages were generated
      System.assertEquals(false, ApexPages.hasMessages());
 
      System.assertEquals(CommunityBaseController.getStartPage().getUrl(), signInCon.postLoginUrl);
 
      // Assert referral url cookie exists but has no value as it was not whitelisted and has been removed
      System.assertEquals(null, ApexPages.currentPage().getCookies().get('rurl').getValue());
       
      Test.stopTest();
    }
  }*/
 
  
}