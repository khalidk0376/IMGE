/**
 * Created by stevelohrenz on 4/28/17.
 */

public with sharing class IntegrationSettingsHelper {

    /**
     * Retrieve the integration settings.
     */
    public static Integration_Settings__c getIntegrationSettings(String serviceName) {
        Integration_Settings__c integrationSettings = Integration_Settings__c.getValues(serviceName);
        System.debug('IntegrationSettingsHelper.getIntegrationSettings() Service Name: ' + serviceName);
        if(integrationSettings == null) {
            throw new InformaExceptions.InformaValueDoesNotExistException(102, 'IntegrationSettingsHelper.getIntegrationSettings() serviceName: [' + serviceName + '] is not setup correctly. ');
        }
        return integrationSettings;
    }

    public static String getEndpointFromSettings(String serviceName) {
        Integration_Settings__c integrationSettings = getIntegrationSettings(serviceName);
        if(integrationSettings.Endpoint__c == null || integrationSettings.Endpoint__c == '') {
            throw new InformaExceptions.InformaValueDoesNotExistException(100, 'getEndpointFromSettings() returned blank or null [' + integrationSettings.Endpoint__c + ']');
        }
        return integrationSettings.Endpoint__c;
    }

    public static String getUsernameFromSettings(String serviceName) {
        Integration_Settings__c integrationSettings = getIntegrationSettings(serviceName);
        if(integrationSettings.Username__c == null || integrationSettings.Username__c == '') {
            throw new InformaExceptions.InformaValueDoesNotExistException(100, 'getUsernameFromSettings() returned blank or null [' + integrationSettings.Endpoint__c + ']');
        }
        return integrationSettings.Username__c;
    }

    public static String getPasswordFromSettings(String serviceName) {
        Integration_Settings__c integrationSettings = getIntegrationSettings(serviceName);
        if(integrationSettings.Password__c == null || integrationSettings.Password__c == '') {
            throw new InformaExceptions.InformaValueDoesNotExistException(100, 'getPasswordFromSettings() returned blank or null [' + integrationSettings.Endpoint__c + ']');
        }
        return integrationSettings.Password__c;
    }

}