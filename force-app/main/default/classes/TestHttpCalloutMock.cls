@isTest
public class TestHttpCalloutMock implements HttpCalloutMock {
 
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;
 
    public TestHttpCalloutMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
 
    public HTTPResponse respond(HTTPRequest req) {
 
        HttpResponse res = new HttpResponse();
        if(responseHeaders != null && !responseHeaders.isEmpty()){
            for (String key : this.responseHeaders.keySet()) {
                res.setHeader(key, this.responseHeaders.get(key));
            }
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
 
}