/**
 * Created/Modified By   : Mahesh (Girikon)
 * Created On:           : June 12 2019
 * @description          : [This test class covers the apex class : IdentityAuth]
 * Modification log --
 * Modified By           :
**/
@isTest
private class IdentityAuthTest {
 
  private Static User communityUser;
 
  private static void setupData(){
    TestUtility.createSiteBranding('Default', 'informa', 'informa', 'Busisness Intellience', true);
    Account theAccount = TestUtility.createTestAccount(true, 'Test Account');
    Contact theContact = TestUtility.createTestContact(true, 'Test', 'Contact', theAccount.Id);
    Profile endUserPrfl= [Select Id,Name From Profile Where Name='Informa Markets Identity' Limit 1]; 
    communityUser = new User(
      FirstName = 'Test',
      LastName = 'Test',
      Email = 'landingcontroller@apextest.com',
      ProfileId = endUserPrfl.Id,
      ContactId = theContact.Id,
      Username = 'testex5@test.com',
      Alias = 'test',
      CommunityNickname = 'landingcontroller_5',
      TimeZoneSidKey = 'GMT',
      LocaleSidKey = 'en_GB',
      EmailEncodingKey = 'ISO-8859-1',
      LanguageLocaleKey = 'en_US',
      IsActive = TRUE);
    insert communityUser;
  }
   
  @isTest static void test_changePassword_successfull() {
     
    setupData();
 
    System.setPassword(communityUser.Id, '12345678abcDEF!');
 
    System.runAs(communityUser){
     
        Test.startTest();
     
        // test by setting variable as change password always returns null in unit tests
        IdentityAuth.treatAsSuccessfulTest = true;
         
        IdentityAuth.treatAsPasswordExipredTest = true;
         
        Site.forgotPassword(communityUser.Username);
         
        // Run test
        PageReference returnPage = IdentityAuth.changePassword(communityUser.Id, 'qwertyPassword1', 'qwertyPassword1', '12345678abcDEF!');
     
        // Change passwword will return null in test scenario
        System.assertEquals(null, returnPage,'The first and second parameter value should be match');
       //System.assertEquals(true, EmailVerificationService.isEmailVerified(communityUser.Id));
     
        Test.stopTest();
        }
     
    AsyncApexJob job = [select Status, NumberOfErrors from AsyncApexJob where ApexClass.Name = 'OAuthTokenHandler'];
    System.assertEquals('Completed', job.Status,'The first and second parameter value should be match');
    System.assertEquals(0, job.NumberOfErrors,'The first and second parameter value should be match');
  }
   
  @isTest static void test_method_two() {
 
    setupData();
 
    System.setPassword(communityUser.Id, '12345678abcDEF!');
 
    // test by setting variable as change password always returns null in unit tests
    IdentityAuth.treatAsSuccessfulTest = false;
    // Run test
    PageReference returnPage = IdentityAuth.changePassword(communityUser.Id, 'a', 'a', 'a');
 
    // Change passwword will return null in test scenario
    System.assertEquals(null, returnPage,'The first and second parameter value should be match');
 
    List<AsyncApexJob> jobs = [select Status, NumberOfErrors from AsyncApexJob where ApexClass.Name = 'OAuthTokenHandler'];
    System.assertEquals(true, jobs.isEmpty(),'The first and second parameter value should be match');
  } 
}