/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-20)]
 * Created On   :   May 16 2019
 * @description :   [Without sharing required so site guest users can get revoke tokens]
 * Test Class   :   OAuthTokenHandlerTest
 * Modification Log----- 
 * Modified by  :   
 **/
global without sharing class OAuthTokenHandler implements Queueable, Database.AllowsCallouts {
 
  private static final String REVOKE_ENDPOINT = '/services/oauth2/revoke';
  private static Organization org {
    get{
      if(org == null){
        org = [SELECT IsSandbox, InstanceName FROM Organization LIMIT 1];
      }
      return org;
    }
    set;
  }
 
  private List<OauthToken> tokens;
  private Id userId;
 
  @testVisible private static Integer callsoutsProcessedNo;
  @testVisible private static Integer callsoutsLimitNo;
 
  // CONSTRUCTOR
  private OAuthTokenHandler(List<OauthToken> tokens) {
    this.tokens = tokens;
  }
 
  // CONSTRUCTOR
  private OAuthTokenHandler(Id userId) {
    this.userId = userId;
  }
 
     public void execute(QueueableContext context) {
 
       if(tokens == null && userId != null){
         tokens = getUserTokens(userId);
       }
 
      // System.debug('*** -- userId: ' +  userId);
      //System.debug('*** -- tokens: ' +  tokens);
      System.debug('*** -- tokens.size(): ' +  tokens.size());
     
    // 100 number of callouts per apex transaction
    while(!tokens.isEmpty() && getCallouts() < getLimitCallouts()){
       
      // Get the first index item in the list
      OauthToken token = tokens[0];
         System.debug('*** -- current token.Id: ' +  token);
      // perform the revoke callout
      Boolean successfullyRevoked = revokeToken(token);
      // Remove the token from the processing list
      tokens.remove(0);
    }
 
    // Check if there are any tokens remaining and reqeue new job
    if(!tokens.isEmpty()){
         System.debug('*** -- remaining tokens: ' +  tokens.size());
      ID jobID = System.enqueueJob(new OAuthTokenHandler(tokens));
    }
 
  }
  /*******************************************************************/
 
 
  public static Integer getCallouts(){
    Integer i = (callsoutsProcessedNo != null) ? callsoutsProcessedNo : Limits.getCallouts();
    System.debug('*** -- callsoutsProcessedNo: ' +  callsoutsProcessedNo);
    System.debug('*** -- Limits.getCallouts(): ' +  Limits.getCallouts());
    System.debug('*** -- getCallouts: ' +  i);
    return i;
  }
 
  public static Integer getLimitCallouts(){
    Integer i = (callsoutsLimitNo != null) ? callsoutsLimitNo : Limits.getLimitCallouts();
    System.debug('*** -- callsoutsLimitNo: ' +  callsoutsLimitNo);
    System.debug('*** -- Limits.getLimitCallouts(): ' +  Limits.getLimitCallouts());
    System.debug('*** -- getLimitCallouts: ' +  i);
    return i;
  }
 
  public static List<OauthToken> getUserTokens(Id userId){
    // Get the users OAuth tokens ordered by the new first, newer records are more likely to be valid
    return [SELECT Id, DeleteToken FROM OauthToken WHERE UserId = :userId AND AppName LIKE '%_ESSO' ORDER BY CreatedDate DESC];
  }
 
  public static Id revokeUserTokensAsync(Id userId){
 
   // System.debug('*** -- revokeUserTokens userId: ' + userId);
 
    ID jobID = System.enqueueJob(new OAuthTokenHandler(userId));
    return jobId;
  }
 
  public static Id revokeUserTokens(Id userId){
 
   // System.debug('*** -- revokeUserTokens userId: ' + userId);
 
    List<OauthToken> tokens = getUserTokens(UserId);
 
    Id jobId;
 
    if(!tokens.isEmpty()){
      jobId = revokeTokens(tokens);
    }
    return jobId;
  }
 
  public static Id revokeTokens(List<OauthToken> tokens){
    ID jobID = System.enqueueJob(new OAuthTokenHandler(tokens));
    return jobId;
  }
 
     public static Boolean revokeToken(OauthToken token){
 
       Boolean successfullyRevoked = false;
 
       String deleteToken = (Test.isRunningTest()) ? 'testtoken123132' : EncodingUtil.urlEncode(token.DeleteToken, 'UTF-8');
 
       // Create the revoke HTTP Request object
       HttpRequest req = new HttpRequest();
    //req.setEndpoint('callout:'+getRevokeEndpoint());
    req.setEndpoint(getRevokeEndpoint());
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    req.setBody('token=' + deleteToken);
     
    // Create a new http object to send the request object
    Http http = new Http();
    HTTPResponse res = http.send(req);
 
    if(res.getStatusCode() == 200){
      successfullyRevoked = true;
    }else{
      ExceptionHandler.capture(OAuthTokenHandler.Class, null, 'OAuthTokenHandler - REVOKE', 'Error revoking OAuth token - ' + token.Id, null);
    }
 
    return successfullyRevoked;
     }
 
 
     public static String getRevokeEndpoint(){
       return 'https://' + org.InstanceName.toLowerCase() + '.salesforce.com' + REVOKE_ENDPOINT;
     }
 
}