/**
* Controller to handle validating the the customer.
* Call out to Mulesoft.
* History: 
* 18/7/2018 : Modified by Kumar for Jira Ticket GGCW-2172
*/

public with sharing class ValidateCustomerController {
    
    private String CALL_VERB = 'POST';
    private String INTEGRATION_SERVICE_NAME = 'VALIDATE_CUSTOMER';
    private Account account;
    private Contact primaryContact;
    private String integrationUrl = '';
    private String integrationUsername = '';
    private String integrationPassword = '';
    
    
    public ValidateCustomerController() {
        system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
    }
    
    public ValidateCustomerController(ApexPages.StandardController standardController) {
        system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
    }
    
    /**
* Method to use from the apex page.
*/
    public PageReference validateCustomer() {
        String accountId = System.currentPageReference().getParameters().get('acctId');
        try {
            return createValidateCallout(accountId);
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Exception Occurred: ' + e.getMessage());
            ApexPages.addMessage(msg);
            return null;
        }
    }
    
    public PageReference createValidateCallout(String accountId) {
        integrationUrl = IntegrationSettingsHelper.getEndpointFromSettings(INTEGRATION_SERVICE_NAME);
        integrationUsername = IntegrationSettingsHelper.getUsernameFromSettings(INTEGRATION_SERVICE_NAME);
        integrationPassword = IntegrationSettingsHelper.getPasswordFromSettings(INTEGRATION_SERVICE_NAME);
        System.debug('ValidateCustomerController.createValidateCallout() accountId ' + accountId);
        try {
            if(String.isNotBlank(accountId)) {
                //Modified By Kumar : GGCW-2172 [Added one more Field to the Query i.e BillingStateCode]
                account = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingCountryCode, Phone, Fax, blng__BillToContact__c, Billing_Address_Line_2__c, BillingStateCode FROM Account WHERE Id = :accountId LIMIT 1];
                System.debug('ValidateCustomerController.createValidateCallout() account ' + account);
                if(account != null) {
                    /*primaryContact = [
SELECT Id, Email, Phone, Title, Name, FirstName, LastName, AccountId,
MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry, Fax
FROM Contact
WHERE Id = :account.blng__BillToContact__c
LIMIT 1];*/
                    primaryContact = [SELECT Id, Email, Phone, Title, Name, FirstName, LastName, AccountId,
                                      MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry, Fax,
                                      Address_Verified__c FROM Contact WHERE AccountId = :accountId AND Contact_Type__c = 'Invoice Contact' LIMIT 1];
                    System.debug('ValidateCustomerController.createValidateCallout() primaryContact ' + primaryContact);
                }
                
            }
        } catch (Exception eek) { insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = eek.getMessage() + ' ' + eek.getStackTraceString());
            System.debug(LoggingLevel.ERROR, 'ValidateCustomerController() selecting error: ' + eek.getMessage() + ' ' + eek.getStackTraceString());
            
        }
        
        if(account != null) {
            System.debug('ValidateCustomerController.createValidateCallout() account not null  primaryContact: ' + primaryContact);
            ValidateCustomerRequest vCustomerRequest = new ValidateCustomerRequest(account, primaryContact);
            System.debug('ValidateCustomerController.createValidateCallout() vCustomerRequest ' + vCustomerRequest);
            
            String validateCustomerPayload = ValidateCustomerRequest.serializeToString(vCustomerRequest);
            System.debug('ValidateCustomerController.createValidateCallout() ' + validateCustomerPayload);
            
            String response = '';
            try {
                response = OutboundCallHelper.makeClientIdTypeHttpRequest(integrationUrl, CALL_VERB, validateCustomerPayload, integrationUsername, integrationPassword);
                System.debug('ValidateCustomerController.createValidateCallout() ' + response);
                
            } catch (InformaExceptions.InformaHttpException eek) {  insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = eek.getMessage() + ' ' + eek.getStackTraceString());
                
                System.debug(LoggingLevel.ERROR, 'ValidateCustomerController() outbound call error ' + eek.getMessage() + ' ' + eek.getStackTraceString());
                
                //End
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Exception Occurred: ' + eek.getMessage());
                ApexPages.addMessage(msg);
                account.addError(eek);
                return new PageReference('/' + account.Id);
            }
            Boolean addressVerified = false;
            ValidateCustomerResponse customerResponse = ValidateCustomerResponse.parse(response);
            System.debug('ValidateCustomerController.createValidateCallout response: ' + customerResponse);
            if(customerResponse.Header != null && (String.isBlank(customerResponse.Header.Systems.MessageStatus) || customerResponse.Header.Systems.MessageStatus == 'OK' || customerResponse.Header.Systems.MessageStatus == 'UPDATED'))  {
                addressVerified = true;
            } else {
                // The response was not completed successfully.
                System.debug(LoggingLevel.ERROR, 'ValidateCustomerController.createValidateCallout() error response from the server ' + customerResponse.Messages);
                String errorString = '';
                for(ValidateCustomerResponse.Message message: customerResponse.Messages) {
                    errorString += ' [' + message.MessageType + ' ' + message.MessageText + '] ';
                }
                addressVerified = false;
                
                insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = errorString, Affected_Object__c = 'Account', Affected_Object_Details__c = accountId);
                
                throw new InformaExceptions.InformaHttpException(1001, 'Error from integration server occurred: [' + errorString + ']');
            }
            
            account.Address_Verified__c = addressVerified;
            
            try { update account;
            } catch (Exception e1) {   throw new InformaExceptions.InformaHttpException(1001, 'Error from integration server occurred: [' + e1.getMessage() + ']');
            
            }
        }
        return new PageReference('/' + account.Id);
    }
}