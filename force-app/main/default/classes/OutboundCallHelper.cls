/**
 * Utility class for handling interactions out of SF.
 *
 */
public with sharing class OutboundCallHelper {

    public static Integer REQUEST_TIMEOUT = 120000;
    public static Integer DEFAULT_TIMEOUT = 60000;
    public  static String CONTENT_TYPE_HTTP_HEADER = 'Content-Type';
    public static String FORM_URL_ENC_FORMAT = 'application/x-www-form-urlencoded';
    public static String JSON_FORMAT = 'application/json';

    /**
     * Make an outbound http request with BASIC authentication.
     */
    public static String makeClientIdTypeHttpRequest(String url, String verb, String bodyContent, String clientId, String clientSecret) {
        system.debug('Test_url->'+url+'Test_verb->'+verb+'Test_bodyContent->'+bodyContent+'Test_clientId->'+clientId+'Test_clientSecret->'+clientSecret);
        String clientUrl = url.trim() + '?client_id=' + clientId.trim() + '&client_secret=' + clientSecret.trim();
        HttpRequest httpRequest = createBasicTokenHttpRequest(clientUrl, verb.trim());

        if(bodyContent != null) {
            httpRequest.setBody(bodyContent);
        }

        httpRequest.setTimeout(REQUEST_TIMEOUT);
        httpRequest.setHeader(CONTENT_TYPE_HTTP_HEADER, JSON_FORMAT);
		system.debug('test_httpRequest'+httpRequest);
        Http http = new Http();

        printHttpRequest(httpRequest);
        HttpResponse httpResponse = http.send(httpRequest);
        system.debug('test_httpResponse'+httpResponse);
        printHttpResponse(httpResponse);
        //checkHttpGoodOrRaiseException(httpResponse);
		system.debug('httpResponse_getBody'+httpResponse.getBody());
        return httpResponse.getBody();
    }

    /**
     * Create a basic http request with default settings.
     */
    public static HttpRequest createBasicTokenHttpRequest(String url, String verb) {
        if(url == null || verb == null) {
            throw new InformaExceptions.InformaInvalidInputException(100, 'Null Input in create basic http request.');
        }

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(url);
        httpRequest.setTimeout(DEFAULT_TIMEOUT);
        httpRequest.setMethod(verb);
        httpRequest.setHeader(CONTENT_TYPE_HTTP_HEADER, FORM_URL_ENC_FORMAT);

        return httpRequest;
    }

    /**
     * Create a basic http request with default settings and basic authorization parameters.
     */
    /*public static HttpRequest createBasicAuthorizationHttpRequest(String url, String verb, String username, String password) {
        HttpRequest httpRequest = createBasicTokenHttpRequest(url, verb);

        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        httpRequest.setHeader('Authorization', authorizationHeader);

        return httpRequest;
    } */

    /**
     * Checks to see if the return codes were 'valid'.
     * 200
     * 201
     *
     */
    /*public static void checkHttpGoodOrRaiseException(HttpResponse response) {
        Set<Integer> acceptableReturnCodes = new Set<Integer>();
        acceptableReturnCodes.add(200);
        acceptableReturnCodes.add(201);
        checkHttpGoodOrRaiseException(response, acceptableReturnCodes);
    }

    public static String checkHttpGoodOrRaiseException(HttpResponse response, Set<Integer> acceptableReturnCodes) {
        if(response == null) {
            throw new InformaExceptions.InformaInvalidInputException(100, 'Null input for response in checkHttpGoodOrRaiseException');
        }
        if(acceptableReturnCodes.contains(response.getStatusCode())) {
            return '';
        }
        throw new InformaExceptions.InformaHttpException(response.getStatusCode(), response.getStatus(), 'Return code was not in the list of acceptable return codes.');
    }  */

    /**
     * Prints the httpResponse to the debug logs.
     */
    public static void printHttpResponse(HttpResponse response) {
        if(response != null) {
            System.debug(' ***** Response Start *****');
            System.debug('Status Code: ' + response.getStatusCode());
            System.debug('Status: ' + response.getStatus());
            System.debug('Body: ' + response.getBody());
            System.debug('Content-Type: ' + response.getHeader(CONTENT_TYPE_HTTP_HEADER));
            System.debug(' ***** Response End   *****');
        }
    }

    /**
     * Prints the httpRequest to the debug logs.
     */
    public static void printHttpRequest(HttpRequest request) {
        if(request != null) {
            System.debug(' ***** Request Start *****');
            if(request.getHeader(CONTENT_TYPE_HTTP_HEADER) != null) {
                System.debug(CONTENT_TYPE_HTTP_HEADER + ': ' + request.getHeader(CONTENT_TYPE_HTTP_HEADER));
            }
            System.debug('Endpoint: ' + request.getEndpoint());
            if(request.getBody() != null) {
                System.debug('Body: ' + request.getBody());
            }
            System.debug('Method: ' + request.getMethod());
            System.debug(' ***** Request End   *****');
        }
    }


    
}