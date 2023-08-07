/**
 * This Mock class used in CurrencyTypeCtrl_Test
 * @Author : Sudip Halder
 * @Date   : 27/Apr/2018
 */
@IsTest
public class CurrencyTypeCtrlMock implements HttpCalloutMock {
  protected Integer code;
  protected String status;
  protected String body;
  protected Map<String, String> responseHeaders;
  public CurrencyTypeCtrlMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
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
        //res.setHeader('Content-Type', 'application/json');
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}