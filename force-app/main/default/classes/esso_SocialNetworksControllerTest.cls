/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Shay.Spoonmore@informa.com (20200828)
 * Created On   :   20200710
 * @description :   [Display Social Network option to login]
 * Test Class   :   esso_SocialNetworksControllerTest
 * Modification Log-----
 * Modified by  :   Shay.Spoonmore@informa.com (20200828)
 **/
@isTest
public with sharing class esso_SocialNetworksControllerTest {
    
    @testSetup static void setup()
    {
        esso_ConfigurationTest.setupData();
        esso_UserTest.setupData();
        SiteBrandingIdentifierTest.defaultSiteBranding();
    }

    static testMethod void testPullSocial()
    {
      
    
    PageReference signinPage = Page.signin;
      
      
      signinPage.getParameters().put('u', 'test@sso.com');
 
      Test.setCurrentPage(signinPage);
       
      System.runAs(esso_UserTest.guest){
 
        Test.startTest();
 
        CommunityBaseController controller = new CommunityBaseController();
        esso_SocialNetworksController snc = new esso_SocialNetworksController();
        snc.controller = controller;
        SignInController signInCon = new SignInController(controller);
 
        // Find social networks
        System.assertEquals(true, (snc.socialNetworks.size()>0),'Find Social Networks');
 
        
         
        Test.stopTest();
      }

    }

}