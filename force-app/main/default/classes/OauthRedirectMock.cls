global class OauthRedirectMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "issued_at" : "1597657978563","token_type" : "Bearer","id" : "https://test.salesforce.com/id/00D550000001HWNEA2/00550000007GvghAAC","instance_url" : "https://informage--devbau.my.salesforce.com","id_token" : "eyJraWQiOiIyMjYiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoid2tLLWxOTGFvN0tGbUVDdEtKMWRQUSIsInN1YiI6Imh0dHBzOi8vdGVzdC5zYWxlc2ZvcmNlLmNvbS9pZC8wMEQ1NTAwMDAwMDFIV05FQTIvMDA1NTAwMDAwMDdHdmdoQUFDIiwiYXVkIjoiM01WRzk4RUU1OS5WSUhtejl5SHE5SjVZUHE0blFxQ0dSWnhrRktHRFI1S0dRMlduc2pQZTh4a2Fxc1lGOU5oeVBmVGIzSFdOLk9aS2xUV1Z4NllMUyIsImlzcyI6Imh0dHBzOi8vdGVzdC5zYWxlc2ZvcmNlLmNvbSIsImV4cCI6MTU5NzY1ODA5OCwiaWF0IjoxNTk3NjU3OTc4fQ.Dnu68rSgFYUT4mt_6HlNzpGxUXXAYbwubkPsaV0x0ZJIx1gy3V9Rx7KID","scope" : "refresh_token full","signature" : "On2s+1VmyW88YUXGO79Tyr4uyuLk30qfQBYr9fjt2K8=","refresh_token" : "5Aep861ulCxXNoWflrgVsdFgVFNWLohNiJ5nRiizzJP5Gexj5GUTAV3JUFUg6DkFOD6AIl5NVu.qGsdqp6vSytM","access_token" : "SESSION_ID_REMOVED"}');
        res.setStatusCode(200);
        return res;
    }
}