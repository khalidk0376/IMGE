global class OAuthMockHttpResponseGenerator  implements HttpCalloutMock {
global HTTPResponse respond(HTTPRequest req) 
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Location','https://test.salesforce.com/setup/secur/RemoteAccessAuthorizationPage.apexp?source=CAAAAXQF-tpVME8wMHYwMDAwMDA0QzkzAAAA4hkiBcFXXc84XtV0Qp2W76PuHOaF37-IwHOwWqX2kD0uC4qqVq7sKM84rq6eRPxv2QV7OZ9od0jZZe1ZhFDKn0LONZ-1aXGxVcfYbUVANbQukx8EPDNWBQF8b2a3HjHQi-gE8xz1iXiubs8QBo6OSSoMhdVXQ4U7gsZzMQch_0j6aQ69tciuEJB6f5SUiiq5h--yG4x_CYj3Pt2nTcqEmG0OAQXXazhn9GDhT8kL7u-zeVolBF0pqgYdFitLtWTf-arRUpPA69KDBUiYgGEWxOw75Jx0IT9n3hqXdO7WKAZT8vyrvejViC_mJlzdSiLyb2w61ZwxII9SW59SeN-3NMNwZoQd43khEuuJDCs7fhbUBf');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(302);
        return res;

}
}