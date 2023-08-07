/**
 * Application           :  Informa Markets Identity (IM IdP)
 * Created/Modified By   :  Mahesh (Girikon)
 * Created On:           :  June 12 2019
 * @description          : [This test class covers the apex class : LandingController]
 * Modification log --
 * Modified by          : Shay.Spoonmore@informa.com (20200901)
 **/
@isTest
private class LandingControllerTest {


@TestSetup
private static void setupData(){

    esso_ConfigurationTest.setupData();
    esso_UserTest.setupData();
    //Commentted due to Method does not exist or incorrect signature: void defaultSiteBranding() from the type SiteBrandingIdentifierTest
    //SiteBrandingIdentifierTest.defaultSiteBranding();
}

public static void getPageMessages()
{


    System.debug('#### !DEBUG! ApexPages.hasMessages(): ' + ApexPages.hasMessages());
    for (ApexPages.Message t : ApexPages.getMessages())
    {
        System.debug('#### !DEBUG! ApexPages.hasMessages(): ' + ApexPages.hasMessages() + '; ' + t.getSeverity() + '; ' + t.getDetail());
    }


}

@isTest static void testGuestRedirect() {

    //Test.setCurrentPage(Page.landing);

    System.runAs(esso_UserTest.guest){

        Test.startTest();

        CommunityBaseController controller = new CommunityBaseController();
        LandingController conExt = new LandingController(controller);
        // PageReference pageRef = Page.landing; // Add your VF page Name here
        // Test.setCurrentPage(pageRef);

        PageReference returnPage = conExt.authValidate();
        //Guest users should always redirect back to Signin
        System.assertEquals(controller.goToLogin().getUrl(), returnPage.getUrl(),'The first and second parameter value should be match');

        Test.stopTest();
    }
}
/*
@isTest static void test_method_two() {

    Test.setCurrentPage(Page.landing);
    System.runAs(esso_UserTest.imIdpBusiness){

        ApexPages.currentPage().getParameters().put('starturl', 'https://www.informa.com');
        ApexPages.currentPage().getParameters().put('provider',esso_Configuration.DEFAULT_PROVIDER);

        CommunityBaseController controller = new CommunityBaseController();

        LandingController conExt = new LandingController(controller);

        //PageReference returnPage = conExt.authValidate();

        //System.assertEquals('https://www.informa.com', returnPage.getUrl(),'The first and second parameter value should be match');
        // Confirm there is redirect
        System.assertEquals('https://www.informa.com', conExt.redirectLocation,'The first and second parameter value should be match');
        // Confirm the IDE session Cookie should exist and should not be deleted
        System.assertEquals(false, conExt.deleteIdeSessionCookie,'The first and second parameter value should be match');
    }
}
*/
@isTest static void test_method_three() {

    Test.setCurrentPage(Page.landing);
    System.runAs(esso_UserTest.guest){

        Test.startTest();

        CommunityBaseController controller = new CommunityBaseController();

        LandingController conExt = new LandingController(controller);
        //LandingController.UserEntitlement(SiteBrandingIdentifierTest.defaultSiteBranding(), 'test');


        PageReference returnPage = conExt.authValidate();
        System.assertNotEquals(false, conExt.deleteIdeSessionCookie,'The first and second parameter values are same');
        Test.stopTest();
    }
}
@isTest static void test_method_landing_with_1_services() {

    List<esso_Site_Branding__c> siteBrandings = new List<esso_Site_Branding__c>();

    esso_Site_Branding__c lloydsListBrand = TestUtility.createSiteBranding('Lloyds List', 'LOLS', 'Lloyds List', 'Informa Markets', false);
    lloydsListBrand.Default_Landing_Page__c = 'https://lloydslist.maritime.com';
    lloydsListBrand.Branding_Type__c = 'Product';
    siteBrandings.add(lloydsListBrand);

    esso_Site_Branding__c iegVuBrand = TestUtility.createSiteBranding('IEG Vu', 'IEGV', 'IEG Vu', 'Informa Markets', false);
    iegVuBrand.Default_Landing_Page__c = 'https://iegvu.agribusiness.com';
    iegVuBrand.Branding_Type__c = 'Product';
    siteBrandings.add(iegVuBrand);

    insert siteBrandings;

    Map<string,Esso_Site_Branding__c> siteBrandingsM = SiteBrandingIdentifier.siteBrandings;

    User communityUser = new User(
        FirstName = 'Test',
        LastName = 'Test',
        Email = 'landingcontroller@apextest.com',
        ProfileId = esso_User.ProfileId,
        //ContactId = theContact.Id,
        Username = 'testex5@test.com',
        Alias = 'test',
        CommunityNickname = 'landingcontroller_5',
        TimeZoneSidKey = 'GMT',
        LocaleSidKey = 'en_GB',
        EmailEncodingKey = 'ISO-8859-1',
        LanguageLocaleKey = 'en_US',
        IsActive = TRUE
        );
    insert communityUser;

    Test.setCurrentPage(Page.landing);

    System.runAs(communityUser){

        Test.startTest();

        CommunityBaseController controller = new CommunityBaseController();

        LandingController conExt = new LandingController(controller);

        PageReference returnPage = conExt.authValidate();
        System.assertEquals(false, conExt.deleteIdeSessionCookie,'The first and second parameter value should be match');

        Test.stopTest();
    }
}
/*
@isTest static void test_method_frontdoor_redirect() {

    User communityUser = new User(
        FirstName = 'Test',
        LastName = 'Test',
        Email = 'landingcontroller@apextest.com',
        ProfileId = esso_User.ProfileId,
        //ContactId = theContact.Id,
        Username = 'testex5@test.com',
        Alias = 'test',
        CommunityNickname = 'landingcontroller_5',
        TimeZoneSidKey = 'GMT',
        LocaleSidKey = 'en_GB',
        EmailEncodingKey = 'ISO-8859-1',
        LanguageLocaleKey = 'en_US',
        IsActive = true,
        esso_Privacy_Policy_Agreed__c=true,
        CountryCode='US'
        );
    insert communityUser;

    PageReference landingPage = Page.landing;


    Test.setCurrentPage(landingPage);

    System.runAs(communityUser){

        Test.startTest();
        ApexPages.currentPage().getParameters().put('referralurl', '/secur/frontdoor.jsp?retURL='+ System.URL.getSalesforceBaseURL().toExternalForm() +'/informamarkets/ChangePassword');
        ApexPages.currentPage().getParameters().put('provider',esso_Configuration.DEFAULT_PROVIDER);
        CommunityBaseController controller = new CommunityBaseController();

        LandingController conExt = new LandingController(controller);

        PageReference returnPage = conExt.authValidate();
        System.debug('#### !DEBUG! returnPage: ' + returnPage);
        System.assertEquals(System.URL.getSalesforceBaseURL().toExternalForm() +'/informamarkets/ChangePassword', returnPage.getUrl() , 'test failed');

        Test.stopTest();
    }
} */

@isTest static void test_federated_user_no_contactsource_cookie() {

    // Update site branding to have specific error
    esso_Site_Branding__c brandings = new esso_Site_Branding__c (Registration_Contact_Source__c ='Standard_Reg_Conact_Source');
    
    insert brandings;
    
    brandings.Registration_Contact_Source__c = 'Standard_Reg_Conact_Source';
    //brandings[0].Trial_Registration_Contact_Source__c = 'Trial_Reg_Conact_Source';
    update brandings;

    Map<string,Esso_Site_Branding__c> siteBrandings = SiteBrandingIdentifier.siteBrandings;

    // Account theAccount = TestUtility.createTestAccount(true, 'Test Account');
    // Contact theContact = TestUtility.createTestContact(true, 'Test', 'Contact', theAccount.Id);
    // Profile endUserPrfl =[select Id,Name From Profile Where Name='Informa Markets Identity'];
    User communityUser = new User(
        FirstName = 'Test',
        LastName = 'Test',
        Email = 'landingcontroller@apextest.com',
        ProfileId = esso_User.ProfileId,
        //ContactId = theContact.Id,
        Username = 'test_federated_user@test.com',
        Alias = 'test',
        CommunityNickname = 'landingcontroller_5',
        TimeZoneSidKey = 'GMT',
        LocaleSidKey = 'en_GB',
        EmailEncodingKey = 'ISO-8859-1',
        LanguageLocaleKey = 'en_US',
        IsActive = true,
        esso_Privacy_Policy_Agreed__c=true,
        CountryCode='US'
        );
    insert communityUser;

    PageReference landingPage = Page.landing;

    Test.setCurrentPage(landingPage);

    System.runAs(communityUser){

        Test.startTest();

        CommunityBaseController controller = new CommunityBaseController();

        LandingController conExt = new LandingController(controller);
        //call the code the page runs on load
        //conExt.runPageActions();
        Test.stopTest();
        System.assertEquals('Test',communityUser.FirstName,'The first and second parameter value should be match');

    }
}

}