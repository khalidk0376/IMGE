/**
 * Created by stevelohrenz on 5/26/17.
 Last Modified By: [Aishwarya BK-3759 27 Aug 2020]
 */

@IsTest
public class HttpCalloutMockImpl implements HttpCalloutMock {
    public Integer statusCode;
    public String body;
    public HttpCalloutMockImpl(Integer statusCode, String body) {
        this.statusCode = statusCode;
        this.body = body;
    }

    public HttpResponse respond(HttpRequest request) {
        System.debug('Request Recieved ::: ' + request);
        HttpResponse response = new HttpResponse();
        response.setStatusCode(this.statusCode);
        response.setStatus('Ok');
        response.setBody(this.body);
        response.setHeader(OutboundCallHelper.CONTENT_TYPE_HTTP_HEADER, OutboundCallHelper.JSON_FORMAT);
        return response;
    }
}