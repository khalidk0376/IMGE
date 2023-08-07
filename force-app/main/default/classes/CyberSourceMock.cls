@isTest
global class CyberSourceMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        string ChargeBody  =    '<?xml version="1.0" encoding="utf-8"?>'+
                                '<mcasResponse>' + 
                                '<status>1</status>' + 
                                '<message>APPROVED: Payment has been Approved.</message>'+
                                '<MCASId>2013068</MCASId>'+
                                '<AuthCode>303</AuthCode>'+
                                '</mcasResponse>';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/XML');
        res.setBody(ChargeBody);
        res.setStatusCode(200);
        return res;
    }
}