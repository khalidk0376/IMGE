/**
 *  Abstract class for the service methods that handles some of the boilerplate code for calling out.
 */

public abstract class RemoteTaxAbstractService {
    private String CALL_VERB = 'POST';
    public String INTEGRATION_SERVICE_NAME = 'TAX_CALCULATION';
    private String integrationUrl = '';
    private String integrationUsername = '';
    private String integrationPassword = '';
    public String MISSING_LEGAL_ENTITY = 'Legal Entity Not Defined';

    public RemoteTaxAbstractService() {
        integrationUrl = IntegrationSettingsHelper.getEndpointFromSettings(INTEGRATION_SERVICE_NAME);
        integrationUsername = IntegrationSettingsHelper.getUsernameFromSettings(INTEGRATION_SERVICE_NAME);
        integrationPassword = IntegrationSettingsHelper.getPasswordFromSettings(INTEGRATION_SERVICE_NAME);
    }

    public virtual CalculateTaxResponse makeOutboundCall(CalculateTaxRequest request) {
        System.debug('RemoteTaxAbstractService.makeOutboundCall()');

        String calcTaxPayload = CalculateTaxRequest.serializeToString(request);
        String response = '';
        try {
            response = OutboundCallHelper.makeClientIdTypeHttpRequest(integrationUrl, CALL_VERB, calcTaxPayload, integrationUsername, integrationPassword);
            System.debug('RemoteTaxAbstractService.makeOutboundCall() ' + response);
            
        } catch (InformaExceptions.InformaHttpException eek) {
            System.debug(LoggingLevel.ERROR, 'RemoteTaxAbstractService.makeOutboundCall() outbound call error ' + eek.getMessage() + ' ' + eek.getStackTraceString());
            insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = eek.getMessage() + ' ' + eek.getStackTraceString());
        }

        CalculateTaxResponse calcTaxResponse = CalculateTaxResponse.parse(response);
        System.debug('RemoteTaxAbstractService.makeOutboundCall response: ' + calcTaxResponse);
        if(calcTaxResponse.Header.Systems.MessageStatus == 'ERROR') {
            System.debug(LoggingLevel.WARN, 'RemoteTaxAbstractService.makeOutboundCall error message: ' + calcTaxResponse);
            insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = CalculateTaxResponse.serializeToString(calcTaxResponse));
            // Should be handled later.
            //throw new InformaExceptions.InformaHttpException(201, 'ERROR', 'Error when communicating with the tax system [' + calcTaxResponse.Header.Systems.MessageStatusText + ']');
        }
        return calcTaxResponse;
    }

}