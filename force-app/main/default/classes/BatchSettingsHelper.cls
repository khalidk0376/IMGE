/**
 * Helper class to handle the batch settings configured in Custom Settings -> Batch Settings.
 */

public with sharing class BatchSettingsHelper {

    public static Batch_Settings__c getBatchSettings(String serviceName) {
        Batch_Settings__c batchSettings = Batch_Settings__c.getValues(serviceName);
        System.debug('BatchSettingsHelper.getBatchSettings() ServiceName: ' + serviceName);
        if(batchSettings == null) {
            throw new InformaExceptions.InformaValueDoesNotExistException(103, 'BatchSettingsHelper.getBatchSettings() service [' + serviceName + '] is not setup correctly. ');
        }
        return batchSettings;
    }

    public static Integer getRetriesFromSettings(String serviceName) {
        Batch_Settings__c batchSettings = getBatchSettings(serviceName);
        if(batchSettings.Retries__c == null || batchSettings.Retries__c == 0) {
            throw new InformaExceptions.InformaValueDoesNotExistException(100, 'getRetriesFromSettings() returned blank or null [' + batchSettings.Retries__c + ']');
        }
        return Integer.valueOf(batchSettings.Retries__c);
    }

}