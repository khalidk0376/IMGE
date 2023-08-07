/**
 * Created/Modified By   :  Mahesh (Girikon)
 * Created On:           :  June 12 2019
 * @description          : [ This test class covers the apex class : OAuthTokenHandler]
 * Modification log --     [Modified By : Aishwarya 12 Aug 2020 BK-3751]
 * Modified By           :
**/
@isTest
private class OAuthTokenHandlerTest {
   
  @isTest static void test_method_one() {
    // Set the mock response from revoke callout
   Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','', null));
     
    OAuthTokenHandler.getUserTokens(UserInfo.getUserId());
    OAuthTokenHandler.revokeUserTokens(UserInfo.getUserId());
     
 
    System.assertEquals(OAuthTokenHandler.getCallouts(), Limits.getCallouts(),'The first and second parameter value should be match');
 
    OAuthTokenHandler.callsoutsProcessedNo = 10;
    System.assertEquals(10, OAuthTokenHandler.getCallouts(),'The first and second parameter value should be match');
 
    System.assertEquals(OAuthTokenHandler.getLimitCallouts(), Limits.getLimitCallouts(),'The first and second parameter value should be match');
 
    OAuthTokenHandler.callsoutsLimitNo = 10;
    System.assertEquals(10, OAuthTokenHandler.getLimitCallouts(),'The first and second parameter value should be match');
 
    System.assert(String.isNotBlank(OAuthTokenHandler.getRevokeEndpoint()),'The first and second parameter value should be match');
  }
   
 @isTest static void test_method_two() {
    // Set the mock response from revoke callout
  Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','', null));
    Test.startTest(); 
    Id jobId = OAuthTokenHandler.revokeTokens(createTestToken(2));
    System.assertNotEquals(jobId, null, 'Job Id should not be blank.'); 
    Test.stopTest();
  } 
 
  /*@isTest static void test_method_three() {
    // Set the mock response from revoke callout
   // Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','', null));
 
    Boolean isSuccessful = OAuthTokenHandler.revokeToken(createTestToken(1)[0]);
     
    System.assertEquals(isSuccessful , true);
  }*/
 
  @isTest static void test_method_four() {
    // Set the mock response from revoke callout
   Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','', null));
 
    Test.startTest();
    Id jobId = OAuthTokenHandler.revokeUserTokensAsync(UserInfo.getUserId());
    System.assertNotEquals(jobId, null, 'Job Id should not be blank.'); 
    Test.stopTest();
 
    /***** Salesforce known issues commenting out assertions unill resolved - https://success.salesforce.com/issues_view?id=a1p300000008XJvAAM *****/
    // System.assertNotEquals(null, jobId);
    // AsyncApexJob job = [select Status, NumberOfErrors from AsyncApexJob where Id=:jobId];
    // System.assertEquals('Completed', job.Status);
    // System.assertEquals(0, job.NumberOfErrors);
  }
 
 /* @isTest static void test_method_five() {
    // Set the mock response from revoke callout
   // Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(400, 'BAD_REQUEST','', null));
 
    Boolean isSuccessful = OAuthTokenHandler.revokeToken(createTestToken(1)[0]);
     
    System.assertEquals(isSuccessful , false);
    System.assertEquals(1, [SELECT COUNT() FROM esso_ErrorLog__c WHERE Class__c = 'OAuthTokenHandler']);
  } */
 
 
  // Test method to create data
  private static List<OAuthToken> createTestToken(Integer numberToGenerate){
 
    List<OAuthToken> tokens = new List<OauthToken>();
 
    for(Integer i = 0; i < numberToGenerate; i++){
      tokens.add(
        new OAuthToken() // Add an empty object in memory as you cannot create this test data
      );
    }
    return tokens;
  }
}