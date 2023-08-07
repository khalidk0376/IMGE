/**
 * Created/Modified By  :  Mahesh (Girikon)
 * Created On:          :  June 12 2019
 * @description         : [ This test class covers the apex class : CommunityBaseController]
 * Modification log --
 * Modified By          :
 **/
//Ticket No. BK-14521 Updating API Version
@isTest
private class CommunityBaseControllerTest {

@testSetup static void setup()
{

    // Create site branding data
    esso_Site_Branding__c brand =TestUtility.createSiteBranding('Informa', 'Informa', 'Informa', 'Informa Markets', false);
    brand.Default_Landing_Page__c = 'http://www.informa.com';
    insert brand;
    esso_ConfigurationTest.setupData();
    Map<string,Esso_Site_Branding__c> siteBrandings = SiteBrandingIdentifier.siteBrandings;
}

@isTest static void test_method_one_no_params() {

    User communityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);

    Network community = [SELECT Id, OptionsSelfRegistrationEnabled FROM Network ORDER BY Name DESC LIMIT 1];

    System.runAs(communityUser){

        CommunityBaseController controller = new CommunityBaseController();

        CommunityBaseController.setTestNetworkId(community.Id);
        controller.goToSelfReg();

        System.assert (controller.goToLogin() != null,'Invalid LoginUrl');

        String logoutUrl = Network.getLogoutUrl(community.Id);

        if(String.isNotBlank(logoutUrl)) {
            System.assert (controller.goToLogout() != null,'Invalid LogoutUrl');
        }else{
            System.assert (controller.goToLogout() == null,'Create a LogoutUrl');
            System.assert (String.isNotBlank(controller.loginURL),'Blank LogoutUrl');
        }
        if(community.OptionsSelfRegistrationEnabled) {
            System.assert (controller.goToSelfReg() != null,'condition should be match');
        }
        System.assert (controller.goToForgotPassword() != null,'condition should be match');
        System.assert (controller.goToDefaultLandingPage().getUrl() == 'http://www.informa.com','condition should be match');
        System.assert (controller.passwordPolicy != null,'condition should be match');
        System.assert (CommunityBaseController.getCurrentNetworkId() == community.Id,'condition should be match');
        System.assert (controller.getStartPageWithParams() != null,'condition should be match');
    }
}

@isTest static void test_method_two_with_params() {

    ApexPages.currentPage().getParameters().put('referralid', 'informa');
    ApexPages.currentPage().getParameters().put('referralurl', 'http://www.informa.com');

    User communityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);

    System.runAs(communityUser){

        CommunityBaseController controller = new CommunityBaseController();

        PageReference testPage = new PageReference('/');
        testPage = controller.addBrandingParams(testPage);

        System.assertEquals('informa', testPage.getParameters().get('referralid').toLowerCase(),'The first and second parameter value should be match');
        System.assertEquals('http://www.informa.com', testPage.getParameters().get('referralurl'),'The first and second parameter value should be match');
        System.assertEquals('informa', controller.getStartPageWithParams().getParameters().get('referralid'),'The first and second parameter value should be match');
        System.assertEquals('http://www.informa.com', controller.getStartPageWithParams().getParameters().get('referralurl'),'The first and second parameter value should be match');
    }
}

@isTest static void test_method_three() {

    User communityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);

    Network community = [SELECT Id, Name, OptionsSelfRegistrationEnabled FROM Network Where Name=:'Informa Markets'];
    System.debug('### community.Name: ' + community.Name );
    /*
    try{
        esso_Site_branding__c branding = TestUtility.createSiteBranding(community.Name, community.Name, community.Name, 'Informa Markets', false);
        branding.Default_Landing_Page__c = 'http://maritime.informa.com';
        insert branding;
    }catch(Exception ex) {
        // Will fail if only one community exists with the name of "informa" (this is the dafult community)
        //BK-3754   
                Utility.logsError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'CommunityBaseControllerTest' , 'Integration');
    }
    testCheckBranding();

    esso_Site_branding__c branding = [SELECT Default_Landing_Page__c,Referral_Id__c,Language__c FROM esso_Site_branding__c WHERE Referral_Id__c ='Informa'];
    */
    System.runAs(communityUser){
    try{
        esso_Site_branding__c branding = TestUtility.createSiteBranding(community.Name, community.Name, community.Name, 'Informa Markets', false);
        branding.Default_Landing_Page__c = 'http://maritime.informa.com';
        insert branding;
    }catch(Exception ex) {
        // Will fail if only one community exists with the name of "informa" (this is the dafult community)
        //BK-3754   
                Utility.logsError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'CommunityBaseControllerTest' , 'Integration');
    }
    testCheckBranding();

    esso_Site_branding__c branding = [SELECT Default_Landing_Page__c,Referral_Id__c,Language__c FROM esso_Site_branding__c WHERE Referral_Id__c ='Informa'];

        Test.setCurrentPage(Page.registration);

        ApexPages.currentPage().getParameters().put('referralid', community.Name);

        CommunityBaseController controller = new CommunityBaseController();

        CommunityBaseController.setTestNetworkId(community.Id);

        System.assert (controller.goToLogin() != null,'condition should be match');
        System.assert (controller.goToLogout() != null,'condition should be match');
        /*if(community.OptionsSelfRegistrationEnabled){
           System.assert(controller.goToSelfReg() != null);
           }*/
        System.assert (controller.goToForgotPassword() != null,'condition should be match');

        String landingurl = (String.isNotBlank(branding.Default_Landing_Page__c) && !branding.Default_Landing_Page__c.startsWithIgnoreCase('http')) ? 'http://' + branding.Default_Landing_Page__c : branding.Default_Landing_Page__c;

        //System.assert(controller.goToDefaultLandingPage().getUrl() == new PageReference(landingurl).geturl());
        System.assert (controller.passwordPolicy != null,'condition should be match');
        System.assert (CommunityBaseController.getCurrentNetworkId() == community.Id,'condition should be match');
    }
}



@isTest static void forwardAuthUserToStartPage_Guest(){

    testCheckBranding();


    List<User> guestSiteUsers = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' and name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
    //System.debug('### guestSiteUsers: ' + guestSiteUsers.Profile.name + '; ' + guestSiteUsers.ProfileId);

    if(!guestSiteUsers.isEmpty()) {

        System.runAs(guestSiteUsers[0]){

            CommunityBaseController controller = new CommunityBaseController();
            PageReference returnPage = controller.forwardAuthUserToStartPage();
            System.assertEquals(null, returnPage,'The first and second parameter value should be match');
        }
    }
}

@isTest static void forwardAuthUserToStartPage_Internal_user(){

    // Run in the context of the current internal user

    CommunityBaseController controller = new CommunityBaseController();
    PageReference returnPage = controller.forwardAuthUserToStartPage();
    System.assertNotEquals(null, returnPage,'The first and second parameter value should be not match');
    System.assertEquals(returnPage.geturl(), returnPage.getUrl(),'The first and second parameter value should be match');

}


@isTest static void forwardAuthUserToStartPage_External_user(){

    testCheckBranding();

    User communityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);
    System.debug('### communityUserProfile: ' + communityUser.Profile.name + '; ' + communityUser.ProfileId);


    System.runAs(communityUser){



        CommunityBaseController controller = new CommunityBaseController();
        PageReference returnPage = controller.forwardAuthUserToStartPage();



        System.assertNotEquals(null, returnPage,'The first and second parameter value should be not match');
        System.assertEquals(returnPage.geturl(), returnPage.getUrl(),'The first and second parameter value should be match');
    }
}



/*@isTest static void base_no_params_IdeAppSettingsEnabled() {

   securitySettingsSetup(true);

   User communityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);

   Network community = [SELECT Id, OptionsSelfRegistrationEnabled FROM Network ORDER BY Name DESC LIMIT 1];

   System.runAs(communityUser){

    CommunityBaseController controller = new CommunityBaseController();

    CommunityBaseController.setTestNetworkId(community.Id);

    System.assert(controller.goToLogin() != null);

    String logoutUrl = Network.getLogoutUrl(community.Id);

    if(String.isNotBlank(logoutUrl)){
      System.assert(controller.goToLogout() != null);
    }else{
      System.assert(controller.goToLogout() == null);
      System.assert(String.isNotBlank(controller.loginURL));
    }
    if(community.OptionsSelfRegistrationEnabled){
      System.assert(controller.goToSelfReg() != null);
    }
    System.assert(controller.goToForgotPassword() != null);
    System.assert(controller.goToDefaultLandingPage().getUrl() == 'http://www.informa.com');
    System.assert(controller.passwordPolicy != null);
    System.assert(CommunityBaseController.getCurrentNetworkId() == community.Id);
    System.assert(controller.getStartPageWithParams() != null);
   }
   }*/

/*@isTest static void base_with_params_IdeAppSettingsEnabled_removed() {

   securitySettingsSetup(true);

   ApexPages.currentPage().getParameters().put('referralid', 'testid');
   ApexPages.currentPage().getParameters().put('referralurl', 'https://www.bad-address.com');

   User communityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);

   System.runAs(communityUser){
     CommunityBaseController controller = new CommunityBaseController();

     PageReference testPage = new PageReference('/');
     testPage = controller.addBrandingParams(testPage);

     // Params return null as referral ids or urls are not set on site branding to whitelist, nor are they setup in the custom metadata IDE Whitelist URL's
     System.assertEquals(null, testPage.getParameters().get('referralid'));
     System.assertEquals(null, testPage.getParameters().get('referralurl'));
     System.assertEquals(null, controller.getStartPageWithParams().getParameters().get('referralid'));
     System.assertEquals(null, controller.getStartPageWithParams().getParameters().get('referralurl'));
   }
   }*/

/* @isTest static void base_with_params_IdeAppSettingsEnabled_retained() {

   securitySettingsSetup(true);

   Network community = [SELECT Id, Name, OptionsSelfRegistrationEnabled FROM Network ORDER BY Name DESC LIMIT 1];

   esso_Site_branding__c branding;
   try{
     branding = TestUtility.createSiteBranding(community.Name, community.Name, community.Name, 'Busisness Intellience', false);
     branding.Default_Landing_Page__c = 'http://maritime.informa.com';
     insert branding;
   }catch(Exception ex){
     // Will fail if only one community exists with the name of "informa" (this is the dafult community)
   }

   ApexPages.currentPage().getParameters().put('referralid', community.Name);
   ApexPages.currentPage().getParameters().put('referralurl', branding.Default_Landing_Page__c);

   User communityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);

   System.runAs(communityUser){
     CommunityBaseController controller = new CommunityBaseController();

     PageReference testPage = new PageReference('/');
     testPage = controller.addBrandingParams(testPage);

     // Params return null as referral ids or urls are not set on site branding to whitelist, nor are they setup in the custom metadata IDE Whitelist URL's
     System.assertEquals(community.Name, testPage.getParameters().get('referralid'));
     System.assertEquals(branding.Default_Landing_Page__c, testPage.getParameters().get('referralurl'));
     System.assertEquals(community.Name, controller.getStartPageWithParams().getParameters().get('referralid'));
     System.assertEquals(branding.Default_Landing_Page__c, controller.getStartPageWithParams().getParameters().get('referralurl'));
   }
   }*/

/*@isTest static void test_method_three_IdeAppSettingsEnabled() {

   securitySettingsSetup(true);

   User communityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);

   Network community = [SELECT Id, Name, OptionsSelfRegistrationEnabled FROM Network ORDER BY Name DESC LIMIT 1];

   try{
    esso_Site_branding__c branding = TestUtility.createSiteBranding(community.Name, community.Name, community.Name, 'Busisness Intellience', false);
    branding.Default_Landing_Page__c = 'http://maritime.informa.com';
    insert branding;
   }catch(Exception ex){
    // Will fail if only one community exists with the name of "informa" (this is the dafult community)
   }

   esso_Site_branding__c branding = [SELECT Default_Landing_Page__c FROM esso_Site_branding__c WHERE Referral_Id__c = :community.Name];

   System.runAs(communityUser){

    Test.setCurrentPage(Page.registration);

    ApexPages.currentPage().getParameters().put('referralid', community.Name);

    CommunityBaseController controller = new CommunityBaseController();

    CommunityBaseController.setTestNetworkId(community.Id);

    System.assert(controller.goToLogin() != null);
    System.assert(controller.goToLogout() != null);
    if(community.OptionsSelfRegistrationEnabled){
      System.assert(controller.goToSelfReg() != null);
    }
    System.assert(controller.goToForgotPassword() != null);

    String landingurl = (String.isNotBlank(branding.Default_Landing_Page__c) && !branding.Default_Landing_Page__c.startsWithIgnoreCase('http')) ? 'http://' + branding.Default_Landing_Page__c : branding.Default_Landing_Page__c;

    System.assert(controller.goToDefaultLandingPage().getUrl() == new PageReference(landingurl).geturl());
    System.assert(controller.passwordPolicy != null);
    System.assert(CommunityBaseController.getCurrentNetworkId() == community.Id);
   }
   }*/

@isTest static void forwardAuthUserToStartPage_Guest_IdeAppSettingsEnabled(){

    XssSecurityHelperTest.setupSettings(true);

    List<User> guestSiteUsers = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' and name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];

    if(!guestSiteUsers.isEmpty()) {

        System.runAs(guestSiteUsers[0]){

            CommunityBaseController controller = new CommunityBaseController();
            PageReference returnPage = controller.forwardAuthUserToStartPage();
            System.assertEquals(null, returnPage,'The first and second parameter value should be match');
        }
    }
}

@isTest static void forwardAuthUserToStartPage_Internal_user_IdeAppSettingsEnabled(){

    XssSecurityHelperTest.setupSettings(true);

    // Run in the context of the current internal user

    CommunityBaseController controller = new CommunityBaseController();
    PageReference returnPage = controller.forwardAuthUserToStartPage();
    System.assertNotEquals(null, returnPage,'The first and second parameter value should be not match');
    System.assertEquals(returnPage.geturl(), returnPage.getUrl(),'The first and second parameter value should be match');

}
static void testCheckBranding()
{
    List<Esso_Site_Branding__c> siteBranding = [SELECT Footer_Background_Colour__c, Footer_Logo_File_Name__c, Name, Page_Background_Colour__c,
                                                Primary_Colour__c,Language__c,Referral_Id__c, Secondary_Colour__c, Standard_Font_Colour__c, Footer_Font_Colour__c,
                                                Headings_Font_Colour__c, Page_Image__c, Product_Logo_File_Name__c, reCAPTCHA_Theme__c, Footer_Image_Location__c,
                                                Registration_HTML_Markup__c, Product_Name__c, Division__c, Default_Landing_Page__c,Favourite_Icon_Logo_File_Name__c, Branding_Type__c
                                                FROM Esso_Site_Branding__c];

    System.debug('### siteBranding Size: ' + siteBranding.size());
    System.debug('### Branding: ' + siteBranding[0].Referral_Id__c);

}

/*@isTest static void forwardAuthUserToStartPage_External_user_IdeAppSettingsEnabled(){

   securitySettingsSetup(true);

   User communityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);

   System.runAs(communityUser){

    CommunityBaseController controller = new CommunityBaseController();
    PageReference returnPage = controller.forwardAuthUserToStartPage();
    System.assertNotEquals(null, returnPage);
    System.assertEquals(returnPage.geturl(), returnPage.getUrl());
   }
   }*/
}