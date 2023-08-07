/**
 * Created/Modified By  : Mahesh (Girikon)
 * Created On:          : June 12 2019
 * @description         : [This test class covers the apex class : IdentitySessionCookieController]
 * Modification log --
 * Modified By          :
**/
@isTest
private class IdentitySessionCookieControllerTest {
   
  @isTest static void test_method_one() {
 
    User communityUser = PortalRunAsTests.getPortalUser(PortalRunAsTests.PortalType.CspLitePortal, null, true);
 
    Network community = [SELECT Id, OptionsSelfRegistrationEnabled FROM Network ORDER BY Name DESC LIMIT 1];
 
    System.runAs(communityUser){
       
      Test.startTest();
 
      IdentitySessionCookieController controller = new IdentitySessionCookieController();
 
      // Assert is null as would be set by component
      System.assertEquals(null, controller.deleteCookie,'The first and second parameter value should be match');
      System.assertEquals(IdentitySessionCookieController.COOKIE_NAME, controller.cookie.name,'The first and second parameter value should be match');
 
      Datetime sessionDatetime = Datetime.valueOfGMT(EncodingUtil.urlDecode(controller.cookie.value, 'UTF-8').replace('T', ' ').replace('Z', ' '));
 
      System.assert(Datetime.now() < sessionDatetime,'condition should be match');
       
      Test.stopTest();
    }
  }
   
  @isTest static void test_method_two() {
 
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' AND IsActive = true LIMIT 1];
 
    System.debug('*** -- guestSiteUser: ' + guestSiteUser);
 
    System.runAs(guestSiteUser){
 
      Test.startTest();
 
      IdentitySessionCookieController controller = new IdentitySessionCookieController();
 
      System.assertEquals(true, controller.deleteCookie,'The first and second parameter value should be match');
      System.assertEquals(IdentitySessionCookieController.COOKIE_NAME, controller.cookie.name,'The first and second parameter value should be match');
 
      Datetime sessionDatetime = Datetime.valueOfGMT(EncodingUtil.urlDecode(controller.cookie.value, 'UTF-8').replace('T', ' ').replace('Z', ' '));
 
      System.assert(Datetime.now() >= sessionDatetime,'condition should be match');
 
      Test.stopTest();
    }
  }
}