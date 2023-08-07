/**
 * Test for the Outbound call helper. 
 */

@IsTest
private class OutboundCallHelperTest {
    static testMethod void testCreateBasicTokenHttpRequestNull() {
        try {
            OutboundCallHelper.createBasicTokenHttpRequest(null, 'GET');
        } catch(InformaExceptions.InformaInvalidInputException eek) {
            System.assertEquals(100, eek.statusCode,'statusCode must be equal to 100');
        }
    }

    static testMethod void testMakeClientIdTypeHttpRequest(){
        String resultBody;
        try{
            Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING));
            resultBody = OutboundCallHelper.makeClientIdTypeHttpRequest('http://result', 'GET', BODY_STRING, '111232', '22222');
        } catch (Exception eek) { 
            System.assertEquals(null,eek,'Exceptions should be handled by the method');
        }
        
        System.assertNotEquals(null, resultBody,'resultBody not equal null');
        System.assertEquals(RESPONSE_STRING, resultBody,'resultBody equal to responseString');
    }

    public static String BODY_STRING = '{NAME: \'Joe Schmoe\'}';

    public static String RESPONSE_STRING = 'Saved';
}