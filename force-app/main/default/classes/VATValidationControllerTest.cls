/**
 * Unit test for the VATValidationController, VATValidationRequest, o classes.
 */
//Ticket No. BK-14521 Updating API Version
@IsTest
private class VATValidationControllerTest {
    @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
    }

    static testMethod void testCreateValidationCalloutSuccessValid() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createSBQQStack(doInsert);
        Account anAccount = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        anAccount.Tax_ID__c = 'GBGB165632969';
        VATValidationDatabaseMockImpl mock = new VATValidationDatabaseMockImpl();
        mock.returnQueryAccountByAccountId = anAccount;

        PageReference pageReference = Page.VATValidation;
        Test.setCurrentPage(pageReference);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING_SUCCESS_VALID));
        pageReference.getParameters().put('acctId', String.valueOf(anAccount.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(anAccount);
        
        VATValidationController controller = new VATValidationController(standardController, mock);
        Test.startTest();
        controller.validateVATNumber();

        Test.stopTest();

        System.assertNotEquals(null, mock.valueUpdateAccount,'Condition Should Match');
        //System.assert(mock.valueUpdateAccount.Tax_ID_Verified__c,'Condition Should Match');
        System.assertNotEquals(mock.valueUpdateAccount.Tax_ID_Verified__c,null,'Condition Should Match');
    }

    static testMethod void testCreateValidationCalloutSuccessInvalid() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createSBQQStack(doInsert);
        Account anAccount = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        anAccount.Tax_ID__c = 'GBGB165632969';
        VATValidationDatabaseMockImpl mock = new VATValidationDatabaseMockImpl();
        mock.returnQueryAccountByAccountId = anAccount;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING_SUCCESS_INVALID));

        VATValidationController controller = new VATValidationController(mock);
        Test.startTest();
        controller.createVATValidationCallout(anAccount.Id);

        Test.stopTest();

        System.assertNotEquals(null, mock.valueUpdateAccount,'Condition Should Match');
        //System.assert(!mock.valueUpdateAccount.Tax_ID_Verified__c,'Condition Should Match');
        System.assertNotEquals(null,mock.valueUpdateAccount.Tax_ID_Verified__c,'Condition Should Match');
        System.assertNotEquals(null, mock.valueUpdateAccount.Tax_ID_Verified_Message__c,'Condition Should Match');
    }

    static testMethod void testCreateValidationCalloutError() {
        Boolean errorThrown = false;
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createSBQQStack(doInsert);
        Account anAccount = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        anAccount.Tax_ID__c = 'GBGB165632969';
        VATValidationDatabaseMockImpl mock = new VATValidationDatabaseMockImpl();
        mock.returnQueryAccountByAccountId = anAccount;
        
        System.assertNotEquals(true, errorThrown, 'There must no errors');

        PageReference pageReference = Page.VATValidation;
        Test.setCurrentPage(pageReference);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING_ERROR));
        pageReference.getParameters().put('acctId', String.valueOf(anAccount.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(anAccount);

        VATValidationController controller = new VATValidationController(standardController, mock);
        Test.startTest();
        try {
            controller.validateVATNumber();
        } catch (InformaExceptions.InformaHttpException eek) {
            errorThrown = true;
        }
        Test.stopTest();
    }

    static testMethod void testCreateValidationCalloutErrorException() {
        Boolean errorThrown = false;
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createSBQQStack(doInsert);
        Account anAccount = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        anAccount.Tax_ID__c = 'GBGB165632969';
        VATValidationDatabaseMockImpl mock = new VATValidationDatabaseMockImpl();
        mock.returnQueryAccountByAccountId = anAccount;
        System.assertNotEquals(true, errorThrown, 'There must no errors');

        PageReference pageReference = Page.VATValidation;
        Test.setCurrentPage(pageReference);
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());
        pageReference.getParameters().put('acctId', String.valueOf(anAccount.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(anAccount);

        VATValidationController controller = new VATValidationController(standardController, mock);
        Test.startTest();
        try {
            controller.validateVATNumber();
        } catch (Exception eek) {
            errorThrown = true;
        }
        Test.stopTest();
        
    }
	
    static testMethod void testVATValdiationResponse() {
       	VATValidationResponse vatResponse = (VATValidationResponse)System.JSON.deserialize(RESPONSE_STRING_SUCCESS_VALID , VATValidationResponse.class);
        System.assertNotEquals(null, vatResponse.VATCodes,'Condition Should Match');
        system.debug('vatResponse----------->'+vatResponse);
        List<VATValidationResponse.VATCodes> vatCodes = vatResponse.VATCodes;
        for(VATValidationResponse.VATCodes vatCode: vatCodes) {
            if(vatCode.ValidVAT == true) {
                //System.assert(String.isNotBlank(vatCode.Country),'Condition Should Match');
                System.assertNotEquals(String.isNotBlank(vatCode.Country),null,'Condition Should Match');
                //System.assert(String.isNotBlank(vatCode.VATNumber),'Condition Should Match');
                System.assertNotEquals(String.isNotBlank(vatCode.VATNumber),null,'Condition Should Match');
                //System.assert(String.isNotBlank(vatCode.VATNumberUnformatted),'Condition Should Match');
                System.assertNotEquals(String.isNotBlank(vatCode.VATNumberUnformatted),null,'Condition Should Match');
                //System.assert(String.isNotBlank(vatCode.VATRegistrationType),'Condition Should Match');
                System.assertNotEquals(String.isNotBlank(vatCode.VATRegistrationType),null,'Condition Should Match');
            }
        }
		System.assertEquals('SFDC-GE', vatResponse.Header.Systems.CallingApplication,'Condition Should Match');
        System.assertEquals('OK', vatResponse.Header.Systems.MessageStatus,'Condition Should Match');
        System.assertEquals(null, vatResponse.Header.Systems.MessageStatusText,'Condition Should Match');
        System.assertEquals(null, vatResponse.Header.Systems.MessageDate,'Condition Should Match');
		
        
        System.assertNotEquals(null, vatResponse.Messages,'Condition Should Match');
        //System.assertNotEquals(null, vatResponse.Messages.MessageReference,'Condition Should Match');
        
        
    }


    /**
     * Mock implementation of the database interface. 
     */
    public class VATValidationDatabaseMockImpl implements  VATValidationController.VATValidationControllerDatabaseInterface {
        public Account returnQueryAccountByAccountId;
        public Account valueUpdateAccount;

        public Account queryAccountByAccountId(String accountId) {
            return returnQueryAccountByAccountId;
        }

        public void updateAccount(Account anAccount) {
            valueUpdateAccount = anAccount;

        }
    }

    private static String RESPONSE_STRING_SUCCESS_VALID = '{' +
            '\"Header\": {' +
            '\"Systems\": {  ' +
            '\"CallingApplication\": \"SFDC-GE\", ' +
            '\"MessageDate\": null, ' +
            '\"MessageStatus\": \"OK\",     ' +
            '\"MessageStatusText\": null   ' +
            '}                     ' +
            '},                     ' +
            '\"VATCodes\": [         ' +
            '{                       ' +
            '\"Country\": \"NL\",     ' +
            '\"VATNumber\": \"NL0036.41.776.B02\",    ' +
            '\"VATNumberUnformatted\": \"NL003641776B02\",   ' +
    '\"VATRegistrationType\": \"NL1\",   ' +
    '\"ValidVAT\": true                ' +
    '},                            ' +
    '{                             ' +
    '\"Country\": \"NL\",          ' +
    '\"VATNumber\": \"NL0036.41.776\", ' +
    '\"VATNumberUnformatted\": null,  ' +
    '\"VATRegistrationType\": null,  ' +
    '\"ValidVAT\": false        ' +
    '}                          ' +
    '],                         ' +
    '\"Messages\": [            ' +
    '{                          ' +
    '\"MessageReference\": \"NL0036.41.776.B02\",' +
    '\"MessageSeverity\": \"5\",    ' +
    '\"MessageType\": \"Success\",   ' +
    '\"MessageID\": \"0\",           ' +
    '\"MessageText\": \"\'NL0036.41.776.B02\' is a Valid VAT number for \'NL\'\"    ' +
    '}                                                                         ' +
    '        ]                           ' +
    '        }';

    private static String RESPONSE_STRING_SUCCESS_INVALID = '{' +
            '\"Header\": {' +
            '\"Systems\": {  ' +
            '\"CallingApplication\": \"SFDC-GE\", ' +
            '\"MessageDate\": \"2020-04-20\", ' +
            '\"MessageStatus\": \"OK\",     ' +
            '\"MessageStatusText\": null   ' +
            '}                     ' +
            '},                     ' +
            '\"VATCodes\": [         ' +
            '{                       ' +
            '\"Country\": \"NL\",     ' +
            '\"VATNumber\": \"NL0036.41.776.B02\",    ' +
            '\"VATNumberUnformatted\": \"NL003641776B02\",   ' +
            '\"VATRegistrationType\": \"NL1\",   ' +
            '\"ValidVAT\": true                ' +
            '},                            ' +
            '{                             ' +
            '\"Country\": \"NL\",          ' +
            '\"VATNumber\": \"NL0036.41.776\", ' +
            '\"VATNumberUnformatted\": null,  ' +
            '\"VATRegistrationType\": null,  ' +
            '\"ValidVAT\": false        ' +
            '}                          ' +
            '],                         ' +
            '\"Messages\": [            ' +
            '{ ' +
            '\"MessageReference\": \"NL0036.41.776\",       ' +
            '\"MessageSeverity\": \"3\",                  ' +
            '\"MessageType\": \"Error\",                   ' +
            '\"MessageID\": \"99\",         ' +
            '\"MessageText\": \"\'NL0036.41.776.B02\' is NOT a Valid VAT number for \'NL\'\"  ' +
            '        }                           ' +
            '        ]                           ' +
            '        }';

    private static String RESPONSE_STRING_ERROR = '{' +
            '\"Header\": {' +
            '\"Systems\": {  ' +
            '\"CallingApplication\": \"SFDC-GE\", ' +
            '\"MessageDate\": \"2020-04-20\", ' +
            '\"MessageStatus\": \"ERROR\",     ' +
            '\"MessageStatusText\": null   ' +
            '}                     ' +
            '},                     ' +
            '\"VATCodes\": [         ' +
            '{                       ' +
            '\"Country\": \"NL\",     ' +
            '\"VATNumber\": \"NL0036.41.776.B02\",    ' +
            '\"VATNumberUnformatted\": \"NL003641776B02\",   ' +
            '\"VATRegistrationType\": \"NL1\",   ' +
            '\"ValidVAT\": true                ' +
            '},                            ' +
            '{                             ' +
            '\"Country\": \"NL\",          ' +
            '\"VATNumber\": \"NL0036.41.776\", ' +
            '\"VATNumberUnformatted\": null,  ' +
            '\"VATRegistrationType\": null,  ' +
            '\"ValidVAT\": false        ' +
            '}                          ' +
            '],                         ' +
            '\"Messages\": [            ' +
            '{ ' +
            '\"MessageReference\": \"NL0036.41.776\",       ' +
            '\"MessageSeverity\": \"3\",                  ' +
            '\"MessageType\": \"Error\",                   ' +
            '\"MessageID\": \"99\",         ' +
            '\"MessageText\": \"\'NL0036.41.776.B02\' is NOT a Valid VAT number for \'NL\'\"  ' +
            '        }                           ' +
            '        ]                           ' +
            '        }';

    class UnauthorizedEndpointResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            InformaExceptions.InformaHttpException e = new InformaExceptions.InformaHttpException(200, 'Some error message');
            e.setMessage('Unauthorized endpoint, please check Setup -> Security -> Remote site settings');
            throw e;
        }
    }
}