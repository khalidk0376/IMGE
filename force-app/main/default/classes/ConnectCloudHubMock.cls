/**
 * @Author      : Rajesh Kumar
 * @Date        : 2/Nov/2017
 * @Description : Mock class used in ProductSyncToSapController_Test
 */
@IsTest
global class ConnectCloudHubMock implements HttpCalloutMock {
    
    global HTTPResponse respond( HTTPRequest req ) {
        System.assertEquals('POST', req.getMethod( ), 'test class failled' );
        // Create a fake response
        HttpResponse res = new HttpResponse( );
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Header": {"Systems": {"CallingApplication": "SFDC-GE","MessageDate": "2017-11-01","MessageStatus": "ERROR","MessageStatusText": "Unknown product. See messages for more details."}},"Products": [{"ProductCode": "TOCEUR2017"},{"ProductCode": "TOCEUR2018"}],"Results": [{"ProductCode": "TOCEUR2017","isValid": false,"ProductExists": false},{"ProductCode": "TOCEUR2018","isValid": false,"ProductExists": false}],"Messages": [{"MessageReference": "TOCEUR2017","MessageSeverity": "1","MessageType": "ERROR","MessageID": "99","MessageText": "Error \'EXCEPTION\': \'INVALID_MATERIAL\'."},{"MessageReference": "TOCEUR2018","MessageSeverity": "1","MessageType": "ERROR","MessageID": "99","MessageText": "Error \'EXCEPTION\': \'INVALID_MATERIAL\'."}]}');
        res.setStatusCode( 200 );
        return res;
    }
}