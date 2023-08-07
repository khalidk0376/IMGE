/**
 * Created By : Sudip Halder
 * Date:        17/Jul/2018
 * Apex Class : AccountRelatedAccountValidation
 * *************************************************************************
 * Description: This test class used in AccountRelatedAccountValidation_Test for Mock 
 * ************************************************************************* 
 * History: Modfied By Rajesh Kumar - BK-3755 on 29 - 04- 2020
 */
@isTest
public class AccountRelatedAccountValidationMock implements HttpCalloutMock {
  protected Integer code;
  protected String status;
  protected String body;
  protected Map<String, String> responseHeaders;
  public AccountRelatedAccountValidationMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
    this.code = code;
    this.status = status;
    this.body = body;
    this.responseHeaders = responseHeaders;
  }
  public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      for (String key : this.responseHeaders.keySet()) {
          res.setHeader(key, this.responseHeaders.get(key));
      }
      res.setBody(this.body);
      res.setStatusCode(this.code);
      res.setStatus(this.status);
      return res;
  }
}