/**
 * Covers the VAT Validation - create the
 * History: 
 * 18/7/2018 : Modified by Kumar for Jira Ticket GGCW-2172
 * Ticket No : BK-14521 Updating API Version
 */

public with sharing class VATValidationController {

    private String CALL_VERB = 'POST';
    private String INTEGRATION_SERVICE_NAME = 'VAT_VALIDATION';
    private Account account;
    private Contact primaryContact;
    private String integrationUrl = '';
    private String integrationUsername = '';
    private String integrationPassword = '';

    private VATValidationControllerDatabaseInterface databaseInterface;

    public VATValidationController() {        databaseInterface = new VATValidationControllerDatabaseDefaultImpl();    }

    public VATValidationController(ApexPages.StandardController standardController) {        databaseInterface  = new VATValidationControllerDatabaseDefaultImpl();    }

    public VATValidationController(VATValidationControllerDatabaseInterface altInterface) {
        databaseInterface = altInterface;
    }

    public VATValidationController(ApexPages.StandardController standardController, VATValidationControllerDatabaseInterface altInterface) {
        databaseInterface = altInterface;
    }

    public PageReference validateVATNumber() {
        String accountId = System.currentPageReference().getParameters().get('acctId');
        try {
            return createVATValidationCallout(accountId);
        } catch (Exception e) {            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Exception Occurred: ' + e.getMessage());            ApexPages.addMessage(msg);            return null;        }
    }

    public PageReference createVATValidationCallout(String accountId) {
        integrationUrl = IntegrationSettingsHelper.getEndpointFromSettings(INTEGRATION_SERVICE_NAME);
        integrationUsername = IntegrationSettingsHelper.getUsernameFromSettings(INTEGRATION_SERVICE_NAME);
        integrationPassword = IntegrationSettingsHelper.getPasswordFromSettings(INTEGRATION_SERVICE_NAME);

        Account anAccount = databaseInterface.queryAccountByAccountId(accountId);
        if(anAccount != null) {
            VATValidationRequest request = new VATValidationRequest(anAccount);
            String validateVATPayload = request.serializeToString(request);
            String response = '';
            try {
                response = OutboundCallHelper.makeClientIdTypeHttpRequest(integrationUrl, CALL_VERB, validateVATPayload, integrationUsername, integrationPassword);
            } catch (InformaExceptions.InformaHttpException eek) {
                insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = eek.getMessage() + ' ' + eek.getStackTraceString());
            }
            try{
                VATValidationResponse vatResponse = (VATValidationResponse) System.JSON.deserialize(response, VATValidationResponse.class);
            
                if(vatResponse.Header != null && (String.isBlank(vatResponse.Header.Systems.MessageStatus) ||
                vatResponse.Header.Systems.MessageStatus == 'OK' || vatResponse.Header.Systems.MessageStatus == 'UPDATED')) {
                    for(VATValidationResponse.Message message: vatResponse.Messages) {
                        if(message.MessageType == 'Success') {
                            anAccount.Tax_ID_Verified__c = true;
                            anAccount.Tax_ID_Verified_Message__c = message.MessageText;
                        } else {
                            anAccount.Tax_ID_Verified__c = false;
                            anAccount.Tax_ID_Verified_Message__c = message.MessageText;
                        }
                    }
                    databaseInterface.updateAccount(anAccount);
                } 
                else {
                    // the response was not processed successfully
                    String errorString = '';
                    for(VATValidationResponse.Message message: vatResponse.Messages) {
                        errorString += ' [' + message.MessageType + ' ' + message.MessageText + '] ';
                    }

                    insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = errorString, Affected_Object__c = 'Account', Affected_Object_Details__c = anAccount.Id);

                    throw new InformaExceptions.InformaHttpException(1001, 'Error from integration server occurred: [' + errorString + ']');
                }
            }
            catch(Exception ex){
               insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = ex.getMessage() + ' ' + ex.getStackTraceString() , Affected_Object__c = 'Account' ,Affected_Object_Details__c = anAccount.Id ) ;
            }
        }
        return new PageReference('/' + accountId);
    }



    /**
 * Database interface for the vat validation controller.
 */
    public interface VATValidationControllerDatabaseInterface {
/**
 * Retrieves an account by the account id.
 *
 * @param accountId - Id of the account to retrieve.
 *
 * @return anAccount.
 */
        Account queryAccountByAccountId(String accountId);

/**
 * Updates the account in the system. Saves.
 *
 * @param anAccount - the account to save.
 */
        void updateAccount(Account anAccount);

    }

    /**
     * Default implementation of the databaseInterface. Accesses the SF Database. 
     */
    public class VATValidationControllerDatabaseDefaultImpl implements VATValidationControllerDatabaseInterface {
        public Account queryAccountByAccountId(String accountId) {   /*Modified By Kumar : GGCW-2172 [Added one more Field to the Query i.e BillingCountryCode]*/    List<Account> accounts =  [SELECT Id, Name, BillingCountry, Tax_Id__c, Tax_ID_Verified__c, BillingCountryCode FROM Account WHERE Id = :accountId LIMIT 1];     return accounts.get(0); }

        public void updateAccount(Account anAccount) {            if(anAccount != null) {                update anAccount;            }        }
    }

}